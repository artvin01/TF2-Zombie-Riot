#pragma semicolon 1
#pragma newdecls required

static float HealthMulti;
static int HealthBonus;
static int EnemyChance;
static int EnemyBosses;
static int ImmuneNuke;
static int CashBonus;
static float KillBonus;
static float MiniBossChance;
static bool HussarBuff;
static bool PernellBuff;
static int IceDebuff;
static int TeslarDebuff;
static int FusionBuff;
static int OceanBuff;
static int CrippleDebuff;
static int CudgelDebuff;
static int PerkMachine;
static int RaidFight;
static float SpeedMult;
static float MeleeMult;
static float RangedMult;
static int ExtraSkulls;
static int SkullTimes;
static bool ExplodingNPC;
static bool IsExplodeWave; // to prevent the message from popping up twice
static int ExplodeNPCDamage;
static int EnemyShields;
static int VoidBuff;
static bool VestaBuff;
static bool SquadBuff;
static bool Coffee;
static int StrangleDebuff;
static int ProsperityDebuff;
static bool SilenceDebuff;
static float ExtraEnemySize;
static bool UnlockedSpeed;
static bool CheesyPresence;
static int EloquenceBuff;
static int RampartBuff;
static int EloquenceBuffEnemies;
static int RampartBuffEnemies;
static int FreeplayBuffTimer;
static bool zombiecombine;
static int moremen;
static bool immutable;
static int RandomStats;
static bool merlton;
static float gay;
static bool friendunit;
static int HurtleBuff;
static int HurtleBuffEnemies;
static bool LoveNahTonic;
static bool Schizophrenia;
static bool DarknessComing;
static int setuptimes;
static float ExtraAttackspeed;
static bool thespewer;

static int FreeplayModifActive = 0;
static float FM_Health;
static float FM_Damage;

#define INTENSE 1
#define MUSCLE 2
#define SQUEEZER 3
static bool squeezerplus; // soon...

public void Freeplay_Modifier_IntenseTraining()
{
	FreeplayModifActive = INTENSE;
	Modifier_Collect_ChaosIntrusion();
}

public void Freeplay_Modifier_MuscleRefiner()
{
	FreeplayModifActive = MUSCLE;
	Modifier_Collect_SecondaryMercs();
}

public void Freeplay_Modifier_SoulSqueezer()
{
	FreeplayModifActive = SQUEEZER;
	Modifier_Collect_OldTimes();
}

public void Freeplay_RemoveModif()
{
	switch(FreeplayModifActive)
	{
		case INTENSE:
		{
			Modifier_Remove_ChaosIntrusion();
		}
		case MUSCLE:
		{
			Modifier_Remove_SecondaryMercs();
		}
		case SQUEEZER:
		{
			Modifier_Remove_OldTimes();
		}
	}
	FreeplayModifActive = 0;
}

void Freeplay_CharBuffToAdd(char[] data)
{
	switch(FreeplayModifActive)
	{
		case INTENSE:
		{
			FormatEx(data, 6, "♦");
		}
		case MUSCLE:
		{
			FormatEx(data, 6, "♠");
		}
		case SQUEEZER:
		{
			if(squeezerplus)
				FormatEx(data, 6, "☻");
			else
				FormatEx(data, 6, "♣");
		}
	}
}

void Freeplay_OnMapStart()
{
	PrecacheSound("ui/vote_success.wav", true);
	PrecacheSound("ui/mm_medal_silver.wav", true);
	PrecacheSound("ambient/halloween/thunder_01.wav", true);
	PrecacheSound("misc/halloween/spelltick_set.wav", true);
	PrecacheSound("misc/halloween/hwn_bomb_flash.wav", true);
	PrecacheSound("music/mvm_class_select.wav", true);
}

void Freeplay_ResetAll()
{
	HealthMulti = 1.0;
	HealthBonus = 0;
	EnemyChance = 10;
	EnemyBosses = 0;
	ImmuneNuke = 0;
	CashBonus = 0;
	KillBonus = 0.0;
	MiniBossChance = 0.025;
	HussarBuff = false;
	PernellBuff = false;
	IceDebuff = 0;
	TeslarDebuff = 0;
	FusionBuff = 0;
	OceanBuff = 0;
	CrippleDebuff = 0;
	CudgelDebuff = 0;
	PerkMachine = 0;
	RaidFight = 0;
	SpeedMult = 1.0;
	MeleeMult = 1.0;
	RangedMult = 1.0;
	ExtraSkulls = -1;
	SkullTimes = 0;
	ExplodeNPCDamage = 0;
	ExplodingNPC = false;
	IsExplodeWave = false;
	EnemyShields = 0;
	VoidBuff = 0;
	VestaBuff = false;
	SquadBuff = false;
	Coffee = false;
	StrangleDebuff = 0;
	ProsperityDebuff = 0;
	SilenceDebuff = false;
	ExtraEnemySize = 1.0;
	UnlockedSpeed = false;
	CheesyPresence = false;
	EloquenceBuff = 0;
	RampartBuff = 0;
	EloquenceBuffEnemies = 0;
	RampartBuffEnemies = 0;
	FreeplayBuffTimer = 0;
	zombiecombine = false;
	moremen = 0;
	RandomStats = 0;
	merlton = false;
	gay = 0.0;
	friendunit = false;
	HurtleBuff = 0;
	HurtleBuffEnemies = 0;
	LoveNahTonic = false;
	Schizophrenia = false;
	DarknessComing = false;
	setuptimes = 4;
	ExtraAttackspeed = 1.0;
	thespewer = false;
	squeezerplus = false;
	FM_Health = 0.25;
	FM_Damage = 0.5;
}

int Freeplay_EnemyCount()
{
	int amount;
	if(RaidFight)
	{
		amount = 1;
	}
	else
	{
		amount = 5;

		if(zombiecombine)
			amount++;
	
		if(moremen)
			amount++;

		if(Schizophrenia)
			amount++;

		if(DarknessComing)
			amount++;

		if(thespewer)
			amount++;
	}

	return amount;
}

