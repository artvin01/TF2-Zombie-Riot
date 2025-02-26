#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static const char g_TeleportSound[][] = {
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

static const char g_MeleeAttackSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};
static const char g_RangedSound[][] = {
	"weapons/tacky_grenadier_shoot.wav",
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

static const char g_MessengerThrowFire[][] = {
	"misc/halloween/spell_fireball_cast.wav",
};

static const char g_MessengerThrowIce[][] = {
	"weapons/icicle_freeze_victim_01.wav",
};

static bool b_khamlWeaponRage[MAXENTITIES];
bool BlockLoseSay;
static float f_MessengerSpeedUp[MAXENTITIES];

static float f_messenger_cutscene_necksnap[MAXENTITIES];
static int NPCId;

void TheMessenger_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Messenger");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_the_messenger");
	strcopy(data.Icon, sizeof(data.Icon), "messenger");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MessengerThrowFire));	   i++) { PrecacheSound(g_MessengerThrowFire[i]);	   }
	for (int i = 0; i < (sizeof(g_MessengerThrowIce));	   i++) { PrecacheSound(g_MessengerThrowIce[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_TeleportSound)); i++) { PrecacheSound(g_TeleportSound[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedSound)); i++) { PrecacheSound(g_RangedSound[i]); }
	for (int i = 0; i < (sizeof(g_HurtArmorSounds)); i++) { PrecacheSound(g_HurtArmorSounds[i]); }
	for (int i = 0; i < (sizeof(g_SuperJumpSound)); i++) { PrecacheSound(g_SuperJumpSound[i]); }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheHitSound));   i++) { PrecacheSound(g_SyctheHitSound[i]);   }
	for (int i = 0; i < (sizeof(g_SyctheInitiateSound));   i++) { PrecacheSound(g_SyctheInitiateSound[i]);   }
	for (int i = 0; i < (sizeof(g_LaserGlobalAttackSound));   i++) { PrecacheSound(g_LaserGlobalAttackSound[i]);   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	PrecacheSoundCustom("#zombiesurvival/internius/messenger.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return TheMessenger(vecPos, vecAng, team, data);
}
methodmap TheMessenger < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float f_TheMessengerMeleeCooldown
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float f_TheMessengerRocketJumpCD
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property float f_TheMessengerRocketJumpCD_Wearoff
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool b_TheMessengerRocketJump
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}
	property float m_flSwitchCooldown	// Delay between switching weapons
	{
		public get()			{	return this.m_flGrappleCooldown;	}
		public set(float value) 	{	this.m_flGrappleCooldown = value;	}
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
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayProjectileSound() 
	{
		if(this.m_flidle_talk > GetGameTime(this.index))
			return;
			
		this.m_flidle_talk = GetGameTime(this.index) + 0.1;
		if(i_RaidGrantExtra[this.index] >= 3)
			EmitSoundToAll(g_MessengerThrowFire[GetRandomInt(0, sizeof(g_MessengerThrowFire) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(g_MessengerThrowIce[GetRandomInt(0, sizeof(g_MessengerThrowIce) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	public void PlayRangedSound() 
	{
		EmitSoundToAll(g_RangedSound[GetRandomInt(0, sizeof(g_RangedSound) - 1)], this.index, SNDCHAN_WEAPON, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHurtArmorSound() 
	{
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	public void PlayHurtSound() 
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound() 
	{
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public TheMessenger(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		TheMessenger npc = view_as<TheMessenger>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		b_khamlWeaponRage[npc.index] = false;



		func_NPCDeath[npc.index] = view_as<Function>(TheMessenger_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(TheMessenger_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(TheMessenger_ClotThink);
		func_NPCFuncWin[npc.index] = view_as<Function>(TheMessenger_Win);

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, TheMessenger_OnTakeDamagePost);

		
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		BlockLoseSay = false;
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 15.0;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 25.0;
		f_MessengerSpeedUp[npc.index] = 1.0;
		npc.g_TimesSummoned = 0;
		
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		RemoveAllDamageAddition();
		

		i_RaidGrantExtra[npc.index] = 1;
		if(StrContains(data, "wave_15") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
		}
		else if(StrContains(data, "wave_45") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
		}
		else if(StrContains(data, "wave_60") != -1)
		{
			i_RaidGrantExtra[npc.index] = 5;
		}

		bool final = StrContains(data, "Cutscene_Khaml") != -1;
		
		if(final)
		{
			TeleportDiversioToRandLocation(npc.index);
			i_RaidGrantExtra[npc.index] = 6;
			f_messenger_cutscene_necksnap[npc.index] = GetGameTime() + 2.0;
		}
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "The Messanger Arrived");
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
	
		float value;
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRound()+1);
			value = float(Waves_GetRound()+1);
		}

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

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(value > 40 && value < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(value > 55)
		{
			RaidModeScaling *= 0.7;
		}

		RaidModeScaling *= 0.5;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/messenger.mp3");
		music.Time = 219;
		music.Volume = 1.25;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Brutality -Rebuild-");
		strcopy(music.Artist, sizeof(music.Artist), "Chihiro Aoki");
		Music_SetRaidMusic(music);
		
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		if(!final)
		{
			if(i_RaidGrantExtra[npc.index] <= 2)
			{
				IgniteTargetEffect(npc.m_iWearable1);
				CPrintToChatAll("{lightblue}The Messenger{default}: Welcome, welcome sinners! I'm bearing a message to you all!");
			}
			else
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Round two.");
			}
		}

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/demo/cc_summer2015_outta_sight/cc_summer2015_outta_sight.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/demo/sbox2014_juggernaut_jacket/sbox2014_juggernaut_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/demo/hwn2023_stunt_suit/hwn2023_stunt_suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/all_class/hiphunter_boots/hiphunter_boots_demo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

//		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);

		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;

		SetVariantColor(view_as<int>({173, 216, 230, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

public void TheMessenger_ClotThink(int iNPC)
{
	TheMessenger npc = view_as<TheMessenger>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(i_RaidGrantExtra[npc.index] >= 6)
	{
		i_RaidGrantExtra[npc.index] = 6;
		CPrintToChatAll("{lightblue}The Messenger{default}: {crimson}AHAHAHAHHAHAHAHA!!! ALL OF YOU ARE DEAD!!");
		return;
	}
	/*
	if(TheMessengerTalkPostWin(npc))
		return;
*/
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		BlockLoseSay = true;
		if(i_RaidGrantExtra[npc.index] <= 2)
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: Shame.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: Are you for real??");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: No comment.");
				}
			}
		}
		else
		{
			CPrintToChatAll("{lightblue}The Messenger{default}: ...........");
		}
	}
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			if(i_RaidGrantExtra[npc.index] <= 2)
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: Your friends are dead. {crimson}Accept your fate.");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: It's just you and me now.");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: Give up, you cannot win.");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: YOU ARE DEAD");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: I'LL FUCK YOU UP");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: AHAHAHAHAHAHA");
					}
				}				
			}
		}
	}
/*
	if(TheMessengerTransformation(npc))
		return;
*/
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

	if(npc.i_GunMode == 0 && Messanger_Elemental_Attack_Projectiles(npc))
	{
		npc.m_flMeleeArmor = 0.65;
		npc.m_flRangedArmor = 0.5;	
		return;
	}

	if(Messanger_Elemental_Attack_TempPowerup(npc))
	{
		npc.m_flMeleeArmor = 0.65;
		npc.m_flRangedArmor = 0.5;	
		return;
	}

	npc.m_flMeleeArmor = 1.25;
	npc.m_flRangedArmor = 1.0;		

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
		SetGoalVectorIndex = TheMessengerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		
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
					Messanger_Elemental_Attack_FingerPoint(npc);
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
		TheMessengerAnimationChange(npc);
	}
}

bool Messanger_Elemental_Attack_Projectiles(TheMessenger npc)
{
	if(!npc.m_flAttackHappens_2 && npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index))
	{
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + (25.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_roar_owar");
		npc.m_flAttackHappens = 0.0;
		npc.SetCycle(0.01);
		npc.SetPlaybackRate(f_MessengerSpeedUp[npc.index]);
		npc.m_flAttackHappens_2 = GetGameTime(npc.index) + (4.0 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_flDoingAnimation = GetGameTime(npc.index) + (4.0 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_iOverlordComboAttack = 0;
		npc.m_iChanged_WalkCycle = 0;

		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);

		float flPos[3];
		float flAng[3];
		npc.GetAttachment("effect_hand_r", flPos, flAng);

		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
	}

	if(npc.m_flAttackHappens_2)
	{
		float TimeUntillOver = npc.m_flAttackHappens_2 - GetGameTime(npc.index);
		//one second into the ability
		if(npc.m_flAttackHappens_2 < GetGameTime(npc.index))
		{
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			npc.m_flAttackHappens_2 = 0.0;
		}

		if(TimeUntillOver < (0.3 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 4)
			{
				npc.m_iOverlordComboAttack = 4;
				fl_TotalArmor[npc.index] = fl_TotalArmor[npc.index] * 0.9;
				RaidModeScaling *= 1.1;
				switch(GetRandomInt(0,3))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: No more fucking around.");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: Stop wasting my time shitheads.");
					}
					case 2:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: All sinners will {crimson}DIE.");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}The Messenger{default}: You just brought infinite pain upon you.");
					}
				}
				MessengerInitiateGroupAttack(npc);
			}
			return true;
		}
		if(TimeUntillOver < (2.0 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 3)
			{
				npc.m_iOverlordComboAttack = 3;
				MessengerInitiateGroupAttack(npc);

			}
			return true;
		}
		if(TimeUntillOver < (2.7 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 2)
			{
				npc.m_iOverlordComboAttack = 2;
				MessengerInitiateGroupAttack(npc);

			}
			return true;
		}
		if(TimeUntillOver < (3.5 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 1)
			{
				npc.m_iOverlordComboAttack = 1;
				MessengerInitiateGroupAttack(npc);
			}
			return true;
		}
		return true;
	}
	return false;
}


