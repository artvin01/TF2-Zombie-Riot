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
	EnemyChance = 10;
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
				enemy.Index = NPC_GetByPlugin("npc_blitzkrieg");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 3:
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_silvester");
				enemy.Health = RoundToFloor(2500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 4:
			{
				enemy.Index = NPC_GetByPlugin("npc_god_alaxios");
				enemy.Health = RoundToFloor(4500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 5:
			{
				enemy.Index = NPC_GetByPlugin("npc_sensal");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 6:	//don't know how to edit the freeplay spawn thing without being 100% sure I didn't brick anything soo commented out for now.
			{
				enemy.Index = NPC_GetByPlugin("npc_stella");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_purge");
				enemy.Health = RoundToFloor(9000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 8:	
			{
				enemy.Index = NPC_GetByPlugin("npc_the_messenger");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 9:	
			{
				enemy.Index = NPC_GetByPlugin("npc_bob_the_first_last_savior");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.65);
			}
			case 10:	
			{
				enemy.Index = NPC_GetByPlugin("npc_chaos_kahmlstein");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 11:	
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_raidboss_nemesis");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
			}
			case 12:	
			{
				enemy.Index = NPC_GetByPlugin("npc_xeno_mrx");
				enemy.Health = RoundToFloor(15000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.85);
			}
			case 13:
			{
				enemy.Index = NPC_GetByPlugin("npc_corruptedbarney");
				enemy.Health = RoundToFloor(10000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage = (f_FreeplayDamageExtra * 0.5);
			}
			case 14:
			{
				enemy.Index = NPC_GetByPlugin("npc_whiteflower_boss");
				enemy.Health = RoundToFloor(9000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 15:
			{
				enemy.Index = NPC_GetByPlugin("npc_void_unspeakable");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "forth";
			}
			case 16:
			{
				enemy.Index = NPC_GetByPlugin("npc_vhxis");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 17:
			{
				enemy.Index = NPC_GetByPlugin("npc_nemal");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "wave_60";
			}
			case 18:
			{
				enemy.Index = NPC_GetByPlugin("npc_ruina_twirl");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 19:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_thompson");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 20:
			{
				enemy.Index = NPC_GetByPlugin("npc_twins");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "Im_The_raid;My_Twin";
			}
			case 21:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_jackson");
				enemy.Health = RoundToFloor(5000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 22:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_smith");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "raid_time";
			}
			default:
			{
				enemy.Index = NPC_GetByPlugin("npc_true_fusion_warrior");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
		}
		//raids otherwise have too much damage.
		enemy.ExtraDamage *= 0.55;
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.5);
		//some raids dont scale with DMG, fix it here

		enemy.Credits += 5000.0;
		
		//money fix
		enemy.Does_Not_Scale = 1;
		count = 1;
		RaidFight = 0;
	}
	else if(FriendlyDay)
	{
		enemy.Team = TFTeam_Red;
		count /= 10;
		FriendlyDay = false;

		if(enemy.Health)
			enemy.Health /= 10;

		if(enemy.ExtraDamage)
			enemy.ExtraDamage *= 10.0;
	}
	else
	{
		if(enemy.Health)
			enemy.Health = RoundToCeil(HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.01250)));
		
		count = CountBonus + RoundToFloor(count * CountMulti * (((postWaves * 2) + 99) * 0.01250));

		if(count > 60)
			count = 60;

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
	if(HussarBuff)
		f_HussarBuff[entity] = FAR_FUTURE;
	
	if(PernellBuff)
		f_PernellBuff[entity] = GetGameTime() + 15.0;
	
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
		SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") * 50);
		fl_Extra_Damage[entity] *= 10.0;
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
			Building_CamoOrRegrowBlocker(entity, camo);
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
		rand = GetURandomInt() % 66;
	
	char message[128];
	switch(rand)
	{
		case 0:
		{
			strcopy(message, sizeof(message), "{red}All enemies have +60000 health");
			HealthBonus += 60000;
		}
		case 1:
		{
			strcopy(message, sizeof(message), "{green}Gain a random group of friendly units");
			FriendlyDay = true;
		}
		case 2:
		{
			strcopy(message, sizeof(message), "{red}All enemies have +15% health");
			HealthMulti *= 1.15;
		}
		case 3:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies have {green}-60000 health {yellow}but {red}+20% health");
			HealthBonus -= 60000;
			HealthMulti *= 1.2;
		}
		case 4:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies have {red}+60000 health {yellow}but {green}-20% health");
			HealthBonus += 60000;
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
			HealthMulti *= 0.95;
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
			HealthMulti *= 0.9;
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

			strcopy(message, sizeof(message), "{red}All enemies gain the Pernell buff for 15 seconds");
			PernellBuff = true;
		}
		case 23:
		{
			if(PerkMachine == 1)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Juggernog, And thus gain resistance.");
			PerkMachine = 1;
		}
		case 24:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Deadshot Daiquiri, And thus gain Extra Damage.");
			PerkMachine = 2;
		}
		case 25:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Double Tap, And thus gain Extra Damage.");
			PerkMachine = 2;
		}
		case 26:
		{
			if(PerkMachine == 3)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Widows Wine, And thus gain camo.");
			PerkMachine = 3;
		}
		case 27:
		{
			if(PerkMachine == 4)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Speed Cola, and thus cannot be slowed.");
			PerkMachine = 4;
		}
		case 28:
		{
			if(PerkMachine == 0)
			{
				Freeplay_SetupStart(postWaves, wave);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies are now using the perk Quick Revive, this is useless and makes them lose perks.");
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
			strcopy(message, sizeof(message), "{red}The next enemy group will be True Fusion Warrior! Killing awards 5k credits!");
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
		case 45:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Blitzkrieg Killing awards 5k credits!");
			RaidFight = 2;
		}
		case 46:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Silvester And Waldch Killing awards 5k credits!");
			RaidFight = 3;
		}
		case 47:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be God Alaxios Killing awards 5k credits!");
			RaidFight = 4;
		}
		case 48:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Sensal Killing awards 5k credits!");
			RaidFight = 5;
		}
		case 49:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Karlas and Stella! Killing awards 5k credits!");
			RaidFight = 6;
		}
		case 50:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be The Purge! Killing awards 5k credits!");
			RaidFight = 7;
		}
		case 51:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be The Messenger! Killing awards 5k credits!");
			RaidFight = 8;
		}
		case 52:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be ?????? Killing awards 5k credits!");
			RaidFight = 9;
		}
		case 53:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Chaos Kahmlstein! Killing awards 5k credits!");
			RaidFight = 10;
		}
		case 54:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Nemesis! Killing awards 5k credits!");
			RaidFight = 11;
		}
		case 55:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Mr.X! Killing awards 5k credits!");
			RaidFight = 12;
		}
		case 56:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Corrupted Barney! Killing awards 5k credits!");
			RaidFight = 13;
		}
		case 57:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Whiteflower! Killing awards 5k credits!");
			RaidFight = 14;
		}
		case 58:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Unspeakable! Killing awards 5k credits!");
			RaidFight = 15;
		}
		case 59:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Vhxis! Killing awards 5k credits!");
			RaidFight = 16;
		}
		case 60:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Nemal & Silvester! Killing awards 5k credits!");
			RaidFight = 17;
		}
		case 61:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Twirl! Killing awards 5k credits!");
			RaidFight = 18;
		}
		case 62:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Agent Thompson! Killing awards 5k credits!");
			RaidFight = 19;
		}
		case 63:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Twins! Killing awards 5k credits!");
			RaidFight = 20;
		}
		case 64:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Agent Jackson! Killing awards 5k credits!");
			RaidFight = 21;
		}
		case 65:
		{
			strcopy(message, sizeof(message), "{red}The next enemy group will be Agent Smith! Killing awards 5k credits!");
			RaidFight = 22;
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