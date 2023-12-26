#pragma semicolon 1
#pragma newdecls required

//static const char g_DeathSounds[][] = {
//	"vo/medic_paincrticialdeath01.mp3",
//	"vo/medic_paincrticialdeath02.mp3",
//	"vo/medic_paincrticialdeath03.mp3",
//};

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
//Mainly huge thanks to spookmaster and artvin to even allow me to do this thank you david helping me with the moonlight and thank you batfox for showcasing how to do a proper way of spawnring (addiction.sp)

//#define OVERDOSE_ACTIVATE				"vo/medic_sf13_spell_earthquake01.mp3"
#define OVERDOSE_ACTIVATE				"freak_fortress_2/bvb_kapdok_duo/doktor/fatal_overdose_activated.mp3"
//#define OVERDOSE_TELEPORT				"misc/halloween/spell_teleport.wav"
#define OVERDOSE_TELEPORT				"freak_fortress_2/bvb_kapdok_duo/doktor/fatal_overdose_teleport.mp3"
#define OVERDOSE_EXPLOSION				"misc/halloween/spell_mirv_explode_primary.wav"
#define OVERDOSE_HIT					"freak_fortress_2/bvb_kapdok_duo/doktor/fatal_overdose_explosion.mp3"
//#define OVERDOSE_HIT					"vo/taunts/medic/medic_taunt_kill_22.mp3"
#define OVERDOSE_MISS					"vo/medic_negativevocalization04.mp3"
#define DOKMED_BACKSTABBED				"vo/medic_paincrticialdeath01.mp3"
#define DOKMED_BACKSTABBED_2			"vo/medic_sf12_scared02.mp3"
#define DOKMED_THEME					"freak_fortress_2/bvb_kapdok_duo/shared/bgm1_1.mp3"//Map Only just to reduce file size of the map itself
#define DOKMED_THEME2					"freak_fortress_2/bvb_kapdok_duo/shared/bgm2_2.mp3"
#define DOKMED_THEME3					"freak_fortress_2/bvb_kapdok_duo/shared/bgm3_3.mp3"
#define DOKMED_THEME4					"freak_fortress_2/bvb_kapdok_duo/shared/bgm4_4.mp3"
#define DOKMED_INTRO					"freak_fortress_2/bvb_kapdok_duo/shared/kapdok_intro2.mp3"
#define DOKMED_INTRO2					"freak_fortress_2/bvb_kapdok_duo/shared/kapdok_intro3.mp3"
//#define DOKMED_THEME					"freak_fortress_2/bvb_kapdok_duo/shared/bgm1.mp3"//if they somehow are allowed to be on any map use this!!
//#define DOKMED_THEME2					"freak_fortress_2/bvb_kapdok_duo/shared/bgm2.mp3"
//#define DOKMED_THEME3					"freak_fortress_2/bvb_kapdok_duo/shared/bgm3.mp3"
//#define DOKMED_THEME4					"freak_fortress_2/bvb_kapdok_duo/shared/bgm4.mp3"
#define DOKMED_CHEMICAL_WARFARE			"freak_fortress_2/bvb_kapdok_duo/doktor/chemical_warfare.mp3"
#define DOKMED_SPEEDBALL				"freak_fortress_2/bvb_kapdok_duo/doktor/speedball.mp3"
#define DOKMED_KETARIODS				"freak_fortress_2/bvb_kapdok_duo/doktor/ketaroids.mp3"
#define DOKMED_COCAIN_OVERDOSE			"freak_fortress_2/bvb_kapdok_duo/doktor/shadow_clones_activate.mp3"
#define DOKMED_DEATH					"freak_fortress_2/bvb_kapdok_duo/doktor/doc_death.mp3"

#define MOONLIGHT_SPRITE	  			"materials/sprites/laserbeam.vmt"
#define MOONLIGHT_ACTIVATE	  			"freak_fortress_2/bvb_kapdok_duo/doktor/moonlight_activate.mp3"
#define MOONLIGHT_ATTACK	  			"freak_fortress_2/bvb_kapdok_duo/doktor/moonlight_attack.mp3"
int MoonLight_Beam;

void Doktor_Medick_OnMapStart_NPC()
{
	//for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheSound(OVERDOSE_ACTIVATE, true);
	PrecacheSound(OVERDOSE_TELEPORT, true);
	PrecacheSound(OVERDOSE_HIT, true);
	PrecacheSound(OVERDOSE_EXPLOSION, true);
	PrecacheSound(OVERDOSE_MISS, true);
	PrecacheSound(DOKMED_BACKSTABBED, true);
	PrecacheSound(DOKMED_BACKSTABBED_2, true);
	PrecacheSound(DOKMED_THEME, true);
	PrecacheSound(DOKMED_THEME2, true);
	PrecacheSound(DOKMED_THEME3, true);
	PrecacheSound(DOKMED_THEME4, true);
	PrecacheSound(DOKMED_INTRO, true);
	PrecacheSound(DOKMED_INTRO2, true);
	PrecacheSound(DOKMED_CHEMICAL_WARFARE, true);
	PrecacheSound(DOKMED_SPEEDBALL, true);
	PrecacheSound(DOKMED_KETARIODS, true);
	PrecacheSound(DOKMED_COCAIN_OVERDOSE, true);
	PrecacheSound(DOKMED_DEATH, true);
	MoonLight_Beam = PrecacheModel(MOONLIGHT_SPRITE);
	PrecacheModel("models/zombie_riot/doktormedick_ascended.mdl", true);
	PrecacheModel("models/weapons/w_models/w_syringe_proj.mdl", true);
}

