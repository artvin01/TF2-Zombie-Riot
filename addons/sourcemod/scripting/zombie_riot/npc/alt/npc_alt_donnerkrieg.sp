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

static const char g_IdleAlertedSounds[][] = {
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

static char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
//static j1
static bool bl_nightmare_stage1[MAXENTITIES];
static bool bl_nightmare_stage2[MAXENTITIES];
static bool bl_nightmare_stage3[MAXENTITIES];
static bool bl_nightmare_stage4[MAXENTITIES];
static bool bl_nightmare_reset[MAXENTITIES];

static float fl_nightmare_end_timer[MAXENTITIES];
static float fl_nightmare_offset_timer[MAXENTITIES];
static float fl_nightmare_intial_timer[MAXENTITIES];
static float fl_nightmare_reset_timer[MAXENTITIES];
static float fl_nightmare_anim_timer[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];


static bool NightmareCannon_BEAM_CanUse[MAXENTITIES];
static bool NightmareCannon_BEAM_IsUsing[MAXENTITIES];
static int NightmareCannon_BEAM_TicksActive[MAXENTITIES];
static int NightmareCannon_BEAM_Laser;
static int NightmareCannon_BEAM_Glow;
static float NightmareCannon_BEAM_CloseDPT[MAXENTITIES];
static float NightmareCannon_BEAM_FarDPT[MAXENTITIES];
static int NightmareCannon_BEAM_MaxDistance[MAXENTITIES];
static int NightmareCannon_BEAM_BeamRadius[MAXENTITIES];
static int NightmareCannon_BEAM_ColorHex[MAXENTITIES];
static int NightmareCannon_BEAM_ChargeUpTime[MAXENTITIES];
static float NightmareCannon_BEAM_CloseBuildingDPT[MAXENTITIES];
static float NightmareCannon_BEAM_FarBuildingDPT[MAXENTITIES];
static float NightmareCannon_BEAM_Duration[MAXENTITIES];
static float NightmareCannon_BEAM_BeamOffset[MAXENTITIES][3];
static float NightmareCannon_BEAM_ZOffset[MAXENTITIES];
static bool NightmareCannon_BEAM_HitDetected[MAXENTITIES];
static int NightmareCannon_BEAM_BuildingHit[MAXENTITIES];
static bool NightmareCannon_BEAM_UseWeapon[MAXENTITIES];


static bool b_InKame[MAXENTITIES];

void Donnerkrieg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	NightmareCannon_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	NightmareCannon_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
}

