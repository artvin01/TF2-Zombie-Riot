#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
	"weapons/fist_swing_crit.wav"
};
static const char g_MeleeHitSounds[][] = {
	"weapons/fist_hit_world1.wav",
	"weapons/fist_hit_world2.wav"
};
static const char g_AdaptiveArmorSounds[][] = {
	"weapons/fx/rics/ric1.wav",
	"weapons/fx/rics/ric2.wav",
	"weapons/fx/rics/ric3.wav",
	"weapons/fx/rics/ric4.wav",
	"weapons/fx/rics/ric5.wav"
};
static char g_BotArrivedSounds[][] = {
	"vo/heavy_specialcompleted03.mp3",
	"vo/heavy_specialcompleted02.mp3",
	"vo/heavy_specialcompleted05.mp3"
};
static char g_AngerSounds[][] = {
	"vo/heavy_revenge07.mp3",
	"vo/heavy_revenge14.mp3"
};
static char g_RushSounds[][] = {
	"vo/heavy_battlecry01.mp3",
	"vo/heavy_battlecry03.mp3",
	"vo/heavy_battlecry05.mp3"
};

static char g_RushHitSounds[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav",
	"weapons/demo_charge_hit_flesh1.wav",
	"weapons/demo_charge_hit_flesh2.wav",
	"weapons/demo_charge_hit_flesh3.wav"
};

static char g_ExplodSounds[][] = {
	"weapons/air_burster_explode1.wav",
	"weapons/air_burster_explode2.wav",
	"weapons/air_burster_explode3.wav"
};

static char g_PowerAttackSounds[] = "weapons/physcannon/energy_sing_explosion2.wav";
static char g_SuperJumpSound[] = "weapons/rocket_ll_shoot.wav";
static char g_AngerSoundsPassed[] = "vo/heavy_specialcompleted08.mp3";
static char g_StartAdaptiveArmorSounds[] = "vo/heavy_specialcompleted06.mp3";

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_KaboomSounds[] = "items/cart_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float Vs_DelayTime[MAXENTITIES];
static int Vs_Target[MAXENTITIES];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];

static float Delay_Attribute[MAXENTITIES];

