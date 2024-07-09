#pragma semicolon 1
#pragma newdecls required

enum struct RawHooks
{
	int Ref;
	int Pre;
	int Post;
}

static DynamicHook ForceRespawn;
static int ForceRespawnHook[MAXTF2PLAYERS];

#if !defined RENDER_TRANSCOLOR
static int GetChargeEffectBeingProvided;
//static bool Disconnecting;
static DynamicHook g_WrenchSmack;
//DynamicHook g_ObjStartUpgrading;
static DynamicHook g_DHookScoutSecondaryFire; 
#endif

#if defined ZR
static bool IsRespawning;
#endif
//static DynamicDetour gH_MaintainBotQuota = null;
static DynamicHook g_DHookGrenadeExplode; //from mikusch but edited
static DynamicHook g_DHookGrenade_Detonate; //from mikusch but edited
static DynamicHook g_DHookFireballExplode; //from mikusch but edited
DynamicHook g_DhookUpdateTransmitState; 

static DynamicDetour g_CalcPlayerScore;

static Handle g_detour_CTFGrenadePipebombProjectile_PipebombTouch;

static bool Dont_Move_Building;											//dont move buildings
static bool Dont_Move_Allied_Npc;											//dont move buildings	
static int TeamBeforeChange;											//dont move buildings	

static bool b_LagCompNPC;

static DynamicHook HookItemIterateAttribute;
static ArrayList RawEntityHooks;
static int m_bOnlyIterateItemViewAttributes;
static int m_Item;
//Handle dHookCheckUpgradeOnHit;
/*
// Offsets from mikusch but edited
static int g_OffsetWeaponMode;
static int g_OffsetWeaponInfo;
static int g_OffsetWeaponPunchAngle;
*/

//#include <dhooks_gameconf_shim>

stock Handle CheckedDHookCreateFromConf(Handle game_config, const char[] name) {
    Handle res = DHookCreateFromConf(game_config, name);

    if (res == INVALID_HANDLE) {
        SetFailState("Failed to create detour for %s", name);
    }

    return res;
}

void DHook_Setup()
{
	GameData gamedata = LoadGameConfigFile("zombie_riot");
	
	if (!gamedata) 
	{
		SetFailState("Failed to load gamedata (zombie_riot).");
	} 
	/*
	else if (!ReadDHooksDefinitions("zombie_riot")) 
	{
		SetFailState("Failed to read DHooks definitions (zombie_riot).");
	}
	*/
	
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);

	//https://github.com/Wilzzu/testing/blob/18a3680a9a1c8bdabc30c504bbf9467ac6e7d7b4/samu/addons/sourcemod/scripting/shavit-replay.sp
	/*
	if (!(gH_MaintainBotQuota = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address)))
	{
		SetFailState("Failed to create detour for BotManager::MaintainBotQuota");
	}

	if (!DHookSetFromConf(gH_MaintainBotQuota, gamedata, SDKConf_Signature, "BotManager::MaintainBotQuota"))
	{
		SetFailState("Failed to get address for BotManager::MaintainBotQuota");
	}

	gH_MaintainBotQuota.Enable(Hook_Pre, Detour_MaintainBotQuota);
	*/
	
#if !defined RTS
	DHook_CreateDetour(gamedata, "CTFPlayer::GetChargeEffectBeingProvided", DHook_GetChargeEffectBeingProvidedPre, DHook_GetChargeEffectBeingProvidedPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::ManageRegularWeapons()", DHook_ManageRegularWeaponsPre, DHook_ManageRegularWeaponsPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::RegenThink", DHook_RegenThinkPre, DHook_RegenThinkPost);
#endif

#if !defined RTS
	DHook_CreateDetour(gamedata, "CTFPlayer::RemoveAllOwnedEntitiesFromWorld", DHook_RemoveAllOwnedEntitiesFromWorldPre, DHook_RemoveAllOwnedEntitiesFromWorldPost);
	g_DHookMedigunPrimary = DHook_CreateVirtual(gamedata, "CWeaponMedigun::PrimaryAttack()");
#endif

#if defined ZR
	DHook_CreateDetour(gamedata, "CTFProjectile_HealingBolt::ImpactTeamPlayer()", OnHealingBoltImpactTeamPlayer, _);
	g_DHookMedigunPrimary = DHook_CreateVirtual(gamedata, "CWeaponMedigun::PrimaryAttack()");
//	DHook_CreateDetour(gamedata, "CTFBuffItem::RaiseFlag", Dhook_RaiseFlag_Pre); 
//	64BIT UPDATE BROKE THIS ENTIRELY. IT IS UNSUABLE AND CAUSES A NULL POINTER CRASH!

	DHook_CreateDetour(gamedata, "CTFBuffItem::BlowHorn", _, Dhook_BlowHorn_Post);
	DHook_CreateDetour(gamedata, "CTFPlayerShared::PulseRageBuff()", Dhook_PulseFlagBuff,_);

//	DHook_CreateDetour(gamedata, "CTeamplayRoundBasedRules::ResetPlayerAndTeamReadyState", DHook_ResetPlayerAndTeamReadyStatePre);
//  64BIT UPDATE BROKE THIS ENTIRELY. IT IS UNSUABLE AND CAUSES A NULL POINTER CRASH!
#endif
	DHook_CreateDetour(gamedata, "CTFWeaponBaseMelee::DoSwingTraceInternal", DHook_DoSwingTracePre, _);
	DHook_CreateDetour(gamedata, "CWeaponMedigun::CreateMedigunShield", DHook_CreateMedigunShieldPre, _);
	DHook_CreateDetour(gamedata, "CTFGCServerSystem::PreClientUpdate", DHook_PreClientUpdatePre, DHook_PreClientUpdatePost);
	
	g_DHookGrenadeExplode = DHook_CreateVirtual(gamedata, "CBaseGrenade::Explode");
	g_DHookGrenade_Detonate = DHook_CreateVirtual(gamedata, "CBaseGrenade::Detonate");
	
#if !defined RTS
	g_WrenchSmack = DHook_CreateVirtual(gamedata, "CTFWrench::Smack()");
	DHook_CreateDetour(gamedata, "CTFPlayer::SpeakConceptIfAllowed()", SpeakConceptIfAllowed_Pre, SpeakConceptIfAllowed_Post);

	g_DHookScoutSecondaryFire = DHook_CreateVirtual(gamedata, "CTFPistol_ScoutPrimary::SecondaryAttack()");
#endif
	g_detour_CTFGrenadePipebombProjectile_PipebombTouch = CheckedDHookCreateFromConf(gamedata, "CTFGrenadePipebombProjectile::PipebombTouch");
	
	
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	g_DHookFireballExplode = DHook_CreateVirtual(gamedata, "CTFProjectile_SpellFireball::Explode");

	int offset = gamedata.GetOffset("CBaseEntity::UpdateTransmitState()");
	g_DhookUpdateTransmitState = new DynamicHook(offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity);
	if (!g_DhookUpdateTransmitState)
	{
		SetFailState("Failed to create hook CBaseEntity::UpdateTransmitState() offset from ZR gamedata!");
	}
	
	ForceRespawn = DynamicHook.FromConf(gamedata, "CBasePlayer::ForceRespawn");
	if(!ForceRespawn)
		LogError("[Gamedata] Could not find CBasePlayer::ForceRespawn");
	
#if !defined RTS
	Handle dtWeaponFinishReload = DHookCreateFromConf(gamedata, "CBaseCombatWeapon::FinishReload()");
	if (!dtWeaponFinishReload) {
		SetFailState("Failed to create detour %s", "CBaseCombatWeapon::FinishReload()");
	}
	DHookEnableDetour(dtWeaponFinishReload, false, OnWeaponReplenishClipPre);
	DHookEnableDetour(dtWeaponFinishReload, true, OnWeaponReplenishClipPost);
