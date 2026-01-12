#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/env_headcrabcanister/explosion.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/ichthyosaur/attack_growl1.wav",
	"npc/ichthyosaur/attack_growl2.wav",
	"npc/ichthyosaur/attack_growl3.wav"
};

static const char g_SpecialAttackSounds[][] =
{
	"ambient/explosions/explode_2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"npc/waste_scanner/grenade_fire.wav",
};

void UnderTides_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_SpecialAttackSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	PrecacheModel("models/synth.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sal Viento Bishop Quintus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_undertides");
	strcopy(data.Icon, sizeof(data.Icon), "ds_quintus");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return UnderTides(vecPos, vecAng, team, data);
}

methodmap UnderTides < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)]);
	}
	public void PlaySpecialSound()
 	{
		EmitSoundToAll(g_SpecialAttackSounds[GetRandomInt(0, sizeof(g_SpecialAttackSounds) - 1)]);
	}
	public void PlayRangedSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public UnderTides(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		UnderTides npc = view_as<UnderTides>(CClotBody(vecPos, vecAng, "models/synth.mdl", "1.0", "15000", ally, false, true, _, _, {30.0, 30.0, 100.0}, .NpcTypeLogic = 1));
		// 100,000 x 0.15

		i_NpcWeight[npc.index] = 999;
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		npc.m_bDissapearOnDeath = true;
		
		func_NPCDeath[npc.index] = UnderTides_NPCDeath;
		func_NPCThink[npc.index] = UnderTides_ClotThink;
		
		i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		npc.m_flSpeed = 1.0;
		npc.Anger = !zr_disablerandomvillagerspawn.BoolValue;
		if(!npc.Anger)
		{
			npc.Anger = !DisableRandomSpawns;
		}

		if(!npc.Anger)
		{
			GiveNpcOutLineLastOrBoss(npc.index, true);
			
			npc.m_flMeleeArmor = 2.0;

			npc.m_flNextMeleeAttack = GetGameTime() + 5.0;
			npc.m_flNextRangedAttack = npc.m_flNextMeleeAttack + 15.0;
			npc.m_flNextRangedSpecialAttack = npc.m_flNextMeleeAttack + 30.0;

			Citizen_MiniBossSpawn();
		}

		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		vecMe[2] += 500.0;
		npc.m_iWearable1 = ParticleEffectAt(vecMe, "env_rain_512", -1.0);
		SetParent(npc.index, npc.m_iWearable1);

		if(!data[0] && ally != TFTeam_Red && !IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime() + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		npc.m_bisWalking = false;
		npc.SetPlaybackRate(1.0);
		
		return npc;
	}
}

