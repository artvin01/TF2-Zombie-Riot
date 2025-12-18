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
static const char g_PainSounds[][] = {
	"vo/soldier_painsevere01.mp3",
	"vo/soldier_painsevere02.mp3",
	"vo/soldier_painsevere03.mp3",
	"vo/soldier_painsevere04.mp3",
	"vo/soldier_painsevere05.mp3",
	"vo/soldier_painsevere06.mp3"
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

static const char g_MeleeAttackSounds[] = "weapons/machete_swing.wav";
static const char g_RocketAttackSounds[] = "weapons/rpg/rocketfire1.wav";

static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/compmode/cm_soldier_pregamefirst_rare_06.mp3";

static const char g_SummonDroneSound[] = "mvm/mvm_bought_in.wav";
static const char g_SummonAlotOfRockets[] = "weapons/rocket_ll_shoot.wav";
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static int g_Laser;
static int g_BluePoint;
static int g_RedPoint;

static int SaveSolidFlags[MAXENTITIES];
static int SaveSolidType[MAXENTITIES];

static int NitroFuelStack[MAXENTITIES];

/* Victoria Nuke */
static float Vs_DelayTime[MAXENTITIES];
static int Vs_Stats[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Boom_Its_Too_Loud;
static float Vs_IncomingBoom_Its_Too_Loud;

/* Extra DMGType Resist */
static float BlastDMG[MAXENTITIES];
static float MagicDMG[MAXENTITIES];
static float BulletDMG[MAXENTITIES];
static bool BlastArmor[MAXENTITIES];
static bool MagicArmor[MAXENTITIES];
static bool BulletArmor[MAXENTITIES];

/*The desc only needs to be printed once.*/
static bool AtomizerDesc;
static bool HuscarlsDesc;
static bool HarrisonDesc;

static bool CounterattackDesc;

static int SupportTeamContinue;
static int NextSupport;

static int AirStrikeTalk[MAXENTITIES];

static bool ParticleSpawned[MAXENTITIES];

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
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_PainSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheSound(g_SummonDroneSound);
	PrecacheSound(g_SummonAlotOfRockets);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_RocketAttackSounds);
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3");
	PrecacheSound("ambient/alarms/doomsday_lift_alarm.wav", true);
	PrecacheSound("weapons/airstrike_fire_crit.wav", true);
	PrecacheSound("weapons/cow_mangler_explode.wav", true);
	
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_castellan.mp3");
	
	PrecacheModel("models/player/soldier.mdl");
	g_BluePoint = PrecacheModel("sprites/blueglow1.vmt");
	g_RedPoint = PrecacheModel("sprites/redglow1.vmt");
	g_Laser = PrecacheModel(LASERBEAM);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Castellan(client, vecPos, vecAng, ally, data);
}

