#pragma semicolon 1
#pragma newdecls required

#define PILLAR_SPACING 170.0
#define SENSAL_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define SENSAL_LASER_THICKNESS 50

static bool BlockLoseSay;


static int i_SaidLineAlready[MAXENTITIES];
static float f_TimeSinceHasBeenHurt[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
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
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
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

static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};
static const char g_SuperJumpSound[][] = {
	"misc/halloween/spell_mirv_explode_primary.wav",
};

static char g_AngerSounds[][] = {
	"vo/taunts/soldier_taunts03.mp3",
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
	"vo/taunts/soldier_taunts15.mp3",
};

static const char g_LaserGlobalAttackSound[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};

static int Silvester_TE_Used;
static float RaidModeScaling;
static bool b_RageAnimated[MAXENTITIES];
static bool b_RageProjectile[MAXENTITIES];

void Sensal_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }
	PrecacheModel("models/player/soldier.mdl");
	PrecacheModel(LASERBEAM);
	PrecacheSound("npc/zombie_poison/pz_alert1.wav");
	PrecacheSound("weapons/mortar/mortar_explode3.wav");
	PrecacheSound("misc/halloween/spell_teleport.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sensal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sensal");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, const float vecPos[3], const float vecAng[3], int team, const char[] data)
{
	return Sensal(vecPos, vecAng, team, data);
}

