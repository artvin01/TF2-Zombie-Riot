#pragma semicolon 1
#pragma newdecls required


static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_smash.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/knife_swing.wav",
};

static char g_RangedAttackSounds[][] = {
	"npc/combine_gunship/gunship_ping_search.wav",
};
static char g_TeleportSounds[][] = {
	"mvm/mvm_tank_end.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_item_secop_domination01.mp3",
};

static char g_AngerSoundsPassed[][] = {
	")vo/medic_laughlong01.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

public void RaidbossBobTheFirst_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	PrecacheSoundCustom("#zombiesurvival/silvester_raid/silvester.mp3");
}

methodmap RaidbossBobTheFirst < CClotBody
{

	public void PlayIdleSound(bool repeat = false) {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);

	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);

	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayAngerSoundPassed() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public RaidbossBobTheFirst(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.35", "25000", ally)); //giant!
		
		i_NpcInternalId[npc.index] = BOB_THE_FIRST;
		i_NpcWeight[npc.index] = 6;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Bob the first, the final Savior");
			}
		}
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		SDKHook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossBobTheFirst_OnTakeDamagePost);
		Music_SetRaidMusic("#zombiesurvival/silvester_raid/silvester.mp3", 117, true);
		
		npc.Anger = false;
		//IDLE
		npc.m_flSpeed = 330.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;		
		Citizen_MiniBossSpawn();
		Building_RaidSpawned(npc.index);
		npc.StartPathing();

		return npc;
	}
}

//TODO 
//Rewrite
public void RaidbossBobTheFirst_ClotThink(int iNPC)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(iNPC);
	
	//Raidmode timer runs out, they lost.
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		RaidbossBobTheFirstSelfDefense(npc,GetGameTime(npc.index)); 
	}
}

	
public Action RaidbossBobTheFirst_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}


public void RaidbossBobTheFirst_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(victim);

}

public void RaidbossBobTheFirst_NPCDeath(int entity)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	SDKUnhook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, RaidbossBobTheFirst_OnTakeDamagePost);
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.

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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}		
		if(IsValidClient(EnemyLoop))
		{
			ResetDamageHud(EnemyLoop);//show nothing so the damage hud goes away so the other raid can take priority faster.
		}				
	}
}

void RaidbossBobTheFirstSelfDefense(RaidbossBobTheFirst npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
								
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float damage = 24.0;
						float damage_rage = 28.0;
						if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
						{
							damage = 20.0; //nerf
							damage_rage = 21.0; //nerf
						}
						else if(ZR_GetWaveCount()+1 > 55)
						{
							damage = 17.5; //nerf
							damage_rage = 18.5; //nerf
						}

						if(!npc.Anger)
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);
								
						if(npc.Anger)
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);									
							
						
						// Hit particle
						
						
						// Hit sound
						npc.PlayMeleeHitSound();
						
						bool Knocked = false;
									
						if(IsValidClient(target))
						{
							if (IsInvuln(target))
							{
								Knocked = true;
								Custom_Knockback(npc.index, target, 900.0, true);
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							else
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
									
						if(!Knocked)
							Custom_Knockback(npc.index, target, 650.0); 
					} 
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}


