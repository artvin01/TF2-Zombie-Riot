#pragma semicolon 1
#pragma newdecls required

enum struct AttackInfo
{
	char WaveSet[64];

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.WaveSet, sizeof(this.WaveSet));
		
		char buffer[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, this.WaveSet);
		if(!FileExists(buffer))
			LogError("\"%s\" wave set does not exist", this.WaveSet);
	}
}

enum struct ResourceInfo
{
	char Plugin[64];
	float Distance;
	int Common;
	int Health;
	int Defense;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Plugin, sizeof(this.Plugin));

		this.Distance = kv.GetFloat("distance");
		this.Distance *= this.Distance;
		this.Common = kv.GetNum("common") + 1;
		this.Health = kv.GetNum("health");
		this.Defense = kv.GetNum("defense");
	}
}

enum struct RewardInfo
{
	char Name[48];
	int MinRisk;
	int Amount;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));

		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "Material %s", this.Name);
		FailTranslation(buffer);
		FormatEx(buffer, sizeof(buffer), "material_%s", this.Name);
		PrecacheMvMIconCustom(buffer);

		this.MinRisk = kv.GetNum("risk");
		this.Amount = kv.GetNum("amount");
	}
}

enum struct ResearchInfo
{
	char Name[48];
	char Key[48];
	float Time;
	StringMap CostMap;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Name, sizeof(this.Name));
		FailTranslation(this.Name);

		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "%s Desc", this.Name);
		FailTranslation(buffer);

		this.Time = kv.GetFloat("time");
		kv.GetString("key", this.Key, sizeof(this.Key));

		this.CostMap = new StringMap();
		if(kv.JumpToKey("cost"))
		{
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					if(kv.GetSectionName(buffer, sizeof(buffer)))
						this.CostMap.SetValue(buffer, kv.GetNum(NULL_STRING));
				}
				while(kv.GotoNextKey(false));

				kv.GoBack();
			}

			kv.GoBack();
		}
	}
}

static bool InConstMode;
static int RiskIncrease;
static int MaxAttacks;
static int HighestRisk;
static float AttackTime;
static int AttackRiskBonus;
static int MaxResource;
static ArrayList RiskList;
static ArrayList ResourceList;
static ArrayList RewardList;
static ArrayList ResearchList;

static Handle GameTimer;
static int CurrentRisk;
static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// 0 = None, 1 = Resource, 2 = Base, 3 = Final
static int AttackRef;
static char CurrentSpawnName[64];
static StringMap CurrentMaterials;
static ArrayList CurrentResearch;
//static int InResearch = -1;
//static float InResearchAt;
//static Handle InResearchMenu[MAXTF2PLAYERS];

bool Construction_Mode()
{
	return InConstMode;
}

bool Construction_Started()
{
	return Construction_Mode() && GameRules_GetRoundState() == RoundState_ZombieRiot;
}

bool Construction_InSetup()
{
	return Construction_Mode() && AttackType < 2;
}

int Construction_GetRound()
{
	return CurrentRisk * 80 / HighestRisk;
}

bool Construction_FinalBattle()
{
	return CurrentAttacks > MaxAttacks;
}

void Construction_PluginStart()
{
	LoadTranslations("zombieriot.phrases.construction"); 
}

void Construction_MapStart()
{
	InConstMode = false;
	Construction_RoundEnd();
}

