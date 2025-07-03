#pragma semicolon 1
#pragma newdecls required

static const char NPCModel[] = "models/humans/group01/male_07.mdl";

static const char g_MeleeHitSounds[][] = {
	"npc/stalker/go_alert2a.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/shovel_swing.wav",
};

void Male07_OnMapStart()
{
	PrecacheModel(NPCModel);
	PrecacheSound("weapons/stinger_fire1.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Male 07");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_male07");
	strcopy(data.Icon, sizeof(data.Icon), "male07");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/aprilfools/male07_chase.mp3");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Male07(vecPos, vecAng, team, data);
}
static int Garrison[MAXENTITIES];

methodmap Male07 < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}

	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public Male07(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Male07 npc = view_as<Male07>(CClotBody(vecPos, {0.0, 0.0, 0.0}, NPCModel, "1.0", "30000", ally, false, true));
		i_NpcWeight[npc.index] = 5;

		int iActivity = npc.LookupActivity("ACT_RUN_PANICKED");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
		if(data[0])
		{
			Garrison[npc.index] = StringToInt(data);
			if(!Garrison[npc.index])
				Garrison[npc.index] = NPC_GetByPlugin(data);
			
			if(Garrison[npc.index] && !ally)
				Zombies_Currently_Still_Ongoing += 6;
		}
		else
		{
			Garrison[npc.index] = 0;
		}

		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(!b_IsPlayerABot[client1] && IsClientInGame(client1) && !IsFakeClient(client1))
			{
				SetMusicTimer(client1, GetTime() + 1); //This is here beacuse of raid music.
				Music_Stop_All(client1);
			}
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/male07_chase.mp3");
		music.Time = 59;
		music.Volume = 1.8;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "it's Male07");
		strcopy(music.Artist, sizeof(music.Artist), "Holy fuck");
		Music_SetRaidMusic(music);
		
		func_NPCDeath[npc.index] = Male07_NPCDeath;
		func_NPCThink[npc.index] = Male07_ClotThink;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 320.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDissapearOnDeath = false;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;

		int entity = CreateEntityByName("light_dynamic");
		if(entity != -1)
		{
			vecPos[2] += 40.0;
			TeleportEntity(entity, vecPos, vecAng, NULL_VECTOR);
			
			DispatchKeyValue(entity, "brightness", "7");
			DispatchKeyValue(entity, "spotlight_radius", "180");
			DispatchKeyValue(entity, "distance", "180");
			DispatchKeyValue(entity, "_light", "255 0 0 255");
			//DispatchKeyValue(entity, "_cone", "-1");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", npc.index);
			AcceptEntityInput(entity, "LightOn");
			b_EntityCantBeColoured[entity] = true;
		}
		
		npc.m_flMeleeArmor = 0.50;
		npc.m_flRangedArmor = 0.50;
		
		if(Garrison[npc.index])
		{
			//TODO: Give flag wearable
			npc.m_iWearable1 = -1;
		}
		else
		{
			npc.m_iWearable1 = -1;
		}
		SDKHook(npc.index, SDKHook_Touch, MaleTouchDamageTouch);
		
		return npc;
	}
}

public void MaleTouchDamageTouch(int entity, int other)
{
	if(IsValidEnemy(entity, other, true, true)) //Must detect camo.
	{
		SDKHooks_TakeDamage(other, entity, entity, 10.0, DMG_CRUSH, -1, _);
	}
}

public Action Male07_RemoveOverlay(Handle helpmeimblind, int id)
{
	int client = GetClientOfUserId(id);
	if (IsValidClient(client))
		DoOverlay(client, "");
		
	return Plugin_Continue;
}

public void Male07_ClotThink(int iNPC)
{
	Male07 npc = view_as<Male07>(iNPC);
	
	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		if(npc.m_iTarget < 1)
		{
			b_DoNotChangeTargetTouchNpc[npc.index] = 0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
	
			//Target close enough to hit
			if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									if(!ShouldNpcDealBonusDamage(target))
										SDKHooks_TakeDamage(target, npc.index, npc.index, 5000.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, Garrison[npc.index] ? 7600.0 : 5500.0, DMG_CLUB, -1, _, vecHit);
									
									// Hit particle

									if(target <= MaxClients)
									{
										DoOverlay(target, "zombie_riot/male07/jumpscare_male07", 0);
										CreateTimer(5.0, Male07_RemoveOverlay, GetClientUserId(target), TIMER_FLAG_NO_MAPCHANGE);
									}
									
									
									// Hit sound
									ParticleEffectAt(vecHit, "skull_island_embers", 2.0);
									npc.PlayMeleeHitSound();
								} 
							}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
			if (npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
//	npc.PlayIdleAlertSound();
}

void Male07_NPCDeath(int entity)
{
	Male07 npc = view_as<Male07>(entity);
	if(!npc.m_bGib)
	{
//		npc.PlayDeathSound();	
	}
	
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
}


public Action Male_Spawner_Delay(Handle timer, DataPack pack)
{
	GiveProgressDelay(1.0);
	//Keep waiting.
	if(MaxEnemiesAllowedSpawnNext(1) < (EnemyNpcAlive - EnemyNpcAliveStatic))
		return Plugin_Continue;

	pack.Reset();
	int ParticleEffect = EntRefToEntIndex(pack.ReadCell());
	int GarrisonType = pack.ReadCell();
	float pos[3];
	pack.ReadFloatArray(pos, sizeof(pos));
	float ang[3];
	pack.ReadFloatArray(ang, sizeof(pos));
	int Team = pack.ReadCell();

	NPC_CreateById(GarrisonType, -1, pos, ang, Team);
	if(IsValidEntity(ParticleEffect))
		RemoveEntity(ParticleEffect);
	return Plugin_Stop;
}
