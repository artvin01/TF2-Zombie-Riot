#pragma semicolon 1
#pragma newdecls required

//Todo: Add lastman duplication for this Announce
//He will duplicate himself 4 times weaker per dupe

static const char g_DeathSounds[][] = {
	"npc/dog/dog_scared1.wav",
};
static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
static const char g_IdleAlertedSounds[][] = {
	"npc/dog/dog_angry1.wav",
	"npc/dog/dog_angry2.wav",
	"npc/dog/dog_angry3.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"vehicles/v8/vehicle_impact_heavy1.wav",
	"vehicles/v8/vehicle_impact_heavy2.wav",
	"vehicles/v8/vehicle_impact_heavy3.wav",
	"vehicles/v8/vehicle_impact_heavy4.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static char g_HeIsAwake[][] = {
	"vo/halloween_boss/knight_spawn.mp3",
	"npc/ichthyosaur/attack_growl1.wav",
};
static char g_ExplosiveBo[][] = {
	"ambient/explosions/explode_4.wav",
};
static char g_AngerSound[][] = {
	"npc/dog/dog_on_dropship.wav",
};

//static bool b_Boss_Minion[MAXENTITIES];
static int i_Data;
void Merlton_Boss_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Merlton");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_merlton_boss");
	strcopy(data.Icon, sizeof(data.Icon), "tank");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	i_Data = NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_HeIsAwake);
	PrecacheSoundArray(g_ExplosiveBo);
	PrecacheSoundArray(g_AngerSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Merlton_Boss(vecPos, vecAng, ally, data);
}

methodmap Merlton_Boss < CClotBody
{
	property float fl_Spawn_Minions
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property int i_Cant_Find_Allies
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
		if(this.m_fbGunout)
		{
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		else
		{
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], _, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[0], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHeIsAwake()
	{
		EmitSoundToAll(g_HeIsAwake[0], _, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2);
		EmitSoundToAll(g_HeIsAwake[1], _, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2);
	}
	public void PlayExplosiveBoo()
	{
		EmitSoundToAll(g_ExplosiveBo[GetRandomInt(0, sizeof(g_ExplosiveBo) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_AngerSound[GetRandomInt(0, sizeof(g_AngerSound) - 1)], _, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Merlton_Boss(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool clone = StrContains(data, "clone") != -1;

		Merlton_Boss npc = view_as<Merlton_Boss>(CClotBody(vecPos, vecAng, "models/dog.mdl", clone ? "0.65" : "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = clone ? 1 : 3;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_fbGunout = clone ? true : false;
		npc.Anger = clone ? true : false;

		//b_Boss_Minion[npc.index] = false;
		Is_a_Medic[npc.index] = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.i_Cant_Find_Allies = 0;
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;    
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		func_NPCDeath[npc.index] = Merlton_Boss_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Merlton_Boss_OnTakeDamage;
		func_NPCThink[npc.index] = Merlton_Boss_ClotThink;

		//IDLE
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;

		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		if(!clone)
		{
			npc.PlayHeIsAwake();
			npc.fl_Spawn_Minions = GetGameTime(npc.index) + 10.0;
		}
		else
		{
			//b_Boss_Minion[npc.index] = true;
			Is_a_Medic[npc.index] = true;
		}

		if(StrContains(data, "enraged") != -1)
		{
			npc.Anger = true;
			npc.PlayAngerSound();
		}
		
		return npc;
	}
}

static void Merlton_Boss_ClotThink(int iNPC)
{
	Merlton_Boss npc = view_as<Merlton_Boss>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	float gameTime = GetGameTime(npc.index);
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			Annonce_Spawn(npc, 2);
		}
	}
	
	if(!npc.Anger)
	{
		npc.m_iTargetAlly = GetClosestAlly(npc.index);

		int closest = npc.m_iTargetAlly;

		if(npc.fl_Spawn_Minions <= gameTime)
		{
			npc.fl_Spawn_Minions = gameTime + 10.0;
			Annonce_Spawn(npc, 3);//yes ik i took it off my npc
		}

		if(IsValidAlly(npc.index, closest) /*&& Merlton_IsNotMyClone(npc.index, closest)*/)
		{
			npc.SetGoalEntity(closest);
			float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
		
			float VecLook[3]; WorldSpaceCenter(npc.index, VecLook);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecLook, true);
			if(flDistanceToTarget < 250000)
			{
				
				if(flDistanceToTarget < 62500)
				{
					npc.StopPathing();
				}
				else
				{
					npc.StartPathing();
				}
				
				//Add cd
				if(npc.m_flAttackHappens_bullshit <= gameTime)
				{
					int color[4] = {40, 250, 64, 200};

					WorldSpaceCenter(closest, VecLook);
					npc.FaceTowards(VecLook, 2000.0);
					npc.m_flAttackHappens_bullshit = gameTime + 0.3;
					RemoveSpecificBuff(closest, "MERLT0N-BUFF");
					ApplyStatusEffect(closest, closest, "MERLT0N-BUFF", 6.0);
					
					spawnRing_Vectors(VecLook, 100.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, 0.3, 5.0, 8.0, 3, 200.0 * 2.0);	
				}
			}
		}
		/*else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}*/

		if(npc.m_flGetClosestTargetTime < gameTime)
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			
			if(npc.m_iTargetAlly <= 0)//No valid allies, anger mode.
			{
				if(npc.i_Cant_Find_Allies >= 3)//rng chance every 3-4s it looks for one again reason why it's max 3
				{
					npc.m_iTargetAlly = 0;
					npc.m_iTarget = GetClosestTarget(npc.index);
					npc.Anger = true;
					npc.PlayAngerSound();
				}
				else
				{
					npc.i_Cant_Find_Allies++;
				}
			}
			else
			{
				npc.i_Cant_Find_Allies = 0;
				npc.StartPathing();
			}
		}
	}
	else
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}
			
			Merlton_SelfDefense(npc, GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.SetActivity("ACT_RUN");
		}
		if(npc.m_flGetClosestTargetTime < gameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			npc.StartPathing();
		}
	}
	
	npc.PlayIdleAlertSound();
}

/*
static bool Merlton_IsNotMyClone(int provider, int entity)
{
	if(b_Boss_Minion[entity])
	{
		return false;
	}
	return true;
}*/

public Action Merlton_Boss_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Merlton_Boss npc = view_as<Merlton_Boss>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		if(!npc.Anger && Health <= MaxHealth/2)
		{
			npc.Anger = true;
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 8.0;
		}
	}
	
	return Plugin_Changed;
}

