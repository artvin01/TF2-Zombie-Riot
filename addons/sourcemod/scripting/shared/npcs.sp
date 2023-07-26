#pragma semicolon 1
#pragma newdecls required

enum //hitgroup_t
{
	HITGROUP_GENERIC,
	HITGROUP_HEAD,
	HITGROUP_CHEST,
	HITGROUP_STOMACH,
	HITGROUP_LEFTARM,
	HITGROUP_RIGHTARM,
	HITGROUP_LEFTLEG,
	HITGROUP_RIGHTLEG,
	
	NUM_HITGROUPS
};

#if defined ZR
enum struct SpawnerData
{
	int 	indexnumber;
	bool	b_SpawnIsCloseEnough;
	float	f_ClosestSpawnerLessCooldown;
	float	f_SpawnerCooldown;
	float	f_PointScore;
	bool	IsBaseBoss;
	char	Name[64];
}

//todo: code a way to include 2 or more groups of players splitting up, so the enemies dont spawn in the middle of nowhere
//Easy temp solution: Map should handle it. via triggers, and such, and dont make huge maps with a billion corridors.



//ArrayList NPCList; Make this global, i need it globally.
//ArrayList SpawnerList; global
static ConVar MapSpawnersActive;
static Handle SyncHudRaid;
#endif

static Handle SyncHud;
static char LastClassname[2049][64];
//static float f_SpawnerCooldown[MAXENTITIES];
/*
void NPC_Spawn_ClearAll()
{
	Zero(f_SpawnerCooldown);
}*/

void Npc_Sp_Precache()
{
	g_particleCritText = PrecacheParticleSystem("crit_text");
	g_particleMissText = PrecacheParticleSystem("miss_text");
}

void NPC_PluginStart()
{
#if defined ZR
	MapSpawnersActive = CreateConVar("zr_spawnersactive", "4", "How many spawners are active by default,", _, true, 0.0, true, 32.0);
	SpawnerList = new ArrayList(sizeof(SpawnerData));
	SyncHudRaid = CreateHudSynchronizer();
#endif

	SyncHud = CreateHudSynchronizer();
	
	LF_HookSpawn("", NPC_OnCreatePre, false);
	LF_HookSpawn("", NPC_OnCreatePost, true);
	
}

#if defined ZR
void NPC_MapEnd()
{
	delete SpawnerList;
	SpawnerList = new ArrayList(sizeof(SpawnerData));
}

void NPC_RoundStart()
{
	// Artvin TODO: Check whenever a teamspawn is deleted and remove from SpawnerList and other arrays

	delete SpawnerList;
	SpawnerList = new ArrayList(sizeof(SpawnerData));

	int entity = -1;
	while((entity = FindEntityByClassname(entity, "info_player_teamspawn")) != -1)
	{
		OnEntityCreated(entity, "info_player_teamspawn");
	}
}
#endif

public Action LF_OnMakeNPC(char[] classname, int &entity)
{
	int index = StringToInt(classname);
	if(!index)
		index = GetIndexByPluginName(classname);
	
	entity = Npc_Create(index, -1, NULL_VECTOR, NULL_VECTOR, false);
	if(entity == -1)
		return Plugin_Continue;
	
	return Plugin_Handled;
}

public Action NPC_OnCreatePre(char[] classname)
{
	if(!StrContains(classname, "npc_") && !StrEqual(classname, "npc_maker"))
	{
		strcopy(classname, 64, "zr_base_npc");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void NPC_OnCreatePost(const char[] classname, int entity)
{
	if(!StrContains(classname, "npc_") && !StrEqual(classname, "npc_maker"))
	{
		strcopy(LastClassname[entity], sizeof(LastClassname[]), classname);
		SDKHook(entity, SDKHook_SpawnPost, NPC_EntitySpawned);
	}
}

public void NPC_EntitySpawned(int entity)
{
	int index = GetIndexByPluginName(LastClassname[entity]);
	if(index)
	{
		float pos[3], ang[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		
		RemoveEntity(entity);
		
		Npc_Create(index, -1, pos, ang, false);
	}
}

#if defined ZR
public Action GetClosestSpawners(Handle timer)
{
	float f3_PositionTemp_2[3];
	float f3_PositionTemp[3];

	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			if(IsPlayerAlive(client) && GetClientTeam(client)==3)
			{
				if(IsFakeClient(client))
				{
					KickClient(client);	
				}
				else
				{
					ClientCommand(client, "retry");
				}
			}
			else if(!IsFakeClient(client))
			{
				QueryClientConVar(client, "snd_musicvolume", ConVarCallback); //cl_showpluginmessages
				QueryClientConVar(client, "snd_ducktovolume", ConVarCallbackDuckToVolume); //cl_showpluginmessages
				QueryClientConVar(client, "cl_showpluginmessages", ConVarCallback_Plugin_message); //cl_showpluginmessages
				int point_difference = PlayerPoints[client] - i_PreviousPointAmount[client];
				
				if(point_difference > 0)
				{
					if(Waves_GetRound() +1 > 60)
					{
						GiveXP(client, point_difference / 10); //Any round above 60 will give way less xp due to just being xp grind fests. This includes the bloons rounds as the points there get ridicilous at later rounds.
					}
					else
					{
						GiveXP(client, point_difference);
					}
				}
				
				i_PreviousPointAmount[client] = PlayerPoints[client];
				
				if(GetClientTeam(client)==2 && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0 && IsPlayerAlive(client))
				{
					
					GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);

					for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++) //Faster check for spawners
					{
						int entity = i_ObjectsSpawners[entitycount];
						if(IsValidEntity(entity))
						{
							GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp_2);

							float distance = GetVectorDistance( f3_PositionTemp, f3_PositionTemp_2, true); 

							//leave it all squared for optimsation sake!
							//max distance is 10,000 anymore and wtf u doin

							if( distance < 100000000.0) 
							{
								int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
								if(index != -1)
								{
									SpawnerData Spawner;
									SpawnerList.GetArray(index, Spawner);

									//For Zr_lila_panic.
									if(StrEqual(Spawner.Name, "underground"))
									{
										if(!b_PlayerIsInAnotherPart[client])
										{
											continue;
										}
									}
									if(b_PlayerIsInAnotherPart[client])
									{
										if(!StrEqual(Spawner.Name, "underground"))
										{
											continue;
										}
									}
										
									float inverting_score_calc;

									inverting_score_calc = ( distance / 100000000.0);

									inverting_score_calc -= 1;

									inverting_score_calc *= -1.0;

									//
									//	(n*n)^4.0
									//	So further away spawnpoints gain way less points.
									//	This should solve the problem of 2 groups of people far away triggering spawnpoints that arent even near them.

									Pow(inverting_score_calc * inverting_score_calc, 5.0);

									Spawner.f_PointScore += inverting_score_calc;

									SpawnerList.SetArray(index, Spawner);										
								}
							}
						}
					}
				}
			}
		}
	}
	/*
	float PositonBeam[3];
	PositonBeam = f3_PositionOfAll;
	PositonBeam[2] += 50;
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	TE_SetupBeamPoints(f3_PositionOfAll, PositonBeam, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 2.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	TE_SendToAll();
	*/
	int i_Spawner_Indexes[32 + 1];
	float TargetDistance = 0.0; 
	int ClosestTarget = -1; 
	int maxSpawners = Rogue_Mode() ? 1 : MapSpawnersActive.IntValue;

	for(int Repeats=1; Repeats<=maxSpawners; Repeats++)
	{
		for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++) //Faster check for spawners
		{
			int entity = i_ObjectsSpawners[entitycount];
			if(IsValidEntity(entity))
			{
				int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
				if(index != -1)
				{
					SpawnerData Spawner;
					SpawnerList.GetArray(index, Spawner);
					bool Found = false;
					if((Spawner.IsBaseBoss || !GetEntProp(entity, Prop_Data, "m_bDisabled")) && GetEntProp(entity, Prop_Data, "m_iTeamNum") != 2)
					{
						for(int Repeats_anti=1; Repeats_anti<=Repeats; Repeats_anti++)
						{
							if(i_Spawner_Indexes[Repeats_anti] == entity)
							{
								Found = true;
								break;
							}
						}
						
						if(Found)
						{
							continue;
						}
						Spawner.b_SpawnIsCloseEnough = false;
						/*
						PositonBeam = TargetLocation;
						TargetLocation[2] += 50;
						PositonBeam[2] += 100;
						TE_SetupBeamPoints(TargetLocation, PositonBeam, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 2.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 0, 255}), 30);
						TE_SendToAll();
						*/
						//i_PointScore[entity]
						if (TargetDistance) 
						{
							if( Spawner.f_PointScore > TargetDistance ) 
							{
								ClosestTarget = entity; 
								TargetDistance = Spawner.f_PointScore;		  
							}
						} 
						else 
						{
							ClosestTarget = entity; 
							TargetDistance = Spawner.f_PointScore;
						}						
					}
					SpawnerList.SetArray(index, Spawner);
				}
			}
		}
		if(IsValidEntity(ClosestTarget))
		{
			int index = SpawnerList.FindValue(ClosestTarget, SpawnerData::indexnumber);
			if(index != -1)
			{
				SpawnerData Spawner;
				SpawnerList.GetArray(index, Spawner);
				if(Repeats < 3) // first two have less cooldown
				{
					Spawner.f_ClosestSpawnerLessCooldown = 1.5;
				}
				else
				{
					Spawner.f_ClosestSpawnerLessCooldown = float(Repeats - 1) / 2.0;
				}
				Spawner.b_SpawnIsCloseEnough = true;
				SpawnerList.SetArray(index, Spawner);
			}
			i_Spawner_Indexes[Repeats] = ClosestTarget;
			/*
			GetEntPropVector(ClosestTarget, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
			PositonBeam = TargetLocation;
			PositonBeam[2] += 50;
			TE_SetupBeamPoints(TargetLocation, PositonBeam, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 2.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 255, 255, 255}), 30);
			TE_SendToAll();
			*/
		}
		ClosestTarget = -1;
		TargetDistance = 0.0;
	}

	for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++) //Faster check for spawners
	{
		int entity = i_ObjectsSpawners[entitycount];
		if(IsValidEntity(entity))
		{
			int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
			if(index != -1)
			{
				SpawnerData Spawner;
				SpawnerList.GetArray(index, Spawner);
				Spawner.f_PointScore = 0.0; //Set it to 0 again, as we wanna keep it for future calcs !	
				SpawnerList.SetArray(index, Spawner);
			}
		}
	}
	
	return Plugin_Continue;
}

