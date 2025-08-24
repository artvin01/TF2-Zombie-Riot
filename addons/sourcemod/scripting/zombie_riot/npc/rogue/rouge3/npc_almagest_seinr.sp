#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_paincrticialdeath01.mp3",
	"vo/mvm/mght/heavy_mvm_m_paincrticialdeath02.mp3",
	"vo/mvm/mght/heavy_mvm_m_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_laughevil01.mp3",
	"vo/mvm/mght/heavy_mvm_m_laughevil02.mp3",
	"vo/mvm/mght/heavy_mvm_m_laughevil03.mp3",
	"vo/mvm/mght/heavy_mvm_m_laughevil04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"vo/mvm/mght/heavy_mvm_m_meleeing01.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing02.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing03.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing04.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing05.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing06.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing07.mp3",
	"vo/mvm/mght/heavy_mvm_m_meleeing08.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/cbar_hitbod_robo01.wav",
	"mvm/melee_impacts/cbar_hitbod_robo02.wav",
	"mvm/melee_impacts/cbar_hitbod_robo03.wav",
};

static const char g_PassiveSound[][] = {
	"mvm/giant_heavy/giant_heavy_loop.wav",
};


void AlmagestSeinr_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	PrecacheModel("models/bots/heavy_boss/bot_heavy_boss.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seinr");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_almagest_seinr");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Interitus;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return AlmagestSeinr(vecPos, vecAng, team);
}

methodmap AlmagestSeinr < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.25;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public AlmagestSeinr(float vecPos[3], float vecAng[3], int ally)
	{
		AlmagestSeinr npc = view_as<AlmagestSeinr>(CClotBody(vecPos, vecAng, "models/bots/heavy_boss/bot_heavy_boss.mdl", "1.5", "3000", ally, false, true));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.PlayPassiveSound();
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		func_NPCDeath[npc.index] = view_as<Function>(AlmagestSeinr_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(AlmagestSeinr_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(AlmagestSeinr_ClotThink);
		
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}
		npc.StartPathing();
		npc.m_flSpeed = 200.0;
		fl_RangedArmor[npc.index] = 0.35;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/mvm_loot/heavy/robo_ushanka.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetEntityRenderFx(npc.m_iWearable2, RENDERFX_DISTORT);
		SetEntityRenderColor(npc.m_iWearable2, 125, 125, 255, 200);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		
		float flPos[3], flAng[3];
				
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "head", {5.0,0.0,-5.0});
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "head", {5.0,0.0,-20.0});

		int particle = ParticleEffectAt(vecPos, "utaunt_snowring_space_parent", 0.0);
		SetParent(npc.index, particle);
		npc.m_iWearable5 = particle;
		

		return npc;
	}
}

public void AlmagestSeinr_ClotThink(int iNPC)
{
	AlmagestSeinr npc = view_as<AlmagestSeinr>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	GrantEntityArmor(iNPC, true, 0.5, 0.25, 0);
	
	if(npc.m_flArmorCount <= 0.0)
	{	
		if(IsValidEntity(npc.m_iWearable5))
		{
			npc.m_flSpeed = 340.0;
			fl_RangedArmor[npc.index] = 1.0;
			RemoveEntity(npc.m_iWearable5);
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
	//	npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
		AlmagestSeinrSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action AlmagestSeinr_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	AlmagestSeinr npc = view_as<AlmagestSeinr>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
	//	npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(npc.m_flArmorCount > 0.0)
	{
		ApplyStatusEffect(npc.index, attacker, "Freeze", 2.0);

		if(IsValidEntity(weapon))
		{
			char buffer[36];
			if(GetEntityClassname(weapon, buffer, sizeof(buffer)) && !StrContains(buffer, "tf_weap"))
				ApplyTempAttrib(weapon, 6, 1.1, 2.0);
		}
		if(attacker <= MaxClients)
			if(!HasSpecificBuff(attacker, "Fluid Movement"))
				TF2_StunPlayer(attacker, 2.0, 0.35, TF_STUNFLAG_SLOWDOWN);
	}
	
	return Plugin_Changed;
}


public void AlmagestSeinr_NPCDeath(int entity)
{
	AlmagestSeinr npc = view_as<AlmagestSeinr>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	npc.StopPassiveSound();
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

void AlmagestSeinrSelfDefense(AlmagestSeinr npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))//Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 450.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.5;

					Elemental_AddWarpedDamage(target, npc.index, 400, true, true, true);


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
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.5;
			}
		}
	}
}