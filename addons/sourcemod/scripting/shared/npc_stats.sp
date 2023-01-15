#pragma semicolon 1
#pragma newdecls required

#if defined ZR
// Stuff that's used only for ZR but npc_stats
// needs so it can't go into the zr_core.sp
enum
{
	TEUTON_NONE,
	TEUTON_DEAD,
	TEUTON_WAITING
}

int dieingstate[MAXTF2PLAYERS];
int TeutonType[MAXTF2PLAYERS];
int i_TeamGlow[MAXENTITIES]={-1, ...};
bool EscapeModeMap;
bool EscapeModeForNpc;
int Zombies_Currently_Still_Ongoing;
int RaidBossActive = INVALID_ENT_REFERENCE;					//Is the raidboss alive, if yes, what index is the raid?
float Medival_Difficulty_Level = 0.0;
int i_KillsMade[MAXTF2PLAYERS];
int i_Backstabs[MAXTF2PLAYERS];
int i_Headshots[MAXTF2PLAYERS];	
bool b_ThisNpcIsSawrunner[MAXENTITIES];
bool b_thisNpcHasAnOutline[MAXENTITIES];
bool b_ThisNpcIsImmuneToNuke[MAXENTITIES];
#endif

#if defined RPG
float f3_SpawnPosition[MAXENTITIES][3];
int hFromSpawnerIndex[MAXENTITIES] = {-1, ...};
int i_NpcIsUnderSpawnProtectionInfluence[MAXENTITIES] = {0, ...};
#endif

static int g_particleImpactFlesh;
static int g_particleImpactRubber;
static int g_modelArrow;

static ConVar flTurnRate;

static int g_sModelIndexBloodDrop;
static int g_sModelIndexBloodSpray;
static float f_TimeSinceLastStunHit[MAXENTITIES];

public Action Command_PetMenu(int client, int argc)
{
	//What are you.
	if(!(client > 0 && client <= MaxClients && IsClientInGame(client)))
		return Plugin_Handled;
	
	if(argc < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spawn_npc <index> [data] [ally]");
		return Plugin_Handled;
	}
	
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	
	char buffer[16];
	GetCmdArg(2, buffer, sizeof(buffer));
	
	bool ally;
	if(argc > 2)
		ally = view_as<bool>(GetCmdArgInt(3));
	
#if defined ZR
	int entity = Npc_Create(GetCmdArgInt(1), client, flPos, flAng, ally, buffer);
	if(IsValidEntity(entity))
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") != view_as<int>(TFTeam_Red))
		{
			Zombies_Currently_Still_Ongoing += 1;
		}
	}
#else
	Npc_Create(GetCmdArgInt(1), client, flPos, flAng, ally, buffer);
#endif

	return Plugin_Handled;
}

void OnMapStart_NPC_Base()
{
	for (int i = 0; i < (sizeof(g_GibSound));   i++) { PrecacheSound(g_GibSound[i]);   }
	for (int i = 0; i < (sizeof(g_GibSoundMetal));   i++) { PrecacheSound(g_GibSoundMetal[i]);   }
	for (int i = 0; i < (sizeof(g_CombineSoldierStepSound));   i++) { PrecacheSound(g_CombineSoldierStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_CombineMetroStepSound));   i++) { PrecacheSound(g_CombineMetroStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundSuccess));	   i++) { PrecacheSound(g_ArrowHitSoundSuccess[i]);	   }
	for (int i = 0; i < (sizeof(g_ArrowHitSoundMiss));	   i++) { PrecacheSound(g_ArrowHitSoundMiss[i]);	   }
	for (int i = 0; i < (sizeof(g_PanzerStepSound));   i++) { PrecacheSound(g_PanzerStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_TankStepSound));   i++) { PrecacheSound(g_TankStepSound[i]);   }
	for (int i = 0; i < (sizeof(g_RobotStepSound));   i++) { PrecacheSound(g_RobotStepSound[i]);   }
	
#if defined ZR
	EscapeModeMap = false;
	
	char buffer[16];
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "info_target")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
		if(!StrEqual(buffer, "zr_escapemode", false))
			continue;
		
		EscapeModeMap = true;
		break;
	}
#endif

	g_sModelIndexBloodDrop = PrecacheModel("sprites/bloodspray.vmt");
	g_sModelIndexBloodSpray = PrecacheModel("sprites/blood.vmt");
	
	PrecacheDecal("sprites/blood.vmt", true);
	PrecacheDecal("sprites/bloodspray.vmt", true);
	
	g_particleImpactMetal = PrecacheParticleSystem("bot_impact_light");
	g_particleImpactFlesh = PrecacheParticleSystem("blood_impact_red_01");
	g_particleImpactRubber = PrecacheParticleSystem("halloween_explosion_bits");
	g_modelArrow = PrecacheModel("models/weapons/w_models/w_arrow.mdl");
	PrecacheModel(ARROW_TRAIL);
	PrecacheDecal(ARROW_TRAIL, true);
	PrecacheModel(ARROW_TRAIL_RED);
	PrecacheDecal(ARROW_TRAIL_RED, true);

	Zero(f_TimeSinceLastStunHit);
	
	InitNavGamedata();
	
	NPC_MapStart();
}

void NPC_Base_OnEntityDestroyed()
{
	RequestFrame(DHookCleanIds);
}

public void DHookCleanIds()
{
	StringMapSnapshot snap = HookIdMap.Snapshot();
	if(snap)
	{
		char buffer[12];
		int length2 = snap.Length;
		for(int a; a<length2; a++)
		{
			snap.GetKey(a, buffer, sizeof(buffer));
			if(EntRefToEntIndex(StringToInt(buffer)) <= MaxClients)
			{
				ArrayList list;
				
				HookIdMap.GetValue(buffer, list);
				HookIdMap.Remove(buffer);
				
				if(list)
				{
					/*
					static const char HookName[][] =
					{
						"g_hGetStepHeight",
						"g_hGetGravity",
						"g_hShouldCollideWith",
						"g_hGetMaxAcceleration",
						"g_hGetFrictionSideways",
						"g_hGetRunSpeed",
						"g_hGetGroundNormal",
						"g_hGetHullWidth",
						"g_hGetHullHeight",
						"g_hGetStandHullHeight",
						"g_hGetActivity",
						"g_hIsActivity",
						"g_hGetSolidMask",
						"g_hStartActivity"
					};
					*/
					int length = list.Length;
					for(int i; i<length; i++)
					{
						int id2 = list.Get(i);
						if(id2 != INVALID_HOOK_ID)
						{
							int value = 1;
							IntToString(id2, buffer, sizeof(buffer));
							if(HookListMap.GetValue(buffer, value) && value > 1)
							{
								HookListMap.SetValue(buffer, value-1);
						//		LogError("Raw hook %d removed dupe (%s %d)", id2, HookName[i], i);
							}
							else
							{
								if(!DHookRemoveHookID(id2))
								{
							//			LogError("Raw hook %d somehow was removed (%s %d)", id2, HookName[i], i);	
								}
								
								HookListMap.Remove(buffer);
							}
						}
					}
					
					delete list;
				}
			}
		}
		delete snap;
	}
}