#endif
	
	// from https://github.com/shavitush/bhoptimer/blob/b78ae36a0ef72d15620d2b18017bbff18d41b9fc/addons/sourcemod/scripting/shavit-misc.sp
	
	if (!(g_CalcPlayerScore = DHookCreateDetour(Address_Null, CallConv_CDECL, ReturnType_Int, ThisPointer_Ignore)))
	{
		SetFailState("Failed to create detour for CTFGameRules::CalcPlayerScore");
	}
	if (DHookSetFromConf(g_CalcPlayerScore, gamedata, SDKConf_Signature, "CTFGameRules::CalcPlayerScore"))
	{
		g_CalcPlayerScore.AddParam(HookParamType_Int);
		g_CalcPlayerScore.AddParam(HookParamType_CBaseEntity);
		g_CalcPlayerScore.Enable(Hook_Pre, Detour_CalcPlayerScore);
	}

	HookItemIterateAttribute = DynamicHook.FromConf(gamedata, "CEconItemView::IterateAttributes");

	m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, m_bOnlyIterateItemViewAttributes);
	
	delete gamedata;
	
	GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");

	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre, StartLagCompensationPost);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FrameUpdatePostEntityThink_SIGNATURE", _, LagCompensationThink);
	
	delete gamedata_lag_comp;
	/*
	GameData edictgamedata = LoadGameConfigFile("edict_limiter");
	//	https://github.com/sapphonie/tf2-edict-limiter/releases/tag/v3.0.4)
	//	Due to zr's nature of spawning lots of enemies, it can cause issues if they die way too fast, this is a fix.
	//	Patch TF2 not reusing edict slots and crashing with a ton of free slots
	{
		MemoryPatch ED_Alloc_IgnoreFree = MemoryPatch.CreateFromConf(edictgamedata, "ED_Alloc::nop");
		if (!ED_Alloc_IgnoreFree.Validate())
		{
			SetFailState("Failed to verify ED_Alloc::nop.");
		}
		else if (ED_Alloc_IgnoreFree.Enable())
		{
			LogMessage("-> Enabled ED_Alloc::nop.");
		}
		else
		{
			SetFailState("Failed to enable ED_Alloc::nop.");
		}
	}
	delete edictgamedata;
	*/
//	int ED_AllocCommentedOut;
}


void DHook_EntityDestoryed()
{
	RequestFrame(DHook_EntityDestoryedFrame);
}

public void DHook_EntityDestoryedFrame()
{
	if(RawEntityHooks)
	{
		int length = RawEntityHooks.Length;
		if(length)
		{
			RawHooks raw;
			for(int i; i < length; i++)
			{
				RawEntityHooks.GetArray(i, raw);
				if(!IsValidEntity(raw.Ref))
				{
					if(raw.Pre != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Pre);
					
					if(raw.Post != INVALID_HOOK_ID)
						DynamicHook.RemoveHook(raw.Post);
					
					RawEntityHooks.Erase(i--);
					length--;
				}
			}
		}
	}
}

stock void DHook_HookStripWeapon(int entity)
{
	if(m_Item > 0 && m_bOnlyIterateItemViewAttributes > 0)
	{
		if(!RawEntityHooks)
			RawEntityHooks = new ArrayList(sizeof(RawHooks));
		
		Address pCEconItemView = GetEntityAddress(entity) + view_as<Address>(m_Item);
		
		RawHooks raw;
		
		raw.Ref = EntIndexToEntRef(entity);
		raw.Pre = HookItemIterateAttribute.HookRaw(Hook_Pre, pCEconItemView, DHook_IterateAttributesPre);
		raw.Post = HookItemIterateAttribute.HookRaw(Hook_Post, pCEconItemView, DHook_IterateAttributesPost);
		
		RawEntityHooks.PushArray(raw);
	}
}

public MRESReturn DHook_IterateAttributesPre(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), true, NumberType_Int8);
	return MRES_Ignored;
}

public MRESReturn DHook_IterateAttributesPost(Address pThis, DHookParam hParams)
{
	StoreToAddress(pThis + view_as<Address>(m_bOnlyIterateItemViewAttributes), false, NumberType_Int8);
	return MRES_Ignored;
}

//cancel melee, we have our own.
public MRESReturn DHook_DoSwingTracePre(int entity, DHookReturn returnHook, DHookParam param)
{
	returnHook.Value = false;
	return MRES_Supercede;
}

public MRESReturn DHook_CreateMedigunShieldPre(int entity, DHookReturn returnHook)
{
	return MRES_Supercede;
}

static bool wasMvM;
public MRESReturn DHook_PreClientUpdatePre()
{
	wasMvM = view_as<bool>(GameRules_GetProp("m_bPlayingMannVsMachine"));
	if(wasMvM)
		GameRules_SetProp("m_bPlayingMannVsMachine", false);
	
	return MRES_Ignored;
}

public MRESReturn DHook_PreClientUpdatePost()
{
	if(wasMvM)
		GameRules_SetProp("m_bPlayingMannVsMachine", wasMvM);
	
	return MRES_Ignored;
}

#if !defined RTS
void OnWrenchCreated(int entity) 
{
	g_WrenchSmack.HookEntity(Hook_Pre, entity, Wrench_SmackPre);
	g_WrenchSmack.HookEntity(Hook_Post, entity, Wrench_SmackPost);
}
static float f_TeleportedPosWrenchSmack[MAXENTITIES][3];
int WhatWasMVMBefore_DHook_CheckUpgradeOnHitPre;

public MRESReturn Wrench_SmackPre(int entity, DHookReturn ret, DHookParam param)
{	
	WhatWasMVMBefore_DHook_CheckUpgradeOnHitPre = GameRules_GetProp("m_bPlayingMannVsMachine");
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
	StartLagCompResetValues();
	Dont_Move_Building = true;
	Dont_Move_Allied_Npc = false;
	int Compensator = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	LagCompEntitiesThatAreIntheWay(Compensator);

	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied))
		{
			GetEntPropVector(baseboss_index_allied, Prop_Data, "m_vecAbsOrigin", f_TeleportedPosWrenchSmack[baseboss_index_allied]);
			SDKCall_SetLocalOrigin(baseboss_index_allied, OFF_THE_MAP_NONCONST);
		}
	}
	return MRES_Ignored;
}

public MRESReturn Wrench_SmackPost(int entity, DHookReturn ret, DHookParam param)
{	
	FinishLagCompMoveBack();
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied))
		{
			SDKCall_SetLocalOrigin(baseboss_index_allied, f_TeleportedPosWrenchSmack[baseboss_index_allied]);
		}
	}
	GameRules_SetProp("m_bPlayingMannVsMachine", WhatWasMVMBefore_DHook_CheckUpgradeOnHitPre);
	return MRES_Ignored;
}
#endif

//NEVER upgrade buildings, EVER.
/*
public MRESReturn ObjStartUpgrading_SmackPre(int entity, DHookReturn ret, DHookParam param)
{	
	SetEntProp(entity, Prop_Send, "m_iUpgradeMetal", 199); //just incase.
	return MRES_Supercede;
}
*/



//Thanks to rafradek#0936 on the allied modders discord for pointing this function out!
//This changes player classes to the correct one.
#if !defined RTS
public MRESReturn SpeakConceptIfAllowed_Pre(int client, Handle hReturn, Handle hParams)
{
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{

#if defined ZR
		if(IsClientInGame(client_2) && !TeutonType[client_2])
#else
		if(IsClientInGame(client_2))
#endif

		{
			if(!CurrentClass[client_2])
			{
				CurrentClass[client_2] = TFClass_Scout;
			}
			TF2_SetPlayerClass_ZR(client_2, CurrentClass[client_2], false, false);
		}
	}
	return MRES_Ignored;
}
public MRESReturn SpeakConceptIfAllowed_Post(int client, Handle hReturn, Handle hParams)
{
	for(int client_2=1; client_2<=MaxClients; client_2++)
	{
		
#if defined ZR
		if(IsClientInGame(client_2) && !TeutonType[client_2])
#else
		if(IsClientInGame(client_2))
#endif

		{
			#if defined ZR
				if(GetEntProp(client_2, Prop_Send, "m_iHealth") > 0 || TeutonType[client_2] != TEUTON_NONE) //otherwise death sounds dont work.
			#else
				if(GetEntProp(client_2, Prop_Send, "m_iHealth") > 0)
			#endif

				{
					if(!WeaponClass[client_2])
					{
						WeaponClass[client_2] = TFClass_Scout;
					}
					TF2_SetPlayerClass_ZR(client_2, WeaponClass[client_2], false, false);
				}
		}
	}
	return MRES_Ignored;
}
#endif

MRESReturn Detour_CalcPlayerScore(DHookReturn hReturn, DHookParam hParams)
{
	/*
	int client = hParams.Get(2);

#if !defined RTS
	int iScore = PlayerPoints[client];
#endif

#if defined RPG
	int iScore = Level[client];
#endif
	
	hReturn.Value = iScore;
	*/
	//make strange point gain not possible
	hReturn.Value = 0;
	return MRES_Supercede;
}

