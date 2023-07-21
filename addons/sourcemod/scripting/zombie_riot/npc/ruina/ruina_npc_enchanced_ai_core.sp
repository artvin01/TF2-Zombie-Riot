#pragma semicolon 1
#pragma newdecls required

static int i_master_target_id[MAXENTITIES];
static int i_master_id[MAXENTITIES];
static int i_npc_type[MAXENTITIES];

static float fl_master_change_timer[MAXENTITIES];
static bool b_master_exists[MAXENTITIES];
static int i_master_attracts[MAXENTITIES];

#define RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER 30.0	//how often do the npc's try to get a new master, ignored by master refind

public void Ruina_Ai_Core_Mapstart()
{
	Zero(fl_master_change_timer);
	Zero(i_master_target_id);
	Zero(b_master_exists);
	Zero(i_master_id);
	Zero(i_npc_type);
}
public void Ruina_Set_Heirarchy(int client, int type, bool master)
{
	if(master)
	{
		b_master_exists[client] = true;
		i_master_attracts[client] = type;
	}
	else
	{
		i_npc_type[client] = type;
	}
}
public void Ruina_NPCDeath_Override(int entity)
{
	b_master_exists[entity] = false;
	
	switch(i_NpcInternalId[entity])
	{
		case RUINA_THEOCRACY:
			Theocracy_NPCDeath(entity);
			
		default:
			PrintToChatAll("This RUINA Npc Did NOT Get a Valid Internal ID! ID that was given but was invalid:[%i]", i_NpcInternalId[entity]);
	}
		
		
}
static int GetRandomMaster()
{
	int valid = -1;
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(b_master_exists[baseboss_index])
				valid=baseboss_index;
		}
	}
	return valid;
}


public void Ruina_Ai_Override_Core(int iNPC, int &PrimaryThreatIndex)
{
		CClotBody npc = view_as<CClotBody>(iNPC);
		
		float GameTime = GetGameTime(npc.index);
		
		if(!b_master_exists[npc.index])
		{	
			int Backup_Target = PrimaryThreatIndex;
			if(fl_master_change_timer[npc.index]<=GameTime || !IsValidEntity(i_master_id[npc.index]))
			{
				i_master_id[npc.index] = GetRandomMaster();
				fl_master_change_timer[npc.index] = GameTime + RUINA_AI_CORE_REFRESH_MASTER_ID_TIMER;
				
			}
			if(IsValidEntity(i_master_id[npc.index]))
			{
				PrimaryThreatIndex = GetClosestTarget(i_master_id[npc.index]);
			}
			
			if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
			{
				PrimaryThreatIndex = Backup_Target;
				return;
			}
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
					
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(IsValidEntity(i_master_id[npc.index]))
			{
				switch(i_npc_type[npc.index])
				{
					case 1:	//melee, buisness as usual, just the target is the same as the masters
					{
						
						
						
						//Predict their pos.
						if(flDistanceToTarget < npc.GetLeadRadius()) 
						{
							
							float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
							
							NPC_SetGoalVector(npc.index, vPredictedPos);
						}
						else 
						{
							NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
						}
						npc.StartPathing();
						
						return;
					}
					case 2:	//ranged, target is the same, npc moves towards the master npc
					{
						float Master_Loc[3]; Master_Loc = WorldSpaceCenter(i_master_id[npc.index]);
						float Npc_Loc[3];	Npc_Loc = WorldSpaceCenter(npc.index);
						
						float dist = GetVectorDistance(Npc_Loc, Master_Loc, true);
						
						if(dist > Pow(100.0, 2.0))
						{
							NPC_SetGoalEntity(npc.index, i_master_id[npc.index]);
							npc.StartPathing();
							npc.m_bPathing = true;
							
						}
						else
						{
							NPC_StopPathing(npc.index);
							npc.m_bPathing = false;
						}
							
	
						
					}
					case 3:	//for the double type just gonna use melee npc logic
					{
						if(flDistanceToTarget < npc.GetLeadRadius()) 
						{
									
							float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
									
							NPC_SetGoalVector(npc.index, vPredictedPos);
						}
						else 
						{
							NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
						}
						npc.StartPathing();
								
						return;
					}
				}
			}
			else
			{
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
							
					float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
							
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
				}
				npc.StartPathing();
						
				return;
			}
		}
		else	//if its a master buisness as usual
		{
			
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
					
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
						
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
						
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			npc.StartPathing();
					
			return;
		}
}

public void Apply_Master_Buff(int iNPC, int buff_type, float range, float time)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	for(int targ; targ<i_MaxcountNpc; targ++)
	{
		int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
		if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index])
		{
			if(baseboss_index!=npc.index)
			{
				if(i_npc_type[baseboss_index]==i_master_attracts[npc.index] || i_npc_type[baseboss_index]==3)	//same type of npc, or a global type
				{
					if(GetEntProp(baseboss_index, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(baseboss_index))
					{
						static float pos2[3];
						GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", pos2);
						if(GetVectorDistance(pos1, pos2, true) < Pow(range, 2.0))
						{
							if(i_NpcInternalId[baseboss_index] != i_NpcInternalId[npc.index]) //cannot buff itself
							{
								switch(buff_type)
								{
									case 1:
									{
										Apply_Defense_buff(time, baseboss_index);
									}
									case 2:
									{
										Apply_Speed_buff(time, baseboss_index);
									}
									case 3:
									{
										Apply_Attack_buff(time, baseboss_index);
									}
								}
								//buffed_anyone = true;
							}
						}
					}
				}
			}
		}
	}
}
/*
	f_Ruina_Speed_Buff[entity] = 0.0;
	f_Ruina_Defense_Buff[entity] = 0.0;
	f_Ruina_Attack_Buff[entity] = 0.0;
*/
static void Apply_Defense_buff(float time, int Other_Npc)
{
	f_Ruina_Defense_Buff[Other_Npc] = GetGameTime() + time;
}
static void Apply_Speed_buff(float time, int Other_Npc)
{
	f_Ruina_Speed_Buff[Other_Npc] = GetGameTime() + time;
}
static void Apply_Attack_buff(float time, int Other_Npc)
{
	f_Ruina_Attack_Buff[Other_Npc] = GetGameTime() + time;
}