void Freeplay_OnNPCDeath(int entity)
{
	if(ExplodingNPC)
	{
		float startPosition[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", startPosition); 
		startPosition[2] += 45;
		makeexplosion(entity, startPosition, ExplodeNPCDamage, 150, _, true, true, 6.0);
	}
}

int Freeplay_GetDangerLevelCurrent()
{
	//0.5% chance for danger lvl 0 stuff.
	if(GetRandomFloat(0.0, 1.0) <= 0.0025)
	{
		return 0;
	}
	int DangerLevel = 1;

	float DefaultChance = 0.035 * float(EnemyChance);
	for(int LoopMax = 1; LoopMax < 6 ; LoopMax++)
	{
		//theres a default 10% chance to roll higher enemies.
		if(GetRandomFloat(0.0, 1.0) <= (DefaultChance))
		{
			DangerLevel++;
		}
		else
		{
			break;
		}
	}
	return DangerLevel;
}

void Freeplay_AddEnemy(int postWaves, Enemy enemy, int &count, bool alaxios = false)
{
	bool shouldscale = true;
	if(RaidFight || friendunit || zombiecombine || moremen || immutable || Schizophrenia || DarknessComing || thespewer)
	{
		enemy.Is_Boss = 0;
		enemy.WaitingTimeGive = 0.0;
		enemy.ExtraSize = 1.0;
		enemy.Is_Outlined = 0;
		enemy.Is_Health_Scaled = 0;
		enemy.Does_Not_Scale = 0;
		enemy.ignore_max_cap = 0;
		enemy.Is_Immune_To_Nuke = 0;
		enemy.Is_Static = false;
		enemy.Team = 3;
		enemy.Is_Static = false;
		enemy.ExtraMeleeRes = 1.0;
		enemy.ExtraRangedRes = 1.0;
		enemy.ExtraSpeed = 1.0;
		enemy.ExtraDamage = 1.0;
		enemy.ExtraThinkSpeed = 1.0;
	}
	if(RaidFight)
	{
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 2;
		enemy.ExtraDamage = 1.0;

		switch(RaidFight)
		{
			case 2:
			{
				switch(GetRandomInt(1, 12))
				{
					case 1:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;hyper";
					}
					case 2:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;hyper";
					}
					case 3:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;hyper";
					}
					case 4:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;hyper";
					}
					case 5:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;blitzmayhem";
					}
					default:
					{
						enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40";
					}
				}
			}
			case 3:
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_silvester");
				enemy.Health = RoundToFloor((2500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_40";
			}
			case 4:
			{
				switch(GetRandomInt(1, 8))
				{
					case 1: // mmmmyes
					{
						enemy.Index = NPC_GetByPlugin("npc_sea_god_alaxios");
						enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;res3;seainfection";
					}
					case 2: // mmmmyes
					{
						enemy.Index = NPC_GetByPlugin("npc_sea_god_alaxios");
						enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;res3;seainfection";
					}
					case 3: // mmmmno
					{
						enemy.Index = NPC_GetByPlugin("npc_toddhoward");
						enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;res3";
					}
					default: // alaxios has no timer in freeplay by default btw
					{
						enemy.Index = NPC_GetByPlugin("npc_god_alaxios");
						enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "wave_40;res3";
					}
				}
				enemy.ExtraThinkSpeed = 0.85; // ??? :bruh~1:
			}
			case 5:
			{
				enemy.Index = NPC_GetByPlugin("npc_sensal");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_40";
			}
			case 6:
			{
				enemy.Index = NPC_GetByPlugin("npc_stella");
				enemy.Health = RoundToFloor((3000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_purge");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 8:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_messenger");
				enemy.Health = RoundToFloor((7500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_30";
			}
			case 9:	
			{
				enemy.Index = NPC_GetByPlugin("npc_bob_the_first_last_savior");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.65);
				enemy.Data = "nobackup";
			}
			case 10:	
			{
				enemy.Index = NPC_GetByPlugin("npc_chaos_kahmlstein");
				enemy.Health = RoundToFloor((7500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 11:	
			{
				switch(GetRandomInt(1, 4))
				{
					case 1: 
					{
						enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_nemesis");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.4);
						enemy.Data = "enraged";
					}
					default: 
					{
						enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_nemesis");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
					}
				}
			}
			case 12:	
			{
				switch(GetRandomInt(1, 4))
				{
					case 1: 
					{
						enemy.Index = NPC_GetByPlugin("npc_xeno_mrx");
						enemy.Health = RoundToFloor((10000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
					}
					default: 
					{
						enemy.Index = NPC_GetByPlugin("npc_xeno_mrx");
						enemy.Health = RoundToFloor((10000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
					}
				}
			}
			case 13:
			{
				enemy.Index = NPC_GetByPlugin("npc_corruptedbarney");
				enemy.Health = RoundToFloor((2000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
			}
			case 14:
			{
				enemy.Index = NPC_GetByPlugin("npc_whiteflower_boss");
				enemy.Health = RoundToFloor((7000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraMeleeRes *= 3.0;
				enemy.ExtraRangedRes *= 3.0;
				enemy.ExtraDamage = 0.80;
			}
			case 15:
			{
				enemy.Index = NPC_GetByPlugin("npc_void_unspeakable");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "forth";
			}
			case 16:
			{
				enemy.Index = NPC_GetByPlugin("npc_vhxis");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 17:
			{
				enemy.Index = NPC_GetByPlugin("npc_nemal");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_40";
				enemy.ExtraDamage = 0.75;
			}
			case 18:
			{
				enemy.Index = NPC_GetByPlugin("npc_ruina_twirl");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 19:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_thompson");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.75;
			}
			case 20:
			{
				enemy.Index = NPC_GetByPlugin("npc_twins");
				enemy.Health = RoundToFloor((4500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "Im_The_raid;My_Twin";
				enemy.ExtraDamage = 0.75;
				enemy.ExtraSpeed = 1.10;
			}
			case 21:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_johnson");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.70; // johnson gets way too much damage in freeplay, reduce it
				enemy.ExtraThinkSpeed = 0.6;
				enemy.ExtraSpeed = 1.50;
			}
			case 22:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_smith");
				enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "raid_time";
			}
			case 23:
			{
				enemy.Index = NPC_GetByPlugin("npc_atomizer");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 24:
			{
				enemy.Index = NPC_GetByPlugin("npc_the_wall");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 25:
			{
				enemy.Index = NPC_GetByPlugin("npc_harrison");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 26:	
			{
				enemy.Index = NPC_GetByPlugin("npc_castellan");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 27:
			{
				enemy.Index = NPC_GetByPlugin("npc_lelouch");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.75;
			}
			case 28:
			{
				enemy.Index = NPC_GetByPlugin("npc_omega_raid");
				enemy.Health = RoundToFloor((6500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 29:
			{
				enemy.Index = NPC_GetByPlugin("npc_cat");
				enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 30:
			{
				enemy.Index = NPC_GetByPlugin("npc_aris");
				enemy.Health = RoundToFloor((5500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 31:
			{
				enemy.Index = NPC_GetByPlugin("npc_chimera");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 32:	
			{
				switch(GetRandomInt(1, 4))
				{
					case 1: // 
					{
						enemy.Index = NPC_GetByPlugin("npc_vincent");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
						enemy.Data = "forceangry;forcesad";
					}
					default: // 
					{
						enemy.Index = NPC_GetByPlugin("npc_vincent");
						enemy.Health = RoundToFloor((6000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
					}
				}
			}
			case 33:
			{
				enemy.Index = NPC_GetByPlugin("npc_boss_reila");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "force_final_battle";
				enemy.ExtraDamage = 0.40;
				enemy.ExtraSpeed = 1.05;
			}
			case 34:
			{
				enemy.Index = NPC_GetByPlugin("npc_almagest_jkei");
				enemy.Health = RoundToFloor((7000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "force_final_battle";
				enemy.ExtraThinkSpeed = 0.55;
				enemy.ExtraDamage = 1.15;
				enemy.ExtraSpeed = 1.15;
			}
			case 35:
			{
				enemy.Index = NPC_GetByPlugin("npc_shadowing_darkness_boss");
				enemy.Health = RoundToFloor((9000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "sc20;force_final_battle";
				enemy.ExtraThinkSpeed = 1.25;
				enemy.ExtraSpeed = 0.90;
				enemy.ExtraDamage = 0.70;
			}
			case 36:
			{
				enemy.Index = NPC_GetByPlugin("npc_zilius");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "bossrush";
				enemy.ExtraSpeed = 1.10;
				enemy.ExtraThinkSpeed = 0.85;
			}
			case 37:
			{
				enemy.Index = NPC_GetByPlugin("npc_squad_master");
				enemy.Health = RoundToFloor((1250000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "sc20";
				enemy.ExtraThinkSpeed = 1.15;
				enemy.ExtraSpeed = 0.85;
			}
			case 38:
			{
				enemy.Index = NPC_GetByPlugin("npc_no_random_kranz");
				enemy.Health = RoundToFloor((1000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "sc40";
				enemy.ExtraThinkSpeed = 1.15;
				enemy.ExtraDamage = 0.6;
				enemy.ExtraSpeed = 0.9;
			}
			case 39:
			{
				enemy.Index = NPC_GetByPlugin("npc_black_heavy_soul");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "sc40";
				enemy.ExtraThinkSpeed = 1.15;
				enemy.ExtraDamage = 0.7;
				enemy.ExtraSpeed = 0.9;
			}
			case 40:
			{
				enemy.Index = NPC_GetByPlugin("npc_kevinmery2009");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraThinkSpeed = 0.60;
				enemy.ExtraDamage = 1.20;
				enemy.ExtraSpeed = 1.1;
			}
			default:
			{
				enemy.Index = NPC_GetByPlugin("npc_true_fusion_warrior");
				enemy.Health = RoundToFloor((5000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_40";
			}
		}

		// Raid health is lower before w101.
		if(Waves_GetRoundScale() < 101)
			enemy.Health = RoundToCeil(float(enemy.Health) * 0.75);

		enemy.Health = RoundToCeil(float(enemy.Health) * HealthMulti);
		
		//Global HP increaser
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.85);

		// moni
		enemy.Credits += 5000.0;
		enemy.Does_Not_Scale = 1;
		count = 1;
		RaidFight = 0;
		shouldscale = false;
	}
	else if(friendunit)
	{
		enemy.Team = TFTeam_Red;
		count = 1;

		if(enemy.ExtraDamage)
			enemy.ExtraDamage = 25.0;

		enemy.ExtraSpeed = 1.25;
		enemy.ExtraSize = 1.25;

		friendunit = false;
		shouldscale = false;
		char thename[128];
		NPC_GetNameById(enemy.Index, thename, sizeof(thename));
		CPrintToChatAll("{gold}Friendly Unit: {orange}%s", thename);
	}
	else if(DarknessComing)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_darkenedheavy");
		enemy.Health = RoundToFloor(((1000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
		enemy.Credits += 100.0;
		enemy.ExtraMeleeRes = 1.5;
		enemy.Is_Boss = 1;

		count = 4;
		DarknessComing = false;
	}
	else if(zombiecombine)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_zombine");
		enemy.Health = RoundToFloor(((150000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
		enemy.ExtraSpeed = 1.5;
		enemy.ExtraSize = 1.33;
		enemy.Credits += 100.0;
		enemy.ExtraDamage = 2.0;
		enemy.Is_Boss = 0;
		enemy.Is_Health_Scaled = 0;

		count = 20;
		zombiecombine = false;
	}
	else if(moremen)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_dweller_heavy");
		enemy.Health = RoundToCeil(((80000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
		enemy.ExtraSpeed = 1.5;
		enemy.ExtraSize = 1.25;
		enemy.Credits += 100.0;
		enemy.ExtraDamage = 1.25;
		enemy.Is_Boss = 0;
		enemy.Is_Health_Scaled = 0;

		count = 30;
		moremen--;
	}
	else if(immutable)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 1;
		enemy.Index = NPC_GetByPlugin("npc_immutableheavy");
		enemy.Health = RoundToFloor(((610000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
		enemy.ExtraMeleeRes = 1.5;
		enemy.ExtraRangedRes = 1.0;
		enemy.ExtraSpeed = 0.9;
		enemy.ExtraDamage = 0.75;
		enemy.ExtraSize = 1.0;
		enemy.Credits += 100.0;

		count = 5;
		immutable = false;
	}
	else if(Schizophrenia)
	{
		enemy.Index = NPC_GetByPlugin("npc_annoying_spirit");
		enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(Waves_GetRoundScale()));
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Outlined = 0;
		enemy.Credits += 100.0;
		count = 1;
		Schizophrenia = false;
	}
	else if(thespewer)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 1;
		enemy.Index = NPC_GetByPlugin("npc_abyssspewer");
		enemy.Health = RoundToFloor(((1100000.0 + HealthBonus) / 65.0 * float(Waves_GetRound())) * HealthMulti);
		enemy.ExtraMeleeRes = 0.75;
		enemy.ExtraRangedRes = 0.75;
		enemy.ExtraDamage = 5.5;
		enemy.ExtraSpeed = 2.0;
		enemy.ExtraSize = 2.5;
		enemy.ExtraThinkSpeed = 0.75;
		enemy.Credits += 100.0;
		count = 1;
		thespewer = false;
	}
	else
	{
		float bigchance;
		if(postWaves+1 < 89)
			bigchance = 0.97;
		else
			bigchance = 0.95;

		if(GetRandomFloat(0.0, 1.0) >= bigchance)
		{
			enemy.Is_Boss = 0;
			enemy.WaitingTimeGive = 0.0;
			enemy.ExtraSize = 1.0;
			enemy.Is_Outlined = 0;
			enemy.Is_Health_Scaled = 0;
			enemy.Does_Not_Scale = 0;
			enemy.ignore_max_cap = 0;
			enemy.Is_Immune_To_Nuke = 0;
			enemy.Is_Static = false;
			enemy.Team = 3;
			enemy.Is_Static = false;
			enemy.ExtraMeleeRes = 1.0;
			enemy.ExtraRangedRes = 1.0;
			enemy.ExtraSpeed = 1.0;
			enemy.ExtraDamage = 1.0;

			enemy.Is_Immune_To_Nuke = true;
			int roll = GetRandomInt(1, 15);
			if(roll == 2)
			{
				enemy.Index = NPC_GetByPlugin("npc_dimensionfrag");
				enemy.Health = RoundToFloor(((170000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.25)) * HealthMulti);
				enemy.ExtraDamage = 0.70;
				count = 20;
			}
			else if(roll == 3)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_ltzens");
				enemy.Health = RoundToFloor(((250000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.15)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 15;
			}
			else if(roll == 4)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_refract");
				enemy.Health = RoundToFloor(((200000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.20)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 20;
			}
			else if(roll == 5)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_spuud");
				enemy.Health = RoundToFloor(((300000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.11)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 15;
			}
			else if(roll == 6)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_rouam");
				enemy.Health = RoundToFloor(((500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
				enemy.ExtraDamage = 2.0;
				count = 5;
			}
			else if(roll == 7)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_keitosis");
				enemy.Health = RoundToFloor(((3000000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
				enemy.ExtraDamage = 1.09;
				enemy.ExtraThinkSpeed = 0.75;
				count = 1;
			}
			else if(roll == 8)
			{
				enemy.Index = NPC_GetByPlugin("npc_vanishingmatter");
				enemy.Health = RoundToFloor(((250000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.11)) * HealthMulti);
				enemy.ExtraDamage = 0.75;
				count = 10;
			}
			else if(roll == 9)
			{
				enemy.Index = NPC_GetByPlugin("npc_dimensionfrag");
				enemy.Health = RoundToFloor(((170000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.25)) * HealthMulti);
				enemy.ExtraDamage = 0.70;
				count = 20;
			}
			else if(roll == 10)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_ltzens");
				enemy.Health = RoundToFloor(((250000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.15)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 15;
			}
			else if(roll == 11)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_refract");
				enemy.Health = RoundToFloor(((200000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.20)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 20;
			}
			else if(roll == 12)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_spuud");
				enemy.Health = RoundToFloor(((300000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.11)) * HealthMulti);
				enemy.ExtraDamage = 1.25;
				count = 15;
			}
			else if(roll == 13)
			{
				enemy.Index = NPC_GetByPlugin("npc_umbral_rouam");
				enemy.Health = RoundToFloor(((500000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
				enemy.ExtraDamage = 2.0;
				count = 5;
			}
			else if(roll == 14)
			{
				enemy.Index = NPC_GetByPlugin("npc_vanishingmatter");
				enemy.Health = RoundToFloor(((250000.0 + HealthBonus) / 70.0 * (float(Waves_GetRound()) * 1.11)) * HealthMulti);
				enemy.ExtraDamage = 0.75;
				count = 10;
			}
			else if(roll == 15)
			{
				enemy.Index = NPC_GetByPlugin("npc_vanishingmatter");
				enemy.Health = RoundToFloor(((350000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
				enemy.ExtraDamage = 0.95;
				count = 10;
			}
			else
			{
				enemy.Index = NPC_GetByPlugin("npc_vanishingmatter");
				enemy.Health = RoundToFloor(((350000.0 + HealthBonus) / 70.0 * float(Waves_GetRound())) * HealthMulti);
				enemy.ExtraDamage = 0.95;
				count = 10;
			}

			count = RoundToFloor((count * (((postWaves * 1.5) + 80) * 0.009)) * 0.5);
			enemy.Credits += 100.0;

			if(postWaves+1 < 89)
			{
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						CPrintToChatAll("{gold}U-uh, that's not supposed to happen....");
					}
					case 2:
					{
						CPrintToChatAll("{gold}Aand this enemy gro- w-wait, what's that!?");	
					}
					case 3:
					{
						CPrintToChatAll("{gold}Erm... seems like something's going wrong...");		
					}
					default:
					{
						CPrintToChatAll("{gold}Oh oh no- BE CAREFUL!!");
					}
				}
			}	
			else
			{	
				switch(GetRandomInt(1, 4))
				{
					case 1:
					{
						CPrintToChatAll("{gold}Aaah crap... here they come again...");
					}
					case 2:
					{
						CPrintToChatAll("{gold}Uh oh, get ready!");	
					}
					case 3:
					{
						CPrintToChatAll("{gold}Damnit... They just keep coming and coming!");		
					}
					default:
					{
						CPrintToChatAll("{gold}Aaaand- oh fudge.");
					}
				}
			}
		}
		else
		{
			if(enemy.Health)
			{
				if(StrContains(enemy.CustomName, "First ") != -1)
				{
					enemy.Health = RoundToCeil((HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009))) * 0.5);
				}
				else
				{
					enemy.Health = RoundToCeil((enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009)) * 0.5);
				}
			}
	
			count = RoundToFloor((count * (((postWaves * 1.5) + 80) * 0.009)) * 0.5);
		}

		if(EnemyBosses && !((enemy.Index + 1) % EnemyBosses))
		{
			enemy.Health = RoundToCeil(enemy.Health * 1.1);
			enemy.ExtraDamage *= 1.25;
			enemy.ExtraMeleeRes *= 0.9;
			enemy.ExtraRangedRes *= 0.9;
			enemy.ExtraSpeed *= 1.1;
		}

		if(ImmuneNuke && !(enemy.Index % ImmuneNuke))
			enemy.Is_Immune_To_Nuke = true;

		if(KillBonus)
			enemy.Credits += KillBonus;

		shouldscale = true;
	}

	if(alaxios)
	{
		enemy.Health = RoundToCeil(enemy.Health * 1.33);
		enemy.ExtraDamage *= 1.15;
	}

	if(shouldscale)
	{
		// count scaling
		float countscale = float(CountPlayersOnRed());
		if(countscale <= 4.0)
		{
			countscale *= 0.07; // below or equal to 4 players, scaling is 0.07 per player, to make low-player freeplay faster
		}
		else if(countscale > 4.0 && countscale <= 8.0) 
		{
			countscale *= 0.125; // above 4 players but below or equal to 8, scaling is 0.125 per player
		}
		else if(countscale > 8.0 && countscale <= 12.0) 
		{
			countscale = 1.0; // above 8 players but below or equal to 12, player scaling should not activate
		}
		else
		{
			countscale *= 0.0782; // above 12 players, scaling should be 0.0782 per player, for a max of +25% enemies at 16 players.
		}

		if(countscale < 0.1)
			countscale = 0.1; // minimum is 90% less enemies

		count = RoundToCeil(float(count) * countscale);
	}

	if(i_WaveHasFreeplay == 2)
	{
		if(count > 30)
			count = 30;
	}

	if(count < 1)
		count = 1;

	if(enemy.Is_Boss == 1)
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.65);

	enemy.Health = RoundToCeil(float(enemy.Health) * FM_Health);

	float ExtraHpAdd;
	ExtraHpAdd = float(postWaves);
	ExtraHpAdd *= 0.075;
	if(ExtraHpAdd <= 1.0)
	{
		ExtraHpAdd = 1.0;
	}
	//Global HP increaser
	enemy.Health = RoundToCeil(float(enemy.Health) * ExtraHpAdd);

	// 2 billion limit, it is necessary to prevent them from going bananas
	if(enemy.Health > 2000000000)
		enemy.Health = 2000000000;

	if(enemy.Team != TFTeam_Red)
	{
		enemy.ExtraThinkSpeed *= ExtraAttackspeed;
		enemy.ExtraSize *= ExtraEnemySize;
	}
}

static Action Freeplay_RouletteMessage(Handle timer)
{
	RaidFight = GetRandomInt(1, 40);
	EmitSoundToAll("misc/halloween/spelltick_set.wav", _, _, _, _, _, GetRandomInt(70, 135));
	switch(RaidFight)
	{
		case 2:
		{
			switch(GetRandomInt(1, 5))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {red}How was Vivithorn smart enough to hack Blitzkreig?");
				}
				case 2:
				{
					CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {lightcyan}That mission to send Blitz that abandoned lab was an huge mistake sadly...");
				}
				case 3:
				{
					CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {lightcyan}I remember Blitz before he was hacked. He was nice to us Expidonsans and Ruanians.");
				}
				case 4:
				{
					CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {red}There was an original group of mercs that tired to stop Blitz at an expidonsan base. They did not succeed...");
				}
				default:
				{
					CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {red}Prepare to fight against the rogue machine!");
				}
			}
		}
		case 3:
		{
			switch(GetRandomInt(1, 6))
			{
				case 1:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {darkblue}WALDCH! {gold}- {red}The better silv duo fight!");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}WALDCH {white}& {yellow}SILVESTER! {gold}- {red}Enjoy getting sniped from across the map!");
				}
				case 3:
				{
					CPrintToChatAll("{yellow}SILVESTER! {gold}- {red}and waldch, of course!");
				}
				case 4:
				{
					CPrintToChatAll("{darkblue}WALDCH! {gold}- {red}and silvester, of course!");
				}
				case 5:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {darkblue}WALDCH! {gold}- {yellow}Hey thanks again for saving me from the Xeno infection, now beat Waldch and me in this simulation.");
				}
				/*case 6:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {darkblue}WALDCH! {gold}- {red}Imagine if I added Sensal to this fight. That would be fun.");
				}*/
				default:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {darkblue}WALDCH! {gold}- {red}Enjoy eating rocks!");
				}
			}
		}
		case 4:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{lightblue}GOD ALAXIOS! {gold}- {red}If Alaxios is the {lightblue}''god of life''{red}, then who's the {green}''god of death''{red}?");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}GOD ALAXIOS! {gold}- {red}What if Alaxios was infected by the abyssal while you guys were fighting it?");
				}
				default:
				{
					CPrintToChatAll("{lightblue}GOD ALAXIOS! {gold}- {red}Face the full power of Atlantis!");
				}
			}
		}
		case 5:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{blue}SENSAL! {gold}- {blue}Lets see how good you guys do against me.");
				}
				default:
				{
					CPrintToChatAll("{blue}SENSAL! {gold}- {red}He shall reap you, and your resistances!");
				}
			}
		}
		case 6:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{aqua}STELLA {white}& {crimson}KARLAS! {gold}- {red}Hope you like stella's laser of death!");
				}
				case 2:
				{
					CPrintToChatAll("{crimson}KARLAS {white}& {aqua}STELLA! {gold}- {red}oh hey Karlas, you here to watch. {crimson}*nods head* >:)");
				}
				/*case 3:
				{
					CPrintToChatAll("{aqua}STELLA {white}& {crimson}KARLAS! {gold}- {red}Now lets add one more elf to this, Twirl. Naaa I wont, maybe.");
				}*/
				default:
				{
					CPrintToChatAll("{crimson}KARLAS {white}& {aqua}STELLA! {gold}- {red}Hope you like dealing with all of karlas's swords!");
				}
			}
		}
		case 7:	
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
						CPrintToChatAll("{crimson}THE PURGE! {gold}- {lightcyan}The only Ziberian that stood up to Kahml, Ivan Petrova. Now he's this cyborg after Kahml killed him with 1 punch.");
				}
				default:
				{
					CPrintToChatAll("{crimson}THE PURGE! {gold}- {red}Annihilation shall be absolute!");
				}
			}
		}
		case 8:	
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{lightblue}THE MESSENGER! {gold}- {lightcyan}How do these people find the Void, ugh. At least Vhxis was holding it back.");
				}
				case 2:
				{
					CPrintToChatAll("{lightblue}THE MESSENGER! {gold}- {red}shhhh, don't tell Nemal what happened to him.");
				}
				default:
				{
					CPrintToChatAll("{lightblue}THE MESSENGER! {gold}- {red}He REALLY wants to make Kahmlstein proud!");
				}
			}
		}
		case 9:	
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{white}BOB THE FIRST! {gold}- {lightcyan}You guys are stupid for going after the leader of that dweller clan all alone, even with Alaxios and his army holding off most of its forces. At least Bob came to uninfect you guys.");
				}
				/*case 2:
				{
					CPrintToChatAll("{white}BOB THE FIRST! {gold}- {red}wip, idk what to add here yet");
				}*/
				/*case 3:
				{
					CPrintToChatAll("{white}BOB THE FIRST! {gold}- {red}Imagine fighting Bob and Bladedance at the same time before Blade was sent into the Curtain by Bob.");
				}*/
				default:
				{
					CPrintToChatAll("{white}BOB THE FIRST! {gold}- {red}Are you really a god? Also no army, it keeps bugging the simulation out somehow.");
				}
			}
		}
		case 10:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{darkblue}CHAOS KAHMLSTEIN! {gold}- {lightcyan}He almost got as smart as one of us while Chaos afflicted. But you guys got rid of his Chaos before he got too smart.");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}CHAOS KAHMLSTEIN! {gold}- {red}Chaos really messed him up, with all he's done while under it. At least he did want to fix what he had done after you guys got rid of his Chaos.");
				}
				default:
				{
					CPrintToChatAll("{darkblue}CHAOS KAHMLSTEIN! {gold}- {red}He thinks he's unstoppable, prove him wrong!");
				}
			}
		}
		case 11:	
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{green}CALMATICUS! {gold}- {red}Aah, the good ol' days when the speed module had no limits...");
				}
				case 2:
				{
					CPrintToChatAll("{green}NEMESIS! {gold}- {red}Nemesis? That should say Calmaticus.");
				}
				case 3:
				{
					CPrintToChatAll("{green}CALMATICUS! {gold}- {red}Was Calmaticus enraged while you guys were fighting it and Vivithorn back at that abandoned lab?");
				}
				/*case 4:
				{
					CPrintToChatAll("{green}CALMATICUS! {gold}- {red}What if you guys fought Calmaticus and Vivithorn at the same time, like how you did back at the abandoned lab?");
				}*/
				default:
				{
					CPrintToChatAll("{green}CALMATICUS! {gold}- {red}The source of the Xeno infection.");
				}
			}
		}
		case 12:	
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{green}VIVITHORN! {gold}- {red}The activater of the Xeno virus.");
				}
				case 2:
				{
					CPrintToChatAll("{green}VIROTHORN! {gold}- {red}Oops, misspelled Vivithorn. :P");
				}
				/*case 3:
				{
					CPrintToChatAll("{green}VIVITHORN! {gold}- {red}What if you guys fought Vivithorn and Calmaticus at the same time, like how you did back at the abandoned lab?");
				}*/
				default:
				{
					CPrintToChatAll("{green}MR. X! {gold}- {red}Mister who? That should say Vivithorn.");
				}
			}
		}
		case 13:
		{
			CPrintToChatAll("{midnightblue}CO0R0RR9R'R4R0#(##()#F92 B '11 A =)$ R 49I N 2G4 E 2#f Y =4,93RW9FW0LRSMUW320$");
		}
		case 14:
		{
			CPrintToChatAll("{crimson}WHITEFLOWER! {gold}- {red}...minus his army, of course.");
		}
		/*case 14:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}FLOWERING DARKNESS {white}& {crimson}WHITEFLOWER! {gold}- {red}The co-boss and boss of w.f.'s forces.");
				}
				case 2:
				{
					CPrintToChatAll("{crimson}}WHITEFLOWER {white}& {crimson}FLOWERING DARKNESS! {gold}- {red}The boss and co-boss of w.f.'s forces.");
				}
				default:
				{
					CPrintToChatAll("{crimson}WHITEFLOWER {white}& {crimson}FLOWERING DARKNESS! {gold}- {red}...minus the army, of course.");
				}
			}
		}*/
		case 15:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{purple}UNSPEAKABLE! {gold}- {red}Thankfully it's should be dead after the incident at the palace.");
				}
				case 2:
				{
					CPrintToChatAll("{purple}UNSPEAKABLE! {gold}- {red}Hopefully it's gone after Kahmlsteins sacrafice.");
				}
				default:
				{
					CPrintToChatAll("{purple}UNSPEAKABLE! {gold}- {red}Does it actually speak though?");
				}
			}
		}
		case 16:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{purple}VHXIS! {gold}- {red}Was it really the best idea to fight him?");
				}
				default:
				{
					CPrintToChatAll("{purple}VHXIS! {gold}- {red}Fight against the void gatekeeper once more!");
				}
			}
		}
		case 17:
		{
			switch(GetRandomInt(1, 6))
			{
				case 1:
				{
					CPrintToChatAll("{lightblue}NEMAL! {gold}- {red}and silvester, of course!");
				}
				case 2:
				{
					CPrintToChatAll("{yellow}SILVESTER! {gold}- {red}and nemal, of course!");
				}
				case 3:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {lightblue}NEMAL! {gold}- {red}The better silv duo fight!");
				}
				case 4:
				{
					CPrintToChatAll("{lightblue}NEMAL! {white}& {yellow}SILVESTER! {gold}- {lightblue}Aah you guys are fighting me! Yay!!!");
				}
				case 5:
				{
					CPrintToChatAll("{yellow}SILVESTER {white}& {lightblue}NEMAL! {gold}- {yellow}Oh you guys are fighting Nemal and me. Another round of training, inside a training simulation.");
				}
				/*case 6:
				{
					CPrintToChatAll("{lightblue}NEMAL! {white}& {yellow}SILVESTER! {gold}- {red}Maybe I should add 1 more expidonsan named Sensal to this. ");
				}*/
				default:
				{
					CPrintToChatAll("{lightblue}NEMAL {white}& {yellow}SILVESTER! {gold}- {red}The better silv duo fight!");
				}
			}
		}
		case 18:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{purple}TWIRL! {gold}- {red}Oh so you're strong? Fight her!");
				}
				/*case 2:
				{
					CPrintToChatAll("{purple}TWIRL! {gold}- {red}What if I add the other elf you guys fought. And her "pet cat." ");
				}*/
				default:
				{
					CPrintToChatAll("{purple}TWIRL! {gold}- {red}The ruler of ruina descends!");
				}
			}
		}
		case 19:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{community}Agent... thompson. {red}eeew.");
				}
				case 2:
				{
					CPrintToChatAll("{community}Agent... thompson. {red}eew.");
				}
				default:
				{
					CPrintToChatAll("{community}Agent... thompson. {red}ew.");
				}
			}
		}
		case 20:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{forestgreen}The.... twins. {red}eeew.");
				}
				case 2:
				{
					CPrintToChatAll("{forestgreen}The.... twins. {red}eew.");
				}
				default:
				{
					CPrintToChatAll("{forestgreen}The.... twins. {red}ew.");
				}
			}
		}
		case 21:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{community}Agent... johnson. {red}eeew. Had to juice him up a bit cause how bad he is");
				}
				case 2:
				{
					CPrintToChatAll("{community}Agent... johnson. {red}eew. Had to juice him up a bit cause how bad he is");
				}
				default:
				{
					CPrintToChatAll("{community}Agent... johnson. {red}ew. Had to juice him up a bit cause how bad he is");
				}
			}	
		}
		case 22:
		{
			switch(GetRandomInt(1, 5))
			{
				case 1:
				{
					CPrintToChatAll("{darkgreen}Agent Smith. {red}Agent Stinky.");
				}
				case 2:
				{
					CPrintToChatAll("{darkgreen}Agent Smith. {red}Agent Stinker.");
				}
				case 3:
				{
					CPrintToChatAll("{darkgreen}Agent Smith. {red}Agent Stinkiest.");
				}
				case 4:
				{
					CPrintToChatAll("{darkgreen}Agent Smith. {red}Agent St- {lightcyan}Shut up Koshi! *sigh* That guy from the simulation movie.");
				}
				default:
				{
					CPrintToChatAll("{darkgreen}Agent Smith. {crimson}*stink sound effect*");
				}
			}
		}
		case 23:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{blue}ATOMIZER! {gold}- {red}The captain of Vesta's Leatherboots Scoutsquad!");
				}
				default:
				{
					CPrintToChatAll("{blue}ATOMIZER! {gold}- {red}I wonder what that nitro fuel is made of...");
				}
			}
		}
		case 24:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{lightblue}HUSCARLS! {gold}- {red}The lieutenant of Vesta's Irongate defence unit!");
				}
				default:
				{
					CPrintToChatAll("{lightblue}HUSCARLS! {gold}- {red}Running around in circles just to hit a wall!");
				}
			}
		}
		case 25:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{skyblue}HARRISON! {gold}- {red}The lieutenant colonel of Vesta's Stormtrooper team!");
				}
				default:
				{
					CPrintToChatAll("{skyblue}HARRISON! {gold}- {red}His rockets surely won't miss you!");
				}
			}
		}
		case 26:	
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{steelblue}CASTELLAN! {gold}- {red}The colonel of Vesta's army!");
				}
				default:
				{
					CPrintToChatAll("{steelblue}CASTELLAN! {gold}- {red}In the name of Vesta, he won't allow you further in!");
				}
			}
		}
		case 27:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{darkviolet}LELOUCH! {gold}- {red}How did Chaos give him info about that pocket dimension thing... {lightcyan}The Curtain, it's called Koshi.");
				}
				default:
				{
					CPrintToChatAll("{darkviolet}LELOUCH! {gold}- {red}The chaos-afflicted ruinian i've spoken about before...");
				}
			}
		}
		case 28:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{gold}OMEGA! - {red}Baldy.");
				}
				default:
				{
					CPrintToChatAll("{gold}OMEGA! - {red}Waltzing straight to you.");
				}
			}
		}
		case 29:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{rare}C.A.T.! {gold}- {red}Zeina look, C.A.T. looks like you. :P {lightcyan}And you look like one of those Glugs, Koshi.");
				}
				default:
				{
					CPrintToChatAll("{rare}C.A.T.! {gold}- {red}It now considers you a trespassers of the laboratories.");
				}
			}
		}
		case 30:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{rare}A.R.I.S.! {gold}- {red}What if you had to fight both A.R.I.S. and C.A.T. at the same time. Naaaa.");
				}
				default:
				{
					CPrintToChatAll("{rare}A.R.I.S.! {gold}- {red}C.A.T. must have failed at stopping you.");
				}
			}
		}
		case 31:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{darkblue}C.H.I.M.E.R.A.! {gold}- {red}Wonder who the {darkblue}creator {red}of this robot is?");
				}
				case 2:
				{
					CPrintToChatAll("{darkblue}C.H.I.M.E.R.A.! {gold}- {red}This robot seems different from the other ones.");
				}
				default:
				{
					CPrintToChatAll("{darkblue}C.H.I.M.E.R.A.! {gold}- {red}Remember to be careful your surrounding, there may be a mine next to you, or a sniper aiming right at you.");
				}
			}
		}
		case 32:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{rare}VINCENT! {gold}- {red}The only sentiant robot from that place.");
				}
				case 2:
				{
					CPrintToChatAll("{rare}VINCENT! {gold}- {red}Atleast you guys were friendly enough to not kill {rare}C.A.T. {red}and {rare}A.R.I.S. {red}But what if you weren't? ");
				}
				default:
				{
					CPrintToChatAll("{rare}VINCENT! {gold}- {red}Lets see how much he yaps this time.");
				}
			}
		}
		case 33:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{pink}REILA! {gold}- {red}The construct will buff Reila and itself, but gives you more time to kill Reila.");
				}
				default:
				{
					CPrintToChatAll("{pink}REILA! {gold}- {red}Make sure you attack Reila herself first. I buffed her cause she has no umbrals supporting her.");
				}
			}
		}
		case 34:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{black}JKEI! {gold}- {red}What's the whole deal with these Almagest Corp. dudes? I should ask Reila.");
				}
				default:
				{
					CPrintToChatAll("{black}JKEI! {gold}- {red}Hope we don't have to fight more from the Almagest Corporation. I buffed him cause he has no allies with him.");
				}
			}
		}
		case 35:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{darkgray}SHADOWING DARKNESS! {gold}- {lightcyan}Good luck with her. Koshi made her the hardest challenge in the simulation");
				}
				default:
				{
					CPrintToChatAll("{darkgray}SHADOWING DARKNESS! {gold}- {red}The hardest challenge we have programmed into this. Good luck beating her.");
				}
			}
		}
		case 36:
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					CPrintToChatAll("{black}ZILIUS! {gold}- {red}Sorry this caused him to imprison you Zeina. {lightcyan}It's alright Koshi, at least these guys freed me from him.");
				}
				case 2:
				{
					CPrintToChatAll("{black}ZILIUS! {gold}- {blue}The other citys are the same as his. They do not care about any other race.");
				}
				case 3:
				{
					CPrintToChatAll("{black}ZILIUS! {gold}- {blue}Your strength somehow made Zilius decide not to kill you guys. Maybe we could use that to find the solution to stop Chaos.");
				}
				default:
				{
					CPrintToChatAll("{black}ZILIUS! {gold}- {lightcyan}If you guys beat him, I'll join you as a thanks for saving me from him. {red}I also made him stronger cause he doesn't have his army.");
				}
			}
		}
		case 37:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{red}MAZEAT {green}FABULOUS {purple}SQUAD {crimson}X {red}E{orange}L{yellow}I{green}T{blue}E{purple}! {gold}- {red}April Fools >:P!!!! oh.. im late...");
				}
				default:
				{
					CPrintToChatAll("{red}MAZEAT {green}FABULOUS {purple}SQUAD {crimson}X {red}E{orange}L{yellow}I{green}T{blue}E{purple}! {gold}- {red}Oh it's so over for you guys...");
				}
			}
		}
		case 38:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{purple}NO RANDOM KRANZ V3! {gold}- {red}Whats with the ''No Random'' part? Also version 3?");
				}
				case 2:
				{
					CPrintToChatAll("{purple}NO RANDOM KRANZ V3! {gold}- {red}April Fools >:P!!!! oh.. im late...");
				}
				default:
				{
					CPrintToChatAll("{purple}NO RANDOM KRANZ V3! {gold}- {red}Whats with the ''V3'' part? Also not random?");
				}
			}
		}
		case 39:
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					CPrintToChatAll("{black}BLACK HEAVY SOUL! {gold}- {red}The evil soul. But why is he a saiyan?");
				}
				case 2:
				{
					CPrintToChatAll("{black}BLACK HEAVY SOUL! {gold}- {red}April Fools >:P!!!! oh.. im late...");
				}
				default:
				{
					CPrintToChatAll("{black}BLACK HEAVY SOUL! {gold}- {red}He killed the others, now you guys must kill him");
				}
			}
		}
		case 40:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{red}KEVINMERY2009! {gold}- {red}April Fools >:P!!!! oh.. im late...");
				}
				default:
				{
					CPrintToChatAll("{red}KEVINMERY2009! {gold}- {red}I took data of your strongest mercenary and turned him into a boss!");
				}
			}
		}
		default:
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					CPrintToChatAll("{yellow}INFECTED SILVESTER! {gold}- {red}Wonder how the Xeno Infection bypassed his shield?");
				}
				default:
				{
					CPrintToChatAll("{yellow}INFECTED SILVESTER! {gold}- {red}An infected menace!");
				}
			}
		}
	}

	return Plugin_Continue;
}	

