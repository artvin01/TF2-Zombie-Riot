#pragma semicolon 1
#pragma newdecls required

//static const char g_DeathSounds[][] = {
//	"vo/heavy_paincrticialdeath01.mp3",
//	"vo/heavy_paincrticialdeath02.mp3",
//	"vo/heavy_paincrticialdeath03.mp3",
//};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/heavy_jeers03.mp3",	
	"vo/heavy_jeers04.mp3",	
	"vo/heavy_jeers06.mp3",
	"vo/heavy_jeers09.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

#define GIANTSTEP_INTRO				"freak_fortress_2/bvb_kapdok_duo/kaptain/steps_activate.mp3"
#define SOVIETPRIDE					"freak_fortress_2/bvb_kapdok_duo/kaptain/pride.mp3"
#define UNTOUCHABLETERROR			"freak_fortress_2/bvb_kapdok_duo/kaptain/reflect.mp3"
#define NMCANNONINTRO				"freak_fortress_2/bvb_kapdok_duo/kaptain/nightmare_intro.mp3"
#define NMCANNONPHASE1				"freak_fortress_2/bvb_kapdok_duo/kaptain/nightmare_phase1.mp3"
#define NMCANNONPHASE2				"freak_fortress_2/bvb_kapdok_duo/kaptain/nightmare_phase2.mp3"
#define NMCANNONTRANSITION			"freak_fortress_2/bvb_kapdok_duo/kaptain/nightmare_transition.mp3"
#define KAPTAINDEATH				"freak_fortress_2/bvb_kapdok_duo/kaptain/kaptain_death.mp3"
#define KAPTAINDEATH2				"freak_fortress_2/bvb_kapdok_duo/kaptain/kaptain_death2.mp3"
#define GIANTSTEPEXPLOSION1			"weapons/airstrike_small_explosion_03.wav"
#define GIANTSTEPEXPLOSION2			"weapons/airstrike_small_explosion_02.wav"
#define GIANTSTEPEXPLOSION3			"weapons/airstrike_small_explosion_03.wav"

void Eternal_Kaptain_Heavy_OnMapStart_NPC()
{
	//for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/zombie_riot/bvb_kaptainheavy.mdl");
	PrecacheSound(GIANTSTEP_INTRO, true);
	PrecacheSound(SOVIETPRIDE, true);
	PrecacheSound(UNTOUCHABLETERROR, true);
	PrecacheSound(NMCANNONINTRO, true);
	PrecacheSound(NMCANNONPHASE1, true);
	PrecacheSound(NMCANNONPHASE2, true);
	PrecacheSound(NMCANNONTRANSITION, true);
	PrecacheSound(KAPTAINDEATH, true);
	PrecacheSound(KAPTAINDEATH2, true);
	PrecacheSound(GIANTSTEPEXPLOSION1, true);
	PrecacheSound(GIANTSTEPEXPLOSION2, true);
	PrecacheSound(GIANTSTEPEXPLOSION3, true);
}

static float GiantSteps_Usage[MAXENTITIES];
static float GiantSteps_Repeater[MAXENTITIES];
static bool GiantSteps_RepeaterOn[MAXENTITIES] = {false, ...};
static bool GiantSteps_On[MAXENTITIES] = {false, ...};
static bool TempOpener3[MAXENTITIES] = {false, ...};

static float Kaptain_MaxSpeed = 330.0;
static float Kaptain_SovietSpeed = 370.0;

static float GiantSteps_FirstUsageTimer = 15.0;
static float GiantSteps_ReUsageTimer = 20.0;
static float GiantSteps_UsageTimer = 10.0;
static float GiantSteps_RepeaterTimer = 0.4;
static float Giantsteps_Smite_ChargeTime = 0.39;
static float Giantsteps_Radius = 380.0;
static float Giantsteps_Damage = 280.0;

static float KaptainDefaultDamage = 300.0;
static float KaptainSovietDamage = 450.0;
static float KaptainDefaultNpcBuildingDamage = 1300.0;
static float KaptainSovietNpcBuildingDamage = 1950.0;

static bool KapAbilityManagement[MAXENTITIES] = {false, ...};
static float KapAbilityManagement_Timer[MAXENTITIES];
static float KapAbilityManagementFirstTimer = 10.0;
static float KapAbilityManagementReuseTimer = 15.0;

static float SovietPride_Usage[MAXENTITIES];
static bool SovietPride_On[MAXENTITIES] = {false, ...};
//static float SovietPride_UsageTimer = 1.0;
static float SovietPride_Wearoff = 5.0;

static float UntouchableTerror_Usage[MAXENTITIES];
static bool UntouchableTerror_On[MAXENTITIES] = {false, ...};
//static float UntouchableTerror_UsageTimer = 1.0;
static float UntouchableTerror_Wearoff = 5.0;

