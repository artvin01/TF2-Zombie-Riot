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
static const char g_RangedAttackSoundsPrepare[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};
static const char g_MG42AttackSounds[][] = {
	"weapons/csgo_awp_shoot.wav",
};
static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/sniper_specialcompleted43.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_DronShotHitSounds[] = "weapons/drg_pomson_drain_01.wav";
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

static const char g_LaserBeamSounds[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};
static const char g_LaserBeamSoundsStart[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float Delay_Attribute[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool GETBFG[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool AirRaidStart[MAXENTITIES];


static float Vs_DelayTime[MAXENTITIES];
static int Vs_Stats[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Boom_Its_Too_Loud;
static float Vs_IncomingBoom_Its_Too_Loud;

static int OverrideOwner;

static int gLaser1;
static int gRedPoint;
static int g_BeamIndex_heal;
static int g_HALO_Laser;

void Harrison_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Harrison");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_harrison");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_harrison_raid");
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
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsPrepare)); i++) { PrecacheSound(g_RangedAttackSoundsPrepare[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MG42AttackSounds)); i++) { PrecacheSound(g_MG42AttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_LaserBeamSounds)); i++) { PrecacheSound(g_LaserBeamSounds[i]); }
	for (int i = 0; i < (sizeof(g_LaserBeamSoundsStart)); i++) { PrecacheSound(g_LaserBeamSoundsStart[i]); }

	PrecacheSound(g_DronShotHitSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	for (int i = 0; i < (sizeof(g_HomerunSounds));   i++) { PrecacheSound(g_HomerunSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PlayRocketshotready));   i++) { PrecacheSound(g_PlayRocketshotready[i]);   }
	for (int i = 0; i < (sizeof(g_LasershotReady));   i++) { PrecacheSound(g_LasershotReady[i]);   }
	PrecacheModel("models/player/sniper.mdl");
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_harrison.mp3");
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3");
	
	PrecacheModel(LASERBEAM);
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Harrison(client, vecPos, vecAng, ally, data);
}

static int i_Harrison_eye_particle[MAXENTITIES];

