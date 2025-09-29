#pragma semicolon 1
#pragma newdecls required

int PlayerVotedForThis[MAXPLAYERS];

enum struct AttackInfo
{
	char WaveSet[64];
	char Key[64];

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.WaveSet, sizeof(this.WaveSet));
		kv.GetString(NULL_STRING, this.Key, sizeof(this.Key));
		
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
	int Limit;

	void SetupKv(KeyValues kv)
	{
		kv.GetSectionName(this.Plugin, sizeof(this.Plugin));

		this.Distance = kv.GetFloat("distance");
		this.Distance *= this.Distance;
		this.Common = kv.GetNum("common") + 1;
		this.Health = kv.GetNum("health");
		this.Defense = kv.GetNum("defense");
		this.Limit = kv.GetNum("limit");
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
		this.Name[0] = CharToLower(this.Name[0]);

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
	int Res_InternalID;
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

		static int IdIncrement;
		IdIncrement++;
		this.Res_InternalID = IdIncrement;

		this.CostMap = new StringMap();
		if(kv.JumpToKey("cost"))
		{
			if(kv.GotoFirstSubKey(false))
			{
				do
				{
					if(kv.GetSectionName(buffer, sizeof(buffer)))
					{
						buffer[0] = CharToLower(buffer[0]);
						this.CostMap.SetValue(buffer, kv.GetNum(NULL_STRING));
					}
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
static float AttackRiskBonus;
static int MaxResource;
static ArrayList RiskList;
static ArrayList ResourceList;
static ArrayList RewardList;
static ArrayList ResearchList;
static MusicEnum BackgroundMusic;
static bool ExplainOreMining[MAXPLAYERS];

static Handle GameTimer;
static int CurrentRisk;
static bool CurrentMidRaise;
static int CurrentAttacks;
static float NextAttackAt;
static int AttackType;	// 0 = None, 1 = Resource, 2 = Base, 3 = Final
static int AttackRef;
static int AttackHardcore;
static char CurrentSpawnName[64];
static StringMap CurrentMaterials;
static ArrayList CurrentResearch;
static int InResearch = -1;
static float InResearchAt;
static Handle InResearchMenu[MAXPLAYERS];


void Construction_PutInServer(int client)
{
	ExplainOreMining[client] = false;
}
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
	int round = CurrentRisk * 50 / HighestRisk;
	if(AttackType > 0 && AttackHardcore > 0)
		round += AttackHardcore * 2;
	
	return round;
}

int Construction_GetRisk()
{
	return CurrentRisk;
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
	BackgroundMusic.Clear();
}

void Construction_SetupVote(KeyValues kv)
{
	PrecacheMvMIconCustom("classic_defend", false);

	InConstMode = true;

	Rogue_SetupVote(kv, "Construction");

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
	BackgroundMusic.Clear();
	ResourceList = new ArrayList(sizeof(ResourceInfo));
	RewardList = new ArrayList(sizeof(RewardInfo));
	ResearchList = new ArrayList(sizeof(ResearchInfo));
	RiskList = new ArrayList();

	MaxAttacks = kv.GetNum("attackcount");
	AttackTime = kv.GetFloat("attacktime");
	AttackRiskBonus = kv.GetFloat("attackbonus");
	RiskIncrease = kv.GetNum("riskincrease");
	MaxResource = kv.GetNum("resourcecount");

	char buffer[64];
	
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
	
	if(kv.JumpToKey("RandomMusic"))
	{
		int count;
		
		if(kv.GotoFirstSubKey())
		{
			do
			{
				count++;
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}


		if(count)
		{
			count = Waves_MapSeed() % count;

			if(kv.GotoFirstSubKey())
			{
				for(int i; i < count; i++)
				{
					kv.GotoNextKey();
				}

				kv.GetSectionName(buffer, sizeof(buffer));
				kv.GoBack();

				BackgroundMusic.SetupKv(buffer, kv);
			}
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
	Zero(PlayerVotedForThis);
	Rogue_StartSetup();
	Construction_RoundEnd();

	NextAttackAt = 0.0;

	delete GameTimer;
	GameTimer = CreateTimer(1.0, Timer_WaitingPeriod, _, TIMER_REPEAT);
	
	//Just incase, reget spawnsers, beacuse its way too fast and needs a frame, start setup is too fast!
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		SDKHook_TeamSpawn_SpawnPostInternal(ent, _, _, _);
	}

	ArrayList list = new ArrayList();
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red)
		{
			list.Push(i);
		}
	}

	int length = list.Length;
	if(length <= 0)
	{
		PrintToChatAll("%i Construction_StartSetup() SOMEHOW HAD 0 SPAWNERS????????",length);
		delete list;
		return;
	}
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

	if(CvarInfiniteCash.BoolValue)
		return Plugin_Continue;
		
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetClientAbsOrigin(client, pos2);
			if(GetVectorDistance(pos1, pos2, true) > 900000.0)
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos1, {0.0, 0.0, 0.0}, NULL_VECTOR);
			}
		}
	}
	
	return Plugin_Continue;
}

