#pragma semicolon 1
#pragma newdecls required


static Handle h_TimerManagement[MAXPLAYERS] = {null, ...};
static float fl_hud_timer[MAXPLAYERS];
static bool b_cannon_animation_active[MAXPLAYERS];
static float fl_animation_cooldown[MAXPLAYERS];

static bool b_Thirdperson_Before[MAXPLAYERS];
static int i_NPC_ID[MAXPLAYERS];
static float fl_magia_angle[MAXPLAYERS];
static float fl_fractal_laser_dist[MAXPLAYERS];
static float fl_fractal_laser_trace_throttle[MAXPLAYERS];
static float fl_fractal_turn_throttle[MAXPLAYERS];
static float fl_fractal_dmg_throttle[MAXPLAYERS];
static bool b_overdrive_active[MAXPLAYERS];
static float fl_main_laser_distance[MAXPLAYERS];
static int i_cosmetic_effect[MAXPLAYERS];

static int i_WeaponGotLastmanBuff[MAXENTITIES];

static float f_AniSoundSpam[MAXPLAYERS];
#define FRACTAL_KIT_SHIELDSOUND1 "weapons/rescue_ranger_charge_01.wav"
#define FRACTAL_KIT_SHIELDSOUND2 "weapons/rescue_ranger_charge_02.wav"

#define FRACTAL_KIT_PASSIVE_OVERDRIVE_COST 1.0
#define FRACTAL_KIT_FANTASIA_COST 7.0
#define FRACTAL_KIT_FANTASIA_GAIN 3.0		//how many crystals the player gains when fantasia does dmg
#define FRACTAL_KIT_STARFALL_COST 75.0
#define FRACTAL_KIT_FANTASIA_ONHIT_LOSS 0.8	//how much dmg is reduced every time fantasia does damage
#define FRACTAL_KIT_STARFALL_JUMP_AMT	10	//how many times the ion can multi strike.
#define FRACTAL_KIT_HARVESTER_CRYSTALGAIN 0.15
#define FRACTAL_KIT_STARFALL_FALLOFF 0.7	//how much to reduce dmg per bounce/jump
static float fl_max_crystal_amt[MAXPLAYERS];
static float fl_current_crystal_amt[MAXPLAYERS];
static float fl_starfall_CD[MAXPLAYERS];
/*
	//the anim npc has the medic backpack, this annoys me greatly
*/
static float f_HarvesterM2CD[] = {
	30.0,	//case -1:
	27.0,	//case 0:
	24.0,	//case 1:
	21.0,	//case 2:
	18.0,	//case 3:
	15.0,	//case 4:
	12.0,	//case 5:
	9.0,	//case 6:
	6.0,	//case 7:
};
static float f_GetHarvesterM2_CD(int pap)
{
	return f_HarvesterM2CD[pap+1];
}

static void Adjust_Crystal_Stats(int client, int weapon)
{
	fl_hud_timer[client] = 0.0;
	b_overdrive_active[client] = false;
	fl_main_laser_distance[client] = 1000.0;
	switch(Pap(weapon))
	{
		case -1:
		{
			fl_max_crystal_amt[client] = 50.0;
			fl_main_laser_distance[client] = 1000.0;
		}
		case 0:
		{
			fl_max_crystal_amt[client] = 75.0;
			fl_main_laser_distance[client] = 1111.0;
		}
		case 1:
		{
			fl_max_crystal_amt[client] = 80.0;
			fl_main_laser_distance[client] = 1250.0;
		}
		case 2:
		{
			fl_max_crystal_amt[client] = 85.0;
			fl_main_laser_distance[client] = 1325.0;
		}
		case 3:
		{
			fl_max_crystal_amt[client] = 90.0;
			fl_main_laser_distance[client] = 1400.0;
		}
		case 4:
		{
			fl_max_crystal_amt[client] = 95.0;
			fl_main_laser_distance[client] = 1450.0;
		}
		case 5:
		{
			fl_max_crystal_amt[client] = 100.0;
			fl_main_laser_distance[client] = 1500.0;
		}
		case 6:
		{
			fl_max_crystal_amt[client] = 105.0;
			fl_main_laser_distance[client] = 1750.0;
		}	
		case 7:
		{
			fl_max_crystal_amt[client] = 110.0;
			fl_main_laser_distance[client] = 2000.0;
		}	
	}
	fl_max_crystal_amt[client] += 25.0;
	fl_main_laser_distance[client] += 250.0;
		
}
bool Fractal_LastMann(int client)
{
	return h_TimerManagement[client] != null;	
}
static void HaloManagment(int client, bool force = false)
{
	if(b_cannon_animation_active[client] && !force)
		return;

	int halo_particle = EntRefToEntIndex(i_cosmetic_effect[client]);
	
	if(IsValidEntity(halo_particle))
		return;
	/*
	
	*/
	if(AtEdictLimit(EDICT_PLAYER))
	{
		Delete_Halo(client);
		return;
	}

	int viewmodelModel;
	viewmodelModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);

	if(MagiaWingsDo(client) && IsValidEntity(viewmodelModel))
	{
		// :3
		float flPos[3];
		GetAttachment(viewmodelModel, "head", flPos, NULL_VECTOR);
		flPos[2] += 10.0;
		int particle = ParticleEffectAt(flPos, "unusual_invasion_boogaloop_2", 0.0);
		AddEntityToThirdPersonTransitMode(client, particle);
		SetParent(viewmodelModel, particle, "head");
		i_cosmetic_effect[client] = EntIndexToEntRef(particle);
		return;
	}

	float flPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flPos);
	flPos[2] += 2.0;
	int particle = ParticleEffectAt(flPos, "utaunt_treespiral_purple_base", -1.0);
	SetParent(client, particle);
	i_cosmetic_effect[client] = EntIndexToEntRef(particle);
}
static void Delete_Halo(int client)
{
	int halo_particle = EntRefToEntIndex(i_cosmetic_effect[client]);
	
	if(IsValidEntity(halo_particle))
	{
		TeleportEntity(halo_particle, OFF_THE_MAP);
		RemoveEntity(halo_particle);
		i_cosmetic_effect[client] = INVALID_ENT_REFERENCE;
	}
}

