#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};
static char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};
static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};

static char gGlow1;
static char gExplosive1;
static char gLaser1;

static bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CanUse[MAXENTITIES];
static bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser;
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Glow;
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseDPT[MAXENTITIES];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarDPT[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_MaxDistance[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ChargeUpTime[MAXENTITIES];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseBuildingDPT[MAXENTITIES];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarBuildingDPT[MAXENTITIES];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Duration[MAXENTITIES];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[MAXENTITIES][3];
static float NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ZOffset[MAXENTITIES];
static bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_HitDetected[MAXENTITIES];
static int NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BuildingHit[MAXENTITIES];
static bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_UseWeapon[MAXENTITIES];

static float fl_TimebeforeIOC[MAXENTITIES];
static float fl_Timebeforekamehameha[MAXENTITIES];
static bool b_InKame[MAXENTITIES];

void NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Precahce();
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	
	PrecacheSound("player/flow.wav");
}
void NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Precahce()
{
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
}
methodmap NPC_ALT_MEDIC_SUPPERIOR_MAGE < CClotBody
{
	
	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_Timebeforekamehameha[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Timebeforekamehameha[this.index] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	public NPC_ALT_MEDIC_SUPPERIOR_MAGE(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.25", "25000", ally));
		
		i_NpcInternalId[npc.index] = ALT_MEDIC_SUPPERIOR_MAGE;
		i_NpcWeight[npc.index] = 3;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = true;
		npc.m_fbRangedSpecialOn = false;
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		SDKHook(npc.index, SDKHook_Think, NPC_ALT_MEDIC_SUPPERIOR_MAGE_ClotThink);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/C_Crossing_Guard/C_Crossing_Guard.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Hood/Xms2013_Medic_Hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Xms2013_Medic_Robe/Xms2013_Medic_Robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 7, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 7, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);	
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		npc.StartPathing();
		fl_TimebeforeIOC[npc.index] = GetGameTime(npc.index) + 5.0;
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 7.5;
		npc.m_bInKame = false;
		npc.Anger = false;
		
		return npc;
	}
}

//TODO 
//Rewrite
public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_ClotThink(int iNPC)
{
	NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
	
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
		{
			if (npc.m_flmovedelay < GetGameTime(npc.index))
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_flmovedelay = GetGameTime(npc.index) + 1.5;
				npc.m_flSpeed = 300.0;					
			}
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			
		}
		
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) {
			
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
		/*	int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
		
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
		
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} else {
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		if(flDistanceToTarget < 60000)	//Do laser of hopefully not doom within a 100 hu's, might be too close but who knows.
		{
			if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index) && !npc.Anger)
			{
				npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 60.0;
				npc.m_bInKame = true;
				NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Ability(npc.index);
			}
			else if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index) && npc.Anger)
			{
				npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 45.0;
				npc.m_bInKame = true;
				NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Ability_Anger(npc.index);
			}
		}
		if(npc.m_bInKame)
		{
			npc.FaceTowards(vecTarget, 700.0);
			npc.m_flSpeed = 100.0;
			f_NpcTurnPenalty[npc.index] = 0.3;
		}
		else
		{
			npc.m_flSpeed = 300.0;
			f_NpcTurnPenalty[npc.index] = 1.0;
		}
		if(flDistanceToTarget > 60000 && flDistanceToTarget < 120000 && !npc.m_bInKame && fl_TimebeforeIOC[npc.index] < GetGameTime(npc.index))
		{
			if(!npc.Anger)
			{
				NPC_ALT_MEDIC_SUPPERIOR_MAGE_IOC_Invoke(EntIndexToEntRef(npc.index), PrimaryThreatIndex);
				fl_TimebeforeIOC[npc.index] = GetGameTime(npc.index) + 60.0;
			}
			if(npc.Anger)
			{
				NPC_ALT_MEDIC_SUPPERIOR_MAGE_IOC_Invoke(EntIndexToEntRef(npc.index), PrimaryThreatIndex);
				fl_TimebeforeIOC[npc.index] = GetGameTime(npc.index) + 45.0;
			}
		}
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen && !npc.m_bInKame)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 2000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
					//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
						
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
					float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,_,_,_,1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
							
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
								
						if(target > 0) 
						{
							float damage = 45.0 * (1.0+(1-(Health/MaxHealth))*2);
							if(ZR_GetWaveCount()<=45)
							{
								damage=damage/1.75;
							}
							if(target <= MaxClients)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB, -1, _, vecHit);
																				
							// Hit particle
							
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
		else if(flDistanceToTarget > 22500 && npc.m_flAttackHappens_2 < GetGameTime(npc.index))
		{
			float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			float crocket = 25.0 / (1.0+(1-(Health/MaxHealth))*2);
			float dmg = 20.0*(1.0+(1-(Health/MaxHealth))*2);
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
			npc.m_flAttackHappens_2 = GetGameTime(npc.index) + crocket;
			npc.PlayRangedSound();
			npc.FireParticleRocket(vecTarget, dmg , 600.0 , 100.0 , "raygun_projectile_blue");
			//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
		}
		else
		{
			npc.StartPathing();
			
		}
		if (npc.m_flReloadDelay < GetGameTime(npc.index))
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

public Action NPC_ALT_MEDIC_SUPPERIOR_MAGE_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(victim);
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) && ZR_GetWaveCount()>40 ) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( <- He is  very angy, but who wouldn't be, they literally lost half of there blood, id say if they weren't angry it would be a real surprise.
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}		
	return Plugin_Changed;
}

public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_NPCDeath(int entity)
{
	NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	
	SDKUnhook(npc.index, SDKHook_Think, NPC_ALT_MEDIC_SUPPERIOR_MAGE_ClotThink);
		
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
}

//something quite funny I hope.

void NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Ability_Anger(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BuildingHit[building] = false;
	}
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client] = false;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = 0;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CanUse[client] = true;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseDPT[client] = 30.0;	//beam dmg 1, 50%<
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarDPT[client] = 17.5;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_MaxDistance[client] = 750;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[client] = 10;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ChargeUpTime[client] = 33;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseBuildingDPT[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarBuildingDPT[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Duration[client] = 1.5;
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][0] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][1] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][2] = 0.0;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ZOffset[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_UseWeapon[client] = false;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client] = true;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 80, _, 0.25, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.25);					
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.25);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.25);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.25);
		}		
	}
			

	CreateTimer(5.0, NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Tick);
}


void NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BuildingHit[building] = false;
	}
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client] = false;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = 0;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CanUse[client] = true;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseDPT[client] = 20.0;	//beam dmg 2, 50%>
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarDPT[client] = 10.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_MaxDistance[client] = 500;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[client] = 10;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[client] = ParseColor("0509FA");
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ChargeUpTime[client] = 33;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseBuildingDPT[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarBuildingDPT[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Duration[client] = 1.5;
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][0] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][1] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][2] = 0.0;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ZOffset[client] = 0.0;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_UseWeapon[client] = false;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client] = true;
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 80, _, 0.25, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.25);					
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.25);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.25);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.25);
		}		
	}
			

	CreateTimer(5.0, NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Tick);
	
}

public Action NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client] = false;
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = 0;
	
	StopSound(client,	SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}



public bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

public bool NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsEntityAlive(entity))
	{
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_HitDetected[entity] = true;
	}
	else if (IsValidEntity(entity))
	{
		if(0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));
			
			if (!StrContains(classname, "zr_base_npc", true) && (GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(client, Prop_Send, "m_iTeamNum")))
			{
				for(int i=1; i < MAXENTITIES; i++)
				{
					if(!NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BuildingHit[i])
					{
						NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BuildingHit[i] = entity;
						break;
					}
				}
			}
			
		}
	}
	return false;
}

static void NPC_ALT_MEDIC_SUPPERIOR_MAGE_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][0] && 0.0 == NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][1] && 0.0 == NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][0];
	tmp[1] = NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}


public Action NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, NPC_ALT_MEDIC_SUPPERIOR_MAGE_TBB_Tick);
		NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(client);
		npc.m_bInKame = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TicksActive[client] = tickCount;
	float diameter = float(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[client] * 2);
	int r = GetR(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[client]);
	int g = GetG(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[client]);
	int b = GetB(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ColorHex[client]);
	if (NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		NPC_ALT_MEDIC_SUPPERIOR_MAGE npc = view_as<NPC_ALT_MEDIC_SUPPERIOR_MAGE>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_MaxDistance[client]));
			float lineReduce = NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseDPT[client] + (NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_FarDPT[client]-NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_CloseDPT[client]) * (distance/NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_MaxDistance[client]);
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
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NPC_ALT_MEDIC_SUPPERIOR_MAGE_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}
public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage=10.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);	
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackCell(data, IOCDist); // Range
		WritePackCell(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(data);
	}
}

public Action NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIon(Handle Timer, any data)
{
	NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, 1.0, 1.0, 255);
	TE_SendToAll();
}

	public void NPC_ALT_MEDIC_SUPPERIOR_MAGE_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		int Ionrange = ReadPackCell(data);
		int Iondamage = ReadPackCell(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client))
		{
			return;
		}
		
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			// Stage 1
			float s=Sine(nphi/360*6.28)*Iondistance;
			float c=Cosine(nphi/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
			
			position[0] += s;
			position[1] += c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIonBeam(position, {212, 175, 55, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackCell(nData, Ionrange);
		WritePackCell(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, NPC_ALT_MEDIC_SUPPERIOR_MAGE_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		else
		{
			if(!b_Anger[client])
				makeexplosion(client, client, startPosition, "", RoundToCeil(75.0), 150);
				
			else if(b_Anger[client])
				makeexplosion(client, client, startPosition, "", RoundToCeil(150.0), 225);
				
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {212, 175, 55, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {212, 175, 55, 200}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {212, 175, 55, 120}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {212, 175, 55, 75}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
			// Blend
			//sendfademsg(0, 10, 200, FFADE_OUT, 255, 255, 255, 150);
			
			// Knockback
	/*		float vReturn[3];
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < Ionrange)
					{
						MakeVectorFromPoints(position, vClientPosition, vReturn);
						NormalizeVector(vReturn, vReturn);
						ScaleVector(vReturn, 10000.0 - dist*10);
	
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
					}
				}
			}
*/
		}
}