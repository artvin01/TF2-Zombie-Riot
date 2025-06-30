#pragma semicolon 1
#pragma newdecls required

static Handle h_Gravaton_Wand_Hud_Management[MAXPLAYERS+1] = {null, ...};
static float fl_gravaton_charges[MAXPLAYERS+1];
static int i_Current_Pap[MAXPLAYERS+1];
static float fl_hud_timer[MAXPLAYERS+1];
static bool b_gained_charge[MAXPLAYERS+1];
static float fl_gravaton_duration[MAXPLAYERS+1];
static float f3_LastGravitonHitLoc[MAXPLAYERS+1][3];


#define GRAVATON_WAND_MAX_CHARGES 9.0
#define GRAVATON_WAND_CHARGES_GAIN 0.3	//how much per PRIMARY ATTACK you get
#define GRAVATON_WAND_GRAVITATION_COLLAPSE_COST 4.5

#define GRAVATON_WAND_SHOWER_CAST_SOUND1 "weapons/boxing_gloves_crit_enabled.wav"
#define GRAVATON_WAND_SHOWER_CAST_SOUND2 "items/japan_fundraiser/tf_zen_tingsha_05.wav"

#define GRAVATON_WAND_SHOWER_END_SOUND1 "weapons/bumper_car_decelerate.wav"

static int LaserIndex;

static const char Spark_Sound[][] = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav",
};

static const char Zap_Sound[][] = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav",
};

public void Gravaton_Wand_MapStart()
{
	PrecacheSound(GRAVATON_WAND_SHOWER_CAST_SOUND1, true);
	PrecacheSound(GRAVATON_WAND_SHOWER_CAST_SOUND2, true);

	PrecacheSound(GRAVATON_WAND_SHOWER_END_SOUND1, true);

	for (int i = 0; i < (sizeof(Zap_Sound));	   i++) { PrecacheSound(Zap_Sound[i]);	   }
	for (int i = 0; i < (sizeof(Spark_Sound));	   i++) { PrecacheSound(Spark_Sound[i]);	   }

	Zero(fl_hud_timer);
	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	Zero(fl_gravaton_duration);
}

public void NPC_OnTakeDmg_Gravaton_Wand(int client, int damagetype)
{
	if(damagetype & DMG_PLASMA) //Plasma is used for M1 attacks, M2 dmg will use something else
	{
		if(!b_gained_charge[client])
		{
			b_gained_charge[client]=true;
			fl_gravaton_charges[client] += GRAVATON_WAND_CHARGES_GAIN;
			if(fl_gravaton_charges[client]>=GRAVATON_WAND_MAX_CHARGES)
				fl_gravaton_charges[client] = GRAVATON_WAND_MAX_CHARGES;
		}
		
	}
}

//DMG_PLASMA


public void Enable_Gravaton_Wand(int client, int weapon) 
{
	if (h_Gravaton_Wand_Hud_Management[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon] == WEAPON_GRAVATON_WAND)
		{
			i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
			//Is the weapon it again?
			//Yes?
			delete h_Gravaton_Wand_Hud_Management[client];
			h_Gravaton_Wand_Hud_Management[client] = null;
			DataPack pack;
			h_Gravaton_Wand_Hud_Management[client] = CreateDataTimer(0.1, Timer_Gravaton_Wand, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));
			fl_hud_timer[client]=0.0;
		}
		return;
	}
	
	if(i_CustomWeaponEquipLogic[weapon] == WEAPON_GRAVATON_WAND)
	{
		i_Current_Pap[client] = RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
		DataPack pack;
		h_Gravaton_Wand_Hud_Management[client] = CreateDataTimer(0.1, Timer_Gravaton_Wand, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		fl_hud_timer[client]=0.0;
	}
}


public Action Timer_Gravaton_Wand(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		h_Gravaton_Wand_Hud_Management[client] = null;
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();
	
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon_holding == weapon) //Only show if the weapon is actually in your hand right now.
	{
		if(i_Current_Pap[client]>0)
			Gravaton_Wand_Hud(client, GameTime);
	}

	return Plugin_Continue;
}