static int I_cant_do_this_all_day[MAXENTITIES];
static int i_Huscarls_eye_particle[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool MyGundammmmmm[MAXENTITIES];

static float DMGTypeArmorDuration[MAXENTITIES];
static float GetArmor[MAXENTITIES];
static float BlastDMG[MAXENTITIES];
static float MagicDMG[MAXENTITIES];
static float BulletDMG[MAXENTITIES];
static bool BlastArmor[MAXENTITIES];
static bool MagicArmor[MAXENTITIES];
static bool BulletArmor[MAXENTITIES];

static float DynamicCharger[MAXENTITIES];
static float ExtraMovement[MAXENTITIES];
static bool Frozen_Player[MAXPLAYERS];

static int MechanizedProtector[MAXENTITIES][3];
static int LifeSupportDevice[MAXENTITIES][3];




static int OverrideOwner[MAXENTITIES];

static int gLaser1;
static int gRedPoint;
static int g_BeamIndex_heal;
static int g_HALO_Laser;

void Huscarls_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Huscarls");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_the_wall");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_huscarls_raid");
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
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_AdaptiveArmorSounds)); i++) { PrecacheSound(g_AdaptiveArmorSounds[i]); }
	for (int i = 0; i < (sizeof(g_RushSounds)); i++) { PrecacheSound(g_RushSounds[i]); }
	for (int i = 0; i < (sizeof(g_RushHitSounds)); i++) { PrecacheSound(g_RushHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngerSounds)); i++) { PrecacheSound(g_AngerSounds[i]); }
	for (int i = 0; i < (sizeof(g_BotArrivedSounds)); i++) { PrecacheSound(g_BotArrivedSounds[i]); }
	for (int i = 0; i < (sizeof(g_ExplodSounds)); i++) { PrecacheSound(g_ExplodSounds[i]); }
	PrecacheSound(g_PowerAttackSounds);
	PrecacheSound(g_SuperJumpSound);
	PrecacheSound(g_AngerSoundsPassed);
	PrecacheSound(g_StartAdaptiveArmorSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_KaboomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav", true);
	PrecacheSound("weapons/medi_shield_deploy.wav", true);
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheModel("models/player/heavy.mdl");
	PrecacheModel(LASERBEAM);
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
	PrecacheModel("models/props_mvm/mvm_player_shield.mdl", true);
	PrecacheModel("models/props_mvm/mvm_player_shield2.mdl", true);
	PrecacheSoundCustom("#zombiesurvival/victoria/huscarl_ost_new.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Huscarls(vecPos, vecAng, ally, data);
}

methodmap Huscarls < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPowerHitSound() 
	{
		EmitSoundToAll(g_PowerAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_PowerAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayTeleportSound(){
		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayKaboomSound()
	{
		EmitSoundToAll(g_KaboomSounds, this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_KaboomSounds, this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound()
	{
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayBotArrivedSound()
	{
		int sound = GetRandomInt(0, sizeof(g_BotArrivedSounds) - 1);
		EmitSoundToAll(g_BotArrivedSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_BotArrivedSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerPassedSound()
	{
		EmitSoundToAll(g_AngerSoundsPassed, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSoundsPassed, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRushSound()
	{
		int sound = GetRandomInt(0, sizeof(g_RushSounds) - 1);
		EmitSoundToAll(g_RushSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RushSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRushHitSound()
	{
		int sound = GetRandomInt(0, sizeof(g_RushHitSounds) - 1);
		EmitSoundToAll(g_RushHitSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RushHitSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayExplodSound()
	{
		EmitSoundToAll(g_ExplodSounds[GetRandomInt(0, sizeof(g_ExplodSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayShieldSound()
	{
		EmitSoundToAll("weapons/medi_shield_deploy.wav", this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAdaptiveArmorSound()
	{
		EmitSoundToAll(g_StartAdaptiveArmorSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_StartAdaptiveArmorSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySuperJumpSound()
	{
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SuperJumpSound, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flHuscarlsRushCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flHuscarlsRushDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flHuscarlsDeployEnergyShieldCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flHuscarlsDeployEnergyShieldDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flHuscarlsGroundSlamCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	
	public Huscarls(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Huscarls npc = view_as<Huscarls>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
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
		switch(Vs_Atomizer_To_Huscarls)
		{
			case 1:
			{
				npc.m_flMeleeArmor = 0.85;
				npc.m_flRangedArmor = 1.0;
			}
			case 2:
			{
				npc.m_flMeleeArmor = 1.0;
				npc.m_flRangedArmor = 0.85;
			}
			default:
			{
				npc.m_flMeleeArmor = 1.0;
				npc.m_flRangedArmor = 1.0;
			}
		}
		float gametime = GetGameTime();
		OverrideOwner[npc.index] = -1;
		bool CloneDo=false;
		static char countext[20][1024];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(!StrContains(countext[i], "support_ability"))CloneDo=true;
			int ownerdata = StringToInt(countext[i]);
			if(IsValidEntity(ownerdata)) OverrideOwner[npc.index] = ownerdata;
		}
		if(CloneDo)
		{
			func_NPCDeath[npc.index] = view_as<Function>(Clone_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Clone_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Clone_ClotThink);
		
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;

			npc.m_flHuscarlsRushCoolDown = gametime + 99.0;
			npc.m_flHuscarlsRushDuration = 0.0;
			npc.m_flHuscarlsAdaptiveArmorCoolDown = gametime + 99.0;
			npc.m_flHuscarlsAdaptiveArmorDuration = 0.0;
			npc.m_flHuscarlsDeployEnergyShieldCoolDown = gametime + 0.1;
			npc.m_flHuscarlsGroundSlamCoolDown = gametime + 99.0;
			npc.m_flHuscarlsDeployEnergyShieldDuration = 0.0;

			CPrintToChatAll("{lightblue}허스칼{default}: 이제 우리 빅토리아 정예 부대와 맞설 시간이다.");
		}
		else
		{
			RemoveAllDamageAddition();
			func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			//IDLE
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.StartPathing();
			npc.m_flSpeed = 330.0;
			Delay_Attribute[npc.index] = 0.0;
			YaWeFxxked[npc.index] = false;
			ParticleSpawned[npc.index] = false;
			MyGundammmmmm[npc.index] = false;
			npc.m_bFUCKYOU = false;
			npc.Anger = false;
			npc.m_fbRangedSpecialOn = false;
			I_cant_do_this_all_day[npc.index] = 0;
			DMGTypeArmorDuration[npc.index] = 0.0;
			GetArmor[npc.index] = 0.0;
			BlastDMG[npc.index] = 0.0;
			MagicDMG[npc.index] = 0.0;
			BulletDMG[npc.index] = 0.0;
			BlastArmor[npc.index] = false;
			MagicArmor[npc.index] = false;
			BulletArmor[npc.index] = false;
			DynamicCharger[npc.index] = 0.0;
			ExtraMovement[npc.index] = 0.0;
			npc.i_GunMode = 0;
			npc.m_flHuscarlsRushCoolDown = gametime + 11.0;
			npc.m_flHuscarlsRushDuration = 0.0;
			npc.m_flHuscarlsAdaptiveArmorCoolDown = gametime + 30.0;
			npc.m_flHuscarlsAdaptiveArmorDuration = 0.0;
			npc.m_flHuscarlsDeployEnergyShieldCoolDown = gametime + 15.0;
			npc.m_flHuscarlsGroundSlamCoolDown = gametime + 10.0;
			npc.m_flHuscarlsDeployEnergyShieldDuration = 0.0;
			Vs_RechargeTimeMax[npc.index] = 15.0;
			Victoria_Support_RechargeTimeMax(npc.index, 15.0);

			Zero(b_said_player_weaponline);
			fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
			
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			b_thisNpcIsARaid[npc.index] = true;
			b_angered_twice[npc.index] = false;
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "Huscarls Arrived");
					Frozen_Player[client_check]=false;
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;

			if(StrContains(data, "nomusic") == -1)
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/huscarl_ost_new.mp3");
				music.Time = 232;
				music.Volume = 1.7;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Unstoppable Force");
				strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
				Music_SetRaidMusic(music);
			}
			
			npc.m_iChanged_WalkCycle = -1;

			CPrintToChatAll("{lightblue}허스칼{default}: 이 ''강철 게이트''를 지나갈 생각 마라! ");
			
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
			
			float amount_of_people = float(CountPlayersOnRed());
			if(amount_of_people > 12.0)
			{
				amount_of_people = 12.0;
			}
			amount_of_people *= 0.12;
			
			if(amount_of_people < 1.0)
				amount_of_people = 1.0;

			RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
			
		}
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;


		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_sr3_punch/c_sr3_punch.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sbox2014_heavy_camopants/sbox2014_heavy_camopants.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/heavy/sept2014_unshaved_bear/sept2014_unshaved_bear.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/fall17_nuke/fall17_nuke_heavy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl");
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

static void Clone_ClotThink(int iNPC)
{
	Huscarls npc = view_as<Huscarls>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	switch(I_cant_do_this_all_day[npc.index])
	{
		case 0:
		{
			npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
			npc.m_flAttackHappens = 0.0;
			npc.SetCycle(0.5);
			npc.SetPlaybackRate(1.0);
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flDoingAnimation = gameTime + 1.0;
			Delay_Attribute[npc.index] = gameTime + 1.1;
			I_cant_do_this_all_day[npc.index] = 1;
		}
		case 1:
		{
			if(Delay_Attribute[npc.index] < gameTime)
			{
				I_cant_do_this_all_day[npc.index] = 0;
				npc.PlayShieldSound();
				if(IsValidEntity(OverrideOwner[npc.index]))
				{
					Huscarls npcGetInfo = view_as<Huscarls>(OverrideOwner[npc.index]);
					Fire_Shield_Projectile(npcGetInfo, 10.0);
				}
				else Fire_Shield_Projectile(npc, 10.0);
				
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				npc.PlayDeathSound();
				
				b_NpcForcepowerupspawn[npc.index] = 0;
				i_RaidGrantExtra[npc.index] = 0;
				b_DissapearOnDeath[npc.index] = true;
				b_DoGibThisNpc[npc.index] = true;
				SmiteNpcToDeath(npc.index);
			}
		}	
	}
}

static Action Clone_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Handled;
}

static void Clone_NPCDeath(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);

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
}

static void Internal_ClotThink(int iNPC)
{
	Huscarls npc = view_as<Huscarls>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	GrantEntityArmor(iNPC, true, 0.05, 0.5, 0);

	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Huscarls_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}
	bool GETVictoria_Support=false;
	if(npc.Anger && npc.m_fbRangedSpecialOn && !MyGundammmmmm[npc.index] && Victoria_Support(npc))
		GETVictoria_Support=true;
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0, 2))
			{
				case 0:CPrintToChatAll("{lightblue}허스칼{default}: 이 곳이 네 무덤이 될 것이다.");
				case 1:CPrintToChatAll("{lightblue}허스칼{default}: 너무 쉽군.");
				case 2:CPrintToChatAll("{lightblue}허스칼{default}: 넌 {gold}빅토리아{default}에 발조차 들이지 못 할 것이다.");
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		DeleteAndRemoveAllNpcs = 3.0;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("layer_taunt_crushing_headache");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		BlockLoseSay = true;
		
		CPrintToChatAll("{lightblue}허스칼{default}: 임무 완료. 이제 저 놈들 뒤에 누가 있는지 확인해보자고.");
		return;
	}
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index])
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		npc.m_flMeleeArmor = 0.33;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.5);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(0, 1))
		{
			case 0:CPrintToChatAll("{lightblue}허스칼{default}: 좋아. 지겹군. {crimson}끝낼 시간이다.{default}");
			case 1:CPrintToChatAll("{lightblue}허스칼{default}: {blue}인수분해{default}, 네가 놓친 침입자 처리는 이제 끝났다. 자네가 맥주 한 잔 사줘.");
			//case 2:CPrintToChatAll("{lightblue}허스칼{default}: {blue}해리슨{default}, 상황은 종료됐다. 이제 돌아가자.");
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		for(int i; i<8; i++)
		{
			int spawn_index = NPC_CreateByName("npc_avangard", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), "only");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 3.0);
				fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index]+2.0;
				fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index]+10.0;
				if(GetTeam(iNPC) != TFTeam_Red)
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
				i_AttacksTillMegahit[spawn_index] = 600;
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
				int Decicion = TeleportDiversioToRandLocation(spawn_index,_,1250.0, 500.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 250.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 0.0);
			}
		}
		npc.PlayTeleportSound();
		BlockLoseSay = true;
		YaWeFxxked[npc.index] = true;
	}
	if(YaWeFxxked[npc.index])
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == GetTeam(npc.index))
				ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.3);
		}
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		//npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_flArmorCount > 0.0)
	{
		float percentageArmorLeft = npc.m_flArmorCount / npc.m_flArmorCountMax;

		if(percentageArmorLeft <= 0.0)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
		}
		if(percentageArmorLeft > 0.0)
		{
			if(!IsValidEntity(npc.m_iWearable1))
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
	}
	
	if(npc.m_bFUCKYOU)
	{
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}허스칼{default}: 플랜 B, {gold}메카니스트{default}. 로봇들을 이 곳으로 전부 불러와라!");
				npc.AddActivityViaSequence("tauntrussian_rubdown");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 0.5;
				Delay_Attribute[npc.index] = gameTime + 0.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1, 2, 3:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.SetPlaybackRate(0.0);
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					int spawn_index = NPC_CreateByName("npc_avangard", -1, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), "only");
					if(spawn_index > MaxClients)
					{
						NpcStats_CopyStats(npc.index, spawn_index);
						int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.15);
						fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
						fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
						fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
						fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
						if(GetTeam(iNPC) != TFTeam_Red)
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
						i_AttacksTillMegahit[spawn_index] = 600;
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
						LifeSupportDevice[npc.index][I_cant_do_this_all_day[npc.index]-1] = spawn_index;
						MechanizedProtector[npc.index][I_cant_do_this_all_day[npc.index]-1] = EntIndexToEntRef(ConnectWithBeam(npc.index, spawn_index, 255, 215, 0, 3.0, 3.0, 1.35, LASERBEAM));
						int Decicion = TeleportDiversioToRandLocation(spawn_index,_,2500.0, 1750.0);

						if(Decicion == 2)
							Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1750.0, 500.0);

						if(Decicion == 2)
							Decicion = TeleportDiversioToRandLocation(spawn_index, _, 500.0, 0.0);

						npc.PlayTeleportSound();
					}
					for(int i = 0; i < (sizeof(LifeSupportDevice[])); i++)
					{
						if(IsValidEntity(LifeSupportDevice[npc.index][i])&& i_NpcInternalId[LifeSupportDevice[npc.index][i]] == VictorianAvangard_ID()
						&& !b_NpcHasDied[LifeSupportDevice[npc.index][i]] && GetTeam(LifeSupportDevice[npc.index][i]) == GetTeam(npc.index))
						{
							FreezeNpcInTime(LifeSupportDevice[npc.index][i], 1.6, true);
							IncreaseEntityDamageTakenBy(LifeSupportDevice[npc.index][i], 0.000001, 1.6);
						}
					}
					Delay_Attribute[npc.index] = gameTime + 1.5;
					I_cant_do_this_all_day[npc.index]++;
				}
			}
			case 4:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("tauntrussian_rubdown_outro");
					npc.SetPlaybackRate(1.0);
					Delay_Attribute[npc.index] = gameTime + 1.5;
					I_cant_do_this_all_day[npc.index]=5;
					for(int i = 0; i < (sizeof(LifeSupportDevice[])); i++)
					{
						if(IsValidEntity(LifeSupportDevice[npc.index][i])&& i_NpcInternalId[LifeSupportDevice[npc.index][i]] == VictorianAvangard_ID()
						&& !b_NpcHasDied[LifeSupportDevice[npc.index][i]] && GetTeam(LifeSupportDevice[npc.index][i]) == GetTeam(npc.index))
						{
							FreezeNpcInTime(LifeSupportDevice[npc.index][i], 1.6, true);
							IncreaseEntityDamageTakenBy(LifeSupportDevice[npc.index][i], 0.000001, 1.6);
						}
					}
				}
			}
			case 5:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					EmitSoundToAll("mvm/mvm_tank_horn.wav", _, _, _, _, 1.0);
					npc.PlayBotArrivedSound();
					npc.m_flHuscarlsRushCoolDown += 1.0;
					npc.m_flHuscarlsAdaptiveArmorCoolDown += 1.0;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown += 1.0;
					npc.m_flHuscarlsGroundSlamCoolDown += 1.0;
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_bFUCKYOU=false;
				}
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		return;
	}
	
	if(npc.Anger && !npc.m_fbRangedSpecialOn)
	{
		bool StillAlive=false;
		for(int i = 0; i < (sizeof(LifeSupportDevice[])); i++)
		{
			if(IsValidEntity(LifeSupportDevice[npc.index][i])&& i_NpcInternalId[LifeSupportDevice[npc.index][i]] == VictorianAvangard_ID()
				&& !b_NpcHasDied[LifeSupportDevice[npc.index][i]] && GetTeam(LifeSupportDevice[npc.index][i]) == GetTeam(npc.index))
				StillAlive=true;
			else
			{
				if(IsValidEntity(MechanizedProtector[npc.index][i]))
					RemoveEntity(MechanizedProtector[npc.index][i]);
			}
		}
		if(!StillAlive)
		{
			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health+RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.1));
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)+RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.25));
			if((RaidModeTime - GetGameTime()) < 60.0)
				RaidModeTime = gameTime + 60.0;
			RaidModeTime += 20.0;
			npc.m_fbRangedSpecialOn = true;
			npc.m_flHuscarlsRushCoolDown += 3.0;
			npc.m_flHuscarlsAdaptiveArmorCoolDown += 3.0;
			npc.m_flHuscarlsDeployEnergyShieldCoolDown += 3.0;
			npc.m_flHuscarlsGroundSlamCoolDown += 3.0;
			I_cant_do_this_all_day[npc.index]=0;
			MyGundammmmmm[npc.index] = true;
		}
	}
	if(npc.Anger && npc.m_fbRangedSpecialOn)
	{
		if(MyGundammmmmm[npc.index])
		{
			switch(I_cant_do_this_all_day[npc.index])
			{
				case 0:
				{
					npc.PlayAngerSound();
					switch(GetRandomInt(0, 1))
					{
						case 0:CPrintToChatAll("{lightblue}허스칼{default}: 망할 깡통들 같으니. 저렇게나 쉽게 무너져내린단 말인가.");
						case 1:CPrintToChatAll("{lightblue}허스칼{default}: 성능 문제를 미리 알아차렸어야 했는데...");
					}
					npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.6);
					npc.SetPlaybackRate(1.2);
					npc.m_flDoingAnimation = gameTime + 1.0;
					Delay_Attribute[npc.index] = gameTime + 1.8;
					I_cant_do_this_all_day[npc.index] = 1;
				}
				case 1:
				{
					if(Delay_Attribute[npc.index] < gameTime)
					{
						b_NpcIsInvulnerable[npc.index] = false;
						ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
						MyGundammmmmm[npc.index]=false;
						I_cant_do_this_all_day[npc.index] = 0;
					}
				}
			}
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flHuscarlsRushCoolDown += 0.1;
			npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
			npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
			npc.m_flDoingAnimation = gameTime + 0.1;
			return;
		}
		else if(GETVictoria_Support)
		{
		
		}
	}
	
	npc.m_flSpeed = 330.0+ExtraMovement[npc.index];

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(HuscarlsSelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget))
		{
			case 0:
			{
				npc.StartPathing();
				
				npc.m_bisWalking = true;
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
				npc.StartPathing();
				
				npc.m_bisWalking = true;
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
			case 2:
			{
				npc.StopPathing();
				
				npc.m_bisWalking = false;
			}
			case 3:
			{
				npc.StartPathing();
				
				npc.m_bisWalking = true;
				npc.m_bAllowBackWalking = false;
				static float vOrigin[3], vAngles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				vAngles[0]=5.0;
				EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
				npc.SetGoalVector(vOrigin);
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
		HuscarlsAnimationChange(npc);
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Huscarls npc = view_as<Huscarls>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flArmorCount <= 0.0)
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}		
	}
	
	bool hot;
	bool magic;
	bool pierce;

	if((damagetype & DMG_TRUEDAMAGE))
	{
		pierce = true;
	}
	else
	{
		if((damagetype & DMG_BLAST))
		{
			hot = true;
			pierce = true;
		}
		
		if(damagetype & DMG_PLASMA)
		{
			magic = true;
			pierce = true;
		}
		else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[npc.index] & ZR_DAMAGE_LASER_NO_BLAST))
		{
			magic = true;
		}
	}
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	if(GetArmor[npc.index]>=float(maxhealth)*0.25)
	{
		BlastArmor[npc.index] = false;
		MagicArmor[npc.index] = false;
		BulletArmor[npc.index] = false;
		switch(Huscarls_Get_HighDMGType(npc.index))
		{
			case 0: BlastArmor[npc.index]=true;
			case 1:	MagicArmor[npc.index]=true;
			default:BulletArmor[npc.index]=true;
		}
		GrantEntityArmor(npc.index, false, 0.075, 0.5, 0);
		DMGTypeArmorDuration[npc.index] = gameTime + 30.0;
		GetArmor[npc.index] = 0.0;
		BlastDMG[npc.index] = 0.0;
		MagicDMG[npc.index] = 0.0;
		BulletDMG[npc.index] = 0.0;
	}
	else
	{
		if(DMGTypeArmorDuration[npc.index] < gameTime)
		{
			BlastArmor[npc.index] = false;
			MagicArmor[npc.index] = false;
			BulletArmor[npc.index] = false;
		}
		if(hot)
		{
			if(BlastArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_blast_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			BlastDMG[npc.index] += damage;
		}
		if(magic)
		{
			if(MagicArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_fire_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			MagicDMG[npc.index] += damage;
		}
		if(!pierce)
		{
			if(BulletArmor[npc.index])
			{
				damage *= 0.75;
				damagePosition[2] += 65.0;
				npc.DispatchParticleEffect(npc.index, "medic_resist_match_bullet_blue", damagePosition, NULL_VECTOR, NULL_VECTOR);
				damagePosition[2] -= 65.0;
			}
			BulletDMG[npc.index] += damage;
		}
		GetArmor[npc.index] += damage;
	}
	
	if(npc.m_flHuscarlsAdaptiveArmorDuration > gameTime)
	{
		DynamicCharger[npc.index] += damage;
		if(IsValidClient(attacker))
			EmitSoundToClient(attacker, g_AdaptiveArmorSounds[GetRandomInt(0, sizeof(g_AdaptiveArmorSounds) - 1)], _, _, _, _, 0.7, _, _, _, _, false);
		if(IsValidEntity(npc.m_iWearable2))
		{
			ExtinguishTarget(npc.m_iWearable2);
			IgniteTargetEffect(npc.m_iWearable2);
		}
	}
	
	Huscarls_Weapon_Lines(npc, attacker);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.33 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.Anger)
		{
			I_cant_do_this_all_day[npc.index]=0;
			npc.m_bFUCKYOU=true;
			b_NpcIsInvulnerable[npc.index] = true;
			npc.Anger = true;
		}
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	Vs_RechargeTime[npc.index]=0.0;
	Vs_RechargeTimeMax[npc.index]=0.0;
	
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

	int particle = EntRefToEntIndex(i_Huscarls_eye_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_Huscarls_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client))
			Vs_LockOn[client]=false;
	}
	
	for(int i = 0; i < (sizeof(LifeSupportDevice[])); i++)
	{
		if(IsValidEntity(LifeSupportDevice[npc.index][i])&& i_NpcInternalId[LifeSupportDevice[npc.index][i]] == VictorianAvangard_ID()
			&& !b_NpcHasDied[LifeSupportDevice[npc.index][i]] && GetTeam(LifeSupportDevice[npc.index][i]) == GetTeam(npc.index))
		{
			b_NpcForcepowerupspawn[LifeSupportDevice[npc.index][i]] = 0;
			i_RaidGrantExtra[LifeSupportDevice[npc.index][i]] = 0;
			b_DissapearOnDeath[LifeSupportDevice[npc.index][i]] = true;
			b_DoGibThisNpc[LifeSupportDevice[npc.index][i]] = true;
			SmiteNpcToDeath(LifeSupportDevice[npc.index][i]);
		}
		if(IsValidEntity(MechanizedProtector[npc.index][i]))
			RemoveEntity(MechanizedProtector[npc.index][i]);
	}
	for(int client_check=1; client_check<=MaxClients; client_check++)
	{
		if(IsValidClient(client_check) && Frozen_Player[client_check])
		{
			TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
			TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
			SetEntityCollisionGroup(client_check, 5);
			Frozen_Player[client_check]=false;
		}
	}
	if(BlockLoseSay)
		return;
	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{lightblue}허스칼{default}: 후퇴! 이건 전략적 후퇴다!.");
		case 1:CPrintToChatAll("{lightblue}허스칼{default}: 여기 {gold}빅토리아{default}에 문제가 발생했다! 지원을 더 요청한다!");
		case 2:CPrintToChatAll("{lightblue}허스칼{default}: 다음엔 네 놈을 꼭 {crimson}박살내주마{default}!");
	}
	npc.PlayDeathSound();	
}

