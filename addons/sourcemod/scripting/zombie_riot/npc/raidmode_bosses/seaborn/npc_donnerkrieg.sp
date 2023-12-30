#pragma semicolon 1
#pragma newdecls required

/*
//Donner, schwert raid abilities

shared:

Group Tele: the 2 run at one another, once in range, they both teleport to a random player.

Behvior:
Backup - Schwertkrieg runs and protects donnerkrieg when he is using nightmare cannon
Cover - If Donnerkriegs "sniper threat" value reaches 25% schwert will switch to attacking "sniper" players which are defined by donnerkrieg. if this value reaches 100% schwert WILL murder the snipers, and teleport to them
Shared Goal - Both have the same PrimaryThreatIndex

schwert:
Multi-Teleport-Strike.
Heaven's blade - Fantasmal swings but heavily moddified.
Heaven's barrage - Quincy Hyper barrage

donner:

Wave 15:
Improved Nightmare Cannon: Coded!

On Schwert Death:	Coded but might need more refining.
	Heavens Light: Ruina Ion cannon's but modified - They somewhat start out like moonlight

On donner spawn: Heavens Light.

Wave 30:
	Heaven's Fall:
	Several IOC's spawn around the map, creating creep. once the first creep ion's are done, switches to simply damage.

Wave 45:
	Heaven's radiance: Jump high into the sky, and spew lasers all around.
	Heaves Light natural.

Wave 45 Ult:
	Heavens Touch:
		Moonlight Horizontal Eddition:tm: :)


Very descriptive descriptions, I know lmao

*/

#define DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_1 "ambient/levels/citadel/zapper_warmup1.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_2 "ambient/levels/citadel/zapper_warmup4.wav"

#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE1 "npc/combine_gunship/dropship_engine_distant_loop1.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE2 "ambient/atmosphere/city_beacon_loop1.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE3 "ambient/atmosphere/city_rumble_loop1.wav"


#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND1 "mvm/mvm_mothership_loop.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND2 "ambient/energy/force_field_loop1.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND3 "hl1/ambience/alien_minddrill.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND4 "npc/scanner/combat_scan_loop6.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND5 "npc/scanner/combat_scan_loop4.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND6 "hl1/ambience/alien_minddrill.wav"

#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1 "ambient/levels/citadel/zapper_loop1.wav"
#define DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2 "ambient/levels/citadel/zapper_loop2.wav"

/*
	ambient\energy\force_field_loop1.wav
	ambient\energy\electric_loop.wav
	ambient\atmosphere\city_beacon_loop1.wav
	ambient\atmosphere\city_rumble_loop1.wav


	ambient_mp3\halloween\thunder_01.mp3 - 10
*/

static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];

static const char g_nightmare_cannon_core_sound[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_02.mp3",
	"ambient_mp3/halloween/thunder_03.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_05.mp3",
	"ambient_mp3/halloween/thunder_06.mp3",
	"ambient_mp3/halloween/thunder_07.mp3",
	"ambient_mp3/halloween/thunder_08.mp3",
	"ambient_mp3/halloween/thunder_09.mp3",
	"ambient_mp3/halloween/thunder_10.mp3",
};



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

static bool b_nightmare_logic[MAXENTITIES];
static float fl_nightmare_grace_period[MAXENTITIES];
static bool b_fuck_you_line_used[MAXENTITIES];
static bool b_train_line_used[MAXENTITIES];
static float fl_cannon_Recharged[MAXENTITIES];

#define DONNERKRIEG_RAID_PARTICLE_EFFECTS 3
static int i_particle_effects[MAXENTITIES][DONNERKRIEG_RAID_PARTICLE_EFFECTS];


static float fl_nightmare_end_timer[MAXENTITIES];
static bool DonnerKriegCannon_BEAM_HitDetected[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];

static float fl_backwards_failsafe[MAXENTITIES];

#define DONNERKRIEG_TE_DURATION 0.07

//Heavens Light

bool b_force_heavens_light[MAXENTITIES];
static bool Heavens_Light_Active[MAXENTITIES];
float fl_heavens_light_use_timer[MAXENTITIES];

static int Heavens_Beam;
static char gExplosive1;

//Heavens Fall

static float fl_heavens_fall_use_timer[MAXENTITIES];

//Logic for duo raidboss

bool shared_goal;
bool schwert_retreat;
int schwert_target;
static float fl_donner_sniper_threat_timer_clean[MAXTF2PLAYERS+1];
#define RAIDBOSS_DONNERKRIEG_SNIPER_CLEAN_TIMER	30.0	//For how long does a "sniper" player have to not attack in "sniper" deffinition for the threat index to be reset
static float fl_donner_sniper_threat_value[MAXTF2PLAYERS+1];
bool b_donner_valid_sniper_threats[MAXTF2PLAYERS+1];
bool b_schwert_focus_snipers;
float fl_schwertkrieg_sniper_rampage_timer;
#define RAIDBOSS_DONNERKRIEG_SCHWERTKRIEG_SNIPER_RAMPAGE_REFRESH_TIME 10.0	//tl;dr, if a sniper doesn't attack in 10 seconds, schwertkrieg goes to normal operations

static int i_ally_index;

static int DonnerKriegCannon_BEAM_Glow;
static int DonnerKriegCannon_BEAM_Laser;

bool b_raidboss_schwertkrieg_alive;
bool b_raidboss_donnerkrieg_alive;

static bool b_InKame[MAXENTITIES];

void Raidboss_Donnerkrieg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);	}

	for (int i = 0; i < (sizeof(g_nightmare_cannon_core_sound));   i++) { PrecacheSound(g_nightmare_cannon_core_sound[i]);	}

	Zero(fl_nightmare_cannon_core_sound_timer);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	DonnerKriegCannon_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	DonnerKriegCannon_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
	PrecacheSoundCustom("#zombiesurvival/seaborn/donner_schwert_5.mp3");

	PrecacheSound("misc/halloween/gotohell.wav");
	
	Heavens_Beam = PrecacheModel(BLITZLIGHT_SPRITE);
	
	Zero(b_donner_valid_sniper_threats);
	Zero(fl_donner_sniper_threat_value);
	Zero(fl_donner_sniper_threat_timer_clean);

	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_1, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_2, true);

	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND1, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND2, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND3, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND4, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND5, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND6, true);


	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2, true);

	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE1, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE2, true);
	PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE3, true);

	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);

	PrecacheSound("ambient/energy/whiteflash.wav", true);
	
}

methodmap Raidboss_Donnerkrieg < CClotBody
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
	public void PlayNightmareSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_nightmare_cannon_core_sound[GetRandomInt(0, sizeof(g_nightmare_cannon_core_sound) - 1)]);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime(this.index) + 0.1;
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}

	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound= GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	
	public Raidboss_Donnerkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));
		
		i_NpcInternalId[npc.index] = SEA_RAIDBOSS_DONNERKRIEG;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_raidboss_donnerkrieg_alive = true;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		/*
			Will use similair logic to silvester & goggles duo
			
			Donnerkrieg is the master raidboss.
		*/
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 500.0;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		
		
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			b_donner_valid_sniper_threats[client_check] = false;
			fl_donner_sniper_threat_value[client_check] = 0.0;
			fl_donner_sniper_threat_timer_clean[client_check] = 0.0;
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Donnerkrieg And Schwertkrieg Spawn");
			}
		}
		
		Citizen_MiniBossSpawn();
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		
		
		
		Music_SetRaidMusic("#zombiesurvival/seaborn/donner_schwert_5.mp3", 290, true);
		
		SDKHook(npc.index, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
			
		
		/*
			breakneck baggies	"models/workshop/player/items/all_class/jogon/jogon_medic.mdl"
			colone's coat		"models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl"
			crone's dome		"models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl"
			flatliner			"models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl"
			lo-grav loafers		"models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl"
			nunhood				"models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl"
			puffed practitioner	"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl"

		*/
		//IDLE
		npc.m_flSpeed = 300.0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		
		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		i_particle_effects[npc.index][0] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0}));
		npc.GetAttachment("root", flPos, flAng);
		
		npc.StartPathing();
		
		b_fuck_you_line_used[npc.index] = false;
		b_train_line_used[npc.index] = false;
		b_nightmare_logic[npc.index] = false;
		fl_nightmare_grace_period[npc.index] = 0.0;

		float GameTime = GetGameTime(npc.index);
		
		
		fl_nightmare_end_timer[npc.index]= GameTime + 10.0;
		fl_cannon_Recharged[npc.index]= GameTime + 10.0;
		
		npc.m_flNextRangedBarrage_Spam = GameTime + 15.0;
		
		fl_schwertkrieg_sniper_rampage_timer = 0.0;
		
		
		Heavens_Light_Active[npc.index]=false;
		fl_heavens_light_use_timer[npc.index] = GameTime + 125.0;
		b_force_heavens_light[npc.index] = false;
		//Invoke_Heavens_Light(npc, GameTime);

		fl_heavens_fall_use_timer[npc.index] = GameTime + 30.0;

		//Heavens_Fall(npc, GetGameTime(npc.index));
		
		shared_goal = false;

		b_schwert_focus_snipers = false;

		schwert_retreat = false;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: We have arrived to render judgement");
		
		Donnerkrieg_Wings_Create(npc);

		npc.Anger = false;
		
		//Reused silvester duo code here
		
		RequestFrame(Donnerkrieg_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		
		return npc;
	}
	
	
}

