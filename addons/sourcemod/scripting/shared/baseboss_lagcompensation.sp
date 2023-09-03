#pragma semicolon 1

#pragma newdecls required

/* engine/host.h#L157-L158 */
#define TIME_TO_TICKS(%1)	RoundToNearest(0.5 + %1 / GetTickInterval())
#define TICKS_TO_TIME(%1)	(GetTickInterval() * float(%1))

/* game/client/c_baseanimatingoverlay.h#L46 */
#define MAX_LAYER_RECORDS	15

/* game/server/player_lagcompensation.cpp#L45 */
enum struct LayerRecord
{
	int m_sequence;
	float m_cycle;
	float m_weight;
	int m_order;
}

/* game/server/player_lagcompensation.cpp#L69 */
enum struct LagRecord
{
	// Did player die this frame
	//int						m_fFlags;

	// Player position, orientation and bbox
	float					m_vecOrigin[3];
	float					m_vecAngles[3];
//	float					m_vecMinsPreScaled[3];
//	float					m_vecMaxsPreScaled[3];

	float					m_flSimulationTime;	
	
	// Player animation details, so we can get the legs in the right spot.
	ArrayList				m_layerRecords;
	int						m_masterSequence;
	float					m_masterCycle;
}

//static ConVar sv_unlag;
static ConVar sv_maxunlag;
//static ConVar mp_friendlyfire;

static StringMap EntityTrack;
static StringMap EntityRestore;
static int TickCount[MAXTF2PLAYERS];
static float ViewAngles[MAXTF2PLAYERS][3];
static bool b_EntityIsLagComp[MAXENTITIES];

void OnPluginStart_LagComp()
{
//	sv_unlag = FindConVar("sv_unlag");
	sv_maxunlag = FindConVar("sv_maxunlag");
//	mp_friendlyfire = FindConVar("mp_friendlyfire");
	
	EntityTrack = new StringMap();
	EntityRestore = new StringMap();
	/*
	GameData gamedata = LoadGameConfigFile("lagcompensation");
	
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, "CLagCompensationManager::StartLagCompensation");
	DHookEnableDetour(detour, false, StartLagCompensation);
	delete detour;
	
	detour = DynamicDetour.FromConf(gamedata, "CLagCompensationManager::FinishLagCompensation");
	DHookEnableDetour(detour, false, FinishLagCompensation);
	delete detour;
	*/
//	delete gamedata;	   
}

Action OnPlayerRunCmd_Lag_Comp(int client, float angles[3], int &tickcount)
{
//	i_CmdNumber[client] = cmdnum;
	TickCount[client] = tickcount;
	ViewAngles[client] = angles;
	return Plugin_Continue;
}
/* Manually remove no longer in use entites */
void OnEntityDestroyed_LagComp(int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
		if(!b_EntityIsLagComp[entity])
		{
			return;
		}
		b_EntityIsLagComp[entity] = false;
		
		b_LagCompensationDeletedArrayList[entity] = true;
		int ref = EntIndexToEntRef(entity);
		char key[13];
		IntToString(ref, key, sizeof(key));
		
		ArrayList list;
		if(EntityTrack.GetValue(key, list))
		{
			EntityTrack.Remove(key);
			if(list)
			{
				LagRecord record;
				int length2 = list.Length;
				for(int a; a<length2; a++)
				{
					list.GetArray(a, record);
		//			if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
					{
						delete record.m_layerRecords;
					}
				}
				delete list;
			}
		}
	/*
		static LagRecord restore;
		if(EntityRestore.GetArray(key, restore, sizeof(restore)))
		{
			if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
			{
				if(restore.m_layerRecords)
				{
					delete restore.m_layerRecords;
				}
			}
			EntityRestore.Remove(key);
		}
	*/
		LagRecord restore;
		EntityRestore.GetArray(key, restore, sizeof(restore));
	//	if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
		{
			if(restore.m_layerRecords)
			{
				delete restore.m_layerRecords;
			}
		}
	}
}

