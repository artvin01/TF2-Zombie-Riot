#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_negativevocalization01.mp3",
	"vo/heavy_negativevocalization02.mp3",
	"vo/heavy_negativevocalization03.mp3",
};
static const char g_HurtSounds[][] = {
	"vo/heavy_helpmedefend01.mp3",
	"vo/heavy_helpmedefend02.mp3",
	"vo/heavy_helpmedefend03.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
};

static const char g_RangeAttackSounds[] = "mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav";

static int i_radioguard_particle[MAXENTITIES];

void Victorian_Radioguard_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Radio Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_radioguard");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_radioguard");
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
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/heavy.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Victorian_Radioguard(vecPos, vecAng, ally, data);
}

methodmap Victorian_Radioguard < CClotBody
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
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.7, 80);
	}
	
	property int m_iMainTarget
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}

	public Victorian_Radioguard(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Victorian_Radioguard npc = view_as<Victorian_Radioguard>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.3", "80000", ally, .isGiant = true));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		func_NPCDeath[npc.index] = view_as<Function>(Victorian_Radioguard_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Victorian_Radioguard_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Victorian_Radioguard_ClotThink);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_iMainTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 0.75;
		
		if(StrContains(data, "target") != -1)
		{
			char buffers[3][64];
			ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			ReplaceString(buffers[0], 64, "target", "");
			int targetdata = StringToInt(buffers[0]);
			if(IsValidAlly(npc.index, targetdata))
				npc.m_iMainTarget = targetdata;
		}
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_flameball/c_flameball.mdl");
		SetVariantString("2.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/heavy/hardhat_tower.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/xms2013_heavy_pants/xms2013_heavy_pants.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum23_brother_mann_style3/sum23_brother_mann_style3.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum24_brutes_braces/sum24_brutes_braces.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

static void Victorian_Radioguard_ClotThink(int iNPC)
{
	Victorian_Radioguard npc = view_as<Victorian_Radioguard>(iNPC);
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

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return;
	}
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		bool TooFar;
		if(IsValidAlly(npc.index, npc.m_iMainTarget))
		{
			float vecProtect[3]; WorldSpaceCenter(npc.m_iMainTarget, vecProtect);
			float flDistanceToProtect = GetVectorDistance(vecProtect, VecSelfNpc, true);
			//Too far from the Radiomast
			TooFar = (flDistanceToProtect > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8);
			
			//Enemy is too far, find another Enemy.
			if(GetVectorDistance(vecTarget, vecProtect, true)>(NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*14.8)||GetVectorDistance(vecTarget, VecSelfNpc, true)>(NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*15.5))
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
				npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
			}
		}
		switch(VictorianRadioguardSelfDefense(npc, GetGameTime(npc.index), flDistanceToTarget, TooFar))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
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
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 250.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iMainTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iMainTarget);
				}
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
	}
	npc.PlayIdleAlertSound();
}

static Action Victorian_Radioguard_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Victorian_Radioguard npc = view_as<Victorian_Radioguard>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Victorian_Radioguard_NPCDeath(int entity)
{
	Victorian_Radioguard npc = view_as<Victorian_Radioguard>(entity);
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

	int particle = EntRefToEntIndex(i_radioguard_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_radioguard_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
}

static int VictorianRadioguardSelfDefense(Victorian_Radioguard npc, float gameTime, float distance, bool TooFar)
{
	if(gameTime < npc.m_flNextRangedAttack-4.0)
	{
		npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
		return 3;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappens = gameTime+0.2;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappenswillhappen && gameTime > npc.m_flAttackHappens)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
				npc.FaceTowards(vecTarget, 20000.0);
				npc.PlayRangeSound();
				float RocketDamage = 150.0;
				float RocketSpeed = 950.0;
				if(NpcStats_VictorianCallToArms(npc.index))
					RocketDamage *= 2.0;
				int projectile = npc.FireParticleRocket(vecTarget, RocketDamage , RocketSpeed , 450.0 , "spell_fireball_small_blue", true);
				SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
				SDKHook(projectile, SDKHook_StartTouch, Victoria_RadioGuard_Particle_StartTouch);
				npc.m_flNextRangedAttack = gameTime + 5.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			return 3;
		}
	}
	if(TooFar)
		return 2;
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
		return (Can_I_See_Enemy_Only(npc.index, npc.m_iTarget) ? 0 : 1);
	return 0;
}

static void Victoria_RadioGuard_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		if(inflictor == -1)
			inflictor = owner;
		
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];
			
		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		if(NpcStats_VictorianCallToArms(owner))
		{
			float ProjectileLoc[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, 100.0, _, _, true, _, false, _, Weeeeeeeeeiiiiii);
			ParticleEffectAt(ProjectileLoc, "mvm_soldier_shockwave", 1.0);
		}
		
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
			owner = 0;
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		if(inflictor == -1)
			inflictor = owner;
		if(NpcStats_VictorianCallToArms(owner))
		{
			float ProjectileLoc[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
			Explode_Logic_Custom(0.0, owner, inflictor, -1, ProjectileLoc, 100.0, _, _, true, _, false, _, Weeeeeeeeeiiiiii);
			ParticleEffectAt(ProjectileLoc, "mvm_soldier_shockwave", 1.0);
		}
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}

static void Weeeeeeeeeiiiiii(int entity, int victim, float damage, int weapon)
{
	Victorian_Radioguard npc = view_as<Victorian_Radioguard>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		if(!IsInvuln(victim))
		{
			if(IsValidClient(victim))
			{
				TF2_AddCondition(victim, TFCond_LostFooting, 2.5);
				TF2_AddCondition(victim, TFCond_AirCurrent, 2.5);
			}
			Custom_Knockback(npc.index, victim, 2500.0, true);
			StartBleedingTimer(victim, npc.index, 12.0, 5, -1, DMG_TRUEDAMAGE, 0);
		}
	}
}