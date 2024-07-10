#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"mvm/mvm_robo_stun.wav",
	"mvm/mvm_bomb_explode.wav",
};

static char g_HurtSounds[][] = {
	"vo/medic_item_secop_domination01.mp3",
	"vo/medic_item_secop_idle03.mp3",
	"vo/medic_item_secop_idle01.mp3",
	"vo/medic_item_secop_idle02.mp3",
};

static char g_IdleSounds[][] = {
	"vo/medic_specialcompleted11.mp3",
	"vo/medic_specialcompleted12.mp3",
	"vo/medic_specialcompleted08.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/medic_hat_taunts01.mp3",
	"vo/medic_hat_taunts04.mp3",
	"vo/medic_item_secop_round_start05.mp3",
	"vo/medic_item_secop_round_start07.mp3",
	"vo/medic_item_secop_kill_assist01.mp3",
};

static char g_MeleeHitSounds[][] = {
	"vo/medic_laughshort01.mp3",
	"vo/medic_laughshort02.mp3",
	"vo/medic_laughshort03.mp3",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_03.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	"vo/medic_sf13_influx_big02.mp3",
	"vo/medic_sf13_influx_big03.mp3",
	"vo/medic_weapon_taunts03.mp3",
};

static char g_PullSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};

#define BLITZKRIEG_PUNISHMENT_SHIELD_MULTI "4.75"

#define SOUND_BLITZ_IMPACT_1 					"physics/flesh/flesh_impact_bullet1.wav"	//We hit flesh, we are also kinetic, yes.
#define SOUND_BLITZ_IMPACT_2 					"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_BLITZ_IMPACT_3 					"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_BLITZ_IMPACT_4 					"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_BLITZ_IMPACT_5 					"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_BLITZ_IMPACT_CONCRETE_1		"physics/concrete/concrete_impact_bullet1.wav"//we hit the ground? HOW DARE YOU MISS?
#define SOUND_BLITZ_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_BLITZ_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_BLITZ_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

static char gGlow1;
static char gExplosive1;
static char gLaser1;

static int i_AmountProjectiles[MAXENTITIES];
static int i_NpcCurrentLives[MAXENTITIES];
static float i_HealthScale[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_LifelossReload[MAXENTITIES];
static float fl_TheFinalCountdown[MAXENTITIES];
static float fl_TheFinalCountdown2[MAXENTITIES];
static bool b_winline;

static bool b_Are_we_reloading[MAXENTITIES];

static float fl_move_speed[MAXENTITIES];
//Rocket launcher stuff
static float fl_rocket_firerate[MAXENTITIES];
static int i_PrimaryRocketsFired[MAXENTITIES];
static int i_maxfirerockets[MAXENTITIES];
static float fl_rocket_base_dmg[MAXENTITIES];

//Wave control
static int i_wave_life1[MAXENTITIES];
static int i_wave_life2[MAXENTITIES];
static int i_wave_life3[MAXENTITIES];

static float fl_blitzscale[MAXENTITIES];

static bool b_final_push[MAXENTITIES];

static int i_final_nr[MAXENTITIES];

static bool b_BlitzLight[MAXENTITIES];
static bool b_BlitzLight_stop[MAXENTITIES];
static bool b_BlitzLight_sound[MAXENTITIES];

static float fl_BlitzLight_Throttle[MAXENTITIES];

#define BLITZLIGHT_SPRITE	  "materials/sprites/laserbeam.vmt"
#define BLITZLIGHT_ACTIVATE	  "vo/medic_sf13_influx_big02.mp3"
#define BLITZLIGHT_ATTACK	  "mvm/ambient_mp3/mvm_siren.mp3"

static int g_particleBLITZ_IMPACTTornado;

static bool b_life1[MAXENTITIES];
static bool b_life2[MAXENTITIES];
static bool b_life3[MAXENTITIES];
static bool b_allies[MAXENTITIES];
static bool b_lowplayercount[MAXENTITIES];
static int i_currentwave[MAXENTITIES];

static float fl_attack_timeout[MAXENTITIES];

//Blit'z item drop relate stuff

float g_f_blitz_dialogue_timesincehasbeenhurt;
bool g_b_item_allowed;
bool g_b_donner_died;
bool g_b_schwert_died;
bool g_b_angered;



  ///////////////////////
 ///BlitzLight Floats///
///////////////////////

static float BlitzLight_Duration_notick[MAXENTITIES];
static int BlitzLight_Beam;

static float BlitzLight_Duration[MAXENTITIES];
static float BlitzLight_ChargeTime[MAXENTITIES];
static float BlitzLight_Scale1[MAXENTITIES];
static float BlitzLight_Scale2[MAXENTITIES];
static float BlitzLight_Scale3[MAXENTITIES];
static float BlitzLight_DMG[MAXENTITIES];
static float BlitzLight_DMG_Base[MAXENTITIES];
static float BlitzLight_DMG_Radius[MAXENTITIES];
static float BlitzLight_Radius[MAXENTITIES];
static float BlitzLight_Angle[MAXENTITIES];

static int g_ProjectileModelRocket;

static bool b_lost;

public void Blitzkrieg_OnMapStart()
{
	g_f_blitz_dialogue_timesincehasbeenhurt=0.0;
	g_b_item_allowed=false;
	g_b_donner_died=false;
	g_b_schwert_died=false;
	g_b_angered=false;
	b_lost=false;

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Blitzkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_blitzkrieg");
	strcopy(data.Icon, sizeof(data.Icon), "blitzkrieg");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);      		}
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);       		}
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);       		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);   		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]); 			}
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}		
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   				}
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	PrecacheSoundCustom("#zombiesurvival/altwaves_and_blitzkrieg/music/blitz_theme.mp3");
	g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl");
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_4);
	
	PrecacheSound(SOUND_BLITZ_IMPACT_1);
	PrecacheSound(SOUND_BLITZ_IMPACT_2);
	PrecacheSound(SOUND_BLITZ_IMPACT_3);
	PrecacheSound(SOUND_BLITZ_IMPACT_4);
	PrecacheSound(SOUND_BLITZ_IMPACT_5);
	
	g_particleBLITZ_IMPACTTornado = PrecacheParticleSystem("lowV_debrischunks");
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheSound("player/flow.wav");
	
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_horn.wav");
	PrecacheSound("mvm/mvm_tank_explode.wav");
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	
	BlitzLight_Beam = PrecacheModel(BLITZLIGHT_SPRITE);
	
	PrecacheSound(BLITZLIGHT_ACTIVATE, true);
	PrecacheSound(BLITZLIGHT_ATTACK, true);
	
	PrecacheSound("misc/halloween/gotohell.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Blitzkrieg(client, vecPos, vecAng, ally, data);
}

static bool b_timer_lose[MAXENTITIES];

