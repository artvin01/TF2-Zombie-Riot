static float f_TargetAirtime[MAXENTITIES];
static float f_TargetAirtimeDelayHit[MAXENTITIES];
static float f_TargetAirtimeTeleportDelay[MAXENTITIES];
static bool b_TraceFire[MAXENTITIES];
static int i_NpcToTarget[MAXENTITIES];
static bool b_AirCutterNpcWasShotUp[MAXENTITIES];
#define AIRCUTTER_AIRTIME 1.5	
#define AIRCUTTER_JUDGEMENT_MAXRANGE 100.0	

#define AIRCUTTER_KICKUP_1 "mvm/giant_soldier/giant_soldier_rocket_shoot.wav"
#define AIRCUTTER_EXPLOSION_1 "mvm/giant_common/giant_common_explodes_01.wav"
#define AIRCUTTER_EXPLOSION_2 "mvm/giant_common/giant_common_explodes_02.wav"
static int ShortTeleportLaserIndex;

void AirCutter_Map_Precache()
{
	ShortTeleportLaserIndex = PrecacheModel("materials/sprites/laser.vmt", false);
	PrecacheSound("physics/metal/metal_box_impact_bullet1.wav");
	PrecacheSound("items/powerup_pickup_knockout.wav");
	PrecacheSound("misc/halloween/spell_overheal.wav");	
	PrecacheSound(AIRCUTTER_EXPLOSION_1);
	PrecacheSound(AIRCUTTER_EXPLOSION_2);
	PrecacheSound(AIRCUTTER_KICKUP_1);
}


public float AirCutterAbility(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) != TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Melee Weapon.");
		return 0.0;
	}

	if(Stats_Intelligence(client) < 65)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [65]");
		return 0.0;
	}
	
	int StatsForCalcMultiAdd_stam;
	Stats_Strength(client, StatsForCalcMultiAdd_stam);
	StatsForCalcMultiAdd_stam /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd_stam)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}
	float time = Ability_AirCutter(client, 1, weapon);
	if(time > 0.0)
	{
		RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd_stam);
	}

	return (GetGameTime() + time);
}

static float OldPosSave[MAXENTITIES][3];

public float Ability_AirCutter(int client, int level, int weapon)
{
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", OldPosSave[client]);

	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	Handle swingTrace;
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, 100.0); //about melee range.
	FinishLagCompensation_Base_boss();
				
	int target = TR_GetEntityIndex(swingTrace);
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	

	delete swingTrace;
	if(IsValidEnemy(client, target, true, true))
	{
		//We have found a victim.
		GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", OldPosSave[target]);
		//Save old position
		
		if(GetGameTime() > f_TargetAirtime[target]) //Do not shoot up again once already dome.
		{
			b_AirCutterNpcWasShotUp[target] = true;
		}

		f_TargetAirtime[client] = GetGameTime() + AIRCUTTER_AIRTIME;
		f_TargetAirtimeDelayHit[client] = GetGameTime() + 0.25;
		f_TankGrabbedStandStill[target] = GetGameTime(target) + AIRCUTTER_AIRTIME;
		f_TargetAirtime[target] = GetGameTime() + AIRCUTTER_AIRTIME; //Kick up for way less time.
		b_DoNotUnStuck[client] = true;
		if(target > MaxClients)
			FreezeNpcInTime(target,AIRCUTTER_AIRTIME + 0.25);

		//Give abit extra time so they can run away
		b_TraceFire[client] = false;
		i_EntityToAlwaysMeleeHit[client] = target;
		//teleporting and changing the player vision 24/7 fucks with this.

		ApplyTempAttrib(weapon, 6, 0.25, AIRCUTTER_AIRTIME);
		ApplyTempAttrib(weapon, 4004, 0.25, AIRCUTTER_AIRTIME);
		ApplyTempAttrib(weapon, 2, 0.85, AIRCUTTER_AIRTIME);
		ApplyTempAttrib(weapon, 4005, 0.85, AIRCUTTER_AIRTIME);
		EmitSoundToAll(AIRCUTTER_KICKUP_1, client, _, 75, _, 0.60);
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", 0.0);
		TF2_AddCondition(client, TFCond_DefenseBuffed, AIRCUTTER_AIRTIME);
		f_TargetAirtimeTeleportDelay[client] = GetGameTime();

		spawnRing_Vectors(OldPosSave[target], 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, AIRCUTTER_JUDGEMENT_MAXRANGE * 2.0);	
		spawnRing_Vectors(OldPosSave[client], 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, AIRCUTTER_JUDGEMENT_MAXRANGE * 2.0);

		SDKUnhook(target, SDKHook_Think, Npc_AirCutter_Launch);
		if(!HasSpecificBuff(target, "Solid Stance") && target > MaxClients)
			SDKHook(target, SDKHook_Think, Npc_AirCutter_Launch);

		i_NpcToTarget[client] = target;
		i_NpcToTarget[target] = client;
		//There is no need to ent ref this, the code fires every frame, and the same index cannot be used for 1 second.
		SDKHook(client, SDKHook_PreThink, Npc_AirCutter_Launch_client);
		return 25.0;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return 0.0;
	}
}
public void Npc_AirCutter_Launch(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	//Do their fly logic.

	if(b_AirCutterNpcWasShotUp[iNPC])
	{
		float VicLoc[3];
		WorldSpaceCenter(iNPC, VicLoc);
		VicLoc[2] += 350.0; //Jump up.
		PluginBot_Jump(iNPC, VicLoc);
	}
	b_AirCutterNpcWasShotUp[iNPC] = false;
	
	float time_stay_In_sky;
	time_stay_In_sky = AIRCUTTER_AIRTIME * 0.75;

	if(GetGameTime() > f_TargetAirtime[iNPC])
	{
		//We are Done, kill think.
		SDKUnhook(iNPC, SDKHook_Think, Npc_AirCutter_Launch);
	}	
	else if((GetGameTime() + time_stay_In_sky) > f_TargetAirtime[iNPC])
	{
		//After 0.5 seconds they stop accending to heaven, we also reset their velocity ontop of resetting their gravtiy
		npc.SetVelocity({ 0.0, 0.0, 0.0 });
	}
}