methodmap Castellan < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayPainSound() 
	{
		EmitSoundToAll(g_PainSounds[GetRandomInt(0, sizeof(g_PainSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerReaction()
	{
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDroneSummonSound()
	{
		EmitSoundToAll(g_SummonDroneSound, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomingBadRocketSound()
	{
		EmitSoundToAll(g_SummonAlotOfRockets, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_RocketAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL - 5, _, BOSS_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	
	property bool m_bHalfRage
	{
		public get()							{ return b_NPCTeleportOutOfStuck[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NPCTeleportOutOfStuck[this.index] = TempValueForProperty; }
	}
	property int m_bAirStrikeTalk
	{
		public get()							{ return AirStrikeTalk[this.index]; }
		public set(int TempValueForProperty) 	{ AirStrikeTalk[this.index] = TempValueForProperty; }
	}
	property float m_flTimeUntillSupportSpawn
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeUntillHomingStrike
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTimeUntillAirStrike
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flVICTORIA_NUKE_SETUP
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flAirStrike_Silo_1
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flAirStrike_Silo_2
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flAirStrike_Silo_3
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flDelaySounds
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flRequestDrone
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flTimeSinceHasBeenHurt
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
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
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = Castellan_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Castellan_OnTakeDamage;
		func_NPCThink[npc.index] = Castellan_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);

		//IDLE
		npc.m_iState = 0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flCharge_Duration = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flCharge_delay = 330.0;
		npc.m_flSpeed = npc.m_flCharge_delay;
		npc.m_flDoingAnimation = 0.0;
		npc.m_iHealthBar = 2;
		
		npc.m_flMeleeArmor = 1.25;
		
		BlockLoseSay=false;
		AlreadySaidWin=false;
		
		npc.m_bAirStrikeTalk = 0;
		NitroFuelStack[npc.index] = 0;
		ParticleSpawned[npc.index] = false;
		npc.m_flDead_Ringer_Invis_bool = false;
		npc.m_flDead_Ringer_Invis = 0.0;
		npc.m_bDissapearOnDeath = true;
		BlastDMG[npc.index] = 0.0;
		MagicDMG[npc.index] = 0.0;
		BulletDMG[npc.index] = 0.0;
		
		npc.m_bFUCKYOU = false;
		npc.m_bFUCKYOU_move_anim = false;
		npc.m_bHalfRage = false;
		
		npc.m_flTimeUntillSupportSpawn = GetGameTime() + 5.0;
		npc.m_flTimeUntillHomingStrike = GetGameTime() + 10.0;
		npc.m_flTimeUntillAirStrike = GetGameTime() + 30.0;
		npc.m_flVICTORIA_NUKE_SETUP = GetGameTime() + 45.0;
		npc.m_flRequestDrone = GetGameTime() + 15.0;
		npc.m_flTimeSinceHasBeenHurt = 0.0;
		npc.m_flAirStrike_Silo_1 = 0.0;
		npc.m_flAirStrike_Silo_2 = 0.0;
		npc.m_flAirStrike_Silo_3 = 0.0;
		
		Vs_RechargeTimeMax[npc.index] = 18.0;
		Victoria_Support_RechargeTimeMax(npc.index, 18.0);
		Vs_Stats[npc.index] = 0;
		
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		fl_ruina_battery_max[npc.index]=100.0;
		fl_ruina_battery[npc.index]=0.0;
		ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
		
		npc.m_iMaxAmmo = 8+RoundToNearest(float(CountPlayersOnRed(2)) * 0.25);
		npc.m_iAmmo = 0;
		ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
		
		npc.StartPathing();

		EmitSoundToAll("weapons/airstrike_fire_crit.wav", _, _, _, _, 1.0);
		EmitSoundToAll("weapons/airstrike_fire_crit.wav", _, _, _, _, 1.0);
		npc.m_flDelaySounds=GetGameTime()+0.4;
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
		npc.m_flDead_Ringer = RaidModeScaling*0.02;
		
		if(StrContains(data, "final_item") != -1)
		{
			i_RaidGrantExtra[npc.index] = 1;
			b_NpcUnableToDie[npc.index] = true;
			switch(GetRandomInt(0,2))
			{
				case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Intro-1", false, true);
				case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Intro-2", false, true);
				case 2:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Intro-3", false, true);
			}
		}
		else
		{
			NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Intro-4", false, true);
			RequestFrame(WhyNoFactory, EntIndexToEntRef(npc.index));
		}

		if(StrContains(data, "nomusic") == -1)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_castellan.mp3");
			music.Time = 154;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Deep Dive - Arena Fight");
			strcopy(music.Artist, sizeof(music.Artist), "Serious Sam 4: Reborn mod");
			Music_SetRaidMusic(music);
		}

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 150, 150, 255, 255);

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/soldier/fdu.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable3, 50, 50, 50, 255);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sept2014_lone_survivor/sept2014_lone_survivor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 50, 50, 50, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2022_safety_stripes/hwn2022_safety_stripes.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		//SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
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

static void Castellan_FORVICTORIA(int iNPC)
{
	Castellan npc = view_as<Castellan>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	Victoria_Support(npc, 1, false);
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	StealthDevice(npc, (npc.m_flDead_Ringer_Invis > gameTime));
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	switch(npc.m_iState)
	{
		case 0:
		{
			b_NpcIsInvulnerable[npc.index] = true;
			npc.m_bHalfRage=true;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.PlayPainSound();
			npc.m_bisWalking = false;
			npc.m_bAllowBackWalking = false;
			npc.m_iChanged_WalkCycle = -1;
			npc.m_flSpeed = 0.0;
			npc.AddActivityViaSequence("layer_taunt_neck_snap_soldier");
			npc.SetCycle(0.5);
			npc.SetPlaybackRate(1.0);
			switch(GetRandomInt(0,1))
			{
				case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_GetLifeLost-1", false, false);
				case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_GetLifeLost-2", false, false);
			}
			npc.m_flDoingAnimation = gameTime + 1.25;
			npc.m_iState = 1;
		}
		case 1:
		{
			if(npc.m_flDoingAnimation < gameTime)
			{
				ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
				NPCStats_RemoveAllDebuffs(npc.index, 1.0);
				b_DoNotUnStuck[npc.index] = true;
				b_NoKnockbackFromSources[npc.index] = true;
				b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = true;
				MakeObjectIntangeable(npc.index);
				npc.m_iChanged_WalkCycle = -1;
				npc.PlayDeathSound();
				npc.m_flDead_Ringer_Invis = gameTime + 10.0;
				npc.m_iState = 2;
			}
		}
		case 2:
		{
			if(!IsValidEntity(SupportTeamContinue) || b_NpcHasDied[SupportTeamContinue] || GetTeam(npc.index) != GetTeam(SupportTeamContinue))
			{
				NextSupport++;
				if(NextSupport>3)NextSupport=1;
				TeleportDiversioToRandLocation(npc.index,_,600.0, 250.0);
				WorldSpaceCenter(npc.index, VecSelfNpc);
				npc.m_iTarget = GetClosestTarget(npc.index);
				int GetAbility;
				switch(NextSupport)
				{
					case 1:
					{
						GetAbility=2;
					}
					case 2:
					{
						switch(GetRandomInt(1, 2))
						{
							case 1:GetAbility=1;
							case 2:GetAbility=4;
						}
					}
				}
				SupportTeamContinue=CreateSupport_Castellan(npc.index, npc.m_iTarget, VecSelfNpc, NextSupport, GetAbility);
				if(IsValidEntity(npc.m_iWearable9))
					RemoveEntity(npc.m_iWearable9);
				GetAbsOrigin(npc.index, VecSelfNpc);
				npc.m_iWearable9 = ParticleEffectAt_Parent(VecSelfNpc, "teleporter_mvm_bot_persist", npc.index, "", {0.0,0.0,0.0});
			}
			if(npc.m_flDead_Ringer_Invis < gameTime)
			{
				if(IsValidEntity(npc.m_iWearable9))
					RemoveEntity(npc.m_iWearable9);
				WorldSpaceCenter(npc.index, VecSelfNpc);
				npc.m_iAmmo = npc.m_iMaxAmmo;
				fl_ruina_battery[npc.index]=100.0;
				ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
				b_DoNotUnStuck[npc.index] = false;
				b_NoKnockbackFromSources[npc.index] = false;
				b_NpcIsInvulnerable[npc.index] = false;
				b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = false;
				SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", SaveSolidFlags[npc.index]);
				SetEntProp(npc.index, Prop_Data, "m_nSolidType", SaveSolidType[npc.index]);
				if(GetTeam(npc.index) == TFTeam_Red)
					SetEntityCollisionGroup(npc.index, 24);
				else
					SetEntityCollisionGroup(npc.index, 9);
				npc.AddActivityViaSequence("layer_taunt_maggots_condolence");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.25);
				npc.m_flDoingAnimation = gameTime + 0.75;
				npc.PlayDeathSound();
				npc.m_iState = 3;
			}
		}
		case 3:
		{
			if(npc.m_flDoingAnimation < gameTime)
			{
				if(IsValidEntity(npc.m_iWearable9))
					RemoveEntity(npc.m_iWearable9);
				npc.m_flTimeUntillAirStrike = gameTime + 30.0;
				npc.m_flTimeUntillSupportSpawn = gameTime + 23.0;
				npc.m_flTimeUntillHomingStrike = gameTime + 10.0;
				npc.m_flRequestDrone = gameTime + 15.0;
				npc.m_flDead_Ringer_Invis = 0.0;
				ResetCastellanWeapon(npc, 1);
				npc.PlayAngerReaction();
				npc.PlayAngerSound();
				switch(GetRandomInt(0,2))
				{
					case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_LifeLost-1", false, false);
					case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_LifeLost-2", false, false);
					case 2:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_LifeLost-3", false, false);
				}
				npc.m_iTarget = Victoria_GetTargetDistance(npc.index, true, false);
				GetAbsOrigin(npc.m_iTarget, VecSelfNpc);
				NPC_CreateByName("npc_victoria_factory", -1, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), "type-d;donusetele");
				npc.m_flGetClosestTargetTime=0.0;
				RaidModeTime += 35.0;
				func_NPCThink[npc.index] = Castellan_ClotThink;
			}
		}
	}
	RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
}

static void Castellan_ClotThink(int iNPC)
{
	Castellan npc = view_as<Castellan>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flTimeSinceHasBeenHurt)
	{
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		BlockLoseSay = true;

		if(npc.m_flTimeSinceHasBeenHurt < gameTime)
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	
	if(npc.m_flDelaySounds&&npc.m_flDelaySounds<gameTime)
	{
		EmitSoundToAll("weapons/cow_mangler_explode.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
		EmitSoundToAll("weapons/cow_mangler_explode.wav", _, SNDCHAN_AUTO, 90, _, 1.0);
		npc.m_flDelaySounds=0.0;
	}
	
	if(!npc.m_iHealthBar)
	{
		if(i_RaidGrantExtra[npc.index] == 1)
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

			ReviveAll(true);

			npc.m_flTimeSinceHasBeenHurt = GetGameTime() + 36.0;
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
		}
		else
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		npc.m_iState = 0;
		npc.m_flDoingAnimation = 0.0;
		return;
	}
	
	if(npc.m_iHealthBar!=2)
	{
		if(!npc.m_bFUCKYOU_move_anim)
		{
			npc.m_iState = 0;
			npc.m_flDoingAnimation = 0.0;
			npc.m_bFUCKYOU_move_anim=true;
			func_NPCThink[npc.index] = Castellan_FORVICTORIA;
			return;
		}
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == GetTeam(npc.index))
				ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.3);
		}
	}
	
	if(npc.m_bAirStrikeTalk)
	{
		if(Vs_RechargeTime[npc.index]>Vs_RechargeTimeMax[npc.index]*0.7)
			Vs_RechargeTime[npc.index]=Vs_RechargeTimeMax[npc.index]*0.7;
		DefaultAirStrikeTalk(npc, gameTime);
	}
	bool CastellanInvis = StealthDevice(npc, (npc.m_flDead_Ringer_Invis > gameTime));
	if(CastellanInvis && NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}
	
	if(CastellanInvis && (npc.m_flVICTORIA_NUKE_SETUP < gameTime || npc.m_iHealthBar!=2 || npc.m_bHalfRage))
	{
		//It's probably fair
		static int AddNuke;
		static bool Mk2;
		if(npc.m_flVICTORIA_NUKE_SETUP==1.0)
		{
			if(Victoria_Support(npc, AddNuke, Mk2))
			{
				if(npc.m_iHealthBar!=2)
					AddNuke=2;
				else if(npc.m_bHalfRage)
					AddNuke=1;
				else
					AddNuke=0;
				if(NpcStats_VictorianCallToArms(npc.index))
					Mk2=true;
				else
					Mk2=false;
			}
		}
		else
		{
			AddNuke=0;
			switch(GetRandomInt(0,1))
			{
				case 0:NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-1", false);
				case 1:NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-11", false);
			}
			EmitSoundToAll("ambient/alarms/doomsday_lift_alarm.wav");
			npc.m_flVICTORIA_NUKE_SETUP=1.0;
		}
	}

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,1))
			{
				case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Lastman-1", false, false);
				case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Lastman-2", false, false);
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !npc.m_bFUCKYOU && GetTeam(npc.index) != TFTeam_Red)
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		switch(GetRandomInt(0, 1))
		{
			case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_TimeUp-1", false, false);
			case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_TimeUp-1", false, false);
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		for(int i; i<10; i++)
		{
			int spawn_index = NPC_CreateByName("npc_victorian_tank", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), "alway_mount_lmg;turnrate20000.0");
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
		AlreadySaidWin = true;
		npc.m_bFUCKYOU = true;
	}
	
	if(BlockLoseSay && npc.m_bFUCKYOU && i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		DeleteAndRemoveAllNpcs = 3.0;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_coffee");
		npc.SetCycle(0.01);
		ResetCastellanWeapon(npc, 4);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		BlockLoseSay = true;
		AlreadySaidWin = true;
		
		switch(GetRandomInt(0,1))
		{
			case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_GameEnd-1", false, false);
			case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_GameEnd-2", false, false);
		}
		return;
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

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iState == -1)
			npc.m_iState = 0;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		static bool ReAnim;
		switch(Man_Work(npc, gameTime, VecSelfNpc, vecTarget, flDistanceToTarget, !CastellanInvis))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					ReAnim=true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flCharge_delay = 330.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
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
				ReAnim=false;
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
					npc.m_iChanged_WalkCycle = 1;
				ReAnim=true;
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.m_flCharge_delay = 0.0;
					npc.StopPathing();
				}
				ReAnim=true;
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ReAnim=true;
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.m_flCharge_delay = 330.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
				ReAnim=false;
			}
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ReAnim=true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.m_flCharge_delay = 290.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
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
				ReAnim=false;
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime = 0.0;
	npc.m_flSpeed = npc.m_flCharge_delay*(1.0+(NitroFuelStack[npc.index]*0.025));
	if(!npc.m_flDead_Ringer_Invis_bool)
		npc.PlayIdleAlertSound();
}