methodmap Blitzkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
		public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.5);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
	public Blitzkrieg(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Blitzkrieg npc = view_as<Blitzkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.4", "25000", ally, false, true, true, true)); //giant!
		
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
			
		npc.m_iChanged_WalkCycle = -1;
		
		if(npc.m_iChanged_WalkCycle != 1) 	
		{
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
		}
		/*
			1 = Primary Run.
			2 = Melee Run.
		*/
//		npc.m_flPlayMusicSound = 0.0;

		b_winline = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		

		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/blitz_theme.mp3");
		music.Time = 228;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Death");
		strcopy(music.Artist, sizeof(music.Artist), "Occams Laser");
		Music_SetRaidMusic(music);
		
		npc.m_bThisNpcIsABoss = true;
		b_lost=false;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
		i_NpcCurrentLives[npc.index] = 0;	//Basically tells the npc which life it currently is in
		
		i_HealthScale[npc.index] = 1.0;	//default 1, this is instantly overriden the moment the npc takes damage.
		
		fl_move_speed[npc.index] = 250.0;	//base move speed when on life 0, when npc loses a life this number is changed. also while blitz is using his melee he moves 50 hu's less
		//rocket launcher stuff
		fl_rocket_firerate[npc.index] = 0.4;	//Base firerate of blitz, overriden once npc takes damage
		fl_rocket_base_dmg[npc.index] = 5.0;	//The base dmg that all scaling is done on
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		i_currentwave[npc.index]=(ZR_GetWaveCount()+1);
		b_thisNpcIsARaid[npc.index] = true;
		
		//wave control	| at which wave or beyond will the life activate | Now that I think about it, this one might just be useless
		i_wave_life1[npc.index] = 15;
		i_wave_life2[npc.index] = 30;
		i_wave_life3[npc.index] = 45;	//fun fact, this just exists, no idea if its used for anything. 
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.16; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.33;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		if(amount_of_people<8)	//This is to avoid blitz taking so much damage at low player counts that certain abilities just don't trigger
		{
			b_lowplayercount[npc.index]=true;
		}
		else
		{
			b_lowplayercount[npc.index]=false;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%t", "Blitzkrieg Spawn");
			}
		}
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;	// used for extra rocket spam along side blitz's current rockets
		
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Blitzkrieg_Win);
		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		SetVariantColor(view_as<int>({145, 47, 47, 255}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Cardiologists_Camo/Cardiologists_Camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItemSeperate("head", "models/buildables/sentry_shield.mdl",_,_,_,-350.0, true);
		SetVariantString(BLITZKRIEG_PUNISHMENT_SHIELD_MULTI);
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 55, 30, 30, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 0, 0, 255);
		
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 100, 100, 125);
		
		//IDLE
		npc.m_flSpeed = fl_move_speed[npc.index];
		
		
		fl_TheFinalCountdown[npc.index] = 0.0;	//used for timer logic on blitzlight
		fl_TheFinalCountdown2[npc.index] = 0.0;	//used for timer logic on blitzlight
		i_PrimaryRocketsFired[npc.index] = 0;	//Checks how many rockets haave been fired by blitz's RL.
		fl_LifelossReload[npc.index] = 1.0;	//how fast blitz reloads when ammo is depleted, this number multiples a base 10 number. Basically: 10*fl_LifelossReload[npc.index]
		i_maxfirerockets[npc.index] = 20;	//blitz's max ammo, this number changes on lifeloss.
		i_final_nr[npc.index] = 0;	//used for logic in blitzlight, basicaly locks out stuff so it doesn't repeat the ability.
		
		bool final = StrContains(data, "final_item") != -1;
		fl_blitzscale[npc.index] = (RaidModeScaling*1.5)*zr_smallmapbalancemulti.FloatValue;	//Storage for current raidmode scaling to use for calculating blitz's health scaling.
		if(i_currentwave[npc.index]<=30)
		{
			fl_blitzscale[npc.index] *= 2.0;	//blitz is quite weak on wave 15, and 30
		}
		else if(i_currentwave[npc.index]>=60)
		{
			fl_blitzscale[npc.index] /= 3.0;	//blitz is quite scary on wave 60, so nerf him a bit
			
		}
		if(i_currentwave[npc.index]>60 && !final)
		{
			RaidModeTime = GetGameTime(npc.index) + 900.0;	//tripple the time for waves beyond 60!
		}
		if(final)
		{
			g_b_item_allowed=true;
		}
		else
		{
			g_b_item_allowed=false;
		}
		
		npc.m_flMeleeArmor = 1.25;
		
		/*
		Original scaling is divided by 4, the multiplied by the numbers bellow.
		4x	Wave 15, origami scaling x4.
		3x	wave 30, original scaling x3.
		2x  wave 45, original scaling x2. | Asuming wave 45, 6 players. scaling=((7.2/4)*60/45)*(1.0+(1-(Health/MaxHealth))*1.22) | The entire scaling.
		1x	wave 60, orginial.
		*/
		
		b_BlitzLight[npc.index]=false;			//First stage of blitzlight, blocks health scaling.
		b_BlitzLight_stop[npc.index]=false;		//Tell's the npc when blitzlight has ended
		b_BlitzLight_sound[npc.index]=false;	//Stops sounds related to blitzlight.
		
		BlitzLight_Duration_notick[npc.index]=GetGameTime(npc.index)+1000.0;	//Used to findout the current duration of blitzlight without tick's
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;	//Block's KB from certain abilities. mainly blitzlight
		
		b_final_push[npc.index] = false;			//used for blitzlight logic.
		b_Are_we_reloading[npc.index] = false;		//Tell's the npc that it is indeed reloading and that its a good idea to switch to melee. blocks certain abilities, also is used to block the RJ during blitzlight.
