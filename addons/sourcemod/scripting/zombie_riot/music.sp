static int Music_Timer[MAXTF2PLAYERS];
static int Music_Timer_2[MAXTF2PLAYERS];
static float Give_Cond_Timer[MAXTF2PLAYERS];
static bool MusicDisabled;


/*
Big thanks to backwards#8236 For pointing me towards GetTime and helping me with this music tgimer,
DO NOT USE GetEngineTime, its not good in this case
*/

void Music_MapStart()
{
	MusicDisabled = FindInfoTarget("zr_nomusic");
	if(MusicDisabled)
		return;

	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/1.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/2.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/3.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/4.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/5.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/6.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/7.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/8.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/9.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaultzombiev2/10.mp3", true);
	
	PrecacheSound("#zombiesurvival/beats/defaulthuman/1.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/2.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/3.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/4.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/5.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/6.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/7.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/8.mp3", true);
	PrecacheSound("#zombiesurvival/beats/defaulthuman/9.mp3", true);
	
	PrecacheSound("#zombiesurvival/lasthuman.mp3", true);
	PrecacheSound("#zombiesurvival/music_lose.mp3", true);
	PrecacheSound("#zombiesurvival/music_win.mp3", true);
	
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/1.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/2.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/3.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/4.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/5.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/6.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/7.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/8.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/9.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaultzombiev2/10.mp3");
	
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/1.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/2.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/3.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/4.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/5.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/6.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/7.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/8.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/beats/defaulthuman/9.mp3");
	
	AddFileToDownloadsTable("sound/zombiesurvival/lasthuman.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/music_lose.mp3");
	AddFileToDownloadsTable("sound/zombiesurvival/music_win.mp3");
	
	AddFileToDownloadsTable("sound/zombiesurvival/headshot1.wav");
	AddFileToDownloadsTable("sound/zombiesurvival/headshot2.wav");
	
}

void Music_EndLastmann()
{
//	if(MusicDisabled)   Does this even matter? You might aswell keep it in yknow...
//		return;

	if(LastMann)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				SetMusicTimer(client, 0);
				StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
				StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
				TF2_RemoveCondition(client, TFCond_DefenseBuffed);
				TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
				TF2_RemoveCondition(client, TFCond_RuneHaste);
				TF2_RemoveCondition(client, TFCond_CritCanteen);
			}
		}
		LastMann = false;
	}
}

void Music_RoundEnd(int victim)
{
	ExcuteRelay("zr_gamelost");
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			SetMusicTimer(client, GetTime() + 45);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
			TF2_RemoveCondition(client, TFCond_DefenseBuffed);
			TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
			TF2_RemoveCondition(client, TFCond_RuneHaste);
			TF2_RemoveCondition(client, TFCond_CritCanteen);
			Music_Stop_All(client);
			FormatEx(char_MusicString1, sizeof(char_MusicString1), "");
			
			FormatEx(char_MusicString2, sizeof(char_MusicString2), "");
		
			i_MusicLength1 = 1;
					
			i_MusicLength2 = 1;
			EmitSoundToClient(client, "#zombiesurvival/music_lose.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
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
	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);
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
	cvarTimeScale.SetFloat(1.0);
	return Plugin_Handled;
}

void Music_Stop_All(int client)
{
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/1.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/2.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/3.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/4.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/5.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/6.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/7.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/8.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/9.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/1.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/2.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/3.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/4.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/5.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/6.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/7.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/8.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/9.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/1.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/2.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/3.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/4.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/5.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/6.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/7.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/8.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/9.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/1.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/2.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/3.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/4.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/5.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/6.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/7.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/8.mp3");
	StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/beats/defaulthuman/9.mp3");
	
	if(char_MusicString1[0])
	{
		StopSound(client, SNDCHAN_STATIC, char_MusicString1);
		StopSound(client, SNDCHAN_STATIC, char_MusicString1);
		StopSound(client, SNDCHAN_STATIC, char_MusicString1);
		StopSound(client, SNDCHAN_STATIC, char_MusicString1);
	}
		
	if(char_MusicString2[0])
	{
		StopSound(client, SNDCHAN_STATIC, char_MusicString2);
		StopSound(client, SNDCHAN_STATIC, char_MusicString2);
		StopSound(client, SNDCHAN_STATIC, char_MusicString2);
		StopSound(client, SNDCHAN_STATIC, char_MusicString2);
	}
	
}

float f_ClientMusicVolume[MAXTF2PLAYERS];
float f_BegPlayerToSetDuckConvar[MAXTF2PLAYERS];

//ty miku for tellingg

