#pragma semicolon 1
#pragma newdecls required

static Handle SDKEquipWearable;
static Handle SDKGetMaxHealth;
//static Handle g_hGetAttachment;
//static Handle g_hStudio_FindAttachment;

//static Handle g_hSetLocalAngle;
//static Handle g_hSetAbsOrigin;
//static Handle g_hSetAbsAngle;
static Handle g_hInvalidateBoneCache;

static Handle g_hCTFCreateArrow;
//static Handle g_hCTFCreatePipe;
//Handle g_hSDKMakeCarriedObject;
//static Handle g_hGetVectors;
//static Handle g_hWeaponSound;
//static Handle g_hSDKPlaySpecificSequence;
//static Handle g_hDoAnimationEvent;

static Handle g_hSDKStartLagComp;
static Handle g_hSDKEndLagComp;
static Handle g_hSDKUpdateBlocked;

static Handle g_hImpulse;

static Handle SDKGetShootSound;

static DynamicHook g_hDHookItemIterateAttribute;
static int g_iCEconItem_m_Item;
static int g_iCEconItemView_m_bOnlyIterateItemViewAttributes;

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
		
	//CBaseAnimating::LookupBone( const char *szName )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetLocalOrigin");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	if ((g_hLookupBone = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::LookupBone signature!");
	
	//void CBaseAnimating::GetBonePosition ( int iBone, Vector &origin, QAngle &angles )
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseAnimating::GetBonePosition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if ((g_hGetBonePosition = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for CBaseAnimating::GetBonePosition signature!");
	

	//	https://github.com/Wilzzu/testing/blob/18a3680a9a1c8bdabc30c504bbf9467ac6e7d7b4/samu/addons/sourcemod/scripting/shavit-replay.sp

	//	Thanks to nosoop for pointing soemthing like this out to me
	//	https://discord.com/channels/335290997317697536/335290997317697536/1038513919695802488  in the allied modders discord
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "NextBotCreatePlayerBot<CTFBot>");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);       // const char *name
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);   // bool bReportFakeClient
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer); // CTFBot*
	gH_BotAddCommand = EndPrepSDKCall();

	if(!gH_BotAddCommand)
		SetFailState("[Gamedata] Unable to prepare SDKCall for NextBotCreatePlayerBot<CTFBot>");

	//CBasePlayer
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBasePlayer::SnapEyeAngles");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	if ((g_hSnapEyeAngles = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBasePlayer::SnapEyeAngles!");


		/*
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetAbsVelocity");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	if ((g_hSetAbsVelocity = EndPrepSDKCall()) == null) SetFailState("Failed to create SDKCall for CBaseEntity::SetAbsVelocity");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseEntity::SetLocalAngles");
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef);
	g_hSetLocalAngle = EndPrepSDKCall();
	if(!g_hSetLocalAngle)
		LogError("[Gamedata] Could not find CBaseEntity::SetLocalAngles");
		
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
		*/
		


	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBasePlayer::CheatImpulseCommands");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain); //Player
	g_hImpulse = EndPrepSDKCall();
	if(!g_hImpulse)
		LogError("[Gamedata] Could not find CBasePlayer::CheatImpulseCommands");
		
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
		
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFNavMesh::ComputeBlockedArea");
	g_hSDKUpdateBlocked = EndPrepSDKCall();
	
	/*
	// void CBaseCombatWeapon::WeaponSound( WeaponSound_t sound_type, float soundtime )
	StartPrepSDKCall(cbas);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CBaseCombatWeapon::WeaponSound");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hWeaponSound = EndPrepSDKCall();
	if(!g_hWeaponSound)
		LogError("[Gamedata] Could not find CBaseCombatWeapon::WeaponSound");
	*/
	
