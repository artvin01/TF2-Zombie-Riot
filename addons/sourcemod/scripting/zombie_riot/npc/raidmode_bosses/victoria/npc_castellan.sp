#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_specialcompleted01.mp3",
	"vo/sniper_specialcompleted02.mp3",
	"vo/sniper_specialcompleted03.mp3",
	"vo/sniper_specialcompleted04.mp3",
	"vo/sniper_specialcompleted05.mp3",
	"vo/sniper_specialcompleted06.mp3",
	"vo/sniper_specialcompleted07.mp3",
	"vo/sniper_specialcompleted08.mp3",
	"vo/sniper_specialcompleted09.mp3",
	"vo/sniper_specialcompleted10.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted12.mp3",
	"vo/sniper_specialcompleted13.mp3",
	"vo/sniper_specialcompleted14.mp3",
	"vo/sniper_specialcompleted15.mp3",
	"vo/sniper_specialcompleted17.mp3",
	"vo/sniper_specialcompleted18.mp3",
	"vo/sniper_specialcompleted19.mp3",
	"vo/sniper_specialcompleted21.mp3",
	"vo/sniper_specialcompleted22.mp3",
	"vo/sniper_specialcompleted23.mp3",
	"vo/sniper_specialcompleted24.mp3",
	"vo/sniper_specialcompleted25.mp3",
	"vo/sniper_specialcompleted26.mp3",
	"vo/sniper_specialcompleted27.mp3",
	"vo/sniper_specialcompleted28.mp3",
	"vo/sniper_specialcompleted29.mp3",
	"vo/sniper_specialcompleted30.mp3",
	"vo/sniper_specialcompleted31.mp3",
	"vo/sniper_specialcompleted32.mp3",
	"vo/sniper_specialcompleted33.mp3",
	"vo/sniper_specialcompleted34.mp3",
	"vo/sniper_specialcompleted35.mp3",
	"vo/sniper_specialcompleted36.mp3",
	"vo/sniper_specialcompleted37.mp3",
	"vo/sniper_specialcompleted38.mp3",
	"vo/sniper_specialcompleted39.mp3",
	"vo/sniper_specialcompleted40.mp3",
	"vo/sniper_specialcompleted41.mp3",
	"vo/sniper_specialcompleted42.mp3",
	"vo/sniper_specialcompleted44.mp3",
	"vo/sniper_specialcompleted45.mp3",
	"vo/sniper_specialcompleted46.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};
static const char g_MG42AttackSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/sniper_specialcompleted43.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_HomerunSounds[][]= {
	"vo/sniper_jaratetoss02/mp3",
	"vo/sniper_jaratetoss03/mp3",
};
static const char g_LasershotReady[][]= {
	"vo/sniper_dominationengineer03.mp3",
	"vo/sniper_dominationengineer05.mp3",
	"vo/sniper_goodjob01.mp3"
};
static const char g_PlayRocketshotready[][] = {
	"vo/sniper_specialcompleted20.mp3",
	"vo/sniper_specialcompleted16.mp3",
	"vo/sniper_dominationsoldier02.mp3"

};
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float FTL[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool Gone[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool AlreadySpawned[MAXENTITIES];
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static int i_AmountProjectiles[MAXENTITIES];
static float fl_said_player_weaponline_time[MAXENTITIES];

static int gLaser1;
static int gRedPoint;
static int g_BeamIndex_heal;
static int g_HALO_Laser;

#define BombDrop_CHARGE_TIME 2.0
#define BombDrop_CHARGE_SPAN 1.0
#define BombDrop_LIGHTNING_RANGE 150.0

void Castellan_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Castellan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_castellan");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_atomizer_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MG42AttackSounds)); i++) { PrecacheSound(g_MG42AttackSounds[i]); }
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	for (int i = 0; i < (sizeof(g_HomerunSounds));   i++) { PrecacheSound(g_HomerunSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PlayRocketshotready));   i++) { PrecacheSound(g_PlayRocketshotready[i]);   }
	for (int i = 0; i < (sizeof(g_LasershotReady));   i++) { PrecacheSound(g_LasershotReady[i]);   }
	PrecacheModel("models/player/soldier.mdl");
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_atomizer.mp3");
	PrecacheSoundCustom("mvm/ambient_mp3/mvm_siren.mp3");
	
	PrecacheModel(LASERBEAM);
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Castellan(client, vecPos, vecAng, ally, data);
}

static int i_Castellan_eye_particle[MAXENTITIES];

