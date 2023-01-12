#pragma semicolon 1
#pragma newdecls required

static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

static int client_slammed_how_many_times[MAXTF2PLAYERS];
static int client_slammed_how_many_times_limit[MAXTF2PLAYERS];
static float client_slammed_pos[MAXTF2PLAYERS][3];
static float client_slammed_forward[MAXTF2PLAYERS][3];
static float client_slammed_right[MAXTF2PLAYERS][3];
static float f_OriginalDamage[MAXTF2PLAYERS];

public void Wand_Elemental_2_ClearAll()
{
	Zero(ability_cooldown);
}
#define spirite "spirites/zerogxplode.spr"

#define EarthStyleShockwaveRange 250.0
void Wand_Elemental_2_Map_Precache()
{
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_flyby2.wav", true);
	PrecacheSound("ambient/atmosphere/terrain_rumble1.wav", true);
	PrecacheSound("ambient/explosions/explode_9.wav", true);
}

public void Weapon_Elemental_Wand_2(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		int mana_cost = 350;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Ability_Apply_Cooldown(client, slot, 15.0);
				Current_Mana[client] -= mana_cost;
				float damage = 160.0;
				Address	address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
					
				f_OriginalDamage[client] = damage;
				client_slammed_how_many_times_limit[client] = 5;
				client_slammed_how_many_times[client] = 0;
				float vecUp[3];
				
				GetVectors(client, client_slammed_forward[client], client_slammed_right[client], vecUp); //Sorry i dont know any other way with this :(
				client_slammed_pos[client] = GetAbsOrigin(client);
				client_slammed_pos[client][2] += 5.0;
				
				float vecSwingEnd[3];
				vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (1 * client_slammed_how_many_times[client]);
				vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (1 * client_slammed_how_many_times[client]);
				vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
				
				GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecUp);
				
				
				DataPack pack = new DataPack();
				pack.WriteFloat(vecUp[0]);
				pack.WriteFloat(vecUp[1]);
				pack.WriteFloat(vecUp[2]);
				pack.WriteCell(1);
				RequestFrame(MakeExplosionFrameLater, pack);
				
				Explode_Logic_Custom(damage, client, client, weapon,vecUp,_,_,_,false);
			
				CreateTimer(0.1, shockwave_explosions, client, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}
			else
			{
				float Ability_CD = Ability_Check_Cooldown(client, slot);
		
				if(Ability_CD <= 0.0)
					Ability_CD = 0.0;
			
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
				SetGlobalTransTarget(client);
				ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);	
			}
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