methodmap Harrison < CClotBody
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
		EmitSoundToAll(g_BoomSounds, _, _, _, _, 0.7);
	}
	public void PlayIncomingBoomSound()
	{
		EmitSoundToAll(g_IncomingBoomSounds, _, _, _, _, 0.7);
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
	public void PlayRangedSoundPrepare()
	{
		EmitSoundToAll(g_RangedAttackSoundsPrepare[GetRandomInt(0, sizeof(g_RangedAttackSoundsPrepare) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
		EmitSoundToAll(g_RangedAttackSoundsPrepare[GetRandomInt(0, sizeof(g_RangedAttackSoundsPrepare) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_MG42AttackSounds[GetRandomInt(0, sizeof(g_MG42AttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayLaserBeamSound()
	{
		EmitSoundToAll(g_LaserBeamSounds[GetRandomInt(0, sizeof(g_LaserBeamSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,125));
	}
	public void PlayLaserBeamSoundStart()
	{
		EmitSoundToAll(g_LaserBeamSoundsStart[GetRandomInt(0, sizeof(g_LaserBeamSoundsStart) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	property float m_flTimeUntillSummonRocket
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTimeUntillDroneSniperShot
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextRailgunShots
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flTimeUntillGunReload
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
	property int m_iCurrentAbilityDo
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}

	public Harrison(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Harrison npc = view_as<Harrison>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iCurrentAbilityDo = -1;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		
		OverrideOwner = -1;
		bool CloneDo=false;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(!StrContains(countext[i], "support_ability"))CloneDo=true;
			int ownerdata = StringToInt(countext[i]);
			if(IsValidEntity(ownerdata)) OverrideOwner = ownerdata;
		}
		if(CloneDo)
		{
			func_NPCDeath[npc.index] = view_as<Function>(Clone_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Clone_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Clone_ClotThink);
		
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			CPrintToChatAll("{skyblue}Harrison{default}: I see you Intruders.");
		}
		else
		{
			func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			RemoveAllDamageAddition();
			//IDLE
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.StartPathing();
			npc.m_flSpeed = 300.0;
			Delay_Attribute[npc.index] = 0.0;
			YaWeFxxked[npc.index] = false;
			GETBFG[npc.index] = false;
			ParticleSpawned[npc.index] = false;
			npc.m_bFUCKYOU = false;
			I_cant_do_this_all_day[npc.index] = 0;
			npc.i_GunMode = 0;
			npc.m_flTimeUntillNextRailgunShots = GetGameTime(npc.index) + 22.5;
			npc.m_flTimeUntillSummonRocket = 0.0;
			npc.m_flNextRangedAttack = 0.0;
			npc.m_flAirRaidDelay = 0.0;
			npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 10.0;
			npc.m_flTimeUntillDroneSniperShot = GetGameTime(npc.index) + 5.0;
			npc.m_flTimeUntillGunReload = GetGameTime(npc.index) + 12.5;
			npc.m_iOverlordComboAttack = 0;
			npc.m_iAmountProjectiles = 0;
			npc.m_iAttacksTillReload = 0;
			
			npc.m_fbRangedSpecialOn = false;
			AirRaidStart[npc.index] = false;
			Zero(b_said_player_weaponline);
			fl_said_player_weaponline_time[npc.index] = GetGameTime(npc.index) + GetRandomFloat(0.0, 5.0);
			Vs_RechargeTimeMax[npc.index] = 20.0;
			Victoria_Support_RechargeTimeMax(npc.index, 20.0);
			Vs_Stats[npc.index] = 0;
			
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			b_thisNpcIsARaid[npc.index] = true;
			b_angered_twice[npc.index] = false;
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "obj_status_sentrygun_2", 1, "%t", "Harrison Arrived");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;
			CPrintToChatAll("{skyblue}Harrison{default}: Spotted the Intruders. I guess they leave me no chance but to do it myself");
			
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
				RaidModeScaling *= 0.85;
			}
			
			if(StrContains(data, "nomusic") == -1)
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_harrison.mp3");
				music.Time = 92;
				music.Volume = 1.0;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "RAGE");
				strcopy(music.Artist, sizeof(music.Artist), "Serious sam Reborn mod (?)");
				Music_SetRaidMusic(music);
			}
			
			npc.m_iChanged_WalkCycle = -1;
		}
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/pet_robro.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_starduster/invasion_starduster.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/pyro_hazmat_4/pyro_hazmat_4_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 50, 50, 50, 255);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/sniper/xms2013_sniper_jacket/xms2013_sniper_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 50, 50, 50, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum24_daring_dell_style3/sum24_daring_dell_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({150, 150, 150, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

static void Clone_ClotThink(int iNPC)
{
	Harrison npc = view_as<Harrison>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	if(!IsValidEntity(OverrideOwner))OverrideOwner = npc.index;
	
	bool playsounds=false;
	switch(I_cant_do_this_all_day[npc.index])
	{
		case 0:
		{
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("layer_taunt_i_see_you_primary");
			npc.PlayRocketshotready();
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.01);
			npc.SetPlaybackRate(1.5);
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flDoingAnimation = gameTime + 1.5;
			npc.m_flTimeUntillSummonRocket = 0.15;
			I_cant_do_this_all_day[npc.index]=1;
		}
		case 1:
		{
			UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
			int enemy[8];
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
			for(int i; i < sizeof(enemy); i++)
			{
				for(int k; k < (NpcStats_VictorianCallToArms(OverrideOwner) ? 3 : 2); k++)
				{
					if(enemy[i])
					{
						DataPack pack;
						CreateDataTimer(npc.m_flTimeUntillSummonRocket, Timer_Quad_Rocket_Shot, pack, TIMER_FLAG_NO_MAPCHANGE);
						pack.WriteCell(EntIndexToEntRef(OverrideOwner));
						pack.WriteCell(EntIndexToEntRef(enemy[i]));
						npc.m_flTimeUntillSummonRocket += 0.15;
						playsounds=true;
					}
				}
			}
			I_cant_do_this_all_day[npc.index]=2;
		}
		case 2:
		{
			if(playsounds)npc.PlayHomerunSound();
			I_cant_do_this_all_day[npc.index]=0;
			npc.m_flTimeUntillSummonRocket = 0.0;
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			npc.PlayDeathSound();
			
			b_NpcForcepowerupspawn[npc.index] = 0;
			i_RaidGrantExtra[npc.index] = 0;
			b_DissapearOnDeath[npc.index] = true;
			b_DoGibThisNpc[npc.index] = true;
			SmiteNpcToDeath(npc.index);
		}
	}
}

static Action Clone_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Handled;
}

static void Clone_NPCDeath(int entity)
{
	Harrison npc = view_as<Harrison>(entity);

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
}

static void Internal_ClotThink(int iNPC)
{
	Harrison npc = view_as<Harrison>(iNPC);
	float gameTime = GetGameTime(npc.index);
	//bool GETVictoria_Support = Victoria_Support(npc);
	
	if(!YaWeFxxked[npc.index] && !AirRaidStart[npc.index] && NpcStats_VictorianCallToArms(npc.index) && Victoria_Support(npc))
	{
	
	}
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Harrison_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
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
					CPrintToChatAll("{skyblue}Harrison{default}: You guys are weaker than I expected");
				}
				case 1:
				{
					CPrintToChatAll("{skyblue}Harrison{default}: Comeon, where is your 'adrenaline'?");
				}
				case 2:
				{
					CPrintToChatAll("{skyblue}Harrison{default}: Can't believe {lightblue}Huscarls{default} and {blue}Atomizer{default} was defeated by these weaklings.");
				}
			}
		}
	}
	if(!YaWeFxxked[npc.index] && RaidBossActive != INVALID_ENT_REFERENCE && IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		BlockLoseSay = true;
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{skyblue}Harrison{default}: That's it. Calling in for special forces.");
			case 2:CPrintToChatAll("{skyblue}Harrison{default}: Your small knight pals won't save you now");
			case 3:CPrintToChatAll("{skyblue}Harrison{default}: The artilleries are fully loaded. Bombardment in 3...2...1...");
			case 4:CPrintToChatAll("{skyblue}Harrison{default}: {unique}I need beer.{default}");
		}
		YaWeFxxked[npc.index] = true;
		Vs_RechargeTimeMax[npc.index] = 3.0;
		Victoria_Support_RechargeTimeMax(npc.index, 3.0);
		Vs_RechargeTime[npc.index]=0.0;
		GETBFG[npc.index] = true;
	}
	if(GETBFG[npc.index] && Victoria_Support(npc))
		GETBFG[npc.index] = false;
	
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
	
	if(npc.m_flTimeUntillGunReload < gameTime)
	{
		npc.m_iAttacksTillReload =  RoundToNearest(float(CountPlayersOnRed(2)) * 5); 
		npc.m_flTimeUntillGunReload = 30.0 + gameTime;
	}

	if(npc.m_bFUCKYOU)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				/*
				if(npc.m_iChanged_WalkCycle != 5)
				{
					ResetHarrisonWeapon(npc, 2);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}
				*/
				CPrintToChatAll("{skyblue}Harrison{default}: Hide if you can. I'll get some ammo for my gun.");
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/sniper/taunt_most_wanted/taunt_most_wanted.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				npc.StopPathing();
				
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
					npc.StopPathing();
					
					npc.m_bisWalking = false;
					AirRaidStart[npc.index] = true;
					npc.m_flDoingAnimation = gameTime + 15.0;	
					Delay_Attribute[npc.index] = gameTime + 15.0;
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
					ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
					
					npc.m_flSpeed = 300.0;
					if(IsValidEntity(npc.m_iWearable8))
						RemoveEntity(npc.m_iWearable8);
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_flTimeUntillDroneSniperShot += 4.0;
					npc.m_flTimeUntillNextRailgunShots += 4.0;
					npc.m_flNextRangedSpecialAttackHappens += 4.0;
					npc.m_bFUCKYOU=false;
					AirRaidStart[npc.index] = false;
					b_NpcIsInvulnerable[npc.index] = false;
				}
			}
		}
		if(AirRaidStart[npc.index] && npc.m_flAirRaidDelay < gameTime)
		{
			UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
			int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT];
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), false);
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					float BombPos[3];
					float BombDamage = 45.0;
					BombDamage *= RaidModeScaling;
					float Spam_delay=0.0;
					for(int k; k < 5; k++)
					{
						GetAbsOrigin(enemy[i], BombPos);
						if(k>4)
						{
							BombPos[0] += GetRandomFloat(-750.0, 750.0);
							BombPos[1] += GetRandomFloat(-750.0, 250.0);
						}
						else if(k>2)
						{
							BombPos[0] += GetRandomFloat(-500.0, 500.0);
							BombPos[1] += GetRandomFloat(-500.0, 500.0);
						}
						else if(k>0)
						{
							BombPos[0] += GetRandomFloat(-250.0, 250.0);
							BombPos[1] += GetRandomFloat(-250.0, 250.0);
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
				}
			}
			npc.m_flAirRaidDelay = gameTime + 2.5;
		}
		npc.m_flNextRangedSpecialAttackHappens += 0.1;
		npc.m_flTimeUntillNextRailgunShots += 0.1;
		npc.m_flTimeUntillDroneSniperShot += 0.1;
		RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return;
	}

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = HarrisonSelfDefense(npc,gameTime, npc.m_iTarget, flDistanceToTarget); 

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
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
	{
		HarrisonAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Harrison npc = view_as<Harrison>(victim);
		
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
	Harrison npc = view_as<Harrison>(entity);
	/*
		Explode on death code here please

	*/
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	Vs_RechargeTime[npc.index]=0.0;
	Vs_RechargeTimeMax[npc.index]=0.0;
	
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
		
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client))
			Vs_LockOn[client]=false;
	}
	
	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{skyblue}Harrison{default}: Dammit it hurts!");
		case 1:CPrintToChatAll("{skyblue}Harrison{default}: I should've brought more Explosives...");
		case 2:CPrintToChatAll("{skyblue}Harrison{default}: You intruders will soon face the {crimson}Real Deal.{default}");
	}

}

