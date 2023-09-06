#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"infected_riot/tank/tank_dead.mp3",
};


static char g_HurtSounds[][] = {
	"infected_riot/tank/tank_pain_01.mp3",
	"infected_riot/tank/tank_pain_02.mp3",
	"infected_riot/tank/tank_pain_03.mp3",
};

static char g_SpawnSounds[][] = {
	"infected_riot/tank/tank_spawn.mp3",
};

static char g_MeleeHitSounds[][] = {
	"plats/tram_hit4.wav",
};

static char g_MeleeAttackSounds[][] = {
	"infected_riot/tank/tank_attack_01.mp3",
	"infected_riot/tank/tank_attack_04.mp3",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_IdleMusic[] = "#infected_riot/tank/onebadtank.mp3";

public void L4D2_Tank_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

	PrecacheSoundCustom("#infected_riot/tank/onebadtank.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_dead.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_pain_01.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_pain_02.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_pain_03.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_attack_01.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_attack_04.mp3");
	PrecacheSoundCustom("infected_riot/tank/tank_spawn.mp3");
//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheSound("weapons/physcannon/energy_disintegrate5.wav");
	PrecacheModel("models/infected/hulk_2.mdl");
}


static int i_TankAntiStuck[MAXENTITIES];

static int i_PlayMusicSound[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];


static float fl_ThrowPlayerCooldown[MAXENTITIES];
static float fl_ThrowPlayerImmenent[MAXENTITIES];
static bool b_ThrowPlayerImmenent[MAXENTITIES];
static int i_GrabbedThis[MAXENTITIES];

static bool b_AlreadyHitTankThrow[MAXENTITIES];
static int i_TankThrewThis[MAXENTITIES];

static bool i_ThrowAlly[MAXENTITIES];
static int i_IWantToThrowHim[MAXENTITIES];

static float fl_ThrowDelay[MAXENTITIES];

static float f3_LastValidPosition[MAXENTITIES][3]; //Before grab to be exact

methodmap L4D2_Tank < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.25;
		
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}

	public void PlayDeathSound() {
	
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}

	public void PlaySpawnSound() {
	
		EmitCustomToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, 80, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		
		int Random_pitch = GetRandomInt(90, 110);
		
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, Random_pitch);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, Random_pitch);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	property int m_iPlayMusicSound
	{
		public get()							{ return i_PlayMusicSound[this.index]; }
		public set(int TempValueForProperty) 	{ i_PlayMusicSound[this.index] = TempValueForProperty; }
	}
	public void PlayMusicSound() {
		if(this.m_iPlayMusicSound > GetTime())
			return;
		
		EmitCustomToAll(g_IdleMusic, this.index, SNDCHAN_VOICE, SNDLEVEL_NONE, _, BOSS_ZOMBIE_VOLUME, 100);

		this.m_iPlayMusicSound = GetTime() + 52;
		
	}
	
	public L4D2_Tank(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		L4D2_Tank npc = view_as<L4D2_Tank>(CClotBody(vecPos, vecAng, "models/infected/hulk_2.mdl", "1.45", GetTankHealth(), ally, false, true));
		
		i_NpcInternalId[npc.index] = L4D2_TANK;
		i_NpcWeight[npc.index] = 4;
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "fists");
	
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextDelayTime = GetGameTime(npc.index) + 0.2;
		//IDLE
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = 5; //5 is tank

		
		
		SDKHook(npc.index, SDKHook_Think, L4D2_Tank_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, L4D2_Tank_ClotDamagedPost);
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		npc.m_flSpeed = 0.0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 3.0;
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 3.0;
		npc.m_flNextFlameSound = 0.0;
		npc.m_flFlamerActive = 0.0;
		npc.m_bDoSpawnGesture = true;
		npc.m_bLostHalfHealth = false;
		npc.m_bLostHalfHealthAnim = false;
		npc.m_bDuringHighFlight = false;
		npc.m_bDuringHook = false;
		npc.m_bGrabbedSomeone = false;
		npc.m_bUseDefaultAnim = false;
		npc.m_bFlamerToggled = false;
		npc.m_bDissapearOnDeath = true;
		npc.m_iPlayMusicSound = 0;
		
		i_GrabbedThis[npc.index] = 0;
		fl_ThrowPlayerCooldown[npc.index] = GetGameTime(npc.index) + 3.0;
		fl_ThrowPlayerImmenent[npc.index] = GetGameTime(npc.index) + 3.0;
		b_ThrowPlayerImmenent[npc.index] = false;
		i_ThrowAlly[npc.index] = false;
		i_IWantToThrowHim[npc.index] = -1;
		fl_ThrowDelay[npc.index] = GetGameTime(npc.index) + 3.0;

		
		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;
	
		
