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

static float BEAM_Targets_Hit[MAXENTITIES];
static bool Ikunagae_BEAM_IsUsing[MAXENTITIES];
static int Ikunagae_BEAM_Laser;
static int Ikunagae_BEAM_Glow;
static float Ikunagae_BEAM_CloseDPT[MAXENTITIES];
static float Ikunagae_BEAM_FarDPT[MAXENTITIES];
static int Ikunagae_BEAM_MaxDistance[MAXENTITIES];
static int Ikunagae_BEAM_BeamRadius[MAXENTITIES];
static int Ikunagae_BEAM_ColorHex[MAXENTITIES];
static int Ikunagae_BEAM_ChargeUpTime[MAXENTITIES];
static float Ikunagae_BEAM_Duration[MAXENTITIES];
static bool Ikunagae_BEAM_HitDetected[MAXENTITIES];
static int Ikunagae_BEAM_BuildingHit[MAXENTITIES];
static int tickCountClient[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];

static int i_laser_throttle[MAXENTITIES];
static bool b_cannon_active[MAXENTITIES];
static float fl_cannon_recharge[MAXENTITIES];
static int i_throttle_amt[MAXENTITIES];
static bool ResetAnimBackToNorm[MAXENTITIES];
static float fl_normal_attack_timer[MAXENTITIES];

public void Barrack_Alt_Donnerkrieg_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
	
	Ikunagae_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
	Ikunagae_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheModel("materials/sprites/laserbeam.vmt", true);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Donnerkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_alt_donnerkrieg");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static float fl_npc_basespeed;

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return Barrack_Alt_Donnerkrieg(client, vecPos, vecAng);
}