void HuscarlsAnimationChange(Huscarls npc)
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
				// ResetHuscarlsWeapon(npc, 1);
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
				//	ResetHuscarlsWeapon(npc, 1);
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
				//	ResetHuscarlsWeapon(npc, 0);
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
				//	ResetHuscarlsWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}
}

int HuscarlsSelfDefense(Huscarls npc, float gameTime, int target, float distance)
{
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(npc.m_flHuscarlsAdaptiveArmorCoolDown < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}허스칼{default}: 쳐 보라고. 어디 해봐.");
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_unleashed_rage_heavy");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 3.4;
				Delay_Attribute[npc.index] = gameTime + 1.2;
				I_cant_do_this_all_day[npc.index] = 1;
				npc.PlayAdaptiveArmorSound();
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					DynamicCharger[npc.index] = 0.0;
					if(b_NpcIsInvulnerable[npc.index])
					{
						if(IsValidEntity(npc.m_iWearable2))
						{
							ExtinguishTarget(npc.m_iWearable2);
							IgniteTargetEffect(npc.m_iWearable2);
						}
						DynamicCharger[npc.index]+=2000.0;
					}
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						if(IsValidEntity(npc.m_iWearable2))
						{
							ExtinguishTarget(npc.m_iWearable2);
							IgniteTargetEffect(npc.m_iWearable2);
						}
						DynamicCharger[npc.index]+=1500.0;
					}
					npc.m_flHuscarlsAdaptiveArmorDuration = gameTime + 3.0;
					I_cant_do_this_all_day[npc.index] = 2;
				}
			}
			case 2:
			{
				if(npc.m_flHuscarlsAdaptiveArmorDuration < gameTime)
				{
					CPrintToChatAll("{lightblue}허스칼{default}: 더 가까이 와봐라. 받은 만큼 돌려줘야하니까.");
					int maxhealth = ReturnEntityMaxHealth(npc.index);
					float MAXCharger = (DynamicCharger[npc.index]/(float(maxhealth)*0.05))*0.05;
					if(MAXCharger > 0.05)MAXCharger = 0.05;
					GrantEntityArmor(npc.index, false, MAXCharger, 0.5, 0);
					I_cant_do_this_all_day[npc.index] = 3;
				}
				else
				{
					npc.m_flHuscarlsRushCoolDown += 3.0;
					npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 15.0;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown += 3.0;
					npc.m_flHuscarlsGroundSlamCoolDown += 3.0;
					I_cant_do_this_all_day[npc.index] = 0;
				}
			}
			case 3:
			{
				npc.m_flHuscarlsRushCoolDown += 3.0;
				npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 30.0;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 3.0;
				npc.m_flHuscarlsGroundSlamCoolDown += 3.0;
				I_cant_do_this_all_day[npc.index] = 0;
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		return 2;
	}
	else if(npc.m_flHuscarlsGroundSlamCoolDown < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.AddActivityViaSequence("layer_taunt_yeti_prop");
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.9);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.0;
				Delay_Attribute[npc.index] = gameTime + 0.6;
				I_cant_do_this_all_day[npc.index] = 1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					float SlamDMG = 50.0;
					float Range = 400.0;
					ParticleEffectAt(WorldSpaceVec, "mvm_soldier_shockwave", 1.0);
					ParticleEffectAt(WorldSpaceVec, "ExplosionCore_MidAir", 1.0);
					CreateEarthquake(WorldSpaceVec, 1.0, Range * 1.25, 16.0, 255.0);
					Explode_Logic_Custom(SlamDMG * RaidModeScaling, 0, npc.index, -1, _, Range, 1.0, 0.75, true, 20, _, _, Ground_Slam);
					I_cant_do_this_all_day[npc.index] = 0;
					Delay_Attribute[npc.index] = gameTime + 0.2;
					if(NpcStats_VictorianCallToArms(npc.index))
						npc.m_flHuscarlsGroundSlamCoolDown = gameTime + 20.0;
					else
						npc.m_flHuscarlsGroundSlamCoolDown = gameTime + 25.0;
					npc.PlayKaboomSound();
				}
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		return 2;
	}
	else if(npc.m_flHuscarlsRushCoolDown < gameTime)
	{
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.0;
				Delay_Attribute[npc.index] = gameTime + 1.1;
				I_cant_do_this_all_day[npc.index] = 1;
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					ExtraMovement[npc.index] = 300.0;
					npc.m_flHuscarlsRushDuration = gameTime + 5.0;
					I_cant_do_this_all_day[npc.index] = 2;
					Delay_Attribute[npc.index] = gameTime + 0.2;
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 200.0, _, _, true, _, false, _, NPC_Go_away);
					npc.PlayRushSound();
				}
			}
			case 2:
			{
				static float vOrigin[3], vAngles[3], tOrigin[3];
				WorldSpaceCenter(npc.index, vOrigin);
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				EntityLookPoint(npc.index, vAngles, vOrigin, tOrigin);
				float Tdistance = GetVectorDistance(vOrigin, tOrigin);
				if(Tdistance<125.0)
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
					for(int client_check=1; client_check<=MaxClients; client_check++)
					{
						if(IsValidClient(client_check) && Frozen_Player[client_check])
						{
							TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
							TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
							SetEntityCollisionGroup(client_check, 5);
							Frozen_Player[client_check]=false;
						}
					}
					npc.m_flDoingAnimation = gameTime + 0.25;
					Delay_Attribute[npc.index] = gameTime + 0.75;
					I_cant_do_this_all_day[npc.index] = 5;
					CreateEarthquake(vOrigin, 0.5, 350.0, 16.0, 255.0);
					npc.PlayRushHitSound();
					return 2;
				}
				else if(npc.m_flHuscarlsRushDuration < gameTime)
				{
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
						npc.StopPathing();
						
						npc.m_bisWalking = false;
						npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");
						npc.m_flAttackHappens = 0.0;
						npc.SetCycle(0.01);
						npc.SetPlaybackRate(1.0);
						npc.m_flDoingAnimation = gameTime + 1.0;
						npc.m_iChanged_WalkCycle = 0;
						
						float flPos[3];
						float flAng[3];
						int Particle_1;
						int Particle_2;
						npc.GetAttachment("foot_L", flPos, flAng);
						Particle_1 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
						npc.GetAttachment("foot_R", flPos, flAng);
						Particle_2 = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
						CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_1), TIMER_FLAG_NO_MAPCHANGE);
						CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle_2), TIMER_FLAG_NO_MAPCHANGE);
						
						static float flMyPos_2[3];
						flMyPos[2] += 800.0;
						WorldSpaceCenter(target, flMyPos_2);

						flMyPos[0] = flMyPos_2[0];
						flMyPos[1] = flMyPos_2[1];
						PluginBot_Jump(npc.index, flMyPos);
						ParticleEffectAt(vOrigin, "mvm_soldier_shockwave", 1.0);
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, ToTheMoon);
						SetEntityCollisionGroup(npc.index, 1);
						npc.PlaySuperJumpSound();
						I_cant_do_this_all_day[npc.index] = 3;
					}
					else
					{
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
						for(int client_check=1; client_check<=MaxClients; client_check++)
						{
							if(IsValidClient(client_check) && Frozen_Player[client_check])
							{
								TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
								TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
								SetEntityCollisionGroup(client_check, 5);
								Frozen_Player[client_check]=false;
							}
						}
						npc.m_flDoingAnimation = gameTime + 0.25;
						Delay_Attribute[npc.index] = gameTime + 0.75;
						I_cant_do_this_all_day[npc.index] = 5;
						CreateEarthquake(vOrigin, 0.5, 350.0, 16.0, 255.0);
					}
				}
				else
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Got_it_fucking_shit);
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 200.0, _, _, true, _, false, _, NPC_Go_away);
					if(Delay_Attribute[npc.index] < gameTime)
						npc.AddGesture("PASSTIME_throw_middle");
					Delay_Attribute[npc.index] = gameTime + 1.0;
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
					npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
					return 3;
				}
			}
			case 3:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");	
					npc.SetCycle(0.85);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.25;
					Delay_Attribute[npc.index] = gameTime + 0.75;
					npc.m_iChanged_WalkCycle = 0;
					I_cant_do_this_all_day[npc.index] = 4;
				}
			}
			case 4:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 400.0, _, _, true, _, false, _, Ground_pound);
					npc.PlayExplodSound();
					npc.SetVelocity({0.0,0.0,-1500.0});
					Delay_Attribute[npc.index] = gameTime + 1.0;
					I_cant_do_this_all_day[npc.index] = 5;
					static float vOrigin[3], vAngles[3], tOrigin[3];
					WorldSpaceCenter(npc.index, vOrigin);
					ParticleEffectAt(vOrigin, "mvm_soldier_shockwave", 1.0);
					
					vAngles[0]=90.0;
					EntityLookPoint(npc.index, vAngles, vOrigin, tOrigin);
					CreateEarthquake(tOrigin, 0.5, 350.0, 16.0, 255.0);
				}
			}
			case 5:
			{
				SetEntityCollisionGroup(npc.index, 5);
				npc.SetPlaybackRate(1.0);
				for(int client_check=1; client_check<=MaxClients; client_check++)
				{
					if(IsValidClient(client_check) && Frozen_Player[client_check])
					{
						TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
						TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
						SetEntityCollisionGroup(client_check, 5);
						Frozen_Player[client_check]=false;
					}
				}
				if(Delay_Attribute[npc.index] < gameTime)
					I_cant_do_this_all_day[npc.index] = 6;
			}
			case 6:
			{
				npc.m_flHuscarlsRushCoolDown = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 14.0 : 15.0);
				npc.m_flHuscarlsRushCoolDown = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 14.0 : 15.0);
				npc.m_flHuscarlsAdaptiveArmorCoolDown += 6.0;
				npc.m_flHuscarlsGroundSlamCoolDown += 6.0;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 1.0;
				I_cant_do_this_all_day[npc.index] = 0;
				ExtraMovement[npc.index] = 0.0;
			}
		}
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		return 2;
	}
	else if(npc.m_flHuscarlsDeployEnergyShieldCoolDown < gameTime)
	{
		//npc.AddGesture("gesture_MELEE_cheer");
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
		npc.m_flDoingAnimation = gameTime + 1.0;
		npc.PlayShieldSound();
		Fire_Shield_Projectile(npc, 10.0);
		npc.m_flHuscarlsRushCoolDown += 1.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 1.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 1.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown = gameTime + 21.0;
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
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
				bool PlaySound = false, PlayPOWERSound = false;
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
							float damagebasic = 50.0;
							float damage = damagebasic;
							if(DynamicCharger[npc.index]>0.0 && npc.m_flHuscarlsAdaptiveArmorDuration < gameTime)
							{
								damage+=DynamicCharger[npc.index];
								if(damage>damagebasic*5.0)damage=damagebasic*5.0;
								DynamicCharger[npc.index]=0.0;
								ExtinguishTarget(npc.m_iWearable2);
								CreateEarthquake(VecEnemy, 0.5, 350.0, 16.0, 255.0);
								PlayPOWERSound = true;
							}
							if(ShouldNpcDealBonusDamage(target))
								damage *= 7.0;

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if(IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 300.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
								else
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
									}
								}
							}
							if(!Knocked)
								Custom_Knockback(npc.index, targetTrace, 150.0, true); 
						} 
					}
				}
				if(PlaySound)
					npc.PlayMeleeHitSound();
				if(PlayPOWERSound)
				{
					ParticleEffectAt(VecEnemy, "rd_robot_explosion", 1.0);
					npc.PlayPowerHitSound();
				}
			}
		}
	}
	else if(gameTime > npc.m_flNextMeleeAttack)
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
					npc.m_flNextMeleeAttack = gameTime + 1.5;
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

