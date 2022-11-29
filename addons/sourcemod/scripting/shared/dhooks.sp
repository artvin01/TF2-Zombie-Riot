#pragma semicolon 1
#pragma newdecls required

static DynamicHook ForceRespawn;
static int ForceRespawnHook[MAXTF2PLAYERS];
static int GetChargeEffectBeingProvided;
static bool IsRespawning;
//static bool Disconnecting;

static DynamicHook g_WrenchSmack;

static DynamicDetour gH_MaintainBotQuota = null;
static DynamicHook g_DHookGrenadeExplode; //from mikusch but edited
static DynamicHook g_DHookFireballExplode; //from mikusch but edited
static DynamicHook g_DHookScoutSecondaryFire; 

static DynamicDetour g_CalcPlayerScore;

static Handle g_detour_CTFGrenadePipebombProjectile_PipebombTouch;

static bool Dont_Move_Building;											//dont move buildings
static bool Dont_Move_Allied_Npc;											//dont move buildings	

static bool b_LagCompNPC;

/*
// Offsets from mikusch but edited
static int g_OffsetWeaponMode;
static int g_OffsetWeaponInfo;
static int g_OffsetWeaponPunchAngle;
*/

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
	
	
	DHook_CreateDetour(gamedata, "CTFPlayer::CanAirDash", DHook_CanAirDashPre);
	
//	DHook_CreateDetour(gamedata, "CTFPlayer::DropAmmoPack", DHook_DropAmmoPackPre);
//dont use, causes crashes.

	DHook_CreateDetour(gamedata, "CTFPlayer::GetChargeEffectBeingProvided", DHook_GetChargeEffectBeingProvidedPre, DHook_GetChargeEffectBeingProvidedPost);
	//DHook_CreateDetour(gamedata, "CTFPlayer::GetMaxAmmo", DHook_GetMaxAmmoPre);
	
	//https://github.com/Wilzzu/testing/blob/18a3680a9a1c8bdabc30c504bbf9467ac6e7d7b4/samu/addons/sourcemod/scripting/shavit-replay.sp
	
	if (!(gH_MaintainBotQuota = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Address)))
	{
		SetFailState("Failed to create detour for BotManager::MaintainBotQuota");
	}

	if (!DHookSetFromConf(gH_MaintainBotQuota, gamedata, SDKConf_Signature, "BotManager::MaintainBotQuota"))
	{
		SetFailState("Failed to get address for BotManager::MaintainBotQuota");
	}

	gH_MaintainBotQuota.Enable(Hook_Pre, Detour_MaintainBotQuota);
	
	
	DHook_CreateDetour(gamedata, "CTFPlayer::RegenThink", DHook_RegenThinkPre, DHook_RegenThinkPost);
	DHook_CreateDetour(gamedata, "CTFPlayer::RemoveAllOwnedEntitiesFromWorld", DHook_RemoveAllOwnedEntitiesFromWorldPre, DHook_RemoveAllOwnedEntitiesFromWorldPost);
	DHook_CreateDetour(gamedata, "HandleRageGain", DHook_HandleRageGainPre, DHook_HandleRageGainPost);
	DHook_CreateDetour(gamedata, "CObjectSentrygun::FindTarget", DHook_SentryFind_Target, _);
	DHook_CreateDetour(gamedata, "CObjectSentrygun::Fire", DHook_SentryFire_Pre, DHook_SentryFire_Post);
	DHook_CreateDetour(gamedata, "CTFProjectile_HealingBolt::ImpactTeamPlayer()", OnHealingBoltImpactTeamPlayer, _);

