#pragma semicolon 1
#pragma newdecls required


#define Silvester_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define Silvester_LASER_THICKNESS 25





static bool b_SilvLine[MAXENTITIES];
static bool b_SilvesterAttackSame[MAXENTITIES];

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
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


static bool b_RageAnimated[MAXENTITIES];

void Silvester_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Silvester");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_raid_silvester");
	strcopy(data.Icon, sizeof(data.Icon), "silvester_raid");
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
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Silvester(vecPos, vecAng, team, data);
}

methodmap Silvester < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_SilvesterRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property int m_iSilvesterComboAttack
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property float m_flSilvesterSlicerCD
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property float m_flSilvesterSlicerHappening
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}

	property float m_flInTeleportLogic
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float f_SilvesterMeleeSliceHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float f_SilvesterMeleeSliceHappeningCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flSilvesterTransformRegardless
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flChangeTargetsSilvester
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property float m_flSilvesterAirbornAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}

	property float m_flSetTargetFromWalkTarget
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flSilvesterHudCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flSilvesterChangeTargets
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flSilvesterDelayStart
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flSilvesterDontTarget
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
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
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
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME);
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	
	
	public Silvester(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Silvester npc = view_as<Silvester>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		

		npc.m_bisWalking = true;
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		npc.m_iSilvesterComboAttack = 0;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		npc.m_flInTeleportLogic = 0.0;
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		b_SilvLine[npc.index] = false;
		npc.m_flSpeed = 320.0;
		npc.i_GunMode = 0;
		npc.m_flSilvesterSlicerCD = GetGameTime() + 6.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		BlockLoseSay = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		npc.m_flSilvesterDelayStart = GetGameTime() + 2.0;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.AddActivityViaSequence("taunt_time_out_therapy_outro");
		npc.SetCycle(0.5);
		npc.SetPlaybackRate(0.45);	
		npc.m_flSilvesterChangeTargets = 0.0;
		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;
		npc.m_flSilvesterTransformRegardless = GetGameTime() + 40.0;
		b_SilvesterAttackSame[npc.index] = false;
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		
		b_angered_twice[npc.index] = false;
		
		if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{gold}Silvester{default}: Sorry that im late!");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester{default}: Had to do some errands with {blue}Sensal{default}.");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Silvester{default}: Here i am!");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester{default}: Starting easy? Got it!");
				}
			}
		}
		if(StrContains(data, "wave_45") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{gold}Silvester{default}: Just like old times, eh Mercs?");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester{default}: Its good to practice, i shouldnt slack off.");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Silvester{default}: Sorry {lightblue}Nemal{default} I should take this more seriously.");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester{default}: Wish {darkblue}Waldch{default} would come with train with us, but ever since the {crimson}hitman{default} is gone, he can finally do work.");
				}
			}
		}
		if(StrContains(data, "wave_60") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{gold}Silvester{default}: Here it is.");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester{default}: Final Challange.");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Silvester{default}: No more holding back.");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester{default}: Im giving it my all.");
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
					CPrintToChatAll("{gold}Silvester{default}: Here it is.");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester{default}: Final Challange.");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Silvester{default}: No more holding back.");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Silvester{default}: Im giving it my all.");
				}
			}
		}



		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Silvester_Win);

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;
		/*
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		*/
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable7 = npc.EquipItem("head","models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);

		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});

		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable3, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable4, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		Nemal_SilvesterApplyEffects(npc.index, false);
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Silvester npc = view_as<Silvester>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	

	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	bool NemalAssistance = false;
	if(IsValidEntity(npc.m_iTargetAlly) && !IsPartnerGivingUpNemalSilv(npc.index))
		NemalAssistance = true; //they are alive and helping.


	if(npc.m_flSilvesterHudCD < GetGameTime())
	{
		npc.m_flSilvesterHudCD = GetGameTime() + 0.2;
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
		else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
		{	
			RaidBossActive = EntIndexToEntRef(npc.index);
		}
	}

	if(b_angered_twice[npc.index])
	{
		if(npc.m_iChanged_WalkCycle != 15)
		{
			npc.m_bisWalking = false;
			npc.StopPathing();
			npc.m_iChanged_WalkCycle = 15;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("selectionMenu_Idle");
			npc.SetCycle(0.01);
		}
		return;
	}
	if(npc.m_flSilvesterDelayStart)
	{
		if(npc.m_bisWalking)
		{
			npc.AddActivityViaSequence("taunt_time_out_therapy_outro");
			npc.SetCycle(0.5);
			npc.SetPlaybackRate(0.45);	
			npc.m_bisWalking = false;
		}
		if(npc.m_flSilvesterDelayStart < GetGameTime())
		{
			b_NpcIsInvulnerable[npc.index] = false;
			npc.m_flSilvesterDelayStart = 0.0;
			npc.m_bisWalking = true;
		}
		return;
	}
	if(npc.m_flInTeleportLogic)
	{
		if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		{
			return;
		}

		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
		if(npc.m_flSilvesterSlicerHappening)
		{
			npc.m_flInTeleportLogic = 0.0;
			RemoveSpecificBuff(npc.index, "Very Defensive Backup");
			return;
		}
		if(b_NpcIsInvulnerable[npc.index])
		{
			RemoveSpecificBuff(npc.index, "Very Defensive Backup");
			npc.m_flInTeleportLogic = 0.0;
			return;
		}
		
		CClotBody allynpc = view_as<CClotBody>(npc.m_iTargetAlly);
		if(!IsValidEntity(allynpc.index)) //DEAD!!
		{
			npc.m_flInTeleportLogic = 0.0;
			npc.m_flChangeTargetsSilvester -= 3.0;
			CPrintToChatAll("{gold}Silvester{default}: Oh damn She is already gone...");
			RemoveSpecificBuff(npc.index, "Very Defensive Backup");
			return;
		}
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		float WorldSpaceVec2[3]; WorldSpaceCenter(allynpc.index, WorldSpaceVec2);
		float flDistanceToTarget = GetVectorDistance(WorldSpaceVec, WorldSpaceVec2, true);
		if(flDistanceToTarget < (400.0 * 400.0))
		{
			npc.m_flInTeleportLogic = 0.0;
			npc.m_flChangeTargetsSilvester -= 3.0;
			RemoveSpecificBuff(npc.index, "Very Defensive Backup");
			return;
			//too close, cancel.
		}
		int r = 150;
		int g = 150;
		int b = 0;
		int a = 200;
		
		spawnRing(npc.index, 75.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);
		spawnRing(npc.index, 75.0 * 2.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);
		spawnRing(npc.index, 75.0 * 2.0, 0.0, 0.0, 70.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);

		spawnRing(allynpc.index, 75.0 * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);
		spawnRing(allynpc.index, 75.0 * 2.0, 0.0, 0.0, 40.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);
		spawnRing(allynpc.index, 75.0 * 2.0, 0.0, 0.0, 70.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 3.0, 3.1, 1);

		//Teleport to nemal with animation
		if(npc.m_flInTeleportLogic < (GetGameTime(npc.index))) //teleport and stuff
		{
			npc.m_flInTeleportLogic = 0.0;
			
			ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			ParticleEffectAt(WorldSpaceVec2, "teleported_blue", 0.5);
			npc.PlayDeathSound();	
			TeleportEntity(npc.index, WorldSpaceVec2);
			RemoveSpecificBuff(npc.index, "Very Defensive Backup");
			//go to sister!
		}
		else if(npc.m_flInTeleportLogic < (GetGameTime(npc.index) + 1.3)) //last second
		{
			if(npc.m_iChanged_WalkCycle != 21)
			{
				npc.m_bisWalking = false;
				npc.StopPathing();
				npc.m_iChanged_WalkCycle = 21;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_peace_medic");
				npc.SetCycle(0.02);
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 20)
			{
				npc.m_bisWalking = false;
				npc.StopPathing();
				npc.m_iChanged_WalkCycle = 20;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_borrowed_bones");
				npc.SetCycle(0.03);
				switch(GetRandomInt(0,4 * 2)) //have half the chance to say nothing
				{
					case 0:
					{
						CPrintToChatAll("{gold}Silvester{default}: Hold on {lightblue}Nemal{default} i'm coming!");
					}
					case 1:
					{
						CPrintToChatAll("{gold}Silvester{default}: Thinking of taking {lightblue}Nemal{default} out first?");
					}
					case 2:
					{
						CPrintToChatAll("{gold}Silvester{default}: {lightblue}Nemal{default}... {darkblue}Waldch{default}... you both are the same i swear!");
					}
					case 3:
					{
						CPrintToChatAll("{gold}Silvester{default}: Rahhh, ill teleport to you wait.");
					}
					case 4:
					{
						CPrintToChatAll("{gold}Silvester{default}: Here i go !");
					}
				}
			}
		}
		return;
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
					CPrintToChatAll("{gold}Silvester{default}: You dont beat me, then youll never be able to face the full force of the {purple}void{default}.");
				}
				case 1:
				{
					CPrintToChatAll("{gold}Silvester{default}: Not beating me means no beating the {purple}void{default}.");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Silvester{default}: Use that adrenaline against me, come on!");
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
				CPrintToChatAll("{gold}Silvester{default}: Gotta go, youll win next time.");
			}
			case 1:
			{
				CPrintToChatAll("{gold}Silvester{default}: Atleast you fought, and didnt run!");
			}
			case 2:
			{
				CPrintToChatAll("{gold}Silvester{default}: I can try to go easier next time, but that wont help with training.");
			}
		}
		return;
	}
	if(npc.m_flSilvesterTransformRegardless < GetGameTime(npc.index))
	{
		if(i_RaidGrantExtra[npc.index] >= 3 && !npc.Anger)
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 3.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 30.0;
			npc.m_bisWalking = false;
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			CPrintToChatAll("{gold}Silvester{default}: Youre taking to long to hurt me, ill try harder myself then.");
			npc.m_flSilvesterTransformRegardless = FAR_FUTURE;
			npc.i_GunMode = 0;
		}
	}
	float TotalArmor = 1.0;

	if(npc.Anger)
		TotalArmor *= 0.85;

	fl_TotalArmor[iNPC] = TotalArmor;
	if(RaidModeTime < GetGameTime())
	{
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
				CPrintToChatAll("{gold}Silvester{default}: Sorry, too slow.");
			}
			case 1:
			{
				CPrintToChatAll("{gold}Silvester{default}: Well thats a boring end.");
			}
			case 2:
			{
				CPrintToChatAll("{gold}Silvester{default}: If you would stop running, this wouldnt happen.");
			}
		}
		BlockLoseSay = true;
	}
	if(SilvesterTransformation(npc, NemalAssistance))
		return;

	if(npc.Anger)
	{
		if(SilvesterSwordSlicer(npc, NemalAssistance))
			return;
	}
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

	bool ForceRedo = false;
	if(NemalAssistance)
	{
		//Nemal is alive and didnt give up! Try to target someone near her....
		CClotBody allynpc = view_as<CClotBody>(npc.m_iTargetAlly);
		if(allynpc.m_iTarget == npc.m_iTargetWalkTo)
		{
			ForceRedo = true;
		}
		if((!b_SilvesterAttackSame[npc.index] && ForceRedo) || npc.m_flChangeTargetsSilvester < GetGameTime(npc.index))
		{
			if(b_SilvesterAttackSame[npc.index])
			{
				//We targeted someone before that was within nemals range...
				//try again!
				npc.m_flSilvesterChangeTargets = 5.0;
			}
			b_SilvesterAttackSame[npc.index] = false;
			//Get the next closest target!
			static float flPos[3]; 
			if(npc.m_flSilvesterChangeTargets >= 4.0)
			{
				GetEntPropVector(allynpc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				//only get nemals target every so often.
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,700.0,_,_,allynpc.m_iTarget, flPos);
				npc.m_flSilvesterChangeTargets += 1.0;
				if(!ForceRedo)
				{
					npc.m_flInTeleportLogic = GetGameTime(npc.index) + 3.0;
					ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 3.0);
				}
				npc.m_flChangeTargetsSilvester += 3.0;
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				npc.m_flSilvesterChangeTargets += 1.0;
				//Gets a target near himself
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,_,_,_,allynpc.m_iTarget, flPos);
			}
			bool WasForcingSameTarget = false;
			if(!IsValidEntity(npc.m_iTargetWalkTo))
			{
				//looks like silvester found no target...
				//Did we try to get a target near nemal?
				//if we did. then force targetting a closet eneemy from nemal anyways.
				if(npc.m_flSilvesterChangeTargets >= 5.0)
				{
					if(!ForceRedo)
					{
						npc.m_flInTeleportLogic = GetGameTime(npc.index) + 3.0;
						ApplyStatusEffect(npc.index, npc.index, "Very Defensive Backup", 3.0);
					}
					npc.m_flChangeTargetsSilvester += 3.0;
					npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,_,_,_,_/*allynpc.m_iTarget*/, flPos);
					npc.m_flSilvesterChangeTargets = 5.0;
					WasForcingSameTarget = true;
					b_SilvesterAttackSame[npc.index] = true;
				}
			}
			//We didnt force to target the same guy as nemal, we allow normal attacking.
			if(!WasForcingSameTarget && npc.m_flSilvesterChangeTargets >= 5.0)
			{
				npc.m_flSilvesterChangeTargets = 0.0;
			}
			npc.m_flChangeTargetsSilvester = GetGameTime(npc.index) + (GetRandomRetargetTime());
		}
	//cant have this here, issue being that he'll just target the wrong person.
	//	npc.m_iTarget = npc.m_iTargetWalkTo;
		//we STILL didnt find any target somehow, just stand still.
		//We also stand still if the last target is not downed, and we just patiently wait.
		int ForceStandStill = CountPlayersOnRed(2);
		if(ForceStandStill <= 1 || !IsValidEntity(npc.m_iTargetWalkTo))
		{
			if(npc.Anger)
			{
				if(npc.m_iChanged_WalkCycle != 99)
				{
					npc.m_bisWalking = false;
					npc.StopPathing();
					npc.m_iChanged_WalkCycle = 99;
					npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					CPrintToChatAll("{gold}Silvester{default}: Oh you seem to be alone, i'll wait.");
					b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 88)
				{
					npc.m_bisWalking = false;
					npc.StopPathing();
					npc.m_iChanged_WalkCycle = 88;
					npc.SetActivity("ACT_MP_STAND_MELEE");
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					CPrintToChatAll("{gold}Silvester{default}: Oh you seem to be alone, i'll wait.");
					b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
				}				
			}
			return;
		}
		else
		{
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
		}
	}
	else
	{
		if(!b_SilvLine[npc.index])
		{
			CPrintToChatAll("{gold}Silvester{default}: Fighting me alone now? Guess ill give it extra.");
			b_SilvLine[npc.index] = true;
			RaidModeScaling *= 1.15;
		}
		if(b_NpcIsInvulnerable[npc.index])
		{
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
			npc.m_flGetClosestTargetTime = 0.0;
		}
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}
	if(npc.m_flSetTargetFromWalkTarget < GetGameTime(npc.index))
	{
		//Set attack target
		npc.m_flSetTargetFromWalkTarget = GetGameTime(npc.index) + 1.0;
		npc.m_iTarget = npc.m_iTargetWalkTo;
	}
	int SetGoalVectorIndex;
	//What to do towards the enemy we want to attack	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		SetGoalVectorIndex = SilvesterSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget, NemalAssistance); 

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		

		//Body pitch
		float v[3], ang[3];
		float SelfVec[3]; WorldSpaceCenter(npc.index, SelfVec);
		float vecTargetex[3];
		vecTargetex = vecTarget;
		vecTargetex[2] -= 20.0;
		SubtractVectors(SelfVec, vecTargetex, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
	else
	{
		//instantly set target!
		npc.m_flSetTargetFromWalkTarget = 0.0;
	}
	//What to do towrads the enemy we want to walk to
	if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTargetWalkTo);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		//theres no valid enemy somehow somewhy to walk to, reset.
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flChangeTargetsSilvester = 0.0;
	}

	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		SilvesterAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Silvester npc = view_as<Silvester>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		
	if(i_RaidGrantExtra[npc.index] >= 3)
	{
		if((ReturnEntityMaxHealth(npc.index)/2) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth") - damage) && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 3.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 30.0;
			npc.m_bisWalking = false;
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index)/2);
			CPrintToChatAll("{gold}Silvester{default}: Well, looks like i gotta take off the training wheels.");
			npc.m_flSilvesterTransformRegardless = FAR_FUTURE;
			npc.i_GunMode = 0;
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	if(i_RaidGrantExtra[npc.index] == 5)
	{
		if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			b_angered_twice[npc.index] = true; 
			i_SaidLineAlready[npc.index] = 0; 
			RaidModeTime += 25.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);
			MakeObjectIntangeable(npc.index);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			
			CPrintToChatAll("{gold}Silvester{default}: Not in the face! ah... fine.");

			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	Silvester_Weapon_Lines(npc, attacker);

	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_Silvester_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}

