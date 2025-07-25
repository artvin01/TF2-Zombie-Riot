#pragma semicolon 1
#pragma newdecls required


#define Nemal_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define Nemal_LASER_THICKNESS 25




static float f_TimeSinceHasBeenHurt[MAXENTITIES];

static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};


static bool TripleLol;
static float NemalAntiLaserDo[MAXENTITIES];

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};



static const char g_MissAbilitySound[][] = {
	"vo/soldier_negativevocalization01.mp3",
	"vo/soldier_negativevocalization02.mp3",
	"vo/soldier_negativevocalization03.mp3",
	"vo/soldier_negativevocalization04.mp3",
	"vo/soldier_negativevocalization05.mp3",
	"vo/soldier_negativevocalization06.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"npc/combine_gunship/attack_start2.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

static const char g_NemalShootSnipeShot[][] = {
	"npc/strider/fire.wav",
};

static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};

static char g_AngerSounds[][] = {
	"vo/medic_sf12_goodmagic01.mp3",
};

static char g_SyctheHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};

static char g_SyctheInitiateSound[][] = {
	"npc/env_headcrabcanister/incoming.wav",
};


static char g_AngerSoundsPassed[][] = {
	"vo/medic_sf12_taunts03.mp3",
};

static const char g_LaserGlobalAttackSound[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};


static const char g_AngellicaShooting[][] = {
	"weapons/widow_maker_shot_01.wav",
	"weapons/widow_maker_shot_02.wav",
	"weapons/widow_maker_shot_03.wav",
};

static const char g_AngellicaShootingHit[][] = {
	"npc/scanner/scanner_electric1.wav",
};
static const char g_MineLayed[][] = {
	"weapons/mortar/mortar_explode2.wav",
};


#define NEMAL_AIRSLICE_HIT	"npc/scanner/scanner_electric1.wav"
static bool b_RageAnimated[MAXENTITIES];

