#pragma semicolon 1
#pragma newdecls required

static bool StartedQueue[MAXTF2PLAYERS];
static bool Downloading[MAXTF2PLAYERS];

static ArrayList SoundList;
static StringMap SoundAlts;
static int SoundLevel[MAXTF2PLAYERS];

static ArrayList ExtraList;
static int ExtraLevel[MAXTF2PLAYERS];
static bool DoingSoundFix[MAXTF2PLAYERS];

void FileNetwork_PluginStart()
{
	RegServerCmd("zr_showfilenetlist", DebugCommand);

	SoundList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	SoundAlts = new StringMap();
	ExtraList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
}

static Action DebugCommand(int args)
{
	char buffer[PLATFORM_MAX_PATH];

	if(SoundList)
	{
		int length = SoundList.Length;
		for(int i; i < length; i++)
		{
			SoundList.GetString(i, buffer, sizeof(buffer));
			PrintToServer("\"%s\"", buffer);
		}
	}

	if(ExtraList)
	{
		int length = ExtraList.Length;
		for(int i; i < length; i++)
		{
			ExtraList.GetString(i, buffer, sizeof(buffer));
			PrintToServer("\"%s\"", buffer);
		}
	}

	return Plugin_Handled;
}

void FileNetwork_MapEnd()
{
	for(int i; i < sizeof(SoundLevel); i++)
	{
		SoundLevel[i] = 0;
		ExtraLevel[i] = 0;
	}

	delete SoundList;
	delete SoundAlts;
	delete ExtraList;

	FileNetwork_PluginStart();
}

void FileNetwork_ClientPutInServer(int client)
{
	FileNetwork_ClientDisconnect(client);
#if !defined UseDownloadTable
	//give 3 seconds of breathing
	CreateTimer(3.0, Timer_FilenetworkBegin, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	DoingSoundFix[client] = false;
#endif
}

public Action Timer_FilenetworkBegin(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return Plugin_Stop;

	SendNextFile(client);
	return Plugin_Stop;
}
void FileNetwork_ClientDisconnect(int client)
{
	StartedQueue[client] = false;
	Downloading[client] = false;
	SoundLevel[client] = 0;
	ExtraLevel[client] = 0;
}

#if defined RPG
void FileNetwork_ConfigSetup()
#else
void FileNetwork_ConfigSetup(KeyValues map)
#endif
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "downloads");

	KeyValues kv = new KeyValues("Downloads");
	kv.ImportFromFile(buffer);
	
#if defined RPG
//This adds another ''//'' for no reason.
/*
	2 addons\sourcemod\configs\rpg_fortress\downloads.cfg
	3 addons\sourcemod\configs\rpg_fortress\\downloads.cfg

*/
	RPG_BuildPath(buffer, sizeof(buffer), "downloads");
	KeyValues enabled = new KeyValues("Packages");
	enabled.ImportFromFile(buffer);
#else
	KeyValues enabled;
	if(map)
	{
		map.Rewind();
		if(map.JumpToKey("Packages"))
			enabled = map;
	}

	if(!enabled)
	{
		zr_downloadconfig.GetString(buffer, sizeof(buffer));
		if(buffer[0])
		{
			BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);

			enabled = new KeyValues("Packages");
			enabled.ImportFromFile(buffer);
		}
		else
		{
			enabled = kv;
			enabled.JumpToKey("Default");
		}

	}
#endif

	ArrayList list = new ArrayList(ByteCountToCells(sizeof(buffer)));

	enabled.GotoFirstSubKey(false);
	do
	{
		enabled.GetSectionName(buffer, sizeof(buffer));
		list.PushString(buffer);
	}
	while(enabled.GotoNextKey(false));
	
	kv.Rewind(); // In case enabled is package
	if(kv.JumpToKey("Packages"))
	{
		int table = FindStringTable("downloadables");
		bool save = LockStringTables(false);
		
		kv.GotoFirstSubKey();
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			if(kv.GotoFirstSubKey(false))
			{
				bool extra = list.FindString(buffer) == -1;
				
				do
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					if(extra)
					{
						//ExtraList.PushString(buffer);
					}
					else if(FileExists(buffer, true))
					{
						AddToStringTable(table, buffer);
					}
					else
					{
						LogError("Failed to find file \"%s\" for downloads", buffer);
					}
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}
		}
		while(kv.GotoNextKey());

		LockStringTables(save);
	}

