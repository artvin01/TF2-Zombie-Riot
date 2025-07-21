#pragma semicolon 1
#pragma newdecls required

#define PHLOG_JUDGEMENT_MAX_HITS_NEEDED 150 	

#define PHLOG_ABILITY "misc/halloween/spell_overheal.wav"

Handle h_TimerPHLOGManagement[MAXPLAYERS+1] = {null, ...};
static float f_PHLOGhuddelay[MAXPLAYERS];
static float f_PHLOGabilitydelay[MAXPLAYERS];
static int i_PHLOGHitsDone[MAXPLAYERS];
static float f_FlameerDelay[MAXPLAYERS];

void Npc_OnTakeDamage_Phlog(int attacker)
{
	if(GetGameTime() > f_PHLOGabilitydelay[attacker])
	{
		i_PHLOGHitsDone[attacker] += 1;
		if(i_PHLOGHitsDone[attacker] > PHLOG_JUDGEMENT_MAX_HITS_NEEDED) //We do not go above this, no double charge.
		{
			i_PHLOGHitsDone[attacker] = PHLOG_JUDGEMENT_MAX_HITS_NEEDED;
		}
	}
}

void PHLOG_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	PrecacheSound(PHLOG_ABILITY);
}

void Reset_stats_PHLOG_Global()
{
	Zero(h_TimerPHLOGManagement);
	Zero(f_PHLOGhuddelay); //Only needs to get reset on map change, not disconnect.
	Zero(f_PHLOGabilitydelay); //Only needs to get reset on map change, not disconnect.
	Zero(i_PHLOGHitsDone); //This only ever gets reset on map change or player reset
	Zero(f_FlameerDelay);
}

void Reset_stats_PHLOG_Singular(int client) //This is on disconnect/connect
{
	if (h_TimerPHLOGManagement[client] != null)
	{
		delete h_TimerPHLOGManagement[client];
	}	
	h_TimerPHLOGManagement[client] = null;
	i_PHLOGHitsDone[client] = 0;
}

#define MAX_TARGETS_FLAME 5

static int BEAM_BuildingHit[MAX_TARGETS_FLAME];
static float BEAM_Targets_Hit[MAXPLAYERS];

public void Weapon_PHLOG_Attack(int client, int weapon, bool crit, int slot)
{
	if(f_FlameerDelay[client] > GetGameTime())
	{
		return;
	}
	f_FlameerDelay[client] = GetGameTime() + 0.15;
	for (int building = 0; building < MAX_TARGETS_FLAME; building++)
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
	BEAM_Targets_Hit[client] = 1.0;
	float damage = 25.0;
	damage *= Attributes_Get(weapon, 2, 1.0);
//	damage *= (1.0 / Attributes_Get(weapon, 6, 1.0)); //already does it, see attribute Attrib_AttackspeedConvertIntoDmg

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
				pack.WriteFloat(damage*BEAM_Targets_Hit[client]);
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
				
				BEAM_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
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

public void Enable_PHLOG(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerPHLOGManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == 7) //7 is for PHLOG.
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerPHLOGManagement[client];
			h_TimerPHLOGManagement[client] = null;
			DataPack pack;
			h_TimerPHLOGManagement[client] = CreateDataTimer(0.1, Timer_Management_PHLOG, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon] == 7) //7 is for PHLOG.
	{
		DataPack pack;
		h_TimerPHLOGManagement[client] = CreateDataTimer(0.1, Timer_Management_PHLOG, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}



public Action Timer_Management_PHLOG(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_TimerPHLOGManagement[client] = null;
		return Plugin_Stop;
	}	

	PHLOG_Cooldown_Logic(client, weapon);
		
	return Plugin_Continue;
}


public void PHLOG_Cooldown_Logic(int client, int weapon)
{
	if(f_PHLOGhuddelay[client] < GetGameTime())
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
		{
			if(GetGameTime() > f_PHLOGabilitydelay[client])
			{
				if(i_PHLOGHitsDone[client] < PHLOG_JUDGEMENT_MAX_HITS_NEEDED)
				{
					PrintHintText(client,"Phlog Hit Charge[%i%/%i]", i_PHLOGHitsDone[client], PHLOG_JUDGEMENT_MAX_HITS_NEEDED);
				}
				else
				{
					PrintHintText(client,"Phlog Hit Charge [READY!]");
				}
			}
			else
			{
				PrintHintText(client,"Phlog Hit Charge [Cooldown: %.1f]",f_PHLOGabilitydelay[client] - GetGameTime());
			}
			
			
			f_PHLOGhuddelay[client] = GetGameTime() + 0.5;
		}
	}
	if(GetGameTime() < f_PHLOGabilitydelay[client])
	{
		int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(weapon_holding != weapon) //Only show if the weapon is actually in your hand right now.
		{
			f_PHLOGabilitydelay[client] = 0.0; //They just switched off it, delete.
			TF2_RemoveCondition(client, TFCond_DefenseBuffNoCritBlock);
			TF2_RemoveCondition(client, TFCond_CritCanteen);	
		}
	}
}


public void Weapon_PHLOG_Judgement(int client, int weapon, bool crit, int slot)
{
	//This ability has no cooldown in itself, it just relies on hits you do.
	if(i_PHLOGHitsDone[client] >= PHLOG_JUDGEMENT_MAX_HITS_NEEDED || CvarInfiniteCash.BoolValue)
	{
		Rogue_OnAbilityUse(client, weapon);
		i_PHLOGHitsDone[client] = 0;
		f_PHLOGabilitydelay[client] = GetGameTime() + 10.0; //Have a cooldown so they cannot spam it.
		EmitSoundToAll(PHLOG_ABILITY, client, _, 75, _, 0.60);
		TF2_AddCondition(client, TFCond_UberchargedCanteen, 1.0); //ohboy
		TF2_AddCondition(client, TFCond_DefenseBuffNoCritBlock, 10.0);
		TF2_AddCondition(client, TFCond_CritCanteen, 10.0);
		ApplyTempAttrib(weapon, 2, 1.35, 10.0); //way higher damage.
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
	}
}