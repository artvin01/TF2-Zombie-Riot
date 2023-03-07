#pragma semicolon 1
#pragma newdecls required

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static int i_PlayMusicSound;

void StalkerFather_MapStart()
{
	PrecacheSound("#music/radio1.mp3");
}

methodmap StalkerFather < CClotBody
{
	public void PlayMusicSound()
	{
		if(i_PlayMusicSound > GetTime())
			return;
		
		EmitSoundToAll("#music/radio1.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll("#music/radio1.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		i_PlayMusicSound = GetTime() + 39;
	}
	
	public StalkerFather(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		StalkerFather npc = view_as<StalkerFather>(CClotBody(vecPos, vecAng, "models/zombie/monk_combine.mdl", "1.15", "66666", ally));
		
		i_NpcInternalId[npc.index] = STALKER_COMBINE;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, StalkerFather_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, StalkerFather_ClotThink);

		Zero(fl_AlreadyStrippedMusic);

		npc.m_iState = 0;
		npc.m_flSpeed = 92.0;	// 80 Run Speed * 1.15 Model Size

		i_PlayMusicSound = 0;
		npc.m_iChaseAnger = 0;
		npc.m_bChaseAnger = false;
		return npc;
	}
	property int m_iChaseAnger	// Allows being able to quickly hide
	{
		public get()		{ return this.m_iAttacksTillMegahit; }
		public set(int value) 	{ this.m_iAttacksTillMegahit = value; }
	}
	property bool m_bChaseAnger	// If currently chasing a target down
	{
		public get()		{ return this.Anger; }
		public set(bool value) 	{ this.Anger = value; }
	}
}

