//Use ZeroAoeKnife For func_attack and ZeroRage func_attack2
static int how_many_times_fisted[MAXTF2PLAYERS];
static int weapon_id[MAXPLAYERS+1]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
static float Original_Atackspeed[MAXPLAYERS+1]={0.0, ...};

#define MAXANGLEPITCH	65.0
#define MAXANGLEYAW		75.0

public void ZeroRage_ClearAll()
{
	Zero(ability_cooldown);
}

public void ZeroAoeKnife(int client, int weapon, bool crit)
{
	if(how_many_times_fisted[client] >= 3)
	{
		CreateTimer(0.15, ASX_Timer5, client, TIMER_FLAG_NO_MAPCHANGE);
//		CreateTimer(0.2, Apply_Effect, client, TIMER_FLAG_NO_MAPCHANGE);
		how_many_times_fisted[client] = 0;
	}
	else
	{
		how_many_times_fisted[client] += 1;
	}
}

public void ZeroAoeKnife_pap(int client, int weapon, bool crit)
{
	if(how_many_times_fisted[client] >= 2)
	{
		CreateTimer(0.15, ASX_Timer5_pap, client, TIMER_FLAG_NO_MAPCHANGE);
		how_many_times_fisted[client] = 0;
	}
	else
	{
		how_many_times_fisted[client] += 1;
	}
}

public Action ASX_Timer5(Handle timer, int client)
{
	if(client <= MaxClients)
	{
		if(IsValidClient(client))
		{
			if(IsPlayerAlive(client))
			{
				static float pos2[3], ang2[3];
				GetClientEyePosition(client, pos2);
				GetClientEyeAngles(client, ang2);
				ang2[0] = fixAngle(ang2[0]);
				ang2[1] = fixAngle(ang2[1]);
				
				float damage = 13.0;
				
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 1);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
					
				address = TF2Attrib_GetByDefIndex(weapon, 2);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
					
				address = TF2Attrib_GetByDefIndex(weapon, 476);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);	
					
				bool hit = false;
				float hit_enemies = 1.0;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client, false);
				
				for(int entitycount_2; entitycount_2<i_MaxcountNpc; entitycount_2++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount_2]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							static float pos1[3];
							GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", pos1);
							pos1[2] += 54;
							if(GetVectorDistance(pos2, pos1, true) < 30000)
							{
								static float ang3[3];
								GetVectorAnglesTwoPoints(pos2, pos1, ang3);
	
								// fix all angles
								ang3[0] = fixAngle(ang3[0]);
								ang3[1] = fixAngle(ang3[1]);
	
								// verify angle validity
								if(!(fabs(ang2[0] - ang3[0]) <= MAXANGLEPITCH ||
								(fabs(ang2[0] - ang3[0]) >= (360.0-MAXANGLEPITCH))))
									continue;
	
								if(!(fabs(ang2[1] - ang3[1]) <= MAXANGLEYAW ||
								(fabs(ang2[1] - ang3[1]) >= (360.0-MAXANGLEYAW))))
									continue;
	
								// ensure no wall is obstructing
								TR_TraceRayFilter(pos2, pos1, (CONTENTS_SOLID | CONTENTS_AREAPORTAL | CONTENTS_GRATE), RayType_EndPoint, TraceWallsOnly);
								TR_GetEndPosition(ang3);
								if(ang3[0]!=pos1[0] || ang3[1]!=pos1[1] || ang3[2]!=pos1[2])
									continue;
								
								hit = true;
								SDKHooks_TakeDamage(baseboss_index, client, client, damage/hit_enemies, DMG_CLUB, weapon);
								hit_enemies *= 1.4;
							}
						}
					}
				}
				FinishLagCompensation_Base_boss();
				if(hit)
				{
					/*
					if(IsValidEntity(weapon))
					{	
					}
					*/
					//EmitSoundToAll("weapons/samurai/tf_katana_06.wav",  client,_ ,_ ,_ ,0.75);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action ASX_Timer5_pap(Handle timer, int client)
{
	if(client <= MaxClients)
	{
		if(IsValidClient(client))
		{
			if(IsPlayerAlive(client))
			{
				static float pos2[3], ang2[3];
				GetClientEyePosition(client, pos2);
				GetClientEyeAngles(client, ang2);
				ang2[0] = fixAngle(ang2[0]);
				ang2[1] = fixAngle(ang2[1]);
				
				float damage = 17.0;
				
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 1);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
					
				address = TF2Attrib_GetByDefIndex(weapon, 2);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
					
				address = TF2Attrib_GetByDefIndex(weapon, 476);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);	
					
				bool hit = false;
				float hit_enemies = 1.0;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client, false);
				
				for(int entitycount_2; entitycount_2<i_MaxcountNpc; entitycount_2++)
				{
					int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[entitycount_2]);
					if (IsValidEntity(baseboss_index))
					{
						if(!b_NpcHasDied[baseboss_index])
						{
							static float pos1[3];
							GetEntPropVector(baseboss_index, Prop_Data, "m_vecAbsOrigin", pos1);
							pos1[2] += 54;
							if(GetVectorDistance(pos2, pos1, true) < 30000)
							{
								static float ang3[3];
								GetVectorAnglesTwoPoints(pos2, pos1, ang3);
	
								// fix all angles
								ang3[0] = fixAngle(ang3[0]);
								ang3[1] = fixAngle(ang3[1]);
	
								// verify angle validity
								if(!(fabs(ang2[0] - ang3[0]) <= MAXANGLEPITCH ||
								(fabs(ang2[0] - ang3[0]) >= (360.0-MAXANGLEPITCH))))
									continue;
	
								if(!(fabs(ang2[1] - ang3[1]) <= MAXANGLEYAW ||
								(fabs(ang2[1] - ang3[1]) >= (360.0-MAXANGLEYAW))))
									continue;
	
								// ensure no wall is obstructing
								TR_TraceRayFilter(pos2, pos1, (CONTENTS_SOLID | CONTENTS_AREAPORTAL | CONTENTS_GRATE), RayType_EndPoint, TraceWallsOnly);
								TR_GetEndPosition(ang3);
								if(ang3[0]!=pos1[0] || ang3[1]!=pos1[1] || ang3[2]!=pos1[2])
									continue;
								
								hit = true;
								SDKHooks_TakeDamage(baseboss_index, client, client, damage/hit_enemies, DMG_CLUB, weapon);
								hit_enemies *= 1.4;
							}
						}
					}
				}
				FinishLagCompensation_Base_boss();
				if(hit)
				{
					/*
					if(IsValidEntity(weapon))
					{	
					}
					*/
					//EmitSoundToAll("weapons/samurai/tf_katana_06.wav",  client,_ ,_ ,_ ,0.75);
				}
			}
		}
	}
	return Plugin_Handled;
}

