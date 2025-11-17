#pragma semicolon 1
#pragma newdecls required

static int MusicTypeActive[MAXPLAYERS];

enum struct InterMusicEnum
{
	char Path[PLATFORM_MAX_PATH];
	Function Func;
	
	void AddKv(KeyValues kv, int download)
	{
		kv.GetSectionName(this.Path, sizeof(this.Path));
		this.Func = KvGetFunction(kv, NULL_STRING);

		if(download)
		{
			PrecacheSoundCustom(this.Path, _, download);
		}
		else
		{
			PrecacheSound(this.Path);
		}
	}

	float GetVolume(int client, float multi)
	{
		float volume = 1.0;

		if(this.Func != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.Func);
			Call_PushCell(client);
			Call_Finish(volume);
		}

		volume *= multi;
		if(volume < 0.01)
			volume = 0.01;
		
		return volume;
	}
}

enum struct MusicEnum
{
	char Path[PLATFORM_MAX_PATH];
	int Time;
	float Volume;
	bool Custom;
	char Name[64];
	char Artist[64];
	ArrayList Parts;

	bool SetupKv(const char[] key, KeyValues kv)
	{
		this.Clear();

		if(kv.JumpToKey(key))
		{
			kv.GetString("file", this.Path, sizeof(this.Path));
			kv.GetString("name", this.Name, sizeof(this.Name));
			kv.GetString("author", this.Artist, sizeof(this.Artist));
			this.Time = kv.GetNum("time");
			this.Volume = kv.GetFloat("volume", 2.0);
			int download = kv.GetNum("download");
			this.Custom = view_as<bool>(download);

			if(this.Path[0])
			{
				if(this.Custom)
				{
					PrecacheSoundCustom(this.Path, _, download);
				}
				else
				{
					PrecacheSound(this.Path);
				}
			}

			if(kv.JumpToKey("interactive"))
			{
				// If how intermusic is done, doesn't support multi-sound
				if(this.Volume > 1.0)
					this.Volume = 1.0;
				
				if(kv.GotoFirstSubKey(false))
				{
					InterMusicEnum part;
					this.Parts = new ArrayList(sizeof(InterMusicEnum));

					do
					{
						part.AddKv(kv, download);
						this.Parts.PushArray(part);
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();
				}

				kv.GoBack();
			}

			kv.GoBack();
			return true;
		}

		return false;
	}

	bool PlayMusic(int client)
	{
		if(!this.Valid())
			return false;
		
		if(this.Parts)
		{
			InterMusicEnum part;
			int length = this.Parts.Length;
			bool failed;

			if(this.Custom)
			{
				if(this.Path[0])
					failed = !HasCustomSound(client, this.Path);
				
				if(!failed)
				{
					for(int i; i < length; i++)
					{
						this.Parts.GetArray(i, part);
						if(!HasCustomSound(client, this.Path))
						{
							failed = true;
							break;
						}
					}
				}
			}

			if(failed)
			{
				SetMusicTimer(client, GetTime() + 10);
				return false;
			}
			
			for(int i; i < length; i++)
			{
				this.Parts.GetArray(i, part);
				EmitSoundToClient(client, part.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, part.GetVolume(client, this.Volume));
			}
		}

		if(this.Path[0])
		{
			if(this.Custom)
			{
				if(!EmitCustomToClient(client, this.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, this.Volume))
				{
					SetMusicTimer(client, GetTime() + 3);
					return false;
				}
			}
			else
			{
				EmitSoundToClient(client, this.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, this.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			}
		}

		SetMusicTimer(client, GetTime() + this.Time);

		if(this.Name[0] || this.Artist[0])
			CPrintToChat(client, "%t", "Now Playing Song", this.Name, this.Artist);
		
		return true;
	}

	void StopMusic(int client)
	{
		MusicTypeActive[client] = 0;

		if(this.Path[0])
		{
			if(this.Custom)
			{
				StopCustomSound(client, SNDCHAN_STATIC, this.Path, this.Volume);
			}
			else
			{
				StopSound(client, SNDCHAN_STATIC, this.Path);
				StopSound(client, SNDCHAN_STATIC, this.Path);
				StopSound(client, SNDCHAN_STATIC, this.Path);
				StopSound(client, SNDCHAN_STATIC, this.Path);
			}
		}

		if(this.Parts)
		{
			InterMusicEnum part;
			int length = this.Parts.Length;
			for(int i; i < length; i++)
			{
				this.Parts.GetArray(i, part);

				if(this.Custom)
				{
					StopCustomSound(client, SNDCHAN_STATIC, part.Path);
				}
				else
				{
					StopSound(client, SNDCHAN_STATIC, part.Path);
				}
			}
		}
	}

	void Update(int client)
	{
		if(this.Parts)
		{
			InterMusicEnum part;
			int length = this.Parts.Length;
			for(int i; i < length; i++)
			{
				this.Parts.GetArray(i, part);

				EmitSoundToClient(client, part.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, part.GetVolume(client, this.Volume));
			}
		}
	}

	void CopyTo(MusicEnum music)
	{
		music.Clear();
		music = this;

		if(this.Parts)
			music.Parts = this.Parts.Clone();
	}

	bool Valid()
	{
		return this.Path[0] || this.Parts;
	}

	void Clear()
	{
		this.Path[0] = 0;
		this.Volume = 2.0;
		this.Custom = false;
		this.Name[0] = 0;
		this.Artist[0] = 0;
		delete this.Parts;
	}
}

static int Music_Timer[MAXPLAYERS];
static int Music_Timer_Update[MAXPLAYERS];
static float Give_Cond_Timer[MAXPLAYERS];
static bool MusicDisabled;
static bool XenoMapExtra;
static bool AltExtraLogic;
static int MusicMapRemove[MAXPLAYERS];
static float DelayStopSoundAll[MAXPLAYERS];

#define RANGE_FIRST_MUSIC 2250000.0
#define RANGE_SECOND_MUSIC 422500.0

/*
Big thanks to backwards#8236 For pointing me towards GetTime and helping me with this music tgimer,
DO NOT USE GetEngineTime, its not good in this case
*/
stock void Music_SetRaidMusic(const MusicEnum music, bool StopMusic = true, bool ForceMusicOnly = false)
{
	if(BlockOtherRaidMusic)
		return;

	if(ForceMusicOnly)
		BlockOtherRaidMusic = true;

	if(StopMusic)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				Music_Stop_All(client); //This is actually more expensive then i thought.
				SetMusicTimer(client, GetTime() + 2);
			}
		}
	}

	RaidMusicSpecial1.Clear();
	RaidMusicSpecial1 = music;
}

