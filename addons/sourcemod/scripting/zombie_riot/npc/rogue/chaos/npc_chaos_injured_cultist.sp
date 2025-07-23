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
static const char  g_DeathSoundsAbility[][] =
{
	"misc/outer_space_transition_01.wav",
};


void ChaosInjuredCultist_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedHitSounds)); i++) { PrecacheSound(g_RangedHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_CoughRandom)); i++) { PrecacheSound(g_CoughRandom[i]); }
	for (int i = 0; i < (sizeof(g_DeathSoundsAbility));	   i++) { PrecacheSound(g_DeathSoundsAbility[i]);	   }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Injured Cultist");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_injured_cultist");
	strcopy(data.Icon, sizeof(data.Icon), "chaos_cultist");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_BlueParadox; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosInjuredCultist(vecPos, vecAng, team);
}
methodmap ChaosInjuredCultist < CClotBody
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
	public void PlayAbilitySound() 
	{
		EmitSoundToAll(g_DeathSoundsAbility[GetRandomInt(0, sizeof(g_DeathSoundsAbility) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_DeathSoundsAbility[GetRandomInt(0, sizeof(g_DeathSoundsAbility) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public ChaosInjuredCultist(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosInjuredCultist npc = view_as<ChaosInjuredCultist>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "1500", ally, false, true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int iActivity = npc.LookupActivity("ACT_ROGUE2_CHAOS_INJURED_CULTIST_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);

		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}

		npc.g_TimesSummoned = 1;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bisWalking = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChaosInjuredCultist_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChaosInjuredCultist_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChaosInjuredCultist_ClotThink);
		
		
		
		npc.m_flHeavyResPhaseCooldown = GetGameTime() + 10.0;
		npc.m_flViolentCaughingCooldown = GetGameTime() + 30.0;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/all_class/xms_antlers_engy.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/sniper/thief_sniper_hood/thief_sniper_hood.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 50, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable1, 50, 50, 50, 255);
		SetEntityRenderColor(npc.m_iWearable2, 50, 50, 50, 255);
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {0.0,-10.0,-10.0});
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {0.0,-5.0,-15.0});
		return npc;
	}
}

public void ChaosInjuredCultist_ClotThink(int iNPC)
{
	ChaosInjuredCultist npc = view_as<ChaosInjuredCultist>(iNPC);
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
		npc.m_flViolentCaughingCooldown = FAR_FUTURE;
	}
	
	//default fight animation, set whenever no ability is in use.
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_ROGUE2_CHAOS_INJURED_CULTIST_WALK");
			npc.StartPathing();
			npc.m_flSpeed = 200.0;
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
		ChaosInjuredCultistSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ChaosInjuredCultist_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosInjuredCultist npc = view_as<ChaosInjuredCultist>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	if(npc.g_TimesSummoned < 3)
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int nextLoss = (maxhealth/ 10) * (3 - npc.g_TimesSummoned) / 3;
		float Scaling = float(health) * 3.0 / float(maxhealth);
		while(Scaling > 1.0)
			Scaling -= 1.0;

		Scaling *= -1.0;
		Scaling += 1.0;

		RaidModeScaling = Scaling;

		if((health / 10) < nextLoss)
		{
			npc.g_TimesSummoned++;
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			VecSelfNpcabs[2] += 5.0;

			DataPack pack;
			CreateDataTimer(0.1, Timer_FallenWarrior, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

			for(int i; i < 3; i++)
			{
				pack.WriteFloat(VecSelfNpcabs[i]);
			}
			pack.WriteCell(GetRandomSeedFallenWarrior());
			pack.WriteCell(1);
			pack.WriteCell(GetTeam(npc.index));
			npc.PlayAbilitySound();
			Explode_Logic_Custom(3000.0, 0, npc.index, -1, VecSelfNpcabs, 500.0, 1.0, _, true);
			TE_Particle("asplode_hoodoo", VecSelfNpcabs, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			CreateEarthquake(VecSelfNpcabs, 1.0, 500.0, 12.0, 100.0);
		}
	}
	else
	{
		RaidModeScaling = 0.0;
	}

	return Plugin_Changed;
}

public void ChaosInjuredCultist_NPCDeath(int entity)
{
	ChaosInjuredCultist npc = view_as<ChaosInjuredCultist>(entity);
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

void ChaosInjuredCultistSelfDefense(ChaosInjuredCultist npc, float gameTime, int target, float distance)
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
					float damageDealt = 250.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 7.5;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddChaosDamage(target, npc.index, 500, false, true);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.75))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_ROGUE2_CHAOS_INJURED_CULTIST_ATTACK1");
						
				npc.m_flAttackHappens = gameTime + 0.3;
				npc.m_flDoingAnimation = gameTime + 0.55;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_iChanged_WalkCycle = 2;
				//	npc.SetActivity("ACT_ROGUE2_CHAOS_INJURED_CULTIST_WALK");
					npc.StopPathing();
					npc.m_flSpeed = 0.0;
				}
			}
		}
	}
}