static void Got_it_fucking_shit(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim) && Can_I_See_Enemy(npc.index, victim))
	{
		if(IsValidClient(victim))
		{
			float flPos[3]; WorldSpaceCenter(entity, flPos);
		
			TeleportEntity(victim, flPos, NULL_VECTOR, {0.0,0.0,0.0});
			TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
			TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
			SetEntityCollisionGroup(victim, 1);
			Frozen_Player[victim]=true;
		}
	}
}
static void NPC_Go_away(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && !IsValidClient(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		SDKHooks_TakeDamage(victim, npc.index, npc.index, 1000.0, DMG_TRUEDAMAGE, -1, _, vecHit);
		Custom_Knockback(npc.index, victim, 1500.0, true);
	}
}

static void Compressor(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		damage = 50.0 * RaidModeScaling;
		damage += ReturnEntityMaxHealth(victim)*0.25;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
		if(IsValidClient(victim))
		{
			TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
			TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
		}
		else FreezeNpcInTime(victim, 1.0, true);
		Custom_Knockback(npc.index, victim, 1500.0, true);
	}
}

static void ToTheMoon(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		damage = 40.0 * RaidModeScaling;
		damage += ReturnEntityMaxHealth(victim)*0.05;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
		float fVelocity[3];
		fVelocity[2] = 1000.0;
		if(IsValidClient(victim))
		{
			TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 2.0, 0);
			TF2_AddCondition(victim, TFCond_CompetitiveLoser, 2.0, 0);
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fVelocity);
		}
		else
		{
			PluginBot_Jump(victim, fVelocity);
			FreezeNpcInTime(victim, 1.0, true);
		}
	}
}