// Rogue_RoundStartTimer()
void Construction_Start()
{
	delete GameTimer;

	float pos1[3], pos2[3], ang[3];
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == TFTeam_Red && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
			GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_angRotation", ang);
			break;
		}
	}


	NextAttackAt = GetGameTime() + AttackTime;
	GameTimer = CreateTimer(0.5, Timer_StartAttackWave);
	Ammo_Count_Ready = 20;


	int length = ResourceList.Length;
	if(length)
	{
		int[] resourcePicked = new int[length];
		ArrayList navPicked = new ArrayList();
		ResourceInfo info;
		for(int i; i < MaxResource; i++)
		{
			CNavArea area = PickRandomArea();
			if(area == NULL_AREA)
				continue;
			
			if(navPicked.FindValue(area) != -1)
			{
				if(GetURandomInt() % 2)
					i--;
				
				continue;
			}

			navPicked.Push(i);
			
			if(area.GetAttributes() & (NAV_MESH_AVOID|NAV_MESH_DONT_HIDE))
			{
				if(GetURandomInt() % 2)
					i--;
				
				continue;
			}
			
			area.GetCenter(pos2);
			//Try to not spawn inside other ores?
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			hullcheckmaxs = view_as<float>( { 40.0, 40.0, 120.0 } );
			hullcheckmins = view_as<float>( { -40.0, -40.0, 0.0 } );	
			if(Construction_IsBuildingInWay(pos2, hullcheckmins, hullcheckmaxs))
			{
				i--;
				continue;
			}
			float distance = GetVectorDistance(pos1, pos2, true);

			if(!GetRandomResourceInfo(distance, info, resourcePicked))
			{
				if(GetURandomInt() % 2)
					i--;
				
				continue;
			}
			
			ang[0] = 0.0;
			ang[1] = float(GetURandomInt() % 360);
			ang[2] = 0.0;

			int entity = NPC_CreateByName(info.Plugin, -1, pos2, ang, TFTeam_Blue);
			if(entity != -1)
			{
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", info.Health);
				SetEntProp(entity, Prop_Data, "m_iHealth", info.Health);
			}
		}

		delete navPicked;
	}

	NPC_CreateByName("npc_base_building", -1, pos1, ang, TFTeam_Red);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			Music_Stop_All(client);
			SetMusicTimer(client, GetTime() + 1);
		}
	}

	BackgroundMusic.CopyTo(BGMusicSpecial1);
}

void TutorialShort_ExplainOres(int client)
{
	if(!Construction_Mode())
		return;
	if(ExplainOreMining[client])
		return;


	if(!IsEntityAlive(client))
		return;
	int entity_found = GetClosestOre(client);
	if(!IsValidEntity(entity_found))
		return;
	
	float pos2[3];
	ExplainOreMining[client] = true;
	GetEntPropVector(entity_found, Prop_Data, "m_vecAbsOrigin", pos2);
	pos2[2] += 80.0;
	Event event = CreateEvent("show_annotation");
	if(event)
	{
		char buffer[255];
		FormatEx(buffer, sizeof(buffer), "%T", "Mine Resources", client);
		event.SetFloat("worldPosX", pos2[0]);
		event.SetFloat("worldPosY", pos2[1]);
		event.SetFloat("worldPosZ", pos2[2]);
		event.SetFloat("lifetime", 12.0);
		event.SetString("text", buffer);
		event.SetString("play_sound", "vo/null.mp3");
		IdRef++;
		event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
		event.FireToClient(client);
	}
}