//		npc.PlayMusicSound();
		npc.StartPathing();
		
		npc.m_flCharge_Duration = 0.0;					//during blitzlight, blitz's teleport gets replaced with a dash.
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		
		b_life1[npc.index]=false;	//tell's the npc if 1st life is true.
		b_life2[npc.index]=false;	//tell's the npc if 2nd life is true.
		b_life3[npc.index]=false;	//tell's the npc if 3rd life is true.
		
		b_allies[npc.index]=false;
		
		b_timer_lose[npc.index] = false;
		
		
		
		Citizen_MiniBossSpawn();
		return npc;
		
		/*
		Thanks to Spookmaster for allowing me to port over his "Holy Moonlight" that his dokmed raidboss uses.
		*/
	}
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(iNPC);

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,5))
			{
				case 0:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You alone? How amusing.");
				}
				case 1:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Machines win once more... You're the last...");
				}
				case 3:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You are hopeless.");
				}
				case 4:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Death is{crimson} Inevitable");
				}
				case 5:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: All your friends have already{crimson} joined{default} us.. {crimson} You're next..");
				}
			}
		}
	}
	
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND && !b_winline)
	{
		b_timer_lose[npc.index] = true;

		b_winline=true;
		
		switch(GetRandomInt(0,4))
		{
			case 0:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: {crimson}Annhilated{default}.");
			}
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Hopeless scrap");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Such lackluster {crimson}weapons{default}.");
			}
			case 4:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Death is{crimson} Inevitable{default}.");
			}
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	} 
	if(RaidModeTime < GetGameTime() && !b_lost)	//warp
	{
		
		ZR_NpcTauntWinClear();

		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

		MaxHealth = RoundToFloor(MaxHealth*0.01);

		//Sieg heil

		Spawn_Blitz_Army(npc.index, "npc_alt_combine_soldier_deutsch_ritter", MaxHealth, 20);
		Spawn_Blitz_Army(npc.index, "npc_alt_ikunagae", MaxHealth, 10);
		Spawn_Blitz_Army(npc.index, "npc_alt_kahml", MaxHealth, 5);
		Spawn_Blitz_Army(npc.index, "npc_alt_medic_berserker", MaxHealth, 50);
		Spawn_Blitz_Army(npc.index, "npc_alt_medic_charger", MaxHealth, 69);
		Spawn_Blitz_Army(npc.index, "npc_alt_medic_healer_3", MaxHealth, 35);
		Spawn_Blitz_Army(npc.index, "npc_alt_sniper_railgunner", MaxHealth, 50);
		Spawn_Blitz_Army(npc.index, "npc_alt_medic_supperior_mage", MaxHealth, 25);

		npc.m_flMeleeArmor = 0.1;
		npc.m_flRangedArmor = 0.1;	

		float charge=2.0;
		float timer=100.0;	
		fl_TheFinalCountdown2[npc.index] = GetGameTime(npc.index)+timer+charge+1.0;	
		BlitzLight_Invoke(npc.index, timer, charge);

		i_maxfirerockets[npc.index] =6969;	//Buff's the clipsize

		b_BlitzLight[npc.index]=true;			
		b_BlitzLight_stop[npc.index]=false;		
		b_BlitzLight_sound[npc.index]=false;	

		i_currentwave[npc.index] = 60;

		b_timer_lose[npc.index] = true;

		b_lost=true;
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: It is already {crimson}too late,{default} my army has arrived...");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: My army has completely secured the area{crimson} surrender now{default} or perish");
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: You all will make {crimson}excellent{default} additions to my army...");
			}
		}
	}
	
	if(!IsValidEntity(npc.m_iWearable6))
	{
		npc.m_iWearable6 = npc.EquipItemSeperate("head", "models/buildables/sentry_shield.mdl",_,_,_,-350.0,true);
		SetVariantString(BLITZKRIEG_PUNISHMENT_SHIELD_MULTI);
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 100, 100, 125);
	}
	else
	{
		float vecTarget[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] -= 350.0;
		Custom_SDKCall_SetLocalOrigin(npc.m_iWearable6, vecTarget);
	}
	
	//SetVariantInt(1);
    //AcceptEntityInput(npc.index, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		/*
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		*/
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	int closest = npc.m_iTarget;
	int PrimaryThreatIndex = npc.m_iTarget;
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	
	if(b_Are_we_reloading[npc.index])	//do melee run on reload/blitzlight
	{
		if(npc.m_iChanged_WalkCycle != 2)
		{	
			npc.m_iChanged_WalkCycle = 2;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			
			//Gives Melee when melee run animation plays.
			
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");	//Replaces current weapon with uber saw.
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 1)	//do primary run every other time
		{
			npc.m_iChanged_WalkCycle = 1;
			npc.SetActivity("ACT_MP_RUN_PRIMARY");
			
			//Gives the correct launcher when primary run animation is played.
			
			if(i_NpcCurrentLives[npc.index]==0)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_rocketlauncher.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(i_NpcCurrentLives[npc.index]==1)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(i_NpcCurrentLives[npc.index]==2)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(i_NpcCurrentLives[npc.index]>=3)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
		}
	}
	/*
		1 = Primary Run.
		2 = Melee Run.
	*/
	
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				/*
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);
				*/
				
				
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			npc.StartPathing();
			
			if(fl_TheFinalCountdown2[npc.index] <= GetGameTime(npc.index) && i_final_nr[npc.index] == 1)	//moved the reset due to the funny clot damaged only being called when damaged
			{	//Resets the npc to a base state after blitzlight is used.
				i_final_nr[npc.index]=5;
				
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");	//The thing everyone fears, the airstrike.
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
				
				b_Are_we_reloading[npc.index]=false;
				
				npc.m_flReloadIn = GetGameTime(npc.index) + 1.0;
				
				
				fl_move_speed[npc.index] = 300.0;
				
					
				npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
				i_maxfirerockets[npc.index] = 100;
				
				fl_attack_timeout[npc.index] = GetGameTime(npc.index)+1.0;
				
				fl_LifelossReload[npc.index] = 0.3;
				
				npc.m_flRangedArmor = 1.0;
				
			}
			//emits blitzlight attack sound.
			if(BlitzLight_Duration_notick[npc.index] <= GetGameTime(npc.index) && !b_BlitzLight_sound[npc.index])
			{
				EmitSoundToAll(BLITZLIGHT_ATTACK);
				
				EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 100, _, 0.8, 60);
				EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 100, _, 0.8, 60);
				
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.8);
						EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 0.8);			
					}
					case 2:
					{
						EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.8);
						EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 0.8);
					}
					case 3:
					{
						EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.8);	
						EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 0.8);			
					}
					case 4:
					{
						EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.8);
						EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 0.8);
					}		
				}
				
				b_BlitzLight_sound[npc.index]=true;
			}
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				if(!b_BlitzLight[npc.index])	//this checks if the npc is in blitzlight, if it is use dash instead of teleport.
				{
					if(npc.m_flNextTeleport < GetGameTime(npc.index) && flDistanceToTarget > (125.0* 125.0) && flDistanceToTarget < (500.0 * 500.0))
					{
						static float flVel[3];
						GetEntPropVector(closest, Prop_Data, "m_vecVelocity", flVel);
		
						if (flVel[0] >= 190.0)
						{
							npc.FaceTowards(vecTarget);
							npc.FaceTowards(vecTarget);
							npc.m_flNextTeleport = GetGameTime(npc.index) + 30.0;
							float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
							
							if(Tele_Check > 120.0)
							{
								bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
								if(Succeed)
								{
									npc.PlayTeleportSound();
								}
								else
								{
									npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
								}
							}
						}
					}
				}
				else
				{
					npc.m_flSpeed=fl_move_speed[npc.index];
					if(npc.m_flCharge_Duration < GetGameTime(npc.index))
					{
						if(npc.m_flCharge_delay < GetGameTime(npc.index))
						{
							int Enemy_I_See;
							Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
							//Target close enough to hit
							if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
							{
								npc.m_flCharge_delay = GetGameTime(npc.index) + 7.5;
								npc.m_flCharge_Duration = GetGameTime(npc.index) + 1.0;
								PluginBot_Jump(npc.index, vecTarget);
							}
						}
					}
					else
					{
						npc.m_flSpeed=325.0;
					}
				}
			}
			//Extra rockets during rocket spam, also envokes ioc if blitz is on 3rd life.
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0) && i_NpcCurrentLives[npc.index]>1 && !b_Are_we_reloading[npc.index] && fl_attack_timeout[npc.index] < GetGameTime(npc.index))
			{	
				int Enemy_I_See;		
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
				 	npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					float projectile_speed = (300.0 * i_HealthScale[npc.index]);
					if(projectile_speed>=6000.0)
						projectile_speed = 6000.0;
						
					FireBlitzRocket(npc.index, vecTarget, 7.5 * i_HealthScale[npc.index], projectile_speed, 1.0);
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15 / i_HealthScale[npc.index];
					if (npc.m_iAmountProjectiles >= i_maxfirerockets[npc.index])
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 45.0 * fl_LifelossReload[npc.index];
						if(i_NpcCurrentLives[npc.index]>=2)
						{
							EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
							Blitzkrieg_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
						}
					}
				}
			}
			if(i_PrimaryRocketsFired[npc.index] > i_maxfirerockets[npc.index])	//Every x rockets npc enters a 10 second reload time that scales on lifeloss reload.
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
				npc.m_flReloadIn = GetGameTime(npc.index) + (10.0 * fl_LifelossReload[npc.index]);
				i_PrimaryRocketsFired[npc.index] = 0;	//Resets fired rockets to 0 for when reload ends.
				b_Are_we_reloading[npc.index] = true;
				fl_attack_timeout[npc.index] = GetGameTime(npc.index) + (10.0 * fl_LifelossReload[npc.index]) + 1.0;
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");	//Replaces current weapon with uber saw.
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
				
				npc.m_iChanged_WalkCycle = -1;
			}
			if(npc.m_flReloadIn <= GetGameTime(npc.index) && b_Are_we_reloading[npc.index])	//fast1
			{
				b_Are_we_reloading[npc.index] = false;
			}
			if(flDistanceToTarget < 10000000 && npc.m_flReloadIn <= GetGameTime(npc.index) && !b_Are_we_reloading[npc.index] && fl_attack_timeout[npc.index] <= GetGameTime(npc.index))
			{	//Blitz has infinite range and moves while firing rockets.
				int Enemy_I_See;		
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Look at target so we hit.
					npc.FaceTowards(vecTarget, 1500.0);
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
					{
						npc.m_flSpeed = fl_move_speed[npc.index]-50;	//50 speed slower when using rocket launcher
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						float projectile_speed = 500.0*(1.0+(1-(Health/MaxHealth))*1.5);	//Rocket speed, scales on current health.
						PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
						npc.PlayMeleeSound();
						FireBlitzRocket(npc.index,vecTarget, fl_rocket_base_dmg[npc.index] * i_HealthScale[npc.index], projectile_speed, 1.0); //remove the no kb if people cant escape, or just lower the dmg
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + fl_rocket_firerate[npc.index];
						i_PrimaryRocketsFired[npc.index]++;	//Adds 1 extra rocket to the shoping list for when we go out shoping in the reload store.
						npc.m_flAttackHappens = 0.0;
					}
				}
			}
			if(b_Are_we_reloading[npc.index])	//Melee logic for when we are shoping for rockets. aka reloading.
			{
				//Target close enough to hit
				BlitzKriegSelfDefense(npc, GetGameTime(npc.index));
			}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