static void Ground_pound(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		damage = 40.0 * RaidModeScaling;
		damage += ReturnEntityMaxHealth(victim)*0.05;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
		float fVelocity[3];
		fVelocity[2] = -2000.0;
		if(IsValidClient(victim))
		{
			TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 1.0, 0);
			TF2_AddCondition(victim, TFCond_CompetitiveLoser, 1.0, 0);
		}
		else FreezeNpcInTime(victim, 1.0, true);
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, fVelocity);
	}
}

static void Ground_Slam(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(entity) != GetTeam(victim))
	{
		if(IsValidClient(victim))
		{
			TF2_AddCondition(victim, TFCond_HalloweenKartNoTurn, 0.2, 0);
			TF2_AddCondition(victim, TFCond_CompetitiveLoser, 0.2, 0);
			TF2_AddCondition(victim, TFCond_LostFooting, 1.0);
			TF2_AddCondition(victim, TFCond_AirCurrent, 1.0);
		}
		else FreezeNpcInTime(victim, 0.2, true);
		if(!IsInvuln(victim))
		{
			if(IsValidClient(victim))
				if(!HasSpecificBuff(victim, "Fluid Movement"))
					TF2_StunPlayer(victim, 0.2, 0.8, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);
			Custom_Knockback(entity, victim, 70.0, true);
		}
		else Custom_Knockback(entity, victim, 140.0, true);
	}
}