void Donnerkrieg_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
		
		maxhealth = RoundToFloor(maxhealth*2.5);

		int spawn_index = Npc_Create(SEA_RAIDBOSS_SCHWERTKRIEG, -1, pos, ang, GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
		{
			i_ally_index = EntIndexToEntRef(spawn_index);
			Schwertkrieg_Set_Ally_Index(entity);
			Zombies_Currently_Still_Ongoing += 1;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

//TODO 
//Rewrite
public void Raidboss_Donnerkrieg_ClotThink(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);
	
	if(b_raidboss_donnerkrieg_alive)	//I don't need this here, but I still added it...
		Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(true);	//donner first, schwert second
		
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget == -1)
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	int Current_Wave = ZR_GetWaveCount()+1;
	/*


	*/
	
	if(fl_nightmare_end_timer[npc.index] < GameTime && b_nightmare_logic[npc.index])
	{	
		npc.m_flRangedArmor = 1.0;
		b_nightmare_logic[npc.index] = false;

		if(shared_goal)
			shared_goal=false;
		
		//if(b_angered)
		//{
		fl_cannon_Recharged[npc.index] = GameTime + 60.0;
		//}
		//else		
		//{		
			//fl_cannon_Recharged[npc.index] = GameTime + 90.0;
		//}
		npc.m_flSpeed = 300.0;
		
		f_NpcTurnPenalty[npc.index] = 1.0;	//:)

		npc.SetPlaybackRate(1.0);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][1])))
			RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][1]));
		if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][2])))
			RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][2]));
		
	}
	
	bool target_neutralized = false;	//if all the valid target timers are no more, just forcefully set schwertkrieg to defaul behavior
	for(int client=0 ; client <MAXTF2PLAYERS ; client++)
	{
		if(fl_donner_sniper_threat_timer_clean[client]<GameTime)	//this "sniper" player hasn't attacked donnerkrieg from a far range in 30 seconds, remove them as a valid target for schwertkrieg and remove the threat
		{
			target_neutralized = true;	//a target has been neutralized, check
			fl_donner_sniper_threat_value[client] = 0.0;
			b_donner_valid_sniper_threats[client] = false; //NOTE: its likely that players might attack from a far just cause they happened to be there, so I should probably make the valid threat either be set to false sooner, or I should add a "Value" system, range vs threat %.
		}
		else
		{
			target_neutralized = false;
		}
	}
	if(target_neutralized || fl_schwertkrieg_sniper_rampage_timer < GameTime)
		b_schwert_focus_snipers = false;	//Target neutralized, returning to HQ
		
	int PrimaryThreatIndex = npc.m_iTarget;
		
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_cannon_Recharged[npc.index]<GameTime && !b_nightmare_logic[npc.index] && !Heavens_Light_Active[npc.index])
		{
			fl_nightmare_end_timer[npc.index] = GameTime + 20.0;
			Raidboss_Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}

		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		
						
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(WorldSpaceCenter(npc.index), vecTarget, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		if(!b_nightmare_logic[npc.index])
		{	
			//warp_heave
			if((Current_Wave>=45 && fl_heavens_light_use_timer[npc.index] < GameTime) || b_force_heavens_light[npc.index])
			{
				b_force_heavens_light[npc.index]=false;
				fl_heavens_light_use_timer[npc.index] = GameTime + 150.0;
				Heavens_Light_Active[npc.index]=true;

				Invoke_Heavens_Light(npc, GameTime);
			}
			if(npc.m_flAttackHappens > GameTime)
			{
				npc.FaceTowards(vecTarget, 5000.0);
			}

			if(Current_Wave>=30 &&fl_heavens_fall_use_timer[npc.index]< GameTime)
			{
				fl_heavens_fall_use_timer[npc.index] = GameTime+1.0;	//retry in 1 seconds if failed, otherwise proper CD.
				Heavens_Fall(npc, GameTime);
			}

			Donner_Movement(npc.index, PrimaryThreatIndex, GameTime);
				
			if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0))
			{	

				npc.FaceTowards(vecTarget);
				float projectile_speed = 400.0;
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed);

				
				npc.FireParticleRocket(vecTarget, 25.0*RaidModeScaling , 400.0 , 100.0 , "raygun_projectile_blue");
						
					//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)

				npc.m_iAmountProjectiles += 1;
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MP_THROW");
				npc.m_flNextRangedBarrage_Singular = GameTime + 0.15;
				if (npc.m_iAmountProjectiles >= 15.0)
				{
					npc.m_iAmountProjectiles = 0;
					if(!npc.Anger)
						npc.m_flNextRangedBarrage_Spam = GameTime + 45.0;
					else
						npc.m_flNextRangedBarrage_Spam = GameTime + 25.0;
				}
			}
				
			Donnerkrieg_Normal_Attack(npc, GameTime, flDistanceToTarget, vecTarget);
					
					
			npc.StartPathing();
		}
		else
		{
			Raidboss_Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(!npc.m_bInKame && !b_nightmare_logic[npc.index])
	{
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}

static void Donner_Movement(int client, int PrimaryThreatIndex, float GameTime)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

	if(npc.m_bAllowBackWalking)
		npc.FaceTowards(vecTarget, 20000.0);
	
	if(shared_goal)
	{
		schwert_target = PrimaryThreatIndex;	//if "shared goal" is active both npc's target the same target, the target is set by donnerkrieg
	}

	if(fl_backwards_failsafe[npc.index] < GameTime)
	{
		if(npc.m_bAllowBackWalking)
			npc.m_bAllowBackWalking=false;
	}

	if(flDistanceToTarget < (225.0*225.0))
	{
		

		int Enemy_I_See;
				
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{		
			if(flDistanceToTarget < (125.0*125.0))
			{
				fl_backwards_failsafe[npc.index] = GameTime+2.5;
				npc.m_bAllowBackWalking=true;
				npc.StartPathing();
				float vBackoffPos[3];
				vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);

				npc.StartPathing();
				npc.m_bPathing = true;

				npc.FaceTowards(vecTarget, 20000.0);
			}
			else
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bAllowBackWalking=false;

				npc.FaceTowards(vecTarget, 500.0);
			}
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}		
	}
	else
	{
		npc.m_bAllowBackWalking=false;
		npc.StartPathing();
		npc.m_bPathing = true;
	}

	if(npc.m_bPathing)
	{
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
						
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
						
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} 
		else 
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
	}
}

public void Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(bool donner_alive)
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
		if(donner_alive)
		{
			CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: You think thats how you fight us two?");
		}
		else
		{

		}
		
	}
}
#define HEAVENS_LIGHT_MAXIMUM_IONS 3*5		//3  is a must, then the other multi is whatever, just make sure its an integer. fun fact: going above 5 will kill TE limit!

static float fl_heavens_damage;
static float fl_heavens_charge_time;
static float fl_heavens_charge_gametime;
static float fl_heavens_radius;
static float fl_heavens_speed;