static bool b_AlreadyHitTankThrow[MAXENTITIES][MAXENTITIES];
static float fl_ThrowDelay[MAXENTITIES];
public Action contact_throw_Silvester_entity(int client)
{
	CClotBody npc = view_as<CClotBody>(client);
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	bool EndThrow = false;
	if (IsValidClient(client))
	{
		if(((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1))
		{
			if (fl_ThrowDelay[client] < GetGameTime())
			{
				EndThrow = true;
			}		
		}
	}
	else if(!b_NpcHasDied[client]) //It died.
	{
		if(npc.IsOnGround() && fl_ThrowDelay[client] < GetGameTime())
		{
			EndThrow = true;
		}
	}
	else
	{
		EndThrow = true;
	}

	if(EndThrow)
	{
		for(int entity=1; entity < MAXENTITIES; entity++)
		{
			b_AlreadyHitTankThrow[client][entity] = false;
		}

		SDKUnhook(client, SDKHook_Think, contact_throw_Silvester_entity);	
		return Plugin_Continue;
	}
	else
	{
		char classname[60];
		chargerPos = WorldSpaceCenter(client);
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			if (IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
			{
				GetEntityClassname(entity, classname, sizeof(classname));
				if (!StrContains(classname, "zr_base_npc", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
				{
					targPos = WorldSpaceCenter(entity);
					if (GetVectorDistance(chargerPos, targPos, true) <= (125.0* 125.0) && GetEntProp(entity, Prop_Send, "m_iTeamNum")!=GetEntProp(client, Prop_Send, "m_iTeamNum"))
					{
						if (!b_AlreadyHitTankThrow[client][entity] && entity != client)
						{		
							int damage = GetEntProp(client, Prop_Data, "m_iMaxHealth") / 3;
							
							if(damage > 2000)
							{
								damage = 2000;
							}
							
							if(!ShouldNpcDealBonusDamage(entity))
							{
								damage *= 4;
							}
							
							SDKHooks_TakeDamage(entity, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR, targPos);
							EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
							b_AlreadyHitTankThrow[client][entity] = true;
							if(entity <= MaxClients)
							{
								float newVel[3];
								
								newVel[0] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[0]") * 2.0;
								newVel[1] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[1]") * 2.0;
								newVel[2] = 500.0;
												
								for (int i = 0; i < 3; i++)
								{
									flVel[i] += newVel[i];
								}				
								TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVel); 
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


void ApplySdkHookSilvesterThrow(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		fl_ThrowDelay[entity] = GetGameTime(entity) + 0.1;
		SDKHook(entity, SDKHook_Think, contact_throw_Silvester_entity);		
	}
}



void Silvester_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
			
		maxhealth -= (maxhealth / 4);

		int spawn_index = Npc_Create(XENO_RAIDBOSS_BLUE_GOGGLES, -1, pos, ang, GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
		{
			i_RaidDuoAllyIndex = EntIndexToEntRef(spawn_index);
			Goggles_SetRaidPartner(entity);
			Zombies_Currently_Still_Ongoing += 1;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

void Silvester_Damaging_Pillars_Ability(int entity,
float damage,
int count,
float delay,
float delay_PerPillar,
float direction[3] /*2 dimensional plane*/,
float origin[3],
float volume = 0.7)
{
	float timerdelay = GetGameTime() + delay;
	DataPack pack;
	CreateDataTimer(delay_PerPillar, Silvester_DamagingPillar, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
	pack.WriteCell(damage);
	pack.WriteCell(0);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(count);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(timerdelay);					//Delay for each initial pillar
	pack.WriteCell(direction[0]);
	pack.WriteCell(direction[1]);
	pack.WriteCell(direction[2]);
	pack.WriteCell(origin[0]);
	pack.WriteCell(origin[1]);
	pack.WriteCell(origin[2]);
	pack.WriteCell(volume);

	float origin_altered[3];
	origin_altered = origin;

	for(int Repeats; Repeats < count; Repeats++)
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin_altered[0] + VecForward[0] * (PILLAR_SPACING);
		vecSwingEnd[1] = origin_altered[1] + VecForward[1] * (PILLAR_SPACING);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

		origin_altered = vecSwingEnd;

		//Clip to ground, its like stepping on stairs, but for these rocks.

		Silvester_ClipPillarToGround({24.0,24.0,24.0}, 300.0, origin_altered);
		float Range = 100.0;

		Range += (float(Repeats) * 10.0);
		Silvester_TE_Used += 1;
		if(Silvester_TE_Used > 31)
		{
			int DelayFrames = (Silvester_TE_Used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(origin_altered[0]);
			pack_TE.WriteCell(origin_altered[1]);
			pack_TE.WriteCell(origin_altered[2]);
			pack_TE.WriteCell(Range);
			pack_TE.WriteCell(delay + (delay_PerPillar * float(Repeats)));
			RequestFrames(Silvester_DelayTE, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			spawnRing_Vectors(origin_altered, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 150, 0, 200, 1, delay + (delay_PerPillar * float(Repeats)), 5.0, 0.0, 1);	
		}
		/*
		int laser;
		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);

		int red = 212;
		int green = 155;
		int blue = 0;

		laser = ConnectWithBeam(npc.m_iWearable6, -1, red, green, blue, 5.0, 5.0, 0.0, LINKBEAM,_, origin_altered);

		CreateTimer(delay, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		*/

	}
}

void Silvester_ClipPillarToGround(float vecHull[3], float StepHeight, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_NPCSOLID,HitOnlyWorld, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}
			
public void Silvester_DelayTE(DataPack pack)
{
	pack.Reset();
	float Origin[3];
	Origin[0] = pack.ReadCell();
	Origin[1] = pack.ReadCell();
	Origin[2] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Delay = pack.ReadCell();
	spawnRing_Vectors(Origin, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 212, 150, 0, 200, 1, Delay, 5.0, 0.0, 1);	
		
	delete pack;
}

public Action Silvester_DamagingPillar(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadCell();
	DataPackPos countPos = pack.Position;
	int count = pack.ReadCell();
	int countMax = pack.ReadCell();
	float delayUntillImpact = pack.ReadCell();
	float direction[3];
	direction[0] = pack.ReadCell();
	direction[1] = pack.ReadCell();
	direction[2] = pack.ReadCell();
	float origin[3];
	DataPackPos originPos = pack.Position;
	origin[0] = pack.ReadCell();
	origin[1] = pack.ReadCell();
	origin[2] = pack.ReadCell();
	float volume = pack.ReadCell();

	//Timers have a 0.1 impresicison logic, accont for it.
	if(delayUntillImpact - 0.1 > GetGameTime())
	{
		return Plugin_Continue;
	}

	count += 1;
	pack.Position = countPos;
	pack.WriteCell(count, false);
	if(IsValidEntity(entity))
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin[0] + VecForward[0] * (PILLAR_SPACING);
		vecSwingEnd[1] = origin[1] + VecForward[1] * (PILLAR_SPACING);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

		Silvester_ClipPillarToGround({24.0,24.0,24.0}, 300.0, vecSwingEnd);


		
		int prop = CreateEntityByName("prop_physics_multiplayer");
		if(IsValidEntity(prop))
		{

			float vel[3];
			vel[2] = 750.0;
			float SpawnPropPos[3];
			float SpawnParticlePos[3];

			SpawnPropPos = vecSwingEnd;
			SpawnParticlePos = vecSwingEnd;

			SpawnPropPos[2] -= 250.0;
			SpawnParticlePos[2] += 5.0;

			DispatchKeyValue(prop, "model", PILLAR_MODEL);
			DispatchKeyValue(prop, "physicsmode", "2");
			DispatchKeyValue(prop, "solid", "0");
			DispatchKeyValue(prop, "massScale", "1.0");
			DispatchKeyValue(prop, "spawnflags", "6");


			float SizeScale = 0.9;

			SizeScale += (count * 0.1);

			char FloatString[8];
			FloatToString(SizeScale, FloatString, sizeof(FloatString));

			DispatchKeyValue(prop, "modelscale", FloatString);
			DispatchKeyValueVector(prop, "origin",	 SpawnPropPos);
			direction[2] -= 180.0;
			direction[1] = GetRandomFloat(-180.0, 180.0);
			DispatchKeyValueVector(prop, "angles",	 direction);
			DispatchSpawn(prop);
			TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
			SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
			SetEntityRenderColor(prop, 215, 200, 0, 200);
			SetEntityCollisionGroup(prop, 1); //COLLISION_GROUP_DEBRIS_TRIGGER
			SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(prop, Prop_Data, "m_nSolidType", 6); 

			float Range = 100.0;

			Range += (float(count) * 10.0);
			
			makeexplosion(entity, entity, SpawnParticlePos, "", RoundToCeil(damage), RoundToCeil(Range),_,_,_,false);
			
			SpawnParticlePos[2] += 80.0;
			makeexplosion(entity, entity, SpawnParticlePos, "", RoundToCeil(damage), RoundToCeil(Range),_,_,_,false);
			SpawnParticlePos[2] -= 80.0;
	//		ParticleEffectAt(SpawnParticlePos, "medic_resist_fire", 1.0);
			if(volume == 0.25)
			{
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);		
			}
			else
			{
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
			}
		
		//	spawnRing_Vectors(vecSwingEnd, Range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 1.0, 12.0, 6.1, 1);
			spawnRing_Vectors(SpawnParticlePos, 0.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, 0.5, 12.0, 6.1, 1,Range * 2.0);

			CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		pack.Position = originPos;
		pack.WriteCell(vecSwingEnd[0], false);
		pack.WriteCell(vecSwingEnd[1], false);
		pack.WriteCell(origin[2], false);
		//override origin, we have a new origin.
	}
	else
	{
		return Plugin_Stop; //cancel.
	}

	if(count >= countMax)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void Silvester_TBB_Ability(int client)
{
	float flPos[3]; // original
	float flAng[3]; // original
	GetAttachment(client, "effect_hand_r", flPos, flAng);
	int particlel = ParticleEffectAt(flPos, "eyeboss_death_vortex", 4.0);
	SetParent(client, particlel, "effect_hand_r");

	GetAttachment(client, "effect_hand_l", flPos, flAng);
	int particler = ParticleEffectAt(flPos, "eyeboss_death_vortex", 4.0);
	SetParent(client, particler, "effect_hand_l");
			
	Silvester_BEAM_IsUsing[client] = false;
	Silvester_BEAM_TicksActive[client] = 0;

	Silvester_BEAM_CanUse[client] = true;
	Silvester_BEAM_CloseDPT[client] = 16.0 * RaidModeScaling;
	Silvester_BEAM_FarDPT[client] = 12.0 * RaidModeScaling;
	Silvester_BEAM_MaxDistance[client] = 2000;
	Silvester_BEAM_BeamRadius[client] = 45;
	Silvester_BEAM_ColorHex[client] = ParseColor("EEDD44");
	Silvester_BEAM_ChargeUpTime[client] = 200;
	Silvester_BEAM_CloseBuildingDPT[client] = 0.0;
	Silvester_BEAM_FarBuildingDPT[client] = 0.0;
	Silvester_BEAM_Duration[client] = 6.0;
	
	Silvester_BEAM_BeamOffset[client][0] = 0.0;
	Silvester_BEAM_BeamOffset[client][1] = 0.0;
	Silvester_BEAM_BeamOffset[client][2] = 0.0;

	Silvester_BEAM_ZOffset[client] = 0.0;
	Silvester_BEAM_UseWeapon[client] = false;

	Silvester_BEAM_IsUsing[client] = true;
	Silvester_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);			
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
		}		
	}
			

	CreateTimer(5.0, Silvester_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Silvester_TBB_Tick);
}


public Action Silvester_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	Silvester_BEAM_IsUsing[client] = false;
	
	Silvester_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}


public bool Silvester_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_PLAYERS_ARRAY 36


public bool Silvester_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Silvester_BEAM_HitDetected[entity] = true;
	}
	return false;
}

static void Silvester_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == Silvester_BEAM_BeamOffset[client][0] && 0.0 == Silvester_BEAM_BeamOffset[client][1] && 0.0 == Silvester_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Silvester_BEAM_BeamOffset[client][0];
	tmp[1] = Silvester_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = Silvester_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

#define MAXTF2PLAYERS	36

public Action Silvester_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !Silvester_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, Silvester_TBB_Tick);
		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(client);
		npc.m_iInKame = 1;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	Silvester_BEAM_TicksActive[client] = tickCount;
	float diameter = float(Silvester_BEAM_BeamRadius[client] * 2);
	int r = GetR(Silvester_BEAM_ColorHex[client]);
	int g = GetG(Silvester_BEAM_ColorHex[client]);
	int b = GetB(Silvester_BEAM_ColorHex[client]);
	if (Silvester_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 75.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Silvester_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(Silvester_BEAM_MaxDistance[client]));
			float lineReduce = Silvester_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				Silvester_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(Silvester_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Silvester_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Silvester_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Silvester_BEAM_CloseDPT[client] + (Silvester_BEAM_FarDPT[client]-Silvester_BEAM_CloseDPT[client]) * (distance/Silvester_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					if(victim > MAXTF2PLAYERS)
					{
						damage *= 3.0; //give 3x dmg to anything
					}

					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			
			static float belowBossEyes[3];
			Silvester_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}

bool IsPartnerGivingUpSilvester(int entity)
{
	if(!IsValidEntity(entity))
		return true;

	return b_angered_twice[entity];
}

bool SharedGiveupSilvester(int entity, int entity2)
{
	if(IsPartnerGivingUpSilvester(entity) && IsPartnerGivingUpGoggles(entity2))
	{
		if(i_TalkDelayCheck == 5)
		{
			return true;
		}
		if(f_TalkDelayCheck < GetGameTime())
		{
			f_TalkDelayCheck = GetGameTime() + 7.0;
			RaidModeTime += 10.0; //cant afford to delete it, since duo.
			switch(i_TalkDelayCheck)
			{
				case 0:
				{
					ReviveAll(true);
					CPrintToChatAll("{gold}Silvester{default}: We tried to help, this will be painfull for you.");
					i_TalkDelayCheck += 1;
				}
				case 1:
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: There is a far greater enemy then us, we cant beat him.");
					i_TalkDelayCheck += 1;
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}Blue Goggles{default}: I doubt you can defeat him, but if you do, then you will assist greatly in defeating the great chaos.");
					i_TalkDelayCheck += 1;
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester{default}: Good luck.");
					i_TalkDelayCheck = 5;
				}
			}
		}
	}
	return false;
}