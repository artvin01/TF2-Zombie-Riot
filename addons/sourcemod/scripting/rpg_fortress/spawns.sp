#pragma semicolon 1
#pragma newdecls required

#define LOW	0
#define HIGH	1

enum struct SpawnEnum
{
	int Index;
	char Zone[32];
	bool Touching[MAXPLAYERS];
	float Pos[3];
	float Angle;
	int Count;
	float Time;
	
	int LowLevelClientAreaCount;
	
	char CustomName[64];
	bool Boss;
	int Level[2];
	int Health[2];
	int XP[2];
	int Cash[2];
	int HPRegen[2];
	float DropMulti;

	float ExtraMeleeRes;
	float ExtraRangedRes;
	float ExtraSpeed;
	float ExtraDamage;
	float ExtraSize;
	
	char Item1[48];
	float Chance1;
	
	char Item2[48];
	float Chance2;
	
	char Item3[48];
	float Chance3;

	char Item4[48];
	float Chance4;
	
	float NextSpawnTime;

	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Item1, 48);
		ExplodeStringFloat(this.Item1, " ", this.Pos, sizeof(this.Pos));

		kv.GetString("name", this.Item1, 48);

		this.LowLevelClientAreaCount = 0;

		this.Index = NPC_GetByPlugin(this.Item1);

		kv.GetString("custom_name", this.CustomName, 64);
		
		this.Angle = kv.GetFloat("angle", -1.0);
		this.Count = kv.GetNum("count", 1);
		this.Time = kv.GetFloat("time");
		this.Boss = view_as<bool>(kv.GetNum("boss"));
		this.DropMulti = kv.GetFloat("high_drops", 1.0);

		this.Level[LOW] = kv.GetNum("level", kv.GetNum("low_level"));
		this.Health[LOW] = kv.GetNum("health", kv.GetNum("low_health"));
		this.XP[LOW] = kv.GetNum("xp", kv.GetNum("low_xp"));
		this.Cash[LOW] = kv.GetNum("cash", kv.GetNum("low_cash"));
		this.HPRegen[LOW] = kv.GetNum("hpregen", kv.GetNum("low_hpregen"));

		this.Level[HIGH] = kv.GetNum("level", kv.GetNum("high_level"));
		this.Health[HIGH] = kv.GetNum("health", kv.GetNum("high_health"));
		this.XP[HIGH] = kv.GetNum("xp", kv.GetNum("high_xp"));
		this.Cash[HIGH] = kv.GetNum("cash", kv.GetNum("high_cash"));
		this.HPRegen[HIGH] = kv.GetNum("hpregen", kv.GetNum("high_hpregen"));

		this.ExtraMeleeRes = kv.GetFloat("extra_melee_res", 1.0);
		this.ExtraRangedRes = kv.GetFloat("extra_ranged_res", 1.0);
		this.ExtraSpeed = kv.GetFloat("extra_speed", 1.0);
		this.ExtraDamage = kv.GetFloat("extra_damage", 1.0);
		this.ExtraSize = kv.GetFloat("extra_size", 1.0);

		kv.GetString("drop_name_1", this.Item1, 48);
		if(this.Item1[0])
			this.Chance1 = kv.GetFloat("drop_chance_1", 1.0);

		kv.GetString("drop_name_2", this.Item2, 48);
		if(this.Item2[0])
			this.Chance2 = kv.GetFloat("drop_chance_2", 1.0);

		kv.GetString("drop_name_3", this.Item3, 48);
		if(this.Item3[0])
			this.Chance3 = kv.GetFloat("drop_chance_3", 1.0);

		kv.GetString("drop_name_4", this.Item4, 48);
		if(this.Item4[0])
			this.Chance4 = kv.GetFloat("drop_chance_4", 1.0);
	}

	void DoAllDrops(int client, float pos[3], int level)
	{
		float multi = 1.0;
		if(this.Level[HIGH] > this.Level[LOW])
			multi = float(level - this.Level[LOW]) / float(this.Level[HIGH] - this.Level[LOW]) * this.DropMulti;
		
		float luck = 1.0 + (float(Stats_Luck(client)) / 300.0);
		
		if(this.Item1[0])
			RollItemDrop(client, this.Item1, (this.Chance1 * multi) * luck, pos);
		
		if(this.Item2[0])
			RollItemDrop(client, this.Item2, (this.Chance2 * multi) * luck, pos);
		
		if(this.Item3[0])
			RollItemDrop(client, this.Item3, (this.Chance3 * multi) * luck, pos);

		if(this.Item4[0])
			RollItemDrop(client, this.Item4, (this.Chance4 * multi) * luck, pos);

	}
}

static ArrayList SpawnList;
static StringMap DespawnTimers;
static Handle h_SpawnTimer;
static int SpawnCycle;