static void CastellanIntoAir(Castellan npc, bool ReAime)
{
	static bool ImAirBone;
	switch(npc.m_iChanged_WalkCycle)
	{
		case 0, 3:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_MELEE");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					ImAirBone=false;
				}
			}
		}
		case 4:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					ImAirBone=false;
				}
			}
		}
	}
}

static Action Castellan_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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
	
	bool hot;
	bool magic;
	bool pierce;
	
	if((damagetype & DMG_TRUEDAMAGE))
	{
		pierce = true;
	}
	
	if((damagetype & DMG_BLAST))
	{
		hot = true;
		pierce = true;
	}
	
	if(damagetype & DMG_PLASMA)
	{
		magic = true;
		pierce = true;
	}
	else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
	{
		magic = true;
	}
	
	if(npc.m_flCharge_Duration < gameTime)
	{
		BlastArmor[npc.index] = false;
		MagicArmor[npc.index] = false;
		BulletArmor[npc.index] = false;
	}
	if(hot)
	{
		if(BlastArmor[npc.index])
		{
			damage *= 0.65;
			damagePosition[2] += 65.0;
			npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
			damagePosition[2] -= 65.0;
		}
		BlastDMG[npc.index] += damage;
	}
	if(magic)
	{
		if(MagicArmor[npc.index])
		{
			damage *= 0.65;
			damagePosition[2] += 65.0;
			npc.DispatchParticleEffect(npc.index, "medic_resist_match_fire_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
			damagePosition[2] -= 65.0;
		}
		MagicDMG[npc.index] += damage;
	}
	if(!pierce)
	{
		if(BulletArmor[npc.index])
		{
			damage *= 0.65;
			damagePosition[2] += 65.0;
			npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
			damagePosition[2] -= 65.0;
		}
		BulletDMG[npc.index] += damage;
	}
	
	/*Punishment*/
	if(!Can_I_See_Enemy_Only(npc.index, attacker) && npc.m_flAttackHappens_2 < gameTime)
	{
		if(!CounterattackDesc)
		{
			NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Counterattack", false, false);
			CounterattackDesc=true;
		}
		float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget);
		Engage_HE_Strike(npc.index, vecTarget, 100.0 * RaidModeScaling, 2.25, EXPLOSION_RADIUS*2.0);
		npc.m_flAttackHappens_2 = gameTime + 2.4;
	}
	
	if(!npc.m_bHalfRage)
	{
		int maxhealth = ReturnEntityMaxHealth(npc.index);
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		float ratio = float(health) / float(maxhealth);
		if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
			npc.m_bHalfRage=true;
	}

	return Plugin_Changed;
}

