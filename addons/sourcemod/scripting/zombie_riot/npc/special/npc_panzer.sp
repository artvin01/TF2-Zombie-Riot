#pragma semicolon 1
#pragma newdecls required


#define LASERBEAM_PANZER "cable/rope.vmt"
#define ENERGY_BALL_MODEL_PANZER 	"models/weapons/w_models/w_drg_ball.mdl"

static char g_DeathSounds[][] = {
	"zombie_riot/panzer/death.mp3",
};

static char g_GrappleSound[][] = {
	"zombie_riot/panzer/grapple_2.mp3",
};
static char g_FlameSounds[][] = {
	"ambient/fire/mtov_flame2.wav",
};

static char g_HurtSounds[][] = {
	"physics/metal/metal_solid_impact_bullet1.wav",
	"physics/metal/metal_solid_impact_bullet2.wav",
	"physics/metal/metal_solid_impact_bullet3.wav",
	"physics/metal/metal_solid_impact_bullet4.wav",
};

static char g_IdleSounds[][] = {
	"zombie_riot/panzer/passive1.mp3",
	"zombie_riot/panzer/passive2.mp3",
	"zombie_riot/panzer/passive3.mp3",
};

static char g_SpawnSounds[][] = {
	"zombie_riot/panzer/spawn.mp3",
};


static char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_MeleeHitSounds[][] = {
	"mvm/melee_impacts/metal_gloves_hit_robo01.wav",
	"mvm/melee_impacts/metal_gloves_hit_robo02.wav",
	"mvm/melee_impacts/metal_gloves_hit_robo03.wav",
	"mvm/melee_impacts/metal_gloves_hit_robo04.wav",
};
static char g_MeleeAttackSounds[][] = {
	"vo/null.mp3",
};

static char g_AngerSounds[][] = {
	"zombie_riot/panzer/visordown.mp3",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

public void NaziPanzer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSoundCustom(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_SpawnSounds));	   i++) { PrecacheSoundCustom(g_SpawnSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSoundCustom(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSoundCustom(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GrappleSound));   i++) { PrecacheSoundCustom(g_GrappleSound[i]);   }
	for (int i = 0; i < (sizeof(g_FlameSounds));   i++) { PrecacheSound(g_FlameSounds[i]);   }

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel(LASERBEAM_PANZER);
	PrecacheModel(ENERGY_BALL_MODEL_PANZER);
	PrecacheModel("models/zombie_riot/cod_zombies/panzer_soldat_2.mdl");
}

static char[] GetPanzerHealth()
{
	int health = 110;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(CurrentRound+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.20));
	}
	else if(CurrentRound+1 < 45)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.25));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(CurrentRound+1)) * float(CurrentRound+1)),1.35)); //Yes its way higher but i reduced overall hp of him
	}
	
	health /= 2;
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}
	
