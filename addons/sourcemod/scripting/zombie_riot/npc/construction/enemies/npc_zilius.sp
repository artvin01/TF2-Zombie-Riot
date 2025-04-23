#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_smash.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/knife_swing.wav",
};

static char g_RangedAttackSounds[][] = {
	"npc/combine_gunship/gunship_ping_search.wav",
};
static char g_TeleportSounds[][] = {
	"mvm/mvm_tank_end.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_item_secop_domination01.mp3",
};

static char g_AngerSoundsPassed[][] = {
	")vo/medic_laughlong01.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};
static const char g_SuperJumpSound[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};
static const char g_SuperJumpSoundLaunch[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};
static const char g_PlayRegenShield[][] = {
	"mvm/mvm_tele_activate.wav",
};

static const char g_PlayRegenShieldInit[][] = {
	"weapons/cow_mangler_over_charge_shot.wav",
};

#define LINKBEAM "sprites/glow01.vmt"
#define PILLAR_MODEL "models/props_wasteland/rockcliff06d.mdl"
#define PILLAR_SPACING 170.0


public void Construction_Raid_Zilius_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Zilius");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zilius");
	strcopy(data.Icon, sizeof(data.Icon), "zilius");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = Zilius_TBB_Precahce;
	NPC_Add(data);
}



void Zilius_TBB_Precahce()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSoundLaunch)); i++) { PrecacheSound(g_SuperJumpSoundLaunch[i]); }
	for (int i = 0; i < (sizeof(g_PlayRegenShield)); i++) { PrecacheSound(g_PlayRegenShield[i]); }
	for (int i = 0; i < (sizeof(g_PlayRegenShieldInit)); i++) { PrecacheSound(g_PlayRegenShieldInit[i]); }
	
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Construction_Raid_Zilius(vecPos, vecAng, team, data);
}

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

methodmap Construction_Raid_Zilius < CClotBody
{

	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
	
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayAngerSoundPassed() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_STATIC, 80, _, 0.8);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound[GetRandomInt(0, sizeof(g_SuperJumpSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySuperJumpLaunch()
	{
		EmitSoundToAll(g_SuperJumpSoundLaunch[GetRandomInt(0, sizeof(g_SuperJumpSoundLaunch) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShieldRegenSoundInit()
	{
		EmitSoundToAll(g_PlayRegenShieldInit[GetRandomInt(0, sizeof(g_PlayRegenShieldInit) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 130);
	}
	public void PlayShieldRegenSound()
	{
		EmitSoundToAll(g_PlayRegenShield[GetRandomInt(0, sizeof(g_PlayRegenShield) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flPrepareFlyAtEnemyCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flPrepareFlyAtEnemy
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flShieldRegenCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	public Construction_Raid_Zilius(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally, false, false, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Shared_Xeno_Duo);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		i_TimesSummoned[npc.index] = 0;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Zilius Arrived Arrived.");
			}
		}
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				CPrintToChatAll("{black}Zilius{default}: No other races even help us, we will wipe you out ourselves.");
			}
			case 2:
			{
				CPrintToChatAll("{black}Zilius{default}: Extreme intelligence comes from foresight, dont you think?");
			}
			case 3:
			{
				CPrintToChatAll("{black}Zilius{default}: Sensal and the other expidonsans are too nice, we do lack that weakness.");
			}
		}
		RemoveAllDamageAddition();
		bool final = StrContains(data, "final_item") != -1;
		
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		i_RaidGrantExtra[npc.index] = 1;
		if(final)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 6;
		}
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
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
			RaidModeScaling = float(Waves_GetRound()+1);
		}

		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}

		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
		npc.m_flPrepareFlyAtEnemyCD = GetGameTime() + 1.0;
		npc.m_flShieldRegenCD = GetGameTime() + 5.0;

		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
	
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Construction_Raid_Zilius_OnTakeDamagePost);
		b_angered_twice[npc.index] = false;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		/*
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		*/
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_physician_mask/robo_medic_physician_mask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tw2_roman_wreath/tw2_roman_wreath_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/spr18_scourge_of_the_sky/spr18_scourge_of_the_sky.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/hwn2022_victorian_villainy_style3/hwn2022_victorian_villainy_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		
		npc.m_iWearable6 = npc.EquipItem("head", WINGS_MODELS_1);
		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");	
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 7);


		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({0, 0, 0, 150}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		bool ingoremusic = StrContains(data, "triple_enemies") != -1;
		
		if(!ingoremusic)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/Zilius_raid/Zilius_waldch_duo.mp3");
			music.Time = 260;
			music.Volume = 1.6;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "The Duo that Warns in inconspicuous Ways");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);
		}
		else
		{
			RaidModeTime = GetGameTime(npc.index) + 450.0;
		}
		
		npc.Anger = false;
		//IDLE
		npc.m_flSpeed = 330.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;		
		Citizen_MiniBossSpawn();
		npc.StartPathing();



		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		
		RequestFrame(Zilius_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		npc.m_flNextDelayTime = GetGameTime() + 0.2;
		if(XenoExtraLogic())
		{
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					CPrintToChatAll("{gold}Zilius{default}: Is... Is this really where we must change your mind?");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Zilius{default}: Please just turn away!");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Zilius{default}: This is already too close, this is too much risk!");
				}
			}
		}
		ZiliusApplyEffects(npc.index, false);
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(iNPC);
	
	//Raidmode timer runs out, they lost.
	if(LastMann && !AlreadySaidLastmann)
	{
		if(!npc.m_fbGunout)
		{
			AlreadySaidLastmann = true;
			npc.m_fbGunout = true;
			if(!XenoExtraLogic())
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{gold}Zilius{default}: Give up and turn yourself in.");
					}
					case 1:
					{
						CPrintToChatAll("{gold}Zilius{default}: Ready to listen?");
					}
					case 2:
					{
						CPrintToChatAll("{gold}Zilius{default}: Maybe you just hate us?");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{gold}Zilius{default}: Death may be your only choice from here on out!");
					}
					case 1:
					{
						CPrintToChatAll("{gold}Zilius{default}: You're probably already infected, should kill you instead!");
					}
					case 2:
					{
						CPrintToChatAll("{gold}Zilius{default}: Listening is too hard for you ******* isnt it?");
					}
				}				
			}
		}
	}
	if(RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (10 * 2);
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	//Think throttling
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(ZiliusRegenShieldDo(npc))
		return;


	if(IsEntityAlive(npc.m_iTargetWalkTo))
	{
	//	int ActionToTake = -1;

		//Predict their pos.
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
		}

	}
	else
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	//This is for self defense, incase an enemy is too close, This exists beacuse
	//Zilius's main walking target might not be the closest target he has.
	if(npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		Construction_Raid_ZiliusSelfDefense(npc,GetGameTime(npc.index)); 
	}
}

	
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	Internal_Weapon_Lines(npc, attacker);

	return Plugin_Changed;
}