static float fl_Heavens_Loc[HEAVENS_LIGHT_MAXIMUM_IONS+1][3];
static float fl_Heavens_Target_Loc[HEAVENS_LIGHT_MAXIMUM_IONS+1][3];
static bool b_targeted_by_heavens[MAXTF2PLAYERS+1];
static float fl_was_targeted[MAXTF2PLAYERS+1];
static float fl_heavens_rng_loc_timer[HEAVENS_LIGHT_MAXIMUM_IONS+1];
static int i_heavens_target_id[HEAVENS_LIGHT_MAXIMUM_IONS+1];
static float fl_Heavens_Angle;

static int HeavenLight_GetTarget(int ID, float loc[3])
{
	float Dist = -1.0;
	int client_id=-1;
	for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
	{
		if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
		{
			if(!b_targeted_by_heavens[client] || client==i_heavens_target_id[ID])
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance<Dist || Dist==-1.0)
					{
						Dist = distance;
						client_id = client;
					}
				}
			}
		}
	}
	if(IsValidClient(client_id))
	{
		fl_was_targeted[client_id] = GetGameTime()+0.25;
		b_targeted_by_heavens[client_id]=true;
		i_heavens_target_id[ID]=client_id;
	}
	return client_id;
}

static void GetRandomLoc(Raidboss_Donnerkrieg npc, float Loc[3], int Num)
{

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	Loc[0] = GetRandomFloat((Loc[0] - 200.0*Num),(Loc[0] + 200.0*Num));
	Loc[1] = GetRandomFloat((Loc[1] - 200.0*Num),(Loc[1] + 200.0*Num));

	Handle ToGroundTrace = TR_TraceRayFilterEx(Loc, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
	TR_GetEndPosition(Loc, ToGroundTrace);
	delete ToGroundTrace;

	CNavArea area = TheNavMesh.GetNearestNavArea(Loc, true);
	if(area == NULL_AREA)
	{
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Loc[0] +=GetRandomFloat((-200.0*Num),(200.0*Num));
		Loc[1]  +=GetRandomFloat((-200.0*Num),(200.0*Num));
		return;
	}
		

	int NavAttribs = area.GetAttributes();
	if(NavAttribs & NAV_MESH_AVOID)
	{
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
		Loc[0] +=GetRandomFloat((-200.0*Num),(200.0*Num));
		Loc[1]  +=GetRandomFloat((-200.0*Num),(200.0*Num));
		return;
	}
			

	area.GetCenter(Loc);
}

static float fl_heavens_light_duration;

static void Invoke_Heavens_Light(Raidboss_Donnerkrieg npc, float GameTime)
{
	float Heavens_Duration;
	fl_heavens_damage = 100.0;
	fl_heavens_charge_time = 10.0;
	Heavens_Duration = 30.0;
	fl_heavens_radius = 150.0;	//This is per individual beam
	fl_heavens_speed = 2.5;

	fl_heavens_light_duration = GameTime + Heavens_Duration+fl_heavens_charge_time;
	
	Zero(i_heavens_target_id);
	Zero(fl_heavens_rng_loc_timer);
	fl_Heavens_Angle = 0.0;
	
	fl_heavens_charge_gametime = fl_heavens_charge_time + GameTime;

	Heavens_Light_Active[npc.index] = true;
	
	SDKHook(npc.index, SDKHook_Think, Heavens_TBB_Tick);
}

//static int TE_used;
public Action Heavens_TBB_Tick(int client)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);

	float GameTime = GetGameTime();

	if(fl_heavens_light_duration<GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Heavens_TBB_Tick);
		Heavens_Light_Active[npc.index] = false;

		return Plugin_Stop;
	}

	//TE_used=0;
	
	if(fl_heavens_charge_gametime>GameTime)
	{
		float Ratio =(fl_heavens_charge_gametime - GameTime) / fl_heavens_charge_time;	//L + Ratio
		Heavens_Light_Charging(npc.index, Ratio);
	}
	else
	{
		for(int player=0 ; player <=MAXTF2PLAYERS ; player++)
		{
			if(fl_was_targeted[player]< GameTime)
			{
				b_targeted_by_heavens[player]=false;
			}
		}

		Heavens_Full_Charge(npc, GameTime);
	}
	
	return Plugin_Continue;
}
static void Heavens_Full_Charge(Raidboss_Donnerkrieg npc, float GameTime)
{
	for(int i=0 ; i< HEAVENS_LIGHT_MAXIMUM_IONS ; i++)
	{
		float loc[3]; loc = fl_Heavens_Loc[i];
		float Target_Loc[3]; Target_Loc = loc;

		int Target = HeavenLight_GetTarget(i, loc);
		

		if(IsValidClient(Target))
		{
			GetEntPropVector(Target, Prop_Data, "m_vecAbsOrigin", Target_Loc);
			fl_Heavens_Target_Loc[i] = Target_Loc;
		}
		else
		{
			if(fl_heavens_rng_loc_timer[i] < GameTime)
			{
				fl_heavens_rng_loc_timer[i] = GameTime+GetRandomFloat(1.0, 5.0);
				GetRandomLoc(npc, Target_Loc, i);
				fl_Heavens_Target_Loc[i] = Target_Loc;
			}
			else
			{
				Target_Loc = fl_Heavens_Target_Loc[i];
			}
			
		}
		
		float Direction[3], vecAngles[3];
		MakeVectorFromPoints(loc, Target_Loc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
						
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, fl_heavens_speed);
		AddVectors(loc, Direction, loc);
		
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, loc);

		Doonerkrieg_Do_AOE_Damage(npc, loc, fl_heavens_damage, fl_heavens_radius, 0.4, 0);
		
		fl_Heavens_Loc[i] = loc;
		
		int color[4];
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
		color[3] = 75;

		Heavens_SpawnBeam(loc, color, 7.5, true);
	}
}
static void Heavens_Light_Charging(int ref, float ratio)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	
	float Base_Dist = 500.0 * ratio;
	if(Base_Dist<150.0)
		Base_Dist = 150.0;
		
	float UserLoc[3], UserAng[3];
	UserLoc = GetAbsOrigin(npc.index);
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_Heavens_Angle;
	UserAng[2] = 0.0;
	
	fl_Heavens_Angle += 1.5*ratio;
	
	if(fl_Heavens_Angle>=360.0)
	{
		fl_Heavens_Angle = 0.0;
	}
	
	for (int i = 0; i < 3; i++)
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:
			{
				distance = Base_Dist;
			}
			case 1:
			{
				distance = Base_Dist*1.5;
				angMult = -1.0;
			}
			case 2:
			{
				distance = Base_Dist*2.0;
				angMult = 1.0;
			}
		}
		
		for (int j = 0; j < (HEAVENS_LIGHT_MAXIMUM_IONS/3); j++)
		{
			float tempAngles[3], endLoc[3], Direction[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = angMult * (UserAng[1] + (float(j) * (360.0/(HEAVENS_LIGHT_MAXIMUM_IONS/3))));
			tempAngles[2] = 0.0;
			
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, endLoc);
			
			

			
			if(ratio <=0.2)
			{
				int color[4];
				color[0] = 255;
				color[1] = 50;
				color[2] = 50;
				color[3] = 75;

				Heavens_SpawnBeam(endLoc, color, 7.5, true);
			}
			else
			{
				Heavens_Spawn8(endLoc, 150.0*ratio, ratio);
			}
			int beam_index = (i*(HEAVENS_LIGHT_MAXIMUM_IONS/3))+j;
			
			fl_Heavens_Loc[beam_index] = endLoc;
			fl_Heavens_Target_Loc[beam_index] = endLoc;
		}
	}
}
static void Heavens_Spawn8(float startLoc[3], float space, float ratio)
{
	for (int i = 0; i < 2 ; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(i) * 180.0 + fl_Heavens_Angle;
		tempAngles[2] = 0.0;
		
		if(tempAngles[1]>=360.0)
		{
			tempAngles[1] = -360.0;
			
		}
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, space);
		AddVectors(startLoc, Direction, endLoc);
		int color[4];
		color[0] = 255;
		color[1] = RoundFloat(255.0 * ratio);
		color[2] = RoundFloat(255.0 * ratio);
		color[3] = 150;

		Heavens_SpawnBeam(endLoc, color, 2.0, false);

		
	}
}
void Heavens_SpawnBeam(float beamLoc[3], int color[4], float size, bool rings)
{


	float skyLoc[3], groundLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
	groundLoc = beamLoc;
	groundLoc[2] -= 200.0;


	TE_SetupBeamPoints(skyLoc, groundLoc, Heavens_Beam, Heavens_Beam, 0, 1, 0.1, size, size, 1, 0.5, color, 1);
	TE_SendToAll();

	if(rings)
		spawnRing_Vector(beamLoc, fl_heavens_radius*2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, 0.1, 1.0, 0.1, 1);
}
static void Raidboss_Donnerkrieg_Nightmare_Logic(int ref, int PrimaryThreatIndex)
{

	shared_goal=true;	//while using the cannon, schwert attacks the same target that donner is moving towards

	if(shared_goal)
		schwert_target = PrimaryThreatIndex;	//if "shared goal" is active both npc's target the same target, the target is set by donnerkrieg

	
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	
	//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
	//float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(PrimaryThreatIndex), true);
	
	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bInKame)
	{
		if(!b_nightmare_logic[npc.index])
		{
			//if(b_angered)
			{
				fl_nightmare_grace_period[npc.index] = GameTime + 5.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			}
			//else
			//{
			//	fl_nightmare_grace_period[npc.index] = GameTime + 10.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			//}
			
			b_nightmare_logic[npc.index] = true;

			npc.m_bAllowBackWalking=false;

			shared_goal=true;
			
			switch(GetRandomInt(1,6))
			{
				case 1:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}Thats it {snow}i'm going to kill you");	
				}
				case 2:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}hm, {snow}Wonder how this will end...");	
				}
				case 3:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}PREPARE {snow}Thyself, {yellow}Judgement {snow}Is near");	
				}
				case 4:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Oh not again now train's gone and {aliceblue}Left{snow}.");	
							b_train_line_used[npc.index] = true;
						}				
						default:
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Oh not again now cannon's gone and {aliceblue}recharged{snow}.");	
						}
							
					}
				}
				case 5:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Aiming this thing is actually quite {aliceblue}complex {snow}ya know.");	
					b_fuck_you_line_used[npc.index] = true;
				}
				case 6:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Ya know, im getting quite bored of {aliceblue}this");	
				}
			}
			
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
		}
		else
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				npc.StartPathing();
				float vBackoffPos[3];
				vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);

				if(fl_nightmare_grace_period[npc.index]<GameTime)
				{
					fl_nightmare_grace_period[npc.index] = GameTime + 99.0;
					if(!b_fuck_you_line_used[npc.index] && !b_train_line_used[npc.index])
					{	
						switch(GetRandomInt(1,4))
						{
							case 1:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}NIGHTMARE, CANNON!");
							}
							case 2:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}JUDGEMENT BE UPON THEE!");
							}
							case 3:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}Ruina CANNON!");	
							}
							case 4:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}You cannot run, You Cannot Hide");	
							}
						}
					}
					else
					{
						if(b_train_line_used[npc.index])
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}And the city's to far to walk to the end while I...");	
							b_train_line_used[npc.index] = false;
						}
						else if(b_fuck_you_line_used[npc.index])
						{
							b_fuck_you_line_used[npc.index] = false;
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: However its still{aliceblue} worth the effort");	
						}
						
					}
					
					npc.m_bInKame = true;
					
					npc.m_flRangedArmor = 0.5;
						
					float flPos[3]; // original
					float flAng[3]; // original
						
					npc.GetAttachment("root", flPos, flAng);
					i_particle_effects[npc.index][1] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_portalswirl_purple_parent", npc.index, "root", {0.0,0.0,0.0}));
					npc.GetAttachment("root", flPos, flAng);
					i_particle_effects[npc.index][2] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_runeprison_yellow_parent", npc.index, "root", {0.0,0.0,0.0}));
						
					//npc.FaceTowards(vecTarget, 20000.0);	//TURN DAMMIT
						
						
					//if(b_angered)
					//{
						//npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
						//npc.AddActivityViaSequence("taunt_the_fist_bump");
					//}

					npc.FaceTowards(vecTarget, 20000.0);

					npc.AddActivityViaSequence("taunt_mourning_mercs_medic");

					npc.SetPlaybackRate(2.0);	
					npc.SetCycle(0.0);
					
					EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
					//EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_2);
					//EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_1);

					EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1, npc.index, SNDCHAN_STATIC, 100, _, 0.25, 75);
					//EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1, npc.index, SNDCHAN_STATIC, 100, _, 0.25, 75);
					EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2, npc.index, SNDCHAN_STATIC, 100, _, 0.25, 75);
					//EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2, npc.index, SNDCHAN_STATIC, 100, _, 0.25, 75);

					EmitSoundToAll("ambient/energy/whiteflash.wav", _, _, _, _, 1.0);
					EmitSoundToAll("ambient/energy/whiteflash.wav", _, _, _, _, 1.0);

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


					CreateTimer(0.75, Donner_Nightmare_Offset, npc.index, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				npc.StartPathing();
				
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
		}
	}
	else
	{
		npc.FaceTowards(vecTarget, 100.0);
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
	}
}
#define DONNERKRIEG_HEAVENS_FALL_MAX_DIST 500.0

