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


static float fl_Scaramouche_Global_Ability_Timer;

static float fl_Spin_To_Win_Global_Ability_Timer;

public void Ikunagae_OnMapStart_NPC()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_DefaultCapperShootSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);

	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheModel("materials/sprites/laserbeam.vmt", true);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ikunagae");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_ikunagae");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "ikunage"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Ikunagae(vecPos, vecAng, team, data);
}
methodmap Ikunagae < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flScaraSeverity
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flAnglesAbility
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flAnglesSpinToWin
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flSpinToWinDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flScaraAbilityTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flSpinToWinAbilityTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property int m_iBarrageSeverity
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
	property int m_iMaxSpawnsDo
	{
		public get()		{ return this.m_iAttacksTillMegahit; }
		public set(int value) 	{ this.m_iAttacksTillMegahit = value; }
	}
	property int m_iBarrageBooleanThing
	{
		public get()		{ return i_GunMode[this.index]; }
		public set(int value) 	{ i_GunMode[this.index] = value; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80, 85));
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
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_DefaultCapperShootSound[GetRandomInt(0, sizeof(g_DefaultCapperShootSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public Ikunagae(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Ikunagae npc = view_as<Ikunagae>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "13500", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		i_NpcWeight[npc.index] = 3;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);		

		npc.m_bThisNpcIsABoss = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		bool LimitSpawns = StrContains(data, "limit_spawns") != -1;
		npc.m_iMaxSpawnsDo = 9999;
		if(LimitSpawns)
		{
			npc.m_iMaxSpawnsDo = 3;
		}
		

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

		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		
		npc.m_flSpeed = 262.0;
		
		npc.StartPathing();
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 5.0;
		npc.m_iBarrageSeverity = 6;

		if(GetTeam(npc.index)!=TFTeam_Red)
		{
			npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + GetRandomFloat(12.0, 20.0);
			//Randomised to prevent mega lag.
			
			npc.m_flScaraAbilityTimer = GetGameTime(npc.index) + GetRandomFloat(15.0, 30.0);

			npc.m_flSpinToWinAbilityTimer = GetGameTime(npc.index) + GetRandomFloat(10.0, 30.0);
			
			npc.m_iBarrageBooleanThing = false;
			
			Severity_Core(npc.index);
		}
		return npc;
	}
	
	
}

static void Internal_ClotThink(int iNPC)
{
	Ikunagae npc = view_as<Ikunagae>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNorm_Attack_Duration > GameTime)
		Iku_NormAttackTick(npc);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(GetTeam(npc.index)!=TFTeam_Red)
	{
		npc.m_flAnglesAbility += 1.0;
		
		if(npc.m_flAnglesAbility>=135.0)
		{
			npc.m_flAnglesAbility = 45.0;
		}
	}
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		//Predict their pos.
		
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		
			
		//Body pitch
		float v[3], ang[3];
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec2);
		SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
				
		float flPitch = npc.GetPoseParameter(iPitch);
				
		//	ang[0] = clamp(ang[0], -44.0, 89.0);
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		
		if(flDistanceToTarget < npc.GetLeadRadius()) {
				
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
		npc.StartPathing();
			
		int Enemy_I_See;		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);

		if(GetTeam(npc.index)!=TFTeam_Red)
		{
			if(fl_Spin_To_Win_Global_Ability_Timer < GameTime)
			{
				if(npc.m_flSpinToWinAbilityTimer < GameTime)
				{
					npc.m_flSpinToWinAbilityTimer = GameTime + 12.5;	//retry in 12.5 seconds

					if(Spin_To_Win_Clearance_Check(npc.index))
					{
						npc.m_flSpinToWinAbilityTimer = GameTime + 120.0;
						fl_Spin_To_Win_Global_Ability_Timer=GameTime + 30.0;
						
						Spin_To_Win_Activate(npc.index, 10.0, 5.0);	//setting severity to 10 or more is just pointless, also lots of lag! same thing when using alt but with over 5
					}
				}
			}
			if(fl_Scaramouche_Global_Ability_Timer < GameTime)
			{
				if(npc.m_flScaraAbilityTimer < GameTime)
				{
					npc.m_flScaraAbilityTimer = GameTime + 60.0;
					fl_Scaramouche_Global_Ability_Timer = GameTime + 12.5;
					Scaramouche_Activate(npc.index);
				}
			}
		}
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.m_flAttackHappens = GameTime+0.4;
						npc.m_flAttackHappens_bullshit = GameTime+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
						npc.m_flNextMeleeAttack = GameTime + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.8;
					}
				}
			}
			else
			{
				if(flDistanceToTarget < 202500 && npc.m_flNextMeleeAttack < GameTime)
				{
					npc.m_flNextMeleeAttack = GameTime + 1.5;
					npc.AddGesture("ACT_MP_THROW");
					npc.FaceTowards(vecTarget, 20000.0);
					npc.FaceTowards(vecTarget, 20000.0);
					fl_BEAM_ChargeUpTime[npc.index] = GameTime + 0.2;
					npc.m_flNorm_Attack_Duration = GameTime + 0.45;
					npc.PlayLaserLaunchSound();
					
				}

				npc.StartPathing();
			}
			if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime)
			{	
				npc.m_iAmountProjectiles += 1;
				float dmg = 100.0;
				Barrage_Attack_Start(npc.index, PrimaryThreatIndex, dmg, true);	//kinda custom attack logic for this npc
				npc.PlayRangedSound();
				npc.m_flNextRangedBarrage_Singular = GameTime + 0.1;
				if(npc.m_iAmountProjectiles >= npc.m_iBarrageSeverity)
				{
					npc.m_iAmountProjectiles = 0;
					npc.m_flNextRangedBarrage_Spam = GameTime + 45.0;
					if(GetTeam(npc.index)!=TFTeam_Red)
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
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	Ikunagae npc = view_as<Ikunagae>(victim);
	
	if(GetTeam(npc.index)!=TFTeam_Red)
		Severity_Core(npc.index);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Ikunagae npc = view_as<Ikunagae>(entity);
	
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, Scaramouche_TBB_Tick);
		
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

#define IKU_MAX_VORTEXES 3

static int i_Scaramouche_Vortex_ID[MAXENTITIES][IKU_MAX_VORTEXES];
static int i_Scaramouche_Vortex_Total[MAXENTITIES];
static float fl_Scaramouche_Vortex_Attack_Timer[MAXENTITIES][IKU_MAX_VORTEXES];
static float fl_Scaramouche_Vortex_Timer[MAXENTITIES][IKU_MAX_VORTEXES];
static float fl_Scaramouche_Vortex_Vec[MAXENTITIES][IKU_MAX_VORTEXES][3]; 

static void Scaramouche_Activate(int client)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	float time = 5.0;

	i_Scaramouche_Vortex_Total[npc.index] = 0;
	
	for(int i=0 ; i<IKU_MAX_VORTEXES ; i++)
	{
		i_Scaramouche_Vortex_ID[npc.index][i] = -1;
	}
	
	float UserLoc[3];
	
	GetAbsOrigin(client, UserLoc);
	UserLoc[2] += 10.0;
	
	int type_class = 2;
	int type = 0;
	float range = 600.0 / type_class;
	for(int j=0 ; j<IKU_MAX_VORTEXES; j++)
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
	
	CreateTimer(time, Scaramouche_TBB_Timer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Scaramouche_TBB_Tick);
	
	
}
public Action Scaramouche_TBB_Timer(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
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
	
	for(int i=0 ; i< i_Scaramouche_Vortex_Total[npc.index] ; i++)
	{
		if(i_Scaramouche_Vortex_ID[npc.index][i]==1 && fl_Scaramouche_Vortex_Attack_Timer[npc.index][i]<GetGameTime(npc.index))
		{
			if(fl_Scaramouche_Vortex_Timer[npc.index][i]<GetGameTime(npc.index))
			{
				i_Scaramouche_Vortex_ID[npc.index][i] = -1;
			}
			else
			{
				fl_Scaramouche_Vortex_Attack_Timer[npc.index][i] = GetGameTime(npc.index) + npc.m_flScaraSeverity;
				float Location[3];
				Location = fl_Scaramouche_Vortex_Vec[npc.index][i];
				int PrimaryThreatIndex = npc.m_iTarget;
				if(IsValidEnemy(npc.index, PrimaryThreatIndex))
				{
					float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
					npc.FireParticleRocket(vecTarget, 100.0 , 450.0 , 200.0 , "raygun_projectile_blue",_,_,true,Location);
				}
				//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
			}
			
		}
	}
	return Plugin_Continue;

}
static void Scaramouche_BEAM(int client, float UserLoc[3], float vecAngles[3], int type, float range)
{
	float startPoint[3];
	float endPoint[3];
	float Range = range * type;
	
	startPoint = UserLoc;
	Handle trace = TR_TraceRayFilterEx(UserLoc, vecAngles, 11, RayType_Infinite, Ruina_Laser_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
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
		TE_SetupBeamPoints(endPoint, UserLoc, g_Ruina_BEAM_lightning, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
		TE_SendToAll();
			
	}
	delete trace;
}
static void Scaramouche_Do_Effect_And_Attack(int client, float EndLoc[3])
{
	Ikunagae npc = view_as<Ikunagae>(client);
	ParticleEffectAt(EndLoc, "eyeboss_tp_vortex", 5.0);
	
	i_Scaramouche_Vortex_ID[client][i_Scaramouche_Vortex_Total[client]] = 1;
	fl_Scaramouche_Vortex_Timer[client][i_Scaramouche_Vortex_Total[client]] = GetGameTime(npc.index) + 7.5;
	fl_Scaramouche_Vortex_Vec[client][i_Scaramouche_Vortex_Total[client]] = EndLoc;
	i_Scaramouche_Vortex_Total[client]++;
}
///SPIN_TO_WIN Core



static void Spin_To_Win_Activate(int client, float time, float charge_time)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	charge_time /= 1.7;
	npc.m_flSpinToWinDuration = time;
	npc.m_flAnglesSpinToWin = 0.0;
	fl_BEAM_ThrottleTime[npc.index] = 0.0;
	
	float UserLoc[3];
	GetAbsOrigin(client, UserLoc);
	
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
	
	TE_SetupBeamPoints(UserLoc, skyloc, g_Ruina_BEAM_lightning, 0, 0, 0, charge_time*1.7, 22.0, 10.2, 1, 8.0, color, 0);
	TE_SendToAll();
	UserLoc[2] += 50.0;
	fl_AbilityVectorData[client] = UserLoc;
	
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
	
	CreateTimer(charge_time*1.7, Spin_To_Win_Activate_Timer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}
public Action Spin_To_Win_Activate_Timer(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidEntity(client))
		return Plugin_Continue;
		
	Ikunagae npc = view_as<Ikunagae>(client);
	
	CreateTimer(npc.m_flSpinToWinDuration, Spin_To_Win_TBB_Timer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Spin_To_Win_TBB_Tick);
	
	return Plugin_Continue;
}

