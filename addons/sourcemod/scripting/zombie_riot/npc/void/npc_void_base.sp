
static ArrayList NavList;
static Handle RenderTimer;
static Handle DamageTimer;
static float NervousTouching[MAXENTITIES + 1];
static CNavArea NervousLastTouch[MAXENTITIES + 1];
static int SpreadTicks;
static float RenderToAll;

bool VoidArea_TouchingNethersea(int entity)
{
	return NervousTouching[entity] > GetGameTime();
}

void VoidArea_ClearnNethersea()
{
	RenderToAll = 0.0;
	delete NavList;
}

void VoidArea_SpawnNethersea(const float pos[3], bool WasWeapon = false)
{
	if(!WasWeapon)
	{
		//Make sure to render for a LONG time
		RenderToAll = GetGameTime() + 600.0;
	}
	if(!NavList)
		NavList = new ArrayList();
	
	if(!DamageTimer)
		DamageTimer = CreateTimer(0.2, VoidArea_DamageTimer, _, TIMER_REPEAT);
	
	if(!RenderTimer)
		RenderTimer = CreateTimer(4.0, VoidArea_RenderTimer, _, TIMER_REPEAT);

	CNavArea nav = TheNavMesh.GetNavArea(pos, 30.0);
	if(nav != NULL_AREA)
	{
		if(NavList.FindValue(nav) == -1)
		{
			if(!nav.HasAttributes(NAV_MESH_NO_HOSTAGES))
			{
				NavList.Push(nav);
				TriggerTimer(RenderTimer, true);
			}
		}
	}
}

static bool Similar(float val1, float val2)
{
	return fabs(val1 - val2) < 2.0;
}

static bool SimilarMore(float val1, float val2)
{
	return (val1 > val2) && !Similar(val1, val2);
}

static bool SimilarLess(float val1, float val2)
{
	return (val1 < val2) && !Similar(val1, val2);
}

static bool Overlapping(const float[] pos1, const float[] pos2, int index1, int index2)
{
	return !((SimilarMore(pos1[index1], pos2[index1]) && SimilarMore(pos1[index2], pos2[index2]) && SimilarMore(pos1[index1], pos2[index2]) && SimilarMore(pos1[index2], pos2[index1])) ||
			(SimilarLess(pos1[index1], pos2[index1]) && SimilarLess(pos1[index2], pos2[index2]) && SimilarLess(pos1[index1], pos2[index2]) && SimilarLess(pos1[index2], pos2[index1])));
}

