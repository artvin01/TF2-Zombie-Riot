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
	"weapons/sentry_shoot2.wav",
};

void ApertureSentry_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	
	PrecacheModel("models/buildables/sentry1_heavy.mdl");
	PrecacheModel("models/buildables/sentry2_heavy.mdl");
	PrecacheModel("models/buildables/sentry2.mdl");
	
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

	public ApertureSentry(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureSentry npc = view_as<ApertureSentry>(CClotBody(vecPos, vecAng, "models/buildables/sentry1_heavy.mdl", "1.0", MinibossHealthScaling(4.5, true), ally, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.5;

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		Is_a_Medic[npc.index] = false;
		f_ExtraOffsetNpcHudAbove[npc.index] = 500.0;
		i_NpcIsABuilding[npc.index] = true;
		npc.m_flNextMeleeAttack = 0.0;
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

		func_NPCDeath[npc.index] = view_as<Function>(ApertureSentry_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureSentry_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureSentry_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

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
				
				const float animTime = 5.0; // Sentry anim takes about 5 seconds
				float duration = npc.Anger ? 1.0 : 7.0;
				
				npc.SetPlaybackRate(animTime / duration);
				npc.m_flDoingAnimation = gameTime + duration;
			}
			else if (npc.m_flDoingAnimation < gameTime)
			{
				SetEntityModel(npc.index, "models/buildables/sentry2_heavy.mdl");
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
				// Built, but we want to also add an upgrade animation
				npc.SetActivity("ACT_OBJ_UPGRADING");
				npc.SetCycle(0.01);
				
				const float animTime = 1.0; // Sentry lvl 2 upgrade anim takes about 1 second
				float duration = npc.Anger ? 0.5 : 1.0;
				
				npc.SetPlaybackRate(animTime / duration);
				npc.m_flDoingAnimation = gameTime + duration;
			}
			else if (npc.m_flDoingAnimation < gameTime)
			{
				SetEntityModel(npc.index, "models/buildables/sentry2.mdl");
				npc.m_iState = 2;
				npc.m_flDoingAnimation = 0.0;
			}
			
			return;
		}
		
		case 2:
		{
			if (IsValidEnemy(npc.index, npc.m_iTarget))
			{
				ApertureSentrySelfDefense(npc, gameTime, npc.m_iTarget); 
			}
			else
			{
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
		}
	}
}

public Action ApertureSentry_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureSentry npc = view_as<ApertureSentry>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
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
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(target, vecTargetPos);
		
		float distance = GetVectorDistance(vecTargetPos, vecPos, true);
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.FaceTowards(vecTargetPos, 20000.0);
				
				// DoAimbotTrace checks a target's origin, rather than center. We're doing this ourselves
				Handle trace;
				trace = TR_TraceRayFilterEx(vecPos, vecTargetPos, (MASK_SOLID | CONTENTS_SOLID), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
				if (TR_GetFraction(trace) < 1.0)
				{
					target = TR_GetEntityIndex(trace);	
						
					float vecHit[3];
					TR_GetEndPosition(vecHit, trace);
					float origin[3], angles[3];
					float origin2[3], angles2[3];
					npc.GetAttachment("muzzle_l", origin, angles);
					npc.GetAttachment("muzzle_r", origin2, angles2);
					ShootLaser(npc.index, "bullet_tracer02_blue", origin, vecHit, false );
					ShootLaser(npc.index, "bullet_tracer02_blue", origin2, vecHit, false );
					npc.m_flNextMeleeAttack = gameTime + 0.25;

					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 10.0;
						damageDealt *= npc.m_flWaveScale;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 3.0;
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					}
				}
				
				delete trace;
			}
		}
	}
}