methodmap CClotBody
{
	public CClotBody(float vecPos[3], float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool Ally = false,
						bool Ally_Invince = false,
						bool isGiant = false,
						bool IgnoreBuildings = false,
						bool IsRaidBoss = false,
						float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		int npc = CreateEntityByName("base_boss");
		DispatchKeyValueVector(npc, "origin",	 vecPos);
		DispatchKeyValueVector(npc, "angles",	 vecAng);
		DispatchKeyValue(npc,	   "model",	  model);
		DispatchKeyValue(npc,	   "modelscale", modelscale);
		DispatchKeyValue(npc,	   "health",	 health);
		
		if(Ally)
		{
			if(Ally_Invince)
			{
				b_ThisEntityIgnored[npc] = true;
			}
			SetEntProp(npc, Prop_Send, "m_iTeamNum", TFTeam_Red);
		}
		else
		{
			SetEntProp(npc, Prop_Send, "m_iTeamNum", TFTeam_Blue);
		}
		b_bThisNpcGotDefaultStats_INVERTED[npc] = true;
		b_NpcHasDied[npc] = false;
		DispatchSpawn(npc); //Do this at the end :)

#if defined RPG
		SetEntPropFloat(npc, Prop_Send, "m_fadeMinDist", 1600.0);
		SetEntPropFloat(npc, Prop_Send, "m_fadeMaxDist", 2000.0);
#endif
		SetEntProp(npc, Prop_Data, "m_bSequenceLoops", true);
		//potentially newly added ? or might not get set ?
		//Just set it to true at all times.
		if(Ally)
		{
			SetEntityCollisionGroup(npc, 24);
		}
		
#if defined ZR
		//Enable Harder zombies once in freeplay.
		if(!EscapeModeForNpc)
		{
			if(Waves_InFreeplay())
			{
				EscapeModeForNpc = true;
			}
		}
#endif

		Address pNB =		 SDKCall(g_hMyNextBotPointer,	   npc);
		Address pLocomotion = SDKCall(g_hGetLocomotionInterface, pNB);
		if(pLocomotion < view_as<Address>(0x10000))
			PrintToServer("Invalid pLocomotion %x", pLocomotion);
		
		ArrayList list = new ArrayList();
//		g_hAlwaysTransmit.HookEntity(Hook_Pre, npc, DHook_AlwaysTransmit);	
		
		list.Push(DHookRaw(g_hGetStepHeight,	   true, pLocomotion));
		list.Push(DHookRaw(g_hGetGravity,		  true, pLocomotion));
		
		if(!Ally)
		{
#if defined ZR
			if(IgnoreBuildings || IsValidEntity(EntRefToEntIndex(RaidBossActive))) //During an active raidboss, make sure that they ignore barricades
#else
			if(IgnoreBuildings)
#endif
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemyIngoreBuilding,   false, pLocomotion);
			}
			else
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemy,   false, pLocomotion);
			}
		}
		else
		{
			if(Ally_Invince)
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyInvince,   false, pLocomotion);
			}
			else
			{
				h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAlly,   false, pLocomotion);
			}
		}
		
		
		
	//	We already delete this! there is no need!
	//	This also might not even work out, because it can be changed.
	//	list.Push(h_NpcCollissionHookType[npc]);
	//	and putting it here as a "safety measure" actually causes a leak!!!
	//	not like we could have known this.
		list.Push(DHookRaw(g_hGetMaxAcceleration,  true, pLocomotion));
		list.Push(DHookRaw(g_hGetFrictionSideways, true, pLocomotion));
		list.Push(DHookRaw(g_hGetRunSpeed,		 true, pLocomotion));
		
		//if(bGroundNormal)
		list.Push(DHookRaw(g_hGetGroundNormal, true, pLocomotion));
		
		//TOP GET AUTO DELETED
		
		//BOTTOM DO NOT, BEACUSE ITS TO AN ADRESS?
		Address pBody = SDKCall(g_hGetBodyInterface, pNB);
		//if(pBody < view_as<Address>(0x10000))
		//	ThrowError("Invalid pBody %x", pBody); //what the fuck. This shit gets called 90% of the time.......................
		
		//cant use custom bounding boxes here, just use the normal ones!
		if(!isGiant)
		{
			list.Push(DHookRaw(g_hGetHullWidth,		true, pBody));
			list.Push(DHookRaw(g_hGetHullHeight,	   true, pBody));
			list.Push(DHookRaw(g_hGetStandHullHeight,  true, pBody));
		}
		else
		{
			b_IsGiant[npc] = true;
			list.Push(DHookRaw(g_hGetHullWidthGiant,		true, pBody));
			list.Push(DHookRaw(g_hGetHullHeightGiant,	   true, pBody));
			list.Push(DHookRaw(g_hGetStandHullHeightGiant,  true, pBody));			
		}
		list.Push(DHookRaw(g_hGetActivity,		 true, pBody));
		list.Push(DHookRaw(g_hIsActivity,		  true, pBody));

		//Collide with the correct stuff
		list.Push(DHookRaw(g_hGetSolidMask,		true, pBody));
		
		//Allow jumping
	//	list.Push(DHookRaw(g_hStartActivity,		true, pBody));
		
		//Don't drop money.
		//DHookEntity(g_hGetCurrencyValue, true, npc);
		
		char buffer[12];
		int id = list.Length;
		for(int i; i<id; i++)
		{
			int hook = list.Get(i);
			IntToString(hook, buffer, sizeof(buffer));
			int value = 0;
			if(HookListMap.GetValue(buffer, value))
			{
		//		LogError("Duplicate raw hook found %d", hook); Yeah we get it, just dont do this.		
			}
			
			HookListMap.SetValue(buffer, value+1);
		}
		
		IntToString(EntIndexToEntRef(npc), buffer, sizeof(buffer));
		HookIdMap.SetValue(buffer, list);
		
		
		//Ragdoll, hopefully
		DHookEntity(g_hEvent_Killed,	 false, npc);
		
		//Animevents 
		DHookEntity(g_hHandleAnimEvent,  true, npc);
		DHookEntity(g_hEvent_Ragdoll,  false, npc);
		
		//so map makers can choose between NPCs and Clients
		SetEntityFlags(npc, FL_NPC);
		
		//Don't ResolvePlayerCollisions.
		SetEntData(npc, FindSendPropInfo("CTFBaseBoss", "m_lastHealthPercentage") + 28, false, 4, true);
		
		SetEntProp(npc, Prop_Data, "m_nSolidType", 2); 
		
		
		
		//Don't bleed.
		SetEntProp(npc, Prop_Data, "m_bloodColor", -1); //Don't bleed
		
		b_BoundingBoxVariant[npc] = 0; //This will tell lag compensation what to revert to once the calculations are done.
		static float m_vecMaxs[3];
		static float m_vecMins[3];
		if(isGiant)
		{
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
		SetEntPropVector(npc, Prop_Send, "m_vecMaxs", m_vecMaxs);
		SetEntPropVector(npc, Prop_Data, "m_vecMaxs", m_vecMaxs);
		
		SetEntPropVector(npc, Prop_Send, "m_vecMins", m_vecMins);
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
		if(Ally)
		{
			CClotBody npcstats = view_as<CClotBody>(npc);
			npcstats.m_iTeamGlow = TF2_CreateGlow(npc);
			
			SetVariantColor(view_as<int>({184, 56, 59, 200}));
			AcceptEntityInput(npcstats.m_iTeamGlow, "SetGlowColor");
		}
#endif

		SetEdictFlags(npc, (GetEdictFlags(npc) & ~FL_EDICT_ALWAYS));
		
		SDKHook(npc, SDKHook_OnTakeDamage, NPC_OnTakeDamage_Base);
		SDKHook(npc, SDKHook_Think, Check_If_Stuck);
//		SDKHook(npc, SDKHook_SetTransmit, SDKHook_Settransmit_Baseboss);
		
		CClotBody CreatePathfinderIndex = view_as<CClotBody>(npc);

		if(IsRaidBoss)
		{
			RemoveAllDamageAddition();
			CreatePathfinderIndex.CreatePather(16.0, CreatePathfinderIndex.GetMaxJumpHeight(), 1000.0, CreatePathfinderIndex.GetSolidMask(), 100.0, 0.1, 1.75); //Global.
		}
		else
			CreatePathfinderIndex.CreatePather(16.0, CreatePathfinderIndex.GetMaxJumpHeight(), 1000.0, CreatePathfinderIndex.GetSolidMask(), 100.0, 0.29, 1.75); //Global.
		
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
		EmitSoundToAll(g_GibSoundMetal[sound], this.index, SNDCHAN_AUTO, 80, _, 1.0, _, _);
	}
	public void PlayStepSound(const char[] sound, float volume = 1.0, int Npc_Type = 1)
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
	//	PrintToServer("%i PlayStepSound(\"%s\")", this.index, sound);
	}
	
	property int m_iOverlordComboAttack
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iTargetAlly
	{
		public get()							{ return i_TargetAlly[this.index]; }
		public set(int TempValueForProperty) 	{ i_TargetAlly[this.index] = TempValueForProperty; }
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
		public get()							{ return fl_ExtraDamage[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ExtraDamage[this.index] = TempValueForProperty; }
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
		public get()							{ return fl_RangedArmor[this.index]; }
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
	property int m_iTarget
	{
		public get()							{ return i_Target[this.index]; }
		public set(int TempValueForProperty) 	{ i_Target[this.index] = TempValueForProperty; }
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
	property int m_iCreditsOnKill
	{
		public get()							{ return i_CreditsOnKill[this.index]; }
		public set(int TempValueForProperty) 	{ i_CreditsOnKill[this.index] = TempValueForProperty; }
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
	property bool bBuildingIsStacked
	{
		public get()							{ return b_BuildingIsStacked[this.index]; }
		public set(bool TempValueForProperty) 	{ b_BuildingIsStacked[this.index] = TempValueForProperty; }
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
		public get()							{ return b_bThisNpcGotDefaultStats_INVERTED[this.index]; }
		public set(bool TempValueForProperty) 	{ b_bThisNpcGotDefaultStats_INVERTED[this.index] = TempValueForProperty; }
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
		float speed_for_return;
		
		speed_for_return = 1.0;
		
		float Gametime = GetGameTime();
		
		bool Is_Boss = true;
		if(!this.m_bThisNpcIsABoss)
		{
			
#if defined ZR
			if(EntRefToEntIndex(RaidBossActive) != this.index)
#endif
			
			{
				Is_Boss = false;
			}
		}
		
		if(f_TankGrabbedStandStill[this.index] > GetGameTime())
		{
			speed_for_return = 0.0;
			return speed_for_return;
		}
		if(f_TimeFrozenStill[this.index] > GetGameTime(this.index))
		{
			speed_for_return = 0.0;
			return speed_for_return;
		}
		if(b_PernellBuff[this.index])
		{
			speed_for_return *= 1.15;
		}
		
		if(!Is_Boss) //Make sure that any slow debuffs dont affect these.
		{
			if(f_MaimDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.35;
			}
			if(f_PassangerDebuff[this.index] > Gametime)
			{
				speed_for_return *= 0.20;
			}
			
			if(this.m_fHighTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.65;
			}
			else if(this.m_fLowTeslarDebuff > Gametime)
			{
				speed_for_return *= 0.75;
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
		}
		else
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
		}
		if(this.mf_WidowsWineDebuff > Gametime)
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
#if defined RPG
		if (b_DungeonContracts_ZombieSpeedTimes3[this.index])
		{
			speed_for_return *= 3.0;
		}	
#endif			
		if (this.m_bFrozen)
		{
			speed_for_return = 0.01;
		}		

		return speed_for_return;
	}
	public float GetRunSpeed()//For the future incase we want to alter it easier
	{
		float speed_for_return;
		
		speed_for_return = this.m_flSpeed;
		
		speed_for_return *= this.GetDebuffPercentage();
		
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
#if defined ZR
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
#endif
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
	public float GetMaxJumpHeight() { return 250.0; }
	public float GetLeadRadius()	{ return 90000.0; }
	
	public Address GetLocomotionInterface() { return SDKCall(g_hGetLocomotionInterface, SDKCall(g_hMyNextBotPointer, this.index)); }
	
	public Address GetIntentionInterface()  { return SDKCall(g_hGetIntentionInterface,  SDKCall(g_hMyNextBotPointer, this.index)); }
	public Address GetBodyInterface()	   { return SDKCall(g_hGetBodyInterface,	   SDKCall(g_hMyNextBotPointer, this.index)); }
	
	
	public int GetTeam()  { return GetEntProp(this.index, Prop_Send, "m_iTeamNum"); }
	
	public Address GetModelPtr()
	{
		return view_as<Address>(GetEntData(this.index, FindDataMapInfo(this.index, "m_flFadeScale") + 28));
	}	
	public void SetPoseParameter(int iParameter, float value)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return;
			
		SDKCall(g_hSetPoseParameter, this.index, pStudioHdr, iParameter, value);
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
	public int LookupPoseParameter(const char[] szName)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hLookupPoseParameter, this.index, pStudioHdr, szName);
	}	
	public int LookupActivity(const char[] activity)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hLookupActivity, pStudioHdr, activity);
	}
	public int LookupSequence(const char[] sequence)
	{
		Address pStudioHdr = this.GetModelPtr();
		if(pStudioHdr == Address_Null)
			return -1;
			
		return SDKCall(g_hLookupSequence, pStudioHdr, sequence);
	}
	public void AddGesture(const char[] anim, bool cancel_animation = true)
	{
		int iSequence;
		iSequence = this.LookupActivity(anim);

		if(iSequence < 0)
			return;
			
		if(cancel_animation)
		{
			SDKCall(g_hRestartGesture, this.index, iSequence, true, true); //This is better, it just restarts the sequence instead, if its there or already playing, basically like below but better
		}
		else
		{
			SDKCall(g_hAddGesture, this.index, iSequence, true);
		}
	}
	public void AddGestureViaSequence(const char[] anim, bool cancel_animation = true)
	{
		int iSequence;
		iSequence = this.LookupSequence(anim);

		if(iSequence < 0)
			return;
			
		SDKCall(g_hAddGestureSequence, this.index, iSequence, true);
	}
	public void AddActivityViaSequence(const char[] anim)
	{
		int iSequence;
		iSequence = this.LookupSequence(anim);

		if(iSequence < 0)
			return;
		
		SDKCall(g_hRestartSequence, this.index, iSequence);
		this.SetPlaybackRate(1.0);
		this.SetCycle(0.0);
	
		this.ResetSequenceInfo();	
	}
	public void RemoveGesture(const char[] anim)
	{
		int iSequence = this.LookupActivity(anim);
		if(iSequence < 0)
			return;
			
		SDKCall(g_hRemoveGesture, this.index, iSequence);
	}
	public void SetActivity(const char[] animation, bool Is_sequence = false)
	{
		int activity;
		activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			this.StartActivity(activity);
		}
	}
	public bool IsPlayingGesture(const char[] anim)
	{
		int iSequence = this.LookupActivity(anim);
		if(iSequence < 0)
			return;
		
		SDKCall(g_hIsPlayingGesture, this.index, iSequence);
	}
	public bool IsOnGround()
	{
		return SDKCall(g_hSDKIsOnGround, this.GetLocomotionInterface());
	}
	public void SetDefaultStats()
	{
		//npc got his stats by plugins.
		this.m_bThisNpcGotDefaultStats_INVERTED = true;
	}
	/*
	public bool IsClimbingOrJumping()
	{
		if (g_hSDKIsClimbingOrJumping != null)
			return SDKCall(g_hSDKIsClimbingOrJumping, this.GetLocomotionInterface());
		return false;
	}
	*/
	public void CreatePather(float flStep, float flJump, float flDrop, int iSolid, float flAhead, float flRePath, float flHull)
	{
		PF_Create(this.index, flStep, flJump, flDrop, 0.6, iSolid, flAhead, flRePath, flHull);
		PF_EnableCallback(this.index, PFCB_Approach,			PluginBot_Approach);
		PF_EnableCallback(this.index, PFCB_IsEntityTraversable, PluginBot_IsEntityTraversable);
		PF_EnableCallback(this.index, PFCB_GetPathCost,		 PluginBot_PathCost);
	//	PF_EnableCallback(this.index, PFCB_ClimbUpToLedge, 		PluginBot_NormalJump);
	//	PF_EnableCallback(this.index, PFCB_PathSuccess,			PluginBot_PathSuccess);
		//PF_EnableCallback(this.index, PFCB_OnMoveToSuccess,	 PluginBot_MoveToSuccess);
		//PF_EnableCallback(this.index, PFCB_PathFailed,		  PluginBot_MoveToFailure);
		//PF_EnableCallback(this.index, PFCB_OnMoveToFailure,	 PluginBot_MoveToFailure);
		
		PF_EnableCallback(this.index, PFCB_OnActorEmoted, PluginBot_OnActorEmoted);
		
		this.SetDefaultStats(); // we'll use this so we can set all the default stuff we need!
	}	
	public void RemovePather(int entity)
	{
		PF_DisableCallback(entity, PFCB_Approach);
		PF_DisableCallback(entity, PFCB_IsEntityTraversable);
		PF_DisableCallback(entity, PFCB_GetPathCost);
	//	PF_DisableCallback(entity, PFCB_ClimbUpToLedge);
	//	PF_DisableCallback(entity, PFCB_OnMoveToSuccess);
	//	PF_DisableCallback(entity, PFCB_PathFailed);
	//	PF_DisableCallback(entity, PFCB_OnMoveToFailure);
		PF_DisableCallback(entity, PFCB_OnActorEmoted);
		PF_Destroy(entity);
	}	
	public void StartPathing()
	{
		if(!CvarDisableThink.BoolValue)
		{
			PF_StartPathing(this.index);
			this.m_bPathing = true;
		}
	}
	public void FaceTowards(const float vecGoal[3] , const float turnrate = 250.0)
	{
		
		//Sad!
		float flPrevValue = flTurnRate.FloatValue;
		
		flTurnRate.FloatValue = turnrate;
		SDKCall(g_hFaceTowards, this.GetLocomotionInterface(), vecGoal);
		flTurnRate.FloatValue = flPrevValue;
	}	
		
	public float GetGroundSpeed()									{ return SDKCall(g_hGetGroundSpeed, this.GetLocomotionInterface()); }
	public float GetPoseParameter(int iParameter)					{ return SDKCall(g_hGetPoseParameter, this.index, iParameter);									   }
	public int FindBodygroupByName(const char[] name)				{ return SDKCall(g_hFindBodygroupByName, this.index, name);										  }
	public int SelectWeightedSequence(int activity, int curSequence) { return SDKCall(g_hSelectWeightedSequence, this.index, this.GetModelPtr(), activity, curSequence); }
	
	public void GetAttachment(const char[] szName, float absOrigin[3], float absAngles[3]) { SDKCall(g_hGetAttachment, this.index, this.FindAttachment(szName), absOrigin, absAngles); }
	public void SetBodygroup(int iGroup, int iValue)									   { SDKCall(g_hSetBodyGroup, this.index, iGroup, iValue);									 }
	public void Approach(const float vecGoal[3])										   { SDKCall(g_hApproach, this.GetLocomotionInterface(), vecGoal, 0.1);						}
	public void Jump()																	 { SDKCall(g_hJump, this.GetLocomotionInterface());										  }
	// public void JumpAcrossGap(const float landingGoal[3], const float landingForward[3])   { SDKCall(g_hJumpAcrossGap, this.GetLocomotionInterface(), landingGoal, landingForward);	}
	public void GetVelocity(float vecOut[3])											   { SDKCall(g_hGetVelocity, this.GetLocomotionInterface(), vecOut);						   }	
	public void SetVelocity(const float vec[3])											{ SDKCall(g_hSetVelocity, this.GetLocomotionInterface(), vec);							  }	
	
	public void SetOrigin(const float vec[3])											
	{
		SetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin",vec);
	
	}	
	
	public void SetSequence(int iSequence)	{ SetEntProp(this.index, Prop_Send, "m_nSequence", iSequence); }
	public void SetPlaybackRate(float flRate) { SetEntPropFloat(this.index, Prop_Send, "m_flPlaybackRate", flRate); }
	public void SetCycle(float flCycle)	   { SetEntPropFloat(this.index, Prop_Send, "m_flCycle", flCycle); }
	
	public void GetVectors(float pForward[3], float pRight[3], float pUp[3]) { SDKCall(g_hGetVectors, this.index, pForward, pRight, pUp); }
	
	public void GetGroundMotionVector(float vecMotion[3])					{ SDKCall(g_hGetGroundMotionVector, this.GetLocomotionInterface(), vecMotion); }
	
	public void UpdateCollisionBox() { SDKCall(g_hUpdateCollisionBox,  this.index); }
	public void ResetSequenceInfo()  { SDKCall(g_hResetSequenceInfo,  this.index); }
	public void StudioFrameAdvance() { SDKCall(g_hStudioFrameAdvance, this.index); }
	public void DispatchAnimEvents() { SDKCall(g_hDispatchAnimEvents, this.index, this.index); }
	
	public int EquipItem(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0)
	{
		int item = CreateEntityByName("prop_dynamic");
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

		SetVariantString(attachment);
		AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 			
		
		SetEntityCollisionGroup(item, 1);
		/*
		if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			b_Is_Blue_Npc[item] = true; //make sure they dont collide with stuff
		}
		else if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
			b_IsAlliedNpc[item] = true; //make sure they dont collide with stuff
		}
		*/
		return item;
	}

	public int EquipItemSeperate(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0)
	{
		int item = CreateEntityByName("prop_dynamic");
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
		
	//	SetEntProp(item, Prop_Send, "m_fEffects", EF_PARENT_ANIMATES);
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);

		TeleportEntity(item, GetAbsOrigin(this.index), eyePitch, NULL_VECTOR);

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
/*
		SetVariantString(attachment);
		AcceptEntityInput(item, "SetParentAttachmentMaintainOffset"); 			
*/		
		SetEntityCollisionGroup(item, 1);
		/*
		if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			b_Is_Blue_Npc[item] = true; //make sure they dont collide with stuff
		}
		else if(GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
			b_IsAlliedNpc[item] = true; //make sure they dont collide with stuff
		}
		*/
		return item;
	}
	public bool DoSwingTrace(Handle &trace, int target, float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 }, float vecSwingMins[3] = { -64.0, -64.0, -128.0 }, float vecSwingStartOffset = 44.0, int Npc_type = 0, int Ignore_Buildings = 0)
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
		
		vecTarget = WorldSpaceCenter(target);
		MakeVectorFromPoints(WorldSpaceCenter(this.index), vecTarget, vecForward);
		GetVectorAngles(vecForward, vecForward);
		vecForward[1] = eyePitch[1];
		GetAngleVectors(vecForward, vecForward, vecRight, vecTarget);
		
		float vecSwingStart[3]; vecSwingStart = GetAbsOrigin(this.index);
		
		vecSwingStart[2] += vecSwingStartOffset;
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = vecSwingStart[0] + vecForward[0] * vecSwingMaxs[0];
		vecSwingEnd[1] = vecSwingStart[1] + vecForward[1] * vecSwingMaxs[1];
		vecSwingEnd[2] = vecSwingStart[2] + vecForward[2] * vecSwingMaxs[2];
		
	//	TE_SetupBeamPoints(vecSwingStart, vecSwingEnd, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	//	TE_SendToAll();
		
#if defined ZR
		bool ingore_buildings = false;
		if(Ignore_Buildings || IsValidEntity(EntRefToEntIndex(RaidBossActive)))
		{
			ingore_buildings = true;
		}
#else
		bool ingore_buildings = view_as<bool>(Ignore_Buildings);
