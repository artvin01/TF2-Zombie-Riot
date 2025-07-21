static float f_GoldenAgilityThrottle[MAXPLAYERS+1];
static float f3_GoldenAgilitySpotStepOn[MAXPLAYERS+1][3];
static float f_GoldenAgilityCooldown[MAXPLAYERS+1];
static float f_GoldenAgilityActiveFor[MAXPLAYERS+1];
static char gLaser1;

#define NEW_SPOT_GOLDEN_SOUND "ui/chime_rd_2base_neg.wav"
#define PICKUP_SPOT_GOLDEN_SOUND "ui/chime_rd_2base_pos.wav"

public void GoldenAgilityUnequip(int client)
{
	SDKUnhook(client, SDKHook_PostThink, PostThink_GoldenAgility);
}

public void GoldenAgilityEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		SDKUnhook(client, SDKHook_PostThink, PostThink_GoldenAgility);
		SDKHook(client, SDKHook_PostThink, PostThink_GoldenAgility);		
	}
}

void Abiltity_GoldenAgility_MapStart()
{
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	PrecacheSound(NEW_SPOT_GOLDEN_SOUND);
	PrecacheSound(PICKUP_SPOT_GOLDEN_SOUND);
	Zero(f_GoldenAgilityCooldown);
	Zero2(f3_GoldenAgilitySpotStepOn);
	Zero(f_GoldenAgilityActiveFor);
}


