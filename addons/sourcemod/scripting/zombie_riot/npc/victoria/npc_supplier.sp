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

static const char g_RangeAttackSounds[] = "weapons/barret_arm_zap.wav";

static const char g_HealSound[] = "physics/metal/metal_box_strain1.wav";

void VictorianSupplier_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supplier");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_supplier");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_suppliers");
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
	PrecacheSound(g_HealSound);
	PrecacheModel("models/player/engineer.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictorianSupplier(vecPos, vecAng, ally, data);
}

methodmap VictorianSupplier < CClotBody
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
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHealSound() 
	{
		EmitSoundToAll(g_HealSound, this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 110);
	}
	
	property float m_flArmorToGive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flExtraArmorResist
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flLootTheEnemy
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	public VictorianSupplier(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictorianSupplier npc = view_as<VictorianSupplier>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "750", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		

		func_NPCDeath[npc.index] = VictorianSupplier_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictorianSupplier_OnTakeDamage;
		func_NPCThink[npc.index] = VictorianSupplier_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "pistol");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		Is_a_Medic[npc.index] = true;
		npc.m_flArmorToGive = 25.0;
		npc.m_flExtraArmorResist = 0.75;
		npc.m_flLootTheEnemy = 0.0;
		
		//Maybe used for special waves
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "armor") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "armor", "");
				npc.m_flArmorToGive = StringToFloat(countext[i]);
			}
			else if(StrContains(countext[i], "resist") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "resist", "");
				npc.m_flExtraArmorResist = StringToFloat(countext[i]);
			}
		}
		
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

static void VictorianSupplier_ClotThink(int iNPC)
{
	VictorianSupplier npc = view_as<VictorianSupplier>(iNPC);
	if(npc.m_flNextRangedAttackHappening < GetGameTime(npc.index))
	{
		npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 5.0;
		if(NpcStats_VictorianCallToArms(npc.index))
			IberiaArmorEffect(npc.index, 300.0);
		else
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
	
	if(GetGameTime(npc.index) > npc.m_flLootTheEnemy)
		npc.m_bAllowBackWalking = false;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
			npc.m_iTargetAlly = GetClosestAlly(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget)||IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(VictorianSupplier_Work(npc, GetGameTime(npc.index)))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 280.0;
					npc.m_iChanged_WalkCycle = 0;
				}
				WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
				flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetAlly,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTargetAlly);
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.StopPathing();
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 0.0;
					npc.m_iChanged_WalkCycle = 1;
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.m_flSpeed = 280.0;
					npc.m_iChanged_WalkCycle = 2;
				}
				if(flDistanceToTarget < npc.GetLeadRadius())
				{
					float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else
					npc.SetGoalEntity(npc.m_iTarget);
			}
		}
	}
	if(npc.m_flNextRangedAttack < GetGameTime(npc.index))
	{
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.00;
		if(NpcStats_VictorianCallToArms(npc.index))
			ExpidonsaGroupHeal(npc.index, 100.0, 3, (50.0* fl_Extra_Damage[npc.index]), 1.0, false,SupplierGiveArmorSignalled);
		else
			ExpidonsaGroupHeal(npc.index, 100.0, 3, (25.0* fl_Extra_Damage[npc.index]), 1.0, false,SupplierGiveArmor);
	}
}

static int VictorianSupplier_Work(VictorianSupplier npc, float gameTime)
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
	if(IsValidEnemy(npc.index,GetClosestEnemyToAttack))
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, GetClosestEnemyToAttack);
			WorldSpaceCenter(Enemy_I_See, vecTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(IsValidEnemy(npc.index, Enemy_I_See) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
			{	
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
				npc.PlayRangeSound();
				npc.m_bAllowBackWalking = true;
				npc.FaceTowards(vecTarget, 20000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, Enemy_I_See, { 9999.0, 9999.0, 9999.0 }))
				{
					int target = TR_GetEntityIndex(swingTrace);
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue_crit", origin, vecHit, false );
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 5.5;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;

						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
					npc.m_flNextMeleeAttack = gameTime + 0.25;
					npc.m_flLootTheEnemy = gameTime + 1.0;
				}
				delete swingTrace;
			}
		}
	}
	if(IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		WorldSpaceCenter(npc.m_iTargetAlly, vecTarget);
		return (GetVectorDistance(vecTarget, VecSelfNpc, true) > (68.0*68.0) ? 0 : 1);
	}
	else if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		return (GetVectorDistance(vecTarget, VecSelfNpc, true) > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0) && Can_I_See_Enemy_Only(npc.index, npc.m_iTarget)) ? 2 : 1;
	}
	else
		return 1;
}

static void SupplierGiveArmor(int entity, int victim)
{
	if(i_NpcIsABuilding[victim])
		return;

	VictorianSupplier npc = view_as<VictorianSupplier>(entity);
	GrantEntityArmor(victim, false, 2.0, npc.m_flExtraArmorResist, 0,
	(npc.m_flArmorToGive * 0.5) * fl_Extra_Damage[npc.index]);
}

static void SupplierGiveArmorSignalled(int entity, int victim)
{
	if(i_NpcIsABuilding[victim])
		return;

	VictorianSupplier npc = view_as<VictorianSupplier>(entity);
	GrantEntityArmor(victim, false, 2.0, npc.m_flExtraArmorResist, 0,
	(npc.m_flArmorToGive * 0.75) * fl_Extra_Damage[npc.index]);
}

static Action VictorianSupplier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

static void VictorianSupplier_NPCDeath(int entity)
{
	VictorianSupplier npc = view_as<VictorianSupplier>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
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