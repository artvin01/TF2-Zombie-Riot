#pragma semicolon 1
#pragma newdecls required


#if defined ZR
bool b_NameNoTranslation[MAXENTITIES];
#endif

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

int dieingstate[MAXPLAYERS];
int TeutonType[MAXPLAYERS];
bool b_NpcHasBeenAddedToZombiesLeft[MAXENTITIES];
int Zombies_Currently_Still_Ongoing;
int RaidBossActive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what entref is the raid?
float Medival_Difficulty_Level = 0.0;
int Medival_Difficulty_Level_NotMath = 0;
bool b_ThisNpcIsImmuneToNuke[MAXENTITIES];
int i_NpcOverrideAttacker[MAXENTITIES];
bool b_thisNpcHasAnOutline[MAXENTITIES];

#endif
int i_KillsMade[MAXPLAYERS];
int i_Backstabs[MAXPLAYERS];
int i_Headshots[MAXPLAYERS];	

#if !defined RTS
int TeamFreeForAll = 50;
#endif
float f_LastBaseThinkTime[MAXENTITIES];

int i_TeamGlow[MAXENTITIES]={-1, ...};
int Shared_BEAM_Glow;
int Shared_BEAM_Laser;
char c_NpcName[MAXENTITIES][255];
int i_SpeechBubbleEntity[MAXENTITIES];
PathFollower g_NpcPathFollower[ZR_MAX_NPCS];
static int g_modelArrow;
//static int g_iResolveOffset;

float f3_AvoidOverrideMin[MAXENTITIES][3];
float f3_AvoidOverrideMax[MAXENTITIES][3];
float f3_AvoidOverrideMinNorm[MAXENTITIES][3];
float f3_AvoidOverrideMaxNorm[MAXENTITIES][3];
float f_AvoidObstacleNavTime[MAXENTITIES];
float f_LayerSpeedFrozeRestore[MAXENTITIES];
bool b_AvoidObstacleType[MAXENTITIES];
float b_AvoidObstacleType_Time[MAXENTITIES];
int i_FailedTriesUnstuck[MAXENTITIES][2];
//int i_MasterSequenceNpc[MAXENTITIES];
//float f_MasterSequenceNpcPlayBackRate[MAXENTITIES];
bool b_should_explode[MAXENTITIES];
bool b_rocket_particle_from_blue_npc[MAXENTITIES];
float fl_rocket_particle_dmg[MAXENTITIES];
float fl_rocket_particle_radius[MAXENTITIES];
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
Function FuncShowInteractHud[MAXENTITIES];

enum struct WearableColor
{
	int color;
	int wearableRef;
	ArrayList entities;
}

ArrayList h_ColoredWearables;

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
static const char g_HurtArmorSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

#if defined  BONEZONE_BASE

char        c_BoneZoneBuffedName[MAXENTITIES][255];
char        c_BoneZoneNonBuffedName[MAXENTITIES][255];

bool         b_BoneZoneNaturallyBuffed[MAXENTITIES];
bool         b_SetBuffedSkeletonAnimation[MAXENTITIES];
bool         b_SetNonBuffedSkeletonAnimation[MAXENTITIES];
bool         b_IsSkeleton[MAXENTITIES];
bool         b_BonesBuffed[MAXENTITIES];
int          i_BoneZoneSummoner[MAXENTITIES];
int          i_BoneZoneNonBuffedMaxHealth[MAXENTITIES];
int          i_BoneZoneBuffedMaxHealth[MAXENTITIES];
float        f_BoneZoneSummonValue[MAXENTITIES];
float        f_BoneZoneNumSummons[MAXENTITIES];
float        f_BoneZoneBuffedScale[MAXENTITIES];
float        f_BoneZoneNonBuffedScale[MAXENTITIES];
float        f_BoneZoneBuffedSpeed[MAXENTITIES];
float        f_BoneZoneNonBuffedSpeed[MAXENTITIES];
Handle       g_BoneZoneBuffers[MAXENTITIES];
Function     g_BoneZoneBuffFunction[MAXENTITIES];
Function     g_BoneZoneBuffVFX[MAXENTITIES];

// This is used exclusively for handling skeleton spawns via wave or command.
// If we spawn a NON-BUFFED skeleton with health different from its default max health, and the random buff chance succeeds and forces the buff,
// we need to make sure the buffed form's HP reflects the change. IE if Basic Bones, which normally has 300 HP, is spawned via wave config with 600 HP,
// that means it has double max HP. If the random buff chance happens, we need to make sure the buffed form also has double HP.
public void BoneZone_SetRandomBuffedHP(CClotBody npc)
{
    if (!IsValidEntity(npc.index))
        return;

    if (!npc.BoneZone_GetBuffedState())
        return;

    float current    = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
    float defaultMax = float(npc.m_iBoneZoneNonBuffedMaxHealth);
    float targetMax  = float(npc.m_iBoneZoneBuffedMaxHealth);
    float multiplier = current / defaultMax;

    SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", RoundFloat(targetMax * multiplier));
    SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
}

#endif

public Action Command_RemoveAll(int client, int args)
{
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
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
		ReplyToCommand(client, "[SM] Usage: sm_spawn_npc <plugin> [health] [data] [team] [damage multi] [speed multi] [ranged armour] [melee armour] [Extra Size] [Think Speed]");
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

		if(args > 9)
		{
			f_AttackSpeedNpcIncrease[entity] = GetCmdArgFloat(10);
		}
	}

	return Plugin_Handled;
}

float ReturnEntityAttackspeed(int iNpc)
{
	return f_AttackSpeedNpcIncrease[iNpc];
}

//I moved these up here so they can be precached, because the server crashes if a skeleton is gibbed and these aren't precached:
static char m_cGibModelSkeleton[][] = {
    "models/bots/skeleton_sniper/skeleton_sniper_gib_torso.mdl",
    "models/bots/skeleton_sniper/skeleton_sniper_gib_leg_l.mdl",
    "models/bots/skeleton_sniper/skeleton_sniper_gib_head.mdl"
};

void NPCStats_PluginStart()
{
	h_ColoredWearables = new ArrayList(sizeof(WearableColor));
	CreateTimer(5.0, NPCStats_Timer_HandlePaintedWearables, _, TIMER_REPEAT);
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
	for (int i = 0; i < (sizeof(g_HurtArmorSounds));   i++) { PrecacheSound(g_HurtArmorSounds[i]);   }
#if defined ZR
	for (int i = 0; i < (sizeof(g_TankStepSound));   i++) { PrecacheSoundCustom(g_TankStepSound[i]);   }
#endif
	for (int i = 0; i < (sizeof(g_RobotStepSound));   i++) { PrecacheSound(g_RobotStepSound[i]);   }
	
	g_sModelIndexBloodDrop = PrecacheModel("sprites/bloodspray.vmt");
	g_sModelIndexBloodSpray = PrecacheModel("sprites/blood.vmt");
	PrecacheSound("weapons/bottle_break.wav");
	PrecacheSound("npc/strider/striderx_pain8.wav");
	PrecacheSound("npc/strider/striderx_pain5.wav");
	
	PrecacheDecal("sprites/blood.vmt", true);
	PrecacheDecal("sprites/bloodspray.vmt", true);
	
	g_particleImpactMetal = PrecacheParticleSystem("bot_impact_light");
	g_particleImpactFlesh = PrecacheParticleSystem("blood_impact_red_01");
	g_particleImpactRubber = PrecacheParticleSystem("halloween_explosion_bits");
	g_particleImpactPortal = PrecacheParticleSystem("drg_cow_explosion_sparkles_blue");
	g_modelArrow = PrecacheModel("models/weapons/w_models/w_arrow.mdl");
	Shared_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Shared_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	PrecacheModel(ARROW_TRAIL);
	PrecacheDecal(ARROW_TRAIL, true);
	PrecacheModel(ARROW_TRAIL_RED);
	PrecacheDecal(ARROW_TRAIL_RED, true);

	//HookEntityOutput("trigger_multiple", "OnStartTouch", NPCStats_StartTouch);
	//HookEntityOutput("trigger_multiple", "OnEndTouch", NPCStats_EndTouch);

	Zero(f_TimeSinceLastStunHit);
//	Zero(b_EntityInCrouchSpot);
//	Zero(b_NpcResizedForCrouch);
//	Zero(b_PlayerIsInAnotherPart);
	Zero(b_EntityIsStairAbusing);
	Zero(f_PredictDuration);
	Zero(flNpcCreationTime);
	Zero2(f_PredictPos);
	
	PrecacheEffect("ParticleEffect");
	PrecacheEffect("ParticleEffectStop");
	PrecacheParticleEffect("burningplayer_corpse");

	for (int NpcIndexNumber = 0; NpcIndexNumber < ZR_MAX_NPCS; NpcIndexNumber++)
	{
		g_NpcPathFollower[NpcIndexNumber] = PathFollower(PathCost, Path_FilterIgnoreActors, Path_FilterOnlyActors);
	}

	#if defined BONEZONE_BASE
	for (int i = 0; i < (sizeof(g_BoneZoneBuffDefaultSFX)); i++)
	{
		PrecacheSound(g_BoneZoneBuffDefaultSFX[i]);
	}
	for (int i = 0; i < (sizeof(g_HHHGrunts)); i++)
	{
		PrecacheSound(g_HHHGrunts[i]);
	}
	for (int i = 0; i < (sizeof(g_HHHYells)); i++)
	{
		PrecacheSound(g_HHHYells[i]);
	}
	for (int i = 0; i < (sizeof(g_HHHLaughs)); i++)
	{
		PrecacheSound(g_HHHLaughs[i]);
	}
	for (int i = 0; i < (sizeof(g_HHHLaughs)); i++)
	{
		PrecacheSound(g_HHHLaughs[i]);
	}
	for (int i = 0; i < (sizeof(g_HHHPain)); i++)
	{
		PrecacheSound(g_HHHPain[i]);
	}
	for (int i = 0; i < (sizeof(g_WitchLaughs)); i++)
	{
		PrecacheSound(g_WitchLaughs[i]);
	}
	PrecacheSound(SOUND_DANGER_BIG_GUY_IS_HERE);
	PrecacheSound(SOUND_DANGER_KILL_THIS_GUY_IMMEDIATELY);
	PrecacheSound(SOUND_HHH_DEATH);
	PrecacheModel(BONEZONE_MODEL);
	PrecacheModel(BONEZONE_MODEL_BOSS);
	PrecacheModel(MODEL_SSB);
	PrecacheSound(SND_TRANSFORM);
	PrecacheSound(SND_GIB_SKELETON);

	for (int i = 0; i < sizeof(m_cGibModelSkeleton); i++)
	{
		PrecacheModel(m_cGibModelSkeleton[i], true);
	}
	#endif
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
#define NORMAL_NPC 0
#define STATIONARY_NPC 1

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
						bool Ally_Collideeachother = false,
						const float CustomThreeDimensionsextra[3] = {0.0,0.0,0.0},
						int NpcTypeLogic = NORMAL_NPC)