bool Messanger_Elemental_Attack_TempPowerup(TheMessenger npc)
{
	if(!npc.m_flNextRangedBarrage_Spam && npc.m_flAttackHappens_bullshit < GetGameTime(npc.index))
	{
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + (35.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_cheers_demo");
		npc.m_flAttackHappens = 0.0;
		npc.SetCycle(0.01);
		npc.SetPlaybackRate(f_MessengerSpeedUp[npc.index]);
		npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_flDoingAnimation = GetGameTime(npc.index) + (1.85 * (1.0 / f_MessengerSpeedUp[npc.index]));	
		npc.m_iOverlordComboAttack = 0;
		npc.m_iChanged_WalkCycle = 0;
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 10.0;
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
			
		float flPos[3];
		float flAng[3];
		npc.GetAttachment("effect_hand_r", flPos, flAng);

		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
	}
	if(npc.m_flNextRangedBarrage_Spam)
	{

		if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index))
		{
			npc.i_GunMode = 0;
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			
			if(i_RaidGrantExtra[npc.index] <= 2)
				IgniteTargetEffect(npc.m_iWearable1);

			npc.m_flNextRangedBarrage_Spam = 0.0;
		}
	}
	if(npc.m_flNextRangedBarrage_Singular)
	{
		float TimeUntillOver = npc.m_flNextRangedBarrage_Singular - GetGameTime(npc.index);

		if(TimeUntillOver < (1.2 * (1.0 / f_MessengerSpeedUp[npc.index])))
		{
			if(npc.m_iOverlordComboAttack != 1)
			{
				npc.m_iOverlordComboAttack = 1;
				MessengerInitiateGroupAttack(npc);
				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
			}
		}
		if(npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index))
		{
			npc.i_GunMode = 1;

			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);

			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_quadball/c_quadball.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			npc.m_flNextRangedBarrage_Singular = 0.0;
		}
		return true;
	}
	return false;
}


