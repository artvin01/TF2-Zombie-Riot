#pragma semicolon 1
#pragma newdecls required

#define MAX_FISH_TIER 7

static const char FishingLevels[MAX_FISH_TIER][] =
{
	"Leaf (0)",
	"Feather (1)",
	"Silk (2)",
	"Wire (3)",
	"IV Cable (4)",
	"Carving Tool (5)",
	"MV Cable (6)"
};

#define SHALLOW_WATER_POS_LIMIT 30.0

enum struct PlaceEnum
{
	float Pos[3];
	int Luck;
	ArrayList Pool[MAX_FISH_TIER];
}

enum struct FishEnum
{
	int Tier;
	int Type;
	int Color[4];
	
	void SetupEnum(KeyValues kv)
	{
		this.Tier = kv.GetNum("rarity");
		this.Type = kv.GetNum("type");
		kv.GetColor4("color", this.Color);
	}
}

enum struct PoolEnum
{
	int Client;
	int Tier;
	float Pos[3];
	char Name[48];
	char Place[32];
	float ExpireIn;
}

static int DrawNum;
static StringMap PlaceList;
static StringMap FishList;
static ArrayList PoolList;
static float f_ClientWasFishingDelayCheck[MAXPLAYERS];
static float f_ClientWasPreviouslyFishing[MAXPLAYERS];
static float FishingRate[MAXPLAYERS] = {1.0, ...};
static int FishingTier[MAXPLAYERS];
static int Desired_FishingTier[MAXPLAYERS];
static char CurrentFishing[MAXPLAYERS][32];

static int g_FishCaughtParticle;
static int g_FishCaughtText;

void Fishing_PluginStart()
{
	PoolList = new ArrayList(sizeof(PoolEnum));
	CreateTimer(0.1, Fishing_Drawing, _, TIMER_REPEAT);
}

void Fishing_OnMapStart()
{
	g_FishCaughtParticle = PrecacheParticleSystem("drg_3rd_impact");
	g_FishCaughtText = PrecacheParticleSystem("hit_text");
}

void Fishing_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(buffer);
	
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
	
	if(PlaceList)
	{
		PlaceEnum place;
		StringMapSnapshot snap = PlaceList.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, buffer, sizeof(buffer));
			PlaceList.GetArray(buffer, place, sizeof(place));
			for(int a; a < sizeof(place.Pool); a++)
			{
				delete place.Pool[a];
			}
		}

		delete snap;
		delete PlaceList;
	}

	PlaceList = new StringMap();

	if(kv.JumpToKey("Positions") && kv.GotoFirstSubKey())
	{
		do
		{
			PlaceEnum place;

			if(kv.GotoFirstSubKey())
			{
				do
				{
					kv.GetSectionName(buffer, sizeof(buffer));
					int tier = StringToInt(buffer);
					if(tier >= 0 && tier < sizeof(place.Pool))
					{
						delete place.Pool[tier];
						place.Pool[tier] = new ArrayList(ByteCountToCells(48));

						if(kv.GotoFirstSubKey(false))
						{
							do
							{
								kv.GetSectionName(buffer, sizeof(buffer));
								int amount = kv.GetNum(NULL_STRING, 1);
								for(int i; i < amount; i++)
								{
									place.Pool[tier].PushString(buffer);
								}
							}
							while(kv.GotoNextKey(false));

							kv.GoBack();
						}

						if(!place.Pool[tier].Length)
						{
							delete place.Pool[tier];
							continue;
						}
					}
				}
				while(kv.GotoNextKey());

				kv.GoBack();
			}

			kv.GetSectionName(buffer, sizeof(buffer));
			kv.GetVector("pos", place.Pos);
			place.Luck = kv.GetNum("luck");
			PlaceList.SetArray(buffer, place, sizeof(place));
		}
		while(kv.GotoNextKey());
	}

	delete kv;
}

