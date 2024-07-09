#pragma semicolon 1
#pragma newdecls required

#if defined ZR || defined NOG
// Stuff that's used only for ZR but npc_stats
// needs so it can't go into the zr_core.sp
enum
{
	TEUTON_NONE,
	TEUTON_DEAD,
	TEUTON_WAITING
}

/*
	
	NAV_MESH_AVOID : Cant build here, for stuff like villages
	NAV_MESH_WALK : Walk, do not avoid obstacles
*/

int dieingstate[MAXTF2PLAYERS];
int TeutonType[MAXTF2PLAYERS];
bool EscapeModeForNpc;
bool b_NpcHasBeenAddedToZombiesLeft[MAXENTITIES];
int Zombies_Currently_Still_Ongoing;
int RaidBossActive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?
float Medival_Difficulty_Level = 0.0;
bool b_ThisNpcIsSawrunner[MAXENTITIES];
bool b_ThisNpcIsImmuneToNuke[MAXENTITIES];
int i_NpcOverrideAttacker[MAXENTITIES];
bool b_thisNpcHasAnOutline[MAXENTITIES];
int Shared_BEAM_Glow;
#endif
int i_KillsMade[MAXTF2PLAYERS];
int i_Backstabs[MAXTF2PLAYERS];
int i_Headshots[MAXTF2PLAYERS];	

#if !defined RTS
int TeamFreeForAll = 50;
#endif

int i_TeamGlow[MAXENTITIES]={-1, ...};
int Shared_BEAM_Laser;
char c_NpcName[MAXENTITIES][255];
bool b_NameNoTranslation[MAXENTITIES];
int i_SpeechBubbleEntity[MAXENTITIES];
PathFollower g_NpcPathFollower[ZR_MAX_NPCS];
static int g_modelArrow;

float f3_AvoidOverrideMin[MAXENTITIES][3];
float f3_AvoidOverrideMax[MAXENTITIES][3];
float f3_AvoidOverrideMinNorm[MAXENTITIES][3];
float f3_AvoidOverrideMaxNorm[MAXENTITIES][3];
float f_AvoidObstacleNavTime[MAXENTITIES];
float f_LayerSpeedFrozeRestore[MAXENTITIES];
bool b_AvoidObstacleType[MAXENTITIES];
float b_AvoidObstacleType_Time[MAXENTITIES];
int i_FailedTriesUnstuck[MAXENTITIES][2];
bool b_should_explode[MAXENTITIES];
bool b_rocket_particle_from_blue_npc[MAXENTITIES];
static int g_rocket_particle;
int i_rocket_particle[MAXENTITIES];
float fl_rocket_particle_dmg[MAXENTITIES];
float fl_rocket_particle_radius[MAXENTITIES];
static float f_DelayComputingOfPath[MAXENTITIES];
static float f_PredictPos[MAXENTITIES][3];
static float f_PredictDuration[MAXENTITIES];
static float f_UnstuckSuckMonitor[MAXENTITIES];
int i_TargetToWalkTo[MAXENTITIES];
float f_TargetToWalkToDelay[MAXENTITIES];

static int i_WasPathingToHere[MAXENTITIES];
static float f3_WasPathingToHere[MAXENTITIES][3];
Function func_NPCDeath[MAXENTITIES];
Function func_NPCDeathForward[MAXENTITIES];
Function func_NPCOnTakeDamage[MAXENTITIES];
Function func_NPCOnTakeDamagePost[MAXENTITIES];
Function func_NPCThink[MAXENTITIES];
Function func_NPCFuncWin[MAXENTITIES];
Function func_NPCAnimEvent[MAXENTITIES];
Function func_NPCActorEmoted[MAXENTITIES];
Function func_NPCInteract[MAXENTITIES];

#define PARTICLE_ROCKET_MODEL	"models/weapons/w_models/w_drg_ball.mdl" //This will accept particles and also hide itself.

#define NPC_DEFAULT_YAWRATE 225.0

#define TELEPORT_STUCK_CHECK_1 5.0
#define TELEPORT_STUCK_CHECK_2 18.0
#define TELEPORT_STUCK_CHECK_3 35.0

static int g_sModelIndexBloodDrop;
static int g_sModelIndexBloodSpray;
static float f_TimeSinceLastStunHit[MAXENTITIES];
//static bool b_EntityInCrouchSpot[MAXENTITIES];
//static bool b_NpcResizedForCrouch[MAXENTITIES];

int i_EntitiesHitAoeSwing_NpcSwing[MAXENTITIES]= {-1, ...};	//Who got hit
int i_EntitiesHitAtOnceMax_NpcSwing; //How many do we stack

public Action Command_RemoveAll(int client, int args)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(IsValidEntity(entity))
		{
			b_DissapearOnDeath[entity] = true;
			b_DoGibThisNpc[entity] = true;
			SmiteNpcToDeath(entity);
		}
	}
	return Plugin_Handled;
}

public Action Command_PetMenu(int client, int args)
{
	//What are you.
	if(!(client > 0 && client <= MaxClients && IsClientInGame(client)))
		return Plugin_Handled;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spawn_npc <plugin> [health] [data] [team] [damage multi] [speed multi] [ranged armour] [melee armour] [Extra Size]");
		return Plugin_Handled;
	}
	
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	
	//1==index, 2==health, 3==data, 4==ally, 5==rpg lvl 
	char plugin[64], buffer[64];
	GetCmdArg(1, plugin, sizeof(plugin));
	GetCmdArg(3, buffer, sizeof(buffer));

#if defined RTS
	int team = GetTeam(client);
#elseif defined ZR
	int team = TFTeam_Blue;
#else
	int team = 4;
#endif
	if(args > 3)	//data
		team = view_as<bool>(GetCmdArgInt(4));
	
#if defined RTS
	int entity = NPC_CreateByName(plugin, team, flPos, flAng, buffer);
#else
	int entity = NPC_CreateByName(plugin, client, flPos, flAng, team, buffer);
#endif

	if(IsValidEntity(entity))
	{

#if defined ZR
		if(GetTeam(entity) != view_as<int>(TFTeam_Red))
		{
			NpcAddedToZombiesLeftCurrently(entity, true);
		}
#endif
		
		if(args > 1)
		{
			int health = GetCmdArgInt(2);
			SetEntProp(entity, Prop_Data, "m_iHealth", health);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
		}
		
		if(args > 4)
			fl_Extra_Damage[entity] = GetCmdArgFloat(5);
		
		if(args > 5)
			fl_Extra_Speed[entity] = GetCmdArgFloat(6);
		
		if(args > 6)
			fl_Extra_RangedArmor[entity] = GetCmdArgFloat(7);
		
		if(args > 7)
			fl_Extra_MeleeArmor[entity] = GetCmdArgFloat(8);

		if(args > 8)
		{
			float scale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale * GetCmdArgFloat(9));
		}
	}

	return Plugin_Handled;
}


void OnMapStart_NPC_Base()
{
	for (int i = 0; i < (sizeof(g_GibSound));   i++) { PrecacheSound(g_GibSound[i]);   }
	for (int i = 0; i < (sizeof(g_GibSoundMetal));   i++) { PrecacheSound(g_GibSoundMetal[i]);   }
	for (int i = 0; i < (sizeof(g_CombineSoldierStepSound));   i++) { PrecacheSound(g_CombineSoldierStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_DefaultStepSound));   i++) { PrecacheSound(g_DefaultStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_CombineMetroStepSound));   i++) { PrecacheSound(g_CombineMetroStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundSuccess));	   i++) { PrecacheSound(g_ArrowHitSoundSuccess[i]);	   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundMiss));	   i++) { PrecacheSound(g_ArrowHitSoundMiss[i]);	   }
	for (int i = 0; i < (sizeof(g_PanzerStepSound));   i++) { PrecacheSound(g_PanzerStepSound[i]);   }
#if defined ZR
	for (int i = 0; i < (sizeof(g_TankStepSound));   i++) { PrecacheSoundCustom(g_TankStepSound[i]);   }
#endif
	for (int i = 0; i < (sizeof(g_RobotStepSound));   i++) { PrecacheSound(g_RobotStepSound[i]);   }
	
	g_sModelIndexBloodDrop = PrecacheModel("sprites/bloodspray.vmt");
	g_sModelIndexBloodSpray = PrecacheModel("sprites/blood.vmt");
	
	PrecacheDecal("sprites/blood.vmt", true);
	PrecacheDecal("sprites/bloodspray.vmt", true);
	
	g_particleImpactMetal = PrecacheParticleSystem("bot_impact_light");
	g_particleImpactFlesh = PrecacheParticleSystem("blood_impact_red_01");
	g_particleImpactRubber = PrecacheParticleSystem("halloween_explosion_bits");
	g_modelArrow = PrecacheModel("models/weapons/w_models/w_arrow.mdl");
	g_rocket_particle = PrecacheModel(PARTICLE_ROCKET_MODEL);
	Shared_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
#if defined ZR
	Shared_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
#endif

	PrecacheModel(ARROW_TRAIL);
	PrecacheDecal(ARROW_TRAIL, true);
	PrecacheModel(ARROW_TRAIL_RED);
	PrecacheDecal(ARROW_TRAIL_RED, true);

	HookEntityOutput("trigger_multiple", "OnStartTouch", NPCStats_StartTouch);
	HookEntityOutput("trigger_multiple", "OnEndTouch", NPCStats_EndTouch);

	Zero(f_TimeSinceLastStunHit);
//	Zero(b_EntityInCrouchSpot);
//	Zero(b_NpcResizedForCrouch);
	Zero(b_PlayerIsInAnotherPart);
	Zero(b_EntityIsStairAbusing);
	Zero(f_PredictDuration);
	Zero(flNpcCreationTime);
	Zero2(f_PredictPos);
	
	PrecacheEffect("ParticleEffect");
	PrecacheEffect("ParticleEffectStop");
	PrecacheParticleEffect("burningplayer_red");

	for (int NpcIndexNumber = 0; NpcIndexNumber < ZR_MAX_NPCS; NpcIndexNumber++)
	{
		g_NpcPathFollower[NpcIndexNumber] = PathFollower(PathCost, Path_FilterIgnoreActors, Path_FilterOnlyActors);
	}
}

void NpcStats_OnMapEnd()
{
	for (int NpcIndexNumber = 0; NpcIndexNumber < ZR_MAX_NPCS; NpcIndexNumber++)
	{
		if(g_NpcPathFollower[NpcIndexNumber].IsValid())
		{
			g_NpcPathFollower[NpcIndexNumber].Destroy();
		}
	}
}

Handle DHookCreateEx(Handle gc, const char[] key, HookType hooktype, ReturnType returntype, ThisPointerType thistype, DHookCallback callback)
{
	int iOffset = GameConfGetOffset(gc, key);
	if(iOffset == -1)
	{
		SetFailState("Failed to get offset of %s", key);
		return null;
	}
	
	return DHookCreate(iOffset, hooktype, returntype, thistype, callback);
}

public Action NPCStats_StartTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller < MAXENTITIES)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
		{
/*
			if(StrEqual(name, "npc_crouch_simulation"))
			{
				b_EntityInCrouchSpot[caller] = true;
			}
*/
			if(StrEqual(name, "zr_spawner_scaler"))
			{
				b_PlayerIsInAnotherPart[caller] = true;
			}
			if(StrEqual(name, "zr_anti_stair_abuse"))
			{
				b_EntityIsStairAbusing[caller] = true;
			}
		}
	}
	return Plugin_Continue;
}


public Action NPCStats_EndTouch(const char[] output, int entity, int caller, float delay)
{
	if(caller > 0 && caller < MAXENTITIES)
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)))
		{
/*
			if(StrEqual(name, "npc_crouch_simulation"))
			{
				b_EntityInCrouchSpot[caller] = false;
			}
*/
			if(StrEqual(name, "zr_spawner_scaler"))
			{
				b_PlayerIsInAnotherPart[caller] = false;
			}
			if(StrEqual(name, "zr_anti_stair_abuse"))
			{
				b_EntityIsStairAbusing[caller] = false;
			}
		}
	}
	return Plugin_Continue;
}


methodmap CClotBody < CBaseCombatCharacter
{
#if defined RTS
	public CClotBody(const float vecPos[3], const float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
#else
	public CClotBody(const float vecPos[3], const float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						int Ally = false,
						bool Ally_Invince = false,
						bool isGiant = false,
						bool IgnoreBuildings = false,
						bool IsRaidBoss = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0},
						bool Ally_Collideeachother = false)
#endif
	{

		int npc = CreateEntityByName("zr_base_npc");
		CBaseNPC baseNPC = view_as<CClotBody>(npc).GetBaseNPC();

		DispatchKeyValueVector(npc, "origin",	 vecPos);
		DispatchKeyValueVector(npc, "angles",	 vecAng);
		DispatchKeyValue(npc, "model",	 model);
		view_as<CBaseCombatCharacter>(npc).SetModel(model);
		DispatchKeyValue(npc,	   "modelscale", modelscale);
		DispatchKeyValue(npc,	   "health",	 health);

#if defined ZR
		if(Ally == TFTeam_Red)
		{
			if(Ally_Invince)
			{
				b_ThisEntityIgnored[npc] = true;
			}
			SetTeam(npc, TFTeam_Red);
		}
		else
		{
			if(Ally == 999)
			{
				//setting it to 999 will just keep adding 1 so its a free for all!
				SetTeam(npc, TeamFreeForAll++);
			}
			else
			{
				SetTeam(npc, Ally);
			}
		}
		b_NpcIgnoresbuildings[npc] = IgnoreBuildings;
#elseif !defined RTS
		if(Ally == 999)
		{
			//setting it to 999 will just keep adding 1 so its a free for all!
			SetTeam(npc, TeamFreeForAll++);
		}
		else
		{
			SetTeam(npc, Ally);	
		}
		if(Ally_Invince)
		{
			b_ThisEntityIgnored[npc] = true;
		}
		b_NpcIgnoresbuildings[npc] = IgnoreBuildings;
#endif
		AddEntityToLagCompList(npc);

		b_NpcHasDied[npc] = false;
		i_FailedTriesUnstuck[npc][0] = 0;
		i_FailedTriesUnstuck[npc][1] = 0;
		flNpcCreationTime[npc] = GetGameTime();
		DispatchSpawn(npc); //Do this at the end :)
		Hook_DHook_UpdateTransmitState(npc);
		SDKHook(npc, SDKHook_TraceAttack, NPC_TraceAttack);
		SDKHook(npc, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
		SDKHook(npc, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	
		SetEntProp(npc, Prop_Send, "m_bGlowEnabled", false);
		SetEntityMoveType(npc, MOVETYPE_CUSTOM);

		CClotBody npcstats = view_as<CClotBody>(npc);

	
		//FIX: This fixes lookup activity not working.
		npcstats.StartActivity(0);
		npcstats.SetSequence(0);
		npcstats.SetPlaybackRate(1.0);
		npcstats.SetCycle(0.0);
		npcstats.ResetSequenceInfo();
		//FIX: This fixes lookup activity not working.

#if defined RPG
		SetEntPropFloat(npc, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(npc, Prop_Send, "m_fadeMaxDist", 2000.0);
#endif

		baseNPC.flStepSize = 17.0;
		baseNPC.flGravity = 800.0; //SEE Npc Base Think Function to change it.
		baseNPC.flAcceleration = 6000.0;
		baseNPC.flJumpHeight = 250.0;
		//baseNPC.flRunSpeed = 300.0; //SEE Update Logic.
		baseNPC.flFrictionSideways = 5.0;
		baseNPC.flMaxYawRate = NPC_DEFAULT_YAWRATE;
		baseNPC.flDeathDropHeight = 999999.0;

#if defined ZR
		if(Ally != TFTeam_Red && VIPBuilding_Active())
		{
			baseNPC.flAcceleration = 90000.0;
			baseNPC.flFrictionSideways = 90.0;
		}
#endif

		CBaseNPC_Locomotion locomotion = baseNPC.GetLocomotion();

		SetEntProp(npc, Prop_Data, "m_bSequenceLoops", true);
		//potentially newly added ? or might not get set ?
		//Just set it to true at all times.

#if defined ZR || defined RPG
		if(Ally == TFTeam_Red)
			SetEntityCollisionGroup(npc, 24);

		if(Ally != TFTeam_Red)
		{
			AddNpcToAliveList(npc, 0);
		}
#else
		AddNpcToAliveList(npc, 0);
#endif
			
		locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollide_NpcLoco);
		locomotion.SetCallback(LocomotionCallback_IsEntityTraversable, IsEntityTraversable);
		view_as<CBaseAnimating>(npc).Hook_HandleAnimEvent(CBaseAnimating_HandleAnimEvent);
		
		h_NpcSolidHookType[npc] = DHookRaw(g_hGetSolidMask, true, view_as<Address>(baseNPC.GetBody()));

		SetEntityFlags(npc, FL_NPC);
		
		SetEntProp(npc, Prop_Data, "m_nSolidType", 2); 

		//Don't bleed.
		SetEntProp(npc, Prop_Data, "m_bloodColor", -1); //Don't bleed
		
		b_BoundingBoxVariant[npc] = 0; //This will tell lag compensation what to revert to once the calculations are done.
		static float m_vecMaxs[3];
		static float m_vecMins[3];
		if(isGiant)
		{
			b_IsGiant[npc] = true;
			b_BoundingBoxVariant[npc] = 1;
			m_vecMaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			m_vecMins = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}			
		else
		{
			m_vecMaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
			m_vecMins = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}

		if(CustomThreeDimensions[1] != 0.0)
		{
			f3_CustomMinMaxBoundingBox[npc][0] = CustomThreeDimensions[0];
			f3_CustomMinMaxBoundingBox[npc][1] = CustomThreeDimensions[1];
			f3_CustomMinMaxBoundingBox[npc][2] = CustomThreeDimensions[2];

			m_vecMaxs[0] = f3_CustomMinMaxBoundingBox[npc][0];
			m_vecMaxs[1] = f3_CustomMinMaxBoundingBox[npc][1];
			m_vecMaxs[2] = f3_CustomMinMaxBoundingBox[npc][2];

			m_vecMins[0] = -f3_CustomMinMaxBoundingBox[npc][0];
			m_vecMins[1] = -f3_CustomMinMaxBoundingBox[npc][1];
			m_vecMins[2] = 0.0;
		}
		//Fix collisions
		
		static float m_vecMaxs_Body[3];
		static float m_vecMins_Body[3];

		m_vecMaxs_Body[0] = m_vecMaxs[0] * 2.0;
		m_vecMaxs_Body[1] = m_vecMaxs[1] * 2.0;
		m_vecMaxs_Body[2] = m_vecMaxs[2] * 1.15;
		//we dont want to fake super tall.

		m_vecMins_Body[0] = m_vecMins[0] * 2.0;
		m_vecMins_Body[1] = m_vecMins[1] * 2.0;
		m_vecMins_Body[2] = m_vecMins[2] * 1.15;

		f3_AvoidOverrideMin[npc] = m_vecMins_Body;
		f3_AvoidOverrideMax[npc] = m_vecMaxs_Body;
		f3_AvoidOverrideMinNorm[npc] = m_vecMins;
		f3_AvoidOverrideMaxNorm[npc] = m_vecMaxs;
		baseNPC.SetBodyMaxs(m_vecMaxs);
		baseNPC.SetBodyMins(m_vecMins);
		SetEntPropVector(npc, Prop_Data, "m_vecMaxs", m_vecMaxs);
		SetEntPropVector(npc, Prop_Data, "m_vecMins", m_vecMins);
		
		//Fixed wierd clientside issue or something
		static float m_vecMaxsNothing[3];
		static float m_vecMinsNothing[3];
		m_vecMaxsNothing = view_as<float>( { 1.0, 1.0, 2.0 } );
		m_vecMinsNothing = view_as<float>( { -1.0, -1.0, 0.0 } );		
		SetEntPropVector(npc, Prop_Send, "m_vecMaxsPreScaled", m_vecMaxsNothing);
		SetEntPropVector(npc, Prop_Data, "m_vecMaxsPreScaled", m_vecMaxsNothing);
		SetEntPropVector(npc, Prop_Send, "m_vecMinsPreScaled", m_vecMinsNothing);
		SetEntPropVector(npc, Prop_Data, "m_vecMinsPreScaled", m_vecMinsNothing);


#if defined ZR
		if(Ally == TFTeam_Red && !Ally_Collideeachother)
		{
			npcstats.m_iTeamGlow = TF2_CreateGlow(npc);
			
			SetVariantColor(view_as<int>({184, 56, 59, 200}));
			AcceptEntityInput(npcstats.m_iTeamGlow, "SetGlowColor");
		}
#endif

		SDKHook(npc, SDKHook_Think, NpcBaseThink);
		SDKHook(npc, SDKHook_ThinkPost, NpcBaseThinkPost);
//		SDKHook(npc, SDKHook_SetTransmit, SDKHook_Settransmit_Baseboss);
		
		b_ThisWasAnNpc[npc] = true;

#if defined ZR
		if(IsRaidBoss)
		{
			RemoveAllDamageAddition();
		}
#endif
	
		return view_as<CClotBody>(npc);
	}
		property int index 
	{ 
		public get() { return view_as<int>(this); } 
	}
	public void PlayGibSound() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSound) - 1);
	
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayGibSoundMetal() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSoundMetal) - 1);
	
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayStepSound(const char[] sound, float volume = 1.0, int Npc_Type = 1, bool custom = false)
	{
		if(!custom)
		{
			switch(Npc_Type)
			{
				case STEPSOUND_NORMAL: //normal
				{
					EmitSoundToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 100, _);
				}
				case STEPSOUND_GIANT: //giant
				{
					EmitSoundToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 80, _);
				}
				
			}
		}
		else
		{
			switch(Npc_Type)
			{
				case STEPSOUND_NORMAL: //normal
				{
					EmitCustomToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 100, _);
				}
				case STEPSOUND_GIANT: //giant
				{
					EmitCustomToAll(sound, this.index, SNDCHAN_AUTO, 80, _, volume, 80, _);
				}
			}			
		}
	//	PrintToServer("%i PlayStepSound(\"%s\")", this.index, sound);
	}
	
	property int m_iOverlordComboAttack
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iTargetAlly
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_TargetAlly[this.index]);
#if defined ZR
			if(returnint == -1)
			{
				return 0;
			}