stock int GetClosestOre(int entity)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int i = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(i != entity && IsValidEntity(i) && GetTeam(i) != GetTeam(entity))
		{
			char npc_classname[60];
			NPC_GetPluginById(i_NpcInternalId[i], npc_classname, sizeof(npc_classname));

			if(!(StrContains(npc_classname, "npc_material") != -1))
				continue;
				
			float EntityLocation[3], TargetLocation[3]; 
			GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
			GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
			
			float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
			if( TargetDistance ) 
			{
				if( distance < TargetDistance ) 
				{
					ClosestTarget = i; 
					TargetDistance = distance;		  
				}
			} 
			else 
			{
				ClosestTarget = i; 
				TargetDistance = distance;
			}	
		}
	}
	return ClosestTarget; 
}

static bool GetRandomResourceInfo(float distance, ResourceInfo info, int[] picked)
{
	ArrayList list = new ArrayList();

	int length = ResourceList.Length;

	for(int b = 1; b < MaxResource && !list.Length; b++)
	{
		for(int a; a < length; a++)
		{
			ResourceList.GetArray(a, info);
			if(info.Distance > distance)
				continue;
			
			// Max limit of this
			if(info.Limit && (info.Limit <= picked[a]))
				continue;
			
			// We have too many of this, try getting more of something else
			if(picked[a] > (info.Common * b))
				continue;

			list.Push(a);
		}
	}

	length = list.Length;
	if(length)
	{
		length = list.Get(GetURandomInt() % length);
		ResourceList.GetArray(length, info);
		picked[length]++;
	}

	delete list;
	return length != 0;
}

static Action Timer_StartAttackWave(Handle timer)
{
	float time = NextAttackAt - GetGameTime();
	if(time > 0.0)
	{
		//when 150 ticks left, boost power
		if(time < 150.0 && !CurrentMidRaise)
		{
			CurrentRisk++;
			CurrentMidRaise = true;
		}
		
		GameTimer = CreateTimer(0.5, Timer_StartAttackWave);
		Waves_UpdateMvMStats();
		return Plugin_Stop;
	}
	
	CurrentRisk += RiskIncrease - 1;
	CurrentAttacks++;
	CurrentMidRaise = false;
	
	// Clear out existing enemies
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(GetTeam(entity) != TFTeam_Red && !b_StaticNPC[entity])
				SmiteNpcToDeath(entity);
		}
	}

	int bonusRisk;

	AttackInfo attack;
	if(CurrentAttacks > MaxAttacks)
	{
		// Final Boss
		bonusRisk = GetRiskAttackInfo(RiskList.Length - 1, attack, true);
	}
	else
	{
		bonusRisk = GetRiskAttackInfo(CurrentRisk, attack);
	}

	StartAttack(attack, CurrentAttacks > MaxAttacks ? 3 : 2, Construction_GetBaseBuilding(), bonusRisk);

	if(CurrentAttacks > MaxAttacks)
	{
		NextAttackAt = 0.0;
		GameTimer = null;
	}
	else
	{
		NextAttackAt = GetGameTime() + AttackTime;
		GameTimer = CreateTimer(0.5, Timer_StartAttackWave);
	}
	return Plugin_Stop;
}

static int GetRiskAttackInfo(int risk, AttackInfo attack, bool custom = false)
{
	int setRisk = risk;
	if(!custom)
	{
		if(setRisk < 0)
		{
			setRisk = 0;
		}
		else if(setRisk >= HighestRisk)
		{
			setRisk = HighestRisk - 1;
		}
	}
	
	GetListAttackInfo(RiskList.Get(setRisk), attack);

	// Risk above Highest
	if(custom)
	{
		setRisk = CurrentRisk - HighestRisk;
		if(setRisk < 0)
			setRisk = 0;
	}
	else
	{
		setRisk = risk - HighestRisk;
		if(setRisk < 0)
			setRisk = 0;
	}
	
	return setRisk;
}

