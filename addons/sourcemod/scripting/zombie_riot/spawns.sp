#pragma semicolon 1
#pragma newdecls required

#define BASE_SPAWNER_COOLDOWN 0.30

enum struct SpawnerData
{
	int EntRef;
	bool BaseBoss;
	bool AllySpawner;
	char Name[64];
	bool ignore_disabled;

	float Cooldown;
	float Points;
	bool Enabled;
	int MaxSpawnsAllowed;
	int WaveCreatedIn;
	int MaxWavesAllowed;
	int CurrentSpawnsPerformed;
	int SpawnSetting;
}

static ArrayList SpawnerList;
static ConVar MapSpawnersActive;
static float HighestPoints;
static float LastNamedSpawn;

void Spawns_PluginStart()
{
	MapSpawnersActive = CreateConVar("zr_spawnersactive", "4", "How many spawners are active by default,", _, true, 0.0, true, 32.0);
}

void Spawns_MapEnd()
{
	delete SpawnerList;
	LastNamedSpawn = 0.0;
}

bool Spawns_CanSpawnNext()
{
	if(!SpawnerList)
	{
		return false;
	}
	float gameTime = GetGameTime();

	if(Rogue_Mode())
	{
		if(LastNamedSpawn > gameTime)
			return false;
		
		LastNamedSpawn = gameTime + (BASE_SPAWNER_COOLDOWN / MultiGlobalEnemy);
		return true;
	}

	SpawnerData spawn;

	//bool error = true;
	int length = SpawnerList.Length;
	
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		if(!spawn.Enabled || spawn.AllySpawner)	// Disabled, ignore
		{
			continue;
		}
		
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(i);
			i--;
			length--;
			continue;
		}
		
		if(!spawn.BaseBoss)
		{
			if(GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled"))	// Map disabled, ignore
				continue;
		}

		if(spawn.Points <= 0.0)	// Map disabled, ignore
			continue;
		
		if(spawn.Cooldown < gameTime)
			return true;
	}

	return false;
}