public Action Spin_To_Win_TBB_Timer(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
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
	UserLoc = fl_AbilityVectorData[client];
	
	UserAng[0] = 0.0;
	UserAng[1] = npc.m_flAnglesSpinToWin;
	UserAng[2] = 0.0;
	
	float CustomAng = 1.0;
	float distance = 100.0;
	
	npc.m_flAnglesSpinToWin += 1.5;
	
	if (npc.m_flAnglesSpinToWin >= 360.0)
	{
		npc.m_flAnglesSpinToWin = 0.0;
	}
	int testing = npc.m_iState;
	if(fl_BEAM_ThrottleTime[npc.index] < GetGameTime(npc.index))//Very fast
	{
		fl_BEAM_ThrottleTime[npc.index] = GetGameTime(npc.index) + 0.25;
		if(npc.m_iBarrageBooleanThing)
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
	return Plugin_Continue;
}
static void Spin_To_Win_attack(int client, float endLoc[3], int type)
{
	
	Ikunagae npc = view_as<Ikunagae>(client);
	int r, g, b, a;
	switch(type)
	{
		case 0:
		{
			npc.FireParticleRocket(endLoc, 25.0 , 300.0 , 100.0 , "raygun_projectile_blue_crit",_,_,true,fl_AbilityVectorData[client]);
			r = 41;
			g = 146;
			b = 158;
			a = 175;
		}
		case 1:
		{
			npc.FireParticleRocket(endLoc, 25.0, 300.0 , 100.0 , "raygun_projectile_red_crit",_,_,true,fl_AbilityVectorData[client]);
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
	Aya_UserLoc = fl_AbilityVectorData[client];
									
	TE_SetupBeamPoints(endLoc, Aya_UserLoc, g_Ruina_BEAM_lightning, 0, 0, 0, 0.3, 22.0, 10.2, 0, 4.0, color, 0);
	TE_SendToAll();
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
}
static bool Spin_To_Win_Clearance_Check(int client)
{
	float UserLoc[3], Angles[3];
	GetAbsOrigin(client, UserLoc);
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
	
		Handle trace = TR_TraceRayFilterEx(UserLoc, Angles, 11, RayType_Infinite, Ruina_Laser_BEAM_TraceWallsOnly);
		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			
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
		delete trace;
	}
	return (Total_Hit/360>=0.75);
}
///barrage attack Core.

static void Barrage_Attack_Start(int client, int target, float damgae, bool alternate)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	
	float Angles[3], distance = 100.0, UserLoc[3];
	
	GetAbsOrigin(npc.index, UserLoc);
	
	UserLoc[2] += 50.0;
	
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	
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
			tempAngles[1] = Angles[1] + type*npc.m_flAnglesAbility+alpha;
			tempAngles[2] = 0.0;
														
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
											
			TE_SetupBeamPoints(endLoc, UserLoc, g_Ruina_BEAM_lightning, 0, 0, 0, 0.2, 22.0, 10.2, 0, 4.0, color, 0);
			TE_SendToAll();
			
			npc.FireParticleRocket(endLoc, damgae , 450.0 , 100.0 , "raygun_projectile_blue");
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		}
		
	}
	else
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = /*-32.5+*/Angles[0];
		tempAngles[1] = Angles[1] + npc.m_flAnglesAbility-90;
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
										
		TE_SetupBeamPoints(endLoc, UserLoc, g_Ruina_BEAM_lightning, 0, 0, 0, 0.8, 22.0, 10.2, 10, 4.0, color, 0);
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
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
	
	float Ratio = Health / MaxHealth;
