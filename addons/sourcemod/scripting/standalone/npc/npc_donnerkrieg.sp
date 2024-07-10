#pragma semicolon 1
#pragma newdecls required

static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];
static float fl_normal_attack_duration[MAXENTITIES];
/*
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
};*/


static const char g_heavens_fall_strike_sound[][] = {
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
static const char g_MeleeAttackSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
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

bool schwert_retreat;

static int i_ally_index;
static float RaidModeScaling;

static int DonnerKriegCannon_BEAM_Glow;
static int DonnerKriegCannon_BEAM_Laser;

bool b_raidboss_donnerkrieg_alive;

static bool b_InKame[MAXENTITIES];

static int g_ProjectileModelRocket;
static int g_particleImpactTornado;

bool b_Crystal_active;
static bool b_Crystal_Thrown;
static int i_crystal_index;

static bool b_angered_twice[MAXENTITIES];

//static float fl_divine_intervention_retry;

#define DONNERKRIEG_NIGHTMARE_CANNON_INTRO_LINE 1
#define DONNERKRIEG_NIGHTMARE_CANNON_FIRE_LINE 2
#define DONNERKRIEG_WIN_LINE 3

#define DONNERKRIEG_HEAVENS_LIGHT_START_SOUND "mvm/mvm_tank_horn.wav"
#define DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND "ambient/levels/citadel/zapper_ambient_loop1.wav"
#define DONNERKRIEG_HEAVENS_LIGHT_TOUCHDOWN_SOUND "mvm/ambient_mp3/mvm_siren.mp3"

#define SOUND_BLITZ_IMPACT_1 					"physics/flesh/flesh_impact_bullet1.wav"	//We hit flesh, we are also kinetic, yes.
#define SOUND_BLITZ_IMPACT_2 					"physics/flesh/flesh_impact_bullet2.wav"
#define SOUND_BLITZ_IMPACT_3 					"physics/flesh/flesh_impact_bullet3.wav"
#define SOUND_BLITZ_IMPACT_4 					"physics/flesh/flesh_impact_bullet4.wav"
#define SOUND_BLITZ_IMPACT_5 					"physics/flesh/flesh_impact_bullet5.wav"

#define SOUND_BLITZ_IMPACT_CONCRETE_1		"physics/concrete/concrete_impact_bullet1.wav"//we hit the ground? HOW DARE YOU MISS?
#define SOUND_BLITZ_IMPACT_CONCRETE_2 		"physics/concrete/concrete_impact_bullet2.wav"
#define SOUND_BLITZ_IMPACT_CONCRETE_3 		"physics/concrete/concrete_impact_bullet3.wav"
#define SOUND_BLITZ_IMPACT_CONCRETE_4 		"physics/concrete/concrete_impact_bullet4.wav"

#define DONNERKRIEG_NIGHTMARE_CANNON_DURATION 15.0

#define BLITZLIGHT_SPRITE	  "materials/sprites/laserbeam.vmt"

bool b_donner_said_win_line;

//static bool b_spawn_bob;

//float fl_divine_intervention_active;

#define RUINA_BALL_PARTICLE_BLUE "drg_manmelter_trail_blue"
#define RUINA_BALL_PARTICLE_RED "drg_manmelter_trail_red"

void Raidboss_Donnerkrieg_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_heavens_fall_strike_sound);

	
	//PrecacheSoundArray(g_nightmare_cannon_core_sound);

	//for (int i = 0; i < (sizeof(g_nightmare_cannon_core_sound));   i++) { PrecacheSoundCustom(g_nightmare_cannon_core_sound[i]);	}

	Zero(fl_nightmare_cannon_core_sound_timer);

	g_ProjectileModelRocket = PrecacheModel("models/props_moonbase/moon_gravel_crystal_blue.mdl");
	g_particleImpactTornado = PrecacheParticleSystem("lowV_debrischunks");
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	DonnerKriegCannon_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	DonnerKriegCannon_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);

	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_1);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_2);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_3);
	PrecacheSound(SOUND_BLITZ_IMPACT_CONCRETE_4);
	
	PrecacheSound(SOUND_BLITZ_IMPACT_1);
	PrecacheSound(SOUND_BLITZ_IMPACT_2);
	PrecacheSound(SOUND_BLITZ_IMPACT_3);
	PrecacheSound(SOUND_BLITZ_IMPACT_4);
	PrecacheSound(SOUND_BLITZ_IMPACT_5);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
	PrecacheSoundCustom("#zombiesurvival/seaborn/donner_schwert_5.mp3");

	PrecacheSound("misc/halloween/gotohell.wav");

	PrecacheSound("vo/medic_sf13_influx_big02.mp3", true);
	
	Heavens_Beam = PrecacheModel(BLITZLIGHT_SPRITE);

	PrecacheSound(DONNERKRIEG_HEAVENS_LIGHT_START_SOUND, true);
	PrecacheSound(DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND, true);
	PrecacheSound(DONNERKRIEG_HEAVENS_LIGHT_TOUCHDOWN_SOUND, true);


	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);

	PrecacheSound("ambient/energy/whiteflash.wav", true);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Donnerkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_donnerkrieg");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, const float vecPos[3], const float vecAng[3], int team, const char[] data)
{
	return Raidboss_Donnerkrieg(client, vecPos, vecAng, team, data);
}
methodmap Raidboss_Donnerkrieg < CClotBody
{
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	/*public void PlayNightmareSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime())
			return;

		EmitSoundToAll(g_nightmare_cannon_core_sound[GetRandomInt(0, sizeof(g_nightmare_cannon_core_sound) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, SNDPITCH_NORMAL);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime() + 2.25;
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayNightmareSound()");
		#endif
	}*/

	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound= GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public Raidboss_Donnerkrieg(int client, const float vecPos[3], const float vecAng[3], int ally, const char[] data)
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));

		//b_spawn_bob = false;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_raidboss_donnerkrieg_alive = true;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		b_donner_said_win_line = false;

		//fl_divine_intervention_retry = GetGameTime() + 10.0;

		//fl_divine_intervention_active=0.0;
		
		
		/*
			Will use similair logic to silvester & goggles duo
			
			Donnerkrieg is the master raidboss.
		*/

		/*
		bool final = StrContains(data, "final_item") != -1;
		if(final)
		{
			b_spawn_bob=true;
		}*/
		
		//RaidBossActive = EntIndexToEntRef(npc.index);
		//RaidAllowsBuildings = false;
		
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;
		
		//RaidModeTime = GetGameTime(npc.index) + 250.0;
		
		RaidModeScaling = 60.0;

		b_angered_twice[npc.index]=false;
		
		
		
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = 24.0;
		
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
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Donnerkrieg And Schwertkrieg Spawn");
			}
		}
		
		//Citizen_MiniBossSpawn();
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		
		
		
		//Music_SetRaidMusicSimple("#zombiesurvival/seaborn/donner_schwert_5.mp3", 290, true);
		
		b_thisNpcIsARaid[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			
		
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
		
		
		
		Heavens_Light_Active[npc.index]=false;
		fl_heavens_light_use_timer[npc.index] = GameTime + 60.0;
		b_force_heavens_light[npc.index] = false;
		//Invoke_Heavens_Light(npc, GameTime);

		fl_heavens_fall_use_timer[npc.index] = GameTime + 30.0;

		//Heavens_Fall(npc, GetGameTime(npc.index));

		schwert_retreat = false;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{aqua}Donnerkrieg{snow}: We have arrived to render judgement");
		
		Donnerkrieg_Wings_Create(npc);

		b_Crystal_Thrown=false;
		b_Crystal_active=false;

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
		
		maxhealth = RoundToFloor(maxhealth*1.5);

		int spawn_index = NPC_CreateByName("npc_schwertkrieg", entity, pos, ang, GetTeam(entity));
		if(spawn_index > MaxClients)
		{
			i_ally_index = EntIndexToEntRef(spawn_index);
			Schwertkrieg_Set_Ally_Index(entity);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}
/*
static float fl_last_ratio;

static void Calculate_Combined_Health(Raidboss_Donnerkrieg npc)
{
	if(b_spawn_bob)
	{
		int ally = EntRefToEntIndex(i_ally_index);
		if(IsValidEntity(ally))
		{
			float M_Health = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			float C_Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));

			float M_Health1 = float(GetEntProp(ally, Prop_Data, "m_iMaxHealth"));
			float C_Health1 = float(GetEntProp(ally, Prop_Data, "m_iHealth"));

			C_Health = C_Health+ C_Health1;
			M_Health = M_Health+ M_Health1;
			

			float Ratio = (C_Health/M_Health);

			

			if(Ratio < 0.75 && fl_last_ratio> 0.75)
			{
				CPrintToChatAll("SPAWN THE GOD KNOWN AS BOB!!!!");
			}

			if(fl_last_ratio!=Ratio)
			{
				fl_last_ratio = Ratio;
				CPrintToChatAll("L + Ratio: %f", Ratio);
			}
		}
	}
}*/

//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);
	
	if(b_raidboss_donnerkrieg_alive)	//I don't need this here, but I still added it...
		Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(true);	//donner first, schwert second

	//if(RaidModeTime < GetGameTime())
	//{
	//	SDKUnhook(npc.index, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
	//	return;
	//}
		
	float GameTime = GetGameTime(npc.index);

	//Calculate_Combined_Health(npc);

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
	
	//if(!IsValidEntity(RaidBossActive))
	//{
	//	RaidBossActive=EntIndexToEntRef(npc.index);
	//}

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget < 1)
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
	/*
	if(Current_Wave>=60 && !b_nightmare_logic[npc.index])
	{
		if(fl_divine_intervention_retry < GameTime)
		{
			Invoke_Divine_Intervention(npc, GameTime);
		}
	}

	if(fl_divine_intervention_active > GameTime && !b_nightmare_logic[npc.index])
	{
		return;
	}*/
	
	if(fl_nightmare_end_timer[npc.index] < GameTime && b_nightmare_logic[npc.index])
	{	
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;
		b_nightmare_logic[npc.index] = false;

		if(schwert_retreat)
			schwert_retreat=false;	//schwert goes back to normal

		fl_cannon_Recharged[npc.index] = GameTime + 45.0;

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
		
	int PrimaryThreatIndex = npc.m_iTarget;

	if(!b_nightmare_logic[npc.index])
	{
		npc.StartPathing();
		npc.m_bPathing = true;
	}
		
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_cannon_Recharged[npc.index]<GameTime && !b_nightmare_logic[npc.index] && !Heavens_Light_Active[npc.index])
		{
			fl_nightmare_end_timer[npc.index] = GameTime + 20.0;
			Raidboss_Donnerkrieg_Nightmare_Logic(npc, PrimaryThreatIndex);
			//CPrintToChatAll("Initial Donner Logic");
		}

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		if(!b_Crystal_active)
		{
			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch < 0)
				return;		
							
			//Body pitch
			float v[3], ang[3];
			float SelfVec[3]; WorldSpaceCenter(npc.index, SelfVec);
			SubtractVectors(SelfVec, vecTarget, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
									
			float flPitch = npc.GetPoseParameter(iPitch);
									
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}

		if(!b_nightmare_logic[npc.index])
		{	
			if((fl_heavens_light_use_timer[npc.index] < GameTime) || b_force_heavens_light[npc.index])
			{
				b_force_heavens_light[npc.index]=false;
				fl_heavens_light_use_timer[npc.index] = GameTime + 75.0;
				Heavens_Light_Active[npc.index]=true;

				Invoke_Heavens_Light(npc, GameTime);
			}
			if(npc.m_flAttackHappens > GameTime)
			{
				if(fl_normal_attack_duration[npc.index] < GetGameTime())
					npc.FaceTowards(vecTarget, 5000.0);
			}

			if(fl_heavens_fall_use_timer[npc.index]< GameTime)
			{
				fl_heavens_fall_use_timer[npc.index] = GameTime+1.0;	//retry in 1 seconds if failed, otherwise proper CD.

				Heavens_Fall(npc, GameTime);
			}

			Donner_Movement(npc.index, PrimaryThreatIndex, GameTime);
				
			Donnerkrieg_Normal_Attack(npc, GameTime, flDistanceToTarget, vecTarget);
					
					
			npc.StartPathing();
		}
		else
		{
			Raidboss_Donnerkrieg_Nightmare_Logic(npc, PrimaryThreatIndex);
		}
		
	}
	else
	{
		npc.StopPathing();
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
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);	
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	npc.m_flSpeed = 300.0;

	if(npc.m_bAllowBackWalking && fl_normal_attack_duration[npc.index] < GetGameTime())
		npc.FaceTowards(vecTarget, 20000.0);

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
		if(IsValidEnemy(npc.index, Enemy_I_See) && fl_cannon_Recharged[npc.index] > GameTime+2.5) //Check if i can even see.
		{		
			if(flDistanceToTarget < (125.0*125.0))
			{
				fl_backwards_failsafe[npc.index] = GameTime+2.5;
				npc.m_bAllowBackWalking=true;
				npc.StartPathing();
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);

				npc.StartPathing();
				npc.m_bPathing = true;
				if(fl_normal_attack_duration[npc.index] < GetGameTime())
					npc.FaceTowards(vecTarget, 20000.0);
			}
			else
			{
				npc.StopPathing();
				npc.m_bPathing = false;
				npc.m_bAllowBackWalking=false;

				if(fl_normal_attack_duration[npc.index] < GetGameTime())
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
			float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
						
			npc.SetGoalVector(vPredictedPos);
		} 
		else 
		{
			npc.SetGoalEntity(PrimaryThreatIndex);
		}
	}
}

