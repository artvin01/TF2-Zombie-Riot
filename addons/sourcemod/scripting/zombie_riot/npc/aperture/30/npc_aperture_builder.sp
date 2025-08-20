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
	"vo/taunts/engineer_taunts06.mp3",
	"vo/engineer_meleedare01.mp3",
	"vo/engineer_meleedare02.mp3",
	"vo/engineer_meleedare03.mp3",
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

static const char g_OutOfMyWaySound[] = "vo/engineer_sentrymoving02.mp3";

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
	APT_BUILDER_STATE_ANGRY,
	APT_BUILDER_STATE_RETURNING_TO_NEST,
}

enum
{
	APT_BUILDER_NONE = -1,
	APT_BUILDER_SENTRY,
	APT_BUILDER_DISPENSER,
	APT_BUILDER_TELEPORTER,
	
	APT_BUILDER_BUILDING_COUNT,
}
static float AntiSoundSpam;
static int i_BuildingRefs[MAXENTITIES][APT_BUILDER_BUILDING_COUNT];

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
	AntiSoundSpam = 0.0;
	
	PrecacheSound(g_BuildingBuiltSound);
	PrecacheSound(g_OutOfMyWaySound);
	
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


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return ApertureBuilder(vecPos, vecAng, ally, data);
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
	
	public void PlayOutOfMyWaySound()
	{
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_OutOfMyWaySound, this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(6.0, 12.0);
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
	
	property int m_iBuildingsPlaced
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextBuildingStateTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	property float m_flNextHangOutTime
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	property bool m_bQuickBuildings
	{
		public get()							{ return b_Anger[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Anger[this.index] = TempValueForProperty; }
	}
	
	property bool m_bCurrentlyReturning
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	
	public ApertureBuilder(float vecPos[3], float vecAng[3], int ally, const char[] data)
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
		
		//IDLE
		npc.m_iState = APT_BUILDER_STATE_IDLE;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StopPathing(); // Don't path straight away, so we don't fall off an edge right after spawning
		npc.m_flSpeed = 300.0;
		
		// We just spawned, our mission is to build our shit asap
		npc.m_bQuickBuildings = true;
		npc.m_flNextBuildingStateTime = GetGameTime() + 0.75;
		npc.m_iBuildingsPlaced = 0;
		
		npc.m_bCurrentlyReturning = false;
		npc.m_flNextHangOutTime = 0.0;

		i_BuildingRefs[npc.index][APT_BUILDER_SENTRY] = INVALID_ENT_REFERENCE;
		i_BuildingRefs[npc.index][APT_BUILDER_DISPENSER] = INVALID_ENT_REFERENCE;
		i_BuildingRefs[npc.index][APT_BUILDER_TELEPORTER] = INVALID_ENT_REFERENCE;
		
		Is_a_Medic[npc.index] = true;
		b_StaticNPC[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/engineer/hardhat.mdl");
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		KillFeed_SetKillIcon(npc.index, "wrench");
		
		ApertureBuilder_ToggleBuilding(npc, false);
		
		if (StrContains(data, "noteleport") == -1)
		{
			// Attempt to spawn the builder out of most players' sights. We'll give a few tries while loosening the requirement each time
			// If we can't find an appropriate spot, just ignore LOS
			const int maxAttempts = 12;
			const float loosenedReqPerAttempt = 0.06;
			int livingPlayerCount = CountPlayersOnRed(2); // 2 = excludes teutons and downed players
			
			for (int i = 0; i <= maxAttempts; i++)
			{
				TeleportDiversioToRandLocation(npc.index, true, 3000.0, 1500.0);
				
				if (i == maxAttempts)
					break;
				
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
			
			float vecNewPos[3];
			GetAbsOrigin(npc.index, vecNewPos);
			ParticleEffectAt(vecNewPos, "teleported_blue");
			TE_Particle("teleported_mvm_bot", vecNewPos, _, _, npc.index, 1, 0);
		}
		
		if(AntiSoundSpam < GetGameTime())
		{
			EmitSoundToAll("music/mvm_class_select.wav", _, _, _, _, 0.5);	
			EmitSoundToAll("music/mvm_class_select.wav", _, _, _, _, 1.0);
		}
		AntiSoundSpam = GetGameTime() + 15.0;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "voice_player", 1, "%s", "Engineers Appear");
			}
		}
		
		return npc;
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
	
	PrintToChatAll("state %d", npc.m_iState);
	switch (npc.m_iState)
	{
		case APT_BUILDER_STATE_IDLE:
		{
			npc.m_iTarget = 0;
			
			if (npc.m_flNextBuildingStateTime < gameTime)
			{
				if (ApertureBuilder_GetWhatToBuild(npc) != APT_BUILDER_NONE)
				{
					npc.m_flNextHangOutTime = gameTime;
					f3_NpcSavePos[npc.index] = { 0.0, 0.0, 0.0 };
					npc.m_iState = APT_BUILDER_STATE_WANTS_TO_BUILD;
					
					return;
				}
			}
			
			// Let players kite builders away from nests, but it'll work a little differently
			if (npc.m_flGetClosestTargetTime < gameTime)
			{
				int target = GetClosestTarget(npc.index, .fldistancelimit = 400.0, .onlyPlayers = true);
				if (IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();	
					npc.m_iState = APT_BUILDER_STATE_ANGRY;
					npc.m_flSpeed = 300.0;
					npc.StartPathing();
					return;
				}
			}
			
			float vecPos[3];
			
			if (npc.m_flNextHangOutTime <= gameTime)
			{
				// Hang out around our nest
				npc.m_flSpeed = 80.0;
				
				int building = EntRefToEntIndex(ApertureBuilder_GetRandomBuilding(npc, true));
				if (building > MaxClients)
				{
					GetAbsOrigin(building, vecPos);
					f3_NpcSavePos[npc.index] = vecPos;
					npc.StartPathing();
				}
				else
				{
					f3_NpcSavePos[npc.index] = { 0.0, 0.0, 0.0 };
				}
				
				npc.m_flNextHangOutTime = gameTime + 1.5;
			}
			
			if (GetVectorLength(f3_NpcSavePos[npc.index], true))
			{
				GetAbsOrigin(npc.index, vecPos);
				if (GetVectorDistance(f3_NpcSavePos[npc.index], vecPos, true) < 4000.0)
				{
					npc.StopPathing();
					f3_NpcSavePos[npc.index] = { 0.0, 0.0, 0.0 };
				}
				else
				{
					npc.SetGoalVector(f3_NpcSavePos[npc.index]);
				}
			}
		}
		
		case APT_BUILDER_STATE_WANTS_TO_BUILD:
		{
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			
			if (npc.m_flNextBuildingStateTime < gameTime)
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
						
						// The teleporter might spawn giants!
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
						
						// Ensure the center of the nav mesh is accessible as well, so we can walk on it later
						float vecCenterPos[3];
						area.GetCenter(vecCenterPos);
						
						vecPotentialPos[2] += 1.0;
						vecMins = { -24.0, -24.0, 0.0 };
						vecMaxs = { 24.0, 24.0, 82.0 };
						
						if (IsBoxHazard(vecCenterPos, vecMins, vecMaxs))
							continue;
						
						if (IsSpaceOccupiedIgnorePlayers(vecCenterPos, vecMins, vecMaxs, npc.index))
							continue;
						
						// Congratulations little fella, you got a place to go
						ApertureBuilder_ToggleBuilding(npc, true);
						npc.m_iTarget = 0;
						npc.m_flSpeed = 300.0;
						success = true;
						f3_NpcSavePos[npc.index] = vecPotentialPos;
						npc.StartPathing();
						npc.SetGoalVector(vecPotentialPos);
						break;
					}
					
					if (!success)
					{
						// Epic fail, try again in a little bit. To not lobotomize ourselves, let's be angry at anyone so we move for a little bit
						npc.m_flSpeed = 300.0;
						npc.StartPathing();
						npc.m_iTarget = GetClosestTarget(npc.index);
						npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();	
						npc.m_iState = APT_BUILDER_STATE_ANGRY;
						npc.m_flNextBuildingStateTime = gameTime + 1.5;
					}
				
					return;
				}
				
				npc.SetGoalVector(f3_NpcSavePos[npc.index]);
				if (GetVectorDistance(f3_NpcSavePos[npc.index], vecPos, true) < 450.0)
				{
					ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.6);
					npc.StopPathing();
					npc.m_iState = APT_BUILDER_STATE_BUILDING;
					npc.m_flNextBuildingStateTime = gameTime + 0.5;
					f3_NpcSavePos[npc.index] = vecPos;
				}
				
				return;
			}
		}
		
		case APT_BUILDER_STATE_BUILDING:
		{
			float vecPos[3];
			GetAbsOrigin(npc.index, vecPos);
			
			if (npc.m_flNextBuildingStateTime < gameTime)
			{
				if (GetVectorDistance(f3_NpcSavePos[npc.index], vecPos, true) > 600.0)
				{
					// What the hell, this isn't where we want to build...
					ApertureBuilder_ToggleBuilding(npc, false);
					npc.m_iState = APT_BUILDER_STATE_IDLE;
					npc.m_flNextBuildingStateTime = gameTime + 1.5;
				}
				else
				{
					int building;
					float vecAng[3];
					GetEntPropVector(npc.index, Prop_Send, "m_angRotation", vecAng);
					vecAng[0] = 0.0;
					
					int needToBuild = ApertureBuilder_GetWhatToBuild(npc);
					switch (needToBuild)
					{
						case APT_BUILDER_SENTRY:
						{
							npc.PlayBuildingSentrySound();
							building = NPC_CreateByName("npc_aperture_sentry", -1, vecPos, vecAng, GetTeam(npc.index));
							ApertureSentry npcOther = view_as<ApertureSentry>(building);
							npcOther.Anger = npc.m_bQuickBuildings;
						}
						
						case APT_BUILDER_DISPENSER:
						{
							npc.PlayBuildingDispenserSound();
							building = NPC_CreateByName("npc_aperture_dispenser", -1, vecPos, vecAng, GetTeam(npc.index));
							ApertureDispenser npcOther = view_as<ApertureDispenser>(building);
							npcOther.Anger = npc.m_bQuickBuildings;
						}
						
						case APT_BUILDER_TELEPORTER:
						{
							npc.PlayBuildingTeleporterSound();
							building = NPC_CreateByName("npc_aperture_teleporter", -1, vecPos, vecAng, GetTeam(npc.index));
							ApertureTeleporter npcOther = view_as<ApertureTeleporter>(building);
							npcOther.Anger = npc.m_bQuickBuildings;
						}
						
						default:
						{
							// we have everything?????????? how
							ApertureBuilder_ToggleBuilding(npc, false);
							npc.m_iState = APT_BUILDER_STATE_IDLE;
							npc.m_flNextBuildingStateTime = gameTime + 1.5;
							return;
						}
					}
					
					NpcStats_CopyStats(npc.index, building);
					b_StaticNPC[building] = b_StaticNPC[npc.index];
					
					if (b_StaticNPC[building])
						AddNpcToAliveList(building, 1);
					
					if (GetTeam(iNPC) != TFTeam_Red)
					{
						if (!b_StaticNPC[building])
							NpcAddedToZombiesLeftCurrently(building, true);
					}
					
					i_BuildingRefs[npc.index][needToBuild] = EntIndexToEntRef(building);
					
					if (++npc.m_iBuildingsPlaced == 3)
						npc.m_bQuickBuildings = false;
					
					npc.PlayBuildingBuiltSound(building);
					
					ApertureBuilder_ToggleBuilding(npc, false);
					npc.m_iState = APT_BUILDER_STATE_IDLE;
					npc.m_flNextBuildingStateTime = npc.m_bQuickBuildings ? gameTime : gameTime + 20.0;
					npc.StartPathing();
				}
			}
		}
		
		case APT_BUILDER_STATE_ANGRY:
		{
			if (npc.m_flGetClosestTargetTime < gameTime)
			{
				npc.m_iTarget = GetClosestTarget(npc.index, .fldistancelimit = 400.0, .onlyPlayers = true);
				npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();	
			}
			
			if (IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			
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
				
				ApertureBuilderSelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget); 
				
				if (i_NpcIsABuilding[npc.m_iTarget])
				{
					// You want me to attack a building? bruhhhhhhhhh I BUILD SHIT I know better... my sentry will do that instead
					npc.m_bCurrentlyReturning = false;
					npc.m_iState = APT_BUILDER_STATE_RETURNING_TO_NEST;
				}
			}
			else
			{
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_bCurrentlyReturning = false;
				npc.m_iState = APT_BUILDER_STATE_RETURNING_TO_NEST;
			}
			
			npc.PlayIdleAlertSound();
		}
		
		case APT_BUILDER_STATE_RETURNING_TO_NEST:
		{
			if (!npc.m_bCurrentlyReturning)
			{
				npc.m_flNextIdleSound = 0.0;
				npc.m_flSpeed = 300.0;
				npc.StartPathing();
				npc.m_bCurrentlyReturning = true;
			}
			
			// Continue targetting enemies in this state, but don't move towards them
			if (npc.m_flGetClosestTargetTime < gameTime)
			{
				npc.m_iTarget = GetClosestTarget(npc.index, .fldistancelimit = 200.0);
				npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();	
			}
			
			if (IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float distance = ApertureBuilder_GetEntityDistance(npc.index, npc.m_iTarget, true);
				ApertureBuilderSelfDefense(npc, gameTime, npc.m_iTarget, distance); 
			}
			else
			{
				npc.m_flGetClosestTargetTime = 0.0;
			}
			
			int building = EntRefToEntIndex(ApertureBuilder_GetAnyBuilding(npc));
			if (building > MaxClients)
			{
				npc.m_iTargetAlly = building;
				npc.SetGoalEntity(npc.m_iTargetAlly);
				
				float distance = ApertureBuilder_GetEntityDistance(npc.index, building, true);
				if (distance < 10000.0)
				{
					// We reached our nest, can go back to idling
					npc.m_flNextBuildingStateTime = fmax(npc.m_flNextBuildingStateTime, gameTime + 1.0);
					npc.m_bCurrentlyReturning = false;
					npc.m_iState = APT_BUILDER_STATE_IDLE;
				}
			}
			else
			{
				// We don't have a nest! Go back to idling and decide what to do from there
				npc.m_flNextBuildingStateTime = fmax(npc.m_flNextBuildingStateTime, gameTime + 1.0);
				npc.m_bCurrentlyReturning = false;
				npc.m_iState = APT_BUILDER_STATE_IDLE;
			}
		}
	}
}

