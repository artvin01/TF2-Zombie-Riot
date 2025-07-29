#pragma semicolon 1
#pragma newdecls required

enum struct RawHooks
{
	int Ref;
	int Pre;
	int Post;
}

static DynamicHook ForceRespawn;
static int ForceRespawnHook[MAXPLAYERS];
Handle g_DhookWantsLagCompensationOnEntity;

static int GetChargeEffectBeingProvided;
static DynamicHook g_DHookScoutSecondaryFire; 

#if defined ZR
static bool IsRespawning;
#endif
static DynamicHook g_DHookGrenadeExplode; //from mikusch but edited
static DynamicHook g_DHookGrenade_Detonate; //from mikusch but edited
static DynamicHook g_DHookFireballExplode; //from mikusch but edited
static DynamicHook g_DhookCrossbowHolster;
DynamicHook g_DhookUpdateTransmitState; 

static Handle g_detour_CTFGrenadePipebombProjectile_PipebombTouch;
static bool Dont_Move_Building;											//dont move buildings
static bool Dont_Move_Allied_Npc;											//dont move buildings	
static bool b_LagCompNPC;

static DynamicHook HookItemIterateAttribute;
static ArrayList RawEntityHooks;
static int m_bOnlyIterateItemViewAttributes;
static int m_Item;
static bool GrenadeExplodedAlready[MAXENTITIES];
Handle g_hSDKLoadEvents;
Handle g_hSDKReloadEvents;
Address g_aGameEventManager;


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
	
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);
	
