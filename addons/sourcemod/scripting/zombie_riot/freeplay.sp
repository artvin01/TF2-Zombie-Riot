#pragma semicolon 1
#pragma newdecls required

static float HealthMulti;
static int HealthBonus;
static int EnemyChance;
static int EnemyCount;
static int EnemyBosses;
static int ImmuneNuke;
static int CashBonus;
static bool FriendlyDay;
static float KillBonus;
static int CountBonus;
static float CountMulti;
static float MiniBossChance;
static bool HussarBuff;
static bool PernellBuff;
static int IceDebuff;
static int TeslarDebuff;
static int FusionBuff;
static int OceanBuff;
static int CrippleDebuff;
static int CudgelDebuff;
static int StalkerBuff;
static int PerkMachine;
static int RaidFight;
static bool WaveSkulls;

void Freeplay_ResetAll()
{
	HealthMulti = 1.0;
	HealthBonus = 0;
	EnemyChance = 5;
	EnemyCount = 5;
	EnemyBosses = 0;
	ImmuneNuke = 0;
	CashBonus = 0;
	FriendlyDay = false;
	KillBonus = 0.0;
	CountBonus = 0;
	CountMulti = 1.0;
	MiniBossChance = 0.2;
	HussarBuff = false;
	PernellBuff = false;
	IceDebuff = 0;
	TeslarDebuff = 0;
	FusionBuff = 0;
	OceanBuff = 0;
	CrippleDebuff = 0;
	CudgelDebuff = 0;
	StalkerBuff = 0;
	PerkMachine = 0;
	RaidFight = 0;
	WaveSkulls = false;

	EscapeModeForNpc = false;
}

int Freeplay_EnemyCount()
{
	return EnemyCount;
}

bool Freeplay_ShouldAddEnemy()
{
	return !(GetURandomInt() % EnemyChance);
}

void Freeplay_AddEnemy(int postWaves, Enemy enemy, int &count)
{
	if(RaidFight)
	{
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 2;

		switch(RaidFight)
		{
			case 2:
			{
				enemy.Index = RAIDMODE_BLITZKRIEG;
				enemy.Health = RoundToFloor(4000000.0 / 70.0 * float(Waves_GetRound()) * MultiGlobal);
			}
			case 3:
			{
				enemy.Index = XENO_RAIDBOSS_SILVESTER;
				enemy.Health = RoundToFloor(2500000.0 / 70.0 * float(Waves_GetRound()) * MultiGlobal);
			}
			default:
			{
				enemy.Index = RAIDMODE_TRUE_FUSION_WARRIOR;
				enemy.Health = RoundToFloor(4000000.0 / 70.0 * float(Waves_GetRound()) * MultiGlobal);
			}
		}

		count = 1;
		RaidFight = 0;
	}
	else if(FriendlyDay)
	{
		enemy.Friendly = true;
		count /= 10;
		FriendlyDay = false;
	}
	else
	{
		if(enemy.Health)
			enemy.Health = RoundToCeil(HealthBonus + (enemy.Health * MultiGlobal * HealthMulti * ((postWaves + 99) * 0.0125)));
		
		count = CountBonus + RoundToFloor(count * CountMulti * ((postWaves + 99) * 0.01));

		if(EnemyBosses && !((enemy.Index + 1) % EnemyBosses))
			enemy.Is_Boss = 1;
		
		if(ImmuneNuke && !(enemy.Index % ImmuneNuke))
			enemy.Is_Immune_To_Nuke = true;
		
		if(KillBonus)
			enemy.Credits += KillBonus;
	}

	if(count < 1)
		count = 1;
}

bool Freeplay_ShouldMiniBoss()
{
	return (MiniBossChance > GetURandomFloat());
}