public void Merlton_Boss_NPCDeath(int entity)
{
	Merlton_Boss npc = view_as<Merlton_Boss>(entity);

	npc.PlayDeathSound();

	//b_Boss_Minion[npc.index] = false;
}

void Merlton_SelfDefense(Merlton_Boss npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {100.0 , 100.0 , 100.0};
			static float MinVec[3] = {-100.0, -100.0, -100.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = npc.m_fbGunout ? 65.0 : 120.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;

					if(npc.Anger && !npc.m_fbGunout)
					{
						float explosivedmg = 80.0, radius = 160.0;
						Explode_Logic_Custom(explosivedmg, npc.index, npc.index, -1, _, radius, _, _, true);
						float pos[3];
						WorldSpaceCenter(target, pos);
						ParticleEffectAt(pos, "ExplosionCore_MidAir", 0.2);
						npc.PlayExplosiveBoo();
						
						damageDealt *= 2.0;
						CreateEarthquake(pos, 0.2, radius, 10.0, 20.0);
					}

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
		float DistExtra = 1.25;//if he somehow goes into the air, lets not be unfair
		if (npc.IsOnGround() && npc.Anger)
			DistExtra = 2.5;

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * DistExtra))
		{
			int Enemy_I_See;
			
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGestureViaSequence("pound");
				float duration = 0.95;
				if(npc.Anger)
				{
					duration = 0.45;
				}
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + duration;
			}
		}
	}
}

static void Annonce_Spawn(Merlton_Boss npc, int amount = 1)
{
	Enemy enemy;
	enemy.Index = i_Data;//NPC_GetByPlugin("npc_annonce_brawl");
	int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/16;
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Outlined = true;
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 0.85;
	enemy.ExtraSize = 1.0;
	enemy.Data = "clone";
	enemy.Team = GetTeam(npc.index);
	for(int i; i<amount; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += amount;
}