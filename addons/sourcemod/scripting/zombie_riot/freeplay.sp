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
static bool ExplodingNPC;
static int ExplodeNPCDamage;

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
	ExplodeNPCDamage = 0;
	SuperMiniBoss = false;
	ExplodingNPC = false;
	EscapeModeForNpc = false;
}

int Freeplay_EnemyCount()
{
	return EnemyCount;
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
		count = 15;
		FriendlyDay = false;

		if(enemy.Health)
			enemy.Health /= 10;

		if(enemy.ExtraDamage)
			enemy.ExtraDamage *= 15.0;
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
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 2: // Guln
			{
				enemy.Index = NPC_GetByPlugin("npc_fallen_warrior");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 3: // L4D2 Tank
			{
				enemy.Index = NPC_GetByPlugin("npc_l4d2_tank");
				enemy.Health = RoundToFloor(2500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 4: // Amogus
			{
				enemy.Index = NPC_GetByPlugin("npc_omega");
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 5: // Panzer
			{
				enemy.Index = NPC_GetByPlugin("npc_panzer");
				enemy.Health = RoundToFloor(3500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 6: // Lucius or lucian or luciaus or whatever the name is  i forgor
			{
				enemy.Index = NPC_GetByPlugin("npc_phantom_knight");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7: // Sawrunner
			{
				enemy.Index = NPC_GetByPlugin("npc_sawrunner");
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
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
	if(ExplodingNPC)
		ExplodingNPC = false;

	cash += CashBonus;
}

void Freeplay_SetupStart(bool extra = false)
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
			strcopy(message, sizeof(message), "{red}All enemies now have 60000 more health!");
			HealthBonus += 60000;
		}
		case 1:
		{
			strcopy(message, sizeof(message), "{green}You will gain 15 random friendly units.");
			FriendlyDay = true;
		}
		case 2:
		{
			strcopy(message, sizeof(message), "{red}All enemies now have 15% more health!");
			HealthMulti *= 1.15;
		}
		case 3:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies now have {green}60000 less health {yellow}but {red}20% more health.");
			HealthBonus -= 60000;
			HealthMulti *= 1.2;
		}
		case 4:
		{
			strcopy(message, sizeof(message), "{yellow}All enemies now have {red}60000 more health {yellow}but {green}20% less health.");
			HealthBonus += 60000;
			HealthMulti /= 1.2;
		}
		case 5:
		{
			strcopy(message, sizeof(message), "{red}One extra enemy will spawn in each enemy group!");
			CountBonus++;
		}
		case 6:
		{
			strcopy(message, sizeof(message), "{red}15% more enemies will spawn in each enemy group!");
			CountMulti *= 1.15;
		}
		case 7:
		{
			strcopy(message, sizeof(message), "{green}10% less enemies will spawn in each enemy group.");
			CountMulti /= 1.1;
		}
		case 8:
		{
			strcopy(message, sizeof(message), "{green}All enemies now have 5% less health.");
			HealthMulti *= 0.95;
		}
		case 9, 10:
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
			strcopy(message, sizeof(message), "{green}All enemies now have 10% more health!");
			HealthMulti *= 0.9;
		}
		case 12:
		{
			strcopy(message, sizeof(message), "{red}All enemies now have 20% more health!");
			HealthMulti *= 1.2;
		}
		case 13:
		{
			strcopy(message, sizeof(message), "{green}All enemies now give out 1 extra credits on death.");
			KillBonus += 1;
		}
		case 14:
		{
			if(KillBonus < 1)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}Reduced the credit per enemy kill by 1!");
			KillBonus--;
		}
		case 15:
		{
			strcopy(message, sizeof(message), "{red}Mini-boss spawn rate has been increased by 50%!");
			MiniBossChance *= 1.5;
		}
		case 16:
		{
			strcopy(message, sizeof(message), "{green}Mini-boss spawn rate has been reduced by 25%.");
			MiniBossChance *= 0.75;
		}
		case 17:
		{
			if(CashBonus < 100)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}Reduced extra credits gained per wave by 100!");
			CashBonus -= 100;
		}
		case 18:
		{
			strcopy(message, sizeof(message), "{green}You now gain 120 extra credits per wave.");
			CashBonus += 120;
		}
		case 19:
		{
			if(EnemyBosses == 1)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}Some enemy types now gain boss resistances!");
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
		case 21:
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
		case 22:
		{
			if(PernellBuff)
			{
				strcopy(message, sizeof(message), "{green}All enemies have lost the Purnell buff.");
				PernellBuff = true;
			}
			else
			{
				strcopy(message, sizeof(message), "{red}All enemies now gain the Purnell buff for 15 seconds!");
				PernellBuff = true;
			}
		}
		case 23:
		{
			if(PerkMachine == 1)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the Juggernog perk, And thus gain resistance!");
			PerkMachine = 1;
		}
		case 24, 25:
		{
			if(PerkMachine == 2)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the Double Tap perk, And thus gain Extra Damage!");
			PerkMachine = 2;
		}
		case 26:
		{
			if(PerkMachine == 3)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the Widows Wine perk, And thus gain camo! {yellow}(Allied NPCS and Sentry-a-like buildings cannot target them now.)");
			PerkMachine = 3;
		}
		case 27:
		{
			if(PerkMachine == 4)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies are now using the Speed Cola perk, and thus cannot be slowed!");
			PerkMachine = 4;
		}
		case 28:
		{
			if(PerkMachine == 0)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies are now using the Quick Revive perk, this is useless and removes their previous perk.");
			PerkMachine = 0;
		}
		case 29:
		{
			if(IceDebuff > 2)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies now gain a layer of Cyro debuff.");
			IceDebuff++;
		}
		case 30:
		{
			if(TeslarDebuff > 1)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{green}All enemies now gain a layer of Teslar debuff.");
			TeslarDebuff++;
		}
		case 31:
		{
			if(FusionBuff > 2)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Fusion buff!");
			FusionBuff++;
		}
		case 32:
		{
			if(OceanBuff > 1)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}All enemies now gain a layer of Ocean buff!");
			OceanBuff++;
		}
		case 33:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Crippled debuff.");
			CrippleDebuff += 300;
		}
		case 34:
		{
			strcopy(message, sizeof(message), "{red}The next enemy will become a Stalker! {yellow}(x25 HP, x15 DMG)");
			StalkerBuff++;
		}
		case 35, 36, 37, 38:
		{
			//if(EnemyChance > 8)
			//{
			//	Freeplay_SetupStart();
			//	return;
			//}

			strcopy(message, sizeof(message), "{red}Stronger enemy types are now more likely to appear!");
			EnemyChance++;
		}
		case 39, 40, 41:
		{
			if(EnemyCount < 6)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{red}Now, more enemy groups can appear!");
			EnemyCount++;
		}
		case 42:
		{
			if(EnemyChance < 3)
			{
				Freeplay_SetupStart();
				return;
			}

			strcopy(message, sizeof(message), "{green}Stronger enemy types are now less likely to appear.");
			EnemyChance--;
		}
		case 43:
		{
			strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Cudgel debuff.");
			CudgelDebuff += 300;
		}
		case 44:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{yellow}The True Fusion Warrior will appear in the next wave!");
			RaidFight = 1;
		}
		case 45:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{crimson}The Blitzkrieg is ready to cause mayhem in the next wave!");
			RaidFight = 2;
		}
		case 46:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{yellow}Silvester {white}& {darkblue}Waldch {red}are on their way to stop you on the next wave!");
			RaidFight = 3;
		}
		case 47:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{lightblue}God Alaxios and his army are prepared to fight you in the next wave!");
			RaidFight = 4;
		}
		case 48:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			int chance = GetRandomInt(0, 100);
			if(chance < 10) // 10% chance for pencil
			{
				strcopy(message, sizeof(message), "{yellow}Pencil will draw his way on to victory in the next wave!");
			}
			else
			{
				strcopy(message, sizeof(message), "{blue}Sensal is on his way to arrest you and your team in the next wave!");
			}
			RaidFight = 5;
		}
		case 49:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{aqua}Stella {white}and {crimson}Karlas {red}will arrive to render Judgement in the next wave!");
			RaidFight = 6;
		}
		case 50:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{crimson}The Purge has located your team and is ready for annihilation in the next wave.");
			RaidFight = 7;
		}
		case 51:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{lightblue}The Messenger will deliver you a deadly message next wave.");
			RaidFight = 8;
		}
		case 52:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{white}????????????? is coming...");
			RaidFight = 9;
		}
		case 53:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{darkblue}Chaos Kahmlstein is inviting your team to eat FISTS next wave.");
			RaidFight = 10;
		}
		case 54:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{green}Nemesis has come to spread the xeno infection on the next wave...");
			RaidFight = 11;
		}
		case 55:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{green}Mr.X has come to spread the xeno infection on the next wave...");
			RaidFight = 12;
		}
		case 56:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{midnightblue}Corrupted Barney is coming...");
			RaidFight = 13;
		}
		case 57:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{crimson}Whiteflower, the Traitor, will appear in the next wave.");
			RaidFight = 14;
		}
		case 58:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{purple}An Unspeakable entity is approaching...");
			RaidFight = 15;
		}
		case 59:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{purple}Vhxis, the Void Gatekeeper, will appear in the next wave.");
			RaidFight = 16;
		}
		case 60:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{lightblue}Nemal {white}& {yellow}Silvester {red}want to test your strength in the next wave!");
			RaidFight = 17;
		}
		case 61:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{purple}Twirl has heard you're strong, she wants to fight in the next wave!");
			RaidFight = 18;
		}
		case 62:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{community}Agent Thompson will appear in the next wave.");
			RaidFight = 19;
		}
		case 63:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{forestgreen}The Twins will appear in the next wave.");
			RaidFight = 20;
		}
		case 64:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{community}Agent Jackson will appear in the next wave.");
			RaidFight = 21;
		}
		case 65:
		{
			if(RaidFight)
			{
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{darkgreen}Agent Smith will appear in the next wave.");
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
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{green}Enemies will now move 10% slower.");
			SpeedMult -= 0.1;
		}
		case 69:
		{
			if(SpeedMult < 0.35)
			{
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
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
				Freeplay_SetupStart();
				return;
			}
			strcopy(message, sizeof(message), "{green}All enemies now have 5000 less armor.");
			ExtraArmor -= 5000.0;
			if(ExtraArmor < 0.0)
			{
				ExtraArmor = 0.0;
			}
		}
		case 82:
		{
			if(SuperMiniBoss)
			{
				Freeplay_SetupStart);
				return;
			}
			strcopy(message, sizeof(message), "{red}A random amount of a set SUPER Miniboss will spawn in the next wave! {green}Each one grants 250 credits on death.");
			SuperMiniBoss = true;
		}
		case 83:
		{
			if(ExplodingNPC)
			{
				Freeplay_SetupStart);
				return;
			}
			ExplodeNPCDamage = GetRandomInt(35, 175)
			strcopy(message, sizeof(message), "{red}Now, enemies will explode on death, dealing %d base damage in a short radius!", ExplodeNPCDamage);
			ExplodingNPC = true;
		}
		default:
		{
			strcopy(message, sizeof(message), "{yellow}Nothing!");
			// If this shows up, FIX YOUR CODE :)
		}
	}

	RerollTry = 0;
	CPrintToChatAll("{orange}New Skull{default}: %s", message);

	if(RaidFight)
		CPrintToChatAll("{green}Winning this wave will reward you with 5000 extra credits.");

	if(ExplodingNPC)
		CPrintToChatAll("{yellow}The explosive enemies skull lasts till next wave.");

	if(extra)
	{
		int exskull = GetRandomInt(0, 100);
		if(exskull < 10) // 10% chance
		{
			ExtraSkulls++;
			CPrintToChatAll("{yellow}ALERT!!! {orange}Setups will now contain one additional skull."); 
		}

		SkullTimes = ExtraSkulls;
		if(SkullTimes > 0)
		{
			SkullTimes--;
			Freeplay_SetupStart();
		}
	}
}