static void Castellan_NPCDeath(int entity)
{
	Castellan npc = view_as<Castellan>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
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

	bool bExtraction=false;
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int GetFactory = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if (IsValidEntity(GetFactory) && i_NpcInternalId[GetFactory] == VictorianFactory_ID() && !b_NpcHasDied[GetFactory] && GetTeam(GetFactory) == TFTeam_Blue)
		{
			VictorianFactory vFactory = view_as<VictorianFactory>(GetFactory);
			i_AttacksTillMegahit[vFactory.index] = 608;
			bExtraction=true;
		}
	}
	if(bExtraction)
	{
		EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
		EmitSoundToAll("misc/doomsday_lift_start.wav", _, _, _, _, 1.0);
	}

	if(BlockLoseSay)
		return;

	NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_EscapePlan", false, false);

}
static int Man_Work(Castellan npc, float gameTime, float VecSelfNpc[3], float vecTarget[3], float distance, bool CastellanInvis)
{
	static int Temp_Target[3];
	if(CastellanInvis)
	{
		if(IsValidEnemy(npc.index, Temp_Target[0]))
			CastellanAirStrike(npc, Temp_Target[0], 1, gameTime);
		else 
		{
			if(IsValidClient(Temp_Target[0]))
				Vs_LockOn[Temp_Target[0]]=false;
			Temp_Target[0] = GetClosestTarget(npc.index);
		}
		if(npc.m_bHalfRage)
		{
			if(IsValidEnemy(npc.index, Temp_Target[1]))
				CastellanAirStrike(npc, Temp_Target[1], 2, gameTime);
			else 
			{
				if(IsValidClient(Temp_Target[1]))
					Vs_LockOn[Temp_Target[1]]=false;
				Temp_Target[1] = Victoria_GetTargetDistance(npc.index, true, false);
			}
		}
		if(npc.m_iHealthBar!=2)
		{
			if(IsValidEnemy(npc.index, Temp_Target[2]))
				CastellanAirStrike(npc, Temp_Target[2], 3, gameTime);
			else 
			{
				if(IsValidClient(Temp_Target[2]))
					Vs_LockOn[Temp_Target[2]]=false;
				Temp_Target[2] = Victoria_GetTargetDistance(npc.index, false, false);
			}
		}
		RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillSupportSpawn += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillHomingStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flRequestDrone += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 2;
	}
	else if(npc.m_flDead_Ringer_Invis && npc.m_flDead_Ringer_Invis < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				if(IsValidClient(Temp_Target[0]))
					Vs_LockOn[Temp_Target[0]]=false;
				if(IsValidClient(Temp_Target[1]))
					Vs_LockOn[Temp_Target[1]]=false;
				if(IsValidClient(Temp_Target[2]))
					Vs_LockOn[Temp_Target[2]]=false;
				b_DoNotUnStuck[npc.index] = false;
				b_NoKnockbackFromSources[npc.index] = false;
				b_NpcIsInvulnerable[npc.index] = false;
				b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = false;
				SetEntProp(npc.index, Prop_Send, "m_usSolidFlags", SaveSolidFlags[npc.index]);
				SetEntProp(npc.index, Prop_Data, "m_nSolidType", SaveSolidType[npc.index]);
				if(GetTeam(npc.index) == TFTeam_Red)
					SetEntityCollisionGroup(npc.index, 24);
				else
					SetEntityCollisionGroup(npc.index, 9);
				ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
				npc.AddActivityViaSequence("layer_taunt_maggots_condolence");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.25);
				npc.m_flDoingAnimation = gameTime + 0.75;
				npc.m_iState = 1;
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					ResetCastellanWeapon(npc, 1);
					npc.m_iAmmo = npc.m_iMaxAmmo;
					npc.m_flDead_Ringer_Invis = 0.0;
					npc.m_flTimeUntillAirStrike = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 30.0 : 40.0);
					npc.m_iState = -1;
				}
			}
		}
		RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillSupportSpawn += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillHomingStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flRequestDrone += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 2;
	}
	bool SupportInOperation;
	if(npc.m_flTimeUntillSupportSpawn < gameTime)
	{
		if(!SupportTeamContinue)
		{
			static int Tempindex;
			switch(npc.m_iState)
			{
				case 0:
				{
					ResetCastellanWeapon(npc, 3);
					switch(GetRandomInt(0,2))
					{
						case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability1-1", false, false);
						case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability1-2", false, false);
						case 2:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability1-3", false, false);
					}
					npc.AddActivityViaSequence("layer_taunt_flag_soldier");
					npc.SetCycle(0.01);
					npc.SetPlaybackRate(1.5);
					npc.m_flDoingAnimation = gameTime + 1.1;
					npc.m_flAttackHappens = 0.0;
					npc.m_iState = 1;
				}
				case 1:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						NextSupport++;
						if(NextSupport>3)NextSupport=1;
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpc);
						Tempindex=CreateSupport_Castellan(npc.index, npc.m_iTarget, VecSelfNpc, NextSupport);
						npc.m_flDoingAnimation = gameTime + 0.35;
						npc.m_iState = 2;
					}
				}
				case 2:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.AddActivityViaSequence("layer_taunt_flag_soldier_outro");
						npc.SetCycle(0.01);
						npc.SetPlaybackRate(1.0);
						npc.m_flDoingAnimation = gameTime + 0.65;
						npc.m_iState = 3;
					}
				}
				case 3:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						ResetCastellanWeapon(npc, 0);
						SupportTeamContinue=Tempindex;
						npc.m_iState = -1;
					}
				}
			}
			return 2;
		}
		if(!IsValidEntity(SupportTeamContinue) || b_NpcHasDied[SupportTeamContinue] || GetTeam(npc.index) != GetTeam(SupportTeamContinue))
		{
			switch(NextSupport)
			{
				case 1:
				{
					NPCPritToChat_Noname("Castellan_Talk_Ability1-4", false);
					NitroFuelStack[npc.index]++;
					if(!AtomizerDesc)
					{
						NPCPritToChat_Noname("Castellan_AtomizerDesc", false);
						AtomizerDesc=true;
					}
				}
				case 2:
				{
					NPCPritToChat_Noname("Castellan_Talk_Ability1-5", false);
					BlastArmor[npc.index] = false;
					MagicArmor[npc.index] = false;
					BulletArmor[npc.index] = false;
					npc.m_flCharge_Duration=gameTime+10.0;
					switch(Castellan_Get_HighDMGType(npc))
					{
						case 0:BlastArmor[npc.index]=true;
						case 1:MagicArmor[npc.index]=true;
						default:BulletArmor[npc.index]=true;
					}
					GrantEntityArmor(npc.index, false, 0.025, 0.5, 0);
					if(!HuscarlsDesc)
					{
						NPCPritToChat_Noname("Castellan_HuscarlsDesc", false);
						HuscarlsDesc=true;
					}
				}
				case 3:
				{
					NPCPritToChat_Noname("Castellan_Talk_Ability1-6", false);
					RaidModeScaling+=npc.m_flDead_Ringer;
					if(!HarrisonDesc)
					{
						NPCPritToChat_Noname("Castellan_HarrisonDesc", false);
						HarrisonDesc=true;
					}
				}
				default:PrintToChatAll("WTF dev!!!!!!!!!!!!!!!!!!");
			}
			npc.m_flTimeUntillSupportSpawn = gameTime + 20.0;
			SupportTeamContinue=0;
		}
		else SupportInOperation=true;
		npc.m_flTimeUntillHomingStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillAirStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flRequestDrone += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
	}
	
	if(!SupportInOperation && npc.m_flTimeUntillHomingStrike < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				npc.AddActivityViaSequence("layer_taunt_neck_snap_soldier");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 1.0;
				switch(GetRandomInt(0,1))
				{
					case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability3-1", false, false);
					case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability3-2", false, false);
				}
				npc.m_iState = 1;
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.m_flDoingAnimation = 0.0;
					UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
					int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
					GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
					for(int i; i < sizeof(enemy); i++)
					{
						if(enemy[i])
						{
							DataPack pack;
							CreateDataTimer(npc.m_flDoingAnimation, Timer_Rocket_Shot, pack, TIMER_FLAG_NO_MAPCHANGE);
							pack.WriteCell(EntIndexToEntRef(npc.index));
							pack.WriteCell(EntIndexToEntRef(enemy[i]));
							npc.m_flDoingAnimation += 0.15;
						}
					}
					npc.m_flTimeUntillHomingStrike = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 22.5 : 35.0);
					npc.m_iState = -1;
				}
			}
		}
		npc.m_flTimeUntillSupportSpawn += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillAirStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flRequestDrone += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 2;
	}
	else if(npc.m_flRequestDrone < gameTime)
	{
		char Adddeta[512];
		int whattarget;
		switch(GetRandomInt(0,2))
		{
			case 0:whattarget=npc.m_iTarget;
			case 1:whattarget=Victoria_GetTargetDistance(npc.index, true, false);
			case 2:whattarget=Victoria_GetTargetDistance(npc.index, false, false);
		}
		FormatEx(Adddeta, sizeof(Adddeta), "lifetime30.0;raidmode;tracking;");
		if(NpcStats_VictorianCallToArms(npc.index))
			FormatEx(Adddeta, sizeof(Adddeta), "%s;mk2", Adddeta);
		static bool NextDrone;
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int GetCPU = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(GetCPU) && i_NpcInternalId[GetCPU] == VictorianFactory_ID() && !b_NpcHasDied[GetCPU] && GetTeam(GetCPU) == GetTeam(npc.index))
			{
				WorldSpaceCenter(GetCPU, VecSelfNpc);
				VecSelfNpc[2]+=45.0;
				int DroneIndex;
				if(NextDrone)
				{
					FormatEx(Adddeta, sizeof(Adddeta), "%soverridetarget%i", Adddeta, npc.index);
					DroneIndex = NPC_CreateByName("npc_victoria_anvil", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
				}
				else
				{
					FormatEx(Adddeta, sizeof(Adddeta), "%soverridetarget%i", Adddeta, whattarget);
					DroneIndex = NPC_CreateByName("npc_victoria_fragments", npc.index, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), Adddeta);
				}
				if(DroneIndex > MaxClients)
				{
					int maxhealth = RoundToFloor(ReturnEntityMaxHealth(npc.index)*0.15);
					NpcAddedToZombiesLeftCurrently(DroneIndex, true);
					SetEntProp(DroneIndex, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(DroneIndex, Prop_Data, "m_iMaxHealth", maxhealth);
					fl_Extra_MeleeArmor[DroneIndex] = fl_Extra_MeleeArmor[npc.index];
					fl_Extra_RangedArmor[DroneIndex] = fl_Extra_RangedArmor[npc.index];
					fl_Extra_Speed[DroneIndex] = fl_Extra_Speed[npc.index];
					fl_Extra_Damage[DroneIndex] = fl_Extra_Damage[npc.index];
					FreezeNpcInTime(DroneIndex, 3.0, true);
					IncreaseEntityDamageTakenBy(DroneIndex, 0.000001, 3.0);
				}
			}
		}
		NextDrone=!NextDrone;
		npc.PlayDroneSummonSound();
		npc.m_flRequestDrone = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 28.0 : 40.0);
	}
	else if(npc.m_flTimeUntillAirStrike < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
				npc.AddActivityViaSequence("layer_taunt_cyoa_PDA_intro");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.0);
				npc.m_bAirStrikeTalk=1;
				npc.m_flDoingAnimation = gameTime + 1.3;
				npc.m_iState = 1;
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0);
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.AddActivityViaSequence("layer_tuant_vehicle_tank_end");
					npc.SetCycle(0.01);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_iState = 2;
				}
			}
			case 2:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					ParticleEffectAt(VecSelfNpc, "teleported_blue", 0.5);
					ParticleEffectAt(VecSelfNpc, "smoke_marker", 10.0);
					
					NPCStats_RemoveAllDebuffs(npc.index, 1.0);
					b_DoNotUnStuck[npc.index] = true;
					b_NoKnockbackFromSources[npc.index] = true;
					b_NpcIsInvulnerable[npc.index] = true;
					b_ThisEntityIgnoredEntirelyFromAllCollisions[npc.index] = true;
					MakeObjectIntangeable(npc.index);
					npc.m_iChanged_WalkCycle = -1;
					npc.PlayDeathSound();
					npc.m_flDead_Ringer_Invis = gameTime + 10.0;

					if(npc.m_iHealthBar!=2)
						Temp_Target[2] = Victoria_GetTargetDistance(npc.index, false, false);
					if(npc.m_bHalfRage)
						Temp_Target[1] = Victoria_GetTargetDistance(npc.index, true, false);
					Temp_Target[0] = npc.m_iTarget;
					if(IsValidClient(Temp_Target[0]))
						Vs_LockOn[Temp_Target[0]] = true;
					if(IsValidClient(Temp_Target[1]))
						Vs_LockOn[Temp_Target[1]] = true;
					if(IsValidClient(Temp_Target[2]))
						Vs_LockOn[Temp_Target[2]] = true;
					//Appears in a different location from the sound location.
					TeleportDiversioToRandLocation(npc.index,_,1250.0, 750.0);
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", _, SNDCHAN_STATIC, 120, _, 1.0);
					EmitSoundToAll("mvm/ambient_mp3/mvm_siren.mp3", _, SNDCHAN_STATIC, 120, _, 1.0);
					npc.m_iState = -1;
				}
			}
		}
		RaidModeTime += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillSupportSpawn += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillHomingStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flRequestDrone += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 2;
	}
	
	float AttackSpeed = 1.0-(NitroFuelStack[npc.index]*0.05);
	if(AttackSpeed<0.05)AttackSpeed=0.05;
	if(npc.m_iAmmo)
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget) && npc.m_flNextRangedAttack < gameTime)
		{
			int AnimLayer = npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
			npc.SetLayerPlaybackRate(AnimLayer, 1.0*(1.0/AttackSpeed));
			npc.SetLayerCycle(AnimLayer, 0.01);
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
		
			npc.m_iAmmo--;
			npc.m_flNextRangedAttack = gameTime + ((NpcStats_VictorianCallToArms(npc.index) ? 0.62 : 0.8)*AttackSpeed);
		}
		if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.5))
			npc.m_flGetClosestTargetTime -= 0.076;
		if(!npc.m_iAmmo)
			ResetCastellanWeapon(npc, 0);
		
		npc.m_flTimeUntillSupportSpawn += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		npc.m_flTimeUntillHomingStrike += (0.12 + DEFAULT_UPDATE_DELAY_FLOAT);
		return 4;
	}
	else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				int AnimLayer = npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.SetLayerPlaybackRate(AnimLayer, 1.0*(1.0/AttackSpeed));
				npc.SetLayerCycle(AnimLayer, 0.01);
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					bool PlaySound = false;
					for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
					{
						if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
						{
							if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
							{
								PlaySound = true;
								int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								
								WorldSpaceCenter(targetTrace, vecHit);
								float damage = 40.0 * RaidModeScaling;
								if(ShouldNpcDealBonusDamage(targetTrace))
									damage *= 7.0;
								KillFeed_SetKillIcon(npc.index, "fireaxe");
								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 750.0, true);
									}
									TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
									TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
								}
								
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 375.0, true);
								if(fl_ruina_battery[npc.index] >= fl_ruina_battery_max[npc.index])
								{
									float BombPos[3];
									float BombDamage = 100.0;
									BombDamage *= RaidModeScaling;
									for(int AirRaid; AirRaid < 2; AirRaid++)
									{
										GetAbsOrigin(targetTrace, BombPos);
										if(AirRaid>0)
										{
											PredictSubjectPositionForProjectiles(npc, targetTrace, 125.0, _,BombPos);
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
									fl_ruina_battery[npc.index]=0.0;
								}
								else fl_ruina_battery[npc.index]+=50.0;
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
				}
				npc.m_flAttackHappens = 0.0;
				npc.m_flNextMeleeAttack = gameTime + (1.2*AttackSpeed);
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + (1.2*AttackSpeed);
			}
		}
	}
	npc.m_iState = 0;
	return 0;
}