void Freeplay_SpawnEnemy(int entity)
{
	if(HussarBuff)
		f_HussarBuff[entity] = FAR_FUTURE;
	
	if(PernellBuff)
		b_PernellBuff[entity] = true;
	
	if(IceDebuff > 2)
		f_HighIceDebuff[entity] = FAR_FUTURE;
	
	if(IceDebuff > 1)
		f_LowIceDebuff[entity] = FAR_FUTURE;
	
	if(IceDebuff > 0)
		f_VeryLowIceDebuff[entity] = FAR_FUTURE;
	
	if(TeslarDebuff > 1)
		f_HighTeslarDebuff[entity] = FAR_FUTURE;
	
	if(TeslarDebuff > 0)
		f_LowTeslarDebuff[entity] = FAR_FUTURE;
	
	if(FusionBuff > 1)
		f_EmpowerStateSelf[entity] = FAR_FUTURE;
	
	if(FusionBuff == 1 || FusionBuff > 2)
		f_EmpowerStateOther[entity] = FAR_FUTURE;
	
	if(OceanBuff > 1)
		f_Ocean_Buff_Stronk_Buff[entity] = FAR_FUTURE;
	
	if(OceanBuff > 0)
		f_Ocean_Buff_Weak_Buff[entity] = FAR_FUTURE;
	
	if(CrippleDebuff > 0)
	{
		f_CrippleDebuff[entity] = FAR_FUTURE;
		CrippleDebuff--;
	}
	
	if(CudgelDebuff > 0)
	{
		f_CudgelDebuff[entity] = FAR_FUTURE;
		CudgelDebuff--;
	}

	if(StalkerBuff > 0)
	{
		b_StaticNPC[entity] = true;
		SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") * 30);
		StalkerBuff--;
	}

	switch(PerkMachine)
	{
		case 1:
		{
			Resistance_Overall_Low[entity] = FAR_FUTURE;
		}
		case 2:
		{
			Increaced_Overall_damage_Low[entity] = FAR_FUTURE;
		}
		case 3:
		{
			bool camo = true;
			Building_CamoOrRegrowBlocker(camo, camo);
			if(camo)
			{
				b_IsCamoNPC[entity] = true;
			}
		}
		case 4:
		{
			b_CannotBeSlowed[entity] = true;
		}
	}
}

void Freeplay_OnEndWave(int postWaves, int &cash)
{
	if(WaveSkulls)
		Freeplay_SetupStart(postWaves, true);
	
	cash += CashBonus;
}

