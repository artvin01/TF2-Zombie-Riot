#pragma semicolon 1
#pragma newdecls required

#define ADDICTION_LIGHTNING_RANGE 150.0

#define ADDICTION_CHARGE_TIME 4.1
#define ADDICTION_CHARGE_SPAN 1.5

static char g_HurtSounds[][] =
{
	"cof/addiction/hurt1.mp3",
	"cof/addiction/hurt2.mp3"
};

static char g_PassiveSounds[][] =
{
	"cof/addiction/passive1.mp3",
	"cof/addiction/passive2.mp3"
};

static char g_ThunderSounds[][] =
{
	"cof/addiction/thunder_attack1.wav",
	"cof/addiction/thunder_attack2.wav",
	"cof/addiction/thunder_attack3.wav"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static char g_MeleeMissSounds[][] =
{
	"weapons/cbar_miss1.wav",
};

void Addiction_OnMapStart_NPC()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Addiction");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_addiction");
	strcopy(data.Icon, sizeof(data.Icon), "psycho");
	//already downlowded for psycho
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}
static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSoundCustom(g_HurtSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_PassiveSounds));	   i++) { PrecacheSoundCustom(g_PassiveSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_ThunderSounds));	   i++) { PrecacheSoundCustom(g_ThunderSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));	   i++) { PrecacheSound(g_MeleeMissSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	   i++) { PrecacheSound(g_MeleeHitSounds[i]);	   }
	PrecacheSoundCustom("cof/addiction/death.mp3");

	PrecacheModel("models/zombie_riot/aom/david_monster.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Addicition(vecPos, vecAng, team, data);
}

methodmap Addicition < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + 3.5;
		EmitCustomToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], this.index);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("cof/addiction/death.mp3", _, _, _, _, 2.0);
	}
	public void PlayLightningSound()
	{
		EmitCustomToAll(g_ThunderSounds[GetRandomInt(0, sizeof(g_ThunderSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, 3.0);
	}
	
	property float m_flSelfStun
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	public Addicition(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Addicition npc = view_as<Addicition>(CClotBody(vecPos, vecAng, "models/zombie_riot/aom/david_monster.mdl", "1.15", data[0] == 'f' ? "250000" : "10000", ally, false, false, true));

		i_NpcWeight[npc.index] = 3;
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_SPAWN");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		func_NPCDeath[npc.index] = Addicition_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Addicition_OnTakeDamage;
		func_NPCThink[npc.index] = Addicition_ClotThink;
		
		npc.m_bisWalking = false;
		npc.m_bThisNpcIsABoss = true;
		npc.m_flSpeed = 100.0;
		npc.m_iTarget = -1;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedSpecialDelay = 1.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 2.0;
		npc.m_flNextRangedSpecialAttack = npc.m_flReloadDelay + 0.0;
		npc.m_bLostHalfHealth = false;
		npc.m_bDissapearOnDeath = true;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 2.5;
		
		if(data[0])
			npc.SetHalfLifeStats();

		Citizen_MiniBossSpawn();
		
		return npc;
	}
	
	public void SetHalfLifeStats()
	{
		this.m_bLostHalfHealth = true;
		this.m_flSpeed = 220.0;
	}
}

public void Addicition_ClotThink(int iNPC)
{
	Addicition npc = view_as<Addicition>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(IsValidEntity(npc.m_iTargetAlly) && npc.m_flSelfStun < gameTime)
	{
		ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "Infinite Will", 0.5);		
		ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "Defensive Backup", 0.5);
		int Barneyhealth = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iHealth");
		if(Barneyhealth <= 1.0)
		{
			//Hes about to die.
			ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "False Therapy", 999.9);
			ApplyStatusEffect(npc.m_iTargetAlly, npc.m_iTargetAlly, "Hectic Therapy", 999.9);
		}
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_bLostHalfHealth)
	{
		float Armor_Stats = 1.0 * Pow(0.98, float(Zombies_Currently_Still_Ongoing));
		
		if(Armor_Stats > 1.0)
		{
			Armor_Stats = 1.0;
		}
		else if(Armor_Stats < 0.4)
		{
			Armor_Stats = 0.4;
		}
		
		npc.m_flMeleeArmor = Armor_Stats;
		npc.m_flRangedArmor = Armor_Stats;
	}
	else if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < ReturnEntityMaxHealth(npc.index)/2)
	{
		npc.SetHalfLifeStats();
	}

	if(IsValidEntity(npc.m_iTargetAlly))
	{
		if(npc.m_flSelfStun)
		{
			npc.m_flSelfStun = 0.0;
			EmitSoundToAll("mvm/mvm_bought_in.wav", _, _, _, _, 1.0);
			if(!IsValidEntity(npc.m_iWearable1))
			{
				npc.m_iWearable1 = ConnectWithBeam(npc.m_iTargetAlly, npc.index, 125, 125, 65, 5.0, 5.0, 1.0, "sprites/laserbeam.vmt");
			}
		}
	}
	if(npc.m_blPlayHurtAnimation)
	{
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
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		if(npc.m_bLostHalfHealth)
		{
			if(npc.m_iChanged_WalkCycle != 2 && npc.m_flReloadDelay < GetGameTime(npc.index)) 	
			{
				npc.SetActivity("ACT_RUN_HALFLIFE");
				npc.m_iChanged_WalkCycle = 2;
				npc.StartPathing();
				npc.m_bisWalking = true;
			}		
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 1 && npc.m_flReloadDelay < GetGameTime(npc.index)) 	
			{
				npc.SetActivity("ACT_RUN");
				npc.m_iChanged_WalkCycle = 1;
				npc.StartPathing();
				npc.m_bisWalking = true;
			}
		}
		
		if(npc.m_bLostHalfHealth)
		{
			if(flDistanceToTarget < 200000.0 && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See)
				{
					if(npc.m_iChanged_WalkCycle != 3) 	
					{
						npc.SetActivity("ACT_LIGHTNING");
						npc.m_bisWalking = false;
						npc.m_iChanged_WalkCycle = 3;
						npc.StopPathing();
						
					}
					npc.PlayLightningSound();
					
					float vEnd[3];
					
					GetAbsOrigin(npc.m_iTarget, vEnd);
					Handle pack;
					CreateDataTimer(ADDICTION_CHARGE_SPAN, Smite_Timer_Addiction, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, EntIndexToEntRef(npc.index));
					WritePackFloat(pack, 0.0);
					WritePackFloat(pack, vEnd[0]);
					WritePackFloat(pack, vEnd[1]);
					WritePackFloat(pack, vEnd[2]);
					WritePackFloat(pack, 1000.0);
						
					spawnRing_Vectors(vEnd, ADDICTION_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, ADDICTION_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 3.0;
					npc.m_flReloadDelay = GetGameTime(npc.index) + 5.0;
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 15.0;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 5.0;
				}
			}
		}
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
		{
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					//npc.PlayAttackSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.43;
					npc.m_flAttackHappenswillhappen = true;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
				}
				
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,_, 1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							if(target <= MaxClients)
								SDKHooks_TakeDamage(target, npc.index, npc.index, 150.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 500.0, DMG_CLUB, -1, _, vecHit);					
							
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
				}
			}
			
		}
	}
	else
	{
//		npc.StopPathing();
//		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	npc.PlayIdleSound();
}
	
