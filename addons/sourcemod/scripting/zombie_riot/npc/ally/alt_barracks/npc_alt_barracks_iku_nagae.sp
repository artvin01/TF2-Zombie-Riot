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

static int i_laser_throttle[MAXENTITIES];

static float BEAM_Targets_Hit[MAXENTITIES];
static bool Ikunagae_BEAM_CanUse[MAXENTITIES];
static bool Ikunagae_BEAM_IsUsing[MAXENTITIES];
static int Ikunagae_BEAM_TicksActive[MAXENTITIES];
static int Ikunagae_BEAM_Laser;
static int Ikunagae_BEAM_Glow;
static float Ikunagae_BEAM_CloseDPT[MAXENTITIES];
static float Ikunagae_BEAM_FarDPT[MAXENTITIES];
static int Ikunagae_BEAM_MaxDistance[MAXENTITIES];
static int Ikunagae_BEAM_BeamRadius[MAXENTITIES];
static int Ikunagae_BEAM_ColorHex[MAXENTITIES];
static int Ikunagae_BEAM_ChargeUpTime[MAXENTITIES];
static float Ikunagae_BEAM_CloseBuildingDPT[MAXENTITIES];
static float Ikunagae_BEAM_FarBuildingDPT[MAXENTITIES];
static float Ikunagae_BEAM_Duration[MAXENTITIES];
static float Ikunagae_BEAM_ZOffset[MAXENTITIES];
static bool Ikunagae_BEAM_HitDetected[MAXENTITIES];
static int Ikunagae_BEAM_BuildingHit[MAXENTITIES];
static bool Ikunagae_BEAM_UseWeapon[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];

public void Barrack_Alt_Ikunagae_MapStart()
{
	PrecacheModel("models/player/medic.mdl");
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++)			{ PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_IdleSounds));   i++)					{ PrecacheSound(g_IdleSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));   i++) 			{ PrecacheSound(g_IdleAlertedSounds[i]);	}
	
	Ikunagae_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", true);
	Ikunagae_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

methodmap Barrack_Alt_Ikunagae < BarrackBody
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
	public Barrack_Alt_Ikunagae(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(BarrackBody(client, vecPos, vecAng, "450", "models/player/medic.mdl", STEPTYPE_NORMAL,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcInternalId[npc.index] = ALT_BARRACK_IKUNAGAE;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, Barrack_Alt_Ikunagae_ClotThink);

		npc.m_flSpeed = 250.0;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2	= npc.EquipItem("head", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_medic.mdl");
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
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 7, 255, 255, 255);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 7, 255, 255, 255);
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		
		
		i_laser_throttle[npc.index] = 0;
		
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		
		return npc;
	}
}

public void Barrack_Alt_Ikunagae_ClotThink(int iNPC)
{
	Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(iNPC);
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

			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				BarrackBody_ThinkMove(npc.index, 275.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 9999.0, _, false);
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.m_flAttackHappens = GameTime+0.4 * npc.BonusFireRate;
						npc.m_flAttackHappens_bullshit = GameTime+0.54 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(PrimaryThreatIndex, npc.index, GetClientOfUserId(npc.OwnerUserId), 3000.0 * npc.BonusDamageBonus, DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.8 * npc.BonusFireRate;
					}
				}
			}
			else
			{
				BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
				if(flDistanceToTarget < 300000 && npc.m_flNextMeleeAttack < GameTime)
				{
					npc.PlayPullSound();
					npc.m_flNextMeleeAttack = GameTime + 1.5 * npc.BonusFireRate;
					npc.AddGesture("ACT_MP_THROW");
					npc.FaceTowards(vecTarget, 20000.0);
					npc.FaceTowards(vecTarget, 20000.0);
					Normal_Attack_BEAM_Iku_Ability(npc.index);
				}

				npc.StartPathing();
			}
			int Enemy_I_See;		
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index))
				{	
					npc.m_iAmountProjectiles += 1;
					npc.m_flNextRangedBarrage_Singular = GameTime + 0.1;
					npc.PlayRangedSound();
							
					float flPos[3]; // original
					float flAng[3]; // original
					GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
								
					npc.FireParticleRocket(vecTarget, 1250.0 * npc.BonusDamageBonus , 850.0 , 100.0 , "raygun_projectile_blue_crit", _, false, true, flPos, _ , GetClientOfUserId(npc.OwnerUserId));
					if (npc.m_iAmountProjectiles >= 10)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GameTime + 15.0 * npc.BonusFireRate;
					}
				}
			}
		}
		else
		{
			BarrackBody_ThinkMove(npc.index, 250.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_RUN_MELEE_ALLCLASS", 290000.0, _, false);
			npc.PlayIdleSound();
		}
	}
}

void Barrack_Alt_Ikunagae_NPCDeath(int entity)
{
	Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, Barrack_Alt_Ikunagae_ClotThink);
}

static void Normal_Attack_BEAM_Iku_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		Ikunagae_BEAM_BuildingHit[building] = false;
	}
			
	Barrack_Alt_Ikunagae npc = view_as<Barrack_Alt_Ikunagae>(client);
	
	Ikunagae_BEAM_IsUsing[client] = false;
	Ikunagae_BEAM_TicksActive[client] = 0;

	Ikunagae_BEAM_CanUse[client] = true;
	Ikunagae_BEAM_CloseDPT[client] = Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),12500.0, 1);	//what the fuck
	Ikunagae_BEAM_FarDPT[client] = Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),2500.0, 1);
	Ikunagae_BEAM_MaxDistance[client] = 750;
	Ikunagae_BEAM_BeamRadius[client] = 2;
	Ikunagae_BEAM_ColorHex[client] = ParseColor("abdaf7");
	Ikunagae_BEAM_ChargeUpTime[client] = 12;
	Ikunagae_BEAM_CloseBuildingDPT[client] = 0.0;
	Ikunagae_BEAM_FarBuildingDPT[client] = 0.0;
	Ikunagae_BEAM_Duration[client] = 0.25;

	Ikunagae_BEAM_ZOffset[client] = 0.0;
	Ikunagae_BEAM_UseWeapon[client] = false;

	Ikunagae_BEAM_IsUsing[client] = true;
	Ikunagae_BEAM_TicksActive[client] = 0;

	CreateTimer(Ikunagae_BEAM_Duration[client], Ikunagae_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	
}
static Action Ikunagae_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	Ikunagae_BEAM_IsUsing[client] = false;
	
	Ikunagae_BEAM_TicksActive[client] = 0;
	
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
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !Ikunagae_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, Ikunagae_TBB_Tick);
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;
	
	i_laser_throttle[client]++;
	if(i_laser_throttle[client]<2)
	{
		return Plugin_Continue;
	}
	i_laser_throttle[client] = 0;

	Ikunagae_BEAM_TicksActive[client] = tickCount;
	float diameter = float(Ikunagae_BEAM_BeamRadius[client]);
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
		if(target > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(target);
		
			npc.FaceTowards(vecTarget, 20000.0);
			npc.FaceTowards(vecTarget, 20000.0);
		}
		

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Ikunagae_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
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
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Ikunagae_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			BEAM_Targets_Hit[client] = 1.0;
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Ikunagae_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
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
					SDKHooks_TakeDamage(victim, client, inflictor, (Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 1)/6)/BEAM_Targets_Hit[client], DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
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
	}
	return Plugin_Continue;
}