static void Internal_NPCDeath(int entity)
{
	Silvester npc = view_as<Silvester>(entity);
	/*
		Explode on death code here please
	*/
	ExpidonsaRemoveEffects(npc.index);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	
	RaidModeTime += 20.0;

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

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{gold}Silvester{default}: Welp i gotta help {blue}Sensal{default} again, cya!");
		}
		case 1:
		{
			CPrintToChatAll("{gold}Silvester{default}: I have some stuff to do, exhausted anyways currently, till later.");
		}
		case 2:
		{
			CPrintToChatAll("{gold}Silvester{default}: You guys pack a punch!");
		}
		case 3:
		{
			CPrintToChatAll("{gold}Silvester{default}: Remember when i was infected? I still thank you for helping me!");
		}
	}

}
/*


*/
void SilvesterAnimationChange(Silvester npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	switch(npc.Anger)
	{
		case true: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 5)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 5;
					npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					npc.AddGesture("ACT_MP_JUMP_LAND_ALLCLASS");
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 6)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 6;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
				}	
			}
		}
		case false: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
					npc.AddGesture("ACT_MP_JUMP_LAND_MELEE");
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bAllowBackWalking = false;
				}	
			}
		}
	}
}
int SilvesterSelfDefense(Silvester npc, float gameTime, int target, float distance, bool NemalAssistance)
{
	if(npc.Anger)
	{
		if(npc.m_flSilvesterSlicerCD < GetGameTime(npc.index))
		{	
			int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
			if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
			{
				//steal alaxios jump :D
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				npc.PlayPullSound();
				flPos[2] += 500.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 3.25);	
				npc.m_flSilvesterSlicerHappening = GetGameTime(npc.index) + 1.0;
				float cooldownDo  = 30.0;
				if(!NemalAssistance)
					cooldownDo *= 0.5;

				if(i_RaidGrantExtra[npc.index] >= 4)
					cooldownDo *= 0.75;

				npc.m_flSilvesterSlicerCD = GetGameTime(npc.index) + cooldownDo;

				npc.m_flAttackHappens = GetGameTime(npc.index) + 3.25;
				npc.m_iChanged_WalkCycle = 0;
			}
		}
	}
	if(npc.m_flSilvesterAirbornAttack < GetGameTime(npc.index))
	{
		if(IsValidEnemy(npc.index, target))
		{
			npc.AddGesture("ACT_MP_THROW");
			npc.PlayRangedSound();
			float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
			int MaxCount = RoundToNearest(2.0 * RaidModeScaling);
			npc.FaceTowards(VecEnemy, 99999.9);
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			float ang_Look[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang_Look);
			if(MaxCount < 1)
			{
				MaxCount = 1;
			}
			if(MaxCount > 15)
				MaxCount = 15;

			float DelaybewteenPillars = 0.1;
			float DelayPillars = 0.7;

			if(i_RaidGrantExtra[npc.index] >= 4)
				DelayPillars = 0.55;

			ResetTEStatusSilvester();
			SetSilvesterPillarColour({212, 150, 0, 200});
			Silvester_Damaging_Pillars_Ability(npc.index,
			25.0 * RaidModeScaling,				 	//damage
			MaxCount, 	//how many
			DelayPillars,									//Delay untill hit
			DelaybewteenPillars,									//Extra delay between each
			ang_Look 								/*2 dimensional plane*/,
			pos,
			0.7,
			0.75);	
			
			float cooldownDo  = 7.0;
			if(!NemalAssistance)
				cooldownDo *= 0.5;

			if(NpcStats_IberiaIsEnemyMarked(target))
				cooldownDo *= 0.5;

			npc.m_flSilvesterAirbornAttack = GetGameTime(npc.index) + cooldownDo;
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			if(IsValidEnemy(npc.index, target))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, target,_,_,_,1,_,HowManyEnemeisAoeMelee);
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

							float damage = 26.0;

							if(npc.Anger)
							{
								damage *= 0.75;
							}
							
							if(!NemalAssistance)
								damage *= 1.35;

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
									if(!npc.Anger)
									{
										if(!NpcStats_IsEnemySilenced(npc.index))
										{
											TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
											TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
										}
									}
								}
							}
										
							if(!Knocked)
							{
								if(npc.Anger)
									Custom_Knockback(npc.index, targetTrace, 350.0, true); 
								else
									Custom_Knockback(npc.index, targetTrace, 450.0, true); 
							}
						} 
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					if(npc.Anger)
					{
						switch(GetRandomInt(0,1))
						{
							case 0:
								npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE",_,_,_, 1.25);
							case 1:
								npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						}
					}
					else
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					if(npc.Anger)
					{
						npc.m_flNextMeleeAttack = gameTime + 0.45;
					}
					else
					{
						npc.m_flNextMeleeAttack = gameTime + 0.75;
					}
					npc.m_flDoingAnimation = gameTime + 0.25;
				}
			}
		}
	}
	if(npc.Anger)
	{
		if(npc.f_SilvesterMeleeSliceHappening)
		{
			if(npc.f_SilvesterMeleeSliceHappening < GetGameTime(npc.index))
			{
				npc.f_SilvesterMeleeSliceHappening = 0.0;
				if(IsValidEnemy(npc.index, target))
				{
					float VecEnemy[3]; WorldSpaceCenter(target, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					float DamageCalc = 35.0 * RaidModeScaling;
					npc.PlayRangedSound();
					NemalAirSlice(npc.index, target, DamageCalc, 215, 150, 0, 200.0, 6, 1000.0, "rockettrail_fire", false);
				}
			}
		}
		else if(GetGameTime(npc.index) > npc.f_SilvesterMeleeSliceHappeningCD)
		{				
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				return 1;
			}
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
							
					npc.f_SilvesterMeleeSliceHappening = gameTime + 0.25;
					
					float cooldownDo = 4.5;
					if(!NemalAssistance)
						cooldownDo *= 0.5;

					if(i_RaidGrantExtra[npc.index] >= 4)
						cooldownDo *= 0.75;

					if(NpcStats_IberiaIsEnemyMarked(Enemy_I_See))
						cooldownDo *= 0.35;

					npc.f_SilvesterMeleeSliceHappeningCD = gameTime + cooldownDo;
					npc.m_flDoingAnimation = gameTime + 0.25;
				}
			}
		}
		
	}
	return 0;
}

