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
static int StalkerBuff;
static int PerkMachine;
static int RaidFight;
static bool WaveSkulls;

static int EnemySeed;

void Freeplay_ResetAll()
{
	HealthMulti = 1.0;
	HealthBonus = 0;
	EnemyChance = 2;
	EnemyCount = 5;
	EnemyBosses = 0;
	ImmuneNuke = 0;
	CashBonus = 0;
	FriendlyDay = false;
	KillBonus = 0.0;
	CountBonus = 0;
	CountMulti = 0.0;
	MiniBossChance = 0.2;
	HussarBuff = false;
	PernellBuff = false;
	IceDebuff = 0;
	TeslarDebuff = 0;
	FusionBuff = 0;
	OceanBuff = 0;
	CrippleDebuff = 0;
	StalkerBuff = 0;
	PerkMachine = 0;
	RaidFight = 0;
	WaveSkulls = false;

	EscapeModeForNpc = false;

	char buffer[64];
	EnemySeed = GetCurrentMap(buffer, sizeof(buffer)) * buffer[3];
}

int Freeplay_EnemyCount()
{
	return EnemyCount;
}

bool Freeplay_ShouldAddEnemy(int postWaves)
{
	bool result = !(EnemySeed % EnemyChance);

	if(EnemySeed > 2000000000)
	{
		EnemySeed = (EnemySeed / 20000000) + postWaves;
	}
	else
	{
		EnemySeed *= postWaves;
	}

	return result;
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
				enemy.Health = 4000000 / 70 * Waves_GetRound();
			}
			case 3:
			{
				enemy.Index = XENO_RAIDBOSS_SILVESTER;
				enemy.Health = 2500000 / 70 * Waves_GetRound();
			}
			default:
			{
				enemy.Index = RAIDMODE_TRUE_FUSION_WARRIOR;
				enemy.Health = 4000000 / 70 * Waves_GetRound();
			}
		}

		count = 1;
	}
	else if(FriendlyDay)
	{
		enemy.Friendly = true;
		count /= 10;
		FriendlyDay = false;
	}
	else
	{
		enemy.Health = RoundToCeil(HealthBonus + (enemy.Health * HealthMulti * ((postWaves + 99) * 0.01)));
		count = CountBonus + RoundToFloor(count * CountMulti * ((postWaves + 99) * 0.02));

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
	if((++RerollTry) > 3)
		rand = GetURandomInt() % 45;
	
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
			if(GrigoriMaxSells > 4)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}Father Grigori sells +1 item");
			GrigoriMaxSells++;
			Store_RandomizeNPCStore(false);
		}
		case 14:
		{
			if(GrigoriMaxSells < 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}Father Grigori sells -1 item");
			GrigoriMaxSells--;
			Store_RandomizeNPCStore(false);
		}
		case 15:
		{
			if(KillBonus > 0)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies give +1 credits on death");
			KillBonus++;
		}
		case 16:
		{
			if(KillBonus < 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies give -1 credits on death");
			KillBonus--;
		}
		case 17:
		{
			strcopy(message, sizeof(message), "{red}Mini-boss spawn rate +50%");
			MiniBossChance *= 1.5;
		}
		case 18:
		{
			strcopy(message, sizeof(message), "{green}Mini-boss spawn rate -25%");
			MiniBossChance *= 0.75;
		}
		case 19:
		{
			if(CashBonus < 100)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}-100 credits gained per round");
			CashBonus -= 100;
		}
		case 20:
		{
			strcopy(message, sizeof(message), "{green}+120 credits gained per round");
			CashBonus += 120;
		}
		case 21:
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
		case 22:
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
		case 23:
		{
			if(HussarBuff)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain the Hussar buff");
			HussarBuff = true;
		}
		case 24:
		{
			if(PernellBuff)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain the Pernell buff");
			PernellBuff = true;
		}
		case 25:
		{
			if(PerkMachine == 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Juggernog");
			PerkMachine = 1;
		}
		case 26:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Deadshot Daiquiri");
			PerkMachine = 2;
		}
		case 27:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Double Tap");
			PerkMachine = 2;
		}
		case 28:
		{
			if(PerkMachine == 3)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Widows Wine");
			PerkMachine = 3;
		}
		case 29:
		{
			if(PerkMachine == 4)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Speed Cola");
			PerkMachine = 4;
		}
		case 30:
		{
			if(PerkMachine == 0)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies are now using the perk Quick Revive");
			PerkMachine = 0;
		}
		case 31:
		{
			if(IceDebuff > 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Cyro debuff");
			IceDebuff++;
		}
		case 32:
		{
			if(TeslarDebuff > 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Teslar debuff");
			TeslarDebuff++;
		}
		case 33:
		{
			if(FusionBuff > 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Fusion buff");
			FusionBuff++;
		}
		case 34:
		{
			if(OceanBuff > 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Ocean buff");
			OceanBuff++;
		}
		case 35:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies gain Cripple debuff");
			CrippleDebuff += 300;
		}
		case 36:
		{
			strcopy(message, sizeof(message), "{red}The next enemy becomes a Stalker");
			StalkerBuff++;
		}
		case 37:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be True Fusion Warrior");
			RaidFight = 1;
		}
		case 38:
		{
			strcopy(message, sizeof(message), "{yellow}Every wave will add a new skull until setup");
			WaveSkulls = true;
		}
		case 39:
		{
			strcopy(message, sizeof(message), "{red}The freeplay wave pattern was randomized");
			EnemySeed = EnemyChance;
		}
		case 40, 41, 42:
		{
			strcopy(message, sizeof(message), "{red}Stronger enemy types are more likely to appear");
			if(EnemyChance < 7)
				EnemyChance++;
			
			EnemyCount++;
		}
		case 43:
		{
			if(EnemyChance < 3)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}Stronger enemy types are less likely to appear");
			EnemyChance--;
		}
		case 44:
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
		default:
		{
			strcopy(message, sizeof(message), "{yellow}Nothing!");
			// If this shows up, FIX YOUR CODE :)
		}
	}

	RerollTry = 0;
	CPrintToChatAll("{orange}New Skull{default}: %s", message);
}