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

static const char g_SlicerHitSound[][] = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer3.wav",
	"ambient/machines/slicer4.wav",
};


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
	for (int i = 0; i < (sizeof(g_SlicerHitSound)); i++) { PrecacheSound(g_SlicerHitSound[i]); }
	PrecacheSound("weapons/cow_mangler_explosion_normal_04.wav");
	PrecacheSound("weapons/cow_mangler_explosion_normal_05.wav");
	PrecacheSound("weapons/cow_mangler_explosion_normal_06.wav");
	PrecacheSoundCustom("#zombiesurvival/construct/bat_prtsstage1.mp3");
	
	if(Construction_Mode())
		PrecacheModel("models/zombie_riot/special_boss/zilius_1.mdl");

	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_start.wav");
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Construction_Raid_Zilius(vecPos, vecAng, team, data);
}
#define ZILIUS_BUFF_RANGE 500.0

static int TalkAtWhatAm = 0;
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
	public void PlaySlicerSound()
	{
		EmitSoundToAll(g_SlicerHitSound[GetRandomInt(0, sizeof(g_SlicerHitSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 130);
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
	property float m_flFrontSlicerCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flFrontSlicerInit
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flSpawnPortal
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flLandAnimationdo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flWinAnimation
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flWinAnimationSay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}
	property int m_iPortalsStateSummoned
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property int m_iDontMultiAbility
	{
		public get()		{	return this.m_iMedkitAnnoyance;	}
		public set(int value) 	{	this.m_iMedkitAnnoyance = value;	}
	}
	public void SayStuffZilius()
	{
		//one in 3 chance.
		if(GetRandomInt(1,3) != 3)
			return;

		switch(GetRandomInt(1,10))
		{
			case 1:
			{
				CPrintToChatAll("{black}Zilius{default}: Chaos? There's stuff about it that only i and {black}''Bob the second''{default}, oh sorry, i mean {black}''Izan''{default} know about.");
			}
			case 2:
			{
				CPrintToChatAll("{black}Zilius{default}: Ever think about what endless violence causes? Look at yourselves.");
			}
			case 3:
			{
				CPrintToChatAll("{black}Zilius{default}: Our planet, ruined, you all are useless to help against the {violet}curtain{default} or the {violet}void{default}.");
			}
			case 4:
			{
				CPrintToChatAll("{black}Zilius{default}: Expidonsa wasnt just an underground city, it was the very planet you live on, Parasites.");
			}
			case 5:
			{
				CPrintToChatAll("{black}Zilius{default}: If only the other higherups and {black}''Izan''{default} agreed to not save those others.");
			}
			case 6:
			{
				CPrintToChatAll("{black}Zilius{default}: Whatever you think expidonsa doesnt have, it does.");
			}
			case 7:
			{
				CPrintToChatAll("{black}Zilius{default}: {blue}Sensal{default}, {gold}Silvester{default}, all those other expidonsans in that region are so clueless to whomever made chaos.");
			}
			case 8:
			{
				CPrintToChatAll("{black}Zilius{default}: Iberians are the only ones i respect, Mazeat is an amalgam of failures.");
			}
			case 9:
			{
				CPrintToChatAll("{black}Zilius{default}: Kahmlstein is such a wasted person, sadly he wasnt apart of the {gold}Prime race{default}.");
			}
			case 10:
			{
				CPrintToChatAll("{black}Zilius{default}: If you think very logically, Extermination for all of you is the only endgoal to end {violet}Them{default}.");
			}
		}
	}
	public Construction_Raid_Zilius(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Construction_Raid_Zilius npc;
		if(!Construction_Mode())
			npc = view_as<Construction_Raid_Zilius>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally, false, false, false,true)); //giant!
		else
			npc = view_as<Construction_Raid_Zilius>(CClotBody(vecPos, vecAng, "models/zombie_riot/special_boss/zilius_1.mdl", "1.0", "25000", ally, false, false, false,true)); //giant!
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		
		if(Construction_Mode())
		{
			npc.SetActivity("ACT_BOSS_RUN");
		}
		else
		{
			npc.SetActivity("ACT_MP_RUN_MELEE");
		}
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Shared_Xeno_Duo);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		i_TimesSummoned[npc.index] = 0;
		TalkAtWhatAm = 0;

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
				CPrintToChatAll("{black}Zilius{default}: Zilius and the other expidonsans are too nice, we do lack that weakness.");
			}
		}
		RemoveAllDamageAddition();
		bool final = StrContains(data, "final_item") != -1;
		
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		if(final)
		{
			PrintToChatAll("test1");
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 1;
		}
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);		
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 450.0;
		
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
			
		npc.m_flPrepareFlyAtEnemyCD = GetGameTime() + 1.0;
		npc.m_flShieldRegenCD = GetGameTime() + 5.0;
		npc.m_flFrontSlicerCD = GetGameTime() + 15.0;
		npc.m_flSpawnPortal = GetGameTime() + 25.0;
		
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		ApplyStatusEffect(npc.index, npc.index, "Anti-Waves", 99999.0);
		//cannot be healed ever
		
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
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/construct/bat_prtsstage1.mp3");
			music.Time = 148;
			music.Volume = 1.6;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "bat_prtsstage1");
			strcopy(music.Artist, sizeof(music.Artist), "Arknights OST");
			Music_SetRaidMusic(music);
		}
		
		npc.Anger = false;
		//IDLE
		npc.m_flSpeed = 300.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;		
		Citizen_MiniBossSpawn();
		npc.StartPathing();
		
		SensalGiveShield(npc.index,CountPlayersOnRed(1) * 50);
		RequestFrame(Zilius_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		npc.m_flNextDelayTime = GetGameTime() + 0.2;
		ZiliusApplyEffects(npc.index);
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(iNPC);
	if(npc.m_flWinAnimation)
	{
		if(npc.m_flWinAnimationSay < GetGameTime())
		{
			npc.m_flWinAnimationSay = GetGameTime() + 4.0;
			switch(TalkAtWhatAm)
			{
				case 0:
				{
					CPrintToChatAll("{black}Zilius{default}: {black}''Bob the second''{default} is still such an ass, but whatever.");
				}
				case 1:
				{
					CPrintToChatAll("{black}Zilius{default}: We both suffered losses, so take it as a truce now.");
				}
				case 2:
				{
					CPrintToChatAll("{black}Zilius{default}: You proved to me that other races have the chance to not be useless... but most are regardless.");
				}
				case 3:
				{
					CPrintToChatAll("{black}Zilius{default}: Whenever the {purple}void or curtain{default} surfaces we'll land a hand, dont you think sensal or whoever are the only ones.");
				} 
				case 4:
				{
					CPrintToChatAll("{snow}Zeina{default}: ... Why did you im-");
					npc.m_flWinAnimationSay = GetGameTime() + 1.0;
				} 
				case 5:
				{
					CPrintToChatAll("{black}Zilius{default}: Because you created a simulation thats just pathetic, Dont mess with reality or even a fake of it.");
					npc.m_flWinAnimationSay = GetGameTime() + 3.0;
				} 
				case 6:
				{
					CPrintToChatAll("{snow}Zeina{default}: ... wasnt even my.. ide-");
					npc.m_flWinAnimationSay = GetGameTime() + 1.0;
				} 
				case 7:
				{
					CPrintToChatAll("{black}Zilius{default}: Whatever, Theres many more expidonsans to convince, you earned our respect, but not our trust yet.");
				} 
				case 8:
				{
					CPrintToChatAll("{black}Zilius{default}: for one, {black}''Bob the second''{default}, stop being so inactive and finally help against the chaos with your fellow expidonsans... {black}''Izan''{default}.");
				} 
				case 9:
				{
					CPrintToChatAll("{black}Izan{default}: ... Nobody can know, theyll have my head on a stick...");
				} 
				case 10:
				{
					CPrintToChatAll("{black}Zilius{default}: Sure, just tell your Mercs to not spill the beans.");
				} 
				case 11:
				{
					CPrintToChatAll("{black}Izan{default}: ... sure... whatever...");
				} 
				default:
				{
					ForcePlayerWin();
					npc.m_flWinAnimationSay = 0.0;
					npc.m_flWinAnimation = 0.0;
				}
			
			}
			TalkAtWhatAm++;
		}
		npc.Update();

		if(npc.m_flWinAnimation < GetGameTime())
		{

			
			return;
		}
		return;
	}
	//Raidmode timer runs out, they lost.
	if(LastMann && !AlreadySaidLastmann)
	{
		if(!npc.m_fbGunout)
		{
			AlreadySaidLastmann = true;
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,0))
			{
				case 0:
				{
					CPrintToChatAll("{black}Zilius{default}: If only we kept your gene modification tech to make you into something greater.");
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

	if(npc.m_flNextThinkTime < GetGameTime(npc.index))
	{
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		Zillius_ApplyBuffInLocation(VecSelfNpcabs, GetTeam(npc.index), npc.index);
		float Range = ZILIUS_BUFF_RANGE;
		spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", 50, 50, 255, 200, 1, /*duration*/ 0.11, 3.0, 5.0, 1);	
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	}

	if(npc.m_flLandAnimationdo)
	{
		if(npc.IsOnGround())
		{
			npc.m_flLandAnimationdo = 0.0;
			if(Construction_Mode())
				npc.AddGesture("ACT_BOSS_LAND", _,_,_, 2.0);
		}	
	}
	if(npc.m_flPrepareFlyAtEnemy)
	{
		static float Size = 75.0;
		spawnRing_Vectors(f3_NpcSavePos[npc.index], Size * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 200, 200, 200, 200, 1, 0.15, 6.0, 6.0, 2);
		
		if(npc.m_flPrepareFlyAtEnemy < GetGameTime(npc.index))
		{
			npc.m_flLandAnimationdo = 1.0;
				
			npc.PlaySuperJumpLaunch();
			npc.m_flPrepareFlyAtEnemy = 0.0;
			PluginBot_Jump(npc.index, f3_NpcSavePos[npc.index], 2500.0, true);
		}
	}

	if(ZiliusRegenShieldDo(npc))
		return;

	if(ZiliusSpawnPortal(npc))
		return;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	bool CancelEarly = false;
	CancelEarly = ZiliusFrontSlicer(npc);

	if(IsEntityAlive(npc.m_iTarget))
	{
	//	int ActionToTake = -1;

		//Predict their pos.
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

	}
	else
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	if(CancelEarly)
		return;
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
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	if(RoundToCeil(damage) >= health && i_RaidGrantExtra[npc.index] == 1)
	{
		CPrintToChatAll("{black}Zilius{default}: Guess you lot are more then worthy. ill let you be, be usefull against the {purple}void{default}.");
		npc.m_flWinAnimation = GetGameTime() + 50.0;
		npc.m_flWinAnimationSay = GetGameTime() + 4.0;
		i_RaidGrantExtra[npc.index] = 1111;
		if(Construction_Mode())
			npc.SetActivity("ACT_BOSS_RUN");
		else
			npc.SetActivity("ACT_MP_STAND_MELEE");
		RaidModeTime += 9999.0;
		npc.m_bisWalking = false;
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
			{
				SetTeam(baseboss_index, TFTeam_Red);
				SetEntityCollisionGroup(baseboss_index, 24);
			}
		}
		Waves_ClearWaves();
		GiveProgressDelay(50.0);
	}
	Internal_Weapon_Lines(npc, attacker);

	return Plugin_Changed;
}



static void Internal_NPCDeath(int entity)
{
	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();
	
	StopSound(entity, SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	ExpidonsaRemoveEffects(entity);
	

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

				if(Construction_Mode())
					npc.AddGesture("ACT_BOSS_JUMP");

				float cooldownDo = 20.0;
				npc.m_flPrepareFlyAtEnemyCD = GetGameTime(npc.index) + cooldownDo;

				npc.m_iChanged_WalkCycle = 0;
				npc.FaceTowards(f3_NpcSavePos[npc.index], 15000.0);
				ApplyStatusEffect(npc.index, npc.index, "Expidonsan War Cry", 5.0);
			}
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
							float damage = 30.0;

							if(ShouldNpcDealBonusDamage(target))
								damage *= 10.0;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);									
							
							// Hit particle
							
							bool Knocked = false;
										
							if(IsValidClient(target) && IsInvuln(target))
							{
								Knocked = true;
								Custom_Knockback(npc.index, target, 900.0, true);
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
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
					
					if(Construction_Mode())
					{
						switch(GetRandomInt(1,2))
						{
							case 1:
								npc.AddGesture("ACT_BOSS_ATTACK_1");
							case 2:
								npc.AddGesture("ACT_BOSS_ATTACK_2");
						}
					}
					else
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.85 ;
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
			
		maxhealth /= 8;

		int spawn_index = NPC_CreateByName("npc_zeina_prisoner", -1, pos, ang, GetTeam(entity));
		if(spawn_index > MaxClients)
		{
			Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(spawn_index);
			npc.m_iTargetAlly = entity;
			NpcStats_CopyStats(entity, spawn_index);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

void ZiliusApplyEffects(int entity)
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
		 switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "Be lucky {blue}Sensal{default} didnt kill you for it.");
		  							case 1: Format(Text_Lines, sizeof(Text_Lines), "Scythes are a farming tool {gold}%N{default}, Not a weapon.", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2, WEAPON_NEARL: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "One of many, huh.");
		 							case 1: Format(Text_Lines, sizeof(Text_Lines), "My blade is a eons ahead.");}
		case WEAPON_KIT_BLITZKRIEG_CORE:  Format(Text_Lines, sizeof(Text_Lines), "Truly upsetting that {crimson} He {default} failed..");
		case WEAPON_BOBS_GUN:
		{
			Format(Text_Lines, sizeof(Text_Lines), "{crimson}You think you have a chance with that against me?");
			fl_Extra_Speed[npc.index] = 3.0;
			fl_Extra_MeleeArmor[npc.index] = 0.01;
			fl_Extra_RangedArmor[npc.index] = 0.01;
			f_AttackSpeedNpcIncrease[npc.index] = 0.25;
		} 
		case WEAPON_ANGELIC_SHOTGUN:  Format(Text_Lines, sizeof(Text_Lines), "{lightblue}she{default} is a disgrace for being with others.");

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{black}Zilius{default}: %s", Text_Lines);
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
	if(npc.m_iDontMultiAbility && npc.m_iDontMultiAbility != 2)
		return false;

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
			ZiliusApplyEffects(npc.index);
			npc.m_flShieldRegenCD = GetGameTime(npc.index) + 30.0;

			if(Construction_Mode())
				npc.SetActivity("ACT_BOSS_RUN");
			else
				npc.SetActivity("ACT_MP_RUN_MELEE");

			npc.m_flSpeed = 330.0;
			npc.StartPathing();
			npc.m_bisWalking = true;
			//big shield
			SensalGiveShield(npc.index,CountPlayersOnRed(1) * 25);
			ApplyStatusEffect(npc.index, npc.index, "Expidonsan Anger", 8.0);
			npc.PlayShieldRegenSound();
			npc.m_iDontMultiAbility = 0;
			npc.m_flDoingAnimation = 0.0;
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
		if(Construction_Mode())
		{
			npc.AddActivityViaSequence("boss_shield");
			npc.SetPlaybackRate(0.5);
		}
		else
		{
			npc.AddActivityViaSequence("taunt_unleashed_rage_medic");
			npc.SetPlaybackRate(0.9);
			npc.SetCycle(0.2);
		}
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flShieldRegenCD = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
		npc.SayStuffZilius();
		npc.m_iDontMultiAbility = 2;
		return true;
	}
	return false;
}


