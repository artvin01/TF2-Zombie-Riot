#pragma semicolon 1
#pragma newdecls required

static bool ArenaMode;
static bool Started;
static Handle GameTimer;
static ArrayList SpecialRounds;
static Function CurrentSpecial = INVALID_FUNCTION;
static StringMap TeamPoints;
static int RoundCount;
static bool FreeForAll;
static bool PostRound;
static int GregHandicap;
static bool AlwaysSpecial;
static ArrayList MusicList;
static Handle WaitingTimer;

public bool Arena_Mode()
{
	return ArenaMode;
}

bool Arena_Started()
{
	return Arena_Mode() && Started;
}

stock bool Arena_FreeForAll()
{
	return Arena_Mode() && FreeForAll;
}

int Arena_GetRound()
{
	return (RoundCount + 1) * 10;
}

void Arena_MapStart()
{
	ArenaMode = false; 
	Arena_RoundEnd();
}

// Waves_SetupVote
void Arena_SetupVote(KeyValues kv)
{
	PrecacheMvMIconCustom("classic_defend", false);
	PrecacheMvMIconCustom("robo_extremethreat");
	PrecacheSound("ui/chime_rd_2base_pos.wav");
	PrecacheSound("ui/chime_rd_2base_neg.wav");
	PrecacheSound("ui/itemcrate_smash_rare.wav");

	ArenaMode = true;

	delete SpecialRounds;

	MusicEnum music;
	if(MusicList)
	{
		int length = MusicList.Length;
		for(int i; i < length; i++)
		{
			MusicList.GetArray(i, music);
			music.Clear();
		}
		delete MusicList;
	}

	SpecialRounds = new ArrayList(ByteCountToCells(256));
	MusicList = new ArrayList(sizeof(MusicEnum));

	MVMHud_Disable();

	Rogue_SetupVote(kv, "Arena");

	char buffer[PLATFORM_MAX_PATH];
	FreeForAll = view_as<bool>(kv.GetNum("freeforall"));
	
	if(kv.JumpToKey("SpecialRounds"))
	{
		if(kv.GotoFirstSubKey(false))
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				SpecialRounds.PushString(buffer);
			}
			while(kv.GotoNextKey(false));

			kv.GoBack();
		}

		kv.GoBack();
	}
	
	if(kv.JumpToKey("RandomMusic"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				if(music.SetupKv("", kv))
					MusicList.PushArray(music);
			}
			while(kv.GotoNextKey());
		}

		kv.GoBack();
	}

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
void Arena_StartSetup()
{
	Rogue_StartSetup();

	s_MissionClient = "{gray}Onsian";

	//Just incase, reget spawnsers, beacuse its way too fast and needs a frame, start setup is too fast!
	for (int ent = -1; (ent = FindEntityByClassname(ent, "info_player_teamspawn")) != -1;) 
	{
		SDKHook_TeamSpawn_SpawnPostInternal(ent, _, _, _);
	}
	
	Ammo_Count_Ready = 20;

	if(!FreeForAll)
	{
		int amount;
		int[] clients = new int[MaxClients];
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) > 1)
			{
				clients[amount++] = client;
			}
		}

		SortIntegers(clients, amount, Sort_Random);
		
		if(amount > 2)
		{
			for(int i; i < amount; i++)
			{
				int team = (i % 2) ? TFTeam_Blue : TFTeam_Red;
				if(GetClientTeam(clients[i]) != team)
				{
					int state = GetEntProp(clients[i], Prop_Send, "m_lifeState");
					SetEntProp(clients[i], Prop_Send, "m_lifeState", 2);
					ChangeClientTeam(clients[i], team);
					SetEntProp(clients[i], Prop_Send, "m_lifeState", state);
					DHook_RespawnPlayer(clients[i]);
				}
			}
		}
		
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
				SmiteNpcToDeath(entity);
		}
		
		Citizen_SpawnAtPoint("b", .team = 2);
		Citizen_SpawnAtPoint("a", .team = 3);
	}

	delete WaitingTimer;
	WaitingTimer = CreateTimer(1.0, Timer_WaitingPeriod, _, TIMER_REPEAT);
}