public void NPC_SpawnNext(bool force, bool panzer, bool panzer_warning)
{
	float GameTime = GetGameTime();
	if(f_DelaySpawnsForVariousReasons > GameTime)
	{
		return;
	}
	bool found;
	/*
	*/
	/*
	int limit = 10 + RoundToCeil(float(Waves_GetRound())/2.3);
	*/
	int limit = 0;
	int npc_current_count = 0;
	
	if(CvarNoSpecialZombieSpawn.BoolValue)//PLEASE ASK CRUSTY FOR MODELS
	{		
		panzer = false;
		panzer_warning = false;
	}
	
	if(GlobalCheckDelayAntiLagPlayerScale < GameTime)
	{
		AllowSpecialSpawns = false;
		GlobalCheckDelayAntiLagPlayerScale = GameTime + 3.0;//only check every 5 seconds.
		PlayersAliveScaling = 0;
		GlobalIntencity = 0;
		PlayersInGame = 0;
		
		limit = 8; //Minimum should be 8! Do not scale with waves, makes it boring early on.

		float f_limit = Pow(1.14, float(CountPlayersOnRed()));
		float f_limit_alive = Pow(1.14, float(CountPlayersOnRed(true)));

		f_limit *= float(limit);
		f_limit_alive *= float(limit);
		
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client)==2 && TeutonType[client] != TEUTON_WAITING && b_HasBeenHereSinceStartOfWave[client])
			{
				if(TeutonType[client] == TEUTON_DEAD || dieingstate[client] > 0)
				{
					GlobalIntencity += 1;
				}
				PlayersInGame += 1;

				if(Level[client] > 7)
					AllowSpecialSpawns = true;
			}
		}
		if(PlayersInGame < 2)
		{
			PlayersInGame = 3;
		}
		
		//This is here to fix the issue of it always playing the zombie instead of human music when 2 people are in.
		//even if both are alive.

		PlayersAliveScaling = RoundToNearest(f_limit);
		
		if(RoundToNearest(f_limit) >= NPC_HARD_LIMIT)
			f_limit = float(NPC_HARD_LIMIT);

		if(RoundToNearest(f_limit_alive) >= NPC_HARD_LIMIT)
			f_limit_alive = float(NPC_HARD_LIMIT);
			
		
		if(PlayersAliveScaling >= NPC_HARD_LIMIT)
			PlayersAliveScaling = NPC_HARD_LIMIT;

		LimitNpcs = RoundToNearest(f_limit);
		
	}
	
	if(!b_GameOnGoing) //no spawn if the round is over
		return;
	
	if(!AllowSpecialSpawns)
	{
		panzer = false;
		panzer_warning = false;
	}
	
	if(!panzer)
	{
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc; entitycount_again_2++) //Check for npcs
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again_2]);
			if(IsValidEntity(entity) && entity != 0)
			{
				if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
				{
					npc_current_count += 1;
					CClotBody npcstats = view_as<CClotBody>(entity);
					if(!npcstats.m_bThisNpcIsABoss && !b_thisNpcHasAnOutline[entity])
					{
						if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
							GiveNpcOutLineLastOrBoss(entity, true);
						else
							GiveNpcOutLineLastOrBoss(entity, false);
					}
					
					if(!npcstats.m_bStaticNPC)
						found = true;
				}
			}
		}
		//emercency stop. 
		if(npc_current_count >= LimitNpcs)
		{
			return;
		}
	}
	
	bool npcInIt;
	float pos[3], ang[3];
	ArrayList list = new ArrayList();
	int Active_Spawners = 0;
	int entity_Spawner = -1;
	for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++)
	{
		entity_Spawner = i_ObjectsSpawners[entitycount];
		if(IsValidEntity(entity_Spawner))
		{
			int index = SpawnerList.FindValue(entity_Spawner, SpawnerData::indexnumber);
			if(index != -1)
			{
				SpawnerData Spawner;
				SpawnerList.GetArray(index, Spawner);
				if((Spawner.IsBaseBoss || !GetEntProp(entity_Spawner, Prop_Data, "m_bDisabled")) && GetEntProp(entity_Spawner, Prop_Data, "m_iTeamNum") != 2 && Spawner.b_SpawnIsCloseEnough)
				{
					Active_Spawners += 1;
					if(Spawner.f_SpawnerCooldown < GameTime)
					{
						list.Push(entity_Spawner);
					}
				}
				SpawnerList.SetArray(index, Spawner);
			}
		}
	}
	float Active_Spawners_Calculate = 1.0;
	switch (Active_Spawners)
	{
		case 1:
		{
			Active_Spawners_Calculate = 1.95;
		}
		case 2:
		{
			Active_Spawners_Calculate = 1.85;
		}
		case 3:
		{
			Active_Spawners_Calculate = 1.8;
		}
		case 4:
		{
			Active_Spawners_Calculate = 1.7;
		}
		case 5:
		{
			Active_Spawners_Calculate = 1.6;
		}
		case 6:
		{
			Active_Spawners_Calculate = 1.5;
		}
	}
	
	entity_Spawner = list.Length;
	if(entity_Spawner)
	{
		MiniBoss boss;
		if(panzer && Waves_GetMiniBoss(boss))
		{
			entity_Spawner = list.Get(GetRandomInt(0, entity_Spawner-1));
			bool isBoss = false;
			int deathforcepowerup = boss.Powerup;
			if(panzer_warning)
			{
				int Text_Int = GetRandomInt(0, 2);
				if(boss.Sound[0])
				{
					for(int panzer_warning_client=1; panzer_warning_client<=MaxClients; panzer_warning_client++)
					{
						if(IsClientInGame(panzer_warning_client))
						{
							if(IsValidClient(panzer_warning_client))
							{
								SetGlobalTransTarget(panzer_warning_client);
								/*
									https://github.com/SteamDatabase/GameTracking-TF2/blob/master/tf/tf2_misc_dir/scripts/mod_textures.txt	
								
								*/
								switch(Text_Int)
								{
									case 0:
									{
										ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_1);
									}
									case 1:
									{
										ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_2);
									}
									case 2:
									{
										ShowGameText(panzer_warning_client, boss.Icon, 1, "%t", boss.Text_3);
									}
								}
							}

							if(boss.SoundCustom)
							{
								EmitCustomToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 2.0);
							}
							else
							{
								EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
								EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
							}
						}
					}

					Citizen_MiniBossSpawn(entity_Spawner);
				}
				isBoss = true;
			}
			else
			{
				deathforcepowerup = 0;
			}
			
			int index = SpawnerList.FindValue(entity_Spawner, SpawnerData::indexnumber);
			if(index != -1)
			{
				SpawnerData Spawner;
				SpawnerList.GetArray(index, Spawner);
				Spawner.f_SpawnerCooldown = GameTime + boss.Delay + 2.0;
				SpawnerList.SetArray(index, Spawner);
			}
			
			DataPack pack;
			CreateDataTimer(boss.Delay, Timer_Delayed_BossSpawn, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(entity_Spawner);
			pack.WriteCell(isBoss);
			pack.WriteCell(boss.Index);
			pack.WriteCell(deathforcepowerup);
			pack.WriteFloat(boss.HealthMulti);
		}
		else
		{
			Enemy enemy;
			if(Waves_GetNextEnemy(enemy))
			{
				if(enemy.Spawn[0])
				{
					int length = SpawnerList.Length;

					SpawnerData Spawner;

					int count;
					int[] matches = new int[length];
					for(int i; i < length; i++)
					{
						SpawnerList.GetArray(i, Spawner);
						if(StrEqual(Spawner.Name, enemy.Spawn, false))
							matches[count++] = Spawner.indexnumber;
					}

					if(count)
					{
						entity_Spawner = matches[GetRandomInt(0, count-1)];
					}
					else
					{
						entity_Spawner = list.Get(GetRandomInt(0, entity_Spawner-1));
						PrintToChatAll("UNKNOWN SPAWN POINT \"%s\", REPORT BUG", enemy.Spawn);
					}
				}
				else
				{
					int index = SpawnerList.FindValue(entity_Spawner, SpawnerData::indexnumber);
					if(index != -1)
					{
						SpawnerData Spawner;
						SpawnerList.GetArray(index, Spawner);
						Spawner.f_SpawnerCooldown = GameTime+(2.0 - (Active_Spawners_Calculate / Spawner.f_ClosestSpawnerLessCooldown));
						SpawnerList.SetArray(index, Spawner);
					}
					entity_Spawner = list.Get(GetRandomInt(0, entity_Spawner-1));
				}
				
				GetEntPropVector(entity_Spawner, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(entity_Spawner, Prop_Data, "m_angRotation", ang);
				
				entity_Spawner = Npc_Create(enemy.Index, -1, pos, ang, enemy.Friendly, enemy.Data);
				if(entity_Spawner != -1)
				{
					if(enemy.Is_Outlined)
					{
						b_thisNpcHasAnOutline[entity_Spawner] = true;
					}
					
					if(enemy.Is_Immune_To_Nuke)
					{
						b_ThisNpcIsImmuneToNuke[entity_Spawner] = true;
					}
					
					if(enemy.Health)
					{
						SetEntProp(entity_Spawner, Prop_Data, "m_iMaxHealth", enemy.Health);
						SetEntProp(entity_Spawner, Prop_Data, "m_iHealth", enemy.Health);
					}
					
					CClotBody npcstats = view_as<CClotBody>(entity_Spawner);
					
					npcstats.m_bStaticNPC = enemy.Is_Static;
					
					if(enemy.Is_Boss == 1)
					{
					//	npcstats.RemovePather(entity_Spawner);
					//	npcstats.CreatePather(16.0, npcstats.GetMaxJumpHeight(), 1000.0, MASK_NPCSOLID, 150.0, 0.1, 1.75); //Global.
						npcstats.m_bThisNpcIsABoss = true; //Set to true!
					}
					else
					{
						npcstats.m_bThisNpcIsABoss = false; //Set to true!
					}
					
					if(enemy.Credits && MultiGlobal)
						npcstats.m_fCreditsOnKill = enemy.Credits / MultiGlobal;

					fl_Extra_MeleeArmor[entity_Spawner] 	= enemy.ExtraMeleeRes;
					fl_Extra_RangedArmor[entity_Spawner] 	= enemy.ExtraRangedRes;
					fl_Extra_Speed[entity_Spawner] 			= enemy.ExtraSpeed;
					fl_Extra_Damage[entity_Spawner] 		= enemy.ExtraDamage;
					
					if(enemy.Is_Boss || enemy.Is_Outlined)
					{
						GiveNpcOutLineLastOrBoss(entity_Spawner, true);
					}
					else
					{
						GiveNpcOutLineLastOrBoss(entity_Spawner, false);
					}

					if(zr_spawnprotectiontime.FloatValue > 0.0)
					{
				
						b_npcspawnprotection[entity_Spawner] = true;
						
						/*
						CClotBody npc = view_as<CClotBody>(entity_Spawner);
						npc.m_iSpawnProtectionEntity = TF2_CreateGlow(npc.index);
				
						SetVariantColor(view_as<int>({0, 255, 0, 100}));
						AcceptEntityInput(npc.m_iSpawnProtectionEntity, "SetGlowColor");
						*/
						
						CreateTimer(zr_spawnprotectiontime.FloatValue, Remove_Spawn_Protection, EntIndexToEntRef(entity_Spawner), TIMER_FLAG_NO_MAPCHANGE);
					}

					if(Waves_InFreeplay())
						Freeplay_SpawnEnemy(entity_Spawner);
				}
			}
			else if(!found)
			{
				Waves_Progress();
			}
		}
	}
	else if(!npcInIt && !force)
	{
		NPC_SpawnNext(true, false, false);
	}
	delete list;
}
#endif	// ZR

