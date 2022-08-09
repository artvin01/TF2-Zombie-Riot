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

static int HandIndex[10];
static int PlayerIndex[10];
static int HandRef[MAXTF2PLAYERS];
static int WeaponRef[MAXTF2PLAYERS];

void ViewChange_MapStart()
{
	for(int i; i<10; i++)
	{
		HandIndex[i] = PrecacheModel(HandModels[i], true);
	}

	for(int i; i<10; i++)
	{
		PlayerIndex[i] = PrecacheModel(PlayerModels[i], true);
	}
}

void ViewChange_PlayerModel(int client)
{
	if(TeutonType[client] == TEUTON_NONE)
	{
		int team = GetClientTeam(client);
		int entity = CreateEntityByName("tf_wearable");
		if(entity > MaxClients)	// Weapon viewmodel
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndex", PlayerIndex[CurrentClass[client]]);
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
		}
	}
}

void ViewChange_Switch(int client, int active, const char[] buffer = "")
{
	int entity = EntRefToEntIndex(WeaponRef[client]);
	if(entity > MaxClients)
		TF2_RemoveWearable(client, entity);

	entity = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
	if(entity > MaxClients)
	{
		SetEntProp(entity, Prop_Send, "m_fEffects", EF_NODRAW);
		if(active > MaxClients)
		{
			//static char buffer[36];
			//GetEntityClassname(active, buffer, sizeof(buffer));
			//if(!StrEqual(buffer, "tf_weapon_sapper"))
			{

				int itemdefindex = GetEntProp(active, Prop_Send, "m_iItemDefinitionIndex");
				
				TFClassType class = TF2_GetWeaponClass(itemdefindex, CurrentClass[client], TF2_GetClassnameSlot(buffer, true));

				SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[class]);

				entity = CreateEntityByName("tf_wearable_vm");
				if(entity > MaxClients)	// Weapon viewmodel
				{
					int team = GetClientTeam(client);
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
					SDKCall_EquipWearable(client, entity);
					WeaponRef[client] = EntIndexToEntRef(entity);
				}
				WeaponClass[client] = class;
				/*
				if(GetEntProp(active, Prop_Send, "m_iItemDefinitionIndex") == 357)
				{
					
					WeaponClass[client] = TFClass_Spy;
					//katanais always spy.
					
				}
				*/
				#if defined NoSendProxyClass
				TF2_SetPlayerClass(client, WeaponClass[client], _, false);
				Store_ApplyAttribs(client);
				#else
				ClassProxy_m_iClass_Set(client, WeaponClass[client]);
				#endif
				ViewChange_UpdateHands(client, CurrentClass[client]);
				return;
			}
		}
	}

	ViewChange_DeleteHands(client);
	WeaponClass[client] = TFClass_Unknown;
	WeaponRef[client] = INVALID_ENT_REFERENCE;
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
			SetEntProp(entity, Prop_Send, "m_nModelIndex", HandIndex[class]);
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