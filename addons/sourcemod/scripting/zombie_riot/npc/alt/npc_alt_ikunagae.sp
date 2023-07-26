#pragma semicolon 1
#pragma newdecls required


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

static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static char g_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};
static char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static char g_PullSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};


//static char gLaser1;
static char gLaser2;

static bool clearance[MAXENTITIES]={false,...};

static int i_AmountProjectiles[MAXENTITIES];

static int i_Severity_Spin_To_Win[MAXENTITIES];
static bool b_Severity_Spin_To_Win[MAXENTITIES];

static int i_Severity_Barrage[MAXENTITIES];


static float fl_Severity_Scaramouche[MAXENTITIES];

static float fl_Scaramouche_Ability_Timer[MAXENTITIES];
static float fl_Scaramouche_Global_Ability_Timer;

static float fl_Spin_To_Win_Ability_Timer[MAXENTITIES];
static float fl_Spin_To_Win_Global_Ability_Timer;

static bool Ikunagae_BEAM_CanUse[MAXENTITIES];
static bool Ikunagae_BEAM_IsUsing[MAXENTITIES];
static int Ikunagae_BEAM_TicksActive[MAXENTITIES];
static int Ikunagae_BEAM_Laser;
static int Ikunagae_BEAM_Glow;
static float Ikunagae_BEAM_CloseDPT[MAXENTITIES];
static float Ikunagae_BEAM_FarDPT[MAXENTITIES];
static int Ikunagae_BEAM_MaxDistance[MAXENTITIES];
static int Ikunagae_BEAM_BeamRadius[MAXENTITIES];
static int Ikunagae_BEAM_ColorHex[MAXENTITIES];
static int Ikunagae_BEAM_ChargeUpTime[MAXENTITIES];
static float Ikunagae_BEAM_CloseBuildingDPT[MAXENTITIES];
static float Ikunagae_BEAM_FarBuildingDPT[MAXENTITIES];
static float Ikunagae_BEAM_Duration[MAXENTITIES];
static float Ikunagae_BEAM_BeamOffset[MAXENTITIES][3];
static float Ikunagae_BEAM_ZOffset[MAXENTITIES];
static bool Ikunagae_BEAM_HitDetected[MAXENTITIES];
static int Ikunagae_BEAM_BuildingHit[MAXENTITIES];
static bool Ikunagae_BEAM_UseWeapon[MAXENTITIES];

public void Ikunagae_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));			i++) { PrecacheSound(g_HurtSounds[i]);			}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); 	i++) { PrecacheSound(g_IdleAlertedSounds[i]); 	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));		i++) { PrecacheSound(g_MeleeHitSounds[i]);		}
	for (int i = 0; i < (sizeof(g_DeathSounds));		i++) { PrecacheSound(g_DeathSounds[i]);			}
	for (int i = 0; i < (sizeof(g_PullSounds));  		i++) { PrecacheSound(g_PullSounds[i]);   		}
	
	Ikunagae_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Ikunagae_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	//gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gLaser2= PrecacheModel("materials/sprites/lgtning.vmt");
	PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

methodmap Ikunagae < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	//static bool b_scaramouche_used[MAXENTITIES] = { false, ... };
	public Ikunagae(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Ikunagae npc = view_as<Ikunagae>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "13500", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_NpcInternalId[npc.index] = ALT_IKUNAGAE;
		i_NpcWeight[npc.index] = 3;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		
		SDKHook(npc.index, SDKHook_Think, Ikunagae_ClotThink);				
		
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		

		//models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl
		//models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl
		//models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		
		npc.m_flSpeed = 262.0;
		
		npc.StartPathing();
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		fl_Scaramouche_Ability_Timer[npc.index] = GetGameTime(npc.index) + GetRandomFloat(15.0, 30.0);

		fl_Spin_To_Win_Ability_Timer[npc.index] = GetGameTime(npc.index) + GetRandomFloat(10.0, 30.0);
		
		clearance[npc.index] = false;
		b_Severity_Spin_To_Win[npc.index] = false;
		
		Severity_Core(npc.index);
		
		//Scaramouche_Activate(npc.index);
		
		//Spin_To_Win_Activate(npc.index, 3, false, 60.0, 10.0);	//setting severity to 10 or more is just pointless, also lots of lag! same thing when using alt but with over 4
		
		return npc;
	}
	
	
}

