#pragma semicolon 1
#pragma newdecls required

#define GORE_ABDOMEN	  (1 << 0)
#define GORE_FOREARMLEFT  (1 << 1)
#define GORE_HANDRIGHT	(1 << 2)
#define GORE_FOREARMRIGHT (1 << 3)
#define GORE_HEAD		 (1 << 4)
#define GORE_HEADLEFT	 (1 << 5)
#define GORE_HEADRIGHT	(1 << 6)
#define GORE_UPARMLEFT	(1 << 7)
#define GORE_UPARMRIGHT   (1 << 8)
#define GORE_HANDLEFT	 (1 << 9)

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
}

//todo: code a way to include 2 or more groups of players splitting up, so the enemies dont spawn in the middle of nowhere
//Easy temp solution: Map should handle it. via triggers, and such, and dont make huge maps with a billion corridors.



//ArrayList NPCList; Make this global, i need it globally.
static ArrayList SpawnerList;
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
void NPC_RoundEnd()
{
	delete SpawnerList;
	SpawnerList = new ArrayList(sizeof(SpawnerData));
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
		strcopy(classname, 64, "base_boss");
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

	for(int Repeats=1; Repeats<=(MapSpawnersActive.IntValue); Repeats++)
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
					if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetEntProp(entity, Prop_Data, "m_iTeamNum") != 2)
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
	if(f_DelaySpawnsForVariousReasons > GetGameTime())
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
	
	if(GlobalCheckDelayAntiLagPlayerScale < GetGameTime())
	{
		AllowSpecialSpawns = false;
		GlobalCheckDelayAntiLagPlayerScale = GetGameTime() + 3.0;//only check every 5 seconds.
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
						if(Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0 && !IsValidEntity(npcstats.m_iTeamGlow))
							SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
						else
							SetEntProp(entity, Prop_Send, "m_bGlowEnabled", false);
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
	float gameTime = GetGameTime();
	ArrayList list = new ArrayList();
	int Active_Spawners = 0;
	int entity_Spawner = -1;
	for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++)
	{
		entity_Spawner = i_ObjectsSpawners[entitycount];
		if(IsValidEntity(entity_Spawner) && entity_Spawner != 0)
		{
			int index = SpawnerList.FindValue(entity_Spawner, SpawnerData::indexnumber);
			if(index != -1)
			{
				SpawnerData Spawner;
				SpawnerList.GetArray(index, Spawner);
				if(!GetEntProp(entity_Spawner, Prop_Data, "m_bDisabled") && GetEntProp(entity_Spawner, Prop_Data, "m_iTeamNum") != 2 && Spawner.b_SpawnIsCloseEnough)
				{
					Active_Spawners += 1;
					if(Spawner.f_SpawnerCooldown < gameTime)
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
								
								/*
									Good images:
									
									"hud_menu_heavy_red" Fat Streched heavy

								*/
								/*
									TODO:
									Use Custom texts and maybe icons for each boss.
								
									(Panzer)

									You can discern faint metalic screams not like the others...
									
									Distant low rumbles fill the air space...
									
									Die SS Division hat einer ihrer Infizierten soldaten Gesendet...
									
									(Sawrunner)
									
									Faint rattling can be heard, and its approaching at a fast pace...
									
									Something rapidly rams through hordes in your direction...
									
									Common means might not stop this agile enemy...
									
									(Tank)
									
									You have alerted the horde...
									
									Destruction echoes through a nearby space...
									
									A massive foe has entered this field...
									
									(Ghostface after getting found out before killing anyone)
									
									We are just getting started!
									
									Asshole!
									
									Lousy shot!
									
									(Whiteface and HER)
									
									Find HER
									
									I love watching You
									
									I'm afraid I can't let you do that
									
									{completely optional based on how masochistic you feel to code such useless detail}
									
									Ready for round 2?
									
									STAY WITH ME
									
									He won't let us leave
								
								*/
							}
				
							EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
							EmitSoundToClient(panzer_warning_client, boss.Sound, panzer_warning_client, SNDCHAN_AUTO, 90, _, 1.0);
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
				Spawner.f_SpawnerCooldown = gameTime + boss.Delay + 2.0;
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
				int index = SpawnerList.FindValue(entity_Spawner, SpawnerData::indexnumber);
				if(index != -1)
				{
					SpawnerData Spawner;
					SpawnerList.GetArray(index, Spawner);
					Spawner.f_SpawnerCooldown = gameTime+(2.0 - (Active_Spawners_Calculate / Spawner.f_ClosestSpawnerLessCooldown));
					SpawnerList.SetArray(index, Spawner);
				}
				entity_Spawner = list.Get(GetRandomInt(0, entity_Spawner-1));
				
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
						npcstats.m_bThisNpcIsABoss = true; //Set to true!
					}
					else
					{
						npcstats.m_bThisNpcIsABoss = false; //Set to true!
					}
					
					if(enemy.Credits && MultiGlobal)
						npcstats.m_iCreditsOnKill = RoundToCeil(float(enemy.Credits) / MultiGlobal);
					
					if(enemy.Is_Boss || enemy.Is_Outlined)
					{
						SetEntProp(entity_Spawner, Prop_Send, "m_bGlowEnabled", true);
					}
					else
					{
						SetEntProp(entity_Spawner, Prop_Send, "m_bGlowEnabled", false);
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
	return Plugin_Handled;
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
				SetEntProp(entity, Prop_Send, "m_bGlowEnabled", true);
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
		}
	}
	return Plugin_Handled;
}
#endif

