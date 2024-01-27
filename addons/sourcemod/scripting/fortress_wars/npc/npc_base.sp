#pragma semicolon 1
#pragma newdecls required

enum struct CommandEnum
{
	int Type;
	float Pos[3];
	int TargetRef;
}

static int OwnerUserId[MAXENTITIES];
static int UnitFlags[MAXENTITIES];
static float VisionRange[MAXENTITIES];
static float EngageRange[MAXENTITIES];
static char NextGesture[MAXENTITIES][32];
static ArrayList CommandList[MAXENTITIES];

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

	public void AddCommand(int type, int target = -1, const float pos[3] = NULL_VECTOR)
	{
		CommandEnum command;
		command.Type = type;
		command.TargetRef = target == -1 ? -1 : EntIndexToEntRef(target);
		command.Pos = pos;

		if(!CommandList[this.index])
			CommandList[this.index] = new ArrayList(CommandEnum);
		
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

void UnitBody_AddCommand(int entity, int type, int target = -1, const float pos[3] = NULL_VECTOR)
{
	view_as<UnitBody>(entity).AddCommand(type, target, pos);
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

	do
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

			npc.AddCommand(command);
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
			}
		}

		return target;
	}
	while(CommandList[npc.index]);

	return -1;	// Should never happen
}

// Make sure to call UnitBody_ThinkTarget before this
bool UnitBody_ThinkMove(UnitBody npc, float gameTime)
{
	int actions = CommandList[npc.index].Length;

	CommandEnum command;
	CommandList[npc.index].GetArray(actions - 1, command);

	int taget = npc.m_iTarget;
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
			PredictSubjectPosition(npc, target);
			NPC_SetGoalVector(npc.index, vecTarget);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, target);
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
				CommandList[npc.index].Erase(actions - 1, command);
		}
		else
		{
			NPC_SetGoalVector(npc.index, command.Pos);
			npc.StartPathing();
		}
	}

	return npc.m_bPathing;
}