static float Normal_Attack_Angles[MAXENTITIES];	//placing this here to use the clot think.

//TODO 
//Rewrite
public void Ikunagae_ClotThink(int iNPC)
{
	Ikunagae npc = view_as<Ikunagae>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	Normal_Attack_Angles[npc.index] += 1.0;
	
	if(Normal_Attack_Angles[npc.index]>=135.0)
	{
		Normal_Attack_Angles[npc.index] = 45.0;
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

		//Predict their pos.
		
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		
			
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(WorldSpaceCenter(npc.index), WorldSpaceCenter(PrimaryThreatIndex), v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
				
		float flPitch = npc.GetPoseParameter(iPitch);
				
		//	ang[0] = clamp(ang[0], -44.0, 89.0);
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		
		if(flDistanceToTarget < npc.GetLeadRadius()) {
				
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		npc.StartPathing();
			
		int Enemy_I_See;		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		
		if(fl_Spin_To_Win_Global_Ability_Timer < GetGameTime(npc.index))
		{
			if(fl_Spin_To_Win_Ability_Timer[npc.index] < GetGameTime(npc.index))
			{
				clearance[npc.index] = false;
				fl_Spin_To_Win_Ability_Timer[npc.index] = GetGameTime(npc.index) + 12.5;	//retry in 12.5 seconds
				Spin_To_Win_Clearance_Check(npc.index);
				if(clearance[npc.index])
				{
					fl_Spin_To_Win_Ability_Timer[npc.index] = GetGameTime(npc.index) + 120.0;
					fl_Spin_To_Win_Global_Ability_Timer=GetGameTime(npc.index) + 30.0;
					
					Spin_To_Win_Activate(npc.index, i_Severity_Spin_To_Win[npc.index], b_Severity_Spin_To_Win[npc.index], 15.0, 10.0);	//setting severity to 10 or more is just pointless, also lots of lag! same thing when using alt but with over 5
				}
			}
		}
		if(fl_Scaramouche_Global_Ability_Timer < GetGameTime(npc.index))
		{
			if(fl_Scaramouche_Ability_Timer[npc.index] < GetGameTime(npc.index))
			{
				fl_Scaramouche_Ability_Timer[npc.index] = GetGameTime(npc.index) + 60.0;
				fl_Scaramouche_Global_Ability_Timer = GetGameTime(npc.index) + 12.5;
				Scaramouche_Activate(npc.index);
			}
		}
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								
								if(!ShouldNpcDealBonusDamage(target))
									SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 750.0, DMG_CLUB, -1, _, vecHit);	//Cade Devestation
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
					}
				}
			}
			else
			{
				if(flDistanceToTarget < 202500 && npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					npc.PlayPullSound();
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.5;
					npc.AddGesture("ACT_MP_THROW");
					npc.FaceTowards(vecTarget, 20000.0);
					npc.FaceTowards(vecTarget, 20000.0);
					Normal_Attack_BEAM_Iku_Ability(npc.index);
				}

				npc.StartPathing();
			}
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index))
			{	
				npc.m_iAmountProjectiles += 1;
				float dmg = 100.0;
				Normal_Attack_Start(npc.index, PrimaryThreatIndex, dmg, true);	//kinda custom attack logic for this npc
				npc.PlayRangedSound();
				npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.1;
				if (npc.m_iAmountProjectiles >= i_Severity_Barrage[npc.index])
				{
					npc.m_iAmountProjectiles = 0;
					npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 45.0;
					Ikunagae_Spawn_Minnions(npc.index, 8);
				}
			}
		}
		else
		{
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
	npc.PlayIdleAlertSound();
}