//	npc.PlayMusicSound();
	npc.PlayIdleAlertSound();
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0 || attacker > MaxClients)
		return Plugin_Continue;
		
	Blitzkrieg npc = view_as<Blitzkrieg>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );
	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	
	if((flDistanceToTarget > 1000000 || b_lost) && fl_blitz_ioc_punish_timer[npc.index][attacker] < GetGameTime(npc.index) && IsPlayerAlive(attacker) && TeutonType[attacker] == TEUTON_NONE && dieingstate[attacker] == 0)	//Basically we "punish(ment)" players who are too far from blitz.
	{
		//CPrintToChatAll("Target inside distance %i", attacker);
		Blitzkrieg_Punishment_Invoke(npc.index, attacker, flDistanceToTarget);
	}
	/*else
	{
		CPrintToChatAll("Target outside distance %i", attacker);
	}*/
	int closest = npc.m_iTarget;	//IOC and text towards the npc's target, who is most likely the one tanking him, ion *should* in theory obliterate them!
	
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	
	if(!b_BlitzLight[npc.index])	//Blocks scaling if blitzlight is active
	{	//Blitz's power scales off of current health. the health scaling is dependant on current stage, 1 stage being 15 waves.
		if(i_currentwave[npc.index]<=15)
		{
			RaidModeScaling= fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth)));
			i_HealthScale[npc.index]=fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth)));
			fl_rocket_firerate[npc.index]=((Health/MaxHealth)-0.4)/zr_smallmapbalancemulti.FloatValue;
			if(fl_rocket_firerate[npc.index]<=0.3)//This limits the firerate of the npc.
			{
				fl_rocket_firerate[npc.index]=0.3;
			}
		}
		if(i_currentwave[npc.index]<=30 && i_currentwave[npc.index]>15)	//waves 16-30 he scales with this
		{
			RaidModeScaling= fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.1);
			i_HealthScale[npc.index]=fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.1);
			fl_rocket_firerate[npc.index]=((Health/MaxHealth)-0.5)/zr_smallmapbalancemulti.FloatValue;
			if(fl_rocket_firerate[npc.index]<=0.25)//This limits the firerate of the npc.
			{
				fl_rocket_firerate[npc.index]=0.25;
			}
		}
		if(i_currentwave[npc.index]<=45 && i_currentwave[npc.index]>30)//waves 31-45 he scales with this
		{
			RaidModeScaling= fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.22);
			i_HealthScale[npc.index]=fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.22);
			fl_rocket_firerate[npc.index]=((Health/MaxHealth)-0.75)/zr_smallmapbalancemulti.FloatValue;
			if(fl_rocket_firerate[npc.index]<=0.075)//This limits the firerate of the npc.
			{
				fl_rocket_firerate[npc.index]=0.075;
			}
		}
		if(i_currentwave[npc.index]>=60)	//beyond wave 60 he scales with this
		{
			RaidModeScaling= fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.3);
			i_HealthScale[npc.index]=fl_blitzscale[npc.index]*(1.0+(1-(Health/MaxHealth))*1.3);
			fl_rocket_firerate[npc.index]=((Health/MaxHealth)-0.85)/zr_smallmapbalancemulti.FloatValue;
			if(fl_rocket_firerate[npc.index]<=0.01)	//This limits the firerate of the npc. In this case its used to make sure it doesn't go negative or not to reach server crashing levels of firerate.
			{
				fl_rocket_firerate[npc.index]=0.01;
			}
		}
	}
	
	  //////////////////////
	 ///Blitzkrieg Lives///
	//////////////////////
	
	//Blitzkrieg uses lives to buff and to change rocket launchers and for other abilities.
	
	if(Health/MaxHealth>0.5 && Health/MaxHealth<0.75 && !b_life1[npc.index] && i_currentwave[npc.index]>=i_wave_life1[npc.index])	//Lifelosses
	{	//75%-50%
		i_NpcCurrentLives[npc.index]=1;
		b_life1[npc.index]=true;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");	//Liberty
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_maxfirerockets[npc.index] =25;	//Buff's the clipsize
		
		fl_attack_timeout[npc.index] = GetGameTime(npc.index)+1.0;
		
		fl_LifelossReload[npc.index] = 0.8;	//Buff's the reload speed.
		
		fl_move_speed[npc.index] = 270.0;	//Buff's movement speed.
		
		npc.m_flReloadIn = GetGameTime(npc.index);	//Forces immediate reload.
		
		b_Are_we_reloading[npc.index]=false;	//Forces immediate reload.
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);
		
		if(IsValidClient(closest))//Fancy text for blitz
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: This is only just the beginning {yellow}%N{default}!", closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You think this is the end {yellow}%N{default}?", closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You fool {yellow}%N{default}!", closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: There plenty more to come {yellow}%N{default}!", closest);
				}
			}
		}
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");
		
		npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
		
	}
	else if(Health/MaxHealth<0.5 && !b_life2[npc.index] && i_currentwave[npc.index]>=i_wave_life2[npc.index])
	{	//50%-25% same thing as before.
		i_NpcCurrentLives[npc.index]=2;
		b_life2[npc.index]=true;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");	//Dumpster deive aka beggars
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		b_Are_we_reloading[npc.index]=false;
		
		npc.m_flReloadIn = GetGameTime(npc.index);
		
		i_maxfirerockets[npc.index] =40;
		
		fl_attack_timeout[npc.index] = GetGameTime(npc.index)+1.0;
		
		
		fl_LifelossReload[npc.index] = 0.75;
		
		fl_move_speed[npc.index] = 275.0;
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);

		if(IsValidClient(closest))
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Don't get too cocky {yellow}%N{default}!", closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Thy end is near {yellow}%N{default}!", closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}%N {default}are you sure you want to proceed further?", closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: This is getting interesting, {yellow}%N{default}!", closest);
				}
			}
		}
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");
					
		npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
		
	}
	else if(Health/MaxHealth>0.175 && Health/MaxHealth<0.25 && !b_life3[npc.index] && b_life2[npc.index] && i_currentwave[npc.index]>=i_wave_life3[npc.index])
	{	//25%-ded same thing as before.
		i_NpcCurrentLives[npc.index]=3;
		b_life3[npc.index]=true;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");	//The thing everyone fears, the airstrike.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");
		
		b_Are_we_reloading[npc.index]=false;
		
		npc.m_flReloadIn = GetGameTime(npc.index);
		
		i_maxfirerockets[npc.index] = 65;
		
		fl_attack_timeout[npc.index] = GetGameTime(npc.index)+1.0;
		
		fl_move_speed[npc.index] = 280.0;
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);
		
		if(IsValidClient(closest))
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Your own foolishness lead you to this {yellow}%N{default} prepare for complete {red}BLITZKRIEG", closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: Thy end is {red} Now {yellow}%N{default} Thou shall feel true {red}BLITZKRIEG", closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You've gone and done it {red} ITS TIME TO DIE {yellow}%N {red}PREPARE FOR FULL BLITZKRIEG", closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}Blitzkrieg{default}: You cannot stop the {crimson}Blitzkrieg{default} with such lackluster weapons {yellow}%N{default}!", closest);
				}
			}
		}
		
		fl_LifelossReload[npc.index] = 0.65;
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
					
		npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
		
	} 
	if(((Health/MaxHealth>0 && Health/MaxHealth<0.175) || (Health/MaxHealth<=0.2 && b_lowplayercount[npc.index])) && i_currentwave[npc.index]>=i_wave_life3[npc.index] && !b_final_push[npc.index])
	{	//If server count is above 8 this will actiavte on 17.5% hp, however since on low player counts blitz's hp is low enough for players with insane single target damage to just avoid this ability, so to prevent that this ability is activated on 24% hp.
		
		EmitSoundToAll("mvm/mvm_tank_horn.wav");
		
		b_final_push[npc.index] = true;	//Tells the npc that its begun.
		
		i_final_nr[npc.index]=1;	//logic stuff.
		
		fl_move_speed[npc.index] = 300.0;	//Sets npc's speed to a higher value, still should be lower than a player who is running away without looking at the npc
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");	//he becomes melee.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: {crimson}I AM A GOD");	//Ego boost 9000%
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: {crimson}THY PUNISHMENT IS DEATH");	//Ego boost 9000%
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: {crimson}THE POWER OF THE MOON, IN THE PALMS OF MY HANDS");	//Ego boost 9000%
			}
		}
		
		
		b_Are_we_reloading[npc.index]=true;
		
		npc.m_flReloadIn = GetGameTime(npc.index);
		
		fl_attack_timeout[npc.index] =GetGameTime(npc.index)+ 1.0;
		
		float charge=6.0;	//Charge time of blitzlight MUST be set here
		float timer=20.0;	//Duration of blitzlight MUST be set here
		fl_TheFinalCountdown2[npc.index] = GetGameTime(npc.index)+timer+charge+1.0;	//Duration of the whole thing. should be the same number as duration of blitzlight invoke
		BlitzLight_Invoke(npc.index, timer, charge);	//timer is duration, charge is charge time. || Blitzlight invoke, thanks to spooks permission I ported the ability over for blitz
		b_BlitzLight[npc.index]=true;						//Blitzlight logic, blocks scaling, blocks other things.
		
		
		npc.m_flNextTeleport = GetGameTime(npc.index) + 10.0;	//This value gets change on reset.
		
		fl_LifelossReload[npc.index] = 1.0;				//Used to make sure npc is in melee.
		
		npc.m_flReloadIn = GetGameTime(npc.index) + (timer+charge+1.0);	//turns off melee logic when blitzlight ends.
		
		npc.m_flRangedArmor = 0.1;	//Sets ranged armour to 90%, however melee still does normal damage, so if somehow is mad enough as melee to duel blitz in this state, they are free to do so.
		
		npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
	}
	if(i_currentwave[npc.index]>=45 && !b_allies[npc.index] && (b_life2[npc.index] || b_life3[npc.index]))
	{	//This system is used to spawn minnions depending on wave and life. Also almost everything here is hard coded to waves meaning they won't on other waves.
		b_allies[npc.index]=true;
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		if(i_currentwave[npc.index]==45)
		{
			CPrintToChatAll("{crimson}Blitzkrieg{default}: The minnion's have joined the battle.");
		}
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		int heck;
		int spawn_index;
		heck= maxhealth;
		maxhealth=RoundToNearest((heck/10)*zr_smallmapbalancemulti.FloatValue);
		if(i_currentwave[npc.index]==45)	//Only spwans if the wave is 45.
		{
			spawn_index = NPC_CreateByName("npc_alt_combine_soldier_deutsch_ritter", npc.index, pos, ang, GetTeam(npc.index));
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			if(spawn_index > MaxClients)
			{
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
			spawn_index = NPC_CreateByName("npc_alt_medic_supperior_mage", npc.index, pos, ang, GetTeam(npc.index));
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			if(spawn_index > MaxClients)
			{
			
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
		if(i_currentwave[npc.index]>=60)	//Only spawns if the wave is 60 or beyond.
		{
			CPrintToChatAll("{crimson}Blitzkrieg{default}: The siblings have been reborn.");
			maxhealth=RoundToNearest((heck/5)*zr_smallmapbalancemulti.FloatValue);	//mid squishy

			spawn_index = NPC_CreateByName("npc_alt_donnerkrieg", npc.index, pos, ang, GetTeam(npc.index), "raid_ally");
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			if(spawn_index > MaxClients)
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Ay, Donnerkrieg, how ya doin?");
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
			maxhealth=RoundToNearest((heck/2)*zr_smallmapbalancemulti.FloatValue);	//the tankiest
			spawn_index = NPC_CreateByName("npc_alt_schwertkrieg", npc.index, pos, ang, GetTeam(npc.index), "raid_ally");
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			if(spawn_index > MaxClients)
			{
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
	}
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	npc.PlayDeathSound();
	
//	Music_RoundEnd(entity);


	RaidModeTime += 45.0;
	
	int closest = npc.m_iTarget;

	g_f_blitz_dialogue_timesincehasbeenhurt = GetGameTime()+20.0;
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
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
		
	if(IsValidClient(closest) && !b_timer_lose[npc.index])
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Nooo, this cannot be {yellow}%N{default} you won, {red}this time", closest);
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: It seems I have failed {yellow}%N{default} you survived {red}this time", closest);
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Until next time {yellow}%N{red} until next time...", closest);
			}
			case 4:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: What, HOW, {yellow}%N{default} How did you beat me before my army arrived, {crimson}no matter{default} theres always next time...", closest);
			}
		}
	}
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;

	Citizen_MiniBossDeath(entity);
}
static float fl_blitz_punish_dmg;
public void Blitzkrieg_Punishment_Invoke(int ref, int enemy, float dist)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		Blitzkrieg npc = view_as<Blitzkrieg>(entity);
		float Time=2.5;	//how long before kaboom
		
		if(!b_BlitzLight[entity])
			fl_blitz_ioc_punish_timer[entity][enemy]=GetGameTime(npc.index)+5.0;
		else
		{
			fl_blitz_ioc_punish_timer[entity][enemy]=GetGameTime(npc.index)+1.0;	//Punishment be upon thee
			Time = 0.75;
		}
		fl_blitz_punish_dmg=25.0*i_HealthScale[npc.index];
		
		float Range = 200.0;
		float vecTarget[3];
		WorldSpaceCenter(enemy, vecTarget );
		vecTarget[2] += 1.0;
		
		if(dist > 4000000 && !b_BlitzLight[entity])
		{
			Time = 1.5;
		}
		else
		{
			vecTarget[0]+=GetRandomInt(-100, 100);	//Randomize the place where it hits.
			vecTarget[1]+=GetRandomInt(-100, 100);
		}
		
		
		
		
		
		int color[4];
		color[0] = 145;
		color[1] = 47;
		color[2] = 47;
		color[3] = 255;
		float UserLoc[3];
		GetAbsOrigin(entity, UserLoc);
		
		UserLoc[2]+=75.0;
		
		int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
					
		TE_SetupBeamPoints(vecTarget, UserLoc, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
		TE_SendToAll();

		EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vecTarget);
		
		Handle data;
		CreateDataTimer(Time, Smite_Timer_Blitz, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, Range); // Range
		WritePackCell(data, ref);
		WritePackCell(data, enemy);
		
		spawnRing_Vectors(vecTarget, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, Time, 6.0, 0.1, 1, 1.0);
	}
}
static float fl_punish_dmg_multi[MAXENTITIES + 1];
public Action Smite_Timer_Blitz(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	int target = ReadPackCell(data);
	
	for(int player=1 ; player<= MAXENTITIES ; player++)
	{
		if(IsValidClient(player))
		{
			fl_punish_dmg_multi[player] = 0.5;	//damage is halfed for the non punisher initiator
		}
	}
	if(IsValidClient(target))
	{
		fl_punish_dmg_multi[target] = 1.0;		//full damage for the initiator
	}
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Explode_Logic_Custom(0.0, client, client, -1, startPosition, Ionrange , _ , _ , true, _, _, 1.0, Blitzkrieg_Punishment_Tweak);	//this moreso acts like a distance trace
	
	TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 900.0;
	startPosition[2] += -200;
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	
	position[2] = startPosition[2] + 50.0;
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	return Plugin_Continue;
}
void Blitzkrieg_Punishment_Tweak(int entity, int victim, float damage, int weapon)	//while this function actually does the damage
{
	if(IsValidEntity(victim))
	{
		SDKHooks_TakeDamage(victim, entity, entity, (fl_blitz_punish_dmg*fl_punish_dmg_multi[victim])*zr_smallmapbalancemulti.FloatValue, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
	}
}
public void Blitzkrieg_IOC_Invoke(int ref, int enemy)	//Ion cannon from above
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=125.0; // /29 for duartion till boom
		static float IOCDist=350.0;
		static float IOCdamage=100.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		Blitzkrieg_IonAttack(data);
	}
}
public Action Blitzkrieg_DrawIon(Handle Timer, any data)
{
	Blitzkrieg_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void Blitzkrieg_DrawIonBeam(float startPosition[3], const int color[4])
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

	public void Blitzkrieg_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		float Ionrange = ReadPackFloat(data);
		float Iondamage = ReadPackFloat(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client) || b_NpcHasDied[client])
		{
			delete data;
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
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {145, 47, 47, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;

		delete data;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackFloat(nData, Ionrange);
		WritePackFloat(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, Blitzkrieg_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
		else	//Normal Ioc Damge on wave
		{

			startPosition[2] += 25.0;
			Explode_Logic_Custom((100.0*RaidModeScaling)*zr_smallmapbalancemulti.FloatValue, client, client, -1, startPosition, 400.0 , _ , _ , true);
			startPosition[2] -= 25.0;
				
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {145, 47, 47, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {145, 47, 47, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {145, 47, 47, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {145, 47, 47, 255}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < 500.0)
					{
						Client_Shake(i, 0, 10.0, 25.0, 7.5);
					}
				}
			}
		}
}

  /////////////////////
 ///BlitzLight Core///
/////////////////////

static float tickCountScaling[MAXENTITIES];
static float tickCountClient[MAXENTITIES];

static int TickCount_Stage1[MAXENTITIES];
static float Stage1_Multi[MAXENTITIES];

static int TickCount_Stage2[MAXENTITIES];
static float Stage2_Multi[MAXENTITIES];

static int TickCount_Stage3[MAXENTITIES];
static float Stage3_Multi[MAXENTITIES];

public Action BlitzLight_TBB_Tick(int client)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(client);
	
	if(!IsValidEntity(client) || b_BlitzLight_stop[npc.index])
	{
		tickCountClient[npc.index] = 0.0;
		tickCountScaling[npc.index] = 0.0;
		SDKUnhook(client, SDKHook_Think, BlitzLight_TBB_Tick);
		b_BlitzLight[npc.index] = false;
	}
	int entity = EntRefToEntIndex(npc.index);
	
	Stage1_Multi[client]=tickCountClient[client]/TickCount_Stage1[client]; 
	if(Stage1_Multi[client] >=1.0)
	{
		Stage1_Multi[client] = 1.0;
	}
	
	Stage2_Multi[client]=tickCountClient[client]/TickCount_Stage2[client];
	if(Stage2_Multi[client] >=1.0)
	{
		Stage2_Multi[client] = 1.0;
	}
	
	Stage3_Multi[client]=tickCountClient[client]/TickCount_Stage3[client];
	if(Stage3_Multi[client] >=1.0)
	{
		Stage3_Multi[client] = 1.0;
	}
		
	BlitzLight_DMG[npc.index]=BlitzLight_DMG_Base[npc.index]*(1+Stage3_Multi[client]) / TickrateModify;				//damage scales on duration.

	BlitzLight_DMG_Radius[npc.index]=BlitzLight_Scale3[npc.index]*Stage3_Multi[client]+1.0;
	
	if(fl_BlitzLight_Throttle[npc.index] < GetGameTime(npc.index))
	{
		fl_BlitzLight_Throttle[npc.index]=GetGameTime(npc.index) + 0.04;
		if(IsValidEntity(entity))
		{
			if (BlitzLight_Duration_notick[npc.index] > GetGameTime(npc.index))	//If current active time is more than charge, then its "charging"
			{
				BlitzLight_Beams(entity, true);
			}
			else
			{
				BlitzLight_Beams(entity, false);
			}
		}
	}
	tickCountClient[npc.index]++;
	
	return Plugin_Continue;

}
public void BlitzLight_Invoke(int ref, float timer, float charge)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(ref);
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float vecTarget[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		float smallmap = zr_smallmapbalancemulti.FloatValue;	//Nerf's blitzlight on small maps. this is set in another plugin from this one
		BlitzLight_Duration[npc.index] = timer*smallmap;
		BlitzLight_ChargeTime[npc.index] = charge;
		BlitzLight_Scale1[npc.index] = 200.0*smallmap;	//Best to do the scales in sets of numbers.
		BlitzLight_Scale2[npc.index] = 400.0*smallmap;
		BlitzLight_Scale3[npc.index] = 600.0*smallmap;
		BlitzLight_DMG_Base[npc.index] = 80.0*smallmap;	//Damage is dealt 10 times a second. The longer blitzlight is active the more it deals, once "stage 3" is reached it deals 2x damage
		BlitzLight_Radius[npc.index] = 200.0*smallmap;	//Best to set radius as the same different of numbers when going up from scale 1, to 2. in this case scale goes up by 200 each time, so radius is 200.
		BlitzLight_Duration_notick[npc.index] = GetGameTime(npc.index) + charge;	//Charge time.
		
		float time=BlitzLight_Duration[npc.index]+charge;	//Another value in a temp timer.
		BlitzLight_Duration[npc.index]*=TickrateModifyInt;	//Converts the duration into ticks
		
		//Convert the time into tick amount
		TickCount_Stage1[npc.index]=RoundToFloor(((charge/2)+charge)*TickrateModifyInt);
		TickCount_Stage2[npc.index]=RoundToFloor(((timer/3)+charge)*TickrateModifyInt);
		TickCount_Stage3[npc.index]=RoundToFloor((((timer/3)*2)+charge)*TickrateModifyInt);

		if(b_lost)
		{
			BlitzLight_Scale1[npc.index] *=2.5;
			BlitzLight_Scale2[npc.index] *=2.5;
			BlitzLight_Scale3[npc.index] *=2.5;
			BlitzLight_DMG_Base[npc.index] *=2.5; 
			BlitzLight_Radius[npc.index] *=2.5;
		}
		
		EmitSoundToAll(BLITZLIGHT_ACTIVATE);
		
		CreateTimer(time, BlitzLight_TBB_Timer, ref, TIMER_FLAG_NO_MAPCHANGE);
		SDKHook(ref, SDKHook_Think, BlitzLight_TBB_Tick);
		
	}
	
}
static void Blitzkrieg_Light_Pilair_Proper_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
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
public Action BlitzLight_TBB_Timer(Handle timer, int client)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(client);
	if(!IsValidEntity(client))
		return Plugin_Continue;

	b_BlitzLight_stop[npc.index] = true;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