//	DHook_CreateDetour(gamedata, "CTFGCServerSystem::PreClientUpdate", PreClientUpdatePre, PreClientUpdatePost);


	DHook_CreateDetour(gamedata, "CBaseObject::FinishedBuilding", Dhook_FinishedBuilding_Pre, Dhook_FinishedBuilding_Post);
	DHook_CreateDetour(gamedata, "CBaseObject::FirstSpawn", Dhook_FirstSpawn_Pre, Dhook_FirstSpawn_Post);
	DHook_CreateDetour(gamedata, "FX_FireBullets()", FX_FireBullets_Pre, FX_FireBullets_Post);

	DHook_CreateDetour(gamedata, "CTFBuffItem::RaiseFlag", _, Dhook_RaiseFlag_Post);
	DHook_CreateDetour(gamedata, "CTFBuffItem::BlowHorn", _, Dhook_BlowHorn_Post);

	
	g_DHookGrenadeExplode = DHook_CreateVirtual(gamedata, "CBaseGrenade::Explode");
	
	g_WrenchSmack = DHook_CreateVirtual(gamedata, "CTFWrench::Smack()");
	
	g_detour_CTFGrenadePipebombProjectile_PipebombTouch = CheckedDHookCreateFromConf(gamedata, "CTFGrenadePipebombProjectile::PipebombTouch");
	
	
	g_DHookRocketExplode = DHook_CreateVirtual(gamedata, "CTFBaseRocket::Explode");
	g_DHookFireballExplode = DHook_CreateVirtual(gamedata, "CTFProjectile_SpellFireball::Explode");
	g_DHookMedigunPrimary = DHook_CreateVirtual(gamedata, "CWeaponMedigun::PrimaryAttack()");
	g_DHookScoutSecondaryFire = DHook_CreateVirtual(gamedata, "CTFPistol_ScoutPrimary::SecondaryAttack()");
	 
	ForceRespawn = DynamicHook.FromConf(gamedata, "CBasePlayer::ForceRespawn");
	if(!ForceRespawn)
		LogError("[Gamedata] Could not find CBasePlayer::ForceRespawn");
	
	Handle dtWeaponFinishReload = DHookCreateFromConf(gamedata, "CBaseCombatWeapon::FinishReload()");
	if (!dtWeaponFinishReload) {
		SetFailState("Failed to create detour %s", "CBaseCombatWeapon::FinishReload()");
	}
	DHookEnableDetour(dtWeaponFinishReload, false, OnWeaponReplenishClipPre);
	
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
		
	
	delete gamedata;
	
	GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");

	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::StartLagCompensation", StartLagCompensationPre, StartLagCompensationPost);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FinishLagCompensation", FinishLagCompensation, _);
	DHook_CreateDetour(gamedata_lag_comp, "CLagCompensationManager::FrameUpdatePostEntityThink_SIGNATURE", _, LagCompensationThink);

	delete gamedata_lag_comp;
	
}

void OnWrenchCreated(int entity) 
{
	g_WrenchSmack.HookEntity(Hook_Pre, entity, Wrench_SmackPre);
	g_WrenchSmack.HookEntity(Hook_Post, entity, Wrench_SmackPost);
}

public MRESReturn Wrench_SmackPre(int entity, DHookReturn ret, DHookParam param)
{	
	StartLagCompResetValues();
	Dont_Move_Building = true;
	int Compensator = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	LagCompEntitiesThatAreIntheWay(Compensator);
	return MRES_Ignored;
}

public MRESReturn Wrench_SmackPost(int entity, DHookReturn ret, DHookParam param)
{	
	FinishLagCompMoveBack();
	return MRES_Ignored;
}

//prevent infinite score gain
MRESReturn Detour_CalcPlayerScore(DHookReturn hReturn, DHookParam hParams)
{
	int client = hParams.Get(2);
	int iScore = PlayerPoints[client];

	hReturn.Value = iScore;
	return MRES_Supercede;
}

public void ApplyExplosionDhook_Pipe(int entity, bool Sticky)
{
	g_DHookGrenadeExplode.HookEntity(Hook_Pre, entity, DHook_GrenadeExplodePre);
	DHookEntity(g_detour_CTFGrenadePipebombProjectile_PipebombTouch, false, entity, _, GrenadePipebombProjectile_PipebombTouch);
	
	if(Sticky)
	{
		SDKHook(entity, SDKHook_StartTouch, SdkHook_StickStickybombToBaseBoss);
	}
	
	//Hacky? yes, But i gotta.
	
	//I have to do it twice, if its a custom spawn i have to do it insantly, if its a tf2 spawn then i have to do it seperatly.
}

void See_Projectile_Team(int entity)
{
	if (entity < 0 || entity > 2048)
	{
		entity = EntRefToEntIndex(entity);
	}
	if (IsValidEntity(entity) && entity != 0)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
			b_Is_Player_Projectile[entity] = true;	 //try this
			//Update: worked! Will now pass through players/teammates
			//Nice.
		}	
		else if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue))
		{
			b_Is_Npc_Projectile[entity] = true; 
		}
	}
	
}

void See_Projectile_Team_Player(int entity)
{
	if (entity < 0 || entity > 2048)
	{
		entity = EntRefToEntIndex(entity);
	}
	if (IsValidEntity(entity) && entity != 0)
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
		{
			b_Is_Player_Projectile_Through_Npc[entity] = true;	 //try this
			//Update: worked! Will now pass through players/teammates
			//Nice.
		}	
	}
}

