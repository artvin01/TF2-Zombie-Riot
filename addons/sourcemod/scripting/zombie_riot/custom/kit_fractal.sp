#pragma semicolon 1
#pragma newdecls required


static Handle h_TimerManagement[MAXPLAYERS] = {null, ...};
static float fl_hud_timer[MAXPLAYERS];
static bool b_cannon_animation_active[MAXTF2PLAYERS];
static float fl_animation_cooldown[MAXTF2PLAYERS];


void Kit_Fractal_MapStart()
{
	Zero(fl_hud_timer);
	Zero(b_cannon_animation_active);
	Zero(fl_animation_cooldown);
}

enum struct Kit_Fractal_Cannon_Data
{
	int NPC_ID;
	bool Thirdperson_Before;

	void Initiate_Animation(int client)
	{
		//TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 0);
		SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 0);
	//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 0);
		SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 0);
		SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 1);
		SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 1);
		int entity, i;
		while(TF2U_GetWearable(client, entity, i))
		{
			SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
		}	

		this.Thirdperson_Before = thirdperson[client];
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");

		float vabsOrigin[3], vabsAngles[3];
		WorldSpaceCenter(client, vabsOrigin);
		GetClientEyeAngles(client, vabsAngles);
		int Spawn_Index = NPC_CreateByName("npc_fractal_cannon_animation", client, vabsOrigin, vabsAngles, GetTeam(client));
		if(Spawn_Index > 0)
		{
			this.NPC_ID = EntIndexToEntRef(Spawn_Index);
		}
	}
	void Turn_Animation(int client)
	{
		int animation = EntRefToEntIndex(this.NPC_ID);
		if(animation == -1)
		{
			this.Kill_Animation(client);
			return;
		}
		Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(animation);

		Player_Laser_Logic Laser;
		Laser.client = client;
		//todo: make these adjust with stats like firerate and such.
		Laser.DoForwardTrace_Basic(1000.0);
		npc.FaceTowards(Laser.End_Point, (65.0));
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);

		TeleportEntity(npc.index, Laser.Start_Point, NULL_VECTOR, {0.0, 0.0, 0.0});	//make 200% sure it follows the player.

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		

		//Body pitch
		float v[3], ang[3];
		SubtractVectors(VecSelfNpc, Laser.End_Point, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		
	}
	void Kill_Animation(int client)
	{
		
		int animation = EntRefToEntIndex(this.NPC_ID);
		if(animation != -1)
		{
			Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(animation);
			npc.m_iState = 1;

			SmiteNpcToDeath(animation);
		}
		if(!IsClientInGame(client))
			return;

		if(this.Thirdperson_Before && thirdperson[client])
		{
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
		}

		//TF2_RemoveCondition(client, TFCond_FreezeInput);
		SetEntProp(client, Prop_Send, "m_bIsPlayerSimulated", 1);
	//	SetEntProp(client, Prop_Send, "m_bAnimatedEveryTick", 1);
		SetEntProp(client, Prop_Send, "m_bSimulatedEveryTick", 1);
		SetEntProp(client, Prop_Send, "m_bClientSideAnimation", 1);
		SetEntProp(client, Prop_Send, "m_bClientSideFrameReset", 0);	
		SetEntProp(client, Prop_Send, "m_bForceLocalPlayerDraw", 0);
	//its too offset, clientside prediction makes this impossible
		if(!b_HideCosmeticsPlayer[client])
		{
			int entity, i;
			while(TF2U_GetWearable(client, entity, i))
			{
				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			}
		}
		else
		{
			int entity, i;
			while(TF2U_GetWearable(client, entity, i))
			{
				if(Viewchanges_NotAWearable(client, entity))
					SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			}
		}
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

Kit_Fractal_Cannon_Data Struct_Fractal_Core[MAXTF2PLAYERS];

void Activate_Fractal_Kit(int client, int weapon)
{

	if(h_TimerManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_FRACTAL)
		{
			//Is the weapon it again?
			//Yes?
			delete h_TimerManagement[client];
			h_TimerManagement[client] = null;
			DataPack pack;
			h_TimerManagement[client] = CreateDataTimer(0.1, Timer_Weapon_Managment, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_FRACTAL)
	{
		DataPack pack;
		h_TimerManagement[client] = CreateDataTimer(0.1, Timer_Weapon_Managment, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
	}
}
static int Pap(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, 122, 0.0));
}

public void Kit_Fractal_Primary_Cannon(int client, int weapon, bool &result, int slot)
{
	if(fl_animation_cooldown[client] > GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon is Recharging [%.1fs]", fl_animation_cooldown[client]-GetGameTime());
		return;
	}
	if(b_cannon_animation_active[client])
	{
		Kill_Cannon(client);
	}
	else
	{
		b_cannon_animation_active[client] = true;
		Initiate_Cannon(client, weapon);
	}
}

static float fl_fractal_turn_throttle[MAXTF2PLAYERS];
static void Kill_Cannon(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
	b_cannon_animation_active[client] = false;
	fl_animation_cooldown[client] = GetGameTime() + 5.0;	//no spaming it!
	Struct_Fractal_Core[client].Kill_Animation(client);

}

static void Initiate_Cannon(int client, int weapon)
{
	Struct_Fractal_Core[client].Initiate_Animation(client);
	SDKUnhook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
	SDKHook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
}

static void Fractal_Cannon_Tick(int client)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(h_TimerManagement[client] == null || i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_KIT_FRACTAL || !b_cannon_animation_active[client])
	{
		Kill_Cannon(client);
		return;
	}
	float GameTime = GetGameTime();
	if(fl_fractal_turn_throttle[client] > GameTime)
		return;
	
	fl_fractal_turn_throttle[client] = GameTime + 0.05;

	Struct_Fractal_Core[client].Turn_Animation(client);
}


