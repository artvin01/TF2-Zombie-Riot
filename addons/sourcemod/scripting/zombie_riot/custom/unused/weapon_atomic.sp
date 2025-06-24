#pragma semicolon 1
#pragma newdecls required

static float Strength[MAXPLAYERS];

// the R
static int use_id[MAXPLAYERS + 1]               = { 0, ... };
static int is_currently_boosted[MAXPLAYERS + 1] = { 0, ... };


static bool  BeamWand_CanUse[MAXPLAYERS];
static bool  BeamWand_IsUsing[MAXPLAYERS];
static int   BeamWand_TicksActive[MAXPLAYERS];
static int   BeamWand_Laser;
static int   BeamWand_Glow1;
static int   BeamWand_Glow2;
static float BeamWand_CloseDPT[MAXPLAYERS];
static float BeamWand_FarDPT[MAXPLAYERS];
static int   BeamWand_MaxDistance[MAXPLAYERS];
static int   BeamWand_BeamRadius[MAXPLAYERS];
static int   BeamWand_ChargeUpTime[MAXPLAYERS];
static float BeamWand_CloseBuildingDPT[MAXPLAYERS];
static float BeamWand_FarBuildingDPT[MAXPLAYERS];
static float BeamWand_Duration[MAXPLAYERS];
static float BeamWand_BeamOffset[MAXPLAYERS][3];
static float BeamWand_ZOffset[MAXPLAYERS];
static bool  BeamWand_HitDetected[MAXPLAYERS];
static int   BeamWand_BuildingHit[MAX_TARGETS_HIT];
static bool  BeamWand_UseWeapon[MAXPLAYERS];
static int   red;
static int   green;
static int   blue;

