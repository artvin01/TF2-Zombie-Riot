#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/scanner/scanner_explode_crash2.wav",
};

static const char g_HurtSounds[][] = {
	"npc/scanner/scanner_pain1.wav",
	"npc/scanner/scanner_pain2.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"npc/scanner/scanner_alert1.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"ambient/materials/metal_groan.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/scanner/cbot_discharge1.wav",
};

void Iberia_AntiSeaRobot_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Anti Sea Robot");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_anti_sea_robot");
	strcopy(data.Icon, sizeof(data.Icon), "tank");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Iberia_AntiSeaRobot(vecPos, vecAng, team, data);
}

methodmap Iberia_AntiSeaRobot < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	
	public Iberia_AntiSeaRobot(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Iberia_AntiSeaRobot npc = view_as<Iberia_AntiSeaRobot>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.35", "3500", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.g_TimesSummoned = 0;

		if(data[0])
			npc.g_TimesSummoned = StringToInt(data);
			
		npc.m_flMeleeArmor = 2.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Iberia_AntiSeaRobot_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Iberia_AntiSeaRobot_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Iberia_AntiSeaRobot_ClotThink);
		
		
		npc.StartPathing();
		npc.m_flSpeed = 230.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime() + GetRandomFloat(5.0, 15.0);
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetMoraleDoIberia(npc.index, 35.0);
		

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
		
		if(npc.g_TimesSummoned == 0)
		{
			npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-120.0, true);
			SetVariantString("2.5");
			AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		}

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);

		return npc;
	}
}

public void Iberia_AntiSeaRobot_ClotThink(int iNPC)
{
	Iberia_AntiSeaRobot npc = view_as<Iberia_AntiSeaRobot>(iNPC);
	if(npc.g_TimesSummoned == 0)
	{
		if(!IsValidEntity(npc.m_iWearable6))
		{
			npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-120.0,true);
			SetVariantString("2.5");
			AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
			SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		}
		else
		{
			float vecTarget[3];
			GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
			vecTarget[2] -= 100.0;
			Custom_SDKCall_SetLocalOrigin(npc.m_iWearable6, vecTarget);
		}
	}

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
	IberiaMoraleGivingDo(iNPC, GetGameTime(npc.index));
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
		Iberia_AntiSeaRobotSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Iberia_AntiSeaRobot_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Iberia_AntiSeaRobot npc = view_as<Iberia_AntiSeaRobot>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );

	float VecSelfNpc[3]; WorldSpaceCenter(victim, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget > (275.0 * 275.0))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}


public void Iberia_AntiSeaRobot_NPCDeath(int entity)
{
	Iberia_AntiSeaRobot npc = view_as<Iberia_AntiSeaRobot>(entity);
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

void Iberia_AntiSeaRobotSelfDefense(Iberia_AntiSeaRobot npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 300.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 12.0;

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
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_,0.75);
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				if(NpcStats_IberiaIsEnemyMarked(npc.m_iTarget))
					npc.m_flNextMeleeAttack = gameTime + 0.35;
			}
		}
	}
}