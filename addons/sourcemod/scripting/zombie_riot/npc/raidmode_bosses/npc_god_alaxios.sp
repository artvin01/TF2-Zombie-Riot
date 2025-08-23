#pragma semicolon 1
#pragma newdecls required

static bool BlockLoseSay;

static const char g_DeathSounds[][] = {
	"zombiesurvival/medieval_raid/arkantos_death.mp3",
};

static const char g_HurtSounds[][] = {
	"zombiesurvival/medieval_raid/arkantos_hurt_1.mp3",
	"zombiesurvival/medieval_raid/arkantos_hurt_2.mp3",
};


static const char g_SeaDeathSounds[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_death.mp3",
};

static const char g_SeaHurtSounds[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_hurt_1.mp3",
	"zombiesurvival/medieval_raid/special_mutation/arkantos_hurt_2.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};


static char g_SlamSounds[][] = {
	"ambient/rottenburg/barrier_smash.wav"
};

static char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};

static char g_LastStand[][] = {
	"zombiesurvival/medieval_raid/arkantos_rage.mp3",
};
static char g_SeaLastStand[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_rage.mp3",
};

static char g_RandomGroupScream[][] = {
	"zombiesurvival/medieval_raid/battlecry1.mp3",
	"zombiesurvival/medieval_raid/battlecry2.mp3",
	"zombiesurvival/medieval_raid/battlecry3.mp3",
	"zombiesurvival/medieval_raid/battlecry4.mp3",
};

static char g_RandomGroupScreamSea[][] = {
	"zombiesurvival/medieval_raid/special_mutation/battlecry1.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry2.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry3.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry4.mp3",
};
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

#define SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE	"misc/halloween/spell_mirv_explode_primary.wav"

#define ALAXIOS_BUFF_MAXRANGE 500.0

#define ALAXIOS_SEA_INFECTED 555
int RevertResearchLogic = 0;
static int NPCId;
static int NPCId2;
public void GodAlaxios_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "God Alaxios");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_god_alaxios");
	strcopy(data.Icon, sizeof(data.Icon), "alaxios");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);

	//different due to differnt precaches
	strcopy(data.Name, sizeof(data.Name), "Sea-Infected God Alaxios");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sea_god_alaxios");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache_SeaAlaxios;
	NPCId2 = NPC_Add(data);


	for (int i = 0; i < (sizeof(g_RandomGroupScream));   i++) { PrecacheSoundCustom(g_RandomGroupScream[i]);   }
	RevertResearchLogic = 0;
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSoundCustom(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSoundCustom(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));        i++) { PrecacheSound(g_MeleeHitSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));        i++) { PrecacheSound(g_MeleeAttackSounds[i]);        }
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));        i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SlamSounds));        i++) { PrecacheSound(g_SlamSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SummonSounds));        i++) { PrecacheSound(g_SummonSounds[i]);        }
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
	PrecacheSoundCustom("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3");
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	for (int i = 0; i < (sizeof(g_LastStand));   i++) { PrecacheSoundCustom(g_LastStand[i]);   }
}

static void ClotPrecache_SeaAlaxios()
{
	for (int i = 0; i < (sizeof(g_SeaDeathSounds));       i++) { PrecacheSoundCustom(g_SeaDeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_SeaHurtSounds));        i++) { PrecacheSoundCustom(g_SeaHurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));        i++) { PrecacheSound(g_MeleeHitSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));        i++) { PrecacheSound(g_MeleeAttackSounds[i]);        }
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));        i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SlamSounds));        i++) { PrecacheSound(g_SlamSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SummonSounds));        i++) { PrecacheSound(g_SummonSounds[i]);        }
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/special_mutation/kazimierz_boss.mp3");
	PrecacheSoundCustom("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3");
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RandomGroupScreamSea));   i++) { PrecacheSoundCustom(g_RandomGroupScreamSea[i]);   }
	for (int i = 0; i < (sizeof(g_SeaLastStand));   i++) { PrecacheSoundCustom(g_SeaLastStand[i]);   }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return GodAlaxios(vecPos, vecAng, team, data);
}
static float f_AlaxiosCantDieLimit[MAXENTITIES];

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

