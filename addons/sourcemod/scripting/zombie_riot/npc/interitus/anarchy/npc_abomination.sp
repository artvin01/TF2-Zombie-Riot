#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"vo/pyro_paincrticialdeath01.mp3",
	"vo/pyro_paincrticialdeath02.mp3",
	"vo/pyro_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/pyro_taunts01.mp3",
	"vo/taunts/pyro_taunts02.mp3",
	"vo/taunts/pyro_taunts03.mp3",
};

static const char g_charge_sound[][] = {
	"misc/halloween/spell_blast_jump.wav",
};

void AnarchyAbomination_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_charge_sound)); i++) { PrecacheSound(g_charge_sound[i]); }
	PrecacheSound("weapons/flame_thrower_loop.wav");
	PrecacheSound("weapons/flame_thrower_pilot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Abomination");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_abomination");
	strcopy(data.Icon, sizeof(data.Icon), "pyro_armored2_1");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AnarchyAbomination(vecPos, vecAng, team);
}

methodmap AnarchyAbomination < CClotBody
{

	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayChargeSound() 
	{
		EmitSoundToAll(g_charge_sound[GetRandomInt(0, sizeof(g_charge_sound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));

	}
	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
				EmitSoundToAll("weapons/flame_thrower_loop.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
				EmitSoundToAll("weapons/flame_thrower_pilot.wav", this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}
	
	public AnarchyAbomination(float vecPos[3], float vecAng[3], int ally)
	{
		AnarchyAbomination npc = view_as<AnarchyAbomination>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.35", "500000", ally, false, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(AnarchyAbomination_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AnarchyAbomination_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AnarchyAbomination_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 290.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_the_creatures_grin/sf14_the_creatures_grin.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_arm/sf14_hw2014_robot_arm.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/sf14_hw2014_robot_legg/sf14_hw2014_robot_legg.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_maniacs_manacles/hw2013_maniacs_manacles.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void AnarchyAbomination_ClotThink(int iNPC)
{
	AnarchyAbomination npc = view_as<AnarchyAbomination>(iNPC);
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
	
	if (npc.IsOnGround())
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			npc.StartPathing();
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
			npc.StartPathing();
		}	
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(npc.m_flCharge_delay < GetGameTime(npc.index))
		{
			if(flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
			{
				npc.PlayChargeSound();
				npc.m_flCharge_delay = GetGameTime(npc.index) + 5.0;
				PluginBot_Jump(npc.index, vecTarget);
				float flPos[3];
				float flAng[3];
				int Particle_1;
				int Particle_2;
				npc.GetAttachment("foot_L", flPos, flAng);
				Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
				

				npc.GetAttachment("foot_R", flPos, flAng);
				Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
				CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		bool SpinSound = true;
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = AnarchyAbominationSelfDefense(npc,SpinSound); 
		
		if(SpinSound)
			npc.PlayMinigunSound(false);
		
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
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action AnarchyAbomination_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AnarchyAbomination npc = view_as<AnarchyAbomination>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		if (attacker <= MaxClients && attacker > 0 && TeutonType[attacker] != TEUTON_NONE)
		{	
			return Plugin_Changed;
		}
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		//teutons dont change this.

		npc.m_flSpeed = 290.0;
		npc.Anger = false;
		float minimumres = 0.05;
		if(EnableSilentMode)
		{
			minimumres = 0.25;
		}
		if(damagetype & DMG_CLUB)
		{
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				npc.m_flMeleeArmor -= 0.05;
				if(npc.m_flMeleeArmor < minimumres)
				{
					npc.m_flMeleeArmor = minimumres;
					npc.Anger = true;
				}
			}
			
			npc.m_flRangedArmor += 0.05;
			if(npc.m_flRangedArmor > 1.5)
			{
				npc.m_flRangedArmor = 1.5;
				npc.Anger = true;
			}
		}
		else if(!(damagetype & DMG_TRUEDAMAGE))
		{
			npc.m_flRangedArmor -= 0.05;
			if(npc.m_flRangedArmor < minimumres)
			{
				npc.Anger = true;
				npc.m_flRangedArmor = minimumres;
			}
			
			npc.m_flMeleeArmor += 0.05;
			if(npc.m_flMeleeArmor > 1.5)
			{
				npc.Anger = true;
				npc.m_flMeleeArmor = 1.5;
			}
		}
	}
	
	return Plugin_Changed;
}

public void AnarchyAbomination_NPCDeath(int entity)
{
	AnarchyAbomination npc = view_as<AnarchyAbomination>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	
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

int AnarchyAbominationSelfDefense(AnarchyAbomination npc, bool &SpinSound)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.FaceTowards(vecTarget, 20000.0);
			float ProjectileSpeed = 1000.0;

			int projectile;
			
			if(npc.Anger)
			{
				PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);
				projectile = npc.FireParticleRocket(vecTarget, 30.0, ProjectileSpeed, 150.0, "superrare_burning2", true);
				static float ang_Look[3];
				GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
				Initiate_HomingProjectile(projectile,
				npc.index,
					90.0,			// float lockonAngleMax,
					90.0,				//float homingaSec,
					true,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					ang_Look,			
					target); //home onto this enemy
			}
			else
			{
				projectile = npc.FireParticleRocket(vecTarget, 30.0, ProjectileSpeed, 150.0, "superrare_burning1", true);
			}
			SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			int particle = EntRefToEntIndex(i_WandParticle[projectile]);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
			
			SDKHook(projectile, SDKHook_StartTouch, AnarchyAbomination_Rocket_Particle_StartTouch);			
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
	return 0;
}



public void AnarchyAbomination_Rocket_Particle_StartTouch(int entity, int target)
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

		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= 17.5;

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	

		Elemental_AddChaosDamage(target, owner, 15, true, true);

		NPC_Ignite(target, owner,12.0, -1, 8.0);

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