static float BurnDamage[MAXPLAYERS];

void NPC_Ignite(int entity, int client, float duration, int weapon)
{
	IgniteFor[entity] += RoundToCeil(duration*2.0);
	if(IgniteFor[entity] > 20)
		IgniteFor[entity] = 20;
	
	if(!IgniteTimer[entity])
		IgniteTimer[entity] = CreateTimer(0.5, NPC_TimerIgnite, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	
	
	float value = 8.0;
	if(weapon > MaxClients && IsValidEntity(weapon))
	{
		value *= Attributes_FindOnWeapon(client, weapon, 2, true, 1.0);	  //For normal weapons
			
		value *= Attributes_FindOnWeapon(client, weapon, 410, true, 1.0); //For wand
					
		value *= Attributes_FindOnWeapon(client, weapon, 71, true, 1.0); //For wand
	}
			
	if(value > BurnDamage[client]) //Dont override if damage is lower.
	{
		IgniteId[entity] = GetClientUserId(client);
	
		IgniteRef[entity] = EntIndexToEntRef(weapon);
	}
}

public Action NPC_TimerIgnite(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity > MaxClients)
	{
		if(!b_NpcHasDied[entity])
		{
			int client = GetClientOfUserId(IgniteId[entity]);
			if(client && IsClientInGame(client))
			{
				IgniteFor[entity]--;
				
				float pos[3], ang[3];
				GetClientEyeAngles(client, ang);
				int weapon = EntRefToEntIndex(IgniteRef[entity]);
				float value = 8.0;
				if(weapon > MaxClients && IsValidEntity(weapon))
				{
					value *= Attributes_FindOnWeapon(client, weapon, 2, true, 1.0);	  //For normal weapons
					
					value *= Attributes_FindOnWeapon(client, weapon, 410, true, 1.0); //For wand
					
					value *= Attributes_FindOnWeapon(client, weapon, 71, true, 1.0); //For wand
				}
				else
				{
					weapon = -1;
				}
				
				pos = WorldSpaceCenter(entity);
				
				if(value < BurnDamage[client])
				{
					value = BurnDamage[client];
				}
				else
				{
					BurnDamage[client] = value;
				}
				
				SDKHooks_TakeDamage(entity, client, client, value, DMG_SLASH, weapon, ang, pos, false);
				//Setting burn dmg to slash cus i want it to work with melee!!!
				//Also yes this means burn and bleed are basically the same, excluding that burn doesnt stack.
				//In this case ill buff it so its 2x as good as bleed! or more in the future
				//Also now allows hp gain and other stuff for that reason. pretty cool.
				if(IgniteFor[entity] == 0)
				{
					IgniteTimer[entity] = null;
					IgniteFor[entity] = 0;
					BurnDamage[client] = 0.0;
					return Plugin_Stop;
				}
				return Plugin_Continue;
			}
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

			if(hitgroup == HITGROUP_HEAD || Blitzed_By_Riot)
			{
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
					damage *= 2.0;
				}
				else
				{
					i_HasBeenHeadShotted[victim] = true; //shouldnt count as an actual headshot!
				}

#if defined ZR
				if(i_CurrentEquippedPerk[attacker] == 5) //I guesswe can make it stack.
				{
					damage *= 1.35;
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
					if(f_ChargeTerroriserSniper[weapon] > 149.0)
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += 2;
					}
					else
					{
						i_HowManyBombsOnThisEntity[victim][attacker] += 1;
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
									EmitSoundToClient(client, "zombiesurvival/headshot1.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitSoundToClient(attacker, "zombiesurvival/headshot1.wav", _, _, 90, _, volume, pitch);
						}
						case 2:
						{
							for(int client=1; client<=MaxClients; client++)
							{
								if(IsClientInGame(client) && client != attacker)
								{
									EmitSoundToClient(client, "zombiesurvival/headshot2.wav", victim, _, 80, _, volume, pitch);
								}
							}
							EmitSoundToClient(attacker, "zombiesurvival/headshot2.wav", _, _, 90, _, volume, pitch);
						}
					}
				}
				return Plugin_Changed;
			}
			else
			{
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
	if(damagetype & DMG_DROWN)
	{
		damage *= 5.0;
		return Plugin_Changed;	
	}
	
	if(attacker < 1 ||/* attacker > MaxClients ||*/ victim == attacker)
		return Plugin_Continue;
		
	if(HasEntProp(attacker,Prop_Send,"m_iTeamNum"))
	{
		if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
		{
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	
	f_TimeUntillNormalHeal[victim] = GetGameTime() + 4.0;
	i_HasBeenBackstabbed[victim] = false;

	if(f_TraceAttackWasTriggeredSameFrame[victim] != GetGameTime())
	{
		i_HasBeenHeadShotted[victim] = false;
	}

	//Reset all things here.
	if(b_npcspawnprotection[victim]) //make them resistant on spawn or else itll just be spawncamping fest
	{
		damage *= 0.25;
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
	
	if(f_EmpowerStateOther[attacker] > GetGameTime()) //Allow stacking.
	{
		damage *= 1.1;
	}
	if(f_EmpowerStateSelf[attacker] > GetGameTime()) //Allow stacking.
	{
		damage *= 1.15;
	}

	if(f_HighTeslarDebuff[victim] > GetGameTime())
	{
		damage *= 1.25;
	}
	else if(f_LowTeslarDebuff[victim] > GetGameTime())
	{
		damage *= 1.15;
	}
	
	if(f_HighIceDebuff[victim] > GetGameTime())
	{
		damage *= 1.15;
	}
	else if(f_LowIceDebuff[victim] > GetGameTime())
	{
		damage *= 1.10;
	}
	else if(f_VeryLowIceDebuff[victim] > GetGameTime())
	{
		damage *= 1.05;
	}
	
	if(f_WidowsWineDebuff[victim] > GetGameTime())
	{
		damage *= 1.35;
	}
	
	if(Resistance_Overall_Low[victim] > GetGameTime())
	{
		damage *= 0.85;
	}
	
	if(Increaced_Overall_damage_Low[attacker] > GetGameTime())
	{
		damage *= 1.25;
	}
	
	if(f_CrippleDebuff[victim] > GetGameTime())
	{
		damage *= 1.4;
	}
	
	if(attacker <= MaxClients)
	{
#if defined RPG	

		//Random crit damage!
		//Yes, we allow those.
		if(GetRandomFloat(0.0, 1.0) < 0.01)
		{
			damage *= 3.0;
			DisplayCritAboveNpc(victim, attacker, true); //Display crit above head
		}

#endif

#if defined ZR
		if(dieingstate[attacker] > 0)
		{
			damage *= 0.25;
		}
#endif
		
		if(damagecustom>=TF_CUSTOM_SPELL_TELEPORT && damagecustom<=TF_CUSTOM_SPELL_BATS)
		{
			//nope, no fireball damage. or any mage damage.
			damage = 0.0;
			return Plugin_Handled;
		}
		
#if defined ZR
		if(EscapeMode)
		{
			if(IsValidEntity(weapon))
			{
				if(!i_IsWandWeapon[weapon] && !i_IsWrench[weapon]) //make sure its not a wand.
				{
					char melee_classname[64];
					GetEntityClassname(weapon, melee_classname, 64);
					
					if (TFWeaponSlot_Melee == TF2_GetClassnameSlot(melee_classname))
						damage *= 1.25;
				}
			}
		}
#endif
		
		//NPC STUFF FOR RECORD AND ON KILL
		LastHitId[victim] = GetClientUserId(attacker);
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
		char classname[32];
		if(IsValidEntity(inflictor) && inflictor>MaxClients)// && attacker<=MaxClients)
		{
			GetEntityClassname(inflictor, classname, sizeof(classname));
			if(StrEqual(classname, "obj_sentrygun"))
			{
				
#if defined ZR
				if(EscapeMode) //BUFF SENTRIES DUE TO NO PERKS IN ESCAPE!!!
				{
					damage *= 4.0;
				}
#endif
				
				if(Increaced_Sentry_damage_Low[inflictor] > GetGameTime())
				{
					damage *= 1.15;
				}
				else if(Increaced_Sentry_damage_High[inflictor] > GetGameTime())
				{
					damage *= 1.3;
				}
			}
			
#if defined ZR
			else if(StrEqual(classname, "base_boss") && b_IsAlliedNpc[inflictor]) //add a filter so it only does it for allied base_bosses
			{
				CClotBody npc = view_as<CClotBody>(inflictor);
				if(npc.m_bScalesWithWaves)
				{
					int Wave_Count = Waves_GetRound() + 1;
					if(!EscapeMode) //Buff in escapemode overall!
					{
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
					else
					{
						damage *= 1.5;
					}
				}
			}
#endif	// ZR
			
		}
		if(attacker <= MaxClients && IsValidEntity(weapon))
		{
			
#if defined ZR
			float modified_damage = NPC_OnTakeDamage_Equipped_Weapon_Logic(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition);
			
			damage = modified_damage;
			
			if(i_ArsenalBombImplanter[weapon] > 0)
			{
				if(f_ChargeTerroriserSniper[weapon] > 149.0)
				{
					i_HowManyBombsOnThisEntity[victim][attacker] += 2;
				}
				else
				{
					i_HowManyBombsOnThisEntity[victim][attacker] += 1;
				}
				Apply_Particle_Teroriser_Indicator(victim);
				damage = 0.0;
			}
#endif
			
			if(i_HighTeslarStaff[weapon] == 1)
			{
				f_HighTeslarDebuff[victim] = GetGameTime() + 5.0;
			}
			else if(i_LowTeslarStaff[weapon] == 1)
			{
				f_LowTeslarDebuff[victim] = GetGameTime() + 5.0;
			}
			
			/*
			for (int client = 1; client <= MaxClients; client++)
			{
				i_HowManyBombsOnThisEntity[victim][client] = 0; //to clean on death ofc.
			}
			*/
			GetEntityClassname(weapon, classname, sizeof(classname));
			if(!StrContains(classname, "tf_weapon_knife", false))
			{
				if(damagetype & DMG_CLUB) //Use dmg slash for any npc that shouldnt be scaled.
				{
					if(IsBehindAndFacingTarget(attacker, victim) || b_FaceStabber[attacker])
					{
						int viewmodel = GetEntPropEnt(attacker, Prop_Send, "m_hViewModel");
						int melee = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
						if(melee != 4 && melee != 1003 && viewmodel>MaxClients && IsValidEntity(viewmodel))
						{
							i_HasBeenBackstabbed[victim] = true;
							
							float attack_speed;
			
							attack_speed = Attributes_FindOnWeapon(attacker, weapon, 6, true, 1.0);
							attack_speed = Attributes_FindOnWeapon(attacker, weapon, 396, true, 1.0);
							
							EmitSoundToAll("weapons/knife_swing_crit.wav", attacker, _, _, _, 0.7);
							
							DataPack pack = new DataPack();
							RequestFrame(DoMeleeAnimationFrameLater, pack);
							pack.WriteCell(EntIndexToEntRef(viewmodel));
							pack.WriteCell(melee);

						//	damagetype |= DMG_CRIT; For some reason post ontakedamage doenst like crits. Shits wierd man.
							damage *= 5.25;
							
							if(b_FaceStabber[attacker])
							{
								damage *= 0.35; //cut damage in half and then some.
							}
							
							CClotBody npc = view_as<CClotBody>(victim);
							
							if(attacker == npc.m_iTarget && !b_FaceStabber[attacker])
							{
								damage *= 2.0; // EXTRA BONUS DAMAGE GIVEN BEACUSE OF THE AI BEING SMARTER AND AVOIDING HITS BETTER! But not for facestabbers.
							}
							
#if defined ZR
							if(i_CurrentEquippedPerk[attacker] == 5) //Deadshot!
							{
								damage *= 1.35;
							}
							
							if(EscapeMode)
								damage *= 1.35;
#endif
							
							/*
							Latest tf2 update broke this, too lazy to fix lol
							if(!(GetClientButtons(attacker) & IN_DUCK)) //This shit only works sometimes, i blame tf2 for this.
							{
								
								RequestFrame(Try_Backstab_Anim_Again, attacker);
								TE_Start("PlayerAnimEvent");
								Animation_Setting[attacker] = 1;
								Animation_Index[attacker] = 33;
								TE_WriteNum("m_iPlayerIndex", attacker);
								TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
								TE_WriteNum("m_nData", Animation_Index[attacker]);
								TE_SendToAll();
							}
							*/
							int heal_amount = 0;
							if(melee == 356)
							{
								heal_amount = 10;
								if(b_FaceStabber[attacker])
								{
									heal_amount = 1;
								}
								StartHealingTimer(attacker, 0.1, 1, heal_amount);
								SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+(1.5 * attack_speed));
								SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+(1.5 * attack_speed));
							}
							else if(melee == 225)
							{
								heal_amount = 25;
								if(b_FaceStabber[attacker])
								{
									heal_amount = 4;
								}
								StartHealingTimer(attacker, 0.1, 2, heal_amount);
								SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+(1.0 * attack_speed));
								SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+(1.0 * attack_speed));
							}
							else if(melee == 727)
							{
								heal_amount = 25;
								if(b_FaceStabber[attacker])
								{
									heal_amount = 3;
								}
								//THIS MELEE WILL HAVE SPECIAL PROPERTIES SO ITS RECONISED AS A SPY MELEE AT ALL TIMES!
								StartHealingTimer(attacker, 0.1, 3, heal_amount);
								SepcialBackstabLaughSpy(attacker);
								
								if(b_FaceStabber[attacker])
								{
									damage *= 0.75;
								}
								damage *= 0.75; //Nerf the dmg abit for the last knife as itsotheriwse ridicilous
							}
							else if(melee == 910)
							{
								damage *= 0.10;
							}
							else
							{
								SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+(1.5 * attack_speed));
								SetEntPropFloat(attacker, Prop_Send, "m_flNextAttack", GetGameTime()+(1.5 * attack_speed));	
							}
						}
					}
				}
			}
			
#if defined ZR
			else if(!StrContains(classname, "tf_weapon_compound_bow", false))
			{
				if(damagetype & DMG_CRIT)
				{		
					if(i_CurrentEquippedPerk[attacker] == 5) //Just give them 25% more damage if they do crits with the huntsman, includes buffbanner i guess
					{
						damage *= 1.35;
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
	switch (damagecustom) //Make sure taunts dont do any damage, cus op as fuck
	{
		case TF_CUSTOM_TAUNT_HADOUKEN, TF_CUSTOM_TAUNT_HIGH_NOON, TF_CUSTOM_TAUNT_GRAND_SLAM, TF_CUSTOM_TAUNT_FENCING,
		TF_CUSTOM_TAUNT_ARROW_STAB, TF_CUSTOM_TAUNT_GRENADE, TF_CUSTOM_TAUNT_BARBARIAN_SWING,
		TF_CUSTOM_TAUNT_UBERSLICE, TF_CUSTOM_TAUNT_ENGINEER_SMASH, TF_CUSTOM_TAUNT_ENGINEER_ARM, TF_CUSTOM_TAUNT_ARMAGEDDON:
		{
			damage = 0.0;
		}
		
	}	//Remove annoying instakill taunts
	
	return Plugin_Changed;
}

public void NPC_OnTakeDamage_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	i_HexCustomDamageTypes[victim] = 0; //Reset it back to 0.
	if(attacker < 1 || attacker > MaxClients)
		return;
		
	Calculate_And_Display_hp(attacker, victim, damage, false);
	/*
	if(GetEntProp(attacker, Prop_Send, "m_iTeamNum") == GetEntProp(victim, Prop_Send, "m_iTeamNum"))
	{
		return;
	}
	*/
}

stock void Calculate_And_Display_hp(int attacker, int victim, float damage, bool ignore, int overkill = 0)
{
	int Health = GetEntProp(victim, Prop_Data, "m_iHealth");
	int MaxHealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
	
#if defined ZR
	if(overkill <= 0)
	{
		Damage_dealt_in_total[attacker] += damage;
	}
	else
	{
		Damage_dealt_in_total[attacker] += overkill; //dont award for overkilling.
	}
#endif
	
	if(f_CooldownForHurtHud[attacker] < GetGameTime() || ignore)
	{
		if(!ignore)
		{
			f_CooldownForHurtHud[attacker] = GetGameTime() + 0.1;
		}
		
		int red = 255;
		int green = 255;
		int blue = 0;
		
		if(!b_npcspawnprotection[victim])
		{
			red = Health * 255  / MaxHealth;
			//	blue = GetEntProp(entity, Prop_Send, "m_iHealth") * 255  / Building_Max_Health[entity];
			green = Health * 255  / MaxHealth;
					
			red = 255 - red;
				
			if(Health <= 0)
			{
				red = 255;
				green = 0;
				blue = 0;
			}
		}
		else
		{
			red = 0;
			green = 0;
			blue = 255;
		}
		
		char Debuff_Adder[64];
		
		bool Debuff_added = false;
		
		if(f_HighTeslarDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "⌁⌁");
		}
		else if(f_LowTeslarDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "⌁");
		}
		
		if(BleedAmountCountStack[victim] > 0) //bleed
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❣%i", Debuff_Adder, BleedAmountCountStack[victim]);			
		}
		
		if(IgniteFor[victim] > 0) //burn
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s♨", Debuff_Adder);			
		}
		
		if(f_HighIceDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅❅❅", Debuff_Adder);
		}
		else if(f_LowIceDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅❅", Debuff_Adder);
		}
		else if (f_VeryLowIceDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s❅", Debuff_Adder);	
		}
		
		if(f_WidowsWineDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s४", Debuff_Adder);
		}
		
		if(f_CrippleDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s⯯", Debuff_Adder);
		}
		
		if(f_MaimDebuff[victim] > GetGameTime())
		{
			Debuff_added = true;
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s↓", Debuff_Adder);
		}
		
		
		if(Debuff_added)
		{
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s\n", Debuff_Adder);
		}
		
		CClotBody npc = view_as<CClotBody>(victim);
		
#if defined ZR
		if(npc.m_flMeleeArmor != 1.0 || Medival_Difficulty_Level != 0)
#else
		if(npc.m_flMeleeArmor != 1.0)
#endif
		
		{
			float percentage = npc.m_flMeleeArmor * 100.0;
			
#if defined ZR
			if(Medival_Difficulty_Level != 0.0)
			{
				percentage *= Medival_Difficulty_Level;
			}
#endif
			
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s [♈ %.0f%%]", Debuff_Adder, percentage);
		}
		
#if defined ZR
		if(npc.m_flRangedArmor != 1.0 || Medival_Difficulty_Level != 0)
#else
		if(npc.m_flRangedArmor != 1.0)
#endif
		
		{
			float percentage = npc.m_flRangedArmor * 100.0;
			
#if defined ZR
			if(Medival_Difficulty_Level != 0.0)
			{
				percentage *= Medival_Difficulty_Level;
			}
#endif
			
			FormatEx(Debuff_Adder, sizeof(Debuff_Adder), "%s [♐ %.0f%%]", Debuff_Adder, percentage);
		}
		
#if defined ZR
		if(EntRefToEntIndex(RaidBossActive) != victim)
		{
			SetGlobalTransTarget(attacker);
			SetHudTextParams(-1.0, 0.15, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
			ShowSyncHudText(attacker, SyncHud, "%t\n%d / %d\n%s", NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder);
		}
		else
		{
			float Timer_Show = RaidModeTime - GetGameTime();
		
			if(Timer_Show < 0.0)
				Timer_Show = 0.0;
				
			SetGlobalTransTarget(attacker);
			SetHudTextParams(-1.0, 0.05, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
			ShowSyncHudText(attacker, SyncHudRaid, "[%t | %t : %.1f%% | %t: %.1f]\n%s\n%d / %d \n%s","Raidboss", "Power", RaidModeScaling * 100, "TIME LEFT", Timer_Show, NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder);
		}
#endif
		
#if defined RPG
		SetGlobalTransTarget(attacker);

		char level[32];
		GetDisplayString(Level[victim], level, sizeof(level));
		
		SetHudTextParams(-1.0, 0.15, 1.0, red, green, blue, 255, 0, 0.01, 0.01);
		ShowSyncHudText(attacker, SyncHud, "%s\n%t\n%d / %d\n%s", level, NPC_Names[i_NpcInternalId[victim]], Health, MaxHealth, Debuff_Adder);
		
		char HealthString[512];
		Format(HealthString, sizeof(HealthString), "%i | %i", Health, MaxHealth);
		
		DispatchKeyValue(npc.m_iTextEntity3, "message", HealthString);
#endif
		
	}
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
	RequestFrame(Try_Backstab_Anim_Again2, attacker);
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
					
}
public void Try_Backstab_Anim_Again2(int attacker)
{
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
	if(Dont_Crouch[attacker] > 0)
		RequestFrame(Try_Backstab_Anim_Again3, attacker);
					
}
public void Try_Backstab_Anim_Again3(int attacker)
{
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", attacker);
	TE_WriteNum("m_iEvent", Animation_Setting[attacker]);
	TE_WriteNum("m_nData", Animation_Index[attacker]);
	TE_SendToAll();
					
}

public void NPC_CheckDead(int entity)
{
	if(IsValidEntity(entity))
	{
		if(!b_NpcHasDied[entity])
		{
			b_NpcHasDied[entity] = true;
			
#if defined ZR
			if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				Zombies_Currently_Still_Ongoing -= 1;
			}
			if(GlobalAntiSameFrameCheck_NPC_SpawnNext == GetGameTime())
			{
				return;
			}
				
			GlobalAntiSameFrameCheck_NPC_SpawnNext = GetGameTime();
			
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
		if(GlobalAntiSameFrameCheck_NPC_SpawnNext != GetGameTime())
		{
			RequestFrame(NPC_SpawnNextRequestFrame, false);
		}
		GlobalAntiSameFrameCheck_NPC_SpawnNext = GetGameTime();
		Zombies_Currently_Still_Ongoing -= 1;
		DropPowerupChance(entity);
		Gift_DropChance(entity);
#endif
		
		int WeaponLastHit = EntRefToEntIndex(LastHitWeaponRef[entity]);
		int client = GetClientOfUserId(LastHitId[entity]);
		if(client && IsClientInGame(client))
		{
			
#if defined ZR
			GiveXP(client, 1);
			GiveNamedItem(client, NPC_Names[i_NpcInternalId[entity]]);
#endif
			
#if defined RPG
			Quests_AddKill(client, NPC_Names[i_NpcInternalId[entity]]);
			Spawns_NPCDeath(entity, client);
#endif
			
			NPC_Killed_Show_Hud(client, entity, WeaponLastHit, NPC_Names[i_NpcInternalId[entity]], DamageBits[entity]);
			Attributes_OnKill(client, WeaponLastHit);
		}
	}
	
	RemoveNpcThingsAgain(entity);
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

void CleanAllAppliedEffects(int entity)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		i_HowManyBombsOnThisEntity[entity][client] = 0; //to clean on death ofc.
	}
}

void CleanAllNpcArray()
{
	Zero(played_headshotsound_already);
	Zero(f_CooldownForHurtHud);
}

#if defined ZR
void Spawner_AddToArray(int entity) //cant use ent ref here...
{
	SpawnerData Spawner;
	int index = SpawnerList.FindValue(entity, SpawnerData::indexnumber);
	if(index == -1)
	{
		Spawner.indexnumber = entity;
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