//		SetEntPropFloat(npc.index, Prop_Data, "m_speed",npc.m_flSpeed);
		npc.m_flAttackHappenswillhappen = false;
		npc.StartPathing();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void L4D2_Tank_ClotThink(int iNPC)
{
	L4D2_Tank npc = view_as<L4D2_Tank>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.PlaySpawnSound();
		npc.AddGesture("ACT_SPAWN");
		npc.m_bDoSpawnGesture = false;
	}
	if(npc.m_bUseDefaultAnim)
	{
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_bUseDefaultAnim = false;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_FLINCH_STOMACH", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flStandStill > GetGameTime(npc.index))
	{
		npc.m_flSpeed = 0.0;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;		
	}
	else
	{
		npc.m_flSpeed = 320.0;	
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
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 6);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float flDistanceToTarget;
		
		float flDistanceToTarget_OnRun = 999999.9;
		
		float vecTarget[3];
		float vecTarget_OnRun[3];
		
		bool I_Wanna_Throw_ally = false;
		if(IsValidEntity(EntRefToEntIndex(i_IWantToThrowHim[npc.index])))
		{
			I_Wanna_Throw_ally = true;
			NPC_SetGoalEntity(npc.index, EntRefToEntIndex(i_IWantToThrowHim[npc.index]));
			vecTarget = WorldSpaceCenter(EntRefToEntIndex(i_IWantToThrowHim[npc.index]));
			flDistanceToTarget  = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			vecTarget_OnRun = WorldSpaceCenter(closest);
			flDistanceToTarget_OnRun = GetVectorDistance(vecTarget_OnRun, WorldSpaceCenter(npc.index), true);
			
		}
		if(!I_Wanna_Throw_ally)
		{
			vecTarget = WorldSpaceCenter(closest);
			vecTarget_OnRun = vecTarget;
			flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
		//		PrintToChatAll("cutoff");
				NPC_SetGoalVector(npc.index, vPredictedPos);	
			}
			else
			{
				NPC_SetGoalEntity(npc.index, closest);
			}
		}
		if(b_ThrowPlayerImmenent[npc.index])
		{
			if(fl_ThrowPlayerImmenent[npc.index] < GetGameTime(npc.index))
			{
				int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
				if(IsValidEntity(client))
				{
					if(i_ThrowAlly[npc.index])
					{
						int Closest_non_grabbed_player = GetClosestTarget(npc.index);
						
						if(IsValidEntity(Closest_non_grabbed_player))
						{
							int Enemy_I_See;
							
							Enemy_I_See = Can_I_See_Enemy(npc.index, Closest_non_grabbed_player);
		
							if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See) && Closest_non_grabbed_player == Enemy_I_See)
							{
								Zero(b_AlreadyHitTankThrow);
								i_TankThrewThis[client] = npc.index;
								float flPos[3]; // original
								float flAng[3]; // original
								
								npc.GetAttachment("rhand", flPos, flAng);
								TeleportEntity(client, flPos, NULL_VECTOR, {0.0,0.0,0.0});
								
								SDKCall_SetLocalOrigin(client, flPos);
								
								float vecTarget_closest[3]; vecTarget_closest = WorldSpaceCenter(Closest_non_grabbed_player);
								npc.FaceTowards(vecTarget_closest, 20000.0);
								PluginBot_Jump(client, vecTarget_closest);
								RequestFrame(ApplySdkHookTankThrow, EntIndexToEntRef(client));
								i_TankAntiStuck[client] = EntIndexToEntRef(npc.index);
								CreateTimer(0.1, CheckStuckTank, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
							}
						}
						
						i_ThrowAlly[npc.index] = false;
					}
					else
					{
						AcceptEntityInput(client, "ClearParent");
						
						float flPos[3]; // original
						float flAng[3]; // original
						
						
						npc.GetAttachment("rhand", flPos, flAng);
						TeleportEntity(client, flPos, NULL_VECTOR, {0.0,0.0,0.0});
						
						SDKCall_SetLocalOrigin(client, flPos);
						
						if(client <= MaxClients)
						{
							SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
							
							TF2_AddCondition(client, TFCond_LostFooting, 1.0);
							TF2_AddCondition(client, TFCond_AirCurrent, 1.0);
							
							if(dieingstate[client] == 0)
							{
								SetEntityCollisionGroup(client, 5);
							}
							if(dieingstate[client] == 0)
							{
								b_ThisEntityIgnored[client] = false;
							}
						}
						
						
						b_DoNotUnStuck[client] = false;
						Zero(b_AlreadyHitTankThrow);
						i_TankThrewThis[client] = npc.index;
						int Closest_non_grabbed_player = GetClosestTarget(npc.index,_,_,_,_, client);
						
						if(IsValidEntity(Closest_non_grabbed_player))
						{
							int Enemy_I_See;
							
							Enemy_I_See = Can_I_See_Enemy(npc.index, Closest_non_grabbed_player);
		
							if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See) && Closest_non_grabbed_player == Enemy_I_See)
							{
								float vecTarget_closest[3]; vecTarget_closest = WorldSpaceCenter(Closest_non_grabbed_player);
								npc.FaceTowards(vecTarget_closest, 20000.0);
								if(client > MaxClients)
								{
									RequestFrame(ApplySdkHookTankThrow, EntIndexToEntRef(client));
									PluginBot_Jump(client, vecTarget_closest);
								}
								i_TankAntiStuck[client] = EntIndexToEntRef(npc.index);
								CreateTimer(0.1, CheckStuckTank, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
							}
						}
						if(client <= MaxClients)
						{
							SDKHook(client, SDKHook_PreThink, contact_throw_tank);	
							i_TankAntiStuck[client] = EntIndexToEntRef(npc.index);
							CreateTimer(0.1, CheckStuckTank, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
							Custom_Knockback(npc.index, client, 3000.0, true, true);
						}
					}
				}
				b_ThrowPlayerImmenent[npc.index] = false;
				i_GrabbedThis[npc.index] = -1;
				fl_ThrowPlayerCooldown[npc.index] = GetGameTime(npc.index) + 13.0;
			}
		}
		else
		{
			if((flDistanceToTarget < 12500 && npc.m_flNextMeleeAttack < GetGameTime(npc.index) && !I_Wanna_Throw_ally) || (flDistanceToTarget_OnRun < 12500 && npc.m_flNextMeleeAttack < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_TERROR_ATTACK_MOVING");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.43;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
						npc.m_flAttackHappenswillhappen = true;
					}
					//Can we attack right now?
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget_OnRun, 20000.0);
						if(npc.DoSwingTrace(swingTrace, closest,_,_,_,1))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							if(target > 0) 
							{
								float damage = 60.0;
								
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 2.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
								
								
									
								// Hit sound
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
			else if(!I_Wanna_Throw_ally && (flDistanceToTarget < 12500 && fl_ThrowPlayerCooldown[iNPC] < GetGameTime(npc.index) && !npc.m_bLostHalfHealth && (!b_NpcHasDied[closest] || closest < MaxClients) && !i_IsABuilding[closest]))
			{
				int Enemy_I_See;
					
				Enemy_I_See = Can_I_See_Enemy(npc.index, closest);
				//Target close enough to hit
				if(IsValidEntity(closest) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_LastValidPosition[Enemy_I_See]);
					
					f_TankGrabbedStandStill[Enemy_I_See] = GetGameTime(npc.index) + 1.2;
					//Ok just grab this mf
					float flPos[3]; // original
					float flAng[3]; // original
				
					npc.GetAttachment("rhand", flPos, flAng);
					
					TeleportEntity(Enemy_I_See, flPos, NULL_VECTOR, {0.0,0.0,0.0});
					
					SDKCall_SetLocalOrigin(Enemy_I_See, flPos);
					
					if(Enemy_I_See <= MaxClients)
					{
						SetEntityMoveType(Enemy_I_See, MOVETYPE_NONE); //Cant move XD
						SetEntityCollisionGroup(Enemy_I_See, 1);
					}
					
					
					b_DoNotUnStuck[Enemy_I_See] = true;
					if(Enemy_I_See <= MaxClients)
					{
						SetParent(npc.index, Enemy_I_See, "rhand");
					}
					npc.AddGesture("ACT_HULK_THROW");
					
					i_GrabbedThis[npc.index] = EntIndexToEntRef(Enemy_I_See);
				//	fl_ThrowPlayerCooldown[npc.index] = GetGameTime(npc.index) + 10.0;
					fl_ThrowPlayerImmenent[npc.index] = GetGameTime(npc.index) + 1.0;
					b_ThrowPlayerImmenent[npc.index] = true;
					npc.m_flStandStill = GetGameTime(npc.index) + 1.5;
				}
			}
			else if (npc.m_bLostHalfHealth && fl_ThrowPlayerCooldown[iNPC] < GetGameTime(npc.index))
			{
				int ally = GetClosestAlly(npc.index);
				if(IsValidEntity(EntRefToEntIndex(i_IWantToThrowHim[npc.index])))
				{
					ally = EntRefToEntIndex(i_IWantToThrowHim[npc.index]);
				}
				else
				{
					i_IWantToThrowHim[npc.index] = -1;
				}
				
				if(IsValidEntity(ally) && !b_NpcHasDied[ally])
				{

					if(!I_Wanna_Throw_ally)
					{
						i_IWantToThrowHim[npc.index] = EntIndexToEntRef(ally);
					}
					else if(flDistanceToTarget < 12500)
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_LastValidPosition[ally]);
						
						f_TankGrabbedStandStill[ally] = GetGameTime(npc.index) + 1.2;
						i_ThrowAlly[npc.index] = true;
						
						//Ok just grab this mf
						float flPos[3]; // original
						float flAng[3]; // original
					
						npc.GetAttachment("rhand", flPos, flAng);
						
						TeleportEntity(ally, flPos, NULL_VECTOR, {0.0,0.0,0.0});
						
						SDKCall_SetLocalOrigin(ally, flPos);
						
						b_DoNotUnStuck[ally] = true;
						
						npc.AddGesture("ACT_HULK_THROW");
						
						i_GrabbedThis[npc.index] = EntIndexToEntRef(ally);
					//	fl_ThrowPlayerCooldown[npc.index] = GetGameTime(npc.index) + 10.0;
						fl_ThrowPlayerImmenent[npc.index] = GetGameTime(npc.index) + 1.0;
						b_ThrowPlayerImmenent[npc.index] = true;
						npc.m_flStandStill = GetGameTime(npc.index) + 1.5;
						i_IWantToThrowHim[npc.index] = -1;
					}
				}
				else
				{
					i_IWantToThrowHim[npc.index] = -1;
				}
			}
			npc.StartPathing();
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayMusicSound();
}


