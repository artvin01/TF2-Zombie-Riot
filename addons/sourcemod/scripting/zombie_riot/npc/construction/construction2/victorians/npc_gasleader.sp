#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_MegaMeleeHitSounds[][] = {
	"items/cart_explode.wav",
};

static const char g_RangeAttackSounds[] = "weapons/pistol/pistol_fire2.wav";

static const char g_MeleeAttackSounds[] = "weapons/demo_sword_swing1.wav";

void Gasleader_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Gasleader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_gasleader");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_aviator");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MegaMeleeHitSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheModel(COMBINE_CUSTOM_MODEL);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Gasleader(vecPos, vecAng, team);
}
methodmap Gasleader < CClotBody
{
	property int m_iAlliesDied
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iAlliesMaxDeath
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flPercentageAngry
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
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
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangeAttackSounds, this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMegaMeleeHitSound() 
	{
		EmitSoundToAll(g_MegaMeleeHitSounds[GetRandomInt(0, sizeof(g_MegaMeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}

	public Gasleader(float vecPos[3], float vecAng[3], int ally)
	{
		Gasleader npc = view_as<Gasleader>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.55", "50000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.SetActivity("ACT_CUSTOM_WALK_EAGLE");
		npc.m_iChanged_WalkCycle = 2;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Gasleader_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Gasleader_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Gasleader_ClotThink);
		//func_NPCDeathForward[npc.index] = Gasleader_AllyDeath;
		
		npc.i_GunMode = 0;
		
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		float MaxAlliesDeath = 50.0;
		MaxAlliesDeath *= MultiGlobalEnemy;
		npc.m_iAlliesMaxDeath = RoundToCeil(MaxAlliesDeath);
		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.5;

		npc.m_flPercentageAngry = 0.0;
		npc.m_iAlliesDied = 0;
		npc.Anger = false;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeScaling = 0.0;	//just a safety net
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("thorns_backpack_1",  "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_contaminated_carryall/hwn2024_contaminated_carryall.mdl");
		SetVariantString("3.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/tw_soldierbot_armor/tw_soldierbot_armor.mdl");
		SetVariantString("1.33");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/soldier/thief_soldier_helmet/thief_soldier_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = ParticleEffectAt_Parent(vecPos, "utaunt_tarotcard_blue_glow", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});

		npc.m_iWearable9 = ParticleEffectAt_Parent(vecPos, "utaunt_poweraura_blue_beam", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		npc.m_iOverlordComboAttack = 0;
		

		return npc;
	}
}

static void Gasleader_ClotThink(int iNPC)
{
	Gasleader npc = view_as<Gasleader>(iNPC);
	float gametime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gametime)
		return;
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	GrantEntityArmor(iNPC, true, 0.33, 0.5, 0); //50% res armor 

	if(npc.Anger == false)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float radius = 500.0;
		GasleaderEffect(npc.index, radius);
		if(gametime > npc.m_flRangedSpecialDelay)
		{
			Explode_Logic_Custom(10.0, -1, npc.index, -1, vecMe, radius, _, 0.75, true, _, false, _, Gasleader_ExplodePost);
			npc.m_flRangedSpecialDelay = gametime + 0.5;
		}
			float VecI[3]; WorldSpaceCenter(npc.index, VecI);
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (!b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetTeam(entitycount) == GetTeam(npc.index) && IsEntityAlive(entitycount))
				{
					static float vecTarget[3]; WorldSpaceCenter(entitycount, vecTarget);
					if(GetVectorDistance(VecI, vecTarget, true) < (350.0 * 350.0))
					{
						ApplyStatusEffect(npc.index, entitycount, "Caffinated", 1.6);
						ApplyStatusEffect(npc.index, entitycount, "Caffinated Drain", 1.6);
					}
				}
			}
		}
	}
	

	if(npc.m_flNextThinkTime > gametime)
		return;
	npc.m_flNextThinkTime = gametime + 0.1;

	if(npc.m_flGetClosestTargetTime <gametime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gametime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//Cooldown is reduced out of range.
		
		switch(GasleaderSelfDefense(npc, GetGameTime(npc.index), flDistanceToTarget))
		{
			case 0:
			{
				if(npc.i_GunMode != 0)
				{
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					KillFeed_SetKillIcon(npc.index, "frontier_kill");
					npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
					SetVariantString("1.5");
					AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					npc.m_iWearable2 = npc.EquipItem("thorns_backpack_1", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					SetVariantString("1.0");
					AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
					SetVariantInt(3);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.i_GunMode=0;
				}
				if(npc.IsOnGround())
				{
					if(npc.m_iChanged_WalkCycle != 0)
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 0;
						npc.m_flSpeed = 250.0;
						npc.SetActivity("ACT_DARIO_WALK");
						npc.StartPathing();
					}	
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 1;
						npc.m_flSpeed = 250.0;
						npc.SetActivity("ACT_DARIO_WALK");
						npc.StartPathing();
					}	
				}
				npc.m_bAllowBackWalking = false;
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
				if(npc.i_GunMode != 0)
				{
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					KillFeed_SetKillIcon(npc.index, "frontier_kill");
					npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
					SetVariantString("1.5");
					AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
					npc.m_iWearable2 = npc.EquipItem("thorns_backpack_1", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					SetVariantString("1.0");
					AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
					SetVariantInt(3);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.i_GunMode=0;
				}
				if(npc.IsOnGround())
				{
					if(npc.m_iChanged_WalkCycle != 0)
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 0;
						npc.m_flSpeed = 250.0;
						npc.SetActivity("ACT_DARIO_WALK");
						npc.StartPathing();
					}	
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 1)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 1;
						npc.m_flSpeed = 250.0;
						npc.SetActivity("ACT_DARIO_WALK");
						npc.StartPathing();
					}	
				}
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
			case 2:
			{
				if(npc.i_GunMode != 1)
				{
					if(IsValidEntity(npc.m_iWearable1))
						RemoveEntity(npc.m_iWearable1);
					KillFeed_SetKillIcon(npc.index, "claidheamohmor");
					npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");
					SetVariantString("1.0");
					SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
					AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					/*
					npc.m_iWearable2 = npc.EquipItem("anim_attachment_LH", "models/weapons/c_models/c_claymore/c_claymore_xmas.mdl");
					SetVariantString("1.0");
					AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
					*/
					SetVariantInt(3);
					AcceptEntityInput(npc.index, "SetBodyGroup");
					npc.i_GunMode=1;
				}
				if(npc.IsOnGround())
				{
					if(npc.m_iChanged_WalkCycle != 2)
					{
						npc.m_bisWalking = true;
						npc.m_iChanged_WalkCycle = 2;
						npc.m_flSpeed = 330.0;
						npc.SetActivity("ACT_CUSTOM_WALK_EAGLE");
						npc.StartPathing();
					}	
				}
				else
				{
					if(npc.m_iChanged_WalkCycle != 3)
					{
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 3;
						npc.m_flSpeed = 330.0;
						npc.SetActivity("ACT_CUSTOM_WALK_EAGLE");
						npc.StartPathing();
					}	
				}
				npc.m_bAllowBackWalking = false;
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
		}
	}
	else
		npc.m_flGetClosestTargetTime = 0.0;

	npc.PlayIdleAlertSound();
}

