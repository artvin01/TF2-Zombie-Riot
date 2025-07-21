#pragma semicolon 1
#pragma newdecls required

#define VIEW_CHANGES

static const char HandModels[][] =
{
	"models/empty.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/zombie_riot/weapons/soldier_hands/c_soldier_arms.mdl", //needed custom model due to rocket in face.
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl"
};

static const char PlayerModels[][] =
{
	"models/player/scout.mdl",
	"models/player/scout.mdl",
	"models/player/sniper.mdl",
	"models/player/soldier.mdl",
	"models/player/demo.mdl",
	"models/player/medic.mdl",
	"models/player/heavy.mdl",
	"models/player/pyro.mdl",
	"models/player/spy.mdl",
	"models/player/engineer.mdl"
};


static const char RobotModels[][] =
{
	"models/bots/scout/bot_scout.mdl",
	"models/bots/scout/bot_scout.mdl",
	"models/bots/sniper/bot_sniper.mdl",
	"models/bots/soldier/bot_soldier.mdl",
	"models/bots/demo/bot_demo.mdl",
	"models/bots/medic/bot_medic.mdl",
	"models/bots/heavy/bot_heavy.mdl",
	"models/bots/pyro/bot_pyro.mdl",
	"models/bots/spy/bot_spy.mdl",
	"models/bots/engineer/bot_engineer.mdl"
};

static const char PlayerModelsCustom[][] =
{
	"models/bots/headless_hatman.mdl",
	"models/zombie_riot/player_model_add/model_player_1_3.mdl",
	"models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl",
	"models/bots/skeleton_sniper/skeleton_sniper.mdl",
	"models/zombie_riot/player_model_add/model_player_2_1.mdl",
};


static const char PlayerCustomHands[][] =
{
	"",
	"models/zombie_riot/player_model_add/model_player_hands_1_5.mdl",
	"models/sasamin/oneshot/zombie_riot_edit/niko_arms_01.mdl",
	"models/bots/skeleton_sniper/skeleton_sniper.mdl",
	"models/zombie_riot/player_model_add/model_player_hands_1_5.mdl",
};

int PlayerCustomModelBodyGroup[] =
{
	0,
	1,
	0,
	0,
	2,
};

enum
{
	HHH_SkeletonOverride = 0,
	BARNEY = 1,
	NIKO_2 = 2,
	SKELEBOY = 3,
	KLEINER = 4,
}

static int HandIndex[10];
static int PlayerIndex[10];
static int RobotIndex[10];
static int CustomIndex[sizeof(PlayerModelsCustom)];
static int CustomHandIndex[sizeof(PlayerCustomHands)];

static bool b_AntiSameFrameUpdate[MAXPLAYERS];

#if defined ZR
static int TeutonModelIndex;
#endif

void ViewChange_MapStart()
{
	for(int i; i<sizeof(HandIndex); i++)
	{
		HandIndex[i] = PrecacheModel(HandModels[i], true);
	}

	for(int i; i<sizeof(PlayerModels); i++)
	{
		PlayerIndex[i] = PrecacheModel(PlayerModels[i], true);
	}

	for(int i; i<sizeof(RobotIndex); i++)
	{
		RobotIndex[i] = PrecacheModel(RobotModels[i], true);
	}

	for(int i; i<sizeof(CustomIndex); i++)
	{
		CustomIndex[i] = PrecacheModel(PlayerModelsCustom[i], true);
	}

	for(int i; i<sizeof(CustomHandIndex); i++)
	{
		CustomHandIndex[i] = PlayerCustomHands[i][0] ? PrecacheModel(PlayerCustomHands[i], true) : 0;
	}
	Zero(b_AntiSameFrameUpdate);

#if defined ZR
	TeutonModelIndex = PrecacheModel(COMBINE_CUSTOM_MODEL, true);
#endif

	int entity = -1;
	while((entity=FindEntityByClassname(entity, "tf_wearable_vm")) != -1)
	{
		RemoveEntity(entity);
	}
}

