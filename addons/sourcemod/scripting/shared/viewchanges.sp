#pragma semicolon 1
#pragma newdecls required


static const char HandModels[][] =
{
	"models/empty.mdl",
	"models/weapons/c_models/c_scout_arms.mdl",
	"models/weapons/c_models/c_sniper_arms.mdl",
	"models/weapons/c_models/c_soldier_arms.mdl",
	"models/weapons/c_models/c_demo_arms.mdl",
	"models/weapons/c_models/c_medic_arms.mdl",
	"models/weapons/c_models/c_heavy_arms.mdl",
	"models/weapons/c_models/c_pyro_arms.mdl",
	"models/weapons/c_models/c_spy_arms.mdl",
	"models/weapons/c_models/c_engineer_arms.mdl",
	"models/sasamin/oneshot/zombie_riot_edit/niko_arms_01.mdl"
};

//	"models/sasamin/oneshot/zombie_riot_edit/niko_arms_01.mdl"

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


static int HandIndex[11];
static int PlayerIndex[10];
static int RobotIndex[10];
static int HandRef[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS];
static int TeutonModelIndex;

void ViewChange_MapStart()
{
	for(int i; i<11; i++)
	{
		HandIndex[i] = PrecacheModel(HandModels[i], true);
	}

	for(int i; i<10; i++)
	{
		PlayerIndex[i] = PrecacheModel(PlayerModels[i], true);
	}

	for(int i; i<10; i++)
	{
		RobotIndex[i] = PrecacheModel(RobotModels[i], true);
	}

	TeutonModelIndex = PrecacheModel(COMBINE_CUSTOM_MODEL, true);
	
	PrecacheModel(NIKO_PLAYERMODEL);
}

void ViewChange_PlayerModel(int client)
{
	{
		if(b_IsPlayerNiko[client])
		{
			SetVariantString(NIKO_PLAYERMODEL);
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", true);

#if defined RPG
			Party_PlayerModel(client, NIKO_PLAYERMODEL);
#endif

		}
		else
		{
			int team = GetClientTeam(client);
			int entity = CreateEntityByName("tf_wearable");
			if(entity > MaxClients)	// Weapon viewmodel
			{
#if defined ZR
				if(TeutonType[client] == TEUTON_NONE)
				{
					if(i_HealthBeforeSuit[client] == 0)
					{
						SetEntProp(entity, Prop_Send, "m_nModelIndex", PlayerIndex[CurrentClass[client]]);
					}
					else
					{
						SetEntProp(entity, Prop_Send, "m_nModelIndex", RobotIndex[CurrentClass[client]]);
					}
					UpdatePlayerFakeModel(client);

				}
				else
				{
					SetEntProp(entity, Prop_Send, "m_nModelIndex", TeutonModelIndex);
					SetEntProp(entity, Prop_Send, "m_nBody", 9);
				}
#else
				SetEntProp(entity, Prop_Send, "m_nModelIndex", PlayerIndex[CurrentClass[client]]);
#endif
				
				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
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

#if defined RPG
				Party_PlayerModel(client, PlayerModels[CurrentClass[client]]);
#endif

			}
		}
	}
}