public Action shockwave_explosions(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		client_slammed_how_many_times[client] += 1;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = client_slammed_pos[client][0] + client_slammed_forward[client][0] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[1] = client_slammed_pos[client][1] + client_slammed_forward[client][1] * (90 * client_slammed_how_many_times[client]);
		vecSwingEnd[2] = client_slammed_pos[client][2] + client_slammed_forward[client][2] * 100;
		
		int ent = CreateEntityByName("env_explosion");
		if(ent != -1)
		{
			SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
									
			EmitAmbientSound("ambient/explosions/explode_9.wav", vecSwingEnd);
							
			DispatchKeyValueVector(ent, "origin", vecSwingEnd);
			DispatchKeyValue(ent, "spawnflags", "64");
			
			DispatchKeyValue(ent, "rendermode", "5");
			DispatchKeyValue(ent, "fireballsprite", spirite);
							
			SetEntProp(ent, Prop_Data, "m_iMagnitude", 0); 
			SetEntProp(ent, Prop_Data, "m_iRadiusOverride", 200); 
						
			DispatchSpawn(ent);
			ActivateEntity(ent);
						
			AcceptEntityInput(ent, "explode");
			AcceptEntityInput(ent, "kill");
			Explode_Logic_Custom(f_OriginalDamage[client], client, client, -1, vecSwingEnd,_,_,_,false);
		}
		if(client_slammed_how_many_times[client] > client_slammed_how_many_times_limit[client])
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


//Passanger Ability stuff.

Handle h_TimerPassangerManagement[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
static float f_PassangerHudDelay[MAXTF2PLAYERS];

static int BeamWand_Laser;
static int BeamWand_Glow;

void Passanger_Map_Precache() //Anything that needs to be precaced like sounds or something.
{
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
//	PrecacheSound(PHLOG_ABILITY);
}

void Reset_stats_Passanger_Global()
{
	Zero(f_PassangerHudDelay);
}

void Reset_stats_Passanger_Singular(int client) //This is on disconnect/connect
{
	h_TimerPassangerManagement[client] = INVALID_HANDLE;
}

#define CUSTOM_MELEE_RANGE_DETECTION 1000.0


public void Weapon_Passanger_Attack(int client, int weapon, bool crit, int slot)
{
	b_LagCompNPC_No_Layers = true;
	float vecSwingForward[3];
	StartLagCompensation_Base_Boss(client);
	Handle swingTrace;
	DoSwingTrace_Custom(swingTrace, client, vecSwingForward, CUSTOM_MELEE_RANGE_DETECTION);
		
	int target = TR_GetEntityIndex(swingTrace);
	float vecHit[3];
	TR_GetEndPosition(vecHit, swingTrace);	

	delete swingTrace;
	FinishLagCompensation_Base_boss();

	if(IsValidEnemy(client, target))
	{

		//We have found a victim.
		static float belowBossEyes[3];
		GetBeamDrawStartPoint_Stock(client, belowBossEyes);
		vecHit = WorldSpaceCenter(target);
		Passanger_Lightning_Effect(belowBossEyes, vecHit, 1);
	}
	else
	{
		//We will just fire a trace on whatever we hit.

		static float belowBossEyes[3];
		GetBeamDrawStartPoint_Stock(client, belowBossEyes);
		Passanger_Lightning_Effect(belowBossEyes, vecHit, 1);
	}
}

void Passanger_Lightning_Effect(float belowBossEyes[3], float vecHit[3], int Power)
{	
	
	int r = 255; //Yellow.
	int g = 255;
	int b = 0;
	float diameter = 25.0;
	if(Power == 1)
	{
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 60);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
		TE_SendToAll(0.0);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Laser, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 60);
		TE_SetupBeamPoints(belowBossEyes, vecHit, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
		TE_SendToAll(0.0);
	}

}

public void Enable_Passanger(int client, int weapon) // Enable management, handle weapons change but also delete the timer if the client have the max weapon
{
	if (h_TimerPassangerManagement[client] != INVALID_HANDLE)
		return;
		
	if(i_CustomWeaponEquipLogic[weapon] == 9) //9 Is for Passanger
	{
		DataPack pack;
		h_TimerPassangerManagement[client] = CreateDataTimer(0.1, Timer_Management_Passanger, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
//	else
//	{	
//		Kill_Timer_Passanger(client);
//	}
}



public Action Timer_Management_Passanger(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	if(IsValidClient(client))
	{
		if (IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				Passanger_Cooldown_Logic(client, EntRefToEntIndex(pack.ReadCell()));
			}
			else
				Kill_Timer_Passanger(client);
		}
		else
			Kill_Timer_Passanger(client);
	}
	else
		Kill_Timer_Passanger(client);
		
	return Plugin_Continue;
}


public void Passanger_Cooldown_Logic(int client, int weapon)
{
	if (!IsValidMulti(client))
		return;
		
	if(IsValidEntity(weapon))
	{
		if(i_CustomWeaponEquipLogic[weapon] == 9)
		{	
			if(f_PassangerHudDelay[client] < GetGameTime())
			{
				int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
				{
					StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
					f_PassangerHudDelay[client] = GetGameTime() + 0.5;
				}
			}
		}
		else
		{
			Kill_Timer_Passanger(client);
		}
	}
	else
	{
		Kill_Timer_Passanger(client);
	}
}

public void Kill_Timer_Passanger(int client)
{
	if (h_TimerPassangerManagement[client] != INVALID_HANDLE)
	{
		KillTimer(h_TimerPassangerManagement[client]);
		h_TimerPassangerManagement[client] = INVALID_HANDLE;
	}
}

public void Weapon_Passanger_LightningArea(int client, int weapon, bool crit, int slot)
{
	ClientCommand(client, "playgamesound items/medshotno1.wav");
	SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255, 1, 0.1, 0.1, 0.1);
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
}