#define DONNERKRIEG_HEAVENS_FALL_MAX_AMT 1

#define DONNERKRIEG_HEAVENS_FALL_AMT_1 1	//ratios
#define DONNERKRIEG_HEAVENS_FALL_AMT_2 1
#define DONNERKRIEG_HEAVENS_FALL_AMT_3 1

#define DONNERKRIEG_HEAVENS_FALL_MAX_STAGE 5.0

#define DONNERKRIEG_HEAVENS_STAGE_1 5.0	//ratios
#define DONNERKRIEG_HEAVENS_STAGE_2 1.0
#define DONNERKRIEG_HEAVENS_STAGE_3 5.0


static float DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[2] = {7.5, 12.5};	//Minimum, Maximum Time

static int TE_used;

static void Heavens_Fall(Raidboss_Donnerkrieg npc, float GameTime, int Infection=0 , bool creep=false)
{

	float Base_Dist=0.0;
	float Distance_Ratios = DONNERKRIEG_HEAVENS_FALL_MAX_DIST/DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;
	if(!Heavens_Fall_Clearance_Check(npc, Base_Dist, DONNERKRIEG_HEAVENS_FALL_MAX_DIST))
	{
		return;
	}

	float Timer = 80.0 *(Base_Dist/DONNERKRIEG_HEAVENS_FALL_MAX_DIST);

	if(!npc.Anger)
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer;
	else
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer*0.5;


	int Base_Amt = RoundToFloor((Base_Dist/Distance_Ratios)/DONNERKRIEG_HEAVENS_FALL_MAX_AMT);

	Base_Dist /= DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;

	

	int Amt1, Amt2, Amt3;
	float Dist1, Dist2, Dist3;

	Dist1 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_1;
	Dist2 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_2;
	Dist3 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_3;

	Amt1= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_1;
	Amt2= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_2;
	Amt3= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_3;

	TE_used=0;



	float Loc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);

	float Range = 150.0;

	float UserLoc[3];
	UserLoc = GetAbsOrigin(npc.index);
	UserLoc[2]+=75.0;

	for(int Ion=0 ; Ion < Amt1 ; Ion++)
	{

		float tempAngles[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = (360.0/Amt1)*Ion;
		tempAngles[2] = 0.0;

		Do_Trace_Heavens_Fall(Loc, tempAngles, EndLoc, Dist1);

		float dist_check1 = GetVectorDistance(Loc, EndLoc);

		if(dist_check1<Dist1*0.75)
			continue;

		for(int Ion2=0 ; Ion2 < Amt2 ; Ion2++)
		{
			float tempAngles2[3], EndLoc2[3];
			tempAngles2[0] = 0.0;
			tempAngles2[1] = (360.0/Amt2)*Ion2;
			tempAngles2[2] = 0.0;

			Do_Trace_Heavens_Fall(EndLoc, tempAngles2, EndLoc2, Dist2);

			float dist_check2 = GetVectorDistance(EndLoc, EndLoc2);

			if(dist_check2<Dist2*0.75)
				continue;
			
			for(int Ion3=0 ; Ion3 < Amt3 ; Ion3++)
			{
				float tempAngles3[3], EndLoc3[3];
				tempAngles3[0] = 0.0;
				tempAngles3[1] = (360.0/Amt3)*Ion3;
				tempAngles3[2] = 0.0;

				Do_Trace_Heavens_Fall(EndLoc2, tempAngles3, EndLoc3, Dist3);

				float dist_check3 = GetVectorDistance(EndLoc2, EndLoc3);

				if(dist_check3<Dist3*0.75)
					continue;

				Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, EndLoc3);

				float Time = GetRandomFloat(DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[0], DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[1]);
				int color[4];
				color[0] = 240;
				color[1] = 240;
				color[2] = 240;
				color[3] = 175;

				EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, Loc);

				TE_used += 1;
				if(TE_used > 31)
				{
					int DelayFrames = (TE_used / 32);
					DelayFrames *= 2;
					DataPack pack_TE = new DataPack();
					pack_TE.WriteCell(EndLoc3[0]);
					pack_TE.WriteCell(EndLoc3[1]);
					pack_TE.WriteCell(EndLoc3[2]);
					pack_TE.WriteCell(UserLoc[0]);
					pack_TE.WriteCell(UserLoc[1]);
					pack_TE.WriteCell(UserLoc[2]);
					pack_TE.WriteCell(color[0]);
					pack_TE.WriteCell(color[1]);
					pack_TE.WriteCell(color[2]);
					pack_TE.WriteCell(color[3]);
					pack_TE.WriteCell(SPRITE_INT_2);

					RequestFrames(Doonerkrieg_Delay_TE_Beam2, DelayFrames, pack_TE);
					//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
				}
				else
				{	
					TE_SetupBeamPoints(UserLoc, EndLoc3, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
					TE_SendToAll();
				}
				
				Handle data;
				CreateDataTimer(Time, Smite_Timer_Donner, data, TIMER_FLAG_NO_MAPCHANGE);
				WritePackFloat(data, EndLoc3[0]);
				WritePackFloat(data, EndLoc3[1]);
				WritePackFloat(data, EndLoc3[2]);
				WritePackCell(data, Range); // Range
				WritePackCell(data, EntIndexToEntRef(npc.index));
				WritePackCell(data, Infection);
				WritePackCell(data, color[0]);
				WritePackCell(data, color[1]);
				WritePackCell(data, color[2]);
				WritePackCell(data, color[3]);
				WritePackCell(data, creep);
				

				TE_used += 1;
				if(TE_used > 31)
				{
					int DelayFrames = (TE_used / 32);
					DelayFrames *= 2;
					DataPack pack_TE = new DataPack();
					pack_TE.WriteCell(EndLoc3[0]);
					pack_TE.WriteCell(EndLoc3[1]);
					pack_TE.WriteCell(EndLoc3[2]);
					pack_TE.WriteCell(color[0]);
					pack_TE.WriteCell(color[1]);
					pack_TE.WriteCell(color[2]);
					pack_TE.WriteCell(color[3]);
					pack_TE.WriteCell(Range);
					pack_TE.WriteCell(Time);
					RequestFrames(Doonerkrieg_Delay_TE_Ring, DelayFrames, pack_TE);
					//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
				}
				else
				{
					spawnRing_Vectors(EndLoc3, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, Time, 6.0, 0.1, 1, 1.0);
				}
			}
		}
	}
	TE_used=0;
}