bool Freeplay_ShouldMiniBoss()
{
	float chance = MiniBossChance;
	int decrease = 10;
	Flagellant_MiniBossChance(decrease);
	if(decrease < 1)
		return true;

	chance *= float(10 / decrease);
	return (chance > GetURandomFloat());
}

void Freeplay_ApplyStatusEffect(int entity, const char[] name, float duration)
{
	float mult = 1.0;
	switch(FreeplayModifActive)
	{
		case INTENSE:
		{
			mult = 1.2;
		}
		case MUSCLE:
		{
			mult = 1.4;
		}
		case SQUEEZER:
		{
			mult = 2.0;
			if(squeezerplus)
				mult = 3.0;
		}
	}
	duration *= mult;
	ApplyStatusEffect(entity, entity, name, duration);
}

void Freeplay_SpawnEnemy(int entity)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(RandomStats)
		{
			if(GetRandomInt(0, 100) < 1) // 1% chance for this to work, it NEEDS to be extra rare.
			{
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * GetRandomFloat(2.0, 8.0)));
				if(GetEntProp(entity, Prop_Data, "m_iHealth") < 0 || GetEntProp(entity, Prop_Data, "m_iHealth") > 2000000000)
					SetEntProp(entity, Prop_Data, "m_iHealth", 2000000000);
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", GetEntPropFloat(entity, Prop_Send, "m_flModelScale") * GetRandomFloat(0.1, 3.5));
				fl_Extra_MeleeArmor[entity] *= GetRandomFloat(0.1, 2.0);
				fl_Extra_RangedArmor[entity] *= GetRandomFloat(0.1, 2.0);
				fl_Extra_Speed[entity] *= GetRandomFloat(0.1, 3.0);
				fl_Extra_Damage[entity] *= GetRandomFloat(0.5, 6.0);
				f_AttackSpeedNpcIncrease[entity] *= GetRandomFloat(0.4, 1.5);

				// this works if you want to make them stalkers!!!!!!
				if(GetRandomInt(0, 1) == 1)
				{
					b_StaticNPC[entity] = true;
					AddNpcToAliveList(entity, 1);
					b_NoHealthbar[entity] = 1; //Makes it so they never have an outline
					GiveNpcOutLineLastOrBoss(entity, false);
					b_thisNpcHasAnOutline[entity] = true;
				}
	
				switch(GetRandomInt(1, 6))
				{
					case 1:
					{
						CPrintToChatAll("{crimson}HAVE AT THEE!!");
					}
					case 2:
					{
						CPrintToChatAll("{crimson}FACE THIS!!");
					}
					case 3:
					{
						CPrintToChatAll("{crimson}HOW'S THIS FOR A SURPRISE!?");
					}
					case 5:
					{
						CPrintToChatAll("{crimson}BOO!!!!");
					}
					case 6:
					{
						CPrintToChatAll("{crimson}ENGAGE!!!");
					}
					default:
					{
						CPrintToChatAll("{crimson}GET A LOAD OF THIS GUY!!");
					}
				}
	
				RandomStats--;
				EmitSoundToAll("misc/halloween/hwn_bomb_flash.wav", _, _, _, _, _, GetRandomInt(75, 135));
				if(b_thisNpcIsARaid[entity])
				{
					char thename[64];
					NPC_GetNameById(entity, thename, sizeof(thename));
					CPrintToChatAll("{orange}Uh oh... you got a {yellow}%s {orange}with randomized stats.", thename);
					CPrintToChatAll("{orange}Bad luck!");
				}
			}
		}

		if(!b_thisNpcIsARaid[entity])
		{
			fl_Extra_Damage[entity] *= 1.0 + ((float(Waves_GetRoundScale() - 59)) * 0.02);
		}
		else
		{
			fl_Extra_Damage[entity] *= 1.0 + ((float(Waves_GetRoundScale() - 59)) * 0.01);
		}

		fl_Extra_Damage[entity] *= FM_Damage;
	
		//// BUFFS ////

		if(EloquenceBuffEnemies == 1)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Eloquence I", 30.0);

		if(EloquenceBuffEnemies == 2)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Eloquence II", 20.0);	

		if(EloquenceBuffEnemies == 3)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Eloquence III", 10.0);	

		if(RampartBuffEnemies == 1)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Rampart I", 30.0);

		if(RampartBuffEnemies == 2)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Rampart II", 20.0);	

		if(RampartBuffEnemies == 3)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Rampart III", 10.0);

		if(HurtleBuffEnemies == 1)
			Freeplay_ApplyStatusEffect( entity, "Freeplay Hurtle I", 30.0);

		if(HurtleBuffEnemies == 2)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Hurtle II", 20.0);	

		if(HurtleBuffEnemies == 3)
			Freeplay_ApplyStatusEffect(entity, "Freeplay Hurtle III", 10.0);
	
		if(HussarBuff)
			Freeplay_ApplyStatusEffect(entity, "Hussar's Warscream", 45.0);	
	
		if(PernellBuff)
			Freeplay_ApplyStatusEffect(entity, "False Therapy", 9.0);
	
		if(FusionBuff > 1)
			Freeplay_ApplyStatusEffect(entity, "Self Empowerment", 30.0);	
	
		if(FusionBuff > 0)
			Freeplay_ApplyStatusEffect(entity, "Ally Empowerment", 30.0);	
	
		if(OceanBuff > 1)
			Freeplay_ApplyStatusEffect(entity, "Oceanic Scream", 30.0);	
	
		if(OceanBuff > 0)
			Freeplay_ApplyStatusEffect(entity, "Oceanic Singing", 30.0);	
	
		if(VoidBuff > 1)
			Freeplay_ApplyStatusEffect(entity, "Void Strength II", 12.0);
	
		if(VoidBuff > 0)
			Freeplay_ApplyStatusEffect(entity, "Void Strength I", 6.0);
	
		if(VestaBuff)
			Freeplay_ApplyStatusEffect(entity, "Call To Vesta", 10.0);
	
		if(SquadBuff)
			Freeplay_ApplyStatusEffect(entity, "Squad Leader", 20.0);	
	
		if(Coffee)
		{
			Freeplay_ApplyStatusEffect(entity, "Caffinated", 8.0);
			Freeplay_ApplyStatusEffect(entity, "Caffinated Drain", 8.0);
		}
	
		if(merlton)
			Freeplay_ApplyStatusEffect(entity, "MERLT0N-BUFF", 5.0);	

		if(LoveNahTonic)
		{
			Freeplay_ApplyStatusEffect(entity, "Tonic Affliction", 8.0);
			Freeplay_ApplyStatusEffect(entity, "Tonic Affliction Hide", 8.0);
		}
	
		//// DEBUFFS ////
	
		if(SilenceDebuff)
			ApplyStatusEffect(entity, entity, "Silenced", 10.0);
	
		if(ProsperityDebuff > 2)
			ApplyStatusEffect(entity, entity, "Prosperity III", 999999.0);	
	
		if(ProsperityDebuff > 1)
			ApplyStatusEffect(entity, entity, "Prosperity II", 999999.0);	
	
		if(ProsperityDebuff > 0)
			ApplyStatusEffect(entity, entity, "Prosperity I", 999999.0);	
	
		if(StrangleDebuff > 2)
			ApplyStatusEffect(entity, entity, "Stranglation III", 999999.0);	
	
		if(StrangleDebuff > 1)
			ApplyStatusEffect(entity, entity, "Stranglation II", 999999.0);	
	
		if(StrangleDebuff > 0)
			ApplyStatusEffect(entity, entity, "Stranglation I", 999999.0);	
	
		if(IceDebuff > 2)
			ApplyStatusEffect(entity, entity, "Near Zero", 999999.0);	
	
		if(IceDebuff > 1)
			ApplyStatusEffect(entity, entity, "Cryo", 999999.0);	
	
		if(IceDebuff > 0)
			ApplyStatusEffect(entity, entity, "Freeze", 999999.0);	
	
		if(TeslarDebuff > 1)
			ApplyStatusEffect(entity, entity, "Teslar Electricution", 999999.0);	
	
		if(TeslarDebuff > 0)
			ApplyStatusEffect(entity, entity, "Teslar Shock", 999999.0);	
	
		if(CrippleDebuff > 0)
		{
			ApplyStatusEffect(entity, entity, "Cripple", 999999.0);	
			CrippleDebuff--;
		}
	
		if(CudgelDebuff > 0)
		{
			ApplyStatusEffect(entity, entity, "Cudgelled", 999999.0);	
			CudgelDebuff--;
		}
	
		// OTHER //
		switch(PerkMachine)
		{
			case 1:
			{
				fl_Extra_MeleeArmor[entity] *= 0.8;
				fl_Extra_RangedArmor[entity] *= 0.8;
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.15));
			}
			case 2:
			{
				fl_Extra_Damage[entity] *= 1.35;
			}
			case 3:
			{
				fl_Extra_Damage[entity] *= 1.15;
			}
			case 4:
			{
				ApplyStatusEffect(entity, entity, "Fluid Movement", 999999.0);		
			}
		}
		fl_Extra_Speed[entity] *= SpeedMult;
		fl_Extra_MeleeArmor[entity] *= MeleeMult;
		fl_Extra_RangedArmor[entity] *= RangedMult;
		if(EnemyShields > 0)
			VausMagicaGiveShield(entity, EnemyShields);
	}
}