static Action Timer_WaitingPeriod(Handle timer)
{
	if(CvarInfiniteCash.BoolValue)
		return Plugin_Continue;
	
	float pos1[3], pos2[3];
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			int team = GetTeam(client);
			for(int i; i < ZR_MAX_SPAWNERS; i++)
			{
				if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == team && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
				{
					GetEntPropVector(i_ObjectsSpawners[i], Prop_Data, "m_vecOrigin", pos1);
					break;
				}
			}

			GetClientAbsOrigin(client, pos2);
			if(GetVectorDistance(pos1, pos2, true) > 300000.0)
			{
				Vehicle_Exit(client, false, false);
				TeleportEntity(client, pos1, {0.0, 0.0, 0.0}, NULL_VECTOR);
			}
		}
	}
	
	return Plugin_Continue;
}

// OnRoundEnd
void Arena_RoundEnd()
{
	Started = false;
	PostRound = false;
	RoundCount = 0;
	GregHandicap = 0;
	delete GameTimer;
	delete WaitingTimer;
	delete TeamPoints;
}

// Rogue_RoundStartTimer()
void Arena_Start()
{
	// First setup is done, game starts
	Started = true;
	delete WaitingTimer;
}

// OnStateUpdate
void Arena_StateUpdate(int readystate)
{
	// Team-based ready up
	if(Arena_Mode() && !Rogue_VoteActive() && !Started && readystate)
	{
		bool ready1 = true;
		bool ready2 = true;

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && !IsFakeClient(client))
			{
				int team = GetClientTeam(client);
				switch(team)
				{
					case TFTeam_Red:
						ready1 = false;
					
					case TFTeam_Blue:
						ready2 = false;
				}
			}
		}

		if(GameRules_GetProp("m_bTeamReady", 1, TFTeam_Red))
			ready1 = true;

		if(GameRules_GetProp("m_bTeamReady", 1, TFTeam_Blue))
			ready2 = true;

		if(ready1 && ready2 && GameRules_GetPropFloat("m_flRestartRoundTime") < 0)
		{
			Event event = CreateEvent("teamplay_round_restart_seconds");
			event.SetInt("seconds", 10.0);
			event.Fire();
			/*
			delete GameTimer;
			GameTimer = CreateTimer(10.0, ArenaGameTimer, 2);
			SpawnTimer(10.0);
			Waves_ForceSetup(10.0);
			GameRules_SetProp("m_bInWaitingForPlayers", false);
			*/
		}
	}
}

// OnAllTeamReady
Action Arena_AllTeamsReady(int &time = 0)
{
	if(!Arena_Mode())
		return Plugin_Continue;

	if(Rogue_VoteActive())
	{
		float ftime = Rogue_VoteGameTime() + 10.0;
		GameRules_SetPropFloat("m_flRestartRoundTime", ftime);
		time = RoundFloat(ftime - GetGameTime());
	}
	else
	{
		GameRules_SetPropFloat("m_flRestartRoundTime", GetGameTime() + 10.0);
		time = 10;
	}

	delete GameTimer;
	GameTimer = CreateTimer(0.1, ArenaGameTimer, 0);
	return Plugin_Changed;
}