static void HarrisonAnimationChange(Harrison npc)
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
					ResetHarrisonWeapon(npc, 1);
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
					ResetHarrisonWeapon(npc, 1);
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
					ResetHarrisonWeapon(npc, 2);
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
					ResetHarrisonWeapon(npc, 2);
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
					ResetHarrisonWeapon(npc, 0);
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
					ResetHarrisonWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

static int HarrisonSelfDefense(Harrison npc, float gameTime, int target, float distance)
{
	if(npc.m_flNextRangedSpecialAttackHappens < gameTime && (npc.m_iCurrentAbilityDo == -1 || npc.m_iCurrentAbilityDo == 1))
	{
		bool playsounds=false;
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.m_iCurrentAbilityDo = 1;
				switch(GetRandomInt(1, 4))
				{
					case 1:CPrintToChatAll("{skyblue}Harrison{default}: Do you think I would miss?");
					case 2:CPrintToChatAll("{skyblue}Harrison{default}: I see you.");
					case 3:CPrintToChatAll("{skyblue}Harrison{default}: They won't miss you. Probably.");
					case 4:CPrintToChatAll("{skyblue}Harrison{default}: Auto Rockets are fully charged");
				}
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_i_see_you_primary");
				npc.PlayRocketshotready();
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.5);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flTimeUntillSummonRocket = 0.15;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
				int enemy[8];
				GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
				for(int i; i < sizeof(enemy); i++)
				{
					for(int k; k < (NpcStats_VictorianCallToArms(npc.index) ? 2 : 1); k++)
					{
						if(enemy[i])
						{
							DataPack pack;
							CreateDataTimer(npc.m_flTimeUntillSummonRocket, Timer_Quad_Rocket_Shot, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(EntIndexToEntRef(npc.index));
							pack.WriteCell(EntIndexToEntRef(enemy[i]));
							npc.m_flTimeUntillSummonRocket += 0.15;
							playsounds=true;
						}
					}
				}
				I_cant_do_this_all_day[npc.index]=2;
			}
			case 2:
			{
				npc.m_iCurrentAbilityDo = -1;
				if(playsounds)npc.PlayHomerunSound();
				I_cant_do_this_all_day[npc.index]=0;
				npc.m_flTimeUntillSummonRocket = 0.0;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 12.0;
				npc.m_flTimeUntillNextRailgunShots = gameTime + 2.0;
			}
		}
		return 1;
	}
	else if(npc.m_flTimeUntillNextRailgunShots < gameTime && (npc.m_iCurrentAbilityDo == -1 || npc.m_iCurrentAbilityDo == 2))
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float projectile_speed = 800.0;


		PredictSubjectPositionForProjectiles(npc, target, projectile_speed, 40.0, vecTarget);
		if(!Can_I_See_Enemy_Only(npc.index, target)) //cant see enemy in the predicted position, we will instead just attack normally
		{
			WorldSpaceCenter(target, vecTarget );
		}
		npc.m_iCurrentAbilityDo = 2;

		npc.m_flSpeed = 100.0;
		float flPos[3];
		float flAng[3];
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		
		if(!IsValidEntity(npc.m_iWearable8))
		{
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		}
		if(npc.m_iOverlordComboAttack == 0)
		{
			npc.PlayLaserBeamSoundStart();
		}
		//float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		if(npc.m_iOverlordComboAttack < 12)
		{
			npc.PlayLaserBeamSound();
			npc.m_iOverlordComboAttack += 1;
			HarrisonInitiateLaserAttack(npc.index, vecTarget, flPos); //laser finger!
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flTimeUntillNextRailgunShots = gameTime + 0.25;
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			npc.m_iCurrentAbilityDo = -1;
			npc.m_flSpeed = 300.0;
			npc.m_flTimeUntillNextRailgunShots = gameTime + 18.5;
			npc.m_iOverlordComboAttack = 0;
		}
	}
	else if(npc.m_flTimeUntillDroneSniperShot < gameTime && (npc.m_iCurrentAbilityDo == -1 || npc.m_iCurrentAbilityDo == 3))
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{	
			npc.m_iCurrentAbilityDo = 3;
			npc.m_iAmountProjectiles += 1;
			npc.m_flSpeed = 200.0;
			npc.m_flNextRangedAttack = gameTime + 0.1;

			float flPos[3], flAng[3];
						
			npc.GetAttachment("head", flPos, flAng);
			float flPosEdit[3]; 
			flPosEdit = flPos;
			flPosEdit[0] += 15.0;
			flPosEdit[1] += 25.0;
			flPosEdit[2] += 5.0;

			if (npc.m_iAmountProjectiles == 1)
			{
				if(!IsValidEntity(npc.m_iWearable8))
				{
					npc.m_iWearable8 = ParticleEffectAt(flPosEdit, "raygun_projectile_blue_crit", -1.0);
					SetParent(npc.index, npc.m_iWearable8);
				}
				npc.PlayRangedSoundPrepare();
			}

			if (npc.m_iAmountProjectiles >= 10)
			{
				npc.PlayRangedSound();

				float RocketSpeed = 1200.0;
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float vecDest[3];
				vecDest = vecTarget;
				vecDest[0] += GetRandomFloat(-50.0, 50.0);
				vecDest[1] += GetRandomFloat(-50.0, 50.0);
				vecDest[2] += GetRandomFloat(-50.0, 50.0);
				int DronShot = npc.FireParticleRocket(vecDest, 0.0, RocketSpeed, 0.0, "raygun_projectile_blue_crit", true,_, true, flPosEdit);
				SDKUnhook(DronShot, SDKHook_StartTouch, Rocket_Particle_StartTouch);
				SDKHook(DronShot, SDKHook_StartTouch, Dron_Laser_Particle_StartTouch);
			}
		
	
			
			if (npc.m_iAmountProjectiles >= 35)
			{
				if(IsValidEntity(npc.m_iWearable8))
				{
					RemoveEntity(npc.m_iWearable8);
				}
				npc.m_iCurrentAbilityDo = -1;
				npc.m_flSpeed = 300.0;
				npc.m_iAmountProjectiles = 0;
				npc.m_flTimeUntillDroneSniperShot = gameTime + 15.0;
			}
		}
	}
	if(npc.m_iAttacksTillReload > 0)
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			//float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			//float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(IsValidEnemy(npc.index, target))
			{
				npc.PlayGunSound();
				npc.FaceTowards(vecTarget, 20000.0);
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");

				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
				float y = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecRight[0] + y * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecRight[1] + y * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecRight[2] + y * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				float damage = 5.0 * 0.1 * RaidModeScaling;
				if(distance > 100000.0)	// 316 HU
					damage *= 100000.0 / distance;	// Lower damage based on distance
				
				damage *= 3.5;
				FireBullet(npc.index, npc.m_iWearable2, vecMe, vecDir, damage, 3000.0, DMG_BULLET, "bullet_tracer02_blue_crit");
				npc.m_flNextMeleeAttack = gameTime + 0.1;
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

								float damage = 35.0;
								damage *= 1.15;
								if(ShouldNpcDealBonusDamage(target))
									damage *= 7.0;

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										StartBleedingTimer(targetTrace, npc.index, damage * 0.1, 4, -1, DMG_TRUEDAMAGE, 0);
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
				if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5) && npc.m_iAttacksTillReload > 0)
				{
					int Enemy_I_See;
										
					Enemy_I_See = Can_I_See_Enemy(npc.index, target);
							
					if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
					{
						target = Enemy_I_See;

						npc.PlayMeleeSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
						
						float time = 0.1;
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



static void HarrisonInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{
	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Harrison_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 200;
	int green = 200;
	int blue = 200;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 200);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Combine_Black, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Combine_Black, 0, 0, 0, 0.4, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Combine_Black, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 200);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.2), ClampBeamWidth(diameter * 0.2), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(HarrisonInitiateLaserAttack_DamagePart, 50, pack);
}

