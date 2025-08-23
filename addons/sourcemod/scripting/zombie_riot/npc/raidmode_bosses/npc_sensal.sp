#pragma semicolon 1
#pragma newdecls required


#define SENSAL_BASE_RANGED_SCYTHE_DAMGAE 13.0
#define SENSAL_LASER_THICKNESS 25

static bool BlockLoseSay;



static float f_TimeSinceHasBeenHurt[MAXENTITIES];

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


static bool b_RageAnimated[MAXENTITIES];
static bool b_RageProjectile[MAXENTITIES];

int SensalID;
int SensalNPCID()
{
	return SensalID;
}
void Sensal_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sensal");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sensal");
	strcopy(data.Icon, sizeof(data.Icon), "sensal_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	SensalID = NPC_Add(data);
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
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
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
	
	
	public Sensal(float vecPos[3], float vecAng[3], int ally, const char[] data)
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
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossSensal_OnTakeDamagePost);
		
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
		

		bool final = StrContains(data, "final_item") != -1;
		
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
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 6;
			b_NpcUnableToDie[npc.index] = true;
		}
		bool cutscene = StrContains(data, "duo_cutscene") != -1;
		if(cutscene)
		{
			i_RaidGrantExtra[npc.index] = 50;
		}
		bool cutscene2 = StrContains(data, "victoria_cutscene") != -1;
		if(cutscene2)
		{
			i_RaidGrantExtra[npc.index] = 51;
		}
		bool tripple = StrContains(data, "triple_enemies") != -1;
		if(tripple)
		{
			RemoveAllDamageAddition();
			CPrintToChatAll("{blue}Sensal{default}: This is your final challange, beat all 3 of us at once, Fear the might of {gold}Expidonsa{default}!");
			GiveOneRevive(true);
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

		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;

			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}

			if(value > 40.0 && value < 55.0)
			{
				RaidModeScaling *= 0.85;
			}
			else if(value > 55.0)
			{
				RaidModeTime = GetGameTime(npc.index) + 220.0;
				RaidModeScaling *= 0.65;
			}
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
			}
				
			if(Waves_GetRoundScale()+1 > 25 && Waves_GetRoundScale()+1 < 35)
			{
				RaidModeScaling *= 0.85;
			}
			else if(Waves_GetRoundScale()+1 > 35)
			{
				RaidModeTime = GetGameTime(npc.index) + 220.0;
				RaidModeScaling *= 0.65;
			}
		}

		b_RageAnimated[npc.index] = false;
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff

		if(!cutscene && !cutscene2 && !tripple)
		{
			RemoveAllDamageAddition();
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
			music.Time = 218;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Goukisan - Betrayal of Fear (TeslaX VIP remix)");
			strcopy(music.Artist, sizeof(music.Artist), "Talurre/TeslaX11");
			Music_SetRaidMusic(music);
		}
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


		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/spr18_veterans_attire/spr18_veterans_attire.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SensalEffects(npc.index, view_as<int>(npc.Anger));
		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});

		
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
				npc.StopPathing();
				
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}
		return;
	}
	if(i_RaidGrantExtra[npc.index] == 51)
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
				npc.StopPathing();
				
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
				npc.StartPathing();
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
		}

		if(npc.f_SensalMeleeCooldown > GetGameTime())
		{
			return;
		}
		npc.f_SensalMeleeCooldown = GetGameTime() + 4.0;
		switch(npc.i_GunMode)
		{
			case 0:
			{
				CPrintToChatAll("{blue}Sensal{default}: Stop the fight this instant.");
			}
			case 1:
			{
				CPrintToChatAll("{blue}Sensal{default}: What is happening here?");
			}
			case 2:
			{
				CPrintToChatAll("{blue}Castellan{default}: They attacked us while invading Ziberia, what else is there to add?");
			}
			case 3:
			{
				CPrintToChatAll("{blue}Sensal{default}: Invading Ziberia? Right after {darkblue}Kahmlstein{default} Perished?");
			}
			case 4:
			{
				CPrintToChatAll("{blue}Sensal{default}: There are more important matters to attend to.\nZiberia is not like Him.");
			}
			case 5:
			{
				CPrintToChatAll("{blue}Castellan{default}: Youre meaning to say that he was the cause?");
			}
			case 6:
			{
				CPrintToChatAll("{blue}Sensal{default}: Correct. The country itself isnt at fault. Now leave, I also believe Victoria has to deal with chaos.");
			}
			case 7:
			{
				CPrintToChatAll("{blue}Castellan{default}: I remember you mentioning chaos before, if you say its in our city walls, then we will immedietly return and assess the situation.");
			}
			case 8:
			{
				CPrintToChatAll("{blue}Sensal{default}: Good.");
			}
			case 9:
			{
				CPrintToChatAll("{blue}Castellan{default}: We will return to Victoria now.");
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						Items_GiveNamedItem(client, "Avangard's Processing Core-B");
						CPrintToChat(client,"{default}As Castellan and his army leave, they drop something: {darkblue}''Avangard's Processing Core-B''{default}!");
					}
				}
			}
			default:
			{
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}
		npc.i_GunMode++;
		return;
	}
	if(SensalTalkPostWin(npc))
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
					CPrintToChatAll("{blue}Sensal{default}: You are the last one.");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Sensal{default}: None of you criminals are of any importants infront of {gold}Expidonsa{default}.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Sensal{default}: All your friends are gone. Submit to {gold}Expidonsa{default}.");
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
		
		CPrintToChatAll("{blue}Sensal{default}: Refusing to collaborate or even reason with {gold}Expidonsa{default} will result in termination.");
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
		CPrintToChatAll("{blue}Sensal{default}: You are under arrest. The Expidonsan elite forces will take you now.");
		for(int i; i<32; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = NPC_CreateByName("npc_diversionistico", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
			}
		}
		BlockLoseSay = true;
	}

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
	Sensal_Weapon_Lines(npc, attacker);
	if(!b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(((ReturnEntityMaxHealth(npc.index)/40) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			b_angered_twice[npc.index] = true; 
			i_SaidLineAlready[npc.index] = 0; 
			f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;
			RaidModeTime += 60.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);
			
			CPrintToChatAll("{blue}Sensal{default}: You keep talking about Silvester and Waldch, what is the meaning of this?");

			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}

	
	return Plugin_Changed;
}
public void Raidmode_Expidonsa_Sensal_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}