bool SilvesterTransformation(Silvester npc, bool NemalAssistance)
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
			npc.m_flSilvesterSlicerHappening = 0.0;	
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_electricity_cloud1_WY", 3.0);
			npc.m_flSpeed = 0.0;
			npc.m_iChanged_WalkCycle = 0;
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
			RaidModeScaling *= 1.10;
			ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 5.0);
			npc.m_flDoingAnimation = 0.0;

			CPrintToChatAll("{gold}Silvester{default}: Here's my scythe!");
			if(NemalAssistance)
			{
				CPrintToChatAll("{lightblue}Nemal{default}: Guess ill try harder aswell, or try to.");
			}
			Nemal_SilvesterApplyEffects(npc.index, false);

			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			npc.m_iWearable8 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("1.35");
			AcceptEntityInput(npc.m_iWearable8, "SetModelScale");	
			SetVariantInt(512);
			AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");
			SetEntityRenderColor(npc.m_iWearable8, 255, 255, 255, 3);
				
			SetVariantColor(view_as<int>({255, 255, 255, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			npc.PlayAngerSoundPassed();


			npc.m_flNextRangedSpecialAttack = 0.0;			
			npc.m_flNextRangedAttack = 0.0;		
			npc.m_flSilvesterSlicerCD = 0.0;	
			//Reset all cooldowns.
		}
		return true;
	}
	return false;
}

