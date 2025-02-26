
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
static bool VictoriaBuff;
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
static bool AntinelNextWave;
static bool zombiecombine;
static int moremen;
static bool immutable;
static bool spotteralive;
static int spotter;
static int RandomStats;
static bool merlton;
static bool Sigmaller;
static float gay;
static int friendunitamount;
static int HurtleBuff;
static int HurtleBuffEnemies;
static bool LoveNahTonic;
static bool Schizophrenia;
static bool NormalSignaller;
static bool DarknessComing;

void Freeplay_OnMapStart()
{
	PrecacheSound("ui/vote_success.wav", true);
	PrecacheSound("ui/mm_medal_silver.wav", true);
	PrecacheSound("ambient/halloween/thunder_01.wav", true);
	PrecacheSound("misc/halloween/spelltick_set.wav", true);
	PrecacheSound("misc/halloween/hwn_bomb_flash.wav", true);
	PrecacheSound("music/mvm_class_select.wav", true);
}

void Freeplay_SpotterStatus(bool status)
{
	spotteralive = status;
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
	MiniBossChance = 0.2;
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
	EscapeModeForNpc = false;
	EnemyShields = 0;
	VoidBuff = 0;
	VictoriaBuff = false;
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
	AntinelNextWave = false;
	zombiecombine = false;
	moremen = 0;
	spotteralive = false;
	spotter = 0;
	RandomStats = 0;
	merlton = false;
	Sigmaller = false;
	gay = 0.0;
	friendunitamount = 0;
	HurtleBuff = 0;
	HurtleBuffEnemies = 0;
	LoveNahTonic = false;
	Schizophrenia = false;
	NormalSignaller = false;
	DarknessComing = false;
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
		if(AntinelNextWave)
			amount++;

		if(Sigmaller)
			amount++;

		if(zombiecombine)
			amount++;
	
		if(moremen)
			amount += 3;

		if(Schizophrenia)
			amount++;

		if(DarknessComing)
			amount++;

		if(NormalSignaller)
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
		makeexplosion(entity, entity, startPosition, "", ExplodeNPCDamage, 150, _, _, true, true, 6.0);
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
	for(int LoopMax = 1; LoopMax < 5 ; LoopMax++)
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
	if(RaidFight || friendunitamount || AntinelNextWave || zombiecombine || moremen || immutable || spotter || Sigmaller || Schizophrenia || NormalSignaller || DarknessComing)
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
				enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
			}
			case 3:
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_silvester");
				enemy.Health = RoundToFloor(2500000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
			}
			case 4:
			{
				enemy.Index = NPC_GetByPlugin("npc_god_alaxios");
				enemy.Health = RoundToFloor(4500000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60;res3";
			}
			case 5:
			{
				enemy.Index = NPC_GetByPlugin("npc_sensal");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
			}
			case 6:
			{
				enemy.Index = NPC_GetByPlugin("npc_stella");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_purge");
				enemy.Health = RoundToFloor(9000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 8:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_messenger");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_30";
			}
			case 9:	
			{
				enemy.Index = NPC_GetByPlugin("npc_bob_the_first_last_savior");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.65);
			}
			case 10:	
			{
				enemy.Index = NPC_GetByPlugin("npc_chaos_kahmlstein");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "sc60";
			}
			case 11:	
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_nemesis");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
			}
			case 12:	
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_mrx");
				enemy.Health = RoundToFloor(15000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.85);
			}
			case 13:
			{
				enemy.Index = NPC_GetByPlugin("npc_corruptedbarney");
				enemy.Health = RoundToFloor(10000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
			}
			case 14:
			{
				enemy.Index = NPC_GetByPlugin("npc_whiteflower_boss");
				enemy.Health = RoundToFloor(10000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraMeleeRes *= 3.0;
				enemy.ExtraRangedRes *= 2.0;
			}
			case 15:
			{
				enemy.Index = NPC_GetByPlugin("npc_void_unspeakable");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "forth";
			}
			case 16:
			{
				enemy.Index = NPC_GetByPlugin("npc_vhxis");
				enemy.Health = RoundToFloor(4500000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 17:
			{
				enemy.Index = NPC_GetByPlugin("npc_nemal");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
				enemy.ExtraDamage = 0.75;
			}
			case 18:
			{
				enemy.Index = NPC_GetByPlugin("npc_ruina_twirl");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 19:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_thompson");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.75;
			}
			case 20:
			{
				enemy.Index = NPC_GetByPlugin("npc_twins");
				enemy.Health = RoundToFloor(4500000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "Im_The_raid;My_Twin";
				enemy.ExtraDamage = 0.75;
			}
			/*
			case -1:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_johnson");
				enemy.Health = RoundToFloor(5000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.75; // johnson gets way too much damage in freeplay, reduce it
			}

			//FUCK you eno your raid is boring
			*/
			case 21:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_smith");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "raid_time";
			}
			case 22:
			{
				enemy.Index = NPC_GetByPlugin("npc_atomizer");
				enemy.Health = RoundToFloor(5000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 23:
			{
				enemy.Index = NPC_GetByPlugin("npc_the_wall");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 24:
			{
				enemy.Index = NPC_GetByPlugin("npc_harrison");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 25:	
			{
				enemy.Index = NPC_GetByPlugin("npc_castellan");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			case 26: // WHEN THE DUST SETTLES
			{
				enemy.Index = NPC_GetByPlugin("npc_lelouch");
				enemy.Health = RoundToFloor(12500000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = 0.75;
			}
			case 27:
			{
				enemy.Index = NPC_GetByPlugin("npc_omega_raid");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
			}
			default:
			{
				enemy.Index = NPC_GetByPlugin("npc_true_fusion_warrior");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
			}
		}

		if(Waves_GetRound() > 124)
			enemy.ExtraDamage *= 2.0;

		if(Waves_GetRound() > 174)
			enemy.ExtraDamage *= 2.0;

		// Raid health is lower before w150.
		if(Waves_GetRound() > 149)
			enemy.Health = RoundToCeil(float(enemy.Health) * 1.75);

		if(Waves_GetRound() > 174)
			enemy.Health = RoundToCeil(float(enemy.Health) * 1.5);

		// moni
		enemy.Credits += 10000.0;
		enemy.Does_Not_Scale = 1;
		count = 1;
		RaidFight = 0;
		shouldscale = false;
	}
	else if(friendunitamount)
	{
		enemy.Team = TFTeam_Red;
		count = friendunitamount;

		if(enemy.Health)
			enemy.Health = RoundToCeil(float(enemy.Health) * 0.65);

		if(enemy.ExtraDamage)
			enemy.ExtraDamage = 20.0;

		enemy.ExtraSpeed = 1.25;

		friendunitamount = 0;
		shouldscale = false;
	}
	else if(Sigmaller)
	{
		// Spawns a humongous Signaller that does multiple stuff.
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 1;

		enemy.Index = NPC_GetByPlugin("npc_freeplay_sigmaller");
		enemy.Health = RoundToFloor(4000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.Credits += 1.0;

		count = 1;
		Sigmaller = false;
		shouldscale = false;
	}
	else if(AntinelNextWave)
	{
		// Spawns an ant-sized Sentinel that has the same health as Stella in freeplay.
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 1;

		enemy.Index = NPC_GetByPlugin("npc_sentinel");
		enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.ExtraSpeed = 2.5;
		enemy.ExtraSize = 0.2; // smol
		enemy.Credits += 1.0;
		enemy.Is_Health_Scaled = 0;
		strcopy(enemy.CustomName, sizeof(enemy.CustomName), "Antinel");

		count = 1;
		AntinelNextWave = false;
	}
	else if(DarknessComing)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_darkenedheavy");
		enemy.Health = RoundToCeil(HealthBonus + (1250000.0 * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.02)));
		enemy.Credits += 100.0;
		enemy.ExtraMeleeRes = 1.25;
		enemy.ExtraRangedRes = 0.5;
		enemy.Is_Boss = 1;

		count = 6;
		DarknessComing = false;
	}
	else if(zombiecombine)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_zombine");
		enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.1);
		enemy.ExtraSpeed = 1.5;
		enemy.ExtraSize = 1.0; // smol
		enemy.Credits += 100.0;
		enemy.ExtraDamage = 3.0;
		enemy.Is_Boss = 0;
		enemy.Is_Health_Scaled = 0;

		count = 20;
		zombiecombine = false;
	}
	else if(moremen)
	{
		enemy.Is_Immune_To_Nuke = true;
		enemy.Index = NPC_GetByPlugin("npc_seaborn_heavy");
		enemy.Health = RoundToCeil(60000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.ExtraSpeed = 5.0;
		enemy.ExtraSize = 1.25;
		enemy.Credits += 125.0;
		enemy.ExtraDamage = 1.35;
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
		enemy.Health = RoundToCeil((HealthBonus + (700000.0 * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.01))) * 1.5);
		enemy.ExtraMeleeRes = 1.35;
		enemy.ExtraRangedRes = 1.0;
		enemy.ExtraSpeed = 1.0;
		enemy.ExtraDamage = 1.0;
		enemy.ExtraSize = 1.0;
		enemy.Credits += 100.0;

		count = 5;
		immutable = false;
	}
	else if(spotter)
	{
		enemy.Team = TFTeam_Red;
		enemy.Index = NPC_GetByPlugin("npc_spotter");
		enemy.Health = RoundToFloor(50000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Outlined = 0;
		count = 1;
		spotter--;
		shouldscale = false;
	}
	else if(Schizophrenia)
	{
		enemy.Index = NPC_GetByPlugin("npc_annoying_spirit");
		enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(Waves_GetRound() * 2) * MultiGlobalHighHealthBoss);
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Outlined = 0;
		enemy.Credits += 250.0;
		count = 1;
		Schizophrenia = false;
	}
	else if(NormalSignaller)
	{
		enemy.Team = TFTeam_Red;
		enemy.Index = NPC_GetByPlugin("npc_signaller");
		enemy.Health = 50000;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Outlined = 0;

		count = 1;
		NormalSignaller = false;
		shouldscale = false;
	}
	else
	{
		float bigchance;
		if(postWaves+1 < 89)
			bigchance = 0.98;
		else
			bigchance = 0.96;

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
			if(GetRandomInt(1, 2) == 2)
			{
				enemy.Index = NPC_GetByPlugin("npc_dimensionfrag");
				enemy.Health = 60000; // enemy hp is getting overriden apparently
			}
			else
			{
				enemy.Index = NPC_GetByPlugin("npc_vanishingmatter");
				enemy.Health = 150000; // enemy hp is getting overriden apparently
			}

			if(enemy.Health)
				enemy.Health = RoundToCeil(HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.01)));

			count = RoundToFloor((count * (((postWaves * 1.5) + 80) * 0.009)) * 0.5);

			enemy.ExtraMeleeRes = 1.35;
			enemy.ExtraRangedRes = 0.75;
			enemy.ExtraSize = 1.15;

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
				// Nerfing bob the first's army health due to freeplay scaling
				// Basically the same hp formula except HealthBonus is not there
				if(StrContains(enemy.CustomName, "First ") != -1)
				{
					enemy.Health = RoundToCeil(((enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009))) * 0.75);
				}
				else
				{
					enemy.Health = RoundToCeil((HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009))) * 0.75);
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
			enemy.ExtraSpeed = 1.1;
		}

		if(ImmuneNuke && !(enemy.Index % ImmuneNuke))
			enemy.Is_Immune_To_Nuke = true;

		if(KillBonus)
			enemy.Credits += KillBonus;

		shouldscale = true;
	}

	if(alaxios && count > 30)
		count = 30;

	if(count > 45)
		count = 45;

	if(shouldscale)
	{
		// stat related stuff
		enemy.ExtraSize *= ExtraEnemySize;	
		
		// count scaling
		float countscale = float(CountPlayersOnRed());
		if(countscale <= 8.0)
		{
			countscale *= 0.125; // below or equal to 8 players, scaling should be 0.125 per player
		}
		else if(countscale > 8.0 && countscale <= 12.0) 
		{
			countscale = 1.0; // above 8 players but below or equal to 12, player scaling should not activate
		}
		else
		{
			countscale *= 0.0782; // above 12 players, scaling should be 0.0782 per player, for a max of +25% enemies at 16 players assuming there can't be more.
		}

		if(countscale < 0.3)
			countscale = 0.3; // below or equal to 2 players, there are 70% less enemies

		count = RoundToCeil(float(count) * countscale);
	}

	if(count < 1)
		count = 1;

	if(enemy.Is_Boss == 1)
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.65);

	// 2 billion limit, it is necessary to prevent them from going bananas
	if(enemy.Health > 2000000000)
		enemy.Health = 2000000000;

	if(enemy.Team != TFTeam_Red)
		enemy.ExtraSize *= ExtraEnemySize;
}

