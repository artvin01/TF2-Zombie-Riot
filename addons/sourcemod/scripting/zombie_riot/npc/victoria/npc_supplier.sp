#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
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

static const char g_HurtSounds[][] =
{
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

static const char g_MeleeAttackSounds[][] = {
	"weapons/barret_arm_zap.wav",
};
static const char g_HealSound[][] = {
	"physics/metal/metal_box_strain1.wav",
};



void VictorianSupplier_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_HealSound)); i++) { PrecacheSound(g_HealSound[i]); }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supplier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_supplier");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_suppliers");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictorianSupplier(vecPos, vecAng, ally);
}
methodmap VictorianSupplier < CClotBody
{
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
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
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound[GetRandomInt(0, sizeof(g_HealSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);

	}
	
	
	public VictorianSupplier(float vecPos[3], float vecAng[3], int ally)
	{
		VictorianSupplier npc = view_as<VictorianSupplier>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "750", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		

		func_NPCDeath[npc.index] = view_as<Function>(VictorianSupplier_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictorianSupplier_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictorianSupplier_ClotThink);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		Is_a_Medic[npc.index] = true;
		npc.m_flArmorToGive = 25.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_winger_pistol/c_winger_pistol.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/scout/scout_hair.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/engineer/drg_brainiac_goggles.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum19_spawn_camper_backpack/sum19_spawn_camper_backpack.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec22_underminers_style1/dec22_underminers_style1.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
	
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable4, 80, 150, 255, 255);
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable5, 80, 150, 255, 255);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		return npc;
	}
}

public void VictorianSupplier_ClotThink(int iNPC)
{
	VictorianSupplier npc = view_as<VictorianSupplier>(iNPC);
	if(npc.m_flNextRangedAttackHappening < GetGameTime())
	{
		npc.m_flNextRangedAttackHappening = GetGameTime() + 5.0;
		IberiaArmorEffect(npc.index, 200.0);
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

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

	if(npc.m_iTargetAlly && !IsValidAlly(npc.index, npc.m_iTargetAlly))
		npc.m_iTargetAlly = 0;
	
	if(!npc.m_iTargetAlly || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);
		if(npc.m_iTargetAlly < 1)
		{
			npc.m_iTargetAlly = GetClosestTarget(npc.index);
		}
		
		if(npc.m_iTargetAlly > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			if(flDistanceToTarget > (100.0*100.0))
			{
				npc.StartPathing();
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_,vPredictedPos );
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetAlly);
				}
			}
			else
			{
				npc.StopPathing();
			}
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	if(npc.m_flNextRangedAttack < GetGameTime(npc.index))
	{
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.00;
		ExpidonsaGroupHeal(npc.index, 100.0, 3, 20.0, 1.0, false,SupplierGiveArmor);
	}
	VictorianSupplierSelfDefense(npc, npc.m_iTarget, GetGameTime(npc.index)); 
}

void VictorianSupplierSelfDefense(VictorianSupplier npc, int target, float gameTime)
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))
	{
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_STAND_SECONDARY");
				npc.m_flSpeed = 0.0;
				npc.StartPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
					npc.PlayMeleeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						float origin[3], angles[3];
						view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
						ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, vecHit, false );
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.25;

						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 5.5;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt *= 3.0;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						}
					}
					delete swingTrace;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_SECONDARY");
				npc.m_flSpeed = 250.0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
	}
}

void SupplierGiveArmor(int entity, int victim)
{
	if(i_NpcIsABuilding[victim])
		return;

	VictorianSupplier npc1 = view_as<VictorianSupplier>(entity);
	GrantEntityArmor(victim, false, 2.0, 0.75, 0,
	npc1.m_flArmorToGive * 0.5);
}

public Action VictorianSupplier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictorianSupplier npc = view_as<VictorianSupplier>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void VictorianSupplier_NPCDeath(int entity)
{
	VictorianSupplier npc = view_as<VictorianSupplier>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
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