#if defined _PathFollower_Nav_included
#endinput
#endif
#define _PathFollower_Nav_included

#pragma newdecls required


#define TEAM_INVALID -1
#define TEAM_ANY     -2


enum NavArea
{
	NavArea_Null = 0x00000000,
};

enum NavCornerType
{
	NORTH_WEST = 0,
	NORTH_EAST = 1,
	SOUTH_EAST = 2,
	SOUTH_WEST = 3,

	NUM_CORNERS
};

enum NavDirType
{
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3,

	NUM_DIRECTIONS
};

enum NavAttributeType
{
	NAV_MESH_INVALID		= 0,
	NAV_MESH_CROUCH			= 0x00000001,	// must crouch to use this node/area
	NAV_MESH_JUMP			= 0x00000002,	// must jump to traverse this area (only used during generation)
	NAV_MESH_PRECISE		= 0x00000004,	// do not adjust for obstacles, just move along area
	NAV_MESH_NO_JUMP		= 0x00000008,	// inhibit discontinuity jumping
	NAV_MESH_STOP			= 0x00000010,	// must stop when entering this area
	NAV_MESH_RUN			= 0x00000020,	// must run to traverse this area
	NAV_MESH_WALK			= 0x00000040,	// must walk to traverse this area
	NAV_MESH_AVOID			= 0x00000080,	// avoid this area unless alternatives are too dangerous
	NAV_MESH_TRANSIENT		= 0x00000100,	// area may become blocked, and should be periodically checked
	NAV_MESH_DONT_HIDE		= 0x00000200,	// area should not be considered for hiding spot generation
	NAV_MESH_STAND			= 0x00000400,	// bots hiding in this area should stand
	NAV_MESH_NO_HOSTAGES	= 0x00000800,	// hostages shouldn't use this area
	NAV_MESH_STAIRS			= 0x00001000,	// this area represents stairs, do not attempt to climb or jump them - just walk up
	NAV_MESH_NO_MERGE		= 0x00002000,	// don't merge this area with adjacent areas
	NAV_MESH_OBSTACLE_TOP	= 0x00004000,	// this nav area is the climb point on the tip of an obstacle
	NAV_MESH_CLIFF			= 0x00008000,	// this nav area is adjacent to a drop of at least CliffHeight

	NAV_MESH_FIRST_CUSTOM	= 0x00010000,	// apps may define custom app-specific bits starting with this value
	NAV_MESH_LAST_CUSTOM	= 0x04000000,	// apps must not define custom app-specific bits higher than with this value

	NAV_MESH_FUNC_COST		= 0x20000000,	// area has designer specified cost controlled by func_nav_cost entities
	NAV_MESH_HAS_ELEVATOR	= 0x40000000,	// area is in an elevator's path
	NAV_MESH_NAV_BLOCKER	= 0x80000000	// area is blocked by nav blocker ( Alas, needed to hijack a bit in the attributes to get within a cache line [7/24/2008 tom])
};

enum TFNavAttributeType
{
	BLOCKED                     = (1 << 0),
	RED_SPAWN_ROOM              = (1 << 1),
	BLUE_SPAWN_ROOM             = (1 << 2),
	SPAWN_ROOM_EXIT             = (1 << 3),
	AMMO                        = (1 << 4),
	HEALTH                      = (1 << 5),
	CONTROL_POINT               = (1 << 6),
	BLUE_SENTRY                 = (1 << 7),
	RED_SENTRY                  = (1 << 8),
	/* bit  9: unused */
	/* bit 10: unused */
	BLUE_SETUP_GATE             = (1 << 11),
	RED_SETUP_GATE              = (1 << 12),
	BLOCKED_AFTER_POINT_CAPTURE = (1 << 13),
	BLOCKED_UNTIL_POINT_CAPTURE = (1 << 14),
	BLUE_ONE_WAY_DOOR           = (1 << 15),
	RED_ONE_WAY_DOOR            = (1 << 16),
	WITH_SECOND_POINT           = (1 << 17),
	WITH_THIRD_POINT            = (1 << 18),
	WITH_FOURTH_POINT           = (1 << 19),
	WITH_FIFTH_POINT            = (1 << 20),
	SNIPER_SPOT                 = (1 << 21),
	SENTRY_SPOT                 = (1 << 22),
	/* bit 23: unused */
	/* bit 24: unused */
	NO_SPAWNING                 = (1 << 25),
	RESCUE_CLOSET               = (1 << 26),
	BOMB_DROP                   = (1 << 27),
	DOOR_NEVER_BLOCKS           = (1 << 28),
	DOOR_ALWAYS_BLOCKS          = (1 << 29),
	UNBLOCKABLE                 = (1 << 30),
	/* bit 31: unused */
};