void Fishing_ClientDisconnect(int client)
{
	Desired_FishingTier[client] = 1; //Reset the desired fishing tier to 0.
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

bool Fishing_Interact(int client, int weapon)
{
	bool rod = (weapon != -1 && EntityFuncAttack[weapon] == Fishing_RodM1);

	//We are in water. Fire a trace and see if we can see water.
	
	float f_pos[3];
	GetClientEyePosition(client,f_pos);
	float f_ang[3];
	GetClientEyeAngles(client, f_ang);
	float f_resulthit[3];
	Handle trace; 
	trace = TR_TraceRayFilterEx(f_pos, f_ang, ( MASK_WATER | MASK_SHOT_HULL ), RayType_Infinite, HitOnlyWorld, client);
	//Do we hit water?
	TR_GetEndPosition(f_resulthit, trace);
	f_resulthit[2] -= 0.1;
	delete trace;
	if(TR_GetPointContents(f_resulthit) & CONTENTS_WATER) //We have hit water, hit groundto get the middle.
	{
		if(!rod)
		{
			float dist = GetVectorDistance(f_pos, f_resulthit);
			if(dist >= 100.0)
			{
				return false;
			}
			if(!Store_SwitchToWeaponSlot(client, 4))
			{
				SPrintToChat(client, "You must equip a fishing rod!");
			}
		}
		return true;
	}
	else
	{
		if(rod)
		{
			Store_SwitchToWeaponSlot(client, 2);
		}
	}
	return false;
}

void Fishing_PlayerRunCmd(int client)
{
	float gameTime = GetGameTime();
	if(f_ClientWasFishingDelayCheck[client] < gameTime)
	{
		f_ClientWasFishingDelayCheck[client] = gameTime + (1.0 / FishingRate[client]);

		int AllowFishing = 0;
		if(GetEntProp(client, Prop_Send, "m_nWaterLevel") > 0)
		{
			AllowFishing = 1; //Allow fishing and reset the float so they can keep fishing
		}
		else if(f_ClientWasPreviouslyFishing[client] > gameTime)
		{
			AllowFishing = 2; //Allow fishing but dont reset the float
		}

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
			if(place.Pool[Desired_FishingTier[client]])
			{
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
						trace_hull = TR_TraceHullFilterEx(f_MiddlePos, f_MiddlePos, { -5.0, -5.0, -5.0 }, { 5.0, 5.0, 5.0 }, ( MASK_SHOT_HULL ), HitOnlyWorld, client);
						int entity = TR_GetEntityIndex(trace_hull);
						delete trace_hull;
						if(entity == -1)
						{
							CreateFish(client, f_MiddlePos, place);
							//FishCreatedOrIsValid(client, f_MiddlePos);
						}
						else
						{
							f_ClientWasFishingDelayCheck[client] = gameTime + (0.75 / FishingRate[client]); //Try again 2x as fast
						}
					}
					else
					{
						f_ClientWasFishingDelayCheck[client] = gameTime + (0.75 / FishingRate[client]); //Try again 2x as fast
					}
				}
				else
				{
					f_ClientWasFishingDelayCheck[client] = gameTime + (0.75 / FishingRate[client]); //Try again 2x as fast
				}
			}
			else
			{
				f_ClientWasFishingDelayCheck[client] = gameTime + 6.0;
				//SPrintToChat(client, "There seems to be no fish attracted to your fishing rod... try another one!");
			}
		}
		else
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon != -1 && EntityFuncAttack[weapon] == Fishing_RodM1)
			{
				Store_SwitchToWeaponSlot(client, 2);
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

static void CreateFish(int client, const float pos[3], const PlaceEnum place)
{
	static PoolEnum pool;
	place.Pool[Desired_FishingTier[client]].GetString(GetURandomInt() % place.Pool[Desired_FishingTier[client]].Length, pool.Name, sizeof(pool.Name));

	static FishEnum fish;
	FishList.GetArray(pool.Name, fish, sizeof(fish));
	
	pool.Client = client;
	pool.Pos = pos;
	pool.Tier = fish.Tier;
	pool.ExpireIn = GetGameTime() + 15.0;
	strcopy(pool.Place, sizeof(pool.Place), CurrentFishing[client]);
	PoolList.PushArray(pool);
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

			int color[4];
			color[0] = RenderColors_RPG[pool.Tier][0];
			color[1] = RenderColors_RPG[pool.Tier][1];
			color[2] = RenderColors_RPG[pool.Tier][2];
			color[3] = RenderColors_RPG[pool.Tier][3];

			TE_DrawBox(pool.Client, pool.Pos, m_vecMins, m_vecMaxs, float(length + 1) * 0.105, color);
		}
		else
		{
			PoolList.Erase(DrawNum--);
		}
	}
	return Plugin_Continue;
}