/*
#define MAXSTICKYCOUNTTONPC 12
const int i_MaxcountSticky = MAXSTICKYCOUNTTONPC;
int i_StickyToNpcCount[MAXENTITIES][MAXSTICKYCOUNTTONPC]; //12 should be the max amount of stickies.
*/


public Action SdkHook_StickStickybombToBaseBoss(int entity, int other)
{
	if(!GetEntProp(entity, Prop_Send, "m_bTouched"))
	{
		if(!b_StickyIsSticking[entity] && b_Is_Blue_Npc[other])
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
	if(!b_EntityIsArrow[entity] && !b_EntityIsWandProjectile[entity]) //No!
	{
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, DHook_RocketExplodePre);
	}
	CreateTimer(0.1, FixVelocityStandStillRocket, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hThrower");
	if (0 < owner <= MaxClients)
	{
		if(f_CustomGrenadeDamage[entity] < 999999.9)
		{
			float original_damage = GetEntPropFloat(entity, Prop_Send, "m_flDamage"); 
			if(f_CustomGrenadeDamage[entity] > 1.0)
			{
				original_damage = f_CustomGrenadeDamage[entity];
			}
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
			Explode_Logic_Custom(original_damage, owner, entity, weapon);
		}
		else
		{
			return MRES_Supercede;
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
			SetEntPropFloat(entity, Prop_Send, "m_flDamage", 0.0); 
			
			//Important, make them not act as an ai if its on red, or else they are BUSTED AS FUCK.
			if(GetEntProp(entity, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
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
			return MRES_Supercede;
		}
	}
	f_CustomGrenadeDamage[entity] = 0.0;
	return MRES_Ignored;
}

//steal from fortress royale

stock int GetOwnerLoop(int entity)
{
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (owner > 0 && owner != entity)
		return GetOwnerLoop(owner);
	else
		return entity;
}

public MRESReturn DHook_FireballExplodePre(int entity)
{
	int owner = GetOwnerLoop(entity);
	if (0 < owner <= MaxClients)
	{
		int i, weapon;
		while(TF2_GetItem(owner, weapon, i))
		{
			if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 939)
			{
				float damage = 300.0;
				
				Address address = TF2Attrib_GetByDefIndex(weapon, 410);
				if(address != Address_Null)
					damage *= TF2Attrib_GetValue(address);
				
				Explode_Logic_Custom(damage, owner, entity, weapon, _, _, _, _, _, _, true);
				break;
			}
		}

	}
	return MRES_Ignored;
}

public MRESReturn DHook_RocketExplodePre(int entity)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (0 < owner <= MaxClients)
	{
		float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
		int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
		Explode_Logic_Custom(original_damage, owner, entity, weapon);
	}
	else if(owner > MaxClients)
	{
		float original_damage = GetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);
	//	int weapon = GetEntPropEnt(entity, Prop_Send, "m_hOriginalLauncher");
	//Important, make them not act as an ai if its on red, or else they are BUSTED AS FUCK.
		if(GetEntProp(entity, Prop_Data, "m_iTeamNum") != view_as<int>(TFTeam_Red))
		{
			Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,true);	
		}
		else
		{
			Explode_Logic_Custom(original_damage, owner, entity, -1,_,_,_,_,false);
		}
	}
	return MRES_Ignored;
}
/*
public Action CH_ShouldCollide(int ent1, int ent2, bool &result)
{
	if(IsValidEntity(ent1) && IsValidEntity(ent2))
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
*/