static bool Heavens_Fall_Clearance_Check(Raidboss_Donnerkrieg npc, float &Return_Dist, float Max_Distance)
{
	
	float UserLoc[3], Angles[3];
	UserLoc = GetAbsOrigin(npc.index);
	Max_Distance+=Max_Distance*0.1;
	float distance = Max_Distance;
	float Distances[361];
	
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
	
		Handle trace = TR_TraceRayFilterEx(UserLoc, Angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			
			float flDistanceToTarget = GetVectorDistance(endPoint, UserLoc);

			Distances[alpha] = flDistanceToTarget;
			
			if(flDistanceToTarget>250.0)
			{
				Total_Hit++;
				if(flDistanceToTarget>=Max_Distance)
					Distances[alpha]=Max_Distance;
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
		delete trace;
	}
	float Avg=0.0;
	for(int alpha = 1 ; alpha<=360 ; alpha++)
	{
		Avg+=Distances[alpha];
	}
	Avg /=360.0;
	Return_Dist = Avg;
	if(Total_Hit/360>=0.75)
	{
		return true;
	}
	else
	{
		return false;
	}
}

static void Do_Trace_Heavens_Fall(float startPoint[3], float Angles[3], float Loc[3], float Dist)
{

	Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(Loc, trace);
		delete trace;

		float distance = GetVectorDistance(startPoint, Loc);

		if(distance>Dist)
		{
			Get_Fake_Forward_Vec(Dist, Angles, Loc, startPoint);
		}
		
	}
	else
	{
		delete trace;
	}
}

public Action Smite_Timer_Donner(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	int Infection = ReadPackCell(data);
	int Color[4];
	Color[0] = ReadPackCell(data);
	Color[1] = ReadPackCell(data);
	Color[2] = ReadPackCell(data);
	Color[3] = ReadPackCell(data);
	bool creep  = ReadPackCell(data);
	
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);

	Doonerkrieg_Do_AOE_Damage(npc, startPosition, 100.0, Ionrange, 0.4, Infection);

	if(creep)	//if creep, create the cancer thing.
	{

	}

	TE_used += 1;
	if(TE_used > 31)
	{
		int DelayFrames = (TE_used / 32);
		DelayFrames *= 2;
		DataPack pack_TE = new DataPack();
		pack_TE.WriteCell(startPosition[0]);
		pack_TE.WriteCell(startPosition[1]);
		pack_TE.WriteCell(startPosition[2]);
		RequestFrames(Doonerkrieg_Delay_TE_Explosion, DelayFrames, pack_TE);
		//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
	}
	else
	{
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
	}

	
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 999.0;
	startPosition[2] += -200;

	float time[4], start[4], end[4];
	time[0]=2.2; start[0] = 30.0; end[0] = 30.0;
	time[1]=2.1; start[1] = 50.0; end[1] = 50.0;
	time[2]=2.0; start[2] = 70.0; end[2] = 70.0;
	time[3]=1.9; start[3] = 90.0; end[3] = 90.0;


	for(int i=0 ; i < 4 ; i ++)
	{
		TE_used += 1;
		if(TE_used > 31)
		{
			int DelayFrames = (TE_used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(startPosition[0]);
			pack_TE.WriteCell(startPosition[1]);
			pack_TE.WriteCell(startPosition[2]);
			pack_TE.WriteCell(position[0]);
			pack_TE.WriteCell(position[1]);
			pack_TE.WriteCell(position[2]);
			pack_TE.WriteCell(Color[0]);
			pack_TE.WriteCell(Color[1]);
			pack_TE.WriteCell(Color[2]);
			pack_TE.WriteCell(Color[3]);
			pack_TE.WriteCell(time[i]);
			pack_TE.WriteCell(start[i]);
			pack_TE.WriteCell(end[i]);
			RequestFrames(Doonerkrieg_Delay_TE_Beam, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			TE_SetupBeamPoints(startPosition, position, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time[i], start[i], end[i], 0, 1.0, Color, 3);
			TE_SendToAll();
		}
	}
	
	position[2] = startPosition[2] + 50.0;
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	return Plugin_Continue;
}

public void Doonerkrieg_Delay_TE_Ring(DataPack pack)
{
	pack.Reset();
	float endLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Time = pack.ReadCell();

	spawnRing_Vectors(endLoc, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, Time, 6.0, 0.1, 1, 1.0);
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Beam(DataPack pack)
{
	pack.Reset();
	float endLoc[3], StartLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	StartLoc[0] = pack.ReadCell();
	StartLoc[1] = pack.ReadCell();
	StartLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	float time = pack.ReadCell();
	float start = pack.ReadCell();
	float end = pack.ReadCell();

	TE_SetupBeamPoints(StartLoc, endLoc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, 1.0, color, 3);
	TE_SendToAll();
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Explosion(DataPack pack)
{
	pack.Reset();
	float endLoc[3];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();

	TE_SetupExplosion(endLoc, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Beam2(DataPack pack)
{
	pack.Reset();
	float endLoc[3], StartLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	StartLoc[0] = pack.ReadCell();
	StartLoc[1] = pack.ReadCell();
	StartLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	int SPRITE_INT_2 = pack.ReadCell();
					
	TE_SetupBeamPoints(StartLoc, endLoc, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
	TE_SendToAll();
		
	delete pack;
}

static bool b_cannon_sound_created[MAXENTITIES];

static Action Donner_Nightmare_Offset(Handle timer, int client)
{
	if(IsValidEntity(client))
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);

		f_NpcTurnPenalty[npc.index] = 0.1;	//:)
		npc.SetPlaybackRate(0.0);
		npc.SetCycle(0.227);
		ParticleEffectAt(WorldSpaceCenter(npc.index), "eyeboss_death_vortex", 1.0);
		b_cannon_sound_created[npc.index]=false;
		EmitSoundToAll("mvm/mvm_tank_ping.wav");
		fl_nightmare_end_timer[npc.index] = GetGameTime(npc.index) + 31.5;
		Donnerkrieg_Main_Nightmare_Cannon(npc);
	}
	return Plugin_Handled;
}
/*
							PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_1, true);
PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_BEGIN_SOUND_2, true);

PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND, true);

PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1, true);
PrecacheSound(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2, true);
*/
static void Start_Donner_Main_Cannon_Sound(int client)
{
	b_cannon_sound_created[client]=true;

	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND1, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND2, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND3, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND4, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND5, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND6, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE1, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE2, client, SNDCHAN_STATIC, 100, _, 1.0, 75);
	EmitSoundToAll(DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE3, client, SNDCHAN_STATIC, 100, _, 1.0, 75);

}

static void Kill_Donner_Main_Cannon_Sound(int client)
{
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND1);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND2);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND3);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND4);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND5);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND6);

	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA1);

	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_EXTRA2);

	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE1);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE2);
	StopSound(client, SNDCHAN_STATIC, DONNERKRIEG_NIGHTMARE_CANNON_LOOP_SOUND_CORE3);
}
public Action Raidboss_Donnerkrieg_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(attacker < MAXTF2PLAYERS)
		Donnerkrieg_Set_Sniper_Threat_Value(npc, attacker, damage, weapon);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