#endif
			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_TargetAlly[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TargetAlly[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property bool m_bGetClosestTargetTimeAlly
	{
		public get()							{ return b_GetClosestTargetTimeAlly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_GetClosestTargetTimeAlly[this.index] = TempValueForProperty; }
	}
	property bool m_bWasSadAlready
	{
		public get()							{ return b_WasSadAlready[this.index]; }
		public set(bool TempValueForProperty) 	{ b_WasSadAlready[this.index] = TempValueForProperty; }
	}
	property int m_iChanged_WalkCycle
	{
		public get()							{ return i_Changed_WalkCycle[this.index]; }
		public set(int TempValueForProperty) 	{ i_Changed_WalkCycle[this.index] = TempValueForProperty; }
	}
	property float m_flDuration
	{
		public get()							{ return fl_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Duration[this.index] = TempValueForProperty; }
	}
	property float m_flExtraDamage
	{
		public get()							{ return fl_Extra_Damage[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Extra_Damage[this.index] = TempValueForProperty; }
	}
	property float m_flHurtie
	{
		public get()							{ return fl_Hurtie[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Hurtie[this.index] = TempValueForProperty; }
	}
	property float m_flheal_cooldown
	{
		public get()							{ return fl_heal_cooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_heal_cooldown[this.index] = TempValueForProperty; }
	}
	property float m_flidle_talk
	{
		public get()							{ return fl_idle_talk[this.index]; }
		public set(float TempValueForProperty) 	{ fl_idle_talk[this.index] = TempValueForProperty; }
	}
	property float m_flDoingSpecial
	{
		public get()							{ return fl_DoingSpecial[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoingSpecial[this.index] = TempValueForProperty; }
	}
	property float m_flComeToMe
	{
		public get()							{ return fl_ComeToMe[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ComeToMe[this.index] = TempValueForProperty; }
	}
	property int m_iMedkitAnnoyance
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	property bool m_b_stand_still
	{
		public get()							{ return b_stand_still[this.index]; }
		public set(bool TempValueForProperty) 	{ b_stand_still[this.index] = TempValueForProperty; }
	}
	
	
	property bool m_b_follow
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_walk
	{
		public get()							{ return b_movedelay_walk[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_walk[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_run
	{
		public get()							{ return b_movedelay_run[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_run[this.index] = TempValueForProperty; }
	}
	property bool m_bIsFriendly
	{
		public get()							{ return b_IsFriendly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsFriendly[this.index] = TempValueForProperty; }
	}
	property bool m_bReloaded
	{
		public get()							{ return b_Reloaded[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Reloaded[this.index] = TempValueForProperty; }
	}
	
	property float m_flFollowing_Master_Now
	{
		public get()							{ return fl_Following_Master_Now[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Following_Master_Now[this.index] = TempValueForProperty; }
	}
	property float m_flHookDamageTaken
	{
		public get()							{ return fl_HookDamageTaken[this.index]; }
		public set(float TempValueForProperty) 	{ fl_HookDamageTaken[this.index] = TempValueForProperty; }
	}
	property float m_flGrappleCooldown
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	property float m_flStandStill
	{
		public get()							{ return fl_StandStill[this.index]; }
		public set(float TempValueForProperty) 	{ fl_StandStill[this.index] = TempValueForProperty; }
	}
	property float m_flNextFlameSound
	{
		public get()							{ return fl_NextFlameSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextFlameSound[this.index] = TempValueForProperty; }
	}
	property float m_flFlamerActive
	{
		public get()							{ return fl_FlamerActive[this.index]; }
		public set(float TempValueForProperty) 	{ fl_FlamerActive[this.index] = TempValueForProperty; }
	}
	property float m_flWaveScale
	{
		public get()							{ return fl_WaveScale[this.index]; }
		public set(float TempValueForProperty) 	{ fl_WaveScale[this.index] = TempValueForProperty; }
	}
	
	property bool m_bDoSpawnGesture
	{
		public get()							{ return b_DoSpawnGesture[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DoSpawnGesture[this.index] = TempValueForProperty; }
	}
	property bool m_bLostHalfHealth
	{
		public get()							{ return b_LostHalfHealth[this.index]; }
		public set(bool TempValueForProperty) 	{ b_LostHalfHealth[this.index] = TempValueForProperty; }
	}
	property bool m_bLostHalfHealthAnim
	{
		public get()							{ return b_LostHalfHealthAnim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_LostHalfHealthAnim[this.index] = TempValueForProperty; }
	}
	property bool m_bDuringHighFlight
	{
		public get()							{ return b_DuringHighFlight[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DuringHighFlight[this.index] = TempValueForProperty; }
	}
	property bool m_bDuringHook
	{
		public get()							{ return b_DuringHook[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DuringHook[this.index] = TempValueForProperty; }
	}
	property bool m_bGrabbedSomeone
	{
		public get()							{ return b_GrabbedSomeone[this.index]; }
		public set(bool TempValueForProperty) 	{ b_GrabbedSomeone[this.index] = TempValueForProperty; }
	}
	property bool m_bUseDefaultAnim
	{
		public get()							{ return b_UseDefaultAnim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_UseDefaultAnim[this.index] = TempValueForProperty; }
	}
	property bool m_bFlamerToggled
	{
		public get()							{ return b_FlamerToggled[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FlamerToggled[this.index] = TempValueForProperty; }
	}
	property bool m_bCamo
	{
		public get()							{ return b_IsCamoNPC[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsCamoNPC[this.index] = TempValueForProperty; }
	}
	property bool m_bNoKillFeed
	{
		public get()							{ return b_NoKillFeed[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NoKillFeed[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay_gun
	{
		public get()							{ return b_movedelay_gun[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay_gun[this.index] = TempValueForProperty; }
	}
	property bool m_flHalf_Life_Regen
	{
		public get()							{ return b_Half_Life_Regen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Half_Life_Regen[this.index] = TempValueForProperty; }
	}
	property float m_flDead_Ringer_Invis
	{
		public get()							{ return fl_Dead_Ringer_Invis[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer_Invis[this.index] = TempValueForProperty; }
	}
	property float m_flDead_Ringer
	{
		public get()							{ return fl_Dead_Ringer[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Dead_Ringer[this.index] = TempValueForProperty; }
	}
	property bool m_flDead_Ringer_Invis_bool
	{
		public get()							{ return b_Dead_Ringer_Invis_bool[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Dead_Ringer_Invis_bool[this.index] = TempValueForProperty; }
	}
	property int m_iAttacksTillMegahit
	{
		public get()							{ return i_AttacksTillMegahit[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillMegahit[this.index] = TempValueForProperty; }
	}
	property float m_flCharge_Duration
	{
		public get()							{ return fl_Charge_Duration[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_Duration[this.index] = TempValueForProperty; }
	}
	property float m_flCharge_delay
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
	}
	property int g_TimesSummoned
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens_2
	{
		public get()							{ return fl_AttackHappens_2[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappens_2[this.index] = TempValueForProperty; }
	}
	property bool m_bFUCKYOU
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	property bool m_bFUCKYOU_move_anim
	{
		public get()							{ return b_FUCKYOU_move_anim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU_move_anim[this.index] = TempValueForProperty; }
	}
	property bool Healing
	{
		public get()							{ return b_healing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_healing[this.index] = TempValueForProperty; }
	}
	property bool m_bnew_target
	{
		public get()							{ return b_new_target[this.index]; }
		public set(bool TempValueForProperty) 	{ b_new_target[this.index] = TempValueForProperty; }
	}
	property float m_flReloadIn
	{
		public get()							{ return fl_ReloadIn[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ReloadIn[this.index] = TempValueForProperty; }
	}
	property float m_flAngerDelay
	{
		public get()							{ return fl_AngerDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AngerDelay[this.index] = TempValueForProperty; }
	}
	property float m_flmovedelay
	{
		public get()							{ return fl_movedelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_movedelay[this.index] = TempValueForProperty; }
	}
	property float m_flNextChargeSpecialAttack
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedSpecialAttack
	{
		public get()							{ return fl_NextRangedSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedSpecialAttack[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextRangedSpecialAttackHappens
	{
		public get()							{ return fl_NextRangedSpecialAttackHappens[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedSpecialAttackHappens[this.index] = TempValueForProperty; }
	}
	property float m_flRangedSpecialDelay
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property bool m_fbRangedSpecialOn
	{
		public get()							{ return b_RangedSpecialOn[this.index]; }
		public set(bool TempValueForProperty) 	{ b_RangedSpecialOn[this.index] = TempValueForProperty; }
	}
	property float m_flNextIdleSound
	{
		public get()							{ return fl_NextIdleSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextIdleSound[this.index] = TempValueForProperty; }
	}
	property float m_flInJump
	{
		public get()							{ return fl_InJump[this.index]; }
		public set(float TempValueForProperty) 	{ fl_InJump[this.index] = TempValueForProperty; }
	}
	property bool m_bDissapearOnDeath
	{
		public get()							{ return b_DissapearOnDeath[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DissapearOnDeath[this.index] = TempValueForProperty; }
	}

	property bool m_bIsGiant
	{
		public get()							{ return b_IsGiant[this.index]; }
		public set(bool TempValueForProperty) 	{ b_IsGiant[this.index] = TempValueForProperty; }
	}
	property bool Anger
	{
		public get()							{ return b_Anger[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Anger[this.index] = TempValueForProperty; }
	}
	property bool m_bPathing
	{
		public get()							{ return b_Pathing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Pathing[this.index] = TempValueForProperty; }
	}

	property bool m_bThisEntityIgnored
	{
		public get()							{ return b_ThisEntityIgnored[this.index]; }
		public set(bool TempValueForProperty) 	{ b_ThisEntityIgnored[this.index] = TempValueForProperty; }
	}
	
	property bool m_bJumping
	{
		public get()							{ return b_Pathing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Pathing[this.index] = TempValueForProperty; }
	}
	property float m_flDoingAnimation
	{
		public get()							{ return fl_DoingAnimation[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoingAnimation[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedBarrage_Spam
	{
		public get()							{ return fl_NextRangedBarrage_Spam[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Spam[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedBarrage_Singular
	{
		public get()							{ return fl_NextRangedBarrage_Singular[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedBarrage_Singular[this.index] = TempValueForProperty; }
	}
	property bool m_bNextRangedBarrage_OnGoing
	{
		public get()							{ return b_NextRangedBarrage_OnGoing[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NextRangedBarrage_OnGoing[this.index] = TempValueForProperty; }
	}

	property float m_flJumpStartTimeInternal
	{
		public get()							{ return fl_JumpStartTimeInternal[this.index]; }
		public set(float TempValueForProperty) 	{ fl_JumpStartTimeInternal[this.index] = TempValueForProperty; }
	}

	property float m_flJumpStartTime
	{
		public get()							{ return fl_JumpStartTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_JumpStartTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextTeleport
	{
		public get()							{ return fl_NextTeleport[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextTeleport[this.index] = TempValueForProperty; }
	}
	property float m_flJumpCooldown
	{
		public get()							{ return fl_JumpCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_JumpCooldown[this.index] = TempValueForProperty; }
	}
	
	property float m_flNextThinkTime
	{
		public get()							{ return fl_NextThinkTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextThinkTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextRunTime
	{
		public get()							{ return fl_NextRunTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRunTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextDelayTime
	{
		public get()							{ return fl_NextDelayTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextDelayTime[this.index] = TempValueForProperty; }
	}

	property float m_flNextMeleeAttack
	{
		public get()							{ return fl_NextMeleeAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextMeleeAttack[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens
	{
		public get()							{ return fl_AttackHappensMinimum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMinimum[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens_bullshit
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property bool m_flAttackHappenswillhappen
	{
		public get()							{ return b_AttackHappenswillhappen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AttackHappenswillhappen[this.index] = TempValueForProperty; }
	}
	
	
	property float m_flMeleeArmor
	{
		public get()							{ return fl_MeleeArmor[this.index]; }
		public set(float TempValueForProperty) 	{ fl_MeleeArmor[this.index] = TempValueForProperty; }
	}
	property float m_flRangedArmor
	{
		public get()				{ return fl_RangedArmor[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedArmor[this.index] = TempValueForProperty; }
	}
	property bool m_bScalesWithWaves
	{
		public get()							{ return b_ScalesWithWaves[this.index]; }
		public set(bool TempValueForProperty) 	{ b_ScalesWithWaves[this.index] = TempValueForProperty; }	
	
	}
	property float m_flSpeed
	{
		public get()							{ return fl_Speed[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Speed[this.index] = TempValueForProperty; }
	}
	property int m_iTargetWalkTo
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_TargetToWalkTo[this.index]);
#if defined ZR
			if(returnint == -1)
			{
				return 0;
			}
#endif
			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_TargetToWalkTo[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TargetToWalkTo[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTarget
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_Target[this.index]);
#if defined ZR
			if(returnint == -1)
			{
				return 0;
			}
#endif
			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_Target[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Target[this.index] = EntIndexToEntRef(iInt);
#if defined RPG
				if(iInt <= MaxClients && iInt > 0)
					RPGCore_ClientTargetedByNpc(iInt, 8.0);
#endif
			}
		}
	}
	property int m_iBleedType
	{
		public get()							{ return i_BleedType[this.index]; }
		public set(int TempValueForProperty) 	{ i_BleedType[this.index] = TempValueForProperty; }
	}
	property int m_iState
	{
		public get()							{ return i_State[this.index]; }
		public set(int TempValueForProperty) 	{ i_State[this.index] = TempValueForProperty; }
	}
	property bool m_bmovedelay
	{
		public get()							{ return b_movedelay[this.index]; }
		public set(bool TempValueForProperty) 	{ b_movedelay[this.index] = TempValueForProperty; }
	}
	property int m_iStepNoiseType
	{
		public get()							{ return i_StepNoiseType[this.index]; }
		public set(int TempValueForProperty) 	{ i_StepNoiseType[this.index] = TempValueForProperty; }
	}
	property int m_iNpcStepVariation
	{
		public get()							{ return i_NpcStepVariation[this.index]; }
		public set(int TempValueForProperty) 	{ i_NpcStepVariation[this.index] = TempValueForProperty; }
	}
	property float m_fCreditsOnKill
	{
		public get()							{ return f_CreditsOnKill[this.index]; }
		public set(float TempValueForProperty) 	{ f_CreditsOnKill[this.index] = TempValueForProperty; }
	}
	property float m_flGetClosestTargetTime
	{
		public get()							{ return fl_GetClosestTargetTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GetClosestTargetTime[this.index] = TempValueForProperty; }
	}
	property float m_flGetClosestTargetNoResetTime
	{
		public get()							{ return fl_GetClosestTargetNoResetTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GetClosestTargetNoResetTime[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedAttack
	{
		public get()							{ return fl_NextRangedAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttack[this.index] = TempValueForProperty; }
	}
	property float m_flNextRangedAttackHappening
	{
		public get()							{ return fl_NextRangedAttackHappening[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextRangedAttackHappening[this.index] = TempValueForProperty; }
	}
	property int m_iAttacksTillReload
	{
		public get()							{ return i_AttacksTillReload[this.index]; }
		public set(int TempValueForProperty) 	{ i_AttacksTillReload[this.index] = TempValueForProperty; }
	}
	property float m_flNextHurtSound
	{
		public get()							{ return fl_NextHurtSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextHurtSound[this.index] = TempValueForProperty; }
	}
	property float m_flHeadshotCooldown
	{
		public get()							{ return fl_HeadshotCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_HeadshotCooldown[this.index] = TempValueForProperty; }
	}
	property bool m_blPlayHurtAnimation
	{
		public get()							{ return b_PlayHurtAnimation[this.index]; }
		public set(bool TempValueForProperty) 	{ b_PlayHurtAnimation[this.index] = TempValueForProperty; }
	}
	property bool m_fbGunout
	{
		public get()							{ return b_Gunout[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Gunout[this.index] = TempValueForProperty; }
	}
	property bool bCantCollidie
	{
		public get()							{ return b_CantCollidie[this.index]; }
		public set(bool TempValueForProperty) 	{ b_CantCollidie[this.index] = TempValueForProperty; }
	}
	property bool bCantCollidieAlly
	{
		public get()							{ return b_CantCollidieAlly[this.index]; }
		public set(bool TempValueForProperty) 	{ b_CantCollidieAlly[this.index] = TempValueForProperty; }
	}
	property bool bBuildingIsPlaced
	{
		public get()							{ return b_bBuildingIsPlaced[this.index]; }
		public set(bool TempValueForProperty) 	{ b_bBuildingIsPlaced[this.index] = TempValueForProperty; }
	}
	property bool bXenoInfectedSpecialHurt
	{
		public get()							{ return b_XenoInfectedSpecialHurt[this.index]; }
		public set(bool TempValueForProperty) 	{ b_XenoInfectedSpecialHurt[this.index] = TempValueForProperty; }
	}
	property float flXenoInfectedSpecialHurtTime
	{
		public get()							{ return fl_XenoInfectedSpecialHurtTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_XenoInfectedSpecialHurtTime[this.index] = TempValueForProperty; }
	}
	property bool m_bThisNpcIsABoss
	{
		public get()							{ return b_thisNpcIsABoss[this.index]; }
		public set(bool TempValueForProperty) 	{ b_thisNpcIsABoss[this.index] = TempValueForProperty; }
	}
	property bool m_bStaticNPC
	{
		public get()							{ return b_StaticNPC[this.index]; }
		public set(bool TempValueForProperty) 	{ b_StaticNPC[this.index] = TempValueForProperty; }
	}
	
	property bool m_bThisNpcGotDefaultStats_INVERTED //This is the only one, reasoning is that is that i kinda need to check globablly if any base_boss spawned outside of this plugin and apply stuff accordingly.
	{
		public get()							{ return b_ThisWasAnNpc[this.index]; }
		public set(bool TempValueForProperty) 	{ b_ThisWasAnNpc[this.index] = TempValueForProperty; }
	}
	property bool m_bInSafeZone
	{
		public get()							{ return view_as<bool>(i_InSafeZone[this.index]); }
	}
	property float m_fHighTeslarDebuff 
	{
		public get()							{ return f_HighTeslarDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_HighTeslarDebuff[this.index] = TempValueForProperty; }
	}
	property float m_fLowTeslarDebuff 
	{
		public get()							{ return f_LowTeslarDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_LowTeslarDebuff[this.index] = TempValueForProperty; }
	}
	
	property float mf_WidowsWineDebuff 
	{
		public get()							{ return f_WidowsWineDebuff[this.index]; }
		public set(float TempValueForProperty) 	{ f_WidowsWineDebuff[this.index] = TempValueForProperty; }
	}
	
	property bool m_bFrozen
	{
		public get()				{ return b_Frozen[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Frozen[this.index] = TempValueForProperty; }
	}
	
	property bool m_bAllowBackWalking
	{
		public get()				{ return b_AllowBackWalking[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AllowBackWalking[this.index] = TempValueForProperty; }
	}
	public float GetDebuffPercentage()//For the future incase we want to alter it easier
	{
		float speed_for_return = 1.0;
		float Gametime = GetGameTime();
		float GametimeNpc = GetGameTime(this.index);
		speed_for_return *= fl_Extra_Speed[this.index];
		
#if defined RTS
		speed_for_return *= RTS_GameSpeed();
#endif

		bool Is_Boss = true;
#if defined ZR
		if(IS_MusicReleasingRadio() && GetTeam(this.index) != TFTeam_Red)
			speed_for_return *= 0.9;

		if(i_CurrentEquippedPerk[this.index] == 4)
		{
			speed_for_return *= 1.25;
		}
#endif
		if(b_npcspawnprotection[this.index])
		{
			speed_for_return *= 1.35;
		}
		if(!this.m_bThisNpcIsABoss)
		{
			if(!b_thisNpcIsARaid[this.index])
			{
				Is_Boss = false;
			}
		}
		
		if(f_TankGrabbedStandStill[this.index] > Gametime)
		{
			speed_for_return = 0.0;
			return speed_for_return;
		}
		if(f_TimeFrozenStill[this.index] > GametimeNpc)
		{
			speed_for_return = 0.0;
			return speed_for_return;
		}
		if (this.m_bFrozen && !b_CannotBeSlowed[this.index])
		{
			speed_for_return = 0.0;
			return speed_for_return;
		}	
		if(f_PernellBuff[this.index] > Gametime)
		{
			speed_for_return *= 1.25;
		}
		if(f_HussarBuff[this.index] > Gametime)
		{
			speed_for_return *= 1.20;
		}
		if(f_GodAlaxiosBuff[this.index] > Gametime)
		{
			speed_for_return *= 1.50;
		}
#if defined RUINA_BASE	
		if(f_Ruina_Speed_Buff[this.index] > Gametime)
		{
			speed_for_return *= f_Ruina_Speed_Buff_Amt[this.index];
		}
#endif

#if defined ZR
		SeabornVanguard_SpeedBuff(this, speed_for_return);	
#endif

		if(!Is_Boss && !b_CannotBeSlowed[this.index]) //Make sure that any slow debuffs dont affect these.
		{
			if(f_MaimDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.35;
			}
			if(f_PotionShrinkEffect[this.index] > Gametime)
			{
				speed_for_return *= 0.35;
			}
			if(f_PassangerDebuff[this.index] > Gametime)
			{
#if defined ZR
				speed_for_return *= 0.20;
#else
				speed_for_return *= 0.75;
#endif
			}
#if defined RPG
			switch(BubbleProcStatusLogicCheck(this.index))
			{
				case -1:
				{
					speed_for_return *= 1.15; 
				}
				case 1:
				{
					speed_for_return *= 0.85; 
				}
			}
#endif
			if(this.m_fHighTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.65;
			}
			else if(this.m_fLowTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.75;
			}

			if(f_SpecterDyingDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.4;
			}
			
			if(f_HighIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.85;
			}
			else if(f_LowIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.90;
			}
			else if (f_VeryLowIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.95;
			}
			else if (f_LudoDebuff[this.index] > Gametime)
			{
				speed_for_return *= GetRandomFloat(0.7, 0.9);
			}
			else if (f_SpadeLudoDebuff[this.index] > Gametime)
			{
				speed_for_return *= GetRandomFloat(0.7, 0.85);
			}
		}
		else if (!b_CannotBeSlowed[this.index])
		{
			if(this.m_fHighTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.9;
			}
			else if(this.m_fLowTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.95;
			}
			if(f_PassangerDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.9;
			}
			if(f_MaimDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.9;
			}
			if(f_PotionShrinkEffect[this.index] > Gametime)
			{
				speed_for_return *= 0.9;
			}
			
			if(f_HighIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.95;
			}
			else if(f_LowIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.96;
			}
			else if (f_VeryLowIceDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.97;
			}
			else if (f_LudoDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.96;
			}
			else if (f_SpadeLudoDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.94;
			}
			if(f_SpecterDyingDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.75;
			}
		}
		if(this.mf_WidowsWineDebuff > Gametime && !b_CannotBeSlowed[this.index])
		{
			float slowdown_amount = this.mf_WidowsWineDebuff - Gametime;
			
			float max_amount = FL_WIDOWS_WINE_DURATION;
			
			slowdown_amount = slowdown_amount / max_amount;
			
			slowdown_amount -= 1.0;
			
			slowdown_amount *= -1.0;
			
			if(!Is_Boss)
			{
				if(slowdown_amount < 0.1)
				{
					slowdown_amount = 0.1;
				}
				else if(slowdown_amount > 1.0)
				{
					slowdown_amount = 1.0;
				}	
			}
			else
			{
				if(slowdown_amount < 0.8)
				{
					slowdown_amount = 0.8;
				}
				else if(slowdown_amount > 1.0)
				{
					slowdown_amount = 1.0;
				}	
			}
			speed_for_return *= slowdown_amount;
		}		

		return speed_for_return;
	}
	public float GetRunSpeed()//For the future incase we want to alter it easier
	{
		float speed_for_return;
		
		speed_for_return = this.m_flSpeed;
		
		speed_for_return *= this.GetDebuffPercentage();

#if defined ZR
		if(!b_thisNpcIsARaid[this.index] && GetTeam(this.index) != TFTeam_Red && XenoExtraLogic(true))
		{
			speed_for_return *= 1.1;
		}

		if(GetTeam(this.index) != TFTeam_Red)
		{
			speed_for_return *= Zombie_DelayExtraSpeed();
		}
		else
		{
			if(VIPBuilding_Active())
				speed_for_return *= 2.0;
		}
#endif
		return speed_for_return; 
	}
	public void m_vecLastValidPos(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecTeleportBackSave[this.index][0] = pos[0];
			f3_VecTeleportBackSave[this.index][1] = pos[1];
			f3_VecTeleportBackSave[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecTeleportBackSave[this.index][0];
			pos[1] = f3_VecTeleportBackSave[this.index][1];
			pos[2] = f3_VecTeleportBackSave[this.index][2];
		}
	}
	
	public void m_vecLastValidPosJump(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecTeleportBackSaveJump[this.index][0] = pos[0];
			f3_VecTeleportBackSaveJump[this.index][1] = pos[1];
			f3_VecTeleportBackSaveJump[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecTeleportBackSaveJump[this.index][0];
			pos[1] = f3_VecTeleportBackSaveJump[this.index][1];
			pos[2] = f3_VecTeleportBackSaveJump[this.index][2];
		}
	}
	public void m_vecpunchforce(float pos[3], bool set)
	{
		if(set)
		{
			f3_VecPunchForce[this.index][0] = pos[0];
			f3_VecPunchForce[this.index][1] = pos[1];
			f3_VecPunchForce[this.index][2] = pos[2];
		}
		else
		{
			pos[0] = f3_VecPunchForce[this.index][0];
			pos[1] = f3_VecPunchForce[this.index][1];
			pos[2] = f3_VecPunchForce[this.index][2];
		}
	}
	property bool m_bGib
	{
		public get()							{ return b_DoGibThisNpc[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DoGibThisNpc[this.index] = TempValueForProperty; }
	}
	property bool g_bNPCVelocityCancel
	{
		public get()							{ return b_NPCVelocityCancel[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NPCVelocityCancel[this.index] = TempValueForProperty; }
	}
	property bool g_bNPCTeleportOutOfStuck
	{
		public get()							{ return b_NPCTeleportOutOfStuck[this.index]; }
		public set(bool TempValueForProperty) 	{ b_NPCTeleportOutOfStuck[this.index] = TempValueForProperty; }
	}
	property float m_flDoSpawnGesture
	{
		public get()							{ return fl_DoSpawnGesture[this.index]; }
		public set(float TempValueForProperty) 	{ fl_DoSpawnGesture[this.index] = TempValueForProperty; }
	}
	property float m_flReloadDelay
	{
		public get()							{ return fl_ReloadDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ReloadDelay[this.index] = TempValueForProperty; }
	}
	property bool m_bisWalking
	{
		public get()							{ return b_isWalking[this.index]; }
		public set(bool TempValueForProperty) 	{ b_isWalking[this.index] = TempValueForProperty; }
	}
	property bool m_bDoNotGiveWaveDelay
	{
		public get()							{ return b_DoNotGiveWaveDelay[this.index]; }
		public set(bool TempValueForProperty) 	{ b_DoNotGiveWaveDelay[this.index] = TempValueForProperty; }
	}
	property float m_bisGiantWalkCycle
	{
		public get()							{ return b_isGiantWalkCycle[this.index]; }
		public set(float TempValueForProperty) 	{ b_isGiantWalkCycle[this.index] = TempValueForProperty; }
	}
	
	property int m_iSpawnProtectionEntity
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_SpawnProtectionEntity[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_SpawnProtectionEntity[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_SpawnProtectionEntity[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTeamGlow
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TeamGlow[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TeamGlow[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TeamGlow[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property bool m_bTeamGlowDefault
	{
		public get()							{ return b_TeamGlowDefault[this.index]; }
		public set(bool TempValueForProperty) 	{ b_TeamGlowDefault[this.index] = TempValueForProperty; }
	}
	property int m_iTextEntity1
	{
		public get()		 
		{
			return EntRefToEntIndex(i_TextEntity[this.index][0]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TextEntity[this.index][0] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TextEntity[this.index][0] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTextEntity2
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][1]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TextEntity[this.index][1] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TextEntity[this.index][1] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTextEntity3
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][2]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TextEntity[this.index][2] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TextEntity[this.index][2] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTextEntity4
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][3]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TextEntity[this.index][3] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TextEntity[this.index][3] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iTextEntity5
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][4]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_TextEntity[this.index][4] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_TextEntity[this.index][4] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iSpeechBubble
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_SpeechBubbleEntity[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_SpeechBubbleEntity[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_SpeechBubbleEntity[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}

	property int m_iWearable1
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][0]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][0] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][0] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable2
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][1]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][1] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][1] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable3
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][2]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][2] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][2] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable4
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][3]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][3] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][3] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable5
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][4]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][4] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][4] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable6
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][5]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][5] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][5] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable7
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][6]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][6] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][6] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWearable8
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][7]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][7] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][7] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iFreezeWearable
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_FreezeWearable[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_FreezeWearable[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_FreezeWearable[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iInvulWearable
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_InvincibleParticle[this.index]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_InvincibleParticle[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_InvincibleParticle[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	
	public PathFollower GetPathFollower()
	{
		return view_as<PathFollower>(this.GetProp(Prop_Data, "zr_pPath"));
	}
	public INextBot GetBot()
	{
		return this.MyNextBotPointer();
	}
	public CBaseNPC GetBaseNPC()
	{
		return TheNPCs.FindNPCByEntIndex(this.index);
	}
	public ILocomotion GetLocomotion()
	{
		return this.MyNextBotPointer().GetLocomotionInterface();
	}
	public ILocomotion GetLocomotionInterface()
	{
		return this.MyNextBotPointer().GetLocomotionInterface();
	}
	public bool IsOnGround()
	{
		return this.GetLocomotionInterface().IsOnGround();
	}
	public void AddGesture(const char[] anim, bool cancel_animation = true, float duration = 1.0, bool autokill = true, float SetGestureSpeed = 1.0)
	{
		int activity = this.LookupActivity(anim);
		if(activity < 0)
			return;
		
		if(cancel_animation)
		{
			view_as<CBaseCombatCharacter>(this).RestartGesture(view_as<Activity>(activity), true, autokill);
		}
		else
		{
			view_as<CBaseCombatCharacter>(this).AddGesture(view_as<Activity>(activity), duration, autokill);
		}
		
		int layer = this.FindGestureLayer(view_as<Activity>(activity));
		if(layer != -1)
			this.SetLayerPlaybackRate(layer, SetGestureSpeed);
	}
	public void RemoveGesture(const char[] anim)
	{
		int activity = this.LookupActivity(anim);
		if(activity < 0)
			return;
		
		int layer = this.FindGestureLayer(view_as<Activity>(activity));
		if(layer != -1)
			this.FastRemoveLayer(layer);
	}
	public void AddActivityViaSequence(const char[] anim)
	{
		int iSequence = this.LookupSequence(anim);
		if(iSequence < 0)
			return;
		
		this.ResetSequence(iSequence);
		this.ResetSequenceInfo();
	//	this.SetSequence(iSequence);
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);
		this.ResetSequenceInfo();
		this.m_iState = iSequence;
	//	int layer = this.FindGestureLayerBySequence(iSequence);
	//	if(layer != -1)
	//	{
	//		CAnimationLayer alayer = this.GetAnimOverlay(layer);
	//		alayer.m_flPlaybackRate = 1.0;
	//		alayer.m_flCycle = 0.0;
	//	}
	
	}
	public void AddGestureViaSequence(const char[] anim, bool cancel_animation = true)
	{
		int iSequence = this.LookupSequence(anim);
		if(iSequence < 0)
			return;
		
		this.AddGestureSequence(iSequence);
	}
	public int FindAttachment(const char[] pAttachmentName)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hStudio_FindAttachment, pStudioHdr, pAttachmentName) + 1;
	}
	public void DispatchParticleEffect(int entity, const char[] strParticle, float flStartPos[3], float vecAngles[3], float flEndPos[3], 
									   int iAttachmentPointIndex = 0, ParticleAttachment_t iAttachType = PATTACH_CUSTOMORIGIN, bool bResetAllParticlesOnEntity = false, float colour[3] = {0.0,0.0,0.0})
	{
		int tblidx = FindStringTable("ParticleEffectNames");
		if (tblidx == INVALID_STRING_TABLE) 
		{
			LogError("Could not find string table: ParticleEffectNames");
			return;
		}
		char tmp[256];
		int count = GetStringTableNumStrings(tblidx);
		int stridx = INVALID_STRING_INDEX;
		for (int i = 0; i < count; i++)
		{
			ReadStringTable(tblidx, i, tmp, sizeof(tmp));
			if (StrEqual(tmp, strParticle, false))
			{
				stridx = i;
				break;
			}
		}
		if (stridx == INVALID_STRING_INDEX)
		{
			LogError("Could not find particle: %s", strParticle);
			return;
		}
	
		TE_Start("TFParticleEffect");
		TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
		TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
		TE_WriteFloat("m_vecOrigin[2]", flStartPos[2]);
		TE_WriteVector("m_vecAngles", vecAngles);
		TE_WriteNum("m_iParticleSystemIndex", stridx);
		TE_WriteNum("entindex", entity);
		TE_WriteNum("m_iAttachType", view_as<int>(iAttachType));
		TE_WriteNum("m_iAttachmentPointIndex", iAttachmentPointIndex);
		TE_WriteNum("m_bResetParticles", bResetAllParticlesOnEntity);	
		TE_WriteNum("m_bControlPoint1", 0);	
		TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 0);  
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
		TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
		TE_SendToAll();
	}
	public void SetActivity(const char[] animation, bool Is_sequence = false)
	{
		if(Is_sequence)
		{
			int sequence = this.LookupSequence(animation);
			if(sequence > 0 && sequence != this.m_iState)
			{
				this.m_iState = sequence;
				this.m_iActivity = 0;
				
				this.SetSequence(sequence);
				this.SetPlaybackRate(1.0);
				this.SetCycle(0.0);
				this.ResetSequenceInfo();
			}
		}
		else
		{
			int activity = this.LookupActivity(animation);
			if(activity > 0 && activity != this.m_iState)
			{
				this.m_iState = activity;
				this.StartActivity(activity);
			}
		}
	}
	public void StartPathing()
	{
		if(!CvarDisableThink.BoolValue)
		{
			this.m_bPathing = true;

			this.GetPathFollower().SetMinLookAheadDistance(100.0);
		}
	}
	public void StopPathing()
	{
#if defined RTS
		if(this.m_bPathing)
#endif
		{
			f_DelayComputingOfPath[this.index] = 0.0; //find new target instantly.
			this.GetPathFollower().Invalidate();
			this.GetLocomotion().Stop();

			this.m_bPathing = false;
		}
	}
	public void SetGoalEntity(int target, bool ignoretime = false)
	{
#if defined RTS
		if(IsObject(target) || i_IsABuilding[target] || b_IsVehicle[target])
#else
		if(i_IsABuilding[target] || b_IsVehicle[target])
#endif
		{
			//broken on targetting buildings...?
			float pos[3]; GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
			this.SetGoalVector(pos, false);
			return;
		}

		if(ignoretime || DelayPathing(this.index))
		{
			if(IsEntityTowerDefense(this.index))
			{
				if(this.m_bPathing && this.IsOnGround())
				{
					if(i_WasPathingToHere[this.index] == target)
					{
						return;
					}

					i_WasPathingToHere[this.index] = target;
				}
				else
				{
					i_WasPathingToHere[this.index] = 0;
				}
			}
			if(this.m_bPathing)
			{
				this.GetPathFollower().ComputeToTarget(this.GetBot(), target);
				float DistanceCheck[3];
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", DistanceCheck);
				AddDelayPather(this.index, DistanceCheck);
			}
		}
	}
	public void SetGoalVector(const float vec[3], bool ignoretime = false)
	{	
		if(ignoretime || DelayPathing(this.index))
		{
			if(IsEntityTowerDefense(this.index))
			{
				if(this.m_bPathing && this.IsOnGround())
				{
					if(f3_WasPathingToHere[this.index][0] == vec[0] && f3_WasPathingToHere[this.index][1] == vec[1] && f3_WasPathingToHere[this.index][2] == vec[2])
						return;

					f3_WasPathingToHere[this.index] = vec;
				}
				else
				{
					f3_WasPathingToHere[this.index][0] = 0.0;
					f3_WasPathingToHere[this.index][1] = 0.0;
					f3_WasPathingToHere[this.index][2] = 0.0;
				}
			}
			if(this.m_bPathing)
			{
				this.GetPathFollower().ComputeToPos(this.GetBot(), vec);
				AddDelayPather(this.index, vec);
			}
		}
	}
	public void FaceTowards(const float vecGoal[3], float turnrate = 250.0)
	{
		//Sad!
		float flPrevValue = this.GetBaseNPC().flMaxYawRate;
		
		this.GetBaseNPC().flMaxYawRate = turnrate;
		this.GetLocomotionInterface().FaceTowards(vecGoal);
		this.GetBaseNPC().flMaxYawRate = flPrevValue;
	}
	/*

		public void FaceTowards(const float vecGoal[3], float turnrate = 250.0)
	{
		//Sad!
		float flPrevValue = flTurnRate.FloatValue;
		
		flTurnRate.FloatValue = turnrate;
		SDKCall(g_hFaceTowards, this.GetLocomotionInterface(), vecGoal);
		flTurnRate.FloatValue = flPrevValue;
	}
	*/		
	public float GetMaxJumpHeight()	{ return this.GetLocomotionInterface().GetMaxJumpHeight(); }
	public float GetGroundSpeed()	{ return this.GetLocomotionInterface().GetGroundSpeed(); }
	public int SelectWeightedSequence(any activity) { return view_as<CBaseAnimating>(view_as<int>(this)).SelectWeightedSequence(activity); }
	
	public bool GetAttachment(const char[] szName, float absOrigin[3], float absAngles[3]) { return view_as<CBaseAnimating>(view_as<int>(this)).GetAttachment(view_as<CBaseAnimating>(view_as<int>(this)).LookupAttachment(szName), absOrigin, absAngles); }
	public void Approach(const float vecGoal[3])										   { this.GetLocomotionInterface().Approach(vecGoal, 0.1);						}
	public void Jump()																	 { this.GetLocomotionInterface().Jump();										  }
	public void GetVelocity(float vecOut[3])											   { this.GetLocomotionInterface().GetVelocity(vecOut);						   }	
	public void SetVelocity(const float vec[3])	
	{
		CBaseNPC baseNPC = view_as<CClotBody>(this.index).GetBaseNPC();
		CBaseNPC_Locomotion locomotion = baseNPC.GetLocomotion();
		locomotion.SetVelocity(vec);							  
	}	
	
	public void SetOrigin(const float vec[3])											
	{
		SetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin",vec);
	}	
	
	public void SetSequence(int iSequence)	{ SetEntProp(this.index, Prop_Send, "m_nSequence", iSequence); }
	public float GetPlaybackRate() { return GetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate"); }
	public void SetPlaybackRate(float flRate) { SetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate", flRate); }
	public void SetCycle(float flCycle)	   { SetEntPropFloat(this.index, Prop_Send, "m_flCycle", flCycle); }
	
	public void GetVectors(float pForward[3], float pRight[3], float pUp[3]) { view_as<CBaseEntity>(this).GetVectors(pForward, pRight, pUp); }
	
	public void GetGroundMotionVector(float vecMotion[3])					{ this.GetLocomotionInterface().GetGroundMotionVector(vecMotion); }
	public float GetLeadRadius()	{ return 90000.0/*this.GetPathFollower().GetLeadRadius()*/; }
	public void UpdateCollisionBox() { SDKCall(g_hUpdateCollisionBox,  this.index); }
	public void ResetSequenceInfo()  { SDKCall(g_hResetSequenceInfo,  this.index); }
	public void StudioFrameAdvance() { view_as<CBaseAnimating>(view_as<int>(this)).StudioFrameAdvance(); }
	public void DispatchAnimEvents() { view_as<CBaseAnimating>(view_as<int>(this)).DispatchAnimEvents(view_as<CBaseAnimating>(view_as<int>(this))); }
	
	public int EquipItem(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0)
	{
		int item = CreateEntityByName("prop_dynamic_override");
		if(!IsValidEntity(item))
		{
			PrintToServer("Failed!!! Retry!!!!");
			//warning, warning!!!
			//infinite loop this untill it works!
			//Tf2 has a very very very low chance to fail to spawn a prop, because reasons!
			return this.EquipItem(
			attachment,
			model,
			anim,
			skin,
			model_size);
		}
		DispatchKeyValue(item, "model", model);

		if(model_size == 1.0)
		{
			DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
		}
		else
		{
			DispatchKeyValueFloat(item, "modelscale", model_size);
		}

		DispatchSpawn(item);
		SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES);
		SetEntityMoveType(item, MOVETYPE_NONE);
		SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
	
		if(anim[0])
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}

#if defined RPG
		SetEntPropFloat(item, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(item, Prop_Send, "m_fadeMaxDist", 1800.0);
#endif

		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);

		if(attachment[0])
		{
			SetVariantString(attachment);
			AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 
		}	
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
		
		MakeObjectIntangeable(item);

		return item;
	}

	public int EquipItemSeperate(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0,
	float offset = 0.0,
	bool DontParent = false)
	{
		int item = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(item, "model", model);

		if(model_size == 1.0)
		{
			DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
		}
		else
		{
			DispatchKeyValueFloat(item, "modelscale", model_size);
		}

		DispatchSpawn(item);
		
		SetEntityMoveType(item, MOVETYPE_NONE);
		SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);

		float VecOrigin[3];
		GetAbsOrigin(this.index, VecOrigin);
		VecOrigin[2] += offset;

		TeleportEntity(item, VecOrigin, eyePitch, NULL_VECTOR);
		if(DontParent)
		{
			return item;
		}
		

		if(!StrEqual(anim, ""))
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}

#if defined RPG
		SetEntPropFloat(item, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(item, Prop_Send, "m_fadeMaxDist", 1800.0);
#endif

		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);
		MakeObjectIntangeable(item);
		return item;
	} 
	public bool DoSwingTrace(Handle &trace,
	int target,
	 float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 },
	  float vecSwingMins[3] = { -64.0, -64.0, -128.0 },
	   float vecSwingStartOffset = 55.0,
	    int Npc_type = 0,
		 int Ignore_Buildings = 0,
		  int countAoe = 0)
	{
		switch(Npc_type)
		{
			case 1: //giants
			{
				vecSwingMaxs = { 100.0, 100.0, 150.0 };
				vecSwingMins = { -100.0, -100.0, -150.0 };
			}
			case 2: //Ally Invinceable 
			{
				vecSwingMaxs = { 250.0, 250.0, 250.0 };
				vecSwingMins = { -250.0, -250.0, -250.0 };
			}
		}
		
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);
		
		float vecForward[3], vecRight[3], vecTarget[3];
		
		WorldSpaceCenter(target, vecTarget);
		if(target <= MaxClients)
			vecTarget[2] += 10.0; //abit extra as they will most likely always shoot upwards more then downwards

		WorldSpaceCenter(this.index, vecForward);
		MakeVectorFromPoints(vecForward, vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		vecForward[1] = eyePitch[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
		
		float vecSwingStart[3];
		GetAbsOrigin(this.index, vecSwingStart);
		
		vecSwingStart[2] += vecSwingStartOffset; //default is 55 for a few reasons.
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * vecSwingMaxs[0];
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * vecSwingMaxs[1];
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * vecSwingMaxs[2];
		
#if defined ZR
		bool ingore_buildings = false;
		if(Ignore_Buildings || (RaidbossIgnoreBuildingsLogic(2)))
		{
			ingore_buildings = true;
		}
#else
		bool ingore_buildings = view_as<bool>(Ignore_Buildings);
#endif
		// See if we hit anything.
		if(countAoe > 0)
		{
			Zero(i_EntitiesHitAoeSwing_NpcSwing);
			i_EntitiesHitAtOnceMax_NpcSwing = countAoe; //How many do we stack
			
			for(int repeat; repeat < 3; repeat ++)
			{
				vecSwingMins[repeat] *= 0.75;
				vecSwingMins[repeat] *= 0.75;
				vecSwingMaxs[repeat] *= 0.75;
				vecSwingMaxs[repeat] *= 0.75;
			}

			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd,vecSwingMins, vecSwingMaxs, 1073741824, ingore_buildings ? BulletAndMeleeTrace_MultiNpcPlayerAndBaseBossOnly : BulletAndMeleeTrace_MultiNpcTrace, this.index);
		}	
		else
		{
			trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
		}
		return (TR_GetFraction(trace) < 1.0);
	}
	public bool DoAimbotTrace(Handle &trace, int target, float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 }, float vecSwingMins[3] = { -64.0, -64.0, -128.0 }, float vecSwingStartOffset = 44.0)
	{
		float vecSwingStart[3];
		GetAbsOrigin(this.index, vecSwingStart);
		
		vecSwingStart[2] += vecSwingStartOffset;
		
		float vecSwingEnd[3];
		GetAbsOrigin(target, vecSwingEnd);
		
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, this.index );
		return (TR_GetFraction(trace) < 1.0);
	}
	public void GetPositionInfront(float DistanceOffsetInfront, float vecSwingEnd[3], float ang[3])
	{	
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);
		
		float vecSwingStart[3];
		float vecSwingForward[3];

		GetAbsOrigin(this.index, vecSwingStart);
		
		GetAngleVectors(ang, vecSwingForward, NULL_VECTOR, NULL_VECTOR);
		
		vecSwingEnd[0] = vecSwingStart[0] + vecSwingForward[0] * DistanceOffsetInfront;
		vecSwingEnd[1] = vecSwingStart[1] + vecSwingForward[1] * DistanceOffsetInfront;
		vecSwingEnd[2] = vecSwingStart[2] + vecSwingForward[2] * DistanceOffsetInfront;
	}
	public int SpawnShield(float duration, char[] model, float position_offset, bool parent = true)
	{

		float eyePitch[3];
		float absorigin[3];
		
		this.GetPositionInfront(position_offset, absorigin, eyePitch);
		int entity = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "targetname", "rpg_fortress");
			DispatchKeyValue(entity, "model", model);
			DispatchKeyValue(entity, "solid", "6");
			SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 1600.0);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 2400.0);	
			SetEntityCollisionGroup(entity, 24); //our savior
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);			
			DispatchSpawn(entity);
			TeleportEntity(entity, absorigin, eyePitch, NULL_VECTOR, true);
			SetEntProp(entity, Prop_Send, "m_fEffects", EF_PARENT_ANIMATES);
			SetEntityMoveType(entity, MOVETYPE_NONE);
			SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1.0);
			
			b_ThisEntityIgnored[entity] = true;
			b_ForceCollisionWithProjectile[entity] = true;
			i_WandOwner[entity] = this.index;

			SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 1600.0);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 1800.0);

			if(parent)
			{
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", this.index);
			}
		}
		if(duration > 0.0)
			CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			
		return entity;
	}
	public int FireRocket(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, int flags = 0, float offset = 0.0, int inflictor = INVALID_ENT_REFERENCE) //No defaults, otherwise i cant even judge.
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		//this.GetVectors(vecForward, vecSwingStart, vecAngles);

		GetAbsOrigin(this.index, vecSwingStart);
		vecSwingStart[2] += 54.0;

		vecSwingStart[2] += offset;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		float speed = rocket_speed;
#if defined ZR
		Rogue_Paradox_ProjectileSpeed(this.index, speed);
#endif
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-speed;

		int entity = CreateEntityByName("zr_projectile_base");
		if(IsValidEntity(entity))
		{
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			i_ExplosiveProjectileHexArray[entity] = flags;
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			SetTeam(entity, GetTeam(this.index));
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);

			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				int g_ProjectileModelRocket = PrecacheModel(rocket_model);
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
				}
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27
		}
		return entity;
	}
	public int FireParticleRocket(float vecTarget[3], float rocket_damage, float rocket_speed, float damage_radius , const char[] rocket_particle = "", bool do_aoe_dmg=false , bool FromBlueNpc=true, bool Override_Spawn_Loc = false, float Override_VEC[3] = {0.0,0.0,0.0}, int flags = 0, int inflictor = INVALID_ENT_REFERENCE, float bonusdmg = 1.0, bool hide_projectile = true)
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		//this.GetVectors(vecForward, vecSwingStart, vecAngles);
		
		if(Override_Spawn_Loc)
		{
			vecSwingStart[0]=Override_VEC[0];
			vecSwingStart[1]=Override_VEC[1];
			vecSwingStart[2]=Override_VEC[2];
		}
		else
		{
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 54.0;
		}
		
		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		float speed = rocket_speed;
#if defined ZR
		Rogue_Paradox_ProjectileSpeed(this.index, speed);
#endif
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-speed;

		int entity = CreateEntityByName("zr_projectile_base");
		if(IsValidEntity(entity))
		{
			h_BonusDmgToSpecialArrow[entity] = bonusdmg;
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			b_should_explode[entity] = do_aoe_dmg;
			i_ExplosiveProjectileHexArray[entity] = flags;
			fl_rocket_particle_dmg[entity] = rocket_damage;
			fl_rocket_particle_radius[entity] = damage_radius;
			b_rocket_particle_from_blue_npc[entity] = FromBlueNpc;
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetTeam(entity, GetTeam(this.index));
			
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
			DispatchSpawn(entity);
			for(int i; i<4; i++) //This will make it so it doesnt override its collision box.
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_rocket_particle, _, i);
			}
			SetEntityModel(entity, PARTICLE_ROCKET_MODEL);
	
			//Make it entirely invis. Shouldnt even render these 8 polygons.
			SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			if(hide_projectile)
			{
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
				SetEntityRenderColor(entity, 255, 255, 255, 0);
			}
			
			int particle = 0;
	
			if(rocket_particle[0]) //If it has something, put it in. usually it has one. but if it doesn't base model it remains.
			{
				particle = ParticleEffectAt(vecSwingStart, rocket_particle, 0.0); //Inf duartion
				i_rocket_particle[entity]= EntIndexToEntRef(particle);
				TeleportEntity(particle, NULL_VECTOR, vecAngles, NULL_VECTOR);
				SetParent(entity, particle);	
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR); //Make it entirely invis.
				SetEntityRenderColor(entity, 255, 255, 255, 0);
			}
			
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27
			
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rocket_Particle_DHook_RocketExplodePre); //*yawn*
		//	SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			SDKHook(entity, SDKHook_StartTouch, Rocket_Particle_StartTouch);
			return entity;
		}
		return -1;
	}
	public void FireGrenade(float vecTarget[3], float grenadespeed = 800.0, float damage, char[] model)
	{
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			GetAbsOrigin(this.index, vecSwingStart);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			float speed = grenadespeed;

#if defined ZR
			Rogue_Paradox_ProjectileSpeed(this.index, speed);
#endif
			
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*speed;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*speed;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-speed;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", this.index);
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			f_CustomGrenadeDamage[entity] = damage;	
			SetTeam(entity, GetTeam(this.index));
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
			DispatchSpawn(entity);
			SetEntityModel(entity, model);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			
			SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
		}
	}
	public int FireArrow(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, float offset = 0.0, int inflictor = INVALID_ENT_REFERENCE, int entitytofirefrom = -1) //No defaults, otherwise i cant even judge.
	{
		//ITS NOT actually an arrow, because of an ANNOOOOOOOOOOOYING sound.
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		//this.GetVectors(vecForward, vecSwingStart, vecAngles);

		if(entitytofirefrom == -1)
		{
			entitytofirefrom = this.index;
		}
		GetAbsOrigin(entitytofirefrom, vecSwingStart);
		vecSwingStart[2] += 54.0;

		vecSwingStart[2] += offset;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		float speed = rocket_speed;
		
#if defined ZR
		Rogue_Paradox_ProjectileSpeed(this.index, speed);
#endif
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-speed;

		int entity = CreateEntityByName("zr_projectile_base");
		if(IsValidEntity(entity))
		{
			b_EntityIsArrow[entity] = true;
			f_ArrowDamage[entity] = rocket_damage;
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetTeam(entity, GetTeam(this.index));
			SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				int g_ProjectileModelRocket = PrecacheModel(rocket_model);
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
				}
			}
			else
			{
				for(int i; i<4; i++)
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_modelArrow, _, i);
					
				//	int trail = Trail_Attach(entity, "effects/arrowtrail_blue.vmt", 255, 1.5, 12.0, 0.0, 4);
					int trail;

#if defined ZR
					if(GetTeam(this.index) == TFTeam_Red)
					{
						trail = Trail_Attach(entity, ARROW_TRAIL_RED, 255, 0.3, 3.0, 3.0, 5);
					}
					else
#endif

					{
						trail = Trail_Attach(entity, ARROW_TRAIL, 255, 0.3, 3.0, 3.0, 5);
					}
					
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(trail);
					
					//Just use a timer tbh.
					
					CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 24); //our savior
			Set_Projectile_Collision(entity); //If red, set to 27
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Arrow_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
	//		SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			SDKHook(entity, SDKHook_StartTouch, ArrowStartTouch);
		}
		return entity;
	}
	property int m_iActivity
	{
		public get()							{ return i_Activity[this.index]; }
		public set(int TempValueForProperty) 	{ i_Activity[this.index] = TempValueForProperty; }
	}
	
	property int m_iPoseMoveX 
	{
		public get()							{ return i_PoseMoveX[this.index]; }
		public set(int TempValueForProperty) 	{ i_PoseMoveX[this.index] = TempValueForProperty; }
	}
	
	property int m_iPoseMoveY
	{
		public get()							{ return i_PoseMoveY[this.index]; }
		public set(int TempValueForProperty) 	{ i_PoseMoveY[this.index] = TempValueForProperty; }
	}
	//Begin an animation activity, return false if we cant do that right now.
	public bool StartActivity(int iActivity, int flags = 0, bool Reset_Sequence_Info = true)
	{
		int nSequence = this.SelectWeightedSequence(iActivity);
		if (nSequence == 0) 
			return false;
		
		this.m_iActivity = iActivity;
		
		this.SetSequence(nSequence);
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);
	
//		Crashes now for buildings, ignore.
		if(Reset_Sequence_Info)
		{
			this.ResetSequenceInfo();
		}
		
		return true;
	}
		
	public int LookupActivity(const char[] activity)
	{
		
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
		
		int value = SDKCall(g_hLookupActivity, pStudioHdr, activity);
		return value;
	}
	public void Update()
	{
		if (this.m_iPoseMoveX < 0) {
			this.m_iPoseMoveX = this.LookupPoseParameter("move_x");
		}
		if (this.m_iPoseMoveY < 0) {
			this.m_iPoseMoveY = this.LookupPoseParameter("move_y");
		}
		
		float flNextBotGroundSpeed = this.GetGroundSpeed();
		
		if (flNextBotGroundSpeed < 0.01) {
			if (this.m_iPoseMoveX >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveX, 0.0);
			}
			if (this.m_iPoseMoveY >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveY, 0.0);
			}
		} else {
			float vecFwd[3], vecRight[3], vecUp[3];
			this.GetVectors(vecFwd, vecRight, vecUp);
			
			float vecMotion[3]; this.GetGroundMotionVector(vecMotion);
			
			if (this.m_iPoseMoveX >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveX, GetVectorDotProduct(vecMotion, vecFwd));
			}
			if (this.m_iPoseMoveY >= 0) {
				this.SetPoseParameter(this.m_iPoseMoveY, GetVectorDotProduct(vecMotion, vecRight));
			}
			
		}		
		this.GetBaseNPC().flRunSpeed = this.GetRunSpeed();
		this.GetBaseNPC().flWalkSpeed = this.GetRunSpeed();
		


		if(f_TimeFrozenStill[this.index] && f_TimeFrozenStill[this.index] < GetGameTime(this.index))
		{
			// Was frozen before, reset layers
			int layerCount = this.GetNumAnimOverlays();
			for(int i; i < layerCount; i++)
			{
				view_as<CClotBody>(this.index).SetLayerPlaybackRate(i, 1.0);
			}
			view_as<CClotBody>(this.index).SetPlaybackRate(f_LayerSpeedFrozeRestore[this.index]);

			if(IsValidEntity(view_as<CClotBody>(this.index).m_iFreezeWearable))
				RemoveEntity(view_as<CClotBody>(this.index).m_iFreezeWearable);

			f_TimeFrozenStill[this.index] = 0.0;
		}

		if(this.m_bisWalking) //This exists to make sure that if there is any idle animation played, it wont alter the playback rate and keep it at a flat 1, or anything altered that the user desires.
		{
			float m_flGroundSpeed = GetEntPropFloat(this.index, Prop_Data, "m_flGroundSpeed");
			if(m_flGroundSpeed != 0.0)
			{
				float PlaybackSpeed = clamp((flNextBotGroundSpeed / m_flGroundSpeed), -4.0, 12.0);
				PlaybackSpeed *= this.m_bisGiantWalkCycle;
				if(PlaybackSpeed > 2.0)
					PlaybackSpeed = 2.0;
					
				this.SetPlaybackRate(PlaybackSpeed);
			}
		}
		
	//	this.StudioFrameAdvance();
	//	this.DispatchAnimEvents();
		
		//Run and StuckMonitor
		if(this.m_flNextRunTime < GetGameTime())
		{
			this.m_flNextRunTime = GetGameTime() + 0.15; //Only update every 0.1 seconds, we really dont need more, 
			this.GetLocomotionInterface().Run();
		}
		if(this.m_bAllowBackWalking)
		{
			this.GetBaseNPC().flMaxYawRate = 0.0;
		}
		else
		{
			this.GetBaseNPC().flMaxYawRate = (NPC_DEFAULT_YAWRATE * this.GetDebuffPercentage() * f_NpcTurnPenalty[this.index]);
		}

		if(f_AvoidObstacleNavTime[this.index] < GetGameTime()) //add abit of delay for optimisation
		{
			CNavArea areaNavget;
			CNavArea areaNavget2;
			Segment segment;
			Segment segment2;
			segment = this.GetPathFollower().FirstSegment();
			if(segment != NULL_PATH_SEGMENT)
			{
				segment2 = this.GetPathFollower().NextSegment(segment);
				segment2 = this.GetPathFollower().NextSegment(segment2);
			}

			if(segment != NULL_PATH_SEGMENT && segment2 != NULL_PATH_SEGMENT)
			{
				areaNavget = segment.area;
				areaNavget2 = segment2.area;
			}

			b_AvoidObstacleType[this.index] = false;
			
			if(areaNavget != NULL_AREA && areaNavget2 != NULL_AREA)
			{
				int NavAttribs = areaNavget.GetAttributes();
				int NavAttribs2 = areaNavget2.GetAttributes();
				if(NavAttribs & NAV_MESH_WALK || NavAttribs2 & NAV_MESH_WALK)
				{
					b_AvoidObstacleType[this.index] = true;
				}
				if(NavAttribs & NAV_MESH_JUMP && NavAttribs2 & NAV_MESH_JUMP)
				{
					//They are in some position where we need to jump, lets jump.
					if(this.m_flJumpStartTimeInternal < GetGameTime())
					{
						this.m_flJumpStartTimeInternal = GetGameTime() + 2.0;
						float VecPos[3];
						areaNavget2.GetCenter(VecPos);
						PluginBot_Jump(this.index,VecPos);
					}
				}
			}
			f_AvoidObstacleNavTime[this.index] = GetGameTime() + 0.1;
		}

		//increace the size of the avoid box by 2x

		int IgnoreObstacles = 0;

		if(b_AvoidObstacleType_Time[this.index] > GetGameTime())
			IgnoreObstacles = 1;

		if(b_AvoidObstacleType[this.index])
			IgnoreObstacles = 2;
#if defined ZR
		if((VIPBuilding_Active() && GetTeam(this.index) != TFTeam_Red))
			IgnoreObstacles = 2;
#endif
		if(IgnoreObstacles == 0)
		{
			float ModelSize = GetEntPropFloat(this.index, Prop_Send, "m_flModelScale");
			//avoid obstacle code scales with modelsize, we dont want that.
			float f3_AvoidModifMax[3];
			float f3_AvoidModifMin[3];

			for(int axis; axis < 3; axis++)
			{
				f3_AvoidModifMax[axis] = f3_AvoidOverrideMax[this.index][axis];
				f3_AvoidModifMin[axis] = f3_AvoidOverrideMin[this.index][axis];
				f3_AvoidModifMax[axis] /= ModelSize;
				f3_AvoidModifMin[axis] /= ModelSize;
				if(this.m_bIsGiant) //giants need abit more space.
				{
					f3_AvoidModifMax[axis] *= 1.35;
					f3_AvoidModifMin[axis] *= 1.35;
				}
			}
			this.GetBaseNPC().SetBodyMaxs(f3_AvoidModifMax);
			this.GetBaseNPC().SetBodyMins(f3_AvoidModifMin);	
		}
		else
		{
			if(IgnoreObstacles == 2)
			{
				//was in obstacle avoid before, reuse.
				//some stairs really dont like navs, so they think they are on no nav and then try to avoid stairs, oof!
				//this is a good solution, if any stairs are bigger

				//unused.
				b_AvoidObstacleType_Time[this.index] = GetGameTime() + 0.0;
			}
			//if in tower defense, never avoid.
			this.GetBaseNPC().SetBodyMaxs({1.0,1.0,1.0});
			this.GetBaseNPC().SetBodyMins({0.0,0.0,0.0});
		}
#if defined ZR
		if(VIPBuilding_Active() && GetTeam(this.index) != TFTeam_Red)
		{
			if(f_UnstuckSuckMonitor[this.index] < GetGameTime())
			{
				this.GetLocomotionInterface().ClearStuckStatus("UN-STUCK");
				f_UnstuckSuckMonitor[this.index] = GetGameTime() + 1.0;
			}
		}
#endif
		if(this.m_bPathing)
			this.GetPathFollower().Update(this.GetBot());	

		this.GetBaseNPC().SetBodyMaxs(f3_AvoidOverrideMaxNorm[this.index]);
		this.GetBaseNPC().SetBodyMins(f3_AvoidOverrideMinNorm[this.index]);	
	}

	 	
	
	//return currently animating activity
	public int GetActivity()
	{
		return this.m_iActivity;
	}
	
	//return true if currently animating activity matches the given one
	public bool IsActivity(int iActivity)
	{
	
		return (iActivity == this.m_iActivity);
	}
	public void RestartMainSequence()
	{
		SetEntPropFloat(this.index, Prop_Data, "m_flAnimTime", GetGameTime());
		
		this.SetCycle(0.0);
	}
	
	public bool IsSequenceFinished()
	{
		return !!GetEntProp(this.index, Prop_Data, "m_bSequenceFinished");
	}
}

//Trash below!

public void NPC_Base_InitGamedata()
{
	RegAdminCmd("sm_spawn_npc", Command_PetMenu, ADMFLAG_SLAY);
	RegAdminCmd("sm_remove_npc", Command_RemoveAll, ADMFLAG_SLAY);
	
	GameData gamedata = LoadGameConfigFile("zombie_riot");
	
	DHook_CreateDetour(gamedata, "NextBotGroundLocomotion::UpdateGroundConstraint", Dhook_UpdateGroundConstraint_Pre, Dhook_UpdateGroundConstraint_Post);
	//this isnt directly the same function, but it should act the same.
	
	//SDKCalls
	//This call is used to get an entitys center position
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseEntity::WorldSpaceCenter");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((g_hSDKWorldSpaceCenter = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::WorldSpaceCenter offset!");
	

	//CBaseAnimating::ResetSequenceInfo( );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseAnimating::ResetSequenceInfo");
	if ((g_hResetSequenceInfo = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::ResetSequenceInfo signature!"); 
	

	/*
	void CBaseAnimating::RefreshCollisionBounds( void )
	{
		CollisionProp()->RefreshScaledCollisionBounds();
	}
	*/
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseAnimating::RefreshCollisionBounds");
	if ((g_hUpdateCollisionBox = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::RefreshCollisionBounds offset!"); 
	
	//-----------------------------------------------------------------------------
	// Purpose: Looks up an activity by name.
	// Input  : label - Name of the activity to look up, ie "ACT_IDLE"
	// Output : Activity index or ACT_INVALID if not found.
	//-----------------------------------------------------------------------------
	//int LookupActivity( CStudioHdr *pstudiohdr, const char *label )
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "LookupActivity");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//label
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hLookupActivity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for LookupActivity");

	//CBaseEntity::GetVectors(Vector*, Vector*, Vector*) 
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if((g_hGetVectors = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseEntity::GetVectors!");

	g_hGetSolidMask			= DHookCreateEx(gamedata, "IBody::GetSolidMask",	   HookType_Raw, ReturnType_Int,   ThisPointer_Address, IBody_GetSolidMask);

	delete gamedata;

	NextBotActionFactory ActionFactory = new NextBotActionFactory("ZRMainAction");
	ActionFactory.SetEventCallback(EventResponderType_OnActorEmoted, PluginBot_OnActorEmoted);

	CEntityFactory EntityFactory = new CEntityFactory("zr_base_npc", OnCreate, OnDestroy);
	EntityFactory.DeriveFromNPC();
	EntityFactory.SetInitialActionFactory(ActionFactory);
	EntityFactory.BeginDataMapDesc()
		.DefineIntField("zr_pPath")
	
		//Seargent Ideal Shield Netprops
		.DefineIntField("zr_iRefSeargentProtect")
		.DefineFloatField("zr_fSeargentProtectTime")
	.EndDataMapDesc();
	EntityFactory.Install();

	//for (int i = 0; i < MAXENTITIES; i++) pPath[i] = PathFollower(PathCost, Path_FilterIgnoreActors, Path_FilterOnlyActors);
}

/*
	GetTeam(i) != TFTeam_Red
	GetTeam(ally) == TFTeam_Red
	This is just here for me to quickly copypaste
	incase i forget to delete
	delete it for me
*/
static void OnCreate(CClotBody body)
{
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
		if(!IsValidEntity(entity))
		{
			body.SetProp(Prop_Data, "zr_pPath", view_as<int>(g_NpcPathFollower[entitycount]));
			i_ObjectsNpcsTotal[entitycount] = EntIndexToEntRef(body.index);
			break;
		}
	}
}

void RemoveFromNpcPathList(CClotBody body)
{
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
		if(entity == body.index)
		{
			body.SetProp(Prop_Data, "zr_pPath", 0);
			i_ObjectsNpcsTotal[entitycount] = -1;
			break;
		}
	}	
}
#if defined ZR
void NpcAddedToZombiesLeftCurrently(int entity, bool CountUp)
{
	b_NpcHasBeenAddedToZombiesLeft[entity] = true;
	if(CountUp)
	{
		Zombies_Currently_Still_Ongoing += 1;
	}
} 

void RemoveNpcFromZombiesLeftCounter(int entity)
{
	if(b_NpcHasBeenAddedToZombiesLeft[entity])
	{
		Zombies_Currently_Still_Ongoing -= 1;
	}
	b_NpcHasBeenAddedToZombiesLeft[entity] = false;
}
#endif
static void OnDestroy(CClotBody body)
{
	RemoveFromNpcAliveList(body.index);
#if defined ZR
		RemoveNpcFromZombiesLeftCounter(body.index);
#endif
	if(!b_NpcHasDied[body.index])
	{
		RemoveFromNpcPathList(body);
	}
	RemoveNpcThingsAgain(body.index);
	if(h_NpcCollissionHookType[body.index] != 0)
	{
		if(!DHookRemoveHookID(h_NpcCollissionHookType[body.index]))
		{
			PrintToConsoleAll("Somehow Failed to unhook h_NpcCollissionHookType");
		}
	}
	if(h_NpcSolidHookType[body.index] != 0)
	{
		if(!DHookRemoveHookID(h_NpcSolidHookType[body.index]))
		{
			PrintToConsoleAll("Somehow Failed to unhook h_NpcSolidHookType");
		}
	}
	b_ThisWasAnNpc[body.index] = false;
	b_NpcHasDied[body.index] = true;
	b_StaticNPC[body.index] = false;

	if(IsValidEntity(body.m_iTeamGlow))
		RemoveEntity(body.m_iTeamGlow);

	if(IsValidEntity(body.m_iSpawnProtectionEntity))
		RemoveEntity(body.m_iSpawnProtectionEntity);

	if(IsValidEntity(body.m_iTextEntity1))
		RemoveEntity(body.m_iTextEntity1);
	if(IsValidEntity(body.m_iTextEntity2))
		RemoveEntity(body.m_iTextEntity2);
	if(IsValidEntity(body.m_iTextEntity3))
		RemoveEntity(body.m_iTextEntity3);
	if(IsValidEntity(body.m_iTextEntity4))
		RemoveEntity(body.m_iTextEntity4);
	if(IsValidEntity(body.m_iTextEntity5))
		RemoveEntity(body.m_iTextEntity5);
	if(IsValidEntity(body.m_iFreezeWearable))
		RemoveEntity(body.m_iFreezeWearable);
	if(IsValidEntity(body.m_iInvulWearable))
		RemoveEntity(body.m_iInvulWearable);
	if(IsValidEntity(body.m_iWearable1))
		RemoveEntity(body.m_iWearable1);
	if(IsValidEntity(body.m_iSpeechBubble))
		RemoveEntity(body.m_iSpeechBubble);
	if(IsValidEntity(body.m_iWearable2))
		RemoveEntity(body.m_iWearable2);
	if(IsValidEntity(body.m_iWearable3))
		RemoveEntity(body.m_iWearable3);
	if(IsValidEntity(body.m_iWearable4))
		RemoveEntity(body.m_iWearable4);
	if(IsValidEntity(body.m_iWearable5))
		RemoveEntity(body.m_iWearable5);
	if(IsValidEntity(body.m_iWearable6))
		RemoveEntity(body.m_iWearable6);
	if(IsValidEntity(body.m_iWearable7))
		RemoveEntity(body.m_iWearable7);
	if(IsValidEntity(body.m_iWearable8))
		RemoveEntity(body.m_iWearable8);

}

//Ragdoll
public void CBaseCombatCharacter_EventKilledLocal(int pThis, int iAttacker, int iInflictor, float flDamage, int iDamagetype, int iWeapon, const float vecDamageForce[3], const float vecDamagePosition[3])
{	
	RemoveFromNpcAliveList(pThis);
	if(!b_NpcHasDied[pThis])
	{

		int client;
#if defined ZR
		if(Saga_EnemyDoomed(pThis))
		{
			client = Saga_EnemyDoomedBy(pThis);
		}
		else
#endif
		{
			client = EntRefToEntIndex(LastHitRef[pThis]);
		}

#if defined ZR || defined RPG
		KillFeed_Show(pThis, iInflictor, iAttacker, client, iWeapon, iDamagetype);
#endif

		//MUST be at top, or else there can be heavy issues regarding infinite loops!
		b_NpcHasDied[pThis] = true;

		//leaving these on can cause crashes.
		SDKUnhook(pThis, SDKHook_TraceAttack, NPC_TraceAttack);
		SDKUnhook(pThis, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
		SDKUnhook(pThis, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	

#if defined ZR || defined RPG
		if(client > 0 && client <= MaxClients)
		{
			if(i_HasBeenHeadShotted[pThis])
				i_Headshots[client] += 1; //Award 1 headshot point, only once.

			if(i_HasBeenBackstabbed[pThis])
				i_Backstabs[client] += 1; //Give a backstab count!

			i_KillsMade[client] += 1;
			RemoveHudCooldown(client);
			Calculate_And_Display_hp(client, pThis, 0.0, true);
		}
#endif
		
		for(int entitycount; entitycount<i_MaxcountSticky; entitycount++)
		{
			int Sticky_Index = EntRefToEntIndex(i_StickyToNpcCount[pThis][entitycount]);
			if (IsValidEntity(Sticky_Index)) //Am i valid still exiting sticky ?
			{
				float Vector_Pos[3];
				GetEntPropVector(Sticky_Index, Prop_Data, "m_vecAbsOrigin", Vector_Pos); 
				AcceptEntityInput(Sticky_Index, "ClearParent");
				i_StickyToNpcCount[pThis][entitycount] = -1; //Remove it being parented.
				TeleportEntity(Sticky_Index, Vector_Pos);
				
				SetEntProp(Sticky_Index, Prop_Send, "m_bTouched", false);
				b_StickyIsSticking[Sticky_Index] = false;
				
			}
		}
		
		
		CClotBody npc = view_as<CClotBody>(pThis);
		npc.m_flNextDelayTime = 999999.9; //disable them thinking.
		SDKUnhook(pThis, SDKHook_ThinkPost, NpcBaseThinkPost);
#if defined ZR
		OnKillUniqueWeapon(iAttacker, iWeapon, pThis);
#endif
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
		if(IsValidEntity(npc.m_iSpawnProtectionEntity))
			RemoveEntity(npc.m_iSpawnProtectionEntity);

		if(IsValidEntity(npc.m_iTextEntity1))
			RemoveEntity(npc.m_iTextEntity1);
		if(IsValidEntity(npc.m_iTextEntity2))
			RemoveEntity(npc.m_iTextEntity2);
		if(IsValidEntity(npc.m_iTextEntity3))
			RemoveEntity(npc.m_iTextEntity3);
		if(IsValidEntity(npc.m_iTextEntity4))
			RemoveEntity(npc.m_iTextEntity4);
		if(IsValidEntity(npc.m_iTextEntity5))
			RemoveEntity(npc.m_iTextEntity5);
		if(IsValidEntity(npc.m_iFreezeWearable))
			RemoveEntity(npc.m_iFreezeWearable);
		if(IsValidEntity(npc.m_iInvulWearable))
			RemoveEntity(npc.m_iInvulWearable);
		if(IsValidEntity(npc.m_iSpeechBubble))
			RemoveEntity(npc.m_iSpeechBubble);
		
#if defined ZR
		if(GetTeam(pThis) != TFTeam_Red && !b_DoNotGiveWaveDelay[pThis])
		{
			if(f_DelayNextWaveStartAdvancingDeathNpc < GetGameTime() + 1.5)
			{
				f_DelayNextWaveStartAdvancingDeathNpc = GetGameTime() + 1.5;
			}
		}
		CleanAllAppliedEffects_BombImplanter(pThis, true);
#endif

#if defined EXPIDONSA_BASE
		VausMagicaRemoveShield(pThis);
#endif

#if !defined RTS
		NPC_DeadEffects(pThis); //Do kill attribute stuff
#endif

		SetEntProp(pThis, Prop_Data, "m_lifeState", 2);
		RemoveNpcThingsAgain(pThis);
		ExtinguishTarget(pThis);
		NPCDeath(pThis);
		NPCStats_SetFuncsToZero(pThis);
		//We do not want this entity to collide with anything when it dies. 
		//yes it is a single frame, but it can matter in ugly ways, just avoid this.
		MakeObjectIntangeable(pThis);
		b_ThisEntityIgnored[pThis] = true;
		b_ThisEntityIgnoredEntirelyFromAllCollisions[pThis] = true;
	//Do not remove pather here.
		RemoveNpcFromEnemyList(pThis, true);
		b_StaticNPC[pThis] = false;

		if(!npc.m_bDissapearOnDeath)
		{
			if(!npc.m_bGib)
			{
				MakeEntityRagdollNpc(npc.index);
			}
			else
			{
				Npc_DoGibLogic(pThis);
				SetNpcToDeadViaGib(pThis);
			}
		}
		else
		{	
			SetNpcToDeadViaGib(pThis);
		}

#if defined ZR
		Waves_UpdateMvMStats();
#endif

	}
	else
	{	
		SetNpcToDeadViaGib(pThis);
	}
}


void Npc_DoGibLogic(int pThis)
{
	CClotBody npc = view_as<CClotBody>(pThis);
	float startPosition[3]; //This is what we use if we cannot find the correct name of said bone for this npc.
				
	float accurateposition[3]; //What we use if it has one.
	float accurateAngle[3]; //What we use if it has one.
	
	float damageForce[3];
	npc.m_vecpunchforce(damageForce, false);

	bool Limit_Gibs = false;
	if(CurrentGibCount > ZR_MAX_GIBCOUNT)
	{
		Limit_Gibs = true;
	}

	static int Main_Gib;
	
	switch(npc.m_iBleedType)
	{
		case BLEEDTYPE_NORMAL:
		{
			npc.PlayGibSound();
			if(npc.m_bIsGiant)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 64;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true, true);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 15;
					Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce, false, true);
					startPosition[2] += 44;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, false, true);	
					}
					else
					{
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, false, true);	
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 42;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 10;
					Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce);
					startPosition[2] += 34;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce);	
					}
					else
					{
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce);	
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}	
		}	
		case BLEEDTYPE_METAL:
		{
			npc.PlayGibSoundMetal();
			if(npc.m_bIsGiant)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 64;
				Main_Gib = Place_Gib("models/gibs/helicopter_brokenpiece_03.mdl", startPosition, _, damageForce, true, false, true, true); //dont gigantify this one.
				if(!Limit_Gibs)
				{
					startPosition[2] -= 15;
					Place_Gib("models/gibs/scanner_gib01.mdl", startPosition, _, damageForce, false, true, true);
					startPosition[2] += 44;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/gibs/metal_gib2.mdl", accurateposition, accurateAngle, damageForce, false, true, true);	
					}
					else
					{
						Place_Gib("models/gibs/metal_gib2.mdl", startPosition, _, damageForce, false, true, true);		
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 42;
				Main_Gib = Place_Gib("models/gibs/helicopter_brokenpiece_03.mdl", startPosition, _, damageForce, true, false, true, true, true);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 10;
					Place_Gib("models/gibs/scanner_gib01.mdl", startPosition, _, damageForce, false, false, true);
					startPosition[2] += 34;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/gibs/metal_gib2.mdl", accurateposition, accurateAngle, damageForce, false, false, true);
					}
					else
					{
						Place_Gib("models/gibs/metal_gib2.mdl", startPosition, _, damageForce, false, false, true);		
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}		
		}
		case BLEEDTYPE_XENO:
		{
			npc.PlayGibSound();
			if(npc.m_bIsGiant)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 64;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true, true, _, _, _, 1);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 15;
					Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce, false, true, _, _, _, 1);
					startPosition[2] += 44;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, false, true, _, _, _, 1);	
					}
					else
					{
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, false, true, _, _, _, 1);		
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 42;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true, _, _, _, _, 1);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 10;
					Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce, _, _, _, _, _, 1);
					startPosition[2] += 34;
					if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
					{
						npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
						Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, _, _, _, _, _, 1);
					}
					else
					{
						Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, _, _, _, _, _, 1);
					}
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}	
		}
		case BLEEDTYPE_SKELETON:
		{
			npc.PlayGibSound();
			if(npc.m_bIsGiant)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 64;
				Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl", startPosition, _, damageForce, false, true, _, _, _, false, true);
				startPosition[2] -= 15;
				Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_torso.mdl", startPosition, _, damageForce, false, true, _, _, _, false, true);
				startPosition[2] += 44;
				if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
				{
					npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
					Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl", accurateposition, accurateAngle, damageForce, false, true, _, _, _, false, true);	
				}
				else
				{
					Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl", startPosition, _, damageForce, false, true, _, _, _, false, true);		
				}
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 42;
				Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl", startPosition, _, damageForce, true, _, _, _, _, false, true);
				startPosition[2] -= 10;
				Place_Gib("models/bots/skeleton_sniper/skeleton_sniper_gib_torso.mdl", startPosition, _, damageForce, _, _, _, _, _, false, true);
				startPosition[2] += 34;
				if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
				{
					npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
					Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, _, _, _, _, _, false, true);
				}
				else
				{
					Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, _, _, _, _, _, false, true);
				}
			}	
		}
		case BLEEDTYPE_SEABORN:
		{
			npc.PlayGibSound();
			if(npc.m_bIsGiant)
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 64;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_3.mdl", startPosition, _, damageForce, true, true, _, _, _, 2);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 15;
					Place_Gib("models/gibs/antlion_gib_medium_2.mdl", startPosition, _, damageForce, false, true, _, _, _, 2);
					startPosition[2] += 44;
					Place_Gib("models/gibs/antlion_gib_medium_1.mdl", startPosition, _, damageForce, false, true, _, _, _, 2);
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}
			else
			{
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				startPosition[2] += 42;
				Main_Gib = Place_Gib("models/gibs/antlion_gib_large_3.mdl", startPosition, _, damageForce, true, _, _, _, _, 2);
				if(!Limit_Gibs)
				{
					startPosition[2] -= 10;
					Place_Gib("models/gibs/antlion_gib_medium_2.mdl", startPosition, _, damageForce, _, _, _, _, _, 2);
					startPosition[2] += 34;
					Place_Gib("models/gibs/antlion_gib_medium_1.mdl", startPosition, _, damageForce, _, _, _, _, _, 2);
				}
				else
				{
					if(IsValidEntity(Main_Gib))
					{
						b_LimitedGibGiveMoreHealth[Main_Gib] = true;
					}
				}
			}	
		}
	}
}
public void SetNpcToDeadViaGib(int pThis)
{
#if defined ZR
	b_thisNpcHasAnOutline[pThis] = false;
#endif
	b_IsEntityNeverTranmitted[pThis] = true; //doesnt seem to work all the time, but the more the better.
	SetEntityRenderMode(pThis, RENDER_NONE);
	SetEdictFlags(pThis, SetEntityTransmitState(pThis, FL_EDICT_DONTSEND));
	CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(pThis), TIMER_FLAG_NO_MAPCHANGE);	
}

public void Kill_Npc(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity) && entity > 0)
	{
		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); 	//Teleport them very far away as to not just stand and eat bullets.
																		//Dont do this too soon or else it MIGHT cause ragdolls and other stuff to actually
																		//not even apear, so just do it when they actually despawn, just to be safe.
	}
}

