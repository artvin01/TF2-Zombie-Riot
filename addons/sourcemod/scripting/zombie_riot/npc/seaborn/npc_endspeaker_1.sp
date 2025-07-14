#pragma semicolon 1
#pragma newdecls required

methodmap EndSpeaker1 < EndSpeakerSmall
{
	public EndSpeaker1(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		EndSpeaker1 npc = view_as<EndSpeaker1>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.0", "1200", ally, false, _, true));
		// 10000 x 0.4 x 0.3

		i_NpcWeight[npc.index] = 0;
		npc.SetActivity("ACT_RUN");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		npc.m_bDissapearOnDeath = true;
		npc.m_bHardMode = view_as<bool>(data[0]);
		
		func_NPCDeath[npc.index] = EndSpeaker1_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = EndSpeaker_OnTakeDamage;
		func_NPCThink[npc.index] = EndSpeaker1_ClotThink;
		
		npc.m_flSpeed = 250.0;	// 0.8 + 0.2 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

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

public void EndSpeaker1_ClotThink(int iNPC)
{
	EndSpeaker1 npc = view_as<EndSpeaker1>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	npc.m_iBaseHealth = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) / 0.4);

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, true, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(distance < npc.GetLeadRadius())
		{
			PredictSubjectPosition(npc, npc.m_iTarget, _,_,vecTarget);
			npc.SetGoalVector(vecTarget);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
	}
}

void EndSpeaker1_NPCDeath(int entity)
{
	EndSpeaker1 npc = view_as<EndSpeaker1>(entity);
	
	npc.PlayDeathSound();

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
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("BurrowIn");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", EndSpeaker_BurrowAnim, true);

		SetEntityRenderColor(entity_death, 100, 100, 255, 255);
	}
}