#endif
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
		/*
		if ( TR_GetFraction(trace) >= 1.0 || TR_GetEntityIndex(trace) == 0)
		{
			delete trace;
			trace = TR_TraceHullFilterEx( vecSwingStart, vecSwingEnd, vecSwingMins, vecSwingMaxs, ( MASK_SOLID | CONTENTS_SOLID ), ingore_buildings ? BulletAndMeleeTracePlayerAndBaseBossOnly : BulletAndMeleeTrace, this.index );
			if ( TR_GetFraction(trace) < 1.0)
			{
				// This is the point on the actual surface (the hull could have hit space)
				TR_GetEndPosition(vecSwingEnd, trace);	
			}
		}
		*/
		return (TR_GetFraction(trace) < 1.0);
	}
	public bool DoAimbotTrace(Handle &trace, int target, float vecSwingMaxs[3] = { 64.0, 64.0, 128.0 }, float vecSwingMins[3] = { -64.0, -64.0, -128.0 }, float vecSwingStartOffset = 44.0)
	{
		float vecSwingStart[3]; vecSwingStart = GetAbsOrigin(this.index);
		
		vecSwingStart[2] += vecSwingStartOffset;
		
		float vecSwingEnd[3]; vecSwingEnd = GetAbsOrigin(target);
		
		// See if we hit anything.
		trace = TR_TraceRayFilterEx( vecSwingStart, vecSwingEnd, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, this.index );
		/*
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
		*/
		return (TR_GetFraction(trace) < 1.0);
	}
	public void GetPositionInfront(float DistanceOffsetInfront, float vecSwingEnd[3], float ang[3])
	{	
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);
		
		float vecSwingStart[3];
		float vecSwingForward[3];

		vecSwingStart = GetAbsOrigin(this.index);
		
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
			
			b_ThisEntityIgnored[entity] = true;
			b_ForceCollisionWithProjectile[entity] = true;

			SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 1600.0);
			SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 1800.0);

			if(parent)
			{
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", this.index);
			}
		}
		CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		return entity;
	}
	public void FireRocket(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0, int flags = 0) //No defaults, otherwise i cant even judge.
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			i_ExplosiveProjectileHexArray[entity] = flags;
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(this.index, Prop_Send, "m_iTeamNum"));
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
			SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			SetEntityCollisionGroup(entity, 19); //our savior
			See_Projectile_Team(entity);
		}
	}
	public void FireGrenade(float vecTarget[3], float grenadespeed = 800.0, float damage, char[] model)
	{
		int entity = CreateEntityByName("tf_projectile_pipe");
		if(IsValidEntity(entity))
		{
			float vecForward[3], vecSwingStart[3], vecAngles[3];
			this.GetVectors(vecForward, vecSwingStart, vecAngles);
	
			vecSwingStart = GetAbsOrigin(this.index);
			vecSwingStart[2] += 90.0;
	
			MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
	
			vecSwingStart[0] += vecForward[0] * 64;
			vecSwingStart[1] += vecForward[1] * 64;
			vecSwingStart[2] += vecForward[2] * 64;
	
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*grenadespeed;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*grenadespeed;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-grenadespeed;
			
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntPropEnt(entity, Prop_Send, "m_hThrower", this.index);
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			f_CustomGrenadeDamage[entity] = damage;	
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
			DispatchSpawn(entity);
			SetEntityModel(entity, model);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
			
			SetEntProp(entity, Prop_Send, "m_bTouched", true);
			SetEntityCollisionGroup(entity, 1);
		}
	}
	public void FireArrow(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "", float model_scale = 1.0) //No defaults, otherwise i cant even judge.
	{
		//ITS NOT actually an arrow, because of an ANNOOOOOOOOOOOYING sound.
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(entity))
		{
			b_EntityIsArrow[entity] = true;
			f_ArrowDamage[entity] = rocket_damage;
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", GetEntProp(this.index, Prop_Send, "m_iTeamNum"));
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
					int trail = Trail_Attach(entity, ARROW_TRAIL, 255, 0.3, 3.0, 3.0, 5);
					
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
			SetEntityCollisionGroup(entity, 19); //our savior
			See_Projectile_Team(entity);
			g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Arrow_DHook_RocketExplodePre); //im lazy so ill reuse stuff that already works *yawn*
			SDKHook(entity, SDKHook_ShouldCollide, Never_ShouldCollide);
			SDKHook(entity, SDKHook_StartTouch, ArrowStartTouch);
		}
	}
	/*
	public void FireBolt(float vecTarget[3], float rocket_damage, float rocket_speed, const char[] rocket_model = "" , float model_scale = 1.0) //No defaults, otherwise i cant even judge.
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		this.GetVectors(vecForward, vecSwingStart, vecAngles);

		vecSwingStart = GetAbsOrigin(this.index);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);

	//	vecSwingStart[0] += vecForward[0] * 64;
	//	vecSwingStart[1] += vecForward[1] * 64;
	//	vecSwingStart[2] += vecForward[2] * 64;
	// 	this isnt needed anymore 


		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*rocket_speed;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-rocket_speed;

		int entity = CreateEntityByName("tf_projectile_energy_ball");
		if(IsValidEntity(entity))
		{
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.index);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, rocket_damage, true);	// Damage
			SetEntProp(entity, Prop_Send, "m_iTeamNum", TFTeam_Blue);
			TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR);
			DispatchSpawn(entity);
			if(rocket_model[0])
			{
				SetEntityModel(entity, rocket_model);
			}
			if(model_scale != 1.0)
			{
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", model_scale); // ZZZZ i sleep
			}
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward);
			SetEntityCollisionGroup(entity, 19); //our savior
		}
	}
	*/
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
	/*
	
		property int m_iActivity
	{
		public get()              { return this.ExtractStringValueAsInt("m_iActivity"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iActivity", buff, true); }
	}
	
	property int m_iPoseMoveX 
	{
		public get()              { return this.ExtractStringValueAsInt("m_iPoseMoveX"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iPoseMoveX", buff, true); }
	}
	
	property int m_iPoseMoveY
	{
		public get()              { return this.ExtractStringValueAsInt("m_iPoseMoveY"); }
		public set(int iActivity) { char buff[8]; IntToString(iActivity, buff, sizeof(buff)); SetCustomKeyValue(this.index, "m_iPoseMoveY", buff, true); }
	}
	*/

	//Begin an animation activity, return false if we cant do that right now.
	public bool StartActivity(int iActivity, int flags = 0, bool Reset_Sequence_Info = true)
	{
		int nSequence = this.SelectWeightedSequence(iActivity, GetEntProp(this.index, Prop_Send, "m_nSequence"));
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
		if(this.m_bisWalking) //This exists to make sure that if there is any idle animation played, it wont alter the playback rate and keep it at a flat 1, or anything altered that the user desires.
		{
			float m_flGroundSpeed = GetEntPropFloat(this.index, Prop_Data, "m_flGroundSpeed");
			if (m_flGroundSpeed != 0.0) {
				float PlaybackSpeed = clamp((flNextBotGroundSpeed / m_flGroundSpeed), -4.0, 12.0);
				PlaybackSpeed *= this.m_bisGiantWalkCycle;
				if(PlaybackSpeed > 2.0)
					PlaybackSpeed = 2.0;
				this.SetPlaybackRate(PlaybackSpeed);
			}
		}
		
		this.StudioFrameAdvance();
		this.DispatchAnimEvents();
		
		//Run and StuckMonitor
		if(this.m_flNextRunTime < GetGameTime())
		{
			this.m_flNextRunTime = GetGameTime() + 0.1; //Only update every 0.1 seconds, we really dont need more, 
			SDKCall(g_hRun,          this.GetLocomotionInterface());	
		}
		
		/*
		
		SDKCall(g_hStuckMonitor, this.GetLocomotionInterface());
		
		bool bStuck = this.IsStuck();
		if(bStuck)
		{
			float there[3];
			bool bYes = false;
			
			for (int i = 1; i <= 2; i++)
			{
				if (PF_GetFutureSegment(this.index, i, there)) 
				{
					bYes = true; 
					break;
				}
			}
			
			if(bYes) 
			{
				NavArea RandomArea = PickRandomArea();	
			
				if(RandomArea == NavArea_Null) 
				{
				
				}
				else
				{
					
					float vecGoal[3]; RandomArea.GetCenter(vecGoal);
					
					if(!PF_IsPathToVectorPossible(this.index, vecGoal))
					{
					
					}
					else
					{
						PF_SetGoalVector(this.index, vecGoal);
						SDKCall(g_hClearStuckStatus, this.GetLocomotionInterface(), "Un-Stuck");//  Sauce code :)
					}
				}
				
			} 
			
			
			else 
			{
				NavArea area = TheNavMesh.GetNearestNavArea_Vec(WorldSpaceCenter(this.index), true);
				if(area == NavArea_Null)
					return;
			
				float center[3]; area.GetCenter(center); center[2] += 18.0;
		//		PrintToChatAll("stuck2");
				TeleportEntity(this.index, center, NULL_VECTOR, NULL_VECTOR);
			}
		}
		
		*/
		
		
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

	//return the bot's collision mask
	public int GetSolidMask()
	{
		//0x202400B L4D2
		return (MASK_NPCSOLID);
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
	public void SetDefaultStatsZombieRiot(int Team)
	{
		CClotBody npc = view_as<CClotBody>(this.index);
		npc.m_bThisNpcGotDefaultStats_INVERTED = true;
		if(Team == view_as<int>(TFTeam_Red)) //ANY NPC THATS AN ALLY AND THAT HAS NO DEFAULT STATS WILL GET THIS.
		{
			npc.m_bThisEntityIgnored = false;
			npc.m_bThisNpcIsABoss = false;
			npc.bCantCollidie = false;
		}
	}
}

enum ActivityType 
{ 
	MOTION_CONTROLLED_XY	= 0x0001,	// XY position and orientation of the bot is driven by the animation.
	MOTION_CONTROLLED_Z		= 0x0002,	// Z position of the bot is driven by the animation.
	ACTIVITY_UNINTERRUPTIBLE= 0x0004,	// activity can't be changed until animation finishes
	ACTIVITY_TRANSITORY		= 0x0008,	// a short animation that takes over from the underlying animation momentarily, resuming it upon completion
	ENTINDEX_PLAYBACK_RATE	= 0x0010,	// played back at different rates based on entindex
};


//Trash below!


public void NPC_Base_InitGamedata()
{
	flTurnRate = FindConVar("tf_base_boss_max_turn_rate");
	RegAdminCmd("sm_spawn_npc", Command_PetMenu, ADMFLAG_ROOT);
	
	
	GameData gamedata = LoadGameConfigFile("tf2.pets");
	
	// thanks to Dysphie#4094 on discord for help
	DHook_CreateDetour(gamedata, "NextBotGroundLocomotion::UpdateGroundConstraint", Dhook_UpdateGroundConstraint_Pre, Dhook_UpdateGroundConstraint_Post);

//	DHook_CreateDetour(gamedata, "NextBotGroundLocomotion::ResolveCollision", Dhook_ResolveCollision_Pre, Dhook_ResolveCollision_Post);
	
	delete gamedata;
	
	Handle hConf = LoadGameConfigFile("tf2.pets");
	
	//SDKCalls
	//This call is used to get an entitys center position
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::WorldSpaceCenter");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if ((g_hSDKWorldSpaceCenter = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::WorldSpaceCenter offset!");
	
	//=========================================================
	// StudioFrameAdvance - advance the animation frame up some interval (default 0.1) into the future
	//=========================================================
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::StudioFrameAdvance");
	if ((g_hStudioFrameAdvance = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::StudioFrameAdvance offset!"); 	


//	CBaseAnimatingOverlay::StudioFrameAdvance()
	
	//CBaseAnimating::ResetSequenceInfo( );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::ResetSequenceInfo");
	if ((g_hResetSequenceInfo = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::ResetSequenceInfo signature!"); 
	
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::MyNextBotPointer");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hMyNextBotPointer = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseEntity::MyNextBotPointer offset!"); 
	
	/*
	void CBaseAnimating::RefreshCollisionBounds( void )
	{
		CollisionProp()->RefreshScaledCollisionBounds();
	}
	*/
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::RefreshCollisionBounds");
	if ((g_hUpdateCollisionBox = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::RefreshCollisionBounds offset!"); 
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetLocomotionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetLocomotionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetLocomotionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetIntentionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetIntentionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetIntentionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetBodyInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetBodyInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetBodyInterface!");
/*		
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBot::GetVisionInterface");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetVisionInterface = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBot::GetVisionInterface!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::GetPrimaryKnownThreat");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetPrimaryKnownThreat = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::GetPrimaryKnownThreat!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::GetKnown");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);	//CBaseEntity - Entity to check for
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//CKnownEntity
	if((g_hGetKnown = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::GetKnown!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "IVision::AddKnownEntity");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hAddKnownEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for IVision::AddKnownEntity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::GetEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hGetKnownEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::GetEntity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::UpdatePosition");
	if((g_hUpdatePosition = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::UpdatePosition!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CKnownEntity::UpdateVisibilityStatus");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	//bool visible now
	if((g_hUpdateVisibilityStatus = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CKnownEntity::UpdateVisibilityStatus!");
*/
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Run");
	if((g_hRun = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Run!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Approach");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	if((g_hApproach = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Approach!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::FaceTowards");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hFaceTowards = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::FaceTowards!");

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::Jump");
	if((g_hJump = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::Jump!");
/*	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::JumpAcrossGap");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hJumpAcrossGap = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::JumpAcrossGap!");
	*/
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetVelocity");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if((g_hGetVelocity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetVelocity!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::SetVelocity");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	if((g_hSetVelocity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::SetVelocity!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseAnimating::DispatchAnimEvents");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	if ((g_hDispatchAnimEvents = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::DispatchAnimEvents offset!"); 
	
	//ILocomotion::GetGroundSpeed() 
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetGroundSpeed");
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hGetGroundSpeed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetGroundSpeed!");
	
	//ILocomotion::GetGroundMotionVector() 
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::GetGroundMotionVector");
	PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByRef);
	if((g_hGetGroundMotionVector = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for ILocomotion::GetGroundMotionVector!");
	
	//CBaseEntity::GetVectors(Vector*, Vector*, Vector*) 
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if((g_hGetVectors = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseEntity::GetVectors!");

	//CBaseAnimating::GetPoseParameter(int iParameter)
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hGetPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::GetPoseParameter");
	
	//CBaseAnimating::FindBodygroupByName(const char* name)
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::FindBodygroupByName");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hFindBodygroupByName = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::FindBodygroupByName");
	
	//CBaseAnimating::SetBodygroup( int iGroup, int iValue )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::SetBodygroup");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hSetBodyGroup = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::SetBodygroup");
	
	//int SelectWeightedSequence( CStudioHdr *pstudiohdr, int activity, int curSequence );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "SelectWeightedSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pstudiohdr
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//activity
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//curSequence
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return sequence
	if((g_hSelectWeightedSequence = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for SelectWeightedSequence");
	
	//SetPoseParameter( CStudioHdr *pStudioHdr, int iParameter, float flValue );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::SetPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Float, SDKPass_Plain);
	if((g_hSetPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::SetPoseParameter");
	
	//LookupPoseParameter( CStudioHdr *pStudioHdr, const char *szName );
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::LookupPoseParameter");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hLookupPoseParameter = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::LookupPoseParameter");
	
	//CBaseAnimatingOverlay::AddGesture( Activity activity, bool autokill )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::AddGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain); 
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hAddGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::AddGesture");

	//CBaseAnimatingOverlay::AddGesture( Activity activity, bool autokill )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::AddGestureSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain); 
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hAddGestureSequence = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::AddGestureSequence");

	//CBaseAnimatingOverlay::RemoveGesture( Activity activity )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::RemoveGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if((g_hRemoveGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::RemoveGesture");


	//CBaseAnimatingOverlay::ResetSequence( int sequence? )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::ResetSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hRestartSequence = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::ResetSequence");
		
	//( Activity activity, bool addifmissing /*=true*/, bool autokill /*=true*/ )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::RestartGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);	
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hRestartGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::RestartGesture");
	
	
	//CBaseAnimatingOverlay::IsPlayingGesture( Activity activity )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimatingOverlay::IsPlayingGesture");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if((g_hIsPlayingGesture = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimatingOverlay::IsPlayingGesture");
	/*
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::IsClimbingOrJumping");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
	g_hSDKIsClimbingOrJumping = EndPrepSDKCall();
	if (g_hSDKIsClimbingOrJumping == null)
	{
		PrintToServer("Failed to retrieve ILocomotion::IsClimbingOrJumping offset from SF2 gamedata!");
	}
	*/
	//-----------------------------------------------------------------------------
	
	//-----------------------------------------------------------------------------
	// Purpose: Looks up an activity by name.
	// Input  : label - Name of the activity to look up, ie "ACT_IDLE"
	// Output : Activity index or ACT_INVALID if not found.
	//-----------------------------------------------------------------------------
	//int LookupActivity( CStudioHdr *pstudiohdr, const char *label )
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "LookupActivity");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//label
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hLookupActivity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for LookupActivity");


	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "LookupSequence");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//label
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hLookupSequence = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for LookupSequence");
	
	
	//-----------------------------------------------------------------------------
	// Purpose: lookup attachment by name
	//-----------------------------------------------------------------------------
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "Studio_FindAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//pAttachmentName
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hStudio_FindAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for Studio_FindAttachment");
	
	//-----------------------------------------------------------------------------
	// Purpose: Returns the world location and world angles of an attachment
	// Input  : attachment name
	// Output :	location and angles
	//-----------------------------------------------------------------------------
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//iAttachment
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absOrigin
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absAngles
	if((g_hGetAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::GetAttachment");
	
	//PluginBot SDKCalls
	//Get NextBot pointer
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBotComponent::GetBot");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if((g_hGetBot = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBotComponent::GetBot!");
	
	//Get NextBot entity index
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "INextBotComponent::GetEntity");
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	if((g_hGetEntity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for INextBotComponent::GetEntity!");
	
	//
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "NextBotCombatCharacter::Event_Killed");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
	if((g_hNextBotCombatCharacter_Event_Killed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for NextBotCombatCharacter::Event_Killed!");

	//Get NextBot entity index
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseCombatCharacter::Event_Killed");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Pointer);
	if((g_hCBaseCombatCharacter_Event_Killed = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseCombatCharacter::Event_Killed!");
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "ILocomotion::IsOnGround");
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_ByValue);
	g_hSDKIsOnGround = EndPrepSDKCall();
	if (g_hSDKIsOnGround == null)
	{
		PrintToServer("Failed to retrieve ILocomotion::IsOnGround offset from SF2 gamedata!");
	}
	
	//DHooks
	g_hHandleAnimEvent = DHookCreateEx(hConf, "CBaseAnimating::HandleAnimEvent",  HookType_Entity, ReturnType_Void,   ThisPointer_CBaseEntity, CBaseAnimating_HandleAnimEvent);
	DHookAddParam(g_hHandleAnimEvent, HookParamType_ObjectPtr);
	
	g_hGetFrictionSideways = DHookCreateEx(hConf, "ILocomotion::GetFrictionSideways",HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetFrictionSideways);
	g_hGetStepHeight	   = DHookCreateEx(hConf, "ILocomotion::GetStepHeight",	  HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetStepHeight);	
	g_hGetGravity		  = DHookCreateEx(hConf, "ILocomotion::GetGravity",		 HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetGravity);	
	g_hGetRunSpeed		 = DHookCreateEx(hConf, "ILocomotion::GetRunSpeed",		HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetRunSpeed);
	g_hGetGroundNormal	 = DHookCreateEx(hConf, "ILocomotion::GetGroundNormal",	HookType_Raw, ReturnType_VectorPtr, ThisPointer_Address, ILocomotion_GetGroundNormal);
	g_hGetMaxAcceleration  = DHookCreateEx(hConf, "ILocomotion::GetMaxAcceleration", HookType_Raw, ReturnType_Float,	 ThisPointer_Address, ILocomotion_GetMaxAcceleration);
	
	g_hShouldCollideWithAlly = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithAlly);
	DHookAddParam(g_hShouldCollideWithAlly, HookParamType_CBaseEntity);
	
	g_hShouldCollideWithAllyInvince = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithAllyInvince);
	DHookAddParam(g_hShouldCollideWithAllyInvince, HookParamType_CBaseEntity);
	
	g_hShouldCollideWithAllyEnemy = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithEnemy);
	DHookAddParam(g_hShouldCollideWithAllyEnemy, HookParamType_CBaseEntity);

	g_hShouldCollideWithAllyEnemyIngoreBuilding = DHookCreateEx(hConf, "ILocomotion::ShouldCollideWith",  HookType_Raw, ReturnType_Bool, ThisPointer_Address, ILocomotion_ShouldCollideWithEnemyIngoreBuilding);
	DHookAddParam(g_hShouldCollideWithAllyEnemyIngoreBuilding, HookParamType_CBaseEntity);
	
	g_hGetSolidMask		= DHookCreateEx(hConf, "IBody::GetSolidMask",	   HookType_Raw, ReturnType_Int,   ThisPointer_Address, IBody_GetSolidMask);
	g_hGetActivity		 = DHookCreateEx(hConf, "IBody::GetActivity",		HookType_Raw, ReturnType_Int,   ThisPointer_Address, IBody_GetActivity);
	
	g_hGetHullWidthGiant		= DHookCreateEx(hConf, "IBody::GetHullWidth",	   HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullWidth_ISGIANT);
	g_hGetHullHeightGiant	   = DHookCreateEx(hConf, "IBody::GetHullHeight",	  HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullHeight_ISGIANT);
	g_hGetStandHullHeightGiant  = DHookCreateEx(hConf, "IBody::GetStandHullHeight", HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetStandHullHeight_ISGIANT);
	
	
	
	g_hGetHullWidth		= DHookCreateEx(hConf, "IBody::GetHullWidth",	   HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullWidth);
	g_hGetHullHeight	   = DHookCreateEx(hConf, "IBody::GetHullHeight",	  HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetHullHeight);
	g_hGetStandHullHeight  = DHookCreateEx(hConf, "IBody::GetStandHullHeight", HookType_Raw, ReturnType_Float, ThisPointer_Address, IBody_GetStandHullHeight);
	
	g_hIsActivity   = DHookCreateEx(hConf, "IBody::IsActivity",   HookType_Raw, ReturnType_Bool, ThisPointer_Address, IBody_IsActivity);
	DHookAddParam(g_hIsActivity, HookParamType_Int);
	
	g_hStartActivity = DHookCreateEx(hConf, "IBody::StartActivity", HookType_Raw, ReturnType_Bool, ThisPointer_Address, IBody_StartActivity);
	DHookAddParam(g_hStartActivity, HookParamType_Int);
	DHookAddParam(g_hStartActivity, HookParamType_Int);

	g_hEvent_Killed = DHookCreateEx(hConf, "CTFBaseBoss::Event_Killed", HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, CTFBaseBoss_Event_Killed);
	DHookAddParam(g_hEvent_Killed, HookParamType_Int); //( const CTakeDamageInfo &info )
	
//	g_hAlwaysTransmit = DynamicHook.FromConf(hConf, "CTFBaseBoss::UpdateTransmitState()");
	
	g_hEvent_Ragdoll = DHookCreateEx(hConf, "CBaseCombatCharacter::BecomeRagdoll", HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, CTFBaseBoss_Ragdoll);
	
	DHookAddParam(g_hEvent_Ragdoll, HookParamType_Int); //( const CTakeDamageInfo &info )
	DHookAddParam(g_hEvent_Ragdoll, HookParamType_VectorPtr); //( const vector )

	Address iAddr = GameConfGetAddress(hConf, "GetAnimationEvent");
	if(iAddr == Address_Null) SetFailState("Can't find GetAnimationEvent address for patch.");
	
	StoreToAddress(iAddr += view_as<Address>(131), 9999, NumberType_Int16);
	
	delete hConf;
	
	HookIdMap = new StringMap();
	HookListMap = new StringMap();
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

//Ragdoll.
public MRESReturn CTFBaseBoss_Event_Killed(int pThis, Handle hParams)
{	
//	CreateTimer(5.0, Check_Emergency_Reload, EntIndexToEntRef(pThis), TIMER_FLAG_NO_MAPCHANGE);
	
	Address CTakeDamageInfo = DHookGetParam(hParams, 1);
	
	CTakeDamageInfo -= view_as<Address>(16*4);
	if(!b_NpcHasDied[pThis])
	{

		int client = GetClientOfUserId(LastHitId[pThis]);
		int Health = GetEntProp(pThis, Prop_Data, "m_iHealth");
		Health *= -1;
		
		int overkill = RoundToNearest(Damage[pThis] - float(Health));
		
		if(client && IsClientInGame(client))
		{
			
#if defined ZR
			if(i_HasBeenHeadShotted[pThis])
				i_Headshots[client] += 1; //Award 1 headshot point, only once.

			if(i_HasBeenBackstabbed[pThis])
				i_Backstabs[client] += 1; //Give a backstab count!

			i_KillsMade[client] += 1;
#endif

			Calculate_And_Display_hp(client, pThis, Damage[pThis], true, overkill);
		}
		
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
		SDKUnhook(pThis, SDKHook_OnTakeDamage, NPC_OnTakeDamage_Base);
		SDKUnhook(pThis, SDKHook_Think, Check_If_Stuck);
#if defined ZR
		if(IsValidEntity(npc.m_iTeamGlow))
			RemoveEntity(npc.m_iTeamGlow);
#endif
		if(IsValidEntity(npc.m_iSpawnProtectionEntity))
			RemoveEntity(npc.m_iSpawnProtectionEntity);

		if(IsValidEntity(npc.m_iTextEntity1))
			RemoveEntity(npc.m_iTextEntity1);
		if(IsValidEntity(npc.m_iTextEntity2))
			RemoveEntity(npc.m_iTextEntity2);
		if(IsValidEntity(npc.m_iTextEntity3))
			RemoveEntity(npc.m_iTextEntity3);
		
#if defined ZR
		if (EntRefToEntIndex(RaidBossActive) == pThis)
		{
			Raidboss_Clean_Everyone();
		}
#endif
		b_NpcHasDied[pThis] = true;
#if defined ZR
		CleanAllAppliedEffects_BombImplanter(pThis, true);
#endif		
	
		NPC_DeadEffects(pThis); //Do kill attribute stuff
		RemoveNpcThingsAgain(pThis);
		NPCDeath(pThis);
		//We do not want this entity to collide with anything when it dies. 
		//yes it is a single frame, but it can matter in ugly ways, just avoid this.
		SetEntityCollisionGroup(pThis, 1);
		b_ThisEntityIgnored[pThis] = true;
		b_ThisEntityIgnoredEntirelyFromAllCollisions[pThis] = true;
		
		/*
		#if defined ISSPECIALDEATHANIMATION
			RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));
			return MRES_Supercede;
		#else
		*/
		if(!npc.m_bDissapearOnDeath)
		{
			if(!npc.m_bGib)
			{
				SDKCall(g_hNextBotCombatCharacter_Event_Killed, pThis, CTakeDamageInfo);
				SDKCall(g_hCBaseCombatCharacter_Event_Killed,   pThis, CTakeDamageInfo);
			}
			else
			{
				SDKCall(g_hNextBotCombatCharacter_Event_Killed, pThis, CTakeDamageInfo);
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
				
				
				if(npc.m_iBleedType == 1)
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
				else if(npc.m_iBleedType == 2)
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
				else if(npc.m_iBleedType == 4)
				{
					npc.PlayGibSound();
					if(npc.m_bIsGiant)
					{
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
						startPosition[2] += 64;
						Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true, true, _, _, _, true);
						if(!Limit_Gibs)
						{
							startPosition[2] -= 15;
							Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce, false, true, _, _, _, true);
							startPosition[2] += 44;
							if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
							{
								npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
								Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, false, true, _, _, _, true);	
							}
							else
							{
								Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, false, true, _, _, _, true);		
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
						Main_Gib = Place_Gib("models/gibs/antlion_gib_large_1.mdl", startPosition, _, damageForce, true, _, _, _, _, true);
						if(!Limit_Gibs)
						{
							startPosition[2] -= 10;
							Place_Gib("models/Gibs/HGIBS_spine.mdl", startPosition, _, damageForce, _, _, _, _, _, true);
							startPosition[2] += 34;
							if(c_HeadPlaceAttachmentGibName[npc.index][0] != 0)
							{
								npc.GetAttachment(c_HeadPlaceAttachmentGibName[npc.index], accurateposition, accurateAngle);
								Place_Gib("models/Gibs/HGIBS.mdl", accurateposition, accurateAngle, damageForce, _, _, _, _, _, true);
							}
							else
							{
								Place_Gib("models/Gibs/HGIBS.mdl", startPosition, _, damageForce, _, _, _, _, _, true);
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
				else if(npc.m_iBleedType == 5)
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
			//	#endif					
			//	Do_Death_Frame_Later(EntIndexToEntRef(pThis));
				RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));						
			}
		}
		else
		{	
		//	Do_Death_Frame_Later(EntIndexToEntRef(pThis));
			RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));		
		}
	}
	else
	{	
	//	Do_Death_Frame_Later(EntIndexToEntRef(pThis));
		RequestFrame(Do_Death_Frame_Later, EntIndexToEntRef(pThis));	
	}
	return MRES_Supercede;
}

public void Do_Death_Frame_Later(int ref)
{
	int pThis = EntRefToEntIndex(ref);
	if(IsValidEntity(pThis) && pThis > 0)
	{
		RemoveEntity(pThis);
	}
}
/*
public Action Check_Emergency_Reload(Handle Timer_Handle, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		//SOMETHING TERRIBLE HAPPEND!!! PLUGIN MUST RELOAD ITSELF AND KILL ALL EXISTING BASE_BOSSES THAT ARE FROM THIS PLUGIN INSTANTLY!!!
		//This can happen due to the plugin failing to correctly hook upton server restart, rendering winning/advancing IMPOSSIBLE.
		char buffer[64];
		for(int i=MAXENTITIES; i>MaxClients; i--)
		{
			if(IsValidEntity(i) && GetEntityClassname(i, buffer, sizeof(buffer)))
			{
				if(StrEqual(buffer, "base_boss"))
				{
					GetEntPropString(i, Prop_Data, "m_iName", buffer, sizeof(buffer))
					if(!StrContains(this_plugin_name, buffer))
					{
						RemoveEntity(i);
					}
				}
			}
		}
		static char plugin_name[256];
		GetPluginFilename(INVALID_HANDLE, plugin_name, sizeof(plugin_name));
		ServerCommand("sm plugins reload %s", plugin_name);
	}
	return Plugin_Handled;
}
*/

/*
//	models/Gibs/HGIBS.mdl
//	models/Gibs/HGIBS_scapula.mdl
//	models/Gibs/HGIBS_spine.mdl
//	models/Gibs/HGIBS_rib.mdl
//	models/gibs/antlion_gib_large_1.mdl //COLOR RED!
*/

public MRESReturn CTFBaseBoss_Ragdoll(int pThis, Handle hReturn, Handle hParams)  
{
	CClotBody npc = view_as<CClotBody>(pThis);
	float Push[3];
	npc.m_vecpunchforce(Push, false);
	ScaleVector(Push, 2.0);
	if(Push[0] == 0.0 || Push[0] > 10000000.0 || Push[1] > 10000000.0 || Push[2] > 10000000.0 || Push[0] < -10000000.0 || Push[1] < -10000000.0 || Push[2] < -10000000.0) //knockback is way too huge. set to 0.
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
		if (event == 7001 || event == 59 || event == 58 || event == 66 || event == 65 || event == 6004 || event == 6005 || event == 7005 || event == 7004 || event || 7001)
			return true;
	}
		
	return false;
	
}

public MRESReturn CBaseAnimating_HandleAnimEvent(int pThis, Handle hParams)
{
	int event = DHookGetParamObjectPtrVar(hParams, 1, 0, ObjectValueType_Int);
//	PrintToChatAll("CBaseAnimating_HandleAnimEvent(%i, %i)", pThis, event);
	CClotBody npc = view_as<CClotBody>(pThis);
	
#if defined ZR
	switch(i_NpcInternalId[pThis])
	{
		case MEDIVAL_ARCHER:
		{
			HandleAnimEventMedival_Archer(pThis, event);
		}
		case MEDIVAL_SKIRMISHER:
		{
			HandleAnimEvent_MedivalSkirmisher(pThis, event);
		}	
		case MEDIVAL_CROSSBOW_MAN:
		{
			HandleAnimEventMedival_CrossbowMan(pThis, event);
		}
		case MEDIVAL_HANDCANNONEER:
		{
			HandleAnimEventMedival_HandCannoneer(pThis, event);
		}
		case MEDIVAL_ELITE_SKIRMISHER:
		{
			HandleAnimEvent_MedivalEliteSkirmisher(pThis, event);
		}
	}
#endif
	
	switch(npc.m_iNpcStepVariation)
	{
		case STEPTYPE_NORMAL:
		{
			if(IsWalkEvent(event))
			{
				static char strSound[64];
				static float vSoundPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vSoundPos);
				vSoundPos[2] += 1.0;
				
				TR_TraceRayFilter(vSoundPos, view_as<float>( { 90.0, 0.0, 0.0 } ), npc.GetSolidMask(), RayType_Infinite, BulletAndMeleeTrace, npc.index);
				static char material[PLATFORM_MAX_PATH]; TR_GetSurfaceName(null, material, PLATFORM_MAX_PATH);
				
				Format(strSound, sizeof(strSound), "player/footsteps/%s%i.wav", GetStepSoundForMaterial(material), GetRandomInt(1,4));
				
				npc.PlayStepSound(strSound,0.8, npc.m_iStepNoiseType);
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
					npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, npc.m_iStepNoiseType);
					npc.PlayStepSound(g_TankStepSound[GetRandomInt(0, sizeof(g_TankStepSound) - 1)], 1.0, npc.m_iStepNoiseType);
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
	}
	return MRES_Ignored;
}

public MRESReturn ILocomotion_GetGroundNormal(Address pThis, Handle hReturn, Handle hParams)	 { DHookSetReturnVector(hReturn,	view_as<float>( { 0.0, 0.0, 1.0 } ));  return MRES_Supercede; }
public MRESReturn ILocomotion_GetStepHeight(Address pThis, Handle hReturn, Handle hParams)	   { DHookSetReturn(hReturn, 17.0);	return MRES_Supercede; }
public MRESReturn ILocomotion_GetMaxAcceleration(Address pThis, Handle hReturn, Handle hParams)  { DHookSetReturn(hReturn, 5000.0); return MRES_Supercede; }
public MRESReturn ILocomotion_GetFrictionSideways(Address pThis, Handle hReturn, Handle hParams) { DHookSetReturn(hReturn, 3.0);	return MRES_Supercede; }
public MRESReturn ILocomotion_GetGravity(Address pThis, Handle hReturn, Handle hParams)
{
#if defined ZR
	int entity = view_as<int>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis)));
	if(Npc_Is_Targeted_In_Air(entity))
	{
		DHookSetReturn(hReturn, 0.0); //We want no gravity
	}
	else
#endif
	{
		DHookSetReturn(hReturn, 800.0); 
	}
	return MRES_Supercede; 
}

public MRESReturn ILocomotion_ShouldCollideWithAlly(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede; 
	}	
	 //OPTIMISEEEEEEEEE!!!!!!!!
	 
	if(b_CantCollidieAlly[otherindex]) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}

	//https://github.com/lua9520/source-engine-2018-hl2_src/blob/3bf9df6b2785fa6d951086978a3e66f49427166a/game/server/NextBot/NextBotLocomotionInterface.h#L152
	//ALWAYS YES, WHY??????
	
//	DHookSetReturn(hReturn, true); 
	return MRES_Ignored;
}
public MRESReturn ILocomotion_ShouldCollideWithAllyInvince(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede; 
	}	
	 //OPTIMISEEEEEEEEE!!!!!!!!
	 
	if(b_CantCollidie[otherindex]) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(b_CantCollidieAlly[otherindex]) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	
//	DHookSetReturn(hReturn, true); 
	return MRES_Ignored;
}

public MRESReturn ILocomotion_ShouldCollideWithEnemy(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(b_ThisEntityIgnored[otherindex])
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
	//	DHookSetReturn(hReturn, true); 
		return MRES_Ignored;
	}
	 
	if(b_CantCollidie[otherindex]) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}

	
//	DHookSetReturn(hReturn, true); 
	return MRES_Ignored;
}

public MRESReturn ILocomotion_ShouldCollideWithEnemyIngoreBuilding(Address pThis, Handle hReturn, Handle hParams)   
{ 
	int otherindex = DHookGetParam(hParams, 1);
	
	if(otherindex > 0 && otherindex <= MaxClients)
	{
		if(b_ThisEntityIgnored[otherindex])
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
	//	DHookSetReturn(hReturn, true); 
		return MRES_Ignored;
	}
	 
	if(b_CantCollidie[otherindex]) //no change in performance..., almost.
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;
	}
	if(b_CantCollidieAlly[otherindex]) //no change in performance..., almost.
	{
		if(i_IsABuilding[otherindex])
		{
			DHookSetReturn(hReturn, false); 
			return MRES_Supercede;
		}
	//	DHookSetReturn(hReturn, true); 
		return MRES_Ignored;
	}
	
//	DHookSetReturn(hReturn, true); 
	return MRES_Ignored;
}
//2 * m_vecMaxs
public MRESReturn IBody_GetHullWidth_ISGIANT(Address pThis, Handle hReturn, Handle hParams)			  { DHookSetReturn(hReturn, 60.0); return MRES_Supercede; }
public MRESReturn IBody_GetHullHeight_ISGIANT(Address pThis, Handle hReturn, Handle hParams)			 { DHookSetReturn(hReturn, 120.0); return MRES_Supercede; }
public MRESReturn IBody_GetStandHullHeight_ISGIANT(Address pThis, Handle hReturn, Handle hParams)		{ DHookSetReturn(hReturn, 120.0); return MRES_Supercede; }