public void Gravaton_Wand_Primary_Attack(int client, int weapon, bool crit, int slot)
{
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost <= Current_Mana[client])
	{
		bool WeakerCast = false;
		float Time= 2.5;
		float Range = 750.0;
		float Radius = 250.0;
		Current_Mana[client] -=mana_cost;
		SDKhooks_SetManaRegenDelayTime(client, 2.0);
		Range *= Attributes_Get(weapon, 103, 1.0);
		Range *= Attributes_Get(weapon, 104, 1.0);
		Range *= Attributes_Get(weapon, 475, 1.0);
		Range *= Attributes_Get(weapon, 101, 1.0);
		Range *= Attributes_Get(weapon, 102, 1.0);

		Radius *= Attributes_Get(weapon, 103, 1.0);
		Radius *= Attributes_Get(weapon, 104, 1.0);
		Radius *= Attributes_Get(weapon, 475, 1.0);
		Radius *= Attributes_Get(weapon, 101, 1.0);
		Radius *= Attributes_Get(weapon, 102, 1.0);

		float damage = 65.0;
			
		damage *= Attributes_Get(weapon, 410, 1.0);

		damage *= 1.15;

		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true); //infinite range, and ignore walls!

		float vec[3];

		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, vec);
		}
		else
		{
			delete swingTrace;
			int MaxTargethit = -1;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true,MaxTargethit); //infinite range, and ignore walls!
			TR_GetEndPosition(vec, swingTrace);
		}
		FinishLagCompensation_Base_boss();
		delete swingTrace;

		float distance = GetVectorDistance(f3_LastGravitonHitLoc[client], vec);

		if(distance < 30.0)
		{
			WeakerCast = true;
			damage *= 0.5;
		}
		f3_LastGravitonHitLoc[client] = vec;

		int color[4];
		color[0] = 240;
		color[1] = 240;
		color[2] = 240;
		color[3] = 120;

		if(WeakerCast)
		{
			color[3] = 60;
		}

		int loop_for = 7;
		float Seperation = 12.5;
		switch(i_Current_Pap[client])
		{
			case 0:
			{
				loop_for = 2;
				Seperation = 7.5;
				Time = 0.85;
			}
			case 1:
			{
				loop_for = 4;
				Seperation = 8.5;
				Time = 0.8;
			}
			case 2:
			{
				loop_for = 5;
				Seperation = 9.0;
				Time = 0.75;
			}
			case 3:
			{
				loop_for = 6;
				Seperation = 9.0;
				Time = 0.7;
			}
			case 4:
			{
				loop_for = 7;
				Seperation = 11.0;
				Time = 0.65;
			}
		}

	//	Time *= 0.75;

		//effect_hand_l

		int viewmodelModel;
		viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

		if(IsValidEntity(viewmodelModel))
		{
			float fPos[3], fAng[3];
			GetAttachment(viewmodelModel, "effect_hand_l", fPos, fAng);
			TE_SetupBeamPoints(fPos, vec, LaserIndex, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
			TE_SendToAll();
		}
		else
		{
			float pos[3];
			GetClientEyePosition(client, pos);
			TE_SetupBeamPoints(pos, vec, LaserIndex, 0, 0, 0, 0.25, 2.5, 2.5, 1, 4.0, color, 0);
			TE_SendToAll();
		}

		


		Handle data;
		CreateDataTimer(Time, Smite_Timer_Gravaton_Wand, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(data, vec[0]);
		WritePackFloat(data, vec[1]);
		WritePackFloat(data, vec[2]);
		WritePackCell(data, Radius);
		WritePackCell(data, EntIndexToEntRef(client));
		WritePackCell(data, EntIndexToEntRef(weapon));
		WritePackCell(data, damage); 

		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				EmitSoundToAll(LANTEAN_WAND_SHOT_1, client, _, 65, _, 0.35, 160);
			}
			case 2:
			{
				EmitSoundToAll(LANTEAN_WAND_SHOT_2, client, _, 65, _, 0.35, 160);
			}
		}
		vec[2]+= Seperation*loop_for+10.0;
		float thicc = 3.0;
		float Offset_Time = Time /=loop_for;
		for(int i = 1 ; i <= loop_for ; i++)
		{
			float timer = Offset_Time*i;
			if(timer<=0.02)
				timer=0.02;
			TE_SetupBeamRingPoint(vec, Radius*0.5, 0.0, LaserIndex, LaserIndex, 0, 1, timer, thicc, 0.1, color, 1, 0);

			if(i == loop_for)
				TE_SendToAll();
			else
				TE_SendToClient(client);
			vec[2]-=Seperation;
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

public Action Smite_Timer_Gravaton_Wand(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	int weapon = EntRefToEntIndex(ReadPackCell(data));
	float damage = ReadPackCell(data);
	
	
	if (!IsValidClient(client))
	{
		return Plugin_Stop;
	}
				
	i_ExplosiveProjectileHexArray[client] = EP_DEALS_PLASMA_DAMAGE;
	
	int EnemiesHitMax = (i_Current_Pap[client] + 1);
	
	b_gained_charge[client]=false;
	Explode_Logic_Custom(damage, client, client, weapon, startPosition, Ionrange,_,_,_,EnemiesHitMax);
	
	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(startPosition[0]);
	pack_boom.WriteFloat(startPosition[1]);
	pack_boom.WriteFloat(startPosition[2]);
	pack_boom.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom);

	float sky_Loc[3]; sky_Loc = startPosition;
	sky_Loc[2]+=200.0;

	int color[4];
	color[0] = 240;
	color[1] = 240;
	color[2] = 240;
	color[3] = 120;

	switch(GetRandomInt(1, 2))
	{
		case 1:
		{
			EmitSoundToAll(Zap_Sound[GetRandomInt(0, sizeof(Zap_Sound)-1)], 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, startPosition);
		}
		case 2:
		{
			EmitSoundToAll(Spark_Sound[GetRandomInt(0, sizeof(Spark_Sound)-1)], 0, SNDCHAN_STATIC, 80, _, 1.0, SNDPITCH_NORMAL, -1, startPosition);
		}		
	}

	TE_SetupBeamPoints(startPosition, sky_Loc, LaserIndex, 0, 0, 0, 0.75, 11.0, 1.0, 1, 8.0, color, 0);
	TE_SendToAll();


	return Plugin_Continue;
}

