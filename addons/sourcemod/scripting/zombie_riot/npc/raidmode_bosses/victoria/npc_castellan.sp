#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts02.mp3",
	"vo/taunts/soldier_taunts03.mp3",
	"vo/taunts/soldier_taunts04.mp3",
	"vo/taunts/soldier_taunts05.mp3",
	"vo/taunts/soldier_taunts06.mp3",
	"vo/taunts/soldier_taunts07.mp3",
	"vo/taunts/soldier_taunts08.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts10.mp3",
	"vo/taunts/soldier_taunts11.mp3",
	"vo/taunts/soldier_taunts12.mp3",
	"vo/taunts/soldier_taunts13.mp3",
	"vo/taunts/soldier_taunts14.mp3",
	"vo/taunts/soldier_taunts15.mp3",
	"vo/taunts/soldier_taunts16.mp3",
	"vo/taunts/soldier_taunts17.mp3",
	"vo/taunts/soldier_taunts18.mp3",
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};
static const char g_RocketAttackSounds[][] = {
	"weapons/rpg/rocketfire1.wav",
};
static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/compmode/cm_soldier_pregamefirst_rare_06.mp3";
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

static const char g_SummonDroneSound[][] = {
	"mvm/mvm_bought_in.wav",
};
static const char g_SummonAlotOfRockets[][] = {
	"weapons/rocket_ll_shoot.wav",
};