stock void Music_SetRaidMusicSimple(const char[] MusicPath, int duration, bool isCustom, float volume = 2.0)
{
	if(BlockOtherRaidMusic)
		return;

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client); //This is actually more expensive then i thought.
			SetMusicTimer(client, GetTime() + 2);
		}
	}
	RaidMusicSpecial1.Clear();
	RaidMusicSpecial1.Volume = volume;
	strcopy(RaidMusicSpecial1.Path, sizeof(RaidMusicSpecial1.Path), MusicPath);
	RaidMusicSpecial1.Time = duration;
	RaidMusicSpecial1.Custom = isCustom;

}

static const char g_LastMannAnnouncer[][] =
{
	"vo/announcer_am_lastmanalive01.mp3",
	"vo/announcer_am_lastmanalive02.mp3",
	"vo/announcer_am_lastmanalive03.mp3",
	"vo/announcer_am_lastmanalive04.mp3",
};

Action CommandBGTest(int client, int args)
{
	if(args)
	{
		char buffer[PLATFORM_MAX_PATH];
		GetCmdArgString(buffer, sizeof(buffer));
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, buffer);

		KeyValues kv = new KeyValues("");
		kv.ImportFromFile(buffer);

		if(SearchForMusic(kv))
		{
			ReplyToCommand(client, "Found music entry '%s'", BGMusicSpecial1.Path);
		}
		else
		{
			ReplyToCommand(client, "No music entry found in '%s'", buffer);
		}

		delete kv;
	}
	else if(BGMusicSpecial1.Valid())
	{
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i))
				BGMusicSpecial1.StopMusic(i);
		}
		
		BGMusicSpecial1.Clear();
		ReplyToCommand(client, "Cleared BGMusicSpecial1");
	}
	else
	{
		ReplyToCommand(client, "BGMusicSpecial1 is already empty");
	}
	return Plugin_Handled;
}