void ViewChange_ClientDisconnect(int client)
{
	int entity = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(entity != -1)
	{
		i_Viewmodel_PlayerModel[client] = -1;
		TF2_RemoveWearable(client, entity);
	}
	
	entity = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(entity != -1)
	{
		WeaponRef_viewmodel[client] = -1;
		RemoveEntity(entity);
	}
	
	entity = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(entity != -1)
	{
		i_Worldmodel_WeaponModel[client] = -1;
		TF2_RemoveWearable(client, entity);
	}

	ViewChange_DeleteHands(client);
}

void OverridePlayerModel(int client, int index = -1, bool DontShowCosmetics = false)
{
	if(index == -1 || (CvarCustomModels.BoolValue && IsFileInDownloads("models/sasamin/oneshot/zombie_riot_edit/niko_05.mdl")))
	{
		b_HideCosmeticsPlayer[client] = DontShowCosmetics;
		i_PlayerModelOverrideIndexWearable[client] = index;
		if(ForceNiko)
		{
			b_HideCosmeticsPlayer[client] = true;
			i_PlayerModelOverrideIndexWearable[client] = NIKO_2;
		}
		ViewChange_Update(client, true);
		int entity;
		if(DontShowCosmetics)
		{
			while(TF2_GetWearable(client, entity))
			{
				if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) == entity)
					continue;

				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
			}
		}
		else
		{
			while(TF2_GetWearable(client, entity))
			{
				if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) == entity)
					continue;

				SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") &~ EF_NODRAW);
			}
		}
	}
}

void ViewChange_PlayerModel(int client)
{
	int ViewmodelPlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(IsValidEntity(ViewmodelPlayerModel))
	{
#if defined ZR
		TransferDispenserBackToOtherEntity(client, true);
#endif
		TF2_RemoveWearable(client, ViewmodelPlayerModel);
	}

#if defined ZR
	if(Rogue_GetChaosLevel() > 2 && !(GetURandomInt() % 9))
		return;
#endif

	int team = GetClientTeam(client);
	int entity = CreateEntityByName("tf_wearable");
	if(entity != -1)	// playermodel
	{
#if defined ZR
		i_CustomModelOverrideIndex[client] = -1;
		
		if(TeutonType[client] == TEUTON_NONE)
		{
			if(i_HealthBeforeSuit[client] == 0)
			{
				int index;
				int sound = -1;
				int body = -1;
				bool anim, noCosmetic;

				if(i_PlayerModelOverrideIndexWearable[client] >= 0 && i_PlayerModelOverrideIndexWearable[client] < sizeof(PlayerModelsCustom))
				{
					index = CustomIndex[i_PlayerModelOverrideIndexWearable[client]];
					sound = i_PlayerModelOverrideIndexWearable[client];
					body = PlayerCustomModelBodyGroup[i_PlayerModelOverrideIndexWearable[client]];
					anim = Viewchanges_PlayerModelsAnims[i_PlayerModelOverrideIndexWearable[client]];
					noCosmetic = true;
				}
				else
				{
					index = PlayerIndex[CurrentClass[client]];
				}

				if(Native_OnClientWorldmodel(client, CurrentClass[client], index, sound, body, anim, noCosmetic))
					OverridePlayerModel(client, -1, noCosmetic);

				SetEntProp(entity, Prop_Send, "m_nModelIndex", index);

				if(anim)
				{
					static char model[PLATFORM_MAX_PATH];
					ModelIndexToString(index, model, sizeof(model));
					SetVariantString(model);
				}
				else
				{
					SetVariantString(NULL_STRING);
				}

				AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
				i_CustomModelOverrideIndex[client] = sound;

				if(body != -1)
				{
					SetEntProp(entity, Prop_Send, "m_nBody", body);
					SetEntProp(client, Prop_Send, "m_nBody", body);
				}
			}
			else
			{
				SetEntProp(entity, Prop_Send, "m_nModelIndex", RobotIndex[CurrentClass[client]]);

				SetVariantString(NULL_STRING);
				AcceptEntityInput(client, "SetCustomModelWithClassAnimations");
			}

			UpdatePlayerFakeModel(client);
			MedicAdjustModel(client);
		}
		else
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndex", TeutonModelIndex);
			SetEntProp(entity, Prop_Send, "m_nBody", 9);
		}
#else
		UpdatePlayerFakeModel(client);
		MedicAdjustModel(client);
		SetEntProp(entity, Prop_Send, "m_nModelIndex", PlayerIndex[CurrentClass[client]]);
#endif
		
		SetEntProp(entity, Prop_Send, "m_fEffects", 129);
#if defined ZR
		if(CurrentModifOn() == SECONDARY_MERCS)
		{
			team = 3;
		}
#endif
		SetTeam(entity, team);
		SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
		SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
		SetEntityCollisionGroup(entity, 11);
		SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
		DispatchSpawn(entity);
		SetVariantString("!activator");
		ActivateEntity(entity);

		SDKCall_EquipWearable(client, entity);
		
		SetEntProp(client, Prop_Send, "m_nRenderFX", 6);

		i_Viewmodel_PlayerModel[client] = EntIndexToEntRef(entity);
		//get its attachemt once, it probably has to authorise it once to work correctly for later.
		//otherwise, trying to get its attachment breaks, i dont know why, it has to be here.
		float flPos[3];
		float flAng[3];
		GetAttachment(entity, "flag", flPos, flAng);
#if defined ZR
		TransferDispenserBackToOtherEntity(client, false);
#endif

#if defined RPG
		Party_PlayerModel(client, PlayerModels[CurrentClass[client]]);
#endif

	}
}