/* game/server/player_lagcompensation.cpp#L328 */
//public MRESReturn StartLagCompensation(Address manager, DHookParam param)
void StartLagCompensation_Base_Boss(int client)
{
	if(!DoingLagCompensation) //dont  check for && sv_unlag.BoolValue, this function wont even call if you dont have this cvar enabled.
	{
	//	if(GetEntProp(client, Prop_Data, "m_bLagCompensation", 1) && !IsFakeClient(client) && IsPlayerAlive(client)) dont check for these things, unndeded as fuck
		{
		//	CurrentPlayer = client;
		//	SetEntProp(client, Prop_Data, "m_bLagCompensation", false, 1);
			
			DoingLagCompensation = true;
			
			// Get true latency
			
			// correct is the amout of time we have to correct game time
			float correct = GetClientLatency(client, NetFlow_Outgoing);
			
			// calc number of view interpolation ticks - 1
			int lerpTicks = TIME_TO_TICKS(GetEntPropFloat(client, Prop_Data, "m_fLerpTime"));
			
			// add view interpolation latency see C_BaseEntity::GetInterpolationAmount()
			correct += TICKS_TO_TIME(lerpTicks);
			
			// check bouns [0,sv_maxunlag]
			correct = clamp(correct, 0.0, sv_maxunlag.FloatValue);
			
			// correct tick send by player 
			int targettick = TickCount[client] - lerpTicks;
			
			// calc difference between tick send by player and our latency based tick
			float deltaTime = correct - TICKS_TO_TIME(GetGameTickCount() - targettick);
			
			if(fabs(deltaTime) > 0.2)
			{
				// difference between cmd time and latency is too big > 200ms, use time correction based on latency
			//	PrintToConsoleAll("StartLagCompensation: delta too big (%.3f)\n", deltaTime );
				targettick = GetGameTickCount() - TIME_TO_TICKS(correct);
			}

			
			// Iterate all active NPCs
			//const CBitVec<MAX_EDICTS> *pEntityTransmitBits = engine.GetEntityTransmitBitsForClient( player.entindex() - 1 );
		//	if(!compensate_players)
			{
				for(int entitycount; entitycount<i_Maxcount_Apply_Lagcompensation; entitycount++)
				{
					int entity = EntRefToEntIndex(i_Objects_Apply_Lagcompensation[entitycount]);
					if(IsValidEntity(entity))
					{
							// Custom checks for if things should lag compensate (based on things like what team the player is on).
						if(!WantsLagCompensationOnEntity(entity, client, ViewAngles[client]/*, pEntityTransmitBits*/))
							continue;

						// Move other NPCs back in time
						BacktrackEntity(entity, TICKS_TO_TIME(targettick));
					}
				}
			}
		}
	}
}

/* game/server/player.cpp#L732 */
bool WantsLagCompensationOnEntity(int entity, int player, const float viewangles[3]/*, const CBitVec<MAX_EDICTS> *pEntityTransmitBits */)
{
	// Team members shouldn't be adjusted unless friendly fire is on.
	/*
	if(!mp_friendlyfire.BoolValue && GetClientTeam(player) == GetEntProp(entity, Prop_Data, "m_iTeamNum"))
		return false;
	*/
	// If this entity hasn't been transmitted to us and acked, then don't bother lag compensating it.
	//if ( pEntityTransmitBits && !pEntityTransmitBits.Get( pPlayer.entindex() ) )
	//	return false;
	if(b_LagCompNPC_OnlyAllies && !b_IsAlliedNpc[entity])
	{
		return false;
	}
	float pos1[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos1);
	float pos2[3];
	GetClientAbsOrigin(player, pos2);
	
	// get max distance player could have moved within max lag compensation time, 
	// multiply by 1.5 to to avoid "dead zones"  (sqrt(2) would be the exact value)
	float maxDistance = 1.5 * GetEntPropFloat(player, Prop_Data, "m_flMaxspeed") * sv_maxunlag.FloatValue;
	
	// If the player is within this distance, lag compensate them in case they're running past us.
	if(GetVectorDistance(pos2, pos1) < maxDistance)
		return true;
	
//	if(!b_LagCompNPC_No_Layers)
//	{
	// If their origin is not within a 45 degree cone in front of us, no need to lag compensate.
	float forwar[3];
	GetAngleVectors(viewangles, forwar, NULL_VECTOR, NULL_VECTOR );
	
	float diff[3];
	SubtractVectors(pos2, pos1, diff);
	NormalizeVector(diff, diff);
	
	static const float flCosAngle = 0.707107;	// 45 degree angle
	if(GetVectorDotProduct(forwar, diff) > flCosAngle)
	{
		return false;
	}
//	}
//	else
//	{
//		return false;	
//	}
	return true;
}

