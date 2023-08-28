#pragma semicolon 1
#pragma newdecls required

static float Strength[MAXTF2PLAYERS];

static int weapon_id[MAXPLAYERS+1]={0, ...};
static float ability_cooldown[MAXPLAYERS+1]={0.0, ...};

#define SOUND_BEAMWAND_ATTACKSPEED_ABILITY "weapons/physcannon/energy_disintegrate4.wav"


static bool BeamWand_CanUse[MAXTF2PLAYERS];
static bool BeamWand_IsUsing[MAXTF2PLAYERS];
static int BeamWand_TicksActive[MAXTF2PLAYERS];
static int BeamWand_Laser;
static int BeamWand_Glow;
static float BeamWand_CloseDPT[MAXTF2PLAYERS];
static float BeamWand_FarDPT[MAXTF2PLAYERS];
static int BeamWand_MaxDistance[MAXTF2PLAYERS];
static int BeamWand_BeamRadius[MAXTF2PLAYERS];
static int BeamWand_ChargeUpTime[MAXTF2PLAYERS];
static float BeamWand_CloseBuildingDPT[MAXTF2PLAYERS];
static float BeamWand_FarBuildingDPT[MAXTF2PLAYERS];
static float BeamWand_Duration[MAXTF2PLAYERS];
static float BeamWand_BeamOffset[MAXTF2PLAYERS][3];
static float BeamWand_ZOffset[MAXTF2PLAYERS];
static bool BeamWand_HitDetected[MAXTF2PLAYERS];
static int BeamWand_BuildingHit[MAX_TARGETS_HIT];
static bool BeamWand_UseWeapon[MAXTF2PLAYERS];

static float BeamWand_Targets_Hit[MAXTF2PLAYERS];
//BeamWand for all the stuffs
void BeamWand_MapStart()
{
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	TBB_Precahce_BeamWand();
}
public void BeamWand_m2_ClearAll()
{
	Zero(ability_cooldown);
}
public void Weapon_Wand_Beam(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		BeamWand_Targets_Hit[client] = 0.0;

		Strength[client] = 65.0;
		
		Strength[client] *= Attributes_Get(weapon, 410, 1.0);
					
	//	TBB_Ability(client);
		TBB_Ability_BeamWand(client);
	//	RequestFrame(TBB_Ability_BeamWand, client);
	}
	else
	{

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}
public void Weapon_Wand_Beam_pap(int client, int weapon, bool crit)
{
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		
		Mana_Regen_Delay[client] = GetGameTime() + 1.0;
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		
		BeamWand_Targets_Hit[client] = 0.0;

		Strength[client] = 65.0;
		
		Strength[client] *= Attributes_Get(weapon, 410, 1.0);
			
					
	//	TBB_Ability(client);
		TBB_Ability_BeamWand_pap(client);
	//	RequestFrame(TBB_Ability_BeamWand, client);
	}
	else
	{

		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}