#if !defined RTS
	DHook_CreateDetour(gamedata, "CTFPlayer::GetChargeEffectBeingProvided", DHook_GetChargeEffectBeingProvidedPre, DHook_GetChargeEffectBeingProvidedPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::ManageRegularWeapons()", DHook_ManageRegularWeaponsPre, DHook_ManageRegularWeaponsPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::RegenThink", DHook_RegenThinkPre, DHook_RegenThinkPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::Taunt", DHook_TauntPre, DHook_TauntPost);

	//Borrowed from Mikusch, thanks!
	//https://github.com/Mikusch/MannVsMann/blob/db821cd173a53aad4cc499babbcbd118f4cea234/addons/sourcemod/scripting/mannvsmann/dhooks.sp#L315
	//

	//prevents having 200 metal permanently
	DHook_CreateDetour(gamedata, "CTFGameRules::IsQuickBuildTime", DHookCallback_CTFGameRules_IsQuickBuildTime_Pre);
#endif

	g_DHookMedigunPrimary = DHook_CreateVirtual(gamedata, "CWeaponMedigun::PrimaryAttack()");


#if defined ZR
	DHook_CreateDetour(gamedata, "CTFProjectile_HealingBolt::ImpactTeamPlayer()", OnHealingBoltImpactTeamPlayer, _);

	DHook_CreateDetour(gamedata, "CTFBuffItem::BlowHorn", _, Dhook_BlowHorn_Post);
	DHook_CreateDetour(gamedata, "CTFPlayerShared::PulseRageBuff()", Dhook_PulseFlagBuff,_);

#endif
	DHook_CreateDetour(gamedata, "CTFWeaponBaseMelee::DoSwingTraceInternal", DHook_DoSwingTracePre, _);
	DHook_CreateDetour(gamedata, "CWeaponMedigun::CreateMedigunShield", DHook_CreateMedigunShieldPre, _);
	DHook_CreateDetour(gamedata, "CTFBaseBoss::ResolvePlayerCollision", DHook_ResolvePlayerCollisionPre, _);
	DHook_CreateDetour(gamedata, "CTFGCServerSystem::PreClientUpdate", DHook_PreClientUpdatePre, DHook_PreClientUpdatePost);
	DHook_CreateDetour(gamedata, "CTFSpellBook::CastSelfStealth", Dhook_StealthCastSpellPre, _);
	DHook_CreateDetour(gamedata, "CTFPlayerShared::RecalculateChargeEffects", DHookCallback_RecalculateChargeEffects_Pre);
	
	g_DHookGrenadeExplode = DHook_CreateVirtual(gamedata, "CBaseGrenade::Explode");
	g_DHookGrenade_Detonate = DHook_CreateVirtual(gamedata, "CBaseGrenade::Detonate");
	
#if !defined RTS
	DHook_CreateDetour(gamedata, "CTFPlayer::SpeakConceptIfAllowed()", SpeakConceptIfAllowed_Pre, SpeakConceptIfAllowed_Post);

	g_DHookScoutSecondaryFire = DHook_CreateVirtual(gamedata, "CTFPistol_ScoutPrimary::SecondaryAttack()");
#endif
	g_detour_CTFGrenadePipebombProjectile_PipebombTouch = CheckedDHookCreateFromConf(gamedata, "CTFGrenadePipebombProjectile::PipebombTouch");
	
	
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	g_DHookFireballExplode = DHook_CreateVirtual(gamedata, "CTFProjectile_SpellFireball::Explode");
	g_DhookCrossbowHolster = DHook_CreateVirtual(gamedata, "CTFCrossbow::Holster");

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
	
	DHook_CreateDetour(gamedata, "CTFGameRules::CalcPlayerScore", Detour_CalcPlayerScore);

	HookItemIterateAttribute = DynamicHook.FromConf(gamedata, "CEconItemView::IterateAttributes");

	m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, m_bOnlyIterateItemViewAttributes);
	
	//Fixes mediguns giving extra speed where it was not intended.
	//gamedata first try!!
	DHook_CreateDetour(gamedata, "CTFPlayer::TeamFortress_SetSpeed()", DHookCallback_TeamFortress_SetSpeed_Pre, DHookCallback_TeamFortress_SetSpeed_Post);


	//https://github.com/CookieCat45/Risk-Fortress-2/blob/a98baf90d1074da6f82b53d30747aae354589b9a/scripting/rf2.sp#L281
	DynamicDetour g_hDetourCreateEvent = DynamicDetour.FromConf(gamedata, "CGameEventManager::CreateEvent");
	if (!g_hDetourCreateEvent || !g_hDetourCreateEvent.Enable(Hook_Pre, Detour_CreateEvent))
	{
		LogError("[DHooks] Failed to create detour for CGameEventManager::CreateEvent");
	}

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CGameEventManager::LoadEventsFromFile");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hSDKLoadEvents = EndPrepSDKCall();
	if (!g_hSDKLoadEvents)
	{
		LogError("[SDK] Failed to create call to CGameEventManager::LoadEventsFromFile");
	}
	
	if (g_hDetourCreateEvent)
	{
		CreateEvent("give_me_my_cgameeventmanager_pointer", true);
	}
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "SV_CreateBaseline");
	g_hSDKReloadEvents = EndPrepSDKCall();
	if (!g_hSDKReloadEvents)
	{
		LogError("[SDK] Failed to create call to SV_CreateBaseline");
	}

	delete gamedata;
	
	GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");

	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre, StartLagCompensationPost);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FrameUpdatePostEntityThink_SIGNATURE", _, LagCompensationThink);
		

	g_DhookWantsLagCompensationOnEntity = DHookCreateFromConf(gamedata_lag_comp,
			"CTFPlayer::WantsLagCompensationOnEntity");

	if (!g_DhookWantsLagCompensationOnEntity) {
		SetFailState("Failed to setup detour for CTFPlayer::WantsLagCompensationOnEntity");
	}
	
	delete gamedata_lag_comp;
}