public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	//if(IsValidEntity(ent1) && IsValidEntity(ent2))
	if(ent1 > 0 && ent1 <= MAXENTITIES && ent2 > 0 && ent2 <= MAXENTITIES)
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
		if(b_ThisEntityIgnoredEntirelyFromAllCollisions[entity1])
		{
		//	PrintToChatAll("ingore");
			return false;
		}
		else if(b_IsAGib[entity1]) //This is a gib that just collided with a player, do stuff! and also make it not collide.
		{
			if(entity2 <= MaxClients && entity2 > 0)
			{
				GibCollidePlayerInteraction(entity1, entity2);
				return false;
			}
		}
		else if(b_Is_Npc_Projectile[entity1])
		{
			if(b_ThisEntityIgnored[entity2])
			{
				return false;
			}
			if(b_Is_Blue_Npc[entity2])
			{
				return false;
			}
			else if(b_Is_Npc_Projectile[entity2])
			{
				return false;
			}
		}
		else if(b_Is_Player_Projectile[entity1])
		{
			if(b_ThisEntityIgnored[entity2])
			{
				return false;
			}
			if(entity2 <= MaxClients && entity2 > 0)
			{
				return false;
			}
			else if(b_IsAlliedNpc[entity2])
			{
				return false;
			}
			else if(b_Is_Player_Projectile[entity2])
			{
				return false;
			}
		}
		else if (b_Is_Player_Projectile_Through_Npc[entity1])
		{
			if(b_Is_Blue_Npc[entity2])
			{
				return false;
			}
		}
		else if(b_Is_Blue_Npc[entity1])
		{
			if(b_ThisEntityIgnored[entity2] && !DoingLagCompensation) //Only Ignore when not shooting/compensating, which is shooting only.
			{
				return false;
			}
			else if(b_Is_Blue_Npc[entity2])
			{
				return false;
			}
		}
		else if(b_IsAlliedNpc[entity1])
		{
			if(b_IsAlliedNpc[entity2])
			{	
				return false;
			}
			else if((entity2 <= MaxClients && entity2 > 0) && !Dont_Move_Allied_Npc && !b_DoNotIgnoreDuringLagCompAlly[entity1])
			{
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
/*
static void CreateDynamicDetour(GameData gamedata, const char[] name, DHookCallback callbackPre = INVALID_FUNCTION, DHookCallback callbackPost = INVALID_FUNCTION)
{
	DynamicDetour detour = DynamicDetour.FromConf(gamedata, name);
	if (detour)
	{
		if (callbackPre != INVALID_FUNCTION)
			detour.Enable(Hook_Pre, callbackPre);
		
		if (callbackPost != INVALID_FUNCTION)
			detour.Enable(Hook_Post, callbackPost);
	}
	else
	{
		LogError("Failed to create detour setup handle for %s", name);
	}
}
*/
/*
hopefully fixes 0x2f2388
I suspect that somehow someone got disgusied and thus the sendproxy regarding classes broke as there is no blue player, and maybe it bugs out with base_boss
i will keep it updated incase this didnt work.

*/

//LAG COMP SECTION! Kinda VERY important.

/*
public MRESReturn StartLagCompensation_Pre(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
	PrintToChatAll("StartLagCompensation_Pre %i",Compensator);
	if(b_LagCompAlliedPlayers) //This will ONLY compensate allies, so it wont do anything else! Very handy for optimisation. 
	{
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum", view_as<int>(TFTeam_Spectator))
	}
	return MRES_Ignored;
}
*/
public void StartLagCompResetValues()
{
	Dont_Move_Building = false;
	Dont_Move_Allied_Npc = false;
	b_LagCompNPC = true;
	b_LagCompNPC_No_Layers = false;	
	b_LagCompNPC_AwayEnemies = false;
	b_LagCompNPC_ExtendBoundingBox = false;
	b_LagCompNPC_BlockInteral = false;
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
	#if defined LagCompensation
	if(b_LagCompNPC)
		StartLagCompensation_Base_Boss(Compensator, false);
	#endif
	
	if(b_LagCompNPC_BlockInteral)
	{
		TF2_SetPlayerClass(Compensator, TFClass_Scout, false, false); //Make sure they arent a medic during this! Reason: Mediguns lag comping, need both to be a medic and have a medigun
		LagCompMovePlayersExceptYou(Compensator);
	}
	
	g_hSDKStartLagCompAddress = manager;
	
	return MRES_Ignored;
}
public MRESReturn StartLagCompensationPost(Address manager, DHookParam param)
{
	int Compensator = param.Get(1);
	if(b_LagCompNPC_BlockInteral)
	{
		TF2_SetPlayerClass(Compensator, WeaponClass[Compensator], false, false); 
	//	return MRES_Supercede;
	}
	if(b_LagCompAlliedPlayers) //This will ONLY compensate allies, so it wont do anything else! Very handy for optimisation.
	{
		SetEntProp(Compensator, Prop_Send, "m_iTeamNum", view_as<int>(TFTeam_Red)); //Hardcode to red as there will be no blue players.
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
			if (TeutonType[client] == TEUTON_NONE) 
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
			}
		}
	}
}

public void LagCompEntitiesThatAreIntheWay(int Compensator)
{
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsClientInGame(client) && client != Compensator)
		{
			if (TeutonType[client] != TEUTON_NONE || (!Dont_Move_Allied_Npc)) 
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
			}
		}
	}
	if(!Dont_Move_Building)
	{
		for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
		{
			int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
			if (IsValidEntity(entity))
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[entity] = true;
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpc_Allied; entitycount_again++)
	{
		int baseboss_index_allied = EntRefToEntIndex(i_ObjectsNpcs_Allied[entitycount_again]);
		if (IsValidEntity(baseboss_index_allied) && baseboss_index_allied != 0)
		{
			if(!Dont_Move_Allied_Npc || b_ThisEntityIgnored[baseboss_index_allied])
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[baseboss_index_allied] = true;
			}
		}
	}
	if(b_LagCompNPC_AwayEnemies)
	{
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpc; entitycount_again_2++)
		{
			int baseboss = EntRefToEntIndex(i_ObjectsNpcs[entitycount_again_2]);
			if (IsValidEntity(baseboss) && baseboss != 0)
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[baseboss] = true;
			}
		}	
	}
}