public Action Remove_Spawn_Protection(Handle timer, int ref)
{
	int index = EntRefToEntIndex(ref);
	if(IsValidEntity(index) && index>MaxClients)
	{
		CClotBody npc = view_as<CClotBody>(index);
			
		if(IsValidEntity(npc.m_iSpawnProtectionEntity))
			RemoveEntity(npc.m_iSpawnProtectionEntity);
		
		b_npcspawnprotection[index] = false;
	}
	return Plugin_Stop;
}

#if defined ZR
public Action Timer_Delayed_BossSpawn(Handle timer, DataPack pack)
{
	pack.Reset();
	int spawner_entity = pack.ReadCell();
	bool isBoss = pack.ReadCell();
	int index = pack.ReadCell();
	int forcepowerup = pack.ReadCell();
	float healthmulti = pack.ReadFloat();
	if(IsValidEntity(spawner_entity) && spawner_entity != 0)
	{
		float pos[3], ang[3];
			
		GetEntPropVector(spawner_entity, Prop_Data, "m_vecOrigin", pos);
		GetEntPropVector(spawner_entity, Prop_Data, "m_angRotation", ang);
		Zombies_Currently_Still_Ongoing += 1;
		int entity = Npc_Create(index, -1, pos, ang, false);
		if(entity != -1)
		{
			CClotBody npcstats = view_as<CClotBody>(entity);
			if(isBoss)
			{
				GiveNpcOutLineLastOrBoss(entity, true);
				npcstats.m_bThisNpcIsABoss = true; //Set to true!
			}
			else
			{
				npcstats.m_bThisNpcIsABoss = false; //Set to true!
			}
			
			if(healthmulti)
			{
				SetEntProp(entity, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iHealth")) * healthmulti));
				SetEntProp(entity, Prop_Data, "m_iMaxHealth", RoundToCeil(float(GetEntProp(entity, Prop_Data, "m_iMaxHealth")) * healthmulti));
			}
			
			b_NpcForcepowerupspawn[entity] = forcepowerup;

			if(Waves_InFreeplay())
				Freeplay_SpawnEnemy(entity);
		}
	}
	return Plugin_Stop;
}
#endif


void NPC_Ignite(int entity, int attacker, float duration, int weapon)
{
	bool wasBurning = view_as<bool>(IgniteFor[entity]);

	IgniteFor[entity] += RoundToCeil(duration*2.0);
	if(IgniteFor[entity] > 20)
		IgniteFor[entity] = 20;
	
	if(!IgniteTimer[entity])
		IgniteTimer[entity] = CreateTimer(0.5, NPC_TimerIgnite, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	float value = 8.0;
	bool validWeapon = false;
	if(weapon > MaxClients && IsValidEntity(weapon))
	{
		validWeapon = true;
		value *= Attributes_FindOnWeapon(attacker, weapon, 2, true, 1.0);	  //For normal weapons
			
		value *= Attributes_FindOnWeapon(attacker, weapon, 410, true, 1.0); //For wand
					
		value *= Attributes_FindOnWeapon(attacker, weapon, 71, true, 1.0); //For wand
	}

	if(wasBurning)
	{
		if(value > BurnDamage[entity]) //Dont override if damage is lower.
		{
			BurnDamage[entity] = value;
			IgniteId[entity] = EntIndexToEntRef(attacker);

			if(validWeapon)
			{
				IgniteRef[entity] = EntIndexToEntRef(weapon);
			}
			else
			{
				IgniteRef[entity] = -1;
			}
		}
	}
	else
	{
		BurnDamage[entity] = value;
		IgniteId[entity] = EntIndexToEntRef(attacker);
		if(validWeapon)
		{
			IgniteRef[entity] = EntIndexToEntRef(weapon);
		}
		else
		{
			IgniteRef[entity] = -1;
		}
	}
}

public Action NPC_TimerIgnite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > MaxClients)
	{
		if(!b_NpcHasDied[entity])
		{
			int attacker = EntRefToEntIndex(IgniteId[entity]);
			if(attacker != INVALID_ENT_REFERENCE)
			{
				IgniteFor[entity]--;
				
				float pos[3], ang[3];
				GetClientEyeAngles(attacker, ang);
				int weapon = EntRefToEntIndex(IgniteRef[entity]);
				float value = 8.0;
				if(weapon > MaxClients && IsValidEntity(weapon))
				{
					value *= Attributes_FindOnWeapon(attacker, weapon, 2, true, 1.0);	  //For normal weapons
					
					value *= Attributes_FindOnWeapon(attacker, weapon, 410, true, 1.0); //For wand
					
					value *= Attributes_FindOnWeapon(attacker, weapon, 71, true, 1.0); //For wand
				}
				else
				{
					weapon = -1;
				}
				
				pos = WorldSpaceCenter(entity);
				
				if(value < 0.2)
				{
					
				}
				else if(value < BurnDamage[entity])
				{
					value = BurnDamage[entity];
				}
				else
				{
					BurnDamage[entity] = value;
				}
				//Burn damage should pierce any resistances because its too hard to keep track off, and its not common.
				SDKHooks_TakeDamage(entity, attacker, attacker, value, DMG_SLASH, weapon, ang, pos, false, (ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED | ZR_DAMAGE_IGNORE_DEATH_PENALTY ));
				
				//Setting burn dmg to slash cus i want it to work with melee!!!
				//Also yes this means burn and bleed are basically the same, excluding that burn doesnt stack.
				//In this case ill buff it so its 2x as good as bleed! or more in the future
				//Also now allows hp gain and other stuff for that reason. pretty cool.
				if(IgniteFor[entity] == 0)
				{
					IgniteTimer[entity] = null;
					IgniteFor[entity] = 0;
					BurnDamage[entity] = 0.0;
					return Plugin_Stop;
				}
				if(f_NpcImmuneToBleed[entity] > GetGameTime())
				{
					IgniteTimer[entity] = null;
					IgniteFor[entity] = 0;
					BurnDamage[entity] = 0.0;
					return Plugin_Stop;
				}
				return Plugin_Continue;
			}
			else
			{
				IgniteTimer[entity] = null;
				IgniteFor[entity] = 0;
				BurnDamage[entity] = 0.0;
				return Plugin_Stop;		
			}
		}
		else
		{
			IgniteTimer[entity] = null;
			IgniteFor[entity] = 0;
			BurnDamage[entity] = 0.0;
			return Plugin_Stop;		
		}
	}
	return Plugin_Stop;
}

int GetIndexByPluginName(const char[] name)
{
	for(int i; i<sizeof(NPC_Plugin_Names_Converted); i++)
	{
		if(StrEqual(name, NPC_Plugin_Names_Converted[i], false))
			return i;
	}
	return 0;
}

public Action NPC_TraceAttack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& ammotype, int hitbox, int hitgroup)
{
//	PrintToChatAll("ow NPC_TraceAttack");
	if(attacker < 1 || attacker > MaxClients || victim == attacker)
		return Plugin_Continue;
		
	if(inflictor < 1 || inflictor > MaxClients)
		return Plugin_Continue;

	/*
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	*/
	
	if((damagetype & (DMG_BLAST))) //make sure any hitscan boom type isnt actually boom
	{
		f_IsThisExplosiveHitscan[attacker] = GetGameTime();
		damagetype |= DMG_BULLET; //add bullet logic
		damagetype &= ~DMG_BLAST; //remove blast logic	
	}
	else
	{
		f_IsThisExplosiveHitscan[attacker] = 0.0;
	}
	
//	if((damagetype & (DMG_BULLET)) || (damagetype & (DMG_BUCKSHOT))) // Needed, other crap for some reason can trigger headshots, so just make sure only bullets can do this.
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
	{
		f_TraceAttackWasTriggeredSameFrame[victim] = GetGameTime();
		i_HasBeenHeadShotted[victim] = false;
		if(damagetype & DMG_BULLET)
		{
			if(i_WeaponDamageFalloff[weapon] != 1.0) //dont do calculations if its the default value, meaning no extra or less dmg from more or less range!
			{
				float AttackerPos[3];
				float VictimPos[3];
				
				AttackerPos = WorldSpaceCenter(attacker);
				VictimPos = WorldSpaceCenter(victim);

				float distance = GetVectorDistance(AttackerPos, VictimPos, true);
				
				distance -= 1600.0;// Give 60 units of range cus its not going from their hurt pos

				if(distance < 0.1)
				{
					distance = 0.1;
				}

				damage *= Pow(i_WeaponDamageFalloff[weapon], (distance/1000000.0)); //this is 1000, we use squared for optimisations sake
			}
		}
		if(!i_WeaponCannotHeadshot[weapon])
		{
			bool Blitzed_By_Riot = false;
			if(f_TargetWasBlitzedByRiotShield[victim][weapon] > GetGameTime())
			{
				Blitzed_By_Riot = true;
			}

			if((hitgroup == HITGROUP_HEAD && !b_CannotBeHeadshot[victim]) || Blitzed_By_Riot)
			{
				
#if defined ZR
				if(b_ThisNpcIsSawrunner[victim])
				{
					damage *= 2.0;
				}
#endif

				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 2.0;
				}
				else
				{
					damage *= 1.65;
				}

				if(Blitzed_By_Riot) //Extra damage.
				{
					damage *= 1.35;
				}
				else
				{
					i_HasBeenHeadShotted[victim] = true; //shouldnt count as an actual headshot!
				}

#if defined ZR
				if(i_CurrentEquippedPerk[attacker] == 5) //I guesswe can make it stack.
				{
					damage *= 1.25;
				}
#endif
				
				int pitch = GetRandomInt(90, 110);
				int random_case = GetRandomInt(1, 2);
				float volume = 0.7;
				
				if(played_headshotsound_already[attacker] >= GetGameTime())
				{
					random_case = played_headshotsound_already_Case[attacker];
					pitch = played_headshotsound_already_Pitch[attacker];
					volume = 0.15;
				}
				else
				{
					DisplayCritAboveNpc(victim, attacker, Blitzed_By_Riot);
					played_headshotsound_already_Case[attacker] = random_case;
					played_headshotsound_already_Pitch[attacker] = pitch;
				}
				
#if defined ZR
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					int BombsToInject = i_ArsenalBombImplanter[weapon];
					if(f_ChargeTerroriserSniper[weapon] > 149.0)
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject * 2;
					}
					else
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
					}
					if(i_CurrentEquippedPerk[attacker] == 5) //I guesswe can make it stack.
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
					}
					if(i_HeadshotAffinity[attacker] == 1)
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
					}
					Apply_Particle_Teroriser_Indicator(victim);
					damage = 0.0;
				}
