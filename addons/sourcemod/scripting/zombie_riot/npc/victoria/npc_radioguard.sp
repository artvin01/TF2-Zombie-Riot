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

static const char g_ReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav",
	"mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav",
};


void Victorian_Radioguard_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ReloadSound)); i++) { PrecacheSound(g_ReloadSound[i]); }
	PrecacheModel("models/player/heavy.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Radio Guard");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_radioguard");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_radioguard");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static int i_radioguard_particle[MAXENTITIES];

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Victorian_Radioguard(vecPos, vecAng, ally);
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
	public void PlayReloadSound() 
	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 60, _, 0.5, 80);
	}

	public Victorian_Radioguard(float vecPos[3], float vecAng[3], int ally)
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
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 250.0;
		
		
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

public void Victorian_Radioguard_ClotThink(int iNPC)
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
		Victorian_RadioguardSelfDefense(npc,GetGameTime(npc.index)); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Victorian_Radioguard_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

public void Victorian_Radioguard_NPCDeath(int entity)
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

void Victorian_RadioguardSelfDefense(Victorian_Radioguard npc, float gameTime)
{
	int target;
	//some Ranged units will behave differently.
	//not this one.
	target = npc.m_iTarget;
	if(!IsValidEnemy(npc.index,target))
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 4;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(npc.m_iChanged_WalkCycle != 5)
			{
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 5;
				npc.SetActivity("ACT_MP_DEPLOYED_PRIMARY");
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
			}	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
				{	
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
					npc.PlayMeleeSound();
					npc.FaceTowards(vecTarget, 20000.0);
					Handle swingTrace;
					if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						npc.PlayMeleeSound();
						//after we fire, we will have a short delay beteween the actual laser, and when it happens
						//This will predict as its relatively easy to dodge
						float projectile_speed = 950.0;
						float Hitdamage = 150.0;

						WorldSpaceCenter(target, vecTarget);

						if(NpcStats_VictorianCallToArms(npc.index))
						{
							Hitdamage *= 2.0;
						}

						npc.FaceTowards(vecTarget, 20000.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 5.0;
						int projectile = npc.FireParticleRocket(vecTarget, Hitdamage , projectile_speed , 450.0 , "spell_fireball_small_blue", true);
						WandProjectile_ApplyFunctionToEntity(projectile, Victoria_RadioGuard_Particle_StartTouch);	
						npc.PlayIdleAlertSound();
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
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
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
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.m_flSpeed = 250.0;
			npc.StartPathing();
		}
	}
}


public void Victoria_RadioGuard_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		if (!IsInvuln(target))
		{
			if(NpcStats_VictorianCallToArms(owner))
			{
				bool Knocked = false;
				if(IsValidClient(target))
				{
					Knocked = true;
					Custom_Knockback(entity, target, 2500.0, true);
					TF2_AddCondition(target, TFCond_LostFooting, 2.5);
					TF2_AddCondition(target, TFCond_AirCurrent, 2.5);
				}
				if(!Knocked)
					Custom_Knockback(entity, target, 2500.0, true); 
			}
			StartBleedingTimer(target, owner, 12.0, 5, -1, DMG_TRUEDAMAGE, 0);
		}

		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}