#if defined ZR || defined RPG
public void AntiSameFrameUpdateRemove0(int client)
{
	b_AntiSameFrameUpdate[client] = false;
}


void Viewchange_UpdateDelay(int client)
{
	RequestFrame(Viewchange_UpdateDelay_Internal, EntIndexToEntRef(client));
}

void Viewchange_UpdateDelay_Internal(int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
		return;

	ViewChange_Update(client);
}
void ViewChange_Update(int client, bool full = true)
{
	if(full)
		ViewChange_DeleteHands(client);
	

	//Some weapons or things call it in the same frame, lets prevent this!
	//If people somehow spam switch, or multiple things call it, lets wait a frame before updating, it allows for easy use iwthout breaking everything
	if(b_AntiSameFrameUpdate[client])
		return;
		
	RequestFrame(AntiSameFrameUpdateRemove0, client);

	b_AntiSameFrameUpdate[client] = true;
	char classname[36];
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon != -1)
	{
		f_Client_BackwardsWalkPenalty[client] = f_Weapon_BackwardsWalkPenalty[weapon];
		GetEntityClassname(weapon, classname, sizeof(classname));
	}
	
	ViewChange_Switch(client, weapon, classname);
}

stock bool ViewChange_IsViewmodelRef(int ref)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(i_Viewmodel_PlayerModel[client] == ref)
			return true;
		
		if(WeaponRef_viewmodel[client] == ref)
			return true;
		
		if(i_Worldmodel_WeaponModel[client] == ref)
			return true;
		
		if(HandRef[client] == ref)
			return true;
	}

	return false;
}