methodmap Barrack_Alt_Donnerkrieg < BarrackBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME*0.5);
		
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				NpcSpeechBubble(this.index, "I wonder what my homeland has been like", 5, {255,255,255,255}, {0.0,0.0,60.0}, "...");
			}
			case 1:
			{
				NpcSpeechBubble(this.index, "Wheres schwert at?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 2:
			{
				NpcSpeechBubble(this.index, "Is ruina fine?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 3:
			{
				NpcSpeechBubble(this.index, "A little nice and quiet.", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
		}
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				NpcSpeechBubble(this.index, "uh oh!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 1:
			{
				NpcSpeechBubble(this.index, "Enemies never stop comming do they?", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 2:
			{
				NpcSpeechBubble(this.index, "Im too tired to cast my main spell here.", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 3:
			{
				NpcSpeechBubble(this.index, "Hey a little assistance here", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
		}
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public Barrack_Alt_Donnerkrieg(int client, float vecPos[3], float vecAng[3])
	{
		Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(BarrackBody(client, vecPos, vecAng, "650", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = Barrack_Alt_Donnerkrieg_NPCDeath;
		func_NPCThink[npc.index] = Barrack_Alt_Donnerkrieg_ClotThink;

		fl_npc_basespeed = 250.0;
		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);

		fl_normal_attack_timer[npc.index]=0.0;
		
		b_cannon_active[npc.index] = false;
		fl_cannon_recharge[npc.index] = GetGameTime(npc.index) + 10.0;
		
		i_laser_throttle[npc.index] = 0;
		ResetAnimBackToNorm[npc.index] = false;
		AcceptEntityInput(npc.m_iWearable1, "Enable");

		npc.m_flNextIdleSound = GetGameTime(npc.index) + GetRandomFloat(2.0, 3.0);
		
		return npc;
	}
}

public void Barrack_Alt_Donnerkrieg_ClotThink(int iNPC)
{
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(fl_normal_attack_timer[npc.index]>GameTime)
	{
		if(!b_cannon_active[npc.index])
			DonnerKrieg_Normal_Attack(npc);
	}
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);
		int PrimaryThreatIndex = npc.m_iTarget;
		
		if(ResetAnimBackToNorm[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			ResetAnimBackToNorm[npc.index] = false;
		}
		
		if(PrimaryThreatIndex>0)
		{
			
			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch < 0)
				return;	
			//Body pitch
			float v[3], ang[3];
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			float WorldSpaceVec_2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec_2);
			SubtractVectors(WorldSpaceVec, WorldSpaceVec_2, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
					
			float flPitch = npc.GetPoseParameter(iPitch);
					
			//	ang[0] = clamp(ang[0], -44.0, 89.0);
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}
		if(PrimaryThreatIndex > 0 && !b_cannon_active[npc.index])
		{
			npc.PlayIdleAlertSound();
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch < 0)
				return;		
				
			
			if(flDistanceToTarget < 250000 && fl_cannon_recharge[npc.index]<GameTime)
			{
				int Enemy_I_See;		
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					int iActivity = npc.LookupActivity("ACT_GRAPPLE_PULL_IDLE");
					if(iActivity > 0) npc.StartActivity(iActivity);
					Normal_Attack_BEAM_Iku_Ability(npc.index);
					b_cannon_active[npc.index] = true;
					fl_cannon_recharge[npc.index] = GameTime + 30.0*npc.BonusFireRate;
				}
			}

			if(npc.m_bAllowBackWalking)
				npc.FaceTowards(vecTarget);
			
			if(flDistanceToTarget < 100000 || npc.m_flAttackHappenswillhappen)
			{
				npc.m_bAllowBackWalking = true;
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
						
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayPullSound();
						npc.m_flAttackHappens =  GameTime+0.4*npc.BonusFireRate;
						npc.m_flAttackHappens_bullshit =  GameTime+0.54*npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = true;
						npc.FaceTowards(vecTarget);
						i_throttle_amt[npc.index] = 2;
						Primary_Attack_BEAM_Iku_Ability(npc.index, GameTime);
					}
					if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime+0.4*npc.BonusFireRate;
					}
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bAllowBackWalking = false;
			}
			int Enemy_I_See;		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(flDistanceToTarget < 300000 && IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime)
				{	
					npc.m_iAmountProjectiles += 1;
					npc.m_flNextRangedBarrage_Singular = GameTime + 0.1;
					npc.PlayRangedSound();
					
					float speed = 750.0;					
					float flPos[3]; // original
					float flAng[3]; // original
					GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
					
					PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed,_,vecTarget);					
					npc.FireParticleRocket(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), 2200.0, 1) , 850.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
					if (npc.m_iAmountProjectiles >= 15)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GameTime + 10.0 * npc.BonusFireRate;
					}
				}
			}
		}
		else
		{
			if(b_cannon_active[npc.index])
			{
				f_NpcTurnPenalty[npc.index] = 0.5;
				npc.m_flRangedArmor = 0.5;
				npc.m_flMeleeArmor = 0.5;
				i_throttle_amt[npc.index] = 10;
				BarrackBody_ThinkMove(npc.index, 0.0, "ACT_GRAPPLE_PULL_IDLE", "ACT_GRAPPLE_PULL_IDLE", 100000.0, false, false);
				
			}
			else
			{
				npc.PlayIdleSound();
			}
			
		}
		if(!b_cannon_active[npc.index])
			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE", "ACT_MP_RUN_MELEE", 100000.0, _, false);

		if(!b_cannon_active[npc.index])
		{
			if(npc.m_flNextMeleeAttack > GameTime)
			{
				npc.m_flSpeed = 10.0;
			}
			else
			{
				npc.m_flSpeed = fl_npc_basespeed;
			}
		}
	}
}

void Barrack_Alt_Donnerkrieg_NPCDeath(int entity)
{
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(entity);
	BarrackBody_NPCDeath(npc.index);
}

static void Primary_Attack_BEAM_Iku_Ability(int client, float GameTime)
{
	for (int building = 1; building < MaxClients; building++)
	{
		Ikunagae_BEAM_BuildingHit[building] = false;
	}
	
	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(client);

	Ikunagae_BEAM_CloseDPT[client] = 4000.0;
	Ikunagae_BEAM_FarDPT[client] = 2000.0;
	Ikunagae_BEAM_MaxDistance[client] = 500;
	Ikunagae_BEAM_BeamRadius[client] = 2;
	Ikunagae_BEAM_ColorHex[client] = ParseColor("abdaf7");
	Ikunagae_BEAM_ChargeUpTime[client] = RoundToFloor(12 * TickrateModify);

	tickCountClient[client] = 0;

	fl_normal_attack_timer[npc.index]=GameTime+0.25;
}

static void Normal_Attack_BEAM_Iku_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		Ikunagae_BEAM_BuildingHit[building] = false;
	}
	
	Ikunagae_BEAM_IsUsing[client] = false;

	Ikunagae_BEAM_CloseDPT[client] = 3500.0;	//what the fuck
	Ikunagae_BEAM_FarDPT[client] = 2250.0;
	Ikunagae_BEAM_MaxDistance[client] = 750;
	Ikunagae_BEAM_BeamRadius[client] = 5;
	Ikunagae_BEAM_ColorHex[client] = ParseColor("c22b2b");
	Ikunagae_BEAM_ChargeUpTime[client] = RoundToFloor(50 * TickrateModify);
	Ikunagae_BEAM_Duration[client] = 10.0;

	Ikunagae_BEAM_IsUsing[client] = true;

	tickCountClient[client] = 0;

	CreateTimer(Ikunagae_BEAM_Duration[client], Ikunagae_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	
}
static Action Ikunagae_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(client);
	
	Ikunagae_BEAM_IsUsing[client] = false;
	
	b_cannon_active[client] = false;
	f_NpcTurnPenalty[client] = 1.0;
	npc.m_flRangedArmor = 1.0;
	npc.m_flMeleeArmor = 1.0;

	tickCountClient[client] = 0;

	ResetAnimBackToNorm[client] = true;
	
	//StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	//StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	//StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	return Plugin_Continue;
}

static bool Ikunagae_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static bool Ikunagae_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Ikunagae_BEAM_HitDetected[entity] = true;
	}
	return false;
}

