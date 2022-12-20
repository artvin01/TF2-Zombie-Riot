#pragma semicolon 1
#pragma newdecls required

#define LOW	0
#define HIGH	1

enum struct SpawnEnum
{
	int Index;
	char Zone[32];
	float Pos[3];
	float Angle;
	int Count;
	float Time;
	
	bool Boss;
	int Level[2];
	int Health[2];
	int XP[2];
	int Cash[2];
	float DropMulti;
	
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

		this.Index = StringToInt(this.Item1);
		if(!this.Index)
			this.Index = GetIndexByPluginName(this.Item1);
		
		this.Angle = kv.GetFloat("angle", -1.0);
		this.Count = kv.GetNum("count", 1);
		this.Time = kv.GetFloat("time");
		this.Boss = view_as<bool>(kv.GetNum("boss"));
		this.DropMulti = kv.GetFloat("high_drops", 1.0);

		this.Level[LOW] = kv.GetNum("low_level");
		this.Health[LOW] = kv.GetNum("low_health");
		this.XP[LOW] = kv.GetNum("low_xp");
		this.Cash[LOW] = kv.GetNum("low_cash");

		this.Level[HIGH] = kv.GetNum("high_level");
		this.Health[HIGH] = kv.GetNum("high_health");
		this.XP[HIGH] = kv.GetNum("high_xp");
		this.Cash[HIGH] = kv.GetNum("high_cash");

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

	}
}

static ArrayList SpawnList;
static Handle SpawnTimer;
static int SpawnCycle;

void Spawns_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Spawns"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "spawns");
		kv = new KeyValues("Spawns");
		kv.ImportFromFile(buffer);
	}
	
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

	if(kv != map)
		delete kv;
	
	if(!SpawnTimer && SpawnList.Length)
		SpawnTimer = CreateTimer(0.1, Spawner_Timer, _, TIMER_REPEAT);
}

void Spawns_MapEnd()
{
	delete SpawnTimer;
}

void Spawns_DisableSpawn(const char[] name)
{
	ArrayList list = new ArrayList();

	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
		if(StrEqual(spawn.Zone, name))
			list.Push(i);
	}

	int i = MaxClients + 1;
	while((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if(list.FindValue(hFromSpawnerIndex[i]) != -1)
			NPC_Despawn(i);
	}

	delete list;
}

void Spawns_UpdateSpawn(const char[] name)
{
	int length = SpawnList.Length;
	for(int i; i < length; i++)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(i, spawn);
		if(StrEqual(spawn.Zone, name))
			UpdateSpawn(i, spawn, true);
	}
}

public Action Spawner_Timer(Handle timer)
{
	if(SpawnCycle >= SpawnList.Length)
		SpawnCycle = 0;
	
	static SpawnEnum spawn;
	SpawnList.GetArray(SpawnCycle, spawn);
	if(Zones_IsActive(spawn.Zone))
		UpdateSpawn(SpawnCycle, spawn, false);
	
	SpawnCycle++;
	return Plugin_Continue;
}