methodmap GodAlaxios < CClotBody
{
	property float m_flAlaxiosBuffEffect
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property float m_flReviveAlaxiosTime
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;

		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		
		if(i_RaidGrantExtra[this.index] == ALAXIOS_SEA_INFECTED)
		{
			EmitCustomToAll(g_SeaHurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaHurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
		else
		{
			EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(1.6, 2.5);
	}
	public void PlayDeathSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		if(i_RaidGrantExtra[this.index] == ALAXIOS_SEA_INFECTED)
		{
			EmitCustomToAll(g_SeaDeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaDeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaDeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaDeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		}
		else
		{
			EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeWarCry() 
	{
		if(i_RaidGrantExtra[this.index] != ALAXIOS_SEA_INFECTED)
		{
			EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		}
		else
		{
			EmitCustomToAll("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			EmitCustomToAll("zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		}
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.9, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.6, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 55.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 75.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	}
	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySlamSound() 
	{
		EmitSoundToAll(g_SlamSounds[GetRandomInt(0, sizeof(g_SlamSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRageSound() 
	{
		if(i_RaidGrantExtra[this.index] == ALAXIOS_SEA_INFECTED)
		{
			EmitCustomToAll(g_SeaLastStand[GetRandomInt(0, sizeof(g_SeaLastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaLastStand[GetRandomInt(0, sizeof(g_SeaLastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaLastStand[GetRandomInt(0, sizeof(g_SeaLastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_SeaLastStand[GetRandomInt(0, sizeof(g_SeaLastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		}
		else
		{
			EmitCustomToAll(g_LastStand[GetRandomInt(0, sizeof(g_LastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_LastStand[GetRandomInt(0, sizeof(g_LastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_LastStand[GetRandomInt(0, sizeof(g_LastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_LastStand[GetRandomInt(0, sizeof(g_LastStand) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	property float m_flAlaxiosSeaInfectedStance
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	public GodAlaxios(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		GodAlaxios npc = view_as<GodAlaxios>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "25000", ally, false, false, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Alaxios_Win);

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_bDissapearOnDeath = true;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RemoveAllDamageAddition();

		npc.m_iChanged_WalkCycle = 4;
		npc.SetActivity("ACT_WALK");
		npc.m_flSpeed = 320.0;
	
		npc.m_flMeleeArmor = 1.25;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				if(StrContains(data, "seainfection") != -1)
					ShowGameText(client_check, "item_armor", 1, "%t", "Sea Alaxios Arrived");
				else
					ShowGameText(client_check, "item_armor", 1, "%t", "Alaxios Arrived");
			}
		}

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
		if(StrContains(data, "seainfection") != -1)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = ALAXIOS_SEA_INFECTED;
		}
		RevertResearchLogic = 0;
		if(StrContains(data, "res1") != -1)
		{
			RevertResearchLogic = 1;
			Medival_Wave_Difficulty_Riser(1);
		}
		else if(StrContains(data, "res2") != -1)
		{
			RevertResearchLogic = 2;
			Medival_Wave_Difficulty_Riser(2);
		}
		else if(StrContains(data, "res3") != -1)
		{
			RevertResearchLogic = 3;
			Medival_Wave_Difficulty_Riser(3);
		}
		else if(StrContains(data, "res4") != -1)
		{
			RevertResearchLogic = 4;
			Medival_Wave_Difficulty_Riser(4);
		}
		else if(StrContains(data, "res5") != -1)
		{
			RevertResearchLogic = 5;
			Medival_Wave_Difficulty_Riser(5);
		}

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 6;
		}

		if(i_RaidGrantExtra[npc.index] >= 5)
		{
			RaidModeTime = GetGameTime(npc.index) + 300.0;
		}
		if(ally == TFTeam_Red)
		{
			RaidModeTime = GetGameTime(npc.index) + 9999.0;
			RaidAllowsBuildings = true;
		}
		if(Waves_InFreeplay())
		{
			RaidModeTime = GetGameTime(npc.index) + 9999999.0;
		}
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		if(StrContains(data, "seainfection") != -1)
			npc.m_iBleedType = BLEEDTYPE_SEABORN;

		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		b_angered_twice[npc.index] = false;

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
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
		
		npc.Anger = false;

		npc.m_flAlaxiosBuffEffect = GetGameTime() + 25.0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedAttack = GetGameTime() + 15.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.g_TimesSummoned = 0;
		f_AlaxiosCantDieLimit[npc.index] = 0.0;
		
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
		
		
		func_NPCDeath[npc.index] = GodAlaxios_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = GodAlaxios_OnTakeDamage;
		func_NPCThink[npc.index] = GodAlaxios_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, GodAlaxios_OnTakeDamagePost);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
		{
			SetEntityRenderColor(npc.index, 100, 100, 255, 255);
			SetEntityRenderColor(npc.m_iWearable1, 100, 100, 255, 255);
			SetEntityRenderColor(npc.m_iWearable2, 100, 100, 255, 255);
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/special_mutation/kazimierz_boss.mp3");
			music.Time = 189;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "lobotomy corp - insignia decay");
			strcopy(music.Artist, sizeof(music.Artist), "???");
			Music_SetRaidMusic(music);
		}
		else
		{
			
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
			music.Time = 189;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Arknights - Putrid");
			strcopy(music.Artist, sizeof(music.Artist), "Arknights");
			Music_SetRaidMusic(music);
		}
		Citizen_MiniBossSpawn();

		if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
		{
			RaidModeTime += 100.0;
		}
		

		//Sea version: lobotomy corp - insignia decay

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_wispy_parent_g", npc.index, "", {0.0,0.0,0.0});
		npc.StartPathing();

		DoGlobalMultiScaling();
		
		return npc;
	}
}


public void GodAlaxios_ClotThink(int iNPC)
{
	GodAlaxios npc = view_as<GodAlaxios>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
	{
		if(i_TalkDelayCheck > 0)
		{
			if(npc.m_flAlaxiosSeaInfectedStance < gameTime)
			{
				npc.m_flAlaxiosSeaInfectedStance = gameTime + 1.0;
				i_TalkDelayCheck--;
				switch(i_TalkDelayCheck)
				{
					case 4:
					{
						npc.m_bisWalking = false;
						npc.AddActivityViaSequence("Lucian_Death_Real");
						npc.SetPlaybackRate(0.75);	
						npc.PlayDeathSound();
						CPrintToChatAll("{lightblue}God Alaxios stands down... he is free...");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}...?");
					}
					case 2:
					{
						CPrintToChatAll("{lightblue}...!?!?!?");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}!");
					}
					case 0:
					{
						f_AttackSpeedNpcIncrease[npc.index] *= 0.75;
						fl_Extra_Damage[npc.index] *= 0.75;
						CPrintToChatAll("{crimson}The infection wont let go. It wants him the most.");
						b_NpcUnableToDie[npc.index] = false;
						RaidModeTime = GetGameTime(npc.index) + 150.0;
						RaidBossActive = EntIndexToEntRef(npc.index);
						RaidAllowsBuildings = false;
						npc.PlayRageSound();
						SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 4));
						static float flPos[3]; 
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						ApplyStatusEffect(npc.index, npc.index, "Oceanic Scream", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "Caffinated", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "Caffinated Drain", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "Ancient Melodies", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "War Cry", 999.0);
						ApplyStatusEffect(npc.index, npc.index, "UBERCHARGED", 1.0);
						flPos[2] += 5.0;
						ParticleEffectAt(flPos, "taunt_yeti_fistslam", 0.25);
						npc.m_iChanged_WalkCycle = 4;
						npc.SetActivity("ACT_WALK");
						npc.m_bisWalking = true;
						float EnemyPos[3];
						float Range = 500.0;
						//Kick everyone away in range, except the one target we hate, make sure to check line of sight too.
						for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
						{
							if(IsValidEnemy(npc.index, EnemyLoop))
							{
								GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
								float Distance = GetVectorDistance(flPos, EnemyPos);
								if(Distance < Range)
								{
									//only apply the laser if they are near us.
									if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && EnemyLoop == npc.m_iTargetWalkTo)
									{
										//Pull them.
										static float angles[3];
										GetVectorAnglesTwoPoints(EnemyPos, flPos, angles);

										if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
											angles[0] = 0.0; // toss out pitch if on ground

										static float velocity[3];
										GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
										float attraction_intencity = 1.50;
										ScaleVector(velocity, Distance * attraction_intencity);
														
														
										// min Z if on ground
										if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
											velocity[2] = fmax(325.0, velocity[2]);
													
										// apply velocity
										TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);   
									}
									else if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
									{
										float damage = 50.0;

										SDKHooks_TakeDamage(EnemyLoop, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, _);		
										if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
											Elemental_AddNervousDamage(EnemyLoop, npc.index, RoundToCeil(damage * RaidModeScaling * 0.1));
										//push them away.
										static float angles[3];
										GetVectorAnglesTwoPoints(EnemyPos, flPos, angles);

										if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
											angles[0] = 0.0; // toss out pitch if on ground

										static float velocity[3];
										GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
										float attraction_intencity = 1500.0;
										ScaleVector(velocity, attraction_intencity);
														
														
										// min Z if on ground
										if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
										{
											velocity[2] = 350.0;
										}
										else
										{
											velocity[2] = 200.0;
										}
													
										// apply velocity
										velocity[0] *= -1.0;
										velocity[1] *= -1.0;
									//	velocity[2] *= -1.0;
										TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);    	
									}
								}
							}
						}
					}
				}
			}
			return;
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}God Alaxios{crimson}: STOP BEING SO WEAK, HELP ME!!!!!");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}God Alaxios{crimson}: IM UNDER CONTROLL, HELP ME.....");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}God Alaxios{crimson}: THIS THING IS TOO MUCH, HELP!!!!!!!!!");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{lightblue}God Alaxios{default}: You have no chance alone!");
					}
					case 1:
					{
						CPrintToChatAll("{lightblue}God Alaxios{default}: Your weaponry frails in comparison to Atlantis!!");
					}
					case 3:
					{
						CPrintToChatAll("{lightblue}God Alaxios{default}: Consider surrendering?!");
					}
				}
			}
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (9 * 2);
		
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		if(i_RaidGrantExtra[npc.index] != ALAXIOS_SEA_INFECTED)
		{
			for(int targ; targ<i_MaxcountNpcTotal; targ++)
			{
				int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
				if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
				{
					SetTeam(baseboss_index, TFTeam_Red);
					SetEntityCollisionGroup(baseboss_index, 24);
				}
			}
			CPrintToChatAll("{lightblue}God Alaxios{default}: No.. No No!! They are coming, prepare to fight together NOW!!!");
			RaidBossActive = INVALID_ENT_REFERENCE;
			for(int i; i<32; i++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				int Spawner_entity = GetRandomActiveSpawner();
				if(IsValidEntity(Spawner_entity))
				{
					GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
				}
				int spawn_index = NPC_CreateByName("npc_seaslider", -1, pos, ang, TFTeam_Blue);
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
					fl_Extra_Damage[spawn_index] = 25.0;
					fl_Extra_Speed[spawn_index] = 1.5;
				}
			}
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			}
			int spawn_index = NPC_CreateByName("npc_isharmla", -1, pos, ang, TFTeam_Blue);
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 100000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 100000000);
				fl_Extra_Damage[spawn_index] = 25.0;
				fl_Extra_Speed[spawn_index] = 1.5;
			}
		}
		else
		{

			CPrintToChatAll("{green}The Xeno infection sides with you...??!\nSuddenly a battle ensues between Xeno and the Sea infection with alaxios in possession..");
			for(int i; i<32; i++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				int Spawner_entity = GetRandomActiveSpawner();
				if(IsValidEntity(Spawner_entity))
				{
					GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
				}
				int spawn_index = NPC_CreateByName("npc_xeno_acclaimed_swordsman", -1, pos, ang, TFTeam_Red);
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
					fl_Extra_Damage[spawn_index] = 25.0;
					fl_Extra_Speed[spawn_index] = 1.5;
					TeleportNpcToRandomPlayer(spawn_index);
				}
			}
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			}
			int spawn_index = NPC_CreateByName("npc_xeno_raidboss_nemesis", -1, pos, ang, TFTeam_Red);
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 100000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 100000000);
				fl_Extra_Damage[spawn_index] = 25.0;
				fl_Extra_Speed[spawn_index] = 1.5;
				TeleportNpcToRandomPlayer(spawn_index);
			}
			RaidBossActive = EntIndexToEntRef(npc.index);
		}
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		return;
	}
	if(i_RaidGrantExtra[npc.index] != ALAXIOS_SEA_INFECTED && b_angered_twice[npc.index])
	{
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		int closestTarget = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(closestTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
		npc.SetActivity("ACT_IDLE");
		npc.m_bisWalking = false;
		npc.StopPathing();
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
			{
				TF2_StunPlayer(client, 0.5, 0.5, TF_STUNFLAGS_LOSERSTATE);
			}
		}
		if(AlaxiosForceTalk())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(f_AlaxiosCantDieLimit[npc.index] && f_AlaxiosCantDieLimit[npc.index] < GetGameTime())
	{
		int RandSound = GetRandomInt(0, sizeof(g_RandomGroupScream) - 1);
		if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
		{
			EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		}
		else
		{
			EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
			EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		}
		f_AlaxiosCantDieLimit[npc.index] = 0.0;
	}
	if(npc.m_flSpeed >= 1.0)
	{
		if(HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 220.0;
		}
		else if(!HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 320.0;
		}	
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoingSpecial < gameTime)
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}
	else
	{
		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.65;
	}		


	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && i_NpcInternalId[baseboss_index] != NPCId2 && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			if(!npc.Anger)
			{
				npc.PlayRageSound();
				AlaxiosSayWordsAngry(npc.index);
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) * 6) / 7);
			}
		}
	}

	if(GetTeam(npc.index) == TFTeam_Red)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			if(f_TargetToWalkToDelay[npc.index] < gameTime)
			{
				npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
				if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
				{
					npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
				}
			}
			else 
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
			f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;	
		}	
	}
	
	if(f_TargetToWalkToDelay[npc.index] < gameTime)
	{
		if(npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && !npc.m_flNextRangedAttackHappening && i_RaidGrantExtra[npc.index] >= 4)
		{
			npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
			if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
		}
		else 
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		}
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;
	}	
	int ActionToTake = -1;
	bool AllowSelfDefense = true;
	//This means nothing, we do nothing.
	if(IsEntityAlive(npc.m_iTargetWalkTo))
	{
		//Predict their pos.
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
		}

		if(npc.m_flNextRangedAttackHappening > GetGameTime(npc.index))
		{
			ActionToTake = -1;
		}	
		else if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo) && !(i_RaidGrantExtra[npc.index] >= 4 && npc.Anger && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index)))
		{
			if(flDistanceToTarget < (500.0 * 500.0) && flDistanceToTarget > (250.0 * 250.0) && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				ActionToTake = 1;
				//first we try to jump to them if close enough.
			}
			else if(flDistanceToTarget < (250.0 * 250.0) && npc.m_flNextRangedAttack < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 3)
			{
				//We are pretty close, we will do a wirlwind to kick everyone away after a certain amount of delay so they can prepare.
				ActionToTake = 2;
			}
		}
		else if(IsValidAlly(npc.index, npc.m_iTargetWalkTo) || npc.Anger)
		{
			if((npc.Anger || flDistanceToTarget < (125.0* 125.0)) && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 4)
			{
				//can only be above wave 15.
				ActionToTake = -1;
				GodAlaxiosAOEBuff(npc,GetGameTime(npc.index));
			}
		}
		else
		{
			ActionToTake = -1; //somethings wrong, do nothing.
		}

		switch(ActionToTake)
		{
			case 1:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				npc.PlayPullSound();
				flPos[2] += 500.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				
				npc.m_flSpeed = 0.0;
				if(npc.m_bPathing)
				{
					npc.StopPathing();
					
				}
				if(npc.m_iChanged_WalkCycle != 8) 	
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_JUMP");
					npc.m_bisWalking = false;
					npc.SetPlaybackRate(1.0);
					npc.m_iTarget = -1;
				}
				
				npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.5;
				if(npc.Anger)
					npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.0;

				if(npc.g_TimesSummoned == 4)
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
				}
				else
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 20.0;
				}
				if(npc.Anger)
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 7.0;

				npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0; //lets not intiate any new ability for a second.
				npc.m_fbRangedSpecialOn = true;
				//just jump at them.
			}
			case 2:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 3.0);
				SetParent(npc.index, particle, "effect_hand_r");
				npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 3.0; //3 seconds to prepare.
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 20.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 4.5; //lets not intiate any new ability for a second.
				if(npc.Anger)
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 10.0;
					npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 1.5; //1.5 seconds to prepare.
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5; //lets not intiate any new ability for a second.
				}
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;		
	}
	if(AllowSelfDefense)
	{
		GodAlaxiosSelfDefense(npc, gameTime);
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;
	GodAlaxiosHurricane(npc, gameTime);
	GodAlaxiosJumpSpecial(npc, gameTime);

}
	
