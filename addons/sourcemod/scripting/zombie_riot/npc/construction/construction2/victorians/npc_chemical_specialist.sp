#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")vo/engineer_negativevocalization01.mp3",
	")vo/engineer_negativevocalization02.mp3",
	")vo/engineer_negativevocalization03.mp3",
	")vo/engineer_negativevocalization04.mp3",
	")vo/engineer_negativevocalization05.mp3",
	")vo/engineer_negativevocalization06.mp3",
	")vo/engineer_negativevocalization07.mp3",
	")vo/engineer_negativevocalization08.mp3",
	")vo/engineer_negativevocalization09.mp3",
	")vo/engineer_negativevocalization10.mp3",
	")vo/engineer_negativevocalization11.mp3",
	")vo/engineer_negativevocalization12.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};


static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_mvm_mannhattan_gate_atk01.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk02.mp3",
	"vo/engineer_mvm_mannhattan_gate_atk03.mp3",
};

static const char g_RangeAttackSounds[] = "weapons/ar2/fire1.wav";

void Chemical_Specialist_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chemical Specialist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chemical_specialist");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_shotgunner");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/engineer.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Chemical_Specialist(vecPos, vecAng, ally);
}

methodmap Chemical_Specialist < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound() 
	{
		EmitSoundToAll(g_RangeAttackSounds[GetRandomInt(0, sizeof(g_RangeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 85);
	}
	
	public Chemical_Specialist(float vecPos[3], float vecAng[3], int ally)
	{
		Chemical_Specialist npc = view_as<Chemical_Specialist>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "7500", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = Chemical_Specialist_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Chemical_Specialist_OnTakeDamage;
		func_NPCThink[npc.index] = Chemical_Specialist_ClotThink;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "panic_attack");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 230.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_pro_smg/c_pro_smg.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_uberneedle/c_uberneedle.mdl");
        SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/invasion_life_support_system/invasion_life_support_system.mdl");
        SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_mannhattan_protect/hwn2024_mannhattan_protect.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_nuclear_necessity/hwn2024_nuclear_necessity.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_contaminated_carryall/hwn2024_contaminated_carryall.mdl");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		
		return npc;
	}
}

static void Chemical_Specialist_ClotThink(int iNPC)
{
	Chemical_Specialist npc = view_as<Chemical_Specialist>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_bAllowBackWalking)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	Elemental_ClearDamage(npc.index);
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(Chemical_SpecialistSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget))
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
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action Chemical_Specialist_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Chemical_Specialist npc = view_as<Chemical_Specialist>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Chemical_Specialist_NPCDeath(int entity)
{
	Chemical_Specialist npc = view_as<Chemical_Specialist>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static int Chemical_SpecialistSelfDefense(Chemical_Specialist npc, float gameTime, int target, float distance)
{
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.5))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangeSound();
				float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
				{
					target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
					ShootLaser(npc.index, "bullet_tracer02_blue", origin, vecHit, false );
					npc.m_flNextMeleeAttack = gameTime + 0.5;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 10.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;
						Elemental_AddNervousDamage(target, npc.index, 25);

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
				}
				delete swingTrace;
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
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
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
		{
			//target is too far, try to close in
			return 0;
		}
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
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