static int Huscarls_Get_HighDMGType(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);
	int DMGType;
	float HighDMG;
	float LowDMG;
	for(int i = 0; i <= 2; i++)
	{
		switch(i)
		{
			case 0:	LowDMG=BlastDMG[npc.index];
			case 1:	LowDMG=MagicDMG[npc.index];
			default: LowDMG=BulletDMG[npc.index];
		}
		if(HighDMG)
		{
			if(LowDMG > HighDMG)
			{
				DMGType = i;
				HighDMG = LowDMG;			
			}
		}
		else
		{
			DMGType = i;
			HighDMG = LowDMG;
		}
	}
	return DMGType;
}

static bool Victoria_Support(Huscarls npc)
{
	float GameTime = GetGameTime(npc.index);
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;
	Vs_DelayTime[npc.index] = GameTime + 0.1;
	
	Vs_Target[npc.index] = Victoria_GetTargetDistance(npc.index, true, false);
	if(!IsValidEnemy(npc.index, Vs_Target[npc.index]))
		return false;
	if(Vs_RechargeTime[npc.index] >= 1.0 && Vs_RechargeTime[npc.index] <= 3.0 && IsValidEntity(Vs_ParticleSpawned[npc.index]))
		RemoveEntity(Vs_ParticleSpawned[npc.index]);
	Vs_RechargeTime[npc.index] += 0.1;
	if(Vs_RechargeTime[npc.index]>(Vs_RechargeTimeMax[npc.index]+1.0))
		Vs_RechargeTime[npc.index]=0.0;
	
	float vecTarget[3];
	GetEntPropVector(Vs_Target[npc.index], Prop_Data, "m_vecAbsOrigin", vecTarget);
	vecTarget[2] += 5.0;
	
	if(Vs_RechargeTime[npc.index] < Vs_RechargeTimeMax[npc.index])
	{
		float position[3];
		position[0] = vecTarget[0];
		position[1] = vecTarget[1];
		position[2] = vecTarget[2] + 3000.0;
		if(Vs_RechargeTime[npc.index] < (Vs_RechargeTimeMax[npc.index] - 3.0))
		{
			Vs_Temp_Pos[npc.index][0] = position[0];
			Vs_Temp_Pos[npc.index][1] = position[1];
			Vs_Temp_Pos[npc.index][2] = position[2] - 3000.0;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client) && !IsFakeClient(client))
					Vs_LockOn[client]=false;
			}
			Vs_LockOn[Vs_Target[npc.index]]=true;
		}
		else
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client) && !IsFakeClient(client))
					Vs_LockOn[client]=false;
			}
		}
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0), (1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0))+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {255, 255, 255, 150}, 0, 0);
		TE_SendToAll();
		float position2[3];
		position2[0] = Vs_Temp_Pos[npc.index][0];
		position2[1] = Vs_Temp_Pos[npc.index][1];
		position2[2] = Vs_Temp_Pos[npc.index][2] + 65.0;
		TE_SetupBeamRingPoint(position2, 1000.0, 1000.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 1000.0, 1000.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamPoints(Vs_Temp_Pos[npc.index], position, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {145, 47, 47, 150}, 3);
		TE_SendToAll();
		TE_SetupGlowSprite(Vs_Temp_Pos[npc.index], gRedPoint, 0.1, 1.0, 255);
		TE_SendToAll();
		if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0) && !IsValidEntity(Vs_ParticleSpawned[npc.index]))
		{
			position[0] = 525.0;
			position[1] = 1600.0;
			Vs_ParticleSpawned[npc.index] = EntIndexToEntRef(ParticleEffectAt(position, "kartimpacttrail", 2.0));
			SetEdictFlags(Vs_ParticleSpawned[npc.index], (GetEdictFlags(Vs_ParticleSpawned[npc.index]) | FL_EDICT_ALWAYS));
			SetEntProp(Vs_ParticleSpawned[npc.index], Prop_Data, "m_iHammerID", npc.index);
			npc.PlayIncomingBoomSound();
		}
	}
	else if(IsValidEntity(Vs_ParticleSpawned[npc.index]))
	{
		float position[3];
		position[0] = Vs_Temp_Pos[npc.index][0];
		position[1] = Vs_Temp_Pos[npc.index][1];
		position[2] = Vs_Temp_Pos[npc.index][2] - 100.0;
		TeleportEntity(EntRefToEntIndex(Vs_ParticleSpawned[npc.index]), position, NULL_VECTOR, NULL_VECTOR);
		position[2] += 100.0;
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_TRUE_DAMAGE;
		Explode_Logic_Custom(100.0*RaidModeScaling, 0, npc.index, -1, position, 500.0, 1.0, _, true, 20);
		
		ParticleEffectAt(position, "hightower_explosion", 1.0);
		i_ExplosiveProjectileHexArray[npc.index] = 0; 
		npc.PlayBoomSound();
		Vs_RechargeTime[npc.index]=0.0;
		Vs_RechargeTime[npc.index]=0.0;
		return true;
	}
	return false;
}