public void ApplyExplosionDhook_Pipe(int entity, bool Sticky)
{
	g_DHookGrenadeExplode.HookEntity(Hook_Pre, entity, DHook_GrenadeExplodePre);
	g_DHookGrenade_Detonate.HookEntity(Hook_Pre, entity, DHook_GrenadeDetonatePre);
	DHookEntity(g_detour_CTFGrenadePipebombProjectile_PipebombTouch, false, entity, _, GrenadePipebombProjectile_PipebombTouch);
	
	if(Sticky)
	{
		SDKHook(entity, SDKHook_StartTouch, SdkHook_StickStickybombToBaseBoss);
	}
	
	//Hacky? yes, But i gotta.
	
	//I have to do it twice, if its a custom spawn i have to do it insantly, if its a tf2 spawn then i have to do it seperatly.
}

stock void PipeApplyDamageCustom(int entity)
{
	f_CustomGrenadeDamage[entity] = GetEntPropFloat(entity, Prop_Send, "m_flDamage");
}

stock void See_Projectile_Team_Player(int entity)
{
	if (entity < 0 || entity > 2048)
	{
		entity = EntRefToEntIndex(entity);
	}
	if (IsValidEntity(entity))
	{
		if(GetTeam(entity) == view_as<int>(TFTeam_Red))
		{
			b_Is_Player_Projectile_Through_Npc[entity] = true;	 //try this
			//Update: worked! Will now pass through players/teammates
			//Nice.
		}	
	}
}

public Action SdkHook_StickStickybombToBaseBoss(int entity, int other)
{
	if(!GetEntProp(entity, Prop_Send, "m_bTouched"))
	{
		if(!b_StickyIsSticking[entity] && !b_NpcHasDied[other])
		{
			//Dont stick if it already has max.
			for (int i = 0; i < MAXSTICKYCOUNTTONPC; i++)
			{
				if (EntRefToEntIndex(i_StickyToNpcCount[other][i]) <= 0)
				{
					i_StickyToNpcCount[other][i] = EntIndexToEntRef(entity);
					i = MAXSTICKYCOUNTTONPC;
					
					SetEntProp(entity, Prop_Send, "m_bTouched", true);
					SetParent(other, entity);
					b_StickyIsSticking[entity] = true;
				}
			}
		}
	}
	return Plugin_Continue;
}

static float Velocity_Rocket[MAXENTITIES][3];

public void ApplyExplosionDhook_Rocket(int entity)
{
//	SetEntProp(entity, Prop_Send, "m_flDestroyableTime", GetGameTime());
	if(!b_EntityIsArrow[entity] && !b_EntityIsWandProjectile[entity]) //No!
	{
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, DHook_RocketExplodePre);
	}
	CreateTimer(1.0, FixVelocityStandStillRocket, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//Heavily increace thedelay, this rarely ever happens, and if it does, then it should check every 2 seconds at the most!
}


public Action FixVelocityStandStillRocket(Handle Timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (IsValidEntity(entity))
	{
		float Velocity_Temp[3];
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", Velocity_Temp); 
		if(Velocity_Temp[0] == 0.0 && Velocity_Temp[1] == 0.0 && Velocity_Temp[2] == 0.0)
		{
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, Velocity_Rocket[entity]);
		}
		else
		{
			Velocity_Rocket[entity][0] = Velocity_Temp[0];
			Velocity_Rocket[entity][1] = Velocity_Temp[1];
			Velocity_Rocket[entity][2] = Velocity_Temp[2];
		}
		
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}


public void ApplyExplosionDhook_Fireball(int entity)
{
	g_DHookFireballExplode.HookEntity(Hook_Pre, entity, DHook_FireballExplodePre);
// g_DHookFireballExplode
}

public void IsCustomTfGrenadeProjectile(int entity, float damage) //I cant make custom grenades work, so ill just use this logic, works just as good.
{
	f_CustomGrenadeDamage[entity] = damage;
}



static MRESReturn GrenadePipebombProjectile_PipebombTouch(int self, Handle params) 
{
	int other = DHookGetParam(params, 1);

	bool result = PassfilterGlobal(self, other, true);

	if(!result)
	{
		return MRES_Supercede;
	}
	return MRES_Ignored;
}
/*
	GrenadePipebombProjectile_PipebombTouch is from From:
	
	https://github.com/aarmastah/zesty-tf2-servers/blob/a96250f1c41c96ff10bf5b35e209095769f28d22/tf2/tf/addons/sourcemod/scripting/tf2-comp-fixes/projectiles-ignore-teammates.sp
	
	Because im too stupid to do it myself.
*/
public MRESReturn DHook_GrenadeExplodePre(int entity)
{
	if(IsValidEntity(entity))
	{
		DoGrenadeExplodeLogic(entity);
		RemoveEntity(entity);
		return MRES_Supercede;
	}
	else
	{
		return MRES_Ignored;
	}
}

public MRESReturn DHook_GrenadeDetonatePre(int entity)
{
	if(IsValidEntity(entity))
	{
		DoGrenadeExplodeLogic(entity);
		RemoveEntity(entity);
		return MRES_Supercede;
	}
	else
	{
		return MRES_Ignored;
	}
}

float f_SameExplosionSound[MAXENTITIES];
void DoGrenadeExplodeLogic(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
	//do not allow normal explosion, this causes screenshake, which in zr is a problem as many happen, and can cause headaches.
	float GrenadePos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", GrenadePos);
	bool DoNotPlay = false;

	if(IsValidEntity(owner))
	{
		if(f_SameExplosionSound[owner] == GetGameTime())
			DoNotPlay = true;
		
		//prevent insanely loud explosion sounds.
		if(!DoNotPlay)
		{
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					EmitAmbientSound(")weapons/pipe_bomb1.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
				}
				case 2:
				{
					EmitAmbientSound(")weapons/pipe_bomb2.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
				}
				case 3:
				{
					EmitAmbientSound(")weapons/pipe_bomb3.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
				}
			}
		}
		if(!DoNotPlay)
		{
			f_SameExplosionSound[owner] = GetGameTime();
		}
	}
	else
	{
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				EmitAmbientSound("weapons/explode1.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
			case 2:
			{
				EmitAmbientSound("weapons/explode2.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
			case 3:
			{
				EmitAmbientSound("weapons/explode3.wav", GrenadePos, _, 85, _,0.9, GetRandomInt(95, 105));
			}
		}
	}
	TE_Particle("ExplosionCore_MidAir", GrenadePos, NULL_VECTOR, NULL_VECTOR, 
	_, _, _, _, _, _, _, _, _, _, 0.0);
	if (0 < owner <= MaxClients)
	{
		if(f_CustomGrenadeDamage[entity] < 999999.9)
		{
			float original_damage = GetEntPropFloat(entity, Prop_Send, "m_flDamage"); 
			if(f_CustomGrenadeDamage[entity] > 1.0)
			{
				original_damage = f_CustomGrenadeDamage[entity];
			}
			else
			{
				original_damage *= 1.666666666666666;
			}
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
			Explode_Logic_Custom(original_damage, owner, entity, weapon);
		}
		else
		{
			return;
		}
	}
	else if(owner > MaxClients)
	{
		if(f_CustomGrenadeDamage[entity] < 999999.9)
		{
			float original_damage = GetEntPropFloat(entity, Prop_Send, "m_flDamage"); 
			if(f_CustomGrenadeDamage[entity] > 1.0)
			{
				original_damage = f_CustomGrenadeDamage[entity];
			}
			else
			{
				original_damage *= 1.666666666666666;
			}
			
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			
			//Important, make them not act as an ai if its on red, or else they are BUSTED AS FUCK.
			if(GetTeam(entity) != view_as<int>(TFTeam_Red))
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,true);	
			}
			else
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,false);
			}
		}
		else
		{
			return;
		}
	}
}