bool Messanger_Elemental_Attack_FingerPoint(TheMessenger npc)
{
	if(!npc.m_flJumpStartTimeInternal && npc.m_flJumpCooldown < GetGameTime(npc.index))
	{
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
		npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_PRIMARY");
		npc.m_flJumpStartTimeInternal = GetGameTime(npc.index) + 0.75;	
		npc.m_flSwitchCooldown = GetGameTime(npc.index) + 1.25;	
		float flPos[3];
		float flAng[3];
		int Particle_1;
		npc.GetAttachment("foot_L", flPos, flAng);
		Particle_1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		CreateTimer(0.75, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
	}
	if(npc.m_flJumpStartTimeInternal)
	{
		if(npc.m_flSwitchCooldown < GetGameTime(npc.index))
		{
			npc.m_flJumpStartTimeInternal = 0.0;
		}
	}
	if(npc.m_flJumpStartTimeInternal)
	{
		if(npc.m_flJumpStartTimeInternal < GetGameTime(npc.index) && npc.m_flSwitchCooldown > GetGameTime(npc.index))
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

			float PreviousPos[3];
			WorldSpaceCenter(npc.index, PreviousPos);
			
			bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, true);
			if(Succeed)
			{
				npc.PlayTeleportSound();
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				ParticleEffectAt(PreviousPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
						
				npc.m_flJumpStartTimeInternal = 0.0;
				MessengerResetAndDelayAttack(npc.index);
			}
		}
		return true;
	}
	return false;
}

