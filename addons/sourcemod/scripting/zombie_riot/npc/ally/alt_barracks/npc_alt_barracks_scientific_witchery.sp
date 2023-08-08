#pragma semicolon 1
#pragma newdecls required

static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static const char g_IdleSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static char g_PullSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};

static float fl_self_heal_timer[MAXENTITIES];

static char gLaser2;

static float BEAM_Targets_Hit[MAXENTITIES];
static bool Scientific_Witchery_BEAM_HitDetected[MAXENTITIES];
static int Scientific_Witchery_BEAM_BuildingHit[MAXENTITIES];
static float fl_runaway_timer_timeout[MAXENTITIES];

static float fl_trace_target_timeout[MAXENTITIES][MAXENTITIES];


static int i_AmountProjectiles[MAXENTITIES];

public void Barrack_Alt_Scientific_Witchery_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
	
	Zero(fl_self_heal_timer);
	Zero2(fl_trace_target_timeout);
	
	gLaser2 = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

methodmap Barrack_Alt_Scientific_Witchery < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public Barrack_Alt_Scientific_Witchery(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(BarrackBody(client, vecPos, vecAng, "1300", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_crit.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACK_SCIENTIFIC_WITCHERY;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Scientific_Witchery_ClotThink);

		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
	
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_vampiric_vesture/sf14_vampiric_vesture.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_templar_hood/sf14_templar_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 150, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 150, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 150, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 7, 150, 255, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		
		fl_self_heal_timer[npc.index] = GetGameTime(npc.index) + 1.0;
		fl_runaway_timer_timeout[npc.index] = 0.0;
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Scientific_Witchery_ClotThink(int iNPC)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		
		
		
		if(PrimaryThreatIndex > 0)
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			

			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
			if(flDistanceToTarget < (300.0 * 300.0) && npc.m_flNextMeleeAttack < GameTime)
			{
				npc.AddGesture("ACT_MP_THROW");
				npc.m_flNextMeleeAttack = GameTime + 1.25 * npc.BonusFireRate;
				
				Horizontal_Slicer(npc.index, vecTarget, 300.0);
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
			}
			else if(flDistanceToTarget < (1250.0 * 1250.0) && npc.m_flNextMeleeAttack < GameTime)
			{
				Create_Laser_Hell(npc.index, vecTarget);
				npc.m_flNextMeleeAttack = GameTime + 2.0 * npc.BonusFireRate;
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
			}
			npc.StartPathing();
			
		}
		else
		{
			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
			npc.PlayIdleSound();
		}
		
		float Health =float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
		float MaxHealth =  float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		if(fl_self_heal_timer[npc.index]<GameTime)
		{
			int Heal_Amt = RoundToFloor((MaxHealth / 100.0)*1.0);
			if(Health+Heal_Amt < MaxHealth)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToFloor(Health) + Heal_Amt);
			}

			fl_self_heal_timer[npc.index] = GameTime + 0.25;
		}
		float H_Amt = (Health / MaxHealth) * 100.0;
		if(H_Amt<10.0 && fl_runaway_timer_timeout[npc.index] < GameTime)	//RUNAWAY FOR YOUR LIFE
		{
			fl_runaway_timer_timeout[npc.index] = GameTime + 60.0;
			npc.CmdOverride = Command_RetreatPlayer;	//npc retreats to the player
		}
		else
		{
			if(H_Amt<10.0)	//RUNAWAY FOR YOUR LIFE
			{
				npc.m_flSpeed = 375.0;
			}
			else
			{
				npc.m_flSpeed = 250.0;
			}
		}
	}
}

void Barrack_Alt_Scientific_Witchery_NPCDeath(int entity)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Scientific_Witchery_ClotThink);
	
	SDKUnhook(npc.index, SDKHook_Think, Scientific_Witchery_TBB_Ability);
	SDKUnhook(npc.index, SDKHook_Think, Scientific_Witchery_TBB_Ability_Two);
}
//Horizontal Slicer
static int H_Tick_Count[MAXENTITIES];
static int H_Tick_Count_Max[MAXENTITIES];

#define H_SLICER_AMOUNT 6	//how many individual pieces of the arc are there, more = nicer curve but more traces

static int H_i_Slicer_Throttle[MAXENTITIES];

static float H_fl_target_vec[MAXENTITIES][H_SLICER_AMOUNT+2][3];
static float H_fl_starting_vec[MAXENTITIES][3];
static float H_fl_current_vec[MAXENTITIES][H_SLICER_AMOUNT+2][3];

