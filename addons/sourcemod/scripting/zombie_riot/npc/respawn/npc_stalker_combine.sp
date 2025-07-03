#pragma semicolon 1
#pragma newdecls required



methodmap StalkerShared < CClotBody
{
	public bool CanSeeEnemy()
	{
		if(this.m_iTarget < 1)
			return false;
		
		int EnemySee = Can_I_See_Enemy(this.index, this.m_iTarget);
		if(IsValidEnemy(this.index, EnemySee))
		{
			this.m_iTarget = EnemySee;
		}
		if(IsValidEnemy(this.index, this.m_iTarget))
		{
			if(this.m_iChaseVisable < 6)
				this.m_iChaseVisable++;
		}
		else if(this.m_iChaseVisable > 0)
		{
			this.m_iChaseVisable--;
		}

		return this.m_iChaseVisable > 0;
	}
	public void PickRandomPos(float pos[3])
	{
		static float pos2[3];
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
			{
				GetClientAbsOrigin(client, pos2);
				break;
			}
		}

		CNavArea startArea = TheNavMesh.GetNavAreaEntity(this.index, view_as<GetNavAreaFlags_t>(0), 1000.0);
		if(startArea != NULL_AREA)
		{
			for(int i; i < 50; i++)
			{
				CNavArea RandomArea = PickRandomArea();
				if(RandomArea != NULL_AREA)
				{
					int NavAttribs = RandomArea.GetAttributes();
					if(NavAttribs & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE|NAV_MESH_NO_HOSTAGES))
						continue;
					
					RandomArea.GetCenter(pos);
					if(!TheNavMesh.BuildPath(startArea, RandomArea, pos))
						continue;

					if(GetVectorDistance(pos, pos2, true) < 2000000.0)
						return;
				}
			}
		}

		WorldSpaceCenter(this.index, pos);
	}

	property int m_iChaseAnger	// Allows being able to quickly hide
	{
		public get()		{ return this.m_iAttacksTillMegahit; }
		public set(int value) 	{ this.m_iAttacksTillMegahit = value; }
	}
	property bool m_bChaseAnger	// If currently chasing a target down
	{
		public get()		{ return !b_DuringHook[this.index]; }
		public set(bool value) 	{ b_DuringHook[this.index] = !value; }
	}
	property int m_iChaseVisable	// Time before we considered "lost them"
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
}