bool Fishing_IsFishingFunc(const char[] buffer)
{
	return StrEqual(buffer, "Fishing_RodM1");
}

void Fishing_DescItem(KeyValues kv, char[] desc, int[] attrib, float[] value, int attribs)
{
	static char buffer[64];
	kv.GetString("func_attack", buffer, sizeof(buffer));
	if(Fishing_IsFishingFunc(buffer))
	{
		for(int i; i < attribs; i++)
		{
			switch(attrib[i])
			{
				case 2016:
				{
					if(value[i])
						Format(desc, 512, "%s\nFishing Attraction: %.0f％", desc, 1.6 / value[i]);
				}
				case 5017:
				{
					int pos = RoundFloat(value[i]);
					if(pos < sizeof(FishingLevels))
						Format(desc, 512, "%s\nFishing Level: %s", desc, FishingLevels[pos]);
				}
			}
		}
	}
}

public void Fishing_RodM1(int client, int weapon)
{
	float ApplyCooldown = 0.8 * Attributes_Get(weapon, 6, 1.0);
	Ability_Apply_Cooldown(client, 1, ApplyCooldown);
	
	DataPack pack;
	CreateDataTimer(0.2, Fishing_RodM1Delay, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

public void FishingRodSetRarity(int client, int weapon, int index)
{
	FishingTier[client] = RoundToNearest(Attributes_Get(weapon, 5017, 0.0));
	FishingRate[client] = Attributes_Get(weapon, 2016, 1.0);
	int totalInt = Stats_Intelligence(client);
	if(totalInt >= 5000)
		FishingRate[client] *= 0.75;
	Desired_FishingTier[client] = FishingTier[client]; //Set the desired fishing tier to the tier of the rod.
}

public void FishingRodCycleRarity(int client, int weapon, int index)
{
	FishingTier[client] = RoundToNearest(Attributes_Get(weapon, 5017, 0.0));
	FishingRate[client] = Attributes_Get(weapon, 2016, 1.0);
	int totalInt = Stats_Intelligence(client);
	if(totalInt >= 5000)
		FishingRate[client] *= 0.75;
		
	Desired_FishingTier[client] -= 1;
	if(Desired_FishingTier[client] < 1)
	{
		Desired_FishingTier[client] = FishingTier[client]; //Reset desired fishing tier back to max.
	}


	if(Desired_FishingTier[client] > FishingTier[client])
	{
		Desired_FishingTier[client] = FishingTier[client]; //Safety check for incase it somehow goes over the fishing tier.
	}
	PrintHintText(client,"Your desired fishing tier is now: [%i]", Desired_FishingTier[client]);
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
		float FishPos[3];
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
					FishPos = pool.Pos;
				}
			}
		}
		
		if(choosen != -1)
		{
			TE_ParticleInt(g_FishCaughtParticle, FishPos);
			TE_SendToClient(client);
			DisplayHitEnemyTarget(client, FishPos, true);
			PoolList.GetArray(choosen, pool);
			PoolList.Erase(choosen);
			
			GetClientEyePosition(client, pos);
			TextStore_DropNamedItem(client, pool.Name, pos, 1);
			Tinker_GainXP(client, weapon);
		}
	}
	return Plugin_Handled;
}

void DisplayHitEnemyTarget(int client, float Vec[3], bool playsound)
{
	DisplayCritAboveNpc(_, client, playsound,Vec, g_FishCaughtText); //Display crit above head
}