static void Initiate_Animation(int client, int weapon)
{
	Attributes_Set(weapon, 698, 1.0);
	//TF2_AddCondition(client, TFCond_FreezeInput, -1.0);

	int WeaponModel;
	WeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(IsValidEntity(WeaponModel))
	{
		SetEntityRenderMode(WeaponModel, RENDER_NONE); //Make it entirely invis.
		SetEntityRenderColor(WeaponModel, 255, 255, 255, 1);
	}

	fl_magia_angle[client] = GetRandomFloat(0.0, 360.0);

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

	b_Thirdperson_Before[client] = thirdperson[client];
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");

	float vabsOrigin[3], vabsAngles[3];
	WorldSpaceCenter(client, vabsOrigin);
	GetClientEyeAngles(client, vabsAngles);
	vabsAngles[0] = 0.0;
	vabsAngles[2] = 0.0;
	int Spawn_Index = NPC_CreateByName("npc_fractal_cannon_animation", client, vabsOrigin, vabsAngles, GetTeam(client));
	if(Spawn_Index > 0)
	{
		i_NPC_ID[client] = EntIndexToEntRef(Spawn_Index);
	}
}
static void Turn_Animation(int client, int weapon)
{
	int animation = EntRefToEntIndex(i_NPC_ID[client]);
	if(animation == -1)
	{
		Kill_Animation(client);
		return;
	}
	Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(animation);

	float Start_Loc[3];
	WorldSpaceCenter(client, Start_Loc);
	if(fl_fractal_laser_trace_throttle[client] < GetGameTime())
	{
		fl_fractal_laser_trace_throttle[client] = GetGameTime() + 0.1;
		
		//weird bug: for some reason the movetype none sticks even though movetype_walk is set.
		//this bug has only appeard when the player has run out of mana and was forced out of the animation.
		//I have no clue why its only happened then.
		//but if it happens again after this change, then clearly I was wrong. and I have zero clue how to fix it.
		//and I can't make it set movetype none only once since every round start / raid spawn, movetype is reset
		//meaning the player can move around fully while firing the deathray.
		if(Current_Mana[client] > 100)
			SetEntityMoveType(client, MOVETYPE_NONE);
	}	

	float LookVec[3]; LookVec = Start_Loc;
	float Angles[3]; 
	GetClientEyeAngles(client, Angles);
	Get_Fake_Forward_Vec(200.0, Angles, LookVec, LookVec);

	float turn_speed = 65.0;
	float firerate1 = Attributes_Get(weapon, 6, 1.0);
	float firerate2 = Attributes_Get(weapon, 5, 1.0);
	turn_speed /= firerate1;
	turn_speed /= firerate2;

	//double turn rate.
	if(LastMann)
		turn_speed *=2.0;

	if(b_overdrive_active[client])
		turn_speed *=1.2;
	
	npc.FaceTowards(LookVec, turn_speed);
	float VecSelfNpc2[3]; 
	GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", VecSelfNpc2);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float Tele_Loc[3]; Tele_Loc = Start_Loc; Tele_Loc[2]-=37.0;

	TeleportEntity(npc.index, VecSelfNpc2, NULL_VECTOR, {0.0, 0.0, 0.0});	//make 200% sure it follows the player.

	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, LookVec, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
							
	float flPitch = npc.GetPoseParameter(iPitch);
							
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	
}
static void Fire_Beam(int client, int weapon, bool update)
{
	int animation = EntRefToEntIndex(i_NPC_ID[client]);
	if(animation == -1)
	{
		Kill_Animation(client);
		return;
	}
	Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(animation);

	if(npc.m_flNextRangedBarrage_Spam > GetGameTime() && npc.m_flNextRangedBarrage_Spam != FAR_FUTURE)
		return;

	float Radius = 30.0;
	float diameter = Radius*2.0;
	if(update)
	{
		int WeaponModel;
		WeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
		if(IsValidEntity(WeaponModel))
		{
			SetEntityRenderMode(WeaponModel, RENDER_NONE); //Make it entirely invsible.
			SetEntityRenderColor(WeaponModel, 255, 255, 255, 1);
		}

		int mana_cost;
		mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

		if(mana_cost > Current_Mana[client])
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);

			Kill_Cannon(client);
			return;
		}

		SDKhooks_SetManaRegenDelayTime(client, 2.5);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
	}
	float 	flPos[3], // original
			flAng[3]; // original
	float Angles[3];

	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	
	float flPitch = 0.0;
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch >= 0)
	{
		flPitch = npc.GetPoseParameter(iPitch);
	}
	flPitch *=-1.0;
	if(flPitch>25.0)	//limit the pitch. by a lot
		flPitch=25.0;
	if(flPitch <-50.0)
		flPitch = -50.0;
	Angles[0] = flPitch;
	GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
	//flPos[2]+=37.0;
	//Get_Fake_Forward_Vec(-10.0, Angles, flPos, flPos);

	Offset_Vector({-10.0, 2.5, 2.5}, Angles, flPos);	//{-10.0, 2.5, 2.5}

	float EndLoc[3]; 

	int color[4];
	color[0] = 0;
	color[1] = 250;
	color[2] = 237;	
	color[3] = 255;

	bool Mouse2 = (GetClientButtons(client) & IN_ATTACK2) != 0;

	if((b_overdrive_active[client] && !Mouse2) || fl_current_crystal_amt[client] <= FRACTAL_KIT_PASSIVE_OVERDRIVE_COST * 2.0)
		b_overdrive_active[client] = false;
	
	if(update)
	{
		Player_Laser_Logic Laser;
		Laser.client = client;
		float dps = 130.0;
		float range = fl_main_laser_distance[client];
		
		if(b_overdrive_active[client])
		{
			dps *= 1.1;
			range *=1.15;
			fl_current_crystal_amt[client] -=FRACTAL_KIT_PASSIVE_OVERDRIVE_COST;
		}
		range *= Attributes_Get(weapon, 103, 1.0);
		range *= Attributes_Get(weapon, 104, 1.0);
		range *= Attributes_Get(weapon, 475, 1.0);
		range *= Attributes_Get(weapon, 101, 1.0);
		range *= Attributes_Get(weapon, 102, 1.0);
		Laser.DoForwardTrace_Custom(Angles, flPos, range);
		dps *=Attributes_Get(weapon, 410, 1.0);
		Laser.Damage = dps;
		Laser.Radius = Radius;
		Laser.damagetype = DMG_PLASMA;
		PlayerLaserDoDamageCombined(Laser, dps, dps*0.3);
		fl_fractal_laser_dist[client] = GetVectorDistance(Laser.End_Point, flPos);
		EndLoc = Laser.End_Point;
		
	}
	else
	{
		Get_Fake_Forward_Vec(fl_fractal_laser_dist[client], Angles, EndLoc, flPos);
	}
	
	float TE_Duration = 0.1;
	
	float Offset_Loc[3];
	Get_Fake_Forward_Vec(50.0, Angles, Offset_Loc, flPos);

	int colorLayer4[4];
	SetColorRGBA(colorLayer4, color[0], color[1], color[2], color[1]);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, color[3]);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, color[3]);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 7255 / 8, colorLayer4[1] * 5 + 7255 / 8, colorLayer4[2] * 5 + 7255 / 8, color[3]);

	float 	Rng_Start = GetRandomFloat(diameter*0.3, diameter*0.5);

	float 	Start_Diameter1 = ClampBeamWidth(Rng_Start*0.7),
			Start_Diameter2 = ClampBeamWidth(Rng_Start*0.9),
			Start_Diameter3 = ClampBeamWidth(Rng_Start);
		
	float 	End_Diameter1 = ClampBeamWidth(diameter*0.7),
			End_Diameter2 = ClampBeamWidth(diameter*0.9),
			End_Diameter3 = ClampBeamWidth(diameter);

	int Beam_Index = g_Ruina_BEAM_Combine_Blue;

	//the rest of the beam thats the long part
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter1*0.9, End_Diameter1, 0, 0.1, colorLayer2, 3);
	Send_Te_Client_ZR(client);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter2*0.9, End_Diameter2, 0, 0.1, colorLayer3, 3);
	Send_Te_Client_ZR(client);
	TE_SetupBeamPoints(Offset_Loc, EndLoc, Beam_Index, 	0, 0, 66, TE_Duration, Start_Diameter3*0.9, End_Diameter3, 0, 0.1, colorLayer4, 3);
	Send_Te_Client_ZR(client);
	
	//the tiny part of the beam thats at the start.
	colorLayer2[3] = 150;
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter1, 0, 7.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index, 	0, 0, 66, TE_Duration, 0.0, Start_Diameter2, 0, 7.0, colorLayer3, 3);
	Send_Te_Client_ZR(client);
	TE_SetupBeamPoints(flPos, Offset_Loc, Beam_Index,	0, 0, 66, TE_Duration, 0.0, Start_Diameter3, 0, 7.0, colorLayer4, 3);
	Send_Te_Client_ZR(client);

	if(fl_magia_angle[client]>360.0)
		fl_magia_angle[client] -=360.0;
	
	fl_magia_angle[client]+=2.5/TickrateModify;

	Fractal_Magia_Rings(client, Offset_Loc, Angles, 3, true, 40.0, 1.0, TE_Duration, color, EndLoc);

	npc.PlayLaserLoopSound();
}
void Format_Fancy_Hud(char Text[255])
{
	ReplaceString(Text, 500, "Ą", "「");
	ReplaceString(Text, 500, "Č", "」");
	ReplaceString(Text, 500, "Ę", "【");
	ReplaceString(Text, 500, "Ė", "】");
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static void Fractal_Magia_Rings(int client, float Origin[3], float Angles[3], int loop_for, bool Type=true, float distance_stuff, float ang_multi, float TE_Duration, int color[4], float drill_loc[3])
{
	float buffer_vec[3][3];
		
	for(int i=0 ; i<loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (fl_magia_angle[client]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		if(Type)
		{
			int r=175, g=175, b=175, a=175;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, drill_loc, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			Send_Te_Client_ZR(client);
		}
		
	}
	
	TE_SetupBeamPoints(buffer_vec[0], buffer_vec[loop_for-1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
	Send_Te_Client_ZR(client);
	for(int i=0 ; i<(loop_for-1) ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Combine_Blue, 0, 0, 0, TE_Duration, 5.0, 5.0, 0, 0.01, color, 3);	
		Send_Te_Client_ZR(client);
	}
	
}
static void Kill_Animation(int client)
{
	
	int animation = EntRefToEntIndex(i_NPC_ID[client]);
	if(animation != -1)
	{
		Fracatal_Kit_Animation npc = view_as<Fracatal_Kit_Animation>(animation);
		npc.m_iState = 1;

		//SmiteNpcToDeath(animation);
	}
	if(!IsClientInGame(client))
		return;

	if(!b_Thirdperson_Before[client] && !thirdperson[client])
	{
		SetVariantInt(0);
		AcceptEntityInput(client, "SetForcedTauntCam");
		ViewChange_Update(client, false);
	}

	int WeaponModel;
	WeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(IsValidEntity(WeaponModel))
	{
		SetEntityRenderMode(WeaponModel, RENDER_NORMAL); //Make it entirely visible.
		SetEntityRenderColor(WeaponModel, 255, 255, 255, 255);
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
void Activate_Fractal_Kit(int client, int weapon)
{
	if(h_TimerManagement[client] != null)
	{
		//This timer already exists.
		if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_FRACTAL)
		{
			//Is the weapon it again?
			//Yes?
			if(b_cannon_animation_active[client])
				Kill_Cannon(client);
			
			i_WeaponGotLastmanBuff[weapon] = false;
			delete h_TimerManagement[client];
			h_TimerManagement[client] = null;
			DataPack pack;
			h_TimerManagement[client] = CreateDataTimer(0.1, Timer_Weapon_Managment, pack, TIMER_REPEAT);
			pack.WriteCell(client);
			pack.WriteCell(EntIndexToEntRef(weapon));

			Adjust_Crystal_Stats(client, weapon);
			if(FileNetwork_Enabled())
				PrecacheTwirlMusic();
			
		}
		return;
	}
		
	if(i_CustomWeaponEquipLogic[weapon]==WEAPON_KIT_FRACTAL)
	{
		if(b_cannon_animation_active[client])
			Kill_Cannon(client);

		i_WeaponGotLastmanBuff[weapon] = false;

		if(FileNetwork_Enabled())
			PrecacheTwirlMusic();
			
		DataPack pack;
		h_TimerManagement[client] = CreateDataTimer(0.1, Timer_Weapon_Managment, pack, TIMER_REPEAT);
		pack.WriteCell(client);
		pack.WriteCell(EntIndexToEntRef(weapon));
		Adjust_Crystal_Stats(client, weapon);
	}
}
static int Pap(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, Attrib_PapNumber, 0.0));
}
static int Slot(int weapon)
{
	return RoundFloat(Attributes_Get(weapon, 868, 0.0));
}

#define FRACTAL_FANTASIA_AMT 4

static int i_fantasia_laser_ref[MAXPLAYERS][FRACTAL_FANTASIA_AMT];
static int i_fantasia_particle[MAXPLAYERS][FRACTAL_FANTASIA_AMT];

static float fl_fantasia_angles[MAXPLAYERS][FRACTAL_FANTASIA_AMT][3];

static float fl_fantasia_origin[MAXPLAYERS][3];
static float fl_fantasia_throttle[MAXPLAYERS];
static float fl_fantasia_duration[MAXPLAYERS];
static float fl_fantasia_distance = 750.0;
static float fl_fantasia_lens = 3.0;	//the small the number, the wider, the larger the number, the narrower.
static float fl_fantasia_duration_base = 1.7;	
static float fl_fantasia_radius = 17.0;

static void Delete_Fantasia(int client)
{
	for(int i=0 ; i < FRACTAL_FANTASIA_AMT ; i ++)
	{
		int env_beam = EntRefToEntIndex(i_fantasia_laser_ref[client][i]);
		int particle = EntRefToEntIndex(i_fantasia_particle[client][i]);
		
		if(IsValidEntity(env_beam))
		{
			RemoveEntity(env_beam);
		}
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}

		i_fantasia_particle[client][i] = INVALID_ENT_REFERENCE;
		i_fantasia_laser_ref[client][i] = INVALID_ENT_REFERENCE;
	}
}
static int i_fantasia_hitcount[MAXPLAYERS];
static float fl_fantasia_targetshit[MAXPLAYERS];
static float fl_fantasia_damage[MAXPLAYERS];
static float fl_fantasia_true_duration[MAXPLAYERS];

public void Fantasia_Mouse1(int client, int weapon, bool &result, int slot)
{
	if(b_cannon_animation_active[client])
	{
		return;
	}
	if(fl_current_crystal_amt[client] < FRACTAL_KIT_FANTASIA_COST)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
		return;
	}
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost > Current_Mana[client] && !b_cannon_animation_active[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	switch(GetRandomInt(1, 2))
	{
		case 1:
		{
			EmitSoundToAll(FANTASY_BLADE_SHOOT_1, client, _, 65, _, 0.75, GetRandomInt(60, 80));
		}
		case 2:
		{
			EmitSoundToAll(FANTASY_BLADE_SHOOT_2, client, _, 65, _, 0.75, GetRandomInt(60, 80));
		}
	}

	fl_current_crystal_amt[client] -=FRACTAL_KIT_FANTASIA_COST;
	Current_Mana[client] -=mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.5);
	Mana_Hud_Delay[client] = 0.0;

	Delete_Fantasia(client);

	float GameTime = GetGameTime();

	float Time = fl_fantasia_duration_base;

	//fantasia has a very high firerate penalty, due to that I need to make sure the adjustment here compensates for that.
	Time *= (Attributes_Get(weapon, 6, 3.0)/3.0);

	fl_fantasia_true_duration[client] = Time;
	fl_fantasia_duration[client] = GameTime + Time;

	fl_fantasia_throttle[client] = 0.0;

	float Origin[3];
	GetClientEyePosition(client, Origin);

	Origin[2]-=17.5;

	i_fantasia_hitcount[client] = 0;
	fl_fantasia_targetshit[client] = 1.0;
	fl_fantasia_damage[client] = 100.0;
	fl_fantasia_damage[client] *= Attributes_Get(weapon, 410, 1.0);

	Create_Fantasia(client, Origin);

	fl_fantasia_origin[client] = Origin;

	SDKUnhook(client, SDKHook_PreThink, Fantasia_Tick);
	SDKHook(client, SDKHook_PreThink, Fantasia_Tick);
}
static void Create_Fantasia(int client, float Loc[3])
{
	int color[3];
	float Width[2]; Width[0] = fl_fantasia_radius*0.2; Width[1] = fl_fantasia_radius*0.2;
	color = {0, 125, 180};
	
	float ang_Look[3];

	GetClientEyeAngles(client, ang_Look);

	float Distancing = 50.0;

	float Offset = Distancing *(FRACTAL_FANTASIA_AMT * -0.5)+Distancing*0.5;
	
	int previus_dot = INVALID_ENT_REFERENCE;

	for(int i=0 ; i <FRACTAL_FANTASIA_AMT ; i ++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		
		tempAngles[0] = ang_Look[0];
		tempAngles[1] = ang_Look[1];
		tempAngles[2] = 90.0;

		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, Offset);
		AddVectors(Loc, Direction, endLoc);

		float Buffer_Loc[3];

		//1.75
		Get_Fake_Forward_Vec(Distancing*fl_fantasia_lens, ang_Look, Buffer_Loc, endLoc);

		Offset+=Distancing;

		float Angles[3];
		MakeVectorFromPoints(Loc, Buffer_Loc, Angles);
		GetVectorAngles(Angles, Angles);

		float Offset_Loc[3];

		fl_fantasia_angles[client][i] = Angles;

		Get_Fake_Forward_Vec(100.0, Angles, Offset_Loc, Loc);
		
		int dot = Ruina_Create_Entity(Offset_Loc, 0.0, false);

		if(previus_dot!=INVALID_ENT_REFERENCE && !AtEdictLimit(EDICT_PLAYER))
		{
			int laster = ConnectWithBeamClient(previus_dot, dot, color[0], color[1], color[2], Width[0], Width[1], 0.1, LASERBEAM);
			if(IsValidEntity(laster))
			{
				i_fantasia_laser_ref[client][i] = EntIndexToEntRef(laster);
			}
		}	
		

		if(IsValidEntity(dot))
		{
			i_fantasia_particle[client][i] = EntIndexToEntRef(dot);
			previus_dot = dot;
		}
	}
}

