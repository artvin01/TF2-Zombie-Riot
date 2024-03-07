#pragma semicolon 1
#pragma newdecls required

enum struct CommandEnum
{
	int Type;
	float Pos[3];
	int TargetRef;
	int Data;
}

static int ResourceSearch;

static char NextGesture[MAXENTITIES][32];
static ArrayList CommandList[MAXENTITIES];

void UnitBody_Setup()
{
}

methodmap UnitBody < CClotBody
{
	property Function m_hDeathFunc
	{
		public set(Function value)
		{
			func_NPCDeath[this.index] = value;
		}
	}
	property Function m_hOnTakeDamageFunc
	{
		public set(Function value)
		{
			func_NPCOnTakeDamage[this.index] = value;
		}
	}
	property Function m_hThinkFunc
	{
		public set(Function value)
		{
			func_NPCThink[this.index] = value;
		}
	}

	public void SetName(const char[] name)
	{
		strcopy(c_NpcName[this.index], sizeof(c_NpcName[]), name);
	}

	// Range at which units can provide vision
	property float m_flVisionRange
	{
		public get()
		{
			return (Stats[this.index].Sight + Stats[this.index].SightBonus) * OBJECT_UNITS;
		}
	}

	// Range at which units will target automatically
	property float m_flEngageRange
	{
		public get()
		{
			int range = Stats[this.index].Range + Stats[this.index].RangeBonus;
			if(range < 4)
				range = 4;
			
			return range * OBJECT_UNITS;
		}
	}

	public void AddFlag(int type)
	{
		UnitFlags[this.index] |= (1 << type);
	}
	public void RemoveFlag(int type)
	{
		UnitFlags[this.index] &= ~(1 << type);
	}
	public void RemoveAllFlags()
	{
		UnitFlags[this.index] = 0;
	}
	public bool HasFlag(int type)
	{
		return RTS_HasFlag(this.index, type);
	}

	public void AddNextGesture(const char[] anim)
	{
		strcopy(NextGesture[this.index], sizeof(NextGesture[]), anim);
	}

	public void SetSoundFunc(int type, Function func)
	{
		FuncSound[this.index][type] = func;
	}
	property Function m_hSkillsFunc
	{
		public set(Function value)
		{
			FuncSkills[this.index] = value;
		}
	}

	public void ClearStats(const StatEnum stats = {})
	{
		Stats[this.index] = stats;
	}

	public void AddCommand(int method, int type, const float pos[3], int target = -1)
	{
		if(method == 1)
		{
			delete CommandList[this.index];
			this.m_flGetClosestTargetTime = 0.0;
		}
		
		CommandEnum command;
		SetupCommand(this, command, type, pos, target);

		if(!CommandList[this.index])
			CommandList[this.index] = new ArrayList(sizeof(CommandEnum));
		
		if(method == 2 && CommandList[this.index].Length)
		{
			CommandList[this.index].ShiftUp(0);
			CommandList[this.index].SetArray(0, command);
		}
		else
		{
			CommandList[this.index].PushArray(command);
		}

		if(method == 1 && type == Command_Patrol)
		{
			// Keep our current position when starting a patrol
			command.TargetRef = -1;
			GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", command.Pos);
			CommandList[this.index].PushArray(command);
		}
	}
	public void DealDamage(int victim, float multi = 1.0, int damageType = DMG_GENERIC, const float damageForce[3] = NULL_VECTOR, const float damagePosition[3] = NULL_VECTOR)
	{
		int damage = RoundFloat(Stats[this.index].Damage * multi) + Stats[this.index].DamageBonus;

		// Check for extra damage vs flags
		for(int i; i < Flag_MAX; i++)
		{
			if((Stats[this.index].ExtraDamage[i] || Stats[this.index].ExtraDamageBonus[i]) && view_as<UnitBody>(victim).HasFlag(i))
				damage += RoundFloat(Stats[this.index].ExtraDamage[i] * multi) + Stats[this.index].ExtraDamageBonus[i];
		}

		SDKHooks_TakeDamage(victim, this.index, this.index, float(damage), damageType, _, damageForce, damagePosition);
	}
	public bool InAttackRange(int target)
	{
		float rangesqr = MELEE_RANGE_SQR;
		if(Stats[this.index].Range > 1)
		{
			rangesqr = (Stats[this.index].Range + Stats[this.index].RangeBonus) * OBJECT_UNITS;
			rangesqr *= rangesqr;
		}
		
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(this.index, vecMe);
		WorldSpaceCenter(target, vecTarget);
		
		Handle trace = TR_TraceRayFilterEx(vecMe, vecTarget, MASK_SOLID, RayType_EndPoint, AttackRangeTrace, target);
		TR_GetEndPosition(vecTarget, trace);
		delete trace;

		float dist = GetVectorDistance(vecMe, vecTarget, true);
		return dist < rangesqr;
	}
	
	public UnitBody(int team, const float vecPos[3], const float vecAng[3],
						const char[] model = COMBINE_CUSTOM_MODEL,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		UnitBody npc = view_as<UnitBody>(CClotBody(vecPos, vecAng, model, modelscale, health, isGiant, CustomThreeDimensions));
		
		SetTeam(npc.index, team);
		npc.RemoveAllFlags();
		NextGesture[npc.index][0] = 0;
		delete CommandList[npc.index];
		npc.ClearStats();
		npc.m_hSkillsFunc = INVALID_FUNCTION;

		for(int i; i < Sound_MAX; i++)
		{
			npc.SetSoundFunc(i, INVALID_FUNCTION);
		}

		return npc;
	}
}