static void Fire_Shield_Projectile(Huscarls npc, float Time)
{
	static float vOrigin[3], vAngles[3], vTarget[4][3];
	WorldSpaceCenter(npc.index, vOrigin);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
	vAngles[0]=0.0;
	vAngles[2]=0.0;
	float TempAng[3];
	TempAng[1] = vAngles[1];
	TempAng[0]=0.0;
	TempAng[2]=0.0;
	for(int i=1; i<=4; i++)
	{
		EntityLookPoint(npc.index, TempAng, vOrigin, vTarget[i-1]);
		/*Handle trace = TR_TraceRayFilterEx(vOrigin, TempAng, MASK_SHOT, RayType_Infinite, BulletAndMeleeTrace, npc.index);
		if(TR_DidHit(trace))
			TR_GetEndPosition(vTarget[i-1], trace);
		delete trace;*/
		TempAng[1] += 90.0;
	}
	for(int i=1; i<=4; i++)
	{
		int RocketGet = npc.FireParticleRocket(vTarget[i-1], 0.0, (npc.Anger ? 150.0 : 100.0), 400.0, "", true);
		if(!IsValidEntity(RocketGet))
			continue;
		SetEntityMoveType(RocketGet, MOVETYPE_NOCLIP);
		int Shield = npc.SpawnShield(-1.0, "models/props_mvm/mvm_player_shield.mdl",120.0, false);
		SetEntProp(Shield, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
		WorldSpaceCenter(RocketGet, TempAng);
		TempAng[2] -= 24.0;
		TeleportEntity(Shield, TempAng, vAngles, NULL_VECTOR);
		SetVariantString("!activator");
		AcceptEntityInput(Shield, "SetParent", RocketGet);
		
		DataPack RFShield = new DataPack();
		RFShield.WriteCell(EntIndexToEntRef(Shield));
		RFShield.WriteCell(EntIndexToEntRef(npc.index));
		RequestFrame(Huscarls_Shield_StartTouch, RFShield);
		vAngles[1] += 90.0;
		CreateTimer(Time, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
	}
}
static void Huscarls_Shield_StartTouch(DataPack pack)
{
	pack.Reset();
	int Shield = EntRefToEntIndex(pack.ReadCell());
	int Owner = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(Shield))
		return;
	if(!IsValidEntity(Owner))
		return;
	float position[3];
	GetEntPropVector(Shield, Prop_Data, "m_vecAbsOrigin", position);
	float vecTarget[3];
	bool PlaySounds=false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(EnemyLoop) && b_IsAProjectile[EnemyLoop] && GetTeam(Owner) != GetTeam(EnemyLoop))
		{
			WorldSpaceCenter(EnemyLoop, vecTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, position);
			if(flDistanceToTarget < 250.0)
			{
				ParticleEffectAt(vecTarget, "manmelter_impact_electro", 1.0);
				RemoveEntity(EnemyLoop);
				PlaySounds=true;
			}
		}
	}
	if(PlaySounds)EmitSoundToAll(g_AdaptiveArmorSounds[GetRandomInt(0, sizeof(g_AdaptiveArmorSounds) - 1)], 0, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.7, _, -1, vecTarget);
	Explode_Logic_Custom(0.0, Owner, Owner, -1, position, 142.0, _, _, true, _, false, _, Shield_Knockback);
	delete pack;
	DataPack pack2 = new DataPack();
	pack2.WriteCell(EntIndexToEntRef(Shield));
	pack2.WriteCell(EntIndexToEntRef(Owner));
	float Throttle = 0.04;	//0.025
	int frames_offset = RoundToCeil(66.0*Throttle);	//no need to call this every frame if avoidable
	if(frames_offset < 0)
		frames_offset = 1;
	RequestFrames(Huscarls_Shield_StartTouch, frames_offset, pack2);
}