//static float Overdose_TeleDistance = 200000.0;
//static float Overdose_VictimDMG = 6000.0;
//static float Overdose_BlastRadius = 800.0;
//static float Overdose_BlastDMG = 4000.0;
static float f_OverDose_Usage[MAXENTITIES];
static bool b_OverDose_Animation[MAXENTITIES] = {false, ...};
static bool b_OverDose_Activate[MAXENTITIES] = {false, ...};
static bool b_Overdose_TeleportUsage[MAXENTITIES] = {false, ...};
static bool b_TempOpener[MAXENTITIES] = {false, ...};
static bool b_OverDoseActive[MAXENTITIES] = {false, ...};

static float Overdose_Smite_BaseDMG = 225.0;//Base damage of the explosion
static float Overdose_Smite_Radius = 650.0;//Radius of the effect and explosion
static float Overdose_Smite_ChargeTime = 0.99;//name says it
static float Overdose_Smite_ChargeSpan = 0.44;//name says it
static float Overdose_Timer = 1.4; //How long it takes to teleport
static float Overdose_Reuseable = 13.4; //How long it should be reuseable again

static float f_BackToMeleeAnimation[MAXENTITIES];
static bool b_BackToMeleeAnimation[MAXENTITIES] = {false, ...};

static bool b_AbilityManagement[MAXENTITIES] = {false, ...};
static float f_AbilityManagement_Timer[MAXENTITIES];

static bool b_KetamineUsage[MAXENTITIES] = {false, ...};
static float f_KetamineTimer[MAXENTITIES];

static bool b_SteroidsUsage[MAXENTITIES] = {false, ...};
static float f_SteroidsTimer[MAXENTITIES];

static bool b_Chemical_Warfare[MAXENTITIES] = {false, ...};
static float f_Chemical_Warfare_Timer[MAXENTITIES];

static float f_KetamineSteroidsCombo[MAXENTITIES];
static bool b_KetamineSteroidsCombo[MAXENTITIES] = {false, ...};

static float DokMed_MaxSpeed = 340.0;//Main Speed
static float f_AbilityManagement_TimerReuseability = 13.0;//How long it should be reuseable again

static float KetamineSteroids_Timer = 6.5;//how long it should stay
static float KetamineWearoff = 6.5;//how long it should stay
static float SteroidsWearoff = 6.5;//how long it should stay
static float f_Chemical_Warfare_Wearoff = 5.0;//how long it should stay

static float SteroidsDamage = 600.0;//Melee Damage for players 
static float SteroidsBuildingNpcDamage = 19950.0;//Melee Damage for npc's and building
static float DefaultDamage = 350.0;//Melee Damage for players
static float DefaultBuildingNpcDamage = 15500.0;//Melee Damage for npc's and building
static float Chemical_Warfare_Damage = 190.0;//Chemical Damage for players
//static float BackstabExplosionDamage = 120.0;//Explosion Damage for players
//static float BackstabNpcBuildingExplosionDamage = 320.0;//Explosion Damage for npc's and building

//Todo rework this moonlight some day
static float AmountOfTickCount[MAXENTITIES];
static float MoonLightDamage_throttle[MAXENTITIES];
static bool Moonlight_ActualUseability[MAXENTITIES] = {false, ...};
static float Moonlight_ActualUseability_Timer[MAXENTITIES];
static bool MoonLight[MAXENTITIES] = {false, ...};
static bool MoonLight_used[MAXENTITIES] = {false, ...};
static bool MoonLight_stop[MAXENTITIES] = {false, ...};
static float MoonLight_Timer[MAXENTITIES];
static float MoonLight_Throttle[MAXENTITIES];
static float MoonLight_Duration[MAXENTITIES];
//static float MoonLight_RemainingDuration[MAXENTITIES];
static float MoonLight_ChargeTime[MAXENTITIES];
static float MoonLight_RemainingChargeTime[MAXENTITIES];
static float MoonLight_Scale1[MAXENTITIES] = {200.0, ...};//Moonlight scale damage
static float MoonLight_Scale2[MAXENTITIES] = {400.0, ...};//Moonlight scale damage
static float MoonLight_Scale3[MAXENTITIES] = {600.0, ...};//Moonlight scale damage
static float MoonLight_Scale2_timer[MAXENTITIES];
static float MoonLight_Scale3_timer[MAXENTITIES];
static float MoonLight_DMG[MAXENTITIES];
static float MoonLight_DMG_Base[MAXENTITIES] = {55.0, ...};//Moonlight damage
static float MoonLight_DMG_Radius[MAXENTITIES];
static float MoonLight_Radius[MAXENTITIES] = {125.0, ...};//Moonlight radius
static float MoonLight_Angle[MAXENTITIES];

bool DokMedHasDied;
bool KapheavyHasDied;

