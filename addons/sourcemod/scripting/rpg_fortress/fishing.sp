#pragma semicolon 1
#pragma newdecls required

static const char FishingLevels[][] =
{
	"Leaf (0)",
	"Feather (1)",
	"Silk (2)",
	"Wire (3)",
	"IV Cable (4)",
	"Carving Tool (5)",
	"MV Cable (6)",
	"HV Cable (7)"
};

#define SHALLOW_WATER_POS_LIMIT 30.0

enum struct PlaceEnum
{
	float Pos[3];
	int Luck;
	ArrayList Pool;
}

enum struct FishEnum
{
	int Tier;
	int Type;
	int Color[4];
	
	void SetupEnum(KeyValues kv)
	{
		this.Tier = kv.GetNum("tier");
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
static float f_ClientWasFishingDelayCheck[MAXTF2PLAYERS];
static float f_ClientWasPreviouslyFishing[MAXTF2PLAYERS];
static float FishingRate[MAXTF2PLAYERS] = {1.0, ...};
static int FishingTier[MAXTF2PLAYERS];
static char CurrentFishing[MAXTF2PLAYERS][32];

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
	
	PlaceEnum place;

	if(PlaceList)
	{
		StringMapSnapshot snap = PlaceList.Snapshot();
		int length = snap.Length;
		for(int i; i < length; i++)
		{
			snap.GetKey(i, buffer, sizeof(buffer));
			PlaceList.GetArray(buffer, place, sizeof(place));
			delete place.Pool;
		}

		delete snap;
		delete PlaceList;
	}

	PlaceList = new StringMap();

	if(kv.JumpToKey("Positions") && kv.GotoFirstSubKey())
	{
		do
		{
			place.Pool = new ArrayList(ByteCountToCells(48));

			if(kv.JumpToKey("Pool"))
			{
				if(kv.GotoFirstSubKey(false))
				{
					do
					{
						kv.GetSectionName(buffer, sizeof(buffer));
						int amount = kv.GetNum(NULL_STRING, 1);
						for(int i; i < amount; i++)
						{
							place.Pool.PushString(buffer);
						}
					}
					while(kv.GotoNextKey(false));

					kv.GoBack();
				}

				kv.GoBack();
			}

			if(!place.Pool.Length)
			{
				delete place.Pool;
				continue;
			}

			kv.GetSectionName(buffer, sizeof(buffer));
			kv.GetVector("pos", place.Pos);
			place.Luck = kv.GetNum("luck");
			PlaceList.SetArray(buffer, place, sizeof(place));
		}
		while(kv.GotoNextKey());
	}

	if(kv != map)
		delete kv;
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
	place.Pool.GetString(GetURandomInt() % place.Pool.Length, pool.Name, sizeof(pool.Name));

	static FishEnum fish;
	FishList.GetArray(pool.Name, fish, sizeof(fish));
	if(FishingTier[client] >= fish.Tier)
	{
		pool.Client = client;
		pool.Pos = pos;
		pool.Tier = fish.Tier;
		pool.ExpireIn = GetGameTime() + 15.0;
		strcopy(pool.Place, sizeof(pool.Place), CurrentFishing[client]);
		PoolList.PushArray(pool);
	}
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
						Format(desc, 512, "%s\nFishing Attraction: %.0f%%", desc, 1.6 / value[i]);
				}
				case 2017:
				{
					int pos = RoundFloat(value[i]);
					if(pos < sizeof(FishingLevels))
						Format(desc, 512, "%s\nFishing Level: %s", desc, FishingLevels[pos]);
				}
			}
		}
	}
}

public void Fishing_RodM1(int client, int weapon, const char[] classname, bool &result)
{
	float ApplyCooldown =  0.8 * Attributes_FindOnWeapon(client, weapon, 6, true, 1.0);
	Ability_Apply_Cooldown(client, 1, ApplyCooldown);
	FishingTier[client] = RoundToNearest(Attributes_FindOnWeapon(client, weapon, 2017));
	FishingRate[client] = Attributes_FindOnWeapon(client, weapon, 2016, true, 1.0);
	
	DataPack pack;
	CreateDataTimer(0.2, Fishing_RodM1Delay, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
}

public void FishingRodSetRarity(int client, int weapon, int index)
{
	FishingTier[client] = RoundToNearest(Attributes_FindOnWeapon(client, weapon, 2017));
	FishingRate[client] = Attributes_FindOnWeapon(client, weapon, 2016, true, 1.0);
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
			DisplayCritAboveNpc(_, client, true,FishPos, g_FishCaughtText); //Display crit above head
			PoolList.GetArray(choosen, pool);
			PoolList.Erase(choosen);
			
			GetClientEyePosition(client, pos);
			TextStore_DropNamedItem(client, pool.Name, pos, 1);
		}
	}
	return Plugin_Handled;
}