#pragma semicolon 1
#pragma newdecls required

static const char NPCModel[] = "models/combine_apc_dynamic.mdl";

methodmap MedivalTrebuchet < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll("weapons/stinger_fire1.wav", this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public MedivalTrebuchet(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		MedivalTrebuchet npc = view_as<MedivalTrebuchet>(CClotBody(vecPos, vecAng, NPCModel, "0.85", "5000", ally));
		i_NpcInternalId[npc.index] = MEDIVAL_TREBUCHET;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_Think, MedivalTrebuchet_ClotThink);
		
		npc.m_iState = 0;
		npc.m_flSpeed = 150.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.25;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void MedivalTrebuchet_ClotThink(int iNPC)
{
	MedivalTrebuchet npc = view_as<MedivalTrebuchet>(iNPC);
	
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
	
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
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
				
				PF_SetGoalVector(npc.index, vPredictedPos);
			} else {
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
	
			//Target close enough to hit
			//if((flDistanceToTarget < 10000 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
			
			{
			//	npc.FaceTowards(vecTarget, 1000.0);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						//Target close enough to hit
						if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, PrimaryThreatIndex)))
						{
							npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
							npc.m_flAttackHappens = GetGameTime(npc.index)+2.4;
							npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+2.54;
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 4.0;
							npc.m_flAttackHappenswillhappen = true;
							PF_StopPathing(npc.index);
							npc.m_bPathing = false;
						}
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.FireRocket(vecTarget, 500.0, 600.0);
						npc.PlayMeleeSound();
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
			if (npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

void MedivalTrebuchet_NPCDeath(int entity)
{
	MedivalTrebuchet npc = view_as<MedivalTrebuchet>(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, MedivalTrebuchet_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
}