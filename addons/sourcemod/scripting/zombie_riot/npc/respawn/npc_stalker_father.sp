#pragma semicolon 1
#pragma newdecls required

void StalkerFather_MapStart()
{
	PrecacheSound("#music/radio1.mp3");
	PrecacheModel("models/zombie/monk_combine.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Corrupted Father Grigori");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stalker_father");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return StalkerFather(vecPos, vecAng, team, data);
}

methodmap StalkerFather < StalkerShared
{
	public void PlayMusicSound()
	{
		if(i_PlayMusicSound[this.index] > GetTime())
			return;
		
		EmitSoundToAll("#music/radio1.mp3", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll("#music/radio1.mp3", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		i_PlayMusicSound[this.index] = GetTime() + 39;
	}
	
	public StalkerFather(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		StalkerFather npc = view_as<StalkerFather>(CClotBody(vecPos, vecAng, "models/zombie/monk_combine.mdl", "1.15", "66666", ally));
		
		i_NpcWeight[npc.index] = 5;
		fl_GetClosestTargetTimeTouch[npc.index] = 99999.9;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK_RIFLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = StalkerFather_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = StalkerFather_OnTakeDamage;
		func_NPCThink[npc.index] = StalkerFather_ClotThink;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);

		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; //Makes it so they never have an outline
		//b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets

		Zero(fl_AlreadyStrippedMusic);

		npc.m_iState = -1;
		npc.m_flSpeed = 92.0;	// 80 Run Speed * 1.15 Model Size

		i_PlayMusicSound[npc.index] = 0;
		npc.m_iChaseAnger = 0;
		npc.m_bChaseAnger = false;
		npc.m_iChaseVisable = 0;
		npc.Anger = view_as<bool>(StringToInt(data));
		return npc;
	}
}

public void StalkerFather_ClotThink(int iNPC)
{
	StalkerFather npc = view_as<StalkerFather>(iNPC);

	float gameTime = GetGameTime(iNPC);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	if(!Waves_InSetup() && !npc.Anger && Waves_GetRoundScale() > 19)
	{
		if(b_thisNpcHasAnOutline[npc.index])
		{
			// Vulnerable pass Wave 30
			GiveNpcOutLineLastOrBoss(npc.index, true);
			//b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
		}
	}
	else if(!b_thisNpcHasAnOutline[npc.index])
	{
		GiveNpcOutLineLastOrBoss(npc.index, false);
		//b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
	}

	if(Waves_InSetup())
	{
		for(int i; i < 9; i++)
		{
			StopSound(npc.index, SNDCHAN_STATIC, "#music/radio1.mp3");
		}

		i_PlayMusicSound[npc.index] = 0;
		FreezeNpcInTime(npc.index, 0.5);
		return;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget, true))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	static float LastKnownPos[3];
	if(npc.m_flGetClosestTargetTime < gameTime && (npc.m_bChaseAnger || npc.m_iChaseAnger < 1))
	{
		// Big range while were angery
		npc.m_iTarget = GetClosestTarget(npc.index, _, npc.m_bChaseAnger ? FAR_FUTURE : 150.0, npc.m_bChaseAnger, _, _, _, true, npc.m_bChaseAnger ? FAR_FUTURE : 200.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(!npc.m_bChaseAnger && npc.m_iTarget > 0)
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
	
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	if(npc.m_bChaseAnger && npc.CanSeeEnemy())
	{
		WorldSpaceCenter(npc.m_iTarget, LastKnownPos);
		float distance = GetVectorDistance(LastKnownPos, vecMe, true);
		
		int state;
		if(npc.m_flDoingAnimation > gameTime)
		{
			state = -1;
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			state = 1;
		}

		switch(state)
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

				npc.StartPathing();
				if(distance < npc.GetLeadRadius()) 
				{
					PredictSubjectPosition(npc, npc.m_iTarget,_,_,LastKnownPos);
					npc.SetGoalVector(LastKnownPos);
				}
				else
				{
					npc.SetGoalEntity(npc.m_iTarget);
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
		int state;
		float distance = GetVectorDistance(LastKnownPos, vecMe, true);
		if(npc.m_flDoingAnimation > gameTime)
		{
			state = -1;
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED)
		{
			state = 1;
		}

		switch(state)
		{
			case -1:
			{
				npc.StopPathing();
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

				if(!npc.m_bChaseAnger && !(GetURandomInt() % 999))
					npc.PickRandomPos(LastKnownPos);

				npc.StartPathing();
				npc.SetGoalVector(LastKnownPos);
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

				npc.PickRandomPos(LastKnownPos);
			}
		}
	}

	float engineTime = GetEngineTime();

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			static float pos[3];
			GetClientAbsOrigin(client, pos);
			if(GetVectorDistance(vecMe, pos, true) < 2000000.0 && (Can_I_See_Enemy(npc.index, client) == client))
			{
				if(fl_AlreadyStrippedMusic[client] < engineTime)
					Music_Stop_All(client);
				
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = engineTime + 5.0;
			}
		}
	}
	
	npc.PlayMusicSound();
}

public Action StalkerFather_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0 && attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if(damage > 9999999.9)
		return Plugin_Continue;
	
	if(damagetype & DMG_OUTOFBOUNDS)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE && !GetEntProp(client, Prop_Send, "m_bDucked"))
			{
				float pos[3];
				GetClientAbsOrigin(client, pos);
				TeleportEntity(victim, pos);
				break;
			}
		}
		return Plugin_Changed;
	}

	if(attacker < 1)
		return Plugin_Continue;

	StalkerFather npc = view_as<StalkerFather>(victim);

	// Angry when injured
	if(npc.m_bChaseAnger)
	{
		if(npc.m_iChaseAnger < 60)
			npc.m_iChaseAnger = 60;
	}
	else
	{
		npc.m_flSpeed = 280.0;
		npc.m_bChaseAnger = true;
		npc.m_iChaseAnger = 100;
	}

	damage *= 15.0 / float(PlayersInGame);

	if(!Waves_InSetup() && Waves_GetRoundScale() > 19)
		return Plugin_Changed;
	
	damage = 0.0;
	return Plugin_Handled;
}

void StalkerFather_NPCDeath(int entity)
{
	StalkerFather npc = view_as<StalkerFather>(entity);

	for(int i; i < 9; i++)
	{
		StopSound(npc.index, SNDCHAN_STATIC, "#music/radio1.mp3");
	}

	if(!npc.Anger)
	{
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

		CreateTimer(70.0, StalkerFather_Timer, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

public Action StalkerFather_Timer(Handle timer)
{
	if(Waves_InSetup())
		return Plugin_Continue;
	
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin("npc_stalker_googgles");
	enemy.Health = 66666666;
	enemy.Is_Immune_To_Nuke = true;
	enemy.Is_Static = true;
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;	
	enemy.ExtraSize = 1.0;	
	enemy.Team = TFTeam_Blue;	
	Waves_AddNextEnemy(enemy);
	return Plugin_Stop;
}