static Action Fantasia_Tick(int client)
{
	float GameTime = GetGameTime();

	if(b_invalid_client(client) || fl_fantasia_duration[client] < GameTime || i_fantasia_hitcount[client] >= 10)
	{

		Delete_Fantasia(client);
		SDKUnhook(client, SDKHook_PreThink, Fantasia_Tick);

		return Plugin_Stop;
	}

	float Ratio = 1.0-(fl_fantasia_duration[client]-GameTime)/fl_fantasia_true_duration[client];

	float Distance = fl_fantasia_distance*Ratio;

	float Origin[3];
	Origin = fl_fantasia_origin[client];

	float Previous_Loc[3];

	bool Throttle_Tick = false;

	if(fl_fantasia_throttle[client] < GameTime)
	{
		fl_fantasia_throttle[client] = GameTime + 0.1;
		Throttle_Tick = true;
	}
	
	for(int i=0 ; i <FRACTAL_FANTASIA_AMT ; i ++)
	{
		float Angles[3]; Angles = fl_fantasia_angles[client][i];
		float endLoc[3]; 

		Get_Fake_Forward_Vec(Distance, Angles, endLoc, Origin);

		int point = EntRefToEntIndex(i_fantasia_particle[client][i]);
		if(IsValidEntity(point))
		{
			Fractal_Move_Entity(point, endLoc, NULL_VECTOR);
		}
		if(i>0)
		{
			if(Throttle_Tick)
			{
				Player_Laser_Logic Laser;
				Laser.client = client;
				Laser.Radius = fl_fantasia_radius;
				Laser.End_Point = Previous_Loc;
				Laser.Start_Point = endLoc;
				Laser.Damage = fl_fantasia_damage[client];
				Laser.Detect_Targets(OnFantasiaHit);
			}
		}
		Previous_Loc = endLoc;
	}
	return Plugin_Continue;
}
void Fractal_Move_Entity(int entity, float loc[3], float Ang[3], bool old=false)
{
	if(IsValidEntity(entity))	
	{
		if(old)
		{
			//the version bellow creates some "funny" movements/interactions..
			float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
					
			MakeVectorFromPoints(Entity_Loc, loc, vecView);
			GetVectorAngles(vecView, vecView);
			
			float dist = GetVectorDistance(Entity_Loc, loc);

			GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
		
			Entity_Loc[0]+=vecFwd[0] * dist;
			Entity_Loc[1]+=vecFwd[1] * dist;
			Entity_Loc[2]+=vecFwd[2] * dist;
			
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecFwd);
			
			SubtractVectors(Entity_Loc, vecFwd, vecVel);
			ScaleVector(vecVel, 10.0);

			TeleportEntity(entity, NULL_VECTOR, Ang, vecVel);
		}
		else
		{
			float flNewVec[3], flRocketPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flRocketPos);
			float Ratio = (GetVectorDistance(loc, flRocketPos))/250.0;

			if(Ratio<0.075)
				Ratio=0.075;

			float flSpeedInit = 1250.0*Ratio;
		
			SubtractVectors(loc, flRocketPos, flNewVec);
			NormalizeVector(flNewVec, flNewVec);
			
			float flAng[3];
			GetVectorAngles(flNewVec, flAng);
			
			ScaleVector(flNewVec, flSpeedInit);
			TeleportEntity(entity, NULL_VECTOR, Ang, flNewVec);
		}
	}
}
static void OnFantasiaHit(int client, int target, int damagetype, float &damage)
{
	//Fantsasy blade will have an offset of (MAXENTITIES 
	//Client instead of target, so it gets removed if the target dies
	if(IsIn_HitDetectionCooldown(client + MAXENTITIES,target))
	{
		return;
	}
	Set_HitDetectionCooldown(client + MAXENTITIES,target, GetGameTime() + 1.0);

	float dps = fl_fantasia_damage[client]*fl_fantasia_targetshit[client];
	fl_fantasia_targetshit[client] *= FRACTAL_KIT_FANTASIA_ONHIT_LOSS;
	SDKHooks_TakeDamage(target, client, client, dps, DMG_PLASMA);
	
	fl_current_crystal_amt[client] += ((b_thisNpcIsARaid[target] || b_thisNpcIsABoss[target]) ? FRACTAL_KIT_FANTASIA_GAIN * 4.0 : FRACTAL_KIT_FANTASIA_GAIN);

	i_fantasia_hitcount[client]++;

	if(fl_current_crystal_amt[client] > fl_max_crystal_amt[client])
		fl_current_crystal_amt[client] = fl_max_crystal_amt[client];
}
public void Kit_Fractal_OverDrive(int client, int weapon, bool &result, int slot)
{
	if(!b_cannon_animation_active[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon is Offline");
	}
	if(fl_animation_cooldown[client] > GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Laser Cannon is Recharging [%.1fs]", fl_animation_cooldown[client]-GetGameTime());
		return;
	}
	if(fl_current_crystal_amt[client] < FRACTAL_KIT_PASSIVE_OVERDRIVE_COST*2.0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
		return;
	}

	b_overdrive_active[client] = true;
}

static int i_targeted_ID[MAXPLAYERS][FRACTAL_KIT_STARFALL_JUMP_AMT];
public void Kit_Fractal_Starfall(int client, int weapon, bool &result, int slot)
{
	float GameTime = GetGameTime();
	if(b_cannon_animation_active[client])
	{
		return;
	}
	if(fl_current_crystal_amt[client] < FRACTAL_KIT_STARFALL_COST)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "Your Weapon is not charged enough.");
		return;
	}
	if(fl_starfall_CD[client] > GameTime)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "StarFall is Recharging [%.1fs]", fl_starfall_CD[client]-GetGameTime());
		return;
	}
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	if(mana_cost > Current_Mana[client] && !b_cannon_animation_active[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	fl_starfall_CD[client] = GameTime + f_GetHarvesterM2_CD(Pap(weapon));

	Current_Mana[client] -=mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.5);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;

	for(int i=0 ; i < FRACTAL_KIT_STARFALL_JUMP_AMT ; i++)
	{
		i_targeted_ID[client][i] = INVALID_ENT_REFERENCE;
	}
	fl_current_crystal_amt[client] -=FRACTAL_KIT_STARFALL_COST;
	Player_Laser_Logic Laser;
	Laser.client = client;
	float Range = 1500.0;
	float Radius = 250.0;
	Range *= Attributes_Get(weapon, 103, 1.0);
	Range *= Attributes_Get(weapon, 104, 1.0);
	Range *= Attributes_Get(weapon, 475, 1.0);
	Range *= Attributes_Get(weapon, 101, 1.0);
	Range *= Attributes_Get(weapon, 102, 1.0);
	Radius *=Attributes_Get(weapon, 99, 1.0);
	Radius *=Attributes_Get(weapon, 100, 1.0);
	Laser.DoForwardTrace_Basic(Range);
	float dps = 150.0;
	dps *=Attributes_Get(weapon, 410, 1.0);
	Check_StarfallAOE(client, Laser.End_Point, Radius, FRACTAL_KIT_STARFALL_JUMP_AMT-1, dps, true);

}
static int i_entity_targeted[FRACTAL_KIT_STARFALL_JUMP_AMT];
static void AoeExplosionCheckCast(int entity, int victim, float damage, int weapon)
{
	if(IsValidEnemy(entity, victim))
	{
		for(int i=0 ; i < FRACTAL_KIT_STARFALL_JUMP_AMT ; i++)
		{
			if(!i_entity_targeted[i])
			{
				i_entity_targeted[i] = victim;
				break;
			}
		}
	}
}
static void Check_StarfallAOE(int client, float Loc[3], float Radius, int cycle, float damage, bool first = false)
{
	if(cycle < 0)
		return;

	Zero(i_entity_targeted);
	Explode_Logic_Custom(0.0, client, client, -1, Loc, Radius, _, _, _, _, _, _, AoeExplosionCheckCast);

//	bool Hit = false;
	float speed = 0.69;
	int color[4] = {255, 255, 255, 255};
	if(first)
	{
		EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Loc);
		EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_SPAWN, client, SNDCHAN_STATIC, 45, _, 1.0);
		DataPack pack;
		CreateDataTimer(speed, Timer_StarfallIon, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(client));
		pack.WriteFloat(damage);
		pack.WriteFloat(Radius);
		pack.WriteCell(cycle);
		pack.WriteFloatArray(Loc, 3);
		Loc[2]+=10.0;
		TE_SetupBeamRingPoint(Loc, Radius*2.0, 0.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, speed, 15.0, 0.75, color, 1, 0);
		Send_Te_Client_ZR(client);
		Loc[2]-=10.0;

		return;
	}
	for (int entitys = 0; entitys < FRACTAL_KIT_STARFALL_JUMP_AMT; entitys++)
	{
		if(i_entity_targeted[entitys] > 0)
		{
			bool the_same = false;
			for(int i= 0 ; i < FRACTAL_KIT_STARFALL_JUMP_AMT ; i++)
			{
				if(i_entity_targeted[entitys] == EntRefToEntIndex(i_targeted_ID[client][i]))
				{
					the_same =true;
					break;
				}
			}
			if(the_same)
				continue;
			
			//CPrintToChatAll("cycle %i", cycle);
			i_targeted_ID[client][cycle] = EntIndexToEntRef(i_entity_targeted[entitys]);
			float pos1[3];
			WorldSpaceCenter(i_entity_targeted[entitys], pos1);
			DataPack pack;
			CreateDataTimer(speed, Timer_StarfallIon, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(client));
			pack.WriteFloat(damage*FRACTAL_KIT_STARFALL_FALLOFF);
			pack.WriteFloat(Radius);
			pack.WriteCell(cycle);
			pack.WriteFloatArray(pos1, 3);
			pos1[2]+=10.0;
			EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, pos1);
			EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_SPAWN, client, SNDCHAN_STATIC, 45, _, 1.0);
			TE_SetupBeamRingPoint(pos1, Radius*2.0, 0.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, speed, 15.0, 0.75, color, 1, 0);
			Send_Te_Client_ZR(client);
			pos1[2]-=10.0;
			break;
		}
		else
		{
			break;
		}
	}
}
static Action Timer_StarfallIon(Handle Timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	float damage = pack.ReadFloat();
	float radius = pack.ReadFloat();
	int cycle = pack.ReadCell();
	float Loc[3]; pack.ReadFloatArray(Loc, 3);

	Explode_Logic_Custom(damage , client ,client , -1 , Loc , radius);
	float sky[3]; sky = Loc; sky[2] +=3000.0;
	int color[4] = {255, 255, 255, 255};
	float speed = 0.45;
	TE_SetupBeamPoints(Loc, sky, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, speed, 15.0, 15.0, 0, 0.1, color, 3);
	TE_SendToAll();
	Loc[2]+=10.0;
	TE_SetupBeamRingPoint(Loc, 0.0, radius*2.0, g_Ruina_BEAM_Combine_Black, g_Ruina_HALO_Laser, 0, 1, speed, 15.0, 0.75, color, 1, 0);
	Send_Te_Client_ZR(client);
	Loc[2]-=10.0;
	Check_StarfallAOE(client, Loc, radius, cycle-1, damage);

	EmitSoundToAll(RUINA_ION_CANNON_SOUND_TOUCHDOWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Loc);
	EmitSoundToClient(client, RUINA_ION_CANNON_SOUND_TOUCHDOWN, client, SNDCHAN_STATIC, 45, _, 1.0);

	return Plugin_Stop;
}
Action SetTransmitHarvester(int entity, int client)
{
	int owner = EntRefToEntIndex(i_OwnerEntityEnvLaser[entity]);
	if(owner == client)
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}
#define FRACTAL_HARVESTER_MAX_AMT 3
enum struct Harvester_Enum
{
	int weapon;
	float throttle;
	int Enumerated_Ents[FRACTAL_HARVESTER_MAX_AMT];
	bool Active;