static float fl_gravaton_throttle[MAXPLAYERS+1];
static float fl_gravaton_location[MAXPLAYERS+1][3];
static float fl_gravaton_sky_location[MAXPLAYERS+1][3];
static float fl_gravaton_damage[MAXPLAYERS+1];
static float fl_gravaton_radius[MAXPLAYERS+1];
//static float fl_gravaton_cooldown[MAXPLAYERS+1][i_MaxcountNpc];
static int i_gravaton_weapon_index[MAXPLAYERS+1];

public void Gravaton_Wand_Secondary_Attack(int client, int weapon, bool crit, int slot)
{
	float GameTime = GetGameTime();

	if(fl_gravaton_duration[client]>GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Gravaton Shower Already Active!");
		return; 
	}
	if(fl_gravaton_charges[client] < GRAVATON_WAND_GRAVITATION_COLLAPSE_COST)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.\n\n[%.1f/%.1f]", fl_gravaton_charges[client], GRAVATON_WAND_GRAVITATION_COLLAPSE_COST);
		return; 
	}
	int mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	mana_cost = RoundToFloor(mana_cost*3.0);

	if(mana_cost <= Current_Mana[client])
	{
		float Time= 5.0;

		switch(i_Current_Pap[client])
		{
			case 0:
			{
				Time = 4.0;
			}
			case 1:
			{
				Time = 5.0;
			}
			case 2:
			{
				Time = 5.5;
			}
			case 3:
			{
				Time = 6.0;
			}
			case 4:
			{
				Time = 8.0;
			}
		}

		Time *= 0.5;

		fl_gravaton_charges[client] -=GRAVATON_WAND_GRAVITATION_COLLAPSE_COST;
		fl_gravaton_duration[client] =GameTime+Time;
		fl_gravaton_throttle[client] = 0.0;
		i_gravaton_weapon_index[client] = EntIndexToEntRef(weapon);
		float Range = 1000.0;
		float Radius = 300.0;
		Current_Mana[client] -=mana_cost;
		SDKhooks_SetManaRegenDelayTime(client, 2.0);


		EmitSoundToAll(GRAVATON_WAND_SHOWER_CAST_SOUND1, client, _, 65, _, 1.0, SNDPITCH_NORMAL);
		EmitSoundToAll(GRAVATON_WAND_SHOWER_CAST_SOUND2, client, _, 65, _, 0.5, SNDPITCH_NORMAL);
		

		Range *= Attributes_Get(weapon, 103, 1.0);
		Range *= Attributes_Get(weapon, 104, 1.0);
		Range *= Attributes_Get(weapon, 475, 1.0);
		Range *= Attributes_Get(weapon, 101, 1.0);
		Range *= Attributes_Get(weapon, 102, 1.0);

		Radius *= Attributes_Get(weapon, 103, 1.0);
		Radius *= Attributes_Get(weapon, 104, 1.0);
		Radius *= Attributes_Get(weapon, 475, 1.0);
		Radius *= Attributes_Get(weapon, 101, 1.0);
		Radius *= Attributes_Get(weapon, 102, 1.0);

		float damage = 20.0;
			
		damage *= Attributes_Get(weapon, 410, 1.0);

		fl_gravaton_damage[client] = damage;
		fl_gravaton_radius[client] = Radius;

		Handle swingTrace;
		b_LagCompNPC_No_Layers = true;
		float vecSwingForward[3];
		StartLagCompensation_Base_Boss(client);
		DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true); //infinite range, and ignore walls!

		float vec[3];

		int target = TR_GetEntityIndex(swingTrace);	
		if(IsValidEnemy(client, target))
		{
			WorldSpaceCenter(target, vec);
		}
		else
		{
			delete swingTrace;
			int MaxTargethit = -1;
			DoSwingTrace_Custom(swingTrace, client, vecSwingForward, Range, false, 45.0, true,MaxTargethit); //infinite range, and ignore walls!
			TR_GetEndPosition(vec, swingTrace);
		}
		FinishLagCompensation_Base_boss();
		delete swingTrace;
		

		SDKUnhook(client, SDKHook_PreThink, Gravaton_Wand_Tick);
		SDKHook(client, SDKHook_PreThink, Gravaton_Wand_Tick);

		float Sky_Loc[3]; Sky_Loc=vec;
		Gravaton_Check_The_Sky(Sky_Loc);
		fl_gravaton_sky_location[client] = Sky_Loc;


		vec[2]+10.0;

		fl_gravaton_location[client] = vec;

		int color[4];
		color[0] = 240;
		color[1] = 240;
		color[2] = 240;
		color[3] = 120;
		
		TE_SetupBeamRingPoint(vec, Radius*2.0, Radius*2.0+1.0, LaserIndex, LaserIndex, 0, 1, Time, 6.0, 0.1, color, 1, 0);
		TE_SendToAll();
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
	}
}