static void GetListAttackInfo(ArrayList list, AttackInfo attack)
{
	ArrayList found = new ArrayList();

	int length = list.Length;
	for(int i; i < length; i++)
	{
		list.GetArray(i, attack);
		if(!attack.Key[0])
			continue;

		if(Construction_HasNamedResearch(attack.Key) || Rogue_HasNamedArtifact(attack.Key))
			found.Push(i);
	}

	if(found.Length == 0)
	{
		for(int i; i < length; i++)
		{
			list.GetArray(i, attack);
			if(attack.Key[0])
				continue;

			found.Push(i);
		}
	}

	length = found.Length;
	if(length)
		list.GetArray(found.Get(GetURandomInt() % length), attack);
	
	delete found;
}

// Start an attack based on info and the target entity
static bool StartAttack(const AttackInfo attack, int type, int target, int bonuses = 0)
{
	if(target == -1)
		return false;
	
	float pos[3];
	GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
	bool failed = !UpdateValidSpawners(pos, type);

	if(type < 2 && failed)
		return false;

	AttackType = type;
	AttackRef = EntIndexToEntRef(target);
	AttackHardcore = bonuses;

	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, attack.WaveSet);
	KeyValues kv = new KeyValues("Waves");
	kv.ImportFromFile(buffer);
	Waves_SetupWaves(kv, false);
	delete kv;

	Rogue_TriggerFunction(Artifact::FuncStageStart);
	CreateTimer(float(type * type), Waves_RoundStartTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	WaveStart_SubWaveStart(GetGameTime() + AttackTime - 523.0);
	return true;
}

void Construction_BattleVictory()
{
	int type = AttackType;
	AttackType = 0;

	if(type > 1)
	{
		int cash = 300;
		int GetRound = Construction_GetRisk() + 3;
		cash *= GetRound;
		CPrintToChatAll("%t", "Gained Material", cash, "Cash");
		CurrentCash += cash;
		//Extra money.
		ReviveAll();
		int SpawnGiftRemains = 3;
		SpawnGiftRemains -= RemainsRaidsLeftOnMap();
		
		int Amountspawned = 0;
		for(;SpawnGiftRemains > 0; SpawnGiftRemains--)
		{
			
			int EntitySpawned;
			EntitySpawned = SpawnRandomGiftRemain();
			if(IsValidEntity(EntitySpawned))
			{
				MaterialGift npc = view_as<MaterialGift>(EntitySpawned);	
				npc.m_iMyRisk = Construction_GetRisk();
				Amountspawned++;
			}
			else
			{
				SpawnGiftRemains++;
				//Failed to spawn, retry. go go!
			}
		}
		/*if(Amountspawned > 0)
		{
			CPrintToChatAll("%t","Gifts Spawned", Amountspawned);
		}
		else
		{
			CPrintToChatAll("%t","No Gifts Spawn");
		}*/
	}

	CPrintToChatAll("%t", "Battle Finished");
	
	Waves_RoundEnd();
	bool victory = true;
	Rogue_TriggerFunction(Artifact::FuncStageEnd, victory);
	Store_RogueEndFightReset();
	Ammo_Count_Ready += (type > 1) ? 10 : 5;

	int entity = EntRefToEntIndex(AttackRef);
	if(entity != -1)
	{
		view_as<CClotBody>(entity).Anger = false;
		view_as<CClotBody>(entity).m_bCamo = false;
	}
	
	GiveRandomReward(CurrentRisk, type > 1 ? 4 : 2);
}

void GiveRandomReward(int risk, int maxDrops)
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
					if(NextAttackAt)
					{
						int time = RoundToCeil(NextAttackAt - GetGameTime());
						int flags = CurrentAttacks < MaxAttacks ? MVM_CLASS_FLAG_NORMAL : MVM_CLASS_FLAG_MINIBOSS;
						if(time < 61)
							flags += MVM_CLASS_FLAG_ALWAYSCRIT;
						
						Waves_SetWaveClass(objective, i, time, "classic_defend", flags, true);
						continue;
					}
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
					bool found;
					while(snapPos < snapLength)
					{
						static const char prefix[] = "material_";

						int size = snap.KeyBufferSize(snapPos) + strlen(prefix) + 1;
						char[] key = new char[size];
						snap.GetKey(snapPos, key, size);
						snapPos++;

						int amount;
						CurrentMaterials.GetValue(key, amount);
						if(amount > 0)
						{
							Format(key, size, "%s%s", prefix, key);
							Waves_SetWaveClass(objective, i, amount, key, MVM_CLASS_FLAG_NORMAL, true);
							found = true;
							break;
						}
					}

					if(found)
						continue;
				}
			}

			Waves_SetWaveClass(objective, i);
		}

		delete snap;
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