bool Npc_Is_Targeted_In_Air(int entity) //Anything that needs to be precaced like sounds or something.
{
	if(f_TargetAirtime[entity] > GetGameTime())
	{
		return true;
	}
	return false;
}


public void Npc_AirCutter_Launch_client(int client)
{
	int target = i_NpcToTarget[client];
	if(target == -999)
	{
		SDKUnhook(client, SDKHook_PreThink, Npc_AirCutter_Launch_client);
		return;
	}
	if(IsValidEnemy(client, target, true, true))
	{
		if(GetGameTime() > f_TargetAirtime[client])
		{
			CClotBody npc = view_as<CClotBody>(target);
			float VecPos[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VecPos);
			float VecPosClient[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", VecPosClient);
			float Time = 0.5;
			TE_SetupBeamPoints(VecPosClient, OldPosSave[client], ShortTeleportLaserIndex, 0, 0, 0, Time, 10.0, 10.0, 0, 1.0, {255,255,255,200}, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(VecPos, OldPosSave[target], ShortTeleportLaserIndex, 0, 0, 0, Time, 10.0, 10.0, 0, 1.0, {255,255,255,200}, 3);
			TE_SendToAll(0.0);
			
			spawnRing_Vectors(OldPosSave[target], 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, AIRCUTTER_JUDGEMENT_MAXRANGE * 2.0);	
			spawnRing_Vectors(OldPosSave[client], 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.25, 12.0, 6.1, 1, AIRCUTTER_JUDGEMENT_MAXRANGE * 2.0);
			TeleportEntity(target, OldPosSave[target], NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(client, OldPosSave[client], NULL_VECTOR, NULL_VECTOR);
			SpawnSmallExplosionNotRandom(VecPos);
			SpawnSmallExplosionNotRandom(VecPosClient);
			
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					EmitSoundToAll(AIRCUTTER_EXPLOSION_1, client, _, 85, _, 0.5);
				}
				case 2:
				{
					EmitSoundToAll(AIRCUTTER_EXPLOSION_2, client, _, 85, _, 0.5);
				}
			}			
			SetEntityMoveType(client, MOVETYPE_WALK);
			if(target > MaxClients)
				npc.SetVelocity({ 0.0, 0.0, 0.0 });

			b_DoNotUnStuck[client] = false;
			i_NpcToTarget[client] = 0;
			LookAtTarget(client, target);
			i_EntityToAlwaysMeleeHit[client] = 0;
			SDKUnhook(client, SDKHook_PreThink, Npc_AirCutter_Launch_client);
			return;
		}	
		else if(GetGameTime() > f_TargetAirtimeDelayHit[client])
		{
			float VecPos[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VecPos);
			if(GetGameTime() > f_TargetAirtimeTeleportDelay[client])
			{
				f_TargetAirtimeTeleportDelay[client] = GetGameTime() + 0.15;
				
				float OriginalVecPos[3];
				OriginalVecPos = VecPos;
				b_ThisEntityIsAProjectileForUpdateContraints[target] = true;
				for(int repeat; repeat < 10; repeat ++)
				{
					//a max of 10 repeaots before we give up.
					VecPos = OriginalVecPos;


					VecPos[0] += (60.0 * float(GetRandomInt(-1,1)))
					VecPos[1] += (60.0 * float(GetRandomInt(-1,1)))
					VecPos[2] += (90.0 * float(GetRandomInt(-1,1)))
					static float hullcheckmaxs_Player[3];
					static float hullcheckmins_Player[3];
					hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	

					if(IsSafePosition(client, VecPos, hullcheckmins_Player, hullcheckmaxs_Player))
						break;

					if(repeat == 9)
					{
						VecPos = OriginalVecPos;
					}	
				}
				b_ThisEntityIsAProjectileForUpdateContraints[target] = false;

				TeleportEntity(client, VecPos, NULL_VECTOR, NULL_VECTOR);
				LookAtTarget(client, target);
				spawnRing_Vectors(VecPos, AIRCUTTER_JUDGEMENT_MAXRANGE * 2.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 255, 200, 1, 0.2, 12.0, 6.1, 1);
				
				VecPos = OriginalVecPos;
			}
			if(!b_TraceFire[client])
			{
				SetEntityMoveType(client, MOVETYPE_NONE);
				float startPos[3];
				startPos = OldPosSave[client];
				startPos[2] += 45.0;
				VecPos[2] += 45.0;
				float Time = 0.5;
				TE_SetupBeamPoints(startPos, VecPos, ShortTeleportLaserIndex, 0, 0, 0, Time, 10.0, 10.0, 0, 1.0, {255,255,255,200}, 3);
				TE_SendToAll(0.0);
				SpawnSmallExplosionNotRandom(OldPosSave[client]);
				switch(GetRandomInt(1, 2))
				{
					case 1:
					{
						EmitSoundToAll(AIRCUTTER_EXPLOSION_1, client, _, 85, _, 0.5);
					}
					case 2:
					{
						EmitSoundToAll(AIRCUTTER_EXPLOSION_2, client, _, 85, _, 0.5);
					}
				}
			}
			b_TraceFire[client] = true;

		}
		else
		{
			LookAtTarget(client, target);
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR,{0.0,0.0,0.0});
		}
	}
	else
	{
		if(IsValidEntity(target))
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:
				{
					EmitSoundToAll(AIRCUTTER_EXPLOSION_1, client, _, 85, _, 0.5);
				}
				case 2:
				{
					EmitSoundToAll(AIRCUTTER_EXPLOSION_2, client, _, 85, _, 0.5);
				}
			}
			float VecPos[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VecPos);
			VecPos[2] += 45.0;
			float Time = 0.5;
			TE_SetupBeamPoints(VecPos, OldPosSave[client], ShortTeleportLaserIndex, 0, 0, 0, Time, 10.0, 10.0, 0, 1.0, {255,255,255,200}, 3);
			TE_SendToAll(0.0);
		}
		i_EntityToAlwaysMeleeHit[client] = 0;
		b_DoNotUnStuck[client] = false;
		TeleportEntity(client, OldPosSave[client], NULL_VECTOR, NULL_VECTOR);
		SetEntityMoveType(client, MOVETYPE_WALK);
		i_NpcToTarget[client] = 0;
		SDKUnhook(client, SDKHook_PreThink, Npc_AirCutter_Launch_client);
		return;
	}
}

void AircutterCancelAbility(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Npc_AirCutter_Launch_client);
	i_EntityToAlwaysMeleeHit[client] = 0;
	b_DoNotUnStuck[client] = false;	
	SetEntityMoveType(client, MOVETYPE_WALK);
	i_NpcToTarget[client] = -999;
}