static Action Gasleader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Gasleader npc = view_as<Gasleader>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flArmorCount <= 0.0 && npc.Anger == false)
	{
		npc.Anger = true;
		npc.m_iChanged_WalkCycle = 2;
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Gasleader_NPCDeath(int entity)
{
	Gasleader npc = view_as<Gasleader>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	

	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);	
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
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

static int GasleaderSelfDefense(Gasleader npc, float gameTime, float distance)
{
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED *3.0 || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_iOverlordComboAttack <= 2)
				{
					/*
					switch(GetRandomInt(0,1))
					{
						case 0:
						{
							npc.AddGesture("ACT_BLADEDANCE_ATTACK_LEFT");
						}
						case 1:
						{
							npc.AddGesture("ACT_MILITIA_ATTACK");
						}
					}
					*/
					npc.AddGesture("ACT_MILITIA_ATTACK");
				}
				else
				{
					npc.AddGesture("ACT_SEABORN_ATTACK_TOOL_1");
				}
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime +0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flAttackHappens_bullshit = gameTime + 0.35;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 20000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float damageDealt = 100.0;
							int ElementalDamage = 30;
							if(NpcStats_VictorianCallToArms(npc.index))
								ElementalDamage *= 2;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt*=10.0;
							if(npc.m_iOverlordComboAttack <= 2)
							{
								npc.m_iOverlordComboAttack++;
								Elemental_AddNervousDamage(target, npc.index, ElementalDamage, true);
								npc.PlayMeleeHitSound();
								npc.m_flNextMeleeAttack = gameTime + 0.5;
							}
							else
							{
								damageDealt *= 3.0;
								npc.m_iOverlordComboAttack = 0;
								ElementalDamage *= 3.1;
								Elemental_AddNervousDamage(target, npc.index, ElementalDamage, true);
								if(IsValidClient(target) && !HasSpecificBuff(target, "Fluid Movement"))
								{
									TF2_StunPlayer(target, 1.5, 0.5, TF_STUNFLAG_SLOWDOWN);
									Client_Shake(target, 0, 25.0, 12.5, 1.5);
								}
								ParticleEffectAt(VecEnemy, "Explosion_ShockWave_01", 0.5);
								npc.m_flNextMeleeAttack = gameTime + 1.0;
							}
							damageDealt *= (npc.m_flPercentageAngry * 5.0) + 1.0;
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);					
						}
					}
				}
				/*
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee))
				{
					for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
					{
						int target = TR_GetEntityIndex(swingTrace);
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 100.0;
							int ElementalDamage = 30;
							if(NpcStats_VictorianCallToArms(npc.index))
								ElementalDamage *= 2;
							if(ShouldNpcDealBonusDamage(target))
								damageDealt*=10.0;
							if(npc.m_iOverlordComboAttack <= 2)
							{
								npc.m_iOverlordComboAttack++;
								Elemental_AddNervousDamage(target, npc.index, ElementalDamage, true);
								npc.PlayMeleeHitSound();
								npc.m_flNextMeleeAttack = gameTime + 0.5;
							}
							else
							{
								damageDealt *= 3.0;
								npc.m_iOverlordComboAttack = 0;
								ElementalDamage *= 3.1;
								Elemental_AddNervousDamage(target, npc.index, ElementalDamage, true);
								if(IsValidClient(target) && !HasSpecificBuff(target, "Fluid Movement"))
								{
									TF2_StunPlayer(target, 1.5, 0.5, TF_STUNFLAG_SLOWDOWN);
									Client_Shake(target, 0, 25.0, 12.5, 1.5);
								}
								npc.m_flNextMeleeAttack = gameTime + 1.0;
							}
							damageDealt *= (npc.m_flPercentageAngry * 5.0) + 1.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						}
					}
				}
				*/
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 0.1;
			}
		}
		return 2;
	}


	if(npc.m_flNextRangedAttack < gameTime)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.AddGesture("ACT_DARIO_ATTACK_GUN_1");
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangedSound();
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 30000.0);
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, { 9999.0, 9999.0, 9999.0 }))
				{
					int target = TR_GetEntityIndex(swingTrace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float origin[3], angles[3];
					view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
					ShootLaser(npc.m_iWearable1, "bullet_tracer02_blue", origin, vecHit, false );

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 75.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 10.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
						if(IsValidEnemy(npc.index, target))
							ApplyStatusEffect(npc.index, target, "Cripple", NpcStats_VictorianCallToArms(npc.index) ? 7.5 : 5.0);
						
					}
					npc.m_flNextRangedAttack = gameTime + 1.0;
				}
				delete swingTrace;
			}
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
				return 0;
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					return 1;
			}
			return 0;
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
				return 0;
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					return 1;
			}
		}
	}
	else
	{
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
			return 0;
		else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
				return 1;
		}
	}
	return 0;
}