void Nemal_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nemal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nemal");
	strcopy(data.Icon, sizeof(data.Icon), "nemal");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheSound("ambient/energy/whiteflash.wav");
	PrecacheSound("ambient/energy/weld1.wav");
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultMedic_HurtSounds));		i++) { PrecacheSound(g_DefaultMedic_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_NemalShootSnipeShot)); i++) { PrecacheSound(g_NemalShootSnipeShot[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }
	for (int i = 0; i < (sizeof(g_AngellicaShooting));   i++) { PrecacheSound(g_AngellicaShooting[i]);   }
	for (int i = 0; i < (sizeof(g_AngellicaShootingHit));   i++) { PrecacheSound(g_AngellicaShootingHit[i]);   }
	for (int i = 0; i < (sizeof(g_MineLayed));   i++) { PrecacheSound(g_MineLayed[i]);   }
	PrecacheModel("models/player/soldier.mdl");
	PrecacheSoundCustom("#zombiesurvival/iberia/nemal_raid.mp3");
	PrecacheSoundCustom("#zombiesurvival/iberia/expidonsa_training_montage.mp3");
	PrecacheSound(NEMAL_AIRSLICE_HIT);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Nemal(vecPos, vecAng, team, data);
}

methodmap Nemal < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_NemalMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_NemalRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_NemalRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property int m_iNemalComboAttack
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iPlayerScaledStart
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property float m_flTimeUntillMark
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flNemalSlicerCD
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property float m_flNemalSlicerHappening
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsHappeningCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flNemalSniperShotsLaserThrottle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flNemalAirbornAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}

	property float m_flNemalPlaceAirMines
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flNemalPlaceAirMinesCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flNemalSuperRes
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}

	
	property float m_flNemalSummonSilvesterCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flNemalSummonSilvesterHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}

	public void PlayAngerSoundPassed() 
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);

		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_STATIC, 80, _, 0.8);
	}
	public void PlaySytheInitSound() {
	
		int sound = GetRandomInt(0, sizeof(g_SyctheInitiateSound) - 1);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SyctheInitiateSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 105);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 105);
		
	}
	
	public void PlayMissSound() 
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
	}
	public void PlayAngellicaShotSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngellicaShooting) - 1);
		EmitSoundToAll(g_AngellicaShooting[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
		EmitSoundToAll(g_AngellicaShooting[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
	}
	public void PlayAngellicaShotHitSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_AngellicaShootingHit) - 1);
		EmitSoundToAll(g_AngellicaShootingHit[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
		EmitSoundToAll(g_AngellicaShootingHit[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 120);
	}
	public void PlayMineLayed() 
	{
		int sound = GetRandomInt(0, sizeof(g_MineLayed) - 1);
		EmitSoundToAll(g_MineLayed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 120);
		EmitSoundToAll(g_MineLayed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 120);
		EmitSoundToAll(g_MineLayed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 120);
	}
	public void PlayShootSoundNemalSnipe() 
	{
		EmitSoundToAll(g_NemalShootSnipeShot[GetRandomInt(0, sizeof(g_NemalShootSnipeShot) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
		EmitSoundToAll(g_NemalShootSnipeShot[GetRandomInt(0, sizeof(g_NemalShootSnipeShot) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	
	
	public Nemal(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Nemal npc = view_as<Nemal>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		npc.m_iNemalComboAttack = 0;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		Zero(NemalAntiLaserDo);
		npc.m_flTimeUntillMark = GetGameTime(npc.index) + 15.0;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 320.0;
		npc.i_GunMode = 0;
		npc.m_flNemalSniperShotsHappening = 0.0;
		npc.m_flNemalSlicerCD = GetGameTime() + 8.0;
		npc.m_flNemalSniperShotsHappeningCD = GetGameTime() + 25.0;
		npc.m_flNemalPlaceAirMinesCD = GetGameTime() + 15.0;
		BlockLoseSay = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		npc.m_flNemalSummonSilvesterCD = GetGameTime() + 30.0;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		
		b_angered_twice[npc.index] = false;
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		RemoveAllDamageAddition();
		

		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;
		if(StrContains(data, "wave_10") != -1)
		{
			f_ExplodeDamageVulnerabilityNpc[npc.index] = 1.0;
			i_RaidGrantExtra[npc.index] = 1;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Were supposed to train our abilities, remember? Well here i am! Lets start off easy!");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: {gold}Silvester{default}? Where are you?... \nLate again... \nThis dude... \nHe'll come later, let's start off relaxed!");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: {gold}Silvester{default} is late isnt he? Probably off to some random beach with {blue}Sensal{default} as usual.. without me!!!\nWe said vacation is after this! oh well, lets begin!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Iberians are with us {gold}Expidonsans{default}!... But im kinda both...\nProbably not that important, anyways lets go!");
				}
			}
		}
		if(StrContains(data, "wave_20") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Got a call, {gold}Silvester{default} will be joining soon, he had some buisness apperantly, get ready for... when he comes!");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: What i would do for {darkblue}Waldch{default} to stop being so mangetic to {gold}Silvester{default} with his Wildingen antics, that isnt his home!!!");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I'll be honest, {blue}Sensal's{default} kinda scary, i mean you fought him, you'd know!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: There sadly aint many Iberians left after what happend to their home country, damn traitorous {blue}seaborn{default}... we took in the surviving iberians and helped them!");
				}
			}
		}
		if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Enough chatter, i'll start to not restrain myself.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: {blue}Sensal{default} wasnt lying when he said you guys got some tricks.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Iberian's have some really widening history, eventually it'll be rebuilt with {gold}Expidonsa's{default} help.");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: {blue}Seaborns{default} and us had some treaty yknow... before they attacked everyone... Thats how we have the idea of what {green}Defenda's{default} are using.");
				}
			}
		}
		if(StrContains(data, "wave_40") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Look's like i have to give it all.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I wont hold back anymore.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Ready yourself.");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I would worry about you, but i don't think thats neccecary.");
				}
			}
		}
		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 5;
			b_NpcUnableToDie[npc.index] = true;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Look's like i have to give it all.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I wont hold back anymore.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Ready yourself.");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I would worry about you, but i don't think thats neccecary.");
				}
			}
		}

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Nemal Arrived");
			}
		}
		NemalEffects(npc.index, 0);

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

		if(value > 35)
		{
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.7;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();

		npc.m_iPlayerScaledStart = CountPlayersOnRed();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}

		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		TripleLol = false;
		if(!StrContains(data, "triple_enemies"))
		{
			TripleLol = true;
			i_RaidGrantExtra[npc.index] = 4;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Sorry {blue}Sensal's{default} he's comming a bit late.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Hey {blue}Sensal's{default}, im here.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Isnt this overkill?");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Sorry but thats all.");
				}
			}
		}
		if(!TripleLol)
		{
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Nemal_Win);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/iberia/nemal_raid.mp3");
			music.Time = 158;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Morning Moon");
			strcopy(music.Artist, sizeof(music.Artist), "Hopeku");
			Music_SetRaidMusic(music);
		}

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
	//	Weapon slot
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_templar_hood/sf14_templar_hood.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({125, 125, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Nemal npc = view_as<Nemal>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NemalTalkPostWin(npc))
		return;

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: You dont beat me, then youll never be able to face the full force of the {purple}void{default}.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Not beating me means no beating the {purple}void{default}.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Use that adrenaline against me, come on!");
				}
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: Well... Theres next time.");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: Too tired today? I get it.");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: I'm sorry but this is needed, this is training not a daycare.");
			}
		}
		return;
	}
	float TotalArmor = 1.0;
	if(npc.m_flNemalSuperRes > GetGameTime())
	{
		TotalArmor *= 0.25;
	}

	if(npc.Anger)
		TotalArmor *= 0.95;

	fl_TotalArmor[iNPC] = TotalArmor;
	if(RaidModeTime < GetGameTime())
	{
	//	DeleteAndRemoveAllNpcs = 10.0;
	//	mp_bonusroundtime.IntValue = (6 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: You won't defeat {purple}it{default} with that speed.");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: ... Don't dissapoint {darkblue}Kahmlstein{default} like this...");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: As much of an ass{darkblue}Kahmlstein{default} was... he did have something in him.");
			}
		}
		BlockLoseSay = true;
	}

	if(NemalTransformation(npc))
		return;


	if(!npc.Anger)
	{
		if(NemalSwordSlicer(npc))
			return;

		if(NemalSnipingShots(npc))
			return;

		if(NemalMarkAreas(npc))
			return;
	}

	if(NemalSummonSilvester(npc))
		return;

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;


	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}


	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive = EntIndexToEntRef(npc.index);
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		if(!npc.Anger)
			SetGoalVectorIndex = NemalSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		else
			SetGoalVectorIndex = NemalSelfDefenseRage(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

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

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				if(npc.Anger)
				{			
					npc.m_flSpeed = 400.0;
				}
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
				if(npc.Anger)
				{			
					npc.m_flSpeed = 350.0;
				}
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

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		NemalAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Nemal npc = view_as<Nemal>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		
	
	if(((ReturnEntityMaxHealth(npc.index) * 3)/4) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth") - damage)) //npc.Anger after half hp/400 hp
	{
		if(npc.m_flNemalSummonSilvesterCD != FAR_FUTURE)
			npc.m_flNemalSummonSilvesterCD = 0.0;
	}
	if(i_RaidGrantExtra[npc.index] >= 3)
	{
		if((ReturnEntityMaxHealth(npc.index)/10) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth") - damage) && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 3.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 60.0;
			npc.m_bisWalking = false;
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/9);
			CPrintToChatAll("{lightblue}Nemal{default}: Hey man, you're really hurting me here...");
			npc.i_GunMode = 0;
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	if(i_RaidGrantExtra[npc.index] == 5)
	{
		if(!b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] && RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

		//	ReviveAll(true);

			b_angered_twice[npc.index] = true; 
			i_SaidLineAlready[npc.index] = 0; 
			f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;
			RaidModeTime += 25.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);
			MakeObjectIntangeable(npc.index);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			
			CPrintToChatAll("{lightblue}Nemal{default}: Ouch ouch! Time out, time out!");
			npc.m_iTarget = 0;

			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	Nemal_Weapon_Lines(npc, attacker);

	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_Nemal_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}

static void Internal_NPCDeath(int entity)
{
	Nemal npc = view_as<Nemal>(entity);
	/*
		Explode on death code here please
	*/
	ExpidonsaRemoveEffects(npc.index);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	
	RaidModeTime += 20.0;

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

	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}					
	}
	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{lightblue}Nemal{default}: Okay... ouch.. ow...");
		}
		case 1:
		{
			CPrintToChatAll("{lightblue}Nemal{default}: Okay Okay you won! For now.");
		}
		case 2:
		{
			CPrintToChatAll("{lightblue}Nemal{default}: See you next time.... this hurts..");
		}
		case 3:
		{
			CPrintToChatAll("{lightblue}Nemal{default}: I was going to insult you, but i asked for this...");
		}
	}

}
/*


*/
void NemalAnimationChange(Nemal npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	if(npc.Anger)
	{
		if (npc.IsOnGround())
		{
			if(npc.m_iChanged_WalkCycle != 8)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 8;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.StartPathing();
				npc.m_flSpeed = 350.0;
			}	
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 7)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 7;
				npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
				npc.StartPathing();
				npc.m_flSpeed = 350.0;
			}	
		}
		return;
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 5)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_CROUCHWALK_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 150.0;
					npc.m_bAllowBackWalking = true;
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					}
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 6)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_MP_CROUCHWALK_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 150.0;
					npc.m_bAllowBackWalking = true;
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					}
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					}
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					if(!IsValidEntity(npc.m_iWearable1))
					{
						npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
					}
				}	
			}
		}
	}

}
int NemalSelfDefenseRage(Nemal npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			bool GotLastCharge = false;
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, target,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				bool WasPlayerOnly = false;
				bool DontGiveStack = false;
				bool ResetStack = false;
				if(npc.m_iNemalComboAttack >= 3)
				{
					DontGiveStack = true;
				}	
				float origin[3], angles[3];
				view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
				int colorLayer4[4];
				float diameter = float(10 * 2);
				int r = 125;
				int g = 125;
				int b = 255;
				SetColorRGBA(colorLayer4, r, g, b, 60);
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							if(npc.m_iNemalComboAttack >= 3)
							{
								//if they already have teslar, do stronger one
								if(NpcStats_IsEnemyTeslar(targetTrace, false) || NpcStats_IsEnemyTeslar(targetTrace, true))
								{
									ApplyStatusEffect(npc.index, targetTrace, "Teslar Electricution", 5.0);
								}

								ApplyStatusEffect(npc.index, targetTrace, "Teslar Shock", 5.0);

								ResetStack = true;
							}
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 35.0;
							

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
							// Hit particle
							
							
							SetColorRGBA(colorLayer4, r, g, b, 60);
							TE_SetupBeamPoints(origin, vecHit, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer4, 3);
							TE_SendToAll(0.0);
							TE_SetupBeamPoints(origin, vecHit, Shared_BEAM_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0,  colorLayer4, 3);
							TE_SendToAll(0.0);
							TE_SetupBeamPoints(origin, vecHit, g_Ruina_BEAM_Combine_Black, 0, 0, 66, 0.22, ClampBeamWidth(diameter * 0.4 * 1.28), ClampBeamWidth(diameter * 0.4 * 1.28), 0, 1.0,  {255,255,255,125}, 3);
							TE_SendToAll(0.0);

							TE_SetupBeamPoints(origin, vecHit, Shared_BEAM_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, colorLayer4, 1);
							TE_SendToAll(0.0);
							if(targetTrace <= MaxClients)
								WasPlayerOnly = true;
							
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
						} 
					}
				}
				if(PlaySound)
				{
					//Do Hit Effect
					float flMaxhealth = float(ReturnEntityMaxHealth(npc.index));
					flMaxhealth *= 0.0025;
					if(!WasPlayerOnly)
					{
						flMaxhealth *= 0.5;
					}
					if(i_RaidGrantExtra[npc.index] >= 4)
					{
						flMaxhealth *= 0.75;
					}
					flMaxhealth *= NpcDoHealthRegenScaling();
					HealEntityGlobal(npc.index, npc.index, flMaxhealth, 0.15, 0.0, HEAL_SELFHEAL);
					if(!DontGiveStack)
					{
						npc.m_iNemalComboAttack++;
						if(npc.m_iNemalComboAttack >= 3)
							GotLastCharge = true;
					}
						
					npc.PlayAngellicaShotHitSound();
				}
				if(ResetStack)
				{
					if(npc.m_iNemalComboAttack >= 3)
						npc.m_iNemalComboAttack = 0;
				}
			}

			if(npc.m_iNemalComboAttack >= 3 && !GotLastCharge)
			{
				//Missed or hit, idk, reset combo
				npc.m_iNemalComboAttack = 0;
			}
		}
	}
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.3))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayAngellicaShotSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
							
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					if(npc.i_GunMode >= 2)
					{
						npc.m_flNextMeleeAttack = gameTime + 0.025;
						npc.i_GunMode = -1;
					}
					else
					{
						npc.i_GunMode++;
					}
					npc.m_flAttackHappens = GetGameTime(npc.index);
					npc.m_flDoingAnimation = GetGameTime(npc.index);
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}

	if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.6))
	{
		//target is too far, try to close in
		return 0;
	}
	else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.1))
	{
		if(Can_I_See_Enemy_Only(npc.index, target))
		{
			//target is too close, try to keep distance
			return 1;
		}
	}
	return 0;
}
int NemalSelfDefense(Nemal npc, float gameTime, int target, float distance)
{
	if(npc.m_flNemalPlaceAirMinesCD < GetGameTime(npc.index))
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_flDoingAnimation = gameTime + 99.9;
			npc.m_flNemalPlaceAirMines = gameTime + 2.0;
			npc.m_flNemalPlaceAirMinesCD = gameTime + 30.0;
			if(i_RaidGrantExtra[npc.index] >= 4)
				npc.m_flNemalPlaceAirMinesCD = gameTime + 25.0;

			npc.m_flAttackHappens = 0.0;
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_cheers_medic");
			if(i_RaidGrantExtra[npc.index] >= 4)
			{
				npc.SetPlaybackRate(1.5);	
				npc.m_flNemalPlaceAirMines = gameTime + 1.33;
			}
			
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			npc.SetCycle(0.05);
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iChanged_WalkCycle = 0;
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "eb_beam_angry_core03", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		}		
	}
	else if(npc.m_flNemalSniperShotsHappeningCD < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 2)
	{				
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_flDoingAnimation = gameTime + 99.9;
			npc.m_flNemalSniperShotsHappening = gameTime + 1.0;
			npc.m_flNemalSniperShotsHappeningCD = gameTime + 30.0;
			npc.m_flAttackHappens = 0.0;
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			npc.SetCycle(0.05);
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iChanged_WalkCycle = 0;
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_breaker_green_parent", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		}
	}
	else if(npc.m_flNemalSlicerCD < GetGameTime(npc.index))
	{				
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			npc.i_GunMode = 1;
			npc.m_flNemalSlicerCD = gameTime + 22.0;
			npc.StopPathing();
			
			npc.m_flAttackHappens = GetGameTime(npc.index) + 1.5;
			npc.m_flNemalSlicerHappening = gameTime + 4.5;
			EmitSoundToAll("ambient/energy/whiteflash.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 100);
			EmitSoundToAll("ambient/energy/whiteflash.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 100);
			float flPos[3];
			float flAng[3];
			npc.m_iChanged_WalkCycle = 0;
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});

			NemalAnimationChange(npc);
		}
	}
	if(npc.m_flTimeUntillMark < gameTime)
	{
		if(!IsValidEntity(npc.m_iWearable7))
		{
			float flPos[3]; // original
			float flAng[3]; // original
			npc.GetAttachment("head", flPos, flAng);
			npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "mark_for_death", npc.index, "head", {0.0,0.0,7.0});
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable7))
		{
			RemoveEntity(npc.m_iWearable7);
		}
	}
	if(npc.m_iNemalComboAttack >= 3)
	{
		//weapon
		if(!IsValidEntity(npc.m_iWearable6))
		{
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			int particle = ParticleEffectAt(flPos, "utaunt_electric_mist");
			SetParent(npc.index, particle);
			npc.m_iWearable6 = particle;
		}
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSALPHA);
			SetEntityRenderColor(npc.m_iWearable1, 192, 192, 255, 125);
			int LaserEntity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[npc.index][14]);
			
			if(IsValidEntity(LaserEntity))
			{
				SetEntityRenderColor(LaserEntity, 192, 192, 255, 255);
				SetEntPropFloat(LaserEntity, Prop_Data, "m_fWidth", 2.0);
				SetEntPropFloat(LaserEntity, Prop_Data, "m_fEndWidth", 2.0);

				SetEntPropFloat(LaserEntity, Prop_Data, "m_fAmplitude", 10.0);
			}
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable1))
		{
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		}
		if(IsValidEntity(npc.m_iWearable6))
		{
			RemoveEntity(npc.m_iWearable6);
		}
		int LaserEntity = EntRefToEntIndex(i_ExpidonsaEnergyEffect[npc.index][14]);
		if(IsValidEntity(LaserEntity))
		{
			SetEntityRenderColor(LaserEntity, 255, 255, 255, 255);
			SetEntPropFloat(LaserEntity, Prop_Data, "m_fWidth", 1.0);
			SetEntPropFloat(LaserEntity, Prop_Data, "m_fEndWidth", 1.0);

			SetEntPropFloat(LaserEntity, Prop_Data, "m_fAmplitude", 1.0);
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			bool GotLastCharge = false;
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				bool DontGiveStack = false;
				bool ResetStack = false;
				bool MarkCooldown = false;
				if(npc.m_iNemalComboAttack >= 3)
				{
					DontGiveStack = true;
				}
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							if(npc.m_iNemalComboAttack >= 3)
							{
								//if they already have teslar, do stronger one
								if(NpcStats_IsEnemyTeslar(targetTrace, false) || NpcStats_IsEnemyTeslar(targetTrace, true))
								{
									ApplyStatusEffect(npc.index, targetTrace, "Teslar Electricution", 5.0);
								}

								ApplyStatusEffect(npc.index, targetTrace, "Teslar Shock", 5.0);

								ResetStack = true;
							}
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 26.0;
							if(npc.m_flTimeUntillMark < GetGameTime(npc.index))
							{
								damage *= 1.35;
								ApplyStatusEffect(npc.index, targetTrace, "Marked", 15.0);
								MarkCooldown = true;
							}
							

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
							// Hit particle
							
						
							
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
							}
										
							if(!NpcStats_IberiaIsEnemyMarked(targetTrace))
							{
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 450.0, true);
							} 
						} 
					}
				}
				if(MarkCooldown)
				{
					npc.m_flTimeUntillMark = GetGameTime(npc.index) + 15.0;
				}
				if(PlaySound)
				{
					if(!DontGiveStack)
					{
						npc.m_iNemalComboAttack++;
						if(npc.m_iNemalComboAttack >= 3)
							GotLastCharge = true;
					}
						
					npc.PlayMeleeHitSound();
				}
				if(ResetStack)
				{
					if(npc.m_iNemalComboAttack >= 3)
						npc.m_iNemalComboAttack = 0;
				}
			}

			if(npc.m_iNemalComboAttack >= 3 && !GotLastCharge)
			{
				//Missed or hit, idk, reset combo
				npc.m_iNemalComboAttack = 0;
			}
		}
	}
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.75;
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
	return 0;
}