static void ResetCastellanWeapon(Castellan npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	switch(weapon_Type)
	{
		case 0:
		{	
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
			SetVariantString("1.25");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntityRenderColor(npc.m_iWearable1, 150, 150, 255, 255);
		}
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 2:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 3:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/taunt_flag/taunt_flag.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		}
		case 4:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/taunts/wupass_mug/wupass_mug.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		}
	}
}


static void WhyNoFactory(int ref)
{
	int entity = EntRefToEntIndex(ref);
	NPC_CreateByName("npc_victoria_factory", -1, {0.0,0.0,0.0}, {0.0,0.0,0.0}, GetTeam(entity), "type-d");
	NPC_CreateByName("npc_victoria_factory", -1, {0.0,0.0,0.0}, {0.0,0.0,0.0}, GetTeam(entity), "type-d");
}

static int CreateSupport_Castellan(int entity, int enemySelect, float SelfPos[3], int WhatBoss, int SetAbility=0)
{
	int SupportTeam;
	char Adddeta[512];
	switch(WhatBoss)
	{
		case 1:
		{
			if(SetAbility)
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", SetAbility);
			else
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", GetRandomInt(1, 2));
			SupportTeam = NPC_CreateByName("npc_atomizer", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		case 2:
		{
			if(SetAbility)
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", SetAbility);
			else
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", GetRandomInt(1, 4));
			FormatEx(Adddeta, sizeof(Adddeta), "%s;override_owner%i", Adddeta, entity);
			SupportTeam = NPC_CreateByName("npc_the_wall", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		case 3:
		{
			if(SetAbility)
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", SetAbility);
			else
				FormatEx(Adddeta, sizeof(Adddeta), "support_ability%i", GetRandomInt(1, 3));
			FormatEx(Adddeta, sizeof(Adddeta), "%s;override_owner%i", Adddeta, entity);
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
		b_ThisEntityIgnoredEntirelyFromAllCollisions[SupportTeam] = true;
		CClotBody npc = view_as<CClotBody>(SupportTeam);
		npc.m_iTarget = enemySelect;
		npc.m_bDissapearOnDeath = true;
		return SupportTeam;
	}
	return 0;
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

static int Castellan_Get_HighDMGType(Castellan npc)
{
	int DMGType;
	float HighDMG;
	float LowDMG;
	for(int i = 0; i <= 2; i++)
	{
		switch(i)
		{
			case 0:	LowDMG=BlastDMG[npc.index];
			case 1:	LowDMG=MagicDMG[npc.index];
			default: LowDMG=BulletDMG[npc.index];
		}
		if(HighDMG)
		{
			if(LowDMG > HighDMG)
			{
				DMGType = i;
				HighDMG = LowDMG;			
			}
		}
		else
		{
			DMGType = i;
			HighDMG = LowDMG;
		}
	}
	return DMGType;
}

static void DefaultAirStrikeTalk(Castellan npc, float gameTime)
{
	switch(npc.m_bAirStrikeTalk)
	{
		case 1:
		{
			if(npc.m_iHealthBar!=2)
			{
				NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability2-3", false, false);
				npc.m_flAttackHappens_2 = gameTime + 1.35;
				npc.m_bAirStrikeTalk = 6;
			}
			else if(npc.m_bHalfRage)
			{
				NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability2-2", false, false);
				npc.m_flAttackHappens_2 = gameTime + 1.35;
				npc.m_bAirStrikeTalk = 3;
			}
			else
			{
				NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability2-1", false, false);
				npc.m_flAttackHappens_2 = gameTime + 1.65;
				npc.m_bAirStrikeTalk = 2;
			}
		}
		case 2:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-7", false);
				npc.m_bAirStrikeTalk=0;
				npc.m_flAttackHappens_2=0.0;
			}
		}
		case 3:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-8", false);
				npc.m_flAttackHappens_2 = gameTime + 0.8;
				npc.m_bAirStrikeTalk=4;
			}
		}
		case 4:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Atomizer", "{blue}", "Atomizer_Talk_Support-3", false);
				npc.m_flAttackHappens_2 = gameTime + 0.6;
				npc.m_bAirStrikeTalk=5;
			}
		}
		case 5:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-9", false);
				npc.m_bAirStrikeTalk=0;
				npc.m_flAttackHappens_2=0.0;
			}
		}
		case 6:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Atomizer", "{blue}", "Atomizer_Talk_Support-4", false);
				npc.m_flAttackHappens_2 = gameTime + 0.8;
				npc.m_bAirStrikeTalk=7;
			}
		}
		case 7:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Huscarls", "{lightblue}", "Huscarls_Talk_Support-10", false);
				npc.m_flAttackHappens_2 = gameTime + 0.8;
				npc.m_bAirStrikeTalk=8;
			}
		}
		case 8:
		{
			if(npc.m_flAttackHappens_2 < gameTime)
			{
				NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-10", false);
				npc.m_bAirStrikeTalk=0;
				npc.m_flAttackHappens_2=0.0;
			}
		}
		default:
		{
			//WTF HOW
			npc.m_bAirStrikeTalk=0;
			npc.m_flAttackHappens_2=0.0;
		}
	}
}