void PostThink_GoldenAgility(int client)
{
	if(f_GoldenAgilityThrottle[client] > GetGameTime())
		return;

	if(f_GoldenAgilityActiveFor[client])
	{
		//We generated a cirlce before, now make sure they stand in it!
		if(f_GoldenAgilityActiveFor[client] < GetGameTime())
		{
			f_GoldenAgilityActiveFor[client] = 0.0; //fail.
			f_GoldenAgilityCooldown[client] = GetGameTime() + 5.0;
			f3_GoldenAgilitySpotStepOn[client][0] = -16000.0;
			f3_GoldenAgilitySpotStepOn[client][1] = -16000.0;
			f3_GoldenAgilitySpotStepOn[client][2] = -16000.0;
			return;
		}
		f_GoldenAgilityThrottle[client] =  GetGameTime() + 0.1;

		float RangeCircleBig = 80.0;

		float ClientPos[3];
		float SavePos[3];
		SavePos = f3_GoldenAgilitySpotStepOn[client];
		GetClientAbsOrigin(client, ClientPos);
		if (GetVectorDistance(ClientPos, SavePos, true) <= (RangeCircleBig * RangeCircleBig))
		{
			f_GoldenAgilityCooldown[client] = GetGameTime() + 18.0;
			f_GoldenAgilityActiveFor[client] = 0.0; //fail.
			//Circle yippie.
			//Do stuff now.
			f_GoldenAgilityThrottle[client] = 0.0;
			f3_GoldenAgilitySpotStepOn[client][0] = -16000.0;
			f3_GoldenAgilitySpotStepOn[client][1] = -16000.0;
			f3_GoldenAgilitySpotStepOn[client][2] = -16000.0;
			
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(!IsValidEntity(weapon))
				return;

			static char classname[36];
			GetEntityClassname(weapon, classname, sizeof(classname));
			if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
			{
				return;
			}
			//if they dont hold a ranged weapon, then they dont get anything. Fuck u
			
			ApplyTempAttrib(client, 442, 1.35, 17.9);
			SDKCall_SetSpeed(client);
			ApplyTempAttrib(weapon, 2, 1.35, 18.0);	
			ApplyTempAttrib(weapon, 6, 0.75, 18.0);
			ApplyTempAttrib(weapon, 97, 0.75, 18.0);
			ApplyTempAttrib(weapon, 4004, 0.75, 18.0);
			ApplyTempAttrib(weapon, 4003, 0.75, 18.0);
			CreateTimer(18.0, Timer_UpdateMovementSpeed, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			EmitSoundToClient(client, PICKUP_SPOT_GOLDEN_SOUND, client, SNDCHAN_STATIC, 100, _);
			TE_Particle("teleportedin_red", SavePos, NULL_VECTOR, NULL_VECTOR, 0, _, _, _, _, _, _, _, _, _, 0.0);
		}
		else
		{
			spawnRing_Vectors(f3_GoldenAgilitySpotStepOn[client], RangeCircleBig * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ 0.25, 12.0, 0.1, 1,_,client);
			float VecAbove2[3];
			VecAbove2 = f3_GoldenAgilitySpotStepOn[client];
			VecAbove2[2] += 30.0;
			spawnRing_Vectors(VecAbove2, RangeCircleBig * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ 0.25, 12.0, 0.1, 1,_,client);
		
		}
		return;
	}
	f_GoldenAgilityThrottle[client] =  GetGameTime() + 0.5;

	if(f_InBattleDelay[client] + 5.0 < GetGameTime())
	{
		f_GoldenAgilityCooldown[client] = GetGameTime() + 2.0;
		return;
	}
	
	if(f_GoldenAgilityCooldown[client] > GetGameTime())
	{
		//on cooldown, do nothing.
		return;
	}
	//they are in battle.
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
		return;

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		return;
	}
	//Generate random circle.
	float f_ang[3];
	float f_pos[3];
	GetClientAbsOrigin(client, f_pos);

	f_pos[2] += 150.0;
	f_ang[0] = 5.0 + GetRandomFloat(20.0, 35.0);
	f_ang[1] = GetRandomFloat(-180.0,180.0);

	Handle trace; 
	trace = TR_TraceRayFilterEx(f_pos, f_ang, (MASK_SHOT_HULL), RayType_Infinite, HitOnlyWorld, client);
	TR_GetEndPosition(f3_GoldenAgilitySpotStepOn[client], trace);
	delete trace;

	float pos_enemy[3];
	pos_enemy = f3_GoldenAgilitySpotStepOn[client];
	pos_enemy[2] += 5.0;
	float pos_Client[3];
	WorldSpaceCenter(client, pos_Client);

	AddEntityToTraceStuckCheck(client);
	
	Handle trace2;
	trace2 = TR_TraceRayFilterEx(pos_enemy, pos_Client, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, TraceRayCanSeeAllySpecific, _);
	
	RemoveEntityToTraceStuckCheck(client);
	
	//needs to be seeable by the client
	int Traced_Target = TR_GetEntityIndex(trace2);
	delete trace2;
	if(Traced_Target != client)
	{
		f_GoldenAgilityThrottle[client] = GetGameTime() + 0.1;
		return;
	}

	//Needs to be on a nav to work
	CNavArea area = TheNavMesh.GetNavArea(pos_enemy, 30.0);
	if(area == NULL_AREA)
	{
		f_GoldenAgilityThrottle[client] = GetGameTime() + 0.1;
		return;
	}
	f_GoldenAgilityActiveFor[client] = GetGameTime() + 8.0;
	EmitSoundToClient(client, NEW_SPOT_GOLDEN_SOUND, client, SNDCHAN_STATIC, 100, _);
	f_GoldenAgilityCooldown[client] = GetGameTime() + 10.0;
	float RangeCircleBig = 80.0;
	float VecAbove[3];
	VecAbove = f3_GoldenAgilitySpotStepOn[client];
	VecAbove[2] += 1000.0;
	TE_SetupBeamPoints(VecAbove, f3_GoldenAgilitySpotStepOn[client], gLaser1, 0, 0, 0, 0.75, 50.0, 50.0, 0, NORMAL_ZOMBIE_VOLUME, {255, 255, 50, 255}, 3);
	TE_SendToClient(client);
	spawnRing_Vectors(f3_GoldenAgilitySpotStepOn[client], RangeCircleBig * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ 0.75, 12.0, 0.1, 1,_,client);
	
	float VecAbove2[3];
	VecAbove2 = f3_GoldenAgilitySpotStepOn[client];
	VecAbove2[2] += 30.0;
	spawnRing_Vectors(VecAbove2, RangeCircleBig * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 50, 200, 1, /*DURATION*/ 0.75, 12.0, 0.1, 1,_,client);
	f_GoldenAgilityThrottle[client] =  GetGameTime() + 0.3;
}