void Construction_SetupVote(KeyValues kv)
{
	PrecacheMvMIconCustom("classic_defend", false);

	InConstMode = true;

	kv.Rewind();
	kv.JumpToKey("Construction");
	Rogue_SetupVote(kv, true);

	if(RiskList)
	{
		int length = RiskList.Length;
		for(int i; i < length; i++)
		{
			CloseHandle(RiskList.Get(i));
		}
		delete RiskList;
	}

	ResearchInfo research;

	if(ResearchList)
	{
		int length = ResearchList.Length;
		for(int i; i < length; i++)
		{
			ResearchList.GetArray(i, research);
			delete research.CostMap;
		}
		delete ResearchList;
	}

	delete ResourceList;
	delete RewardList;
	ResourceList = new ArrayList(sizeof(ResourceInfo));
	RewardList = new ArrayList(sizeof(RewardInfo));
	ResearchList = new ArrayList(sizeof(ResearchInfo));
	RiskList = new ArrayList();

	MaxAttacks = kv.GetNum("attackcount");
	AttackTime = kv.GetFloat("attacktime");
	AttackRiskBonus = kv.GetNum("attackrisk");
	RiskIncrease = kv.GetNum("riskincrease");
	MaxResource = kv.GetNum("resourcecount");
	
	if(kv.JumpToKey("Research"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				research.SetupKv(kv);
				ResearchList.PushArray(research);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("AttackDrops"))
	{
		if(kv.GotoFirstSubKey())
		{
			RewardInfo reward;

			do
			{
				reward.SetupKv(kv);
				RewardList.PushArray(reward);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("Resources"))
	{
		if(kv.GotoFirstSubKey())
		{
			ResourceInfo resource;

			do
			{
				resource.SetupKv(kv);
				ResourceList.PushArray(resource);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("Attacks"))
	{
		if(kv.GotoFirstSubKey())
		{
			AttackInfo attack;

			do
			{
				if(kv.GotoFirstSubKey(false))
				{
					ArrayList list = new ArrayList(sizeof(AttackInfo));

					do
					{
						attack.SetupKv(kv);
						list.PushArray(attack);
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();

					RiskList.Push(list);
				}
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	HighestRisk = RiskList.Length;

	if(kv.JumpToKey("FinalAttack"))
	{
		if(kv.GotoFirstSubKey(false))
		{
			AttackInfo attack;
			ArrayList list = new ArrayList(sizeof(AttackInfo));

			do
			{
				attack.SetupKv(kv);
				list.PushArray(attack);
			}
			while(kv.GotoNextKey(false));

			kv.GoBack();

			RiskList.Push(list);
		}

		kv.GoBack();
	}

	if(!RiskList.Length)
		InConstMode = false;

	SteamWorks_UpdateGameTitle();
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) > 1)
		{
			Waves_RoundStart();
			break;
		}
	}

	Waves_SetReadyStatus(2);
}

// Waves_RoundStart()
void Construction_StartSetup()
{
	Rogue_StartSetup();
	Construction_RoundEnd();

	GameTimer = CreateTimer(1.0, Timer_WaitingPeriod, TIMER_REPEAT);

	ArrayList list = new ArrayList();
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red)
		{
			list.Push(i);
		}
	}

	int length = list.Length;
	int choosen = GetURandomInt() % length;
	for(int i; i < length; i++)
	{
		int index = list.Get(i);
		SetEntProp(i_ObjectsSpawners[index], Prop_Data, "m_bDisabled", index != choosen);
	}

	delete list;
}

void Construction_RoundEnd()
{
	CurrentRisk = 0;
	CurrentAttacks = 0;
	delete GameTimer;
	delete CurrentMaterials;
	delete CurrentResearch;
//	InResearch = -1;
	AttackType = 0;
}

static Action Timer_WaitingPeriod(Handle timer)
{
	float pos1[3], pos2[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
			break;
		}
	}

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetClientAbsOrigin(client, pos2);
			if(GetVectorDistance(pos1, pos2, true) > 900000.0)
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos1, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	
	return Plugin_Continue;
}

// Rogue_RoundStartTimer()
void Construction_Start()
{
	delete GameTimer;

	float pos[3], ang[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
			break;
		}
	}

	NPC_CreateByName("npc_base_building", -1, pos, ang, TFTeam_Red);

	NextAttackAt = GetGameTime() + AttackTime;
	GameTimer = CreateTimer(AttackTime, Timer_StartAttackWave);
	Ammo_Count_Ready = 20;

	ArrayList picked = new ArrayList();
	ResourceInfo info;
	for(int i; i < MaxResource; i++)
	{
		CNavArea area = PickRandomArea();
		if(area == NULL_AREA)
			continue;
		
		if(picked.FindValue(area))
		{
			if(GetURandomInt() % 2)
				i--;
			
			continue;
		}

		picked.Push(i);
		
		if(area.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
		{
			if(GetURandomInt() % 2)
				i--;
			
			continue;
		}
		
		area.GetCenter(ang);
		float distance = GetVectorDistance(pos, ang, true);

		if(!GetRandomResourceInfo(distance, info))
		{
			if(GetURandomInt() % 2)
				i--;
			
			continue;
		}
		
		ang[0] = 0.0;
		ang[1] = float(GetURandomInt() % 360);
		ang[2] = 0.0;

		int entity = NPC_CreateByName(info.Plugin, -1, pos, ang, TFTeam_Blue);
		if(entity != -1)
		{
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", info.Health);
			SetEntProp(entity, Prop_Data, "m_iHealth", info.Health);
		}
	}

	delete picked;
}

static bool GetRandomResourceInfo(float distance, ResourceInfo info)
{
	ArrayList list = new ArrayList();

	int length = ResourceList.Length;
	for(int a; a < length; a++)
	{
		ResourceList.GetArray(a, info);
		if(info.Distance > distance)
			continue;
		
		for(int b; b < info.Common; b++)
		{
			list.Push(a);
		}
	}

	length = list.Length;
	if(length)
		ResourceList.GetArray(list.Get(GetURandomInt() % length), info);

	delete list;
	return length != 0;
}

static Action Timer_StartAttackWave(Handle timer)
{
	CurrentRisk += RiskIncrease;
	CurrentAttacks++;
	
	// Clear out existing enemies
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) != TFTeam_Red)
				SmiteNpcToDeath(entity);
		}
	}

	AttackInfo attack;
	if(CurrentAttacks > MaxAttacks)
	{
		// Final Boss
		ArrayList list = RiskList.Get(RiskList.Length - 1);
		list.GetArray(GetURandomInt() % list.Length, attack);
	}
	else
	{
		GetRandomAttackInfo(CurrentRisk + AttackRiskBonus, attack);
	}

	StartAttack(attack, CurrentAttacks > MaxAttacks ? 3 : 2, GetBaseBuilding());

	if(CurrentAttacks > MaxAttacks)
	{
		GameTimer = null;
	}
	else
	{
		NextAttackAt = GetGameTime() + AttackTime;
		GameTimer = CreateTimer(AttackTime, Timer_StartAttackWave);
	}
	return Plugin_Continue;
}