bool ZiliusFrontSlicer(Construction_Raid_Zilius npc)
{
	if(npc.m_iDontMultiAbility && npc.m_iDontMultiAbility != 1)
		return false;
	if(npc.m_flFrontSlicerInit)
	{

		if(npc.m_flFrontSlicerInit < GetGameTime(npc.index))
		{
			float flPos[3]; // original
			float flAng[3]; // original
		
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			npc.GetAttachment("foot_L", flPos, flAng);
			npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "foot_L", {0.0,0.0,0.0});
			npc.GetAttachment("foot_R", flPos, flAng);
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "foot_R", {0.0,0.0,0.0});
			npc.GetAttachment("effect_hand_l", flPos, flAng);
			npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
			
			if(Construction_Mode())
			{
				npc.AddActivityViaSequence("boss_dash");
			}
			else
			{
				npc.SetActivity("ACT_MP_SWIM_MELEE");
				npc.SetPlaybackRate(0.5); //slow "swim"
				npc.SetCycle(0.0);
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
				for(int loopi; loopi < layerCount; loopi++)
				{
					view_as<CClotBody>(npc.index).SetLayerPlaybackRate(loopi, 0.01);
					view_as<CClotBody>(npc.index).SetLayerCycle(loopi, 0.35);
				}
				npc.SetPoseParameter_Easy("body_pitch", -21.2);
				npc.SetPoseParameter_Easy("body_yaw", 11.2);
				npc.SetPoseParameter_Easy("move_x", 1.0);
			}
			npc.m_flSpeed = 600.0;
			npc.StartPathing();
			npc.m_bisWalking = false;
			npc.m_flFrontSlicerInit = 0.0;
			f_NpcAdjustFriction[npc.index] = 0.15;
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 7.0;
			ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
			f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		}
		return true;
	}
	if(!npc.m_flFrontSlicerCD)
	{
		if(!Construction_Mode())
		{
			npc.SetPoseParameter_Easy("move_x", 1.0);
			npc.SetPoseParameter_Easy("move_y", 0.0);
		}
		Zilius_KickLogic(npc.index);
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			if(IsValidEntity(npc.m_iWearable7))
				RemoveEntity(npc.m_iWearable7);
			if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
			if(IsValidEntity(npc.m_iWearable9))
				RemoveEntity(npc.m_iWearable9);

			npc.SetPoseParameter_Easy("body_pitch", 0.0);
			npc.SetPoseParameter_Easy("body_yaw", 0.0);
			npc.SetPoseParameter_Easy("move_x", 0.0);
		
			ZiliusApplyEffects(npc.index);

			npc.m_flFrontSlicerCD = GetGameTime(npc.index) + 30.0;
			npc.RemoveGesture("ACT_MP_GESTURE_VC_FISTPUMP_PRIMARY");
			
			if(Construction_Mode())
				npc.SetActivity("ACT_BOSS_RUN");
			else
				npc.SetActivity("ACT_MP_RUN_MELEE");

			npc.StartPathing();
			npc.m_flSpeed = 330.0;
			npc.m_bisWalking = true;
			f_NpcAdjustFriction[npc.index] = 1.0;
			npc.m_iDontMultiAbility = 0;	
			npc.m_flDoingAnimation = 0.0;
			RemoveSpecificBuff(npc.index, "Intangible");
			f_CheckIfStuckPlayerDelay[npc.index] = 1.0; //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
			b_ThisEntityIgnoredBeingCarried[npc.index] = false; //cant be targeted AND wont do npc collsiions

		}
		return true;
	}
	if(npc.m_flFrontSlicerCD < GetGameTime(npc.index))
	{
			
		npc.m_flFrontSlicerCD = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 3.0;
		npc.m_flFrontSlicerInit = GetGameTime(npc.index) + 2.0;

		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_r", {0.0,0.0,0.0});

		npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_PRIMARY");
		int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
		for(int loopi; loopi < layerCount; loopi++)
		{
			view_as<CClotBody>(npc.index).SetLayerPlaybackRate(loopi, 0.5);
			view_as<CClotBody>(npc.index).SetLayerCycle(loopi, 0.45);
		}
		npc.PlayShieldRegenSoundInit();
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("layer_taunt_the_fist_bump");
		npc.SetPlaybackRate(0.3);
		npc.SetCycle(0.1);
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
		npc.SayStuffZilius();
		npc.m_iDontMultiAbility = 1;
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0, 110);
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", _, _, _, _, 1.0, 110);
		return true;
	}
	return false;
}