static void Horizontal_Slicer(int client, float vecTarget[3], float Range)
{
	float Vec_offset[3]; Vec_offset = vecTarget;
	float Npc_Vec[3]; Npc_Vec = WorldSpaceCenter(client);
	
	
	H_fl_starting_vec[client] = Npc_Vec;
	
	float ang_Look[3];
	
	MakeVectorFromPoints(Npc_Vec, Vec_offset, ang_Look);
	GetVectorAngles(ang_Look, ang_Look);
	
	float wide_set = 45.0;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing
	
	ang_Look[1] -= wide_set;
	float type = (wide_set*2) / H_SLICER_AMOUNT;
	ang_Look[1] -= type;
	if(ang_Look[1]>360.0)
	{
		ang_Look[1] = 0.0;
	}
	else if(ang_Look[1]<0.0)
	{
		ang_Look[1] +=360.0;
	}
		
	for(int i=1 ; i<=H_SLICER_AMOUNT+1 ; i++)
	{
		H_fl_current_vec[client][i] = Npc_Vec;
		
		
		
					
		float tempAngles[3], endLoc[3], Direction[3];
		
		tempAngles[0] = ang_Look[0];
		tempAngles[1] = ang_Look[1] + type * i;
		tempAngles[2] = 0.0;
		
		if(ang_Look[1]>360.0)
		{
			ang_Look[1] -= 360.0;
		}
							
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Range);
		AddVectors(Npc_Vec, Direction, endLoc);
			
							
		
		H_fl_target_vec[client][i] = endLoc;
		
	}
	
	float time = 1.25;
	
	Scientific_Witchery_BEAM_BuildingHit[client] = 0;
	H_i_Slicer_Throttle[client] = 0;

	H_Tick_Count[client] = 0;
	H_Tick_Count_Max[client] = RoundToFloor(66.0*time);
	
	SDKHook(client, SDKHook_Think, Scientific_Witchery_TBB_Ability_Two);
}
static Action Scientific_Witchery_TBB_Ability_Two(int client)
{
	if(!IsValidEntity(client) || H_Tick_Count_Max[client]<H_Tick_Count[client] || Scientific_Witchery_BEAM_BuildingHit[client] >=11)
	{
		H_Tick_Count[client] = 0;
		SDKUnhook(client, SDKHook_Think, Scientific_Witchery_TBB_Ability_Two);
		return Plugin_Handled;
	}
	H_Tick_Count[client]++;
	H_i_Slicer_Throttle[client]++;
	
	float Spn_Vec[3];
	Spn_Vec = H_fl_starting_vec[client];
	
	for(int i=1 ; i<=H_SLICER_AMOUNT+1 ; i++)
	{
		float Trg_Vec[3], Cur_Vec[3], vecAngles[3], Direction[3];
	
	
		Trg_Vec = H_fl_target_vec[client][i];
		Cur_Vec = H_fl_current_vec[client][i];
		
		
		float Dist = GetVectorDistance(Spn_Vec, Trg_Vec);
		float Speed = Dist / (H_Tick_Count_Max[client]/2);
		
		
		MakeVectorFromPoints(Spn_Vec, Trg_Vec, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
			
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, Speed);
		AddVectors(Cur_Vec, Direction, Cur_Vec);
		
		
		
		H_fl_current_vec[client][i] = Cur_Vec;
		
	}
	
	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;
		
	if(H_i_Slicer_Throttle[client]>2)
	{
		H_i_Slicer_Throttle[client] = 0;
		for(int i=1 ; i<=H_SLICER_AMOUNT ; i++)
		{
				Scientific_Witchery_Ability(client, H_fl_current_vec[client][i], H_fl_current_vec[client][i+1], 2.0, 7500.0);
				
				TE_SetupBeamPoints(H_fl_current_vec[client][i], H_fl_current_vec[client][i+1], gLaser2, 0, 0, 0, 0.051, 5.0, 5.0, 0, 0.1, colour, 1);
				TE_SendToAll(0.0);
			
		}
	}
	
	
	return Plugin_Continue;
	
}

//	Verical Slier
static int Tick_Count[MAXENTITIES];
static int Tick_Count_Max[MAXENTITIES];

static int i_Slicer_Throttle[MAXENTITIES];

static float fl_target_vec[MAXENTITIES][3];
static float fl_starting_vec[MAXENTITIES][3];
static float fl_current_vec[MAXENTITIES][3];