#endif
				
				played_headshotsound_already[attacker] = GetGameTime();
				if(!Blitzed_By_Riot) //dont play headshot sound if blized.
				{
					switch(random_case)
					{
						case 1:
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && client != attacker)
								{
									EmitCustomToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
						}
						case 2:
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && client != attacker)
								{
									EmitCustomToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitCustomToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
						}
					}
				}
				return Plugin_Changed;
			}
			else
			{
				if(i_ArsenalBombImplanter[weapon] > 0)
				{
					int BombsToInject = i_ArsenalBombImplanter[weapon];
					if(i_HeadshotAffinity[attacker] == 1)
					{
						i_HowManyBombsOnThisEntity[victim][attacker] -= BombsToInject;
					}
				}
				if(i_HeadshotAffinity[attacker] == 1)
				{
					damage *= 0.65;
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Changed;
}
		
//Otherwise we get kicks if there is too much hurting going on.

public void Func_Breakable_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
#if defined ZR
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
#endif
	
	Event event = CreateEvent("npc_hurt");
	if (event) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", Health > 0 ? Health : 0);
		event.SetInt("damageamount", RoundToFloor(damage));
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if (attacker > 0 && attacker <= MaxClients)
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}
		else 
		{
			event.SetInt("attacker_player", 0);
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}
public void Map_BaseBoss_Damage_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	if(attacker < 1 || attacker > MaxClients)
		return;
	
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	
#if defined ZR
	float damage_Caclulation = damage;
		
	//for some reason it doesnt do it by itself, im baffeled.

	if(Health < 0)
		damage_Caclulation += float(Health);
	
	if(damage_Caclulation > 0.0) //idk i guess my math is off or that singular/10 frames of them being still being there somehow impacts this, cannot go around this, delay is a must
		Damage_dealt_in_total[attacker] += damage_Caclulation;	//otherwise alot of other issues pop up.
	
	Damage_dealt_in_total[attacker] += damage_Caclulation;
#endif
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime())
	{
		f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		
		SetHudTextParams(-1.0, 0.2, 1.0, 255, 200, 200, 255, 0, 0.01, 0.01);
		ShowSyncHudText(attacker, SyncHud, "%d", Health);
	}
}
public Action NPC_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	/*
	if(damagetype & DMG_DROWN)
	{
		damage *= 5.0;
		return Plugin_Changed;	
	}
	*/
	//they dont take drown dmg ever.
	bool WeaponWasValid = false;

	if(b_NpcIsInvulnerable[victim] && damage < 999999.9)// if your damage is higher then a million, we give up and let it through, theres multiple reasons why, mainly slaying.
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	CClotBody npcBase = view_as<CClotBody>(victim);
	if(attacker < 1 ||/* attacker > MaxClients ||*/ victim == attacker)
	{
		//nothing happens.
	}
	else
	{

#if defined ZR
		//should not steal.
		if(Saga_EnemyDoomed(victim) && attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE && Saga_IsChargeWeapon(attacker, weapon))
		{
			damage = 0.0;
			return Plugin_Handled;
		}
#endif
		
		float GameTime = GetGameTime();
		if(b_NpcHasDied[attacker] || b_NpcHasDied[victim])
		{
			if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum")) //should be entirely ignored
			{
				damage = 0.0;
				return Plugin_Handled;
			}
		}

		f_TimeUntillNormalHeal[victim] = GameTime + 4.0;
		i_HasBeenBackstabbed[victim] = false;

		if(f_TraceAttackWasTriggeredSameFrame[victim] != GameTime)
		{
			i_HasBeenHeadShotted[victim] = false;
		}
		
#if defined ZR
		if(b_IsAlliedNpc[victim])
		{
			if(f_FreeplayDamageExtra != 1.0)
			{
				damage *= f_FreeplayDamageExtra;
			}
			if(OnTakeDamage_ShieldLogic(victim, damagetype))
			{
				return Plugin_Handled;
			}
		}

		if(b_npcspawnprotection[victim])
			damage *= 0.25;
#endif

#if defined RPG
		if(b_NpcIsInADungeon[victim] || attacker > MaxClients || Level[victim] > 100000)
		{
			
		}
		//We check if the npc is already hurt, dead, or other stuff like that.

		//TODO:
		//Make sure ownership goes over other party members if you die
		//Realisticly speaking this should never be an issue.
		else if(!i_NpcFightOwner[victim] || f_NpcFightTime[victim] < GameTime || !IsClientInGame(i_NpcFightOwner[victim]) || !IsPlayerAlive(i_NpcFightOwner[victim]))
		{
			if(b_npcspawnprotection[victim] && i_NpcIsUnderSpawnProtectionInfluence[victim] && Level[victim] < (Level[attacker] - 8))
			{
				damage = 0.0;
			}
			else
			{
				i_NpcFightOwner[victim] = attacker;
				f_NpcFightTime[victim] = GameTime + 10.0;
			}
		}
		else if(i_NpcFightOwner[victim] != attacker && !Party_IsClientMember(i_NpcFightOwner[victim], attacker))
		{
			damage = 0.0;
		}
		else
		{
			f_NpcFightTime[victim] = GameTime + 10.0;
		}

		if(!b_NpcIsInADungeon[victim] && Level[victim] < 100000)
		{
			// Reduces damage when fighting enemies higher level than you
			int underLv = Level[victim] - Level[attacker];
			if(underLv > 3)
			{
				damage /= Pow(float(underLv - 2), 0.5);
			}
		}
#endif

		if(f_NpcHasBeenUnstuckAboveThePlayer[victim] > GameTime) //They were immortal, just nullfy any and all damage.
		{
			damage = 0.0;
		}

		/*
			The Bloons:
			
			DMG_BLAST = Good vs Lead, Bad vs Black
			
			DMG_VEHICLE = Good vs Lead, Bad vs White
			
			DMG_BURN, DMG_SONIC = Good vs Lead, Bad vs Purple
			
			DMG_PLASMA = Bad vs Purple, good against lead
			
			DMG_SHOCK = Bad vs purple and lead
		*/
		if(!(damagetype & DMG_NOCLOSEDISTANCEMOD))
		{
			damagetype |= DMG_NOCLOSEDISTANCEMOD; //Remove damage ramp up cus it makes camping like 9458349573483285734895x more efficient then walking to wallmart
		}
		if(damagetype & DMG_USEDISTANCEMOD)
		{
			damagetype &= ~DMG_USEDISTANCEMOD; //Remove damage falloff.
		}
		/*
		if(i_CurrentEquippedPerk[attacker] == 3)
		{
			damage *= 1.20;
			
		}
		*/

		//This exists for rpg so that attacking the target will trigger it for hte next 5 seconds.
		//ZR does not need this.
#if defined RPG
		if(IsValidEntity(attacker))
		{
			if(GetEntProp(attacker, Prop_Send, "m_iTeamNum")!=GetEntProp(victim, Prop_Send, "m_iTeamNum"))
			{
				npcBase.m_flGetClosestTargetNoResetTime = GetGameTime(npcBase.index) + 5.0; //make them angry for 5 seconds if they are too far away.

				if(npcBase.m_iTarget == -1) //Only set it if they actaully have no target.
				{
					npcBase.m_iTarget = attacker;
				}
			}
		}
#endif
		if(f_IsThisExplosiveHitscan[attacker] == GameTime)
		{
			npcBase.m_vecpunchforce(CalculateDamageForceSelfCalculated(attacker, 10000.0), true);
			damagetype |= DMG_BULLET; //add bullet logic
			damagetype &= ~DMG_BLAST; //remove blast logic			
		}

		if((damagetype & DMG_CLUB)) //Needs to be here because it already gets it from the top.
		{
#if defined ZR
			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && !b_IsAlliedNpc[victim])
				{
					damage *= Medival_Difficulty_Level;
				}
			}
#endif
			damage *= fl_MeleeArmor[victim];
			damage *= fl_Extra_MeleeArmor[victim];
		}
		else if(!(damagetype & DMG_SLASH))
		{
#if defined ZR
			if(i_CurrentEquippedPerk[attacker] == 5)
			{
				damage *= 1.25;
			}
			if(!NpcStats_IsEnemySilenced(victim))
			{
				if(Medival_Difficulty_Level != 0.0 && !b_IsAlliedNpc[victim])
				{
					damage *= Medival_Difficulty_Level;
				}
			}
#endif
			damage *= fl_RangedArmor[victim];
			damage *= fl_Extra_RangedArmor[victim];
		}
		damage *= fl_Extra_Damage[attacker];
#if defined ZR
		VausMagicaShieldLogicNpcOnTakeDamage(victim, damage);