void ViewChange_Switch(int client, int active, const char[] classname)
{
	int entity = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(entity != -1)
	{
		WeaponRef_viewmodel[client] = -1;
		RemoveEntity(entity);
	}
	
	entity = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(entity != -1)
	{
		i_Worldmodel_WeaponModel[client] = -1;
		TF2_RemoveWearable(client, entity);
	}
	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity != -1)
	{
		if(active != -1)
		{
			int itemdefindex = GetEntProp(active, Prop_Send, "m_iItemDefinitionIndex");
			TFClassType class = TF2_GetWeaponClass(itemdefindex, CurrentClass[client], TF2_GetClassnameSlot(classname, true));

			if(i_WeaponForceClass[active] > 0)
			{
				if(i_WeaponForceClass[active] > 10) //it is an allclass weapon, we want to force the weapon into the class the person holds
				//some weapons for engi or spy just don do this and take pyro and look ugly as fuck.
				{
					//exception for engineer, hes always bugged, force medic.
					class = view_as<TFClassType>(CurrentClass[client]);
					if(class == TFClass_Engineer)
					{
						class = TFClass_Medic;
					}
				}
				else
				{
					class = view_as<TFClassType>(i_WeaponForceClass[active]);
				}
			}

			
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[class]);
			
			int team = GetClientTeam(client);
#if defined ZR
			if(CurrentModifOn() == SECONDARY_MERCS)
			{
				team = 3;
			}
#endif
			SetTeam(entity, team);
			SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
			int model = GetEntProp(active, Prop_Send, "m_iWorldModelIndex");
			
			entity = CreateViewmodel(client, model, i_WeaponModelIndexOverride[active] > 0 ? i_WeaponModelIndexOverride[active] : model, active, true);
			if(entity != -1)	// Weapon viewmodel
			{
				WeaponRef_viewmodel[client] = EntIndexToEntRef(entity);

				if(i_WeaponVMTExtraSetting[active] != -1)
				{
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[active];
#if defined ZR
					if(IsSensalWeapon(i_CustomWeaponEquipLogic[active]))
					{
						SensalApplyRecolour(client, entity);
					}
					else
#endif

					{
						SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[active]);
					}
				}
				if(i_WeaponBodygroup[active] != -1)
				{
					SetVariantInt(i_WeaponBodygroup[active]);
					AcceptEntityInput(entity, "SetBodyGroup");
				}
			}

			entity = CreateEntityByName("tf_wearable");
			if(entity != -1)	// Weapon worldmodel
			{
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
				
				if(i_WeaponVMTExtraSetting[active] != -1)
				{
					i_WeaponVMTExtraSetting[entity] = i_WeaponVMTExtraSetting[active];
#if defined ZR
					if(IsSensalWeapon(i_CustomWeaponEquipLogic[active]))
					{
						SensalApplyRecolour(client, entity);
					}
					else
#endif

					{
						SetEntityRenderColor(entity, 255, 255, 255, i_WeaponVMTExtraSetting[active]);
					}
				}
				if(i_WeaponBodygroup[active] != -1)
				{
					SetVariantInt(i_WeaponBodygroup[active]);
					AcceptEntityInput(entity, "SetBodyGroup");
				}

				ImportSkinAttribs(entity, active);

				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
#if defined ZR
				if(CurrentModifOn() == SECONDARY_MERCS)
				{
					team = 3;
				}
#endif
				SetTeam(entity, team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				i_Worldmodel_WeaponModel[client] = EntIndexToEntRef(entity);
			//	SetEntPropFloat(entity, Prop_Send, "m_flPoseParameter", GetEntPropFloat(active, Prop_Send, "m_flPoseParameter"));
				
				SDKCall_EquipWearable(client, entity);
				DataPack pack = new DataPack();
				pack.WriteCell(EntIndexToEntRef(active));
				pack.WriteCell(EntIndexToEntRef(entity));
				//needs to be delayed...
				RequestFrame(AdjustWeaponFrameDelay, pack);
			}
			
			HidePlayerWeaponModel(client, active);
			
			//if(WeaponClass[client] != class)
			{
				WeaponClass[client] = class;
				
				TF2_SetPlayerClass_ZR(client, WeaponClass[client], _, false);
				Store_ApplyAttribs(client);
			}
			
			//ViewChange_DeleteHands(client);
			ViewChange_UpdateHands(client, CurrentClass[client]);

#if defined ZR
			if(TeutonType[client] == TEUTON_NONE)
			{
				UpdatePlayerFakeModel(client);
			}
			else
			{
				int ViewmodelPlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
				if(IsValidEntity(ViewmodelPlayerModel))
				{
					SetEntProp(ViewmodelPlayerModel, Prop_Send, "m_nBody", 9);
				}
			}
#else
			UpdatePlayerFakeModel(client);
#endif
			MedicAdjustModel(client);

			int iMaxWeapons = GetMaxWeapons(client);
			for (int i = 0; i < iMaxWeapons; i++)
			{
				int weapon = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
				if (weapon != INVALID_ENT_REFERENCE)
					SetEntProp(weapon, Prop_Send, "m_nCustomViewmodelModelIndex", GetEntProp(weapon, Prop_Send, "m_nModelIndex"));
			}
#if defined ZR
			SDKHooks_UpdateMarkForDeath(client, true);
#endif
			f_UpdateModelIssues[client] = GetGameTime() + 0.1;
			return;
		}
	}

	ViewChange_DeleteHands(client);
	WeaponClass[client] = TFClass_Unknown;
}

