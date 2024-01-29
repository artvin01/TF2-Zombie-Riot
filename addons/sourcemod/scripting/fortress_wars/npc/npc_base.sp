#pragma semicolon 1
#pragma newdecls required

enum struct CommandEnum
{
	int Type;
	float Pos[3];
	int TargetRef;
}

static float SoundCooldown[MAXTF2PLAYERS];

static int OwnerUserId[MAXENTITIES];
static int UnitFlags[MAXENTITIES];
static float VisionRange[MAXENTITIES];
static float EngageRange[MAXENTITIES];
static char NextGesture[MAXENTITIES][32];
static ArrayList CommandList[MAXENTITIES];
static Function FuncSound[MAXENTITIES][Sound_MAX];

void UnitBody_MapStart()
{
	Zero(SoundCooldown);
}

methodmap UnitBody < CClotBody
{
	// Returns client index, 0 for none
	property int m_hOwner
	{
		public get()
		{
			return OwnerUserId[this.index] == -1 ? 0 : GetClientOfUserId(OwnerUserId[this.index]);
		}
		public set(int owner)
		{
			OwnerUserId[this.index] = owner > 0 ? GetClientUserId(owner) : -1;
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

	public void AddCommand(int type, const float pos[3], int target = -1)
	{
		CommandEnum command;
		command.Type = type;
		command.TargetRef = target == -1 ? -1 : EntIndexToEntRef(target);
		command.Pos = pos;

		if(!CommandList[this.index])
			CommandList[this.index] = new ArrayList(sizeof(CommandEnum));
		
		CommandList[this.index].PushArray(command);
	}

	public bool IsAlly(int attacker)
	{
		return RTS_IsPlayerAlly(attacker, this.m_hOwner);
	}
	public bool CanControl(int attacker)
	{
		return RTS_CanPlayerControl(attacker, this.m_hOwner);
	}
	
	public UnitBody(int client, const float vecPos[3], const float vecAng[3],
						const char[] model = COMBINE_CUSTOM_MODEL,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isBuilding = false,
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		UnitBody npc = view_as<UnitBody>(CClotBody(vecPos, vecAng, model, modelscale, health, isGiant, CustomThreeDimensions));
		
		npc.m_hOwner = client;
		npc.m_bBuilding = isBuilding;
		npc.m_flVisionRange = 0.0;
		npc.RemoveAllFlags();
		NextGesture[npc.index][0] = 0;
		delete CommandList[npc.index];

		for(int i; i < Sound_MAX; i++)
		{
			npc.SetSoundFunc(i, INVALID_FUNCTION);
		}

		return npc;
	}
}

bool UnitBody_IsAlly(int player, int entity)
{
	return view_as<UnitBody>(entity).IsAlly(player);
}

bool UnitBody_CanControl(int player, int entity)
{
	return view_as<UnitBody>(entity).CanControl(player);
}

void UnitBody_AddCommand(int entity, int type, const float pos[3], int target = -1)
{
	view_as<UnitBody>(entity).AddCommand(type, pos, target);
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

int UnitBody_ThinkTarget(UnitBody npc, float gameTime)
{
	CommandEnum command;

	for(;;)
	{
		int actions = CommandList[npc.index] ? CommandList[npc.index].Length : 0;
		if(actions)
		{
			// Oldest command
			CommandList[npc.index].GetArray(actions - 1, command);
		}
		else
		{
			// Default behaviour
			command.Type = Command_Idle;
			GetAbsOrigin(npc.index, command.Pos);
			command.TargetRef = -1;

			npc.AddCommand(command.Type, command.Pos, command.TargetRef);
		}
		
		bool foundTarget;
		int target = command.TargetRef == -1 ? -1 : EntRefToEntIndex(command.TargetRef);
		if(target > 0)
		{
			if(IsValidEnemy(npc.index, target))	// Following enemy
			{
				npc.m_iTarget = target;
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
				CommandList[npc.index].Erase(actions - 1);
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
			target = npc.m_iTarget;

			if(canAttack)	// No existing target and time as passed
				canAttack = (target < 1 && npc.m_flGetClosestTargetTime < gameTime);

			if(canAttack || !IsValidEnemy(npc.index, target))
			{
				if(canAttack)
				{
					target = GetClosestTargetRTS(npc.index, npc.m_flEngageRange);
				}
				else
				{
					target = -1;
				}

				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;
			}
		}

		return target;
	}
}

// Make sure to call UnitBody_ThinkTarget before this
stock bool UnitBody_ThinkMove(UnitBody npc, float gameTime)
{
	int actions = CommandList[npc.index].Length;

	CommandEnum command;
	CommandList[npc.index].GetArray(actions - 1, command);

	int target = npc.m_iTarget;
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
						CommandList[npc.index].SetArray(actions - 1, command);
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
						CommandList[npc.index].SetArray(actions - 1, command);
					}
				}
			}

			if(nextCommand)
				CommandList[npc.index].Erase(actions - 1);
		}
		else
		{
			npc.SetGoalVector(command.Pos);
			npc.StartPathing();
		}
	}

	return npc.m_bPathing;
}