methodmap NaziPanzer < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitCustomToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(7.0, 10.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.25;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayFlameSound() {
		if(this.m_flNextFlameSound > GetGameTime(this.index))
			return;
			
		this.m_flNextFlameSound = GetGameTime(this.index) + 0.25;
		
		EmitSoundToAll(g_FlameSounds[GetRandomInt(0, sizeof(g_FlameSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayGrappleSound() {
	
		EmitSoundToAll(g_GrappleSound[GetRandomInt(0, sizeof(g_GrappleSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_GrappleSound[GetRandomInt(0, sizeof(g_GrappleSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlaySpawnSound() {
	
		EmitCustomToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, 80, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, 80, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayAngerSound() {
	
		EmitCustomToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void FireHook(float vecTarget[3])
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 44.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		vecSwingStart[0] += vecForward[0] * 1;
		vecSwingStart[1] += vecForward[1] * 1;
		vecSwingStart[2] += vecForward[2] * 1;

		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*1200.0;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*1200.0;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-1200.0;

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			SetEntityCollisionGroup(entity, 19);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 20.0, true);	// Damage
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 2.0);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			SetEntityModel(entity, "models/weapons/w_bullet.mdl");
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 19);
			
			float position[3];
			
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
			
			int particle = 0;
			
			particle = ParticleEffectAt(position, "drg_cow_rockettrail_normal_blue", 5.0);
				
			SetParent(entity, particle);
			
			if(IsValidEntity(this.m_iWearable3))
				RemoveEntity(this.m_iWearable3);

			this.m_iWearable3 = ConnectWithBeam(this.index, entity, 5, 5, 5, 3.0, 3.0, 1.0, LASERBEAM_PANZER);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Panzer_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
			
		}
	}
	
	public NaziPanzer(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		NaziPanzer npc = view_as<NaziPanzer>(CClotBody(vecPos, vecAng, "models/zombie_riot/cod_zombies/panzer_soldat_2.mdl", "1.15", GetPanzerHealth(), ally, false, true));
		
		i_NpcInternalId[npc.index] = NAZI_PANZER;
		i_NpcWeight[npc.index] = 3;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
	
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextDelayTime = GetGameTime(npc.index) + 0.2;
		//IDLE
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;		

		
		
		SDKHook(npc.index, SDKHook_Think, NaziPanzer_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, NaziPanzer_ClotDamagedPost);
		
		npc.m_flSpeed = 0.0;
		npc.m_flNextThinkTime = GetGameTime(npc.index) + 3.0;
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 3.0;
		npc.m_flNextFlameSound = 0.0;
		npc.m_flFlamerActive = 0.0;
		npc.m_bDoSpawnGesture = true;
		npc.m_bLostHalfHealth = false;
		npc.m_bLostHalfHealthAnim = false;
		npc.m_bDuringHighFlight = false;
		npc.m_bDuringHook = false;
		npc.m_bGrabbedSomeone = false;
		npc.m_bUseDefaultAnim = false;
		npc.m_bFlamerToggled = false;
		npc.m_bDissapearOnDeath = true;
		
		float wave = float(ZR_GetWaveCount()+1);
		
		wave *= 0.1;
	
		npc.m_flWaveScale = wave;
		
//		SetEntPropFloat(npc.index, Prop_Data, "m_speed",npc.m_flSpeed);
		npc.m_flAttackHappenswillhappen = false;
		npc.StartPathing();
		
		return npc;
	}
	
	public bool DoSwingTraceFlamer(Handle &trace, int target)
	{
		// Setup a volume for the melee weapon to be swung - approx size, so 125 melee behave the same.
		static float vecSwingMins[3]; vecSwingMins = view_as<float>({-125.0, -100.0, -150.0});
		static float vecSwingMaxs[3]; vecSwingMaxs = view_as<float>({125.0, 125.0, 150.0});
	
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);
		
		float vecForward[3], vecRight[3], vecTarget[3];
		
		vecTarget = WorldSpaceCenter(target);
		MakeVectorFromPoints(WorldSpaceCenter(this.index), vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		vecForward[1] = eyePitch[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
		
		float vecSwingStart[3]; vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 44.0;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * 125;
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * 125;
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * 150;
		
//		TE_SetupBeamPoints(vecSwingStart, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//		TE_SendToAll();
		
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, this.index );
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID | CONTENTS_SOLID ), BulletAndMeleeTrace, this.index );
			if ( TR_GetFraction(trace) < 1.0)
			{
				// This is the point on the actual surface (the hull could have hit space)
				TR_GetEndPosition(vecSwingEnd, trace);	
			}
		}
		return ( TR_GetFraction(trace) < 1.0 );
	}
}

//TODO 
//Rewrite
public void NaziPanzer_ClotThink(int iNPC)
{
	NaziPanzer npc = view_as<NaziPanzer>(iNPC);
	
	if(!npc.m_bLostHalfHealth)
	{
		SetVariantInt(1);
		AcceptEntityInput(iNPC, "SetBodyGroup");
	}
	else
	{
		SetVariantInt(0);
		AcceptEntityInput(iNPC, "SetBodyGroup");		
		
	}
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_bDoSpawnGesture)
	{
		npc.PlaySpawnSound();
		npc.AddGesture("ACT_PANZER_SPAWN");
		npc.m_bDoSpawnGesture = false;
	}
	if(npc.m_bUseDefaultAnim)
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_bUseDefaultAnim = false;
	}
	
	if(npc.m_flDoSpawnGesture < GetGameTime(npc.index))
	{
		if(npc.m_bDuringHighFlight)
			npc.m_flSpeed = 900.0;
		else
			npc.m_flSpeed = 300.0;

		if (npc.m_bLostHalfHealthAnim && npc.m_bLostHalfHealth)
		{
			if(npc.m_bDuringHighFlight)
			{
				int iActivity = npc.LookupActivity("ACT_FLY_LOOP");
				if(iActivity > 0) npc.StartActivity(iActivity);
			}
			else
			{
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity > 0) npc.StartActivity(iActivity);
			}
			npc.m_bLostHalfHealthAnim = false;
		}
	}
	else if (!npc.m_bLostHalfHealthAnim && npc.m_bLostHalfHealth)
	{
		npc.m_flNextThinkTime = npc.m_flDoSpawnGesture;
		npc.AddGesture("PANZER_STAGGER_2");
		npc.m_flSpeed = 0.0;
		npc.m_bLostHalfHealthAnim = true;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
	}
	if(npc.m_flStandStill > GetGameTime(npc.index))
	{
		npc.m_flSpeed = 0.0;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;		
	}
	else
	{
		if(npc.m_bDuringHook)
		{
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_bDuringHook = false;
		}
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
	//		PrintToChatAll("cutoff");
			NPC_SetGoalVector(npc.index, vPredictedPos);	
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
		}
		
		npc.StartPathing();
		
		if(npc.m_bGrabbedSomeone)
		{
			Handle swingTrace;
			npc.FaceTowards(vecTarget, 20000.0);
			if(npc.DoSwingTrace(swingTrace, closest,_,_,_,1))
			{
				int target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(target > 0) 
				{
					KillFeed_SetKillIcon(npc.index, "taunt_sniper");

					float damage = 5.0;
					
					if(!ShouldNpcDealBonusDamage(target))
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_BURN);
						if(IsValidClient(target))
							TF2_IgnitePlayer(target, target, 4.0);
					}
					else
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 2.0 * npc.m_flWaveScale, DMG_BURN);
				}
				npc.PlayFlameSound();
			}
			delete swingTrace;
		}
		else if(flDistanceToTarget < 160000 && npc.m_bDuringHighFlight)
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
				
			if(npc.m_flGrappleCooldown > GetGameTime(npc.index))
			{
				npc.m_flGrappleCooldown += 4.0;
			}
			else
			{
				npc.m_flGrappleCooldown = GetGameTime(npc.index) + 4.0;
			}
			
			
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.AddGesture("ACT_FLY_LAND");
			npc.m_bDuringHighFlight = false;
			npc.m_flStandStill = GetGameTime(npc.index) + 1.25;
		}
		else if (flDistanceToTarget < 20000 && npc.m_bFlamerToggled)
		{
			if(npc.m_flFlamerActive > GetGameTime(npc.index))
			{
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, closest,_,_,_,1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					if(target > 0) 
					{
						KillFeed_SetKillIcon(npc.index, "degreaser");

						float damage = 20.0;
						
						if(!ShouldNpcDealBonusDamage(target))
						{
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_BURN);
							if(IsValidClient(target))
								TF2_IgnitePlayer(target, target, 4.0);
						}
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 2.0 * npc.m_flWaveScale, DMG_BURN);
					}
					npc.PlayFlameSound();
				}
				delete swingTrace;
			}
			else
			{
				npc.m_bFlamerToggled = false;
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity > 0) npc.StartActivity(iActivity);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
			}
		}
		else if(flDistanceToTarget < 12500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
		//	npc.FaceTowards(vecTarget, 20000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.2;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.33;
					npc.m_flAttackHappenswillhappen = true;
				}
				//Can we attack right now?
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest,_,_,_,1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						if(target > 0) 
						{
							KillFeed_SetKillIcon(npc.index, "steel_fists");

							float damage = 50.0;
							
							if(!ShouldNpcDealBonusDamage(target))
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 2.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
							
							
								
							// Hit sound
							npc.PlayMeleeHitSound();
						}
						else
						{
							npc.PlayMeleeMissSound();
						}
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.2;
				}
			}
			
		}
		else if(flDistanceToTarget > 12500 && flDistanceToTarget < 1000000 && !npc.m_bDuringHighFlight && npc.m_flGrappleCooldown < GetGameTime(npc.index) && !npc.m_bDuringHook)
		{
			
			int HumanTarget = GetClosestTarget(npc.index, true);	//So he only tries to grab humans
			int target;
			
			target = Can_I_See_Enemy(npc.index, HumanTarget);
			if (target == HumanTarget)
			{
				float vecTargetHook[3]; vecTargetHook = WorldSpaceCenter(HumanTarget);
				npc.FaceTowards(vecTargetHook, 20000.0);
				
				float projectile_speed = 1200.0;
			
				float vPredictedPosHuman[3];
				vPredictedPosHuman = PredictSubjectPositionForProjectiles(npc, HumanTarget, projectile_speed);
				npc.FireHook(vPredictedPosHuman);
				npc.m_flGrappleCooldown = GetGameTime(npc.index) + 30.0;
				
				int iActivity = npc.LookupActivity("ACT_HOOK_SHOOT");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.m_flStandStill = GetGameTime(npc.index) + 5.0;
				npc.m_bDuringHook = true;
				npc.PlayGrappleSound();
			}
			else
			{
				npc.m_flGrappleCooldown = GetGameTime(npc.index) + 0.2;	
				
			}
		}
		else if(flDistanceToTarget > 1250000/*1100*/ && !npc.m_bDuringHighFlight && !npc.m_bFlamerToggled && !NpcStats_IsEnemySilenced(npc.index))
		{
				
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			if(IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);
				
			float flPos[3]; // original
			float flAng[3]; // original
	
			npc.GetAttachment("jetpack_R", flPos, flAng);
				
			npc.m_iWearable1 = ParticleEffectAt(flPos, "spell_fireball_small_red", 0.0);
				
			SetParent(npc.index, npc.m_iWearable1, "jetpack_R");
			
			npc.GetAttachment("jetpack_L", flPos, flAng);
				
			npc.m_iWearable2 = ParticleEffectAt(flPos, "spell_fireball_small_red", 0.0);
				
			SetParent(npc.index, npc.m_iWearable2, "jetpack_L");
			
			int iActivity = npc.LookupActivity("ACT_FLY_LOOP");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.AddGesture("ACT_FLY_START");
			npc.m_bDuringHighFlight = true;
			npc.m_flStandStill = GetGameTime(npc.index) + 1.2;
		}
		//Target close enough to hit
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}