public Action GodAlaxios_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	GodAlaxios npc = view_as<GodAlaxios>(victim);
	if(npc.m_flReviveAlaxiosTime > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!npc.Anger)
	{
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
		if(health < 1)
		{
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	
	if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
	{
		if(GetTeam(npc.index) != TFTeam_Red && !b_angered_twice[npc.index] && b_NpcUnableToDie[npc.index])
		{
			if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
			{
				GiveProgressDelay(55.0);
				b_angered_twice[npc.index] = true;
				RaidModeTime = 9999999.9;
				RaidBossActive = INVALID_ENT_REFERENCE;
				i_TalkDelayCheck = 5;
			}
		}
		return Plugin_Changed;
	}
	if(GetTeam(npc.index) != TFTeam_Red && !b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
			b_angered_twice[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(55.0);
			damage = 0.0;
			RaidModeTime += 120.0;
			f_TalkDelayCheck = GetGameTime() + 4.0;
			CPrintToChatAll("{lightblue}God Alaxios{crimson}: EEEEEEEEEEEEEEENOOOOOOOOUGH!!!");
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}

public void GodAlaxios_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	GodAlaxios npc = view_as<GodAlaxios>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(i_RaidGrantExtra[npc.index] <= 2)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(7.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_scout",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_scout",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 3)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_brawler",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_pikeman",_, RoundToCeil(15.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow_giant",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalHealthBoss), RoundToCeil(2.0 * MultiGlobalEnemyBoss), true);				
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 4)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_longbowmen",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",_, RoundToCeil(2.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_obuch",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(2500.0 * MultiGlobalHighHealthBoss), 1, true);		
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(125000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else
	{
		if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
		{
			if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
			{
				npc.g_TimesSummoned = 1;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_kazimersch_knight",100000, RoundToCeil(6.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_kazimersch_archer",50000, RoundToCeil(12.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_kazimersch_melee_assasin",75000, RoundToCeil(4.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
			{
				npc.g_TimesSummoned = 2;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_vanguard",25000, RoundToCeil(2.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_defender",60000, RoundToCeil(12.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
			{
				npc.g_TimesSummoned = 3;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_medic",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_guard",100000, RoundToCeil(10.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_kazimersch_beserker",200000, RoundToCeil(2.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_pathshaper", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
			}
			else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
				AlaxiosSayWords(npc.index);
				npc.g_TimesSummoned = 4;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_vanguard",50000, RoundToCeil(1.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_kazimersch_longrange",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_netherseapredator",70000, RoundToCeil(20.0 * MultiGlobalEnemy));	
				GodAlaxiosSpawnEnemy(npc.index,"npc_netherseaspewer",50000, RoundToCeil(20.0 * MultiGlobalEnemy));	
				GodAlaxiosSpawnEnemy(npc.index,"npc_isharmla", RoundToCeil(1000000.0 * MultiGlobalHighHealthBoss), 1, true);	
				GodAlaxiosSpawnEnemy(npc.index,"npc_seaborn_specialist",7000, RoundToCeil(20.0 * MultiGlobalEnemy));	
			}	
		}
		else
		{
			if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
			{
				npc.g_TimesSummoned = 1;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(6.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_arbalest",50000, RoundToCeil(12.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_longbowmen",50000, RoundToCeil(4.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
			{
				npc.g_TimesSummoned = 2;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_samurai",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
			{
				npc.g_TimesSummoned = 3;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_paladin",100000, RoundToCeil(10.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",250000, RoundToCeil(2.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
			}
			else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
				AlaxiosSayWords(npc.index);
				npc.g_TimesSummoned = 4;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",100000, RoundToCeil(2.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_riddenarcher",75000, RoundToCeil(20.0 * MultiGlobalEnemy));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(50000.0 * MultiGlobalHighHealthBoss), 1);
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_son_of_osiris", RoundToCeil(1200000.0 * MultiGlobalHighHealthBoss), 1, true);		
			}			
		}
	}
}

public void GodAlaxios_NPCDeath(int entity)
{
	GodAlaxios npc = view_as<GodAlaxios>(entity);
	if(RevertResearchLogic >= 1)
	{
		RevertResearchLogic = 0;
		Medival_Wave_Difficulty_Riser(0); // Refresh me !!!
	}
	if(!BlockLoseSay)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
		TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		npc.PlayDeathSound();
			
		if(i_RaidGrantExtra[npc.index] != ALAXIOS_SEA_INFECTED)
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: I have failed Atlantis...");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: How was my army defeated..?");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: You dont know what you are doing!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: We should be fighting together, not against each other, the {blue}sea{default} will be your doom...");
				}
			}
		}
		else
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: Im.. im free..?");
			CPrintToChatAll("{lightblue}God Alaxios instnatly leaves the battlefield... you couldnt even trace him.");
		}
	}
	else
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
		TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
	}
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
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

	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}		
	}

	Citizen_MiniBossDeath(entity);
}

void GodAlaxiosSpawnEnemy(int alaxios, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(alaxios) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(alaxios, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(alaxios, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(alaxios));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(alaxios);
	
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[enemy.Index], npc_classname, sizeof(npc_classname));

		Freeplay_AddEnemy(postWaves, enemy, count, true);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}

void GodAlaxiosSelfDefense(GodAlaxios npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
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
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
										
							float damage = 20.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);	
							if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(damage * RaidModeScaling * 0.1));							
							
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
									if(!HasSpecificBuff(npc.index, "Godly Motivation"))
									{
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, target, 150.0, true); 
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

					npc.AddGesture("ACT_ARKANTOS_ATTACK_FAST");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
					if(npc.Anger)
					{
						npc.m_flAttackHappens = gameTime + 0.125;
						npc.m_flDoingAnimation = gameTime + 0.125;
						npc.m_flNextMeleeAttack = gameTime + 0.35;
						int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
						for(int i; i < layerCount; i++)
						{
							view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 2.0);
						}
					}
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
				npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