#endif
		if(i_CurrentEquippedPerk[victim] == 6)
		{
			if(f_WidowsWineDebuffPlayerCooldown[victim] < GameTime) //either too much dmg, or your health is too low.
			{
				f_WidowsWineDebuffPlayerCooldown[victim] = GameTime + 20.0;
				
				float vecVictim[3]; vecVictim = WorldSpaceCenter(victim);
				
				ParticleEffectAt(vecVictim, "peejar_impact_cloud_milk", 0.5);
				
				EmitSoundToAll("weapons/jar_explode.wav", victim, SNDCHAN_AUTO, 60, _, 1.0);

				damage *= 0.5;
				f_WidowsWineDebuff[attacker] = GameTime + FL_WIDOWS_WINE_DURATION;
			}
		}

		//No resistances towards slash as its internal.

		if(damagePosition[0] != 0.0) //If there is no pos, then dont.
		{
			if(!(damagetype & (DMG_SHOCK)))
			{
				if (f_CooldownForHurtParticle[victim] < GameTime)
				{
					f_CooldownForHurtParticle[victim] = GameTime + 0.1;

					if(npcBase.m_iBleedType == BLEEDTYPE_NORMAL)
					{
						TE_ParticleInt(g_particleImpactFlesh, damagePosition);
						TE_SendToAll();
					}
					else if (npcBase.m_iBleedType == BLEEDTYPE_METAL)
					{
						damagePosition[2] -= 40.0;
						TE_ParticleInt(g_particleImpactMetal, damagePosition);
						TE_SendToAll();
					}
					else if (npcBase.m_iBleedType == BLEEDTYPE_RUBBER)
					{
						TE_ParticleInt(g_particleImpactRubber, damagePosition);
						TE_SendToAll();
					}
					else if (npcBase.m_iBleedType == BLEEDTYPE_XENO)
					{
						//If you cant find any good blood effect, use this one and just recolour it.
						TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 125, 255, 125, 255, 32);
						TE_SendToAll();
					}
					else if (npcBase.m_iBleedType == BLEEDTYPE_SEABORN)
					{
						//If you cant find any good blood effect, use this one and just recolour it.
						TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 65, 65, 255, 255, 32);
						TE_SendToAll();
					}
				}
			}
		}
		
		if(Rogue_InItallianWrath(weapon))
		{
			damage *= 2.0;
		}
		OnTakeDamage_RogueItemGeneric(attacker, damage, damagetype, inflictor);

		float BaseDamageBeforeBuffs = damage;

		if(!NpcStats_IsEnemySilenced(attacker))
		{
			if(f_HussarBuff[attacker] > GameTime) //hussar!
			{
				damage += BaseDamageBeforeBuffs * 0.1;
			}
			if(f_GodArkantosBuff[victim] > GameTime) //hussar!
			{
				damage += BaseDamageBeforeBuffs * 0.5; //50% more damage!
			}
		}
		if(f_Ocean_Buff_Stronk_Buff[attacker] > GameTime) //hussar!
		{
			damage += BaseDamageBeforeBuffs * 0.25;
		}
		else if (f_Ocean_Buff_Weak_Buff[attacker] > GameTime) //hussar!
		{
			damage += BaseDamageBeforeBuffs * 0.1;
		}
		if(f_EmpowerStateOther[attacker] > GameTime) //Allow stacking.
		{
			damage += BaseDamageBeforeBuffs * 0.1;
		}
		if(f_EmpowerStateSelf[attacker] > GameTime) //Allow stacking.
		{
			damage += BaseDamageBeforeBuffs * 0.15;
		}
		if(f_BuffBannerNpcBuff[attacker] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.35;
		}
		if(f_HighTeslarDebuff[victim] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.35;
		}
		else if(f_LowTeslarDebuff[victim] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.25;
		}
		if(f_PotionShrinkEffect[victim] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.35;
		}
		if(f_Ruina_Attack_Buff[attacker] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * f_Ruina_Attack_Buff_Amt[attacker];	//x% dmg bonus
		}
		if(f_Ruina_Defense_Buff[victim] > GameTime)
		{
			damage -= BaseDamageBeforeBuffs * f_Ruina_Defense_Buff_Amt[victim];	//x% dmg resist
		}
		
		if(f_HighIceDebuff[victim] > GameTime)
		{
			if(IsZombieFrozen(victim))
				damage += BaseDamageBeforeBuffs * 0.30;
			else
				damage += BaseDamageBeforeBuffs * 0.15;
		}
		else if(f_LowIceDebuff[victim] > GameTime)
		{
			if(IsZombieFrozen(victim))
				damage += BaseDamageBeforeBuffs * 0.20;
			else
				damage += BaseDamageBeforeBuffs * 0.10;
		}
		else if(f_VeryLowIceDebuff[victim] > GameTime)
		{
			if(IsZombieFrozen(victim))
				damage += BaseDamageBeforeBuffs * 0.10;
			else
				damage += BaseDamageBeforeBuffs * 0.5;
		}
		
		if(f_WidowsWineDebuff[victim] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.35;
		}

		if(Increaced_Overall_damage_Low[attacker] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.25;
		}
		
		if(f_CrippleDebuff[victim] > GameTime)
		{
			damage += BaseDamageBeforeBuffs * 0.4;
		}

		//Resistance buffs will not count towards this flat decreace, they will be universal!
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(f_HussarBuff[victim] > GameTime) //hussar!
			{
				damage *= 0.90;
			}
			if(f_GodArkantosBuff[victim] > GameTime) //hussar!
			{
				damage *= 0.75;
			}
		}
		if(f_PotionShrinkEffect[attacker] > GameTime || (IsValidEntity(inflictor) && f_PotionShrinkEffect[attacker] > GameTime))
		{
			damage *= 0.5; //half the damage when small.
		}
		if(f_BattilonsNpcBuff[victim] > GameTime)
		{
			damage *= 0.65;
		}		
		if(Resistance_Overall_Low[victim] > GameTime)
		{
			damage *= 0.85;
		}
				
		if(attacker <= MaxClients)
		{
#if defined RPG	

			//Random crit damage!
			//Yes, we allow those.
			if(GetRandomFloat(0.0, 1.0) < (float(1 + Stats_Luck(attacker)) * 0.001))
			{
				damage *= 3.0;
				DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
			}

#endif

#if defined ZR
			if(dieingstate[attacker] > 0 && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_IGNORE_DEATH_PENALTY))
			{
				damage *= 0.25;
			}
#endif
			
			if(damagecustom>=TF_CUSTOM_SPELL_TELEPORT && damagecustom<=TF_CUSTOM_SPELL_BATS)
			{
				//nope, no fireball damage. or any mage damage.
				damage = 0.0;
			//	return Plugin_Handled;
			}

			//NPC STUFF FOR RECORD AND ON KILL
			LastHitRef[victim] = EntIndexToEntRef(attacker);
			DamageBits[victim] = damagetype;
			Damage[victim] = damage;
			
			if(weapon > MaxClients)
				LastHitWeaponRef[victim] = EntIndexToEntRef(weapon);
			else
				LastHitWeaponRef[victim] = -1;
				
			//NPC STUFF FOR RECORD AND ON KILL
			
			Attributes_OnHit(attacker, victim, weapon, damage, damagetype);
			
			if(i_BarbariansMind[attacker] == 1)	// Deal extra damage with melee, but none with everything else
			{
				if(damagetype & (DMG_CLUB|DMG_SLASH)) // if you want anything to be melee based, just give them this.
					damage *= 1.10;
				else
					damage = 0.0;
			}

		}
		//This only ever effects base_bosses so dont worry about sentries hurting you
		if(!(damagetype & DMG_SLASH)) //Use dmg slash for any npc that shouldnt be scaled.
		{
			if(IsValidEntity(inflictor) && inflictor>MaxClients)// && attacker<=MaxClients)
			{
				if(i_IsABuilding[inflictor])
				{
#if defined RPG
					if(RpgHasSentry(attacker)) //BUFF SENTRIES DUE TO NO PERKS IN ESCAPE!!!
					{
						damage = SentryDamageRpg(attacker);
					}
#endif
					if(Increaced_Sentry_damage_Low[inflictor] > GameTime)
					{
						damage *= 1.15;
					}
					else if(Increaced_Sentry_damage_High[inflictor] > GameTime)
					{
						damage *= 1.3;
					}
				}
#if defined ZR
				else if(b_IsAlliedNpc[inflictor]) //add a filter so it only does it for allied base_bosses
				{
					CClotBody npc = view_as<CClotBody>(inflictor);
					if(npc.m_bScalesWithWaves)
					{
						int Wave_Count = Waves_GetRound() + 1;
						if(Wave_Count <= 10)
							damage *= 0.35;
							
						else if(Wave_Count <= 15)
							damage *= 1.0;
						
						else if(Wave_Count <= 20)
							damage *= 1.35;
							
						else if(Wave_Count <= 25)
							damage *= 2.5;
							
						else if(Wave_Count <= 30)
							damage *= 5.0;
							
						else if(Wave_Count <= 40)
							damage *= 7.0;
							
						else if(Wave_Count <= 45)
							damage *= 20.0;
						
						else if(Wave_Count <= 50)
							damage *= 30.0;
						
						else if(Wave_Count <= 60)
							damage *= 40.0;
						
						else
							damage *= 60.0;
					}
				}
#endif	// ZR
				
			}
			if(attacker <= MaxClients)
			{
				if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
				{
					DoClientHitmarker(attacker);
				}
				if(IsValidEntity(weapon))
				{
#if defined RPG
					char Weaponclassname[64];
					GetEntityClassname(weapon, Weaponclassname, 64);

					int slot = TF2_GetClassnameSlot(Weaponclassname);

					if(f_HealingPotionDuration[attacker] > GameTime) //Client has a buff, but which one?
					{
						switch(f_HealingPotionEffect[attacker])
						{
							case MELEE_BUFF_2:
							{
								if(slot == TFWeaponSlot_Melee && !i_IsWandWeapon[weapon] && !i_IsWrench[weapon]) //Only melee.
								{
									damage *= 1.15;
								}
							}
							case RANGED_BUFF_2: 
							{
								if(slot < TFWeaponSlot_Melee) //Only Ranged
								{
									damage *= 1.25;
								}
							}
							case MAGE_BUFF_2:
							{
								if(i_IsWandWeapon[weapon]) //Only Mage.
								{
									damage *= 1.25;
								}
							}
							default: //Nothing.
							{
								damage *= 1.0;
							}
						}
					}		
					damage = RpgCC_ContractExtrasNpcOnTakeDamage(victim, attacker, damage, damagetype, weapon, slot);
#endif

#if defined ZR
					if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
					{
						WeaponWasValid = true;
						float modified_damage = NPC_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);	
						damage = modified_damage;
						OnTakeDamage_HandOfElderMages(attacker, weapon);
					}
					
					
					if(i_ArsenalBombImplanter[weapon] > 0)
					{
						int BombsToInject = i_ArsenalBombImplanter[weapon];
						float damage_save = 50.0;

						damage_save *= Attributes_Get(weapon, 2, 1.0);

						f_BombEntityWeaponDamageApplied[victim][attacker] = damage_save;

						if(f_ChargeTerroriserSniper[weapon] > 149.0)
						{
							i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject * 2;
						}
						else
						{
							i_HowManyBombsOnThisEntity[victim][attacker] += BombsToInject;
						}
						Apply_Particle_Teroriser_Indicator(victim);
						damage = 0.0;
					}
	#endif
					
					if(i_HighTeslarStaff[weapon] == 1)
					{
						f_HighTeslarDebuff[victim] = GameTime + 5.0;
					}
					else if(i_LowTeslarStaff[weapon] == 1)
					{
						f_LowTeslarDebuff[victim] = GameTime + 5.0;
					}
					
					/*
					for (int client = 1; client <= MaxClients; client++)
					{
						i_HowManyBombsOnThisEntity[victim][client] = 0; //to clean on death ofc.
					}
					*/
					if(f_BackstabDmgMulti[weapon] != 0.0 && !b_CannotBeBackstabbed[victim]) //Irene weapon cannot backstab.
					{
						if(damagetype & DMG_CLUB && !(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED)) //Use dmg slash for any npc that shouldnt be scaled.
						{
							if(IsBehindAndFacingTarget(attacker, victim) || b_FaceStabber[attacker] || i_NpcIsABuilding[victim])
							{
								int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
								int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
								if(melee != 4 && melee != 1003 && viewmodel>MaxClients && IsValidEntity(viewmodel))
								{
									i_HasBeenBackstabbed[victim] = true;
										
									float attack_speed;

									attack_speed = 1.0;
									
									attack_speed *= Attributes_FindOnWeapon(attacker, weapon, 6, true, 1.0);
									attack_speed *= Attributes_FindOnWeapon(attacker, weapon, 396, true, 1.0); //Extra
										
									EmitSoundToAll("weapons/knife_swing_crit.wav", attacker, _, _, _, 0.7);
										
									DataPack pack = new DataPack();
									RequestFrame(DoMeleeAnimationFrameLater, pack);
									pack.WriteCell(EntIndexToEntRef(viewmodel));
									pack.WriteCell(melee);


									attack_speed *= f_BackstabCooldown[weapon]; //extra delay.

								//	damagetype |= DMG_CRIT; For some reason post ontakedamage doenst like crits. Shits wierd man.
									damage *= 5.25;

	#if defined ZR
									if(LastMann)
									{
										attack_speed *= 0.5; //extra delay.
									}
	#endif
									
									if(b_FaceStabber[attacker] || i_NpcIsABuilding[victim])
									{
										damage *= 0.35; //cut damage in half and then some.
									}
									
									CClotBody npc = view_as<CClotBody>(victim);
									
									if(attacker == npc.m_iTarget && !b_FaceStabber[attacker])
									{
										damage *= 2.0; // EXTRA BONUS DAMAGE GIVEN BEACUSE OF THE AI BEING SMARTER AND AVOIDING HITS BETTER! But not for facestabbers.
									}

									damage *= f_BackstabDmgMulti[weapon];		
	#if defined ZR
									if(i_CurrentEquippedPerk[attacker] == 5) //Deadshot!
									{
										damage *= 1.25;
									}
	#endif						
									
									//Latest tf2 update broke this, too lazy to fix lol
									
						//			THERE IS A FIX IN SOURCEMOD 1.12 FOR THIS!
									if(!b_IsPlayerNiko[attacker])
									{
										if(!(GetClientButtons(attacker) & IN_DUCK)) //This shit only works sometimes, i blame tf2 for this.
										{
											Animation_Retry[attacker] = 4;
											RequestFrame(Try_Backstab_Anim_Again, attacker);
											TE_Start("PlayerAnimEvent");
											Animation_Setting[attacker] = 1;
											Animation_Index[attacker] = 33;
											TE_WriteEnt("m_hPlayer",attacker);
											TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
											TE_WriteNum("m_nData", Animation_Index[attacker]);
											TE_SendToAll();
										}
									}
									
								
									int heal_amount = i_BackstabHealEachTick[weapon];
									int heal_ticks = i_BackstabHealTicks[weapon];
									if(heal_amount && heal_ticks)
									{
										if(b_FaceStabber[attacker])
										{
											heal_amount /= 4;
											heal_ticks	/= 4;
											if(heal_amount < 1)
											{
												heal_amount = 1;
											}
											if(heal_ticks < 1)
											{
												heal_ticks = 1;
											}

										}
										StartHealingTimer(attacker, 0.1, float(heal_amount), heal_ticks);
									}
									if(f_BackstabCooldown[weapon] != 0.0)
									{
										SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GameTime+(attack_speed));
										SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GameTime+(attack_speed));
									}

									if(b_BackstabLaugh[weapon])
									{
										SepcialBackstabLaughSpy(attacker);
									}
								}
							}
						}
					}
	#if defined ZR
					else if(b_IsABow[weapon])
					{
						if(damagetype & DMG_CRIT)
						{		
							if(i_HeadshotAffinity[attacker] == 1)
							{
								damage *= 1.35;
							}
							if(i_CurrentEquippedPerk[attacker] == 5) //Just give them 25% more damage if they do crits with the huntsman, includes buffbanner i guess
							{
								damage *= 1.25;
							}
						}
						else
						{
							if(i_HeadshotAffinity[attacker] == 1) //if no crit, penalise
							{
								damage *= 0.75;
							}
						}
					}
	#endif
					
					/*
					else
					{	
						int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
						//Check if the weapon is a laser weapon, these weapons have wierd shit that causes people to crash with the way we use them
						switch(weaponindex)
						{
							case 442: // Bison
							{
								PrintToChatAll("test");
								int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
								SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
							}
							case 588: // Pomson
							{
								int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
								SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
							}
							case 441: // Mangler
							{
								int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
								SetEntProp(viewmodel, Prop_Send, "m_nSequence", 1);
							}
						}
					}
					*/
						
				}
			}
		}
		switch (damagecustom) //Make sure taunts dont do any damage, cus op as fuck
		{
			case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
			TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
			TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
			{
				damage = 0.0;
			}
			
		}	//Remove annoying instakill taunts
	}

	NpcSpecificOnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