bool IsWalkEvent(int event, int special = 0)
{
	if(special == 5)
	{
		if (event == 52)
			return true;	
	}
	else 
	{
		if (event == 7001 || event == 59 || event == 58 || event == 66 || event == 65 || event == 6004 || event == 6005 || event == 7005 || event == 7004)
			return true;
	}
		
	return false;
	
}


public MRESReturn CBaseAnimating_HandleAnimEvent(int pThis, Handle hParams)
{
	int event = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
	CClotBody npc = view_as<CClotBody>(pThis);
	if(b_NpcHasDied[pThis])
		return MRES_Ignored;
		
	Function func = func_NPCAnimEvent[pThis];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(pThis);
		Call_PushCell(event);
		Call_Finish();
	}
	
	switch(npc.m_iNpcStepVariation)
	{
		case STEPTYPE_NORMAL:
		{
			if(IsWalkEvent(event))
			{
				/*
				causes too much lag.
				static char strSound[64];
				static float vSoundPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vSoundPos);
				vSoundPos[2] += 1.0;
				
				TR_TraceRayFilter(vSoundPos, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
				static char material[PLATFORM_MAX_PATH]; TR_GetSurfaceName(null, material, PLATFORM_MAX_PATH);
				
				Format(strSound, sizeof(strSound), "player/footsteps/%s%i.wav", GetStepSoundForMaterial(material), GetRandomInt(1,4));
				
				npc.PlayStepSound(strSound,0.8, npc.m_iStepNoiseType);
				*/
				npc.PlayStepSound(g_DefaultStepSound[GetRandomInt(0, sizeof(g_DefaultStepSound) - 1)], 0.8, npc.m_iStepNoiseType);
			}
		}
		case STEPTYPE_COMBINE:
		{
			if(IsWalkEvent(event))
			{
				npc.PlayStepSound(g_CombineSoldierStepSound[GetRandomInt(0, sizeof(g_CombineSoldierStepSound) - 1)], 0.8, npc.m_iStepNoiseType);
			}
		}
		case STEPTYPE_PANZER:
		{
			if(IsWalkEvent(event))
			{
				if(npc.m_flDoSpawnGesture < GetGameTime())
				{
					npc.PlayStepSound(g_PanzerStepSound[GetRandomInt(0, sizeof(g_PanzerStepSound) - 1)], 1.0, npc.m_iStepNoiseType);
				}
			}
		}
		case STEPTYPE_COMBINE_METRO:
		{
			if(IsWalkEvent(event))
			{
				if(npc.m_flDoSpawnGesture < GetGameTime())
				{
					npc.PlayStepSound(g_CombineMetroStepSound[GetRandomInt(0, sizeof(g_CombineMetroStepSound) - 1)], 0.65, npc.m_iStepNoiseType);
				}
			}
		}
		case STEPTYPE_TANK:
		{
			if(IsWalkEvent(event, 5))
			{
				if(npc.m_flDoSpawnGesture < GetGameTime())
				{
					npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, npc.m_iStepNoiseType, true);
					npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, npc.m_iStepNoiseType, true);
				}
			}
		}
		case STEPTYPE_ROBOT:
		{
			if(IsWalkEvent(event))
			{
				npc.PlayStepSound(g_RobotStepSound[GetRandomInt(0, sizeof(g_RobotStepSound) - 1)], 0.8, npc.m_iStepNoiseType);
			}
		}
		case STEPTYPE_SEABORN:
		{
			if(IsWalkEvent(event))
			{
				static char strSound[64];
				Format(strSound, sizeof(strSound), "player/footsteps/mud%d.wav", GetRandomInt(1,4));
				npc.PlayStepSound(strSound, 0.5, npc.m_iStepNoiseType);
			}
		}
	}
	return MRES_Ignored;
}

