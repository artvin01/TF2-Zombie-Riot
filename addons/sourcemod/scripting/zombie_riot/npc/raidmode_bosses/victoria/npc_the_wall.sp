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
static const char g_BotArrivedSounds[][] = {
	"vo/heavy_specialcompleted03.mp3",
	"vo/heavy_specialcompleted02.mp3",
	"vo/heavy_specialcompleted05.mp3"
};
static const char g_AngerSounds[][] = {
	"vo/heavy_revenge07.mp3",
	"vo/heavy_revenge14.mp3"
};
static const char g_RushSounds[][] = {
	"vo/heavy_battlecry01.mp3",
	"vo/heavy_battlecry03.mp3",
	"vo/heavy_battlecry05.mp3"
};

static const char g_RushHitSounds[][] = {
	"weapons/demo_charge_hit_world1.wav",
	"weapons/demo_charge_hit_world2.wav",
	"weapons/demo_charge_hit_world3.wav",
	"weapons/demo_charge_hit_flesh1.wav",
	"weapons/demo_charge_hit_flesh2.wav",
	"weapons/demo_charge_hit_flesh3.wav"
};

static const char g_ExplodSounds[][] = {
	"weapons/air_burster_explode1.wav",
	"weapons/air_burster_explode2.wav",
	"weapons/air_burster_explode3.wav"
};

static const char g_PowerAttackSounds[] = "weapons/physcannon/energy_sing_explosion2.wav";
static const char g_SuperJumpSound[] = "weapons/rocket_ll_shoot.wav";
static const char g_AngerSoundsPassed[] = "vo/heavy_specialcompleted08.mp3";
static const char g_StartAdaptiveArmorSounds[] = "vo/heavy_specialcompleted06.mp3";
static const char g_ThrowSounds[] = "weapons/cleaver_throw.wav";

static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_KaboomSounds[] = "items/cart_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

/* Victoria Nuke */
static float Vs_DelayTime[MAXENTITIES];
static int Vs_Target[MAXENTITIES];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];

static int g_RedPoint;
static int g_Laser;

/* Extra DMGType Resist */
static float GetArmor[MAXENTITIES];
static float BlastDMG[MAXENTITIES];
static float MagicDMG[MAXENTITIES];
static float BulletDMG[MAXENTITIES];
static bool BlastArmor[MAXENTITIES];
static bool MagicArmor[MAXENTITIES];
static bool BulletArmor[MAXENTITIES];


static int GrabPlayer[MAXPLAYERS];