public Action Ikunagae_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	Ikunagae npc = view_as<Ikunagae>(victim);
	
	Severity_Core(npc.index);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Ikunagae_NPCDeath(int entity)
{
	Ikunagae npc = view_as<Ikunagae>(entity);
	
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, Scaramouche_TBB_Tick);
	
	SDKUnhook(npc.index, SDKHook_Think, Ikunagae_ClotThink);	
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}


///Scara-attack-core

#define IKU_MAX_VORTEXES 10

static float fl_Scaramouche_Angle[MAXENTITIES];

static int i_Scaramouche_Vortex_ID[MAXENTITIES][IKU_MAX_VORTEXES+1];
static int i_Scaramouche_Vortex_Total[MAXENTITIES];
static float fl_Scaramouche_Vortex_Attack_Timer[MAXENTITIES][IKU_MAX_VORTEXES+1];
static float fl_Scaramouche_Vortex_Timer[MAXENTITIES][IKU_MAX_VORTEXES+1];
static float fl_Scaramouche_Vortex_Vec[MAXENTITIES][IKU_MAX_VORTEXES+1][3]; 

static void Scaramouche_Activate(int client)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	float time = 5.0;
	
	fl_Scaramouche_Angle[npc.index] = 180.0;
	i_Scaramouche_Vortex_Total[npc.index] = 0;
	
	for(int i=0 ; i<IKU_MAX_VORTEXES+1 ; i++)
	{
		i_Scaramouche_Vortex_ID[npc.index][i] = -1;
	}
	
	float UserLoc[3];
	
	UserLoc = GetAbsOrigin(client);
	UserLoc[2] += 10.0;
	
	int type_class = 2;
	int type = 0;
	float range = 600.0 / type_class;
	for(int j=1 ; j<=IKU_MAX_VORTEXES; j++)
	{
		type++;
		if(type>type_class)
		{
			type = 1;
		}
		float distance = 100.0;
	
		float tempAngles[3], endLoc[3], Direction[3];
		
		float angles[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		
		tempAngles[0] =	float(j)*9.0+180.0;
		tempAngles[1] = angles[1]-90.0;
		tempAngles[2] = 0.0;
				
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, distance);
		AddVectors(UserLoc, Direction, endLoc);
		
		float vecAngles[3];
		
		MakeVectorFromPoints(UserLoc, endLoc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		Scaramouche_BEAM(npc.index, UserLoc, vecAngles, type, range);
	}
	
	CreateTimer(time, Scaramouche_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Scaramouche_TBB_Tick);
	
	
}
public Action Scaramouche_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;
		
	SDKUnhook(client, SDKHook_Think, Scaramouche_TBB_Tick);
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}
public Action Scaramouche_TBB_Tick(int client)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	if(!IsValidEntity(client))
	{
		SDKUnhook(client, SDKHook_Think, Scaramouche_TBB_Tick);
	}
	
	for(int i=0 ; i<=i_Scaramouche_Vortex_Total[npc.index] ; i++)
	{
		if(i_Scaramouche_Vortex_ID[npc.index][i]==1 && fl_Scaramouche_Vortex_Attack_Timer[npc.index][i]<GetGameTime(npc.index))
		{
			if(fl_Scaramouche_Vortex_Timer[npc.index][i]<GetGameTime(npc.index))
			{
				i_Scaramouche_Vortex_ID[npc.index][i] = -1;
			}
			else
			{
				fl_Scaramouche_Vortex_Attack_Timer[npc.index][i] = GetGameTime(npc.index) + fl_Severity_Scaramouche[npc.index];
				float Location[3];
				Location = fl_Scaramouche_Vortex_Vec[npc.index][i];
				int PrimaryThreatIndex = npc.m_iTarget;
				if(IsValidEnemy(npc.index, PrimaryThreatIndex))
				{
					float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
					npc.FireParticleRocket(vecTarget, 100.0 , 450.0 , 100.0 , "raygun_projectile_blue",_,_,true,Location);
				}
				//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
			}
			
		}
	}
	return Plugin_Continue;

}
static bool Scaramouche_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
static void Scaramouche_BEAM(int client, float UserLoc[3], float vecAngles[3], int type, float range)
{
	float startPoint[3];
	float endPoint[3];
	float Range = range * type;
	
	startPoint = UserLoc;
	Handle trace = TR_TraceRayFilterEx(UserLoc, vecAngles, 11, RayType_Infinite, Scaramouche_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
		CloseHandle(trace);
		ConformLineDistance(endPoint, startPoint, endPoint, Range);
		float lineReduce = 5.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		
		Scaramouche_Do_Effect_And_Attack(client, endPoint);
		
		int colour[4];
		colour[0]=41;
		colour[1]=146;
		colour[2]=158;
		colour[3]=175;
		TE_SetupBeamPoints(endPoint, UserLoc, gLaser2, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
		TE_SendToAll();
			
	}
	else
	{
		delete trace;
	}
}
static void Scaramouche_Do_Effect_And_Attack(int client, float EndLoc[3])
{
	Ikunagae npc = view_as<Ikunagae>(client);
	ParticleEffectAt(EndLoc, "eyeboss_tp_vortex", 5.0);
	
	i_Scaramouche_Vortex_Total[client]++;
	i_Scaramouche_Vortex_ID[client][i_Scaramouche_Vortex_Total[client]] = 1;
	fl_Scaramouche_Vortex_Timer[client][i_Scaramouche_Vortex_Total[client]] = GetGameTime(npc.index) + 7.5;
	fl_Scaramouche_Vortex_Vec[client][i_Scaramouche_Vortex_Total[client]] = EndLoc;
	

}
///SPIN_TO_WIN Core

static float fl_Spin_to_win_Angle[MAXENTITIES];
static float fl_spin_to_win_Origin_Vec[MAXENTITIES][3];
static float fl_spin_to_win_duration[MAXENTITIES];

static int i_spin_to_win_Severity[MAXENTITIES];
static int i_spin_to_win_throttle[MAXENTITIES];

static bool b_spin_to_win_Alternate[MAXENTITIES];

static void Spin_To_Win_Activate(int client, int severity, bool alternate_attack, float time, float charge_time)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	charge_time /= 1.7;
	fl_spin_to_win_duration[npc.index] = time;
	fl_Spin_to_win_Angle[npc.index] = 0.0;
	i_spin_to_win_Severity[npc.index] = severity;
	b_spin_to_win_Alternate[npc.index] = alternate_attack;
	i_spin_to_win_throttle[npc.index] = 0;
	
	float UserLoc[3];
	UserLoc = GetAbsOrigin(client);
	
	int r, g, b, a;
	r = 41;
	g = 146;
	b = 158;
	a = 175;
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	float skyloc[3];
	skyloc = UserLoc;
	skyloc[2] = 5000.0;
	
	TE_SetupBeamPoints(UserLoc, skyloc, gLaser2, 0, 0, 0, charge_time*1.7, 22.0, 10.2, 1, 8.0, color, 0);
	TE_SendToAll();
	UserLoc[2] += 50.0;
	fl_spin_to_win_Origin_Vec[client] = UserLoc;
	
	UserLoc[2] += 45.0;
	float Range = 10.0*charge_time*1.7;

	
	spawnRing_Vectors(UserLoc, Range * 2.1, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.7, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.2, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.6, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.3, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.5, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.4, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.4, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.5, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.3, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.6, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.2, 6.0, 0.1, 1, 1.0);
	UserLoc[2] -= 12.5;
	spawnRing_Vectors(UserLoc, Range * 2.7, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, charge_time*1.1, 6.0, 0.1, 1, 1.0);
	
	CreateTimer(charge_time*1.7, Spin_To_Win_Activate_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action Spin_To_Win_Activate_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;
		
	Ikunagae npc = view_as<Ikunagae>(client);
	
	CreateTimer(fl_spin_to_win_duration[npc.index], Spin_To_Win_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Spin_To_Win_TBB_Tick);
	
	return Plugin_Continue;
}

public Action Spin_To_Win_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;
		
	SDKUnhook(client, SDKHook_Think, Spin_To_Win_TBB_Tick);
	
	return Plugin_Continue;
}
public Action Spin_To_Win_TBB_Tick(int client)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	if(!IsValidEntity(client))
	{
		SDKUnhook(client, SDKHook_Think, Spin_To_Win_TBB_Tick);
	}
	
	float UserLoc[3], UserAng[3];
	UserLoc = fl_spin_to_win_Origin_Vec[client];
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_Spin_to_win_Angle[npc.index];
	UserAng[2] = 0.0;
	
	float CustomAng = 1.0;
	float distance = 100.0;
	
	fl_Spin_to_win_Angle[npc.index] += 1.5;
	
	if (fl_Spin_to_win_Angle[npc.index] >= 360.0)
	{
		fl_Spin_to_win_Angle[npc.index] = 0.0;
	}
	int testing = i_spin_to_win_Severity[npc.index];
	if(i_spin_to_win_throttle[npc.index]>15)//Very fast
	{
		i_spin_to_win_throttle[npc.index] = 0;
		if(b_spin_to_win_Alternate[npc.index])
		{
			for(int j=0 ; j<=1 ; j++)
			{
				switch(j)
				{
					case 0:
					{
						CustomAng = 1.0;
					}
					case 1:
					{
						CustomAng = -1.0;
					}
				}
				for(int m=1 ; m <= testing ; m++)
				{
					float tempAngles[3], endLoc[3], Direction[3];
					tempAngles[0] = 0.0;
					tempAngles[1] = CustomAng*(UserAng[1]+(360/testing/2)*float(m*2));
					tempAngles[2] = 0.0;
					
					GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(Direction, distance);
					AddVectors(UserLoc, Direction, endLoc);
					Spin_To_Win_attack(client, endLoc, j);
				}
			}
		}
		else
		{
			for(int m=1 ; m <= testing ; m++)
			{
				float tempAngles[3], endLoc[3], Direction[3];
				tempAngles[0] = 0.0;
				tempAngles[1] = CustomAng*(UserAng[1]+(360/testing/2)*float(m*2));
				tempAngles[2] = 0.0;
				
				GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
				ScaleVector(Direction, distance);
				AddVectors(UserLoc, Direction, endLoc);
				
				Spin_To_Win_attack(client, endLoc, 0);
			}
		}
	}
	i_spin_to_win_throttle[npc.index]++;
	return Plugin_Continue;
}