#if defined ZR || defined RPG
stock void NPC_StartPathing(int entity)
{
	view_as<CClotBody>(entity).StartPathing();
}

stock void NPC_StopPathing(int entity)
{
	view_as<CClotBody>(entity).StopPathing();
}

stock void NPC_SetGoalVector(int entity, const float vec[3], bool ignore_time = false)
{
	view_as<CClotBody>(entity).SetGoalVector(vec, ignore_time);
}

stock void NPC_SetGoalEntity(int entity, int target)
{
	if(i_IsABuilding[target] || b_IsVehicle[target])
	{
		//broken on targetting buildings...?
		float pos[3]; GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
		view_as<CClotBody>(entity).SetGoalVector(pos, false);
	}
	else
	{
		view_as<CClotBody>(entity).SetGoalEntity(target);
	}
}
#endif

stock bool IsLengthGreaterThan(float vector[3], float length)
{
	return (SquareRoot(GetVectorLength(vector, false)) > length * length);
}

public float clamp(float a, float b, float c) { return (a > c ? c : (a < b ? b : a)); }

stock void WorldSpaceCenter(int entity, float vecPos[3])
{
	//We need to do an exception here, if we detect that we actually make the size bigger via lag comp
	//then we just get an offset of the abs origin, abit innacurate but it works like a charm.
	if(b_LagCompNPC_ExtendBoundingBox)
	{
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vecPos);
		//did you know abs origin only exists for the server? crazy right
		
		//This is usually the middle, so this should work out just fine!
	
		if(b_IsGiant[entity])
		{
			vecPos[2] += 64.0;
		}
		else
		{
			vecPos[2] += 42.0;
		}
	}
	else
	{
		SDKCall(g_hSDKWorldSpaceCenter, entity, vecPos);
	}
}

stock CNavArea PickRandomArea()
{
	int iAreaCount = TheNavAreas.Length;
	
	//Pick a random goal area
	return TheNavAreas.Get(GetURandomInt() % iAreaCount);
}

int HitEntitiesTeleportTrace[MAXENTITIES];
public bool TeleportDetectEnemy(int entity, int contentsMask, any iExclude)
{
	if(IsValidEnemy(iExclude, entity, true, true))
	{
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!HitEntitiesTeleportTrace[i])
			{
				HitEntitiesTeleportTrace[i] = entity;
				break;
			}
		}
	}
	return false;
}
stock bool Player_Teleport_Safe(int client, float endPos[3], bool teleport = true)
{
	bool FoundSafeSpot = false;

	static float hullcheckmaxs_Player[3];
	static float hullcheckmins_Player[3];
	hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
	hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	

	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
		FoundSafeSpot = true;

	for (int x = 0; x < 6; x++)
	{
		if (FoundSafeSpot)
			break;

		endPos = OriginalPos;
		//ignore 0 at all costs.
		
		switch(x)
		{
			case 0:
				endPos[0] += TELEPORT_STUCK_CHECK_1;

			case 1:
				endPos[0] -= TELEPORT_STUCK_CHECK_1;

			case 2:
				endPos[0] += TELEPORT_STUCK_CHECK_2;

			case 3:
				endPos[0] -= TELEPORT_STUCK_CHECK_2;

			case 4:
				endPos[0] += TELEPORT_STUCK_CHECK_3;

			case 5:
				endPos[0] -= TELEPORT_STUCK_CHECK_3;	
		}
		for (int y = 0; y < 7; y++)
		{
			if (FoundSafeSpot)
				break;

			endPos[1] = OriginalPos[1];
				
			switch(y)
			{
				case 1:
					endPos[1] += TELEPORT_STUCK_CHECK_1;

				case 2:
					endPos[1] -= TELEPORT_STUCK_CHECK_1;

				case 3:
					endPos[1] += TELEPORT_STUCK_CHECK_2;

				case 4:
					endPos[1] -= TELEPORT_STUCK_CHECK_2;	

				case 5:
					endPos[1] += TELEPORT_STUCK_CHECK_3;	

				case 6:
					endPos[1] -= TELEPORT_STUCK_CHECK_3;	
			}

			for (int z = 0; z < 7; z++)
			{
				if (FoundSafeSpot)
					break;

				endPos[2] = OriginalPos[2];
						
				switch(z)
				{
					case 1:
						endPos[2] += TELEPORT_STUCK_CHECK_1;

					case 2:
						endPos[2] -= TELEPORT_STUCK_CHECK_1;

					case 3:
						endPos[2] += TELEPORT_STUCK_CHECK_2;

					case 4:
						endPos[2] -= TELEPORT_STUCK_CHECK_2;

					case 5:
						endPos[2] += TELEPORT_STUCK_CHECK_3;

					case 6:
						endPos[2] -= TELEPORT_STUCK_CHECK_3;	
				}
				if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
					FoundSafeSpot = true;
			}
		}
	}
				
	FoundSafeSpot = false;

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player))
	{
		FoundSafeSpot = true;
	}

	if(FoundSafeSpot)
	{
		if(teleport)
			TeleportEntity(client, endPos, NULL_VECTOR, NULL_VECTOR);
	}
	return FoundSafeSpot;
}

public void constrainDistance(const float[] startPoint, float[] endPoint, float distance, float maxDistance)
{
	float constrainFactor = maxDistance / distance;
	endPoint[0] = ((endPoint[0] - startPoint[0]) * constrainFactor) + startPoint[0];
	endPoint[1] = ((endPoint[1] - startPoint[1]) * constrainFactor) + startPoint[1];
	endPoint[2] = ((endPoint[2] - startPoint[2]) * constrainFactor) + startPoint[2];
}

public bool IsEntityTraversable(CBaseNPC_Locomotion loco, int other_entidx, TraverseWhenType when)
{
	if(other_entidx < 1)
	{
		return false;
	}
	int bot_entidx = loco.GetBot().GetNextBotCombatCharacter();

#if defined ZR
	if(GetTeam(bot_entidx) != TFTeam_Red && IsEntityTowerDefense(bot_entidx))
	{
		//during tower defense, pretend all enemies are non collideable.
		return true;
	}
#endif

	if(b_is_a_brush[other_entidx])
	{
		return false;
	}

	if(b_ThisEntityIsAProjectileForUpdateContraints[other_entidx])
	{
		return true;
	}


#if defined RTS
	if(IsObject(other_entidx))
	{
		return !b_CantCollidie[other_entidx];
	}

	return !b_NpcHasDied[other_entidx];
#else
	if(i_IsABuilding[other_entidx])
	{
		return true;
	}

#if defined ZR


	if(GetTeam(bot_entidx) == TFTeam_Red) //ally!
	{
		if(b_IsCamoNPC[bot_entidx])
		{
			return true;
		}
		if(b_CollidesWithEachother[bot_entidx])
		{
			if(b_CollidesWithEachother[other_entidx])
			{
				return false; //Incase allies collide with eachother, then we try to make them avoid eachother.
			}
		}
		if(b_CantCollidie[other_entidx])
		{
			return true;
		}
	}
	else if(b_CantCollidieAlly[other_entidx])
	{
		return true;
	}
#else
	if(b_CantCollidie[other_entidx])
	{
		return true;
	}

#endif

	if(other_entidx > 0 && other_entidx <= MaxClients)
	{
		if(b_TryToAvoidTraverse[bot_entidx])
		{
			return false;
		}
		return true;
	}
	if(GetTeam(bot_entidx) != GetTeam(other_entidx))
	{
		return true;
	}

	return false; //we let them through, we dont want them to just try to avoid everything!
#endif	// Non-RTS
}
static int i_PluginBot_ApproachDelay[MAXENTITIES];

public int Action_CommandApproach(NextBotAction action, int actor, const float pos[3], float range)
{
	CClotBody npc = view_as<CClotBody>(actor);
	npc.Approach(pos);
	if(i_PluginBot_ApproachDelay[actor] >= 1)
	{
		i_PluginBot_ApproachDelay[actor] = 0;

		//gets called every frame! bad! delay abit.
		//Default value is 250.
		if(!npc.m_bAllowBackWalking)
			npc.FaceTowards(pos, (500.0 * npc.GetDebuffPercentage() * f_NpcTurnPenalty[npc.index]));
	}
	else
	{
		i_PluginBot_ApproachDelay[actor]++;
	}
	
	return 0;
}

bool Allowbuildings_BulletAndMeleeTraceAlly = false;

stock void Allowbuildings_BulletAndMeleeTraceAllyLogic(bool Enableornot)
{
	Allowbuildings_BulletAndMeleeTraceAlly = Enableornot;
}

public bool BulletAndMeleeTraceAlly(int entity, int contentsMask, any iExclude)
{
#if defined ZR
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
#endif
	if(Allowbuildings_BulletAndMeleeTraceAlly)
	{
		if(b_ThisEntityIgnored[entity])
		{
			return false;
		}	
		if(i_IsABuilding[entity])
			return !(entity == iExclude);
			
		return false;
	}
	
	if(i_IsABuilding[entity])
	{
		return false;
	}
	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}

	if(GetTeam(iExclude) != GetTeam(entity))
		return false;
	else if(!b_NpcHasDied[entity])
	{
		if(GetTeam(iExclude) == GetTeam(entity))
		{
			return !(entity == iExclude);
		}
		else if (b_CantCollidie[entity] && b_CantCollidieAlly[entity]) //If both are on, then that means the npc shouldnt be invis and stuff
		{
			return false;
		}
	}
	
	//if anything else is team
	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}	
	if(b_IsARespawnroomVisualiser[entity])
	{
		return false;
	}	
	
	if(GetTeam(iExclude) == GetTeam(entity))
		return !(entity == iExclude);


	return !(entity == iExclude);
}

int Entity_to_Respect;

public void AddEntityToTraceStuckCheck(int entity)
{
	Entity_to_Respect = entity;
}
public void RemoveEntityToTraceStuckCheck(int entity)
{
	Entity_to_Respect = -1;
}

public float PathCost(INextBot bot, CNavArea area, CNavArea from_area, CNavLadder ladder, int iElevator, float length)
{
	float dist;
	if (length != 0.0) 
	{
		dist = length;
	}
	else 
	{
		float vecCenter[3], vecFromCenter[3];
		area.GetCenter(vecCenter);
		from_area.GetCenter(vecFromCenter);
		
		float vecSubtracted[3];
		SubtractVectors(vecCenter, vecFromCenter, vecSubtracted);
		
		dist = GetVectorLength(vecSubtracted);
	}
	
	/*
	float multiplier = 1.0;
	
	 very similar to CTFBot::TransientlyConsistentRandomValue 
	
	int seed = RoundToFloor(GetGameTime() * 0.1) + 1;
	seed *= area.GetID();
	seed *= bot_entidx;
	
	 huge random cost modifier [0, 100] for non-ISGIANT bots! 
	
	multiplier += (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0;
	*/
	
	float cost = dist * ((1.0 + (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0);
	
	return from_area.GetCostSoFar() + cost;
}

public bool PluginBot_Jump(int bot_entidx, float vecPos[3])
{
	if(IsEntityTowerDefense(bot_entidx)) //do not allow them to jump.
	{
		return false;
	}
	float vecNPC[3], vecJumpVel[3];
	GetEntPropVector(bot_entidx, Prop_Data, "m_vecAbsOrigin", vecNPC);
	
	float gravity = GetEntPropFloat(bot_entidx, Prop_Data, "m_flGravity");
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
	
	// How fast does the headcrab need to travel to reach the position given gravity?
	float flActualHeight = vecPos[2] - vecNPC[2];
	float height = flActualHeight;
	if ( height < 72 )
	{
		height = 72.0;
	}
	float additionalHeight = 0.0;
	
	if ( height < 35 )
	{
		additionalHeight = 50.0;
	}
	
	height += additionalHeight;
	
	float speed = SquareRoot( 2 * gravity * height );
	float time = speed / gravity;

	time += SquareRoot( (2 * additionalHeight) / gravity );
	
	// Scale the sideways velocity to get there at the right time
	SubtractVectors( vecPos, vecNPC, vecJumpVel );
	vecJumpVel[0] /= time;
	vecJumpVel[1] /= time;
	vecJumpVel[2] /= time;

	// Speed to offset gravity at the desired height.
	vecJumpVel[2] = speed;
	
	// Don't jump too far/fast.
	float flJumpSpeed = GetVectorLength(vecJumpVel);
	float flMaxSpeed = 1250.0;
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	npc.Jump();
	npc.SetVelocity(vecJumpVel);
	
	/*char JumpAnim[32];
	npc.JumpAnim(JumpAnim, sizeof(JumpAnim));
	
	if(!StrEqual(JumpAnim, ""))
	{
		npc.SetAnimation(JumpAnim);
	}
	*/
	return true;
}

stock bool IsEntityAlive(int index, bool WasValidAlready = false)
{
	if(WasValidAlready || IsValidEntity(index))
	{
		if(index > MaxClients)
		{
			if(b_ThisWasAnNpc[index]) //It is an npc
			{
				if(b_NpcHasDied[index]) //It died.
				{
					return false;
				}
			}
			return true;
		}
		else
		{
#if defined ZR
			if(!IsPlayerAlive(index) || dieingstate[index] > 0 || TeutonType[index] != TEUTON_NONE)
			{
				return false;	
			}
#else
			if(!IsPlayerAlive(index))
			{
				return false;	
			}
#endif
			else
			{
				return true;
			}
		}
	}
	else
	{
		return false;
	}
}

stock bool IsValidEnemy(int index, int enemy, bool camoDetection=false, bool target_invul = false)
{
	if(enemy <= 0)
		return false;
		
	if(IsValidEntity(enemy))
	{
		if(b_IsVehicle[enemy])
		{
			enemy = GetEntPropEnt(enemy, Prop_Data, "m_hPlayer");
			if(enemy == -1)
				return false;
		}
		

		if(b_ThisEntityIgnored[enemy])
		{
			return false;
		}
		if(index == enemy && !b_AllowSelfTarget[index])
		{
			return false;
		}
		if(b_ThisEntityIsAProjectileForUpdateContraints[enemy])
		{
			return false;
		}

		if(b_is_a_brush[enemy])
		{
			return false;
		}

		if(enemy <= MaxClients || b_ThisWasAnNpc[enemy])
		{
			if(b_ThisWasAnNpc[enemy] && b_NpcHasDied[enemy])
			{
				return false;
			}
			if(b_NpcIsInvulnerable[enemy] && !target_invul)
			{
				return false;
			}

			if(!camoDetection && b_IsCamoNPC[enemy])
			{
				return false;
			}
			
			if(b_ThisEntityIgnoredByOtherNpcsAggro[enemy])
			{
				if(GetTeam(enemy) == TFTeam_Stalkers)
				{
					if(GetTeam(index) != TFTeam_Red)
					{
						return false;
					}
				}
				else
				{
					if(index > MaxClients && !b_IsAProjectile[index])
					{
						return false;
					}	
				}
			}

#if defined RTS
			if(RTS_IsEntAlly(index, enemy))
			{
				return false;
			}
#else
			if(!b_NpcIsTeamkiller[index] && GetTeam(index) == GetTeam(enemy))
			{
#if defined RPG
				if(RPGCore_PlayerCanPVP(index, enemy) || b_NpcIsTeamkiller[index])
					return true;
				else
					return false;
#else
				return false;
#endif
			}
#endif

#if defined RPG
			if(GetTeam(index) != GetTeam(enemy))
			{
				if(OnTakeDamageRpgPartyLogic(enemy, index, GetGameTime()))
				{
					return false;
				}
			}
#endif
#if defined ZR
			if(Saga_EnemyDoomed(enemy) && index > MaxClients && !b_IsAProjectile[index])
			{
				return false;
			}
			else
#endif
			{
				return IsEntityAlive(enemy, true);
			}
		}
		else if(i_IsABuilding[enemy])
		{
#if defined ZR
			if(RaidbossIgnoreBuildingsLogic(2))
			{
				return false;
			}
			if(BuildingIsBeingCarried(enemy))
			{
				return false;
			}
#endif

#if defined RTS
			if(Object_GetResource(enemy))
			{
				return true;
			}
#endif

			if(GetTeam(index) == GetTeam(enemy))
			{
				return false;
			}
			if(b_ThisEntityIgnoredBeingCarried[enemy])
				return false;
				
			return true;
		}
	}
	return false;
}

stock bool IsValidAllyPlayer(int index, int Ally)
{
	if(IsValidClient(Ally))
	{
		if(GetTeam(index) == GetTeam(Ally))
		{
			if(b_ThisEntityIgnored[Ally])
			{
				return false;
			}
			else
			{
				return IsEntityAlive(Ally, true);
			}
		}
	}
	
	return false;
}

int GetClosestTarget_EnemiesToCollect[MAXENTITIES];
int GetClosestTarget_Enemy_Type[MAXENTITIES];

#if defined RTS
stock int GetClosestTargetRTS(int entity,
 bool IgnoreBuildings = false,
  float fldistancelimit = 99999.9,
   bool camoDetection = false,
	 int ingore_client = -1,
	 float EntityLocation[3] = {0.0,0.0,0.0},
  		float MinimumDistance = 0.0,
  		Function ExtraValidityFunction = INVALID_FUNCTION)
#else
stock int GetClosestTarget(int entity,
 bool IgnoreBuildings = false,
  float fldistancelimit = 99999.9,
   bool camoDetection=false,
    bool onlyPlayers = false,
	 int ingore_client = -1, 
	 float EntityLocation[3] = {0.0,0.0,0.0},
	  bool CanSee = false,
	   float fldistancelimitAllyNPC = 450.0,
	   bool IgnorePlayers = false,
	   bool UseVectorDistance = false,
  		float MinimumDistance = 0.0,
  		Function ExtraValidityFunction = INVALID_FUNCTION)
#endif
{
	int SearcherNpcTeam = GetTeam(entity); //do it only once lol

	if(EntityLocation[2] == 0.0)
	{
		GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
	}

	Zero(GetClosestTarget_EnemiesToCollect);
	Zero(GetClosestTarget_Enemy_Type);
	/*
		1: player
		2: player enemy npc
		3: player ally npc
		4: buildings
	*/

#if !defined RTS
	//for tower defense, we need entirely custom logic.
	//we will only override any non get vector distances, becuase those are pathing
	//anything using get vector distance means that its a ranged attack, so we leave it alone.

	#if defined ZR
	bool IsTowerdefense = false;
	if(!UseVectorDistance) 
	{
		if(IsEntityTowerDefense(entity))
		{
			IsTowerdefense = true;
		}
	}
	#endif
	
	//This code: if the npc is not on player team, make them attack players.
	//This doesnt work if they ignore players or tower defense mode is enabled.
	#if defined ZR
	if(SearcherNpcTeam != TFTeam_Red && !IgnorePlayers && !IsTowerdefense)
	#else
	if(!IgnorePlayers)
	#endif
	{
		for( int i = 1; i <= MaxClients; i++ ) 
		{
			if (IsValidClient(i) && i != ingore_client)
			{
				CClotBody npc = view_as<CClotBody>(i);
				if (GetTeam(i) != SearcherNpcTeam && !npc.m_bThisEntityIgnored && IsEntityAlive(i, true))
				{
					if(CanSee)
					{
						if(!Can_I_See_Enemy_Only(entity, i))
							continue;
					}

					if(ExtraValidityFunction != INVALID_FUNCTION)
					{
						bool WasValid;
						Call_StartFunction(null, ExtraValidityFunction);
						Call_PushCell(entity);
						Call_PushCell(i);
						Call_Finish(WasValid);

						if(!WasValid)
							continue;
					}
					int vehicle = GetEntPropEnt(i, Prop_Data, "m_hVehicle");
					if(vehicle != -1)
					{
						GetClosestTarget_AddTarget(vehicle, 1);
					}
					else if(!npc.m_bCamo || camoDetection)
					{
						GetClosestTarget_AddTarget(i, 1);
					}			
				}
			}
		}
	}
#endif	// Non-RTS

	//This is for Player sided NPCS.
	//They have pretty much infinite range when targetting other npcs!
#if defined ZR
	if(SearcherNpcTeam == TFTeam_Red && !IsTowerdefense)
#endif
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(entity_close != entity && IsValidEntity(entity_close) && entity_close != ingore_client && GetTeam(entity_close) != SearcherNpcTeam)
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
#if defined RTS
				if(!npc.m_bThisEntityIgnored && IsEntityAlive(entity_close, true) && !b_NpcIsInvulnerable[entity_close] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
					if(RTS_IsEntAlly(entity, entity_close))
						continue;
#else
				if(!npc.m_bThisEntityIgnored && IsEntityAlive(entity_close, true) && !b_NpcIsInvulnerable[entity_close] && !onlyPlayers && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
#endif

#if defined ZR
					if(CanSee)
					{
						if(!Can_I_See_Enemy_Only(entity, entity_close))
							continue;
					}
#endif

					if(ExtraValidityFunction != INVALID_FUNCTION)
					{
						bool WasValid;
						Call_StartFunction(null, ExtraValidityFunction);
						Call_PushCell(entity);
						Call_PushCell(entity_close);
						Call_Finish(WasValid);

						if(!WasValid)
							continue;
					}

					if(!npc.m_bCamo || camoDetection)
					{
						GetClosestTarget_AddTarget(entity_close, 2);
					}
				}
			}
		}
	}

#if defined ZR
	/*
		The npc is not on the player team, it will target players first
		other enemy npcs are preffered only when too close.
	*/
	if(SearcherNpcTeam != TFTeam_Red && !IgnorePlayers)
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(entity_close != entity && IsValidEntity(entity_close) && entity_close != ingore_client && GetTeam(entity_close) != GetTeam(entity))
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
				if(!npc.m_bThisEntityIgnored && IsEntityAlive(entity_close, true) && !b_NpcIsInvulnerable[entity_close] && !onlyPlayers && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
					if(IsTowerdefense)
					{
						if(i_NpcInternalId[entity_close] == VIPBuilding_ID() && !IsValidEnemy(entity, view_as<CClotBody>(entity).m_iTarget, true, true))
						{
							return entity_close; //we found a vip building, go after it.
						}
					}
					
					if(CanSee)
					{
						if(!Can_I_See_Enemy_Only(entity, entity_close))
							continue;
					}
					if(ExtraValidityFunction != INVALID_FUNCTION)
					{
						bool WasValid;
						Call_StartFunction(null, ExtraValidityFunction);
						Call_PushCell(entity);
						Call_PushCell(entity_close);
						Call_Finish(WasValid);

						if(!WasValid)
							continue;
					}
					if (!npc.m_bCamo || camoDetection)
					{
						if(GetTeam(entity_close) == TFTeam_Red)
							GetClosestTarget_AddTarget(entity_close, 3);
						else
							GetClosestTarget_AddTarget(entity_close, 2);
					}
				}
			}
		}
	}
	if(IsTowerdefense)
	{
		CClotBody npc = view_as<CClotBody>(entity);
		return npc.m_iTarget;
	}
#endif

	//If the team searcher is not on red, target buildings, buildings can only be on the player team.
#if defined ZR
	if(SearcherNpcTeam != TFTeam_Red && !RaidbossIgnoreBuildingsLogic(1) && !IgnoreBuildings && ((view_as<CClotBody>(entity).m_iTarget > 0 && i_IsABuilding[view_as<CClotBody>(entity).m_iTarget]) || IgnorePlayers)) //If the previous target was a building, then we try to find another, otherwise we will only go for collisions.
#elseif defined RTS
	if(!IgnoreBuildings)
#else
	if(!IgnoreBuildings && ((view_as<CClotBody>(entity).m_iTarget > 0 && i_IsABuilding[view_as<CClotBody>(entity).m_iTarget]) || IgnorePlayers))
#endif
	{
		int entity_close = -1;
		while((entity_close=FindEntityByClassname(entity_close, "obj_*")) != -1) //BUILDINGS!
		{
			if(entity_close != entity && entity_close != ingore_client)
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
				if(GetTeam(entity_close) != SearcherNpcTeam && !b_ThisEntityIgnored[entity_close] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //make sure it doesnt target buildings that are picked up and special cases with special building types that arent ment to be targeted
				{
#if defined RTS
					if(ExtraValidityFunction == INVALID_FUNCTION)
					{
						// Ignore resources and allies
						if(Object_GetResource(entity_close) ||
							RTS_IsEntAlly(entity, entity_close))
							continue;
					}
					else
					{
						// Ignore non-resource allies
						if(!Object_GetResource(entity_close) && RTS_IsEntAlly(entity, entity_close))
							continue;
					}
#endif

#if !defined RTS
					if(CanSee)
					{
						if(!Can_I_See_Enemy_Only(entity, entity_close))
							continue;
					}
#endif

					if(ExtraValidityFunction != INVALID_FUNCTION)
					{
						bool WasValid;
						Call_StartFunction(null, ExtraValidityFunction);
						Call_PushCell(entity);
						Call_PushCell(entity_close);
						Call_Finish(WasValid);

						if(!WasValid)
							continue;
					}
					if (!npc.m_bCamo || camoDetection)
					{
						GetClosestTarget_AddTarget(entity_close, 4);
					}
				}
			}
		}
	}

#if defined RTS
	return GetClosestTarget_Internal(entity, fldistancelimit, EntityLocation, MinimumDistance);
#else
	return GetClosestTarget_Internal(entity, fldistancelimit, fldistancelimitAllyNPC, EntityLocation, UseVectorDistance, MinimumDistance);
#endif
}

void GetClosestTarget_AddTarget(int entity, int type)
{
	for (int i = 0; i < MAXENTITIES; i++)
	{
		if (GetClosestTarget_EnemiesToCollect[i] == 0)
		{
			GetClosestTarget_EnemiesToCollect[i] = entity;
			GetClosestTarget_Enemy_Type[entity] = type;
			break; //same as break;
		}
	}	
}

void GetClosestTarget_ResetAllTargets()
{
	Zero(GetClosestTarget_EnemiesToCollect);
	Zero(GetClosestTarget_Enemy_Type);
}

#if defined RTS
stock int GetClosestTarget_Internal(int entity, float fldistancelimit, const float EntityLocation[3], float MinimumDistance)
#else
int GetClosestTarget_Internal(int entity, float fldistancelimit, float fldistancelimitAllyNPC, const float EntityLocation[3], bool UseVectorDistance, float MinimumDistance)
#endif
{
	int ClosestTarget = -1; 

#if !defined RTS
	if(!b_NpcHasDied[entity] && !UseVectorDistance)
	{
		f_DelayComputingOfPath[entity] = 0.0;
		//Reset Timer, let them repath!
		CBaseNPC baseNPC = view_as<CClotBody>(entity).GetBaseNPC();
		if(baseNPC == INVALID_NPC)
		{
			PrintToServer("FAILED NPC.");
			return -1;
		}
		
		CNavArea area = TheNavMesh.GetNavArea(EntityLocation, 100.0);
		if(area == NULL_AREA)
		{
			area = TheNavMesh.GetNearestNavArea(EntityLocation, _, _, _, _, _);
		}

		static CNavArea targetNav[MAXENTITIES];
		static float targetPos[MAXENTITIES][3];
		for(int i; i < MAXENTITIES; i++)
		{
			if(GetClosestTarget_EnemiesToCollect[i] <= 0)
				break;

			GetEntPropVector(GetClosestTarget_EnemiesToCollect[i], Prop_Data, "m_vecOrigin", targetPos[i]);
			CNavArea NavAreaUnder = TheNavMesh.GetNavArea(targetPos[i], 100.0);

			if(NavAreaUnder == NULL_AREA)
			{
				NavAreaUnder = TheNavMesh.GetNearestNavArea(targetPos[i], _, _, _, _, _);
			}
			targetNav[i] = NavAreaUnder;
		}

		float maxDistance = fldistancelimit > fldistancelimitAllyNPC ? fldistancelimit : fldistancelimitAllyNPC;
		SurroundingAreasCollector iterator = TheNavMesh.CollectSurroundingAreas(area, 99999.9, 2000.0/*baseNPC.flStepSize*/, baseNPC.flDeathDropHeight);
		
		CNavArea closeNav = NULL_AREA;
		float closeDist = maxDistance;
		
		int length = iterator.Count();
		for(int i; i < length; i++)
		{
			CNavArea area2 = iterator.Get(i);
			float dist = -5.5;
			
			// Find if any targets are standing on here
			for(int a; a < MAXENTITIES; a++)
			{
				if(GetClosestTarget_EnemiesToCollect[a] <= 0)
					break;
				
				if(targetNav[a] == area2)
				{
					// See if it's the closest nav
					if(dist == -5.5)
						dist = area2.GetCostSoFar();
						
					if(dist == 0.0)
						dist = GetVectorDistance(targetPos[a], EntityLocation, false);


				//	PrintToChatAll("%f > %f", dist, fldistancelimit);
					if(GetClosestTarget_Enemy_Type[GetClosestTarget_EnemiesToCollect[a]] > 2)	// Distance limit
					{
						if(dist > fldistancelimitAllyNPC)
						{
							continue;
						}
					}
					else if(dist > fldistancelimit)
					{
						continue;
					}

					if(dist < closeDist)
					{
						closeNav = area2;
						closeDist = dist;
					}
					break;
				}
			}
		}

		delete iterator;
		
		if(closeNav != NULL_AREA)	// Found our closest nav, find the closest enemy on this nav
		{
			closeDist = maxDistance * maxDistance;
			//float minDistance1 = fldistancelimit * fldistancelimit;
			//float minDistance2 = fldistancelimitAllyNPC * fldistancelimitAllyNPC;

			for(int i; i < MAXENTITIES; i++)
			{
				if(GetClosestTarget_EnemiesToCollect[i] <= 0)
					break;
				
				if(targetNav[i] != closeNav)	// In this close nav
					continue;

				float dist = GetVectorDistance(targetPos[i], EntityLocation, true);
				if(dist > closeDist)	// Closest entity
					continue;

				/*if(GetClosestTarget_Enemy_Type[i] > 2)	// Distance limit
				{
					if(dist > minDistance2)
						continue;
				}
				else if(dist > minDistance1)
				{
					continue;
				}*/
				//todo: readd distance limit eventually.
				// Note: Currently will target NPCs & Buildings with in the same nav as players
				// TODO: Make a better distance check so it doesn't stall out if a solo NPC is in the closest nav

				closeDist = dist;
				ClosestTarget = GetClosestTarget_EnemiesToCollect[i];
			}
		}
	}
	else
#endif	// Non-RTS
	{
#if defined RTS
		float distance_limit = fldistancelimit * fldistancelimit;
#endif

		float TargetDistance = 0.0;
		int target;
		static float TargetLocation[3]; 
		for (int i = 0; i < MAXENTITIES; i++)
		{
			if (GetClosestTarget_EnemiesToCollect[i] == 0)
			{
				break; //none left.
			}
			target = GetClosestTarget_EnemiesToCollect[i];
			/*
			static float TargetLocation[3]; 
			GetEntPropVector( target, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
							
			static float distance;
			distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
			*/

			GetEntPropVector( target, Prop_Data, "m_vecOrigin", TargetLocation ); //do not use abs, some entities do not have abs.
			float distanceVector = GetVectorDistance( EntityLocation, TargetLocation, true ); 

			/*
				1: player
				2: player enemy npc
				3: player ally npc
				4: buildings
			*/

#if !defined RTS
			float distance_limit = fldistancelimit;
			switch(GetClosestTarget_Enemy_Type[GetClosestTarget_EnemiesToCollect[i]])
			{
				case 1:
				{
					distance_limit = fldistancelimit;
				}
				case 2:
				{
					distance_limit = fldistancelimit;
				}
				case 3:
				{
					distance_limit = fldistancelimitAllyNPC;
				}
				case 4:
				{
					distance_limit = fldistancelimitAllyNPC;
				}
				default:
				{
					distance_limit = 99999.9;
				}
			}

			distance_limit *= distance_limit;
#endif	// Non-RTS

			if(distanceVector < distance_limit && MinimumDistance < distanceVector)
			{
				if( TargetDistance ) 
				{
					if( distanceVector < TargetDistance ) 
					{
						ClosestTarget = target; 
						TargetDistance = distanceVector;		  
					}
				}
				else 
				{
					ClosestTarget = target; 
					TargetDistance = distanceVector;
				}
			}
		}		
	}


	GetClosestTarget_ResetAllTargets();
	return ClosestTarget;
}

stock int GetClosestAllyPlayer(int entity, bool Onlyplayers = false)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i))
		{
			CClotBody npc = view_as<CClotBody>(i);
			if (GetTeam(i)== GetTeam(entity) && !npc.m_bThisEntityIgnored && IsEntityAlive(i, true) && GetEntPropEnt(i, Prop_Data, "m_hVehicle") == -1) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetClientAbsOrigin( i, TargetLocation ); 
				
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( TargetDistance ) 
				{
					if( distance < TargetDistance ) 
					{
						ClosestTarget = i; 
						TargetDistance = distance;		  
					}
				} 
				else 
				{
					ClosestTarget = i; 
					TargetDistance = distance;
				}					
			}
		}
	}
	return ClosestTarget; 
}

stock bool IsSpaceOccupiedWorldOnly(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace;
	if(IsValidClient(entity) || i_IsABuilding[entity])
	{	
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayHitWorldOnly, entity);
	}
#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID | MASK_PLAYERSOLID, TraceRayHitWorldOnly, entity);
	}
#endif
	else
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitWorldOnly, entity);
	}
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedWorldandBuildingsOnly(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace;
	if(IsValidClient(entity) || i_IsABuilding[entity])
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayHitWorldAndBuildingsOnly, entity);
	}
#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID | MASK_PLAYERSOLID, TraceRayHitWorldAndBuildingsOnly, entity);
	}
#endif
	else
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitWorldAndBuildingsOnly, entity);
	}
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace;
	if(IsValidClient(entity) || i_IsABuilding[entity])
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayDontHitPlayersOrEntityCombat, entity);
	}
#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID | MASK_PLAYERSOLID, TraceRayDontHitPlayersOrEntityCombat, entity);
	}
#endif
	else
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayDontHitPlayersOrEntityCombat, entity);
	}
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedDontIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace;
	if(IsValidClient(entity) || i_IsABuilding[entity])
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayHitPlayersOnly, entity);	
	}
#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID | MASK_PLAYERSOLID, TraceRayHitPlayersOnly, entity);	
	}
#endif
	else
	{
		hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitPlayersOnly, entity);
	}
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedRTSBuilding(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayDontHitRTSAlliedNpc, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock int IsSpaceOccupiedOnlyPlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitPlayersOnly, entity);
//	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	if(ref <= 0)
		return 0;
		
	return ref;
}

