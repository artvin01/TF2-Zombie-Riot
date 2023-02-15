#pragma semicolon 1
#pragma newdecls required

static ArrayList SoundList;
static StringMap SoundAlts;
static int SoundLevel[MAXTF2PLAYERS];

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
	SoundLevel[client] = 0;
}

void PrecacheSoundCustom(const char[] sound, const char[] altsound = "")
{
	PrecacheSound(sound);
	if(altsound[0])
	{
		PrecacheSound(altsound);
		SoundAlts.SetString(sound, altsound);
	}

	if(SoundList.FindString(sound) == -1)
		SoundList.PushString(sound);
}

public void FileNetwork_SendResults(int client, const char[] file, bool success)
{
	if(SoundLevel[client])
	{
		if(success)
		{
			SendNextFile(client);
		}
		else
		{
			LogError("Failed to send file \"%s\" to client", file);
		}
	}
}

static void SendNextFile(int client)
{
	if(SoundLevel[client] < SoundList.Length)
	{
		static char sound[PLATFORM_MAX_PATH];
		SoundList.GetString(SoundLevel[client], sound, sizeof(sound));
		Format(sound, sizeof(sound), "sound/%s", sound[sound[0] == '#' ? 1 : 0]);
		
		SoundLevel[client]++;
		
		if(!FileNet_SendFile(client, sound, FileNetwork_SendResults))
			LogError("Failed to queue file \"%s\" to client", sound);
	}
}

stock void EmitCustomToClient(int client, const char[] sound, int entity = SOUND_FROM_PLAYER, int channel = SNDCHAN_AUTO, int level = SNDLEVEL_NORMAL, int flags = SND_NOFLAGS, float volume = SNDVOL_NORMAL, int pitch = SNDPITCH_NORMAL, int speakerentity = -1, const float origin[3]=NULL_VECTOR, const float dir[3]=NULL_VECTOR, bool updatePos = true, float soundtime = 0.0)
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
	}
	else
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
				EmitSoundToClient(client, buffer, entity, channel, level, flags, volume2, pitch, speakerentity, origin, dir, updatePos, soundtime);
			}
		}
	}
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