static void Donnerkrieg_Set_Sniper_Threat_Value(Raidboss_Donnerkrieg npc, int PrimaryThreatIndex, float damage, int weapon)
{
	if(!IsValidEntity(weapon))
		return;
		
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
	
	float GameTime = GetGameTime(npc.index);
	
	if(flDistanceToTarget >(2000.0 * 2000.0))
	{
		char classname[32];
		GetEntityClassname(weapon, classname, 32);
	
		int weapon_slot = TF2_GetClassnameSlot(classname);
	
		if(weapon_slot == 0)	//check if its a primary, primarly checking if the player is using a long range weapon | Ideally if I could I would check if there holding a sniper weapon type, but idk how to do that
		{
			float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			
			float amt = damage / (MaxHealth/10.0);
			
			fl_schwertkrieg_sniper_rampage_timer = GameTime + RAIDBOSS_DONNERKRIEG_SCHWERTKRIEG_SNIPER_RAMPAGE_REFRESH_TIME;
			fl_donner_sniper_threat_value[PrimaryThreatIndex]+= amt;
			b_donner_valid_sniper_threats[PrimaryThreatIndex] = true;	//this player is now a valid target for schwert to focus if schwert goes into anti sniper mode
			fl_donner_sniper_threat_timer_clean[PrimaryThreatIndex] = GameTime + RAIDBOSS_DONNERKRIEG_SNIPER_CLEAN_TIMER;
		}
	}
	
	float threat_ammount = 0.0;
	for(int client=0 ; client <MAXTF2PLAYERS ; client++)
	{
		threat_ammount += fl_donner_sniper_threat_value[client];
	}
		
	if(threat_ammount>0.25 && !b_schwert_focus_snipers)
	{
		b_schwert_focus_snipers = true;
	}
	if(threat_ammount<0.25)
		b_schwert_focus_snipers = false;
}