static void GetRandomAttackInfo(int risk, AttackInfo attack)
{
	int setRisk = risk;
	if(setRisk < 0)
	{
		setRisk = 0;
	}
	else if(setRisk >= HighestRisk)
	{
		setRisk = HighestRisk - 1;
	}
	
	ArrayList list = RiskList.Get(setRisk);
	list.GetArray(GetURandomInt() % list.Length, attack);
}

// Start an attack based on info and the target entity
static bool StartAttack(const AttackInfo attack, int type, int target)
{
	if(target == -1)
		return false;
	
	float pos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
	bool failed = !UpdateValidSpawners(pos);

	if(type < 2 && failed)
		return false;

	AttackType = type;
	AttackRef = EntIndexToEntRef(target);

	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, attack.WaveSet);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(buffer);
	Waves_SetupWaves(kv, false);
	delete kv;

	Rogue_TriggerFunction(Artifact::FuncStageStart);
	CreateTimer(float(type * type), Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	return true;
}

void Construction_BattleVictory()
{
	int type = AttackType;
	AttackType = 0;

	if(type > 1)
		ReviveAll();
	
	Waves_RoundEnd();
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();

	int entity = EntRefToEntIndex(AttackRef);
	if(entity != -1)
		view_as<CClotBody>(entity).Anger = false;
	
	GiveRandomReward(CurrentRisk, type > 1 ? 4 : 2);
}

static void GiveRandomReward(int risk, int maxDrops)
{
	ArrayList list = new ArrayList();

	RewardInfo info;
	int length = RewardList.Length;
	for(int a; a < length; a++)
	{
		RewardList.GetArray(a, info);
		if(info.MinRisk > risk)
			continue;
		
		list.Push(a);
	}

	list.Sort(Sort_Random, Sort_Integer);

	length = list.Length;
	if(length > maxDrops)
		length = maxDrops;
	
	for(int a; a < length; a++)
	{
		RewardList.GetArray(list.Get(a), info);

		int amount = RoundFloat(info.Amount * GetRandomFloat(0.5, 1.5));

		Construction_AddMaterial(info.Name, amount);
	}

	delete list;
}

