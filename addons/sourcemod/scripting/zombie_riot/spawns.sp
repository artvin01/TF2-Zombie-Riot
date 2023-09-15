#pragma semicolon 1
#pragma newdecls required


enum struct SpawnerData
{
	int EntRef;
	bool BaseBoss;
	char Name[64];

	float Cooldown;
	float Points;
	bool Enabled;
}

static ArrayList SpawnerList;
static ConVar MapSpawnersActive;
static float HighestPoints;

void Spawns_PluginStart()
{
	MapSpawnersActive = CreateConVar("zr_spawnersactive", "4", "How many spawners are active by default,", _, true, 0.0, true, 32.0);
}

void Spawns_MapEnd()
{
	delete SpawnerList;
}

bool Spawns_CanSpawnNext()
{
	SpawnerData spawn;
	float gameTime = GetGameTime();

	//bool error = true;
	int length = SpawnerList.Length;
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		if(!spawn.Enabled)	// Disabled, ignore
			continue;
		
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(i);
			i--;
			length--;
			continue;
		}

		if(!spawn.BaseBoss && GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled"))	// Map disabled, ignore
			continue;
		
		//error = false;
		if(spawn.Cooldown < gameTime)
			return true;
	}

	//if(error)
	//	PrintToChatAll("ERROR NO ACTIVE SPAWNS %d", length);
	
	return false;
}

bool Spawns_GetNextPos(float pos[3], float ang[3], const char[] name = NULL_STRING, float cooldownOverride = -1.0)
{
	SpawnerData spawn;
	float gameTime = GetGameTime();

	int bestIndex = -1;
	float bestPoints = 0.0;

	int nonBossSpawners;
	int length = SpawnerList.Length;
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		if(name[0])
		{
			if(!StrEqual(name, spawn.Name))	// Invalid name, ignore
				continue;
		}
		else if(!spawn.Enabled)	// Disabled, ignore
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
			nonBossSpawners++;

			if(GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled"))	// Map disabled, ignore
				continue;
		}
		
		if((spawn.Cooldown < gameTime && spawn.Points > bestPoints) || (name[0] && bestIndex == -1))
		{
			bestIndex = i;
			bestPoints = spawn.Points;
		}
	}

	if(bestIndex == -1)
		return false;
	
	SpawnerList.GetArray(bestIndex, spawn);
	GetEntPropVector(spawn.EntRef, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(spawn.EntRef, Prop_Data, "m_angRotation", ang);
	
	if(cooldownOverride < 0.0)	// Normal cooldown time
	{
		if(nonBossSpawners == 1)
		{
			spawn.Cooldown = gameTime + (0.30 / MultiGlobal);
		}
		else
		{
			float nearSpeedUp = 4.0 * (spawn.Points / HighestPoints);
			if(nearSpeedUp < 1.0)
				nearSpeedUp = 1.0;

			float playerSpeedUp = 1.0 + (MultiGlobal * 0.5);
			
			float baseTime = 2.0 + (nonBossSpawners * 0.15);

			// player = 1.0 + (1.5) = 2.5
			// baseTime = 2.0 + (6 * 0.15) = 2.9
			// 2.9 / 2.5 = 1.16 slowest
			// 1.16 / 4 = 0.29 fastest

			spawn.Cooldown = gameTime + (baseTime / nearSpeedUp / playerSpeedUp);
		}
	}
	else	// Override cooldown time
	{
		spawn.Cooldown = gameTime + cooldownOverride;
	}
	
	SpawnerList.SetArray(bestIndex, spawn);
	return true;
}

void Spawns_AddToArray(int ref, bool base_boss = false)
{
	if(!SpawnerList)
		SpawnerList = new ArrayList(sizeof(SpawnerData));
	
	if(SpawnerList.FindValue(ref, SpawnerData::EntRef) == -1)
	{
		SpawnerData spawn;

		spawn.EntRef = ref;
		spawn.BaseBoss = base_boss;
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
		spawn.Points = 0.0;
		SpawnerList.SetArray(index, spawn);	
	}
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(GetClientTeam(client)==2 && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0 && IsPlayerAlive(client))
			{
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);

				for(int index; index < length; index++)
				{
					SpawnerList.GetArray(index, spawn);
					
					int entity_Ref = spawn.EntRef;

					GetEntPropVector(entity_Ref, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp_2);
					float distance = GetVectorDistance( f3_PositionTemp, f3_PositionTemp_2, true); 
					//leave it all squared for optimsation sake!
					//max distance is 10,000 anymore and wtf u doin
					if( distance < 100000000.0)
					{
						//For Zr_lila_panic.
						if(StrEqual(spawn.Name, "underground"))
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
						}
							
						float inverting_score_calc;
						inverting_score_calc = ( distance / 100000000.0);
						inverting_score_calc -= 1.0;
						inverting_score_calc *= -1.0;
                        
						spawn.Points += inverting_score_calc;
						SpawnerList.SetArray(index, spawn);							
					}
				}
			}
		}
	}

	// Get max spawner count
	int maxSpawners = Rogue_Mode() ? 1 : MapSpawnersActive.IntValue;

	// Get list of points
	ArrayList pointsList = new ArrayList();
	for(int index; index < length; index++)
	{
		SpawnerList.GetArray(index, spawn);
		if(spawn.BaseBoss)
			maxSpawners++;
		
		pointsList.Push(spawn.Points);
    }
	
	if(maxSpawners > length)
		maxSpawners = length;

	// Sort points
	pointsList.Sort(Sort_Ascending, Sort_Float);
	
	// Get points of the X ranked score
	HighestPoints = pointsList.Get(0);
	float minPoints = pointsList.Get(maxSpawners - 1);

	// Enable if meet requirement
	for(int index; index < length; index++)
	{
		SpawnerList.GetArray(index, spawn);
		spawn.Enabled = spawn.Points >= minPoints;
		SpawnerList.SetArray(index, spawn);
	}
}

int GetRandomActiveSpawner()
{
	SpawnerData spawn;
	
	int length = SpawnerList.Length;
	for(int i; i < length; i++)
	{
		SpawnerList.GetArray(i, spawn);
		
		if(!spawn.Enabled)	// Disabled, ignore
			continue;
		
		if(!IsValidEntity(spawn.EntRef))	// Invalid entity, remove
		{
			SpawnerList.Erase(i);
			i--;
			length--;
			continue;
		}

		if(!spawn.BaseBoss && GetEntProp(spawn.EntRef, Prop_Data, "m_bDisabled"))	// Map disabled, ignore
			continue;
		
		return spawn.EntRef;
	}
	return -1;
}