void BlitzLight_Beams(int entity, bool charging = true)
{
	
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	if (!IsValidEntity(entity) || !b_BlitzLight[npc.index])
		return;
		
	float UserLoc[3], UserAng[3];
	GetAbsOrigin(entity, UserLoc);
	
	UserAng[0] = 0.0;
	UserAng[1] = BlitzLight_Angle[npc.index];
	UserAng[2] = 0.0;
	
	if (charging)
	{
		BlitzLight_Angle[npc.index] += 2.5;
	}
	else
	{
		BlitzLight_Angle[npc.index] += 1.25;
	}
	
	if (BlitzLight_Angle[npc.index] >= 360.0)
	{
		BlitzLight_Angle[npc.index] = 0.0;
	}
	
	for (int i = 0; i < 3; i++)
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:
			{
				distance = 1.0+BlitzLight_Scale1[npc.index]*Stage1_Multi[npc.index];
			}
			case 1:
			{
				distance = 1.0+BlitzLight_Scale2[npc.index]*Stage2_Multi[npc.index];
				angMult = -1.0;
			}
			case 2:
			{
				distance = 1.0+BlitzLight_Scale3[npc.index]*Stage3_Multi[npc.index];
				angMult = 1.0;
			}
		}
		
		for (int j = 0; j < 8; j++)
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
				BlitzLight_Spawn8(endLoc, BlitzLight_Radius[npc.index], entity);
			}
			else
			{
				BlitzLight_SpawnBeam(entity, false, endLoc);
			}
		}
	}
	if(!charging)
	{
		BlitzLight_DealDamage(npc.index);
	}

}