#if !defined RPG
	if(enabled != map && enabled != kv)
#endif
	{
		delete enabled;
	}

	delete list;
	delete kv;
}

stock void PrecacheSoundCustom(const char[] sound, const char[] altsound = "", int delay = 5)
{
	if(!sound[0])
		ThrowError("Empty string");
	
	PrecacheSound(sound);

#if defined UseDownloadTable
	if(delay < 9999999) //stop warnings.
	{
		char buffer[PLATFORM_MAX_PATH];
		FormatEx(buffer, sizeof(buffer), "sound/%s", sound);
		ReplaceString(buffer, sizeof(buffer), "#", "");
		AddFileToDownloadsTable(buffer);

		altsound[0] = 0; //stop warnings.
	}

#else
	if(altsound[0])
	{
		PrecacheSound(altsound);
		SoundAlts.SetString(sound, altsound);
	}

	if(delay >= 0)
	{
		DataPack pack = new DataPack();
		pack.WriteString(sound);
		RequestFrames(FileNetwork_AddSoundFrame, delay, pack);
	}
#endif
}

stock void PrecacheMvMIconCustom(const char[] icon, bool vtf = true)
{

	char buffer[PLATFORM_MAX_PATH];

	if(vtf)
	{
		FormatEx(buffer, sizeof(buffer), "materials/hud/leaderboard_class_%s.vtf", icon);

#if defined UseDownloadTable
		AddFileToDownloadsTable(buffer);
#else
		if(ExtraList.FindString(buffer) == -1)
			ExtraList.PushString(buffer);
#endif

	}

	FormatEx(buffer, sizeof(buffer), "materials/hud/leaderboard_class_%s.vmt", icon);

#if defined UseDownloadTable
	AddFileToDownloadsTable(buffer);
#else
	if(ExtraList.FindString(buffer) == -1)
		ExtraList.PushString(buffer);
#endif

#if !defined UseDownloadTable
	for(int client = 1; client <= MaxClients; client++)
	{
		if(StartedQueue[client] && !Downloading[client])
			SendNextFile(client);
	}
#endif

}

public void FileNetwork_AddSoundFrame(DataPack pack)
{
	pack.Reset();

	char buffer[PLATFORM_MAX_PATH];
	pack.ReadString(buffer, sizeof(buffer));

	delete pack;

	AddSoundFile(buffer);
}

static void AddSoundFile(const char[] sound)
{
	if(SoundList.FindString(sound) == -1)
	{
		SoundList.PushString(sound);
#if !defined UseDownloadTable
		for(int client = 1; client <= MaxClients; client++)
		{
			if(StartedQueue[client] && !Downloading[client])
				SendNextFile(client);
		}
#endif
	}
}

#if !defined UseDownloadTable
static void FormatFileCheck(const char[] file, int client, char[] output, int length)
{
	strcopy(output, length, file);
	ReplaceString(output, length, ".", "");
	Format(output, length, "%s_%d.txt", output, GetSteamAccountID(client, false));
}

static void SendNextFile(int client)
{
	// First, request a dummy file to see if they have it downloaded before

	StartedQueue[client] = true;
	
	static char download[PLATFORM_MAX_PATH];
	DataPack pack;

	if(ExtraLevel[client] < ExtraList.Length)
	{
		ExtraList.GetString(ExtraLevel[client], download, sizeof(download));

		pack = new DataPack();
		pack.WriteCell(true);	// Is an extra
	}
	else if(SoundLevel[client] < SoundList.Length)
	{
		SoundList.GetString(SoundLevel[client], download, sizeof(download));
		Format(download, sizeof(download), "sound/%s", download[download[0] == '#' ? 1 : 0]);
		
		pack = new DataPack();
		pack.WriteCell(false);	// Is a sound
	}

	if(pack)
	{
		Downloading[client] = true;

		pack.WriteString(download);
		
		static char filecheck[PLATFORM_MAX_PATH];
		FormatFileCheck(download, client, filecheck, sizeof(filecheck));
		FileNet_RequestFile(client, filecheck, FileNetwork_RequestResults, pack);
		if(!DeleteFile(filecheck, true))	// There has been some cases where we still have a file (Eg. plugin unload)
		{
			Format(filecheck, sizeof(filecheck), "download/%s", filecheck);
			DeleteFile(filecheck);
		}
	}
	else
	{
		Downloading[client] = false;

		PrintToConsole(client, "---");
		PrintToConsole(client, "[ZR/RPG] Finished Downloading/Verifying Files! You will hear and see everything as intended now.");
		PrintToConsole(client, "---");
	}
}

