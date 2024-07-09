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



#define SCHWERT_TELEPORT_STRIKE_INTIALIZE		"misc/halloween/gotohell.wav"
#define SCHWERT_TELEPORT_STRIKE_LOOPS 			"weapons/vaccinator_charge_tier_03.wav"
#define SCHWERT_TELEPORT_STRIKE_EXPLOSION		"misc/halloween/spell_mirv_explode_primary.wav"

#define SCHWERTKRIEG_LIGHT_MODEL "models/effects/vol_light256x512.mdl"
#define SCHWERTKRIEG_BLADE_MODEL "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl"

#define SCHWERT_BALL_MODEL "models/weapons/w_models/w_drg_ball.mdl"

static float fl_schwert_speed;

//Logic for duo raidboss

static int i_ally_index;
static int LaserIndex;
static int BeamLaser;
static float fl_focus_timer[MAXENTITIES];
static bool b_swords_created[MAXENTITIES];

static bool b_angered_twice[MAXENTITIES];
static float fl_retreat_timer[MAXENTITIES];
static bool Schwertkrieg_BEAM_HitDetected[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_schwert_armour[MAXENTITIES][2];
static float fl_schwert_sword_battery[MAXENTITIES];

static float fl_groupteleport_timer[MAXENTITIES];


#define SCHWERKRIEG_SWORDS_AMT 7	

#define TELEPORT_STRIKE_TELEPORT		"weapons/bison_main_shot.wav"
#define TELEPORT_STRIKE_HIT				"vo/taunts/medic/medic_taunt_kill_22.mp3"
#define TELEPORT_STRIKE_MISS			"vo/medic_negativevocalization04.mp3"

static int i_dance_of_light_sword_id[MAXENTITIES][SCHWERKRIEG_SWORDS_AMT];
static float fl_dance_of_light_sword_throttle[MAXENTITIES][SCHWERKRIEG_SWORDS_AMT];
static float fl_dance_of_light_sound_spam_timer[MAXENTITIES];
static bool b_swords_flying[MAXENTITIES];
static int Projectile_Index[MAXENTITIES];
static int i_ProjectileIndex;


void Raidboss_Schwertkrieg_OnMapStart_NPC()
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

	PrecacheSound(SCHWERT_TELEPORT_STRIKE_INTIALIZE, true);
	PrecacheSound(SCHWERT_TELEPORT_STRIKE_LOOPS, true);
	PrecacheSound(SCHWERT_TELEPORT_STRIKE_EXPLOSION, true);

	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	BeamLaser = PrecacheModel("materials/sprites/laser.vmt", true);

	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);

	i_ProjectileIndex = PrecacheModel(SCHWERT_BALL_MODEL);

	
	PrecacheSound("mvm/mvm_tele_deliver.wav", true);
	PrecacheSound("mvm/mvm_tele_activate.wav", true);

	Zero(fl_focus_timer);
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
	Zero(b_swords_flying);
	Zero(fl_groupteleport_timer);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Karlas");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_schwertkrieg");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float RaidModeScaling;
static any ClotSummon(int client, const float vecPos[3], const float vecAng[3], int team)
{
	return Raidboss_Schwertkrieg(client, vecPos, vecAng, team);
}
static int i_schwert_hand_particle[MAXENTITIES];

