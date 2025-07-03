#pragma semicolon 1
#pragma newdecls required

static float f_FlameerDelay[MAXPLAYERS];
static float LastDamageCalc[MAXPLAYERS];
static int LastWeaponCalc[MAXPLAYERS];

void ChemicalThrower_NPCTakeDamage(int attacker, int victim, float damage)
{
	bool wasBurning = view_as<bool>(IgniteFor[victim]);

	NPC_Ignite(victim, attacker, 1.0, -1, LastDamageCalc[attacker] * 4.0, true);
	Elemental_AddNervousDamage(victim, attacker, RoundFloat(damage * 1.5), .weapon = LastWeaponCalc[attacker]);

	if(!wasBurning && IgniteFor[victim])
	{
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(EntIndexToEntRef(attacker));
		RequestFrame(StartChemicalDebuff, pack);
	}
}

static void StartChemicalDebuff(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1 && IgniteFor[entity])
	{
		CreateTimer(0.5, TimerChemicalDebuff, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT|TIMER_DATA_HNDL_CLOSE);
	}
	else
	{
		delete pack;
	}
}

static Action TimerChemicalDebuff(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity == -1 || !IgniteFor[entity])
		return Plugin_Stop;
	
	int attacker = EntRefToEntIndex(pack.ReadCell());
	if(attacker == -1)
		return Plugin_Stop;
	
	Elemental_AddNervousDamage(entity, attacker, RoundToCeil(LastDamageCalc[attacker] * 6.0), .weapon = LastWeaponCalc[attacker]);
	return Plugin_Continue;
}

static int BEAM_BuildingHit[MAX_TARGETS_FLAME];
static float BEAM_Targets_Hit;

public void Weapon_ChemicalThrower_M1(int client, int weapon, bool crit, int slot)
{
	if(fabs(f_FlameerDelay[client] - GetGameTime()) < 0.15)
		return;
	
	f_FlameerDelay[client] = GetGameTime();

	for(int building = 0; building < MAX_TARGETS_FLAME; building++)
	{
		BEAM_BuildingHit[building] = false;
	}

	float Angles[3];
	float belowBossEyes[3];
	GetClientEyeAngles(client, Angles);	
	float vecForward[3];
	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);
	float VectorTarget_2[3];
	float VectorForward = 300.0; //a really high number.

	VectorForward *= Attributes_Get(weapon, 4001, 1.0);
	GetBeamDrawStartPoint_Stock(client, belowBossEyes,{0.0,0.0,0.0}, Angles);
	VectorTarget_2[0] = belowBossEyes[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = belowBossEyes[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = belowBossEyes[2] + vecForward[2] * VectorForward;
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	Handle trace;
	static float hullMin[3];
	static float hullMax[3];
	hullMin = {-20.0,-20.0,-20.0};
	hullMax = {20.0,20.0,20.0};
	trace = TR_TraceHullFilterEx(belowBossEyes, VectorTarget_2, hullMin, hullMax, 1073741824, Flamer_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
	FinishLagCompensation_Base_boss();
	BEAM_Targets_Hit = 1.0;

	LastDamageCalc[client] = Attributes_Get(weapon, 868, 1.0);	// Base Damage
	LastDamageCalc[client] *= Attributes_GetOnPlayer(client, 287, true, true);	// Sentry damage bonus
	float AttackspeedValue = Attributes_GetOnPlayer(client, 343, true, true);	// Sentry attack speed bonus
	if(AttackspeedValue < 1.0)
	{
		LastDamageCalc[client] *= ((AttackspeedValue * -1.0) + 2.0);
	}
	else
		LastDamageCalc[client] *= (1.0 / AttackspeedValue); //nerf normally.
	
	LastDamageCalc[client] *= BuildingWeaponDamageModif(1);
	LastWeaponCalc[client] = weapon;

	float damage = 25.0 * LastDamageCalc[client];

	float playerPos[3];

	for (int building = 0; building < MAX_TARGETS_FLAME; building++)
	{
		if (BEAM_BuildingHit[building])
		{
			if(IsValidEntity(BEAM_BuildingHit[building]))
			{
				WorldSpaceCenter(BEAM_BuildingHit[building], playerPos);

				float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
				DataPack pack = new DataPack();
				pack.WriteCell(EntIndexToEntRef(BEAM_BuildingHit[building]));
				pack.WriteCell(EntIndexToEntRef(client));
				pack.WriteCell(EntIndexToEntRef(client));
				pack.WriteFloat(damage*BEAM_Targets_Hit);
				pack.WriteCell(DMG_BULLET);
				pack.WriteCell(EntIndexToEntRef(weapon));
				pack.WriteFloat(damage_force[0]);
				pack.WriteFloat(damage_force[1]);
				pack.WriteFloat(damage_force[2]);
				pack.WriteFloat(playerPos[0]);
				pack.WriteFloat(playerPos[1]);
				pack.WriteFloat(playerPos[2]);
				pack.WriteCell(0);
				RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
				
				BEAM_Targets_Hit *= LASER_AOE_DAMAGE_FALLOFF;
			}
			else
				BEAM_BuildingHit[building] = false;
		}
	}
 	return;
}

static bool Flamer_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=0; i < MAX_TARGETS_FLAME; i++)
			{
				if(!BEAM_BuildingHit[i])
				{
					BEAM_BuildingHit[i] = entity;
					break;
				}
			}
			
		}
	}
	return false;
}