static void Silvester_Weapon_Lines(Silvester npc, int client)
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
		 switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "You have his weapon yet none of his strength.");
		  							case 1: Format(Text_Lines, sizeof(Text_Lines), "{blue}Sensal{default} gave you this {gold}%N{default}? cant be.", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2, WEAPON_NEARL: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "You little stealers arent you?");
		 							case 1: Format(Text_Lines, sizeof(Text_Lines), "Hey thats my weapon!");}
		case WEAPON_KIT_BLITZKRIEG_CORE:  Format(Text_Lines, sizeof(Text_Lines), "Oh you beat him up? Thats good.");
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "that gun aint got ANYTHING ON ME!!!");
		case WEAPON_ANGELIC_SHOTGUN:  Format(Text_Lines, sizeof(Text_Lines), "{lightblue}Her{default} gun...? uh...");

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{gold}Silvester{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}


void Nemal_SilvesterApplyEffects(int entity, bool withoutweapon = false)
{
	Silvester npc = view_as<Silvester>(entity);	
	if(npc.Anger)
	{
		if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);
		ExpidonsaRemoveEffects(entity);
		SilvesterEarsApply(npc.index);
		if(withoutweapon)
			Nemal_SilvesterApplyEffectsForm2(entity, 0);	
		else	
			Nemal_SilvesterApplyEffectsForm2(entity, 2);	
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);
		ExpidonsaRemoveEffects(entity);
		SilvesterEarsApply(npc.index);
		if(withoutweapon)
			Nemal_SilvesterApplyEffectsForm2(entity, 0);	
		else	
			Nemal_SilvesterApplyEffectsForm2(entity, 1);		
	}
}
void SilvesterEarsApply(int iNpc, char[] attachment = "head")
{
	
	int red = 255;
	int green = 215;
	int blue = 0;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	int particle_ears2 = InfoTargetParentAt({0.0,-2.5,0.0}, "", 0.0); //First offset we go by
	int particle_ears3 = InfoTargetParentAt({0.0,-6.0,-5.0}, "", 0.0); //First offset we go by
	int particle_ears4 = InfoTargetParentAt({0.0,-8.0,3.0}, "", 0.0); //First offset we go by
	
	//fist ear
	int particle_ears2_r = InfoTargetParentAt({0.0,2.5,0.0}, "", 0.0); //First offset we go by
	int particle_ears3_r = InfoTargetParentAt({0.0,6.0,-5.0}, "", 0.0); //First offset we go by
	int particle_ears4_r = InfoTargetParentAt({0.0,8.0,3.0}, "", 0.0); //First offset we go by

	SetParent(particle_ears1, particle_ears2, "",_, true);
	SetParent(particle_ears1, particle_ears3, "",_, true);
	SetParent(particle_ears1, particle_ears4, "",_, true);
	SetParent(particle_ears1, particle_ears2_r, "",_, true);
	SetParent(particle_ears1, particle_ears3_r, "",_, true);
	SetParent(particle_ears1, particle_ears4_r, "",_, true);
	Custom_SDKCall_SetLocalOrigin(particle_ears1, flPos);
	SetEntPropVector(particle_ears1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_ears1, attachment,_);


	int Laser_ears_1 = ConnectWithBeamClient(particle_ears4, particle_ears2, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_ears_2 = ConnectWithBeamClient(particle_ears4, particle_ears3, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);

	int Laser_ears_1_r = ConnectWithBeamClient(particle_ears4_r, particle_ears2_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	int Laser_ears_2_r = ConnectWithBeamClient(particle_ears4_r, particle_ears3_r, red, green, blue, 1.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][15] = EntIndexToEntRef(particle_ears1);
	i_ExpidonsaEnergyEffect[iNpc][16] = EntIndexToEntRef(particle_ears2);
	i_ExpidonsaEnergyEffect[iNpc][17] = EntIndexToEntRef(particle_ears3);
	i_ExpidonsaEnergyEffect[iNpc][18] = EntIndexToEntRef(particle_ears4);
	i_ExpidonsaEnergyEffect[iNpc][19] = EntIndexToEntRef(Laser_ears_1);
	i_ExpidonsaEnergyEffect[iNpc][20] = EntIndexToEntRef(Laser_ears_2);
	i_ExpidonsaEnergyEffect[iNpc][21] = EntIndexToEntRef(particle_ears2_r);
	i_ExpidonsaEnergyEffect[iNpc][22] = EntIndexToEntRef(particle_ears3_r);
	i_ExpidonsaEnergyEffect[iNpc][23] = EntIndexToEntRef(particle_ears4_r);
	i_ExpidonsaEnergyEffect[iNpc][24] = EntIndexToEntRef(Laser_ears_1_r);
	i_ExpidonsaEnergyEffect[iNpc][25] = EntIndexToEntRef(Laser_ears_2_r);
}
void Nemal_SilvesterApplyEffectsForm2(int entity, int WeaponSettingDo = 0)
{
	if(AtEdictLimit(EDICT_RAID))
		return;
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	
	int red = 255;
	int green = 255;
	int blue = 0;
	float flPos[3];
	float flAng[3];
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);

	npc.m_iWearable9 = npc.EquipItem("head", WINGS_MODELS_1);
	SetVariantInt(1);
	AcceptEntityInput(npc.m_iWearable9, "SetBodyGroup");	
	SetVariantString("1.35");
	AcceptEntityInput(npc.m_iWearable9, "SetModelScale");
	SetEntityRenderColor(npc.m_iWearable9, 255, 255, 255, 3);
	
	if(WeaponSettingDo == 1 || WeaponSettingDo == 2)
	{
		if(WeaponSettingDo == 1)
		{
			npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 3);
			SetVariantInt(2048);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");	
			return;
		}
		int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
		
		int particle_2 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
		int particle_3 = InfoTargetParentAt({-20.5,0.0,0.0}, "", 0.0); //First offset we go by
		int particle_4 = InfoTargetParentAt({-6.75,13.5,0.0}, "", 0.0); //First offset we go by
		int particle_5 = InfoTargetParentAt({-2.7,67.5,0.0}, "", 0.0); //First offset we go by

		
		int particle_2_1 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
		int particle_3_1 = InfoTargetParentAt({20.5,0.0,0.0}, "", 0.0); //First offset we go by
		int particle_4_1 = InfoTargetParentAt({6.75,13.5,0.0}, "", 0.0); //First offset we go by
		int particle_5_1 = InfoTargetParentAt({2.7,67.5,0.0}, "", 0.0); //First offset we go by

		SetParent(particle_1, particle_2, "",_, true);
		SetParent(particle_1, particle_3, "",_, true);
		SetParent(particle_1, particle_4, "",_, true);
		SetParent(particle_1, particle_5, "",_, true);
		
		SetParent(particle_1, particle_2_1, "",_, true);
		SetParent(particle_1, particle_3_1, "",_, true);
		SetParent(particle_1, particle_4_1, "",_, true);
		SetParent(particle_1, particle_5_1, "",_, true);

		Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
		SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
		SetParent(entity, particle_1, "effect_hand_l",_);


		int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);

		int Laser_1_1 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_2_1 = ConnectWithBeamClient(particle_3_1, particle_4_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_3_1 = ConnectWithBeamClient(particle_4_1, particle_5_1, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);
		

		i_ExpidonsaEnergyEffect[entity][0] = EntIndexToEntRef(particle_1);
		i_ExpidonsaEnergyEffect[entity][1] = EntIndexToEntRef(particle_2);
		i_ExpidonsaEnergyEffect[entity][2] = EntIndexToEntRef(particle_3);
		i_ExpidonsaEnergyEffect[entity][3] = EntIndexToEntRef(particle_4);
		i_ExpidonsaEnergyEffect[entity][4] = EntIndexToEntRef(particle_5);
		i_ExpidonsaEnergyEffect[entity][5] = EntIndexToEntRef(Laser_1);
		i_ExpidonsaEnergyEffect[entity][6] = EntIndexToEntRef(Laser_2);
		i_ExpidonsaEnergyEffect[entity][7] = EntIndexToEntRef(Laser_3);
		
		i_ExpidonsaEnergyEffect[entity][8] = EntIndexToEntRef(particle_2_1);
		i_ExpidonsaEnergyEffect[entity][9] = EntIndexToEntRef(particle_3_1);
		i_ExpidonsaEnergyEffect[entity][10] = EntIndexToEntRef(particle_4_1);
		i_ExpidonsaEnergyEffect[entity][11] = EntIndexToEntRef(particle_5_1);
		i_ExpidonsaEnergyEffect[entity][12] = EntIndexToEntRef(Laser_1_1);
		i_ExpidonsaEnergyEffect[entity][13] = EntIndexToEntRef(Laser_2_1);
		i_ExpidonsaEnergyEffect[entity][14] = EntIndexToEntRef(Laser_3_1);	
	}
}