public void BlitzLight_Spawn8(float startLoc[3], float space, int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	float ticks = (tickCountClient[npc.index] / BlitzLight_Duration[npc.index]);
	for (int i = 0; i < 8; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(i) * 45.0;
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, space);
		AddVectors(startLoc, Direction, endLoc);
		BlitzLight_SpawnBeam(entity, true, endLoc, ticks);
	}
	int color[4];
	color[0] = 0;
	color[1] = 180;
	color[2] = 60;
	color[3] = RoundFloat(255.0 * ticks);
	
	TE_SetupBeamRingPoint(startLoc, space * 2.0, space * 2.0, BlitzLight_Beam, BlitzLight_Beam, 0, 1, 0.1, 2.0, 0.1, color, 1, 0);
	TE_SendToAll();
}

void BlitzLight_SpawnBeam(int entity, bool charging, float beamLoc[3], float alphaMod = 1.0)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	int color[4];
	color[3] = RoundFloat(255.0 * alphaMod);
	
	float skyLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
	
	if (charging)
	{
		color[0] = 25;
		color[1] = 205;
		color[2] = 255;
		
		TE_SetupBeamPoints(skyLoc, beamLoc, BlitzLight_Beam, BlitzLight_Beam, 0, 1, 0.1, 2.0, 2.1, 1, 0.1, color, 1);
		TE_SendToAll();
	}
	else
	{
		if (!IsValidEntity(entity))
			return;
		
		color[0] = 145;
		color[1] = 47;
		color[2] = 47;
		
		Blitzkrieg_Light_Pilair_Proper_Clip({24.0,24.0,24.0}, 300.0, beamLoc);
		
		skyLoc[0] = beamLoc[0];
		skyLoc[1] = beamLoc[1];
		skyLoc[2] = 9999.0;
		TE_SetupBeamPoints(skyLoc, beamLoc, BlitzLight_Beam, BlitzLight_Beam, 0, 1, 0.1, 10.0, 10.1, 1, 0.1, color, 1);
		TE_SendToAll();
		TE_SetupBeamRingPoint(beamLoc, 0.0, BlitzLight_Radius[npc.index] * 2.0, BlitzLight_Beam, BlitzLight_Beam, 0, 1, 0.33, 2.0, 0.1, color, 1, 0);
		TE_SendToAll();
		
	}
}

