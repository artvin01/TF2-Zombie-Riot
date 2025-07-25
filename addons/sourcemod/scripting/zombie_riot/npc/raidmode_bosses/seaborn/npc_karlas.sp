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
static bool b_tripple_raid[MAXENTITIES];



#define KARLAS_TELEPORT_STRIKE_INITIALIZE		"misc/halloween/gotohell.wav"
#define KARLAS_TELEPORT_STRIKE_LOOPS 			"weapons/vaccinator_charge_tier_03.wav"
#define KARLAS_TELEPORT_STRIKE_EXPLOSION		"misc/halloween/spell_mirv_explode_primary.wav"

#define KARLAS_LIGHT_MODEL "models/effects/vol_light256x512.mdl"

#define KARLAS_TELEPORT_STRIKE_RADIUS 750.0

static float fl_npc_basespeed;

//Logic for duo raidboss


static bool b_bobwave[MAXENTITIES];

static bool b_swords_created[MAXENTITIES];


static float fl_retreat_timer[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_karlas_sword_battery[MAXENTITIES];


#define KARLAS_SWORDS_AMT 7	
#define KARLAS_SLICER_HIT	"npc/scanner/scanner_electric1.wav"
#define KARLAS_SLICER_FIRE "ambient/rottenburg/portcullis_down.wav"

static int i_dance_of_light_sword_id[MAXENTITIES][KARLAS_SWORDS_AMT];
static float fl_dance_of_light_sword_throttle[MAXENTITIES][KARLAS_SWORDS_AMT];
static float fl_dance_of_light_sound_spam_timer[MAXENTITIES];

static bool b_lostOVERDRIVE[MAXENTITIES];


void Karlas_OnMapStart_NPC()
{
	Zero(fl_teleport_strike_recharge);
	Zero(b_teleport_strike_active);
	Zero(b_swords_created);
	Zero(fl_retreat_timer);
	Zero(fl_dance_of_light_sound_spam_timer);
	Zero2(fl_dance_of_light_sword_throttle);
	Zero(fl_spinning_angle);
	Zero(fl_karlas_sword_battery);

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
	PrecacheSoundArray(g_DefaultMedic_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_DefaultMeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_Sword_Impact_Sound);
	PrecacheSoundArray(g_BuffSounds);
	
	PrecacheModel(KARLAS_LIGHT_MODEL, true);
	PrecacheSound(KARLAS_TELEPORT_STRIKE_INITIALIZE, true);
	PrecacheSound(KARLAS_TELEPORT_STRIKE_LOOPS, true);
	PrecacheSound(KARLAS_TELEPORT_STRIKE_EXPLOSION, true);
	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);

	PrecacheSound(KARLAS_SLICER_HIT, true);
	PrecacheSound(KARLAS_SLICER_FIRE, true);

	
	PrecacheSound("mvm/mvm_tele_deliver.wav", true);
	PrecacheSound("mvm/mvm_tele_activate.wav", true);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, char[] data)
{
	return Karlas(vecPos, vecAng, team, data);
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
		
		EmitSoundToAll(g_DefaultMedic_IdleAlertedSounds[GetRandomInt(0, sizeof(g_DefaultMedic_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		int rng = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		EmitSoundToAll(g_DeathSounds[rng], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DeathSounds[rng], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DeathSounds[rng], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DeathSounds[rng], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayTeleportSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_TeleportSounds) - 1);
		EmitSoundToAll(g_TeleportSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);	//don't mind me, just reusing this...
		pack.WriteString(g_TeleportSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	property float m_flSlicerBarrageCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flSlicerBarrageActive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSlicerBarrageNextWave
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
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
	property float m_flInvulnerability
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property int m_iParticles1
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_particle_effects[this.index]);
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
				i_particle_effects[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_particle_effects[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iSlicersFired
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property int m_iWingSlot
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_wingslot[this.index]);
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
				i_wingslot[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_wingslot[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property float m_flKarlMeleeArmour
	{
		public get()		 
		{ 
			return this.m_flMeleeArmor;
		}
		public set(float fAmt) 
		{
			//we are teleporting and also can't move, take a heavily defensive position.	
			if(b_teleport_strike_active[this.index])
				fAmt -=0.5;

			//we are retreating to stella, take a more defensive position.
			if(this.m_bRetreat)
				fAmt -=0.15;
			
			//we are doing our "amazon delivery service", we cannot move, give uis armour
			if(this.m_flSlicerBarrageCD == FAR_FUTURE)
				fAmt -= 0.3;

			//we are being used as a mirror, cannot move, take defensive stance.
			if(this.m_flNC_LockedOn > GetGameTime(this.index))
				fAmt -= 0.15;
			
			if(this.Anger)
				fAmt -=0.25;

			//hard limit, although unlikely to be hit.
			if(fAmt < 0.05)
				fAmt = 0.05;	
			
			if(b_lostOVERDRIVE[this.index])
				fAmt = 0.01699;

			this.m_flMeleeArmor = fAmt;
		}
	}
	property float m_flKarlRangedArmour
	{
		public get()		 
		{ 
			return this.m_flRangedArmor;
		}
		public set(float fAmt) 
		{
			//we are teleporting and also can't move, take a heavily defensive position.	
			if(b_teleport_strike_active[this.index])
				fAmt -=0.3;

			//we are retreating to stella, take a more defensive position.
			if(this.m_bRetreat)
				fAmt -=0.15;
			
			//we are doing our "amazon delivery service", we cannot move, give us armour
			if(this.m_flSlicerBarrageCD == FAR_FUTURE)
				fAmt -= 0.3;

			//we are being used as a mirror, cannot move, take defensive stance.
			if(this.m_flNC_LockedOn > GetGameTime(this.index))
				fAmt -= 0.15;

			if(this.Anger)
				fAmt -=0.25;

			//hard limit, although unlikely to be hit.
			if(fAmt < 0.05)
				fAmt = 0.05;	
			
			if(b_lostOVERDRIVE[this.index])
				fAmt = 0.01699;

			this.m_flRangedArmor = fAmt;
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

	public Karlas(float vecPos[3], float vecAng[3], int ally, char[] data)
	{
		Karlas npc = view_as<Karlas>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));

		i_NpcWeight[npc.index] = 3;
		b_bobwave[npc.index] = false;
		
		if(StrContains(data, "force10") != -1)
			i_current_wave[npc.index] = 10;
		else if(StrContains(data, "force20") != -1)
			i_current_wave[npc.index] = 20;
		else if(StrContains(data, "force30") != -1)
			i_current_wave[npc.index] = 30;
		else if(StrContains(data, "force40") != -1)
			i_current_wave[npc.index] = 40;
		
		if(StrContains(data, "bob") != -1)
			b_bobwave[npc.index] = true;

		b_lostOVERDRIVE[npc.index] = false;
		
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

		f_ExplodeDamageVulnerabilityNpc[npc.index] = 1.0;

		Zero(fl_dance_of_light_sound_spam_timer);

		npc.m_fbGunout = false;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		if(RaidModeTime < GetGameTime() + 200.0)
			RaidModeTime = GetGameTime() + 200.0;

		npc.m_flNextChargeSpecialAttack = 0.0;	//used for transformation Logic
		b_swords_created[npc.index]=false;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;

		fl_karlas_sword_battery[npc.index]=0.0;
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
		npc.m_iWearable8 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_2);
		SetVariantInt(RUINA_IMPACT_LANCE_4);
		AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		KarlasEarsApply(npc.index,_,0.75);

		npc.m_iWingSlot =  npc.EquipItem("head", WINGS_MODELS_1);
		SetVariantInt(WINGS_KARLAS);
		AcceptEntityInput(npc.m_iWingSlot, "SetBodyGroup");
		npc.StartPathing();
		npc.Set_Particle("raygun_projectile_blue_crit", "eyeglow_L");

		npc.m_flKarlMeleeArmour = 1.5;
		npc.m_flKarlRangedArmour = 1.0;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");

		npc.m_flSlicerBarrageCD = GetGameTime() + GetRandomFloat(15.0, 20.0);
		npc.m_flSlicerBarrageActive = 0.0;
		npc.m_flSlicerBarrageNextWave = 0.0;
		npc.m_iSlicersFired = 0;
		npc.Anger = false;

		Delete_Swords(npc.index);

		func_NPCFuncWin[npc.index] = Win_Line;
		npc.m_iNClockonState = 0;

		if(StrContains(data, "overdrive") != -1)
		{
			CPrintToChatAll("{crimson}카를라스{snow}: >:)");
			b_lostOVERDRIVE[npc.index] = true;

			NpcSpeechBubble(npc.index, ">:)", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");

			fl_karlas_sword_battery[npc.index] = FAR_FUTURE;

			npc.m_flSlicerBarrageCD = FAR_FUTURE;

			RaidModeTime = FAR_FUTURE;

			b_NameNoTranslation[npc.index] = true;
			c_NpcName[npc.index] = ">:)";

			fl_npc_basespeed = fl_npc_basespeed*3.0;
			npc.Anger = true;
		}
			

		if((StrContains(data, "anger") != -1))
			npc.Anger = true;

		b_allow_karlas_transform[npc.index] = false;
		
		return npc;
	}
}
static void Emit_Sword_Impact_Sound(int target)
{
	if(fl_dance_of_light_sound_spam_timer[target] > GetGameTime())
		return;

	fl_dance_of_light_sound_spam_timer[target] = GetGameTime() + 0.1;

	int sound = GetRandomInt(0, sizeof(g_Sword_Impact_Sound) - 1);
	EmitSoundToAll(g_Sword_Impact_Sound[sound], target, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
}
static void Win_Line(int entity)
{
	Karlas npc = view_as<Karlas>(entity);
	if(npc.Ally)
		return;
		
	CPrintToChatAll("{crimson}카를라스{snow}: ???");
}
void Set_Karlas_Ally(int karlas, int stella, int wave = -2, bool bob, bool tripple)
{	
	if(wave == -2)
		wave = Waves_GetRoundScale()+1;

	i_current_wave[karlas] = wave;
	i_ally_index[karlas] = EntIndexToEntRef(stella);
	b_bobwave[karlas] = bob;
	b_tripple_raid[karlas] = tripple;
}

static void Internal_ClotThink(int iNPC)
{
	Karlas npc = view_as<Karlas>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flInvulnerability)
	{
		int ally = npc.Ally;
		Karlas npcally = view_as<Karlas>(ally);
		if(IsValidEntity(ally) && npcally.m_flInvulnerability)
		{
			RequestFrame(KillNpc, EntIndexToEntRef(ally));
			RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
		}
		else if(!IsValidEntity(ally))
		{
			RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
		}
	}
	
	if(RaidModeTime < GetGameTime() && !npc.Ally && !b_lostOVERDRIVE[npc.index])
	{
		CPrintToChatAll("{crimson}카를라스{snow}: >:)");
		b_lostOVERDRIVE[npc.index] = true;

		NpcSpeechBubble(npc.index, ">:)", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");

		SetEntProp(npc.index, Prop_Data, "m_iHealth", 696969420);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", 696969420);

		b_NameNoTranslation[npc.index] = true;
		RaidModeTime = FAR_FUTURE;
		c_NpcName[npc.index] = ">:)";

		fl_karlas_sword_battery[npc.index] = FAR_FUTURE;

		npc.m_flSlicerBarrageCD = FAR_FUTURE;

		GiveOneRevive(true);

		fl_npc_basespeed = fl_npc_basespeed*3.0;
		npc.Anger = true;
		
		return;
	}

	if(npc.m_flNextDelayTime > GameTime)
		return;
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	npc.m_flKarlMeleeArmour = 1.5;
	npc.m_flKarlRangedArmour = 1.0;
			
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
	//slicer is about to be ready, don't teleport.
	if(npc.m_flSlicerBarrageCD < GameTime + 2.0 && i_current_wave[npc.index] >=20)
		abort_teleport = true;
	
	if(abort_teleport && Karlas_Status(npc, GameTime)==1 && b_teleport_strike_active[npc.index])
	{
		npc.m_flSpeed =fl_npc_basespeed;
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.LanceState(true);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0; 
	}
	GetTarget(npc);	
	if(i_current_wave[npc.index] >= 20)
		Fire_Wave_Barrage(npc);

	if(npc.m_flNC_LockedOn > GameTime)
	{
		return;
	}
	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}
	//we are in the process of transforming, do stuff. also using a sepereate game time so special effects don't affect the transforming stuff.
	if(Karlas_Status(npc, GetGameTime())==0)	
	{
		f_NpcTurnPenalty[npc.index] = 0.0;	//:)
		i_NpcWeight[npc.index]=999;	//HE ONE HEAFTY BOI!
		float Anim_Timer = 6.25;
		if(npc.m_flNextChargeSpecialAttack < GetGameTime() + Anim_Timer)
		{
			npc.SetPlaybackRate(0.0);
			Karlas_Lifeloss_Logic(npc);
		}
		return;
	}
	else if(b_NpcIsInvulnerable[npc.index] && b_angered_twice[npc.index])
	{
		f_NpcTurnPenalty[npc.index]=1.0;
		i_NpcWeight[npc.index]=3;
		b_NpcIsInvulnerable[npc.index]=false;
		RemoveSpecificBuff(npc.index, "Clear Head");
		RemoveSpecificBuff(npc.index, "Solid Stance");
		RemoveSpecificBuff(npc.index, "Fluid Movement");
		npc.PlayAngerSoundPassed();
		npc.SetPlaybackRate(1.0);

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.LanceState(true);

		npc.m_bisWalking = true;

		if(fl_teleport_strike_recharge[npc.index] < GameTime+5.0)
			fl_teleport_strike_recharge[npc.index]=GameTime+5.0; 

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
		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		GetTarget(npc);
		return;
	}
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float npc_Vec[3]; WorldSpaceCenter(npc.index, npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, npc_Vec, true);
	npc.AdjustWalkCycle();

	Body_Pitch(npc, npc_Vec, vecTarget);

	//use same logic for teleport aborting.
	//this will alos override where we are walking to.
	//but only override where we are walking to IF the abort teleport is invalid.
	if(Healing_Logic(npc, PrimaryThreatIndex, flDistanceToTarget) && !abort_teleport)
	{
		return;
	}
		
	//STELLA NEEDS HEALING, QUICKLY CALL AN AMBULANCE.
	//BUT NOT FOR ME


	if(npc.m_bRetreat)
	{
		int Ally = npc.Ally;
		if(IsValidAlly(npc.index, Ally))
		{
			float vecAlly[3]; WorldSpaceCenter(Ally, vecAlly);

			float flDistanceToAlly = GetVectorDistance(vecAlly, npc_Vec, true);
			Karlas_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget);

			if(flDistanceToAlly < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*10.0 && Can_I_See_Enemy_Only(npc.index, Ally))
			{
				NPCStats_RemoveAllDebuffs(Ally, 1.0);
				ApplyStatusEffect(npc.index, Ally, "Defensive Backup", 2.5);
			}

			//Karlas_Teleport_Core(npc, PrimaryThreatIndex);
		}
	}
	else
	{
		if(Karlas_Status(npc, GameTime)!=1)
		{
			npc.m_flSpeed =  fl_npc_basespeed;
		}	
		Karlas_Movement(npc, flDistanceToTarget, PrimaryThreatIndex);
		Karlas_Aggresive_Behavior(npc, PrimaryThreatIndex, GameTime, flDistanceToTarget, vecTarget);
	}

	Blade_Logic(npc);

	npc.PlayIdleAlertSound();
}

static bool Healing_Logic(Karlas npc, int PrimaryThreatIndex, float flDistanceToTarget)
{
	int Ally = npc.Ally;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextRangedBarrage_Singular > GameTime)
		return false;
	
	Ally = npc.Ally;
	if(!IsValidAlly(npc.index, Ally))
		return false;
	
	int AllyMaxHealth = ReturnEntityMaxHealth(Ally);
	int AllyHealth = GetEntProp(Ally, Prop_Data, "m_iHealth");
	int KarlasMaxHealth = ReturnEntityMaxHealth(npc.index);
	int KarlasHealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(KarlasHealth > (KarlasMaxHealth / 2) && AllyHealth < (AllyMaxHealth / 3))
	{
		float vecAlly[3];
		float vecMe[3];
		WorldSpaceCenter(Ally, vecAlly);
		WorldSpaceCenter(npc.index, vecMe);

		float flDistanceToAlly = GetVectorDistance(vecAlly, vecMe, true);
		Karlas_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime, PrimaryThreatIndex, flDistanceToTarget, true);	
		
		if(flDistanceToAlly < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && Can_I_See_Enemy_Only(npc.index, Ally))
		{
			NpcSpeechBubble(npc.index, "..!", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
			CPrintToChatAll("{crimson}카를라스{snow}: ..!");
			CPrintToChatAll("{crimson}카를라스가 스텔라를 치유하며, 그 자신의 몸에 아드레날린이 퍼져나가고 있습니다...");
			HealEntityGlobal(npc.index, Ally, float((AllyMaxHealth / 7)), 1.0, 0.0, HEAL_ABSOLUTE);
			ApplyStatusEffect(npc.index, npc.index, "Ancient Melodies", 5.0);

			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, vecAlly, vecMe);	
			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, vecAlly, vecMe);	
			spawnBeam(0.8, 50, 50, 255, 50, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, vecAlly, vecMe);

			GetEntPropVector(Ally, Prop_Data, "m_vecAbsOrigin", vecAlly);
			
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 60.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);
			spawnRing_Vectors(vecAlly, 0.0, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 255, 2, 1.0, 5.0, 12.0, 1, 150.0);

			NPCStats_RemoveAllDebuffs(Ally, 5.0);
			ApplyStatusEffect(npc.index, Ally, "Hussar's Warscream", 10.0);
			npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 30.0;

			npc.PlayBuffSound();
			return false;
		}	
		return true;
	}
	return false;
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

	//stella has NC on karlas, use special targeting logic!
	if(npc.m_flNC_LockedOn > GameTime)
	{
		//stella is dead, but the "lockon" is still valid, kill the lockon
		if(!IsValidAlly(npc.index, npc.Ally))
		{
			npc.m_flNC_LockedOn = 0.0;
			npc.m_iNClockonState = 0;
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
	int enemy_2[MAXPLAYERS];
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

	float GameTime = GetGameTime(npc.index);

	if(b_swords_created[npc.index])
	{
		if(fl_karlas_sword_battery[npc.index] < GameTime-45.0)
		{
			fl_karlas_sword_battery[npc.index] = GameTime + 15.0;
		}
		
		Blade_Behavior=2;

		if(fl_karlas_sword_battery[npc.index]<GameTime && !npc.m_bRetreat)
		{
			Blade_Behavior=4;
		}
	}
	float npc_Vec[3]; WorldSpaceCenter(npc.index, npc_Vec);

	if(b_angered_twice[npc.index])
	{
		switch(Blade_Behavior)
		{
			case 2:	//Aggresive - spin around him while extended
			{
				Karlas_Manipulate_Sword_Location(npc, npc_Vec, npc_Vec, GameTime, 7.5, 12.0*RaidModeScaling);
			}
			case 4:	//becomes pseudo wings. neutral state for when the things are "recharging"
			{
				Karlas_SwordWings_Logic(npc, npc_Vec);
			}
		}
	}
}
static int Karlas_Status(Karlas npc, float GameTime)
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
	int pitch = GetRandomInt(90,110);
	EmitSoundToAll(KARLAS_SLICER_FIRE, npc.index, _, 120,_,_,pitch);

	float SelfVec[3];
	Ruina_Projectiles Projectile;
	npc.GetAttachment("effect_hand_r", SelfVec, NULL_VECTOR);
	TE_Particle("spell_batball_impact_red", SelfVec, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = SelfVec;
	float Ang[3];
	float VecTarget[3];
	WorldSpaceCenter(PrimaryThreatIndex, VecTarget);
	MakeVectorFromPoints(SelfVec, VecTarget, Ang);
	GetVectorAngles(Ang, Ang);

	float Speed = (npc.Anger ? 600.0 : 500.0);
	float Time = 10.0;

	if(NpcStats_IsEnemySilenced(npc.index))
		Speed *=0.95;

	Projectile.Angles = Ang;
	Projectile.speed = Speed;
	Projectile.radius = 0.0;
	Projectile.damage = Modify_Damage(-1, 30.0);
	Projectile.bonus_dmg = Modify_Damage(-1, 30.0)*6.0;
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

	float Distance = GetVectorDistance(SelfVec, VecTarget);
	float Timer_Span = Distance/Speed;
	Timer_Span *=(npc.Anger ? 0.75 : 0.5) + 0.25;
	

	CreateTimer(Timer_Span, KillProjectileHoming, EntIndexToEntRef(Proj), TIMER_FLAG_NO_MAPCHANGE);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(Proj));
	RequestFrame(Projectile_Detect_Loop, pack);
	
}
Action KillProjectileHoming(Handle Timer, int iRef)
{
	int Projectile = EntRefToEntIndex(iRef);
	if(!IsValidEntity(Projectile))
		return Plugin_Stop;
	
	HomingProjectile_Deactivate(Projectile);
	return Plugin_Stop;
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
	Laser.Damage = Modify_Damage(-1, 17.0);
	Laser.Bonus_Damage = Modify_Damage(-1, 17.0) * 6.0;
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
	int frames_offset = RoundToCeil((66.0*TickrateModify)*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(Projectile_Detect_Loop, frames_offset, pack2);

	
}
static void On_LaserHit(int karlas, int target, int damagetype, float damage)
{
	
	if(IsIn_HitDetectionCooldown(karlas,target))
		return;
			
	Set_HitDetectionCooldown(karlas,target, GetGameTime() + 0.25);	//if they walk backwards, its likely to hit them 2 times, but who on earth would willingly walk backwards/alongside the trajectory of the projectile

	int pitch = GetRandomInt(125,135);
	EmitSoundToAll(KARLAS_SLICER_HIT, target, SNDCHAN_AUTO, 75,_,0.8,pitch);
	SDKHooks_TakeDamage(target, karlas, karlas, damage, damagetype, -1); 
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
static void Karlas_Aggresive_Behavior(Karlas npc, int PrimaryThreatIndex, float GameTime, float flDistanceToTarget, float vecTarget[3])
{

	if(npc.m_bAllowBackWalking)
	{
		npc.FaceTowards(vecTarget, 20000.0);
	}
	else
	{
		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
	}
		

	if(fl_retreat_timer[npc.index] != -1.0 && !b_lostOVERDRIVE[npc.index] && (fl_retreat_timer[npc.index] > GameTime || (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*2.0 && npc.m_flNextMeleeAttack > GameTime)))
	{
		npc.m_bAllowBackWalking=true;
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
		npc.SetGoalVector(vBackoffPos, true);

		npc.FaceTowards(vecTarget, 20000.0);

		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
	}
	else
	{
		npc.m_bAllowBackWalking=false;
	}

	npc.StartPathing();
	

	
	Karlas_Teleport_Strike(npc, flDistanceToTarget, GameTime, PrimaryThreatIndex);
	
	//ancient melee code, don't copy it, take it from a more recent melee npc, this one is staying since it works + it has special logic for Karlas.
	//if you want similar "retreat after melee" logic like Karlas, go look at the lancelot from ruina, its far cleaner
	if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(Karlas_Status(npc, GameTime)==1)
			return;

		float Swing_Speed = (b_lostOVERDRIVE[npc.index] ? 0.2 : (npc.Anger ? 1.5 : 2.5));
		float Swing_Delay = (b_lostOVERDRIVE[npc.index] ? 0.0 : 0.25);

		bool Silence = NpcStats_IsEnemySilenced(npc.index);
		float Knockback_Deal = Silence ? 560.0 : 900.0;
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			if(!b_lostOVERDRIVE[npc.index])
			{
				int Nearby = Nearby_Players(npc, 400.0);

				int amount_of_people = 6;

				float Ratio = 1.0 - (Nearby/float(amount_of_people));
				if(Ratio <0.0)
					Ratio = 0.0;

				float MinSpeed = (npc.Anger ? 0.175 : 0.3);
				float MinDelay = 0.1;	//must be lower, since uh, otherwise the melee doesn't ever hit

				Swing_Speed = MinSpeed + (Swing_Speed - MinSpeed) * Ratio;
				Swing_Delay = MinDelay + (Swing_Delay - MinDelay) * Ratio;

				Knockback_Deal *=Ratio;
			}
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
				if(Swing_Speed > 0.9)
					fl_retreat_timer[npc.index] = GameTime+(Swing_Speed*0.35);
				else
					fl_retreat_timer[npc.index] = -1.0;

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float meleedmg= Modify_Damage(target, 50.0);	//karlas hurts like a fucking truck

						if(fl_karlas_sword_battery[npc.index]> GameTime)
						{
							fl_karlas_sword_battery[npc.index] +=2.0;
						}

						//clause ae karlas knockback
						if(!b_lostOVERDRIVE[npc.index])
						{
							
							if(IsValidClient(target) && !Silence)
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							Custom_Knockback(npc.index, target, Knockback_Deal, true);
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
static int i_targets_inrange;

static int Nearby_Players(Karlas npc, float Radius)
{
	i_targets_inrange = 0;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);
	return i_targets_inrange;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}
static void Fire_Wave_Barrage(Karlas npc)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_iSlicersFired == 0)
	{
		//bruh. so many checks.
		if(Karlas_Status(npc, GameTime) != -1)
			return;
			
		if(npc.m_flSlicerBarrageCD > GameTime)
			return;
		
		if(b_NpcIsInvulnerable[npc.index])
			return;

		if(npc.m_iNClockonState != 0 || npc.m_flNC_LockedOn > GameTime)
			return;
			
		
		if(Nearby_Players(npc, 9000.0) <=0)
			return;
	}
	if(npc.m_flSlicerBarrageActive > GameTime && (npc.m_iNClockonState != 0 || npc.m_flNC_LockedOn > GameTime))
	{
		npc.m_flSpeed =fl_npc_basespeed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iSlicersFired = 0;
		npc.m_flSlicerBarrageCD = GameTime + 10.0;
		npc.m_bisWalking = true;

		npc.LanceState(true);
		return;
	}

	if(npc.m_flSlicerBarrageNextWave > GameTime)
		return;
	
	//taunt_the_fist_bump_fistbump

	int Amt = (npc.Anger ? 12 : 8); 
	float Fire_Rate = (npc.Anger ? 0.5 : 1.0);	//how long between slicer bursts

	if(npc.m_iSlicersFired > Amt+1)
	{
		npc.m_flSpeed =fl_npc_basespeed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flSlicerBarrageCD = GameTime + (npc.Anger ? 40.0 : 45.0);	
		npc.m_iSlicersFired = 0;
		npc.m_bisWalking = true;

		npc.LanceState(true);
		return;
	}
	if(npc.m_flSlicerBarrageCD <= GameTime)
	{
		npc.SetPlaybackRate(0.85);	
		npc.SetCycle(0.01);

		npc.m_bisWalking = false;
		//look into using "setcycle" when we fire the projectile as we "crack" the hands, allowing us to "crack" an infinite amount of hands if we wanted to, to fire a proj
		npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");

		npc.m_flSlicerBarrageCD = FAR_FUTURE;

		npc.m_flSlicerBarrageNextWave = GameTime + 0.8;
		npc.m_flDoingAnimation = GameTime + 2.0;
		npc.m_flSlicerBarrageActive = GameTime + 2.0;

		npc.LanceState(false);

		npc.m_flSpeed = 0.0;

		npc.m_iSlicersFired = 1;

		return;
	}

	if(NpcStats_IsEnemySilenced(npc.index))
		Fire_Rate *=1.05;

	npc.m_flSlicerBarrageNextWave = GameTime + Fire_Rate;
	npc.m_flDoingAnimation = GameTime + Fire_Rate+0.5;
	npc.m_flSlicerBarrageActive = GameTime + Fire_Rate+0.5;
	npc.SetCycle(0.05);
	//offset the firing of the barrage so it matches up nicely with the animation!
	CreateTimer(0.1, TimerFireSlicers, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);

	npc.m_iSlicersFired++;

	//get a target right infront of karlas.
	//or if one is not found, use standard targeting logic.
	npc.m_iTarget = i_Get_Laser_Target(npc);
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
		return;

	float TargetVec[3]; WorldSpaceCenter(npc.m_iTarget, TargetVec);
	npc.FaceTowards(TargetVec, 5000.0);
}
#define KARLAS_MAX_BARRAGE 3
static int i_targets[KARLAS_MAX_BARRAGE];
static Action TimerFireSlicers(Handle Timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(!IsValidEntity(entity))
		return Plugin_Handled;

	Karlas npc = view_as<Karlas>(entity);

	float Radius = (npc.Anger ? 99999.0 : 2000.0);
	Zero(i_targets);
	Explode_Logic_Custom(0.0, npc.index, npc.index, 0, _, Radius, _, _, true, 15, false, _, GetEntitiesForSlicers);

	for(int i=0 ; i < KARLAS_MAX_BARRAGE ; i++)
	{
		//we have run out of valid targets, abort.
		if(!i_targets[i])
			break;

		Fire_Hiigara_Projectile(npc, i_targets[i]);
	}

	return Plugin_Handled;
}
static void GetEntitiesForSlicers(int entity, int victim, float damage, int weapon)
{
	Karlas npc = view_as<Karlas>(entity);
	int target = IsLineOfSight(npc, victim);
	if(!IsValidEnemy(npc.index, target))
		return;

	for(int i=0 ; i < KARLAS_MAX_BARRAGE ; i++)
	{
		if(!i_targets[i])
		{
			i_targets[i] = target;
			break;
		}
	}
}
static int IsLineOfSight(Karlas npc, int Target)
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

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	float MaxYaw = 60.0;
	float MinYaw = -60.0;
		
	// now it's a simple check
	if ((yawOffset >= MinYaw && yawOffset <= MaxYaw))	//first check position before doing a trace checking line of sight.
	{					
		return Can_I_See_Enemy(npc.index, Target);
	}
	return 0;
}


static void Karlas_Teleport_Strike(Karlas npc, float flDistanceToTarget, float GameTime, int PrimaryThreatIndex)
{
	if(npc.m_bRetreat)
		return;

	if(flDistanceToTarget < (2500.0*2500.0) && fl_teleport_strike_recharge[npc.index] < GameTime && !b_teleport_strike_active[npc.index] && npc.m_flDoingAnimation < GameTime)
	{
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))
		{
			npc.m_flSpeed = 0.0;
			float Time = 2.0;
			npc.m_flDoingAnimation = GameTime+Time;
			b_teleport_strike_active[npc.index]=true;

			npc.SetPlaybackRate(0.75);	
			npc.SetCycle(0.1);

			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_neck_snap_medic");

			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", Time);

			npc.LanceState(false);

			float npc_Loc[3]; GetAbsOrigin(npc.index, npc_Loc);

			EmitSoundToAll(KARLAS_TELEPORT_STRIKE_INITIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);
			EmitSoundToAll(KARLAS_TELEPORT_STRIKE_INITIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);


			npc_Loc[2]+=10.0;
			int color[4];
			Ruina_Color(color, i_current_wave[npc.index]);
			TE_SetupBeamRingPoint(npc_Loc, 250.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, 12.0, 0.75, color, 1, 0);
			TE_SendToAll();

		}
	}
	if(b_teleport_strike_active[npc.index] && npc.m_flDoingAnimation < GameTime)
	{
		npc.m_flSpeed =fl_npc_basespeed;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_bisWalking = true;

		npc.LanceState(true);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0;

		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))	//now do another check to see if we can still even see a target, if not, abort the whole process.
		{
			float Original_Origin[3];
			float Angles[3];
			float Test_Origin[3];
			
			WorldSpaceCenter(PrimaryThreatIndex, Original_Origin);
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_angRotation", Angles);

			//100 infront of the target
			Test_Origin = Original_Origin;
			Offset_Vector({100.0, 0.0, 0.0}, Angles, Test_Origin);
			

			//float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
			//TE_SetupBeamPoints(npc_vec, Test_Origin, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 0, 5.0, 25.0, 25.0, 10, 0.1, {255,255,255,255}, 10);
			//TE_SendToAll();

			if(Karlas_Teleport(npc.index, Test_Origin, 0.0))
			{
				Karlas_Teleport_Boom(npc, Test_Origin);
				npc.PlayTeleportSound();
				if(npc.Anger)
					fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
				else
					fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
			}
			else
			{
				//100 behind of the target
				Test_Origin = Original_Origin;
				Offset_Vector({-100.0, 0.0, 0.0}, Angles, Test_Origin);

				//TE_SetupBeamPoints(npc_vec, Test_Origin, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 0, 5.0, 25.0, 25.0, 10, 0.1, {255,255,255,255}, 10);
				//TE_SendToAll();

				if(Karlas_Teleport(npc.index, Test_Origin, 0.0))
				{
					npc.PlayTeleportSound();
					Karlas_Teleport_Boom(npc, Test_Origin);
					if(npc.Anger)
						fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
					else
						fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
				}
				else
				{
					//100 onto the left(?) of the target
					Test_Origin = Original_Origin;
					Offset_Vector({0.0, -100.0, 0.0}, Angles, Test_Origin);

					//TE_SetupBeamPoints(npc_vec, Test_Origin, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 0, 5.0, 25.0, 25.0, 10, 0.1, {255,255,255,255}, 10);
					//TE_SendToAll();

					if(Karlas_Teleport(npc.index, Test_Origin, 0.0))
					{
						npc.PlayTeleportSound();
						Karlas_Teleport_Boom(npc, Test_Origin);
						if(npc.Anger)
							fl_teleport_strike_recharge[npc.index]=GameTime+30.0;
						else
							fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
					}
					else
					{
						//100 onto the right(?) of the target
						Test_Origin = Original_Origin;
						Offset_Vector({0.0, 100.0, 0.0}, Angles, Test_Origin);

						//TE_SetupBeamPoints(npc_vec, Test_Origin, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 0, 5.0, 25.0, 25.0, 10, 0.1, {255,255,255,255}, 10);
						//TE_SendToAll();

						if(Karlas_Teleport(npc.index, Test_Origin, 0.0))
						{
							npc.PlayTeleportSound();
							Karlas_Teleport_Boom(npc, Test_Origin);
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
}
static void Karlas_Proper_To_Groud_Clip(float vecHull[3], float StepHeight, float vecorigin[3])
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

static void Karlas_Teleport_Boom(Karlas npc, float Location[3])
{
	float Boom_Time = 5.0;

	Karlas_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Location);

	float radius = KARLAS_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	
	int color[4];
	Ruina_Color(color, i_current_wave[npc.index]);
	color[3] = 175;

	TE_SetupBeamRingPoint(Location, radius*2.0, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, Boom_Time, 15.0, 1.0, color, 1, 0);

	Handle pack;
	CreateDataTimer(Boom_Time, Karlas_Boom, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntRefToEntIndex(npc.index));
	WritePackFloat(pack, Location[0]);
	WritePackFloat(pack, Location[1]);
	WritePackFloat(pack, Location[2]);

	Handle pack2;
	CreateDataTimer(0.0, Karlas_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(npc.index));
	WritePackFloat(pack2, Boom_Time);
	WritePackFloat(pack2, Location[0]);
	WritePackFloat(pack2, Location[1]);
	WritePackFloat(pack2, Location[2]);
}
static Action Karlas_Ring_Loops(Handle Loop, DataPack pack)
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

	EmitAmbientSound(KARLAS_TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
	EmitAmbientSound(KARLAS_TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));

	Karlas npc = view_as<Karlas>(entity);
	float radius = KARLAS_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	
	int color[4];
	Ruina_Color(color, i_current_wave[npc.index]);
	color[3] = 175;

	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, 0.0, g_Ruina_BEAM_lightning, g_Ruina_HALO_Laser, 0, 66, 1.0, 30.0, 0.1, color, 1, 0);
	TE_SendToAll();

	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, (radius*2.0) + 0.1, g_Ruina_Laser_BEAM, g_Ruina_HALO_Laser, 0, 1, 1.0, 20.0, 1.0, color, 1, 0);
	TE_SendToAll();

	Handle pack2;
	CreateDataTimer(1.0, Karlas_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(entity));
	WritePackFloat(pack2, loops);
	WritePackFloat(pack2, spawnLoc[0]);
	WritePackFloat(pack2, spawnLoc[1]);
	WritePackFloat(pack2, spawnLoc[2]);

	return Plugin_Stop;

}
static Action Karlas_Boom(Handle Smite_Logic, DataPack pack)
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
	float radius = KARLAS_TELEPORT_STRIKE_RADIUS;
	int color[4];
	Ruina_Color(color, i_current_wave[npc.index]);
	color[3] = 175;
	int loop_for = 15;		//15
	float height = 1500.0;	//1500
	float sky_loc[3]; sky_loc = spawnLoc; sky_loc[2]+=height;

	if(npc.Anger)
	{
		radius *= 1.25;	
	}

	Explode_Logic_Custom(damage, npc.index, npc.index, -1, spawnLoc, radius,_,0.8, true);

	EmitAmbientSound(KARLAS_TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
	EmitAmbientSound(KARLAS_TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));

	float GameTime = GetGameTime(npc.index);
	
	if(fl_karlas_sword_battery[npc.index]< GameTime)
		fl_karlas_sword_battery[npc.index] = GameTime+7.0;
	else
		fl_karlas_sword_battery[npc.index] += 7.0;

	spawnLoc[2]+=10.0;

	TE_SetupBeamRingPoint(spawnLoc, 1.0, radius*2.0, g_Ruina_Laser_BEAM, g_Ruina_HALO_Laser, 0, 1, 1.0, 20.0, 1.0, color, 1, 0);
	TE_SendToAll();
	
	float start = 75.0;
	float end = 75.0;
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.25, start*0.5, end*0.5, 0, 1.0, color, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Diamond, 0, 0, 0, 1.5, start*0.25, end*0.25, 0, 1.0, color, 3);
	TE_SendToAll();

	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.25, start*0.5, end*0.5, 0, 1.0, color, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(spawnLoc, sky_loc, g_Ruina_BEAM_Combine_Blue, g_Ruina_HALO_Laser, 0, 0, 1.5, start*0.25, end*0.25, 0, 1.0, color, 3);
	TE_SendToAll();

	float Time = 1.0;

	float thicc = 4.0;
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
static bool Karlas_Teleport(int iNPC, float vecTarget[3], float Min_Range)
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
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	

		Succeed = Npc_Teleport_Safe(npc.index, vecTarget, hullcheckmins, hullcheckmaxs, false);
	
		if(Succeed)
		{
			
			float effect_duration = 0.25;
			
			
			end_offset = vecTarget;
			
			start_offset[2]-= 25.0;
			end_offset[2] -= 25.0;
			
			for(int help=1 ; help<=8 ; help++)
			{	
				Karlas_Teleport_Effect("drg_manmelter_trail_blue", effect_duration, start_offset, end_offset);
				
				start_offset[2] += 12.5;
				end_offset[2] += 12.5;
			}
		}
	}
	return Succeed;
}
static void Karlas_Movement(Karlas npc, float flDistanceToTarget, int target)
{	
	npc.StartPathing();
	
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
static void Karlas_Movement_Ally_Movement(Karlas npc, float flDistanceToAlly, int ally, float GameTime, int PrimaryThreatIndex_Karlas, float flDistanceToTarget_Karlas, bool block_defense=false)
{	
	if(npc.m_bAllowBackWalking)
		npc.m_bAllowBackWalking=false;
		
	npc.StartPathing();
	
	
	float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex_Karlas, WorldSpaceVec2);
	
	if(flDistanceToTarget_Karlas < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25 && npc.m_flNC_LockedOn < GameTime)
	{
		Karlas_Movement(npc, flDistanceToTarget_Karlas, PrimaryThreatIndex_Karlas);
		Karlas_Aggresive_Behavior(npc, PrimaryThreatIndex_Karlas, GameTime, flDistanceToTarget_Karlas, WorldSpaceVec2);
		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed;
		return;
	}
	Stella donner = view_as<Stella>(ally);
	
	if(block_defense)
	{
		npc.SetGoalEntity(donner.index);
		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed*2.0;
		return;
	}	
	float Return_Loc[3];
	bool Can_I_SeeNC = CanIseeNCEndLoc(npc, Return_Loc);
	//stella wants to reflect
	//we can see the end vec of NC
	if(npc.m_iNClockonState == 2 && (Can_I_SeeNC || Can_I_See_Enemy_Only(npc.index, npc.Ally)) && donner.m_bInKame)
	{
		int target_new = GetClosestTarget(donner.index);
		if(!IsValidEnemy(npc.index, target_new))
			target_new = PrimaryThreatIndex_Karlas;

		int see_target = Can_I_See_Enemy(npc.index, target_new);

		if(IsValidEnemy(npc.index, see_target))
		{
			WorldSpaceCenter(see_target, WorldSpaceVec2);
			npc.m_bAllowBackWalking = true;
			npc.FaceTowards(WorldSpaceVec2, RUINA_FACETOWARDS_BASE_TURNSPEED*1.5);

			if(npc.m_flNC_LockedOn < GameTime)
			{
				npc.m_flSpeed = fl_npc_basespeed;
				npc.SetGoalVector(Return_Loc, true);
			}
		}
		else
		{
			Karlas_Movement(npc, flDistanceToTarget_Karlas, PrimaryThreatIndex_Karlas);
			Karlas_Aggresive_Behavior(npc, PrimaryThreatIndex_Karlas, GameTime, flDistanceToTarget_Karlas, WorldSpaceVec2);
			if(Karlas_Status(npc, GameTime)!=1)
				npc.m_flSpeed =  fl_npc_basespeed;
		}

		return;
	}

	float Distance_To_Ally_Keep = (1500.0*1500.0);
	if(flDistanceToAlly < Distance_To_Ally_Keep)	//stay within a 1500 radius of stella
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
				Karlas_Movement(npc, flDistanceToTarget, target_new);
				Karlas_Aggresive_Behavior(npc, target_new, GameTime, flDistanceToTarget, Vec_Target);
				if(Karlas_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_npc_basespeed*2.0;
			}
			else
			{
				Karlas_Movement(npc, flDistanceToTarget_Karlas, PrimaryThreatIndex_Karlas);
				Karlas_Aggresive_Behavior(npc, PrimaryThreatIndex_Karlas, GameTime, flDistanceToTarget_Karlas, WorldSpaceVec2);
				if(Karlas_Status(npc, GameTime)!=1)
					npc.m_flSpeed =  fl_npc_basespeed;
			}
		}
		else
		{
			Karlas_Movement(npc, flDistanceToTarget_Karlas, PrimaryThreatIndex_Karlas);
			Karlas_Aggresive_Behavior(npc, PrimaryThreatIndex_Karlas, GameTime, flDistanceToTarget_Karlas, WorldSpaceVec2);
			if(Karlas_Status(npc, GameTime)!=1)
				npc.m_flSpeed =  fl_npc_basespeed;
		}
	} 
	else 
	{
		npc.SetGoalEntity(donner.index);
		if(Karlas_Status(npc, GameTime)!=1)
			npc.m_flSpeed =  fl_npc_basespeed*2.0;
			
		npc.m_flGetClosestTargetTime = 0.0;
	}
}
bool CanIseeNCEndLoc(Karlas npc, float Return_Loc[3])
{
	if(!IsValidAlly(npc.index, npc.Ally))
		return false;

	if(npc.m_flNC_LockedOn > GetGameTime(npc.index))
		return true;
	
	Ruina_Laser_Logic Laser;
	Laser.client = npc.Ally;
	Laser.DoForwardTrace_Basic(-1.0);

	int canIsee = Check_Line_Of_Sight(Laser.End_Point, npc.Ally, npc.index);

	Return_Loc = Laser.End_Point;

	if(canIsee == npc.index)
		return true;

	if(IsValidEnemy(npc.index, npc.m_iTarget))
		canIsee = Check_Line_Of_Sight(Laser.End_Point, npc.Ally, npc.m_iTarget);
	return (canIsee == npc.m_iTarget);
}
static int Check_Line_Of_Sight(float pos_npc[3], int attacker, int enemy)
{
	Ruina_Laser_Logic Laser;
	Laser.client = attacker;
	Laser.Start_Point = pos_npc;

	float Enemy_Loc[3], vecAngles[3];
	//get the enemy gamer's location.
	GetAbsOrigin(enemy, Enemy_Loc);
	//get the angles from the current location of the crystal to the enemy gamer
	MakeVectorFromPoints(pos_npc, Enemy_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	//get the estimated distance to the enemy gamer,
	float Dist = GetVectorDistance(Enemy_Loc, pos_npc);
	//do a trace from the current location of the crystal to the enemy gamer.
	Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.

	float Trace_Loc[3];
	Trace_Loc = Laser.End_Point;	//get the end location of the trace.
	//see if the vectors match up, if they do we can safely say the target is in line of sight of the origin npc/loc
	if(Similar_Vec(Trace_Loc, Enemy_Loc))
		return enemy;
	else
		return -1;
}


static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Karlas npc = view_as<Karlas>(victim);
		
	int health;
	health = GetEntProp(victim, Prop_Data, "m_iHealth");
	int KarlasMaxHealth = ReturnEntityMaxHealth(victim);
	if(health < (KarlasMaxHealth / 2) && !npc.m_fbRangedSpecialOn)
	{
		npc.m_fbRangedSpecialOn = true;
		CPrintToChatAll("{crimson}카를라스의 체력이 절반 이하가 되자, 그의 치유 배낭이 파괴되었습니다. 그는 더 이상 스텔라를 치료할 수 없게 되었습니다...");
	}
	if(RoundToCeil(damage) >= health && !npc.m_flInvulnerability && i_current_wave[npc.index] > 10)
	{
		ApplyStatusEffect(victim, victim, "Infinite Will", 15.0);
		ApplyStatusEffect(victim, victim, "Hardened Aura", 15.0);
		int ally = npc.Ally;
		if(IsValidEntity(ally))
		{
			ApplyStatusEffect(ally, ally, "Extreme Anxiety", 999.0);
			switch(GetRandomInt(0, 1))
			{
				case 0: CPrintToChatAll("{crimson}카를라스{snow}: *거친 숨소리*");
				case 1: CPrintToChatAll("{crimson}카를라스{snow}: *고통스러워하는 한숨소리*");
			}
			RaidModeTime +=17.0; //Extra time due to invuln
		
			Stella donner = view_as<Stella>(ally);
			donner.Anger=true;
			ApplyStatusEffect(npc.index, npc.index, "Hardened Aura", 15.0);
			ApplyStatusEffect(ally, ally, "Hardened Aura", 15.0);

			ApplyStatusEffect(npc.index, npc.index, "Ruina's Defense", 999.0);
			NpcStats_RuinaDefenseStengthen(npc.index, 0.8);	//20% resistances
			ApplyStatusEffect(npc.index, npc.index, "Ruina's Agility", 999.0);
			NpcStats_RuinaAgilityStengthen(npc.index, 1.15);//15% speed bonus, going bellow 1.0 will make npc's slower
			ApplyStatusEffect(npc.index, npc.index, "Ruina's Damage", 999.0);
			NpcStats_RuinaDamageStengthen(npc.index, 0.1);	//10% dmg bonus
			
			ApplyStatusEffect(npc.Ally, npc.Ally, "Ruina's Defense", 999.0);
			NpcStats_RuinaDefenseStengthen(npc.Ally, 0.8);	//20% resistances
			ApplyStatusEffect(npc.Ally, npc.Ally, "Ruina's Agility", 999.0);
			NpcStats_RuinaAgilityStengthen(npc.Ally, 1.15);	//15% speed bonus, going bellow 1.0 will make npc's slower
			ApplyStatusEffect(npc.Ally, npc.Ally, "Ruina's Damage", 999.0);
			NpcStats_RuinaDamageStengthen(npc.Ally, 0.1);	//10% dmg bonus

			ApplyStatusEffect(npc.index, npc.index, "Ancient Melodies", 999.0);
			ApplyStatusEffect(ally, ally, "Ancient Melodies", 999.0);
		}
		npc.m_flInvulnerability = 1.0;
	}
	

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

	//stella is dead, its wave 20 or beyond, health is less then 80% we are not teleporting, we are not being lockedon by stella, we are not doing an animation
	if(!b_angered_twice[npc.index] && wave >=20 && (!IsValidAlly(npc.index, npc.Ally) || b_allow_karlas_transform[npc.index]) && Health/MaxHealth<=0.8 && !b_teleport_strike_active[npc.index] && npc.m_flNC_LockedOn < GetGameTime(npc.index) && npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		b_allow_karlas_transform[npc.index] = false;
		b_angered_twice[npc.index]=true;
		npc.m_flNextChargeSpecialAttack = GetGameTime()+8.0;
		npc.m_bisWalking = false;
		npc.LanceState(false);
		npc.AddActivityViaSequence("taunt_the_fist_bump");
		npc.SetPlaybackRate(0.2);	
		npc.SetCycle(0.01);
		npc.Anger = true;

		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
		ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	

		if(npc.m_flSlicerBarrageActive > GetGameTime(npc.index))
		{
			npc.m_flSlicerBarrageCD = GetGameTime(npc.index) + 20.0;
			npc.m_iSlicersFired = 0;
		}

		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		npc.PlayAngerSound();

		Karlas_Lifeloss_Initialize(npc);

		npc.m_flSpeed=0.0;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

static void Karlas_Lifeloss_Initialize(Karlas npc)
{
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	npc.m_iWearable7 = npc.EquipItemSeperate(KARLAS_LIGHT_MODEL ,_,_,_,300.0);
	
}
static void Karlas_Lifeloss_Logic(Karlas npc)
{
	if(!b_swords_created[npc.index])
	{
		b_swords_created[npc.index]=true;
		//CPrintToChatAll("Swords created.");

		fl_karlas_sword_battery[npc.index] = GetGameTime() + 30.0;

		float Loc[3];
		GetAbsOrigin(npc.index, Loc);

		for(int i=0 ; i < KARLAS_SWORDS_AMT ; i++)
		{
			int sword = Create_Blade(Loc, 2.0, npc);
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
		Karlas_Manipulate_Sword_Location(npc, Loc, Loc2, GetGameTime(), speed, 20.0*RaidModeScaling);	//they are spinning up, so deal lotsa damage
	}
}
static void Karlas_SwordWings_Logic(Karlas npc, float npc_Vec[3])
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

	for(int i=0 ; i < KARLAS_SWORDS_AMT ; i++)
	{
		float tempAngles[3], Direction[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = angles[1];
		tempAngles[2] = fl_spinning_angle[npc.index] + (float(i) * (360.0/KARLAS_SWORDS_AMT));
			
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
			Karlas_Move_Entity(sword, EndLoc, Ang);
		}
	}
}
static void Karlas_Manipulate_Sword_Location(Karlas npc, float Loc[3], float Look_Vec[3], float GameTime, float spin_speed, float dmg)
{
	if(b_lostOVERDRIVE[npc.index])
		spin_speed = 20.0;
	fl_spinning_angle[npc.index] +=spin_speed;

	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index]=0.0;

	float Range = 175.0;

	float Player_Pos[3]; Player_Pos = Loc;

	for(int i=0 ; i < KARLAS_SWORDS_AMT ; i++)
	{
		float tempAngles[3], Direction[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = fl_spinning_angle[npc.index] + (float(i) * (360.0/KARLAS_SWORDS_AMT));
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

			Karlas_Move_Entity(sword, EndLoc, Ang);
			
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

			if(fl_dance_of_light_sword_throttle[npc.index][i] < GameTime)
			{
				fl_dance_of_light_sword_throttle[npc.index][i] = GameTime+0.1;
				Karlas_Laser_Trace(npc, Sword_Loc, Loc2, 10.0, dmg);
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
static void Karlas_Move_Entity(int entity, float loc[3], float Ang[3])
{
	if(!IsValidEntity(entity))	
		return;

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
static void Karlas_Laser_Trace(Karlas npc, float Start_Point[3], float End_Point[3], float Radius, float dps)
{
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.Damage = dps;
	Laser.Bonus_Damage = dps*6.0;
	Laser.Radius = Radius;
	Laser.Start_Point = Start_Point;
	Laser.End_Point = End_Point;
	Laser.Deal_Damage(OnBladeHit);
}
static void OnBladeHit(int client, int target, int damagetype, float damage)
{
	Emit_Sword_Impact_Sound(target);
	if(target <= MaxClients)
		Client_Shake(target, 0, 8.0, 8.0, 0.1);
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])	//Why On GODS EARTH DID I MAKE THE INPUT/OUTPUT IN THE WRONG ORDER, LIKE WHY/???????
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static int Create_Blade(float Loc[3], float size, Karlas npc)
{
	int prop = CreateEntityByName("prop_physics_override");
	
	if(!IsValidEntity(prop))
		return -1;
	
	DispatchKeyValue(prop, "model", RUINA_POINT_MODEL);
	DispatchKeyValue(prop, "modelscale", "0.01");	
	DispatchKeyValue(prop, "solid", "0"); 
	DispatchSpawn(prop);
	ActivateEntity(prop);

	int ModelApply = ApplyCustomModelToWandProjectile(prop, RUINA_CUSTOM_MODELS_2, size, "");
	if(IsValidEntity(ModelApply))
	{
		SetEntPropEnt(ModelApply, Prop_Send, "m_hOwnerEntity", npc.index);
		float angles[3];
		GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
		angles[2]+=90.0;
		TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
		SetVariantInt(RUINA_ZANGETSU);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
		
		/*
		//idk why but the glow doesn't work.
		CClotBody sword = view_as<CClotBody>(ModelApply);
		sword.m_iTeamGlow = TF2_CreateGlow(npc.index);
		sword.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({3, 244, 252, 200}));
		AcceptEntityInput(sword.m_iTeamGlow, "SetGlowColor");
		*/
	}
	MakeObjectIntangeable(prop);
	TeleportEntity(prop, Loc, NULL_VECTOR, NULL_VECTOR);
	return prop;
}

static void Delete_Swords(int client)
{
	for(int i=0 ; i < KARLAS_SWORDS_AMT ; i++)
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
	ExpidonsaRemoveEffects(entity);
	RaidModeScaling *= 1.2;
	RaidModeTime +=30.0;

	if(b_tripple_raid[npc.index])
	{
		Twirl_OnStellaKarlasDeath();
	}

	if(npc.Ally)
	{
		Stella stella = view_as<Stella>(ally);
		if(!stella.m_bSaidWinLine)
		{
			if(!b_bobwave[npc.index])
			{
				ApplyStatusEffect(stella.index, stella.index, "Extreme Anxiety", 999.0);
				switch(GetRandomInt(1,3))
				{
					case 1: Stella_Lines(stella,"흠, 어쩔 수 없이 나 혼자 처리해야하나.");
					case 2: Stella_Lines(stella,"아직 끝나지 않았어..");
					case 3: Stella_Lines(stella,"감히 {crimson}카를라스{snow}에게 손을 대다니!");
				}
			}
		}
	}
	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

	ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
		
	Delete_Swords(npc.index);
	
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
		RaidBossActive = INVALID_ENT_REFERENCE;
			
	npc.m_bThisNpcIsABoss = false;
	b_thisNpcIsARaid[npc.index] = false;
		
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
	if(IsValidEntity(npc.m_iWingSlot))
		RemoveEntity(npc.m_iWingSlot);

	if(IsValidEntity(npc.m_iParticles1))
		RemoveEntity(npc.m_iParticles1);
		
}
static Action Karlas_Timer_Move_Particle(Handle timer, DataPack pack)
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
static void Karlas_Teleport_Effect(char type[255], float duration = 0.0, float start_point[3], float end_point[3])
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
		CreateDataTimer(0.1, Karlas_Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
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


void KarlasEarsApply(int iNpc, char[] attachment = "head", float size = 1.0)
{
	int red = 255;
	int green = 125;
	int blue = 125;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	float DoApply[3];
	DoApply = {0.0,-2.5,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,-6.0,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,-8.0,3.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4 = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	
	//fist ear
	DoApply = {0.0,2.5,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears2_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,6.0,-5.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears3_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by
	DoApply = {0.0,8.0,3.0};
	DoApply[0] *= size;
	DoApply[1] *= size;
	DoApply[2] *= size;
	int particle_ears4_r = InfoTargetParentAt(DoApply, "", 0.0); //First offset we go by

	SetParent(particle_ears1, particle_ears2, "",_, true);
	SetParent(particle_ears1, particle_ears3, "",_, true);
	SetParent(particle_ears1, particle_ears4, "",_, true);
	SetParent(particle_ears1, particle_ears2_r, "",_, true);
	SetParent(particle_ears1, particle_ears3_r, "",_, true);
	SetParent(particle_ears1, particle_ears4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_ears1, flPos);
	SetEntPropVector(particle_ears1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_ears1, attachment,_);


	int Laser_ears_1 = ConnectWithBeamClient(particle_ears4, particle_ears2, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2 = ConnectWithBeamClient(particle_ears4, particle_ears3, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);

	int Laser_ears_1_r = ConnectWithBeamClient(particle_ears4_r, particle_ears2_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	int Laser_ears_2_r = ConnectWithBeamClient(particle_ears4_r, particle_ears3_r, red, green, blue, 1.0 * size, 1.0 * size, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][3] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][4] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][5] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][6] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][7] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][8] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][9] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][10] = EntIndexToEntRef(Laser_ears_2_r);
}


public Action Fusion_RepeatSound_Doublevoice(Handle timer, DataPack pack)
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