bool Construction_UpdateMvMStats()
{
	if(!Construction_Mode() || AttackType > 1)
		return false;
	
	int objective = FindEntityByClassname(-1, "tf_objective_resource");
	if(objective != -1)
	{
		SetEntProp(objective, Prop_Send, "m_nMvMWorldMoney", 0);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveEnemyCount", 0);

		SetEntProp(objective, Prop_Send, "m_nMannVsMachineWaveCount", CurrentAttacks);
		SetEntProp(objective, Prop_Send, "m_nMannVsMachineMaxWaveCount", MaxAttacks + 1);

		StringMapSnapshot snap = CurrentMaterials ? CurrentMaterials.Snapshot() : null;
		int snapLength = snap ? snap.Length : 0;
		int snapPos;

		for(int i; i < 24; i++)
		{
			switch(i)
			{
				case 0:
				{
					int time = RoundToCeil(NextAttackAt - GetGameTime());
					int flags = CurrentAttacks < MaxAttacks ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
					if(time < 61)
						flags += MVM_CLASS_FLAG_ALWAYSCRIT;
					
					Waves_SetWaveClass(objective, i, time, "classic_defend", flags, true);
					continue;
				}
				case 1:
				{
					int flags = CurrentRisk < HighestRisk ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
					if(flags == MVM_CLASS_FLAG_NORMAL && CurrentRisk > (HighestRisk * 3 / 4))
						flags += MVM_CLASS_FLAG_ALWAYSCRIT;
					
					Waves_SetWaveClass(objective, i, CurrentRisk + 1, "robo_extremethreat", flags, true);
					continue;
				}
				default:
				{
					while(snapPos < snapLength)
					{
						static const char prefix[] = "material_";

						int size = snap.KeyBufferSize(snapPos) + sizeof(prefix) + 1;
						char[] key = new char[size];
						snap.GetKey(snapPos, key, size);
						snapPos++;

						int amount;
						CurrentMaterials.GetValue(key, amount);
						if(amount > 0)
						{
							Format(key, size, "%s%s", prefix, key);
							Waves_SetWaveClass(objective, i, amount, key, MVM_CLASS_FLAG_NORMAL, true);
							break;
						}
					}
				}
			}

			Waves_SetWaveClass(objective, i);
		}
	}

	return true;
}

bool Construction_BlockSpawner(const char[] name)
{
	if(!Construction_Mode())
		return false;
	
	// Block other spawners not our name
	return CurrentSpawnName[0] && !StrEqual(CurrentSpawnName, name, false);
}

static int GetBaseBuilding()
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == BaseBuilding_ID() && IsEntityAlive(entity))
			return entity;
	}

	return -1;
}

static int RiskBonusFromDistance(const float pos[3])
{
	int entity = GetBaseBuilding();
	if(entity == -1)
		return 0;
	
	float pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
	return RoundFloat(GetVectorDistance(pos, pos2, true) / 400000000.0 * float(HighestRisk));
}

static bool UpdateValidSpawners(const float pos[3])
{
	CNavArea goalArea = TheNavMesh.GetNavArea(pos, 1000.0);
	if(goalArea == NULL_AREA)
	{
		CurrentSpawnName[0] = 0;
		PrintToChatAll("ERROR: Could not find valid nav area for location (%f %f %f)", pos[0], pos[1], pos[2]);
		return false;
	}

	ArrayList list = new ArrayList();
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") != TFTeam_Red)
		{
			list.Push(i_ObjectsSpawners[i]);
		}
	}

	int length = list.Length;
	for(int i; i < length; i++)
	{
		int entity = list.Get(i);

		CNavArea startArea = TheNavMesh.GetNavAreaEntity(entity, view_as<GetNavAreaFlags_t>(0), 1000.0);
		if(startArea == NULL_AREA)
			continue;
		
		if(TheNavMesh.BuildPath(startArea, goalArea, pos))
		{
			GetEntPropString(entity, Prop_Data, "m_iName", CurrentSpawnName, sizeof(CurrentSpawnName));

			delete list;
			return true;
		}
	}

	CurrentSpawnName[0] = 0;
	PrintToChatAll("ERROR: Could not find valid spawner to path to location (%f %f %f)", pos[0], pos[1], pos[2]);

	delete list;
	return false;
}

void Construction_ClotThink(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 2.0;

	if(AttackType && npc.Anger && EntRefToEntIndex(AttackRef) != npc.index)
	{
		b_NpcIsInvulnerable[npc.index] = true;
	}
	else
	{
		b_NpcIsInvulnerable[npc.index] = false;
	}
}