static Action RepeatSound_Doublevoice(Handle timer, DataPack pack)
{
	pack.Reset();
	char sound[128];
	pack.ReadString(sound, 128);
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		EmitSoundToAll(sound, entity, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	return Plugin_Handled; 
}
methodmap Raidboss_Schwertkrieg < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
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
	public void PlayTeleportSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_TeleportSounds) - 1);
		EmitSoundToAll(g_TeleportSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		DataPack pack;
		CreateDataTimer(0.1, RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
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
	
	
	
	public Raidboss_Schwertkrieg(int client, const float vecPos[3], const float vecAng[3], int ally)
	{
		Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		fl_focus_timer[npc.index]=0.0;

		b_angered_twice[npc.index]=false;
		fl_teleport_strike_recharge[npc.index] = GetGameTime()+25.0;
		b_teleport_strike_active[npc.index]=false;

		fl_groupteleport_timer[npc.index]= GetGameTime() + 30.0;

		fl_dance_of_light_sound_spam_timer[npc.index] = 0.0;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//RaidModeTime = GetGameTime(npc.index) + 250.0;

		npc.m_flNextChargeSpecialAttack = 0.0;	//used for transformation Logic
		b_swords_created[npc.index]=false;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;

		fl_schwert_sword_battery[npc.index]=0.0;
		npc.m_flNextRangedBarrage_Singular = 0.0;
			
		
		//IDLE
		fl_schwert_speed = 330.0;
		npc.m_flSpeed =330.0;

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

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

		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
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

		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
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
		
		npc.StartPathing();

		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_schwert_hand_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("root", flPos, flAng);

		fl_schwert_armour[npc.index][0] = 1.0;	//ranged
		fl_schwert_armour[npc.index][1] = 1.5;	//melee
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");

		b_swords_flying[npc.index]=false;
		npc.Anger = false;


		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		Schwertkrieg_Create_Wings(npc);
		Schwert_Impact_Lance_Create(npc.index);

		Delete_Swords(npc.index);

		for(int i=0 ; i < SCHWERKRIEG_SWORDS_AMT ; i++)
		{
			i_dance_of_light_sword_id[npc.index][i] = INVALID_ENT_REFERENCE;
		}
		
		
		return npc;
	}
}

public void Schwertkrieg_Set_Ally_Index(int ref)
{	
	i_ally_index = EntIndexToEntRef(ref);
}
//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(iNPC);
	
	if(!b_raidboss_donnerkrieg_alive)	//While This I do need
		Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(false);	//donner first, schwert second


	float GameTime = GetGameTime(npc.index);

	//if(RaidModeTime < GetGameTime())
	//{
	//	SDKUnhook(npc.index, SDKHook_Think, Raidboss_Schwertkrieg_ClotThink);
	//	return;
	//}

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

	/*if(fl_divine_intervention_active > GetGameTime() && !b_teleport_strike_active[npc.index])
	{
		int Ally = EntRefToEntIndex(i_ally_index);
		if(IsValidAlly(npc.index, Ally))
		{
			npc.SetGoalEntity(npc.index, Ally);
			return;
		}
		else
		{
			CPrintToChatAll("Something CATASTROPHIC HAPPENED, OH GOD");
		}	
	}*/

	if(schwert_retreat && Schwert_Status(npc, GameTime)==1 && b_teleport_strike_active[npc.index])
	{
		npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1];
		npc.m_flRangedArmor = fl_schwert_armour[npc.index][0];
		npc.m_flSpeed =fl_schwert_speed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);
		Schwert_Impact_Lance_Create(npc.index);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0; 
	}

	if(npc.m_flGetClosestTargetTime < GameTime && !schwert_retreat)
	{
		if(IsValidAlly(npc.index, EntRefToEntIndex(i_ally_index)))	//schwert will always prefer attacking enemies who are near donnerkrieg.
		{
			npc.m_iTarget = GetClosestTarget(EntRefToEntIndex(i_ally_index),_,_,_,_,_,_,true);
			if(npc.m_iTarget < 1)
			{
				npc.m_iTarget = GetClosestTarget(EntRefToEntIndex(i_ally_index));
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		
	}	
	/*
	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

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
	*/
	if(Schwert_Status(npc, GetGameTime())==0)	//we are in the process of transforming, do stuff. also using a sepereate game time so special effects don't affect the transforming stuff.
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

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flSpeed=fl_schwert_speed;

		

		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);

		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);
		
	}
		
	
	int PrimaryThreatIndex = npc.m_iTarget;

	int Ally =-1;

	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			if(npc.m_bAllowBackWalking)
				npc.m_bAllowBackWalking=false;
		}
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed;
		npc.StopPathing();
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		return;
	}
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float npc_Vec[3]; WorldSpaceCenter(npc.index, npc_Vec);

	float flDistanceToTarget = GetVectorDistance(vecTarget, npc_Vec, true);

	int Blade_Behavior=-1;

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

		if(schwert_retreat)	//he can only ever use the blades defensively when helping donner
		{
			Blade_Behavior=1;
		}
		if(b_swords_flying[npc.index] && npc.m_flNextRangedBarrage_Spam < GameTime)
		{
			npc.m_flNextRangedBarrage_Spam = GameTime + 35.0;
		}

		if(npc.m_flNextRangedBarrage_Spam < GameTime && flDistanceToTarget < (900.0*900.0) && !b_swords_flying[npc.index])
		{
			npc.m_flNextRangedBarrage_Spam = GameTime + 35.0;

			Schwert_Launch_Boomerang_Core(npc, PrimaryThreatIndex);

			b_swords_flying[npc.index]=true;
		}

		if(fl_schwert_sword_battery[npc.index]<GameTime && !schwert_retreat)
		{
			Blade_Behavior=4;
		}

		if(b_swords_flying[npc.index])
		{
			Blade_Behavior=3;
		}
	}
	if(npc.m_flNextRangedBarrage_Singular < GetGameTime())
	{
		Ally = EntRefToEntIndex(i_ally_index);
		if(IsValidAlly(npc.index, Ally))
		{
		//	SetEntProp(npc.index, Prop_Data, "m_iHealth", (GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2));
			
			int AllyMaxHealth = GetEntProp(Ally, Prop_Data, "m_iMaxHealth");
			int AllyHealth = GetEntProp(Ally, Prop_Data, "m_iHealth");
			int SchwertMaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			int SchwertHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");

			if(SchwertHealth > (SchwertMaxHealth / 2) && AllyHealth < (AllyMaxHealth / 4))
			{
				float vecAlly[3];
				float vecMe[3];
				WorldSpaceCenter(Ally, vecAlly);
				WorldSpaceCenter(npc.index, vecMe);

				float flDistanceToAlly = GetVectorDistance(vecAlly, vecMe, true);
				Schwert_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget, true);	//warp
				
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

					npc.m_flNextRangedBarrage_Singular = GetGameTime(Ally) + 45.0;

					npc.PlayBuffSound();
				}	
			}
		}
	}
	if(schwert_retreat)
	{
		Ally = EntRefToEntIndex(i_ally_index);
		if(IsValidAlly(npc.index, Ally))
		{
			float vecAlly[3]; WorldSpaceCenter(Ally, vecAlly);

			float flDistanceToAlly = GetVectorDistance(vecAlly, npc_Vec, true);
			Schwert_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget);

			//Schwert_Teleport_Core(npc, PrimaryThreatIndex);
		}
	}
	else
	{
		if(fl_groupteleport_timer[npc.index] < GameTime && !b_teleport_strike_active[npc.index])
		{
			Ally = EntRefToEntIndex(i_ally_index);
			if(IsValidAlly(npc.index, Ally))
			{
				float vecAlly[3]; WorldSpaceCenter(Ally, vecAlly);

				float flDistanceToAlly = GetVectorDistance(vecAlly, npc_Vec, true);
				Schwert_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget, true);	//warp

				if(flDistanceToAlly < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0)
				{
					Raidboss_Donnerkrieg donner = view_as<Raidboss_Donnerkrieg>(Ally);
					int target_new = GetClosestTarget(donner.index);
					bool tele=false;

					if(IsValidEnemy(npc.index, target_new))
					{
						int enemy = Can_I_See_Enemy(donner.index, target_new);
						if(IsValidEnemy(npc.index, enemy))
						{
							tele = Schwert_Do_Group_Tele(npc.index, target_new);
							if(tele)
								Schwert_Do_Group_Tele(donner.index, target_new);
						}
					}
					else 
					{
						int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
						if(IsValidEnemy(npc.index, enemy))
						{
							tele = Schwert_Do_Group_Tele(npc.index, PrimaryThreatIndex);
							if(tele)
								Schwert_Do_Group_Tele(donner.index, PrimaryThreatIndex);
						}
					}
					if(tele)
					{
						npc.PlayTeleportSound();
					}
					if(tele)
					{
						fl_groupteleport_timer[npc.index] = GameTime + 75.0;
					}
					else
					{
						fl_groupteleport_timer[npc.index] = GameTime + 10.0;
					}
						
				}
			}
			else
			{
				fl_groupteleport_timer[npc.index] = FAR_FUTURE;
			}
		}
		else
		{
			if(Schwert_Status(npc, GameTime)!=1)
				npc.m_flSpeed =  fl_schwert_speed;
				
			Schwert_Movement(npc, flDistanceToTarget, PrimaryThreatIndex);

			Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex, GameTime, flDistanceToTarget, vecTarget);

			//Schwert_Teleport_Core(npc, PrimaryThreatIndex);
		}
	}

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

	npc.PlayIdleAlertSound();
}
static int Schwert_Status(Raidboss_Schwertkrieg npc, float GameTime)
{
	if(npc.m_flNextChargeSpecialAttack > GameTime)	//we are transforming
		return 0;

	if(npc.m_flDoingAnimation > GameTime)	//we are doing an animation.
		return 1;

	return -1;

}
static void Schwert_Aggresive_Behavior(Raidboss_Schwertkrieg npc, int PrimaryThreatIndex, float GameTime, float flDistanceToTarget, float vecTarget[3])
{

	if(npc.m_bAllowBackWalking)
	{
		npc.FaceTowards(vecTarget, 20000.0);
	}
	else
	{
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed;
	}
		

	if(fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime))
	{
		npc.m_bAllowBackWalking=true;
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
		npc.SetGoalVector(vBackoffPos, true);

		npc.FaceTowards(vecTarget, 20000.0);

		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed*0.75;
	}
	else
	{
		npc.m_bAllowBackWalking=false;
	}

	npc.StartPathing();
	npc.m_bPathing = true;

	
	Schwertkrieg_Teleport_Strike(npc, flDistanceToTarget, GameTime, PrimaryThreatIndex);
	
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
						float meleedmg= 50.0*RaidModeScaling;	//schwert hurts like a fucking truck

						if(npc.Anger)
							meleedmg*1.25;

						if(fl_schwert_sword_battery[npc.index]> GameTime)
						{
							if(npc.Anger)
								fl_schwert_sword_battery[npc.index] +=2.0;
							else
								fl_schwert_sword_battery[npc.index] +=1.0;
						}
						
						if(!ShouldNpcDealBonusDamage(target))
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

							SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
						}
						else
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg * 5, DMG_CLUB, -1, _, vecHit);
						}
						
						if(IsValidClient(target))
						{
							Custom_Knockback(npc.index, target, 900.0, true);
							TF2_AddCondition(target, TFCond_LostFooting, 0.5);
							TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
						}
						
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
static void Schwertkrieg_Teleport_Strike(Raidboss_Schwertkrieg npc, float flDistanceToTarget, float GameTime, int PrimaryThreatIndex)
{
	if(schwert_retreat)
		return;
		
	bool can_see=false;
	bool touching_creep = true;
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

			npc.AddActivityViaSequence("taunt_neck_snap_medic");

			Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);

			float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc);

			EmitSoundToAll(SCHWERT_TELEPORT_STRIKE_INTIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);
			EmitSoundToAll(SCHWERT_TELEPORT_STRIKE_INTIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);

			npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1]-1.0;
			npc.m_flRangedArmor = fl_schwert_armour[npc.index][0]-0.5;

			npc_Loc[2]+=10.0;
			int r, g, b, a;
			a = 175;
			r = 255;
			g = 50;
			b = 50;

			spawnRing_Vectors(npc_Loc, 250.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 2.0, 12.0, 2.0, 1, 1.0);

		}
	}
	if(b_teleport_strike_active[npc.index] && npc.m_flDoingAnimation < GameTime)
	{
		npc.m_flMeleeArmor = fl_schwert_armour[npc.index][1];
		npc.m_flRangedArmor = fl_schwert_armour[npc.index][0];
		npc.m_flSpeed =fl_schwert_speed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);
		Schwert_Impact_Lance_Create(npc.index);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0;

		if(fl_groupteleport_timer[npc.index]>GameTime)
			fl_groupteleport_timer[npc.index] += 25.0;

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
static bool Schwert_Do_Group_Tele(int iNPC, int PrimaryThreatIndex)
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
	if(Schwert_Teleport(iNPC, vecSwingEnd, 0.0))
	{
		return true;
	}
	else
	{
		vecSwingEnd[0] = vecPos[0] - VecForward[0] * (-100);
		vecSwingEnd[1] = vecPos[1] - VecForward[1] * (-100);
		vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/
		if(Schwert_Teleport(iNPC, vecSwingEnd, 0.0))
		{
			return true;
		}
	}
	return false;
}
#define SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS 750.0