static void HarrisonInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 155;
	int green = 155;
	int blue = 255;
	int colorLayer4[4];
	float diameter = float(13 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 255);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Diamond, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Diamond, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, g_Ruina_BEAM_Diamond, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(10);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Harrison_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 70.0 * RaidModeScaling;
	float FarDamage = 60.0 * RaidModeScaling;
	float MaxDistance = 5000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			
			if(victim > MaxClients) //make sure barracks units arent bad, they now get targetted too.
				damage *= 0.25;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


static bool Harrison_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if(IsEntityAlive(entity))
		LaserVarious_HitDetection[entity] = true;
	return false;
}

static bool Harrison_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static Action Timer_Quad_Rocket_Shot(Handle timer, DataPack pack)
{
	pack.Reset();
	Harrison npc = view_as<Harrison>(EntRefToEntIndex(pack.ReadCell()));
	int enemy = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(enemy))
	{
		float vecTarget[3]; WorldSpaceCenter(enemy, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);
		vecSelf[2] += 80.0;
		vecSelf[0] += GetRandomFloat(-20.0, 20.0);
		vecSelf[1] += GetRandomFloat(-20.0, 20.0);
		float RocketDamage = 36.0;
		int RocketGet = npc.FireRocket(vecSelf, RocketDamage * RaidModeScaling, 300.0 ,"models/buildables/sentry3_rockets.mdl");
		if(IsValidEntity(RocketGet))
		{
			DataPack pack2;
			CreateDataTimer(0.5, WhiteflowerTank_Rocket_Stand, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(EntIndexToEntRef(RocketGet));
			pack2.WriteCell(EntIndexToEntRef(enemy));
		}
	}
	return Plugin_Stop;
}