static bool SearchForMusic(KeyValues kv)
{
	if(BGMusicSpecial1.SetupKv("music", kv) || BGMusicSpecial1.SetupKv("music_1", kv) || BGMusicSpecial1.SetupKv("music_2", kv))
		return true;
	
	if(kv.GotoFirstSubKey())
	{
		do
		{
			if(SearchForMusic(kv))
				return true;
		}
		while(kv.GotoNextKey());

		kv.GoBack();
	}
	return false;
}

int g_iSoundEnts[MAXENTITIES];
int g_iNumSounds;
void PrecacheMusicZr()
{
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/1.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/2.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/3.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/4.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/5.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/6.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/7.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/8.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaulthuman/9.mp3",_,0);

	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/1.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/2.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/3.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/4.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/5.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/6.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/7.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/8.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/9.mp3",_,0);
	PrecacheSoundCustom("#zombiesurvival/beats/defaultzombiev2/10.mp3",_,0);
	
	PrecacheSoundCustom("#zombiesurvival/lasthuman.mp3",_,1);
	PrecacheSoundCustom("#zombiesurvival/music_lose.mp3",_,1);
	PrecacheSoundCustom("#zombiesurvival/music_win_1.mp3",_,1);
	PrecacheSoundCustom("#zombiesurvival/nilksongboss.mp3",_,5);

	MusicDisabled = FindInfoTarget("zr_nomusic");
	XenoMapExtra = FindInfoTarget("zr_xeno_extras");
	AltExtraLogic = FindInfoTarget("zr_alternative_extras");
	DisableSpawnProtection = FindInfoTarget("zr_disablespawn_protection");
	DisableRandomSpawns = FindInfoTarget("zr_disable_randomspawn");
}

void Music_MapStart()
{
	Zero(DelayStopSoundAll);
	PrecacheSoundArray(g_LastMannAnnouncer);
	
	EventRoundStartMusicFilter();
	PrecacheMusicZr();
	PrecacheSound("#music/hl2_song23_suitsong3.mp3");
}

void EventRoundStartMusicFilter()
{
	char sSound[256];
	int entity;
	g_iNumSounds = 0;
	
	for(int client=1; client<=MaxClients; client++)
	{
		MusicMapRemove[client] = 2000000000;
	}
	while ((entity = FindEntityByClassname(entity, "ambient_generic")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
		
		if(StrContains(sSound, "#", true) != -1)
		{
			Zero(MusicMapRemove);
			g_iSoundEnts[g_iNumSounds++] = EntIndexToEntRef(entity);
		}
	}
	RequestFrames(StopMapMusicAll, 60);
}
void StopMapMusicAll()
{
	int entity;
	char sSound[256];
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && (b_IgnoreMapMusic[client] || !Database_IsCached(client)))
		{
			for (int i = 0; i < g_iNumSounds; i++)
			{
				entity = EntRefToEntIndex(g_iSoundEnts[i]);
				
				if (entity != INVALID_ENT_REFERENCE)
				{
					GetEntPropString(entity, Prop_Data, "m_iszSound", sSound, sizeof(sSound));
					Client_StopSound(client, entity, SNDCHAN_STATIC, sSound);
				}
			}
		}
	}
}