public MRESReturn IBody_GetHullWidth(Address pThis, Handle hReturn, Handle hParams)			  { DHookSetReturn(hReturn, 48.0); return MRES_Supercede; }
public MRESReturn IBody_GetHullHeight(Address pThis, Handle hReturn, Handle hParams)			 { DHookSetReturn(hReturn, 82.0); return MRES_Supercede; }
public MRESReturn IBody_GetStandHullHeight(Address pThis, Handle hReturn, Handle hParams)		{ DHookSetReturn(hReturn, 82.0); return MRES_Supercede; }
//npc.m_bISGIANT
//BOUNDING BOX FOR ENEMY TO RESPECT

stock bool IsLengthGreaterThan(float vector[3], float length)
{
	return (SquareRoot(GetVectorLength(vector, false)) > length * length);
}

public float clamp(float a, float b, float c) { return (a > c ? c : (a < b ? b : a)); }

stock float[] WorldSpaceCenter(int entity)
{
	//We need to do an exception here, if we detect that we actually make the size bigger via lag comp
	//then we just get an offset of the abs origin, abit innacurate but it works like a charm.
	float vecPos[3];
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
	
	return vecPos;
}

public void InitNavGamedata()
{
	Handle hConf = LoadGameConfigFile("tf2.pets");

	navarea_count = GameConfGetAddress(hConf, "navarea_count");
	//PrintToServer("[CClotBody] Found \"navarea_count\" @ 0x%X", navarea_count);
	
	if(LoadFromAddress(navarea_count, NumberType_Int32) <= 0)
	{
		char buffer[64];
		GetCurrentMap(buffer, sizeof(buffer));
		PrintToServer("No Nav Mesh for %s, aborting map", buffer);
		RemoveEntity(0);
		return;
	}
	
	//TheNavAreas is nicely above navarea_count
	TheNavAreas = view_as<Address>(LoadFromAddress(navarea_count + view_as<Address>(0x4), NumberType_Int32));
	//PrintToServer("[CClotBody] Found \"TheNavAreas\" @ 0x%X", TheNavAreas);
	
	delete hConf;
}

