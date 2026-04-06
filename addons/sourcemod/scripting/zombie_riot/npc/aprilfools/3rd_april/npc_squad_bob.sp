#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"common/null.wav",
};

static const char g_HurtSounds[][] = {
	"common/null.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"common/null.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/saxxy_turntogold_05.wav"
};
static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};


int SquadX_BobId;
int SquadX_BobIDReturn()
{
	return SquadX_BobId;
}

void SquadX_Bob_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob The First Squad");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_squad_bob");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	SquadX_BobId = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SquadX_Bob(vecPos, vecAng, team);
}

methodmap SquadX_Bob < CClotBody
{
	property float m_flTransformIn
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property int m_iSaiyanState
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property float m_flPowAbilityCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flKickComboCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property bool b_SwordIgnition
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 10.0);	
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public SquadX_Bob(float vecPos[3], float vecAng[3], int ally)
	{
		SquadX_Bob npc = view_as<SquadX_Bob>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "40000", ally, _, _, true, false));
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_RUN_BOB");
		
		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		npc.m_flMeleeArmor = 1.25;	
		b_NpcUnableToDie[npc.index] = true;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		npc.m_bDissapearOnDeath = true;

		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		IgniteTargetEffect(npc.m_iWearable1);
		npc.b_SwordIgnition = true;
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;

		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	SquadX_Bob npc = view_as<SquadX_Bob>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	npc.PlayIdleAlertSound();
	
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = Clot_SelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

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

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		Clot_AnimationChange(npc);
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SquadX_Bob npc = view_as<SquadX_Bob>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
	if(health < 1)
	{
		ApplyStatusEffect(victim, victim, "Terrified", 9999.0);
	}
	
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	SquadX_Bob npc = view_as<SquadX_Bob>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

static void Clot_AnimationChange(SquadX_Bob npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}

	if (npc.IsOnGround())
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			if(!npc.b_SwordIgnition)
			{
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				IgniteTargetEffect(npc.m_iWearable1);
				npc.b_SwordIgnition = true;
			}
			RemoveSpecificBuff(npc.index, "Defensive Backup");
			npc.m_flSpeed = 330.0;
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_RUN_BOB");
			npc.StartPathing();
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			if(!npc.b_SwordIgnition)
			{
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				IgniteTargetEffect(npc.m_iWearable1);
				npc.b_SwordIgnition = true;
			}
			RemoveSpecificBuff(npc.index, "Defensive Backup");
			npc.m_flSpeed = 330.0;
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_RUN_BOB");
			npc.StartPathing();
		}	
	}

}

static int Clot_SelfDefense(SquadX_Bob npc, float gameTime, int target, float distance)
{
	if(npc.m_iAttackType <= 0 && npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,_,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 20.0;

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
								
							
							// Hit particle

							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
							float VulnerabilityToGive = 0.20;
							IncreaseEntityDamageTakenBy(targetTrace, VulnerabilityToGive, 10.0, true);
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	else if(npc.m_iAttackType > 0)
	{
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float damage = 60.0 * RaidModeScaling;

		switch(npc.m_iAttackType)
		{
			case 2:	// COMBO1 - Frame 44
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.999, damage * 2.0, true);
					
					npc.m_iAttackType = 3;
					npc.m_flAttackHappens = gameTime + 0.899;
					npc.m_flDoingAnimation = gameTime + 0.899;
				}
			}
			case 3:	// COMBO1 - Frame 54
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.5, damage, false);
					
					npc.m_iAttackType = -1;
					npc.m_flAttackHappens = gameTime + 1.555;
					npc.m_flDoingAnimation = gameTime + 1.555;
				}
			}
			case 4:	// COMBO2 - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.833, damage, false);
					
					npc.m_iAttackType = 5;
					npc.m_flAttackHappens = gameTime + 0.833;
					npc.m_flDoingAnimation = gameTime + 0.833;
				}
			}
			case 5:	// COMBO2 - Frame 52
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.833, damage, false);
					
					npc.m_iAttackType = 6;
					npc.m_flAttackHappens = gameTime + 0.833;
					npc.m_flDoingAnimation = gameTime + 0.833;
				}
			}
			case 6:	// COMBO2 - Frame 73
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.875, damage, true);
					
					npc.m_iAttackType = -1;
					npc.m_flAttackHappens = gameTime + 1.083;
					npc.m_flDoingAnimation = gameTime + 1.083;
				}
			}
		}
	}
	else if(npc.m_flNextMeleeAttack < gameTime && npc.m_flKickComboCooldown < gameTime)
	{
		//do big slap attack
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float damage = 60.0 * RaidModeScaling;

		npc.m_flKickComboCooldown = gameTime + 15.0;
		npc.m_iChanged_WalkCycle = 200;
		ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 99.0);
		if(npc.b_SwordIgnition)
		{
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			ExtinguishTarget(npc.m_iWearable1);
			npc.b_SwordIgnition = false;
		}
		switch(GetURandomInt() % 3)
		{
			case 0:
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
				npc.SetActivity("ACT_COMBO1_BOBPRIME");
				npc.m_iAttackType = 2;
				npc.m_flAttackHappens = gameTime + 0.916;
				npc.m_flDoingAnimation = gameTime + 0.916;
				
				BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.916, damage, true);
			}
			case 1:
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
				npc.SetActivity("ACT_COMBO2_BOBPRIME");
				npc.m_iAttackType = 4;
				npc.m_flAttackHappens = gameTime + 0.5;
				npc.m_flDoingAnimation = gameTime + 0.5;
				
				BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 0.5, damage, false);
			}
			case 2:
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
				npc.SetActivity("ACT_COMBO3_BOBPRIME");
				npc.m_flAttackHappens = gameTime + 3.25;
				npc.m_flDoingAnimation = gameTime + 3.25;
				npc.m_iAttackType = -1;
				
				BobInitiatePunch(npc.index, vecTarget, VecSelfNpc, 2.125, damage * 3.0, true);
				ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 3.25);
			}
		}
	}
	//Melee attack, last prio
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MELEE_BOB");
							
					npc.m_flAttackHappens = gameTime + 0.15;
					npc.m_flNextMeleeAttack = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.15;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	return 0;
}