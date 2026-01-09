#pragma semicolon 1
#pragma newdecls required

static Handle SDKEquipWearable;
static Handle SDKGetMaxHealth;
//static Handle g_hStudio_FindAttachment;

static Handle g_hSetAbsOrigin;
static Handle g_hSetAbsAngle;
static Handle g_hInvalidateBoneCache;

static Handle g_hCTFCreateArrow;
//static Handle g_hCTFCreatePipe;
//Handle g_hSDKMakeCarriedObject;
//static Handle g_hGetVectors;
//static Handle g_hWeaponSound;
//static Handle g_hSDKPlaySpecificSequence;
//static Handle g_hDoAnimationEvent;

#if defined ZR || defined RPG
static Handle g_hSDKStartLagComp;
static Handle g_hSDKEndLagComp;
#endif

static Handle g_SDKCallRemoveImmediate;

static Handle SDKGetShootSound;
static Handle SDKBecomeRagdollOnClient;
static Handle SDKSetSpeed;

void SDKCall_Setup()
{
	GameData gamedata = LoadGameConfigFile("sm-tf2.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetVirtual(gamedata.GetOffset("RemoveWearable") - 1);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	SDKEquipWearable = EndPrepSDKCall();
	if(!SDKEquipWearable)
		LogError("[Gamedata] Could not find RemoveWearable");
	
	delete gamedata;
	
	gamedata = LoadGameConfigFile("sdkhooks.games");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "GetMaxHealth");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
	SDKGetMaxHealth = EndPrepSDKCall();
	if(!SDKGetMaxHealth)
		LogError("[Gamedata] Could not find GetMaxHealth");
		
	delete gamedata;
	
	gamedata = LoadGameConfigFile("zombie_riot");
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetLocalOrigin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	g_hSetLocalOrigin = EndPrepSDKCall();
	if(!g_hSetLocalOrigin)
		LogError("[Gamedata] Could not find CBaseEntity::SetLocalOrigin");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetLocalAngles");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	g_hSetLocalAngles = EndPrepSDKCall();
	if(!g_hSetLocalAngles)
		LogError("[Gamedata] Could not find CBaseEntity::SetLocalOrigin");

	//CBasePlayer
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBasePlayer::SnapEyeAngles");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	if ((g_hSnapEyeAngles = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBasePlayer::SnapEyeAngles!");


		
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetAbsVelocity");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	if ((g_hSetAbsVelocity = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::SetAbsVelocity");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetAbsOrigin");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	g_hSetAbsOrigin = EndPrepSDKCall();
	if(!g_hSetAbsOrigin)
		LogError("[Gamedata] Could not find CBaseEntity::SetAbsOrigin");
		
		
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetAbsAngles");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	g_hSetAbsAngle = EndPrepSDKCall();
	if(!g_hSetAbsAngle)
		LogError("[Gamedata] Could not find CBaseEntity::SetAbsAngles");

	//From mikusch!
	g_SDKCallRemoveImmediate = PrepSDKCall_RemoveImmediate(gamedata);
		

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBasePlayer::CheatImpulseCommands");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); //Player
	g_hImpulse = EndPrepSDKCall();
	if(!g_hImpulse)
		LogError("[Gamedata] Could not find CBasePlayer::CheatImpulseCommands");