methodmap Sensal < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_SensalMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_SensalRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_SensalRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_SensalRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
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
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMissSound() 
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_MissAbilitySound[GetRandomInt(0, sizeof(g_MissAbilitySound) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	public void PlayHurtArmorSound() 
	{
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
	}
	
	
	public Sensal(int client, const float vecPos[3], const float vecAng[3], int ally, const char[] data)
	{
		Sensal npc = view_as<Sensal>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossSensal_OnTakeDamagePost);
		
		npc.StartPathing();
		npc.m_flSpeed = 450.0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		BlockLoseSay = false;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		
		i_RaidGrantExtra[npc.index] = 1;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Sensal Arrived");
			}
		}

		RaidModeScaling = 60.0;//float(ZR_GetWaveCount()+1);
		b_RageAnimated[npc.index] = false;
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = 12.0;


		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

	//	Weapon
	//	npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
	//	SetVariantString("1.0");
	//	AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tw2_roman_wreath/tw2_roman_wreath_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/short2014_soldier_fedhair/short2014_soldier_fedhair.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_caws_of_death/hw2013_the_caws_of_death_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SensalEffects(npc.index, view_as<int>(npc.Anger));
		npc.m_flSwitchCooldown = GetGameTime() + GetRandomFloat(30.0, 60.0);

		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({35, 35, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Sensal npc = view_as<Sensal>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
	{
		if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
		{
			Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
		}	
	}
	if(npc.m_flSwitchCooldown < GetGameTime())
	{
		npc.m_flSwitchCooldown = GetGameTime() + GetRandomFloat(30.0, 60.0);
		switch(GetURandomInt() % 7)
		{
			case 0:
			{
				CPrintToChatAll("{blue}Sensal{default}: Your Chaos destroys all there is.");
			}
			case 1:
			{
				CPrintToChatAll("{blue}Sensal{default}: Multidimensional travel is nothing that cant be achived by us.");
			}
			case 2:
			{
				CPrintToChatAll("{blue}Sensal{default}: Are you sure you can handle me?");
			}
			case 3:
			{
				CPrintToChatAll("{blue}Sensal{default}: I am on no ones team.");
			}
			case 4:
			{
				CPrintToChatAll("{blue}Sensal{default}: Your abilties are futile against me, you do not know me.");
			}
			case 5:
			{
				CPrintToChatAll("{blue}Sensal{default}: Your universe is full of chaos.");
			}
			case 6:
			{
				CPrintToChatAll("{blue}Sensal{default}: Raids? What is that, i am worse.");
			}
			case 7:
			{
				CPrintToChatAll("{blue}Sensal{default}: All what you know is nothing before my technology.");
			}
		}
	}
	npc.Update();
	if(SensalTalkPostWin(npc))
		return;
/*
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{blue}Sensal{default}: You are the last one.");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Sensal{default}: None of you criminals are of any importants infront of {gold}Expidonsa{default}.");
				}
				case 3:
				{
					CPrintToChatAll("{blue}Sensal{default}: All your friends are gone. Submit to {gold}Expidonsa{default}.");
				}
			}
		}
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		SDKUnhook(npc.index, SDKHook_Think, Sensal_ClotThink);
		
		CPrintToChatAll("{blue}Sensal{default}: Refusing to collaborate or even reason with {gold}Expidonsa{default} will result in termination.");
		return;
	}
	if(RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, Sensal_ClotThink);
		CPrintToChatAll("{blue}Sensal{default}: You are under arrest. The Expidonsan elite forces will take you now.");
		for(int i; i<32; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = NPC_CreateById(EXPIDONSA_DIVERSIONISTICO, -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
			}
		}
		BlockLoseSay = true;
	}*/

	if(SensalTransformation(npc))
		return;

	if(SensalMassLaserAttack(npc))
		return;

	if(SensalSummonPortal(npc))
		return;

	if (npc.IsOnGround())
	{
		if(GetGameTime(npc.index) > npc.f_SensalRocketJumpCD_Wearoff)
		{
			npc.b_SensalRocketJump = false;
		}
	}
	
	if(npc.m_bAllowBackWalking)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		if(IsValidEnemy(npc.index, npc.m_iTarget))
			npc.FaceTowards(vecTarget, 150.0);
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}


	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecMe, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = SensalSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
		if(npc.m_flCharge_delay < GetGameTime(npc.index))
		{
			if(npc.IsOnGround())
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

				float SelfPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
				float AllyAng[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
				
				bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, false);
				if(Succeed)
				{
					npc.PlayDeathSound();
					ParticleEffectAt(SelfPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					ParticleEffectAt(vPredictedPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					float SpaceCenter[3]; WorldSpaceCenter(npc.m_iTarget, SpaceCenter);
					npc.FaceTowards(SpaceCenter, 15000.0);
					npc.m_flCharge_delay = GetGameTime(npc.index) + 5.0;
				}
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
		SensalAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Sensal npc = view_as<Sensal>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 1)
	{
		if(((ReturnEntityMaxHealth(npc.index)/40) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			b_angered_twice[npc.index] = true; 
			i_SaidLineAlready[npc.index] = 0; 
			f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;
			//RaidModeTime += 60.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			
			CPrintToChatAll("{blue}Sensal{default}: You will ruin all there is.");

			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}

	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Sensal npc = view_as<Sensal>(entity);
	/*
		Explode on death code here please

	*/
	
	float pos[3];
	WorldSpaceCenter(npc.index, pos);
	ParticleEffectAt(pos, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

		
	
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
			CPrintToChatAll("{blue}Sensal{default}: Your actions against a fellow {gold}Expidonsan{default} will not be forgiven, I will be back with reinforcements.");
		}
		case 1:
		{
			CPrintToChatAll("{blue}Sensal{default}: Your time will come when you pay for going against the law of {gold}Expidonsa{default}.");
		}
		case 2:
		{
			CPrintToChatAll("{blue}Sensal{default}: {gold}Expidonsa{default} is far out of your level of understanding.");
		}
		case 3:
		{
			CPrintToChatAll("{blue}Sensal{default}: You do not know what you are getting yourself into.");
		}
	}

}
/*


*/
void SensalAnimationChange(Sensal npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
		SensalEffects(npc.index, view_as<int>(npc.Anger));
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetSensalWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
				//	ResetSensalWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
				//	ResetSensalWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
				//	ResetSensalWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

int SensalSelfDefense(Sensal npc, float gameTime, int target, float distance)
{
	npc.i_GunMode = 0;
	if(npc.m_flAngerDelay < GetGameTime(npc.index))
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			//i can see my enemy, but we want to make sure if there is even space free above us.
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

			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}
			npc.AddActivityViaSequence("taunt05");
			npc.m_flAttackHappens = 0.0;
			EmitSoundToAll("mvm/mvm_tank_end.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
			npc.SetCycle(0.01);
			npc.SetPlaybackRate(2.0);
			npc.StopPathing();
			npc.m_bPathing = false;

			SensalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flAngerDelay = gameTime + 15.0;

			npc.m_flReloadIn = gameTime + 1.5;
		}
		else
		{
			npc.m_flAngerDelay = gameTime + 1.0;
		}
	}

	if(npc.m_flNextRangedSpecialAttackHappens < GetGameTime(npc.index))
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
			npc.PlaySytheInitSound();
			SensalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 7.5;

			npc.m_flNextRangedSpecialAttackHappens = gameTime + 5.5;
		}
	}
	else if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			SensalThrowScythes(npc);
			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}
			npc.m_flRangedSpecialDelay = gameTime + 15.5;
			npc.m_flAttackHappens_2 = gameTime + 1.4;
			npc.StopPathing();
			npc.m_bPathing = false;
			npc.m_flDoingAnimation = gameTime + 99.0;
			npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
			npc.m_flAttackHappens = 0.0;
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
			npc.SetCycle(0.01);
			float flPos[3];
			float flAng[3];
			npc.m_iChanged_WalkCycle = 0;
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			if(!npc.Anger)
				npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
			else
				npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "flaregun_trail_red", npc.index, "effect_hand_r", {0.0,0.0,0.0});

			/*
				Fire a shitretlrrsgtrsglsoads of lasers
			*/

		}
	}	
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				float pos[3];
				WorldSpaceCenter(npc.m_iTarget, pos);
				
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				npc.FaceTowards(pos, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
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

							float damage = 24.0;
							damage *= 1.15;

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
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 450.0, true); 
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
	//Melee attack, last prio
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
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


