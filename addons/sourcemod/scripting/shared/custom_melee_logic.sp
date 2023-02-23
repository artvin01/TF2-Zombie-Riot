#pragma semicolon 1
#pragma newdecls required

static const char g_KnifeHitFlesh[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_KnifeHitWorld[][] = {
	"weapons/blade_hitworld.wav",
};

static const char g_UberSawHitFlesh[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};

static const char g_DefaultHitWorld[][] = {
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav",
};

static const char g_DefaultHitFlesh[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_ThirdDegreeHitWorld[][] = {
	"weapons/3rd_degree_hit_world_01.wav",
	"weapons/3rd_degree_hit_world_02.wav",
	"weapons/3rd_degree_hit_world_03.wav",
	"weapons/3rd_degree_hit_world_04.wav",
	
};

static const char g_ThirdDegreeHitFlesh[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/3rd_degree_hit_02.wav",
	"weapons/3rd_degree_hit_03.wav",
	"weapons/3rd_degree_hit_04.wav",
};

static const char g_SwordHitWorld[][] = {
	"weapons/demo_sword_hit_world1.wav",
	"weapons/demo_sword_hit_world2.wav",
};

static const char g_SwordHitFlesh[][] = {
	"weapons/blade_slice_2.wav",
	"weapons/blade_slice_3.wav",
	"weapons/blade_slice_4.wav",
};


static const char g_BatSaberHitWorld[][] = {
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};

static const char g_BatSaberHitFlesh[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
};


static const char g_HHHAxeHitWorld[][] = {
	"weapons/halloween_boss/knight_axe_miss.wav",
};

static const char g_HHHAxeHitFlesh[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_FistsMetalHitWorld[][] = {
	"weapons/metal_gloves_hit_world1.wav",
	"weapons/metal_gloves_hit_world2.wav",
	"weapons/metal_gloves_hit_world3.wav",
	"weapons/metal_gloves_hit_world4.wav",
};

static const char g_FistsMetalHitFlesh[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
};


static const char g_FistsHitWorld[][] = {
	"weapons/fist_hit_world1.wav",
	"weapons/fist_hit_world2.wav",
};

static const char g_AxeHitFlesh[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_BatHitFlesh[][] = {
	"weapons/bat_hit.wav",
};


static const char g_WeebKnifeLaughBackstab[][] = {
	"vo/spy_laughhappy01.mp3",
	"vo/spy_laughhappy02.mp3",
	"vo/spy_laughhappy03.mp3",
};


static const char g_KatanaHitFlesh[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};


static const char g_KatanaHitWorld[][] = {
	"weapons/samurai/tf_katana_impact_object_01.wav",
	"weapons/samurai/tf_katana_impact_object_02.wav",
	"weapons/samurai/tf_katana_impact_object_03.wav",
};
/*
static const char g_MeatHitFlesh[][] = {
	"weapons/holy_mackerel1.wav",
	"weapons/holy_mackerel2.wav",
	"weapons/holy_mackerel3.wav",
};


static const char g_MeatHitWorld[][] = {
	"weapons/holy_mackerel1.wav",
	"weapons/holy_mackerel2.wav",
	"weapons/holy_mackerel3.wav",
};
*/

void MapStart_CustomMeleePrecache()
{
	for (int i = 0; i < (sizeof(g_KnifeHitFlesh));	   i++) { PrecacheSound(g_KnifeHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_KnifeHitWorld));	   i++) { PrecacheSound(g_KnifeHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_ThirdDegreeHitWorld));	   i++) { PrecacheSound(g_ThirdDegreeHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_ThirdDegreeHitFlesh));	   i++) { PrecacheSound(g_ThirdDegreeHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_UberSawHitFlesh));	   i++) { PrecacheSound(g_UberSawHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultHitWorld));	   i++) { PrecacheSound(g_DefaultHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_DefaultHitFlesh));	   i++) { PrecacheSound(g_DefaultHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_SwordHitWorld));	   i++) { PrecacheSound(g_SwordHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_SwordHitFlesh));	   i++) { PrecacheSound(g_SwordHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_BatSaberHitWorld));	   i++) { PrecacheSound(g_BatSaberHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_BatSaberHitFlesh));	   i++) { PrecacheSound(g_BatSaberHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_HHHAxeHitWorld));	   i++) { PrecacheSound(g_HHHAxeHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_HHHAxeHitFlesh));	   i++) { PrecacheSound(g_HHHAxeHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_FistsMetalHitWorld));	   i++) { PrecacheSound(g_FistsMetalHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_FistsMetalHitFlesh));	   i++) { PrecacheSound(g_FistsMetalHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_FistsHitWorld));	   i++) { PrecacheSound(g_FistsHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_AxeHitFlesh));	   i++) { PrecacheSound(g_AxeHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_BatHitFlesh));	   i++) { PrecacheSound(g_BatHitFlesh[i]);	   }
	for (int i = 0; i < (sizeof(g_WeebKnifeLaughBackstab));	   i++) { PrecacheSound(g_WeebKnifeLaughBackstab[i]);	   }
	for (int i = 0; i < (sizeof(g_KatanaHitWorld));	   i++) { PrecacheSound(g_KatanaHitWorld[i]);	   }
	for (int i = 0; i < (sizeof(g_KatanaHitFlesh));	   i++) { PrecacheSound(g_KatanaHitFlesh[i]);	   }
}