public Action NaziPanzer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	NaziPanzer npc = view_as<NaziPanzer>(victim);
	
	
	if(npc.m_flDoSpawnGesture > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.PlayHurtSound();
	}
//	
	return Plugin_Changed;
}

public void NaziPanzer_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	NaziPanzer npc = view_as<NaziPanzer>(victim);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth) //Anger after half hp/400 hp
	{
		npc.m_flDoSpawnGesture = GetGameTime(npc.index) + 1.5;
	//	npc.AddGesture("ACT_PANZER_STAGGER");
		npc.PlayAngerSound();
		npc.m_bLostHalfHealth = true;
		npc.m_flFlamerActive = 0.0;
		npc.m_bFlamerToggled = false;
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
				
		npc.m_bDuringHook = false;
		npc.m_flHookDamageTaken = 0.0;
		npc.m_flStandStill = 0.0;
		npc.m_bGrabbedSomeone = false;
	}
	
	if(npc.m_bGrabbedSomeone || npc.m_bDuringHook)
	{
		npc.m_flHookDamageTaken += damage;
		if(npc.m_flHookDamageTaken > GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/10)
		{
			npc.m_bUseDefaultAnim = true;
			npc.m_bGrabbedSomeone = false;
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);
			npc.m_bDuringHook = false;
			npc.m_flHookDamageTaken = 0.0;
			npc.m_flStandStill = 0.0;
			
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
				
			npc.m_flGrappleCooldown = GetGameTime(npc.index) + 25.0;
			
			npc.m_flFlamerActive = 0.0;
			npc.m_bFlamerToggled = false;
		}
	}
}

