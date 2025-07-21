#pragma semicolon 1
#pragma newdecls required

/* engine/host.h#L157-L158 */
#define TIME_TO_TICKS(%1)	RoundToZero(0.5 + %1 / GetTickInterval())
#define TICKS_TO_TIME(%1)	(GetTickInterval() * float(%1))

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
	int						m_sequence[10];
	float					m_cycle[10];
	float					m_weight[10];
	int						m_order[10];
	int						m_layerRecords;

	int						m_masterSequence;
	float					m_masterCycle;
}

static ConVar sv_maxunlag;

static int TickCount[MAXPLAYERS];
static float ViewAngles[MAXPLAYERS][3];
// EntityTrack should only confine the max ticks on the server, alter this value for your server's
static LagRecord EntityTrack[ZR_MAX_LAG_COMP][67];
static int EntityTrackCount[ZR_MAX_LAG_COMP];
static LagRecord EntityRestore[ZR_MAX_LAG_COMP];
static LagRecord EntityRestoreSave[ZR_MAX_LAG_COMP];
static bool WasBackTracked[ZR_MAX_LAG_COMP];

static int i_Objects_Apply_Lagcompensation[ZR_MAX_LAG_COMP];

void OnPluginStart_LagComp()
{
	sv_maxunlag = FindConVar("sv_maxunlag");
}

void OnPlayerRunCmd_Lag_Comp(int client, float angles[3], int &tickcount)
{
	TickCount[client] = tickcount;
	ViewAngles[client] = angles;
}

/* game/server/player_lagcompensation.cpp#L328 */
void StartLagCompensation_Base_Boss(int client)
{
	if(DoingLagCompensation)
	{
		PrintToChatAll("Was already in DoingLagCompensation But tried doing another?");
		FinishLagCompensation_Base_boss(-1, false);
	}
	DoingLagCompensation = true;
//	PrintToChatAll("StartLagCompensation_Base_Boss");
	
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

	for(int index; index < ZR_MAX_LAG_COMP; index++)
	{
		int entity = EntRefToEntIndexFast(i_Objects_Apply_Lagcompensation[index]);
		if(IsValidEntity(entity))
		{
			// Custom checks for if things should lag compensate (based on things like what team the player is on).
			if(!WantsLagCompensationOnEntity(entity, client, ViewAngles[client]/*, pEntityTransmitBits*/))
				continue;

			// Move other NPCs back in time
			BacktrackEntity(entity, index, TICKS_TO_TIME(targettick));
		}
	}
}