public void Raidboss_Donnerkrieg_NPCDeath(int entity)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Kill_Donner_Main_Cannon_Sound(npc.index);

	shared_goal = false;
	b_raidboss_donnerkrieg_alive = false;

	Donnerkrieg_Delete_Wings(npc);
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.
	
	if(b_raidboss_schwertkrieg_alive)	//handover the hud to schwert
	{
		RaidBossActive = EntRefToEntIndex(i_ally_index);
	}
	
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	SDKUnhook(npc.index, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
		
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
	if(IsValidEntity(npc.m_iWearable7))	
		RemoveEntity(npc.m_iWearable7);

	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][0])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][0]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][1])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][1]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][2])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][2]));


	
}
static bool b_hit_something;
static bool Donnerkrieg_Is_Target_Infront(Raidboss_Donnerkrieg npc, float Radius, float &dist=0.0)
{
	float startPoint[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(npc.index);
	startPoint[2] += 50.0;
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return false;
			
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(npc.index);
	startPoint[2] += 50.0;

	b_hit_something=false;
	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		float endPoint[3];
		TR_GetEndPosition(endPoint, trace);
		delete trace;

		dist = GetVectorDistance(startPoint, endPoint, true);

		static float hullMin[3];
		static float hullMax[3];
		hullMin[0] = -Radius;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Check_Target, npc.index);	// 1073741824 is CONTENTS_LADDER?
		if(b_hit_something)
		{
			delete trace;
			return true;
		}
		else
		{
			delete trace;
		}
	}		
	else
	{
		delete trace;
	}
	

	return false;
}
static bool Check_Target(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		if(GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(entity, Prop_Send, "m_iTeamNum"))
			b_hit_something=true;
	}
	return false;
}
static float fl_normal_attack_duration[MAXENTITIES];
static void Donnerkrieg_Normal_Attack(Raidboss_Donnerkrieg npc, float GameTime, float flDistanceToTarget, float vecTarget[3])
{
	if(npc.m_flNextMeleeAttack < GameTime && !npc.m_flAttackHappenswillhappen)
	{
		if(flDistanceToTarget < (2500.0*2500.0))
		{
			if(Donnerkrieg_Is_Target_Infront(npc, 75.0))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = GameTime+0.2;
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flAttackHappenswillhappen=true;
			}
			else
			{
				npc.FaceTowards(vecTarget);
			}
		}
	}
	else if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappenswillhappen)
	{
		npc.FaceTowards(vecTarget, 20000.0);
		npc.m_flAttackHappenswillhappen=false;
		npc.m_flNextMeleeAttack=GameTime +1.0;
		fl_normal_attack_duration[npc.index] = GameTime+0.25;
		Donnerkrieg_Shoot_Laser(npc);
	}
}
static void Donnerkrieg_Shoot_Laser(Raidboss_Donnerkrieg npc)
{
	SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Laser_Think);
	SDKHook(npc.index, SDKHook_Think, Donnerkrieg_Laser_Think);
}
public Action Donnerkrieg_Laser_Think(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(fl_normal_attack_duration[npc.index]<GameTime)
	{
		SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Laser_Think);
		return Plugin_Stop;
	}

	float angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return Plugin_Continue;

	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;

	float flAng[3]; // original
	float startPoint[3];
	GetAttachment(npc.index, "effect_hand_r", startPoint, flAng);

	float radius = 25.0;

	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, NightmareCannon_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		float endPoint[3];
		TR_GetEndPosition(endPoint, trace);
		delete trace;

		Donnerkrieg_Laser_Trace(npc, startPoint, endPoint, radius, 15.0*RaidModeScaling, 2);

		float diameter = radius *1.0;
		int r=255, g=255, b=255, a=30;
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, a);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, a);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, a);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
		TE_SetupBeamPoints(startPoint, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(startPoint, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(startPoint, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(startPoint, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, a);
		TE_SetupBeamPoints(startPoint, endPoint, DonnerKriegCannon_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter*1.5), ClampBeamWidth(diameter*0.75), 0, 2.5, glowColor, 0);
		TE_SendToAll(0.0);

	}
	else
	{
		delete trace;
	}

	return Plugin_Continue;
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static float fl_initial_windup[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_explosion_thorttle[MAXENTITIES];
static void Donnerkrieg_Main_Nightmare_Cannon(Raidboss_Donnerkrieg npc)
{
	npc.m_bInKame=true;
	fl_initial_windup[npc.index] = GetGameTime(npc.index)+1.5;
	fl_explosion_thorttle[npc.index]=0.0;
	fl_spinning_angle[npc.index]=0.0;
	SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
	SDKHook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
}
public Action Donnerkrieg_Main_Nightmare_Tick(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(fl_nightmare_end_timer[npc.index]<GameTime)
	{
		Kill_Donner_Main_Cannon_Sound(npc.index);
		npc.m_bInKame=false;
		SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
		return Plugin_Stop;
	}

	float angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return Plugin_Continue;

	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;

	float Pos[3];
	Pos = GetAbsOrigin(npc.index);
	Pos[2]+=50.0;


	fl_spinning_angle[npc.index]+=2.5;
		
	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index] = 0.0;

	float Start_Loc[3];

	Get_Fake_Forward_Vec(30.0, angles, Start_Loc, Pos);

	float radius = 75.0;

	Handle trace = TR_TraceRayFilterEx(Start_Loc, angles, 11, RayType_Infinite, NightmareCannon_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		float endPoint[3];
		TR_GetEndPosition(endPoint, trace);
		delete trace;

		float Dist = GetVectorDistance(Start_Loc, endPoint);

		Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 5, Dist, false, radius, 1.0);			//5
		Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 3, Dist, false, radius/3.0, 2.0);		//15
		Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 3, Dist, false, radius/3.0, -2.0);		//18

		if(fl_initial_windup[npc.index] < GameTime)
		{

			//npc.PlayNightmareSound();

			if(!b_cannon_sound_created[npc.index])
				Start_Donner_Main_Cannon_Sound(npc.index);

			Donnerkrieg_Laser_Trace(npc, Start_Loc, endPoint, radius*0.75, 90.0*RaidModeScaling);

			Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, true, radius/2.0, -1.0);		//12

			float diameter = radius *0.75;

			int r=100, g=100, b=100, a=60;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, colorLayer4[3]* 7 + 765 / 8);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, colorLayer4[3]* 6 + 765 / 8);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, colorLayer4[3]* 5 + 765 / 8);
			TE_SetupBeamPoints(Start_Loc, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(Start_Loc, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(Start_Loc, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(Start_Loc, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, a);
			TE_SetupBeamPoints(Start_Loc, endPoint, DonnerKriegCannon_BEAM_Glow, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter*1.5), ClampBeamWidth(diameter*0.75), 0, 2.5, glowColor, 0);
			TE_SendToAll(0.0);

			if(fl_explosion_thorttle[npc.index]<GameTime)	//use a particle instead of this for fancyness of fancy
			{
				fl_explosion_thorttle[npc.index]=GameTime+0.1;
				TE_SetupExplosion(endPoint, gExplosive1, 10.0, 1, 0, 0, 0);
				TE_SendToAll();
			}

			
		}
		else
		{
			Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, false, radius/2.0, -1.0);		//12
		}
	}
	else
	{
		delete trace;
	}

	return Plugin_Continue;
}
static void Donnerkrieg_Create_Spinning_Beams(Raidboss_Donnerkrieg npc, float Origin[3], float Angles[3], int loop_for, float Main_Beam_Dist, bool Type=true, float distance_stuff, float ang_multi)
{
	
	float buffer_vec[10][3];
		
	for(int i=1 ; i<=loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3], End_Loc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (fl_spinning_angle[npc.index]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		Get_Fake_Forward_Vec(Main_Beam_Dist, Angles, End_Loc, endLoc);
		
		if(Type)
		{
			int r=1, g=1, b=255, a=225;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, End_Loc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	int color[4]; color[0] = 1; color[1] = 255; color[2] = 255; color[3] = 255;
	
	TE_SetupBeamPoints(buffer_vec[1], buffer_vec[loop_for], DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=1 ; i<loop_for ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}
static void Donnerkrieg_Laser_Trace(Raidboss_Donnerkrieg npc, float Start_Point[3], float End_Point[3], float Radius, float dps, int infection=0)
{

	for (int i = 1; i < MAXENTITIES; i++)
	{
		DonnerKriegCannon_BEAM_HitDetected[i] = false;
	}

	float hullMin[3], hullMax[3];
	hullMin[0] = -Radius;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(Start_Point, End_Point, hullMin, hullMax, 1073741824, DonnerKriegCannon_BEAM_TraceUsers, npc.index);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (DonnerKriegCannon_BEAM_HitDetected[victim] && GetEntProp(npc.index, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
		{
			float playerPos[3];
			switch(infection)
			{
				case 0:
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

					float Dmg = dps;

					if(ShouldNpcDealBonusDamage(victim))
					{
						Dmg *= 5.0;
					}
					SDKHooks_TakeDamage(victim, npc.index, npc.index, (Dmg/6), DMG_PLASMA, -1, NULL_VECTOR, Start_Point);
				}
				case 1:
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

					float Dmg = dps/2.0;
					if(ShouldNpcDealBonusDamage(victim))
					{
						Dmg *= 5.0;
					}
					SDKHooks_TakeDamage(victim, npc.index, npc.index, (Dmg/12), DMG_PLASMA, -1, NULL_VECTOR, Start_Point);

					int damage = RoundToFloor(dps*0.01);
					if(damage < 4)
						damage = 4;

					SeaSlider_AddNeuralDamage(victim, npc.index, damage, false);
				}
				case 2:
				{
					int damage = RoundToFloor(dps*0.05);
					if(damage < 8)
						damage = 8;

					SeaSlider_AddNeuralDamage(victim, npc.index, damage, false);
				}
				
			}
			if(victim <= MaxClients)
				Client_Shake(victim, 0, 8.0, 8.0, 0.1);
		}
	}
}

public bool DonnerKriegCannon_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

public bool DonnerKriegCannon_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		DonnerKriegCannon_BEAM_HitDetected[entity] = true;
	}
	return false;
}

#define DONNERKRIEG_PARTICLE_EFFECT_AMT 30
static int i_donner_particle_index[MAXENTITIES][DONNERKRIEG_PARTICLE_EFFECT_AMT];