static int gLaser1;
static int gBluePoint;

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float f_TimeSinceHasBeenHurt;
static float Delay_Attribute[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static int HowManyMelee[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool Gone[MAXENTITIES];
static bool Gone_Stats[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool AlreadySpawned[MAXENTITIES];


static int Temp_Target[MAXENTITIES];

static int SaveSolidFlags[MAXENTITIES];
static int SaveSolidType[MAXENTITIES];

void Castellan_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Castellan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_castellan");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_castellan_raid");
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
	for (int i = 0; i < (sizeof(g_RocketAttackSounds)); i++) { PrecacheSound(g_RocketAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_SummonDroneSound)); i++) { PrecacheSound(g_SummonDroneSound[i]); }
	for (int i = 0; i < (sizeof(g_SummonAlotOfRockets)); i++) { PrecacheSound(g_SummonAlotOfRockets[i]); }
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
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_castellan.mp3");
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3");
	PrecacheModel(LASERBEAM);
	gBluePoint = PrecacheModel("sprites/blueglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheModel("materials/sprites/laserbeam.vmt", true);
	PrecacheModel("materials/sprites/halo01.vmt", true);
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
	public void PlayDroneSummonSound() {
	
		EmitSoundToAll(g_SummonDroneSound[GetRandomInt(0, sizeof(g_SummonDroneSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomingBadRocketSound() {
	
		EmitSoundToAll(g_SummonAlotOfRockets[GetRandomInt(0, sizeof(g_SummonAlotOfRockets) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
		EmitSoundToAll(g_RocketAttackSounds[GetRandomInt(0, sizeof(g_RocketAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL - 5, _, BOSS_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
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
	property float m_flTimeUntillHomingStrike
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flTimeUntillSummonRocket
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
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
		
		SaveSolidFlags[npc.index]=GetEntProp(npc.index, Prop_Send, "m_usSolidFlags");
		SaveSolidType[npc.index]=GetEntProp(npc.index, Prop_Send, "m_nSolidType");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Castellan_Sensal_Win);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		Delay_Attribute[npc.index] = 0.0;
		YaWeFxxked[npc.index] = false;
		ParticleSpawned[npc.index] = false;
		Gone[npc.index] = false;
		f_TimeSinceHasBeenHurt = 0.0;
		Gone_Stats[npc.index] = false;
		npc.m_bFUCKYOU = false;
		I_cant_do_this_all_day[npc.index] = 0;
		npc.i_GunMode = 0;
		HowManyMelee[npc.index] = 0;
		npc.m_flTimeUntillSupportSpawn = GetGameTime() + 15.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAirRaidDelay = 0.0;
		npc.m_flTimeUntillAirStrike = GetGameTime() + 10.0;
		npc.m_flTimeUntillNextSummonDrones = GetGameTime() + 15.0;
		npc.m_flTimeUntillNextSummonHardenerDrones = GetGameTime() + 13.5;
		npc.m_flTimeUntillHomingStrike = GetGameTime() + 5.0;
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
				ShowGameText(client_check, "obj_status_sentrygun_3", 1, "%t", "Castellan Arrived");
			}
		}
		RemoveAllDamageAddition();
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		float value;
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
			value = float(Waves_GetRoundScale()+1);
		}

		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
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
		
		if(value > 25 && value < 35)
		{
			RaidModeScaling *= 0.85;
		}
		else if(value > 35)
		{
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.75;
		}
		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
			b_NpcUnableToDie[npc.index] = true;
		}

		if(StrContains(data, "nomusic") == -1)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_castellan.mp3");
			music.Time = 154;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "06Graveyard_Arena3");
			strcopy(music.Artist, sizeof(music.Artist), "Serious sam Reborn mod (?)");
			Music_SetRaidMusic(music);
		}

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 150, 150, 255, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/fdu.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
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
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		npc.m_iWearable8 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2022_safety_stripes/hwn2022_safety_stripes.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable8, "SetModelScale");
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
		
		CPrintToChatAll("{blue}카스텔란{default}: 빅토리아의 이름으로, 이 이상 지나가게 두진 않겠다.");
		
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
	
	if(f_TimeSinceHasBeenHurt)
	{
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		BlockLoseSay = true;

		if(f_TimeSinceHasBeenHurt < GetGameTime())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(NpcStats_VictorianCallToArms(npc.index) && !Gone_Stats[npc.index] && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Castellan_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}

	if(IsValidEntity(npc.index)&&Gone[npc.index])
	{
		if(Gone_Stats[npc.index])
		{
			int particle = EntRefToEntIndex(i_Castellan_eye_particle[npc.index]);
			if(IsValidEntity(particle))
			{
				RemoveEntity(particle);
				i_Castellan_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
			}
			ParticleSpawned[npc.index] = false;
			npc.m_iChanged_WalkCycle = 0;
			b_NoHealthbar[npc.index]=true;
			Npc_BossHealthBar(npc);
			
			if(IsValidEntity(i_InvincibleParticle[npc.index]))
			{
				particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
				SetEntityRenderMode(particle, RENDER_NONE);
				SetEntityRenderColor(particle, 255, 255, 255, 1);
				SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			SetEntityRenderMode(npc.index, RENDER_NONE);
			SetEntityRenderColor(npc.index, 255, 255, 255, 1);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntityRenderMode(npc.m_iWearable2, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable3))
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable4))
			{
				SetEntityRenderMode(npc.m_iWearable4, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable5))
			{
				SetEntityRenderMode(npc.m_iWearable5, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable6))
			{
				SetEntityRenderMode(npc.m_iWearable6, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable7))
			{
				SetEntityRenderMode(npc.m_iWearable7, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				SetEntityRenderMode(npc.m_iWearable8, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iTeamGlow))
				RemoveEntity(npc.m_iTeamGlow);
		}
		else
		{
			b_NoHealthbar[npc.index]=false;
			Npc_BossHealthBar(npc);
			if(IsValidEntity(i_InvincibleParticle[npc.index]))
			{
				int Shield = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
				if(b_NpcIsInvulnerable[npc.index])
				{
					if(i_InvincibleParticlePrev[Shield] != 0)
					{
						SetEntityRenderColor(Shield, 0, 255, 0, 255);
						i_InvincibleParticlePrev[Shield] = 0;
					}
				}
				else if(i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
				{
					if(i_InvincibleParticlePrev[Shield] != 1)
					{
						SetEntityRenderColor(Shield, 0, 50, 50, 35);
						i_InvincibleParticlePrev[Shield] = 1;
					}
				}
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 30000.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 30000.0);
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable3))
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable4))
			{
				SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable5))
			{
				SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable6))
			{
				SetEntityRenderMode(npc.m_iWearable6, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable7))
			{
				SetEntityRenderMode(npc.m_iWearable7, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				SetEntityRenderMode(npc.m_iWearable8, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(!IsValidEntity(npc.m_iTeamGlow))
			{
				npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
				npc.m_bTeamGlowDefault = false;
				SetVariantColor(view_as<int>({150, 150, 150, 200}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
		}
		Gone[npc.index]=false;
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
					CPrintToChatAll("{blue}카스텔란{default}: 약골들 같으니!");
				}
				case 1:
				{
					CPrintToChatAll("{blue}카스텔란{default}: 널 잡은 후에는 다시 전선으로 돌아갈 수 있겠군.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}카스텔란{default}: 네 동지들은 전부 사라졌다.");
				}
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{blue}카스텔란{default}: 전차들의 연료는 충분하다. 돌격!");
			case 2:CPrintToChatAll("{blue}카스텔란{default}: 자이베리아 놈들은 이 짓을 한 대가로 피바다가 될 것이다.");
			case 3:CPrintToChatAll("{blue}카스텔란{default}: 이제 끝이군! 전부 돌격!");
			case 4:CPrintToChatAll("{blue}카스텔란{default}: 보아하나 네 작은 기사 친구들도 더 이상 버틸 수 없었나보군.");
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		for(int i; i<10; i++)
		{
			int spawn_index = NPC_CreateByName("npc_victorian_tank", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), "only");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 3.0);
				fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index] * 10.0;
				fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index]* 20.0;
				if(GetTeam(iNPC) != TFTeam_Red)
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
				int Decicion = TeleportDiversioToRandLocation(spawn_index,_,1250.0, 500.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 250.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 0.0);
			}
		}
		npc.PlayDeathSound();
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
	if(npc.m_bFUCKYOU)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				b_NpcIsInvulnerable[npc.index] = true;
				npc.AddActivityViaSequence("layer_tauntcan_it");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.5;	
				Delay_Attribute[npc.index] = gameTime + 1.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.PlayAngerSound();
					npc.PlayAngerReaction();
					ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
					b_NpcIsInvulnerable[npc.index] = false;
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_bFUCKYOU = false;
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
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
			case 2:
			{
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.m_flDoingAnimation += 0.1;
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
		CastellanAnimationChange(npc);
	if(!Gone_Stats[npc.index])
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
	if(i_RaidGrantExtra[npc.index] == 1)
	{
		if((RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			f_TimeSinceHasBeenHurt = GetGameTime() + 36.0;
			RaidModeTime += 900.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			SetEntityCollisionGroup(npc.index, 24);
			SetTeam(npc.index, TFTeam_Red);
			GiveProgressDelay(45.0);
			
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			float AllyAng[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
			}
			int SensalSpawn = NPC_CreateByName("npc_sensal", -1, SelfPos, AllyAng, GetTeam(npc.index), "victoria_cutscene"); //can only be enemy
			if(IsValidEntity(SensalSpawn))
			{
				if(GetTeam(SensalSpawn) != TFTeam_Red)
				{
					NpcAddedToZombiesLeftCurrently(SensalSpawn, true);
				}
				SetEntProp(SensalSpawn, Prop_Data, "m_iHealth", 100000000);
				SetEntProp(SensalSpawn, Prop_Data, "m_iMaxHealth", 100000000);
			}
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.25 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.m_fbRangedSpecialOn)
		{
			I_cant_do_this_all_day[npc.index]=0;
			ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
			IncreaseEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			npc.m_bFUCKYOU=true;
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
		
	int particle = EntRefToEntIndex(i_Castellan_eye_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_Castellan_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
	}

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{blue}카스텔란{default}: 으, 지원이 필요하다!");
		case 1:CPrintToChatAll("{blue}카스텔란{default}: 네 놈들이 {gold}빅토리아{default}의 영광을 짓밟게 두진 않겠다!");
		case 2:CPrintToChatAll("{blue}카스텔란{default}: 기대해라, 다음 번엔 {crimson}더 강한 공세{default}로 되돌아올테니.");
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
		CPrintToChatAll("{blue}카스텔란{default}: 어서 와라, 지원이 좀 필요하다.");
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
				npc.StopPathing();
				
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
					pos[2] += 50.0;
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

					int health = ReturnEntityMaxHealth(npc.index) / 85;
					char Adddeta[512];
					FormatEx(Adddeta, sizeof(Adddeta), "mk2;limit");
					FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, npc.index);
					npc.PlayDroneSummonSound();
					int summon1 = NPC_CreateByName("npc_victoria_fragments", -1, pos, ang, GetTeam(npc.index), Adddeta);

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

					npc.StopPathing();
					
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 0.5;	
					Delay_Attribute[npc.index] = gameTime + 0.5;
					I_cant_do_this_all_day[npc.index]=0;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						npc.m_flTimeUntillNextSummonDrones = gameTime + 10.0;
					}
					else
					{
						npc.m_flTimeUntillNextSummonDrones = gameTime + 15.0;
					}
					
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
				npc.StopPathing();
				
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
					pos[2] += 50.0;
					float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

					int health = ReturnEntityMaxHealth(npc.index) / 75;
					char Adddeta[512];
					FormatEx(Adddeta, sizeof(Adddeta), "mk2;limit");
					FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, npc.index);
					npc.PlayDroneSummonSound();
					int summon = NPC_CreateByName("npc_victoria_anvil", -1, pos, ang, GetTeam(npc.index), Adddeta);
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

					npc.StopPathing();
					
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 0.5;	
					Delay_Attribute[npc.index] = gameTime + 0.5;
					I_cant_do_this_all_day[npc.index]=0;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						npc.m_flTimeUntillNextSummonHardenerDrones = gameTime + 10.0;
					}
					else
					{
						npc.m_flTimeUntillNextSummonHardenerDrones = gameTime + 20.0;
					}
					npc.m_flTimeUntillNextSummonDrones +=  2.0;
					return 0;
				}
			}
		}
	}
	else if(npc.m_flTimeUntillAirStrike <gameTime)
	{
		
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		npc.m_flDoingAnimation = gameTime + 0.35;
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				CPrintToChatAll("{blue}카스텔란{default}: 주 목표가 발견됐다, {skyblue}해리슨{default}!");
				npc.AddActivityViaSequence("layer_taunt_cyoa_PDA_intro");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				Delay_Attribute[npc.index] = gameTime + 1.3;
				I_cant_do_this_all_day[npc.index]=1;
				npc.m_flTimeUntillSupportSpawn += 12.0;
				npc.m_flTimeUntillNextSummonDrones +=  12.0;
				npc.m_flTimeUntillNextSummonHardenerDrones += 12.0;
				npc.m_flTimeUntillHomingStrike += 12.0;
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.i_GunMode = 1;
					npc.m_iAttacksTillReload += 8;
					npc.m_iChanged_WalkCycle = 0;
					I_cant_do_this_all_day[npc.index]=2;
				}
			}
			case 2:
			{
				npc.AddActivityViaSequence("layer_tuant_vehicle_tank_end");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				Delay_Attribute[npc.index] = gameTime + 0.35;
				I_cant_do_this_all_day[npc.index]=3;
			}
			case 3:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					CPrintToChatAll("{skyblue}해리슨{default}: 확인. 주 목표 제거 시도.");
					Gone_Stats[npc.index] = true;
					Gone[npc.index] = true;
					b_DoNotUnStuck[npc.index] = true;
					b_NoKnockbackFromSources[npc.index] = true;
					b_NpcIsInvulnerable[npc.index] = true;
					b_ThisEntityIgnored[npc.index] = true;
					MakeObjectIntangeable(npc.index);
					npc.m_iChanged_WalkCycle = 0;
					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
					ParticleEffectAt(WorldSpaceVec, "smoke_marker", 10.0);
					npc.PlayDeathSound();
					Temp_Target[npc.index]=-1;
					/*
					UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
					int enemy[MAXENTITIES];
					int EnemiesFound = 0;
					GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
					do
					{
						if(!enemy[0]) //there wasnt one enemy found.
							break;

						EnemiesFound = 0;
						for(int i; i < sizeof(enemy); i++)
						{
							if(enemy[i])
							{
								EnemiesFound++;
							}
						}
						Temp_Target[npc.index] = enemy[GetRandomInt(0, EnemiesFound)];
					}
					while(EnemiesFound > 0 && (!IsValidEntity(Temp_Target[npc.index]) || GetTeam(npc.index) == GetTeam(Temp_Target[npc.index]) || npc.index==Temp_Target[npc.index]));
					{
						if(IsValidClient(Temp_Target[npc.index]))
							Vs_LockOn[Temp_Target[npc.index]]=true;
					}
					*/
					Temp_Target[npc.index] = npc.m_iTarget;
					Vs_LockOn[Temp_Target[npc.index]] = true;
							
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", npc.index, SNDCHAN_STATIC, 120, _, 1.0);
					TeleportDiversioToRandLocation(npc.index,_,1250.0, 750.0);
					Delay_Attribute[npc.index] = gameTime + 10.0;
					I_cant_do_this_all_day[npc.index]=4;
				}	
			}
			case 4:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					if(IsValidClient(Temp_Target[npc.index]))
						Vs_LockOn[Temp_Target[npc.index]]=false;
					Temp_Target[npc.index]=-1;
					Gone_Stats[npc.index] = false;
					Gone[npc.index] = true;
					Gone[npc.index] = true;
					b_DoNotUnStuck[npc.index] = false;
					b_NoKnockbackFromSources[npc.index] = false;
					b_NpcIsInvulnerable[npc.index] = false;
					b_ThisEntityIgnored[npc.index] = false;
					SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", SaveSolidFlags[npc.index]);
					SetEntProp(npc.index, Prop_Data, "m_nSolidType", SaveSolidType[npc.index]);
					if(GetTeam(npc.index) == TFTeam_Red)
						SetEntityCollisionGroup(npc.index, 24);
					else
						SetEntityCollisionGroup(npc.index, 9);
					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
					npc.AddActivityViaSequence("layer_taunt_maggots_condolence");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.5);
					npc.SetPlaybackRate(1.25);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flDoingAnimation = gameTime + 0.75;	
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						npc.m_flTimeUntillAirStrike = gameTime + 30.0;
					}
					else
					{
						npc.m_flTimeUntillAirStrike = gameTime + 40.0;
					}
					I_cant_do_this_all_day[npc.index]=0;
				}
			}
		}
		if(IsValidEntity(Temp_Target[npc.index]))
		{
			float BombPos[3], TempPos[3];
			GetAbsOrigin(Temp_Target[npc.index], BombPos);
			TempPos[0] = BombPos[0];
			TempPos[1] = BombPos[1];
			TempPos[2] = BombPos[2] + 3000.0;
			BombPos[2] += 5.0;
			TE_SetupBeamPoints(BombPos, TempPos, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {115, 125, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupGlowSprite(BombPos, gBluePoint, 0.1, 1.0, 255);
			TE_SendToAll();
			BombPos[2] -= 5.0;
			if(npc.m_flAirRaidDelay < gameTime)
			{
				float BombDamage = 50.0;
				BombDamage *= RaidModeScaling;
				float Spam_delay=0.0;
				for(int AirRaid; AirRaid < 8; AirRaid++)
				{
				if(AirRaid>4)
				{
					PredictSubjectPositionForProjectiles(npc, Temp_Target[npc.index], 100.0, _,BombPos);
					BombPos[0] += GetRandomFloat(-25.0, 25.0);
					BombPos[1] += GetRandomFloat(-25.0, 25.0);
				}
				else if(AirRaid>0)
				{
					BombPos[0] += GetRandomFloat(-500.0, 500.0);
					BombPos[1] += GetRandomFloat(-500.0, 500.0);
				}
				DataPack pack;
				CreateDataTimer(Spam_delay, Timer_Bomb_Spam, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(npc.index));
				pack.WriteFloat(BombPos[0]);
				pack.WriteFloat(BombPos[1]);
				pack.WriteFloat(BombPos[2]);
				pack.WriteFloat(BombDamage);
				pack.WriteFloat(3.0);
				pack.WriteFloat(1.0);
				pack.WriteFloat(150.0);
				Spam_delay += 0.15;
				}
				npc.m_flAirRaidDelay = gameTime + 2.5;
			}
		}
		RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 2;
	}
	else if(npc.m_flTimeUntillHomingStrike <gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				CPrintToChatAll("{blue}카스텔란{default}: 그 로켓들은 널 놓치지 않는다.");
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_neck_snap_soldier");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.0;	
				Delay_Attribute[npc.index] = gameTime + 1.0;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.m_flTimeUntillSummonRocket = 0.0;
					UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
					int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
					GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
					for(int i; i < sizeof(enemy); i++)
					{
						if(enemy[i])
						{
							DataPack pack;
							CreateDataTimer(npc.m_flTimeUntillSummonRocket, Timer_Rocket_Shot, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(EntIndexToEntRef(npc.index));
							pack.WriteCell(EntIndexToEntRef(enemy[i]));
							npc.m_flTimeUntillSummonRocket += 0.15;
						}
					}
					I_cant_do_this_all_day[npc.index]=0;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						npc.m_flTimeUntillHomingStrike = gameTime + 22.5;
					}
					else
					{
						npc.m_flTimeUntillHomingStrike = gameTime + 35.0;
					}
				}
			}
		}
	}
	if(npc.m_iAttacksTillReload > 0)
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			//float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			//float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(IsValidEnemy(npc.index, target))
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
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
				npc.m_flNextMeleeAttack = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 0.75 : 1.5);
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
						if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
						{
							if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
							{
								PlaySound = true;
								int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								
								WorldSpaceCenter(targetTrace, vecHit);

								float damage = 40.0;
								if(ShouldNpcDealBonusDamage(target))
									damage *= 7.0;

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										StartBleedingTimer(target, npc.index, damage * 0.15, 4, -1, DMG_TRUEDAMAGE, 0);
									}
								}
											
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 150.0, true); 
								
								if(HowManyMelee[npc.index] > 2)
								{
									float BombPos[3];
									float BombDamage = 100.0;
									BombDamage *= RaidModeScaling;
									for(int AirRaid; AirRaid < 2; AirRaid++)
									{
										GetAbsOrigin(target, BombPos);
										if(AirRaid>0)
										{
											PredictSubjectPositionForProjectiles(npc, target, 125.0, _,BombPos);
										}
										DataPack pack;
										CreateDataTimer(0.01, Timer_Bomb_Spam, pack, TIMER_FLAG_NO_MAPCHANGE);
										pack.WriteCell(EntIndexToEntRef(npc.index));
										pack.WriteFloat(BombPos[0]);
										pack.WriteFloat(BombPos[1]);
										pack.WriteFloat(BombPos[2]);
										pack.WriteFloat(BombDamage);
										pack.WriteFloat(3.0);
										pack.WriteFloat(1.0);
										pack.WriteFloat(150.0);
									}
									HowManyMelee[npc.index] = 0;
								}
								else
								{
									HowManyMelee[npc.index] += 1;
								}
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
						
						float time = 3.0;
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