public MRESReturn DHook_FireballExplodePre(int entity)
{
	int owner = GetOwnerLoop(entity);
	if (0 < owner <= MaxClients)
	{
		int weapon;
		weapon = GetEntPropEnt(entity, Prop_Send, "m_hLauncher");
		if(f_CustomGrenadeDamage[entity] > 0.0)
		{
			Explode_Logic_Custom(f_CustomGrenadeDamage[entity], owner, entity, weapon, _, _, _, _, _, _, true);
		}
#if defined ZR
		else
		{
			int i, weapon1;
			while(TF2_GetItem(owner, weapon1, i))
			{
				if(i_CustomWeaponEquipLogic[weapon1] == WEAPON_FIRE_WAND)
				{
					float damage = 300.0;
					
					damage *= Attributes_Get(weapon1, 410, 1.0);
					
					Explode_Logic_Custom(damage, owner, entity, weapon1, _, _, _, _, _, _, true);
					break;
				}
			}
		}
#endif
	}

	return MRES_Ignored;
}

public MRESReturn DHook_RocketExplodePre(int entity)
{
	
	if(b_RocketBoomEffect[entity])
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (0 < owner  && owner <= MaxClients)
		{
			float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
			int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");

			int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
			if(!IsValidEntity(inflictor))
			{
				inflictor = 0;
			}
			Explode_Logic_Custom(original_damage, owner, entity, weapon,_,_,_,_,_,_,_,_,_,_,inflictor);
		}
		else if(owner > MaxClients)
		{
			float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
			int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
			if(!IsValidEntity(inflictor))
			{
				inflictor = 0;
			}
			if(GetTeam(entity) != view_as<int>(TFTeam_Red))
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,true,_,_,_,_,_,inflictor);	
			}
			else
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,false,_,_,_,_,_,inflictor);	
			}
		}
		RemoveEntity(entity);
		return MRES_Supercede;
	}
	else
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if (0 < owner  && owner <= MaxClients)
		{
			float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
			int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
			int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
			if(!IsValidEntity(inflictor))
			{
				inflictor = 0;
			}
			Explode_Logic_Custom(original_damage, owner, entity, weapon,_,_,_,_,_,_,_,_,_,_,inflictor);
		}
		else if(owner > MaxClients)
		{
			float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
			SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		//	int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		//Important, make them not act as an ai if its on red, or else they are BUSTED AS FUCK.
			int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
			if(!IsValidEntity(inflictor))
			{
				inflictor = 0;
			}
			if(GetTeam(entity) != view_as<int>(TFTeam_Red))
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,true,_,_,_,_,_,inflictor);	
			}
			else
			{
				Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,false,_,_,_,_,_,inflictor);	
			}
		}
	}
	return MRES_Ignored;
}
/*
public Action CH_ShouldCollide(int ent1, int ent2, bool &result)
{
	if(IsValidEntity(ent1) && IsValidEntity(ent2))
	{
		result = CustomDetectionPassFlter(ent1, ent2, true);
		if(result)
		{
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
*/