void GodAlaxiosJumpSpecial(GodAlaxios npc, float gameTime)
{
	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		static float ThrowPos[3]; 
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true); //only visible targets!
		}
		float Range = 150.0;
		
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			static float enemypos[3]; 
			GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", enemypos);
			enemypos[2] += 45.0;
			if(npc.m_flNextRangedSpecialAttackHappens > gameTime + 0.5 && npc.m_fbRangedSpecialOn)
			{
				ThrowPos = enemypos;
			}
			npc.FaceTowards(ThrowPos, 15000.0);
			static float selfpos[3]; 
			float flAng[3]; // original
		
			int r = 200;
			int g = 200;
			int b = 255;
			float diameter = 25.0;
			
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 200);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 200);

			npc.GetAttachment("weapon_bone", selfpos, flAng);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			spawnRing_Vectors(ThrowPos, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.15, 5.0, 0.0, 1);	
		}
		
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime + 0.5 && npc.m_fbRangedSpecialOn)
		{
			npc.AddGesture("ACT_CUSTOM_ATTACK_SPEAR");
			npc.m_fbRangedSpecialOn = false;
		}

		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			npc.FaceTowards(ThrowPos, 15000.0);
			npc.m_flNextRangedSpecialAttackHappens = 0.0;
			static float selfpos[3]; 
			float flAng[3]; // original
			
			
			npc.GetAttachment("weapon_bone", selfpos, flAng);
			//throw extreamly powerfull spear/laser lighting whatever.	
			EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
			EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
			int r = 200;
			int g = 200;
			int b = 255;
			float diameter = 25.0;
				
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 200);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 0.9, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 0.8, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Laser, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 150);
			TE_SetupBeamPoints(selfpos, ThrowPos, g_Ruina_BEAM_Glow, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
			spawnRing_Vectors(ThrowPos, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.5, 5.0, 0.0, 1,Range * 2.0);	
			float damage = 600.0;
				
			Explode_Logic_Custom(damage, 0, npc.index, -1, ThrowPos,Range, 1.0, _, true, 20);
			TE_Particle("asplode_hoodoo", ThrowPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
				SeaFounder_SpawnNethersea(ThrowPos);
			
			npc.SetVelocity({0.0,0.0,-1000.0});

			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_WALK");
				npc.StartPathing();
				npc.m_flSpeed = 320.0;
				npc.m_bisWalking = true;
			}
		}
	}
}

