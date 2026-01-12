#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/halloween_boss/knight_pain01.mp3",
	"vo/halloween_boss/knight_pain02.mp3",
	"vo/halloween_boss/knight_pain03.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"vo/halloween_boss/knight_attack01.mp3",
	"vo/halloween_boss/knight_attack02.mp3",
	"vo/halloween_boss/knight_attack03.mp3",
	"vo/halloween_boss/knight_attack04.mp3"
};

static char gExplosive1;
static char gLaser1;

void IsharmlaTrans_MapStart()
{
	PrecacheModel("models/bots/headless_hatman.mdl");
	PrecacheModel("models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
	PrecacheSound("ui/halloween_boss_summoned_fx.wav");
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ishar'mla, Heart of Corruption");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_isharmla_trans");
	strcopy(data.Icon, sizeof(data.Icon), "ds_isharmla");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MISSION|MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return IsharmlaTrans(vecPos, vecAng, team);
}

methodmap IsharmlaTrans < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 12.0);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)]);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpawnSound()
	{
		EmitSoundToAll("ui/halloween_boss_summoned_fx.wav");
	}
	
	public IsharmlaTrans(float vecPos[3], float vecAng[3], int ally)
	{
		IsharmlaTrans npc = view_as<IsharmlaTrans>(CClotBody(vecPos, vecAng, "models/bots/headless_hatman.mdl", "1.35", "45000", ally, false, true));
		
		i_NpcWeight[npc.index] = 6;
		npc.SetActivity("ACT_MP_STAND_ITEM1");
		KillFeed_SetKillIcon(npc.index, "headtaker");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = IsharmlaTrans_NPCDeath;
		func_NPCThink[npc.index] = IsharmlaTrans_ClotThink;
		
		npc.m_flSpeed = 250.0;//100.0;	// 0.6 - 0.2 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_bDissapearOnDeath = true;
		npc.Anger = false;
		npc.m_flMeleeArmor = 1.5;

		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", FAR_FUTURE);	
		f_ExtraOffsetNpcHudAbove[npc.index] = 35.0;
		
		SetEntityRenderColor(npc.index, 55, 55, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bigaxe/c_bigaxe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.DispatchParticleEffect(npc.index, "halloween_boss_summon", vecPos, vecAng, vecPos);
		npc.PlaySpawnSound();
		
		return npc;
	}
}

public void IsharmlaTrans_ClotThink(int iNPC)
{
	IsharmlaTrans npc = view_as<IsharmlaTrans>(iNPC);

	ResolvePlayerCollisions_Npc(iNPC, /*damage crush*/ 5.0);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
		npc.m_iTarget = 0;

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, false);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				if(ShouldNpcDealBonusDamage(npc.m_iTarget))
				{
					SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 500000.0, DMG_TRUEDAMAGE);
					float pos[3];
					GetEntPropVector(npc.m_iTarget, Prop_Send, "m_vecOrigin", pos);
					pos[2] += 25.0;
					IsharmlaEffect(npc.index, pos);
					int enemy[6];
					UnderTides npc1 = view_as<UnderTides>(iNPC);
					GetHighDefTargets(npc1, enemy, sizeof(enemy));
					for(int i; i < sizeof(enemy); i++)
					{
						if(enemy[i])
						{
							IsharMlarWaterAttack_Invoke(npc.index, enemy[i]);
						}
					}
				}
				else
				{
					int enemy[6];
					UnderTides npc1 = view_as<UnderTides>(iNPC);
					GetHighDefTargets(npc1, enemy, sizeof(enemy));
					for(int i; i < sizeof(enemy); i++)
					{
						if(enemy[i])
						{
							IsharMlarWaterAttack_Invoke(npc.index, enemy[i]);
						}
					}
					PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1000.0,_,vecTarget);
					npc.FireParticleRocket(vecTarget, npc.Anger ? 750.0 : 500.0, 1000.0, 275.0, "drg_cow_rockettrail_burst_charged_blue", true, true, _, _, EP_DEALS_TRUE_DAMAGE);
				}
			}

			npc.FaceTowards(vecTarget, 15000.0);
		}


		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 640000.0)	// 4.0 * 200
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target, true))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;
					npc.m_flNextMeleeAttack = gameTime + 4.45;
					if(ShouldNpcDealBonusDamage(target))
						npc.m_flNextMeleeAttack = gameTime + 2.5;

					npc.PlayMeleeSound();

					npc.AddGesture(ShouldNpcDealBonusDamage(target) ? "ACT_MP_GESTURE_VC_FINGERPOINT_MELEE" : "ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					npc.m_flAttackHappens = gameTime + 0.65;
					npc.m_flDoingAnimation = gameTime + 1.45;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_MP_STAND_ITEM1");
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
			npc.SetActivity("ACT_MP_RUN_ITEM1");
		}
	}
	else
	{
		npc.StopPathing();
		npc.SetActivity("ACT_MP_STAND_ITEM1");
	}

	npc.PlayIdleSound();
}

void IsharmlaTrans_NPCDeath(int entity)
{
	IsharmlaTrans npc = view_as<IsharmlaTrans>(entity);
	npc.PlayDeathSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	SeaFounder_SpawnNethersea(pos);
}


static void IsharmlaEffect(int entity = -1, float VecPos_target[3] = {0.0,0.0,0.0})
{	
	int r = 65; //Blue.
	int g = 65;
	int b = 255;
	int laser;

	laser = ConnectWithBeam(entity, -1, r, g, b, 3.0, 3.0, 2.35, LASERBEAM, _, VecPos_target,"effect_hand_l");

	CreateTimer(1.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}



public void IsharMlarWaterAttack_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
	//	IsharmlaTrans npc = view_as<IsharmlaTrans>(entity);
		float Time=2.5;	//how long before kaboom
			
					
		
		float Range=150.0;
		if(LastMann)
			Range = 75.0;

		float Dmg=500.0;
		
		float vecTarget[3];
		WorldSpaceCenter(enemy, vecTarget );
		vecTarget[2] += 1.0;
		
		
		int color[4];
		color[0] = 65;
		color[1] = 65;
		color[2] = 255;
		color[3] = 255;
		float UserLoc[3];
		GetAbsOrigin(entity, UserLoc);
		
		UserLoc[2]+=75.0;
		
		int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
					
		TE_SetupBeamPoints(vecTarget, UserLoc, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
		TE_SendToAll();

		EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecTarget);
		
		Handle data;
		CreateDataTimer(Time, Smite_Timer_IsharMlar, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackFloat(data, Range); // Range
		WritePackFloat(data, Dmg); // Damge
		WritePackCell(data, ref);
		
		spawnRing_Vectors(vecTarget, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 65, 65, 255, 200, 1, Time, 6.0, 0.1, 1, 1.0);
	}
}

public Action Smite_Timer_IsharMlar(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackFloat(data);
	float Iondamage = ReadPackFloat(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Explode_Logic_Custom(Iondamage, client, client, -1, startPosition, Ionrange , _ , _ , true);
	
	TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 900.0;
	startPosition[2] += -200;
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {65, 65, 255, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {65, 65, 255, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {65, 65, 255, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {65, 65, 255, 255}, 3);
	TE_SendToAll();
	
	position[2] = startPosition[2] + 50.0;
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	return Plugin_Continue;
}
