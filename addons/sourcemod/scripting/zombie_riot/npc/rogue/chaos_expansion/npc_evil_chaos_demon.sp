#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};


void ChaosEvilDemon_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	PrecacheModel("models/props_halloween/eyeball_projectile.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Evil Demon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_evil_demon");
	strcopy(data.Icon, sizeof(data.Icon), "spy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosEvilDemon(vecPos, vecAng, team);
}
methodmap ChaosEvilDemon < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,80);

	}
	
	property float m_flHealCooldownDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property bool m_bFakeClone
	{
		public get()		{	return i_RaidGrantExtra[this.index] < 0;	}
	}
	public ChaosEvilDemon(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosEvilDemon npc = view_as<ChaosEvilDemon>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.4", "15000", ally, _, true));
		
		i_NpcWeight[npc.index] = 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChaosEvilDemon_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChaosEvilDemon_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChaosEvilDemon_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 125.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_acr_hookblade/c_acr_hookblade.mdl");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/dec24_poleur_voyeur_style1/dec24_poleur_voyeur_style1.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/dec24_laire_filteure/dec24_laire_filteure.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 65, 65, 65, 200);
		SetEntityRenderColor(npc.m_iWearable3, 65, 65, 65, 255);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 65, 255);
		SetEntityRenderColor(npc.m_iWearable1, 65, 65, 65, 255);

		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {10.0,0.0,0.0});
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {10.0,0.0,-15.0});
		npc.StartPathing();
		
		return npc;
	}
}

public void ChaosEvilDemon_ClotThink(int iNPC)
{
	ChaosEvilDemon npc = view_as<ChaosEvilDemon>(iNPC);
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

	if(npc.m_flHealCooldownDo < GetGameTime(npc.index))
	{
		npc.m_flHealCooldownDo = GetGameTime(npc.index) + 0.5;
		ExpidonsaGroupHeal(npc.index, 1000.0, 99, 3000.0, 1.0, false,Expidonsa_DontHealSameIndex, ChaosEvilDemonAfterBuff);
		DesertYadeamDoHealEffect(npc.index, 1000.0);
	}

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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ChaosEvilDemonSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ChaosEvilDemon_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosEvilDemon npc = view_as<ChaosEvilDemon>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ChaosEvilDemon_NPCDeath(int entity)
{
	ChaosEvilDemon npc = view_as<ChaosEvilDemon>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
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

void ChaosEvilDemonSelfDefense(ChaosEvilDemon npc, float gameTime, int target, float distance)
{

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					int ElementalDamage = 200;
					float damageDealt = 450.0;

					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					Elemental_AddChaosDamage(target, npc.index, ElementalDamage, true, true);
					
					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
		return;
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;
			
			if(npc.m_iTarget > 0)
			{	
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.PlayRangedSound();
				int ElementalDamage = 150;
				float damageDealt = 120.0;

				int entity = npc.FireArrow(vecTarget, damageDealt, 800.0, "models/props_halloween/eyeball_projectile.mdl");
				i_ChaosArrowAmount[entity] = ElementalDamage;
				
				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);

					SetEntityRenderColor(entity, 100, 100, 255, 255);
					
					WorldSpaceCenter(entity, vecTarget);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "tranq_distortion_trail", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}
		}
		return;
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}		
	}
	if(gameTime > npc.m_flNextRangedAttack)
	{
		if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_THROW");
						
				npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.15;
				npc.m_flNextRangedAttack = gameTime + 1.0;
			}
		}		
	}
}


void ChaosEvilDemonAfterBuff(int entity, int victim)
{
	ApplyStatusEffect(entity, victim, "War Cry", 0.6);	
	ApplyStatusEffect(entity, victim, "Defensive Backup", 0.6);	
	ApplyStatusEffect(entity, victim, "Squad Leader", 0.6);

	//buff self too
	ApplyStatusEffect(entity, entity, "War Cry", 0.6);	
	ApplyStatusEffect(entity, entity, "Defensive Backup", 0.6);	
	ApplyStatusEffect(entity, entity, "Squad Leader", 0.6);


	float vecSelf[3];
	WorldSpaceCenter(entity, vecSelf);
	float vecAlly[3];
	WorldSpaceCenter(victim, vecAlly);
	//If it healed someone, heal himself!
	int maxhealth = ReturnEntityMaxHealth(entity);
	HealEntityGlobal(entity, entity, float(maxhealth) / 500, 1.0, 0.0, HEAL_SELFHEAL);
	TE_SetupBeamPoints(vecSelf, vecAlly, Shared_BEAM_Laser, 0, 0, 0, 0.25, 10.0, 10.0, 0, 1.0, {65,255,65,125}, 3);
	TE_SendToAll(0.0);
}