public void Fishing_RodM2(int client, int weapon)
{
	if(GetEntProp(client, Prop_Send, "m_nWaterLevel") == 0)
		return;

	float gameTime = GetGameTime();
	if(f_ClientWasPreviouslyFishing[client] < gameTime)
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		GetNearestPond(pos, CurrentFishing[client], sizeof(CurrentFishing[]));
	}

	f_ClientWasPreviouslyFishing[client] = gameTime + 5.0;

	static PlaceEnum place;
	PlaceList.GetArray(CurrentFishing[client], place, sizeof(place));
	if(place.Pool[Desired_FishingTier[client]])
	{
		char current[48];
		int count;
		int length = place.Pool[Desired_FishingTier[client]].Length;
		for(int i; i <= length; i++)
		{
			static char buffer[48];
			if(i < length)
			{
				place.Pool[Desired_FishingTier[client]].GetString(i, buffer, sizeof(buffer));
				if(StrEqual(buffer, current))
				{
					count++;
					continue;
				}
			}
			
			if(count)
				SPrintToChat(client, "%s %d％", current, count * 100 / length);

			strcopy(current, sizeof(current), buffer);
			count = 1;
		}
	}
	PrintHintText(client,"These fish apear at your current desired tier: [%i]", Desired_FishingTier[client]);
}

static char CurrentKeyEditing[MAXPLAYERS][64];
static char CurrentRarityEditing[MAXPLAYERS][64];
static char CurrentSectionEditing[MAXPLAYERS][64];
static int CurrentMenuEditing[MAXPLAYERS];