static bool AttackRangeTrace(int entity, int contentsMask, int match)
{
	return entity == match;
}

static void SetupCommand(UnitBody npc, CommandEnum command, int type, const float pos[3], int target)
{
	command.Type = type;
	command.TargetRef = target == -1 ? -1 : EntIndexToEntRef(target);
	command.Pos = pos;

	if(target != -1 && command.Type <= Command_HoldPos)
	{
		if(IsObject(target))
		{
			if(npc.HasFlag(Flag_Worker))
			{
				command.Type = Command_WorkOn;
				command.Data = Object_GetResource(target);
			}
			else
			{
				command.Type = Command_Attack;
			}
		}
		else if(!RTS_IsEntAlly(npc.index, target))
		{
			command.Type = Command_Attack;
		}
	}
}

void UnitBody_AddCommand(int entity, int method, int type, const float pos[3], int target = -1)
{
	view_as<UnitBody>(entity).AddCommand(method, type, pos, target);
}

bool UnitBody_GetCommand(int entity, int i, int &type, float pos[3], int &target)
{
	int actions = CommandList[entity].Length;
	if(i < actions)
	{
		CommandEnum command;
		CommandList[entity].GetArray(i, command);
		type = command.Type;
		pos = command.Pos;
		target = EntRefToEntIndex(command.TargetRef);
		return true;
	}

	return false;
}