bool Spawns_GetNextPos(float pos[3], float ang[3], const char[] name = NULL_STRING, float cooldownOverride = -1.0, int &spawnerSetting = 0)
{
	SpawnerData spawn;
	float gameTime = GetGameTime();

	int bestIndex = -1;
	float bestPoints = 0.0;
	bool SpawnWasDeleted = false;
	int nonBossSpawners;
	int length = SpawnerList.Length;
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(i);
			i--; //we try again.
			length--;
			SpawnWasDeleted = true;
			continue;
		}

		if(name[0])
		{
			if(!StrEqual(name, spawn.Name))	// Invalid name, ignore
				continue;
		}
		else if(!spawn.Enabled || spawn.AllySpawner)	// Disabled, ignore
		{
			continue;
		}
		
		if(!spawn.BaseBoss)
		{
			if(GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled") && !spawn.AllySpawner)	// Map disabled, ignore, except if its an ally one.
				continue;
			
			if(spawn.MaxWavesAllowed != 999)
			{
				//999 means its a perma spawn or a boss spawn, whatever it may be.
				int WavesAllow = spawn.MaxWavesAllowed;
				int WavesLeft = Waves_GetRoundScale() - spawn.WaveCreatedIn;
				if(WavesLeft >= WavesAllow)
				{
					SpawnerList.Erase(i);
					i--; //we try again.
					length--;
					SpawnWasDeleted = true;
					//EDIT:looks like deleting it is bad.
					continue;
				}
			}
			
			nonBossSpawners++;
		}
		
		if((spawn.Cooldown < gameTime && spawn.Points >= bestPoints) || (name[0] && bestIndex == -1))
		{
			bestIndex = i;
			bestPoints = spawn.Points;
		}
	}

	if(bestIndex == -1 && name[0])	// Fallback to case checks for spawn names
	{
		for(int i; i < length; i++)
		{
			SpawnerList.GetArray(i, spawn);

			if(StrContains(spawn.Name, name, false) == -1)	// Invalid name, ignore
				continue;
			
			if(!spawn.BaseBoss)
			{
				if(GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled") && !spawn.AllySpawner)	// Map disabled, ignore, except if its an ally one.
					continue;

				if(spawn.MaxWavesAllowed != 999)
				{
					//999 means its a perma spawn or a boss spawn, whatever it may be.
					int WavesAllow = spawn.MaxWavesAllowed;
					int WavesLeft = Waves_GetRoundScale() - spawn.WaveCreatedIn;
					if(WavesLeft >= WavesAllow)
					{
						SpawnerList.Erase(i);
						i--; //we try again.
						length--;
						SpawnWasDeleted = true;
						continue;
					}
				}
				nonBossSpawners++;
			}
			//get atleast 1 spawnpont?
			if(bestIndex == -1 || (spawn.Cooldown < gameTime && spawn.Points >= bestPoints))
			{
				bestIndex = i;
				bestPoints = spawn.Points;
			}
		}
	}

	if(bestIndex == -1)
	{
		if(SpawnWasDeleted)
		{
			//Update all spawns.	
			Spawners_Timer();
		}
		return false;
	}
	
	SpawnerList.GetArray(bestIndex, spawn);
	GetEntPropVector(spawn.EntRef, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(spawn.EntRef, Prop_Data, "m_angRotation", ang);
	if(cooldownOverride < 0.0)	// Normal cooldown time
	{
		if(nonBossSpawners == 1)
		{
			spawn.Cooldown = gameTime + (ZRModifs_SpawnSpeedModif() * (BASE_SPAWNER_COOLDOWN / MultiGlobalEnemy));
		}
		else
		{
			float nearSpeedUp = 4.0 * (spawn.Points / HighestPoints);
			if(nearSpeedUp < 1.0)
				nearSpeedUp = 1.0;

			float playerSpeedUp = 1.0 + (MultiGlobalEnemy * 0.5);
			
			float baseTime = 2.0 + (nonBossSpawners * 0.15);

			// player = 1.0 + (1.5) = 2.5
			// baseTime = 2.0 + (6 * 0.15) = 2.9
			// 2.9 / 2.5 = 1.16 slowest
			// 1.16 / 4 = 0.29 fastest

			spawn.Cooldown = gameTime + (ZRModifs_SpawnSpeedModif() * (baseTime / nearSpeedUp / playerSpeedUp));
		}
	}
	else	// Override cooldown time
	{
		spawn.Cooldown = gameTime + cooldownOverride;
	}
	//This spawns always atleast 1 thing.
	Rogue_Paradox_SpawnCooldown(spawn.Cooldown);
	
	spawn.CurrentSpawnsPerformed++;
	SpawnerList.SetArray(bestIndex, spawn);
	if(spawn.CurrentSpawnsPerformed >= spawn.MaxSpawnsAllowed)
	{
		Spawns_RemoveFromArray(spawn.EntRef);
		RemoveEntity(spawn.EntRef);
	}
	spawnerSetting = spawn.SpawnSetting;
	if(spawn.BaseBoss)
	{
		//never give spawnprotection if it spawns from an NPC.
		spawnerSetting |= 1;
	}
	if(SpawnWasDeleted)
	{
		//Update all spawns.	
		Spawners_Timer();
	}
	return true;
}

void Spawns_AddToArray(int ref, bool base_boss = false, bool allyspawner = false, int MaxSpawnsAllowed = 2000000000, int i_SpawnSetting = 0, int WavesAllowed = 999)
{
	if(!SpawnerList)
		SpawnerList = new ArrayList(sizeof(SpawnerData));
	
	if(SpawnerList.FindValue(ref, SpawnerData::EntRef) == -1)
	{
		SpawnerData spawn;

		spawn.EntRef = ref;
		spawn.BaseBoss = base_boss;
		spawn.AllySpawner = allyspawner;
		spawn.MaxSpawnsAllowed = MaxSpawnsAllowed;
		spawn.WaveCreatedIn = Waves_GetRoundScale();
		spawn.MaxWavesAllowed = WavesAllowed;
		spawn.CurrentSpawnsPerformed = 0;
		spawn.SpawnSetting = i_SpawnSetting;

		GetEntPropString(ref, Prop_Data, "m_iName", spawn.Name, sizeof(spawn.Name));

		SpawnerList.PushArray(spawn);
	}
}

void Spawns_RemoveFromArray(int entity)
{
	int index = SpawnerList.FindValue(entity, SpawnerData::EntRef);
	if(index != -1)
		SpawnerList.Erase(index);
}

void Spawners_Timer()
{
	if(!SpawnerList)
		return;
	
	float f3_PositionTemp_2[3];
	float f3_PositionTemp[3];
		
	SpawnerData spawn;
	int length = SpawnerList.Length;
	for(int index; index < length; index++)
	{
		SpawnerList.GetArray(index, spawn);
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(index);
			index--;
			length--;
			continue;
		}

		if(!spawn.BaseBoss)
		{
			if(GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled") && !spawn.AllySpawner)	// Map disabled, ignore, except if its an ally one.
				continue;

			if(spawn.MaxWavesAllowed != 999)
			{
				//999 means its a perma spawn or a boss spawn, whatever it may be.
				int WavesAllow = spawn.MaxWavesAllowed;
				int WavesLeft = Waves_GetRoundScale() - spawn.WaveCreatedIn;
				if(WavesLeft >= WavesAllow)
				{
					SpawnerList.Erase(index);
					index--; //we try again.
					length--;
					continue;
				}
			}
		}

		spawn.Points = (!spawn.BaseBoss && Construction_BlockSpawner(spawn.Name)) ? -999.0 : 0.0;
		SpawnerList.SetArray(index, spawn);	
	}
	int PlayersGathered = 0;
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(GetClientTeam(client)==2 && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0 && IsPlayerAlive(client))
			{
				PlayersGathered++;
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);

				for(int index; index < length; index++)
				{
					SpawnerList.GetArray(index, spawn);
					if(spawn.AllySpawner || spawn.Points < 0.0)
						continue;
					
					int entity_Ref = spawn.EntRef;
					
					if(!spawn.BaseBoss && GetEntProp(entity_Ref, Prop_Data, "m_bDisabled"))
					{
						continue;
					}
						
					GetEntPropVector(entity_Ref, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp_2);
					float distance = GetVectorDistance( f3_PositionTemp, f3_PositionTemp_2, true); 
					//leave it all squared for optimsation sake!
					//max distance is 10,000 anymore and wtf u doin
					if( distance < 100000000.0)
					{
						//For Zr_lila_panic, this might be outdated code, look into it.
						/*if(StrEqual(spawn.Name, "underground"))
						{
							if(!b_PlayerIsInAnotherPart[client])
							{
								continue;
							}
						}
						if(b_PlayerIsInAnotherPart[client])
						{
							if(!StrEqual(spawn.Name, "underground"))
							{
								continue;
							}
						}*/
						
						float inverting_score_calc = ( distance / 100000000.0) - 1.0;
						spawn.Points -= inverting_score_calc;
						SpawnerList.SetArray(index, spawn);							
					}
				}
			}
		}
	}

	// Get max spawner count
	int maxSpawners = MapSpawnersActive.IntValue;
	if(maxSpawners < 1)
		maxSpawners = 1;

	// Get list of points
	ArrayList pointsList = new ArrayList();

	for(int index; index < length; index++)
	{
		SpawnerList.GetArray(index, spawn);
		if(spawn.Points > 0.0)
		{
			spawn.Points /= PlayersGathered;
			SpawnerList.SetArray(index, spawn);
		}
	}

	for(int index; index < length; index++)
	{
		SpawnerList.GetArray(index, spawn);
		if(spawn.Points >= 0.0)
		{
			if(spawn.BaseBoss)
				maxSpawners++;
			
			pointsList.Push(spawn.Points);
		}
	}
	
	if(maxSpawners > pointsList.Length)
		maxSpawners = pointsList.Length;
	
	if(maxSpawners)
	{
		// Sort points
		pointsList.Sort(Sort_Descending, Sort_Float);
		
		// Get points of the X ranked score
		HighestPoints = pointsList.Get(0);
		float minPoints = pointsList.Get(maxSpawners - 1);
		
		// Enable if meet requirement
		for(int index; index < length; index++)
		{
			SpawnerList.GetArray(index, spawn);

			if(spawn.Points <= 0.0)
			{
				spawn.Enabled = false;
			}
			else
			{
				spawn.Enabled = spawn.Points >= minPoints;
			}
			SpawnerList.SetArray(index, spawn);
		}
	}

	delete pointsList;
}

int GetRandomActiveSpawner(const char[] name = "")
{
	SpawnerData spawn;
	
	int length = SpawnerList.Length;
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		//always check if its existant first!!
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(i);
			i--;
			length--;
			continue;
		}

		if(name[0])
		{
			if(!StrEqual(name, spawn.Name))	// Invalid name, ignore
				continue;
		}
		else if(!spawn.Enabled || spawn.AllySpawner)	// Disabled, ignore
		{
			continue;
		}
		

		if(!spawn.BaseBoss && GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled") && !spawn.AllySpawner)	// Map disabled, ignore
			continue;
		
		return spawn.EntRef;
	}
	return -1;
}