static void Schwertkrieg_Teleport_Boom(Raidboss_Schwertkrieg npc, float Location[3])
{
	float Boom_Time = 5.0;

	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Location);

	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	


	int color[4];
	color[3] = 175;

	color[0] = 255;
	color[1] = 50;
	color[2] = 50;

	TE_SetupBeamRingPoint(Location, radius*2.0, 0.0, LaserIndex, LaserIndex, 0, 1, Boom_Time, 15.0, 1.0, color, 1, 0);

	

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
	int color[4];
	color[3] = 175;

	color[0] = 255;
	color[1] = 50;
	color[2] = 50;
	

	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	
	
	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, 0.0, LaserIndex, LaserIndex, 0, 1, 1.0, 15.0, 0.1, color, 1, 0);
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
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);

	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = 200.0*RaidModeScaling;	//very deadly!
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	int color[4];
	color[3] = 175;
	int loop_for = 15;		//15
	float height = 1500.0;	//1500
	float sky_loc[3]; sky_loc = spawnLoc; sky_loc[2]+=height;

	color[0] = 255;
	color[1] = 50;
	color[2] = 50;
	

	if(npc.Anger)
	{
		radius *= 2.0;	
		damage *=2.0;
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

	TE_SetupBeamRingPoint(spawnLoc, 1.0, radius*2.0, LaserIndex, LaserIndex, 0, 1, 1.0, 15.0, 1.0, color, 1, 0);
	TE_SendToAll();

	float start = 15.0;
	float end = 15.0;
	TE_SetupBeamPoints(spawnLoc, sky_loc, BeamLaser, 0, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
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
		TE_SetupBeamRingPoint(spawnLoc, 0.0, final_radius, LaserIndex, LaserIndex, 0, 1, timer, thicc, 0.1, color, 1, 0);

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
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
		Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false);
	
		if(Succeed)
		{
			
			float effect_duration = 0.25;
			
			
			end_offset = vecTarget;
			
			start_offset[2]-= 25.0;
			end_offset[2] -= 25.0;
			
			for(int help=1 ; help<=8 ; help++)
			{	
				Schwert_Teleport_Effect(RUINA_BALL_PARTICLE_BLUE, effect_duration, start_offset, end_offset);
				
				start_offset[2] += 12.5;
				end_offset[2] += 12.5;
			}
		}
	}
	return Succeed;
}
static void Schwert_Movement(Raidboss_Schwertkrieg npc, float flDistanceToTarget, int target)
{	
	npc.StartPathing();
	npc.m_bPathing = true;
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
								
		npc.SetGoalVector(vPredictedPos);
	} 
	else 
	{
		npc.SetGoalEntity(target);
	}
}
static void Schwert_Movement_Ally_Movement(Raidboss_Schwertkrieg npc, float flDistanceToAlly, int ally, float GameTime, int PrimaryThreatIndex_Schwert, float flDistanceToTarget_Schwert, bool block_defense=false)
{	
	if(npc.m_bAllowBackWalking)
		npc.m_bAllowBackWalking=false;
		
	npc.StartPathing();
	npc.m_bPathing = true;
	
	
	if(flDistanceToTarget_Schwert < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25)
	{
		Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
		float enemy_vec[3];
		WorldSpaceCenter(PrimaryThreatIndex_Schwert, enemy_vec);
		Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, enemy_vec);
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed;
		return;
	}
	Raidboss_Donnerkrieg donner = view_as<Raidboss_Donnerkrieg>(ally);
	
	if(block_defense)
	{
		npc.SetGoalEntity(donner.index);
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed*2.0;
		return;
	}	
	if(flDistanceToAlly < (1500.0*1500.0))	//stay within a 1500 radius of donner
	{
		float self_vec[3];
		WorldSpaceCenter(npc.index, self_vec);
		int target_new = GetClosestTarget(donner.index);
		if(IsValidEnemy(npc.index, target_new))
		{
			float Ally_Vec[3]; WorldSpaceCenter(donner.index, Ally_Vec);
			float Vec_Target[3]; WorldSpaceCenter(target_new, Vec_Target);
			float flDistanceToTarget = GetVectorDistance(Ally_Vec, Vec_Target, true);
			if(flDistanceToTarget < (500.0*500.0))	//they are to close to my beloved, *Kill them*
			{

				flDistanceToTarget = GetVectorDistance(self_vec, Vec_Target, true);
				Schwert_Movement(npc, flDistanceToTarget, target_new);
				Schwert_Aggresive_Behavior(npc, target_new, GameTime, flDistanceToTarget, Vec_Target);
				if(Schwert_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_schwert_speed*2.0;
			}
			else
			{
				Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
				float enemy_vec[3];
				WorldSpaceCenter(PrimaryThreatIndex_Schwert, enemy_vec);
				Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, enemy_vec);
				if(Schwert_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_schwert_speed;
			}
		}
		else
		{
			Schwert_Movement(npc, flDistanceToTarget_Schwert, PrimaryThreatIndex_Schwert);
			float enemy_vec[3];
			WorldSpaceCenter(PrimaryThreatIndex_Schwert, enemy_vec);
			Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex_Schwert, GameTime, flDistanceToTarget_Schwert, enemy_vec);
			if(Schwert_Status(npc, GameTime)!=1)
				npc.m_flSpeed =  fl_schwert_speed;
		}
	} 
	else 
	{
		npc.SetGoalEntity(donner.index);
		if(Schwert_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_schwert_speed*2.0;
	}
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

	if(npc.m_flNextChargeSpecialAttack > GetGameTime())
	{
		damage=0.0;
		//CPrintToChatAll("Damage nulified");
		return Plugin_Changed;
	}


	if(!b_angered_twice[npc.index] && Health/MaxHealth<=0.8 && !b_teleport_strike_active[npc.index])
	{
		b_angered_twice[npc.index]=true;

		npc.m_flNextChargeSpecialAttack = GetGameTime()+8.0;

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

static void Schwert_Lifeloss_Initialize(Raidboss_Schwertkrieg npc)
{
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	npc.m_iWearable7 = npc.EquipItemSeperate("head", SCHWERTKRIEG_LIGHT_MODEL ,_,_,_,300.0);
	
}
static void Schwert_Lifeloss_Logic(Raidboss_Schwertkrieg npc)
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
static void Schwert_SwordWings_Logic(Raidboss_Schwertkrieg npc, float npc_Vec[3])
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
	TE_SetupBeamPoints(npc_Vec, back_vec, BeamLaser, 0, 0, 0, DONNERKRIEG_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);
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
static void Schwert_Manipulate_Sword_Location(Raidboss_Schwertkrieg npc, float Loc[3], float Look_Vec[3], float GameTime, float spin_speed, bool damage=true, float dmg)
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
			float Sword_Loc[3]; GetAbsOrigin(sword,Sword_Loc);

			Schwertkrieg_Move_Entity(sword, EndLoc, Ang);
			
			/*float diameter = 10.0;
									
			int color[4];
			color[0]=255;
			color[1]=255;
			color[2]=255;
			color[3]=255;
			TE_SetupBeamPoints(Player_Pos, Sword_Loc, BeamLaser, 0, 0, 0, BOMBERZV2_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);

			TE_SendToAll();*/

			float Loc2[3];

			float Distance = 100.0;

			MakeVectorFromPoints(Look_Vec, EndLoc, Ang);
			GetVectorAngles(Ang, Ang);
			Get_Fake_Forward_Vec(Distance, Ang, Loc2, Sword_Loc);

			if(fl_dance_of_light_sword_throttle[npc.index][i] < GameTime && damage)
			{
				fl_dance_of_light_sword_throttle[npc.index][i] = GameTime+0.1;
				Schwertkrieg_Laser_Trace(npc, Sword_Loc, Loc2, 10.0, dmg);
			}

			/*
			
			color[0]=75;
			color[1]=9;
			color[2]=145;
			color[3]=255;
			TE_SetupBeamPoints(Sword_Loc, Loc2, BeamLaser, 0, 0, 0, DONNERKRIEG_TE_DURATION, diameter, diameter, 0, 0.1, color, 3);
											
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
static void Schwertkrieg_Laser_Trace(Raidboss_Schwertkrieg npc, float Start_Point[3], float End_Point[3], float Radius, float dps)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		Schwertkrieg_BEAM_HitDetected[i] = false;
	}

	float hullMin[3], hullMax[3];
	hullMin[0] = -Radius;
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	Handle trace = TR_TraceHullFilterEx(Start_Point, End_Point, hullMin, hullMax, 1073741824, Schwertkrieg_BEAM_TraceUsers);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	for (int victim = 0; victim < MAXTF2PLAYERS; victim++)
	{
		if (Schwertkrieg_BEAM_HitDetected[victim] && GetTeam(npc.index) != GetTeam(victim))
		{
			float playerPos[3];
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);

			float Dmg = dps;

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
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	int ally = EntRefToEntIndex(i_ally_index);
	if(IsValidEntity(ally))
	{
		Raidboss_Donnerkrieg donner = view_as<Raidboss_Donnerkrieg>(ally);
		b_force_heavens_light[ally]=true;	//force heavens Light!
		donner.Anger=true;
	}

	//RaidModeTime +=50.0;

	int wave = 45;
	if(wave<60 && !b_donner_said_win_line)
	{
		if(b_raidboss_donnerkrieg_alive)
		{
			switch(GetRandomInt(1,2))	//warp
			{
				case 1:
				{
					CPrintToChatAll("{aqua}Donnerkrieg{snow}: Hmph, Guess I'll handle this alone");
				}
				case 2:
				{
					CPrintToChatAll("{aqua}Donnerkrieg{snow}: Ohohoh, this ain't over yet,{crimson} not even close to over{snow}...");
				}
			}
		}
	}
	float self_vec[3]; WorldSpaceCenter(npc.index, self_vec);

	ParticleEffectAt(self_vec, "teleported_red", 0.5);

	if(IsValidEntity(Projectile_Index[npc.index]))
	{
		SDKUnhook(npc.index, SDKHook_Think, Schwert_Spiral_Core_Projectile_Homing_Hook);
		RemoveEntity(Projectile_Index[npc.index]);
	}
	
		
	Delete_Swords(npc.index);
			
	npc.m_bThisNpcIsABoss = false;

	Schwertkrieg_Delete_Wings(npc);
	Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);
		
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

	int particle = EntRefToEntIndex(i_schwert_hand_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_schwert_hand_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
		
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
		CreateDataTimer(0.1, Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}
#define SCHWERTKRIEG_PARTICLE_EFFECT_AMT 30
static int i_schwert_particle_index[MAXENTITIES][SCHWERTKRIEG_PARTICLE_EFFECT_AMT];

static void Schwertkrieg_Delete_Wings(Raidboss_Schwertkrieg npc)
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

static void Schwertkrieg_Create_Wings(Raidboss_Schwertkrieg npc)
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

#define SCHWERTKRIEG_LANCE_EFFECTS 25

static int i_Schwert_Impact_Lance_CosmeticEffect[MAXENTITIES][SCHWERTKRIEG_LANCE_EFFECTS];

static void Schwert_Impact_Lance_CosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<SCHWERTKRIEG_LANCE_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_Schwert_Impact_Lance_CosmeticEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_Schwert_Impact_Lance_CosmeticEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}

static void Schwert_Impact_Lance_Create(int client, char[] attachment = "effect_hand_r")
{

	if(AtEdictLimit(EDICT_RAID))
		return;

	Schwert_Impact_Lance_CosmeticRemoveEffects(client);

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 7.5}, "", 0.0); //First offset we go by
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -7.5}, "", 0.0);

	int particle_3 = InfoTargetParentAt({5.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = InfoTargetParentAt({-5.0,10.0,0.0}, "", 0.0);

	int particle_4 = InfoTargetParentAt({0.0,70.0,2.5}, "", 0.0);
	int particle_4_1 = InfoTargetParentAt({0.0,70.0, -2.5}, "", 0.0);

	int particle_5 = InfoTargetParentAt({0.0,-10.0, 5.0}, "", 0.0);
	int particle_5_1 = InfoTargetParentAt({0.0,-10.0, -5.0}, "", 0.0);

	int particle_6 = InfoTargetParentAt({12.0,-5.0, 0.0}, "", 0.0);
	int particle_6_1 = InfoTargetParentAt({-12.0,-5.0, 0.0}, "", 0.0);

	int particle_7 = InfoTargetParentAt({0.0,-10.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_1, particle_5_1, "",_, true);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_1, particle_6_1, "",_, true);
	SetParent(particle_1, particle_7, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//blade
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);		//blade

	int Laser_7 = ConnectWithBeamClient(particle_2, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM );			//inner blade
	int Laser_8 = ConnectWithBeamClient(particle_2_1, particle_5_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM );	//	inner blade

	int Laser_9 = ConnectWithBeamClient(particle_6, particle_3, red, green, blue, blade_end, handguard_size, amp, LASERBEAM );			//wing start
	int Laser_10 = ConnectWithBeamClient(particle_6_1, particle_3_1, red, green, blue, blade_end, handguard_size, amp, LASERBEAM );		//wing start
	int Laser_11 = ConnectWithBeamClient(particle_6, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM );			//wing end
	int Laser_12 = ConnectWithBeamClient(particle_6_1, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM );			//wing end
	

	i_Schwert_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Schwert_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Schwert_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Schwert_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Schwert_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Schwert_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Schwert_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_5);
	i_Schwert_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_6);
	i_Schwert_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(particle_4_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(particle_5);
	i_Schwert_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_7);
	i_Schwert_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_8);
	i_Schwert_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(particle_5_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(Laser_9);
	i_Schwert_Impact_Lance_CosmeticEffect[client][18] = EntIndexToEntRef(Laser_10);
	i_Schwert_Impact_Lance_CosmeticEffect[client][19] = EntIndexToEntRef(Laser_11);
	i_Schwert_Impact_Lance_CosmeticEffect[client][20] = EntIndexToEntRef(Laser_12);
	i_Schwert_Impact_Lance_CosmeticEffect[client][21] = EntIndexToEntRef(particle_7);
	i_Schwert_Impact_Lance_CosmeticEffect[client][22] = EntIndexToEntRef(particle_6);
	i_Schwert_Impact_Lance_CosmeticEffect[client][23] = EntIndexToEntRef(particle_6_1);

}


static int RMR_CurrentHomingTarget[MAXENTITIES];
static bool RWI_WasLockedOnce[MAXENTITIES];
static float RWI_RocketSpeed[MAXENTITIES];

static float RWI_RocketRotation[MAXENTITIES][3];

static float fl_boomerang_duration[MAXENTITIES];


static float fl_homing_throttle[MAXENTITIES];
static float fl_retract_timer[MAXENTITIES];
/*
 *	I just stole this off "homing_projectile_logic.sp" and heavily modified it 
 **/
static void Schwert_Launch_Boomerang_Core(Raidboss_Schwertkrieg npc, int initialTarget)	//warp
{

	float rocket_speed = 750.0;
	float Target_Loc[3];
	GetAbsOrigin(initialTarget, Target_Loc);
	int projectile = Schwert_Create_Invis_Proj(npc, rocket_speed, Target_Loc);
	
	if(!IsValidEntity(projectile))
		return;

	if(npc.Anger)
		fl_boomerang_duration[projectile] = GetGameTime() + 17.0;
	else
		fl_boomerang_duration[projectile] = GetGameTime() + 12.5;

	float Npc_Vec[3], Target_Vec[3];
	GetAbsOrigin(npc.index, Npc_Vec);
	GetAbsOrigin(initialTarget, Target_Vec);

	fl_homing_throttle[projectile]=0.0;
	float Ang[3];
	MakeVectorFromPoints(Npc_Vec, Target_Vec, Ang);
	GetVectorAngles(Ang, Ang);	

	float Deviation = 65.0;

	fl_retract_timer[projectile] = GetGameTime()+2.5;

	switch(GetRandomInt(1,2))
	{
		case 1:
		{
			Ang[1]-=Deviation;
		}
		case 2:
		{
			Ang[1]+=Deviation;
		}
	}
	
	Projectile_Index[npc.index] = projectile;
	RWI_WasLockedOnce[projectile] = false;
	if(initialTarget != -1)
		RWI_WasLockedOnce[projectile] = true;
		
	RMR_CurrentHomingTarget[projectile] = initialTarget;

	RWI_RocketRotation[projectile][0] = Ang[0];
	RWI_RocketRotation[projectile][1] = Ang[1];
	RWI_RocketRotation[projectile][2] = Ang[2];

	
	
	RWI_RocketSpeed[projectile] = rocket_speed;

	SDKUnhook(npc.index, SDKHook_Think, Schwert_Spiral_Core_Projectile_Homing_Hook);

	SDKHook(npc.index, SDKHook_Think, Schwert_Spiral_Core_Projectile_Homing_Hook);

}

static int Schwert_Create_Invis_Proj(Raidboss_Schwertkrieg npc, float rocket_speed, float vecTarget[3])
{
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
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetTeam(entity, GetTeam(npc.index));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
										
		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);

		DispatchKeyValue(entity, "solid", "0"); 

		DispatchSpawn(entity);
		
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", i_ProjectileIndex, _, i);
		}
		SetEntityModel(entity, SCHWERT_BALL_MODEL);

		//Make it entirely invis. Shouldnt even render these 8 polygons.
		SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);

		SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
		SetEntityRenderColor(entity, 255, 255, 255, 0);


		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		MakeObjectIntangeable(entity);

		SetEntityMoveType(entity, MOVETYPE_NOCLIP);

		return entity;
	}
	b_swords_flying[npc.index]=false;
	return -1;
}
static Action Schwert_Spiral_Core_Projectile_Homing_Hook(int iNPC)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(iNPC);

	int entity = Projectile_Index[npc.index];

	//CPrintToChatAll("beep");
	if(!IsValidEntity(entity)) //no need for converting.
	{
		b_swords_flying[npc.index]=false;
		RemoveEntity(entity);
		SDKUnhook(npc.index, SDKHook_Think, Schwert_Spiral_Core_Projectile_Homing_Hook);
		//CPrintToChatAll("beep term1");
		return Plugin_Stop;
	}
	//CPrintToChatAll("beep1");

	

	float GameTime = GetGameTime();

	if(fl_boomerang_duration[entity] < GameTime)
	{
		RMR_CurrentHomingTarget[entity] = -1;
	}

	//sword stuff:

	float Npc_Vec[3]; GetAbsOrigin(npc.index, Npc_Vec);
	float Proj_Vec[3]; GetAbsOrigin(entity, Proj_Vec);


	if(npc.Anger)
		Schwert_Manipulate_Sword_Location(npc, Proj_Vec, Proj_Vec, GameTime, 6.75, true, 30.0*RaidModeScaling);
	else
		Schwert_Manipulate_Sword_Location(npc, Proj_Vec, Proj_Vec, GameTime, 4.5, true, 20.0*RaidModeScaling);

	float dist = GetVectorDistance(Npc_Vec, Proj_Vec);

	if(dist < 100.0 && RMR_CurrentHomingTarget[entity]==-1)
	{
		b_swords_flying[npc.index]=false;
		RemoveEntity(entity);
		//CPrintToChatAll("beep term2");
		SDKUnhook(npc.index, SDKHook_Think, Schwert_Spiral_Core_Projectile_Homing_Hook);
		return Plugin_Stop;
	}


	//homing stuff:

	if(fl_homing_throttle[entity]> GameTime)
	{
		return Plugin_Continue;
	}

	fl_homing_throttle[entity]= GameTime+0.1;

	if(fl_retract_timer[entity]<GameTime)
	{
		RMR_CurrentHomingTarget[entity] = -1;
	}

	//The enemy is valid
	if(IsValidEnemy(entity, RMR_CurrentHomingTarget[entity]))
	{
		
		if(HomingProjectile_IsVisible(entity, RMR_CurrentHomingTarget[entity]))
		{
			if(Can_I_See_Withing_Angles(entity, RMR_CurrentHomingTarget[entity]))
			{
				fl_retract_timer[entity] = GameTime+3.5;
			}
			Schwert_TurnToTarget_Proj(entity, RMR_CurrentHomingTarget[entity]);
			return Plugin_Continue;
		}
		return Plugin_Continue;
	}
	RMR_CurrentHomingTarget[entity] = -1;

	//We already lost our homing Target, return to schwert!

	Schwert_TurnToTarget_Proj(entity, npc.index);

	return Plugin_Continue;
}	