static bool ParticleSpawned[MAXENTITIES];
static bool Frozen_Player[MAXPLAYERS];

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
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_AdaptiveArmorSounds);
	PrecacheSoundArray(g_RushSounds);
	PrecacheSoundArray(g_RushHitSounds);
	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_BotArrivedSounds);
	PrecacheSoundArray(g_ExplodSounds);
	PrecacheSound(g_PowerAttackSounds);
	PrecacheSound(g_SuperJumpSound);
	PrecacheSound(g_AngerSoundsPassed);
	PrecacheSound(g_StartAdaptiveArmorSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_KaboomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheSound(g_ThrowSounds);
	PrecacheSound("ambient/alarms/doomsday_lift_alarm.wav", true);
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav", true);
	PrecacheSound("weapons/medi_shield_deploy.wav", true);
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("items/powerup_pickup_knockout.wav", true);
	PrecacheSound("items/powerup_pickup_resistance.wav", true);
	PrecacheSoundCustom("#zombiesurvival/victoria_1/huscarl_ost_new.mp3");

	PrecacheModel("models/props_mvm/mvm_player_shield.mdl", true);
	PrecacheModel("models/props_mvm/mvm_player_shield2.mdl", true);
	g_Laser = PrecacheModel(LASERBEAM);
	g_RedPoint = PrecacheModel("sprites/redglow1.vmt");
	
	PrecacheModel("models/player/heavy.mdl");
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
	public void PlayThrowSound()
	{
		EmitSoundToAll(g_ThrowSounds, this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME - 0.2);
	}
	public void PlayDMGTypeArmorSound()
	{
		EmitSoundToAll("items/powerup_pickup_resistance.wav", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property float m_flHuscarlsRushCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flHuscarlsAdaptiveArmorDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flHuscarlsDeployEnergyShieldCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flHuscarlsGroundSlamCoolDown
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flDMGTypeArmorDuration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	property int iLifeSupportDevice_1
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property int iLifeSupportDevice_2
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property int iLifeSupportDevice_3
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	
	public void SaveLifeSupportDevice(int entity, int slot)
	{
		switch(slot)
		{
			case 1:this.iLifeSupportDevice_1=entity;
			case 2:this.iLifeSupportDevice_2=entity;
			case 3:this.iLifeSupportDevice_3=entity;
			default:this.iLifeSupportDevice_3=entity;
		}
	}
	public int LoadLifeSupportDevice(int slot)
	{
		switch(slot)
		{
			case 1:return this.iLifeSupportDevice_1;
			case 2:return this.iLifeSupportDevice_2;
			case 3:return this.iLifeSupportDevice_3;
			default:return this.iLifeSupportDevice_3;
		}
	}
	
	property int m_iOverrideOwner
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	
	public Huscarls(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Huscarls npc = view_as<Huscarls>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.35", "48000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
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
		npc.m_iState=0;
		npc.m_iOverlordComboAttack=0;
		npc.m_flDoingAnimation=0.0;
		float gametime = GetGameTime(npc.index);
		npc.m_iOverrideOwner = 0;
		static char countext[2][512];
		int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
		float MAXHitCharge=5000.0;
		for(int i = 0; i < count; i++)
		{
			if(i>=count)break;
			else if(StrContains(countext[i], "support_ability") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "support_ability", "");
				npc.m_iOverlordComboAttack = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "override_owner") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "override_owner", "");
				npc.m_iOverrideOwner = StringToInt(countext[i]);
			}
			else if(StrContains(countext[i], "max_hitcharge") != -1)
			{
				ReplaceString(countext[i], sizeof(countext[]), "max_hitcharge", "");
				MAXHitCharge = StringToFloat(countext[i]);
			}
		}
		if(npc.m_iOverlordComboAttack)
		{
			func_NPCDeath[npc.index] = Clone_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Clone_OnTakeDamage;
			func_NPCThink[npc.index] = Clone_ClotThink;
		
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			npc.m_iChanged_WalkCycle = -1;

			switch(npc.m_iOverlordComboAttack)
			{
				case 1:
				{
					switch(GetRandomInt(0, 2))
					{
						case 0: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-1", false, true);
						case 1: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-2", false, true);
						case 2: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-9", false, true);
					}
				}
				case 2:
				{
					switch(GetRandomInt(0, 1))
					{
						case 0: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-3", false, true);
						case 1: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-4", false, true);
					}
				}
				case 3:
				{
					switch(GetRandomInt(0, 1))
					{
						case 0: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-5", false, true);
						case 1: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-6", false, true);
					}
				}
				case 4:
				{
					switch(GetRandomInt(0, 1))
					{
						case 0: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-7", false, true);
						case 1: NPCPritToChat(npc.index, "{blue}", "Huscarls_Talk_Support-8", false, true);
					}
				}
			}
		}
		else
		{
			RemoveAllDamageAddition();
			func_NPCDeath[npc.index] = Huscarls_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Huscarls_OnTakeDamage;
			func_NPCThink[npc.index] = Huscarls_ClotThink;
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			//IDLE
			npc.m_iState = 0;
			npc.m_flSpeed = 330.0;
			npc.m_iChanged_WalkCycle = -1;
			npc.m_bLostHalfHealth = false;
			b_NpcIsInvulnerable[npc.index] = false;
			npc.Anger = false;
			b_angered_twice[npc.index] = false;
			npc.m_bFUCKYOU_move_anim = false;
			npc.m_bFUCKYOU = false;
			BlockLoseSay = false;
			AlreadySaidWin = false;

			npc.m_flHuscarlsRushCoolDown = gametime + 11.0;
			
			npc.m_flHuscarlsAdaptiveArmorCoolDown = gametime + 30.0;
			npc.m_flHuscarlsAdaptiveArmorDuration = 0.0;
			
			npc.m_flHuscarlsDeployEnergyShieldCoolDown = gametime + 15.0;
			
			npc.m_flHuscarlsGroundSlamCoolDown = gametime + 10.0;
			
			npc.m_flNextRangedBarrage_Singular = gametime + 20.0;
			npc.m_flNextRangedBarrage_Spam = 0.0;
			
			Vs_RechargeTimeMax[npc.index] = 15.0;
			Victoria_Support_RechargeTimeMax(npc.index, 15.0);

			ParticleSpawned[npc.index] = false;
			
			GetArmor[npc.index] = 0.0;
			BlastDMG[npc.index] = 0.0;
			MagicDMG[npc.index] = 0.0;
			BulletDMG[npc.index] = 0.0;

			Zero(b_said_player_weaponline);
			fl_said_player_weaponline_time[npc.index] = gametime + GetRandomFloat(0.0, 5.0);
			
			EmitSoundToAll("items/powerup_pickup_knockout.wav", _, _, _, _, 1.0, .soundtime = GetGameTime() - 0.336);
			EmitSoundToAll("items/powerup_pickup_knockout.wav", _, _, _, _, 1.0, .soundtime = GetGameTime() - 0.336);
			b_thisNpcIsARaid[npc.index] = true;
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
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria_1/huscarl_ost_new.mp3");
				music.Time = 232;
				music.Volume = 1.7;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Unstoppable Force");
				strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
				Music_SetRaidMusic(music);
			}

			NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Intro", false, true);
			
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
			fl_ruina_battery_max[npc.index] = MAXHitCharge+(500.0 * RaidModeScaling);
			fl_ruina_battery[npc.index] = 0.0;
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
	static bool ReAnim;
	npc.m_flNextThinkTime = gameTime + 0.1;

	switch(npc.m_iOverlordComboAttack)
	{
		case 1:
		{
			switch(npc.m_iState)
			{
				case 0:
				{
					npc.AddActivityViaSequence("taunt02");
					npc.SetCycle(0.5);
					npc.SetPlaybackRate(1.2);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flDoingAnimation = gameTime + 1.47;
					npc.m_iState = 1;
					npc.StopPathing();
					npc.m_bisWalking = false;
				}
				case 1:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.PlayShieldSound();
						if(IsValidEntity(npc.m_iOverrideOwner))
						{
							Huscarls npcGetInfo = view_as<Huscarls>(npc.m_iOverrideOwner);
							Fire_Shield_Projectile(npcGetInfo, 10.0);
						}
						else Fire_Shield_Projectile(npc, 10.0);
						
						npc.m_iOverlordComboAttack = 0;
					}
				}
			}
		}
		case 2:
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				switch(Support_Work(npc, gameTime, VecSelfNpc, vecTarget))
				{
					case 0:
					{
						if(npc.m_iChanged_WalkCycle != 0)
						{
							npc.m_bisWalking = false;
							npc.m_bAllowBackWalking = false;
							npc.m_iChanged_WalkCycle = 0;
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
						}
						ReAnim=true;
					}
					case 1:
					{
						if(npc.m_iChanged_WalkCycle != 1)
						{
							npc.m_iChanged_WalkCycle = 1;
							npc.StartPathing();
							npc.m_flSpeed = 630.0;
							npc.m_bisWalking = true;
							npc.m_bAllowBackWalking = false;
							ReAnim=true;
						}
						HuscarlIntoAir(npc, ReAnim);
						static float vOrigin[3], vAngles[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
						vAngles[0]=5.0;
						EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
						npc.SetGoalVector(vOrigin);
					}
				}
			}
			else npc.m_iTarget = GetClosestTarget(npc.index);
		}
		case 3:
		{
			switch(npc.m_iState)
			{
				case 0:
				{
					npc.AddActivityViaSequence("layer_zoomin_broom_exit");
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
					npc.SetCycle(0.01);
					npc.SetPlaybackRate(1.2);
					npc.m_flDoingAnimation = gameTime + 0.2;
					npc.m_iState = 1;
					npc.StopPathing();
					npc.m_bisWalking = false;
				}
				case 1:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.AddActivityViaSequence("layer_taunt_yeti_prop");
						npc.SetCycle(0.9);
						npc.SetPlaybackRate(1.1);
						npc.m_flDoingAnimation = gameTime + 0.5;
						npc.m_iState = 2;
					}
				}
				case 2:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
						float SlamDMG = 50.0;
						float Range = 250.0;
						ParticleEffectAt(WorldSpaceVec, "mvm_soldier_shockwave", 1.0);
						ParticleEffectAt(WorldSpaceVec, "ExplosionCore_MidAir", 1.0);
						CreateEarthquake(WorldSpaceVec, 1.0, Range * 1.25, 16.0, 255.0);
						KillFeed_SetKillIcon(npc.index, "pumpkindeath");
						Explode_Logic_Custom(SlamDMG * RaidModeScaling, 0, npc.index, -1, _, Range, 1.0, 0.75, true, 20, _, _, Ground_Slam);
						npc.m_flDoingAnimation = gameTime + 0.2;
						npc.PlayKaboomSound();
						npc.m_iState=-1;
						npc.m_iOverlordComboAttack = 0;
					}
				}
			}
		}
		case 4:
		{
			static int GET_RAGED_TARGET;
			switch(npc.m_iState)
			{
				case 0:
				{
					GET_RAGED_TARGET=Victoria_GetTargetDistance(npc.index, true, true);
					npc.AddActivityViaSequence("layer_taunt_cyoa_PDA_intro");
					npc.SetCycle(0.0);
					npc.SetPlaybackRate(0.8);
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_iState = 1;
					
					npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
					npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
					npc.m_flHuscarlsRushCoolDown += 0.1;
					npc.StopPathing();
					npc.m_bisWalking = false;
				}
				case 1:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.SetActivity("ACT_MP_RUN_MELEE");
						if(Can_I_See_Enemy_Only(npc.index, GET_RAGED_TARGET))
							npc.m_iState = 2;
						else
						{
							npc.m_flNextRangedBarrage_Spam=10.0;
							npc.m_iState = 7;
						}
					}
				}
				case 2,3,4,5,6,7:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						float vecTarget[3], VecSelfNpc[3]; WorldSpaceCenter(GET_RAGED_TARGET, vecTarget); WorldSpaceCenter(npc.index, VecSelfNpc);
						npc.FaceTowards(vecTarget, 15000.0);
						int RocketGet;
						if(IsValidEntity(npc.m_iOverrideOwner))
						{
							Huscarls npcGetInfo = view_as<Huscarls>(npc.m_iOverrideOwner);
							RocketGet = npcGetInfo.FireRocket(vecTarget, 0.0, 1100.0,_,1.5);
						}
						else RocketGet = npc.FireRocket(vecTarget, 0.0, 1100.0,_,1.5);
						if(RocketGet != -1)
						{
							npc.AddGesture("ACT_MP_THROW");
							npc.SetCycle(0.0);
							npc.SetPlaybackRate(1.2);
							float SpeedReturn[3];
							SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
							vecTarget[0] += GetRandomFloat(-200.0, 200.0);
							vecTarget[1] += GetRandomFloat(-200.0, 200.0);
							ArcToLocationViaSpeedProjectile(VecSelfNpc, vecTarget, SpeedReturn, 5.0, 2.0);
							float ang[3]; GetVectorAngles(SpeedReturn, ang);
							SetEntPropVector(RocketGet, Prop_Data, "m_angRotation", ang);
							TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
							SetEntityMoveType(RocketGet, MOVETYPE_NOCLIP);
							WorldSpaceCenter(GET_RAGED_TARGET, vecTarget);
							if(IsValidClient(GET_RAGED_TARGET) && !(GetEntityFlags(GET_RAGED_TARGET)&FL_ONGROUND))
							{
								SpeedReturn[0]=90.0;
								SpeedReturn[1]=0.0;
								SpeedReturn[2]=0.0;
								EntityLookPoint(GET_RAGED_TARGET, SpeedReturn, vecTarget, vecTarget);
								vecTarget[2] += (b_IsGiant[GET_RAGED_TARGET] ? 64.0 : 42.0);
							}
							if(IsValidEntity(npc.m_iOverrideOwner))
								Engage_HE_Strike(npc.m_iOverrideOwner, vecTarget, 85.0 * RaidModeScaling, 1.85, EXPLOSION_RADIUS*1.25);
							else Engage_HE_Strike(npc.index, vecTarget, 85.0 * RaidModeScaling, 1.85, EXPLOSION_RADIUS*1.25);
							CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
							npc.PlayThrowSound();
						}
						npc.m_flDoingAnimation = gameTime + 0.26;
						npc.m_iState++;
					}
				}
				case 8:
				{
					npc.AddActivityViaSequence("layer_taunt_vehicle_allclass_spawn");
					npc.SetCycle(0.0);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_iOverlordComboAttack = 0;
					npc.m_iState = -1;
				}
			}
		}
		default:
		{
			if(npc.m_flDoingAnimation < gameTime)
			{
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

static int Support_Work(Huscarls npc, float gameTime, float VecSelfNpc[3], float vecTarget[3])
{
	switch(npc.m_iOverlordComboAttack)
	{
		case 2:
		{
			switch(npc.m_iState)
			{
				case 0:
				{
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
					npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
					npc.SetCycle(0.5);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 1.1;
					npc.m_iState = 1;
				}
				case 1:
				{
					npc.FaceTowards(vecTarget, 15000.0);
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.PlayRushSound();
						npc.SetActivity("ACT_MP_RUN_MELEE");
						int AnimLayer = npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
						npc.SetLayerPlaybackRate(AnimLayer, (0.01));
						npc.SetLayerCycle(AnimLayer, (0.9));
						npc.m_flDoingAnimation = gameTime + 5.0;
						npc.m_iState = 2;
					}
				}
				case 2:
				{
					ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Got_it_fucking_shit);
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 200.0, _, _, true, _, false, _, NPC_Go_away);
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
						npc.m_iState = 3;
					}
					else
					{
						float vAngles[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
						EntityLookPoint(npc.index, vAngles, VecSelfNpc, vecTarget);
						if(GetVectorDistance(VecSelfNpc, vecTarget, true)<15625.0)
						{
							npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
							npc.m_iState = 5;
						}
					}
					npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
					npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
					npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
					npc.m_flNextRangedBarrage_Singular += 0.1;
					return 1;
				}
				case 3:
				{
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];

					hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
					hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );
					if(!IsSpaceOccupiedWorldOnly(VecSelfNpc, hullcheckmins, hullcheckmaxs, npc.index))
					{
						npc.StopPathing();
						npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");
						npc.SetCycle(0.01);
						npc.SetPlaybackRate(1.0);
						
						float flPos[3];
						float flAng[3];
						int Particle;
						npc.GetAttachment("foot_L", flPos, flAng);
						Particle = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
						CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle), TIMER_FLAG_NO_MAPCHANGE);
						npc.GetAttachment("foot_R", flPos, flAng);
						Particle = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
						CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle), TIMER_FLAG_NO_MAPCHANGE);
						ParticleEffectAt(VecSelfNpc, "mvm_soldier_shockwave", 1.0);
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, ToTheMoon);
						VecSelfNpc[2] += 800.0;

						VecSelfNpc[0] = vecTarget[0];
						VecSelfNpc[1] = vecTarget[1];
						PluginBot_Jump(npc.index, VecSelfNpc);
						npc.PlaySuperJumpSound();
						npc.m_flDoingAnimation = gameTime + (HasSpecificBuff(npc.index, "Intangible") ? 1.0 : 1.5);
						npc.m_iState = 4;
					}
					else
						npc.m_iState = 5;
				}
				case 4:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 400.0, _, _, true, _, false, _, Ground_pound);
						npc.PlayExplodSound();
						npc.SetVelocity({0.0,0.0,-1500.0});
						ParticleEffectAt(VecSelfNpc, "mvm_soldier_shockwave", 1.0);
						float vAngles[3];
						vAngles[0]=90.0;
						EntityLookPoint(npc.index, vAngles, VecSelfNpc, vecTarget);
						CreateEarthquake(vecTarget, 0.5, 350.0, 16.0, 255.0);
						npc.PlayRushHitSound();
						npc.m_iState = 6;
					}
				}
				case 5:
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
					CreateEarthquake(VecSelfNpc, 0.5, 350.0, 16.0, 255.0);
					npc.PlayRushHitSound();
					npc.m_iState = 6;
				}
				case 6:
				{
					npc.AddActivityViaSequence("taunt_crushing_headache");
					npc.SetCycle(0.75);
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 0.7;
					npc.m_iState = 7;
				}
				case 7:
				{
					if(npc.m_flDoingAnimation < gameTime)
					{
						npc.AddActivityViaSequence("taunt_crushing_headache");
						npc.SetCycle(0.75);
						npc.SetPlaybackRate(1.0);
						if(HasSpecificBuff(npc.index, "Intangible"))
							RemoveSpecificBuff(npc.index, "Intangible");
						for(int client_check=1; client_check<=MaxClients; client_check++)
						{
							if(IsValidClient(client_check) && Frozen_Player[client_check])
							{
								SetEntProp(client_check, Prop_Send, "m_bDucked", true);
								SetEntityFlags(client_check, GetEntityFlags(client_check) | FL_DUCKING);
								TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
								TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
								SetEntityCollisionGroup(client_check, COLLISION_GROUP_PLAYER);
								Frozen_Player[client_check]=false;
							}
						}
						npc.m_iOverlordComboAttack = 0;
						npc.m_iState = -1;
					}
				}
			}
			return 0;
		}
	}
	return 0;
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

