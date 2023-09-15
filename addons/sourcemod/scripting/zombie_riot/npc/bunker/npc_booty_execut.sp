#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/pootis_engage/be_ded2.mp3"
};

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

static const char g_ExeHeavyHo[][] = {
	"#freak_fortress_2/pootis_engage/be_heavy_dance1.mp3",
};

static const char g_SandvichUse[][] = {
	"freak_fortress_2/pootis_engage/ss_steak.mp3",
};

static const char g_BootyNuke[][] = {
	"freak_fortress_2/pootis_engage/be_rage_nuke.mp3",
};

static const char g_BootyExplode[][] = {
	"freak_fortress_2/pootis_engage/be_explode.mp3",
};

static const char g_BootyPunch[][] = {
	"vo/heavy_jeers02.mp3",
};

static const char g_BootyLaser[][] = {
	"vo/heavy_specialcompleted06.mp3",
};

//gets shared with the partner
public const char g_DuoPootisMainTheme[][] = {
	"#freak_fortress_2/pootis_engage/bgm1.mp3",
};

public const char g_DuoPootisDeathTheme[][] = {
	"#freak_fortress_2/pootis_engage/death_bgm1.mp3",
};

public const char g_DuoCritHitPootis[][] = {
	"freak_fortress_2/pootis_engage/crit1.mp3",
	"freak_fortress_2/pootis_engage/crit2.mp3",
	"freak_fortress_2/pootis_engage/crit3.mp3",
};

//idk if this needs to be in zr_core
//bool DefaultPootisTheme = false;
bool b_DuoOnePootisDied = false;
bool b_DuoDisableMainPootisTheme = false;
bool b_DuoMainLeaderDied = false;
bool b_DuoSandSlayerDied = false;
bool b_DuoOneTimeStopForExe = false;
float fl_DuoExecuteCustomPootisTheme = 0.0;

static bool b_Sandvich[MAXENTITIES];
static float fl_Sandvich_Timer[MAXENTITIES] = {0.0, ...};
static int i_MaxSandvichUse[MAXENTITIES];

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_AbilityManagement_Timer[MAXENTITIES];
static float fl_AbilityManagement_FirstTimer = 10.0;
static float fl_AbilityManagement_SecondTimer = 15.0;

static float fl_HeavyHo_Speed = 375.0;
static float fl_MainSpeed = 300.0;

static bool b_AbilityManagement[MAXENTITIES] = {false, ...};
static float fl_AbilityHeavyHo_Timer[MAXENTITIES];
static float fl_HeavyHo_EndTimer = 9.0;
static bool b_HeavyHo[MAXENTITIES] = {false, ...};

static bool b_Serious_Punch[MAXENTITIES] = {false, ...};
static float fl_Serious_Punch_Timer[MAXENTITIES] = {0.0, ...};
static float fl_Serious_Punch_Wearoff = 5.0;
static int i_Serious_Punch_Hit[MAXENTITIES] = {0, ...};

static int i_Crit_Hit[MAXENTITIES] = {0, ...};
static int i_Crit_HitAmount = 6;

//static bool b_AbilityHeavyLaser[MAXENTITIES] = {false, ...};
//static float fl_AbilityHeavyLaser_Timer[MAXENTITIES] = {0.0, ...};
//static float fl_Heavylaser_Damage = 32.0;

static float fl_MainDamage = 175.0;
static float fl_MainBuildNpcDamage = 3750.0;
static float fl_HeavyHoDamageMult = 1.6;
static float fl_CritDamageMult = 3.0;

static bool b_BootyExplosion[MAXENTITIES];
static float fl_BootyExplosion_Timer[MAXENTITIES];
static float fl_BootyExplosion_Damage = 400.0;
static float fl_BootyExplosion_Radius = 350.0;

static bool b_BootyNuke[MAXENTITIES] = {false, ...};
static bool b_BootyNukeUsed[MAXENTITIES] = {false, ...};
static float fl_BootyNuke_Timer[MAXENTITIES];