public void UnderTides_ClotThink(int iNPC)
{
	UnderTides npc = view_as<UnderTides>(iNPC);

	float gameTime = GetGameTime();	// You can't stun it

	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	
	/*
	if(npc.m_flAbilityOrAttack0 < gameTime)
	{
		PrintToChatAll("ttest");
		npc.SetCycle(0.0);
		npc.m_flAbilityOrAttack0 = gameTime + 3.0;
	}
	*/
	if(npc.Anger)
	{
		if(npc.m_flNextThinkTime > gameTime)
			return;
		
		npc.m_flNextThinkTime = gameTime + 0.1;

		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1250.0, 500.0);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 500.0, 350.0);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 350.0, 150.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 150.0, 0.0);
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.Anger = false;
		npc.m_flMeleeArmor = 2.0;

		npc.m_flNextMeleeAttack = GetGameTime() + 5.0;
		npc.m_flNextRangedAttack = npc.m_flNextMeleeAttack + 15.0;
		npc.m_flNextRangedSpecialAttack = npc.m_flNextMeleeAttack + 30.0;

		Citizen_MiniBossSpawn();
		
		if(!VIPBuilding_Active())
		{
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(!i_ObjectsSpawners[i] || !IsValidEntity(i_ObjectsSpawners[i]))
				{
					Spawns_AddToArray(EntIndexToEntRef(npc.index), true);
					i_ObjectsSpawners[i] = EntIndexToEntRef(npc.index);
					break;
				}
			}
		}
	}
	else if(npc.m_flNextMeleeAttack < gameTime)
	{
		float vecTarget[3];

		if(npc.m_flNextRangedSpecialAttack < gameTime)	// Great Tide
		{
			KillFeed_SetKillIcon(npc.index, "pumpkindeath");

			int enemy[16];
			GetHighDefTargets(npc, enemy, sizeof(enemy), Zombie_DelayExtraSpeed() < 1.6);

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					WorldSpaceCenter(enemy[i], vecTarget);

					ParticleEffectAt(vecTarget, "water_bulletsplash01", 3.0);

					SDKHooks_TakeDamage(enemy[i], npc.index, npc.index, 57.0, DMG_BULLET);
					// 380 * 0.15

					Elemental_AddNervousDamage(enemy[i], npc.index, 57);
					// 380 * 0.15

				}
			}

		//	npc.AddGesture("ACT_CHARGE_END");
			npc.PlaySpecialSound();
			npc.PlaySpecialSound();
			
			if(Zombie_DelayExtraSpeed() < 2.0)
				npc.m_flNextRangedSpecialAttack = gameTime + 30.0;
			
			npc.m_flNextMeleeAttack = gameTime + 6.0;
			float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
			ParticleEffectAt(npc_vec, "hammer_bell_ring_shockwave2", 4.0);
		}
		else if(npc.m_flNextRangedAttack < gameTime)	// Collapse
		{
			KillFeed_SetKillIcon(npc.index, "syringegun_medic");

			int enemy[8];
			GetHighDefTargets(npc, enemy, sizeof(enemy));

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					PredictSubjectPositionForProjectiles(npc, enemy[i], 1300.0, _,vecTarget);

					npc.FireArrow(vecTarget, 57.0, 1300.0);
					// 380 * 0.15
				}
			}

			if(vecTarget[0])
			{
			//	npc.AddGesture("ACT_CHARGE_END");
				npc.PlayRangedSound();
				npc.m_flNextRangedAttack = gameTime + 12.0;
				npc.m_flNextMeleeAttack = gameTime + 4.5;
			}
			else
			{
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
		else
		{
			KillFeed_SetKillIcon(npc.index, "huntsman_flyingburn");
			
			int enemy[2];
			GetHighDefTargets(npc, enemy, sizeof(enemy));

			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					PredictSubjectPositionForProjectiles(npc, enemy[i], 1200.0, _,vecTarget);

					int entity = npc.FireArrow(vecTarget, 57.0, 1200.0, "models/weapons/w_bugbait.mdl");
					// 380 * 0.15

					i_NervousImpairmentArrowAmount[entity] = 12;
					// 380 * 0.2 * 0.15
					
					if(entity != -1)
					{
						if(IsValidEntity(f_ArrowTrailParticle[entity]))
							RemoveEntity(f_ArrowTrailParticle[entity]);
						
						SetEntityRenderColor(entity, 100, 100, 255, 255);
						
						WorldSpaceCenter(entity, vecTarget);
						f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "rockettrail_bubbles", 3.0);
						SetParent(entity, f_ArrowTrailParticle[entity]);
						f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
					}
				}
			}

			if(vecTarget[0])
			{
			//	npc.AddGesture("ACT_CHARGE_END");
				npc.PlayMeleeSound();
				npc.m_flNextMeleeAttack = gameTime + 3.5;
			}
			else
			{
				npc.m_flNextMeleeAttack = gameTime + 0.5;
			}
		}
	}
}