/* game/server/player_lagcompensation.cpp#L423 */
void BacktrackEntity(int entity, float currentTime) //Make sure that allies only get compensated for their bounding box.
{
	int ref = EntIndexToEntRef(entity);
	char refchar[12];
	IntToString(ref, refchar, sizeof(refchar));
	
	ArrayList list;
	if (!EntityTrack.GetValue(refchar, list))
	{
		return;
	}
	
	int length = list.Length;
	if (length < 1)
	{
		return;
	}
	
	LagRecord prevRecord;
	LagRecord record;

	float prevOrg[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", prevOrg);
	
	bool multi;
	for(int i=length-1; i>=0; i--)
	{
		// remember last record
		prevRecord = record;
		
		// get next record
		list.GetArray(i, record);
		
		/*float delta[3]
		SubtractVectors(record.m_vecOrigin, prevOrg, delta);
		if(Length2DSqr(delta) > m_flTeleportDistanceSqr)
		{
			// lost track, too much difference
			return; 
		}*/
		
		// did we find a context smaller than target time ?
		if(record.m_flSimulationTime <= currentTime)
			break; // hurra, stop
		
		prevOrg = record.m_vecOrigin;
		multi = true;
	}
	
	float frac = 0.0;
	float ang[3], org[3]; // minsPreScaled[3], maxsPreScaled[3];
	
	if(multi && record.m_flSimulationTime < currentTime && record.m_flSimulationTime < prevRecord.m_flSimulationTime)
	{
		// we didn't find the exact time but have a valid previous record
		// so interpolate between these two records;
		
		// calc fraction between both records
		frac = (currentTime - record.m_flSimulationTime) / (prevRecord.m_flSimulationTime - record.m_flSimulationTime);
		
		frac = clamp(frac, 0.000001, 0.999999); // should never extrapolate							LIT
		
		VectorLerp(record.m_vecAngles, prevRecord.m_vecAngles, frac, ang);
		VectorLerp(record.m_vecOrigin, prevRecord.m_vecOrigin, frac, org);
	//	VectorLerp(record.m_vecMinsPreScaled, prevRecord.m_vecMinsPreScaled, frac, minsPreScaled);
	//	VectorLerp(record.m_vecMaxsPreScaled, prevRecord.m_vecMaxsPreScaled, frac, maxsPreScaled);
	}
	else
	{
		// we found the exact record or no other record to interpolate with
		// just copy these values since they are the best we have
		ang = record.m_vecAngles;
		org = record.m_vecOrigin;
	//	minsPreScaled = record.m_vecMinsPreScaled;
	//	maxsPreScaled = record.m_vecMaxsPreScaled;
	}
	LagRecord restore;
				
//	GetEntPropVector(entity, Prop_Data, "m_vecMinsPreScaled", restore.m_vecMinsPreScaled);
//	GetEntPropVector(entity, Prop_Data, "m_vecMaxsPreScaled", restore.m_vecMaxsPreScaled);
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", restore.m_vecOrigin);
//	if(!b_LagCompAlliedPlayers)
	{
		GetEntPropVector(entity, Prop_Data, "m_angRotation", restore.m_vecAngles);
		if(!b_LagCompNPC_No_Layers && !b_IsAlliedNpc[entity])
		{	
			restore.m_masterSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
			restore.m_masterCycle = GetEntPropFloat(entity, Prop_Data, "m_flCycle");
			restore.m_flSimulationTime = GetEntPropFloat(entity, Prop_Data, "m_flSimulationTime");
		}
		if(b_LagCompNPC_ExtendBoundingBox)
		{
			if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
			{
				SetEntPropVector(entity, Prop_Data, "m_vecMaxsPreScaled", { 100.0, 100.0, 200.0 });
				SetEntPropVector(entity, Prop_Data, "m_vecMinsPreScaled", { -100.0, -100.0, 0.0 });
				
				
				CClotBody npc = view_as<CClotBody>(entity);
				npc.UpdateCollisionBox();
			}
		}
		SetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	}
	SDKCall_SetLocalOrigin(entity, org);
	
	/*
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	float tempRestore_1[3];
	tempRestore_1 = tempRestore;
	tempRestore[2] += 54.0;
	TE_SetupBeamPoints(tempRestore, tempRestore_1, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({0, 0, 255, 255}), 30);
	TE_SendToAll();
	
	//	SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime",record.m_flSimulationTime);
	float tempRestore[3];
	tempRestore[0] = 4676.0;
	tempRestore[1] = -3309.0;
	tempRestore[2] = 146.0;
	
	float tempRestore[3];
	tempRestore = restore.m_vecOrigin;
	tempRestore[2] += 54;
	
	float temporg[3];
	temporg = org;
	temporg[2] += 54;
	
	TE_SetupBeamPoints(restore.m_vecOrigin, tempRestore, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 0, 255}), 30);
	TE_SendToAll();
	
	TE_SetupBeamPoints(temporg, org, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({0, 0, 255, 255}), 30);
	TE_SendToAll();
	*/
	// If the master state changes, all layers will be invalid too, so don't interp (ya know, interp barely ever happens anyway)
//	if(!b_LagCompAlliedPlayers)
//	{
	if(!b_LagCompNPC_No_Layers && !b_IsAlliedNpc[entity])
	{
		bool interpolationAllowed = (multi && frac > 0.0 && record.m_masterSequence == prevRecord.m_masterSequence);
		
		if(interpolationAllowed)
		{
			SetEntProp(entity, Prop_Data, "m_nSequence", Lerpint(frac, record.m_masterSequence, prevRecord.m_masterSequence));
				
			if(record.m_masterCycle > prevRecord.m_masterCycle)
			{
				// the older record is higher in frame than the newer, it must have wrapped around from 1 back to 0
				// add one to the newer so it is lerping from .9 to 1.1 instead of .9 to .1, for example.
				float newCycle = Lerpfloat(frac, record.m_masterCycle, prevRecord.m_masterCycle + 1.0);
					
				if (newCycle<0.01)
					newCycle = 0.01;
				else if (newCycle>1.0)
					newCycle = 1.0;
					
				SetEntPropFloat(entity, Prop_Data, "m_flCycle", newCycle < 1.0 ? newCycle : newCycle - 1.0);// and make sure .9 to 1.2 does not end up 1.05
			}
			else
			{
				float newCycle = Lerpfloat(frac, record.m_masterCycle, prevRecord.m_masterCycle);
					
				if (newCycle<0.01)
					newCycle = 0.01;
				else if (newCycle>1.0)
					newCycle = 1.0;
					
				SetEntPropFloat(entity, Prop_Data, "m_flCycle", newCycle);
			}
		}
		else
		{
			SetEntProp(entity, Prop_Data, "m_nSequence", record.m_masterSequence);
			SetEntPropFloat(entity, Prop_Data, "m_flCycle", record.m_masterCycle);
		}
		////////////////////////
		// Now do all the layers
		if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
		{
			CBaseAnimatingOverlay overlay = CBaseAnimatingOverlay(entity);
			if(overlay.IsValid())
			{
				int layerCount = overlay.GetNumAnimOverlays();
				LayerRecord layer, recordsLayerRecord, prevRecordsLayerRecord;
				restore.m_layerRecords = new ArrayList(sizeof(LayerRecord));
				for(int i; i<layerCount; i++)
				{
					CAnimationLayer overlayLayer = overlay.GetAnimOverlay(i);

					layer.m_cycle = overlay.GetLayerCycle(i);
					layer.m_order = overlayLayer.m_nOrder;
					layer.m_sequence = overlay.GetLayerSequence(i);
					layer.m_weight = overlay.GetLayerWeight(i);
					restore.m_layerRecords.PushArray(layer);

					bool interpolated = false;
					if(interpolationAllowed &&
						i < record.m_layerRecords.Length && i < prevRecord.m_layerRecords.Length)	// TODO: Duct tape fix, find out of bounds array happens
					{
						
						record.m_layerRecords.GetArray(i, recordsLayerRecord);
						prevRecord.m_layerRecords.GetArray(i, prevRecordsLayerRecord);
						if(recordsLayerRecord.m_order == prevRecordsLayerRecord.m_order && recordsLayerRecord.m_sequence == prevRecordsLayerRecord.m_sequence)
						{
							// We can't interpolate across a sequence or order change
							interpolated = true;
							if(recordsLayerRecord.m_cycle > prevRecordsLayerRecord.m_cycle)
							{
								// the older record is higher in frame than the newer, it must have wrapped around from 1 back to 0
								// add one to the Lerpfloat so it is lerping from .9 to 1.1 instead of .9 to .1, for example.
								float newCycle = Lerpfloat(frac, recordsLayerRecord.m_cycle, prevRecordsLayerRecord.m_cycle + 1.0);
								overlay.SetLayerCycle(i, newCycle < 1.0 ? newCycle : newCycle - 1.0);
							}
							else
							{
								overlay.SetLayerCycle(i, Lerpfloat(frac, recordsLayerRecord.m_cycle, prevRecordsLayerRecord.m_cycle));
							}
							
							overlayLayer.m_nOrder = recordsLayerRecord.m_order;
							overlayLayer.m_nSequence = recordsLayerRecord.m_sequence;
							overlay.SetLayerWeight(i, Lerpfloat(frac, recordsLayerRecord.m_weight, prevRecordsLayerRecord.m_weight));
						}
					}
						
					if(!interpolated)
					{
						//Either no interp, or interp failed.  Just use record.
						overlay.SetLayerCycle(i, layer.m_cycle);
						overlayLayer.m_nOrder = layer.m_order;
						overlayLayer.m_nSequence = layer.m_sequence;
						overlay.SetLayerWeight(i, layer.m_weight);
					}
				}
			}
		}
	}
	SDKCall_InvalidateBoneCache(entity); //Do at all times, yes, ew but i have to,
	EntityRestore.SetArray(refchar, restore, sizeof(restore));
}

void FinishLagCompensation_Base_boss(/*DHookParam param*/)
//public MRESReturn FinishLagCompensation(Address manager, DHookParam param)
{
	if(DoingLagCompensation)
	{
		DoingLagCompensation = false;
	//	SetEntProp(CurrentPlayer, Prop_Data, "m_bLagCompensation", true, 1);
		
		char refchar[12];
		LagRecord restore;
		LayerRecord layer;
		for(int entitycount; entitycount<i_Maxcount_Apply_Lagcompensation; entitycount++)
		{
			int entity = EntRefToEntIndex(i_Objects_Apply_Lagcompensation[entitycount]);
			if(IsValidEntity(entity))
			{
				IntToString(EntIndexToEntRef(entity), refchar, sizeof(refchar));
				if(EntityRestore.GetArray(refchar, restore, sizeof(restore)))
				{
					if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
					{
						if(b_LagCompNPC_ExtendBoundingBox)
						{
							static float m_vecMaxs[3];
							static float m_vecMins[3];
							m_vecMaxs = view_as<float>( { 1.0, 1.0, 2.0 } );
							m_vecMins = view_as<float>( { -1.0, -1.0, 0.0 } );		
							
							SetEntPropVector(entity, Prop_Data, "m_vecMinsPreScaled", m_vecMins);
							
							SetEntPropVector(entity, Prop_Data, "m_vecMaxsPreScaled", m_vecMaxs);
							
							CClotBody npc = view_as<CClotBody>(entity);
							npc.UpdateCollisionBox();
							
							if(b_BoundingBoxVariant[entity] == 1)
							{
								m_vecMaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
								m_vecMins = view_as<float>( { -30.0, -30.0, 0.0 } );	
							}			
							else
							{
								m_vecMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
								m_vecMins = view_as<float>( { -24.0, -24.0, 0.0 } );		
							}

							if(f3_CustomMinMaxBoundingBox[entity][1] != 0.0)
							{
								m_vecMaxs[0] = f3_CustomMinMaxBoundingBox[entity][0];
								m_vecMaxs[1] = f3_CustomMinMaxBoundingBox[entity][1];
								m_vecMaxs[2] = f3_CustomMinMaxBoundingBox[entity][2];

								m_vecMins[0] = -f3_CustomMinMaxBoundingBox[entity][0];
								m_vecMins[1] = -f3_CustomMinMaxBoundingBox[entity][1];
								m_vecMins[2] = 0.0;
							}

							SetEntPropVector(entity, Prop_Data, "m_vecMaxs", m_vecMaxs);
							SetEntPropVector(entity, Prop_Data, "m_vecMins", m_vecMins);
						}
					}
					SetEntPropVector(entity, Prop_Data, "m_angRotation", restore.m_vecAngles); //See start pos on why we use this instead of the SDKCall
					SDKCall_SetLocalOrigin(entity, restore.m_vecOrigin);
					if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity])
					{
						if(!b_LagCompNPC_No_Layers && !b_IsAlliedNpc[entity])
						{
							SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", restore.m_flSimulationTime);
							SetEntProp(entity, Prop_Data, "m_nSequence", restore.m_masterSequence);
							SetEntPropFloat(entity, Prop_Data, "m_flCycle", restore.m_masterCycle);
							CBaseAnimatingOverlay overlay = CBaseAnimatingOverlay(entity);
							if(overlay.IsValid())
							{
								int layerCount = overlay.GetNumAnimOverlays();
								for(int i; i<layerCount; i++)
								{
									restore.m_layerRecords.GetArray(i, layer);
									CAnimationLayer currentLayer = overlay.GetAnimOverlay(i); 
									currentLayer.m_flCycle = layer.m_cycle;
									currentLayer.m_nOrder = layer.m_order;
									currentLayer.m_nSequence = layer.m_sequence;
									currentLayer.m_flWeight = layer.m_weight;
								}
							}
							delete restore.m_layerRecords;
						}
					}
					EntityRestore.Remove(refchar);
				}
			}
		}
	}
	StartLagCompResetValues();
}