static void Internal_NPCDeath(int entity)
{
	Sensal npc = view_as<Sensal>(entity);
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
	if(i_RaidGrantExtra[npc.index] == 50)
	{
		if(XenoExtraLogic())
			CPrintToChatAll("{blue}Sensal{default}: This area is restricted for all of you.");
		else
			CPrintToChatAll("{blue}Sensal{default}: You all are coming with me.");

		return;
	}
	if(i_RaidGrantExtra[npc.index] == 51)
	{
		return;
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
	if(i_RaidGrantExtra[npc.index] >= 4 && npc.m_flAngerDelay < GetGameTime(npc.index))
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
			npc.StopPathing();
			
			SensalGiveShield(npc.index, CountPlayersOnRed(1) * 3); //Give self a shield

			SensalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flAngerDelay = gameTime + 60.0;

			if(i_RaidGrantExtra[npc.index] >= 5)
			{
				npc.m_flReloadIn = gameTime + 1.5;
				npc.SetPlaybackRate(2.0);
				npc.m_flAngerDelay = gameTime + 45.0;
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
			SensalThrowScythes(npc);
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + 7.5;
			SensalGiveShield(npc.index, CountPlayersOnRed(1));

			if(i_RaidGrantExtra[npc.index] >= 2)
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 4.0;
				
			if(i_RaidGrantExtra[npc.index] >= 3)
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 5.5;
		}
	}
	else if(i_RaidGrantExtra[npc.index] >= 3 && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
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
			npc.StopPathing();
			
			npc.m_flDoingAnimation = gameTime + 99.0;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
			npc.m_flAttackHappens = 0.0;
			npc.m_flAttackHappens_2 = gameTime + 1.4;
			SensalGiveShield(npc.index,CountPlayersOnRed(1) * 2);
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8);
			npc.SetCycle(0.01);
			if(i_RaidGrantExtra[npc.index] >= 5)
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


void SensalEffects(int iNpc, int colour = 0, char[] attachment = "effect_hand_r", int colourdiff = 0)
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

		if(colourdiff)
		{
			SetEntityRenderColor(ModelApply, 255, 255, 255, 2);
		}
		else
		{
			if(colour)
			{
				SetEntityRenderColor(ModelApply, 255, 255, 255, 1);
			}
			else
			{
				SetEntityRenderColor(ModelApply, 255, 255, 255, 0);
			}
		}
		SetVariantInt(2);
		AcceptEntityInput(ModelApply, "SetBodyGroup");
	}
}


