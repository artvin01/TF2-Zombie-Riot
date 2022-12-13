#pragma semicolon 1
#pragma newdecls required

#define SHALLOW_WATER_POS_LIMIT 30.0

enum struct PlaceEnum
{
	float Pos[3];
	int Luck;
	int Pop;
	bool City;
	bool Nature;
	bool Ocean;

	char North[32];
	char West[32];
	char East[32];
	char South[32];
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetVector("pos", this.Pos);
		this.Luck = kv.GetNum("luck");
		this.Pop = kv.GetNum("pop");

		this.City = view_as<bool>(kv.GetNum("city"));
		this.Nature = view_as<bool>(kv.GetNum("nature"));
		this.Ocean = view_as<bool>(kv.GetNum("ocean"));

		kv.GetString("north", this.North, 32);
		kv.GetString("west", this.West, 32);
		kv.GetString("east", this.East, 32);
		kv.GetString("south", this.South, 32);
	}
}

enum struct FishEnum
{
	int Tier;
	int Type;
	int Pref;
	float Rate;
	float Breed;
	float Move;
	int Color[4];
	
	void SetupEnum(KeyValues kv)
	{
		this.Tier = kv.GetNum("tier");
		this.Type = kv.GetNum("type");
		this.Pref = kv.GetNum("pref");
		this.Rate = kv.GetFloat("rate");
		this.Breed = kv.GetFloat("breed");
		this.Move = kv.GetFloat("move");
		kv.GetColor4("color", this.Color);
	}
}

enum struct PoolEnum
{
	int Client;
	int Color[4];
	float Pos[3];
	char Name[48];
	char Place[32];
	float ExpireIn;
}

static int DrawNum;
static StringMap PlaceList;
static StringMap FishList;
static KeyValues Population;
static ArrayList PoolList;
static float f_ClientWasFishingDelayCheck[MAXTF2PLAYERS];
static float f_ClientWasPreviouslyFishing[MAXTF2PLAYERS];
static int FishingTier[MAXTF2PLAYERS];
static char CurrentFishing[MAXTF2PLAYERS][32];

void Fishing_PluginStart()
{
	PoolList = new ArrayList(sizeof(PoolEnum));
	CreateTimer(0.1, Fishing_Drawing, _, TIMER_REPEAT);
	CreateTimer(10.0, Fishing_Timer, _, TIMER_REPEAT);
}

void Fishing_ConfigSetup(KeyValues map)
{
	KeyValues kv = map;
	if(kv)
	{
		kv.Rewind();
		if(!kv.JumpToKey("Fishing"))
			kv = null;
	}
	
	char buffer[PLATFORM_MAX_PATH];
	if(!kv)
	{
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "fishing");
		kv = new KeyValues("Fishing");
		kv.ImportFromFile(buffer);
	}
	
	delete PlaceList;
	PlaceList = new StringMap();

	PlaceEnum place;

	if(kv.JumpToKey("Positions"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				place.SetupEnum(kv);
				PlaceList.SetArray(buffer, place, sizeof(place));
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
		kv.GoBack();
	}
	
	delete FishList;
	FishList = new StringMap();

	FishEnum fish;

	if(kv.JumpToKey("Fishes"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				fish.SetupEnum(kv);
				FishList.SetArray(buffer, fish, sizeof(fish));
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
		kv.GoBack();
	}

	if(kv != map)
		delete kv;
	
	delete Population;

	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "fishing_savedata");
	Population = new KeyValues("Fishing");
	if(!Population.ImportFromFile(buffer))
	{
		StringMapSnapshot snapPlace = PlaceList.Snapshot();
		StringMapSnapshot snapFish = FishList.Snapshot();
		int lengthPlace = snapPlace.Length;
		int lengthFish = snapFish.Length;

		for(int i; i < lengthPlace && i < lengthFish; i++)
		{
			snapPlace.GetKey(i, buffer, sizeof(buffer));
			if(Population.JumpToKey(buffer, true))
			{
				snapFish.GetKey(i, buffer, sizeof(buffer));
				FishList.GetArray(buffer, fish, sizeof(fish));
				Population.SetNum(buffer, RoundToCeil(fish.Rate * fish.Breed));
				Population.GoBack();
			}
		}

		delete snapPlace;
		delete snapFish;
	}
}