static int Spin_To_Win_Damage_Multi[MAXENTITIES];

static void Spin_To_Win_attack(int client, float endLoc[3], int type)
{
	
	Ikunagae npc = view_as<Ikunagae>(client);
	int r, g, b, a;
	switch(type)
	{
		case 0:
		{
			npc.FireParticleRocket(endLoc, 25.0*Spin_To_Win_Damage_Multi[client] , 300.0 , 100.0 , "raygun_projectile_blue_crit",_,_,true,fl_spin_to_win_Origin_Vec[client]);
			r = 41;
			g = 146;
			b = 158;
			a = 175;
		}
		case 1:
		{
			npc.FireParticleRocket(endLoc, 25.0*Spin_To_Win_Damage_Multi[client] , 300.0 , 100.0 , "raygun_projectile_red_crit",_,_,true,fl_spin_to_win_Origin_Vec[client]);
			r = 158;
			g = 146;
			b = 41;
			a = 175;
		}
	}
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	float Aya_UserLoc[3];
	Aya_UserLoc = fl_spin_to_win_Origin_Vec[client];
									
	TE_SetupBeamPoints(endLoc, Aya_UserLoc, gLaser2, 0, 0, 0, 0.3, 22.0, 10.2, 0, 4.0, color, 0);
	TE_SendToAll();
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
}
static void Spin_To_Win_Clearance_Check(int client)
{
	
	float UserLoc[3], Angles[3];
	UserLoc = GetAbsOrigin(client);
	float distance = 100.0;
	
	int Total_Hit = 0;
	
	for(int alpha = 1 ; alpha<=360 ; alpha++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(alpha);
		tempAngles[2] = 0.0;
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, distance);
		AddVectors(UserLoc, Direction, endLoc);
		
		MakeVectorFromPoints(UserLoc, endLoc, Angles);
		GetVectorAngles(Angles, Angles);
		
		float endPoint[3];
	
		Handle trace = TR_TraceRayFilterEx(UserLoc, Angles, 11, RayType_Infinite, Scaramouche_BEAM_TraceWallsOnly);
		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			
			float flDistanceToTarget = GetVectorDistance(endPoint, UserLoc);
			
			if(flDistanceToTarget>250.0)
			{
				Total_Hit++;
			}
			/*else
			{
				int colour[4];
				colour[0]=150;
				colour[1]=0;
				colour[2]=255;
				colour[3]=125;
				TE_SetupBeamPoints(endPoint, UserLoc, gLaser1, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
				TE_SendToAll();
			}*/
				
		}
		else
		{
			delete trace;
		}
	}
	if(Total_Hit/360>=0.75)
	{
		clearance[client]=true;
	}
	else
	{
		clearance[client]=false;
	}
}
///barrage attack Core.