methodmap Castellan < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayRocketshotready() {
	
		int sound = GetRandomInt(0, sizeof(g_PlayRocketshotready) - 1);
		EmitSoundToAll(g_PlayRocketshotready[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerReaction() {
	
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunHitSound() {
	
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunSound() {
	
		EmitSoundToAll(g_HomerunSounds[GetRandomInt(0, sizeof(g_HomerunSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunSounds[GetRandomInt(0, sizeof(g_HomerunSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunMissSound() {
	
		EmitSoundToAll(g_LasershotReady[GetRandomInt(0, sizeof(g_LasershotReady) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_LasershotReady[GetRandomInt(0, sizeof(g_LasershotReady) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound()
	{
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,125));
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_MG42AttackSounds[GetRandomInt(0, sizeof(g_MG42AttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flTimeUntillSupportSpawn
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextSummonDrones
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextSummonHardenerDrones
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flTimeUntillAirStrike
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flAirRaidDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}

	public Castellan(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Castellan npc = view_as<Castellan>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		Delay_Attribute[npc.index] = 0.0;
		YaWeFxxked[npc.index] = false;
		ParticleSpawned[npc.index] = false;
		Gone[npc.index] = false;
		npc.m_bFUCKYOU = false;
		I_cant_do_this_all_day[npc.index] = 0;
		npc.i_GunMode = 0;
		npc.m_flTimeUntillSupportSpawn = GetGameTime() + 15.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAirRaidDelay = 0.0;
		npc.m_flTimeUntillAirStrike = GetGameTime() + 10.0;
		npc.m_flTimeUntillNextSummonDrones = GetGameTime() + 10.0;
		npc.m_flTimeUntillNextSummonHardenerDrones = GetGameTime() + 13.5;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iAmountProjectiles = 0;
		npc.m_iAttacksTillReload = 0;
		
		npc.m_fbRangedSpecialOn = false;
		AlreadySpawned[npc.index] = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Harrison Arrived");
			}
		}
		FTL[npc.index] = 200.0;
		RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
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

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(ZR_GetWaveCount()+1 > 55)
		{
			FTL[npc.index] = 220.0;
			RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
			RaidModeScaling *= 0.65;
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_atomizer.mp3");
		music.Time = 128;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Hard to Ignore");
		strcopy(music.Artist, sizeof(music.Artist), "UNFINISH");
		Music_SetRaidMusic(music);
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
		SetVariantString("0.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		CPrintToChatAll("{blue}%s{default}: Intruders in sight, I won't let the get out alive!", c_NpcName[npc.index]);

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/fdu.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/sept2014_lone_survivor/sept2014_lone_survivor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		npc.m_iWearable8 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2022_safety_stripes/hwn2022_safety_stripes.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable8, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 255);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable8, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({150, 150, 150, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		CPrintToChatAll("{blue}Castellan{default}: Intruders in sight, I won't let the get out alive!");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Castellan npc = view_as<Castellan>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Castellan_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}	

	if(Gone[npc.index])
	{
		npc.m_iChanged_WalkCycle = 0;
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 0);
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable8, 255, 255, 255, 0);
	}
	else if(!Gone[npc.index])
	{
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 255);
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);
		SetEntityRenderMode(npc.m_iWearable8, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 255);
	}

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{blue}Castellan{default}: Ready to die?");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Castellan{default}: You can't run forever.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Castellan{default}: All of your comrades are fallen.");
				}
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		npc.m_flMeleeArmor = 0.33;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{blue}Castellan{default}: Victoria will be in peace. Once and for all.");
			case 2:CPrintToChatAll("{blue}Castellan{default}: The troops have arrived and will begin destroying the intruders!");
			case 3:CPrintToChatAll("{blue}Castellan{default}: Backup team has arrived. Catch those damn bastards!");
			case 4:CPrintToChatAll("{blue}Castellan{default}: After this, Im heading to Rusted Bolt Pub. {unique}I need beer.{default}");
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_batter",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_charger",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_teslar",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_victorian_vanguard",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_supplier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_ballista",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_grenadier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 8))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_humbee",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_shotgunner",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_bulldozer",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_hardener",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_raider",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_zapper",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_payback",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 8:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_blocker",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		BlockLoseSay = true;
		YaWeFxxked[npc.index] = true;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	/*
	if(npc.m_flTimeUntillGunReload < gameTime)
	{
		npc.m_iAttacksTillReload =  RoundToNearest(float(CountPlayersOnRed(2)) * 5); 
		npc.m_flTimeUntillGunReload = 30.0 + gameTime;
	}
	*/
	if(npc.m_bFUCKYOU)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				/*
				if(npc.m_iChanged_WalkCycle != 5)
				{
					ResetCastellanWeapon(npc, 2);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}
				*/
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/taunt_most_wanted/taunt_most_wanted.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				b_NpcIsInvulnerable[npc.index] = true;
				npc.AddActivityViaSequence("layer_taunt_most_wanted");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.75;	
				Delay_Attribute[npc.index] = gameTime + 0.75;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("layer_taunt_most_wanted");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.3);
					npc.SetPlaybackRate(0.0);
					npc.m_iChanged_WalkCycle = 0;
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 30.0;	
					Delay_Attribute[npc.index] = gameTime + 30.0;
					I_cant_do_this_all_day[npc.index]=2;
				}
			}
			case 2:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.PlayAngerSound();
					npc.PlayAngerReaction();
					npc.AddActivityViaSequence("layer_taunt_most_wanted");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.8);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_iChanged_WalkCycle = 0;
					f_VictorianCallToArms[npc.index] = GetGameTime() + 999.0;
					I_cant_do_this_all_day[npc.index]=0;
					//npc.m_flTimeUntillDroneSniperShot += 4.0;
					//npc.m_flTimeUntillNextSummonDrones += 4.0;
					//npc.m_flNextRangedSpecialAttackHappens += 4.0;
					npc.m_bFUCKYOU=false;
					b_NpcIsInvulnerable[npc.index] = false;
				}
			}
		}
		return;
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = CastellanSelfDefense(npc,gameTime, npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
	{
		CastellanAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Castellan npc = view_as<Castellan>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.33 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.m_fbRangedSpecialOn)
		{
			I_cant_do_this_all_day[npc.index]=0;
			f_VictorianCallToArms[npc.index] = GetGameTime() + 999.0;
			IncreaceEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			npc.m_bFUCKYOU=true;
			FTL[npc.index] += 35.0;
			RaidModeTime += 35.0;
		}
	}

	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Castellan npc = view_as<Castellan>(entity);
	/*
		Explode on death code here please

	*/
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{blue}Castellan{default}: Ugh, I need backup");
		case 1:CPrintToChatAll("{blue}Castellan{default}: I will never let you trample over the glory of {gold}Victoria{default} Again!");
		case 2:CPrintToChatAll("{blue}Castellan{default}: You intruders will soon face the {crimson}Real Deal.{default}");
	}

}

static void CastellanAnimationChange(Castellan npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
		npc.m_iChanged_WalkCycle = -1;
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetCastellanWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetCastellanWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 2: //secondary
		{
			if(npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetCastellanWeapon(npc, 2);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetCastellanWeapon(npc, 2);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_SECONDARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ResetCastellanWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ResetCastellanWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

static int CastellanSelfDefense(Castellan npc, float gameTime, int target, float distance)
{
	if(npc.m_flTimeUntillSupportSpawn < gameTime)
	{
		float SelfPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
		npc.m_flTimeUntillSupportSpawn = gameTime + 20.0;
		CreateSupport_Castellan(npc.index, target, SelfPos);
	}
	else if(npc.m_flTimeUntillNextSummonDrones < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt05");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.7);
				npc.SetPlaybackRate(1.5);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.5;	
				Delay_Attribute[npc.index] = gameTime + 0.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					
					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

					int health = ReturnEntityMaxHealth(npc.index) / 30;
					
					int summon1 = NPC_CreateByName("npc_victoria_fragments", -1, pos, ang, GetTeam(npc.index), "mk2;limit");

					{
						if(GetTeam(npc.index) != TFTeam_Red)
							Zombies_Currently_Still_Ongoing++;
						
						SetEntProp(summon1, Prop_Data, "m_iHealth", health);
						SetEntProp(summon1, Prop_Data, "m_iMaxHealth", health);
						
						fl_Extra_MeleeArmor[summon1] = fl_Extra_MeleeArmor[npc.index];
						fl_Extra_RangedArmor[summon1] = fl_Extra_RangedArmor[npc.index];
						fl_Extra_Speed[summon1] = fl_Extra_Speed[npc.index];
						fl_Extra_Damage[summon1] = fl_Extra_Damage[npc.index];
						view_as<CClotBody>(summon1).m_iBleedType = BLEEDTYPE_METAL;
					}

					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 0.5;	
					Delay_Attribute[npc.index] = gameTime + 0.5;
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_flTimeUntillNextSummonDrones = gameTime + 25.0;
					npc.m_flTimeUntillNextSummonHardenerDrones += 2.0;
					return 0;
				}
			}
		}
	}
	else if(npc.m_flTimeUntillNextSummonHardenerDrones < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_cheers_soldier");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.5;	
				Delay_Attribute[npc.index] = gameTime + 0.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("layer_taunt_cheers_soldier");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.2);
					npc.SetPlaybackRate(0.0);
					npc.m_iChanged_WalkCycle = 0;

					float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

					int health = ReturnEntityMaxHealth(npc.index) / 25;
					
					int summon = NPC_CreateByName("npc_victoria_anvil", -1, pos, ang, GetTeam(npc.index), "mk2;limit");
					{
						if(GetTeam(npc.index) != TFTeam_Red)
							Zombies_Currently_Still_Ongoing++;
						
						SetEntProp(summon, Prop_Data, "m_iHealth", health);
						SetEntProp(summon, Prop_Data, "m_iMaxHealth", health);
						
						fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
						fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
						fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
						fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
						view_as<CClotBody>(summon).m_iBleedType = BLEEDTYPE_METAL;
					}

					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 0.5;	
					Delay_Attribute[npc.index] = gameTime + 0.5;
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_flTimeUntillNextSummonHardenerDrones = gameTime + 31.0;
					npc.m_flTimeUntillNextSummonDrones +=  2.0;
					return 0;
				}
			}
		}
	}
	else if(npc.m_flTimeUntillAirStrike <gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_cyoa_PDA_intro");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.0;	
				Delay_Attribute[npc.index] = gameTime + 1.0;
				I_cant_do_this_all_day[npc.index]=1;
				npc.m_flTimeUntillSupportSpawn += 25.0;
				npc.m_flTimeUntillNextSummonDrones +=  25.0;
				npc.m_flTimeUntillNextSummonHardenerDrones += 25.0;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.i_GunMode = 1;
					npc.m_iAttacksTillReload += 8;
					I_cant_do_this_all_day[npc.index]=2;
				}
			}
			case 2:
			{
				npc.AddActivityViaSequence("layer_tuant_vehicle_tank_end");
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.34;	
				Delay_Attribute[npc.index] = gameTime + 0.35;
				I_cant_do_this_all_day[npc.index]=3;
			}
			case 3:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					Gone[npc.index] = true;
					b_DoNotUnStuck[npc.index] = true;
					b_NoKnockbackFromSources[npc.index] = true;
					b_ThisEntityIgnored[npc.index] = true;
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					NPC_StopPathing(npc.index);
					npc.m_iChanged_WalkCycle = 0;
					Delay_Attribute[npc.index] = gameTime + 20.0;
					I_cant_do_this_all_day[npc.index]=4;
				}	
			}
			case 4:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					Gone[npc.index] = false;
					b_DoNotUnStuck[npc.index] = false;
					b_NoKnockbackFromSources[npc.index] = false;
					b_ThisEntityIgnored[npc.index] = false;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.AddActivityViaSequence("layer_taunt_maggots_condolence");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.01);
					npc.SetPlaybackRate(1.25);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flDoingAnimation = gameTime + 0.75;	
					npc.m_flTimeUntillAirStrike = gameTime + 40.0;
					I_cant_do_this_all_day[npc.index]=0;
				}
			}
		}
		return 0;
	}
	/*
	else if(npc.m_flTimeUntillDroneSniperShot < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				b_NpcIsInvulnerable[npc.index] = true;
				npc.AddActivityViaSequence("layer_taunt09");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.85);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.5;	
				Delay_Attribute[npc.index] = gameTime + 0.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("layer_taunt_most_wanted");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.3);
					npc.SetPlaybackRate(0.0);
					npc.m_iChanged_WalkCycle = 0;

					UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
					int enemy[MAXENTITIES];
					GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy),_,_,_,(550.0 * 550.0));
					for(int i; i < sizeof(enemy); i++)
					{
						float Spam_delay=0.0;
						if(enemy[i])
						{
							float vEnd[3];
							float RocketDamage = 50.0;
							RocketDamage *= RaidModeScaling ;
							GetAbsOrigin(enemy[i], vEnd);
							DataPack pack;
							CreateDataTimer(Spam_delay, Timer_Bomb_Spam, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(EntIndexToEntRef(npc.index));
							pack.WriteCell(EntIndexToEntRef(enemy[i]));
							Spam_delay += 0.15;
							Handle pack2;
							CreateDataTimer(BombDrop_CHARGE_SPAN, Smite_Timer_BombDrop, pack2, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							WritePackCell(pack2, EntIndexToEntRef(npc.index));
							WritePackFloat(pack2, 0.0);
							WritePackFloat(pack2, vEnd[0]);
							WritePackFloat(pack2, vEnd[1]);
							WritePackFloat(pack2, vEnd[2]);
							WritePackFloat(pack2, RocketDamage);
						}
					}

					npc.m_flAirRaidDelay = gameTime + 2.5;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 30.0;	
					Delay_Attribute[npc.index] = gameTime + 30.0;
					I_cant_do_this_all_day[npc.index]=2;
				}
			}
			case 2:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.PlayAngerSound();
					npc.PlayAngerReaction();
					npc.AddActivityViaSequence("layer_taunt_most_wanted");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.8);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_iChanged_WalkCycle = 0;
					f_VictorianCallToArms[npc.index] = GetGameTime() + 999.0;
					I_cant_do_this_all_day[npc.index]=0;
					//npc.m_flTimeUntillDroneSniperShot += 4.0;
					//npc.m_flTimeUntillNextSummonDrones += 4.0;
					npc.m_flNextRangedSpecialAttackHappens += 4.0;
					npc.m_bFUCKYOU=false;
					b_NpcIsInvulnerable[npc.index] = false;
				}
			}
		}
		return;
	}
	*/
	if(npc.m_iAttacksTillReload > 0)
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			//float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			//float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(IsValidEnemy(npc.index, target))
			{
				npc.PlayGunSound();
				npc.FaceTowards(vecTarget, 20000.0);
				float SpeedProjectile = 1000.0;
				float ProjectileDamage = 30.0;
				int Projectile = npc.FireRocket(vecTarget, ProjectileDamage * RaidModeScaling, SpeedProjectile ,"models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl");

				ProjectileDamage *= 0.35;
				SpeedProjectile *= 0.65;
				float vecForward[3];

				float vAngles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				for(int LoopDo = 1 ; LoopDo <= 4; LoopDo++)
				{
					Projectile = npc.FireRocket(vecTarget, ProjectileDamage * RaidModeScaling, SpeedProjectile ,"models/weapons/w_models/w_rocket.mdl");
					float vAnglesProj[3];
					GetEntPropVector(Projectile, Prop_Data, "m_angRotation", vAnglesProj);
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
					vAnglesProj[1] = vAngles[1];
					switch(LoopDo)
					{
						case 1:
							vAnglesProj[1] -= 30.0;

						case 2:
							vAnglesProj[1] += 30.0;
							
						case 3:
							vAnglesProj[2] -= 30.0;

						case 4:
							vAnglesProj[2] += 30.0;
					}
					
					TeleportEntity(Projectile, NULL_VECTOR, vAnglesProj, vecForward); 

					Initiate_HomingProjectile(Projectile,
					npc.index,
					9999.0,			// float lockonAngleMax,
					13.0,			// float homingaSec,
					false,			// bool LockOnlyOnce,
					true,			// bool changeAngles,
					vAnglesProj,
					npc.m_iTarget);			// float AnglesInitiate[3]);
					
				}
				npc.m_iAttacksTillReload -= 1;
			}
		}
	}
	else
	{
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				if(IsValidEnemy(npc.index, target))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
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
								int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								
								WorldSpaceCenter(targetTrace, vecHit);

								float damage = 70.0;
								damage *= 1.15;

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										if(target > MaxClients)
										{
											StartBleedingTimer_Against_Client(target, npc.index, 15.0, 10);
										}
										else
										{
											if (!IsInvuln(target))
											{
												StartBleedingTimer_Against_Client(target, npc.index, 15.0, 10);
											}
										}
									}
								}
											
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 150.0, true); 
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
				}
			}
		}
		//Melee attack, last prio
		else if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(IsValidEnemy(npc.index, target)) 
			{
				if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.5) && npc.m_iAttacksTillReload > 0)
				{
					int Enemy_I_See;
										
					Enemy_I_See = Can_I_See_Enemy(npc.index, target);
							
					if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
					{
						target = Enemy_I_See;

						npc.PlayMeleeSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
						
						float time = 2.0;
						if(NpcStats_VictorianCallToArms(npc.index))
						{
							time *= 0.75;
						}
						npc.m_flAttackHappens = gameTime + time;
						npc.m_flNextMeleeAttack = gameTime + time;
						npc.m_flDoingAnimation = gameTime + time;
					}
				}
				if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
				{
					int Enemy_I_See;
										
					Enemy_I_See = Can_I_See_Enemy(npc.index, target);
							
					if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
					{
						target = Enemy_I_See;

						npc.PlayMeleeSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
								
						npc.m_flAttackHappens = gameTime + 0.25;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
						npc.m_flDoingAnimation = gameTime + 0.25;
					}
				}
			}
			else
			{
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index);
			}	
		}
	}
	if(npc.m_iAttacksTillReload >0)
	{
		npc.i_GunMode = 1;
	}
	else
	{
		npc.i_GunMode = 0;
	}
	return 0;
}

