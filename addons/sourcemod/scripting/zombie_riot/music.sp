#pragma semicolon 1
#pragma newdecls required

enum struct MusicEnum
{
	char Path[PLATFORM_MAX_PATH];
	int Time;
	float Volume;
	bool Custom;
	char Name[64];
	char Artist[64];

	bool SetupKv(const char[] key, KeyValues kv)
	{
		if(kv.JumpToKey(key))
		{
			kv.GetString("file", this.Path, sizeof(this.Path));
			kv.GetString("name", this.Name, sizeof(this.Name));
			kv.GetString("author", this.Artist, sizeof(this.Artist));
			this.Time = kv.GetNum("time");
			this.Volume = kv.GetFloat("volume", 2.0);
			int download = kv.GetNum("download");

			this.Custom = view_as<bool>(download);
			if(this.Custom)
			{
				PrecacheSoundCustom(this.Path, _, download);
			}
			else
			{
				PrecacheSound(this.Path);
			}

			kv.GoBack();
			return true;
		}
		
		this.Path[0] = 0;
		return false;
	}

	void Clear()
	{
		this.Path[0] = 0;
		this.Volume = 2.0;
		this.Custom = false;
		this.Name[0] = 0;
		this.Artist[0] = 0;
	}
}

static int Music_Timer[MAXTF2PLAYERS];
static int Music_Timer_2[MAXTF2PLAYERS];
static float Give_Cond_Timer[MAXTF2PLAYERS];
static bool MusicDisabled;
static bool XenoMapExtra;
static bool AltExtraLogic;
static int MusicMapRemove[MAXTF2PLAYERS];

static float DelayStopSoundAll[MAXTF2PLAYERS];

#define RANGE_FIRST_MUSIC 6250000
#define RANGE_SECOND_MUSIC 1000000

/*
Big thanks to backwards#8236 For pointing me towards GetTime and helping me with this music tgimer,
DO NOT USE GetEngineTime, its not good in this case
*/

stock void Music_SetRaidMusic(const MusicEnum music)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client); //This is actually more expensive then i thought.
			SetMusicTimer(client, GetTime() + 2);
		}
	}

	RaidMusicSpecial1 = music;
}

stock void Music_SetRaidMusicSimple(const char[] MusicPath, int duration, bool isCustom, float volume = 2.0)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client); //This is actually more expensive then i thought.
			SetMusicTimer(client, GetTime() + 3);
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

	MusicDisabled = FindInfoTarget("zr_nomusic");
	XenoMapExtra = FindInfoTarget("zr_xeno_extras");
	AltExtraLogic = FindInfoTarget("zr_alternative_extras");
	ForceNiko = FindInfoTarget("zr_niko");

	if(XenoMapExtra)
	{
		PrecacheSoundCustom("#zombie_riot/abandoned_lab/music/inside_lab.mp3",_,1);
		PrecacheSoundCustom("#zombie_riot/abandoned_lab/music/outside_wasteland.mp3",_,1);
	}
}
void Music_MapStart()
{
	Zero(DelayStopSoundAll);
	PrecacheSoundArray(g_LastMannAnnouncer);
	
	EventRoundStartMusicFilter();
	PrecacheMusicZr();
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
		if(XenoMapExtra && (!StrContains(WhatDifficultySetting_Internal, "Xeno") || !StrContains(WhatDifficultySetting_Internal, "Silvester & Goggles")))
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

void Music_EndLastmann()
{
	if(LastMann)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
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
				}

				SetMusicTimer(client, 0);
				StopCustomSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3", 2.0);
				SDKCall_SetSpeed(client);
				TF2_RemoveCondition(client, TFCond_DefenseBuffed);
				TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
				TF2_RemoveCondition(client, TFCond_RuneHaste);
				TF2_RemoveCondition(client, TFCond_CritCanteen);
				Armor_Charge[client] = 0;
				if(IsPlayerAlive(client))
					SetEntProp(client, Prop_Send, "m_iHealth", 50);
				
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
				EmitCustomToClient(client, "#zombiesurvival/music_lose.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			
			SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", victim);
		}
	}
	
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "1");
		}
	}
	ResetReplications();
	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);
	RemoveAllCustomMusic();
}

public Action SetTimeBack(Handle timer)
{
	for(int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendConVarValue(i, sv_cheats, "0");
		}
	}
	ResetReplications();
	cvarTimeScale.SetFloat(1.0);
	return Plugin_Handled;
}