	float Lockout;
}
static Harvester_Enum struct_Harvester_Data[MAXPLAYERS];
public void Kit_Fractal_Mana_Harvester(int client, int weapon, bool &result, int slot)	//warp_harvester
{
	if(struct_Harvester_Data[client].Lockout > GetGameTime() + 30.0)
		struct_Harvester_Data[client].Lockout = 0.0;

	if(struct_Harvester_Data[client].Lockout > GetGameTime())
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "The Harvester is Recharging [%.1fs]", struct_Harvester_Data[client].Lockout-GetGameTime());
		return;
	}
	struct_Harvester_Data[client].weapon = EntIndexToEntRef(weapon);

	//failsafe.
	if(struct_Harvester_Data[client].throttle > GetGameTime() + 10.0)
		struct_Harvester_Data[client].throttle = 0.0;

	for(int i=0 ; i < FRACTAL_HARVESTER_MAX_AMT ; i++)
	{
		struct_Harvester_Data[client].Enumerated_Ents[i] = 0;
	}
	struct_Harvester_Data[client].Active = true;

	EmitSoundToAll(LEX_LASER_LOOP_SOUND, client, SNDCHAN_STATIC, 45, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
	EmitSoundToAll(LEX_LASER_LOOP_SOUND, client, SNDCHAN_STATIC, 45, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
	EmitSoundToAll(LEX_LASER_LOOP_SOUND1, client, SNDCHAN_STATIC, 45, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);
	EmitSoundToAll(LEX_LASER_LOOP_SOUND1, client, SNDCHAN_STATIC, 45, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL);

	SDKUnhook(client, SDKHook_PreThink, Mana_Harvester_Tick);
	SDKHook(client, SDKHook_PreThink, Mana_Harvester_Tick);
}
void Max_Fractal_Crystals(int client)
{
	fl_current_crystal_amt[client] = fl_max_crystal_amt[client];
}
static Action Mana_Harvester_Tick(int client)
{
	bool Mouse1 = (GetClientButtons(client) & IN_ATTACK) != 0;
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weapon = EntRefToEntIndex(struct_Harvester_Data[client].weapon);
	if(!Mouse1 || weapon_holding != weapon || !IsValidEntity(weapon) || i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_KIT_FRACTAL)
	{
		struct_Harvester_Data[client].Lockout = GetGameTime() + 0.5;
		
		struct_Harvester_Data[client].Active = false;
		SDKUnhook(client, SDKHook_PreThink, Mana_Harvester_Tick);

		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);

		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		return Plugin_Stop;
	}

	float GameTime = GetGameTime();

	if(struct_Harvester_Data[client].throttle > GameTime)
		return Plugin_Continue;

	ManaCalculationsBefore(client);
	float Time = 0.25 * Attributes_Get(weapon, 6, 1.0);

	struct_Harvester_Data[client].throttle = GameTime + Time;

	//we want to get like 10 entities infront of the player in a 45 degree angle within a set range.
	//start with finding entities.
	//a sphere trace should do the trick, both a range check / gets every ent.

	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0)*0.1);
	float damage = 7.0 * Attributes_Get(weapon, 410, 1.0);
	if(Current_Mana[client] < mana_cost)
	{
		struct_Harvester_Data[client].Active = false;
		SDKUnhook(client, SDKHook_PreThink, Mana_Harvester_Tick);

		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND);

		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);
		StopSound(client, SNDCHAN_STATIC, LEX_LASER_LOOP_SOUND1);

		struct_Harvester_Data[client].Lockout = GameTime + 5.0;
		return Plugin_Stop;
	}

	Current_Mana[client] -=mana_cost;
	SDKhooks_SetManaRegenDelayTime(client, 2.5);
	Mana_Hud_Delay[client] = 0.0;
	delay_hud[client] = 0.0;
		
	for(int i=0 ; i < FRACTAL_HARVESTER_MAX_AMT ; i++)
	{
		struct_Harvester_Data[client].Enumerated_Ents[i] = 0;
	}
	float range = 300.0;
	float Origin[3]; WorldSpaceCenter(client, Origin);
	b_LagCompNPC_No_Layers = true;
	StartLagCompensation_Base_Boss(client);
	TR_EnumerateEntitiesSphere(Origin, range, PARTITION_NON_STATIC_EDICTS, TraceEntityEnumerator_Fractal_Harvester, client);
	FinishLagCompensation_Base_boss();
	//we now have every valid target within range / within line of sight, comence the harvesting!
	int color[4]; color = Kit_Color();

	if(i_CurrentEquippedPerk[client] & PERK_HASTY_HOPS)
		mana_cost = RoundToFloor(mana_cost * 1.33);

	for(int i=0 ; i < FRACTAL_HARVESTER_MAX_AMT ; i++)
	{
		if(!struct_Harvester_Data[client].Enumerated_Ents[i])
			break;	//we have run out of targets, abort loop.

		bool raid = b_thisNpcIsARaid[struct_Harvester_Data[client].Enumerated_Ents[i]];

		int laser;
		//"effect_hand_l"
		laser = ConnectWithBeam(client, struct_Harvester_Data[client].Enumerated_Ents[i], color[0], color[1], color[2], 5.0, 3.0, 2.0, BEAM_COMBINE_BLACK, _,_,"effect_hand_l");
		
		if(Current_Mana[client] < max_mana[client]*1.2)
			Current_Mana[client] += (raid ? RoundToFloor(mana_cost*2.0) : RoundToFloor(mana_cost*1.5));

		fl_current_crystal_amt[client] += (raid ? FRACTAL_KIT_HARVESTER_CRYSTALGAIN * 2.0 : FRACTAL_KIT_HARVESTER_CRYSTALGAIN);

		SDKHooks_TakeDamage(struct_Harvester_Data[client].Enumerated_Ents[i], client, client, damage, DMG_PLASMA);

		damage *=LASER_AOE_DAMAGE_FALLOFF;
		
		if(IsValidEntity(laser))
		{
			if(!LastMann)
			{
				i_OwnerEntityEnvLaser[laser] = EntIndexToEntRef(client);
				SDKHook(laser, SDKHook_SetTransmit, SetTransmitHarvester);
			}

			CreateTimer(Time, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		}
		
	}
	if(fl_current_crystal_amt[client] > fl_max_crystal_amt[client])
		fl_current_crystal_amt[client] = fl_max_crystal_amt[client];

	return Plugin_Continue;
}
static int[] Kit_Color()
{
	int color[4] = {25,175,255,255};
	return color;
}
static bool TraceEntityEnumerator_Fractal_Harvester(int entity, int client)
{
	//This will automatically take care of all the checks, very handy.
	if(!IsValidEnemy(client, entity, true)) //Must detect camo.
		return true;

	//is the target within 45 degrees of the client?
	if(!IsTargetInfrontOfPlayer(client, entity))
		return true;
	
	for(int i=0; i < FRACTAL_HARVESTER_MAX_AMT; i++)
	{
		if(!struct_Harvester_Data[client].Enumerated_Ents[i])
		{
			struct_Harvester_Data[client].Enumerated_Ents[i] = entity;
			break;
		}
	}
	//always keep going!
	return true;
}
static bool IsTargetInfrontOfPlayer(int client, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(client, npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetClientEyeAngles(client, eyeAngles);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0)
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	//if its more then 180, its on the other side of the client / behind
	if(fabs(yawOffset) > 45)
		return false;
	else
		return true;
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
	int mana_cost;
	mana_cost = RoundToCeil(Attributes_Get(weapon, 733, 1.0));

	mana_cost *= 10;

	if(mana_cost > Current_Mana[client] && !b_cannon_animation_active[client])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%t", "Not Enough Mana", mana_cost);
		return;
	}

	if(b_cannon_animation_active[client])
	{
		Kill_Cannon(client);
	}
	else
	{
		if(!(GetEntityFlags(client) & FL_ONGROUND != 0))
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Must be on the ground to use the Laser Cannon");
			return;
		}
		if(!IsPlayerAlive(client) || TeutonType[client] != TEUTON_NONE || dieingstate[client] != 0)	//are you dead?
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			SetDefaultHudPosition(client);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client,  SyncHud_Notifaction, "Must be alive to use the Laser Cannon");
			return;
		}
		SDKhooks_SetManaRegenDelayTime(client, 2.5);
		Mana_Hud_Delay[client] = 0.0;
		
		Current_Mana[client] -= mana_cost;
		
		delay_hud[client] = 0.0;
		b_cannon_animation_active[client] = true;
		Initiate_Cannon(client, weapon);
		if(MagiaWingsDo(client))
			Delete_Halo(client);
	}
}
static void Kill_Cannon(int client)
{
	SDKUnhook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
	b_cannon_animation_active[client] = false;
	fl_animation_cooldown[client] = GetGameTime() + 5.0;	//no spaming it!
	Kill_Animation(client);

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
	{
		Attributes_Set(weapon, 698, 0.0);
	}
}