methodmap Donnerkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
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
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	
	public Donnerkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Donnerkrieg npc = view_as<Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));
		
		i_NpcInternalId[npc.index] = ALT_DONNERKRIEG;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Donnerkrieg_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Donnerkrieg_ClotThink);
			
		
		//IDLE
		npc.m_flSpeed = 300.0;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		bl_nightmare_stage1[npc.index]=false;
		bl_nightmare_stage2[npc.index]=false;
		bl_nightmare_stage3[npc.index]=false;
		bl_nightmare_stage4[npc.index]=false;
		
		fl_nightmare_end_timer[npc.index]= GetGameTime(npc.index) + 10.0;	//time from spawn for nightmare cannon trigger, can be configured with data
		fl_nightmare_offset_timer[npc.index]= GetGameTime(npc.index) + 5.0;	//offset used for animation.
		fl_nightmare_anim_timer[npc.index]= GetGameTime(npc.index) + 5.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{crimson}Donnerkrieg{default}: I have arrived to render judgement");
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Donnerkrieg_ClotThink(int iNPC)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	if(bl_nightmare_stage2[npc.index] && bl_nightmare_stage1[npc.index] && bl_nightmare_stage3[npc.index] && fl_nightmare_anim_timer[npc.index] <GetGameTime(npc.index))
	{
		npc.AddGesture("ACT_GRAPPLE_PULL_IDLE");
		fl_nightmare_anim_timer[npc.index]= GetGameTime(npc.index) + 2.0;
	}
	if(fl_nightmare_reset_timer[npc.index] < GetGameTime(npc.index) && !bl_nightmare_reset[npc.index])
	{
		bl_nightmare_stage1[npc.index]=false;
		bl_nightmare_stage2[npc.index]=false;
		bl_nightmare_stage3[npc.index]=false;
		bl_nightmare_stage4[npc.index]=false;
		bl_nightmare_reset[npc.index]=true;
		
		npc.m_flRangedArmor = 1.0;

		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		
	}
	if(!bl_nightmare_stage3[npc.index])
	{	
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(IsValidEnemy(npc.index, PrimaryThreatIndex))
		{
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
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
					
					PF_SetGoalVector(npc.index, vPredictedPos);
				} else {
					PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				if(bl_nightmare_stage2[npc.index] && bl_nightmare_stage1[npc.index] && !bl_nightmare_stage3[npc.index])
				{
					bl_nightmare_stage3[npc.index]=true;
					fl_nightmare_offset_timer[npc.index]= GetGameTime(npc.index) + 1.0;
					CPrintToChatAll("{crimson}Donnerkrieg: NIGHTMARE, CANNNON!");
					//CPrintToChatAll("stage 3");
					
					npc.m_flRangedArmor = 0.5;
					
					float flPos[3]; // original
					float flAng[3]; // original
					
					npc.GetAttachment("root", flPos, flAng);
					npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "utaunt_portalswirl_purple_parent", npc.index, "root", {0.0,0.0,0.0});
					npc.GetAttachment("root", flPos, flAng);
					npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_runeprison_yellow_parent", npc.index, "root", {0.0,0.0,0.0});
					
					npc.FaceTowards(vecTarget, 20000.0);	//TURN DAMMIT
					
					EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");

				}
				if(!bl_nightmare_stage1[npc.index])
				{
					
					if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && flDistanceToTarget > Pow(110.0, 2.0) && flDistanceToTarget < Pow(500.0, 2.0))
					{	

						npc.FaceTowards(vecTarget);
						float projectile_speed = 400.0;
						vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed);
						npc.FireParticleRocket(vecTarget, 12.5 , 400.0 , 100.0 , "raygun_projectile_blue");
						//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)

						npc.m_iAmountProjectiles += 1;
						npc.PlayRangedSound();
						npc.AddGesture("ACT_MP_THROW");
						npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15;
						if (npc.m_iAmountProjectiles >= 15.0)
						{
							npc.m_iAmountProjectiles = 0;
							npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 45.0;
						}
					}
					
					//Target close enough to hit
					if(flDistanceToTarget < 100000 || npc.m_flAttackHappenswillhappen)
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
								npc.PlayMeleeSound();
								npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
								npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
								npc.m_flAttackHappenswillhappen = true;
								npc.FaceTowards(vecTarget);
								Normal_Attack_BEAM_TBB_Ability(npc.index);
							}
							if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
							{
								npc.m_flAttackHappenswillhappen = false;
								npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
							}
						}
					}
					else
					{
					npc.StartPathing();
					}
				}
				else if(!bl_nightmare_stage2[npc.index])
				{
					npc.StartPathing();
					
					int Enemy_I_See;
				
					Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
					{
						float vBackoffPos[3];
						if(fl_nightmare_intial_timer[npc.index] < GetGameTime(npc.index))
						{
							bl_nightmare_stage2[npc.index]=true;
							//CPrintToChatAll("{crimson}Donnerkrieg:{default} Prepare thyself");
						}
						else
						{
							vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
						
							PF_SetGoalVector(npc.index, vBackoffPos);
						}
					}	
				}
				if(fl_nightmare_end_timer[npc.index] < GetGameTime(npc.index) && !bl_nightmare_stage1[npc.index])	//Initializer for the cannon
				{
					bl_nightmare_stage1[npc.index]=true;	//it begins
					fl_nightmare_offset_timer[npc.index]= GetGameTime(npc.index) + 10.0;
					CPrintToChatAll("{crimson}Donnerkrieg: Thats it {default}i'm going to kill you");
					//CPrintToChatAll("stage 1");
					//npc.FaceTowards(vecTarget);
					fl_nightmare_intial_timer[npc.index]= GetGameTime(npc.index) + 10.0;
					bl_nightmare_reset[npc.index]=false;
					fl_nightmare_reset_timer[npc.index] = GetGameTime(npc.index) + 100.0;
					
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
				}
		}
		else
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if(bl_nightmare_stage3[npc.index])
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		if(bl_nightmare_stage1[npc.index] && bl_nightmare_stage2[npc.index] && bl_nightmare_stage3[npc.index] && !bl_nightmare_stage4[npc.index] && fl_nightmare_offset_timer[npc.index] < GetGameTime(npc.index))
		{
			NightmareCannon_TBB_Ability(npc.index);
			bl_nightmare_stage4[npc.index]=true;
			//CPrintToChatAll("{crimson}Donnerkrieg: {default} JUDGEMENT");
			fl_nightmare_end_timer[npc.index]= GetGameTime(npc.index) + 90.0;	//1.5 minute cooldown.
			fl_nightmare_reset_timer[npc.index] = GetGameTime(npc.index) + 15.0;
			
			EmitSoundToAll("mvm/mvm_tank_ping.wav");
			
		}
	}
	else
	{
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}