static int i_BlitzLight_dmg_throttle[MAXENTITIES];
public void BlitzLight_DealDamage(int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	if (!IsValidEntity(entity))
			return;

	float beamLoc[3];
	GetAbsOrigin(entity, beamLoc);
	
		
	if(i_BlitzLight_dmg_throttle[npc.index] > 2)	//do damage 10 times a second.
	{
		i_BlitzLight_dmg_throttle[npc.index] = 0;	//damage throttle
		float dmg_pen = 1.0;
		if(i_currentwave[npc.index]>=60)
		{
			dmg_pen = 1.75;	//A slight buff to damage on wave 60
		}
		Explode_Logic_Custom((BlitzLight_DMG[npc.index]) * dmg_pen, entity, entity, -1, beamLoc, BlitzLight_DMG_Radius[npc.index]*1.25 , _ , _ , true, _, _, 10.0, Blitzlight_Shake_Client);
		//CPrintToChatAll("dmg: %fl", BlitzLight_DMG[npc.index]);
		//CPrintToChatAll("radius: %fl", 1.25*BlitzLight_DMG_Radius[npc.index]);
		beamLoc[2]+=10;
		spawnRing_Vector(beamLoc, BlitzLight_DMG_Radius[npc.index]*2*1.25, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.1, 1.0, 0.1, 1);
	}
	i_BlitzLight_dmg_throttle[npc.index]++;
}
public void Blitzlight_Shake_Client(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
		Client_Shake(victim, 0, 8.0, 8.0, 0.1);
}
static void spawnRing_Vector(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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
static float fl_blitz_rocket_dmg[MAXENTITIES];
static float fl_last_rocket_time[MAXENTITIES];

static void FireBlitzRocket(int client, float vecTarget[3], float rocket_damage, float rocket_speed, float model_scale = 1.0) //No defaults, otherwise i cant even judge.
{
	if(rocket_speed>3000)
		rocket_speed=3000.0;
	Blitzkrieg npc = view_as<Blitzkrieg>(client);
	float vecForward[3], vecSwingStart[3], vecAngles[3];
	npc.GetVectors(vecForward, vecSwingStart, vecAngles);
										
	GetAbsOrigin(npc.index, vecSwingStart);
	vecSwingStart[2] += 54.0;
										
	MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
										
										
	
	vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
	vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
	vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;
										
	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		fl_blitz_rocket_dmg[entity] = rocket_damage;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetTeam(entity, GetTeam(npc.index));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
										
		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);

		fl_last_rocket_time[entity] = GetGameTime();

		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}

		if(model_scale != 1.0)
		{
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
		}
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24); //our savior
		Set_Projectile_Collision(entity); //If red, set to 27
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rocket_Blitz_DHook_RocketExplodePre); //*yawn*
		
		SDKHook(entity, SDKHook_StartTouch, Rocket_Blitz_StartTouch);
	}
}

