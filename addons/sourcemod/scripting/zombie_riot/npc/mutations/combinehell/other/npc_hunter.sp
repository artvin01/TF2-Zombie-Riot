#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/hunter/hunter_die2.mp3",
	"npc/hunter/hunter_die3.mp3",
};

static const char g_HurtSounds[][] = {
	"npc/hunter/hunter_pain2.mp3",
	"npc/hunter/hunter_pain4.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/hunter/hunter_alert1.mp3",
	"npc/hunter/hunter_alert2.mp3",
	"npc/hunter/hunter_alert3.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/hunter/strider_legstretch1.mp3",
	"npc/hunter/strider_legstretch2.mp3",
	"npc/hunter/strider_legstretch3.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"npc/hunter/body_medium_impact_hard4.mp3",
	"npc/hunter/body_medium_impact_hard5.mp3",
	"npc/hunter/body_medium_impact_hard6.mp3",
};

static const char g_ChargeSounds[][] = {
	"npc/hunter/hunter_charge3.mp3",
	"npc/hunter/hunter_charge4.mp3",
};

static char g_RangedAttackSounds[][] = {
	"npc/hunter/hunter_fire1.mp3",
};

static char g_SkewerSounds[][] = {
	"npc/hunter/hunter_skewer1.mp3",
};