static Action Timer_Weapon_Managment(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Kill_Cannon(client);
		
		h_TimerManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");   //get current active weapon. we don't actually use the original weapon, its there as a way to tell if something went wrong

	if(!IsValidEntity(weapon_holding))  //held weapon is somehow invalid, keep on looping...
		return Plugin_Continue;

	if(i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_KIT_FRACTAL)
		return Plugin_Continue;
		

	float GameTime = GetGameTime();

	Hud(client, weapon);

	return Plugin_Continue;
}

static void Hud(int client, int weapon)
{
	float GameTime = GetGameTime();

	if(fl_hud_timer[client] > GameTime)
		return;

	fl_hud_timer[client] = GameTime + 0.5;

	char HUDText[255] = "";

	if(IsInAnim(client))
		Format(HUDText, sizeof(HUDText), "Anim active");
	else
		Format(HUDText, sizeof(HUDText), "Anim not active");

	PrintHintText(client, HUDText);
	StopSound(client, SNDCHAN_STATIC, "UI/hint.wav");
}

static bool IsInAnim(int client)
{
	return b_cannon_animation_active[client];
}


//stuff that im probably gonna use a lot in other future weapons.

static int Player_Laser_BEAM_HitDetected[MAXENTITIES];
static int i_targets_hit;
static int i_maxtargets_hit;
enum struct Player_Laser_Logic
{
	int client;
	float Start_Point[3];
	float End_Point[3];
	float Angles[3];
	float Radius;
	float Damage;
	float Bonus_Damage;
	int damagetype;
	int max_targets;
	float target_hitfalloff;
	float range_hitfalloff;		//no work yet

	bool trace_hit;
	bool trace_hit_enemy;

	/*

	*/

	void DoForwardTrace_Basic(float Dist=-1.0)
	{
		float Angles[3], startPoint[3], Loc[3];
		WorldSpaceCenter(this.client, startPoint);
		GetClientEyeAngles(this.client, Angles);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Player_Laser_BEAM_TraceWallsOnly);

		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.trace_hit=true;
			this.Angles = Angles;
		}
		else
		{
			delete trace;
		}
		FinishLagCompensation_Base_boss();
	}
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0)
	{
		float Loc[3];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Player_Laser_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(Loc, trace);
			delete trace;


			if(Dist !=-1.0)
			{
				ConformLineDistance(Loc, startPoint, Loc, Dist);
			}
			this.Start_Point = startPoint;
			this.End_Point = Loc;
			this.Angles = Angles;
			this.trace_hit=true;
		}
		else
		{
			delete trace;
		}
		FinishLagCompensation_Base_boss();
	}

	void Deal_Damage(Function Attack_Function = INVALID_FUNCTION)
	{
		if(this.max_targets)
			i_maxtargets_hit = this.max_targets;
		else
			i_maxtargets_hit = MAX_TARGETS_HIT;

		float Falloff = LASER_AOE_DAMAGE_FALLOFF;

		if(this.target_hitfalloff)
			Falloff = this.target_hitfalloff;

		Zero(Player_Laser_BEAM_HitDetected);

		i_targets_hit = 0;

		float hullMin[3], hullMax[3];
		hullMin[0] = -this.Radius;
		hullMin[1] = hullMin[0];
		hullMin[2] = hullMin[0];
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Player_Laser_BEAM_TraceUsers, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();

		float TargetHitFalloff = 1.0;
				
		for (int loop = 0; loop < i_targets_hit; loop++)
		{
			int victim = Player_Laser_BEAM_HitDetected[loop];
			if (victim && IsValidEnemy(this.client, victim))
			{
				this.trace_hit_enemy=true;

				float playerPos[3];
				WorldSpaceCenter(victim, playerPos);

				float Dmg = this.Damage;

				if(ShouldNpcDealBonusDamage(victim))
					Dmg = this.Bonus_Damage;

				Dmg *= TargetHitFalloff;

				TargetHitFalloff *= Falloff;
				
				SDKHooks_TakeDamage(victim, this.client, this.client, Dmg, this.damagetype, -1, _, playerPos);

				if(Attack_Function && Attack_Function != INVALID_FUNCTION)
				{	
					Call_StartFunction(null, Attack_Function);
					Call_PushCell(this.client);
					Call_PushCell(victim);
					Call_PushCell(this.damagetype);
					Call_PushFloatRef(this.Damage);
					Call_Finish();

					//static void On_LaserHit(int client, int target, int damagetype, float &damage)
				}
			}
		}
	}
}

static bool Player_Laser_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
static bool Player_Laser_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		entity = Target_Hit_Wand_Detection(client, entity);
		if(0 < entity)
		{
			for(int i=0 ; i < i_maxtargets_hit ; i++)
			{
				if(!Player_Laser_BEAM_HitDetected[i])
				{
					i_targets_hit++;
					Player_Laser_BEAM_HitDetected[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}