public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	if(ent1 >= 0 && ent1 <= MAXENTITIES && ent2 >= 0 && ent2 <= MAXENTITIES)
	{
		result = PassfilterGlobal(ent1, ent2, true);
		if(result)
		{
			return Plugin_Continue;
		}
		else
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public bool PassfilterGlobal(int ent1, int ent2, bool result)
{
	if(b_IsInUpdateGroundConstraintLogic)
	{
		if(b_ThisEntityIsAProjectileForUpdateContraints[ent1])
		{
			return false;
		}
		else if(b_ThisEntityIsAProjectileForUpdateContraints[ent2])
		{
			return false;
		}
		//We do not want this entity to step on anything aside from the actual world or entities that are treated as the world
	}
	//npc has died, ignore all collissions no matter what
	if(b_ThisWasAnNpc[ent1])
	{
		if(b_NpcHasDied[ent1])
			return false;
	}
	if(b_ThisWasAnNpc[ent2])
	{
		if(b_NpcHasDied[ent2])
			return false;
	}
	if(b_ThisEntityIgnoredEntirelyFromAllCollisions[ent1] || b_ThisEntityIgnoredEntirelyFromAllCollisions[ent2])
	{
#if defined RPG
		if(ent1 < MaxClients && ent2 < MaxClients)
		{
			if(RPGCore_PlayerCanPVP(ent1, ent2))
				return true;
		}
		return false;
#else
		return false;
#endif
	}	
	
	for( int ent = 1; ent <= 2; ent++ ) 
	{
		static int entity1;
		static int entity2; 	
		if(ent == 1)
		{
			entity1 = ent1;
			entity2 = ent2;
		}
		else
		{
			entity1 = ent2;
			entity2 = ent1;			
		}
#if !defined RTS
		if(b_ProjectileCollideIgnoreWorld[entity1])
		{
			Wand_Base_StartTouch(entity1, entity2);
			return false;
		}
#endif

#if defined ZR
		if(b_IsAGib[entity1]) //This is a gib that just collided with a player, do stuff! and also make it not collide.
		{
			if(entity2 <= MaxClients && entity2 > 0)
			{
				GibCollidePlayerInteraction(entity1, entity2);
				return false;
			}
			return false;
		}
#endif
		if(b_IsAProjectile[entity1] && GetTeam(entity1) != TFTeam_Red)
		{
			if(b_IsATrigger[entity2])
			{
				return false;
			}
			if(b_ThisEntityIgnored[entity2])
			{
				return false;
			}
			if(b_IsAProjectile[entity2])
			{
				return false;
			}
			if(GetTeam(entity2) == GetTeam(entity1))
			{
				return false;
			}
#if !defined RTS
			if(i_IsABuilding[entity2] && RaidbossIgnoreBuildingsLogic(2))
			{
				return false;
			}
#endif
		}

#if !defined RTS
		else if(b_IsAProjectile[entity1] && GetTeam(entity1) == TFTeam_Red)
		{
#if defined ZR
			if(b_ForceCollisionWithProjectile[entity2] && !b_EntityIgnoredByShield[entity1] && !IsEntitySpike(entity1))
#else
			if(b_ForceCollisionWithProjectile[entity2] && !b_EntityIgnoredByShield[entity1])
#endif
			{
				int EntityOwner = i_WandOwner[entity2];
				if(ShieldDeleteProjectileCheck(EntityOwner, entity1))
				{
					if(i_WandIdNumber[entity1] != 0)
					{
						//make it act as if it collided with the world.
						Wand_Base_StartTouch(entity1, 0);
					}
					else
					{
						//force a collision
						
						//We sadly cannot force a collision like this, but whatwe can do is manually call the collision with out own code.
						//This is only used for wands so place beware, we will just delete the entity.
						RemoveEntity(entity1);
					//	RequestFrame(Delete_FrameLater, EntIndexToEntRef(entity1));
					//	b_ThisEntityIgnoredEntirelyFromAllCollisions[entity1] = true;
						int entity_particle = EntRefToEntIndex(i_WandParticle[entity1]);
						if(IsValidEntity(entity_particle))
						{
							RemoveEntity(entity_particle);
						//	RequestFrame(Delete_FrameLater, EntIndexToEntRef(entity_particle));
						}						
					}
				}
				return false;
			}
			if(b_IsATrigger[entity2])
			{
				return false;
			}
			else if(b_IgnoredByPlayerProjectiles[entity2])
			{
				return false;
			}
			else if(b_ThisEntityIgnored[entity2])
			{
				return false;
			}
			else if(b_IsAProjectile[entity2])
			{
				return false;
			}
			//dont colldide with wsame team if its
			else if(GetTeam(entity2) == GetTeam(entity1) && !b_ProjectileCollideWithPlayerOnly[entity1])
			{
#if defined RPG
				if(!RPGCore_PlayerCanPVP(entity1, entity2))
					return false;
#else
					return false;
#endif	
			}
			//ally projectiles do not collide with players unless they only go for players
			else if(entity2 <= MaxClients && entity2 > 0 && !b_ProjectileCollideWithPlayerOnly[entity1])
			{
#if defined RPG
				if(!RPGCore_PlayerCanPVP(entity1, entity2))
					return false;
#else
					return false;
#endif	
			}
			//ignores everything else if it only collides with players
			else if(entity2 > MaxClients && b_ProjectileCollideWithPlayerOnly[entity1])
			{
#if defined RPG
				if(!RPGCore_PlayerCanPVP(entity1, entity2))
					return false;
#else
					return false;
#endif	
			}
		}
		else if (b_Is_Player_Projectile_Through_Npc[entity1])
		{
			if(!b_NpcHasDied[entity2] && GetTeam(entity2) != TFTeam_Red)
			{
				return false;
			}
		}
#endif	// Non-RTS
//enemy NPC
#if defined RTS
		if(!b_NpcHasDied[entity1])
#else	
		if(!b_NpcHasDied[entity1] && GetTeam(entity1) != TFTeam_Red)
#endif
		{
			//ignore buildings, neccecary during some situations
			if(i_IsABuilding[entity2])
			{
				if(RaidbossIgnoreBuildingsLogic(2) || b_NpcIgnoresbuildings[entity1])
				{
					return false;
				}
			}
			if(b_ThisEntityIgnored[entity2] && !DoingLagCompensation) //Only Ignore when not shooting/compensating, which is shooting only.
			{
				return false;
			}
			else if(IsEntityTowerDefense(entity1) && !DoingLagCompensation) //allow players to go through enemies here.
			{
				if(entity2 > 0 && entity2 <= MaxClients) 
				{
					return false;
				}
			}
#if defined RTS
			else if(!b_NpcHasDied[entity2])
#else
			else if(!b_NpcHasDied[entity2] && GetTeam(entity2) != TFTeam_Red)
#endif
			{
				return false;
			}
			else if (b_DoNotUnStuck[entity2])
			{
				return false;
			}
#if defined RPG
			else if((entity2 <= MaxClients && entity2 > 0) && (f_AntiStuckPhaseThrough[entity2] > GetGameTime() || OnTakeDamageRpgPartyLogic(entity1, entity2, GetGameTime())))
#else
			else if((entity2 <= MaxClients && entity2 > 0) && (f_AntiStuckPhaseThrough[entity2] > GetGameTime()))
#endif
			{
				//if a player needs to get unstuck.
				return false;
			}
		}
//allied NPC
#if !defined RTS
		else if(!b_NpcHasDied[entity1] && GetTeam(entity1) == TFTeam_Red)
		{
			//dont be solid to buildings
			if(i_IsABuilding[entity2] && GetTeam(entity2) == TFTeam_Red)
				return false;
			
			///????? i dont know
			if(!b_NpcHasDied[entity2] && GetTeam(entity2) == TFTeam_Red)
			{	
				if(!i_IsABuilding[entity2] && !i_IsABuilding[entity1])
					return false;
			}
			//lag comp stuff, shooting in specific
			else if((entity2 <= MaxClients && entity2 > 0) && !Dont_Move_Allied_Npc && !b_DoNotIgnoreDuringLagCompAlly[entity1])
			{
				return false;
			}
		}
#endif
	}
	return result;	
}
static DynamicHook DHook_CreateVirtual(GameData gamedata, const char[] name)
{
	DynamicHook hook = DynamicHook.FromConf(gamedata, name);
	if (!hook)
		LogError("Failed to create virtual: %s", name);
	
	return hook;
}

public void StartLagCompResetValues()
{
	Dont_Move_Building = false;
	Dont_Move_Allied_Npc = false;
	b_LagCompNPC = true;
	b_LagCompNPC_No_Layers = false;	
	b_LagCompNPC_AwayEnemies = false;
	b_LagCompNPC_ExtendBoundingBox = false;
	b_LagCompNPC_BlockInteral = false;
	b_LagCompNPC_OnlyAllies = false;
}

//if you find a way thats better to ignore fellow dispensers then tell me..!
public MRESReturn StartLagCompensationPre(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
//	PrintToChatAll("called %i",Compensator);
	StartLagCompResetValues();
	
	bool already_moved = false;
	if(b_LagCompAlliedPlayers) //This will ONLY compensate allies, so it wont do anything else! Very handy for optimisation.
	{
		b_LagCompNPC = true;
		b_LagCompNPC_ExtendBoundingBox = false;
		b_LagCompNPC_No_Layers = false;
		b_LagCompNPC_OnlyAllies = true;
		StartLagCompensation_Base_Boss(Compensator); //Compensate, but mostly allies.
		TeamBeforeChange = view_as<int>(GetEntProp(Compensator, Prop_Send, "m_iTeamNum")); //Hardcode to red as there will be no blue players.
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum", view_as<int>(TFTeam_Spectator)); //Hardcode to red as there will be no blue players.
		
		return MRES_Ignored;
	}
	
	
	int active_weapon = GetEntPropEnt(Compensator, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(active_weapon))
	{
		if(b_Dont_Move_Building[active_weapon])
		{
			Dont_Move_Building = true;
		}
		if(b_Dont_Move_Allied_Npc[active_weapon])
		{
			Dont_Move_Allied_Npc = true; //We presume this includes players too.
		}
		if(b_ExtendBoundingBox[active_weapon]) //Fat collision for hitting guranteed
		{
			b_LagCompNPC_ExtendBoundingBox = true;
		}
		if(b_BlockLagCompInternal[active_weapon]) //Fat collision for hitting guranteed
		{
			b_LagCompNPC_BlockInteral = true;
		}
		if(!b_Do_Not_Compensate[active_weapon])
		{
			b_LagCompNPC = false; //For guns that rapid fire or are melee as i do my own logic regarding that.
		}
		if(b_Only_Compensate_CollisionBox[active_weapon]) //This is mostly unused, but keep it for mediguns if needed. Otherwise kinda useless.
		{
			if(b_Only_Compensate_AwayPlayers[active_weapon])
			{
				b_LagCompNPC_AwayEnemies = true; //why was it not on true. I am really smart!
				already_moved = true;
				LagCompEntitiesThatAreIntheWay(Compensator); //Include this.
			}
			else
			{
				b_LagCompNPC_No_Layers = true; //why was it not on true. I am really smart!
			}
		}

		if(!already_moved)
		{
			LagCompEntitiesThatAreIntheWay(Compensator);
		}
	}
	if(b_LagCompNPC)
		StartLagCompensation_Base_Boss(Compensator);
	
	if(b_LagCompNPC_BlockInteral)
	{
#if !defined RTS
		TF2_SetPlayerClass_ZR(Compensator, TFClass_Scout, false, false); //Make sure they arent a medic during this! Reason: Mediguns lag comping, need both to be a medic and have a medigun
#endif
		LagCompMovePlayersExceptYou(Compensator);
	}
	
#if !defined RTS
	g_hSDKStartLagCompAddress = manager;
#endif
	
	return MRES_Ignored;
}
public MRESReturn StartLagCompensationPost(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
#if !defined RTS
	if(b_LagCompNPC_BlockInteral)
	{
		TF2_SetPlayerClass_ZR(Compensator, WeaponClass[Compensator], false, false); 
	//	return MRES_Supercede;
	}
#endif
	if(b_LagCompAlliedPlayers) //This will ONLY compensate allies, so it wont do anything else! Very handy for optimisation.
	{
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum", view_as<int>(TeamBeforeChange)); //Hardcode to red as there will be no blue players.
		return MRES_Ignored;
	} 
	return MRES_Ignored;
}


/*
THINGS I TRIED THAT DONT WORK!

Setting collision groups
Trying to pass through them via passfilter, it works but stops. probably cus the trace ends there... :(

*/

public void LagCompMovePlayersExceptYou(int player)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && client != player)
		{
			
#if defined ZR
			if (TeutonType[client] == TEUTON_NONE) 
#endif
			
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
			}
		}
	}
}

public void LagCompEntitiesThatAreIntheWay(int Compensator)
{
#if defined RTS
	if(!Dont_Move_Allied_Npc)
#endif
	
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && client != Compensator)
			{
				
#if defined ZR
				if (TeutonType[client] != TEUTON_NONE || (!Dont_Move_Allied_Npc)) 
#endif
				
				{
					b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
				}
			}
		}
	}
	if(!Dont_Move_Building)
	{
		int entity = -1;
		while((entity=FindEntityByClassname(entity, "obj_*")) != -1)
		{
			b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = true;
		}
	}

#if !defined RTS
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied) && GetTeam(baseboss_index_allied) == TFTeam_Red)
		{
			if(!Dont_Move_Allied_Npc || b_ThisEntityIgnored[baseboss_index_allied])
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[baseboss_index_allied] = true;
			}
		}
	}
#endif

	if(b_LagCompNPC_AwayEnemies)
	{
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++)
		{
			int baseboss = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount_again_2]);
			if (IsValidEntity(baseboss) && GetTeam(baseboss) != TFTeam_Red)
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[baseboss] = true;
			}
		}	
	}
}

public MRESReturn LagCompensationThink(Address manager)
{
	LagCompensationThink_Forward();
	return MRES_Ignored;
}
public void FinishLagCompMoveBack()
{
	b_LagCompAlliedPlayers = false;
	for (int entity = 0; entity < MAXENTITIES; entity++)
	{
		b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = false;
	}
	//Ultimate lazy
}