static bool b_ExeLaser[MAXENTITIES];
static bool BootyExecutioner_BEAM_CanUse[MAXENTITIES];
static bool BootyExecutioner_BEAM_IsUsing[MAXENTITIES];
static int BootyExecutioner_BEAM_TicksActive[MAXENTITIES];
static int BootyExecutioner_BEAM_Laser;
static int BootyExecutioner_BEAM_Glow;
static float BootyExecutioner_BEAM_CloseDPT[MAXENTITIES];
static float BootyExecutioner_BEAM_FarDPT[MAXENTITIES];
static int BootyExecutioner_BEAM_MaxDistance[MAXENTITIES];
static int BootyExecutioner_BEAM_BeamRadius[MAXENTITIES];
static int BootyExecutioner_BEAM_ColorHex[MAXENTITIES];
static int BootyExecutioner_BEAM_ChargeUpTime[MAXENTITIES];
static float BootyExecutioner_BEAM_CloseBuildingDPT[MAXENTITIES];
static float BootyExecutioner_BEAM_FarBuildingDPT[MAXENTITIES];
static float BootyExecutioner_BEAM_Duration[MAXENTITIES];
static float BootyExecutioner_BEAM_BeamOffset[MAXENTITIES][3];
static float BootyExecutioner_BEAM_ZOffset[MAXENTITIES];
static bool BootyExecutioner_BEAM_HitDetected[MAXENTITIES];
static int BootyExecutioner_BEAM_BuildingHit[MAXENTITIES];

#define POOTISTHEME "#freak_fortress_2/pootis_engage/bgm1.mp3"
#define POOTISOUTROMUSIC "freak_fortress_2/pootis_engage/outromusic_lose.mp3"

void BootyExecutioner_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_ExeHeavyHo));   i++) { PrecacheSound(g_ExeHeavyHo[i]);   }
	for (int i = 0; i < (sizeof(g_SandvichUse));   i++) { PrecacheSound(g_SandvichUse[i]);   }
	for (int i = 0; i < (sizeof(g_BootyNuke));   i++) { PrecacheSound(g_BootyNuke[i]);   }
	for (int i = 0; i < (sizeof(g_BootyExplode));   i++) { PrecacheSound(g_BootyExplode[i]);   }
	for (int i = 0; i < (sizeof(g_BootyPunch));   i++) { PrecacheSound(g_BootyPunch[i]);   }
	for (int i = 0; i < (sizeof(g_BootyLaser));   i++) { PrecacheSound(g_BootyLaser[i]);   }
	for (int i = 0; i < (sizeof(g_DuoPootisMainTheme));   i++) { PrecacheSound(g_DuoPootisMainTheme[i]);   }
	for (int i = 0; i < (sizeof(g_DuoPootisDeathTheme));   i++) { PrecacheSound(g_DuoPootisDeathTheme[i]);   }
	for (int i = 0; i < (sizeof(g_DuoCritHitPootis));   i++) { PrecacheSound(g_DuoCritHitPootis[i]);   }
	PrecacheSound(POOTISOUTROMUSIC, true);
	PrecacheModel("materials/sprites/laserbeam.vmt", true);
	PrecacheModel("materials/sprites/sprite_fire01.vmt");
	BootyExecutioner_TBB_Precache();
}

void BootyExecutioner_TBB_Precache()
{
	BootyExecutioner_BEAM_Glow = PrecacheModel("sprites/glow2.vmt", true);
	BootyExecutioner_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
}