int Construction_GetBaseBuilding()
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && i_NpcInternalId[entity] == BaseBuilding_ID() && IsEntityAlive(entity))
			return entity;
	}

	return -1;
}

static stock int RiskBonusFromDistance(const float pos[3])
{
/*
	int entity = Construction_GetBaseBuilding();
	if(entity == -1)
		return 0;
	
	float pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);

	if(GetVectorDistance(pos, pos2, true) > 100000000.0)	// 10000 HU
		return 1;

keep it at 0*/
	return 0;
	//return RoundFloat(GetVectorDistance(pos, pos2, true) / 400000000.0 * float(HighestRisk));
}

static bool UpdateValidSpawners(const float pos1[3], int type)
{
	CNavArea goalArea = TheNavMesh.GetNavArea(pos1, 1000.0);
	if(goalArea == NULL_AREA)
	{
		CurrentSpawnName[0] = 0;
		PrintToServer("ERROR: Could not find valid nav area for location (%f %f %f)", pos1[0], pos1[1], pos1[2]);
		return false;
	}

	ArrayList list = new ArrayList();
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") != TFTeam_Red)
		{
			if(type > 1)
			{
				GetEntPropString(i_ObjectsSpawners[i], Prop_Data, "m_iName", CurrentSpawnName, sizeof(CurrentSpawnName));
				if(StrContains(CurrentSpawnName, "noraid", false) != -1)
					continue;
			}
			
			list.Push(i_ObjectsSpawners[i]);
		}
	}

	if(type > 1)
		list.Sort(Sort_Random, Sort_Integer);

	float pos2[3];
	float distance = FAR_FUTURE;
	int length = list.Length;
	for(int i; i < length; i++)
	{
		int entity = list.Get(i);

		float dist = 0.0;

		if(type < 2)
		{
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
			dist = GetVectorDistance(pos1, pos2, true);
			if(dist > distance)
				continue;
		}

		CNavArea startArea = TheNavMesh.GetNavAreaEntity(entity, view_as<GetNavAreaFlags_t>(0), 1000.0);
		if(startArea == NULL_AREA)
			continue;
		
		if(TheNavMesh.BuildPath(startArea, goalArea, pos1))
		{
			GetEntPropString(entity, Prop_Data, "m_iName", CurrentSpawnName, sizeof(CurrentSpawnName));
			distance = dist;

			if(type > 1)
				break;
		}
	}

	delete list;

	if(distance != FAR_FUTURE)
	{
		Spawners_Timer();
		return true;
	}

	CurrentSpawnName[0] = 0;
	PrintToChatAll("ERROR: Could not find valid spawner to path to location (%f %f %f)", pos1[0], pos1[1], pos1[2]);

	Spawners_Timer();
	return false;
}

void Construction_EnemySpawned(int entity)
{
	if(AttackType == 2 && AttackRiskBonus > 0 && CurrentRisk > 0)
	{
		float stats = Pow(AttackRiskBonus, float(CurrentRisk));
		fl_Extra_Damage[entity] *= stats;
		
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * stats));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * stats));
	}
	
	if(AttackType > 0 && AttackHardcore > 0)
	{
		float stats = Pow(1.06, float(AttackHardcore));
		fl_Extra_Damage[entity] *= stats;
		
		SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * stats));
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(ReturnEntityMaxHealth(entity)) * stats));
	}
}

void Construction_ClotThink(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + 2.0;

	if(AttackType && npc.m_bCamo && EntRefToEntIndex(AttackRef) != npc.index)
	{
		if(!b_NpcIsInvulnerable[npc.index])
		{
			b_ThisEntityIgnored[npc.index] = true;
			b_NpcIsInvulnerable[npc.index] = true;
			SetEntityRenderFx(npc.index, RENDERFX_DISTORT);
		}
	}
	else
	{
		if(b_NpcIsInvulnerable[npc.index])
		{
			b_ThisEntityIgnored[npc.index] = false;
			b_NpcIsInvulnerable[npc.index] = false;
			SetEntityRenderFx(npc.index, RENDERFX_NONE);
		}
	}
}