void StalkerCombine_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Subject");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stalker_combine");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/zombie/zombie_soldier.mdl");
	static const char SoundList[][] =
	{
		"npc/zombine/zombine_idle1.wav",
		"npc/zombine/zombine_idle2.wav",
		"npc/zombine/zombine_idle3.wav",
		"npc/zombine/zombine_idle4.wav",
		"npc/zombine/zombine_alert1.wav",
		"npc/zombine/zombine_alert2.wav",
		"npc/zombine/zombine_alert3.wav",
		"npc/zombine/zombine_alert4.wav",
		"npc/zombine/zombine_alert5.wav",
		"npc/zombine/zombine_alert6.wav",
		"npc/zombine/zombine_alert7.wav",
		"npc/zombine/zombine_pain1.wav",
		"npc/zombine/zombine_pain2.wav",
		"npc/zombine/zombine_pain3.wav",
		"npc/zombine/zombine_pain4.wav",
		"npc/zombine/zombine_die1.wav",
		"npc/zombine/zombine_charge1.wav",
		"npc/zombine/zombine_charge2.wav",
		"npc/zombine/zombine_readygrenade2.wav",
		"#music/vlvx_song11.mp3",
		"npc/zombine/gear1.wav",
		"npc/zombine/gear2.wav",
		"npc/zombine/gear3.wav"
	};

	for(int i; i < sizeof(SoundList); i++)
	{
		PrecacheSoundCustom(SoundList[i]);
	}
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return StalkerCombine(vecPos, vecAng, team);
}
methodmap StalkerCombine < StalkerShared
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		static const char RandomSound[][] =
		{
			"npc/zombine/zombine_idle1.wav",
			"npc/zombine/zombine_idle2.wav",
			"npc/zombine/zombine_idle3.wav",
			"npc/zombine/zombine_idle4.wav"
		};

		EmitCustomToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 12.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		static const char RandomSound[][] =
		{
			"npc/zombine/zombine_alert1.wav",
			"npc/zombine/zombine_alert2.wav",
			"npc/zombine/zombine_alert3.wav",
			"npc/zombine/zombine_alert4.wav",
			"npc/zombine/zombine_alert5.wav",
			"npc/zombine/zombine_alert6.wav",
			"npc/zombine/zombine_alert7.wav"
		};
		
		EmitCustomToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 12.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		static const char RandomSound[][] =
		{
			"npc/zombine/zombine_pain1.wav",
			"npc/zombine/zombine_pain2.wav",
			"npc/zombine/zombine_pain3.wav",
			"npc/zombine/zombine_pain4.wav"
		};
		
		EmitCustomToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("npc/zombine/zombine_die1.wav");
	}
	public void PlayMeleeHitSound()
	{
		static const char RandomSound[][] =
		{
			"npc/fast_zombie/claw_strike1.wav",
			"npc/fast_zombie/claw_strike2.wav",
			"npc/fast_zombie/claw_strike3.wav"
		};

		EmitSoundToAll(RandomSound[GetURandomInt() % sizeof(RandomSound)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAlertSound(int client)
	{
		static const char RandomSound[][] =
		{
			"npc/zombine/zombine_charge1.wav",
			"npc/zombine/zombine_charge2.wav"
		};
		
		int rand = GetURandomInt() % sizeof(RandomSound);
		EmitCustomToAll(RandomSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		if(client > 0 && client <= MaxClients)
			EmitCustomToClient(client, RandomSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpecialSound()
	{
		EmitCustomToAll("npc/zombine/zombine_readygrenade2.wav");
	}
	public void PlayMusicSound()
	{
		if(i_PlayMusicSound[this.index] > GetTime())
			return;
		
		EmitCustomToAll("#music/vlvx_song11.mp3", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0, 100);
		i_PlayMusicSound[this.index] = GetTime() + 76;
	}
	
	public StalkerCombine(float vecPos[3], float vecAng[3], int ally)
	{
		StalkerCombine npc = view_as<StalkerCombine>(CClotBody(vecPos, vecAng, "models/zombie/zombie_soldier.mdl", "1.2", "6666", ally));
		
		i_NpcWeight[npc.index] = 5;
	//	fl_GetClosestTargetTimeTouch[npc.index] = 99999.9;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "warrior_spirit");
		
		npc.m_iBleedType = BLEEDTYPE_XENO;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NONE;
		
		
		func_NPCDeath[npc.index] = StalkerCombine_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = StalkerCombine_OnTakeDamage;
		func_NPCThink[npc.index] = StalkerCombine_ClotThink;
		func_NPCAnimEvent[npc.index] = StalkerCombine_HandleAnimEvent;


		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		Is_a_Medic[npc.index] = true;
		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);

		Zero(fl_AlreadyStrippedMusic);

		npc.m_iState = -1;
		npc.m_flSpeed = 50.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_bDissapearOnDeath = false;
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; //Makes it so they never have an outline
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets

		i_PlayMusicSound[npc.index] = 0;
		npc.m_iChaseAnger = 0;
		npc.m_bChaseAnger = false;
		npc.m_iChaseVisable = 0;
		npc.m_iWearable1 = -1;
		return npc;
	}
}

public void StalkerCombine_ClotThink(int iNPC)
{
	StalkerCombine npc = view_as<StalkerCombine>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(npc.index, "SetBodyGroup");

	float gameTime = GetGameTime(iNPC);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	/*
	if(Waves_InSetup())
	{
		for(int i; i < 9; i++)
		{
			StopSound(npc.index, SNDCHAN_STATIC, "#music/vlvx_song11.mp3");
		}
		
		i_PlayMusicSound = 0;
		FreezeNpcInTime(npc.index, 0.5);
		return;
	}
	*/
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		//npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget > 0 && (!npc.m_bmovedelay || i_NpcInternalId[npc.m_iTarget] != CuredFatherGrigori_ID() || !IsValidEntity(npc.m_iTarget)) && !IsValidEnemy(npc.index, npc.m_iTarget, true))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	static float LastKnownPos[3];
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		// Only find targets we can look at, ignore buildings while not pissed
		npc.m_iTarget = GetClosestTarget(npc.index, !npc.m_bChaseAnger, _, true, _, _, _, true, FAR_FUTURE);
		npc.m_flGetClosestTargetTime = gameTime + (npc.m_iTarget ? 2.5 : 0.5);

		// Hunt down the Father
		if(npc.m_iTarget < 1 || i_NpcInternalId[npc.m_iTarget] != CuredFatherGrigori_ID())
		{
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == CuredFatherGrigori_ID())
				{
					float EntityLocation[3], TargetLocation[3]; 
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", EntityLocation); 
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", TargetLocation); 
								
					float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
					if(distance < 1000000.0) // 1000 range
					{
						npc.m_iTarget = entity;
						npc.m_iChaseAnger = 999;
						npc.m_bChaseAnger = true;
						npc.m_flGetClosestTargetTime = FAR_FUTURE;

						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 5;
						npc.SetActivity("ACT_ZOMBINE_GRENADE_PULL");
						npc.StopPathing();
						
						npc.m_flDoingAnimation = gameTime + 1.05;

						if(npc.m_iWearable1 == -1)
						{
							npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_grenade.mdl");
							SetVariantString("1.2");
							AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

							npc.m_bmovedelay = true;
							GiveNpcOutLineLastOrBoss(npc.index, true);

							npc.PlaySpecialSound();
						}
					}
					break;
				}
			}
		}
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			if(npc.m_iTarget > 0)
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					if(target > 0)
					{
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);

						float damage = 180.0;
						if(Construction_Mode())
							damage *= 5.0;

						if(ShouldNpcDealBonusDamage(npc.m_iTarget))
							damage *= 8.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if((npc.m_iTarget > 0 && npc.m_bmovedelay) || npc.CanSeeEnemy())
	{
		if(npc.m_iChaseAnger < 54)
		{
			if(!npc.m_iChaseAnger)
				npc.PlayAlertSound(npc.m_iTarget);
			
			npc.m_iChaseAnger += 9;
			if(!npc.m_bChaseAnger && npc.m_iChaseAnger > 53)
			{
				npc.m_flSpeed = 231.96;	// 193.3 Run Speed * 1.2 Model Size
				npc.m_bChaseAnger = true;
			}
		}

		if(npc.m_bChaseAnger)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			float engineTime = GetEngineTime();

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client))
				{
					GetClientAbsOrigin(client, LastKnownPos);
					if(GetVectorDistance(vecMe, LastKnownPos, true) < 2000000.0 && (Can_I_See_Enemy(npc.index, client) == client))
					{
						if(fl_AlreadyStrippedMusic[client] < engineTime)
							Music_Stop_All(client);
						
						SetMusicTimer(client, GetTime() + 5);
						fl_AlreadyStrippedMusic[client] = engineTime + 5.0;
					}
				}
			}
			
			npc.PlayMusicSound();

			WorldSpaceCenter(npc.m_iTarget, LastKnownPos);
			float distance = GetVectorDistance(LastKnownPos, vecMe, true);

			int state;
			if(npc.m_flDoingAnimation > gameTime)
			{
				state = -1;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.65) && npc.m_flNextMeleeAttack < gameTime)
			{
				state = 1;
			}

			switch(state)
			{
				case -1:
				{
					npc.StopPathing();
					return;
				}
				case 0:
				{
					npc.m_bisWalking = true;
					if(npc.m_iChanged_WalkCycle != 4)
					{
						npc.m_iChanged_WalkCycle = 4;
						if(npc.m_bmovedelay)
						{
							npc.SetActivity("ACT_ZOMBINE_GRENADE_RUN");
						}
						else
						{
							npc.SetActivity("ACT_RUN");
						}
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
					if(npc.m_bmovedelay)
					{
						// Blow up Father, add the next stalker boss
						if(i_NpcInternalId[npc.m_iTarget] == CuredFatherGrigori_ID())
						{
							Enemy enemy;
							enemy.Index = NPC_GetByPlugin("npc_stalker_father");
							enemy.Health = 666666;
							enemy.Is_Immune_To_Nuke = true;
							enemy.Is_Static = true;
							enemy.ExtraMeleeRes = 1.0;
							enemy.ExtraRangedRes = 1.0;
							enemy.ExtraSpeed = 1.0;
							enemy.ExtraDamage = fl_Extra_Damage[npc.index];	
							enemy.ExtraSize = 1.0;	
							enemy.Team = GetTeam(npc.index);	
							Waves_AddNextEnemy(enemy);

							TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);

							KillFeed_SetKillIcon(npc.index, "taunt_soldier");
							SmiteNpcToDeath(npc.index);
							SmiteNpcToDeath(npc.m_iTarget);
						}
					}
					else
					{
						npc.m_bisWalking = false;
						npc.StopPathing();

						if(npc.m_iChanged_WalkCycle != 7)
						{
							npc.m_iChanged_WalkCycle = 7;
							npc.SetActivity("ACT_IDLE");
						}
						
						npc.AddGesture("ACT_ZOMBINE_ATTACK_FAST");
						
						npc.m_flAttackHappens = gameTime + 0.25;
						npc.m_flDoingAnimation = gameTime + 1.0;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
				}
			}
		}
		else
		{
			// Stare at the target, confirm their real before chasing after
			float targ_vec[3]; WorldSpaceCenter(npc.m_iTarget, targ_vec);
			npc.FaceTowards(targ_vec, 1000.0);
		}

		npc.PlayIdleAlertSound();
	}
	else
	{
		if(npc.m_iChaseAnger > 0)
		{
			npc.m_iChaseAnger--;
			if(npc.m_bChaseAnger && npc.m_iChaseAnger == 0)
			{
				npc.m_flSpeed = 50.0;
				npc.m_bChaseAnger = false;
				i_PlayMusicSound[npc.index] = 0;

				for(int i; i < 9; i++)
				{
					StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/vlvx_song11.mp3");
				}
			}
		}

		int state;
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
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
				return;
			}
			case 0:
			{
				npc.m_bisWalking = true;
				
				if(npc.m_bChaseAnger)
				{
					if(npc.m_iChanged_WalkCycle != 4)
					{
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_RUN");
					}
				}
				else if(npc.m_iChanged_WalkCycle != 6)
				{
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_WALK");
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
				
				if(npc.m_iChanged_WalkCycle != 7)
				{
					npc.m_iChanged_WalkCycle = 7;
					npc.SetActivity("ACT_IDLE");
				}

				if(!npc.m_bChaseAnger && !(GetURandomInt() % 99))
					npc.PickRandomPos(LastKnownPos);
			}
		}

		npc.PlayIdleSound();
	}
}