static Action Ikunagae_TBB_Tick(int client)
{
	if(!IsValidEntity(client) || !Ikunagae_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;
	
	i_laser_throttle[client]++;
	if(i_laser_throttle[client]<i_throttle_amt[client])
	{
		return Plugin_Continue;
	}
	i_laser_throttle[client] = 0;
	
	float diameter = float(Ikunagae_BEAM_BeamRadius[client]*2);
	int r = GetR(Ikunagae_BEAM_ColorHex[client]);
	int g = GetG(Ikunagae_BEAM_ColorHex[client]);
	int b = GetB(Ikunagae_BEAM_ColorHex[client]);
	if (Ikunagae_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		Barrack_Alt_Donnerkrieg npc = view_as<Barrack_Alt_Donnerkrieg>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		
		float flAng[3]; // original
		GetAttachment(npc.index, "effect_hand_r", startPoint, flAng);
		
		int target = npc.m_iTarget;
		if(IsValidEntity(target))
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		
			int Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.FaceTowards(vecTarget, 20000.0);
				npc.FaceTowards(vecTarget, 20000.0);
			}
		}
		

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Ikunagae_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(Ikunagae_BEAM_MaxDistance[client]));
			float lineReduce = Ikunagae_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				Ikunagae_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(Ikunagae_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			delete trace;
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Ikunagae_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			BEAM_Targets_Hit[client] = 1.0;
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Ikunagae_BEAM_HitDetected[victim] && GetTeam(client) != GetTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Ikunagae_BEAM_CloseDPT[client] + (Ikunagae_BEAM_FarDPT[client]-Ikunagae_BEAM_CloseDPT[client]) * (distance/Ikunagae_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;
						
					int inflictor = GetClientOfUserId(npc.OwnerUserId);
					if(inflictor==-1)
					{
						inflictor=client;
					}
					float EnemyVecPos[3]; WorldSpaceCenter(victim, EnemyVecPos);
					SDKHooks_TakeDamage(victim, client, inflictor, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1)/6) * BEAM_Targets_Hit[client], DMG_PLASMA, -1, NULL_VECTOR, EnemyVecPos);	// 2048 is DMG_NOGIB?
					BEAM_Targets_Hit[client] *= LASER_AOE_DAMAGE_FALLOFF;
				}
			}
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
		delete trace;
	}
	return Plugin_Continue;
}

static void DonnerKrieg_Normal_Attack(Barrack_Alt_Donnerkrieg npc)
{
	int tickCount = tickCountClient[npc.index];
	tickCountClient[npc.index]++;
	
	i_laser_throttle[npc.index]++;
	if(i_laser_throttle[npc.index]<i_throttle_amt[npc.index])
	{
		return;
	}
	i_laser_throttle[npc.index] = 0;

	float diameter = float(Ikunagae_BEAM_BeamRadius[npc.index]*2);
	int r = GetR(Ikunagae_BEAM_ColorHex[npc.index]);
	int g = GetG(Ikunagae_BEAM_ColorHex[npc.index]);
	int b = GetB(Ikunagae_BEAM_ColorHex[npc.index]);
	if (Ikunagae_BEAM_ChargeUpTime[npc.index] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		
		float flAng[3]; // original
		GetAttachment(npc.index, "effect_hand_r", startPoint, flAng);
		
		int target = npc.m_iTarget;
		if(IsValidEntity(target))
		{
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		
			int Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.FaceTowards(vecTarget, 20000.0);
				npc.FaceTowards(vecTarget, 20000.0);
			}
		}
		

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Ikunagae_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(Ikunagae_BEAM_MaxDistance[npc.index]));
			float lineReduce = Ikunagae_BEAM_BeamRadius[npc.index] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				Ikunagae_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(Ikunagae_BEAM_BeamRadius[npc.index]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			delete trace;
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Ikunagae_BEAM_TraceUsers, npc.index);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			BEAM_Targets_Hit[npc.index] = 1.0;
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Ikunagae_BEAM_HitDetected[victim] && GetTeam(npc.index) != GetTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Ikunagae_BEAM_CloseDPT[npc.index] + (Ikunagae_BEAM_FarDPT[npc.index]-Ikunagae_BEAM_CloseDPT[npc.index]) * (distance/Ikunagae_BEAM_MaxDistance[npc.index]);
					if (damage < 0)
						damage *= -1.0;
						
					int inflictor = GetClientOfUserId(npc.OwnerUserId);
					if(inflictor==-1)
					{
						inflictor=npc.index;
					}
					float WorldSpaceVec[3]; WorldSpaceCenter(victim, WorldSpaceVec);
					SDKHooks_TakeDamage(victim, npc.index, inflictor, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId), damage, 1)/6)*BEAM_Targets_Hit[npc.index], DMG_PLASMA, -1, NULL_VECTOR, WorldSpaceVec);	// 2048 is DMG_NOGIB?
					BEAM_Targets_Hit[npc.index] *= LASER_AOE_DAMAGE_FALLOFF;
				}
			}
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(startPoint, endPoint, Ikunagae_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
		delete trace;
	}
}