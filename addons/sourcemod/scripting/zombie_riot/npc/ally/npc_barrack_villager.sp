#pragma semicolon 1
#pragma newdecls required

static int VillagerSpecialCommand[MAXENTITIES];
static int VillagerTowerLink[MAXENTITIES];
static float VillagerRemindbuild[MAXENTITIES];
static float VillagerBuildCooldown[MAXENTITIES];
static float VillagerDesiredBuildLocation[MAXENTITIES][3];
static float VillagerRepairFocusLoc[MAXENTITIES][3];

enum
{
	Villager_Command_Default = -1,
	Villager_Command_RepairFocus = 0,
	Villager_Command_GatherResource = 1,
	Villager_Command_StandNearTower = 2,
}

static int NPCId;

void BarrackVillagerOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Assistant Villager");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_villager");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int BarrackVillager_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackVillager(client, vecPos, vecAng);
}

methodmap BarrackVillager < BarrackBody
{
	property float f_VillagerBuildCooldown
	{
		public get()
		{
			return VillagerBuildCooldown[view_as<int>(this)];
		}
		public set(float value)
		{
			VillagerBuildCooldown[view_as<int>(this)] = value;
		}
	}
	property float f_VillagerRemind
	{
		public get()
		{
			return VillagerRemindbuild[view_as<int>(this)];
		}
		public set(float value)
		{
			VillagerRemindbuild[view_as<int>(this)] = value;
		}
	}
	property int i_VillagerSpecialCommand
	{
		public get()
		{
			return VillagerSpecialCommand[view_as<int>(this)];
		}
		public set(int value)
		{
			VillagerSpecialCommand[view_as<int>(this)] = value;
		}
	}
	property int m_iTowerLinked
	{
		public get()		 
		{ 
			return EntRefToEntIndex(VillagerTowerLink[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				VillagerTowerLink[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				VillagerTowerLink[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	public BarrackVillager(int client, float vecPos[3], float vecAng[3])
	{
		BarrackVillager npc = view_as<BarrackVillager>(BarrackBody(client, vecPos, vecAng, "1000",_,_,_,_,"models/pickups/pickup_powerup_king.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackVillager_NPCDeath;
		func_NPCThink[npc.index] = BarrackVillager_ClotThink;
		
		npc.m_flSpeed = 150.0;
		npc.i_VillagerSpecialCommand = Villager_Command_Default;
		npc.m_iTowerLinked = -1;
		npc.b_NpcSpecialCommand = true;
		npc.f_VillagerRemind = 0.0;
		npc.f_VillagerBuildCooldown = 0.0;
		VillagerDesiredBuildLocation[npc.index][0] = 0.0;
		VillagerDesiredBuildLocation[npc.index][1] = 0.0;
		VillagerDesiredBuildLocation[npc.index][2] = 0.0;
		VillagerRepairFocusLoc[npc.index][0] = 0.0;
		VillagerRepairFocusLoc[npc.index][1] = 0.0;
		VillagerRepairFocusLoc[npc.index][2] = 0.0;
		b_DoNotChangeTargetTouchNpc[npc.index] = 1;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_sledgehammer/c_sledgehammer.mdl");
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

public void BarrackVillager_ClotThink(int iNPC)
{
	BarrackVillager npc = view_as<BarrackVillager>(iNPC);
	float GameTime = GetGameTime(iNPC);
	npc.m_flSpeed = 150.0;
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		BarrackVillager player = view_as<BarrackVillager>(client);
		if(npc.i_VillagerSpecialCommand != Villager_Command_GatherResource)
		{
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
			
			if(!IsValidEntity(npc.m_iWearable1))
			{
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_sledgehammer/c_sledgehammer.mdl");
				SetVariantString("0.5");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");		
			}		
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			if(!IsValidEntity(npc.m_iWearable2))
			{
				npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_pickaxe/c_pickaxe.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable2, "SetModelScale");		
			}
		}

		//	npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
		bool ListenToCustomCommands = true;
		bool IngoreBarracksCommands = false;
		int BuildingAlive = player.m_iTowerLinked;
		if(!IsValidEntity(BuildingAlive))
		{
			if(VillagerDesiredBuildLocation[npc.index][0] != 0.0 && npc.f_VillagerBuildCooldown < GameTime)
			{
				ListenToCustomCommands = false;
				IngoreBarracksCommands = true;
				//We move to this position
				if(npc.m_iChanged_WalkCycle != 5) //walk to building
				{
					npc.m_iChanged_WalkCycle = 5;
					npc.StartPathing();
					npc.m_bisWalking = true;
					npc.SetActivity("ACT_VILLAGER_RUN");
				}	
				npc.SetGoalVector(VillagerDesiredBuildLocation[npc.index]);
				float MePos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);

				
				float flDistanceToTarget = GetVectorDistance(VillagerDesiredBuildLocation[npc.index], MePos, true);

				if(flDistanceToTarget < (50.0*50.0))
				{
					//We are close enough to build, lets build.
					int spawn_index = NPC_CreateByName("npc_barrack_building", client, VillagerDesiredBuildLocation[npc.index], {0.0,0.0,0.0}, GetTeam(npc.index));
					if(spawn_index > MaxClients)
					{
						VillagerDesiredBuildLocation[npc.index][0] = 0.0;
						VillagerDesiredBuildLocation[npc.index][1] = 0.0;
						VillagerDesiredBuildLocation[npc.index][2] = 0.0;
						
						npc.f_VillagerBuildCooldown = GameTime + 120.0;
						if(Rogue_Mode())
							npc.f_VillagerBuildCooldown = GameTime + 60.0;

						npc.m_iTowerLinked = spawn_index;
						player.m_iTowerLinked = spawn_index;
						if(GetTeam(iNPC) != TFTeam_Red)
						{
							NpcAddedToZombiesLeftCurrently(iNPC, true);
						}
						i_AttacksTillMegahit[spawn_index] = 10;
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", 1); //only 1 health, the villager needs to first needs to build it up over time.
						SetEntityRenderMode(spawn_index, RENDER_TRANSCOLOR);
						SetEntityRenderColor(spawn_index, 255, 255, 255, 0);
					}
				}
			}
			else if(IsValidClient(client))
			{

				if(npc.f_VillagerRemind < GameTime && npc.f_VillagerBuildCooldown < GameTime)
				{
					npc.f_VillagerRemind = GameTime + 10.0;
					switch(GetRandomInt(1,4))
					{
						case 1:
						{
							CPrintToChat(client, "{green}주민 하수인{default}: 망루를 지을 위치를 알려주십시오!");
						}
						case 2:
						{
							CPrintToChat(client, "{green}주민 하수인{default}: 대장, 어디에다 지을지를 가르쳐주십시오!");
						}
						case 3:
						{
							CPrintToChat(client, "{green}주민 하수인{default}: 망루를 건설하고 싶습니다! 어디에 지을깝쇼?");
						}
						case 4:
						{
							CPrintToChat(client, "{green}주민 하수인{default}: 어디에 망루를 지을까요?");
						}
					}
				}		
			}
		}
		else
		{
			//our building now exists, lets build it if we are close enough, we ignore any other command.
			if(i_AttacksTillMegahit[BuildingAlive] < 255)
			{
				IngoreBarracksCommands = true;
				ListenToCustomCommands = false;
				float BuildingPos[3];
				GetEntPropVector(BuildingAlive, Prop_Data, "m_vecAbsOrigin", BuildingPos);
				float MePos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);
				float flDistanceToTarget = GetVectorDistance(BuildingPos, MePos, true);
				if(flDistanceToTarget < (50.0*50.0)) //we are close enough, lets build.
				{
					if(Rogue_Mode())
					{
						i_AttacksTillMegahit[BuildingAlive] += 1;
						if(GetEntProp(BuildingAlive, Prop_Data, "m_iHealth") < GetEntProp(BuildingAlive, Prop_Data, "m_iMaxHealth"))
						{
							SetEntProp(BuildingAlive, Prop_Data, "m_iHealth", GetEntProp(BuildingAlive, Prop_Data, "m_iHealth") + (GetEntProp(BuildingAlive, Prop_Data, "m_iMaxHealth") / 222));
							if(GetEntProp(BuildingAlive, Prop_Data, "m_iHealth") >= GetEntProp(BuildingAlive, Prop_Data, "m_iMaxHealth"))
							{
								SetEntProp(BuildingAlive, Prop_Data, "m_iHealth", GetEntProp(BuildingAlive, Prop_Data, "m_iMaxHealth"));
							}
						}
					}
					else
					{
						i_AttacksTillMegahit[BuildingAlive] += 255;
						SetEntProp(BuildingAlive, Prop_Data, "m_iHealth", GetEntProp(BuildingAlive, Prop_Data, "m_iMaxHealth"));
					}
					npc.FaceTowards(BuildingPos, 10000.0); //build.
					if(npc.m_iChanged_WalkCycle != 6)
					{
						npc.m_iChanged_WalkCycle = 6;
						npc.StopPathing();
						npc.m_bisWalking = false;
						npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
					}	
				}
				else //Lets move to the building.
				{
					if(npc.m_iChanged_WalkCycle != 5) //walk to building
					{
						npc.m_iChanged_WalkCycle = 5;
						npc.StartPathing();
						npc.m_bisWalking = true;
						npc.SetActivity("ACT_VILLAGER_RUN");
					}	
					npc.SetGoalVector(BuildingPos);
				}
			}
			else if(i_AttacksTillMegahit[BuildingAlive] != 300) //300 indicates its finished building.
			{
				IngoreBarracksCommands = true;
				ListenToCustomCommands = false;
				i_AttacksTillMegahit[BuildingAlive] = 255;
				//we are done.
			}
			else
			{
				ListenToCustomCommands = true;
			}
		}
		if(ListenToCustomCommands)
		{
			//we will now obey any command incase we werent given an order to build a tower.
			switch(npc.i_VillagerSpecialCommand)
			{
				//we stay near whatever we have been made to be near, we repair, we build, we run.
				case Villager_Command_GatherResource:
				{
					IngoreBarracksCommands = true;
					float MePos[3];
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);
					float flDistanceToTarget = GetVectorDistance(VillagerRepairFocusLoc[npc.index], MePos, true);
					if(flDistanceToTarget < (25.0*25.0))
					{
						SummonerRenerateResources(client, 0.4, 1.05);
						if(npc.m_iChanged_WalkCycle != 7)
						{
							npc.m_iChanged_WalkCycle = 7;
							npc.StopPathing();
							npc.m_bisWalking = false;
							npc.SetActivity("ACT_VILLAGER_MINING"); //mining animation?
						}	
					}
					else
					{
						if(npc.m_iChanged_WalkCycle != 5) //walk to building
						{
							npc.m_iChanged_WalkCycle = 5;
							npc.StartPathing();
							npc.m_bisWalking = true;
							npc.SetActivity("ACT_VILLAGER_RUN");
						}	
						npc.SetGoalVector(VillagerRepairFocusLoc[npc.index]);
					}
				}
				case Villager_Command_StandNearTower:
				{
					if(BarracksVillager_RepairSelfTower(npc.index, BuildingAlive))
					{
						IngoreBarracksCommands = true;
						//uhhh....
					}
					else
					{
						if(BuildingAlive > 0)
						{
							IngoreBarracksCommands = true;
							float BuildingPos[3];
							GetEntPropVector(BuildingAlive, Prop_Data, "m_vecOrigin", BuildingPos);
							int Closest_Building = GetClosestBuildingVillager(npc.index, BuildingPos, (750.0 * 750.0));

							if(Closest_Building > 0)
							{
								BarracksVillager_RepairBuilding(npc.index, Closest_Building);
							}
							else
							{
								float MePos[3];
								GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);
								float flDistanceToTarget = GetVectorDistance(BuildingPos, MePos, true);

								if(flDistanceToTarget < (25.0*25.0))
								{
									if(npc.m_iChanged_WalkCycle != 4)
									{
										npc.m_iChanged_WalkCycle = 4;
										npc.StopPathing();
										npc.m_bisWalking = false;
										npc.SetActivity("ACT_VILLAGER_IDLE");
									}	
								}
								else
								{
									if(npc.m_iChanged_WalkCycle != 5) //walk to building
									{
										npc.m_iChanged_WalkCycle = 5;
										npc.StartPathing();
										npc.m_bisWalking = true;
										npc.SetActivity("ACT_VILLAGER_RUN");
									}	
									npc.SetGoalVector(BuildingPos);
								}
							}
						}
					}					
				}
				case Villager_Command_Default:
				{
					if(BarracksVillager_RepairSelfTower(npc.index, BuildingAlive))
					{
						IngoreBarracksCommands = true;
					}
					else
					{
						BarrackBody_ThinkTarget(npc.index, true, GameTime, true); //we are passive, we do not attack, we just repair.
						float MePos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);

						int Closest_Building = GetClosestBuildingVillager(npc.index, MePos, (750.0 * 750.0));

						if(Closest_Building > 0)
						{
							BarracksVillager_RepairBuilding(npc.index, Closest_Building);
							IngoreBarracksCommands = true;
						}
					}
				}
				case Villager_Command_RepairFocus:
				{
					if(BarracksVillager_RepairSelfTower(npc.index, BuildingAlive))
					{
						IngoreBarracksCommands = true;
					}
					else
					{
						// we ingore any command now from default barracks, we got assigned a position and we will now repair everything in this area.
						int Closest_Building = GetClosestBuildingVillager(npc.index, VillagerRepairFocusLoc[npc.index], (750.0 * 750.0));

						if(Closest_Building < 1)
						{
							float MePos[3];
							GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", MePos);
							float flDistanceToTarget = GetVectorDistance(VillagerRepairFocusLoc[npc.index], MePos, true);
							//we have no building to repair! ahh!
							//be lazy :)
							if(flDistanceToTarget < (25.0*25.0))
							{
								if(npc.m_iChanged_WalkCycle != 4)
								{
									npc.m_iChanged_WalkCycle = 4;
									npc.StopPathing();
									npc.m_bisWalking = false;
									npc.SetActivity("ACT_VILLAGER_IDLE");
								}	
							}
							else
							{
								if(npc.m_iChanged_WalkCycle != 5) //walk back home.
								{
									npc.m_iChanged_WalkCycle = 5;
									npc.StartPathing();
									npc.m_bisWalking = true;
									npc.SetActivity("ACT_VILLAGER_RUN");
								}	
								npc.SetGoalVector(VillagerRepairFocusLoc[npc.index]);
							}
						}
						else
						{
							IngoreBarracksCommands = true;
							BarracksVillager_RepairBuilding(npc.index, Closest_Building);
							//building found thats hurt, repair.
						}
					}
				}
			}
		}
		if(!IngoreBarracksCommands)
			BarrackBody_ThinkMove(npc.index, 150.0, "ACT_VILLAGER_IDLE", "ACT_VILLAGER_RUN");
	}
}

void BarrackVillager_NPCDeath(int entity)
{
	BarrackVillager npc = view_as<BarrackVillager>(entity);
	BarrackBody_NPCDeath(npc.index);
}

bool BarracksVillager_RepairSelfTower(int entity, int tower)
{
	if(tower < 0) //woops, tower is fucking dead.
	{
		return false;
	}
	if(GetEntProp(tower, Prop_Data, "m_iHealth") >= GetEntProp(tower, Prop_Data, "m_iMaxHealth"))
	{
		return false;
	}
	BarrackVillager npc = view_as<BarrackVillager>(entity);
	float MePos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", MePos);
	float BuildingPos[3];
	GetEntPropVector(tower, Prop_Data, "m_vecOrigin", BuildingPos);
	float flDistanceToTarget = GetVectorDistance(BuildingPos, MePos, true);
	if(flDistanceToTarget > (500.0*500.0)) //i am too far away from my tower, i wont bother.
	{
		return false;
	}
	bool BuldingCanBeRepaired = false;
	if(flDistanceToTarget < (50.0*50.0))
	{
		BuldingCanBeRepaired = true;
		npc.FaceTowards(BuildingPos, 10000.0); //build.
		if(npc.m_iChanged_WalkCycle != 6)
		{
			npc.m_iChanged_WalkCycle = 6;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 5) //walk to building
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_VILLAGER_RUN");
		}	
		npc.SetGoalVector(BuildingPos);
	}
	if(BuldingCanBeRepaired)
	{
		if(GetEntProp(tower, Prop_Data, "m_iHealth") < GetEntProp(tower, Prop_Data, "m_iMaxHealth"))
		{
			SetEntProp(tower, Prop_Data, "m_iHealth", GetEntProp(tower, Prop_Data, "m_iHealth") + (GetEntProp(tower, Prop_Data, "m_iMaxHealth") / 500));
			if(GetEntProp(tower, Prop_Data, "m_iHealth") >= GetEntProp(tower, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(tower, Prop_Data, "m_iHealth", GetEntProp(tower, Prop_Data, "m_iMaxHealth"));
			}
		}
	}
	return true;
}

void BarracksVillager_RepairBuilding(int entity, int building)
{
	float MePos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", MePos);
	float BuildingPos[3];
	GetEntPropVector(building, Prop_Data, "m_vecOrigin", BuildingPos);
	float flDistanceToTarget = GetVectorDistance(BuildingPos, MePos, true);
	BarrackVillager npc = view_as<BarrackVillager>(entity);
	//we have no building to repair! ahh!
	//be lazy :)
	bool BuldingCanBeRepaired = false;
	if(flDistanceToTarget < (100.0*100.0))
	{
		BuldingCanBeRepaired = true;
		npc.FaceTowards(BuildingPos, 10000.0); //build.
		if(npc.m_iChanged_WalkCycle != 6)
		{
			npc.m_iChanged_WalkCycle = 6;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
		}	
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 5) //walk to building
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.StartPathing();
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_VILLAGER_RUN");
		}	
		npc.SetGoalVector(BuildingPos);
	}
	if(BuldingCanBeRepaired)
	{
		if(GetEntProp(building, Prop_Data, "m_iHealth") < GetEntProp(building, Prop_Data, "m_iMaxHealth"))
		{
			if(i_IsABuilding[building])
			{
				int HealthToRepair = GetEntProp(building, Prop_Data, "m_iMaxHealth") / 750;
				if(HealthToRepair < 1)
				{
					HealthToRepair = 1;
				}
				HealEntityGlobal(entity, building, float(HealthToRepair), _, _, _, _);
			}
		}
	}
}

void BarracksVillager_MenuSpecial(int client, int entity)
{
	SetGlobalTransTarget(client);
	BarrackVillager npc = view_as<BarrackVillager>(entity);

	Menu menu = new Menu(BarrackVillager_MenuH);
	menu.SetTitle("%t\n \n%s\n ", "TF2: Zombie Riot", NpcStats_ReturnNpcName(entity));
	BarrackVillager player = view_as<BarrackVillager>(client);
	char num[16];
	IntToString(EntIndexToEntRef(entity), num, sizeof(num));
	menu.AddItem(num, "Default Engagement", npc.i_VillagerSpecialCommand == Villager_Command_Default ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Place Tower There", IsValidEntity(player.m_iTowerLinked) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Repair This", npc.i_VillagerSpecialCommand == Villager_Command_RepairFocus ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Gather Resources", ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Stand Near Tower", npc.i_VillagerSpecialCommand == Villager_Command_StandNearTower ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	menu.AddItem(num, "Destroy Tower", IsValidEntity(player.m_iTowerLinked) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

	menu.Pagination = 0;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);	
}


public int BarrackVillager_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char num[16];
			menu.GetItem(choice, num, sizeof(num));

			int entity = EntRefToEntIndex(StringToInt(num));
			if(entity != INVALID_ENT_REFERENCE)
			{
				BarrackVillager npc = view_as<BarrackVillager>(entity);
				float GameTime = GetGameTime(entity);
				npc.m_flComeToMe = GameTime;

				switch(choice)
				{
					case 0:
					{
						npc.i_VillagerSpecialCommand = Command_Default;
					}
					case 1:
					{
						if(npc.f_VillagerBuildCooldown < GameTime)
						{
							float StartOrigin[3], Angles[3], vecPos[3];
							GetClientEyeAngles(client, Angles);
							GetClientEyePosition(client, StartOrigin);
							Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (MASK_NPCSOLID_BRUSHONLY), RayType_Infinite, HitOnlyWorld);
							if (TR_DidHit(TraceRay))
								TR_GetEndPosition(vecPos, TraceRay);
								
							delete TraceRay;
							npc.FaceTowards(vecPos, 10000.0);
							CreateParticle("ping_circle", vecPos, NULL_VECTOR);

							CNavArea area = TheNavMesh.GetNavArea(vecPos, 25.0);
							if(area == NULL_AREA)
							{
								CPrintToChat(client, "{green}주민 하수인{default}: 이 곳엔 지을수 없습니다. 바닥에 가까이 놓거나 벽에서 멀리 떨어뜨려주세요!");		
							}
							else
							{
								vecPos[2] += 18.0;
								if(IsPointHazard(vecPos)) //Retry.
								{
									CPrintToChat(client, "{green}주민 하수인{default}: 이 곳엔 지을수 없습니다. 바닥에 가까이 놓거나 벽에서 멀리 떨어뜨려주세요!");		
									BarracksVillager_MenuSpecial(client, npc.index);
									return 0;
								}

								
								vecPos[2] -= 18.0;
								if(IsPointHazard(vecPos)) //Retry.
								{
									CPrintToChat(client, "{green}주민 하수인{default}: 이 곳엔 지을수 없습니다. 바닥에 가까이 놓거나 벽에서 멀리 떨어뜨려주세요!");		
									BarracksVillager_MenuSpecial(client, npc.index);
									return 0;
								}
								VillagerDesiredBuildLocation[npc.index] = vecPos;
								
								CPrintToChat(client, "{green}주민 하수인{default}: 즉시 하겠습니다!");			
							}
						}	
						else
						{
							switch(GetRandomInt(1,2))
							{
								case 1:
								{
									CPrintToChat(client, "{green}Villager Minion{default}: I'm sorry i dont have the resources right now. [%.1f]",npc.f_VillagerBuildCooldown - GameTime);
								}
								case 2:
								{
									CPrintToChat(client, "{green}Villager Minion{default}: I currently can't build my tower, i need more resources, please wait! [%.1f]",npc.f_VillagerBuildCooldown - GameTime);
								}
							}
						}					
						npc.i_VillagerSpecialCommand = Command_Default;
					}
					case 2:
					{
						float StartOrigin[3], Angles[3], vecPos[3];
						GetClientEyeAngles(client, Angles);
						GetClientEyePosition(client, StartOrigin);
						Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (MASK_NPCSOLID_BRUSHONLY), RayType_Infinite, HitOnlyWorld);
						if (TR_DidHit(TraceRay))
							TR_GetEndPosition(vecPos, TraceRay);
								
						delete TraceRay;
						npc.FaceTowards(vecPos, 10000.0);
						CreateParticle("ping_circle", vecPos, NULL_VECTOR);
						VillagerRepairFocusLoc[npc.index] = vecPos;

						npc.i_VillagerSpecialCommand = Villager_Command_RepairFocus;
					}
					case 3:
					{
						float StartOrigin[3], Angles[3], vecPos[3];
						GetClientEyeAngles(client, Angles);
						GetClientEyePosition(client, StartOrigin);
						Handle TraceRay = TR_TraceRayFilterEx(StartOrigin, Angles, (MASK_NPCSOLID_BRUSHONLY), RayType_Infinite, HitOnlyWorld);
						if (TR_DidHit(TraceRay))
							TR_GetEndPosition(vecPos, TraceRay);
								
						delete TraceRay;
						npc.FaceTowards(vecPos, 10000.0);
						CreateParticle("ping_circle", vecPos, NULL_VECTOR);
						VillagerRepairFocusLoc[npc.index] = vecPos;

						npc.i_VillagerSpecialCommand = Villager_Command_GatherResource;
					}
					case 4:
					{
						npc.i_VillagerSpecialCommand = Villager_Command_StandNearTower;
					}
					case 5:
					{
						BarrackVillager player = view_as<BarrackVillager>(client);
						if(IsValidEntity(player.m_iTowerLinked))
						{
							RequestFrame(KillNpc, EntIndexToEntRef(player.m_iTowerLinked));
						}
					}
				}
				BarracksVillager_MenuSpecial(client, npc.index);
			}
		}
	}
	return 0;
}


stock int GetClosestBuildingVillager(int entity, float EntityLocation[3], float limitsquared = 99999999.9)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
	{
		int building = EntRefToEntIndexFast(i_ObjectsBuilding[entitycount]);
		if(IsValidEntity(building) && GetEntProp(building, Prop_Data, "m_iHealth") < GetEntProp(building, Prop_Data, "m_iMaxHealth"))
		{
			if(Can_I_See_Enemy_Only(entity, building))
			{
				float TargetLocation[3]; 
				GetEntPropVector( building, Prop_Data, "m_vecOrigin", TargetLocation ); //buildings do not have abs origin? 
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( distance < limitsquared )
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = building; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = building; 
						TargetDistance = distance;
					}			
				}
			}
		}
	}
	return ClosestTarget; 
}