static float BeamWand_Targets_Hit[MAXPLAYERS];
// BeamWand for all the stuffs
void         Atomic_MapStart()
{
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	PrecacheSound("weapons/bison_main_shot_01.wav");
	PrecacheSound("weapons/bison_main_shot_02.wav");
	TBB_Precahce_BeamWand();
}
// main attack stuff
public void Weapon_Atomic_Beam(int client, int weapon, bool crit)
{
	int	mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if (mana_cost <= Current_Mana[client])
	{
		SDKhooks_SetManaRegenDelayTime(client, 1.0);
		Mana_Hud_Delay[client]   = 0.0;

		Current_Mana[client] -= mana_cost;

		delay_hud[client] = 0.0;

		BeamWand_Targets_Hit[client] = 0.0;

		Strength[client] = 200.0;

		is_currently_boosted[client] = 0;

		if (use_id[client] == 0)
		{    // checks if the other attack has been used and if so gives bonus dmg
			Strength[client]             = 550.0;
			use_id[client]               = 1;
			is_currently_boosted[client] = 1;
			
			EmitSoundToAll("weapons/bison_main_shot_01.wav", client, SNDCHAN_STATIC, 65, _, 0.45, 100);
			
		}

		Strength[client] *= Attributes_Get(weapon, 410, 1.0);

		red   = 255;
		green = 0;
		blue  = 0;

		//	TBB_Ability(client);
		TBB_Ability_BeamWand(client);
		//	RequestFrame(TBB_Ability_BeamWand, client);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

public void Weapon_Atomic_Beam_m2(int client, int weapon, bool crit, int slot)
{
	if (Ability_Check_Cooldown(client, slot) < 0.0)
	{

		int     mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

		if (mana_cost <= Current_Mana[client])
		{
			SDKhooks_SetManaRegenDelayTime(client, 1.0);
			Mana_Hud_Delay[client]   = 0.0;

			Current_Mana[client] -= mana_cost;

			delay_hud[client] = 0.0;

			BeamWand_Targets_Hit[client] = 0.0;

			Strength[client] = 200.0;

			is_currently_boosted[client] = 0;

			if (use_id[client] == 1)
			{    // checks if the other attack has been used and if so gives bonus dmg
				Strength[client]             = 550.0;
				use_id[client]               = 0;
				is_currently_boosted[client] = 1;
				
				EmitSoundToAll("weapons/bison_main_shot_02.wav", client, SNDCHAN_STATIC, 65, _, 0.45, 100);
			}

			Strength[client] *= Attributes_Get(weapon, 410, 1.0);
				
				
			float cooldown = 0.5;
			cooldown *= Attributes_Get(weapon, 6, 1.0);

			red   = 0;
			green = 0;
			blue  = 255;
			
			Ability_Apply_Cooldown(client, slot, cooldown);
			
			//	TBB_Ability(client);
			TBB_Ability_BeamWand(client);
			//	RequestFrame(TBB_Ability_BeamWand, client);
		}
		else
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		}
	}
}

// precache stuff - don't touch
static void TBB_Precahce_BeamWand()
{
	BeamWand_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	BeamWand_Glow1 = PrecacheModel("sprites/glow02.vmt", true);    // the normal color
	BeamWand_Glow2 = PrecacheModel("sprites/circle.vmt", true);    // the ugly color for being bad at the game :(
	PrecacheSound(SOUND_BEAMWAND_ATTACKSPEED_ABILITY);
}
// don't know
static void TBB_Ability_BeamWand(int client)
{
	for (int building = 0; building < MAX_TARGETS_HIT; building++)
	{
		BeamWand_BuildingHit[building] = false;
		BeamWand_Targets_Hit[client]   = 0.0;
	}
	/*float shoottimer;
	if(shoottimer < GetGameTime())
	{
	    ClientCommand(client, "playgamesound player/crit_hit_mini.wav");
	    shoottimer = GetGameTime() + 0.75;
	}
	*/
	BeamWand_IsUsing[client]     = false;
	BeamWand_TicksActive[client] = 0;

	BeamWand_CanUse[client]           = true;
	BeamWand_CloseDPT[client]         = 2.0;
	BeamWand_FarDPT[client]           = 1.0;
	BeamWand_MaxDistance[client]      = 1500;
	BeamWand_BeamRadius[client]       = 7;
	//	BeamWand_ColorHex[client] = ParseColor("0398FC");
	BeamWand_ChargeUpTime[client]     = 1;
	BeamWand_CloseBuildingDPT[client] = Strength[client];
	BeamWand_FarBuildingDPT[client]   = Strength[client];
	BeamWand_Duration[client]         = 2.5;

	BeamWand_BeamOffset[client][0] = 0.0;
	BeamWand_BeamOffset[client][1] = -8.0;
	BeamWand_BeamOffset[client][2] = 15.0;

	BeamWand_ZOffset[client]   = 0.0;
	BeamWand_UseWeapon[client] = false;

	BeamWand_IsUsing[client]     = true;
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
// don't know
static bool BeamWand_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
// don't know
static bool BeamWand_TraceUsers(int entity, int contentsMask, int client)
{
	static char classname[64];
	if (IsValidEntity(entity))
	{
		if (0 < entity)
		{
			GetEntityClassname(entity, classname, sizeof(classname));

			if (((!StrContains(classname, "zr_base_npc", true) && !b_NpcHasDied[entity]) || !StrContains(classname, "func_breakable", true)) && (GetTeam(entity) != GetTeam(client)))
			{
				for (int i = 1; i <= (MAX_TARGETS_HIT - 1); i++)
				{
					if (!BeamWand_BuildingHit[i])
					{
						BeamWand_BuildingHit[i] = entity;
						break;
					}
				}
			}
		}
	}
	return false;
}
// don't know
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
// seems to be color stuff
static void TBB_Tick(int client)
{
	if (!IsValidClient(client))
	{
		return;
	}

	//	int BossTeam = GetClientTeam(client);
	//	BeamWand_TicksActive[client] = tickCount;
	float diameter = float(BeamWand_BeamRadius[client] * 2);
	/*
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
	*/
	int   r        = red;
	int   g        = green;
	int   b        = blue;

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
		ConformLineDistance(endPoint, startPoint, endPoint, float(BeamWand_MaxDistance[client]));
		float lineReduce = BeamWand_BeamRadius[client] * 2.0 / 3.0;
		float curDist    = GetVectorDistance(startPoint, endPoint, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
		}
		for (int i = 1; i < MAXPLAYERS; i++)
		{
			BeamWand_HitDetected[i] = false;
		}

		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			BeamWand_BuildingHit[building] = false;
		}

		hullMin[0]             = -float(BeamWand_BeamRadius[client]);
		hullMin[1]             = hullMin[0];
		hullMin[2]             = hullMin[0];
		hullMax[0]             = -hullMin[0];
		hullMax[1]             = -hullMin[1];
		hullMax[2]             = -hullMin[2];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(client);
		delete trace;
		trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, BeamWand_TraceUsers, client);    // 1073741824 is CONTENTS_LADDER?
		FinishLagCompensation_Base_boss();
		float vecForward[3];
		GetAngleVectors(angles, vecForward, NULL_VECTOR, NULL_VECTOR);
		BeamWand_Targets_Hit[client] = 1.0;
		int weapon_active            = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		for (int building = 0; building < MAX_TARGETS_HIT; building++)
		{
			if (BeamWand_BuildingHit[building])
			{
				if (IsValidEntity(BeamWand_BuildingHit[building]))
				{
					WorldSpaceCenter(BeamWand_BuildingHit[building], playerPos);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage   = BeamWand_CloseBuildingDPT[client] + (BeamWand_FarBuildingDPT[client] - BeamWand_CloseBuildingDPT[client]) * (distance / BeamWand_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					float damage_force[3]; CalculateDamageForce(vecForward, 10000.0, damage_force);
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(BeamWand_BuildingHit[building]));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteCell(EntIndexToEntRef(client));
					pack.WriteFloat(damage / BeamWand_Targets_Hit[client]);
					pack.WriteCell(DMG_PLASMA);
					pack.WriteCell(EntIndexToEntRef(weapon_active));
					pack.WriteFloat(damage_force[0]);
					pack.WriteFloat(damage_force[1]);
					pack.WriteFloat(damage_force[2]);
					pack.WriteFloat(playerPos[0]);
					pack.WriteFloat(playerPos[1]);
					pack.WriteFloat(playerPos[2]);
					pack.WriteCell(0);
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
		if(is_currently_boosted[client] == 1)
		{
			TE_SetupBeamPoints(belowBossEyes, endPoint, BeamWand_Glow1, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.5, glowColor, 0);
		}
		else {
			TE_SetupBeamPoints(belowBossEyes, endPoint, BeamWand_Glow2, 0, 0, 0, 0.22, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.5, glowColor, 0);
		}
		TE_SendToAll(0.0);
	}

	delete trace;
}