static void Gravaton_Check_The_Sky(float Loc[3])
{
	Loc[2]+=10.0;
	float Sky_Loc[3]; Sky_Loc = Loc; Sky_Loc[2]+=400.0;
	float vecAngles[3];
	MakeVectorFromPoints(Loc, Sky_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);

	Handle trace = TR_TraceRayFilterEx(Loc, vecAngles, 11, RayType_Infinite, Gravaton_Trace_Walls);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(Sky_Loc, trace);
		delete trace;

		float distance = GetVectorDistance(Loc, Sky_Loc);

		float buffer_vec[3]; buffer_vec = Loc;

		if(distance>400.0)
		{
			Get_Fake_Forward_Vec(400.0, vecAngles, Loc, buffer_vec);
		}
		else
		{
			Get_Fake_Forward_Vec(distance-25.0, vecAngles, Loc, buffer_vec);
		}
		
	}
	else
	{
		delete trace;
	}

}
public bool Gravaton_Trace_Walls(int entity, int contentsMask)
{
	return !entity;
}

static float fl_gravation_angle[MAXPLAYERS+1];

public Action Gravaton_Wand_Tick(int client)
{
	float GameTime = GetGameTime();

	if(fl_gravaton_duration[client] < GameTime)
	{
		EmitSoundToAll(GRAVATON_WAND_SHOWER_END_SOUND1, client, _, 65, _, 1.0, SNDPITCH_NORMAL);
		SDKUnhook(client, SDKHook_PreThink, Gravaton_Wand_Tick);
		return Plugin_Stop;
	}

	if(fl_gravaton_throttle[client]> GameTime)
	{
		return Plugin_Continue;
	}

	float Loc[3]; Loc = fl_gravaton_location[client];
	float damage = fl_gravaton_damage[client];
	float Radius = fl_gravaton_radius[client];
	float Sky_Loc[3]; Sky_Loc = fl_gravaton_sky_location[client];
	int weapon = EntRefToEntIndex(i_gravaton_weapon_index[client]);
	

	float Throttle_speed = 0.2;

	fl_gravaton_throttle[client] = GameTime+Throttle_speed;


	int Spam_Amt= 4;

	switch(i_Current_Pap[client])
	{
		case 0:
		{
			Spam_Amt= 1;	//this should never trigger....
		}
		case 1:
		{
			Spam_Amt = 1;
		}
		case 2:
		{
			Spam_Amt = 2;
		}
		case 3:
		{
			Spam_Amt = 3;
		}
		case 4:
		{
			Spam_Amt = 4;
		}
	}

	//warp

	i_ExplosiveProjectileHexArray[client] = EP_GENERIC;
	
	Explode_Logic_Custom(damage, client, client, weapon, Loc, Radius);

	if(fl_gravation_angle[client]>360.0)
		fl_gravation_angle[client]=0.0;

	fl_gravation_angle[client]+=25.0;

	for(int i=0 ; i < Spam_Amt ; i++)
	{
		float tempAngles[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] =fl_gravation_angle[client] + (360.0/Spam_Amt)*i;
		tempAngles[2] = 0.0;

		Get_Fake_Forward_Vec(GetRandomFloat(1.0, Radius), tempAngles, EndLoc, Loc);

		Gravaton_Point_effects(EndLoc, Sky_Loc, Throttle_speed);
	}

	return Plugin_Continue;
}