static Action Freeplay_RouletteMessage(Handle timer)
{
	RaidFight = GetRandomInt(1, 27);
	EmitSoundToAll("misc/halloween/spelltick_set.wav", _, _, _, _, _, GetRandomInt(70, 135));
	switch(RaidFight)
	{
		case 2:
		{
			CPrintToChatAll("{crimson}THE BLITZKRIEG! {gold}- {red}Prepare to fight against the rogue machine!");
		}
		case 3:
		{
			CPrintToChatAll("{yellow}SILVESTER {white}& {darkblue}WALDCH! {gold}- {red}Enjoy eating rocks!");
		}
		case 4:
		{
			CPrintToChatAll("{lightblue}GOD ALAXIOS! {gold}- {red}Face the full power of Atlantis!");
		}
		case 5:
		{
			CPrintToChatAll("{blue}SENSAL! {gold}- {red}He shall reap you, and your resistances!");
		}
		case 6:
		{
			CPrintToChatAll("{aqua}STELLA {white}& {crimson}KARLAS! {gold}- {red}Hope you like spinning blades!");
		}
		case 7:	
		{
			CPrintToChatAll("{crimson}THE PURGE! {gold}- {red}Annihilation shall be absolute.");
		}
		case 8:	
		{
			CPrintToChatAll("{lightblue}THE MESSENGER! {gold}- {red}He REALLY wants to make Kahmlstein proud!");
		}
		case 9:	
		{
			CPrintToChatAll("{white}BOB THE FIRST! {gold}- {red}Are you a god?");
		}
		case 10:	
		{
			CPrintToChatAll("{darkblue}CHAOS KAHMLSTEIN! {gold}- {red}He thinks he's unstoppable, prove him wrong!");
		}
		case 11:	
		{
			CPrintToChatAll("{green}NEMESIS! {gold}- {red}Aah, the good ol' days when the speed module had no limits...");
		}
		case 12:	
		{
			CPrintToChatAll("{green}MR. X! {gold}- {red}MISTER WHAT!?");
		}
		case 13:
		{
			CPrintToChatAll("{midnightblue}CO0R0RR9R'R4R0#(##()#F92 B '11 A =)$ R 49I N 2G4 E 2#f Y =4,93RW9FW0LRSMUW320$");
		}
		case 14:
		{
			CPrintToChatAll("{crimson}WHITEFLOWER! {gold}- {red}...minus his army, of course.");
		}
		case 15:
		{
			CPrintToChatAll("{purple}UNSPEAKABLE! {gold}- {red}Does he actually speak though?");
		}
		case 16:
		{
			CPrintToChatAll("{purple}VHXIS! {gold}- {red}Fight against the void gatekeeper once more!");
		}
		case 17:
		{
			CPrintToChatAll("{lightblue}NEMAL! {gold}- {red}and silvester, of course!");
		}
		case 18:
		{
			CPrintToChatAll("{purple}TWIRL! {gold}- {red}Oh so you're strong? Fight her!");
		}
		case 19:
		{
			CPrintToChatAll("{community}Agent... thompson. {crimson}ew.");
		}
		case 20:
		{
			CPrintToChatAll("{forestgreen}The.... twins. {crimson}eew.");
		}
		/*
		case -1:
		{
			CPrintToChatAll("{community}Agent... johnson. {crimson}ew.");
		}
		*/
		case 21:
		{
			CPrintToChatAll("{darkgreen}Agent Smith. {crimson}*stink sound effect*");
		}
		case 22:
		{
			CPrintToChatAll("{blue}ATOMIZER! {gold}- {red}I wonder what that nitro fuel is made of...");
		}
		case 23:
		{
			CPrintToChatAll("{lightblue}HUSCARLS! {gold}- {red}Running around in circles just to hit a wall!");
		}
		case 24:
		{
			CPrintToChatAll("{skyblue}HARRISON! {gold}- {red}His rockets surely won't miss you!");
		}
		case 25:	
		{
			CPrintToChatAll("{blue}CASTELLAN! {gold}- {red}In the name of victoria, he won't allow you further in!");
		}
		case 26: // WHEN THE DUST SETTLES
		{
			CPrintToChatAll("{darkviolet}LELOUCH! {gold}- {red}The chaos-afflicted ruinian i've spoken about before...");
		}
		case 27:
		{
			CPrintToChatAll("{gold}OMEGA! - {red}Waltzing straight to you.");
		}
		default:
		{
			CPrintToChatAll("{yellow}TRUE FUSION WARRIOR! {gold}- {red}An infected menace!");
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

void Freeplay_SpawnEnemy(int entity)
{
	if(GetTeam(entity) != TFTeam_Red)
	{
		if(RandomStats)
		{
			if(GetRandomInt(0, 100) < 1) // 1% chance for this to work, it NEEDS to be extra rare.
			{
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * GetRandomFloat(0.25, 10.0)));
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", GetEntProp(entity, Prop_Data, "m_iHealth"));
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", GetEntPropFloat(entity, Prop_Send, "m_flModelScale") * GetRandomFloat(0.3, 3.5));
				fl_Extra_MeleeArmor[entity] *= GetRandomFloat(0.1, 2.35);
				fl_Extra_RangedArmor[entity] *= GetRandomFloat(0.1, 2.35);
				fl_Extra_Speed[entity] *= GetRandomFloat(0.25, 3.0);
				fl_Extra_Damage[entity] *= GetRandomFloat(0.35, 10.0);
	
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
			}
		}

		if(!b_thisNpcIsARaid[entity])
		{
				fl_Extra_Damage[entity] *= 2.0 + (((float(Waves_GetRound() - 59)) * 0.025));
		}
	
		//// BUFFS ////

		if(EloquenceBuffEnemies == 1)
			ApplyStatusEffect(entity, entity, "Freeplay Eloquence I", 30.0);

		if(EloquenceBuffEnemies == 2)
			ApplyStatusEffect(entity, entity, "Freeplay Eloquence II", 20.0);	

		if(EloquenceBuffEnemies == 3)
			ApplyStatusEffect(entity, entity, "Freeplay Eloquence III", 10.0);	

		if(RampartBuffEnemies == 1)
			ApplyStatusEffect(entity, entity, "Freeplay Rampart I", 30.0);

		if(RampartBuffEnemies == 2)
			ApplyStatusEffect(entity, entity, "Freeplay Rampart II", 20.0);	

		if(RampartBuffEnemies == 3)
			ApplyStatusEffect(entity, entity, "Freeplay Rampart III", 10.0);

		if(HurtleBuffEnemies == 1)
			ApplyStatusEffect(entity, entity, "Freeplay Hurtle I", 30.0);

		if(HurtleBuffEnemies == 2)
			ApplyStatusEffect(entity, entity, "Freeplay Hurtle II", 20.0);	

		if(HurtleBuffEnemies == 3)
			ApplyStatusEffect(entity, entity, "Freeplay Hurtle III", 10.0);
	
		if(HussarBuff)
			ApplyStatusEffect(entity, entity, "Hussar's Warscream", 45.0);	
	
		if(PernellBuff)
			ApplyStatusEffect(entity, entity, "False Therapy", 15.0);
	
		if(FusionBuff > 1)
			ApplyStatusEffect(entity, entity, "Self Empowerment", 30.0);	
	
		if(FusionBuff == 1 || FusionBuff > 2)
			ApplyStatusEffect(entity, entity, "Ally Empowerment", 30.0);	
	
		if(OceanBuff > 1)
			ApplyStatusEffect(entity, entity, "Oceanic Scream", 30.0);	
	
		if(OceanBuff > 0)
			ApplyStatusEffect(entity, entity, "Oceanic Singing", 30.0);	
	
		if(VoidBuff > 1)
			ApplyStatusEffect(entity, entity, "Void Strength II", 12.0);
	
		if(VoidBuff > 0)
			ApplyStatusEffect(entity, entity, "Void Strength I", 6.0);
	
		if(VictoriaBuff)
			ApplyStatusEffect(entity, entity, "Call To Victoria", 10.0);
	
		if(SquadBuff)
			ApplyStatusEffect(entity, entity, "Squad Leader", 20.0);	
	
		if(Coffee)
		{
			ApplyStatusEffect(entity, entity, "Caffinated", 8.0);
			ApplyStatusEffect(entity, entity, "Caffinated Drain", 8.0);
		}
	
		if(merlton)
			ApplyStatusEffect(entity, entity, "MERLT0N-BUFF", 5.0);	

		if(LoveNahTonic)
		{
			ApplyStatusEffect(entity, entity, "Tonic Affliction", 10.0);
			ApplyStatusEffect(entity, entity, "Tonic Affliction Hide", 10.0);
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

	for (int client = 0; client < MaxClients; client++)
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
	if(ExplodingNPC)
	{
		ExplodingNPC = false;
		IsExplodeWave = false;
	}

	cash += CashBonus;
}
float Freeplay_SetupValues()
{
	return gay;
}
void Freeplay_SetupStart(bool extra = false)
{
	bool wrathofirln = false;
	bool raidtime = false;
	if(extra)
	{
		FreeplayBuffTimer = 0;
		CreateTimer(4.0, activatebuffs, _, TIMER_FLAG_NO_MAPCHANGE);
		int raidreq = 15;
		int irlnreq = 2;
		
		if(Waves_GetRound() > 150)
			raidreq = 25;

		if(Waves_GetRound() > 100)
			irlnreq = 5;

		int raidchance = GetRandomInt(0, 100);
		if(raidchance < raidreq)
		{
			raidtime = true;
		}

		int wrathchance = GetRandomInt(0, 100);
		if(wrathchance < irlnreq)
		{
			raidtime = false;
			wrathofirln = true;
		}

		if(!wrathofirln && !raidtime)
		{
			EmitSoundToAll("ui/vote_success.wav");
		}
		
		//one more skull the further you go, its limited time so i tshould be CBT
	//	int exskull = GetRandomInt(0, 100);

	//	if(exskull < 20) // 20% chance
		{
			ExtraSkulls++;
			CPrintToChatAll("{yellow}Current skull count: {orange}%d", ExtraSkulls+1);
		}

		SkullTimes = ExtraSkulls;
	}

	static int RerollTry;

	int rand = 6;
	if((++RerollTry) < 12)
		rand = GetURandomInt() % 92;

	if(wrathofirln)
	{
		int randomhp1 = GetRandomInt(-50000, 150000);
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

		float randomhp2 = GetRandomFloat(0.2, 1.5);
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
			CPrintToChatAll("{red}All enemies now gain the Purnell buff for 15 seconds!");
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
			int randomcripple = GetRandomInt(400, 1200);
			CrippleDebuff += randomcripple;
			CPrintToChatAll("{green}The next %d enemies will now gain the Crippled debuff.", randomcripple);

			int randomcudgel = GetRandomInt(400, 1200);
			CudgelDebuff += randomcudgel;
			CPrintToChatAll("{green}The next %d enemies will now gain the Cudgel debuff.", randomcudgel);
		}
		else
		{
			RandomStats += GetRandomInt(5, 15);
			CPrintToChatAll("{red}%d random enemies will recieve randomized stats! You'll never know when.", RandomStats);
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
			int randomcredits = GetRandomInt(350, 750);
			CPrintToChatAll("{green}You now gain %d extra credits per wave.", randomcredits);
			CashBonus += randomcredits;
		}
		else
		{
			if(CashBonus < 100)
			{
				int randomcredits = GetRandomInt(350, 700);
				CPrintToChatAll("{green}You now gain %d extra credits per wave.", randomcredits);
				CashBonus += randomcredits;
			}
			else
			{
				CPrintToChatAll("{red}Reduced extra credits gained per wave by 150!");
				CashBonus -= 150;
			}
		}

		int guh = GetRandomInt(8, 16);
		CPrintToChatAll("{green}You will gain %d random friendly units.", guh);
		friendunitamount = guh;

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

		float randommelee = GetRandomFloat(0.3, 2.35);
		MeleeMult *= randommelee;
		if(randommelee < 1.0)
		{
			CPrintToChatAll("{red}Enemy melee vulnerability has been multiplied by %.2fx!", randommelee);
		}
		else
		{
			CPrintToChatAll("{green}Enemy melee vulnerability has been multiplied by %.2fx.", randommelee);
		}

		float randomranged = GetRandomFloat(0.3, 2.35);
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

		if(VictoriaBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Call to Victoria buff.");
			VictoriaBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Call to Victoria buff for 10 seconds!");
			VictoriaBuff = true;
		}

		if(SquadBuff)
		{
			CPrintToChatAll("{green}All enemies have lost the Squad Leader buff.");
			SquadBuff = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Squad Leader buff for 20 seconds");
			SquadBuff = true;
		}

		if(Coffee)
		{
			CPrintToChatAll("{green}All enemies have lost the Caffinated buff.");
			Coffee = false;
		}
		else
		{
			CPrintToChatAll("{red}All enemies now gain the Caffinated buff for 8 seconds! {yellow}(Includes Caffinated Drain)");
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

		float randomsize = GetRandomFloat(0.4, 1.8);
		ExtraEnemySize *= randomsize;
		CPrintToChatAll("{yellow}Enemy size has been multiplied by %.2fx!", randomsize);

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
			CPrintToChatAll("{red}All enemies now gain the Merlton buff for 5 seconds!");
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
				CPrintToChatAll("{red}All enemies are now using the Juggernog perk, And thus gain +20% resist and +15% HP!");
				PerkMachine = 1;
			}
			case 2:
			{
				CPrintToChatAll("{red}All enemies are now using the Double Tap perk, And thus gain 35% Extra Damage!");
				PerkMachine = 2;
			}
			case 3:
			{
				CPrintToChatAll("{red}All enemies are now using the Deadshot Daiquiri perk, and thus gain 15% Extra Damage!");
				PerkMachine = 3;
			}
			case 4:
			{
				CPrintToChatAll("{red}All enemies are now using the Speed Cola perk, and thus cannot be slowed!");
				PerkMachine = 4;
			}
			default:
			{
				CPrintToChatAll("{green}All enemies are now using the Quick Revive perk, this is useless and removes their previous perk.");
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
			CPrintToChatAll("{pink}Love is in the air? {crimson}WRONG! {red}Tonic Affliction in the enemies. {yellow}(Lasts 10s)");
			LoveNahTonic = true;
		}

		switch(GetRandomInt(1, 8))
		{
			case 1:
			{
				CPrintToChatAll("{red}Hey, im thinking of something.... What if, a {gold}combine, {red}and a {gold}zombie, {red}were...");
				zombiecombine = true;
			}
			case 2:
			{
				CPrintToChatAll("{red}III THINK YOU NEED MORE MEN!");
				moremen = 3;
			}
			case 3:
			{
				CPrintToChatAll("{red}An ant comes out of this skull, and its approaching to the bloody gate!");
				AntinelNextWave = true;
			}
			case 4:
			{
				CPrintToChatAll("{red}I FEEL SO SIGMA!!!!!");
				Sigmaller = true;
			}
			case 5:
			{
				CPrintToChatAll("{red}THE DARKNESS IS COMING. {crimson}YOU NEED TO RUN.");
				DarknessComing = true;
			}
			case 6:
			{
				CPrintToChatAll("{red}You begin to hear voices in your head...");
				Schizophrenia = true;
			}
			case 7:
			{
				CPrintToChatAll("{green}Seems like a common Signaller has decided to help in training.");
				DarknessComing = true;
			}
			default:
			{
				CPrintToChatAll("{purple}Otherworldly beings approach from a dimensional rip...");
				NormalSignaller = true;
			}
		}

		for (int client = 0; client < MaxClients; client++)
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
	else if(raidtime)
	{
		EmitSoundToAll("music/mvm_class_select.wav");
		EmitSoundToAll("items/powerup_pickup_king.wav");
		CPrintToChatAll("{strange}--==({gold}RAID ROULETTE!!{strange})==--");
		CPrintToChatAll("{gold}--==({strange}LET THOU FATE BE RANDOMIZED!{gold})==--");
		CPrintToChatAll("{green}-=({lime}Winning this wave will reward you with 10000 extra credits.{green})=-");
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
				CPrintToChatAll("{gold}Koshi{white}: Here's a trade offer! I recieve {orange}a piece of cheese{white} from your findings, and you recieve...");
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
			// The way I (samuu) manage the skulls is ordering the original ones, 
			// and at the very bottom, i put on the new ones (below raid skulls)
			// So i don't later have to worry about changing every case number
	
			/// HEALTH SKULLS ///
			case 0:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 22500 more health!");
				HealthBonus += 22500;
			}
			case 1:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 45000 more health!");
				HealthBonus += 45000;
			}
			case 2:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 15% more health!");
				HealthMulti *= 1.15;
			}
			case 3:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 20% more health!");
				HealthMulti *= 1.2;
			}
			case 4:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 15% less health.");
				HealthMulti *= 0.85;
			}
			case 5:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 20% less health.");
				HealthMulti *= 0.8;
			}
			case 6:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {green}30000 less health {yellow}but {red}10% more health.");
				HealthBonus -= 30000;
				HealthMulti *= 1.1;
			}
			case 7:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {green}60000 less health {yellow}but {red}20% more health.");
				HealthBonus -= 60000;
				HealthMulti *= 1.2;
			}
			case 8:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {red}30000 more health {yellow}but {green}15% less health.");
				HealthBonus += 30000;
				HealthMulti /= 1.15;
			}
			case 9:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {red}60000 more health {yellow}but {green}25% less health.");
				HealthBonus += 60000;
				HealthMulti /= 1.25;
			}

			/// BUFF/DEBUFF SKULLS //
			case 10:
			{
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
					strcopy(message, sizeof(message), "{red}All enemies now gain the Hussar buff! {yellow}(Lasts 45s)");
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
					strcopy(message, sizeof(message), "{red}All enemies now gain the Purnell buff for 15 seconds!");
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
				if(TeslarDebuff > 2)
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
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Fusion buff! {yellow}(Lasts 30s)");
					FusionBuff++;
				}
				
			}
			case 16:
			{
				if(OceanBuff > 2)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Ocean buff.");
					OceanBuff = 0;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Ocean buff! {yellow}(Lasts 30s)");
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
				RandomStats += 4;
				strcopy(message, sizeof(message), "{red}4 random enemies will recieve randomized stats! You'll never know when.");
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
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Juggernog perk, And thus gain +20% resist and +15% HP!");
				PerkMachine = 1;
			}
			case 27:
			{
				if(PerkMachine == 2)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Double Tap perk, And thus gain 35% Extra Damage!");
				PerkMachine = 2;
			}
			case 28: // YOUR ATTEMPTS AT DEATH ARE IN, VAIN
			{
				if(PerkMachine == 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Deadshot Daiquiri perk, and thus gain 15% Extra Damage!");
				PerkMachine = 3;
			}
			case 29:
			{
				if(PerkMachine == 4)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Speed Cola perk, and thus cannot be slowed!");
				PerkMachine = 4;
			}
			case 30:
			{
				if(PerkMachine == 0)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{green}All enemies are now using the Quick Revive perk, this is useless and removes their previous perk.");
				PerkMachine = 0;
			}
	
			/// MISCELANEOUS SKULLS ///
			case 31:
			{
				if(friendunitamount)
				{
					Freeplay_SetupStart();
					return;
				}
				int guh2 = GetRandomInt(4, 8);
				strcopy(message, sizeof(message), "{green}You will gain a random amount of friendly units.");
				friendunitamount = guh2;
			}
			case 32:
			{
				strcopy(message, sizeof(message), "{red}Mini-boss spawn rate has been increased by 50%!");
				MiniBossChance *= 1.5;
			}
			case 33:
			{
				strcopy(message, sizeof(message), "{green}Mini-boss spawn rate has been reduced by 25%.");
				MiniBossChance *= 0.75;
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
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more melee damage.");
				MeleeMult += 0.2;
			}
			case 43, 44:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more melee damage.");
				MeleeMult += 0.25;
			}
			case 45:
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
			case 46:
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
			case 47:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more ranged damage.");
				RangedMult += 0.20;
			}
			case 48, 49:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more ranged damage.");
				RangedMult += 0.25;
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
				if(EnemyShields >= 15)
				{
					EnemyShields = 15;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}All enemies receieve 3 expidonsan shields!");
				EnemyShields += 3;
			}
			case 55:
			{
				if(EnemyShields >= 15)
				{
					EnemyShields = 15;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}All enemies receieve 6 expidonsan shields!");
				EnemyShields += 6;
			}
			case 56:
			{
				if(EnemyShields <= 0)
				{
					EnemyShields = 0;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}All enemies lose 2 expidonsan shields.");
				EnemyShields -= 2;
			}
			case 57:
			{
				if(EnemyShields <= 0)
				{
					EnemyShields = 0;
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}All enemies lose 4 expidonsan shields.");
				EnemyShields -= 4;
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
				if(VictoriaBuff)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Call to Victoria buff.");
					VictoriaBuff = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Call to Victoria buff for 10 seconds!");
					VictoriaBuff = true;
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
					strcopy(message, sizeof(message), "{red}All enemies now gain the Squad Leader buff for 20 seconds!");
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
					strcopy(message, sizeof(message), "{red}All enemies now gain the Caffinated buff for 8 seconds! {yellow}(Includes Caffinated Drain)");
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
				if(ExtraEnemySize <= 0.01) // 99% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 10%");
				ExtraEnemySize -= 0.10;
			}
			case 66:
			{
				if(ExtraEnemySize <= 0.01) // 99% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 15%");
				ExtraEnemySize -= 0.15;
			}
			case 67:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 10%");
				ExtraEnemySize += 0.10;
			}
			case 68:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 15%");
				ExtraEnemySize += 0.15;
			}
			case 69:
			{
				//10% chance, otherwise retry.
				if(GetRandomFloat(0.0, 1.0) <= 0.1)
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
			case 70:
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
			case 71:
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
			case 72:
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
			case 73:
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
			case 74:
			{
				if(AntinelNextWave)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}An ant comes out of this skull, and its approaching to the bloody gate!");
				AntinelNextWave = true;
			}
			case 75:
			{
				if(zombiecombine)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}Hey, im thinking of something.... What if, a {gold}combine, {red}and a {gold}zombie, {red}were...");
				zombiecombine = true;
			}
			case 76:
			{
				if(moremen)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}III THINK YOU NEED MORE MEN!");
				moremen = 3;
			}
			case 77:
			{
				if(immutable)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{purple}Otherworldly beings approach from a dimensional rip...");
				immutable = true;
			}
			case 78:
			{
				if(spotter || spotteralive)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{lime}Its time for the {orange}Spotter {lime}to take action!");
				spotter = 1;
			}
			case 79:
			{
				if(merlton)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Merlton buff.");
					merlton = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Merlton buff for 5 seconds!");
					merlton = true;
				}
			}
			case 80:
			{
			//	if(Sigmaller)
			//	{
					Freeplay_SetupStart();
					return;
			//	} Shit design, remove for now.
			//	strcopy(message, sizeof(message), "{red}This skull... it.. it FEELS SO SIGMA!!!!!");
			//	Sigmaller = true;
			}
			case 81:
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
			case 82:
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
			case 83:
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
			case 84:
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
			case 85:
			{
				if(LoveNahTonic)
				{
					strcopy(message, sizeof(message), "{green}Ok, that's enough Tonic...");
					LoveNahTonic = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{pink}Love is in the air? {crimson}WRONG! {red}Tonic Affliction in the enemies. {yellow}(Lasts 10s)");
					LoveNahTonic = true;
				}
			}
			case 86:
			{
				strcopy(message, sizeof(message), "{yellow}Y'know what? I'll throw in another extra skull.");
				ExtraSkulls++;
			}
			case 87:
			{
				strcopy(message, sizeof(message), "{yellow}Actually, y'know what? Maybe i'll throw in TWO extra skulls even.");
				ExtraSkulls += 2;
			}
			case 88:
			{
				strcopy(message, sizeof(message), "{red}ffffFFFFF-{crimson}FUCK {red}it, THREE EXTRA SKULLS!!!");
				ExtraSkulls += 3;
			}
			case 89:
			{
				if(Schizophrenia)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}As you pick this skull, you begin to hear voices in your head...");
				Schizophrenia = true;
			}
			case 90:
			{
				if(NormalSignaller)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Seems like a common Signaller has decided to help in training.");
				NormalSignaller = true;
			}
			case 91:
			{
				if(DarknessComing)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}THE DARKNESS IS COMING. {crimson}YOU NEED TO RUN.");
				DarknessComing = true;
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
