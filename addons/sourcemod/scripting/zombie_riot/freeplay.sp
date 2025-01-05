
#pragma semicolon 1
#pragma newdecls required

static float HealthMulti;
static int HealthBonus;
static int EnemyChance;
static int EnemyBosses;
static int ImmuneNuke;
static int CashBonus;
static bool FriendlyDay;
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
static bool IsExplodeWave; // to prevent the message from popping up twice
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
static bool CheesyPresence;
static int EloquenceBuff;
static int RampartBuff;
static int FreeplayBuffTimer;
static bool AntinelNextWave;

void Freeplay_OnMapStart()
{
	PrecacheSound("ui/vote_success.wav", true);
	PrecacheSound("passtime/ball_dropped.wav", true);
	PrecacheSound("ui/mm_medal_silver.wav", true);
	PrecacheSound("ambient/halloween/thunder_01.wav", true);
}

void Freeplay_ResetAll()
{
	HealthMulti = 1.0;
	HealthBonus = 0;
	EnemyChance = 10;
	EnemyBosses = 0;
	ImmuneNuke = 0;
	CashBonus = 0;
	FriendlyDay = false;
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
	IsExplodeWave = false;
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
	CheesyPresence = false;
	EloquenceBuff = 0;
	RampartBuff = 0;
	FreeplayBuffTimer = 0;
	AntinelNextWave = false;
}