public void ZeroRage(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ability_Apply_Cooldown(client, slot, 60.0);
			
			weapon_id[client] = weapon;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					if(weapon >= MaxClients)
					{
						weapon_id[client] = weapon;
					
						TF2_AddCondition(client, TFCond_DefenseBuffed, 6.5, 0);
				
						ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav")
						CreateTimer(60.0, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
						SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "Defence Rage has striked.");
					}
				}
				case 2:
				{
					if(weapon >= MaxClients)
					{
						weapon_id[client] = weapon;
				
						Original_Atackspeed[client] = 1.0;
						Address address = TF2Attrib_GetByDefIndex(weapon, 6);
						if(address != Address_Null)
						Original_Atackspeed[client] = TF2Attrib_GetValue(address);
						TF2Attrib_SetByDefIndex(weapon, 6, Original_Atackspeed[client] * 0.45);
						
						CreateTimer(60.0, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
			
						TF2_StunPlayer(client, 2.5, _, TF_STUNFLAG_BONKSTUCK, 0);
						TF2_AddCondition(client, TFCond_UberchargedHidden, 1.5, 0);
						TF2_AddCondition(client, TFCond_UberBlastResist, 1.5, 0);
			
						switch(GetRandomInt(1, 3))
						{
							case 1:
							{
								ClientCommand(client, "playgamesound items/powerup_pickup_knockout.wav");
							}
							case 2:
							{
								ClientCommand(client, "playgamesound items/powerup_pickup_strength.wav");
							}
							case 3:
							{
								ClientCommand(client, "playgamesound items/powerup_pickup_base.wav");
							}
						}
						SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "Wrath Rage has striked.");
						CreateTimer(10.0, Reset_Attackspeed, client, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
		else
		{
			float Ability_CD =  Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
}

public void ZeroDefenceRage(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ability_Apply_Cooldown(client, slot, 15.0);
			
			weapon_id[client] = weapon;
			
			TF2_AddCondition(client, TFCond_DefenseBuffed, 10.0, 0);
			
			ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav")
			
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Defence Rage has striked.");
			CreateTimer(80.0, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			float Ability_CD =  Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Ability has cooldown", Ability_CD);
		}
	}
}

public void ZeroWrathRage(int client, int weapon, bool crit, int slot)
{
	if(weapon >= MaxClients)
	{
		if (Ability_Check_Cooldown(client, slot) < 0.0)
		{
			Ability_Apply_Cooldown(client, slot, 80.0);
			
			weapon_id[client] = weapon;
			
			Original_Atackspeed[client] = 1.0;
			
			Address address = TF2Attrib_GetByDefIndex(weapon, 6);
			if(address != Address_Null)
			Original_Atackspeed[client] = TF2Attrib_GetValue(address);
			TF2Attrib_SetByDefIndex(weapon, 6, Original_Atackspeed[client] * 0.30);
			
			TF2_StunPlayer(client, 2.5, _, TF_STUNFLAG_BONKSTUCK, 0);
			TF2_AddCondition(client, TFCond_UberchargedHidden, 1.5, 0);
			TF2_AddCondition(client, TFCond_UberBlastResist, 1.5, 0);
			
			switch(GetRandomInt(1, 3))
			{
				case 1:
				{
					ClientCommand(client, "playgamesound items/powerup_pickup_knockout.wav");
				}
				case 2:
				{
					ClientCommand(client, "playgamesound items/powerup_pickup_strength.wav");
				}
				case 3:
				{
					ClientCommand(client, "playgamesound items/powerup_pickup_base.wav");
				}
			}
			SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Wrath Rage has striked.");
			CreateTimer(17.0, Reset_Attackspeed, client, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(80.0, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
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
}

public Action Ability_charged(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		ClientCommand(client, "playgamesound items/gunpickup2.wav");
		SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Rage Ability Is Back");
	}
	return Plugin_Handled;
}

public Action Reset_Attackspeed(Handle cut_timer, int client)
{
	if (IsValidClient(client))
	{
		int weapon = GetPlayerWeaponSlot(client, 2);
		if(weapon == weapon_id[client])
		{
			TF2Attrib_SetByDefIndex(weapon, 6, Original_Atackspeed[client]);
		}
	}
	return Plugin_Handled;
}