static void Normal_Attack_Start(int client, int target, float damgae, bool alternate)
{
	
	Ikunagae npc = view_as<Ikunagae>(client);
	
	float Angles[3], distance = 100.0, UserLoc[3];
				
				
	UserLoc = GetAbsOrigin(npc.index);
	
	UserLoc[2] += 50.0;
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(target);
	
	MakeVectorFromPoints(UserLoc, vecTarget, Angles);
	GetVectorAngles(Angles, Angles);
	
	if(alternate)
	{
		for(int i=0 ; i<=1 ; i++)
		{
			int r, g, b, a;
			int color[4];
			float type = 1.0;
			float alpha = -90.0;
			switch(i)
			{
				case 0:
				{
					r = 1;
					g = 1;
					b = 255;
					a = 255;
					
					color[0] = r;
					color[1] = g;
					color[2] = b;
					color[3] = a;
					type = -1.0;
					alpha = 90.0;
				}
				case 1:
				{
					r = 255;
					g = 1;
					b = 1;
					a = 255;
					
					color[0] = r;
					color[1] = g;
					color[2] = b;
					color[3] = a;
					type = 1.0;
					alpha = -90.0;
				}
			}
			float tempAngles[3], endLoc[3], Direction[3];
			tempAngles[0] = Angles[0];
			tempAngles[1] = Angles[1] + type*Normal_Attack_Angles[npc.index]+alpha;
			tempAngles[2] = 0.0;
														
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
											
			TE_SetupBeamPoints(endLoc, UserLoc, gLaser2, 0, 0, 0, 0.2, 22.0, 10.2, 0, 4.0, color, 0);
			TE_SendToAll();
			
			npc.FireParticleRocket(endLoc, damgae , 450.0 , 100.0 , "raygun_projectile_blue");
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		}
		
	}
	else
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = /*-32.5+*/Angles[0];
		tempAngles[1] = Angles[1] + Normal_Attack_Angles[npc.index]-90;
		tempAngles[2] = 0.0;
													
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, distance);
		AddVectors(UserLoc, Direction, endLoc);
		
		int r, g, b, a;
		r = 41;
		g = 146;
		b = 158;
		a = 175;
		
		int color[4];
		color[0] = r;
		color[1] = g;
		color[2] = b;
		color[3] = a;
										
		TE_SetupBeamPoints(endLoc, UserLoc, gLaser2, 0, 0, 0, 0.8, 22.0, 10.2, 10, 4.0, color, 0);
		TE_SendToAll();
		
		npc.FireParticleRocket(endLoc, damgae , 450.0 , 100.0 , "raygun_projectile_blue");
		//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
	}
}