public MRESReturn Rocket_Blitz_DHook_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Don't even think about it mate
}

public void Rocket_Blitz_StartTouch(int entity, int target)
{
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}

		float DamageDeal = fl_blitz_rocket_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= 2.0;

		
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_BLITZ_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_BLITZ_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_BLITZ_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_BLITZ_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_BLITZ_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
	   	}

		float time = GetGameTime() - fl_last_rocket_time[entity];

		if(time<=2.0 && time>=0.0)
		{			
			if(time<1.0)
				time=1.0;	//minimum dmg limiter
			float ratio = time/2.0;
			DamageDeal *=ratio;
		}

		SDKHooks_TakeDamage(target, owner, owner, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket

	}
	switch(GetRandomInt(1,4)) 
	{
		case 1:EmitSoundToAll(SOUND_BLITZ_IMPACT_CONCRETE_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
		case 2:EmitSoundToAll(SOUND_BLITZ_IMPACT_CONCRETE_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
		case 3:EmitSoundToAll(SOUND_BLITZ_IMPACT_CONCRETE_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
		
		case 4:EmitSoundToAll(SOUND_BLITZ_IMPACT_CONCRETE_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
	}
	DataPack pack = new DataPack();
	pack.WriteFloat(ProjectileLoc[0]);
	pack.WriteFloat(ProjectileLoc[1]);
	pack.WriteFloat(ProjectileLoc[2]);
	pack.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack);
	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);
	TE_ParticleInt(g_particleBLITZ_IMPACTTornado, pos1);
	TE_SendToAll();
	RemoveEntity(entity);
}



void BlitzKriegSelfDefense(Blitzkrieg npc, float gameTime)
{
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
							float meleedmg;
							meleedmg = 12.5 * i_HealthScale[npc.index];
							SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);	
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
								Custom_Knockback(npc.index, target, 450.0, true); 
						}
					}
				}
				if(PlaySound)
				{
					npc.PlayPullSound();
				}
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeHitSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.3;

					npc.m_flNextMeleeAttack = gameTime + 0.85;
				}
			}
		}
	}
}		
public void Raidmode_Blitzkrieg_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;

}
static void Spawn_Blitz_Army(int blitz, char[] plugin_name, int health = 0, int count, bool outline = false)
{
	if(GetTeam(blitz) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(blitz, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(blitz, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(blitz));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 4);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 4);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Outlined = outline;
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.5;
	enemy.ExtraDamage = 2.5;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(blitz);
	for(int i; i<count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += count;	// FIXME
}