/* game/server/player.cpp#L732 */
static bool WantsLagCompensationOnEntity(int entity, int player, const float viewangles[3]/*, const CBitVec<MAX_EDICTS> *pEntityTransmitBits */)
{
	// Team members shouldn't be adjusted unless friendly fire is on.
	/*
	if(!mp_friendlyfire.BoolValue && GetClientTeam(player) == GetTeam(entity))
		return false;
	*/
	// If this entity hasn't been transmitted to us and acked, then don't bother lag compensating it.
	//if ( pEntityTransmitBits && !pEntityTransmitBits.Get( pPlayer.entindex() ) )
	//	return false;

#if defined RTS
	bool allied = RTS_CanControl(player, entity);
#else
	bool allied = GetTeam(entity) == GetTeam(player);
#endif
	
	if(b_LagCompNPC_OnlyAllies ^ allied)
	{
		if(!b_DoNotIgnoreDuringLagCompAlly[entity])
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
	return true;
}

/* game/server/player_lagcompensation.cpp#L423 */
static void BacktrackEntity(int entity, int index, float currentTime) //Make sure that allies only get compensated for their bounding box.
{
	if(EntityTrackCount[index] < 1)
	{
		return;
	}
	if(WasBackTracked[index])
	{
		//they were already compensated, do not.
		return;
	}
	
	LagRecord prevRecord;
	LagRecord record;

	float prevOrg[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", prevOrg);
	
	bool multi;
	for(int i = EntityTrackCount[index] - 1; i >= 0; i--)
	{
		// remember last record
		prevRecord = record;
		
		// get next record
		record = EntityTrack[index][i];
		
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
	}
	else
	{
		// we found the exact record or no other record to interpolate with
		// just copy these values since they are the best we have
		ang = record.m_vecAngles;
		org = record.m_vecOrigin;
	}
	
	
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", EntityRestore[index].m_vecOrigin);
	GetEntPropVector(entity, Prop_Data, "m_angRotation", EntityRestore[index].m_vecAngles);
	EntityRestore[index].m_flSimulationTime = GetEntPropFloat(entity, Prop_Data, "m_flSimulationTime");

#if defined RTS
	if(!b_LagCompNPC_No_Layers)
#else
	if(!b_LagCompNPC_No_Layers && GetTeam(entity) != TFTeam_Red)
#endif
	{	
		EntityRestore[index].m_masterSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
		EntityRestore[index].m_masterCycle = GetEntPropFloat(entity, Prop_Data, "m_flCycle");
	}

	if(b_LagCompNPC_ExtendBoundingBox)
	{

#if defined ZR
		if(GetTeam(entity) != TFTeam_Red)
#endif
		{
			SetEntPropVector(entity, Prop_Data, "m_vecMaxsPreScaled", { 100.0, 100.0, 200.0 });
			SetEntPropVector(entity, Prop_Data, "m_vecMinsPreScaled", { -100.0, -100.0, 0.0 });
			
			CClotBody npc = view_as<CClotBody>(entity);
			npc.UpdateCollisionBox();
		}
	}

	SDKCall_SetLocalOrigin(entity, org);
	SetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
	SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", record.m_flSimulationTime);

	EntityRestoreSave[index].m_vecOrigin = org;
	EntityRestoreSave[index].m_vecAngles = ang;
//	EntityRestoreSave[index].m_flSimulationTime = GetEntPropFloat(entity, Prop_Data, "m_flSimulationTime");
	
#if defined RTS
	if(!b_LagCompNPC_No_Layers)
#else
	if(!b_LagCompNPC_No_Layers && GetTeam(entity) != TFTeam_Red)
#endif
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
#if defined RTS
		if(GetTeam(entity) != TFTeam_Red)
#endif
		{
			CBaseAnimatingOverlay overlay = CBaseAnimatingOverlay(entity);
			if(overlay.IsValid())
			{
				EntityRestore[index].m_layerRecords = overlay.GetNumAnimOverlays();
				if(EntityRestore[index].m_layerRecords >= sizeof(EntityRestore[].m_sequence))
					EntityRestore[index].m_layerRecords = sizeof(EntityRestore[].m_sequence) - 1;
				
				for(int i; i < EntityRestore[index].m_layerRecords; i++)
				{
					CAnimationLayer overlayLayer = overlay.GetAnimOverlay(i);

					EntityRestore[index].m_cycle[i] = overlay.GetLayerCycle(i);
					EntityRestore[index].m_order[i] = overlayLayer.m_nOrder;
					EntityRestore[index].m_sequence[i] = overlay.GetLayerSequence(i);
					EntityRestore[index].m_weight[i] = overlay.GetLayerWeight(i);

					bool interpolated = false;
					if(interpolationAllowed &&
						i < record.m_layerRecords && i < prevRecord.m_layerRecords)
					{
						if(record.m_order[i] == prevRecord.m_order[i] && record.m_sequence[i] == prevRecord.m_sequence[i])
						{
							// We can't interpolate across a sequence or order change
							interpolated = true;
							if(record.m_cycle[i] > prevRecord.m_cycle[i])
							{
								// the older record is higher in frame than the newer, it must have wrapped around from 1 back to 0
								// add one to the Lerpfloat so it is lerping from .9 to 1.1 instead of .9 to .1, for example.
								float newCycle = Lerpfloat(frac, record.m_cycle[i], prevRecord.m_cycle[i] + 1.0);
								overlay.SetLayerCycle(i, newCycle < 1.0 ? newCycle : newCycle - 1.0);
							}
							else
							{
								overlay.SetLayerCycle(i, Lerpfloat(frac, record.m_cycle[i], prevRecord.m_cycle[i]));
							}
							
							overlayLayer.m_nOrder = record.m_order[i];
							overlayLayer.m_nSequence = record.m_sequence[i];
							overlay.SetLayerWeight(i, Lerpfloat(frac, record.m_weight[i], prevRecord.m_weight[i]));
						}
					}
						
					if(!interpolated)
					{
						//Either no interp, or interp failed.  Just use record.
						overlay.SetLayerCycle(i, record.m_cycle[i]);
						overlayLayer.m_nOrder = record.m_order[i];
						overlayLayer.m_nSequence = record.m_sequence[i];
						overlay.SetLayerWeight(i, record.m_weight[i]);
					}

					EntityRestoreSave[index].m_cycle[i] = overlay.GetLayerCycle(i);
					EntityRestoreSave[index].m_order[i] = overlayLayer.m_nOrder;
					EntityRestoreSave[index].m_sequence[i] = overlay.GetLayerSequence(i);
					EntityRestoreSave[index].m_weight[i] = overlay.GetLayerWeight(i);
				}
			}
		}
		EntityRestoreSave[index].m_masterSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
		EntityRestoreSave[index].m_masterCycle = GetEntPropFloat(entity, Prop_Data, "m_flCycle");
	}

	//only invalidate when we actually update the bones, otherwise there is no reason to do this.
	//if this bool is on, then that means whateverhappens only goes for position or collision box.
	//if the code needs the bones for any reason, then simply enable this bool when doing the compensation.
	if(!b_LagCompNPC_No_Layers)
		SDKCall_InvalidateBoneCache(entity);
	
	WasBackTracked[index] = true;
}

void FinishLagCompensation_Base_boss(int ForceOptionalEntity = -2, bool DoReset = true)
{
	
	if(ForceOptionalEntity == -2)
		DoingLagCompensation = false;

	for(int index; index < ZR_MAX_LAG_COMP; index++)
	{
		int entity = EntRefToEntIndexFast(i_Objects_Apply_Lagcompensation[index]);
		//if its a selected entity:
		if(ForceOptionalEntity != -2)
		{
			if(entity != ForceOptionalEntity)
				continue;
		}
		if(!WasBackTracked[index])
		{
			if(ForceOptionalEntity == entity)
				return;

			continue;
		}


		WasBackTracked[index] = false;
		if(!IsValidEntity(entity))
		{ 	
			if(ForceOptionalEntity == entity)
				return;

			continue;
		}

#if defined ZR
		if(GetTeam(entity) != TFTeam_Red)
#endif
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
					
					if(f3_CustomMinMaxBoundingBoxMinExtra[entity][1] != 0.0)
					{
						m_vecMins[0] = f3_CustomMinMaxBoundingBoxMinExtra[entity][0];
						m_vecMins[1] = f3_CustomMinMaxBoundingBoxMinExtra[entity][1];
						m_vecMins[2] = f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
					}
					else
					{
						m_vecMins[0] = -f3_CustomMinMaxBoundingBox[entity][0];
						m_vecMins[1] = -f3_CustomMinMaxBoundingBox[entity][1];
						m_vecMins[2] = 0.0;
					}

				}

				SetEntPropVector(entity, Prop_Data, "m_vecMaxs", m_vecMaxs);
				SetEntPropVector(entity, Prop_Data, "m_vecMins", m_vecMins);
			}
		}
		static float OriginGet[3];
		static float AngGet[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", OriginGet);
		GetEntPropVector(entity, Prop_Data, "m_angRotation", AngGet);
		
		if(AreVectorsEqual(OriginGet, EntityRestoreSave[index].m_vecOrigin))
			SDKCall_SetLocalOrigin(entity, EntityRestore[index].m_vecOrigin);
		

		if(AreVectorsEqual(AngGet, EntityRestoreSave[index].m_vecAngles))
			SetEntPropVector(entity, Prop_Data, "m_angRotation", EntityRestore[index].m_vecAngles); //See start pos on why we use this instead of the SDKCall
		
		SetEntPropFloat(entity, Prop_Data, "m_flSimulationTime", EntityRestore[index].m_flSimulationTime);
			
		if(!b_LagCompNPC_No_Layers && GetTeam(entity) != TFTeam_Red)
		{
			int CurrentSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
			if(CurrentSequence == EntityRestoreSave[index].m_masterSequence) //They didnt update sequence?
			{
				SetEntProp(entity, Prop_Data, "m_nSequence", EntityRestore[index].m_masterSequence);
				SetEntPropFloat(entity, Prop_Data, "m_flCycle", EntityRestore[index].m_masterCycle);

			}
			
			if(EntityRestore[index].m_layerRecords)
			{
				CBaseAnimatingOverlay overlay = CBaseAnimatingOverlay(entity);
				if(overlay.IsValid())
				{
					int layerCount = overlay.GetNumAnimOverlays();
					if(layerCount >= EntityRestore[index].m_layerRecords)
						layerCount = EntityRestore[index].m_layerRecords - 1;
					
					for(int i; i < layerCount; i++)
					{
						CAnimationLayer currentLayer = overlay.GetAnimOverlay(i); 
	
						if(currentLayer.m_flCycle == EntityRestoreSave[index].m_cycle[i])
							currentLayer.m_flCycle = EntityRestore[index].m_cycle[i];

						if(currentLayer.m_nOrder == EntityRestoreSave[index].m_order[i])
							currentLayer.m_nOrder = EntityRestore[index].m_order[i];

						if(currentLayer.m_nSequence == EntityRestoreSave[index].m_sequence[i])
							currentLayer.m_nSequence = EntityRestore[index].m_sequence[i];

						if(currentLayer.m_flWeight == EntityRestoreSave[index].m_weight[i])
							currentLayer.m_flWeight = EntityRestore[index].m_weight[i];
					}
				}
			}
		}

		WasBackTracked[index] = false;
		//we only wanted to lag comp this entity, were done.
		if(ForceOptionalEntity == entity)
			return;
	}

	if(ForceOptionalEntity == -2 && DoReset)
		StartLagCompResetValues();
}