static void Huscarls_ClotThink(int iNPC)
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
		npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}
	if(npc.m_bLostHalfHealth && Victoria_Support(npc))
	{
		/*none*/
	}
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0, 2))
			{
				case 0:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Lastman-1", false, false);
				case 1:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Lastman-2", false, false);
				case 2:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Lastman-3", false, false);
			}
		}
	}
	if(!npc.m_bFUCKYOU && i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		DeleteAndRemoveAllNpcs = 3.0;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("layer_taunt_crushing_headache");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		BlockLoseSay = true;
		AlreadySaidWin = true;
		
		NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_GameEnd", false, false);
		return;
	}
	if(RaidModeTime < GetGameTime())
	{
		if(!npc.m_bFUCKYOU)
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
				case 0:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_TimeUp-1", false, false);
				case 1:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_TimeUp-2", false, false);
				//case 2:CPrintToChatAll("{lightblue}Huscarls{default}: {blue}Harrison{default}? The situation is over. Let's go back.");
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
			npc.m_bFUCKYOU = true;
		}
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

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iState == -1)
			npc.m_iState = 0;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		static bool ReAnim;
		switch(Huscarls_Work(npc, gameTime, VecSelfNpc, vecTarget, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flSpeed = 330.0;
					npc.StartPathing();
				}
				HuscarlIntoAir(npc, ReAnim);
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
				ReAnim=false;
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
					npc.m_iChanged_WalkCycle = 1;
				ReAnim=true;
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
				ReAnim=true;
			}
			case 3:
			{
				//I didn't fix the 'Kansei Dorifto' bug
				//because it's fun.
				if(npc.m_iChanged_WalkCycle != 3)
				{
					npc.m_iChanged_WalkCycle = 3;
					npc.StartPathing();
					npc.m_flSpeed = 630.0;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					ReAnim=true;
				}
				HuscarlIntoAir(npc, ReAnim);
				static float vOrigin[3], vAngles[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
				vAngles[0]=5.0;
				EntityLookPoint(npc.index, vAngles, VecSelfNpc, vOrigin);
				npc.SetGoalVector(vOrigin);
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime = 0.0;
}

static int Huscarls_Work(Huscarls npc, float gameTime, float VecSelfNpc[3], float vecTarget[3], float distance)
{
	if(npc.m_bFUCKYOU_move_anim && TinCan_Raid(npc, gameTime))
		return 2;

	if(npc.m_flHuscarlsAdaptiveArmorDuration && npc.m_flHuscarlsAdaptiveArmorDuration < gameTime)
	{
		if(fl_ruina_battery[npc.index])
			NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Ability1-2", false, false);
		else
			RemoveSpecificBuff(npc.index, "Battery_TM Charge");
		npc.m_flHuscarlsAdaptiveArmorDuration=0.0;
		npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 20.0 : 30.0);
	}
	
	if(b_angered_twice[npc.index] && npc.m_flHuscarlsRushCoolDown-(0.28 + DEFAULT_UPDATE_DELAY_FLOAT) > gameTime && npc.m_flHuscarlsRushCoolDown-3.6 < gameTime)
		HuscarlsGrab(npc, gameTime);

	if(npc.m_flHuscarlsRushCoolDown < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
				npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 1.1;
				npc.m_flAttackHappens = 0.0;
				npc.m_iState = 1;
			}
			case 1:
			{
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.PlayRushSound();
					npc.SetActivity("ACT_MP_RUN_MELEE");
					int AnimLayer = npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
					npc.SetLayerPlaybackRate(AnimLayer, (0.01));
					npc.SetLayerCycle(AnimLayer, (0.9));
					npc.m_flDoingAnimation = gameTime + 5.0;
					npc.m_iState = 2;
					b_angered_twice[npc.index]=true;
				}
			}
			case 2:
			{
				ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
				Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Got_it_fucking_shit);
				Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 200.0, _, _, true, _, false, _, NPC_Go_away);
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
					npc.m_iState = 3;
				}
				else
				{
					float vAngles[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vAngles);
					EntityLookPoint(npc.index, vAngles, VecSelfNpc, vecTarget);
					if(GetVectorDistance(VecSelfNpc, vecTarget, true)<15625.0)
					{
						npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
						npc.m_iState = 5;
					}
				}
				npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
				npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
				npc.m_flNextRangedBarrage_Singular += 0.1;
				return 3;
			}
			case 3:
			{
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];

				hullcheckmaxs = view_as<float>( { 35.0, 35.0, 500.0 } ); //check if above is free
				hullcheckmins = view_as<float>( { -35.0, -35.0, 17.0 } );
				if(!IsSpaceOccupiedWorldOnly(VecSelfNpc, hullcheckmins, hullcheckmaxs, npc.index))
				{
					npc.StopPathing();
					npc.AddActivityViaSequence("layer_taunt_bare_knuckle_beatdown_outro");
					npc.m_flAttackHappens = 0.0;
					npc.SetCycle(0.01);
					npc.SetPlaybackRate(1.0);
					
					float flPos[3];
					float flAng[3];
					int Particle;
					npc.GetAttachment("foot_L", flPos, flAng);
					Particle = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_L", {0.0,0.0,0.0});
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle), TIMER_FLAG_NO_MAPCHANGE);
					npc.GetAttachment("foot_R", flPos, flAng);
					Particle = ParticleEffectAt_Parent(flPos, "rockettrail", npc.index, "foot_R", {0.0,0.0,0.0});
					CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(Particle), TIMER_FLAG_NO_MAPCHANGE);
					ParticleEffectAt(VecSelfNpc, "mvm_soldier_shockwave", 1.0);
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, ToTheMoon);
					VecSelfNpc[2] += 800.0;

					VecSelfNpc[0] = vecTarget[0];
					VecSelfNpc[1] = vecTarget[1];
					PluginBot_Jump(npc.index, VecSelfNpc);
					SetEntityCollisionGroup(npc.index, COLLISION_GROUP_DEBRIS);
					npc.PlaySuperJumpSound();
					npc.m_flDoingAnimation = gameTime + (HasSpecificBuff(npc.index, "Intangible") ? 1.0 : 1.5);
					npc.m_iState = 4;
				}
				else
					npc.m_iState = 5;
			}
			case 4:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 400.0, _, _, true, _, false, _, Ground_pound);
					npc.PlayExplodSound();
					npc.SetVelocity({0.0,0.0,-1500.0});
					ParticleEffectAt(VecSelfNpc, "mvm_soldier_shockwave", 1.0);
					float vAngles[3];
					vAngles[0]=90.0;
					EntityLookPoint(npc.index, vAngles, VecSelfNpc, vecTarget);
					CreateEarthquake(vecTarget, 0.5, 350.0, 16.0, 255.0);
					npc.PlayRushHitSound();
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_iState = 6;
				}
			}
			case 5:
			{
				Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, 125.0, _, _, true, _, false, _, Compressor);
				CreateEarthquake(VecSelfNpc, 0.5, 350.0, 16.0, 255.0);
				npc.PlayRushHitSound();
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_iState = 6;
			}
			case 6:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					if(HasSpecificBuff(npc.index, "Intangible"))
						RemoveSpecificBuff(npc.index, "Intangible");
					npc.m_flHuscarlsRushCoolDown = gameTime+(NpcStats_VictorianCallToArms(npc.index) ? 14.0 : 15.0);
					npc.m_iState = -1;
					SetEntityCollisionGroup(npc.index, COLLISION_GROUP_PLAYER);
					for(int client_check=1; client_check<=MaxClients; client_check++)
					{
						if(IsValidClient(client_check) && Frozen_Player[client_check])
						{
							SetEntProp(client_check, Prop_Send, "m_bDucked", true);
							SetEntityFlags(client_check, GetEntityFlags(client_check) | FL_DUCKING);
							TF2_AddCondition(client_check, TFCond_LostFooting, 1.0);
							TF2_AddCondition(client_check, TFCond_AirCurrent, 1.0);
							SetEntityCollisionGroup(client_check, COLLISION_GROUP_PLAYER);
							Frozen_Player[client_check]=false;
						}
					}
				}
			}
		}
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flNextRangedBarrage_Singular += 0.1;
		return 2;
	}
	else if(npc.m_flHuscarlsAdaptiveArmorCoolDown < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Ability1-1", false, false);
				
				npc.AddActivityViaSequence("layer_taunt_unleashed_rage_heavy");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_iState = 1;
				npc.PlayAdaptiveArmorSound();
			}
			case 1:
			{
				if(!npc.m_flHuscarlsAdaptiveArmorDuration)
				{
					ApplyStatusEffect(npc.index, npc.index, "Battery_TM Charge", 999.0);
					fl_ruina_battery[npc.index]=0.0;
					bool IgniteFist;
					if(b_NpcIsInvulnerable[npc.index])
					{
						IgniteFist=true;
						fl_ruina_battery[npc.index]+=fl_ruina_battery_max[npc.index];
					}
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						IgniteFist=true;
						fl_ruina_battery[npc.index]+=fl_ruina_battery_max[npc.index]*0.3;
					}
					if(IsValidEntity(npc.m_iWearable2))
					{
						ExtinguishTarget(npc.m_iWearable2);
						if(IgniteFist)
							IgniteTargetEffect(npc.m_iWearable2);
					}
					npc.m_flHuscarlsAdaptiveArmorDuration = gameTime + 5.0;
				}
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.m_flHuscarlsAdaptiveArmorCoolDown = gameTime + 999.0;
					npc.m_iState = -1;
				}
			}
		}
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flNextRangedBarrage_Singular += 0.1;
		return 2;
	}
	else if(npc.m_flHuscarlsDeployEnergyShieldCoolDown < gameTime)
	{
		if(npc.m_flAttackHappens_bullshit > gameTime && !npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
		npc.PlayShieldSound();
		Fire_Shield_Projectile(npc, 10.0);
		npc.m_flHuscarlsDeployEnergyShieldCoolDown = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 15.0 : 21.0);
	}
	else if(npc.m_flNextRangedBarrage_Singular < gameTime)
	{
		static int GET_RAGED_TARGET;
		switch(npc.m_iState)
		{
			case 0:
			{
				GET_RAGED_TARGET=Victoria_GetTargetDistance(npc.index, true, true);
				npc.AddActivityViaSequence("layer_taunt_cyoa_PDA_intro");
				npc.SetCycle(0.0);
				npc.SetPlaybackRate(0.8);
				npc.m_flDoingAnimation = gameTime + 0.5;
				npc.m_iState = 1;
				
				npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
				npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
				npc.m_flHuscarlsRushCoolDown += 0.1;
				return 2;
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.SetActivity("ACT_MP_RUN_MELEE");
					if(Can_I_See_Enemy_Only(npc.index, GET_RAGED_TARGET))
						npc.m_iState = 2;
					else
					{
						npc.m_flNextRangedBarrage_Spam=10.0;
						npc.m_iState = 7;
					}
				}
				npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
				npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
				npc.m_flHuscarlsRushCoolDown += 0.1;
				return 2;
			}
			case 2,3,4,5,6:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					WorldSpaceCenter(GET_RAGED_TARGET, vecTarget);
					int RocketGet = npc.FireRocket(vecTarget, 0.0, 1100.0,_,1.5);
					if(RocketGet != -1)
					{
						npc.AddGesture("ACT_MP_THROW");
						npc.SetCycle(0.0);
						npc.SetPlaybackRate(1.2);
						float SpeedReturn[3];
						SetEntProp(RocketGet, Prop_Send, "m_bCritical", true);
						vecTarget[0] += GetRandomFloat(-200.0, 200.0);
						vecTarget[1] += GetRandomFloat(-200.0, 200.0);
						ArcToLocationViaSpeedProjectile(VecSelfNpc, vecTarget, SpeedReturn, 5.0, 2.0);
						float ang[3]; GetVectorAngles(SpeedReturn, ang);
						SetEntPropVector(RocketGet, Prop_Data, "m_angRotation", ang);
						TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						SetEntityMoveType(RocketGet, MOVETYPE_NOCLIP);
						WorldSpaceCenter(GET_RAGED_TARGET, vecTarget);
						if(IsValidClient(GET_RAGED_TARGET) && !(GetEntityFlags(GET_RAGED_TARGET)&FL_ONGROUND))
						{
							SpeedReturn[0]=90.0;
							SpeedReturn[1]=0.0;
							SpeedReturn[2]=0.0;
							EntityLookPoint(GET_RAGED_TARGET, SpeedReturn, vecTarget, vecTarget);
							vecTarget[2] += (b_IsGiant[GET_RAGED_TARGET] ? 64.0 : 42.0);
						}
						Engage_HE_Strike(npc.index, vecTarget, 85.0 * RaidModeScaling, 2.0, EXPLOSION_RADIUS*1.25);
						CreateTimer(2.5, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
						npc.PlayThrowSound();
					}
					npc.m_flDoingAnimation = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 0.26 : 0.32);
					if(npc.m_iState>=4 && !NpcStats_VictorianCallToArms(npc.index))
						npc.m_iState=7;
					else
						npc.m_iState++;
				}
			}
			case 7:
			{
				npc.m_flDoingAnimation = 0.0;
				npc.m_flNextRangedBarrage_Singular = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 25.0 : 30.0);
				if(npc.m_flNextRangedBarrage_Spam)
				{
					npc.m_flNextRangedBarrage_Singular -= npc.m_flNextRangedBarrage_Spam;
					npc.m_flNextRangedBarrage_Spam=0.0;
				}
				npc.m_iState = -1;
			}
		}
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsRushCoolDown += 0.1;
		return 0;
	}
	else if(npc.m_flHuscarlsGroundSlamCoolDown < gameTime)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				npc.AddActivityViaSequence("layer_taunt_yeti_prop");
				EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
				npc.SetCycle(0.9);
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 0.6;
				npc.m_iState = 1;
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					float SlamDMG = 50.0;
					float Range = 250.0;
					ParticleEffectAt(WorldSpaceVec, "mvm_soldier_shockwave", 1.0);
					ParticleEffectAt(WorldSpaceVec, "ExplosionCore_MidAir", 1.0);
					CreateEarthquake(WorldSpaceVec, 1.0, Range * 1.25, 16.0, 255.0);
					KillFeed_SetKillIcon(npc.index, "pumpkindeath");
					Explode_Logic_Custom(SlamDMG * RaidModeScaling, 0, npc.index, -1, _, Range, 1.0, 0.75, true, 20, _, _, Ground_Slam);
					npc.m_flDoingAnimation = gameTime + 0.2;
					npc.PlayKaboomSound();
					npc.m_iState=2;
				}
			}
			case 2:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.m_flHuscarlsGroundSlamCoolDown = gameTime + (NpcStats_VictorianCallToArms(npc.index) ? 17.0 : 18.0);
					npc.m_iState = -1;
				}
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flNextRangedBarrage_Singular += 0.1;
		return 2;
	}
	
	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
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
								float damage = 50.0 * RaidModeScaling;
								if(fl_ruina_battery[npc.index] && !npc.m_flHuscarlsAdaptiveArmorDuration)
								{
									damage+=fl_ruina_battery[npc.index]*0.1;
									fl_ruina_battery[npc.index]=0.0;
									ExtinguishTarget(npc.m_iWearable2);
									CreateEarthquake(vecTarget, 0.5, 350.0, 16.0, 255.0);
									if(HasSpecificBuff(npc.index, "Battery_TM Charge"))
										RemoveSpecificBuff(npc.index, "Battery_TM Charge");
									PlayPOWERSound = true;
								}
								if(ShouldNpcDealBonusDamage(targetTrace))
									damage *= 7.0;
								KillFeed_SetKillIcon(npc.index, "apocofists");
								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
								bool Knocked = false;
								
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 750.0, true);
									}
									if(!HasSpecificBuff(npc.index, "Godly Motivation") || Knocked)
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 375.0, true); 
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
					if(PlayPOWERSound)
					{
						ParticleEffectAt(vecTarget, "rd_robot_explosion", 1.0);
						npc.PlayPowerHitSound();
					}
				}
				npc.m_flAttackHappens = 0.0;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	
	npc.m_iState = 0;
	return 0;
}