void NemalEffects(int iNpc, int colour = 0, char[] attachment = "head")
{
	if(!attachment[0])
		return;

	if(AtEdictLimit(EDICT_RAID))
		return;
		
	if(colour == 3)
		return;

	int red = 177;
	int green = 156;
	int blue = 216;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	int particle_2 = InfoTargetParentAt({0.0,-2.5,0.0}, "", 0.0); //First offset we go by
	int particle_3 = InfoTargetParentAt({0.0,-6.0,-5.0}, "", 0.0); //First offset we go by
	int particle_4 = InfoTargetParentAt({0.0,-8.0,3.0}, "", 0.0); //First offset we go by
	
	//fist ear
	int particle_2_r = InfoTargetParentAt({0.0,2.5,0.0}, "", 0.0); //First offset we go by
	int particle_3_r = InfoTargetParentAt({0.0,6.0,-5.0}, "", 0.0); //First offset we go by
	int particle_4_r = InfoTargetParentAt({0.0,8.0,3.0}, "", 0.0); //First offset we go by

	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_2_r, "",_, true);
	SetParent(particle_1, particle_3_r, "",_, true);
	SetParent(particle_1, particle_4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_1, attachment,_);


	int Laser_1 = ConnectWithBeamClient(particle_4, particle_2, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_4, particle_3, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);

	int Laser_1_r = ConnectWithBeamClient(particle_4_r, particle_2_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_2_r = ConnectWithBeamClient(particle_4_r, particle_3_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(particle_3);
	i_ExpidonsaEnergyEffect[iNpc][3] = EntIndexToEntRef(particle_4);
	i_ExpidonsaEnergyEffect[iNpc][4] = EntIndexToEntRef(Laser_1);
	i_ExpidonsaEnergyEffect[iNpc][5] = EntIndexToEntRef(Laser_2);
	i_ExpidonsaEnergyEffect[iNpc][6] = EntIndexToEntRef(particle_2_r);
	i_ExpidonsaEnergyEffect[iNpc][7] = EntIndexToEntRef(particle_3_r);
	i_ExpidonsaEnergyEffect[iNpc][8] = EntIndexToEntRef(particle_4_r);
	i_ExpidonsaEnergyEffect[iNpc][9] = EntIndexToEntRef(Laser_1_r);
	i_ExpidonsaEnergyEffect[iNpc][10] = EntIndexToEntRef(Laser_2_r);
	
	NemalEffects2(iNpc, 0, "back_lower");
}
void NemalEffects2(int iNpc, int colour = 0, char[] attachment = "back_lower")
{
	if(!attachment[0])
		return;

	if(AtEdictLimit(EDICT_RAID))
		return;

	if(colour == 3)
		return;

	int red = 255;
	int green = 255;
	int blue = 255;
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	int particle_1_r = InfoTargetParentAt({-10.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	int particle_2 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	SetParent(particle_1, particle_1_r, "",_, true);
	SetParent(iNpc, particle_1, attachment,_);

	SetParent(iNpc, particle_2, "effect_hand_R",_);


	int Laser_1 = ConnectWithBeamClient(particle_1_r, particle_2, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][11] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[iNpc][12] = EntIndexToEntRef(particle_1_r);
	i_ExpidonsaEnergyEffect[iNpc][13] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[iNpc][14] = EntIndexToEntRef(Laser_1);
}

bool NemalTalkPostWin(Nemal npc)
{
	if(!b_angered_twice[npc.index])
		return false;
	
	if(npc.m_iChanged_WalkCycle != 6 && npc.m_iChanged_WalkCycle != 88)
	{
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 6;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		npc.StopPathing();
	}
	
	if(!IsPartnerGivingUpNemalSilv(npc.index))
		return true;
		
	if(npc.m_iChanged_WalkCycle != 88)
	{
		i_SaidLineAlready[npc.index] = 0; 
		npc.m_iChanged_WalkCycle = 88;
		f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;
	}

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
			{
				Music_Stop_All(client); //This is actually more expensive then i thought.
			}
			SetMusicTimer(client, GetTime() + 6);
			fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
		}
	}
	if(GetGameTime() > f_TimeSinceHasBeenHurt[npc.index])
	{
		CPrintToChatAll("{lightblue}Nemal{default}: Till later Mercs!");
		
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		CClotBody allynpc = view_as<CClotBody>(npc.m_iTargetAlly);
		if(IsValidEntity(allynpc.index))
			RequestFrame(KillNpc, EntIndexToEntRef(allynpc.index));

		BlockLoseSay = true;
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
			{
				Items_GiveNamedItem(client, "Iberian and Expidonsan Training");
				CPrintToChat(client,"{default}You feel more skilled and obtain: {gold}''Iberian and Expidonsan Training''{default}!");
			}
		}
	}
	else if(GetGameTime() + 5.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 4)
	{
		i_SaidLineAlready[npc.index] = 4;
		CPrintToChatAll("{lightblue}Nemal{default}: We'll Keep {purple}void gates{default} under controll, tell us when youre ready to kill off the {purple}void{default}  once and for all, as a team!");
	}
	else if(GetGameTime() + 10.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 3)
	{
		i_SaidLineAlready[npc.index] = 3;
		CPrintToChatAll("{lightblue}Nemal{default}: shhh! dont ruin the fun! Eitherways, good job!");
	}
	else if(GetGameTime() + 13.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 2)
	{
		i_SaidLineAlready[npc.index] = 2;
		CPrintToChatAll("{gold}Silvester{default}: Why do you keep pretending you dont know them? Some of them come from a {crimson}Previous{default} era.");
	}
	else if(GetGameTime() + 16.5 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 1)
	{
		i_SaidLineAlready[npc.index] = 1;
		CPrintToChatAll("{lightblue}Nemal{default}: Well thats it! You passed the test and ontop of that, helped eachother, teamwork!.. probably.");
		ReviveAll(true);
	}
	return true; //He is trying to help.
}

