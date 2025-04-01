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
	"player/souls_receive1.wav",
	"player/souls_receive2.wav",
	"player/souls_receive3.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cow_mangler_main_shot.wav",
};

void ChaosMage_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Mage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_mage");
	strcopy(data.Icon, sizeof(data.Icon), "chaos_mage");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_BlueParadox; 
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosMage(vecPos, vecAng, team);
}
methodmap ChaosMage < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 145);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.1, 140);

	}
	property float m_flChaosRevive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	public ChaosMage(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosMage npc = view_as<ChaosMage>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		int iActivity = npc.LookupActivity("ACT_ROGUE2_CHAOS_MAGE_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChaosMage_NPCDeath);
		func_NPCOnTakeDamagePost[npc.index] = view_as<Function>(ChaosMage_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChaosMage_ClotThink);
		ApplyStatusEffect(npc.index, npc.index, "Infinite Will", 9999999.0);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 270.0;
		fl_TotalArmor[npc.index] = 0.25;
		npc.m_iHealthBar = 1;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/sniper/desert_marauder.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 125, 125, 255);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 125, 125, 125, 255);
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {0.0,-5.0,-10.0});
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {0.0,5.0,-15.0});
		
		return npc;
	}
}

public void ChaosMage_ClotThink(int iNPC)
{
	ChaosMage npc = view_as<ChaosMage>(iNPC);
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
	if(npc.m_flChaosRevive)
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_ROGUE2_CHAOS_MAGE_REVIVE");
			NPC_StopPathing(npc.index);
			npc.m_flSpeed = 0.0;
		}
		if(npc.m_flChaosRevive < GetGameTime(npc.index))
		{
			RemoveSpecificBuff(npc.index, "Infinite Will");
			b_NpcIsInvulnerable[npc.index] = false;
			HealEntityGlobal(npc.index, npc.index, 999999.9, 1.15, 0.0, HEAL_SELFHEAL);
			npc.m_flChaosRevive = 0.0;
		}
		return;
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
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		ChaosMageSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ChaosMage_OnTakeDamage(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosMage npc = view_as<ChaosMage>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_iHealthBar <= 0 && !npc.Anger)
	{
		npc.Anger = true;
		npc.m_flChaosRevive = GetGameTime(npc.index) + 1.7;
		npc.PlayDeathSound();
		b_NpcIsInvulnerable[npc.index] = true;
	}
	
	return Plugin_Changed;
}

public void ChaosMage_NPCDeath(int entity)
{
	ChaosMage npc = view_as<ChaosMage>(entity);
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

void ChaosMageSelfDefense(ChaosMage npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		float projectile_speed = 350.0;
		float vecTarget[3];
		float DamageProject = 125.0;

		PredictSubjectPositionForProjectiles(npc, target, projectile_speed,_,vecTarget);
		npc.FaceTowards(vecTarget, 15000.0);
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);

			int entity = npc.FireArrow(vecTarget, DamageProject, 700.0, ENERGY_BALL_MODEL);
			
			npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("RHand"), PATTACH_POINT_FOLLOW, true);

			npc.PlayMeleeHitSound();
			if(entity != -1)
			{
				if(IsValidEntity(f_ArrowTrailParticle[entity]))
					RemoveEntity(f_ArrowTrailParticle[entity]);
				
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, 200, 0, 200, 255);
				
				WorldSpaceCenter(entity, vecTarget);
				f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "flaregun_energyfield_blue", 5.0);
				SetParent(entity, f_ArrowTrailParticle[entity]);
				f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);

				i_ChaosArrowAmount[entity] = RoundToCeil(DamageProject);
			}
		}
	}

	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_ROGUE2_CHAOS_MAGE_WALK");
			NPC_StopPathing(npc.index);
			npc.m_flSpeed = 0.0;
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			//This lasts 73 frames
			//at frame 61 it explodes.
			//divide by 24 to get the accurate time!
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.SetActivity("ACT_ROGUE2_CHAOS_MAGE_WALK");
			npc.StartPathing();
			npc.m_flSpeed = 270.0;
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_ROGUE2_CHAOS_MAGE_ATTACK");
				float flPos[3], flAng[3];
				npc.GetAttachment("RHand", flPos, flAng);
				npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "flaregun_energyfield_blue", npc.index, "RHand", {0.0,0.0,0.0});
						
				npc.m_flAttackHappens = gameTime + 0.6;
				npc.m_flDoingAnimation = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}