void GodAlaxiosHurricane(GodAlaxios npc, float gameTime)
{
	if(npc.m_flNextRangedAttackHappening)
	{
		static float EnemyPos[3];
		static float pos[3]; 
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float Range = 500.0;
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		//Apply an Connection beam.
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
				float Distance = GetVectorDistance(pos, EnemyPos, true);
				if(Distance < (Range * Range))
				{
					//only apply the laser if they are near us.
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
					{
						int red = 65;
						int green = 65;
						int blue = 255;
						if(EnemyLoop == npc.m_iTargetWalkTo)
						{
							red = 220;
							green = 220;
							blue = 255;
						}
						if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							{
								RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
							}

							int laser;
							
							laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
				
							i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
							//Im seeing a new target, relocate laser particle.
						}
						else
						{
							int laser = EntRefToEntIndex(i_LaserEntityIndex[EnemyLoop]);
							SetEntityRenderColor(laser, red, green, blue, 255);
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
			}
			else
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}						
			}
		}
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
		{
			int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity_close))
			{
				if(IsValidEnemy(npc.index, entity_close))
				{
					GetEntPropVector(entity_close, Prop_Send, "m_vecOrigin", EnemyPos);
					float Distance = GetVectorDistance(pos, EnemyPos, true);
					if(Distance < (Range * Range))
					{
						//only apply the laser if they are near us.
						if(Can_I_See_Enemy_Only(npc.index, entity_close) && IsEntityAlive(entity_close))
						{
							int red = 65;
							int green = 65;
							int blue = 255;
							if(entity_close == npc.m_iTargetWalkTo)
							{
								red = 220;
								green = 220;
								blue = 255;
							}
							if(!IsValidEntity(i_LaserEntityIndex[entity_close]))
							{
								if(IsValidEntity(i_LaserEntityIndex[entity_close]))
								{
									RemoveEntity(i_LaserEntityIndex[entity_close]);
								}

								int laser;
								
								laser = ConnectWithBeam(npc.index, entity_close, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
					
								i_LaserEntityIndex[entity_close] = EntIndexToEntRef(laser);
								//Im seeing a new target, relocate laser particle.
							}
							else
							{
								int laser = EntRefToEntIndex(i_LaserEntityIndex[entity_close]);
								SetEntityRenderColor(laser, red, green, blue, 255);
							}
						}
						else
						{
							if(IsValidEntity(i_LaserEntityIndex[entity_close]))
							{
								RemoveEntity(i_LaserEntityIndex[entity_close]);
							}
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[entity_close]))
						{
							RemoveEntity(i_LaserEntityIndex[entity_close]);
						}
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[entity_close]))
					{
						RemoveEntity(i_LaserEntityIndex[entity_close]);
					}						
				}
			}
		}
		
		
		
		if(npc.m_flNextRangedAttackHappening < GetGameTime(npc.index))
		{
			npc.AddGesture("ACT_SEABORN_ATTACK_BESERK_1");
			npc.m_flDoingAnimation = gameTime + 0.5;
			npc.m_flNextRangedAttackHappening = 0.0;
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			ParticleEffectAt(flPos, "taunt_yeti_fistslam", 0.25);
			npc.PlaySlamSound();
			//Kick everyone away in range, except the one target we hate, make sure to check line of sight too.
			for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
			{
				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
					float Distance = GetVectorDistance(pos, EnemyPos);
					if(Distance < Range)
					{
						//only apply the laser if they are near us.
						if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && EnemyLoop == npc.m_iTargetWalkTo)
						{
							//Pull them.
							static float angles[3];
							GetVectorAnglesTwoPoints(EnemyPos, pos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1.50;
							ScaleVector(velocity, Distance * attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);   
						}
						else if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
						{
							float damage = 50.0;

							SDKHooks_TakeDamage(EnemyLoop, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, _);		
							if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
								Elemental_AddNervousDamage(EnemyLoop, npc.index, RoundToCeil(damage * RaidModeScaling * 0.1));
							//push them away.
							static float angles[3];
							GetVectorAnglesTwoPoints(EnemyPos, pos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1500.0;
							ScaleVector(velocity, attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
							{
								velocity[2] = 350.0;
							}
							else
							{
								velocity[2] = 200.0;
							}
										
							// apply velocity
							velocity[0] *= -1.0;
							velocity[1] *= -1.0;
						//	velocity[2] *= -1.0;
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);    	
						}
					}
				}
			}
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
			{
				int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity_close))
				{
					if(IsValidEnemy(npc.index, entity_close))
					{
						GetEntPropVector(entity_close, Prop_Send, "m_vecOrigin", EnemyPos);
						float Distance = GetVectorDistance(pos, EnemyPos, true);
						if(Distance < (Range * Range))
						{
							//only apply the laser if they are near us.
							if(Can_I_See_Enemy_Only(npc.index, entity_close) && IsEntityAlive(entity_close))
							{
								if(entity_close != npc.m_iTargetWalkTo)
								{
									CClotBody npcenemy = view_as<CClotBody>(entity_close);
									static float flPos_1[3]; 
									GetEntPropVector(npcenemy.index, Prop_Data, "m_vecAbsOrigin", flPos_1);
									flPos_1[2] += 500.0;
									npcenemy.SetVelocity({0.0,0.0,0.0});
									PluginBot_Jump(npcenemy.index, flPos_1);
									float damage = 50.0;
									SDKHooks_TakeDamage(entity_close, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, _);	
									if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
										Elemental_AddNervousDamage(entity_close, npc.index, RoundToCeil(damage * RaidModeScaling * 0.1));
								}
							}
						}
					}
				}
			}
			//Erase all lasers.
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}		
			}
		}
	}
}



