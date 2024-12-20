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
static bool SuperMiniBoss;
static int ExtraSkulls;
static int SkullTimes;
static bool ExplodingNPC;
static int ExplodeNPCDamage;
static int EnemyShields;
static bool IsRaidWave; // to prevent the message from popping up twice
static int VoidBuff;
static bool VictoriaBuff;
static bool SquadBuff;
static bool Coffee;
static int StrangleDebuff;
static int ProsperityDebuff;
static bool SilenceDebuff;
static float ExtraEnemySize;
static bool UnlockedSpeed;

void Freeplay_OnMapStart()
{
	PrecacheSound("ui/vote_success.wav", true);
	PrecacheSound("passtime/ball_dropped.wav", true);
	PrecacheSound("ui/mm_medal_silver.wav", true);
}

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
	ExtraSkulls = 0;
	SkullTimes = 0;
	ExplodeNPCDamage = 0;
	SuperMiniBoss = false;
	ExplodingNPC = false;
	EscapeModeForNpc = false;
	IsRaidWave = false;
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
				enemy.Index = NPC_GetByPlugin("npc_agent_johnson");
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
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.4);
		//some raids dont scale with DMG, fix it here

		enemy.Credits += 5000.0;
		
		//money fix
		enemy.Does_Not_Scale = 1;
		count = 1;
		RaidFight = 0;
		IsRaidWave = false;
	}
	else if(FriendlyDay)
	{
		enemy.Team = TFTeam_Red;
		count = 15;
		FriendlyDay = false;

		if(enemy.Health)
			enemy.Health /= 5;

		if(enemy.ExtraDamage)
			enemy.ExtraDamage *= 15.0;
	}
	else if(SuperMiniBoss)
	{
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 3;

		switch(GetRandomInt(1, 7)) // All super minibosses recieve a 65% damage boost, with the exception of Omega who gets 10% after a very... unfortunate testing session
		{
			case 1: // Rogue cta doctor
			{
				enemy.Index = NPC_GetByPlugin("npc_doctor");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
			case 2: // Guln
			{
				enemy.Index = NPC_GetByPlugin("npc_fallen_warrior");
				enemy.Health = RoundToFloor(4000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
			case 3: // L4D2 Tank
			{
				enemy.Index = NPC_GetByPlugin("npc_l4d2_tank");
				enemy.Health = RoundToFloor(3500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
			case 4: // Amogus
			{
				enemy.Index = NPC_GetByPlugin("npc_omega");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.10;
			}
			case 5: // Panzer
			{
				enemy.Index = NPC_GetByPlugin("npc_panzer");
				enemy.Health = RoundToFloor(4500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
			case 6: // Lucius or lucian or luciaus or whatever the name is  i forgor
			{
				enemy.Index = NPC_GetByPlugin("npc_phantom_knight");
				enemy.Health = RoundToFloor(4000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
			case 7: // Sawrunner
			{
				enemy.Index = NPC_GetByPlugin("npc_sawrunner");
				enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 1.65;
			}
		}
		enemy.Credits += 125.0;
		enemy.ExtraSpeed = 1.45;
		enemy.ExtraSize = 1.65; // big

		count = GetRandomInt(2, 10);
		SuperMiniBoss = false;
	}
	else
	{
		if(enemy.Health)
			enemy.Health = RoundToCeil((HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.01250))) * 0.9);
		
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

	enemy.ExtraSize *= ExtraEnemySize;
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
	//// BUFFS ////

	if(HussarBuff)
		ApplyStatusEffect(entity, entity, "Hussar's Warscream", FAR_FUTURE);

	if(PernellBuff)
		ApplyStatusEffect(entity, entity, "False Therapy", 15.0);
	
	if(FusionBuff > 1)
		ApplyStatusEffect(entity, entity, "Self Empowerment", FAR_FUTURE);
	
	if(FusionBuff == 1 || FusionBuff > 2)
		ApplyStatusEffect(entity, entity, "Ally Empowerment", FAR_FUTURE);
	
	if(OceanBuff > 1)
		ApplyStatusEffect(entity, entity, "Oceanic Scream", FAR_FUTURE);
	
	if(OceanBuff > 0)
		ApplyStatusEffect(entity, entity, "Oceanic Singing", FAR_FUTURE);

	if(VoidBuff > 1)
		ApplyStatusEffect(entity, entity, "Void Strength II", 12.0);

	if(VoidBuff > 0)
		ApplyStatusEffect(entity, entity, "Void Strength I", 6.0);

	if(VictoriaBuff)
		ApplyStatusEffect(entity, entity, "Call To Victoria", 10.0);
	
	if(SquadBuff)
		ApplyStatusEffect(entity, entity, "Squad Leader", FAR_FUTURE);

	if(Coffee)
	{
		ApplyStatusEffect(entity, entity, "Caffinated", 15.0);
		ApplyStatusEffect(entity, entity, "Caffinated Drain", 15.0);
	}

	if(StalkerBuff > 0)
	{
		b_StaticNPC[entity] = true;
		SetEntProp(entity, Prop_Data, "m_iHealth", GetEntProp(entity, Prop_Data, "m_iHealth") * 25);
		fl_Extra_Damage[entity] *= 15.0;
		StalkerBuff--;
	}

	//// DEBUFFS ////

	if(SilenceDebuff)
		ApplyStatusEffect(entity, entity, "Silenced", 10.0);

	if(ProsperityDebuff > 2)
		ApplyStatusEffect(entity, entity, "Prosperity III", FAR_FUTURE);

	if(ProsperityDebuff > 1)
		ApplyStatusEffect(entity, entity, "Prosperity II", FAR_FUTURE);

	if(ProsperityDebuff > 0)
		ApplyStatusEffect(entity, entity, "Prosperity I", FAR_FUTURE);

	if(StrangleDebuff > 2)
		ApplyStatusEffect(entity, entity, "Stranglation III", FAR_FUTURE);

	if(StrangleDebuff > 1)
		ApplyStatusEffect(entity, entity, "Stranglation II", FAR_FUTURE);

	if(StrangleDebuff > 0)
		ApplyStatusEffect(entity, entity, "Stranglation I", FAR_FUTURE);

	if(IceDebuff > 2)
		ApplyStatusEffect(entity, entity, "Near Zero", FAR_FUTURE);
	
	if(IceDebuff > 1)
		ApplyStatusEffect(entity, entity, "Cryo", FAR_FUTURE);
	
	if(IceDebuff > 0)
		ApplyStatusEffect(entity, entity, "Freeze", FAR_FUTURE);
	
	if(TeslarDebuff > 1)
		ApplyStatusEffect(entity, entity, "Teslar Electricution", FAR_FUTURE);
	
	if(TeslarDebuff > 0)
		ApplyStatusEffect(entity, entity, "Teslar Shock", FAR_FUTURE);
	
	if(CrippleDebuff > 0)
	{
		ApplyStatusEffect(entity, entity, "Cripple", FAR_FUTURE);
		CrippleDebuff--;
	}
	
	if(CudgelDebuff > 0)
	{
		ApplyStatusEffect(entity, entity, "Cudgelled", FAR_FUTURE);
		CudgelDebuff--;
	}

	// OTHER //
	switch(PerkMachine)
	{
		case 1:
		{
			ApplyStatusEffect(entity, entity, "Healing Resolve", FAR_FUTURE);
		}
		case 2:
		{
			ApplyStatusEffect(entity, entity, "Healing Strength", FAR_FUTURE);
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
	fl_Extra_Speed[entity] *= SpeedMult;
	fl_Extra_MeleeArmor[entity] *= MeleeMult;
	fl_Extra_RangedArmor[entity] *= RangedMult;
	if(EnemyShields > 0)
		VausMagicaGiveShield(entity, EnemyShields);
}

void Freeplay_OnEndWave(int &cash)
{
	if(ExplodingNPC)
		ExplodingNPC = false;

	

	cash += CashBonus;
}

void Freeplay_SetupStart(bool extra = false)
{
	bool wrathofirln = false;
	if(extra)
	{
		int wrathchance = GetRandomInt(0, 100);
		if(wrathchance < 2) // 2% chance
		{
			wrathofirln = true;
		}

		if(!wrathofirln)
		{
			EmitSoundToAll("ui/vote_success.wav");
			int exskull = GetRandomInt(0, 100);

			if(exskull < 20) // 20% chance
			{
				ExtraSkulls++;
				CPrintToChatAll("{yellow}ALERT!!! {orange}An extra skull per setup has been added.");
				CPrintToChatAll("{yellow}Current skull count: {orange}%d", ExtraSkulls+1);
				EmitSoundToAll("passtime/ball_dropped.wav", _, _, _, _, 0.67);
			}

			SkullTimes = ExtraSkulls;
		}
	}

	static int RerollTry;

	int rand = 6;
	if((++RerollTry) < 12)
		rand = GetURandomInt() % 90;

	if(wrathofirln)
	{
		float randomhp1 = GetRandomInt(-60000, 60000);
		HealthBonus += randomhp1;
		if(randomhp1 > 1.0)
		{
			CPrintToChatAll("{red}+%d enemy health!", randomhp1);
		}
		else
		{
			CPrintToChatAll("{green}-%d enemy health!", randomhp1);
		}

		float randomhp2 = GetRandomFloat(0.8, 1.2);
		HealthMulti *= randomhp2;
		if(randomhp2 > 1.0)
		{
			CPrintToChatAll("{red}+%.1fx enemy health!", randomhp2);
		}
		else
		{
			CPrintToChatAll("{green}-%.1fx enemy health!", randomhp2);
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
			int randomcripple = GetRandomInt(50, 350);
			CrippleDebuff += randomcripple;
			CPrintToChatAll("{green}The next %d enemies will now gain the Crippled debuff.", randomcripple);

			int randomcudgel = GetRandomInt(50, 350);
			CudgelDebuff += randomcudgel;
			CPrintToChatAll("{green}The next %d enemies will now gain the Cudgel debuff.", randomcudgel);
		}
		else
		{
			int randomstalker = GetRandomInt(2, 4);
			StalkerBuff += randomstalker;
			CPrintToChatAll("{red}The next %d enemies will become Stalkers! {yellow}(x25 HP, x15 DMG)", randomstalker);
		}

		if(GetRandomInt(1, 2) > 1)
		{
			CPrintToChatAll("{green}All enemies now give out 1 extra credit on death.");
			KillBonus += 1;
		}
		else
		{
			if(KillBonus < 1)
			{
				CPrintToChatAll("{green}All enemies now give out 1 extra credit on death.");
				KillBonus += 1;
			}
			else
			{
				CPrintToChatAll("{red}Reduced the credit per enemy kill by 1!");
				KillBonus--;
			}
		}

		if(GetRandomInt(1, 2) > 1)
		{
			CPrintToChatAll("{green}You now gain 120 extra credits per wave.");
			CashBonus += 120;
		}
		else
		{
			if(CashBonus < 100)
			{
				CPrintToChatAll("{green}You now gain 120 extra credits per wave.");
				CashBonus += 120;
			}
			else
			{
				CPrintToChatAll("{red}Reduced extra credits gained per wave by 100!");
				CashBonus -= 100;
			}
		}

		if(GetRandomInt(1, 2) > 1)
		{
			CPrintToChatAll("{red}15% more enemies will spawn in each enemy group!");
			CountMulti *= 1.15;
		else
		{	
			CPrintToChatAll("{green}10% less enemies will spawn in each enemy group.");
			CountMulti /= 1.1;
		}
				
		CPrintToChatAll("{green}You will gain 15 random friendly units.");
		FriendlyDay = true;


		float randommini = GetRandomFloat(0.75, 1.5);
		MiniBossChance *= randommini;
		if(randommini > 1.0)
		{
			CPrintToChatAll("{red}Mini-boss spawn rate has been multiplied by %.1fx!", randommini);
		else
		{	
			CPrintToChatAll("{green}Mini-boss spawn rate has been multiplied by %.1fx.", randommini);
		}	

		// if this works i WILL kill arvin
		for (int client = 0; client < MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2)
			{
				SetDefaultHudPosition(client, 255, 135, 0, 6.0);
				ShowSyncHudText(client, SyncHud_Notifaction, "Suffer the Wrath of Irln.");
			}
		}

		CPrintToChatAll("{orange}Wrath of Irln: {yellow}(almost) {crimson}ALL SKULLS HAVE BEEN ACTIVATED. The effects are described above.");
	}
	else
	{
		char message[128];
		switch(rand)
		{
			// The way I (samuu) manage the skulls is ordering the original ones, 
			// and at the very bottom, i put on the new ones (below raid skulls)
			// So i don't later have to worry about changing every case number
	
			/// HEALTH SKULLS ///
			case 0:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 60000 more health!");
				HealthBonus += 60000;
			}
			case 1:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 15% more health!");
				HealthMulti *= 1.15;
			}
			case 2:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {green}60000 less health {yellow}but {red}20% more health.");
				HealthBonus -= 60000;
				HealthMulti *= 1.2;
			}
			case 3:
			{
				strcopy(message, sizeof(message), "{yellow}All enemies now have {red}60000 more health {yellow}but {green}20% less health.");
				HealthBonus += 60000;
				HealthMulti /= 1.2;
			}
			case 4:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 5% less health.");
				HealthMulti *= 0.95;
			}
			case 5:
			{
				strcopy(message, sizeof(message), "{green}All enemies now have 10% less health.");
				HealthMulti *= 0.9;
			}
			case 6:
			{
				strcopy(message, sizeof(message), "{red}All enemies now have 20% more health!");
				HealthMulti *= 1.2;
			}

			/// BUFF/DEBUFF SKULLS //
			case 7:
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
			case 8:
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
			case 9:
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
			case 10:
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
			case 11:
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
			case 12:
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
			case 13:
			{
				if(OceanBuff > 2)
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
			case 14:
			{
				strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Crippled debuff.");
				CrippleDebuff += 300;
			}
			case 15:
			{
				strcopy(message, sizeof(message), "{red}The next 2 enemies will become Stalkers! {yellow}(x25 HP, x15 DMG)");
				StalkerBuff += 2;
			}
			case 16:
			{
				strcopy(message, sizeof(message), "{green}The next 300 enemies will now gain the Cudgel debuff.");
				CudgelDebuff += 300;
			}
	
			/// CREDIT SKULLS //
			case 17:
			{
				strcopy(message, sizeof(message), "{green}All enemies now give out 1 extra credits on death.");
				KillBonus += 1;
			}
			case 18:
			{
				if(KillBonus < 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Reduced the credit per enemy kill by 1!");
				KillBonus--;
			}
			case 19:
			{
				if(CashBonus < 100)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Reduced extra credits gained per wave by 100!");
				CashBonus -= 100;
			}
			case 20:
			{
				strcopy(message, sizeof(message), "{green}You now gain 120 extra credits per wave.");
				CashBonus += 120;
			}
	
			/// ENEMY COUNT SKULLS ///
			case 21:
			{
				strcopy(message, sizeof(message), "{red}One extra enemy will spawn in each enemy group!");
				CountBonus++;
			}
			case 22:
			{
				strcopy(message, sizeof(message), "{red}15% more enemies will spawn in each enemy group!");
				CountMulti *= 1.15;
			}
			case 23:
			{
				strcopy(message, sizeof(message), "{green}10% less enemies will spawn in each enemy group.");
				CountMulti /= 1.1;
			}
			case 24:
			{
				strcopy(message, sizeof(message), "{green}You will gain 15 random friendly units.");
				FriendlyDay = true;
			}
			case 25:
			{
				if(EnemyCount < 6)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}Now, more enemy groups can appear!");
				EnemyCount++;
			}
	
			/// PERK SKULLS ///
			case 26:
			{
				if(PerkMachine == 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Juggernog perk, And thus gain resistance!");
				PerkMachine = 1;
			}
			case 27:
			{
				if(PerkMachine == 2)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Double Tap perk, And thus gain Extra Damage!");
				PerkMachine = 2;
			}
			case 28:
			{
				if(PerkMachine == 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Widows Wine perk, And thus gain camo! {yellow}(Allied NPCS and Sentry-a-like buildings cannot target them now.)");
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
				strcopy(message, sizeof(message), "{red}Mini-boss spawn rate has been increased by 50%!");
				MiniBossChance *= 1.5;
			}
			case 32:
			{
				strcopy(message, sizeof(message), "{green}Mini-boss spawn rate has been reduced by 25%.");
				MiniBossChance *= 0.75;
			}
			case 33:
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
			case 34:
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
			
			case 35:
			{
				//if(EnemyChance > 8)
				//{
				//	Freeplay_SetupStart();
				//	return;
				//}
	
				strcopy(message, sizeof(message), "{red}Stronger enemy types are now more likely to appear!");
				EnemyChance++;
			}
			case 36:
			{
				if(EnemyChance < 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{green}Stronger enemy types are now less likely to appear.");
				EnemyChance--;
			}
	
			/// RAID SKULLS ///
			case 37:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}The True Fusion Warrior will appear in the next wave!");
				RaidFight = 1;
			}
			case 38:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{crimson}The Blitzkrieg is ready to cause mayhem in the next wave!");
				RaidFight = 2;
			}
			case 39:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}Silvester {white}& {darkblue}Waldch {red}are on their way to stop you on the next wave!");
				RaidFight = 3;
			}
			case 40:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{lightblue}God Alaxios and his army are prepared to fight you in the next wave!");
				RaidFight = 4;
			}
			case 41:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{blue}Sensal is on his way to arrest you and your team in the next wave!");
				RaidFight = 5;
			}
			case 42:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{aqua}Stella {white}and {crimson}Karlas {red}will arrive to render Judgement in the next wave!");
				RaidFight = 6;
			}
			case 43:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{crimson}The Purge has located your team and is ready for annihilation in the next wave.");
				RaidFight = 7;
			}
			case 44:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{lightblue}The Messenger will deliver you a deadly message next wave.");
				RaidFight = 8;
			}
			case 45:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{white}????????????? is coming...");
				RaidFight = 9;
			}
			case 46:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{darkblue}Chaos Kahmlstein is inviting your team to eat FISTS next wave.");
				RaidFight = 10;
			}
			case 47:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Nemesis has come to spread the xeno infection on the next wave...");
				RaidFight = 11;
			}
			case 48:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Mr.X has come to spread the xeno infection on the next wave...");
				RaidFight = 12;
			}
			case 49:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{midnightblue}Corrupted Barney is coming...");
				RaidFight = 13;
			}
			case 50:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{crimson}Whiteflower, the Traitor, will appear in the next wave.");
				RaidFight = 14;
			}
			case 51:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{purple}An Unspeakable entity is approaching...");
				RaidFight = 15;
			}
			case 52:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{purple}Vhxis, the Void Gatekeeper, will appear in the next wave.");
				RaidFight = 16;
			}
			case 53:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{lightblue}Nemal {white}& {yellow}Silvester {red}want to test your strength in the next wave!");
				RaidFight = 17;
			}
			case 54:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{purple}Twirl has heard you're strong, she wants to fight in the next wave!");
				RaidFight = 18;
			}
			case 55:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{community}Agent Thompson will appear in the next wave.");
				RaidFight = 19;
			}
			case 56:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{forestgreen}The Twins will appear in the next wave.");
				RaidFight = 20;
			}
			case 57:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{community}Agent Jackson will appear in the next wave.");
				RaidFight = 21;
			}
			case 58:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{darkgreen}Agent Smith will appear in the next wave.");
				RaidFight = 22;
			}
	
			/// SAMU'S SKULLS (new!) ///
			case 59:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 10% faster!");
				SpeedMult += 0.1;
			}
			case 60:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 15% faster!");
				SpeedMult += 0.15;
			}
			case 61:
			{
				if(SpeedMult < 0.35) // i'll go with a minimum of -65% movement speed since freeplay enemies move way faster than usual, and certain buffs make them faster
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 10% slower.");
				SpeedMult -= 0.1;
			}
			case 62:
			{
				if(SpeedMult < 0.35)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 15% slower.");
				SpeedMult -= 0.15;
			}
			case 63:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more melee damage.");
				MeleeMult += 0.10;
			}
			case 64:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more melee damage.");
				MeleeMult += 0.15;
			}
			case 65:
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
			case 66:
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
			case 67:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more ranged damage.");
				RangedMult += 0.10;
			}
			case 68:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more ranged damage.");
				RangedMult += 0.15;
			}
			case 69:
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
			case 70:
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
			case 71:
			{
				if(SuperMiniBoss)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}A random amount of a set SUPER Miniboss will spawn in the next wave! {green}Each one grants 250 credits on death.");
				SuperMiniBoss = true;
				EmitSoundToAll("mvm/mvm_warning.wav");
			}
			case 72:
			{
				if(ExplodingNPC)
				{
					Freeplay_SetupStart();
					return;
				}
				ExplodeNPCDamage = GetRandomInt(50, 250);
				strcopy(message, sizeof(message), "{red}Now, enemies will explode on death!");
				ExplodingNPC = true;
				EmitSoundToAll("ui/mm_medal_silver.wav");
			}
			case 73:
			{
				strcopy(message, sizeof(message), "{red}All enemies receieve 3 expidonsan shields!");
				EnemyShields += 3;
			}
			case 74:
			{
				strcopy(message, sizeof(message), "{red}All enemies receieve 6 expidonsan shields!");
				EnemyShields += 6;
			}
			case 75:
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
			case 76:
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
			case 77:
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
			case 78:
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
			case 79:
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
			case 80:
			{
				if(Coffee)
				{
					strcopy(message, sizeof(message), "{green}All enemies have lost the Caffinated buff.");
					Coffee = false;
				}
				else
				{
					strcopy(message, sizeof(message), "{red}All enemies now gain the Caffinated buff for 15 seconds! {yellow}(Includes Caffinated Drain)");
					Coffee = true;
				}
			}
			case 81:
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
			case 82:
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
			case 83:
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
			case 84:
			{
				if(ExtraEnemySize <= 0.35) // 65% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 10%");
				ExtraEnemySize -= 0.10;
			}
			case 85:
			{
				if(ExtraEnemySize <= 0.35) // 65% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 15%");
				ExtraEnemySize -= 0.15;
			}
			case 86:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 10%");
				ExtraEnemySize -= 0.10;
			}
			case 87:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 10%");
				ExtraEnemySize -= 0.10;
			}
			case 88:
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
			case 89:
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
			default:
			{
				strcopy(message, sizeof(message), "{yellow}Nothing!");
				// If this shows up, FIX YOUR CODE :)
			}
		}

		RerollTry = 0;
		CPrintToChatAll("{orange}New Skull{default}: %s", message);

		if(RaidFight && !IsRaidWave)
		{
			IsRaidWave = true;
			CPrintToChatAll("{green}Winning this wave will reward you with 5000 extra credits.");
			EmitSoundToAll("mvm/mvm_used_powerup.wav", _, _, _, _, 0.67);
		}

		if(ExplodingNPC)
			CPrintToChatAll("{yellow}The exploding enemy skull lasts 1 wave. | Current Base damage: %d", ExplodeNPCDamage);
	
		if(SkullTimes > 0)
		{
			SkullTimes--;
			Freeplay_SetupStart();
		}
	}
}
