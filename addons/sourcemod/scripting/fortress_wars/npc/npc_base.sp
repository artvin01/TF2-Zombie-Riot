#pragma semicolon 1
#pragma newdecls required

#define MELEE_RANGE_SQR	6500.0

enum struct CommandEnum
{
	int Type;
	float Pos[3];
	int TargetRef;
}

static float SoundCooldown[MAXTF2PLAYERS];

static int UnitFlags[MAXENTITIES];
static float VisionRange[MAXENTITIES];
static float EngageRange[MAXENTITIES];
static char NextGesture[MAXENTITIES][32];
static ArrayList CommandList[MAXENTITIES];
static Function FuncSound[MAXENTITIES][Sound_MAX];
static Function FuncSkills[MAXENTITIES];
static StatEnum Stats[MAXENTITIES];

void UnitBody_Setup()
{
	Zero(SoundCooldown);
}

methodmap UnitBody < CClotBody
{
	property int m_iTeamNumber
	{
		public get()
		{
			return TeamNumber[this.index];
		}
		public set(int team)
		{
			TeamNumber[this.index] = team;
		}
	}

	property bool m_bBuilding
	{
		public get()
		{
			return i_NpcIsABuilding[this.index];
		}
		public set(bool value)
		{
			i_NpcIsABuilding[this.index] = value;
		}
	}

	// Range at which units can provide vision
	property float m_flVisionRange
	{
		public get()
		{
			return VisionRange[this.index];
		}
		public set(float value)
		{
			VisionRange[this.index] = value;
		}
	}

	// Range at which units will target automatically
	property float m_flEngageRange
	{
		public get()
		{
			return EngageRange[this.index];
		}
		public set(float value)
		{
			EngageRange[this.index] = value;
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
		return view_as<bool>(UnitFlags[this.index] & (1 << type));
	}

	public void AddNextGesture(const char[] anim)
	{
		strcopy(NextGesture[this.index], sizeof(NextGesture[]), anim);
	}

	public void SetSoundFunc(int type, Function func)
	{
		FuncSound[this.index][type] = func;
	}
	public void SetSkillFunc(Function func)
	{
		FuncSkills[this.index] = func;
	}

	public void GetStats(StatEnum stats)
	{
		stats = Stats[this.index];
	}
	public void SetStats(const StatEnum stats = {})
	{
		Stats[this.index] = stats;
	}

	public void AddCommand(bool override, int type, const float pos[3], int target = -1)
	{
		if(override)
			delete CommandList[this.index];
		
		CommandEnum command;
		command.Type = type;
		command.TargetRef = target == -1 ? -1 : EntIndexToEntRef(target);
		command.Pos = pos;

		if(!CommandList[this.index])
			CommandList[this.index] = new ArrayList(sizeof(CommandEnum));
		
		CommandList[this.index].PushArray(command);

		if(override && type == Command_Patrol)
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

	public bool IsAlly(int team)
	{
		return RTS_IsTeamAlly(team, this.m_iTeamNumber);
	}
	public bool CanControl(int team)
	{
		return RTS_CanTeamControl(team, this.m_iTeamNumber);
	}
	
	public UnitBody(int team, const float vecPos[3], const float vecAng[3],
						const char[] model = COMBINE_CUSTOM_MODEL,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isBuilding = false,
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		UnitBody npc = view_as<UnitBody>(CClotBody(vecPos, vecAng, model, modelscale, health, isGiant, CustomThreeDimensions));
		
		npc.m_iTeamNumber = team;
		npc.m_bBuilding = isBuilding;
		npc.m_flVisionRange = 0.0;
		npc.RemoveAllFlags();
		NextGesture[npc.index][0] = 0;
		delete CommandList[npc.index];
		npc.SetStats();
		npc.SetSkillFunc(INVALID_FUNCTION);

		for(int i; i < Sound_MAX; i++)
		{
			npc.SetSoundFunc(i, INVALID_FUNCTION);
		}

		return npc;
	}
}

bool UnitBody_IsEntAlly(int attacker, int entity)
{
	return view_as<UnitBody>(entity).IsAlly(TeamNumber[attacker]);
}

bool UnitBody_CanControl(int attacker, int entity)
{
	return view_as<UnitBody>(entity).CanControl(TeamNumber[attacker]);
}

bool UnitBody_HasFlag(int entity, int flag)
{
	return view_as<UnitBody>(entity).HasFlag(flag);
}

void UnitBody_AddCommand(int entity, bool override, int type, const float pos[3], int target = -1)
{
	view_as<UnitBody>(entity).AddCommand(override, type, pos, target);
}

void UnitBody_GetStats(int entity, StatEnum stats)
{
	view_as<UnitBody>(entity).GetStats(stats);
}

void UnitBody_TakeDamage(int victim, float &damage, int damagetype)
{
	int dmg = RoundFloat(damage);

	if(dmg > 0)
	{
		if(damagetype & DMG_SLASH)
		{
		}
		else if(damagetype & DMG_CLUB)
		{
			dmg -= Stats[victim].MeleeArmor + Stats[victim].MeleeArmorBonus;
		}
		else
		{
			dmg -= Stats[victim].RangeArmor + Stats[victim].RangeArmorBonus;
		}

		if(dmg < 1)
			dmg = 1;
	}

	damage = float(dmg);
}

void UnitBody_PlaySound(int entity, int client, int type)
{
	float gameTime = GetGameTime();
	if(SoundCooldown[client] > gameTime)
		return;
	
	if(FuncSound[entity][type] != INVALID_FUNCTION)
	{
		SoundCooldown[client] = gameTime + 1.5;
		
		Call_StartFunction(null, FuncSound[entity][type]);
		Call_PushCell(client);
		Call_Finish();
	}
}

bool UnitBody_GetSkill(int entity, int client, int type, SkillEnum skill)
{
	bool result;

	if(FuncSkills[entity] != INVALID_FUNCTION)
	{
		Call_StartFunction(null, FuncSkills[entity]);
		Call_PushCell(entity);
		Call_PushCell(client);
		Call_PushCell(type);
		Call_PushCell(false);
		Call_PushArrayEx(skill, sizeof(skill), SM_PARAM_COPYBACK);
		Call_Finish(result);
	}

	return result;
}

bool UnitBody_TriggerSkill(int entity, int client, int type)
{
	bool result;

	if(FuncSkills[entity] != INVALID_FUNCTION)
	{
		SkillEnum skill;

		Call_StartFunction(null, FuncSkills[entity]);
		Call_PushCell(entity);
		Call_PushCell(client);
		Call_PushCell(type);
		Call_PushCell(true);
		Call_PushArrayEx(skill, sizeof(skill), 0);
		Call_Finish(result);
	}

	return result;
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
		if(CommandList[npc.index] && CommandList[npc.index].Length)
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

			npc.AddCommand(false, command.Type, command.Pos, command.TargetRef);
		}
		
		bool foundTarget;
		int target = command.TargetRef == -1 ? -1 : EntRefToEntIndex(command.TargetRef);
		if(target > 0)
		{
			if(IsValidEnemy(npc.index, target, true))	// Following enemy
			{
				npc.m_iTargetWalkTo = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				command.Type = Command_Attack;	// Force to always attack
				foundTarget = true;
			}
			else if(IsValidEntity(target))	// Following something
			{
				
			}
			else	// Following target is now invalid
			{
				// Remove this command
				CommandList[npc.index].Erase(0);
				continue;
			}
		}
		
		bool canAttack;
		switch(command.Type)
		{
			case Command_Idle:
			{
				// Idle, no command
				canAttack = !npc.HasFlag(Flag_Worker);
			}
			case Command_Move:
			{
				// Only move, no attack
				canAttack = false;
			}
			case Command_Attack:
			{
				// Attack move
				canAttack = true;
			}
			case Command_HoldPos:
			{
				// Can attack, later code prevents moving
				canAttack = !npc.HasFlag(Flag_Worker);
			}
			case Command_Patrol:
			{
				// Attacks on patrol, workers patrol to auto repair
				canAttack = !npc.HasFlag(Flag_Worker);
			}
		}

		if(!foundTarget)
		{
			if(canAttack)
			{
				if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo, true))
				{

				}
				else if(i_TargetToWalkTo[npc.index] != -1 || npc.m_flGetClosestTargetTime < gameTime)
				{
					// Had an existing target or time as passed
					target = GetClosestTargetRTS(npc.index, npc.m_flEngageRange, _, _, _, _, closestTargetFunction);
					npc.m_flGetClosestTargetTime = gameTime + 1.0;
				}
				else
				{
					target = -1;
				}
			}
			else
			{
				target = -1;
			}

			npc.m_iTargetWalkTo = target;
		}

		return target;
	}
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
			//Predict their pos.
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

			bool nextCommand = true;
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
