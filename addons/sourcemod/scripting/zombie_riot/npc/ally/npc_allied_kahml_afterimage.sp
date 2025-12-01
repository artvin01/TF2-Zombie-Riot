#pragma semicolon 1
#pragma newdecls required


static const char g_RangedSound[][] = {
	"weapons/gauss/fire1.wav",
};

void AlliedKahmlAbilityOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Kahmlstein");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_allied_kahml_afterimage");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return AlliedKahmlAbility(client, vecPos, vecAng);
}

methodmap AlliedKahmlAbility < CClotBody
{
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedSound[GetRandomInt(0, sizeof(g_RangedSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.9, 100);
	}
	
	public AlliedKahmlAbility(int client, float vecPos[3], float vecAng[3])
	{
		AlliedKahmlAbility npc = view_as<AlliedKahmlAbility>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "100", TFTeam_Red, true));
		
		i_NpcWeight[npc.index] = 999;
		SetEntPropEnt(npc.index,   Prop_Send, "m_hOwnerEntity", client);
		
		int ModelIndex;
		char ModelPath[255];
		int entity, i;
			
		if((i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}
		else
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.index, 21, 71, 171, 125);
		}

		func_NPCDeath[npc.index] = Internal_Npc_NPCDeath;
		func_NPCThink[npc.index] = Internal_Npc_ClotThink;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 0.35;


		SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
		AcceptEntityInput(npc.index, "SetBodyGroup");

		while(TF2U_GetWearable(client, entity, i, "tf_wearable"))
		{
			if(entity == EntRefToEntIndex(Armor_Wearable[client]) || i_WeaponVMTExtraSetting[entity] != -1)
				continue;
				
			if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) != entity || (i_CustomModelOverrideIndex[client] < BARNEY || !b_HideCosmeticsPlayer[client]))
			{
				ModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex");
				if(ModelIndex < 0)
				{
					GetEntPropString(entity, Prop_Data, "m_ModelName", ModelPath, sizeof(ModelPath));
				}
				else
				{
					ModelIndexToString(ModelIndex, ModelPath, sizeof(ModelPath));
				}
			}
			if(!ModelPath[0])
				continue;

			for(int Repeat=0; Repeat<7; Repeat++)
			{
				int WearableIndex = i_Wearable[npc.index][Repeat];
				if(!IsValidEntity(WearableIndex))
				{	
					int WearablePostIndex = npc.EquipItem("head", ModelPath);
					if(IsValidEntity(WearablePostIndex))
					{	
						if(entity == EntRefToEntIndex(i_Viewmodel_PlayerModel[client]))
						{
							SetVariantInt(GetEntProp(client, Prop_Send, "m_nBody"));
							AcceptEntityInput(WearablePostIndex, "SetBodyGroup");
						}
						SetEntityRenderMode(WearablePostIndex, RENDER_TRANSCOLOR); //Make it half invis.
						SetEntityRenderColor(WearablePostIndex, 21, 71, 171, 125);
						i_Wearable[npc.index][Repeat] = EntIndexToEntRef(WearablePostIndex);
					}
					break;
				}
			}
		}
	
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bNoKillFeed = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	

		npc.m_iState = 0;
		npc.m_flSpeed = 450.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		npc.StartPathing();
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);

		return npc;
	}
}

static void Internal_Npc_ClotThink(int iNPC)
{
	AlliedKahmlAbility npc = view_as<AlliedKahmlAbility>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	int owner = GetEntPropEnt(npc.index, Prop_Data, "m_hOwnerEntity");
	if(!IsValidClient(owner))
	{
		SmiteNpcToDeath(iNPC);
		return;
	}
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return;
	}
	//What is owner looking at ?
	
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(owner);
	Handle swingTrace;
	float vecSwingForward[3];
	DoSwingTrace_Custom(swingTrace, owner, vecSwingForward, 9999.0, false, 45.0, true); 
	FinishLagCompensation_Base_boss();
	int target = TR_GetEntityIndex(swingTrace);	
	delete swingTrace;

	if(target > 0)
		npc.m_iTarget = target;
		

	if(!IsValidEnemy(npc.index,npc.m_iTarget))
	{
		npc.m_iTarget = 0;
		//no enemy valid, run back to papa
		float vecTarget[3]; WorldSpaceCenter(owner, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		npc.m_bAllowBackWalking = false;

		if(flDistanceToTarget > (100.0 * 100.0))
		{
			npc.StartPathing();
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, owner,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(owner);
			}
		}
		else
		{
			npc.StopPathing();
		}
	}
	else
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = ChaosKahmlsteinAllySelfDefense(npc, npc.m_iTarget, flDistanceToTarget, owner); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	if(npc.m_flRangedSpecialDelay)
	{
		if(npc.m_flRangedSpecialDelay < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
	}
}

static void Internal_Npc_NPCDeath(int entity)
{
	AlliedKahmlAbility npc = view_as<AlliedKahmlAbility>(entity);

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

	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}


int ChaosKahmlsteinAllySelfDefense(AlliedKahmlAbility npc, int target, float distance, int owner)
{
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.5))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",true, 0.09, _, 4.0);
			npc.PlayRangedSound();
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			int projectile;
			float Proj_Damage = fl_heal_cooldown[npc.index];
			vecTarget[0] += GetRandomFloat(-10.0, 10.0);
			vecTarget[1] += GetRandomFloat(-10.0, 10.0);
			vecTarget[2] += GetRandomFloat(-10.0, 10.0);
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1200.0, 150.0, "raygun_projectile_blue_crit", false,
					_,_,_,EP_DEALS_CLUB_DAMAGE,owner);
				}
				case 2:
				{
					projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1200.0, 150.0, "raygun_projectile_red_crit", false,
					_,_,_,EP_DEALS_CLUB_DAMAGE,owner);
				}
			}
			
			
			float fAng[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", fAng);
			Initiate_HomingProjectile(projectile,
				npc.index,
					180.0,			// float lockonAngleMax,
					90.0,				//float homingaSec,
					true,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					fAng,
					npc.m_iTarget);			// float AnglesInitiate[3]);
			TriggerTimerHoming(projectile);
			
		}
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
		return 0;
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			if(Can_I_See_Enemy_Only(npc.index, target))
			{
				//target is too close, try to keep distance
				return 1;
			}
		}
	}
	return 0;
}