static void Donnerkrieg_Delete_Wings(Raidboss_Donnerkrieg npc)
{

	for(int i=0 ; i < DONNERKRIEG_PARTICLE_EFFECT_AMT ; i++)
	{
		int particle = EntRefToEntIndex(i_donner_particle_index[npc.index][i]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		i_donner_particle_index[npc.index][i]=INVALID_ENT_REFERENCE;
	}
}

static void Donnerkrieg_Wings_Create(Raidboss_Donnerkrieg npc)
{

	if(AtEdictLimit(EDICT_RAID))
		return;

	Donnerkrieg_Delete_Wings(npc);

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];


	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(npc.index, "back_lower", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(npc.index, ParticleOffsetMain, "back_lower",_);


	//Left

	float core_loc[3] = {0.0, 15.0, -20.0};


	//upper left

	int particle_upper_left_core = InfoTargetParentAt(core_loc, "", 0.0);


	
	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_upper_left_wing_1 = InfoTargetParentAt({7.5, 0.0, -9.5}, "", 0.0);	//middle mid
	int particle_upper_left_wing_2 = InfoTargetParentAt({20.5, 10.0, -15.0}, "", 0.0);		//middle lower
	int particle_upper_left_wing_3 = InfoTargetParentAt({5.0, -25.0, 0.0}, "", 0.0);		//middle up	

	int particle_upper_left_wing_4 = InfoTargetParentAt({50.0, -15.0, 5.0}, "", 0.0);	//side up
	int particle_upper_left_wing_5 = InfoTargetParentAt({60.0, -10.0, 10.0}, "", 0.0);	//side mid
	int particle_upper_left_wing_6 = InfoTargetParentAt({55.0, 0.0, 2.5}, "", 0.0);	//side low


	SetParent(particle_upper_left_core, particle_upper_left_wing_1, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_2, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_3, "",_, true);

	SetParent(particle_upper_left_core, particle_upper_left_wing_4, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_5, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_6, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_upper_left_core, flPos);
	SetEntPropVector(particle_upper_left_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_upper_left_core, "",_);

	//start_1 = 2.0;
	//end_1 = 0.5;
	//amp =0.1;

	int laser_upper_left_wing_1 = ConnectWithBeamClient(particle_upper_left_wing_1, particle_upper_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);
	int laser_upper_left_wing_2 = ConnectWithBeamClient(particle_upper_left_wing_1, particle_upper_left_wing_3, red, green, blue, start_1, start_1, amp, LASERBEAM);
	
	int laser_upper_left_wing_3 = ConnectWithBeamClient(particle_upper_left_wing_5, particle_upper_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_upper_left_wing_4 = ConnectWithBeamClient(particle_upper_left_wing_5, particle_upper_left_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_upper_left_wing_5 = ConnectWithBeamClient(particle_upper_left_wing_3, particle_upper_left_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_upper_left_wing_6 = ConnectWithBeamClient(particle_upper_left_wing_2, particle_upper_left_wing_6, red, green, blue, start_1, end_1, amp, LASERBEAM);

	int laser_upper_left_wing_7 = ConnectWithBeamClient(particle_upper_left_wing_4, particle_upper_left_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);


	
	i_donner_particle_index[npc.index][0] = EntIndexToEntRef(ParticleOffsetMain);
	i_donner_particle_index[npc.index][1] = EntIndexToEntRef(particle_upper_left_core);
	i_donner_particle_index[npc.index][2] = EntIndexToEntRef(laser_upper_left_wing_1);
	i_donner_particle_index[npc.index][3] = EntIndexToEntRef(laser_upper_left_wing_2);
	i_donner_particle_index[npc.index][4] = EntIndexToEntRef(laser_upper_left_wing_3);
	i_donner_particle_index[npc.index][5] = EntIndexToEntRef(laser_upper_left_wing_4);
	i_donner_particle_index[npc.index][6] = EntIndexToEntRef(laser_upper_left_wing_5);
	i_donner_particle_index[npc.index][7] = EntIndexToEntRef(laser_upper_left_wing_6);
	i_donner_particle_index[npc.index][8] = EntIndexToEntRef(laser_upper_left_wing_7);

	i_donner_particle_index[npc.index][9] = EntIndexToEntRef(particle_upper_left_wing_1);
	i_donner_particle_index[npc.index][10] = EntIndexToEntRef(particle_upper_left_wing_2);
	i_donner_particle_index[npc.index][11] = EntIndexToEntRef(particle_upper_left_wing_3);
	i_donner_particle_index[npc.index][12] = EntIndexToEntRef(particle_upper_left_wing_4);
	i_donner_particle_index[npc.index][13] = EntIndexToEntRef(particle_upper_left_wing_5);
	i_donner_particle_index[npc.index][14] = EntIndexToEntRef(particle_upper_left_wing_6);


	//upper right

	int particle_upper_right_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_upper_right_wing_1 = InfoTargetParentAt({-7.5, 0.0, -9.5}, "", 0.0);	//middle mid
	int particle_upper_right_wing_2 = InfoTargetParentAt({-20.5, 10.0, -15.0}, "", 0.0);		//middle lower
	int particle_upper_right_wing_3 = InfoTargetParentAt({-5.0, -25.0, 0.0}, "", 0.0);		//middle up	

	int particle_upper_right_wing_4 = InfoTargetParentAt({-50.0, -15.0, 5.0}, "", 0.0);	//side up
	int particle_upper_right_wing_5 = InfoTargetParentAt({-60.0, -10.0, 10.0}, "", 0.0);	//side mid
	int particle_upper_right_wing_6 = InfoTargetParentAt({-55.0, 0.0, 2.5}, "", 0.0);	//side low


	SetParent(particle_upper_right_core, particle_upper_right_wing_1, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_2, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_3, "",_, true);

	SetParent(particle_upper_right_core, particle_upper_right_wing_4, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_5, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_6, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_upper_right_core, flPos);
	SetEntPropVector(particle_upper_right_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_upper_right_core, "",_);

	//start_1 = 2.0;
	//end_1 = 0.5;
	//amp =0.1;

	int laser_upper_right_wing_1 = ConnectWithBeamClient(particle_upper_right_wing_1, particle_upper_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);
	int laser_upper_right_wing_2 = ConnectWithBeamClient(particle_upper_right_wing_1, particle_upper_right_wing_3, red, green, blue, start_1, start_1, amp, LASERBEAM);
	
	int laser_upper_right_wing_3 = ConnectWithBeamClient(particle_upper_right_wing_5, particle_upper_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_upper_right_wing_4 = ConnectWithBeamClient(particle_upper_right_wing_5, particle_upper_right_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_upper_right_wing_5 = ConnectWithBeamClient(particle_upper_right_wing_3, particle_upper_right_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_upper_right_wing_6 = ConnectWithBeamClient(particle_upper_right_wing_2, particle_upper_right_wing_6, red, green, blue, start_1, end_1, amp, LASERBEAM);

	int laser_upper_right_wing_7 = ConnectWithBeamClient(particle_upper_right_wing_4, particle_upper_right_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	i_donner_particle_index[npc.index][15] = EntIndexToEntRef(particle_upper_right_core);
	i_donner_particle_index[npc.index][16] = EntIndexToEntRef(laser_upper_right_wing_1);
	i_donner_particle_index[npc.index][17] = EntIndexToEntRef(laser_upper_right_wing_2);
	i_donner_particle_index[npc.index][18] = EntIndexToEntRef(laser_upper_right_wing_3);
	i_donner_particle_index[npc.index][19] = EntIndexToEntRef(laser_upper_right_wing_4);
	i_donner_particle_index[npc.index][20] = EntIndexToEntRef(laser_upper_right_wing_5);
	i_donner_particle_index[npc.index][21] = EntIndexToEntRef(laser_upper_right_wing_6);
	i_donner_particle_index[npc.index][22] = EntIndexToEntRef(laser_upper_right_wing_7);

	i_donner_particle_index[npc.index][23] = EntIndexToEntRef(particle_upper_right_wing_1);
	i_donner_particle_index[npc.index][24] = EntIndexToEntRef(particle_upper_right_wing_2);
	i_donner_particle_index[npc.index][25] = EntIndexToEntRef(particle_upper_right_wing_3);
	i_donner_particle_index[npc.index][26] = EntIndexToEntRef(particle_upper_right_wing_4);
	i_donner_particle_index[npc.index][27] = EntIndexToEntRef(particle_upper_right_wing_5);
	i_donner_particle_index[npc.index][28] = EntIndexToEntRef(particle_upper_right_wing_6);
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
static void Doonerkrieg_Do_AOE_Damage(Raidboss_Donnerkrieg npc, float loc[3], float damage, float Range, float FallOff, int infection = 0)
{
	for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
	{
		if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
		{
			float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
			float distance = GetVectorDistance(client_loc, loc, true);
			{
				if(distance< (Range * Range))
				{
					float ratio = (1.0 - (distance / (fl_heavens_radius * fl_heavens_radius)));
					if(ratio<FallOff)
						ratio = FallOff;
					float fake_damage = damage*ratio;	//reduce damage if the target just grazed it.

					switch(infection)
					{
						case 0:
						{
							SDKHooks_TakeDamage(client, npc.index, npc.index, fake_damage, DMG_CLUB, _, _, loc);
							Client_Shake(client, 0, 5.0, 15.0, 0.1);
						}
						case 1:
						{
							SDKHooks_TakeDamage(client, npc.index, npc.index, fake_damage, DMG_CLUB, _, _, loc);
							Client_Shake(client, 0, 5.0, 15.0, 0.1);

							int neural_damage = RoundToFloor(damage*0.1);
							if(neural_damage < 4)
								neural_damage = 4;

							SeaSlider_AddNeuralDamage(client, npc.index, neural_damage, false);
						}
						case 3:
						{
							int neural_damage = RoundToFloor(damage*0.1);
							if(neural_damage < 8)
								neural_damage = 8;

							SeaSlider_AddNeuralDamage(client, npc.index, neural_damage, false);
						}
					}	
				}	
			}
		}
	}

	for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)	// now murder red npc's :)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally])
		{
			float target_vec[3]; target_vec = GetAbsOrigin(ally);
			float dist=GetVectorDistance(loc, target_vec, true);

			if(dist< (fl_heavens_radius * fl_heavens_radius))
			{
				float ratio = (1.0 - (dist / (fl_heavens_radius * fl_heavens_radius)));
				if(ratio<0.4)
					ratio = 0.4;	// L + Ratio. :3
				float fake_damage = damage*ratio;	//reduce damage if the target just grazed it.

				if(ShouldNpcDealBonusDamage(ally))	//kill
				{
					fake_damage *=10.0;
				}
				SDKHooks_TakeDamage(ally, npc.index, npc.index, fake_damage, DMG_CLUB, _, _, loc);
			}
		}
	}
}