void GodAlaxiosAOEBuff(GodAlaxios npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flAlaxiosBuffEffect < gameTime)
	{
		bool buffed_anyone;
		bool buffedAlly = false;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (ALAXIOS_BUFF_MAXRANGE * ALAXIOS_BUFF_MAXRANGE))
					{
						ApplyStatusEffect(npc.index, entitycount, "Godly Motivation", 10.0);
						//Buff this entity.
						buffed_anyone = true;	
						if(entitycount != npc.index)
						{
							buffedAlly = true;
						}
					}
				}
			}
		}
		if(npc.Anger)
			buffed_anyone = true;

		if(buffed_anyone)
		{
			if(buffedAlly)
				f_AlaxiosCantDieLimit[npc.index] = GetGameTime() + 1.0;

			npc.m_flAlaxiosBuffEffect = gameTime + 10.0;
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				ApplyStatusEffect(npc.index, npc.index, "Godly Motivation", 5.0);
			}
			else
			{
				ApplyStatusEffect(npc.index, npc.index, "Godly Motivation", 3.0);
			}
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				r = 220;
				g = 220;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, ALAXIOS_BUFF_MAXRANGE * 2.0);		
			npc.AddGestureViaSequence("g_wave");
			if(!mute)
			{
				spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayMeleeWarCry();
			}
		}
		else
		{
			npc.m_flAlaxiosBuffEffect = gameTime + 1.0; //Try again in a second.
		}
	}
}