public MRESReturn FinishLagCompensation(Address manager, DHookParam param) //This code does not need to be touched. mostly.
{
//	PrintToChatAll("finish lag comp");
	//Set this to false to be sure.
	FinishLagCompMoveBack();
	
	if(b_LagCompNPC)
		FinishLagCompensation_Base_boss();
	
//	FinishLagCompensationResetValues();
	
#if !defined RTS
	g_hSDKEndLagCompAddress = manager;
	Sdkcall_Load_Lagcomp();
#endif

	StartLagCompResetValues();
	
	return MRES_Ignored;
//	return MRES_Supercede;
}

void DHook_HookClient(int client)
{

	if(ForceRespawn)
	{
		ForceRespawnHook[client] = ForceRespawn.HookEntity(Hook_Pre, client, DHook_ForceRespawn);
		
#if defined ZR
		dieingstate[client] = 0;
#endif
		
		CClotBody player = view_as<CClotBody>(client);
		player.m_bThisEntityIgnored = false;
	}
}

void DHook_UnhookClient(int client)
{
	if(ForceRespawn)
		DynamicHook.RemoveHook(ForceRespawnHook[client]);
	
}
/*
void DHook_ClientDisconnect()
{
	Disconnecting = true;
}

void DHook_ClientDisconnectPost()
{
	Disconnecting = false;
}
*/

#if defined ZR
void DHook_RespawnPlayer(int client)
{
	IsRespawning = true;
	TF2_RespawnPlayer(client);
	SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 0.0); //No cloak regen at all. Very important to set here!
	IsRespawning = false;
}
#endif

public MRESReturn DHook_CanAirDashPre(int client, DHookReturn ret)
{
#if defined RPG
	int current = GetEntProp(client, Prop_Send, "m_iAirDash");
	int max_Value = Attributes_Airdashes(client);

	if(TF2_IsPlayerInCondition(client, TFCond_CritHype))
		max_Value += 4;

	if(current < max_Value)
	{
		ret.Value = true;
		SetEntProp(client, Prop_Send, "m_iAirDash", current+1);
	}
	else
#endif
	
	{
		ret.Value = false;
	}
	return MRES_Supercede;
}

public MRESReturn DHook_DropAmmoPackPre(int client, DHookParam param)
{
	return MRES_Supercede;
}

public MRESReturn DHook_ForceRespawn(int client)
{
	if(IsFakeClient(client))
	{
#if !defined RTS
		int team = KillFeed_GetBotTeam(client);
		if(GetClientTeam(client) != team)
			ChangeClientTeam(client, team);
#endif
		TF2Util_SetPlayerRespawnTimeOverride(client, FAR_FUTURE);
		return MRES_Supercede;
	}
	
	if(GetClientTeam(client) != 2)
	{
		ChangeClientTeam(client, 2);
		return MRES_Supercede;
	}

#if defined RPG
	if(!Saves_HasCharacter(client))
		return MRES_Supercede;
	
	if(!Dungeon_CanClientRespawn(client))
		return MRES_Supercede;
#endif

#if defined ZR
	DoTutorialStep(client, false);
	SetTutorialUpdateTime(client, GetGameTime() + 1.0);
	
	TeutonType[client] = (!IsRespawning && !Waves_InSetup()) ? TEUTON_DEAD : TEUTON_NONE;
#endif

#if !defined RTS
	CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
	if(!CurrentClass[client])
	{
		CurrentClass[client] = TFClass_Scout;
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Scout);
	}
	
	WeaponClass[client] = TFClass_Unknown;
#endif
	
	DoOverlay(client, "", 2);
	
#if defined ZR
	if(!WaitingInQueue[client] && !GameRules_GetProp("m_bInWaitingForPlayers"))
		Queue_AddPoint(client);
	
	
	if(f_WasRecentlyRevivedViaNonWaveClassChange[client] > GetGameTime())
	{	
		return MRES_Ignored;
	}
	GiveCompleteInvul(client, 2.0);
	if(Waves_Started() && TeutonType[client] == TEUTON_NONE)
	{
		SetEntityHealth(client, 50);
		RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(client));
	}
	
	f_TimeAfterSpawn[client] = GetGameTime() + 1.0;
#endif
	
	CreateTimer(0.1, DHook_TeleportToAlly, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	return MRES_Ignored;
}

public Action DHook_TeleportToAlly(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
#if defined ZR
		GiveCompleteInvul(client, 2.0);
		if(f_WasRecentlyRevivedViaNonWave[client] < GetGameTime())
		{	
			if(Waves_Started())
			{
				int target = 0;
				for(int i=1; i<=MaxClients; i++)
				{
					if(i != client && IsClientInGame(i))
					{
						if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE && f_TimeAfterSpawn[i] < GetGameTime() && dieingstate[i] == 0) //dont spawn near players who just spawned
						{
							target = i;
							break;
						}
					}
				}
				if(target)
				{
					float pos[3], ang[3];
					GetEntPropVector(target, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(target, Prop_Data, "m_angRotation", ang);
					ang[2] = 0.0;
					SetEntProp(client, Prop_Send, "m_bDucked", true);
					SetEntityFlags(client, GetEntityFlags(client)|FL_DUCKING);
					TeleportEntity(client, pos, ang, NULL_VECTOR);
				}
			}
		}
#endif
		
#if defined RPG
		if(f3_SpawnPosition[client][0])
		{
			TeleportEntity(client, f3_SpawnPosition[client], NULL_VECTOR, NULL_VECTOR);
			f3_SpawnPosition[client][0] = 0.0;
		}
		else if(f3_PositionArrival[client][0])
		{
			TeleportEntity(client, f3_PositionArrival[client], NULL_VECTOR, NULL_VECTOR);
		}
#endif
	}
	return Plugin_Stop;
}

#if !defined RTS
public MRESReturn DHook_GetChargeEffectBeingProvidedPre(int client, DHookReturn ret)
{
	if(IsClientInGame(client) && !IsInsideManageRegularWeapons)
	{
		TF2_SetPlayerClass_ZR(client, TFClass_Medic, false, false);
		GetChargeEffectBeingProvided = client;
	}
	return MRES_Ignored;
}

public MRESReturn DHook_GetChargeEffectBeingProvidedPost(int client, DHookReturn ret)
{
	if(GetChargeEffectBeingProvided && !IsInsideManageRegularWeapons)
	{
		if(!IsValidClient(GetChargeEffectBeingProvided))
		{
			return MRES_Ignored;
		}
		if(WeaponClass[GetChargeEffectBeingProvided] > 0)
			TF2_SetPlayerClass_ZR(GetChargeEffectBeingProvided, WeaponClass[GetChargeEffectBeingProvided], false, false);
		GetChargeEffectBeingProvided = 0;
	}
	return MRES_Ignored;
}

bool WasMedicPreRegen[MAXTF2PLAYERS];

public MRESReturn DHook_RegenThinkPre(int client, DHookParam param)
{
	if(TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		WasMedicPreRegen[client] = true;
		TF2_SetPlayerClass_ZR(client, TFClass_Scout, false, false);
	}
	else
	{
		WasMedicPreRegen[client] = false;
	}

	return MRES_Ignored;
}

public MRESReturn DHook_RegenThinkPost(int client, DHookParam param)
{
	if(WasMedicPreRegen[client])
		TF2_SetPlayerClass_ZR(client, TFClass_Medic, false, false);
		
	WasMedicPreRegen[client] = false;
	return MRES_Ignored;
}
#endif	// Non-RTS

#if !defined RTS
static int LastTeam;
public MRESReturn DHook_RemoveAllOwnedEntitiesFromWorldPre(int client, DHookParam param)
{
	// Prevent buildings form disappearing
//	if(!Disconnecting)
	{
		LastTeam = GetTeam(client);
		SetEntProp(client, Prop_Send, "m_iTeamNum", TFTeam_Blue);
	}
	return MRES_Ignored;
}
#endif
/*
public MRESReturn DHookCallback_GameModeUsesUpgrades_Pre(DHookReturn ret)
{
	ret.Value = true;
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
	return MRES_Supercede;	
}
*/