bool NemalTransformation(Nemal npc)
{
	if(npc.Anger)
	{
		if(!b_RageAnimated[npc.index])
		{
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_surgeons_squeezebox");
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.01);
			npc.SetPlaybackRate(0.35);	
			b_RageAnimated[npc.index] = true;
			b_CannotBeHeadshot[npc.index] = true;
			b_CannotBeBackstabbed[npc.index] = true;
			ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);		
			ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
			npc.m_flNemalSlicerHappening = 0.0;	
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_god_aquatic_crack3", 3.0);
			npc.m_flSpeed = 0.0;
			npc.m_iChanged_WalkCycle = 0;
			
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
		
		}
	}

	if(npc.m_flNextChargeSpecialAttack)
	{
		if(npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index))
		{
			b_CannotBeHeadshot[npc.index] = false;
			b_CannotBeBackstabbed[npc.index] = false;
			RemoveSpecificBuff(npc.index, "Clear Head");
			RemoveSpecificBuff(npc.index, "Solid Stance");
			RemoveSpecificBuff(npc.index, "Fluid Movement");
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			npc.StartPathing();
			
			npc.m_flNextChargeSpecialAttack = 0.0;
			npc.m_bisWalking = true;
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
			i_NpcWeight[npc.index] = 4;
			npc.m_flRangedArmor = 0.35;
			npc.m_flMeleeArmor = 1.75;		
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 5.0);
			npc.m_flNemalSuperRes = GetGameTime() + 5.0;
			npc.m_flDoingAnimation = 0.0;

			SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 9));
			CPrintToChatAll("{lightblue}Nemal{default}: Here's my finest creation at work!");
				
			SetVariantColor(view_as<int>({255, 255, 255, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			npc.PlayAngerSoundPassed();


			npc.m_flNextRangedSpecialAttack = 0.0;			
			npc.m_flNextRangedAttack = 0.0;		
			npc.m_flNemalSlicerCD = 0.0;	
			//Reset all cooldowns.
		}
		return true;
	}
	return false;
}