void SensalEffects(int iNpc, int colour = 0, char[] attachment = "effect_hand_r")
{
	if(attachment[0])
	{
		CClotBody npc = view_as<CClotBody>(iNpc);
		if(IsValidEntity(npc.m_iWearable7))
		{
			if(colour)
			{
				SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 1);
			}
			else
			{
				SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 0);
			}
		}
		else
		{
			npc.m_iWearable7 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
			SetVariantString("1.35");
			AcceptEntityInput(npc.m_iWearable7, "SetModelScale");	
			SetVariantInt(1);
			AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	
			if(colour)
			{
				SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 1);
			}
			else
			{
				SetEntityRenderColor(npc.m_iWearable7, 255, 255, 255, 0);
			}
		}
	}
	else
	{
		int ModelApply = ApplyCustomModelToWandProjectile(iNpc, WEAPON_CUSTOM_WEAPONRY_1, 1.65, "scythe_spin");

		if(colour)
		{
			SetEntityRenderColor(ModelApply, 255, 255, 255, 1);
		}
		else
		{
			SetEntityRenderColor(ModelApply, 255, 255, 255, 0);
		}
		SetVariantInt(2);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}
}


public void RaidbossSensal_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Sensal npc = view_as<Sensal>(victim);
	//if(ZR_GetWaveCount()+1 >= 45)
	{
		if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 3.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			//RaidModeTime += 60.0;
			npc.m_bisWalking = false;
			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_electricity_cloud1_WY", 3.0);
		}
	}
}