static Action ArenaGameTimer(Handle timer, int mode)
{
	GameTimer = null;
	PostRound = false;
	
	switch(mode)
	{
		case 1:	// Round Setup
		{
			DisableRandomMusic();
			
			RoundCount++;

			int preRound = (RoundCount) * 10;
			int postRound = (RoundCount + 1) * 10;
			for(int i = preRound; i < postRound; i++)
			{
				if(i >= sizeof(DefaultWaveCash))
					break;
				
				CurrentCash += DefaultWaveCash[i];
			}

			if(RoundCount == 1)
			{
				GrigoriMaxSells = 6;
				Spawn_Cured_Grigori(GregHandicap == 0 ? 0 : ((GregHandicap % 2) ? TFTeam_Red : TFTeam_Blue));
			}

			Store_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE);

			Waves_SetReadyStatus(1);

			RespawnCheckCitizen();

			// Force respawn back to spawn
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
					TeutonType[client] = TEUTON_DEAD;
			}

			ReviveAll();
			WaveEndLogicExtra();

			CreateTimer(0.2, TeleportAlliedNPCs, _, TIMER_FLAG_NO_MAPCHANGE);

			delete WaitingTimer;
			WaitingTimer = CreateTimer(1.0, Timer_WaitingPeriod, _, TIMER_REPEAT);

			return Plugin_Continue;
		}
		case 2:	// Round Start
		{
			delete WaitingTimer;
			Waves_SetReadyStatus(0);
			WaveStart_SubWaveStart(GetGameTime() - 300.0);
			SetRandomMusic();
			Ammo_Count_Ready += 10;

			ExcuteRelay("zr_arenastart");

			int entity = -1;
			while((entity=FindEntityByClassname(entity, "func_door*")) != -1)
			{
				AcceptEntityInput(entity, "Open");
			}

			while((entity=FindEntityByClassname(entity, "prop_door*")) != -1)
			{
				AcceptEntityInput(entity, "Open");
			}

			CreateTimer(1.0, UpdateNavBlockers, _, TIMER_FLAG_NO_MAPCHANGE);

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
				{
					HealEntityGlobal(client, client, 9999.9, 1.0, 2.0, HEAL_ABSOLUTE);
					GiveArmorViaPercentage(client, 6.0, 1.0);
				}
			}

			if(AlwaysSpecial || (GregHandicap && (GetURandomInt() % 2)))
			{
				int rand = SpecialRounds.Length;
				if(rand)
				{
					rand = GetURandomInt() % rand;
					
					char buffer[256];
					SpecialRounds.GetString(rand, buffer, sizeof(buffer));

					CurrentSpecial = GetFunctionByName(null, buffer);
					if(CurrentSpecial != INVALID_FUNCTION)
					{
						Call_StartFunction(null, CurrentSpecial);
						Call_PushCell(false);
						Call_Finish();
					}
				}
			}

			if(!FreeForAll)
			{
				int balance;

				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
					{
						if(GetClientTeam(client) == 2)
						{
							balance++;
						}
						else
						{
							balance--;
						}
					}
				}

				while(balance != 0)
				{
					Citizen_SpawnAtPoint("temp", .team = (balance > 0 ? TFTeam_Blue : TFTeam_Red));

					if(balance > 0)
					{
						balance--;
					}
					else
					{
						balance++;
					}
				}
			}
		}
		case 3:	// Game Over
		{
			if(TeamPoints)
			{
				StringMapSnapshot snap = TeamPoints.Snapshot();

				int points;
				int length = snap.Length;
				for(int i; i < length; i++)
				{
					int size = snap.KeyBufferSize(i);
					char[] key = new char[size];
					snap.GetKey(i, key, size);
					TeamPoints.GetValue(key, points);
					if(FreeForAll)
					{
						CPrintToChatAll("{orange}%s - %d wins", key, points);
					}
					else
					{
						CPrintToChatAll("{orange}Team %d - %d wins", StringToInt(key) - 1, points);
					}
				}

				delete snap;
			}

			ForcePlayerLoss(false);
			return Plugin_Continue;
		}
		default:
		{
			if(Started)
			{
				CheckAlivePlayers();
			}
			else
			{
				float startTime = GameRules_GetPropFloat("m_flRestartRoundTime");
				if(startTime < 0.0)
					return Plugin_Continue;
				
				if((startTime - 0.3) < GetGameTime())
				{
					GameRules_SetPropFloat("m_flRestartRoundTime", -1.0);

					delete GameTimer;
					GameTimer = CreateTimer(0.1, ArenaGameTimer, 2);
					Waves_ForceSetup(0.1);
					GameRules_SetProp("m_bInWaitingForPlayers", false);
				}
			}
		}
	}

	if(GameTimer == null)
		GameTimer = CreateTimer(Started ? 3.0 : 0.1, ArenaGameTimer, 0);

	return Plugin_Continue;
}

static Action TeleportAlliedNPCs(Handle timer)
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			int team = GetTeam(entity);
			if(team == 2 || team == 3)
			{
				TeleportAlliedNPC(entity);
			}
			else
			{
				SmiteNpcToDeath(entity);
			}
		}
	}

	return Plugin_Continue;
}

static void TeleportAlliedNPC(int npc)
{
	int count;
	int[] list = new int[i_MaxcountSpawners];

	int team = GetTeam(npc);
	for(int i; i < i_MaxcountSpawners; i++)
	{
		int entity = i_ObjectsSpawners[i];
		if(IsValidEntity(entity))
		{
			if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetTeam(entity) == team)
				list[count++] = entity;
		}
	}
	
	if(!count)
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target) && GetTeam(target) == team)
				list[count++] = target;
		}
	}
	
	if(count)
	{
		float pos[3], ang[3];
		int entity = list[GetURandomInt() % count];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		TeleportEntity(npc, pos, ang);
	}
}