static void Shield_Knockback(int entity, int victim, float damage, int weapon)
{
	if(!IsValidEntity(entity))
		return;
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		damage = 1.0 * RaidModeScaling;
		if(damage<1.0)damage=1.0;
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET, -1, _, vecHit);
		if(!IsInvuln(victim))
		{
			if(IsValidClient(victim))
				if(!HasSpecificBuff(victim, "Fluid Movement"))
					TF2_StunPlayer(victim, 0.2, 0.8, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);
			Custom_Knockback(entity, victim, 70.0, true);
		}
		else Custom_Knockback(entity, victim, 140.0, true);
	}
}

static void Huscarls_Weapon_Lines(Huscarls npc, int client)
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
		/*ase WEAPON_SEABORNMELEE: switch(GetRandomInt(0,3)){
			case 0: Format(Text_Lines, sizeof(Text_Lines), "Okay, now there's {darkblue}Seaborn{default} too.");
			case 1: Format(Text_Lines, sizeof(Text_Lines), "I need some {red}Napalm{default} to fry the {darkblue}Seaborn{default}.");
			case 2: Format(Text_Lines, sizeof(Text_Lines), "I found an {darkblue}Infected{default} person, I need a Backup!");
			case 3: Format(Text_Lines, sizeof(Text_Lines), "I didn't know there was a {darkblue}Seaborn{default}.");}
		case WEAPON_EXPLORER: switch(GetRandomInt(0,2)){
			case 0: Format(Text_Lines, sizeof(Text_Lines), "{purple}Void{default}...!");
			case 1: Format(Text_Lines, sizeof(Text_Lines), "{purple}Purple guy{default} is here.");
			case 2: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{default}, You're using {purple}Void{default} as a weapon...", client);}*/
		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{lightblue}Huscarls{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}