static void Initiate_Cannon(int client, int weapon)
{
	Initiate_Animation(client, weapon);
	fl_fractal_dmg_throttle[client] = 0.0;
	fl_fractal_turn_throttle[client] = 0.0;
	fl_fractal_laser_trace_throttle[client] = 0.0;

	SDKUnhook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
	SDKHook(client, SDKHook_PreThink, Fractal_Cannon_Tick);
}
static bool b_invalid_client(int client)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon_holding))	//CLEARLY YOU DON'T OWN AN AIR FRYER
	{
		Kill_Cannon(client);
		return true;
	}
	if(h_TimerManagement[client] == null)	//is the timer invalid? 
	{
		Kill_Cannon(client);
		return true;
	}
	if(i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_KIT_FRACTAL)	//are you somehow holding a non fractal kit weapon?
	{
		return true;
	}
	if(!IsPlayerAlive(client) || TeutonType[client] != TEUTON_NONE || dieingstate[client] != 0)	//are you dead?
	{
		return true;
	}
	return false;
}
static void Fractal_Cannon_Tick(int client)
{
	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(b_invalid_client(client) || !IsValidEntity(weapon_holding))
	{
		Kill_Cannon(client);
		return;
	}
	if(!b_cannon_animation_active[client])	//is the tick somehow active even though it shouldn't be possible?
	{
		Kill_Cannon(client);
		return;
	}
	float GameTime = GetGameTime();

	bool update = false;

	if(fl_fractal_dmg_throttle[client] < GameTime)
	{
		fl_fractal_dmg_throttle[client] = GameTime + 0.1;
		update = true;
	}
	
	Fire_Beam(client, weapon_holding, update);

	if(fl_fractal_turn_throttle[client] > GameTime)
		return;
	
	fl_fractal_turn_throttle[client] = GameTime + 0.05;

	Turn_Animation(client, weapon_holding);
}
static Action Timer_Weapon_Managment(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = pack.ReadCell();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsValidEntity(weapon))
	{
		Delete_Halo(client);
		h_TimerManagement[client] = null;
		return Plugin_Stop;
	}	

	int weapon_holding = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");   //get current active weapon. we don't actually use the original weapon, its there as a way to tell if something went wrong

	if(!IsValidEntity(weapon_holding))  //held weapon is somehow invalid, keep on looping...
		return Plugin_Continue;

	if(i_CustomWeaponEquipLogic[weapon_holding] != WEAPON_KIT_FRACTAL)
		return Plugin_Continue;

	Hud(client, weapon_holding);

	if(fl_current_crystal_amt[client] < 25.0)	//10
	{
		fl_current_crystal_amt[client] +=0.1;
	}
	else
	{
		if(fl_current_crystal_amt[client] < fl_max_crystal_amt[client])
			fl_current_crystal_amt[client] += 0.05;

		if(fl_current_crystal_amt[client] > fl_max_crystal_amt[client])
			fl_current_crystal_amt[client] = fl_max_crystal_amt[client];
	}

	return Plugin_Continue;
}