void ViewChange_Switch(int client, int active, const char[] buffer = "")
{
	int entity = EntRefToEntIndex(WeaponRef[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);
	
	entity = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);

	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity > MaxClients)
	{
		if(active > MaxClients)
		{
			int itemdefindex = GetEntProp(active, Prop_Send, "m_iItemDefinitionIndex");
			TFClassType class = TF2_GetWeaponClass(itemdefindex, CurrentClass[client], TF2_GetClassnameSlot(buffer, true));

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

			// entity here is m_hViewModel
			/*	
				using EF_NODRAW works but it makes the animations mess up for spectators, currently no fix is known.
			*/
			//SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
			
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[class]);

			entity = CreateEntityByName("tf_wearable_vm");
			if(entity > MaxClients)	// Weapon viewmodel
			{
				int team = GetClientTeam(client);
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
				
				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				WeaponRef[client] = EntIndexToEntRef(entity);
				SetEntPropFloat(entity, Prop_Send, "m_flPoseParameter", GetEntPropFloat(active, Prop_Send, "m_flPoseParameter"));

				SDKCall_EquipWearable(client, entity);
			}

			entity = CreateEntityByName("tf_wearable");
			if(entity > MaxClients)	// Weapon worldmodel
			{
				int team = GetClientTeam(client);
				if(i_WeaponModelIndexOverride[active] > 0)
					SetEntProp(entity, Prop_Send, "m_nModelIndex", i_WeaponModelIndexOverride[active]);
				else
					SetEntProp(entity, Prop_Send, "m_nModelIndex", GetEntProp(active, Prop_Send, "m_iWorldModelIndex"));
				
				SetEntProp(entity, Prop_Send, "m_fEffects", 129);
				SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
				SetEntProp(entity, Prop_Send, "m_nSkin", team-2);
				SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
				SetEntityCollisionGroup(entity, 11);
				SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
				
				DispatchSpawn(entity);
				SetVariantString("!activator");
				ActivateEntity(entity);

				i_Viewmodel_WeaponModel[client] = EntIndexToEntRef(entity);
				SetEntPropFloat(entity, Prop_Send, "m_flPoseParameter", GetEntPropFloat(active, Prop_Send, "m_flPoseParameter"));

				SDKCall_EquipWearable(client, entity);
			}
			
			HidePlayerWeaponModel(client, active);
					
			//if(WeaponClass[client] != class)
			{
				WeaponClass[client] = class;
				
				TF2_SetPlayerClass(client, WeaponClass[client], _, false);
				Store_ApplyAttribs(client);
				
				ViewChange_DeleteHands(client);
				ViewChange_UpdateHands(client, CurrentClass[client]);
			}

			#if defined ZR
			if(TeutonType[client] == TEUTON_NONE)
			{
				UpdatePlayerFakeModel(client);
			}
			else
			#endif
			{
				int ViewmodelPlayerModel = EntRefToEntIndex(i_Viewmodel_PlayerModel[client]);
				if(IsValidEntity(ViewmodelPlayerModel))
				{
					SetEntProp(ViewmodelPlayerModel, Prop_Send, "m_nBody", 9);
				}
			}
			return;
		}
	}
	ViewChange_DeleteHands(client);
	WeaponClass[client] = TFClass_Unknown;
	WeaponRef[client] = INVALID_ENT_REFERENCE;
	i_Viewmodel_WeaponModel[client] = INVALID_ENT_REFERENCE;
}

void ViewChange_DeleteHands(int client)
{
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);

	HandRef[client] = INVALID_ENT_REFERENCE;
}

int ViewChange_UpdateHands(int client, TFClassType class)
{
	int entity = EntRefToEntIndex(HandRef[client]);
	if(entity <= MaxClients)
	{
		entity = CreateEntityByName("tf_wearable_vm");
		if(entity > MaxClients)
		{
			int hand_index = view_as<int>(class);
			if(b_IsPlayerNiko[client])
				hand_index = 10;
			
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[hand_index]);
			SetEntProp(entity, Prop_Send, "m_fEffects", 129);
			SetEntProp(entity, Prop_Send, "m_iTeamNum", GetClientTeam(client));
			SetEntProp(entity, Prop_Send, "m_usSolidFlags", 4);
			SetEntityCollisionGroup(entity, 11);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", 1);
			DispatchSpawn(entity);
			SetVariantString("!activator");
			ActivateEntity(entity);
			SDKCall_EquipWearable(client, entity);
			HandRef[client] = EntIndexToEntRef(entity);
		}
	}
	return entity;
}

void HidePlayerWeaponModel(int client, int entity)
{
	SetEntityRenderMode(entity, RENDER_TRANSALPHA);
	SetEntityRenderColor(entity, 0, 0, 0, 0);
//	SetEntProp(entity, Prop_Send, "m_bBeingRepurposedForTaunt", 1);
//	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	SetEntProp(entity, Prop_Send, "m_fEffects", GetEntProp(entity, Prop_Send, "m_fEffects") | EF_NODRAW);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMinDist", 0.0);
	SetEntPropFloat(entity, Prop_Send, "m_fadeMaxDist", 0.00001);
	int EntityWeaponModel = EntRefToEntIndex(i_Viewmodel_WeaponModel[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverride[entity]);
	}
	EntityWeaponModel = EntRefToEntIndex(WeaponRef[client]);
	if(IsValidEntity(EntityWeaponModel))
	{
		SetEntPropFloat(EntityWeaponModel, Prop_Send, "m_flModelScale", f_WeaponSizeOverrideViewmodel[entity]);
	}
}