#if defined ZR	
	if(SeargentIdeal_Existant())
	{
		SeargentIdeal_Protect(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	}
#endif
	if(WeaponWasValid)
	{
		float modified_damage = NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);	
		damage = modified_damage;
	}

	npcBase.m_vecpunchforce(damageForce, true);
	npcBase.m_bGib = false;
	if(!npcBase.m_bDissapearOnDeath) //Make sure that if they just vanish, its always false. so their deathsound plays.
	{
		if((damagetype & DMG_BLAST))
		{
			npcBase.m_bGib = true;
		}
		else if((i_HexCustomDamageTypes[victim] & ZR_DAMAGE_GIB_REGARDLESS))
		{
			npcBase.m_bGib = true;
		}
		else if(damage > (GetEntProp(victim, Prop_Data, "m_iMaxHealth") * 1.5))
		{
			npcBase.m_bGib = true;
		}
	}
	if(RogueFizzyDrink())
	{
		npcBase.m_bGib = true;
	}

	return Plugin_Changed;
}

public void NPC_OnTakeDamage_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3])
{
	
	if(inflictor > 0 && inflictor <= MaxClients)
	{
		GiveRageOnDamage(inflictor, damage);
		Calculate_And_Display_hp(inflictor, victim, damage, false);
	}
	else if(attacker > 0 && attacker <= MaxClients)
	{
		GiveRageOnDamage(attacker, damage);
		Calculate_And_Display_hp(attacker, victim, damage, false);	
	}
	/*
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		return;
	}
	*/
	OnPostAttackUniqueWeapon(attacker, victim, weapon, i_HexCustomDamageTypes[victim]);

	int health = GetEntProp(victim, Prop_Data, "m_iHealth");

	Event event = CreateEvent("npc_hurt");
	if(event) 
	{
		event.SetInt("entindex", victim);
		event.SetInt("health", health);
		event.SetInt("damageamount", RoundToFloor(damage));
		event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

		if(attacker > 0 && attacker <= MaxClients)
		{
			event.SetInt("attacker_player", GetClientUserId(attacker));
			event.SetInt("weaponid", 0);
		}
		else 
		{
			event.SetInt("attacker_player", 0);
			event.SetInt("weaponid", 0);
		}

		event.Fire();
	}

	i_HexCustomDamageTypes[victim] = 0; //Reset it back to 0.
	if(health <= 0)
		CBaseCombatCharacter_EventKilledLocal(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
}

void GiveRageOnDamage(int client, float damage)
{
	if(!GetEntProp(client, Prop_Send, "m_bRageDraining"))
	{
		float rage = GetEntPropFloat(client, Prop_Send, "m_flRageMeter") + (damage * 0.05);
		if(rage > 100.0)
			rage = 100.0;
			
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", rage);
	}
}
void Generic_OnTakeDamage(int victim, int attacker)
{
	if(attacker > 0)
	{
		CClotBody npc = view_as<CClotBody>(victim);
		float gameTime = GetGameTime(npc.index);

		if(npc.m_flHeadshotCooldown < gameTime)
		{
			npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
}

static float f_damageAddedTogether[MAXTF2PLAYERS];
static float f_damageAddedTogetherGametime[MAXTF2PLAYERS];
static float f_HudCooldownAntiSpam[MAXTF2PLAYERS];
static float f_HudCooldownAntiSpamRaid[MAXTF2PLAYERS];

static int i_HudVictimToDisplay[MAXTF2PLAYERS];

stock void RemoveAllDamageAddition()
{
	Zero(f_damageAddedTogether);
	Zero(f_damageAddedTogetherGametime);
}
void RemoveHudCooldown(int client)
{
	f_HudCooldownAntiSpam[client] = 0.0;
}


stock void Calculate_And_Display_HP_Hud(int attacker)
{
	int victim = i_HudVictimToDisplay[attacker];
	if(!IsValidEntity(victim))
		return;

#if defined ZR
	bool raidboss_active = false;
	int raid_entity = EntRefToEntIndex(RaidBossActive);
	if(IsValidEntity(raid_entity))
	{
		raidboss_active = true;
	}

	if(raidboss_active)
	{
		if(raid_entity != victim) //If a raid is alive, but the victim is not the raid! we need extra rules.
		{
			if(f_HudCooldownAntiSpam[attacker] >= GetGameTime())
				return;

			f_HudCooldownAntiSpam[attacker] = GetGameTime() + 0.2;
		}
		else
		{
			//need a diff timer for raids, otherwise it cant display both huds!!
			if(f_HudCooldownAntiSpamRaid[attacker] >= GetGameTime())
				return;

			f_HudCooldownAntiSpamRaid[attacker] = GetGameTime() + 0.2;
		}
	}
	else
#endif
	
	{
		if(f_HudCooldownAntiSpam[attacker] >= GetGameTime())
			return;

		f_HudCooldownAntiSpam[attacker] = GetGameTime() + 0.2;		
	}

	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	int MaxHealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
	int red = 255;
	int green = 255;
	int blue = 0;

	if(b_NpcIsInvulnerable[victim])
	{
		red = 255;
		green = 255;
		blue = 255;
	}
	else
	{
#if defined RPG
		if((!b_npcspawnprotection[victim] || i_NpcIsUnderSpawnProtectionInfluence[victim] == 0) && (i_NpcFightOwner[victim] == attacker || Party_IsClientMember(i_NpcFightOwner[victim], attacker)))
#endif
#if defined ZR
		if(!b_npcspawnprotection[victim])
#endif
		{
			red = (Health + 1) * 255  / (MaxHealth + 1);
			//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			green = (Health + 1) * 255  / (MaxHealth + 1);
						
			red = 255 - red;
					
			if(Health <= 0)
			{
				red = 255;
				green = 0;
				blue = 0;
			}
			else if(Health >= MaxHealth)
			{
				red = 0;
				green = 255;
				blue = 0;				
			}
		}
		else
		{
			red = 0;
			green = 0;
			blue = 255;
		}
			
		
	}
	char Debuff_Adder[64];
		
	bool Debuff_added = false;
	bool Debuff_added_hud = false;
	float GameTime = GetGameTime();

	if(f_HighTeslarDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "⌁⌁");
	}
	else if(f_LowTeslarDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "⌁");
	}
		
	if(BleedAmountCountStack[victim] > 0) //bleed
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❣%i", Debuff_Adder, BleedAmountCountStack[victim]);			
	}
		
	if(IgniteFor[victim] > 0) //burn
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s~", Debuff_Adder);			
	}
		
	if(f_HighIceDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅❅❅", Debuff_Adder);
	}
	else if(f_LowIceDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅❅", Debuff_Adder);
	}
	else if (f_VeryLowIceDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅", Debuff_Adder);	
	}
		
	if(f_WidowsWineDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s४", Debuff_Adder);
	}
		
	if(f_CrippleDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s⯯", Debuff_Adder);
	}
		
	if(f_MaimDebuff[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s↓", Debuff_Adder);
	}
	if(f_PotionShrinkEffect[victim] > GameTime)
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s▼", Debuff_Adder);
	}
	if(NpcStats_IsEnemySilenced(victim))
	{
		Debuff_added = true;
		Debuff_added_hud = true;
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%sX", Debuff_Adder);
	}
	if(Increaced_Overall_damage_Low[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⌃%s", Debuff_Adder);
	}
	if(Resistance_Overall_Low[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⌅%s", Debuff_Adder);
	}
	if(f_EmpowerStateOther[victim] > GameTime) //Do not show fusion self buff.
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⍋%s", Debuff_Adder);
	}
	if(f_HussarBuff[victim] > GameTime) //hussar!
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "ᐩ%s", Debuff_Adder);
	}
	if(f_GodArkantosBuff[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "ß%s", Debuff_Adder);
	}
	if(f_Ocean_Buff_Stronk_Buff[victim] > GameTime) //hussar!
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⍟%s", Debuff_Adder);
	}
	else if(f_Ocean_Buff_Weak_Buff[victim] > GameTime) //hussar!
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⌾%s", Debuff_Adder);
	}
	if(f_BattilonsNpcBuff[victim] > GameTime) //hussar!
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "⛨%s", Debuff_Adder);
	}
	if(f_BuffBannerNpcBuff[victim] > GameTime) //hussar!
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "↖%s", Debuff_Adder);
	}
	
	if(f_Ruina_Defense_Buff[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "♜%s", Debuff_Adder);
	}
	if(f_Ruina_Speed_Buff[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "♝%s", Debuff_Adder);
	}
	if(f_Ruina_Attack_Buff[victim] > GameTime)
	{
		if(Debuff_added_hud)
		{
			Format(Debuff_Adder, sizeof(Debuff_Adder), " |%s ", Debuff_Adder);
			Debuff_added_hud = false;
		}
		Debuff_added = true;
		Format(Debuff_Adder, sizeof(Debuff_Adder), "♟%s", Debuff_Adder);
	}
	
	if(Debuff_added)
	{
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s\n", Debuff_Adder);
	}
	
	CClotBody npc = view_as<CClotBody>(victim);
	Debuff_added = false;

