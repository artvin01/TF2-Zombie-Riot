#pragma semicolon 1
#pragma newdecls required

enum struct FishingEnum
{
	char Zone[32];
	float Pos[3];
	
	void SetupEnum(KeyValues kv)
	{
	//	kv.GetSectionName(this.Model, PLATFORM_MAX_PATH);
	//	ExplodeStringFloat(this.Model, " ", this.Pos, sizeof(this.Pos));

		kv.GetString("zone", this.Zone, 32);
	}
	
	void DespawnFish()
	{
		/*
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
		*/
	}
	
	void SpawnFish()
	{

	}

	void IsFishValid()
	{

	}
}

static ArrayList FishingList;

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
		BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "Fishing");
		kv = new KeyValues("Fishing");
		kv.ImportFromFile(buffer);
	}
	
	delete FishingList;
	FishingList = new ArrayList(sizeof(FishingEnum));

	FishingEnum fish;

	kv.GotoFirstSubKey();
	do
	{
		kv.GetSectionName(fish.Zone, sizeof(fish.Zone));

		if(kv.GotoFirstSubKey())
		{
			do
			{
				fish.SetupEnum(kv);
				FishingList.PushArray(fish);
			}
			while(kv.GotoNextKey());
			kv.GoBack();
		}
	}
	while(kv.GotoNextKey());

	if(kv != map)
		delete kv;
}


float f_ClientWasFishingDelayCheck[MAXTF2PLAYERS];
float f_ClientWasPreviouslyFishing[MAXTF2PLAYERS];

#define SHALLOW_WATER_POS_LIMIT 30.0

void Fishing_PlayerRunCmd(int client)
{
	if(f_ClientWasFishingDelayCheck[client] < GetGameTime())
	{
		f_ClientWasFishingDelayCheck[client] = GetGameTime() + 0.1;
		int AllowFishing = 0;
		if(GetEntProp(client, Prop_Send, "m_nWaterLevel") >= 1)
		{
			AllowFishing = 1; //Allow fishing and reset the float so they can keep fishing
		}
		else if(f_ClientWasPreviouslyFishing[client] > GetGameTime())
		{
			AllowFishing = 2; //Allow fishing but dont reset the float
		}

		if (AllowFishing > 0)
		{
			if(AllowFishing == 1)
			{
				f_ClientWasPreviouslyFishing[client] = GetGameTime() + 5.0;
			}
			float f_pos[3];
			float f_ang[3];

			GetClientEyePosition(client,f_pos);

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
						FishCreatedOrIsValid(client, f_MiddlePos);
					}
				}
			}
		}
	}
}


void FishCreatedOrIsValid(int client, float f_fishpos[3])
{
	static float m_vecMaxs[3];
	static float m_vecMins[3];
	m_vecMaxs = view_as<float>( { 5.0, 5.0, 5.0 } );
	m_vecMins = view_as<float>( { -5.0, -5.0, -5.0 } );	
	TE_DrawBox(client, f_fishpos, m_vecMins, m_vecMaxs, 2.0, view_as<int>({0, 255, 0, 255}));
}