stock bool Construction_OnTakeDamageCustom(const char[] waveset, int victim, int attacker, float &damage, int damagetype)
{
	CClotBody npc = view_as<CClotBody>(victim);

	if(AttackType && npc.Anger && EntRefToEntIndex(AttackRef) != npc.index)
	{
		// No cross mining when a fight is happening
		damage = 0.0;
		return false;
	}

	if(b_NpcIsInvulnerable[victim])
	{
		// cant hurt if invincibke..
		damage = 0.0;
		return false;
	}

	if(npc.m_bCamo)
	{
		// Must provoke it
		if(attacker > 0 && attacker <= MaxClients && (damagetype & DMG_CLUB))
		{
			SetGlobalTransTarget(attacker);
			
			Menu menu = new Menu(ConstructionProvokeH);
			menu.SetTitle("%t", "Start Mining\n ", NpcStats_ReturnNpcName(victim));

			char num[16], buffer[16];
			IntToString(EntIndexToEntRef(attacker), num, sizeof(num));

			FormatEx(buffer, sizeof(buffer), "%t", "Yes");
			menu.AddItem(num, buffer);

			FormatEx(buffer, sizeof(buffer), "%t", "No");
			menu.AddItem(num, buffer);

			menu.ExitButton = false;
			menu.Display(attacker, 10);
		}

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

				//if(!(damagetype & DMG_TRUEDAMAGE))
				{
					float minDamage = damage * 0.05;
					if(!(damagetype & DMG_TRUEDAMAGE))
						damage -= float(info.Defense);
					if(damage < minDamage)
						damage = minDamage;
				}

				if(npc.Anger && RiskList)
				{
					if(AttackType)
						return false;
					
					AttackInfo attack;
					strcopy(attack.WaveSet, sizeof(attack.WaveSet), waveset);
					if(!StartAttack(attack, 1, npc.index))
						return false;
					
					return true;
				}
			}
		}
	}

	if(MultiGlobalHighHealthBoss)
		damage /= MultiGlobalHighHealthBoss;

	if(CurrentAttacks && RiskIncrease)
	{
		float multi = Pow(0.5, float(CurrentAttacks));
		damage *= multi;
	}

	return true;
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

	if(b_NpcIsInvulnerable[victim])
	{
		// cant hurt if invincibke..
		damage = 0.0;
		return false;
	}

	if(npc.m_bCamo)
	{
		// Must provoke it
		if(attacker > 0 && attacker <= MaxClients && (damagetype & DMG_CLUB))
		{
			SetGlobalTransTarget(attacker);
			
			Menu menu = new Menu(ConstructionProvokeH);
			if(b_IsAloneOnServer)
			{
				menu.SetTitle("%t", "Start Mining Alone", NpcStats_ReturnNpcName(victim));
			}
			else
			{
				menu.SetTitle("%t", "Start Mining", NpcStats_ReturnNpcName(victim));
			}

			char num[16], buffer[16];
			IntToString(EntIndexToEntRef(victim), num, sizeof(num));

			FormatEx(buffer, sizeof(buffer), "%t", "Yes");
			menu.AddItem(num, buffer);

			FormatEx(buffer, sizeof(buffer), "%t", "No");
			menu.AddItem(num, buffer);

			menu.ExitButton = false;
			menu.Display(attacker, 10);
		}

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

				//if(!(damagetype & DMG_TRUEDAMAGE))
				{
					float minDamage = damage * 0.05;
					if(!(damagetype & DMG_TRUEDAMAGE))
						damage -= float(info.Defense);
					if(damage < minDamage)
						damage = minDamage;

						
					float MaxDamage = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

					MaxDamage /= 25.0;
					if(damage > MaxDamage)
						damage = MaxDamage;

				}

				if(npc.Anger && RiskList)
				{
					if(AttackType)
						return false;
					
					float pos[3];
					GetEntPropVector(npc.index, Prop_Data, "m_vecOrigin", pos);
					int risk = CurrentRisk + RiskBonusFromDistance(pos);

					AttackInfo attack;
					if(!StartAttack(attack, 1, npc.index, GetRiskAttackInfo(risk, attack)))
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

	if(MultiGlobalHighHealthBoss)
		damage /= MultiGlobalHighHealthBoss;

	if(CurrentAttacks && RiskIncrease)
	{
		float multi = Pow(0.5, float(CurrentAttacks));
		damage *= multi;
	}

	if(Construction_Mode() && maxAmount)
		ResourceBasedOnHealth(resource, maxAmount, npc, GetEntProp(npc.index, Prop_Data, "m_iHealth") - RoundToCeil(damage), GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

	return true;
}

static int ConstructionProvokeH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			if(choice == 0)
			{
				char buffer[16];
				menu.GetItem(choice, buffer, sizeof(buffer));
				
				int entity = EntRefToEntIndex(StringToInt(buffer));
				if(entity != -1)
				{
					//need atleast 2 parcitipants
					CClotBody npc = view_as<CClotBody>(entity);
					if(b_IsAloneOnServer || IsValidEntity(npc.m_iTargetWalkTo) && npc.m_iTargetWalkTo != client)
					{
						view_as<CClotBody>(entity).m_bCamo = false;
						Construction_Material_Interact(client, entity);
					}
					npc.m_iTargetWalkTo = client;
				}
			}
		}
	}
	return 0;
}