public void StalkerFather_ClotThink(int iNPC)
{
	StalkerFather npc = view_as<StalkerFather>(iNPC);

	float gameTime = GetGameTime(iNPC);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	static float LastKnownPos[3];
	if(npc.m_flGetClosestTargetTime < gameTime && (npc.m_bChaseAnger || npc.m_iChaseAnger < 1))
	{
		// Big range while were angery
		npc.m_iTarget = GetClosestTarget(npc.index, _, npc.Anger ? FAR_FUTURE : 200.0, npc.Anger, _, _, _, true, npc.Anger ? FAR_FUTURE : 200.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(!npc.m_bChaseAnger && npc.m_iTarget)
		{
			npc.m_flSpeed = 280.0;
			npc.m_bChaseAnger = true;
			npc.m_iChaseAnger = 100;
		}
	}

	if(npc.m_iChaseAnger > 0)
	{
		npc.m_iChaseAnger--;
		if(npc.m_bChaseAnger && npc.m_iChaseAnger == 10)
		{
			npc.m_flSpeed = 92.0;	// 80 HU x 1.15 Size
			npc.m_bChaseAnger = false;
		}
	}

	// Vulnerable past Wave 30
	if(!b_thisNpcHasAnOutline[npc.index] && Waves_GetRound() > 29)
	{
		b_StaticNPC[npc.index] = false;
		b_thisNpcHasAnOutline[npc.index] = true;
		SetEntProp(npc.index, Prop_Send, "m_bGlowEnabled", true);
	}
	
	if(npc.m_bChaseAnger && npc.m_iTarget > 0 && Can_I_See_Enemy(npc.index, npc.m_iTarget) == npc.m_iTarget)
	{
		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		float engineTime = GetEngineTime();

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				GetClientAbsOrigin(client, LastKnownPos);
				if(GetVectorDistance(vecMe, LastKnownPos, true) < 1000000.0) // 1000 range
				{
					if(fl_AlreadyStrippedMusic[client] < engineTime)
						Music_Stop_All(client); //This is actually more expensive then i thought.
					
					SetMusicTimer(client, GetTime() + 5);
					fl_AlreadyStrippedMusic[client] = engineTime + 5.0;
				}
			}
		}
		
		npc.PlayMusicSound();

		LastKnownPos = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(LastKnownPos, vecMe, true);

		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.m_iState = -1;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT * NORMAL_ENEMY_MELEE_RANGE_FLOAT) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1;
		}
		else 
		{
			npc.m_iState = 0;
		}

		switch(npc.m_iState)
		{
			case -1:
			{
				npc.StopPathing();
			}
			case 0:
			{
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN_AIM_RIFLE");
				}

				if(distance < npc.GetLeadRadius()) 
				{
					LastKnownPos = PredictSubjectPosition(npc, npc.m_iTarget);
					PF_SetGoalVector(npc.index, LastKnownPos);
				}
				else
				{
					PF_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_RANGE_ATTACK_SHOTGUN");
				npc.StopPathing();
				
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 1.19;
				npc.FireRocket(LastKnownPos, 100.0, 1200.0, "models/weapons/w_bullet.mdl", 2.0);	
				view_as<FatherGrigori>(npc).PlayRangedSound();
			}
		}
	}
	else
	{
		float distance = GetVectorDistance(LastKnownPos, WorldSpaceCenter(npc.index), true);
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.m_iState = -1;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT * NORMAL_ENEMY_MELEE_RANGE_FLOAT))
		{
			npc.m_iState = 1;
		}
		else 
		{
			npc.m_iState = 0;
		}

		switch(npc.m_iState)
		{
			case -1:
			{
				npc.StopPathing();
				return;
			}
			case 0:
			{
				npc.m_bisWalking = true;
				
				if(npc.m_bChaseAnger)
				{
					if(npc.m_iChanged_WalkCycle != 7)
					{
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_RUN_RIFLE");
					}
				}
				else if(npc.m_iChanged_WalkCycle != 6)
				{
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_WALK_RIFLE");
				}

				PF_SetGoalVector(npc.index, LastKnownPos);

				if(!npc.m_bChaseAnger && !(GetURandomInt() % 999))
				{
					NavArea RandomArea = PickRandomArea();
					if(RandomArea != NavArea_Null) 
						RandomArea.GetCenter(LastKnownPos);
				}
			}
			case 1:
			{
				npc.m_bisWalking = false;
				npc.StopPathing();

				if(npc.m_iChanged_WalkCycle != 8)
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_GLIDE");
				}

				NavArea RandomArea = PickRandomArea();
				if(RandomArea != NavArea_Null) 
					RandomArea.GetCenter(LastKnownPos);
			}
		}
	}
}

public Action StalkerFather_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1 || damage > 999999.9)
		return Plugin_Continue;

	StalkerFather npc = view_as<StalkerFather>(victim);

	// Angry when injured
	if(!npc.m_bChaseAnger && npc.m_iTarget)
	{
		npc.m_flSpeed = 280.0;
		npc.m_bChaseAnger = true;
		npc.m_iChaseAnger = 110;
	}

	if(!b_StaticNPC[npc.index] && !b_thisNpcHasAnOutline[npc.index])
		return Plugin_Changed;
	
	damage = 0.0;
	return Plugin_Handled;
}

void StalkerFather_NPCDeath(int entity)
{
	StalkerFather npc = view_as<StalkerFather>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, StalkerFather_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, StalkerFather_ClotThink);

	for(int i; i < 9; i++)
	{
		StopSound(npc.index, SNDCHAN_AUTO, "#music/radio1.mp3");
	}

	for(int client_Grigori=1; client_Grigori<=MaxClients; client_Grigori++)
	{
		if(IsClientInGame(client_Grigori) && GetClientTeam(client_Grigori)==2)
		{
			ClientCommand(client_Grigori, "playgamesound vo/ravenholm/yard_greetings.wav");
			SetHudTextParams(-1.0, -1.0, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client_Grigori);
			ShowSyncHudText(client_Grigori,  SyncHud_Notifaction, "%t", "Father Grigori Spawn");
		}
	}
	Spawn_Cured_Grigori();
}