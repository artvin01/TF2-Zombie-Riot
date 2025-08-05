#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	")physics/metal/metal_canister_impact_hard1.wav",
	")physics/metal/metal_canister_impact_hard2.wav",
	")physics/metal/metal_canister_impact_hard3.wav",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/sentry_shoot3.wav",
};

static bool AlternatingBarrel[MAXENTITIES];

static float CustomMinMaxBoundingBoxDimensions[3] = { 24.0, 24.0, 82.0 };

void ApertureSentry_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	
	PrecacheModel("models/buildables/sentry1_heavy.mdl");
	PrecacheModel("models/buildables/sentry3.mdl");
	PrecacheModel("models/buildables/sentry3_heavy.mdl");
	PrecacheModel("models/buildables/sentry3_rockets.mdl");
	
	PrecacheParticleSystem("muzzle_sentry");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Sentry");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_sentry");
	strcopy(data.Icon, sizeof(data.Icon), "sentry_gun_lvl3_lite");
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ApertureSentry(vecPos, vecAng, team);
}
methodmap ApertureSentry < CClotBody
{
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public int GetValidSentryTarget()
	{
		return GetClosestTarget(this.index, .fldistancelimit = 1024.0, .CanSee = true, .UseVectorDistance = true);
	}
	
	public void FixCollisionBox()
	{
		// Collision boxes change on model change! But we need the actual models to do animations!
		// Revert collision box on each model change.
		// The globals will already have the right values so we don't need to change everything.
		
		float vecMins[3], vecMaxs[3];
		vecMaxs = CustomMinMaxBoundingBoxDimensions;
		vecMins[0] = -CustomMinMaxBoundingBoxDimensions[0];
		vecMins[1] = -CustomMinMaxBoundingBoxDimensions[1];
		
		CBaseNPC baseNPC = view_as<CClotBody>(this).GetBaseNPC();
		
		baseNPC.SetBodyMaxs(vecMaxs);
		baseNPC.SetBodyMins(vecMins);
		
		SetEntPropVector(this, Prop_Data, "m_vecMaxs", vecMaxs);
		SetEntPropVector(this, Prop_Data, "m_vecMins", vecMins);
		
		//Fixed wierd clientside issue or something
		float vecMaxsNothing[3], vecMinsNothing[3];
		vecMaxsNothing = view_as<float>( { 1.0, 1.0, 2.0 } );
		vecMinsNothing = view_as<float>( { -1.0, -1.0, 0.0 } );		
		SetEntPropVector(this, Prop_Send, "m_vecMaxsPreScaled", vecMaxsNothing);
		SetEntPropVector(this, Prop_Data, "m_vecMaxsPreScaled", vecMaxsNothing);
		SetEntPropVector(this, Prop_Send, "m_vecMinsPreScaled", vecMinsNothing);
		SetEntPropVector(this, Prop_Data, "m_vecMinsPreScaled", vecMinsNothing);
	}
	
	property bool m_bAlternatingBarrel
	{
		public get()							{ return AlternatingBarrel[this.index]; }
		public set(bool TempValueForProperty) 	{ AlternatingBarrel[this.index] = TempValueForProperty; }
	}

	public ApertureSentry(float vecPos[3], float vecAng[3], int ally)
	{
		// Important: the Sentry is NOT a building entity! This is so animations work properly.
		ApertureSentry npc = view_as<ApertureSentry>(CClotBody(vecPos, vecAng, "models/buildables/sentry3.mdl", "1.0", MinibossHealthScaling(4.5, true), ally, .CustomThreeDimensions = CustomMinMaxBoundingBoxDimensions));
		
		// ...we still fake building status anyway
		i_NpcIsABuilding[npc.index] = true;
		npc.m_flSpeed = 0.0;
		npc.m_bisWalking = false;
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.5;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		Is_a_Medic[npc.index] = false;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		f_AttackSpeedNpcIncrease[npc.index] = 1.0;
		
		AddNpcToAliveList(npc.index, 1);
		
		npc.Anger = false;
		npc.m_flDoingAnimation = 0.0;

		float wave = float(Waves_GetRound()+1);
		wave *= 0.5;
		npc.m_flWaveScale = wave;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		// Fixes weird collision
		SetEntityModel(npc.index, "models/buildables/sentry1_heavy.mdl");
		npc.FixCollisionBox();

		func_NPCDeath[npc.index] = view_as<Function>(ApertureSentry_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureSentry_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureSentry_ClotThink);
		
		npc.m_iState = 0;

		return npc;
	}
}