void GasleaderEffect(int entity, float range)
{
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 100, 150, 255, 175, 1, 0.1, 5.0, 0.1, 3);	
}

static void Gasleader_ExplodePost(int attacker, int victim, float damage, int weapon)
{
	Elemental_AddNervousDamage(victim, attacker, 3, true);
}

/*
public void Gasleader_AllyDeath(int self, int ally)
{
	Gasleader npc = view_as<Gasleader>(self);

	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}

	float AllyPos[3];
	GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", AllyPos);
	float SelfPos[3];
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", SelfPos);
	float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
	{
		npc.m_iAlliesDied += 1;

		if(npc.m_iAlliesDied >= npc.m_iAlliesMaxDeath)
		{
			npc.m_flPercentageAngry = 1.0;
		}
		else
		{
			npc.m_flPercentageAngry = float(npc.m_iAlliesDied)	/ float(npc.m_iAlliesMaxDeath);
		}
	}
	float flPos[3]; // original
	float flAng[3]; // original
	if(npc.m_flPercentageAngry == 1.0)
	{
		if(IsValidEntity(npc.m_iWearable7))
		{
			RemoveEntity(npc.m_iWearable7);
		}
		if(!IsValidEntity(npc.m_iWearable7))
		{
			npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
			npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "utaunt_poweraura_red_beam", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
		}
	}
	else if(npc.m_flPercentageAngry > 0.5)
	{
		if(!IsValidEntity(npc.m_iWearable7))
		{
			npc.GetAttachment("m_vecAbsOrigin", flPos, flAng);
	
			npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "utaunt_poweraura_blue_beam", npc.index, "m_vecAbsOrigin", {0.0,0.0,0.0});
		}
	}
}
*/