public void SepcialBackstabLaughSpy(int attacker)
{
	EmitSoundToAll(g_WeebKnifeLaughBackstab[GetRandomInt(0, sizeof(g_WeebKnifeLaughBackstab) - 1)], attacker, SNDCHAN_VOICE, 70, _, 1.0);
}
/*
bool CTFWeaponBaseMelee::DoSwingTraceInternal( trace_t &trace, bool bCleave, CUtlVector< trace_t >* pTargetTraceVector )
{
	// Setup a volume for the melee weapon to be swung - approx size, so all melee behave the same.
	static Vector vecSwingMinsBase( -18, -18, -18 );
	static Vector vecSwingMaxsBase( 18, 18, 18 );

	float fBoundsScale = 1.0f;
	CALL_ATTRIB_HOOK_FLOAT( fBoundsScale, melee_bounds_multiplier );
	Vector vecSwingMins = vecSwingMinsBase * fBoundsScale;
	Vector vecSwingMaxs = vecSwingMaxsBase * fBoundsScale;

	// Get the current player.
	CTFPlayer *pPlayer = GetTFPlayerOwner();
	if ( !pPlayer )
		return false;

	// Setup the swing range.
	float fSwingRange = GetSwingRange();

	// Scale the range and bounds by the model scale if they're larger
	// Not scaling down the range for smaller models because midgets need all the help they can get
	if ( pPlayer->GetModelScale() > 1.0f )
	{
		fSwingRange *= pPlayer->GetModelScale();
		vecSwingMins *= pPlayer->GetModelScale();
		vecSwingMaxs *= pPlayer->GetModelScale();
	}

	CALL_ATTRIB_HOOK_FLOAT( fSwingRange, melee_range_multiplier );

	Vector vecForward; 
	AngleVectors( pPlayer->EyeAngles(), &vecForward );
	Vector vecSwingStart = pPlayer->Weapon_ShootPosition();
	Vector vecSwingEnd = vecSwingStart + vecForward * fSwingRange;

	// In MvM, melee hits from the robot team wont hit teammates to ensure mobs of melee bots don't 
	// swarm so tightly they hit each other and no-one else
	bool bDontHitTeammates = pPlayer->GetTeamNumber() == TF_TEAM_PVE_INVADERS && TFGameRules()->IsMannVsMachineMode();
	CTraceFilterIgnoreTeammates ignoreTeammatesFilter( pPlayer, COLLISION_GROUP_NONE, pPlayer->GetTeamNumber() );

	if ( bCleave )
	{
		Ray_t ray;
		ray.Init( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs );
		CBaseEntity *pList[256];
		int nTargetCount = UTIL_EntitiesAlongRay( pList, ARRAYSIZE( pList ), ray, FL_CLIENT|FL_OBJECT );
		
		int nHitCount = 0;
		for ( int i=0; i<nTargetCount; ++i )
		{
			CBaseEntity *pTarget = pList[i];
			if ( pTarget == pPlayer )
			{
				// don't hit yourself
				continue;
			}

			if ( bDontHitTeammates && pTarget->GetTeamNumber() == pPlayer->GetTeamNumber() )
			{
				// don't hit teammate
				continue;
			}

			if ( pTargetTraceVector )
			{
				trace_t tr;
				UTIL_TraceModel( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, pTarget, COLLISION_GROUP_NONE, &tr );
				pTargetTraceVector->AddToTail();
				pTargetTraceVector->Tail() = tr;
			}
			nHitCount++;
		}

		return nHitCount > 0;
	}
	else
	{
		bool bSapperHit = false;

		// if this weapon can damage sappers, do that trace first
		int iDmgSappers = 0;
		CALL_ATTRIB_HOOK_INT( iDmgSappers, set_dmg_apply_to_sapper );
		if ( iDmgSappers != 0 )
		{
			CTraceFilterIgnorePlayers ignorePlayersFilter( NULL, COLLISION_GROUP_NONE );
			UTIL_TraceLine( vecSwingStart, vecSwingEnd, MASK_SOLID, &ignorePlayersFilter, &trace );
			if ( trace.fraction >= 1.0 )
			{
				UTIL_TraceHull( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, MASK_SOLID, &ignorePlayersFilter, &trace );
			}

			if ( trace.fraction < 1.0f &&
				 trace.m_pEnt &&
				 trace.m_pEnt->IsBaseObject() &&
				 trace.m_pEnt->GetTeamNumber() == pPlayer->GetTeamNumber() )
			{
				CBaseObject *pObject = static_cast< CBaseObject* >( trace.m_pEnt );
				if ( pObject->HasSapper() )
				{
					bSapperHit = true;
				}
			}
		}

		if ( !bSapperHit )
		{
			// See if we hit anything.
			if ( bDontHitTeammates )
			{
				UTIL_TraceLine( vecSwingStart, vecSwingEnd, MASK_SOLID, &ignoreTeammatesFilter, &trace );
			}
			else
			{
				CTraceFilterIgnoreFriendlyCombatItems filter( pPlayer, COLLISION_GROUP_NONE, pPlayer->GetTeamNumber() );
				UTIL_TraceLine( vecSwingStart, vecSwingEnd, MASK_SOLID, &filter, &trace );
			}

			if ( trace.fraction >= 1.0 )
			{
				if ( bDontHitTeammates )
				{
					UTIL_TraceHull( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, MASK_SOLID, &ignoreTeammatesFilter, &trace );
				}
				else
				{
					CTraceFilterIgnoreFriendlyCombatItems filter( pPlayer, COLLISION_GROUP_NONE, pPlayer->GetTeamNumber() );
					UTIL_TraceHull( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, MASK_SOLID, &filter, &trace );
				}

				if ( trace.fraction < 1.0 )
				{
					// Calculate the point of intersection of the line (or hull) and the object we hit
					// This is and approximation of the "best" intersection
					CBaseEntity *pHit = trace.m_pEnt;
					if ( !pHit || pHit->IsBSPModel() )
					{
						// Why duck hull min/max?
						FindHullIntersection( vecSwingStart, trace, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, pPlayer );
					}

					// This is the point on the actual surface (the hull could have hit space)
					vecSwingEnd = trace.endpos;	
				}
			}
		}

		return ( trace.fraction < 1.0f );
	}
}
*/

