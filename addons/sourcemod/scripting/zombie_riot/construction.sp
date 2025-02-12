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

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Plugin, sizeof(this.Plugin));

		this.Distance = kv.GetFloat("distance");
		this.Distance *= this.Distance;
		this.Common = kv.GetNum("common") + 1;
	}
}

static bool InConstMode;
static int AttackRisk;
static int MaxAttacks;
static int HighestRisk;
static float AttackTime;
static int MaxResource;
static ArrayList RiskList;
static ArrayList ResourceList;

static Handle GameTimer;
static int CurrentRisk;
static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// 0 = None, 1 = Resource, 2 = Base, 3 = Final
static int AttackRef;
static char CurrentSpawnName[64];

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
	//LoadTranslations("zombieriot.phrases.construction"); 
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

	delete ResourceList;
	ResourceList = new ArrayList(sizeof(ResourceInfo));
	RiskList = new ArrayList();

	MaxAttacks = kv.GetNum("attackcount");
	AttackTime = kv.GetFloat("attacktime");
	AttackRisk = kv.GetNum("attackrisk");
	MaxResource = kv.GetNum("resourcecount");
	
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

	float pos1[3], pos2[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", pos2);
			break;
		}
	}

	NPC_CreateByName("npc_base_building", -1, pos1, pos2, TFTeam_Red);

	NextAttackAt = GetGameTime() + AttackTime;
	GameTimer = CreateTimer(AttackTime, Timer_StartAttackWave);

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
		
		area.GetCenter(pos2);
		float distance = GetVectorDistance(pos1, pos2, true);
		if(GetRandomResourceInfo(distance, info))
		{
			pos2[0] = 0.0;
			pos2[1] = GetRandomFloat(0.0, 360.0);
			pos2[2] = 0.0;
			NPC_CreateByName(info.Plugin, -1, pos1, pos2, TFTeam_Blue);
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
	CurrentRisk += AttackRisk;
	if(CurrentRisk > HighestRisk)
		CurrentRisk = HighestRisk;
	
	CurrentAttacks++;
	
	// Clear out existing enemies
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
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
		GetRandomAttackInfo(CurrentRisk + 1, attack);
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

bool Construction_StartResourceAttack(int entity)
{
	if(AttackType)
		return false;
	
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	int risk = CurrentRisk + RiskBonusFromDistance(pos);

	AttackInfo attack;
	GetRandomAttackInfo(risk, attack);
	if(!StartAttack(attack, 1, entity))
		return false;
	
	// TODO: Set up rewards, etc.
	return true;
}

static void GetRandomAttackInfo(int risk, AttackInfo attack)
{
	int setRisk = risk;
	if(setRisk > HighestRisk)
		setRisk = HighestRisk;
	
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

	if(type == 2)
		ReviveAll();
	
	Waves_RoundEnd();
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();

	// TODO: Resource battle rewards
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
				/*case 1:
				{
					int flags = CurrentRisk < HighestRisk ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS
					if(flags == MVM_CLASS_FLAG_NORMAL && CurrentRisk > (HighestRisk * 3 / 4))
						flags += MVM_CLASS_FLAG_ALWAYSCRIT;
					
					Waves_SetWaveClass(objective, i, CurrentRisk + 1, "robo_extremethreat", flags, true);
					continue;
				}*/
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
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
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