void SensalThrowScythes(Sensal npc)
{
	Silvester_TE_Used = 0;
	int MaxCount = 1;
	float DelayPillars = 0.5;
	float DelaybewteenPillars = 0.5;
	float ang_Look[3];
	float pos[3];
	WorldSpaceCenter(npc.index, pos);
	
//	if(ZR_GetWaveCount()+1 >= 60)
	MaxCount = 3;

	for(int Repeat; Repeat <= 7; Repeat++)
	{
		Sensal_Scythe_Throw_Ability(npc.index,
		SENSAL_BASE_RANGED_SCYTHE_DAMGAE * RaidModeScaling,				 	//damage
		MaxCount, 	//how many
		DelayPillars,									//Delay untill hit
		DelaybewteenPillars,									//Extra delay between each
		ang_Look 								/*2 dimensional plane*/,
		pos,
		0.25);									//volume
		ang_Look[1] += 45.0;
	}
}

void Sensal_Scythe_Throw_Ability(int entity,
float damage,
int count,
float delay,
float delay_PerPillar,
float direction[3] /*2 dimensional plane*/,
float origin[3],
float volume = 0.7)
{
	float timerdelay = GetGameTime() + delay;
	DataPack pack;
	CreateDataTimer(delay_PerPillar, Sensal_SpawnSycthes, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
	pack.WriteCell(damage);
	pack.WriteCell(0);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(count);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(timerdelay);					//Delay for each initial pillar
	pack.WriteCell(direction[0]);
	pack.WriteCell(direction[1]);
	pack.WriteCell(direction[2]);
	pack.WriteCell(origin[0]);
	pack.WriteCell(origin[1]);
	pack.WriteCell(origin[2]);
	pack.WriteCell(volume);

	float origin_altered[3];
	origin_altered = origin;

	for(int Repeats; Repeats < count; Repeats++)
	{
		float Range = 50.0;
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);

		float vecSwingEnd[3];
		vecSwingEnd[0] = origin_altered[0] + VecForward[0] * (PILLAR_SPACING);
		vecSwingEnd[1] = origin_altered[1] + VecForward[1] * (PILLAR_SPACING);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		hullcheckmaxs = view_as<float>( { 5.0, 5.0, 5.0 } );
		hullcheckmins = view_as<float>( { -5.0, -5.0, -5.0 } );
		
		Handle trace = TR_TraceHullFilterEx(origin_altered, vecSwingEnd, hullcheckmins, hullcheckmaxs, MASK_PLAYERSOLID, Sensal_TraceWallsOnly);

		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(origin_altered, trace);
		}
		else
		{
			origin_altered = vecSwingEnd;
		}
		delete trace;

		Range += (float(Repeats) * 10.0);
		Silvester_TE_Used += 1;
		if(Silvester_TE_Used > 31)
		{
			int DelayFrames = (Silvester_TE_Used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(origin_altered[0]);
			pack_TE.WriteCell(origin_altered[1]);
			pack_TE.WriteCell(origin_altered[2]);
			pack_TE.WriteCell(Range);
			pack_TE.WriteCell(delay + (delay_PerPillar * float(Repeats)));
			RequestFrames(Sensal_DelayTE, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			spawnRing_Vectors(origin_altered, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, delay + (delay_PerPillar * float(Repeats)), 5.0, 0.0, 1);	
		}
		/*
		int laser;
		RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);

		int red = 212;
		int green = 155;
		int blue = 0;

		laser = ConnectWithBeam(npc.m_iWearable6, -1, red, green, blue, 5.0, 5.0, 0.0, LINKBEAM,_, origin_altered);

		CreateTimer(delay, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		*/

	}
}

public void Sensal_DelayTE(DataPack pack)
{
	pack.Reset();
	float Origin[3];
	Origin[0] = pack.ReadCell();
	Origin[1] = pack.ReadCell();
	Origin[2] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Delay = pack.ReadCell();
	spawnRing_Vectors(Origin, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, Delay, 5.0, 0.0, 1);	
		
	delete pack;
}



public Action Sensal_SpawnSycthes(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadCell();
	DataPackPos countPos = pack.Position;
	int count = pack.ReadCell();
	int countMax = pack.ReadCell();
	float delayUntillImpact = pack.ReadCell();
	float direction[3];
	direction[0] = pack.ReadCell();
	direction[1] = pack.ReadCell();
	direction[2] = pack.ReadCell();
	float origin[3];
	DataPackPos originPos = pack.Position;
	origin[0] = pack.ReadCell();
	origin[1] = pack.ReadCell();
	origin[2] = pack.ReadCell();
	float volume = pack.ReadCell();

	//Timers have a 0.1 impresicison logic, accont for it.
	if(delayUntillImpact - 0.1 > GetGameTime())
	{
		return Plugin_Continue;
	}

	count += 1;
	pack.Position = countPos;
	pack.WriteCell(count, false);
	if(IsValidEntity(entity))
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin[0] + VecForward[0] * (PILLAR_SPACING);
		vecSwingEnd[1] = origin[1] + VecForward[1] * (PILLAR_SPACING);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/
		float origin_altered[3];
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];

		hullcheckmaxs = view_as<float>( { 5.0, 5.0, 5.0 } );
		hullcheckmins = view_as<float>( { -5.0, -5.0, -5.0 } );
		
		Handle trace = TR_TraceHullFilterEx(origin, vecSwingEnd, hullcheckmins, hullcheckmaxs, MASK_PLAYERSOLID, Sensal_TraceWallsOnly);

		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(origin_altered, trace);
		}
		else
		{
			origin_altered = vecSwingEnd;
		}
		delete trace;

		Sensal npc = view_as<Sensal>(entity);
		float FloatVector[3];
		
		
		if(IsValidEntity(npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, FloatVector);
		}
		else
		{
			WorldSpaceCenter(entity, FloatVector);
		}

		int Projectile = npc.FireParticleRocket(FloatVector, damage , 600.0 , 100.0 , "",_,_,true,origin_altered,_,_,_,false);
		SensalEffects(Projectile,view_as<int>(npc.Anger),"");
		b_RageProjectile[Projectile] = npc.Anger;
		//dont exist !
		SDKUnhook(Projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
		SDKHook(Projectile, SDKHook_StartTouch, Sensal_Particle_StartTouch);
		CreateTimer(15.0, Timer_RemoveEntitySensal, EntIndexToEntRef(Projectile), TIMER_FLAG_NO_MAPCHANGE);
		static float ang_Look[3];
		GetEntPropVector(Projectile, Prop_Send, "m_angRotation", ang_Look);
		Initiate_HomingProjectile(Projectile,
		 npc.index,
		 	70.0,			// float lockonAngleMax,
		   	9.0,				//float homingaSec,
			false,				// bool LockOnlyOnce,
			true,				// bool changeAngles,
			  ang_Look);// float AnglesInitiate[3]);

		if(volume == 0.25)
		{
			EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, origin_altered);		
		}
		else
		{
			EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, origin_altered);
			EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, origin_altered);
		}

		pack.Position = originPos;
		pack.WriteCell(origin_altered[0], false);
		pack.WriteCell(origin_altered[1], false);
		pack.WriteCell(origin_altered[2], false);
		//override origin, we have a new origin.
	}
	else
	{
		return Plugin_Stop; //cancel.
	}

	if(count >= countMax)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;

}