public void Construction_Raid_Zilius_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(victim);
	if(i_RaidGrantExtra[npc.index] >= 4)
	{
		if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			ZiliusApplyEffects(npc.index, true);
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 6.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			RaidModeTime += 60.0;
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					CPrintToChatAll("{gold}Zilius{default}: You're blind to your own arrogance!");
				}
				case 2:
				{
					CPrintToChatAll("{gold}Zilius{default}: You think im weak alone?!");
				}
				case 3:
				{
					CPrintToChatAll("{gold}Zilius{default}: You refuse to listen and thus, pay the price!");
				}
			}
			
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_electricity_cloud1_WY", 5.5);
		}
	}
}

static void Internal_NPCDeath(int entity)
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Construction_Raid_Zilius_OnTakeDamagePost);
	StopSound(entity, SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	ExpidonsaRemoveEffects(entity);
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.

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
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidClient(EnemyLoop))
		{
			ResetDamageHud(EnemyLoop);//show nothing so the damage hud goes away so the other raid can take priority faster.
		}				
	}
	Citizen_MiniBossDeath(entity);
}

void Construction_Raid_ZiliusSelfDefense(Construction_Raid_Zilius npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(IsValidEntity(npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.
		if(npc.m_flPrepareFlyAtEnemyCD < GetGameTime(npc.index) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 13.0))
		{	
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				//steal alaxios jump :D
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				static float flPosEnemy[3]; 
				GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", flPosEnemy);
				flDistanceToTarget = GetVectorDistance(flPos, flPosEnemy);
				float SpeedToPredict = flDistanceToTarget * 1.0;
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, SpeedToPredict, _,f3_NpcSavePos[npc.index]);
				flPos[2] += 5.0;
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				npc.PlaySuperJumpSound();
				flPos[2] += 400.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 1.0);	
				npc.m_flPrepareFlyAtEnemy = GetGameTime(npc.index) + 0.6;

				float cooldownDo = 20.0;
				npc.m_flPrepareFlyAtEnemyCD = GetGameTime(npc.index) + cooldownDo;

				npc.m_iChanged_WalkCycle = 0;
				npc.FaceTowards(f3_NpcSavePos[npc.index], 15000.0);
			}
		}

	}
	if(npc.m_flPrepareFlyAtEnemy)
	{
		static float Size = 75.0;
		spawnRing_Vectors(f3_NpcSavePos[npc.index], Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 100, 200, 1, 0.15, 6.0, 6.0, 2);
		
		if(npc.m_flPrepareFlyAtEnemy < GetGameTime(npc.index))
		{
			npc.PlaySuperJumpLaunch();
			npc.m_flPrepareFlyAtEnemy = 0.0;
			PluginBot_Jump(npc.index, f3_NpcSavePos[npc.index], 2500.0, true);
		}
	}
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,_,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
							float damage = 24.0;
							float damage_rage = 28.0;

							if(!npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);
									
							if(npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);									
								
							
							// Hit particle
							
							bool Knocked = false;
										
							if(IsValidClient(target))
							{
								if (IsInvuln(target))
								{
									Knocked = true;
									Custom_Knockback(npc.index, target, 900.0, true);
									TF2_AddCondition(target, TFCond_LostFooting, 0.5);
									TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
								}
								else
								{
									TF2_AddCondition(target, TFCond_LostFooting, 0.5);
									TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, target, 450.0, true); 
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

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.85 	;
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

void Zilius_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
			
		maxhealth -= (maxhealth / 4);

	//	int spawn_index = NPC_CreateByName("npc_infected_goggles", -1, pos, ang, GetTeam(entity));
	//	if(spawn_index > MaxClients)
	//	{
	//		//Spawn Zeina
	//	}
	}
}

