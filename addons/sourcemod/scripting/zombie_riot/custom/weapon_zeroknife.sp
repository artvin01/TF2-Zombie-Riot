#pragma semicolon 1
#pragma newdecls required

#define MAXANGLEPITCH	65.0
#define MAXANGLEYAW		75.0

//Use ZeroAoeKnife For func_attack and ZeroRage func_attack2
static int how_many_times_fisted[MAXTF2PLAYERS];
static int weapon_id[MAXPLAYERS+1]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};
//First Knife
#define FirstDefenceRageCooldown 80.0 //How Long you can reuse it again
#define FirstDefenceRageTimer 10.0 //How Long the duration of battalions effect is

//Second Pap
#define MultiRageCooldown 60.0 //How long you can reuse it again
#define MultiDefenceRageTimer 6.5 //How long the duration of battalions effect is

#define MultiWrathStunTimer 2.5 //How long the stun duration is
#define MultiWrathUberTimer 1.5 //How long Uber is
#define MultiWrathRageSpeed 0.45 //Attack Speed Boost attribute 6
#define MultiWrathResetSpeedTimer 10.0 //Back to normal Attack speed

//Final Pap
#define FinalWrathRageCooldown 65.0 //How Long you can reuse it again
#define FinalWrathRageStunTimer 2.5 // How Long Stun is
#define FinalWrathRageUberTimer 1.5 //How long uber is
#define FinalWrathRagePapSpeed 0.38 //Attack Speed Boost attribute 6
#define FinalWrathResetSpeedTimer 17.0 //Back to normal Attack speed

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
				
				if(!IsValidEntity(weapon))
				{
					return Plugin_Handled;
				}
				damage *= Attributes_Get(weapon, 1, 1.0);
				damage *= Attributes_Get(weapon, 2, 1.0);
				damage *= Attributes_Get(weapon, 476, 1.0);
					
				bool hit = false;
				float hit_enemies = 1.0;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client);
				
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
				if(!IsValidEntity(weapon))
				{
					return Plugin_Handled;
				}
				damage *= Attributes_Get(weapon, 1, 1.0);
				damage *= Attributes_Get(weapon, 2, 1.0);
				damage *= Attributes_Get(weapon, 476, 1.0);
					
				bool hit = false;
				float hit_enemies = 1.0;
				b_LagCompNPC_No_Layers = true;
				StartLagCompensation_Base_Boss(client);
				
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
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, MultiRageCooldown);
			
			weapon_id[client] = weapon;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					if(weapon >= MaxClients)
					{
						weapon_id[client] = weapon;
					
						TF2_AddCondition(client, TFCond_DefenseBuffed, MultiDefenceRageTimer, 0);
				
						ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav");
						CreateTimer(MultiRageCooldown, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "Defence Rage has striked.");
					}
				}
				case 2:
				{
					if(weapon >= MaxClients)
					{
						weapon_id[client] = weapon;
				
						float Original_Attackspeed = 1.0;
						Original_Attackspeed = Attributes_Get(weapon, 6, 1.0);

						Attributes_Set(weapon, 6, Original_Attackspeed * MultiWrathRageSpeed);
						CreateTimer(MultiRageCooldown, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
			
						TF2_StunPlayer(client, MultiWrathStunTimer, _, TF_STUNFLAG_BONKSTUCK, 0);
						TF2_AddCondition(client, TFCond_UberchargedHidden, MultiWrathUberTimer, 0);
						TF2_AddCondition(client, TFCond_UberBlastResist, MultiWrathUberTimer, 0);
			
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
						SetDefaultHudPosition(client);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client,  SyncHud_Notifaction, "Wrath Rage has striked.");
						f_BackstabDmgMulti[weapon] = 0.0;
						CreateTimer(MultiWrathResetSpeedTimer, Reset_Attackspeed, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
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
			SetDefaultHudPosition(client);
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
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, FirstDefenceRageCooldown);
			
			weapon_id[client] = weapon;
			
			TF2_AddCondition(client, TFCond_DefenseBuffed, FirstDefenceRageTimer, 0);
			
			ClientCommand(client, "playgamesound items/powerup_pickup_resistance.wav");
			
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Defence Rage has striked.");
			CreateTimer(FirstDefenceRageCooldown, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			float Ability_CD =  Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
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
			Rogue_OnAbilityUse(weapon);
			Ability_Apply_Cooldown(client, slot, FinalWrathRageCooldown);
			
			weapon_id[client] = weapon;
			
			float Original_Attackspeed = 1.0;
			
			Original_Attackspeed = Attributes_Get(weapon, 6, 1.0);

			Attributes_Set(weapon, 6, Original_Attackspeed * FinalWrathRagePapSpeed);
			
			TF2_StunPlayer(client, FinalWrathRageStunTimer, _, TF_STUNFLAG_BONKSTUCK, 0);
			TF2_AddCondition(client, TFCond_UberchargedHidden, FinalWrathRageUberTimer, 0);
			TF2_AddCondition(client, TFCond_UberBlastResist, FinalWrathRageUberTimer, 0);
			
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
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Wrath Rage has striked.");
			f_BackstabDmgMulti[weapon] = 0.0;
			CreateTimer(FinalWrathResetSpeedTimer, Reset_Attackspeed_Final, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(FinalWrathRageCooldown, Ability_charged, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			float Ability_CD = Ability_Check_Cooldown(client, slot);
			if(Ability_CD <= 0.0)
				Ability_CD = 0.0;
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
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
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Rage Ability Is Back");
	}
	return Plugin_Handled;
}

public Action Reset_Attackspeed(Handle cut_timer, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		float Original_Atackspeed;

		f_BackstabDmgMulti[weapon] = 1.0;
		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);

		Attributes_Set(weapon, 6, Original_Atackspeed / MultiWrathRageSpeed);
	}
	return Plugin_Handled;
}

public Action Reset_Attackspeed_Final(Handle cut_timer, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		float Original_Atackspeed;

		f_BackstabDmgMulti[weapon] = 0.65;
		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);

		Attributes_Set(weapon, 6, Original_Atackspeed / FinalWrathRagePapSpeed);
	}
	return Plugin_Handled;
}