static void Create_Laser_Hell(int client, float vecTarget[3])
{
	float Vec_offset[3]; Vec_offset = vecTarget;
	float Npc_Vec[3]; Npc_Vec = WorldSpaceCenter(client);
	
	
	fl_target_vec[client] = Vec_offset;
	fl_starting_vec[client] = Npc_Vec;
	fl_current_vec[client] = Npc_Vec;
	
	Npc_Vec[2] -= 125.0;
	Vec_offset[2] -= 125.0;
	float skyloc[3];
	
	float time = 1.25;
	
	i_Slicer_Throttle[client] = 0;
	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;
	skyloc = Npc_Vec;
	skyloc[2] += 300.0;
	Scientific_Witchery_BEAM_BuildingHit[client] = 0;
	TE_SetupBeamPoints(Npc_Vec, skyloc, gLaser2, 0, 0, 0, time, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll(0.0);
	
	skyloc = Vec_offset;
	skyloc[2] += 300.0;
	TE_SetupBeamPoints(Vec_offset, skyloc, gLaser2, 0, 0, 0, time, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll(0.0);
	Tick_Count[client] = 0;
	Tick_Count_Max[client] = RoundToFloor(66.0*time);
	
	SDKHook(client, SDKHook_Think, Scientific_Witchery_TBB_Ability);
}
static Action Scientific_Witchery_TBB_Ability(int client)
{
	if(!IsValidEntity(client) || Tick_Count_Max[client]<Tick_Count[client] || Scientific_Witchery_BEAM_BuildingHit[client] >=11)
	{
		Tick_Count[client] = 0;
		SDKUnhook(client, SDKHook_Think, Scientific_Witchery_TBB_Ability);
		return Plugin_Handled;
	}
	Tick_Count[client]++;
	i_Slicer_Throttle[client]++;
	
	float Trg_Vec[3], Cur_Vec[3], Spn_Vec[3], vecAngles[3], Direction[3], skyloc[3];
	
	Trg_Vec = fl_target_vec[client];
	Cur_Vec = fl_current_vec[client];
	Spn_Vec = fl_starting_vec[client];
	
	float Dist = GetVectorDistance(Spn_Vec, Trg_Vec);
	float Speed = Dist / Tick_Count_Max[client];
	
	
	MakeVectorFromPoints(Spn_Vec, Trg_Vec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
		
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Speed);
	AddVectors(Cur_Vec, Direction, Cur_Vec);
	
	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;
	
	fl_current_vec[client] = Cur_Vec;
	if(i_Slicer_Throttle[client]>2)
	{
		i_Slicer_Throttle[client] = 0;
		Scientific_Witchery_Ability(client, Cur_Vec, skyloc, 2.0, 10000.0);
		skyloc = Cur_Vec;
		skyloc[2] += 150.0;
		Cur_Vec[2] -= 150.0;
		TE_SetupBeamPoints(Cur_Vec, skyloc, gLaser2, 0, 0, 0, 0.051, 5.0, 5.0, 0, 0.1, colour, 1);
		TE_SendToAll(0.0);
	}
	return Plugin_Continue;
	
}

static void Scientific_Witchery_Ability(int client, float Vec_1[3], float Vec_2[3], float radius, float dmg)
{
	
			Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);
	
			static float hullMin[3];
			static float hullMax[3];

			for (int i = 1; i < MAXENTITIES; i++)
			{
				Scientific_Witchery_BEAM_HitDetected[i] = false;
			}
			
			hullMin[0] = -radius;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			Handle trace = TR_TraceHullFilterEx(Vec_1, Vec_2, hullMin, hullMax, 1073741824, Scientific_Witchery_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			BEAM_Targets_Hit[client] = 1.0;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Scientific_Witchery_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					int inflictor = GetClientOfUserId(npc.OwnerUserId);
					if(inflictor==-1)
					{
						inflictor=client;
					}
					SDKHooks_TakeDamage(victim, client, inflictor, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),dmg, 1))/BEAM_Targets_Hit[client], DMG_PLASMA, -1, NULL_VECTOR, Vec_1);	// 2048 is DMG_NOGIB?
					BEAM_Targets_Hit[client] *= 1.2;
				}
			}

}
static bool Scientific_Witchery_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity) && Scientific_Witchery_BEAM_BuildingHit[client]<11)
	{
		if(fl_trace_target_timeout[client][entity]<=GetGameTime())
		{
			fl_trace_target_timeout[client][entity] = GetGameTime() + 0.25;
			Scientific_Witchery_BEAM_BuildingHit[client]++;
			Scientific_Witchery_BEAM_HitDetected[entity] = true;
		}
	}
	return false;
}