void Freeplay_SetupStart(int postWaves, bool wave = false)
{
	if(WaveSkulls && !wave)
	{
		WaveSkulls = false;
		return;
	}

	static int RerollTry;

	int rand = 6;
	if((++RerollTry) < 4)
		rand = GetURandomInt() % 44;
	
	char message[128];
	switch(rand)
	{
		case 0:
		{
			strcopy(message, sizeof(message), "{red}All enemies have +3000 health");
			HealthBonus += 3000;
		}
		case 1:
		{
			strcopy(message, sizeof(message), "{green}Gain a random group of friendly units");
			FriendlyDay = true;
		}
		case 2:
		{
			strcopy(message, sizeof(message), "{red}All enemies have +10% health");
			HealthMulti *= 1.1;
		}
		case 3:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies have {green}-6000 health {yellow}but {red}+20% health");
			HealthBonus -= 6000;
			HealthMulti *= 1.2;
		}
		case 4:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies have {red}+6000 health {yellow}but {green}-20% health");
			HealthBonus += 6000;
			HealthMulti /= 1.2;
		}
		case 5:
		{
			strcopy(message, sizeof(message), "{red}One extra enemy will spawn in each enemy group");
			CountBonus++;
		}
		case 6:
		{
			strcopy(message, sizeof(message), "{red}15% more enemies will spawn in each enemy group");
			CountMulti *= 1.15;
		}
		case 7:
		{
			strcopy(message, sizeof(message), "{green}10% less enemies will spawn in each enemy group");
			CountMulti /= 1.1;
		}
		case 8:
		{
			strcopy(message, sizeof(message), "{green}All enemies have -5% health");
			HealthMulti /= 0.95;
		}
		case 9, 10:
		{
			if(EscapeModeForNpc)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}Weaker enemies gain extra speed and damage");
			EscapeModeForNpc = true;
		}
		case 11:
		{
			strcopy(message, sizeof(message), "{green}All enemies have -10% health");
			HealthMulti /= 0.9;
		}
		case 12:
		{
			strcopy(message, sizeof(message), "{red}All enemies have +20% health");
			HealthMulti *= 1.2;
		}
		case 13:
		{
			if(KillBonus > 0)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies give +1 credits on death");
			KillBonus++;
		}
		case 14:
		{
			if(KillBonus < 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies give -1 credits on death");
			KillBonus--;
		}
		case 15:
		{
			strcopy(message, sizeof(message), "{red}Mini-boss spawn rate +50%");
			MiniBossChance *= 1.5;
		}
		case 16:
		{
			strcopy(message, sizeof(message), "{green}Mini-boss spawn rate -25%");
			MiniBossChance *= 0.75;
		}
		case 17:
		{
			if(CashBonus < 100)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}-100 credits gained per round");
			CashBonus -= 100;
		}
		case 18:
		{
			strcopy(message, sizeof(message), "{green}+120 credits gained per round");
			CashBonus += 120;
		}
		case 19:
		{
			if(EnemyBosses == 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}Some enemy types gain boss resistances");
			if(EnemyBosses)
			{
				EnemyBosses--;
			}
			else
			{
				EnemyBosses = 6;
			}
		}
		case 20:
		{
			if(ImmuneNuke == 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}Some enemy types are immune to the Nuke Powerup");
			if(ImmuneNuke)
			{
				ImmuneNuke--;
			}
			else
			{
				ImmuneNuke = 4;
			}
		}
		case 21:
		{
			if(HussarBuff)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain the Hussar buff");
			HussarBuff = true;
		}
		case 22:
		{
			if(PernellBuff)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain the Pernell buff");
			PernellBuff = true;
		}
		case 23:
		{
			if(PerkMachine == 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Juggernog");
			PerkMachine = 1;
		}
		case 24:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Deadshot Daiquiri");
			PerkMachine = 2;
		}
		case 25:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Double Tap");
			PerkMachine = 2;
		}
		case 26:
		{
			if(PerkMachine == 3)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Widows Wine");
			PerkMachine = 3;
		}
		case 27:
		{
			if(PerkMachine == 4)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Speed Cola");
			PerkMachine = 4;
		}
		case 28:
		{
			if(PerkMachine == 0)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies are now using the perk Quick Revive");
			PerkMachine = 0;
		}
		case 29:
		{
			if(IceDebuff > 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Cyro debuff");
			IceDebuff++;
		}
		case 30:
		{
			if(TeslarDebuff > 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Teslar debuff");
			TeslarDebuff++;
		}
		case 31:
		{
			if(FusionBuff > 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Fusion buff");
			FusionBuff++;
		}
		case 32:
		{
			if(OceanBuff > 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Ocean buff");
			OceanBuff++;
		}
		case 33:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies gain Cripple debuff");
			CrippleDebuff += 300;
		}
		case 34:
		{
			strcopy(message, sizeof(message), "{red}The next enemy becomes a Stalker");
			StalkerBuff++;
		}
		case 35:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be True Fusion Warrior");
			RaidFight = 1;
		}
		case 36:
		{
			strcopy(message, sizeof(message), "{yellow}Every wave will add a new skull until setup");
			WaveSkulls = true;
		}
		case 37, 38, 39, 40:
		{
			//if(EnemyChance > 8)
			//{
			//	Freeplay_SetupStart(postWaves, wave);
			//	return;
			//}

			strcopy(message, sizeof(message), "{red}Stronger enemy types are more likely to appear");
			EnemyChance++;
		}
		case 41:
		{
			if(EnemyCount < 6)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}More enemy groups can appear");
			EnemyCount++;
		}
		case 42:
		{
			if(EnemyChance < 3)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}Stronger enemy types are less likely to appear");
			EnemyChance--;
		}
		case 43:
		{
			if(Medival_Difficulty_Level <= 0.1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}Mediveal armour was improved");
			Medival_Difficulty_Level *= 0.9;
			if(Medival_Difficulty_Level < 0.1)
				Medival_Difficulty_Level = 0.1;
		}
		case 44:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies gain Cudgel debuff");
			CudgelDebuff += 300;
		}
		default:
		{
			strcopy(message, sizeof(message), "{yellow}Nothing!");
			// If this shows up, FIX YOUR CODE :)
		}
	}

	RerollTry = 0;
	CPrintToChatAll("{orange}New Skull{default}: %s", message);
}