static void Zilius_KickTouched(int entity, int enemy)
{
	if(!IsValidEnemy(entity, enemy, true, true))
		return;

	if(IsIn_HitDetectionCooldown(entity ,enemy, 5))
		return;

	Set_HitDetectionCooldown(entity,enemy, GetGameTime() + 0.15, 5);

	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	
	float targPos[3];
	WorldSpaceCenter(enemy, targPos);
	float damagedeal = 50.0;
	if(ShouldNpcDealBonusDamage(enemy))
		damagedeal *= 10.0;

	damagedeal *= RaidModeScaling;
	SDKHooks_TakeDamage(enemy, entity, entity, damagedeal, DMG_CLUB, -1, NULL_VECTOR, targPos);
	npc.PlaySlicerSound();

	ApplyStatusEffect(enemy, enemy, "Anti-Waves", 3.0);
	Custom_Knockback(enemy, enemy, 500.0, true, false);
}

void Zilius_KickLogic(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	static float vel[3];
	static float flMyPos[3];
	npc.GetVelocity(vel);
	fClamp(vel[0], -300.0, 300.0);
	fClamp(vel[1], -300.0, 300.0);
	fClamp(vel[2], -300.0, 300.0);
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
	static float hullcheckmins[3];
	static float hullcheckmaxs[3];
	if(b_IsGiant[iNPC])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	
	static float flPosEnd[3];
	flPosEnd = flMyPos;
	ScaleVector(vel, 0.1);
	AddVectors(flMyPos, vel, flPosEnd);
	
	ResetTouchedentityResolve();
	ResolvePlayerCollisions_Npc_Internal(flMyPos, flPosEnd, hullcheckmins, hullcheckmaxs, iNPC);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!TouchedNpcResolve(entity_traced))
			break;

	//	if(i_IsABuilding[ConvertTouchedResolve(entity_traced)])
	//		continue;
		
		Zilius_KickTouched(iNPC,ConvertTouchedResolve(entity_traced));
	}
	ResetTouchedentityResolve();
}