int ClientThatWasChanged = 0;
int SavedClassForClient = 0;
public MRESReturn DHookCallback_TeamFortress_SetSpeed_Pre(int pThis)
{
	//-1 isnt enough.
	if(!IsValidEntity(pThis))     
		return MRES_Ignored;

	if(!IsClientInGame(pThis))
		return MRES_Ignored;
		
	int active = GetEntPropEnt(pThis, Prop_Send, "m_hActiveWeapon");
	if(active != -1)
	{
		if(b_IsAMedigun[active])
		{
			int healTarget = GetEntPropEnt(active, Prop_Send, "m_hHealingTarget");
			if(IsValidClient(healTarget))
			{
				SavedClassForClient = GetEntProp(healTarget, Prop_Send, "m_iClass");
				if(SavedClassForClient != view_as<int>(TFClass_Scout))
				{
					SavedClassForClient = -1;
					return MRES_Ignored;
				}

				ClientThatWasChanged = healTarget;
				SavedClassForClient = GetEntProp(healTarget, Prop_Send, "m_iClass");
				TF2_SetPlayerClass_ZR(healTarget, TFClass_Medic, false, false);
			}
		}
	}
	return MRES_Ignored;
}

public MRESReturn DHookCallback_TeamFortress_SetSpeed_Post(int pThis)
{
	if(ClientThatWasChanged > 0 && ClientThatWasChanged <= MaxClients)
	{
		if(view_as<TFClassType>(SavedClassForClient) > TFClass_Unknown)
			TF2_SetPlayerClass_ZR(ClientThatWasChanged, view_as<TFClassType>(SavedClassForClient), false, false);

		SavedClassForClient = -1;
		ClientThatWasChanged = -1;
	}
	return MRES_Ignored;
}
public MRESReturn Dhook_WantsLagCompensationOnEntity(int InitatedClient, Handle hReturn, Handle hParams)
{
	if(b_LagCompAlliedPlayers)
	{
		int target = DHookGetParam(hParams, 1);
		if(target == InitatedClient)
		{
			return MRES_Ignored;
		}
		DHookSetReturn(hReturn, true);
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
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

public MRESReturn DHook_ResolvePlayerCollisionPre(int entity, DHookReturn returnHook)
{
	PrintToServer("DHook_ResolvePlayerCollisionPre");
	return MRES_Supercede;
}

public MRESReturn Dhook_StealthCastSpellPre(int entity, DHookReturn returnHook, DHookParam param)
{
	returnHook.Value = true;
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


//Thanks to rafradek#0936 on the allied modders discord for pointing this function out!
//This changes player classes to the correct one.
#if !defined RTS
public MRESReturn SpeakConceptIfAllowed_Pre(int client, DHookReturn returnHook, DHookParam param)
{
	if(f_MutePlayerTalkShutUp[client] > GetGameTime())
	{
		returnHook.Value = false;
		return MRES_Supercede;
	}
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
	GrenadeExplodedAlready[entity] = false;
	g_DHookGrenadeExplode.HookEntity(Hook_Pre, entity, DHook_GrenadeExplodePre);
	g_DHookGrenade_Detonate.HookEntity(Hook_Pre, entity, DHook_GrenadeDetonatePre);
	if(Sticky)
		DHookEntity(g_detour_CTFGrenadePipebombProjectile_PipebombTouch, false, entity, _, GrenadePipebombProjectile_PipebombTouch);
	else
		DHookEntity(g_detour_CTFGrenadePipebombProjectile_PipebombTouch, false, entity, _, GrenadePipebombProjectile_PipebombTouch_Grenade);
	
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
	GrenadeExplodedAlready[entity] = false;
	if(!b_EntityIsArrow[entity] && !b_EntityIsWandProjectile[entity]) //No!
	{
		h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, DHook_RocketExplodePre);
	}
	CreateTimer(1.0, FixVelocityStandStillRocket, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
//Heavily increase thedelay, this rarely ever happens, and if it does, then it should check every 2 seconds at the most!
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
static MRESReturn GrenadePipebombProjectile_PipebombTouch_Grenade(int self, Handle params) 
{
	int other = DHookGetParam(params, 1);

	bool result = PassfilterGlobal(self, other, true);
	SetEntProp(self, Prop_Send, "m_bTouched", false);

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
	if(GrenadeExplodedAlready[entity])
	{
		return;
	}
	GrenadeExplodedAlready[entity] = true;
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
					EmitAmbientSound(")weapons/pipe_bomb1.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
				}
				case 2:
				{
					EmitAmbientSound(")weapons/pipe_bomb2.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
				}
				case 3:
				{
					EmitAmbientSound(")weapons/pipe_bomb3.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
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
				EmitAmbientSound("weapons/explode1.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
			}
			case 2:
			{
				EmitAmbientSound("weapons/explode2.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
			}
			case 3:
			{
				EmitAmbientSound("weapons/explode3.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
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

public MRESReturn DHook_RocketExplodePre(int entity, DHookParam params)
{
	if(GrenadeExplodedAlready[entity])
	{
		return MRES_Supercede;
	}
	GrenadeExplodedAlready[entity] = true;
	
	//Projectile_TeleportAndClip(entity);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	float GrenadePos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", GrenadePos);
	if (0 < owner  && owner <= MaxClients)
	{
		float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
		int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		int inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);
		if(!IsValidEntity(inflictor))
		{
			inflictor = 0;
		}
		Explode_Logic_Custom(original_damage, owner, entity, weapon,_,_,_,_,_,_,_,_,_,_,inflictor);

#if defined ZR
		//Owner was a client
		//Soldine check
		//Must be midair
		if(Wkit_Soldin_BvB(owner) && CanSelfHurtAndJump(owner))
		{
			float explosionRadius = 80.0;
			b_NpcIsTeamkiller[entity] = true;
			Explode_Logic_Custom(1.0, entity, entity, -1,_,explosionRadius,1.0,1.0,_,99,_,_,RocketJumpManualDo);
			b_NpcIsTeamkiller[entity] = false;
		}
#endif
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
	switch(GetRandomInt(1,3))
	{
		case 1:
		{
			EmitAmbientSound("weapons/explode1.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
		}
		case 2:
		{
			EmitAmbientSound("weapons/explode2.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
		}
		case 3:
		{
			EmitAmbientSound("weapons/explode3.wav", GrenadePos, _, 80, _,0.9, GetRandomInt(95, 105));
		}
	}
	GrenadePos[2] += 5.0;
	TE_Particle("ExplosionCore_MidAir", GrenadePos, NULL_VECTOR, NULL_VECTOR, 
	_, _, _, _, _, _, _, _, _, _, 0.0);
	RemoveEntity(entity);
	return MRES_Supercede;
}

#if defined ZR
static float RocketJumpManualDo(int attacker, int victim, float damage, int weapon)
{
	int owner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
	if(owner != victim)
		return (-damage); //Remove dmg
		
	if((GetEntityFlags(owner) & FL_ONGROUND))
		return (-damage); //Remove dmg
		
	float GrenadePos[3];
	GetEntPropVector(attacker, Prop_Data, "m_vecAbsOrigin", GrenadePos);
	float ClientPos[3];
	GetClientEyePosition(owner, ClientPos);
	float velocity[3];

	float explosionRadius = 80.0;
	CalculateExplosiveDamageForce(GrenadePos, ClientPos, explosionRadius * 2.0, velocity);
	velocity[0] = fClamp(velocity[0], -600.0, 600.0);
	velocity[1] = fClamp(velocity[1], -600.0, 600.0);
	velocity[2] = fClamp(velocity[2], -850.0, 850.0);
	//Speed limit
	TeleportEntity(owner, NULL_VECTOR, NULL_VECTOR, velocity);
	TF2_AddCondition(owner, TFCond_BlastJumping, 1.0);
	Wkit_Soldin_Effect(owner);
	return (-damage); //Remove dmg
}
#endif
/*
public MRESReturn CH_PassServerEntityFilter(DHookReturn ret, DHookParam params) 
{
	int toucher = DHookGetParam(params, 1);
	int passer  = DHookGetParam(params, 2);
	if(passer == -1)
		return MRES_Ignored;
		
	if(PassfilterGlobal(toucher, passer, true))
		return MRES_Ignored;
	
	ret.Value = false;
	return MRES_Supercede;
}
*/
public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	if(!(ent1 >= 0 && ent1 <= MAXENTITIES && ent2 >= 0 && ent2 <= MAXENTITIES))
		return Plugin_Continue;

	result = PassfilterGlobal(ent1, ent2, true);
	if(!result)
	{
		return Plugin_Handled;
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
		if(ent1 <= MaxClients && ent2 <= MaxClients)
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

		//if an npc is said to ignore all collisions, then it primarily means world as of now, do additional checks at a later time.
		if(b_IgnoreAllCollisionNPC[entity1] && entity2 == 0)
		{
			return false;
		}
		if(b_ProjectileCollideIgnoreWorld[entity1])
		{
		//	Wand_Base_StartTouch(entity1, entity2);
			return false;
		}

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
			if(i_IsABuilding[entity2] && RaidbossIgnoreBuildingsLogic(2))
			{
				return false;
			}
		}
		else if(b_IsAProjectile[entity1] && GetTeam(entity1) == TFTeam_Red)
		{
#if defined ZR
			if(b_ForceCollisionWithProjectile[entity2] && !b_EntityIgnoredByShield[entity1] && !IsEntitySpike(entity1))
#else
			if(b_ForceCollisionWithProjectile[entity2] && !b_EntityIgnoredByShield[entity1])
#endif
			{
#if defined ZR
				int EntityOwner = i_WandOwner[entity2];
				if(ShieldDeleteProjectileCheck(EntityOwner, entity1))
				{
					if(func_WandOnTouchReturn(entity1))
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
#endif
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
		if(!b_NpcHasDied[entity1] && GetTeam(entity1) != TFTeam_Red)
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
			else if(!b_NpcHasDied[entity2] && GetTeam(entity2) != TFTeam_Red)
			{
				return false;
			}
			else if (b_DoNotUnStuck[entity2])
			{
				return false;
			}
			
			//dont do during lag comp, no matter what	
			else if(!DoingLagCompensation)
			{
#if defined RPG
				if((entity2 <= MaxClients && entity2 > 0) && (f_AntiStuckPhaseThrough[entity2] > GetGameTime() || OnTakeDamageRpgPartyLogic(entity1, entity2, GetGameTime())))
#else
				if((entity2 <= MaxClients && entity2 > 0) && (f_AntiStuckPhaseThrough[entity2] > GetGameTime()))
#endif
				{
					//if a player needs to get unstuck.
					return false;
				}
				else if((entity2 <= MaxClients && entity2 > 0) && b_IgnoreAllCollisionNPC[entity1])
				{
					return false;
				}
			}
			
		}
//allied NPC
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
		else if(i_IsVehicle[entity1])
		{
			if(!i_IsVehicle[entity2])
			{
				int team = GetTeam(entity1);
				if(team == -1 || team == GetTeam(entity2))
					return false;
			}
		}
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

int TeamBeforeChange;
//if you find a way thats better to ignore fellow dispensers then tell me..!
public MRESReturn StartLagCompensationPre(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
	StartLagCompResetValues();
//	PrintToChatAll("StartLagCompensationPre");
	bool already_moved = false;
	if(b_LagCompAlliedPlayers) //This will ONLY compensate allies, so it wont do anything else! Very handy for optimisation.
	{
		b_LagCompNPC = true;
		b_LagCompNPC_ExtendBoundingBox = false;
		b_LagCompNPC_No_Layers = false;
		b_LagCompNPC_OnlyAllies = true;
		StartLagCompensation_Base_Boss(Compensator); //Compensate, but mostly allies.
		TeamBeforeChange = view_as<int>(GetEntProp(Compensator, Prop_Send, "m_iTeamNum")); //Hardcode to red as there will be no blue players.
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum",TFTeam_Blue);
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
		int baseboss_index_allied = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied) && GetTeam(baseboss_index_allied) == TFTeam_Red)
		{
			if(!Dont_Move_Allied_Npc || b_ThisEntityIgnored[baseboss_index_allied])
			{
#if defined ZR
				//if its a downed citizen, dont!!!
				if(!Citizen_ThatIsDowned(baseboss_index_allied))
#endif
					b_ThisEntityIgnoredEntirelyFromAllCollisions[baseboss_index_allied] = true;
			}
		}
	}
#endif

	if(b_LagCompNPC_AwayEnemies)
	{
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++)
		{
			int baseboss = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
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
	for (int entity = 0; entity < MAXENTITIES; entity++)
	{
		b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = false;
	}
	//Ultimate lazy
}

public MRESReturn FinishLagCompensation(Address manager, DHookParam param) //This code does not need to be touched. mostly.
{
//	PrintToChatAll("FinishLagCompensation");
	//Set this to false to be sure.
	int Compensator = param.Get(1);
	if(TeamBeforeChange)
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum",TeamBeforeChange);
	TeamBeforeChange = 0;
	FinishLagCompMoveBack();
	b_LagCompAlliedPlayers = false;
	
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
		DHookEntity(g_DhookWantsLagCompensationOnEntity, false, client, _, Dhook_WantsLagCompensationOnEntity);
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
			SetTeam(client, team);
#endif
		TF2Util_SetPlayerRespawnTimeOverride(client, FAR_FUTURE);
		return MRES_Supercede;
	}
	
	if(GetClientTeam(client) != 2)
	{
		SetTeam(client, 2);
		return MRES_Supercede;
	}

#if defined RPG
	if(!Saves_HasCharacter(client))
	{
		SetTeam(client, TFTeam_Spectator);
		return MRES_Supercede;
	}
	
	if(!Dungeon_CanClientRespawn(client))
		return MRES_Supercede;
#endif

#if defined ZR
	DoTutorialStep(client, false);
	SetTutorialUpdateTime(client, GetGameTime() + 1.0);
	
	if(Construction_InSetup())
	{
		TeutonType[client] = TEUTON_NONE;
	}
	else
	{
		if(Rogue_BlueParadox_CanTeutonUpdate(client) && Classic_CanTeutonUpdate(client, IsRespawning))
			TeutonType[client] = (!IsRespawning && !Waves_InSetup()) ? TEUTON_DEAD : TEUTON_NONE;
	}
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

	if(Construction_Mode())
		return MRES_Ignored;
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
						if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE && f_TimeAfterSpawn[i] < GetGameTime() && dieingstate[i] == 0 && Vehicle_Driver(i) == -1) //dont spawn near players who just spawned
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
		else
		{
			Race race;
			Races_GetClientInfo(client, race);
			if(race.StartPos[0])
			{
				float ang[3];
				ang[1] = race.StartAngle;
				TeleportEntity(client, race.StartPos, ang, NULL_VECTOR);
			}
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
		if(WeaponClass[GetChargeEffectBeingProvided] > view_as<TFClassType>(0))
			TF2_SetPlayerClass_ZR(GetChargeEffectBeingProvided, WeaponClass[GetChargeEffectBeingProvided], false, false);
		GetChargeEffectBeingProvided = 0;
	}
	return MRES_Ignored;
}

bool WasMedicPreRegen[MAXPLAYERS];

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
static TFClassType LastClass;
public MRESReturn DHook_TauntPre(int client, DHookParam param)
{
	if(f_PreventMovementClient[client] > GetGameTime() || TF2_IsPlayerInCondition(client, TFCond_Disguising) || TF2_IsPlayerInCondition(client, TFCond_Disguised) || TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		return MRES_Supercede;
	
	LastClass = TF2_GetPlayerClass(client);
	TF2_SetPlayerClass_ZR(client, WeaponClass[client], false, false);
	return MRES_Ignored;
}

public MRESReturn DHook_TauntPost(int client, DHookParam param)
{
	TF2_SetPlayerClass_ZR(client, LastClass, false, false);
	return MRES_Ignored;
}
#endif

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

	float HealAmmount = 20.0;

	HealAmmount *= Attributes_GetOnWeapon(owner, originalLauncher, 8, true);
	

	
	float GameTime = GetGameTime();
	if(f_TimeUntillNormalHeal[target] > GameTime)
	{
		HealAmmount /= 4.0; //make sure they dont get the full benifit if hurt recently.
	}
	
	int flHealth = GetEntProp(target, Prop_Send, "m_iHealth");
	int flMaxHealth = SDKCall_GetMaxHealth(target);
	
	int Health_To_Max;
	
	Health_To_Max = flMaxHealth - flHealth;
	
	if(Health_To_Max <= 0 || Health_To_Max > flMaxHealth)
	{
		ClientCommand(owner, "playgamesound items/medshotno1.wav");
		SetGlobalTransTarget(owner);
		
		ApplyStatusEffect(owner, owner, 	"Healing Resolve", 5.0);
		ApplyStatusEffect(owner, target, 	"Healing Resolve", 15.0);
	}
	else
	{
		HealEntityGlobal(owner, target, HealAmmount, 1.0, 1.0, _);
		
		ClientCommand(owner, "playgamesound items/smallmedkit1.wav");
		ClientCommand(target, "playgamesound items/smallmedkit1.wav");
		SetGlobalTransTarget(owner);
			
		ApplyStatusEffect(owner, owner, 	"Healing Resolve", 5.0);
		ApplyStatusEffect(owner, target, 	"Healing Resolve", 15.0);
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
	RequestFrames(DHook_ScoutSecondaryFireAbilityDelay, 10, EntIndexToEntRef(entity));
	//Allow short pushing of enemies.
	return MRES_Ignored;
}
void DHook_ScoutSecondaryFireAbilityDelay(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(IsValidClient(client))
		{
			int Active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(Active != entity)
				return;
#if defined ZR
			Enforcer_AbilityM2(client, entity, 1, 5, 1.25, true);
#endif
			SetEntPropFloat(entity, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 4.0);
			Ability_Apply_Cooldown(client, 2, 4.0);
		}
	}
}


//We want to disable them auto switching weapons during this, the reason being is that it messes with out custom equip logic, bad!


#if defined ZR
int BannerWearable[MAXPLAYERS];
int BannerWearableModelIndex[3];
#endif
bool DidEventHandleChange = false;
void DHooks_MapStart()
{
#if defined ZR
	BannerWearableModelIndex[0]= PrecacheModel("models/weapons/c_models/c_buffbanner/c_buffbanner.mdl", true);
	BannerWearableModelIndex[1]= PrecacheModel("models/weapons/c_models/c_battalion_buffbanner/c_batt_buffbanner.mdl", true);
	BannerWearableModelIndex[2]= PrecacheModel("models/weapons/c_models/c_shogun_warbanner/c_shogun_warbanner.mdl", true);
#endif
	DidEventHandleChange = false;
	RequestFrame(OverrideNpcHurtShortToLong);
	//g_bCustomEventsAvailable = false;

	//if(g_DHookShouldCollide)
	//	g_DHookShouldCollide.HookGamerules(Hook_Post, DHook_ShouldCollide);
}

void OverrideNpcHurtShortToLong()
{
	if(!DidEventHandleChange)
	{
		if (g_aGameEventManager && g_hSDKLoadEvents)
		{
			DidEventHandleChange = true;
			char eventsFile[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, eventsFile, sizeof(eventsFile), "data/zombie_riot/zrevents.res");
			LogMessage("Loading custom events file '%s'", eventsFile);
			if (SDKCall(g_hSDKLoadEvents, g_aGameEventManager, eventsFile))
			{
				//g_bCustomEventsAvailable = true;
				LogMessage("Success!");
				SDKCall(g_hSDKReloadEvents);
			}
			else
			{
				LogError("FAILED to load custom events file '%s'", eventsFile);
			}
		}
		else
		{
			LogError("FAILED to load custom events file (Missing Gamedata!)");
		}
	}
}
#if defined ZR
bool PersonInitiatedHornBlow[MAXPLAYERS];
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
		EmitSoundToAll("mvm/mvm_tank_horn.wav", client, SNDCHAN_STATIC, 80, _, 0.45);
		
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
		spawnRing(client, 50.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.1, 6.0, 6.1, 1);
	}
	ExtendDuration *= 1.5;

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

	int SettingDo;
	if(MagiaWingsDo(client))
		SettingDo = 1;
	if(SilvesterWingsDo(client))
		SettingDo = 2;
	//no equipping this wearable.
	if(SettingDo != 0)
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
	//select their class here again.
	CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
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
	else if (b_thisNpcHasAnOutline[entity] || !b_NpcHasDied[entity] && Zombies_Currently_Still_Ongoing <= 3 && Zombies_Currently_Still_Ongoing > 0)
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
//	SetEdictFlags(entity, flags);

	return flags;
}



static MRESReturn DHookCallback_CTFGameRules_IsQuickBuildTime_Pre(DHookReturn ret)
{
	ret.Value = false;
	return MRES_Supercede;
}

bool b_FixInfiniteAmmoBugOnly[MAXENTITIES];
bool SetBackAmmoCrossbow = false;
void CrossbowGiveDhook(int entity, bool GiveBackammo)
{
	g_DhookCrossbowHolster.HookEntity(Hook_Pre, entity, DhookBlockCrossbowPre);
	g_DhookCrossbowHolster.HookEntity(Hook_Post, entity, DhookBlockCrossbowPost);
	b_FixInfiniteAmmoBugOnly[entity] = GiveBackammo;
}

public MRESReturn DhookBlockCrossbowPre(int entity)
{
	if(b_FixInfiniteAmmoBugOnly[entity])
	{
		int AmmoType = GetAmmoType_WeaponPrimary(entity);
		if(AmmoType >= 1)
			return MRES_Ignored;
			//they have more then 1 ammo? Allow reloading.
	}
	int GetAmmoCrossbow = GetEntProp(entity, Prop_Data, "m_iClip1");
	if(GetAmmoCrossbow <= 0)
	{
		SetEntProp(entity, Prop_Data, "m_iClip1", 1);
		SetBackAmmoCrossbow = true;
	}
	return MRES_Ignored;
}

public MRESReturn DhookBlockCrossbowPost(int entity)
{
	if(SetBackAmmoCrossbow)
	{
		SetEntProp(entity, Prop_Data, "m_iClip1", 0);
		SetBackAmmoCrossbow = false;
	}
	return MRES_Ignored;
}

int OffsetLagCompStart_UserInfoReturn()
{
	//Get to CUserCmd				*m_pCurrentCommand;
	static int ReturnInfo;
	if(!ReturnInfo)
		ReturnInfo = (FindSendPropInfo("CTFPlayer", "m_hViewModel") + 76);

	return ReturnInfo;
}


public MRESReturn Detour_CreateEvent(Address eventManager, DHookReturn returnVal, DHookParam params)
{
	g_aGameEventManager = eventManager;
	
	RequestFrame(OverrideNpcHurtShortToLong);
	return MRES_Ignored;
}


static MRESReturn DHookCallback_RecalculateChargeEffects_Pre(Address pShared, DHookParam params)
{
//	DHookSetParam(params, 1, true);
	return MRES_Supercede;
}