/* game/server/player_lagcompensation.cpp#L233 */
//-----------------------------------------------------------------------------
// Purpose: Called once per frame after all entities have had a chance to think
//-----------------------------------------------------------------------------
void LagCompensationThink_Forward()
{
//	if(sv_unlag.BoolValue) //This isnt needed as itsa utomatic
	{
		// remove all records before that time:
		float deadTime = GetGameTime() - sv_maxunlag.FloatValue;
		char refchar[12];
		ArrayList list;
		LagRecord record;
		LayerRecord layer;
		// Iterate all active NPCs
		for(int entitycount; entitycount<i_Maxcount_Apply_Lagcompensation; entitycount++)
		{
			int entity = EntRefToEntIndex(i_Objects_Apply_Lagcompensation[entitycount]);
			if(IsValidEntity(entity))
			{
				if(b_LagCompensationDeletedArrayList[entity]) //Is the npc dead?
				{
					b_EntityIsLagComp[entity] = true;
					continue; //This npc has died. We reset it to be sure and dont keep tracking it.
				}
				b_EntityIsLagComp[entity] = true;
				
				IntToString(EntIndexToEntRef(entity), refchar, sizeof(refchar));
				if(!EntityTrack.GetValue(refchar, list))
				{
					list = new ArrayList(sizeof(LagRecord));
					EntityTrack.SetValue(refchar, list);
					continue; // give a frame to spawn in before we do anything
				}
				
				// remove tail records that are too old
				int length = list.Length;
				while(length)
				{
					list.GetArray(0, record);
					
					// if tail is within limits, stop
					if(record.m_flSimulationTime >= deadTime)
						break;
					
					// remove tail, get new tail
					delete record.m_layerRecords;
					list.Erase(0);
					length--;
				}
				
				// check if head has same simulation time
				if(length)
				{
					list.GetArray(length-1, record);
					
					// check if player changed simulation time since last time updated
					if(record.m_flSimulationTime >= GetEntPropFloat(entity, Prop_Data, "m_flSimulationTime"))
						continue; // don't add new entry for same or older time
				}
				
				CBaseAnimatingOverlay overlay = CBaseAnimatingOverlay(entity);
				if(overlay.IsValid())
				{
					// add new record to player track
					record.m_flSimulationTime	= GetEntPropFloat(entity, Prop_Data, "m_flSimulationTime");
					GetEntPropVector(entity, Prop_Data, "m_angRotation", record.m_vecAngles);
					GetEntPropVector(entity, Prop_Data, "m_vecOrigin", record.m_vecOrigin);

					if(!b_Map_BaseBoss_No_Layers[entity] && !b_IsAlliedNpc[entity]) //If its an allied baseboss, make sure to not get layers.
					{
						record.m_layerRecords = new ArrayList(sizeof(LayerRecord));
						int layerCount = overlay.GetNumAnimOverlays();
						for(int i = 0; i < layerCount; i++)
						{
							CAnimationLayer overlayLayer = overlay.GetAnimOverlay(i);
							
							layer.m_cycle = overlay.GetLayerCycle(i);
							layer.m_order = overlayLayer.IsAlive() ? overlayLayer.m_nOrder : 0;
							layer.m_sequence = overlay.GetLayerSequence(i);
							layer.m_weight = overlay.GetLayerWeight(i);
							record.m_layerRecords.PushArray(layer);
						}
						record.m_masterSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
						record.m_masterCycle = GetEntPropFloat(entity, Prop_Data, "m_flCycle");
					}
					else
					{
						record.m_layerRecords = null;
					}

					list.PushArray(record);
				}
			}
		}
	}
}

/* public/mathlib/vector.h#L1153 */
void VectorLerp(const float src1[3], const float src2[3], float t, float dest[3])
{
	dest[0] = src1[0] + (src2[0] - src1[0]) * t;
	dest[1] = src1[1] + (src2[1] - src1[1]) * t;
	dest[2] = src1[2] + (src2[2] - src1[2]) * t;
}

/* game/client/particle_util.h#L19 */
float Lerpfloat(float t, float minVal, float maxVal)
{
	return minVal + (maxVal - minVal) * t;
}

int Lerpint(float t, int minVal, int maxVal)
{
	return RoundToNearest(minVal + float((maxVal - minVal)) * t);
}

/*  */
/*  */
/*
stock float fabs(float value)
{
	return value < 0 ? -value : value;
}
*/

void AddEntityToLagCompList(int entity)
{
	b_EntityIsLagComp[entity] = true;
	for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Make them lag compensate
	{
		if (EntRefToEntIndex(i_Objects_Apply_Lagcompensation[i]) <= 0)
		{
			i_Objects_Apply_Lagcompensation[i] = EntIndexToEntRef(entity);
			i = ZR_MAX_LAG_COMP;
		}
	}	
}