public Action Fishing_Timer(Handle timer)
{
	if(Population)
	{
		static char buffer[PLATFORM_MAX_PATH];

		static int AutoSave;
		if(++AutoSave > 99)
		{
			BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "fishing_savedata");
			Population.ExportToFile(buffer);
			AutoSave = 40;
		}
		else
		{
			static PlaceEnum place;
			static FishEnum fish;

			StringMapSnapshot snapPlace = PlaceList.Snapshot();
			StringMapSnapshot snapFish = FishList.Snapshot();
			int lengthPlace = snapPlace.Length;
			int lengthFish = snapFish.Length;

			Population.Rewind();
			for(int i; i < lengthPlace; i++)
			{
				snapPlace.GetKey(i, buffer, sizeof(buffer));
				PlaceList.GetArray(buffer, place, sizeof(place));
				if(Population.JumpToKey(buffer, true))
				{
					//bool checkPop;
					switch(GetURandomInt() % 5)
					{
						case 0:
						{
							if(place.Ocean)
							{
								snapFish.GetKey(GetURandomInt() % lengthFish, buffer, sizeof(buffer));
								FishList.GetArray(buffer, fish, sizeof(fish));
								if(fish.Type == 0 && fish.Rate > 0.5)
								{
									int amount = RoundFloat(fish.Rate * GetURandomFloat());
									if(amount)
									{
										//checkPop = true;
										Population.SetNum(buffer, Population.GetNum(buffer) + amount);
								//		PrintToChatAll("[FISH] Gained %d %s via ocean", amount, buffer);
									}
								}
							}
						}
						case 1:
						{
							if(place.Nature)
							{
								snapFish.GetKey(GetURandomInt() % lengthFish, buffer, sizeof(buffer));
								FishList.GetArray(buffer, fish, sizeof(fish));
								if(fish.Type == 1 && fish.Rate > 0.5)
								{
									int amount = RoundFloat(fish.Rate * GetURandomFloat());
									if(amount)
									{
										//checkPop = true;
										Population.SetNum(buffer, Population.GetNum(buffer) + amount);
								//		PrintToChatAll("[FISH] Gained %d %s via nature", amount, buffer);
									}
								}
							}
						}
						case 2:
						{
							if(place.City)
							{
								snapFish.GetKey(GetURandomInt() % lengthFish, buffer, sizeof(buffer));
								FishList.GetArray(buffer, fish, sizeof(fish));
								if(fish.Type == 2 && fish.Rate > 0.5)
								{
									int amount = RoundFloat(fish.Rate * GetURandomFloat());
									if(amount)
									{
										//checkPop = true;
										Population.SetNum(buffer, Population.GetNum(buffer) + amount);
								//		PrintToChatAll("[FISH] Gained %d %s via city", amount, buffer);
									}
								}
							}
						}
						case 3:
						{
							if(place.North[0] || place.South[0] || place.West[0] || place.East[0])
							{
								snapFish.GetKey(GetURandomInt() % lengthFish, buffer, sizeof(buffer));
								int current = Population.GetNum(buffer);
								if(current > 0)
								{
									FishList.GetArray(buffer, fish, sizeof(fish));
									if(fish.Move > 0.5)
									{
										int amount = RoundFloat(fish.Move * GetURandomFloat());
										if(amount <= current)
										{
											for(;;)
											{
												switch(fish.Pref)
												{
													case 1:
													{
														if(place.North[0])
															break;
														
														fish.Pref = 2;
													}
													case 2:
													{
														if(place.West[0])
															break;
														
														fish.Pref = 4;
													}
													case 3:
													{
														if(place.East[0])
															break;
														
														fish.Pref = 1;
													}
													case 4:
													{
														if(place.South[0])
															break;
														
														fish.Pref = 3;
													}
													default:
													{
														fish.Pref = (GetURandomInt() % 4) + 1;
														break;
													}
												}
											}

											Population.SetNum(buffer, current - amount);
											Population.GoBack();

											switch(fish.Pref)
											{
												case 1:
												{
													Population.JumpToKey(place.North);
													PlaceList.GetArray(place.North, place, sizeof(place));
												}
												case 2:
												{
													Population.JumpToKey(place.West);
													PlaceList.GetArray(place.West, place, sizeof(place));
												}
												case 3:
												{
													Population.JumpToKey(place.East);
													PlaceList.GetArray(place.East, place, sizeof(place));
												}
												default:
												{
													Population.JumpToKey(place.South);
													PlaceList.GetArray(place.South, place, sizeof(place));
												}
											}
											
											Population.SetNum(buffer, Population.GetNum(buffer) + amount);
											//checkPop = true;
										}
									}
								}
							}
						}
						case 4:
						{
							snapFish.GetKey(GetURandomInt() % lengthFish, buffer, sizeof(buffer));
							int current = Population.GetNum(buffer);
							if(current > 0)
							{
								FishList.GetArray(buffer, fish, sizeof(fish));
								if(fish.Breed > 0.5)
								{
									int amount = RoundFloat(fish.Breed * GetURandomFloat());
									if(amount)
									{
										Population.SetNum(buffer, Population.GetNum(buffer) + amount);
										//checkPop = true;
									}
								}
							}
						}
					}

					/*if(checkPop && Population.GotoFirstSubKey(false))
					{
						int total;
						do
						{
							total += Population.GetNum(NULL_STRING);
						}
						while(Population.GotoNextKey(false));

						if(total > place.Pop)
						{
							Population.GoBack();
							if(Population.GotoFirstSubKey(false))
							{
								if(Population.DeleteThis() != -1)
									Population.GoBack();
							}
						}

						Population.GoBack();
					}*/

					Population.GoBack();
				}
			}

			delete snapPlace;
			delete snapFish;
		}
	}
	return Plugin_Continue;
}