bool Construction_OnTakeDamage(const char[] resource, int maxAmount, int victim, int attacker, float &damage, int damagetype)
{
	CClotBody npc = view_as<CClotBody>(victim);

	if(AttackType && npc.Anger && EntRefToEntIndex(AttackRef) != npc.index)
	{
		// No cross mining when a fight is happening
		damage = 0.0;
		return false;
	}

	if(npc.Anger && (attacker > MaxClients || !(damagetype & DMG_CLUB)))
	{
		// Must provoke it via melee first
		damage = 0.0;
		return false;
	}

	if(!CheckInHud())
	{
		if(ResourceList)
		{
			char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[npc.index], plugin, sizeof(plugin));

			int index = ResourceList.FindString(plugin, ResourceInfo::Plugin);
			if(index != -1)
			{
				ResourceInfo info;
				ResourceList.GetArray(index, info);

				if(!(damagetype & DMG_TRUEDAMAGE))
				{
					float minDamage = damage * 0.05;
					damage -= float(info.Defense);
					if(damage < minDamage)
						damage = minDamage;
				}

				if(npc.Anger && RiskList)
				{
					if(AttackType)
						return false;
					
					float pos[3];
					GetEntPropVector(npc.index, Prop_Data, "m_vecOrigin", pos);
					int risk = CurrentRisk + RiskBonusFromDistance(pos);

					AttackInfo attack;
					GetRandomAttackInfo(risk, attack);
					if(!StartAttack(attack, 1, npc.index))
						return false;
					
					if(attacker > 0 && attacker <= MaxClients)
					{
						char buffer[64];
						FormatEx(buffer, sizeof(buffer), "Material %s", resource);
						if(TranslationPhraseExists(buffer))
							CPrintToChatAll("%t", "Resource Attack Started", attacker, buffer);
					}

					return true;
				}
			}
		}
	}

	if(CurrentAttacks && MaxAttacks && RiskIncrease)
	{
		float multi = Pow(0.5, float(CurrentAttacks) * 5.0 / float(MaxAttacks));
		
		damage *= multi;
	}

	if(Construction_Mode() && maxAmount)
		ResourceBasedOnHealth(resource, maxAmount, npc, GetEntProp(npc.index, Prop_Data, "m_iHealth") - RoundToCeil(damage), GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

	return true;
}

void Construction_NPCDeath(const char[] resource, int maxAmount, CClotBody npc)
{
	ResourceBasedOnHealth(resource, maxAmount, npc, 0, 100);
}

static void ResourceBasedOnHealth(const char[] resource, int maxAmount, CClotBody npc, int health, int maxhealth)
{
	if(Construction_Mode() && maxhealth)
	{
		int newAmount = maxAmount - (health * maxAmount / maxhealth) - 1;
		if(newAmount > maxAmount)
			newAmount = maxAmount;
		
		while(newAmount < npc.g_TimesSummoned)
		{
			npc.g_TimesSummoned++;
			Construction_AddMaterial(resource, 1);
		}
	}
}

float Construction_GetNextAttack()
{
	return NextAttackAt;
}

int Construction_GetMaterial(const char[] short)
{
	int amount;
	if(CurrentMaterials)
		CurrentMaterials.GetValue(short, amount);

	return amount;
}

int Construction_AddMaterial(const char[] short, int gain, bool silent = false)
{
	if(!CurrentMaterials)
		CurrentMaterials = new StringMap();
	
	int amount;
	CurrentMaterials.GetValue(short, amount);
	amount += gain;
	CurrentMaterials.SetValue(short, amount);

	if(!silent)
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "Material %s", short);
		if(TranslationPhraseExists(buffer))
		{
			if(gain > 0)
			{
				CPrintToChatAll("%t", "Gained Material", gain, buffer);
			}
			else
			{
				CPrintToChatAll("%t", "Used Material", gain, buffer);
			}
		}
		else
		{
			if(gain > 0)
			{
				CPrintToChatAll("{green}Gained %d %s", gain, short);
			}
			else
			{
				CPrintToChatAll("{red}Used %d %s", gain, short);
			}
		}
	}

	return amount;
}

public float InterMusic_ConstructRisk(int client)
{
	if(LastMann)
		return 1.0;
	
	if(!AttackType)
		return 0.0;
	
	float volume = float(CurrentRisk) / float(HighestRisk);
	return fClamp(volume, 0.0, 1.0);
}

public float InterMusic_ConstructBase(int client)
{
	if(LastMann)
		return 1.0;
	
	int entity = GetBaseBuilding();
	if(entity == -1)
		return 0.0;
	
	float pos1[3], pos2[3];
	GetClientEyePosition(client, pos1);
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
	float distance = GetVectorDistance(pos1, pos2);
	distance = distance / 2000.0;
	return fClamp(1.0 - distance, 0.0, 1.0);
}

public float InterMusic_ConstructIntencity(int client)
{
	if(AttackType > 1)
		return 1.0;
	
	if(!AttackType)
		return 0.0;
	
	return InterMusic_ByIntencity(client);
}