public Action TheMessenger_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TheMessenger npc = view_as<TheMessenger>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}		
	if(weapon > 0)
	{
		if(!b_khamlWeaponRage[npc.index])
		{
			if(i_CustomWeaponEquipLogic[weapon] == WEAPON_MESSENGER_LAUNCHER)
			{
				b_khamlWeaponRage[npc.index] = true;
				CPrintToChatAll("{lightblue}The Messenger{default}: FUCK you, okay? FUCK you.");
			}
		}
	}
	return Plugin_Changed;
}

public void TheMessenger_NPCDeath(int entity)
{
	TheMessenger npc = view_as<TheMessenger>(entity);
	/*
		Explode on death code here please

	*/
	
	if(!b_thisNpcIsARaid[npc.index])
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
		npc.PlayDeathSound();	
	}

	RaidBossActive = INVALID_ENT_REFERENCE;
		
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

	if(b_thisNpcIsARaid[npc.index])
	{
		if(i_RaidGrantExtra[npc.index] <= 2)
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: Ugh... little fucks.. This ain't over");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: You're just delaying the inevitable..");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: I may or may not heavily underestimated you..");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: No...");
				}
			}
		}
		else
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: NOT TWICE");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: WHY");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}The Messenger{default}: I just want to impress Him for once... Ugh.....");
				}
			}
		}
	}
}
/*


*/
void TheMessengerAnimationChange(TheMessenger npc)
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
				// ResetTheMessengerWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_SECONDARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
				//	ResetTheMessengerWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_SECONDAY");
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
				//	ResetTheMessengerWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_ITEM1");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
				//	ResetTheMessengerWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_ITEM1");
					npc.StartPathing();
				}	
			}
		}
	}

}

int TheMessengerSelfDefense(TheMessenger npc, float gameTime, int target, float distance)
{
	if(npc.i_GunMode == 1)
	{
		if(gameTime > npc.m_flNextMeleeAttack)
		{
			if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5))
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					npc.FaceTowards(vecTarget, 20000.0);
					int projectile;
					float Proj_Damage = 22.0 * RaidModeScaling;
					if(i_RaidGrantExtra[npc.index] <= 2)
						projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1000.0, 150.0, "spell_fireball_small_red", false);
					else
						projectile = npc.FireParticleRocket(vecTarget, Proj_Damage, 1000.0, 150.0, "spell_fireball_small_blue", false);
			
					SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
					int particle = EntRefToEntIndex(i_rocket_particle[projectile]);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					
					SDKHook(projectile, SDKHook_StartTouch, TheMessenger_Rocket_Particle_StartTouch);		
					
				}
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
				{
					//target is too far, try to close in
					return 0;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 1;
					}
				}
				return 0;
			}
			else
			{
				if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
				{
					//target is too far, try to close in
					return 0;
				}
				else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
				{
					if(Can_I_See_Enemy_Only(npc.index, target))
					{
						//target is too close, try to keep distance
						return 1;
					}
				}
			}
		}
		else
		{
			if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.5))
			{
				//target is too far, try to close in
				return 0;
			}
			else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				if(Can_I_See_Enemy_Only(npc.index, target))
				{
					//target is too close, try to keep distance
					return 1;
				}
			}
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
									TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
									TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
								}
								else
								{
									TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
									TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
								}
							}
										
							if(i_RaidGrantExtra[npc.index] <= 2)
							{
								if(targetTrace <= MaxClients)
									TF2_IgnitePlayer(targetTrace, targetTrace, 5.0);

								StartBleedingTimer_Against_Client(targetTrace, npc.index, 3.0, 5);
							}
							else
							{
								int ChaosDamage = 150;
								if(NpcStats_IsEnemySilenced(npc.index))
									ChaosDamage = 100;

								Elemental_AddChaosDamage(targetTrace, npc.index, ChaosDamage, true, true);
							}

							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 650.0); 
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1",true, 1.0, _, f_MessengerSpeedUp[npc.index]);
							
					npc.m_flAttackHappens = gameTime + (0.25 * (1.0 / f_MessengerSpeedUp[npc.index]));
					npc.m_flNextMeleeAttack = gameTime + (1.2 * (1.0 / f_MessengerSpeedUp[npc.index]));
					npc.m_flDoingAnimation = gameTime + (0.25 * (1.0 / f_MessengerSpeedUp[npc.index]));
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