/*
void UnitBody_ThinkMove(int iNPC, float speed, const char[] idleAnim = "", const char[] moveAnim = "", float canRetreat = 0.0, bool move = true, bool sound=true)
{
	UnitBody npc = view_as<UnitBody>(iNPC);

	bool pathed;
	float gameTime = GetGameTime(npc.index);
	if(move && npc.m_flReloadDelay < gameTime)
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		int command = client ? (npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride) : Command_Aggressive;

		float myPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", myPos);

		if(f3_SpawnPosition[client][0] && command == Command_HoldPosBarracks)
		{
			f3_SpawnPosition[npc.index] = f3_SpawnPosition[client];
		}
		
		bool retreating = (command == Command_Retreat || command == Command_RetreatPlayer || command == Command_RTSMove);

		if(IsValidEntity(npc.m_iTarget) && canRetreat > 0.0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", vecTarget);
			float flDistanceToTarget;
			if(command == Command_HoldPosBarracks)
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			}
			else
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			}

			if(flDistanceToTarget < canRetreat)
			{
				vecTarget = BackoffFromOwnPositionAndAwayFromEnemyOld(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vecTarget);
				
				npc.StartPathing();
				pathed = true;
			}
		}
		else
		{
			npc.m_iTarget = 0;
		}

		if(!pathed && IsValidEntity(npc.m_iTargetRally) && npc.m_iTargetRally > 0 && command != Command_HoldPos && !retreating)
		{
			float vecTarget[3];
			GetEntPropVector(npc.m_iTargetRally, Prop_Data, "m_vecAbsOrigin", vecTarget);

			float flDistanceToTarget;
			if(command == Command_HoldPosBarracks)
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, f3_SpawnPosition[npc.index], true);
			}
			else
			{
				flDistanceToTarget = GetVectorDistance(vecTarget, myPos, true);
			}
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				//Predict their pos.
				vecTarget = PredictSubjectPositionOld(npc, npc.m_iTargetRally);
				NPC_SetGoalVector(npc.index, vecTarget);

				npc.StartPathing();
				pathed = true;
			}
			else
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTargetRally);

				npc.StartPathing();
				pathed = true;
			}
		}
		
		if(!pathed && IsValidEntity(npc.m_iTargetAlly) && command != Command_Aggressive)
		{
			if(command != Command_HoldPos && command != Command_HoldPosBarracks && command != Command_RTSMove && command != Command_RTSAttack)
			{
				float vecTarget[3];
				if(npc.m_iTargetAlly <= MaxClients && f3_SpawnPosition[npc.index][0] && npc.m_flComeToMe >= (gameTime + 0.6))
				{
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", vecTarget);
					if(GetVectorDistance(myPos, vecTarget, true) > (100.0 * 100.0))
					{
						// Too far away from the mounter
						npc.m_flComeToMe = gameTime + 0.5;
					}
				}

				if(npc.m_flComeToMe < gameTime)
				{
					npc.m_flComeToMe = gameTime + 0.5;

					float originalVec[3];
					GetEntPropVector(npc.m_iTargetAlly, Prop_Data, "m_vecAbsOrigin", originalVec);
					vecTarget = originalVec;

					if(npc.m_iTargetAlly <= MaxClients)
					{
						vecTarget[0] += GetRandomFloat(-50.0, 50.0);
						vecTarget[1] += GetRandomFloat(-50.0, 50.0);
					}
					else
					{
						vecTarget[0] += GetRandomFloat(-300.0, 300.0);
						vecTarget[1] += GetRandomFloat(-300.0, 300.0);
					}
					vecTarget[2] += 50.0;
					Handle trace = TR_TraceRayFilterEx(vecTarget, view_as<float>({90.0, 0.0, 0.0}), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
					TR_GetEndPosition(vecTarget, trace);
					delete trace;
					vecTarget[2] += 18.0;
					static float hullcheckmaxs[3];
					static float hullcheckmins[3];
							
					hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );	
					if(!IsSpaceOccupiedRTSBuilding(vecTarget, hullcheckmins, hullcheckmaxs, npc.index))
					{
						if(!IsPointHazard(vecTarget))
						{
							if(GetVectorDistance(originalVec, vecTarget, true) <= (npc.m_iTargetAlly <= MaxClients ? (100.0 * 100.0) : (350.0 * 350.0)) && GetVectorDistance(originalVec, vecTarget, true) > (30.0 * 30.0))
							{
								npc.m_flComeToMe = gameTime + 10.0;
								f3_SpawnPosition[npc.index] = vecTarget;
							}
						}
					}
				}
			}
			
			if(f3_SpawnPosition[npc.index][0])
			{
				if(command == Command_HoldPosBarracks && !pathed)
				{
					if(GetVectorDistance(f3_SpawnPosition[npc.index], myPos, true) > (50.0 * 50.0))
					{
						NPC_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
						npc.StartPathing();
						pathed = true;
					}
				}
				else if(GetVectorDistance(f3_SpawnPosition[npc.index], myPos, true) > (25.0 * 25.0))
				{
					NPC_SetGoalVector(npc.index, f3_SpawnPosition[npc.index]);
					npc.StartPathing();
					pathed = true;
				}

				if(!pathed && command == Command_RTSMove)
				{
					command = Command_RTSAttack;
				}
			}
		}
	}
	
	if(pathed)
	{
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.m_bisWalking = true;
			npc.m_flSpeed = speed;
			
			if(moveAnim[0])
				npc.SetActivity(moveAnim);
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 4)
		{
			npc.m_iChanged_WalkCycle = 4;
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;

			if(idleAnim[0])
				npc.SetActivity(idleAnim);
			
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			b_WalkToPosition[npc.index] = false;
		}
	}

	if(sound)
	{
		if(npc.m_iTarget > 0)
		{
			npc.PlayIdleAlertSound();
		}
		else
		{
			npc.PlayIdleSound();
		}
	}
}
*/