///Battle Severity Core

static void Severity_Core(int client) //Depending on current hp we determin  the severity of the battle. tl;dr: npc gets stronger on lower hp.
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	
	float Health_Current = Health * 100 / MaxHealth;
	
	if(Health_Current>90)
	{
		i_Severity_Spin_To_Win[npc.index] = 2;
		b_Severity_Spin_To_Win[npc.index] = false;
		i_Severity_Barrage[npc.index] = 6;
		fl_Severity_Scaramouche[npc.index] = 3.0; //The timer thats used to attack on this ability
		Spin_To_Win_Damage_Multi[npc.index] = 1;
	}
	else if(Health_Current>80)
	{
		i_Severity_Barrage[npc.index] = 8;
		fl_Severity_Scaramouche[npc.index] = 2.9;
	}
	else if(Health_Current>70)
	{
		i_Severity_Spin_To_Win[npc.index] = 3;
		i_Severity_Barrage[npc.index] = 10;
		fl_Severity_Scaramouche[npc.index] = 2.85;
	}
	else if(Health_Current>60)
	{
		i_Severity_Barrage[npc.index] = 12;
		fl_Severity_Scaramouche[npc.index] = 2.8;
		i_Severity_Spin_To_Win[npc.index] = 4;
	}
	else if(Health_Current>50)
	{
		i_Severity_Spin_To_Win[npc.index] = 4;
		i_Severity_Barrage[npc.index] = 12;
		fl_Severity_Scaramouche[npc.index] = 2.75;
		Spin_To_Win_Damage_Multi[npc.index] = 2;
	}
	else if(Health_Current>40)
	{
		i_Severity_Spin_To_Win[npc.index] = 2;
		b_Severity_Spin_To_Win[npc.index] = true;
		i_Severity_Barrage[npc.index] = 13;
		fl_Severity_Scaramouche[npc.index] = 2.70;
	}
	else if(Health_Current>30)
	{
		Spin_To_Win_Damage_Multi[npc.index] = 3;
		i_Severity_Barrage[npc.index] = 13;
		fl_Severity_Scaramouche[npc.index] = 2.60;
	}
	else if(Health_Current>20)
	{
		Spin_To_Win_Damage_Multi[npc.index] = 6;
		i_Severity_Spin_To_Win[npc.index] = 4;
		fl_Severity_Scaramouche[npc.index] = 2.25;
		i_Severity_Barrage[npc.index] = 14;
	}
	else if(Health_Current>10)
	{
		fl_Severity_Scaramouche[npc.index] = 1.75;
		Spin_To_Win_Damage_Multi[npc.index] = 6;
		i_Severity_Barrage[npc.index] = 16;
	}
	else	// THATS IT YOU FUCKERS
	{
		fl_Severity_Scaramouche[npc.index] = 0.5;
		Spin_To_Win_Damage_Multi[npc.index] = 6;
		i_Severity_Barrage[npc.index] = 24;
	}
	
	if((ZR_GetWaveCount()+1)==59)	//Makes it so the spam on wave 59 doesn't absoluetly annihialate the server.
	{
		i_Severity_Barrage[npc.index] = 4;
	}
}