public void Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(bool donner_alive)
{
	/*if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		b_donner_said_win_line = true;
		if(donner_alive)
		{
			char name_color[255]; name_color = "aqua";
			char text_color[255]; text_color = "snow";

			char text_lines[255];
			int ally = EntRefToEntIndex(i_ally_index);
			if(IsValidEntity(ally))
			{
				Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: You think thats how you fight us two?", name_color, text_color);
			}
			else
			{
				Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Oh my, how annoying this has become...", name_color, text_color);
			}
			CPrintToChatAll(text_lines);
		}
		else
		{
			CPrintToChatAll("{crimson}Schwertkrieg{snow}: Ayaya?");
		}
		
	}*/
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

static int HeavenLight_GetTarget(int ID, float loc[3])	//get the closest valid target for the heavens light.
{
	float Dist = -1.0;
	int client_id=-1;
	for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
	{
		if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
		{
			if(!b_targeted_by_heavens[client] || client==i_heavens_target_id[ID])	//if the player is already targeted, ignore him. UNLESS, we are the ones who are targeting him, then add him to the distance calcs
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance<Dist || Dist==-1.0)
					{
						Dist = distance;	//closest target is best target - idk.
						client_id = client;
					}
				}
			}
		}
	}
	if(IsValidClient(client_id))	// if the target is valid, we add a lock onto him
	{
		fl_was_targeted[client_id] = GetGameTime()+0.25;
		b_targeted_by_heavens[client_id]=true;
		i_heavens_target_id[ID]=client_id;
	}
	return client_id;	//and then we return the client id. This can often return -1, but thats intended and is dealt with
}