void Fishing_ClientDisconnect(int client)
{
	f_ClientWasFishingDelayCheck[client] = 0.0;
	f_ClientWasPreviouslyFishing[client] = 0.0;
}

static void GetNearestPond(const float pos[3], char[] found, int leng)
{
	float distance = FAR_FUTURE;

	StringMapSnapshot snap = PlaceList.Snapshot();

	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i) + 1;
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		static PlaceEnum place;
		PlaceList.GetArray(name, place, sizeof(place));

		float dist = GetVectorDistance(place.Pos, pos, true);
		if(dist < distance)
		{
			strcopy(found, leng, name);
			distance = dist;
		}
	}

	delete snap;
}

void Fishing_PlayerRunCmd(int client)
{
	float gameTime = GetGameTime();
	if(f_ClientWasFishingDelayCheck[client] < gameTime)
	{
		f_ClientWasFishingDelayCheck[client] = gameTime + 1.0;

		int AllowFishing = 0;
		if(GetEntProp(client, Prop_Send, "m_nWaterLevel") > 0)
		{
			AllowFishing = 1; //Allow fishing and reset the float so they can keep fishing
		}
		else if(f_ClientWasPreviouslyFishing[client] > gameTime)
		{
			AllowFishing = 2; //Allow fishing but dont reset the float
		}

		Crafting_AllowedFishing(client, AllowFishing == 1);

		if(AllowFishing > 0)
		{
			float f_pos[3];
			GetClientEyePosition(client,f_pos);

			if(AllowFishing == 1)
			{
				if(f_ClientWasPreviouslyFishing[client] < gameTime)
					GetNearestPond(f_pos, CurrentFishing[client], sizeof(CurrentFishing[]));
				
				f_ClientWasPreviouslyFishing[client] = gameTime + 5.0;
			}

			static PlaceEnum place;
			PlaceList.GetArray(CurrentFishing[client], place, sizeof(place));

			Population.Rewind();
			if(!Population.JumpToKey(CurrentFishing[client]) || !Population.GotoFirstSubKey(false))
				return;
			
			int total;
			do
			{
				total += Population.GetNum(NULL_STRING);
			}
			while(Population.GotoNextKey(false));
			
			float spawnRate = 4.9 - (float(total) * 3.9 / float(place.Pop));
			if(spawnRate < 0.2)
				spawnRate = 0.2;
			
			f_ClientWasFishingDelayCheck[client] = gameTime + spawnRate;

			float f_ang[3];

			f_pos[2] += 150.0;

			float f_resulthit[3];
			
			f_ang[0] = 5.0 + GetRandomFloat(20.0, 50.0);

			f_ang[1] = GetRandomFloat(-180.0,180.0);

			Handle trace; 
			trace = TR_TraceRayFilterEx(f_pos, f_ang, ( MASK_WATER | MASK_SHOT_HULL ), RayType_Infinite, HitOnlyWorld, client);
			//Do we hit water?
			TR_GetEndPosition(f_resulthit, trace);

			
		//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
		//	TE_SetupBeamPoints(f_pos, f_resulthit, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
		//	TE_SendToAll();
			
			delete trace;

			f_resulthit[2] -= 0.1;
			
			float f_WaterHitPos[3];
			float f_GroundHitPos[3];
			float f_MiddlePos[3];

			f_WaterHitPos = f_resulthit;

			if(TR_GetPointContents(f_resulthit) & CONTENTS_WATER) //We have hit water, hit groundto get the middle.
			{
				Handle trace_water; 
				trace_water = TR_TraceRayFilterEx(f_pos, f_ang, ( MASK_SHOT_HULL ), RayType_Infinite, HitOnlyWorld, client);
				
				TR_GetEndPosition(f_GroundHitPos, trace_water);
				delete trace_water;
				f_MiddlePos[0] = f_GroundHitPos[0] + (f_WaterHitPos[0] - f_GroundHitPos[0]) / 2;
				f_MiddlePos[1] = f_GroundHitPos[1] + (f_WaterHitPos[1] - f_GroundHitPos[1]) / 2;
				f_MiddlePos[2] = f_GroundHitPos[2] + (f_WaterHitPos[2] - f_GroundHitPos[2]) / 2;

				if((f_GroundHitPos[2] - f_WaterHitPos[2] < -SHALLOW_WATER_POS_LIMIT) || (f_GroundHitPos[2] - f_WaterHitPos[2] > SHALLOW_WATER_POS_LIMIT))
				{
					f_MiddlePos[2] += GetRandomFloat(-10.0, 10.0);

					Handle trace_hull; 
					trace_hull = TR_TraceHullFilterEx(f_MiddlePos, f_MiddlePos, { -10.0, -10.0, -10.0 }, { 10.0, 10.0, 10.0 }, ( MASK_SHOT_HULL ), HitOnlyWorld, client);
					int entity = TR_GetEntityIndex(trace_hull);
					delete trace_hull;
					if(entity == -1)
					{
						CreateFish(client, f_MiddlePos);
						//FishCreatedOrIsValid(client, f_MiddlePos);
					}
				}
			}
		}
	}
}