static Action Timer_Rocket_Shot(Handle timer, DataPack pack)
{
	pack.Reset();
	Castellan npc = view_as<Castellan>(EntRefToEntIndex(pack.ReadCell()));
	int enemy = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(enemy))
	{
		float vecTarget[3]; WorldSpaceCenter(enemy, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);
		vecSelf[2] += 80.0;
		vecSelf[0] += GetRandomFloat(-20.0, 20.0);
		vecSelf[1] += GetRandomFloat(-20.0, 20.0);
		float RocketDamage = 40.0;
		int RocketGet = npc.FireRocket(vecSelf, RocketDamage * RaidModeScaling, 50.0 ,"models/buildables/sentry3_rockets.mdl");
		npc.PlayHomingBadRocketSound();
		if(IsValidEntity(RocketGet))
		{
			for(int r=1; r<=5; r++)
            { 
                DataPack pack2;
                CreateDataTimer(1.35 * float(r), WhiteflowerTank_Rocket_Stand, pack2, TIMER_FLAG_NO_MAPCHANGE);
                pack2.WriteCell(EntIndexToEntRef(RocketGet));
                pack2.WriteCell(EntIndexToEntRef(enemy));
            }
		}
	}
	return Plugin_Stop;
}


public void Raidmode_Castellan_Sensal_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	BlockLoseSay = true;
}