public Action VoidArea_RenderTimer(Handle timer, DataPack pack)
{
	if(!NavList || (Waves_InSetup() && !CvarNoRoundStart.BoolValue))
	{
		delete NavList;
		RenderTimer = null;
		SpreadTicks = 0;
		return Plugin_Stop;
	}
	int SpreadTicksMax = 24;

	if(CurrentRound >= 39)
		SpreadTicksMax = 24 * 3;

	if(RaidbossIgnoreBuildingsLogic(0))
		SpreadTicksMax = 6;

	//wave 40 nerf

	if(++SpreadTicks > SpreadTicksMax)
	{
		SpreadTicks = (GetURandomInt() % 3) - 1;

		ArrayList list = new ArrayList();

		float gameTime = GetGameTime();
		for(int entity = 1; entity < sizeof(NervousTouching); entity++)	// Prevent spreading if an entity is on it currently
		{
			if(NervousTouching[entity] > gameTime)
			{
				list.Push(NervousLastTouch[entity]);
			}
		}

		//If Only allow 25 navs to spread at once
		int AllowMaxSpread = 0;
		int length = NavList.Length;
		for(int a; a < length; a++)	// Spread creap to all tiles it touches
		{
			CNavArea nav1 = NavList.Get(a);

			if(list.FindValue(nav1) == -1)
			{
				for(NavDirType b; b < NUM_DIRECTIONS; b++)
				{
					int count = nav1.GetAdjacentCount(b);
					for(int c; c < count; c++)
					{
						if(AllowMaxSpread >= 25)
						{
							break;
						}
						CNavArea nav2 = nav1.GetAdjacentArea(b, c);
						if(nav2 != NULL_AREA && !nav2.HasAttributes(NAV_MESH_NO_HOSTAGES) && NavList.FindValue(nav2) == -1)
						{
							AllowMaxSpread++;
							NavList.Push(nav2);
						}
					}
				}
			}
		}

		delete list;
	}

	float lines1[6];//, lines2[6];
	//float line1[3], line2[3];

	ArrayList list = new ArrayList(sizeof(lines1));

	int length1 = NavList.Length;
	float corner[NUM_CORNERS][3];
	for(int a; a < length1; a++)	// Go through infected tiles
	{
		CNavArea nav = NavList.Get(a);

		for(NavCornerType b = NORTH_WEST; b < NUM_CORNERS; b++)	// Go through each side of the tile
		{
			nav.GetCorner(b, corner[b]);
		}

		for(NavCornerType b = NORTH_WEST; b < NUM_CORNERS; b++)
		{
			// Get the two positions for a line of the side
			NavCornerType c = (b + view_as<NavCornerType>(1));
			if(c == NUM_CORNERS)
				c = NORTH_WEST;

			// Sort by highest first to filter out dupe lines
			if(corner[b][0] > corner[c][0])
			{
				lines1[0] = corner[b][0];
				lines1[1] = corner[b][1];
				lines1[2] = corner[b][2];
				lines1[3] = corner[c][0];
				lines1[4] = corner[c][1];
				lines1[5] = corner[c][2];
			}
			else
			{
				lines1[0] = corner[c][0];
				lines1[1] = corner[c][1];
				lines1[2] = corner[c][2];
				lines1[3] = corner[b][0];
				lines1[4] = corner[b][1];
				lines1[5] = corner[b][2];
			}

			AddLineToListTest(0, list, lines1);
		}
	}

	length1 = list.Length;
	for(int a; a < length1; a++)
	{
		list.GetArray(a, lines1);

		//if(!lines1[6])
		{
			/*line1[0] = lines1[0];
			line1[1] = lines1[1];
			line1[2] = lines1[2] + 3.0;
			line2[0] = lines1[3];
			line2[1] = lines1[4];
			line2[2] = lines1[5] + 3.0;*/

			DataPack pack2 = new DataPack();
			RequestFrames(VoidArea_RenderFrame, 2 + (a / 16), pack2);
			pack2.WriteFloat(lines1[0]);
			pack2.WriteFloat(lines1[1]);
			pack2.WriteFloat(lines1[2] + 8.0);
			pack2.WriteFloat(lines1[3]);
			pack2.WriteFloat(lines1[4]);
			pack2.WriteFloat(lines1[5] + 8.0);
		}
	}

	delete list;
	return Plugin_Continue;
}

static void AddLineToListTest(int start, ArrayList list, const float lines1[6])
{
	float sort[4][2], lines2[6];

	int length2 = list.Length;
	for(int d = start; d < length2; d++)	// Find dupe lines from touching tiles
	{
		list.GetArray(d, lines2);

		if(Similar(lines1[0], lines1[3]) && Similar(lines1[0], lines2[0]) && Similar(lines1[3], lines2[3]) &&	// Same x-axis
			Overlapping(lines1, lines2, 1, 4))	// Overlapping y-axis
		{
			sort[0][0] = lines1[1];
			sort[0][1] = lines1[2];
			sort[1][0] = lines2[1];
			sort[1][1] = lines2[2];
			sort[2][0] = lines1[4];
			sort[2][1] = lines1[5];
			sort[3][0] = lines2[4];
			sort[3][1] = lines2[5];

			SortCustom2D(sort, sizeof(sort), SeaFounder_Sorting);

			list.Erase(d);

			for(int e; e < 3; e += 2)	// Compare 1st and 2nd, 3rd and 4th
			{
				if(!Similar(sort[e][0], sort[e + 1][0]))
				{
					lines2[1] = sort[e][0];
					lines2[2] = sort[e][1];
					lines2[4] = sort[e + 1][0];
					lines2[5] = sort[e + 1][1];

					AddLineToListTest(d + 1, list, lines2);
				}
			}

			return;
		}
		
		if(Similar(lines1[1], lines1[4]) && Similar(lines1[1], lines2[1]) && Similar(lines1[4], lines2[4]) &&	// Same y-axis
			Overlapping(lines1, lines2, 0, 3))	// Overlapping x-axis
		{
			sort[0][0] = lines1[0];
			sort[0][1] = lines1[2];
			sort[1][0] = lines2[0];
			sort[1][1] = lines2[2];
			sort[2][0] = lines1[3];
			sort[2][1] = lines1[5];
			sort[3][0] = lines2[3];
			sort[3][1] = lines2[5];

			SortCustom2D(sort, sizeof(sort), SeaFounder_Sorting);

			list.Erase(d);

			for(int e; e < 3; e += 2)
			{
				if(!Similar(sort[e][0], sort[e + 1][0]))
				{
					lines2[0] = sort[e][0];
					lines2[2] = sort[e][1];
					lines2[3] = sort[e + 1][0];
					lines2[5] = sort[e + 1][1];

					AddLineToListTest(d + 1, list, lines2);
				}
			}

			return;
		}
	}

	list.PushArray(lines1);	// Add to line list
}