void Music_Stop_All(int client)
{
	if(DelayStopSoundAll[client] < GetGameTime())
	{
		//dont spam these
		DelayStopSoundAll[client] = GetGameTime() + 0.1;
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
	}
	//dont call so often! causes lag!
	
	
	if(MusicString1.Path[0])
	{
		if(MusicString1.Custom)
		{
			StopCustomSound(client, SNDCHAN_STATIC, MusicString1.Path, 4.0);
		}
		else
		{
 			StopSound(client, SNDCHAN_STATIC, MusicString1.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString1.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString1.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString1.Path);
		}
	}
		
	if(MusicString2.Path[0])
	{
		if(MusicString1.Custom)
		{
			StopCustomSound(client, SNDCHAN_STATIC, MusicString2.Path, 4.0);

		}
		else
		{
 			StopSound(client, SNDCHAN_STATIC, MusicString2.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString2.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString2.Path);
 			StopSound(client, SNDCHAN_STATIC, MusicString2.Path);
		}
	}

	if(RaidMusicSpecial1.Path[0])
	{
		if(RaidMusicSpecial1.Custom)
		{
			StopCustomSound(client, SNDCHAN_STATIC, RaidMusicSpecial1.Path, 4.0);
		}
		else
		{
 			StopSound(client, SNDCHAN_STATIC, RaidMusicSpecial1.Path);
 			StopSound(client, SNDCHAN_STATIC, RaidMusicSpecial1.Path);
 			StopSound(client, SNDCHAN_STATIC, RaidMusicSpecial1.Path);
 			StopSound(client, SNDCHAN_STATIC, RaidMusicSpecial1.Path);
		}
	}

	if(XenoExtraLogic())
	{
		StopCustomSound(client, SNDCHAN_STATIC, "#zombie_riot/abandoned_lab/music/inside_lab.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombie_riot/abandoned_lab/music/outside_wasteland.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombie_riot/abandoned_lab/music/inside_lab.mp3");
		StopCustomSound(client, SNDCHAN_STATIC, "#zombie_riot/abandoned_lab/music/outside_wasteland.mp3");
	}
}