public Action L4D2_Tank_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	L4D2_Tank npc = view_as<L4D2_Tank>(victim);
	
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.PlayHurtSound();
	}
//	
	return Plugin_Changed;
}

public void L4D2_Tank_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	L4D2_Tank npc = view_as<L4D2_Tank>(victim);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth) //Anger after half hp/400 hp
	{
//		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 1.5;
	//	npc.AddGesture("ACT_PANZER_STAGGER");
		npc.m_bLostHalfHealth = true;
		npc.m_flFlamerActive = 0.0;
		npc.m_bFlamerToggled = false;
				
		npc.m_bDuringHook = false;
		npc.m_flHookDamageTaken = 0.0;
		npc.m_flStandStill = 0.0;
		npc.m_bGrabbedSomeone = false;
	}
}

public void L4D2_Tank_NPCDeath(int entity)
{
	L4D2_Tank npc = view_as<L4D2_Tank>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Music_Stop_All_Tank(entity);
	int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	
	if(IsValidClient(client))
	{
		AcceptEntityInput(client, "ClearParent");
		
		SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
		SetEntityCollisionGroup(client, 5);
		
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(client, pos, Angles, NULL_VECTOR);
	}	
	
	i_GrabbedThis[npc.index] = -1;
	
	
	SDKUnhook(npc.index, SDKHook_Think, L4D2_Tank_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, L4D2_Tank_ClotDamagedPost);
		
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
		
				
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/infected/hulk_2.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.45); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("Death_11ab");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		pos[2] += 20.0;
		
		CreateTimer(3.2, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);

	}
			