// Waves_SetReadyStatus
void Arena_SetReadyStatus(int status)
{
	switch(status)
	{
		case 0:
		{
			return;
		}
		case 1:	// Ready Up -> 60s Setup Time
		{
			if(Started)
			{
				delete GameTimer;
				GameTimer = CreateTimer(60.0, ArenaGameTimer, 2);
				SpawnTimer(60.0);
				Waves_ForceSetup(60.0);
				GameRules_SetProp("m_bInWaitingForPlayers", false);
			}
		}
	}

	int entity = -1;
	while((entity=FindEntityByClassname(entity, "func_door*")) != -1)
	{
		AcceptEntityInput(entity, "Close");
	}

	while((entity=FindEntityByClassname(entity, "prop_door*")) != -1)
	{
		AcceptEntityInput(entity, "Close");
	}
}

static Action UpdateNavBlockers(Handle timer)
{
	Recalculate_NavBlockers();
	return Plugin_Continue;
}

// CheckAlivePlayers
void Arena_CheckAlivePlayers(int killed)
{
	if(!Started || PostRound || Waves_InSetup())
		return;
	
	int colorRef;
	ArrayList aliveTeams = new ArrayList();

	// Alive check
	for(int client = 1; client <= MaxClients; client++)
	{
		if(killed == client || !IsClientInGame(client))
			continue;
		
		if(!IsPlayerAlive(client) || TeutonType[client] != TEUTON_NONE)
			continue;
		
		if(dieingstate[client] != 0)
			continue;

		int team = GetTeam(client);
		if(aliveTeams.FindValue(team) == -1)
			aliveTeams.Push(team);
		
		colorRef = client;
	}

	bool forceEnd = aliveTeams.Length < 1;
	
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(b_NpcHasDied[entity] || b_ThisEntityIgnored[entity] || b_thisNpcIsAMiniboss[entity])
			continue;
		
		if(Citizen_ThatIsDowned(entity))
			continue;
		
		int team = GetTeam(entity);
		if(aliveTeams.FindValue(team) == -1)
			aliveTeams.Push(team);
	}

	// Kill all downed players with no more alive teammates
	for(int target = 1; target <= MaxClients; target++)
	{
		if(killed == target || !IsClientInGame(target))
			continue;
		
		if(!IsPlayerAlive(target) || TeutonType[target] != TEUTON_NONE)
			continue;
		
		if(dieingstate[target] == 0)
			continue;

		int team = GetTeam(target);
		if(aliveTeams.FindValue(team) == -1)
			ForcePlayerSuicide(target);
	}

	int length = aliveTeams.Length;
	if(length > 1 && !forceEnd)
	{
		delete aliveTeams;
		return;	// 2+ teams alive
	}

	bool end = RoundCount > 3;
	int winningTeam = length != 1 ? -1 : aliveTeams.Get(0);

	if(winningTeam == -1)
	{
		CPrintToChatAll("{gray}Draw{default}, you're all losers!");
	}
	else
	{
		if(!TeamPoints)
			TeamPoints = new StringMap();
	
		char buffer[64];
		if(FreeForAll)
		{
			GetClientName(colorRef, buffer, sizeof(buffer));
		}
		else
		{
			IntToString(winningTeam, buffer, sizeof(buffer));
		}
		
		int points;
		TeamPoints.GetValue(buffer, points);
		points++;
		TeamPoints.SetValue(buffer, points);

		GregHandicap = winningTeam;

		if(points > 2)
			end = true;
		
		if(colorRef == 0)
		{
			CPrintToChatAll("{orange}Team %d {default}won this round! ({orange}%d {default}win%s)", winningTeam - 1, points, points == 1 ? "" : "s");
		}
		else if(FreeForAll)
		{
			CPrintToChatAllEx(colorRef, "{teamcolor}%N {default}won this round! ({teamcolor}%d {default}win%s)", colorRef, points, points == 1 ? "" : "s");
		}
		else
		{
			CPrintToChatAllEx(colorRef, "{teamcolor}Team %d {default}won this round! ({teamcolor}%d {default}win%s)", winningTeam - 1, points, points == 1 ? "" : "s");
		}
	}

	for(int target = 1; target <= MaxClients; target++)
	{
		if(killed == target || !IsClientInGame(target))
			continue;
		
		if(!IsPlayerAlive(target))
			continue;
		
		if(GetTeam(target) == winningTeam)
			TF2_AddCondition(target, TFCond_CritOnFlagCapture, 9.9);
	}

	PostRound = true;

	delete GameTimer;
	GameTimer = CreateTimer(5.0, ArenaGameTimer, end ? 3 : 1);
	Waves_ApplyCooldown(0.0);

	delete aliveTeams;

	if(CurrentSpecial != INVALID_FUNCTION)
	{
		Call_StartFunction(null, CurrentSpecial);
		Call_PushCell(true);
		Call_Finish();

		CurrentSpecial = INVALID_FUNCTION;
	}
}