static void GetRandomLoc(Raidboss_Donnerkrieg npc, float Loc[3], int Num)	//directly stolen and modified from villagers building spawn code :3
{

	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	Loc[0] = GetRandomFloat((Loc[0] - 200.0*Num),(Loc[0] + 200.0*Num));
	Loc[1] = GetRandomFloat((Loc[1] - 200.0*Num),(Loc[1] + 200.0*Num));

	Handle ToGroundTrace = TR_TraceRayFilterEx(Loc, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
		
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
static bool b_touchdown;

/*
 *	Heavens Light 
 * 	Spawns 3*5 IONS that follow individual players.
 *  If these ions don't have a vaild target, they just wander around randomly.
 * 	The ability has a fancy chargeup sequence that resembles holy moonlight/blitzlight from blitzkrieg
 *  "As the stars shine upon the Heavens, we shall bask in its radiant and glorious light" - J at 5:03 AM... 2023-12-31
 */



static void Invoke_Heavens_Light(Raidboss_Donnerkrieg npc, float GameTime)
{
	float Heavens_Duration;
	fl_heavens_damage = 15.0 * RaidModeScaling;
	fl_heavens_charge_time = 10.0;
	Heavens_Duration = 30.0;
	fl_heavens_radius = 150.0;	//This is per individual beam
	fl_heavens_speed = 2.5;

	b_touchdown = false;

	fl_heavens_light_duration = GameTime + Heavens_Duration+fl_heavens_charge_time;
	
	Zero(i_heavens_target_id);
	Zero(fl_heavens_rng_loc_timer);
	fl_Heavens_Angle = 0.0;
	
	fl_heavens_charge_gametime = fl_heavens_charge_time + GameTime;

	EmitSoundToAll(DONNERKRIEG_HEAVENS_LIGHT_START_SOUND);

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

		StopSound(npc.index, SNDCHAN_STATIC, DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND);
		StopSound(npc.index, SNDCHAN_STATIC, DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND);

		return Plugin_Stop;
	}

	//TE_used=0;
	
	if(fl_heavens_charge_gametime>GameTime)
	{
		float Ratio =(fl_heavens_charge_gametime - GameTime) / fl_heavens_charge_time;	//L + Ratio	//anyway, we get the ratio of how long until game time is caughtup with charge time, once fully caught up ,the ratio is well 0, once its started, the ratio is 1.0
		Heavens_Light_Charging(npc.index, Ratio);
	}
	else
	{
		for(int player=0 ; player <=MAXTF2PLAYERS ; player++)
		{
			if(fl_was_targeted[player]< GameTime)	//make it so heavens light doesn't just target 1 singular player making 1 beam of fucking death and destruction thats really bright
			{
				b_targeted_by_heavens[player]=false;
			}
		}

		if(!b_touchdown)
		{
			EmitSoundToAll(DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND, npc.index, SNDCHAN_STATIC);
			EmitSoundToAll(DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND, npc.index, SNDCHAN_STATIC);
			EmitSoundToAll(DONNERKRIEG_HEAVENS_LIGHT_TOUCHDOWN_SOUND);
			b_touchdown=true;
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

		int Target = HeavenLight_GetTarget(i, loc);	//get a target if we can
		

		if(IsValidClient(Target))	//we got a target, get his ass's loc so we can roast him
		{
			GetEntPropVector(Target, Prop_Data, "m_vecAbsOrigin", Target_Loc);
			fl_Heavens_Target_Loc[i] = Target_Loc;
		}
		else	//we didn't get a loc, find a random loc to wander to
		{
			if(fl_heavens_rng_loc_timer[i] < GameTime)
			{
				fl_heavens_rng_loc_timer[i] = GameTime+GetRandomFloat(1.0, 5.0);	//make it so we don't constantly check nav mesh 10 billion times a second
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


		int color[4];
		color[3] = 75;
		
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
		

		Doonerkrieg_Do_AOE_Damage(npc, loc, fl_heavens_damage, fl_heavens_radius, false);
		
		fl_Heavens_Loc[i] = loc;

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
	GetAbsOrigin(npc.index, UserLoc);
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_Heavens_Angle;
	UserAng[2] = 0.0;
	
	fl_Heavens_Angle += 1.5*ratio;	//make it so the spining starts to slowdown the more "charged" up the ability becomes until it just stops spinning
	
	if(fl_Heavens_Angle>=360.0)
	{
		fl_Heavens_Angle = 0.0;
	}
	
	for (int i = 0; i < 3; i++)	//to make it look nice we have 3 main layers of the charging phase, inner circle, middle circle, and outer circle. aka 0, 1, 3
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:	//here we modulate their angles/spining direction, speed. and thier distances
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
			
			

			
			if(ratio <=0.2)	//if we are nearing full charge, switch to a singular TE beam alongside a TE ring
			{
				int color[4];
				color[0] = 255;
				color[1] = 50;
				color[2] = 50;
				color[3] = 75;

				Heavens_SpawnBeam(endLoc, color, 7.5, true);
			}
			else	//if we are not near full charge create 2 spining TE beams that also slowly converge with one another
			{
				Heavens_Spawn8(endLoc, 150.0*ratio, ratio);
			}
			int beam_index = (i*(HEAVENS_LIGHT_MAXIMUM_IONS/3))+j;
			
			fl_Heavens_Loc[beam_index] = endLoc;			//make it so once charging is complete, the independant IONS start at the locations the heavens was charging at.
			fl_Heavens_Target_Loc[beam_index] = endLoc;		//set the target loc the same so they don't freakout while finidng a vaild target
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
		color[0] = 255;									//color is dependant on ratio, starts out white, turns red
		color[1] = RoundFloat(255.0 * ratio);
		color[2] = RoundFloat(255.0 * ratio);
		color[3] = 150;	//alpha is a set amt.

		Heavens_SpawnBeam(endLoc, color, 2.0, false);

		
	}
}
static void Heavens_SpawnBeam(float beamLoc[3], int color[4], float size, bool rings)
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
static void Raidboss_Donnerkrieg_Nightmare_Logic(Raidboss_Donnerkrieg npc, int PrimaryThreatIndex)
{
	if(npc.m_bAllowBackWalking)
		npc.m_bAllowBackWalking=false;

	schwert_retreat=true;	//while using the cannon, schwert protects donner
	
	//float vPredictedPos[3]; vPredictedPos = PredictSubjectPositionOld(npc, PrimaryThreatIndex);
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
	//float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenterOld(PrimaryThreatIndex), true);
	
	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bInKame)
	{
		npc.m_flSpeed = 300.0;
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

			npc.StartPathing();
			npc.m_bPathing = true;

			npc.m_bAllowBackWalking=false;

			Donnerkrieg_Say_Lines(npc, DONNERKRIEG_NIGHTMARE_CANNON_INTRO_LINE);
			
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
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);

				if(fl_nightmare_grace_period[npc.index]<GameTime)
				{
					fl_nightmare_grace_period[npc.index] = GameTime + 99.0;

					Donnerkrieg_Say_Lines(npc, DONNERKRIEG_NIGHTMARE_CANNON_FIRE_LINE);
					
					
					npc.m_bInKame = true;
					
					npc.m_flRangedArmor = 0.3;
					npc.m_flMeleeArmor = 0.3;
						
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
				
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
		}
	}
	else
	{
		if(!b_Crystal_active)
		{
			float Duration = fl_nightmare_end_timer[npc.index] - GameTime;
			float Ratio = (1.0 - (Duration / DONNERKRIEG_NIGHTMARE_CANNON_DURATION));
			if(Ratio<0.1)
				Ratio=0.1;

			float Turn_Speed = (250.0*Ratio);

			if(fl_normal_attack_duration[npc.index] < GetGameTime())
				npc.FaceTowards(vecTarget, Turn_Speed);
		}
		npc.StopPathing();
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
	}
}
#define DONNERKRIEG_HEAVENS_FALL_MAX_DIST 500.0

#define DONNERKRIEG_HEAVENS_FALL_MAX_AMT 1	//this should always be the highest value of the 3 ones bellow

#define DONNERKRIEG_HEAVENS_FALL_AMT_1 1	//ratios
#define DONNERKRIEG_HEAVENS_FALL_AMT_2 1
#define DONNERKRIEG_HEAVENS_FALL_AMT_3 1

#define DONNERKRIEG_HEAVENS_FALL_MAX_STAGE 5.0	//same thing for this

#define DONNERKRIEG_HEAVENS_STAGE_1 5.0	//ratios
#define DONNERKRIEG_HEAVENS_STAGE_2 1.0
#define DONNERKRIEG_HEAVENS_STAGE_3 5.0


static float DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[2] = {2.5, 5.0};	//Minimum, Maximum Time

static int TE_used;

static void Heavens_Fall(Raidboss_Donnerkrieg npc, float GameTime)
{

	float Base_Dist=0.0;
	float Distance_Ratios = DONNERKRIEG_HEAVENS_FALL_MAX_DIST/DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;
	if(!Heavens_Fall_Clearance_Check(npc, Base_Dist, DONNERKRIEG_HEAVENS_FALL_MAX_DIST))
	{
		return;
	}

	float Timer = 80.0 *(Base_Dist/DONNERKRIEG_HEAVENS_FALL_MAX_DIST);	//the timer is dynamic to the "power" of this attack, the power is determined by the avalable avg distance which is gotten by clearance check

	if(!npc.Anger)
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer;
	else
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer*0.5;


	int Base_Amt = RoundToFloor((Base_Dist/Distance_Ratios)/DONNERKRIEG_HEAVENS_FALL_MAX_AMT);

	Base_Dist /= DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;	//a lot of ratio stuff, this here makes it actually all dynamic, if you wish to modify it, go to the place where these are defined

	
	int color[4];
	color[3] = 175;

	color[0] = 240;
	color[1] = 240;
	color[2] = 240;

	int Amt1, Amt2, Amt3;
	float Dist1, Dist2, Dist3;

	Dist1 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_1;
	Dist2 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_2;
	Dist3 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_3;

	Amt1= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_1;
	Amt2= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_2;
	Amt3= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_3;

	TE_used=0;	//set the TE used amt to 0 when we start heavens fall!



	float Loc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	EmitSoundToAll("misc/halloween/gotohell.wav");	//GO TO HELL, AND TELL THE DEVIL, IM COMIN FOR HIM NEXT
	EmitSoundToAll("misc/halloween/gotohell.wav");	//GO TO HELL, AND TELL THE DEVIL, IM COMIN FOR HIM NEXT


	int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);

	float Range = 150.0;

	float UserLoc[3];
	GetAbsOrigin(npc.index, UserLoc);
	UserLoc[2]+=75.0;

	for(int Ion=0 ; Ion < Amt1 ; Ion++)
	{

		float tempAngles[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = (360.0/Amt1)*Ion;
		tempAngles[2] = 0.0;

		Do_Trace_Heavens_Fall(Loc, tempAngles, EndLoc, Dist1);

		float dist_check1 = GetVectorDistance(Loc, EndLoc);

		if(dist_check1<Dist1*0.75)	//if the distance is less than we expect or want, abort, same for all the other stages!
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

				Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, EndLoc3);	//Make it so the ions appear properly on the ground so its nice

				float Time = GetRandomFloat(DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[0], DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[1]);	//make it a bit random so it doesn't all explode at the same time

				
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
				CreateDataTimer(Time, Smite_Timer_Donner, data, TIMER_FLAG_NO_MAPCHANGE);	//a basic ion timer
				WritePackFloat(data, EndLoc3[0]);
				WritePackFloat(data, EndLoc3[1]);
				WritePackFloat(data, EndLoc3[2]);
				WritePackCell(data, Range); // Range
				WritePackCell(data, EntIndexToEntRef(npc.index));
				WritePackCell(data, color[0]);
				WritePackCell(data, color[1]);
				WritePackCell(data, color[2]);
				WritePackCell(data, color[3]);
				

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
	TE_used=0;	//now that the initial heavens fall has been completed, reset this to 0 for the ions TE.
}

static bool Heavens_Fall_Clearance_Check(Raidboss_Donnerkrieg npc, float &Return_Dist, float Max_Distance)
{
	float UserLoc[3], Angles[3];
	GetAbsOrigin(npc.index, UserLoc);
	Max_Distance+=Max_Distance*0.1;
	float distance = Max_Distance;
	float Distances[361];
	
	int Total_Hit = 0;
	
	for(int alpha = 1 ; alpha<=360 ; alpha++)	//check in a 360 degree angle around the npc, heavy on preformance, but its a raid so I guess its fine..?
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
			
			if(flDistanceToTarget>250.0)	//minimum distance we wish to check, if the traces end is beyond, we count this angle as a valid area.
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
	if(Total_Hit/360>=0.5)	//has to hit atleast 50% before actually proceeding and saying that we have enough clearance
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
	int Color[4];
	Color[0] = ReadPackCell(data);
	Color[1] = ReadPackCell(data);
	Color[2] = ReadPackCell(data);
	Color[3] = ReadPackCell(data);

	EmitSoundToAll(g_heavens_fall_strike_sound[GetRandomInt(0, sizeof(g_heavens_fall_strike_sound) - 1)], 0, _, _, _, _, _, -1, startPosition);
	//EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);

	Doonerkrieg_Do_AOE_Damage(npc, startPosition, 100.0, Ionrange);

	/*TE_used += 1;
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
	}*/

	
			
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

static Action Donner_Nightmare_Offset(Handle timer, int client)
{
	if(IsValidEntity(client))
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);

		f_NpcTurnPenalty[npc.index] = 0.1;	//:)
		npc.SetPlaybackRate(0.0);
		npc.SetCycle(0.23);
		float startPoint[3];
		WorldSpaceCenter(npc.index, startPoint);
		ParticleEffectAt(startPoint, "eyeboss_death_vortex", 1.0);
		EmitSoundToAll("mvm/mvm_tank_ping.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
		
		fl_nightmare_end_timer[npc.index] = GetGameTime(npc.index) + DONNERKRIEG_NIGHTMARE_CANNON_DURATION+1.5;
		//Invoke_Heavens_Touch(npc, GetGameTime(npc.index));
		EmitSoundToAll("vo/medic_sf13_influx_big02.mp3");	//he laughing
		Donnerkrieg_Main_Nightmare_Cannon(npc);
	}
	return Plugin_Handled;
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

	if(!b_angered_twice[npc.index] && Health/MaxHealth<=0.5)
	{
		b_angered_twice[npc.index]=true;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(IsValidEntity(i_crystal_index))	//warp_crystal
	{
		RemoveEntity(i_crystal_index);
	}

//	b_allow_schwert_transformation = true;
	int wave = 45;

	int ally = EntRefToEntIndex(i_ally_index);
	float startPoint[3];
	GetAbsOrigin(npc.index, startPoint);
	ParticleEffectAt(startPoint, "teleported_blue", 0.5);
	if(!b_donner_said_win_line)
	{
		if(wave<60)
		{
			if(IsValidEntity(ally))
			{
				switch(GetRandomInt(1,2))	//warp
				{
					case 1:
					{
						CPrintToChatAll("{aqua}Donnerkrieg{snow}: Hmph, I'll let {crimson}Schwertkrieg{snow} handle this");
					}
					case 2:
					{
						CPrintToChatAll("{aqua}Donnerkrieg{snow}: You still have {crimson}Schwertkrieg{snow} to deal with... heh");
					}
				}
			}
			else
			{
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						CPrintToChatAll("{aqua}Donnerkrieg{snow}: Hmph, I'll let this slide,{crimson} for now.");
					}
					case 2:
					{
						CPrintToChatAll("{aqua}Donnerkrieg{snow}: Fine, we're leaving.{crimson} Until next time that is{snow} heh");
					}
				}
			}
		}
		else
		{
			switch(GetRandomInt(1,2))	//warp
			{
				case 1:
				{
					CPrintToChatAll("{aqua}Donnerkrieg{snow}: Oh its very serious, we'll go.");
				}
				case 2:
				{
					CPrintToChatAll("{aqua}Donnerkrieg{snow}: This isn't a joke if you come...");
				}
			}
			
		}
	}

	//RaidModeTime +=50.0;

	SDKUnhook(npc.index, SDKHook_Think, Heavens_TBB_Tick);
	Heavens_Light_Active[npc.index] = false;

	StopSound(entity, SNDCHAN_STATIC, DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND);
	StopSound(entity, SNDCHAN_STATIC, DONNERKRIEG_HEAVENS_LIGHT_LOOP_SOUND);

	
	if(IsValidEntity(ally))
	{
		Raidboss_Schwertkrieg schwert = view_as<Raidboss_Schwertkrieg>(ally);
		schwert.Anger=true;
	}

	schwert_retreat = false;
	b_raidboss_donnerkrieg_alive = false;

	Donnerkrieg_Delete_Wings(npc);

/*
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}*/
	
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
	if(IsValidEntity(npc.m_iWearable7))	
		RemoveEntity(npc.m_iWearable7);

		//when 7 wearables isn't enough, get 3 more...

	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][0])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][0]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][1])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][1]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][2])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][2]));


	
}
static bool b_hit_something;
static bool Donnerkrieg_Is_Target_Infront(Raidboss_Donnerkrieg npc, float Radius, float &dist=0.0)	//we only care about finding anything living and an enemy.
{
	float startPoint[3], angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	GetAbsOrigin(npc.index, startPoint);
	startPoint[2] += 50.0;
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return false;
			
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	GetAbsOrigin(npc.index, startPoint);
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
static bool Check_Target(int entity, int contentsMask, int client)	//Stupidly basic target check, we don't even check if the thing infront of us is the person we are chasing lmao
{
	if (IsEntityAlive(entity))
	{
		if(GetTeam(client) != GetTeam(entity))
			b_hit_something=true;
	}
	return false;
}
static void Donnerkrieg_Normal_Attack(Raidboss_Donnerkrieg npc, float GameTime, float flDistanceToTarget, float vecTarget[3])
{
	if(npc.m_flNextMeleeAttack < GameTime && !npc.m_flAttackHappenswillhappen)
	{
		if(flDistanceToTarget < (2500.0*2500.0))	// is the target we wish to delete within range???
		{
			if(Donnerkrieg_Is_Target_Infront(npc, 75.0))	//only fire the laser if the target is actually infront of us, otherwise just dont
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = GameTime+0.2;
				npc.FaceTowards(vecTarget, 20000.0);
				npc.m_flAttackHappenswillhappen=true;
			}
			else
			{
		//		npc.FaceTowards(vecTarget);	//turn towards him, menacingly..
			}
		}
	}
	else if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappenswillhappen)	//a slight delay to the actual firing so the animation plays, and who knows, give a 0.2 second chance for the player to doge it lmao
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
public Action Donnerkrieg_Laser_Think(int iNPC)	//A short burst of a laser.
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);

	float GameTime = GetGameTime(npc.index);
	f_NpcTurnPenalty[npc.index] = 0.0;

	if(fl_normal_attack_duration[npc.index]<GameTime)
	{
		f_NpcTurnPenalty[npc.index] = 1.0;
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

	float radius = 10.0;

	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		float endPoint[3];
		TR_GetEndPosition(endPoint, trace);
		delete trace;

		int color[4];
		color[3] = 30;
		
		color[0] = 255;
		color[1] = 255;
		color[2] = 255;

		Donnerkrieg_Laser_Trace(npc, startPoint, endPoint, radius, 15.0*RaidModeScaling);

		float diameter = radius *1.0;
		int r=color[0], g=color[1], b=color[2], a=color[3];
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
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])	//Why On GODS EARTH DID I MAKE THE INPUT/OUTPUT IN THE WRONG ORDER, LIKE WHY/???????
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static float fl_end_vec[3];
static bool b_is_crystal[MAXENTITIES];
static float fl_initial_windup[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_explosion_thorttle[MAXENTITIES];
static float fl_force_kill_crystal_timer;

static float Laser_Loc[MAXTF2PLAYERS+1][3];
static void Donnerkrieg_Main_Nightmare_Cannon(Raidboss_Donnerkrieg npc)
{
	npc.m_bInKame=true;
	Zero(b_is_crystal);
	fl_end_vec = { 0.0, 0.0, 0.0};
	b_Crystal_active=false;
	b_Crystal_Thrown=false;
	fl_initial_windup[npc.index] = GetGameTime(npc.index)+1.5;
	fl_explosion_thorttle[npc.index]=0.0;
	fl_spinning_angle[npc.index]=0.0;
	i_crystal_index=-1;
	SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
	SDKHook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
}
public Action Donnerkrieg_Main_Nightmare_Tick(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(fl_nightmare_end_timer[npc.index]<GameTime)
	{
		npc.m_bInKame=false;
		SDKUnhook(npc.index, SDKHook_Think, Donnerkrieg_Main_Nightmare_Tick);
		if(IsValidEntity(i_crystal_index))	//warp_crystal
		{
			RemoveEntity(i_crystal_index);
		}
		return Plugin_Stop;
	}

	fl_end_vec = { 0.0, 0.0, 0.0};
	if(IsValidEntity(i_crystal_index))	//warp_crystal
	{
		int crystal = i_crystal_index;

		
		float vecNPC[3];
		GetEntPropVector(crystal, Prop_Data, "m_vecAbsOrigin", vecNPC);
		if(fl_normal_attack_duration[npc.index] < GetGameTime())
			npc.FaceTowards(vecNPC, 750.0);

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;		
							
		//Body pitch
		float v[3], ang[3];
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		SubtractVectors(WorldSpaceVec, vecNPC, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
									
									
		float flPitch = npc.GetPoseParameter(iPitch);
									
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

		if(fl_force_kill_crystal_timer < GameTime)
		{
			RemoveEntity(i_crystal_index);
			i_crystal_index= -1;
			b_Crystal_active=false;
		}

	}

	float angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);	//pitch code stolen from fusion. ty artvin

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return Plugin_Continue;

	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;

	float Pos[3];
	GetAbsOrigin(npc.index, Pos);
	Pos[2]+=50.0;

	float speed = 750.0;
	bool hover=  false;
	float crystal_turn_speed = 3.5;

	speed=250.0;
	hover=true;
	crystal_turn_speed = 10.0;

	fl_spinning_angle[npc.index]+=2.0;
		
	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index] = 0.0;

	float Start_Loc[3];

	Get_Fake_Forward_Vec(30.0, angles, Start_Loc, Pos);

	float radius = 75.0;

	/*
		This thing happens every tick, oh dear god the sever, but its a raidboss so its FIIIIIIIIIINE... right?

	*/
	Handle trace = TR_TraceRayFilterEx(Start_Loc, angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
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

			if(Dist>250.0)
			{

				if(!b_Crystal_Thrown)
					Donnerkrieg_Invoke_Crstaline_Reflection(npc.index, endPoint, hover, speed);
			}

			//npc.PlayNightmareSound();

			Donnerkrieg_Laser_Trace(npc, Start_Loc, endPoint, radius*0.75, 75.0*RaidModeScaling);	//this technically finds the LOC of the crystal.

			

			float diameter = radius *0.75;

			if(fl_end_vec[0] != 0.0 || fl_end_vec[1] != 0.0 || fl_end_vec[2] != 0.0)
			{
				endPoint=fl_end_vec;
				Dist = GetVectorDistance(Start_Loc, endPoint);

				for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
				{
					if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
					{
						Crystal_Laser_Move_And_Dmg_Logic(npc, client, endPoint, diameter, crystal_turn_speed);
					}
				}
				for(int i=MAXTF2PLAYERS ; i <MAXENTITIES ; i++)	//for allied npc's don't bother the fancy laser, just fucking shoot them lmao
				{
					if(IsValidEntity(i))
					{
						if(IsValidEnemy(npc.index, i))
						{
							float current_loc[3], vecAngles[3]; GetAbsOrigin(i, current_loc);
							MakeVectorFromPoints(endPoint, current_loc, vecAngles);
							GetVectorAngles(vecAngles, vecAngles);
							float Dist2 = 2000.0;

							Get_Fake_Forward_Vec(Dist2, vecAngles, current_loc, current_loc);
							TE_SetupBeamPoints(endPoint, current_loc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 0.5, {150, 150, 150, 150}, 3);
							TE_SendToAll(0.0);

							Donnerkrieg_Laser_Trace(npc, endPoint, current_loc, diameter*0.5, 25.0*RaidModeScaling);	//this technically finds the LOC of the crystal.
						}
					}
				}
			}

			

			Donnerkrieg_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, true, radius/2.0, -1.0);		//12

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
				DataPack pack = new DataPack();
				pack.WriteFloat(endPoint[0]);
				pack.WriteFloat(endPoint[1]);
				pack.WriteFloat(endPoint[2]);
				pack.WriteCell(1);
				RequestFrame(MakeExplosionFrameLater, pack);
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
static void Crystal_Laser_Move_And_Dmg_Logic(Raidboss_Donnerkrieg npc, int client, float start_loc[3], float diameter, float speed)
{
	float current_loc[3]; current_loc = Laser_Loc[client];
	float client_loc[3];
	GetClientEyePosition(client, client_loc);
	int Enemy_I_See = Check_Line_Of_Sight(start_loc , npc.index, client);

	float vecAngles[3], Direction[3];

	MakeVectorFromPoints(current_loc, client_loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
						
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, speed);
	AddVectors(current_loc, Direction, current_loc);

	Laser_Loc[client] = current_loc;

	MakeVectorFromPoints(start_loc, current_loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	float Dist = 2000.0;

	Get_Fake_Forward_Vec(Dist, vecAngles, current_loc, current_loc);


	if(Enemy_I_See==client)
	{
		TE_SetupBeamPoints(start_loc, current_loc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 0.5, {150, 150, 150, 150}, 3);
		TE_SendToAll(0.0);

		Donnerkrieg_Laser_Trace(npc, start_loc, current_loc, diameter*0.5, 5.5*RaidModeScaling);
	}
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
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
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
static void Donnerkrieg_Laser_Trace(Raidboss_Donnerkrieg npc, float Start_Point[3], float End_Point[3], float Radius, float dps)
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
		if (DonnerKriegCannon_BEAM_HitDetected[victim] && GetTeam(npc.index) != GetTeam(victim))
		{

			float Dmg = dps;

			if(ShouldNpcDealBonusDamage(victim))
			{
				Dmg *= 5.0;
			}
			float dmg_force[3]; WorldSpaceCenter(victim, dmg_force);
			SDKHooks_TakeDamage(victim, npc.index, npc.index, (Dmg/6), DMG_PLASMA, -1, NULL_VECTOR, dmg_force);

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
	if(b_is_crystal[entity])
	{
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", fl_end_vec);
	}
	return false;
}

static float fl_crystal_direct_dmg[MAXENTITIES];

//Crystaline Reflection:
public void Donnerkrieg_Invoke_Crstaline_Reflection(int client, float Target[3], bool hover, float speed)	//schwert can throw this. :) but I didn't do that.
{
	fl_force_kill_crystal_timer = GetGameTime() +7.5;
	for(int i=0 ; i <=MAXTF2PLAYERS ; i++)
	{
		if(IsValidClient(i))
		{
			float loc[3] ; GetAbsOrigin(i, loc);
			loc[0] +=GetRandomFloat(-75.0,75.0);
			loc[1] +=GetRandomFloat(-75.0,75.0);
			loc[2] +=GetRandomFloat(-75.0,75.0);

			Laser_Loc[i] = loc;
		}
	}
	int Crystal = Create_Crystal(client, Target, 100.0*RaidModeScaling, speed, hover); //if you get hit by this lmao, gg
	if(IsValidEntity(Crystal))
	{
		b_Crystal_active=true;
		b_Crystal_Thrown=true;
		i_crystal_index= Crystal;
		b_is_crystal[Crystal]=true;
	}
}
static int Create_Crystal(int client, float vecTarget[3], float damage, float rocket_speed, bool hover)
{
	CClotBody npc = view_as<CClotBody>(client);
	float vecForward[3], vecSwingStart[3], vecAngles[3];
	npc.GetVectors(vecForward, vecSwingStart, vecAngles);
										
	GetAbsOrigin(npc.index, vecSwingStart);
	vecSwingStart[2] += 54.0;
										
	MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	
	vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
	vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
	vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

	if(!hover)
		vecForward[2]+=1000.0;
										
	int entity = CreateEntityByName("zr_projectile_base");
	if(IsValidEntity(entity))
	{
		fl_crystal_direct_dmg[entity] = damage;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetTeam(entity, GetTeam(npc.index));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
										
		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);

		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}

		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 2.0); // ZZZZ i sleep

		if(!hover)
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);

		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24); //our savior
		Set_Projectile_Collision(entity); //If red, set to 27



		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Donner_Crystal_DHook_RocketExplodePre); //*yawn*
		
		SDKHook(entity, SDKHook_StartTouch, Crystal_Donner_StartTouch);

		return entity;
	}
	return -1;
}