//	AcceptEntityInput(npc.index, "KillHierarchy");

	Citizen_MiniBossDeath(entity);
}


static char[] GetTankHealth()
{
	int health = 85;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	
	health = RoundToCeil(float(health) * 1.2);
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}

void Music_Stop_All_Tank(int entity)
{
	StopSound(entity, SNDCHAN_VOICE, "#infected_riot/tank/onebadtank.mp3");
	StopSound(entity, SNDCHAN_VOICE, "#infected_riot/tank/onebadtank.mp3");
	StopSound(entity, SNDCHAN_VOICE, "#infected_riot/tank/onebadtank.mp3");
	StopSound(entity, SNDCHAN_VOICE, "#infected_riot/tank/onebadtank.mp3");
	StopSound(entity, SNDCHAN_VOICE, "#infected_riot/tank/onebadtank.mp3");
}


public Action contact_throw_tank(int client)
{
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	if (IsValidClient(client) && IsPlayerAlive(client) && dieingstate[client] != 0 && TeutonType[client] == TEUTON_NONE)
	{
		
		Zero(b_AlreadyHitTankThrow);
		SDKUnhook(client, SDKHook_PreThink, contact_throw_tank);	
	}
	if ((GetEntityFlags(client) & FL_ONGROUND) != 0 || GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
	{
		Zero(b_AlreadyHitTankThrow);
		SDKUnhook(client, SDKHook_PreThink, contact_throw_tank);	
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
					if (GetVectorDistance(chargerPos, targPos, true) <= (125.0* 125.0))
					{
						if (!b_AlreadyHitTankThrow[entity] && entity != client && i_TankThrewThis[client] != entity)
						{		
							int damage = SDKCall_GetMaxHealth(client) / 3;
							
							if(damage > 2000)
							{
								damage = 2000;
							}
							if(entity > MaxClients)
							{
								damage *= 4;
							}
							
							SDKHooks_TakeDamage(entity, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR, targPos);
							EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
							b_AlreadyHitTankThrow[entity] = true;
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


public Action contact_throw_tank_entity(int client)
{
	CClotBody npc = view_as<CClotBody>(client);
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	if (npc.IsOnGround() && fl_ThrowDelay[client] < GetGameTime(npc.index))
	{
		Zero(b_AlreadyHitTankThrow);
		SDKUnhook(client, SDKHook_Think, contact_throw_tank_entity);	
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
					if (GetVectorDistance(chargerPos, targPos, true) <= (125.0* 125.0))
					{
						if (!b_AlreadyHitTankThrow[entity] && entity != client && i_TankThrewThis[client] != entity)
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
							b_AlreadyHitTankThrow[entity] = true;
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


void ApplySdkHookTankThrow(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		fl_ThrowDelay[entity] = GetGameTime(entity) + 0.1;
		SDKHook(entity, SDKHook_Think, contact_throw_tank_entity);		
	}
	
}

public Action CheckStuckTank(Handle timer, any entid)
{
	int client = EntRefToEntIndex(entid);
	if(IsValidEntity(client))
	{
		float flMyPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];
		if(b_IsGiant[client])
		{
		 	hullcheckmaxs_Player = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins_Player = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}
		else
		{	
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );			
		}
		
		if(IsValidClient(client)) //Player size
		{
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}
		
		if(IsSpaceOccupiedIgnorePlayers(flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, client))
		{
			if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
			{
				int damage = SDKCall_GetMaxHealth(client) / 8;
				SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
			}
			TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
		}
		else
		{
			int tank = EntRefToEntIndex(i_TankAntiStuck[client]);
			if(IsValidEntity(tank))
			{
				bool Hit_something = Can_I_See_Enemy_Only(tank, client);
				//Target close enough to hit
				if(!Hit_something)
				{	
					if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
					{
						int damage = SDKCall_GetMaxHealth(client) / 8;
						SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
					}
					TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
				}
			}
			else
			{
				//Just teleport back, dont fucking risk it.
				TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
			}
		}
	}
	return Plugin_Handled;
}