void GetHighDefTargets(UnderTides npc, int[] enemy, int count, bool respectTrace = true, int player_only = 0, int TraceFrom = -1, float RangeLimit = 0.0)
{
	// Prio:
	// 1. Highest Defense Stat
	// 2. Highest NPC Entity Index
	// 3. Random Player
	int TraceEntity = npc.index;
	if(TraceFrom != -1)
	{
		TraceEntity = TraceFrom;
	}
	int team = GetTeam(npc.index);
	float[] def = new float[count];
	float Pos1[3];
	if(RangeLimit > 0.0)
	{
		if(b_ThisEntityIgnored_NoTeam[TraceEntity])
		{
			GetEntPropVector(TraceEntity, Prop_Data, "m_vecAbsOrigin", Pos1);
		}
		else
		{
			WorldSpaceCenter(TraceEntity, Pos1);
		}
	}

	// 0 assumes we only target players
	// 1 assumes we target both
	// 2 assumes we only target npcs
	if(player_only != 2)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetTeam(client) != team && IsEntityAlive(client))
			{
				if(respectTrace && !Can_I_See_Enemy_Only(TraceEntity, client))
					continue;
					
				if(RangeLimit > 0.0)
				{
					float npc_vec[3]; WorldSpaceCenter(client, npc_vec);
					float flDistanceToTarget = GetVectorDistance(npc_vec, Pos1, true);
					if(flDistanceToTarget > RangeLimit)
						continue;
				}

				for(int i; i < count; i++)
				{
					float percentage_ranged = 100.0;
					int i_TheWorld = 0;
					int testvalue = 1;
					int testvalue2 = -1;
					float testvalue1[3];
					int DmgType = DMG_BULLET;

					CheckInHudEnable(1);
					Player_OnTakeDamage(client, i_TheWorld, i_TheWorld, percentage_ranged, DmgType, testvalue2, testvalue1, testvalue1,testvalue);
					CheckInHudEnable(0);

					if(enemy[i])
					{
						if(def[i] < percentage_ranged)
						{
							continue;
						}
					}

					AddToList(client, i, enemy, count);
					AddToList(percentage_ranged, i, def, count);
					break;
				}
			}
		}

	}

	if(player_only == 0 || player_only == 2)
	{
		for(int a; a < i_MaxcountNpcTotal; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
			if(entity != INVALID_ENT_REFERENCE && entity != npc.index)
			{
				if(!view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && GetTeam(entity) != team && IsEntityAlive(entity))
				{
					if(respectTrace && !Can_I_See_Enemy_Only(TraceEntity, entity))
						continue;

					if(RangeLimit > 0.0)
					{
						float npc_vec[3]; WorldSpaceCenter(entity, npc_vec);
						float flDistanceToTarget = GetVectorDistance(npc_vec, Pos1, true);
						if(flDistanceToTarget > RangeLimit)
							continue;
					}

					for(int i; i < count; i++)
					{
						float percentage_ranged = 100.0;
						int testvalue = 1;
						int testvalue2 = -1;
						int attackertestDo = npc.index;
						float testvalue1[3];
						int DmgType = DMG_BULLET;

						CheckInHudEnable(1);
						NPC_OnTakeDamage(entity, attackertestDo, attackertestDo, percentage_ranged, DmgType, testvalue2, testvalue1, testvalue1,testvalue);
						CheckInHudEnable(0);

						if(enemy[i] && def[i] < percentage_ranged)
							continue;

						AddToList(entity, i, enemy, count);
						AddToList(percentage_ranged, i, def, count);
						break;
					}
				}
			}
		}
	}
}

static void AddToList(any data, int pos, any[] list, int count)
{
	for(int i = count - 1; i > pos; i--)
	{
		list[i] = list[i - 1];
	}

	list[pos] = data;
}

void UnderTides_NPCDeath(int entity)
{
	UnderTides npc = view_as<UnderTides>(entity);
	
	npc.PlayDeathSound();

	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	
	Spawns_RemoveFromArray(entity);
	
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(i_ObjectsSpawners[i] == entity)
		{
			i_ObjectsSpawners[i] = 0;
			break;
		}
	}

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