static Action activatebuffs(Handle timer)
{
	if(FreeplayBuffTimer <= 0)
	{
		FreeplayBuffTimer = 1;
		CreateTimer(2.0, Freeplay_BuffTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
}

static Action Freeplay_BuffTimer(Handle Freeplay_BuffTimer)
{
	if(FreeplayBuffTimer <= 0)
	{
		return Plugin_Stop;
	}

	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsValidClient(client) && IsPlayerAlive(client))
		{
			if(CheesyPresence)
			{
				ApplyStatusEffect(client, client, "Cheesy Presence", 5.0);
			}
			else
			{
				/*
				if(Items_HasNamedItem(client, "A Block of Cheese"))
					ApplyStatusEffect(client, client, "Cheesy Presence", 5.0);
				*/
			}

			switch(EloquenceBuff)
			{
				case 1:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence III", 5.0);
				}
			}

			switch(RampartBuff)
			{
				case 1:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart III", 5.0);
				}
			}

			switch(HurtleBuff)
			{
				case 1:
				{
					ApplyStatusEffect(client, client, "Freeplay Hurtle I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(client, client, "Freeplay Hurtle II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(client, client, "Freeplay Hurtle III", 5.0);
				}
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			if(CheesyPresence)
				ApplyStatusEffect(ally, ally, "Cheesy Presence", 5.0);

			switch(EloquenceBuff)
			{
				case 1:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence III", 5.0);
				}
			}

			switch(RampartBuff)
			{
				case 1:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart III", 5.0);
				}
			}

			switch(HurtleBuff)
			{
				case 1:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Hurtle I", 5.0);
				}
				case 2:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Hurtle II", 5.0);
				}
				case 3:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Hurtle III", 5.0);
				}
			}
		}
	}

	return Plugin_Continue;
}