static void TBB_Precahce_BeamWand()
{
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow = PrecacheModel("sprites/glow02.vmt", true);
	PrecacheSound(SOUND_BEAMWAND_ATTACKSPEED_ABILITY);
}
public void Weapon_BeamWand_M2(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int Actualmana = Current_Mana[client]/2+50;
		int attackmana = Actualmana;
		if(attackmana >= 200)
		{
		attackmana = 200;
		}
		int mana_cost = attackmana;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				Rogue_OnAbilityUse(weapon);
				float speedtime = Actualmana / 100.0 + 5.0;
				Ability_Apply_Cooldown(client, slot, speedtime);	//Cooldown based on how much mana the player currently has.
				
				weapon_id[client] = weapon;
				
				float Original_Atackspeed = 1.0;
				
				Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
				
				Attributes_Set(weapon, 6, Original_Atackspeed * 0.25);
				
				EmitSoundToAll(SOUND_BEAMWAND_ATTACKSPEED_ABILITY, client, SNDCHAN_STATIC, 80, _, 0.9);
				
				CreateTimer(3.0, Reset_BeamWand_Attackspeed, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
				
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
				
				delay_hud[client] = 0.0;
				
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
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}
public void Weapon_BeamWand_M2_pap(int client, int weapon, bool &result, int slot)
{
	if(weapon >= MaxClients)
	{
		int Actualmana = Current_Mana[client]/2+100;
		int attackmana = Actualmana;
		if(attackmana >= 400)
		{
		attackmana = 400;
		}
		int mana_cost = attackmana;
		if(mana_cost <= Current_Mana[client])
		{
			if (Ability_Check_Cooldown(client, slot) < 0.0)
			{
				float speedtime = Actualmana / 100.0 + 5.0;
				Ability_Apply_Cooldown(client, slot, speedtime);	//Cooldown based on how much mana the player currently has.
				
				weapon_id[client] = weapon;
				
				float Original_Atackspeed = 1.0;
				
				Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);
				
				Attributes_Set(weapon, 6, Original_Atackspeed * 0.25);
				
				EmitSoundToAll(SOUND_BEAMWAND_ATTACKSPEED_ABILITY, client, SNDCHAN_STATIC, 80, _, 0.9);
				
				CreateTimer(3.0, Reset_BeamWand_Attackspeed, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
				
				Mana_Regen_Delay[client] = GetGameTime() + 1.0;
				Mana_Hud_Delay[client] = 0.0;
				
				Current_Mana[client] -= mana_cost;
				
				delay_hud[client] = 0.0;
				
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
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}


public Action Reset_BeamWand_Attackspeed(Handle cut_timer, int ref)
{
	int weapon = EntRefToEntIndex(ref);
	if (IsValidEntity(weapon))
	{
		float Original_Atackspeed;

		Original_Atackspeed = Attributes_Get(weapon, 6, 1.0);

		Attributes_Set(weapon, 6, Original_Atackspeed / 0.25);
	}
	return Plugin_Handled;
}

static void TBB_Ability_BeamWand(int client)
{
	for (int building = 1; building < MAX_TARGETS_HIT; building++)
	{
		BeamWand_BuildingHit[building] = false;
		BeamWand_Targets_Hit[client] = 0.0;
	}
	/*float shoottimer;
	if(shoottimer < GetGameTime())
	{
		ClientCommand(client, "playgamesound player/crit_hit_mini.wav");
		shoottimer = GetGameTime() + 0.75;
	}
	*/
	BeamWand_IsUsing[client] = false;
	BeamWand_TicksActive[client] = 0;

	BeamWand_CanUse[client] = true;
	BeamWand_CloseDPT[client] = 2.0;
	BeamWand_FarDPT[client] = 1.0;
	BeamWand_MaxDistance[client] = 1500;
	BeamWand_BeamRadius[client] = 7;
//	BeamWand_ColorHex[client] = ParseColor("0398FC");
	BeamWand_ChargeUpTime[client] = 1;
	BeamWand_CloseBuildingDPT[client] = Strength[client];
	BeamWand_FarBuildingDPT[client] = Strength[client];
	BeamWand_Duration[client] = 2.5;
	
	BeamWand_BeamOffset[client][0] = 0.0;
	BeamWand_BeamOffset[client][1] = -8.0;
	BeamWand_BeamOffset[client][2] = 15.0;

	BeamWand_ZOffset[client] = 0.0;
	BeamWand_UseWeapon[client] = false;

	BeamWand_IsUsing[client] = true;
	BeamWand_TicksActive[client] = 0;
	/*
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, 80, _, _, 1.0);					
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, 80, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, 80, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, 80, _, _, 1.0);
		}		
	}
			*/
	TBB_Tick(client);
//	SDKHook(client, SDKHook_PreThink, TBB_Tick);
	
//	CreateTimer(999.9, Timer_RemoveEntity, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}
static void TBB_Ability_BeamWand_pap(int client)
{
	for (int building = 1; building < MAX_TARGETS_HIT; building++)
	{
		BeamWand_BuildingHit[building] = false;
		BeamWand_Targets_Hit[client] = 0.0;
	}
	/*float shoottimer;
	if(shoottimer < GetGameTime())
	{
		ClientCommand(client, "playgamesound player/crit_hit_mini.wav");
		shoottimer = GetGameTime() + 0.75;
	}
	*/
	BeamWand_IsUsing[client] = false;
	BeamWand_TicksActive[client] = 0;

	BeamWand_CanUse[client] = true;
	BeamWand_CloseDPT[client] = 2.0;
	BeamWand_FarDPT[client] = 1.0;
	BeamWand_MaxDistance[client] = 1500;
	BeamWand_BeamRadius[client] = 7;
//	BeamWand_ColorHex[client] = ParseColor("0398FC");
	BeamWand_ChargeUpTime[client] = 1;
	BeamWand_CloseBuildingDPT[client] = 1.5 * Strength[client];
	BeamWand_FarBuildingDPT[client] = Strength[client];
	BeamWand_Duration[client] = 2.5;
	
	BeamWand_BeamOffset[client][0] = 0.0;
	BeamWand_BeamOffset[client][1] = -8.0;
	BeamWand_BeamOffset[client][2] = 15.0;

	BeamWand_ZOffset[client] = 0.0;
	BeamWand_UseWeapon[client] = false;

	BeamWand_IsUsing[client] = true;
	BeamWand_TicksActive[client] = 0;
	/*
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 80, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, 80, _, _, 1.0);					
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, 80, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, 80, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, 80, _, _, 1.0);
		}		
	}
			*/
	TBB_Tick(client);
//	SDKHook(client, SDKHook_PreThink, TBB_Tick);
	
//	CreateTimer(999.9, Timer_RemoveEntity, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
}

static bool BeamWand_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool BeamWand_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		entity = Target_Hit_Wand_Detection(client, entity);
		if(0 < entity)
		{
			for(int i=1; i <= (MAX_TARGETS_HIT -1 ); i++)
			{
				if(!BeamWand_BuildingHit[i])
				{
					BeamWand_BuildingHit[i] = entity;
					break;
				}
			}
			
		}
	}
	return false;
}

static void GetBeamDrawStartPoint(int client, float startPoint[3])
{
	GetClientEyePosition(client, startPoint);
	float angles[3];
	GetClientEyeAngles(client, angles);
	startPoint[2] -= 25.0;
	if (0.0 == BeamWand_BeamOffset[client][0] && 0.0 == BeamWand_BeamOffset[client][1] && 0.0 == BeamWand_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = BeamWand_BeamOffset[client][0];
	tmp[1] = BeamWand_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = BeamWand_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

static void TBB_Tick(int client)
{
	if(!IsValidClient(client))
	{
		return;
	}

//	int BossTeam = GetClientTeam(client);
//	BeamWand_TicksActive[client] = tickCount;
	float diameter = float(BeamWand_BeamRadius[client] * 2);
	
	int red = 255;
	int green = 0;
	int blue = 255;
		
	red = Current_Mana[client] * 255  / RoundToFloor(max_mana[client]);
	
	blue = Current_Mana[client] * 255  / RoundToFloor(max_mana[client]);
	 
	red = 255 - red;
	
	if(red > 255)
		red = 255;
	
	if(blue > 255)
		blue = 255;
		
	if(red < 0)
		red = 0;
		
	if(blue < 0)
		blue = 0;
			
	int r = red;
	int g = green;
	int b = blue;
	/*int r = GetRandomInt(1, 254);
	int g = GetRandomInt(1, 254);	// This was just for proof of recompile
	int b = GetRandomInt(1, 254);*/
	static float angles[3];
	static float startPoint[3];
	static float endPoint[3];
	static float hullMin[3];
	static float hullMax[3];
	static float playerPos[3];
	GetClientEyeAngles(client, angles);
	GetClientEyePosition(client, startPoint);
	Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, BeamWand_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(endPoint, trace);
		CloseHandle(trace);
		ConformLineDistance(endPoint, startPoint, endPoint, float(BeamWand_MaxDistance[client]));
		float lineReduce = BeamWand_BeamRadius[client] * 2.0 / 3.0;
		float curDist = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			BeamWand_HitDetected[i] = false;
		}
		
		
		for (int building = 1; building < MAX_TARGETS_HIT; building++)
		{
			BeamWand_BuildingHit[building] = false;
		}
		
		
		hullMin[0] = -float(BeamWand_BeamRadius[client]);
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BeamWand_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();
//		int weapon = BeamWand_UseWeapon[client] ? GetPlayerWeaponSlot(client, 2) : -1;
		/*
		for (int victim = 1; victim < MaxClients; victim++)
		{
			if (BeamWand_HitDetected[victim] && BossTeam != GetClientTeam(victim))
			{
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
				float distance = GetVectorDistance(startPoint, playerPos, false);
				float damage = BeamWand_CloseDPT[client] + (BeamWand_FarDPT[client]-BeamWand_CloseDPT[client]) * (distance/BeamWand_MaxDistance[client]);
				if (damage < 0)
					damage *= -1.0;
				TakeDamage(victim, client, client, damage/6, 2048, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
			}
		}
		*/
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		BeamWand_Targets_Hit[client] = 1.0;
		int weapon_active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BeamWand_BuildingHit[building])
			{
				if(IsValidEntity(BeamWand_BuildingHit[building]))
				{
					playerPos = WorldSpaceCenter(BeamWand_BuildingHit[building]);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = BeamWand_CloseBuildingDPT[client] + (BeamWand_FarBuildingDPT[client]-BeamWand_CloseBuildingDPT[client]) * (distance/BeamWand_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
					
					float damage_force[3];
					damage_force = CalculateDamageForce(vecForward, 10000.0);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BeamWand_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage/BeamWand_Targets_Hit[client]);
					pack.WriteCell(DMG_PLASMA);
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
					
					BeamWand_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
				}
				else
					BeamWand_BuildingHit[building] = false;
			}
		}
		
		static float belowBossEyes[3];
		GetBeamDrawStartPoint(client, belowBossEyes);
		int colorLayer4[4];
		SetColorRGBA(colorLayer4, r, g, b, 60);
		int colorLayer3[4];
		SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 60);
		int colorLayer2[4];
		SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 60);
		int colorLayer1[4];
		SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 60);
		TE_SetupBeamPoints(belowBossEyes, endPoint, BeamWand_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
		TE_SendToAll(0.0);
		int glowColor[4];
		SetColorRGBA(glowColor, r, g, b, 60);
		TE_SetupBeamPoints(belowBossEyes, endPoint, BeamWand_Glow, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.5, glowColor, 0);
		TE_SendToAll(0.0);
	}
	else
	{
		delete trace;
	}
}