public void ApertureSentry_ClotThink(int iNPC)
{
	ApertureSentry npc = view_as<ApertureSentry>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	switch (npc.m_iState)
	{
		case 0:
		{
			// Building
			if (!npc.m_flDoingAnimation)
			{
				npc.AddActivityViaSequence("build");
				npc.SetCycle(0.01);
				
				SetVariantInt(2);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				
				const float animTime = 5.0; // Sentry anim takes about 5 seconds
				float duration = npc.Anger ? 1.0 : 7.0;
				
				npc.SetPlaybackRate(animTime / duration);
				npc.m_flDoingAnimation = gameTime + duration;
			}
			else if (npc.m_flDoingAnimation < gameTime)
			{
				SetEntityModel(npc.index, "models/buildables/sentry3_heavy.mdl");
				npc.FixCollisionBox();
				
				SetVariantInt(0);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				
				npc.m_iState = 1;
				npc.m_flDoingAnimation = 0.0;
			}
			
			return;
		}
		
		case 1:
		{
			if (!npc.m_flDoingAnimation)
			{
				// FIXME: This doesn't work!
				// Do these animations work at all? It looks like the same problem was ran-into for the friendly buildings
				// Just magically make them level three
				
				// Built, but we want to also add an upgrade animation
				npc.AddActivityViaSequence("upgrade");
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				
				SetVariantInt(3);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				
				npc.m_flDoingAnimation = gameTime + 1.4;
			}
			else if (npc.m_flDoingAnimation < gameTime)
			{
				SetEntityModel(npc.index, "models/buildables/sentry3.mdl");
				npc.FixCollisionBox();
				
				npc.AddActivityViaSequence("idle_off");
				npc.SetCycle(0.01);
				
				npc.SetPlaybackRate(1.0);
				
				SetVariantInt(0);
				AcceptEntityInput(npc.index, "SetBodyGroup");
				
				float vecPos[3];
				WorldSpaceCenter(npc.index, vecPos);
				
				npc.m_iState = 2;
				npc.m_flDoingAnimation = 0.0;
			}
			
			return;
		}
		
		case 2:
		{
			// Fully built, can shoot, but is on standby
			npc.m_iTarget = npc.GetValidSentryTarget();
			
			// Can't see anyone, stop here
			if (npc.m_iTarget <= 0)
				return;
			
			// We'll turn now, then start blasting on the next think time
			float vecPos[3];
			WorldSpaceCenter(npc.index, vecPos);
			npc.FaceTowards(vecPos, 1200.0);
			
			// Make rockets not fire straight away, if they're ready
			npc.m_flNextRangedAttack = fmax(npc.m_flNextRangedAttack, gameTime + 0.75);
			
			npc.m_iState = 3;
			return;
		}
		
		case 3:
		{
			// Fully built, is shooting at last known target
			npc.m_iTarget = npc.GetValidSentryTarget();
			
			// Can't see anyone, stop here, go back to being on standby
			if (npc.m_iTarget <= 0)
			{
				npc.m_iState = 2;
				return;
			}
			
			ApertureSentrySelfDefense(npc, gameTime, npc.m_iTarget);
		}
	}
}

public Action ApertureSentry_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureSentry npc = view_as<ApertureSentry>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
	
	return Plugin_Changed;
}

public void ApertureSentry_NPCDeath(int entity)
{
	ApertureSentry npc = view_as<ApertureSentry>(entity);
	npc.PlayDeathSound();	
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
}

void ApertureSentrySelfDefense(ApertureSentry npc, float gameTime, int target)
{
	float vecPos[3], vecTargetPos[3];
	WorldSpaceCenter(npc.index, vecPos);
	WorldSpaceCenter(target, vecTargetPos);
	
	// Keep turning towards our target even if we're not ready to shoot...
	npc.FaceTowards(vecTargetPos, 1200.0);
	
	if (gameTime > npc.m_flNextMeleeAttack)
	{
		// At this point we know we can see and should shoot our target, let's avoid doing allat again
		npc.PlayMeleeSound();
		npc.AddGesture("ACT_RANGE_ATTACK1");
		
		float vecBarrelPos[3], vecBarrelAng[3], vecTraceAng[3];
		npc.GetAttachment(npc.m_bAlternatingBarrel ? "muzzle_l" : "muzzle_r", vecBarrelPos, vecBarrelAng);
		
		npc.m_bAlternatingBarrel = !npc.m_bAlternatingBarrel;
		
		ParticleEffectAtWithRotation(vecBarrelPos, vecBarrelAng, "muzzle_sentry");
		
		// Barrels only aim straight forward. Make the bullet traces aim in the vertical direction of the target
		GetRayAngles(vecBarrelPos, vecTargetPos, vecTraceAng);
		
		// We only care about the vertical difference
		vecTraceAng[1] = vecBarrelAng[1];
		
		Handle trace;
		trace = TR_TraceRayFilterEx(vecBarrelPos, vecTraceAng, (MASK_SOLID | CONTENTS_SOLID), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		if (TR_DidHit(trace))
		{
			float vecHit[3];
			TR_GetEndPosition(vecHit, trace);
			
			int traceTarget = TR_GetEntityIndex(trace);
			ShootLaser(npc.index, "bullet_tracer02_blue", vecBarrelPos, vecHit, false );

			if(IsValidEnemy(npc.index, traceTarget))
			{
				float damageDealt = 10.0;
				damageDealt *= npc.m_flWaveScale;
				if(ShouldNpcDealBonusDamage(traceTarget))
					damageDealt *= 3.0;
				
				SDKHooks_TakeDamage(traceTarget, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
			}
		}
		
		delete trace;
		npc.m_flNextMeleeAttack = gameTime + 0.25;
	}
	
	if (gameTime > npc.m_flNextRangedAttack)
	{
		char model[64];
		npc.AddGesture("ACT_RANGE_ATTACK2", false);
		
		float damageDealt = 60.0;
		damageDealt *= npc.m_flWaveScale;
		if (ShouldNpcDealBonusDamage(target))
			damageDealt *= 3.0;
		
		npc.FireRocket(vecTargetPos, damageDealt, 450.0, "models/buildables/sentry3_rockets.mdl", .offset = 12.0, .inflictor = npc.index);
		npc.m_flNextRangedAttack = gameTime + 3.0;
	}
}