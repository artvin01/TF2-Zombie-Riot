#pragma semicolon 1
#pragma newdecls required

static ArrayList SoundList;
static StringMap SoundAlts;
static int SoundLevel[MAXTF2PLAYERS];
static bool Downloading[MAXTF2PLAYERS];

void FileNetwork_PluginStart()
{
	SoundList = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	SoundAlts = new StringMap();
}

void FileNetwork_MapEnd()
{
	Zero(SoundLevel);
	delete SoundList;
	delete SoundAlts;
	FileNetwork_PluginStart();
}

void FileNetwork_ClientPutInServer(int client)
{
	FileNetwork_ClientDisconnect(client);
	SendNextFile(client);
}

void FileNetwork_ClientDisconnect(int client)
{
	Downloading[client] = false;
	SoundLevel[client] = 0;
}

void PrecacheSoundCustom(const char[] sound, const char[] altsound = "", int delay = 5)
{
	PrecacheSound(sound);
	if(altsound[0])
	{
		PrecacheSound(altsound);
		SoundAlts.SetString(sound, altsound);
	}

	DataPack pack = new DataPack();
	pack.WriteString(sound);
	RequestFrames(FileNetwork_AddSoundFrame, delay, pack);
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
		for(int client = 1; client <= MaxClients; client++)
		{
			if(SoundLevel[client] && !Downloading[client])
			{
				SoundLevel[client]--;
				SendNextFile(client);
			}
		}
	}
}

static void FormatFileCheck(const char[] file, int client, char[] output, int length)
{
	strcopy(output, length, file);
	ReplaceString(output, length, ".", "");
	Format(output, length, "%s_%d.txt", output, GetSteamAccountID(client));
}

static void SendNextFile(int client)
{
	// First, request a dummy file to see if they have it downloaded before
	if(SoundLevel[client] < SoundList.Length)
	{
		Downloading[client] = true;
		
		static char sound[PLATFORM_MAX_PATH];
		SoundList.GetString(SoundLevel[client], sound, sizeof(sound));
		Format(sound, sizeof(sound), "sound/%s", sound[sound[0] == '#' ? 1 : 0]);

		static char filecheck[PLATFORM_MAX_PATH];
		FormatFileCheck(sound, client, filecheck, sizeof(filecheck));
		
		DataPack pack = new DataPack();
		pack.WriteString(sound);
		FileNet_RequestFile(client, filecheck, FileNetwork_RequestResults, pack);
	}
	else
	{
		Downloading[client] = false;

		PrintToConsole(client, "---");
		PrintToConsole(client, "[ZR/RPG] Finished Downloading/Verifying Files! You will hear and see everything as intended now.");
		PrintToConsole(client, "---");
	}
	
	SoundLevel[client]++;
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

	if(SoundLevel[client])
	{
		if(success)
		{
			SendNextFile(client);
		}
		else
		{
			static char sound[PLATFORM_MAX_PATH];
			pack.Reset();
			pack.ReadString(sound, sizeof(sound));

			// So the client doesn't freak out about existing CreateFragmentsFromFile spam
			PrintToConsole(client, "[ZR/RPG] Downloading '%s'", sound);

			if(!FileNet_SendFile(client, sound, FileNetwork_SendResults))
				LogError("Failed to queue file \"%s\" to client", sound);
		}
	}

	delete pack;
}

public void FileNetwork_SendResults(int client, const char[] file, bool success)
{
	// When done, send a dummy file and the next file in queue
	if(SoundLevel[client])
	{
		if(success)
		{
			static char filecheck[PLATFORM_MAX_PATH];
			FormatFileCheck(file, client, filecheck, sizeof(filecheck));

			File filec = OpenFile(filecheck, "wt");
			filec.WriteLine("Used for file checks for ZR/RPG");
			filec.Close();

			if(!FileNet_SendFile(client, filecheck, FileNetwork_SendFileCheck))
			{
				LogError("Failed to queue file \"%s\" to client", filecheck);
				if(!DeleteFile(filecheck))
					LogError("Failed to delete file \"%s\"", filecheck);
			}

			SendNextFile(client);
		}
		else
		{
			LogError("Failed to send file \"%s\" to client", file);
		}
	}
}

public void FileNetwork_SendFileCheck(int client, const char[] file, bool success)
{
	// Delete the dummy file left over
	if(SoundLevel[client] && !success)
		LogError("Failed to send file \"%s\" to client", file);
	
	if(!DeleteFile(file))
		LogError("Failed to delete file \"%s\"", file);
}

stock bool EmitCustomToClient(int client, const char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3]=NULL_VECTOR, const float dir[3]=NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
{
	int soundlevel = SoundList.FindString(sound) + 1;
	if(soundlevel == 0)
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
	int soundlevel = SoundList.FindString(sound) + 1;
	if(soundlevel == 0)
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
}