methodmap Eternal_Kaptain_Heavy < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
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
	
	public Eternal_Kaptain_Heavy(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Eternal_Kaptain_Heavy npc = view_as<Eternal_Kaptain_Heavy>(CClotBody(vecPos, vecAng, "models/zombie_riot/bvb_kaptainheavy.mdl", "1.0", "550000", ally));
		
		i_NpcInternalId[npc.index] = KAPTAIN_HEAVY;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		npc.m_bThisNpcIsABoss = true;
		KapheavyHasDied = false;
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 320.0;
			GiveNpcOutLineLastOrBoss(npc.index, true);
		}
		
		GiantSteps_Usage[npc.index] = GetGameTime(npc.index) + GiantSteps_FirstUsageTimer;
		GiantSteps_Repeater[npc.index] = GetGameTime(npc.index) + GiantSteps_RepeaterTimer;
		KapAbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + KapAbilityManagementFirstTimer;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, Eternal_Kaptain_Heavy_ClotThink);		

		npc.m_flSpeed = Kaptain_MaxSpeed;
		//IDLE
		npc.m_iState = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		if(b_IsAlliedNpc[npc.index])
		{
			int skin = 0;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		}
		else
		{
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		}
		
		//npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/heavy/heavy_zombie.mdl");
		//SetVariantString("1.0");
		//AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		return npc;
	}
}