static int LastEnemyTargeted[MAXENTITIES];

bool SilvesterSwordSlicer(Silvester npc, bool NemalAssistance)
{
	if(npc.m_flSilvesterSlicerHappening)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			bool ForceRedo = false;
			npc.m_flGetClosestTargetTime = 0.0;
			if(NemalAssistance)
			{
				CClotBody allynpc = view_as<CClotBody>(npc.m_iTargetAlly);
				if(allynpc.m_iTarget == npc.m_iTarget)
				{
					ForceRedo = true;
				}
				if(ForceRedo || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
				{
					npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,allynpc.m_iTarget);
					npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
				}
			}
			else
			{
				if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
				{
					npc.m_iTarget = GetClosestTarget(npc.index);
					npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
				}
			}
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

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS",_,_,_, 2.0);
					float DamageCalc = 50.0 * RaidModeScaling;
					float VecEnemy[3]; WorldSpaceCenter(TargetEnemy, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					NemalAirSlice(npc.index, TargetEnemy, DamageCalc, 215, 150, 0, 200.0, 6, 1750.0, "rockettrail_fire", false);
					npc.PlayRangedSound();
				}
			}
		}
		if(npc.m_flSilvesterSlicerHappening < GetGameTime(npc.index))
		{
			
			if(npc.m_iChanged_WalkCycle != 999)
			{
				npc.m_iChanged_WalkCycle = 999;
				i_NpcWeight[npc.index] = 999;
				b_NoGravity[npc.index] = true;
				npc.m_flAttackHappens = 0.0;
				npc.SetVelocity({0.0,0.0,0.0});
				npc.m_flSilvesterSlicerHappening = GetGameTime(npc.index) + 2.0;	
				npc.m_bisWalking = false;
				npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
				return true;
			}
			npc.m_iChanged_WalkCycle = 0;
			i_NpcWeight[npc.index] = 4;
			b_NoGravity[npc.index] = false;
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flSilvesterSlicerHappening = 0.0;	
			npc.SetVelocity({0.0,0.0,-1000.0});
		}
		return true;
	}
	return false;
}



bool IsPartnerGivingUpNemalSilv(int iNpc)
{
	CClotBody npc = view_as<CClotBody>(iNpc);
	CClotBody allynpc = view_as<CClotBody>(npc.m_iTargetAlly);
	if(!IsValidEntity(allynpc.index))
		return true;

	return b_angered_twice[allynpc.index];
}