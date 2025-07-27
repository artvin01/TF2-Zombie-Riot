#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"mvm/mvm_robo_stun.wav",
	"mvm/mvm_bomb_explode.wav",
};

static const char g_DeathSounds1[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
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

//Rocket launcher stuff


#define BLITZLIGHT_ACTIVATE	  "vo/medic_sf13_influx_big02.mp3"
#define BLITZLIGHT_ATTACK	  "mvm/ambient_mp3/mvm_siren.mp3"


static float fl_rocket_base_dmg;
static int gExplosive1;
static bool b_winline;
static float fl_npc_basespeed;
static int g_particleBLITZ_IMPACTTornado;
static bool b_buffed_blitz;
static bool b_pureblitz;
float g_f_blitz_dialogue_timesincehasbeenhurt;
bool g_b_item_allowed;
bool g_b_donner_died;
bool g_b_schwert_died;
bool g_b_angered;
static bool b_musicprecached;
static bool b_lost;
static bool b_timer_lose;
static float fl_base_raidmodescaling;


  ///////////////////////
 ///BlitzLight Floats///
///////////////////////

static float BlitzLight_Scale1;
static float BlitzLight_Scale2;
static float BlitzLight_Scale3;
static float BlitzLight_DMG_Base;
static float BlitzLight_Radius_Base;


static int NPCId;

public void Blitzkrieg_OnMapStart()
{
	g_f_blitz_dialogue_timesincehasbeenhurt=0.0;
	g_b_item_allowed=false;
	g_b_donner_died=false;
	g_b_schwert_died=false;
	g_b_angered=false;
	b_lost=false;

	b_musicprecached = false;

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Blitzkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_blitzkrieg");
	strcopy(data.Icon, sizeof(data.Icon), "blitzkrieg");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

int RaidBoss_Blitzkrieg_ID()
{
	return NPCId;
}

void PrecacheBlitzMusic()
{
	if(b_musicprecached)
		return;
	
	b_musicprecached = true;
	PrecacheSoundCustom("#zombiesurvival/altwaves_and_blitzkrieg/music/dm_loop1.mp3");
	PrecacheSoundCustom("#zombiesurvival/altwaves_and_blitzkrieg/music/blitzkrieg_ost.mp3");
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_PullSounds);
	PrecacheSoundArray(g_DeathSounds1);
	PrecacheSoundArray(g_DefaultLaserLaunchSound);

	PrecacheBlitzMusic();

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
	
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheSound("player/flow.wav");
	
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_horn.wav");
	PrecacheSound("mvm/mvm_tank_explode.wav");
	
	PrecacheSound(BLITZLIGHT_ACTIVATE, true);
	PrecacheSound(BLITZLIGHT_ATTACK, true);
	
	PrecacheSound("misc/halloween/gotohell.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Blitzkrieg(vecPos, vecAng, team, data);
}
methodmap Blitzkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	
	property int m_iProjectilesFired
	{
		public get()							{ return i_ammo_count[this.index]; }
		public set(int TempValueForProperty) 	{ i_ammo_count[this.index] = TempValueForProperty; }
	}
	property int m_iMaxRockets
	{
		public get()							{ return i_GunMode[this.index]; }
		public set(int TempValueForProperty) 	{ i_GunMode[this.index] = TempValueForProperty; }
	}
	property int m_iCurrentLife
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flRocketFireRate
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRocketTimeOutTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flBlitzLightAngle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flLifeLossReloadMulti
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	//[4] is used for projectiles!
	property bool m_bPrimaryReloading
	{
		public get()							{ return b_we_are_reloading[this.index]; }
		public set(bool TempValueForProperty) 	{ b_we_are_reloading[this.index] = TempValueForProperty; }
	}
	property bool m_bAlliesSummoned
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayDeathSound() {
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSoundfake() {
		int sound = GetRandomInt(0, sizeof(g_DeathSounds1) - 1);
		EmitSoundToAll(g_DeathSounds1[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.5);
	}
	public void PlayAngerSound() {
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public Blitzkrieg(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		//sm_spawn_npc npc_blitzkrieg 10000 "wave_60" 3
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
		RemoveAllDamageAddition();
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		

		npc.m_bThisNpcIsABoss = true;
		b_lost=false;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
		npc.m_iCurrentLife= 0;	//Basically tells the npc which life it currently is in
		
		RaidModeScaling = 1.0;	//default 1, this is instantly overriden the moment the npc takes damage.
		
		fl_npc_basespeed = 250.0;	//base move speed when on life 0, when npc loses a life this number is changed. also while blitz is using his melee he moves 50 hu's less
		//rocket launcher stuff
		npc.m_flRocketFireRate = 0.4;	//Base firerate of blitz, overriden once npc takes damage
		fl_rocket_base_dmg = 7.5;	//The base dmg that all scaling is done on

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		i_current_wave[npc.index]=(Waves_GetRoundScale()+1);
		if(StrContains(data, "wave_10") != -1)
		{
			i_current_wave[npc.index] = 10;
		}
		else if(StrContains(data, "wave_20") != -1)
		{
			i_current_wave[npc.index] = 20;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_current_wave[npc.index] = 30;
		}
		else if(StrContains(data, "wave_40") != -1)
		{
			i_current_wave[npc.index] = 40;
		}
		
		b_thisNpcIsARaid[npc.index] = true;
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
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
		
		npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-350.0, true);
		SetVariantString(BLITZKRIEG_PUNISHMENT_SHIELD_MULTI);
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 55, 30, 30, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 255, 0, 0, 255);
		
		SetEntityRenderColor(npc.m_iWearable5, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 100, 100, 125);
		
		//IDLE
		npc.m_flSpeed = fl_npc_basespeed;
		
		
		npc.m_iProjectilesFired = 0;			//Checks how many rockets have been fired by blitz's RL.
		npc.m_flLifeLossReloadMulti= 1.0;		//how fast blitz reloads when ammo is depleted, this number multiples a base 10 number. Basically: 10*npc.m_flLifeLossReloadMulti
		npc.m_iMaxRockets = 20;		//blitz's max ammo, this number changes on lifeloss.

		b_buffed_blitz = StrContains(data, "hyper") != -1;	//mostly for testing. buuuut....
		if(FindInfoTarget("zr_hyperblitz")) //if the map asks for hyperblitz, force hyperblitz.
		{
			b_buffed_blitz = true;
		}
		b_pureblitz = false;
		if(!b_buffed_blitz)
		{
			b_buffed_blitz = StrContains(data, "blitzmayhem") != -1;
			if(b_buffed_blitz)
			{
				strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "TRUE BLITZKRIEG");
				b_pureblitz = true;
				switch(GetRandomInt(0,7))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 으하하하하하!!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 전부 다 죽여버린다!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{crimson}%s{default}: 이게 바로 순수한 힘이다!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 3:
					{
						CPrintToChatAll("{crimson}%s{default}: 넌 그게 끝이라고 생각한거냐!?", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 4:
					{
						CPrintToChatAll("{crimson}%s{default}: 이 쥐새끼같은 놈아!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 5:
					{
						CPrintToChatAll("{crimson}%s{default}: 이리 기어와라, 보잘것 없는 놈들아!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 6:
					{
						CPrintToChatAll("{crimson}%s{default}: 이것이 루이나와 엑스피돈사의 진정함 힘이다!!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 7:
					{
						CPrintToChatAll("{crimson}%s{default}: 여기서 다 꺼져버려라!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 8:
					{
						CPrintToChatAll("{crimson}%s{default}: 지금부터 너와 나의 진짜 전격전이다!!!", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/blitzkrieg_ost.mp3");
				music.Time = 209;
				music.Volume = 1.6;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Great Machine from the big Three");
				strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
				Music_SetRaidMusic(music);
			}
		}
		else
		{
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/altwaves_and_blitzkrieg/music/blitzkrieg_ost.mp3");
			music.Time = 209;
			music.Volume = 1.6;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Great Machine from the big Three");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);
		}

		if(!b_buffed_blitz)
			b_buffed_blitz = AlternativeExtraLogic();

		if(b_buffed_blitz && !b_pureblitz)
		{
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Hyper Blitzkrieg");
			if(i_current_wave[npc.index] <=10)
			{
				RaidModeScaling *=1.5;
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 흐흐흐..", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 준비 되셨나?", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else if(i_current_wave[npc.index] <=20)
			{
				RaidModeScaling *=1.5;
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 흐흐흐, 널 죽일 기회가 또 한 번 생긴것 같군.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 이전엔 살아나갔었지. 과연 지금도 살아남을 수 있을까?", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else if(i_current_wave[npc.index] <=30)
			{
				RaidModeScaling *=1.5;
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 아무래도 내가 뭔갈 좀 알려줘야 할 것 같은데... 저 달을 봐라...", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 넌 정말 끈기 있는 놈이군. 안 그래?", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 여기서 모든게 {crimson}끝날거다. {default}이제 도망갈 곳도 없지!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 이전보다 더욱 짜증나는 쥐새끼들이 되었어. 그렇지 않나?", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{crimson}%s{default}: 이제 내 리미터도 전부 해제되었다.{crimson} 준비 됐나?{default}.", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
		}
		
		bool final = StrContains(data, "final_item") != -1;
		fl_base_raidmodescaling = (RaidModeScaling*1.5);	//Storage for current raidmode scaling to use for calculating blitz's health scaling.
		if(i_current_wave[npc.index]<=20)
		{
			fl_base_raidmodescaling *= 2.0;	//blitz is quite weak on wave 15, and 30
		}
		else if(i_current_wave[npc.index]>=40)
		{
			if(!b_buffed_blitz)
				fl_base_raidmodescaling /= 3.0;	//blitz is quite scary on wave 60, so nerf him a bit
		}
		if(i_current_wave[npc.index]>40 && !final)
		{
			RaidModeTime = GetGameTime(npc.index) + 900.0;	//tripple the time for waves beyond 60!
		}
		if(final)
		{
			g_b_item_allowed=true;
		}
		else
		{
			npc.m_bDissapearOnDeath = true;
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
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;	//Block's KB from certain abilities. mainly blitzlight
		
		npc.m_bPrimaryReloading = false;		//Tell's the npc that it is indeed reloading and that its a good idea to switch to melee. blocks certain abilities, also is used to block the RJ during blitzlight.
//		npc.PlayMusicSound();
		npc.StartPathing();
		
		npc.m_flCharge_Duration = 0.0;					//during blitzlight, blitz's teleport gets replaced with a dash.
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		
		b_timer_lose = false;
		
		ApplyStatusEffect(npc.index, npc.index, "Ruina Battery Charge", 9999.0);
		fl_ruina_battery_max[npc.index] = 1000000.0; //so high itll never be reached.
		fl_ruina_battery[npc.index] = 0.0;
		
		npc.m_bAlliesSummoned = false;
		
		i_GunAmmo[npc.index] = 0;

		if(StrContains(data, "test") != -1)
			RaidModeTime = FAR_FUTURE;
		

		Citizen_MiniBossSpawn();
		return npc;
		
		/*
		Thanks to Spookmaster for allowing me to port over his "Holy Moonlight" that his dokmed raidboss uses.
		*/
	}
}


static void ClotThink(int iNPC)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(iNPC);
	
	CheckChargeTimeBlitzkrieg(npc);
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;

			if(b_pureblitz)
			{
				switch(GetRandomInt(0,4))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 힘드냐? 힘들면 그냥 죽어!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 이제 널 어떻게 요리해야할까? {crimson}흐으으으음?", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{crimson}%s{default}: 멍청한 인간들아, {crimson}파멸을 맞이해라!!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 3:
					{
						CPrintToChatAll("{crimson}%s{default}: 연합의 진정한 힘이{crimson} 드디어 승리했도다!!", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 4:
					{
						CPrintToChatAll("{crimson}%s{crimson}: 어차피 끝날건데 뭐 이리 도망을 치는거냐!!!!", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else if(b_buffed_blitz)
			{
				switch(GetRandomInt(0,4))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 너희 유기체들은 살아남으려면 산소가 필요했었지? 우린 필요없다. 너와 우린 차원이 다른 존재지.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 그래, {crimson}혼자 남는 기분이 어떠냐?", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{crimson}%s{default}: 넌 화력도, 실력도 없다. {crimson}항복해라...", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 3:
					{
						CPrintToChatAll("{crimson}%s{default}: {crimson}네 죽음이 다가오고 있다...", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 4:
					{
						CPrintToChatAll("{crimson}%s{default}: 네 친구들은 이미{crimson} 우리와{default} 함께 한다... {crimson} 너만이 남았지...", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,4))
				{
					case 0:
					{
						CPrintToChatAll("{crimson}%s{default}: 너 혼자 날 상대하겠다고? 어이가 없군.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{crimson}%s{default}: 우리 기계의 승리가 또 다시 드리우고 있군...", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{crimson}%s{default}: 희망조차 없는 놈이군.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 3:
					{
						CPrintToChatAll("{crimson}%s{default}: {crimson}넌 죽음을 피할 수 없다...", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 4:
					{
						CPrintToChatAll("{crimson}%s{default}: 네 친구들은 이미{crimson} 우리와{default} 함께 한다... {crimson} 너만이 남았지...", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
		}
	}
	
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND && !b_winline)
	{
		b_timer_lose = true;

		b_winline=true;
		
		if(b_pureblitz)
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
				{
					CPrintToChatAll("{crimson}%s{default}: 다시 해볼 생각이냐? 흐으음?", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 벌써 포기하겠다고? 쓰레기 같은 것들!", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
		else if(b_buffed_blitz)
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
				{
					CPrintToChatAll("{crimson}%s{default}: 이제 {crimson}다른 미개한 놈들과{default} 맞설 차례군.", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 왠만해서는 살려두려고 했지만, {crimson}넌 예외다.", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
		else
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}너희들은 전부 제거되었다{default}.", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 이 가망 없는 쓰레기들!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}원시시대만도 못 한 것들!{default}.", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 기계가 다시 한 번 승리했다.", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	} 

	if(RaidModeTime < GetGameTime() && !b_lost)	//warp
	{
		
		ZR_NpcTauntWinClear();

		int MaxHealth = ReturnEntityMaxHealth(npc.index);

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
		BlitzLight_Invoke(npc.index, timer, charge);

		npc.m_iMaxRockets =6969;	//Buff's the clipsize

		i_current_wave[npc.index] = 40;

		b_timer_lose = true;

		b_lost=true;
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}%s{default}: {crimson}너무 느리군.{default} 이제 나의 수하들이 집결했다...", NpcStats_ReturnNpcName(npc.index, true));
			}
			case 2:
			{
				CPrintToChatAll("{crimson}%s{default}: 선택해라, {crimson} 항복,{default} 아니면 죽음.", NpcStats_ReturnNpcName(npc.index, true));
			}
			case 3:
			{
				CPrintToChatAll("{crimson}%s{default}: 너희들은 내 수하로 만들면 {crimson}정말 완벽한{default} 존재들이 될 거야...", NpcStats_ReturnNpcName(npc.index, true));
			}
		}
	}
	
	if(!IsValidEntity(npc.m_iWearable6))
	{
		npc.m_iWearable6 = npc.EquipItemSeperate("models/buildables/sentry_shield.mdl",_,_,_,-350.0,true);
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
	
	//if the raid is a duo. show secondary hud
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	//no more raid hud exists, but I exist, make raid hud mine
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
	
	if(npc.m_bPrimaryReloading)	//do melee run on reload/blitzlight
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
			
			if(npc.m_iCurrentLife==0)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_rocketlauncher.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(npc.m_iCurrentLife==1)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(npc.m_iCurrentLife==2)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			if(npc.m_iCurrentLife>=3)
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
	
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleAlertSound();
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	
	float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
	
	//Predict their pos.
	if(flDistanceToTarget < npc.GetLeadRadius()) {
		npc.SetGoalVector(vPredictedPos);
	} else {
		npc.SetGoalEntity(PrimaryThreatIndex);
	}
	npc.StartPathing();
	
	if(fl_BEAM_DurationTime[npc.index] <= GetGameTime(npc.index) && i_GunAmmo[npc.index] == 1)	//moved the reset due to the funny clot damaged only being called when damaged
	{	//Resets the npc to a base state after blitzlight is used.
		i_GunAmmo[npc.index] = 2;
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");	//The thing everyone fears, the airstrike.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_bPrimaryReloading=false;	
		npc.m_flReloadIn = GetGameTime(npc.index);
		fl_npc_basespeed = 300.0;
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
		
		npc.m_iMaxRockets = (b_buffed_blitz ? 200 : 100);

		npc.m_flRocketTimeOutTimer = GetGameTime(npc.index)+1.0;
		
		npc.m_flLifeLossReloadMulti = 0.3;
		
		npc.m_flRangedArmor = 1.0;
		
	}
	//emits blitzlight attack sound.
	if(fl_BEAM_ChargeUpTime[npc.index] <= GetGameTime(npc.index) && fl_BEAM_DurationTime[npc.index] > GetGameTime(npc.index))
	{
		fl_BEAM_ChargeUpTime[npc.index] = FAR_FUTURE;
		EmitSoundToAll(BLITZLIGHT_ATTACK);
		
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 100, _, 0.8, 60);
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 100, _, 0.8, 60);
		
		npc.PlayLaserLaunchSound();
	}
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		if(fl_BEAM_DurationTime[npc.index] < GetGameTime(npc.index))	//this checks if the npc is in blitzlight, if it is use dash instead of teleport.
		{
			float Max_Dist = (b_buffed_blitz ? 1000.0 : 500.0);
			if(npc.m_flNextTeleport < GetGameTime(npc.index) && flDistanceToTarget > (125.0 * 125.0) && flDistanceToTarget < (Max_Dist * Max_Dist))
			{
				static float flVel[3];
				GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);

				if (flVel[0] >= 190.0)
				{
					npc.FaceTowards(vecTarget, 6000.0);
					npc.m_flNextTeleport = GetGameTime(npc.index) + (b_buffed_blitz ? 25.0 : 30.0);
					float Tele_Check = GetVectorDistance(vPredictedPos, VecSelfNpc);
					
					if(Tele_Check > 120.0)
					{
						float start_offset[3]; WorldSpaceCenter(npc.index, start_offset);
						
						bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
						if(Succeed)
						{
							npc.PlayTeleportSound();
							float end_offset[3];
							
							float effect_duration = 0.25;
							WorldSpaceCenter(npc.index, end_offset);
							
							for(int help=1 ; help<=8 ; help++)
							{	
								Lanius_Teleport_Effect(RUINA_BALL_PARTICLE_RED, effect_duration, start_offset, end_offset);
								start_offset[2] += 12.5;
								end_offset[2] += 12.5;
							}
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
			npc.m_flSpeed=fl_npc_basespeed;
			if(npc.m_flCharge_Duration < GetGameTime(npc.index))
			{
				if(npc.m_flCharge_delay < GetGameTime(npc.index))
				{
					int Enemy_I_See;
					Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex && flDistanceToTarget > NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0)
					{
						npc.m_flCharge_delay = GetGameTime(npc.index) + (b_buffed_blitz ? 5.0 : 7.5);
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
	if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0) && npc.m_iCurrentLife>1 && !npc.m_bPrimaryReloading && npc.m_flRocketTimeOutTimer < GetGameTime(npc.index))
	{	
		int Enemy_I_See;		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.FaceTowards(vecTarget);
			npc.FaceTowards(vecTarget);
			float projectile_speed = (300.0 * RaidModeScaling);
			if(projectile_speed>=6000.0)
				projectile_speed = 6000.0;
				
			FireBlitzRocket(npc, vecTarget, 10.0 * RaidModeScaling, projectile_speed, 1.0);
			npc.m_iAmountProjectiles += 1;
			npc.PlayRangedSound();
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15 / RaidModeScaling;
			if (npc.m_iAmountProjectiles >= npc.m_iMaxRockets)
			{
				npc.m_iAmountProjectiles = 0;
				npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 45.0 * npc.m_flLifeLossReloadMulti;
				if(npc.m_iCurrentLife>=2)
				{
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
					if(b_buffed_blitz)
					{
						switch(GetRandomInt(1, 2))
						{
							case 1:
							{
								CPrintToChatAll("{crimson}%s{default}: 널 위한 작은 선물이다, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index), Enemy_I_See);
							}
							case 2:
							{
								CPrintToChatAll("{crimson}%s{default}: 네 위를 봐라, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index), Enemy_I_See);
							}
						}
					}
					Blitzkrieg_IOC_Invoke(npc.index, Enemy_I_See);
				}
			}
		}
	}
	if(npc.m_iProjectilesFired > npc.m_iMaxRockets)	//Every x rockets npc enters a 10 second reload time that scales on lifeloss reload.
	{
		npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
		npc.m_flReloadIn = GetGameTime(npc.index) + (10.0 * npc.m_flLifeLossReloadMulti);
		npc.m_iProjectilesFired = 0;	//Resets fired rockets to 0 for when reload ends.
		npc.m_bPrimaryReloading = true;
		npc.m_flRocketTimeOutTimer = GetGameTime(npc.index) + (10.0 * npc.m_flLifeLossReloadMulti) + 1.0;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");	//Replaces current weapon with uber saw.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iChanged_WalkCycle = -1;
	}
	if(npc.m_flReloadIn <= GetGameTime(npc.index) && npc.m_bPrimaryReloading)	//fast1
	{
		npc.m_bPrimaryReloading = false;
		if(b_buffed_blitz)
		{
			npc.m_flNextRangedBarrage_Spam = 0.0;
			npc.m_iAmountProjectiles = 0;
		}
			
	}
	if(flDistanceToTarget < 10000000 && npc.m_flReloadIn <= GetGameTime(npc.index) && !npc.m_bPrimaryReloading && npc.m_flRocketTimeOutTimer <= GetGameTime(npc.index))
	{	//Blitz has infinite range and moves while firing rockets.
	
		int Enemy_I_See;		
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.m_bAllowBackWalking = true;
			//Look at target so we hit.
			npc.FaceTowards(vecTarget, 1500.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				npc.m_flSpeed = fl_npc_basespeed-50;	//50 speed slower when using rocket launcher
				//Play attack anim
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				float projectile_speed = 500.0*(1.0+(1-(Health/MaxHealth))*1.5);	//Rocket speed, scales on current health.
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
				npc.PlayMeleeSound();
				FireBlitzRocket(npc, vecTarget, fl_rocket_base_dmg * RaidModeScaling, projectile_speed, 1.0); //remove the no kb if people cant escape, or just lower the dmg
				npc.m_flNextMeleeAttack = GetGameTime(npc.index) + npc.m_flRocketFireRate;
				npc.m_iProjectilesFired++;	//Adds 1 extra rocket to the shoping list for when we go out shoping in the reload store.
				npc.m_flAttackHappens = 0.0;
			}
		}
		else
		{
			npc.m_bAllowBackWalking = false;
		}
	}
	else
	{
		npc.m_bAllowBackWalking = false;
	}
	if(npc.m_bPrimaryReloading)	//Melee logic for when we are shoping for rockets. aka reloading.
	{
		//Target close enough to hit
		BlitzKriegSelfDefense(npc, GetGameTime(npc.index));
	}
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
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));
	
	
	//Blitz's power scales off of current health. the health scaling is dependant on current stage, 1 stage being 15 waves.
	if(i_current_wave[npc.index]<=10)
	{
		RaidModeScaling = fl_base_raidmodescaling*(1.0+(1-(Health/MaxHealth)));
		npc.m_flRocketFireRate=((Health/MaxHealth)-0.4);
		if(npc.m_flRocketFireRate<=0.3)//This limits the firerate of the npc.
		{
			npc.m_flRocketFireRate=0.3;
		}
	}
	else if(i_current_wave[npc.index]<=30 && i_current_wave[npc.index]>10)	//waves 16-30 he scales with this
	{
		RaidModeScaling = fl_base_raidmodescaling*(1.0+(1-(Health/MaxHealth))*1.1);
		npc.m_flRocketFireRate=((Health/MaxHealth)-0.5);
		if(npc.m_flRocketFireRate<=0.25)//This limits the firerate of the npc.
		{
			npc.m_flRocketFireRate=0.25;
		}
	}
	else if(i_current_wave[npc.index]<=45 && i_current_wave[npc.index]>20)//waves 31-45 he scales with this
	{
		RaidModeScaling = fl_base_raidmodescaling*(1.0+(1-(Health/MaxHealth))*1.22);
		npc.m_flRocketFireRate=((Health/MaxHealth)-0.75);
		if(npc.m_flRocketFireRate<=0.075)//This limits the firerate of the npc.
		{
			npc.m_flRocketFireRate=0.075;
		}
	}
	else if(i_current_wave[npc.index]>=40)	//beyond wave 60 he scales with this
	{
		RaidModeScaling = fl_base_raidmodescaling*(1.0+(1-(Health/MaxHealth))*1.3);
		npc.m_flRocketFireRate=((Health/MaxHealth)-0.85);
		if(npc.m_flRocketFireRate<=0.01)	//This limits the firerate of the npc. In this case its used to make sure it doesn't go negative
		{
			npc.m_flRocketFireRate=0.01;
		}
	}

	
	  //////////////////////
	 ///Blitzkrieg Lives///
	//////////////////////
	
	//Blitzkrieg uses lives to buff and to change rocket launchers and for other abilities.

	float Ratio = Health/MaxHealth;
	
	if(Ratio<0.75 && npc.m_iCurrentLife == 0 && i_current_wave[npc.index]>=10)
	{	//75%-50%
		BlitzLifeLossBase(npc, "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");
		
		npc.m_iMaxRockets = (b_buffed_blitz ? 50 : 25);	//Buff's the clipsize
		npc.m_flRocketTimeOutTimer = GetGameTime(npc.index)+1.0;
		npc.m_flLifeLossReloadMulti= 0.8;	//Buff's the reload speed.
		fl_npc_basespeed = 270.0;	//Buff's movement speed.
		
		if(b_pureblitz)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 이게 전부가 아니다!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 널 찢어발겨주마!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 하하하하하!!!", NpcStats_ReturnNpcName(npc.index));
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 역겨운 머리통을 몸과 분리시켜주마!!!", NpcStats_ReturnNpcName(npc.index));
				}
			}
		}
		else if(IsValidClient(closest))//Fancy text for blitz
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 이건 그냥 시작일 뿐이라고, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 이게 정말 끝일거라 생각하나, {yellow}%N{default}?", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 넌 너무 어리석군, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 아직 끝난게 아니다, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
	}
	else if(Ratio<0.5 && npc.m_iCurrentLife == 1 && i_current_wave[npc.index]>=20)
	{
		BlitzLifeLossBase(npc, "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");

		npc.m_iMaxRockets = (b_buffed_blitz ? 80 : 40);	//Buff's the clipsize
		npc.m_flRocketTimeOutTimer = GetGameTime(npc.index)+1.0;
		npc.m_flLifeLossReloadMulti= 0.75;
		fl_npc_basespeed = 275.0;

		if(b_pureblitz)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 이게 전부가 아니다!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 널 찢어발겨주마!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 하하하하하!!!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 역겨운 머리통을 몸과 분리시켜주마!!!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
		else if(IsValidClient(closest))
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 아직 자만하면 안 되지, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 종말이 다가오고 있다, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: {yellow}%N {default}, 정말로 계속 버티려는거냐?", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 네가 점점 더 흥미로워지는군, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
	}
	else if(Ratio<0.25 && npc.m_iCurrentLife == 2 && i_current_wave[npc.index]>=30)
	{	
		BlitzLifeLossBase(npc, "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");
		
		npc.m_iMaxRockets = (b_buffed_blitz ? 130 : 65);	//Buff's the clipsize
		npc.m_flRocketTimeOutTimer = GetGameTime(npc.index)+1.0;
		fl_npc_basespeed = 280.0;
		
		
		if(b_pureblitz)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 이게 전부가 아니다!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 널 찢어발겨주마!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 하하하하하!!!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 역겨운 머리통을 몸과 분리시켜주마!!!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
		else if(IsValidClient(closest))
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 어리석음이 결국 이렇게까지 되게 만드는구나, {yellow}%N{default}. 기대해라, {red}진짜 전격전을.", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 네 종말은 {red}지금이다, {yellow}%N{default}... 진정한 전격전을 {red}기대해라!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 슬슬 감이 오나? {red}너의 죽음이 다가온다, {yellow}%N {red}전격전을 느껴라!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 너의 그따위 약해빠진 무기로는 이 {crimson}블리츠크리그{default}를 막을 수 없다, {yellow}%N{default}!", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
	} 
	else if(Ratio < 0.175 && i_current_wave[npc.index] >=30 && fl_BEAM_RechargeTime[npc.index] != FAR_FUTURE && npc.m_iCurrentLife == 3)
	{
		
		npc.m_iCurrentLife++;
		fl_BEAM_RechargeTime[npc.index] = FAR_FUTURE;
		EmitSoundToAll("mvm/mvm_tank_horn.wav");

		
		fl_npc_basespeed = 300.0;	//Sets npc's speed to a higher value, still should be lower than a player who is running away without looking at the npc
		
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");	//he becomes melee.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		if(b_pureblitz)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}이거나 먹어라!!!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}아직도 살아있는거냐???", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}엑스피돈사의 기술력은 세계 제일!!!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
			}
		}
		else if(b_buffed_blitz)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}재밌는걸 하나 알려주지, 이건 대기가 없으면 쓸 수 없는 공격이다. 그리고 여긴 대기가 흘러넘치는 곳이지!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}최후를 맞이해라!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}진정한 {aqua}달{default}의 힘이 내 손 안에 있다!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
			}
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}나는 신이다...", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}저 놈들에게 내릴 징벌은 죽음 뿐이다!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: {crimson}달의 힘이 내 손 안에 있다!", NpcStats_ReturnNpcName(npc.index, true));	//Ego boost 9000%
				}
			}
		}
		
		float charge=6.0;	//Charge time of blitzlight MUST be set here
		float timer=20.0;	//Duration of blitzlight MUST be set here

		if(b_buffed_blitz)
		{
			charge = 7.0;
			timer = 25.0;
		}
		BlitzLight_Invoke(npc.index, timer, charge);	//timer is duration, charge is charge time. || Blitzlight invoke, thanks to spooks permission I ported the ability over for blitz
		
		npc.m_flNextTeleport = GetGameTime(npc.index) + 10.0;	//This value gets change on reset.
		
		if(!b_buffed_blitz)
		{
			npc.m_flLifeLossReloadMulti= 1.0;				//Used to make sure npc is in melee.

			npc.m_bPrimaryReloading=true;
			
			npc.m_flRocketTimeOutTimer =GetGameTime(npc.index)+1.0;
			
			npc.m_flReloadIn = GetGameTime(npc.index) + (timer+charge+1.0);	//turns off melee logic when blitzlight ends.

			npc.m_flRangedArmor = 0.1;	//Sets ranged armour to 90%, however melee still does normal damage, so if somehow is mad enough as melee to duel blitz in this state, they are free to do so.
		}
		else
		{
			npc.m_flRangedArmor = 0.25;
		}
		npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
	}
	if(!b_pureblitz && !npc.m_bAlliesSummoned && i_current_wave[npc.index]>=30 && Ratio < 0.5)
	{	
		npc.m_bAlliesSummoned = true;
		//This system is used to spawn minnions depending on wave and life. Also almost everything here is hard coded to waves meaning they won't on other waves.
		Spawn_Allies(npc);
	}
	return Plugin_Changed;
}
static void BlitzLifeLossBase(Blitzkrieg npc, char[] item)
{
	npc.m_iCurrentLife++;
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	npc.m_iWearable1 = npc.EquipItem("head", item);
	SetVariantString("1.0");
	AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

	npc.m_flReloadIn = GetGameTime(npc.index);	//Forces immediate reload.
	
	npc.m_bPrimaryReloading=false;	//Forces immediate reload.
	
	npc.PlayAngerSound();
	npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
		Blitzkrieg_IOC_Invoke(npc.index, npc.m_iTarget);

	EmitSoundToAll("mvm/mvm_tank_end.wav");
		
	npc.m_iChanged_WalkCycle = -1;	//Sets current anim to a non value so when clot think is called the correct anim is set
}
static void Spawn_Allies(Blitzkrieg npc)
{
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	if(i_current_wave[npc.index]==30)
	{
		CPrintToChatAll("{crimson}%s{default}: 하수인들이 이 곳에 도착했군.", NpcStats_ReturnNpcName(npc.index, true));
	}
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int heck;
	int spawn_index;
	heck= maxhealth;
	maxhealth= (heck/10);
	if(i_current_wave[npc.index]==30)	//Only spwans if the wave is 45.
	{
		spawn_index = NPC_CreateByName("npc_alt_combine_soldier_deutsch_ritter", npc.index, pos, ang, GetTeam(npc.index));
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
		spawn_index = NPC_CreateByName("npc_alt_medic_supperior_mage", npc.index, pos, ang, GetTeam(npc.index));
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		if(spawn_index > MaxClients)
		{
		
			NpcStats_CopyStats(npc.index, spawn_index);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
	if(i_current_wave[npc.index]>=40)	//Only spawns if the wave is 60 or beyond.
	{
		CPrintToChatAll("{crimson}%s{default}: And now its those two's turn", NpcStats_ReturnNpcName(npc.index, true));
		maxhealth= (heck/5);	//mid squishy

		spawn_index = NPC_CreateByName("npc_alt_donnerkrieg", npc.index, pos, ang, GetTeam(npc.index), "raid_ally");
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			b_thisNpcIsABoss[spawn_index] = true;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
		maxhealth= (heck/2);	//the tankiest
		spawn_index = NPC_CreateByName("npc_alt_schwertkrieg", npc.index, pos, ang, GetTeam(npc.index), "raid_ally");
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			b_thisNpcIsABoss[spawn_index] = true;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

static void NPC_Death(int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	if(g_b_item_allowed)
		npc.PlayDeathSound();
	else
	{
		npc.PlayDeathSoundfake();
	
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);	
	}


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
		
	if(IsValidClient(closest) && !b_timer_lose)
	{	
		if(b_pureblitz)
		{
			switch(GetRandomInt(1, 4))	//either he will say something, or nothing.
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 제기랄!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 널 반드시 죽여버리겠다!", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
		else if(g_b_item_allowed)
		{
			switch(GetRandomInt(1, 4))	//either he will say something, or nothing.
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 안 돼!!!!!", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 오류 발생...", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
		else if(b_buffed_blitz)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: {yellow}%N{default}, 다음엔 쉽진 않을거다. {red}다음에는 말이지...", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 이번에도 행운이 좋았군, {yellow}%N{default}. {red}그렇지?", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 다음에 두고 보자고, {yellow}%N{red}. 다음을...", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 흐흐, {yellow}%N{default} 넌 자만하고 있군, {crimson}다음 번에는{default} 내가 더 강력해져서 돌아올텐데 말이지.", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
			}
		}
		else
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}%s{default}: 오, {yellow}%N{default} 네 승리다. {red}지금 당장은...", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 2:
				{
					CPrintToChatAll("{crimson}%s{default}: 그래, {yellow}%N{default} 네 목숨줄이 조금 더 연장되었구나. {red}다음에도 그럴까?", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 3:
				{
					CPrintToChatAll("{crimson}%s{default}: 다음에 두고 보자고, {yellow}%N{red}, 다음을...", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
				case 4:
				{
					CPrintToChatAll("{crimson}%s{default}: 내 수하들이 오기 전에 나를 이기다니, {crimson}여전히{default} 이게 끝이 아닌걸 알아둬라...", NpcStats_ReturnNpcName(npc.index, true), closest);
				}
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
		
		if(fl_BEAM_DurationTime[npc.index] < GetGameTime(npc.index))
			fl_blitz_ioc_punish_timer[entity][enemy]=GetGameTime(npc.index)+5.0;
		else
		{
			fl_blitz_ioc_punish_timer[entity][enemy]=GetGameTime(npc.index)+1.0;	//Punishment be upon thee
			Time = 0.75;
		}
		float base_dmg = (b_buffed_blitz ? 50.0 : 25.0);
		fl_blitz_punish_dmg=base_dmg*RaidModeScaling;
		
		float Range = (b_buffed_blitz ? 300.0 : 200.0);
		float vecTarget[3];
		WorldSpaceCenter(enemy, vecTarget);
		vecTarget[2] += 1.0;
		
		if(dist > 4000000 && fl_BEAM_DurationTime[npc.index] < GetGameTime(npc.index))
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
static int i_punish_initiator;
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

	i_punish_initiator = target;
	
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
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {145, 47, 47, 255}, 3);
	TE_SendToAll();
	
	position[2] = startPosition[2] + 50.0;
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	return Plugin_Continue;
}
void Blitzkrieg_Punishment_Tweak(int entity, int victim, float damage, int weapon)	//while this function actually does the damage
{
	SDKHooks_TakeDamage(victim, entity, entity, (fl_blitz_punish_dmg*(i_punish_initiator == victim ? 1.0 : 0.5)), DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
}
static void Blitzkrieg_IOC_Invoke(int entity, int enemy)	//Ion cannon from above
{
	float distance=125.0; // /29 for duartion till boom
	float IOCDist=350.0;
	
	float vecTarget[3];
	GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);
	
	Handle data = CreateDataPack();
	WritePackFloat(data, vecTarget[0]);
	WritePackFloat(data, vecTarget[1]);
	WritePackFloat(data, vecTarget[2]);
	WritePackCell(data, distance); // Distance
	WritePackFloat(data, 0.0); // nphi
	WritePackFloat(data, IOCDist); // Range
	WritePackCell(data, EntIndexToEntRef(entity));
	ResetPack(data);
	Blitzkrieg_IonAttack(data);
}
static Action Blitzkrieg_DrawIon(Handle Timer, any data)
{
	Blitzkrieg_IonAttack(data);
		
	return (Plugin_Stop);
}
	
static void Blitzkrieg_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, g_Ruina_Glow_Blue, 1.0, 1.0, 255);
	TE_SendToAll();
}

static void Blitzkrieg_IonAttack(Handle &data)
{
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Iondistance = ReadPackCell(data);
	float nphi = ReadPackFloat(data);
	float Ionrange = ReadPackFloat(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	
	if(!IsValidEntity(client) || b_NpcHasDied[client])
	{
		delete data;
		return;
	}
	spawnRing_Vectors(startPosition, Ionrange * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.2, 12.0, 4.0, 3);	
	
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
	WritePackCell(nData, EntIndexToEntRef(client));
	ResetPack(nData);
	
	if (Iondistance > -30)
		CreateTimer(0.1, Blitzkrieg_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
	else	//Normal Ioc Damge on wave
	{

		startPosition[2] += 25.0;
		Explode_Logic_Custom((100.0*RaidModeScaling), client, client, -1, startPosition, Ionrange , _ , _ , true);
		startPosition[2] -= 25.0;
			
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
		spawnRing_Vectors(startPosition, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.5, 20.0, 10.0, 3, Ionrange * 2.0);	
		position[0] = startPosition[0];
		position[1] = startPosition[1];
		position[2] += startPosition[2] + 900.0;
		startPosition[2] += -200;
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {145, 47, 47, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {145, 47, 47, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {145, 47, 47, 255}, 3);
		TE_SendToAll();
		TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {145, 47, 47, 255}, 3);
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

static float fl_blitzlight_basecharge;
static float fl_blitzlight_basetimer;

static void BlitzLight_Invoke(int iNPC, float timer, float charge)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(iNPC);

	float vecTarget[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecTarget);
	
	BlitzLight_Scale1 = 200.0;	//Best to do the scales in sets of numbers.
	BlitzLight_Scale2 = 400.0;
	BlitzLight_Scale3 = 600.0;
	BlitzLight_DMG_Base = 80.0;		//Damage is dealt 10 times a second. The longer blitzlight is active the more it deals, once "stage 3" is reached it deals 2x damage
	BlitzLight_Radius_Base = 600.0;	//max radius

	
	float GameTime = GetGameTime(npc.index);
	fl_BEAM_DurationTime[npc.index] = GameTime + timer + charge;
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + charge;
	fl_blitzlight_basecharge = charge;
	fl_blitzlight_basetimer = timer;

	i_GunAmmo[npc.index] = 1;

	if(b_lost)
	{
		BlitzLight_Scale1 *=2.5;
		BlitzLight_Scale2 *=2.5;
		BlitzLight_Scale3 *=2.5;
		BlitzLight_DMG_Base *=2.5; 
		BlitzLight_Radius_Base *=2.5;
	}
	
	EmitSoundToAll(BLITZLIGHT_ACTIVATE);
	
	SDKHook(npc.index, SDKHook_Think, BlitzLight_Tick);
}
static Action BlitzLight_Tick(int client)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(client);

	float GameTime = GetGameTime(npc.index);
	
	if(fl_BEAM_DurationTime[npc.index] < GameTime)
	{

		SDKUnhook(client, SDKHook_Think, BlitzLight_Tick);

		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);

		return Plugin_Stop;
	}

	float Duration = fl_BEAM_DurationTime[npc.index] - GameTime;
	float Stages[3];
	//0.25.
	//0.5.
	//0.66.
	float Ratio = 1.0 - (Duration / fl_blitzlight_basetimer);
	Stages[0] = Ratio*4.0;	//doesn't really matter this one
	Stages[1] = Ratio*2.0;
	Stages[2] = Ratio*1.33;

	for(int i=0 ; i < 3 ; i++)
	{
		if(Stages[i] > 1.0)
			Stages[i] = 1.0;

		//CPrintToChatAll("what: [%i]: %.1f", i, Stages[i]);
	}

	SpawnBlitzLightBeams(npc, (fl_BEAM_ChargeUpTime[npc.index] > GameTime && fl_BEAM_ChargeUpTime[npc.index] != FAR_FUTURE), Stages);
	return Plugin_Continue;

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

static void SpawnBlitzLightBeams(Blitzkrieg npc, bool charging = true, float Stages[3])
{
	float GameTime = GetGameTime(npc.index);

	float UserLoc[3], UserAng[3];
	GetAbsOrigin(npc.index, UserLoc);
	
	UserAng[0] = 0.0;
	UserAng[1] = npc.m_flBlitzLightAngle;
	UserAng[2] = 0.0;

	
	
	if (charging)
	{
		npc.m_flBlitzLightAngle += 2.5;
	}
	else
	{
		npc.m_flBlitzLightAngle += (b_buffed_blitz ? 1.5 : 1.25);
	}
	
	if (npc.m_flBlitzLightAngle >= 360.0)
	{
		npc.m_flBlitzLightAngle -=360.0;
	}

	for (int i = 0; i < (charging ? 1 : 3); i++)
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:
			{
				distance = 1.0+BlitzLight_Scale1*Stages[i];
			}
			case 1:
			{
				distance = 1.0+BlitzLight_Scale2*Stages[i];
				angMult = -1.0;
			}
			case 2:
			{
				distance = 1.0+BlitzLight_Scale3*Stages[i];
				angMult = 1.0;
			}
		}

		if(distance < BlitzLight_Scale1 && !charging)
			distance = BlitzLight_Scale1;
		
		int loop_for = (charging ? 4 : 8);
		for (int j = 0; j < loop_for; j++)
		{
			float tempAngles[3], endLoc[3], Direction[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = angMult * (UserAng[1] + (float(j) * (360.0/loop_for)));
			tempAngles[2] = 0.0;
			
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			if (charging)
			{
				BlitzLight_Spawn8(endLoc, BlitzLight_Scale1, npc.index);
			}
			else
			{
				BlitzLight_SpawnBeam(npc.index, false, endLoc);
			}
		}
	}

	if(fl_BEAM_ThrottleTime[npc.index] > GameTime || (fl_BEAM_ChargeUpTime[npc.index] > GameTime && fl_BEAM_ChargeUpTime[npc.index] != FAR_FUTURE) )
		return;

	fl_BEAM_ThrottleTime[npc.index] = GameTime + 0.1;

	float Radius = BlitzLight_Radius_Base*(Stages[2]);
	float dmg = BlitzLight_DMG_Base*(1+Stages[2]);				//damage scales on duration.

	BlitzLight_DealDamage(npc, dmg, Radius);
}

static void BlitzLight_Spawn8(float startLoc[3], float space, int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	float ratio = 1.0 - ((fl_BEAM_ChargeUpTime[npc.index]-GetGameTime(npc.index)) / fl_blitzlight_basecharge);

	int loop_for = 8;
	for (int i = 0; i < loop_for; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(i) * (360.0/loop_for);
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, space);
		AddVectors(startLoc, Direction, endLoc);
		BlitzLight_SpawnBeam(entity, true, endLoc, ratio);
	}
	int color[4];
	color[0] = 25;
	color[1] = 205;
	color[2] = 255;
	color[3] = RoundFloat(255.0 * ratio);
	
	TE_SetupBeamRingPoint(startLoc, space * 2.0, space * 2.0 +1.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 0.1, 2.0, 0.1, color, 1, 0);
	TE_SendToAll();
}

static void BlitzLight_SpawnBeam(int entity, bool charging, float beamLoc[3], float alphaMod = 1.0)
{
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
		
		TE_SetupBeamPoints(skyLoc, beamLoc, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 0.1, 2.0, 2.1, 1, 0.1, color, 1);
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
		TE_SetupBeamPoints(skyLoc, beamLoc, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 0.1, 10.0, 10.1, 1, 0.1, color, 1);
		TE_SendToAll();
		TE_SetupBeamRingPoint(beamLoc, 0.0, BlitzLight_Scale1 * 2.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 0.33, 2.0, 0.1, color, 1, 0);
		TE_SendToAll();
		
	}
}

static void BlitzLight_DealDamage(Blitzkrieg npc, float damage, float radius)
{
	float beamLoc[3];
	GetAbsOrigin(npc.index, beamLoc);
	
	float dmg_pen = 1.0;
	if(i_current_wave[npc.index]>=40)
	{
		dmg_pen = 1.75;	//A slight buff to damage on wave 60
	}
	if(b_buffed_blitz)
	{
		dmg_pen *= 1.75;
	}
	Explode_Logic_Custom((damage) * dmg_pen, npc.index, npc.index, -1, beamLoc, radius*1.25 , _ , _ , true, _, _, 10.0, Blitzlight_Shake_Client);
	//CPrintToChatAll("dmg: %fl", damage);
	//CPrintToChatAll("radius: %fl", 1.25*radius);
	beamLoc[2]+=10;
	spawnRing_Vector(beamLoc, radius*2.0*1.25, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, 0.1, 1.0, 0.1, 1);

}
static void Blitzlight_Shake_Client(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
		Client_Shake(victim, 0, 10.0, 10.0, 0.35);
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
static void FireBlitzRocket(Blitzkrieg npc, float vecTarget[3], float rocket_damage, float rocket_speed, float model_scale = 1.0)
{
	if(rocket_speed>3000)
		rocket_speed=3000.0;
	
	Ruina_Projectiles Projectile;
	float SelfVec[3];
	WorldSpaceCenter(npc.index, SelfVec);
	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = SelfVec;
	float Ang[3];
	MakeVectorFromPoints(SelfVec, vecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = rocket_speed;
	Projectile.radius = 0.0;
	Projectile.damage = rocket_damage;
	Projectile.bonus_dmg = rocket_damage*2.5;
	Projectile.Time = 5.0;
	Projectile.visible = true;
	int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);		
	Projectile.Size = model_scale;
	Projectile.Apply_Model("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl");

	fl_AbilityOrAttack[Proj][4] = GetGameTime();
}

static void Func_On_Proj_Touch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	float damage = fl_ruina_Projectile_dmg[entity];

	if(other > 0 && ShouldNpcDealBonusDamage(other))
		damage = fl_ruina_Projectile_bonus_dmg[entity];

	switch(GetRandomInt(1,5)) 
	{
		case 1:EmitSoundToAll(SOUND_BLITZ_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);	
		case 2:EmitSoundToAll(SOUND_BLITZ_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);	
		case 3:EmitSoundToAll(SOUND_BLITZ_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
		case 4:EmitSoundToAll(SOUND_BLITZ_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
		case 5:EmitSoundToAll(SOUND_BLITZ_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
	}

	float time = GetGameTime() - fl_AbilityOrAttack[entity][4];

	if(time<=2.0 && time>=0.0)
	{			
		if(time<1.0)
			time=1.0;	//minimum dmg limiter
		
		if(b_buffed_blitz)
			if(time<1.75)
				time=1.75;

		float ratio = time/2.0;
		damage *=ratio;
	}

	i_ExplosiveProjectileHexArray[owner] = EP_GENERIC|EP_NO_KNOCKBACK;
	if(fl_ruina_Projectile_radius[entity]>0.0)
		Explode_Logic_Custom(damage , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[entity] , _ , _ , true);
	else if(other > 0)
		SDKHooks_TakeDamage(other, owner, owner, damage, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1, _, ProjectileLoc);

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

	Ruina_Remove_Projectile(entity);
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
							meleedmg = 15.5 * RaidModeScaling;
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


static void CheckChargeTimeBlitzkrieg(Blitzkrieg npc)
{
	float GameTime = GetGameTime(npc.index);
	float PercentageCharge = 0.0;
	float TimeUntillTeleLeft = npc.m_flReloadIn - GameTime;

	PercentageCharge = (TimeUntillTeleLeft  / (10.0 * npc.m_flLifeLossReloadMulti));
	
	if(!npc.m_bPrimaryReloading)
	{
		PercentageCharge = (float(npc.m_iProjectilesFired) / float(npc.m_iMaxRockets));
	}
	if(PercentageCharge <= 0.0)
		PercentageCharge = 0.0;

	if(PercentageCharge >= 1.0)
		PercentageCharge = 1.0;

	PercentageCharge -= 1.0;
	PercentageCharge *= -1.0;


	TwirlSetBatteryPercentage(npc.index, PercentageCharge);
}