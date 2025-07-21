static bool HeavyWind;
#pragma semicolon 1
#pragma newdecls required

static bool ExtremeHeat;
static bool RedMoon;
static bool StartEasyMode;
static bool StartLastman;
static bool ForceNextHunter;

static Handle FrostTimer;
static Handle AnxietyTimer;
static ArrayList WinterTheme;

public float Rogue_Encounter_ForcedHunterBattle()
{
	ForceNextHunter = true;
	Rogue_SetBattleIngots(4 + (Rogue_GetFloor() / 2));
	return 0.0;
}


bool Rogue_Paradox_IgnoreOdds()
{
	if(ForceNextHunter)
	{
		ForceNextHunter = false;
		return true;
	}

	return false;
}

bool Rogue_Paradox_ExtremeHeat()
{
	return ExtremeHeat;
}

bool Rogue_Paradox_RedMoon()
{
	return RedMoon;
}

void Rogue_Paradox_MapStart()
{
	delete WinterTheme;
}

void Rogue_Paradox_AddChaos(int &change)
{
	if(StartEasyMode)
		change /= 4;
}

bool Rogue_Paradox_Lastman()
{
	return StartLastman;
}

void Rogue_Paradox_OnNewFloor(int floor)
{
	if(/*StartCamping && */floor < 3)
		Rogue_AddExtraStage(1);
}

void Rogue_Paradox_AddWinterNPC(int id)
{
	if(!WinterTheme)
		WinterTheme = new ArrayList();
	
	WinterTheme.Push(id);
}

void Rogue_Paradox_SpawnCooldown(float &time)
{
	if(ExtremeHeat)
	{
		float gameTime = GetGameTime();
		float cooldown = time - gameTime;
		cooldown *= 3.0;
		time = gameTime + cooldown;
	}
}

void Rogue_Paradox_ReviveSpeed(int &amount)
{
	if(ExtremeHeat)
		amount = RoundToNearest(float(amount) * 1.25);
}

bool Rogue_Paradox_GrigoriBlessing(int client)
{
	if(FrostTimer && dieingstate[client] == 0)
	{
		int health = GetClientHealth(client);
		if(health > 1)
		{
			int maxhealth = SDKCall_GetMaxHealth(client);

			// Degen if no blessing or above 50% health
			if(Grigori_Blessing[client] != 1 || (health > maxhealth / 2))
			{
				int damage = maxhealth / -400;
				health += damage;
				if(health < 1)
				{
					damage = 1 - health;
					health = 1;
				}
				SetEntityHealth(client, health);
			}
		}

		return true;	// Override Grigori Blessing
	}

	return false;
}

void Rogue_Paradox_ProjectileSpeed(int owner, float &speed)
{
	if(HeavyWind && !b_NpcHasDied[owner])	// NPCs
	{
		NPCData data;
		NPC_GetById(i_NpcInternalId[owner], data);
		speed *= data.Category == Type_Expidonsa ? 1.25 : 0.67;
	}
}

public void Rogue_CompassMap_Collect()
{
	StartEasyMode = true;
}

public void Rogue_CompassMap_Enemy(int entity)
{
	fl_Extra_Speed[entity] *= 0.8;
	fl_Extra_MeleeArmor[entity] *= 1.35;
	fl_Extra_RangedArmor[entity] *= 1.35;
	fl_Extra_Damage[entity] *= 0.65;
}
public void Construction_VoidStart_EnemySpawn(int entity)
{
	fl_Extra_Damage[entity] *= 1.15;
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 1.1));
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.1));
}

public void Rogue_CompassMap_Remove()
{
	StartEasyMode = false;
}

public void Rogue_Lastman_Collect()
{
	StartLastman = true;
}

public void Rogue_Lastman_Remove()
{
	StartLastman = false;
}

public void Rogue_Trading_Collect()
{
	Rogue_AddIngots(20, true);
}

public void Rogue_Weapon_Collect()
{
	GlobalExtraCash += 250;
	CurrentCash += 250;

	Ammo_Count_Ready += 30;
}

public void Rogue_SomethingElse_Enemy(int entity)
{
	int stats = Rogue_GetFloor() + (Rogue_GetChaos() / 5);
	float multi = 1.0 + (stats * 0.01);
	
	fl_Extra_Damage[entity] *= multi;
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * multi));
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * multi));
}

public void Rogue_SomethingElse_Collect()
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_bob_first_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}
}