methodmap Doktor_Medick < CClotBody
{
	property float MoonLight_Scale1
	{
		public get()							{ return MoonLight_Scale1[this.index]; }
		public set(float TempValueForProperty) 	{ MoonLight_Scale1[this.index] = TempValueForProperty; }
	}
	property float MoonLight_Scale2
	{
		public get()							{ return MoonLight_Scale2[this.index]; }
		public set(float TempValueForProperty) 	{ MoonLight_Scale2[this.index] = TempValueForProperty; }
	}
	property float MoonLight_Scale3
	{
		public get()							{ return MoonLight_Scale3[this.index]; }
		public set(float TempValueForProperty) 	{ MoonLight_Scale3[this.index] = TempValueForProperty; }
	}
	property bool b_OverDose_Animation
	{
		public get()							{ return b_OverDose_Animation[this.index]; }
		public set(bool TempValueForProperty) 	{ b_OverDose_Animation[this.index] = TempValueForProperty; }
	}
	property bool b_OverDose_Activate
	{
		public get()							{ return b_OverDose_Activate[this.index]; }
		public set(bool TempValueForProperty) 	{ b_OverDose_Activate[this.index] = TempValueForProperty; }
	}
	property bool b_Overdose_TeleportUsage
	{
		public get()							{ return b_Overdose_TeleportUsage[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Overdose_TeleportUsage[this.index] = TempValueForProperty; }
	}
	property bool b_TempOpener
	{
		public get()							{ return b_TempOpener[this.index]; }
		public set(bool TempValueForProperty) 	{ b_TempOpener[this.index] = TempValueForProperty; }
	}
	property bool b_OverDoseActive
	{
		public get()							{ return b_OverDoseActive[this.index]; }
		public set(bool TempValueForProperty) 	{ b_OverDoseActive[this.index] = TempValueForProperty; }
	}
	property bool b_BackToMeleeAnimation
	{
		public get()							{ return b_BackToMeleeAnimation[this.index]; }
		public set(bool TempValueForProperty) 	{ b_BackToMeleeAnimation[this.index] = TempValueForProperty; }
	}
	property bool b_AbilityManagement
	{
		public get()							{ return b_AbilityManagement[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AbilityManagement[this.index] = TempValueForProperty; }
	}
	property bool b_KetamineUsage
	{
		public get()							{ return b_KetamineUsage[this.index]; }
		public set(bool TempValueForProperty) 	{ b_KetamineUsage[this.index] = TempValueForProperty; }
	}
	property bool b_SteroidsUsage
	{
		public get()							{ return b_SteroidsUsage[this.index]; }
		public set(bool TempValueForProperty) 	{ b_SteroidsUsage[this.index] = TempValueForProperty; }
	}
	property bool b_Chemical_Warfare
	{
		public get()							{ return b_Chemical_Warfare[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Chemical_Warfare[this.index] = TempValueForProperty; }
	}
	property bool b_KetamineSteroidsCombo
	{
		public get()							{ return b_KetamineSteroidsCombo[this.index]; }
		public set(bool TempValueForProperty) 	{ b_KetamineSteroidsCombo[this.index] = TempValueForProperty; }
	}
	property bool Moonlight_ActualUseability
	{
		public get()							{ return Moonlight_ActualUseability[this.index]; }
		public set(bool TempValueForProperty) 	{ Moonlight_ActualUseability[this.index] = TempValueForProperty; }
	}
	property bool MoonLight
	{
		public get()							{ return MoonLight[this.index]; }
		public set(bool TempValueForProperty) 	{ MoonLight[this.index] = TempValueForProperty; }
	}
	property bool MoonLight_used
	{
		public get()							{ return MoonLight_used[this.index]; }
		public set(bool TempValueForProperty) 	{ MoonLight_used[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	//public void PlayDeathSound() {
	//
	//	EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	//	
	//	#if defined DEBUG_SOUND
	//	PrintToServer("CClot::PlayDeathSound()");
	//	#endif
	//}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public Doktor_Medick(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Doktor_Medick npc = view_as<Doktor_Medick>(CClotBody(vecPos, vecAng, "models/zombie_riot/doktormedick_ascended.mdl", "1.0", "550000", ally));
		
		i_NpcInternalId[npc.index] = DOKTOR_MEDICK;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bThisNpcIsABoss = true;
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					//LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "DokMed Spawn Message");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 320.0;
			GiveNpcOutLineLastOrBoss(npc.index, true);
		}
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		//SDKHook(npc.index, SDKHook_OnTakeDamagePost, Doktor_Medick_ClotDamaged_Post);
		SDKHook(npc.index, SDKHook_Think, Doktor_Medick_ClotThink);
		
		Moonlight_ActualUseability_Timer[npc.index] = GetGameTime(npc.index) + 300.0;//300s = 5 min you took too long
		f_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + 15.0;
		f_OverDose_Usage[npc.index] = GetGameTime(npc.index) + 10.0;
		f_KetamineTimer[npc.index] = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 0.0;
		DokMedHasDied = false;
		//IDLE
		npc.m_flSpeed = DokMed_MaxSpeed;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		
		if(b_IsAlliedNpc[npc.index])//Idk this will mainly only work on this map (unless you allow downloads)
		{
			int skin = 0;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		}
		else
		{
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
			
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
			
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		}
		npc.StartPathing();
		
		return npc;
	}
}

public void Doktor_Medick_ClotThink(int iNPC)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(iNPC);
	
	if(!b_IsAlliedNpc[npc.index])
	{
		if(RaidModeTime < GetGameTime())
		{
			SDKUnhook(npc.index, SDKHook_Think, MoonLight_TBB_Tick);
			MoonLight[npc.index] = false;
			MoonLight_stop[npc.index] = false;
			Moonlight_ActualUseability[npc.index] = false;
			MoonLight_used[npc.index] = false;
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, Doktor_Medick_ClotThink);
			if(!KapheavyHasDied)
			{
				SDKUnhook(npc.index, SDKHook_Think, Eternal_Kaptain_Heavy_ClotThink);
			}
		}
		//Todo rework this moonlight some day
		if(Moonlight_ActualUseability_Timer[npc.index] <= GetGameTime(npc.index) && !Moonlight_ActualUseability[npc.index])
		{
			SDKHook(npc.index, SDKHook_Think, MoonLight_TBB_Tick);
			MoonLight_Invoke(npc.index, npc.m_iTarget, 20.0, 6.0);	//final invoke
			MoonLight[npc.index] = true;
			Moonlight_ActualUseability[npc.index] = true;
			MoonLight_used[npc.index] = true;
			MoonLight_Timer[npc.index] = GetGameTime(npc.index) + 10.0;
			Moonlight_ActualUseability_Timer[npc.index] = GetGameTime(npc.index) + 4.0;
			EmitSoundToAll(MOONLIGHT_ACTIVATE, _, _, 140);
		}
		if(Moonlight_ActualUseability_Timer[npc.index] <= GetGameTime(npc.index) && Moonlight_ActualUseability[npc.index])
		{
			Moonlight_ActualUseability[npc.index] = false;
			Moonlight_ActualUseability_Timer[npc.index] = GetGameTime(npc.index) + 20.0;
			EmitSoundToAll(MOONLIGHT_ATTACK, _, _, 140);
		}
	}
	
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(f_OverDose_Usage[npc.index] <= GetGameTime(npc.index) && !b_OverDoseActive[npc.index] && !b_TempOpener[npc.index] && !MoonLight_used[npc.index])
	{
		b_OverDose_Animation[npc.index] = true;
		npc.m_flSpeed = 0.0;
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		f_OverDose_Usage[npc.index] = GetGameTime(npc.index) + Overdose_Timer;
		b_TempOpener[npc.index] = true;
		//npc.AddGesture("FATAL_OVERDOSE")
		if(b_IsAlliedNpc[npc.index])
		{
			//EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		}
		else
		{
			//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		}
		//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		Overdose_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, Overdose_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
		Overdose_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, Overdose_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
		//npc.AddGesture("FATAL_OVERDOSE");
		int iActivity = npc.LookupActivity("FATAL_OVERDOSE");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	if(f_OverDose_Usage[npc.index] <= GetGameTime(npc.index) && !b_OverDoseActive[npc.index] && b_TempOpener[npc.index])
	{
		//f_OverDose_Usage[npc.index] = GetGameTime(npc.index) + Overdose_Reuseable;
		if(!b_Chemical_Warfare[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		else//If he somehow used this still just another safty
		{
			int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
			if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		}
		b_Overdose_TeleportUsage[npc.index] = true;
		b_OverDoseActive[npc.index] = true;
		b_OverDose_Animation[npc.index] = false;
		b_TempOpener[npc.index] = false;
	}
	if(f_AbilityManagement_Timer[npc.index] <= GetGameTime(npc.index) && !b_AbilityManagement[npc.index] && !b_KetamineUsage[npc.index] && !b_SteroidsUsage[npc.index] &&!b_OverDoseActive[npc.index] && !b_Overdose_TeleportUsage[npc.index] && !b_OverDose_Animation[npc.index] && !MoonLight_used[npc.index])
	{
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		switch(GetRandomInt(1,4))
		{
			case 1:
			{
				//b_AbilityManagement[npc.index] = true;
				b_KetamineUsage[npc.index] = true;
				f_KetamineTimer[npc.index] = GetGameTime(npc.index) + KetamineWearoff;
				if(b_IsAlliedNpc[npc.index])
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_SPEEDBALL, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_SPEEDBALL, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
			}
			case 2:
			{
				//b_AbilityManagement[npc.index] = true;
				b_SteroidsUsage[npc.index] = true;
				f_SteroidsTimer[npc.index] = GetGameTime(npc.index) + SteroidsWearoff;
				if(b_IsAlliedNpc[npc.index])
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_KETARIODS, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_KETARIODS, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
			}
			case 3:
			{
				//b_AbilityManagement[npc.index] = true;
				b_KetamineSteroidsCombo[npc.index] = true;
				f_KetamineSteroidsCombo[npc.index] = GetGameTime(npc.index) + KetamineSteroids_Timer;
				if(b_IsAlliedNpc[npc.index])
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_COCAIN_OVERDOSE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_COCAIN_OVERDOSE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
			}
			case 4:
			{
				b_Chemical_Warfare[npc.index] = true;
				f_Chemical_Warfare_Timer[npc.index] = GetGameTime(npc.index) + f_Chemical_Warfare_Wearoff;
				b_BackToMeleeAnimation[npc.index] = true;
				f_BackToMeleeAnimation[npc.index] = GetGameTime(npc.index) + f_Chemical_Warfare_Wearoff;
				if(b_IsAlliedNpc[npc.index])
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_CHEMICAL_WARFARE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					//EmitSoundToAll(OVERDOSE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(DOKMED_CHEMICAL_WARFARE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
			}
		}
		b_AbilityManagement[npc.index] = true;
		//f_AbilityManagement_Timer[npc.index] = 5.0;
	}
	if(b_KetamineUsage[npc.index] && f_KetamineTimer[npc.index] <= GetGameTime(npc.index) && b_AbilityManagement[npc.index] && !b_SteroidsUsage[npc.index])
	{//ketamine
		b_KetamineUsage[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		//f_KetamineTimer[npc.index] = 5.0;
		f_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + f_AbilityManagement_TimerReuseability;
	}
	if(b_SteroidsUsage[npc.index] && f_SteroidsTimer[npc.index] <= GetGameTime(npc.index) && b_AbilityManagement[npc.index] && !b_KetamineUsage[npc.index])
	{//Steroids
		b_SteroidsUsage[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		//f_KetamineTimer[npc.index] = 5.0;
		f_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + f_AbilityManagement_TimerReuseability;
	}
	if(b_KetamineSteroidsCombo[npc.index] && f_KetamineSteroidsCombo[npc.index] <= GetGameTime(npc.index) && b_AbilityManagement[npc.index] && !b_SteroidsUsage[npc.index] && !b_KetamineUsage[npc.index])
	{//ketamineSteroids
		b_KetamineSteroidsCombo[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		f_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + f_AbilityManagement_TimerReuseability;
		//f_KetamineSteroidsCombo[npc.index] = GetGameTime(npc.index) + 999.0;
	}
	if(b_Chemical_Warfare[npc.index] && f_Chemical_Warfare_Timer[npc.index] <= GetGameTime(npc.index) && b_AbilityManagement[npc.index] && !b_SteroidsUsage[npc.index] && !b_KetamineUsage[npc.index])
	{//ketamineSteroids
		b_Chemical_Warfare[npc.index] = false;
		//f_Chemical_Warfare_Timer[npc.index] = GetGameTime(npc.index) + f_Chemical_Warfare_Wearoff;
		b_AbilityManagement[npc.index] = false;
		f_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + f_AbilityManagement_TimerReuseability;
	}
	if(f_BackToMeleeAnimation[npc.index] <= GetGameTime(npc.index) && b_BackToMeleeAnimation[npc.index])
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{
			npc.m_iChanged_WalkCycle = 2;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			AcceptEntityInput(npc.m_iWearable2, "Disable");
		}
		b_BackToMeleeAnimation[npc.index] = false;
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
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
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		float vOrigin[3];
		float vEnd[3];
		vOrigin = GetAbsOrigin(npc.m_iTarget);
		vEnd = GetAbsOrigin(npc.m_iTarget);
		//if(b_OverDoseActive[npc.index] && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
		if(b_OverDoseActive[npc.index])
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex, 0.3);
			static float flVel[3];
			f_OverDose_Usage[npc.index] = GetGameTime(npc.index) + Overdose_Reuseable;
			
			if(b_Overdose_TeleportUsage[npc.index])
			{
				int color[4];
				color[0] = 0;
				color[1] = 255;
				color[2] = 120;
				color[3] = 255;
		
				int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
				int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
				
				float pos[3], angles[3];
				GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_angRotation", angles);
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		
				TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT, 0, 0, 0, 0.8, 14.0, 10.2, 1, 1.0, color, 0);
				TE_SendToAll();
				TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
				TE_SendToAll();
				TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
				GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
				if(Tele_Check < 100000000 || Tele_Check < 10000000 || Tele_Check < 1000000 || Tele_Check < 100000 || Tele_Check < 10000 || Tele_Check > 100000000 || Tele_Check > 10000000 || Tele_Check > 1000000 || Tele_Check > 100000 || Tele_Check > 10000)
				{
					EmitSoundToAll(OVERDOSE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					EmitSoundToAll(OVERDOSE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
					TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
					b_OverDose_Activate[npc.index] = true;
					b_Overdose_TeleportUsage[npc.index] = false;
					npc.m_flSpeed = DokMed_MaxSpeed;
				}
			}
			
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See && b_OverDose_Activate[npc.index] && !b_Overdose_TeleportUsage[npc.index])
			{
				//float vAngles[3];
				//float vOrigin[3];
				//float vEnd[3];
				//vAngles = GetAbsOrigin(npc.m_iTarget);
				//vOrigin = GetAbsOrigin(npc.m_iTarget);
				//vEnd = GetAbsOrigin(npc.m_iTarget);
			
				Handle pack;
				CreateDataTimer(Overdose_Smite_ChargeSpan, Overdose_Smite_Timer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(pack, EntRefToEntIndex(npc.index));
				WritePackFloat(pack, 0.0);
				WritePackFloat(pack, vEnd[0]);
				WritePackFloat(pack, vEnd[1]);
				WritePackFloat(pack, vEnd[2]);
				WritePackFloat(pack, Overdose_Smite_BaseDMG);
			
				Overdose_spawnBeam(0.8, 255, 255, 0, 120, "materials/sprites/lgtning.vmt", 8.0, 8.2, _, 5.0, vOrigin, vEnd);
				//Overdose_spawnBeam(320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, Overdose_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
				Overdose_spawnRing_Vectors(vEnd, Overdose_Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 200, 1, Overdose_Smite_ChargeTime, 6.0, 0.1, 1, 1.0);
				
				//npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 9.0;
				b_OverDoseActive[npc.index] = false;
			}
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 142500 && npc.m_flReloadDelay < GetGameTime(npc.index) && b_Chemical_Warfare[npc.index])
		{
			if(npc.m_iChanged_WalkCycle != 1)
			{
				npc.m_iChanged_WalkCycle = 1;
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
			}
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.4;
				npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
					npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					npc.m_iAttacksTillReload = 5;
					//npc.PlayRangedReloadSound();
					//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
				}
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				npc.FireArrow(vecTarget, Chemical_Warfare_Damage, 1400.0, "models/weapons/w_models/w_syringe_proj.mdl", 1.5);
				
				//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
				//npc.PlayRangedSound();
			}
		}
		if(flDistanceToTarget > 142500 || flDistanceToTarget < 142500)
		{
			npc.StartPathing();
		}
		//Target close enough to hit
		if(flDistanceToTarget < 10000 && !b_Chemical_Warfare[npc.index] || npc.m_flAttackHappenswillhappen && !b_Chemical_Warfare[npc.index])
		{
		//	Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					if(b_KetamineUsage[npc.index] || b_KetamineSteroidsCombo[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.1;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.24;
						npc.m_flAttackHappenswillhappen = true;
						//CPrintToChatAll("Ketamine");
					}
					else
					{
						//CPrintToChatAll("NonKetamine");
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}		
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
							if(target <= MaxClients)
							{
								if(b_SteroidsUsage[npc.index] || b_KetamineSteroidsCombo[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, SteroidsDamage, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultDamage, DMG_CLUB, -1, _, vecHit);
								}
							}
							else
							{
								if(b_SteroidsUsage[npc.index] || b_KetamineSteroidsCombo[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, SteroidsBuildingNpcDamage, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, DefaultBuildingNpcDamage, DMG_CLUB, -1, _, vecHit);
								}
							}
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					if(b_KetamineUsage[npc.index] || b_KetamineSteroidsCombo[npc.index])
					{
						//CPrintToChatAll("Ketamine");
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						npc.m_flAttackHappenswillhappen = false;
					}
					else
					{
						//CPrintToChatAll("NonKetamine");
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.56;
						npc.m_flAttackHappenswillhappen = false;
					}
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(b_KetamineUsage[npc.index] || b_KetamineSteroidsCombo[npc.index])
					{
						//CPrintToChatAll("Ketamine");
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
					}
					else
					{
						//CPrintToChatAll("NonKetamine");
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.56;
					}
					//npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
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

public Action Doktor_Medick_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

/*//Need to do a better way detecting this again... NPC shit out error's when attacking him
public void Doktor_Medick_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	//if(attacker <= 0)
		//return;
	
	Doktor_Medick npc = view_as<Doktor_Medick>(iNPC);
	for(int i = 1; i <= MaxClients; i++)
	{
		int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
		char classname[32];
		GetEntityClassname(weapon, classname, sizeof(classname));
		if(IsValidClient(i))
		{
			if(!StrContains(classname, "tf_weapon_knife", false))//Don't use this for any other npc i legit did this only for pablo cspy and dokmed
			{
				if(damagetype & DMG_CLUB) //Use dmg slash for any npc that shouldnt be scaled.
				{
					if(IsBehindAndFacingTarget(attacker, iNPC))
					{
						//int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
						int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
						if(melee != 4 && melee != 1003)
						{
							int	entity = iNPC;
							int closest = attacker;
							if(IsValidEntity(entity) && entity>MaxClients)
							{
								if(closest > 0) 
								{
									if(closest <= MaxClients)
										//SDKHooks_TakeDamage(closest, npc.index, npc.index, 90.0 , DMG_CLUB, -1, _);
										SDKHooks_TakeDamage(closest, npc.index, npc.index, BackstabExplosionDamage, DMG_CLUB, -1, _);
									else
										//SDKHooks_TakeDamage(closest, npc.index, npc.index, 130.0, DMG_CLUB, -1, _);
										SDKHooks_TakeDamage(closest, npc.index, npc.index, BackstabNpcBuildingExplosionDamage, DMG_CLUB, -1, _);
									float pos[3];
									GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
									makeexplosion(-1, -1, pos, "", 0, 150);
									//npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
								}
							}
							switch(GetRandomInt(1, 2))
							{
								case 1:
								{
									EmitSoundToAll(DOKMED_BACKSTABBED, attacker, _, _, _, 1.0);
								}
								case 2:
								{
									EmitSoundToAll(DOKMED_BACKSTABBED_2, attacker, _, _, _, 1.0);
								}
							}
						}
					}
				}
			}
		}
	}
}*/

public void Doktor_Medick_NPCDeath(int entity)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(entity);
	/*if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}*/
	float vEnd[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
	
	if(b_IsAlliedNpc[npc.index])//I'm sorry but i like this method more
	{
		//EmitSoundToAll(DOKMED_DEATH, _, _, _, _, 1.0)
		EmitSoundToAll(DOKMED_DEATH, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
	}
	else
	{
		DokMedHasDied = true;
		RaidBossActive = INVALID_ENT_REFERENCE;
		//EmitSoundToAll(DOKMED_DEATH, _, _, _, _, 1.0)
		EmitSoundToAll(DOKMED_DEATH, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, MoonLight_TBB_Tick);
	//SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Doktor_Medick_ClotDamaged_Post);
	SDKUnhook(npc.index, SDKHook_Think, Doktor_Medick_ClotThink);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

public Action Overdose_Smite_Timer(Handle Smite_Logic, DataPack pack)
{
	//int iNPC;
	//Doktor_Medick npc = view_as<Doktor_Medick>(iNPC);
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if(NumLoops >= Overdose_Smite_ChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			Overdose_spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.33, 6.0, 0.4, 1, (Overdose_Smite_Radius * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		//secondLoc[2] = 9999.0;
		secondLoc[2] = 1500.0;
		
		Overdose_spawnBeam(0.8, 255, 255, 120, 255, "materials/sprites/laserbeam.vmt", 16.0, 16.2, _, 5.0, secondLoc, spawnLoc);	
		Overdose_spawnBeam(0.8, 255, 255, 120, 200, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);	
		Overdose_spawnBeam(0.8, 255, 255, 120, 200, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);
		
		EmitAmbientSound(OVERDOSE_HIT, spawnLoc, _, 120);
		EmitAmbientSound(OVERDOSE_HIT, spawnLoc, _, 120);
		
		//int target = TR_GetEntityIndex(npc.m_iTarget);	
		//if(target > 0) 
		//{
		//	if(target <= MaxClients)
		//	{
		//		EmitAmbientSound(OVERDOSE_HIT, spawnLoc, _, 120);
		//		EmitAmbientSound(OVERDOSE_HIT, spawnLoc, _, 120);
		//	}
		//} 
		//else
		//{
		//	EmitAmbientSound(OVERDOSE_MISS, spawnLoc, _, 120);
		//	EmitAmbientSound(OVERDOSE_MISS, spawnLoc, _, 120);
		//}
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, Overdose_Smite_Radius * 1.4, _, 0.8, true);
		//Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, Overdose_Smite_Radius * 1.4, _, 0.8, true, EP_NO_KNOCKBACK);
		
		return Plugin_Stop;
	}
	else
	{
		Overdose_spawnRing_Vectors(spawnLoc, Overdose_Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
		EmitAmbientSound(OVERDOSE_EXPLOSION, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		EmitAmbientSound(OVERDOSE_EXPLOSION, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + Overdose_Smite_ChargeSpan);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void Overdose_spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
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

static void Overdose_spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if(endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}

//Todo rework this moonlight some day
public Action MoonLight_TBB_Tick(int client)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(client);
	if(MoonLight_Throttle[npc.index] < GetGameTime(npc.index))
	{
		MoonLight_Throttle[npc.index]=GetGameTime(npc.index) + 0.04;
		if(!IsValidEntity(client) || MoonLight_stop[npc.index])
		{
			AmountOfTickCount[npc.index] = 0.0;
			SDKUnhook(npc.index, SDKHook_Think, MoonLight_TBB_Tick);
			MoonLight[npc.index] = false;
			MoonLight_stop[npc.index] = false;
			Moonlight_ActualUseability[npc.index] = false;
			MoonLight_used[npc.index] = false;
		}
		
		MoonLight_DMG[npc.index]=MoonLight_DMG_Base[npc.index]*(1.0+(AmountOfTickCount[npc.index]/MoonLight_Duration[npc.index]));
		MoonLight_DMG_Radius[npc.index]=MoonLight_Radius[npc.index]*(1.0+(AmountOfTickCount[npc.index]/MoonLight_Duration[npc.index])*2.5);
		int entity = EntRefToEntIndex(npc.index);
		if(IsValidEntity(entity))
		{
			if(MoonLight_Timer[npc.index] > GetGameTime(npc.index) + MoonLight_ChargeTime[npc.index])
			{
				MoonLight_Beams(entity, true);
			}
			else if(MoonLight_Timer[npc.index] < GetGameTime(npc.index) + MoonLight_ChargeTime[npc.index])
			{
				MoonLight_Beams(entity, false);
			}
		}
	}
	AmountOfTickCount[npc.index]++;
	
	return Plugin_Continue;
}

public void MoonLight_Invoke(int ref, int enemy, float timer, float charge)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(ref);
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float vecTarget[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		MoonLight_Duration[npc.index] = timer;
		MoonLight_ChargeTime[npc.index] = charge;
		//Doesn't need to be for dokmed
		//MoonLight_Scale1[npc.index] = 200.0;
		//MoonLight_Scale2[npc.index] = 400.0;
		//MoonLight_Scale3[npc.index] = 600.0;
		//MoonLight_DMG_Base[npc.index] = 40.0;	//dmg is multiplied by duration, half duration is 1.5, near end of duration its almost 2x. it also does dmg 2 times a second.
		//MoonLight_Radius[npc.index] = 200.0;
		timer+=charge;

		float time=MoonLight_Duration[npc.index]+charge;
		MoonLight_Duration[npc.index]*=66.0;
		//MoonLight_RemainingDuration[npc.index] = 0.0;
		
		MoonLight_Scale2_timer[npc.index]=GetGameTime(npc.index)+(timer/3)+charge;	//makes it so the 3 beam rings spawn in 3 seperate times.
		MoonLight_Scale3_timer[npc.index]=GetGameTime(npc.index)+((timer/3)*2)+charge;
		
		MoonLight_RemainingChargeTime[npc.index] = MoonLight_ChargeTime[npc.index];
		EmitSoundToAll(MOONLIGHT_ACTIVATE);
		
		CreateTimer(time, MoonLight_TBB_Timer, ref, TIMER_FLAG_NO_MAPCHANGE);
		SDKHook(ref, SDKHook_Think, MoonLight_TBB_Tick);
	}
	
}

public Action MoonLight_TBB_Timer(Handle timer, int client)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(client);
	if(!IsValidEntity(client))
		return Plugin_Continue;

	MoonLight_stop[npc.index] = true;
	Moonlight_ActualUseability_Timer[npc.index] = GetGameTime(npc.index) + 30.0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

void MoonLight_Beams(int entity, bool charging = true)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(entity);
	if(!IsValidEntity(entity) || !MoonLight[npc.index])
		return;
	
	float UserLoc[3], UserAng[3];
	UserLoc = GetAbsOrigin(entity);
	
	UserAng[0] = 0.0;
	UserAng[1] = MoonLight_Angle[npc.index];
	UserAng[2] = 0.0;
	
	if(charging)
	{
		MoonLight_Angle[npc.index] += 2.5;
	}
	else
	{
		MoonLight_Angle[npc.index] += 1.25;
	}
	
	if(MoonLight_Angle[npc.index] >= 360.0)
	{
		MoonLight_Angle[npc.index] = 0.0;
	}
	
	for(int i = 0; i < 3; i++)
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:
			{
				distance = MoonLight_Scale1[npc.index];
			}
			case 1:
			{
				if(MoonLight_Scale2_timer[npc.index]<GetGameTime(npc.index))
				{
					distance = MoonLight_Scale2[npc.index];
					angMult = -1.0;
				}
			}
			case 2:
			{
				if(MoonLight_Scale3_timer[npc.index]<GetGameTime(npc.index))
				{
					distance = MoonLight_Scale3[npc.index];
					angMult = 1.0;
				}
			}
		}
		
		for(int j = 0; j < 8; j++)
		{
			float tempAngles[3], endLoc[3], Direction[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = angMult * (UserAng[1] + (float(j) * 45.0));
			tempAngles[2] = 0.0;
			
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			if (charging)
			{
				MoonLight_Spawn8(endLoc, MoonLight_Radius[npc.index], entity);
			}
			else
			{
				MoonLight_SpawnBeam(entity, false, endLoc);
			}
		}
	}
}

public void MoonLight_Spawn8(float startLoc[3], float space, int entity)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(entity);
	float ticks = (AmountOfTickCount[npc.index] / MoonLight_Duration[npc.index]);
	for (int i = 0; i < 8; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(i) * 45.0;
		tempAngles[2] = 0.0;
		
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, space);
		AddVectors(startLoc, Direction, endLoc);
		MoonLight_SpawnBeam(entity, true, endLoc, ticks);
	}
	int color[4];
	color[0] = 0;
	color[1] = 180;
	color[2] = 60;
	color[3] = RoundFloat(255.0 * ticks);
	
	TE_SetupBeamRingPoint(startLoc, space * 2.0, space * 2.0, MoonLight_Beam, MoonLight_Beam, 0, 1, 0.1, 2.0, 0.1, color, 1, 0);
	TE_SendToAll();
}

void MoonLight_SpawnBeam(int entity, bool charging, float beamLoc[3], float alphaMod = 1.0)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(entity);
	int color[4];
	color[3] = RoundFloat(255.0 * alphaMod);
	
	float skyLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
	
	if(charging)
	{
		color[1] = 180;
		color[2] = 60;
		
		TE_SetupBeamPoints(skyLoc, beamLoc, MoonLight_Beam, MoonLight_Beam, 0, 1, 0.1, 2.0, 2.1, 1, 0.1, color, 1);
		TE_SendToAll();
	}
	else
	{
		if(!IsValidEntity(entity))
			return;
		
		color[1] = 255;
		color[2] = 135;
		
		TE_SetupBeamPoints(skyLoc, beamLoc, MoonLight_Beam, MoonLight_Beam, 0, 1, 0.1, 10.0, 10.1, 1, 0.1, color, 1);
		TE_SendToAll();
		TE_SetupBeamRingPoint(beamLoc, 0.0, MoonLight_Radius[npc.index] * 2.0, MoonLight_Beam, MoonLight_Beam, 0, 1, 0.33, 2.0, 0.1, color, 1, 0);
		TE_SendToAll();
		
		MoonLight_DealDamage(npc.index);
	}
}

public void MoonLight_DealDamage(int entity)
{
	Doktor_Medick npc = view_as<Doktor_Medick>(entity);
	if(!IsValidEntity(entity))
		return;
	
	if(MoonLightDamage_throttle[npc.index] < GetGameTime(npc.index))
	{
		float beamLoc[3];
		beamLoc = GetAbsOrigin(entity);
		MoonLightDamage_throttle[npc.index] = GetGameTime(npc.index) + 0.5;	//funny throttle due to me being dumb and not knowing to how do damage any other way.
		Explode_Logic_Custom(MoonLight_DMG[npc.index], entity, entity, -1, beamLoc, MoonLight_DMG_Radius[npc.index] , _, _, true);
		//CPrintToChatAll("Damage: %.1f%", MoonLight_DMG[npc.index]);
		//CPrintToChatAll("radius: %.0f%", MoonLight_DMG_Radius[npc.index]);
	}
}