/*
	int spin_min = 2;
	int spin_max = 6;

	int barrage_min = 6;
	int barrage_max = 24;

	float scara_min = 0.5;
	float scara_max = 3.0;

	theres just too much, i had to reduce it.
	*/
	int spin_min = 3;
	int spin_max = 3;

	int barrage_min = 8;
	int barrage_max = 8;

	float scara_min = 1.0;
	float scara_max = 1.0;

	npc.m_iBarrageBooleanThing = (Ratio < 0.4);

	npc.m_iState = RoundToCeil(spin_min + (spin_max - spin_min) * (1.0-Ratio));
	npc.m_iBarrageSeverity= RoundToCeil(barrage_min + (barrage_max - barrage_min) * (1.0-Ratio));
	npc.m_flScaraSeverity = scara_min + (scara_max - scara_min) * Ratio;
}

///Primary Long attack core

static void Iku_NormAttackTick(Ikunagae npc)
{
	if(fl_BEAM_ChargeUpTime[npc.index] > GetGameTime(npc.index))
		return;

	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 10.0;
	Data.Range = 1000.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = 60.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = 45.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Color = {193, 247, 244, 30};
	Data.DoEffects = true;
	GetAttachment(npc.index, "effect_hand_r", Data.EffectsStartLoc, NULL_VECTOR);
	Basic_NPC_Laser_Logic(Data);
}