static void Schwert_TurnToTarget_Proj(int projectile, int Target)
{
	static float rocketAngle[3];

	rocketAngle[0] = RWI_RocketRotation[projectile][0];
	rocketAngle[1] = RWI_RocketRotation[projectile][1];
	rocketAngle[2] = RWI_RocketRotation[projectile][2];

	static float tmpAngles[3];
	static float rocketOrigin[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", rocketOrigin);

	float pos1[3];
	WorldSpaceCenter(Target, pos1);
	GetRayAngles(rocketOrigin, pos1, tmpAngles);
	
	// Thanks to mikusch for pointing out this function to use instead
	// we had a simular function but i forgot that it existed before
	// https://github.com/Mikusch/ChaosModTF2/pull/4/files

	float Dist = GetVectorDistance(rocketOrigin, pos1);

	float Homing_Speed = 15.0;

	if(Can_I_See_Withing_Angles(projectile, Target))
	{
		Homing_Speed = 30.0 * (Dist/1500.0);
	}

	rocketAngle[0] = ApproachAngle(tmpAngles[0], rocketAngle[0], Homing_Speed);
	rocketAngle[1] = ApproachAngle(tmpAngles[1], rocketAngle[1], Homing_Speed);
	
	float vecVelocity[3];
	GetAngleVectors(rocketAngle, vecVelocity, NULL_VECTOR, NULL_VECTOR);
	
	vecVelocity[0] *= RWI_RocketSpeed[projectile];
	vecVelocity[1] *= RWI_RocketSpeed[projectile];
	vecVelocity[2] *= RWI_RocketSpeed[projectile];

	RWI_RocketRotation[projectile][0] = rocketAngle[0];
	RWI_RocketRotation[projectile][1] = rocketAngle[1];
	RWI_RocketRotation[projectile][2] = rocketAngle[2];

	TeleportEntity(projectile, NULL_VECTOR, rocketAngle, vecVelocity);
}

static bool Can_I_See_Withing_Angles(int projectile, int Target)
{
	static float ang3[3];
	
	float ang_Look[3];

	ang_Look[0] = RWI_RocketRotation[projectile][0];
	ang_Look[1] = RWI_RocketRotation[projectile][1];
	ang_Look[2] = RWI_RocketRotation[projectile][2];

	float pos1[3];
	float pos2[3];
	GetEntPropVector(projectile, Prop_Send, "m_vecOrigin", pos2);
	WorldSpaceCenter(Target, pos1);
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	float Can_See_Angles = 100.0;

	// verify angle validity
	if(!(fabs(ang_Look[0] - ang3[0]) <= Can_See_Angles ||
	(fabs(ang_Look[0] - ang3[0]) >= (360.0-Can_See_Angles))))
	{
		return false;
	}

	if(!(fabs(ang_Look[1] - ang3[1]) <= Can_See_Angles ||
	(fabs(ang_Look[1] - ang3[1]) >= (360.0-Can_See_Angles))))
	{
		return false;
	}
		
	return true;
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
static Action Timer_Move_Particle(Handle timer, DataPack pack)
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