bool NemalSnipingShots(Nemal npc)
{
	if(npc.m_flNemalSniperShotsHappening)
	{
		
		//at max 15 targets, anything above that is unneccecary.
		//we dont support more then 1 nemal at a time.
		//This is due to just the array being way too big.
		static float SnipeTargets[MAXENTITIES][3];  
		if(npc.m_flAttackHappens)
		{
			//Enemies currently in vision
			float pos_npc[3];
			float angles_useless[3];
			float PosEnemy[3];
			WorldSpaceCenter(npc.index, pos_npc);
			npc.GetAttachment("effect_hand_r", pos_npc, angles_useless);
			if(npc.m_flAttackHappens - 0.35 > GetGameTime(npc.index))
			{
				UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
				int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
				//itll work wierdly but its needed.
				GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false, npc.m_iWearable8);
				for(int i; i < sizeof(enemy_2); i++)
				{
					if(enemy_2[i] && NemalAntiLaserDo[enemy_2[i]] < GetGameTime())
					{
						int ememyTarget = enemy_2[i];
						WorldSpaceCenter(ememyTarget, PosEnemy);
						float flDistanceToTarget = GetVectorDistance(pos_npc, PosEnemy);
						float SpeedToPredict = flDistanceToTarget * 2.1;
						PredictSubjectPositionForProjectiles(npc, ememyTarget, SpeedToPredict, _,SnipeTargets[ememyTarget]);
					}
				}
			}
			bool DoLaserShow = false;
			if(npc.m_flNemalSniperShotsLaserThrottle < GetGameTime())
			{
				DoLaserShow = true;
				npc.m_flNemalSniperShotsLaserThrottle = GetGameTime() + 0.1;
			}
			for(int Loop = 1; Loop < MAXENTITIES; Loop ++)
			{
				if(SnipeTargets[Loop][1] != 0.0)
				{
					float AngleAim[3];
					GetVectorAnglesTwoPoints(pos_npc, SnipeTargets[Loop], AngleAim);
					Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
					if(TR_DidHit(hTrace))
					{
						TR_GetEndPosition(SnipeTargets[Loop], hTrace);
					}
					delete hTrace;
					if(DoLaserShow)
					{
						TE_SetupBeamPoints(pos_npc, SnipeTargets[Loop], Shared_BEAM_Laser, 0, 0, 0, 0.1, 5.0, 5.0, 0, 0.0, {125,125,255,255}, 3);
						TE_SendToAll(0.0);
					}
				}
			}
			if(npc.m_flAttackHappens < GetGameTime(npc.index))
			{	
				bool PlaySound;
				for(int Loop = 1; Loop < MAXENTITIES; Loop ++)
				{
					if(SnipeTargets[Loop][1] != 0.0)
					{
						TE_SetupBeamPoints(pos_npc, SnipeTargets[Loop], Shared_BEAM_Laser, 0, 0, 0, 0.25, 5.0, 5.0, 5, 0.0, {255,255,255,255}, 3);
						TE_SendToAll(0.0);
						float AngleAim[3];
						GetVectorAnglesTwoPoints(pos_npc, SnipeTargets[Loop], AngleAim);
						Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
						int Traced_Target = TR_GetEntityIndex(hTrace);
						if(Traced_Target > 0)
						{
							WorldSpaceCenter(Traced_Target, SnipeTargets[Loop]);
						}
						else if(TR_DidHit(hTrace))
						{
							TR_GetEndPosition(SnipeTargets[Loop], hTrace);
						}
						delete hTrace;
						int target = Can_I_See_Enemy(npc.index, Loop,_ ,SnipeTargets[Loop]);
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 40.0 * RaidModeScaling;
							if(Loop > MaxClients)
								damageDealt *= 0.5;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, SnipeTargets[Loop]);
						} 
						PlaySound = true;
						DataPack pack_boom = new DataPack();
						pack_boom.WriteFloat(SnipeTargets[Loop][0]);
						pack_boom.WriteFloat(SnipeTargets[Loop][1]);
						pack_boom.WriteFloat(SnipeTargets[Loop][2]);
						pack_boom.WriteCell(0);
						RequestFrame(MakeExplosionFrameLater, pack_boom);
						EmitAmbientSound("ambient/explosions/explode_3.wav", SnipeTargets[Loop], _, 90, _,0.7, GetRandomInt(75, 110));
					}
				}
				if(PlaySound)
				{
					npc.PlayShootSoundNemalSnipe();
				}
				npc.m_flAttackHappens = GetGameTime(npc.index) + 1.0;
				Zero2(SnipeTargets);//rest all!
			}
		}
		if(npc.m_flNemalSniperShotsHappening < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 100)
			{
				//we change animations
				npc.m_flNemalSniperShotsHappening = GetGameTime(npc.index) + 3.1;
				if(i_RaidGrantExtra[npc.index] >= 4)
					npc.m_flNemalSniperShotsHappening = GetGameTime(npc.index) + 4.1;

				npc.m_flAttackHappens = GetGameTime(npc.index) + 1.0;
				npc.m_iChanged_WalkCycle = 100;
				npc.AddActivityViaSequence("taunt_headbutt_start");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(0.05);	
				Zero2(SnipeTargets);//rest all!
				return true;
			}
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flNemalSniperShotsHappening = 0.0;	
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flDoingAnimation = 0.0;
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
		}
		return true;
	}
	return false;
}
static int LastEnemyTargeted[MAXENTITIES];
bool NemalSummonSilvester(Nemal npc)
{
	if(i_RaidGrantExtra[npc.index] < 2)
		return false;

	if(npc.m_flNemalSummonSilvesterHappening)
	{
		if(npc.m_flNemalSummonSilvesterHappening < GetGameTime(npc.index))
		{
			switch(npc.m_iChanged_WalkCycle)
			{
				case 0:
				{
					npc.SetPlaybackRate(0.35);	
					npc.m_iChanged_WalkCycle = 1;
					npc.m_flNemalSummonSilvesterHappening = GetGameTime(npc.index) + 1.0;
				}
				case 1:
				{
					npc.SetPlaybackRate(0.02);	
					npc.m_iChanged_WalkCycle = 2;
					npc.m_flNemalSummonSilvesterHappening = GetGameTime(npc.index) + 2.0;
					Nemal_SpawnAllyDuoRaid(EntIndexToEntRef(npc.index));
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
					npc.PlayDeathSound();	
				}
				case 2:
				{
					switch(GetRandomInt(0,3))
					{
						case 0:
						{
							CPrintToChatAll("{lightblue}Nemal{default}: Ah no worries! I'll totally forgive you!");
						}
						case 1:
						{
							CPrintToChatAll("{lightblue}Nemal{default}: You're such a nut you know that right?");
						}
						case 2:
						{
							CPrintToChatAll("{lightblue}Nemal{default}: Sorry mercs this guy is signed with ''i dont wanna''");
						}
						case 3:
						{
							CPrintToChatAll("{lightblue}Nemal{default}: Just dont attack the same guy as me, thats unfair!");
						}
					}
					npc.m_iChanged_WalkCycle = 3;
					npc.m_flNemalSummonSilvesterHappening = GetGameTime(npc.index) + 1.0;
				}
				case 3:
				{
					
					npc.m_flNemalSummonSilvesterHappening = 0.0;
					b_NpcIsInvulnerable[npc.index] = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flDoingAnimation = 0.0;
					if(npc.Anger)
						npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_dex_shotgun/c_dex_shotgun.mdl");
				}
			}
		}
		return true;
	}
	if(npc.m_flNemalSummonSilvesterCD < GetGameTime(npc.index))
	{
		npc.AddActivityViaSequence("taunt_time_out_therapy");
		npc.SetPlaybackRate(0.02);	
		npc.SetCycle(0.03);
		RaidModeTime += 20.0;
		npc.m_bisWalking = false;
		npc.m_flNemalSummonSilvesterHappening = GetGameTime(npc.index) + 2.0;
		npc.m_flNemalSummonSilvesterCD = FAR_FUTURE;
		npc.m_flNemalSniperShotsHappening = 0.0;
		npc.m_flNemalSlicerHappening = 0.0;
		npc.m_flNemalAirbornAttack = 0.0;
		npc.m_flNemalPlaceAirMines = 0.0;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}

		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: Oh? Looks like {gold}Silvester{default} Is finally comming!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: The lazy ass {gold}cat{default} is comming right up!");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: Hey look, traning partner!");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}Nemal{default}: New phone who this? Oh, you finally came!");
			}
		}
		if(i_RaidGrantExtra[npc.index] >= 3 && !TripleLol)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/iberia/expidonsa_training_montage.mp3");
			music.Time = 300;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Expidonsa Training Montage");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);
		}
		npc.m_iChanged_WalkCycle = 0;
		return true;
	}
	return false;
}
bool NemalSwordSlicer(Nemal npc)
{
	if(npc.m_flNemalSlicerHappening)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.SetGoalEntity(npc.m_iTarget);
			if(npc.m_flAttackHappens < GetGameTime(npc.index))
			{
				int TargetEnemy = false;
				TargetEnemy = GetClosestTarget(npc.index,.ingore_client = LastEnemyTargeted[npc.index],  .CanSee = true, .UseVectorDistance = true);
				LastEnemyTargeted[npc.index] = TargetEnemy;
				if(TargetEnemy == -1)
				{
					TargetEnemy = GetClosestTarget(npc.index, .CanSee = true, .UseVectorDistance = true);
				}
				if(IsValidEnemy(npc.index, TargetEnemy))
				{
					npc.m_flAttackHappens = GetGameTime(npc.index) + 0.25;

					npc.AddGesture("ACT_MP_ATTACK_CROUCH_MELEE_ALLCLASS",_,_,_, 2.0);
					float DamageCalc = 50.0 * RaidModeScaling;
					float VecEnemy[3]; WorldSpaceCenter(TargetEnemy, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					NemalAirSlice(npc.index,TargetEnemy, DamageCalc, 125, 125, 255, 250.0, 6, 1000.0, "flaregun_trail_blue");
					npc.PlayRangedSound();
				}
			}
		}
		if(npc.m_flNemalSlicerHappening < GetGameTime(npc.index))
		{
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flNemalSlicerHappening = 0.0;	
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
		}
		return true;
	}
	return false;
}