public void Rogue_HeavyWind_Weapon(int entity)
{
	if(Attributes_Has(entity, 103))
		Attributes_SetMulti(entity, 103, 0.67);
}

public void Rogue_HeavyRain_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		bool seaborn;
		int i, weapon;
		while(TF2_GetItem(entity, weapon, i))
		{
			switch(i_CustomWeaponEquipLogic[weapon])
			{
				case WEAPON_OCEAN, WEAPON_OCEAN_PAP, WEAPON_SPECTER, WEAPON_GLADIIA, WEAPON_ULPIANUS, WEAPON_SEABORNMELEE, WEAPON_SKADI:
				{
					seaborn = true;
					break;
				}
			}
		}

		float value;

		// -20% move speed
		map.GetValue("442", value);
		map.SetValue("442", value * (seaborn ? 1.1 : 0.8));
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		BarrackBody npc = view_as<BarrackBody>(entity);
		if(npc.OwnerUserId)	// Barracks Unit
		{
			fl_Extra_Speed[entity] *= 0.8;
		}
	}
}

public void Rogue_HeavyRain_Enemy(int entity)
{
	if(view_as<CClotBody>(entity).m_iBleedType == BLEEDTYPE_SEABORN)
	{
		fl_Extra_Speed[entity] *= 1.1;
	}
	else
	{
		fl_Extra_Speed[entity] *= 0.8;
	}
}

public void Rogue_Ruinan_BadGuy(int entity)
{
	fl_Extra_Damage[entity] *= 1.15;
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 1.25));
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 1.25));
}

public void Rogue_Ruinan_GoodGuy(int entity)
{
	fl_Extra_Damage[entity] *= 0.9;
	SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iMaxHealth") * 0.85));
	SetEntProp(entity, Prop_Data, "m_iHealth", RoundFloat(GetEntProp(entity, Prop_Data, "m_iHealth") * 0.85));
}

public void Rogue_Curse_HeavyRain(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Heavy Rain", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Heavy Rain");
	}
}

public void Rogue_Curse_ExtremeHeat(bool enable)
{
	ExtremeHeat = enable;
}

public void Rogue_Curse_HeavyWind(bool enable)
{
	HeavyWind = enable;

	if(enable)
	{
		Rogue_GiveNamedArtifact("Heavy Wind", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Heavy Wind");
	}
}

public void Rogue_Curse_DenseFrost(bool enable)
{
	delete FrostTimer;

	if(enable)
		FrostTimer = CreateTimer(0.25, Timer_ParadoxFrost, _, TIMER_REPEAT);
}

public void Rogue_Curse_RedMoon(bool enable)
{
	RedMoon = enable;
}

public void Rogue_ShadowingDarkness(bool enable)
{
	delete AnxietyTimer;

	if(enable)
		AnxietyTimer = CreateTimer(0.25, Timer_AnxietyTimer, _, TIMER_REPEAT);
}

static Action Timer_AnxietyTimer(Handle timer)
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			ApplyStatusEffect(entity, entity, "Extreme Anxiety", 1.0);
		}
	}
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2)
		{
			ApplyStatusEffect(client_summon, client_summon, "Extreme Anxiety", 1.0);
		}
	}

	return Plugin_Continue;
}

static Action Timer_ParadoxFrost(Handle timer)
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && !b_NpcIsInvulnerable[entity])
		{
			if(WinterTheme && WinterTheme.FindValue(i_NpcInternalId[entity]) != -1)
				continue;
			
			int health = GetEntProp(entity, Prop_Data, "m_iHealth");
			if(health > 1)
			{
				int damage = ReturnEntityMaxHealth(entity) / 1600;
				if(damage > 50)
					damage = 50;
				
				health -= damage;
				if(health < 1)
					health = 1;
				
				SetEntProp(entity, Prop_Data, "m_iHealth", health);
			}
		}
	}

	return Plugin_Continue;
}

public void Rogue_BlueGoggles_Collect()
{
	/*
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == BobTheFirstFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
	*/
	//dont allow both bob and goggles, only 1 follower.
	
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_goggles_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}
}

public void Rogue_BlueGoggles_Remove()
{
	/*
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == GogglesFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
	*/
}

bool MazeatTechLost;

bool MazeatItemHas()
{
	return MazeatTechLost;
}

public void Rogue_MazeatLostTech_Collect()
{
	MazeatTechLost = true;
}