#define MELEE_RANGE 100
#define MELEE_BOUNDS 22.0
void DoSwingTrace_Custom(Handle &trace, int client, float vecSwingForward[3], float CustomMeleeRange = 0.0, bool Hit_ally = false)
{
	// Setup a volume for the melee weapon to be swung - approx size, so all melee behave the same.
	static float vecSwingMins[3]; vecSwingMins = view_as<float>({-MELEE_BOUNDS, -MELEE_BOUNDS, -MELEE_BOUNDS});
	static float vecSwingMaxs[3]; vecSwingMaxs = view_as<float>({MELEE_BOUNDS, MELEE_BOUNDS, MELEE_BOUNDS});

	float vecSwingStart[3];
//	float vecSwingForward[3];
	float ang[3];
	GetClientEyePosition(client, vecSwingStart);
	GetClientEyeAngles(client, ang);
	
	GetAngleVectors(ang, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
	
	float vecSwingEnd[3];

	if(CustomMeleeRange)
	{
		vecSwingEnd[0] = vecSwingStart[0] + vecSwingForward[0] * CustomMeleeRange;
		vecSwingEnd[1] = vecSwingStart[1] + vecSwingForward[1] * CustomMeleeRange;
		vecSwingEnd[2] = vecSwingStart[2] + vecSwingForward[2] * CustomMeleeRange;
	}
	else
	{
		vecSwingEnd[0] = vecSwingStart[0] + vecSwingForward[0] * MELEE_RANGE;
		vecSwingEnd[1] = vecSwingStart[1] + vecSwingForward[1] * MELEE_RANGE;
		vecSwingEnd[2] = vecSwingStart[2] + vecSwingForward[2] * MELEE_RANGE;
	}
	
	
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(vecSwingStart, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
	
	if(!Hit_ally)
	{
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, client );
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID ), BulletAndMeleeTrace, client );
		//	TE_DrawBox(client, vecSwingStart, vecSwingMins, vecSwingMaxs, 0.5, view_as<int>( { 0, 0, 255, 255 } ));
		}	
	}
	else
	{
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID ), RayType_EndPoint, BulletAndMeleeTraceAlly, client );
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID ), BulletAndMeleeTraceAlly, client );
		//	TE_DrawBox(client, vecSwingStart, vecSwingMins, vecSwingMaxs, 0.5, view_as<int>( { 0, 0, 255, 255 } ));
		}			
	}
}