static void Nemal_Weapon_Lines(Nemal npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		
		case WEAPON_SENSAL_SCYTHE,WEAPON_SENSAL_SCYTHE_PAP_1,WEAPON_SENSAL_SCYTHE_PAP_2,WEAPON_SENSAL_SCYTHE_PAP_3:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Cool Scythe! Can it be yellow though {gold}%N{default}?",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "I'll let you in on a secret, {blue}Sensal's{default} weapon isnt even from him... its from {gold}Silvester{default}! .... i think, i may be wrong.");
			}
		}
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default} cant stop himself from showing his weapons cant he?",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{blue}Sensal{default} Wasnt kidding when he said {gold}Silvester{default} loves showing off.");
			}
		}
		case WEAPON_SICCERINO,WEAPON_WALDCH_SWORD_NOVISUAL:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Nice pair of Siccors {gold}%N{default}!",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Ever tried Snipping slower?",client);
			}
		} 
		case WEAPON_WALDCH_SWORD_REAL:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Aha! {darkblue}Waldch{default} DID accept my blade!.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{darkblue}Waldch{default} You said you HATED IT!!!!!!!!!!!!");
			}
		}  
		case WEAPON_NEARL:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default} went there too?!.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default}... invite me next time to Kazimierz...");
			}
		} 
		case WEAPON_KAHMLFIST:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "{darkblue}Kahmlstein{default} was a rude asshole, But atleast he reedemed himself.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Trying to keep his memory going {gold}%N{default}? I guess {darkblue}Kahmlstein{default} deserves it after what he did at the end.",client);
			}
		}  
		case WEAPON_KIT_BLITZKRIEG_CORE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Always hated the concept of the machine {crimson}Blitkzrieg{default}...");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Why are you trying to be like it {gold}%N{default}? I guess {crimson}Blitkzrieg{default} was cool...",client);
			}
		}
		case WEAPON_RED_BLADE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "I miss {crimson}Guln{default}.");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "The world was too cruel to {crimson}Guln{default}...");
			}
		}
		case WEAPON_SPIKELAYER:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "OW! WHY LEGOS??");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Just cause i can WALK doesnt mean i gotta step on LEGO.");
			}
		}
		case WEAPON_BOARD:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Big shield {gold}%N{default}, compensating?",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Parry me right... and youll be set for {purple}it{default}.");
			}
		}
		case WEAPON_IRENE:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Hey hey thats my good {snow}friends{default} weapon {gold}%N{default}! She's a very nice Iberian.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Oh {snow}Irene{default}, looks like you have a student, their name is {gold}%N{default}!",client);
			}
		}
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "Were here to train.... why......");
		case WEAPON_ANGELIC_SHOTGUN:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Hey thats my weapon {gold}%N{default}!",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "An one on one battle{gold}%N{default}?",client);
			}
		}
		case WEAPON_HHH_AXE:  Format(Text_Lines, sizeof(Text_Lines), "You're just a little guy {gold}%N{default}! wait ow OW that hurts!!!",client);
		case WEAPON_MLYNAR_PAP_2,WEAPON_MLYNAR_PAP,WEAPON_MLYNAR:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Care {gold}%N{default}, dammit!",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "You arent even fighting me are you {gold}%N{default}?! Get off your paper!",client);
			}
		}
		case WEAPON_TRASH_CANNON:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Your Trash doesnt scare me {gold}%N{default}.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Why is there a bomb in your trash {gold}%N{default}?",client);
			}
		}
		case WEAPON_STAR_SHOOTER:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Hey youre using my Star Shooter {gold}%N{default}!",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Oh how i wanna use that weapon again... can i borrow your Star Shooter {gold}%N{default}?",client);
			}
		}
		case WEAPON_MESSENGER_LAUNCHER:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Messenger's Mind was long gone, i pity him, really...");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "If you see Messenger around, tell him i said hi {gold}%N{default}, okay?",client);
			}
		}
		case WEAPON_FLAMETAIL:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Dont Dodge me!");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Cant dodge forever, {crimson}%N{default}.",client);
			}
		}
		case WEAPON_LEPER_MELEE, WEAPON_LEPER_MELEE_PAP:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "That sword is cool {gold}%N{default}! lets fight like... uh... people.",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "That amazing pose wont scare me off {gold}%N{default}!",client);
			}
		}
		case WEAPON_NECRO_WANDS, WEAPON_SKULL_SERVANT:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Dont mess with the dead {gold}%N{default}, dont want {green}him{default} bugging us....",client);
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "if {green}he{default} comes back im blaming {gold}%N{default}.",client);
			}
		}
		case WEAPON_SEABORN_MISC:
		{
			switch(GetRandomInt(0,1))
			{
				case 0:
					Format(Text_Lines, sizeof(Text_Lines), "Sea creature! Shoo shoo!");
				case 1:
					Format(Text_Lines, sizeof(Text_Lines), "Why are you a Sea Creature {gold}%N{default}? Shoo shoo!",client);
			}
		}

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{lightblue}Nemal{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}


#define MAX_SLICES_ALLOWED 32

bool CurrentSliceIndexAviable[MAX_SLICES_ALLOWED];
bool TargetsHitNemal[MAX_SLICES_ALLOWED][MAXENTITIES];
int EntityBelongsToMasterIndex[MAXENTITIES];

void NemalAirSlice(int iNpc, int target, float damage,int red, int green, int blue, float fatness, int MaxJoints, float speed, char[] Particle, bool GiveDebuff = true)
{
	//This determines on what was hit beforehand, we cant have duplicates!
	int EntityMasterMainIndex = -1;

	for(int TryFindMasterIndex = 0; TryFindMasterIndex < MAX_SLICES_ALLOWED; TryFindMasterIndex ++)
	{
		if(!CurrentSliceIndexAviable[TryFindMasterIndex])
		{
			EntityMasterMainIndex = TryFindMasterIndex;
			CurrentSliceIndexAviable[TryFindMasterIndex] = true;
			break;
		}
	}
	if(EntityMasterMainIndex == -1)
	{
		//somehow no master index was found, cancel.
		return;
	}
	//Reset hits
	for(int Loop = 0; Loop < MAXENTITIES; Loop ++)
	{
		TargetsHitNemal[EntityMasterMainIndex][Loop] = false;
	}

	//First we get the angle between the two entities.
	float vecSelf[3]; 	WorldSpaceCenter(iNpc, vecSelf );
	float VecTarget[3]; WorldSpaceCenter(target, VecTarget );

	if(NpcStats_IberiaIsEnemyMarked(target))
	{
		CClotBody npc = view_as<CClotBody>(iNpc);
		//predict.
		PredictSubjectPositionForProjectiles(npc, target, speed, _,VecTarget);
	}
	float TempAng[3];
	float AngleFromSelf[3];

	MakeVectorFromPoints(vecSelf, VecTarget, TempAng);
	GetVectorAngles(TempAng, AngleFromSelf);
	//It should delete itself if the middle part touches a wall.
	int MasterEntityIndex = Wand_Projectile_Spawn(iNpc, speed, 0.0, 0.0, -1, -1, "", AngleFromSelf,_,vecSelf);
	SetEntProp(MasterEntityIndex, Prop_Send, "m_usSolidFlags", 12); 
	WandProjectile_ApplyFunctionToEntity(MasterEntityIndex, NemalSlicerTouchOverall);
	
	//AngleFromSelf is the angle of where it should fire from towards to the target.

	//need atleast 2 joints.
	if(MaxJoints <= 2)
		MaxJoints = 2;

	//fatness Determines overall max size of it, length wise.
	float AddedOffsetEachLoop;
	float AddedOffsetEachLoopBack;

	float FatnessHalf = fatness / 2.0;

	//how much to add with each joint
	AddedOffsetEachLoop = fatness / float(MaxJoints);
	AddedOffsetEachLoopBack = FatnessHalf / float(MaxJoints);
	
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = -(FatnessHalf / 2.0); //Go backwards abit too
	tmp[1] = -(fatness / 2.0);	//start off half way to the other side
	tmp[1] += (AddedOffsetEachLoop / 2.0);
	tmp[2] = 0.0;
	VectorRotate(tmp, AngleFromSelf, actualBeamOffset);
	actualBeamOffset[2] = 0.0;
	vecSelf[0] += actualBeamOffset[0];
	vecSelf[1] += actualBeamOffset[1];
	vecSelf[2] += actualBeamOffset[2];
	float OverridePosOfSpawned[3];
	OverridePosOfSpawned = vecSelf;

	int PreviousProjectile;
	for(int RepeatJoint = 0; RepeatJoint < MaxJoints; RepeatJoint ++)
	{
		int SitatuionCalcDo = NemalSutationSliceHelp(RepeatJoint, MaxJoints -1);
		int projectile;
		if(RepeatJoint == 0 || (RepeatJoint + 1) == MaxJoints)
			projectile= Wand_Projectile_Spawn(iNpc, speed, 0.0, damage, -1, -1, Particle, AngleFromSelf,_,OverridePosOfSpawned);
		else
			projectile= Wand_Projectile_Spawn(iNpc, speed, 0.0, damage, -1, -1, "", AngleFromSelf,_,OverridePosOfSpawned);
			
		EntityBelongsToMasterIndex[projectile] = EntityMasterMainIndex;

		switch(SitatuionCalcDo)
		{
			case 3:
			{
				tmp[0] = 0.0;
			}
			case 2:
				tmp[0] = -AddedOffsetEachLoopBack; //start off half way to the other side
			case 1:
				tmp[0] = AddedOffsetEachLoopBack; //start off half way to the other side
		}
		tmp[1] = AddedOffsetEachLoop;
		tmp[2] = 0.0;
		VectorRotate(tmp, AngleFromSelf, actualBeamOffset);
		actualBeamOffset[2] = 0.0;
		OverridePosOfSpawned[0] += actualBeamOffset[0];
		OverridePosOfSpawned[1] += actualBeamOffset[1];
		OverridePosOfSpawned[2] += actualBeamOffset[2];
		int laser = projectile;
		float LaserFatnessCalc;
		float LaserFatnessCalcNext;
		float DefaultFatnessLaser = 20.0;
		float PercentageRepeatDo;
		{
			//Do calcs for inbetweeners
			switch(SitatuionCalcDo)
			{
				case 1, 2:
				{
					PercentageRepeatDo = float(RepeatJoint) / (MaxJoints);
					if(PercentageRepeatDo > 0.5)
					{
						PercentageRepeatDo = float(RepeatJoint - 1) / (MaxJoints);
						PercentageRepeatDo *= -1.0;
						PercentageRepeatDo += 1.0;
					}
					LaserFatnessCalc = PercentageRepeatDo * DefaultFatnessLaser;
				}
				case 3:
				{
					PercentageRepeatDo = 0.5;
					LaserFatnessCalc = PercentageRepeatDo * DefaultFatnessLaser;
				}
			}
			SitatuionCalcDo = NemalSutationSliceHelp((RepeatJoint), (MaxJoints -1));
			switch(SitatuionCalcDo)
			{
				case 1, 2:
				{
					PercentageRepeatDo = float(RepeatJoint + 1) / (MaxJoints);
					if(PercentageRepeatDo > 0.5)
					{
						PercentageRepeatDo = float(RepeatJoint) / (MaxJoints);
						PercentageRepeatDo *= -1.0;
						PercentageRepeatDo += 1.0;
					}
					LaserFatnessCalcNext = PercentageRepeatDo * DefaultFatnessLaser;
				}
				case 3:
				{
					PercentageRepeatDo = 0.5;
					LaserFatnessCalcNext = PercentageRepeatDo * DefaultFatnessLaser;
				}
			}
		}
		
		if(IsValidEntity(PreviousProjectile))
		{
			laser = ConnectWithBeam(projectile, PreviousProjectile, red, green, blue, LaserFatnessCalcNext, LaserFatnessCalc, 1.0);
		}
		DataPack pack = new DataPack();
		SetEntityMoveType(projectile, MOVETYPE_NOCLIP);
		PreviousProjectile = projectile;
		pack.WriteCell(EntIndexToEntRef(projectile));
		pack.WriteCell(EntIndexToEntRef(laser));
		RequestFrames(Mylnar_DeleteLaserAndParticle, 300, pack);
		//after 5 seconds, delete
		
		DataPack pack2;
		CreateDataTimer(0.1, Timer_NemalProjectileHitDetect, pack2, TIMER_REPEAT);
		pack2.WriteCell(EntIndexToEntRef(MasterEntityIndex));
		pack2.WriteCell(EntIndexToEntRef(laser));
		pack2.WriteCell(EntIndexToEntRef(projectile));
		pack2.WriteFloat(OverridePosOfSpawned[0]);
		pack2.WriteFloat(OverridePosOfSpawned[1]);
		pack2.WriteFloat(OverridePosOfSpawned[2]);
		pack2.WriteCell(EntityMasterMainIndex);
		pack2.WriteCell(GiveDebuff);
		
	}
}

