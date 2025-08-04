#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

static const char g_BuildingSentrySounds[][] = {
	"vo/engineer_autobuildingsentry01.mp3",
	"vo/engineer_autobuildingsentry02.mp3",
};

static const char g_BuildingDispenserSounds[][] = {
	"vo/engineer_autobuildingdispenser01.mp3",
	"vo/engineer_autobuildingdispenser02.mp3",
};

static const char g_BuildingTeleporterSounds[][] = {
	"vo/engineer_autobuildingteleporter01.mp3",
	"vo/engineer_autobuildingteleporter02.mp3",
};

static const char g_BuildingBuiltSound[] = "weapons/sentry_finish.wav";

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

enum
{
	APT_BUILDER_STATE_IDLE,
	APT_BUILDER_STATE_WANTS_TO_BUILD,
	APT_BUILDER_STATE_BUILDING,
	APT_BUILDER_STATE_WANTS_TO_REPAIR,
	APT_BUILDER_STATE_REPAIRING,
}

enum
{
	APT_BUILDER_HAS_SENTRY = (1 << 0),
	APT_BUILDER_HAS_DISPENSER = (1 << 1),
	APT_BUILDER_HAS_TELEPORTER = (1 << 2),
	
	APT_BUILDER_HAS_ALL_BUILDINGS = 7, // 1, 2, 4
}

static int BuildingsOwned[MAXENTITIES];
static float NextBuildingTime[MAXENTITIES];
static bool QuickBuildings[MAXENTITIES];

static bool b_WantTobuild[MAXENTITIES];
static bool b_AlreadyReparing[MAXENTITIES];
static float f_RandomTolerance[MAXENTITIES];
static int i_BuildingRef[MAXENTITIES];