public void VoidArea_RenderFrame(DataPack pack)
{
	pack.Reset();
	float pos1[3], pos2[3];
	pos1[0] = pack.ReadFloat();
	pos1[1] = pack.ReadFloat();
	pos1[2] = pack.ReadFloat();
	pos2[0] = pack.ReadFloat();
	pos2[1] = pack.ReadFloat();
	pos2[2] = pack.ReadFloat();

	delete pack;

	TE_SetupBeamPoints(pos1, pos2, Silvester_BEAM_Laser_1, Silvester_BEAM_Laser_1, 0, 0, 4.0, 5.0/*Width*/, 5.0/*end Width*/, 0, 0.0, {200, 0, 25, 125}, 0);
	if(RenderToAll < GetGameTime())
	{	
		int total = 0;
		int[] clients = new int[MaxClients];
		//it will render only to players with the blade
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && ClientPossesesVoidBlade(client))
			{
				clients[total++] = client;
			}
		}
		if(total > 0)
			TE_Send(clients, total, 0.0);
	}
	else
		TE_SendToAll();
}

public Action VoidArea_DamageTimer(Handle timer, DataPack pack)
{
	if(!NavList || (Waves_InSetup() && !CvarNoRoundStart.BoolValue))
	{
		Zero(NervousTouching);
		delete NavList;
		DamageTimer = null;
		return Plugin_Stop;
	}

	NervousTouching[0] = GetGameTime() + 0.5;
	
	float pos[3];


	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);

			// Find entities touching infected tiles
			CNavArea nav = TheNavMesh.GetNavArea(pos, 5.0);
			if(nav != NULL_AREA && NavList.FindValue(nav) != -1)
			{
				NervousTouching[entity] = NervousTouching[0];
			//	NervousLastTouch[entity] = NULL_AREA;
				if(view_as<CClotBody>(entity).m_iBleedType == BLEEDTYPE_VOID || GetEntPropFloat(entity, Prop_Data, "m_flElementRes", Element_Void) > 0.4)
				{
					VoidWave_ApplyBuff(entity, 1.0);
				}
				else if(RenderToAll)
				{
					ApplyStatusEffect(entity, entity, "Void Presence", 1.0);
				}
			}
		}
	}
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
		{
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);

			// Find entities touching infected tiles
			CNavArea nav = TheNavMesh.GetNavArea(pos, 70.0);
			if(nav != NULL_AREA && NavList.FindValue(nav) != -1)
			{
				if(ClientPossesesVoidBlade(client))
				{
					VoidWave_ApplyBuff(client, 1.0);
				}
				else if(RenderToAll)
				{
					ApplyStatusEffect(client, client, "Void Presence", 1.0);
				}
				NervousTouching[client] = NervousTouching[0];
			}
		}
	}
	return Plugin_Continue;
}