static Action Huscarls_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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
	else if((damagetype & DMG_SHOCK) || (i_HexCustomDamageTypes[victim] & ZR_DAMAGE_LASER_NO_BLAST))
	{
		magic = true;
	}
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	if(GetArmor[npc.index]>=float(maxhealth)*0.25)
	{
		BlastArmor[npc.index] = false;
		MagicArmor[npc.index] = false;
		BulletArmor[npc.index] = false;
		switch(Huscarls_Get_HighDMGType(npc.index))
		{
			case 0:
			{
				NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_BlastArmor", false, false);
				BlastArmor[npc.index]=true;
			}
			case 1:
			{
				NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_MagicArmor", false, false);
				MagicArmor[npc.index]=true;
			}
			default:
			{
				NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_BulletArmor", false, false);
				BulletArmor[npc.index]=true;
			}
		}
		GrantEntityArmor(npc.index, false, 0.08, 0.5, 0);
		npc.PlayDMGTypeArmorSound();
		npc.m_flDMGTypeArmorDuration = gameTime + 30.0;
		GetArmor[npc.index] = 0.0;
		BlastDMG[npc.index] = 0.0;
		MagicDMG[npc.index] = 0.0;
		BulletDMG[npc.index] = 0.0;
	}
	else
	{
		if(npc.m_flDMGTypeArmorDuration < gameTime)
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
		if(fl_ruina_battery[npc.index]<fl_ruina_battery_max[npc.index])
		{
			fl_ruina_battery[npc.index] += damage;
			if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index])
				fl_ruina_battery[npc.index]=fl_ruina_battery_max[npc.index];
		}
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
		if(!npc.m_bLostHalfHealth)
		{
			EmitSoundToAll("ambient/alarms/doomsday_lift_alarm.wav");
			NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-1", false);
			npc.m_bLostHalfHealth = true;
		}
		if(!npc.Anger)
		{
			npc.m_iState = 0;
			b_NpcIsInvulnerable[npc.index] = true;
			npc.Anger = true;
			npc.m_bFUCKYOU_move_anim = true;
		}
	}
	else if(ratio<0.5 || (float(health)-damage)<(maxhealth*0.5))
	{
		if(!npc.m_bLostHalfHealth)
		{
			EmitSoundToAll("ambient/alarms/doomsday_lift_alarm.wav");
			NPCPritToChat_Override("Victoria Harrison", "{skyblue}", "Harrison_Talk_Support-1", false);
			npc.m_bLostHalfHealth = true;
		}
	}
	
	return Plugin_Changed;
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