int Freeplay_EnemyCount()
{
	return AntinelNextWave ? 6 : 5;
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
				enemy.Health = RoundToFloor(10000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraMeleeRes *= 4.0;
				enemy.ExtraRangedRes *= 3.0;
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
				enemy.ExtraDamage *= 0.6; // thompson gets way too much damage in freeplay, reduce it
			}
			case 22:
			{
				enemy.Index = NPC_GetByPlugin("npc_agent_smith");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.Data = "raid_time";
			}
    /*
			case 23:
			{
				enemy.Index = NPC_GetByPlugin("npc_atomizer");
				enemy.Health = RoundToFloor(5000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 24:
			{
				enemy.Index = NPC_GetByPlugin("npc_the_wall");
				enemy.Health = RoundToFloor(6000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 25:
			{
				enemy.Index = NPC_GetByPlugin("npc_harrison");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 26:	
			{
				enemy.Index = NPC_GetByPlugin("npc_castellan");
				enemy.Health = RoundToFloor(8000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
    */
			default:
			{
				enemy.Index = NPC_GetByPlugin("npc_true_fusion_warrior");
				enemy.Health = RoundToFloor(7000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
		}
		//raids otherwise have too much damage.
		enemy.ExtraDamage *= 0.75;
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.65);
		//some raids dont scale with DMG, fix it here

		enemy.Credits += 6500.0;

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
				enemy.Health = RoundToFloor(1000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 3: // L4D2 Tank
			{
				enemy.Index = NPC_GetByPlugin("npc_l4d2_tank");
				enemy.Health = RoundToFloor(1500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 4: // Amogus
			{
				enemy.Index = NPC_GetByPlugin("npc_omega");
				enemy.Health = RoundToFloor(750000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
				enemy.ExtraDamage *= 0.35;
			}
			case 5: // Panzer
			{
				enemy.Index = NPC_GetByPlugin("npc_panzer");
				enemy.Health = RoundToFloor(2000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 6: // Lucius or lucian or luciaus or whatever the name is  i forgor
			{
				enemy.Index = NPC_GetByPlugin("npc_phantom_knight");
				enemy.Health = RoundToFloor(1500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
			case 7: // Sawrunner
			{
				enemy.Index = NPC_GetByPlugin("npc_sawrunner");
				enemy.Health = RoundToFloor(1500000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
			}
		}

		// Leaving this in here in the case i have to nerf super miniboss health
		// 22/12/2024 - lesson learned, i went way too overboard
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.3);
		enemy.ExtraDamage *= 0.75;
		enemy.Credits += 125.0;
		enemy.ExtraSpeed = 1.3;
		enemy.ExtraSize = 1.75; // big
		enemy.Does_Not_Scale = 1;

		count = GetRandomInt(2, 8);
		SuperMiniBoss = false;
	}
	else if(AntinelNextWave)
	{
		// Spawns an ant-sized Sentinel that has the same health as Stella in freeplay.
		enemy.Is_Outlined = true;
		enemy.Is_Immune_To_Nuke = true;
		enemy.Is_Boss = 1;

		enemy.Index = NPC_GetByPlugin("npc_sentinel");
		enemy.Health = RoundToFloor(3000000.0 / 70.0 * float(ZR_GetWaveCount() * 2) * MultiGlobalHighHealthBoss);
		enemy.Health = RoundToCeil(float(enemy.Health) * 0.4);
		enemy.ExtraSpeed = 2.0;
		enemy.ExtraSize = 0.2; // smol
		enemy.Credits += 1.0;
		strcopy(enemy.CustomName, sizeof(enemy.CustomName), "Antinel");

		count = 1;
		AntinelNextWave = false;
	}
	else
	{
		if(enemy.Health)
		{
			// Nerfing bob the first's army health due to freeplay scaling
			// Basically the same hp formula except HealthBonus is not there
			if(StrContains(enemy.CustomName, "First ") != -1)
			{
				enemy.Health = RoundToCeil(((enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009))) * 0.7);
			}
			else
			{
				enemy.Health = RoundToCeil((HealthBonus + (enemy.Health * MultiGlobalHealth * HealthMulti * (((postWaves * 3) + 99) * 0.009))) * 0.7);
			}
		}

		count = RoundToFloor((count * (((postWaves * 2) + 99) * 0.009)) * 0.5);

		if(count > 45)
			count = 45;

		if(EnemyBosses && !((enemy.Index + 1) % EnemyBosses))
			enemy.Is_Boss = 1;

		if(ImmuneNuke && !(enemy.Index % ImmuneNuke))
			enemy.Is_Immune_To_Nuke = true;

		if(KillBonus)
			enemy.Credits += KillBonus;

		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[enemy.Index], npc_classname, sizeof(npc_classname));
		if(StrEqual(npc_classname, "npc_ruina_valiant") || StrEqual(npc_classname, "npc_majorsteam"))
			count = 1;
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
	// arvin's order
	if(!b_thisNpcIsARaid[entity])
		fl_Extra_Damage[entity] *= 2.0;

	//// BUFFS ////

	if(HussarBuff)
		ApplyStatusEffect(entity, entity, "Hussar's Warscream", 999999.0);	

	if(PernellBuff)
		ApplyStatusEffect(entity, entity, "False Therapy", 15.0);

	if(FusionBuff > 1)
		ApplyStatusEffect(entity, entity, "Self Empowerment", 999999.0);	

	if(FusionBuff == 1 || FusionBuff > 2)
		ApplyStatusEffect(entity, entity, "Ally Empowerment", 999999.0);	

	if(OceanBuff > 1)
		ApplyStatusEffect(entity, entity, "Oceanic Scream", 999999.0);	

	if(OceanBuff > 0)
		ApplyStatusEffect(entity, entity, "Oceanic Singing", 999999.0);	

	if(VoidBuff > 1)
		ApplyStatusEffect(entity, entity, "Void Strength II", 12.0);

	if(VoidBuff > 0)
		ApplyStatusEffect(entity, entity, "Void Strength I", 6.0);

	if(VictoriaBuff)
		ApplyStatusEffect(entity, entity, "Call To Victoria", 10.0);

	if(SquadBuff)
		ApplyStatusEffect(entity, entity, "Squad Leader", 999999.0);	

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
			fl_Extra_MeleeArmor[entity] *= 0.85;
			fl_Extra_RangedArmor[entity] *= 0.85;
    SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.1));
		}
		case 2:
		{
			fl_Extra_Damage[entity] *= 1.25;
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
			ApplyStatusEffect(entity, entity, "Fluid Movement", 999999.0);		
		}
	}
	fl_Extra_Speed[entity] *= SpeedMult;
	fl_Extra_MeleeArmor[entity] *= MeleeMult;
	fl_Extra_RangedArmor[entity] *= RangedMult;
	if(EnemyShields > 0)
		VausMagicaGiveShield(entity, EnemyShields);
}

static Action activatebuffs(Handle timer)
{
	if(FreeplayBuffTimer <= 0)
	{
		FreeplayBuffTimer = 1;
		CreateTimer(1.0, Freeplay_BuffTimer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
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
				ApplyStatusEffect(client, client, "Cheesy Presence", 1.25);

			switch(EloquenceBuff)
			{
				case 1:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence I", 1.25);
				}
				case 2:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence II", 1.25);
				}
				case 3:
				{
					ApplyStatusEffect(client, client, "Freeplay Eloquence III", 1.25);
				}
			}

			switch(RampartBuff)
			{
				case 1:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart I", 1.25);
				}
				case 2:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart II", 1.25);
				}
				case 3:
				{
					ApplyStatusEffect(client, client, "Freeplay Rampart III", 1.25);
				}
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == TFTeam_Red)
		{
			if(CheesyPresence)
				ApplyStatusEffect(ally, ally, "Cheesy Presence", 1.25);

			switch(EloquenceBuff)
			{
				case 1:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence I", 1.25);
				}
				case 2:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence II", 1.25);
				}
				case 3:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Eloquence III", 1.25);
				}
			}

			switch(RampartBuff)
			{
				case 1:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart I", 1.25);
				}
				case 2:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart II", 1.25);
				}
				case 3:
				{
					ApplyStatusEffect(ally, ally, "Freeplay Rampart III", 1.25);
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

void Freeplay_SetupStart(bool extra = false)
{
	bool wrathofirln = false;
	if(extra)
	{
		FreeplayBuffTimer = 0;
		CreateTimer(5.0, activatebuffs, _, TIMER_FLAG_NO_MAPCHANGE);
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
		rand = GetURandomInt() % 71;

	if(wrathofirln)
	{
		int randomhp1 = GetRandomInt(-60000, 60000);
		HealthBonus += randomhp1;
		if(randomhp1 > 0)
		{
			CPrintToChatAll("{red}Enemies now have %d more health!", randomhp1);
		}
		else
		{
			CPrintToChatAll("{green}Enemies now have %d less health.", randomhp1);
		}

		float randomhp2 = GetRandomFloat(0.8, 1.2);
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
			int randomcripple = GetRandomInt(100, 600);
			CrippleDebuff += randomcripple;
			CPrintToChatAll("{green}The next %d enemies will now gain the Crippled debuff.", randomcripple);

			int randomcudgel = GetRandomInt(100, 600);
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
			CPrintToChatAll("{green}You will gain 15 random friendly units.");
			FriendlyDay = true;
		}
		else
		{	
			CPrintToChatAll("{red}A random amount of a set SUPER Miniboss will spawn in the next wave! {green}Each one grants 250 credits on death.");
			SuperMiniBoss = true;
		}

		float randommini = GetRandomFloat(0.75, 1.5);
		MiniBossChance *= randommini;
		if(randommini > 1.0)
		{
			CPrintToChatAll("{red}Mini-boss spawn rate has been multiplied by %.2fx!", randommini);
		}
		else
		{	
			CPrintToChatAll("{green}Mini-boss spawn rate has been multiplied by %.2fx.", randommini);
		}

		float randomspeed = GetRandomFloat(0.75, 1.25);
		SpeedMult *= randomspeed;
		if(randomspeed > 1.0)
		{
			CPrintToChatAll("{red}Enemy speed has been multiplied by %.2fx!", randomspeed);
		}
		else
		{
			CPrintToChatAll("{green}Enemy speed has been multiplied by %.2fx.", randomspeed);
		}

		float randommelee = GetRandomFloat(0.75, 1.25);
		MeleeMult *= randommelee;
		if(randommelee < 1.0)
		{
			CPrintToChatAll("{red}Enemy melee vulnerability has been multiplied by %.2fx!", randommelee);
		}
		else
		{
			CPrintToChatAll("{green}Enemy melee vulnerability has been multiplied by %.2fx.", randommelee);
		}

		float randomranged = GetRandomFloat(0.75, 1.25);
		RangedMult *= randomranged;
		if(randomranged < 1.0)
		{
			CPrintToChatAll("{red}Enemy ranged vulnerability has been multiplied by %.2fx!", randomranged);
		}
		else
		{
			CPrintToChatAll("{green}Enemy ranged vulnerability has been multiplied by %.2fx.", randomranged);
		}

		int randomshield = GetRandomInt(-4, 4);
		EnemyShields += randomshield;
		if(EnemyShields > 15)
			EnemyShields = 15;

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
			CPrintToChatAll("{red}All enemies now gain the Caffinated buff for 15 seconds! {yellow}(Includes Caffinated Drain)");
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

		float randomsize = GetRandomFloat(0.75, 1.25);
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

		RaidFight = GetRandomInt(1, 26);
		switch(RaidFight)
		{
			case 1:
			{
				CPrintToChatAll("{yellow}The True Fusion Warrior will appear in the next wave!");
			}
			case 2:
			{
				CPrintToChatAll("{crimson}The Blitzkrieg is ready to cause mayhem in the next wave!");
			}
			case 3:
			{
				CPrintToChatAll("{yellow}Silvester {white}& {darkblue}Waldch {red}are on their way to stop you on the next wave!");
			}
			case 4:
			{
				CPrintToChatAll("{lightblue}God Alaxios and his army are prepared to fight you in the next wave!");
			}
			case 5:
			{
				CPrintToChatAll("{blue}Sensal is on his way to arrest you and your team in the next wave!");
			}
			case 6:
			{
				CPrintToChatAll("{aqua}Stella {white}and {crimson}Karlas {red}will arrive to render Judgement in the next wave!");
			}
			case 7:
			{
				CPrintToChatAll("{crimson}The Purge has located your team and is ready for annihilation in the next wave.");
			}
			case 8:
			{
				CPrintToChatAll("{lightblue}The Messenger will deliver you a deadly message next wave.");
			}
			case 9:
			{
				CPrintToChatAll("{white}????????????? is coming...");
			}
			case 10:
			{
				CPrintToChatAll("{darkblue}Chaos Kahmlstein is inviting your team to eat FISTS next wave.");
			}
			case 11:
			{
				CPrintToChatAll("{green}Nemesis has come to spread the xeno infection on the next wave...");
			}
			case 12:
			{
				CPrintToChatAll("{green}Mr.X has come to spread the xeno infection on the next wave...");
			}
			case 13:
			{
				CPrintToChatAll("{midnightblue}Corrupted Barney is coming...");
			}
			case 14:
			{
				CPrintToChatAll("{crimson}Whiteflower, the Traitor, will appear in the next wave.");
			}
			case 15:
			{
				CPrintToChatAll("{purple}An Unspeakable entity is approaching...");
			}
			case 16:
			{
				CPrintToChatAll("{purple}Vhxis, the Void Gatekeeper, will appear in the next wave.");
			}
			case 17:
			{
				CPrintToChatAll("{lightblue}Nemal {white}& {yellow}Silvester {red}want to test your strength in the next wave!");
			}
			case 18:
			{
				CPrintToChatAll("{purple}Twirl has heard you're strong, she wants to fight in the next wave!");
			}
			case 19:
			{
				CPrintToChatAll("{community}Agent Thompson will appear in the next wave.");
			}
			case 20:
			{
				CPrintToChatAll("{forestgreen}The Twins will appear in the next wave.");
			}
			case 21:
			{
				CPrintToChatAll("{community}Agent Jackson will appear in the next wave.");
			}
			case 22:
			{
				CPrintToChatAll("{darkgreen}Agent Smith will appear in the next wave.");
			}
    /*
			case 23:
			{
				CPrintToChatAll("{blue}The Atomizer has spotted your team, get ready next wave!");
			}
			case 24:
			{
				CPrintToChatAll("{lightblue}Huscarls is approaching to erradicate your team next wave!");
			}
			case 25:
			{
				CPrintToChatAll("{skyblue}Harrison and his fully-loaded arsenal will exterminate you next wave!");
			}
			case 26:
			{
				CPrintToChatAll("{blue}In the Name of Victoria, Castellan won't let you proceed further next wave.");
			}
    */
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
					PernellBuff = false;
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
	
			/// PERK SKULLS ///
			case 21:
			{
				if(PerkMachine == 1)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Juggernog perk, And thus gain +15% resist and +10% HP!");
				PerkMachine = 1;
			}
			case 22:
			{
				if(PerkMachine == 2)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Double Tap perk, And thus gain 25% Extra Damage!");
				PerkMachine = 2;
			}
			case 23:
			{
				if(PerkMachine == 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Widows Wine perk, And thus gain camo! {yellow}(Allies/Sentry-a-likes won't target enemies)");
				PerkMachine = 3;
			}
			case 24:
			{
				if(PerkMachine == 4)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{red}All enemies are now using the Speed Cola perk, and thus cannot be slowed!");
				PerkMachine = 4;
			}
			case 25:
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
			case 26:
			{
				if(FriendlyDay)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}You will gain 15 random friendly units.");
				FriendlyDay = true;
			}
			case 27:
			{
				strcopy(message, sizeof(message), "{red}Mini-boss spawn rate has been increased by 50%!");
				MiniBossChance *= 1.5;
			}
			case 28:
			{
				strcopy(message, sizeof(message), "{green}Mini-boss spawn rate has been reduced by 25%.");
				MiniBossChance *= 0.75;
			}
			case 29:
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
			case 30:
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
			case 31:
			{
				//if(EnemyChance > 8)
				//{
				//	Freeplay_SetupStart();
				//	return;
				//}
	
				strcopy(message, sizeof(message), "{red}Stronger enemy types are now more likely to appear!");
				EnemyChance++;
			}
			case 32:
			{
				if(EnemyChance < 3)
				{
					Freeplay_SetupStart();
					return;
				}
	
				strcopy(message, sizeof(message), "{green}Stronger enemy types are now less likely to appear.");
				EnemyChance--;
			}
	
			/// RAID SKULL ///
			case 33, 34, 35:
			{
				if(RaidFight)
				{
					Freeplay_SetupStart();
					return;
				}
				RaidFight = GetRandomInt(1, 22);

				switch(RaidFight)
				{
					case 2:
					{
						strcopy(message, sizeof(message), "{crimson}The Blitzkrieg is ready to cause mayhem in the next wave!");
					}
					case 3:
					{
						strcopy(message, sizeof(message), "{yellow}Silvester {white}& {darkblue}Waldch {red}are on their way to stop you on the next wave!");
					}
					case 4:
					{
						strcopy(message, sizeof(message), "{lightblue}God Alaxios and his army are prepared to fight you in the next wave!");
					}
					case 5:
					{
						strcopy(message, sizeof(message), "{blue}Sensal is on his way to arrest you and your team in the next wave!");
					}
					case 6:
					{
						strcopy(message, sizeof(message), "{aqua}Stella {white}and {crimson}Karlas {red}will arrive to render Judgement in the next wave!");
					}
					case 7:
					{
						strcopy(message, sizeof(message), "{crimson}The Purge has located your team and is ready for annihilation in the next wave.");
					}
					case 8:
					{
						strcopy(message, sizeof(message), "{lightblue}The Messenger will deliver you a deadly message next wave.");
					}
					case 9:
					{
						strcopy(message, sizeof(message), "{white}????????????? is coming...");
					}
					case 10:
					{
						strcopy(message, sizeof(message), "{darkblue}Chaos Kahmlstein is inviting your team to eat FISTS next wave.");
					}
					case 11:
					{
						strcopy(message, sizeof(message), "{green}Nemesis has come to spread the xeno infection on the next wave...");
					}
					case 12:
					{
						strcopy(message, sizeof(message), "{green}Mr.X has come to spread the xeno infection on the next wave...");
					}
					case 13:
					{
						strcopy(message, sizeof(message), "{midnightblue}Corrupted Barney is coming...");
					}
					case 14:
					{
						strcopy(message, sizeof(message), "{crimson}Whiteflower, the Traitor, will appear in the next wave.");
					}
					case 15:
					{
						strcopy(message, sizeof(message), "{purple}An Unspeakable entity is approaching...");
					}
					case 16:
					{
						strcopy(message, sizeof(message), "{purple}Vhxis, the Void Gatekeeper, will appear in the next wave.");
					}
					case 17:
					{
						strcopy(message, sizeof(message), "{lightblue}Nemal {white}& {yellow}Silvester {red}want to test your strength in the next wave!");
					}
					case 18:
					{
						strcopy(message, sizeof(message), "{purple}Twirl has heard you're strong, she wants to fight in the next wave!");
					}
					case 19:
					{
						strcopy(message, sizeof(message), "{community}Agent Thompson will appear in the next wave.");
					}
					case 20:
					{
						strcopy(message, sizeof(message), "{forestgreen}The Twins will appear in the next wave.");
					}
					case 21:
					{
						strcopy(message, sizeof(message), "{community}Agent Jackson will appear in the next wave.");
					}
					case 22:
					{
						strcopy(message, sizeof(message), "{darkgreen}Agent Smith will appear in the next wave.");
					}
      /*
					case 23:
					{
						strcopy(message, sizeof(message), "{blue}The Atomizer has spotted your team, get ready next wave!");
					}
					case 24:
					{
						strcopy(message, sizeof(message), "{lightblue}Huscarls is approaching to erradicate your team next wave!");
					}
					case 25:
					{
						strcopy(message, sizeof(message), "{skyblue}Harrison and his fully-loaded arsenal will exterminate you next wave!");
					}
					case 26:
					{
						strcopy(message, sizeof(message), "{blue}In the Name of Victoria, Castellan won't let you proceed further next wave.");
					}
      */
					default:
					{
						strcopy(message, sizeof(message), "{yellow}The True Fusion Warrior will appear in the next wave!");
					}
				}
			}
	
			/// SAMU'S SKULLS (new!) ///
			case 36:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 10% faster!");
				SpeedMult += 0.1;
			}
			case 37:
			{
				strcopy(message, sizeof(message), "{red}Enemies will now move 15% faster!");
				SpeedMult += 0.15;
			}
			case 38:
			{
				if(SpeedMult < 0.35) // i'll go with a minimum of -65% movement speed since freeplay enemies move way faster than usual, and certain buffs make them faster
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 10% slower.");
				SpeedMult -= 0.1;
			}
			case 39:
			{
				if(SpeedMult < 0.35)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{green}Enemies will now move 15% slower.");
				SpeedMult -= 0.15;
			}
			case 40:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more melee damage.");
				MeleeMult += 0.2;
			}
			case 41:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more melee damage.");
				MeleeMult += 0.25;
			}
			case 42:
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
			case 43:
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
			case 44:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 20% more ranged damage.");
				RangedMult += 0.20;
			}
			case 45:
			{
				strcopy(message, sizeof(message), "{green}Enemies will now take 25% more ranged damage.");
				RangedMult += 0.25;
			}
			case 46:
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
			case 47:
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
			case 48:
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
			case 49:
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
			case 50:
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
			case 51:
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
			case 52:
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
			case 53:
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
			case 54:
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
			case 55:
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
			case 56:
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
			case 57:
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
			case 58:
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
			case 59:
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
			case 60:
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
			case 61:
			{
				if(ExtraEnemySize <= 0.35) // 65% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 10%");
				ExtraEnemySize -= 0.10;
			}
			case 62:
			{
				if(ExtraEnemySize <= 0.35) // 65% less size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes reduced by 15%");
				ExtraEnemySize -= 0.15;
			}
			case 63:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 10%");
				ExtraEnemySize += 0.10;
			}
			case 64:
			{
				if(ExtraEnemySize >= 4.0) // 300% more size max
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{yellow}All enemies now have their sizes increased by 15%");
				ExtraEnemySize += 0.15;
			}
			case 65:
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
				if(AntinelNextWave)
				{
					Freeplay_SetupStart();
					return;
				}
				strcopy(message, sizeof(message), "{red}An ant comes out of this skull, and its approaching to the bloody gate!");
				AntinelNextWave = true;
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
			CPrintToChatAll("{green}Winning this wave will reward you with 6500 extra credits.");
			EmitSoundToAll("mvm/mvm_used_powerup.wav", _, _, _, _, 0.67);
		}

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
