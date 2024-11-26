#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"ambient/levels/streetwar/strider_distant1.wav",
	"ambient/levels/streetwar/strider_distant2.wav",
	"ambient/levels/streetwar/strider_distant3.wav",
};

static const char g_HurtSounds[][] = {
	"ambient/levels/prison/radio_random1.wav",
	"ambient/levels/prison/radio_random2.wav",
	"ambient/levels/prison/radio_random3.wav",
	"ambient/levels/prison/radio_random4.wav",
	"ambient/levels/prison/radio_random5.wav",
	"ambient/levels/prison/radio_random6.wav",
	"ambient/levels/prison/radio_random7.wav",
	"ambient/levels/prison/radio_random8.wav",
	"ambient/levels/prison/radio_random9.wav",
	"ambient/levels/prison/radio_random10.wav",
	"ambient/levels/prison/radio_random11.wav",
	"ambient/levels/prison/radio_random12.wav",
	"ambient/levels/prison/radio_random13.wav",
	"ambient/levels/prison/radio_random14.wav",
	"ambient/levels/prison/radio_random15.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};

static char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static char g_AngerSounds[][] = {
	"mvm/mvm_tank_deploy.wav",
};

static char g_AngerSoundsPassed[][] = {
	"ambient/levels/labs/teleport_winddown1.wav",
};

static char g_Sword_Impact_Sound[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};


static float fl_teleport_strike_recharge[MAXENTITIES];
static bool b_teleport_strike_active[MAXENTITIES];



#define SCHWERT_TELEPORT_STRIKE_INITIALIZE		"misc/halloween/gotohell.wav"
#define SCHWERT_TELEPORT_STRIKE_LOOPS 			"weapons/vaccinator_charge_tier_03.wav"
#define SCHWERT_TELEPORT_STRIKE_EXPLOSION		"misc/halloween/spell_mirv_explode_primary.wav"

#define SCHWERTKRIEG_LIGHT_MODEL "models/effects/vol_light256x512.mdl"
#define SCHWERTKRIEG_BLADE_MODEL "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl"

#define SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS 750.0

static float fl_npc_basespeed;

//Logic for duo raidboss

static int i_current_wave[MAXENTITIES];
static int i_ally_index[MAXENTITIES];

static bool b_swords_created[MAXENTITIES];


static float fl_retreat_timer[MAXENTITIES];
static bool Schwertkrieg_BEAM_HitDetected[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_schwert_armour[MAXENTITIES][2];
static float fl_schwert_sword_battery[MAXENTITIES];


#define SCHWERKRIEG_SWORDS_AMT 7	
#define KARLAS_SLICER_HIT	"npc/scanner/scanner_electric1.wav"

static int i_dance_of_light_sword_id[MAXENTITIES][SCHWERKRIEG_SWORDS_AMT];
static float fl_dance_of_light_sword_throttle[MAXENTITIES][SCHWERKRIEG_SWORDS_AMT];
static float fl_dance_of_light_sound_spam_timer[MAXENTITIES];


void Karlas_OnMapStart_NPC()
{
	Zero(fl_teleport_strike_recharge);
	Zero(b_teleport_strike_active);
	Zero(b_swords_created);
	Zero(fl_retreat_timer);
	Zero(fl_dance_of_light_sound_spam_timer);
	Zero2(fl_dance_of_light_sword_throttle);
	Zero(Schwertkrieg_BEAM_HitDetected);
	Zero(fl_spinning_angle);
	Zero2(fl_schwert_armour);
	Zero(fl_schwert_sword_battery);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Karlas");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_karlas");
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "schwert"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;										//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Precache = ClotPrecache;
	NPC_Add(data);

}

static void ClotPrecache()
{
	PrecacheSoundArray(g_AngerSoundsPassed);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_Sword_Impact_Sound);
	PrecacheSoundArray(g_BuffSounds);
	
	PrecacheModel(SCHWERTKRIEG_LIGHT_MODEL, true);
	PrecacheModel(SCHWERTKRIEG_BLADE_MODEL, true);
	PrecacheSound(SCHWERT_TELEPORT_STRIKE_INITIALIZE, true);
	PrecacheSound(SCHWERT_TELEPORT_STRIKE_LOOPS, true);
	PrecacheSound(SCHWERT_TELEPORT_STRIKE_EXPLOSION, true);
	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);

	PrecacheSound(KARLAS_SLICER_HIT, true);

	
	PrecacheSound("mvm/mvm_tele_deliver.wav", true);
	PrecacheSound("mvm/mvm_tele_activate.wav", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Karlas(vecPos, vecAng, team);
}

static int i_particle_effects[MAXENTITIES];

