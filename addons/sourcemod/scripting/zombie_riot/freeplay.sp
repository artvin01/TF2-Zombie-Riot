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
static float SpeedMult;
static float MeleeMult;
static float RangedMult;
static float ExtraArmor;
static bool SuperMiniBoss;
static int ExtraSkulls;
static int SkullTimes;

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
	SpeedMult = 1.0;
	MeleeMult = 1.0;
	RangedMult = 1.0;
	ExtraArmor = 0.0;
	ExtraSkulls = 0;
	SkullTimes = 0;
	SuperMiniBoss = false;

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
	else if(SuperMiniBoss)
	{
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 3;

		switch(GetRandomInt(1, 7))
		{
			case 1: // Rogue cta doctor
			{
				enemy.Index = NPC_GetByPlugin("npc_doctor");
				enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 2: // Guln
			{
				enemy.Index = NPC_GetByPlugin("npc_fallen_warrior");
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 3: // L4D2 Tank
			{
				enemy.Index = NPC_GetByPlugin("npc_l4d2_tank");
				enemy.Health = RoundToFloor(1500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 4: // Amogus
			{
				enemy.Index = NPC_GetByPlugin("npc_omega");
				enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 5: // Panzer
			{
				enemy.Index = NPC_GetByPlugin("npc_panzer");
				enemy.Health = RoundToFloor(2500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 6: // Lucius or lucian or luciaus or whatever the name is  i forgor
			{
				enemy.Index = NPC_GetByPlugin("npc_phantom_knight");
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7: // Sawrunner
			{
				enemy.Index = NPC_GetByPlugin("npc_sawrunner");
				enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
		}
		enemy.Credits += 250.0;
		enemy.ExtraDamage *= 1.33;
		enemy.ExtraSpeed = 1.33;
		enemy.ExtraSize = 1.65; // big

		count = GetRandomInt(2, 10);
		SuperMiniBoss = false;
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
		SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") * 25);
		fl_Extra_Damage[entity] *= 15.0;
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

	if(ExtraArmor > 0.0)
		GrantEntityArmor(entity, false, 1.0, 0.5, 0, ExtraArmor);

	fl_Extra_Speed[entity] *= SpeedMult;
	fl_Extra_MeleeArmor[entity] *= MeleeMult;
	fl_Extra_RangedArmor[entity] *= RangedMult;
}

void Freeplay_OnEndWave(int &cash)
{
	cash += CashBonus;
}

void Freeplay_SetupStart(bool again)
{
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
		case 9:
		{
			if(EscapeModeForNpc)
			{
				strcopy(message, sizeof(message), "{green}Weaker enemies lose the given extra speed and damage.");
				EscapeModeForNpc = false;
			}
			else
			{
				strcopy(message, sizeof(message), "{red}Weaker enemies gain extra speed and damage.");
				EscapeModeForNpc = true;
			}
		}
		case 10:
		{
			strcopy(message, sizeof(message), "{red}A random amount of a set SUPER Miniboss will spawn in the next wave! {green}Defeating them will grant 250 extra credits each.");
			SuperMiniBoss = true;
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
			strcopy(message, sizeof(message), "{green}All enemies give +1 credits on death");
			KillBonus += 1;
		}
		case 14:
		{
			if(KillBonus < 1)
			{
				Freeplay_SetupStart(false);
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
				Freeplay_SetupStart(false);
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
				Freeplay_SetupStart(false);
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
				Freeplay_SetupStart(false);
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
				strcopy(message, sizeof(message), "{green}All enemies lose the Hussar buff!");
				HussarBuff = false;
			}
			else
			{
				strcopy(message, sizeof(message), "{red}All enemies gain the Hussar buff.");
				HussarBuff = true;
			}
		}
		case 22:
		{
			if(PernellBuff)
			{
				strcopy(message, sizeof(message), "{green}All enemies lose the Purnell buff!");
				PernellBuff = true;
			}
			else
			{
				strcopy(message, sizeof(message), "{red}All enemies gain the Purnell buff for 15 seconds.");
				PernellBuff = true;
			}
		}
		case 23:
		{
			if(PerkMachine == 1)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Juggernog, And thus gain resistance.");
			PerkMachine = 1;
		}
		case 24, 25:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Double Tap, And thus gain Extra Damage.");
			PerkMachine = 2;
		}
		case 26:
		{
			if(PerkMachine == 3)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Widows Wine, And thus gain camo.");
			PerkMachine = 3;
		}
		case 27:
		{
			if(PerkMachine == 4)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the perk Speed Cola, and thus cannot be slowed.");
			PerkMachine = 4;
		}
		case 28:
		{
			if(PerkMachine == 0)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies are now using the perk Quick Revive, this is useless and makes them lose perks.");
			PerkMachine = 0;
		}
		case 29:
		{
			if(IceDebuff > 2)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Cyro debuff");
			IceDebuff++;
		}
		case 30:
		{
			if(TeslarDebuff > 1)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies gain a layer of Teslar debuff");
			TeslarDebuff++;
		}
		case 31:
		{
			if(FusionBuff > 2)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Fusion buff");
			FusionBuff++;
		}
		case 32:
		{
			if(OceanBuff > 1)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies gain a layer of Ocean buff");
			OceanBuff++;
		}
		case 33:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies gain the Crippled debuff");
			CrippleDebuff += 300;
		}
		case 34:
		{
			strcopy(message, sizeof(message), "{red}The next enemy becomes a Stalker");
			StalkerBuff++;
		}
		case 35:
		{
			strcopy(message, sizeof(message), "{yellow}The True Fusion Warrior will appear in the next wave! {green}Defeating him will award you with 5000 credits.");
			RaidFight = 1;
		}
		case 36, 37, 38, 39:
		{
			//if(EnemyChance > 8)
			//{
			//	Freeplay_SetupStart(postWaves, wave);
			//	return;
			//}

			strcopy(message, sizeof(message), "{red}Stronger enemy types are more likely to appear");
			EnemyChance++;
		}
		case 40, 41:
		{
			if(EnemyCount < 6)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}More enemy groups can appear");
			EnemyCount++;
		}
		case 42:
		{
			if(EnemyChance < 3)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{green}Stronger enemy types are less likely to appear");
			EnemyChance--;
		}
		case 43: // is this ever used?
		{
			if(Medival_Difficulty_Level <= 0.1)
			{
				Freeplay_SetupStart(false);
				return;
			}

			strcopy(message, sizeof(message), "{red}Mediveal armour was improved");
			Medival_Difficulty_Level *= 0.9;
			if(Medival_Difficulty_Level < 0.1)
				Medival_Difficulty_Level = 0.1;
		}
		case 44:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies will gain the Cudgel debuff.");
			CudgelDebuff += 300;
		}
		case 45:
		{
			strcopy(message, sizeof(message), "{crimson}The Blitzkrieg is ready to cause mayhem in the next wave! {green}Defeating it will award you with 5000 credits.");
			RaidFight = 2;
		}
		case 46:
		{
			strcopy(message, sizeof(message), "{yellow}Silvester {white}& {darkblue}Waldch {red}are on their way to stop you on the next wave! {green}Defeating them will award you with 5000 credits.");
			RaidFight = 3;
		}
		case 47:
		{
			strcopy(message, sizeof(message), "{lightblue}God Alaxios and his army are prepared to fight you in the next wave! {green}Defeating them will award you with 5000 credits.");
			RaidFight = 4;
		}
		case 48:
		{
			float chance = GetRandomFloat(0.0, 1.0);
			if(chance > 0.9) // 10% chance for pencil
			{
				strcopy(message, sizeof(message), "{yellow}Pencil will draw his way on to victory in the next wave! {green}Defeating him will award you with 5000 credits.");
			}
			else
			{
				strcopy(message, sizeof(message), "{blue}Sensal is on his way to arrest you and your team in the next wave! {green}Defeating him will award you with 5000 credits.");
			}
			RaidFight = 5;
		}
		case 49:
		{
			strcopy(message, sizeof(message), "{aqua}Stella {white}and {crimson}Karlas {red}will arrive to render Judgement in the next wave! {green}Defeating them will award you with 5000 credits.");
			RaidFight = 6;
		}
		case 50:
		{
			strcopy(message, sizeof(message), "{crimson}The Purge has located your team and is ready for annihilation in the next wave. {green}Defeating it will award you with 5000 credits.");
			RaidFight = 7;
		}
		case 51:
		{
			strcopy(message, sizeof(message), "{lightblue}The Messenger will deliver you a deadly message next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 8;
		}
		case 52:
		{
			strcopy(message, sizeof(message), "{white}????????????? is coming... {green}Defeating it will award you with 5000 credits.");
			RaidFight = 9;
		}
		case 53:
		{
			strcopy(message, sizeof(message), "{darkblue}Chaos Kahmlstein is inviting your team to eat FISTS next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 10;
		}
		case 54:
		{
			strcopy(message, sizeof(message), "{green}Nemesis has come to spread the xeno infection on the next wave... Defeating him will award you with 5000 credits.");
			RaidFight = 11;
		}
		case 55:
		{
			strcopy(message, sizeof(message), "{green}Mr.X has come to spread the xeno infection on the next wave... Defeating him will award you with 5000 credits.");
			RaidFight = 12;
		}
		case 56:
		{
			strcopy(message, sizeof(message), "{midnightblue}Corrupted Barney is coming... {green}Defeating him will award you with 5000 credits.");
			RaidFight = 13;
		}
		case 57:
		{
			strcopy(message, sizeof(message), "{crimson}Whiteflower, the Traitor, will appear in the next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 14;
		}
		case 58:
		{
			strcopy(message, sizeof(message), "{purple}An Unspeakable entity is approaching... {green}Defeating it will award you with 5000 credits.");
			RaidFight = 15;
		}
		case 59:
		{
			strcopy(message, sizeof(message), "{purple}Vhxis, the Void Gatekeeper, will appear in the next wave. {green}Defeating it will award you with 5000 credits.");
			RaidFight = 16;
		}
		case 60:
		{
			strcopy(message, sizeof(message), "{lightblue}Nemal {white}& {yellow}Silvester {red}want to test your strength in the next wave! {green}Defeating them will award you with 5000 credits.");
			RaidFight = 17;
		}
		case 61:
		{
			strcopy(message, sizeof(message), "{purple}Twirl has heard you're strong, she wants to fight in the next wave! {green}Defeating her will award you with 5000 credits.");
			RaidFight = 18;
		}
		case 62:
		{
			strcopy(message, sizeof(message), "{community}Agent Thompson will appear in the next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 19;
		}
		case 63:
		{
			strcopy(message, sizeof(message), "{forestgreen}The Twins will appear in the next wave. {green}Defeating them will award you with 5000 credits.");
			RaidFight = 20;
		}
		case 64:
		{
			strcopy(message, sizeof(message), "{community}Agent Jackson will appear in the next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 21;
		}
		case 65:
		{
			strcopy(message, sizeof(message), "{darkgreen}Agent Smith will appear in the next wave. {green}Defeating him will award you with 5000 credits.");
			RaidFight = 22;
		}
		case 66:
		{
			strcopy(message, sizeof(message), "{red}Enemies will now move 10% faster!");
			SpeedMult += 0.1;
		}
		case 67:
		{
			strcopy(message, sizeof(message), "{red}Enemies will now move 15% faster!");
			SpeedMult += 0.15;
		}
		case 68:
		{
			if(SpeedMult < 0.35) // i'll go with a minimum of -65% movement speed since freeplay enemies move way faster than usual, and certain buffs make them faster
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{green}Enemies will now move 10% slower.");
			SpeedMult -= 0.1;
		}
		case 69:
		{
			if(SpeedMult < 0.35)
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{green}Enemies will now move 15% slower.");
			SpeedMult -= 0.15;
		}
		case 70:
		{
			strcopy(message, sizeof(message), "{green}Enemies will now take 10% more melee damage.");
			MeleeMult += 0.10;
		}
		case 71:
		{
			strcopy(message, sizeof(message), "{green}Enemies will now take 15% more melee damage.");
			MeleeMult += 0.15;
		}
		case 72:
		{
			if(MeleeMult < 0.05) // 95% melee res max
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{red}Enemies will now take 10% less melee damage.");
			MeleeMult -= 0.10;
			if(MeleeMult < 0.05)
			{
				MeleeMult = 0.05;
			}
		}
		case 73:
		{
			if(MeleeMult < 0.05)
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{red}Enemies will now take 15% less melee damage.");
			MeleeMult -= 0.15;
			if(MeleeMult < 0.05)
			{
				MeleeMult = 0.05;
			}
		}
		case 74:
		{
			strcopy(message, sizeof(message), "{green}Enemies will now take 10% more ranged damage.");
			RangedMult += 0.10;
		}
		case 75:
		{
			strcopy(message, sizeof(message), "{green}Enemies will now take 15% more ranged damage.");
			RangedMult += 0.15;
		}
		case 76:
		{
			if(RangedMult < 0.05) // 95% ranged res max
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{red}Enemies will now take 10% less ranged damage.");
			RangedMult -= 0.10;
			if(RangedMult < 0.05)
			{
				RangedMult = 0.05;
			}
		}
		case 77:
		{
			if(RangedMult < 0.05)
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{red}Enemies will now take 15% less ranged damage.");
			RangedMult -= 0.15;
			if(RangedMult < 0.05)
			{
				RangedMult = 0.05;
			}
		}
		case 78:
		{
			strcopy(message, sizeof(message), "{red}All enemies now gain 5000 extra armor, which halves their damage taken.");
			ExtraArmor += 5000.0;
		}
		case 79:
		{
			strcopy(message, sizeof(message), "{red}All enemies now gain 10000 extra armor, which halves their damage taken.");
			ExtraArmor += 10000.0;
		}
		case 80:
		{
			if(ExtraArmor < 0.0)
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{green}All enemies now have 2500 less armor.");
			ExtraArmor -= 2500.0;
			if(ExtraArmor < 0.0)
			{
				ExtraArmor = 0.0;
			}
		}
		case 81:
		{
			if(ExtraArmor < 0.0)
			{
				Freeplay_SetupStart(false);
				return;
			}
			strcopy(message, sizeof(message), "{green}All enemies now have 5000 less armor.");
			ExtraArmor -= 5000.0;
			if(ExtraArmor < 0.0)
			{
				ExtraArmor = 0.0;
			}
		}
		default:
		{
			strcopy(message, sizeof(message), "{yellow}Nothing!");
			// If this shows up, FIX YOUR CODE :)
		}
	}

	RerollTry = 0;
	CPrintToChatAll("{orange}New Skull{default}: %s", message);

	int exskull = GetRandomInt(0, 100);
	if(exskull > 90 && !again) // 10% chance
	{
		ExtraSkulls++;
		CPrintToChatAll("{yellow}ALERT!!! {orange}Setups will now contain one additional skull.");
	}

	SkullTimes = ExtraSkulls;
	if(SkullTimes < 0 && again)
	{
		SkullTimes--;
		Freeplay_SetupStart(true);
	}
}
