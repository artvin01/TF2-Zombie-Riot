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

public void Barrack_Alt_Scientific_Witchery_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}


	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Scientific Witchery");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_witch");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Scientific_Witchery(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Scientific_Witchery < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property int m_iFantasiaHits
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property float m_flRunAwayTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
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
		
		
	}
	public Barrack_Alt_Scientific_Witchery(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(BarrackBody(client, vecPos, vecAng, "1300", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_crit.mdl"));
		
		i_NpcWeight[npc.index] = 1;

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Scientific_Witchery_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Scientific_Witchery_ClotThink;

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

		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable4, 7, 150, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable3, 7, 150, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable2, 7, 150, 255, 255);
		
		SetEntityRenderColor(npc.m_iWearable1, 7, 150, 255, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		
		fl_ruina_in_combat_timer[npc.index] = GetGameTime(npc.index) + 1.0;
		npc.m_flRunAwayTimer = 0.0;
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

static void Barrack_Alt_Scientific_Witchery_ClotThink(int iNPC)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(iNPC);
	float GameTime = GetGameTime(iNPC);
	
	if(!BarrackBody_ThinkStart(npc.index, GameTime))
		return;

	BarrackBody_ThinkTarget(npc.index, true, GameTime);
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(PrimaryThreatIndex > 0)
	{
		npc.PlayIdleAlertSound();
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		if(flDistanceToTarget < (1250.0 * 1250.0))
		{
			npc.FaceTowards(vecTarget, 3000.0);
			npc.m_bAllowBackWalking = true;
		}
		else
			npc.m_bAllowBackWalking = false;	

		int IcanSeeEnemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);

		if(npc.m_flNextMeleeAttack < GameTime && IsValidEnemy(npc.index, IcanSeeEnemy))
		{
			if(flDistanceToTarget < (600.0 * 600.0))
			{
				npc.AddGesture("ACT_MP_THROW");
				npc.m_flNextMeleeAttack = GameTime + 4.0 * npc.BonusFireRate;
				Invoke_Horizontal_Slicer(npc.index, vecTarget, 600.0);
			}
			else if(flDistanceToTarget < (1250.0 * 1250.0))
			{
				Invoke_Vertical_Slicer(npc.index, vecTarget);
				npc.m_flNextMeleeAttack = GameTime + 3.0 * npc.BonusFireRate;
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			}
		}
		npc.StartPathing();
		
	}
	else
	{
		npc.m_bAllowBackWalking = false;
		npc.PlayIdleSound();
	}
	
	float Health =float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth =  float(ReturnEntityMaxHealth(npc.index));
	if(fl_ruina_in_combat_timer[npc.index]<GameTime)
	{
		int Heal_Amt = RoundToFloor((MaxHealth / 100.0)*1.0);
		if(Health+Heal_Amt < MaxHealth)
		{
			HealEntityGlobal(npc.index, npc.index, float(Heal_Amt), 1.0, 0.0, HEAL_SELFHEAL|HEAL_PASSIVE_NO_NOTIF);
		}

		fl_ruina_in_combat_timer[npc.index] = GameTime + 0.25;
	}

	float movepseed = 250.0;
	float H_Amt = (Health / MaxHealth) * 100.0;
	if(H_Amt<10.0 && npc.m_flRunAwayTimer < GameTime)	//RUNAWAY FOR YOUR LIFE
	{
		npc.m_flRunAwayTimer = GameTime + 60.0;
		npc.CmdOverride = Command_RetreatPlayer;	//npc retreats to the player
	}
	else
	{
		if(H_Amt<10.0)	//RUNAWAY FOR YOUR LIFE
		{
			movepseed = 375.0;
		}
		else
		{
			movepseed = 250.0;
		}
	}
	if(H_Amt>90.0 && npc.CmdOverride==Command_RetreatPlayer && npc.m_flRunAwayTimer > GameTime)
	{
		npc.CmdOverride=Command_Default;
	}

	BarrackBody_ThinkMove(npc.index, movepseed, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
}

void Barrack_Alt_Scientific_Witchery_NPCDeath(int entity)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(entity);
	BarrackBody_NPCDeath(npc.index);
	
	SDKUnhook(npc.index, SDKHook_Think, Witch_VerticalSlicer_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Witch_HorizontaSlicer_Tick);
}
//Horizontal Slicer


#define H_SLICER_AMOUNT_WITCH 6	//how many individual pieces of the arc are there, more = nicer curve but more traces

static float fl_horizontal_slicer_angleset = 45.0;
static float fl_horizontal_slicer_timer = 1.75;
static float fl_starting_vec[MAXENTITIES][3];

static void Invoke_Horizontal_Slicer(int client, float vecTarget[3], float Range)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);
	float Vec_offset[3]; Vec_offset = vecTarget;
	float Npc_Vec[3]; WorldSpaceCenter(client, Npc_Vec);
	
	fl_BEAM_ChargeUpTime[client] = Range;
	
	float ang_Look[3];
	
	MakeVectorFromPoints(Npc_Vec, Vec_offset, ang_Look);
	GetVectorAngles(ang_Look, ang_Look);
	
	float wide_set = fl_horizontal_slicer_angleset;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing
	
	ang_Look[1] -= wide_set;
	float type = (wide_set*2) / H_SLICER_AMOUNT_WITCH;
	ang_Look[1] -= type;
	if(ang_Look[1]>360.0)
	{
		ang_Look[1] -= 360.0;
	}
	else if(ang_Look[1]<0.0)
	{
		ang_Look[1] +=360.0;
	}
		
	fl_AbilityVectorData[client] = ang_Look;
	fl_starting_vec[client] = Npc_Vec;
	
	fl_BEAM_DurationTime[npc.index] = fl_horizontal_slicer_timer*npc.BonusFireRate + GetGameTime(npc.index);
	npc.m_iFantasiaHits = 0;
	fl_BEAM_ThrottleTime[client] = 0.0;
	

	SDKUnhook(client, SDKHook_Think, Witch_VerticalSlicer_Tick);
	SDKUnhook(client, SDKHook_Think, Witch_HorizontaSlicer_Tick);
	SDKHook(client, SDKHook_Think, Witch_HorizontaSlicer_Tick);
	
}
static float[] fl_GetSlicerPoints(int npc, int section)
{
	float wide_set = fl_horizontal_slicer_angleset;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing

	float type = (wide_set*2) / H_SLICER_AMOUNT_WITCH;

	float ang_Look[3]; ang_Look = fl_AbilityVectorData[npc];
	
	float tempAngles[3];
	
	tempAngles[0] = ang_Look[0];
	tempAngles[1] = ang_Look[1] + type * section;
	tempAngles[2] = 0.0;
	
	return tempAngles;
}
static void Witch_HorizontaSlicer_Tick(int client)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);
	float GameTime = GetGameTime(npc.index);

	if(fl_BEAM_DurationTime[npc.index] < GameTime || npc.m_iFantasiaHits >10)
	{
		SDKUnhook(npc.index, SDKHook_Think, Witch_VerticalSlicer_Tick);
		return;
	}
	if(fl_BEAM_ThrottleTime[npc.index] > GameTime)
		return;

	fl_BEAM_ThrottleTime[npc.index] = GameTime + 0.1;

	float Ratio = (fl_BEAM_DurationTime[npc.index]-GameTime) / (fl_horizontal_slicer_timer*npc.BonusFireRate);
	
	float Spn_Vec[3];
	Spn_Vec = fl_starting_vec[client];

	float DistToDo = fl_BEAM_ChargeUpTime[client] * (1.0-Ratio);

	float Vectors_Previus[3];

	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;
	
	for(int i=1 ; i<=H_SLICER_AMOUNT_WITCH+1 ; i++)
	{
		float SlicerAngles[3], SlicerLoc[3];
		SlicerAngles = fl_GetSlicerPoints(npc.index, i);
	
		Get_Fake_Forward_Vec(DistToDo, SlicerAngles, SlicerLoc, Spn_Vec);

		if(i>1)
		{
			Scientific_Witchery_DmgTrace(client, SlicerLoc, Vectors_Previus, 2.0, 7500.0); // Horizontal Slicer dmg
			
			TE_SetupBeamPoints(SlicerLoc, Vectors_Previus, g_Ruina_Laser_BEAM, 0, 0, 0, 0.1, 5.0, 5.0, 0, 0.1, colour, 1);
			TE_SendToAll(0.0);
		}

		Vectors_Previus = SlicerLoc;
	}
}