#if defined ZR
	if(npc.m_flMeleeArmor != 1.0 || (Medival_Difficulty_Level != 0 && !NpcStats_IsEnemySilenced(victim)) || fl_Extra_MeleeArmor[victim] != 1.0)
#else
	if(npc.m_flMeleeArmor != 1.0 || fl_Extra_MeleeArmor[victim] != 1.0)
#endif
	
	{
		float percentage = npc.m_flMeleeArmor * 100.0;
		percentage *= fl_Extra_MeleeArmor[victim];
		
#if defined ZR
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(Medival_Difficulty_Level != 0.0 && !b_IsAlliedNpc[victim])
			{
				percentage *= Medival_Difficulty_Level;
			}
		}
#endif
		
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s [♈ %.0f%%]", Debuff_Adder, percentage);
		Debuff_added = true;
	}
	
#if defined ZR
	if(npc.m_flRangedArmor != 1.0 || (Medival_Difficulty_Level != 0 && !NpcStats_IsEnemySilenced(victim)) || fl_Extra_RangedArmor[victim] != 1.0)
#else
	if(npc.m_flRangedArmor != 1.0 || fl_Extra_RangedArmor[victim] != 1.0)
#endif
	
	{
		float percentage = npc.m_flRangedArmor * 100.0;
		percentage *= fl_Extra_RangedArmor[victim];
		
#if defined ZR
		if(!NpcStats_IsEnemySilenced(victim))
		{
			if(Medival_Difficulty_Level != 0.0 && !b_IsAlliedNpc[victim])
			{
				percentage *= Medival_Difficulty_Level;
			}
		}
#endif
		
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s [♐ %.0f%%]", Debuff_Adder, percentage);
		Debuff_added = true;
	}
	if(Debuff_added)
	{
		FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s\n", Debuff_Adder);
	}
#if defined ZR
	if(EntRefToEntIndex(RaidBossActive) != victim)
	{
		float HudOffset = 0.05;

		if(raidboss_active)
		{
			HudOffset = 0.205;

			int raidboss = EntRefToEntIndex(RaidBossActive);
			//We have to check if the raidboss has any debuffs.
			if(fl_RangedArmor[raidboss] != 1.0 || fl_Extra_RangedArmor[raidboss] != 1.0)
			{
				HudOffset += 0.035;
			}
			else if(fl_MeleeArmor[raidboss] != 1.0 || fl_Extra_MeleeArmor[raidboss] != 1.0)
			{
				HudOffset += 0.035;
			}
			else if(Medival_Difficulty_Level != 0)
			{
				if(!NpcStats_IsEnemySilenced(raidboss))
				{
					HudOffset += 0.035;
				}
			}

			if(DoesNpcHaveHudDebuffOrBuff(raidboss, GameTime))
			{
				HudOffset += 0.035;
			}
		}

		SetGlobalTransTarget(attacker);
		float HudY = -1.0;

		HudY += f_HurtHudOffsetY[attacker];
		HudOffset += f_HurtHudOffsetX[attacker];

		SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		if(!b_NpcIsInvulnerable[victim])
		{
			if(!raidboss_active)
			{
				ShowSyncHudText(attacker, SyncHud, "%t\n%d / %d\n%s-%0.f", NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, f_damageAddedTogether[attacker]);
			}
			else
			{
				ShowSyncHudText(attacker, SyncHud, "%t\n%d / %d\n%s", NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder);	
			}
		}
		else
		{
			if(!raidboss_active)
			{
				ShowSyncHudText(attacker, SyncHud, "%t\n%d / %d\n%s %t", NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, "Invulnerable Npc");
			}
			else
			{
				ShowSyncHudText(attacker, SyncHud, "%t\n%d / %d\n%s %t", NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, "Invulnerable Npc");	
			}			
		}
	}
	else
	{
		float Timer_Show = RaidModeTime - GameTime;
	
		if(Timer_Show < 0.0)
			Timer_Show = 0.0;
			
		SetGlobalTransTarget(attacker);
		SetHudTextParams(-1.0, 0.05, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		if(!b_NpcIsInvulnerable[victim])
		{
			ShowSyncHudText(attacker, SyncHudRaid, "[%t | %t : %.1f%% | %t: %.1f]\n%s\n%d / %d \n%s-%0.f","Raidboss", "Power", RaidModeScaling * 100, "TIME LEFT", Timer_Show, NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, f_damageAddedTogether[attacker]);	
		}
		else
		{
			ShowSyncHudText(attacker, SyncHudRaid, "[%t | %t : %.1f%% | %t: %.1f]\n%s\n%d / %d \n%s %t","Raidboss", "Power", RaidModeScaling * 100, "TIME LEFT", Timer_Show, NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, "Invulnerable Npc");		
		}
	}
#endif	// ZR

#if defined RPG
	char level[32];
	GetDisplayString(Level[victim], level, sizeof(level));

	if(IsValidEntity(npc.m_iTextEntity3))
	{
		char HealthString[512];
		Format(HealthString, sizeof(HealthString), "%i / %i", Health, MaxHealth);
			
		DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
	}
	float HudY = -1.0;
	float HudOffset = 0.05;

	HudY += f_HurtHudOffsetY[attacker];
	HudOffset += f_HurtHudOffsetX[attacker];

	SetHudTextParams(HudY, HudOffset, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		
	//RPG cannot support translations! due to test and its used everywhere.
	ShowSyncHudText(attacker, SyncHud, "%s\n%s\n%d / %d\n%s-%0.f", level, NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder, f_damageAddedTogether[attacker]);
#endif
}

#if defined ZR
void ResetDamageHud(int client)
{
	SetHudTextParams(-1.0, 0.05, 1.0, 0, 0, 0, 255, 0, 0.01, 0.01);
	ShowSyncHudText(client, SyncHud, "");
}
#endif

stock void Calculate_And_Display_hp(int attacker, int victim, float damage, bool ignore, int overkill = 0)
{
	b_DisplayDamageHud[attacker] = true;
	i_HudVictimToDisplay[attacker] = victim;
	float GameTime = GetGameTime();
	bool raidboss_active = false;
	if(!b_NpcIsInvulnerable[victim])
	{
#if defined ZR
		if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			raidboss_active = true;
		}
		if(overkill <= 0)
		{
			Damage_dealt_in_total[attacker] += damage;
		}
		else
		{
			Damage_dealt_in_total[attacker] += overkill; //dont award for overkilling.
		}
#endif
		if(GameTime > f_damageAddedTogetherGametime[attacker])
		{
			if(!raidboss_active)
			{
				f_damageAddedTogether[attacker] = 0.0; //reset to 0 if raid isnt active.
			}
		}
		if(!ignore) //Cannot be a just show function
		{
			f_damageAddedTogether[attacker] += damage;
		}
		if(damage > 0)
		{
			f_damageAddedTogetherGametime[attacker] = GameTime + 0.6;
		}
	}
}

stock bool DoesNpcHaveHudDebuffOrBuff(int npc, float GameTime)
{
	if(f_HighTeslarDebuff[npc] > GameTime)
		return true;
	else if(f_LowTeslarDebuff[npc] > GameTime)
		return true;
	else if(BleedAmountCountStack[npc] > 0) //bleed
		return true;
	else if(IgniteFor[npc] > 0) //burn
		return true;
	else if(f_HighIceDebuff[npc] > GameTime)
		return true;
	else if(f_LowIceDebuff[npc] > GameTime)
		return true;
	else if (f_VeryLowIceDebuff[npc] > GameTime)
		return true;
	else if(f_WidowsWineDebuff[npc] > GameTime)
		return true;
	else if(f_CrippleDebuff[npc] > GameTime)
		return true;
	else if(f_MaimDebuff[npc] > GameTime)
		return true;
	else if(NpcStats_IsEnemySilenced(npc))
		return true;
	else if(Increaced_Overall_damage_Low[npc] > GameTime)
		return true;
	else if(Resistance_Overall_Low[npc] > GameTime)
		return true;
	else if(f_EmpowerStateOther[npc] > GameTime)
		return true;
	else if(f_HussarBuff[npc] > GameTime)
		return true;
	else if(f_PotionShrinkEffect[npc] > GameTime)
		return true;
	else if(f_GodArkantosBuff[npc] > GameTime)
		return true;
	else if(f_Ocean_Buff_Stronk_Buff[npc] > GameTime)
		return true;
	else if(f_Ocean_Buff_Weak_Buff[npc] > GameTime)
		return true;
	else if(f_BattilonsNpcBuff[npc] > GameTime)
		return true;
	else if(f_BuffBannerNpcBuff[npc] > GameTime)
		return true;
	else if(f_Ruina_Defense_Buff[npc] > GameTime)
		return true;
	else if(f_Ruina_Speed_Buff[npc] > GameTime)
		return true;
	else if(f_Ruina_Attack_Buff[npc] > GameTime)
		return true;

	return false;
}