static void Gravaton_Point_effects(float EndVec[3], float StartVec[3], float Throttle_speed)
{
	int color[4];
	color[0] = 240;
	color[1] = 240;
	color[2] = 240;
	color[3] = 120;
	TE_SetupBeamPoints(StartVec, EndVec, LaserIndex, 0, 0, 0, Throttle_speed, 5.0, 1.0, 1, 4.0, color, 0);
	TE_SendToAll();

	switch(GetRandomInt(1,4)) 
	{
		case 1:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_1, 0, SNDCHAN_STATIC, 80, _, 0.9, SNDPITCH_NORMAL, -1, EndVec);
				
		case 2:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_2, 0, SNDCHAN_STATIC, 80, _, 0.9, SNDPITCH_NORMAL, -1, EndVec);
				
		case 3:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_3, 0, SNDCHAN_STATIC, 80, _, 0.9, SNDPITCH_NORMAL, -1, EndVec);
			
		case 4:EmitSoundToAll(SOUND_AUTOAIM_IMPACT_CONCRETE_4, 0, SNDCHAN_STATIC, 80, _, 0.9, SNDPITCH_NORMAL, -1, EndVec);
	}
}

static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}

static void Gravaton_Wand_Hud(int client, float GameTime)
{
	if(fl_hud_timer[client] > GameTime)
	{
		return;
	}
	fl_hud_timer[client] = GameTime+0.5;

	char HUDText[255] = "";

	if(fl_gravaton_duration[client] < GameTime)
	{
		Format(HUDText, sizeof(HUDText), "%sGravaton Charges: [%.1f/%.1f]", HUDText, fl_gravaton_charges[client], GRAVATON_WAND_MAX_CHARGES);
	}
	else
	{
		float Duration = fl_gravaton_duration[client]-GameTime;
		Format(HUDText, sizeof(HUDText), "%sGravaton Shower Active! [%.1f]", HUDText, Duration);
	}
	

	PrintHintText(client, HUDText);

	
}