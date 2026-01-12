#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_AngerSounds[][] =
{
	"npc/roller/mine/rmine_taunt2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

static int HitEnemies[16];
static int LaserSprite;

#define SPRITE_SPRITE	"materials/sprites/laserbeam.vmt"

void FirstToTalk_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_AngerSounds);
	LaserSprite = PrecacheModel(SPRITE_SPRITE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The First To Talk");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_firsttotalk");
	strcopy(data.Icon, sizeof(data.Icon), "ds_firsttotalk");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FirstToTalk(vecPos, vecAng, team);
}

methodmap FirstToTalk < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayAngerSound()
 	{
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public FirstToTalk(float vecPos[3], float vecAng[3], int ally)
	{
		FirstToTalk npc = view_as<FirstToTalk>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "5000", ally, false, true));
		// 21000 x 0.15

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcWeight[npc.index] = 4;
		npc.m_bisWalking = true;
		npc.SetActivity("ACT_SEABORN_WALK_FIRST_1");
		KillFeed_SetKillIcon(npc.index, "huntsman_flyingburn");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = FirstToTalk_NPCDeath;
		func_NPCThink[npc.index] = FirstToTalk_ClotThink;
		
		npc.m_flSpeed = 200.0;	// 0.8 x 250
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 10.0;
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/hw2013_octo_face/hw2013_octo_face.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 100, 100, 255, 255);

		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		vecMe[2] += 500.0;
		npc.m_iWearable1 = ParticleEffectAt(vecMe, "env_rain_128", -1.0);
		SetParent(npc.index, npc.m_iWearable1);
		return npc;
	}
}