public void NemalSlicerTouchOverall(int entity, int target)
{
	if(target == 0)
	{
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
	}
}
int NemalSutationSliceHelp(int CurrentJoint, int MaxJoints)
{
	if(CurrentJoint == (MaxJoints / 2))
	{
		return 3;
		//its the middle.
	}
	else if(CurrentJoint > MaxJoints / 2)
	{
		return 2;
		//Its the end side.
	}
	else
	{
		return 1;
		//Its the first side.
	}
}

bool DoDamageActiveHereNemal[MAXENTITIES];
public Action Timer_NemalProjectileHitDetect(Handle timer, DataPack pack)
{
	pack.Reset();
	int MasterProjEntity = EntRefToEntIndex(pack.ReadCell());
	int LaserEntity = EntRefToEntIndex(pack.ReadCell());
	int Projectile = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(MasterProjEntity))
	{
		if(IsValidEntity(LaserEntity))
			RemoveEntity(LaserEntity);

		if(IsValidEntity(Projectile))
			RemoveEntity(Projectile);
	}
	float OldPositionGet[3];
	OldPositionGet[0] = pack.ReadFloat();
	OldPositionGet[1] = pack.ReadFloat();
	OldPositionGet[2] = pack.ReadFloat();
	int EntityMasterMainIndex = pack.ReadCell();
	int GiveDebuff = pack.ReadCell();
	if(IsValidEntity(Projectile))
	{
		//Get new abs origin
		float NewPos[3]; 
		GetEntPropVector(Projectile, Prop_Data, "m_vecAbsOrigin", NewPos);
		float hullMin[3] = {-5.0,-5.0,-5.0};
		float hullMax[3] = {5.0,5.0,5.0};
		Zero(DoDamageActiveHereNemal);
		Handle trace = TR_TraceHullFilterEx(OldPositionGet, NewPos, hullMin, hullMax, 1073741824, BEAM_TraceUsers, Projectile);
		delete trace;
		pack.Position--;
		pack.Position--;
		pack.Position--;
		pack.Position--;
		pack.Position--;
		pack.WriteFloat(NewPos[0]);
		pack.WriteFloat(NewPos[1]);
		pack.WriteFloat(NewPos[2]);
		static float angles[3];
		GetEntPropVector(Projectile, Prop_Send, "m_angRotation", angles);
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		int OwnerEntity = EntRefToEntIndex(i_WandOwner[Projectile]);
		if(IsValidEntity(OwnerEntity))
		{
			for(int Loop = 0; Loop < MAXENTITIES; Loop ++)
			{
				if(DoDamageActiveHereNemal[Loop])
				{
					static float Entity_Position[3];
					WorldSpaceCenter(Loop, Entity_Position);
					float Dmg_Force[3]; CalculateDamageForce(vecForward, 10000.0, Dmg_Force);
					int pitch = GetRandomInt(125,135);
					EmitSoundToAll(NEMAL_AIRSLICE_HIT, Loop, SNDCHAN_AUTO, 75,_,0.8,pitch);
					Custom_Knockback(OwnerEntity, Loop, 450.0, true);
					if(Loop <= MaxClients)
					{
						SDKHooks_TakeDamage(Loop, OwnerEntity, OwnerEntity, f_WandDamage[Projectile], DMG_CLUB, -1, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
					}
					else
					{
						SDKHooks_TakeDamage(Loop, OwnerEntity, OwnerEntity, f_WandDamage[Projectile] * 0.5, DMG_CLUB, -1, Dmg_Force, Entity_Position);	// 2048 is DMG_NOGIB?
					}
					if(GiveDebuff)
						ApplyStatusEffect(OwnerEntity, Loop, "Teslar Shock", 5.0);
				}
			}
		}
		return Plugin_Continue;
	}
	CurrentSliceIndexAviable[EntityMasterMainIndex] = false;
	return Plugin_Stop; 
}

static bool BEAM_TraceUsers(int enemy, int contentsMask, int projectile)
{
	if (IsValidEntity(enemy))
	{
		int OwnerEntity = EntRefToEntIndex(i_WandOwner[projectile]);
		if(IsValidEnemy(enemy, OwnerEntity, true, false)) //Must detect camo.
		{
			int MasterIndex = EntityBelongsToMasterIndex[projectile];
			if(!TargetsHitNemal[MasterIndex][enemy])
			{
				DoDamageActiveHereNemal[enemy] = true;
				TargetsHitNemal[MasterIndex][enemy] = true;
			}
		}
	}
	return false;
}

bool NemalMarkAreas(Nemal npc)
{
	if(npc.m_flNemalPlaceAirMines)
	{
		if(npc.m_flNemalPlaceAirMines < GetGameTime(npc.index))
		{
			NemalPlaceAirMines(npc.index, 85.0 * RaidModeScaling, 1.5, 15.0, 70.0);
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flNemalPlaceAirMines = 0.0;	
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flDoingAnimation = 0.0;
			float pos_npc[3];
			float angles_useless[3];
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			npc.GetAttachment("effect_hand_r", pos_npc, angles_useless);
			npc.m_iWearable8 = ParticleEffectAt_Parent(pos_npc, "powerup_supernova_explode_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
			npc.PlayMineLayed();

			CreateTimer(0.25, Timer_RemoveEntity, EntIndexToEntRef(npc.m_iWearable8), TIMER_FLAG_NO_MAPCHANGE);
		}
		return true;
	}

	return false;
}


void NemalPlaceAirMines(int iNpc, float damage, float TimeUntillArm, float MaxDuration, float Size)
{
	//Find 10 random locations on a map, or 5, undecided.

	float pos_npc[3];
	WorldSpaceCenter(iNpc, pos_npc);
	
	//players only
	int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
	UnderTides npcGetInfo = view_as<UnderTides>(iNpc);
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), false, 1);
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			int LoopTarget = enemy_2[i];
			NemalPlaceAirMinesInternal(iNpc, damage, TimeUntillArm, MaxDuration, Size, LoopTarget, pos_npc);
		}
	}
	
	//npcs only, do less.
	int enemy_3[RAIDBOSS_GLOBAL_ATTACKLIMIT / 2];
	GetHighDefTargets(npcGetInfo, enemy_3, sizeof(enemy_3), true, 2);
	for(int i; i < sizeof(enemy_3); i++)
	{
		if(enemy_3[i])
		{
			int LoopTarget = enemy_3[i];
			NemalPlaceAirMinesInternal(iNpc, damage, TimeUntillArm, MaxDuration, Size, LoopTarget, pos_npc);
		}
	}
}