// Dhook_TeleportToCenter
void Arena_TeleportToCenter(int client)
{
	int found;
	for(int i; i < ZR_MAX_SPAWNERS; i++)
	{
		if(IsValidEntity(i_ObjectsSpawners[i]) && GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_iTeamNum") == GetTeam(client) && !GetEntProp(i_ObjectsSpawners[i], Prop_Data, "m_bDisabled"))
		{
			found = i_ObjectsSpawners[i];
			break;
		}
	}
	
	if(found)
	{
		float pos[3], ang[3];
		GetEntPropVector(found, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(found, Prop_Data, "m_angRotation", ang);

		ang[1] = 0.0;
		ang[2] = 0.0;
		SetEntProp(client, Prop_Send, "m_bDucked", true);
		SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
		TeleportEntity(client, pos, ang, NULL_VECTOR);
	}
}

void Arena_AntiStalled()
{
	float redPos[3], redAng[3], bluPos[3], bluAng[3];
	Arena_GetCenterSpawnPoint(redPos, redAng, TFTeam_Red);
	Arena_GetCenterSpawnPoint(redPos, redAng, TFTeam_Blue);

	for(int i; i < 4; i++)
	{
		int entity = NPC_CreateByName("npc_chaos_swordsman", 0, i > 1 ? bluPos : redPos, i > 1 ? bluAng : redAng, TFTeam_Stalkers);
		if(entity != -1)
		{
			SetEntProp(entity, Prop_Data, "m_iHealth", 9999999);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", 9999999);

			b_thisNpcIsABoss[entity] = true;
			b_NoHealthbar[entity] = 1;
			fl_Extra_Damage[entity] = 99999.9;
			b_ThisNpcIsImmuneToNuke[entity] = true;
			b_thisNpcIsAMiniboss[entity] = true;
		}
	}
}

bool Arena_GetCenterSpawnPoint(float pos[3], float ang[3], int team = 0)
{
	int count;
	int[] list = new int[i_MaxcountSpawners];
	
	int entity = FindEntityByClassname(-1, "team_control_point");
	if(entity != -1)
	{
		list[count++] = entity;
	}

	if(!count && team != 0)
	{
		for(int i; i < i_MaxcountSpawners; i++)
		{
			entity = i_ObjectsSpawners[i];
			if(IsValidEntity(entity))
			{
				if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetTeam(entity) == team)
					list[count++] = entity;
			}
		}
	}
	
	if(!count && team != 0)
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target) && GetTeam(target) == team)
				list[count++] = target;
		}
	}
	
	if(!count)
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(IsClientInGame(target) && IsPlayerAlive(target))
				list[count++] = target;
		}
	}

	if(!count)
		return false;
	
	entity = list[GetURandomInt() % count];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	return true;
}

static void DisableRandomMusic()
{
	MusicEnum music;
	int length = MusicList.Length;
	if(length)
	{
		MusicList.GetArray(GetURandomInt() % length, music);
		
		int time = GetTime() + 2;
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, time);
			}
		}

		BGMusicSpecial1.Clear();
	}
}

static void SetRandomMusic()
{
	int length = MusicList.Length;
	if(length)
	{
		MusicEnum music;
		MusicList.GetArray(GetURandomInt() % length, music);
		
		int time = GetTime();
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!b_IsPlayerABot[client] && IsClientInGame(client))
			{
				Music_Stop_All(client);
				SetMusicTimer(client, time);
			}
		}

		music.CopyTo(BGMusicSpecial1);
	}
}

public void Arena_AlwaysSpecial_Collect()
{
	AlwaysSpecial = true;
}

public void Arena_AlwaysSpecial_Remove()
{
	AlwaysSpecial = false;
}

public void Arena_Turbolences_Collect()
{
	CurrentCash += 50000;
	Modifier_Collect_Turbolences();
}

#include "roguelike/arena_specials.sp"