#endif
	{

		int npc;
		switch(NpcTypeLogic)
		{
			case NORMAL_NPC:
				npc = CreateEntityByName("zr_base_npc");
			case STATIONARY_NPC:
				npc = CreateEntityByName("zr_base_stationary");
		}
		
		CBaseNPC baseNPC = view_as<CClotBody>(npc).GetBaseNPC();

		DispatchKeyValueVector(npc, "origin",	 vecPos);
		DispatchKeyValueVector(npc, "angles",	 vecAng);
#if defined ZR
		if(!ModelReplaceDo(npc, Ally))
#endif
		{
			DispatchKeyValue(npc, "model",	 model);
			view_as<CBaseCombatCharacter>(npc).SetModel(model);
		}
		DispatchKeyValue(npc,	   "modelscale", modelscale);
		if(NpcTypeLogic == NORMAL_NPC) //No need for lagcomp on things that dont even move.
		{
			DispatchKeyValue(npc,	   "health",	 health);
		}
		
		i_IsNpcType[npc] = NpcTypeLogic;
		f_LastBaseThinkTime[npc] = GetGameTime();

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
#if defined ZR
		if(Construction_Mode())
		{
			b_NpcIgnoresbuildings[npc] = false;
		}
#endif
		if(NpcTypeLogic == NORMAL_NPC) //No need for lagcomp on things that dont even move.
		{
			AddEntityToLagCompList(npc);
		}
		else if(NpcTypeLogic == STATIONARY_NPC)
		{
			DispatchKeyValue(npc, "solid", "2");
		}
		
		b_NpcHasDied[npc] = false;
		i_FailedTriesUnstuck[npc][0] = 0;
		i_FailedTriesUnstuck[npc][1] = 0;
		flNpcCreationTime[npc] = GetGameTime();
		DispatchSpawn(npc); //Do this at the end :)

	//	if(NpcTypeLogic == NORMAL_NPC)
	//Crashes
	//		SetEntData(npc, FindSendPropInfo("CTFBaseBoss", "m_lastHealthPercentage") + g_iResolveOffset, false, 1, true);

		Hook_DHook_UpdateTransmitState(npc);
		SDKHook(npc, SDKHook_TraceAttack, NPC_TraceAttack);
		SDKHook(npc, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
		SDKHook(npc, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	

		if(NpcTypeLogic != STATIONARY_NPC)
		{
			SetEntProp(npc, Prop_Send, "m_bGlowEnabled", false);
			SetEntityMoveType(npc, MOVETYPE_CUSTOM);
		}
		else
		{
			SetEntProp(npc, Prop_Data, "m_iHealth", StringToInt(health));
			SetEntProp(npc, Prop_Data, "m_iMaxHealth", StringToInt(health));
		}

		CClotBody npcstats = view_as<CClotBody>(npc);
		SetEntProp(npc, Prop_Send, "m_fEffects", GetEntProp(npc, Prop_Send, "m_fEffects") | EF_NOSHADOW);

	
		//FIX: This fixes lookup activity not working.

#if defined RPG
		SetEntPropFloat(npc, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(npc, Prop_Send, "m_fadeMaxDist", 2000.0);
#endif
		//FIX: This fixes lookup activity not working.
		npcstats.StartActivity(0);
		npcstats.SetSequence(0);
		npcstats.SetPlaybackRate(1.0, true);
		npcstats.SetCycle(0.0);
		npcstats.ResetSequenceInfo();
		//FIX: This fixes lookup activity not working.
		if(NpcTypeLogic != STATIONARY_NPC)
		{

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
				baseNPC.flAcceleration = 9000.0;
				baseNPC.flFrictionSideways = 7.0;
			}
#endif

			SetEntProp(npc, Prop_Data, "m_bSequenceLoops", true);
		}
		//potentially newly added ? or might not get set ?
		//Just set it to true at all times.

#if defined ZR || defined RPG
		if(Ally == TFTeam_Red)
			SetEntityCollisionGroup(npc, 24);

		if(Ally != TFTeam_Red)
		{
			AddNpcToAliveList(npc, b_StaticNPC[npc] ? 1 : 0);
		}
#else
		AddNpcToAliveList(npc, 0);
#endif
			
		if(NpcTypeLogic != STATIONARY_NPC)
		{
			CBaseNPC_Locomotion locomotion = baseNPC.GetLocomotion();
			locomotion.SetCallback(LocomotionCallback_ShouldCollideWith, ShouldCollide_NpcLoco);
			locomotion.SetCallback(LocomotionCallback_IsEntityTraversable, IsEntityTraversable);
			locomotion.SetCallback(LocomotionCallback_ClimbUpToLedge, TriesClimbingUpLedge);
			npcstats.ZRHook_HandleAnimEvent(CBaseAnimating_HandleAnimEvent);
			h_NpcSolidHookType[npc] = DHookRaw(g_hGetSolidMask, true, view_as<Address>(baseNPC.GetBody()));
			SetEntProp(npc, Prop_Data, "m_bloodColor", -1); //Don't bleed
		}
		if(NpcTypeLogic == STATIONARY_NPC)
		{
			//These npcs cant be moved or slowed, so this should be indicated!
			ApplyStatusEffect(npc, npc, "Solid Stance", 999999.0);	
			ApplyStatusEffect(npc, npc, "Fluid Movement", 999999.0);	
		}
		

		SetEntityFlags(npc, FL_NPC);
		
		SetEntProp(npc, Prop_Data, "m_nSolidType", 2);
		
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
			if(CustomThreeDimensionsextra[1] != 0.0)
			{
				m_vecMins[0] = CustomThreeDimensionsextra[0];
				m_vecMins[1] = CustomThreeDimensionsextra[1];
				m_vecMins[2] = CustomThreeDimensionsextra[2];
			}
			else
			{
				m_vecMins[0] = -f3_CustomMinMaxBoundingBox[npc][0];
				m_vecMins[1] = -f3_CustomMinMaxBoundingBox[npc][1];
				m_vecMins[2] = 0.0;
			}
			f3_CustomMinMaxBoundingBoxMinExtra[npc][0] = CustomThreeDimensionsextra[0];
			f3_CustomMinMaxBoundingBoxMinExtra[npc][1] = CustomThreeDimensionsextra[1];
			f3_CustomMinMaxBoundingBoxMinExtra[npc][2] = CustomThreeDimensionsextra[2];
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
		if(NpcTypeLogic != STATIONARY_NPC)
		{
			baseNPC.SetBodyMaxs(m_vecMaxs);
			baseNPC.SetBodyMins(m_vecMins);
		}
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
		//	RemoveAllDamageAddition();
		}
#endif
		//Think once.
		if(NpcTypeLogic == STATIONARY_NPC)
		{
			CBaseCombatCharacter(npc).SetNextThink(GetGameTime());
		//	NpcBaseThink(npc);
		}
		npcstats.f_RegenLogicDo = GetGameTime() + 0.05;

		return view_as<CClotBody>(npc);
	}
	
	public void ZRHook_HandleAnimEvent(DHookCallback callback)
	{
		static DynamicHook hHook = null;
		if (hHook == null)
		{
			hHook = new DynamicHook(CBaseAnimating.iHandleAnimEvent(), HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity);
			if (hHook == null) return;
			hHook.AddParam(HookParamType_ObjectPtr);
		}
		h_NpcHandleEventHook[this.index] = hHook.HookEntity(Hook_Pre, this.index, callback);
	}
	property int index 
	{ 
		public get() { return view_as<int>(this); } 
	}
	public void PlayGibSound() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSound) - 1);
	
		EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	//	EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	//	EmitSoundToAll(g_GibSound[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayGibSoundMetal() { //ehehee this sound is funny 
		int sound = GetRandomInt(0, sizeof(g_GibSoundMetal) - 1);
	
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	//	EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
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
	
	property float m_flArmorCountMax
	{
		public get()							{ return fl_ArmorSetting[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_ArmorSetting[this.index][0] = TempValueForProperty; }
	}
	property float m_flArmorCount
	{
		public get()							{ return fl_ArmorSetting[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_ArmorSetting[this.index][1] = TempValueForProperty; }
	}
	property float m_flArmorProtect
	{
		public get()							{ return fl_ArmorSetting[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_ArmorSetting[this.index][2] = TempValueForProperty; }
	}

	property int m_iArmorGiven
	{
		public get()							{ return i_ArmorSetting[this.index][0]; }
		public set(int TempValueForProperty) 	{ i_ArmorSetting[this.index][0] = TempValueForProperty; }
	}
	property int m_iArmorType
	{
		public get()							{ return i_ArmorSetting[this.index][1]; }
		public set(int TempValueForProperty) 	{ i_ArmorSetting[this.index][1] = TempValueForProperty; }
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

	property float m_flAbilityOrAttack0
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack1
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack2
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack3
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack4
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flAbilityOrAttack5
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack6
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack7
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack8
	{
		public get()							{ return fl_AbilityOrAttack[this.index][8]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][8] = TempValueForProperty; }
	}

	property float m_flAbilityOrAttack9
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	public void PlayHurtArmorSound() 
	{
		if(this.m_flNextHurtSoundArmor > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSoundArmor = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtArmorSounds[GetRandomInt(0, sizeof(g_HurtArmorSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

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
	property float m_flGravityMulti
	{
		public get()							{ return fl_GravityMulti[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GravityMulti[this.index] = TempValueForProperty; }
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
	property int m_iCheckpointTarget
	{
		public get()		 
		{ 
			if(!b_ThisWasAnNpc[this.index])
				return 0;
				
			return this.GetProp(Prop_Data, "m_iTowerdefense_Target");
		}
		public set(int iInt) 
		{
			if(!b_ThisWasAnNpc[this.index])
				return;

			this.SetProp(Prop_Data, "m_iTowerdefense_Target", iInt); 
		}
	}
	property float f_RegenLogicDo
	{
		public get()		 
		{ 
			return this.GetPropFloat(Prop_Data, "f_RegenDoLogic");
		}
		public set(float iFloat) 
		{
			this.SetPropFloat(Prop_Data, "f_RegenDoLogic", iFloat); 
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
	property int m_iAnimationState
	{
		public get()							{ return i_AnimationState[this.index]; }
		public set(int TempValueForProperty) 	{ i_AnimationState[this.index] = TempValueForProperty; }
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
	property float m_flNextHurtSoundArmor
	{
		public get()							{ return fl_NextHurtSoundArmor[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextHurtSoundArmor[this.index] = TempValueForProperty; }
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
	
	property bool m_bAllowBackWalking
	{
		public get()				{ return b_AllowBackWalking[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AllowBackWalking[this.index] = TempValueForProperty; }
	}

	#if defined BONEZONE_BASE

	property int m_iBoneZoneNonBuffedMaxHealth
    {
		public get() { return i_BoneZoneNonBuffedMaxHealth[this.index]; }
		public set(int value) { i_BoneZoneNonBuffedMaxHealth[this.index] = value; }
	}

	property int m_iBoneZoneBuffedMaxHealth
    {
		public get() { return i_BoneZoneBuffedMaxHealth[this.index]; }
		public set(int value) { i_BoneZoneBuffedMaxHealth[this.index] = value; }
	}

	property float m_flBoneZoneBuffedScale
    {
		public get() { return f_BoneZoneBuffedScale[this.index]; }
		public set(float value) { f_BoneZoneBuffedScale[this.index] = value; }
	}

	property float m_flBoneZoneNonBuffedScale
    {
		public get() { return f_BoneZoneNonBuffedScale[this.index]; }
		public set(float value) { f_BoneZoneNonBuffedScale[this.index] = value; }
	}

	property float m_flBoneZoneBuffedSpeed
    {
		public get() { return f_BoneZoneBuffedSpeed[this.index]; }
		public set(float value) { f_BoneZoneBuffedSpeed[this.index] = value; }
	}

	property float m_flBoneZoneNonBuffedSpeed
    {
		public get() { return f_BoneZoneNonBuffedSpeed[this.index]; }
		public set(float value) { f_BoneZoneNonBuffedSpeed[this.index] = value; }
	}

	property bool m_bBoneZoneNaturallyBuffed
	{
		public get() { return b_BoneZoneNaturallyBuffed[this.index]; }
		public set(bool TempValueForProperty) { b_BoneZoneNaturallyBuffed[this.index] = TempValueForProperty; }
	}

	property bool m_blSetBuffedSkeletonAnimation
	{
		public get() { return b_SetBuffedSkeletonAnimation[this.index]; }
		public set(bool TempValueForProperty) { b_SetBuffedSkeletonAnimation[this.index] = TempValueForProperty; }
	}

	property bool m_blSetNonBuffedSkeletonAnimation
	{
		public get() { return b_SetNonBuffedSkeletonAnimation[this.index]; }
		public set(bool TempValueForProperty) { b_SetNonBuffedSkeletonAnimation[this.index] = TempValueForProperty; }
	}

	property bool m_bIsSkeleton
	{
		public get() { return b_IsSkeleton[this.index]; }
		public set(bool TempValueForProperty) { b_IsSkeleton[this.index] = TempValueForProperty; }
	}

	property int m_iBoneZoneSummoner
    {
		public get() { return i_BoneZoneSummoner[this.index]; }
		public set(int value) { i_BoneZoneSummoner[this.index] = value; }
	}

	property float m_flBoneZoneSummonValue
    {
		public get() { return f_BoneZoneSummonValue[this.index]; }
		public set(float value) { f_BoneZoneSummonValue[this.index] = value; }
	}

	property float m_flBoneZoneNumSummons
    {
		public get() { return f_BoneZoneNumSummons[this.index]; }
		public set(float value) { f_BoneZoneNumSummons[this.index] = value; }
	}

	property Handle g_BoneZoneBuffers
	{
		public get() { return g_BoneZoneBuffers[this.index]; }
		public set(Handle TempValueForProperty) { g_BoneZoneBuffers[this.index] = TempValueForProperty; }
	}

		// Updates the skeleton's name, depending on whether or not it is in its buffed form.
	public void BoneZone_UpdateName()
	{
		strcopy(c_NpcName[this.index], sizeof(c_NpcName[]), (b_BonesBuffed[this.index] ? c_BoneZoneBuffedName[this.index] : c_BoneZoneNonBuffedName[this.index]));
	}

	// Returns whether or not the NPC is a skeleton. This function is redundant, but was made before m_bIsSkeleton was implemented and I don't want to go back and edit all the NPCs that already use it.
	public bool BoneZone_IsASkeleton()
	{
		return this.m_bIsSkeleton;
	}

	//Returns whether or not the NPC is any type of medic.
	public bool BoneZone_IsASaint()
	{
		return Is_a_Medic[this.index];
	}

	// Returns whether or not the NPC is a buffed skeleton.
	public bool BoneZone_GetBuffedState()
	{
		return b_BonesBuffed[this.index];
	}

	// Retrieves the number of NPCs who are currently providing this skeleton with a buff.
	public int BoneZone_GetNumBuffers()
	{
		if (this.g_BoneZoneBuffers == null || !this.BoneZone_IsASkeleton())
			return 0;

		return GetArraySize(this.g_BoneZoneBuffers);
	}

	// Turns a non-buffed skeleton into a buffed one, or vice-versa.
	// Passing an invalid buffer will force the effect to go through
	// TODO: The max health set by this will need to account for later waves where skeletons have higher HP. Probably do this by comparing
	// its current max health to its actual max health, and then multiply the target max health accordingly.
	public void BoneZone_SetBuffedState(bool buffed, int buffer = -1)
	{
		// Skeletons which are already buffed when they spawn are completely ignored by this so that we don't accidentally remove their natural buff.
		// Maybe we can change this in the future so players can remove buffs via Silence, but that may be way too strong, so for now it stays like this.
		if (this.m_bBoneZoneNaturallyBuffed)
			return;

		bool AllBuffersGone = false;
		bool hadBuffAtStart = this.BoneZone_GetBuffedState();
		// If buffer is a valid entity, add it to the list of buffers or remove it.
		// This way, we can force the buffed state without specifying a buffer if we so choose.
		if (IsValidEntity(buffer))
		{
			// Add the buffer to the list if we are applying the buffed form:
			if (buffed)
			{
				if (this.g_BoneZoneBuffers == null)
					this.g_BoneZoneBuffers = CreateArray(16);

				bool DoNotAdd = false;
				for (int i = 0; i < GetArraySize(this.g_BoneZoneBuffers) && !DoNotAdd; i++)
				{
					int index = EntRefToEntIndex(GetArrayCell(this.g_BoneZoneBuffers, i));
					if (index == buffer)
					{
						DoNotAdd = true;
					}
				}

				if (!DoNotAdd)
					PushArrayCell(this.g_BoneZoneBuffers, EntIndexToEntRef(buffer));
			}
			else if (this.g_BoneZoneBuffers != null)    // Remove the buffer from the list if we are removing the buffed form, and then delete the list if it is empty:
			{
				for (int i = 0; i < GetArraySize(this.g_BoneZoneBuffers); i++)
				{
					int index = EntRefToEntIndex(GetArrayCell(this.g_BoneZoneBuffers, i));
					if (index == buffer)
					{
						RemoveFromArray(this.g_BoneZoneBuffers, i);
					}
				}

				if (GetArraySize(this.g_BoneZoneBuffers) < 1)
				{
					AllBuffersGone = true;
					delete this.g_BoneZoneBuffers;
				}
			}
		}

		// Add the buff if we are adding one, or remove it if we are trying to remove the buff and the list of buffers is empty:
		if (((buffed && !hadBuffAtStart) || AllBuffersGone) && g_BoneZoneBuffFunction[this.index] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, g_BoneZoneBuffFunction[this.index]);
			Call_PushCell(this.index);
			Call_PushCell(buffed);
			Call_Finish();

			bool hasBuffNow = this.BoneZone_GetBuffedState();

			if (hasBuffNow != hadBuffAtStart)
			{
				// Calculates the max health to give a skeleton based on scaling.
				// Example: In the waves config I specify Basic Bones should spawn with 1000 max health, when he normally has 500. This means he has double his max health.
				// Therefore, if we convert him to his buffed state, he needs to have double the buffed state's max health too.
				// Without this, wave config based health scaling does not play nice with the buffed forms gimmick. Also, barracks would be monstrously OP!
				// NOTE: DO NOT MODIFY MAX HEALTH IN THE SKELETON'S BUFF FUNCTION! THIS WILL CAUSE UNINTENDED RESULTS!
				float current    = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
				float defaultMax = float((hadBuffAtStart ? this.m_iBoneZoneBuffedMaxHealth : this.m_iBoneZoneNonBuffedMaxHealth));
				float targetMax  = float((hasBuffNow ? this.m_iBoneZoneBuffedMaxHealth : this.m_iBoneZoneNonBuffedMaxHealth));
				float multiplier = current / defaultMax;

				SetEntProp(this.index, Prop_Data, "m_iMaxHealth", RoundFloat(targetMax * multiplier));
				// Don't let skeletons keep excess health when they lose their buffed state.
				if (!buffed && GetEntProp(this.index, Prop_Data, "m_iHealth") > GetEntProp(this.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(this.index, Prop_Data, "m_iHealth", GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));
				}

				SetEntPropFloat(this.index, Prop_Send, "m_flModelScale", (hasBuffNow ? this.m_flBoneZoneBuffedScale : this.m_flBoneZoneNonBuffedScale));
				this.m_flSpeed = (hasBuffNow ? this.m_flBoneZoneBuffedSpeed : this.m_flBoneZoneNonBuffedSpeed);

				this.BoneZone_UpdateName();

				float skeleBuffPos[3];
				this.GetAbsOrigin(skeleBuffPos);

				if (g_BoneZoneBuffVFX[this.index] != INVALID_FUNCTION)
				{
					Call_StartFunction(null, g_BoneZoneBuffVFX[this.index]);
					Call_PushCell(this.index);
					Call_PushCell(hasBuffNow);
					Call_PushArray(skeleBuffPos, sizeof(skeleBuffPos));
					Call_Finish();
				}
				else
				{
					if (hasBuffNow)
					{
						ParticleEffectAt(skeleBuffPos, "spell_batball_impact_blue_3", 2.0);
						EmitSoundToAll(g_BoneZoneBuffDefaultSFX[GetRandomInt(0, sizeof(g_BoneZoneBuffDefaultSFX) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, _, GetRandomInt(90, 110));
					}
					else
					{
						WorldSpaceCenter(this.index, skeleBuffPos);
						ParticleEffectAt(skeleBuffPos, "bombinomicon_burningdebris_halloween_4", 2.0);
					}
				}
			}
		}
	}

	public void BoneZone_SetExtremeDangerState(bool dangerous)
	{
		if (dangerous)
		{
			EmitSoundToAll(SOUND_DANGER_BIG_GUY_IS_HERE, this.index, _, 120, _, _, 80);
			EmitSoundToAll(SOUND_DANGER_BIG_GUY_IS_HERE, this.index, _, 120, _, _, 80);
			EmitSoundToAll(SOUND_DANGER_KILL_THIS_GUY_IMMEDIATELY, this.index, _, 120);
			EmitSoundToAll(SOUND_DANGER_KILL_THIS_GUY_IMMEDIATELY, this.index, _, 120);
			float pos[3];
			WorldSpaceCenter(this.index, pos);
			ParticleEffectAt(pos, PARTICLE_DANGER_BIG_GUY_IS_HERE);
		}

		b_thisNpcIsABoss[this.index] = dangerous;
		GiveNpcOutLineLastOrBoss(this.index, dangerous);
	}
	#endif

	public void SetPoseParameter_Easy(char[] PoseParam = "", float Value)//For the future incase we want to alter it easier
	{
		int iPitch = this.LookupPoseParameter(PoseParam);
		if(iPitch < 0)
			return;		

		this.SetPoseParameter(iPitch, Value);
	}
	public float GetDebuffPercentage()//For the future incase we want to alter it easier
	{
		//Buildings dont have speed...
		if(i_IsNpcType[this.index] == 1)
		{
			return 1.0;
		}
		float speed_for_return = 1.0;
		float Gametime = GetGameTime();
		float GametimeNpc = GetGameTime(this.index);
		speed_for_return = fl_Extra_Speed[this.index];
		
#if defined RTS
		speed_for_return *= RTS_GameSpeed();
#endif

#if defined ZR
		if(IS_MusicReleasingRadio() && GetTeam(this.index) != TFTeam_Red)
			speed_for_return *= 0.9;

		if(i_CurrentEquippedPerk[this.index] & PERK_HASTY_HOPS)
		{
			speed_for_return *= 1.25;
		}
#endif
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
		
#if defined ZR
		if(MoraleBoostLevelAt(this.index) > 0)
		{
			speed_for_return *= EntityMoraleBoostReturn(this.index, 1);
		}
#endif

#if defined ZR
		SeabornVanguard_SpeedBuff(this, speed_for_return);	
#endif

#if defined RPG
		if(!b_thisNpcIsABoss[this.index] && !HasSpecificBuff(this.index, "Fluid Movement")) //Make sure that any slow debuffs dont affect these.
		{
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
		}
#endif

		return speed_for_return;
	}
	public float GetRunSpeed()//For the future incase we want to alter it easier
	{
		if(i_IsNpcType[this.index] == 1)
		{
			return 1.0;
		}
		if(GetEntPropFloat(this.index, Prop_Data, "f_ClimbingAm") > GetGameTime())
		{
			if(!this.IsOnGround())
				return 0.0;
		}
		else
		{
			SetEntProp(this.index, Prop_Data, "i_Climbinfractions", 0);
		}
#if defined ZR
		if(i_npcspawnprotection[this.index] == NPC_SPAWNPROT_ON)
		{
			if(!Rogue_Mode())
				return 400.0;
			else
			{
				switch(Rogue_Theme())
				{
					case BlueParadox:
					{
						return 1200.0;
					}
					default:
					{
						return 400.0;
					}
				}
			}
		}
#endif
		
		float GetPercentageAdjust = 1.0;
		GetPercentageAdjust = this.GetDebuffPercentage();	
		StatusEffect_SpeedModifier(this.index, GetPercentageAdjust);
		CBaseNPC baseNPC = view_as<CClotBody>(this.index).GetBaseNPC();

#if defined ZR
		if(GetTeam(this.index) != TFTeam_Red && Zombie_DelayExtraSpeed() != 1.0)
		{
			GetPercentageAdjust *= Zombie_DelayExtraSpeed();
		}
		else if(GetTeam(this.index) == TFTeam_Red)
		{
			if(VIPBuilding_Active())
			{
				GetPercentageAdjust *= 2.0;
				baseNPC.flAcceleration = (6000.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
				baseNPC.flFrictionSideways = (5.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
			}
		}

		if(!VIPBuilding_Active())
		{
			baseNPC.flAcceleration = (6000.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
			baseNPC.flFrictionSideways = (5.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
		}
#else
		baseNPC.flAcceleration = (6000.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
		baseNPC.flFrictionSideways = (5.0 * GetPercentageAdjust * f_NpcAdjustFriction[this.index]);
#endif
		//in freeplay there should be a speed limit, otherwise they will just have infinite speed and youre screwed.
		

#if defined ZR
		if(Waves_InFreeplay())
		{
			if((this.m_flSpeed * GetPercentageAdjust) > 500.0)
				return (500.0 * Zombie_DelayExtraSpeed());
		}
#endif
		return (this.m_flSpeed * GetPercentageAdjust);
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
	property int m_iHealthBar
	{
		public get()		 
		{ 
			if(!b_ThisWasAnNpc[this.index])
				return 0;
				
			return this.GetProp(Prop_Data, "m_iHealthBar");
		}
		public set(int iInt) 
		{
			if(!b_ThisWasAnNpc[this.index])
				return;

			this.SetProp(Prop_Data, "m_iHealthBar", iInt); 
		}
	}
	property int m_iTowerdefense_Checkpoint
	{
		public get()		 
		{ 
			if(!b_ThisWasAnNpc[this.index])
				return 0;
				
			return this.GetProp(Prop_Data, "m_iTowerdefense_CheckpointAt");
		}
		public set(int iInt) 
		{
			if(!b_ThisWasAnNpc[this.index])
				return;

			this.SetProp(Prop_Data, "m_iTowerdefense_CheckpointAt", iInt); 
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
	property int m_iWearable9
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][8]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][8] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][8] = EntIndexToEntRef(iInt);
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
		if(i_IsNpcType[this.index] == 1)
		{
			return true;
		}
		return this.GetLocomotionInterface().IsOnGround();
	}
	public int AddGesture(const char[] anim, bool cancel_animation = true, float duration = 1.0, bool autokill = true, float SetGestureSpeed = 1.0)
	{
		if(i_IsNpcType[this.index] == STATIONARY_NPC)
			return -1;
		//Will crash the server via corruption.
		
		int activity = this.LookupActivity(anim);
		if(activity < 0)
			return -1;
		
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
			this.SetLayerPlaybackRate(layer, (SetGestureSpeed / (ReturnEntityAttackspeed(this.index))));

		return layer;
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
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);
		this.m_iAnimationState = iSequence;
	
	}
	public int AddGestureViaSequence(const char[] anim)
	{
		int iSequence = this.LookupSequence(anim);
		if(iSequence < 0)
			return -1;
		
		return this.AddGestureSequence(iSequence);
	}
	public int FindAttachment(const char[] pAttachmentName)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hStudio_FindAttachment, pStudioHdr, pAttachmentName) + 1;
	}
	public void DispatchParticleEffect(int entity, const char[] strParticle, float flStartPos[3], float vecAngles[3], float flEndPos[3], 
									   int iAttachmentPointIndex = 0, ParticleAttachment_t iAttachType = PATTACH_CUSTOMORIGIN, bool bResetAllParticlesOnEntity = false)
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
			if(sequence > 0 && sequence != this.m_iAnimationState)
			{
				this.m_iAnimationState = sequence;
				this.m_iActivity = 0;
				
				this.SetSequence(sequence);
				this.ResetSequenceInfo();
				this.SetCycle(0.0);
				this.SetPlaybackRate(1.0);
			}
		}
		else
		{
			int activity = this.LookupActivity(animation);
			if(activity > 0 && activity != this.m_iAnimationState)
			{
				this.m_iAnimationState = activity;
				this.StartActivity(activity);
			}
		}
	}
	public void StartPathing()
	{
		if(IsEntityTowerDefense(this.index))
		{
			if(!this.m_bPathing)
			{
				this.GetPathFollower().SetMinLookAheadDistance(50.0);
				this.m_bPathing = true;
			}
			return;
		}
		if(!this.m_bPathing)
		{
			this.GetPathFollower().SetMinLookAheadDistance(50.0);	
		}
		this.m_bPathing = true;
	}
	public void StopPathing()
	{
		if(IsEntityTowerDefense(this.index))
		{
			this.StartPathing();
			//never ever stop.
			return;
		}
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
		if(IsEntityTowerDefense(this.index))
		{
			//this is entirely ignored.
			return;
		}
#if defined RTS
		if(IsObject(target) || i_IsABuilding[target] || i_IsVehicle[target] || i_IsNpcType[target] == 1)
#else
		if(i_IsABuilding[target] || i_IsVehicle[target] || i_IsNpcType[target] == 1)
#endif
		{
			//broken on targetting buildings...?
			float pos[3]; GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
			this.SetGoalVector(pos, false);
			return;
		}

		if(ignoretime || DelayPathing(this.index))
		{
			/*
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
			*/
			
			if(this.m_bPathing)
			{
				this.GetPathFollower().ComputeToTarget(this.GetBot(), target);
				float DistanceCheck[3];
				GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", DistanceCheck);
				AddDelayPather(this.index, DistanceCheck);
			}
		}
	}
	// BUGBUG: Why do we need both of these?
	public float UTIL_AngleDiff( float destAngle, float srcAngle )
	{
		float delta;

		delta = fmodf(destAngle - srcAngle, 360.0);
		if ( destAngle > srcAngle )
		{
			if ( delta >= 180.0 )
				delta -= 360.0;
		}
		else
		{
			if ( delta <= -180.0 )
				delta += 360.0;
		}
		return delta;
	}

	public float UTIL_VecToYaw(const float vec[3])
	{
		if (vec[1] == 0 && vec[0] == 0)
			return 0.0;
		
		float yaw = ArcTangent2( vec[1], vec[0] );

		yaw = RAD2DEG(yaw);

		if (yaw < 0)
			yaw += 360;

		return yaw;
	}
	public float UTIL_VecToPitch( const float vec[3])
	{
		if (vec[1] == 0 && vec[0] == 0)
		{
			if (vec[2] < 0)
				return 180.0;
			else
				return -180.0;
		}

		float dist = GetVectorLength(vec);
		float pitch = ArcTangent2( -vec[2], dist );

		pitch = RAD2DEG(pitch);

		return pitch;
	}
	public void SetGoalVector(const float vec[3], bool ignoretime = false)
	{	
		if(IsEntityTowerDefense(this.index))
		{
			//this is entirely ignored.
			return;
		}
		if(ignoretime || DelayPathing(this.index))
		{
			/*
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
			*/
			
			if(this.m_bPathing)
			{
				this.GetPathFollower().ComputeToPos(this.GetBot(), vec);
				AddDelayPather(this.index, vec);
			}
		}
	}
	public void SetGoalTowerDefense(const float vec[3])
	{	
		this.GetPathFollower().ComputeToPos(this.GetBot(), vec);
	}
	public void FaceTowards(float vecGoal[3], float turnrate = 250.0, bool TurnOnWalk = false)
	{
		//Sad!
		//Dont use face towards, why?
		// It updates UpdateCollisionBounds for some reason, this is entgirely unneccecary beacuse this is ONLY needed for hte tank, anyone else does not need this
		//This just destroys performance as this is called every.single.frame.
//		float flPrevValue = this.GetBaseNPC().flMaxYawRate;
		
//		this.GetBaseNPC().flMaxYawRate = turnrate;
//		this.GetLocomotionInterface().ZR_Self_FaceTowards(vecGoal);
//		this.GetBaseNPC().flMaxYawRate = flPrevValue;

		/*
			CIRBaseNPCLocomotion*pNpcLoco = GetLocomotionInterface();

			const float deltaT = pNpcLoco->GetUpdateInterval();

			QAngle angles = GetLocalAngles();

			float desiredYaw = UTIL_VecToYaw( target - pNpcLoco->GetFeet() );

			float angleDiff = UTIL_AngleDiff( desiredYaw, angles.y );

			float deltaYaw = TurnRate * deltaT;

			if ( angleDiff < -deltaYaw )
			{
				angles.y -= deltaYaw;
			}
			else if ( angleDiff > deltaYaw )
			{
				angles.y += deltaYaw;
			}
			else
			{
				angles.y += angleDiff;
			}
		*/
		float deltaT = 0.015;
		//I am dumb, we accidentally made it scale with tickrate....
		//facepalm.
		if(TurnOnWalk)
		{
			deltaT = GetTickInterval();
		}

		float angles[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", angles);
		float AbsOrigin[3];
		GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
		float SubractedVec[3];
		AbsOrigin[2] += 1.0;
		SubractedVec[0] = vecGoal[0] - AbsOrigin[0];
		SubractedVec[1] = vecGoal[1] - AbsOrigin[1];
		SubractedVec[2] = vecGoal[2] - AbsOrigin[2];
		float desiredYaw = this.UTIL_VecToYaw( SubractedVec );
		float angleDiff = this.UTIL_AngleDiff( desiredYaw, angles[1] );
		
		float deltaYaw = turnrate * deltaT;
		angleDiff = fixAngle(angleDiff);
		if ( angleDiff < -deltaYaw )
		{
			angles[1] -= deltaYaw;
		}
		else if ( angleDiff > deltaYaw )
		{
			angles[1] += deltaYaw;
		}
		else
		{
			angles[1] += angleDiff;
		}

		SDKCall_SetLocalAngles(this.index, angles);
	}

			
	public float GetMaxJumpHeight()	{ return this.GetLocomotionInterface().GetMaxJumpHeight(); }
	public float GetGroundSpeed()	
	{
		 return this.GetLocomotionInterface().GetGroundSpeed(); 
	}
	public int SelectWeightedSequence(any activity) { return view_as<CBaseAnimating>(view_as<int>(this)).SelectWeightedSequence(activity); }
	
	public bool GetAttachment(const char[] szName, float absOrigin[3], float absAngles[3]) { return view_as<CBaseAnimating>(view_as<int>(this)).GetAttachment(view_as<CBaseAnimating>(view_as<int>(this)).LookupAttachment(szName), absOrigin, absAngles); }
	public void Approach(const float vecGoal[3])										   { this.GetLocomotionInterface().Approach(vecGoal, 0.1);						}
	public void Jump()																	 { this.GetLocomotionInterface().Jump();										  }
	public void GetVelocity(float vecOut[3])											   { this.GetLocomotionInterface().GetVelocity(vecOut);						   }	
	public void SetVelocity(const float vec[3])	
	{
		if(i_IsNpcType[this.index] == 1)
			return;
		//dont do anything.
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
	public void SetPlaybackRate(float flRate, bool DontAlter = false) 
	{
		if(DontAlter || flRate == 0.0)
		{
			SetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate", flRate);
			return;
		}
	//	PrintToChatAll(" Speed playback %f",flRate / ReturnEntityAttackspeed(this.index));
		SetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate", (flRate / ReturnEntityAttackspeed(this.index)));
	}
	public void SetCycle(float flCycle)	   
	{
		SetEntPropFloat(this.index, Prop_Send, "m_flCycle", flCycle); 
	}
	
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

		if(model_size != 1.0)
		{
		//	DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
			DispatchKeyValueFloat(item, "modelscale", model_size);
		}
		DispatchSpawn(item);
		SetEntProp(item, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_PARENT_ANIMATES|EF_NOSHADOW );
		SetEntityMoveType(item, MOVETYPE_NONE);
		SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
	
		if(anim[0])
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}
		b_ThisEntityIgnored[item] = true;

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
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
		if(DontParent)
		{
			return item;
		}
		

		if(!StrEqual(anim, ""))
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}
		b_ThisEntityIgnored[item] = true;

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
		
		if(i_IsVehicle[target])
		{
			// Vehicle hitboxes
			return this.DoAimbotTrace(trace, target, vecSwingStartOffset);
		}
		
		float eyePitch[3];
		if(Npc_type != 3)
			GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);
		
		float vecForward[3], vecRight[3], vecTarget[3];
		
		WorldSpaceCenter(target, vecTarget);
		if(target <= MaxClients)
			vecTarget[2] += 10.0; //abit extra as they will most likely always shoot upwards more then downwards
		
		WorldSpaceCenter(this.index, vecForward);
	//	GetAbsOrigin(this.index, vecForward);
	//	vecForward[2] += 45.0;
		MakeVectorFromPoints(vecForward, vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		if(Npc_type != 3)
			vecForward[1] = eyePitch[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
		
		float vecSwingStart[3];
		GetAbsOrigin(this.index, vecSwingStart);
		
		vecSwingStart[2] += vecSwingStartOffset; //default is 55 for a few reasons.
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * vecSwingMaxs[0];
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * vecSwingMaxs[1];
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * vecSwingMaxs[2];
	//	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	//	TE_SetupBeamPoints(vecSwingStart, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	//	TE_SendToAll();
		
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
				vecSwingMins[repeat] *= 0.5625;
				vecSwingMaxs[repeat] *= 0.5625;
			}

			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd,vecSwingMins, vecSwingMaxs, 1073741824, ingore_buildings ? BulletAndMeleeTrace_MultiNpcPlayerAndBaseBossOnly : BulletAndMeleeTrace_MultiNpcTrace, this.index);
		}	
		else
		{
			trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
		}

		//PrintToConsoleAll("DoSwingTrace::%f:%d:%d", TR_GetFraction(trace), TR_DidHit(trace), TR_GetEntityIndex(trace));
		return (TR_GetFraction(trace) < 1.0);
	}
	public bool DoAimbotTrace(Handle &trace, int target, float vecSwingStartOffset = 44.0)
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
			SetEntProp(entity, Prop_Send, "m_fEffects", EF_PARENT_ANIMATES| EF_NOSHADOW);
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

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
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
	public int FireParticleRocket(float vecTarget[3], float rocket_damage, float rocket_speed, float damage_radius , const char[] rocket_particle = "",
	 bool do_aoe_dmg=false , bool FromBlueNpc=true, bool Override_Spawn_Loc = false,
	 float Override_VEC[3] = {0.0,0.0,0.0}, int flags = 0, int inflictor = INVALID_ENT_REFERENCE, float bonusdmg = 1.0, bool hide_projectile = true)
	{
		float vecSwingStart[3], vecAngles[3];
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
		
		int entity = Wand_Projectile_Spawn(this.index, rocket_speed, 10.0, rocket_damage, -1, -1, rocket_particle, vecAngles,hide_projectile,vecSwingStart);
		
		if(IsValidEntity(entity))
		{
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
			h_BonusDmgToSpecialArrow[entity] = bonusdmg;
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			b_should_explode[entity] = do_aoe_dmg;
			i_ExplosiveProjectileHexArray[entity] = flags;
			fl_rocket_particle_dmg[entity] = rocket_damage;
			fl_rocket_particle_radius[entity] = damage_radius;
			b_rocket_particle_from_blue_npc[entity] = FromBlueNpc;
			
			WandProjectile_ApplyFunctionToEntity(entity, Rocket_Particle_StartTouch);
			return entity;
		}
		
		
		return -1;
	}
	public int FireGrenade(float vecTarget[3], float grenadespeed = 800.0, float damage, char[] model)
	{
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
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
			return entity;
		}
		return -1;
	}
	public void RemoveAllWearables()
    {
        if (IsValidEntity(this.m_iWearable1))
            RemoveEntity(this.m_iWearable1);
        if (IsValidEntity(this.m_iWearable2))
            RemoveEntity(this.m_iWearable2);
        if (IsValidEntity(this.m_iWearable3))
            RemoveEntity(this.m_iWearable3);
        if (IsValidEntity(this.m_iWearable4))
            RemoveEntity(this.m_iWearable4);
        if (IsValidEntity(this.m_iWearable5))
            RemoveEntity(this.m_iWearable5);
        if (IsValidEntity(this.m_iWearable6))
            RemoveEntity(this.m_iWearable6);
        if (IsValidEntity(this.m_iWearable7))
            RemoveEntity(this.m_iWearable7);
    }
	public int FireArrow(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, float offset = 0.0, int inflictor = INVALID_ENT_REFERENCE, int entitytofirefrom = -1) //No defaults, otherwise i cant even judge.
	{
		//ITS NOT actually an arrow, because of an ANNOOOOOOOOOOOYING sound.
		float vecSwingStart[3], vecAngles[3];
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

		int entity = Wand_Projectile_Spawn(this.index, rocket_speed, 10.0, rocket_damage, -1, -1, "", vecAngles,false,vecSwingStart);
		if(IsValidEntity(entity))
		{
			fl_Extra_Damage[entity] = fl_Extra_Damage[this.index];
			b_EntityIsArrow[entity] = true;
			f_ArrowDamage[entity] = rocket_damage;
			h_ArrowInflictorRef[entity] = inflictor < 1 ? INVALID_ENT_REFERENCE : EntIndexToEntRef(inflictor);
			
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

			WandProjectile_ApplyFunctionToEntity(entity, ArrowStartTouch);
			return entity;
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
	property int m_iPose_MoveScale
	{
		public get()							{ return this.GetProp(Prop_Data, "m_imove_scale"); }
		public set(int TempValueForProperty) 	{ this.SetProp(Prop_Data, "m_imove_scale", TempValueForProperty); }
	}
	property int m_iPose_MoveYaw
	{
		public get()							{ return this.GetProp(Prop_Data, "m_imove_yaw"); }
		public set(int TempValueForProperty) 	{ this.SetProp(Prop_Data, "m_imove_yaw", TempValueForProperty); }
	}
	
	property int m_iPoseMoveY
	{
		public get()							{ return i_PoseMoveY[this.index]; }
		public set(int TempValueForProperty) 	{ i_PoseMoveY[this.index] = TempValueForProperty; }
	}
	//Begin an animation activity, return false if we cant do that right now.
	public bool StartActivity(int iActivity)
	{
		int nSequence = this.SelectWeightedSequence(iActivity);
		if (nSequence == 0) 
			return false;
		
		this.m_iActivity = iActivity;
		
		this.SetSequence(nSequence);
		this.ResetSequenceInfo();
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);

		
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
		float flNextBotGroundSpeed;
		if(i_IsNpcType[this.index] != 1)
		{
			if (this.m_iPoseMoveX == 0)   
			{
				this.m_iPoseMoveX = this.LookupPoseParameter("move_x");
			}
			if (this.m_iPoseMoveY == 0)  
			{
				this.m_iPoseMoveY = this.LookupPoseParameter("move_y");
			}
			if (this.m_iPose_MoveYaw == 0) 
			{
				this.m_iPose_MoveYaw = this.LookupPoseParameter("move_yaw");
			}
			if (this.m_iPose_MoveScale == 0) 
			{
				this.m_iPose_MoveScale = this.LookupPoseParameter("move_scale");
			}
		
			flNextBotGroundSpeed = this.GetGroundSpeed();
			
			if (flNextBotGroundSpeed < 0.01) 
			{
				if (this.m_iPoseMoveX != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveX, 0.0);
				}
				if (this.m_iPoseMoveY != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveY, 0.0);
				}
				if (this.m_iPose_MoveYaw != -1) 
				{
					this.SetPoseParameter(this.m_iPose_MoveYaw, 0.0);
				}
				if (this.m_iPose_MoveScale != -1) 
				{
					this.SetPoseParameter(this.m_iPose_MoveScale, 0.0);
				}
			}
			else 
			{
				float vecFwd[3], vecRight[3], vecUp[3];
				this.GetVectors(vecFwd, vecRight, vecUp);
				
				float vecMotion[3]; this.GetGroundMotionVector(vecMotion);
			
				if (this.m_iPoseMoveX != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveX, GetVectorDotProduct(vecMotion, vecFwd));
				}
				if (this.m_iPoseMoveY != -1) 
				{
					this.SetPoseParameter(this.m_iPoseMoveY, GetVectorDotProduct(vecMotion, vecRight));
				}
				if (this.m_iPose_MoveYaw != -1) 
				{
					//too lazy to code this :D
					this.SetPoseParameter(this.m_iPose_MoveYaw, 0.0);
				}
			}	
			this.GetBaseNPC().flRunSpeed = this.GetRunSpeed();
			this.GetBaseNPC().flWalkSpeed = this.GetRunSpeed();	
		}

		if(f_TimeFrozenStill[this.index] && f_TimeFrozenStill[this.index] < GetGameTime(this.index))
		{
			// Was frozen before, reset layers
			int layerCount = this.GetNumAnimOverlays();
			for(int i; i < layerCount; i++)
			{
				view_as<CClotBody>(this.index).SetLayerPlaybackRate(i, 1.0);
			}
			view_as<CClotBody>(this.index).SetPlaybackRate(f_LayerSpeedFrozeRestore[this.index], true);

			if(IsValidEntity(view_as<CClotBody>(this.index).m_iFreezeWearable))
				RemoveEntity(view_as<CClotBody>(this.index).m_iFreezeWearable);

			f_TimeFrozenStill[this.index] = 0.0;
		}
		
		if(this.m_bisWalking && i_IsNpcType[this.index] != 1) //This exists to make sure that if there is any idle animation played, it wont alter the playback rate and keep it at a flat 1, or anything altered that the user desires.
		{
			float m_flGroundSpeed = GetEntPropFloat(this.index, Prop_Data, "m_flGroundSpeed");
			if (this.m_iPose_MoveScale != -1)
			{
				//robots use this wierdly enough.
				m_flGroundSpeed = 300.0; //assume 300.0
			}
			if(m_flGroundSpeed != 0.0)
			{
				float PlaybackSpeed = clamp((flNextBotGroundSpeed / m_flGroundSpeed), -4.0, 12.0);
				if (this.m_iPose_MoveScale != -1)
				{
					//how much they move
					this.SetPoseParameter(this.m_iPose_MoveScale, (clamp((PlaybackSpeed), 0.0, 1.0)));
				}
				if(PlaybackSpeed > f_MaxAnimationSpeed[this.index])
					PlaybackSpeed = f_MaxAnimationSpeed[this.index];
					

				if(PlaybackSpeed <= 0.01)
					PlaybackSpeed = 0.01;
					
				
				this.SetPlaybackRate(PlaybackSpeed, true);
			}
			else
			{
				//if its lower then this value, then itll mess up and particles wont animate.
				this.SetPlaybackRate(0.01, true);
			}
		}
		
	//	this.StudioFrameAdvance();
	//	this.DispatchAnimEvents();
		
		//Run and StuckMonitor
		if(i_IsNpcType[this.index] != 1)
		{
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

			//increase the size of the avoid box by 2x

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
			{
				this.GetPathFollower().Update(this.GetBot());	
			}

			this.GetBaseNPC().SetBodyMaxs(f3_AvoidOverrideMaxNorm[this.index]);
			this.GetBaseNPC().SetBodyMins(f3_AvoidOverrideMinNorm[this.index]);	
		}
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
	RegAdminCmd("sm_spawn_npc", Command_PetMenu, ADMFLAG_ROOT);
	RegAdminCmd("sm_remove_npc", Command_RemoveAll, ADMFLAG_ROOT);
	
	GameData gamedata = LoadGameConfigFile("zombie_riot");
	
	DHook_CreateDetour(gamedata, "NextBotGroundLocomotion::UpdateGroundConstraint", Dhook_UpdateGroundConstraint_Pre, Dhook_UpdateGroundConstraint_Post);
//	DHook_CreateDetour(gamedata, "CBaseAnimating::GetBoneCache", Dhook_BoneAnimPrintDo, _);
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


//	g_iResolveOffset = gamedata.GetOffset("CBaseBoss::m_bResolvePlayerCollisions");
	delete gamedata;

	NextBotActionFactory ActionFactory = new NextBotActionFactory("ZRMainAction");
	ActionFactory.SetEventCallback(EventResponderType_OnActorEmoted, PluginBot_OnActorEmoted);

	CEntityFactory EntityFactory = new CEntityFactory("zr_base_npc", OnCreate, OnDestroy);
	EntityFactory.DeriveFromNPC();
	EntityFactory.SetInitialActionFactory(ActionFactory);
	EntityFactory.BeginDataMapDesc()
		.DefineIntField("zr_pPath")
	
		//Sergeant Ideal Shield Netprops
		.DefineIntField("zr_iRefSergeantProtect")
		.DefineFloatField("zr_fSergeantProtectTime")
		.DefineIntField("m_iHealthBar")
		.DefineIntField("m_iTowerdefense_CheckpointAt")
		.DefineIntField("m_iTowerdefense_Target")
		.DefineFloatField("f_RegenDoLogic")
		.DefineIntField("m_imove_scale")
		.DefineIntField("m_imove_yaw")
		.DefineFloatField("f_JumpedRecently")
		.DefineIntField("i_Climbinfractions")
		.DefineFloatField("f_ClimbingAm")
#if defined ZR
		.DefineFloatField("m_flElementRes", Element_MAX)
#endif
	.EndDataMapDesc();
	EntityFactory.Install();

	
	//Potentially uses less logic?
	CEntityFactory EntityFactory_Building = new CEntityFactory("zr_base_stationary", OnCreate_Stationary, OnDestroy_Stationary);
	EntityFactory_Building.DeriveFromClass("prop_dynamic_override");
	EntityFactory_Building.BeginDataMapDesc()
	
		//Sergeant Ideal Shield Netprops
		.DefineIntField("zr_iRefSergeantProtect")
		.DefineFloatField("zr_fSergeantProtectTime")
		.DefineIntField("m_iHealthBar")
		.DefineIntField("m_iTowerdefense_CheckpointAt")
		.DefineIntField("m_iTowerdefense_Target")
		.DefineFloatField("f_RegenDoLogic")
#if defined ZR
		.DefineFloatField("m_flElementRes", Element_MAX)
#endif
	.EndDataMapDesc(); 
	EntityFactory_Building.Install();
}

static void OnCreate(CClotBody body)
{
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(!IsValidEntity(entity))
		{
			body.SetProp(Prop_Data, "zr_pPath", view_as<int>(g_NpcPathFollower[entitycount]));
			i_ObjectsNpcsTotal[entitycount] = EntIndexToEntRef(body.index);
			break;
		}
	}
}
static void OnCreate_Stationary(CClotBody body)
{
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(!IsValidEntity(entity))
		{
			i_ObjectsNpcsTotal[entitycount] = EntIndexToEntRef(body.index);
			break;
		}
	}
}

void RemoveFromNpcPathList(CClotBody body)
{
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
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
static void OnDestroy_Stationary(CClotBody body)
{
	OnDestroy_Global(body, 1);
}
static void OnDestroy(CClotBody body)
{
	OnDestroy_Global(body, 0);
}
static void OnDestroy_Global(CClotBody body, int Type)
{
	NPCStats_SetFuncsToZero(body.index);
	RemoveFromNpcAliveList(body.index);
#if defined ZR
		RemoveNpcFromZombiesLeftCounter(body.index);
#endif
	if(!b_NpcHasDied[body.index] && Type == 0)
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
	if(IsValidEntity(body.m_iWearable9))
		RemoveEntity(body.m_iWearable9);

	#if defined BONEZONE_BASE
	b_IsSkeleton[body.index] = false;

	int summoner = EntRefToEntIndex(i_BoneZoneSummoner[body.index]);
	if (IsValidEntity(summoner))
	{
		f_BoneZoneNumSummons[summoner] -= f_BoneZoneSummonValue[body.index];
		if (f_BoneZoneNumSummons[summoner] < 0.0)
			f_BoneZoneNumSummons[summoner] = 0.0;

		i_BoneZoneSummoner[body.index] = -1;
	}
	#endif

}

//Ragdoll
public void CBaseCombatCharacter_EventKilledLocal(int pThis, int iAttacker, int iInflictor, float flDamage, int iDamagetype, int iWeapon, const float vecDamageForce[3], const float vecDamagePosition[3])
{	
	RemoveFromNpcAliveList(pThis);
	if(!b_NpcHasDied[pThis])
	{
		//we push back the entity in time to when lag comp happend, so gibs actually make sense.
		FinishLagCompensation_Base_boss(pThis);
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

		float GibEnemyGive = 1.0;

#if defined ZR || defined RPG
		if(IsValidEntity(iWeapon))
		{
			GibEnemyGive *= Attributes_Get(iWeapon, 4012, 1.0);
		}
		//oh i was burnin!!
		//Grilled.
		if(HasSpecificBuff(pThis, "Burn"))
			GibEnemyGive *= 1.1;
#endif

		//MUST be at top, or else there can be heavy issues regarding infinite loops!
		b_NpcHasDied[pThis] = true;

		//leaving these on can cause crashes.
		SDKUnhook(pThis, SDKHook_TraceAttack, NPC_TraceAttack);
		SDKUnhook(pThis, SDKHook_OnTakeDamage, NPC_OnTakeDamage);
		SDKUnhook(pThis, SDKHook_OnTakeDamagePost, NPC_OnTakeDamage_Post);	
#if defined ZR || defined RPG
		if(client > 0)
		{
			if(client <= MaxClients)
			{
				if(i_HasBeenHeadShotted[pThis])
					i_Headshots[client] += 1; //Award 1 headshot point, only once.

				if(i_HasBeenBackstabbed[pThis])
					i_Backstabs[client] += 1; //Give a backstab count!

				i_KillsMade[client] += 1;
				RemoveHudCooldown(client);
			}
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
		VausMagicaRemoveShield(pThis, true);
#endif

#if defined BONEZONE_BASE
	delete g_BoneZoneBuffers[pThis];
	b_SetBuffedSkeletonAnimation[pThis]    = false;
	b_SetNonBuffedSkeletonAnimation[pThis] = false;
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

		//avoid hitboxes gettign in the way, specifically a sniper rifle fix
		SetEntPropFloat(pThis, Prop_Send, "m_flModelScale", 0.0001);

		//If its a building type, force vanish.
		if(i_IsNpcType[pThis] == 1)
		{
			npc.m_bDissapearOnDeath = true;
			//Need extra, baseboss is very special.
		}
		if(!npc.m_bDissapearOnDeath)
		{
			if((b_OnDeathExtraLogicNpc[pThis] & ZRNPC_DEATH_NOGIB) || !npc.m_bGib)
			{
				MakeEntityRagdollNpc(npc.index);
			}
			else
			{
				Npc_DoGibLogic(pThis, GibEnemyGive);
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
	if(b_NpcHasDied[pThis])
		return MRES_Ignored;
		
	int event = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
	CClotBody npc = view_as<CClotBody>(pThis);
		
	Function func = func_NPCAnimEvent[pThis];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(pThis);
		Call_PushCell(event);
		Call_Finish();
	}
	else
	{
		if(!b_thisNpcIsARaid[pThis] && (EnemyNpcAlive >= 20 || EnableSilentMode)) //Theres too many npcs, kill off the sounds.
		{
			switch(npc.m_iNpcStepVariation)
			{
				case STEPTYPE_TANK:
				{
					
				}
				default:
				{
					//Remove this entire logic if theres no hooked handle event!
					b_KillHookHandleEvent[pThis] = true;
					//dont delete hook INSIDE hook
				}
			}
		}
	}
	if(!b_thisNpcIsARaid[pThis] && (EnemyNpcAlive >= 20 || EnableSilentMode))
	{
		//kill off sound.
		//even if they had an anim event
		return MRES_Ignored;
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
					npc.PlayStepSound(g_PanzerStepSound[GetRandomInt(0, sizeof(g_PanzerStepSound) - 1)], 0.65, npc.m_iStepNoiseType);
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
			if(IsWalkEvent(event, 5) || IsWalkEvent(event))
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
				npc.PlayStepSound(g_RobotStepSound[GetRandomInt(0, sizeof(g_RobotStepSound) - 1)], 0.65, npc.m_iStepNoiseType);
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
		/*
		//downwards breaks.
		if(b_ThisWasAnNpc[entity])
			vecPos[2] += f3_CustomMinMaxBoundingBoxMinExtra[entity][2];
			*/
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

	for (int x = -1; x < 6; x++)
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
		if(b_AvoidBuildingsAtAllCosts[bot_entidx])
			return false;

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
		float pos2[3];
		pos2 = pos;
		if(!npc.m_bAllowBackWalking)
			npc.FaceTowards(pos2, (500.0 * npc.GetDebuffPercentage() * f_NpcTurnPenalty[npc.index]), true);
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
	float cost;
#if defined ZR
	if(!VIPBuilding_Active())
	{
		cost = dist * ((1.0 + (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0);
	}
	else
	{
		cost = dist * 25.0;
	}
#else
	cost = dist * ((1.0 + (GetRandomFloat(0.0, 1.0)) + 1.0) * 25.0);
#endif
	
	return from_area.GetCostSoFar() + cost;
}

bool PluginBot_Jump(int bot_entidx, float vecPos[3], float flMaxSpeed = 1250.0, bool DirectLaunch = false)
{
	if(IsEntityTowerDefense(bot_entidx)) //do not allow them to jump.
	{
		return false;
	}
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	if(!TheNPCs.IsValidNPC(npc.GetBaseNPC())) //do not allow them to jump.
	{
		return false;
	}
	float vecNPC[3], vecJumpVel[3];
	GetEntPropVector(bot_entidx, Prop_Data, "m_vecAbsOrigin", vecNPC);
	if(DirectLaunch)
	{
		float vecAngles[3];

		MakeVectorFromPoints(vecNPC, vecPos, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

		float speed = flMaxSpeed;
		
		vecJumpVel[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*speed;
		vecJumpVel[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*speed;
		vecJumpVel[2] = Sine(DegToRad(vecAngles[0]))*-speed;

		npc.Jump();
		npc.SetVelocity(vecJumpVel);
		return true;
	}
	/*
	float gravity = GetEntPropFloat(bot_entidx, Prop_Data, "m_flGravity");
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
		*/
	float gravity = npc.GetBaseNPC().flGravity;
	if(gravity <= 0.0)
	{
		gravity = 800.0; 
	}

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
		additionalHeight = 25.0;
	}
	
	if(DirectLaunch)
		additionalHeight = 0.1;

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
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	
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


stock void ArcToLocationViaSpeedProjectile(float VecStart[3], float VecEnd[3], float SpeedReturn[3], float TimeUntillReachDest = 1.0, float GravityChange = 1.0)
{
	float vecJumpVel[3];
	
	float gravity;
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;

	gravity *= GravityChange;
	// How fast does the headcrab need to travel to reach the position given gravity?
	float flActualHeight = VecEnd[2] - VecStart[2];
	float height = flActualHeight;
	if(height < 0.0)
	{
		//tickrate gravity downwards is bad.
		gravity *= TickrateModify;
		if(height >= -20.0)
		{
			height = -20.0;

		}
	}
	else
	{
		//invert for gravity the otherway
		gravity *= (((TickrateModify - 1.0) * -1.0) + 1.0);
		if(height <= 20.0)
		{
			height = 20.0;
		}
	}

	float speed = SquareRoot( 2.0 * gravity * fabs(height) );
	float time = speed / gravity;

	time += SquareRoot( (2.0 * fabs(height)) / gravity );

	time *= TimeUntillReachDest;
	speed *= TimeUntillReachDest;
	
	// Scale the sideways velocity to get there at the right time
	SubtractVectors( VecEnd, VecStart, vecJumpVel );
	vecJumpVel[0] /= time;
	vecJumpVel[1] /= time;
	vecJumpVel[2] /= time;

	// Speed to offset gravity at the desired height.
	vecJumpVel[2] = speed;

	SpeedReturn = vecJumpVel;

	/*
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
		additionalHeight = 25.0;
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
	*/
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
		if(i_IsVehicle[enemy])
		{
#if defined ZR
			enemy = Vehicle_Driver(enemy);
#else
			enemy = GetEntPropEnt(enemy, Prop_Data, "m_hPlayer");
#endif
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
			if(b_ThisWasAnNpc[enemy])
			{
				if(b_NpcHasDied[enemy])
				{
					return false;
				}
			}
			if(b_ThisWasAnNpc[index])
			{
				if(i_npcspawnprotection[enemy] > NPC_SPAWNPROT_INIT && i_npcspawnprotection[enemy] != NPC_SPAWNPROT_UNSTUCK)
				{
					return false;
				}
			}
			if(enemy > MaxClients && IsInvuln(enemy, true) && !target_invul)
			{
				//invlun check is only for npcs!
				return false;
			}

			if(!camoDetection && b_IsCamoNPC[enemy])
			{
				return false;
			}
#if defined ZR
			//citizen that are downed must be ignored.
			if(b_ThisWasAnNpc[enemy] && Citizen_ThatIsDowned(enemy))
			{
				return false;
			}
#endif
			
			if(b_ThisEntityIgnoredByOtherNpcsAggro[enemy])
			{
				if(b_ThisWasAnNpc[index])
					return false;
				
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

#if defined RPG
			if(GetTeam(index) != GetTeam(enemy))
			{
				if(OnTakeDamageRpgPartyLogic(enemy, index, GetGameTime(), true))
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
			if(b_NpcIgnoresbuildings[index])
			{
				return false;
			}
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
	   bool IgnorePlayers = false, //also assumes npcs, only buildings are attacked
	   bool UseVectorDistance = false,
  		float MinimumDistance = 0.0,
  		Function ExtraValidityFunction = INVALID_FUNCTION)
#endif
{

	//for tower defense, we need entirely custom logic.
	//we will only override any non get vector distances, becuase those are pathing
	//anything using get vector distance means that its a ranged attack, so we leave it alone.

	int SearcherNpcTeam = GetTeam(entity); //do it only once lol
#if defined ZR
	if(BetWar_Mode())
	{
		IgnorePlayers = false;
		onlyPlayers = false;
		fldistancelimitAllyNPC = 99999.9;
		UseVectorDistance = true;
	}

	//in rogue you can get allies, but they shouldnt get any enemies during setups.
	if(Rogue_Mode())
	{
		if(Rogue_InSetup() && SearcherNpcTeam == TFTeam_Red)
		{
			return -1;
		}
	}
	bool IsTowerdefense = false;
//	if(!UseVectorDistance) 
	{
		if(IsEntityTowerDefense(entity))
		{
			IsTowerdefense = true;
		}
	}
	if(IsTowerdefense)
	{
		// this logic is entirely ignored?
		CClotBody npc = view_as<CClotBody>(entity);
		return npc.m_iTarget;
	}
#endif

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
	
	//This code: if the npc is not on player team, make them attack players.
	//This doesnt work if they ignore players or tower defense mode is enabled.
#if defined ZR
	bool ForceIgnorePlayers = false;
	if(BetWar_Mode())
	{
		ForceIgnorePlayers = true;
	}
	if(SearcherNpcTeam != TFTeam_Red && !IgnorePlayers && !ForceIgnorePlayers)
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
					if(!npc.m_bCamo || camoDetection)
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
	if(SearcherNpcTeam == TFTeam_Red)
#endif
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
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
			int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(entity_close != entity && IsValidEntity(entity_close) && entity_close != ingore_client && GetTeam(entity_close) != GetTeam(entity))
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
				if(!npc.m_bThisEntityIgnored && IsEntityAlive(entity_close, true) && !b_NpcIsInvulnerable[entity_close] && !onlyPlayers && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
					//if its a downed citizen, dont target.
					if(Citizen_ThatIsDowned(entity_close))
						continue;

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
				if(!i_IsVehicle[entity_close] && GetTeam(entity_close) != SearcherNpcTeam && !b_ThisEntityIgnored[entity_close] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //make sure it doesnt target buildings that are picked up and special cases with special building types that arent ment to be targeted
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
			GetClosestTarget_Enemy_Type[i] = type;
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
	if(i_IsNpcType[entity] == STATIONARY_NPC)
	{
		//Stationary npcs never really need vector distance.
		UseVectorDistance = true;
	}
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
			
#if defined ZR
			int vehicle = Vehicle_Driver(GetClosestTarget_EnemiesToCollect[i]);
#else
			int vehicle = (GetClosestTarget_EnemiesToCollect[i] > 0 && GetClosestTarget_EnemiesToCollect[i] <= MaxClients) ? GetEntPropEnt(GetClosestTarget_EnemiesToCollect[i], Prop_Data, "m_hVehicle") : -1;
#endif
			if(vehicle != -1)
				GetClosestTarget_EnemiesToCollect[i] = vehicle;

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
		bool closeNpc;
#if defined ZR
		bool construction = Construction_Mode();	// Buildings/NPCs don't use allydist, focus buildings
#else
		bool construction = false;
#endif
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
					if(GetClosestTarget_Enemy_Type[a] > 2)	// Distance limit
					{
						if(!construction || dist < fldistancelimit)
						{
							if(dist > fldistancelimitAllyNPC)
							{
								continue;
							}
						}
					}
					else
					{
						if(construction && closeNpc)
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
					}

					if(dist < closeDist)
					{
						closeNav = area2;
						closeDist = dist;
						closeNpc = GetClosestTarget_Enemy_Type[a] > 2;
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
				int target = GetClosestTarget_EnemiesToCollect[i];
				if(target <= 0)
					break;
				
				if(targetNav[i] != closeNav)	// In this close nav
					continue;

				float dist = GetVectorDistance(targetPos[i], EntityLocation, true);
				//if they are in the taunt range, subtract into negatives.
				float TauntRange;
				if(target <= MaxClients)
				{
					int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
					if(IsValidEntity(weapon)) //Must also hold melee out 
						TauntRange = Attributes_Get(weapon, Attrib_TauntRangeValue, 0.0);
				}
				else
				{
					TauntRange = Attributes_Get(target, Attrib_TauntRangeValue, 0.0);
				}
				if(TauntRange != 0.0)
				{
					//taunting enemy in rnage, give much higher proprity
					TauntRange *= TauntRange;
					if(TauntRange > dist)
					{
						dist *= 0.00001;
					}
				}
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
				ClosestTarget = target;
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

			float TauntRange;
			if(target <= MaxClients)
			{
				int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
				if(IsValidEntity(weapon)) //Must also hold melee out 
					TauntRange = Attributes_Get(weapon, Attrib_TauntRangeValue, 0.0);
			}
			else
			{
				TauntRange = Attributes_Get(target, Attrib_TauntRangeValue, 0.0);
			}
			if(TauntRange != 0.0)
			{
				//taunting enemy in rnage, give much higher proprity
				TauntRange *= TauntRange;
				if(TauntRange > distanceVector)
				{
					distanceVector *= 0.00001;
				}
			}
			/*
				1: player
				2: player enemy npc
				3: player ally npc
				4: buildings
			*/

#if !defined RTS
			float distance_limit = fldistancelimit;
			switch(GetClosestTarget_Enemy_Type[i])
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
					distance_limit = fldistancelimit;
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

stock int GetClosestAllyPlayer(int entity, int ignore = 0)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (i != ignore && IsValidClient(i))
		{
			CClotBody npc = view_as<CClotBody>(i);
			if (GetTeam(i)== GetTeam(entity) && !npc.m_bThisEntityIgnored && IsEntityAlive(i, true)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
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

bool NpcGotStuck = false;
stock void IsSpaceOccupiedOnlyPlayers_Cleave(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	NpcGotStuck = false;
	TR_TraceHullFilter(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitPlayersOnly_Cleave, entity);
	//they got stuck, try to unstuck ONCE.
	static float PosFiller[3];
	static float MinsSave[3];
	static float MaxsSave[3];
	MinsSave = mins;
	MaxsSave = maxs;
	PosFiller = pos;
//	TE_DrawBox(1, PosFiller, MinsSave, MaxsSave, 0.1, view_as<int>({255, 0, 0, 255}));
	if(NpcGotStuck) 
	{
		Npc_Teleport_Safe(entity, PosFiller, MinsSave, MaxsSave);
	}
}
//Should only try to collide with players.
public bool TraceRayHitPlayersOnly_Cleave(int entity,int mask,any iExclude)
{
	if(!TraceRayHitPlayersOnly(entity,mask,iExclude))
	{
		return false;
	}
	NpcGotStuck = true;
	if(entity)
	{
		//first recorded instance of getting stuck after 2 seconds of nnot being stuck.
		if(f_AntiStuckPhaseThroughFirstCheck[entity] < GetGameTime() + 1.0)
		{
			//if still stuck after 1 second...
			f_AntiStuckPhaseThrough[entity] = GetGameTime() + 1.0;
			ApplyStatusEffect(entity, entity, "Intangible", 1.0);
			//give them 2 seconds to unstuck themselves
		}
		if(f_AntiStuckPhaseThroughFirstCheck[entity] < GetGameTime())
		{
			f_AntiStuckPhaseThroughFirstCheck[entity] = GetGameTime() + 2.0;
		}
	}

	return false;
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

	if(entity == Entity_to_Respect)
	{
		return true;
	}
	
	if(entity == data)
	{
		return false;
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
	float lastThink = f_LastBaseThinkTime[iNPC];
	f_LastBaseThinkTime[iNPC] = GetGameTime();
	CBaseCombatCharacter(iNPC).SetNextThink(GetGameTime());
	static float SimulationTimeDelay;
	if(!SimulationTimeDelay)
	{
		SimulationTimeDelay = (0.05/* * TickrateModify*/);
		//calc once
	}
	SetEntPropFloat(iNPC, Prop_Data, "m_flSimulationTime",GetGameTime() + SimulationTimeDelay);
	if(ReturnEntityAttackspeed(iNPC) == 1.0)
		return;
		
	if(f_TimeFrozenStill[iNPC] > GetGameTime(iNPC))
		return;
		
	float time = GetGameTime() - lastThink;	// Time since the last time this NPC thought

	if(ReturnEntityAttackspeed(iNPC) < 1.0)	// Buffs
		f_StunExtraGametimeDuration[iNPC] += (time - (time / ReturnEntityAttackspeed(iNPC)));
	else	// Nerfs
		f_StunExtraGametimeDuration[iNPC] += ((time * ReturnEntityAttackspeed(iNPC)) - time);
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
	//tempfix didnt work
	if(i_IsNpcType[npc.index] == 0 && !TheNPCs.IsValidNPC(npc.GetBaseNPC()))
	{
		//delete, somehow they arent valid!
		LogStackTrace("Somehow i was an invalid npc, look into me, my name was: %s, and i was in this dead state: %b, and i was i even an npcs : %b.",c_NpcName[iNPC], b_NpcHasDied[iNPC], b_ThisWasAnNpc[iNPC]);
		SDKUnhook(iNPC, SDKHook_Think, NpcBaseThink);
		RemoveEntity(iNPC);
		return;
	}
	if(b_NpcHasDied[iNPC])
	{
		if(i_IsNpcType[npc.index] == 0)
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
		}
		SDKUnhook(iNPC, SDKHook_Think, NpcBaseThink);
		return;
	}
	if(i_IsNpcType[npc.index] == NORMAL_NPC)
	{
		static float Vectorspeed[3];
		npc.GetVelocity(Vectorspeed);
		if(Vectorspeed[2] == 0.0 && !npc.IsOnGround())
		{
			float JumpFloat = GetEntPropFloat(iNPC, Prop_Data, "f_JumpedRecently");
			if(JumpFloat > GetGameTime())
			{
				StuckFixNpc_Ledge(npc,_, 1);
			}
		}
	}
	if(b_KillHookHandleEvent[iNPC])
	{
		if(h_NpcHandleEventHook[iNPC] != 0)
		{
			DHookRemoveHookID(h_NpcHandleEventHook[iNPC]);
		}
		h_NpcHandleEventHook[iNPC] = 0;
		b_KillHookHandleEvent[iNPC] = false;
	}
#if defined ZR
	AprilFoolsModelHideWearables(iNPC);
#endif
	if(i_IsNpcType[npc.index] == 0)
	{
		SaveLastValidPositionEntity(iNPC);
		NpcSetGravity(npc,iNPC);
	}

	if(f_TextEntityDelay[iNPC] < GetGameTime())
	{
		char BufferTest1[64];
		char BufferTest2[64];
		StatusEffects_HudHurt(iNPC, iNPC, BufferTest1, BufferTest2, 64, 0);
		//MAkes some buffs work for npcs
		//this is just as a temp fix, remove whenver.
		//If it isnt custom, then these npcs ignore triggers
	//	SetEntityMoveType(iNPC, MOVETYPE_CUSTOM);
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
	if(f_QuickReviveHealing[iNPC] < GetGameTime())
	{
		f_QuickReviveHealing[iNPC] = GetGameTime() + 0.1;
		if((i_CurrentEquippedPerk[iNPC] & PERK_REGENE) || HasSpecificBuff(iNPC, "Regenerating Therapy") ||  NpcStats_WeakVoidBuff(iNPC)|| NpcStats_StrongVoidBuff(iNPC))
		{
			float HealingAmount = float(ReturnEntityMaxHealth(npc.index)) * 0.01;
			
			float HpScalingDecrease = 1.0;

			if(b_thisNpcIsARaid[iNPC])
			{
				HealingAmount *= 0.025;
				//this means it uses scaling somehow.
				HpScalingDecrease = NpcDoHealthRegenScaling(iNPC);
			}
			else if(b_thisNpcIsABoss[iNPC])
			{
				HealingAmount *= 0.125;
				HpScalingDecrease = NpcDoHealthRegenScaling(iNPC);
			}
			if(NpcStats_StrongVoidBuff(iNPC))
				HealingAmount *= 1.25;
			
			//Reduce Healing
			if(GetTeam(iNPC) == TFTeam_Red)
			{
				HealingAmount *= 0.2;
			}
			HealingAmount *= HpScalingDecrease;

			f_QuickReviveHealing[iNPC] = GetGameTime() + 0.25;
			
			HealEntityGlobal(iNPC, iNPC, HealingAmount, 1.25, 0.0, HEAL_SELFHEAL);
		}
	}
#endif
#if defined RPG
	if(i_HpRegenInBattle[iNPC] > 1 && f_QuickReviveHealing[iNPC] < GetGameTime() && !f_TimeFrozenStill[iNPC])
	{
		f_QuickReviveHealing[iNPC] = GetGameTime() + 0.25;

		HealEntityGlobal(iNPC, iNPC, float(i_HpRegenInBattle[iNPC]), 1.0, 0.0, HEAL_SELFHEAL | HEAL_PASSIVE_NO_NOTIF);
		RPGNpc_UpdateHpHud(iNPC);
	}
#endif
#if defined RPG
	if(f_InBattleDelay[iNPC] < GetGameTime())
	{
		f_InBattleDelay[iNPC] = GetGameTime() + 0.4;
		HealOutOfBattleNpc(iNPC);
	}
#endif
	if(npc.f_RegenLogicDo < GetGameTime())
	{
		StatusEffect_TimerCallDo(iNPC);
		npc.f_RegenLogicDo = GetGameTime() + 0.4;
#if defined ZR
		if(IsEntityTowerDefense(iNPC) && i_IsNpcType[iNPC] == 0)
		{
			if(IsValidEntity(npc.m_iCheckpointTarget))
			{
				npc.StartPathing();
				static float flNextPos[3];
				GetEntPropVector(npc.m_iCheckpointTarget, Prop_Data, "m_vecAbsOrigin", flNextPos);
				npc.SetGoalTowerDefense(flNextPos);
				npc.f_RegenLogicDo = GetGameTime() + 1.0;
				//not that important.
			}
		}
#endif
#if defined ZR
		if(IsEntityTowerDefense(iNPC))
		{
			if(IsValidEntity(npc.m_iCheckpointTarget))
			{
				npc.StartPathing();
				static float flNextPos[3];
				GetEntPropVector(npc.m_iCheckpointTarget, Prop_Data, "m_vecAbsOrigin", flNextPos);
				npc.SetGoalTowerDefense(flNextPos);
			}
		}
#endif
	}

	if(CvarDisableThink.BoolValue)
		return;

	if(i_IsNpcType[npc.index] == 0)
	{
		//Is the NPC out of bounds, or inside a player
		NpcOutOfBounds(npc,iNPC);
		//is the NPC inside an object
		NpcStuckInSomething(npc, iNPC);

		//is npc somehow outside any nav mesh
		NpcStuckInSomethingOutOfBonunds(npc, iNPC);
	}
	Function func = func_NPCThink[iNPC];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(iNPC);
		Call_Finish();
	}
	/*
	if(IsEntityTowerDefense(iNPC))
	{
		TowerdefenseLocationGet(iNPC);
		if(npc.m_iTowerdefense_Checkpoint == -1)
		{
			//walk towards the VIP building, currently no support for 2 tracks (i guess)
			npc.m_iTarget = VIPBuilding_Get();
			if(IsValidEntity(npc.m_iTarget))
			{
				static float flNextPos[3];
				GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", flNextPos);
				npc.SetGoalTowerDefense(flNextPos);
			}
			return;
		}
		static float flMyPos[3];
		GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float flNextPos[3];
		GetEntPropVector(npc.m_iCheckpointTarget, Prop_Data, "m_vecAbsOrigin", flNextPos);
		float flDistanceToTarget = GetVectorDistance(flMyPos, flNextPos, true);
		if(flDistanceToTarget <= (25.0 * 25.0))
		{
			npc.m_iTowerdefense_Checkpoint++;
			return;
		}
		npc.StartPathing();
		npc.SetGoalTowerDefense(flNextPos);
	}
	*/
}
stock float NpcDoHealthRegenScaling(int iNPC)
{
#if defined ZR
	if(GetTeam(iNPC) == TFTeam_Red)
		return 1.0;
	//not allies.
	
	float ValueDo = 1.0;
	if(b_thisNpcIsARaid[iNPC] || b_thisNpcIsABoss[iNPC])
	{
		//we want to assume that we never scale above like 14 players, if it is, then we scale the HP regen down.
		int AliveAssume = CountPlayersOnRed(1);
		if(AliveAssume > 14)
			AliveAssume = 14;
		ValueDo = float(AliveAssume) / float(CountPlayersOnRed(0));
	}
	else
	{
		//if normal enemeis scale higher interms of HP, then we want to tune down the health regen.
		ValueDo = 1.0 / MultiGlobalHealth;
	}
	return ValueDo;
#else
	return 1.0;
#endif
}
public void NpcSetGravity(CClotBody npc, int iNPC)
{
	if(f_KnockbackPullDuration[iNPC] > GetGameTime())
	{
		npc.GetBaseNPC().flGravity = 0.0;
	}
	else
	{
#if defined ZR || defined RPG
		npc.GetBaseNPC().flGravity = (Npc_Is_Targeted_In_Air(iNPC) || b_NoGravity[iNPC]) ? 0.0 : (800.0 * npc.m_flGravityMulti);
#else
		npc.GetBaseNPC().flGravity = b_NoGravity[iNPC] ? 0.0 : (800.0 * npc.m_flGravityMulti);
#endif
	}
}
public void NpcOutOfBounds(CClotBody npc, int iNPC)
{
	if(i_NpcIsABuilding[iNPC])
		return;

#if defined RTS
	if(!i_NpcIsABuilding[iNPC])
#else
	if(!IsEntityTowerDefense(iNPC) && GetTeam(iNPC) != TFTeam_Red)
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
			//This is a temporary fix. find a better one for players getting stuck.
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
			hullcheckmins_Player[0] += 2.0;
			hullcheckmins_Player[1] += 2.0;

			hullcheckmaxs_Player[0] -= 2.0;
			hullcheckmaxs_Player[1] -= 2.0;
			hullcheckmaxs_Player[2] -= 2.0;
			//only if they are outright stuck inside them !!

			//this unstucks all players that are inside npcs, instead of just one!
			IsSpaceOccupiedOnlyPlayers_Cleave(flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, iNPC);

		}
	}
#if defined ZR
	else if(GetTeam(iNPC) == TFTeam_Red)
	{
		float GameTime = GetGameTime();
		if(f_StuckOutOfBoundsCheck[iNPC] < GameTime)
		{
			f_StuckOutOfBoundsCheck[iNPC] = GameTime + 10.0;
			//If NPCs some how get out of bounds
			bool OutOfBounds = false;
			if(i_InHurtZone[iNPC])
			{
				OutOfBounds = true;
			}
			else
			{
				static float flMyPos[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
				flMyPos[2] += 1.0;
				if(TR_PointOutsideWorld(flMyPos))
				{
					OutOfBounds = true;
				}
			}

			if(OutOfBounds)
			{
				TeleportNpcToRandomPlayer(iNPC);
			}
		}
	}
#endif	// Non-RTS
}

stock void TeleportNpcToRandomPlayer(int iNPC)
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
public void NpcStuckInSomethingOutOfBonunds(CClotBody npc, int iNPC)
{
	if(f_NoUnstuckVariousReasons[iNPC] > GetGameTime())
	{
		if(f_UnstuckSuckMonitor[iNPC] < GetGameTime())
		{
			npc.GetLocomotionInterface().ClearStuckStatus("UN-STUCK");
			f_UnstuckSuckMonitor[iNPC] = GetGameTime() + 1.0;
		}
		return;
	}
	if (b_DoNotUnStuck[iNPC])
		return;
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
		/*
		int NavAttribs = area.GetAttributes();
		if(NavAttribs & NAV_MESH_DONT_HIDE)
		{
			PassCheck = 2;
		}
		//This is for plaers only.
		*/
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
		UnstuckStuckNpc(npc);
	}
	else
	{
		i_FailedTriesUnstuck[iNPC][0] = 0;
	}
}
public void NpcStuckInSomething(CClotBody npc, int iNPC)
{
	if (b_DoNotUnStuck[iNPC])
		return;
	if(f_DoNotUnstuckDuration[iNPC] > GetGameTime())
		return;

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
			UnstuckStuckNpc(npc);
		}
	}
	else
	{
		i_FailedTriesUnstuck[iNPC][1] = 0;
	}
}
void UnstuckStuckNpc(CClotBody npc)
{
	static float vec3Origin[3];
	npc.SetVelocity(vec3Origin);
#if defined ZR
	if(GetTeam(npc.index) != TFTeam_Red)
	{
		//This was an enemy.
		if(Rogue_Mode())
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			return;
		}
		int Spawner_entity = GetRandomActiveSpawner();
		if(IsValidEntity(Spawner_entity))
		{
			float pos[3];
			float ang[3];
			GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			TeleportEntity(npc.index, pos, ang, NULL_VECTOR);
			i_npcspawnprotection[npc.index] = NPC_SPAWNPROT_UNSTUCK;
			CreateTimer(3.0, Remove_Spawn_Protection, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
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
			TeleportEntity(npc.index, pos, ang, NULL_VECTOR);
		}
		else
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
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
	 bool ReceiveInfo = false,
	 float ReceivePullInfo[3] = {0.0,0.0,0.0},
	 float OverrideLookAng[3] ={0.0,0.0,0.0})
{
	if(HasSpecificBuff(enemy, "Solid Stance"))
	{
		//dont be immune to self displacements
		if(attacker != enemy)
			return;
	}
	if(i_IsNpcType[enemy] == 1)
		return;
	
#if defined ZR
	bool forceOut = (PullDuration != 0.0 || knockback > 500.0);
	if(i_IsVehicle[enemy])
	{
		// Pull the driver instead of the vehicle
		if(forceOut && i_IsVehicle[enemy] == 2)
		{
			int driver = Vehicle_Driver(enemy);
			if(driver != -1)
			{
				enemy = driver;
				Vehicle_Exit(enemy);
			}
		}
	}
	else
	{
		// Push the vehicle instead of the driver
		int vehicle = Vehicle_Driver(enemy);
		if(vehicle != -1)
		{
			if(forceOut && i_IsVehicle[vehicle] == 2)
			{
				Vehicle_Exit(enemy);
			}
			else
			{
				enemy = vehicle;
			}
		}
	}
#endif

	if(enemy > 0 && !b_NoKnockbackFromSources[enemy] && !IsEntityTowerDefense(enemy))
	{
		float vAngles[3], vDirection[3];

		if(attacker <= MaxClients)	
		{
			if(PullDuration == 0.0)
			{
				GetClientEyeAngles(attacker, vAngles);
				/*
				if(vAngles[0] < -40.0) //if they look up too much, we set it.
				{
					vAngles[0] = -40.0;
				}
				else if(vAngles[0] > -5.0) //if they look down too much, we set it.
				{
					vAngles[0] = -5.0;
				}
				*/
				//Always launch up so people dont have to look up like a hawk.
				vAngles[0] = -40.0;
				if(OverrideLookAng[0] != 0.0)
					vAngles = OverrideLookAng;
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
			if(OverrideLookAng[0] != 0.0)
				vAngles = OverrideLookAng;
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
			if (TheNPCs.IsValidNPC(npc.GetBaseNPC()) && !npc.IsOnGround())
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
			float Attribute_Knockback = Attributes_GetOnPlayer(enemy, 252, true,_, 1.0);	
			
			knockback *= Attribute_Knockback;
		}
#endif
		
		knockback *= 0.75; //oops, too much knockback now!


		ScaleVector(vDirection, knockback);

		ReceivePullInfo = vDirection;
		
		if(ReceiveInfo)
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
	if(i_IsNpcType[iNPC] == 1)
	{
		f_PullStrength[iNPC] = 0.0;
		i_PullTowardsTarget[iNPC] = 0;
		SDKUnhook(iNPC, SDKHook_Think, NpcJumpThink);
	}
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
	//assume that if we are tragetting an enemy, dont do anything.
	if(i_npcspawnprotection[attacker] > NPC_SPAWNPROT_INIT && i_npcspawnprotection[attacker] != NPC_SPAWNPROT_UNSTUCK)
	{
		if(!IsValidAlly(attacker, enemy))
			return 0;
	}
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


bool Can_I_See_Enemy_Only(int attacker, int enemy, float pos_npc[3] = {0.0,0.0,0.0})
{
	//assume that if we are tragetting an enemy, dont do anything.
	if(i_npcspawnprotection[attacker] > NPC_SPAWNPROT_INIT && i_npcspawnprotection[attacker] != NPC_SPAWNPROT_UNSTUCK)
	{
		if(!IsValidAlly(attacker, enemy))
			return false;
	}
	Handle trace;
	
	float pos_enemy[3];
	if(pos_npc[2] == 0.0)
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

static char m_cGibModelDefault[][] =
{
	"models/gibs/antlion_gib_large_1.mdl",
	"models/Gibs/HGIBS_spine.mdl",
	"models/Gibs/HGIBS.mdl"
};
static char m_cGibModelMetal[][] =
{
	"models/gibs/helicopter_brokenpiece_03.mdl",
	"models/gibs/scanner_gib01.mdl",
	"models/gibs/metal_gib2.mdl"
};
void Npc_DoGibLogic(int pThis, float GibAmount = 1.0, bool forcesilentMode = false)
{
	CClotBody npc = view_as<CClotBody>(pThis);
	if(npc.m_iBleedType == 0)
		return;

	float startPosition[3];
				
	float damageForce[3];
	npc.m_vecpunchforce(damageForce, false);
	ScaleVector(damageForce, 0.025); //Reduce overall

	bool Limit_Gibs = false;
	if(CurrentGibCount > ZR_MAX_GIBCOUNT)
	{
		Limit_Gibs = true;
	}
	if(EnableSilentMode)
		Limit_Gibs = true;

	if(forcesilentMode)
		Limit_Gibs = true;

	if(npc.m_iBleedType == BLEEDTYPE_METAL)
		npc.PlayGibSoundMetal();
	else if(npc.m_iBleedType != BLEEDTYPE_RUBBER)
		npc.PlayGibSound();


	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
				
	for(int GibLoop; GibLoop < 3; GibLoop++)
	{
		int prop = CreateEntityByName("prop_physics_multiplayer");
		if(!IsValidEntity(prop))
			return; //Emergency backup
		float TempPosition[3];
		float TempForce[3];

		TempPosition = startPosition;

		switch(GibLoop)
		{
			case 0:
			{
				//main torso
				if(!npc.m_bIsGiant)
					TempPosition[2] += 42;
				else
					TempPosition[2] += 64;

			}
			case 1:
			{
				//Spine, or something
				if(!npc.m_bIsGiant)
					TempPosition[2] += 30;
				else
					TempPosition[2] += 49;
			}
			case 2:
			{
				//Head
				if(!npc.m_bIsGiant)
					TempPosition[2] += 75;
				else
					TempPosition[2] += 110;
			}
		}
		TempForce = damageForce;
		if(GibLoop == 0 && npc.m_iBleedType == BLEEDTYPE_NORMAL)
			ScaleVector(TempForce, 0.4);
		//This gib in specific has too much knockback.

		if(npc.m_iBleedType == BLEEDTYPE_METAL)
			DispatchKeyValue(prop, "model", m_cGibModelMetal[GibLoop]);
		else if (npc.m_iBleedType == BLEEDTYPE_SKELETON)
		{
			DispatchKeyValue(prop, "model", m_cGibModelSkeleton[GibLoop]);
			SetEntProp(prop, Prop_Send, "m_nSkin", GetEntProp(npc.index, Prop_Send, "m_nSkin", 1));
		}
		else
			DispatchKeyValue(prop, "model", m_cGibModelDefault[GibLoop]);

		DispatchKeyValue(prop, "physicsmode", "2");
		DispatchKeyValue(prop, "massScale", "1.0");
		DispatchKeyValue(prop, "spawnflags", "2");
		if(npc.m_bIsGiant)
		{
			if(npc.m_iBleedType == BLEEDTYPE_METAL && GibLoop == 0)
			{
				DispatchKeyValue(prop, "modelscale", "1.1");
			}
			else
				DispatchKeyValue(prop, "modelscale", "1.6");
		}
		else
		{
			if(npc.m_iBleedType == BLEEDTYPE_METAL && GibLoop == 0)
			{
				DispatchKeyValue(prop, "modelscale", "0.8");
			}
		}

		float Random_time = GetRandomFloat(6.0, 7.0);
		if(EnableSilentMode || CurrentGibCount > ZR_MAX_GIBCOUNT_ABSOLUTE)
		{
			Random_time *= 0.5; //half the duration if there are too many gibs
		}
#if defined RPG
		Random_time *= 0.25; //in RPG, gibs are really not needed as they are purpely cosmetic, for this reason they wont stay long at all.
#endif
		f_GibHealingAmount[prop] = 1.0 * GibAmount; //Set it to false by default first.
		if(Limit_Gibs)	
			f_GibHealingAmount[prop] *= 3.0;

		if(b_thisNpcIsABoss[pThis] || b_thisNpcIsARaid[pThis])
		{
			f_GibHealingAmount[prop] *= 4.0;
		}
		else if(b_IsGiant[pThis])
		{
			f_GibHealingAmount[prop] *= 2.0;
		}

		float ang[3];
		switch(GibLoop)
		{
			case 0:
			{
				if(npc.m_iBleedType == BLEEDTYPE_METAL)
					ang[0] = 90.0;
			}
		}
		CurrentGibCount += 1;
		DispatchKeyValueVector(prop, "origin",	 TempPosition);
		DispatchKeyValueVector(prop, "angles",	 ang);
		DispatchSpawn(prop);
		TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, TempForce);
		SetEntityCollisionGroup(prop, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
		CreateTimer(Random_time - 1.5, Prop_Gib_FadeSet, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(Random_time, Timer_RemoveEntity_Prop_Gib, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);

		Random_time -= 1.0;
		int ParticleSet = -1;
		switch(npc.m_iBleedType)
		{
			case BLEEDTYPE_NORMAL:
			{
				if(!EnableSilentMode)
					ParticleSet = ParticleEffectAt(TempPosition, "blood_trail_red_01_goop", Random_time); 
				SetEntityRenderColor(prop, 255, 0, 0, 255);
			}
			case BLEEDTYPE_METAL:
			{
				if(!EnableSilentMode)
					ParticleSet = ParticleEffectAt(TempPosition, "tpdamage_4", Random_time); 
			}
			case BLEEDTYPE_RUBBER:
			{
				if(!EnableSilentMode)
					ParticleSet = ParticleEffectAt(TempPosition, "doublejump_trail_alt", Random_time); //This is a permanent particle, gotta delete it manually...
			}
			case BLEEDTYPE_XENO:
			{
				if(!EnableSilentMode)
					ParticleSet = ParticleEffectAt(TempPosition, "blood_impact_green_01", Random_time); 
				SetEntityRenderColor(prop, 0, 255, 0, 255);
			}
			/*case BLEEDTYPE_SKELETON:
			{
				Skeletons don't bleed, so I'm leaving this blank.
			}*/
			case BLEEDTYPE_SEABORN:
			{
				if(!EnableSilentMode)
					ParticleSet = ParticleEffectAt(TempPosition, "flamethrower_rainbow_bubbles02", Random_time); 
				SetEntityRenderColor(prop, 65, 65, 255, 255);
			}
			case BLEEDTYPE_VOID:
			{
				if(!EnableSilentMode)
				{
					TE_BloodSprite(TempPosition, { 0.0, 0.0, 0.0 }, 200, 0, 200, 255, 32);
					TE_SendToAllInRange(TempPosition, RangeType_Visibility);
				}
				SetEntityRenderColor(prop, 200, 0, 200, 255);
			}
			case BLEEDTYPE_PORTAL:
			{
				//none.
			}
		}	
		if(ParticleSet != -1)
		{
			SetParent(prop, ParticleSet);
		}
		b_IsAGib[prop] = true;
		if(Limit_Gibs)
			return; //only spawn 1 gib.
	}
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
					float Heal_Amount = 0.0;
					
					Heal_Amount = Attributes_Get(weapon, 180, 0.0);
					//Make sure heal is higher then 0
					if(Heal_Amount > 0.0 && SDKCall_GetMaxHealth(player) > GetEntProp(player, Prop_Data, "m_iHealth"))
					{
						f_GibHealingAmount[gib] *= Heal_Amount;
						
						float Heal_Amount_calc;
						
						Heal_Amount_calc = Heal_Amount * 0.75;

						
						if(Heal_Amount_calc > 0.0)
						{
							b_IsAGib[gib] = false; //we dont want the same gib to heal twice.
							if(f_GibHealingAmount[gib])
							{
								Heal_Amount_calc *= 3.0;
							}
							HealEntityGlobal(player, player, Heal_Amount_calc, 1.0, 1.0, _);
							int sound = GetRandomInt(0, sizeof(g_GibEating) - 1);
							EmitSoundToClient(player, g_GibEating[sound], player, SNDCHAN_AUTO, 80, _, 1.0, _, _);
							RemoveEntity(gib);
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


stock void TE_Particle(const char[] Name, float origin[3]=NULL_VECTOR, float start[3]=NULL_VECTOR, float angles[3]=NULL_VECTOR, int entindex=-1, int attachtype= 0, int attachpoint=-1, bool resetParticles=true, int customcolors=0, float color1[3]=NULL_VECTOR, float color2[3]=NULL_VECTOR, int controlpoint=-1, int controlpointattachment=-1, float controlpointoffset[3]=NULL_VECTOR, float delay=0.0, int clientspec = 0)
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

//must include -1, or else it freaks out!!!!
//	if(entindex != -1)
	TE_WriteNum("entindex", entindex);

	if(attachtype != -1)
		TE_WriteNum("m_iAttachType", attachtype);

	if(attachpoint != -1)
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);

	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	if(customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		if(color1[2] == 11.1) //This shit doesnt work and spams console, block.
		{
			TE_WriteVector("m_CustomColors.m_vecColor1", color1);
			if(customcolors == 2)
				TE_WriteVector("m_CustomColors.m_vecColor2", color2);
			
		}
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

	if(clientspec == 0)
		TE_SendToAll(delay);
	else
	{
		TE_SendToClient(clientspec, delay);
	}
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
			
			if(!b_ThisWasAnNpc[TR_GetEntityIndex(trace)] && StrContains(class, "obj_")) //if its the world, then do this.
			{
				CreateParticle("impact_concrete", endpos, vecNormal);
			}
			
		}
		
		// Regular impact effects.
		char effect[PLATFORM_MAX_PATH];
		Format(effect, PLATFORM_MAX_PATH, "%s", tracerEffect);
		
		if (tracerEffect[0])
		{
			if(IsValidEntity(iWeapon))
			{
				if ( nDamageType & DMG_CRIT )
				{
					Format( effect, sizeof(effect), "%s_crit", tracerEffect );
				}

				float origin[3], angles[3];
				view_as<CClotBody>(iWeapon).GetAttachment(szAttachment, origin, angles);
				ShootLaser(iWeapon, effect, origin, endpos, false );
			}
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
	  float attackposition[3],
		 int Damage_for_boom = 200,
		  int Range_for_boom = 200,
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

float ShootLaterShotgunLogic[MAXENTITIES];
int ShootLaterShotgunLogic_Frames[MAXENTITIES];


void Requestframe_Shootlater(DataPack pack)
{
	pack.Reset();
	char StrParticle[255];
	float flStartPos[3];
	float flEndPos[3];
	int weapon;
	weapon = EntRefToEntIndex(pack.ReadCell());
	pack.ReadString(StrParticle, 255);
	flStartPos[0] = pack.ReadFloat();
	flStartPos[1] = pack.ReadFloat();
	flStartPos[2] = pack.ReadFloat();
	flEndPos[0] = pack.ReadFloat();
	flEndPos[1] = pack.ReadFloat();
	flEndPos[2] = pack.ReadFloat();
	delete pack;

	if(IsValidEntity(weapon))
		ShootLaser(weapon, StrParticle, flStartPos, flEndPos, false);
}
stock void ShootLaser(int weapon, const char[] strParticle, float flStartPos[3], float flEndPos[3], bool bResetParticles = false)
{
	if(ShootLaterShotgunLogic[weapon] == GetGameTime())
	{
		DataPack pack_TE = new DataPack();
		pack_TE.WriteCell(EntRefToEntIndex(weapon));
		pack_TE.WriteString(strParticle);
		pack_TE.WriteFloat(flStartPos[0]);
		pack_TE.WriteFloat(flStartPos[1]);
		pack_TE.WriteFloat(flStartPos[2]);
		pack_TE.WriteFloat(flEndPos[0]);
		pack_TE.WriteFloat(flEndPos[1]);
		pack_TE.WriteFloat(flEndPos[2]);
		RequestFrames(Requestframe_Shootlater, ShootLaterShotgunLogic_Frames[weapon], pack_TE);
		ShootLaterShotgunLogic_Frames[weapon]++;
		return;
	}

	ShootLaterShotgunLogic[weapon] = GetGameTime();
	ShootLaterShotgunLogic_Frames[weapon] = 1;
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

stock void BackoffFromOwnPositionAndAwayFromEnemy(CClotBody npc, int subject, float extra_backoff = 64.0, float pathTarget[3], int customlogic = -1)
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
	/*
		This means that theyare touching a wall!
	*/
	if(customlogic == 1 || customlogic == 2 || flDistanceToTarget < ((extra_backoff * extra_backoff)) / 2.0)
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
			if(customlogic == 1)
				ang[1] += 45.0; //try to the left/right.

			
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
			if(customlogic == 1)
				ang[1] -= 45.0; //try to the left/right.
			
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
	/*
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
	*/

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
			if(GetTeam(entity) == GetTeam(i) && !Is_a_Medic[i] && IsEntityAlive(i, true) && !i_NpcIsABuilding[i] && !b_ThisEntityIgnoredByOtherNpcsAggro[i] && !b_NpcIsInvulnerable[i])  //The is a medic thing is really needed
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

stock int GetClosestBuilding(int entity, float limitsquared = 99999999.9, int ingore_thisAlly = 0,Function ExtraValidityFunction = INVALID_FUNCTION)
{
	float TargetDistancetoBuilding = 0.0; 
	int ClosestTarget1 = 0; 
	for( int i = 1; i <= MAXENTITIES; i++ ) 
	{
		if (IsValidEntity(i) && i != entity && i != ingore_thisAlly && (i <= MaxClients || !b_NpcHasDied[i]))
		{
			if(GetTeam(entity) == GetTeam(i) && !Is_a_Medic[i] && IsEntityAlive(i, true) && i_NpcIsABuilding[i] && !b_ThisEntityIgnoredByOtherNpcsAggro[i] && !b_NpcIsInvulnerable[i])  //Making go for the building
			{
				if(ExtraValidityFunction != INVALID_FUNCTION)
				{
					bool WasValid1;
					Call_StartFunction(null, ExtraValidityFunction);
					Call_PushCell(entity);
					Call_PushCell(i);
					Call_Finish(WasValid1);

					if(!WasValid1)
						continue;
				}
				float EntityLocation[3], TargetLocation[3]; 
				GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
				GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				
				float distance = GetVectorDistance( EntityLocation, TargetLocation, true ); 
				if( distance < limitsquared )
				{
					if( TargetDistancetoBuilding ) 
					{
						if( distance < TargetDistancetoBuilding ) 
						{
							ClosestTarget1 = i; 
							TargetDistancetoBuilding = distance;		  
						}
					} 
					else 
					{
						ClosestTarget1 = i; 
						TargetDistancetoBuilding = distance;
					}			
				}
			}
		}
	}
	return ClosestTarget1; 
}


stock bool IsValidAlly(int index, int ally)
{
	if(IsValidEntity(ally))
	{
		if(fl_GibVulnerablity[ally] >= 50000.0)
		{
			//they are dead or something else, mainly used for Crystilioasion wirthtout making it very expensive to check.
			return false;
		}
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
	Function func = func_NPCActorEmoted[actor.index];
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
	FuncShowInteractHud[entity] = INVALID_FUNCTION;

	#if defined BONEZONE_BASE
    g_BoneZoneBuffFunction[entity] = INVALID_FUNCTION;
    g_BoneZoneBuffVFX[entity]      = INVALID_FUNCTION;
	#endif
}
public void SetDefaultValuesToZeroNPC(int entity)
{
	StatusEffectReset(entity, true);
#if defined ZR
	b_NpcHasBeenAddedToZombiesLeft[entity] = false;
	i_SpawnProtectionEntity[entity] = -1; 
	i_TeamGlow[entity] = -1;
	i_NpcOverrideAttacker[entity] = 0;
	b_thisNpcHasAnOutline[entity] = false;
	b_ThisNpcIsImmuneToNuke[entity] = false;
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
	b_KillHookHandleEvent[entity] = false;
	f_NpcAdjustFriction[entity] = 1.0;
	f_AprilFoolsSetStuff[entity] = 0.0;
	b_HideHealth[entity] = false;
//	i_MasterSequenceNpc[entity] = -1;
	ResetAllArmorStatues(entity);
	f_AttackSpeedNpcIncrease[entity] = 1.0;
	b_AvoidBuildingsAtAllCosts[entity] = false;
	f_MaxAnimationSpeed[entity] = 2.0;
	b_OnDeathExtraLogicNpc[entity] = 0;
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
	f_ExtraOffsetNpcHudAbove[entity] = 0.0;
	i_Wearable[entity][0] = -1;
	i_Wearable[entity][1] = -1;
	i_Wearable[entity][2] = -1;
	i_Wearable[entity][3] = -1;
	i_Wearable[entity][4] = -1;
	i_Wearable[entity][5] = -1;
	i_Wearable[entity][6] = -1;
	i_Wearable[entity][7] = -1;
	i_Wearable[entity][8] = -1;
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
	for(int repeat; repeat <= 9; repeat++)
	{
		fl_AbilityOrAttack[entity][repeat] = 0.0;
	}

	fl_JumpStartTimeInternal[entity] = 0.0;
	fl_JumpCooldown[entity] = 0.0;
	fl_NextDelayTime[entity] = 0.0;
	fl_NextThinkTime[entity] = 0.0;
	fl_NextRunTime[entity] = 0.0;
	fl_NextMeleeAttack[entity] = 0.0;
	fl_Speed[entity] = 0.0;
	fl_GravityMulti[entity] = 1.0;
	i_Target[entity] = -1;
	i_TargetAlly[entity] = -1;
	fl_GetClosestTargetTime[entity] = 0.0;
	fl_GetClosestTargetTimeTouch[entity] = 0.0;
	b_DoNotChangeTargetTouchNpc[entity] = 0;
	fl_GetClosestTargetNoResetTime[entity] = 0.0;
	fl_NextHurtSound[entity] = 0.0;
	fl_NextHurtSoundArmor[entity] = 0.0;
	fl_HeadshotCooldown[entity] = 0.0;
	b_CantCollidie[entity] = false;
	b_CollidesWithEachother[entity] = false;
	b_CantCollidieAlly[entity] = false;
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
	i_AnimationState[entity] = 0;
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
	i_Activity[entity] = -1;
	i_PoseMoveX[entity] = 0;
	i_PoseMoveY[entity] = 0;
	b_PlayHurtAnimation[entity] = false;
	IgniteTimer[entity] = null;
	IgniteFor[entity] = 0;
	BurnDamage[entity] = 0.0;
	IgniteRef[entity] = -1;
	f_CreditsOnKill[entity] = 0.0;
	i_PluginBot_ApproachDelay[entity] = 0;
	i_npcspawnprotection[entity] = NPC_SPAWNPROT_INIT;
	f_DomeInsideTest[entity] = 0.0;
	f_CooldownForHurtParticle[entity] = 0.0;
	f_DelayComputingOfPath[entity] = GetGameTime() + 0.2;
	f_UnstuckSuckMonitor[entity] = 0.0;
	i_TargetToWalkTo[entity] = -1;
	f_TargetToWalkToDelay[entity] = 0.0;
	i_WasPathingToHere[entity] = 0;
	f3_WasPathingToHere[entity][0] = 0.0;
	f3_WasPathingToHere[entity][1] = 0.0;
	f3_WasPathingToHere[entity][2] = 0.0;
	
	b_Frozen[entity] = false;
	b_NoGravity[entity] = false;
	f_TankGrabbedStandStill[entity] = 0.0;
	f_TimeFrozenStill[entity] = 0.0;
	f_DuelStatus[entity] = 0.0;
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
	f_StuckOutOfBoundsCheck[entity] = GetGameTime() + 2.0;
	f_StunExtraGametimeDuration[entity] = 0.0;
	i_TextEntity[entity][0] = -1;
	i_TextEntity[entity][1] = -1;
	i_TextEntity[entity][2] = -1;
	i_TextEntity[entity][3] = -1;
	i_TextEntity[entity][4] = -1;
	i_NpcIsABuilding[entity] = false;
//	b_EntityInCrouchSpot[entity] = false;
//	b_NpcResizedForCrouch[entity] = false;
	i_Changed_WalkCycle[entity] = -1;
	i_MedkitAnnoyance[entity] = 0;
	f_TextEntityDelay[entity] = 0.0;
	f_CheckIfStuckPlayerDelay[entity] = 0.0;
	f_QuickReviveHealing[entity] = 0.0;
#if defined ZR
	OsmosisElementalEffectEnable(entity, -1.0);
	for(int i; i < Element_MAX; i++)
	{
		f_ArmorCurrosionImmunity[entity][i] = 0.0;
	}
	ResetBoundVillageAlly(entity);
	ResetFreeze(entity);
#endif
	c_HeadPlaceAttachmentGibName[entity][0] = 0;
}


public void ArrowStartTouch(int arrow, int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
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
		Projectile_DealElementalDamage(entity, arrow);

		EmitSoundToAll(g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], arrow, _, 80, _, 0.8, 100);

	}
	else
	{
		EmitSoundToAll(g_ArrowHitSoundMiss[GetRandomInt(0, sizeof(g_ArrowHitSoundMiss) - 1)], arrow, _, 80, _, 0.8, 100);
	}
	int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
	if(IsValidEntity(arrow_particle))
	{
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
	}
	CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow), TIMER_FLAG_NO_MAPCHANGE);
	SetEntityRenderMode(arrow, RENDER_NONE);
	SetEntityMoveType(arrow, MOVETYPE_NONE);
	WandProjectile_ApplyFunctionToEntity(arrow, INVALID_FUNCTION);
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

		int DamageTypes;
		DamageTypes |= DMG_PREVENT_PHYSICS_FORCE;

		if((i_ExplosiveProjectileHexArray[entity] & EP_DEALS_CLUB_DAMAGE))
		{
			DamageTypes |= DMG_CLUB;
		}
		else
		{
			DamageTypes |= DMG_BULLET;
		}


		if(b_should_explode[entity])	//should we "explode" or do "kinetic" damage
		{
			i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
			Explode_Logic_Custom(fl_rocket_particle_dmg[entity] , inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
		}
		else
		{
			SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DamageTypes, -1);	//acts like a kinetic rocket
		}
		
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
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
/*
public MRESReturn Dhook_BoneAnimPrintDo(int entity, DHookReturn ret)
{
	if(b_IsInUpdateGroundConstraintLogic)
	{
		static char buffer[64];
		GetEntityClassname(entity, buffer, sizeof(buffer));
		char model[256];
		CBaseEntity(entity).GetModelName(model, sizeof(model));
		PrintToServer("[RPG DEBUG] Dhook_BoneAnimPrintDo Entity: %i| Classname %s | Model Mame %s",entity, buffer, model);
	}
	return MRES_Ignored;
}
*/
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
		//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.

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
#if defined RPG
		NPC_Despawn(entity);
#endif
#if defined ZR
		SmiteNpcToDeath(entity);
#endif
	}
}

stock void FreezeNpcInTime(int npc, float Duration_Stun, bool IgnoreAllLogic = false)
{
	if(HasSpecificBuff(npc, "Clear Head") && !IgnoreAllLogic)
		return;

	//Emergency incase it wasnt an npc.
	if(!b_ThisWasAnNpc[npc])
	{
		if(npc <= 0 || npc > MaxClients)
		{
			return;
		}
		if(HasSpecificBuff(npc, "Dimensional Turbulence"))
			Duration_Stun *= 0.25;
		
		TF2_StunPlayer(npc, Duration_Stun, 1.0, TF_STUNFLAGS_NORMALBONK);
		ApplyStatusEffect(npc, npc, "Stunned", Duration_Stun);	
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
	if(!IgnoreAllLogic)
	{
		if(HasSpecificBuff(npc, "Shook Head"))
			Duration_Stun_Post *= 0.5;

#if defined ZR
		Rogue_ParadoxDLC_StunTime(npc, Duration_Stun_Post);
#endif
		if(HasSpecificBuff(npc, "Dimensional Turbulence"))
			Duration_Stun_Post *= 0.5;
	}

	if(Duration_Stun_Post <= 0.05)
	{
		//this is too little, do not bother
		return;
	}
	bool DontSetFrozenState = false;
	if(f_TimeFrozenStill[npc])
		DontSetFrozenState = true;
	f_StunExtraGametimeDuration[npc] += (Duration_Stun_Post - TimeSinceLastStunSubtract);
	fl_NextDelayTime[npc] = GameTime + Duration_Stun_Post - f_StunExtraGametimeDuration[npc];
	f_TimeFrozenStill[npc] = GameTime + Duration_Stun_Post - f_StunExtraGametimeDuration[npc];
	f_TimeSinceLastStunHit[npc] = GameTime + Duration_Stun_Post;
	if(b_thisNpcIsARaid[npc])
		ApplyStatusEffect(npc, npc, "Shook Head", Duration_Stun * 3.0);	

	//PrintToChatAll("%f",Duration_Stun_Post);
	ApplyStatusEffect(npc, npc, "Stunned", Duration_Stun_Post);	

	npcclot.Update();

	Npc_DebuffWorldTextUpdate(view_as<CClotBody>(npc));

	if(DontSetFrozenState)
		return;
	//already stunned, dont get their stunned animation states.
	
	f_LayerSpeedFrozeRestore[npc] = view_as<CClotBody>(npc).GetPlaybackRate();
	view_as<CClotBody>(npc).SetPlaybackRate(0.0, true);
	int layerCount = CBaseAnimatingOverlay(npc).GetNumAnimOverlays();
	for(int i; i < layerCount; i++)
	{
		view_as<CClotBody>(npc).SetLayerPlaybackRate(i, 0.0);
	}
}

void NPCStats_RemoveAllDebuffs(int enemy, float Duration = 0.0)
{
	IgniteFor[enemy] = 0;
	//for 0.6 seconds, so all bleed get cleared
	if(Duration <= 0.6)
		Duration = 0.6;

	RemoveAllBuffs(enemy, false);
	ApplyRapidSuturing(enemy);
	ApplyStatusEffect(enemy, enemy, "Hardened Aura", Duration);
}



bool Npc_Teleport_Safe(int client, float endPos[3], float hullcheckmins_Player[3], float hullcheckmaxs_Player[3], bool check_for_Ground_Clerance = false, bool teleport_entity = true, bool ingoreSafeTrace = false)
{
	bool FoundSafeSpot = false;
	//Try base position.
	float OriginalPos[3];
	OriginalPos = endPos;

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance, ingoreSafeTrace))
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
				if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance, ingoreSafeTrace))
					FoundSafeSpot = true;
			}
		}
	}
				

	if(IsSafePosition(client, endPos, hullcheckmins_Player, hullcheckmaxs_Player, check_for_Ground_Clerance, ingoreSafeTrace))
		FoundSafeSpot = true;

	if(FoundSafeSpot && teleport_entity)
	{
		SDKCall_SetLocalOrigin(client, endPos);	
	}
	return FoundSafeSpot;
}


//We wish to check if this poisiton is safe or not.
//This is only for players.
bool IsSafePosition(int entity, float Pos[3], float mins[3], float maxs[3], bool check_for_Ground_Clerance = false, bool ingoreSafeTrace = false)
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
	if(!ingoreSafeTrace)
	{
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
	}
	if(ref < 0) //It hit nothing, good!
	{
		if(!check_for_Ground_Clerance)
		{
			delete hTrace;
			return true;
		}
		delete hTrace;

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
	int MaxHealth = ReturnEntityMaxHealth(npc.index);
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
	
	if(!BetWar_Mode())
	{
		DisplayRGBHealthValue(Health, MaxHealth, HealthColour[0], HealthColour[1],HealthColour[2]);
	}
	else
	{
		switch(GetTeam(npc.index))
		{
			case 4:
			{
				HealthColour[0] = 255;
				HealthColour[1] = 0;
				HealthColour[2] = 0;
			}
			case 3:
			{
				HealthColour[0] = 0;
				HealthColour[1] = 0;
				HealthColour[2] = 255;
			}
			default:
				DisplayRGBHealthValue(Health, MaxHealth, HealthColour[0], HealthColour[1],HealthColour[2]);
		}
	}

	if(IsValidEntity(npc.m_iTextEntity5))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(npc.m_iTextEntity5,	 "color", sColor);
		DispatchKeyValue(npc.m_iTextEntity5, "message", HealthText);
	}
	else
	{
		float Offset[3];

		Offset[2] += 95.0;
		Offset[2] += f_ExtraOffsetNpcHudAbove[npc.index];
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

	StatusEffects_HudAbove(npc.index, HealthText, sizeof(HealthText));
#if defined ZR
	VausMagicaRemoveShield(npc.index);
	if(MoraleBoostLevelAt(npc.index) > 0) //hussar!
	{
		//Display morale!
		MoraleIconShowHud(npc.index, HealthText, sizeof(HealthText));
	}
	if(Saga_EnemyDoomed(npc.index))
	{
		Format(HealthText, sizeof(HealthText), "%s#",HealthText);
	}
	if(i_HowManyBombsHud[npc.index] > 0)
	{
		Format(HealthText, sizeof(HealthText), "%s!(%i)",HealthText, i_HowManyBombsHud[npc.index]);
	}
	if(VausMagicaShieldLeft(npc.index) > 0)
	{
		Format(HealthText, sizeof(HealthText), "%sS(%i)",HealthText,VausMagicaShieldLeft(npc.index));
	}
	
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
		//	DispatchKeyValue(npc.m_iTextEntity1,	 "color", sColor);
		// Colour will never be Edited probably.
		DispatchKeyValue(npc.m_iTextEntity4, "message", HealthText);
	}
	else
	{
		float Offset[3];

		Offset[2] += 95.0;
		Offset[2] += f_ExtraOffsetNpcHudAbove[npc.index];

		Offset[2] *= GetEntPropFloat(npc.index, Prop_Send, "m_flModelScale");
#if defined RPG
		Offset[2] += 30.0;
#endif
		Offset[2] += 15.0;
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 16, HealthColour, npc.index);
		DispatchKeyValue(TextEntity, "font", "4");
		npc.m_iTextEntity4 = TextEntity;	
	}
}

static int b_TouchedEntity[MAXENTITIES];

void ResetTouchedentityResolve()
{
	Zero(b_TouchedEntity);
}
bool TouchedNpcResolve(int entity)
{
	return view_as<bool>(b_TouchedEntity[entity]);
}
int ConvertTouchedResolve(int index)
{
	return b_TouchedEntity[index];
}
//TODO: teleport entities instead, but this is easier to i sleep :)
stock void ResolvePlayerCollisions_Npc(int iNPC, float damage, bool CauseKnockback = true)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	static float vel[3];
	static float flMyPos[3];
	npc.GetVelocity(vel);
	//clamping so insane speeds dont translate through hitting the entire map.
	fClamp(vel[0], -300.0, 300.0);
	fClamp(vel[1], -300.0, 300.0);
	fClamp(vel[2], -300.0, 300.0);
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
		
	static float hullcheckmins[3];
	static float hullcheckmaxs[3];
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
	
	static float flPosEnd[3];
	flPosEnd = flMyPos;
	ScaleVector(vel, 0.1);
	AddVectors(flMyPos, vel, flPosEnd);
	
	ResetTouchedentityResolve();
	ResolvePlayerCollisions_Npc_Internal(flMyPos, flPosEnd, hullcheckmins, hullcheckmaxs, iNPC);

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
		int EntityHit = b_TouchedEntity[entity_traced];
		if(!EntityHit)
			break;

		if(i_IsABuilding[EntityHit])
			continue;

		if(EntityHit <= MaxClients)
		{
			vDirection[0] += GetEntPropFloat(EntityHit, Prop_Send, "m_vecVelocity[0]");
			vDirection[1] += GetEntPropFloat(EntityHit, Prop_Send, "m_vecVelocity[1]");
			vDirection[2] = GetEntPropFloat(EntityHit, Prop_Send, "m_vecVelocity[2]");
		}
		
		SDKHooks_TakeDamage(EntityHit, iNPC, iNPC, damage, DMG_CRUSH, -1, _);
		if(CauseKnockback && GetTeam(iNPC) != TFTeam_Red)
		{
			if(b_NpcHasDied[EntityHit])
			{
				Custom_SetAbsVelocity(EntityHit, vDirection);
			}
			else
			{
				CClotBody npc1 = view_as<CClotBody>(EntityHit);
				npc1.SetVelocity(vDirection);
			}
		}
	}

	ResetTouchedentityResolve(); 	
}

stock void ResolvePlayerCollisions_Npc_Internal(const float startpos[3],const float pos[3], const float mins[3], const float maxs[3],int entity=-1)
{
	TR_EnumerateEntitiesHull(startpos, pos, mins, maxs, PARTITION_SOLID_EDICTS, ResolvePlayerCollisionsTrace, entity);
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

stock ArrayList GetAllNearbyAreas(float pos[3], float radius)
{
	ArrayList valid = CreateArray(255);

	int iAreaCount = TheNavAreas.Length;
	for (int i = 0; i < iAreaCount; i++)
	{
		CNavArea navi = TheNavAreas.Get(i);

		if (navi == NULL_AREA)
			break;    // No nav?

		int NavAttribs = navi.GetAttributes();
		if (NavAttribs & NAV_MESH_AVOID)
		{
			continue;
		}

		float navPos[3];
		navi.GetCenter(navPos);

		if (GetVectorDistance(pos, navPos, true) <= (radius * radius))
			PushArrayCell(valid, navi);
	}

	return valid;
}

stock CNavArea GetRandomNearbyArea(float pos[3], float radius)
{
    CNavArea navi;
    
    static ArrayList areas;
    static float vecLastKnownPos[3];
    
    if (areas)
    {
        if (!GetVectorDistance(pos, vecLastKnownPos) && areas.Length > 0)
        {
            navi = areas.Get(GetURandomInt() % areas.Length);
            return navi;
        }
        
        delete areas;
    }
    
    areas = GetAllNearbyAreas(pos, radius);
    
    if (areas.Length > 0)
        navi = areas.Get(GetURandomInt() % areas.Length);
    
    vecLastKnownPos = pos;
    return navi;
}

void NpcStartTouch(int TouchedTarget, int target, bool DoNotLoop = false)
{
	int entity = TouchedTarget;
	CClotBody npc = view_as<CClotBody>(entity);
#if defined ZR
	if(target > 0 && entity > MaxClients && i_npcspawnprotection[entity] > NPC_SPAWNPROT_INIT && i_npcspawnprotection[entity] != NPC_SPAWNPROT_UNSTUCK)
	{
		if(IsValidEnemy(entity, target, true, true)) //Must detect camo.
		{
			int DamageFlags = DMG_CRUSH|DMG_TRUEDAMAGE;
			float DamageDeal = float(ReturnEntityMaxHealth(target));
			DamageDeal *= 0.01;
			if(DamageDeal <= 5.0)
				DamageDeal = 5.0;
			if(ShouldNpcDealBonusDamage(target) || entity > MaxClients)
			{
				DamageFlags &= ~DMG_CRUSH;
			}
			HealEntityGlobal(target, target, -DamageDeal, 99.0, 0.0, HEAL_ABSOLUTE | HEAL_PASSIVE_NO_NOTIF);
			SDKHooks_TakeDamage(target, entity, entity, 1.0, DamageFlags, -1, _);
		}
	}
#endif
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
	if(Push[0] > 100000.0 || Push[1] > 100000.0 || Push[2] > 100000.0 || Push[0] < -100000.0 || Push[1] < -100000.0 || Push[2] < -100000.0) //knockback is way too huge. set to 0.
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

void RemoveNpcFromEnemyList(int npc, bool ingoresetteam = false)
{
	if(!ingoresetteam)
		SetTeam(npc, TFTeam_Red);
		
	//set to red just incase!
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //BLUE npcs.
	{
		int entity_close = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
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
	bool type = BulletAndMeleeTrace(entity, 0, iExclude);
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
		if(IsEntityTowerDefense(npcpather))
			AddComputingDelay += 3.0;

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
		
	CClotBody npc = view_as<CClotBody>(entity);
	float Push[3];
	npc.m_vecpunchforce(Push, true);
	SDKHooks_TakeDamage(entity, 0, 0, 199999999.0, DMG_BLAST, -1, {0.1,0.1,0.1}, _, _, ZR_SLAY_DAMAGE); // 2048 is DMG_NOGIB?
	CBaseCombatCharacter_EventKilledLocal(entity, 0, 0, 1.0, DMG_TRUEDAMAGE, -1, {0.0,0.0,0.0}, {0.0,0.0,0.0});
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
			b_DoNotGiveWaveDelay[iNpc] = true; //dont delay spawns if static
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
	if(Construction_Mode())
	{
		RaidAllowsBuildings = true;
	}
	switch(value)
	{
		//if a raidboss exists, but we have a rule to make it still target buildings, set to true!

		//construction forces building attacking.
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

public void TeleportBackToLastSavePosition(int entity)
{
	if(f3_VecTeleportBackSave_OutOfBounds[entity][0] != 0.0)
	{
		i_npcspawnprotection[entity] = NPC_SPAWNPROT_UNSTUCK;
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
			npcBase.GetPathFollower().Invalidate();
			npcBase.SetVelocity({0.0,0.0,0.0});
			//make them lose their target.
		}
	}
}

void SaveLastValidPositionEntity(int entity, float vecsaveforce[3] = {0.0,0.0,0.0})
{
	//first see if they are on the ground
	if(vecsaveforce[2] != 0.0)
	{
		//Save new point
		f3_VecTeleportBackSave_OutOfBounds[entity] = vecsaveforce;
		return;
	}
	if(f_GameTimeTeleportBackSave_OutOfBounds[entity] > GetGameTime())
		return;

	f_GameTimeTeleportBackSave_OutOfBounds[entity] = GetGameTime() + GetRandomFloat(1.5, 2.2);
	//dont save location too often

	//Am i a player?
	if(entity <= MaxClients)
	{
		if (!IsPlayerAlive(entity))
			return;

		//am i on the ground? If not, then dont save.
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
		if(!SavePosition)
			return;
		/*
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];
		hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );
		
		b_AntiSlopeCamp[entity] = false;
		//Make sure they arent on a slope!
		if(!SavePosition)
		{
			static float hullcheckmaxs_Player[3];
			static float hullcheckmins_Player[3];
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );	

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
		slope camp isnt needed as it checks for valid navs anyways
		*/
	
		if(i_InHurtZone[entity])
			return;

		float AbsOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsOrigin);

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
			
		if(i_InHurtZone[entity])
			return;

		float AbsOrigin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", AbsOrigin);
		//This should be a safe space for us to save the location for later teleporting.
		f3_VecTeleportBackSave_OutOfBounds[entity] = AbsOrigin;		
	}
}

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
	Format(c_NpcName[Text_Entity], 255, speechtext);
	Format(ch_SpeechBubbleEndingScroll[entity], 10, endingtextscroll);
	i_SpeechBubbleTotalText_ScrollingPart[entity] = 0;
	i_SpeechEndingScroll_ScrollingPart[entity] = 0;
	if(entity > MaxClients)
	{
		SDKUnhook(entity, SDKHook_Think, NpcSpeechBubbleTalk);
		SDKHook(entity, SDKHook_Think, NpcSpeechBubbleTalk);
	}
	else
	{
		SDKUnhook(entity, SDKHook_PreThink, NpcSpeechBubbleTalk);
		SDKHook(entity, SDKHook_PreThink, NpcSpeechBubbleTalk);
	}
}

void NpcSpeechBubbleTalk(int iNPC)
{
	int Text_Entity;
	Text_Entity = EntRefToEntIndex(i_SpeechBubbleEntity[iNPC]);
	if(!IsValidEntity(Text_Entity))
	{
		if(iNPC > MaxClients)
			SDKUnhook(iNPC, SDKHook_Think, NpcSpeechBubbleTalk);
		else
			SDKUnhook(iNPC, SDKHook_PreThink, NpcSpeechBubbleTalk);
		return;
	}
	if(f_SpeechTickDelay[iNPC] > GetGameTime())
		return;
	
	if(iNPC > MaxClients)
		f_SpeechTickDelay[iNPC] = GetGameTime() + 0.05;
	else
		f_SpeechTickDelay[iNPC] = GetGameTime() + 0.035;
	int TotalLength = strlen(c_NpcName[Text_Entity]);

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

			Format(TestMax, sizeof(TestMax), "%s%s",c_NpcName[Text_Entity],TestMaxEnd);
			DispatchKeyValue(Text_Entity, "message", TestMax);


			if(f_SpeechDeleteAfter[iNPC] < GetGameTime())
			{
				if(iNPC > MaxClients)
					SDKUnhook(iNPC, SDKHook_Think, NpcSpeechBubbleTalk);
				else
					SDKUnhook(iNPC, SDKHook_PreThink, NpcSpeechBubbleTalk);
				RemoveEntity(Text_Entity);
			}
			return;
		}
		f_SpeechDeleteAfter[iNPC] = GetGameTime() + 5.0;
	}
	i_SpeechBubbleTotalText_ScrollingPart[iNPC] += 1;
	char TestMax[255];
	int MaxTextCutoff = i_SpeechBubbleTotalText_ScrollingPart[iNPC];
	Format(TestMax, MaxTextCutoff, c_NpcName[Text_Entity]);
	DispatchKeyValue(Text_Entity, "message", TestMax);
}


#define PARTICLE_DISPATCH_FROM_ENTITY		(1<<0)
#define PARTICLE_DISPATCH_RESET_PARTICLES	(1<<1)

#define FIRSTPERSON 1
#define THIRDPERSON 2

Handle Timer_Ingition_Settings[MAXENTITIES] = {INVALID_HANDLE, ...};
Handle Timer_Ingition_ReApply[MAXENTITIES] = {INVALID_HANDLE, ...};
float Reapply_BurningCorpse[MAXENTITIES];

void IgniteTargetEffect(int target, int ViewmodelSetting = 0, int viewmodelClient = 0, bool type = false)
{
	Reapply_BurningCorpse[target] = GetGameTime() + 5.0;
	if(ViewmodelSetting > 0)
	{
		EntityKilled_HitDetectionCooldown(target, IgniteClientside);
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
		pack.WriteCell(type);
	}
	else
	{
		TE_SetupParticleEffect(type ? "halloween_burningplayer_flyingbits" : "burningplayer_corpse", PATTACH_ABSORIGIN_FOLLOW, target);
		TE_WriteNum("m_bControlPoint1", target);	
		TE_SendToAll();
		if(Timer_Ingition_ReApply[target] != null)
		{
			delete Timer_Ingition_ReApply[target];
			Timer_Ingition_ReApply[target] = null;
		}		
		DataPack pack;
		Timer_Ingition_ReApply[target] = CreateDataTimer(type ? 1.5 : 5.0, IgniteTimerVisual_Reignite, pack);
		pack.WriteCell(target);
		pack.WriteCell(EntIndexToEntRef(target));
		pack.WriteCell(type);
	}
}

public Action IgniteTimerVisual_Reignite(Handle timer, DataPack pack)
{
	pack.Reset();
	int targetoriginal = pack.ReadCell();
	int target = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(target))
	{
		Timer_Ingition_ReApply[targetoriginal] = null;
		return Plugin_Continue;
	}
	bool type = pack.ReadCell();
	ExtinguishTarget(target, true);
	Timer_Ingition_ReApply[targetoriginal] = null;
	IgniteTargetEffect(target, _, _, type);
	return Plugin_Continue;
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
	bool type = pack.ReadCell();
	for( int client = 1; client <= MaxClients; client++ ) 
	{
		if (IsValidClient(client))
		{
			//extinquish shortly.
			if(Reapply_BurningCorpse[target] < GetGameTime())
			{
				Reapply_BurningCorpse[target] = GetGameTime() + 5.0;
				IngiteTargetClientside(target, client, false, type);
			}
			if(b_FirstPersonUsesWorldModel[client])
			{
				//always ignited.
				if(InvisMode == THIRDPERSON)
				{
					IngiteTargetClientside(target, client, true, type);
				}
				else
				{
					IngiteTargetClientside(target, client, false, type);
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
						IngiteTargetClientside(target, client, false, type);
					}
					else
					{
						IngiteTargetClientside(target, client, true, type);
					}
					continue;		
				}
				else
				{
					if(InvisMode == THIRDPERSON)
					{
						IngiteTargetClientside(target, client, true, type);
					}
					else
					{
						IngiteTargetClientside(target, client, false, type);
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
					IngiteTargetClientside(target, client, false, type);
				}
				else
				{
					IngiteTargetClientside(target, client, true, type);
				}
				continue;	
			}
			if(InvisMode == THIRDPERSON)
			{
				IngiteTargetClientside(target, client, true, type);
			}
			else
			{
				IngiteTargetClientside(target, client, false, type);
			}
		}
	}
	return Plugin_Continue;
}



void IngiteTargetClientside(int target, int client, bool ingite, bool type)
{
	if(ingite && !IsIn_HitDetectionCooldown(target,client, IgniteClientside))
	{
		Set_HitDetectionCooldown(target,client, FAR_FUTURE, IgniteClientside);
		TE_SetupParticleEffect(type ? "halloween_burningplayer_flyingbits" : "burningplayer_corpse", PATTACH_ABSORIGIN_FOLLOW, target);
		TE_WriteNum("m_bControlPoint1", target);	
		TE_SendToClient(client);
	}
	else if(!ingite && IsIn_HitDetectionCooldown(target,client, IgniteClientside))
	{
		Set_HitDetectionCooldown(target,client, 0.0, IgniteClientside);
		TE_Start("EffectDispatch");
		
		if(target > 0)
			TE_WriteNum("entindex", target);
		
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(type ? "halloween_burningplayer_flyingbits" : "burningplayer_corpse"));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToClient(client);	
	}

}
void ExtinguishTarget(int target, bool dontkillTimer = false)
{
	TE_Start("EffectDispatch");
	
	if(target > 0)
		TE_WriteNum("entindex", target);
	
	TE_WriteNum("m_nHitBox", GetParticleEffectIndex("burningplayer_corpse"));
	TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
	TE_SendToAll();
	if(Timer_Ingition_Settings[target] != null)
	{
		delete Timer_Ingition_Settings[target];
		Timer_Ingition_Settings[target] = null;
	}
	if(!dontkillTimer)
	{
		if(Timer_Ingition_ReApply[target] != null)
		{
			delete Timer_Ingition_ReApply[target];
			Timer_Ingition_ReApply[target] = null;
		}	
	}
}




void IsEntityInvincible_Shield(int entity)
{
	int NpcInvulShieldDisplay;

	if(HasSpecificBuff(entity, "UBERCHARGED"))
		NpcInvulShieldDisplay = 3;

#if defined ZR
//This is not neccecary in RPG.
	if(i_npcspawnprotection[entity] == NPC_SPAWNPROT_ON || i_npcspawnprotection[entity] == NPC_SPAWNPROT_UNSTUCK)
		NpcInvulShieldDisplay = 2;
#endif
	if(IsInvuln(entity, true))
		NpcInvulShieldDisplay = 1;
	
	CClotBody npc = view_as<CClotBody>(entity);
	if(!NpcInvulShieldDisplay || b_ThisEntityIgnored[entity])
	{
		IsEntityInvincible_ShieldRemove(entity);
		return;
	}
	if(IsValidEntity(i_InvincibleParticle[entity]))
	{
		int Shield = EntRefToEntIndex(i_InvincibleParticle[entity]);
		if(NpcInvulShieldDisplay == 1)
		{
			if(i_InvincibleParticlePrev[Shield] != 0)
			{
				SetEntityRenderMode(Shield, RENDER_NORMAL);
				SetEntityRenderColor(Shield, 0, 255, 0, 255);
				i_InvincibleParticlePrev[Shield] = 0;
				SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
			}
		}
		else if(NpcInvulShieldDisplay == 2)
		{
			if(i_InvincibleParticlePrev[Shield] != 1)
			{
				SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
				SetEntityRenderColor(Shield, 0, 50, 50, 35);
				i_InvincibleParticlePrev[Shield] = 1;
				SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
			}
		}
		else if(NpcInvulShieldDisplay == 3)
		{
			if(i_InvincibleParticlePrev[Shield] != 2)
			{
				SetEntityRenderMode(Shield, RENDER_NORMAL);
				SetEntityRenderColor(Shield, 255, 255, 255, 255);
				i_InvincibleParticlePrev[Shield] = 2;
				SetEntProp(Shield, Prop_Send, "m_nSkin", 4);
			}
		}
		return;
	}

	int Shield = npc.EquipItem("", "models/effects/resist_shield/resist_shield.mdl");
	if(b_IsGiant[entity])
		SetVariantString("1.38");
	else
		SetVariantString("1.05");
	i_InvincibleParticlePrev[Shield] = -1;

	AcceptEntityInput(Shield, "SetModelScale");
	
	SetEntProp(Shield, Prop_Send, "m_nSkin", 1);
	if(NpcInvulShieldDisplay == 1)
	{
		if(i_InvincibleParticlePrev[Shield] != 0)
		{
			SetEntityRenderMode(Shield, RENDER_NORMAL);
			SetEntityRenderColor(Shield, 0, 255, 0, 255);
			i_InvincibleParticlePrev[Shield] = 0;
		}
	}
	else if(NpcInvulShieldDisplay == 2)
	{
		if(i_InvincibleParticlePrev[Shield] != 1)
		{
			SetEntityRenderMode(Shield, RENDER_TRANSCOLOR);
			SetEntityRenderColor(Shield, 0, 50, 50, 35);
			i_InvincibleParticlePrev[Shield] = 1;
		}
	}
	else if(NpcInvulShieldDisplay == 3)
	{
		if(i_InvincibleParticlePrev[Shield] != 2)
		{
			SetEntityRenderMode(Shield, RENDER_NORMAL);
			SetEntityRenderColor(Shield, 255, 255, 255, 255);
			i_InvincibleParticlePrev[Shield] = 2;
			SetEntProp(Shield, Prop_Send, "m_nSkin", 4);
		}
	}

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


static int BadSpotPoints[MAXPLAYERS];
stock void Spawns_CheckBadClient(int client/*, int checkextralogic = 0*/)
{
#if defined ZR
	if(CvarInfiniteCash.BoolValue)
	{
		return;
	}
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
	//Are we checking 
	/*
		0 = Passively wating every so often
		2 = when landing after being airborn

	*/
//	if(checkextralogic == 0)
	/*
		TODO: If they are out of bounds in a non playable area, kill them.
		//Did any NPC try to attack us, if not...
	*/
	if(RPGCore_ClientTargetedByNpcReturn(client) < GetGameTime())
	{
		//are we somehow in a battle regardless? if no then...
		if(f_InBattleDelay[client] < GetGameTime())
		{
			BadSpotPoints[client] = 0;
			return;
		}
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
#if defined RPG
		if(!b_is_a_brush[GroundEntity])
#endif
		{
			return;
		}
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
				SDKHooks_TakeDamage(client, 0, 0, damage, DMG_TRUEDAMAGE|DMG_PREVENT_PHYSICS_FORCE, -1, _, _, _, ZR_STAIR_ANTI_ABUSE_DAMAGE);
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

void ResetAllArmorStatues(int entiity)
{
	fl_ArmorSetting[entiity][0] = 0.0;
	fl_ArmorSetting[entiity][1] = 0.0;
	fl_ArmorSetting[entiity][2] = 0.0;
	i_ArmorSetting[entiity][0] = 0;
	i_ArmorSetting[entiity][1] = 0;
}

stock void GrantEntityArmor(int entity, bool Once = true, float ScaleMaxHealth, float ArmorProtect, int ArmorType,
float custom_maxarmour = 0.0, int ArmorGiver = -1)
{
	CClotBody npc = view_as<CClotBody>(entity);
	if(Once)
	{
		if(npc.m_iArmorGiven)
		{
			return;
		}
	}
	npc.m_iArmorGiven = true;
	npc.m_iArmorType = ArmorType;
	if(custom_maxarmour == 0.0)
	{
		npc.m_flArmorProtect = ArmorProtect;
	}
	else
	{
		if(npc.m_flArmorProtect == 0.0)
			npc.m_flArmorProtect = ArmorProtect;
	}
	
	if(custom_maxarmour == 0.0)
	{
		float flMaxHealth = ScaleMaxHealth * float(ReturnEntityMaxHealth(npc.index));
		npc.m_flArmorCount = flMaxHealth;
		npc.m_flArmorCountMax = flMaxHealth;
	}
	else
	{
		float flMaxHealth = ScaleMaxHealth * float(ReturnEntityMaxHealth(npc.index));
		if(npc.m_flArmorCount > flMaxHealth)
		{
			return;
		}
		if(flMaxHealth <= (npc.m_flArmorCount + custom_maxarmour))
		{
			npc.m_flArmorCount 		= 	flMaxHealth;
			npc.m_flArmorCountMax 	= flMaxHealth;
			return;
		}
		npc.m_flArmorCount 		+= 	custom_maxarmour;
		npc.m_flArmorCountMax += custom_maxarmour;
		if(npc.m_flArmorCountMax >= npc.m_flArmorCount)
			npc.m_flArmorCountMax = npc.m_flArmorCount;
	}
	
	if(ArmorGiver > 0 && custom_maxarmour > 0.0)
	{
		ApplyArmorEvent(entity, RoundToNearest(custom_maxarmour), ArmorGiver);
	}
	//any extra logic please add here. deivid.
}

int ReturnEntityMaxHealth(int entity)
{
	if(entity <= MaxClients)
	{
		return SDKCall_GetMaxHealth(entity);
	}
	return GetEntProp(entity, Prop_Data, "m_iMaxHealth");
}


float[] GetBehindTarget(int target, float Distance, float origin[3])
{
	float VecForward[3];
	float vecRight[3];
	float vecUp[3];
	
	GetVectors(target, VecForward, vecRight, vecUp); //Sorry i dont know any other way with this :(
	
	float vecSwingEnd[3];
	vecSwingEnd[0] = origin[0] - VecForward[0] * (Distance);
	vecSwingEnd[1] = origin[1] - VecForward[1] * (Distance);
	vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

	return vecSwingEnd;
}

#if defined RPG
char[] NpcStats_ReturnNpcName(int entity)
#else
char[] NpcStats_ReturnNpcName(int entity, bool NoTrans = false)
#endif
{
#if defined RPG
	return c_NpcName[entity];
#else
	char NameReturn[255];
	if(!b_NameNoTranslation[entity] && !NoTrans)
		Format(NameReturn, sizeof(NameReturn), "%t", c_NpcName[entity]);
	else
		Format(NameReturn, sizeof(NameReturn), "%s", c_NpcName[entity]);
	return NameReturn;
#endif
}

void NpcStats_CopyStats(int Owner, int Child)
{
	CClotBody ownernpc = view_as<CClotBody>(Owner);
	CClotBody childnpc = view_as<CClotBody>(Child);

	childnpc.m_iTowerdefense_Checkpoint = ownernpc.m_iTowerdefense_Checkpoint;
	childnpc.m_iCheckpointTarget		= ownernpc.m_iCheckpointTarget;
}


// from https://github.com/TF2-DMB/CBaseNPC/blob/f2af3f7b74af2d20cf5f673565cb31a887835fb8/scripting/cbasenpc/actiontest/nb_test_scout.sp#L125
//adjusted for various fixes.
static bool TriesClimbingUpLedge(CBaseNPC_Locomotion loco, const float goal[3], const float fwd[3], int entity)
{
	float feet[3];
	loco.GetFeet(feet);
	
	float MaxSpeedjump = loco.GetDesiredSpeed();
	if(MaxSpeedjump == 0.0) //if standing still
	{
		MaxSpeedjump = 150.0;
	}
	if(MaxSpeedjump <= 100.0)
		MaxSpeedjump = 100.0;
	if(MaxSpeedjump >= 150.0)
		MaxSpeedjump = 150.0;
	float GoalAm[3];
	GoalAm = goal;
	if (GetVectorDistance(feet, GoalAm) > MaxSpeedjump)
	{
		return false;
	}
	int bot_entidx = loco.GetBot().GetNextBotCombatCharacter();
	loco.SetVelocity({0.0,0.0,0.0});
	//but we reset the pos to make a perfect jump everytime.
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	npc.FaceTowards(GoalAm, 20000.0);
	//we save when they recently jumped.
	float JumpFloat = GetEntPropFloat(bot_entidx, Prop_Data, "f_JumpedRecently");
	JumpFloat -= 0.3;
	if(JumpFloat > GetGameTime())
	{
		//fix now
		if(GetEntProp(bot_entidx, Prop_Data, "i_Climbinfractions") >= 4)
		{
		//	SetEntPropFloat(bot_entidx, Prop_Data, "f_JumpedRecently", 0.0);
			//took too long, teleport.
			StuckFixNpc_Ledge(npc, true, 1);
			return false;
		}
		else
		{
			float Difference = GoalAm[2] - feet[2];
			if(Difference <= 0.0)
				Difference *= -1.0;

			Difference *= 15.0;
			StuckFixNpc_Ledge(npc, false, 2, Difference);
			SetEntPropFloat(bot_entidx, Prop_Data, "f_ClimbingAm", GetGameTime() + 1.0);
			SetEntProp(bot_entidx, Prop_Data, "i_Climbinfractions", GetEntProp(bot_entidx, Prop_Data, "i_Climbinfractions") + 1);
			return loco.CallBaseFunction(goal, fwd, entity);
		}
	}
	SetEntPropFloat(bot_entidx, Prop_Data, "f_JumpedRecently", GetGameTime() + 0.65);
	return loco.CallBaseFunction(goal, fwd, entity);
}

#define DEFAULT_ANTISTUCK_SPEED 100.0
void StuckFixNpc_Ledge(CClotBody npc, bool TeleportDo = true, int LaunchForward = 0, float GiveSpeedUp = 250.0)
{
	static float flMyPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flMyPos);
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[npc.index])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else if(f3_CustomMinMaxBoundingBox[npc.index][1] != 0.0)
	{
		hullcheckmaxs[0] = f3_CustomMinMaxBoundingBox[npc.index][0];
		hullcheckmaxs[1] = f3_CustomMinMaxBoundingBox[npc.index][1];
		hullcheckmaxs[2] = f3_CustomMinMaxBoundingBox[npc.index][2];

		hullcheckmins[0] = -f3_CustomMinMaxBoundingBox[npc.index][0];
		hullcheckmins[1] = -f3_CustomMinMaxBoundingBox[npc.index][1];
		hullcheckmins[2] = 0.0;	
	}
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );			
	}
	hullcheckmaxs[0] += 1.0;
	hullcheckmaxs[1] += 1.0;
	hullcheckmaxs[2] += 1.0;

	hullcheckmins[0] -= 1.0;
	hullcheckmins[1] -= 1.0;
	hullcheckmins[2] -= 1.0;
	CNavArea areaNavget;
	Segment segment;
	Segment segment2;
	segment = npc.GetPathFollower().FirstSegment();
	float VecPos[3];
	if(segment != NULL_PATH_SEGMENT)
	{
		segment2 = npc.GetPathFollower().NextSegment(segment);
		segment2 = npc.GetPathFollower().NextSegment(segment2);
	}	
	if(segment2 != NULL_PATH_SEGMENT)
	{
		areaNavget = segment2.area;
		areaNavget.GetCenter(VecPos);
	}
	if(VecPos[2] != 0.0)
	{
		flMyPos[2] = VecPos[2];
	}
	float ang[3], Vectorspeed[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	Vectorspeed[2] = GiveSpeedUp;
	if(LaunchForward)
	{
		Vectorspeed[0] = -1.0 * (Cosine(DegToRad(ang[0]))*Cosine(DegToRad(ang[1]))*DEFAULT_ANTISTUCK_SPEED);
		Vectorspeed[1] = -1.0 * (Cosine(DegToRad(ang[0]))*Sine(DegToRad(ang[1]))*DEFAULT_ANTISTUCK_SPEED);
		if(LaunchForward == 2)
		{
			Vectorspeed[0] *= -1.0;
			Vectorspeed[1] *= -1.0;
		}
	}
	if(TeleportDo)
	{
		if(Npc_Teleport_Safe(npc.index, flMyPos, hullcheckmins, hullcheckmaxs, true))
		{
			Vectorspeed[0] *= -1.0;
			Vectorspeed[1] *= -1.0;
		}
	}
	else
	{
		npc.Jump();
	}
	npc.SetVelocity(Vectorspeed);
	SetEntPropFloat(npc.index, Prop_Data, "f_JumpedRecently", GetGameTime() + 0.5);
}

/*
https://steamcommunity.com/sharedfiles/filedetails/?id=1911160067

Website for own RGB stuff:
https://www.webfx.com/web-design/color-picker/?colorcode=E7B53B
http://www.shodor.org/stella2java/rgbint.html

Here is a table of RGB integer values for the paints in TF2:
Indubitably Green
7511618
Zepheniah's Greed
4345659
Noble Hatter's Violet
5322826
Color No. 216-190-216
14204632
A deep Commitment to Purple
8208497
Mann Co. Orange
13595446
Muskelmannbraun
10843461
Peculiarly Drab Tincture
12955537
Radigan Conagher Brown
6901050
Ye Olde Rustic Colour
8154199
Australium Gold
15185211
Aged Moustache Grey
8289918
An Extraordinary Abundance of Tinge
15132390
A Distinctive Lack of Hue
1315860
Pink as Hell
16738740
A Color Similar to Slate
3100495
Drably Olive
8421376
The Bitter Taste of Defeat and Lime
3329330
The Color of a Gentlemann's Business Pants
15787660
Dark Salmon Injustice
15308410
Mann's Mint
12377523
After Eight
2960676
Team Spirit (RED)
12073019
Team Spirit (BLU)
5801378
Operator's Overalls (RED)
4732984
Operator's Overalls (BLU)
3686984
Waterlogged Lab Coat (RED)
11049612
Waterlogged Lab Coat (BLU)
8626083
Balaclavas are Forever (RED)
3874595
Balaclavas are Forever (BLU)
1581885
The Value of Teamwork (RED)
8400928
The Value of Teamwork (BLU)
2452877
Cream Spirit (RED)
12807213
Cream Spirit (BLU)
12091445
An Air of Debonair (RED)
6637376
An Air of Debonair (BLU)
2636109
*/
int NpcColourCosmetic_ViaPaint(int entity, int color, bool halloweenSpell = false)
{
	// To paint NPC cosmetics a certain color, we need an econ entity painted this color, then make the econ entity own the NPC cosmetic entity
	// To avoid creating many edicts, only create one econ entity per color, then reuse it in case other cosmetics use the same color
	
	WearableColor wearableColor;
	wearableColor.wearableRef = INVALID_ENT_REFERENCE;
	
	int index = h_ColoredWearables.FindValue(color);
	if (index != -1)
	{
		h_ColoredWearables.GetArray(index, wearableColor);
		if (IsValidEntity(wearableColor.wearableRef))
		{
			// Found an econ entity using this color, reuse it
			SetEntityOwner(entity, wearableColor.wearableRef);
			wearableColor.entities.Push(EntIndexToEntRef(entity));
			return wearableColor.wearableRef;
		}
		else
		{
			// This can happen if the wearable was deleted by something out of our control
			// and the color handler hasn't been updated yet
			return -1;
		}
	}
	
	// We have yet to use this color, create an econ entity for this
	int Wearable = CreateEntityByName("tf_wearable");
	if(Wearable == -1)
		return -1;
	
	SetEntProp(Wearable, Prop_Send, "m_bInitialized", true);
	TF2Attrib_SetByName(Wearable, halloweenSpell ? "SPELL: set item tint RGB" : "set item tint RGB", float(color));
	SetEntityOwner(entity, Wearable);
	DispatchSpawn(Wearable);
	ActivateEntity(Wearable);	
	SetEdictFlags(Wearable, GetEdictFlags(Wearable) | FL_EDICT_ALWAYS);
	b_IsEntityAlwaysTranmitted[Wearable] = true;
	
	wearableColor.color = color;
	wearableColor.wearableRef = EntIndexToEntRef(Wearable);
	
	wearableColor.entities = new ArrayList();
	wearableColor.entities.Push(EntIndexToEntRef(entity));
	
	h_ColoredWearables.PushArray(wearableColor);
	
	return Wearable;
}

Action NPCStats_Timer_HandlePaintedWearables(Handle timer)
{
	NPCStats_HandlePaintedWearables();
	return Plugin_Continue;
}

void NPCStats_HandlePaintedWearables()
{
	// Check if each color is still being used by a cosmetic
	for (int i = h_ColoredWearables.Length - 1; i >= 0; i--)
	{
		WearableColor wearableColor;
		h_ColoredWearables.GetArray(i, wearableColor);
		
		bool foundValidEntity;
		
		// This color is still being used, but are the cosmetics in here still valid?
		for (int j = wearableColor.entities.Length - 1; j >= 0; j--)
		{
			if (IsValidEntity(wearableColor.entities.Get(j)))
				foundValidEntity = true;
			else
				wearableColor.entities.Erase(j);
		}
		
		// None of the cosmetics using this color are valid, we can erase this color from the list
		if (!foundValidEntity)
		{
			if (IsValidEntity(wearableColor.wearableRef))
				RemoveEntity(wearableColor.wearableRef);
			
			delete wearableColor.entities;
			h_ColoredWearables.Erase(i);
		}
	}
}