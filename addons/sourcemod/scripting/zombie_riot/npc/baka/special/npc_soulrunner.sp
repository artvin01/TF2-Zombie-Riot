#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"zombie_riot/sawrunner/death.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"zombie_riot/sawrunner/passive.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"zombie_riot/sawrunner/attack1.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"zombie_riot/sawrunner/attack1.mp3",
	"zombie_riot/sawrunner/attack2.mp3",
};

static const char g_MeleeMissSounds[][] = {
	"zombie_riot/sawrunner/attacksaw2.mp3",
};

static const char g_IdleChainsaw[][] = {
	"zombie_riot/sawrunner/chainsaw_loop.mp3",
};

void SoulRunner_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSoundCustom(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSoundCustom(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSoundCustom(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSoundCustom(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleChainsaw));   i++) { PrecacheSoundCustom(g_IdleChainsaw[i]);   }
	PrecacheModel("models/zombie_riot/cof/sawrunner_2.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Soulrunner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_soulrunner");
	strcopy(data.Icon, sizeof(data.Icon), "sawrunner");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SoulRunner(vecPos, vecAng, team);
}

methodmap SoulRunner < CClotBody
{
	
	property int m_iPlayIdleAlertSound
	{
		public get()							{ return i_PlayIdleAlertSound[this.index]; }
		public set(int TempValueForProperty) 	{ i_PlayIdleAlertSound[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetEngineTime())
			return;
		EmitCustomToAll(g_IdleChainsaw[GetRandomInt(0, sizeof(g_IdleChainsaw) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetEngineTime() + 2.5;
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_iPlayIdleAlertSound > GetTime())
			return;
		
		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_iPlayIdleAlertSound = GetTime() + GetRandomInt(12, 17);
	}
	
	public void PlayDeathSound() {
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	
	public void PlayMeleeSound() {
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	
	public void PlayMeleeHitSound() {
		EmitCustomToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}

	public void PlayMeleeMissSound() {
		EmitCustomToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	
	public SoulRunner(float vecPos[3], float vecAng[3], int ally)
	{
		SoulRunner npc = view_as<SoulRunner>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/sawrunner_2.mdl", "1.35", MinibossHealthScaling(90.0), ally, false, true, true));
		
		i_NpcWeight[npc.index] = 2;
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "headtaker");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		

		npc.m_bDoSpawnGesture = true;
		
		func_NPCDeath[npc.index] = SoulRunner_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SoulRunner_OnTakeDamage;
		func_NPCThink[npc.index] = SoulRunner_ClotThink;
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 2.0;
		f_HeadshotDamageMultiNpc[npc.index] = 2.0;
		
		npc.m_flSpeed = 200.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_bDissapearOnDeath = true;
		
		npc.StartPathing();
		b_HideHealth[npc.index] = true;
		b_NoHealthbar[npc.index] = true;
		//counts as a static npc, means it wont count towards NPC limit.
		AddNpcToAliveList(npc.index, 1);
		
		return npc;
	}
}

public void SoulRunner_ClotThink(int iNPC)
{
	SoulRunner npc = view_as<SoulRunner>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.AddGesture("ACT_SPAWN");
		npc.m_bDoSpawnGesture = false;
	}
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		npc.m_flSpeed = 0.0;
		return;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index))
		npc.m_flSpeed = 0.0;
	else
		npc.m_flSpeed = 450.0;
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		return;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index, true);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		npc.SetGoalEntity(PrimaryThreatIndex);
		
		//Target close enough to hit
		if((flDistanceToTarget < 12500 && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					
					switch(GetRandomInt(1,3))
					{
						case 1:
						{
							npc.AddGesture("ACT_MELEE_1");
						}
						case 2:
						{
							npc.AddGesture("ACT_MELEE_2");
						}
						case 3:
						{
							npc.AddGesture("ACT_MELEE_3");
						}
					}
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.5;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.64;
					npc.m_flAttackHappenswillhappen = true;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if (npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 128.0, 128.0, 128.0 }, { -128.0, -128.0, -128.0 }, _, _, 1))
						{
							
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								if(target <= MaxClients)
								{
									if(i_HealthBeforeSuit[target] > 0)
									{
										DealTruedamageToEnemy(0, target, 99999999.9);
										Custom_Knockback(npc.index, target, 1000.0); // Kick them away.
									}
									else
									{
										float flMaxHealth = float(SDKCall_GetMaxHealth(target));
										
										flMaxHealth *= 0.75; //Because drown damage is 2x in anycase
										
										if(IsInvuln(target))	
										{
											flMaxHealth *= 0.5; //If under uber, give em more resistance so uber isnt completly useless
											Custom_Knockback(npc.index, target, 5000.0);
										}
										else
										{
											Custom_Knockback(npc.index, target, 1000.0); //Give them massive knockback so they can get away/dont make this boy stuck.
										}
										
										DealTruedamageToEnemy(0, target, flMaxHealth + 50.0);
									}
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 99999.0, DMG_CLUB, -1, _, vecHit);
								}
								npc.PlayMeleeHitSound();
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
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
			npc.StartPathing();
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
	npc.PlayIdleSound();
}

public Action SoulRunner_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	SoulRunner npc = view_as<SoulRunner>(victim);
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
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

public void SoulRunner_NPCDeath(int entity)
{
	SoulRunner npc = view_as<SoulRunner>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/cof/sawrunner_2.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.5); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		CreateTimer(2.0, Timer_RemoveEntitySawrunner, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.7, Timer_RemoveEntitySawrunner_Tantrum, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);

	}

	Citizen_MiniBossDeath(entity);
}