#pragma semicolon 1
#pragma newdecls required


#define Atomizer_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define Atomizer_LASER_THICKNESS 25

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float Delay_Attribute[MAXENTITIES];
static float DrinkRND_Time[MAXENTITIES];
static float NiceMiss[MAXENTITIES];
static bool OnMiss[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
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
	"vo/scout_stunballpickup01.mp3",
	"vo/scout_stunballpickup02.mp3",
	"vo/scout_stunballpickup03.mp3",
	"vo/scout_stunballpickup04.mp3",
	"vo/scout_stunballpickup05.mp3",
};


static char g_AngerSoundsPassed[][] = {
	"vo/taunts/soldier_taunts15.mp3",
};

static const char g_LaserGlobalAttackSound[][] = {
	"weapons/bumper_car_speed_boost_start.wav",
};


void Atomizer_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Atomizer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_atomizer");
	strcopy(data.Icon, sizeof(data.Icon), "sensal_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
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
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_Atomizer_2.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Atomizer(client, vecPos, vecAng, ally, data);
}

methodmap Atomizer < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float f_AtomizerMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_AtomizerRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_AtomizerRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_AtomizerRocketJump
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
	
	
	public Atomizer(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Atomizer npc = view_as<Atomizer>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
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

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		Delay_Attribute[npc.index] = 0.0;
		DrinkRND_Time[npc.index] = 0.0;
		NiceMiss[npc.index] = 0.0;
		I_cant_do_this_all_day[npc.index] = 0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 15.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		npc.m_iOverlordComboAttack = 0;
		OnMiss[npc.index] = false;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Sensal Arrived");
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(ZR_GetWaveCount()+1 > 55)
		{
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.65;
		}
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Atomizer_Win);
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
		music.Time = 218;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Goukisan - Betrayal of Fear (TeslaX VIP remix)");
		strcopy(music.Artist, sizeof(music.Artist), "Talurre/TeslaX11");
		Music_SetRaidMusic(music);
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

	//	Weapon
	//	npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
	//	SetVariantString("1.0");
	//	AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

	//	Weapon
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		CPrintToChatAll("{lightblue}The Messenger{default}: Hello World!");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/scout/pn2_longfall.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_jungle_jersey/fall17_jungle_jersey.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/sum19_bottle_cap/sum19_bottle_cap.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector/hwn2019_fuel_injector.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({100, 150, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Atomizer npc = view_as<Atomizer>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NiceMiss[npc.index] < GetGameTime(npc.index))
	{
		if(IsValidEntity(npc.m_iWearable7))
		{
			RemoveEntity(npc.m_iWearable7);
		}
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
					CPrintToChatAll("{blue}Atomizer{default}: You are the last one.");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Atomizer{default}: None of you criminals are of any importants infront of {gold}Expidonsa{default}.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Atomizer{default}: All your friends are gone. Submit to {gold}Expidonsa{default}.");
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
		
		CPrintToChatAll("{blue}Atomizer{default}: Refusing to collaborate or even reason with {gold}Expidonsa{default} will result in termination.");
		return;
	}
	if(RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		CPrintToChatAll("{blue}Atomizer{default}: You are under arrest. The Expidonsan elite forces will take you now.");
		for(int i; i<32; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = NPC_CreateByName("npc_mortar", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
			}
		}
		BlockLoseSay = true;
	}

	if (npc.IsOnGround())
	{
		if(GetGameTime(npc.index) > npc.f_AtomizerRocketJumpCD_Wearoff)
		{
			npc.b_AtomizerRocketJump = false;
		}
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
		SetGoalVectorIndex = AtomizerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
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
		AtomizerAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Atomizer npc = view_as<Atomizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if(NiceMiss[npc.index] > GetGameTime(npc.index) && GetRandomInt(1,100)<=40)
	{
		damage = 0.0;
		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		if(b_BoundingBoxVariant[victim] == 1)
		{
			chargerPos[2] += 120.0;
		}
		else
		{
			chargerPos[2] += 82.0;
		}
		int particle_power = ParticleEffectAt(chargerPos, "miss_text", 1.5);
		SetParent(victim, particle_power);
		OnMiss[npc.index]=true;
		ExtinguishTarget(npc.m_iWearable1);
		IgniteTargetEffect(npc.m_iWearable1);
		return Plugin_Handled;
	}

	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_Atomizer_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}

static void Internal_NPCDeath(int entity)
{
	Atomizer npc = view_as<Atomizer>(entity);
	/*
		Explode on death code here please

	*/
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

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

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{blue}Atomizer{default}: Ugh, I need backup");
		}
		case 1:
		{
			CPrintToChatAll("{blue}Atomizer{default}: I will never let you trample over the glory of Victoria Again!");
		}
		case 2:
		{
			CPrintToChatAll("{blue}Atomizer{default}: {gold}Expidonsa{default} is far out of your level of understanding.");
		}
		case 3:
		{
			CPrintToChatAll("{blue}Atomizer{default}: You do not know what you are getting yourself into.");
		}
	}

}
/*


*/
void AtomizerAnimationChange(Atomizer npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetAtomizerWeapon(npc, 1);
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
				//	ResetAtomizerWeapon(npc, 1);
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
				//	ResetAtomizerWeapon(npc, 0);
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
				//	ResetAtomizerWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

int AtomizerSelfDefense(Atomizer npc, float gameTime, int target, float distance)
{
	npc.i_GunMode = 0;

	if(npc.m_flNextRangedSpecialAttackHappens < GetGameTime(npc.index))
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
			npc.PlaySytheInitSound();
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 22.5;
			npc.m_iOverlordComboAttack =  RoundToNearest(float(CountPlayersOnRed(2)) * 2.5); 
		}
	}
	else if(npc.m_flRangedSpecialDelay < gameTime)
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			switch(I_cant_do_this_all_day[npc.index])
			{
				case 0:
				{
					if(IsValidEntity(npc.m_iWearable2))
					{
						RemoveEntity(npc.m_iWearable2);
					}
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl");
					
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_bisWalking = false;
					npc.AddActivityViaSequence("layer_taunt04");
					npc.m_flAttackHappens = 0.0;
					npc.m_flAttackHappens_2 = gameTime + 1.4;
					npc.Anger = true;
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
					npc.SetCycle(0.01);
					float flPos[3];
					float flAng[3];
					npc.m_iChanged_WalkCycle = 0;
					npc.GetAttachment("effect_hand_r", flPos, flAng);
					npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "eb_projectile_core01", npc.index, "effect_hand_r", {0.0,0.0,0.0});
					Delay_Attribute[npc.index] = gameTime + 1.0;
					I_cant_do_this_all_day[npc.index]=1;
				}
				case 1:
				{
					if(Delay_Attribute[npc.index] < gameTime)
					{
						/*int GetRND=GetRandomInt(1, 9);
						switch(I_cant_do_this_all_day[npc.index])
						{
							case 1: DrinkRND_Time[npc.index] = gameTime+10.0;
							default: DrinkRND_Time[npc.index] = gameTime+10.0;
						}
						DataPack pack;
						CreateDataTimer(0.1, Atomizer_DrinkRND, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(npc.index);
						pack.WriteCell(GetRND);*/
						if(IsValidEntity(npc.m_iWearable2))
						{
							RemoveEntity(npc.m_iWearable2);
						}
						npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
						SetVariantString("1.2");
						AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
						
						if(!IsValidEntity(npc.m_iWearable7))
						{
							static float flPos[3]; 
							GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
							flPos[2] += 5.0;
							int particle = ParticleEffectAt(flPos, "utaunt_tarotcard_blue_glow");
							SetParent(npc.index, particle);
							npc.m_iWearable7 = particle;
						}

						NiceMiss[npc.index]=gameTime+10.0;
						I_cant_do_this_all_day[npc.index]=2;
					}
				}
				case 2:
				{
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_flRangedSpecialDelay = gameTime + 30.0;
				}
			}
		}
	}	
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			if(npc.m_iOverlordComboAttack > 0)
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
					{
						npc.m_flAttackHappens = 0.0;
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						if(IsValidEnemy(npc.index, Enemy_I_See))
						{
							npc.m_iTarget = Enemy_I_See;
							npc.PlayMeleeSound();
							float RocketDamage = 15.0;
							if(OnMiss[npc.index])
							{
								RocketDamage*=1.5;
								OnMiss[npc.index]=false;
								ExtinguishTarget(npc.m_iWearable1);
							}
							float RocketSpeed = 1100.0;
							float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
							float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
							if(npc.m_iChanged_WalkCycle == 1)
							{
								float SpeedReturn[3];

								int RocketGet = npc.FireRocket(vecTarget, RocketDamage * RaidModeScaling, RocketSpeed, "models/weapons/w_models/w_baseball.mdl");
								SetEntityGravity(RocketGet, 1.0); 	
								ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 2.5, 1.0);
								SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
								TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);

								//This will return vecTarget as the speed we need.
							}
							else
							{
								RocketSpeed *= 0.75;
								npc.FireRocket(vecTarget, RocketDamage * RaidModeScaling, RocketSpeed, "models/weapons/w_models/w_baseball.mdl");
							}
							npc.m_iOverlordComboAttack --;
						}
					}
				}
				//No can shooty.
				//Enemy is close enough.
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					{
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						//stand
						return 1;
					}
					//cant see enemy somewhy.
					return 0;
				}
				else //enemy is too far away.
				{
					return 0;
				}
			}
			else if(npc.m_iOverlordComboAttack < 0)
			{
				npc.m_flAttackHappens = 0.0;
			
				if(IsValidEnemy(npc.index, target))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
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

								float damage = 20.0;
								damage *= 1.15;
								if(OnMiss[npc.index])
								{
									damage*=1.5;
									OnMiss[npc.index]=false;
									ExtinguishTarget(npc.m_iWearable1);
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
	}
	//Melee attack, last prio
	else if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0) && npc.m_iOverlordComboAttack > 0)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
							
					npc.m_flAttackHappens = gameTime + 0.125;
					npc.m_flNextMeleeAttack = gameTime + 0.15;
					npc.m_flDoingAnimation = gameTime + 0.125;
				}
			}
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.5;
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