stock NavArea PickRandomArea()
{
	int iAreaCount = LoadFromAddress(navarea_count, NumberType_Int32);
	
	//Pick a random goal area
	return view_as<NavArea>(LoadFromAddress(TheNavAreas + view_as<Address>(4 * GetRandomInt(0, iAreaCount - 1)), NumberType_Int32));
}

public bool FilterBaseActorsAndData(int entity, int contentsMask, any data)
{
	static char class[12];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(!StrContains(class, "base_boss")) return true;
	
	return !(entity == data);
}


public bool PluginBot_IsEntityTraversable(int bot_entidx, int other_entidx, TraverseWhenType when)
{
	if(other_entidx == 0) {
		return false;
	}
	
	if(other_entidx > 0 && other_entidx <= MaxClients) 
	{
		return true;
	}	
	
	CClotBody npc = view_as<CClotBody>(other_entidx);

	#if defined ISINVINCEABLEALLY || defined ISALLY
	if(npc.bCantCollidieAlly) //no change in performance..., almost.
	{
		return true;
	}
	#else
	if(npc.bCantCollidie) //no change in performance..., almost.
	{
		return true;
	}
	#endif
	
	if(when == IMMEDIATELY) {
		return false;
	}
	
	return false;
}

public void PluginBot_Approach(int bot_entidx, const float vec[3])
{
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	npc.Approach(vec);
	
	if(!npc.m_bAllowBackWalking)
		npc.FaceTowards(vec, (250.0 * npc.GetDebuffPercentage()));
}

public bool BulletAndMeleeTrace(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));

#if defined ZR
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
#endif
	if(StrEqual(class, "prop_physics") || StrEqual(class, "prop_physics_multiplayer"))
	{
		return false;
	}
	
	CClotBody npc = view_as<CClotBody>(entity);
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}	
	else if(StrEqual(class, "base_boss"))
	{
			//Yes its double but i need it here too for npc vs npc, sorry.
		if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		{
			return false;				
		}
		else if (npc.bCantCollidie && npc.bCantCollidieAlly) //If both are on, then that means the npc shouldnt be invis and stuff
		{
			return false;
		}
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	if(npc.m_bThisEntityIgnored)
	{
		return false;
	}
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

public bool BulletAndMeleeTracePlayerAndBaseBossOnly(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));

#if defined ZR
	if(entity > 0 && entity <= MaxClients) 
	{
		if(TeutonType[entity])
		{
			return false;
		}
	}
#endif

	if(StrEqual(class, "prop_physics") || StrEqual(class, "prop_physics_multiplayer"))
	{
		return false;
	}
	CClotBody npc = view_as<CClotBody>(entity);
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}	
	else if(StrContains(class, "obj_", false) != -1)
	{
		return false;
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	if(npc.m_bThisEntityIgnored)
	{
		return false;
	}
	if(StrEqual(class, "base_boss"))
	{
		return true;
	}
	return !(entity == iExclude);
}

public bool BulletAndMeleeTraceDontIgnoreBaseBoss(int entity, int contentsMask, any iExclude)
{
	char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	/*
	if(other_entidx > 0 && other_entidx <= MaxClients) 
	{
		return true;
	}
	*/
	if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	else if(GetEntProp(iExclude, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
		
	
	return !(entity == iExclude);
}

public float PluginBot_PathCost(int bot_entidx, NavArea area, NavArea from_area, float length)
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
	float Jump_1_frame[3];
	GetEntPropVector(bot_entidx, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
	Jump_1_frame[2] += 20.0;
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[bot_entidx])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}			
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
	}

	if (!IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, bot_entidx))//The boss will start to merge with shits, cancel out velocity.
	{
		float vecNPC[3], vecJumpVel[3];
		GetEntPropVector(bot_entidx, Prop_Data, "m_vecAbsOrigin", vecNPC);
		
		vecNPC[2] -= 20.0;
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
		//npc.SetOrigin(Jump_1_frame);
		//float No_Vel[3];
		//npc.SetVelocity(No_Vel);
		TeleportEntity(npc.index, Jump_1_frame, NULL_VECTOR, NULL_VECTOR);
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
	return false;
}
/*
public void PluginBot_PathSuccess(int bot_entidx, Address path)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = true;
	
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}

public void PluginBot_MoveToSuccess(int bot_entidx, Address path)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = false;
	
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}

public void PluginBot_MoveToFailure(int bot_entidx, Address path, MoveToFailureType type)
{
	PF_StopPathing(bot_entidx);
	view_as<CClotBody>(bot_entidx).m_bPathing = false;
	
	//view_as<CClotBody>(bot_entidx).m_flNextTargetTime = GetGameTime() + GetRandomFloat(1.0, 4.0);
}
*/
stock bool IsEntityAlive(int index)
{
	if(IsValidEntity(index) && index > 0)
	{
		if(index > MaxClients)
		{
			if(GetEntProp(index, Prop_Data, "m_iHealth") > 0)
			{
				return true;	
			}
			else
			{
				return false;
			}	
		}
		else
		{
			if(!IsPlayerAlive(index))
			{
				return false;	
			}
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
stock bool IsValidEnemy(int index, int enemy, bool camoDetection=false)
{
	if(IsValidEntity(enemy))
	{
		static char strClassname[16];
		GetEntityClassname(enemy, strClassname, sizeof(strClassname));
		if(StrEqual(strClassname, "player") || StrEqual(strClassname, "base_boss"))
		{
			CClotBody npc = view_as<CClotBody>(enemy);
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(enemy, Prop_Send, "m_iTeamNum"))
			{
				return false;
			}
			if(camoDetection)
			{
				if(npc.m_bThisEntityIgnored || b_ThisEntityIgnoredByOtherNpcsAggro[enemy])
				{
					return false;
				}
				else
				{
					return IsEntityAlive(enemy);
				}
			}
			else
			{
				if(npc.m_bThisEntityIgnored || npc.m_bCamo || b_ThisEntityIgnoredByOtherNpcsAggro[enemy])
				{
					return false;
				}
				else
				{
					return IsEntityAlive(enemy);
				}
			}	
		}
		else if(StrEqual(strClassname, "obj_dispenser") || StrEqual(strClassname, "obj_teleporter") || StrEqual(strClassname, "obj_sentrygun"))
		{
			CClotBody npc = view_as<CClotBody>(enemy);
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(enemy, Prop_Send, "m_iTeamNum"))
			{
				return false;
			}
			
			else if(npc.bBuildingIsStacked)
			{
				return false;
			}
			
			else if(npc.bBuildingIsPlaced)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	return false;
}

stock bool IsValidAllyPlayer(int index, int Ally)
{
	if(IsValidClient(Ally))
	{
		CClotBody npc = view_as<CClotBody>(Ally);
		if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(Ally, Prop_Send, "m_iTeamNum"))
		{
			if(npc.m_bThisEntityIgnored)
			{
				return false;
			}
			else
			{
				return IsEntityAlive(Ally);
			}
		}
	}
	
	return false;
}


stock int GetClosestTarget(int entity, bool IgnoreBuildings = false, float fldistancelimit = 999999.9, bool camoDetection=false, bool onlyPlayers = false, int ingore_client = -1, float EntityLocation[3] = {0.0,0.0,0.0})
{
	float TargetDistance = 0.0; 
	int ClosestTarget = -1; 
	int searcher_team = GetEntProp(entity, Prop_Send, "m_iTeamNum"); //do it only once lol
	if(EntityLocation[2] == 0.0)
	{
		GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
	}
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if (IsValidClient(i) && i != ingore_client)
		{
			CClotBody npc = view_as<CClotBody>(i);
			if (TF2_GetClientTeam(i)!=view_as<TFTeam>(searcher_team) && !npc.m_bThisEntityIgnored && IsEntityAlive(i)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
			{
				if(camoDetection)
				{
					float TargetLocation[3]; 
					GetClientAbsOrigin( i, TargetLocation ); 
					
					
					float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
					if(distance < fldistancelimit)
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
				else if (!npc.m_bCamo)
				{
					float TargetLocation[3]; 
					GetClientAbsOrigin( i, TargetLocation ); 
					
					
					float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
					if(distance < fldistancelimit)
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
	}
	/*
	
	
	enum TFTeam
	{
		TFTeam_Unassigned = 0,
		TFTeam_Spectator = 1,
		TFTeam_Red = 2,
		TFTeam_Blue = 3
	};
	*/
	for(int entitycount; entitycount<i_MaxcountNpc; entitycount++) //BLUE npcs.
	{
		int entity_close = EntRefToEntIndex(i_ObjectsNpcs[entitycount]);
		if(IsValidEntity(entity_close) && entity_close != ingore_client)
		{
			if(searcher_team != 3) 
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
				if(!npc.m_bThisEntityIgnored && GetEntProp(entity_close, Prop_Data, "m_iHealth") > 0 && !onlyPlayers && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
					if(camoDetection)
					{
						float TargetLocation[3]; 
						GetEntPropVector( entity_close, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
						float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
						if(distance < fldistancelimit)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = entity_close; 
									TargetDistance = distance;		  
								}
							} 
							else 
							{
								ClosestTarget =entity_close; 
								TargetDistance = distance;
							}	
						}	
					}
					else if (!npc.m_bCamo)
					{
						float TargetLocation[3]; 
						GetEntPropVector( entity_close, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
							
							
						float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
						if(distance < fldistancelimit)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = entity_close; 
									TargetDistance = distance;		  
								}
							} 
							else 
							{
								ClosestTarget = entity_close; 
								TargetDistance = distance;
							}	
						}	
					}
				}
			}
		}
	}
	for(int entitycount; entitycount<i_MaxcountNpc_Allied; entitycount++) //RED npcs.
	{
		int entity_close = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount]);
		if(IsValidEntity(entity_close) && entity_close != ingore_client)
		{
			if(searcher_team != 2)
			{
				CClotBody npc = view_as<CClotBody>(entity_close);
				if(!npc.m_bThisEntityIgnored && GetEntProp(entity_close, Prop_Data, "m_iHealth") > 0 && !onlyPlayers && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //Check if dead or even targetable
				{
					if(camoDetection)
					{
						float TargetLocation[3]; 
						GetEntPropVector( entity_close, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
						float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
						if(distance < fldistancelimit)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = entity_close; 
									TargetDistance = distance;		  
								}
							} 
							else 
							{
								ClosestTarget = entity_close; 
								TargetDistance = distance;
							}	
						}	
					}
					else if (!npc.m_bCamo)
					{
						float TargetLocation[3]; 
						GetEntPropVector( entity_close, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
							
							
						float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
						if(distance < fldistancelimit)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = entity_close; 
									TargetDistance = distance;		  
								}
							} 
							else 
							{
								ClosestTarget = entity_close; 
								TargetDistance = distance;
							}	
						}	
					}
				}
			}
		}
	}
	
