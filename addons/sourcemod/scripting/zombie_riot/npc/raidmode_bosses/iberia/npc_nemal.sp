#pragma semicolon 1
#pragma newdecls required


#define Nemal_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define Nemal_LASER_THICKNESS 25

static bool BlockLoseSay;

static bool b_angered_twice[MAXENTITIES];
static int i_SaidLineAlready[MAXENTITIES];
static float f_TimeSinceHasBeenHurt[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static float fl_said_player_weaponline_time[MAXENTITIES];

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


static bool b_RageAnimated[MAXENTITIES];
static bool b_RageProjectile[MAXENTITIES];

void Nemal_OnMapStart_NPC()
{
	if(!IsFileInDownloads(WEAPON_CUSTOM_WEAPONRY_1))
		return;
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nemal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_Nemal");
	strcopy(data.Icon, sizeof(data.Icon), "Nemal_raid");
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
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_Nemal_2.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Nemal(client, vecPos, vecAng, ally, data);
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
	property bool b_NemalRocketJump
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
	
	
	public Nemal(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Nemal npc = view_as<Nemal>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
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

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossNemal_OnTakeDamagePost);
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		BlockLoseSay = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		

		if(StrContains(data, "wave_15"))
		{
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
					CPrintToChatAll("{lightblue}Nemal{default}: {gold}Silvester{default} is late isnt he? Probably off to some random beach with {blue}Nemal{default} as usual.. without me!!!\nWe said vacation is after this! oh well, lets begin!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: Iberians are with us {gold}Expidonsans{default}!... But im kinda both...\nProbably not that important, anyways lets go!");
				}
			}
		}
		if(StrContains(data, "wave_30"))
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
					CPrintToChatAll("{lightblue}Nemal{default}: What i would do for {blue}Waldch{default} to stop being so mangetic to {gold}Silvester{default} with his Wildingen antics, that isnt his home!!!");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: I'll be honest, {blue}Nemal's{default} kinda scary, i mean you fought him, you'd know!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}Nemal{default}: There sadly aint many Iberians left after what happend to their home country, damn traitorous {blue}seaborn{default}... we took in the rest and helped them!");
				}
			}
		}
		if(StrContains(data, "wave_45"))
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
					CPrintToChatAll("{lightblue}Nemal{default}: {blue}Nemal{default} wasnt lying when he said you guys got some tricks.");
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
		if(StrContains(data, "wave_60"))
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

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		b_RageAnimated[npc.index] = false;
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



		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Nemal_Win);
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_Nemal_2.mp3");
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
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_templar_hood/sf14_templar_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
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
	if(i_RaidGrantExtra[npc.index] == 50)
	{
		npc.m_flSpeed = 660.0;
		BlockLoseSay = true;
		if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestAlly(npc.index);
			npc.m_flGetClosestTargetTime = GetRandomRetargetTime();
		}
		if(IsValidAlly(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}
		return;
	}
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

	if(NemalMassLaserAttack(npc))
		return;

	if(NemalSummonPortal(npc))
		return;

	if (npc.IsOnGround())
	{
		if(GetGameTime(npc.index) > npc.f_NemalRocketJumpCD_Wearoff)
		{
			npc.b_NemalRocketJump = false;
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
		SetGoalVectorIndex = NemalSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 

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
	Nemal_Weapon_Lines(npc, attacker);
	if(i_RaidGrantExtra[npc.index] == 5)
	{
		if(((ReturnEntityMaxHealth(npc.index)/40) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			b_angered_twice[npc.index] = true; 
			i_SaidLineAlready[npc.index] = 0; 
			f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;
			RaidModeTime = FAR_FUTURE;
			f_NpcImmuneToBleed[npc.index] = GetGameTime() + 1.0;
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);
			
			CPrintToChatAll("{ligghtblue}Nemal{default}: Ouch ouch! Time out, time out!");

			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}

	
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
			CPrintToChatAll("{ligghtblue}Nemal{default}: Okay... ouch.. ow...");
		}
		case 1:
		{
			CPrintToChatAll("{ligghtblue}Nemal{default}: Okay Okay you won! For now!");
		}
		case 2:
		{
			CPrintToChatAll("{ligghtblue}Nemal{default}: See you next time.... this hurts!");
		}
		case 3:
		{
			CPrintToChatAll("{ligghtblue}Nemal{default}: I was going to insult you, but i asked for this...");
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
		NemalEffects(npc.index, view_as<int>(npc.Anger));
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetNemalWeapon(npc, 1);
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
				//	ResetNemalWeapon(npc, 1);
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
				//	ResetNemalWeapon(npc, 0);
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
				//	ResetNemalWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

int NemalSelfDefense(Nemal npc, float gameTime, int target, float distance)
{
	npc.i_GunMode = 0;
	if(ZR_GetWaveCount()+1 >= 45 && npc.m_flAngerDelay < GetGameTime(npc.index))
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
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt05");
			npc.m_flAttackHappens = 0.0;
			EmitSoundToAll("mvm/mvm_tank_end.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
			npc.SetCycle(0.01);
			npc.m_flReloadIn = gameTime + 3.0;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			NemalGiveShield(npc.index, CountPlayersOnRed(1) * 3); //Give self a shield

			NemalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flAngerDelay = gameTime + 60.0;

			if(ZR_GetWaveCount()+1 >= 60)
			{
				npc.m_flReloadIn = gameTime + 1.5;
				npc.SetPlaybackRate(2.0);
				npc.m_flAngerDelay = gameTime + 30.0;
			}

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
			NemalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 7.5;
			NemalGiveShield(npc.index, CountPlayersOnRed(1));

			if(ZR_GetWaveCount()+1 >= 15)
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 4.0;
				
			if(ZR_GetWaveCount()+1 >= 30)
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 5.5;
		}
	}
	else if(ZR_GetWaveCount()+1 >= 30 && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			NemalThrowScythes(npc);
			if(IsValidEntity(npc.m_iWearable7))
			{
				RemoveEntity(npc.m_iWearable7);
			}
			npc.m_flRangedSpecialDelay = gameTime + 15.5;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_flDoingAnimation = gameTime + 99.0;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
			npc.m_flAttackHappens = 0.0;
			npc.m_flAttackHappens_2 = gameTime + 1.4;
			NemalGiveShield(npc.index,CountPlayersOnRed(1) * 2);
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
			npc.SetCycle(0.01);
			if(ZR_GetWaveCount()+1 >= 60)
			{
				npc.m_flAttackHappens_2 = gameTime + 1.275;
				npc.SetPlaybackRate(1.25);
			}
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


void NemalEffects(int iNpc, int colour = 0, char[] attachment = "effect_hand_r")
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


public void RaidbossNemal_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Nemal npc = view_as<Nemal>(victim);
	if(ZR_GetWaveCount()+1 >= 45)
	{
		if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 3.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 60.0;
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

bool NemalTalkPostWin(Nemal npc)
{
	if(!b_angered_twice[npc.index])
		return false;

	if(npc.m_iChanged_WalkCycle != 6)
	{
		if(IsValidEntity(npc.m_iWearable7))
		{
			RemoveEntity(npc.m_iWearable7);
		}
		NemalEffects(npc.index, view_as<int>(npc.Anger));
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 6;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		NPC_StopPathing(npc.index);
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
		CPrintToChatAll("{blue}Nemal{default}: We apologize for the sudden attack, we didn't know, take this as an apology.");
		
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		BlockLoseSay = true;
		for (int client = 0; client < MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
			{
				Items_GiveNamedItem(client, "Expidonsan Battery Device");
				CPrintToChat(client,"{default}Nemal gave you a high tech battery: {darkblue}''Expidonsan Battery Device''{default}!");
			}
		}
	}
	else if(GetGameTime() + 5.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 4)
	{
		i_SaidLineAlready[npc.index] = 4;
		CPrintToChatAll("{blue}Nemal{default}: But I see that this was to protect you guys, yet you were able to destroy Nemesis.");
	}
	else if(GetGameTime() + 10.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 3)
	{
		i_SaidLineAlready[npc.index] = 3;
		CPrintToChatAll("{blue}Nemal{default}: We got sent to rescue him and we saw you attacking him.");
	}
	else if(GetGameTime() + 13.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 2)
	{
		i_SaidLineAlready[npc.index] = 2;
		CPrintToChatAll("{blue}Nemal{default}: We are close friends though we lost contact since he came out of the city.");
	}
	else if(GetGameTime() + 16.5 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 1)
	{
		i_SaidLineAlready[npc.index] = 1;
		CPrintToChatAll("{blue}Nemal{default}: I see, they are friend of your's now aswell.");
	}
	return true; //He is trying to help.
}

bool NemalTransformation(Nemal npc)
{
	if(npc.Anger)
	{
		if(!b_RageAnimated[npc.index])
		{
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
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
			NPC_StartPathing(npc.index);
			npc.m_bPathing = true;
			npc.m_flSpeed = 330.0;
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
			NemalEffects(npc.index, view_as<int>(npc.Anger));
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
bool NemalMassLaserAttack(Nemal npc)
{
	if(npc.m_flAttackHappens_2)
	{
		UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
		int enemy_2[MAXENTITIES];
		bool ClientTargeted[MAXENTITIES];
		GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
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
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false);
			bool foundEnemy = false;
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					foundEnemy = true;
					float WorldSpaceVec[3]; WorldSpaceCenter(enemy[i], WorldSpaceVec);
					NemalInitiateLaserAttack(npc.index, WorldSpaceVec, flPos);
				}
			}
			if(foundEnemy)
			{
				int Pitch = 100;
				if(ZR_GetWaveCount()+1 >= 60)
					Pitch = 125;

				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME, Pitch);
				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME, Pitch);
				EmitSoundToAll(g_LaserGlobalAttackSound[GetRandomInt(0, sizeof(g_LaserGlobalAttackSound) - 1)], npc.index, SNDCHAN_AUTO, 150, _, BOSS_ZOMBIE_VOLUME, Pitch);
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

bool NemalSummonPortal(Nemal npc)
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
			Nemal particle = view_as<Nemal>(PortalParticle);
			particle.Anger = npc.Anger;
			DataPack pack;
			CreateDataTimer(8.5, Nemal_TimerRepeatPortalGate, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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
public Action Nemal_TimerRepeatPortalGate(Handle timer, DataPack pack)
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

		Nemal npc = view_as<Nemal>(Originator);
		static float flMyPos[3];
		GetEntPropVector(Particle, Prop_Data, "m_vecOrigin", flMyPos);
		UnderTides npcGetInfo = view_as<UnderTides>(Originator);
		int enemy[MAXENTITIES];
		GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false, Particle, (1800.0 * 1800.0));
		bool Foundenemies = false;

		for(int i; i < sizeof(enemy); i++)
		{
			if(enemy[i])
			{
				Foundenemies = true;
				float WorldSpaceVec[3]; WorldSpaceCenter(enemy[i], WorldSpaceVec);
				int Projectile = npc.FireParticleRocket(WorldSpaceVec, Nemal_BASE_RANGED_SCYTHE_DAMGAE * RaidModeScaling , 400.0 , 100.0 , "",_,_,true, flMyPos,_,_,_,false);
				NemalEffects(Projectile,view_as<int>(npc.Anger),"");
				b_RageProjectile[Projectile] = npc.Anger;

				//dont exist !
				SDKUnhook(Projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
				SDKHook(Projectile, SDKHook_StartTouch, Nemal_Particle_StartTouch);
				
				CreateTimer(15.0, Timer_RemoveEntityNemal, EntIndexToEntRef(Projectile), TIMER_FLAG_NO_MAPCHANGE);
				static float ang_Look[3];
				GetEntPropVector(Projectile, Prop_Send, "m_angRotation", ang_Look);
				Initiate_HomingProjectile(Projectile,
				npc.index,
					70.0,			// float lockonAngleMax,
					9.0,				//float homingaSec,
					true,				// bool LockOnlyOnce,
					true,				// bool changeAngles,
					ang_Look,			
					enemy[i]); //home onto this enemy
			}
		}

		if(Foundenemies)
			EmitSoundToAll("misc/halloween/spell_teleport.wav", npc.index, SNDCHAN_STATIC, 90, _, 0.8);
			
		Nemal particle = view_as<Nemal>(Particle);
		if(npc.Anger && !particle.Anger)
		{
			//update particle
			int PortalParticle = ParticleEffectAt(flMyPos, "eyeboss_death_vortex", 0.0);
			DataPack pack2;
			particle.Anger = npc.Anger;
			CreateDataTimer(8.5, Nemal_TimerRepeatPortalGate, pack2, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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




int NemalHitDetected[MAXENTITIES];

void NemalInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{

	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Nemal_TraceWallsOnly);
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

	Nemal npc = view_as<Nemal>(entity);
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
	float diameter = float(Nemal_LASER_THICKNESS * 4);
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
	RequestFrames(NemalInitiateLaserAttack_DamagePart, 50, pack);
}

void NemalInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		NemalHitDetected[i] = false;
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

	Nemal npc = view_as<Nemal>(entity);
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
	float diameter = float(Nemal_LASER_THICKNESS * 4);
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
	hullMin[0] = -float(Nemal_LASER_THICKNESS);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Nemal_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 70.0 * RaidModeScaling;
	float FarDamage = 60.0 * RaidModeScaling;
	float MaxDistance = 5000.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (NemalHitDetected[victim] && GetTeam(entity) != GetTeam(victim))
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


public bool Nemal_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		NemalHitDetected[entity] = true;
	}
	return false;
}

public bool Nemal_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


void NemalGiveShield(int Nemal, int shieldcount)
{
	Nemal npc = view_as<Nemal>(Nemal);
	if(ZR_GetWaveCount()+1 >= 60)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.4);
	}
	else if(ZR_GetWaveCount()+1 >= 45)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.3);
	}
	else if(ZR_GetWaveCount()+1 >= 30)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.25);
	}
	else
	{
		shieldcount = RoundToNearest(float(shieldcount) * 0.75);
	}

	if(npc.Anger)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.1);
	}

	VausMagicaGiveShield(Nemal, shieldcount); //Give self a shield
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
		
		case WEAPON_Nemal_SCYTHE,WEAPON_Nemal_SCYTHE_PAP_1,WEAPON_Nemal_SCYTHE_PAP_2,WEAPON_Nemal_SCYTHE_PAP_3:
		 switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "You are trying to wield my weapon, {gold}%N{default}? You do not have the expertiese in it.", client);
		  							case 1: Format(Text_Lines, sizeof(Text_Lines), "You think you can use it to its fullest potentnial {gold}%N{default}? You dont even own the {gold}Manifestation glove.", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvesters{default} blade? Why is he so nice to everyone...");
		 							case 1: Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default}, you...");}
		case WEAPON_SICCERINO,WEAPON_WALDCH_SWORD_NOVISUAL:  Format(Text_Lines, sizeof(Text_Lines), "How do you have access to such expidonsan weaponry{gold}%N{default}?",client);
		case WEAPON_WALDCH_SWORD_REAL:  Format(Text_Lines, sizeof(Text_Lines), "What? How did you get this elite blade {gold}%N{default}?",client);
		case WEAPON_NEARL:  Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default} decided to visit Kazimierz?");
		case WEAPON_KAHMLFIST:  Format(Text_Lines, sizeof(Text_Lines), "Kahmlstein caused enough problems as it is.");
		case WEAPON_KIT_BLITZKRIEG_CORE:  Format(Text_Lines, sizeof(Text_Lines), "This machine is gone now, use it better then it has {gold}%N{default}.",client);
		case WEAPON_IRENE:  Format(Text_Lines, sizeof(Text_Lines), "Iberia's Weapons!? Looks like the secret is out of the bag now...");
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "OH MY GOD, {snow}BOB THE FIRST{default} IS ON YOUR SIDE?!");
		case WEAPON_ANGELIC_SHOTGUN:  Format(Text_Lines, sizeof(Text_Lines), "Howd you get {lightblue}Nemal's{default} Weapon{gold}%N{default}?",client);
		case WEAPON_IMPACT_LANCE:  Format(Text_Lines, sizeof(Text_Lines), "The lance... the only weapon that was forged from both ruina and {gold}expidonsa{default}...");

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{blue}Nemal{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}