static void UpdateSpawn(int pos, SpawnEnum spawn, bool start)
{
	int alive;

	if(!start)
	{
		int i = MaxClients + 1;
		while((i = FindEntityByClassname(i, "base_boss")) != -1)
		{
			if(hFromSpawnerIndex[i] == pos)
				alive++;
		}
	}
	
	if(alive < spawn.Count)
	{
		int count;
		if(spawn.NextSpawnTime)
		{
			float gameTime = GetGameTime();

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
				spawn.NextSpawnTime += spawn.Time;
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
			static float ang[3];
			ang[1] = spawn.Angle;
			if(ang[1] < 0.0)
				ang[1] = GetURandomFloat() * 360.0;
			
			int diff = spawn.Level[HIGH] - spawn.Level[LOW];
			for(int i; i < count; i++)
			{
				int entity = Npc_Create(spawn.Index, 0, spawn.Pos, ang, false);
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
				i_CreditsOnKill[entity] = GetScaledRate(spawn.Cash, strength, diff);
				XP[entity] = GetScaledRate(spawn.XP, strength, diff);
				int health = 999999999; //ayo he forgor, ANNOY ADMINO

				if(spawn.Health[LOW])
				{
					health = GetScaledRate(spawn.Health, strength, diff);
					SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
					SetEntProp(entity, Prop_Data, "m_iHealth", health);
				}
				Apply_Text_Above_Npc(entity,strength, health);

				b_npcspawnprotection[entity] = true;
				CreateTimer(2.0, Remove_Spawn_Protection, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else if(spawn.NextSpawnTime)
	{
		spawn.NextSpawnTime = 0.0;
		SpawnList.SetArray(pos, spawn);
	}
}

void Apply_Text_Above_Npc(int entity,int strength, int health)
{
	CClotBody npc = view_as<CClotBody>(entity);
	char String[128];
	GetDisplayString(Level[entity], String, sizeof(String), true);

	int color[4];
		
	color[0] = RenderColors_RPG[strength][0];
	color[1] = RenderColors_RPG[strength][1];
	color[2] = RenderColors_RPG[strength][2];
	color[3] = RenderColors_RPG[strength][3];

	float OffsetFromHead[3];

	OffsetFromHead[2] = 95.0;
	OffsetFromHead[2] *= GetEntPropFloat(entity, Prop_Send, "m_flModelScale");

				
	OffsetFromHead[2] += 10.0;
	npc.m_iTextEntity1 = SpawnFormattedWorldText(NPC_Names[i_NpcInternalId[entity]], OffsetFromHead, 10,color, entity);
				
	OffsetFromHead[2] += 10.0;
	npc.m_iTextEntity2 = SpawnFormattedWorldText(String, OffsetFromHead, 10,color, entity);

	Format(String, sizeof(String), "%d / %d", health, health);
	OffsetFromHead[2] -= 20.0;
	npc.m_iTextEntity3 = SpawnFormattedWorldText(String, OffsetFromHead, 10,color, entity);
}

static int GetScaledRate(const int rates[2], int power, int maxpower)
{
	return rates[LOW] + ((rates[HIGH] - rates[LOW]) * power / maxpower);
}

void Spawns_NPCDeath(int entity, int client, int weapon)
{
	int xp = XP[entity];
	if(xp < 0)
		xp = Level[entity];
	
	for(int target = 1; target <= MaxClients; target++)
	{
		if(client == target || Party_IsClientMember(client, target))
		{
			if((Level[client] - 5) < Level[entity] && (Level[client] + 5) > Level[entity] && GetLevelCap(Tier[client]) != Level[client])
				GiveXP(client, xp);
		}
	}

	static float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

	if(i_CreditsOnKill[entity])
	{
		if(i_CreditsOnKill[entity] > 199)
		{
			TextStore_DropCash(client, pos, i_CreditsOnKill[entity]);
		}
		else if(i_CreditsOnKill[entity] > 49)
		{
			if(GetURandomInt() % 2)
				TextStore_DropCash(client, pos, i_CreditsOnKill[entity] * 2);
		}
		else if(!(GetURandomInt() % 5))
		{
			TextStore_DropCash(client, pos, i_CreditsOnKill[entity] * 5);
		}
	}

	if(hFromSpawnerIndex[entity] >= 0)
	{
		static SpawnEnum spawn;
		SpawnList.GetArray(hFromSpawnerIndex[entity], spawn);

		spawn.DoAllDrops(client, pos, Level[entity]);
		hFromSpawnerIndex[entity] = -1;
	}

	if(weapon != -1)
		Tinker_GainXP(client, weapon);
}

static void RollItemDrop(int client, const char[] name, float chance, float pos[3])
{
	if(chance > GetURandomFloat())
		TextStore_DropNamedItem(client, name, pos, 1);
}