void AdjustWeaponFrameDelay(DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int wearable = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(weapon) && IsValidEntity(wearable))
	{
		float AttribDo = Attributes_Get(weapon, 4021, -1.0);
		if(AttribDo != -1.0)
		{
			SetEntProp(wearable, Prop_Send, "m_nSkin", RoundToNearest(AttribDo));
		}
		AttribDo = Attributes_Get(weapon, 542, -1.0);
		if(AttribDo != -1.0)
		{
			Attributes_Set(wearable, 542, AttribDo);
		}
	}
	delete pack;
}
void MedicAdjustModel(int client)
{
	int ViewmodelPlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
	if(!IsValidEntity(ViewmodelPlayerModel))
		return;
		
	if(i_PlayerModelOverrideIndexWearable[client] >= 0)
	{
		return;
	}

	if(CurrentClass[client] != view_as<TFClassType>(5))
		return;
	
	bool RemoveMedicBackpack = true;
	int ie;
	int entity;
	while(TF2_GetItem(client, entity, ie))
	{
		int index = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 211:
			{
				if(b_IsAMedigun[entity])
				{
					RemoveMedicBackpack = false;
					break;
				}
			}
		}
	}
	if(RemoveMedicBackpack)
	{
		SetEntProp(ViewmodelPlayerModel, Prop_Send, "m_nBody", 1);
	}
}

void ViewChange_DeleteHands(int client)
{
	int entity = EntRefToEntIndex(HandRef[client]);
	HandRef[client] = INVALID_ENT_REFERENCE;

	if(entity != -1)
		RemoveEntity(entity);
}

int ViewChange_UpdateHands(int client, TFClassType class)
{
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity != -1)
	{
		SetEntPropEnt(entity, Prop_Send, "m_hWeaponAssociatedWith", weapon);
	}
	else
	{
		int model = HandIndex[view_as<int>(class)];
		if(i_PlayerModelOverrideIndexWearable[client] >= 0 && i_PlayerModelOverrideIndexWearable[client] < sizeof(CustomHandIndex) && CustomHandIndex[i_PlayerModelOverrideIndexWearable[client]])
		{
			model = CustomHandIndex[i_PlayerModelOverrideIndexWearable[client]];
		}
		
		entity = CreateViewmodel(client, model, model, weapon);
		if(i_PlayerModelOverrideIndexWearable[client] >= 0)
			SetEntProp(entity, Prop_Send, "m_nBody", PlayerCustomModelBodyGroup[i_PlayerModelOverrideIndexWearable[client]]);
			
		if(entity != -1)
			HandRef[client] = EntIndexToEntRef(entity);
	}
	return entity;
}