static void Huscarls_NPCDeath(int entity)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	Vs_RechargeTime[npc.index]=0.0;
	Vs_RechargeTimeMax[npc.index]=0.0;

	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
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
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client))
		{
			Vs_LockOn[client]=false;
			if(Frozen_Player[client])
			{
				TF2_AddCondition(client, TFCond_LostFooting, 1.0);
				TF2_AddCondition(client, TFCond_AirCurrent, 1.0);
				SetEntityCollisionGroup(client, 5);
				Frozen_Player[client]=false;
			}
		}
		if(IsValidEntity(GrabPlayer[client-1]))
			RemoveEntity(GrabPlayer[client-1]);
	}

	npc.PlayDeathSound();	
	if(BlockLoseSay)
		return;
	switch(GetRandomInt(0,2))
	{
		case 0:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_EscapePlan-1", false, false);
		case 1:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_EscapePlan-2", false, false);
		case 2:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_EscapePlan-3", false, false);
	}
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
		
		SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
		SDKHook(RocketGet, SDKHook_StartTouch, Huscarls_Particle_StartTouch);
		DataPack RFShield = new DataPack();
		RFShield.WriteCell(EntIndexToEntRef(Shield));
		RFShield.WriteCell(EntIndexToEntRef(npc.index));
		RequestFrame(Huscarls_Shield_StartTouch, RFShield);
		vAngles[1] += 90.0;
		CreateTimer(Time, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
	}
}