stock void Client_StopSound(int client, int entity, int channel, char[] name)
{
	EmitSoundToClient(client, name, entity, channel, SNDLEVEL_NONE, SND_STOP, 0.0, SNDPITCH_NORMAL, _, _, _, true);
}

bool Music_Disabled()
{
	return MusicDisabled;
}

bool XenoExtraLogic(bool NpcBuffing = false)
{
	if(!NpcBuffing)
		return XenoMapExtra;
	else
	{
		if(XenoMapExtra && (!StrContains(WhatDifficultySetting_Internal, "Xeno") || !StrContains(WhatDifficultySetting_Internal, "Silvester & Waldch")))
		{
			return true;
		}
	}
	return false;
}
bool FishExtraLogic(bool NpcBuffing = false)
{
	if(!NpcBuffing)
		return XenoMapExtra;
	else
	{
		if(XenoMapExtra && (!StrContains(WhatDifficultySetting_Internal, "Stella & Karlas")))
		{
			return true;
		}
	}
	return false;
}

bool AlternativeExtraLogic(bool NpcBuffing = false)
{
	if(!NpcBuffing)
		return AltExtraLogic;
	else
	{
		if(AltExtraLogic && (!StrContains(WhatDifficultySetting_Internal, "Alternative") || !StrContains(WhatDifficultySetting_Internal, "Blitzkrieg")))
		{
			return true;
		}
	}
	return false;
}

bool BlockLastmanMusicRaidboss(int client)
{
	if(RaidMusicSpecial1.Valid())
	{
		if(b_LastManDisable[client])
		{
			return true;
		}
	}
	return false;
}
void Music_EndLastmann(bool Reinforce=false)
{
	if(LastMann)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(!BlockLastmanMusicRaidboss(client))
				{
					switch(Yakuza_Lastman())
					{
						case 1:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/yakuza_lastman.mp3", 2.0);
						case 2:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/zealot_lastman_1.mp3", 2.0);
						case 3:
							StopCustomSound(client, SNDCHAN_STATIC, RAIDBOSS_TWIRL_THEME, 2.0);
						case 4:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3", 2.0);
						case 5:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/purnell_lastman.mp3", 2.0);
						case 6:
							StopSound(client, SNDCHAN_STATIC, "#music/hl2_song23_suitsong3.mp3");
						case 7:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/altwaves_and_blitzkrieg/music/blitzkrieg_ost.mp3", 2.0);
						case 8:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/flaggilant_lastman.mp3", 2.0);
						case 9:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/wave_music/bat_rglk2boss1.mp3", 2.0);
						case 11:
							StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/cheese_lastman.mp3", 2.0);
						case 12:
                            StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3", 2.0);
                        case 13:
                            StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/combinehell/escalationP2.mp3", 2.0);
                        case 14:
                            StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/internius/chaos_engineered_cyborg.mp3", 2.0);
					}
					SetMusicTimer(client, 0);
					MusicLastmann.StopMusic(client);
					StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3", 2.0);
					
				}

				SDKCall_SetSpeed(client);
				TF2_RemoveCondition(client, TFCond_DefenseBuffed);
				TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
				TF2_RemoveCondition(client, TFCond_RuneHaste);
				TF2_RemoveCondition(client, TFCond_CritCanteen);
				if(!Reinforce)
				{
					Armor_Charge[client] = 0;
					if(IsPlayerAlive(client))
						SetEntProp(client, Prop_Send, "m_iHealth", 50);
				}
				else DoOverlay(client, "", 2);
				
				//just incase.
				Attributes_Set(client, 442, 1.0);
			}
		}
		LastMann = false;
		Yakuza_Lastman(0);
	}
}