void NemalPlaceAirMinesInternal(int iNpc, float damage, float TimeUntillArm, float MaxDuration, float Size, int LoopTarget, float pos_npc[3])
{
	float LocationOfMine[3];
	
	float PosEnemy[3];
	Nemal npc = view_as<Nemal>(iNpc);
	if(b_ThisWasAnNpc[LoopTarget])
	{
		if(!Can_I_See_Enemy_Only(iNpc, LoopTarget))
		{
			return;
		}
	}

	WorldSpaceCenter(LoopTarget, PosEnemy);
	float flDistanceToTarget = GetVectorDistance(pos_npc, PosEnemy);
	float SpeedToPredict = flDistanceToTarget * 3.0;
	PredictSubjectPositionForProjectiles(npc, LoopTarget, SpeedToPredict, _,LocationOfMine);
	LocationOfMine[2] += 1.0;
	
	Handle ToGroundTrace = TR_TraceRayFilterEx(LocationOfMine, view_as<float>( { 90.0, 0.0, 0.0 } ), MASK_SOLID, RayType_Infinite, TraceRayHitWorldOnly, iNpc);
	TR_GetEndPosition(LocationOfMine, ToGroundTrace);
	delete ToGroundTrace;
	LocationOfMine[2] += 5.0;
	float SaveOldLoc[3];
	SaveOldLoc = LocationOfMine;

	DataPack pack2;
	CreateDataTimer(0.25, Timer_NemalMineLogic, pack2, TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(iNpc));
	pack2.WriteCell(0); //0 means EVIL
	pack2.WriteFloat(LocationOfMine[0]);
	pack2.WriteFloat(LocationOfMine[1]);
	pack2.WriteFloat(LocationOfMine[2]);
	pack2.WriteFloat(damage);
	pack2.WriteFloat(Size);
	pack2.WriteFloat(TimeUntillArm + GetGameTime());
	pack2.WriteFloat(MaxDuration + GetGameTime());

	
	flDistanceToTarget = GetVectorDistance(pos_npc, PosEnemy);
	SpeedToPredict = flDistanceToTarget * 1.0;
	PredictSubjectPositionForProjectiles(npc, LoopTarget, SpeedToPredict, _,LocationOfMine);
	LocationOfMine[2] += 1.0;
	
	ToGroundTrace = TR_TraceRayFilterEx(LocationOfMine, view_as<float>( { 90.0, 0.0, 0.0 } ), MASK_SOLID, RayType_Infinite, TraceRayHitWorldOnly, iNpc);
	TR_GetEndPosition(LocationOfMine, ToGroundTrace);
	delete ToGroundTrace;
	LocationOfMine[2] += 5.0;
	flDistanceToTarget = GetVectorDistance(SaveOldLoc, LocationOfMine, true);
	//the mines are too close together, dont spawn friendly.
	if(flDistanceToTarget < (50.0 * 50.0))
		return;
	
	DataPack pack3;
	CreateDataTimer(0.25, Timer_NemalMineLogic, pack3, TIMER_REPEAT);
	pack3.WriteCell(EntIndexToEntRef(iNpc));
	pack3.WriteCell(1); //1 means GOOD.
	pack3.WriteFloat(LocationOfMine[0]);
	pack3.WriteFloat(LocationOfMine[1]);
	pack3.WriteFloat(LocationOfMine[2]);
	pack3.WriteFloat(damage);
	pack3.WriteFloat(Size);
	pack3.WriteFloat(TimeUntillArm + GetGameTime());
	pack3.WriteFloat((MaxDuration * 2.5) + GetGameTime());
}
bool DetonateCurrentMine;
public Action Timer_NemalMineLogic(Handle timer, DataPack pack)
{
	pack.Reset();
	int MasterNpc = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(MasterNpc))
		return Plugin_Stop; 
	bool Friendly = view_as<bool>(pack.ReadCell());
	//the master npc isnt existant anymore, delete all mines instantly.
		
	float MinePositionGet[3];
	MinePositionGet[0] = pack.ReadFloat();
	MinePositionGet[1] = pack.ReadFloat();
	MinePositionGet[2] = pack.ReadFloat();
	float Damage_Do = pack.ReadFloat();
	float Size = pack.ReadFloat();
	float TimeUntillArm = pack.ReadFloat();
	if(TimeUntillArm > GetGameTime())
	{
		if(Friendly)
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 125, 50, 200, 1, 0.3, 2.0, 2.0, 2);
		else
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 50, 50, 200, 1, 0.3, 2.0, 2.0, 2);
		//Do not do damage calculations yet.
		return Plugin_Continue; 
	}
	DetonateCurrentMine = false;
	
	if(Friendly)
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 100, 255, 100, 200, 1, 0.3, 5.0, 8.0, 2);
	else
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 100, 100, 200, 1, 0.3, 5.0, 8.0, 2);
		
	if(Friendly)
		Explode_Logic_Custom(0.0, 0, MasterNpc, -1, MinePositionGet, Size, 1.0, _, true, 20,_,_,_,NemalMineExploderFriendly);
	else
		Explode_Logic_Custom(Damage_Do, 0, MasterNpc, -1, MinePositionGet, Size, 1.0, _, true, 20,_,_,_,NemalMineExploder);

	if(DetonateCurrentMine)
	{
		if(Friendly)
		{
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 100, 200, 100, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 100, 200, 100, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 100, 200, 100, 200, 1, 0.5, 12.0, 10.0, 2);
		}
		else
		{
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 100, 100, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 200, 100, 100, 200, 1, 0.5, 12.0, 10.0, 2);
			spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 200, 100, 100, 200, 1, 0.5, 12.0, 10.0, 2);
		}
		//It hit something, boom.
		EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", 0, _, 80, _, 0.85,_,_,MinePositionGet);
		return Plugin_Stop; 
	}
	float MaxDuration = pack.ReadFloat();
	if(MaxDuration < GetGameTime())
	{
		//Time is up, mine will dissapear.
		return Plugin_Stop; 
	}


	return Plugin_Continue; 
}

float NemalMineExploderFriendly(int entity, int victim, float damage, int weapon)
{
	//Knock target up
	if(victim <= MaxClients)
	{
		NemalAntiLaserDo[victim] = GetGameTime() + 4.0;
		DetonateCurrentMine = true;
		float vDirection[3];
		vDirection[2] += 1000.0;
		float newVel[3];
		f_ImmuneToFalldamage[victim] = GetGameTime() + 5.0;
				
		newVel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
		newVel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
		newVel[2] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[2]");
						
		for (int i = 0; i < 3; i++)
		{
			vDirection[i] += newVel[i];
		}
		vDirection[2] = 1000.0;
		
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vDirection);
		NPCStats_RemoveAllDebuffs(victim, 0.0);
		//Cure off debuffs, oops forgot.
	}
	
	return damage;
}


float NemalMineExploder(int entity, int victim, float damage, int weapon)
{
	DetonateCurrentMine = true;
	//Knock target up
	if(NpcStats_IberiaIsEnemyMarked(victim))
	{
		damage *= 2.5;
	}
	if(b_ThisWasAnNpc[victim])
		PluginBot_Jump(victim, {0.0,0.0,1000.0});
	else
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,1000.0});

	ApplyStatusEffect(entity, victim, "Marked", 20.0);
	
	//if it was a barracks units, half damage
	if(victim > MaxClients)
	{
		return- (damage * 0.5);
	}
	return damage;
}



void Nemal_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iMaxHealth");
			
		maxhealth = RoundToNearest(float(maxhealth) * 0.63);

		int spawn_index;
		switch(i_RaidGrantExtra[entity])
		{
			case 2:
			{
				spawn_index = NPC_CreateByName("npc_raid_silvester", -1, pos, ang, GetTeam(entity), "wave_30");
			}
			case 3:
			{
				spawn_index = NPC_CreateByName("npc_raid_silvester", -1, pos, ang, GetTeam(entity), "wave_45");
			}
			case 4:
			{
				spawn_index = NPC_CreateByName("npc_raid_silvester", -1, pos, ang, GetTeam(entity), "wave_60");
			}
			case 5:
			{
				spawn_index = NPC_CreateByName("npc_raid_silvester", -1, pos, ang, GetTeam(entity), "final_item");
			}
		}
		if(spawn_index > MaxClients)
		{
			CClotBody npc1 = view_as<CClotBody>(entity);
			npc1.m_iTargetAlly = spawn_index;
			CClotBody npc2 = view_as<CClotBody>(spawn_index);
			npc2.m_iTargetAlly = entity;
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			fl_Extra_Damage[spawn_index] = fl_Extra_Damage[entity];
			fl_Extra_Speed[spawn_index] = fl_Extra_Speed[entity];
			fl_Extra_Damage[spawn_index] *= 1.1;
			//10% dmg buff
		}
	}
}