public bool TraceRayHitPlayers(int entity,int mask,any data)
{
	if (entity == 0) return true;
	
	if (entity <= MaxClients) return true;
	
	return false;
}



public bool TraceRayDontHitRTSAlliedNpc(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}

	if(entity > 0 && entity <= MaxClients) 
	{
		return false;
	}

	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	
	if(!b_NpcHasDied[entity])
	{
		if(b_CollidesWithEachother[entity])
		{
			return true;
		}
		return false;
	}
	
	//if anything else is team
	
	if(GetTeam(data) == GetTeam(entity))
		return false;
	
	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}
	else if(b_IsARespawnroomVisualiser[entity])
	{
		return true;//They blockin me and not on same team, otherwsie top filter
	}
	
	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}
	
	if(entity == Entity_to_Respect)
	{
		return false;
	}
	
	return true;
}

public bool TraceRayCanSeeAllySpecific(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}

	if(entity == data)
	{
		return false;
	}

	if(entity == Entity_to_Respect)
	{
		return true;
	}

	if(entity > 0 && entity <= MaxClients) 
	{
		return false;
	}

	if(b_ThisEntityIsAProjectileForUpdateContraints[entity])
	{
		return false;
	}
	
	if(b_is_a_brush[entity])
	{
		return true;//They blockin me
	}
	else if(b_IsARespawnroomVisualiser[entity])
	{
		return true;//They blockin me and not on same team, otherwsie top filter
	}
	
	if(b_ThisEntityIgnored[entity])
	{
		return false;
	}
	
	if(entity == Entity_to_Respect)
	{
		return true;
	}
	
	return false;
}


public Action Timer_CheckStuckOutsideMap(Handle cut_timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		static float flMyPos_Bounds[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flMyPos_Bounds);
		flMyPos_Bounds[2] += 25.0;
		if(TR_PointOutsideWorld(flMyPos_Bounds))
		{
			LogError("Enemy NPC somehow got out of the map..., Cordinates : {%f,%f,%f}", flMyPos_Bounds[0],flMyPos_Bounds[1],flMyPos_Bounds[2]);
			RequestFrame(KillNpc, EntIndexToEntRef(entity));
		}
	}
	return Plugin_Stop;
}

float f_CheckIfStuckPlayerDelay[MAXENTITIES];
float f_QuickReviveHealing[MAXENTITIES];
public void NpcBaseThinkPost(int iNPC)
{
	CBaseCombatCharacter(iNPC).SetNextThink(GetGameTime());
	SetEntPropFloat(iNPC, Prop_Data, "m_flSimulationTime",GetGameTime());
}
void NpcDrawWorldLogic(int entity)
{
	if(b_IsEntityNeverTranmitted[entity])
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_DONTSEND));
	}
#if defined ZR
	else if(IsValidEntity(view_as<CClotBody>(entity).m_iTeamGlow))
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_ALWAYS));
	}
#endif
#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_ALWAYS));
	}
#endif
	else if(b_IsEntityAlwaysTranmitted[entity] || b_thisNpcIsABoss[entity])
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_ALWAYS));
	}
#if defined ZR
	else if(b_thisNpcHasAnOutline[entity])
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_ALWAYS));
	}
	else if (!b_NpcHasDied[entity] && Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_ALWAYS));
	}
#endif
	else
	{
		SetEdictFlags(entity, SetEntityTransmitState(entity, FL_EDICT_PVSCHECK));
	}
}

#if defined ZR
void GiveNpcOutLineLastOrBoss(int entity, bool add)
{
	CClotBody npc = view_as<CClotBody>(entity);
	if(b_NpcHasDied[entity])
	{
		return;
	}
	if(b_NoHealthbar[npc.index])
	{
		if(IsValidEntity(npc.m_iTeamGlow)) 
		{
			RemoveEntity(npc.m_iTeamGlow);
		}	
		return;	
	}
	//they have a custom outline.
	//if !npc.m_bTeamGlowDefault is off, then that means that they have an outline that isnt set with this.
	if((add && IsValidEntity(npc.m_iTeamGlow)) || !npc.m_bTeamGlowDefault)
	{	
		return;
	}
	if(add)
	{
		if(!IsValidEntity(npc.m_iTeamGlow))
		{
			npc.m_iTeamGlow = TF2_CreateGlow(entity);
			
			SetVariantColor(view_as<int>({125, 200, 255, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		}
	}
	else
	{
		if(IsValidEntity(npc.m_iTeamGlow)) 
		{
			RemoveEntity(npc.m_iTeamGlow);
		}		
	}

}
#endif


public void NpcBaseThink(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);

//	static float FakeRotationFix[3];
//	npc.FaceTowards(FakeRotationFix, 1.0);
	//issue: There is a bug where particles dont get updated to the newest position, this is a temp fix
	//wait for kennzer to fix this, in the meantime, alter their rotation just a slight bit to fix it 
	if(b_NpcHasDied[iNPC])
	{
		if(npc.GetPathFollower().IsValid())
		{
			npc.GetPathFollower().Invalidate(); //Remove its current path
		}
		npc.SetProp(Prop_Data, "zr_pPath", -1);
		RemoveEntityToLagCompList(iNPC);

		if(h_NpcCollissionHookType[iNPC] != 0)
		{
			if(!DHookRemoveHookID(h_NpcCollissionHookType[iNPC]))
			{
				PrintToConsoleAll("Somehow Failed to unhook h_NpcCollissionHookType");
			}
		}
		if(h_NpcSolidHookType[iNPC] != 0)
		{
			if(!DHookRemoveHookID(h_NpcSolidHookType[iNPC]))
			{
				PrintToConsoleAll("Somehow Failed to unhook h_NpcSolidHookType");
			}
		}
		h_NpcCollissionHookType[iNPC] = 0;
		h_NpcSolidHookType[iNPC] = 0;
		RemoveFromNpcPathList(npc);
		SDKUnhook(iNPC, SDKHook_Think, NpcBaseThink);
		return;
	}
	SaveLastValidPositionEntity(iNPC);
	NpcSetGravity(npc,iNPC);
	
	if(f_KnockbackPullDuration[iNPC] > GetGameTime())
	{
		npc.GetBaseNPC().flGravity = 0.0;
	}

	if(f_TextEntityDelay[iNPC] < GetGameTime())
	{
		//this is just as a temp fix, remove whenver.
		SetEntityMoveType(iNPC, MOVETYPE_CUSTOM);
		NpcDrawWorldLogic(iNPC);
		f_TextEntityDelay[iNPC] = GetGameTime() + GetRandomFloat(0.25, 0.35);
		Npc_DebuffWorldTextUpdate(npc);
		IsEntityInvincible_Shield(iNPC);
#if defined RTS
		RTS_NPCHealthBar(npc);
#elseif defined ZR
		Npc_BossHealthBar(npc);
#endif
	}

#if defined ZR
	if(i_CurrentEquippedPerk[iNPC] == 1 && f_QuickReviveHealing[iNPC] < GetGameTime())
	{
		f_QuickReviveHealing[iNPC] = GetGameTime() + 0.1;

		int HealingAmount = (GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 1000);
	
		if(b_thisNpcIsARaid[iNPC])
		{
			HealingAmount /= 10;
		}
		else if(b_thisNpcIsABoss[iNPC])
		{
			HealingAmount /= 2;
		}
		if(HealingAmount < 1)
		{
			HealingAmount = 1;
		}

		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + HealingAmount);
			if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			}
		}
	}
#endif
#if defined RPG
	if(i_HpRegenInBattle[iNPC] > 1 && f_QuickReviveHealing[iNPC] < GetGameTime() && !f_TimeFrozenStill[iNPC])
	{
		f_QuickReviveHealing[iNPC] = GetGameTime() + 0.25;

		HealEntityGlobal(iNPC, iNPC, float(i_HpRegenInBattle[iNPC]), 1.0, 0.0, HEAL_SELFHEAL);
		RPGNpc_UpdateHpHud(iNPC);
	}
#endif

	//Is the NPC out of bounds, or inside a player
	NpcOutOfBounds(npc,iNPC);

	Function func = func_NPCThink[iNPC];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(iNPC);
		Call_Finish();
	}
	//is the NPC inside an object
	NpcStuckInSomething(npc, iNPC);

	//is npc somehow outside any nav mesh
	NpcStuckInSomethingOutOfBonunds(npc, iNPC);
}