methodmap Karlas < CClotBody
{
	
	property bool m_bRetreat
	{
		public get()							{ return this.m_fbGunout; }
		public set(bool TempValueForProperty) 	{ this.m_fbGunout = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayTeleportSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_TeleportSounds) - 1);
		EmitSoundToAll(g_TeleportSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack.WriteString(g_TeleportSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void Emit_Sword_Impact_Sound(float Loc[3])
	{
		if(fl_dance_of_light_sound_spam_timer[this.index] > GetGameTime())
			return;

		fl_dance_of_light_sound_spam_timer[this.index] = GetGameTime() + 0.1;

		int sound = GetRandomInt(0, sizeof(g_Sword_Impact_Sound) - 1);
		EmitSoundToAll(g_Sword_Impact_Sound[sound], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _, _, Loc);
	}

	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME); 
	}
	public void PlayAngerSoundPassed() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);

		EmitSoundToAll("mvm/mvm_tele_activate.wav", this.index, SNDCHAN_STATIC, 80, _, 0.8);
	}
	
	property int Ally
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_ally_index[this.index]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_ally_index[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_ally_index[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	property float m_flNC_LockedOn
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property int m_iNClockonState
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property int m_iParticles1
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_particle_effects[this.index][0]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_particle_effects[this.index][0] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_particle_effects[this.index][0] = EntIndexToEntRef(iInt);
			}
		}
	}
	public void LanceState(bool activate)
	{
		if(IsValidEntity(this.m_iWearable8))
			RemoveEntity(this.m_iWearable8);

		if(!activate)
			return;

		this.m_iWearable8 = this.EquipItem("effect_hand_r", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_IMPACT_LANCE_4);
		AcceptEntityInput(this.m_iWearable8, "SetBodyGroup");
	}
	

	public void Set_Particle(char[] Particle, char[] Attachment)
	{
		if(IsValidEntity(this.m_iParticles1))
			RemoveEntity(this.m_iParticles1);

		float flPos[3], flAng[3];

		this.GetAttachment(Attachment, flPos, flAng);
		this.m_iParticles1 = ParticleEffectAt_Parent(flPos, Particle, this.index, Attachment, {0.0,0.0,0.0});
	}

	public Karlas(float vecPos[3], float vecAng[3], int ally)
	{
		Karlas npc = view_as<Karlas>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));

		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.m_iChanged_WalkCycle = 1;
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		b_angered_twice[npc.index]=false;
		fl_teleport_strike_recharge[npc.index] = GetGameTime()+25.0;
		b_teleport_strike_active[npc.index]=false;

		fl_dance_of_light_sound_spam_timer[npc.index] = 0.0;

		npc.m_fbGunout = false;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		if(RaidModeTime < GetGameTime() + 250.0)
			RaidModeTime = GetGameTime() + 250.0;

		npc.m_flNextChargeSpecialAttack = 0.0;	//used for transformation Logic
		b_swords_created[npc.index]=false;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;

		fl_schwert_sword_battery[npc.index]=0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
			
		
		//IDLE
		fl_npc_basespeed = 330.0;
		npc.m_flSpeed =330.0;

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;

		SetVariantColor(view_as<int>({3, 244, 252, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		
		/*

			breakneck baggies	"models/workshop/player/items/all_class/jogon/jogon_medic.mdl"
			lo-grav loafers		"models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl"
			puffed practitioner	"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl"

			das blutliebhaber	"models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl"
			Herzensbrecher		"models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl"
			dark helm			"models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl"
			quadwrangler		"models/player/items/medic/qc_glove.mdl"

		*/
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl");
		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		npc.m_iWearable8 = npc.EquipItem("weapon_bone", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_IMPACT_LANCE_4);
		AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
		npc.StartPathing();

		npc.Set_Particle("raygun_projectile_blue_crit", "eyeglow_L");


		fl_schwert_armour[npc.index][0] = 1.0;	//ranged
		fl_schwert_armour[npc.index][1] = 1.5;	//melee
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");

		npc.Anger = false;

		Schwertkrieg_Create_Wings(npc);
		Delete_Swords(npc.index);

		func_NPCFuncWin[npc.index] = Win_Line;
		npc.m_iNClockonState = 2;
		
		
		return npc;
	}
}
static void Win_Line(int entity)
{
	//if(b_raidboss_donnerkrieg_alive)
	//	return;
	
	CPrintToChatAll("{crimson}Karlas{snow}: Oyaya?");


}
void Set_Karlas_Ally(int karlas, int stella, int wave = -2)
{	
	if(wave == -2)
		wave = ZR_GetWaveCount()+1;

	i_current_wave[karlas] = wave;
	i_ally_index[karlas] = EntIndexToEntRef(stella);
}

static void Internal_ClotThink(int iNPC)
{
	Karlas npc = view_as<Karlas>(iNPC);
	
	//if(!b_raidboss_donnerkrieg_alive)	//While This I do need
	//	Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(false);	//donner first, schwert second


	float GameTime = GetGameTime(npc.index);

	//Todo: fix raidmodetime
	/*if(RaidModeTime < GetGameTime())
	{
		func_NPCThink[npc.index]=INVALID_FUNCTION;
		return;
	}*/

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

	//Set raid to this one incase the previous one has died or somehow vanished
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

	//we are about to teleport, BUT stella wants us to retreat, so abort the teleport and run to stella.
	bool abort_teleport = false;
	if(npc.m_bRetreat)
		abort_teleport = true;
	//Stella has her NC locked onto us, abort teleport.
	if(npc.m_flNC_LockedOn > GameTime)
		abort_teleport = true;
	
	if(abort_teleport && Schwert_Status(npc, GameTime)==1 && b_teleport_strike_active[npc.index])
	{
		npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1];
		npc.m_flRangedArmor = fl_schwert_armour[npc.index][0];
		npc.m_flSpeed =fl_npc_basespeed;
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.LanceState(true);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0; 
	}

	GetTarget(npc);	

	if(npc.m_flNC_LockedOn > GameTime)
		return;

	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

	//we are in the process of transforming, do stuff. also using a sepereate game time so special effects don't affect the transforming stuff.
	if(Schwert_Status(npc, GetGameTime())==0)	
	{
		f_NpcTurnPenalty[npc.index] = 0.0;	//:)
		i_NpcWeight[npc.index]=999;	//HE ONE HEAFTY BOI!
		float Anim_Timer = 6.25;
		if(npc.m_flNextChargeSpecialAttack < GameTime + Anim_Timer)
		{
			npc.SetPlaybackRate(0.0);
			Schwert_Lifeloss_Logic(npc);
		}
		return;
	}
	else if(b_NpcIsInvulnerable[npc.index] && b_angered_twice[npc.index])
	{
		f_NpcTurnPenalty[npc.index]=1.0;
		i_NpcWeight[npc.index]=3;
		b_NpcIsInvulnerable[npc.index]=false;
		npc.PlayAngerSoundPassed();
		npc.SetPlaybackRate(1.0);

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = true;

		npc.m_flSpeed=fl_npc_basespeed;

		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);

		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);
		
	}
		
	
	int PrimaryThreatIndex = npc.m_iTarget;

	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			if(npc.m_bAllowBackWalking)
				npc.m_bAllowBackWalking=false;
		}
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		return;
	}
	
	int wave = i_current_wave[npc.index];
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float npc_Vec[3]; WorldSpaceCenter(npc.index, npc_Vec);

	float flDistanceToTarget = GetVectorDistance(vecTarget, npc_Vec, true);
	npc.AdjustWalkCycle();

	Body_Pitch(npc, npc_Vec, vecTarget);

	Healing_Logic(npc, PrimaryThreatIndex, flDistanceToTarget);

	if(npc.m_flNextRangedAttack < GameTime && Can_I_See_Enemy(npc.index, PrimaryThreatIndex) == PrimaryThreatIndex)
	{
		Fire_Hiigara_Projectile(npc, PrimaryThreatIndex);

		npc.m_flNextRangedAttack = GameTime + 1.0;

		return;
	}

	if(npc.m_bRetreat)
	{
		int Ally = npc.Ally;
		if(IsValidAlly(npc.index, Ally))
		{
			float vecAlly[3]; WorldSpaceCenter(Ally, vecAlly);

			float flDistanceToAlly = GetVectorDistance(vecAlly, npc_Vec, true);
			Karlas_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget);

			//Schwert_Teleport_Core(npc, PrimaryThreatIndex);
		}
	}
	else
	{
		
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
			
		Schwert_Movement(npc, flDistanceToTarget, PrimaryThreatIndex);

		Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex, GameTime, flDistanceToTarget, vecTarget);
	}

	Blade_Logic(npc);

	npc.PlayIdleAlertSound();
}
static void Healing_Logic(Karlas npc, int PrimaryThreatIndex, float flDistanceToTarget)
{
	int Ally = npc.Ally;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextRangedBarrage_Singular > GameTime)
		return;
	
	Ally = npc.Ally;
	if(!IsValidAlly(npc.index, Ally))
		return;
	
	int AllyMaxHealth = ReturnEntityMaxHealth(Ally);
	int AllyHealth = GetEntProp(Ally, Prop_Data, "m_iHealth");
	int SchwertMaxHealth = ReturnEntityMaxHealth(npc.index);
	int SchwertHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(SchwertHealth > (SchwertMaxHealth / 2) && AllyHealth < (AllyMaxHealth / 4))
	{
		float vecAlly[3];
		float vecMe[3];
		WorldSpaceCenter(Ally, vecAlly);
		WorldSpaceCenter(npc.index, vecMe);

		float flDistanceToAlly = GetVectorDistance(vecAlly, vecMe, true);
		Karlas_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget, true);	
		
		if(flDistanceToAlly < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && Can_I_See_Enemy_Only(npc.index, Ally))
		{
			CPrintToChatAll("{crimson}Karlas{snow}: ..!");
			HealEntityGlobal(npc.index, Ally, float((AllyMaxHealth / 5)), 1.0, 0.0, HEAL_ABSOLUTE);
			HealEntityGlobal(npc.index, npc.index, -float((AllyMaxHealth / 5)), 1.0, 0.0, HEAL_ABSOLUTE);

			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);

			GetEntPropVector(Ally, Prop_Data, "m_vecAbsOrigin", vecAlly);
			
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

			NPCStats_RemoveAllDebuffs(Ally);
			f_NpcImmuneToBleed[Ally] = GetGameTime(Ally) + 5.0;
			f_HussarBuff[Ally] = GetGameTime(Ally) + 10.0;
			npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 30.0;

			npc.PlayBuffSound();
		}	
	}
}
static void Body_Pitch(Karlas npc, float VecSelfNpc[3], float vecTarget[3])
{
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, vecTarget, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
							
	float flPitch = npc.GetPoseParameter(iPitch);
							
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
}
static void GetTarget(Karlas npc)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flGetClosestTargetTime > GameTime)
		return;

	if(npc.m_flNC_LockedOn > GameTime)
	{
		//stella is dead, but the "lockon" is still valid, kill the lockon
		if(!IsValidAlly(npc.index, npc.Ally))
		{
			npc.m_flNC_LockedOn = 0.0;
			npc.m_iNClockonState = 2;
			return;
		}
			

		Stella stella = view_as<Stella>(npc.Ally);
		int target = i_Get_Laser_Target(npc);
		if(IsValidEnemy(npc.index, target))
		{
			npc.m_iTarget = target;
			npc.m_flGetClosestTargetTime = GameTime + 0.2;

			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);

			float Duration = fl_AbilityOrAttack[stella.index][3] - GetGameTime(stella.index);
			float Ratio = (1.0 - (Duration / STELLA_NC_DURATION))+0.2;

			float Turn_Speed = ((stella.Anger ? STELLA_NC_TURNRATE_ANGER : STELLA_NC_TURNRATE)*Ratio);

			Turn_Speed *=0.8;

			if(NpcStats_IsEnemySilenced(stella.index))
				Turn_Speed *=0.95;

			npc.FaceTowards(vecTarget, Turn_Speed);

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);

			Body_Pitch(npc, VecSelfNpc, vecTarget);

			npc.m_flSpeed = fl_npc_basespeed*0.15;
		}
		else
			npc.m_flGetClosestTargetTime = 0.0;

		return;
	}

	if(npc.m_bRetreat)
		return;

	//Karlas will always prefer attacking enemies who are near Stella.
	if(IsValidAlly(npc.index, npc.Ally))	
	{
		npc.m_iTarget = GetClosestTarget(npc.Ally,_,_,_,_,_,_,true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.Ally);
		}
	}
	else
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
}
static float Target_Angle_Value(Karlas npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(npc.index, npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyeAngles);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0)
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	//if its more then 180, its on the other side of the npc / behind
	return fabs(yawOffset);
}
//don't just search for the nearest target when using the laser.
//Instead search for the target NEAREST to our BEAM's length.
static int i_Get_Laser_Target(Karlas npc, float Range = -1.0)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[MAXTF2PLAYERS];
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, true);
	//only bother getting targets infront of karlas that are players. + wall check obv
	int Tmp_Target = -1;
	float Angle_Val = 420.0;
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			float Target_Angles = Target_Angle_Value(npc, enemy_2[i]);
			float VecTarget[3]; WorldSpaceCenter(enemy_2[i], VecTarget);
			if(Target_Angles < 45.0 && Target_Angles < Angle_Val && (Range == -1 || GetVectorDistance(VecTarget, Npc_Vec) <= Range))
			{
				Angle_Val = Target_Angles;
				Tmp_Target = enemy_2[i];
				
				//CPrintToChatAll("Player %N within 45 degress: %f", Tmp_Target, Target_Angles);
			}
		}
	}
	//if we don't find any targets within 90 degrees infront, give up and use normal targeting!
	//and by 90 degress I mean -45 -> 45. \/
	
	if(!IsValidEnemy(npc.index, Tmp_Target))
	{
		//CPrintToChatAll("Backup Target used");
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		return npc.m_iTarget;
	}
	else
	{
		//CPrintToChatAll("Chose Target: %N with angle var: %f", Tmp_Target, Angle_Val);
		return Tmp_Target;
	}
		
}
static void Blade_Logic(Karlas npc)
{
	int Blade_Behavior = -1;

	int wave = i_current_wave[npc.index];

	float GameTime = GetGameTime(npc.index);

	if(b_swords_created[npc.index])
	{
		if(npc.Anger)
		{
			if(fl_schwert_sword_battery[npc.index] < GameTime-30.0)
			{
				fl_schwert_sword_battery[npc.index] = GameTime + 30.0;
			}
		}
		else
		{
			if(fl_schwert_sword_battery[npc.index] < GameTime-45.0)
			{
				fl_schwert_sword_battery[npc.index] = GameTime + 15.0;
			}
		}
		
		Blade_Behavior=2;

		if(npc.m_bRetreat)	//he can only ever use the blades defensively when helping donner
		{
			Blade_Behavior=1;
		}

		if(fl_schwert_sword_battery[npc.index]<GameTime && !npc.m_bRetreat)
		{
			Blade_Behavior=4;
		}
	}
	float npc_Vec[3]; WorldSpaceCenter(npc.index, npc_Vec);
	
	int Ally = npc.Ally;

	if(b_angered_twice[npc.index])
	{
		switch(Blade_Behavior)
		{
			case 1:	//Defenisve. spin around while retracted
			{
				float Loc2[3]; Loc2 = npc_Vec; Loc2[2]+=175.0;
				npc_Vec[2]+=50.0;
				Schwert_Manipulate_Sword_Location(npc, npc_Vec, Loc2, GameTime, 10.0, false, 420.0);
				if(Schwert_Status(npc, GameTime)!=1)
				{
					npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1] - 0.25;
					npc.m_flRangedArmor = fl_schwert_armour[npc.index][0] - 0.25;
				}
				if(IsValidAlly(npc.index, Ally))
				{
					float vecAlly[3];
					WorldSpaceCenter(Ally, vecAlly);
					if(GetVectorDistance(vecAlly, npc_Vec, true) < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0 && Can_I_See_Enemy_Only(npc.index, Ally))
					{
						NPCStats_RemoveAllDebuffs(Ally);
						f_NpcImmuneToBleed[Ally] = GetGameTime(Ally) + 1.0;
						f_BattilonsNpcBuff[Ally] = GetGameTime(Ally) + 2.5;
					}
				}
			}
			case 2:	//Aggresive - spin around him while extended
			{
				//npc_Vec[2]+=0.0;
				if(npc.Anger)
					Schwert_Manipulate_Sword_Location(npc, npc_Vec, npc_Vec, GameTime, 15.0, true, 15.0*RaidModeScaling);
				else
					Schwert_Manipulate_Sword_Location(npc, npc_Vec, npc_Vec, GameTime, 10.0, true, 10.0*RaidModeScaling);
			}
			case 3: //Aggresive - bommerange.
			{
				/*
					how to do this stupid idea:

					Create a fake circle, then make the sword sprial go around that fake circle, once reaching 75% completion of circle, switches back to default spinning.
				*/
				
			}
			case 4:	//becomes pseudo wings. neutral state for when the things are "recharging"
			{
				Schwert_SwordWings_Logic(npc, npc_Vec);
			}
		}
	}
}
static int Schwert_Status(Karlas npc, float GameTime)
{
	if(npc.m_flNextChargeSpecialAttack > GameTime)	//we are transforming
		return 0;

	if(npc.m_flDoingAnimation > GameTime)	//we are doing an animation.
		return 1;

	return -1;

}
enum struct KarlasProj
{
	int particles[3];
}
static KarlasProj struct_Projectile[MAXENTITIES];
//warp
static void Fire_Hiigara_Projectile(Karlas npc, int PrimaryThreatIndex)
{
	float SelfVec[3];
	Ruina_Projectiles Projectile;
	WorldSpaceCenter(npc.index, SelfVec);
	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = SelfVec;
	float Ang[3];
	float VecTarget[3];
	WorldSpaceCenter(PrimaryThreatIndex, VecTarget);
	MakeVectorFromPoints(SelfVec, VecTarget, Ang);
	GetVectorAngles(Ang, Ang);

	float Speed = (npc.Anger ? 750.0 : 500.0);
	float Time = 10.0;

	Projectile.Angles = Ang;
	Projectile.speed = Speed;
	Projectile.radius = 0.0;
	Projectile.damage = 100.0;
	Projectile.bonus_dmg = 100.0;
	Projectile.Time = Time;
	Projectile.visible = false;
	int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);	

	if(!IsValidEntity(Proj))
		return;

	Projectile.Size = 1.0;
	int ModelApply = Projectile.Apply_Model(RUINA_CUSTOM_MODELS_4);
	if(!IsValidEntity(ModelApply))
		return;
	
	SetEntProp(Proj, Prop_Send, "m_usSolidFlags", 12); 
	
	//float angles[3];
	//GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
	//angles[1]+=90.0;
	//TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
	SetVariantInt(RUINA_KARLAS_PROJECTILE);
	AcceptEntityInput(ModelApply, "SetBodyGroup");

	float 	Homing_Power = (npc.Anger ? 8.0 : 5.0),
			Homing_Lockon = (npc.Anger ? 90.0 : 60.0);

	Initiate_HomingProjectile(Proj,
	npc.index,
	Homing_Lockon,			// float lockonAngleMax,
	Homing_Power,			// float homingaSec,
	!npc.Anger,				// bool LockOnlyOnce,
	true,					// bool changeAngles,
	Ang,
	PrimaryThreatIndex
	);

	float flPos[3];
	float flAng[3];

	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetEntPropVector(Proj, Prop_Data, "m_angRotation", flAng);
	GetEntPropVector(Proj, Prop_Data, "m_vecAbsOrigin", flPos);

	int right = ParticleEffectAt({0.0, -52.5, 0.0}, "raygun_projectile_blue", Time);
	int left = ParticleEffectAt({0.0, 52.5, 0.0}, "raygun_projectile_red", Time);

	SetParent(ParticleOffsetMain, right, "",_, true);
	SetParent(ParticleOffsetMain, left, "",_, true);

	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(Proj, ParticleOffsetMain, "",_);

	struct_Projectile[Proj].particles[0] = EntIndexToEntRef(ParticleOffsetMain);
	struct_Projectile[Proj].particles[1] = EntIndexToEntRef(left);
	struct_Projectile[Proj].particles[2] = EntIndexToEntRef(right);

	CreateTimer(Time, Timer_RemoveEntity, EntIndexToEntRef(ParticleOffsetMain), TIMER_FLAG_NO_MAPCHANGE);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(Proj));
	RequestFrame(Projectile_Detect_Loop, pack);
	
}
static void Projectile_Detect_Loop(DataPack pack)
{
	pack.Reset();
	int projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(projectile))
	{
		if(projectile == -1)
			return ;

		for(int i =0 ; i < 3 ; i++)
		{
			int particle = EntRefToEntIndex(struct_Projectile[projectile].particles[i]);
			if(IsValidEntity(particle))
				RemoveEntity(particle);
			
			struct_Projectile[projectile].particles[i] = INVALID_ENT_REFERENCE;
		}
		return ;
	}
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		for(int i =0 ; i < 3 ; i++)
		{
			int particle = EntRefToEntIndex(struct_Projectile[projectile].particles[i]);
			if(IsValidEntity(particle))
				RemoveEntity(particle);
			
			struct_Projectile[projectile].particles[i] = INVALID_ENT_REFERENCE;
		}
		Ruina_Remove_Projectile(projectile);
		return ;
	}
	float Vec_Points[2][3];
	for(int i =1 ; i < 3 ; i++)
	{
		int particle = EntRefToEntIndex(struct_Projectile[projectile].particles[i]);
		if(!IsValidEntity(particle))
			return ;

		float flPos[3];
		GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", flPos);
		Vec_Points[i-1] = flPos;
	}
	//float radius = 7.0;
	//TE_SetupBeamPoints(Vec_Points[0], Vec_Points[1], g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, radius*2.0, radius*2.0, 0, 5.0, {255,255,255,255}, 3);
	//TE_SendToAll();

	Ruina_Laser_Logic Laser;
	Laser.client = owner;
	Laser.Damage = Modify_Damage(-1, 25.0);
	Laser.Bonus_Damage = Modify_Damage(-1, 25.0) * 6.0;
	Laser.damagetype = DMG_PLASMA|DMG_PREVENT_PHYSICS_FORCE;
	//Laser.Radius = radius;
	Laser.End_Point = Vec_Points[1];
	Laser.Start_Point = Vec_Points[0];
	Laser.Custom_Hull = {7.0, 7.0, 2.0};	//we want the player to have the ability to jump over the slicer if they time it right
	Laser.Detect_Entities(On_LaserHit);

	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(EntIndexToEntRef(projectile));
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(Projectile_Detect_Loop, frames_offset, pack2);

	
}
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	if(fl_trace_target_timeout[client][target] > GetGameTime())
		return;
	fl_trace_target_timeout[client][target] = GetGameTime() + 0.25;	//if they walk backwards, its likely to hit them 2 times, but who on earth would willingly walk backwards/alongside the trajectory of the projectile

	int pitch = GetRandomInt(125,135);
	EmitSoundToAll(KARLAS_SLICER_HIT, target, SNDCHAN_AUTO, 75,_,0.8,pitch);
	SDKHooks_TakeDamage(target, client, client, damage, damagetype, -1); 
}
static void Func_On_Proj_Touch(int entity, int other)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))	//owner is invalid, evacuate.
	{
		Ruina_Remove_Projectile(entity);
		return;
	}
	//we only care if we hit a wall or smth.
	if(other != 0)
		return;
	
	for(int i =0 ; i < 3 ; i++)
	{
		int particle = EntRefToEntIndex(struct_Projectile[entity].particles[i]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
		
		struct_Projectile[entity].particles[i] = INVALID_ENT_REFERENCE;
	}
	
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	TE_Particle("spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

	Ruina_Remove_Projectile(entity);

}
static void Schwert_Aggresive_Behavior(Karlas npc, int PrimaryThreatIndex, float GameTime, float flDistanceToTarget, float vecTarget[3])
{

	if(npc.m_bAllowBackWalking)
	{
		npc.FaceTowards(vecTarget, 20000.0);
	}
	else
	{
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
	}
		

	if(fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
	{
		npc.m_bAllowBackWalking=true;
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
		NPC_SetGoalVector(npc.index, vBackoffPos, true);

		npc.FaceTowards(vecTarget, 20000.0);

		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
	}
	else
	{
		npc.m_bAllowBackWalking=false;
	}

	npc.StartPathing();
	npc.m_bPathing = true;

	
	Schwertkrieg_Teleport_Strike(npc, flDistanceToTarget, GameTime, PrimaryThreatIndex);
	
	//ancient melee code, don't copy it, take it from a more recent melee npc, this one is staying since it works + it has special logic for Karlas.
	//if you want similar "retreat after melee" logic like Karlas, go look at the lancelot from ruina, its far cleaner
	if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(Schwert_Status(npc, GameTime)==1)
			return;

		float Swing_Speed = 1.0;
		float Swing_Delay = 0.2;
		if(npc.m_flNextMeleeAttack < GameTime)
		{

			//Play attack ani
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = GameTime+Swing_Delay;
				npc.m_flAttackHappens_bullshit = GameTime+Swing_Speed;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
			{
				fl_retreat_timer[npc.index] = GameTime+(Swing_Speed*0.35);

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float meleedmg= Modify_Damage(target, 50.0);	//schwert hurts like a fucking truck

						if(npc.Anger)
							meleedmg*1.25;

						if(fl_schwert_sword_battery[npc.index]> GameTime)
						{
							if(npc.Anger)
								fl_schwert_sword_battery[npc.index] +=2.0;
							else
								fl_schwert_sword_battery[npc.index] +=1.0;
						}
						
						if(IsValidClient(target))
						{
							float Bonus_damage = 1.0;
							int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
							
							if(IsValidEntity(weapon))
							{	
								char classname[32];
								GetEntityClassname(weapon, classname, 32);
							
								int weapon_slot = TF2_GetClassnameSlot(classname);
							
								if(weapon_slot != 2 || i_IsWandWeapon[weapon])
								{
									Bonus_damage = 1.5;
								}
								meleedmg *= Bonus_damage;
							}
							//clause ae schwert knockback
							Custom_Knockback(npc.index, target, 900.0, true);
							TF2_AddCondition(target, TFCond_LostFooting, 0.5);
							TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
						}

						SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();	
					
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
			}
		}
	}
	else
	{
		npc.StartPathing();
	}
}
static float Modify_Damage(int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	damage*=RaidModeScaling;

	return damage;
}

static void Schwertkrieg_Teleport_Strike(Karlas npc, float flDistanceToTarget, float GameTime, int PrimaryThreatIndex)
{
	if(npc.m_bRetreat)
		return;
	
	float FIXME;
	
	bool can_see=false;
	bool touching_creep = SeaFounder_TouchingNethersea(PrimaryThreatIndex);
	if(flDistanceToTarget < (2500.0*2500.0) || touching_creep)
	{
		can_see=true;
	}
	if(can_see && fl_teleport_strike_recharge[npc.index] < GameTime && !b_teleport_strike_active[npc.index])
	{
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))
		{
			npc.m_flSpeed = 0.0;
			npc.m_flDoingAnimation = GameTime+2.0;
			b_teleport_strike_active[npc.index]=true;

			npc.SetPlaybackRate(0.75);	
			npc.SetCycle(0.1);

			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_neck_snap_medic");

			npc.LanceState(false);

			float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc);

			EmitSoundToAll(SCHWERT_TELEPORT_STRIKE_INITIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);
			EmitSoundToAll(SCHWERT_TELEPORT_STRIKE_INITIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);

			npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1]-1.0;
			npc.m_flRangedArmor = fl_schwert_armour[npc.index][0]-0.5;

			npc_Loc[2]+=10.0;
			int wave = i_current_wave[npc.index];
			int r, g, b, a;
			a = 175;

			if(wave<=15)
			{
				r = 255;
				g = 50;
				b = 50;
			}
			else if(wave <=30)
			{
				r = 147;
				g = 188;
				b = 199;
			}
			else if(wave <=45)
			{
				r = 51;
				g = 9;
				b = 235;
			}
			else
			{
				r = 255;
				g = 50;
				b = 50;
			}
			spawnRing_Vectors(npc_Loc, 250.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 2.0, 12.0, 2.0, 1, 1.0);

		}
	}
	if(b_teleport_strike_active[npc.index] && npc.m_flDoingAnimation < GameTime)
	{
		npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1];
		npc.m_flRangedArmor = fl_schwert_armour[npc.index][0];
		npc.m_flSpeed =fl_npc_basespeed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = true;

		npc.LanceState(true);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0;


		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy) || touching_creep)	//now do another check to see if we can still even see a target, if not, abort the whole process. ignore if the target is in creep
		{
			float VecForward[3];
			float vecRight[3];
			float vecUp[3];
			float vecPos[3];
					
			GetVectors(PrimaryThreatIndex, VecForward, vecRight, vecUp);
			GetAbsOrigin(PrimaryThreatIndex, vecPos);
			vecPos[2] += 5.0;
					
			float vecSwingEnd[3];
			vecSwingEnd[0] = vecPos[0] - VecForward[0] * (100);
			vecSwingEnd[1] = vecPos[1] - VecForward[1] * (100);
			vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/
			if(Schwert_Teleport(npc.index, vecSwingEnd, 0.0))
			{
				Schwertkrieg_Teleport_Boom(npc, vecSwingEnd);
				npc.PlayTeleportSound();
				if(npc.Anger)
					fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
				else
					fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
			}
			else
			{
				vecSwingEnd[0] = vecPos[0] - VecForward[0] * (-100);
				vecSwingEnd[1] = vecPos[1] - VecForward[1] * (-100);
				vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/
				if(Schwert_Teleport(npc.index, vecSwingEnd, 0.0))
				{
					npc.PlayTeleportSound();
					Schwertkrieg_Teleport_Boom(npc, vecSwingEnd);
					if(npc.Anger)
						fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
					else
						fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
				}
				else
				{
					GetAbsOrigin(PrimaryThreatIndex, vecSwingEnd);
					vecSwingEnd[2]+=125.0;
					if(Schwert_Teleport(npc.index, vecSwingEnd, 0.0))
					{
						npc.PlayTeleportSound();
						Schwertkrieg_Teleport_Boom(npc, vecSwingEnd);
						if(npc.Anger)
							fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
						else
							fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
					}
				}
			}
		}
	}
}
static void Schwertkrieg_Proper_To_Groud_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
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

