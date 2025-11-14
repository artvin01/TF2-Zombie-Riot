#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_ChargeExplode[][] = {
	"weapons/loose_cannon_charge.wav",
};
static const char g_ExplodeMe[][] = {
	"weapons/sentry_explode.wav",
};


void DrDamClone_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_ChargeExplode));	   i++) { PrecacheSound(g_ChargeExplode[i]);	   }
	for (int i = 0; i < (sizeof(g_ExplodeMe));	   i++) { PrecacheSound(g_ExplodeMe[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_DeathSounds));	   i++) { PrecacheSound(g_DefaultMedic_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dr Dam Clone");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_drdam_clone");
	strcopy(data.Icon, sizeof(data.Icon), "medic_main");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return DrDamClone(vecPos, vecAng, team);
}

methodmap DrDamClone < CClotBody
{
	property float m_flDetonateTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
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
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayChargeSound() 
	{
		EmitSoundToAll(g_ChargeExplode[GetRandomInt(0, sizeof(g_ChargeExplode) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, 170);
	}
	public void PlayBoomSound() 
	{
		EmitSoundToAll(g_ExplodeMe[GetRandomInt(0, sizeof(g_ExplodeMe) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	
	public DrDamClone(float vecPos[3], float vecAng[3], int ally)
	{
		DrDamClone npc = view_as<DrDamClone>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", MinibossHealthScaling(60.0, true), ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(0);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		npc.m_iOverlordComboAttack = 255;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(DrDamClone_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(DrDamClone_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(DrDamClone_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		npc.m_bDissapearOnDeath = true;

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_uberneedle/c_uberneedle.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/jul13_madmans_mop/jul13_madmans_mop.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_gasmask/medic_gasmask.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable3, 3342130);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 3342130);
		b_NpcUnableToDie[npc.index] = true;
		
		return npc;
	}
}

public void DrDamClone_ClotThink(int iNPC)
{
	DrDamClone npc = view_as<DrDamClone>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flDetonateTime)
	{
		npc.m_iOverlordComboAttack -= 2;
		if(npc.m_iOverlordComboAttack < 0)
			npc.m_iOverlordComboAttack = 0;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(IsValidEntity(npc.m_iWearable2))
			SetEntityRenderColor(npc.m_iWearable2, 255, npc.m_iOverlordComboAttack, npc.m_iOverlordComboAttack, 255);
		if(IsValidEntity(npc.m_iWearable3))
			SetEntityRenderColor(npc.m_iWearable3, 255, npc.m_iOverlordComboAttack, npc.m_iOverlordComboAttack, 255);
		if(IsValidEntity(npc.m_iWearable4))
			SetEntityRenderColor(npc.m_iWearable4, 255, npc.m_iOverlordComboAttack, npc.m_iOverlordComboAttack, 255);
		if(IsValidEntity(npc.m_iWearable5))
			SetEntityRenderColor(npc.m_iWearable5, 255, npc.m_iOverlordComboAttack, npc.m_iOverlordComboAttack, 255);

		SetEntityRenderColor(npc.index, 255, npc.m_iOverlordComboAttack, npc.m_iOverlordComboAttack, 255);
		if(npc.m_flDetonateTime < GetGameTime(npc.index))
		{
			b_ThisEntityIgnored[npc.index] = false;
			npc.PlayBoomSound();
			float damage = 50.0;
			i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_CLUB_DAMAGE;
			float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
			Explode_Logic_Custom(damage * npc.m_flWaveScale,
			npc.index,
			npc.index,
			-1,
			_,
			70.0,
			_,
			_,
			true,
			99,
			false,
			3.0,
			_);

			SmiteNpcToDeath(npc.index);
			TE_Particle("ExplosionCore_MidAir", npc_vec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0); //particle that spawns after his death
			npc.m_flDetonateTime = 0.0;
		}
		return;
	}
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float flDistanceToTarget2 = GetVectorDistance(vecTarget, VecSelfNpc);
		
		flDistanceToTarget2 /= 300.0;
		npc.m_flSpeed = (320.0 * flDistanceToTarget2);
		if(npc.m_flSpeed > 800.0)
		{
			npc.m_flSpeed = 800.0;
			if(!IsValidEntity(npc.m_iWearable6))
			{
				float pos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				pos[2] += 70.0;
				npc.m_iWearable6 = ParticleEffectAt(pos, "scout_dodge_blue", 0.0);
				SetParent(npc.index, npc.m_iWearable6);
			}
			ApplyStatusEffect(npc.index, npc.index, "UBERCHARGED", 0.5);
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
		}
		if(npc.m_flSpeed < 320.0)
			npc.m_flSpeed = 320.0;
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
		DrDamCloneSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action DrDamClone_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	DrDamClone npc = view_as<DrDamClone>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	//each HIT gives more. 
	

	//DETONATE!!!!!!!!
	if(!npc.m_flDetonateTime && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		npc.PlayChargeSound();
		npc.m_flDetonateTime = GetGameTime(npc.index) + 1.5;
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE;
		b_ThisEntityIgnoredBeingCarried[npc.index] = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		b_DoNotUnStuck[npc.index] = true;
		b_ThisEntityIgnored[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 1);
		npc.StopPathing();
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_DIEVIOLENT");
		npc.m_flSpeed = 0.0;
	}
	return Plugin_Changed;
}

public void DrDamClone_NPCDeath(int entity)
{
	DrDamClone npc = view_as<DrDamClone>(entity);
	/*
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	*/	
	
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

void DrDamCloneSelfDefense(DrDamClone npc, float gameTime, int target, float distance)
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
					float damageDealt = 35.0;
					if(npc.m_iOverlordComboAttack >= 3)
					{
						damageDealt *= 2.0;
						Custom_Knockback(npc.index, target, 360.0);
					}
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.5;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			if(npc.m_iOverlordComboAttack >= 3)
			{
				npc.m_iOverlordComboAttack = 0;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
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
				npc.m_iOverlordComboAttack++;
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.25;
			}
		}
	}
}