static Action Huscarls_Particle_StartTouch(int entity, int target)
{
	return Plugin_Handled;
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
			float flDistanceToTarget = GetVectorDistance(vecTarget, position, true);
			if(flDistanceToTarget < 62500.0)
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
		KillFeed_SetKillIcon(npc.index, "infection_emp");
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET, -1, _, vecHit);
		if(!IsInvuln(victim))
		{
			if(IsValidClient(victim))
				if(!HasSpecificBuff(victim, "Fluid Movement"))
					TF2_StunPlayer(victim, 0.2, 0.8, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);
			if(!HasSpecificBuff(victim, "Solid Stance"))
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

static void HuscarlIntoAir(Huscarls npc, bool ReAime)
{
	static bool ImAirBone;
	switch(npc.m_iChanged_WalkCycle)
	{
		case 0:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_MELEE");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					ImAirBone=false;
				}
			}
		}
	}
}

static bool Victoria_Support(Huscarls npc)
{
	float GameTime = GetGameTime(npc.index);
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;
	Vs_DelayTime[npc.index] = GameTime + 0.1;
	
	Vs_Target[npc.index] = Victoria_GetTargetDistance(npc.index, false, false);
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
		spawnRing_Vectors(Vs_Temp_Pos[npc.index], (1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0)), 0.0, 0.0, 0.0, LASERBEAM, 255, 255, 255, 150, 1, 0.1, 3.0, 0.1, 3);
		float position2[3];
		position2[0] = Vs_Temp_Pos[npc.index][0];
		position2[1] = Vs_Temp_Pos[npc.index][1];
		position2[2] = Vs_Temp_Pos[npc.index][2] + 65.0;
		spawnRing_Vectors(position2, 1000.0, 0.0, 0.0, 0.0, LASERBEAM, 145, 47, 47, 150, 1, 0.1, 3.0, 0.1, 3);
		spawnRing_Vectors(Vs_Temp_Pos[npc.index], 1000.0, 0.0, 0.0, 0.0, LASERBEAM, 145, 47, 47, 150, 1, 0.1, 3.0, 0.1, 3);
		TE_SetupBeamPoints(Vs_Temp_Pos[npc.index], position, g_Laser, -1, 0, 0, 0.1, 0.0, 25.0, 0, 0.0, {145, 47, 47, 150}, 3);
		TE_SendToAll();
		TE_SetupGlowSprite(Vs_Temp_Pos[npc.index], g_RedPoint, 0.1, 1.0, 255);
		TE_SendToAll();
		if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0) && !IsValidEntity(Vs_ParticleSpawned[npc.index]))
		{
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
		KillFeed_SetKillIcon(npc.index, "megaton");
		Explode_Logic_Custom(125.0*RaidModeScaling, 0, npc.index, -1, position, 500.0, 1.0, _, true, 20);
		
		ParticleEffectAt(position, "hightower_explosion", 1.0);
		i_ExplosiveProjectileHexArray[npc.index] = 0; 
		npc.PlayBoomSound();
		Vs_RechargeTime[npc.index]=0.0;
		Vs_RechargeTime[npc.index]=0.0;
		return true;
	}
	return false;
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
			ApplyStatusEffect(npc.index, npc.index, "Intangible", 5.0);
			b_angered_twice[npc.index]=false;
		}
	}
}
static void NPC_Go_away(int entity, int victim, float damage, int weapon)
{
	Huscarls npc = view_as<Huscarls>(entity);
	float vecHit[3]; WorldSpaceCenter(victim, vecHit);
	if(IsValidEntity(npc.index) && IsValidEntity(victim) && !IsValidClient(victim) && GetTeam(npc.index) != GetTeam(victim))
	{
		KillFeed_SetKillIcon(npc.index, "vehicle");
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
		float flPos[3]; GetAbsOrigin(npc.index, flPos);
		flPos[2]+=5.0;
		TeleportEntity(victim, flPos, NULL_VECTOR, NULL_VECTOR);
		damage = 50.0 * RaidModeScaling;
		damage += ReturnEntityMaxHealth(victim)*0.715;
		KillFeed_SetKillIcon(npc.index, "vehicle");
		SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
		ApplyStatusEffect(victim, victim, "Intangible", 1.0);
		if(IsValidClient(victim))
		{
			//Attempt teleport twice to avoid getting stuck in walls.
			GetAbsOrigin(victim, flPos);
			Player_Teleport_Safe(victim, flPos);
			Player_Teleport_Safe(victim, flPos);
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
		damage += ReturnEntityMaxHealth(victim)*0.35;
		KillFeed_SetKillIcon(npc.index, "apocofists");
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
		damage += ReturnEntityMaxHealth(victim)*0.35;
		KillFeed_SetKillIcon(npc.index, "mentreads");
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
					TF2_StunPlayer(victim, 1.5, 0.85, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);
			if(!HasSpecificBuff(victim, "Solid Stance"))
				Custom_Knockback(entity, victim, 720.0, true);
		}
		else Custom_Knockback(entity, victim, 1440.0, true);
	}
}