public MRESReturn LagCompensationThink(Address manager)
{
	#if defined LagCompensation
	LagCompensationThink_Forward();
	#endif
	return MRES_Ignored;
//	return MRES_Supercede;
}
/*
public void FinishLagCompensationResetValues()
{
	b_LagCompAlliedPlayers = false; //Do it here.
}
*/

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
//	StartLagCompensation_Base_Boss
//	FinishLagCompensation_Base_boss(param);
//	int Compensator = param.Get(1);
	
	FinishLagCompMoveBack();
	
	#if defined LagCompensation
	if(b_LagCompNPC)
		FinishLagCompensation_Base_boss();
	#endif
	
//	FinishLagCompensationResetValues();
	
	g_hSDKEndLagCompAddress = manager;
	Sdkcall_Load_Lagcomp();
	
	return MRES_Ignored;
//	return MRES_Supercede;
}
/*
public MRESReturn DHook_BlockThink(int Base_Boss)
{
	PrintToChatAll("thinking");
	return MRES_Supercede;
}
*/
public MRESReturn DHook_SentryFind_Target(int sentry, Handle hReturn, Handle hParams)
{
	if(b_SentryIsCustom[sentry])
	{
		DHookSetReturn(hReturn, false); 
		return MRES_Supercede;		
	}
	int owner = GetEntPropEnt(sentry, Prop_Send, "m_hBuilder");
	if(owner > 0)
	{
		if(IsPlayerAlive(owner))
		{
			int i, entity;
			while(TF2_GetItem(owner, entity, i))
			{
				int weaponindex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
				if(weaponindex == 140)
					return MRES_Ignored;
			}
		}
	}
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
	return MRES_Ignored;
}


public MRESReturn DHook_SentryFire_Pre(int sentry, Handle hReturn, Handle hParams)
{
	if(!EscapeMode)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
			}
		}
	}
	else
	{
		int owner = GetEntPropEnt(sentry, Prop_Send, "m_hBuilder");
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && owner != client)
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = true;
			}
		}	
	}
	return MRES_Ignored;
}

public MRESReturn DHook_SentryFire_Post(int sentry, Handle hReturn, Handle hParams)
{
	if(!EscapeMode)
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = false;
			}
		}
	//	EmitGameSoundToAll("Building_MiniSentrygun.Fire", sentry);
	}
	else
	{
		int owner = GetEntPropEnt(sentry, Prop_Send, "m_hBuilder");
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client) && owner != client)
			{
				b_ThisEntityIgnoredEntirelyFromAllCollisions[client] = false;
			}
		}
	//	EmitGameSoundToAll("Building_MiniSentrygun.Fire", sentry);		
	}
	return MRES_Ignored;
}

void DHook_HookClient(int client)
{
	
	if(ForceRespawn)
	{
		ForceRespawnHook[client] = ForceRespawn.HookEntity(Hook_Pre, client, DHook_ForceRespawn);
		dieingstate[client] = 0;
		CClotBody player = view_as<CClotBody>(client);
		player.m_bThisEntityIgnored = false;
	}
}

void DHook_UnhookClient(int client)
{
	if(ForceRespawn)
	{
		DynamicHook.RemoveHook(ForceRespawnHook[client]);
		RequestFrame(CheckIfAloneOnServer);
	}
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
void DHook_RespawnPlayer(int client)
{
	IsRespawning = true;
	TF2_RespawnPlayer(client);
	SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 0.0); //No cloak regen at all. Very important to set here!
	IsRespawning = false;
}