void Zillius_ApplyBuffInLocation(float BannerPos[3], int Team, int iMe = 0)
{
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
		{
			GetClientAbsOrigin(ally, targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (ZILIUS_BUFF_RANGE * ZILIUS_BUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Zilius Prime Technology", 1.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally)
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			if (GetVectorDistance(BannerPos, targPos, true) <= (ZILIUS_BUFF_RANGE * ZILIUS_BUFF_RANGE))
			{
				ApplyStatusEffect(ally, ally, "Zilius Prime Technology", 1.0);
			}
		}
	}
}


bool ZiliusSpawnPortal(Construction_Raid_Zilius npc)
{
	if(npc.m_iDontMultiAbility && npc.m_iDontMultiAbility != 3)
		return false;
	if(!npc.m_flSpawnPortal)
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
			ZiliusApplyEffects(npc.index);
			npc.m_flSpawnPortal = GetGameTime(npc.index) + 60.0;
			
			if(Construction_Mode())
				npc.SetActivity("ACT_BOSS_RUN");
			else
				npc.SetActivity("ACT_MP_RUN_MELEE");
			npc.m_flSpeed = 330.0;
			npc.StartPathing();
			npc.m_bisWalking = true;

			
			static float flMyPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];

			//Defaults:
			//hullcheckmaxs = view_as<float>( { 24.0, 24.0, 72.0 } );
			//hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );

			hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
			hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );
			
			if(!IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, npc.index))
			{
				npc.m_flDead_Ringer_Invis_bool = true;
			}
			else
			{
				npc.m_flDead_Ringer_Invis_bool = false;
			}

			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);

			if(npc.m_flDead_Ringer_Invis_bool)
			{
				flMyPos[2] += 400.0;
			}
			else
			{
				flMyPos[2] += 120.0; //spawn at headhight instead.
			}
			
			//every 5 seconds, summon blades onto all enemeis in view
			int PortalParticle = ParticleEffectAt(flMyPos, "eyeboss_tp_vortex", 0.0);
			npc.m_iPortalsStateSummoned++;
			DataPack pack;
			CreateDataTimer(8.5, Zilius_TimerRepeatPortalGate, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(npc.index));
			pack.WriteCell(EntIndexToEntRef(PortalParticle));
			pack.WriteCell(npc.m_iPortalsStateSummoned);

			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flMyPos);	
			
			ParticleEffectAt(flPos, "hammer_bell_ring_shockwave", 1.0); //This is the root bone basically
			npc.m_iDontMultiAbility = 0;
			npc.m_flDoingAnimation = 0.0;

		}
		return true;
	}
	if(npc.m_flSpawnPortal < GetGameTime(npc.index))
	{
			
		float flPos[3]; // original
		float flAng[3]; // original
	
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});

		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("layer_taunt_02");
		npc.SetPlaybackRate(0.01);
		npc.SetCycle(0.2);
		npc.StopPathing();
		npc.m_flSpeed = 0.0;
		npc.m_flSpawnPortal = 0.0;
		npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
		npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
		int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
		for(int loopi; loopi < layerCount; loopi++)
		{
			view_as<CClotBody>(npc.index).SetLayerPlaybackRate(loopi, 0.5);
			view_as<CClotBody>(npc.index).SetLayerCycle(loopi, 0.1);
		}
		npc.m_iDontMultiAbility = 3;
		npc.SayStuffZilius();
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0, 90);
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0, 90);
		return true;
	}
	return false;
}