void PlayTeamDeadSound()
{
	int RandomInt = GetRandomInt(0,sizeof(g_LastMannAnnouncer)- 1);
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			EmitSoundToClient(client, g_LastMannAnnouncer[RandomInt], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
		}
	}	
}
void Music_RoundEnd(int victim, bool music = true)
{
	ExcuteRelay("zr_gamelost");
	//lastman fail. end music.
	Music_EndLastmann();
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			if(music)
				SetMusicTimer(client, GetTime() + 45);
			
			SDKCall_SetSpeed(client);
			TF2_RemoveCondition(client, TFCond_DefenseBuffed);
			TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
			TF2_RemoveCondition(client, TFCond_RuneHaste);
			TF2_RemoveCondition(client, TFCond_CritCanteen);
			Music_Stop_All(client);

			if(music)
				if(!MusicLoss.PlayMusic(client))
					EmitCustomToClient(client, "#zombiesurvival/music_lose.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			
			SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", victim);
		}
	}
	
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "1");
			Convars_FixClientsideIssues(i);
		}
	}
	ResetReplications();
	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);
	RemoveAllCustomMusic(true);
}

public Action SetTimeBack(Handle timer)
{
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "0");
			Convars_FixClientsideIssues(i);
		}
	}
	ResetReplications();
	cvarTimeScale.SetFloat(1.0);
	return Plugin_Handled;
}

void Music_Stop_All(int client)
{
//	LogStackTrace("stoppedmusic");
	if(DelayStopSoundAll[client] < GetGameTime())
	{
		//dont spam these
		DelayStopSoundAll[client] = GetGameTime() + 0.1;
 	//	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
		if(PrepareMusicVolume[client] == 1.0)
			PrepareMusicVolume[client] = 0.4;
		else if(PrepareMusicVolume[client]) //i.e. doing it rn
		{
			PrepareMusicVolume[client] = 0.0;
			StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
		}
		//stop music slowly.
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3", 2.0);
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/1.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/2.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/3.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/4.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/5.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/6.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/7.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/8.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/9.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/1.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/2.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/3.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/4.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/5.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/6.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/7.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/8.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/9.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/1.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/2.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/3.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/4.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/5.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/6.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/7.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/8.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/9.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/1.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/2.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/3.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/4.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/5.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/6.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/7.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/8.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/9.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/nilksongboss.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/nilksongboss.mp3");
	}
	//dont call so often! causes lag!
	
	MusicLastmann.StopMusic(client);
	MusicString1.StopMusic(client);
	MusicString2.StopMusic(client);
	RaidMusicSpecial1.StopMusic(client);
	BGMusicSpecial1.StopMusic(client);
}