void DoMeleeAnimationFrameLater(DataPack pack)
{
	pack.Reset();
	int viewmodel = EntRefToEntIndex(pack.ReadCell());
	if(viewmodel != INVALID_ENT_REFERENCE)
	{
		int animation = 38;
		switch(pack.ReadCell())
		{
			case 225, 356, 423, 461, 574, 649, 1071, 30758:  //Your Eternal Reward, Conniver's Kunai, Saxxy, Wanga Prick, Big Earner, Spy-cicle, Golden Frying Pan, Prinny Machete
				animation=12;

			case 638:  //Sharp Dresser
				animation=32;
		}
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	delete pack;
}
/*
enum PlayerAnimEvent_t
{
0	PLAYERANIMEVENT_ATTACK_PRIMARY, 	
1	PLAYERANIMEVENT_ATTACK_SECONDARY,
2	PLAYERANIMEVENT_ATTACK_GRENADE,
3	PLAYERANIMEVENT_RELOAD,
4	PLAYERANIMEVENT_RELOAD_LOOP,
5	PLAYERANIMEVENT_RELOAD_END,
6	PLAYERANIMEVENT_JUMP,
7	PLAYERANIMEVENT_SWIM,
8	PLAYERANIMEVENT_DIE,
9	PLAYERANIMEVENT_FLINCH_CHEST,
10	PLAYERANIMEVENT_FLINCH_HEAD,
11	PLAYERANIMEVENT_FLINCH_LEFTARM,
12	PLAYERANIMEVENT_FLINCH_RIGHTARM,
13	PLAYERANIMEVENT_FLINCH_LEFTLEG,
14	PLAYERANIMEVENT_FLINCH_RIGHTLEG,
15	PLAYERANIMEVENT_DOUBLEJUMP,

	// Cancel.
16	PLAYERANIMEVENT_CANCEL,
17	PLAYERANIMEVENT_SPAWN,

	// Snap to current yaw exactly
18	PLAYERANIMEVENT_SNAP_YAW,

19	PLAYERANIMEVENT_CUSTOM,				// Used to play specific activities
20	PLAYERANIMEVENT_CUSTOM_GESTURE,
21	PLAYERANIMEVENT_CUSTOM_SEQUENCE,	// Used to play specific sequences
22	PLAYERANIMEVENT_CUSTOM_GESTURE_SEQUENCE,

	// TF Specific. Here until there's a derived game solution to this.
23	PLAYERANIMEVENT_ATTACK_PRE,
24	PLAYERANIMEVENT_ATTACK_POST,
25	PLAYERANIMEVENT_GRENADE1_DRAW,
26	PLAYERANIMEVENT_GRENADE2_DRAW,
27	PLAYERANIMEVENT_GRENADE1_THROW,
28	PLAYERANIMEVENT_GRENADE2_THROW,
29	PLAYERANIMEVENT_VOICE_COMMAND_GESTURE,
30	PLAYERANIMEVENT_DOUBLEJUMP_CROUCH,
31	PLAYERANIMEVENT_STUN_BEGIN,
32	PLAYERANIMEVENT_STUN_MIDDLE,
33	PLAYERANIMEVENT_STUN_END,
34	PLAYERANIMEVENT_PASSTIME_THROW_BEGIN,
35	PLAYERANIMEVENT_PASSTIME_THROW_MIDDLE,
36	PLAYERANIMEVENT_PASSTIME_THROW_END,
37	PLAYERANIMEVENT_PASSTIME_THROW_CANCEL,

38	PLAYERANIMEVENT_ATTACK_PRIMARY_SUPER,

39	PLAYERANIMEVENT_COUNT
};
*/
public void Try_Backstab_Anim_Again(int attacker)
{
	if(Animation_Retry[attacker] > 0)
	{
		RequestFrame(Try_Backstab_Anim_Again, attacker);
	}
	Animation_Retry[attacker] -= 1;
	TE_Start("PlayerAnimEvent");
	TE_WriteEnt("m_hPlayer", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
					
}
public void NPC_CheckDead(int entity)
{
//	if(IsValidEntity(entity))
	{
		if(!b_NpcHasDied[entity])
		{
			CClotBody npc = view_as<CClotBody>(entity);
			npc.RemovePather(entity);
			b_NpcHasDied[entity] = true;
			
#if defined ZR
			float GameTime = GetGameTime();
			
			if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				Zombies_Currently_Still_Ongoing -= 1;
			}
			if(GlobalAntiSameFrameCheck_NPC_SpawnNext == GameTime)
			{
				return;
			}
				
			GlobalAntiSameFrameCheck_NPC_SpawnNext = GameTime;
			
			RequestFrame(NPC_SpawnNextRequestFrame, false);
			//dont call if its multiple at once, can cause lag
			//make sure that if they despawned instead of dying, that their shit still gets cleaned just in case.
#endif
			
		}
	}
}

void NPC_DeadEffects(int entity)
{
	if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
	{
#if defined ZR		
		float GameTime = GetGameTime();

		if(GlobalAntiSameFrameCheck_NPC_SpawnNext != GameTime)
		{
			RequestFrame(NPC_SpawnNextRequestFrame, false);
		}
		GlobalAntiSameFrameCheck_NPC_SpawnNext = GameTime;
		Zombies_Currently_Still_Ongoing -= 1;
		DropPowerupChance(entity);
		Gift_DropChance(entity);
#endif
		
		int WeaponLastHit = EntRefToEntIndex(LastHitWeaponRef[entity]);
		int client = EntRefToEntIndex(LastHitRef[entity]);
		if(client > 0 && client <= MaxClients)
		{
			
#if defined ZR
			GiveXP(client, 1);
			GiveNamedItem(client, NPC_Names[i_NpcInternalId[entity]]);
			Saga_DeadEffects(entity, client, WeaponLastHit);
#endif
			
#if defined RPG
			Quests_AddKill(client, NPC_Names[i_NpcInternalId[entity]]);
			Spawns_NPCDeath(entity, client, WeaponLastHit);
#endif
			
			Attributes_OnKill(client, WeaponLastHit);
		}
	}
}

#if defined ZR
void GiveNamedItem(int client, const char[] name)
{
	if(name[0] && GetFeatureStatus(FeatureType_Native, "TextStore_GetItems") == FeatureStatus_Available)
	{
		int length = TextStore_GetItems();
		for(int i; i<length; i++)
		{
			static char buffer[64];
			TextStore_GetItemName(i, buffer, sizeof(buffer));
			if(StrEqual(buffer, name, false))
			{
				int amount;
				TextStore_GetInv(client, i, amount);
				TextStore_SetInv(client, i, amount + 1);
				TextStore_Cash(client, 1);
				break;
			}
		}
	}
}
#endif

stock void CleanAllAppliedEffects_BombImplanter(int entity, bool do_boom = false)
{
	for (int client = 1; client <= MaxClients; client++)
	{
#if defined ZR
		float flPos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flPos);
		flPos[2] += 40.0;
		if(do_boom)
		{
			//Its 0 for no reason, i only ever set it to 0 here or in the m2 terroiser one
			if(i_HowManyBombsOnThisEntity[entity][client] > 0)
			{
				if(IsValidClient(client))
				{
					float damage = f_BombEntityWeaponDamageApplied[entity][client] * i_HowManyBombsOnThisEntity[entity][client];
					i_HowManyBombsOnThisEntity[entity][client] = 0;
					f_BombEntityWeaponDamageApplied[entity][client] = 0.0;
					Cause_Terroriser_Explosion(client, entity, damage, flPos);
				}
			}
		}
#endif
		//This is the only time it happens ever
		i_HowManyBombsOnThisEntity[entity][client] = 0;
		f_BombEntityWeaponDamageApplied[entity][client] = 0.0;
	}
}

void CleanAllNpcArray()
{
	Zero(played_headshotsound_already);
	Zero(f_CooldownForHurtHud);
	Zero(f_damageAddedTogetherGametime);
	Zero(f_HudCooldownAntiSpam);
	Zero(f_HudCooldownAntiSpamRaid);
}

#if defined ZR
void Spawner_AddToArray(int entity, bool base_boss = false) //cant use ent ref here...
{
	SpawnerData Spawner;
	int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
	if(index == -1)
	{
		if(base_boss)
		{
			Spawner.IsBaseBoss = true;
		}
		Spawner.indexnumber = entity;
		GetEntPropString(entity, Prop_Data, "m_iName", Spawner.Name, sizeof(Spawner.Name));
		SpawnerList.PushArray(Spawner);
	}
}

void Spawner_RemoveFromArray(int entity)
{
	int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
	if(index != -1)
		SpawnerList.Erase(index);
}
#endif

stock float NPC_OnTakeDamage_Equipped_Weapon_Logic(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
#if defined ZR
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_FUSION:
		{
			return Npc_OnTakeDamage_Fusion(victim, damage, weapon);
		}
		case WEAPON_BOUNCING:
		{
			return SniperMonkey_BouncingBullets(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_MAIMMOAB:
		{
			return SniperMonkey_MaimMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_CRIPPLEMOAB:
		{
			return SniperMonkey_CrippleMoab(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_IRENE:
		{
			Npc_OnTakeDamage_Iberia(attacker, damagetype);
		}
		case 7://WEAPON_PHLOG:
		{
			Npc_OnTakeDamage_Phlog(attacker);
		}
		case WEAPON_NEARL: //pap fusion
		{
			return Npc_OnTakeDamage_PaP_Fusion(attacker, victim, damage, weapon);
		}
		case WEAPON_LAPPLAND: //pap ark alt
		{
			return Npc_OnTakeDamage_LappLand(damage, attacker, damagetype, inflictor, victim);
		}
		case WEAPON_SPECTER:
		{
			Specter_OnTakeDamage(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
		}
		case WEAPON_YAMATO:
		{
			Npc_OnTakeDamage_Yamato(attacker, damagetype);
		}
		case WEAPON_BEAM_PAP:
		{
			Npc_OnTakeDamage_BeamWand_Pap(attacker, damagetype);
		}
		case WEAPON_GLADIIA:
		{
			Gladiia_OnTakeDamageEnemy(victim, attacker, damage);
		}
		case WEAPON_BLEMISHINE:
		{
			NPC_OnTakeDamage_Blemishine(attacker, victim, damage,weapon);
		}
		case WEAPON_FANTASY_BLADE:
		{
			Npc_OnTakeDamage_Fantasy_Blade(attacker, damagetype);
		}
		case WEAPON_BOOMSTICK:
		{
			if(b_thisNpcIsARaid[victim])
			{
				damage *= 2.0; //due to how dangerous it is to get closer.
			}
		}
	}
#endif

#if defined RPG
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_STUNSTICK:
		{
			Weapon_TakeDamage_StunStick(victim, damagetype);
		}
		case WEAPON_SILENCESTICK:
		{
			Weapon_TakeDamage_SilenceStick(victim, attacker, damagetype);
		}
	}
#endif

	return damage;
}
stock float NPC_OnTakeDamage_Equipped_Weapon_Logic_PostCalc(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
#if defined ZR
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_SAGA:
		{
			Saga_OnTakeDamage(victim, attacker, damage, weapon);
		}
	}
#endif
	return damage;
}
/*
public void OnNpcHurt(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("entindex");

	PrintToChatAll("%i",entity);
	PrintToChatAll("%i",event.GetInt("attacker_player"));
}*/


void OnKillUniqueWeapon(int attacker, int weapon)
{
	if(!IsValidEntity(weapon))
		return;

	if(!IsValidClient(attacker))
		return;
		
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MLYNAR:
		{
			MlynarReduceDamageOnKill(attacker);
		}
	}
}
void OnPostAttackUniqueWeapon(int attacker, int victim, int weapon, int damage_custom_zr)
{
	if(!IsValidEntity(weapon))
		return;

	if(!IsValidClient(attacker))
		return;

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_MLYNAR:
		{
			if(b_thisNpcIsARaid[victim] && (!(damage_custom_zr & ZR_DAMAGE_REFLECT_LOGIC))) //do not reduce damage if the damage type was a reflect.
				MlynarTakeDamagePostRaid(attacker);
		}
	}
}