public Action StalkerCombine_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
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

	StalkerCombine npc = view_as<StalkerCombine>(victim);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	ApplyStatusEffect(victim, victim, "Specter's Aura", 5.0);

	if(!b_StaticNPC[victim])
		return Plugin_Changed;
	
	damage = 0.0;
	return Plugin_Handled;
}

void StalkerCombine_HandleAnimEvent(int entity, int event)
{
	if(IsWalkEvent(event))
	{
		static const char RandomSound[][] =
		{
			"npc/zombine/gear1.wav",
			"npc/zombine/gear2.wav",
			"npc/zombine/gear3.wav"
		};

		StalkerCombine npc = view_as<StalkerCombine>(entity);
		npc.PlayStepSound(RandomSound[GetURandomInt() % sizeof(RandomSound)], 1.0, npc.m_iStepNoiseType, true);
	}
}

void StalkerCombine_NPCDeath(int entity)
{
	StalkerCombine npc = view_as<StalkerCombine>(entity);
	npc.PlayDeathSound();
	
	float startPosition[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
	startPosition[2] += 32;
	int gib;
/*
	int gib = Place_Gib("models/zombie/zombie_soldier_legs.mdl", startPosition, _, NULL_VECTOR, _, false, false, _, false, true, true);
	if(gib != -1)
		f_GibHealingAmount[gib] = true;
	
	startPosition[2] += 34;
	
	gib = Place_Gib("models/zombie/zombie_soldier_torso.mdl", startPosition, _, NULL_VECTOR, _, false, false, _, false, true, true);
	if(gib != -1)
		f_GibHealingAmount[gib] = true;
*/	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	

	for(gib = 0; gib < 9; gib++)
	{
		StopCustomSound(npc.index, SNDCHAN_STATIC, "#music/vlvx_song11.mp3");
	}
}