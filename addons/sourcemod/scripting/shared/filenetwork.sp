#pragma semicolon 1
#pragma newdecls required

static bool StartedQueue[MAXTF2PLAYERS];
static bool Downloading[MAXTF2PLAYERS];

static ArrayList SoundList;
static StringMap SoundAlts;
static int SoundLevel[MAXTF2PLAYERS];

static ArrayList ExtraList;
static int ExtraLevel[MAXTF2PLAYERS];

void FileNetwork_PluginStart()
{
	SoundList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	SoundAlts = new StringMap();
	ExtraList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
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
	SendNextFile(client);
#endif
}

void FileNetwork_ClientDisconnect(int client)
{
	StartedQueue[client] = false;
	Downloading[client] = false;
	SoundLevel[client] = 0;
	ExtraLevel[client] = 0;
}

void FileNetwork_ConfigSetup(KeyValues map)
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "downloads");
	KeyValues kv = new KeyValues("Downloads");
	kv.ImportFromFile(buffer);

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
			RequestFrame(DeleteHandle, enabled);
		}
		else
		{
			enabled = kv;
			enabled.JumpToKey("Default");
		}
	}

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

	delete list;
	delete kv;
}

void PrecacheSoundCustom(const char[] sound, const char[] altsound = "", int delay = 5)
{
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
	DataPack pack = new DataPack();
	pack.WriteString(sound);
	RequestFrames(FileNetwork_AddSoundFrame, delay, pack);
#endif
}

public void FileNetwork_AddSoundFrame(DataPack pack)
{
	pack.Reset();

	char buffer[PLATFORM_MAX_PATH];
	pack.ReadString(buffer, sizeof(buffer));

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

	if(SoundLevel[client] < SoundList.Length)
	{
		SoundList.GetString(SoundLevel[client], download, sizeof(download));
		Format(download, sizeof(download), "sound/%s", download[download[0] == '#' ? 1 : 0]);
		
		pack = new DataPack();
		pack.WriteCell(false);	// Is a sound
	}
	else if(ExtraLevel[client] < ExtraList.Length)
	{
		ExtraList.GetString(ExtraLevel[client], download, sizeof(download));

		pack = new DataPack();
		pack.WriteCell(true);	// Is an extra
	}

	if(pack)
	{
		Downloading[client] = true;

		pack.WriteString(download);
		
		static char filecheck[PLATFORM_MAX_PATH];
		FormatFileCheck(download, client, filecheck, sizeof(filecheck));
#if !defined UseDownloadTable
		FileNet_RequestFile(client, filecheck, FileNetwork_RequestResults, pack);
#endif
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
			if(!DeleteFile(filecheck))
				LogError("Failed to delete file \"%s\"", file);
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
			}

			SendNextFile(client);
		}
		else
		{
#if !defined UseDownloadTable
			// So the client doesn't freak out about existing CreateFragmentsFromFile spam
			PrintToConsole(client, "[ZR/RPG] Downloading '%s'", download);
			if(FileNet_SendFile(client, download, FileNetwork_SendResults, pack))
				return;
			
			LogError("Failed to queue file \"%s\" to client", download);
#endif
		}
	}

	delete pack;
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
			filec.WriteLine("Used for file checks for ZR/RPG");
			filec.Close();
#if !defined UseDownloadTable
			if(!FileNet_SendFile(client, filecheck, FileNetwork_SendFileCheck))
			{
				LogError("Failed to queue file \"%s\" to client", filecheck);
				if(!DeleteFile(filecheck))
					LogError("Failed to delete file \"%s\"", filecheck);
			}
#endif
			pack.Reset();
			if(pack.ReadCell())
			{
				ExtraLevel[client]++;
			}
			else
			{
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
	
	if(!DeleteFile(file))
		LogError("Failed to delete file \"%s\"", file);
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
	if(soundlevel == -1)
		ThrowError("\"%s\" is not precached with PrecacheSoundCustom", sound);
	
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
	
	static char buffer[PLATFORM_MAX_PATH];
	if(!SoundAlts.GetString(sound, buffer, sizeof(buffer)))
		return false;
	
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