void AlaxiosSayWords(int entity)
{
	if(i_RaidGrantExtra[entity] == ALAXIOS_SEA_INFECTED)
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios calls upon the infected.");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios attracts nearby creatures.");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios is reviving dead sea creatures.");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios is never alone, infected or not...");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: You don't know the dangers you're getting yourself into fighting me and my army at the same time!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: My army will always help me back up!");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: Me and my army, as one, will never be defeated!");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: Together for Atlantis! As one and for all!");
			}
		}
	}
}

void AlaxiosSayWordsAngry(int entity)
{
	if(!Waves_InFreeplay())
		RaidModeTime += 30.0;

	if(i_RaidGrantExtra[entity] == ALAXIOS_SEA_INFECTED)
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios Screams for help...");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios's head is under full controll, free him.");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios, even if strong, cant resist everything.");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}Free him, help him.");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}ISVOLI!!!! FOR THE PEOPLE!!!!!!!!!!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}ISVOLI!!!! FOR ALL THAT IS FORSAKEN!!!!!!!");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}ISVOLI!!!! FOR THE FUTURE!!!!!!!");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}ISVOLI!!!! FOR ATLANTIS!!!!!!!!!");
			}
		}
	}
}


bool AlaxiosForceTalk()
{
	if(i_TalkDelayCheck == 11)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 5.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				CPrintToChatAll("{lightblue}God Alaxios{default}: I will NOT tolerate this dispute any longer!");
				i_TalkDelayCheck += 1;
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: You have to understand, WE have a {blue}common enemy{default}, and that is {blue}Seaborn{default}.");
				i_TalkDelayCheck += 1;
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: More wars with each other means more opportunity for them to rise.");
				i_TalkDelayCheck += 1;
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: And whilst I am immortal and my army unkillable, we are not incorruptible.");
				i_TalkDelayCheck += 1;
			}
			case 4:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: However, I saw your prowess and your abilities.");
				i_TalkDelayCheck += 1;
			}
			case 5:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: You can wield {blue}Seaborn's{default} weapons without succumbing to their corruption, from what i can see atleast...");
				i_TalkDelayCheck += 1;
			}
			case 6:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: As such, we need your aid. YOU are our greatest opportunity to cleanse this world of watery horrors.");
				i_TalkDelayCheck += 1;
			}
			case 7:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: Of course, we will support you as much as we can. As one, we will thrive once again.");
				i_TalkDelayCheck += 1;
			}
			case 8:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: When you invade them, we will make sure that their main forces are distracted by us.");
				i_TalkDelayCheck += 1;
			}
			case 9:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: ALL HEIL THE MERCENARIES!! {crimson} FOR ATLANTISSSSS!!!!!!!!!!!!!!.");
				i_TalkDelayCheck = 11;
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						Items_GiveNamedItem(client, "Alaxios's Godly assistance");
						CPrintToChat(client, "{default}You feel something around you... and gained: {lightblue}''Alaxios's Godly assistance''{default}!");
					}
				}
			}
		}
	}
	return false;
}
public void Raidmode_Alaxios_Win(int entity)
{
	GodAlaxios npc = view_as<GodAlaxios>(entity);
	func_NPCThink[entity] = INVALID_FUNCTION;
	npc.m_bDissapearOnDeath = true;
	BlockLoseSay = true;
	
	if(i_RaidGrantExtra[npc.index] == ALAXIOS_SEA_INFECTED)
	{
		CPrintToChatAll("{lightblue}... You failed as expected, hopefully the xeno can put an end to the sea-Terror clan.");
		CPrintToChatAll("{crimson}The enemy of my enemy is my ally as they say.");
		CPrintToChatAll("{green}You thus offer yourself to the xeno infection to fight it......");
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: Atlantis will never fall!");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: I still have to take care of the {blue}deep sea{default}...");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: Threaten our livelyhood and you pay!");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: I have to inform {blue}Sensal{default} about this.");
			}
		}
	}
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}