/*
void Construction_OpenResearch(int client)
{
	SetGlobalTransTarget(client);

	Menu menu = new Menu(ResearchMenuH);

	ResearchInfo info;
	char index[16], buffer[128];

	if(InResearch == -1)
	{
		menu.SetTitle("%t\n \n%t", "Research Station", "Crouch and select to view description");

		int amount, items;
		int length1 = ResearchList.Length;
		for(int a; a < length1; a++)
		{
			ResearchList.GetArray(a, info);
			if(CurrentResearch && CurrentResearch.FindString(info.Name) != -1)
				continue;

			if(info.Key[0])
			{
				if(!CurrentResearch || CurrentResearch.FindString(info.Key) == -1)
					continue;
			}

			FormatEx(buffer, sizeof(buffer), "%t", info.Name);

			bool failed;
			StringMapSnapshot snap = info.CostMap.Snapshot();
			int length2 = snap.Length;
			for(int b; b < length2; b++)
			{
				int size = snap.KeyBufferSize(b) + 10;
				char[] name = new char[size];
				snap.GetKey(b, name, size);
				
				info.CostMap.GetValue(name, amount);

				if(!failed && Construction_GetMaterial(name) < amount)
					failed = true;

				Format(name, size, "Material %s", name);
				if(TranslationPhraseExists(name))
				{
					Format(buffer, sizeof(buffer), "%s (%d %t)", buffer, amount, name);
				}
				else
				{
					Format(buffer, sizeof(buffer), "%s (%d %s)", buffer, amount, name);
				}
			}
			delete snap;

			IntToString(a, index, sizeof(index));
			menu.AddItem(index, buffer, failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			if(++items > 4)
				break;
		}
	}
	else
	{
		ResearchList.GetArray(InResearch, info);
		menu.SetTitle("%t\n \n%t", "Research Station", info.Name);

		float gameTime = GetGameTime();
		if(InResearchAt > gameTime)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Claim Research Time", RoundToCeil(InResearchAt - gameTime));
			menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Claim Research");
			menu.AddItem(NULL_STRING, buffer);
		}
	}

	if(menu.Display(client, MENU_TIME_FOREVER))
		InResearchMenu[client] = CreateTimer(1.0, ResearchTimer, client);
}

static Action ResearchTimer(Handle timer, int client)
{
	InResearchMenu[client] = null;
	Construction_OpenResearch(client);
	return Plugin_Continue;
}

static int ResearchMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			delete InResearchMenu[client];
		}
		case MenuAction_Select:
		{
			delete InResearchMenu[client];
			
			ResearchInfo info;
			char buffer[64];

			if(InResearch == -1)
			{
				menu.GetItem(choice, buffer, sizeof(buffer));

				int a = StringToInt(buffer);

				ResearchList.GetArray(a, info);

				if(GetClientButtons(client) & IN_DUCK)
				{
					FormatEx(buffer, sizeof(buffer), "%s Desc", info.Name);
					CPrintToChat(client, "%t", "Artifact Info", info.Name, buffer);
				}
				else
				{
					int amount;

					StringMapSnapshot snap = info.CostMap.Snapshot();
					int length2 = snap.Length;
					for(int b; b < length2; b++)
					{
						snap.GetKey(b, buffer, sizeof(buffer));
						
						info.CostMap.GetValue(buffer, amount);

						if(Construction_GetMaterial(buffer) < amount)
						{
							delete snap;
							return 0;
						}
					}

					for(int b; b < length2; b++)
					{
						snap.GetKey(b, buffer, sizeof(buffer));
						
						info.CostMap.GetValue(buffer, amount);
						Construction_AddMaterial(buffer, -amount);
					}
					delete snap;

					InResearchAt = GetGameTime() + info.Time;
					InResearch = a;

					CPrintToChatAll("%t", "Player Start Research", client, info.Name);
				}
			}
			else if(InResearchAt < GetGameTime())
			{
				ResearchList.GetArray(InResearch, info);

				if(!CurrentResearch)
					CurrentResearch = new ArrayList(sizeof(info.Name));
				
				CurrentResearch.PushString(info.Name);
				InResearch = -1;

				FormatEx(buffer, sizeof(buffer), "%s Desc", info.Name);
				CPrintToChatAll("%t", "Finish Research Desc", info.Name, buffer);
			}

			Construction_OpenResearch(client);
		}
	}
	return 0;
}
*/