public Action ApertureBuilder_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ApertureBuilder npc = view_as<ApertureBuilder>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(attacker <= MaxClients)
	{
		//counters too hard, no fun.
		if(TeutonType[attacker] != TEUTON_NONE)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
		if(dieingstate[attacker] != 0)
		{
			damage *= 0.25;
			return Plugin_Changed;
		}
	}	
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
					
					if (npc.m_bCurrentlyReturning)
					{
						// get out of my FUCKING way
						if (ShouldNpcDealBonusDamage(target))
						{
							damageDealt *= 35.0;
						}
						else
						{
							Custom_Knockback(npc.index, target, 1250.0);
							
							if (target > 0 && target <= MaxClients)
							{
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
						
						npc.PlayOutOfMyWaySound();
					}

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

static float ApertureBuilder_GetEntityDistance(int entity, int other, bool squared = true)
{
	float vecPos1[3], vecPos2[3];
	WorldSpaceCenter(entity, vecPos1);
	WorldSpaceCenter(other, vecPos2);
	
	return GetVectorDistance(vecPos1, vecPos2, squared);
}

static int ApertureBuilder_GetWhatToBuild(ApertureBuilder npc)
{
	// We have a priority order for building: Sentry, Teleporter, Dispenser
	if (!IsValidEntity(i_BuildingRefs[npc.index][APT_BUILDER_SENTRY]))
		return APT_BUILDER_SENTRY;
	
	if (!IsValidEntity(i_BuildingRefs[npc.index][APT_BUILDER_TELEPORTER]))
		return APT_BUILDER_TELEPORTER;
	
	if (!IsValidEntity(i_BuildingRefs[npc.index][APT_BUILDER_DISPENSER]))
		return APT_BUILDER_DISPENSER;
	
	return APT_BUILDER_NONE;
}

static int ApertureBuilder_GetAnyBuilding(ApertureBuilder npc)
{
	// We don't care about which, just go for one!!!!
	for (int i = 0; i < APT_BUILDER_BUILDING_COUNT; i++)
	{
		int ref = i_BuildingRefs[npc.index][i];
		if (IsValidEntity(ref) && IsValidAlly(npc.index, EntRefToEntIndex(ref)))
			return ref;	
	}
	
	return INVALID_ENT_REFERENCE;
}

static int ApertureBuilder_GetRandomBuilding(ApertureBuilder npc, bool excludeClosest)
{
	// We DO care about which, pick wisely
	int building = INVALID_ENT_REFERENCE;
	ArrayList buildingList = new ArrayList();
	
	int closestIndex;
	int index;
	float closestDist = -1.0;
	
	for (int i = 0; i < APT_BUILDER_BUILDING_COUNT; i++)
	{
		int ref = i_BuildingRefs[npc.index][i];
		if (IsValidEntity(ref) && IsValidAlly(npc.index, EntRefToEntIndex(ref)))
		{
			buildingList.Push(ref);
			
			if (excludeClosest)
			{
				float distance = ApertureBuilder_GetEntityDistance(npc.index, ref, true);
				if (closestDist <= 0.0 || distance < closestDist)
				{
					closestIndex = index++;
					closestDist = distance;
				}
			}
		}
	}
	
	int length = buildingList.Length;
	if (length > 0)
	{
		if (excludeClosest && length != 1)
		{
			buildingList.Erase(closestIndex);
			length--;
		}
		
		building = buildingList.Get(GetURandomInt() % length);
	}
	
	delete buildingList;
	
	return building;
}

static void ApertureBuilder_ToggleBuilding(ApertureBuilder npc, bool toggle)
{
	// This is just used to swap building weapons
	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	int activity;
	if (toggle)
	{
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_toolbox/c_toolbox.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		activity = npc.LookupActivity("ACT_MP_RUN_BUILDING_DEPLOYED");
	}
	else
	{
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_wrench/c_wrench.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		activity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	}
	
	if (activity > 0)
		npc.StartActivity(activity);
}