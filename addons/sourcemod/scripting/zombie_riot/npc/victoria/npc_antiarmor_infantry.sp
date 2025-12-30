#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav"
};

static const char g_HurtSounds[] = "npc/metropolice/vo/chuckle.wav";

static const char g_IdleAlertedSounds[] = "npc/metropolice/vo/pickupthecan2.wav";

static const char g_RangedAttackSounds[] = "weapons/quake_rpg_fire_remastered.wav";

void VictoriaAntiarmorInfantry_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Anti-Armor Infantry");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_antiarmor_infantry");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_antiarmor_infantry");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSound(g_HurtSounds);
	PrecacheSound(g_IdleAlertedSounds);
	PrecacheSound(g_RangedAttackSounds);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaAntiarmorInfantry(vecPos, vecAng, ally);
}

methodmap VictoriaAntiarmorInfantry < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
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
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public VictoriaAntiarmorInfantry(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaAntiarmorInfantry npc = view_as<VictoriaAntiarmorInfantry>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.2", "9000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN_RPG");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		func_NPCDeath[npc.index] = view_as<Function>(VictoriaAntiarmorInfantry_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(VictoriaAntiarmorInfantry_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(VictoriaAntiarmorInfantry_ClotThink);
		
		//IDLE
		KillFeed_SetKillIcon(npc.index, "rocketlauncher_directhit");
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 150.0;
		
		int skin = 1;

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_rocket_launcher.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/grfs_soldier.mdl", .model_size=3.5);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum24_aimframe/sum24_aimframe.mdl", .model_size=3.5);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

static void VictoriaAntiarmorInfantry_ClotThink(int iNPC)
{
	VictoriaAntiarmorInfantry npc = view_as<VictoriaAntiarmorInfantry>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
		VictoriaAntiarmorInfantrySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void VictoriaAntiarmorInfantry_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaAntiarmorInfantry npc = view_as<VictoriaAntiarmorInfantry>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

static void VictoriaAntiarmorInfantry_NPCDeath(int entity)
{
	VictoriaAntiarmorInfantry npc = view_as<VictoriaAntiarmorInfantry>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
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

static void VictoriaAntiarmorInfantrySelfDefense(VictoriaAntiarmorInfantry npc, float gameTime, int target, float distance)
{
	if(!npc.m_flNextRangedAttackHappening)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_flNextRangedAttack = gameTime + 0.25;
				npc.m_flNextRangedAttackHappening = 1.0;
				npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_RPG");
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}		
		return;
	}
	if(npc.m_flNextRangedAttack && npc.m_flNextRangedAttack != 5.0)
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{
			float EnemyPos[3];
			WorldSpaceCenter(npc.m_iTarget, EnemyPos);
			npc.FaceTowards(EnemyPos, 15000.0);
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			float RocketDamage = 100.0;
			if(NpcStats_VictorianCallToArms(npc.index))
			{
				RocketDamage *= 1.5;
			}
			int entity = npc.FireRocket(EnemyPos, RocketDamage, 1500.0);
			if(entity != -1)
			{
				SetEntProp(entity, Prop_Send, "m_bCritical", true);
			}
			npc.m_flNextRangedAttack = 5.0;
			npc.PlayRangedSound();
			npc.m_flDoingAnimation = gameTime + 0.25;
		}
	}
	if(npc.m_flNextRangedAttack && npc.m_flNextRangedAttack == 5.0)
	{
		KillFeed_SetKillIcon(npc.index, "sword");
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		npc.SetActivity("ACT_ACHILLES_RUN_DAGGER");
		npc.m_flSpeed = 375.0;
		return;
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 60.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 2.0;


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
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}