void MessengerResetAndDelayAttack(int entity)
{
	TheMessenger npc = view_as<TheMessenger>(entity);
	npc.m_flAttackHappens = 0.0;
	if(npc.m_flNextMeleeAttack < GetGameTime(entity) + 0.5)
	{
		npc.m_flNextMeleeAttack = GetGameTime(entity) + 0.5;
	}
}

public void TheMessenger_Rocket_Particle_StartTouch(int entity, int target)
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

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	

		if(i_RaidGrantExtra[owner] <= 2)
		{
			if(target <= MaxClients)
				TF2_IgnitePlayer(target, target, 5.0);

			StartBleedingTimer_Against_Client(target, owner, DamageDeal * 0.1, 5);
		}
		else
		{
			int ChaosDamage = 75;
			if(NpcStats_IsEnemySilenced(owner))
				ChaosDamage = 40;

			if(i_NpcInternalId[owner] == NPCId)
			{
				ChaosDamage = 40;
				if(NpcStats_IsEnemySilenced(owner))
					ChaosDamage = 30;
			}

			Elemental_AddChaosDamage(target, owner, ChaosDamage, true, true);
		}
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
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}



void MessengerInitiateGroupAttack(TheMessenger npc)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy[MAXENTITIES];
	if(!IsValidEntity(npc.m_iWearable2))
	{
		float flPos[3];
		float flAng[3];
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "flaregun_trail_blue", npc.index, "effect_hand_r", {0.0,0.0,0.0});
	}
	GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, npc.m_iWearable2);

	for(int i; i < sizeof(enemy); i++)
	{
		if(enemy[i])
		{
			npc.PlayProjectileSound();
			int Target = enemy[i];
			float vecHit[3];
			WorldSpaceCenter(Target, vecHit);
			float vecHitPart[3];
			GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_vecAbsOrigin", vecHitPart);

			int projectile;
			float Proj_Damage = 22.0 * RaidModeScaling;
			if(i_RaidGrantExtra[npc.index] <= 2)
				projectile = npc.FireParticleRocket(vecHit, Proj_Damage, 1000.0, 150.0, "spell_fireball_small_red", false,_,true, vecHitPart);
			else
				projectile = npc.FireParticleRocket(vecHit, Proj_Damage, 1000.0, 150.0, "spell_fireball_small_blue", false,_,true, vecHitPart);
	
			SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			
			SDKHook(projectile, SDKHook_StartTouch, TheMessenger_Rocket_Particle_StartTouch);		
			static float ang_Look[3];
			GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
			Initiate_HomingProjectile(projectile,
			npc.index,
				70.0,			// float lockonAngleMax,
				7.5,				//float homingaSec,
				true,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				ang_Look,			
				Target); //home onto this enemy
		}
	}
}



public void TheMessenger_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(!b_thisNpcIsARaid[victim])
		return;

	TheMessenger npc = view_as<TheMessenger>(victim);
	if(npc.g_TimesSummoned < 99)
	{
		int nextLoss = ReturnEntityMaxHealth(npc.index) * (99 - npc.g_TimesSummoned) / 100;
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < nextLoss)
		{
			npc.g_TimesSummoned++;
			npc.m_flAttackHappens_bullshit -= 0.5;
			npc.m_flNextChargeSpecialAttack -= 0.5;
			npc.m_flJumpCooldown -= 0.125;
		}
	}

	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true;
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 0.0;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 0.0;
		f_MessengerSpeedUp[npc.index] = 1.65;
		npc.m_flSpeed = 330.0;

		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Ahahahahahaha, all of you are {crimson}FUCKED!!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: VOID, GRANT ME STRENGTH!");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: You think you won? I'M JUST GETTING STARTED.");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Remember those cats? {crimson} You're getting it worse.");
			}
		}
	}
}


public void TheMessenger_Win(int entity)
{
	if(i_RaidGrantExtra[entity] <= 2)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Judgement delivered.");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Your penance is now over.");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Thus your reign of terror is no more.");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: {crimson}TAKE THAT YOU FUCKS");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Are you seeing me right now? I did it..");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}The Messenger{default}: Are you proud? My Lord....");
			}
		}
	}
}