void Spawns_PluginStart()
{
	RegConsoleCmd("rpg_spawns", Spawns_Command);
}

void Spawns_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "spawns");
	KeyValues kv = new KeyValues("Spawns");
	kv.ImportFromFile(buffer);
	
	delete SpawnList;
	SpawnList = new ArrayList(sizeof(SpawnEnum));

	SpawnEnum spawn;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(spawn.Zone, sizeof(spawn.Zone));

		if(kv.GotoFirstSubKey())
		{
			do
			{
				spawn.SetupEnum(kv);
				SpawnList.PushArray(spawn);
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
	}
	while(kv.GotoNextKey());

	delete kv;

	if(!h_SpawnTimer && SpawnList.Length)
		h_SpawnTimer = CreateTimer(0.35, Spawner_Timer, _, TIMER_REPEAT);
}

void Spawns_MapEnd()
{
	delete h_SpawnTimer;
	delete DespawnTimers;
}

void Spawns_ClientEnter(int client, const char[] name)
{
	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
		if(StrEqual(spawn.Zone, name))
		{  
			if(RPGSpawns_GivePrioLevel(spawn.Level[LOW], Level[client])) //Give priority to lower level players.
			{
				spawn.LowLevelClientAreaCount += 1; //Give the spawn a way to give the npcs inside itself to protect it from high levels.
			}
			spawn.Touching[client] = true;
			SpawnList.SetArray(i, spawn);
		}
	}
}

void Spawns_ClientLeave(int client, const char[] name)
{
	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
		if(StrEqual(spawn.Zone, name))
		{
			if(RPGSpawns_GivePrioLevel(spawn.Level[LOW], Level[client])) //Give priority to lower level players.
			{
				spawn.LowLevelClientAreaCount -= 1; //Remove by 1.
				if(spawn.LowLevelClientAreaCount < 0)
				{
					spawn.LowLevelClientAreaCount = 0;
				}
			}

			spawn.Touching[client] = false;
			SpawnList.SetArray(i, spawn);
		}
	}
}

void Spawns_EnableZone(const char[] name)
{
	bool start = true;

	if(DespawnTimers)
	{
		// Stop the despawn timer
		Handle timer;
		if(DespawnTimers.GetValue(name, timer))
		{
			start = false;
			delete timer;
			DespawnTimers.Remove(name);
		}
	}
	
	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
/*
		if(RPGSpawns_GivePrioLevel(spawn.Level[LOW], Level[client])) //Give priority to lower level players.
		{
			spawn.LowLevelClientAreaCount += 1; //Give the spawn a way to give the npcs inside itself to protect it from high levels.
		}
*/
		if(StrEqual(spawn.Zone, name))
			UpdateSpawn(i, spawn, start);
	}
}

bool RPGSpawns_GivePrioLevel(int spawnlevel, int playerlevel)
{
	//Extra rules: if the player is below lvl 50, then the below calcs kinda suck, so we need more extreme things.
	//as in very low level areas, 1 level makes a huge difference, being lvl 0 and going to lvl 10 is a 10x difference.
	//So we need to do this exception.
	if(spawnlevel <= 50 && playerlevel <= 50)
	{
		return true;
	}
	
	/*
		the player is atleast above their level if it was 75% reduced
		And the player isnt above their level if it was raised by 25%
		So its a range between 75 - 125 player levels if the enemy was lvl 100 that gets priority!
	*/
	
	if(spawnlevel >= ((playerlevel * 3) / 4) && spawnlevel <= ((playerlevel * 5) / 4))
	{
		return true;
	}
	//too low level, or way too high.
	return false;
}

void Spawns_DisableZone(const char[] name)
{
	if(DespawnTimers)
	{
		// Cancel current despawn timer
		Handle timer;
		if(DespawnTimers.GetValue(name, timer))
			delete timer;
	}
	else
	{
		DespawnTimers = new StringMap();
	}

	// Despawn NPCs in 4s
	Handle timer = CreateTimer(4.0, Spawner_DespawnTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	DespawnTimers.SetValue(name, timer);
}

void Spawns_DisableZoneNow(const char[] name)
{
	ArrayList list = new ArrayList();

	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
		spawn.LowLevelClientAreaCount = 0; //Reset to 0.
		if(StrEqual(spawn.Zone, name))
			list.Push(i);
	}
	
	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(list.FindValue(hFromSpawnerIndex[i]) != -1)
		{
			NPC_Despawn(i);
		}
	}

	delete list;

	if(DespawnTimers)
		DespawnTimers.Remove(name);
}