/*static Action Atomizer_DrinkRND(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int GetRND = pack.ReadCell();
	if(IsValidClient(client))
	{
		switch(GetRND)
		{
			case 1:
			{
				if(f_PDelay[client] < GetGameTime())
				{
					GiveArmorViaPercentage(client, 0.075, 1.0);
					f_PDelay[client]=GetGameTime() + 0.2;
				}
			}
			case 2:
			{
				if(f_PDelay[client] < GetGameTime())
				{
					if(dieingstate[client] > 0)
					{
						if(i_CurrentEquippedPerk[client] == 1)
						{
							SetEntityHealth(client,  GetClientHealth(client) + 12);
							dieingstate[client] -= 20;
						}
						else
						{
							SetEntityHealth(client,  GetClientHealth(client) + 6);
							dieingstate[client] -= 10;
						}
						if(dieingstate[client] < 1)
						{
							dieingstate[client] = 1;
						}
					}
					else
					{
						HealEntityGlobal(client, client, 25.0, 1.0, _, HEAL_SELFHEAL);
					}
					f_PDelay[client]=GetGameTime() + 0.2;
				}
			}
			case 3:
			{
				int health = GetClientHealth(client), selfDMG = 5;
				int safety = health-selfDMG;
				if(health>1)
				{
					if(safety>1)
						SDKHooks_TakeDamage(client, 0, 0, float(selfDMG), DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
					else
						SetEntityHealth(client, 1);
				}
			}
			case 4:
			{
				TF2_RemoveCondition(client, TFCond_ObscuredSmoke);
				TF2_AddCondition(client, TFCond_ObscuredSmoke, 1.0);
				TF2_RemoveCondition(client, TFCond_SpeedBuffAlly);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
				if(f_PDuration[client] < GetGameTime())
				{
					TF2_RemoveCondition(client, TFCond_MarkedForDeath);
					TF2_AddCondition(client, TFCond_MarkedForDeath, 10.0);
					TF2_StunPlayer(client, 10.0, 0.9, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				}
			}
			case 5:
			{
				SetEntityHealth(client, 1);
				return Plugin_Stop;
			}
			case 6:
			{
				TF2_RemoveCondition(client, TFCond_Buffed);
				TF2_AddCondition(client, TFCond_Buffed, 30.0);
				TF2_RemoveCondition(client, TFCond_KingAura);
				TF2_AddCondition(client, TFCond_KingAura, 30.0);
				return Plugin_Stop;
			}
			case 7:
			{
				if(!TF2_IsPlayerInCondition(client, TFCond_OnFire))
				{
					TF2_IgnitePlayer(client, client, 10.0);
					TF2_AddCondition(client, TFCond_HealingDebuff, 10.0);
				}
				SDKHooks_TakeDamage(client, 0, 0, 4.0, DMG_GENERIC|DMG_PREVENT_PHYSICS_FORCE);
			}
			case 8:
			{
				TF2_StunPlayer(client, 30.0, 0.5, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN, client);
				return Plugin_Stop;
			}
			case 9:
			{
				TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
				TF2_AddCondition(client, TFCond_UberchargedCanteen, 5.0);
				return Plugin_Stop;
			}
		}
		if(DrinkRND_Time[npc.index] < GetGameTime())
			return Plugin_Stop;	
		return Plugin_Continue;
	}
	else
		return Plugin_Stop;
}*/