static void Hud(int client, int weapon)
{
	float GameTime = GetGameTime();

	if(fl_hud_timer[client] > GameTime)
		return;

	HaloManagment(client);

	fl_hud_timer[client] = GameTime + 0.5;

	char HUDText[255] = "";

	switch(Slot(weapon))
	{
		case 1:
		{
			if(b_cannon_animation_active[client])
			{
				Format(HUDText, sizeof(HUDText), "ĄHyper CannonČ Active Ę[M1] to DissableĖ");

				if(b_overdrive_active[client])
				{
					Format(HUDText, sizeof(HUDText), "%s\nĄOverDriveČ Active!",HUDText);
				}
				else
				{
					Format(HUDText, sizeof(HUDText), "%s\nPress [M2] To Activate ĄOverDriveČ [Cost:%.0f/s]",HUDText, FRACTAL_KIT_PASSIVE_OVERDRIVE_COST*10.0);
				}
				
			}
			else
			{
				if(fl_animation_cooldown[client] > GameTime)
				{	
					Format(HUDText, sizeof(HUDText), "ĄHyper CannonČ Offline ĘCooling [%.1fs]Ė", fl_animation_cooldown[client] - GameTime);
				}
				else
				{
					Format(HUDText, sizeof(HUDText), "ĄHyper CannonČ Ready Ę[M1] to ActivateĖ");
				}
			}
		}
		case 2:
		{
			if(b_cannon_animation_active[client])
			{
				Format(HUDText, sizeof(HUDText), "Error: Secondary slot while cannon is active");
			}
			else
			{
				if(struct_Harvester_Data[client].Lockout > GameTime)
				{
					Format(HUDText, sizeof(HUDText), "ĄMana HarvesterČ Recharging [%.1f]", struct_Harvester_Data[client].Lockout - GameTime);
				}
				else
				{
					if(struct_Harvester_Data[client].Active)
						Format(HUDText, sizeof(HUDText), "ĄMana HarvesterČ Active!");
					else
						Format(HUDText, sizeof(HUDText), "Hold [M1] To Cast ĄMana HarvesterČ");
				}

				if(fl_starfall_CD[client] > GameTime)
					Format(HUDText, sizeof(HUDText), "%s\nĄStarFallČ Recharging [%.1f] | [Cost:%.0f]",HUDText, fl_starfall_CD[client] - GameTime, FRACTAL_KIT_STARFALL_COST);
				else if(fl_current_crystal_amt[client] >= FRACTAL_KIT_STARFALL_COST)
					Format(HUDText, sizeof(HUDText), "%s\nPress [M2] To Cast ĄStarFallČ [Cost:%.0f]",HUDText, FRACTAL_KIT_STARFALL_COST);
				else
					Format(HUDText, sizeof(HUDText), "%s\nNot Enough Crystals To Cast ĄStarFallČ [%.0f/%.0f]",HUDText, fl_current_crystal_amt[client], FRACTAL_KIT_STARFALL_COST);

				
				//m1: mana harvester.
				//m2: Mana Ion.
			}

			Fractal_Weapon_LastMannHandle(weapon, 6, 0.75);
		}
		case 3:
		{
			if(b_cannon_animation_active[client])
			{
				Format(HUDText, sizeof(HUDText), "Error: Melee slot while cannon is active");
			}
			else
			{
				Format(HUDText, sizeof(HUDText), "Press [M1] To Cast ĄFantasiaČ [Cost:%.0f]", FRACTAL_KIT_FANTASIA_COST);
				//m1: fantasia
			}

			Fractal_Weapon_LastMannHandle(weapon, 6, 0.5);
		}
	}

	Format(HUDText, sizeof(HUDText), "%s\nĄCrystals:Ę%.0f/%.0fĖČ",HUDText, fl_current_crystal_amt[client], fl_max_crystal_amt[client]);

	Format_Fancy_Hud(HUDText);

	PrintHintText(client, HUDText);
}
static void Fractal_Weapon_LastMannHandle(int weapon, int attribute, float value)
{
	if(LastMann)
	{
		if(!i_WeaponGotLastmanBuff[weapon])
		{
			i_WeaponGotLastmanBuff[weapon] = true;
			Attributes_SetMulti(weapon, attribute, value);
		}
	}
	else
	{
		if(i_WeaponGotLastmanBuff[weapon])
		{
			i_WeaponGotLastmanBuff[weapon] = false;
			Attributes_SetMulti(weapon, attribute, 1 / value);
		}
	}
}
#define FRACTAL_SHIELD_YAW 45.0
float Player_OnTakeDamage_Fractal(int victim, float &damage, float damagePosition[3], int attacker)
{
	if(!b_cannon_animation_active[victim])
		return damage;

	if(CheckInHud())
		return damage;

	int animation = EntRefToEntIndex(i_NPC_ID[victim]);
	if(animation == -1)
		return damage;

	
	// need position of either the inflictor or the attacker
	float actualDamagePos[3];
	float victimPos[3];
	float angle[3];
	float eyeAngles[3];
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victimPos);
	
	bool BlockAnyways = false;
	if(damagePosition[0]) //Make sure if it doesnt
	{
		if(IsValidEntity(attacker))
		{
			GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", actualDamagePos);
		}
		else
		{
			BlockAnyways = true;
		}
	}
	else
	{
		actualDamagePos = damagePosition;
	}

	GetVectorAnglesTwoPoints(victimPos, actualDamagePos, angle);

	GetEntPropVector(animation, Prop_Data, "m_angRotation", eyeAngles);


	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;
		
	// now it's a simple check
	if ((yawOffset >= -FRACTAL_SHIELD_YAW && yawOffset <= FRACTAL_SHIELD_YAW) || BlockAnyways)
	{
		damage *= 0.75;	//25% dmg resist forward of where the npc is looking. not the actual player.
		
		if(f_AniSoundSpam[victim] < GetGameTime())
		{
			f_AniSoundSpam[victim] = GetGameTime() + 0.2;
			switch(GetRandomInt(1,2))
			{
				case 1:
				{
					EmitSoundToClient(victim, FRACTAL_KIT_SHIELDSOUND2, victim, _, 85, _, 0.8, GetRandomInt(90, 100));
				}
				case 2:
				{
					EmitSoundToClient(victim, FRACTAL_KIT_SHIELDSOUND1, victim, _, 85, _, 0.8, GetRandomInt(90, 100));
				}
			}
		}
	}
	return damage;
	
}
void Fractal_Kit_MapStart()
{
	Zero(fl_starfall_CD);
	Zero(fl_max_crystal_amt);
	Zero(fl_fractal_laser_trace_throttle);
	Zero(fl_hud_timer);
	Zero(b_cannon_animation_active);
	Zero(fl_animation_cooldown);
	Zero(f_AniSoundSpam);
	Zero(fl_current_crystal_amt);
	PrecacheSound(FRACTAL_KIT_SHIELDSOUND1, true);
	PrecacheSound(FRACTAL_KIT_SHIELDSOUND2, true);
	for(int i=0 ; i < MAXPLAYERS ; i++)
	{
		struct_Harvester_Data[i].Lockout = 0.0;
	}
}
void Kit_Fractal_ResetRound()
{	
	Zero(fl_max_crystal_amt);
	Zero(f_AniSoundSpam);
	Zero(fl_fractal_laser_trace_throttle);
	Zero(fl_hud_timer);
	Zero(fl_animation_cooldown);
	Zero(fl_current_crystal_amt);

	for(int i=0 ; i < MAXPLAYERS ; i++)
	{
		struct_Harvester_Data[i].Lockout = 0.0;
	}
}