void Fishing_EditorMenu(int client)
{
	char buffer1[PLATFORM_MAX_PATH], buffer2[PLATFORM_MAX_PATH];

	EditMenu menu = new EditMenu();

	switch(CurrentMenuEditing[client])
	{
		case 1:	// Fishing Spots
		{
			if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Fishing\nFishing Spots - %s - %s\n ", CurrentSectionEditing[client], CurrentRarityEditing[client]);
				
				if(FishList.ContainsKey(CurrentKeyEditing[client]))
				{
					FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				}
				else
				{
					Format(buffer1, sizeof(buffer1), "\"%s\" {WARNING: Fish does not exist}", buffer1);
				}

				menu.AddItem("0", buffer1);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustSpotKey);
			}
			else if(CurrentRarityEditing[client][0])
			{
				RPG_BuildPath(buffer1, sizeof(buffer1), "fishing");
				KeyValues kv = new KeyValues("Fishing");
				kv.ImportFromFile(buffer1);
				kv.JumpToKey("Positions");
				kv.JumpToKey(CurrentSectionEditing[client]);
				bool missing = !kv.JumpToKey(CurrentRarityEditing[client]);

				menu.SetTitle("Fishing\nFishing Spots - %s - %s\nClick to set it's value:\n ", CurrentSectionEditing[client], CurrentRarityEditing[client]);
				
				menu.AddItem("", "Type to add a fish", ITEMDRAW_DISABLED);

				int total;

				if(!missing && kv.GotoFirstSubKey(false))
				{
					do
					{
						total += kv.GetNum(NULL_STRING);
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();
				}

				if(!missing && kv.GotoFirstSubKey(false))
				{
					do
					{
						int count = kv.GetNum(NULL_STRING);
						kv.GetSectionName(buffer1, sizeof(buffer1));

						if(FishList.ContainsKey(buffer1))
						{
							FormatEx(buffer2, sizeof(buffer2), "%s x%d (%.2f％)", buffer1, count, float(count) * 100.0 / float(total));
						}
						else
						{
							FormatEx(buffer2, sizeof(buffer2), "%s {WARNING: Fish does not exist}", buffer1);
						}

						menu.AddItem(buffer1, buffer2);
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();
				}

				menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustSpotSection);
				
				delete kv;
			}
			else if(CurrentSectionEditing[client][0])
			{
				RPG_BuildPath(buffer1, sizeof(buffer1), "fishing");
				KeyValues kv = new KeyValues("Fishing");
				kv.ImportFromFile(buffer1);
				kv.JumpToKey("Positions");
				bool missing = !kv.JumpToKey(CurrentSectionEditing[client]);

				menu.SetTitle("Fishing\nFishing Spots - %s\nClick to set it's value:\n ", CurrentSectionEditing[client]);
				
				if(!missing && kv.GotoFirstSubKey())
				{
					do
					{
						int count;
						kv.GetSectionName(buffer1, sizeof(buffer1));

						if(kv.GotoFirstSubKey(false))
						{
							do
							{
								count++;
							}
							while(kv.GotoNextKey(false));

							kv.GoBack();
						}

						FormatEx(buffer2, sizeof(buffer2), "Rarity %s (%d Drops)", buffer1, count);
						menu.AddItem(buffer1, buffer2);
					}
					while(kv.GotoNextKey());

					kv.GoBack();
				}

				menu.AddItem("0", "Type a rarity number to create a new section", ITEMDRAW_DISABLED);

				float vec[3];
				kv.GetVector("pos", vec);
				FormatEx(buffer2, sizeof(buffer2), "Position: %.0f %.0f %.0f", vec[0], vec[1], vec[2]);
				menu.AddItem("pos", buffer2);

				menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustSpot);
				
				delete kv;
			}
			else
			{
				menu.SetTitle("Fishing\nFishing Spots\nSelect a spot:\n ");

				RPG_BuildPath(buffer1, sizeof(buffer1), "fishing");
				KeyValues kv = new KeyValues("Fishing");
				kv.ImportFromFile(buffer1);
				
				menu.AddItem("", "Type to create a new spot", ITEMDRAW_DISABLED);

				float pos[3];
				GetClientAbsOrigin(client, pos);
				GetNearestPond(pos, buffer2, sizeof(buffer2));
				
				bool first;
				if(kv.JumpToKey("Positions") && kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));
						if(StrEqual(buffer1, buffer2))
						{
							FormatEx(buffer2, sizeof(buffer2), "%s (Closest)", buffer1);
							if(first)
							{
								menu.InsertItem(0, buffer1, buffer2);
							}
							else
							{
								menu.AddItem(buffer1, buffer2);
							}
						}
						else
						{
							menu.AddItem(buffer1, buffer1);
							first = true;
						}
					}
					while(kv.GotoNextKey());
				}

				menu.ExitBackButton = true;
				menu.Display(client, FishPicker);

				delete kv;
			}
		}
		case 2:	// Fish Listing
		{
			if(CurrentKeyEditing[client][0])
			{
				menu.SetTitle("Spawns\nFish Listing - %s\n ", CurrentSectionEditing);
				
				FormatEx(buffer1, sizeof(buffer1), "Type to set value for \"%s\"", CurrentKeyEditing[client]);
				menu.AddItem("", buffer1, ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustFishKey);
			}
			else if(CurrentSectionEditing[client][0])
			{
				RPG_BuildPath(buffer1, sizeof(buffer1), "fishing");
				KeyValues kv = new KeyValues("Fishing");
				kv.ImportFromFile(buffer1);
				kv.JumpToKey("Fishes");
				bool missing = !kv.JumpToKey(CurrentSectionEditing[client]);

				menu.SetTitle("Fishing\nFish Listing - %s\nClick to set it's value:\n ", CurrentSectionEditing[client]);
				
				if(!TextStore_IsValidName(CurrentSectionEditing[client]))
					menu.AddItem("delete", "{WARNING: Item does not exist}\n ");
				
				static const char Types[][] =
				{
					"0 (Fish)",
					"1 (Nature)",
					"2 (Landfill)",
					"3 (Lootboxes)"
				};

				int type = kv.GetNum("type");
				if(!missing && type >= 0 && type < sizeof(Types))
				{
					FormatEx(buffer2, sizeof(buffer2), "Type: %s", Types[type]);
				}
				else
				{
					FormatEx(buffer2, sizeof(buffer2), "Type: %d (Unknown)", type);
				}

				menu.AddItem("type", buffer2);

				FormatEx(buffer2, sizeof(buffer2), "Rarity: %d", kv.GetNum("rarity"));
				menu.AddItem("rarity", buffer2);

				menu.AddItem("delete", "Delete (Type \"delete\")", ITEMDRAW_DISABLED);

				menu.ExitBackButton = true;
				menu.Display(client, AdjustFish);
				
				delete kv;
			}
			else
			{
				menu.SetTitle("Fishing\nFish Listing\nSelect a fish:\n ");

				RPG_BuildPath(buffer1, sizeof(buffer1), "fishing");
				KeyValues kv = new KeyValues("Fishing");
				kv.ImportFromFile(buffer1);
				
				menu.AddItem("", "Type to create a new fish", ITEMDRAW_DISABLED);
				
				if(kv.JumpToKey("Fishes") && kv.GotoFirstSubKey())
				{
					do
					{
						kv.GetSectionName(buffer1, sizeof(buffer1));

						if(TextStore_IsValidName(buffer1))
						{
							strcopy(buffer2, sizeof(buffer2), buffer1);
						}
						else
						{
							Format(buffer2, sizeof(buffer2), "%s {WARNING: Item does not exist}", buffer1);
						}

						menu.AddItem(buffer1, buffer2);
					}
					while(kv.GotoNextKey());
				}

				menu.ExitBackButton = true;
				menu.Display(client, FishPicker);

				delete kv;
			}
		}
		default:
		{
			menu.SetTitle("Fishing\n ");

			menu.AddItem("2", "Fish Listing");
			menu.AddItem("1", "Fishing Spots");

			menu.ExitBackButton = true;
			menu.Display(client, MenuPicker);
		}
	}
}