///Primary Long attack core

static void Normal_Attack_BEAM_Iku_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		Ikunagae_BEAM_BuildingHit[building] = false;
	}
			
	Ikunagae_BEAM_IsUsing[client] = false;
	Ikunagae_BEAM_TicksActive[client] = 0;

	Ikunagae_BEAM_CanUse[client] = true;
	Ikunagae_BEAM_CloseDPT[client] = 30.0;
	Ikunagae_BEAM_FarDPT[client] = 25.0;
	Ikunagae_BEAM_MaxDistance[client] = 1000;
	Ikunagae_BEAM_BeamRadius[client] = 10;
	Ikunagae_BEAM_ColorHex[client] = ParseColor("c1f7f4");
	Ikunagae_BEAM_ChargeUpTime[client] = 12;
	Ikunagae_BEAM_CloseBuildingDPT[client] = 0.0;
	Ikunagae_BEAM_FarBuildingDPT[client] = 0.0;
	Ikunagae_BEAM_Duration[client] = 0.25;
	
	Ikunagae_BEAM_BeamOffset[client][0] = 0.0;
	Ikunagae_BEAM_BeamOffset[client][1] = 0.0;
	Ikunagae_BEAM_BeamOffset[client][2] = 0.0;

	Ikunagae_BEAM_ZOffset[client] = 0.0;
	Ikunagae_BEAM_UseWeapon[client] = false;

	Ikunagae_BEAM_IsUsing[client] = true;
	Ikunagae_BEAM_TicksActive[client] = 0;

	CreateTimer(Ikunagae_BEAM_Duration[client], Ikunagae_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	
}
static Action Ikunagae_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	Ikunagae_BEAM_IsUsing[client] = false;
	
	Ikunagae_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	return Plugin_Continue;
}