public Action Donnerkrieg_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Donnerkrieg_NPCDeath(int entity)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Donnerkrieg_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))	//particles
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))	//temp particles
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))	//temp particles
		RemoveEntity(npc.m_iWearable6);
}
void Normal_Attack_BEAM_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NightmareCannon_BEAM_BuildingHit[building] = false;
	}
			
	NightmareCannon_BEAM_IsUsing[client] = false;
	NightmareCannon_BEAM_TicksActive[client] = 0;

	NightmareCannon_BEAM_CanUse[client] = true;
	NightmareCannon_BEAM_CloseDPT[client] = 120.0;
	NightmareCannon_BEAM_FarDPT[client] = 120.0;
	NightmareCannon_BEAM_MaxDistance[client] = 1000;
	NightmareCannon_BEAM_BeamRadius[client] = 10;
	NightmareCannon_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	NightmareCannon_BEAM_ChargeUpTime[client] = 12;
	NightmareCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_FarBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_Duration[client] = 0.25;
	
	NightmareCannon_BEAM_BeamOffset[client][0] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][1] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][2] = 0.0;

	NightmareCannon_BEAM_ZOffset[client] = 0.0;
	NightmareCannon_BEAM_UseWeapon[client] = false;

	NightmareCannon_BEAM_IsUsing[client] = true;
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);				
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}		
	}
			

	CreateTimer(NightmareCannon_BEAM_Duration[client], NightmareCannon_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
	
}
void NightmareCannon_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NightmareCannon_BEAM_BuildingHit[building] = false;
	}
	
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
			
	NightmareCannon_BEAM_IsUsing[client] = false;
	NightmareCannon_BEAM_TicksActive[client] = 0;

	NightmareCannon_BEAM_CanUse[client] = true;
	NightmareCannon_BEAM_CloseDPT[client] = 200.0;
	NightmareCannon_BEAM_FarDPT[client] = 200.0;
	NightmareCannon_BEAM_MaxDistance[client] = 10000;
	NightmareCannon_BEAM_BeamRadius[client] = 150;
	NightmareCannon_BEAM_ColorHex[client] = ParseColor("ff0303");
	NightmareCannon_BEAM_ChargeUpTime[client] = 150;
	NightmareCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_FarBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_Duration[client] = 15.0;
	
	NightmareCannon_BEAM_BeamOffset[client][0] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][1] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][2] = 0.0;

	NightmareCannon_BEAM_ZOffset[client] = 0.0;
	NightmareCannon_BEAM_UseWeapon[client] = false;

	NightmareCannon_BEAM_IsUsing[client] = true;
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
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
			

	CreateTimer(NightmareCannon_BEAM_Duration[client], NightmareCannon_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
	
}
public Action NightmareCannon_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	NightmareCannon_BEAM_IsUsing[client] = false;
	
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

public bool NightmareCannon_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_PLAYERS_ARRAY 36

public bool NightmareCannon_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		NightmareCannon_BEAM_HitDetected[entity] = true;
	}
	return false;
}
static void NightmareCannon_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	Donnerkrieg npc = view_as<Donnerkrieg>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == NightmareCannon_BEAM_BeamOffset[client][0] && 0.0 == NightmareCannon_BEAM_BeamOffset[client][1] && 0.0 == NightmareCannon_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = NightmareCannon_BEAM_BeamOffset[client][0];
	tmp[1] = NightmareCannon_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = NightmareCannon_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

#define MAXTF2PLAYERS	36

public Action NightmareCannon_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !NightmareCannon_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		npc.m_bInKame = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	NightmareCannon_BEAM_TicksActive[client] = tickCount;
	float diameter = float(NightmareCannon_BEAM_BeamRadius[client] * 4);
	int r = GetR(NightmareCannon_BEAM_ColorHex[client]);
	int g = GetG(NightmareCannon_BEAM_ColorHex[client]);
	int b = GetB(NightmareCannon_BEAM_ColorHex[client]);
	if (NightmareCannon_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, NightmareCannon_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(NightmareCannon_BEAM_MaxDistance[client]));
			float lineReduce = NightmareCannon_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				NightmareCannon_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(NightmareCannon_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, NightmareCannon_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (NightmareCannon_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = NightmareCannon_BEAM_CloseDPT[client] + (NightmareCannon_BEAM_FarDPT[client]-NightmareCannon_BEAM_CloseDPT[client]) * (distance/NightmareCannon_BEAM_MaxDistance[client]);
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
			NightmareCannon_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}