static bool TinCan_Raid(Huscarls npc, float gameTime)
{
	static bool FullySpawnTinCan;
	static bool MyGundammmmmm;
	if(!FullySpawnTinCan)
	{
		MyGundammmmmm=false;
		switch(npc.m_iState)
		{
			case 0:
			{
				NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_Pre_2_Phase", false, false);
				npc.AddActivityViaSequence("tauntrussian_rubdown");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(1.0);
				npc.m_flDoingAnimation = gameTime + 0.5;
				npc.m_iState=1;
			}
			case 1, 2, 3:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.SetPlaybackRate(0.0);
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					int spawn_index = NPC_CreateByName("npc_avangard", -1, VecSelfNpc, {0.0,0.0,0.0}, GetTeam(npc.index), "only imcomplete");
					if(spawn_index > MaxClients)
					{
						if(GetTeam(npc.index) != TFTeam_Red)
							Zombies_Currently_Still_Ongoing++;
						NpcStats_CopyStats(npc.index, spawn_index);
						int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.15);
						fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
						fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
						fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index];
						fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index];
						if(GetTeam(npc.index) != TFTeam_Red)
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
						i_AttacksTillMegahit[spawn_index] = 600;
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
						strcopy(c_NpcName[spawn_index], sizeof(c_NpcName[]), "Imcomplete Avangard");
						npc.SaveLifeSupportDevice(spawn_index, npc.m_iState);
						view_as<CClotBody>(spawn_index).m_iWearable7=ConnectWithBeam(npc.index, spawn_index, 255, 215, 0, 1.5, 1.5, 0.0, LASERBEAM);
						
						int Decicion = TeleportDiversioToRandLocation(spawn_index,_,1750.0, 750.0);

						if(Decicion == 2)
							Decicion = TeleportDiversioToRandLocation(spawn_index, _, 750.0, 500.0);

						if(Decicion == 2)
							Decicion = TeleportDiversioToRandLocation(spawn_index, _, 500.0, 0.0);

						npc.PlayTeleportSound();
					}
					for(int i = 1; i <= 3; i++)
					{
						int TinCan=npc.LoadLifeSupportDevice(i);
						if(IsValidEntity(TinCan)&& i_NpcInternalId[TinCan] == VictorianAvangard_ID()
						&& !b_NpcHasDied[TinCan] && GetTeam(TinCan) == GetTeam(npc.index))
						{
							FreezeNpcInTime(TinCan, 1.6, true);
							IncreaseEntityDamageTakenBy(TinCan, 0.000001, 1.6);
						}
					}
					npc.m_flDoingAnimation = gameTime + 1.5;
					npc.m_iState++;
				}
			}
			case 4:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					npc.AddActivityViaSequence("tauntrussian_rubdown_outro");
					npc.SetPlaybackRate(1.0);
					npc.m_flDoingAnimation = gameTime + 1.5;
					npc.m_iState=5;
					for(int i = 1; i <= 3; i++)
					{
						int TinCan=npc.LoadLifeSupportDevice(i);
						if(IsValidEntity(TinCan)&& i_NpcInternalId[TinCan] == VictorianAvangard_ID()
						&& !b_NpcHasDied[TinCan] && GetTeam(TinCan) == GetTeam(npc.index))
						{
							FreezeNpcInTime(TinCan, 1.6, true);
							IncreaseEntityDamageTakenBy(TinCan, 0.000001, 1.6);
						}
					}
				}
			}
			case 5:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					EmitSoundToAll("mvm/mvm_tank_horn.wav", _, _, _, _, 1.0);
					npc.PlayBotArrivedSound();
					npc.m_iState=-1;
					FullySpawnTinCan=true;
				}
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		npc.m_flNextRangedBarrage_Singular += 0.1;
		return true;
	}
	else if(!MyGundammmmmm)
	{
		bool StillAlive=false;
		for(int i = 1; i <= 3; i++)
		{
			int TinCan=npc.LoadLifeSupportDevice(i);
			if(IsValidEntity(TinCan)&& i_NpcInternalId[TinCan] == VictorianAvangard_ID()
			&& !b_NpcHasDied[TinCan] && GetTeam(TinCan) == GetTeam(npc.index))
				StillAlive=true;
		}
		if(!StillAlive)
		{
			MyGundammmmmm=true;
			npc.m_iState=0;
			return true;
		}
	}
	else
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				RaidModeTime += 40.0;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flHuscarlsRushCoolDown += 4.0;
				npc.m_flHuscarlsAdaptiveArmorCoolDown += 4.0;
				npc.m_flHuscarlsDeployEnergyShieldCoolDown += 4.0;
				npc.m_flHuscarlsGroundSlamCoolDown += 4.0;
				npc.m_flNextRangedBarrage_Singular += 4.0;
				npc.m_flAttackHappens = 0.0;
				npc.m_flDoingAnimation = gameTime + 1.0;
				switch(GetRandomInt(0, 1))
				{
					case 0:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_2_Phase-1", false, false);
					case 1:NPCPritToChat(npc.index, "{lightblue}", "Huscarls_Talk_2_Phase-2", false, false);
				}
				npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
				npc.AddActivityViaSequence("layer_taunt_soviet_showoff");
				npc.SetCycle(0.65);
				npc.SetPlaybackRate(1.2);
				npc.PlayAngerSound();
				npc.m_iState=1;
			}
			case 1:
			{
				if(npc.m_flDoingAnimation < gameTime)
				{
					int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
					SetEntProp(npc.index, Prop_Data, "m_iHealth", health+RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.1));
					SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(npc.index)+RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 0.25));
					b_NpcIsInvulnerable[npc.index] = false;
					ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
					FullySpawnTinCan=false;
					npc.m_bFUCKYOU_move_anim=false;
				}
			}
		}
		npc.m_flHuscarlsRushCoolDown += 0.1;
		npc.m_flHuscarlsAdaptiveArmorCoolDown += 0.1;
		npc.m_flHuscarlsDeployEnergyShieldCoolDown += 0.1;
		npc.m_flHuscarlsGroundSlamCoolDown += 0.1;
		npc.m_flNextRangedBarrage_Singular += 0.1;
		return true;
	}
	return false;
}