void Construction_NPCDeath(const char[] resource, int maxAmount, CClotBody npc)
{
	ResourceBasedOnHealth(resource, maxAmount, npc, 0, 100);
}

static void ResourceBasedOnHealth(const char[] resource, int maxAmount, CClotBody npc, int health, int maxhealth)
{
	if(Construction_Mode() && maxhealth)
	{
//		PrintToChatAll("maxAmount %i",maxAmount);
		int newAmount = maxAmount - (health * maxAmount / maxhealth) - 1;
//		PrintToChatAll("newAmount1 %i",newAmount);
		if(newAmount > maxAmount)
			newAmount = maxAmount;
		
//		PrintToChatAll("newAmount2 %i",newAmount);
		int AmountOfTimesToWarn = 0;
		while(newAmount > npc.g_TimesSummoned)
		{
			npc.g_TimesSummoned++;
			AmountOfTimesToWarn++;
		}
		if(AmountOfTimesToWarn != 0)
			Construction_AddMaterial(resource, AmountOfTimesToWarn);
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
//	PrintToChatAll("short %s gain %i silent %b",short, gain, silent);
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
	
	int entity = Construction_GetBaseBuilding();
	if(entity == -1)
		return 0.0;
	
	float pos1[3], pos2[3];
	GetClientEyePosition(client, pos1);
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
	float distance = GetVectorDistance(pos1, pos2);
	distance = distance / 3000.0;
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

void Construction_GiveNamedResearch(const char[] name, bool silent = false)
{
	if(!CurrentResearch)
		CurrentResearch = new ArrayList(ByteCountToCells(48));

	CurrentResearch.PushString(name);

	if(!silent)
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "%s Desc", name);
		CPrintToChatAll("%t", "Finish Research Desc", name, buffer);
	}
}