static void ResetCastellanWeapon(Castellan npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable2))
	{
		RemoveEntity(npc.m_iWearable2);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}
		case 2:
		{
			npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}
		case 0:
		{	
			npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
			SetVariantString("0.75");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}
	}
}


void CreateSupport_Castellan(int entity, int enemySelect, float SelfPos[3])
{
	int SupportTeam;
	char Adddeta[512];
	FormatEx(Adddeta, sizeof(Adddeta), "support_ability");
	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			SupportTeam = NPC_CreateByName("npc_atomizer", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta); //can only be enemy
		}
		case 2:
		{
			FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, entity);
			SupportTeam = NPC_CreateByName("npc_the_wall", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		case 3:
		{
			FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, entity);
			SupportTeam = NPC_CreateByName("npc_harrison", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		default: //This should not happen
		{
			PrintToChatAll("An error occured. Scream at devs");//none
		}
	}
	if(IsValidEntity(SupportTeam))
	{
		MakeObjectIntangeable(SupportTeam);
		b_DoNotUnStuck[SupportTeam] = true;
		b_NoKnockbackFromSources[SupportTeam] = true;
		b_ThisEntityIgnored[SupportTeam] = true;
		Whiteflower_FloweringDarkness npc = view_as<Whiteflower_FloweringDarkness>(SupportTeam);
		npc.m_iTarget = enemySelect;
		npc.m_bDissapearOnDeath = true;
	}
}


