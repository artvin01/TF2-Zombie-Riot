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
	PrecacheSoundCustom("#zombiesurvival/internius/messenger_ost.mp3");
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
	property bool m_bBossRushDuo
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
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
		if(i_RaidGrantExtra[this.index] < 3)
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
		BlockLoseSay = false;
		npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 15.0;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 10.0;
		f_MessengerSpeedUp[npc.index] = 1.0;
		npc.g_TimesSummoned = 0;
		
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("mvm/mvm_tank_start.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		RemoveAllDamageAddition();
		

		i_RaidGrantExtra[npc.index] = 1;
		if(StrContains(data, "wave_10") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
		}
		else if(StrContains(data, "wave_20") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
		}
		else if(StrContains(data, "wave_40") != -1)
		{
			i_RaidGrantExtra[npc.index] = 5;
		}

		bool final = StrContains(data, "Cutscene_Khaml") != -1;
		npc.m_bBossRushDuo = StrContains(data, "bossrush_duo") != -1;
		
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
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(value > 25 && value < 35)
		{
			RaidModeScaling *= 0.85;
		}
		else if(value > 35)
		{
			RaidModeScaling *= 0.7;
		}

		RaidModeScaling *= 0.5;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/internius/messenger_ost.mp3");
		music.Time = 230;
		music.Volume = 1.6;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Ultimatum");
		strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
		Music_SetRaidMusic(music);
		
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

	//	Weapon
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_battleaxe/c_battleaxe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		if (npc.m_bBossRushDuo)
		{
			CPrintToChatAll("{lightblue}The Messenger{default}: You're gonna die.");
		}
		else if(!final)
		{
			if(i_RaidGrantExtra[npc.index] <= 2)
			{
				IgniteTargetEffect(npc.m_iWearable1);
				CPrintToChatAll("{lightblue}메신저{default}: 잘 왔다, 죄인들아! 여기 너희에게 줄 전령이 하나 있다!");
			}
			else
			{
				CPrintToChatAll("{lightblue}메신저{default}: 2차전은 준비 됐겠지, 죄인들?");
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
	
	if (npc.m_bBossRushDuo && b_NpcIsInvulnerable[npc.index])
		return;
	
	if(i_RaidGrantExtra[npc.index] >= 6)
	{
		i_RaidGrantExtra[npc.index] = 6;
		CPrintToChatAll("{lightblue}메신저{default}: {crimson}으하하하하하!!! 전부 뒈져버려라!!");
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
					CPrintToChatAll("{lightblue}메신저{default}: 쪽팔리는 줄 알아라.");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 진심인가?");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 뭐라 할 말이 없군.");
				}
			}
		}
		else
		{
			CPrintToChatAll("{lightblue}메신저{default}: ...........");
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
						CPrintToChatAll("{lightblue}메신저{default}: 네 놈의 친구들은 전부 죽었다. {crimson}네 운명을 받아들여라.");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 너와 나만 남았다.");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 포기해라. 넌 이길 수 없다");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 죽으라고!!!!");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 사지를 찢어발겨주마!!!!");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 으하하하하하!!!");
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
					npc.SetGoalVector(vPredictedPos);
					Messanger_Elemental_Attack_FingerPoint(npc);
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
		TheMessengerAnimationChange(npc);
	}
}

bool Messanger_Elemental_Attack_Projectiles(TheMessenger npc)
{
	if(!npc.m_flAttackHappens_2 && npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index))
	{
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + (25.0 * (1.0 / f_MessengerSpeedUp[npc.index]));
		npc.StopPathing();
		
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
						CPrintToChatAll("{lightblue}메신저{default}: 나는 너희들과 이 지랄하면서 놀 시간이 없다.");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 그만 죽어라, 이 머저리들아.");
					}
					case 2:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 모든 죄인은 {crimson}죽어야만한다.");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}메신저{default}: 그래봤자 무한한 고통을 느끼게 될 뿐이다.");
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
		npc.StopPathing();
		
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
				CPrintToChatAll("{lightblue}메신저{default}: 그건 내 무기잖아. 이런 미친 놈이...");
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
	
	if (EntIndexToEntRef(npc.index) == RaidBossActive)
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
					CPrintToChatAll("{lightblue}메신저{default}: 으윽... 이런 개밥도 못 한 쓰레기들이...");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 너흰 그저 피할 수 없는 일을 지연시킬 수 있을 뿐이다..");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 어쩌면 네놈들을 과소평가 했을수도 있겠군..");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 안 돼...");
				}
			}
		}
		else
		{
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 두 번 씩이나 졌단 말인가!!");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 어째서냐!!");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}메신저{default}: 난 그저 그 분에게 한 번이라도 좋은 모습을 보여주고 싶었을 뿐인데... 으윽.....");
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
			
					int particle = EntRefToEntIndex(i_WandParticle[projectile]);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(3.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
					
					WandProjectile_ApplyFunctionToEntity(projectile, TheMessenger_Rocket_Particle_StartTouch);
					
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
								float Proj_Damage = 22.0 * RaidModeScaling;
								Proj_Damage *= 0.1;
								NPC_Ignite(targetTrace, npc.index,2.5, -1, Proj_Damage);
							}
							else
							{
								
								int ChaosDamage = 150;
								if(NpcStats_IsEnemySilenced(npc.index))
									ChaosDamage = 140;

								ApplyStatusEffect(npc.index, targetTrace, "Near Zero", 3.5);
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
			if(i_NpcInternalId[owner] == NPCId)
				NPC_Ignite(target, owner,2.5, -1, DamageDeal * 0.1);
			else
				NPC_Ignite(target, owner,2.5, -1, DamageDeal * 0.2);
		}
		else
		{
			int ChaosDamage = 100;
			//above is kahmlstein

			if(i_NpcInternalId[owner] == NPCId)
			{
				//This is messenger
				ChaosDamage = 60;
					
				ApplyStatusEffect(owner, target, "Near Zero", 3.5);
			}

			Elemental_AddChaosDamage(target, owner, ChaosDamage, true, true);
		}
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
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
	int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
	//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
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
	
			WandProjectile_ApplyFunctionToEntity(projectile, TheMessenger_Rocket_Particle_StartTouch);		
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
				CPrintToChatAll("{lightblue}메신저{default}: 하하하하하, 전부 {crimson}뒈질 준비나 해라!!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 공허여, 내게 힘을 주소서!");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 지금 이겼다고 생각하나? 아직 시작일 뿐이라고.");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 그 고양이들을 기억하나? {crimson} 너희는 그것보다 더 심한 꼴을 당하게 될 거다.");
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
				CPrintToChatAll("{lightblue}메신저{default}: 정의가 집행되었다.");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 네 죗값은 이걸로 전부 치뤘다.");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 네 공포 정치는 이걸로 끝이다.");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}메신저{default}: {crimson}멍청한 병신새끼들!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 보고 계십니까? 제가 해냈습니다...");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}메신저{default}: 이제 만족하십니까, 주군이시여....");
			}
		}
	}
}