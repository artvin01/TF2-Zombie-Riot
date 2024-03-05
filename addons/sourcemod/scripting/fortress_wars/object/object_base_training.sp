#pragma semicolon 1
#pragma newdecls required

enum struct TrainEnum
{
	int Index;
	Function Research;
	int Price[Resource_MAX];

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
}

static Action ThinkTimer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity == -1)
		return Plugin_Stop;
	
	bool refreshed;
	if(TrainCurrent[entity].Has())
	{

	}
	
	if(!TrainCurrent[entity].Has())
	{

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
			if(data.Price[b] > Resource[team][b])
			{
				poor = true;
				break;
			}
		}

		Stats[entity].SupplyBonus = 0;
		TrainCurrent[entity].Reset();
	}
}

bool ObjectTraining_ClearSkill(int entity, bool use, SkillEnum skill)
{
	if(TrainCurrent[entity] == -1)
		return false;
	
	if(use)
	{
		TriggerTimer(TrainTimer[entity]);
	}
	else
	{
		strcopy(skill.Formater, sizeof(skill.Formater), "Cancel Of");
		NPC_GetNameById(TrainCurrent[entity], skill.Name, sizeof(skill.Name));
		strcopy(skill.Desc, sizeof(skill.Desc), "Cancel All");
	}
	
	return true;
}

bool ObjectTraining_Skill(int entity, int client, const char[] name, bool use, SkillEnum skill)
{
	static NPCData data;
	int id = NPC_GetByPlugin(name, data);
	if(id == -1)
		return false;
	
	int team = GetTeam(entity);
	RTS_UnitPriceChanges(team, data);
	
	if(use)
	{
		bool poor;
		int start = RTSCamera_HoldingCtrl(client) ? 5 : 1;
		int count = start;
		for(int i; i < sizeof(TrainQueue[]); i++)
		{
			if(TrainQueue[i] == -1)
			{
				for(int b = 1; b < Resource_MAX; b++)
				{
					if(data.Price[b] > Resource[team][b])
					{
						poor = true;
						break;
					}
				}

				if(poor)
					break;

				TrainQueue[i] = id;

				for(int b = 1; b < Resource_MAX; b++)
				{
					Resource[team][b] -= data.Price[b];
				}

				if(--count < 1)
					break;
			}
		}
		
		if(count == start)
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
		strcopy(skill.Formater, sizeof(skill.Formater), "Create Of");
		strcopy(skill.Name, sizeof(skill.Name), data.Name);
		Format(skill.Desc, sizeof(skill.Desc), "%s Desc", data.Name);
		skill.Price = data.Price;
	}
	
	return true;
}