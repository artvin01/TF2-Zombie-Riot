#pragma semicolon 1
#pragma newdecls required

static const char NPCModel[] = "models/combine_apc_dynamic.mdl";

static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/shovel_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void MedivalRam_OnMapStart()
{
	PrecacheModel(NPCModel);
	PrecacheSound("weapons/stinger_fire1.wav");
}

static int Garrison[MAXENTITIES];

methodmap MedivalRam < CClotBody
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
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public MedivalRam(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		MedivalRam npc = view_as<MedivalRam>(CClotBody(vecPos, vecAng, NPCModel, "0.8", "30000", ally, false, true));
		i_NpcInternalId[npc.index] = MEDIVAL_RAM;
		i_NpcWeight[npc.index] = 5;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
		if(data[0])
		{
			Garrison[npc.index] = StringToInt(data);
			if(!Garrison[npc.index])
				Garrison[npc.index] = GetIndexByPluginName(data);
			
			if(Garrison[npc.index] && !ally)
				Zombies_Currently_Still_Ongoing += 6;
		}
		else
		{
			Garrison[npc.index] = 0;
		}
		
		SDKHook(npc.index, SDKHook_Think, MedivalRam_ClotThink);
		
		npc.m_iState = 0;
		npc.m_flSpeed = Garrison[npc.index] ? 170.0 : 150.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDissapearOnDeath = true;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.01;
		
		if(Garrison[npc.index])
		{
			//TODO: Give flag wearable
			npc.m_iWearable1 = -1;
		}
		else
		{
			npc.m_iWearable1 = -1;
		}
		SDKHook(npc.index, SDKHook_Touch, RamTouchDamageTouch);
		
		return npc;
	}
}

public void RamTouchDamageTouch(int entity, int other)
{
	if(IsValidEnemy(entity, other, true, true)) //Must detect camo.
	{
		SDKHooks_TakeDamage(other, entity, entity, 10.0, DMG_CRUSH, -1, _);
	}
}
//TODO 
//Rewrite
public void MedivalRam_ClotThink(int iNPC)
{
	MedivalRam npc = view_as<MedivalRam>(iNPC);
	
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
		if(npc.m_iTarget == -1)
		{
			b_DoNotChangeTargetTouchNpc[npc.index] = 0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
	
			//Target close enough to hit
			if((flDistanceToTarget < 10000 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
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
										SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, Garrison[npc.index] ? 7600.0 : 5500.0, DMG_CLUB, -1, _, vecHit);
									
									// Hit particle
									
									
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
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,_,999999.9, true);
		if(npc.m_iTarget == -1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
//	npc.PlayIdleAlertSound();
}

void MedivalRam_NPCDeath(int entity)
{
	MedivalRam npc = view_as<MedivalRam>(entity);
	if(!npc.m_bGib)
	{
//		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_Think, MedivalRam_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
	
	if(Garrison[entity])
	{
		bool friendly = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2;
		
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		
		for(int i; i < 6; i++)
		{
			Npc_Create(Garrison[entity], -1, pos, ang, friendly);
		}
	}
}
