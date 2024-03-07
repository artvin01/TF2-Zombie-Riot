#pragma semicolon 1
#pragma newdecls required

enum struct TrainEnum
{
	int Index;
	char Name[32];
	Function Research;
	int Price[Resource_MAX];
	float Time;

	bool Has()
	{
		return view_as<bool>(this.Index);
	}
	void Reset()
	{
		this.Index = 0;
	}
}

static Handle TrainTimer[MAXENTITIES];
static TrainEnum TrainQueue[MAXENTITIES][14];
static TrainEnum TrainCurrent[MAXENTITIES];
static float TrainStartAt[MAXENTITIES];
static float TrainFinishAt[MAXENTITIES];

void ObjectTraining_Create(int entity)
{
	TrainTimer[entity] = CreateTimer(0.2, ThinkTimer, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	for(int i; i < sizeof(TrainQueue[]); i++)
	{
		TrainQueue[entity][i].Reset();
	}

	TrainCurrent[entity].Reset();
}

void ObjectTraining_Destory(int entity)
{
	delete TrainTimer[entity];
	CancelTrainCurrent(entity);
	CancelTrainQueued(entity);
}

static Action ThinkTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		return Plugin_Stop;
	
	bool refreshed;
	if(TrainCurrent[entity].Has())
	{
		if(TrainFinishAt[entity] < GetGameTime(entity))
		{
			int team = GetTeam(entity);
			
			if(TrainCurrent[entity].Research == INVALID_FUNCTION)
			{
				// TODO: Spawn outside the building
				float pos[3];
				WorldSpaceCenter(entity, pos);
				pos[2] += 300.0;
				NPC_CreateById(TrainCurrent[entity].Index, team, pos, {0.0, 0.0, 0.0});
			}
			else
			{
				Call_StartFunction(null, TrainCurrent[entity].Research);
				Call_PushCell(entity);
				Call_PushCell(team);
				Call_Finish();
			}
			
			Stats[entity].SupplyBonus = 0;
			TrainCurrent[entity].Reset();
			refreshed = true;
		}
	}
	
	if(!TrainCurrent[entity].Has() && TrainQueue[entity][0].Has())
	{
		int team = GetTeam(entity);
		
		if(TrainQueue[entity][0].Price[Resource_Supply] < 1 || TrainQueue[entity][0].Price[Resource_Supply] <= RTS_CheckSupplies(team))
		{
			TrainCurrent[entity] = TrainQueue[entity][0];
			TrainStartAt[entity] = GetGameTime(entity);
			TrainFinishAt[entity] = TrainStartAt[entity] + TrainCurrent[entity].Time;
			Stats[entity].SupplyBonus = TrainCurrent[entity].Price[Resource_Supply];
			refreshed = true;

			for(int i = 1; i < sizeof(TrainQueue[]); i++)
			{
				TrainQueue[entity][i - 1] = TrainQueue[entity][i];
			}
		}
	}

	if(refreshed)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			ArrayList selection = RTSCamera_GetSelected(client);
			if(selection && selection.FindValue(ref) != -1)
			{
				RTSMenu_Update(client);
			}
		}
	}

	return Plugin_Continue;
}

static void CancelTrainCurrent(int entity)
{
	if(TrainCurrent[entity].Has())
	{
		int team = GetTeam(entity);
		
		for(int b = 1; b < Resource_MAX; b++)
		{
			Resource[team][b] += TrainCurrent[entity].Price[b];
		}

		Stats[entity].SupplyBonus = 0;
		TrainCurrent[entity].Reset();
	}
}

static void CancelTrainQueued(int entity)
{
	int team = GetTeam(entity);
	
	for(int a; a < sizeof(TrainQueue[]); a++)
	{
		if(!TrainQueue[entity][a].Has())
			break;

		for(int b = 1; b < Resource_MAX; b++)
		{
			Resource[team][b] += TrainQueue[entity][a].Price[b];
		}

		TrainQueue[entity][a].Reset();
	}
}

bool ObjectTraining_ClearSkill(int entity, int client, bool use, SkillEnum skill)
{
	if(!TrainCurrent[entity].Has())
		return false;
	
	if(use)
	{
		CancelTrainCurrent(entity);
		
		if(RTSCamera_HoldingCtrl(client))
			CancelTrainQueued(entity);

		TriggerTimer(TrainTimer[entity]);
	}
	else
	{
		strcopy(skill.Formater, sizeof(skill.Formater), "Cancel Of");
		strcopy(skill.Name, sizeof(skill.Name), TrainCurrent[entity].Name);
		strcopy(skill.Desc, sizeof(skill.Desc), "Cancel All");
	}
	
	return true;
}

