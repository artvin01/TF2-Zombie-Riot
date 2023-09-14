#pragma semicolon 1
#pragma newdecls required

static int Music_Timer[MAXTF2PLAYERS];
static int Music_Timer_2[MAXTF2PLAYERS];
static float Give_Cond_Timer[MAXTF2PLAYERS];
static bool MusicDisabled;
static float RaidMusicVolume;

#define RANGE_FIRST_MUSIC 6250000
#define RANGE_SECOND_MUSIC 1000000

/*
Big thanks to backwards#8236 For pointing me towards GetTime and helping me with this music tgimer,
DO NOT USE GetEngineTime, its not good in this case
*/

void Music_SetRaidMusic(const char[] MusicPath, int duration, bool isCustom, float volume = 2.0)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client); //This is actually more expensive then i thought.
			SetMusicTimer(client, GetTime() + 3);
		}
	}
	RaidMusicVolume = volume;
	strcopy(char_RaidMusicSpecial1, sizeof(char_RaidMusicSpecial1), MusicPath);
	i_RaidMusicLength1 = duration;
	b_RaidMusicCustom1 = isCustom;

}

void Music_MapStart()
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
	PrecacheSoundCustom("#zombiesurvival/music_win.mp3",_,1);

	MusicDisabled = FindInfoTarget("zr_nomusic");
}

bool Music_Disabled()
{
	return MusicDisabled;
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
				Armor_Charge[client] = 0;
				if(IsPlayerAlive(client))
					SetEntProp(client, Prop_Send, "m_iHealth", 50);
				
				//just incase.
				Attributes_Set(client, 442, 1.0);
			}
		}
		LastMann = false;
	}
}

void Music_RoundEnd(int victim, bool music = true)
{
	ExcuteRelay("zr_gamelost");
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			if(music)
				SetMusicTimer(client, GetTime() + 45);
			
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
			TF2_RemoveCondition(client, TFCond_DefenseBuffed);
			TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
			TF2_RemoveCondition(client, TFCond_RuneHaste);
			TF2_RemoveCondition(client, TFCond_CritCanteen);
			Music_Stop_All(client);
			char_MusicString1[0] = 0;
			char_MusicString2[0] = 0;
		
			i_MusicLength1 = 1;
			i_MusicLength2 = 1;

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

	if(char_RaidMusicSpecial1[0])
	{
		StopSound(client, SNDCHAN_STATIC, char_RaidMusicSpecial1);
		StopSound(client, SNDCHAN_STATIC, char_RaidMusicSpecial1);
		StopSound(client, SNDCHAN_STATIC, char_RaidMusicSpecial1);
		StopSound(client, SNDCHAN_STATIC, char_RaidMusicSpecial1);
	}
	
}

public void ConVarCallback_Plugin_message(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientServerShowMessages[client] = view_as<bool>(StringToInt(cvarValue));
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
					if(Attributes_FindOnPlayerZR(client, 232))
						TF2_AddCondition(client, TFCond_CritCanteen, 2.0);
					
					Give_Cond_Timer[client] = GetGameTime() + 1.0;
					Attributes_Set(client, 442, 0.7674418604651163);
					
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
	
	if(MusicDisabled)
		return;

	if(!b_GameOnGoing)
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

		if(char_RaidMusicSpecial1[0])
			RoundHasCustomMusic = true;
		
		if(LastMann)
		{
			RoundHasCustomMusic = false;
		}
		
		if(RoundHasCustomMusic)
		{
			if(char_RaidMusicSpecial1[0])
			{
				if(b_RaidMusicCustom1)
				{
					EmitCustomToClient(client, char_RaidMusicSpecial1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, RaidMusicVolume);
				}
				else
				{
					EmitSoundToClient(client, char_RaidMusicSpecial1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
					EmitSoundToClient(client, char_RaidMusicSpecial1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				}
				SetMusicTimer(client, GetTime() + i_RaidMusicLength1);
				return;
			}
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					if(char_MusicString1[0])
					{
						if(b_MusicCustom1)
						{
							EmitCustomToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
						}
						else
						{
							EmitSoundToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}
						SetMusicTimer(client, GetTime() + i_MusicLength1);
					}
					else if(char_MusicString2[0])
					{
						if(b_MusicCustom2)
						{
							EmitCustomToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
						}
						else
						{
							EmitSoundToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}
						SetMusicTimer(client, GetTime() + i_MusicLength2);				
					}
					//Make checks to be sure.
				}
				case 2:
				{
					if(char_MusicString2[0])
					{
						if(b_MusicCustom2)
						{
							EmitCustomToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
						}
						else
						{
							EmitSoundToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, char_MusicString2, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}
						SetMusicTimer(client, GetTime() + i_MusicLength2);
					}
					else if(char_MusicString1[0])
					{
						if(b_MusicCustom1)
						{
							EmitCustomToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
						}
						else
						{
							EmitSoundToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
							EmitSoundToClient(client, char_MusicString1, _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
						}
						SetMusicTimer(client, GetTime() + i_MusicLength1);				
					}
					//Make checks to be sure.
				}
			}
			return;
		}
		float f_intencity;
		float targPos[3];
		float chargerPos[3];
		for(int entitycount; entitycount<i_MaxcountNpc; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
			if(IsValidEntity(entity) && !b_NpcHasDied[entity])
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
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			f_intencity += 9999.9; //absolute max.
			GlobalIntencity += 9999;
		}

		if(!ZombieMusicPlayed)//once set in a wave, it should stay untill the next mass revive.
		{
			if(!b_IsAloneOnServer && float(GlobalIntencity) >= float(PlayersInGame) * 0.25)
			{
				ZombieMusicPlayed = true;
			}
		}
		
		if(LastMann)
		{
			EmitCustomToClient(client, "#zombiesurvival/lasthuman.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			SetMusicTimer(client, GetTime() + 120);		
		}
		else if(f_intencity < 1.0)
		{
			SetMusicTimer(client, GetTime() + 8);
		}
		else if(!b_IsAloneOnServer && f_intencity < float(PlayersAliveScaling) * 0.1)
		{
			EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
			SetMusicTimer(client, GetTime() + 6);
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.2)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.3)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.4)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.5)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 8);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.6)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.7)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.8)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 14);
			}
			
		}
		else if(f_intencity < float(PlayersAliveScaling) * 0.9)
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
				SetMusicTimer(client, GetTime() + 7);
			}
			
		}
		else
		{
			if(ZombieMusicPlayed)
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.5);
				SetMusicTimer(client, GetTime() + 6);
			}
			else
			{
				EmitCustomToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 2.0);
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