//	Verical Slier

static float fl_vertical_slicer_max_timer = 1.25;
static void Invoke_Vertical_Slicer(int client, float vecTarget[3])
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);
	float Vec_offset[3]; Vec_offset = vecTarget;
	float Npc_Vec[3]; WorldSpaceCenter(client, Npc_Vec);
	
	fl_AbilityVectorData[client] = Vec_offset;
	fl_starting_vec[client] = Npc_Vec;
	
	Npc_Vec[2] -= 125.0;
	Vec_offset[2] -= 125.0;
	float skyloc[3];
	
	float time = fl_vertical_slicer_max_timer*npc.BonusFireRate;

	fl_BEAM_DurationTime[npc.index] = time + GetGameTime(npc.index);
	
	fl_BEAM_ThrottleTime[client] = 0.0;
	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;
	skyloc = Npc_Vec;
	skyloc[2] += 300.0;
	npc.m_iFantasiaHits = 0;
	TE_SetupBeamPoints(Npc_Vec, skyloc, g_Ruina_Laser_BEAM, 0, 0, 0, time, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll(0.0);
	
	skyloc = Vec_offset;
	skyloc[2] += 300.0;
	TE_SetupBeamPoints(Vec_offset, skyloc, g_Ruina_Laser_BEAM, 0, 0, 0, time, 0.75, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll(0.0);
	
	SDKUnhook(client, SDKHook_Think, Witch_HorizontaSlicer_Tick);
	SDKUnhook(client, SDKHook_Think, Witch_VerticalSlicer_Tick);
	SDKHook(client, SDKHook_Think, Witch_VerticalSlicer_Tick);
}
static Action Witch_VerticalSlicer_Tick(int client)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < GameTime || npc.m_iFantasiaHits >10)
	{
		SDKUnhook(client, SDKHook_Think, Witch_VerticalSlicer_Tick);
		return Plugin_Stop;
	}
	if(fl_BEAM_ThrottleTime[client] > GameTime)
		return Plugin_Continue;

	fl_BEAM_ThrottleTime[client] = GameTime + 0.1;
	
	float Trg_Vec[3], Cur_Vec[3], Spn_Vec[3], vecAngles[3], skyloc[3];
	
	Trg_Vec = fl_AbilityVectorData[client];
	
	Spn_Vec = fl_starting_vec[client];
	
	float Dist = GetVectorDistance(Spn_Vec, Trg_Vec);

	float ratio = (fl_BEAM_DurationTime[npc.index]-GameTime) / (fl_vertical_slicer_max_timer*npc.BonusFireRate);
	
	MakeVectorFromPoints(Spn_Vec, Trg_Vec, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);

	Get_Fake_Forward_Vec(Dist*(1.0-ratio), vecAngles, Cur_Vec, Spn_Vec);
	
	int colour[4];
	colour[0] = 0;
	colour[1] = 125;
	colour[2] = 255;
	colour[3] = 255;

	skyloc = Cur_Vec;

	skyloc[2] += 150.0;

	Scientific_Witchery_DmgTrace(client, Cur_Vec, skyloc, 2.0, 8500.0); // Vertical Laser dmg

	Cur_Vec[2] -= 150.0;
	TE_SetupBeamPoints(Cur_Vec, skyloc, g_Ruina_Laser_BEAM, 0, 0, 0, 0.1, 5.0, 5.0, 0, 0.1, colour, 1);
	TE_SendToAll(0.0);

	return Plugin_Continue;
}

static void Scientific_Witchery_DmgTrace(int client, float Vec_1[3], float Vec_2[3], float radius, float dmg)
{
	Barrack_Alt_Scientific_Witchery npc = view_as<Barrack_Alt_Scientific_Witchery>(client);

	int inflictor = GetClientOfUserId(npc.OwnerUserId);
	if(inflictor==-1)
		inflictor=npc.index;

	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.Radius = radius;
	Laser.Start_Point = Vec_1;
	Laser.End_Point = Vec_2;
	Laser.Enumerate_Simple();
	for(int i=0 ; i < sizeof(i_Ruina_Laser_BEAM_HitDetected) ; i++)
	{
		int victim = i_Ruina_Laser_BEAM_HitDetected[i];

		if(!victim || npc.m_iFantasiaHits > 10)
			break;

		if(IsIn_HitDetectionCooldown(npc.index,victim))
			continue;
			
		Set_HitDetectionCooldown(npc.index,victim, GetGameTime() + 0.25);

		npc.m_iFantasiaHits++;

		SDKHooks_TakeDamage(victim, npc.index, inflictor, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), dmg, 1)), DMG_PLASMA);	// 2048 is DMG_NOGIB?
	}

}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}