/*
void FishCreatedOrIsValid(int client, float f_fishpos[3])
{
	static float m_vecMaxs[3];
	static float m_vecMins[3];
	m_vecMaxs = view_as<float>( { 5.0, 5.0, 5.0 } );
	m_vecMins = view_as<float>( { -5.0, -5.0, -5.0 } );	
	TE_DrawBox(client, f_fishpos, m_vecMins, m_vecMaxs, 2.0, view_as<int>({0, 255, 0, 255}));
}
*/

static void CreateFish(int client, float pos[3])
{
	Population.Rewind();
	if(Population.JumpToKey(CurrentFishing[client]))
	{
		StringMapSnapshot snap = FishList.Snapshot();

		int length = snap.Length;
		int start = GetURandomInt() % length;
		for(int i = start + 1; i != start; i++)
		{
			if(i >= length)
			{
				i = -1;
				continue;
			}

			static PoolEnum pool;
			snap.GetKey(i, pool.Name, sizeof(pool.Name));

			if(Population.GetNum(pool.Name) > 0)
			{
				static FishEnum fish;
				FishList.GetArray(pool.Name, fish, sizeof(fish));
				if(FishingTier[client] >= fish.Tier)
				{
					pool.Client = client;
					pool.Pos = pos;
					pool.Color = fish.Color;
					pool.ExpireIn = GetGameTime() + 15.0;
					strcopy(pool.Place, sizeof(pool.Place), CurrentFishing[client]);
					PoolList.PushArray(pool);
				//	PrintToChatAll("Spawned %N's %s", pool.Client, pool.Name);
					delete snap;
					return;
				}
			}
		}

		delete snap;
	}

//	PrintToChat(client, "Lee Fishy Gone :(");
}

