#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_SpawnBombCartSounds[] = "mvm/sentrybuster/mvm_sentrybuster_intro.wav";

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav"
};

static const char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav"
};

void VictoriaBreachcart_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Breachcart");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_breachcart");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_breachcart");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_SpawnBombCartSounds);
	PrecacheModel("models/bots/tw2/boss_bot/static_boss_tank.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaBreachcart(vecPos, vecAng, ally, data);
}

methodmap VictoriaBreachcart < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlaSpawnBombCartSound()
 	{
		EmitSoundToAll(g_SpawnBombCartSounds, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.6, 125);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public VictoriaBreachcart(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaBreachcart npc = view_as<VictoriaBreachcart>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		npc.SetActivity("ACT_RIDER_RUN");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = 0;

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.g_TimesSummoned = 0;

		if(data[0])
			npc.g_TimesSummoned = StringToInt(data);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictoriaBreachcart_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaBreachcart_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaBreachcart_ClotThink;
		
		npc.m_flSpeed = 150.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		KillFeed_SetKillIcon(npc.index, "resurfacer");
		npc.m_flMeleeArmor = 2.00;
		npc.m_flRangedArmor = 0.75;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);		
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_bat.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/sum20_hazard_headgear/sum20_hazard_headgear.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		if(npc.g_TimesSummoned == 0)
		{
			npc.m_iWearable2 = npc.EquipItemSeperate("models/bots/tw2/boss_bot/static_boss_tank.mdl");
			SetVariantString("0.3");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}

		return npc;

	}
}

static void VictoriaBreachcart_ClotThink(int iNPC)
{
	VictoriaBreachcart npc = view_as<VictoriaBreachcart>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 10.0);

	if(npc.g_TimesSummoned == 0)
	{
		if(npc.m_fbRangedSpecialOn)
		{
			if(!IsValidEntity(npc.m_iWearable2))
			{
				npc.m_iWearable2 = npc.EquipItemSeperate("models/bots/tw2/boss_bot/static_boss_tank.mdl");
				SetVariantString("0.3");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			}
			else
			{
				float vecTarget[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
				Custom_SDKCall_SetLocalOrigin(npc.m_iWearable2, vecTarget);
			}
		}
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 5000.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		VictoriaBreachcart_Work(npc, GetGameTime(npc.index), flDistanceToTarget);
		npc.StartPathing();
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
			npc.SetGoalEntity(npc.m_iTarget);
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
	}
	npc.PlayIdleAlertSound();
}

static Action VictoriaBreachcart_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaBreachcart npc = view_as<VictoriaBreachcart>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void VictoriaBreachcart_ClotDeath(int entity)
{
	VictoriaBreachcart npc = view_as<VictoriaBreachcart>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("rd_robot_explosion_smoke_linger", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
}

static void VictoriaBreachcart_Work(VictoriaBreachcart npc, float gameTime, float distance)
{
	if(npc.m_flNextRangedAttack < gameTime)
	{
		int health = ReturnEntityMaxHealth(npc.index) / 15;

		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
		if(MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
		{
			int entity = NPC_CreateByName("npc_bombcart", -1, pos, ang, GetTeam(npc.index), "EX");
			if(entity > MaxClients)
			{
				if(GetTeam(npc.index) != TFTeam_Red)
					Zombies_Currently_Still_Ongoing++;
				
				SetEntProp(entity, Prop_Data, "m_iHealth", health);
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
				
				fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index] * 0.85;
				fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index] * 2.0;
				view_as<CClotBody>(entity).m_iBleedType = BLEEDTYPE_METAL;
				
				npc.PlaSpawnBombCartSound();
				npc.AddGesture("ACT_RIDER_CHEER");
				float Cooldown = 5.0;
				if(NpcStats_VictorianCallToArms(npc.index))
					Cooldown *= 0.75;
				npc.m_flNextRangedAttack = gameTime + Cooldown;
			}
		}
	}
	
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = gameTime+0.4;
				npc.m_flAttackHappens_bullshit = gameTime+0.54;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				Handle swingTrace;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 20.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt*=7.5;
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
						ParticleEffectAt(vecHit, "drg_cow_explosion_sparkles_blue", 1.5);
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}