public int PlayCustomWeaponSoundFromPlayerCorrectly(int client, int target, int weapon_index)
{
	if(target == -1)
		return ZEROSOUND;
		
	if(target > 0 && !b_NpcHasDied[target])
	{
		switch(weapon_index)
		{
			case 649: //The Spy-cicle, because it has no hit enemy sound.
			{
				EmitSoundToAll(g_KnifeHitFlesh[GetRandomInt(0, sizeof(g_KnifeHitFlesh) - 1)], client, SNDCHAN_ITEM, 90, _, 1.0);
				return ZEROSOUND;
			}
		}
		return MELEE_HIT;
	}
	else
	{
		return MELEE_HIT_WORLD;
	}
}


stock bool IsValidCurrentWeapon(int client, int weapon)
{
	if(IsValidEntity(weapon))
	{
		int Active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon == Active_weapon)
		{
			return true;
			
		}
	}
	return false;
}

/*
typedef enum {
    EMPTY,
    SINGLE,
    SINGLE_NPC,
    WPN_DOUBLE, // Can't be "DOUBLE" because windows.h uses it.
    DOUBLE_NPC,
    BURST,
    RELOAD,
    RELOAD_NPC,
    MELEE_MISS,
    MELEE_HIT,
    MELEE_HIT_WORLD,
    SPECIAL1,
    SPECIAL2,
    SPECIAL3,
    TAUNT,
    DEPLOY,

    // Add new shoot sound types here

    NUM_SHOOT_SOUND_TYPES,
} WeaponSound_t;*/