void ApertureBuilder_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_BuildingSentrySounds)); i++) { PrecacheSound(g_BuildingSentrySounds[i]); }
	for (int i = 0; i < (sizeof(g_BuildingDispenserSounds)); i++) { PrecacheSound(g_BuildingDispenserSounds[i]); }
	for (int i = 0; i < (sizeof(g_BuildingTeleporterSounds)); i++) { PrecacheSound(g_BuildingTeleporterSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	
	PrecacheSound(g_BuildingBuiltSound);
	
	PrecacheModel("models/player/engineer.mdl");
	PrecacheModel("models/weapons/c_models/c_wrench/c_wrench.mdl");
	PrecacheModel("models/weapons/c_models/c_toolbox/c_toolbox.mdl");
	PrecacheModel("models/player/items/engineer/hardhat.mdl");
	
	PrecacheSound("music/mvm_class_select.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Aperture Builder");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aperture_builder");
	strcopy(data.Icon, sizeof(data.Icon), "engineer");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ApertureBuilder(vecPos, vecAng, ally);
}
methodmap ApertureBuilder < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayBuildingSentrySound() 
	{
		EmitSoundToAll(g_BuildingSentrySounds[GetRandomInt(0, sizeof(g_BuildingSentrySounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayBuildingDispenserSound() 
	{
		EmitSoundToAll(g_BuildingDispenserSounds[GetRandomInt(0, sizeof(g_BuildingDispenserSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayBuildingTeleporterSound() 
	{
		EmitSoundToAll(g_BuildingTeleporterSounds[GetRandomInt(0, sizeof(g_BuildingTeleporterSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayBuildingBuiltSound(int building) 
	{
		EmitSoundToAll(g_BuildingBuiltSound, building, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 130);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	property int m_iBuildingsOwned
	{
		public get()							{ return BuildingsOwned[this.index]; }
		public set(int TempValueForProperty) 	{ BuildingsOwned[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextBuildingTime
	{
		public get()							{ return NextBuildingTime[this.index]; }
		public set(float TempValueForProperty) 	{ NextBuildingTime[this.index] = TempValueForProperty; }
	}
	
	property bool m_bQuickBuildings
	{
		public get()							{ return QuickBuildings[this.index]; }
		public set(bool TempValueForProperty) 	{ QuickBuildings[this.index] = TempValueForProperty; }
	}
	
	public ApertureBuilder(float vecPos[3], float vecAng[3], int ally)
	{
		ApertureBuilder npc = view_as<ApertureBuilder>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "700", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ApertureBuilder_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ApertureBuilder_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ApertureBuilder_ClotThink);

		i_ClosestAllyCD[npc.index] = 0.0;
		
		
		//IDLE
		npc.m_iState = APT_BUILDER_STATE_IDLE;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopPathing(); // Don't path straight away, so we don't fall off an edge right after spawning
		npc.m_flSpeed = 300.0;
		
		// We just spawned, our mission is to build our shit asap
		npc.m_bQuickBuildings = true;
		npc.m_flNextBuildingTime = GetGameTime() + 0.75;
		
		npc.m_iBuildingsOwned = 0;

		b_WantTobuild[npc.index] = true;
		b_AlreadyReparing[npc.index] = false;
		f_RandomTolerance[npc.index] = GetRandomFloat(0.25, 0.75);
		Is_a_Medic[npc.index] = true;
		i_BuildingRef[npc.index] = -1;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/engineer/hardhat.mdl");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		npc.ToggleBuilding(false);
		
		// Attempt to spawn the builder out of most players' sights. We'll give a few tries while loosening the requirement each time
		// If we can't find an appropriate spot, just ignore LOS
		const int maxAttempts = 12;
		const float loosenedReqPerAttempt = 0.06;
		int livingPlayerCount = CountPlayersOnRed(2); // 2 = excludes teutons and downed players
		
		for (int i = 0; i < maxAttempts; i++)
		{
			TeleportDiversioToRandLocation(npc.index, true, 2000.0, 1500.0);
			
			int visiblePlayerCount;
			
			for (int client = 1; client <= MaxClients; client++)
			{
				if (IsValidEnemy(npc.index, client) && Can_I_See_Enemy(npc.index, client))
					visiblePlayerCount++;
			}
			
			float percentage = float(visiblePlayerCount) / float(livingPlayerCount);
			
			// We got what we wanted, no need to try to teleport anymore
			if (percentage <= i * loosenedReqPerAttempt)
				break;
		}
		
		EmitSoundToAll("music/mvm_class_select.wav", _, _, _, _, 0.5);	
		EmitSoundToAll("music/mvm_class_select.wav", _, _, _, _, 1.0);	
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%s", "Engineers Appear");
			}
		}
		
		float vecNewPos[3];
		GetAbsOrigin(npc.index, vecNewPos);
		ParticleEffectAt(vecNewPos, "teleported_blue");
		
		return npc;
	}
	
	public void ToggleBuilding(bool toggle)
	{
		// This is just used to swap building weapons
		if (IsValidEntity(this.m_iWearable2))
			RemoveEntity(this.m_iWearable2);
		
		int activity;
		if (toggle)
		{
			this.m_iWearable2 = this.EquipItem("head", "models/weapons/c_models/c_toolbox/c_toolbox.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(this.m_iWearable2, "SetModelScale");
			
			SetEntProp(this.m_iWearable2, Prop_Send, "m_nSkin", 1);
			
			activity = this.LookupActivity("ACT_MP_RUN_BUILDING_DEPLOYED");
		}
		else
		{
			this.m_iWearable2 = this.EquipItem("head", "models/weapons/c_models/c_wrench/c_wrench.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(this.m_iWearable2, "SetModelScale");
			
			activity = this.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		}
		
		if (activity > 0)
			this.StartActivity(activity);
	}
}

public void ApertureBuilder_ClotThink(int iNPC)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	switch (npc.m_iState)
	{
		case APT_BUILDER_STATE_IDLE:
		{
			if (npc.m_iBuildingsOwned != APT_BUILDER_HAS_ALL_BUILDINGS)
			{
				if (npc.m_flNextBuildingTime < gameTime)
				{
					f3_NpcSavePos[npc.index] = { 0.0, 0.0, 0.0 };
					npc.m_iState = APT_BUILDER_STATE_WANTS_TO_BUILD;
					
					return;
				}
			}
			else
			{
				// TODO: Maybe think about repairing stuff while in this state?
			}
		}
		
		case APT_BUILDER_STATE_WANTS_TO_BUILD:
		{
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			
			if (npc.m_flNextBuildingTime < gameTime)
			{
				if (!GetVectorLength(f3_NpcSavePos[npc.index], true))
				{
					bool success = false;
					
					// We want to search for a valid spot around us to build something first
					for (int i = 0; i < 60; i++)
					{
						float vecPotentialPos[3], vecBuffer[3];
						GetAbsOrigin(npc.index, vecBuffer);
						vecPotentialPos = vecBuffer;
						
						vecPotentialPos[0] = GetRandomFloat((vecPotentialPos[0] - 200.0), (vecPotentialPos[0] + 200.0));
						vecPotentialPos[1] = GetRandomFloat((vecPotentialPos[1] - 200.0), (vecPotentialPos[1] + 200.0));
						
						Handle trace = TR_TraceRayFilterEx(vecBuffer, vecPotentialPos, GetSolidMask(npc.index), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
						if (TR_DidHit(trace))
						{
							delete trace;
							continue;
						}
						
						delete trace;
						
						trace = TR_TraceRayFilterEx(vecPotentialPos, view_as<float>( { 90.0, 0.0, 0.0 } ), GetSolidMask(npc.index), RayType_Infinite, BulletAndMeleeTrace, npc.index);
						
						TR_GetEndPosition(vecPotentialPos, trace);
						delete trace;
						
						CNavArea area = TheNavMesh.GetNearestNavArea(vecPotentialPos, true);
						if (area == NULL_AREA)
							continue;
			
						int navAttribs = area.GetAttributes();
						if (navAttribs & NAV_MESH_AVOID)
							continue;
						
						float vecMins[3] = { -35.0, -35.0, 0.0 };
						float vecMaxs[3] = { 35.0, 35.0, 130.0 };
						
						vecPotentialPos[2] += 1.0;
						if (IsBoxHazard(vecPotentialPos, vecMins, vecMaxs))
							continue;
						
						if (IsSpaceOccupiedIgnorePlayers(vecPotentialPos, vecMins, vecMaxs, npc.index))
							continue;
						
						// Avoid placing buildings way too close to other buildings
						int other = INVALID_ENT_REFERENCE;
						int nothing;
						while ((other = FindEntityByNPC(nothing)) != INVALID_ENT_REFERENCE)
						{
							if (IsValidEntity(other))
							{
								if (!i_NpcIsABuilding[other])
									continue;
								
								float vecOtherPos[3];
								GetAbsOrigin(other, vecOtherPos);
								if (GetVectorDistance(vecPotentialPos, vecOtherPos, true) <= 8000.0)
									break;
							}
						}
						
						if (other != INVALID_ENT_REFERENCE)
							continue;
						
						// Congratulations little fella, you got a place to go
						npc.ToggleBuilding(true);
						npc.m_iTarget = 0;
						success = true;
						f3_NpcSavePos[npc.index] = vecPotentialPos;
						npc.StartPathing();
						npc.SetGoalVector(vecPotentialPos);
						break;
					}
					
					if (!success)
					{
						// Epic fail, try again in a little bit
						npc.m_iState = APT_BUILDER_STATE_IDLE;
						npc.m_flNextBuildingTime = gameTime + 1.5;
					}
				
					return;
				}
				
				npc.SetGoalVector(f3_NpcSavePos[npc.index]);
				if (GetVectorDistance(f3_NpcSavePos[npc.index], vecPos, true) < 400.0)
				{
					ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.6);
					npc.StopPathing();
					npc.m_iState = APT_BUILDER_STATE_BUILDING;
					npc.m_flNextBuildingTime = gameTime + 0.5;
					f3_NpcSavePos[npc.index] = vecPos;
				}
				
				return;
			}
		}
		
		case APT_BUILDER_STATE_BUILDING:
		{
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			
			if (npc.m_flNextBuildingTime < gameTime)
			{
				if (GetVectorDistance(f3_NpcSavePos[npc.index], vecPos, true) > 600.0)
				{
					// What the hell, this isn't where we want to build...
					npc.ToggleBuilding(false);
					npc.m_iState = APT_BUILDER_STATE_IDLE;
					npc.m_flNextBuildingTime = gameTime + 1.5;
				}
				else
				{
					int building;
					float vecAng[3];
					GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecAng);
					vecAng[2] = 0.0;
					
					// TODO: We never let the engineer know it's okay to re-build stuff once a building is destroyed
					// We have a priority order: Sentry, Teleporter, Dispenser
					if (!(npc.m_iBuildingsOwned & APT_BUILDER_HAS_SENTRY))
					{
						npc.PlayBuildingSentrySound();
						npc.m_iBuildingsOwned |= APT_BUILDER_HAS_SENTRY;
						building = NPC_CreateByName("npc_aperture_sentry", -1, vecPos, vecAng, GetTeam(npc.index));
					}
					else if (!(npc.m_iBuildingsOwned & APT_BUILDER_HAS_TELEPORTER))
					{
						npc.PlayBuildingTeleporterSound();
						npc.m_iBuildingsOwned |= APT_BUILDER_HAS_TELEPORTER;
						building = NPC_CreateByName("npc_aperture_teleporter", -1, vecPos, vecAng, GetTeam(npc.index));
					}
					else if (!(npc.m_iBuildingsOwned & APT_BUILDER_HAS_DISPENSER))
					{
						npc.PlayBuildingDispenserSound();
						npc.m_iBuildingsOwned |= APT_BUILDER_HAS_DISPENSER;
						building = NPC_CreateByName("npc_aperture_dispenser", -1, vecPos, vecAng, GetTeam(npc.index));
					}
					else
					{
						// we have everything?????????? how
						npc.ToggleBuilding(false);
						npc.m_iState = APT_BUILDER_STATE_IDLE;
						npc.m_flNextBuildingTime = gameTime + 1.5;
						return;
					}
					
					if (b_StaticNPC[building])
						AddNpcToAliveList(building, 1);
					
					if (GetTeam(iNPC) != TFTeam_Red)
					{
						if (!b_StaticNPC[building])
							NpcAddedToZombiesLeftCurrently(building, true);
					}
					
					npc.PlayBuildingBuiltSound(building);
					
					if (npc.m_iBuildingsOwned == APT_BUILDER_HAS_ALL_BUILDINGS)
						npc.m_bQuickBuildings = false;
					
					npc.ToggleBuilding(false);
					npc.m_iState = APT_BUILDER_STATE_IDLE;
					npc.m_flNextBuildingTime = npc.m_bQuickBuildings ? gameTime : gameTime + 10.0;
					npc.StartPathing();
				}
			}
		}
		
		case APT_BUILDER_STATE_WANTS_TO_REPAIR:
		{
			// TODO: THIS
		}
		
		case APT_BUILDER_STATE_REPAIRING:
		{
			// TODO: THIS
		}
	}
	
	// If he's doing important stuff, ignore other goals
	if (npc.m_iState != APT_BUILDER_STATE_IDLE)
		return;
	
	if (npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ApertureBuilderSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action ApertureBuilder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ApertureBuilder_NPCDeath(int entity)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void ApertureBuilderSelfDefense(ApertureBuilder npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 25.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 1.5;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}