bool Construction_HasNamedResearch(const char[] name)
{
	if(CurrentResearch)
	{
		char buffer[64];
		int length = CurrentResearch.Length;
		for(int i; i < length; i++)
		{
			CurrentResearch.GetString(i, buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
				return true;
		}
	}
	return false;
}

void Construction_OpenResearch(int client)
{
	SetGlobalTransTarget(client);

	Menu menu = new Menu(ResearchMenuH);
	AnyMenuOpen[client] = 1.0;

	ResearchInfo info;
	char index[16], buffer[128];

	if(InResearch == -1)
	{
		if(b_IsAloneOnServer)
		{
			menu.SetTitle("%t\n \n%t", "Research Station", "Crouch and select to view description Alone");

		}
		else
		{
			menu.SetTitle("%t\n \n%t", "Research Station", "Crouch and select to view description");
		}

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
				{
					if(!Rogue_HasNamedArtifact(info.Key))
						continue;
				}
			}

			bool VotedAlready = false;
			for(int clientloop = 1; clientloop <= MaxClients; clientloop++)
			{
				if(IsClientInGame(clientloop) && GetClientTeam(clientloop) == 2)
				{
					if(info.Res_InternalID == PlayerVotedForThis[clientloop] && client != clientloop)
					{
						VotedAlready = true;
					}
				}
			}
			if(b_IsAloneOnServer)
			{
				VotedAlready = true;
			}
			FormatEx(buffer, sizeof(buffer), "%t", info.Name);
			if(VotedAlready)
			{
				Format(buffer, sizeof(buffer), "%s [✓]", buffer);
			}
			else
			{
				Format(buffer, sizeof(buffer), "%s [ ]", buffer);
			}

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
			if(++items > 6)
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
			menu.AddItem("-1", buffer, ITEMDRAW_DISABLED);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Claim Research");
			menu.AddItem("-1", buffer);
		}
	}

	menu.Pagination = 0;
	menu.ExitButton = true;
	if(menu.Display(client, MENU_TIME_FOREVER))
		InResearchMenu[client] = CreateTimer(1.0, ResearchTimer, client);
}

static Action ResearchTimer(Handle timer, int client)
{
	if(IsValidClient(client))
	{
		InResearchMenu[client] = null;
		Construction_OpenResearch(client);
	}
	return Plugin_Continue;
}

static int ResearchMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Cancel:
		{
			delete InResearchMenu[client];
			AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			delete InResearchMenu[client];
			AnyMenuOpen[client] = 0.0;
			
			ResearchInfo info;
			char buffer[64];

			if(InResearch == -1)
			{
				menu.GetItem(choice, buffer, sizeof(buffer));

				int a = StringToInt(buffer);
				if(a < 0)
					return 0;

				ResearchList.GetArray(a, info);

				bool VotedAlready = false;
				for(int clientloop = 1; clientloop <= MaxClients; clientloop++)
				{
					if(IsClientInGame(clientloop) && GetClientTeam(clientloop) == 2 && client != clientloop)
					{
						if(info.Res_InternalID == PlayerVotedForThis[clientloop])
						{
							VotedAlready = true;
						}
					}
				}
				if(b_IsAloneOnServer)
					VotedAlready = true;

				PlayerVotedForThis[client] = info.Res_InternalID;

				if(!VotedAlready || GetClientButtons(client) & IN_DUCK)
				{
					FormatEx(buffer, sizeof(buffer), "%s Desc", info.Name);
					CPrintToChat(client, "%t", "Artifact Info", info.Name, buffer);
					if(!VotedAlready)
					{
						CPrintToChat(client, "%t", "Player Must Agree");
					}
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
				Rogue_GiveNamedArtifact(info.Name, true, true);
			}

			Construction_OpenResearch(client);
		}
	}
	return 0;
}

float Construction_GetMaxHealthMulti()
{
	float multi = 1.5;	// Construction Novice
	multi *= 1.65;	// Construction Apprentice

	if(Construction_HasNamedResearch("Base Level I"))
	{
		multi *= 1.65;	// Construction Worker
	}

	if(Construction_HasNamedResearch("Base Level II"))
	{
		multi *= 1.7;	// Construction Expert
	}

	if(Construction_HasNamedResearch("Base Level III"))
	{
		multi *= 1.4;	// Construction Master
	}

	if(Construction_HasNamedResearch("Base Level IV"))
	{
		multi *= 1.7;	// Wildingen's Elite Building Components
	}

	return multi;
}

static bool BuildingDetected;
stock bool Construction_IsBuildingInWay(const float pos1[3],const float mins[3],const float maxs[3])
{
	BuildingDetected = false;
	TR_EnumerateEntitiesHull(pos1, pos1, mins, maxs, PARTITION_TRIGGER_EDICTS, BuildingDetected_Enumerate, _);
	return BuildingDetected;
}
public bool BuildingDetected_Enumerate(int entity, int client)
{
	if(IsValidEntity(entity) && (i_IsABuilding[entity] || b_ThisWasAnNpc[entity] || IsValidClient(entity)))
	{
		BuildingDetected = true;
	}
	return false;
}

#include "roguelike/construction_items.sp"
//#include "roguelike/construction_construction.sp"