#if defined ZR
	if(searcher_team != 2 && !IsValidEntity(EntRefToEntIndex(RaidBossActive)) && !IgnoreBuildings)
#else
	if(!IgnoreBuildings && searcher_team != 2)
#endif
	{
		for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++) //BUILDINGS!
		{
			int entity_close = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
			if(IsValidEntity(entity_close) && entity_close != ingore_client)
			{
					CClotBody npc = view_as<CClotBody>(entity_close);
					if(!npc.bBuildingIsStacked && npc.bBuildingIsPlaced && !b_ThisEntityIgnored[entity_close] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity_close]) //make sure it doesnt target buildings that are picked up and special cases with special building types that arent ment to be targeted
					{
						float TargetLocation[3]; 
						GetEntPropVector( entity_close, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
						float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
						if(distance < fldistancelimit)
						{
							if( TargetDistance ) 
							{
								if( distance < TargetDistance ) 
								{
									ClosestTarget = entity_close; 
									TargetDistance = distance;		  
								}
							} 
							else 
							{
								ClosestTarget = entity_close; 
								TargetDistance = distance;
							}	
						}
					}
			}
		}
	}
	/*
//	if() //Make sure that they completly ignore barricades during raids
	{
		for (int pass = 0; pass <= 2; pass++)
		{
			static char classname[1024];
			if (pass == 0) classname = "obj_sentrygun";
			else if (pass == 1) classname = "obj_dispenser";
		//	else if (pass == 2) classname = "obj_teleporter";
			else if (pass == 2) classname = "base_boss";
	
			int i = MaxClients + 1;
			while ((i = FindEntityByClassname(i, classname)) != -1)
			{
				if (searcher_team != GetEntProp(i, Prop_Send, "m_iTeamNum")) 
				{
					CClotBody npc = view_as<CClotBody>(i);
					if(pass != 2)
					{
						if(!npc.bBuildingIsStacked && npc.bBuildingIsPlaced) //make sure it doesnt target buildings that are picked up and special cases with special building types that arent ment to be targeted
						{
							
							if(!IsValidEntity(EntRefToEntIndex(RaidBossActive)) && !IgnoreBuildings)
							{
								float EntityLocation[3], TargetLocation[3]; 
								GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
								GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
								float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
								if(distance < fldistancelimit)
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
					else
					{
						if(!npc.m_bThisEntityIgnored && GetEntProp(i, Prop_Data, "m_iHealth") > 0 && !onlyPlayers) //Check if dead or even targetable
						{
							if(camoDetection)
							{
								float EntityLocation[3], TargetLocation[3]; 
								GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
								GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
								float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
								if(distance < fldistancelimit)
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
							else if (!npc.m_bCamo)
							{
								float EntityLocation[3], TargetLocation[3]; 
								GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
								GetEntPropVector( i, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
									
									
								float distance = GetVectorDistance( EntityLocation, TargetLocation ); 
								if(distance < fldistancelimit)
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
				}
			}
		}
	}
	*/
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
			if (TF2_GetClientTeam(i)==view_as<TFTeam>(GetEntProp(entity, Prop_Send, "m_iTeamNum")) && !npc.m_bThisEntityIgnored && IsEntityAlive(i)) //&& CheckForSee(i)) we dont even use this rn and probably never will.
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
/*
stock bool CheckForSee(int client)
{
	if (TF2_IsPlayerInCondition(client,TFCond_Cloaked) || TF2_IsPlayerInCondition(client,TFCond_Disguised) || TF2_IsPlayerInCondition(client,TFCond_Stealthed) || TF2_IsPlayerInCondition(client,TFCond_StealthedUserBuffFade))
		return false;
		
	return true;
}
*/

stock bool IsSpaceOccupiedIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_PLAYERSOLID, TraceRayDontHitPlayersOrEntityCombat, entity);
	bool bHit = TR_DidHit(hTrace);
	ref = TR_GetEntityIndex(hTrace);
	delete hTrace;
	return bHit;
}

stock bool IsSpaceOccupiedDontIgnorePlayers(const float pos[3], const float mins[3], const float maxs[3],int entity=-1,int &ref=-1)
{
	Handle hTrace = TR_TraceHullFilterEx(pos, pos, mins, maxs, MASK_NPCSOLID, TraceRayHitPlayers, entity);
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

public bool TraceRayHitPlayersOnly(int entity,int mask,any data)
{
	if (entity > 0 && entity <= MaxClients)
	{
#if defined ZR
		if(TeutonType[entity] == TEUTON_NONE && dieingstate[entity] == 0)
#endif
		{
			if(!b_DoNotUnStuck[entity] && !b_ThisEntityIgnored[entity])
				return true;
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

//This is mainly to see if you THE PLAYER!!!!! is stuck inside the WORLD OR BRUSHES OR STUFF LIKE THAT. Not stuck inside an npc, because this code is not made for that.
public bool TraceRayDontHitPlayersOrEntityCombat(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return true;
	}

	if(entity > 0 && entity <= MaxClients) 
	{
		return false;
	}

	static char class[64];
	GetEntityClassname(entity, class, sizeof(class));
	if(StrEqual(class, "prop_physics") || StrEqual(class, "prop_physics_multiplayer"))
	{
		return false;
	}
	
	CClotBody npc = view_as<CClotBody>(entity);
	
	if(StrEqual(class, "base_boss"))
	{
		return false;
	}
	
	else if(StrContains(class, "tf_projectile_", false) != -1)
	{
		return false;
	}
	
	//if anything else is team
	
	if(GetEntProp(data, Prop_Send, "m_iTeamNum") == GetEntProp(entity, Prop_Send, "m_iTeamNum"))
		return false;
	
	if(StrEqual(class, "func_brush"))
	{
		return true;//They blockin me
	}
	else if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return true;//They blockin me and not on same team, otherwsie top filter
	}
	
	if(npc.m_bThisEntityIgnored)
	{
		return false;
	}
	
	if(entity == Entity_to_Respect)
	{
		return false;
	}
	
	return true;
}

float f_StuckTextChatNotif[MAXTF2PLAYERS];

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

public void Check_If_Stuck(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	
	static float flMyPos[3];
	GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", flMyPos);
	if(!b_IsAlliedNpc[iNPC])
	{
		//If NPCs some how get out of bounds
		if(f_StuckOutOfBoundsCheck[iNPC] < GetGameTime())
		{
			static float flMyPos_Bounds[3];
			flMyPos_Bounds = flMyPos;
			flMyPos_Bounds[2] += 25.0;
			f_StuckOutOfBoundsCheck[iNPC] = GetGameTime() + 10.0;
			if(TR_PointOutsideWorld(flMyPos))
			{
				CreateTimer(1.0, Timer_CheckStuckOutsideMap, EntIndexToEntRef(iNPC), TIMER_FLAG_NO_MAPCHANGE);
			}
		}

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
			static float flPlayerPos[3];
			GetEntPropVector(Hit_player, Prop_Data, "m_vecAbsOrigin", flPlayerPos);
			static float flMyPos_2[3];
			flMyPos_2[0] = flPlayerPos[0];
			flMyPos_2[1] = flPlayerPos[1];
			flMyPos_2[2] = flMyPos[2];
			
			if(flPlayerPos[2] > flMyPos_2[2]) //PLAYER IS ABOVE ZOMBIE
			{
				flMyPos_2[2] += hullcheckmaxs_Player[2];
				
				if(IsValidEntity(Hit_player))
				{
					
					static float hullcheckmaxs_Player_Again[3];
					static float hullcheckmins_Player_Again[3];

					hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );		
					
					if(!IsSpaceOccupiedIgnorePlayers(flMyPos_2, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, Hit_player))
					{
						SDKCall_SetLocalOrigin(Hit_player, flMyPos_2);	
					//	TeleportEntity(entity, f3_LastValidPosition[entity], NULL_VECTOR, { 0.0, 0.0, 0.0 });
					}
					else
					{
						if(f_StuckTextChatNotif[Hit_player] < GetGameTime())
						{
							f_StuckTextChatNotif[Hit_player] = GetGameTime() + 1.0;
							PrintToChat(Hit_player, "You are stuck, yet Unstucking you will stuck you again, you will remain in this position so if you kill the npc, you can get free.");
						}
					}
				}		
			}
			else //PLAYER IS BELOW ZOMBIE
			{
				flMyPos_2[0] = flMyPos[0];
				flMyPos_2[1] = flMyPos[1];
				flMyPos_2[2] = flMyPos[2];
				flMyPos_2[2] += 82.0; //Player height.
				flMyPos_2[2] += 5.0;
				
				if(IsValidEntity(Hit_player))
				{
					static float hullcheckmaxs_Player_Again[3];
					static float hullcheckmins_Player_Again[3];

					hullcheckmaxs_Player_Again = view_as<float>( { 24.0, 24.0, 82.0 } );
					hullcheckmins_Player_Again = view_as<float>( { -24.0, -24.0, 0.0 } );		
					
					if(!IsSpaceOccupiedIgnorePlayers(flMyPos_2, hullcheckmins_Player_Again, hullcheckmaxs_Player_Again, iNPC))
					{
						SDKCall_SetLocalOrigin(iNPC, flMyPos_2);	
						TeleportEntity(iNPC, flMyPos_2, NULL_VECTOR, { 0.0, 0.0, 0.0 }); //Reset their speed
						npc.SetVelocity({ 0.0, 0.0, 0.0 });
						f_NpcHasBeenUnstuckAboveThePlayer[iNPC] = GetGameTime() + 1.0; //Make the npc immortal! This will prevent abuse of stuckspots.
					}
					else
					{
						if(f_StuckTextChatNotif[Hit_player] < GetGameTime())
						{
							f_StuckTextChatNotif[Hit_player] = GetGameTime() + 1.0;
							PrintToChat(Hit_player, "You are stuck, yet Unstucking you will stuck you again, you will remain in this position so if you kill the npc, you can get free.");
						}
					}
				}
			}
		}
		//This is a tempomary fix. find a better one for players getting stuck.
	}
	else
	{
		if(f_StuckOutOfBoundsCheck[iNPC] < GetGameTime())
		{
			f_StuckOutOfBoundsCheck[iNPC] = GetGameTime() + 10.0;
			//If NPCs some how get out of bounds
			static float flMyPos_Bounds[3];
			flMyPos_Bounds = flMyPos;
			flMyPos_Bounds[2] += 25.0;
			if(TR_PointOutsideWorld(flMyPos_Bounds))
			{
				LogError("Allied NPC somehow got out of the map..., Cordinates : {%f,%f,%f}", flMyPos_Bounds[0],flMyPos_Bounds[1],flMyPos_Bounds[2]);
				
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
	

	//TODO:
	//Rewrite  ::Update func inside nextbots instead of doing this.
	if (!npc.IsOnGround())
	{
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
		
		//invert to save 1 frame per 3 minutes
	
		hullcheckmins[0] -= 15.0;
		hullcheckmins[1] -= 15.0;
		
		hullcheckmaxs[0] += 15.0;
		hullcheckmaxs[1] += 15.0;
		
		hullcheckmins[2] -= 20.0; //STEP HEIGHT
		hullcheckmaxs[2] += 20.0;
		
		if (!npc.g_bNPCVelocityCancel && IsSpaceOccupiedIgnorePlayers(flMyPos, hullcheckmins, hullcheckmaxs, iNPC))//The boss will start to merge with shits, cancel out velocity.
		{
			static float vec3Origin[3];
			npc.SetVelocity(vec3Origin);
			npc.g_bNPCVelocityCancel = true;
		}
	}
	else
	{
		npc.g_bNPCVelocityCancel = false;
	}
	
	
}

//using normal ontakedamage will make it abit more inaccurate but it will work
//Using post will make it too late and it wont even get called as the npc has already died, resulting in post not calling anymore
//Have to use this, for now, if that one bug still happens with unhooks and dhooks then i will revert back.

static float f_CooldownForHurtParticle[MAXENTITIES];	

public Action NPC_OnTakeDamage_Base(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	/*
	if(attacker < MaxClients && attacker > 0) //make sure players cannot hurt allied npcs.
	//Do not use team checks, they actually lag alot...
	{
		return Plugin_Handled;
	}
	*/
	CClotBody npc = view_as<CClotBody>(victim);
	npc.m_vecpunchforce(damageForce, true);
	npc.m_bGib = false;

//This exists for rpg so that attacking the target will trigger it for hte next 5 seconds.
//ZR does not need this.
#if defined RPG
	if(IsValidEntity(attacker))
	{
		if(GetEntProp(attacker, Prop_Send, "m_iTeamNum")!=GetEntProp(victim, Prop_Send, "m_iTeamNum"))
		{
			npc.m_flGetClosestTargetNoResetTime = GetGameTime(npc.index) + 5.0; //make them angry for 5 seconds if they are too far away.

			if(npc.m_iTarget == -1) //Only set it if they actaully have no target.
			{
				npc.m_iTarget = attacker;
			}
		}
	}

#endif
	if(f_IsThisExplosiveHitscan[attacker] == GetGameTime())
	{
		npc.m_vecpunchforce(CalculateDamageForceSelfCalculated(attacker, 10000.0), true);
		damagetype |= DMG_BULLET; //add bullet logic
		damagetype &= ~DMG_BLAST; //remove blast logic			
	}
	
	if((damagetype & DMG_CLUB)) //Needs to be here because it already gets it from the top.
	{
		
#if defined ZR
		if(Medival_Difficulty_Level != 0.0)
		{
			damage *= Medival_Difficulty_Level;
		}
		
		if(fl_MeleeArmor[victim] >= 1.0 || !Building_DoesPierce(attacker))
#endif
		
		{
			damage *= fl_MeleeArmor[victim];
		}
	}
	else if(!(damagetype & DMG_SLASH))
	{
		
#if defined ZR
		if(Medival_Difficulty_Level != 0.0)
		{
			damage *= Medival_Difficulty_Level;
		}
		
		if(fl_RangedArmor[victim] >= 1.0 || !Building_DoesPierce(attacker))
#endif
		
		{
			damage *= fl_RangedArmor[victim];
		}
	}
	//No resistances towards slash as its internal.
	
	
	
	if(!npc.m_bDissapearOnDeath) //Make sure that if they just vanish, its always false. so their deathsound plays.
	{
		if((damagetype & DMG_BLAST))
		{
			npc.m_bGib = true;
		}
		else if(damage > (GetEntProp(victim, Prop_Data, "m_iMaxHealth") * 1.5))
		{
			npc.m_bGib = true;
		}
	}
	if(damagePosition[0] != 0.0) //If there is no pos, then dont.
	{
		if(!(damagetype & (DMG_SHOCK)))
		{
			if (f_CooldownForHurtParticle[victim] < GetGameTime())
			{
				f_CooldownForHurtParticle[victim] = GetGameTime() + 0.1;

				if(npc.m_iBleedType == 1)
				{
					TE_ParticleInt(g_particleImpactFlesh, damagePosition);
					TE_SendToAll();
				}
				else if (npc.m_iBleedType == 2)
				{
					damagePosition[2] -= 40.0;
					TE_ParticleInt(g_particleImpactMetal, damagePosition);
					TE_SendToAll();
				}
				else if (npc.m_iBleedType == 3)
				{
					TE_ParticleInt(g_particleImpactRubber, damagePosition);
					TE_SendToAll();
				}
				else if (npc.m_iBleedType == 4)
				{
					//If you cant find any good blood effect, use this one and just recolour it.
					TE_BloodSprite(damagePosition, { 0.0, 0.0, 0.0 }, 125, 255, 125, 255, 32);
					TE_SendToAll();
				}
			}
		}
	}
	return Plugin_Continue;
	//return CClotBodyDamaged_flare(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
}

stock void Custom_Knockback(int attacker, int enemy, float knockback, bool ignore_attribute = false, bool override = false, bool work_on_entity = false)
{
	if(enemy <= MaxClients || work_on_entity)
	{							
		float vAngles[3], vDirection[3];
										
		GetEntPropVector(attacker, Prop_Data, "m_angRotation", vAngles); 
										
		if(vAngles[0] > -45.0)
		{
			vAngles[0] = -45.0;
		}
										
		GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
			
		if(!ignore_attribute && !work_on_entity)
		{
			float Attribute_Knockback = Attributes_FindOnPlayer(enemy, 252, true, 1.0);	
			
			knockback *= Attribute_Knockback;
		}
		
#if defined ZR
		knockback *= 0.75; //oops, too much knockback now!
#endif
		
		ScaleVector(vDirection, knockback);
		
		if(!override)
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
		TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, vDirection); 
	}
}

public int Can_I_See_Enemy(int attacker, int enemy)
{
	Handle trace; 
	float pos_npc[3];
	float pos_enemy[3];
	pos_npc = WorldSpaceCenter(attacker);
	pos_enemy = WorldSpaceCenter(enemy);
	
	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, MASK_NPCSOLID, RayType_EndPoint, BulletAndMeleeTrace, attacker);
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
	pos_npc = WorldSpaceCenter(attacker);
	pos_enemy = WorldSpaceCenter(enemy);

	
	AddEntityToTraceStuckCheck(enemy);
	
	trace = TR_TraceRayFilterEx(pos_npc, pos_enemy, MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitPlayersOrEntityCombat, attacker);
	
	RemoveEntityToTraceStuckCheck(enemy);
	
	bool bHit = TR_DidHit(trace);	

	delete trace;
	return bHit;
}

/*
void RequestFrames(RequestFrameCallback func, int frames, any data=0)
{
	DataPack pack = new DataPack();
	pack.WriteFunction(func);
	pack.WriteCell(data);
	pack.WriteCell(frames);
	RequestFrame(RequestFramesCallback, pack);
}

public void RequestFramesCallback(DataPack pack)
{
	pack.Reset();
	RequestFrameCallback func = view_as<RequestFrameCallback>(pack.ReadFunction());
	any data = pack.ReadCell();

	int frames = pack.ReadCell();
	if(frames < 2)
	{
		RequestFrame(func, data);
		delete pack;
	}
	else
	{
		pack.Position--;
		pack.WriteCell(frames-1, false);
		RequestFrame(RequestFramesCallback, pack);
	}
}
*/


//	models/Gibs/HGIBS.mdl
//	models/Gibs/HGIBS_scapula.mdl
//	models/Gibs/HGIBS_spine.mdl
//	models/Gibs/HGIBS_rib.mdl
//	models/gibs/antlion_gib_large_1.mdl //COLOR RED!



static int Place_Gib(const char[] model, float pos[3],float ang[3] = {0.0,0.0,0.0}, float vel[3], bool Reduce_masively_Weight = false, bool big_gibs = false, bool metal_colour = false, bool Rotate = false, bool smaller_gibs = false, bool xeno = false, bool nobleed = false)
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
			TeleportEntity(prop, pos, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			TeleportEntity(prop, pos, {90.0,0.0,0.0}, NULL_VECTOR);
		}
	}
	else
	{
		if(!Rotate)
		{
			TeleportEntity(prop, pos, ang, NULL_VECTOR);
		}
		else
		{
			ang[0] += 90.0;
			TeleportEntity(prop, pos, ang, NULL_VECTOR);
		}		
		
	}
	DispatchSpawn(prop);
	TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);

	float Random_time = GetRandomFloat(6.0, 7.0);
	SetEntityCollisionGroup(prop, 2); //COLLISION_GROUP_DEBRIS_TRIGGER
	
	b_IsAGib[prop] = true;
	
	if (!nobleed)
	{
		if(!metal_colour)
		{
			if(!xeno)
			{
				int particle = ParticleEffectAt(pos, "blood_trail_red_01_goop", Random_time); //This is a permanent particle, gotta delete it manually...
				SetParent(prop, particle);
				SetEntityRenderColor(prop, 255, 0, 0, 255);
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
	CreateTimer(Random_time, Timer_RemoveEntity_Prop_Gib, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
//	CreateTimer(1.5, Timer_DisableMotion, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
	return prop;
}

public void GibCollidePlayerInteraction(int gib, int player)
{
	if(b_IsCannibal[player])
	{
		
#if defined ZR
		if(dieingstate[player] == 0)
#endif
		
		{
			int weapon = GetEntPropEnt(player, Prop_Send, "m_hActiveWeapon");
			if(IsValidEntity(weapon)) //Must also hold melee out 
			{
				if(!i_IsWandWeapon[weapon]) //Make sure its not wand.
				{
					if(SDKCall_GetMaxHealth(player) > GetEntProp(player, Prop_Send, "m_iHealth"))
					{
						float Heal_Amount = 0.0;
						
						Address address = TF2Attrib_GetByDefIndex(weapon, 180);
						if(address != Address_Null)
							Heal_Amount = TF2Attrib_GetValue(address);
				
						
						int Heal_Amount_calc;
						
						Heal_Amount_calc = RoundToNearest(Heal_Amount * 0.75);
						
						if(Heal_Amount_calc > 0)
						{
							if(b_LimitedGibGiveMoreHealth[gib])
							{
								Heal_Amount_calc *= 3;
							}
							StartHealingTimer(player, 0.1, 1, Heal_Amount_calc);
							int sound = GetRandomInt(0, sizeof(g_GibEating) - 1);
							EmitSoundToAll(g_GibEating[sound], player, SNDCHAN_AUTO, 80, _, 1.0, _, _);
							RemoveEntity(gib);
							CurrentGibCount -= 1;
						}
					}
				}
			}
		}
	}
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

public void PluginBot_Jump_Now(int bot_entidx, float vecPos[3])
{
	CClotBody npc = view_as<CClotBody>(bot_entidx);
	
	float watchForClimbRange = 75.0;
	
	float vecNPC[3];
	GetEntPropVector(bot_entidx, Prop_Data, "m_vecOrigin", vecNPC);
	
	float flDistance = GetVectorDistance(vecNPC, vecPos);
	if(flDistance > watchForClimbRange || npc.m_bJumping)
		return;
	
	//I guess we failed our last jump because we're jumping again this soon, let's try just a regular jump.
	if((GetGameTime() - npc.m_flJumpStartTime) < 0.25)
		npc.Jump();
	/*
	else
		npc.JumpAcrossGap(vecPos, vecPos);
	*/
	npc.m_bJumping = true;
	npc.m_flJumpStartTime = GetGameTime();
}


public void PluginBot_Jump_Now_old(int bot_index)
{
	CClotBody npc = view_as<CClotBody>(bot_index);

	if((GetGameTime() - npc.m_flJumpStartTimeInternal) < 2.0)
		return;

	npc.m_flJumpStartTimeInternal = GetGameTime();

	float Jump_1_frame[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
	Jump_1_frame[2] += 20.0;
	
	static float hullcheckmaxs[3];
	static float hullcheckmins[3];
	if(b_IsGiant[bot_index])
	{
		hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
		hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}			
	else
	{
		hullcheckmaxs = view_as<float>( { 24.0, 24.0, 82.0 } );
		hullcheckmins = view_as<float>( { -24.0, -24.0, 0.0 } );		
	}
	
	if (!IsSpaceOccupiedDontIgnorePlayers(Jump_1_frame, hullcheckmins, hullcheckmaxs, npc.index))//The boss will start to merge with shits, cancel out velocity.
	{
		float Save_Old_Pos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Save_Old_Pos);
		npc.m_vecLastValidPosJump(Save_Old_Pos, true);
		float vecJumpVel[3];
		npc.m_flJumpCooldown = GetGameTime() + 1.5;
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsVelocity", vecJumpVel);
		
		vecJumpVel[2] = 350.0;
		
		npc.Jump();
	//	vecJumpVel[0] = 0.0;
	//	vecJumpVel[1] = 0.0;
		SetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Jump_1_frame);
		CreateTimer(0.1, Did_They_Get_Suck, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		npc.SetVelocity(vecJumpVel);
		
	}
	return;
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
			
			if(StrContains(class, "base_boss") && StrContains(class, "obj_")) //if its the world, then do this.
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
		if(client != -1)
		{
			if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)))
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, client, m_flDamage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos); //any bullet type will deal 5x the damage, usually
		}
		else
		{
			if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)) && TR_GetEntityIndex(trace) <= MaxClients)
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, m_pAttacker, m_flDamage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos);
			else if(IsValidEnemy(m_pAttacker, TR_GetEntityIndex(trace)) && TR_GetEntityIndex(trace) > MaxClients)
				SDKHooks_TakeDamage(TR_GetEntityIndex(trace), m_pAttacker, m_pAttacker, m_flDamage * bonus_entity_damage, nDamageType, -1, CalculateBulletDamageForce(m_vecDirShooting, 1.0), endpos); //any bullet type will deal 5x the damage, usually
		}
		
	}
	int hurt_who = TR_GetEntityIndex(trace);
	delete trace;
	return hurt_who;
}