/* game/server/player_lagcompensation.cpp#L233 */
//-----------------------------------------------------------------------------
// Purpose: Called once per frame after all entities have had a chance to think
//-----------------------------------------------------------------------------
void LagCompensationThink_Forward()
{
	// remove all records before that time:
	float deadTime = GetGameTime() - sv_maxunlag.FloatValue;
	LagRecord record;

	// Iterate all active NPCs
	for(int index; index < ZR_MAX_LAG_COMP; index++)
	{
		int entity = EntRefToEntIndexFast(i_Objects_Apply_Lagcompensation[index]);
		if(IsValidEntity(entity))
		{
			if(EntityTrackCount[index] < 0)
			{
				EntityTrackCount[index]++;
				continue; // give a frame to spawn in before we do anything
			}
			
			// remove tail records that are too old
			while(EntityTrackCount[index])
			{
				// if tail is within limits, stop, only record at max 1 seconds, either max tickrate, or max of 66 ticks
				if((EntityTrackCount[index] < (TickrateModifyInt - 1) || EntityTrackCount[index] < (sizeof(EntityTrack[]) - 1)) &&
				   EntityTrack[index][0].m_flSimulationTime >= deadTime)
					break;
				
				// remove tail, get new tail
				for(int i = 1; i < EntityTrackCount[index]; i++)
				{
					EntityTrack[index][i - 1] = EntityTrack[index][i];
				}

				EntityTrackCount[index]--;
			}
			
			// check if head has same simulation time
			if(EntityTrackCount[index])
			{
				record = EntityTrack[index][EntityTrackCount[index] - 1];
				
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
#if defined ZR
				if(GetTeam(entity) != TFTeam_Red) //If its an allied entity, dont get layers, dont alter them a its never used.
#endif
				{
					record.m_layerRecords = overlay.GetNumAnimOverlays();
					if(record.m_layerRecords >= sizeof(record.m_sequence))
						record.m_layerRecords = sizeof(record.m_sequence) - 1;
					
					for(int i = 0; i < record.m_layerRecords; i++)
					{
						CAnimationLayer overlayLayer = overlay.GetAnimOverlay(i);
						
						record.m_cycle[i] = overlay.GetLayerCycle(i);
						record.m_order[i] = overlayLayer.IsAlive() ? overlayLayer.m_nOrder : 0;
						record.m_sequence[i] = overlay.GetLayerSequence(i);
						record.m_weight[i] = overlay.GetLayerWeight(i);
					}

					record.m_masterSequence = GetEntProp(entity, Prop_Data, "m_nSequence");
					record.m_masterCycle = GetEntPropFloat(entity, Prop_Data, "m_flCycle");
				}
#if defined ZR
				else
				{
					record.m_layerRecords = 0;
				}
#endif

				EntityTrack[index][EntityTrackCount[index]] = record;
				EntityTrackCount[index]++;
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
	for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Make them lag compensate
	{
		if (EntRefToEntIndexFast(i_Objects_Apply_Lagcompensation[i]) <= 0)
		{
			EntityTrackCount[i] = -1;
			i_Objects_Apply_Lagcompensation[i] = EntIndexToEntRef(entity);
			WasBackTracked[i] = false;
			break;
		}
	}
}

void RemoveEntityToLagCompList(int entity)
{
	for (int i = 0; i < ZR_MAX_LAG_COMP; i++) //Remove lag comp
	{
		if (EntRefToEntIndexFast(i_Objects_Apply_Lagcompensation[i]) == entity)
		{
			i_Objects_Apply_Lagcompensation[i] = -1;
			WasBackTracked[i] = false;
			break;
		}
	}	
}