public void ConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientMusicVolume[client] = StringToFloat(cvarValue);
}

public void ConVarCallback_Plugin_message(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientServerShowMessages[client] = view_as<bool>(StringToInt(cvarValue));
}

public void ConVarCallbackDuckToVolume(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
	{
		if(f_BegPlayerToSetDuckConvar[client] < GetGameTime())
		{
			f_BegPlayerToSetDuckConvar[client] = GetGameTime() + 300.0;
			if(StringToFloat(cvarValue) < 0.9)
			{
				PrintToChat(client,"If you wish for Grigori to not half mute your game volume when he talks, set ''snd_ducktovolume'' to 1 in the console!");
			}
		}
	}
}

//TODO: This music just breaks and cuts off earlier and plays earlier, i really dont know why. I hate it! Find a fix!

void Music_PostThink(int client)
{
	if(LastMann)
	{
		if(Give_Cond_Timer[client] < GetGameTime())
		{
			if(IsPlayerAlive(client))
			{
				if(TeutonType[client] == TEUTON_NONE)
				{
					TF2_AddCondition(client, TFCond_DefenseBuffed, 2.0);
					TF2_AddCondition(client, TFCond_NoHealingDamageBuff, 2.0);
					TF2_AddCondition(client, TFCond_RuneHaste, 2.0);
					if(Attributes_FindOnPlayer(client, 232))
						TF2_AddCondition(client, TFCond_CritCanteen, 2.0);
					
					Give_Cond_Timer[client] = GetGameTime() + 1.0;
				}
			}
		}
		if(TeutonType[client] == TEUTON_NONE)
		{
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 250.0);
		}
	}
	
	if(MusicDisabled)
		return;
	
	if(f_ClientMusicVolume[client] < 0.05)
		return;
	
	if(Music_Timer[client] < GetTime() && Music_Timer_2[client] < GetTime())
	{
		bool RoundHasCustomMusic = false;
		
		if(char_MusicString1[0])
			RoundHasCustomMusic = true;
			
		if(char_MusicString2[0])
			RoundHasCustomMusic = true;
		
		if(LastMann)
		{
			RoundHasCustomMusic = false;
		}
		
		if(RoundHasCustomMusic)
		{
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					if(char_MusicString1[0])
					{
						EmitSoundToClient(client, char_MusicString1[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						EmitSoundToClient(client, char_MusicString1[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						SetMusicTimer(client, GetTime() + i_MusicLength1);
					}
					else if(char_MusicString2[0])
					{
						EmitSoundToClient(client, char_MusicString2[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						EmitSoundToClient(client, char_MusicString2[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						SetMusicTimer(client, GetTime() + i_MusicLength2);				
					}
					//Make checks to be sure.
				}
				case 2:
				{
					if(char_MusicString2[0])
					{
						EmitSoundToClient(client, char_MusicString2[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						EmitSoundToClient(client, char_MusicString2[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						SetMusicTimer(client, GetTime() + i_MusicLength2);
					}
					else if(char_MusicString1[0])
					{
						EmitSoundToClient(client, char_MusicString1[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						EmitSoundToClient(client, char_MusicString1[0], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						SetMusicTimer(client, GetTime() + i_MusicLength1);				
					}
					//Make checks to be sure.
				}
			}
			return;
		}
		int intencity;
		for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity])
			{
				float targPos[3];
				float chargerPos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targPos);
				GetClientAbsOrigin(client, chargerPos);
				if (GetVectorDistance(chargerPos, targPos, true) <= Pow(1750.0, 2.0))
				{
					CClotBody npcstats = view_as<CClotBody>(entity);
					if(!npcstats.m_bThisNpcIsABoss)
					{
						intencity += 1;
					}
					else
					{
						intencity += 10;
					}
				}
			}
		}
		
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			intencity += 9999; //absolute max.
			GlobalIntencity += 9999;
		}
		
		if(LastMann)
		{
			EmitSoundToClient(client, "#zombiesurvival/lasthuman.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			SetMusicTimer(client, GetTime() + 120);		
		}
		else if(intencity < 1)
		{
			SetMusicTimer(client, GetTime() + 8);
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.1))
		{
			EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			SetMusicTimer(client, GetTime() + 6);
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.2))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.3))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.4))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.5))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.6))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.7))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.8))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(intencity < RoundToCeil(float(PlayersAliveScaling) * 0.9))
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else
		{
			if(GlobalIntencity >= RoundToNearest((float(PlayersAliveScaling) * 0.65)))
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
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
	Zero(f_BegPlayerToSetDuckConvar);
}