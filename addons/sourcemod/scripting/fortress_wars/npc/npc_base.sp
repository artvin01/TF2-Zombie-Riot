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

void UnitBody_ThinkTarget(UnitBody npc, float gameTime)
{
	CommandEnum command;

	if(CommandList[npc.index] && CommandList[npc.index].Length)
	{
		CommandList[npc.index].GetArray(0, command);
	}
	else
	{
		command.Type = Command_Move;
		GetAbsOrigin(npc.index, command.Pos);
	}

	if(command.Target > 0)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
			npc.m_iTarget = command.Target;
	}
}

/*
int UnitBody_ThinkTarget(int iNPC, bool camo, float gameTime, bool passive = false)
{
	UnitBody npc = view_as<UnitBody>(iNPC);

	int client = GetClientOfUserId(npc.OwnerUserId);
	bool newTarget = npc.m_flGetClosestTargetTime < gameTime;
	
	int command = Command_Aggressive;

	if(client)
		command = npc.CmdOverride == Command_Default ? Building_GetFollowerCommand(client) : npc.CmdOverride;
	
	bool retreating = (command == Command_Retreat || command == Command_RetreatPlayer || command == Command_RTSMove);

	if(!newTarget && !retreating)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTarget);

	if(!newTarget && !retreating)
		newTarget = !IsValidEnemy(npc.index, npc.m_iTargetRally);

	if(newTarget)
	{
		if(client)
		{
			switch(command)
			{
				case Command_HoldPos, Command_HoldPosBarracks, Command_RTSMove, Command_RTSAttack:
					npc.m_iTargetAlly = npc.index;
			
				case Command_DefensivePlayer, Command_RetreatPlayer:
					npc.m_iTargetAlly = client;
				
				default:
					npc.m_iTargetAlly = Building_GetFollowerEntity(client);
			}
		}
		else
		{
			npc.m_iTargetAlly = 0;
		}
		
		if(!passive && !retreating)
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo);	
		}
		
		if(npc.m_iTargetAlly > 0 && !passive)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenterOld(npc.m_iTargetAlly);
			npc.m_iTargetRally = GetClosestTarget(npc.index, _, command == Command_Aggressive ? FAR_FUTURE : 900.0, camo, _, _, vecTarget, command != Command_Aggressive);
		}
		else
		{
			npc.m_iTargetRally = 0;

			int entity = MaxClients + 1;
			while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
			{
				if(BarrackOwner[entity] == BarrackOwner[npc.index] && GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2)
				{
					UnitBody ally = view_as<UnitBody>(entity);
					if(ally.m_iTargetRally > 0 && IsValidEnemy(npc.index, ally.m_iTargetRally))
					{
						npc.m_iTargetRally = ally.m_iTargetRally;
					}
				}
			}

			if(!passive)
			{
				if(npc.m_iTargetRally < 1)
					npc.m_iTargetRally = npc.m_iTarget;
			}
		}

		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	return client;
}

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