float[] CalculateBulletDamageForce( const float vecBulletDir[3], float flScale )
{
	float vecForce[3]; vecForce = vecBulletDir;
	NormalizeVector( vecForce, vecForce );
	ScaleVector(vecForce, FindConVar("phys_pushscale").FloatValue);
	ScaleVector(vecForce, flScale);
	return vecForce;
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
			if(!b_IsAlliedNpc[attacker])
			{
				FromBlueNpc = true;
				
				Range_for_boom = RoundToCeil(float(Range_for_boom) * 1.65);
			}
		}
		Range_for_boom = RoundToCeil(float(Range_for_boom) * 1.1); //Overall abit more range due to how our checks work.
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
	
	
stock void CreateParticle(char[] particle, float pos[3], float ang[3])
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
	TE_SendToAll();
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

public MRESReturn ILocomotion_GetRunSpeed(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetRunSpeed()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_GetSolidMask(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetSolidMask()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_GetActivity(Address pThis, Handle hReturn, Handle hParams)			  
{ 
	#if defined DEBUG_ANIMATION
	PrintToServer("IBody_GetActivity");	
	#endif
	
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).GetActivity()); 
	return MRES_Supercede; 
}

public MRESReturn IBody_IsActivity(Address pThis, Handle hReturn, Handle hParams)			  
{
	int iActivity = DHookGetParam(hParams, 1);
	
	#if defined DEBUG_ANIMATION
	PrintToServer("IBody_IsActivity %i", iActivity);	
	#endif

	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).IsActivity(iActivity));
	return MRES_Supercede; 
}

public MRESReturn IBody_StartActivity(Address pThis, Handle hReturn, Handle hParams)			 
{ 
	int iActivity = DHookGetParam(hParams, 1);
	int fFlags	= DHookGetParam(hParams, 2);
	
	PrintToServer("IBody_StartActivity %i %i", iActivity, fFlags);	
	
	DHookSetReturn(hReturn, view_as<CClotBody>(SDKCall(g_hGetEntity, SDKCall(g_hGetBot, pThis))).StartActivity(iActivity, fFlags)); 
	
	return MRES_Supercede; 
}

stock float[] PredictSubjectPosition(CClotBody npc, int subject, float Extra_lead = 0.0)
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	float subjectPos[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
		
	botPos[2] += 1.0;
	subjectPos[2] += 1.0;
#if defined ZR
	if(Npc_Is_Targeted_In_Air(npc.index)) //Logic breaks when they are under this effect.
	{
		return subjectPos;
	}
#endif
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
		return subjectPos;
	
	// Normalize in place
	float range = SquareRoot( flRangeSq );
	to[0] /= ( range + 0.0001 );	// avoid divide by zero
	to[1] /= ( range + 0.0001 );	// avoid divide by zero
	to[2] /= ( range + 0.0001 );	// avoid divide by zero
	
	// estimate time to reach subject, assuming maximum speed
	float leadTime = (0.1 + Extra_lead) + ( range / ( npc.GetRunSpeed() + 0.0001 ) );
	
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
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	

	NavArea leadArea = TheNavMesh.GetNearestNavArea_Vec( pathTarget );
	
	
	if (leadArea == NavArea_Null || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		return subjectPos;	
	}

	pathTarget[2] += 20.0; //Clip them up, minimum crouch level preferred, or else the bots get really confused and sometimees go otther ways if the player goes up or down somewhere, very thin stairs break these bots.

/*	
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	TE_SetupBeamPoints(botPos, pathTarget, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	TE_SendToAll();
*/
	/*
	//Extra check on if they try to follow through a wall again, double check is always good. Specficially check for only COLLIDING WITH THE WORLD.
	
	int Looking_At_This; 
	Looking_At_This = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
	if(IsValidEntity(Looking_At_This) && IsValidEnemy(sentry, Looking_At_This))
	{
		Handle trace; 
		float pos_sentry[3]; GetEntPropVector(sentry, Prop_Data, "m_vecAbsOrigin", pos_sentry);
		float pos_enemy[3]; GetEntPropVector(Looking_At_This, Prop_Data, "m_vecAbsOrigin", pos_enemy);
		pos_sentry[2] += 25.0;
		pos_enemy[2] += 45.0;
		
		trace = TR_TraceRayFilterEx(pos_sentry, pos_enemy, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, Base_Boss_Hit, sentry);
		int Traced_Target;
		
//		int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
//		TE_SetupBeamPoints(pos_sentry, pos_enemy, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 1.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
//		TE_SendToAll();
		
		Traced_Target = TR_GetEntityIndex(trace);
		delete trace;
		
		if(IsValidEntity(Traced_Target) && IsValidEnemy(sentry, Traced_Target))
		{
			DHookSetReturn(hReturn, true); 
			return MRES_Supercede;		
		}
	}
	*/
	
	return pathTarget;
}

static float f_PickThisDirectionForabit[MAXENTITIES];
static int i_PickThisDirectionForabit[MAXENTITIES];