/*
public Action Tank_OnGameModeUsesUpgrades(bool &result)
{
	PrintToChatAll("1");
	result = true;
	return Plugin_Changed;
}

public MRESReturn DHookCallback_GameModeUsesUpgrades_Post(DHookReturn ret)
{
	ret.Value = true;
//	GameRules_SetProp("m_bPlayingMannVsMachine", false);
	return MRES_Supercede;	
}
*/
#if !defined RTS
public MRESReturn DHook_RemoveAllOwnedEntitiesFromWorldPost(int client, DHookParam param)
{
//	if(!Disconnecting)
	{
		SetEntProp(client, Prop_Send, "m_iTeamNum", LastTeam);
	}
	return MRES_Ignored;
}
#endif

#if !defined RTS
/*
public MRESReturn DHook_TauntPre(int client, DHookParam param)
{
	//Dont allow taunting if disguised or cloaked
	if(TF2_IsPlayerInCondition(client, TFCond_Disguising) || TF2_IsPlayerInCondition(client, TFCond_Disguised) || TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		return MRES_Supercede;

	//Player wants to taunt, set class to whoever can actually taunt with active weapon
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon <= MaxClients)
		return MRES_Ignored;

	if(!b_TauntSpeedIncreace[client])
	{
		Attributes_Set(client, 201, 1.0);
		f_DelayAttackspeedPreivous[client] = 1.0;
	}
	
	//static char buffer[36];
	//GetEntityClassname(weapon, buffer, sizeof(buffer));
	//TFClassType class = TF2_GetWeaponClass(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"), CurrentClass[client], TF2_GetClassnameSlot(buffer));
	//if(class != TFClass_Unknown)
	{
		TF2_SetPlayerClass_ZR(client, WeaponClass[client], false, false);
	}

	return MRES_Ignored;
}
public MRESReturn DHook_TauntPost(int client, DHookParam param)
{
	//Set class back to what it was
	TF2_SetPlayerClass_ZR(client, WeaponClass[client], false, false);
	return MRES_Ignored;
}*/
#endif
/*
// g_bWarnedAboutMaxplayersInMVM
public MRESReturn PreClientUpdatePre(Handle hParams)
{
//	CvarTfMMMode.IntValue = 1;
	GameRules_SetProp("m_bPlayingMannVsMachine", true);
	return MRES_Ignored;
}

public MRESReturn PreClientUpdatePost(Handle hParams)
{
//	CvarTfMMMode.IntValue = 0;
	GameRules_SetProp("m_bPlayingMannVsMachine", false);
	return MRES_Ignored;
}
*/
#if defined ZR
public MRESReturn OnHealingBoltImpactTeamPlayer(int healingBolt, Handle hParams) {
	int originalLauncher = GetEntPropEnt(healingBolt, Prop_Send, "m_hOriginalLauncher");
	if (!IsValidEntity(originalLauncher)) {
		return MRES_Ignored;
	}
	
	RemoveEntity(healingBolt);
	
	// past this point we always supercede;
	// the attribute being present overrides any other behavior
	
	int owner = GetEntPropEnt(originalLauncher, Prop_Send, "m_hOwnerEntity");
	if (!IsValidEntity(owner)) {
		return MRES_Supercede;
	}
	
	
	int target = DHookGetParam(hParams, 1);
	
	int ammo_amount_left = GetAmmo(owner, 21);
	if(ammo_amount_left > 0)
	{
		float HealAmmount = 20.0;

		HealAmmount *= Attributes_GetOnPlayer(owner, 8, true, !Merchant_IsAMerchant(owner));
		

		
		float GameTime = GetGameTime();
		if(f_TimeUntillNormalHeal[target] > GameTime)
		{
			HealAmmount /= 4.0; //make sure they dont get the full benifit if hurt recently.
		}
		
		if(ammo_amount_left > RoundToCeil(HealAmmount))
		{
			ammo_amount_left = RoundToCeil(HealAmmount);
		}
		
		int flHealth = GetEntProp(target, Prop_Send, "m_iHealth");
		int flMaxHealth = SDKCall_GetMaxHealth(target);
		
		int Health_To_Max;
		
		Health_To_Max = flMaxHealth - flHealth;
		
		if(Health_To_Max <= 0 || Health_To_Max > flMaxHealth)
		{
			ClientCommand(owner, "playgamesound items/medshotno1.wav");
			SetGlobalTransTarget(owner);
			PrintHintText(owner,"%N %t", target, "Is already at full hp");
			
			Increaced_Overall_damage_Low[owner] = GameTime + 5.0;
			Increaced_Overall_damage_Low[target] = GameTime + 15.0;
			Resistance_Overall_Low[owner] = GameTime + 5.0;
			Resistance_Overall_Low[target] = GameTime + 15.0;
		}
		else
		{
			if(Health_To_Max < RoundToCeil(HealAmmount))
			{
				ammo_amount_left = Health_To_Max;
			}

			HealEntityGlobal(owner, target, float(ammo_amount_left), 1.0, 1.0, _);
			
			int new_ammo = GetAmmo(owner, 21) - ammo_amount_left;
			ClientCommand(owner, "playgamesound items/smallmedkit1.wav");
			ClientCommand(target, "playgamesound items/smallmedkit1.wav");
			SetGlobalTransTarget(owner);
			
			PrintHintText(owner, "%t", "You healed for", target, ammo_amount_left);
			SetAmmo(owner, 21, new_ammo);
			Increaced_Overall_damage_Low[owner] = GameTime + 5.0;
			Increaced_Overall_damage_Low[target] = GameTime + 15.0;
			Resistance_Overall_Low[owner] = GameTime + 5.0;
			Resistance_Overall_Low[target] = GameTime + 15.0;
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[owner][i] = GetAmmo(owner, i);
			}
		}
	}

	
	return MRES_Supercede;
}
#endif

#if !defined RTS
MRESReturn OnWeaponReplenishClipPost(int weapon)
{
	if(IsValidEntity(weapon))
	{
		DataPack pack = new DataPack();
		int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwner");
		pack.WriteCell(GetClientUserId(client));
		pack.WriteCell(EntIndexToEntRef(weapon));

#if defined ZR
		Update_Ammo(pack);
#endif

	}
	return MRES_Ignored;
}

MRESReturn OnWeaponReplenishClipPre(int weapon) // Not when the player press reload but when the weapon reloads
{
	if(IsValidEntity(weapon))
	{
		int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwner");
		Action action = Plugin_Continue;
		if(EntityFuncReload4[weapon] && EntityFuncReload4[weapon]!=INVALID_FUNCTION)
		{
			char classname[32];
			GetEntityClassname(weapon, classname, 32);
			Call_StartFunction(null, EntityFuncReload4[weapon]);
			Call_PushCell(client);
			Call_PushCell(weapon);
			Call_PushString(classname);
			Call_Finish(action);
		}
	}
	return MRES_Ignored;
	
}

void ScatterGun_Prevent_M2_OnEntityCreated(int entity)
{
	g_DHookScoutSecondaryFire.HookEntity(Hook_Pre, entity, DHook_ScoutSecondaryFire);
}
#endif	// Non-RTS


public MRESReturn DHook_ScoutSecondaryFire(int entity) //BLOCK!!
{
	return MRES_Supercede;	//NEVER APPLY. Causes you to not fire if accidentally pressing m2
}

public MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede;
}


//We want to disable them auto switching weapons during this, the reason being is that it messes with out custom equip logic, bad!

#if defined ZR
bool PersonInitiatedHornBlow[MAXTF2PLAYERS];
public MRESReturn Dhook_BlowHorn_Post(int entity)
{
	Attributes_Set(entity, 698, 1.0); // disable weapon switch
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(client))
	{
		PersonInitiatedHornBlow[client] = true;
	}
	return MRES_Ignored;
}

/*
	Issue: Dhook_RaiseFlag_Pre broke in the 64bit update, so i had to do this workaround :(

*/
public MRESReturn Dhook_PulseFlagBuff(Address pPlayerShared)
{
	int client = TF2Util_GetPlayerFromSharedAddress(pPlayerShared);

	if(PersonInitiatedHornBlow[client])
	{
		int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		if(viewmodel>MaxClients && IsValidEntity(viewmodel)) //For some reason it plays the horn anim again, just set it to idle!
		{
			int animation = 21; //should be default idle, modded viewmodels are fucked ig lol
			SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
		}
		
		//They successfully blew the horn! give them abit of credit for that! they helpinnnnnnn... yay
		i_ExtraPlayerPoints[client] += 15;
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			AncientBannerActivate(client, weapon);
			BuffBannerActivate(client, weapon);
			BuffBattilonsActivate(client, weapon);
		}
		RequestFrame(DelayEffectOnHorn, EntIndexToEntRef(client));
		Attributes_Set(weapon, 698, 0.0); // disable weapon switch
	}
	PersonInitiatedHornBlow[client] = false;
	return MRES_Supercede;
}