public void NpcSetGravity(CClotBody npc, int iNPC)
{
#if defined ZR || defined RPG
	npc.GetBaseNPC().flGravity = (Npc_Is_Targeted_In_Air(iNPC) || b_NoGravity[iNPC]) ? 0.0 : 800.0;
#else
	npc.GetBaseNPC().flGravity = b_NoGravity[iNPC] ? 0.0 : 800.0;
#endif
}
public void NpcOutOfBounds(CClotBody npc, int iNPC)
{
#if defined RTS
	if(!i_NpcIsABuilding[iNPC])
#else
	if(!IsEntityTowerDefense(iNPC) && GetTeam(iNPC) != TFTeam_Red && !i_NpcIsABuilding[iNPC])
#endif
	{
		static float flMyPos[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		float GameTime = GetGameTime();
		//If NPCs some how get out of bounds
		if(f_StuckOutOfBoundsCheck[iNPC] < GameTime)
		{
			static float flMyPos_Bounds[3];
			flMyPos_Bounds = flMyPos;
			flMyPos_Bounds[2] += 25.0;
			f_StuckOutOfBoundsCheck[iNPC] = GameTime + 10.0;
			if(TR_PointOutsideWorld(flMyPos))
			{
				CreateTimer(1.0, Timer_CheckStuckOutsideMap, EntIndexToEntRef(iNPC), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		if(!b_DoNotUnStuck[iNPC] && f_CheckIfStuckPlayerDelay[iNPC] < GameTime)
		{
			f_CheckIfStuckPlayerDelay[iNPC] = GameTime + 0.5;
			//This is a tempomary fix. find a better one for players getting stuck.
			static float hullcheckmaxs_Player[3];
			static float hullcheckmins_Player[3];
			if(b_IsGiant[iNPC])
			{
				hullcheckmaxs_Player = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins_Player = view_as<float>( { -30.0, -30.0, 0.0 } );	
			}
			else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
			{
				hullcheckmaxs_Player[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
				hullcheckmaxs_Player[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
				hullcheckmaxs_Player[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

				hullcheckmins_Player[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
				hullcheckmins_Player[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
				hullcheckmins_Player[2] = 0.0;
			}
			else
			{
				hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );			
			}
		
			int Hit_player = IsSpaceOccupiedOnlyPlayers(flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, iNPC);
			if (Hit_player) //The boss will start to merge with player, STOP!
			{
				Npc_Teleport_Safe(iNPC, flMyPos, hullcheckmins_Player, hullcheckmaxs_Player);

				//first recorded instance of getting stuck after 2 seconds of nnot being stuck.
				if(f_AntiStuckPhaseThroughFirstCheck[Hit_player] < GetGameTime())
				{
					f_AntiStuckPhaseThroughFirstCheck[Hit_player] = GetGameTime() + 2.0;
				}
				else if(f_AntiStuckPhaseThroughFirstCheck[Hit_player] < GetGameTime() + 1.0)
				{
					//if still stuck after 1 second...
					f_AntiStuckPhaseThrough[Hit_player] = GetGameTime() + 1.0;
					//give them 2 seconds to unstuck themselves
				}
			}
			//This is a tempomary fix. find a better one for players getting stuck.
		}
	}
#if defined ZR
	else if(GetTeam(iNPC) == TFTeam_Red && !i_NpcIsABuilding[iNPC])
	{
		float GameTime = GetGameTime();
		if(f_StuckOutOfBoundsCheck[iNPC] < GameTime)
		{
			f_StuckOutOfBoundsCheck[iNPC] = GameTime + 10.0;
			//If NPCs some how get out of bounds
			static float flMyPos[3];
			GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
			static float flMyPos_Bounds[3];
			flMyPos_Bounds = flMyPos;
			flMyPos_Bounds[2] += 1.0;
			static float hullcheckmaxs_Player[3];
			static float hullcheckmins_Player[3];
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	
			bool OutOfBounds = false;
			if(IsBoxHazard(flMyPos_Bounds, hullcheckmins_Player, hullcheckmaxs_Player))
			{
				OutOfBounds = true;
			}
			if(TR_PointOutsideWorld(flMyPos_Bounds))
			{
				OutOfBounds = true;
			}
			if(OutOfBounds)
			{
			//	LogError("Allied NPC somehow got out of the map..., Cordinates : {%f,%f,%f}", flMyPos_Bounds[0],flMyPos_Bounds[1],flMyPos_Bounds[2]);
#if defined ZR
				int target = 0;
				for(int i=1; i<=MaxClients; i++)
				{
					if(IsClientInGame(i))
					{
						if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE)
						{
							target = i;
							break;
						}
					}
				}
				
				if(target)
				{
					float pos[3], ang[3];
					GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos);
					GetEntPropVector(target, Prop_Data, "m_angRotation", ang);
					ang[2] = 0.0;
					TeleportEntity(iNPC, pos, ang, NULL_VECTOR);
				}
				else
#endif
				{
					RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
				}
			}
		}
	}
#endif	// Non-RTS
}

public void NpcStuckInSomethingOutOfBonunds(CClotBody npc, int iNPC)
{
	if (!b_DoNotUnStuck[iNPC])
	{
		if(i_FailedTriesUnstuck[iNPC][0] == 0)
		{
			if(f_UnstuckTimerCheck[iNPC][0] < GetGameTime())
			{
				f_UnstuckTimerCheck[iNPC][0] = GetGameTime() + GetRandomFloat(2.8, 3.5); 
				//every 3 seconds we shall do an emenergency check
			}
			else
			{
				return;
			}
		}
		else
		{
			if(!(i_FailedTriesUnstuck[iNPC][0] % 10))
			{
				i_FailedTriesUnstuck[iNPC][0] += 1;
				return;
			}
		}

		static float flMyPos[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		flMyPos[2] += 35.0;
		CNavArea area = TheNavMesh.GetNavArea(flMyPos, 200.0);
		int PassCheck = 0;
		if(area != NULL_AREA)
		{
			int NavAttribs = area.GetAttributes();
			if(NavAttribs & NAV_MESH_DONT_HIDE)
			{
				PassCheck = 2;
			}
		}
		else
		{
			PassCheck = 1;
		}
		if(PassCheck)
		{
			i_FailedTriesUnstuck[iNPC][0] += 1;
			if(i_FailedTriesUnstuck[iNPC][0] < (TickrateModifyInt * 5)) //we will wait about 5 seconds
			{
				return;
			}
			i_FailedTriesUnstuck[iNPC][0] = 0;
			flMyPos[2] -= 35.0;
			area = TheNavMesh.GetNearestNavArea(flMyPos, false, 55.0, false, true);
			if(area != NULL_AREA && PassCheck == 1)
			{
				return;
			}
			UnstuckStuckNpc(npc, iNPC);
		}
		else
		{
			i_FailedTriesUnstuck[iNPC][0] = 0;
		}
	}
}
public void NpcStuckInSomething(CClotBody npc, int iNPC)
{
	if (!b_DoNotUnStuck[iNPC] && f_DoNotUnstuckDuration[iNPC][1] < GetGameTime())
	{
		if(i_FailedTriesUnstuck[iNPC][1] == 0)
		{
			if (npc.IsOnGround())
			{
				if(f_UnstuckTimerCheck[iNPC][1] < GetGameTime())
				{
					f_UnstuckTimerCheck[iNPC][1] = GetGameTime() + GetRandomFloat(2.8, 3.5); 
					//every 3 seconds we shall do an emenergency check
				}
				else
				{
					return;
				}
			}
		}
		else
		{
			if(!(i_FailedTriesUnstuck[iNPC][1] % 10))
			{
				i_FailedTriesUnstuck[iNPC][1] += 1;
				return;
			}
		}
		static float flMyPos[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
		f_UnstuckTimerCheck[iNPC][1] = GetGameTime() + GetRandomFloat(2.8, 3.5);  //they were in the air regardless, add time.
		static float hullcheckmaxs[3];
		static float hullcheckmins[3];
		if(b_IsGiant[iNPC])
		{
		 	hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}
		else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
		{
			hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
			hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
			hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

			hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
			hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
			hullcheckmins[2] = 0.0;	
		}
		else
		{
			hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
		}
		hullcheckmins[2] += 17.0;
		if (npc.IsOnGround()) //npcs can slightly clip if on ground due to giants massive height for example.
		{
			hullcheckmaxs[2] *= 0.5;
		}
		else
		{
			//Floating point imprecision.
			hullcheckmaxs[0] += 1.0;
			hullcheckmaxs[1] += 1.0;
			hullcheckmaxs[2] += 1.0;

			hullcheckmins[0] -= 1.0;
			hullcheckmins[1] -= 1.0;
			hullcheckmins[2] -= 1.0;			
		}

		if(IsSpaceOccupiedWorldOnly(flMyPos, hullcheckmins, hullcheckmaxs, iNPC))
		{
			if(!Npc_Teleport_Safe(npc.index, flMyPos, hullcheckmins, hullcheckmaxs))
			{
				i_FailedTriesUnstuck[iNPC][1] += 1;
				if(i_FailedTriesUnstuck[iNPC][1] < TickrateModifyInt) //we will wait about a second
				{
					return;
				}
				i_FailedTriesUnstuck[iNPC][1] = 0;
				//they are still stuck after so many tries and a second, teleport to safe location
				//delete velocity.
				UnstuckStuckNpc(npc, iNPC);
			}
		}
		else
		{
			i_FailedTriesUnstuck[iNPC][1] = 0;
		}
	}	
}
void UnstuckStuckNpc(CClotBody npc, int iNPC)
{
	static float vec3Origin[3];
	npc.SetVelocity(vec3Origin);
#if defined ZR
	if(GetTeam(npc.index) != TFTeam_Red)
	{
		//This was an enemy.
		if(Rogue_Mode())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
			return;
		}
		int Spawner_entity = GetRandomActiveSpawner();
		if(IsValidEntity(Spawner_entity))
		{
			float pos[3];
			float ang[3];
			GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			TeleportEntity(iNPC, pos, ang, NULL_VECTOR);
			b_npcspawnprotection[iNPC] = true;
			CreateTimer(3.0, Remove_Spawn_Protection, EntIndexToEntRef(iNPC), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		//This is an ally.
		int target = 0;
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE)
				{
					target = i;
					break;
				}
			}
		}
		
		if(target)
		{
			float pos[3], ang[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", pos);
			GetEntPropVector(target, Prop_Data, "m_angRotation", ang);
			ang[2] = 0.0;
			TeleportEntity(iNPC, pos, ang, NULL_VECTOR);
		}
		else
		{
			RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
		}
	}
#endif
}
float f3_KnockbackToTake[MAXENTITIES][3];

stock void Custom_Knockback(int attacker,
 int enemy,
  float knockback,
   bool ignore_attribute = false,
    bool override = false,
	 bool work_on_entity = false,
	 float PullDuration = 0.0,
	 bool RecieveInfo = false,
	 float RecievePullInfo[3] = {0.0,0.0,0.0})
{
	if(enemy > 0 && !b_NoKnockbackFromSources[enemy] && !IsEntityTowerDefense(enemy))
	{
		float vAngles[3], vDirection[3];

		if(attacker <= MaxClients)	
		{
			if(PullDuration == 0.0)
			{
				GetClientEyeAngles(attacker, vAngles);
				if(vAngles[0] < -40.0) //if they look up too much, we set it.
				{
					vAngles[0] = -40.0;
				}
				else if(vAngles[0] > -5.0) //if they look down too much, we set it.
				{
					vAngles[0] = -5.0;
				}
			}
			else
			{
				float vector1[3];
				float pos1[3];
				float pos2[3];
				GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", pos1); 
				GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", pos2);
				pos2[2] += 50.0; 
				//so thery always should be pulled abit...
				SubtractVectors(pos1, pos2, vector1);
				NormalizeVector(vector1, vector1);
				GetVectorAngles(vector1, vAngles); 
			}
		}
		else
		{
			GetEntPropVector(attacker, Prop_Data, "m_angRotation", vAngles);
			vAngles[0] = -45.0;
		}
		
		if(enemy <= MaxClients)	
		{
			if (!(GetEntityFlags(enemy) & FL_ONGROUND))
			{
				knockback *= 0.85; //Dont do as much knockback if they are in the air
				if(attacker > MaxClients) //npcs have no angles up, help em.
				{
					if(PullDuration == 0.0)
					{
						vAngles[0] = -30.0;
					}
					else
					{
						vAngles[0] = 30.0;// ??
					}
				}
				
			}
		}
		else
		{
			CClotBody npc = view_as<CClotBody>(enemy);
			if (!npc.IsOnGround())
			{
				knockback *= 0.85; //Dont do as much knockback if they are in the air
				if(attacker > MaxClients) //npcs have no angles up, help em.
				{
					if(PullDuration == 0.0)
					{
						vAngles[0] = -30.0;
					}
				}
			}
		}	
		//dont knock enemies up that high if they are already in the air.									
										
		GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
			
#if !defined RTS
		if(enemy <= MaxClients && !ignore_attribute && !work_on_entity)
		{
			float Attribute_Knockback = Attributes_FindOnPlayerZR(enemy, 252, true, 1.0);	
			
			knockback *= Attribute_Knockback;
		}
#endif
		
		knockback *= 0.75; //oops, too much knockback now!


		ScaleVector(vDirection, knockback);

		RecievePullInfo = vDirection;
		
		if(RecieveInfo)
		{
			return;
		}
		if(!override && enemy <= MaxClients)
		{
			float newVel[3];
			
			newVel[0] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[0]");
			newVel[1] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[1]");
			newVel[2] = GetEntPropFloat(enemy, Prop_Send, "m_vecVelocity[2]");
							
			for (int i = 0; i < 3; i++)
			{
				vDirection[i] += newVel[i];
			}
		}		
		if(!b_NpcHasDied[enemy])	
		{
			if(PullDuration > 0.0)
			{
				if(f_KnockbackPullDuration[enemy] < GetGameTime() + PullDuration)
				{
					f_KnockbackPullDuration[enemy] = GetGameTime() + PullDuration;
					//this is alonger pull duration, override.
				}
				SDKUnhook(enemy, SDKHook_Think, NpcJumpThink); //incase another one was in progress.
				//we do a push, yet they are being pulled, this calls for uhhh idk, what is bigger? we do this.
				f3_KnockbackToTake[enemy] = vDirection;
				i_PullTowardsTarget[enemy] = attacker;
				f_PullStrength[enemy] = knockback;
				//it needs to be on think, otherwise it wont work sometimes.
				SDKHook(enemy, SDKHook_Think, NpcJumpThink);	
			}
			else
			{
				SDKUnhook(enemy, SDKHook_Think, NpcJumpThink); //incase another one was in progress.
				//We'll make push override pulls.
				f_KnockbackPullDuration[enemy] = 0.0;
				i_PullTowardsTarget[enemy] = 0;
				f3_KnockbackToTake[enemy] = vDirection;
				//it needs to be on think, otherwise it wont work sometimes.	

				SDKHook(enemy, SDKHook_Think, NpcJumpThink);	
			}
		}		
		else
		{
			TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, vDirection); 
		}						
	}
}
//it needs to be on think, otherwise it wont work sometimes.
public void NpcJumpThink(int iNPC)
{	
	if(IsValidEntity(iNPC) && !b_NpcHasDied[iNPC])
	{
		CClotBody npc = view_as<CClotBody>(iNPC);

		if(f_KnockbackPullDuration[iNPC] < GetGameTime())
		{
			if(i_PullTowardsTarget[iNPC] == 0)
			{
				f_DoNotUnstuckDuration[iNPC] = GetGameTime() + 0.05;
				npc.GetLocomotionInterface().Jump();
				npc.SetVelocity(f3_KnockbackToTake[iNPC]);
			}
		}
		else
		{
			//the npc is being pulled, do different logic.
			int puller = i_PullTowardsTarget[iNPC];
			if(IsValidEntity(puller))
			{
				float Jump_1_frame[3];

				Custom_Knockback(puller,
				iNPC,
				f_PullStrength[iNPC],
				false,
				false,
				true,
				0.1,
				true,
				Jump_1_frame);
				f_DoNotUnstuckDuration[iNPC] = GetGameTime() + 0.05;
				npc.GetLocomotionInterface().Jump();
				npc.SetVelocity(Jump_1_frame);
				return;
			}
		}
	}
	f_PullStrength[iNPC] = 0.0;
	i_PullTowardsTarget[iNPC] = 0;
	SDKUnhook(iNPC, SDKHook_Think, NpcJumpThink);
}

stock int Can_I_See_Enemy(int attacker, int enemy, bool Ignore_Buildings = false, float EnemyModifpos[3] = {0.0,0.0,0.0})
{
	Handle trace; 
	float pos_npc[3];
	float pos_enemy[3];
	WorldSpaceCenter(attacker, pos_npc);
	if(EnemyModifpos[0] == 0.0 && EnemyModifpos[1] == 0.0 && EnemyModifpos[2] == 0.0)
	{
		WorldSpaceCenter(enemy, pos_enemy);
	}
	else
	{
		pos_enemy[0] = EnemyModifpos[0];
		pos_enemy[1] = EnemyModifpos[1];
		pos_enemy[2] = EnemyModifpos[2];
	}

#if defined ZR
	bool ingore_buildings = (Ignore_Buildings || (RaidbossIgnoreBuildingsLogic(2)));
#else
	bool ingore_buildings = Ignore_Buildings;
#endif

	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, MASK_SOLID, RayType_EndPoint, ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, attacker);
	int Traced_Target;
		
//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//	TE_SetupBeamPoints(pos_npc, pos_enemy, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//	TE_SendToAll();
		
	Traced_Target = TR_GetEntityIndex(trace);
	delete trace;
	return Traced_Target;
}


public bool Can_I_See_Enemy_Only(int attacker, int enemy)
{
	Handle trace;
	float pos_npc[3];
	float pos_enemy[3];
	WorldSpaceCenter(attacker, pos_npc);
	WorldSpaceCenter(enemy, pos_enemy);

	
	AddEntityToTraceStuckCheck(enemy);
	
	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, TraceRayCanSeeAllySpecific, attacker);
	
	RemoveEntityToTraceStuckCheck(enemy);
	
	int Traced_Target = TR_GetEntityIndex(trace);
	delete trace;
	if(Traced_Target == enemy)
	{
		return true;
	}
	return false;
}

public int Can_I_See_Ally(int attacker, int ally)
{
	Handle trace;
	float pos_npc[3];
	float pos_enemy[3];
	WorldSpaceCenter(attacker, pos_npc);
	WorldSpaceCenter(ally, pos_enemy);

	
	AddEntityToTraceStuckCheck(ally);
	
	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, TraceRayCanSeeAllySpecific, attacker);
	
	RemoveEntityToTraceStuckCheck(ally);
	
	int Traced_Target = TR_GetEntityIndex(trace);
	delete trace;
	return Traced_Target;
}

int Place_Gib(const char[] model, float pos[3],float ang[3] = {0.0,0.0,0.0}, float vel[3], bool Reduce_masively_Weight = false, bool big_gibs = false, bool metal_colour = false, bool Rotate = false, bool smaller_gibs = false, int BleedType = 0, bool nobleed = false)
{
	int prop = CreateEntityByName("prop_physics_multiplayer");
	if(!IsValidEntity(prop))
		return -1;
	DispatchKeyValue(prop, "model", model);
	DispatchKeyValue(prop, "physicsmode", "2");
	DispatchKeyValue(prop, "massScale", "1.0");
	DispatchKeyValue(prop, "spawnflags", "2");

/*
	TF2_CreateGlow(prop, model, client, color);

	char buffer[16];
	FormatEx(buffer, sizeof(buffer), "rpg_item_%d", index);
	DispatchKeyValue(prop, "targetname", buffer);

	static float vel[3];
	vel[0] = GetRandomFloat(-160.0, 160.0);
	vel[1] = GetRandomFloat(-160.0, 160.0);
	vel[2] = GetRandomFloat(0.0, 160.0);
	pos[2] += 20.0;
	*/
	/*
	Pow(vel[0], 0.5);
	Pow(vel[1], 0.5);
	Pow(vel[2], 0.5);
	*/
	b_LimitedGibGiveMoreHealth[prop] = false; //Set it to false by default first.
	CurrentGibCount += 1;
	if(big_gibs)
	{
		DispatchKeyValue(prop, "modelscale", "1.6");
	}
	if(smaller_gibs)
	{
		DispatchKeyValue(prop, "modelscale", "0.8");
	}
	
	if(Reduce_masively_Weight)
		ScaleVector(vel, 0.02);
		
	if(ang[0] != 0.0)
	{
		if(!Rotate)
		{
			ang[0] = 0.0;
			ang[1] = 0.0;
			ang[2] = 0.0;
		//	TeleportEntity(prop, pos, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			ang[0] = 90.0;
			ang[1] = 0.0;
			ang[2] = 0.0;
	//		TeleportEntity(prop, pos, {90.0,0.0,0.0}, NULL_VECTOR);
		}
	}
	else
	{
		if(!Rotate)
		{
		//	TeleportEntity(prop, pos, ang, NULL_VECTOR);
		}
		else
		{
			ang[0] += 90.0;
		//	TeleportEntity(prop, pos, ang, NULL_VECTOR);
		}		
		
	}
	DispatchKeyValueVector(prop, "origin",	 pos);
	DispatchKeyValueVector(prop, "angles",	 ang);
	DispatchSpawn(prop);
	TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);

	float Random_time = GetRandomFloat(6.0, 7.0);
	if(CurrentGibCount > ZR_MAX_GIBCOUNT_ABSOLUTE)
	{
		Random_time *= 0.5; //half the duration if there are too many gibs
	}
#if defined RPG
	Random_time *= 0.25; //in RPG, gibs are really not needed as they are purpely cosmetic, for this reason they wont stay long at all.
#endif
	SetEntityCollisionGroup(prop, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
	
	b_IsAGib[prop] = true;
	
	if (!nobleed)
	{
		if(!metal_colour)
		{
			if(BleedType == 0)
			{
				int particle = ParticleEffectAt(pos, "blood_trail_red_01_goop", Random_time); //This is a permanent particle, gotta delete it manually...
				SetParent(prop, particle);
				SetEntityRenderColor(prop, 255, 0, 0, 255);
			}
			else if(BleedType == 2)
			{
				int particle = ParticleEffectAt(pos, "flamethrower_rainbow_bubbles02", Random_time); //This is a permanent particle, gotta delete it manually...
				SetParent(prop, particle);
				SetEntityRenderColor(prop, 65, 65, 255, 255);				
			}
			else
			{
				int particle = ParticleEffectAt(pos, "blood_impact_green_01", Random_time); //This is a permanent particle, gotta delete it manually...
				SetParent(prop, particle);
				SetEntityRenderColor(prop, 0, 255, 0, 255);
			}
		}
		else
		{
	//		pos[2] -= 40.0;
			int particle = ParticleEffectAt(pos, "tpdamage_4", Random_time); //This is a permanent particle, gotta delete it manually...
			SetParent(prop, particle);
		}
	}
	
	CreateTimer(Random_time - 1.5, Prop_Gib_FadeSet, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(Random_time, Timer_RemoveEntity_Prop_Gib, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
//	CreateTimer(1.5, Timer_DisableMotion, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	return prop;
}

#if defined ZR
void GibCollidePlayerInteraction(int gib, int player)
{
	if(b_IsCannibal[player])
	{
		if(dieingstate[player] == 0)
		{
			int weapon = GetEntPropEnt(player, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(weapon)) //Must also hold melee out 
			{
				if(!i_IsWandWeapon[weapon]) //Make sure its not wand.
				{
					if(SDKCall_GetMaxHealth(player) > GetEntProp(player, Prop_Data, "m_iHealth"))
					{
						float Heal_Amount = 0.0;
						
						Heal_Amount = Attributes_Get(weapon, 180, 1.0);
						
						float Heal_Amount_calc;
						
						Heal_Amount_calc = Heal_Amount * 0.75;

						
						if(Heal_Amount_calc > 0.0)
						{
							b_IsAGib[gib] = false; //we dont want the same gib to heal twice.
							if(b_LimitedGibGiveMoreHealth[gib])
							{
								Heal_Amount_calc *= 3.0;
							}
							HealEntityGlobal(player, player, Heal_Amount_calc, 1.0, 1.0, _);
							int sound = GetRandomInt(0, sizeof(g_GibEating) - 1);
							EmitSoundToAll(g_GibEating[sound], player, SNDCHAN_AUTO, 80, _, 1.0, _, _);
						//	RequestFrame(Delete_FrameLater, EntIndexToEntRef(gib));
							RemoveEntity(gib);
						//	b_ThisEntityIgnoredEntirelyFromAllCollisions[gib] = true;
							CurrentGibCount -= 1;
						}
					}
				}
			}
		}
	}
}
#endif

public Action Prop_Gib_FadeSet(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		SetEntityRenderFx(entity, RENDERFX_FADE_FAST);
	}
	return Plugin_Stop;
}
public Action Timer_RemoveEntity_Prop_Gib(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		CurrentGibCount -= 1;
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

public Action Timer_RemoveEntity_Prop(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

public Action Timer_RemoveEntityPanzer(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		float angles[3];
		view_as<CClotBody>(entity).GetAttachment("jetpack_R", pos, angles);
		
		TE_Particle("rd_robot_explosion", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
		
		view_as<CClotBody>(entity).GetAttachment("jetpack_L", pos, angles);
		
		TE_Particle("rd_robot_explosion", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

public Action Timer_RemoveEntityOverlord(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float pos[3];
		float angles[3];
		view_as<CClotBody>(entity).GetAttachment("middle_body_part", pos, angles);
		
		TE_Particle("asplode_hoodoo", pos, NULL_VECTOR, NULL_VECTOR, entity, _, _, _, _, _, _, _, _, _, 0.0);
//		TeleportEntity(entity, OFF_THE_MAP, NULL_VECTOR, NULL_VECTOR); // send it away first in case it feels like dying dramatically
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

stock char[] GetStepSoundForMaterial(const char[] material)
{
	char sound[32]; sound = "concrete";
	
	if (StrContains(material, "wood", false) != -1)
	{
		sound = "wood";
	}
	else if (StrContains(material, "Metal", false) != -1)
	{
		sound = "metal";
	}
	else if (StrContains(material, "Tile", false) != -1)
	{
		sound = "tile";
	}
	else if (StrContains(material, "Concrete", false) != -1)
	{
		sound = "concrete";
	}
	else if (StrContains(material, "Gravel", false) != -1)
	{
		sound = "sravel";
	}
	else if (StrContains(material, "ChainLink", false) != -1)
	{
		sound = "chainlink";
	}
	else if (StrContains(material, "Flesh", false) != -1)
	{
		sound = "flesh";
	}
	else if (StrContains(material, "Grass", false) != -1)
	{
		sound = "grass";
	}
	
	return sound;
}

public Action Did_They_Get_Suck(Handle cut_timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		CClotBody npc = view_as<CClotBody>(entity);
		if (npc.m_flJumpStartTime < GetGameTime() + 0.1)
		{
			float Jump_1_frame[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
			
			static float hullcheckmaxs[3];
			static float hullcheckmins[3];
			if(b_IsGiant[entity])
			{
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
			}			
			else
			{
				hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
				hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
			}
			
			if (IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, npc.index))//The boss will start to merge with shits, cancel out velocity.
			{
				float Save_Old_Pos[3];
				npc.m_vecLastValidPosJump(Save_Old_Pos, false);
				if(!IsSpaceOccupiedDontIgnorePlayers(Save_Old_Pos, hullcheckmins, hullcheckmaxs, npc.index))
				{
					SetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Save_Old_Pos);
					return Plugin_Stop;
				}
			}
		}
		else
		{
			return Plugin_Continue;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype=-1, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0)
{
	// find string table
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE)
	{
//		LogError2("[Plugin] Could not find string table: ParticleEffectNames");
		return;
	}

	// find particle index
	static char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for(int i; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}

	if(stridx == INVALID_STRING_INDEX)
	{
//		LogError2("[Boss] Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);

	if(entindex != -1)
		TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if(customcolors == 2)
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
	}

	if(controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if(controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}

	TE_SendToAll(delay);
}

stock int FireBullet(int m_pAttacker, int iWeapon, float m_vecSrc[3], float m_vecDirShooting[3], float m_flDamage, float m_flDistance, int nDamageType, const char[] tracerEffect, int client = -1, float bonus_entity_damage = 5.0, const char[] szAttachment = "muzzle")
{
	float vecEnd[3];
	vecEnd[0] = m_vecSrc[0] + m_vecDirShooting[0] * m_flDistance; 
	vecEnd[1] = m_vecSrc[1] + m_vecDirShooting[1] * m_flDistance;
	vecEnd[2] = m_vecSrc[2] + m_vecDirShooting[2] * m_flDistance;
	
	// Fire a bullet (ignoring the shooter).
	Handle trace = TR_TraceRayFilterEx(m_vecSrc, vecEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, m_pAttacker);


	if ( TR_GetFraction(trace) < 1.0 )
	{
		// Verify we have an entity at the point of impact.
		if(TR_GetEntityIndex(trace) == -1)
		{
			delete trace;
			return -1;
		}
		
		float endpos[3];	TR_GetEndPosition(endpos, trace);
		
		if(TR_GetEntityIndex(trace) <= 0 || TR_GetEntityIndex(trace) > MaxClients)
		{
			float vecNormal[3];	TR_GetPlaneNormal(trace, vecNormal);
			GetVectorAngles(vecNormal, vecNormal);
			static char class[12];
			GetEntityClassname(TR_GetEntityIndex(trace), class, sizeof(class));
			
			if(StrContains(class, "zr_base_npc") && StrContains(class, "obj_")) //if its the world, then do this.
			{
				CreateParticle("impact_concrete", endpos, vecNormal);
			}
			
		}
		
		// Regular impact effects.
		char effect[PLATFORM_MAX_PATH];
		Format(effect, PLATFORM_MAX_PATH, "%s", tracerEffect);
		
		if (tracerEffect[0])
		{
			if ( nDamageType & DMG_CRIT )
			{
				Format( effect, sizeof(effect), "%s_crit", tracerEffect );
			}

			float origin[3], angles[3];
			view_as<CClotBody>(iWeapon).GetAttachment(szAttachment, origin, angles);
			ShootLaser(iWeapon, effect, origin, endpos, false );
		}
		
	//	TE_SetupBeamPoints(m_vecSrc, endpos, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 0.1, 0.1, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	//	TE_SendToAll();

		int hurt_who = TR_GetEntityIndex(trace);
		if(!IsValidEntity(hurt_who))
		{
			delete trace;
			return -1;
		}
		 
		if(!ShouldNpcDealBonusDamage(hurt_who))
		{
			bonus_entity_damage = 1.0;
		}
		if(client > 0)
		{
			if(IsValidEnemy(m_pAttacker, hurt_who))
			{
				float v[3];
				CalculateBulletDamageForce(m_vecDirShooting, 1.0, v);
				SDKHooks_TakeDamage(hurt_who, m_pAttacker, client, m_flDamage, nDamageType, -1, v, endpos); //any bullet type will deal 5x the damage, usually
			}
		}
		else
		{
			if(IsValidEnemy(m_pAttacker, hurt_who) && hurt_who <= MaxClients)
			{
				float v[3];
				CalculateBulletDamageForce(m_vecDirShooting, 1.0, v);
				SDKHooks_TakeDamage(hurt_who, m_pAttacker, m_pAttacker, m_flDamage, nDamageType, -1, vecEnd, endpos);
			}
			else if(IsValidEnemy(m_pAttacker, hurt_who) && hurt_who > MaxClients)
			{
				float v[3];
				CalculateBulletDamageForce(m_vecDirShooting, 1.0, v);
				SDKHooks_TakeDamage(hurt_who, m_pAttacker, m_pAttacker, m_flDamage * bonus_entity_damage, nDamageType, -1, v, endpos); //any bullet type will deal 5x the damage, usually
			}
		}
		
	}
	int hurt_who = TR_GetEntityIndex(trace);
	delete trace;
	return hurt_who;
}


void CalculateBulletDamageForce(const float vecBulletDir[3], float flScale, float vecForce[3])
{
	vecForce = vecBulletDir;
	NormalizeVector(vecForce, vecForce);
	ScaleVector(vecForce, FindConVar("phys_pushscale").FloatValue);
	ScaleVector(vecForce, flScale);
}

stock bool makeexplosion(
	int attacker = 0,
	 int inflictor = -1,
	  float attackposition[3],
	    char[] weaponname = "",
		 int Damage_for_boom = 200,
		  int Range_for_boom = 200,
		   float Knockback = 200.0,
		    int flags = 0,
			 bool FromNpcForced = false,
			  bool do_explosion_effect = true,
			  float dmg_against_entity_multiplier = 3.0)
{
	if(IsValidEntity(attacker)) //Is this just for effect?
	{
		bool FromBlueNpc = false;
		if(!b_NpcHasDied[attacker] || FromNpcForced)
		{

#if defined ZR
			if(GetTeam(attacker) != TFTeam_Red)
#endif

			{
				FromBlueNpc = true;
			}
		}

		i_ExplosiveProjectileHexArray[attacker] = flags;
		Explode_Logic_Custom(float(Damage_for_boom), attacker, attacker, -1, attackposition, float(Range_for_boom), _, _, FromBlueNpc, _, _, dmg_against_entity_multiplier);

	}
	if(do_explosion_effect)
	{
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(attackposition[0]);
		pack_boom.WriteFloat(attackposition[1]);
		pack_boom.WriteFloat(attackposition[2]);
		pack_boom.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
	}
	
	return true;
}	
	
	
stock void CreateParticle(const char[] particle, const float pos[3], const float ang[3], int client = -1)
{
	int tblidx = FindStringTable("ParticleEffectNames");
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	
	for(int i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, particle, false))
		{
			stridx = i;
			break;
		}
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", pos[0]);
	TE_WriteFloat("m_vecOrigin[1]", pos[1]);
	TE_WriteFloat("m_vecOrigin[2]", pos[2]);
	TE_WriteVector("m_vecAngles", ang);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", -1);
	TE_WriteNum("m_iAttachType", 5);	//Dont associate with any entity
	if(client > 1)
	{
		TE_SendToClient(client);
	}
	else
	{
		TE_SendToAll();
	}
}

stock void ShootLaser(int weapon, const char[] strParticle, float flStartPos[3], float flEndPos[3], bool bResetParticles = false)
{
	int tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE) 
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	char tmp[256];
	int count = GetStringTableNumStrings(tblidx);
	int stridx = INVALID_STRING_INDEX;
	for (int i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, strParticle, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", strParticle);
		return;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
	TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
	TE_WriteFloat("m_vecOrigin[2]", flStartPos[2]);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", weapon);
	TE_WriteNum("m_iAttachType", 2);
	TE_WriteNum("m_iAttachmentPointIndex", 0);
	TE_WriteNum("m_bResetParticles", bResetParticles);	
	TE_WriteNum("m_bControlPoint1", 1);	
	TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 5);  
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
	TE_SendToAll();
}

public bool TraceEntityFilterPlayer2(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

bool SetTeleportEndPoint(int client, float Position[3])
{
	float vAngles[3];
	float vOrigin[3];
	float vBuffer[3];
	float vStart[3];
	float Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	//get endpoint for teleport
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer2);

	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		Position[0] = vStart[0] + (vBuffer[0]*Distance);
		Position[1] = vStart[1] + (vBuffer[1]*Distance);
		Position[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		delete trace;
		return false;
	}
	
	delete trace;
	return true;
}

int GetSolidMask(int npc)
{
	int Solidity;
#if defined ZR
	if(GetTeam(npc) == TFTeam_Red)
		Solidity = (MASK_NPCSOLID|MASK_PLAYERSOLID);
	else
		Solidity = (MASK_NPCSOLID);
#else
//This is RPG
	Solidity = (MASK_NPCSOLID);
#endif
	if(b_IgnorePlayerCollisionNPC[npc])
	{
		Solidity = (MASK_NPCSOLID);
	}
	//this npc ignores all collisions.
	if(b_IgnoreAllCollisionNPC[npc])
	{
		Solidity = (0);	//uhh?
	}
	return Solidity;
}

public MRESReturn IBody_GetSolidMask(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	int EntitySolidMask = view_as<int>(view_as<INextBotComponent>(pThis).GetBot().GetEntity());
	DHookSetReturn(hReturn, GetSolidMask(EntitySolidMask)); 
	return MRES_Supercede; 
}

stock void PredictSubjectPosition(CClotBody npc, int subject, float Extra_lead = 0.0, bool ignore = false, float vec[3])
{
	if(!ignore && f_PredictDuration[subject] > GetGameTime())
	{
		vec = f_PredictPos[subject];
		return;
	}

	PredictSubjectPositionInternal(npc, subject, Extra_lead);
	f_PredictDuration[subject] = GetGameTime() + 0.05;
	vec = f_PredictPos[subject];
}

static void PredictSubjectPositionInternal(CClotBody npc, int subject, float Extra_lead = 0.0)
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	float subjectPos[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
		
	botPos[2] += 45.0;
	subjectPos[2] += 45.0;
	//do not predict if in air
	//do not predict if its a building, waste of resources.

#if defined RTS
	if(IsObject(subject) || i_IsABuilding[subject])
#elseif defined ZR
	if(Npc_Is_Targeted_In_Air(npc.index) || i_IsABuilding[subject])
#else
	if(i_IsABuilding[subject])
#endif
	{
		f_PredictPos[subject] = subjectPos;
		return;
	}

	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	if(MovementSpreadSpeedTooLow(SubjectAbsVelocity))
	{
		f_PredictPos[subject] = subjectPos;
		return;
	}
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
	{
		f_PredictPos[subject] = subjectPos;
		return;
	}
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = (0.1 + Extra_lead) + ( range / ( npc.GetRunSpeed() + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	float pathTarget[3];
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if(view_as<CClotBody>(npc).GetLocomotionInterface().IsPotentiallyTraversable(botPos, subjectPos, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	
	CNavArea leadArea = TheNavMesh.GetNearestNavArea(pathTarget, false, 100.0);
	
	
	if (leadArea == NULL_AREA || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		f_PredictPos[subject] = subjectPos;
		return;
	}
	
	//todo: find better code to not clip through very thin walls, but this works for now
	Handle trace; 
	trace = TR_TraceRayFilterEx(subjectPos, pathTarget, MASK_NPCSOLID | MASK_PLAYERSOLID, RayType_EndPoint, TraceRayHitWorldOnly, 0); //If i hit a wall, i stop retreatring and accept death, for now!
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pathTarget, trace);
	}
	delete trace;
	
	pathTarget[2] += 5.0; //Clip them up, minimum crouch level preferred, or else the bots get really confused and sometimees go otther ways if the player goes up or down somewhere, very thin stairs break these bots.
	f_PredictPos[subject] = pathTarget;
}

static float f_PickThisDirectionForabit[MAXENTITIES];
static int i_PickThisDirectionForabit[MAXENTITIES];

stock void BackoffFromOwnPositionAndAwayFromEnemy(CClotBody npc, int subject, float extra_backoff = 64.0, float pathTarget[3])
{
	float botPos[3];
	WorldSpaceCenter(npc.index, botPos);
	
	float subjectPos[3];
	WorldSpaceCenter(subject, subjectPos);

	// compute our desired destination	
	//https://forums.alliedmods.net/showthread.php?t=278691 im too stupid for vectors.
	
	float vvector[3], ang[3];
	SubtractVectors(botPos, subjectPos, vvector);
	NormalizeVector(vvector, vvector);
	GetVectorAngles(vvector, ang); 
	
	ang[0] = 0.0; //I dont want him to go up or down with his prediction.
	
	float flDistanceToTarget;
	
	if(f_PickThisDirectionForabit[npc.index] < GetGameTime())
	{
		float vecForward[3], vecRight[3], vecTarget[3];
			
		WorldSpaceCenter(subject, vecTarget);
		MakeVectorFromPoints(botPos, vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		vecForward[1] = ang[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
			
		float vecSwingStart[3]; vecSwingStart = botPos;
			
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * extra_backoff;
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * extra_backoff;
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * extra_backoff;
			
		Handle trace; 
		trace = TR_TraceRayFilterEx(botPos, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
		
		
		//Make sure to actually back off...
		
		//I could reuse this code for if npcs get stuck, might actually work out....
		
		TR_GetEndPosition(pathTarget, trace);
		
		delete trace;
		
		flDistanceToTarget = GetVectorDistance(botPos, pathTarget, true);
	}
	else
	{
		flDistanceToTarget = 0.0;
	}
	
	//Check of on if its too close, if yes, try again, but left or right, randomly chosen!
	if(flDistanceToTarget < ((extra_backoff * extra_backoff)) / 2.0)
	{
		int Direction = GetRandomInt(1, 2);
		
		float gameTime = GetGameTime();
		
		if(f_PickThisDirectionForabit[npc.index] < GetGameTime())
		{
			f_PickThisDirectionForabit[npc.index] = gameTime + 1.2;
			i_PickThisDirectionForabit[npc.index] = Direction;
		}
		else
		{
			Direction = i_PickThisDirectionForabit[npc.index];
		}
		
		if(Direction == 1)
		{
			float vecForward_2[3], vecRight_2[3], vecTarget_2[3];
		
			WorldSpaceCenter(subject, vecTarget_2);
			MakeVectorFromPoints(botPos, vecTarget_2, vecForward_2);
			GetVectorAngles(vecForward_2, vecForward_2);
			
			ang[1] += 90.0; //try to the left/right.
			
			vecForward_2[1] = ang[1];
			GetAngleVectors(vecForward_2, vecForward_2, vecRight_2, vecTarget_2);
					
			float vecSwingStart_2[3]; vecSwingStart_2 = botPos;
				
			float vecSwingEnd_2[3];
			vecSwingEnd_2[0] = vecSwingStart_2[0] + vecForward_2[0] * extra_backoff;
			vecSwingEnd_2[1] = vecSwingStart_2[1] + vecForward_2[1] * extra_backoff;
			vecSwingEnd_2[2] = vecSwingStart_2[2] + vecForward_2[2] * extra_backoff;
			
			Handle trace_2; 
			
			trace_2 = TR_TraceRayFilterEx(botPos, vecSwingEnd_2, MASK_SOLID, RayType_EndPoint, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
			TR_GetEndPosition(pathTarget, trace_2);
			
			delete trace_2;
		}
		else
		{
			float vecForward_2[3], vecRight_2[3], vecTarget_2[3];
		
			WorldSpaceCenter(subject, vecTarget_2);
			MakeVectorFromPoints(botPos, vecTarget_2, vecForward_2);
			GetVectorAngles(vecForward_2, vecForward_2);
			
			ang[1] -= 90.0; //try to the left/right.
			
			vecForward_2[1] = ang[1];
			GetAngleVectors(vecForward_2, vecForward_2, vecRight_2, vecTarget_2);
					
			float vecSwingStart_2[3]; vecSwingStart_2 = botPos;
				
			float vecSwingEnd_2[3];
			vecSwingEnd_2[0] = vecSwingStart_2[0] + vecForward_2[0] * extra_backoff;
			vecSwingEnd_2[1] = vecSwingStart_2[1] + vecForward_2[1] * extra_backoff;
			vecSwingEnd_2[2] = vecSwingStart_2[2] + vecForward_2[2] * extra_backoff;
			
			Handle trace_2; 
			
			trace_2 = TR_TraceRayFilterEx(botPos, vecSwingEnd_2, MASK_SOLID, RayType_EndPoint, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
			TR_GetEndPosition(pathTarget, trace_2);
			
			delete trace_2;			
		}
		
	}
	
	Handle trace_3; //2nd one, make sure to actually hit the ground!
	
	trace_3 = TR_TraceRayFilterEx(pathTarget, {89.0, 1.0, 0.0}, MASK_SOLID, RayType_Infinite, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
	
	TR_GetEndPosition(pathTarget, trace_3);
	
	delete trace_3;
	
	/*
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	TE_SetupBeamPoints(botPos, pathTarget, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	TE_SendToAll();
	*/
	
	pathTarget[2] += 20.0; //Clip them up, minimum crouch level preferred, or else the bots get really confused and sometimees go otther ways if the player goes up or down somewhere, very thin stairs break these bots.
}


stock void PredictSubjectPositionForProjectiles(CClotBody npc, int subject, float projectile_speed, float offset = 0.0, float pathTarget[3])
{
	float botPos[3];
	WorldSpaceCenter(npc.index, botPos);

	botPos[2] += offset;
	
	float subjectPos[3];
	WorldSpaceCenter(subject, subjectPos);
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = (0.0001) + ( range / ( projectile_speed + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	/*
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	*/
	//replace this with a trace.
}

stock void PredictSubjectPositionHook(CClotBody npc, int subject, float subjectPos[3])
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
		return;
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = 0.1 + ( range / ( npc.GetRunSpeed() + 0.0001 ) );
	
	// estimate amount to lead the subject	
	float SubjectAbsVelocity[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);
	float lead[3];	
	lead[0] = leadTime * SubjectAbsVelocity[0];
	lead[1] = leadTime * SubjectAbsVelocity[1];
	lead[2] = 0.0;	

	if(GetVectorDotProduct(to, lead) < 0.0)
	{
		// the subject is moving towards us - only pay attention 
		// to his perpendicular velocity for leading
		float to2D[3]; to2D = to;
		to2D[2] = 0.0;
		NormalizeVector(to2D, to2D);
		
		float perp[2];
		perp[0] = -to2D[1];
		perp[1] = to2D[0];

		float enemyGroundSpeed = lead[0] * perp[0] + lead[1] * perp[1];

		lead[0] = enemyGroundSpeed * perp[0];
		lead[1] = enemyGroundSpeed * perp[1];
	}

	// compute our desired destination
	float pathTarget[3];
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
	if (GetVectorLength(lead, true) > 36.0)
	{
		float fraction;
		if(view_as<CClotBody>(npc).GetLocomotionInterface().IsPotentiallyTraversable(botPos, subjectPos, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	
//	CNavArea leadArea = TheNavMesh.GetNavArea(pathTarget, 50.0);
	CNavArea leadArea = TheNavMesh.GetNearestNavArea( pathTarget );
	
	
	if (leadArea == NULL_AREA || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		return;	
	}

	subjectPos = pathTarget;
}


stock int Trace_Test(int m_pAttacker, float m_vecSrc[3], float m_vecDirShooting[3], float m_flDistance)
{
	float vecEnd[3];
	vecEnd[0] = m_vecSrc[0] + m_vecDirShooting[0] * m_flDistance; 
	vecEnd[1] = m_vecSrc[1] + m_vecDirShooting[1] * m_flDistance;
	vecEnd[2] = m_vecSrc[2] + m_vecDirShooting[2] * m_flDistance;
	
	// Fire a bullet (ignoring the shooter).
	Handle trace = TR_TraceRayFilterEx(m_vecSrc, vecEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, m_pAttacker);
	
	int enemy = TR_GetEntityIndex(trace);
	delete trace;
	
	return enemy;
}

stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;
	if (particleEffectNames == INVALID_STRING_TABLE)
	{
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE)
		{
			return INVALID_STRING_INDEX;
		}
	}
	
	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX)
	{
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames))
		{
			return INVALID_STRING_INDEX;
		}
		
		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}
	
	return index;
}

stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];
	int numStrings = GetStringTableNumStrings(tableidx);
	for (int idx = 0; idx < numStrings; idx++)
	{
		ReadStringTable(tableidx, idx, buf, sizeof(buf));
		if (strcmp(buf, str) == 0)
		{
			return idx;
		}
	}
	
	return INVALID_STRING_INDEX;
}

void TE_ParticleInt(int iParticleIndex, const float origin[3] = NULL_VECTOR, const float start[3] = NULL_VECTOR, const float angles[3] = NULL_VECTOR, int entindex = -1, int attachtype = -1, int attachpoint = -1, bool resetParticles = true)
{
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", iParticleIndex);
	TE_WriteNum("entindex", entindex);
	
	if (attachtype != -1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	
	if (attachpoint != -1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);
}

stock void TE_BloodSprite(float Origin[3],float Direction[3], int red, int green, int blue, int alpha, int size)
{
	TE_Start("Blood Sprite");
	TE_WriteVector("m_vecOrigin", Origin);
	TE_WriteVector("m_vecDirection", Direction);
	TE_WriteNum("r", red);
	TE_WriteNum("g", green);
	TE_WriteNum("b", blue);
	TE_WriteNum("a", alpha);
	TE_WriteNum("m_nSize", size);
	
	TE_WriteNum("m_nSprayModel", g_sModelIndexBloodSpray);
	TE_WriteNum("m_nDropModel", g_sModelIndexBloodDrop);
	
	
//	TE_SendToAll();
}

stock int ConnectWithBeam(int iEnt, int iEnt2, int iRed=255, int iGreen=255, int iBlue=255,
							float fStartWidth=0.8, float fEndWidth=0.8, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt",
							float vector1[3]= {0.0,0.0,0.0},float vector2[3]= {0.0,0.0,0.0}, char[] attachment1= "")
{
	int iBeam = CreateEntityByName("env_beam");
	if(iBeam <= MaxClients)
		return -1;

	if(!IsValidEntity(iBeam))
		return -1;

	SetEntityModel(iBeam, Model);
	char sColor[16];
	Format(sColor, sizeof(sColor), "%d %d %d", iRed, iGreen, iBlue);

	DispatchKeyValue(iBeam, "rendercolor", sColor);
	DispatchKeyValue(iBeam, "life", "0");

	DispatchSpawn(iBeam);

	int particle;
	if(iEnt != -1)
	{
		particle = Create_BeamParent(iEnt,_, iBeam, attachment1);
	}
	else
	{
		particle = Create_BeamParent(-1, vector1, iBeam);
	}
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(particle));

	if(iEnt2 != -1)
	{
		particle = Create_BeamParent(iEnt2,_, iBeam);
	}
	else
	{
		particle = Create_BeamParent(-1, vector2, iBeam);
	}
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(particle), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");

	SetVariantInt(0);
	AcceptEntityInput(iBeam, "TouchType");

	SetVariantString("0");
	AcceptEntityInput(iBeam, "damage");

	//its delayed by a frame to avoid it not rendering at all.
//	RequestFrames(ApplyBeamThinkRemoval, 15, EntIndexToEntRef(iBeam));

	return iBeam;
}

stock void ApplyBeamThinkRemoval(int ref)
{
	int EntityBeam = EntRefToEntIndex(ref);
	if(IsValidEntity(EntityBeam))
	{
		CBaseCombatCharacter(EntityBeam).SetNextThink(FAR_FUTURE);
	}
}

stock int Create_BeamParent(int parented, float f3_PositionTemp[3] = {0.0,0.0,0.0}, int beam, char[] attachment = "")
{
	int entity = CreateEntityByName("info_teleport_destination");
	DispatchSpawn(entity);

	//Visualise.
	/*
	DispatchKeyValue(entity, "effect_name", "raygun_projectile_red_crit");
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "Start");	
	*/
	if(parented != -1)
	{
		if(attachment[0])
		{
			static float flAng[3];
			GetAttachment(parented, attachment, f3_PositionTemp, flAng);
			SDKCall_SetLocalOrigin(entity, f3_PositionTemp);		
		}
		else
		{
			WorldSpaceCenter(parented, f3_PositionTemp);
		
			TeleportEntity(entity, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
		}

		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", parented);

		if(attachment[0])
		{
			SetVariantString(attachment);
			AcceptEntityInput(entity, "SetParentAttachment", parented);
			if(attachment[0]) //Delay for 0.001 sec
			{
				SetVariantString(attachment);
				AcceptEntityInput(entity, "SetParentAttachmentMaintainOffset"); 	
			}
		}	

	}
	else
	{
		TeleportEntity(entity, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
	}

	DataPack pack;
	CreateDataTimer(1.0, Create_BeamParent_Owner_Check, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(beam));
	pack.WriteCell(EntIndexToEntRef(entity));

	return entity;
}

public Action Create_BeamParent_Owner_Check(Handle timer, DataPack pack)
{
	pack.Reset();
	int OwnerEntity = EntRefToEntIndex(pack.ReadCell());
	int ChildEntity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(OwnerEntity))
	{
		if(IsValidEntity(ChildEntity))
		{
			RemoveEntity(ChildEntity);	
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


stock int TF2_CreateParticle(int iEnt, const char[] attachment, const char[] particle)
{
	int b = CreateEntityByName("info_particle_system");
	DispatchKeyValue(b, "effect_name", particle);
	DispatchSpawn(b);
	
	SetVariantString("!activator");
	AcceptEntityInput(b, "SetParent", iEnt);
	
	SetVariantString(attachment);
	AcceptEntityInput(b, "SetParentAttachment", iEnt);
	
	ActivateEntity(b);
	AcceptEntityInput(b, "Start");	
	
	return b;
}

stock int GetClosestAlly(int entity, float limitsquared = 99999999.9, int ingore_thisAlly = 0,Function ExtraValidityFunction = INVALID_FUNCTION)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if (IsValidEntity(i) && i != entity && i != ingore_thisAlly && (i <= MaxClients || !b_NpcHasDied[i]))
		{
			if(GetTeam(entity) == GetTeam(i) && !Is_a_Medic[i] && IsEntityAlive(i, true) && !i_NpcIsABuilding[i] && !b_ThisEntityIgnoredByOtherNpcsAggro[i])  //The is a medic thing is really needed
			{
				if(ExtraValidityFunction != INVALID_FUNCTION)
				{
					bool WasValid;
					Call_StartFunction(null, ExtraValidityFunction);
					Call_PushCell(entity);
					Call_PushCell(i);
					Call_Finish(WasValid);

					if(!WasValid)
						continue;
				}
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( distance < limitsquared )
				{
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = i; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = i; 
						TargetDistance = distance;
					}			
				}
			}
		}
	}
	return ClosestTarget; 
}


stock bool IsValidAlly(int index, int ally)
{
	if(IsValidEntity(ally))
	{
		if(b_ThisEntityIgnored[ally])
		{
			return false;
		}
		if(b_ThisEntityIgnoredByOtherNpcsAggro[ally])
		{
			return false;
		}

		if(GetTeam(index) == GetTeam(ally) && (ally <= MaxClients || !b_NpcHasDied[ally]) && IsEntityAlive(ally, true)) 
		{
			return true;
		}
	}
	
	return false;
}


public int PluginBot_OnActorEmoted(NextBotAction action, CBaseCombatCharacter actor, CBaseCombatCharacter emoter, int emote)
{
	int value;
	Function func = func_NPCAnimEvent[actor.index];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(action);
		Call_PushCell(actor);
		Call_PushCell(emoter);
		Call_PushCell(emote);
		Call_Finish(value);
	}
	return value;
}

stock float ApproachAngle( float target, float value, float speed )
{
	float delta = AngleDiff_Change(target, value);
	
	// Speed is assumed to be positive
	if ( speed < 0 )
		speed = -speed;
	
	if ( delta < -180 )
		delta += 360;
	else if ( delta > 180 )
		delta -= 360;
	
	if ( delta > speed )
		value += speed;
	else if ( delta < -speed )
		value -= speed;
	else 
		value = target;
	
	return value;
}

stock float AngleDiff_Change( float destAngle, float srcAngle )
{
	float delta = fmodf(destAngle - srcAngle, 360.0);
	if ( destAngle > srcAngle )
	{
		if ( delta >= 180 )
			delta -= 360;
	}
	else
	{
		if ( delta <= -180 )
			delta += 360;
	}
	
	return delta;
}

stock float fmodf(float num, float denom)
{
	return num - denom * RoundToFloor(num / denom);
}

public void NPCStats_SetFuncsToZero(int entity)
{
	func_NPCDeath[entity] = INVALID_FUNCTION;
	func_NPCOnTakeDamage[entity] = INVALID_FUNCTION;
	func_NPCOnTakeDamagePost[entity] = INVALID_FUNCTION;
	func_NPCThink[entity] = INVALID_FUNCTION;
	func_NPCDeathForward[entity] = INVALID_FUNCTION;
	func_NPCFuncWin[entity] = INVALID_FUNCTION;
	func_NPCAnimEvent[entity] = INVALID_FUNCTION;
	func_NPCActorEmoted[entity] = INVALID_FUNCTION;
	func_NPCInteract[entity] = INVALID_FUNCTION;
}
public void SetDefaultValuesToZeroNPC(int entity)
{
#if defined ZR
	b_NpcHasBeenAddedToZombiesLeft[entity] = false;
	i_SpawnProtectionEntity[entity] = -1; 
	i_TeamGlow[entity] = -1;
	i_NpcOverrideAttacker[entity] = 0;
	b_thisNpcHasAnOutline[entity] = false;
	b_ThisNpcIsImmuneToNuke[entity] = false;
	b_ThisNpcIsSawrunner[entity] = false;
	f_AvoidObstacleNavTime[entity] = 0.0;
	b_NameNoTranslation[entity] = false;
#endif
	c_NpcName[entity][0] = 0;

#if defined EXPIDONSA_BASE
	Expidonsa_SetToZero(entity);
#endif

#if defined RPG
	b_JunalSpecialGear100k[entity] = false;
	RPGCore_SetFlatDamagePiercing(entity,1.0);
	XP[entity] = 0;
	i_CreditsOnKill[entity] = 0;
	i_HpRegenInBattle[entity] = 0;
	Level[entity] = 0;
	RPGCore_ResetHurtList(entity);
	TrueStrength_Reset(_,entity);
#endif
	f_DoNotUnstuckDuration[entity] = 0.0;
	f_UnstuckTimerCheck[entity][0] = 0.0;
	f_UnstuckTimerCheck[entity][1] = 0.0;
	f_BubbleProcStatus[entity][0] = 0.0;
	f_BubbleProcStatus[entity][1] = 0.0;
	f_HeadshotDamageMultiNpc[entity] = 1.0;
	i_NoEntityFoundCount[entity] = 0;
	f3_CustomMinMaxBoundingBox[entity][0] = 0.0;
	f3_CustomMinMaxBoundingBox[entity][1] = 0.0;
	f3_CustomMinMaxBoundingBox[entity][2] = 0.0;
	i_Wearable[entity][0] = -1;
	i_Wearable[entity][1] = -1;
	i_Wearable[entity][2] = -1;
	i_Wearable[entity][3] = -1;
	i_Wearable[entity][4] = -1;
	i_Wearable[entity][5] = -1;
	i_Wearable[entity][6] = -1;
	i_Wearable[entity][7] = -1;
	i_OverlordComboAttack[entity] = 0;
	i_FreezeWearable[entity] = -1;
	i_InvincibleParticle[entity] = -1;
	f3_SpawnPosition[entity][0] = 0.0;
	f3_SpawnPosition[entity][1] = 0.0;
	f3_SpawnPosition[entity][2] = 0.0;
	b_DissapearOnDeath[entity] = false;
	b_IsGiant[entity] = false;
	b_Pathing[entity] = false;
	b_Jumping[entity] = false;
	b_AllowBackWalking[entity] = false;
	fl_JumpStartTime[entity] = 0.0;
#if !defined RTS
	for(int client; client <= MaxClients; client++)
	{
		f_BackstabBossDmgPenaltyNpcTime[entity][client] = 0.0;
	}
#endif

	fl_JumpStartTimeInternal[entity] = 0.0;
	fl_JumpCooldown[entity] = 0.0;
	fl_NextDelayTime[entity] = 0.0;
	fl_NextThinkTime[entity] = 0.0;
	fl_NextRunTime[entity] = 0.0;
	fl_NextMeleeAttack[entity] = 0.0;
	fl_Speed[entity] = 0.0;
	i_Target[entity] = -1;
	fl_GetClosestTargetTime[entity] = 0.0;
	fl_GetClosestTargetTimeTouch[entity] = 0.0;
	b_DoNotChangeTargetTouchNpc[entity] = 0;
	fl_GetClosestTargetNoResetTime[entity] = 0.0;
	fl_NextHurtSound[entity] = 0.0;
	fl_HeadshotCooldown[entity] = 0.0;
	b_CantCollidie[entity] = false;
	b_CollidesWithEachother[entity] = false;
	b_CantCollidieAlly[entity] = false;
	b_bBuildingIsPlaced[entity] = false;
	b_XenoInfectedSpecialHurt[entity] = false;
	fl_XenoInfectedSpecialHurtTime[entity] = 0.0;
	b_DoGibThisNpc[entity] = true;
	b_ThisEntityIgnored[entity] = false;
	b_ThisEntityIgnoredByOtherNpcsAggro[entity] = false;
	b_NpcIsInvulnerable[entity] = false;
	fl_NextIdleSound[entity] = 0.0;
	fl_AttackHappensMinimum[entity] = 0.0;
	fl_AttackHappensMaximum[entity] = 0.0;
	b_AttackHappenswillhappen[entity] = false;
	b_thisNpcIsABoss[entity] = false;
	b_ShowNpcHealthbar[entity] = false;
	b_thisNpcIsARaid[entity] = false;
	b_TryToAvoidTraverse[entity] = false;
	b_NPCVelocityCancel[entity] = false;
	b_NPCTeleportOutOfStuck[entity] = false;
	fl_DoSpawnGesture[entity] = 0.0;
	b_isWalking[entity] = true;
	b_DoNotGiveWaveDelay[entity] = false;
	b_TeamGlowDefault[entity] = true;
	i_StepNoiseType[entity] = 0;
	i_NpcStepVariation[entity] = 0;
	f_NpcTurnPenalty[entity] = 1.0;
	i_BleedType[entity] = 0;
	i_State[entity] = 0;
	b_movedelay[entity] = false;
	fl_NextRangedAttack[entity] = 0.0;
	fl_NextRangedAttackHappening[entity] = 0.0;
	i_AttacksTillReload[entity] = 0;
	b_Gunout[entity] = false;
	fl_ReloadDelay[entity] = 0.0;
	fl_InJump[entity] = 0.0;
	fl_DoingAnimation[entity] = 0.0;
	i_NpcWeight[entity] = 0;
	fl_NextRangedBarrage_Spam[entity] = 0.0;
	fl_NextRangedBarrage_Singular[entity] = 0.0;
	b_CannotBeHeadshot[entity] = false;
	b_CannotBeBackstabbed[entity] = false;
	b_CannotBeStunned[entity] = false;
	b_CannotBeKnockedUp[entity] = false;
	b_CannotBeSlowed[entity] = false;
	b_AvoidObstacleType_Time[entity] = 0.0;

	b_NextRangedBarrage_OnGoing[entity] = false;
	fl_NextTeleport[entity] = 0.0;
	b_Anger[entity] = false;
	fl_NextRangedSpecialAttack[entity] = 0.0;
	fl_NextRangedSpecialAttackHappens[entity] = 0.0;
	b_RangedSpecialOn[entity] = false;
	fl_RangedSpecialDelay[entity] = 0.0;
	fl_movedelay[entity] = 0.0;
	fl_NextChargeSpecialAttack[entity] = 0.0;
	fl_AngerDelay[entity] = 0.0;
	b_FUCKYOU[entity] = false;
	b_FUCKYOU_move_anim[entity] = false;
	b_healing[entity] = false;
	b_new_target[entity] = false;
	fl_ReloadIn[entity] = 0.0;
	i_TimesSummoned[entity] = 0;
	fl_AttackHappens_2[entity] = 0.0;
	fl_Charge_delay[entity] = 0.0;
	fl_Charge_Duration[entity] = 0.0;
	b_movedelay_gun[entity] = false;
	b_Half_Life_Regen[entity] = false;
	fl_Dead_Ringer_Invis[entity] = 0.0;
	fl_Dead_Ringer[entity] = 0.0;
	b_Dead_Ringer_Invis_bool[entity] = false;
	i_AttacksTillMegahit[entity] = 0;
	fl_NextFlameSound[entity] = 0.0;
	fl_FlamerActive[entity] = 0.0;
	b_DoSpawnGesture[entity] = false;
	b_LostHalfHealth[entity] = false;
	b_LostHalfHealthAnim[entity] = false;
	b_DuringHighFlight[entity] = false;
	b_DuringHook[entity] = false;
	b_GrabbedSomeone[entity] = false;
	b_UseDefaultAnim[entity] = false;
	b_FlamerToggled[entity] = false;
	fl_WaveScale[entity] = 0.0;
	fl_StandStill[entity] = 0.0;
	fl_GrappleCooldown[entity] = 0.0;
	fl_HookDamageTaken[entity] = 0.0;
	b_IsCamoNPC[entity] = false;
	b_NoKillFeed[entity] = false;
	b_ThisWasAnNpc[entity] = false;
	b_isGiantWalkCycle[entity] = 1.0;
	i_Activity[entity] = -1;
	i_PoseMoveX[entity] = -1;
	i_PoseMoveY[entity] = -1;
	b_PlayHurtAnimation[entity] = false;
	IgniteTimer[entity] = null;
	IgniteFor[entity] = 0;
	BurnDamage[entity] = 0.0;
	IgniteRef[entity] = -1;
	f_NpcImmuneToBleed[entity] = 0.0;
	f_CreditsOnKill[entity] = 0.0;
	i_PluginBot_ApproachDelay[entity] = 0;
	b_npcspawnprotection[entity] = false;
	f_CooldownForHurtParticle[entity] = 0.0;
	f_DelayComputingOfPath[entity] = GetGameTime() + 0.2;
	f_UnstuckSuckMonitor[entity] = 0.0;
	i_TargetToWalkTo[entity] = -1;
	f_TargetToWalkToDelay[entity] = 0.0;
	i_WasPathingToHere[entity] = 0;
	f3_WasPathingToHere[entity][0] = 0.0;
	f3_WasPathingToHere[entity][1] = 0.0;
	f3_WasPathingToHere[entity][2] = 0.0;
	f_LowTeslarDebuff[entity] = 0.0;
	f_LudoDebuff[entity] = 0.0;
	f_SpadeLudoDebuff[entity] = 0.0;
	f_Silenced[entity] = 0.0;
	f_HighTeslarDebuff[entity] = 0.0;
	f_WidowsWineDebuff[entity] = 0.0;
	f_SpecterDyingDebuff[entity] = 0.0;
	f_VeryLowIceDebuff[entity] = 0.0;
	f_LowIceDebuff[entity] = 0.0;
	f_HighIceDebuff[entity] = 0.0;
	b_Frozen[entity] = false;
	b_NoGravity[entity] = false;
	f_TankGrabbedStandStill[entity] = 0.0;
	f_TimeFrozenStill[entity] = 0.0;
	f_BuildingAntiRaid[entity] = 0.0;
	f_MaimDebuff[entity] = 0.0;
	f_PassangerDebuff[entity] = 0.0;
	f_CrippleDebuff[entity] = 0.0;
	f_CudgelDebuff[entity] = 0.0;
	f_DuelStatus[entity] = 0.0;
	f_PotionShrinkEffect[entity] = 0.0;
	f_EnfeebleEffect[entity] = 0.0;
	f_LeeMinorEffect[entity] = 0.0;
	f_LeeMajorEffect[entity] = 0.0;
	f_LeeSuperEffect[entity] = 0.0;
	b_NoKnockbackFromSources[entity] = false;
	
	fl_TotalArmor[entity] = 1.0;
	fl_MeleeArmor[entity] = 1.0; //yeppers.
	fl_RangedArmor[entity] = 1.0;
	fl_Extra_MeleeArmor[entity] = 1.0;
	fl_Extra_RangedArmor[entity] = 1.0;
	fl_Extra_Speed[entity] = 1.0;
	fl_Extra_Damage[entity] = 1.0;
	f_PickThisDirectionForabit[entity] = 0.0;
	b_ScalesWithWaves[entity] = false;
	f_PernellBuff[entity] = 0.0;
	f_HussarBuff[entity] = 0.0;
	f_GodAlaxiosBuff[entity] = 0.0;
	f_StuckOutOfBoundsCheck[entity] = GetGameTime() + 2.0;
	f_StunExtraGametimeDuration[entity] = 0.0;
	f_RaidStunResistance[entity] = 0.0;
	i_TextEntity[entity][0] = -1;
	i_TextEntity[entity][1] = -1;
	i_TextEntity[entity][2] = -1;
	i_TextEntity[entity][3] = -1;
	i_TextEntity[entity][4] = -1;
	i_NpcIsABuilding[entity] = false;
//	b_EntityInCrouchSpot[entity] = false;
//	b_NpcResizedForCrouch[entity] = false;
	i_Changed_WalkCycle[entity] = -1;
	f_TextEntityDelay[entity] = 0.0;
	f_CheckIfStuckPlayerDelay[entity] = 0.0;
	f_QuickReviveHealing[entity] = 0.0;
#if defined ZR
	ResetBoundVillageAlly(entity);
	ResetFreeze(entity);
#endif
	c_HeadPlaceAttachmentGibName[entity][0] = 0;
}


public void ArrowStartTouch(int arrow, int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
		int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
		if(ShouldNpcDealBonusDamage(entity))
		{
			f_ArrowDamage[arrow] *= 3.0;
		}

		int owner = GetEntPropEnt(arrow, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}

		int inflictor = h_ArrowInflictorRef[arrow];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[arrow]);

		if(inflictor == -1)
			inflictor = owner;

		SDKHooks_TakeDamage(entity, owner, inflictor, f_ArrowDamage[arrow], DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		if(i_NervousImpairmentArrowAmount[arrow] > 0)
		{
#if defined ZR
			Elemental_AddNervousDamage(entity, owner, i_NervousImpairmentArrowAmount[arrow]);
#endif
		}
#if defined ZR
		if(i_ChaosArrowAmount[arrow] > 0)
		{
			Elemental_AddChaosDamage(entity, owner, i_ChaosArrowAmount[arrow]);
		}
#endif

		EmitSoundToAll(g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], arrow, _, 80, _, 0.8, 100);
		if(IsValidEntity(arrow_particle))
		{
		//	DispatchKeyValue(arrow_particle, "parentname", "none");
			AcceptEntityInput(arrow_particle, "ClearParent");
			float f3_PositionTemp[3];
			GetEntPropVector(arrow_particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
			TeleportEntity(arrow_particle, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
		EmitSoundToAll(g_ArrowHitSoundMiss[GetRandomInt(0, sizeof(g_ArrowHitSoundMiss) - 1)], arrow, _, 80, _, 0.8, 100);
		if(IsValidEntity(arrow_particle))
		{
		//	DispatchKeyValue(arrow_particle, "parentname", "none");
			AcceptEntityInput(arrow_particle, "ClearParent");
			float f3_PositionTemp[3];
			GetEntPropVector(arrow_particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
			TeleportEntity(arrow_particle, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	RemoveEntity(arrow);
}

public void Rocket_Particle_StartTouch(int entity, int target)
{
	
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		if(b_should_explode[entity])	//should we "explode" or do "kinetic" damage
		{
			i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
			Explode_Logic_Custom(fl_rocket_particle_dmg[entity] , inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
		}
		else
		{
			SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
		}
		
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}

public MRESReturn Rocket_Particle_DHook_RocketExplodePre(int entity)
{
	return MRES_Supercede;	//Don't even think about it mate
}

public MRESReturn Arrow_DHook_RocketExplodePre(int arrow)
{
	RemoveEntity(arrow);
	int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
	if(IsValidEntity(arrow_particle))
	{
		DispatchKeyValue(arrow_particle, "parentname", "none");
		AcceptEntityInput(arrow_particle, "ClearParent");
		float f3_PositionTemp[3];
		GetEntPropVector(arrow_particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
		TeleportEntity(arrow_particle, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	return MRES_Supercede;
}


public MRESReturn Dhook_UpdateGroundConstraint_Pre(DHookParam param)
{
	b_IsInUpdateGroundConstraintLogic = true;
	return MRES_Ignored;
}

public MRESReturn Dhook_UpdateGroundConstraint_Post(DHookParam param)
{
	b_IsInUpdateGroundConstraintLogic = false;
	return MRES_Ignored;
}

public bool Never_ShouldCollide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	return false;
} 

//TELEPORT IS SAFE? FROM SARYSA BUT EDITED FOR NPCS!
/*
	note:
	This is garbage lol
*/

#if defined ZR
bool NPC_Teleport(int npc, float endPos[3] /*Where do we want to end up?*/, bool ForPlayer = false, float startPos[3] = {0.0,0.0,0.0})
{
	float sizeMultiplier = 1.0; //We do not want to teleport giants, yet.
	
	if(startPos[0] == 0.0)
	{
		GetAbsOrigin(npc, startPos);
		startPos[2] += 25.0;		
	}

	if(b_IsGiant[npc])
	{
		sizeMultiplier = 1.25;
	}

	static float testPos[3];
	bool found = false;

	for (int x = 0; x < 3; x++)
	{
		if (found)
			break;
		
		float xOffset;
		if (x == 0)
			xOffset = 0.0;
		else if (x == 1)
			xOffset = 12.5 * sizeMultiplier;
		else
			xOffset = 25.0 * sizeMultiplier;
			
		if (endPos[0] < startPos[0])
			testPos[0] = endPos[0] + xOffset;
		else if (endPos[0] > startPos[0])
			testPos[0] = endPos[0] - xOffset;
		else if (xOffset != 0.0)
			break; // super rare but not impossible, no sense wasting on unnecessary tests
		
		for (int y = 0; y < 3; y++)
		{
			if (found)
				break;

			float yOffset;
			if (y == 0)
				yOffset = 0.0;
			else if (y == 1)
				yOffset = 12.5 * sizeMultiplier;
			else
				yOffset = 25.0 * sizeMultiplier;

			if (endPos[1] < startPos[1])
				testPos[1] = endPos[1] + yOffset;
			else if (endPos[1] > startPos[1])
				testPos[1] = endPos[1] - yOffset;
			else if (yOffset != 0.0)
				break; // super rare but not impossible, no sense wasting on unnecessary tests
			
			for (int z = 0; z < 3; z++)
			{
				if (found)
					break;
					
				float zOffset;
				if (z == 0)
					zOffset = 0.0;
				else if (z == 1)
					zOffset = 41.5 * sizeMultiplier;
				else
					zOffset = 83.0 * sizeMultiplier;

				if (endPos[2] < startPos[2])
					testPos[2] = endPos[2] + zOffset;
				else if (endPos[2] > startPos[2])
					testPos[2] = endPos[2] - zOffset;
				else if (zOffset != 0.0)
					break; // super rare but not impossible, no sense wasting on unnecessary tests

				// before we test this position, ensure it has line of sight from the point our player looked from
				// this ensures the player can't teleport through walls
				static float tmpPos[3];
				if(!ForPlayer)
				{
					TR_TraceRayFilter(endPos, testPos, MASK_NPCSOLID, RayType_EndPoint, TraceFilterClients);
				}
				else
				{
					TR_TraceRayFilter(endPos, testPos, MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitPlayersOrEntityCombat);
				}
				TR_GetEndPosition(tmpPos);
				if (testPos[0] != tmpPos[0] || testPos[1] != tmpPos[1] || testPos[2] != tmpPos[2])
					continue;
			}
		}
	}
	
	if (!IsSpotSafe(npc, testPos, sizeMultiplier))
		return false;
	
	if(!ForPlayer)
	{
		Handle trace; 

		int Traced_Target;
				
		trace = TR_TraceRayFilterEx(startPos, testPos, MASK_NPCSOLID, RayType_EndPoint, TraceRayDontHitPlayersOrEntityCombat, npc);

		Traced_Target = TR_GetEntityIndex(trace);

		delete trace;
						
		//Can i see This enemy, is something in the way of us?
		//Dont even check if its the same enemy, just engage in rape, and also set our new target to this just in case.

		if(Traced_Target != -1) //We wanna make sure that whever we teleport, nothing has collided with us. (Mainly world)
		{	
			return false; //We are unable to perfom this task. Abort mission
		}
		//Trace found nothing has collided! Horray! Perform our teleport.
			
	}

	TeleportEntity(npc, testPos, NULL_VECTOR, NULL_VECTOR);
	return true;
}


bool TraceFilterClients(int entity, int mask, any data)
{    
    if (entity > 0 && entity <= MAXENTITIES) 
    { 
        return false; 
    }
    else 
    { 
        return true; 
    } 
} 


static bool ResizeTraceFailed;
static int ResizeMyTeam;


bool IsSpotSafe(int npc, float playerPos[3], float sizeMultiplier)
{
	ResizeTraceFailed = false;
	ResizeMyTeam = GetTeam(npc);
	static float mins[3];
	static float maxs[3];
	mins[0] = -24.0 * sizeMultiplier;
	mins[1] = -24.0 * sizeMultiplier;
	mins[2] = 0.0;
	maxs[0] = 24.0 * sizeMultiplier;
	maxs[1] = 24.0 * sizeMultiplier;
	maxs[2] = 82.0 * sizeMultiplier;

	// the eight 45 degree angles and center, which only checks the z offset
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, 0.0, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], 0.0, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1], maxs[2])) return false;

	// 22.5 angles as well, for paranoia sake
	if (!Resize_TestResizeOffset(playerPos, mins[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], mins[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0], maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, mins[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, mins[0] * 0.5, maxs[1], maxs[2])) return false;
	if (!Resize_TestResizeOffset(playerPos, maxs[0] * 0.5, maxs[1], maxs[2])) return false;

	// four square tests
	if (!Resize_TestSquare(playerPos, mins[0], maxs[0], mins[1], maxs[1], maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.75, maxs[0] * 0.75, mins[1] * 0.75, maxs[1] * 0.75, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.5, maxs[0] * 0.5, mins[1] * 0.5, maxs[1] * 0.5, maxs[2])) return false;
	if (!Resize_TestSquare(playerPos, mins[0] * 0.25, maxs[0] * 0.25, mins[1] * 0.25, maxs[1] * 0.25, maxs[2])) return false;
	
	return true;
}


bool Resize_TestSquare(const float bossOrigin[3], float xmin, float xmax, float ymin, float ymax, float zOffset)
{
	static float pointA[3];
	static float pointB[3];
	for (int phase = 0; phase <= 7; phase++)
	{
		// going counterclockwise
		if (phase == 0)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 1)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 2)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmax;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 3)
		{
			pointA[0] = bossOrigin[0] + xmax;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 4)
		{
			pointA[0] = bossOrigin[0] + 0.0;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymin;
		}
		else if (phase == 5)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymin;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + 0.0;
		}
		else if (phase == 6)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + 0.0;
			pointB[0] = bossOrigin[0] + xmin;
			pointB[1] = bossOrigin[1] + ymax;
		}
		else if (phase == 7)
		{
			pointA[0] = bossOrigin[0] + xmin;
			pointA[1] = bossOrigin[1] + ymax;
			pointB[0] = bossOrigin[0] + 0.0;
			pointB[1] = bossOrigin[1] + ymax;
		}

		for (int shouldZ = 0; shouldZ <= 1; shouldZ++)
		{
			pointA[2] = pointB[2] = shouldZ == 0 ? bossOrigin[2] : (bossOrigin[2] + zOffset);
			if (!Resize_OneTrace(pointA, pointB))
				return false;
		}
	}
		
	return true;
}

bool Resize_TestResizeOffset(const float bossOrigin[3], float xOffset, float yOffset, float zOffset)
{
	static float tmpOrigin[3];
	tmpOrigin[0] = bossOrigin[0];
	tmpOrigin[1] = bossOrigin[1];
	tmpOrigin[2] = bossOrigin[2];
	static float targetOrigin[3];
	targetOrigin[0] = bossOrigin[0] + xOffset;
	targetOrigin[1] = bossOrigin[1] + yOffset;
	targetOrigin[2] = bossOrigin[2];
	
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	tmpOrigin[0] = targetOrigin[0];
	tmpOrigin[1] = targetOrigin[1];
	tmpOrigin[2] = targetOrigin[2] + zOffset;

	if (!Resize_OneTrace(targetOrigin, tmpOrigin))
		return false;
		
	targetOrigin[0] = bossOrigin[0];
	targetOrigin[1] = bossOrigin[1];
	targetOrigin[2] = bossOrigin[2] + zOffset;
		
	if (!(xOffset == 0.0 && yOffset == 0.0))
		if (!Resize_OneTrace(tmpOrigin, targetOrigin))
			return false;
		
	return true;
}


bool Resize_OneTrace(const float startPos[3], const float endPos[3])
{
	static float result[3];

//	MASK_NPCSOLID, TraceRayHitPlayersOnly

	TR_TraceRayFilter(startPos, endPos, MASK_SOLID, RayType_EndPoint, Resize_TracePlayersAndBuildings);
	if (ResizeTraceFailed)
	{
		return false;
	}
	TR_GetEndPosition(result);
	if (endPos[0] != result[0] || endPos[1] != result[1] || endPos[2] != result[2])
	{
		return false;
	}
	
	return true;
}

#define MAX_ENTITY_CLASSNAME_LENGTH 48
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_PLAYERS_ARRAY 36

bool Resize_TracePlayersAndBuildings(int entity, int contentsMask)
{
	if(entity > 0 && entity <= MaxClients)
	{
		if(TeutonType[entity] == TEUTON_NONE && dieingstate[entity] == 0)
		{
			if (!b_DoNotUnStuck[entity] && !b_ThisEntityIgnored[entity] && GetClientTeam(entity) != ResizeMyTeam)
			{
				ResizeTraceFailed = true;
			}
		}
	}
	else if (IsValidEntity(entity))
	{
		static char classname[MAX_ENTITY_CLASSNAME_LENGTH];
		GetEntityClassname(entity, classname, sizeof(classname));
		if ((StrContains(classname, "obj_") == 0) || (strcmp(classname, "prop_dynamic") == 0) || (strcmp(classname, "func_door") == 0) || (strcmp(classname, "func_physbox") == 0) || (strcmp(classname, "zr_base_npc") == 0) || (strcmp(classname, "func_breakable") == 0))
		{
			if(!b_ThisEntityIgnored[entity] && ResizeMyTeam != GetTeam(entity))
			{
				ResizeTraceFailed = true;
			}
		}
	}

	return false;
}
#endif
//TELEPORT LOGIC END.

public void KillNpc(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity)) //Dont do this in a think pls.
	{
		SmiteNpcToDeath(entity);
	}
}

stock void FreezeNpcInTime(int npc, float Duration_Stun)
{
	if(b_CannotBeStunned[npc])
	{
		return;
	}
	float GameTime = GetGameTime();
	float TimeSinceLastStunSubtract;
	TimeSinceLastStunSubtract = f_TimeSinceLastStunHit[npc] - GameTime;
			
	if(TimeSinceLastStunSubtract < 0.0)
	{
		TimeSinceLastStunSubtract = 0.0;
	}

	CClotBody npcclot = view_as<CClotBody>(npc);

	//Set speed to 0 as its a stun.
	if(npcclot.IsOnGround())
	{
		static float ResetSpeed[3];
		npcclot.SetVelocity(ResetSpeed);
	}

	float Duration_Stun_Post = Duration_Stun;
	if(b_thisNpcIsARaid[npc]/* && Duration_Stun >= 1.0*/)
	{
		if(f_RaidStunResistance[npc] > GameTime)
		{
			Duration_Stun_Post *= 0.5;
		}
	}
	f_StunExtraGametimeDuration[npc] += (Duration_Stun_Post - TimeSinceLastStunSubtract);
	fl_NextDelayTime[npc] = GameTime + Duration_Stun_Post - f_StunExtraGametimeDuration[npc];
	f_TimeFrozenStill[npc] = GameTime + Duration_Stun_Post - f_StunExtraGametimeDuration[npc];
	f_TimeSinceLastStunHit[npc] = GameTime + Duration_Stun_Post;
	f_RaidStunResistance[npc] = GameTime + Duration_Stun;
	npcclot.Update();

	Npc_DebuffWorldTextUpdate(view_as<CClotBody>(npc));

	f_LayerSpeedFrozeRestore[npc] = view_as<CClotBody>(npc).GetPlaybackRate();
	view_as<CClotBody>(npc).SetPlaybackRate(0.0);
	int layerCount = CBaseAnimatingOverlay(npc).GetNumAnimOverlays();
	for(int i; i < layerCount; i++)
	{
		view_as<CClotBody>(npc).SetLayerPlaybackRate(i, 0.0);
	}
}

stock void NpcStats_SilenceEnemy(int enemy, float duration)
{
	float GameTime = GetGameTime();
	if(f_Silenced[enemy] < (GameTime + duration))
	{
		f_Silenced[enemy] = GameTime + duration; //make sure longer silence buff is prioritised.
	}
}

stock bool NpcStats_IsEnemySilenced(int enemy)
{
	if(!IsValidEntity(enemy))
		return true; //they dont exist, pretend as if they are silenced.

	if(f_Silenced[enemy] < GetGameTime())
	{
		return false;
	}
	return true;
}

#if defined ZR
void NPCStats_RemoveAllDebuffs(int enemy)
{
	f_HighTeslarDebuff[enemy] = 0.0;
	f_LowTeslarDebuff[enemy] = 0.0;
	f_LudoDebuff[enemy] = 0.0;
	f_SpadeLudoDebuff[enemy] = 0.0;
	IgniteFor[enemy] = 0;
	f_HighIceDebuff[enemy] = 0.0;
	f_LowIceDebuff[enemy] = 0.0;
	f_VeryLowIceDebuff[enemy] = 0.0;
	f_WidowsWineDebuff[enemy] = 0.0;
	f_CrippleDebuff[enemy] = 0.0;
	f_CudgelDebuff[enemy] = 0.0;
	f_MaimDebuff[enemy] = 0.0;
	f_PotionShrinkEffect[enemy] = 0.0;
	f_EnfeebleEffect[enemy] = 0.0;
	f_LeeMinorEffect[enemy] = 0.0;
	f_LeeMajorEffect[enemy] = 0.0;
	f_LeeSuperEffect[enemy] = 0.0;
	f_SpecterDyingDebuff[enemy] = 0.0;
	f_PassangerDebuff[enemy] = 0.0;
}
#endif



bool Npc_Teleport_Safe(int client, float endPos[3], float hullcheckmins_Player[3], float hullcheckmaxs_Player[3], bool check_for_Ground_Clerance = false, bool teleport_entity = true)
{
	bool FoundSafeSpot = false;
	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance))
		FoundSafeSpot = true;

	for (int x = 0; x < 6; x++)
	{
		if (FoundSafeSpot)
			break;

		endPos = OriginalPos;
		//ignore 0 at all costs.
		
		switch(x)
		{
			case 0:
				endPos[2] -= TELEPORT_STUCK_CHECK_1;

			case 1:
				endPos[2] += TELEPORT_STUCK_CHECK_1;

			case 2:
				endPos[2] += TELEPORT_STUCK_CHECK_2;

			case 3:
				endPos[2] -= TELEPORT_STUCK_CHECK_2;

			case 4:
				endPos[2] += TELEPORT_STUCK_CHECK_3;

			case 5:
				endPos[2] -= TELEPORT_STUCK_CHECK_3;	
		}
		for (int y = 0; y < 7; y++)
		{
			if (FoundSafeSpot)
				break;

			endPos[1] = OriginalPos[1];
				
			switch(y)
			{
				case 1:
					endPos[1] += TELEPORT_STUCK_CHECK_1;

				case 2:
					endPos[1] -= TELEPORT_STUCK_CHECK_1;

				case 3:
					endPos[1] += TELEPORT_STUCK_CHECK_2;

				case 4:
					endPos[1] -= TELEPORT_STUCK_CHECK_2;

				case 5:
					endPos[1] += TELEPORT_STUCK_CHECK_3;

				case 6:
					endPos[1] -= TELEPORT_STUCK_CHECK_3;	
			}

			for (int z = 0; z < 7; z++)
			{
				if (FoundSafeSpot)
					break;

				endPos[0] = OriginalPos[0];
						
				switch(z)
				{
					case 1:
						endPos[0] += TELEPORT_STUCK_CHECK_1;

					case 2:
						endPos[0] -= TELEPORT_STUCK_CHECK_1;

					case 3:
						endPos[0] += TELEPORT_STUCK_CHECK_2;

					case 4:
						endPos[0] -= TELEPORT_STUCK_CHECK_2;

					case 5:
						endPos[0] += TELEPORT_STUCK_CHECK_3;

					case 6:
						endPos[0] -= TELEPORT_STUCK_CHECK_3;
				}
				if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance))
					FoundSafeSpot = true;
			}
		}
	}
				

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance))
		FoundSafeSpot = true;

	if(FoundSafeSpot && teleport_entity)
	{
		SDKCall_SetLocalOrigin(client, endPos);	
	}
	return FoundSafeSpot;
}


//We wish to check if this poisiton is safe or not.
//This is only for players.
bool IsSafePosition(int entity, float Pos[3], float mins[3], float maxs[3], bool check_for_Ground_Clerance = false)
{
	int ref;
	
	Handle hTrace;
	int SolidityFlags;
	if(entity <= MaxClients)
	{
		SolidityFlags = MASK_PLAYERSOLID;
	}

#if defined ZR
	else if(GetTeam(entity) == TFTeam_Red)
	{
		SolidityFlags = MASK_NPCSOLID | MASK_PLAYERSOLID;
	}
#endif

	else
	{
		SolidityFlags = MASK_NPCSOLID;
	}
	hTrace = TR_TraceHullFilterEx(Pos, Pos, mins, maxs, SolidityFlags, BulletAndMeleeTrace, entity);

	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	float pos_player[3];
	WorldSpaceCenter(entity, pos_player);
	float Pos2Test_Higher[3];
	Pos2Test_Higher = Pos;
	Pos2Test_Higher[2] += 35.0;
	hTrace = TR_TraceRayFilterEx( pos_player, Pos2Test_Higher, SolidityFlags, RayType_EndPoint, TraceRayDontHitPlayersOrEntityCombat, entity );
	if ( TR_GetFraction(hTrace) < 1.0)
	{
		delete hTrace;
		return false;
	}
	if(ref < 0) //It hit nothing, good!
	{
		if(!check_for_Ground_Clerance)
		{
			delete hTrace;
			return true;
		}

		//We aint done yet!
		float Pos2Test[3];
		Pos2Test = Pos;
		Pos2Test[2] -= 25.0; //25 is a good ammount

		if(entity <= MaxClients)	// Clients
		{
			hTrace = TR_TraceHullFilterEx(Pos2Test, Pos2Test, mins, maxs, MASK_PLAYERSOLID, BulletAndMeleeTrace, entity);
		}

#if defined ZR
		else if(GetTeam(entity) == TFTeam_Red)
		{
			hTrace = TR_TraceHullFilterEx(Pos2Test, Pos2Test, mins, maxs, MASK_NPCSOLID | MASK_PLAYERSOLID, BulletAndMeleeTrace, entity);
		}
#endif

		else
		{
			hTrace = TR_TraceHullFilterEx(Pos2Test, Pos2Test, mins, maxs, MASK_NPCSOLID, BulletAndMeleeTrace, entity);
		}
		ref = TR_GetEntityIndex(hTrace);
		delete hTrace;
		if(ref == 0) //It Ground, good, otherwise, bad!
		{
			return true;
		}
	}
	//It Hit something, bad!
	delete hTrace;
	return false;
}


/*
float Calculate_PointValueClosestTargetNpc(int npc, float Npc_Vector[3], float Target_Vector[3])
{
	//If we return anything thats in the exact 
	CNavArea NpcArea = TheNavMesh.GetNearestNavArea_Vec( Npc_Vector );
	CNavArea TargetArea = TheNavMesh.GetNearestNavArea_Vec( Target_Vector );

	if(NpcArea == TargetArea)
	{
		//If its in the exact same nav area, do this instead.
	}
	
	float distanceCost = TheNavMesh.NavAreaTravelDistance(NpcArea, TargetArea, PluginBot_PathCost);

	if(distanceCost == -1.0)
	{
		//panic!
		return 2.0;
	}
	return 1.0;
}


template< typename CostFunctor >
float NavAreaTravelDistance( const Vector &startPos, const Vector &goalPos, CostFunctor &costFunc )
{
	CNavArea *startArea = TheNavMesh->GetNearestNavArea( startPos );
	if (startArea == NULL)
	{
		return -1.0f;
	}

	// compute path between areas using given cost heuristic
	CNavArea *goalArea = NULL;
	if (NavAreaBuildPath( startArea, NULL, &goalPos, costFunc, &goalArea ) == false)
	{
		return -1.0f;
	}

	// compute distance along path
	if (goalArea->GetParent() == NULL)
	{
		// both points are in the same area - return euclidean distance
		return (goalPos - startPos).Length();
	}
	else
	{
		CNavArea *area;
		float distance;

		// goalPos is assumed to be inside goalArea (or very close to it) - skip to next area
		area = goalArea->GetParent();
		distance = (goalPos - area->GetCenter()).Length();

		for( ; area->GetParent(); area = area->GetParent() )
		{
			distance += (area->GetCenter() - area->GetParent()->GetCenter()).Length();
		}

		// add in distance to startPos
		distance += (startPos - area->GetCenter()).Length();

		return distance;
	}
}

#endif // _CS_NAV_PATHFIND_H_
*/

#if defined ZR
public void Npc_BossHealthBar(CClotBody npc)
{
	if(b_IsEntityNeverTranmitted[npc.index] || b_NoHealthbar[npc.index])
	{
		if(IsValidEntity(npc.m_iTextEntity5))
		{
			RemoveEntity(npc.m_iTextEntity5);
		}	
		return;	
	}
	
	int NpcTypeDefine = 0;
	if(b_thisNpcIsABoss[npc.index] || b_ShowNpcHealthbar[npc.index] || (Citizen_IsIt(npc.index) && !b_IsCamoNPC[npc.index] && !b_ThisEntityIgnored[npc.index]))
	{
		NpcTypeDefine = 1;
	}
	if(b_thisNpcIsARaid[npc.index] || EntRefToEntIndex(RaidBossActive) == npc.index)
	{
		NpcTypeDefine = 2;
	}

	if(NpcTypeDefine == 0)
	{
		if(IsValidEntity(npc.m_iTextEntity5))
		{
			RemoveEntity(npc.m_iTextEntity5);
		}
		return;
	}

	NpcTypeDefine --;

	char HealthText[32];
	int HealthColour[4];
	int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	for(int i=0; i<(NpcTypeDefine ? 20 : 10); i++)
	{
		if(Health >= MaxHealth*(i*(NpcTypeDefine ? 0.05 : 0.1)))
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, "|");
		}
		else
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ".");
		}
	}
	HealthColour[3] = 255;

	DisplayRGBHealthValue(Health, MaxHealth, HealthColour[0], HealthColour[1],HealthColour[2]);

	if(IsValidEntity(npc.m_iTextEntity5))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(npc.m_iTextEntity5,     "color", sColor);
		DispatchKeyValue(npc.m_iTextEntity5, "message", HealthText);
	}
	else
	{
		float Offset[3];

		Offset[2] += 95.0;
		Offset[2] *= GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale");
		
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 17, HealthColour, npc.index);
		DispatchKeyValue(TextEntity, "font", "1");
		npc.m_iTextEntity5 = TextEntity;	
	}
}
#endif	// Non-RTS