public Action Timer_RemoveEntitySensal(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity))
	{
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}


public void Sensal_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		if(b_should_explode[entity])	//should we "explode" or do "kinetic" damage
		{
			i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
			Explode_Logic_Custom(fl_rocket_particle_dmg[entity] , inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
		}
		else
		{
			SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
		}
		EmitSoundToAll(g_SyctheHitSound[GetRandomInt(0, sizeof(g_SyctheHitSound) - 1)], entity, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		TE_Particle(b_RageProjectile[entity] ? "spell_batball_impact_red" : "spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		//we uhh, missed?
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		TE_Particle(b_RageProjectile[entity] ? "spell_batball_impact_red" : "spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}


bool SensalTalkPostWin(Sensal npc)
{
	if(!b_angered_twice[npc.index])
		return false;

	if(npc.m_iChanged_WalkCycle != 6)
	{
		if(IsValidEntity(npc.m_iWearable7))
		{
			RemoveEntity(npc.m_iWearable7);
		}
		SensalEffects(npc.index, view_as<int>(npc.Anger));
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 6;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		npc.StopPathing();
	}
	if(GetGameTime() > f_TimeSinceHasBeenHurt[npc.index])
	{
		CPrintToChatAll("{blue}Sensal{default}: I will be back with allies.");
		
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		BlockLoseSay = true;
	}
	else if(GetGameTime() + 5.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 4)
	{
		i_SaidLineAlready[npc.index] = 4;
		CPrintToChatAll("{blue}Sensal{default}: You destroy yourselves and eachother.");
	}
	else if(GetGameTime() + 10.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 3)
	{
		i_SaidLineAlready[npc.index] = 3;
		CPrintToChatAll("{blue}Sensal{default}: As much as he hates me this is gone on too far.");
	}
	else if(GetGameTime() + 13.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 2)
	{
		i_SaidLineAlready[npc.index] = 2;
		CPrintToChatAll("{blue}Sensal{default}: I will make sure to contact {green}Spookmaster Bones{default}.");
	}
	else if(GetGameTime() + 16.5 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 1)
	{
		i_SaidLineAlready[npc.index] = 1;
		CPrintToChatAll("{blue}Sensal{default}: I came here to make sure all is fine, it is not.");
	}
	return true; //He is trying to help.
}

bool SensalTransformation(Sensal npc)
{
	if(npc.Anger)
	{
		if(!b_RageAnimated[npc.index])
		{
			npc.StopPathing();
			npc.m_bPathing = false;
			npc.AddActivityViaSequence("taunt_the_profane_puppeteer");
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.01);
			b_RageAnimated[npc.index] = true;
			b_CannotBeHeadshot[npc.index] = true;
			b_CannotBeBackstabbed[npc.index] = true;
			b_CannotBeStunned[npc.index] = true;
			b_CannotBeKnockedUp[npc.index] = true;
			b_CannotBeSlowed[npc.index] = true;
			npc.m_flAttackHappens_2 = 0.0;	
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
		
			SetVariantInt(3);
			AcceptEntityInput(npc.index, "SetBodyGroup");

			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}				
			}
		}
	}

	if(npc.m_flNextChargeSpecialAttack)
	{
		if(npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index))
		{
			SetVariantInt(2);
			AcceptEntityInput(npc.index, "SetBodyGroup");
			b_CannotBeHeadshot[npc.index] = false;
			b_CannotBeBackstabbed[npc.index] = false;
			b_CannotBeStunned[npc.index] = false;
			b_CannotBeKnockedUp[npc.index] = false;
			b_CannotBeSlowed[npc.index] = false;
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_flSpeed = 500.0;
			npc.m_flNextChargeSpecialAttack = 0.0;
			npc.m_bisWalking = true;
			RaidModeScaling *= 1.15;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
			SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable3, 255, 35, 35, 255);
		//	i_NpcInternalId[npc.index] = XENO_RAIDBOSS_SUPERSILVESTER;
			i_NpcWeight[npc.index] = 4;
			SensalEffects(npc.index, view_as<int>(npc.Anger));
			npc.m_flRangedArmor = 0.7;
			npc.m_flMeleeArmor = 0.875;		

			SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 2));

				
			SetVariantColor(view_as<int>({255, 35, 35, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			npc.PlayAngerSoundPassed();


			npc.m_flNextRangedSpecialAttack = 0.0;			
			npc.m_flNextRangedAttack = 0.0;		
			npc.m_flRangedSpecialDelay = 0.0;	
			//Reset all cooldowns.
		}
		return true;
	}
	return false;
}
bool SensalMassLaserAttack(Sensal npc)
{
	if(npc.m_flAttackHappens_2)
	{
		int enemy_2[MAXENTITIES];
		bool ClientTargeted[MAXENTITIES];
		GetHighDefTargets(npc, enemy_2, sizeof(enemy_2), true, false);
		for(int i; i < sizeof(enemy_2); i++)
		{
			if(enemy_2[i])
			{
				ClientTargeted[enemy_2[i]] = true;
				if(!IsValidEntity(i_LaserEntityIndex[enemy_2[i]]))
				{
					int red = 200;
					int green = 200;
					int blue = 200;
					if(IsValidEntity(i_LaserEntityIndex[enemy_2[i]]))
					{
						RemoveEntity(i_LaserEntityIndex[enemy_2[i]]);
					}

					int laser;
					
					laser = ConnectWithBeam(npc.index, enemy_2[i], red, green, blue, 2.0, 2.0, 1.0, LASERBEAM);
			
					i_LaserEntityIndex[enemy_2[i]] = EntIndexToEntRef(laser);
				}
			}
		}
		for(int client_clear=1; client_clear<MAXENTITIES; client_clear++)
		{
			if(!ClientTargeted[client_clear])
			{
				if(IsValidEntity(i_LaserEntityIndex[client_clear]))
				{
					RemoveEntity(i_LaserEntityIndex[client_clear]);
				}
			}
		}
		if(npc.m_flAttackHappens_2 < GetGameTime(npc.index))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			float flPos[3];
			float flAng[3];
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
			int ParticleEffect;
			
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", flAng);
			flAng[0] = 90.0;
			if(!npc.Anger)
				ParticleEffect = ParticleEffectAt(flPos, "powerup_supernova_explode_blue", 1.0); //This is the root bone basically
			else
				ParticleEffect = ParticleEffectAt(flPos, "powerup_supernova_explode_red", 1.0); //This is the root bone basically
			
			TeleportEntity(ParticleEffect, NULL_VECTOR, flAng, NULL_VECTOR);
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.5;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flAttackHappens_2 = 0.0;	
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}				
			}

			int enemy[128];
			GetHighDefTargets(npc, enemy, sizeof(enemy), true, false);
			bool foundEnemy = false;
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					foundEnemy = true;
					float pos[3];
					WorldSpaceCenter(enemy[i], pos);
					SensalInitiateLaserAttack(npc.index, pos, flPos);
				}
			}
			if(foundEnemy)
			{
				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME);
				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME);
				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME);
			}
			else
			{
				npc.PlayMissSound();
			}
		}
		return true;
	}
	return false;
}