public Action Fishing_Drawing(Handle timer)
{
	int length = PoolList.Length;
	if(length)
	{
		if(++DrawNum >= length)
			DrawNum = 0;
		
		static PoolEnum pool;
		PoolList.GetArray(DrawNum, pool);
		if(pool.ExpireIn > GetGameTime() && IsClientInGame(pool.Client))
		{
			static float m_vecMaxs[3];
			static float m_vecMins[3];
			m_vecMaxs = view_as<float>( { 5.0, 5.0, 5.0 } );
			m_vecMins = view_as<float>( { -5.0, -5.0, -5.0 } );	
			
			TE_DrawBox(pool.Client, pool.Pos, m_vecMins, m_vecMaxs, float(length + 1) * 0.105, pool.Color);
		}
		else
		{
			PoolList.Erase(DrawNum--);
		}
	}
	return Plugin_Continue;
}

public void Fishing_RodM1(int client, int weapon, const char[] classname, bool &result)
{
	Ability_Apply_Cooldown(client, 1, Attributes_FindOnWeapon(client, weapon, 6, true, 1.0));
	FishingTier[client] = RoundToNearest(Attributes_FindOnWeapon(client, weapon, 2019));
	
	DataPack pack;
	CreateDataTimer(0.2, Fishing_RodM1Delay, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

public Action Fishing_RodM1Delay(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(client) && IsValidEntity(weapon))
	{
		Handle tr;
		float pos[3];
		DoSwingTrace_Custom(tr, client, pos);
		TR_GetEndPosition(pos, tr);
		delete tr;
		
		int choosen = -1;
		//float gameTime = GetGameTime();
		float distance = 2500.0;
		static PoolEnum pool;
		int length = PoolList.Length;
		for(int i; i < length; i++)
		{
			PoolList.GetArray(i, pool);
			if(pool.Client == client/* && pool.ExpireIn > gameTime*/)
			{
				float dist = GetVectorDistance(pool.Pos, pos, true);
				if(dist < distance)
				{
					choosen = i;
					distance = dist;
				}
			}
		}
		
		if(choosen != -1)
		{
			PoolList.GetArray(choosen, pool);
			PoolList.Erase(choosen);
			
			GetClientEyePosition(client, pos);
			TextStore_DropNamedItem(pool.Name, pos, 1);

			Population.Rewind();
			if(Population.JumpToKey(pool.Place))
			{
				int amount = Population.GetNum(pool.Name);
				if(amount)
					Population.SetNum(pool.Name, amount - 1);
			}
		}
	}
	return Plugin_Handled;
}