static void HuscarlsGrab(Huscarls npc, float gameTime)
{
	static float EnemyPos[3];
	static float pos[3]; 
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float Range = (NpcStats_VictorianCallToArms(npc.index) ? 450.0 : 325.0);
	spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 5.0, LASERBEAM, 220, 220, 255, 150, 1, 0.1, 3.0, 0.1, 3);
	spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 25.0, LASERBEAM, 220, 220, 255, 150, 1, 0.1, 3.0, 0.1, 3);
	spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 45.0, LASERBEAM, 220, 220, 255, 150, 1, 0.1, 3.0, 0.1, 3);
	
	for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
	{
		if(IsValidEnemy(npc.index, EnemyLoop))
		{
			GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
			float Distance = GetVectorDistance(pos, EnemyPos, true);
			if(Distance < (Range * Range))
			{
				if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && !HasSpecificBuff(EnemyLoop, "Solid Stance"))
				{
					int red = 220;
					int green = 220;
					int blue = 255;
					if(EnemyLoop == npc.m_iTarget)
					{
						red = 255;
						green = 65;
						blue = 65;
					}
					if(!IsValidEntity(GrabPlayer[EnemyLoop]))
					{
						if(IsValidEntity(GrabPlayer[EnemyLoop]))
							RemoveEntity(GrabPlayer[EnemyLoop]);

						int laser;
						laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 1.5, 1.5, 0.0, LASERBEAM);
			
						GrabPlayer[EnemyLoop] = EntIndexToEntRef(laser);
					}
					else
					{
						int laser = EntRefToEntIndex(GrabPlayer[EnemyLoop]);
						SetEntityRenderColor(laser, red, green, blue, 255);
					}
				}
				else
				{
					if(IsValidEntity(GrabPlayer[EnemyLoop]))
						RemoveEntity(GrabPlayer[EnemyLoop]);
				}
			}
			else
			{
				if(IsValidEntity(GrabPlayer[EnemyLoop]))
					RemoveEntity(GrabPlayer[EnemyLoop]);
			}
		}
		else
		{
			if(IsValidEntity(GrabPlayer[EnemyLoop]))
				RemoveEntity(GrabPlayer[EnemyLoop]);
		}
	}
	
	if(npc.m_flHuscarlsRushCoolDown-0.4 < gameTime)
	{
		static float flPos[3]; 
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 5.0;
		//npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
		ParticleEffectAt(flPos, "taunt_yeti_fistslam", 0.25);
		npc.PlayKaboomSound();
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
				float Distance = GetVectorDistance(pos, EnemyPos);
				if(Distance < Range)
				{
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && !HasSpecificBuff(EnemyLoop, "Solid Stance"))
					{
						static float angles[3];
						GetVectorAnglesTwoPoints(EnemyPos, pos, angles);

						if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
							angles[0] = 0.0;

						static float velocity[3];
						GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
						float attraction_intencity = 1.50;
						ScaleVector(velocity, Distance * attraction_intencity);
						
						if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
							velocity[2] = fmax(325.0, velocity[2]);
						
						TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);   
						if(EnemyLoop == npc.m_iTarget)
						{
							TF2_AddCondition(EnemyLoop, TFCond_HalloweenKartNoTurn, 0.2, 0);
							TF2_AddCondition(EnemyLoop, TFCond_CompetitiveLoser, 0.2, 0);
							TF2_AddCondition(EnemyLoop, TFCond_LostFooting, 0.5);
							TF2_AddCondition(EnemyLoop, TFCond_AirCurrent, 0.5);
						}
					}
				}
			}
			if(IsValidEntity(GrabPlayer[EnemyLoop]))
				RemoveEntity(GrabPlayer[EnemyLoop]);
			b_angered_twice[npc.index] = false;
		}
	}
}