public MRESReturn DHook_CanAirDashPre(int client, DHookReturn ret)
{
	/*int current = GetEntProp(client, Prop_Send, "m_iAirDash");
	int max_Value = Attributes_Airdashes(client);

	if(TF2_IsPlayerInCondition(client, TFCond_CritHype))
		max_Value += 4;

	if(current < max_Value)
	{
		ret.Value = true;
		SetEntProp(client, Prop_Send, "m_iAirDash", current+1);
	}
	else*/
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
		if(GetClientTeam(client) != 3)
			ChangeClientTeam(client, 3);
		
		return MRES_Supercede;
	}
	
	RequestFrame(SetEyeAngleCorrect, client);
	
	if(GetClientTeam(client) != 2)
	{
		ChangeClientTeam(client, 2);
		return MRES_Supercede;
	}
	
	DoTutorialStep(client, false);
	SetTutorialUpdateTime(client, GetGameTime() + 1.0);
	
	bool started = !Waves_InSetup();
	TeutonType[client] = (!IsRespawning && started) ? TEUTON_DEAD : TEUTON_NONE;
	
	CurrentClass[client] = view_as<TFClassType>(GetEntProp(client, Prop_Send, "m_iDesiredPlayerClass"));
	if(!CurrentClass[client])
	{
		CurrentClass[client] = TFClass_Scout;
		SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", TFClass_Scout);
	}
	DoOverlay(client, "");
	WeaponClass[client] = TFClass_Unknown;
	
	if(!WaitingInQueue[client] && !GameRules_GetProp("m_bInWaitingForPlayers"))
		Queue_AddPoint(client);
	
	SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
	SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
	
	GiveCompleteInvul(client, 2.0);
			
	if(started && TeutonType[client] == TEUTON_NONE)
	{
		SetEntityHealth(client, 50);
		RequestFrame(SetHealthAfterRevive, client);
	}
	
	CreateTimer(0.1, DHook_TeleportToAlly, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
	f_TimeAfterSpawn[client] = GetGameTime() + 1.0;
	
	return MRES_Ignored;
}
		
//Ty miku for showing me this cvar.
public void PhaseThroughOwnBuildings(int client)
{
	if(b_PhaseThroughBuildingsPerma[client] == 2) //They already ignore everything 24/7, dont bother.
	{
		SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
		return;
	}
	
	float PlayerLoc[3];
	float otherLoc[3];
	bool Collides_with_atleast_one_building = false;
	GetClientAbsOrigin(client, PlayerLoc);
	
	for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
	{
		int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
		if(IsValidEntity(entity) && entity != 0)
		{
			if(GetEntPropEnt(entity, Prop_Send, "m_hBuilder") == client)
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", otherLoc);
				if (GetVectorDistance(PlayerLoc, otherLoc, true) <= 11000.0)// 110.0 distance
				{	 
					Collides_with_atleast_one_building = true;
				}
			}
		}
	}
	
	if(CvarMpSolidObjects)
		CvarMpSolidObjects.ReplicateToClient(client, Collides_with_atleast_one_building ? "0" : "1");
		
	b_PhasesThroughBuildingsCurrently[client] = Collides_with_atleast_one_building;
	
	if(!Collides_with_atleast_one_building)
	{
		SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
}

		
public void DHook_TeleportToObserver(DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	if(client)
	{
		GiveCompleteInvul(client, 2.0);
		int target = pack.ReadCell();
		if(target == client || target < 1 || target > MaxClients || !IsClientInGame(target) || !IsPlayerAlive(target) || TeutonType[target] != TEUTON_NONE)
		{
			target = 0;
			for(int i=1; i<=MaxClients; i++)
			{
				if(i != client && IsClientInGame(i))
				{
					if(IsPlayerAlive(i) && GetClientTeam(i)==2 && TeutonType[i] == TEUTON_NONE)
					{
						target = i;
						break;
					}
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
			SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
			SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
		}
	}
	delete pack;
}

public Action DHook_TeleportToAlly(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		GiveCompleteInvul(client, 2.0);
		if(f_WasRecentlyRevivedViaNonWave[client] < GetGameTime())
		{	
			if(!Waves_InSetup())
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
					SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
					SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
				}
			}
		}
	}
	return Plugin_Handled;
}

public MRESReturn DHook_GetChargeEffectBeingProvidedPre(int client, DHookReturn ret)
{
	if(IsClientInGame(client))
	{
		TF2_SetPlayerClass(client, TFClass_Medic, false, false);
		GetChargeEffectBeingProvided = client;
	}
	return MRES_Ignored;
}

public MRESReturn DHook_GetChargeEffectBeingProvidedPost(int client, DHookReturn ret)
{
	if(GetChargeEffectBeingProvided)
	{
		#if defined NoSendProxyClass
		TF2_SetPlayerClass(GetChargeEffectBeingProvided, WeaponClass[GetChargeEffectBeingProvided], false, false);
		#else
		TF2_SetPlayerClass(GetChargeEffectBeingProvided, CurrentClass[GetChargeEffectBeingProvided], false, false);
		#endif
		GetChargeEffectBeingProvided = 0;
	}
	return MRES_Ignored;
}

