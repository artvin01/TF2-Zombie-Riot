#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[] = "mvm/giant_soldier/giant_soldier_explode.wav";
static const char g_RangeAttackSounds[] = "player/taunt_tank_shoot.wav";
static const char g_MeleeHitSounds[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav"
};

void VictoriaTank_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Tank");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victorian_tank");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_tank");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSound(g_DeathSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/items/taunts/tank/tank.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return VictoriaTank(vecPos, vecAng, ally);
}

methodmap VictoriaTank < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds, this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
	{
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public VictoriaTank(float vecPos[3], float vecAng[3], int ally)
	{
		VictoriaTank npc = view_as<VictoriaTank>(CClotBody(vecPos, vecAng, "models/player/items/taunts/tank/tank.mdl", "2.5", "300000", ally, _, true));
		
		i_NpcWeight[npc.index] = 999;
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = VictoriaTank_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaTank_ClotThink;
		
		f_NpcTurnPenalty[npc.index] = 0.5;
		npc.m_flSpeed = 90.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;

		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.7;

		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	

		return npc;
	}
}

static void VictoriaTank_ClotThink(int iNPC)
{
	VictoriaTank npc = view_as<VictoriaTank>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 20.0);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		VictoriaTank_Work(npc, gameTime, distance);
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		npc.StartPathing();
		
	}
	else
	{
		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
	}
}

static void VictoriaTank_ClotDeath(int entity)
{
	VictoriaTank npc = view_as<VictoriaTank>(entity);

	float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);

	npc.PlayDeathSound();

	TE_Particle("asplode_hoodoo", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	int team = GetTeam(npc.index);

	int health = RoundToCeil(ReturnEntityMaxHealth(npc.index) / 7.5);
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	for(int i; i < 3; i++)
	{
		int other = NPC_CreateByName("npc_welder", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
	health = RoundToCeil(ReturnEntityMaxHealth(npc.index) / 8.5);
	for(int i; i < 2; i++)
	{
		int other = NPC_CreateByName("npc_pulverizer", -1, pos, ang, team);
		if(other > MaxClients)
		{
			if(team != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(other, Prop_Data, "m_iHealth", health);
			SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index] * 1.43;
			fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
			b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
			b_StaticNPC[other] = b_StaticNPC[npc.index];
			if(b_StaticNPC[other])
				AddNpcToAliveList(other, 1);
		}
	}
}

static void VictoriaTank_Work(VictoriaTank npc, float gameTime, float distance)
{
	if(npc.m_flNextRangedAttack < gameTime)
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			float damageDeal = 600.0;
			float ProjectileSpeed = 1400.0;

			if(NpcStats_VictorianCallToArms(npc.index))
				ProjectileSpeed *= 1.25;

			npc.PlayRangeSound();

			int entity = npc.FireRocket(vecTarget, damageDeal, ProjectileSpeed,_,_,_,45.0);
			if(entity != -1)
			{
				//max duration of 4 seconds beacuse of simply how fast they fire
				CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
			npc.m_flNextRangedAttack = gameTime + 3.00;
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
						float damageDealt = 100.0;
						if(ShouldNpcDealBonusDamage(target))
							damageDealt=19721121.0;
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