void Music_Update(int client)
{
	if(LastMann_BeforeLastman && !LastMann)
	{
		if(Give_Cond_Timer[client] < GetGameTime())
		{
			TF2_AddCondition(client, TFCond_MarkedForDeath, 2.0);
			Give_Cond_Timer[client] = GetGameTime() + 1.0;
		}
	}
	if(LastMann && !b_IsAloneOnServer)
	{
		if(Give_Cond_Timer[client] < GetGameTime())
		{
			if(IsPlayerAlive(client))
			{
				if(TeutonType[client] == TEUTON_NONE)
				{
					TF2_AddCondition(client, TFCond_DefenseBuffed, 2.0);
					
					Give_Cond_Timer[client] = GetGameTime() + 1.0;
				}
			}
		}
	}

	if(MusicMapRemove[client] < GetTime())
	{
		StopMapMusicAll();
		MusicMapRemove[client] = GetTime() + 30;
	}
	
	if(MusicDisabled && !b_IgnoreMapMusic[client])
		return;
	
	if(!b_DisableSetupMusic[client] && f_ClientMusicVolume[client] < 0.05)
	{
		//	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
		if(PrepareMusicVolume[client] == 1.0)
			PrepareMusicVolume[client] = 0.4;

		if(PrepareMusicVolume[client] != 1.0 && PrepareMusicVolume[client])
		{
			PrepareMusicVolume[client] = 0.0;
			if(MusicSetup1.Valid())
			{
				MusicSetup1.StopMusic(client);
			}
			StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
			SetMusicTimer(client, GetTime() + 1);	
		}		
		return;
	}

 	//	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
	if(!b_DisableSetupMusic[client] && PrepareMusicVolume[client] != 1.0 && PrepareMusicVolume[client])
	{
		PrepareMusicVolume[client] -= 0.1;
		if(PrepareMusicVolume[client] <= 0.0)
		{
			if(MusicSetup1.Valid())
			{
				MusicSetup1.StopMusic(client);
			}
 			StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
		}
		else
		{
			if(MusicSetup1.Valid())
			{
				MusicSetup1.StopMusic(client);
 				StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3");
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, SND_CHANGEVOL, PrepareMusicVolume[client]);
			}
		}
	}
	//if in menu, dont play new music.
	//but dont kill old music either.
	if(SkillTree_InMenu(client))
		return;
	
	if(!b_GameOnGoing || CvarInfiniteCash.BoolValue)
	{
		return;
	}
	if(Waves_InSetup() && (!Waves_Started() || (!Rogue_Mode() && !Construction_Mode() && !BetWar_Mode())))
	{
		if(!b_DisableSetupMusic[client])
		{
			PlaySetupMusicCustom(client);
		}
		return;
	}
	
	if(Music_Timer_Update[client] > GetTime())
	{

	}
	else if(Music_Timer[client] > GetTime())
	{
		if(MusicTypeActive[client])
		{
			Music_Timer_Update[client] = GetTime() + 1;

			switch(MusicTypeActive[client])
			{
				case 1:
					MusicString1.Update(client);
				
				case 2:
					MusicString2.Update(client);
				
				case 3:
					RaidMusicSpecial1.Update(client);
				
				case 4:
					BGMusicSpecial1.Update(client);
			}
		}
	}
	else
	{
		if(!LastMann || (BlockLastmanMusicRaidboss(client) && LastMann))
		{
			if(RaidMusicSpecial1.PlayMusic(client))
			{
				MusicTypeActive[client] = 3;
				return;
			}
			
			if(GetURandomInt() % 2)
			{
				if(MusicString1.PlayMusic(client))
				{
					MusicTypeActive[client] = 1;
					return;
				}
				
				if(MusicString2.PlayMusic(client))
				{
					MusicTypeActive[client] = 2;
					return;
				}
			}
			else
			{
				if(MusicString2.PlayMusic(client))
				{
					MusicTypeActive[client] = 2;
					return;
				}
				
				if(MusicString1.PlayMusic(client))
				{
					MusicTypeActive[client] = 1;
					return;
				}
			}

			if(BGMusicSpecial1.PlayMusic(client))
			{
				MusicTypeActive[client] = 4;
				return;
			}
		}

		MusicTypeActive[client] = 0;

		// Player disabled ZR Music
		if(b_DisableDynamicMusic[client] && !LastMann)
		{
			SetMusicTimer(client, GetTime() + 3);
			return;
		}

		float f_intencity;
		float targPos[3];
		float chargerPos[3];
		GetClientAbsOrigin(client, chargerPos);
		float RangeFirstMusic = RANGE_FIRST_MUSIC;
		float RangeSecondMusic = RANGE_SECOND_MUSIC;
		if(Classic_Mode())
		{
			//in classic, it should only play if REALLY close.
			RangeFirstMusic *= 0.8;
			RangeSecondMusic *= 0.8;
		}
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) != TFTeam_Red)
			{
				if(i_IsNpcType[entity] == STATIONARY_NPC && b_StaticNPC[entity])
					continue;
				//if its a stationary static npc, then it by default means no harm.


				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
				float distance = GetVectorDistance(chargerPos, targPos, true);
				CClotBody npcstats = view_as<CClotBody>(entity);
				if (distance <= RangeFirstMusic) //Give way bigger range.
				{
					if(!npcstats.m_bThisNpcIsABoss)
					{
						f_intencity += 0.5;
					}
					else
					{
						f_intencity += 4.0;
					}
				}
				if (distance <= RangeSecondMusic)// If they are very close, cause more havok! more epic music!
				{
					if(!npcstats.m_bThisNpcIsABoss)
					{
						f_intencity += 0.65;
					}
					else
					{
						f_intencity += 5.0;
					}
				}
			}
		}
		
		if(!ZombieMusicPlayed)//once set in a wave, it should stay untill the next mass revive.
		{
			if(!b_IsAloneOnServer && float(GlobalIntencity) >= float(PlayersInGame) * 0.25)
			{
				ZombieMusicPlayed = true;
			}
		}
		
		if(LastMann && !BlockLastmanMusicRaidboss(client))
		{
			switch(Yakuza_Lastman())
			{
				case 1:
				{
					EmitCustomToClient(client, "#zombiesurvival/yakuza_lastman.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.15);
					SetMusicTimer(client, GetTime() + 163);		
				}
				case 2:
				{
					EmitCustomToClient(client, "#zombiesurvival/zealot_lastman_1.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.15);
					SetMusicTimer(client, GetTime() + 80);		
				}
				case 3:
				{
					EmitCustomToClient(client, RAIDBOSS_TWIRL_THEME,client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.2);
					SetMusicTimer(client, GetTime() + 190);
				}
				case 4:
				{
					EmitCustomToClient(client, "#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 187);
				}
				case 5:
				{
					EmitCustomToClient(client, "#zombiesurvival/purnell_lastman_1.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 192);
				}
				case 6:
				{
					EmitSoundToClient(client, "#music/hl2_song23_suitsong3.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 150);
				}
				case 7:
				{
					EmitCustomToClient(client, "#zombiesurvival/altwaves_and_blitzkrieg/music/blitzkrieg_ost.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 228);
				}
				case 8:
				{
					EmitCustomToClient(client, "#zombiesurvival/flaggilant_lastman.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 121);
				}
				case 9:
				{
					EmitCustomToClient(client, "#zombiesurvival/wave_music/bat_rglk2boss1.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 113);
				}
				case 11:
				{
					EmitCustomToClient(client, "#zombiesurvival/cheese_lastman.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 170);
				}
				/*
				case 12:
                {
                    EmitCustomToClient(client, "#zombiesurvival/expidonsa_waves/wave_45_music_1.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.2);
                    SetMusicTimer(client, GetTime() + 280);
                }
				*/
                case 13:
                {
                    EmitCustomToClient(client, "#zombiesurvival/combinehell/escalationP2.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.2);
                    SetMusicTimer(client, GetTime() + 147);
                }
                case 14:
                {
                    EmitCustomToClient(client, "#zombiesurvival/internius/chaos_engineered_cyborg.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.2);
                    SetMusicTimer(client, GetTime() + 183);
				}
				default:
				{	
					if(!MusicLastmann.PlayMusic(client))
					{
						EmitCustomToClient(client, "#zombiesurvival/lasthuman.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						SetMusicTimer(client, GetTime() + 120);	
					}
				}
			}
		}
		
		else if(view_as<bool>(Store_HasNamedItem(client, "Expidonsan Research Card")))
		{
			EmitCustomToClient(client, "#zombiesurvival/nilksongboss.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.2);
			SetMusicTimer(client, GetTime() + 100);
		}
		else if(f_intencity < 1.0)
		{
			SetMusicTimer(client, GetTime() + 8);
		}
		else if(!b_IsAloneOnServer && f_intencity < float(PlayersAliveScaling) * 0.1)
		{
			EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
			SetMusicTimer(client, GetTime() + 8);
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.2)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.3)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.4)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.5)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.6)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.7)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.8)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.9)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.5);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 14);
			}
		}
	}
}