///Npc Spawn Core

static void Ikunagae_Spawn_Minnions(int client, int hp_multi)
{
	Ikunagae npc = view_as<Ikunagae>(client);
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.2) > ratio)
	{
		npc.g_TimesSummoned++;
		if(npc.m_iMaxSpawnsDo == 3)
		{
			//half said spawns.
			npc.g_TimesSummoned += 99; //only ever spawn one!
		}
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
					spawn_index = NPC_CreateByName("npc_alt_medic_berserker", npc.index, pos, ang, GetTeam(npc.index));
					maxhealth = RoundToNearest(maxhealth * 1.2);
				}
				case 2:
				{
					spawn_index = NPC_CreateByName("npc_alt_medic_charger", npc.index, pos, ang, GetTeam(npc.index));
					maxhealth = RoundToNearest(maxhealth * 1.2);
				}
				case 3:
				{
					spawn_index = NPC_CreateByName("npc_alt_combine_soldier_deutsch_ritter", npc.index, pos, ang, GetTeam(npc.index));
					maxhealth = RoundToNearest(maxhealth * 0.8);
				}
				case 4:
				{
					spawn_index = NPC_CreateByName("npc_alt_sniper_railgunner", npc.index, pos, ang, GetTeam(npc.index));
					maxhealth = RoundToNearest(maxhealth * 1.1);
				}
				case 5:
				{
					spawn_index = NPC_CreateByName("npc_alt_soldier_barrager", npc.index, pos, ang, GetTeam(npc.index));
					maxhealth = RoundToNearest(maxhealth * 1.1);
				}
			}
			if(spawn_index > MaxClients)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
	}
}