bool ObjectTraining_SkillUnit(int entity, int client, const char[] name, bool use, SkillEnum skill)
{
	static NPCData data;
	int id = NPC_GetByPlugin(name, data);
	if(id == -1)
		return false;
	
	int team = GetTeam(entity);
	RTS_UnitPriceChanges(team, data);
	
	if(use)
	{
		bool lowSupply, poor;
		int start = RTSCamera_HoldingCtrl(client) ? 5 : 1;
		int count = start;
		for(int i; i < sizeof(TrainQueue[]); i++)
		{
			if(!TrainQueue[entity][i].Has())
			{
				for(int b; b < Resource_MAX; b++)
				{
					if(data.Price[b] > Resource[team][b])
					{
						if(b == Resource_Supply)
						{
							lowSupply = true;
						}
						else
						{
							poor = true;
						}

						break;
					}
				}

				if(poor)
					break;

				TrainQueue[entity][i].Index = id;
				TrainQueue[entity][i].Research = INVALID_FUNCTION;
				TrainQueue[entity][i].Time = data.TrainTime;
				TrainQueue[entity][i].Price = data.Price;
				strcopy(TrainQueue[entity][i].Name, sizeof(TrainQueue[][].Name), data.Name);
				
				for(int b = 1; b < Resource_MAX; b++)
				{
					Resource[team][b] -= data.Price[b];
				}

				count--;
				if(count < 1)
					break;
			}
		}
		
		if(count == start)
		{
			if(lowSupply)
			{
				RTS_DisplayMessage(client, "Not enough supply");
			}
			else if(poor)
			{
				RTS_DisplayMessage(client, "Not enough resources");
			}
			else
			{
				RTS_DisplayMessage(client, "Building queue is full");
			}
		}
		
		TriggerTimer(TrainTimer[entity]);
	}
	else
	{
		strcopy(skill.Formater, sizeof(skill.Formater), "Create Of");
		strcopy(skill.Name, sizeof(skill.Name), data.Name);
		Format(skill.Desc, sizeof(skill.Desc), "%s Desc", data.Name);
		skill.Price = data.Price;

		bool active = TrainCurrent[entity].Index == id;
		skill.Count = active ? 1 : 0;
		
		for(int a; a < sizeof(TrainQueue[]); a++)
		{
			if(TrainQueue[entity][a].Index == id)
				skill.Count++;
		}

		if(active)
		{
			skill.Cooldown = TrainFinishAt[entity] - GetGameTime(entity);
		}
		else if(skill.Count)
		{
			skill.Cooldown = 9999.9;
		}
	}
	
	return true;
}

bool ObjectTraining_SkillResearch(int entity, int client, const char[] name, Function func, const int price[Resource_MAX], float time, bool use, SkillEnum skill)
{
	int team = GetTeam(entity);
	
	if(use)
	{
		bool found = (TrainCurrent[entity].Has() && TrainCurrent[entity].Research == func);

		if(!found)
		{
			for(int a; a < sizeof(TrainQueue[]); a++)
			{
				if(TrainQueue[entity][a].Has())
				{
					if(TrainQueue[entity][a].Research != func)
						continue;
					
					found = true;
				}

				break;
			}
		}

		if(found)
			return true;
		
		bool poor;
		for(int i; i < sizeof(TrainQueue[]); i++)
		{
			if(!TrainQueue[entity][i].Has())
			{
				for(int b = 1; b < Resource_MAX; b++)
				{
					if(price[b] > Resource[team][b])
					{
						poor = true;
						break;
					}
				}

				if(poor)
					break;

				TrainQueue[entity][i].Index = -1;
				TrainQueue[entity][i].Research = func;
				TrainQueue[entity][i].Time = time;
				TrainQueue[entity][i].Price = price;
				strcopy(TrainQueue[entity][i].Name, sizeof(TrainQueue[][].Name), name);
				
				for(int b = 1; b < Resource_MAX; b++)
				{
					Resource[team][b] -= price[b];
				}

				found = true;
				break;
			}
		}
		
		if(!found)
		{
			if(poor)
			{
				RTS_DisplayMessage(client, "Not enough resources");
			}
			else
			{
				RTS_DisplayMessage(client, "Building queue is full");
			}
		}
		
		TriggerTimer(TrainTimer[entity]);
	}
	else
	{
		strcopy(skill.Formater, sizeof(skill.Formater), "Research Of");
		strcopy(skill.Name, sizeof(skill.Name), name);
		Format(skill.Desc, sizeof(skill.Desc), "%s Desc", name);
		skill.Price = price;

		bool active = (TrainCurrent[entity].Has() && TrainCurrent[entity].Research == func);
		skill.Count = active ? 1 : 0;
		
		if(!active)
		{
			for(int a; a < sizeof(TrainQueue[]); a++)
			{
				if(TrainQueue[entity][a].Has())
				{
					if(TrainQueue[entity][a].Research != func)
						continue;
					
					skill.Count = 1;
				}

				break;
			}
		}

		if(active)
		{
			skill.Cooldown = TrainFinishAt[entity] - GetGameTime(entity);
		}
		else if(skill.Count)
		{
			skill.Cooldown = 9999.9;
		}
	}
	
	return true;
}