public void SetMusicTimer(int client, int time)
{
	Music_Timer[client] = time /*- 1*/;
}

//CHECK SDKHOOKS PRETHINK!!!


void Music_ClearAll()
{
	Zero(Music_Timer);
	Zero(Music_Timer_Update);
	Zero(Give_Cond_Timer);
	Zero(f_ClientMusicVolume);
}

void RemoveAllCustomMusic(bool background = false)
{
	MusicString1.Clear();
	MusicString2.Clear();
	RaidMusicSpecial1.Clear();
	if(background)
		BGMusicSpecial1.Clear();
}

void PlaySetupMusicCustom(int client)
{
	if(Music_Timer[client] < GetTime() && Music_Timer_Update[client] < GetTime())
	{
		bool PlayedMusic = false;
		if(MusicSetup1.Valid())
		{
			PlayedMusic = MusicSetup1.PlayMusic(client);
			if(!PlayedMusic)
				SetMusicTimer(client, GetTime() + 1);
		}
		else
		{
			EmitSoundToClient(client, "#zombiesurvival/setup_music_extreme_z_battle_dokkan.mp3", client, SNDCHAN_STATIC, _, _, 0.4);
			SetMusicTimer(client, GetTime() + 173);
		}
		PrepareMusicVolume[client] = 1.0;
	}
}

