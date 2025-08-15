#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/vortigaunt/undeserving.wav",
	"vo/npc/vortigaunt/tothevoid.wav",
	"vo/npc/vortigaunt/worthless.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/vortigaunt/vortigese04.wav",
	"vo/npc/vortigaunt/vortigese07.wav",
	"vo/npc/vortigaunt/vortigese08.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/npc/vortigaunt/vortigese02.wav",
	"vo/npc/vortigaunt/vortigese05.wav",
	"vo/npc/vortigaunt/vortigese11.wav",
	"vo/npc/vortigaunt/vortigese12.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/vort/claw_swing1.wav",
	"npc/vort/claw_swing2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/vort/foot_hit.wav",
};

static const char g_PullSounds[][] = {
	"weapons/physcannon/physcannon_charge.wav",
};

static const char g_BoomSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};


void Hostis_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_PullSounds)); i++) { PrecacheSound(g_PullSounds[i]); }
	for (int i = 0; i < (sizeof(g_BoomSounds)); i++) { PrecacheSound(g_BoomSounds[i]); }
	PrecacheModel("models/vortigaunt.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Refragmented Hostis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_refragmented_hostis");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Hostis(vecPos, vecAng, team);
}
methodmap Hostis < CClotBody
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
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	public void PlayPullSound()
	{
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	
	public Hostis(float vecPos[3], float vecAng[3], int ally)
	{
		Hostis npc = view_as<Hostis>(CClotBody(vecPos, vecAng, "models/vortigaunt.mdl", "1.15", "5000", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_Run");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Hostis_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Hostis_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Hostis_ClotThink);

		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 5.0;
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 10.0;
		
		npc.StartPathing();
		npc.m_flSpeed = 270.0;
		
		npc.m_flMeleeArmor = 0.10;
		npc.m_flRangedArmor = 0.10;

		npc.m_iWearable1 = TF2_CreateGlow_White("models/vortigaunt.mdl", npc.index, 1.15);
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_bGlowEnabled", false);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_ENVIRONMENTAL);
			TE_SetupParticleEffect("utaunt_signalinterference_parent", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable1);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable1);	
			TE_SendToAll();
		}

		SetEntityRenderMode(npc.index, RENDER_GLOW);
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
		
		return npc;
	}
}

public void Hostis_ClotThink(int iNPC)
{
	Hostis npc = view_as<Hostis>(iNPC);
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

	float vecTarget2[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget2);
	float VecSelfNpc2[3]; WorldSpaceCenter(npc.index, VecSelfNpc2);
	float distance2 = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
	float flDistanceToTarget = GetVectorDistance(vecTarget2, VecSelfNpc2, true);
	if(distance2 < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		npc.PlayHurtSound();
		SDKHooks_TakeDamage(npc.index, npc.m_iTarget, npc.m_iTarget, 50.0, DMG_TRUEDAMAGE, -1, _, vecMe, true);
		//Explode_Logic_Custom(10.0, npc.index, npc.index, -1, vecMe, 15.0, _, _, false, 1, false);
		SetEntityRenderColor(npc.index, 180, 0, 0, 200);
	}
	if(distance2 > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.25) && !i_IsABuilding[npc.m_iTarget])
	{
		SetEntityRenderColor(npc.index, 0, 0, 125, 200);
	}

	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 <= GetGameTime(npc.index))
		{
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float cpos[3];
			float velocity[3];
			float ScaleVectorDoMulti = -100.0;
			if(!IsValidEntity(npc.m_iWearable1))
			{
				npc.m_iWearable1 = ParticleEffectAt(vecMe, "dxhr_lightningball_parent_blue", -1.0);
				if(IsValidEntity(npc.m_iWearable1))
					SetParent(npc.index, npc.m_iWearable1);
			}
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEnemy(npc.index, EnemyLoop, true, true))
				{
					if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
					{ 	
						GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", cpos);
						float flDistanceToTarget2 = GetVectorDistance(cpos, VecSelfNpc2, true);
						if(flDistanceToTarget2 > (500.0 * 500.0))
							return;

						MakeVectorFromPoints(pos, cpos, velocity);
						NormalizeVector(velocity, velocity);
						ScaleVector(velocity, ScaleVectorDoMulti);
						if(b_ThisWasAnNpc[EnemyLoop])
						{
							CClotBody npc1 = view_as<CClotBody>(EnemyLoop);
							npc1.SetVelocity(velocity);
						}
						else
						{	
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
						}
					}
				}
			}
		}
	}
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 <= GetGameTime(npc.index))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			if(flDistanceToTarget < (500.0 * 500.0))
			{
				Custom_Knockback(npc.index, npc.m_iTarget, 3000.0);
			}
			npc.DispatchParticleEffect(npc.index, "drg_cow_explosioncore_normal_blue", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);

			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 5.0;
			npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 10.0;
		}
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget2 = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget2 < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		HostisSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget2); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Hostis_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Hostis npc = view_as<Hostis>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Hostis_NPCDeath(int entity)
{
	Hostis npc = view_as<Hostis>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void HostisSelfDefense(Hostis npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 200.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK1");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.50;
				npc.m_flNextMeleeAttack = gameTime + 1.15;
			}
		}
	}
}