public MRESReturn Dhook_RaiseFlag_Pre(int entity)
{
	/*
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel)) //For some reason it plays the horn anim again, just set it to idle!
	{
		int animation = 21; //should be default idle, modded viewmodels are fucked ig lol
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	
	//They successfully blew the horn! give them abit of credit for that! they helpinnnnnnn... yay
	i_ExtraPlayerPoints[client] += 15;
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(weapon))
	{
		AncientBannerActivate(client, weapon);
		BuffBannerActivate(client, weapon);
		BuffBattilonsActivate(client, weapon);
	}
	RequestFrame(DelayEffectOnHorn, EntIndexToEntRef(client));
	*/

	
	Attributes_Set(entity, 698, 0.0); // disable weapon switch
	return MRES_Ignored;
}

stock void DelayEffectOnHorn(int ref)
{
	//i do not trust banner durations.
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return;

	float ExtendDuration = 10.0;

	ExtendDuration *= Attributes_GetOnPlayer(client, 319, true, false);

	if(b_AlaxiosBuffItem[client])
	{
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		ExtendDuration *= 1.5;
		EmitSoundToAll("mvm/mvm_tank_horn.wav", client, SNDCHAN_STATIC, 80, _, 0.45);
		
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 6.0, 6.1, 1);
	}

	f_BannerAproxDur[client] = GetGameTime() + ExtendDuration;
	f_BannerDurationActive[client] = GetGameTime() + 0.35;
	CreateTimer(0.15, TimerGrantBannerDuration, EntIndexToEntRef(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if(ExtendDuration <= (10.0 * BANNER_DURATION_FIX_FLOAT))
	{
		return;
	}
	ExtendDuration -= (9.0 * BANNER_DURATION_FIX_FLOAT);

	DataPack pack;
	CreateDataTimer(0.1, TimerSetBannerExtraDuration, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(client));
	pack.WriteFloat(ExtendDuration + GetGameTime());
	

	//"Expidonsan Battery Device"
}

int BannerWearable[MAXTF2PLAYERS];
int BannerWearableModelIndex[3];
void Dhooks_BannerMapstart()
{
	BannerWearableModelIndex[0]= PrecacheModel("models/weapons/c_models/c_buffbanner/c_buffbanner.mdl", true);
	BannerWearableModelIndex[1]= PrecacheModel("models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl", true);
	BannerWearableModelIndex[2]= PrecacheModel("models/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl", true);
}

public Action TimerGrantBannerDuration(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidClient(client))
		return Plugin_Stop;

	int entity;
	if(!GetEntProp(client, Prop_Send, "m_bRageDraining"))
	{
		//banner is over, delete.
		entity = EntRefToEntIndex(BannerWearable[client]);
		if(entity > MaxClients)
			TF2_RemoveWearable(client, entity);

		return Plugin_Stop;
	}

	f_BannerDurationActive[client] = GetGameTime() + 0.35;

	if(IsValidEntity(BannerWearable[client]))
	{
		return Plugin_Continue;
	}

	if(ClientHasBannersWithCD(client) == 0)
		return Plugin_Continue;

	entity = CreateEntityByName("tf_wearable");
	if(entity > MaxClients)
	{
		int team = GetClientTeam(client);
		SetEntProp(entity, Prop_Send, "m_nModelIndex", BannerWearableModelIndex[ClientHasBannersWithCD(client) -1]);

		SetEntProp(entity, Prop_Send, "m_fEffects", 129);
		SetTeam(entity, team);
		SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
		SetEntityCollisionGroup(entity, 11);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		
		DispatchSpawn(entity);
		SetVariantString("!activator");
		ActivateEntity(entity);

		BannerWearable[client] = EntIndexToEntRef(entity);
		SDKCall_EquipWearable(client, entity);
	}	
	return Plugin_Continue;
}

public Action TimerSetBannerExtraDuration(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidClient(client))
		return Plugin_Stop;
	
	float TimeUntillStopExtend = pack.ReadFloat();
	if(TimeUntillStopExtend < GetGameTime())
		return Plugin_Stop;

	SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 90.0);
	SetEntProp(client, Prop_Send, "m_bRageDraining", 1);

	return Plugin_Continue;
}
#endif	// ZR
/*
( INextBot *bot, const Vector &goalPos, const Vector &forward, const Vector &left )
*/

/*
public MRESReturn DHookGiveDefaultItems_Pre(int client, Handle hParams) 
{
	PrintToChatAll("%f DHookGiveDefaultItems_Pre::%d", GetEngineTime(), CurrentClass[client]);
	//TF2_SetPlayerClass_ZR(client, CurrentClass[client]);
	return MRES_Ignored;
}

public MRESReturn DHookGiveDefaultItems_Post(int client, Handle hParams) 
{
	PrintToChatAll("%f DHookGiveDefaultItems_Post::%d", GetEngineTime(), WeaponClass[client]);
	//TF2_SetPlayerClass_ZR(client, WeaponClass[client], false, false);
	return MRES_Ignored;
}
*/

#if !defined RTS
public MRESReturn DHook_ManageRegularWeaponsPre(int client, DHookParam param)
{
	// Gives our desired class's wearables
	IsInsideManageRegularWeapons = true;
	if(!CurrentClass[client])
	{
		CurrentClass[client] = TFClass_Scout;
	}
	TF2_SetPlayerClass_ZR(client, CurrentClass[client]);
	return MRES_Ignored;
}
public MRESReturn DHook_ManageRegularWeaponsPost(int client, DHookParam param)
{
	IsInsideManageRegularWeapons = false;
	return MRES_Ignored;
}
#endif

#define MAX_YAW_SHIELD_DELETE_SIDEWAY 25.0
stock bool ShieldDeleteProjectileCheck(int owner, int enemy)
{
	float pos1[3];
	float pos2[3];
	float ang3[3];
	float ang2[3];
	GetEntPropVector(owner, Prop_Data, "m_vecAbsOrigin", pos1);	
	GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", pos2);	

	GetVectorAnglesTwoPoints(pos2, pos1, ang3);
	GetEntPropVector(owner, Prop_Data, "m_angRotation", ang2);

	// fix all angles
	ang3[0] = fixAngle(ang3[0]);
	ang3[1] = fixAngle(ang3[1]);

	int Verify = 0;

	if(ang2[0] < 15.0 && ang2[0] > -15.0)
		Verify++;

	if(!(fabs(ang2[1] - ang3[1]) <= MAX_YAW_SHIELD_DELETE_SIDEWAY ||
	(fabs(ang2[1] - ang3[1]) >= (360.0-MAX_YAW_SHIELD_DELETE_SIDEWAY))))
		Verify++;

	if(Verify == 2)
		return true;

	return false;
}

void Hook_DHook_UpdateTransmitState(int entity)
{
	g_DhookUpdateTransmitState.HookEntity(Hook_Pre, entity, DHook_UpdateTransmitState);
}

public MRESReturn DHook_UpdateTransmitState(int entity, DHookReturn returnHook) //BLOCK!!
{
	if(b_IsEntityNeverTranmitted[entity])
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_DONTSEND);
	}
	else if(b_IsEntityAlwaysTranmitted[entity] || b_thisNpcIsABoss[entity])
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_ALWAYS);
	}
#if !defined RTS
	else if(!b_ThisEntityIgnored_NoTeam[entity] && GetTeam(entity) == TFTeam_Red)
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_ALWAYS);
	}
#endif
#if defined ZR
	else if(b_thisNpcHasAnOutline[entity])
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_ALWAYS);
	}
	else if (!b_NpcHasDied[entity] && Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_ALWAYS);
	}
#endif
	else
	{
		returnHook.Value = SetEntityTransmitState(entity, FL_EDICT_PVSCHECK);
	}
	return MRES_Supercede;
}

int SetEntityTransmitState(int entity, int newFlags)
{
	if (!IsValidEdict(entity))
	{
		return 0;
	}

	int flags = GetEdictFlags(entity);
	flags &= ~(FL_EDICT_ALWAYS | FL_EDICT_PVSCHECK | FL_EDICT_DONTSEND);
	flags |= newFlags;
	SetEdictFlags(entity, flags);

	return flags;
}