public void FileNetwork_RequestResults(int client, const char[] file, int id, bool success, DataPack pack)
{
	// If not found, send the actual file

	if(success)
	{
		if(!DeleteFile(file, true))
		{
			static char filecheck[PLATFORM_MAX_PATH];
			Format(filecheck, sizeof(filecheck), "download/%s", file);
			DeleteFile(filecheck);
				//LogError("Failed to delete file \"%s\"", file);
		}
	}

	if(StartedQueue[client])
	{
		static char download[PLATFORM_MAX_PATH];
		pack.Reset();
		bool extra = pack.ReadCell();
		pack.ReadString(download, sizeof(download));

		if(success)
		{
			if(extra)
			{
				ExtraLevel[client]++;
			}
			else
			{
				SoundLevel[client]++;
				if(IsValidClient(client))
				{
					/*
					char buffer[PLATFORM_MAX_PATH];
					Format(buffer, sizeof(buffer), "%s", download);
					ReplaceString(buffer, sizeof(buffer), "#", "");
					ReplaceString(buffer, sizeof(buffer), "sound/", "");

					PrecacheSound(buffer);
					EmitSoundToClient(client, buffer, client, SNDCHAN_STATIC, .volume = 0.1);

					PrintToChat(client, "%s",buffer);
					DataPack pack1;
					CreateDataTimer(5.0, Timer_FixSoundsCancelThem, pack1, TIMER_FLAG_NO_MAPCHANGE);
					pack1.WriteString(buffer);
					pack1.WriteCell(EntIndexToEntRef(client));
					*/
					if(!DoingSoundFix[client])
					{
						DataPack pack2;
						CreateDataTimer(0.25, StartSoundCache_ManualLoop, pack2, TIMER_FLAG_NO_MAPCHANGE);
						pack2.WriteCell(0);
						pack2.WriteCell(EntIndexToEntRef(client));
						pack2.WriteCell(0);
						DoingSoundFix[client] = true;
					}
				}
			}

			SendNextFile(client);
		}
		else
		{
			// So the client doesn't freak out about existing CreateFragmentsFromFile spam
			PrintToConsole(client, "[ZR/RPG] Downloading '%s'", download);
			if(FileNet_SendFile(client, download, FileNetwork_SendResults, pack))
				return;
			
			LogError("Failed to queue file \"%s\" to client", download);
		}
	}

	delete pack;
}
public void Manual_SoundcacheFixTest(int client)
{
	SetGlobalTransTarget(client);
	if(SoundList)
	{
		DataPack pack;
		CreateDataTimer(0.25, StartSoundCache_ManualLoop, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(0);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteCell(1);
	}
}

public Action StartSoundCache_ManualLoop(Handle timer, DataPack pack)
{
	pack.Reset();
	int SoundListArrayLoc = pack.ReadCell();
	int client = EntRefToEntIndex(pack.ReadCell());
	bool ShowNotif = view_as<bool>(pack.ReadCell());
	if(IsValidClient(client))
	{
		if(SoundListArrayLoc >= SoundList.Length)
		{
			if(ShowNotif)
				PrintToChat(client,"%t", "FixSoundManual Success");

			DoingSoundFix[client] = false;
			return Plugin_Handled;
		}
		if(SoundLevel[client] > SoundListArrayLoc)
		{
			if(ShowNotif)
				PrintToChat(client, "[ZR SOUND FIX] %i / %i", SoundListArrayLoc, SoundList.Length);

			char sound[PLATFORM_MAX_PATH];
			SoundList.GetString(SoundListArrayLoc, sound, sizeof(sound));
			ReplaceString(sound, sizeof(sound), "sound/", "");
			EmitCustomToClient(client, sound, client, SNDCHAN_AUTO, .volume = 0.01, .pitch = 1);
			SoundListArrayLoc++;
			DataPack pack2;
			CreateDataTimer(0.25, StartSoundCache_ManualLoop, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(SoundListArrayLoc);
			pack2.WriteCell(EntIndexToEntRef(client));
			pack2.WriteCell(ShowNotif);

			DataPack pack1;
			CreateDataTimer(1.5, Timer_FixSoundsCancelThem, pack1, TIMER_FLAG_NO_MAPCHANGE);
			pack1.WriteString(sound);
			pack1.WriteCell(EntIndexToEntRef(client));
			pack1.WriteCell(ShowNotif);
		}
		else
		{
			if(ShowNotif)
			{
				PrintToChat(client,"%t", "FixSoundManual Fail");
				return Plugin_Handled;
			}
			//Try again, and wait.
			DataPack pack2;
			CreateDataTimer(3.0, StartSoundCache_ManualLoop, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(SoundListArrayLoc);
			pack2.WriteCell(EntIndexToEntRef(client));
			pack2.WriteCell(ShowNotif);
		}
	}
	return Plugin_Handled; 
}

public Action Timer_FixSoundsCancelThem(Handle timer, DataPack pack)
{
	pack.Reset();
	char sound[PLATFORM_MAX_PATH];
	pack.ReadString(sound, PLATFORM_MAX_PATH);
	int client = EntRefToEntIndex(pack.ReadCell());
	if(IsValidClient(client))
	{
		EmitSoundToClient(client, sound, client, SNDCHAN_AUTO, _, SND_STOP, SNDVOL_NORMAL);
	}
	return Plugin_Handled; 
}


public void FileNetwork_SendResults(int client, const char[] file, bool success, DataPack pack)
{
	// When done, send a dummy file and the next file in queue
	
	if(StartedQueue[client])
	{
		if(success)
		{
			static char filecheck[PLATFORM_MAX_PATH];
			FormatFileCheck(file, client, filecheck, sizeof(filecheck));

			File filec = OpenFile(filecheck, "wt");
			if(filec)
			{
				filec.WriteLine("Verify");
				filec.Close();
				if(!FileNet_SendFile(client, filecheck, FileNetwork_SendFileCheck))
				{
					LogError("Failed to queue file \"%s\" to client", filecheck);
					DeleteFile(filecheck);
					//LogError("Failed to delete file \"%s\"", filecheck);
				}
			}
			else
			{
				LogError("Failed to write file \"%s\"", filecheck);
			}

			pack.Reset();
			if(pack.ReadCell())
			{
				ExtraLevel[client]++;
			}
			else
			{
				//Fix soundcache issues
				/*
					//When the sound is first played, it has an ugly ass reverb to it, this fixes it.
				*/
				if(!DoingSoundFix[client])
				{
					DataPack pack2;
					CreateDataTimer(0.25, StartSoundCache_ManualLoop, pack2, TIMER_FLAG_NO_MAPCHANGE);
					pack2.WriteCell(0);
					pack2.WriteCell(EntIndexToEntRef(client));
					pack2.WriteCell(0);
					DoingSoundFix[client] = true;
				}
				SoundLevel[client]++;
			}


			SendNextFile(client);
		}
		else
		{
			LogError("Failed to send file \"%s\" to client", file);
		}
	}

	delete pack;
}

public void FileNetwork_SendFileCheck(int client, const char[] file, bool success)
{
	// Delete the dummy file left over

	if(StartedQueue[client] && !success)
		LogError("Failed to send file \"%s\" to client", file);
	
	DeleteFile(file);
		//LogError("Failed to delete file \"%s\"", file);
}
#endif

stock void StopCustomSound(int entity, int channel, const char[] sound, float volume = SNDVOL_NORMAL)
{
	if(entity > 0 && entity <= MaxClients && channel == SNDCHAN_STATIC)
	{
		// Assume it's music
		EmitCustomToClient(entity, sound, entity, channel, _, SND_STOP, volume);
	}
	else
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
				EmitCustomToClient(client, sound, entity, channel, _, SND_STOP, volume);
		}
	}
}

stock bool EmitCustomToClient(int client, const char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3]=NULL_VECTOR, const float dir[3]=NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
{
#if defined UseDownloadTable
	float volume2 = volume;
	int count = RoundToCeil(volume);
	if(count > 1)
		volume2 /= float(count);
		
	for(int i; i < count; i++)
	{
		EmitSoundToClient(client, sound, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
	}
	return true;
#else

	int soundlevel = SoundList.FindString(sound);
	if(soundlevel != -1)
	{
		if(SoundLevel[client] > soundlevel)
		{
			float volume2 = volume;
			int count = RoundToCeil(volume);
			if(count > 1)
				volume2 /= float(count);
			
			for(int i; i < count; i++)
			{
				EmitSoundToClient(client, sound, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
			}
			return true;
		}
	}
	
	static char buffer[PLATFORM_MAX_PATH];
	if(!SoundAlts.GetString(sound, buffer, sizeof(buffer)))
	{
		if(soundlevel == -1)
			LogError("\"%s\" is not precached with PrecacheSoundCustom", sound);

		return false;
	}
	
	float volume2 = volume;
	int count = RoundToCeil(volume);
	if(count > 1)
		volume2 /= float(count);
		
	for(int i; i < count; i++)
	{
		EmitSoundToClient(client, buffer, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
	}
	return true;
#endif
}

stock void EmitCustomToAll(const char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3]=NULL_VECTOR, const float dir[3]=NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
{
	int[] clients = new int[MaxClients];
	int numClients;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
			clients[numClients++] = i;
	}

	if(numClients)
		EmitCustom(clients, numClients, sound, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

stock void EmitCustom(const int[] clients, int numClients, const char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3]=NULL_VECTOR, const float dir[3]=NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
{
#if defined UseDownloadTable
	float volume2 = volume;
	int count = RoundToCeil(volume);
	if(count > 1)
		volume2 /= float(count);
		
	for(int i; i < count; i++)
	{
		EmitSound(clients, numClients, sound, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
	}
#else
	int soundlevel = SoundList.FindString(sound);
	if(soundlevel == -1)
		ThrowError("\"%s\" is not precached with PrecacheSoundCustom", sound);
	
	int[] custom = new int[numClients];
	int[] alt = new int[numClients];
	int customNum, altNum;
	
	for(int i; i < numClients; i++)
	{
		if(SoundLevel[clients[i]] > soundlevel)
		{
			custom[customNum++] = clients[i];
		}
		else
		{
			alt[altNum++] = clients[i];
		}
	}

	if(customNum)
	{
		float volume2 = volume;
		int count = RoundToCeil(volume);
		if(count > 1)
			volume2 /= float(count);
			
		for(int i; i < count; i++)
		{
			EmitSound(custom, customNum, sound, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
		}
	}
	
	if(altNum)
	{
		static char buffer[PLATFORM_MAX_PATH];
		if(SoundAlts.GetString(sound, buffer, sizeof(buffer)))
		{
			float volume2 = volume;
			int count = RoundToCeil(volume);
			if(count > 1)
				volume2 /= float(count);
			
			for(int i; i < count; i++)
			{
				EmitSound(alt, altNum, buffer, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
			}
		}
	}
#endif
}

stock bool IsFileInDownloads(const char[] file)
{
	static int table;
	if(!table)
		table = FindStringTable("downloadables");
	
	char buffer[PLATFORM_MAX_PATH];
	int length = GetStringTableNumStrings(table);
	for(int i; i < length; i++)
	{
		if(ReadStringTable(table, i, buffer, sizeof(buffer)) && StrEqual(buffer, file, false))
			return true;
	}

	return false;
}