bool SensalSummonPortal(Sensal npc)
{
	if(npc.m_flReloadIn)
	{
		if(npc.m_flReloadIn < GetGameTime(npc.index))
		{
			static float flMyPos[3];
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
			int PortalParticle;
			if(npc.Anger)
			{
				PortalParticle = ParticleEffectAt(flMyPos, "eyeboss_death_vortex", 0.0);
			}
			else
			{
				PortalParticle = ParticleEffectAt(flMyPos, "eyeboss_tp_vortex", 0.0);
			}
			Sensal particle = view_as<Sensal>(PortalParticle);
			particle.Anger = npc.Anger;
			DataPack pack;
			CreateDataTimer(4.5, Sensal_TimerRepeatPortalGate, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(npc.index));
			pack.WriteCell(EntIndexToEntRef(PortalParticle));

			float flPos[3];
			float flAng[3];
			GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flMyPos);	
			
			ParticleEffectAt(flPos, "hammer_bell_ring_shockwave", 1.0); //This is the root bone basically

			npc.m_flReloadIn = 0.0;
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.5;
			npc.m_iChanged_WalkCycle = 0;
		}
		return true;
	}
	return false;
}
public Action Sensal_TimerRepeatPortalGate(Handle timer, DataPack pack)
{
	pack.Reset();
	int Originator = EntRefToEntIndex(pack.ReadCell());
	int Particle = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(Originator) && IsValidEntity(Particle))
	{
		if(b_angered_twice[Originator])
		{
			if(IsValidEntity(Particle))
			{
				RemoveEntity(Particle);
			}
			return Plugin_Stop;
		}

		Sensal npc = view_as<Sensal>(Originator);
		static float flMyPos[3];
		GetEntPropVector(Particle, Prop_Data, "m_vecOrigin", flMyPos);
		int enemy[MAXENTITIES];
		GetHighDefTargets(npc, enemy, sizeof(enemy), true, false, Particle, (1800.0 * 1800.0));
		bool Foundenemies = false;

		for(int i; i < sizeof(enemy); i++)
		{
			if(enemy[i])
			{
				Foundenemies = true;
				float pos[3];
				WorldSpaceCenter(enemy[i], pos);
				int Projectile = npc.FireParticleRocket(pos, SENSAL_BASE_RANGED_SCYTHE_DAMGAE * RaidModeScaling , 600.0 , 100.0 , "",_,_,true, flMyPos,_,_,_,false);
				SensalEffects(Projectile,view_as<int>(npc.Anger),"");
				b_RageProjectile[Projectile] = npc.Anger;

				//dont exist !
				SDKUnhook(Projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
				SDKHook(Projectile, SDKHook_StartTouch, Sensal_Particle_StartTouch);
				
				CreateTimer(15.0, Timer_RemoveEntitySensal, EntIndexToEntRef(Projectile), TIMER_FLAG_NO_MAPCHANGE);
				static float ang_Look[3];
				GetEntPropVector(Projectile, Prop_Send, "m_angRotation", ang_Look);
				Initiate_HomingProjectile(Projectile,
				npc.index,
					70.0,			// float lockonAngleMax,
					9.0,				//float homingaSec,
					false,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					ang_Look,			
					enemy[i]); //home onto this enemy
			}
		}

		if(Foundenemies)
			EmitSoundToAll("misc/halloween/spell_teleport.wav", npc.index, SNDCHAN_STATIC, 90, _, 0.8);
			
		Sensal particle = view_as<Sensal>(Particle);
		if(npc.Anger && !particle.Anger)
		{
			//update particle
			int PortalParticle = ParticleEffectAt(flMyPos, "eyeboss_death_vortex", 0.0);
			DataPack pack2;
			particle.Anger = npc.Anger;
			CreateDataTimer(8.5, Sensal_TimerRepeatPortalGate, pack2, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(EntIndexToEntRef(Originator));
			pack2.WriteCell(EntIndexToEntRef(PortalParticle));
			if(IsValidEntity(Particle))
			{
				RemoveEntity(Particle);
			}
			return Plugin_Stop;
		}
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




int SensalHitDetected[MAXENTITIES];

void SensalInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Sensal_TraceWallsOnly);
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

	Sensal npc = view_as<Sensal>(entity);
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
	float diameter = float(SENSAL_LASER_THICKNESS * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(SensalInitiateLaserAttack_DamagePart, 50, pack);
}

void SensalInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		SensalHitDetected[i] = false;
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

	Sensal npc = view_as<Sensal>(entity);
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
	float diameter = float(SENSAL_LASER_THICKNESS * 4);
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
	hullMin[0] = -float(SENSAL_LASER_THICKNESS);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 70.0 * RaidModeScaling;
	float FarDamage = 60.0 * RaidModeScaling;
	float MaxDistance = 5000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (SensalHitDetected[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;

			
			if(victim > MaxClients) //make sure barracks units arent bad, they now get targetted too.
				damage *= 0.25;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


public bool Sensal_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		SensalHitDetected[entity] = true;
	}
	return false;
}

public bool Sensal_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


float[] GetBehindTarget(int target, float Distance, float origin[3])
{
	float VecForward[3];
	float vecRight[3];
	float vecUp[3];
	
	GetVectors(target, VecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(
	
	float vecSwingEnd[3];
	vecSwingEnd[0] = origin[0] - VecForward[0] * (Distance);
	vecSwingEnd[1] = origin[1] - VecForward[1] * (Distance);
	vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

	return vecSwingEnd;
}