#define Zilius_LASER_THICKNESS 25

public Action Zilius_TimerRepeatPortalGate(Handle timer, DataPack pack)
{
	pack.Reset();
	int Originator = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	int Currentat = pack.ReadCell();
	if(IsValidEntity(Originator) && IsValidEntity(Particle))
	{
		Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(Originator);
		if(npc.m_iPortalsStateSummoned >= Currentat + 3)
		{
			if(IsValidEntity(Particle))
			{
				RemoveEntity(Particle);
			}
			return Plugin_Stop;
		}


		static float flMyPos[3];
		GetEntPropVector(Particle, Prop_Data, "m_vecOrigin", flMyPos);
		UnderTides npcGetInfo = view_as<UnderTides>(Originator);
		int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT];
		GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, Particle, (2800.0 * 2800.0));
		bool Foundenemies = false;

		int totalEnemies = 0;
		for(int i; i < sizeof(enemy); i++)
		{
			if(enemy[i])
			{
				totalEnemies++;
			}
		}
		totalEnemies /= 3;

		if(totalEnemies <= 2)
			totalEnemies = 2;

		for(int i; i < sizeof(enemy); i++)
		{
			if(enemy[i] && totalEnemies > 0)
			{	
				totalEnemies--;
				Foundenemies = true;
				float WorldSpaceVec[3]; WorldSpaceCenter(enemy[i], WorldSpaceVec);
				ZiliusInitiateLaserAttack(npc.index, WorldSpaceVec, flMyPos);
			}
		}

		if(Foundenemies)
			EmitSoundToAll("weapons/bumper_car_speed_boost_start.wav", npc.index, SNDCHAN_STATIC, 120, _, 1.0, 90);

		return Plugin_Continue;
	}
	else
	{
		if(IsValidEntity(Particle))
		{
			RemoveEntity(Particle);
		}
		return Plugin_Stop;
	}
}


void ZiliusInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Zilius_TraceWallsOnly);
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

	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	int red = 255;
	int green = 255;
	int blue = 255;
	int Alpha = 255;

	if(npc.Anger)
	{
		red = 255;
		green = 255;
		blue = 255;
	}

	int colorLayer4[4];
	float diameter = float(Zilius_LASER_THICKNESS * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(ZiliusInitiateLaserAttack_DamagePart, 50, pack);
}

void ZiliusInitiateLaserAttack_DamagePart(DataPack pack)
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

	Construction_Raid_Zilius npc = view_as<Construction_Raid_Zilius>(entity);
	int red = 50;
	int green = 50;
	int blue = 255;
	int Alpha = 222;
	if(npc.Anger)
	{
		red = 255;
		green = 50;
		blue = 50;
	}
	int colorLayer4[4];
	float diameter = float(Zilius_LASER_THICKNESS * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(Zilius_LASER_THICKNESS);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Zilius_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			

	switch(GetRandomInt(1,3))
	{
		case 1:
			EmitSoundToAll("weapons/cow_mangler_explosion_normal_04.wav", 0, SNDCHAN_STATIC, 120, _, 1.0, 110,_,VectorStart);
		case 2:
			EmitSoundToAll("weapons/cow_mangler_explosion_normal_05.wav", 0, SNDCHAN_STATIC, 120, _, 1.0, 110,_,VectorStart);
		case 3:
			EmitSoundToAll("weapons/cow_mangler_explosion_normal_06.wav", 0, SNDCHAN_STATIC, 120, _, 1.0, 110,_,VectorStart);
	}

	float CloseDamage = 100.0 * RaidModeScaling;
	float FarDamage = 70.0 * RaidModeScaling;
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

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


public bool Zilius_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}

public bool Zilius_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