public MRESReturn Donner_Crystal_DHook_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Don't even think about it mate
}

public void Crystal_Donner_StartTouch(int entity, int target)
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

		float DamageDeal = fl_crystal_direct_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= 2.0;

		i_crystal_index= -1;
		
		switch(GetRandomInt(1,5)) 
		{
			case 1:EmitSoundToAll(SOUND_BLITZ_IMPACT_1, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 2:EmitSoundToAll(SOUND_BLITZ_IMPACT_2, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
			case 3:EmitSoundToAll(SOUND_BLITZ_IMPACT_3, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 4:EmitSoundToAll(SOUND_BLITZ_IMPACT_4, entity, SNDCHAN_STATIC, 80, _, 0.9);
			
			case 5:EmitSoundToAll(SOUND_BLITZ_IMPACT_5, entity, SNDCHAN_STATIC, 80, _, 0.9);
				
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
	TE_ParticleInt(g_particleImpactTornado, pos1);
	TE_SendToAll();

	i_crystal_index= -1;
	b_Crystal_active=false;

	RemoveEntity(entity);
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

static void Donnerkrieg_Wings_Create(Raidboss_Donnerkrieg npc)	//I wish these wings were real, but allas, Donnerkrieg can't into space
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
/**
 * Description: A simple AOE damage void.
 *
 * @param npc          clot npc body
 * @param loc          from where to do the damage. dmg center
 * @param damage       how much to hurt a person?
 * @param Range        how far to hurt a person
 * @param FallOff      minimum damage multi, distance relative.
 */
static float ion_damage[MAXENTITIES];
static void Doonerkrieg_Do_AOE_Damage(Raidboss_Donnerkrieg npc, float loc[3], float damage, float Range, bool shake=true)
{
	ion_damage[npc.index] = 1.0;
	if(shake)
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5, Donner_Normal_Tweak);
	else
		Explode_Logic_Custom(damage, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5);
}
public void Donner_Normal_Tweak(int entity, int victim, float damage, int weapon)
{	
	if(IsValidClient(victim))
	{
		Client_Shake(victim);
	}
}


static int Check_Line_Of_Sight(float pos_npc[3], int attacker, int enemy)
{
	Handle trace; 
	
	float pos_enemy[3];
	WorldSpaceCenter(enemy, pos_enemy);

	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, MASK_SOLID, RayType_EndPoint, BulletAndMeleeTrace, attacker);
	int Traced_Target;
		
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(pos_npc, pos_enemy, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
		
	Traced_Target = TR_GetEntityIndex(trace);
	delete trace;
	return Traced_Target;
}


static void Donnerkrieg_Say_Lines(Raidboss_Donnerkrieg npc, int line_type)
{
	char name_color[255]; name_color = "aqua";
	char text_color[255]; text_color = "snow";
	char danger_color[255]; danger_color = "crimson";

	char text_lines[255];

	char extra_lines[255]; extra_lines = "";
	
	switch(line_type)
	{
		case DONNERKRIEG_NIGHTMARE_CANNON_INTRO_LINE:
		{
			extra_lines = "...";
			switch(GetRandomInt(1,9))
			{
				case 1:
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}Thats it {%s}i'm going to kill you", name_color, text_color, name_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}Thats it {%s}i'm going to kill you{%s}.", name_color, text_color, name_color, danger_color, text_color);	
				}
				case 2:
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}hm, {%s}Wonder how this will end...", name_color, text_color, danger_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}hm, {%s}Wonder how this will end...", name_color, text_color, danger_color, text_color);	
				}
				case 3:
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}PREPARE {%s}Thyself, {%s}Judgement {%s}Is near", name_color, text_color, danger_color, name_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}PREPARE {%s}Thyself, {%s}Judgement {%s}Is near{%s}.", name_color, text_color, danger_color, name_color, text_color, danger_color, text_color);		
				}
				case 4:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							//CPrintToChatAll("{%s}Donnerkrieg{%s}: Oh not again now train's gone and {%s}Left{%s}.", name_color, text_color, danger_color, text_color);	
							Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Oh not again now train's gone and {%s}Left{%s}.", name_color, text_color, danger_color, text_color);	
							b_train_line_used[npc.index] = true;
						}				
						default:
						{
							//CPrintToChatAll("{%s}Donnerkrieg{%s}: Oh not again now cannon's gone and {%s}recharged{%s}.", name_color, text_color, danger_color, text_color);	
							Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Oh not again now cannon's gone and {%s}recharged{%s}.", name_color, text_color, danger_color, text_color);	
						}
					}
				}
				case 5: 
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: Aiming this thing is actually quite {%s}complex {%s}ya know.", name_color, text_color, danger_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Aiming this thing is actually quite {%s}complex {%s}ya know.", name_color, text_color, danger_color, text_color);
					b_fuck_you_line_used[npc.index] = true;
				}
				case 6:
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: Ya know, im getting quite bored of {%s}this", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Ya know, im getting quite bored of {%s}this{%s}.", name_color, text_color, danger_color, text_color);	
				}
				case 7:
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: Ya know, im getting quite bored of {%s}this", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Oh how {%s}Tiny{%s} you all look from up here.", name_color, text_color, danger_color, text_color);	
				}
				case 8:
				{
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: heh {%s}This is{%s} gonna be funny.", name_color, text_color, danger_color, text_color);	
				}
				case 9:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}Oya{%s}?", name_color, text_color, danger_color, text_color);	
						}				
						default:
						{
							Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: Aya, how troublesome {%s}this is{%s}.", name_color, text_color, danger_color, text_color);	
						}
					}
				}
			}
		}
		case DONNERKRIEG_NIGHTMARE_CANNON_FIRE_LINE:
		{
			if(!b_fuck_you_line_used[npc.index] && !b_train_line_used[npc.index])
			{	
				switch(GetRandomInt(1,6))
				{
					case 1:
					{
						//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}NIGHTMARE, CANNON!", name_color, text_color, danger_color);
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}NIGHTMARE, CANNON{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 2:
					{
						//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}JUDGEMENT BE UPON THEE!", name_color, text_color, danger_color);
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}JUDGEMENT BE UPON THEE{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 3:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}COSMIC ANNIHILATION{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 4:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}DIVINE RETRIBUTION{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 5:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}CALL OF THE BEYOND{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 6:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}PUNISHMENT OF HER {%s}GRACE{%s}!", name_color, text_color, danger_color, name_color, text_color);
					}
				}
			}
			else
			{
				if(b_train_line_used[npc.index])
				{
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: {%s}And the city's to far to walk to the end while I...", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: {%s}And the city's to far to walk to the end while I...", name_color, text_color, danger_color);	
					b_train_line_used[npc.index] = false;
					extra_lines = "...";
				}
				else if(b_fuck_you_line_used[npc.index])
				{
					b_fuck_you_line_used[npc.index] = false;
					//CPrintToChatAll("{%s}Donnerkrieg{%s}: However its still{%s} worth the effort", name_color, text_color, danger_color);	

					Format(text_lines, sizeof(text_lines), "{%s}Donnerkrieg{%s}: However its still{%s} worth the effort{%s}.", name_color, text_color, danger_color, text_color);	
					extra_lines = "";
				}
				
			}
		}
	}
	CPrintToChatAll(text_lines);
	NpcSpeechBubble(npc.index, "", 15, {255,0,0,255}, {0.0,0.0,125.0}, extra_lines);
}
/*
static bool Divine_Intervention_Check(Raidboss_Donnerkrieg npc, float Min_Dist)
{
	float UserLoc[3], Angles[3];
	UserLoc = GetAbsOriginOld(npc.index);
	
	int Total_Hit = 0;
	
	for(int alpha = 1 ; alpha<=360 ; alpha++)	//check in a 360 degree angle around the npc, heavy on preformance, but its a raid so I guess its fine..?
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(alpha);
		tempAngles[2] = 0.0;
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Min_Dist+100.0);
		AddVectors(UserLoc, Direction, endLoc);
		
		MakeVectorFromPoints(UserLoc, endLoc, Angles);
		GetVectorAngles(Angles, Angles);
		
		float endPoint[3];
	
		Handle trace = TR_TraceRayFilterEx(UserLoc, Angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			
			float flDistanceToTarget = GetVectorDistance(endPoint, UserLoc);
			
			if(flDistanceToTarget>Min_Dist)	//minimum distance we wish to check, if the traces end is beyond, we count this angle as a valid area.
			{
				Total_Hit++;
			}

		}
		delete trace;
	}
	if(Total_Hit/360>=0.75)	//has to hit atleast 25% before actually proceeding and saying that we have enough clearance
	{
		return true;
	}
	else
	{
		return false;
	}
}

static bool b_weaver_summoned;
static bool b_stage_one_effects;
static float fl_anchor_location[3];
#define DIVINE_INTERVENTION_MAX_SIZE 300.0

#define DIVINE_INTERVENTION_DURATION 20
static void Invoke_Divine_Intervention(Raidboss_Donnerkrieg npc, float GameTime)
{
	if(!Divine_Intervention_Check(npc, DIVINE_INTERVENTION_MAX_SIZE))	//dear lord this ability is HEAVY HEAVY HEAVY HEAVY HEAAAAAVYYYYYYY
	{
		fl_divine_intervention_retry = GameTime+0.25;
		return;
	}

	fl_divine_intervention_retry = FAR_FUTURE;

	fl_divine_intervention_active = GetGameTime() + DIVINE_INTERVENTION_DURATION;

	b_weaver_summoned=false;
	b_stage_one_effects=false;

	fl_anchor_location = GetAbsOrigin(npc.index);

	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, fl_anchor_location);

	SDKUnhook(npc.index, SDKHook_Think, Divine_Intervention_Hook);
	SDKHook(npc.index, SDKHook_Think, Divine_Intervention_Hook);
}
static Action Divine_Intervention_Hook(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);

	float GameTime = GetGameTime();

	float Duration = fl_divine_intervention_active - GameTime;

	int Ally = EntRefToEntIndex(i_ally_index);

	if(!IsValidEntity(Ally))
	{
		SDKUnhook(npc.index, SDKHook_Think, Divine_Intervention_Hook);
		CPrintToChatAll("SOMETHING HORRIBLE HAPPENED: Divine_Intervention_Hook ALLY CHECK");
		return Plugin_Stop;
	}


	if(Duration<-1.0)
	{
		SDKUnhook(npc.index, SDKHook_Think, Divine_Intervention_Hook);
		return Plugin_Stop;
	}
	float Ally_Vec[3]; Ally_Vec = GetAbsOrigin(Ally);
	float Npc_Loc[3]; Npc_Loc = GetAbsOrigin(npc.index);

	float Anchoring_Location[3]; Anchoring_Location = fl_anchor_location;

	float Max_Size = DIVINE_INTERVENTION_MAX_SIZE;

	NPC_SetGoalVector(npc.index, Anchoring_Location, true);

	float Dist_To_Schwert = GetVectorDistance(Ally_Vec, Npc_Loc);

	if(Dist_To_Schwert > 250.0)
	{
		fl_divine_intervention_active = GameTime + DIVINE_INTERVENTION_DURATION;
		return Plugin_Continue;
	}

	Layer_One_Effects(Anchoring_Location, Max_Size);

	if(Duration < 1.0 && !b_weaver_summoned)
	{
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);	//what

		int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int spawn_index;

		spawn_index = NPC_CreateById(RUINA_STELLAR_WEAVER, -1, Npc_Loc, ang, GetTeam(npc.index), "solo_true");
		if(spawn_index > MaxClients)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", Health);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", Health);
			b_weaver_summoned=true;
		}
	}

	return Plugin_Continue;
}
static void Layer_One_Effects(float Loc[3], float Max_Size)	//WARP
{
	if(b_stage_one_effects)
		return;

	TE_used=0;
	
	b_stage_one_effects=true;
	int spin_amt = 9;
	float Core_Loc[3]; Core_Loc=Loc;

	int color[4]; color[0] = 1; color[1] = 255; color[2] = 255; color[3] = 255;

	float Last_Loc[3] = {0.0, 0.0, 0.0};

	bool originaled= false;
	float Original_Loc[3];

	float time = fl_divine_intervention_active - GetGameTime();

	for(int alpha = 0 ; alpha< spin_amt ; alpha++)	//check in a 360 degree angle around the npc, heavy on preformance, but its a raid so I guess its fine..?
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = (360.0/spin_amt)*alpha;
		tempAngles[2] = 0.0;
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Max_Size);
		AddVectors(Core_Loc, Direction, endLoc);

		if(!originaled)
		{
			originaled=true;
			Original_Loc=endLoc;
		}

		float start = 50.0;
		float end = 50.0;

		TE_used += 1;
		if(TE_used > 31)
		{
			int DelayFrames = (TE_used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(Core_Loc[0]);
			pack_TE.WriteCell(Core_Loc[1]);
			pack_TE.WriteCell(Core_Loc[2]);
			pack_TE.WriteCell(endLoc[0]);
			pack_TE.WriteCell(endLoc[1]);
			pack_TE.WriteCell(endLoc[2]);
			pack_TE.WriteCell(color[0]);
			pack_TE.WriteCell(color[1]);
			pack_TE.WriteCell(color[2]);
			pack_TE.WriteCell(color[3]);
			pack_TE.WriteCell(0.1);
			pack_TE.WriteCell(start);
			pack_TE.WriteCell(end);
			RequestFrames(Doonerkrieg_Delay_TE_Beam_Special, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			TE_SetupBeamPoints(Core_Loc, endLoc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, 0.1, color, 3);
			TE_SendToAll();
		}

		start = 75.0;
		end = 25.0;

		float Sky_Loc[3]; Sky_Loc = endLoc;
		Sky_Loc[2] += 160.0;

		TE_used += 1;
		if(TE_used > 31)
		{
			int DelayFrames = (TE_used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(endLoc[0]);
			pack_TE.WriteCell(endLoc[1]);
			pack_TE.WriteCell(endLoc[2]);
			pack_TE.WriteCell(Sky_Loc[0]);
			pack_TE.WriteCell(Sky_Loc[1]);
			pack_TE.WriteCell(Sky_Loc[2]);
			pack_TE.WriteCell(color[0]);
			pack_TE.WriteCell(color[1]);
			pack_TE.WriteCell(color[2]);
			pack_TE.WriteCell(color[3]);
			pack_TE.WriteCell(0.01);
			pack_TE.WriteCell(start);
			pack_TE.WriteCell(end);
			RequestFrames(Doonerkrieg_Delay_TE_Beam_Special, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			TE_SetupBeamPoints(endLoc, Sky_Loc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, 0.01, color, 3);
			TE_SendToAll();
		}

		start = 25.0;
		end = 25.0;

		if(Last_Loc[0] != 0.0 && Last_Loc[1] != 0.0 && Last_Loc[2] != 0.0)
		{
			float Fence_Height[3]; Fence_Height = endLoc;
			float Fence_2[3]; Fence_2 = Last_Loc;
			for(int i =0 ; i < 3 ; i ++)
			{
				TE_used += 1;
				if(TE_used > 31)
				{
					int DelayFrames = (TE_used / 32);
					DelayFrames *= 2;
					DataPack pack_TE = new DataPack();
					pack_TE.WriteCell(Fence_Height[0]);
					pack_TE.WriteCell(Fence_Height[1]);
					pack_TE.WriteCell(Fence_Height[2]);
					pack_TE.WriteCell(Fence_2[0]);
					pack_TE.WriteCell(Fence_2[1]);
					pack_TE.WriteCell(Fence_2[2]);
					pack_TE.WriteCell(color[0]);
					pack_TE.WriteCell(color[1]);
					pack_TE.WriteCell(color[2]);
					pack_TE.WriteCell(color[3]);
					pack_TE.WriteCell(1.0);
					pack_TE.WriteCell(start);
					pack_TE.WriteCell(end);
					RequestFrames(Doonerkrieg_Delay_TE_Beam_Special, DelayFrames, pack_TE);
					//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
				}
				else
				{
					TE_SetupBeamPoints(Fence_Height, Fence_2, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, 1.0, color, 3);
					TE_SendToAll();
				}
				Fence_Height[2]+=50.0;
				Fence_2[2]+=50.0;
			}
		}

		Last_Loc = endLoc;

	}


	float start = 25.0;
	float end = 25.0;

	float Fence_Height[3]; Fence_Height = Last_Loc;
	float Fence_2[3]; Fence_2 = Original_Loc;
	for(int i =0 ; i < 3 ; i ++)
	{
		TE_used += 1;
		if(TE_used > 31)
		{
			int DelayFrames = (TE_used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(Fence_Height[0]);
			pack_TE.WriteCell(Fence_Height[1]);
			pack_TE.WriteCell(Fence_Height[2]);
			pack_TE.WriteCell(Fence_2[0]);
			pack_TE.WriteCell(Fence_2[1]);
			pack_TE.WriteCell(Fence_2[2]);
			pack_TE.WriteCell(color[0]);
			pack_TE.WriteCell(color[1]);
			pack_TE.WriteCell(color[2]);
			pack_TE.WriteCell(color[3]);
			pack_TE.WriteCell(1.0);
			pack_TE.WriteCell(start);
			pack_TE.WriteCell(end);
			RequestFrames(Doonerkrieg_Delay_TE_Beam_Special, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			TE_SetupBeamPoints(Fence_Height, Fence_2, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, 1.0, color, 3);
			TE_SendToAll();
		}
		Fence_Height[2]+=50.0;
		Fence_2[2]+=50.0;
	}
}

public void Doonerkrieg_Delay_TE_Beam_Special(DataPack pack)
{
	float time = fl_divine_intervention_active - GetGameTime();
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
	float amp = pack.ReadCell();
	float start = pack.ReadCell();
	float end = pack.ReadCell();

	TE_SetupBeamPoints(StartLoc, endLoc, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, time, start, end, 0, amp, color, 3);
	TE_SendToAll();
		
	delete pack;
}*/

static void Ruina_Proper_To_Groud_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
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