#if defined ZR
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CObjectDispenser::MakeCarriedObject");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
	if ((g_hSDKMakeCarriedObjectDispenser = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CObjectDispenser::MakeCarriedObject");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CObjectSentrygun::MakeCarriedObject");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer); //Player
	if ((g_hSDKMakeCarriedObjectSentry = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed To create SDKCall for CObjectSentrygun::MakeCarriedObject");
#endif
	
	//from kenzzer
	
	int iOffset = GameConfGetOffset(gamedata, "CEconItemView::IterateAttributes");
	g_hDHookItemIterateAttribute = new DynamicHook(iOffset, HookType_Raw, ReturnType_Void, ThisPointer_Address);
	if (g_hDHookItemIterateAttribute == null)
	{
		 SetFailState("Failed to create hook CEconItemView::IterateAttributes offset from SF2 gamedata!");
	}
	g_hDHookItemIterateAttribute.AddParam(HookParamType_ObjectPtr);

	g_iCEconItem_m_Item = FindSendPropInfo("CEconEntity", "m_Item");
	FindSendPropInfo("CEconEntity", "m_bOnlyIterateItemViewAttributes", _, _, g_iCEconItemView_m_bOnlyIterateItemViewAttributes);
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTFWeaponBaseMelee::GetShootSound");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
	if((SDKGetShootSound = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CTFWeaponBaseMelee::GetShootSound");

	delete gamedata;
	
	Handle hConf = LoadGameConfigFile("tf2.pets");

	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "CBaseAnimating::GetAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//iAttachment
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absOrigin
	PrepSDKCall_AddParameter(SDKType_QAngle, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK); //absAngles
	if((g_hGetAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for CBaseAnimating::GetAttachment");
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "Studio_FindAttachment");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);	//pStudioHdr
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);		//pAttachmentName
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);	//return index
	if((g_hStudio_FindAttachment = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Call for Studio_FindAttachment");
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CBaseEntity::GetVectors");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef, _, VENCODE_FLAG_COPYBACK);
	if((g_hGetVectors = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create Virtual Call for CBaseEntity::GetVectors!");
	
	delete hConf;
	/*
	Handle ZConf = LoadGameConfigFile("zombie_riot");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ZConf, SDKConf_Signature, "CTFPlayer::PlaySpecificSequence");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	g_hSDKPlaySpecificSequence = EndPrepSDKCall();
	if (g_hSDKPlaySpecificSequence == null)
		LogMessage("Failed to create call: CTFPlayer::PlaySpecificSequence!");
		
	//void				DoAnimationEvent( PlayerAnimEvent_t event, int mData = 0 );
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ZConf, SDKConf_Virtual, "CTFPlayerAnimState::DoAnimationEvent");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue); //event is probably int?
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_ByValue); //int.
	g_hDoAnimationEvent = EndPrepSDKCall();
	if(!g_hDoAnimationEvent)
		LogError("[Gamedata] Could not find CTFPlayerAnimState::DoAnimationEvent");
		
	//Gotten PlaySpecificSequence from https://github.com/redsunservers/VSH-Rewrite/blob/f2bff50693115f469c9558a7eb03a60b5f3a8a59/addons/sourcemod/gamedata/vsh.txt
	
	delete ZConf;
	*/
}

void SDKCall_EquipWearable(int client, int entity)
{
	if(SDKEquipWearable)
		SDKCall(SDKEquipWearable, client, entity);
}

void SDKCall_GetShootSound(int entity, int index, char[] buffer, int length)
{
	if(SDKGetShootSound)
		SDKCall(SDKGetShootSound, entity, buffer, length, index);
}

//( const Vector &vecOrigin, const QAngle &vecAngles, const float fSpeed, const float fGravity, ProjectileType_t projectileType, CBaseEntity *pOwner, CBaseEntity *pScorer )

int SDKCall_CTFCreateArrow(float VecOrigin[3], float VecAngles[3], const float fSpeed, const float fGravity, int projectileType, int Owner, int Scorer)
{
	if(g_hCTFCreateArrow)
		return SDKCall(g_hCTFCreateArrow, VecOrigin, VecAngles, fSpeed, fGravity, projectileType, Owner, Scorer);
	
	return -1;
}

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
/*
void SDKCall_SetLocalAngle(int index, float localAngle[3])
{
	if(g_hSetLocalAngle)
	{
		SDKCall(g_hSetLocalAngle, index, localAngle);
	}
}
*/
void SDKCall_InvalidateBoneCache(int index)
{
	SDKCall(g_hInvalidateBoneCache, index);
}
/*
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
*/
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

void SnapEyeAngles(int client, float viewAngles[3])
{
	SDKCall(g_hSnapEyeAngles, client, viewAngles);
}

/*void SetAbsVelocity(int client, float viewAngles[3])
{
	SDKCall(g_hSetAbsVelocity, client, viewAngles);
}*/

void GetAttachment(int index, const char[] szName, float absOrigin[3], float absAngles[3])
{
	SDKCall(g_hGetAttachment, index, FindAttachment(index, szName), absOrigin, absAngles);
}	
/*
bool SDKCall_PlaySpecificSequence(int iClient, const char[] sAnimationName)
{
	return SDKCall(g_hSDKPlaySpecificSequence, iClient, sAnimationName);
}

void SDKCall_DoAnimationEvent(int iClient, int event_int, int extra_data = 0)
{
	SDKCall(g_hDoAnimationEvent, iClient, event_int, extra_data);
}*/


void GetVectors(int client, float pForward[3], float pRight[3], float pUp[3])
{
	SDKCall(g_hGetVectors, client, pForward, pRight, pUp);
}

void GetBoneAnglesAndPos(int client, char[] BoneName, float origin[3], float angles[3])
{
	int iBone = SDKCall(g_hLookupBone, client, BoneName);
	if(iBone == -1)
		return;
		
	SDKCall(g_hGetBonePosition, client, iBone, origin, angles);
}

void StartPlayerOnlyLagComp(int client, bool Compensate_allies)
{
	if(g_GottenAddressesForLagComp)
	{
	//	StartLagCompResetValues();
		
		if(Compensate_allies)
		{
			b_LagCompAlliedPlayers = true;
		}
		SDKCall(g_hSDKStartLagComp, g_hSDKStartLagCompAddress, client, (GetEntityAddress(client) + view_as<Address>(3512)));
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

void UpdateBlockedNavmesh()
{
	SDKCall(g_hSDKUpdateBlocked);
}	


static MRESReturn CEconItemView_IterateAttributes(Address pThis, DHookParam hParams)
{
    StoreToAddress(pThis + view_as<Address>(g_iCEconItemView_m_bOnlyIterateItemViewAttributes), true, NumberType_Int8, false);
    return MRES_Ignored;
}

static MRESReturn CEconItemView_IterateAttributes_Post(Address pThis, DHookParam hParams)
{
    StoreToAddress(pThis + view_as<Address>(g_iCEconItemView_m_bOnlyIterateItemViewAttributes), false, NumberType_Int8, false);
    return MRES_Ignored;
}

stock void TF2Items_OnGiveNamedItem_Post_SDK(int iClient, char[] sClassname, int iItemDefIndex, int iLevel, int iQuality, int iEntity)
{
	Address pCEconItemView = GetEntityAddress(iEntity) + view_as<Address>(g_iCEconItem_m_Item);
	g_hDHookItemIterateAttribute.HookRaw(Hook_Pre, pCEconItemView, CEconItemView_IterateAttributes);
	g_hDHookItemIterateAttribute.HookRaw(Hook_Post, pCEconItemView, CEconItemView_IterateAttributes_Post);
}

stock int SpawnBotCustom(const char[] Name, bool bReportFakeClient)
{
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

	return bot;
}

//BIG thanks to backwards#8236 on discord for helping me out, YOU ARE MY HERO.

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

void Manual_Impulse_101(int client, int health)
{
	int ie, entity;
	while(TF2_GetItem(client, entity, ie))
	{
		int index = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 411:
			{
				if(HasEntProp(entity, Prop_Send, "m_flChargeLevel"))
				{
					if(f_MedigunChargeSave[client][0] == 0.0)
					{
						f_MedigunChargeSave[client][0] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
					}
				}
			}
			case 211:
			{
				if(HasEntProp(entity, Prop_Send, "m_flChargeLevel"))
				{
					if(f_MedigunChargeSave[client][1] == 0.0)
					{
						f_MedigunChargeSave[client][1] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
					}
				}
			}
			case 998:
			{
				if(HasEntProp(entity, Prop_Send, "m_flChargeLevel"))
				{
					if(f_MedigunChargeSave[client][2] == 0.0)
					{
						f_MedigunChargeSave[client][2] = GetEntPropFloat(entity, Prop_Send, "m_flChargeLevel");
					}
				}
			}
		}
	}

	SetConVarInt(sv_cheats, 1, false, false);
	
	SDKCall(g_hImpulse, client, 101);
	if(nav_edit.IntValue != 1)
	{
		SetConVarInt(sv_cheats, 0, false, false);
	}
	
	
	float host_timescale;
	host_timescale = GetConVarFloat(cvarTimeScale);
	
	if(host_timescale != 1.0)
	{
		for(int i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SendConVarValue(i, sv_cheats, "1");
			}
		}
	}
	
	//how quirky.
	SetAmmo(client, 1, 9999);
	SetAmmo(client, 2, 9999);
	SetAmmo(client, Ammo_Metal, CurrentAmmo[client][Ammo_Metal]);
	for(int i=Ammo_Jar; i<Ammo_MAX; i++)
	{
		SetAmmo(client, i, CurrentAmmo[client][i]);
	}
	
#if defined ZR
	if(EscapeMode)
	{
		SetAmmo(client, Ammo_Metal, 99099); //just give infinite metal. There is no reason not to. (in Escape.)
		SetAmmo(client, 21, 99999);
	}
#endif
	
	SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 0.0);
//	SetEntProp(client, Prop_Send, "m_bWearingSuit", true);
//	SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 0.0); //No cloak regen at all.
	OnWeaponSwitchPost(client, GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"));
	
	
	int iea, weapon;
	while(TF2_GetItem(client, weapon, iea))
	{
		int index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 411:
			{
				if(HasEntProp(weapon, Prop_Send, "m_flChargeLevel"))
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][0]);
					f_MedigunChargeSave[client][0] = 0.0;
				}
			}
			case 211:
			{
				if(HasEntProp(weapon, Prop_Send, "m_flChargeLevel"))
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][1]);
					f_MedigunChargeSave[client][1] = 0.0;
				}
			}
			case 998:
			{
				if(HasEntProp(weapon, Prop_Send, "m_flChargeLevel"))
				{
					SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", f_MedigunChargeSave[client][2]);
					f_MedigunChargeSave[client][2] = 0.0;
				}
			}
		}
	}
	
	if(health > 0)
		SetEntityHealth(client, health);
}