//stuff that im probably gonna use a lot in other future weapons.

void Send_Te_Client_ZR(int client)
{
	if(LastMann)
		TE_SendToAll();
	else
		TE_SendToClient(client);
}

int i_maxtargets_hit;
enum struct Player_Laser_Logic
{
	int client;
	float Start_Point[3];
	float End_Point[3];
	float Angles[3];
	float Radius;
	float Damage;
	int damagetype;
	int max_targets;
	float target_hitfalloff;
	float range_hitfalloff;		//no work yet

	bool trace_hit;
	bool trace_hit_enemy;
	float MaxDist;

	float Custom_Hull[3];

	int weapon;

	/*

	*/

	void DoForwardTrace_Basic(float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Player_Laser_BEAM_TraceWallsOnly;

		float Angles[3], startPoint[3], Loc[3];
		GetClientEyePosition(this.client, startPoint);
		GetClientEyeAngles(this.client, Angles);

		if(Dist != -1.0)
			this.MaxDist = Dist;

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Func_Trace, this.client);

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
	void DoForwardTrace_Custom(float Angles[3], float startPoint[3], float Dist=-1.0, TraceEntityFilter Func_Trace = INVALID_FUNCTION)
	{
		if(Func_Trace==INVALID_FUNCTION)
			Func_Trace = Player_Laser_BEAM_TraceWallsOnly;

		if(Dist != -1.0)
			this.MaxDist = Dist;

		float Loc[3];
		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, Func_Trace, this.client);
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

