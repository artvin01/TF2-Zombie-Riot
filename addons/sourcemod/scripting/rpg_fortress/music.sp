#pragma semicolon 1
#pragma newdecls required

enum struct MusicEnum
{
	char Sound[PLATFORM_MAX_PATH];
	int Duration;
	float Volume;

	void SetupEnum(KeyValues kv)
	{
		kv.GetString("sound", this.Sound, PLATFORM_MAX_PATH);
		if(this.Sound[0])
			PrecacheSound(this.Sound);
		
		this.Duration = kv.GetNum("duration");
		this.Volume = kv.GetFloat("volume", 1.0);
		
		if(kv.GetNum("download"))
		{
			char buffer[PLATFORM_MAX_PATH];
			Format(buffer, sizeof(buffer), "sound/%s", this.Sound);
			ReplaceString(buffer, sizeof(buffer), "#", "");
			if(FileExists(buffer, true))
			{
				AddFileToDownloadsTable(buffer);
			}
			else
			{
				LogError("'%s' is missing from files", buffer);
			}
		}
	}
}

static StringMap MusicList;
static char CurrentSong[MAXTF2PLAYERS][64];
static char NextSong[MAXTF2PLAYERS][64];
static int NextSoundIn[MAXTF2PLAYERS];
static float FadingOut[MAXTF2PLAYERS];
static float FadingIn[MAXTF2PLAYERS];
static char OverrideSong[MAXTF2PLAYERS][PLATFORM_MAX_PATH];
static int OverrideTime[MAXTF2PLAYERS];
static float OverrideVolume[MAXTF2PLAYERS];

void Music_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Music"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "music");
		kv = new KeyValues("Music");
		kv.ImportFromFile(buffer);
	}

	delete MusicList;
	MusicList = new StringMap();

	MusicEnum music;

	if(kv.GotoFirstSubKey())
	{
		do
		{
			kv.GetSectionName(buffer, sizeof(buffer));
			music.SetupEnum(kv);
			MusicList.SetArray(buffer, music, sizeof(music));
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
}

void Music_ZoneEnter(int client, const char[] name)
{
	if(MusicList)
	{
		static MusicEnum newSong;
		if(MusicList.GetArray(name, newSong, sizeof(newSong)))
		{
			if(CurrentSong[client][0])
			{
				static MusicEnum oldSong;
				if(MusicList.GetArray(CurrentSong[client], oldSong, sizeof(oldSong)) && oldSong.Sound[0])
				{
					if(StrEqual(oldSong.Sound, newSong.Sound))
						return;
					
					//StopSound(client, SNDCHAN_STATIC, oldSong.Sound);
					//StopSound(client, SNDCHAN_STATIC, oldSong.Sound);
					//EmitSoundToClient(client, oldSong.Sound, client, SNDCHAN_AUTO, SNDLEVEL_NONE, SND_CHANGEVOL, 0.0001);
					
					//FadingOut[client] = GetGameTime();
				}
			}

			FadingOut[client] = GetGameTime();
			NextSoundIn[client] = 0;
			strcopy(NextSong[client], sizeof(NextSong[]), name);
		}
	}
}

void Music_ClientDisconnect(int client)
{
	CurrentSong[client][0] = 0;
	NextSong[client][0] = 0;
	OverrideSong[client][0] = 0;
}

void Music_SetOverride(int client, const char[] file = "", int time = 0, float volume = 1.0)
{
	FadingOut[client] = GetGameTime();
	NextSoundIn[client] = 0;

	if(OverrideSong[client][0])
	{
		StopSound(client, SNDCHAN_STATIC, OverrideSong[client]);
		StopSound(client, SNDCHAN_STATIC, OverrideSong[client]);
	}

	strcopy(OverrideSong[client], sizeof(OverrideSong[]), file);
	OverrideTime[client] = time;
	OverrideVolume[client] = volume;
}

void Music_PlayerRunCmd(int client)
{
	if(CurrentSong[client][0] || NextSong[client][0] || OverrideSong[client][0])
	{
		bool wasInFade;
		static MusicEnum music;
		if(FadingOut[client])
		{
			if(CurrentSong[client][0])
			{
				if(MusicList.GetArray(CurrentSong[client], music, sizeof(music)))
				{
					float vol = music.Volume - ((GetGameTime() - FadingOut[client]) / 2.0);
					if(vol > 0.0)
					{
						EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, vol);
						return;
					}

					StopSound(client, SNDCHAN_STATIC, music.Sound);
					StopSound(client, SNDCHAN_STATIC, music.Sound);
				}
			
				CurrentSong[client][0] = 0;
			}
			
			FadingOut[client] = 0.0;
			wasInFade = true;
		}

		if(FadingIn[client])
		{
			if(CurrentSong[client][0] && MusicList.GetArray(CurrentSong[client], music, sizeof(music)))
			{
				float vol = ((GetGameTime() - FadingIn[client]) / 2.0);
				if(vol < music.Volume)
				{
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, vol);
					return;
				}

				EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, music.Volume);
			}
			
			FadingIn[client] = 0.0;
		}
		
		int time = GetTime();
		if(wasInFade)
		{
			if(OverrideSong[client][0])
			{
				EmitSoundToClient(client, OverrideSong[client], client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, OverrideVolume[client]);
				NextSoundIn[client] = time + OverrideTime[client];
				CurrentSong[client][0] = 0;
			}
			else if(NextSong[client][0])
			{
				if(MusicList.GetArray(NextSong[client], music, sizeof(music)) && music.Sound[0])
				{
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.00001);
					FadingIn[client] = GetGameTime();
					
					NextSoundIn[client] = time + music.Duration;
					strcopy(CurrentSong[client], sizeof(CurrentSong[]), NextSong[client]);
				}
				else
				{
					NextSong[client][0] = 0;
				}
			}
			return;
		}

		if(NextSoundIn[client] < time)
		{
			NextSoundIn[client] = 0;

			if(OverrideSong[client][0])
			{
				EmitSoundToClient(client, OverrideSong[client], client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, OverrideVolume[client]);
				NextSoundIn[client] = time + OverrideTime[client];
				CurrentSong[client][0] = 0;
			}
			else if(CurrentSong[client][0])
			{
				if(MusicList.GetArray(CurrentSong[client], music, sizeof(music)) && music.Sound[0])
				{
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, music.Volume);
					NextSoundIn[client] = time + music.Duration;
				}
			}
		}
	}
}