void Freeplay_OnEndWave(int &cash)
{
	switch(FreeplayModifActive)
	{
		case INTENSE:
		{
			FM_Damage *= 1.005;
		}
		case MUSCLE:
		{
			FM_Damage *= 1.0075;
		}
		case SQUEEZER:
		{
			FM_Damage *= 1.01;
			if(squeezerplus)
				FM_Damage *= 1.02;
		}
	}

	switch(FreeplayModifActive)
	{
		case INTENSE:
		{
			FM_Health *= 1.0035;
		}
		case MUSCLE:
		{
			FM_Health *= 1.0075;
		}
		case SQUEEZER:
		{
			FM_Health *= 1.0125;
			if(squeezerplus)
				FM_Health *= 1.02;
		}
	}

	if(ExplodingNPC)
	{
		CPrintToChatAll("{lime}Enemies will no longer explode.");
		ExplodingNPC = false;
		IsExplodeWave = false;
	}
	
	cash += CashBonus;
	int extracash = RoundToCeil(Freeplay_GetRemainingCash());
	if(extracash > 0)
	{
		cash += extracash;
	}

	Freeplay_SetRemainingCash(500.0);
	Freeplay_SetCashTime(GetGameTime() + 12.5);
}

float Freeplay_SetupValues()
{
	return gay;
}
void Freeplay_SetupStart(bool extra = false)
{
	if(i_WaveHasFreeplay != 2)
		return;

//	bool wrathofirln = false;

	bool guaranteedraid = false;
	if(extra)
	{
		FreeplayBuffTimer = 0;
		CreateTimer(4.0, activatebuffs, _, TIMER_FLAG_NO_MAPCHANGE);
		/*
		int irlnreq = 1;

		int wrathchance = GetRandomInt(0, 100);
		if(wrathchance < irlnreq)
		{
			wrathofirln = true;
		}
		*/

		setuptimes--;
		if(setuptimes <= 0)
		{
			guaranteedraid = true;
			setuptimes = 4;
		//	wrathofirln = false;
		}

		if(/*!wrathofirln && */!guaranteedraid)
		{
			EmitSoundToAll("ui/vote_success.wav");
		}
		
		int skullamount = 1;
		switch(FreeplayModifActive)
		{
			case INTENSE:
			{
				skullamount = 2;
			}
			case MUSCLE:
			{
				skullamount = 3;
			}
			case SQUEEZER:
			{
				skullamount = 4;
				if(squeezerplus)
					skullamount = 6;
			}
		}
		if(ExtraSkulls < 2)
		{
			ExtraSkulls += skullamount;
			CPrintToChatAll("{yellow}Current skull count: {orange}%d", ExtraSkulls+1);
		}
		

		SkullTimes = ExtraSkulls;
	}

	static int RerollTry;

	int rand = 6;
	if((++RerollTry) < 12)
		rand = GetURandomInt() % 85;
	/*
	if(wrathofirln)
	{
		int randomhp1 = GetRandomInt(-60000, 120000);
		HealthBonus += randomhp1;

		if(HealthBonus < 0)
			HealthBonus = 1;

		if(randomhp1 > 0)
		{
			CPrintToChatAll("{red}Enemies now have %d more health!", randomhp1);
		}
		else
		{
			CPrintToChatAll("{green}Enemies now have %d less health.", randomhp1);
		}

		float randomhp2 = GetRandomFloat(0.5, 2.0);
		HealthMulti *= randomhp2;
		if(randomhp2 > 1.0)
		{
			CPrintToChatAll("{red}Enemy health is multiplied by %.2fx!", randomhp2);
		}
		else
		{
			CPrintToChatAll("{green}Enemy health is multiplied by %.2fx.", randomhp2);
		}

		if(EscapeModeForNpc)
		{
			CPrintToChatAll("{green}Weaker enemies lose the given extra speed and damage from before.");
			EscapeModeForNpc = false;
		}
		else
		{
			CPrintToChatAll("{red}Weaker enemies now gain extra speed and damage!");
			EscapeModeForNpc = true;
		}

		if(HussarBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Hussar buff.");
			HussarBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Hussar buff!");
			HussarBuff = true;
		}

		if(PernellBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Purnell buff.");
			PernellBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Purnell buff!");
			PernellBuff = true;
		}

		if(IceDebuff > 3)
		{
			CPrintToChatAll("{red}All enemies have lost the Cryo debuff!");
			IceDebuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All enemies now gain a layer of Cyro debuff.");
			IceDebuff++;
		}

		if(TeslarDebuff > 2)
		{
			CPrintToChatAll("{red}All enemies have lost the Teslar debuff!");
			TeslarDebuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All enemies now gain a layer of Teslar debuff.");
			TeslarDebuff++;
		}

		if(FusionBuff > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Fusion buff.");
			FusionBuff = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of Fusion buff!");
			FusionBuff++;
		}

		if(OceanBuff > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Ocean buff.");
			OceanBuff = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of Ocean buff!");
			OceanBuff++;
		}

		if(GetRandomInt(1, 2) > 1)
		{
			int randomcripple = GetRandomInt(300, 900);
			CrippleDebuff += randomcripple;
			CPrintToChatAll("{green}The next %d enemies will now gain the Crippled debuff.", randomcripple);

			int randomcudgel = GetRandomInt(300, 900);
			CudgelDebuff += randomcudgel;
			CPrintToChatAll("{green}The next %d enemies will now gain the Cudgel debuff.", randomcudgel);
		}
		else
		{
			RandomStats += GetRandomInt(8, 16);
			CPrintToChatAll("{red}%d random enemies will receive randomized stats! You'll never know when.", RandomStats);
		}

		if(GetRandomInt(1, 2) > 1)
		{
			int randomonkill = GetRandomInt(4, 12);
			CPrintToChatAll("{green}All enemies now give out %d extra credits on death.", randomonkill);
			KillBonus += randomonkill;
		}
		else
		{
			if(KillBonus < 1)
			{
				int randomonkill = GetRandomInt(4, 12);
				CPrintToChatAll("{green}All enemies now give out %d extra credits on death.", randomonkill);
				KillBonus += randomonkill;
			}
			else
			{
				CPrintToChatAll("{red}Reduced the credit per enemy kill by 2!");
				KillBonus -= 2;
			}
		}

		if(GetRandomInt(1, 2) > 1)
		{
			int randomcredits = GetRandomInt(500, 1500);
			CPrintToChatAll("{green}You now gain %d extra credits per wave.", randomcredits);
			CashBonus += randomcredits;
		}
		else
		{
			if(CashBonus < 100)
			{
				int randomcredits = GetRandomInt(500, 1500);
				CPrintToChatAll("{green}You now gain %d extra credits per wave.", randomcredits);
				CashBonus += randomcredits;
			}
			else
			{
				CPrintToChatAll("{red}Reduced extra credits gained per wave by 150!");
				CashBonus -= 150;
			}
		}

		float randommini = GetRandomFloat(0.5, 2.0);
		MiniBossChance *= randommini;
		if(randommini > 1.0)
		{
			CPrintToChatAll("{red}Mini-boss spawn rate has been multiplied by %.2fx!", randommini);
		}
		else
		{	
			CPrintToChatAll("{green}Mini-boss spawn rate has been multiplied by %.2fx.", randommini);
		}

		float randomspeed = GetRandomFloat(0.275, 1.5);
		SpeedMult *= randomspeed;
		if(randomspeed > 1.0)
		{
			CPrintToChatAll("{red}Enemy speed has been multiplied by %.2fx!", randomspeed);
		}
		else
		{
			CPrintToChatAll("{green}Enemy speed has been multiplied by %.2fx.", randomspeed);
		}

		float randommelee = GetRandomFloat(0.25, 1.75);
		MeleeMult *= randommelee;
		if(randommelee < 1.0)
		{
			CPrintToChatAll("{red}Enemy melee vulnerability has been multiplied by %.2fx!", randommelee);
		}
		else
		{
			CPrintToChatAll("{green}Enemy melee vulnerability has been multiplied by %.2fx.", randommelee);
		}

		float randomranged = GetRandomFloat(0.25, 1.75);
		RangedMult *= randomranged;
		if(randomranged < 1.0)
		{
			CPrintToChatAll("{red}Enemy ranged vulnerability has been multiplied by %.2fx!", randomranged);
		}
		else
		{
			CPrintToChatAll("{green}Enemy ranged vulnerability has been multiplied by %.2fx.", randomranged);
		}

		int randomshield = GetRandomInt(-12, 12);
		EnemyShields += randomshield;
		if(EnemyShields > 15)
			EnemyShields = 15;

		if(EnemyShields < 0)
			EnemyShields = 0;

		if(randomshield > 0)
		{
			CPrintToChatAll("{red}All enemies receieve %d expidonsan shields!", randomshield);
		}
		else
		{
			CPrintToChatAll("{green}All enemies lose %d expidonsan shields.", randomshield);
		}

		if(VoidBuff > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Void buff.");
			VoidBuff = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of the Void buff!");
			VoidBuff++;
		}

		if(VestaBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Call to Vesta buff.");
			VestaBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Call to Vesta buff!");
			VestaBuff = true;
		}

		if(SquadBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Squad Leader buff.");
			SquadBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Squad Leader buff!");
			SquadBuff = true;
		}

		if(Coffee)
		{
			CPrintToChatAll("{green}All enemies have lost the Caffinated buff.");
			Coffee = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Caffinated buff! {yellow}(Includes Caffinated Drain)");
			Coffee = true;
		}

		if(StrangleDebuff > 3)
		{
			CPrintToChatAll("{red}All enemies have lost the Stranglation debuff!");
			StrangleDebuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All enemies now gain a layer of the Stranglation debuff.");
			StrangleDebuff++;
		}

		if(ProsperityDebuff > 3)
		{
			CPrintToChatAll("{red}All enemies have lost the Prosperity debuff!");
			ProsperityDebuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All enemies now gain a layer of the Prosperity debuff.");
			ProsperityDebuff++;
		}

		if(SilenceDebuff)
		{
			CPrintToChatAll("{red}All enemies have been Unsilenced!");
			SilenceDebuff = false;
		}
		else
		{
			CPrintToChatAll("{green}All enemies are now silenced for 10 seconds after spawning.");
			SilenceDebuff = true;
		}

		if(CheesyPresence)
		{
			CPrintToChatAll("{red}You no longer feel a {orange}Cheesy Presence {red}around you.");
			CheesyPresence = false;
		}
		else
		{
			CPrintToChatAll("{green}You start to feel a {orange}Cheesy Presence {green}around you...");
			CheesyPresence = true;
		}

		if(EloquenceBuff > 2)
		{
			CPrintToChatAll("{red}Removed the Eloquence buff from everyone!");
			EloquenceBuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All players and allied npcs now gain a layer of the Eloquence buff.");
			EloquenceBuff++;
		}

		if(RampartBuff > 2)
		{
			CPrintToChatAll("{red}Removed the Rampart buff from everyone!");
			RampartBuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All players and allied npcs now gain a layer of the Rampart buff.");
			RampartBuff++;
		}

		if(merlton)
		{
			CPrintToChatAll("{green}All enemies have lost the Merlton buff.");
			merlton = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Merlton buff!");
			merlton = true;
		}

		if(GetRandomInt(1, 2) == 1)
		{
			CPrintToChatAll("{red}Stronger enemy types are now more likely to appear!");
			EnemyChance++;
		}
		else
		{
			if(EnemyChance < 3)
			{
				CPrintToChatAll("{red}Stronger enemy types are now more likely to appear!");
				EnemyChance++;
			}
	
			CPrintToChatAll("{green}Stronger enemy types are now less likely to appear.");
			EnemyChance--;
		}

		PerkMachine = GetRandomInt(0, 4);
		switch(PerkMachine)
		{
			case 1:
			{
				CPrintToChatAll("{red}All enemies are now using the Obsidian Oaf perk, And thus gain +20% resist and +15% HP!");
				PerkMachine = 1;
			}
			case 2:
			{
				CPrintToChatAll("{red}All enemies are now using the Morning Coffee perk, And thus gain 35% Extra Damage!");
				PerkMachine = 2;
			}
			case 3:
			{
				CPrintToChatAll("{red}All enemies are now using the Marksman Beer perk, and thus gain 15% Extra Damage!");
				PerkMachine = 3;
			}
			case 4:
			{
				CPrintToChatAll("{red}All enemies are now using the Hasty Hops perk, and thus cannot be slowed!");
				PerkMachine = 4;
			}
			default:
			{
				CPrintToChatAll("{green}All enemies are now using the Regene Berry perk, this is useless and removes their previous perk.");
				PerkMachine = 0;
			}
		}

		if(EloquenceBuffEnemies > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Eloquence Buff.");
			EloquenceBuffEnemies = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of the Eloquence buff.");
			EloquenceBuffEnemies++;
		}

		if(RampartBuffEnemies > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Rampart Buff.");
			RampartBuffEnemies = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of the Rampart buff!");
			RampartBuffEnemies++;
		}
		if(HurtleBuffEnemies > 2)
		{
			CPrintToChatAll("{green}All enemies have lost the Hurtle Buff.");
			HurtleBuffEnemies = 0;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain a layer of the Hurtle buff!");
			HurtleBuffEnemies++;
		}

		if(HurtleBuff > 2)
		{
			CPrintToChatAll("{red}Removed the Hurtle buff from everyone!");
			HurtleBuff = 0;
		}
		else
		{
			CPrintToChatAll("{green}All players and allied npcs now gain a layer of the Hurtle buff.");
			HurtleBuff++;
		}

		if(LoveNahTonic)
		{
			CPrintToChatAll("{green}Ok, that's enough Tonic...");
			LoveNahTonic = false;
		}
		else
		{
			CPrintToChatAll("{pink}Love is in the air? {crimson}WRONG! {red}Tonic Affliction in the enemies.");
			LoveNahTonic = true;
		}

		float Atkspd = GetRandomFloat(0.25, 1.5);
		ExtraAttackspeed *= Atkspd;
		if(Atkspd < 1.0)
		{
			CPrintToChatAll("{red}Enemy attackspeed has been multiplied by %.2fx!", Atkspd);
		}
		else
		{
			CPrintToChatAll("{green}Enemy attackspeed has been multiplied by %.2fx.", Atkspd);
		}

		switch(GetRandomInt(1, 6))
		{
			case 1:
			{
				CPrintToChatAll("{red}Hey, im thinking of something.... What if, a {gold}combine, {red}and a {gold}zombie, {red}were...");
				zombiecombine = true;
			}
			case 2:
			{
				CPrintToChatAll("{red}III THINK YOU NEED MORE MEN!");
				moremen = 1;
			}
			case 3:
			{
				CPrintToChatAll("{red}THE DARKNESS IS COMING. {crimson}YOU NEED TO RUN.");
				DarknessComing = true;
			}
			case 4:
			{
				CPrintToChatAll("{red}You begin to hear voices in your head...");
				Schizophrenia = true;
			}
			case 5:
			{
				CPrintToChatAll("{red}Your final challenge... a {crimson}Nourished Spewer.");
				thespewer = true;
			}
			default:
			{
				CPrintToChatAll("{purple}Otherworldly beings approach from a dimensional rip...");
				immutable = true;
			}
		}

		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && !b_IsPlayerABot[client])
			{
				SetHudTextParams(-1.0, -1.0, 5.0, 255, 135, 0, 255);
				ShowHudText(client, -1, "Suffer the Wrath of Irln.");
			}
		}

		EmitSoundToAll("ambient/halloween/thunder_01.wav");
		CPrintToChatAll("{orange}Wrath of Irln: {yellow}(almost) {crimson}ALL SKULLS HAVE BEEN ACTIVATED. The effects are described above.");
		gay = 0.0;
	}
	else 
	*/
	if(guaranteedraid)
	{
		EmitSoundToAll("music/mvm_class_select.wav");
		EmitSoundToAll("items/powerup_pickup_king.wav");
		CPrintToChatAll("{strange}--==({gold}RAID ROULETTE!!{strange})==--");
		CPrintToChatAll("{gold}--==({strange}LET THOU FATE BE RANDOMIZED!{gold})==--");
		CPrintToChatAll("{green}-=({lime}Winning this wave will reward you with 5000 extra credits.{green})=-");
		CreateTimer(5.0, Freeplay_RouletteMessage, _, TIMER_FLAG_NO_MAPCHANGE);

		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				CPrintToChatAll("{gold}Koshi{white}: Ooh, this is gonna be {crimson}funny... {white}Now, you'll fight...");
			}
			case 2:
			{
				CPrintToChatAll("{gold}Koshi{white}: Aah, perfect! {orange}This was gettin' a little boring. {white}I'll send in...");
			}
			case 3:
			{
				CPrintToChatAll("{gold}Koshi{white}: Todaaaay's punching bag will be.... {crimson}hehe...");
			}
			default:
			{
				CPrintToChatAll("{gold}Koshi{white}: Oh, nice! An interesting event...");
			}
		}
		gay = 10.0;
	}
	else
	{
		gay = 0.0;
		char message[128];
		switch(rand)
		{
			/// HEALTH SKULLS ///
			case 0:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 3000 more health!");
				HealthBonus += 3000;
			}
			case 1:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 5000 more health!");
				HealthBonus += 5000;
			}
			case 2:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 8% more health!");
				HealthMulti *= 1.08;
			}
			case 3:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 4% more health!");
				HealthMulti *= 1.04;
			}
			case 4:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 8% less health.");
				HealthMulti *= 0.92;
			}
			case 5:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 4% less health.");
				HealthMulti *= 0.96;
			}
			case 6:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {green}2000 less health {yellow}but {red}7% more health.");
				HealthBonus -= 2000;
				HealthMulti *= 1.07;
			}
			case 7:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {green}5000 less health {yellow}but {red}10% more health.");
				HealthBonus -= 5000;
				HealthMulti *= 1.1;
			}
			case 8:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {red}3000 more health {yellow}but {green}7% less health.");
				HealthBonus += 3000;
				HealthMulti /= 1.07;
			}
			case 9:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {red}5000 more health {yellow}but {green}10% less health.");
				HealthBonus += 5000;
				HealthMulti /= 1.1;
			}

			/// BUFF/DEBUFF SKULLS //
			case 10:
			{
				strcopy(message, sizeof(message), "{darkgray}Nothing happend, probably a good thing...");
				/*
				if(EscapeModeForNpc)
				{
					strcopy(message, sizeof(message), "{green}Weaker enemies lose the given extra speed and damage from before.");
					EscapeModeForNpc = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}Weaker enemies now gain extra speed and damage!");
					EscapeModeForNpc = true;
				}
				*/
			}
			case 11:
			{
				if(HussarBuff)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Hussar buff.");
					HussarBuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Hussar buff!");
					HussarBuff = true;
				}
			}
			case 12:
			{
				if(PernellBuff)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Purnell buff.");
					PernellBuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Purnell buff!");
					PernellBuff = true;
				}
			}
			case 13:
			{
				if(IceDebuff > 3)
				{
					strcopy(message, sizeof(message), "{red}All enemies have lost the Cryo debuff!");
					IceDebuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All enemies now gain a layer of Cyro debuff.");
					IceDebuff++;
				}
			}
			case 14:
			{
				if(TeslarDebuff > 1)
				{
					strcopy(message, sizeof(message), "{red}All enemies have lost the Teslar debuff!");
					TeslarDebuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All enemies now gain a layer of Teslar debuff.");
					TeslarDebuff++;
				}
	
			}
			case 15:
			{
				if(FusionBuff > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Fusion buff.");
					FusionBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Fusion buff!");
					FusionBuff++;
				}
				
			}
			case 16:
			{
				if(OceanBuff > 1)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Ocean buff.");
					OceanBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Ocean buff!");
					OceanBuff++;
				}
			}
			case 17:
			{
				strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Crippled debuff.");
				CrippleDebuff += 300;
			}
			case 18:
			{
				strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Cudgel debuff.");
				CudgelDebuff += 300;
			}
			case 19:
			{
				RandomStats += GetRandomInt(3, 6);
				strcopy(message, sizeof(message), "{red}A random amount of random enemies will randomly receive randomized stats randomly!");
			}
	
			/// CREDIT SKULLS //
			case 20:
			{
				strcopy(message, sizeof(message), "{green}All enemies now give out 1 extra credits on death.");
				KillBonus += 1;
			}
			case 21:
			{
				strcopy(message, sizeof(message), "{green}All enemies now give out 2 extra credits on death.");
				KillBonus += 2;
			}
			case 22:
			{
				if(KillBonus < 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Reduced the credit per enemy kill by 1!");
				KillBonus--;
			}
			case 23:
			{
				if(CashBonus < 100)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Reduced extra credits gained per wave by 100!");
				CashBonus -= 100;
			}
			case 24:
			{
				strcopy(message, sizeof(message), "{green}You now gain 120 extra credits per wave.");
				CashBonus += 120;
			}
			case 25:
			{
				strcopy(message, sizeof(message), "{green}You now gain 180 extra credits per wave.");
				CashBonus += 180;
			}
	
			/// PERK SKULLS ///
			case 26:
			{
				if(PerkMachine == 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Obsidian Oaf perk, And thus gain +20% resist and +15% HP!");
				PerkMachine = 1;
			}
			case 27:
			{
				if(PerkMachine == 2)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Morning Coffee perk, And thus gain 35% Extra Damage!");
				PerkMachine = 2;
			}
			case 28: // YOUR ATTEMPTS AT DEATH ARE IN, VAIN
			{
				if(PerkMachine == 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Marksman Beer perk, and thus gain 15% Extra Damage!");
				PerkMachine = 3;
			}
			case 29:
			{
				if(PerkMachine == 4)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Hasty Hops perk, and thus cannot be slowed!");
				PerkMachine = 4;
			}
			case 30:
			{
				if(PerkMachine == 0)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{green}All enemies are now using the Regene Berry perk, this is useless and removes their previous perk.");
				PerkMachine = 0;
			}
	
			/// MISCELANEOUS SKULLS ///
			case 31:
			{
				if(friendunit)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}You will gain a strong, friendly unit.");
				friendunit = true;
			}
			case 32:
			{
				strcopy(message, sizeof(message), "{red}Mini-boss spawn rate has been multiplied by 10%!");
				MiniBossChance *= 1.1;
			}
			case 33:
			{
				strcopy(message, sizeof(message), "{green}Mini-boss spawn rate has been multiplied by 10%.");
				MiniBossChance *= 0.9;
			}
			case 34:
			{
				if(EnemyBosses == 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Some enemy types now gain extra stats!");
				if(EnemyBosses)
				{
					EnemyBosses--;
				}
				else
				{
					EnemyBosses = 6;
				}
			}
			case 35:
			{
				if(ImmuneNuke == 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Some enemy types are now immune to the Nuke Powerup!");
				if(ImmuneNuke)
				{
					ImmuneNuke--;
				}
				else
				{
					ImmuneNuke = 4;
				}
			}
			case 36:
			{
				//if(EnemyChance > 8)
				//{
				//	Freeplay_SetupStart();
				//	return;
				//}
	
				strcopy(message, sizeof(message), "{red}Stronger enemy types are now more likely to appear!");
				EnemyChance++;
			}
			case 37:
			{
				if(EnemyChance < 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{green}Stronger enemy types are now less likely to appear.");
				EnemyChance--;
			}
	
			/// SAMU'S SKULLS (new!) ///
			case 38:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 10% faster!");
				SpeedMult += 0.1;
			}
			case 39:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 15% faster!");
				SpeedMult += 0.15;
			}
			case 40:
			{
				if(SpeedMult < 0.25)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 5% slower.");
				SpeedMult -= 0.05;
				if(SpeedMult < 0.25)
					SpeedMult = 0.25;
			}
			case 41:
			{
				if(SpeedMult < 0.25)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 10% slower.");
				SpeedMult -= 0.10;
				if(SpeedMult < 0.25)
					SpeedMult = 0.25;
			}
			case 42:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 15% more melee damage.");
				MeleeMult += 0.15;
			}
			case 43:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more melee damage.");
				MeleeMult += 0.2;
			}
			case 44:
			{
				if(MeleeMult < 0.01) // 95% melee res max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Enemies will now take 15% less melee damage.");
				MeleeMult -= 0.15;
				if(MeleeMult < 0.01)
				{
					MeleeMult = 0.01;
				}
			}
			case 45:
			{
				if(MeleeMult < 0.01)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Enemies will now take 20% less melee damage.");
				MeleeMult -= 0.2;
				if(MeleeMult < 0.01)
				{
					MeleeMult = 0.01;
				}
			}
			case 46:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 15% more ranged damage.");
				RangedMult += 0.15;
			}
			case 47:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more ranged damage.");
				RangedMult += 0.2;
			}
			case 48:
			{
				strcopy(message, sizeof(message), "{red}Enemy attackspeed has been multiplied by x0.9!");
				ExtraAttackspeed *= 0.9;
			}
			case 49:
			{
				strcopy(message, sizeof(message), "{green}Enemy attackspeed has been reduced by an additional 5%.");
				ExtraAttackspeed += 0.05;
			}
			case 50:
			{
				if(RangedMult < 0.01) // 95% ranged res max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Enemies will now take 15% less ranged damage.");
				RangedMult -= 0.15;
				if(RangedMult < 0.01)
				{
					RangedMult = 0.01;
				}
			}
			case 51:
			{
				if(RangedMult < 0.01)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Enemies will now take 20% less ranged damage.");
				RangedMult -= 0.2;
				if(RangedMult < 0.01)
				{
					RangedMult = 0.01;
				}
			}
			case 52, 53:
			{
				if(ExplodingNPC)
				{
					Freeplay_SetupStart();
					return;
				}
				ExplodeNPCDamage = GetRandomInt(25, 125);
				strcopy(message, sizeof(message), "{red}Now, enemies will explode on death!");
				ExplodingNPC = true;
				EmitSoundToAll("ui/mm_medal_silver.wav");
			}
			
			case 54:
			{
				Freeplay_SetupStart();
				return;
				/*
				if(EnemyShields >= 15)
				{
					EnemyShields = 15;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}All enemies receieve 3 expidonsan shields!");
				EnemyShields += 3;
				*/
			}
			case 55:
			{
				Freeplay_SetupStart();
				/*
				return;
				if(EnemyShields >= 15)
				{
					EnemyShields = 15;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}All enemies receieve 6 expidonsan shields!");
				EnemyShields += 6;
				*/
			}
			case 56:
			{
				Freeplay_SetupStart();
				return;
				/*
				if(EnemyShields <= 0)
				{
					EnemyShields = 0;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}All enemies lose 2 expidonsan shields.");
				EnemyShields -= 2;
				*/
			}
			case 57:
			{
				Freeplay_SetupStart();
				return;
				/*
				if(EnemyShields <= 0)
				{
					EnemyShields = 0;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}All enemies lose 4 expidonsan shields.");
				EnemyShields -= 4;
				*/
			}
			
			case 58:
			{
				if(VoidBuff > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Void buff.");
					VoidBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of the Void buff!");
					VoidBuff++;
				}
			}
			case 59:
			{
				if(VestaBuff)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Call to Vesta buff.");
					VestaBuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Call to Vesta buff!");
					VestaBuff = true;
				}
			}
			case 60:
			{
				if(SquadBuff)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Squad Leader buff.");
					SquadBuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Squad Leader buff!");
					SquadBuff = true;
				}
			}
			case 61:
			{
				if(Coffee)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Caffinated buff.");
					Coffee = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Caffinated buff! {yellow}(Includes Caffinated Drain)");
					Coffee = true;
				}
			}
			case 62:
			{
				if(StrangleDebuff > 3)
				{
					strcopy(message, sizeof(message), "{red}All enemies have lost the Stranglation debuff!");
					StrangleDebuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All enemies now gain a layer of the Stranglation debuff.");
					StrangleDebuff++;
				}
			}
			case 63:
			{
				if(ProsperityDebuff > 3)
				{
					strcopy(message, sizeof(message), "{red}All enemies have lost the Prosperity debuff!");
					ProsperityDebuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All enemies now gain a layer of the Prosperity debuff.");
					ProsperityDebuff++;
				}
			}
			case 64:
			{
				if(SilenceDebuff)
				{
					strcopy(message, sizeof(message), "{red}All enemies have been Unsilenced!");
					SilenceDebuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All enemies are now silenced for 10 seconds after spawning.");
					SilenceDebuff = true;
				}
			}
			case 65:
			{
				// 7.5% chance, otherwise retry.
				if(GetRandomFloat(0.0, 1.0) <= 0.075)
				{
					strcopy(message, sizeof(message), "{green}A new special weapon is now available for purchase!");
					Rogue_RareWeapon_Collect();
				}
				else
				{
					Freeplay_SetupStart();
					return;
				}
			}
			case 66:
			{
				if(UnlockedSpeed)
				{
					Freeplay_SetupStart();
					return;
				}
				UnlockedSpeed = true;
				Store_DiscountNamedItem("Adrenaline", 999);
				strcopy(message, sizeof(message), "{green}Adrenaline is now buyable in the passive store!");
			}
			case 67:
			{
				if(CheesyPresence)
				{
					strcopy(message, sizeof(message), "{red}You no longer feel a {orange}Cheesy Presence {red}around you.");
					CheesyPresence = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}You start to feel a {orange}Cheesy Presence {green}around you...");
					CheesyPresence = true;
				}
			}
			case 68:
			{
				if(EloquenceBuff > 2)
				{
					strcopy(message, sizeof(message), "{red}Removed the Eloquence buff from everyone!");
					EloquenceBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All players and allied npcs now gain a layer of the Eloquence buff.");
					EloquenceBuff++;
				}
			}
			case 69:
			{
				if(RampartBuff > 2)
				{
					strcopy(message, sizeof(message), "{red}Removed the Rampart buff from everyone!");
					RampartBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All players and allied npcs now gain a layer of the Rampart buff.");
					RampartBuff++;
				}
			}
			case 70:
			{
				if(zombiecombine)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Hey, im thinking of something.... What if, a {gold}combine, {red}and a {gold}zombie, {red}were...");
				zombiecombine = true;
			}
			case 71:
			{
				if(moremen)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}III THINK YOU NEED MORE MEN!");
				moremen = 1;
			}
			case 72:
			{
				if(immutable)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{purple}Otherworldly beings approach from a dimensional rip...");
				immutable = true;
			}
			case 73:
			{
				if(merlton)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Merlton buff.");
					merlton = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Merlton buff!");
					merlton = true;
				}
			}
			case 74:
			{
				if(EloquenceBuffEnemies > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Eloquence Buff.");
					EloquenceBuffEnemies = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of the Eloquence buff.");
					EloquenceBuffEnemies++;
				}
			}
			case 75:
			{
				if(RampartBuffEnemies > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Rampart Buff.");
					RampartBuffEnemies = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of the Rampart buff!");
					RampartBuffEnemies++;
				}
			}
			case 76:
			{
				if(HurtleBuffEnemies > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Hurtle Buff.");
					HurtleBuffEnemies = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of the Hurtle buff!");
					HurtleBuffEnemies++;
				}
			}
			case 77:
			{
				if(HurtleBuff > 2)
				{
					strcopy(message, sizeof(message), "{red}Removed the Hurtle buff from everyone!");
					HurtleBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{green}All players and allied npcs now gain a layer of the Hurtle buff.");
					HurtleBuff++;
				}
			}
			case 78:
			{
				if(LoveNahTonic)
				{
					strcopy(message, sizeof(message), "{green}Ok, that's enough Tonic...");
					LoveNahTonic = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{pink}Love is in the air? {crimson}WRONG! {red}Tonic Affliction in the enemies.");
					LoveNahTonic = true;
				}
			}
			case 79:
			{
				strcopy(message, sizeof(message), "{yellow}Y'know what? I'll throw in another extra skull.");
				ExtraSkulls++;
			}
			case 80:
			{
				strcopy(message, sizeof(message), "{yellow}Y'know what? I'll throw in another extra skull.");
				ExtraSkulls++;
			//	strcopy(message, sizeof(message), "{yellow}Actually, y'know what? Maybe i'll throw in TWO extra skulls even.");
			//	ExtraSkulls += 2;
			}
			case 81:
			{
				strcopy(message, sizeof(message), "{yellow}Y'know what? I'll throw in another extra skull.");
				ExtraSkulls++;
			//	strcopy(message, sizeof(message), "{red}ffffFFFFF-{crimson}FUCK {red}it, THREE EXTRA SKULLS!!!");
			//	ExtraSkulls += 3;
			}
			case 82:
			{
				if(Schizophrenia)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}As you pick this skull, you begin to hear voices in your head...");
				Schizophrenia = true;
			}
			case 83:
			{
				if(DarknessComing)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}THE DARKNESS IS COMING. {crimson}YOU NEED TO RUN.");
				DarknessComing = true;
			}
			case 84:
			{
				if(thespewer)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Your final challenge.... a {crimson}Nourished Spewer.");
				thespewer = true;
			}
			default:
			{
				strcopy(message, sizeof(message), "{yellow}Nothing!");
				// If this shows up, FIX YOUR CODE :)
			}	
		}

		RerollTry = 0;
		CPrintToChatAll("{orange}New Skull{default}: %s", message);

		if(ExplodingNPC && !IsExplodeWave)
		{
			CPrintToChatAll("{yellow}The exploding enemy skull lasts 1 wave. | Current Base damage: %d", ExplodeNPCDamage);
			IsExplodeWave = true;
		}
		if(SkullTimes > 0)
		{
			SkullTimes--;
			Freeplay_SetupStart();
		}
	}
}