methodmap NavArea
{
	//Return this area's unique ID
	public native int GetID();

	//Returns the center most vector point for the given CNavArea.
	public native void GetCenter(float out[3]);

	//Returns a random point on the nav area.
	public native void GetRandomPoint(float out[3]);

	//Return Z of area at (x,y) of 'pos'
	public native float GetZ(float x, float y);
	
	//Internal function used when generating a path from one point to another in PathFollower::Compute; The cost so far.
	public native float GetCostSoFar();
	
	//Return height change between edges of adjacent nav areas (not actual underlying ground)
	public native float ComputeAdjacentConnectionHeightChange(NavArea destinationArea);

	//Returns true if the given CNavArea has this attribute flag set.
	public native bool HasAttributes(NavAttributeType bits);

	//Return number of players of given team currently within this area (team of zero means any/all)
	//BUG counts spectators.
	//BUG weird
	//I think you want to subtract 1 from GetClientTeam for this
	public native int GetPlayerCount(int teamID = TEAM_ANY);

	//Computes the area's normal based on m_nwCorner.  If 'alternate' is specified, m_seCorner is used instead.
	public native void ComputeNormal(float out[3], bool alternate = false);

	//Returns the vector position of the corner for the given CNavArea.
	public native void GetCorner(float out[3], NavCornerType corner);
	
	//Return true if area is visible from the given eyepoint, returns visible spot in visSpot param.
	public bool IsVisible(float eye[3], float visSpot[3] = NULL_VECTOR)
	{
		float offset = 0.75 * 71;
	
		float center[3]; this.GetCenter(center); center[2] += offset;
		
		// check center first
		Handle result = TR_TraceRayEx(eye, center, MASK_OPAQUE|CONTENTS_MONSTER, RayType_EndPoint);
		
		if (TR_GetFraction(result) == 1.0)
		{
			// we can see this area
			if (!IsNullVector(visSpot))
			{
				this.GetCenter(visSpot);
			}
			
			delete result;
			return true;
		}
		
		delete result;
		
		float corner[3];
		
		for(NavCornerType c = NORTH_WEST; c < NUM_CORNERS; ++c)
		{
			this.GetCorner(corner, c);
			corner[2] += offset;
			
			result = TR_TraceRayEx(eye, corner, MASK_OPAQUE|CONTENTS_MONSTER, RayType_EndPoint);
			
			if (TR_GetFraction(result) == 1.0)
			{
				// we can see this area
				if (!IsNullVector(visSpot))
				{
					visSpot = corner;
				}
				
				delete result;
				return true;
			}
			
			delete result;
		}
		
		delete result;
		return false;
	}

	//Returns the amount of CNavAreas that have a connection ( one or two way ) from this CNavArea in given direction.
	public native int GetAdjacentCount(NavDirType dir);

	//Return the i'th adjacent area in the given direction
	public native NavArea GetAdjacentArea(NavDirType dir, int i);
};


enum NavMesh
{
	TheNavMesh
};

methodmap NavMesh
{
	public native NavArea GetNavArea_Vec(const float pos[3], float beneathLimit = 120.0);
	
	public native NavArea GetNearestNavArea_Vec(const float pos[3], bool anyZ = false, float maxDist = 10000.0, bool checkLOS = false, bool checkGround = true, int team = TEAM_ANY);
	
//	public native int CollectSurroundingAreas(int nearbyAreasMax, NavArea[] nearbyAreas, NavArea startArea, float travelDistanceLimit = 1500.0, float maxStepUpLimit = 18.0, float maxDropDownLimit = 100.0);
};
/*
stock float GetCombatIntensity(NavArea area)
{
   	Address Area = view_as<Address>(area);
   	
	float m_timestamp = view_as<float>(LoadFromAddress(Area + view_as<Address>(0x214), NumberType_Int32));
	float m_startTime = view_as<float>(LoadFromAddress(Area + view_as<Address>(0x218), NumberType_Int32));

	float tf_nav_combat_decay_rate = FindConVar("tf_nav_combat_decay_rate").FloatValue;
	return Max(m_timestamp - ((GetGameTime() - m_startTime) * tf_nav_combat_decay_rate), 0.0);
}

stock bool IsInCombat(NavArea area)
{
	return GetCombatIntensity(area) > 0.01;
}
*/
stock bool HasTFAttributes(NavArea area, TFNavAttributeType bits)
{
	TFNavAttributeType attributes = view_as<TFNavAttributeType>(LoadFromAddress(view_as<Address>(area) + view_as<Address>(0x1C0), NumberType_Int32));
	
	return ((view_as<int>(attributes) & view_as<int>(bits)) != 0);
}


/* EXAMPLE USAGE

float center[3];
area.GetCenter(center);

float cost = area.GetCostSoFar();

float delta_z = area.ComputeAdjacentConnectionHeightChange(destArea);


float pos[3];
NavArea area = TheNavMesh.GetNavArea_Vec(pos);

float pos[3];
NavArea area = TheNavMesh.GetNearestNavArea_Vec(pos);

*/