static bool StealthDevice(Castellan npc, bool Activate)
{
	static bool ToggleDevice;
	if(Activate)
	{
		if(!npc.m_flDead_Ringer_Invis_bool)
		{
			ParticleSpawned[npc.index] = false;
			npc.m_iChanged_WalkCycle = -1;
			b_NoHealthbar[npc.index]=3;
			Npc_BossHealthBar(npc);

			SetEntityRenderMode(npc.index, RENDER_NONE);
			SetEntityRenderColor(npc.index, 255, 255, 255, 1);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
			}
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
			if(IsValidEntity(npc.m_iWearable9))
				RemoveEntity(npc.m_iWearable9);
			if(IsValidEntity(npc.m_iTeamGlow))
				RemoveEntity(npc.m_iTeamGlow);
			npc.m_flDead_Ringer_Invis_bool=true;
		}
		if(IsValidEntity(i_InvincibleParticle[npc.index]))
		{
			int particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
			SetEntityRenderMode(particle, RENDER_NONE);
			SetEntityRenderColor(particle, 255, 255, 255, 1);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
		}
		ToggleDevice=true;
		return false;
	}
	else
	{
		if(ToggleDevice)
		{
			b_NoHealthbar[npc.index]=0;
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
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
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
			npc.m_flDead_Ringer_Invis_bool=false;
		}
		ToggleDevice=false;
	}
	return true;
}