public void NaziPanzer_NPCDeath(int entity)
{
	NaziPanzer npc = view_as<NaziPanzer>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	
	SDKUnhook(npc.index, SDKHook_Think, NaziPanzer_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, NaziPanzer_ClotDamagedPost);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
			
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
		
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
		
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
		
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
		
				
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);
		
//		Angles[1] += 90.0;
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/cod_zombies/panzer_soldat_2.mdl");

		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("panzer_death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(2.0, Timer_RemoveEntityPanzer, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);

	}
			
//	AcceptEntityInput(npc.index, "KillHierarchy");

	Citizen_MiniBossDeath(entity);
}

#define HookRadius 54.0

public MRESReturn Panzer_DHook_RocketExplodePre(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (owner > MaxClients)
	{
		NaziPanzer npc = view_as<NaziPanzer>(owner);
		
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		float ProjectileLoc[3];
		float VicLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		int Closest_Player = GetClosestTarget(entity, true, _, false, true);
		if(IsValidEntity(Closest_Player) && IsValidClient(Closest_Player))
		{
			GetEntPropVector(Closest_Player, Prop_Data, "m_vecAbsOrigin", VicLoc);
			VicLoc[2] += 45;
			if (GetVectorDistance(ProjectileLoc, VicLoc, true) <= (HookRadius * HookRadius))
			{
				int iActivity = npc.LookupActivity("ACT_HOOK_CAUGHT");
				if(iActivity > 0) npc.StartActivity(iActivity);
				DataPack pack;
				CreateDataTimer(0.1, Timer_Pull_Target, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				pack.WriteCell(EntIndexToEntRef(owner));
				pack.WriteCell(GetClientUserId(Closest_Player));
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				npc.m_iWearable3 = ConnectWithBeam(npc.index, Closest_Player, 5, 5, 5, 3.0, 3.0, 1.0, LASERBEAM_PANZER);
				npc.m_bGrabbedSomeone = true;
				npc.m_flStandStill = 9999999.0;	
				
				float flPos[3]; // original
				float flAng[3]; // original
	
				npc.GetAttachment("flamer", flPos, flAng);
				
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 0.0);
				
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				
				SetParent(npc.index, npc.m_iWearable5, "flamer");
			}
			else
			{
				if(IsValidEntity(npc.m_iWearable3))
					RemoveEntity(npc.m_iWearable3);
				int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
				npc.m_bDuringHook = false;
				npc.m_flHookDamageTaken = 0.0;
				npc.m_flStandStill = 0.0;	
				npc.m_flFlamerActive = GetGameTime(npc.index) + 10.0;
				npc.m_bFlamerToggled = true;
				
				float flPos[3]; // original
				float flAng[3]; // original
	
				npc.GetAttachment("flamer", flPos, flAng);
				
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
					
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 0.0);
				
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				
				SetParent(npc.index, npc.m_iWearable5, "flamer");
			}
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable3))
				RemoveEntity(npc.m_iWearable3);
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_bDuringHook = false;
			npc.m_flHookDamageTaken = 0.0;
			npc.m_flStandStill = 0.0;
		}
	}
	RemoveEntity(entity);
	return MRES_Supercede;
}

public Action Timer_Pull_Target(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity<=MaxClients || !IsValidEntity(entity))
		return Plugin_Stop;
		
	NaziPanzer npc = view_as<NaziPanzer>(entity);
	
	int client = GetClientOfUserId(pack.ReadCell());
	NaziPanzer player = view_as<NaziPanzer>(client);
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || player.m_bThisEntityIgnored)
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_bDuringHook = false;
		npc.m_flHookDamageTaken = 0.0;
		npc.m_flStandStill = 0.0;
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		npc.m_bGrabbedSomeone = false;
		
		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
					
		return Plugin_Stop;		
	}
		
	if(!npc.m_bDuringHook)
		return Plugin_Stop;
		
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	
	float cpos[3];
	GetClientAbsOrigin(client, cpos);
	
	float velocity[3];
	MakeVectorFromPoints(pos, cpos, velocity);
	NormalizeVector(velocity, velocity);
	ScaleVector(velocity, -450.0);
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	return Plugin_Continue;
}