public float InterMusic_ByIntencity(int client)
{
	if(LastMann || !PlayersAliveScaling)
		return 1.0;
	
	float f_intencity;
	float targPos[3];
	float chargerPos[3];
	GetClientAbsOrigin(client, chargerPos);
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) != TFTeam_Red)
		{
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
			float distance = GetVectorDistance(chargerPos, targPos, true);
			CClotBody npcstats = view_as<CClotBody>(entity);
			if (distance <= RANGE_FIRST_MUSIC) //Give way bigger range.
			{
				if(!npcstats.m_bThisNpcIsABoss)
				{
					f_intencity += 0.5;
				}
				else
				{
					f_intencity += 6.0;
				}
			}
			if (distance <= RANGE_SECOND_MUSIC)// If they are very close, cause more havok! more epic music!
			{
				if(!npcstats.m_bThisNpcIsABoss)
				{
					f_intencity += 0.9;
				}
				else
				{
					f_intencity += 8.0;
				}
			}
		}
	}

	float volume = f_intencity / float(PlayersAliveScaling);
	
	return fClamp(volume, 0.0, 1.0);
}

public float InterMusic_ByAlone(int client)
{
	if(LastMann)
		return 1.0;
	
	int alive, total;

	float targPos[3];
	float chargerPos[3];
	GetClientAbsOrigin(client, chargerPos);
	for(int target = 1; target <= MaxClients; target++)
	{
		if(target != client && IsClientInGame(target) && GetClientTeam(target) == 2)
		{
			total++;

			if(IsPlayerAlive(target) && TeutonType[target] == TEUTON_NONE)
			{
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", targPos);
				if(GetVectorDistance(chargerPos, targPos, true) < RANGE_FIRST_MUSIC)
					alive++;
			}
		}
	}

	if(!total)
		return 1.0;
	
	return 1.0 - (float(alive) / float(total));
}

public float InterMusic_ByDifficulty(int client)
{
	if(LastMann)
		return 1.0;
	
	float volume = Waves_GetRoundScale() / 50.0;
	return fClamp(volume, 0.0, 1.0);
}

public float InterMusic_ByRandom(int client)
{
	if(LastMann)
		return 1.0;
	
	float volume = abs((GetTime() % 500) - 250) / 250.0;
	return volume;
}

public float InterMusic_ByGreed(int client)
{
	if(LastMann)
		return 1.0;
	
	if(CurrentCash < 1)
		return 0.0;
	
	float maxCash = float(CurrentCash / 4);
	if(maxCash < 4000.0)
		maxCash = 4000.0;
	
	float volume = float(CurrentCash - CashSpent[client]) / maxCash;
	return fClamp(volume, 0.0, 1.0);
}