stock bool Viewchanges_NotAWearable(int client, int wearable)
{
	if(EntRefToEntIndex(HandRef[client]) == wearable)
		return true;
	if(EntRefToEntIndex(WeaponRef_viewmodel[client]) == wearable)
		return true;
	if(EntRefToEntIndex(i_Viewmodel_PlayerModel[client]) == wearable)
		return true;
	if(EntRefToEntIndex(i_Worldmodel_WeaponModel[client]) == wearable)
		return true;

	return false;
}

static int CreateViewmodel(int client, int modelAnims, int modelOverride, int weapon, bool copy = false)
{
	int wearable = CreateEntityByName("tf_wearable_vm");
	
	float vecOrigin[3], vecAngles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", vecAngles);
	TeleportEntity(wearable, vecOrigin, vecAngles, NULL_VECTOR);

	if(copy)
		ImportSkinAttribs(wearable, weapon);
	
	SetEntProp(wearable, Prop_Send, "m_bValidatedAttachedEntity", true);
	SetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(wearable, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(wearable, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL);
	
	DispatchSpawn(wearable);
	
	SetEntProp(wearable, Prop_Send, "m_nModelIndex", modelAnims);	// After DispatchSpawn, otherwise CEconItemView overrides it
	/*
	char buffer[256];
	ModelIndexToString(modelAnims, buffer, sizeof(buffer));
	PrintToChatAll("Anims: '%s'", buffer);
	ModelIndexToString(modelOverride, buffer, sizeof(buffer));
	PrintToChatAll("Override: '%s'", buffer);
*/
	SetEntProp(wearable, Prop_Data, "m_nModelIndexOverrides", modelOverride);

	SetVariantString("!activator");
	AcceptEntityInput(wearable, "SetParent", GetEntPropEnt(client, Prop_Send, "m_hViewModel"));

	SetEntPropEnt(wearable, Prop_Send, "m_hWeaponAssociatedWith", weapon);
	
	return wearable;
}

static void ImportSkinAttribs(int wearable, int weapon)
{
	int index = i_WeaponFakeIndex[weapon] > 0 ? i_WeaponFakeIndex[weapon] : GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	SetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex", index);
	SetEntProp(wearable, Prop_Send, "m_bOnlyIterateItemViewAttributes", true);
	Attributes_Set(wearable, 834, Attributes_Get(weapon, 834, 0.0));
	Attributes_Set(wearable, 725, Attributes_Get(weapon, 725, 0.0));
#if defined RPG
	// TODO: Add proper randomizing
	Attributes_Set(wearable, 866, float(index));
#elseif defined ZR
	Attributes_Set(wearable, 866, float(CurrentGame));
#endif
#if defined RPG
	Attributes_Set(wearable, 867, float(index));
#else
	Attributes_Set(wearable, 867, float(index));//Attributes_Get(weapon, 867, 0.0));
#endif
	Attributes_Set(wearable, 2013, Attributes_Get(weapon, 2013, 0.0));
	Attributes_Set(wearable, 2014, Attributes_Get(weapon, 2014, 0.0));
	Attributes_Set(wearable, 2025, Attributes_Get(weapon, 2025, 0.0));
	Attributes_Set(wearable, 2027, Attributes_Get(weapon, 2027, 0.0));
	Attributes_Set(wearable, 2053, Attributes_Get(weapon, 2053, 0.0));
}

void HidePlayerWeaponModel(int client, int entity, bool OnlyHide = false)
{
	SetEntityRenderMode(entity, RENDER_NONE);
//	SetEntityRenderColor(entity, 0, 0, 0, 0);
//	SetEntProp(entity, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
//	SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 0.00001);
	if(OnlyHide)
		return;
	int EntityWeaponModel = EntRefToEntIndex(i_Worldmodel_WeaponModel[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[entity]);
	}
	EntityWeaponModel = EntRefToEntIndex(WeaponRef_viewmodel[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverrideViewmodel[entity]);
	}
	f_WeaponVolumeStiller[client] = f_WeaponVolumeStiller[entity];
	f_WeaponVolumeSetRange[client] = f_WeaponVolumeSetRange[entity];
}