void Hunter_OnMapStart_NPC()
{
	PrecacheModel("models/zombie_riot/hl2/hunter.mdl");
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_ChargeSounds)); i++) { PrecacheSound(g_ChargeSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SkewerSounds));   i++) { PrecacheSound(g_SkewerSounds[i]);   }
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hunter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_hunter");
	strcopy(data.Icon, sizeof(data.Icon), "hunter");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Hunter(vecPos, vecAng, ally);
}
methodmap Hunter < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	property int i_AbilityUsage
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayChargeSound()
	{
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	public void PlaySkewerSound() {
		EmitSoundToAll(g_SkewerSounds[GetRandomInt(0, sizeof(g_SkewerSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 95);
	}
	
	
	public Hunter(float vecPos[3], float vecAng[3], int ally)
	{
		Hunter npc = view_as<Hunter>(CClotBody(vecPos, vecAng, "models/zombie_riot/hl2/hunter.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Hunter_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Hunter_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Hunter_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.i_AbilityUsage = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flAbilityOrAttack0 = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		return npc;
	}
}

public void Hunter_ClotThink(int iNPC)
{
	Hunter npc = view_as<Hunter>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 <= gameTime)
		{
			npc.m_flAbilityOrAttack0 = 0.0;
		}
		return;
	}
	if(npc.m_flDead_Ringer_Invis_bool)
	{
		switch(npc.i_AbilityUsage)
		{
			case 1:
			{
				if(npc.m_flDead_Ringer_Invis <= gameTime)
				{
					npc.m_flDead_Ringer_Invis = gameTime + 0.05;
					//SDKHook(npc.index, SDKHook_Touch, HunterTouchDamageTouch);
					float radius = 50.0, damage = 50.0;
					Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
				}
			}
		}
	}
	
	
	if(Hunter_Charge_Disable(npc, gameTime))
	{
		npc.i_AbilityUsage = 0;
		//npc.m_flAbilityOrAttack1 = gameTime + 10.0;
		//SDKUnhook(npc.index, SDKHook_Touch, HunterTouchDamageTouch);
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
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
		if(npc.m_flAbilityOrAttack1 < gameTime && flDistanceToTarget > 62500 && flDistanceToTarget < 122500 && npc.m_flReloadDelay < gameTime)
		{
			int rng = GetRandomInt(0,1);
			npc.i_AbilityUsage = rng;
			switch(npc.i_AbilityUsage)
			{
				case 1:
				{
					npc.PlayChargeSound();
					npc.StopPathing();
					npc.AddGesture("ACT_HUNTER_CHARGE_START");
					npc.m_flAbilityOrAttack1 = gameTime + 20.0;
					Hunter_Charge_Enable(npc, gameTime);
					npc.m_flMeleeArmor = 0.5;
					npc.m_flRangedArmor = 0.5;
				}
				case 2:
				{
					npc.StopPathing();
					Hunter_Shooty_Enable(npc, gameTime);
				}
			}
		}

		HunterSelfDefense(npc,gameTime, npc.m_iTarget, npc.i_AbilityUsage); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public void HunterTouchDamageTouch(int entity, int other)
{
	float vecTarget[3]; WorldSpaceCenter(entity, vecTarget );
	if(IsValidEnemy(entity, other, true, true)) //Must detect camo.
	{
		//float radius = 160.0, damage = 10.0;
		//Explode_Logic_Custom(damage, entity, entity, -1, _, radius, _, _, true);
	}
}

static void Hunter_Shooty_Enable(Hunter npc, float gameTime)
{
	npc.m_flDead_Ringer_Invis = gameTime + 2.0;
	npc.m_flAbilityOrAttack0 = gameTime + 5.0;
	npc.m_flDead_Ringer = gameTime + 10.0;
	npc.m_flDead_Ringer_Invis_bool = true;
	npc.m_flNextRangedAttack = gameTime + 0.01;
	npc.SetActivity("ACT_HUNTER_RANGE_ATTACK2_UNPLANTED");
	KillFeed_SetKillIcon(npc.index, "c.a.p.p.e.r");
}

static void Hunter_Charge_Enable(Hunter npc, float gameTime)
{
	npc.m_flDead_Ringer_Invis = gameTime + 2.0;
	npc.m_flAbilityOrAttack0 = gameTime + 2.0;
	npc.m_flDead_Ringer = gameTime + 10.0;
	npc.m_flDead_Ringer_Invis_bool = true;
	npc.StartPathing();
	npc.m_flSpeed = 420.0;
	npc.m_flNextMeleeAttack = gameTime;
	npc.m_flAttackHappens = gameTime;
	int iActivity = npc.LookupActivity("ACT_HUNTER_CHARGE_RUN");
	if(iActivity > 0) npc.StartActivity(iActivity);
}

static bool Hunter_Charge_Disable(Hunter npc, float gameTime)
{
	if(npc.m_flDead_Ringer)
	{
		if(npc.m_flDead_Ringer <= gameTime)
		{
			npc.i_AbilityUsage = 0;
			npc.m_flDead_Ringer_Invis_bool = false;
			npc.m_flDead_Ringer = 0.0;
			int iActivity = npc.LookupActivity("ACT_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_flSpeed = 300.0;
			npc.m_flNextMeleeAttack = gameTime + 1.2;
			npc.m_flAttackHappens = gameTime + 0.50;
			return true;
		}
	}
		
	return false;
}
	

public Action Hunter_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Hunter npc = view_as<Hunter>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Hunter_NPCDeath(int entity)
{
	Hunter npc = view_as<Hunter>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

}

void HunterSelfDefense(Hunter npc, float gameTime, int target, int usage)
{
	if(usage == 1)
	{
		return;
	}

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(usage != 2)
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
						npc.m_iOverlordComboAttack++;
						float damageDealt = 100.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 5.0;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

						// Hit sound
						npc.PlayMeleeHitSound();
					}
					if(npc.m_iOverlordComboAttack >= 5)
					{
						npc.AddGesture("ACT_MELEE_ATTACK1");
						float damageDealt = 200.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt *= 10.0;
						StartBleedingTimer(target, npc.index,100.0, 3, -1, DMG_TRUEDAMAGE, 0);
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.m_flNextMeleeAttack = gameTime + 2.0;
						npc.PlaySkewerSound();
						npc.m_iOverlordComboAttack = 0;
						float maxhealth = float(ReturnEntityMaxHealth(npc.index));
						maxhealth *= 1.0;
						HealEntityGlobal(npc.index, npc.index, maxhealth, 50000.0, 0.0, HEAL_SELFHEAL);
						float ProjLoc[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
						ProjLoc[2] += 70.0;
						ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
						ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
						ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
						TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
					}
				}
				delete swingTrace;
			}
		}

		if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
			{
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);

				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.AddGesture("ACT_HUNTER_MELEE_ATTACK1_VS_PLAYER");
					npc.PlayMeleeSound();
					npc.StartPathing();
							
					npc.m_flAttackHappens = gameTime + 0.50;
					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
					return;
				}
			}
		}
	}
	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack <= gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.FaceTowards(vecTarget, 15000.0);
				KillFeed_SetKillIcon(npc.index, "c.a.p.p.e.r");
				float predict = 1000.0;
				float damage = 100.0;
				WorldSpaceCenter(npc.m_iTarget, vecTarget);
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, predict, _, vecTarget);
				
				npc.FireRocket(vecTarget, damage, predict, "models/weapons/w_bullet.mdl", 2.0);
			}
		}
	}
	
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.25) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayRangedSound();
				npc.SetActivity("ACT_HUNTER_RANGE_ATTACK2_UNPLANTED");//ACT_MP_ATTACK_STAND_ITEM1 | ACT_MP_ATTACK_STAND_MELEE_ALLCLASS
				npc.StopPathing();
				float reloadattack = 0.5, shoot = 0.15;
				
				if(usage == 2)
				{
					reloadattack = 0.05, shoot = 0.05;
					npc.SetActivity("ACT_HUNTER_RANGE_ATTACK2_UNPLANTED");
				}
				npc.m_flNextRangedSpecialAttack = gameTime + shoot;
				npc.m_flNextRangedAttack = gameTime + reloadattack;
			}
		}
	}
}