//TODO 
//Rewrite
public void Eternal_Kaptain_Heavy_ClotThink(int iNPC)
{
	Eternal_Kaptain_Heavy npc = view_as<Eternal_Kaptain_Heavy>(iNPC);
	if(!b_IsAlliedNpc[npc.index])
	{
		if(DokMedHasDied)
		{
			if(RaidModeTime < GetGameTime())
			{
				int entity = CreateEntityByName("game_round_win"); //You loose.
				DispatchKeyValue(entity, "force_map_reset", "1");
				SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
				DispatchSpawn(entity);
				AcceptEntityInput(entity, "RoundWin");
				Music_RoundEnd(entity);
				RaidBossActive = INVALID_ENT_REFERENCE;
				SDKUnhook(npc.index, SDKHook_Think, Eternal_Kaptain_Heavy_ClotThink);
			}
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
	if(GiantSteps_Usage[npc.index] <= GetGameTime(npc.index) && !GiantSteps_On[npc.index] && !TempOpener3[npc.index] && !GiantSteps_RepeaterOn[npc.index])
	{
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		GiantSteps_Usage[npc.index] = GetGameTime(npc.index) + GiantSteps_UsageTimer;
		GiantSteps_Repeater[npc.index] = GetGameTime(npc.index) + GiantSteps_RepeaterTimer;
		GiantSteps_On[npc.index] = true;
		GiantSteps_RepeaterOn[npc.index] = true;
		TempOpener3[npc.index] = true;
		if(b_IsAlliedNpc[npc.index])
		{
			EmitSoundToAll(GIANTSTEP_INTRO, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		}
		else
		{
			EmitSoundToAll(GIANTSTEP_INTRO, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		}
	}
	if(GiantSteps_Repeater[npc.index] <= GetGameTime(npc.index) && GiantSteps_On[npc.index] && TempOpener3[npc.index] && GiantSteps_RepeaterOn[npc.index])
	{
		GiantSteps_Repeater[npc.index] = GetGameTime(npc.index) + GiantSteps_RepeaterTimer;
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		Giantsteps_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, Giantsteps_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
		Giantsteps_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, Giantsteps_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
		int entity = EntRefToEntIndex(iNPC);
		//if(IsValidEntity(entity) && entity>MaxClients)//Hard focus on one guy and infinite range on it too so don't use it
		//{
		//	if(npc.m_iTarget > 0) 
		//	{
		//		if(npc.m_iTarget <= MaxClients)
		//			SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 150.0, DMG_CLUB, -1, _);
		//		else
		//			SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, 350.0, DMG_CLUB, -1, _);
		//		float pos[3];
		//		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		//		makeexplosion(-1, -1, pos, "", 0, 250);
		//		npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		//	} 
		//}
		float pos[3];
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll(GIANTSTEPEXPLOSION1, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
			case 2:
			{
				EmitSoundToAll(GIANTSTEPEXPLOSION2, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
			case 3:
			{
				EmitSoundToAll(GIANTSTEPEXPLOSION3, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
		}
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		//makeexplosion(0, npc.index, pos, "", 20000, 250, 0.0);
		//for(int i = 1; i <= MaxClients; i++)
		//{
		//	if(IsValidClient(i))
		//	{
		//		Custom_Knockback(npc.index, i, 0.0);
		//	}
		//}
		Explode_Logic_Custom(Giantsteps_Damage, entity, entity, -1, pos, Giantsteps_Radius, _, 0.8, true);
		//Explode_Logic_Custom(Giantsteps_Damage, entity, entity, -1, pos, Giantsteps_Radius, _, 0.0, true, EP_NO_KNOCKBACK)
		//npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
	}
	if(GiantSteps_Usage[npc.index] <= GetGameTime(npc.index) && GiantSteps_On[npc.index] && TempOpener3[npc.index] && GiantSteps_RepeaterOn[npc.index])
	{
		GiantSteps_Usage[npc.index] = GetGameTime(npc.index) + GiantSteps_ReUsageTimer;
		GiantSteps_On[npc.index] = false;
		GiantSteps_RepeaterOn[npc.index] = false;
		TempOpener3[npc.index] = false;
	}
	if(KapAbilityManagement_Timer[npc.index] <= GetGameTime(npc.index) && !KapAbilityManagement[npc.index] && !SovietPride_On[npc.index] && !UntouchableTerror_On[npc.index])
	{
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				if(b_IsAlliedNpc[npc.index])
				{
					EmitSoundToAll(SOVIETPRIDE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					EmitSoundToAll(SOVIETPRIDE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				SovietPride_Usage[npc.index] = GetGameTime(npc.index) + SovietPride_Wearoff;
				SovietPride_On[npc.index] = true;
				npc.m_flSpeed = Kaptain_SovietSpeed;
				npc.m_flMeleeArmor = 0.90;
				npc.m_flRangedArmor = 0.90;
			}
			case 2:
			{
				if(b_IsAlliedNpc[npc.index])
				{
					EmitSoundToAll(UNTOUCHABLETERROR, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				else
				{
					EmitSoundToAll(UNTOUCHABLETERROR, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
				}
				UntouchableTerror_Usage[npc.index] = GetGameTime(npc.index) + UntouchableTerror_Wearoff;
				UntouchableTerror_On[npc.index] = true;
				npc.m_flMeleeArmor = 0.00;
				npc.m_flRangedArmor = 0.00;
			}
			//case 3:
			//{
			//	
			//}
		}
		KapAbilityManagement[npc.index] = true;
	}
	if(SovietPride_Usage[npc.index] <= GetGameTime(npc.index) && KapAbilityManagement[npc.index] && SovietPride_On[npc.index] && !UntouchableTerror_On[npc.index])
	{
		SovietPride_On[npc.index] = false;
		KapAbilityManagement[npc.index] = false;
		KapAbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + KapAbilityManagementReuseTimer;
		npc.m_flSpeed = Kaptain_MaxSpeed;
		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
	}
	if(UntouchableTerror_Usage[npc.index] <= GetGameTime(npc.index) && KapAbilityManagement[npc.index] && !SovietPride_On[npc.index] && UntouchableTerror_On[npc.index])
	{
		KapAbilityManagement[npc.index] = false;
		UntouchableTerror_On[npc.index] = false;
		npc.m_flMeleeArmor = 1.00;
		npc.m_flRangedArmor = 1.00;
		KapAbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + KapAbilityManagementReuseTimer;
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
		//Target close enough to hit
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
					npc.PlayMeleeSound();
					if(SovietPride_On[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.44;
					}
					else
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					}
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
							
							if(target <= MaxClients)
							{
								if(SovietPride_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, KaptainSovietDamage, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, KaptainDefaultDamage, DMG_CLUB, -1, _, vecHit);
								}
							}
							else
							{
								if(SovietPride_On[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, KaptainSovietNpcBuildingDamage, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, KaptainDefaultNpcBuildingDamage, DMG_CLUB, -1, _, vecHit);
								}
							}
							// Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					if(SovietPride_On[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					if(SovietPride_On[npc.index])
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
					}
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

public Action Eternal_Kaptain_Heavy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Eternal_Kaptain_Heavy npc = view_as<Eternal_Kaptain_Heavy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Eternal_Kaptain_Heavy_NPCDeath(int entity)
{
	Eternal_Kaptain_Heavy npc = view_as<Eternal_Kaptain_Heavy>(entity);
	/*if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}*/
	float vEnd[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
	
	if(b_IsAlliedNpc[npc.index])//I'm sorry but i like this method more
	{
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				EmitSoundToAll(KAPTAINDEATH, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
			case 2:
			{
				EmitSoundToAll(KAPTAINDEATH2, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
		}
	}
	else
	{
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				EmitSoundToAll(KAPTAINDEATH, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
			case 2:
			{
				EmitSoundToAll(KAPTAINDEATH2, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
			}
		}
		KapheavyHasDied = true;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, Eternal_Kaptain_Heavy_ClotThink);	
	//if(IsValidEntity(npc.m_iWearable1))
		//RemoveEntity(npc.m_iWearable1);
}
/*
static void Giantsteps_spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
	
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}*/

static void Giantsteps_spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}