//This places a spawnpoint somewhere on the map.
int Void_PlaceZRSpawnpoint(float SpawnPos[3], int WaveDuration = 2000000000, int SpawnsMax = 2000000000, char[] ParticleToSpawn = "", int ParticleOffset = 0, bool SpreadVoid = false, int MaxWaves = 2)
{
	if(VIPBuilding_Active())
		return INVALID_ENT_REFERENCE;
	
	// info_player_teamspawn
	int ref = CreateEntityByName("info_player_teamspawn");
	if(ref != -1)
	{
		SetEntProp(ref, Prop_Data, "m_iTeamNum", 3);
		DispatchKeyValueVector(ref, "origin", SpawnPos);
		DispatchSpawn(ref);
	}
	SDKHook_TeamSpawn_SpawnPostInternal(ref, SpawnsMax, 1, MaxWaves);

	if(WaveDuration >= 1 || ParticleToSpawn[0])
	{
		int ParticleToGive = -1;
		SpawnPos[2] += ParticleOffset;
		if(ParticleToSpawn[0])
		{
			ParticleToGive = EntIndexToEntRef(ParticleEffectAt(SpawnPos, ParticleToSpawn, 0.0));
		}
		DataPack pack;
		CreateDataTimer(0.25, Timer_VoidSpawnPoint, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		pack.WriteCell(ref); 							//spawner to give
		pack.WriteCell(ParticleToGive);					//What particle does it have?
		pack.WriteCell(GetRandomSeedFallenWarrior()); 	//CurrentWave
		pack.WriteCell(WaveDuration);					//how many waves?
		pack.WriteCell(SpreadVoid);						//Should it spread void?
		pack.WriteFloat(GetGameTime());						//Spread Void
	}
	
	return ref;
}


public Action Timer_VoidSpawnPoint(Handle timer, DataPack pack)
{
	pack.Reset();
	int SpawnRef = pack.ReadCell();
	int ParticleRef = pack.ReadCell();
	if(!IsValidEntity(SpawnRef))
	{
		if(IsValidEntity(ParticleRef))
			RemoveEntity(ParticleRef);

		return Plugin_Stop;
	}
	//remove during setups.
	if(Waves_InSetup())
	{
		if(IsValidEntity(ParticleRef))
			RemoveEntity(ParticleRef);

		RemoveEntity(SpawnRef);
		return Plugin_Stop;
	}
	int RandomSeed = pack.ReadCell();
	int WaveDuration = pack.ReadCell();
	if(RandomSeed != GetRandomSeedFallenWarrior())
	{
		WaveDuration--;
		if(WaveDuration <= -1)
		{
			if(IsValidEntity(ParticleRef))
				RemoveEntity(ParticleRef);

			RemoveEntity(SpawnRef);
			return Plugin_Stop;
		}
		pack.Position--;
		pack.WriteCell(WaveDuration, false);
		pack.Position--;
		pack.Position--;
		//Set The current Random seed
		pack.WriteCell(GetRandomSeedFallenWarrior(), false);
		pack.Position++;
	}
	bool SpreadVoid = pack.ReadCell();
	if(SpreadVoid)
	{
		float SpawnPos[3];
		GetEntPropVector(SpawnRef, Prop_Data, "m_vecAbsOrigin", SpawnPos);
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		wave *= MinibossScalingReturn();
		float damage = 25.0;
		i_ExplosiveProjectileHexArray[EntRefToEntIndex(ParticleRef)] = (EP_DEALS_TRUE_DAMAGE | EP_NO_KNOCKBACK);
		Explode_Logic_Custom(damage * wave, EntRefToEntIndex(ParticleRef), EntRefToEntIndex(ParticleRef), -1, SpawnPos, 70.0, 1.0, _, false, 99,_,15.0, .FunctionToCallBeforeHit = VoidGateHurtVoid);
		float SpreadVoidCooldown = pack.ReadFloat();
		if(SpreadVoidCooldown < GetGameTime())
		{
			SpreadVoidCooldown = GetGameTime() + 3.0;
			pack.Position--;
			pack.WriteFloat(SpreadVoidCooldown, false);
			VoidArea_SpawnNethersea(SpawnPos);
		}
	}

	return Plugin_Continue;
}

static float VoidGateHurtVoid(int attacker, int victim, float &damage, int weapon)
{
	if((!b_NpcHasDied[victim] && (view_as<CClotBody>(victim).m_iBleedType == BLEEDTYPE_VOID || GetEntPropFloat(victim, Prop_Data, "m_flElementRes", Element_Void) > 0.4)) || (victim <= MaxClients && ClientPossesesVoidBlade(victim)))
	{
		damage = 0.0;
	}
	return 0.0;
}