public MRESReturn DHook_GetMaxAmmoPre(int client, DHookReturn ret, DHookParam param)
{
	int type = param.Get(1);
	switch(type)
	{
		case Ammo_Metal, Ammo_Flame, Ammo_Minigun:
			ret.Value = 2000;
		
		case Ammo_Pistol:
			ret.Value = 360;
		
		case Ammo_Rocket:
			ret.Value = 200;
		
		case Ammo_Flare, Ammo_Grenade:
			ret.Value = 160;
		
		case Ammo_Sticky, Ammo_Revolver:
			ret.Value = 240;
		
		case Ammo_Bolt:
			ret.Value = 375;
		
		case Ammo_Syringe:
			ret.Value = 1500;
		
		case Ammo_Sniper:
			ret.Value = 250;
		
		case Ammo_Arrow:
			ret.Value = 125;
		
		case Ammo_SMG:
			ret.Value = 750;
		
		case Ammo_Shotgun:
			ret.Value = 320;
		
		default:
			return MRES_Ignored;
	}
	return MRES_Supercede;
}
#if !defined NoSendProxyClass
public MRESReturn DHook_IsPlayerClassPre(int client, DHookReturn ret, DHookParam param)
{
	if(!IsPlayerClass)
		return MRES_Ignored;

	ret.Value = true;
	return MRES_Supercede;
}
#endif

public MRESReturn DHook_RegenThinkPre(int client, DHookParam param)
{
	if(TF2_GetPlayerClass(client) == TFClass_Medic)
		TF2_SetPlayerClass(client, TFClass_Unknown, false, false);

	return MRES_Ignored;
}

public MRESReturn DHook_RegenThinkPost(int client, DHookParam param)
{
	if(TF2_GetPlayerClass(client) == TFClass_Unknown)
		TF2_SetPlayerClass(client, TFClass_Medic, false, false);

	return MRES_Ignored;
}

static int LastTeam;
public MRESReturn DHook_RemoveAllOwnedEntitiesFromWorldPre(int client, DHookParam param)
{
//	if(!Disconnecting)
	{
		LastTeam = GetEntProp(client, Prop_Send, "m_iTeamNum");
		GameRules_SetProp("m_bPlayingMannVsMachine", true);
		SetEntProp(client, Prop_Send, "m_iTeamNum", TFTeam_Blue);
	}
	return MRES_Ignored;
}
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
public MRESReturn DHook_RemoveAllOwnedEntitiesFromWorldPost(int client, DHookParam param)
{
//	if(!Disconnecting)
	{
		GameRules_SetProp("m_bPlayingMannVsMachine", false);
		SetEntProp(client, Prop_Send, "m_iTeamNum", LastTeam);
	}
	return MRES_Ignored;
}