public void Npc_DebuffWorldTextUpdate(CClotBody npc)
{
	if(b_IsEntityNeverTranmitted[npc.index] || b_NoHealthbar[npc.index])
	{
		if(IsValidEntity(npc.m_iTextEntity4))
		{
			RemoveEntity(npc.m_iTextEntity4);
		}		
		return;
	}
	char HealthText[32];
	int HealthColour[4];

	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[2] = 255;
	HealthColour[3] = 255;

	if(NpcStats_IsEnemySilenced(npc.index))
	{
		Format(HealthText, sizeof(HealthText), "X");
	}

#if defined ZR
	if(Saga_EnemyDoomed(npc.index))
	{
		Format(HealthText, sizeof(HealthText), "%s#",HealthText);
	}
	if(i_HowManyBombsHud[npc.index] > 0)
	{
		Format(HealthText, sizeof(HealthText), "%s!(%i)",HealthText, i_HowManyBombsHud[npc.index]);
	}
	if(f_TimeFrozenStill[npc.index] > GetGameTime(npc.index))
	{
		Format(HealthText, sizeof(HealthText), "%s?",HealthText);
	}
	if(VausMagicaShieldLeft(npc.index) > 0)
	{
		Format(HealthText, sizeof(HealthText), "%sS(%i)",HealthText,VausMagicaShieldLeft(npc.index));
	}
	/*
	if(IgniteFor[npc.index] > 0)
	{
		Format(HealthText, sizeof(HealthText), "%s~",HealthText);
	}
	*/
	if(f_DuelStatus[npc.index] > GetGameTime(npc.index))
	{
		Format(HealthText, sizeof(HealthText), "%sVS",HealthText);
	}
#endif

	if(!HealthText[0])
	{
		if(IsValidEntity(npc.m_iTextEntity4))
		{
			RemoveEntity(npc.m_iTextEntity4);
		}
		return;
	}
	

	if(IsValidEntity(npc.m_iTextEntity4))
	{
	//	char sColor[32];
	//	Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
	//	DispatchKeyValue(npc.m_iTextEntity1,     "color", sColor);
	// Colour will never be Edited probably.
		DispatchKeyValue(npc.m_iTextEntity4, "message", HealthText);
	}
	else
	{
		float Offset[3];

		Offset[2] += 95.0;

		Offset[2] *= GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale");
#if defined RPG
		Offset[2] += 30.0;
#endif
		Offset[2] += 15.0;
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 16, HealthColour, npc.index);
	//	SDKHook(TextEntity, SDKHook_SetTransmit, BarrackBody_Transmit);
	//	DispatchKeyValue(TextEntity, "font", "1");
		npc.m_iTextEntity4 = TextEntity;	
	}
}

static int b_TouchedEntity[MAXENTITIES];