static void ResetHarrisonWeapon(Harrison npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable2))
	{
		RemoveEntity(npc.m_iWearable2);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable2 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("0.75");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			SetVariantInt(32);
			AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		}
		case 2:
		{
			npc.m_iWearable2 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("0.75");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
			SetVariantInt(32);
			AcceptEntityInput(npc.m_iWearable2, "SetBodyGroup");
		}
		case 0:
		{	
			npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		}
	}
}

public Action Timer_Bomb_Spam(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float BombPos[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		BombPos[GetVector] = pack.ReadFloat();
	}
	float BombDamage = pack.ReadFloat();
	float BombChargeTime = pack.ReadFloat();
	float BombChargeSpan = pack.ReadFloat();
	float BombRange = pack.ReadFloat();
	if(IsValidEntity(entity))
	{
		Handle pack2;
		CreateDataTimer(BombChargeSpan, Delay_Drop_Rocket, pack2, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack2, EntIndexToEntRef(entity));
		WritePackFloat(pack2, 0.0);
		WritePackFloat(pack2, BombPos[0]);
		WritePackFloat(pack2, BombPos[1]);
		WritePackFloat(pack2, BombPos[2]);
		WritePackFloat(pack2, BombDamage);
		WritePackFloat(pack2, BombChargeTime);
		WritePackFloat(pack2, BombRange);
			
		spawnRing_Vectors(BombPos, BombRange * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 150, 200, 255, 200, 1, BombChargeTime, 6.0, 0.1, 1, 1.0);
	}
	return Plugin_Stop;
}