#if defined ZR || defined RPG
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFPlayerShared::RecalculatePlayerBodygroups");
	if((g_hRecalculatePlayerBodygroups = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CTFPlayerShared::RecalculatePlayerBodygroups");
#endif

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseAnimating::InvalidateBoneCache");
	if((g_hInvalidateBoneCache = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::InvalidateBoneCache");
	
	
	//( const Vector &vecOrigin, const QAngle &vecAngles, const float fSpeed, const float fGravity, ProjectileType_t projectileType, CBaseEntity *pOwner, CBaseEntity *pScorer )
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFProjectile_Arrow::Create");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hCTFCreateArrow = EndPrepSDKCall();
	if(!g_hCTFCreateArrow)
		LogError("[Gamedata] Could not find CTFProjectile_Arrow::Create");
	//from kenzzer
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFWeaponBaseMelee::GetShootSound");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	if((SDKGetShootSound = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CTFWeaponBaseMelee::GetShootSound");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseAnimating::BecomeRagdollOnClient");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	SDKBecomeRagdollOnClient = EndPrepSDKCall();
	if(!SDKBecomeRagdollOnClient)
		LogError("[Gamedata] Could not find CBaseAnimating::BecomeRagdollOnClient");
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "Studio_FindAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//pAttachmentName
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hStudio_FindAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for Studio_FindAttachment");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if((g_hGetVectors = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseEntity::GetVectors!");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFPlayer::TeamFortress_SetSpeed()");
	SDKSetSpeed = EndPrepSDKCall();
	if(!SDKSetSpeed)
		LogError("[Gamedata] Could not find CTFPlayer::TeamFortress_SetSpeed()");

	
	//copied from 
	//https://github.com/bhopppp/Shavit-Surf-Timer/blob/289b9df123e61f2a0982ded688d2c611023b25f5/addons/sourcemod/scripting/shavit-replay-playback.sp#L204
	delete gamedata;
}

void SDKCall_EquipWearable(int client, int entity)
{
	if(SDKEquipWearable)
		SDKCall(SDKEquipWearable, client, entity);
}

stock void SDKCall_GetShootSound(int entity, int index, char[] buffer, int length)
{
	if(SDKGetShootSound)
		SDKCall(SDKGetShootSound, entity, buffer, length, index);
}

//( const Vector &vecOrigin, const QAngle &vecAngles, const float fSpeed, const float fGravity, ProjectileType_t projectileType, CBaseEntity *pOwner, CBaseEntity *pScorer )

#if defined ZR || defined RPG
stock int SDKCall_CTFCreateArrow(float VecOrigin[3], float VecAngles[3], const float fSpeed, const float fGravity, int projectileType, int Owner, int Scorer)
{
	if(g_hCTFCreateArrow)
		return SDKCall(g_hCTFCreateArrow, VecOrigin, VecAngles, fSpeed, fGravity, projectileType, Owner, Scorer);
	
	return -1;
}
#endif

/*		
( const Vector &position, const QAngle &angles, 
																	const Vector &velocity, const AngularImpulse &angVelocity, 
																	CBaseCombatCharacter *pOwner, const CTFWeaponInfo &weaponInfo, 
																	int iPipeBombType, float flMultDmg )
*/
/*
void SDKCall_CallCorrectWeaponSound(int WeaponIndex, int WeaponType, float duration = 1.0)
{
	if(g_hWeaponSound)
	{
		PrintToChatAll("testSound");
		SDKCall(g_hWeaponSound, WeaponIndex, WeaponType, duration);
	}
}
*/
/*
int SDKCall_CTFCreatePipe(float VecOrigin[3], const float VecAngles[3], const float fSpeed, const float angVelocity, int owner, int weaponinfo, int projectileType, float damage)
{
	if(g_hCTFCreatePipe)
		return SDKCall(g_hCTFCreatePipe, VecOrigin, VecAngles, fSpeed, angVelocity, owner, weaponinfo, projectileType, damage);
	
	return -1;
}
*/
void SDKCall_SetLocalOrigin(int index, float localOrigin[3])
{
	if(g_hSetLocalOrigin)
	{
		SDKCall(g_hSetLocalOrigin, index, localOrigin);
	}
}
void SDKCall_SetLocalAngles(int index, float Anglesl[3])
{
	if(g_hSetLocalAngles)
	{
		SDKCall(g_hSetLocalAngles, index, Anglesl);
	}
}

void SDKCall_InvalidateBoneCache(int index)
{
	SDKCall(g_hInvalidateBoneCache, index);
}

void SDKCall_SetAbsOrigin(int index, float AbsOrigin[3])
{
	if(g_hSetAbsOrigin)
	{
		SDKCall(g_hSetAbsOrigin, index, AbsOrigin);
	}
}

void SDKCall_SetAbsAngle(int index, float AbsAngle[3])
{
	if(g_hSetAbsAngle)
	{
		SDKCall(g_hSetAbsAngle, index, AbsAngle);
	}
}


#if defined ZR || defined RPG
stock void SDKCall_RecalculatePlayerBodygroups(int index)
{
	if(g_hRecalculatePlayerBodygroups)
	{
		SDKCall(g_hRecalculatePlayerBodygroups, GetPlayerSharedAddress(index));
	}
}

//https://github.com/nosoop/SM-TFUtils/blob/4802fa401a86d3088feb77c8a78d758c10806112/scripting/tf2utils.sp#L1067C1-L1067C1
static Address GetPlayerSharedAddress(int client) {
	return GetEntityAddress(client)
			+ view_as<Address>(FindSendPropInfo("CTFPlayer", "m_Shared"));
}
#endif	// ZR

int SDKCall_GetMaxHealth(int client)
{
	return SDKGetMaxHealth ? SDKCall(SDKGetMaxHealth, client) : GetEntProp(client, Prop_Data, "m_iMaxHealth");
}

int FindAttachment(int index, const char[] pAttachmentName)
{
	Address pStudioHdr = GetStudioHdr(index);
	if(pStudioHdr == Address_Null)
		return -1;
			
	return SDKCall(g_hStudio_FindAttachment, pStudioHdr, pAttachmentName) + 1;
}	


public Address GetStudioHdr(int index)
{
	if(IsValidEntity(index))
	{
		return view_as<Address>(GetEntData(index, FindDataMapInfo(index, "m_flFadeScale") + 28));
	}
		
	return Address_Null;
}	

void SnapEyeAngles(int client, const float viewAngles[3])
{
	SDKCall(g_hSnapEyeAngles, client, viewAngles);
}

void GetAttachment(int index, const char[] szName, float absOrigin[3], float absAngles[3])
{
	GetEntityAttachment(index, FindAttachment(index, szName), absOrigin, absAngles);
}	

void GetVectors(int client, float pForward[3], float pRight[3], float pUp[3])
{
	SDKCall(g_hGetVectors, client, pForward, pRight, pUp);
}

void SDKCall_BecomeRagdollOnClient(int entity, const float vec[3])
{
	SDKCall(SDKBecomeRagdollOnClient, entity, vec);
}

#if defined ZR || defined RPG
void StartPlayerOnlyLagComp(int client, bool Compensate_allies)
{
	if(g_GottenAddressesForLagComp)
	{
	//	StartLagCompResetValues();
		
		if(Compensate_allies)
		{
			b_LagCompAlliedPlayers = true;
		}
		SDKCall(g_hSDKStartLagComp, g_hSDKStartLagCompAddress, client, (GetEntityAddress(client) + view_as<Address>(OffsetLagCompStart_UserInfoReturn())));
//		StartLagCompensation_Base_Boss(client, true);
	}
}

void EndPlayerOnlyLagComp(int client)
{
	if(g_GottenAddressesForLagComp)
	{
	//	FinishLagCompensation_Base_boss();
		SDKCall(g_hSDKEndLagComp, g_hSDKEndLagCompAddress, client);
	}
}
#endif

void UpdateBlockedNavmesh()
{
//	sv_cheats.IntValue = 1;
	//this updates the nav.
	ServerCommand("sv_cheats 1; nav_load ; sv_cheats 0");
//	sv_cheats.IntValue = 0;
	
	//This broke and is probably inlined, above is a way easier method.
//	SDKCall(g_hSDKUpdateBlocked);
}	
/*
stock int SpawnBotCustom()
{
	PrintToChatAll("trest");
	ServerCommand("sv_cheats 1; bot ; sv_cheats 0");
//	int bot = CreateFakeClient(Name);
	
	int bot = SDKCall(
	gH_BotAddCommand,
	Name, // name
	false // bReportFakeClient
	);
	
//	if (IsValidClient(bot))
//	{
//		PrintToChatAll("party!");
//		SetFakeClientConVar(bot, "name", Name);
//	}

	return -1;
}
*/
//BIG thanks to backwards#8236 on discord for helping me out, YOU ARE MY HERO.

#if defined ZR || defined RPG
void Sdkcall_Load_Lagcomp()
{
	if(!g_GottenAddressesForLagComp)
	{
		GameData gamedata_lag_comp = LoadGameConfigFile("lagcompensation");
		g_GottenAddressesForLagComp = true;
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::StartLagCompensation");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue); //cmd? I dont know.
		if ((g_hSDKStartLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::StartLagCompensation");
		
		
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetFromConf(gamedata_lag_comp, SDKConf_Signature, "CLagCompensationManager::FinishLagCompensation");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
		if ((g_hSDKEndLagComp = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CLagCompensationManager::FinishLagCompensation");	
		
		delete gamedata_lag_comp;	
	}
}
#endif

stock void Manual_Impulse_101(int client, int health)
{

#if defined ZR
	ClientSaveRageMeterStatus(client);
	ClientSaveUber(client);
#endif

	SetConVarInt(sv_cheats, 1, false, false);
	
	SDKCall(g_hImpulse, client, 101);
	if(nav_edit.IntValue != 1)
	{
		SetConVarInt(sv_cheats, 0, false, false);
	}
	SDKCall_GiveCorrectAmmoCount(client);

	OnWeaponSwitchPost(client, GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));

#if defined ZR
	ClientApplyRageMeterStatus(client);
	ClientApplyMedigunUber(client);
	Clip_GiveAllWeaponsClipSizes(client);
#endif

	if(health > 0)
		SetEntityHealth(client, health);
}

void SDKCall_GiveCorrectAmmoCount(int client)
{
	//how quirky.
	SetAmmo(client, 1, 9999);
	SetAmmo(client, 2, 9999);
#if defined ZR
	SetAmmo(client, Ammo_Metal, CurrentAmmo[client][Ammo_Metal]);
	for(int i=Ammo_Jar; i<Ammo_MAX; i++)
	{
		SetAmmo(client, i, CurrentAmmo[client][i]);
	}
#endif
}
#if defined ZR
void SDKCall_ResetPlayerAndTeamReadyState()
{
	int entity = FindEntityByClassname(-1, "tf_gamerules");
	if(entity == -1)
	{
		return;
	}

	static int Size1;
	if(!Size1)
	{
		Size1 = GetEntPropArraySize(entity, Prop_Send, "m_bTeamReady");
	}
	
	for(int i; i < Size1; i++)
	{
		GameRules_SetProp("m_bTeamReady", false, _, i);
	}

	static int Size2;
	if(!Size2)
	{
		Size2 = GetEntPropArraySize(entity, Prop_Send, "m_bPlayerReady");
	}
	
	for(int i; i < Size2; i++)
	{
		GameRules_SetProp("m_bPlayerReady", false, _, i);
	}
}
#endif

void SDKCall_SetSpeed(int client)
{
	if(SDKSetSpeed)
	{
		SDKCall(SDKSetSpeed, client);
	}
	else
	{
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
}



static Handle PrepSDKCall_RemoveImmediate(GameData gamedata)
{
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "UTIL_RemoveImmediate");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	
	Handle call = EndPrepSDKCall();
	if (!call)
	{
		LogMessage("Failed to create SDKCall: UTIL_RemoveImmediate");
	}
	
	return call;
}

void SDKCall_RemoveImmediate(int entity)
{
	if (g_SDKCallRemoveImmediate)
	{
		SDKCall(g_SDKCallRemoveImmediate, entity);
	}
}