public void Rogue_MazeatLostTech_Remove()
{
	MazeatTechLost = false;
}

static Handle KahmlsteinTimer;

public void Rogue_Kahmlstein_Collect()
{
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_kahmlstein_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}

	delete KahmlsteinTimer;
	KahmlsteinTimer = CreateTimer(1.5, Timer_KahmlsteinTimer, _, TIMER_REPEAT);
}

public void Rogue_Kahmlstein_Remove()
{
	/*
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != -1 && i_NpcInternalId[other] == KahmlsteinFollower_ID() && IsEntityAlive(other))
		{
			SmiteNpcToDeath(other);
			break;
		}
	}
	*/

	delete KahmlsteinTimer;
}

static Action Timer_KahmlsteinTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon != -1)
					Saga_ChargeReduction(client, weapon, 1.0);
			}
		}
	}

	return Plugin_Continue;
}

public void Rogue_Twirl_Collect()
{
	for(int client_summon=1; client_summon<=MaxClients; client_summon++)
	{
		if(IsClientInGame(client_summon) && GetClientTeam(client_summon)==2 && IsPlayerAlive(client_summon) && TeutonType[client_summon] == TEUTON_NONE)
		{
			float flPos[3];
			GetClientAbsOrigin(client_summon, flPos);
			NPC_CreateByName("npc_twirl_follower", client_summon, flPos, {0.0, 0.0, 0.0}, TFTeam_Red);
			break;
		}
	}

	delete KahmlsteinTimer;
	KahmlsteinTimer = CreateTimer(1.5, Timer_TwirlTimer, _, TIMER_REPEAT);
}
public void Rogue_Twirl_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;
		// +15% mana cap and regen
		map.GetValue("405", value);
		map.SetValue("405", value * 1.15);
	}
}
public void Rogue_Twirl_Weapon(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;

		// +100% mana cap and regen
		map.GetValue("405", value);
		map.SetValue("405", value * 2.0);
	}
}

static Action Timer_TwirlTimer(Handle timer)
{
	if(Rogue_CanRegen())
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(TeutonType[client] == TEUTON_NONE && IsClientInGame(client) && IsPlayerAlive(client))
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon != -1)
					Saga_ChargeReduction(client, weapon, 0.5);
			}
		}
	}

	return Plugin_Continue;
}

public void Rogue_Twirl_Remove()
{
	delete KahmlsteinTimer;
	Rogue_Refresh_Remove();
}

static ArrayList RuniaGemTimers;

public void Rogue_RuinaGem_StageStart()
{
	if(RuniaGemTimers)
		Rogue_RuinaGem_Remove();
	
	RuniaGemTimers = new ArrayList();
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			RuniaGemTimers.Push(CreateTimer(1.0, RuniaGem_Timer, EntIndexToEntRef(client), TIMER_REPEAT));
		}
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && !b_NpcIsInvulnerable[entity] && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Red)
		{
			RuniaGemTimers.Push(CreateTimer(1.0, RuniaGem_Timer, EntIndexToEntRef(entity), TIMER_REPEAT));
		}
	}
}

public void Rogue_RuinaGem_Remove()
{
	if(RuniaGemTimers)
	{
		int length = RuniaGemTimers.Length;
		for(int i; i < length; i++)
		{
			CloseHandle(RuniaGemTimers.Get(i));
		}

		delete RuniaGemTimers;
	}
}

static Action RuniaGem_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity != -1)
	{
		int health = entity > MaxClients ? GetEntProp(entity, Prop_Data, "m_iHealth") : GetClientHealth(entity);
		int maxhealth = ReturnEntityMaxHealth(entity);
		if(health > (maxhealth / 2))
			return Plugin_Continue;
		
		if(entity > MaxClients)
		{
			HealEntityGlobal(entity, entity, float(maxhealth / 2), 1.0, 1.0, HEAL_ABSOLUTE);
		}
		else
		{
			GiveCompleteInvul(entity, 2.0);
			f_OneShotProtectionTimer[entity] = GetGameTime() + 60.0;
			HealEntityGlobal(entity, entity, float(maxhealth / 2), 1.0, 1.0, HEAL_ABSOLUTE);
		}

		EmitSoundToAll("misc/halloween/spell_overheal.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
	}

	RuniaGemTimers.Erase(RuniaGemTimers.FindValue(timer));
	return Plugin_Stop;
}