static void CastellanAirStrike(Castellan npc, int Target, int Silo, float gameTime)
{
	float AS_Delay, AS_CoolDown;
	int iColor[4];
	switch(Silo)
	{
		case 1:
		{
			AS_CoolDown=3.0;
			AS_Delay=npc.m_flAirStrike_Silo_1;
			SetColorRGBA(iColor, 115, 125, 255, 255);
		}
		case 2:
		{
			AS_CoolDown=2.0;
			AS_Delay=npc.m_flAirStrike_Silo_2;
			SetColorRGBA(iColor, 90, 110, 255, 255);
		}
		case 3:
		{
			AS_CoolDown=1.0;
			AS_Delay=npc.m_flAirStrike_Silo_3;
			SetColorRGBA(iColor, 50, 85, 255, 200);
		}
		default:
		{
			AS_CoolDown=2.5;
			AS_Delay=npc.m_flAirStrike_Silo_1;
			SetColorRGBA(iColor, 115, 125, 255, 255);
		}
	}
	float BombPos[3], TempPos[3];
	GetAbsOrigin(Target, BombPos);
	TempPos[0] = BombPos[0];
	TempPos[1] = BombPos[1];
	TempPos[2] = BombPos[2] + 3000.0;
	BombPos[2] += 5.0;
	TE_SetupBeamPoints(BombPos, TempPos, g_Laser, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, iColor, 3);
	TE_SendToAll();
	TE_SetupGlowSprite(BombPos, g_BluePoint, 0.1, 1.0, 255);
	TE_SendToAll();
	BombPos[2] -= 5.0;
	if(AS_Delay < gameTime)
	{
		float BombDamage = 50.0;
		BombDamage *= RaidModeScaling;
		float Spam_delay=0.0;
		for(int AirRaid; AirRaid < 8; AirRaid++)
		{
			if(AirRaid>4)
			{
				PredictSubjectPositionForProjectiles(npc, Target, 100.0, _,BombPos);
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
		AS_Delay = gameTime + AS_CoolDown;
	}
	switch(Silo)
	{
		case 1:npc.m_flAirStrike_Silo_1=AS_Delay;
		case 2:npc.m_flAirStrike_Silo_2=AS_Delay;
		case 3:npc.m_flAirStrike_Silo_3=AS_Delay;
		default:npc.m_flAirStrike_Silo_1=AS_Delay;
	}
}


static bool Victoria_Support(Castellan npc, int AddNuke, bool Mk2)
{
	float GameTime = GetGameTime(npc.index);
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;

	Vs_DelayTime[npc.index] = GameTime + 0.1;
	float Vs_Raged = (Mk2 ? 1000.0 : 500.0);
	bool Vs_Online=false;
	bool Vs_Fired=false;
	bool Vs_IncomingBoom=false;
	int enemy[3];
	if(AddNuke>1)
		enemy[2] = npc.index;
	if(AddNuke>0)
		enemy[1] = Victoria_GetTargetDistance(npc.index, false, false);
	enemy[0] = Victoria_GetTargetDistance(npc.index, true, false);
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client) && !IsPlayerAlive(client) && TeutonType[client] != TEUTON_NONE)
			Vs_LockOn[client]=false;
	}
	for(int i; i < sizeof(enemy); i++)
	{
		if((AddNuke<2&&i==2) || (AddNuke<1&&i==1))
			continue;
		if(!IsValidEnemy(npc.index, enemy[i]) && i!=2)
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
			spawnRing_Vectors(Vs_Temp_Pos[enemy[i]], (Vs_Raged - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*Vs_Raged)), 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 150, 1, 0.1, 3.0, 0.1, 3);
			float position2[3];
			position2[0] = Vs_Temp_Pos[enemy[i]][0];
			position2[1] = Vs_Temp_Pos[enemy[i]][1];
			position2[2] = Vs_Temp_Pos[enemy[i]][2] + 65.0;
			spawnRing_Vectors(position2, Vs_Raged, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 150, 1, 0.1, 3.0, 0.1, 3);
			spawnRing_Vectors(Vs_Temp_Pos[enemy[i]], Vs_Raged, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 150, 1, 0.1, 3.0, 0.1, 3);
			TE_SetupBeamPoints(Vs_Temp_Pos[enemy[i]], position, g_Laser, -1, 0, 0, 0.1, 0.0, 25.0, 0, 0.0, {145, 47, 47, 150}, 3);
			TE_SendToAll();
			TE_SetupGlowSprite(Vs_Temp_Pos[enemy[i]], g_RedPoint, 0.1, 1.0, 255);
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
			KillFeed_SetKillIcon(npc.index, "megaton");
			Explode_Logic_Custom(100.0*RaidModeScaling, 0, npc.index, -1, position, Vs_Raged/2.0, 1.0, _, true, 20);
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