public void FirstToTalk_ClotThink(int iNPC)
{
	FirstToTalk npc = view_as<FirstToTalk>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0, _,vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);

				npc.PlayMeleeSound();
				int entity = npc.FireArrow(vecTarget, 90.0, 1200.0, "models/weapons/w_bugbait.mdl");
				// 600 x 0.15

				i_NervousImpairmentArrowAmount[entity] = 36;
				// 600 x 0.4 x 0.15

				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);
					
					SetEntityRenderColor(entity, 100, 100, 255, 255);
					
					WorldSpaceCenter(entity, vecTarget);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "rockettrail_bubbles", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}
		}

		if(distance < 250000.0 && npc.m_flNextMeleeAttack < gameTime)	// 2.5 * 200
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				if(npc.m_flNextRangedAttack < gameTime)
				{
					npc.PlayAngerSound();
					npc.m_bisWalking = false;
					npc.SetActivity("ACT_SEABORN_FIRST_ATTACK_2");
					b_NpcIsInvulnerable[npc.index] = true;
					
					vecTarget[2] += 10.0;

					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(npc.index));
					pack.WriteFloat(vecTarget[0]);
					pack.WriteFloat(vecTarget[1]);
					pack.WriteFloat(vecTarget[2]);

					CreateTimer(1.0, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(1.25, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(1.5, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(1.75, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(2.0, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(2.25, FirstToTalk_TimerShoot, pack, TIMER_FLAG_NO_MAPCHANGE);

					CreateTimer(3.0, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.25, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.5, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.75, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(4.0, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(4.25, FirstToTalk_TimerAttack, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);

					spawnRing_Vectors(vecTarget, 325.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, 4.5, 6.0, 0.1, 1);

					npc.m_flDoingAnimation = gameTime + 3.0;
					npc.m_flNextMeleeAttack = gameTime + 5.0;
					npc.m_flNextRangedAttack = gameTime + 35.0;
				}
				else
				{
					npc.AddGesture("ACT_SEABORN_FIRST_ATTACK_1");
					
					npc.m_flAttackHappens = gameTime + 0.35;

					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 3.0;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
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

			if(b_NpcIsInvulnerable[npc.index])
			{
				b_NpcIsInvulnerable[npc.index] = false;
				npc.m_bisWalking = true;
				npc.SetActivity("ACT_SEABORN_WALK_FIRST_1");
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action FirstToTalk_TimerShoot(Handle timer, DataPack pack)
{
	pack.Reset();
	FirstToTalk npc = view_as<FirstToTalk>(EntRefToEntIndex(pack.ReadCell()));
	if(npc.index != INVALID_ENT_REFERENCE)
	{
		float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
		vecPos[2] += 100.0;

		npc.PlayMeleeSound();

		int entity = npc.FireArrow(vecPos, 90.0, 2000.0, "models/weapons/w_bugbait.mdl");
		if(entity != -1)
		{
			if(IsValidEntity(f_ArrowTrailParticle[entity]))
				RemoveEntity(f_ArrowTrailParticle[entity]);
			
			SetEntityRenderColor(entity, 100, 100, 255, 255);
			
			WorldSpaceCenter(entity, vecPos);
			f_ArrowTrailParticle[entity] = ParticleEffectAt(vecPos, "rockettrail_bubbles", 3.0);
			SetParent(entity, f_ArrowTrailParticle[entity]);
			f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
		}
	}
	return Plugin_Stop;
}

public Action FirstToTalk_TimerAttack(Handle timer, DataPack pack)
{
	pack.Reset();
	FirstToTalk npc = view_as<FirstToTalk>(EntRefToEntIndex(pack.ReadCell()));
	if(npc.index != INVALID_ENT_REFERENCE)
	{
		float vecPos[3];
		vecPos[0] = pack.ReadFloat();
		vecPos[1] = pack.ReadFloat();
		vecPos[2] = pack.ReadFloat();

		//spawnRing_Vectors(vecPos, 10.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.4, 6.0, 0.1, 1, 650.0);

		Zero(HitEnemies);
		TR_EnumerateEntitiesSphere(vecPos, 325.0 * 0.75, PARTITION_NON_STATIC_EDICTS, FirstToTalk_EnumerateEntitiesInRange, npc.index);

		// Hits the target with the highest armor within range

		int victim;
		int armor = -9999999;
		for(int i; i < sizeof(HitEnemies); i++)
		{
			if(!HitEnemies[i])
				break;
			
			int myArmor = 1;
			if(HitEnemies[i] <= MaxClients)
				myArmor = Armor_Charge[HitEnemies[i]];
			
			if(myArmor > armor)
			{
				victim = HitEnemies[i];
				armor = myArmor;
			}
		}

		if(victim)
		{
			WorldSpaceCenter(victim, vecPos);
			ParticleEffectAt(vecPos, "water_bulletsplash01", 3.0);

			float vecPos2[3];
			vecPos2[0] = vecPos[0];
			vecPos2[1] = vecPos[1];
			vecPos2[2] = vecPos[2] + 2000.0;

			TE_SetupBeamPoints(vecPos, vecPos2, LaserSprite, 0, 0, 0, 1.0, 1.0, 1.2, 1, 1.0, {50, 50, 255, 255}, 0);
			TE_SendToAll();

			SDKHooks_TakeDamage(victim, npc.index, npc.index, 90.0, DMG_BULLET);
			// 600 x 0.15
			
			Elemental_AddNervousDamage(victim, npc.index, 36);
			// 600 x 0.4 x 0.15
		}
	}
	return Plugin_Stop;
}

public bool FirstToTalk_EnumerateEntitiesInRange(int victim, int attacker)
{
	if(IsValidEnemy(attacker, victim, true))
	{
		for(int i; i < sizeof(HitEnemies); i++)
		{
			if(!HitEnemies[i])
			{
				HitEnemies[i] = victim;
				return true;
			}
		}

		return false;
	}

	return true;
}

public Action FirstToTalk_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	FirstToTalk npc = view_as<FirstToTalk>(victim);
	if(b_NpcIsInvulnerable[npc.index])
		damage = 0.0;
	
	return Plugin_Changed;
}

void FirstToTalk_NPCDeath(int entity)
{
	FirstToTalk npc = view_as<FirstToTalk>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