public MRESReturn DHook_TauntPre(int client, DHookParam param)
{
	//Dont allow taunting if disguised or cloaked
	if(TF2_IsPlayerInCondition(client, TFCond_Disguising) || TF2_IsPlayerInCondition(client, TFCond_Disguised) || TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		return MRES_Supercede;

	//Player wants to taunt, set class to whoever can actually taunt with active weapon
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon <= MaxClients)
		return MRES_Ignored;

	static char buffer[36];
	GetEntityClassname(weapon, buffer, sizeof(buffer));
	TFClassType class = TF2_GetWeaponClass(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex"), CurrentClass[client], TF2_GetClassnameSlot(buffer));
	if(class != TFClass_Unknown)
		TF2_SetPlayerClass(client, class, false, false);

	return MRES_Ignored;
}

public MRESReturn DHook_TauntPost(int client, DHookParam param)
{
	//Set class back to what it was
	#if defined NoSendProxyClass
	TF2_SetPlayerClass(client, WeaponClass[client], false, false);
	#else
	TF2_SetPlayerClass(client, CurrentClass[client], false, false);
	#endif
	return MRES_Ignored;
}

public MRESReturn DHook_HandleRageGainPre(DHookParam param)
{
	if(!param.IsNull(1))
		TF2_SetPlayerClass(param.Get(1), TFClass_Soldier, false, false);
	
	return MRES_Ignored;
}

public MRESReturn DHook_HandleRageGainPost(DHookParam param)
{
	if(!param.IsNull(1))
	{
		int client = param.Get(1);
		#if defined NoSendProxyClass
		TF2_SetPlayerClass(client, WeaponClass[client], false, false);
		#else
		TF2_SetPlayerClass(client, CurrentClass[client], false, false);
		#endif
	}
	return MRES_Ignored;
}

// g_bWarnedAboutMaxplayersInMVM
/*
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
	
	int ammo_amount_left = 9999;
	
	if(!EscapeMode)
		ammo_amount_left = GetAmmo(owner, 21);
								
	if(ammo_amount_left > 0)
	{
		float HealAmmount = 20.0;
		Address address = TF2Attrib_GetByDefIndex(originalLauncher, 8);
		if(address != Address_Null)
		{
			HealAmmount *= TF2Attrib_GetValue(address);
		}
		else
		{
			HealAmmount = 20.0;
		}

		HealAmmount *= Attributes_FindOnPlayer(owner, 8, true, 1.0);
		
		if(EscapeMode)
			HealAmmount *= 2.0;
			
		if(f_TimeUntillNormalHeal[target] > GetGameTime())
		{
			HealAmmount /= 8.0; //make sure they dont get the full benifit if hurt recently.
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
		}
		else
		{
			if(Health_To_Max < RoundToCeil(HealAmmount))
			{
				ammo_amount_left = Health_To_Max;
			}
			Give_Assist_Points(target, owner);
			
			StartHealingTimer(target, 0.1, ammo_amount_left/10, 10, true);
			Healing_done_in_total[owner] += ammo_amount_left;
			int new_ammo = GetAmmo(owner, 21) - ammo_amount_left;
			ClientCommand(owner, "playgamesound items/smallmedkit1.wav");
			ClientCommand(target, "playgamesound items/smallmedkit1.wav");
			SetGlobalTransTarget(owner);
			
			PrintHintText(owner, "%t", "You healed for", target, ammo_amount_left);
			SetAmmo(owner, 21, new_ammo);
			Increaced_Overall_damage_Low[owner] = GetGameTime() + 2.0;
			Increaced_Overall_damage_Low[target] = GetGameTime() + 10.0;
			Resistance_Overall_Low[owner] = GetGameTime() + 2.0;
			Resistance_Overall_Low[target] = GetGameTime() + 10.0;
			for(int i; i<Ammo_MAX; i++)
			{
				CurrentAmmo[owner][i] = GetAmmo(owner, i);
			}
		}
	}

	
	return MRES_Supercede;
}

MRESReturn OnWeaponReplenishClipPre(int weapon) // Not when the player press reload but when the weapon reloads
{
	if(IsValidEntity(weapon))
	{
		Action action = Plugin_Continue;
		if(EntityFuncReload4[weapon] && EntityFuncReload4[weapon]!=INVALID_FUNCTION)
		{
			int client = GetEntPropEnt(weapon, Prop_Send, "m_hOwner");
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

public MRESReturn DHook_ScoutSecondaryFire(int entity) //BLOCK!!
{
	return MRES_Supercede;	//NEVER APPLY. Causes you to not fire if accidentally pressing m2
}

public MRESReturn Detour_MaintainBotQuota(int pThis)
{
	return MRES_Supercede;
}


//We want to disable them auto switching weapons during this, the reason being is that it messes with out custom equip logic, bad!

public MRESReturn Dhook_BlowHorn_Post(int entity)
{
	TF2Attrib_SetByDefIndex(entity, 698, 1.0); // disable weapon switch
	return MRES_Ignored;
}
public MRESReturn Dhook_RaiseFlag_Post(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int viewmodel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(viewmodel>MaxClients && IsValidEntity(viewmodel)) //For some reason it plays the horn anim again, just set it to idle!
	{
		int animation = 21; //should be default idle, modded viewmodels are fucked ig lol
		SetEntProp(viewmodel, Prop_Send, "m_nSequence", animation);
	}
	
	//They successfully blew the horn! give them abit of credit for that! they helpinnnnnnn... yay
	i_ExtraPlayerPoints[client] += 15;
	TF2Attrib_SetByDefIndex(entity, 698, 0.0); // disable weapon switch
	return MRES_Ignored;
}
/*
 void FX_FireBullets( CTFWeaponBase *pWpn,
 int iPlayer,
  const Vector &vecOrigin,
    const QAngle &vecAngles,
	  int iWeapon,
	   int iMode,
	    int iSeed,
		 float flSpread,
		  float flDamage  = -1.0f ,
		   bool bCritical  = false )
*/
public MRESReturn FX_FireBullets_Pre(DHookParam hParams)
{
//	PrintToChatAll("shot");
 //   int Weapon = DHookGetParam(hParams, 1); // I'm sorry methodmap Gods, but the server I uploaded it on doesn't like it so i have to do this :pepega:
 //   int Client = DHookGetParam(hParams, 2);

	//Future use for special guns ?

    return MRES_Ignored;
}

public MRESReturn FX_FireBullets_Post(DHookParam hParams)
{

    return MRES_Ignored;
}