static Action Timer_Bomb_Spam(Handle timer, DataPack pack)
{
	pack.Reset();
	Harrison npc = view_as<Harrison>(EntRefToEntIndex(pack.ReadCell()));
	int enemy = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(enemy))
	{
		float vEnd[3];
		float RocketDamage = 50.0;
		RocketDamage *= RaidModeScaling;
			
		GetAbsOrigin(enemy, vEnd);
		vEnd[0] += GetRandomFloat(-250.0, 250.0);
		vEnd[1] += GetRandomFloat(-250.0, 250.0);
		Handle pack2;
		CreateDataTimer(BombDrop_CHARGE_SPAN, Smite_Timer_BombDrop, pack2, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, EntIndexToEntRef(npc.index));
		WritePackFloat(pack2, 0.0);
		WritePackFloat(pack2, vEnd[0]);
		WritePackFloat(pack2, vEnd[1]);
		WritePackFloat(pack2, vEnd[2]);
		WritePackFloat(pack2, RocketDamage);
			
		spawnRing_Vectors(vEnd, BombDrop_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, BombDrop_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
	}
	return Plugin_Stop;
}

public Action Smite_Timer_BombDrop(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= BombDrop_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 100, 100, 255, 120, 1, 0.33, 6.0, 0.4, 1, (BombDrop_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		float vAngles[3];
		int prop2 = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(prop2))
		{
			DispatchKeyValue(prop2, "model", "models/props_combine/headcrabcannister01a.mdl");
			DispatchKeyValue(prop2, "modelscale", "1.00");
			DispatchKeyValue(prop2, "StartDisabled", "false");
			DispatchKeyValue(prop2, "Solid", "0");
			SetEntProp(prop2, Prop_Data, "m_nSolidType", 0);
			DispatchSpawn(prop2);
			SetEntityCollisionGroup(prop2, 1);
			AcceptEntityInput(prop2, "DisableShadow");
			AcceptEntityInput(prop2, "DisableCollision");
			vAngles[0] += 90.0;
			TeleportEntity(prop2, spawnLoc, vAngles, NULL_VECTOR);
			CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(prop2), TIMER_FLAG_NO_MAPCHANGE);
		}

		/*
		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		*/

		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		CreateEarthquake(spawnLoc, 1.0, BombDrop_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, BombDrop_LIGHTNING_RANGE * 1.4,_,0.8, true, 100, false, 25.0);  //Explosion range increace
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, BombDrop_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 250, 150, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + BombDrop_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}