void Music_PostThink(int client)
{
	if(LastMann_BeforeLastman && !LastMann)
	{
		if(Give_Cond_Timer[client] < GetGameTime())
		{
			TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 2.0);
			Give_Cond_Timer[client] = GetGameTime() + 1.0;
		}
	}
	if(LastMann)
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
		/*
		if(TeutonType[client] == TEUTON_NONE)
		{
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 250.0);
		}
		*/
	}

	if(MusicMapRemove[client] < GetTime())
	{
		StopMapMusicAll();
		MusicMapRemove[client] = GetTime() + 30;
	}
	
	if(MusicDisabled && !b_IgnoreMapMusic[client])
		return;
	
	if(!b_GameOnGoing)
		return;
	
	if(f_ClientMusicVolume[client] < 0.05)
		return;

	//if in menu, dont play new music.
	//but dont kill old music either.
	if(SkillTree_InMenu(client))
		return;

	if(Music_Timer[client] < GetTime() && Music_Timer_2[client] < GetTime())
	{
		bool RoundHasCustomMusic = false;
		
		if(MusicString1.Path[0])
			RoundHasCustomMusic = true;
			
		if(MusicString2.Path[0])
			RoundHasCustomMusic = true;

		if(RaidMusicSpecial1.Path[0])
			RoundHasCustomMusic = true;
		
		if(LastMann)
		{
			RoundHasCustomMusic = false;
		}
		
		if(RoundHasCustomMusic)
		{
			if(RaidMusicSpecial1.Path[0])
			{
				if(RaidMusicSpecial1.Custom)
				{
					EmitCustomToClient(client, RaidMusicSpecial1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, RaidMusicSpecial1.Volume);
				}
				else
				{
					EmitSoundToClient(client, RaidMusicSpecial1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					EmitSoundToClient(client, RaidMusicSpecial1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				}
				SetMusicTimer(client, GetTime() + RaidMusicSpecial1.Time);

				if(RaidMusicSpecial1.Name[0] || RaidMusicSpecial1.Artist[0])
					CPrintToChat(client, "%t", "Now Playing Song", RaidMusicSpecial1.Artist, RaidMusicSpecial1.Name);
				
				return;
			}
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					if(MusicString1.Path[0])
					{
						if(MusicString1.Custom)
						{
							EmitCustomToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, MusicString1.Volume);
						}
						else
						{
							EmitSoundToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}

						if(MusicString1.Name[0] || MusicString1.Artist[0])
							CPrintToChat(client ,"%t", "Now Playing Song", MusicString1.Artist, MusicString1.Name);
						
						SetMusicTimer(client, GetTime() + MusicString1.Time);
					}
					else if(MusicString2.Path[0])
					{
						if(MusicString2.Custom)
						{
							EmitCustomToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, MusicString2.Volume);
						}
						else
						{
							EmitSoundToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}

						if(MusicString2.Name[0] || MusicString2.Artist[0])
							CPrintToChat(client ,"%t", "Now Playing Song", MusicString2.Artist, MusicString2.Name);
						
						SetMusicTimer(client, GetTime() + MusicString2.Time);				
					}
					//Make checks to be sure.
				}
				case 2:
				{
					if(MusicString2.Path[0])
					{
						if(MusicString2.Custom)
						{
							EmitCustomToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, MusicString2.Volume);
						}
						else
						{
							EmitSoundToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, MusicString2.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}

						if(MusicString2.Name[0] || MusicString2.Artist[0])
							CPrintToChat(client ,"%t", "Now Playing Song", MusicString2.Artist, MusicString2.Name);

						SetMusicTimer(client, GetTime() + MusicString2.Time);
					}
					else if(MusicString1.Path[0])
					{
						if(MusicString1.Custom)
						{
							EmitCustomToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, MusicString1.Volume);
						}
						else
						{
							EmitSoundToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, MusicString1.Path, client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}

						if(MusicString1.Name[0] || MusicString1.Artist[0])
							CPrintToChat(client ,"%t", "Now Playing Song", MusicString1.Artist, MusicString1.Name);
						
						SetMusicTimer(client, GetTime() + MusicString1.Time);				
					}
					//Make checks to be sure.
				}
			}
			return;
		}

		if(XenoExtraLogic() && !LastMann)
		{
			//This is special code for a map.
			if(CurrentRound +1 <= 30)
			{
				EmitCustomToClient(client, "#zombie_riot/abandoned_lab/music/outside_wasteland.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 138);	
			}
			else
			{
				EmitCustomToClient(client, "#zombie_riot/abandoned_lab/music/inside_lab.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.45);
				SetMusicTimer(client, GetTime() + 151);	
			}
			return;
		}
		// Player disabled ZR Music
		if(b_DisableDynamicMusic[client] && !LastMann)
			return;

		float f_intencity;
		float targPos[3];
		float chargerPos[3];
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity] && GetTeam(entity) != TFTeam_Red)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
				GetClientAbsOrigin(client, chargerPos);
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
		/*
		//TODO: move somewhere else
		if(RaidbossIgnoreBuildingsLogic())
		{
			//if they arent on red, do this.
			if(GetTeam(EntRefToEntIndex(RaidBossActive)) == TFTeam_Red)
			{
				//thes are on red, set this.
				RaidAllowsBuildings = true;
			}
		}
		*/
		
		if(!ZombieMusicPlayed)//once set in a wave, it should stay untill the next mass revive.
		{
			if(!b_IsAloneOnServer && float(GlobalIntencity) >= float(PlayersInGame) * 0.25)
			{
				ZombieMusicPlayed = true;
			}
		}
		
		if(LastMann)
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
					EmitCustomToClient(client, RAIDBOSS_TWIRL_THEME,client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 285);
				}
				case 4:
				{
					EmitCustomToClient(client, "#zombiesurvival/expidonsa_waves/wave_30_soldine.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 187);
				}
				case 5:
				{
					EmitCustomToClient(client, "#zombiesurvival/purnell_lastman.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
					SetMusicTimer(client, GetTime() + 192);
				}
				default:
				{	
					EmitCustomToClient(client, "#zombiesurvival/lasthuman.mp3",client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					SetMusicTimer(client, GetTime() + 120);	
				}
			}
		}
		else if(f_intencity < 1.0)
		{
			SetMusicTimer(client, GetTime() + 8);
		}
		else if(!b_IsAloneOnServer && f_intencity < float(PlayersAliveScaling) * 0.1)
		{
			EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", client, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
			SetMusicTimer(client, GetTime() + 6);
			
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
				SetMusicTimer(client, GetTime() + 6);
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
	Music_Timer[client] = time -1;
	Music_Timer_2[client] = time -1;
}

//CHECK SDKHOOKS PRETHINK!!!


void Music_ClearAll()
{
	Zero(Music_Timer);
	Zero(Music_Timer_2);
	Zero(Give_Cond_Timer);
	Zero(f_ClientMusicVolume);
}

void RemoveAllCustomMusic()
{
	MusicString1.Clear();
	MusicString2.Clear();
	RaidMusicSpecial1.Clear();
}