public Action Spawner_DespawnTimer(Handle timer)
{
	// Find the timer inside our StringMap
	Handle timer2;
	StringMapSnapshot snap = DespawnTimers.Snapshot();
	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i);
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		DespawnTimers.GetValue(name, timer2);

		if(timer == timer2)
		{
			// Removes the StringMap entry
			Spawns_DisableZoneNow(name);
			break;
		}
	}

	delete snap;
	
	return Plugin_Continue;
}

public Action Spawner_Timer(Handle timer)
{
	for(; SpawnCycle < SpawnList.Length; SpawnCycle++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(SpawnCycle, spawn);
		if(Zones_IsActive(spawn.Zone))
			UpdateSpawn(SpawnCycle, spawn, false);
	}
	SpawnCycle = 0;
	return Plugin_Continue;
}

static void UpdateSpawn(int pos, SpawnEnum spawn, bool start)
{
	int alive;

	if(!start)
	{
		int i = MaxClients + 1;
		while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
		{
			if(hFromSpawnerIndex[i] == pos)
			{
				if(spawn.LowLevelClientAreaCount > 0)
				{
					i_NpcIsUnderSpawnProtectionInfluence[i] = 1;
				}
				else
				{
					i_NpcIsUnderSpawnProtectionInfluence[i] = 0;
				}
				alive++;
			}
		}
	}	
	
	if(alive < spawn.Count)
	{
		int count;
		if(spawn.NextSpawnTime)
		{
			float gameTime = GetGameTime();

			float time = spawn.Time;
			int clients;
			for(int i; i < sizeof(spawn.Touching); i++)
			{
				if(spawn.Touching[i])
					clients++;
			}

			if(clients > 1)
			{
				//Theres only 3 threshholds, no more.
				switch(clients)
				{
					case 2:
						time *= 0.85;
					case 1:
						time *= 1.0;
					default:
						time *= 0.75;
				}
			}

			int limit = spawn.Count - alive;
			for(int i; i < limit; i++)
			{
				if(i >= limit)
				{
					spawn.NextSpawnTime = 0.0;
				}

				if(spawn.NextSpawnTime > gameTime)
					break;
				
				count++;
				spawn.NextSpawnTime = GetGameTime() + time;
			}
			
			if(count)
				SpawnList.SetArray(pos, spawn);
		}
		else if(start)
		{
			count = spawn.Count;
		}
		else
		{
			spawn.NextSpawnTime = GetGameTime() + spawn.Time;
			SpawnList.SetArray(pos, spawn);
		}
		
		if(count)
		{
			int diff = spawn.Level[HIGH] - spawn.Level[LOW];
			for(int i; i < count; i++)
			{
				static float ang[3];
				ang[1] = spawn.Angle;
				if(ang[1] == -1.0)
					ang[1] = GetURandomFloat() * 360.0;
				
				int entity = NPC_CreateById(spawn.Index, 0, spawn.Pos, ang, false);
				if(entity == -1)
					break;
				
				hFromSpawnerIndex[entity] = pos;
				
				int strength = 0;
				if(diff > 0)
				{
					strength = GetURandomInt() % (diff + 1);
				}
				else
				{
					diff = 1;
				}
				
				Level[entity] = spawn.Level[LOW] + strength;
				XP[entity] = GetScaledRate(spawn.XP, strength, diff);
				i_CreditsOnKill[entity] = GetScaledRate(spawn.Cash, strength, diff);
				i_HpRegenInBattle[entity] = GetScaledRate(spawn.HPRegen, strength, diff);
				b_thisNpcIsABoss[entity] = spawn.Boss;

				fl_Extra_MeleeArmor[entity] = spawn.ExtraMeleeRes;
				fl_Extra_RangedArmor[entity] = spawn.ExtraRangedRes;
				fl_Extra_Speed[entity] = spawn.ExtraSpeed;
				fl_Extra_Damage[entity] = spawn.ExtraDamage;

				if(spawn.CustomName[0])
					strcopy(c_NpcName[entity], sizeof(c_NpcName[]), spawn.CustomName);

				if(spawn.ExtraSize != 1.0)
				{
					float scale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
					SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale * spawn.ExtraSize);
				}

				int health;
				if(spawn.Health[LOW])
				{
					health = GetScaledRate(spawn.Health, strength, diff);
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
					SetEntProp(entity, Prop_Data, "m_iHealth", health);
				}
				else
				{
					health = ReturnEntityMaxHealth(entity);
				}

				Apply_Text_Above_Npc(entity, b_thisNpcIsABoss[entity] ? strength + 1 : strength, health);

				if(!b_IsAloneOnServer)
				{
					if(zr_spawnprotectiontime.FloatValue > 0.0)
					{
						i_npcspawnprotection[entity] = NPC_SPAWNPROT_ON;
						CreateTimer(zr_spawnprotectiontime.FloatValue, Remove_Spawn_Protection, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	else if(spawn.NextSpawnTime)
	{
		spawn.NextSpawnTime = 0.0;
		SpawnList.SetArray(pos, spawn);
	}
}

stock void Apply_Text_Above_Npc(int entity,int strength, int health)
{
	CClotBody npc = view_as<CClotBody>(entity);
	char buffer[128];
	Format(buffer, sizeof(buffer), "Level %d", Level[entity]);

	int color[4];
		
	color[0] = RenderColors_RPG[strength][0];
	color[1] = RenderColors_RPG[strength][1];
	color[2] = RenderColors_RPG[strength][2];
	color[3] = RenderColors_RPG[strength][3];

	float OffsetFromHead[3];

	OffsetFromHead[2] = 95.0;
	OffsetFromHead[2] += f_ExtraOffsetNpcHudAbove[npc.index];
	OffsetFromHead[2] *= GetEntPropFloat(entity, Prop_Send, "m_flModelScale");

//	OffsetFromHead[2] += 10.0;
	npc.m_iTextEntity1 = SpawnFormattedWorldText(c_NpcName[entity], OffsetFromHead, 10,color, entity);
	OffsetFromHead[2] -= 10.0;
	npc.m_iTextEntity3 = SpawnFormattedWorldText("???", OffsetFromHead, 10,color, entity);
	RPGSpawns_UpdateHealthNpc(entity);
}

void RPGSpawns_UpdateHealthNpc(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	if(!IsValidEntity(npc.m_iTextEntity3))
		return;
		
	if(entity <= MaxClients)
		return;		
	int MaxHealth = ReturnEntityMaxHealth(entity);
	int Health = GetEntProp(entity, Prop_Data, "m_iHealth");
	char HealthString[64];
	IntToString(Health,HealthString, sizeof(HealthString));
	int offset = Health < 0 ? 1 : 0;
	ThousandString(HealthString[offset], sizeof(HealthString) - offset);
	DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
	int red;
	int green;
	int blue;
	DisplayRGBHealthValue(Health, MaxHealth, red, green,blue);
	char sColor[32];
	Format(sColor, sizeof(sColor), " %d %d %d %d ", red, green, blue, 255);
	DispatchKeyValue(npc.m_iTextEntity3,     "color", sColor);
	
}
static int GetScaledRate(const int rates[2], int power, int maxpower)
{
	return rates[LOW] + ((rates[HIGH] - rates[LOW]) * power / maxpower);
}

void Spawns_NPCDeath(int entity, int client, int weapon)
{
	static float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos1);

	static SpawnEnum spawn;
	if(hFromSpawnerIndex[entity] >= 0)
	{
		//75% of the enemy LVL
		int minlevel = Level[entity] * 3 / 4;

		SpawnList.GetArray(hFromSpawnerIndex[entity], spawn);
		
		int targetCount;
		int[] targets = new int[MaxClients];
		for(int target = 1; target <= MaxClients; target++)
		{
			if(client != target && Party_IsClientMember(client, target))
			{
				if(Level[target] < minlevel && !Stats_GetHasKill(target, c_NpcName[entity]))
					continue;
				
				static float pos2[3];
				GetClientAbsOrigin(target, pos2);
				if(GetVectorDistance(pos1, pos2, true) > 1000000.0)	// 1000 HU
					continue;
				
				targets[targetCount++] = target;
			}
		}

		if(i_CreditsOnKill[entity])
		{
			/*
			if(i_CreditsOnKill[entity] > 49)
			{
				TextStore_DropCash(client, pos1, i_CreditsOnKill[entity]);
			}
			else if(i_CreditsOnKill[entity] > 14)
			{
				if(GetURandomInt() % 2)
					TextStore_DropCash(client, pos1, i_CreditsOnKill[entity] * 2);
			}
			else 
			//we'll only use the bottom part, as its too much cash spam pickup up all the time.
			*/
			if(!(GetURandomInt() % 5))
			{
				TextStore_DropCash(client, pos1, i_CreditsOnKill[entity] * 5);
			}
		}
		
		spawn.DoAllDrops(client, pos1, Level[entity]);

		if(XP[entity] > 0)
		{
			TextStore_AddItemCount(client, ITEM_XP, XP[entity]);
			
			bool lowXPShare = Party_XPLowShare(client);
			
			if(lowXPShare && targetCount > 1)
			{
				SortCustom1D(targets, targetCount, ClientLowLevelSort);

				targetCount--;

				int xp = XP[entity];
				for(int i; i < targetCount; i++)
				{
					int give = xp * 3 / 4;
					TextStore_AddItemCount(targets[i], ITEM_XP, give);
					xp -= give;
				}

				TextStore_AddItemCount(targets[targetCount], ITEM_XP, xp);
			}
			else
			{
				for(int i; i < targetCount; i++)
				{
					TextStore_AddItemCount(targets[i], ITEM_XP, XP[entity] / targetCount);
				}
			}
		}
	}

	hFromSpawnerIndex[entity] = -1;
	
	if(weapon != -1)
		Tinker_GainXP(client, weapon);
}

static int ClientLowLevelSort(int elem1, int elem2, const int[] array, Handle hndl)
{
	if(Level[elem1] < Level[elem2])
		return -1;
	
	if(Level[elem1] > Level[elem2] || elem1 < elem2)
		return 1;
	
	return -1;
}

static void RollItemDrop(int client, const char[] name, float chance, float pos[3])
{
	if(chance > GetURandomFloat())
		TextStore_DropNamedItem(client, name, pos, 1);
}

public Action Spawns_Command(int client, int args)
{
	if(client)
	{
		Menu menu = new Menu(Spawns_CommandH);
		menu.SetTitle("RPG Fortress\n \nSpawn Stats:\n ");

		float luck = (1.0 + (float(Stats_Luck(client)) / 300.0)) * 100.0;

		ArrayList list = new ArrayList();
		int length = SpawnList.Length;
		for(int i; i < length; i++)
		{
			static SpawnEnum spawn;
			SpawnList.GetArray(i, spawn);
			if(spawn.Touching[client] && list.FindValue(spawn.Index) == -1)
			{
				list.Push(spawn.Index);

				static char buffer[256];
				NPC_GetNameById(spawn.Index, buffer, sizeof(buffer));
				Format(buffer, sizeof(buffer), "%s\n ", buffer);
				
				if(spawn.Item1[0])
					Format(buffer, sizeof(buffer), "%s%s - %.2f％\n ", buffer, spawn.Item1, spawn.Chance1 * luck, spawn.Chance1 * luck);
				
				if(spawn.Item2[0])
					Format(buffer, sizeof(buffer), "%s%s - %.2f％\n ", buffer, spawn.Item2, spawn.Chance2 * luck, spawn.Chance2 * luck);
				
				if(spawn.Item3[0])
					Format(buffer, sizeof(buffer), "%s%s - %.2f％\n ", buffer, spawn.Item3, spawn.Chance3 * luck, spawn.Chance3 * luck);

				if(spawn.Item4[0])
					Format(buffer, sizeof(buffer), "%s%s - %.2f％\n ", buffer, spawn.Item4, spawn.Chance4 * luck, spawn.Chance4 * luck);
				
				menu.AddItem(buffer, buffer, ITEMDRAW_DISABLED);
			}
		}
		
		static char Empty[256];
		
		if(!list.Length)
			menu.AddItem(Empty, "Nothing Spawns Here", ITEMDRAW_DISABLED);
		
		delete list;

		menu.Pagination = 2;
		menu.ExitButton = true;
		menu.ExitBackButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public int Spawns_CommandH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
				FakeClientCommandEx(client, "sm_store");
		}
		case MenuAction_Select:
		{
			FakeClientCommandEx(client, "sm_store");
		}
	}
	return 0;
}

//static Handle TimerZoneEditing[MAXPLAYERS];
static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentSpawnEditing[MAXPLAYERS][64];
static char CurrentZoneEditing[MAXPLAYERS][64];

void Spawns_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH], buffer3[48];

	EditMenu menu = new EditMenu();

	if(StrEqual(CurrentKeyEditing[client], "copy"))
	{
		menu.SetTitle("Spawns\n%s - %s\nSelect spawn to copy from:\n ", CurrentZoneEditing[client], CurrentSpawnEditing[client]);
		
		RPG_BuildPath(buffer1, sizeof(buffer1), "spawns");
		KeyValues kv = new KeyValues("Spawns");
		kv.ImportFromFile(buffer1);
		if(kv.GotoFirstSubKey())
		{
			bool first;
			do
			{
				kv.GetSectionName(buffer1, sizeof(buffer1));
				if(kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetSectionName(buffer2, sizeof(buffer2));
						Format(buffer2, sizeof(buffer2), "%s;%s", buffer1, buffer2);

						kv.GetString("name", buffer3, sizeof(buffer3));
						Format(buffer3, sizeof(buffer3), "%s (%s)", buffer3, buffer2);

						if(first && Zones_IsActive(buffer1))
						{
							menu.InsertItem(0, buffer2, buffer3);
						}
						else
						{
							first = true;
							menu.AddItem(buffer2, buffer3);
						}
					}
					while(kv.GotoNextKey());
					kv.GoBack();
				}
			}
			while(kv.GotoNextKey());
		}

		delete kv;

		menu.ExitBackButton = true;
		menu.Display(client, AdjustSpawnCopy);
	}
	else if(CurrentKeyEditing[client][0])
	{
		menu.SetTitle("Spawns\n%s - %s\n ", CurrentZoneEditing[client], CurrentSpawnEditing[client]);
		
		FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
		menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

		menu.AddItem("", "Set To Default");

		menu.ExitBackButton = true;
		menu.Display(client, AdjustSpawnKey);
	}
	else if(CurrentSpawnEditing[client][0])
	{
		RPG_BuildPath(buffer1, sizeof(buffer1), "spawns");
		KeyValues kv = new KeyValues("Spawns");
		kv.ImportFromFile(buffer1);
		kv.JumpToKey(CurrentZoneEditing[client]);
		kv.JumpToKey(CurrentSpawnEditing[client]);

		menu.SetTitle("Spawns\n%s - %s\nClick to set it's value:\n ", CurrentZoneEditing[client], CurrentSpawnEditing[client]);
		
		FormatEx(buffer2, sizeof(buffer2), "Position: %s", CurrentSpawnEditing[client]);
		menu.AddItem("pos", buffer2);
		
		/*
			Teleport Box
		*/
		float telepos[3], vec1[3], vec2[3];
		ExplodeStringFloat(CurrentSpawnEditing[client], " ", telepos, sizeof(telepos));
		for(int i; i < 3; i++)
		{
			vec1 = telepos;
			vec1[0] -= 23.5;
			vec1[1] -= 23.5;
			vec2 = vec1;

			vec2[i] += i == 2 ? 95.0 : 57.0;

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 5.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
			TE_SendToClient(client);
			
			vec1 = telepos;
			vec1[0] += 23.5;
			vec1[1] += 23.5;
			vec1[2] += 95.0;
			vec2 = vec1;

			vec2[i] -= i == 2 ? 95.0 : 57.0;

			TE_SetupBeamPoints(vec1, vec2, Shared_BEAM_Laser, 0, 0, 0, 5.0, 20.0, 20.0, 0, 0.0, {255, 255, 0, 255}, 0);
			TE_SendToClient(client);
		}

		kv.GetString("name", buffer1, sizeof(buffer1));
		bool valid = NPC_GetByPlugin(buffer1) != -1;
		FormatEx(buffer2, sizeof(buffer2), "NPC Plugin: \"%s\"%s", buffer1, valid ? "" : " {WARNING: NPC does not exist}");
		menu.AddItem("name", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Is Boss: %d", kv.GetNum("boss"));
		menu.AddItem("boss", buffer2);

		int angle = kv.GetNum("angle", -1);
		FormatEx(buffer2, sizeof(buffer2), "Angle: %s%d", angle == -1 ? "Random " : "", angle);
		menu.AddItem("angle", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Max Alive: %d", kv.GetNum("count", 1));
		menu.AddItem("count", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Spawn Time: %.1f", kv.GetFloat("time"));
		menu.AddItem("time", buffer2);

		menu.AddItem("time", buffer2, ITEMDRAW_SPACER);

		IntToString(kv.GetNum("level", kv.GetNum("low_level")), buffer2, sizeof(buffer2));
		ThousandString(buffer2, sizeof(buffer2));
		Format(buffer2, sizeof(buffer2), "Level: %s", buffer2);
		menu.AddItem("level", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "Max Level: %d", kv.GetNum("high_level"));
		//menu.AddItem("high_level", buffer2);

		IntToString(kv.GetNum("health", kv.GetNum("low_health")), buffer2, sizeof(buffer2));
		ThousandString(buffer2, sizeof(buffer2));
		Format(buffer2, sizeof(buffer2), "Health: %s", buffer2);
		menu.AddItem("health", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "Max Health: %d", kv.GetNum("high_health"));
		//menu.AddItem("high_health", buffer2);

		IntToString(kv.GetNum("xp", kv.GetNum("low_xp")), buffer2, sizeof(buffer2));
		ThousandString(buffer2, sizeof(buffer2));
		Format(buffer2, sizeof(buffer2), "XP: %s", buffer2);
		menu.AddItem("xp", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "Max XP: %d", kv.GetNum("high_xp"));
		//menu.AddItem("high_xp", buffer2);

		//menu.AddItem("high_xp", buffer2, ITEMDRAW_SPACER);

		IntToString(kv.GetNum("cash", kv.GetNum("low_cash")), buffer2, sizeof(buffer2));
		ThousandString(buffer2, sizeof(buffer2));
		Format(buffer2, sizeof(buffer2), "Cash: %s", buffer2);
		menu.AddItem("cash", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "Max Cash: %d", kv.GetNum("high_cash"));
		//menu.AddItem("high_cash", buffer2);

		IntToString(kv.GetNum("hpregen", kv.GetNum("low_hpregen")), buffer2, sizeof(buffer2));
		ThousandString(buffer2, sizeof(buffer2));
		Format(buffer2, sizeof(buffer2), "HP Regen: %s", buffer2);
		menu.AddItem("hpregen", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "High Hp Regen: %d", kv.GetNum("high_hpregen"));
		//menu.AddItem("high_hpregen", buffer2);

		//FormatEx(buffer2, sizeof(buffer2), "Max Drop Multi: %f", kv.GetFloat("high_drops", 1.0));
		//menu.AddItem("high_drops", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Melee DMG Taken: %f", kv.GetFloat("extra_melee_res", 1.0));
		menu.AddItem("extra_melee_res", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Ranged DMG Taken: %f", kv.GetFloat("extra_ranged_res", 1.0));
		menu.AddItem("extra_ranged_res", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Speed Multi: %f", kv.GetFloat("extra_speed", 1.0));
		menu.AddItem("extra_speed", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Damage Multi: %f", kv.GetFloat("extra_damage", 1.0));
		menu.AddItem("extra_damage", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Size Multi: %f", kv.GetFloat("extra_size", 1.0));
		menu.AddItem("extra_size", buffer2);

		kv.GetString("custom_name", buffer1, sizeof(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Custom Name: \"%s\"", buffer1);
		menu.AddItem("custom_name", buffer2);

		kv.GetString("drop_name_1", buffer1, sizeof(buffer1));
		valid = (!buffer1[0] || TextStore_IsValidName(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Drop 1: \"%s\"%s", buffer1, valid ? "" : " {WARNING: Item does not exist}");
		menu.AddItem("drop_name_1", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Drop 1: %f", kv.GetFloat("drop_chance_1", 1.0));
		menu.AddItem("drop_chance_1", buffer2);

		kv.GetString("drop_name_2", buffer1, sizeof(buffer1));
		valid = (!buffer1[0] || TextStore_IsValidName(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Drop 2: \"%s\"%s", buffer1, valid ? "" : " {WARNING: Item does not exist}");
		menu.AddItem("drop_name_2", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Drop 2: %f", kv.GetFloat("drop_chance_2", 1.0));
		menu.AddItem("drop_chance_2", buffer2);

		kv.GetString("drop_name_3", buffer1, sizeof(buffer1));
		valid = (!buffer1[0] || TextStore_IsValidName(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Drop 3: \"%s\"%s", buffer1, valid ? "" : " {WARNING: Item does not exist}");
		menu.AddItem("drop_name_3", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Drop 3: %f", kv.GetFloat("drop_chance_3", 1.0));
		menu.AddItem("drop_chance_3", buffer2);

		kv.GetString("drop_name_4", buffer1, sizeof(buffer1));
		valid = (!buffer1[0] || TextStore_IsValidName(buffer1));
		FormatEx(buffer2, sizeof(buffer2), "Drop 4: \"%s\"%s", buffer1, valid ? "" : " {WARNING: Item does not exist}");
		menu.AddItem("drop_name_4", buffer2);

		FormatEx(buffer2, sizeof(buffer2), "Drop 4: %f", kv.GetFloat("drop_chance_4", 1.0));
		menu.AddItem("drop_chance_4", buffer2);

		menu.AddItem("copy", "Copy From Spawn");
		menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

		menu.ExitBackButton = true;
		menu.Display(client, AdjustSpawn);
		
		delete kv;
	}
	else if(CurrentZoneEditing[client][0])
	{
		menu.SetTitle("Spawns\n%s\nSelect a spawn:\n ", CurrentZoneEditing[client]);

		RPG_BuildPath(buffer1, sizeof(buffer1), "spawns");
		KeyValues kv = new KeyValues("Spawns");
		kv.ImportFromFile(buffer1);

		menu.AddItem("", "Create New (or type in position)");
		
		if(kv.JumpToKey(CurrentZoneEditing[client]) && kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(buffer1, sizeof(buffer1));
				kv.GetString("name", buffer2, sizeof(buffer2));
				Format(buffer2, sizeof(buffer2), "%s - %s", buffer2, buffer1);
				menu.AddItem(buffer1, buffer2);
			}
			while(kv.GotoNextKey());
		}

		menu.ExitBackButton = true;
		menu.Display(client, SpawnPicker);

		delete kv;

		Zones_RenderZone(client, CurrentZoneEditing[client]);

		//delete TimerZoneEditing[client];
		//TimerZoneEditing[client] = CreateTimer(1.0, Timer_RefreshHud, client);
	}
	else
	{
		menu.SetTitle("Spawns\nSelect a zone:\n ");

		Zones_GenerateZoneList(client, menu);

		menu.ExitBackButton = true;
		menu.Display(client, ZonePicker);
	}
}
/*
static Action Timer_RefreshHud(Handle timer, int client)
{
	TimerZoneEditing[client] = null;
	Function func = Editor_MenuFunc(client);
	if(func != SpawnPicker)
		return Plugin_Stop;
	
	Spawns_EditorMenu(client);
	return Plugin_Continue;
}
*/
static void ZonePicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	strcopy(CurrentZoneEditing[client], sizeof(CurrentZoneEditing[]), key);
	Spawns_EditorMenu(client);
}

static void SpawnPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		//delete TimerZoneEditing[client];
		CurrentZoneEditing[client][0] = 0;
		Editor_MainMenu(client);
		return;
	}

	if(key[0])
	{
		strcopy(CurrentSpawnEditing[client], sizeof(CurrentSpawnEditing[]), key);
	}
	else
	{
		float pos[3];
		GetClientPointVisible(client, _, _, _, pos);
		Format(CurrentSpawnEditing[client], sizeof(CurrentSpawnEditing[]), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
	}

	Spawns_EditorMenu(client);
}

static void AdjustSpawn(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSpawnEditing[client][0] = 0;
		Spawns_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "spawns");
	KeyValues kv = new KeyValues("Spawns");
	kv.ImportFromFile(filepath);
	kv.JumpToKey(CurrentZoneEditing[client], true);
	kv.JumpToKey(CurrentSpawnEditing[client], true);

	if(StrEqual(key, "pos"))
	{
		char buffer[64];
		float pos[3];
		GetClientPointVisible(client, _, _, _, pos);
		FormatEx(buffer, sizeof(buffer), "%.0f %.0f %.0f", pos[0], pos[1], pos[2]);
		kv.SetSectionName(buffer);
		strcopy(CurrentSpawnEditing[client], sizeof(CurrentSpawnEditing[]), buffer);
	}
	else if(StrEqual(key, "boss"))
	{
		kv.SetNum("boss", kv.GetNum("boss") ? 0 : 1);
	}
	else if(StrEqual(key, "angle"))
	{
		int angle = kv.GetNum("angle");
		if(angle == -1)
		{
			angle = 0;
		}
		else if(angle > 179)
		{
			angle = -135;
		}
		else if(angle == -45)
		{
			angle = -1;
		}
		else
		{
			angle += 45;
		}

		kv.SetNum("angle", angle);
	}
	else if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentSpawnEditing[client][0] = 0;
	}
	else
	{
		delete kv;
		
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Spawns_EditorMenu(client);
		return;
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(hFromSpawnerIndex[i] != -1)
			NPC_Despawn(i);
	}

	Spawns_ConfigSetup();
	Zones_Rebuild();
	Spawns_EditorMenu(client);
}

static void AdjustSpawnKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Spawns_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "spawns");
	KeyValues kv = new KeyValues("Spawns");
	kv.ImportFromFile(filepath);
	kv.JumpToKey(CurrentZoneEditing[client], true);
	kv.JumpToKey(CurrentSpawnEditing[client], true);

	if(key[0])
	{
		// Remove ","
		int length = strlen(key) + 1;
		char[] buffer = new char[length];
		strcopy(buffer, length, key);
		ReplaceString(buffer, length, ",", "");

		kv.SetString(CurrentKeyEditing[client], buffer);
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	int i = -1;
	while((i = FindEntityByClassname(i, "zr_base_npc")) != -1)
	{
		if(hFromSpawnerIndex[i] != -1)
			NPC_Despawn(i);
	}

	Spawns_ConfigSetup();
	Zones_Rebuild();
	Spawns_EditorMenu(client);
}

static void AdjustSpawnCopy(int client, const char[] key)
{
	char buffers[2][64];
	if(ExplodeString(key, ";", buffers, sizeof(buffers), sizeof(buffers[])) != 2)
	{
		CurrentKeyEditing[client][0] = 0;
		Spawns_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "spawns");
	KeyValues main = new KeyValues("Spawns");
	main.ImportFromFile(filepath);
	
	if(main.JumpToKey(buffers[0]) && main.JumpToKey(buffers[1]))
	{
		KeyValues other = new KeyValues(buffers[1]);
		other.Import(main);
		
		main.Rewind();
		main.JumpToKey(CurrentZoneEditing[client], true);
		main.JumpToKey(CurrentSpawnEditing[client], true);
		main.Import(other);

		main.Rewind();
		main.ExportToFile(filepath);
	}
	else
	{
		PrintToChatAll("AdjustSpawnCopy:%s::FailedJump", key);
	}

	delete main;

	CurrentKeyEditing[client][0] = 0;
	Spawns_ConfigSetup();
	Zones_Rebuild();
	Spawns_EditorMenu(client);
}