stock float[] BackoffFromOwnPositionAndAwayFromEnemy(CClotBody npc, int subject, float extra_backoff = 64.0)
{
	float botPos[3];
	botPos = WorldSpaceCenter(npc.index);
	
	float subjectPos[3];
	subjectPos = WorldSpaceCenter(subject);

	// compute our desired destination
	float pathTarget[3];
	
		
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
			
		vecTarget = WorldSpaceCenter(subject);
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
		trace = TR_TraceRayFilterEx(botPos, vecSwingEnd, MASK_ALL, RayType_EndPoint, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
		
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
	if(flDistanceToTarget < ((Pow(extra_backoff, 2.0)) / 2.0))
	{
	//	PrintToChatAll("Im against a wall! try other running away methods!");
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
		
			vecTarget_2 = WorldSpaceCenter(subject);
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
		
			vecTarget_2 = WorldSpaceCenter(subject);
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
	
	return pathTarget;
}
/*
public Action SDKHook_Settransmit_Baseboss(int entity, int client)
{
	PrintToChatAll("SDKHook_Settransmit_Baseboss");
	return Plugin_Continue;
}
*/
stock float[] PredictSubjectPositionForProjectiles(CClotBody npc, int subject, float projectile_speed)
{
	float botPos[3];
	botPos = WorldSpaceCenter(npc.index);
	
	float subjectPos[3];
	subjectPos = WorldSpaceCenter(subject);
	
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
	float pathTarget[3];
	AddVectors(subjectPos, lead, pathTarget);

	// validate this destination

	// don't lead through walls
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
	return pathTarget;
}

stock float[] PredictSubjectPositionHook(CClotBody npc, int subject)
{
	float botPos[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", botPos);
	
	float subjectPos[3];
	GetEntPropVector(subject, Prop_Data, "m_vecAbsOrigin", subjectPos);
	
	float to[3];
	SubtractVectors(subjectPos, botPos, to);
	to[2] = 0.0;
	
	float flRangeSq = GetVectorLength(to, true);

	// don't lead if subject is very far away
	float flLeadRadiusSq = npc.GetLeadRadius(); 
	
	if ( flRangeSq > flLeadRadiusSq )
		return subjectPos;
	
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
		if (!PF_IsPotentiallyTraversable( npc.index, subjectPos, pathTarget, IMMEDIATELY, fraction))
		{
			// tried to lead through an unwalkable area - clip to walkable space
			pathTarget[0] = subjectPos[0] + fraction * ( pathTarget[0] - subjectPos[0] );
			pathTarget[1] = subjectPos[1] + fraction * ( pathTarget[1] - subjectPos[1] );
			pathTarget[2] = subjectPos[2] + fraction * ( pathTarget[2] - subjectPos[2] );
		}
	}
	

	NavArea leadArea = TheNavMesh.GetNearestNavArea_Vec( pathTarget );
	
	
	if (leadArea == NavArea_Null || leadArea.GetZ(pathTarget[0], pathTarget[1]) < pathTarget[2] - npc.GetMaxJumpHeight())
	{
		// would fall off a cliff
		return subjectPos;	
	}

	
	return pathTarget;
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

stock float Custom_Explosion(int clientIdx, float distance, float SS_DamageDecayExponent, float SS_MaxDamage, float SS_Radius) // ty Sarysa.
{
	float damage;
	if (SS_DamageDecayExponent <= 0.0)
		damage = SS_MaxDamage;
	else if (SS_DamageDecayExponent == 1.0)
		damage = SS_MaxDamage * (1.0 - (distance / SS_Radius));
	
	else
	{
		damage = SS_MaxDamage - (SS_MaxDamage * (Pow(Pow(SS_Radius, SS_DamageDecayExponent) -
			Pow(SS_Radius - distance, SS_DamageDecayExponent), 1.0 / SS_DamageDecayExponent) / SS_Radius));
	}
	return fmax(1.0, damage);
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

void TE_BloodSprite(float Origin[3],float Direction[3], int red, int green, int blue, int alpha, int size)
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
							float fStartWidth=NORMAL_ZOMBIE_VOLUME, float fEndWidth=NORMAL_ZOMBIE_VOLUME, float fAmp=1.35, char[] Model = "sprites/laserbeam.vmt")
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

	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt));
	SetEntPropEnt(iBeam, Prop_Send, "m_hAttachEntity", EntIndexToEntRef(iEnt2), 1);

	SetEntProp(iBeam, Prop_Send, "m_nNumBeamEnts", 2);
	SetEntProp(iBeam, Prop_Send, "m_nBeamType", 2);

	SetEntPropFloat(iBeam, Prop_Data, "m_fWidth", fStartWidth);
	SetEntPropFloat(iBeam, Prop_Data, "m_fEndWidth", fEndWidth);

	SetEntPropFloat(iBeam, Prop_Data, "m_fAmplitude", fAmp);

	SetVariantFloat(32.0);
	AcceptEntityInput(iBeam, "Amplitude");
	AcceptEntityInput(iBeam, "TurnOn");
	return iBeam;
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


stock int GetClosestAlly(int entity, float limitsquared = 99999999.9)
{
	float TargetDistance = 0.0; 
	int ClosestTarget = 0; 

	int i = MaxClients + 1;
	while ((i = FindEntityByClassname(i, "base_boss")) != -1)
	{
		if (i != entity && GetEntProp(entity, Prop_Send, "m_iTeamNum")==GetEntProp(i, Prop_Send, "m_iTeamNum") && !Is_a_Medic[i] && GetEntProp(i, Prop_Data, "m_iHealth") > 0)  //The is a medic thing is really needed
		{
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
	return ClosestTarget; 
}

stock bool IsValidAlly(int index, int ally)
{
	if(IsValidEntity(ally))
	{
		static char strClassname[16];
		GetEntityClassname(ally, strClassname, sizeof(strClassname));
		if(StrEqual(strClassname, "base_boss"))
		{
			if(GetEntProp(index, Prop_Send, "m_iTeamNum") == GetEntProp(ally, Prop_Send, "m_iTeamNum") && GetEntProp(ally, Prop_Data, "m_iHealth") > 0) 
			{
				return true;
			}
		}
	}
	
	return false;
}

public void PluginBot_OnActorEmoted(int bot_entidx, int who, int concept)
{
#if defined ZR
	switch(i_NpcInternalId[bot_entidx])
	{
		case BOB_THE_GOD_OF_GODS:
		{
			BobTheGod_PluginBot_OnActorEmoted(bot_entidx, who, concept);
		}
	}
#endif
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

public void SetDefaultValuesToZeroNPC(int entity)
{
#if defined ZR
	i_SpawnProtectionEntity[entity] = -1;
	i_TeamGlow[entity] = -1;
	b_thisNpcHasAnOutline[entity] = false;
	b_ThisNpcIsImmuneToNuke[entity] = false;
	b_ThisNpcIsSawrunner[entity] = false;
#endif
	
#if defined RPG
	f3_SpawnPosition[entity][0] = 0.0;
	f3_SpawnPosition[entity][1] = 0.0;
	f3_SpawnPosition[entity][2] = 0.0;
	hFromSpawnerIndex[entity] = -1;
	i_NpcIsUnderSpawnProtectionInfluence[entity] = 0;
	b_DungeonContracts_BleedOnHit[entity] = false;
	b_DungeonContracts_ZombieSpeedTimes3[entity] = false;
	b_DungeonContracts_ZombieFlatArmorMelee[entity] = false;
	b_DungeonContracts_ZombieFlatArmorRanged[entity] = false;
	b_DungeonContracts_ZombieFlatArmorMage[entity] = false;
	b_DungeonContracts_ZombieArmorDebuffResistance[entity] = false;
	b_DungeonContracts_35PercentMoreDamage[entity] = false;
	b_DungeonContracts_25PercentMoreDamage[entity] = false;
#endif
	f_NpcHasBeenUnstuckAboveThePlayer[entity] = 0.0;
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

	b_DissapearOnDeath[entity] = false;
	b_IsGiant[entity] = false;
	b_Pathing[entity] = false;
	b_Jumping[entity] = false;
	b_AllowBackWalking[entity] = false;
	fl_JumpStartTime[entity] = 0.0;
	fl_JumpStartTimeInternal[entity] = 0.0;
	fl_JumpCooldown[entity] = 0.0;
	fl_NextDelayTime[entity] = 0.0;
	fl_NextThinkTime[entity] = 0.0;
	fl_NextRunTime[entity] = 0.0;
	fl_NextMeleeAttack[entity] = 0.0;
	fl_Speed[entity] = 0.0;
	i_Target[entity] = -1;
	fl_GetClosestTargetTime[entity] = 0.0;
	fl_GetClosestTargetNoResetTime[entity] = 0.0;
	fl_NextHurtSound[entity] = 0.0;
	fl_HeadshotCooldown[entity] = 0.0;
	b_CantCollidie[entity] = false;
	b_CantCollidieAlly[entity] = false;
	b_BuildingIsStacked[entity] = false;
	b_bBuildingIsPlaced[entity] = false;
	b_XenoInfectedSpecialHurt[entity] = false;
	fl_XenoInfectedSpecialHurtTime[entity] = 0.0;
	b_DoGibThisNpc[entity] = true;
	b_ThisEntityIgnored[entity] = false;
	fl_NextIdleSound[entity] = 0.0;
	fl_AttackHappensMinimum[entity] = 0.0;
	fl_AttackHappensMaximum[entity] = 0.0;
	b_AttackHappenswillhappen[entity] = false;
	b_thisNpcIsABoss[entity] = false;
	b_StaticNPC[entity] = false;
	b_NPCVelocityCancel[entity] = false;
	fl_DoSpawnGesture[entity] = 0.0;
	b_isWalking[entity] = true;
	i_StepNoiseType[entity] = 0;
	i_NpcStepVariation[entity] = 0;
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
	fl_NextRangedBarrage_Spam[entity] = 0.0;
	fl_NextRangedBarrage_Singular[entity] = 0.0;
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
	b_bThisNpcGotDefaultStats_INVERTED[entity] = false;
	b_isGiantWalkCycle[entity] = 1.0;
	i_Activity[entity] = -1;
	i_PoseMoveX[entity] = -1;
	i_PoseMoveY[entity] = -1;
	b_NpcHasDied[entity] = false;
	b_PlayHurtAnimation[entity] = false;
	i_CreditsOnKill[entity] = 0;
	b_npcspawnprotection[entity] = false;
	f_CooldownForHurtParticle[entity] = 0.0;
	f_LowTeslarDebuff[entity] = 0.0;
	f_HighTeslarDebuff[entity] = 0.0;
	f_WidowsWineDebuff[entity] = 0.0;
	f_VeryLowIceDebuff[entity] = 0.0;
	f_LowIceDebuff[entity] = 0.0;
	f_HighIceDebuff[entity] = 0.0;
	b_Frozen[entity] = false;
	f_TankGrabbedStandStill[entity] = 0.0;
	f_TimeFrozenStill[entity] = 0.0;
	f_MaimDebuff[entity] = 0.0;
	f_PassangerDebuff[entity] = 0.0;
	f_CrippleDebuff[entity] = 0.0;
	
	fl_MeleeArmor[entity] = 1.0; //yeppers.
	fl_RangedArmor[entity] = 1.0;
	f_PickThisDirectionForabit[entity] = 0.0;
	b_ScalesWithWaves[entity] = false;
	b_PernellBuff[entity] = false;
	IgniteFor[entity] = 0;
	f_StuckOutOfBoundsCheck[entity] = GetGameTime() + 2.0;
	f_StunExtraGametimeDuration[entity] = 0.0;
	i_TextEntity[entity][0] = -1;
	i_TextEntity[entity][1] = -1;
	i_TextEntity[entity][2] = -1;
	i_Changed_WalkCycle[entity] = -1;
#if defined ZR
	ResetFreeze(entity);
#endif
	FormatEx(c_HeadPlaceAttachmentGibName[entity], sizeof(c_HeadPlaceAttachmentGibName[]), "");
}

#if defined ZR
public void Raidboss_Clean_Everyone()
{
	int base_boss;
	while((base_boss=FindEntityByClassname(base_boss, "base_boss")) != -1)
	{
		if(IsValidEntity(base_boss))
		{
			if(GetEntProp(base_boss, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
			{
				if(!b_Map_BaseBoss_No_Layers[base_boss] && !b_IsAlliedNpc[base_boss]) //Make sure it doesnt actually kill map base_bosses
				{
					Change_Npc_Collision(base_boss, 1); //Gives raid collision
				}
			}
		}
	}
}
#endif

public void ArrowStartTouch(int arrow, int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
		int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
		SDKHooks_TakeDamage(entity, arrow, arrow, f_ArrowDamage[arrow], DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		EmitSoundToAll(g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], arrow, _, 80, _, 0.8, 100);
		if(IsValidEntity(arrow_particle))
		{
			DispatchKeyValue(arrow_particle, "parentname", "none");
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
			DispatchKeyValue(arrow_particle, "parentname", "none");
			AcceptEntityInput(arrow_particle, "ClearParent");
			float f3_PositionTemp[3];
			GetEntPropVector(arrow_particle, Prop_Data, "m_vecAbsOrigin", f3_PositionTemp);
			TeleportEntity(arrow_particle, f3_PositionTemp, NULL_VECTOR, {0.0,0.0,0.0});
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	RemoveEntity(arrow);
}

public MRESReturn Arrow_DHook_RocketExplodePre(int arrow)
{
//	PrintToChatAll("boom!");
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

public void Change_Npc_Collision(int npc, int CollisionType)
{
	if(IsValidEntity(npc))
	{
		Address pNB =		 SDKCall(g_hMyNextBotPointer,	   npc);
		Address pLocomotion = SDKCall(g_hGetLocomotionInterface, pNB);
		if(!DHookRemoveHookID(h_NpcCollissionHookType[npc]))
		{
			PrintToChatAll("FAILED HOOK REMOVAL");
		}
		else
		{
			switch(CollisionType)
			{
				case 1:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemyIngoreBuilding,   false, pLocomotion);
				}
				case 2:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyEnemy,   false, pLocomotion);
				}
				case 3:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAllyInvince,   false, pLocomotion);
				}
				case 4:
				{
					h_NpcCollissionHookType[npc] = DHookRaw(g_hShouldCollideWithAlly,   false, pLocomotion);
				}
			}	
		}
	}
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

/*
public MRESReturn Dhook_ResolveCollision_Pre()
{
	PrintToChatAll("-----");
	PrintToChatAll("1");
	return MRES_Ignored;
}

public MRESReturn Dhook_ResolveCollision_Post()
{
	PrintToChatAll("2");
	PrintToChatAll("-----");
	return MRES_Ignored;
}
*/

public bool Never_ShouldCollide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	return false;
} 

#if defined ZR
//TELEPORT IS SAFE? FROM SARYSA BUT EDITED FOR NPCS!
bool NPC_Teleport(int npc, float endPos[3] /*Where do we want to end up?*/)
{
	float sizeMultiplier = 1.0; //We do not want to teleport giants, yet.
	
	static float startPos[3];
	startPos = GetAbsOrigin(npc);

	startPos[2] += 25.0;

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
				TR_TraceRayFilter(endPos, testPos, MASK_NPCSOLID, RayType_EndPoint, TraceFilterClients);
				TR_GetEndPosition(tmpPos);
				if (testPos[0] != tmpPos[0] || testPos[1] != tmpPos[1] || testPos[2] != tmpPos[2])
					continue;
			}
		}
	}
	
	if (!IsSpotSafe(npc, testPos, sizeMultiplier))
		return false;

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
	ResizeMyTeam = GetEntProp(npc, Prop_Data, "m_iTeamNum");
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

	TR_TraceRayFilter(startPos, endPos, MASK_NPCSOLID, RayType_EndPoint, Resize_TracePlayersAndBuildings);
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
		if ((StrContains(classname, "obj_") == 0) || (strcmp(classname, "prop_dynamic") == 0) || (strcmp(classname, "func_door") == 0) || (strcmp(classname, "func_physbox") == 0) || (strcmp(classname, "base_boss") == 0) || (strcmp(classname, "func_breakable") == 0))
		{
			if(!b_ThisEntityIgnored[entity] && ResizeMyTeam != GetEntProp(entity, Prop_Data, "m_iTeamNum"))
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
		SDKHooks_TakeDamage(entity, 0, 0, 99999999.9);
	}
}

void FreezeNpcInTime(int npc, float Duration_Stun)
{
	float TimeSinceLastStunSubtract;
	TimeSinceLastStunSubtract = f_TimeSinceLastStunHit[npc] - GetGameTime();
			
	if(TimeSinceLastStunSubtract < 0.0)
	{
		TimeSinceLastStunSubtract = 0.0;
	}

	f_StunExtraGametimeDuration[npc] += (Duration_Stun - TimeSinceLastStunSubtract);
	fl_NextDelayTime[npc] = GetGameTime() + Duration_Stun - f_StunExtraGametimeDuration[npc];
	f_TimeFrozenStill[npc] = GetGameTime() + Duration_Stun - f_StunExtraGametimeDuration[npc];
	f_TimeSinceLastStunHit[npc] = GetGameTime() + Duration_Stun;
}