void ZiliusApplyEffects(int entity, bool withoutweapon = false)
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	if(!npc.Anger)
	{
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);

		ExpidonsaRemoveEffects(entity);
		
		ZiliusEarsApply(npc.index);
		ZiliusApplyEffectsForm1(npc.index);	
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		ExpidonsaRemoveEffects(entity);
		ZiliusEarsApply(npc.index);
		ZiliusApplyEffectsForm1(npc.index);	
	}
}

void ZiliusApplyEffectsForm1(int entity)
{
	if(AtEdictLimit(EDICT_RAID))
		return;
	
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 7);
	SetVariantInt(8192);
	AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");	

}

static void Internal_Weapon_Lines(Construction_Raid_Zilius npc, int client)
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
		CPrintToChatAll("{gold}Zilius{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}



void ZiliusEarsApply(int iNpc, char[] attachment = "head")
{
	
	int red = 255;
	int green = 255;
	int blue = 255;
	float flPos[3];
	float flAng[3];
	int particle_ears1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	//fist ear
	int particle_ears2 = InfoTargetParentAt({0.0,-1.85,0.0}, "", 0.0); //First offset we go by
	int particle_ears3 = InfoTargetParentAt({0.0,-4.44,-3.7}, "", 0.0); //First offset we go by
	int particle_ears4 = InfoTargetParentAt({0.0,-5.9,2.2}, "", 0.0); //First offset we go by
	
	//fist ear
	int particle_ears2_r = InfoTargetParentAt({0.0,1.85,0.0}, "", 0.0); //First offset we go by
	int particle_ears3_r = InfoTargetParentAt({0.0,4.44,-3.7}, "", 0.0); //First offset we go by
	int particle_ears4_r = InfoTargetParentAt({0.0,5.9,2.2}, "", 0.0); //First offset we go by

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

bool ZiliusRegenShieldDo(Construction_Raid_Zilius npc)
{
	if(!npc.m_flShieldRegenCD)
	{
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			//We are done
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			float flPos[3]; // original
			float flAng[3]; // original
		
			npc.GetAttachment("effect_hand_l", flPos, flAng);
			spawnRing_Vectors(flPos, /*RANGE start*/ 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 125, 125, 255, 200, 1, /*DURATION*/ 0.5, 6.0, 0.1, 1,  /*RANGE END*/350 * 2.0);
			ZiliusApplyEffects(npc.index, true);
			npc.m_flShieldRegenCD = GetGameTime(npc.index) + 30.0;
			npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.m_flSpeed = 330.0;
			npc.StartPathing();
			npc.m_bisWalking = true;
			//big shield
			SensalGiveShield(npc.index,CountPlayersOnRed(1) * 10);
			npc.PlayShieldRegenSound();
		}
		return true;
	}
	if(npc.m_flShieldRegenCD < GetGameTime(npc.index))
	{
			
		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});

		npc.PlayShieldRegenSoundInit();
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_unleashed_rage_medic");
		npc.SetPlaybackRate(0.9);
		npc.SetCycle(0.2);
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flShieldRegenCD = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
		return true;
	}
	return false;
}