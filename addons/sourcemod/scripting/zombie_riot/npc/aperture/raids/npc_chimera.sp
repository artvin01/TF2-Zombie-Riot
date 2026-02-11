#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/medic_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/medic_mvm_paincrticialdeath03.mp3",
};

#define CHIMERA_SAFE_RANGE 700.0
static const char g_HurtSounds[][] = {
	"vo/mvm/norm/medic_mvm_painsharp01.mp3",
	"vo/mvm/norm/medic_mvm_painsharp02.mp3",
	"vo/mvm/norm/medic_mvm_painsharp03.mp3",
	"vo/mvm/norm/medic_mvm_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/medic_mvm_battlecry01.mp3",
	"vo/mvm/norm/medic_mvm_battlecry02.mp3",
	"vo/mvm/norm/medic_mvm_battlecry03.mp3",
	"vo/mvm/norm/medic_mvm_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_draw.wav",
};
static const char g_MeleeAttackSounds_Hand[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/manhack/grind_flesh1.wav",
	"npc/manhack/grind_flesh2.wav",
	"npc/manhack/grind_flesh3.wav",
};
static const char g_MeleeHitSounds_Hand[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
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
	"mvm/giant_heavy/giant_heavy_loop.wav",
};
static const char g_BatteryBladeEmpty[][] = {
	"weapons/cow_mangler_explosion_normal_04.wav",
	"weapons/cow_mangler_explosion_normal_05.wav",
	"weapons/cow_mangler_explosion_normal_06.wav",
};
static const char g_StunChimera[][] = {
	"mvm/mvm_robo_stun.wav",
};
static const char g_StunChimeraEnd[][] = {
	"mvm/mvm_warning.wav",
};
static const char g_RefractedAbilityStart[][] = {
	"npc/env_headcrabcanister/launch.wav",
};
static const char g_RefractedSniperSpawn[][] = {
	"ambient/levels/citadel/portal_open1_adpcm.wav",
};

static const char g_AdaptabiliyStart[][] = {
	"mvm/mvm_tank_start.wav",
};
static const char g_AdaptabiliyEnd[][] = {
	"mvm/mvm_tele_activate.wav",
};
static const char g_chimeraSuperSlash[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
	"weapons/vaccinator_charge_tier_02.wav",
	"weapons/vaccinator_charge_tier_03.wav",
	"weapons/vaccinator_charge_tier_04.wav",
};

static const char g_DeathSpawnTeleSound[][] =
{
	"misc/halloween/spell_teleport.wav",
};
static const char g_DeathUseTeleSound[][] =
{
	")ui/mm_scoreboardpanel_slide.wav",
};