static Action Delay_Drop_Rocket(Handle Smite_Logic, DataPack pack)
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
	float BombChargeTime = ReadPackFloat(pack);
	float BombRange = ReadPackFloat(pack);
	
	if (NumLoops >= BombChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 100, 100, 255, 120, 1, 0.33, 6.0, 0.4, 1, (BombRange * 5.0)/float(sequential));
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
			CreateTimer(2.0, Timer_RemoveEntityFancy, EntIndexToEntRef(prop2), TIMER_FLAG_NO_MAPCHANGE);
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
		
		CreateEarthquake(spawnLoc, 1.0, BombRange * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, BombRange * 1.4,_,0.8, true, 100, false, 25.0);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, BombRange * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 250, 150, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + BombChargeTime);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
		WritePackFloat(pack, BombChargeTime);
		WritePackFloat(pack, BombRange);
	}
	
	return Plugin_Continue;
}

/*static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
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

static bool Victoria_Support(Harrison npc)
{
	float GameTime = GetGameTime(npc.index);
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;

	Vs_DelayTime[npc.index] = GameTime + 0.1;
	float Vs_Raged = (YaWeFxxked[npc.index] ? 1000.0 : 250.0);
	bool Vs_Online=false;
	bool Vs_Fired=false;
	bool Vs_IncomingBoom=false;
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy[MAXENTITIES];
	GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), false);
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client) && !IsPlayerAlive(client) && TeutonType[client] != TEUTON_NONE)
			Vs_LockOn[client]=false;
	}
	for(int i; i < sizeof(enemy); i++)
	{
		if(!IsValidEnemy(npc.index, enemy[i]))
			continue;
		Vs_Online = true;
		float vecTarget[3];
		GetEntPropVector(enemy[i], Prop_Data, "m_vecAbsOrigin", vecTarget);
		vecTarget[2] += 5.0;
	
		if(Vs_RechargeTime[npc.index] < Vs_RechargeTimeMax[npc.index])
		{
			float position[3];
			position[0] = vecTarget[0];
			position[1] = vecTarget[1];
			position[2] = vecTarget[2] + 3000.0;
			if(Vs_RechargeTime[npc.index] < (Vs_RechargeTimeMax[npc.index] - 2.0))
			{
				Vs_Temp_Pos[enemy[i]][0] = position[0];
				Vs_Temp_Pos[enemy[i]][1] = position[1];
				Vs_Temp_Pos[enemy[i]][2] = position[2] - 3000.0;
				if(IsValidClient(enemy[i]) && !IsFakeClient(enemy[i])) Vs_LockOn[enemy[i]]=true;
			}
			else
			{
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsValidClient(client) && !IsFakeClient(client))
						Vs_LockOn[client]=false;
				}
			}
			TE_SetupBeamRingPoint(Vs_Temp_Pos[enemy[i]], Vs_Raged- ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*Vs_Raged), (Vs_Raged - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*Vs_Raged))+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {255, 255, 255, 150}, 0, 0);
			TE_SendToAll();
			float position2[3];
			position2[0] = Vs_Temp_Pos[enemy[i]][0];
			position2[1] = Vs_Temp_Pos[enemy[i]][1];
			position2[2] = Vs_Temp_Pos[enemy[i]][2] + 65.0;
			TE_SetupBeamRingPoint(position2, Vs_Raged, Vs_Raged+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
			TE_SendToAll();
			TE_SetupBeamRingPoint(Vs_Temp_Pos[enemy[i]], Vs_Raged, Vs_Raged+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
			TE_SendToAll();
			TE_SetupBeamPoints(Vs_Temp_Pos[enemy[i]], position, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {145, 47, 47, 150}, 3);
			TE_SendToAll();
			TE_SetupGlowSprite(Vs_Temp_Pos[enemy[i]], gRedPoint, 0.1, 1.0, 255);
			TE_SendToAll();
			if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0))
			{
				Vs_ParticleSpawned[enemy[i]] = ParticleEffectAt(position, "kartimpacttrail", 2.0);
				SetEdictFlags(Vs_ParticleSpawned[enemy[i]], (GetEdictFlags(Vs_ParticleSpawned[enemy[i]]) | FL_EDICT_ALWAYS));
				Vs_IncomingBoom=true;
			}
		}
		else if(Vs_Stats[npc.index]==1)
		{
			float position[3];
			position[0] = Vs_Temp_Pos[enemy[i]][0];
			position[1] = Vs_Temp_Pos[enemy[i]][1];
			position[2] = Vs_Temp_Pos[enemy[i]][2] - 100.0;
			TeleportEntity(Vs_ParticleSpawned[enemy[i]], position, NULL_VECTOR, NULL_VECTOR);
			position[2] += 100.0;
			
			i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_TRUE_DAMAGE;
			if(YaWeFxxked[npc.index])
				Explode_Logic_Custom(9001.0, 0, npc.index, -1, position, 1000.0, 1.0, _, true, 20, _, _, FxxkOFF);
			else
				Explode_Logic_Custom((YaWeFxxked[npc.index] ? 9001.0 : 100.0*RaidModeScaling), 0, npc.index, -1, position, (YaWeFxxked[npc.index] ? 1000.0 : 125.0), 1.0, _, true, 20);
			ParticleEffectAt(position, "hightower_explosion", 1.0);
			i_ExplosiveProjectileHexArray[npc.index] = 0; 
			Vs_Fired = true;
		}
	}
	
	if(Vs_IncomingBoom)
	{
		if(Vs_IncomingBoom_Its_Too_Loud < GetGameTime())
		{
			npc.PlayIncomingBoomSound();
			Vs_IncomingBoom_Its_Too_Loud = GetGameTime() + 4.0;
		}
		Vs_Stats[npc.index]=1;
	}
	if(Vs_Fired)
	{
		if(Vs_Boom_Its_Too_Loud < GetGameTime())
		{
			npc.PlayBoomSound();
			Vs_Boom_Its_Too_Loud = GetGameTime() + 4.0;
		}
		Vs_RechargeTime[npc.index]=0.0;
		Vs_RechargeTime[npc.index]=0.0;
		Vs_Stats[npc.index]=0;
	}
	if(Vs_Online)
	{
		Vs_RechargeTime[npc.index] += 0.1;
		if(Vs_RechargeTime[npc.index]>(Vs_RechargeTimeMax[npc.index]+1.0) && Vs_Stats[npc.index]<=0)
			Vs_RechargeTime[npc.index]=0.0;
	}
	
	return Vs_Fired;
}

static Action Dron_Laser_Particle_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	int inflictor = h_ArrowInflictorRef[entity];
	if(inflictor != -1)
		inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

	if(inflictor == -1)
		inflictor = owner;
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	float damage = 10.0;
	damage *= RaidModeScaling;
	Explode_Logic_Custom(damage, owner, inflictor, -1, ProjectileLoc, 150.0, _, _, true, _, false, _);
	ParticleEffectAt(ProjectileLoc, "mvm_soldier_shockwave", 1.0);
	ParticleEffectAt(ProjectileLoc, "drg_cow_explosion_sparkles_blue", 1.5);
	EmitSoundToAll(g_DronShotHitSounds, 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, -1, ProjectileLoc);
	int particle = EntRefToEntIndex(i_rocket_particle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	RemoveEntity(entity);
	return Plugin_Handled;
}

static void FxxkOFF(int entity, int victim, float damage, int weapon)
{
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(entity) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		if(IsValidClient(victim))
			ForcePlayerSuicide(victim);
		else
			SmiteNpcToDeath(victim);
	}
}