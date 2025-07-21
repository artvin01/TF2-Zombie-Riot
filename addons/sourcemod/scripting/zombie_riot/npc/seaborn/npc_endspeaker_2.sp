#pragma semicolon 1
#pragma newdecls required

methodmap EndSpeaker2 < EndSpeakerSmall
{
	public EndSpeaker2(int ally)
	{
		float vecPos[3], vecAng[3];
		view_as<EndSpeaker>(0).GetSpawn(vecPos, vecAng);

		char health[12];
		IntToString(view_as<EndSpeaker>(0).m_iBaseHealth * 3, health, sizeof(health));

		EndSpeaker2 npc = view_as<EndSpeaker2>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.35", health, ally, false));
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_RUN");
		npc.AddGesture("ACT_HEADCRAB_BURROW_OUT");

		npc.EatBuffs();
		npc.PlaySpawnSound();
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		npc.m_bDissapearOnDeath = true;
		
		func_NPCDeath[npc.index] = EndSpeaker2_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = EndSpeaker_OnTakeDamage;
		func_NPCThink[npc.index] = EndSpeaker2_ClotThink;
		
		npc.m_flSpeed = 200.0;	// 0.8 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.45;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 155, 255, 200, 255);

		if(!npc.m_bHardMode && ally != TFTeam_Red && !IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime() + 9000.0;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0) //Dont show scaling if theres none.
				RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		return npc;
	}
}

public void EndSpeaker2_ClotThink(int iNPC)
{
	EndSpeaker2 npc = view_as<EndSpeaker2>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, npc.m_bIgnoreBuildings, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(npc.m_flAttackHappens)
		{
			npc.FaceTowards(vecTarget, 15000.0);
			
			if(npc.m_flAttackHappens < gameTime)
			{
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0, _,vecTarget);

				npc.m_flAttackHappens = 0.0;
				
				float attack = (npc.m_bHardMode ? 229.5 : 204.0) * npc.Attack(gameTime);
				// 800 x 0.85 x 0.3
				// 900 x 0.85 x 0.3

				int entity = -1;
				if(npc.m_hBuffs & BUFF_SPEWER)
				{
					KillFeed_SetKillIcon(npc.index, "syringegun_medic");
					npc.FireRocket(vecTarget, attack, 1200.0, "models/weapons/w_bugbait.mdl");
				}
				else
				{
					KillFeed_SetKillIcon(npc.index, "huntsman_flyingburn");
					entity = npc.FireArrow(vecTarget, attack, 1200.0, "models/weapons/w_bugbait.mdl");
				}

				i_NervousImpairmentArrowAmount[entity] = RoundToCeil(attack * 0.6);
				// 800 x 0.85 x 0.6 x 0.3
				// 900 x 0.85 x 0.6 x 0.3

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

		if(distance < 129600.0 && npc.m_flNextMeleeAttack < gameTime)	// 1.8 * 200
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target, true))
			{
				npc.m_iTarget = target;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_RANGE_ATTACK_1");
				
				npc.m_flAttackHappens = gameTime + 0.45;

				npc.m_flDoingAnimation = gameTime + 1.25;
				npc.m_flNextMeleeAttack = gameTime + 2.0;
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}

			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}
}

void EndSpeaker2_NPCDeath(int entity)
{
	EndSpeaker2 npc = view_as<EndSpeaker2>(entity);
	
	npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);

	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	float pos[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	npc.SetSpawn(pos, angles);
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
		DispatchKeyValue(entity_death, "model", "models/headcrabclassic.mdl");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.5); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("BurrowIn");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", EndSpeaker_BurrowAnim, true);

		SetEntityRenderColor(entity_death, 155, 255, 200, 255);
	}
}