methodmap BootyExecutioner < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], _, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayPootisMainTheme() {
		EmitSoundToAll(g_DuoPootisMainTheme[GetRandomInt(0, sizeof(g_DuoPootisMainTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_DuoPootisMainTheme[GetRandomInt(0, sizeof(g_DuoPootisMainTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, NORMAL_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisMainTheme()");
		#endif
	}
	public void PlayPootisDeathTheme() {
		EmitSoundToAll(g_DuoPootisDeathTheme[GetRandomInt(0, sizeof(g_DuoPootisDeathTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_DuoPootisDeathTheme[GetRandomInt(0, sizeof(g_DuoPootisDeathTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, NORMAL_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisDeathTheme()");
		#endif
	}
	public void PlayHeavyHoSound() {
		EmitSoundToAll(g_ExeHeavyHo[GetRandomInt(0, sizeof(g_ExeHeavyHo) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHeavyHoSound()");
		#endif
	}
	public void PlaySandvichSound() {
		EmitSoundToAll(g_SandvichUse[GetRandomInt(0, sizeof(g_SandvichUse) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlaySandvichSound()");
		#endif
	}
	public void PlayBootyNukeSound() {
		EmitSoundToAll(g_BootyNuke[GetRandomInt(0, sizeof(g_BootyNuke) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayBootyNukeSound()");
		#endif
	}
	public void PlayBootyExplodeSound() {
		EmitSoundToAll(g_BootyExplode[GetRandomInt(0, sizeof(g_BootyExplode) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayBootyNukeSound()");
		#endif
	}
	public void PlayBootyPunchSound() {
		EmitSoundToAll(g_BootyPunch[GetRandomInt(0, sizeof(g_BootyPunch) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayBootyNukeSound()");
		#endif
	}
	public void PlayBootyLaser() {
		EmitSoundToAll(g_BootyLaser[GetRandomInt(0, sizeof(g_BootyLaser) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayBootyNukeSound()");
		#endif
	}
	public void PlayCritSoundEffect() {
		EmitSoundToAll(g_DuoCritHitPootis[GetRandomInt(0, sizeof(g_DuoCritHitPootis) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	
	public BootyExecutioner(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BootyExecutioner npc = view_as<BootyExecutioner>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.25", "15000", ally, false, true));
		
		i_NpcInternalId[npc.index] = BOOTY_EXECUTIONIER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_bThisNpcIsABoss = true;
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			Music_Stop_Beat_Ten(client);
			RaidModeTime = GetGameTime(npc.index) + 250.0;
			//this is only if they somehow magically respawned
			b_DuoOnePootisDied = false;
			b_DuoDisableMainPootisTheme = false;
			b_DuoMainLeaderDied = false;
			GiveNpcOutLineLastOrBoss(npc.index, true);
			//b_DuoSandSlayerDied = false;
			for(int client_clear=1; client_clear<=MaxClients; client_clear++)
			{
				fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
			}
		}
		
		SDKHook(npc.index, SDKHook_Think, BootyExecutioner_ClotThink);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		fl_Sandvich_Timer[npc.index] = GetGameTime(npc.index) + 150.0;
		fl_BootyNuke_Timer[npc.index] = GetGameTime(npc.index) + 210.0;
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_FirstTimer;
		b_AbilityManagement[npc.index] = false;
		b_HeavyHo[npc.index] = true;
		b_ExeLaser[npc.index] = false;
		b_BootyExplosion[npc.index] = false;
		b_Sandvich[npc.index] = false;
		b_BootyNuke[npc.index] = false;
		b_BootyNukeUsed[npc.index] = false;
		i_Serious_Punch_Hit[npc.index] = 0;
		i_Crit_Hit[npc.index] = 0;
		i_MaxSandvichUse[npc.index] = 0;
		
		//IDLE
		npc.m_flSpeed = fl_MainSpeed;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		//npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/jul13_sweet_shades_s1/jul13_sweet_shades_s1_heavy.mdl");
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/heavy/cop_glasses.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		Citizen_MiniBossSpawn();
		
		return npc;
	}
}

public void BootyExecutioner_ClotThink(int iNPC)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(!b_IsAlliedNpc[npc.index])
	{
		if(fl_DuoExecuteCustomPootisTheme <= GetGameTime(npc.index) && !b_DuoOnePootisDied && !b_DuoDisableMainPootisTheme && !b_DuoMainLeaderDied && !b_DuoSandSlayerDied)
		{
			fl_DuoExecuteCustomPootisTheme = GetGameTime(npc.index) + 140.0;
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Pascal Michael Stiefel {default}- {orange}Killing Two Birds");//idk though it's fancy showing it
			npc.PlayPootisMainTheme();
		}
		if(fl_DuoExecuteCustomPootisTheme <= GetGameTime(npc.index) && b_DuoOnePootisDied && b_DuoDisableMainPootisTheme && b_DuoSandSlayerDied)
		{
			fl_DuoExecuteCustomPootisTheme = GetGameTime(npc.index) + 262.0;
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Ruoska {default}- {orange}Kesä Tulla Saa");
			npc.PlayPootisDeathTheme();
		}
		if(b_DuoSandSlayerDied && !b_DuoOneTimeStopForExe)
		{
			Music_Stop_Main_Theme(iNPC);
			b_DuoOneTimeStopForExe = true;
		}
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client);
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		if(RaidModeTime < GetGameTime())
		{
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, BootyExecutioner_ClotThink);
		}
	}
	if(fl_AbilityManagement_Timer[npc.index] <= GetGameTime(npc.index) && !b_AbilityManagement[npc.index] && !b_HeavyHo[npc.index]
	&& !b_BootyExplosion[npc.index] && !b_ExeLaser[npc.index] && !b_Serious_Punch[npc.index] && !b_BootyNuke[npc.index])
	{
		switch(GetRandomInt(1,4))
		{
			case 1:
			{
				//b_AbilityManagement[npc.index] = true;
				b_HeavyHo[npc.index] = true;
				npc.PlayHeavyHoSound();
				//fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				fl_AbilityHeavyHo_Timer[npc.index] = GetGameTime(npc.index) + fl_HeavyHo_EndTimer;
				npc.m_flSpeed = fl_HeavyHo_Speed;
			}
			case 2:
			{
				b_ExeLaser[npc.index] = true;
				npc.PlayBootyLaser();
				//fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				BootyExecutioner_TBB_Ability(npc.index);
			}
			case 3:
			{
				b_Serious_Punch[npc.index] = true;
				npc.PlayBootyPunchSound();
				//fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				fl_Serious_Punch_Timer[npc.index] = GetGameTime(npc.index) + fl_Serious_Punch_Wearoff;
			}
			case 4:
			{
				float vEnd[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
				fl_BootyExplosion_Timer[npc.index] = GetGameTime(npc.index) + 1.5;
				b_BootyExplosion[npc.index] = true;
				//fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				npc.m_flSpeed = 0.0;
				Shitting_spawnRing_Vectors(vEnd, fl_BootyExplosion_Radius, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 1.2, 4.0, 0.1, 1, 1.0);
				Shitting_spawnRing_Vectors(vEnd, fl_BootyExplosion_Radius, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 1.2, 4.0, 0.1, 1, 1.0);
				npc.PlayBootyExplodeSound();
				
				//has a chance to crash on death i rather not use slowmo then on this specific ability
				/*for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i) && !IsFakeClient(i))
					{
						SendConVarValue(i, sv_cheats, "1");
					}
				}
				cvarTimeScale.SetFloat(0.3);
				CreateTimer(0.5, SetTimeBack);*/
			}
		}
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
		b_AbilityManagement[npc.index] = true;
	}
	if(fl_AbilityHeavyHo_Timer[npc.index] <= GetGameTime(npc.index) && b_HeavyHo[npc.index])
	{
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
		b_AbilityManagement[npc.index] = false;
		b_HeavyHo[npc.index] = false;
		npc.m_flSpeed = fl_MainSpeed;
	}
	if(fl_Serious_Punch_Timer[npc.index] <= GetGameTime(npc.index) && b_Serious_Punch[npc.index] || i_Serious_Punch_Hit[npc.index] == 1)
	{
		b_AbilityManagement[npc.index] = false;
		b_Serious_Punch[npc.index] = false;
		i_Serious_Punch_Hit[npc.index] = 0;
	}
	if(i_Crit_Hit[npc.index] == i_Crit_HitAmount + 1)
	{
		i_Crit_Hit[npc.index] = 0;
	}
	if(!b_Sandvich[npc.index] && fl_Sandvich_Timer[npc.index] <= GetGameTime(npc.index) && i_MaxSandvichUse[npc.index] == 0)
	{
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		b_Sandvich[npc.index] = true;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 2);
		//CPrintToChatAll("SANDVICH AMK"); //IGNORE I JUST WANTED TO SEE IF IT WORKS
		i_MaxSandvichUse[npc.index]++;
		npc.PlaySandvichSound();
	}
	if(fl_BootyExplosion_Timer[npc.index] <= GetGameTime(npc.index) && b_BootyExplosion[npc.index])
	{
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		b_AbilityManagement[npc.index] = false;
		b_BootyExplosion[npc.index] = false;
		npc.m_flSpeed = fl_MainSpeed;
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Explode_Logic_Custom(fl_BootyExplosion_Damage, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, fl_BootyExplosion_Radius, _, 0.8, true);
	}
	if(fl_BootyNuke_Timer[npc.index] <= GetGameTime(npc.index) && !b_BootyNuke[npc.index] && !b_BootyNukeUsed[npc.index])
	{
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		fl_BootyNuke_Timer[npc.index] = GetGameTime(npc.index) + 10.0;
		npc.PlayBootyNukeSound();
		Shitting_spawnRing_Vectors(vEnd, 1999.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 9.8, 4.0, 0.1, 1, 1.0);
		Shitting_spawnRing_Vectors(vEnd, 1999.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 9.8, 4.0, 0.1, 1, 1.0);
		CPrintToChatAll("{red}[WARNING]{yellow}Booty Executioner is about to Explode the whole {red}AREA!");
		//CPrintToChatAll("{yellow}Uber while you can.");//actually forgot uber does jack SHIT due to me
		b_BootyNuke[npc.index] = true;
	}
	if(fl_BootyNuke_Timer[npc.index] <= GetGameTime(npc.index) && b_BootyNuke[npc.index] && !b_BootyNukeUsed[npc.index])
	{
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		b_BootyNuke[npc.index] = false;
		b_BootyNukeUsed[npc.index] = true;
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Explode_Logic_Custom(99999.0, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, 7000.0, _, 0.8, true);
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			/*int color[4];
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
		if(b_ExeLaser[npc.index] && !b_HeavyHo[npc.index] && !b_BootyExplosion[npc.index] && !b_BootyNuke[npc.index])
		{
			npc.FaceTowards(vecTarget, 1200.0);
			npc.m_flSpeed = fl_MainSpeed/4;
		}
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.PlayMeleeSound();
					if(b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
					{
						//npc.m_flAttackHappens = GetGameTime(npc.index)+0.1;
						//npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.25;
						npc.m_flAttackHappens = GetGameTime(npc.index) + 0.10;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 0.15;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					}
					else if(b_Serious_Punch[npc.index] && !b_HeavyHo[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.45;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					}
					else if(!b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					}
					npc.m_flAttackHappenswillhappen = true;
				}	
				if(npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0)
						{
							if(target <= MaxClients)
							{
								if(b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_HeavyHoDamageMult * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_HeavyHoDamageMult, DMG_CLUB, -1, _, vecHit);
									}
								}
								else if(b_Serious_Punch[npc.index] && !b_HeavyHo[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * 1.8 * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * 1.8, DMG_CLUB, -1, _, vecHit);
									}
									i_Serious_Punch_Hit[npc.index]++;
								}
								else
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage, DMG_CLUB, -1, _, vecHit);
									}
								}
								i_Crit_Hit[npc.index]++;
							}
							else
							{
								if(b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_HeavyHoDamageMult * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_HeavyHoDamageMult, DMG_CLUB, -1, _, vecHit);
									}
								}
								else if(b_Serious_Punch[npc.index] && !b_HeavyHo[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * 1.8 * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * 1.8, DMG_CLUB, -1, _, vecHit);
									}
									i_Serious_Punch_Hit[npc.index]++;
								}
								else
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage, DMG_CLUB, -1, _, vecHit);
									}
								}
								i_Crit_Hit[npc.index]++;
							}
							//Hit sound
							npc.PlayMeleeHitSound();	
						}
					}
					delete swingTrace;
					if(b_HeavyHo[npc.index])
					{
						//npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
					}
					if(b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else if(!b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.5;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					if(b_HeavyHo[npc.index])
					{
						//npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.1;
					}
					if(b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else if(!b_HeavyHo[npc.index] && !b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.5;
					}
					npc.m_flAttackHappenswillhappen = false;
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

public Action BootyExecutioner_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BootyExecutioner_NPCDeath(int entity)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(entity);
	npc.PlayDeathSound();	
	if(!b_IsAlliedNpc[npc.index])
	{
		Music_Stop_Main_Theme(entity);
		Music_Stop_Death_Theme(entity);
		fl_DuoExecuteCustomPootisTheme = GetGameTime() + 0.01;
		b_DuoOnePootisDied = true;
		b_DuoDisableMainPootisTheme = true;
		b_DuoMainLeaderDied = true;
		//RaidBossActive = INVALID_ENT_REFERENCE;
	}
	if(b_DuoOnePootisDied && b_DuoMainLeaderDied && b_DuoSandSlayerDied)
	{
		EmitSoundToAll(POOTISOUTROMUSIC);
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, BootyExecutioner_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

//THE ALMIGHTLY CTRL+C + CTRL+V ON FUSION BEAM
void BootyExecutioner_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		BootyExecutioner_BEAM_BuildingHit[building] = false;
	}
	
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
	
	BootyExecutioner_BEAM_IsUsing[client] = false;
	BootyExecutioner_BEAM_TicksActive[client] = 0;

	BootyExecutioner_BEAM_CanUse[client] = true;
	BootyExecutioner_BEAM_CloseDPT[client] = 840.0/2;//a
	BootyExecutioner_BEAM_FarDPT[client] = 720.0/2;//a
	BootyExecutioner_BEAM_MaxDistance[client] = 2000;
	BootyExecutioner_BEAM_BeamRadius[client] = 25;
	BootyExecutioner_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	BootyExecutioner_BEAM_ChargeUpTime[client] = 200;
	BootyExecutioner_BEAM_CloseBuildingDPT[client] = 0.0;
	BootyExecutioner_BEAM_FarBuildingDPT[client] = 0.0;
	BootyExecutioner_BEAM_Duration[client] = 4.0;
	
	BootyExecutioner_BEAM_BeamOffset[client][0] = 0.0;
	BootyExecutioner_BEAM_BeamOffset[client][1] = 0.0;
	BootyExecutioner_BEAM_BeamOffset[client][2] = 0.0;

	BootyExecutioner_BEAM_ZOffset[client] = 0.0;

	BootyExecutioner_BEAM_IsUsing[client] = true;
	BootyExecutioner_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	/*switch(GetRandomInt(1, 4))
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
	}*/
	CreateTimer(5.0, TrueBootyExecutioner_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, TrueBootyExecutioner_TBB_Tick);
}

public Action TrueBootyExecutioner_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	BootyExecutioner_BEAM_IsUsing[client] = false;
	b_AbilityManagement[client] = false;
	
	BootyExecutioner_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

static void BootyExecutioner_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	BootyExecutioner npc = view_as<BootyExecutioner>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == BootyExecutioner_BEAM_BeamOffset[client][0] && 0.0 == BootyExecutioner_BEAM_BeamOffset[client][1] && 0.0 == BootyExecutioner_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = BootyExecutioner_BEAM_BeamOffset[client][0];
	tmp[1] = BootyExecutioner_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = BootyExecutioner_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

public bool BootyExecutioner_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
public bool BootyExecutioner_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsEntityAlive(entity))
	{
		BootyExecutioner_BEAM_HitDetected[entity] = true;
	}
	else if (IsValidEntity(entity))
	{
		if(0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));
			
			if (!StrContains(classname, "zr_base_npc", true) && (GetEntProp(entity, Prop_Send, "m_iTeamNum") != GetEntProp(client, Prop_Send, "m_iTeamNum")))
			{
				for(int i=1; i <= MAXENTITIES; i++)
				{
					if(!BootyExecutioner_BEAM_BuildingHit[i])
					{
						BootyExecutioner_BEAM_BuildingHit[i] = entity;
						break;
					}
				}
			}
			
		}
	}
	return false;
}

public Action TrueBootyExecutioner_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !BootyExecutioner_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, TrueBootyExecutioner_TBB_Tick);
		BootyExecutioner npc = view_as<BootyExecutioner>(client);
		npc.m_flSpeed = fl_MainSpeed;
		b_ExeLaser[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	BootyExecutioner_BEAM_TicksActive[client] = tickCount;
	float diameter = float(BootyExecutioner_BEAM_BeamRadius[client] * 2);
	int r = GetR(BootyExecutioner_BEAM_ColorHex[client]);
	int g = GetG(BootyExecutioner_BEAM_ColorHex[client]);
	int b = GetB(BootyExecutioner_BEAM_ColorHex[client]);
	if (BootyExecutioner_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		BootyExecutioner npc = view_as<BootyExecutioner>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
		
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BootyExecutioner_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(BootyExecutioner_BEAM_MaxDistance[client]));
			float lineReduce = BootyExecutioner_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXTF2PLAYERS; i++)
			{
				BootyExecutioner_BEAM_HitDetected[i] = false;
			}
			
			hullMin[0] = -float(BootyExecutioner_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BootyExecutioner_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MaxClients; victim++)
			{
				if (BootyExecutioner_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetClientTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BootyExecutioner_BEAM_CloseDPT[client] + (BootyExecutioner_BEAM_FarDPT[client]-BootyExecutioner_BEAM_CloseDPT[client]) * (distance/BootyExecutioner_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			
			static float belowBossEyes[3];
			BootyExecutioner_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, BootyExecutioner_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, BootyExecutioner_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, BootyExecutioner_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, BootyExecutioner_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, BootyExecutioner_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}
//ends here

void Music_Stop_Main_Theme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
}

void Music_Stop_Death_Theme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
}

void Music_Stop_Beat_Ten(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
}

static void Shitting_spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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