static bool Ikunagae_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool Ikunagae_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Ikunagae_BEAM_HitDetected[entity] = true;
	}
	return false;
}
static void Ikunagae_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	Ikunagae npc = view_as<Ikunagae>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == Ikunagae_BEAM_BeamOffset[client][0] && 0.0 == Ikunagae_BEAM_BeamOffset[client][1] && 0.0 == Ikunagae_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Ikunagae_BEAM_BeamOffset[client][0];
	tmp[1] = Ikunagae_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = Ikunagae_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

static Action Ikunagae_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !Ikunagae_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	Ikunagae_BEAM_TicksActive[client] = tickCount;
	float diameter = float(Ikunagae_BEAM_BeamRadius[client] * 4);
	int r = GetR(Ikunagae_BEAM_ColorHex[client]);
	int g = GetG(Ikunagae_BEAM_ColorHex[client]);
	int b = GetB(Ikunagae_BEAM_ColorHex[client]);
	if (Ikunagae_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		Ikunagae npc = view_as<Ikunagae>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Ikunagae_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(Ikunagae_BEAM_MaxDistance[client]));
			float lineReduce = Ikunagae_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				Ikunagae_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(Ikunagae_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Ikunagae_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Ikunagae_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Ikunagae_BEAM_CloseDPT[client] + (Ikunagae_BEAM_FarDPT[client]-Ikunagae_BEAM_CloseDPT[client]) * (distance/Ikunagae_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;


					if(ShouldNpcDealBonusDamage(victim))
					{
						damage *= 5.0;
					}

					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			
			static float belowBossEyes[3];
			Ikunagae_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Ikunagae_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}

///Npc Spawn Core

static void Ikunagae_Spawn_Minnions(int client, int hp_multi)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.2) > ratio)
	{
		npc.g_TimesSummoned++;
		maxhealth /= hp_multi;
		for(int i; i<1; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index;
			
			switch(GetRandomInt(1,5))
			{
				case 1:
				{
					spawn_index = Npc_Create(ALT_MEDIC_BERSERKER, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					maxhealth = RoundToNearest(maxhealth * 1.2);
				}
				case 2:
				{
					spawn_index = Npc_Create(ALT_MEDIC_CHARGER, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					maxhealth = RoundToNearest(maxhealth * 1.2);
				}
				case 3:
				{
					spawn_index = Npc_Create(ALT_COMBINE_DEUTSCH_RITTER, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					maxhealth = RoundToNearest(maxhealth * 0.8);
				}
				case 4:
				{
					spawn_index = Npc_Create(ALT_SNIPER_RAILGUNNER, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					maxhealth = RoundToNearest(maxhealth * 1.1);
				}
				case 5:
				{
					spawn_index = Npc_Create(ALT_MECHASOLDIER_BARRAGER, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
					maxhealth = RoundToNearest(maxhealth * 1.1);
				}
			}
			if(spawn_index > MaxClients)
			{
				Zombies_Currently_Still_Ongoing += 1;
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
	}
}