static void MenuPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		Editor_MainMenu(client);
		return;
	}

	CurrentMenuEditing[client] = StringToInt(key);
	Fishing_EditorMenu(client);
}

static void FishPicker(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentMenuEditing[client] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	strcopy(CurrentSectionEditing[client], sizeof(CurrentSectionEditing[]), key);
	Fishing_EditorMenu(client);
}

static void AdjustFish(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Fishes", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);

	if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentSectionEditing[client][0] = 0;
	}
	else
	{
		delete kv;
		
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Fishing_EditorMenu(client);
		return;
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Fishing_ConfigSetup();
	Fishing_EditorMenu(client);
}

static void AdjustFishKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Fishes", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);

	int value = StringToInt(key);
	if(value >= 0)
	{
		kv.SetNum(CurrentKeyEditing[client], value);
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Fishing_ConfigSetup();
	Fishing_EditorMenu(client);
}

static void AdjustSpot(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentSectionEditing[client][0] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Positions", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);

	if(StrEqual(key, "pos"))
	{
		float pos[3];
		GetClientAbsOrigin(client, pos);
		kv.SetVector("pos", pos);
	}
	else if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentSectionEditing[client][0] = 0;
	}
	else
	{
		delete kv;
		
		strcopy(CurrentRarityEditing[client], sizeof(CurrentRarityEditing[]), key);
		Fishing_EditorMenu(client);
		return;
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Fishing_ConfigSetup();
	Fishing_EditorMenu(client);
}

static void AdjustSpotSection(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentRarityEditing[client][0] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Positions", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);
	kv.JumpToKey(CurrentRarityEditing[client], true);

	if(StrEqual(key, "delete"))
	{
		kv.DeleteThis();
		CurrentSectionEditing[client][0] = 0;
	}
	else
	{
		delete kv;
		
		strcopy(CurrentKeyEditing[client], sizeof(CurrentKeyEditing[]), key);
		Fishing_EditorMenu(client);
		return;
	}

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Fishing_ConfigSetup();
	Fishing_EditorMenu(client);
}

static void AdjustSpotKey(int client, const char[] key)
{
	if(StrEqual(key, "back"))
	{
		CurrentKeyEditing[client][0] = 0;
		Fishing_EditorMenu(client);
		return;
	}

	char filepath[PLATFORM_MAX_PATH];
	RPG_BuildPath(filepath, sizeof(filepath), "fishing");
	KeyValues kv = new KeyValues("Fishing");
	kv.ImportFromFile(filepath);
	kv.JumpToKey("Positions", true);
	kv.JumpToKey(CurrentSectionEditing[client], true);
	kv.JumpToKey(CurrentRarityEditing[client], true);

	int value = StringToInt(key);
	if(value > 0)
	{
		kv.SetNum(CurrentKeyEditing[client], value);
	}
	else
	{
		kv.DeleteKey(CurrentKeyEditing[client]);
	}

	CurrentKeyEditing[client][0] = 0;

	kv.Rewind();
	kv.ExportToFile(filepath);
	delete kv;
	
	Fishing_ConfigSetup();
	Fishing_EditorMenu(client);
}