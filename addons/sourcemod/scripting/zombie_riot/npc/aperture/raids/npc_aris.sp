#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/soldier_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint03.mp3",
};

static const char g_HalfHealthSounds[][] = {
	"vo/mvm/norm/soldier_mvm_robot_see_ghost01.mp3",
	"vo/mvm/norm/soldier_mvm_robot_see_ghost02.mp3",
};

static const char g_SwitchWeaponSounds[][] = {
	"vo/mvm/norm/soldier_mvm_robot10.mp3",
	"vo/mvm/norm/soldier_mvm_robot11.mp3",
	"vo/mvm/norm/soldier_mvm_robot12.mp3",
	"vo/mvm/norm/soldier_mvm_robot15.mp3",
	"vo/mvm/norm/soldier_mvm_robot20.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/shotgun_shoot.wav",
};

static const char g_ShotgunReloadingSounds[][] = {
	")weapons/shotgun_cock_back.wav",
	")weapons/shotgun_cock_forward.wav",
};

static const char g_MalfunctionSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav",
};

static const char g_PassiveSound[][] = {
	"mvm/giant_soldier/giant_soldier_loop.wav",
};

static const char g_MalfunctionParticleAttachments[][] = {
	"head",
	"eye_1",
	"weapon_bone",
	"flag"
};

static const char g_DeployBeaconSound[] = "mvm/sentrybuster/mvm_sentrybuster_intro.wav";

static const char g_RocketFiringSound[] = "weapons/sentry_rocket.wav";
static const char g_RocketLandingSound[] = "weapons/flare_detonator_launch.wav";
static const char g_RocketExplodingSound[] = "ambient/explosions/explode_9.wav";
static const char g_RocketReadyingSound[] = "misc/doomsday_cap_open_start.wav";

static const char g_ShotgunFiringSound[] = ")weapons/tf2_backshot_shotty_crit.wav";

static const char g_SpecialRangedAttackSound[] = "vo/mvm/norm/soldier_incoming01.mp3";

static const char g_SelfLaunchingSound[] = ")weapons/rocket_pack_boosters_fire.wav";

static int i_AirStrikeRocketModelIndex;
static int i_TargetArray[RAIDBOSS_GLOBAL_ATTACKLIMIT];

static bool b_EnemyHitByBlast[MAXENTITIES];
static int i_EnemyHitByThisManyBullets[MAXENTITIES];

#define ARIS_ROCKET_BARRAGE_COOLDOWN_INITIAL 7.0
#define ARIS_ROCKET_BARRAGE_COOLDOWN 13.0

#define ARIS_ROCKET_COUNT_MIN 5								// Takes priority over PER_PLAYER
#define ARIS_ROCKET_COUNT_MAX RAIDBOSS_GLOBAL_ATTACKLIMIT	// Takes priority over PER_PLAYER. If changing, do NOT set it to higher than the global attack limit
#define ARIS_ROCKET_COUNT_PER_PLAYER 2

#define ARIS_ROCKET_INTERVAL 0.2
#define ARIS_ROCKET_DELAY 3.0 				// Delay between visual rocket going up and actual rocket going down
#define ARIS_ROCKET_FLIGHT_TIME 1.5			// How long should it take for a rocket to come from the sky/ceiling onto the target
#define ARIS_ROCKET_BLAST_RADIUS 250.0

#define ARIS_WEAPON_SWITCH_COOLDOWN_INITIAL 15.0
#define ARIS_WEAPON_SWITCH_COOLDOWN 15.0

#define ARIS_WEAPON_SHOOT_COOLDOWN 2.0
#define ARIS_WEAPON_SHOOT_DELAY 0.85 		// Delay between aiming and firing weapon
#define ARIS_WEAPON_SPECIAL_COOLDOWN_INITIAL 6.0
#define ARIS_WEAPON_SPECIAL_COOLDOWN 12.0

#define ARIS_WEAPON_SHOOT_MAX_DISTANCE 400.0
#define ARIS_WEAPON_SPECIAL_MIN_DISTANCE_SQUARED 1048576.0 // 1024.0 squared, checked often

enum
{
	ARIS_MELEE_RESISTANCE,
	ARIS_MELEE_DAMAGE,
	ARIS_MELEE_SPEED,
	
	ARIS_MELEE_COUNT
}

#define ARIS_MALFUNCTION_PARTICLE "ExplosionCore_sapperdestroyed"
#define ARIS_ROCKET_EXPLOSION_PARTICLE "rd_robot_explosion_smoke_linger"
#define ARIS_WEAPON_SHOOT_BLAST_PARTICLE "drg_cow_explosioncore_charged_blue"
#define ARIS_WEAPON_ARMOR_RETURN_PARTICLE "dxhr_lightningball_hit_zap_blue"