public void RaidbossSensal_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Sensal npc = view_as<Sensal>(victim);
	if(i_RaidGrantExtra[victim] >= 4)
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


void SensalThrowScythes(Sensal npc)
{
	Silvester_TE_Used = 0;
	int MaxCount = 1;
	float DelayPillars = 0.5;
	float DelaybewteenPillars = 0.5;
	float ang_Look[3];
	float pos[3];
	WorldSpaceCenter(npc.index, pos);
	
	if(i_RaidGrantExtra[npc.index] >= 5)
		MaxCount = 2;

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

		int Projectile = npc.FireParticleRocket(FloatVector, damage , 400.0 , 100.0 , "",_,_,true,origin_altered,_,_,_,false);
		b_RageProjectile[Projectile] = npc.Anger;
		//dont exist !
		SDKUnhook(Projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
		SDKHook(Projectile, SDKHook_StartTouch, Sensal_Particle_StartTouch);
		CreateTimer(15.0, Timer_RemoveEntitySensal, EntIndexToEntRef(Projectile), TIMER_FLAG_NO_MAPCHANGE);
		static float ang_Look[3];
		GetEntPropVector(Projectile, Prop_Send, "m_angRotation", ang_Look);
		bool DoHoming = true;
		if(count == 2)
		{
			int EnemySearch = GetClosestTarget(Projectile, true, _, true, _, _, _, true, .UseVectorDistance = true);
			if(IsValidEntity(EnemySearch))
			{
				TeleportEntity(Projectile, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
				SensalEffects(Projectile,view_as<int>(npc.Anger),"", 1);
				DoHoming = false;
				DataPack pack1;
				CreateDataTimer(0.1, WhiteflowerTank_Rocket_Stand, pack1, TIMER_FLAG_NO_MAPCHANGE);
				pack1.WriteCell(EntIndexToEntRef(Projectile));
				pack1.WriteCell(EntIndexToEntRef(EnemySearch));
			}
		}
		if(DoHoming)
		{
			SensalEffects(Projectile,view_as<int>(npc.Anger),"");
			Initiate_HomingProjectile(Projectile,
			npc.index,
				70.0,			// float lockonAngleMax,
				9.0,				//float homingaSec,
				true,				// bool LockOnlyOnce,
				true,				// bool changeAngles,
				ang_Look);// float AnglesInitiate[3]);
		}

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
		float VulnerabilityToGive = 0.065;
		IncreaseEntityDamageTakenBy(target, VulnerabilityToGive, 5.0, true);
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
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 6;
		npc.AddActivityViaSequence("selectionMenu_Idle");
		npc.SetCycle(0.01);
		npc.StopPathing();
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
		CPrintToChatAll("{blue}Sensal{default}: We apologize for the sudden attack, we didn't know, take this as an apology.");
		
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		BlockLoseSay = true;
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
			{
				Items_GiveNamedItem(client, "Expidonsan Battery Device");
				CPrintToChat(client,"{default}Sensal gave you a high tech battery: {darkblue}''Expidonsan Battery Device''{default}!");
			}
		}
	}
	else if(GetGameTime() + 5.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 4)
	{
		i_SaidLineAlready[npc.index] = 4;
		CPrintToChatAll("{blue}Sensal{default}: But I see that this was to protect you guys, yet you were able to destroy Calmaticus.");
	}
	else if(GetGameTime() + 10.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 3)
	{
		i_SaidLineAlready[npc.index] = 3;
		CPrintToChatAll("{blue}Sensal{default}: We got sent to rescue him and we saw you attacking him.");
	}
	else if(GetGameTime() + 13.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 2)
	{
		i_SaidLineAlready[npc.index] = 2;
		CPrintToChatAll("{blue}Sensal{default}: We are close friends though we lost contact since he came out of the city.");
	}
	else if(GetGameTime() + 16.5 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 1)
	{
		i_SaidLineAlready[npc.index] = 1;
		CPrintToChatAll("{blue}Sensal{default}: I see, they are friend of yours now aswell.");
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
			
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_profane_puppeteer");
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.01);
			b_RageAnimated[npc.index] = true;
			b_CannotBeHeadshot[npc.index] = true;
			b_CannotBeBackstabbed[npc.index] = true;
			ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
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
			RemoveSpecificBuff(npc.index, "Clear Head");
			RemoveSpecificBuff(npc.index, "Solid Stance");
			RemoveSpecificBuff(npc.index, "Fluid Movement");
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			npc.StartPathing();
			
			npc.m_flSpeed = 330.0;
			npc.m_flNextChargeSpecialAttack = 0.0;
			npc.m_bisWalking = true;
			RaidModeScaling *= 1.15;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
			
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
		UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
		int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT]; 
		//It should target upto 20 people only, if its anymore it starts becomming un dodgeable due to the nature of AOE laser attacks
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

			int enemy[RAIDBOSS_GLOBAL_ATTACKLIMIT];
			GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy), true, false);
			bool foundEnemy = false;
			for(int i; i < sizeof(enemy); i++)
			{
				if(enemy[i])
				{
					foundEnemy = true;
					float WorldSpaceVec[3]; WorldSpaceCenter(enemy[i], WorldSpaceVec);
					SensalInitiateLaserAttack(npc.index, WorldSpaceVec, flPos);
				}
			}
			if(foundEnemy)
			{
				int Pitch = 100;
				if(i_RaidGrantExtra[npc.index] >= 5)
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
			CreateDataTimer(8.5, Sensal_TimerRepeatPortalGate, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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
				int Projectile = npc.FireParticleRocket(WorldSpaceVec, SENSAL_BASE_RANGED_SCYTHE_DAMGAE * RaidModeScaling , 400.0 , 100.0 , "",_,_,true, flMyPos,_,_,_,false);
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
					true,				// bool LockOnlyOnce,
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
		if (LaserVarious_HitDetection[victim] && GetTeam(entity) != GetTeam(victim))
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
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}

public bool Sensal_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


void SensalGiveShield(int sensal, int shieldcount)
{
	Sensal npc = view_as<Sensal>(sensal);
	if(i_RaidGrantExtra[sensal] >= 5)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.4);
	}
	else if(i_RaidGrantExtra[sensal] >= 4)
	{
		shieldcount = RoundToNearest(float(shieldcount) * 1.3);
	}
	else if(i_RaidGrantExtra[sensal] >= 3)
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

	VausMagicaGiveShield(sensal, shieldcount); //Give self a shield
}