bool UnitBody_ThinkStart(UnitBody npc, float gameTime)
{
	if(npc.m_flNextDelayTime > gameTime)
		return false;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	
	
	if(NextGesture[npc.index][0])
	{
		npc.AddGesture(NextGesture[npc.index], false);
		NextGesture[npc.index][0] = 0;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return false;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	return true;
}

int UnitBody_ThinkTarget(UnitBody npc, float gameTime, Function closestTargetFunction = INVALID_FUNCTION)
{
	CommandEnum command;

	for(;;)
	{
		int length = CommandList[npc.index] ? CommandList[npc.index].Length : 0;
		if(length)
		{
			// Oldest command
			CommandList[npc.index].GetArray(0, command);
		}
		else
		{
			// Default behaviour
			command.Type = Command_Idle;
			GetAbsOrigin(npc.index, command.Pos);
			command.TargetRef = -1;

			npc.AddCommand(0, command.Type, command.Pos, command.TargetRef);
		}
		
		bool foundTarget;
		int target = -1;
		if(command.TargetRef != -1)
		{
			target = EntRefToEntIndex(command.TargetRef);
			if(IsValidEnemy(npc.index, target, true))	// Following enemy
			{
				npc.m_iTargetWalkTo = target;
				npc.m_flGetClosestTargetTime = gameTime + 0.5;

				command.Type = Command_Attack;	// Force to always attack
				foundTarget = true;
			}
			else if(IsValidEntity(target))
			{
				// Following something
			}
			else if(command.Type == Command_WorkOn && length == 1)
			{
				// Resource gone, find a new one (if it's our only command)
				target = -1;
			}
			else	// Following target is now invalid
			{
				// Remove this command
				CommandList[npc.index].Erase(0);
				npc.m_flGetClosestTargetTime = 0.0;
				continue;
			}
		}
		
		bool canAttack;
		switch(command.Type)
		{
			case Command_Idle,	// Idle, no command
				Command_HoldPos,// Can attack, later code prevents moving
				Command_Patrol:	// Attacks on patrol, workers patrol to auto repair
			{
				
				canAttack = !npc.HasFlag(Flag_Worker);
			}
			case Command_Move:	// Only move, no attack
			{
				canAttack = false;
			}
			case Command_Attack:	// Attack move
			{
				canAttack = true;
			}
			case Command_WorkOn:	// Harvesting a resource
			{
				canAttack = false;

				if(target == -1 && command.Data)
				{
					ResourceSearch = command.Data;
					target = GetClosestTargetRTS(npc.index, _, npc.m_flVisionRange, _, _, _, _, ResourceSearchFunction);
					if(target == -1)
					{
						// No nearby resource
						CommandList[npc.index].Erase(0);
						continue;
					}
					else
					{
						// New resource
						command.TargetRef = EntIndexToEntRef(target);
						CommandList[npc.index].SetArray(0, command);
					}
				}
			}
		}

		if(!foundTarget)
		{
			if(canAttack)
			{
				if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true))
				{
					target = npc.m_iTargetWalkTo;
				}
				else if(i_TargetToWalkTo[npc.index] != -1 || npc.m_flGetClosestTargetTime < gameTime)
				{
					// Had an existing target or time as passed
					target = GetClosestTargetRTS(npc.index, _, npc.m_flEngageRange, _, _, _, _, closestTargetFunction);
					npc.m_iTargetWalkTo = target;
					npc.m_flGetClosestTargetTime = gameTime + 0.5;
				}
				else
				{
					target = -1;
					if(i_TargetToWalkTo[npc.index] != -1)
						npc.m_iTargetWalkTo = target;
				}
			}
			else
			{
				target = -1;
				if(i_TargetToWalkTo[npc.index] != -1)
					npc.m_iTargetWalkTo = target;
			}
		}

		return target;
	}
}

static bool ResourceSearchFunction(int entity, int target)
{
	return (IsObject(target) && Object_GetResource(target) == ResourceSearch);
}

// Make sure to call UnitBody_ThinkTarget before this
stock bool UnitBody_ThinkMove(UnitBody npc, float gameTime)
{
	int actions = CommandList[npc.index].Length;

	CommandEnum command;
	CommandList[npc.index].GetArray(0, command);

	int target = npc.m_iTargetWalkTo;
	if(target < 1)
		target = command.TargetRef == -1 ? -1 : EntRefToEntIndex(command.TargetRef);
	
	float vecMe[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe);

	if(target > 0 && command.Type != Command_HoldPos)
	{
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", command.Pos);

		float distance = GetVectorDistance(vecMe, command.Pos, true);
		if(distance < npc.GetLeadRadius())
		{
			PredictSubjectPosition(npc, target, _, _, command.Pos);
			npc.SetGoalVector(command.Pos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
	}
	else
	{
		// Move to location, then idle or move to next command
		float distance = GetVectorDistance(vecMe, command.Pos, true);
		if(distance < 2500.0)	// 50 HU
		{
			npc.StopPathing();

			bool nextCommand;
			switch(command.Type)
			{
				case Command_Idle, Command_HoldPos:
				{
					// Idle, move to next command if any

					if(actions > 1)
						nextCommand = true;
				}
				case Command_Move, Command_Attack:
				{
					// Moving, move to next command or idle

					if(actions > 1)
					{
						nextCommand = true;
					}
					else
					{
						command.Type = Command_Idle;
						CommandList[npc.index].SetArray(0, command);
					}
				}
				case Command_Patrol:
				{
					// Moving, move to next command and requeue current command

					if(actions > 1)
					{
						nextCommand = true;
						CommandList[npc.index].PushArray(command);
						actions++;
					}
					else
					{
						command.Type = Command_Idle;
						CommandList[npc.index].SetArray(0, command);
					}
				}
			}

			if(nextCommand)
				CommandList[npc.index].Erase(0);
		}
		else
		{
			npc.SetGoalVector(command.Pos);
			npc.StartPathing();
		}
	}

	return npc.m_bPathing;
}
