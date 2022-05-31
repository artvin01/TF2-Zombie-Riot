float Music_Timer[MAXTF2PLAYERS];
static float Give_Cond_Timer[MAXTF2PLAYERS];
static bool MusicDisabled;

void Music_ClearAll()
{
	Zero(Give_Cond_Timer);
}

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
				Music_Timer[client] = 0.0;
				StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
				StopSound(client, SNDCHAN_STATIC, "#zombiesurvival/lasthuman.mp3");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
				TF2_RemoveCondition(client, TFCond_DefenseBuffed);
				TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
				TF2_RemoveCondition(client, TFCond_RuneHaste);
				TF2_RemoveCondition(client, TFCond_CritCanteen);
			}
		}
	}
}

void Music_RoundEnd(int victim)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			Music_Timer[client] = GetEngineTime() + 20.0;
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
			TF2_RemoveCondition(client, TFCond_DefenseBuffed);
			TF2_RemoveCondition(client, TFCond_NoHealingDamageBuff);
			TF2_RemoveCondition(client, TFCond_RuneHaste);
			TF2_RemoveCondition(client, TFCond_CritCanteen);
			Music_Stop_All(client);
			EmitSoundToClient(client, "#zombiesurvival/music_lose.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", victim);
		}
	}
	
	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);
}

public Action SetTimeBack(Handle timer)
{
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
}

float f_ClientMusicVolume[MAXTF2PLAYERS];

//ty miku for tellingg

public void ConVarCallback(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(result == ConVarQuery_Okay)
		f_ClientMusicVolume[client] = StringToFloat(cvarValue);
}

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

	if(Music_Timer[client] < GetEngineTime())
	{
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
				if (GetVectorDistance(chargerPos, targPos) <= 1500.0)
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
			Music_Timer[client] = GetEngineTime() + 119.95;
			
		}
		else if(intencity < 1)
		{
			Music_Timer[client] = GetEngineTime() + 7.95;
			
		}
		else if(intencity < 2)
		{
			EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
			Music_Timer[client] = GetEngineTime() + 5.95;
			
		}
		else if(intencity < 3)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 7.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/1.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 6.95;
			}
			
		}
		else if(intencity < 4)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 7.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/2.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 6.95;
			}
			
		}
		else if(intencity < 5)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 7.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/3.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 6.95;
			}
			
		}
		else if(intencity < 6)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 7.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/4.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 6.95;
			}
			
		}
		else if(intencity < 7)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/5.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			
		}
		else if(intencity < 8)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/6.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 13.95;
			}
			
		}
		else if(intencity < 9)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/7.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 13.95;
			}
			
		}
		else if(intencity < 10)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/8.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 6.95;
			}
			
		}
		else if(intencity >= 10)
		{
			if(GlobalIntencity > 3)
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaultzombiev2/10.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 5.95;
			}
			else
			{
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				EmitSoundToClient(client, "#zombiesurvival/beats/defaulthuman/9.mp3", _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, 1.0);
				Music_Timer[client] = GetEngineTime() + 13.95;
			}
			
		}
	}
}

//CHECK SDKHOOKS PRETHINK!!!