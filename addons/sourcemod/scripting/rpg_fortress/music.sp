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

void Music_PlayerRunCmd(int client)
{
	if(CurrentSong[client][0] || NextSong[client][0])
	{
		bool wasInFade;
		static MusicEnum music;
		if(FadingOut[client])
		{
			if(MusicList.GetArray(CurrentSong[client], music, sizeof(music)))
			{
				float vol = music.Volume - ((GetGameTime() - FadingOut[client]) / 2.0);
				if(vol > 0.0)
				{
					PrintToChat(client, "Volume: %f", vol);
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, vol);
					return;
				}

				PrintToChat(client, "Ended");
				StopSound(client, SNDCHAN_STATIC, music.Sound);
				StopSound(client, SNDCHAN_STATIC, music.Sound);
			}
			
			CurrentSong[client][0] = 0;
			FadingOut[client] = 0.0;
			wasInFade = true;
		}

		if(FadingIn[client])
		{
			if(MusicList.GetArray(CurrentSong[client], music, sizeof(music)))
			{
				float vol = ((GetGameTime() - FadingIn[client]) / 2.0);
				if(vol < music.Volume)
				{
					PrintToChat(client, "Volume: %f", vol);
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, vol);
					return;
				}

				PrintToChat(client, "Ended");
				EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, music.Volume);
			}
			
			FadingIn[client] = 0.0;
		}
		
		int time = GetTime();
		if(wasInFade)
		{
			if(MusicList.GetArray(NextSong[client], music, sizeof(music)) && music.Sound[0])
			{
				if(wasInFade)
				{
					PrintToChat(client, "Started Fade");
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 0.00001);
					FadingIn[client] = GetGameTime();
				}
				else
				{
					PrintToChat(client, "Started New");
					EmitSoundToClient(client, music.Sound, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, music.Volume);
				}
				
				NextSoundIn[client] = time + music.Duration;
				strcopy(CurrentSong[client], sizeof(CurrentSong[]), NextSong[client]);
			}
			else
			{
				NextSong[client][0] = 0;
			}
			return;
		}

		if(NextSoundIn[client] < time)
		{
			FadingOut[client] = 1.0;
			NextSoundIn[client] = 0;
		}
	}
}