//TODO: teleport entities instead, but this is easier to i sleep :)
stock void ResolvePlayerCollisions_Npc(int iNPC, float damage, bool CauseKnockback = true)
{
	static float flMyPos[3];
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
	float vecUp[3];
	float vecForward[3];
	float vecRight[3];

	GetVectors(iNPC, vecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(

	float vecSwingEnd[3];
	vecSwingEnd[0] = flMyPos[0] + vecForward[0] * (25.0);
	vecSwingEnd[1] = flMyPos[1] + vecForward[1] * (25.0);
	vecSwingEnd[2] = flMyPos[2];
				

	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[iNPC])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[iNPC][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[iNPC][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[iNPC][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[iNPC][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
		
	//god i love floating point imprecision
	hullcheckmaxs[0] += 0.001;
	hullcheckmaxs[1] += 0.001;
	hullcheckmaxs[2] += 0.001;

	hullcheckmins[0] -= 0.001;
	hullcheckmins[1] -= 0.001;
	hullcheckmins[2] -= 0.001;
	/*
	for(int client; client <= MaxClients; client++)
	{
		if(IsValidClient(client))
		{
			static float m_vecMaxs_2[3];
			static float m_vecMins_2[3];
			static float f_pos[3];
			m_vecMaxs_2 = hullcheckmaxs;
			m_vecMins_2 = hullcheckmins;	
			f_pos = vecSwingEnd;
			TE_DrawBox(client, f_pos, m_vecMins_2, m_vecMaxs_2, 0.1, view_as<int>({255, 0, 0, 255}));
		}
	}
	*/

	ResolvePlayerCollisions_Npc_Internal(vecSwingEnd, hullcheckmins, hullcheckmaxs, iNPC);

	float vAngles[3], vDirection[3];								
	GetEntPropVector(iNPC, Prop_Data, "m_angRotation", vAngles); 								
	if(vAngles[0] > -45.0)
	{
		vAngles[0] = -45.0;
	}
	GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
	float knockback = 200.0;
	ScaleVector(vDirection, knockback);

	for (int entity_traced = 0; entity_traced < MAXENTITIES; entity_traced++)
	{
		if(!b_TouchedEntity[entity_traced])
			break;

		if(i_IsABuilding[entity_traced])
			continue;

		if(b_TouchedEntity[entity_traced] <= MaxClients)
		{
		//	TF2_AddCondition(b_TouchedEntity[entity_traced], TFCond_LostFooting, 0.1);
		//	TF2_AddCondition(b_TouchedEntity[entity_traced], TFCond_AirCurrent, 0.1);
			vDirection[0] += GetEntPropFloat(b_TouchedEntity[entity_traced], Prop_Send, "m_vecVelocity[0]");
			vDirection[1] += GetEntPropFloat(b_TouchedEntity[entity_traced], Prop_Send, "m_vecVelocity[1]");
			vDirection[2] = GetEntPropFloat(b_TouchedEntity[entity_traced], Prop_Send, "m_vecVelocity[2]");
		}
		
		SDKHooks_TakeDamage(b_TouchedEntity[entity_traced], iNPC, iNPC, damage, DMG_CRUSH, -1, _);
		if(CauseKnockback && GetTeam(iNPC) != TFTeam_Red)
		{
			if(b_NpcHasDied[b_TouchedEntity[entity_traced]])
			{
				Custom_SetAbsVelocity(b_TouchedEntity[entity_traced], vDirection);
			}
			else
			{
				CClotBody npc = view_as<CClotBody>(b_TouchedEntity[entity_traced]);
				npc.SetVelocity(vDirection);
			}
		}
	}

	Zero(b_TouchedEntity);
}

stock void ResolvePlayerCollisions_Npc_Internal(const float pos[3], const float mins[3], const float maxs[3],int entity=-1)
{
	TR_EnumerateEntitiesHull(pos, pos, mins, maxs, false, ResolvePlayerCollisionsTrace, entity);
}

public bool ResolvePlayerCollisionsTrace(int entity,int filterentity)
{
	if(IsValidEnemy(filterentity, entity, true, true)) //Must detect camo.
	{
		//This will automatically take care of all the checks, very handy. force it to also target invul enemies.
		for(int i=0; i < MAXENTITIES; i++)
		{
			if(!b_TouchedEntity[i])
			{
				b_TouchedEntity[i] = entity;
				break;
			}
		}
	}
	return true;
}

float GetRandomRetargetTime()
{
	return GetRandomFloat(3.0, 4.0);
}

void NpcStartTouch(int TouchedTarget, int target, bool DoNotLoop = false)
{
	int entity = TouchedTarget;
	CClotBody npc = view_as<CClotBody>(entity);
	if(!DoNotLoop && !b_NpcHasDied[target] && !IsEntityTowerDefense(target) && GetTeam(entity) != TFTeam_Stalkers) //If one entity touches me, then i touch them
	{
		NpcStartTouch(target, entity, true);
	}

	if(fl_GetClosestTargetTimeTouch[entity] < GetGameTime() && f_TimeFrozenStill[entity] < GetGameTime(npc.index))
	{
		if(npc.m_iTarget != target)
		{
			if(IsValidEnemy(target, entity, true, true)) //Must detect camo.
			{
				if(!b_DoNotChangeTargetTouchNpc[entity] || (b_DoNotChangeTargetTouchNpc[entity] && i_NpcIsABuilding[target]))
				{
					fl_GetClosestTargetTimeTouch[entity] = GetGameTime() + 0.2; //Delay to itdoesnt kill server performance, even if its really cheap.
				//	if(target > MaxClients || GetRandomFloat(0.0, 1.0) < 0.25)
				//	a 25% chance that they will change targets, so they sometimes dont want to follow you, but only if yorue a client.
					{
						npc.m_iTarget = target;
						npc.m_flGetClosestTargetTime = GetGameTime(entity) + GetRandomRetargetTime();
						f_DelayComputingOfPath[entity] = 0.0;
						//for tower defense.
						f3_WasPathingToHere[entity][0] = 0.0;
						f3_WasPathingToHere[entity][1] = 0.0;
						f3_WasPathingToHere[entity][2] = 0.0;
						i_WasPathingToHere[entity] = target;
					}
				}
			}
			//not valid enemy somehow, we dont do anything.
		}
		else
		{
			npc.m_flGetClosestTargetTime = GetGameTime(entity) + GetRandomRetargetTime();
		}
	}
}

public void MakeEntityRagdollNpc(int pThis)  
{
	CClotBody npc = view_as<CClotBody>(pThis);
	float Push[3];
	npc.m_vecpunchforce(Push, false);
	ScaleVector(Push, 2.0);
	if(Push[0] > 10000000.0 || Push[1] > 10000000.0 || Push[2] > 10000000.0 || Push[0] < -10000000.0 || Push[1] < -10000000.0 || Push[2] < -10000000.0) //knockback is way too huge. set to 0.
	{
		Push[0] = 1.0;
		Push[1] = 1.0;
		Push[2] = 1.0;
	}

#if defined ZR
	if(b_RaptureZombie[pThis])
	{
		if(GetRandomFloat(0.0, 1.01) > 1.0)
		{
			Push[0] = 0.0;
			Push[1] = 0.0;
			Push[2] = 99999.0;
		}
	}
#endif

	SDKCall_BecomeRagdollOnClient(pThis, Push);
}


public MRESReturn CTFBaseBoss_Ragdoll(int pThis, Handle hReturn, Handle hParams)  
{
	CClotBody npc = view_as<CClotBody>(pThis);
	float Push[3];
	npc.m_vecpunchforce(Push, false);
	ScaleVector(Push, 2.0);
	if(Push[0] > 10000000.0 || Push[1] > 10000000.0 || Push[2] > 10000000.0 || Push[0] < -10000000.0 || Push[1] < -10000000.0 || Push[2] < -10000000.0) //knockback is way too huge. set to 0.
	{
		Push[0] = 1.0;
		Push[1] = 1.0;
		Push[2] = 1.0;
	}
	DHookSetParamVector(hParams, 2, view_as<float>(Push));
//	RequestFrames(Kill_Npc, 5, EntIndexToEntRef(pThis));		
	//Play Ragdolls correctly.
		
	DHookSetReturn(hReturn, true);
	return MRES_ChangedOverride;
}

void RemoveNpcFromEnemyList(int npc, bool ingoresetteam = false)
{
	if(!ingoresetteam)
		SetTeam(npc, TFTeam_Red);
		
	//set to red just incase!
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //BLUE npcs.
	{
		int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
		if(IsValidEntity(npc))
		{
			if(npc == entity_close)
			{
				i_ObjectsNpcsTotal[entitycount] = -1; //remove from the list
				break;
			}
		}
	}	
}

bool MovementSpreadSpeedTooLow(float SubjectAbsVelocity[3])
{
	static float SubjectAbsVel[3];
	SubjectAbsVel = SubjectAbsVelocity;
	for(int Repeat; Repeat <3; Repeat ++)
	{
		if(SubjectAbsVel[Repeat] < 0.0)
		{
			SubjectAbsVel[Repeat] *= -1.0;
		}
	}
	if(SubjectAbsVel[0] <= 20.0 && SubjectAbsVel[1] <= 20.0 && SubjectAbsVel[2] <= 20.0)
	{
		return true;
	}
	return false;
}


bool BulletAndMeleeTrace_MultiNpcTrace(int entity, int contentsMask, int iExclude)
{
	if(entity == 0)
	{
		return false;
	}
	if(entity == iExclude)
	{
		return false;
	}
	if(!IsValidEnemy(iExclude, entity, true, true)) //Must detect camo.
	{
		return false;
	}
	bool type = BulletAndMeleeTracePlayerAndBaseBossOnly(entity, 0, iExclude);
	if(!type) //if it collised, return.
	{
		return false;
	}

	if(!SwingTraceMultiAoeIsInFront(iExclude, entity))
		return false;

	for(int i=1; i <= (i_EntitiesHitAtOnceMax_NpcSwing); i++)
	{
		if(i_EntitiesHitAoeSwing_NpcSwing[i] <= 0)
		{
			i_EntitiesHitAoeSwing_NpcSwing[i] = entity;
			break;
		}
	}
	return false;
}
bool BulletAndMeleeTrace_MultiNpcPlayerAndBaseBossOnly(int entity, int contentsMask, int iExclude)
{
	if(entity == 0)
	{
		return false;
	}
	if(entity == iExclude)
	{
		return false;
	}
	if(!IsValidEnemy(iExclude, entity, true, true)) //Must detect camo.
	{
		return false;
	}
	bool type = BulletAndMeleeTracePlayerAndBaseBossOnly(entity, 0, iExclude);
	if(!type) //if it collised, return.
	{
		return false;
	}
	if(!SwingTraceMultiAoeIsInFront(iExclude, entity))
		return false;

	for(int i=1; i <= (i_EntitiesHitAtOnceMax_NpcSwing); i++)
	{
		if(i_EntitiesHitAoeSwing_NpcSwing[i] <= 0)
		{
			i_EntitiesHitAoeSwing_NpcSwing[i] = entity;
			break;
		}
	}
	return false;
}

#define SWINGPITCHMAX_MAXANGLEPITCH	 90.0
bool SwingTraceMultiAoeIsInFront(int owner, int enemy)
{
	float pos1[3];
	float pos2[3];
	float ang3[3];
	float ang2[3];
	GetEntPropVector(owner, Prop_Data, "m_vecAbsOrigin", pos2);	
	GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", pos1);	

	
	float pos4test;
	pos4test = pos1[2] - pos2[2];
	
	if(pos4test > 75.0) //far above me, just hit.
	{
		return true;
	}
	GetVectorAnglesTwoPoints(pos2, pos1, ang3);
	GetEntPropVector(owner, Prop_Data, "m_angRotation", ang2);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);


	if(!(fabs(ang2[1] - ang3[1]) <= SWINGPITCHMAX_MAXANGLEPITCH || (fabs(ang2[1] - ang3[1]) >= (360.0-SWINGPITCHMAX_MAXANGLEPITCH))))
	{
		return false;
	}

	return true;
}

bool DelayPathing(int npcpather)
{
	if(f_DelayComputingOfPath[npcpather] < GetGameTime())
		return true;
	
	if(b_AvoidObstacleType[npcpather])
	{
		//they are currently treading carefully.
		//check if its a stair
		float CurrentLocation[3];
		GetEntPropVector(npcpather, Prop_Data, "m_vecAbsOrigin", CurrentLocation);
		float VecHullMin[3];
		VecHullMin = f3_AvoidOverrideMinNorm[npcpather];
		float VecHullMax[3];
		VecHullMax = f3_AvoidOverrideMaxNorm[npcpather];
		VecHullMin[2] -= 15.0;
		VecHullMax[0] *= 1.35;
		VecHullMax[1] *= 1.35;
		VecHullMax[2] *= 1.35;
		VecHullMin[0] *= 1.35;
		VecHullMin[1] *= 1.35;

		if(IsBoxStairCase(CurrentLocation, VecHullMin, VecHullMax))
		{
			return true;
		}
	}

	return false;
}
bool BoxStairResult;
stock bool IsBoxStairCase(const float pos1[3],const float mins[3],const float maxs[3])
{
	BoxStairResult = false;
	TR_EnumerateEntitiesHull(pos1, pos1, mins, maxs, PARTITION_TRIGGER_EDICTS, TraceEntityEnumerator_EnumerateTriggers_StairTrigger, _);
	return BoxStairResult;
}

public bool TraceEntityEnumerator_EnumerateTriggers_StairTrigger(int entity, int client)
{
	char classname[32];
	if(!GetEntityClassname(entity, classname, sizeof(classname)))
		return true;

	if((!StrContains(classname, "trigger_multiple")))
	{
		char name[32];
		if(GetEntPropString(entity, Prop_Data, "m_iName", name, sizeof(name)) && StrEqual(name, "zr_anti_stair_abuse"))
		{
			Handle trace = TR_ClipCurrentRayToEntityEx(MASK_ALL, entity);
			bool didHit = TR_DidHit(trace);
			delete trace;
			
			if (didHit)
			{
				BoxStairResult = true;
				return false;
			}
		}
	}
	
	return true;
}

void AddDelayPather(int npcpather, const float DistanceCheap[3])
{
	float AddComputingDelay = 0.0;

	if(b_thisNpcIsARaid[npcpather])
	{
		AddComputingDelay += 0.2;
		f_DelayComputingOfPath[npcpather] = GetGameTime() + AddComputingDelay;
	}
	else
	{
		CClotBody npc = view_as<CClotBody>(npcpather);
		float Length1 = npc.GetPathFollower().GetLength();
		float DistanceCheap_pather[3];
		GetEntPropVector(npcpather, Prop_Data, "m_vecAbsOrigin", DistanceCheap_pather);
		float Length2 = GetVectorDistance(DistanceCheap_pather, DistanceCheap);
		if(Length2 < 500.0)// close enough, update pather often.
		{
			AddComputingDelay += 0.3;
		}
		else
		{
			AddComputingDelay += 0.3 + (Length2 * 0.0005);
		}

		if(Length1 > 0.0)
			f_DelayComputingOfPath[npcpather] = GetGameTime() + AddComputingDelay;
		else
			f_DelayComputingOfPath[npcpather] = GetGameTime() + 0.1;
	}
}

stock void SmiteNpcToDeath(int entity)
{
	if(!b_ThisWasAnNpc[entity])
		return;
		
	SDKHooks_TakeDamage(entity, 0, 0, 199999999.0, DMG_BLAST, -1, _, _, _, ZR_SLAY_DAMAGE); // 2048 is DMG_NOGIB?
	CBaseCombatCharacter_EventKilledLocal(entity, 0, 0, 1.0, DMG_SLASH, -1, {0.0,0.0,0.0}, {0.0,0.0,0.0});
}

void MapStartResetNpc()
{
	for(int i=0; i < MAXENTITIES; i++)
	{
		b_ThisWasAnNpc[i] = false;
		b_NpcHasDied[i] = true;
		b_StaticNPC[i] = false;
		b_EnemyNpcWasIndexed[i][0] = false;
		b_EnemyNpcWasIndexed[i][1] = false;
	}
	EnemyNpcAlive = 0;
	EnemyNpcAliveStatic = 0;
}

/*
	0 means normal enemy
	1 means static
*/
void AddNpcToAliveList(int iNpc, int which)
{
	if(which == 0 && !b_EnemyNpcWasIndexed[iNpc][0])
	{
		b_EnemyNpcWasIndexed[iNpc][0] = true;
		EnemyNpcAlive += 1;
	}
	if(which == 1)
	{
		if(!b_EnemyNpcWasIndexed[iNpc][0])
		{
			b_EnemyNpcWasIndexed[iNpc][0] = true;
			EnemyNpcAlive += 1;
		}
		if(!b_EnemyNpcWasIndexed[iNpc][1])
		{
			b_EnemyNpcWasIndexed[iNpc][1] = true;
			EnemyNpcAliveStatic += 1;
		}
	}
}

void RemoveFromNpcAliveList(int iNpc)
{
	if(b_EnemyNpcWasIndexed[iNpc][0])
		EnemyNpcAlive -= 1;

	if(b_EnemyNpcWasIndexed[iNpc][1])
		EnemyNpcAliveStatic -= 1;

	b_EnemyNpcWasIndexed[iNpc][0] = false;
	b_EnemyNpcWasIndexed[iNpc][1] = false;

	if(EnemyNpcAlive < 0)
		EnemyNpcAlive = 0;

	if(EnemyNpcAliveStatic < 0)
		EnemyNpcAliveStatic = 0;
}

#if defined ZR
bool RaidAllowsBuildings = false;
#endif

stock bool RaidbossIgnoreBuildingsLogic(int value = 0)
{
#if defined ZR
	switch(value)
	{
		//if a raidboss exists, but we have a rule to make it still target buildings, set to true!
		case 1:
		{
			if(RaidAllowsBuildings)
				return false;

			if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				//do ignore
				return true;
			}
			//do not ignore
		}
		//same as above, but if it has the tower defense mode on, also ignore
		case 2:
		{
			if(RaidAllowsBuildings)
				return false;

			if(!VIPBuilding_Active() && IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				//do ignore
				return true;
			}

			//do not ignore
		}
		default:
		{
			//just to see if a raid is existant
			if(IsValidEntity(EntRefToEntIndex(RaidBossActive)))
			{
				return true;
			}
		}
	}
#endif
	return false;
}

stock void EntityIsInHazard_Teleport(int entity)
{
	float AbsOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
	static float hullcheckmaxs_Player[3];
	static float hullcheckmins_Player[3];
	hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
	hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );		
	if(b_IsGiant[entity])
	{
		hullcheckmaxs_Player = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins_Player = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else
	{
		hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	/*
	if(b_NpcResizedForCrouch[entity])
	{
		hullcheckmaxs_Player[2] = 41.0;
	}	
	*/	
	if(IsBoxHazard(AbsOrigin, hullcheckmins_Player, hullcheckmaxs_Player))
	{
		TeleportBackToLastSavePosition(entity);
	}
}

public void TeleportBackToLastSavePosition(int entity)
{
	if(f3_VecTeleportBackSave_OutOfBounds[entity][0] != 0.0)
	{
		b_npcspawnprotection[entity] = true;
		CreateTimer(3.0, Remove_Spawn_Protection, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		f_GameTimeTeleportBackSave_OutOfBounds[entity] = GetGameTime() + 2.0; //was stuck, lets just chill.
		TeleportEntity(entity, f3_VecTeleportBackSave_OutOfBounds[entity], NULL_VECTOR ,{0.0,0.0,0.0});
		if(b_ThisWasAnNpc[entity])
		{
			//freeze the NPC so they can repath their logic, and also not constantly fall off.
			f_DelayComputingOfPath[entity] = 0.0;
			FreezeNpcInTime(entity, 0.5);
			CClotBody npcBase = view_as<CClotBody>(entity);
			npcBase.m_iTarget = 0;
			//make them lose their target.
		}
	}
}

public void SaveLastValidPositionEntity(int entity)
{
	//first see if they are on the ground
	if(f_GameTimeTeleportBackSave_OutOfBounds[entity] > GetGameTime())
		return;

	f_GameTimeTeleportBackSave_OutOfBounds[entity] = GetGameTime() + GetRandomFloat(1.5, 2.2);
	//dont save location too often

	if(entity <= MaxClients)
	{
		if (!IsPlayerAlive(entity))
			return;
		
		/*
		additional logic, if they are on a slope, make sure they cant slide on it
		*/
		bool SavePosition = true;
		if (!(GetEntityFlags(entity) & FL_ONGROUND))
		{
			SavePosition = false;
		}
		else
		{
			int RefGround =  GetEntPropEnt(entity, Prop_Send, "m_hGroundEntity");
			int GroundEntity = EntRefToEntIndex(RefGround);
			if(GroundEntity > 0 && GroundEntity < MAXENTITIES)
			{
				if(!b_NpcHasDied[GroundEntity])
				{
					SavePosition = false;
				}
			}
		}
		
		float AbsOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];
		hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	
		b_AntiSlopeCamp[entity] = false;
		if(!SavePosition)
		{
			float AbsOrigin_after[3];
			AbsOrigin_after = AbsOrigin;
			AbsOrigin_after[2] -= 5.0;
			TR_TraceHullFilter(AbsOrigin, AbsOrigin_after, hullcheckmins_Player, hullcheckmaxs_Player, MASK_PLAYERSOLID_BRUSHONLY, TraceRayHitWorldOnly, entity);
			if(TR_DidHit())
			{
				// Gets the normal vector of the surface under the player
				float vPlane[3];
				TR_GetPlaneNormal(INVALID_HANDLE, vPlane);
				
				// Make sure it's not flat ground and not a surf ramp (1.0 = flat ground, < 0.7 = surf ramp)
				if(0.7 >= vPlane[2])
				{
					b_AntiSlopeCamp[entity] = true;
				}
			}
			return;
		}
	
		if(IsBoxHazard(AbsOrigin, hullcheckmins_Player, hullcheckmaxs_Player))
			return;

		//This should be a safe space for us to save the location for later teleporting.
		f3_VecTeleportBackSave_OutOfBounds[entity] = AbsOrigin;
	}
	else
	{
		//This is an npc!
		CClotBody npc = view_as<CClotBody>(entity);

		//do not save when in air
		if (!npc.IsOnGround())
			return;
			
		float AbsOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];
		if(b_IsGiant[entity])
		{
			hullcheckmaxs_Player = view_as<float>( { 30.0, 30.0, 120.0 } );
			hullcheckmins_Player = view_as<float>( { -30.0, -30.0, 0.0 } );	
		}
		else
		{
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );			
		}
		if(IsBoxHazard(AbsOrigin, hullcheckmins_Player, hullcheckmaxs_Player))
			return;

		//This should be a safe space for us to save the location for later teleporting.
		f3_VecTeleportBackSave_OutOfBounds[entity] = AbsOrigin;		
	}
}

char ch_SpeechBubbleTotalText[MAXENTITIES][255];
int i_SpeechBubbleTotalText_ScrollingPart[MAXENTITIES];
char ch_SpeechBubbleEndingScroll[MAXENTITIES][10];
int i_SpeechEndingScroll_ScrollingPart[MAXENTITIES];
float f_SpeechTickDelay[MAXENTITIES];
float f_SpeechDeleteAfter[MAXENTITIES];

/**
 * @param endingtextscroll	Is end text that loops "" -> "." -> ".." -> "..." -> ""
 */
stock void NpcSpeechBubble(int entity, const char[] speechtext, int fontsize, int colour[4], float extra_offset[3], const char[] endingtextscroll)
{
	int Text_Entity;
	Text_Entity = EntRefToEntIndex(i_SpeechBubbleEntity[entity]);
	if(IsValidEntity(Text_Entity))
		RemoveEntity(Text_Entity);

	Text_Entity = SpawnFormattedWorldText("", extra_offset, fontsize,colour, entity);
	
	DispatchKeyValue(Text_Entity, "font", "9");
	f_SpeechTickDelay[entity] = 0.0;
	f_SpeechDeleteAfter[entity] = 0.0;

	i_SpeechBubbleEntity[entity] = EntIndexToEntRef(Text_Entity);
	Format(ch_SpeechBubbleTotalText[entity], 255, speechtext);
	Format(ch_SpeechBubbleEndingScroll[entity], 10, endingtextscroll);
	i_SpeechBubbleTotalText_ScrollingPart[entity] = 0;
	i_SpeechEndingScroll_ScrollingPart[entity] = 0;
	SDKUnhook(entity, SDKHook_Think, NpcSpeechBubbleTalk);
	SDKHook(entity, SDKHook_Think, NpcSpeechBubbleTalk);
}

void NpcSpeechBubbleTalk(int iNPC)
{
	int Text_Entity;
	Text_Entity = EntRefToEntIndex(i_SpeechBubbleEntity[iNPC]);
	if(!IsValidEntity(Text_Entity))
	{
		SDKUnhook(iNPC, SDKHook_Think, NpcSpeechBubbleTalk);
		return;
	}
	if(f_SpeechTickDelay[iNPC] > GetGameTime())
		return;
	
	f_SpeechTickDelay[iNPC] = GetGameTime() + 0.05;
	int TotalLength = strlen(ch_SpeechBubbleTotalText[iNPC]);

	if(i_SpeechBubbleTotalText_ScrollingPart[iNPC] >= TotalLength)
	{
		if(f_SpeechDeleteAfter[iNPC] != 0.0)
		{
			TotalLength = strlen(ch_SpeechBubbleEndingScroll[iNPC]);
			char TestMax[255];
			char TestMaxEnd[255];
			i_SpeechEndingScroll_ScrollingPart[iNPC] += 1;
			int MaxTextCutoff = i_SpeechEndingScroll_ScrollingPart[iNPC];
			Format(TestMaxEnd, MaxTextCutoff, ch_SpeechBubbleEndingScroll[iNPC]);
			f_SpeechTickDelay[iNPC] = GetGameTime() + 0.5;
			if(i_SpeechEndingScroll_ScrollingPart[iNPC] > TotalLength)
			{
				i_SpeechEndingScroll_ScrollingPart[iNPC] = 0;
			}

			Format(TestMax, sizeof(TestMax), "%s%s",ch_SpeechBubbleTotalText[iNPC],TestMaxEnd);
			DispatchKeyValue(Text_Entity, "message", TestMax);


			if(f_SpeechDeleteAfter[iNPC] < GetGameTime())
			{
				SDKUnhook(iNPC, SDKHook_Think, NpcSpeechBubbleTalk);
				RemoveEntity(Text_Entity);
			}
			return;
		}
		f_SpeechDeleteAfter[iNPC] = GetGameTime() + 5.0;
	}
	i_SpeechBubbleTotalText_ScrollingPart[iNPC] += 1;
	char TestMax[255];
	int MaxTextCutoff = i_SpeechBubbleTotalText_ScrollingPart[iNPC];
	Format(TestMax, MaxTextCutoff, ch_SpeechBubbleTotalText[iNPC]);
	DispatchKeyValue(Text_Entity, "message", TestMax);
}


#define PARTICLE_DISPATCH_FROM_ENTITY		(1<<0)
#define PARTICLE_DISPATCH_RESET_PARTICLES	(1<<1)

#define FIRSTPERSON 1
#define THIRDPERSON 2

Handle Timer_Ingition_Settings[MAXENTITIES] = {INVALID_HANDLE, ...};
bool ClientHasSetFire[MAXENTITIES][MAXTF2PLAYERS];

void IgniteTargetEffect(int target, int ViewmodelSetting = 0, int viewmodelClient = 0)
{
	if(ViewmodelSetting > 0)
	{
		for( int i = 0; i <= MaxClients; i++ ) 
		{
			ClientHasSetFire[target][i] = false;
		}
		if(Timer_Ingition_Settings[target] != null)
		{
			delete Timer_Ingition_Settings[target];
			Timer_Ingition_Settings[target] = null;
		}
		DataPack pack;
		Timer_Ingition_Settings[target] = CreateDataTimer(0.1, IgniteTimerVisual, pack, TIMER_REPEAT);
		pack.WriteCell(target);
		pack.WriteCell(EntIndexToEntRef(target));
		pack.WriteCell(ViewmodelSetting);
		pack.WriteCell(viewmodelClient);

	}
	else
	{
		TE_SetupParticleEffect("burningplayer_red", PATTACH_ABSORIGIN_FOLLOW, target);
		TE_WriteNum("m_bControlPoint1", target);	
		TE_SendToAll();		
	}
}

public Action IgniteTimerVisual(Handle timer, DataPack pack)
{
	pack.Reset();
	int targetoriginal = pack.ReadCell();
	int target = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(target))
	{
		Timer_Ingition_Settings[targetoriginal] = null;
		return Plugin_Stop;
	}	
	int InvisMode = pack.ReadCell();
	int ownerclient = pack.ReadCell();
	for( int client = 1; client <= MaxClients; client++ ) 
	{
		if (IsValidClient(client))
		{
			if(b_FirstPersonUsesWorldModel[client])
			{
				//always ignited.
				if(InvisMode == THIRDPERSON)
				{
					IngiteTargetClientside(target, client, true);
				}
				else
				{
					IngiteTargetClientside(target, client, false);
				}
				continue;		
			}
			if(ownerclient == client)
			{
				if(TF2_IsPlayerInCondition(client, TFCond_Taunting) || GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
				{
					//we are in third person
					//its invis in third person
					if(InvisMode == THIRDPERSON)
					{
						IngiteTargetClientside(target, client, false);
					}
					else
					{
						IngiteTargetClientside(target, client, true);
					}
					continue;		
				}
				else
				{
					if(InvisMode == THIRDPERSON)
					{
						IngiteTargetClientside(target, client, true);
					}
					else
					{
						IngiteTargetClientside(target, client, false);
					}
					continue;	
				}
			}
			else if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") != ownerclient || GetEntProp(client, Prop_Send, "m_iObserverMode") != 4)
			{
				/*
					is in third person
				*/
				if(InvisMode == THIRDPERSON)
				{
					IngiteTargetClientside(target, client, false);
				}
				else
				{
					IngiteTargetClientside(target, client, true);
				}
				continue;	
			}
			if(InvisMode == THIRDPERSON)
			{
				IngiteTargetClientside(target, client, true);
			}
			else
			{
				IngiteTargetClientside(target, client, false);
			}
		}
	}
	return Plugin_Continue;
}


void IngiteTargetClientside(int target, int client, bool ingite)
{
	if(ingite && !ClientHasSetFire[target][client])
	{
		ClientHasSetFire[target][client] = true;
		TE_SetupParticleEffect("burningplayer_red", PATTACH_ABSORIGIN_FOLLOW, target);
		TE_WriteNum("m_bControlPoint1", target);	
		TE_SendToClient(client);
	}
	else if(!ingite && ClientHasSetFire[target][client])
	{
		ClientHasSetFire[target][client] = false;
		TE_Start("EffectDispatch");
		
		if(target > 0)
			TE_WriteNum("entindex", target);
		
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex("burningplayer_red"));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToClient(client);	
	}

}
void ExtinguishTarget(int target)
{
	TE_Start("EffectDispatch");
	
	if(target > 0)
		TE_WriteNum("entindex", target);
	
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex("burningplayer_red"));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
	if(Timer_Ingition_Settings[target] != null)
	{
		delete Timer_Ingition_Settings[target];
		Timer_Ingition_Settings[target] = null;
	}
}




void IsEntityInvincible_Shield(int entity)
{
	if(!b_NpcIsInvulnerable[entity] || b_ThisEntityIgnored[entity])
	{
		IsEntityInvincible_ShieldRemove(entity);
		return;
	}
	if(IsValidEntity(i_InvincibleParticle[entity]))
	{
		int Shield = EntRefToEntIndex(i_InvincibleParticle[entity]);
		SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
		SetEntityRenderColor(Shield, 0, 255, 0, 255);
		return;
	}

	CClotBody npc = view_as<CClotBody>(entity);
	int Shield = npc.EquipItem("root", "models/effects/resist_shield/resist_shield.mdl");
	if(b_IsGiant[entity])
		SetVariantString("1.38");
	else
		SetVariantString("1.05");

	AcceptEntityInput(Shield, "SetModelScale");
	SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
	
	SetEntityRenderColor(Shield, 0, 255, 0, 255);
	SetEntProp(Shield, Prop_Send, "m_nSkin", 1);

	i_InvincibleParticle[entity] = EntIndexToEntRef(Shield);
}

void IsEntityInvincible_ShieldRemove(int entity)
{
	if(!IsValidEntity(i_InvincibleParticle[entity]))
		return;

	RemoveEntity(EntRefToEntIndex(i_InvincibleParticle[entity]));
	i_InvincibleParticle[entity] = INVALID_ENT_REFERENCE;
}


void MakeObjectIntangeable(int entity)
{
	SetEntityCollisionGroup(entity, 0); //Dont Touch Anything.
	SetEntProp(entity, Prop_Send, "m_usSolidFlags", 12); 
	SetEntProp(entity, Prop_Data, "m_nSolidType", 0);
}


static int BadSpotPoints[MAXTF2PLAYERS];
void Spawns_CheckBadClient(int client)
{
#if defined ZR
	if(!IsPlayerAlive(client) || TeutonType[client] != TEUTON_NONE)
	{
		BadSpotPoints[client] = 0;
		return;
	}
#else
	if(!IsPlayerAlive(client))
	{
		BadSpotPoints[client] = 0;
		return;
	}
#endif
#if defined RPG
	if(RPGCore_ClientTargetedByNpcReturn(client) < GetGameTime())
	{
		BadSpotPoints[client] = 0;
		return;
	}
#endif
	if(!(GetEntityFlags(client) & (FL_ONGROUND|FL_INWATER)))
	{
		BadSpotPoints[client]++;
		if(f_ClientInAirSince[client] > GetGameTime())
		{
			// In air or water
			return;
		}
	}
/*
#if defined ZR
	if(Waves_InSetup())
		return;
#endif
*/
	int RefGround =  GetEntPropEnt(client, Prop_Send, "m_hGroundEntity");
	int GroundEntity = EntRefToEntIndex(RefGround);
	if(GroundEntity > 0 && GroundEntity < MAXENTITIES)
	{
		//client is ontop of something, dont do more, they have some way to be put down.
		return;
	}


	int bad;

	float pos1[3];
	GetClientAbsOrigin(client, pos1);
	pos1[2] += 25.0;
	CNavArea area;
	area = TheNavMesh.GetNavArea(pos1, 65.0);
	//no nav area directly under them
	if(area == NULL_AREA)
	{
		pos1[2] -= 25.0;
		area = TheNavMesh.GetNearestNavArea(pos1, false, 55.0, false, true);
		if(area == NULL_AREA)
		{
			// Not near a nav mesh, bad
			bad = 5;
			BadSpotPoints[client] += 5;
		}
		else
		{
			int NavAttribs = area.GetAttributes();
			if(NavAttribs & NAV_MESH_DONT_HIDE)
			{
				//This nav is designated as bad, give them full points instantly.
				bad = 5;
				BadSpotPoints[client] = 45;
			}
		}
	}

	if(bad > 4)
	{
		if(BadSpotPoints[client] > 29)
		{
			float damage = 5.0;
			NpcStuckZoneWarning(client, damage, 0);	
			if(damage >= 0.25)
			{
				SDKHooks_TakeDamage(client, 0, 0, damage, DMG_DROWN|DMG_PREVENT_PHYSICS_FORCE, -1, _, _, _, ZR_STAIR_ANTI_ABUSE_DAMAGE);
			}
		}
	}
	else if(BadSpotPoints[client] > 0)
	{
		BadSpotPoints[client] -= 3;
	}

	/*
	public native bool BuildPath( CNavArea startArea, 
		CNavArea goalArea, 
		const float goalPos[3], 
		NavPathCostFunctor costFunc = INVALID_FUNCTION,
		CNavArea &closestArea = NULL_AREA, 
		float maxPathLength = 0.0,
		int teamID = TEAM_ANY,
		bool ignoreNavBlockers = false);
	*/
}