void ARIS_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "A.R.I.S.");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aris");
	strcopy(data.Icon, sizeof(data.Icon), "aris");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ShotgunReloadingSounds));   i++) { PrecacheSound(g_ShotgunReloadingSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MalfunctionSounds));   i++) { PrecacheSound(g_MalfunctionSounds[i]);   }
	for (int i = 0; i < (sizeof(g_HalfHealthSounds));   i++) { PrecacheSound(g_HalfHealthSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SwitchWeaponSounds));   i++) { PrecacheSound(g_SwitchWeaponSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	
	PrecacheSoundCustom("#zombiesurvival/aperture/aris.mp3");
	
	PrecacheSound(g_RocketFiringSound);
	PrecacheSound(g_RocketLandingSound);
	PrecacheSound(g_RocketExplodingSound);
	PrecacheSound(g_RocketReadyingSound);
	
	PrecacheSound(g_ShotgunFiringSound);
	PrecacheSound(g_SpecialRangedAttackSound);
	
	PrecacheSound(g_DeployBeaconSound);
	
	PrecacheSound(g_SelfLaunchingSound);
	
	i_AirStrikeRocketModelIndex = PrecacheModel("models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl");
	PrecacheModel("models/bots/soldier/bot_soldier.mdl");
	PrecacheModel("models/workshop/weapons/c_models/c_rr_crossing_sign/c_rr_crossing_sign.mdl");
	PrecacheModel("models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
	PrecacheModel("models/weapons/c_models/c_picket/c_picket.mdl");
	
	PrecacheParticleSystem(ARIS_MALFUNCTION_PARTICLE);
	PrecacheParticleSystem(ARIS_ROCKET_EXPLOSION_PARTICLE);
	PrecacheParticleSystem(ARIS_WEAPON_SHOOT_BLAST_PARTICLE);
	PrecacheParticleSystem(ARIS_WEAPON_ARMOR_RETURN_PARTICLE);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return ARIS(vecPos, vecAng, ally, data);
}
methodmap ARIS < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if (this.m_bLostHalfHealth)
			EmitSoundToAll(g_HalfHealthSounds[GetRandomInt(0, sizeof(g_HalfHealthSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
		else
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayWeaponSwitchSound() 
	{
		EmitSoundToAll(g_SwitchWeaponSounds[GetRandomInt(0, sizeof(g_SwitchWeaponSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlaySpecialRangedAttackSound() 
	{
		EmitSoundToAll(g_SpecialRangedAttackSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	
	public void PlayDeployBeaconSound()
	{
		EmitSoundToAll(g_DeployBeaconSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
	}
	
	public void PlayRocketSound()
	{
		EmitSoundToAll(g_RocketFiringSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.6, 80);
	}
	
	public void PlayRocketLandingSound(int entity)
	{
		EmitSoundToAll(g_RocketLandingSound, entity, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, _, 47, .soundtime = GetGameTime() - 0.12);
	}
	
	public void PlayRocketReadyingSound()
	{
		EmitSoundToAll(g_RocketReadyingSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void StopRocketReadyingSound()
	{
		StopSound(this.index, SNDCHAN_AUTO, g_RocketReadyingSound);
	}
	
	public void PlayShotgunSound()
	{
		// This is quiet for some reason
		EmitSoundToAll(g_ShotgunFiringSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
		EmitSoundToAll(g_ShotgunFiringSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	
	public void PlayShotgunReloadingSound()
	{
		EmitSoundToAll(g_ShotgunReloadingSounds[0], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
		CreateTimer(0.4, Timer_ARIS_PlaySecondReloadingSound, this.index, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	public void PlayMalfunctionEffect()
	{
		EmitSoundToAll(g_MalfunctionSounds[GetURandomInt() % sizeof(g_MalfunctionSounds)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(85, 95));
		
		int index = GetURandomInt() % sizeof(g_MalfunctionParticleAttachments);
		
		float vecPos[3], vecAng[3];
		int attachment = this.GetAttachment(g_MalfunctionParticleAttachments[index], vecPos, vecAng);
		
		if (attachment)
		{
			int particle = ParticleEffectAt_Parent(vecPos, ARIS_MALFUNCTION_PARTICLE, this.index, g_MalfunctionParticleAttachments[index]);
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}
			
	}
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	
	public void PlaySelfLaunchingSound()
	{
		EmitSoundToAll(g_SelfLaunchingSound, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void StopSelfLaunchingSound()
	{
		StopSound(this.index, SNDCHAN_AUTO, g_SelfLaunchingSound);
	}
	
	property float m_flNextRocketBarrageMain
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextRocketBarrageStart
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property float m_flNextRocket
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	
	property int m_iRocketsLoaded
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	
	property int m_iTargetArrayIndex
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextWeaponSwitch
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextSpecialRangedAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	property bool m_bDoingSpecialRangedAttack
	{
		public get()							{ return b_RangedSpecialOn[this.index]; }
		public set(bool TempValueForProperty) 	{ b_RangedSpecialOn[this.index] = TempValueForProperty; }
	}
	
	property bool m_bDoingRangedAttack
	{
		public get()							{ return b_movedelay_gun[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_gun[this.index] = TempValueForProperty; }
	}
	
	property bool m_bInFlightFromRangedAttack
	{
		public get()							{ return b_DuringHighFlight[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DuringHighFlight[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextMalfunctionEffect
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	
	property int m_iCurrentMelee
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	
	property int m_iForcedWeaponSwitchHealthThreshold
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	property int m_iLastBeaconRef
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	
	property int m_iDeathState
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextDeathState
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	property float m_flLastDeathHeight
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	property bool m_bHasCalculatedHealthThreshold
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	
	public ARIS(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ARIS npc = view_as<ARIS>(CClotBody(vecPos, vecAng, "models/bots/soldier/bot_soldier.mdl", "1.45", "700", ally, false, true, true, true));
		float gameTime = GetGameTime(npc.index);
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		func_NPCDeath[npc.index] = ARIS_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ARIS_OnTakeDamage;
		func_NPCThink[npc.index] = ARIS_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);

		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);

		npc.PlayPassiveSound();
		
		RaidModeTime = GetGameTime() + 220.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "A.R.I.S. arrives");
			}
		}
		
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

		RaidModeScaling *= 0.75;
		RaidModeScaling *= 1.19;
		//scaling old

		npc.m_flMeleeArmor = 1.25;	
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/aris.mp3");
		music.Time = 167;
		music.Volume = 1.25;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "I Saw a Deer Today (SilvaGunner)");
		strcopy(music.Artist, sizeof(music.Artist), "Mike Morasky");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_flNextRocketBarrageStart = gameTime + ARIS_ROCKET_BARRAGE_COOLDOWN_INITIAL;
		npc.m_flNextRocketBarrageMain = FAR_FUTURE;
		npc.m_flNextWeaponSwitch = gameTime + ARIS_WEAPON_SWITCH_COOLDOWN_INITIAL;
		npc.Anger = false;
		npc.m_fbGunout = false;
		npc.m_iChanged_WalkCycle = 0;
		ARIS_RefreshAnimation(npc, true);
		
		npc.m_flNextRocket = FAR_FUTURE;
		npc.m_iRocketsLoaded = 0;
		
		npc.m_flNextMalfunctionEffect = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_flSpeed = 300.0;
		npc.m_bDissapearOnDeath = true;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();

		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 4R1S ㄷㅐㄱㅣ 중.");
			case 1:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 4R1S = 출동 ㅈㅜㄴㅂㅣ 완료");
			case 2:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 활ㅅㅓㅇ화, 진압 ㅅㅣ작");
		}

		return npc;
	}
}

public void ARIS_ClotThink(int iNPC)
{
	ARIS npc = view_as<ARIS>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	if (ARIS_LoseConditions(iNPC))
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if (npc.m_bLostHalfHealth && npc.m_flNextMalfunctionEffect < gameTime)
	{
		npc.m_flNextMalfunctionEffect = gameTime + 3.0;
		npc.PlayMalfunctionEffect();
	}
	
	ARIS_RefreshAnimation(npc);
	
	if (!npc.m_bHasCalculatedHealthThreshold)
	{
		npc.m_bHasCalculatedHealthThreshold = true;
		ARIS_SetNextForcedWeaponSwitchThreshold(npc);
	}
	
	// If we're flying from our blast, hurt people in the way
	if (npc.IsOnGround())
	{
		if (npc.m_bInFlightFromRangedAttack)
		{
			// We just landed from a shotgun blast, force a retarget
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			
			npc.m_bInFlightFromRangedAttack = false;
			
			// Delay the next attack a little to give us the chance to adapt to the new target
			if (npc.m_fbGunout)
			{
				npc.m_flNextRangedAttack = fmax(npc.m_flNextRangedAttack, gameTime + 1.25);
				npc.m_flNextWeaponSwitch += 1.25;
			}
		}
	}
	else if (npc.m_bInFlightFromRangedAttack)
	{
		float damage = 10.0;
		damage *= RaidModeScaling;
		KillFeed_SetKillIcon(npc.index, "mantreads");
		ResolvePlayerCollisions_Npc(npc.index, damage, true);
	}
	
	if (npc.m_bLostHalfHealth || !npc.m_fbGunout)
	{
		// ROCKET BARRAGE: Fires rockets upwards in quick succession, disappearing when they hit the sky/ceiling/whatever.
		// Then come down at an angle downwards towards the players. We don't need a target for this.
		if (npc.m_flNextRocketBarrageStart < gameTime)
		{
			// This is just the warning
			npc.m_flNextRocketBarrageMain = gameTime + 2.0;
			npc.m_flNextRocketBarrageStart = FAR_FUTURE; // Need to wait until it's done
		
			switch(GetRandomInt(0,2))
			{
				case 0:
					CPrintToChatAll("{rare}A.R.I.S.{default}: ㅅㅜ류탄 ㅌㅜ척!");
				case 1:
					CPrintToChatAll("{rare}A.R.I.S.{default}: 엄ㅍㅖ하ㄹㅏ!");
				case 2:
					CPrintToChatAll("{rare}A.R.I.S.{default}: 로ㅋㅔㅅ!");
			}
			npc.PlayRocketReadyingSound();
		}
		
		if (npc.m_flNextRocketBarrageMain < gameTime)
		{
			// Actual ability starts here
			ARIS_CalculateRocketAmount(npc);
			npc.m_flNextRocket = gameTime;
			npc.m_flNextRocketBarrageMain = FAR_FUTURE; // Don't need this anymore
			
			npc.StopRocketReadyingSound();
		}
		
		if (npc.m_flNextRocket <= gameTime)
		{
			if (npc.m_iRocketsLoaded > 0)
			{
				ARIS_FireRocketUpwards(npc);
				npc.m_flNextRocket = gameTime + ARIS_ROCKET_INTERVAL;
				npc.m_iRocketsLoaded--;
			}
			else
			{
				npc.m_flNextRocket = FAR_FUTURE;
				npc.m_flNextRocketBarrageStart = gameTime + ARIS_ROCKET_BARRAGE_COOLDOWN + ARIS_ROCKET_DELAY + ARIS_ROCKET_FLIGHT_TIME;
			}
		}
	}
	
	if (npc.m_flNextWeaponSwitch < gameTime && !npc.m_bDoingRangedAttack)
	{
		npc.PlayWeaponSwitchSound();
		ARIS_ToggleWeapon(npc);
	}
	
	int target = npc.m_iTarget;
	if (IsValidEnemy(npc.index, target))
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(target, vecTargetPos);
		
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
		
		// GUN: Shoot gun. Deals high knockback to players and ourselves. Should probably do something else besides damage.
		// This is in 2 different places in logic: here and self-defense. Some "special" logic is placed here.
		// If our target is too far away, we knock ourselves towards them
		if (npc.m_fbGunout)
		{
			if (npc.m_flNextRangedAttack < gameTime)
			{
				if (npc.m_flNextSpecialRangedAttack < gameTime)
				{
					if (distance > ARIS_WEAPON_SPECIAL_MIN_DISTANCE_SQUARED && Can_I_See_Enemy(npc.index, target))
					{
						if (ARIS_AttemptToShoot(npc, vecPos, vecTargetPos, true))
						{
							npc.PlaySpecialRangedAttackSound();
							return;
						}
					}
				}
				
				if (npc.m_bDoingRangedAttack)
				{
					ARIS_ShootGun(npc);
					return;
				}
			}
			
			if (npc.m_bDoingRangedAttack)
			{
				if (npc.m_bDoingSpecialRangedAttack)
					return;
				
				if (!NpcStats_IsEnemySilenced(npc.index)) // If we're silenced, we don't turn at all
					npc.FaceTowards(vecTargetPos, 400.0);
			}
			else
			{
				npc.FaceTowards(vecTargetPos, 700.0);
			}
		}
		
		// Predict their pos when not loading our gun
		if (!npc.m_bDoingRangedAttack && distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}
		
		ARIS_SelfDefense(npc, gameTime, target, distance);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void ARIS_SelfDefense(ARIS npc, float gameTime, int target, float distance)
{
	if (npc.m_fbGunout)
	{
		// Aiming self-defense logic is in ARIS.AttemptToShoot(), and actual shooting in ARIS.ShootGun()
		if (distance < (ARIS_WEAPON_SHOOT_MAX_DISTANCE * ARIS_WEAPON_SHOOT_MAX_DISTANCE) * 0.5 && npc.m_flNextRangedAttack < gameTime)
		{
			float vecPos[3], vecTargetPos[3];
			WorldSpaceCenter(npc.index, vecPos);
			WorldSpaceCenter(target, vecTargetPos);
			ARIS_AttemptToShoot(npc, vecPos, vecTargetPos);
		}
		
		return;
	}
	
	if (npc.m_flAttackHappens && npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		npc.m_flAttackHappens = 0.0;
		
		if(IsValidEnemy(npc.index, target))
		{
			int HowManyEnemeisAoeMelee = 64;
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
			delete swingTrace;
			bool PlaySound = false;
			float damage = 35.0;
			damage *= RaidModeScaling;
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
			
			char killicon[64];
			switch (npc.m_iCurrentMelee)
			{
				case ARIS_MELEE_RESISTANCE: killicon = "freedom_staff";
				case ARIS_MELEE_DAMAGE: killicon = "crossing_guard";
				case ARIS_MELEE_SPEED: killicon = "nonnonviolent_protest";
				default: killicon = "fists";
			}
			
			KillFeed_SetKillIcon(npc.index, killicon);
			
			for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
			{
				if(i_EntitiesHitAoeSwing_NpcSwing[counter] <= 0)
					continue;
				if(!IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
					continue;

				int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
				float vecHit[3];
				
				WorldSpaceCenter(targetTrace, vecHit);

				SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);

				bool Knocked = false;
				if(!PlaySound)
				{
					PlaySound = true;
				}
				
				if(IsValidClient(targetTrace))
				{
					if (IsInvuln(targetTrace))
					{
						Knocked = true;
						Custom_Knockback(npc.index, targetTrace, 180.0, true);
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
					else
					{
						if(!silenced)
						{
							TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
							TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
						}
					}
				}			
				if(!Knocked)
					Custom_Knockback(npc.index, targetTrace, 450.0, true); 
			}
			if(PlaySound)
			{
				npc.PlayMeleeHitSound();
			}
		}
	}

	if (gameTime > npc.m_flNextMeleeAttack)
	{
		if (distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				npc.m_flAttackHappens = gameTime + 0.2;
				float attack = 1.0;
				npc.m_flNextMeleeAttack = gameTime + attack;
				return;
			}
		}
	}
}

public Action ARIS_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ARIS npc = view_as<ARIS>(victim);
	
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	if (RoundToCeil(damage) >= health)
	{
		ARIS_DestroyDroppedBeacon(npc);
		ARIS_ClearAllProjectiles(npc);
		
		if (Aperture_ShouldDoLastStand())
		{
			// We're in Laboratories, the boss' think/death functions will be hijacked
			npc.StopPassiveSound();
			npc.m_iState = APERTURE_BOSS_ARIS; // This will store the boss's "type"
			Aperture_Shared_LastStandSequence_Starting(view_as<CClotBody>(npc));
		}
		else if (!npc.m_flNextDeathState)
		{
			// We're not in Laboratories, don't die immediately, we do an animation first
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			ApplyStatusEffect(npc.index, npc.index, "Infinite Will", 99999.0);
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 99999.0);
			
			npc.m_flNextDeathState = 1.0;
			
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
		}
		
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if (!npc.m_bLostHalfHealth && (ReturnEntityMaxHealth(npc.index) / 2) >= health)
		npc.m_bLostHalfHealth = true;
	
	// Force a weapon switch if we took too much damage while holding our melee and have no armor
	if (!npc.m_fbGunout && npc.m_flArmorCount <= 0.0 && npc.m_iForcedWeaponSwitchHealthThreshold >= health + damage)
		npc.m_flNextWeaponSwitch = GetGameTime(npc.index);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ARIS_NPCDeath(int entity)
{
	ARIS npc = view_as<ARIS>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	npc.StopPassiveSound();
}

static void ARIS_CalculateRocketAmount(ARIS npc)
{
	int playerCount = CountPlayersOnRed(0); // 0 = includes teutons and downed players
	int rocketCount = playerCount * ARIS_ROCKET_COUNT_PER_PLAYER;
	
	// no int clamp unlucky
	if (rocketCount < ARIS_ROCKET_COUNT_MIN)
		rocketCount = ARIS_ROCKET_COUNT_MIN;
	else if (rocketCount > ARIS_ROCKET_COUNT_MAX)
		rocketCount = ARIS_ROCKET_COUNT_MAX;
	
	ARIS_EmptyGlobalTargetArray(rocketCount);
	npc.m_iTargetArrayIndex = 0;
	GetHighDefTargets(view_as<UnderTides>(npc.index), i_TargetArray, sizeof(i_TargetArray), false, 1);
	ARIS_LoopGlobalTargetArray(rocketCount);
	
	npc.m_iRocketsLoaded = rocketCount;
}

static void ARIS_FireRocketUpwards(ARIS npc)
{
	// Firing a fake rocket upwards. If it hits a ceiling or wall, no biggie, the excuse is they merge into the walls or some shit idk
	float vecPos[3];
	WorldSpaceCenter(npc.index, vecPos);
	vecPos[0] += GetRandomFloat(-300.0, 300.0);
	vecPos[1] += GetRandomFloat(-300.0, 300.0);
	vecPos[2] += 4000.0;
	
	// We use a particle rocket for better manipulation
	int rocket = npc.FireParticleRocket(vecPos, 0.0, 800.0, 0.0, "rockettrail");
	ARIS_MakeParticleRocketSuitable(rocket, true);
	
	npc.PlayRocketSound();
	
	// Each rocket will create a real rocket a bit later
	CreateTimer(ARIS_ROCKET_DELAY, Timer_ARIS_FireRocketTowardsPlayer, npc.index, TIMER_FLAG_NO_MAPCHANGE);
}

static void ARIS_FireRocketTowardsPlayer(ARIS npc)
{
	int enemy = i_TargetArray[npc.m_iTargetArrayIndex++];
	if (npc.m_iTargetArrayIndex == sizeof(i_TargetArray))
	{
		// Huh. Technically this means the attack is over, but doing this just in case
		npc.m_iTargetArrayIndex = 0;
	}
	
	// We only target players who might not exist anymore
	if (enemy <= 0 || enemy > MaxClients || !IsClientInGame(enemy) || !IsValidEnemy(npc.index, enemy))
		return;
	
	float vecPos[3], vecTargetPos[3], vecTraceAng[3], vecForward[3];
	GetAbsOrigin(enemy, vecTargetPos);
	vecTraceAng[0] = GetRandomFloat(-88.0, -80.0);
	vecTraceAng[1] = GetRandomFloat(-180.0, 180.0);
	
	vecTargetPos[2] += 3.0;
	
	Handle trace;
	trace = TR_TraceRayFilterEx(vecTargetPos, vecTraceAng, (MASK_SOLID | CONTENTS_SOLID), RayType_Infinite, BulletAndMeleeTrace, enemy);
	TR_GetEndPosition(vecPos, trace);
	
	if (TR_GetSurfaceFlags() & SURF_SKY == 0)
	{
		// We didn't hit the sky, but that's fine. I don't do anything here, but if you want to add some lines about rockets coming from walls/ceilings, here's where you do it
	}
	
	delete trace;
	
	// Push the end position 24 units off the surface
	ScaleVector(vecTraceAng, -1.0);
	GetAngleVectors(vecTraceAng, vecForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vecForward, vecForward);
	ScaleVector(vecForward, 24.0);
	AddVectors(vecPos, vecForward, vecPos);
	
	// Tracing the rest of the way to ensure we hit the floor or a wall or something (in case the target is midair)
	trace = TR_TraceRayFilterEx(vecTargetPos, vecTraceAng, (MASK_SOLID | CONTENTS_SOLID), RayType_Infinite, BulletAndMeleeTrace, enemy);
	TR_GetEndPosition(vecTargetPos, trace);
	
	delete trace;
	
	vecTargetPos[2] += 3.0;
	
	float distance = GetVectorDistance(vecPos, vecTargetPos);
	float speed = distance / ARIS_ROCKET_FLIGHT_TIME;
	
	int rocket = npc.FireParticleRocket(vecTargetPos, 0.0, speed, 0.0, "rockettrail", .Override_Spawn_Loc = true, .Override_VEC = vecPos);
	ARIS_MakeParticleRocketSuitable(rocket, false);
	
	float radius = ARIS_ROCKET_BLAST_RADIUS * 2.0;
	spawnRing_Vectors(vecTargetPos, radius, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 104, 207, 255, 255, 1, ARIS_ROCKET_FLIGHT_TIME, 1.0, 0.1, 1, 0.0);
	spawnRing_Vectors(vecTargetPos, radius, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 220, 255, 1, ARIS_ROCKET_FLIGHT_TIME + 0.3, 1.0, 0.1, 1);
	
	npc.PlayRocketLandingSound(rocket);
}

static void ARIS_DestroyDroppedBeacon(ARIS npc)
{
	if (npc.m_iLastBeaconRef)
	{
		int entity = EntRefToEntIndex(npc.m_iLastBeaconRef);
		if (entity != INVALID_ENT_REFERENCE)
			RequestFrame(KillNpc, entity);
	}
}

static void ARIS_ToggleWeapon(ARIS npc)
{
	float gameTime = GetGameTime(npc.index);
	
	npc.m_fbGunout = !npc.m_fbGunout;
	if (npc.m_fbGunout)
	{
		npc.m_flNextRangedAttack = gameTime + (ARIS_WEAPON_SHOOT_COOLDOWN / 1.7);
		npc.m_bDoingRangedAttack = false;
		npc.m_flNextSpecialRangedAttack = gameTime + ARIS_WEAPON_SPECIAL_COOLDOWN_INITIAL;
		npc.m_bDoingSpecialRangedAttack = false;
		
		ARIS_DropMelee(npc);
		npc.m_iCurrentMelee++;
		npc.m_iCurrentMelee = npc.m_iCurrentMelee % ARIS_MELEE_COUNT;
		
		npc.m_bAllowBackWalking = true;
		
		ARIS_SetNextForcedWeaponSwitchThreshold(npc);
	}
	else
	{
		npc.m_bAllowBackWalking = false;
		
		if (!npc.m_bLostHalfHealth)
			npc.m_flNextRocketBarrageStart = fmax(npc.m_flNextRocketBarrageStart, gameTime + 6.0);
	}
	
	npc.m_flNextWeaponSwitch = gameTime + ARIS_WEAPON_SWITCH_COOLDOWN;
	
	ARIS_RefreshAnimation(npc);
}

static void ARIS_RefreshAnimation(ARIS npc, bool forceRefreshWeapon = false)
{
	int oldCycle = npc.m_iChanged_WalkCycle;
	int newCycle;
	
	if (!npc.m_fbGunout)
		newCycle = npc.IsOnGround() ? 0 : 1;
	else
		newCycle = npc.IsOnGround() ? 2 : 3;
	
	if (!forceRefreshWeapon && oldCycle == newCycle)
		return;
	
	// 0 and 1 / 2 = 0, melee out
	// 2 and 3 / 2 = 1, shotgun out
	int weaponId = newCycle / 2;
	bool changeWeapon = oldCycle / 2 != newCycle / 2;
	
	if (changeWeapon || forceRefreshWeapon)
	{
		if (IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		switch (weaponId)
		{
			case 0:
			{
				char model[128];
				switch (npc.m_iCurrentMelee)
				{
					case ARIS_MELEE_RESISTANCE: model = "models/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl";
					case ARIS_MELEE_DAMAGE: model = "models/workshop/weapons/c_models/c_rr_crossing_sign/c_rr_crossing_sign.mdl";
					case ARIS_MELEE_SPEED: model = "models/weapons/c_models/c_picket/c_picket.mdl";
				}
				
				npc.m_iWearable1 = npc.EquipItem("head", model);
				SetVariantString("1.1");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			
			case 1:
			{
				npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_shotgun/c_shotgun.mdl");
				SetVariantString("3.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}	
		}
	}
	
	int activity;
	switch (newCycle)
	{
		case 0:
		{
			npc.m_bisWalking = true;
			activity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		}
		
		case 1:
		{
			npc.m_bisWalking = false;
			activity = npc.LookupActivity("ACT_MP_AIRWALK_MELEE_ALLCLASS");
		}
		
		case 2:
		{
			npc.m_bisWalking = true;
			activity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		}
		
		case 3:
		{
			npc.m_bisWalking = false;
			activity = npc.LookupActivity("ACT_MP_AIRWALK_SECONDARY");
		}
	}
	
	if (activity > 0)
		npc.StartActivity(activity);
	
	npc.m_iChanged_WalkCycle = newCycle;
}

static void ARIS_DropMelee(ARIS npc)
{
	float vecPos[3], vecAng[3], vecTargetPos[3];
	GetAbsOrigin(npc.index, vecPos);
	GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecAng);
	
	Handle trace = TR_TraceRayFilterEx(vecPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_SOLID, RayType_Infinite, TraceEntityFilter_ARIS_OnlyWorld);
	TR_GetEndPosition(vecTargetPos, trace);
	delete trace;
	
	char data[64];
	switch (npc.m_iCurrentMelee)
	{
		case ARIS_MELEE_RESISTANCE: data = "resistance";
		case ARIS_MELEE_DAMAGE: data = "damage";
		case ARIS_MELEE_SPEED: data = "speed";
	}
	
	// This model is a bit too down low, let's raise it up
	if (npc.m_iCurrentMelee == ARIS_MELEE_RESISTANCE)
		vecTargetPos[2] += 50.0;
	
	ARIS_DestroyDroppedBeacon(npc);
	
	int npcSpawn = NPC_CreateByName("npc_aris_makeshift_beacon", -1, vecTargetPos, vecAng, GetTeam(npc.index), data);
	npc.m_iLastBeaconRef = EntIndexToEntRef(npcSpawn);
	
	npc.PlayDeployBeaconSound();

	if(npc.m_iCurrentMelee == ARIS_MELEE_RESISTANCE)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 방어를 ㄷㅓ 증강ㅎㅐ야한다");
			case 1:
				CPrintToChatAll("{rare}A.R.I.S.{default}: ㅈㅓ항력 보강 필요");
			case 2:
				CPrintToChatAll("{rare}A.R.I.S.{default}: ㅂㅏㅇ어장 작동!");
		}
	}
	if(npc.m_iCurrentMelee == ARIS_MELEE_DAMAGE)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 자가 ㄱㅏㅇ화 시작");
			case 1:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 공격력 증강ㄱㅣ ㄱㅏ동중");
			case 2:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 공격ㄹㅕㄱ : 강ㅎㅗㅏ");
		}
	}
	if(npc.m_iCurrentMelee == ARIS_MELEE_SPEED)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 가ㅅㅗㄱ기 ㄱㅏ동중");
			case 1:
				CPrintToChatAll("{rare}A.R.I.S.{default}: ㅎㅏ늘로 돌ㅇㅏ왔다");
			case 2:
				CPrintToChatAll("{rare}A.R.I.S.{default}: 공ㄱㅣ역학 분산 ㄱㅏ동");
		}
	}
}

static bool ARIS_AttemptToShoot(ARIS npc, float vecPos[3], float vecTargetPos[3], bool oppositeDirectionOfTarget = false)
{
	// Why would we be here if we got no gun?
	if (!npc.m_fbGunout)
		return false;
	
	// ???? where the fuck are we looking at
	if (!GetVectorLength(vecTargetPos, true))
		return false;
	
	if (!npc.IsOnGround())
		return false;
	
	float vecAng[3], vecForward[3];
	
	if (oppositeDirectionOfTarget)
		GetVectorAnglesTwoPoints(vecTargetPos, vecPos, vecAng);
	else
		GetVectorAnglesTwoPoints(vecPos, vecTargetPos, vecAng);
	
	GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vecForward, vecForward);
	ScaleVector(vecForward, ARIS_WEAPON_SHOOT_MAX_DISTANCE);
	AddVectors(vecPos, vecForward, vecTargetPos);
	
	if (oppositeDirectionOfTarget)
	{
		npc.m_bDoingSpecialRangedAttack = true;
		npc.m_flNextSpecialRangedAttack = FAR_FUTURE; // Will be reset when the shot is done
			
		// We need to stop IMMEDIATELY
		npc.m_flSpeed = 0.0;
		npc.StopPathing();
		npc.FaceTowards(vecTargetPos, 20000.0);
	}
	else
	{
		if (npc.m_iTarget > 0)
		{
			float vecBuffer[3];
			WorldSpaceCenter(npc.m_iTarget, vecBuffer);
		}
		
		npc.m_flSpeed = 50.0;
	}
	
	npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
	
	npc.m_bDoingRangedAttack = true;
	npc.m_flNextRangedAttack = GetGameTime(npc.index) + ARIS_WEAPON_SHOOT_DELAY;
	
	npc.PlayShotgunReloadingSound();
	
	return true;
}

public void ARIS_ShootGun(ARIS npc)
{
	// Why would we be here if we got no gun?
	if (!npc.m_fbGunout)
		return;
	
	float vecPos[3], vecTargetPos[3], vecAng[3], vecForward[3], vecBarrelPos[3];
	float vecBuffer[3];
	
	npc.GetAttachment("weapon_bone_1", vecBarrelPos, vecAng);
	ParticleEffectAtWithRotation(vecBarrelPos, vecAng, ARIS_WEAPON_SHOOT_BLAST_PARTICLE);
	
	GetAbsOrigin(npc.index, vecPos);
	GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecAng);
	
	if (!npc.m_bDoingSpecialRangedAttack && npc.m_iTarget > 0)
	{
		GetAbsOrigin(npc.m_iTarget, vecBuffer);
		GetVectorAnglesTwoPoints(vecPos, vecBuffer, vecBuffer);
		vecAng[0] = vecBuffer[0];
	}
	
	// If there's not much difference between heights, we'll treat them as the same
	// FIXME: This doesn't work!
	GetAbsOrigin(npc.m_iTarget, vecBuffer);
	float difference = fabs(vecPos[2] - vecBuffer[2]);
	if (difference < 75.0 / 1.3)
		vecTargetPos[2] = vecBuffer[2];
	
	GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vecForward, vecForward);
	ScaleVector(vecForward, ARIS_WEAPON_SHOOT_MAX_DISTANCE - 35.0);
	AddVectors(vecPos, vecForward, vecTargetPos);
	
	int color[4] = { 104, 207, 255, 255 };
	
	KillFeed_SetKillIcon(npc.index, "pomson");
	
	// Our targetting method is a little different, so we can't use DoSwingTrace
	// Bullets
	for (int i = 0; i < 5; i++)
	{
		for (int j = 0; j < 5; j++)
		{
			vecBuffer = vecAng;
			vecBuffer[0] += -15.0 + (i * 7.5);
			vecBuffer[1] += -15.0 + (j * 7.5);
			
			GetAngleVectors(vecBuffer, vecForward, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vecForward, vecForward);
			ScaleVector(vecForward, ARIS_WEAPON_SHOOT_MAX_DISTANCE);
			AddVectors(vecBarrelPos, vecForward, vecBuffer);
			
			Handle trace = TR_TraceRayFilterEx(vecBarrelPos, vecBuffer, (MASK_SOLID | CONTENTS_SOLID), RayType_EndPoint, TraceFilter_ARIS_ShotgunBullet, npc.index);
			TR_GetEndPosition(vecBuffer, trace);
			delete trace;
			
			TE_SetupBeamPoints(vecBarrelPos, vecBuffer, Shared_BEAM_Laser, 0, 0, 0, 0.1, 1.0, 1.0, 30, 0.0, color, 0);
			TE_SendToAll();
			
			for (int k = 1; k < MAXENTITIES; k++)
			{
				if (i_EntitiesHitAoeSwing_NpcSwing[k] == npc.index)
				{
					i_EnemyHitByThisManyBullets[k]++;
					i_EntitiesHitAoeSwing_NpcSwing[k] = INVALID_ENT_REFERENCE;
				}
			}
		}
	}
	
	// Blast
	float vecMins[3] = { -85.0, -85.0, 0.0 };
	float vecMaxs[3] = { 85.0, 85.0, 160.0 };
	
	// I have no idea what these flags are, but it's what DoSwingTrace uses for aoe attacks
	Handle trace = TR_TraceHullFilterEx(vecPos, vecPos, vecMins, vecMaxs, 1073741824, TraceFilter_ARIS_ShotgunBlast, npc.index);
	delete trace;
	
	float finalArmor;
	int finalTarget;
	
	for (int target = 1; target < MAXENTITIES; target++)
	{
		float damage;
		float armorFromThisTarget;
		
		int bullets = i_EnemyHitByThisManyBullets[target];
		if (bullets)
		{
			damage += 10.0 + (5.0 + (bullets - 1));
			armorFromThisTarget += bullets * 0.006;
			i_EnemyHitByThisManyBullets[target] = 0;
		}
		
		int blast = b_EnemyHitByBlast[target];
		if (blast)
		{
			damage += 25.0;
			Custom_Knockback(npc.index, target, 1200.0);
			armorFromThisTarget += 0.012;
			b_EnemyHitByBlast[target] = false;
		}
		damage *= 6.0;
		damage *= RaidModeScaling;
		
		if (damage > 0.0)
		{
			SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_BULLET, -1);
			
			if (target > MaxClients)
				armorFromThisTarget *= 0.2;
			
			if (armorFromThisTarget > finalArmor)
			{
				finalTarget = target;
				finalArmor = armorFromThisTarget;
			}
		}
	}
	
	// Only gain armor from the enemy that was hit the hardest
	if (finalTarget && finalArmor > 0.0)
	{
		finalArmor *= NpcDoHealthRegenScaling(npc.index);
		GrantEntityArmor(npc.index, false, 1.0, 0.5, 0, ReturnEntityMaxHealth(npc.index) * finalArmor);
		
		if (IsValidEntity(npc.m_iWearable1))
		{
			float vecBufferAng[3];
			WorldSpaceCenter(finalTarget, vecBuffer);
			
			GetVectorAnglesTwoPoints(vecBuffer, vecBarrelPos, vecBufferAng);
			int particle = ParticleEffectAtWithRotation(vecBuffer, vecBufferAng, ARIS_WEAPON_ARMOR_RETURN_PARTICLE, 0.3);
			
			// Array netprop, but we only need element 0 anyway
			SetEntPropEnt(particle, Prop_Send, "m_hControlPointEnts", npc.m_iWearable1, 0);
			SetEntProp(particle, Prop_Send, "m_iControlPointParents", npc.m_iWearable1, _, 0);
			CreateMediArmorBeam(finalTarget, npc.index);
		}
	}	
	
	// Launching ourselves backwards. We don't care if we're being blocked
	GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecAng);
	vecAng[0] = 27.5;
	GetAngleVectors(vecAng, vecForward, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(vecForward, vecForward);
	ScaleVector(vecForward, npc.m_bDoingSpecialRangedAttack ? -600.0 : -350.0);
	
	AddVectors(vecPos, vecForward, vecBuffer);
	PluginBot_Jump(npc.index, vecBuffer, 9000.0);
	
	if (npc.m_bDoingSpecialRangedAttack)
	{
		npc.m_flNextSpecialRangedAttack = GetGameTime(npc.index) + ARIS_WEAPON_SPECIAL_COOLDOWN;
		npc.m_bDoingSpecialRangedAttack = false;
	}
	
	npc.m_flNextRangedAttack = GetGameTime() + ARIS_WEAPON_SHOOT_COOLDOWN;
	npc.m_bDoingRangedAttack = false;
	
	npc.m_flNextWeaponSwitch = fmax(npc.m_flNextWeaponSwitch, GetGameTime(npc.index) + 1.0);
	
	npc.m_bInFlightFromRangedAttack = true;
	
	npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
	npc.PlayShotgunSound();
	
	npc.m_flSpeed = 300.0;
	npc.StartPathing();
}

static void ARIS_MakeParticleRocketSuitable(int entity, bool fake)
{
	SetEntityCollisionGroup(entity, COLLISION_GROUP_DEBRIS);
	SDKUnhook(entity, SDKHook_StartTouch, Rocket_Particle_StartTouch);
	
	if (fake)
		SDKHook(entity, SDKHook_StartTouch, ARIS_Fake_Rocket_Particle_StartTouch);
	else
		SDKHook(entity, SDKHook_StartTouch, ARIS_Real_Rocket_Particle_StartTouch);
	
	// We want to actually see it
	SetEntityRenderColor(entity);
	SetEntityRenderMode(entity, RENDER_NORMAL);
	
	for (int i = 0; i < 4; i++) //This will make it so it doesnt override its collision box.
		SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", i_AirStrikeRocketModelIndex, _, i);
}

static void ARIS_Fake_Rocket_Particle_StartTouch(int entity, int target)
{
	if (target == 0 || target >= MAXENTITIES)
		RemoveEntity(entity);
}

static void ARIS_Real_Rocket_Particle_StartTouch(int entity, int target)
{
	if (target == 0 || target >= MAXENTITIES)
	{
		float vecPos[3];
		GetAbsOrigin(entity, vecPos);
		ParticleEffectAt(vecPos, ARIS_ROCKET_EXPLOSION_PARTICLE);
		
		StopSound(entity, SNDCHAN_AUTO, g_RocketLandingSound);
		EmitSoundToAll(g_RocketExplodingSound, entity, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL);
		
		float radius = ARIS_ROCKET_BLAST_RADIUS * 3.0;
		spawnRing_Vectors(vecPos, 1.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 104, 207, 255, 255, 1, 0.5, 1.0, 0.1, 1, radius);
		
		CreateEarthquake(vecPos, 1.2, radius, 14.0, 230.0);
		
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (owner > MaxClients && !b_NpcHasDied[owner])
		{
			// Let's just ASSUME this is ARIS
			float damage = 100.0;
			
			if (IsValidEntity(RaidBossActive))
				damage *= RaidModeScaling;
			
			KillFeed_SetKillIcon(owner, "tf_projectile_rocket");
			
			Explode_Logic_Custom(damage, owner, entity, -1, vecPos, ARIS_ROCKET_BLAST_RADIUS);
		}
		
		RemoveEntity(entity);
	}
}

static void ARIS_EmptyGlobalTargetArray(int count)
{
	for (int i = 0; i < count; i++)
		i_TargetArray[i] = 0;
}

static void ARIS_LoopGlobalTargetArray(int count)
{
	int nextKnownIndex = 0;
	for (int i = 0; i < count; i++)
	{
		if (i_TargetArray[i] == 0)
			i_TargetArray[i] = i_TargetArray[nextKnownIndex++];
	}
}

static void Timer_ARIS_FireRocketTowardsPlayer(Handle timer, int iNPC)
{
	if (b_NpcHasDied[iNPC] || IsValidEntity(Aperture_GetLastStandBoss()))
		return;
	
	ARIS npc = view_as<ARIS>(iNPC);
	ARIS_FireRocketTowardsPlayer(npc);
}

static void Timer_ARIS_PlaySecondReloadingSound(Handle timer, int iNPC)
{
	if (b_NpcHasDied[iNPC])
		return;
	
	EmitSoundToAll(g_ShotgunReloadingSounds[1], iNPC, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
}
	
static bool TraceFilter_ARIS_ShotgunBlast(int entity, int mask, int other)
{
	if (IsValidEnemy(entity, other, true) && Can_I_See_Enemy(entity, other, true))
		b_EnemyHitByBlast[entity] = true;
	
	return false;
}

static bool TraceFilter_ARIS_ShotgunBullet(int entity, int mask, int other)
{
	if (IsValidEnemy(entity, other, true))
	{
		if (i_EnemyHitByThisManyBullets[entity] >= 5)
			return false;
		
		i_EnemyHitByThisManyBullets[entity]++;
	}
	
	return false;
}

static bool TraceEntityFilter_ARIS_OnlyWorld(int entity, int mask)
{
	return entity == 0 || entity > MAXENTITIES;
}

static void ARIS_ClearAllProjectiles(ARIS npc)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		if (!IsValidEntity(i) || !b_IsAProjectile[i])
			continue;
		
		int owner = GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity");
		if (owner != npc.index)
			continue;
		
		RemoveEntity(i);
	}
}

static bool ARIS_LoseConditions(int iNPC)
{
	ARIS npc = view_as<ARIS>(iNPC);
	if (npc.m_flNextDeathState)
	{
		if (npc.m_flNextDeathState > GetGameTime())
			return true;
		
		switch (npc.m_iDeathState)
		{
			case 0:
			{
				npc.m_bisWalking = false;
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				
				npc.AddActivityViaSequence("taunt01");
				npc.SetCycle(0.05);
				npc.SetPlaybackRate(1.0);
				npc.m_flNextDeathState = GetGameTime() + 1.7;
				
				CPrintToChatAll("{rare}A.R.I.S.{default}: ㅅㅣㅁ각한 ㅍㅣㅎㅐ 감지");
			}
			
			case 1:
			{
				npc.AddActivityViaSequence("taunt01");
				npc.SetCycle(0.66);
				npc.SetPlaybackRate(0.0);
				
				float vecPos[3], vecAng[3], vecTargetPos[3];
				npc.GetAttachment("flag", vecPos, vecAng);
				vecPos[2] += 10.0;
				npc.m_iWearable2 = ParticleEffectAt_Parent(vecPos, "rockettrail", npc.index);
				
				GetAbsOrigin(npc.index, vecTargetPos);
				npc.m_flLastDeathHeight = vecTargetPos[2];
				vecTargetPos[2] += 1000.0;
				
				b_NoGravity[npc.index] = true;
				PluginBot_Jump(npc.index, vecTargetPos);
				
				npc.m_flNextDeathState = GetGameTime() + 0.1;
				npc.PlaySelfLaunchingSound();
				
				switch (GetURandomInt() % 4)
				{
					case 0:
						CPrintToChatAll("{rare}A.R.I.S.{default}: ㄷㅗ주!");
					case 1:
						CPrintToChatAll("{rare}A.R.I.S.{default}: 후퇴! ㅇㅓㅅㅓ!");
					case 2:
						CPrintToChatAll("{rare}A.R.I.S.{default}: 재보ㄱㅏㅇ 필요!");
					case 3:
						CPrintToChatAll("{rare}A.R.I.S.{default}: 4R15 = ㅌㅚ장!");
				}
			}
			
			case 20:
			{
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
			
			default: // 2-19 (lazy)
			{
				// Immediately kill ARIS if we hit a ceiling
				float vecPos[3];
				GetAbsOrigin(npc.index, vecPos);
				if (vecPos[2] == npc.m_flLastDeathHeight)
				{
					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
					return true;
				}
				
				npc.m_flNextDeathState = GetGameTime() + 0.1;
				npc.m_flLastDeathHeight = vecPos[2];
			}
		}
		
		npc.m_iDeathState++;
		npc.Update();
		return true;
	}
	
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{rare}A.R.I.S.{default}: 임ㅁㅜ 완료. 원위ㅊㅣ.");
		return true;
	}
	
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{rare}A.R.I.S.{default}: 적ㄱㅜㄴ의 도ㅈㅜ 감지. 임무 완료");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return true;
	}

	return false;
}



void CreateMediArmorBeam(int ToEntity, int FromEntity)
{
	float vecTarget[3];
	WorldSpaceCenter(FromEntity, vecTarget);
	int particle = ParticleEffectAtOcean(vecTarget, "medicgun_beam_machinery", 0.0, false);
	
	SetParent(FromEntity, particle, "", _, true);

	CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
	
	WorldSpaceCenter(ToEntity, vecTarget);

	int particle2 = ParticleEffectAtOcean(vecTarget, "medicgun_beam_machinery", 0.0, false);

	SetParent(ToEntity, particle2, "", _, true);

	CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, Timer_StopEmitting, EntIndexToEntRef(particle2), TIMER_FLAG_NO_MAPCHANGE);

	SetEntPropEnt(particle2, Prop_Send, "m_hControlPointEnts", particle, 0);
	SetEntProp(particle2, Prop_Send, "m_iControlPointParents", particle, _, 0);

	ActivateEntity(particle2);
	AcceptEntityInput(particle2, "start");
}

public Action Timer_StopEmitting(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		ActivateEntity(entity);
		AcceptEntityInput(entity, "stop");
	}
	return Plugin_Stop;
}

static void ARIS_SetNextForcedWeaponSwitchThreshold(ARIS npc)
{
	const float maxHealthPercentageThreshold = 0.25;
	npc.m_iForcedWeaponSwitchHealthThreshold = GetEntProp(npc.index, Prop_Data, "m_iHealth") - RoundToCeil(ReturnEntityMaxHealth(npc.index) * maxHealthPercentageThreshold);
}