enum
{
	ZEROSOUND 						= 0,	
    SINGLE							= 1,
    SINGLE_NPC						= 2,
    WPN_DOUBLE						= 3,
    DOUBLE_NPC						= 4,
    BURST							= 5,
    RELOAD							= 6,
    RELOAD_NPC						= 7,
    MELEE_MISS						= 8,
    MELEE_HIT						= 9,
    MELEE_HIT_WORLD					= 10,
    SPECIAL1						= 11,
    SPECIAL2						= 12,
    SPECIAL3						= 13,
    TAUNT							= 14,
    DEPLOY							= 15,

};

public void Timer_Do_Melee_Attack(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int weapon = EntRefToEntIndex(pack.ReadCell());
	char classname[32];
	pack.ReadString(classname, 32);
	if(IsValidClient(client) && IsValidCurrentWeapon(client, weapon))
	{

		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward);
				
		int target = TR_GetEntityIndex(swingTrace);	
										
		float vecHit[3];
		TR_GetEndPosition(vecHit, swingTrace);	
			
		int Item_Index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		int soundIndex = PlayCustomWeaponSoundFromPlayerCorrectly(client, target, Item_Index);	

		if(soundIndex > 0)
		{
			char SoundStringToPlay[256];
			SDKCall_GetShootSound(weapon, soundIndex, SoundStringToPlay, sizeof(SoundStringToPlay));
			EmitGameSoundToAll(SoundStringToPlay, client);
		}

		Address address;
		
		float damage = 65.0;
		if(!StrContains(classname, "tf_weapon_bat"))
		{
			damage = 35.0;
		}
		if(Item_Index != 155)
		{
			address = TF2Attrib_GetByDefIndex(weapon, 2);
			if(address != Address_Null)
				damage *= TF2Attrib_GetValue(address);
			
		}
		else
		{
			damage = 30.0;
			float attack_speed;
				
			attack_speed = 1.0 / Attributes_FindOnPlayer(client, 343, true, 1.0); //Sentry attack speed bonus
						
			damage = attack_speed * damage * Attributes_FindOnPlayer(client, 287, true, 1.0);			//Sentry damage bonus
		}
		
			
		address = TF2Attrib_GetByDefIndex(weapon, 1);
		if(address != Address_Null)
			damage *= TF2Attrib_GetValue(address);
				
		if(target > 0 && Item_Index != 214)
		{
		//	PrintToChatAll("%i",MELEE_HIT);
		//	SDKCall_CallCorrectWeaponSound(weapon, MELEE_HIT, 1.0);
		// 	This doesnt work sadly and i dont have the power/patience to make it work, just do a custom check with some big shit, im sorry.
			
				
			SDKHooks_TakeDamage(target, client, client, damage, DMG_CLUB, weapon, CalculateDamageForce(vecSwingForward, 20000.0), vecHit);	
		}
		else if(target > -1 && Item_Index == 214)
		{
			i_ExplosiveProjectileHexArray[weapon] = 0;
			i_ExplosiveProjectileHexArray[weapon] |= EP_DEALS_CLUB_DAMAGE;
			i_ExplosiveProjectileHexArray[weapon] |= EP_GIBS_REGARDLESS;
			
			Explode_Logic_Custom(damage, client, weapon, weapon, vecHit, _, _, _, _, 5); //Only allow 5 targets hit, otherwise it can be really op.
			DataPack pack_boom = new DataPack();
			pack_boom.WriteFloat(vecHit[0]);
			pack_boom.WriteFloat(vecHit[1]);
			pack_boom.WriteFloat(vecHit[2]);
			pack_boom.WriteCell(1);
			RequestFrame(MakeExplosionFrameLater, pack_boom);
		}
		delete swingTrace;
		FinishLagCompensation_Base_boss();
	}
	delete pack;
}