static void Schwertkrieg_Teleport_Boom(Karlas npc, float Location[3])
{
	float Boom_Time = 5.0;

	Schwertkrieg_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Location);

	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	

	int wave = i_current_wave[npc.index];
	int color[4];
	color[3] = 175;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}
	else
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
		radius *= 1.5;
	}

	TE_SetupBeamRingPoint(Location, radius*2.0, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, Boom_Time, 15.0, 1.0, color, 1, 0);

	

	Handle pack;
	CreateDataTimer(Boom_Time, Schwert_Boom, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntRefToEntIndex(npc.index));
	WritePackFloat(pack, Location[0]);
	WritePackFloat(pack, Location[1]);
	WritePackFloat(pack, Location[2]);

	Handle pack2;
	CreateDataTimer(0.0, Schwert_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(npc.index));
	WritePackFloat(pack2, Boom_Time);
	WritePackFloat(pack2, Location[0]);
	WritePackFloat(pack2, Location[1]);
	WritePackFloat(pack2, Location[2]);
}
static Action Schwert_Ring_Loops(Handle Loop, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	float loops = ReadPackFloat(pack);
	if(loops<=0.0)
	{
		return Plugin_Stop;
	}
	loops-=1.0;

	
	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}

	EmitAmbientSound(SCHWERT_TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
	EmitAmbientSound(SCHWERT_TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));

	Karlas npc = view_as<Karlas>(entity);
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	

	int wave = i_current_wave[npc.index];
	int color[4];
	color[3] = 175;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}
	else
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}

	
	
	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 1.0, 15.0, 0.1, color, 1, 0);
	TE_SendToAll();

	Handle pack2;
	CreateDataTimer(1.0, Schwert_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(entity));
	WritePackFloat(pack2, loops);
	WritePackFloat(pack2, spawnLoc[0]);
	WritePackFloat(pack2, spawnLoc[1]);
	WritePackFloat(pack2, spawnLoc[2]);

	return Plugin_Stop;

}
static Action Schwert_Boom(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	Karlas npc = view_as<Karlas>(entity);

	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = 200.0*RaidModeScaling;	//very deadly!
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	int wave = i_current_wave[npc.index];
	int color[4];
	color[3] = 175;
	int loop_for = 15;		//15
	float height = 1500.0;	//1500
	float sky_loc[3]; sky_loc = spawnLoc; sky_loc[2]+=height;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}
	else
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}

	if(npc.Anger)
	{
		radius *= 1.25;	
		damage *=1.25;
	}

	Explode_Logic_Custom(damage, npc.index, npc.index, -1, spawnLoc, radius,_,0.8, true);

	EmitAmbientSound(SCHWERT_TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
	EmitAmbientSound(SCHWERT_TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));

	float GameTime = GetGameTime(npc.index);
	
	if(fl_schwert_sword_battery[npc.index]< GameTime)
		fl_schwert_sword_battery[npc.index] = GameTime+5.0;
	else
		fl_schwert_sword_battery[npc.index] += 5.0;

	spawnLoc[2]+=10.0;

	TE_SetupBeamRingPoint(spawnLoc, 1.0, radius*2.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, 1.0, 15.0, 1.0, color, 1, 0);
	TE_SendToAll();

	float start = 15.0;
	float end = 15.0;
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
	TE_SendToAll();

	float Time = 1.0;

	float thicc = 3.0;
	float Seperation = height / loop_for;
	float Offset_Time = Time / loop_for;
	for(int i = 1 ; i <= loop_for ; i++)
	{
		float timer = Offset_Time*i+0.3;
		if(timer<=0.02)
			timer=0.02;
		float end_ratio = (((loop_for/2.0)/i));
		float final_radius = radius*end_ratio;
		if(final_radius > 4096.0)	//so apperantly there is a max endradius, these are the types of things you only findout if you are dumb enough to even try...
			final_radius= 4095.0;
		TE_SetupBeamRingPoint(spawnLoc, 0.0, final_radius, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, timer, thicc, 0.1, color, 1, 0);

		TE_SendToAll();
		spawnLoc[2]+=Seperation;
	}

	return Plugin_Stop;
	
}
static bool Schwert_Teleport(int iNPC, float vecTarget[3], float Min_Range)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	float start_offset[3], end_offset[3];
	WorldSpaceCenter(npc.index, start_offset);
	float Tele_Check = GetVectorDistance(start_offset, vecTarget);


	bool Succeed = false;

	if(Tele_Check>Min_Range)
	{
		Succeed = NPC_Teleport(npc.index, vecTarget);
	
		if(Succeed)
		{
			
			float effect_duration = 0.25;
			
			
			end_offset = vecTarget;
			
			start_offset[2]-= 25.0;
			end_offset[2] -= 25.0;
			
			for(int help=1 ; help<=8 ; help++)
			{	
				Schwert_Teleport_Effect("drg_manmelter_trail_blue", effect_duration, start_offset, end_offset);
				
				start_offset[2] += 12.5;
				end_offset[2] += 12.5;
			}
		}
	}
	return Succeed;
}
static void Schwert_Movement(Karlas npc, float flDistanceToTarget, int target)
{	
	npc.StartPathing();
	npc.m_bPathing = true;
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
								
		NPC_SetGoalVector(npc.index, vPredictedPos);
	} 
	else 
	{
		NPC_SetGoalEntity(npc.index, target);
	}
}
static void Karlas_Movement_Ally_Movement(Karlas npc, float flDistanceToAlly, int ally, float GameTime, int PrimaryThreatIndex_Schwert, float flDistanceToTarget_Schwert, bool block_defense=false)
{	
	if(npc.m_bAllowBackWalking)
		npc.m_bAllowBackWalking=false;
		
	npc.StartPathing();
	npc.m_bPathing = true;
	
	float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex_Schwert, WorldSpaceVec2);
	
	if(flDistanceToTarget_Schwert < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25 && npc.m_iNClockonState != 2)
	{
		Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
		Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, WorldSpaceVec2);
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
		return;
	}
	Stella donner = view_as<Stella>(ally);
	
	if(block_defense)
	{
		NPC_SetGoalEntity(npc.index, donner.index);
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed*2.0;
		return;
	}	
	if(flDistanceToAlly < (1500.0*1500.0) && (npc.m_iNClockonState!=2 || Can_I_See_Enemy_Only(npc.index, npc.Ally)))	//stay within a 1500 radius of donner, and preferably within line of sight
	{
		int target_new = GetClosestTarget(donner.index);
		if(IsValidEnemy(npc.index, target_new))
		{
			float Ally_Vec[3]; WorldSpaceCenter(donner.index, Ally_Vec);
			float Vec_Target[3]; WorldSpaceCenter(target_new, Vec_Target);
			float flDistanceToTarget = GetVectorDistance(Ally_Vec, Vec_Target, true);
			if(flDistanceToTarget < (500.0*500.0))	//they are to close to my beloved, *Kill them*
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				flDistanceToTarget = GetVectorDistance(WorldSpaceVec, Vec_Target, true);
				Schwert_Movement(npc, flDistanceToTarget, target_new);
				Schwert_Aggresive_Behavior(npc, target_new, GameTime, flDistanceToTarget, Vec_Target);
				if(Schwert_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_npc_basespeed*2.0;
			}
			else
			{
				Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
				Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, WorldSpaceVec2);
				if(Schwert_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_npc_basespeed;
			}
		}
		else
		{
			Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
			Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, WorldSpaceVec2);
			if(Schwert_Status(npc, GameTime)!=1)
				npc.m_flSpeed =  fl_npc_basespeed;
		}
	} 
	else 
	{
		NPC_SetGoalEntity(npc.index, donner.index);
		if(Schwert_Status(npc, GameTime)!=1 && (npc.m_iNClockonState !=2 || !Can_I_See_Enemy_Only(npc.index, npc.Ally)))
			npc.m_flSpeed =  fl_npc_basespeed*2.0;

		npc.m_flGetClosestTargetTime = 0.0;
	}
	if(npc.m_iNClockonState == 2)
	{
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex_Schwert);

		if(IsValidEnemy(npc.index, enemy))
		{
			WorldSpaceCenter(enemy, WorldSpaceVec2);
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(WorldSpaceVec2, RUINA_FACETOWARDS_BASE_TURNSPEED*1.5);
		}
		
	}
		
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Karlas npc = view_as<Karlas>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));

	if(npc.m_flNextChargeSpecialAttack > GetGameTime())
	{
		damage=0.0;
		//CPrintToChatAll("Damage nulified");
		return Plugin_Changed;
	}

	int wave = i_current_wave[npc.index];

	
	if(!b_angered_twice[npc.index] && Health/MaxHealth<=0.8 && !b_teleport_strike_active[npc.index] && npc.m_flNC_LockedOn < GetGameTime(npc.index))
	{
		b_angered_twice[npc.index]=true;

		npc.m_flNextChargeSpecialAttack = GetGameTime()+8.0;

		npc.m_bisWalking = false;

		npc.AddActivityViaSequence("taunt_the_fist_bump");
		npc.SetPlaybackRate(0.2);	
		npc.SetCycle(0.01);

		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		npc.PlayAngerSound();

		Schwert_Lifeloss_Initialize(npc);

		npc.m_flSpeed=0.0;
	}
	

	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Schwert_Lifeloss_Initialize(Karlas npc)
{
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	npc.m_iWearable7 = npc.EquipItemSeperate("head", SCHWERTKRIEG_LIGHT_MODEL ,_,_,_,300.0);
	
}
static void Schwert_Lifeloss_Logic(Karlas npc)
{
	if(!b_swords_created[npc.index])
	{
		b_swords_created[npc.index]=true;
		//CPrintToChatAll("Swords created.");

		fl_schwert_sword_battery[npc.index] = GetGameTime() + 30.0;

		float Loc[3];
		GetAbsOrigin(npc.index, Loc);

		for(int i=0 ; i < SCHWERKRIEG_SWORDS_AMT ; i++)
		{
			int sword = Create_Blade(Loc, "2");
			if(IsValidEntity(sword))
			{
				i_dance_of_light_sword_id[npc.index][i]=EntIndexToEntRef(sword);
			}
		}
	}
	if(b_swords_created[npc.index])
	{
		float Duration = npc.m_flNextChargeSpecialAttack - GetGameTime();
		float Ratio = (Duration/6.0);
		float Loc[3]; GetAbsOrigin(npc.index, Loc); Loc[2]+=50.0;
		Loc[2] += 150.0*Ratio;
		float Loc2[3]; GetAbsOrigin(npc.index, Loc2); Loc2[2]+=25.0;
		float speed = 30.0 - 25.0*Ratio;
		Schwert_Manipulate_Sword_Location(npc, Loc, Loc2, GetGameTime(), speed, true, 15.0*RaidModeScaling);
	}
}
static void Schwert_SwordWings_Logic(Karlas npc, float npc_Vec[3])
{
	float angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
	angles[0]=0.0;
	angles[2]=0.0;
	float back_vec[3];

	npc_Vec[2]+=15.0;

	Get_Fake_Forward_Vec(-25.0, angles, back_vec, npc_Vec);
/*
	float diameter = 10.0;
									
	int color[4];
	color[0]=255;
	color[1]=255;
	color[2]=255;
	color[3]=255;
	TE_SetupBeamPoints(npc_Vec, back_vec, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);
	TE_SendToAll();*/

	fl_spinning_angle[npc.index] +=15.0;

	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index]=0.0;

	float Range = 15.0;

	for(int i=0 ; i < SCHWERKRIEG_SWORDS_AMT ; i++)
	{
		float tempAngles[3], Direction[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = angles[1];
		tempAngles[2] = fl_spinning_angle[npc.index] + (float(i) * (360.0/SCHWERKRIEG_SWORDS_AMT));
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, Range);
		AddVectors(back_vec, Direction, EndLoc);

		int sword = EntRefToEntIndex(i_dance_of_light_sword_id[npc.index][i]);

		float Ang[3];

		EndLoc[2]+=10.0;

		MakeVectorFromPoints(EndLoc, npc_Vec, Ang);
		GetVectorAngles(Ang, Ang);	

		if(IsValidEntity(sword))
		{
			Schwertkrieg_Move_Entity(sword, EndLoc, Ang);
		}
	}
}
static void Schwert_Manipulate_Sword_Location(Karlas npc, float Loc[3], float Look_Vec[3], float GameTime, float spin_speed, bool damage=true, float dmg, bool boomerang = false)
{
	fl_spinning_angle[npc.index] +=spin_speed;

	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index]=0.0;

	float Range = 175.0;

	float Player_Pos[3]; Player_Pos = Loc;

	for(int i=0 ; i < SCHWERKRIEG_SWORDS_AMT ; i++)
	{
		float tempAngles[3], Direction[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = fl_spinning_angle[npc.index] + (float(i) * (360.0/SCHWERKRIEG_SWORDS_AMT));
		tempAngles[2] = 0.0;
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Range);
		AddVectors(Player_Pos, Direction, EndLoc);

		int sword = EntRefToEntIndex(i_dance_of_light_sword_id[npc.index][i]);

		float Ang[3];

		MakeVectorFromPoints(EndLoc, Look_Vec, Ang);
		GetVectorAngles(Ang, Ang);

		if(IsValidEntity(sword))
		{
			float Sword_Loc[3]; GetAbsOrigin(sword, Sword_Loc);

			Schwertkrieg_Move_Entity(sword, EndLoc, Ang);
			
			/*float diameter = 10.0;
									
			int color[4];
			color[0]=255;
			color[1]=255;
			color[2]=255;
			color[3]=255;
			TE_SetupBeamPoints(Player_Pos, Sword_Loc, g_Ruina_BEAM_Laser, 0, 0, 0, BOMBERZV2_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);

			TE_SendToAll();*/

			float Loc2[3];

			float Distance = 100.0;

			MakeVectorFromPoints(Look_Vec, EndLoc, Ang);
			GetVectorAngles(Ang, Ang);
			Get_Fake_Forward_Vec(Distance, Ang, Loc2, Sword_Loc);

			if(fl_dance_of_light_sword_throttle[npc.index][i] < GameTime && damage)
			{
				fl_dance_of_light_sword_throttle[npc.index][i] = GameTime+0.1;
				Schwertkrieg_Laser_Trace(npc, Sword_Loc, Loc2, 10.0, dmg, boomerang);
			}

			/*
			
			color[0]=75;
			color[1]=9;
			color[2]=145;
			color[3]=255;
			TE_SetupBeamPoints(Sword_Loc, Loc2, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);
											
			TE_SendToAll();*/
		}
	}
}
static void Schwertkrieg_Move_Entity(int entity, float loc[3], float Ang[3])
{
	if(IsValidEntity(entity))	
	{
		float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
		
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Entity_Loc);
		
		MakeVectorFromPoints(Entity_Loc, loc, vecView);
		GetVectorAngles(vecView, vecView);
		
		float dist = GetVectorDistance(Entity_Loc, loc);

		GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	
		Entity_Loc[0]+=vecFwd[0] * dist;
		Entity_Loc[1]+=vecFwd[1] * dist;
		Entity_Loc[2]+=vecFwd[2] * dist;
		
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecFwd);
		
		SubtractVectors(Entity_Loc, vecFwd, vecVel);
		ScaleVector(vecVel, 10.0);

		TeleportEntity(entity, NULL_VECTOR, Ang, vecVel);

		
	}
	//TeleportEntity(entity, loc, NULL_VECTOR, NULL_VECTOR);
	
}
static void Schwertkrieg_Laser_Trace(Karlas npc, float Start_Point[3], float End_Point[3], float Radius, float dps, bool boomerange)
{
	Zero(Schwertkrieg_BEAM_HitDetected);

	float hullMin[3], hullMax[3];
	hullMin[0] = -Radius;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(Start_Point, End_Point, hullMin, hullMax, 1073741824, Schwertkrieg_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	for (int victim = 0; victim < MAXENTITIES; victim++)
	{
		if (Schwertkrieg_BEAM_HitDetected[victim] && IsValidEnemy(npc.index, victim))
		{
			float playerPos[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

			float Dmg = dps;

			if(boomerange && IsValidClient(victim))
			{
				int weapon = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon))
				{
					float Bonus_damage = 1.0;
					char classname[32];
					GetEntityClassname(weapon, classname, 32);
				
					int weapon_slot = TF2_GetClassnameSlot(classname);
				
					if(weapon_slot == 2 && !i_IsWandWeapon[weapon])
					{
						Bonus_damage = 0.5;
					}
					Dmg *= Bonus_damage;
				}
			}

			SDKHooks_TakeDamage(victim, npc.index, npc.index, Dmg, DMG_PLASMA, -1, NULL_VECTOR, Start_Point);
				
			if(victim <= MaxClients)
				Client_Shake(victim, 0, 8.0, 8.0, 0.1);

			npc.Emit_Sword_Impact_Sound(playerPos);

		}
	}
}
public bool Schwertkrieg_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Schwertkrieg_BEAM_HitDetected[entity] = true;
	}
	return false;
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])	//Why On GODS EARTH DID I MAKE THE INPUT/OUTPUT IN THE WRONG ORDER, LIKE WHY/???????
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static int Create_Blade(float Loc[3], char size[10])
{
	int prop = CreateEntityByName("prop_physics_override");
	
	if (IsValidEntity(prop))
	{
	
		DispatchKeyValue(prop, "model", SCHWERTKRIEG_BLADE_MODEL);
		
		DispatchKeyValue(prop, "modelscale", size);
		
		DispatchKeyValue(prop, "solid", "0"); 
		
		DispatchSpawn(prop);
		
		ActivateEntity(prop);
		
		//SetEntProp(prop, Prop_Send, "m_fEffects", 32); //EF_NODRAW
		
		MakeObjectIntangeable(prop);

		TeleportEntity(prop, Loc, NULL_VECTOR, NULL_VECTOR);

		//CPrintToChatAll("Sword created: %i", prop);
		
		CClotBody npc = view_as<CClotBody>(prop);

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;

		SetVariantColor(view_as<int>({3, 244, 252, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return prop;
	}
	else
	{
		return -1;
	}
}

static void Delete_Swords(int client)
{
	for(int i=0 ; i < SCHWERKRIEG_SWORDS_AMT ; i++)
	{
		int sword = EntRefToEntIndex(i_dance_of_light_sword_id[client][i]);
		if(IsValidEntity(sword))
		{
			CClotBody npc = view_as<CClotBody>(sword);
			if(IsValidEntity(npc.m_iTeamGlow))
			{
				RemoveEntity(npc.m_iTeamGlow);
			}
			RemoveEntity(sword);
			//CPrintToChatAll("Removed sword: %i",sword );
		}
		i_dance_of_light_sword_id[client][i] = INVALID_ENT_REFERENCE;
	}
}

static void Internal_NPCDeath(int entity)
{
	Karlas npc = view_as<Karlas>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	int ally = npc.Ally;
	if(IsValidEntity(ally))
	{
		Stella donner = view_as<Stella>(ally);
		donner.Anger=true;
	}

	RaidModeTime +=50.0;

	int wave = i_current_wave[npc.index];
	if(wave!=60)
	{
		if(npc.Ally)
		{
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					CPrintToChatAll("{aqua}Stella{snow}: Hmph, Guess I'll handle this alone");
				}
				case 2:
				{
					CPrintToChatAll("{aqua}Stella{snow}: Ohohoh, this ain't over yet,{crimson} not even close to over{snow}...");
				}
				case 3:
				{
					CPrintToChatAll("{aqua}Stella{snow}: {crimson}KARLAS{snow} NOO,{crimson} ALL OF YOU WILL PAY WITH YOUR LIVES");
				}
			}
		}
	}
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

	ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
		
	Delete_Swords(npc.index);
	
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
			
	npc.m_bThisNpcIsABoss = false;

	Schwertkrieg_Delete_Wings(npc);
		
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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iParticles1))
		RemoveEntity(npc.m_iParticles1);

	int particle = EntRefToEntIndex(i_particle_effects[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_particle_effects[npc.index]=INVALID_ENT_REFERENCE;
	}
		
}
static Action Schwert_Timer_Move_Particle(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float end_point[3];
	end_point[0] = pack.ReadCell();
	end_point[1] = pack.ReadCell();
	end_point[2] = pack.ReadCell();
	float duration = pack.ReadCell();
	
	if(IsValidEntity(entity) && entity > MaxClients)
	{
		TeleportEntity(entity, end_point, NULL_VECTOR, NULL_VECTOR);
		if (duration > 0.0)
		{
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}
static void Schwert_Teleport_Effect(char type[255], float duration = 0.0, float start_point[3], float end_point[3])
{
	int part1 = CreateEntityByName("info_particle_system");
	if(IsValidEdict(part1))
	{
		TeleportEntity(part1, start_point, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(part1, "effect_name", type);
		SetVariantString("!activator");
		DispatchSpawn(part1);
		ActivateEntity(part1);
		AcceptEntityInput(part1, "Start");
		
		DataPack pack;
		CreateDataTimer(0.1, Schwert_Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}
#define SCHWERTKRIEG_PARTICLE_EFFECT_AMT 30
static int i_schwert_particle_index[MAXENTITIES][SCHWERTKRIEG_PARTICLE_EFFECT_AMT];

static void Schwertkrieg_Delete_Wings(Karlas npc)
{

	for(int i=0 ; i < SCHWERTKRIEG_PARTICLE_EFFECT_AMT ; i++)
	{
		int particle = EntRefToEntIndex(i_schwert_particle_index[npc.index][i]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		i_schwert_particle_index[npc.index][i]=INVALID_ENT_REFERENCE;
	}
}
//warp
static void Schwertkrieg_Create_Wings(Karlas npc)
{
	if(AtEdictLimit(EDICT_RAID))
		return;

	Schwertkrieg_Delete_Wings(npc);

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

	float core_loc[3] = {0.0, 20.0, -25.0};

	int particle_left_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/
	int particle_left_wing_1 = InfoTargetParentAt({15.5, 15.0, -15.0}, "", 0.0);	//middle upper
	int particle_left_wing_2 = InfoTargetParentAt({2.5, 20.0, -15.0}, "", 0.0);		//middle mid
	int particle_left_wing_6 = InfoTargetParentAt({18.5, 27.5, 5.0}, "", 0.0);		//middle lower
	
	int particle_left_wing_3 = InfoTargetParentAt({45.0, 35.0, -7.5}, "", 0.0);	//side upper		//raygun_projectile_blue_crit
	int particle_left_wing_4 = InfoTargetParentAt({40.0, 45.0, -7.5}, "", 0.0);	//side lower

	int particle_left_wing_5 = InfoTargetParentAt({25.5, 60.0, 15.0}, "", 0.0);	//lower left

	SetParent(particle_left_core, particle_left_wing_1, "",_, true);
	SetParent(particle_left_core, particle_left_wing_2, "",_, true);
	SetParent(particle_left_core, particle_left_wing_3, "",_, true);
	SetParent(particle_left_core, particle_left_wing_4, "",_, true);
	SetParent(particle_left_core, particle_left_wing_5, "",_, true);
	SetParent(particle_left_core, particle_left_wing_6, "",_, true);
	//SetParent(particle_left_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_left_core, flPos);
	SetEntPropVector(particle_left_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_left_core, "",_);

	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	int laser_left_wing_1 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);

	int laser_left_wing_2 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_left_wing_3 = ConnectWithBeamClient(particle_left_wing_3, particle_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_left_wing_4 = ConnectWithBeamClient(particle_left_wing_4, particle_left_wing_5, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_left_wing_5 = ConnectWithBeamClient(particle_left_wing_5, particle_left_wing_6, red, green, blue, end_1, start_1, amp, LASERBEAM);
	int laser_left_wing_6 = ConnectWithBeamClient(particle_left_wing_6, particle_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);


	i_schwert_particle_index[npc.index][0] = EntIndexToEntRef(ParticleOffsetMain);
	i_schwert_particle_index[npc.index][1] = EntIndexToEntRef(particle_left_core);
	i_schwert_particle_index[npc.index][2] = EntIndexToEntRef(particle_left_wing_1);
	i_schwert_particle_index[npc.index][3] = EntIndexToEntRef(particle_left_wing_2);
	i_schwert_particle_index[npc.index][4] = EntIndexToEntRef(particle_left_wing_3);
	i_schwert_particle_index[npc.index][5] = EntIndexToEntRef(particle_left_wing_4);
	i_schwert_particle_index[npc.index][6] = EntIndexToEntRef(particle_left_wing_5);
	i_schwert_particle_index[npc.index][7] = EntIndexToEntRef(particle_left_wing_6);

	i_schwert_particle_index[npc.index][8] = EntIndexToEntRef(laser_left_wing_1);
	i_schwert_particle_index[npc.index][9] = EntIndexToEntRef(laser_left_wing_2);
	i_schwert_particle_index[npc.index][10] = EntIndexToEntRef(laser_left_wing_2);
	i_schwert_particle_index[npc.index][11] = EntIndexToEntRef(laser_left_wing_3);
	i_schwert_particle_index[npc.index][12] = EntIndexToEntRef(laser_left_wing_4);
	i_schwert_particle_index[npc.index][13] = EntIndexToEntRef(laser_left_wing_5);
	i_schwert_particle_index[npc.index][14] = EntIndexToEntRef(laser_left_wing_6);

	//right

	
	int particle_right_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	

	int particle_right_wing_1 = InfoTargetParentAt({-15.5, 15.0, -15.0}, "", 0.0);	//middle upper
	int particle_right_wing_2 = InfoTargetParentAt({-2.5, 20.0, -15.0}, "", 0.0);		//middle mid
	int particle_right_wing_6 = InfoTargetParentAt({-18.5, 27.5, 5.0}, "", 0.0);		//middle lower
	
	int particle_right_wing_3 = InfoTargetParentAt({-45.0, 35.0, -7.5}, "", 0.0);	//side upper		//raygun_projectile_blue_crit
	int particle_right_wing_4 = InfoTargetParentAt({-40.0, 45.0, -7.5}, "", 0.0);	//side lower

	int particle_right_wing_5 = InfoTargetParentAt({-25.5, 60.0, 15.0}, "", 0.0);	//lower right

	SetParent(particle_right_core, particle_right_wing_1, "",_, true);
	SetParent(particle_right_core, particle_right_wing_2, "",_, true);
	SetParent(particle_right_core, particle_right_wing_3, "",_, true);
	SetParent(particle_right_core, particle_right_wing_4, "",_, true);
	SetParent(particle_right_core, particle_right_wing_5, "",_, true);
	SetParent(particle_right_core, particle_right_wing_6, "",_, true);
	//SetParent(particle_right_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_right_core, flPos);
	SetEntPropVector(particle_right_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_right_core, "",_);

	int laser_right_wing_1 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);

	int laser_right_wing_2 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_right_wing_3 = ConnectWithBeamClient(particle_right_wing_3, particle_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_right_wing_4 = ConnectWithBeamClient(particle_right_wing_4, particle_right_wing_5, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_right_wing_5 = ConnectWithBeamClient(particle_right_wing_5, particle_right_wing_6, red, green, blue, end_1, start_1, amp, LASERBEAM);
	int laser_right_wing_6 = ConnectWithBeamClient(particle_right_wing_6, particle_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);


	i_schwert_particle_index[npc.index][15] = EntIndexToEntRef(particle_right_core);
	i_schwert_particle_index[npc.index][16] = EntIndexToEntRef(particle_right_wing_1);
	i_schwert_particle_index[npc.index][17] = EntIndexToEntRef(particle_right_wing_2);
	i_schwert_particle_index[npc.index][18] = EntIndexToEntRef(particle_right_wing_3);
	i_schwert_particle_index[npc.index][19] = EntIndexToEntRef(particle_right_wing_4);
	i_schwert_particle_index[npc.index][20] = EntIndexToEntRef(particle_right_wing_5);
	i_schwert_particle_index[npc.index][21] = EntIndexToEntRef(particle_right_wing_6);

	i_schwert_particle_index[npc.index][22] = EntIndexToEntRef(laser_right_wing_1);
	i_schwert_particle_index[npc.index][23] = EntIndexToEntRef(laser_right_wing_2);
	i_schwert_particle_index[npc.index][24] = EntIndexToEntRef(laser_right_wing_2);
	i_schwert_particle_index[npc.index][25] = EntIndexToEntRef(laser_right_wing_3);
	i_schwert_particle_index[npc.index][26] = EntIndexToEntRef(laser_right_wing_4);
	i_schwert_particle_index[npc.index][27] = EntIndexToEntRef(laser_right_wing_5);
	i_schwert_particle_index[npc.index][28] = EntIndexToEntRef(laser_right_wing_6);

}

static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}