static void Sensal_Weapon_Lines(Sensal npc, int client)
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
		 switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "You are trying to wield my weapon, {gold}%N{default}? You do not have the expertiese in it.", client);
		  							case 1: Format(Text_Lines, sizeof(Text_Lines), "You think you can use it to its fullest potentnial {gold}%N{default}? You dont even own the {gold}Manifestation glove.", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvesters{default} blade? Why is he so nice to everyone...");
		 							case 1: Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default}, you...");}
		case WEAPON_SICCERINO,WEAPON_WALDCH_SWORD_NOVISUAL:  Format(Text_Lines, sizeof(Text_Lines), "How do you have access to such expidonsan weaponry {gold}%N{default}?",client);
		case WEAPON_WALDCH_SWORD_REAL:  Format(Text_Lines, sizeof(Text_Lines), "What? How did you get this elite blade {gold}%N{default}?",client);
		case WEAPON_NEARL:  Format(Text_Lines, sizeof(Text_Lines), "{gold}Silvester{default} decided to visit Kazimierz?");
		case WEAPON_KAHMLFIST:  Format(Text_Lines, sizeof(Text_Lines), "Kahmlstein caused enough problems as it is.");
		case WEAPON_KIT_BLITZKRIEG_CORE:  Format(Text_Lines, sizeof(Text_Lines), "This machine is gone now, use it better then it has {gold}%N{default}.",client);
		case WEAPON_IRENE:  Format(Text_Lines, sizeof(Text_Lines), "Iberia's Weapons!? Looks like the secret is out of the bag now...");
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "OH MY GOD, {snow}BOB THE FIRST{default} IS ON YOUR SIDE?!");
		case WEAPON_ANGELIC_SHOTGUN:  Format(Text_Lines, sizeof(Text_Lines), "Howd you get {lightblue}Nemal's{default} Weapon {gold}%N{default}?",client);
		case WEAPON_IMPACT_LANCE:  Format(Text_Lines, sizeof(Text_Lines), "The lance... the only weapon that was forged from both ruina and {gold}expidonsa{default}...");
		/*
		//uncomment on release
		case WEAPON_NECRO_WANDS:
		{
			Format(Text_Lines, sizeof(Text_Lines), "What is this, the dead, an imitation...? Is this a prank again{green} Spookmaster Bones{default}?");
		}
		*/
		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{blue}Sensal{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}
