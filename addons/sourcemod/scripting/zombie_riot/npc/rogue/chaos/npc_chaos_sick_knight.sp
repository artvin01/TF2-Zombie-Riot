#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")npc/combine_soldier/die1.wav",
	")npc/combine_soldier/die2.wav",
	")npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")npc/combine_soldier/pain1.wav",
	")npc/combine_soldier/pain2.wav",
	")npc/combine_soldier/pain3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"misc/halloween/strongman_fast_swing_01.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};

static const char g_RangedAttackSounds[][] = {
	"player/souls_receive1.wav",
	"player/souls_receive2.wav",
	"player/souls_receive3.wav",
};

static const char g_RangedHitSounds[][] = {
	"weapons/cow_mangler_main_shot.wav",
};
static const char g_CoughRandom[][] = {
	"ambient/voices/cough1.wav",
	"ambient/voices/cough2.wav",
	"ambient/voices/cough3.wav",
	"ambient/voices/cough4.wav",
};


void ChaosSickKnight_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedHitSounds)); i++) { PrecacheSound(g_RangedHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_CoughRandom)); i++) { PrecacheSound(g_CoughRandom[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Knight?");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_sick_knight");
	strcopy(data.Icon, sizeof(data.Icon), "chaos_knight");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_BlueParadox; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosSickKnight(vecPos, vecAng, team);
}
methodmap ChaosSickKnight < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}

	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 115);
	}
	public void PlayRangedHitSound() 
	{
		EmitSoundToAll(g_RangedHitSounds[GetRandomInt(0, sizeof(g_RangedHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 145);
	}
	property float m_flAttackHappensBall
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flAttackHappensBallCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flHeavyResPhase
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flHeavyResPhaseCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	property float m_flViolentCaughingCooldown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flViolentCaughing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flCoughSoundCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	public void PlayCoughSound() 
	{
		if(this.m_flCoughSoundCD > GetGameTime(this.index))
			return;
			
		this.m_flCoughSoundCD = GetGameTime(this.index) + 1.0;

		EmitSoundToAll(g_CoughRandom[GetRandomInt(0, sizeof(g_CoughRandom) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public ChaosSickKnight(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosSickKnight npc = view_as<ChaosSickKnight>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.85", "1500", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int iActivity = npc.LookupActivity("ACT_ROGUE2_CHAOS_KNIGHT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChaosSickKnight_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChaosSickKnight_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChaosSickKnight_ClotThink);
		
		
		
		npc.m_flHeavyResPhaseCooldown = GetGameTime() + 10.0;
		npc.m_flViolentCaughingCooldown = GetGameTime() + 30.0;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/demo/jul13_pillagers_barrel/jul13_pillagers_barrel.mdl");
		SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_flModelScale", 1.25);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 50, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable1, 50, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable2, 50, 50, 50, 255);
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {0.0,-10.0,-10.0});
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {0.0,0.0,-15.0});
		return npc;
	}
}

public void ChaosSickKnight_ClotThink(int iNPC)
{
	ChaosSickKnight npc = view_as<ChaosSickKnight>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
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

	if(npc.m_flViolentCaughingCooldown < GetGameTime(npc.index))
	{
		npc.m_flViolentCaughing = GetGameTime(npc.index) + 7.5;
		npc.m_flViolentCaughingCooldown = GetGameTime() + 45.0;
	}
	if(npc.m_flViolentCaughing)
	{
		fl_TotalArmor[npc.index] = 0.5;
		if(npc.m_iChanged_WalkCycle != 6)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 6;
			npc.SetActivity("ACT_ROGUE2_CHAOS_KNIGHT_COUGHING");
			npc.SetPlaybackRate(0.75);
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
		npc.PlayCoughSound();
		if(npc.m_flViolentCaughing < GetGameTime(npc.index))
		{
			fl_TotalArmor[npc.index] = 1.0;
			npc.m_flViolentCaughing = 0.0;
		}
		return;
	}
	if(npc.m_flHeavyResPhase)
	{
		fl_TotalArmor[npc.index] = 0.15;
		float maxhealth = float(ReturnEntityMaxHealth(npc.index));
		maxhealth *= 0.005;
		HealEntityGlobal(npc.index, npc.index, maxhealth, 1.0, 0.0, HEAL_SELFHEAL);
		float ProjLoc[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
		ProjLoc[2] += 70.0;

		ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
		ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
		ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
		TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
		if(npc.m_flHeavyResPhase < GetGameTime(npc.index))
		{
			fl_TotalArmor[npc.index] = 1.0;
			npc.m_flHeavyResPhase = 0.0;
		}
	}
	
	//default fight animation, set whenever no ability is in use.
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_ROGUE2_CHAOS_KNIGHT_WALK");
			npc.StartPathing();
			npc.m_flSpeed = 300.0;
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		ChaosSickKnightSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ChaosSickKnight_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosSickKnight npc = view_as<ChaosSickKnight>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ChaosSickKnight_NPCDeath(int entity)
{
	ChaosSickKnight npc = view_as<ChaosSickKnight>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
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

void ChaosSickKnightSelfDefense(ChaosSickKnight npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 450.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 10.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddChaosDamage(target, npc.index, 200, false, true);
					if(target <= MaxClients)
						Client_Shake(target, 0, 25.0, 25.0, 0.5, false);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}
	if(npc.m_flAttackHappensBall)
	{
		if(npc.m_flAttackHappensBall < gameTime)
		{
			npc.m_flAttackHappensBall = 0.0;
		
			float projectile_speed = 1000.0;
			float vecTarget[3];
			float DamageProject = 400.0;
			npc.PlayRangedHitSound();
			PredictSubjectPositionForProjectiles(npc, target, projectile_speed,_,vecTarget);
			npc.FaceTowards(vecTarget, 15000.0);
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);

			int entity = npc.FireArrow(vecTarget, DamageProject, projectile_speed, ENERGY_BALL_MODEL);
			
			npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("LHand"), PATTACH_POINT_FOLLOW, true);

			if(entity != -1)
			{
				if(IsValidEntity(f_ArrowTrailParticle[entity]))
					RemoveEntity(f_ArrowTrailParticle[entity]);
				
				SetEntityRenderColor(entity, 200, 0, 200, 255);
				
				WorldSpaceCenter(entity, vecTarget);
				f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "flaregun_energyfield_blue", 5.0);
				SetParent(entity, f_ArrowTrailParticle[entity]);
				f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);

				i_ChaosArrowAmount[entity] = RoundToCeil(DamageProject);
			}
		}
	}

	if(npc.m_flDoingAnimation < gameTime && gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime + 0.6;
				npc.m_flDoingAnimation = gameTime + 0.6;
				switch(GetRandomInt(1,3))
				{
					case 1:
					{
						npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ATTACK1");
					}
					case 2:
					{
						npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ATTACK2");
						npc.m_flAttackHappens = gameTime + 0.8;
						npc.m_flDoingAnimation = gameTime + 0.8;
					}
					case 3:
					{
						npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ATTACK3");
					}
				}
				npc.m_flNextMeleeAttack = gameTime + 1.25;
			}
		}
		else if(npc.m_flDoingAnimation < gameTime && gameTime > npc.m_flAttackHappensBallCooldown)
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangedSound();
				npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ABILITY2");
				float flPos[3], flAng[3];
				npc.GetAttachment("LHand", flPos, flAng);
				npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "flaregun_energyfield_blue", npc.index, "LHand", {0.0,0.0,0.0});
						
				npc.m_flAttackHappensBall = gameTime + 1.1;
				npc.m_flDoingAnimation = gameTime + 1.9;
				npc.m_flAttackHappensBallCooldown = gameTime + 2.5;
			}
		}
	}
	else
	{
		
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
		{ 
			if(npc.m_flDoingAnimation < gameTime && gameTime > npc.m_flHeavyResPhaseCooldown)
			{
				npc.m_flHeavyResPhaseCooldown = GetGameTime() + 20.0;
				npc.m_flNextMeleeAttack = gameTime + 2.0;
				npc.m_flDoingAnimation = gameTime + 2.0;
				npc.m_flHeavyResPhase = gameTime + 2.0;
				npc.AddGesture("ACT_ROGUE2_CHAOS_KNIGHT_ABILITY1");
				if(npc.m_iChanged_WalkCycle != 5)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_ROGUE2_CHAOS_KNIGHT_WALK");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
		}
	}
}