	void Detect_Targets(Function Attack_Function)
	{
		if(this.max_targets)
			i_maxtargets_hit = this.max_targets;
		else
			i_maxtargets_hit = MAX_TARGETS_HIT;

		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Player_Laser_BEAM_TraceUsers, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();

		float Dmg = this.Damage;
				
		for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		{
			int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
			if (!victim)
				break;

			this.trace_hit_enemy=true;

			float playerPos[3];
			WorldSpaceCenter(victim, playerPos);

			if(Attack_Function && Attack_Function != INVALID_FUNCTION)
			{	
				Call_StartFunction(null, Attack_Function);
				Call_PushCell(this.client);
				Call_PushCell(victim);
				Call_PushCell(this.damagetype);
				Call_PushFloatRef(Dmg);
				Call_Finish();

				//static void On_LaserHit(int client, int target, int damagetype, float &damage)
			}
		}
	}
	void Enumerate_Simple()
	{
		if(this.max_targets)
			i_maxtargets_hit = this.max_targets;
		else
			i_maxtargets_hit = MAX_TARGETS_HIT;

		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Player_Laser_BEAM_TraceUsers, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();

		//the idea for this one is to then use
		//for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		//to loop throught the stuff. inside the specific npc that needs to use this
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

		Zero(i_Ruina_Laser_BEAM_HitDetected);

		float hullMin[3], hullMax[3];
		this.SetHull(hullMin, hullMax);

		b_LagCompNPC_No_Layers = true;
		StartLagCompensation_Base_Boss(this.client);
		Handle trace = TR_TraceHullFilterEx(this.Start_Point, this.End_Point, hullMin, hullMax, 1073741824, Player_Laser_BEAM_TraceUsers, this.client);	// 1073741824 is CONTENTS_LADDER?
		delete trace;
		FinishLagCompensation_Base_boss();

		float Dmg = this.Damage;
		
		for (int loop = 0; loop < sizeof(i_Ruina_Laser_BEAM_HitDetected); loop++)
		{
			int victim = i_Ruina_Laser_BEAM_HitDetected[loop];
			if (!victim)
				break;

			this.trace_hit_enemy=true;

			this.DoDamage(victim, Dmg, this.weapon, {0.0,0.0,0.0});
			
			//SDKHooks_TakeDamage(victim, this.client, this.client, Dmg, this.damagetype, -1, _, playerPos);

			if(Attack_Function && Attack_Function != INVALID_FUNCTION)
			{	
				Call_StartFunction(null, Attack_Function);
				Call_PushCell(this.client);
				Call_PushCell(victim);
				Call_PushCell(this.damagetype);
				Call_PushFloatRef(Dmg);
				Call_Finish();
				//static void On_LaserHit(int client, int target, int damagetype, float &damage)
			}

			Dmg *= Falloff;
		}
	}
	void DoDamage(int victim, float Dmg, int weapon_active, float damage_force[3])
	{
		float playerPos[3];
		WorldSpaceCenter(victim, playerPos);

		if(!IsValidEntity(weapon_active))
		{
			SDKHooks_TakeDamage(victim, this.client, this.client, Dmg, this.damagetype, -1, _, playerPos);
			return;
		}
		
		DataPack pack = new DataPack();
		pack.WriteCell(EntIndexToEntRef(victim));
		pack.WriteCell(EntIndexToEntRef(this.client));
		pack.WriteCell(EntIndexToEntRef(this.client));
		pack.WriteFloat(Dmg);
		pack.WriteCell(this.damagetype);
		pack.WriteCell(weapon_active);
		pack.WriteFloat(damage_force[0]);
		pack.WriteFloat(damage_force[1]);
		pack.WriteFloat(damage_force[2]);
		pack.WriteFloat(playerPos[0]);
		pack.WriteFloat(playerPos[1]);
		pack.WriteFloat(playerPos[2]);
		pack.WriteCell(0);
		RequestFrame(CauseDamageLaterSDKHooks_Takedamage, pack);
	}
	void SetHull(float hullMin[3], float hullMax[3])
	{
		if(this.Custom_Hull[0] != 0.0 || this.Custom_Hull[1] != 0.0 || this.Custom_Hull[2] != 0.0)
		{
			hullMin[0] = -this.Custom_Hull[0];
			hullMin[1] = -this.Custom_Hull[1];
			hullMin[2] = -this.Custom_Hull[2];
		}
		else
		{
			hullMin[0] = -this.Radius;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
		}
		hullMax[0] = -hullMin[0];
		hullMax[1] = -hullMin[1];
		hullMax[2] = -hullMin[2];
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
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=0 ; i < i_maxtargets_hit ; i++)
			{
				if(!i_Ruina_Laser_BEAM_HitDetected[i])
				{
					i_Ruina_Laser_BEAM_HitDetected[i] = entity;
					break;
				}
			}
		}
	}
	return false;
}
stock bool RayCastTraceEnemies(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		if(IsValidEnemy(client, entity, true, true))
		{
			for(int i=0 ; i < i_maxtargets_hit ; i++)
			{
				//don't retrace the same entity!
				if(i_Ruina_Laser_BEAM_HitDetected[i] == entity)
					break;

				if(!i_Ruina_Laser_BEAM_HitDetected[i])
				{
					i_Ruina_Laser_BEAM_HitDetected[i] = entity;
					break;
				}
			}
		}
	}
	return !entity;
}
stock bool RayCastTraceEverything(int entity, int contentsMask, int client)
{
	if (IsValidEntity(entity))
	{
		for(int i=0 ; i < i_maxtargets_hit ; i++)
		{
			//don't retrace the same entity!
			if(i_Ruina_Laser_BEAM_HitDetected[i] == entity)
				break;
				
			if(!i_Ruina_Laser_BEAM_HitDetected[i])
			{
				i_Ruina_Laser_BEAM_HitDetected[i] = entity;
				break;
			}
		}
	}
	return !entity;
}