void CHIMERA_OnMapStart_NPC()
{
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "C.H.I.M.E.R.A.");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chimera");
	strcopy(data.Icon, sizeof(data.Icon), "chimera");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel("models/bots/medic/bot_medic.mdl");
	PrecacheSoundCustom("#zombiesurvival/aperture/chimera.mp3");
	for (int i = 0; i < (sizeof(g_StunChimera));	   i++) { PrecacheSound(g_StunChimera[i]);	   }
	for (int i = 0; i < (sizeof(g_StunChimeraEnd));	   i++) { PrecacheSound(g_StunChimeraEnd[i]);	   }
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds_Hand)); i++) { PrecacheSound(g_MeleeAttackSounds_Hand[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds_Hand)); i++) { PrecacheSound(g_MeleeHitSounds_Hand[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_ShotgunReloadingSounds));   i++) { PrecacheSound(g_ShotgunReloadingSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MalfunctionSounds));   i++) { PrecacheSound(g_MalfunctionSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	for (int i = 0; i < (sizeof(g_BatteryBladeEmpty));   i++) { PrecacheSound(g_BatteryBladeEmpty[i]);   }
	for (int i = 0; i < (sizeof(g_RefractedAbilityStart));   i++) { PrecacheSound(g_RefractedAbilityStart[i]);   }
	for (int i = 0; i < (sizeof(g_RefractedSniperSpawn));   i++) { PrecacheSound(g_RefractedSniperSpawn[i]);   }
	for (int i = 0; i < (sizeof(g_AdaptabiliyStart));   i++) { PrecacheSound(g_AdaptabiliyStart[i]);   }
	for (int i = 0; i < (sizeof(g_chimeraSuperSlash));   i++) { PrecacheSound(g_chimeraSuperSlash[i]);   }
	for (int i = 0; i < (sizeof(g_DeathSpawnTeleSound));   i++) { PrecacheSound(g_DeathSpawnTeleSound[i]);   }
	for (int i = 0; i < (sizeof(g_DeathUseTeleSound));   i++) { PrecacheSound(g_DeathUseTeleSound[i]);   }
	PrecacheSound("weapons/physcannon/energy_sing_flyby1.wav");
	PrecacheSound("npc/env_headcrabcanister/explosion.wav.wav");
	
	PrecacheParticleSystem("eyeboss_tp_vortex");
	PrecacheParticleSystem("eyeboss_tp_normal");
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CHIMERA(vecPos, vecAng, ally, data);
}

methodmap CHIMERA < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}

	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		if(this.m_flBatteryLeftBlade)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 140);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds_Hand[GetRandomInt(0, sizeof(g_MeleeAttackSounds_Hand) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
		}
	}
	public void PlayMeleeHitSound() 
	{
		if(this.m_flBatteryLeftBlade)
			EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MeleeHitSounds_Hand[GetRandomInt(0, sizeof(g_MeleeHitSounds_Hand) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
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
	public void PlayStunSound()
	{
		EmitSoundToAll(g_StunChimera[GetRandomInt(0, sizeof(g_StunChimera) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
	}
	public void StopStunSound(bool death)
	{
		StopSound(this.index, SNDCHAN_STATIC, g_StunChimera[GetRandomInt(0, sizeof(g_StunChimera) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_StunChimera[GetRandomInt(0, sizeof(g_StunChimera) - 1)]);
		if(!death)
		{
			EmitSoundToAll(g_StunChimeraEnd[GetRandomInt(0, sizeof(g_StunChimeraEnd) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
			EmitSoundToAll(g_StunChimeraEnd[GetRandomInt(0, sizeof(g_StunChimeraEnd) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 100);
		}
	}
	public void PlayBatteryEmpty()
	{
		EmitSoundToAll(g_BatteryBladeEmpty[GetRandomInt(0, sizeof(g_BatteryBladeEmpty) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 80);
		EmitSoundToAll(g_BatteryBladeEmpty[GetRandomInt(0, sizeof(g_BatteryBladeEmpty) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 80);
	}

	public void PlayRefractedAbilityBall()
	{
		EmitSoundToAll(g_RefractedAbilityStart[GetRandomInt(0, sizeof(g_RefractedAbilityStart) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 120);
		EmitSoundToAll(g_RefractedAbilityStart[GetRandomInt(0, sizeof(g_RefractedAbilityStart) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 120);
	}
	public void PlayRefractedAbilitySniper()
	{
		EmitSoundToAll(g_RefractedSniperSpawn[GetRandomInt(0, sizeof(g_RefractedSniperSpawn) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 150);
		EmitSoundToAll(g_RefractedSniperSpawn[GetRandomInt(0, sizeof(g_RefractedSniperSpawn) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 150);
		EmitSoundToAll(g_RefractedSniperSpawn[GetRandomInt(0, sizeof(g_RefractedSniperSpawn) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 150);
		EmitSoundToAll(g_RefractedSniperSpawn[GetRandomInt(0, sizeof(g_RefractedSniperSpawn) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 150);
		EmitSoundToAll(g_RefractedSniperSpawn[GetRandomInt(0, sizeof(g_RefractedSniperSpawn) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 150);
	}
	public void PlayAdaptStart()
	{
		EmitSoundToAll(g_AdaptabiliyStart[GetRandomInt(0, sizeof(g_AdaptabiliyStart) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	public void PlaySlashStart()
	{
		EmitSoundToAll(g_chimeraSuperSlash[GetRandomInt(0, sizeof(g_chimeraSuperSlash) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	public void PlayAdaptEnd()
	{
		EmitSoundToAll(g_AdaptabiliyEnd[GetRandomInt(0, sizeof(g_AdaptabiliyEnd) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	public void PlayDeathSpawnTeleSound()
	{
		EmitSoundToAll(g_DeathSpawnTeleSound[GetRandomInt(0, sizeof(g_DeathSpawnTeleSound) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
		EmitSoundToAll(g_DeathSpawnTeleSound[GetRandomInt(0, sizeof(g_DeathSpawnTeleSound) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	public void PlayDeathUseTeleSound()
	{
		EmitSoundToAll(g_DeathUseTeleSound[GetRandomInt(0, sizeof(g_DeathUseTeleSound) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
		EmitSoundToAll(g_DeathUseTeleSound[GetRandomInt(0, sizeof(g_DeathUseTeleSound) - 1)], this.index, SNDCHAN_STATIC, 100, _, 1.0, 100);
	}
	
	property float m_flBatteryLeftBlade
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flStunDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flSpawnAnnotation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flSpawnSnipers
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flChargeVulnPhase
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flDamageCharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	property float m_flSpawnEvilRefractCircles
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flSuperSlash
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flSuperSlashInAbility
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property float m_flSuperSlashInAbilityDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property float m_flDeathAnim
	{
		public get()							{ return fl_NextRangedSpecialAttackHappens[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedSpecialAttackHappens[this.index] = TempValueForProperty; }
	}
	property int m_iDeathState
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	
	public CHIMERA(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CHIMERA npc = view_as<CHIMERA>(CClotBody(vecPos, vecAng, "models/bots/medic/bot_medic.mdl", "1.45", "700", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		npc.SetActivity("ACT_MP_RUN_MELEE");

		func_NPCDeath[npc.index] = CHIMERA_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CHIMERA_OnTakeDamage;
		func_NPCThink[npc.index] = CHIMERA_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);

		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		npc.PlayPassiveSound();
		
		float RaidTimeDo = 160.0;
		npc.m_flBatteryLeftBlade = GetGameTime(npc.index) + (RaidTimeDo * 0.5);
		npc.m_flSpawnEvilRefractCircles = GetGameTime() + 5.0;
		npc.m_flSuperSlash = GetGameTime() + 15.0;
		npc.m_flSpawnSnipers = GetGameTime() + 20.0;
		RaidModeTime = GetGameTime(npc.index) + RaidTimeDo;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "???");
			}
		}
		npc.m_flMeleeArmor = 1.25;	
		
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
			
		RaidModeScaling *= 1.25;
		//scaling old
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aperture/chimera.mp3");
		music.Time = 126;
		music.Volume = 0.7;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Citadel's End");
		strcopy(music.Artist, sizeof(music.Artist), "Serious Sam : Siberian Mayhem");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = -1;	
		npc.m_iNpcStepVariation = -1;
		
		npc.m_flSpeed = 330.0;
		npc.m_bDissapearOnDeath = true;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();

		CreateTimer(0.2, CHIMERA_Timer_IntroMessage, EntIndexToEntRef(npc.index));

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/tw_medibot_chariot/tw_medibot_chariot.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec24_polar_charger_style4/dec24_polar_charger_style4.mdl", _, skin);

		float flPos[3];
		float flAng[3];
		npc.GetAttachment("flag", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "projectile_fireball_smoke", npc.index, "flag", {0.0,0.0,0.0});

		npc.m_iWearable5 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetVariantInt(8192);
		AcceptEntityInput(npc.m_iWearable5, "SetBodyGroup");
		SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 8);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "env_snow_light_001", npc.index, "", {50.0,-200.0,0.0});
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "head", {0.0,0.0,0.0});
		
		npc.m_flSpawnAnnotation = GetGameTime() + 0.5;
		
		int color[4] = { 100, 100, 200, 50 };
		SetCustomFog(FogType_NPC, color, color, 400.0, 1000.0, 0.65, true);
		
		return npc;
	}
}

static void CHIMERA_Timer_IntroMessage(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (ref == INVALID_ENT_REFERENCE || b_NpcHasDied[entity])
		return;
	
	switch(GetRandomInt(0,2))
	{
		case 0:
			CHIMERA_Talk(entity, "WELCOME, WELCOME SINNERS!");
		case 1:
			CHIMERA_Talk(entity, "LET'S BEGIN");
		case 2:
			CHIMERA_Talk(entity, "ENGAGING THE TARGETS");
	}
}

static void CHIMERA_Talk(int entity, const char[] message)
{
	PrintNPCMessageWithPrefixes(entity, "darkblue", message);
}

public void CHIMERA_ClotThink(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	float gameTime = GetGameTime(iNPC);
	
	if(CHIMERA_LoseConditions(iNPC))
		return;
	if(CHIMERA_timeBased(iNPC))
		return;

	if(npc.m_flNextDelayTime > gameTime)
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
		return;
		
	npc.m_flNextThinkTime = gameTime + 0.1;

	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	Chimera_ApplyDebuffInLocation(VecSelfNpcabs, GetTeam(npc.index));
	spawnRing_Vectors(VecSelfNpcabs, CHIMERA_SAFE_RANGE * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 200, 1, /*duration*/ 0.11, 20.0, 5.0, 1);	
	CHIMERA_SpawnAnnotation(iNPC);
	if(CHIMERA_SuperSlash(iNPC))
		return;
	if(CHIMERA_RefractedSniper(iNPC))
		return;
	if(CHIMERA_RefractSpawners(iNPC))
		return;

	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}

	int EnemyTarget = npc.m_iTarget;
	if (IsValidEnemy(npc.index, EnemyTarget))
	{
		float vecPos[3], vecTargetPos[3];
		WorldSpaceCenter(npc.index, vecPos);
		WorldSpaceCenter(EnemyTarget, vecTargetPos);
		
		float distance = GetVectorDistance(vecPos, vecTargetPos, true);
	
		// Predict their pos when not loading our gun
		if (distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, EnemyTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(EnemyTarget);
		}
		
		CHIMERA_SelfDefense(npc, gameTime, EnemyTarget, distance);
	}
	else
	{
		//no valid target, do stuff.
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleAlertSound();
}

static void CHIMERA_SelfDefense(CHIMERA npc, float gameTime, int target, float distance)
{
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
			
			char killicon[64];
			
			float damage = 35.0;
			damage *= RaidModeScaling;
			
			if(npc.m_flBatteryLeftBlade)
			{
				damage *= 1.5;
				killicon = "merasmus_decap";
			}
			else
			{
				killicon = "robot_arm_kill";
			}
			
			KillFeed_SetKillIcon(npc.index, killicon);
			
			bool silenced = NpcStats_IsEnemySilenced(npc.index);
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
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}

public Action CHIMERA_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CHIMERA npc = view_as<CHIMERA>(victim);
	
	if (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
	{
		CHIMERA_CleanUp(npc.index);
		
		if (Aperture_ShouldDoLastStand())
		{
			// We're in Laboratories, the boss' think/death functions will be hijacked
			npc.m_iState = APERTURE_BOSS_CHIMERA; // This will store the boss's "type"
			fl_TotalArmor[npc.index] = 1.0;
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.0;
			Aperture_Shared_LastStandSequence_Starting(view_as<CClotBody>(npc));
		}
		else if (!npc.m_flDeathAnim)
		{
			// We're not in Laboratories, don't die immediately, we do an animation first
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			ApplyStatusEffect(npc.index, npc.index, "Infinite Will", 99999.0);
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 99999.0);
			
			npc.m_flDeathAnim = 1.0;
		}
		
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if(attacker <= 0)
		return Plugin_Continue;
		
	if(npc.m_flChargeVulnPhase)
	{
		if(damagetype & DMG_CLUB)
		{
			npc.m_flDamageCharge += damage * 1.0;
		}
		else
		{
			npc.m_flDamageCharge -= damage * 1.0;
		}
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!npc.Anger)
	{
		if((ReturnEntityMaxHealth(npc.index) / 2) >= (GetEntProp(npc.index, Prop_Data, "m_iHealth") - RoundToNearest(damage)))
		{
			npc.PlayAdaptStart();
			CHIMERA_Talk(npc.index, "TOO MUCH DAMAGE SUSTAINED, INITIATING {crimson}[DAMAGE ADAPTABILITY MODE]");
			float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
			TE_Particle("teleported_mvm_bot", VecSelfNpcabs, _, _, npc.index, 1, 0);
			npc.Anger = true;
			npc.m_flChargeVulnPhase = GetGameTime() + 10.0;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
			fl_TotalArmor[npc.index] = 0.5;
			RaidModeTime += 30.0;
			HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) / 4.0, _, 10.0, HEAL_ABSOLUTE);
		}
	}
	
	return Plugin_Changed;
}

public void CHIMERA_NPCDeath(int entity)
{
	CHIMERA npc = view_as<CHIMERA>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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
	
	CHIMERA_CleanUp(npc.index);
}

void CHIMERA_CleanUp(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	npc.StopPassiveSound();
	npc.StopStunSound(true);
	ClearCustomFog(FogType_NPC);
}

bool CHIMERA_timeBased(int iNPC)
{

	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(npc.m_flChargeVulnPhase)
	{
		if(npc.m_flChargeVulnPhase < GetGameTime())
		{
			npc.PlayAdaptEnd();
			fl_TotalArmor[npc.index] = 1.0;
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StopStunSound(false);
			npc.m_flChargeVulnPhase = 0.0;
			npc.m_flSpawnSnipers = 1.0;
			npc.m_flSpawnEvilRefractCircles = 1.0;
			//do both abilities twice.
			if(npc.m_flDamageCharge < 0.0)
			{
				CHIMERA_Talk(npc.index, "ADAPTING COMPLETED, {crimson}RANGED{default} IS CONSIDERED THE MOST DANGEROUS.");
				npc.m_flRangedArmor = 0.75;
				npc.m_flMeleeArmor = 1.35;
			}
			else
			{
				CHIMERA_Talk(npc.index, "ADAPTING COMPLETED, {crimson}MELEE{default} IS CONSIDERED THE MOST DANGEROUS.");
				npc.m_flRangedArmor = 1.35;
				npc.m_flMeleeArmor = 0.75;
			}
			if(npc.m_flBatteryLeftBlade)
			{
				//if blade is still on, extend
				npc.m_flBatteryLeftBlade += 15.0;
			}
		}
		return true;
	}
	//idk it never was in a bracket
	if(npc.m_flBatteryLeftBlade && npc.m_flBatteryLeftBlade < GetGameTime())
	{
		npc.m_flBatteryLeftBlade = 0.0;
		npc.m_flStunDuration = GetGameTime(npc.index) + 5.0;
		npc.StopPathing();
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_DIEVIOLENT");
		npc.SetPlaybackRate(0.35);

		CPrintToChatAll("{crimson}C.H.I.M.E.R.A.'s Expidonsan blade detects unauthorised usage and self-destructs.");
		float flPos[3];
		float flAng[3];
		int Particle_1;
		npc.GetAttachment("flag", flPos, flAng);
		Particle_1 = ParticleEffectAt_Parent(flPos, "drg_cow_explosion_sparkles_blue", npc.index, "flag", {0.0,0.0,0.0});
		CreateTimer(0.75, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
		npc.PlayBatteryEmpty();
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		npc.PlayStunSound();
	}
	if(npc.m_flStunDuration)
	{
		if(npc.m_flStunDuration < GetGameTime(npc.index))
		{
			npc.m_flStunDuration = 0.0;
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.StopStunSound(false);
		}
		return true;
	}

	return false;
}
bool CHIMERA_LoseConditions(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if (npc.m_flDeathAnim)
	{
		if (npc.m_flDeathAnim > GetGameTime())
			return true;
		
		switch (npc.m_iDeathState)
		{
			case 0:
			{
				float vecPos[3];
				WorldSpaceCenter(npc.index, vecPos);
				ParticleEffectAt(vecPos, "eyeboss_tp_vortex", 1.5);
				
				npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
				npc.PlayDeathSpawnTeleSound();
				
				npc.m_flSpeed = 0.0;
				npc.m_bisWalking = false;
				npc.StopPathing();
				
				npc.m_flDeathAnim = GetGameTime() + 1.5;
				
				switch (GetURandomInt() % 4)
				{
					case 0:
						CHIMERA_Talk(npc.index, "IT RECOILS IN PAIN?");
					case 1:
						CHIMERA_Talk(npc.index, "I NEED A DISTRACTION. ERROR? ERROR? ERROR?");
					case 2:
						CHIMERA_Talk(npc.index, "THIS PLACE IS TOO HOT FOR ME.");
					case 3:
						CHIMERA_Talk(npc.index, "I MIGHT NOT BE WELCOME HERE?");
				}
			}
			
			case 1:
			{
				float vecPos[3];
				WorldSpaceCenter(npc.index, vecPos);
				ParticleEffectAt(vecPos, "eyeboss_tp_normal");
				npc.PlayDeathUseTeleSound();
				
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}
		
		npc.m_iDeathState++;
		npc.Update();
		return true;
	}
	
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CHIMERA_Talk(npc.index, "ZIBERIA WOULD BE PROUD, PROVIDED THEY WERE TO SEE ME NOW.");
		return true;
	}
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CHIMERA_Talk(npc.index, "TIME TO CHOOSE. LIFE, OR DEATH?");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return true;
	}

	return false;
}


	
void Chimera_ApplyDebuffInLocation(float BannerPos[3], int Team)
{
	float targPos[3];
	float Range = CHIMERA_SAFE_RANGE;

	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) != Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) > (Range * Range))
			{
				ApplyStatusEffect(ally, ally, "Near Zero", 1.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) != Team)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) > (Range * Range))
			{
				ApplyStatusEffect(ally, ally, "Near Zero", 1.0);
			}
		}
	}
}

void CHIMERA_SpawnAnnotation(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(!npc.m_flSpawnAnnotation)
		return;
	if(npc.m_flSpawnAnnotation > GetGameTime())	
		return;
	npc.m_flSpawnAnnotation = 0.0;
	Event event = CreateEvent("show_annotation");
	if(event)
	{
		static float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		pos[2] += 160.0;
		event.SetFloat("worldPosX", pos[0]);
		event.SetFloat("worldPosY", pos[1]);
		event.SetFloat("worldPosZ", pos[2]);
		event.SetInt("follow_entindex", npc.index);
		event.SetFloat("lifetime", 5.0);
		event.SetString("text", "Extreme freeze detected!\nStand near C.H.I.M.E.R.A. to not be frozen!");
		event.SetString("play_sound", "vo/null.mp3");
		event.SetInt("id", 6000+npc.index);
		event.Fire();
	}
}

bool CHIMERA_RefractedSniper(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(npc.m_flSpawnSnipers > GetGameTime(npc.index))
		return false;

	float flPos[3];
	npc.PlayRefractedAbilitySniper();
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flPos);
	flPos[2] += 45;
	ParticleEffectAt(flPos, "eyeboss_tp_vortex", 1.0);
	//players only
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
	UnderTides npcGetInfo = view_as<UnderTides>(iNPC);
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true);
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			char buffers[64];
			IntToString(enemy_2[i], buffers, sizeof(buffers));
			NPC_CreateByName("npc_refragmented_winter_sniper", -1, pos, ang, GetTeam(npc.index), buffers);
		}
	}
	switch(GetRandomInt(0,4))
	{
		case 0:
			CHIMERA_Talk(npc.index, "BREWING UP A STORM");
		case 1:
			CHIMERA_Talk(npc.index, "KEEP RUNNING, THAT'LL HELP");
		case 2:
			CHIMERA_Talk(npc.index, "LET'S COOL THINGS DOWN");
		case 3:
			CHIMERA_Talk(npc.index, "FOOLISH MORTALS, YOU THINK YOU CAN STOP ME?");
		case 4:
			CHIMERA_Talk(npc.index, "DIE ALREADY, I'M GIVING IT ALL ALREADY!");
	}
	if(npc.m_flSpawnSnipers == 1.0)
		npc.m_flSpawnSnipers = GetGameTime(npc.index) + 10.0;
	else
		npc.m_flSpawnSnipers = GetGameTime(npc.index) + 40.0;
	return true;
}

bool CHIMERA_RefractSpawners(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(npc.m_flSpawnEvilRefractCircles > GetGameTime(npc.index))
		return false;

	
	switch(GetRandomInt(0,3))
	{
		case 0:
			CHIMERA_Talk(npc.index, "LOOK OUT, I'M RIGHT BEHIND YOU");
		case 1:
			CHIMERA_Talk(npc.index, "YOU STOP RUNNING AND I'LL STOP FIRING, THAT SEEMS FAIR");
		case 2:
			CHIMERA_Talk(npc.index, "THIS WOULD GO A LOT FASTER IF YOU'D STAY STILL");
		case 3:
			CHIMERA_Talk(npc.index, "DON'T RUN! DON'T RUN!");
		case 4:
			CHIMERA_Talk(npc.index, "YOU'RE JUST DELAYING THE INEVITABLE");

	}
	npc.PlayRefractedAbilityBall();
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
	//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
	GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, npc.m_iWearable7);
	if(npc.m_flSpawnEvilRefractCircles == 1.0)
		npc.m_flSpawnEvilRefractCircles = GetGameTime(npc.index) + 1.0;
	else
		npc.m_flSpawnEvilRefractCircles = GetGameTime(npc.index) + 20.0;
	for(int i; i < sizeof(enemy); i++)
	{
		if(enemy[i])
		{
			int Target = enemy[i];
			float vecHit[3];
			float vecHitPart[3];
			GetEntPropVector(npc.m_iWearable7, Prop_Data, "m_vecAbsOrigin", vecHitPart);

			vecHit = vecHitPart;
			vecHit[2] += 100.0;
			vecHit[1] += GetRandomInt(-50,50);
			vecHit[0] += GetRandomInt(-50,50);
			int projectile = npc.FireParticleRocket(vecHit, 0.0, 700.0, 1.0, "spell_teleport_black", false,_,true, vecHitPart);
			
			WandProjectile_ApplyFunctionToEntity(projectile, Chimera_RefragmentedProjectileSpawner);			
			static float ang_Look[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
			Initiate_HomingProjectile(projectile,
			npc.index,
				360.0,			// float lockonAngleMax,
				13.5,				//float homingaSec,
				true,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				ang_Look,			
				Target); //home onto this enemy
			CreateTimer(2.0, Chimera_Removehoming, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return true;
}

public Action Chimera_Removehoming(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		HomingProjectile_Deactivate(entity);
	}
	return Plugin_Stop;
}

public void Chimera_RefragmentedProjectileSpawner(int entity, int target)
{
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	//we uhh, missed?
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
	}
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	CHIMERAPlaceAirMinesInternal(owner, 1.0, 1.0, 15.0, 100.0, pos);
	EmitSoundToAll("npc/env_headcrabcanister/explosion.wav", 0, _, 80, _, 0.8,130,_,pos);
	EmitSoundToAll("npc/env_headcrabcanister/explosion.wav", 0, _, 80, _, 0.8,130,_,pos);
	RemoveEntity(entity);
}



void CHIMERAPlaceAirMinesInternal(int iNpc, float damage, float TimeUntillArm, float MaxDuration, float Size, float LocationOfMine[3])
{

	LocationOfMine[2] += 1.0;
	
	Handle ToGroundTrace = TR_TraceRayFilterEx(LocationOfMine, view_as<float>( { 90.0, 0.0, 0.0 } ), MASK_SOLID, RayType_Infinite, TraceRayHitWorldOnly, iNpc);
	TR_GetEndPosition(LocationOfMine, ToGroundTrace);
	delete ToGroundTrace;
	LocationOfMine[2] += 5.0;

	DataPack pack2;
	CreateDataTimer(0.25, Timer_CHIMERAMineLogic, pack2, TIMER_REPEAT);
	pack2.WriteCell(EntIndexToEntRef(iNpc));
	pack2.WriteFloat(LocationOfMine[0]);
	pack2.WriteFloat(LocationOfMine[1]);
	pack2.WriteFloat(LocationOfMine[2]);
	pack2.WriteFloat(damage);
	pack2.WriteFloat(Size);
	pack2.WriteFloat(TimeUntillArm + GetGameTime());
	pack2.WriteFloat(MaxDuration + GetGameTime());
}
public Action Timer_CHIMERAMineLogic(Handle timer, DataPack pack)
{
	pack.Reset();
	int MasterNpc = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(MasterNpc))
		return Plugin_Stop;
	//the master npc isnt existant anymore, delete all mines instantly.
	
	int lastStandBoss = EntRefToEntIndex(Aperture_GetLastStandBoss());
	if (lastStandBoss == MasterNpc)
		return Plugin_Stop;
	//the master npc is in the process of dying, delete all mines instantly.
		
	float MinePositionGet[3];
	MinePositionGet[0] = pack.ReadFloat();
	MinePositionGet[1] = pack.ReadFloat();
	MinePositionGet[2] = pack.ReadFloat();
	float Damage_Do = pack.ReadFloat();
	float Size = pack.ReadFloat();
	float TimeUntillArm = pack.ReadFloat();
	if(TimeUntillArm > GetGameTime())
	{
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 50, 50, 100, 200, 1, 0.3, 2.0, 2.0, 2);
		//Do not do damage calculations yet.
		return Plugin_Continue; 
	}
	DetonateCurrentMine = false;
	
	spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 125, 200, 200, 1, 0.3, 5.0, 8.0, 2);
	
	KillFeed_SetKillIcon(MasterNpc, "bluecapture");
	Explode_Logic_Custom(Damage_Do, 0, MasterNpc, -1, MinePositionGet, Size, 1.0, _, true, 20,_,_,_,CHIMERAMineExploder);

	if(DetonateCurrentMine)
	{
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 125, 125, 200, 200, 1, 0.5, 12.0, 10.0, 2);
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 125, 125, 200, 200, 1, 0.5, 12.0, 10.0, 2);
		spawnRing_Vectors(MinePositionGet, Size * 2.0, 0.0, 0.0, 20.0, "materials/sprites/laserbeam.vmt", 125, 125, 200, 200, 1, 0.5, 12.0, 10.0, 2);
		//It hit something, boom.
		EmitSoundToAll("weapons/physcannon/energy_sing_flyby1.wav", 0, _, 80, _, 0.7,_,_,MinePositionGet);
		EmitSoundToAll("weapons/physcannon/energy_sing_flyby1.wav", 0, _, 80, _, 0.7,_,_,MinePositionGet);
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

float CHIMERAMineExploder(int entity, int victim, float damage, int weapon)
{
	DetonateCurrentMine = true;
	
	char buffers[64];
	IntToString(victim, buffers, sizeof(buffers));
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	int NpcSpawn = NPC_CreateByName("npc_refragmented_frost_hunter", -1, pos, ang, GetTeam(entity), buffers);
	TeleportDiversioToRandLocation(NpcSpawn);

	return damage;
}






#define CHIMERA_MELEE_SIZE 50
#define CHIMERA_MELEE_SIZE_F 50.0

bool CHIMERA_SuperSlash(int iNPC)
{
	CHIMERA npc = view_as<CHIMERA>(iNPC);
	if(npc.m_flSuperSlashInAbility)
	{
		if(npc.m_flSuperSlashInAbilityDo)
		{
			if(npc.m_flSuperSlashInAbilityDo < GetGameTime(npc.index))
			{
				npc.m_flSuperSlashInAbilityDo = 0.0;		
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
				Npc_Teleport_Safe(npc.index, f3_NpcSavePos[npc.index], hullcheckmins, hullcheckmaxs);
			}
			return true;
		}
		if(npc.m_flSuperSlashInAbility > GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			int EnemyTarget = npc.m_iTarget;
			if (IsValidEnemy(npc.index, EnemyTarget))
			{
				npc.PlaySlashStart();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
				float vecTarget[3];
				b_TryToAvoidTraverse[npc.index] = false;
				PredictSubjectPosition(npc, EnemyTarget,_,_, vecTarget);
				vecTarget = GetBehindTarget(EnemyTarget, 60.0 ,vecTarget);
				b_TryToAvoidTraverse[npc.index] = true;

				int red = 255;
				int green = 255;
				int blue = 255;
				int Alpha = 255;

				int colorLayer4[4];
				float diameter = float(CHIMERA_MELEE_SIZE * 4);
				SetColorRGBA(colorLayer4, red, green, blue, Alpha);
				//we set colours of the differnet laser effects to give it more of an effect
				int colorLayer1[4];
				SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
				int glowColor[4];
				float VectorStart[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VectorStart);
				f3_NpcSavePos[npc.index] = vecTarget;
				npc.FaceTowards(vecTarget, 20000.0);
				float damage = 40.0;
				damage *= RaidModeScaling;
				if(npc.m_flBatteryLeftBlade)
				{
					damage *= 1.5;
				}

				npc.m_flSuperSlashInAbilityDo = GetGameTime(npc.index) + 0.5;

				float vecForward[3], Angles[3];

				GetVectorAnglesTwoPoints(VectorStart, vecTarget, Angles);
				GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);				
				DataPack pack = new DataPack();
				pack.WriteCell(EntIndexToEntRef(npc.index));
				pack.WriteFloat(VectorStart[0]);
				pack.WriteFloat(VectorStart[1]);
				pack.WriteFloat(VectorStart[2]);
				pack.WriteFloat(vecTarget[0]);
				pack.WriteFloat(vecTarget[1]);
				pack.WriteFloat(vecTarget[2]);
				pack.WriteFloat(damage);
				pack.WriteCell(0);
				// 66.6 assumes normal tickrate.
				int i_FrameCount = RoundToNearest(0.5 * 66.6);
				RequestFrames(BobInitiatePunch_DamagePart, i_FrameCount, pack);
				for(int BeamCube = 0; BeamCube < 4 ; BeamCube++)
				{
					float OffsetFromMiddle[3];
					switch(BeamCube)
					{
						case 0:
						{
							OffsetFromMiddle = {0.0, CHIMERA_MELEE_SIZE_F,CHIMERA_MELEE_SIZE_F};
						}
						case 1:
						{
							OffsetFromMiddle = {0.0, -CHIMERA_MELEE_SIZE_F,-CHIMERA_MELEE_SIZE_F};
						}
						case 2:
						{
							OffsetFromMiddle = {0.0, CHIMERA_MELEE_SIZE_F,-CHIMERA_MELEE_SIZE_F};
						}
						case 3:
						{
							OffsetFromMiddle = {0.0, -CHIMERA_MELEE_SIZE_F,CHIMERA_MELEE_SIZE_F};
						}
					}
					float AnglesEdit[3];
					AnglesEdit[0] = Angles[0];
					AnglesEdit[1] = Angles[1];
					AnglesEdit[2] = Angles[2];

					float VectorStartEdit[3];
					VectorStartEdit[0] = VectorStart[0];
					VectorStartEdit[1] = VectorStart[1];
					VectorStartEdit[2] = VectorStart[2];
					float VectorStartEdit2[3];
					VectorStartEdit2[0] = f3_NpcSavePos[npc.index][0];
					VectorStartEdit2[1] = f3_NpcSavePos[npc.index][1];
					VectorStartEdit2[2] = f3_NpcSavePos[npc.index][2];

					GetBeamDrawStartPoint_Stock(npc.index, VectorStartEdit,OffsetFromMiddle, AnglesEdit);
					GetBeamDrawStartPoint_Stock(npc.index, VectorStartEdit2,OffsetFromMiddle, AnglesEdit);

					SetColorRGBA(glowColor, red, green, blue, Alpha);
					TE_SetupBeamPoints(VectorStartEdit, VectorStartEdit2, Shared_BEAM_Laser, 0, 0, 0, 0.5, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.0, glowColor, 0);
					TE_SendToAll(0.0);
				}
			}

		}
		else
		{
			npc.m_flSuperSlashInAbilityDo = 0.0;
			npc.m_flSuperSlashInAbility = 0.0;
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			npc.StartPathing();
			npc.m_bisWalking = true;
		}
		return true;
	}
	if(npc.m_flSuperSlash > GetGameTime(npc.index))
		return false;

	npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
	npc.m_iWearable8 = Trail_Attach(npc.index, ARROW_TRAIL, 255, 1.0, 60.0, 3.0, 5);
	SetEntityRenderColor(npc.m_iWearable8, 0, 0, 0, 255);
	npc.m_flSuperSlashInAbility = GetGameTime(npc.index) + 4.0;
	npc.m_flSuperSlashInAbilityDo = 0.0;
	npc.m_flSuperSlash = GetGameTime(npc.index) + 20.0;
	npc.StopPathing();
	npc.m_bisWalking = false;
	return true;
	
}