public Action Addicition_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
//	if(damage < 9999999.0 && view_as<Addicition>(victim).m_flRangedSpecialDelay == 1.0)
//		return Plugin_Handled;
	
	Addicition npc = view_as<Addicition>(victim);
	view_as<Addicition>(victim).PlayHurtSound();
	if(IsValidEntity(npc.m_iTargetAlly))
	{
		int Barneyhealth = GetEntProp(npc.m_iTargetAlly, Prop_Data, "m_iHealth");
		if(Barneyhealth <= 1.0)
			return Plugin_Continue;
		//do nothing, allow death.

		int HealthMe = GetEntProp(victim, Prop_Data, "m_iHealth");

		if((HealthMe - RoundToNearest(damage)) <= 0)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			//We died, self stun and give full health.
			npc.m_flSelfStun = GetGameTime(npc.index) + 0.1;
			FreezeNpcInTime(victim, 45.0);
			EmitCustomToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], npc.index);
			EmitCustomToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], npc.index);
			EmitCustomToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], npc.index);
			EmitCustomToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], npc.index);
			//When killed. spawn tallers.
			for(int repeat; repeat < 5; repeat ++)
			{
				int summon = NPC_CreateByName("npc_taller", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), "nightmare");
				if(IsValidEntity(summon))
				{
					CorruptedBarney npcsummon = view_as<CorruptedBarney>(summon);
					if(GetTeam(npc.index) != TFTeam_Red)
						Zombies_Currently_Still_Ongoing++;
					
					fl_Extra_Damage[npcsummon.index] = fl_Extra_Damage[npc.index];
					fl_Extra_Speed[npcsummon.index] = fl_Extra_Speed[npc.index];
					fl_Extra_Speed[npcsummon.index] *= 1.5;
					f_AttackSpeedNpcIncrease[npcsummon.index] *= 4.0;
					NpcStats_CopyStats(npc.index, summon);
					FreezeNpcInTime(npcsummon.index, 2.0);
					SetEntProp(summon, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/4);
					SetEntProp(summon, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)/4);
					ApplyStatusEffect(npcsummon.index, npcsummon.index, "Unstoppable Force", 2.0);
				}
			}
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			HealEntityGlobal(npc.index, npc.index, 99999999.9, 1.0, 0.0, HEAL_ABSOLUTE);
			ApplyStatusEffect(npc.index, npc.index, "Unstoppable Force", 45.0);
			damage = 0.0;
			return Plugin_Changed;

		}
	}
	return Plugin_Continue;
}

public void Addicition_NPCDeath(int entity)
{
	Addicition npc = view_as<Addicition>(entity);
	
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	npc.StopPathing();
	
	
	npc.PlayDeathSound();
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/aom/david_monster.mdl");
		DispatchKeyValue(entity_death, "skin", "0");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(1.0, Timer_RemoveEntityOverlord, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
	}

	Citizen_MiniBossDeath(entity);
}


public Action Smite_Timer_Addiction(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= ADDICTION_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.4, 1, (ADDICTION_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		EmitAmbientSound("cof/addiction/lightning_hit.mp3", spawnLoc, _, 120);
		EmitAmbientSound("cof/addiction/lightning_hit.mp3", spawnLoc, _, 120);
		EmitAmbientSound("cof/addiction/lightning_hit.mp3", spawnLoc, _, 120);
		EmitAmbientSound("cof/addiction/lightning_hit.mp3", spawnLoc, _, 120);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		CreateEarthquake(spawnLoc, 1.0, ADDICTION_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, ADDICTION_LIGHTNING_RANGE * 1.4,_,0.8, true);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, ADDICTION_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + ADDICTION_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}