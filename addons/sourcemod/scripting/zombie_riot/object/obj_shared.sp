#pragma semicolon 1
#pragma newdecls required

/**
 * static bool ClotCanUse(ObjectYour npc, int client)
 * 
 * @param npc		Building
 * @param client	Client
 * @return		If to render as useable
 */
static Function FuncCanUse[MAXENTITIES];

/**
 * static bool ClotCanBuild(ObjectYour npc, int client)
 * 
 * @param npc		Building
 * @param client	0 for being unclaimed
 * @return		If can build this building
 */
static Function FuncCanBuild[MAXENTITIES];

/**
 * static void ClotShowInteractHud(ObjectYour npc, int client)
 * 
 * @param npc		Building
 * @param client	Client
 * @noreturn
 */
static Function FuncShowInteractHud[MAXENTITIES];

static int Building_Max_Health[MAXENTITIES]={0, ...};
static int Building_Repair_Health[MAXENTITIES]={0, ...};

methodmap ObjectGeneric < CClotBody
{
	public ObjectGeneric(int client, const float vecPos[3], const float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] basehealth = "750",
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		ObjectGeneric npc = view_as<ObjectGeneric>(CClotBody(vecPos, vecAng, model, modelscale, basehealth, TFTeam_Red, false, false, _, _, CustomThreeDimensions, true));
		
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		Building_Max_Health[npc.index] = StringToInt(basehealth);
		Building_Repair_Health[npc.index] = Building_Max_Health[npc.index];
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;

		static Function defaultFunc;
		if(!defaultFunc)
			defaultFunc = GetFunctionByName(null, "ObjectGeneric_CanBuild");
		
		npc.FuncCanUse = INVALID_FUNCTION;
		npc.FuncCanBuild = defaultFunc;
		npc.FuncShowInteractHud = INVALID_FUNCTION;

		func_NPCDeath[npc.index] = ObjectGeneric_ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ObjectGeneric_ClotTakeDamage;
		func_NPCOnTakeDamagePost[npc.index] = ObjectGeneric_ClotTakeDamagePost;
		func_NPCThink[npc.index] = ObjectGeneric_ClotThink;

		SetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity", client);
		
		SetEntityRenderFx(npc.index, RENDERFX_FADE_FAST);

		int entity = npc.EquipItemSeperate("partyhat", model);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		npc.m_iWearable1 = entity;

		entity = npc.EquipItemSeperate("partyhat", model);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingReady);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		npc.m_iWearable2 = entity;
		
		npc.m_flSpeed = 0.0;

		return npc;
	}

	property Function FuncCanUse
	{
		public set(Function func)
		{
			FuncCanUse[this.index] = func;
		}
	}
	property Function FuncCanBuild
	{
		public set(Function func)
		{
			FuncCanBuild[this.index] = func;
		}
	}
	property Function FuncShowInteractHud
	{
		public set(Function func)
		{
			FuncShowInteractHud[this.index] = func;
		}
	}
}

static Action SetTransmit_BuildingNotReady(int entity, int client)
{
	return SetTransmit_BuildingShared(entity, client, true);
}

static Action SetTransmit_BuildingReady(int entity, int client)
{
	return SetTransmit_BuildingShared(entity, client, false);
}

static Action SetTransmit_BuildingShared(int entity, int client, bool reverse)
{
	if(client < 1 || client > MaxClients)
		return Plugin_Continue;
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner != -1)
	{
		bool result = true;

		if(FuncCanUse[owner] && FuncCanUse[owner] != INVALID_FUNCTION)
		{
			Call_StartFunction(null, FuncCanUse[owner]);
			Call_PushCell(owner);
			Call_PushCell(client);
			Call_Finish(result);
		}

		return (result ^ reverse) ? Plugin_Continue : Plugin_Stop;
	}

	RemoveEntity(entity);
	return Plugin_Stop;
}

public bool ObjectGeneric_CanBuild(ObjectBarricade npc, int client)
{
	if(client && Object_SupportBuildings(client) >= Object_MaxSupportBuildings(client))
		return false;
	
	return true;
}

bool ObjectGeneric_ClotThink(ObjectGeneric npc)
{
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return false;
	
	npc.m_flNextDelayTime = gameTime + 0.1;

	int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(owner == -1)
	{
		if(FuncCanBuild[npc.index] && FuncCanBuild[npc.index] != INVALID_FUNCTION)
		{
			// If 0 can't build, destory the unclaimed building

			bool result;
			Call_StartFunction(null, FuncCanBuild[npc.index]);
			Call_PushCell(npc.index);
			Call_PushCell(0);
			Call_Finish(result);
			if(!result)
			{
				SmiteNpcToDeath(npc.index);
				return false;
			}
		}

		int wearable = npc.m_iWearable1;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
		
		wearable = npc.m_iWearable2;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
	}
	else
	{
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		int expected = RoundFloat(Building_Max_Health[npc.index] * GetMaxHealthMulti(owner));
		if(maxhealth && expected && maxhealth != expected)
		{
			float change = float(expected) / float(maxhealth);

			maxhealth = expected;
			health = RoundFloat(float(health) * change);
			Building_Repair_Health[npc.index] = RoundFloat(float(Building_Repair_Health[npc.index]) * change);
			
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", maxhealth);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		}
		
		int g = health * 255  / maxhealth;
		if(g > 255)
		{
			g = 255;
		}
		else if(g < 0)
		{
			g = 0;
		}
		
		int r = 255 - g;
		
		int wearable = npc.m_iWearable1;
		if(wearable != -1)
			SetEntityRenderColor(wearable, r, g, 0, 100);
		
		wearable = npc.m_iWearable2;
		if(wearable != -1)
			SetEntityRenderColor(wearable, r, g, 0, 255);
		
	}

	return true;
}

bool Object_ShowInteractHud(int client, int entity)
{
	if(!FuncShowInteractHud[entity] || FuncShowInteractHud[entity] == INVALID_FUNCTION)
		return false;
	
	Call_StartFunction(null, FuncShowInteractHud[entity]);
	Call_PushCell(entity);
	Call_PushCell(client);
	Call_Finish();
	return true;
}

bool Object_Interact(int client, int weapon, int obj)
{
	if(TeutonType[client] != TEUTON_NONE || obj == -1)
		return false;
	
	int entity = obj;
	if(entity <= MaxClients)
	{
		// Player mounted
		entity = EntRefToEntIndex(Building_Mounted[obj]);
		if(entity == -1)
			return false;
	}

	bool result;
	
	static char plugin[64];
	NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
	if(StrContains(plugin, "obj_", false) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
		{
			// Claim a unclaimed building
			if(weapon != -1 && i_IsWrench[weapon])
			{
				if(FuncCanBuild[entity] && FuncCanBuild[entity] != INVALID_FUNCTION)
				{
					Call_StartFunction(null, FuncCanBuild[entity]);
					Call_PushCell(entity);
					Call_PushCell(client);
					Call_Finish(result);

					if(result)
					{
						SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
					}
					else
					{
						ClientCommand(client, "playgamesound items/medshotno1.wav");
					}
				}

				return true;
			}
		}
		else
		{
			// Interact with a building
			Function func = func_NPCInteract[entity];
			if(func && func != INVALID_FUNCTION)
			{
				Call_StartFunction(null, func);
				Call_PushCell(client);
				Call_PushCell(weapon);
				Call_PushCell(entity);
				Call_Finish(result);
			}
		}
	}

	return true;
}

int Object_NamedBuildings(int owner, const char[] name)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(!b_NpcHasDied[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, name, false) != -1)
				count++;
		}
	}

	return count;
}

int Object_SupportBuildings(int owner)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(!b_NpcHasDied[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_", false) != -1)
			{
				if(StrContains(plugin, "barricade", false) != -1)
					continue;
				
				count++;
			}
		}
	}

	return count;
}

int Object_MaxSupportBuildings(int client, bool ingore_glass = false)
{
	int maxAllowed = 1;
	
  	int Building_health_attribute = i_MaxSupportBuildingsLimit[client];
	
	maxAllowed += Building_health_attribute; 
//	maxAllowed += Blacksmith_Additional_SupportBuildings(client); 
	if(CvarInfiniteCash.BoolValue)
	{
		maxAllowed += 999;
	}
	
	if(maxAllowed < 1)
	{
		maxAllowed = 1;
	}

	if(b_HasGlassBuilder[client])
	{
		if(!ingore_glass)
			maxAllowed = 1;
	}

//	if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES)
//	{
//		if(!ingore_glass)
//			maxAllowed = 1;
//	}
	return maxAllowed;
}

static float GetMaxHealthMulti(int client)
{
	return Attributes_GetOnPlayer(client, 286);
}

void ObjectGeneric_ClotDeath(int entity)
{
	ObjectGeneric npc = view_as<ObjectGeneric>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
}

void ObjectGeneric_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(RaidBossActive && RaidbossIgnoreBuildingsLogic(2)) //They are ignored anyways
	{
		damage = 0.0;
		return;
	}
}

void ObjectGeneric_ClotTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom, bool &killed) 
{
	if(killed)
	{
		view_as<CClotBody>(victim).m_bDissapearOnDeath = false;
		view_as<CClotBody>(victim).m_bGib = true;
		return;
	}
	
	int dmg = RoundFloat(damage);
	if(Building_Repair_Health[victim] > 0)
	{
		Building_Repair_Health[victim] -= dmg;
		if(Building_Repair_Health[victim] > 0)
		{
			dmg = 0;
		}
		else
		{
			dmg += Building_Repair_Health[victim];
			Building_Repair_Health[victim] = 0;
		}
	}

	if(dmg)
	{
		Building_Max_Health[victim] -= dmg;
		if(Building_Max_Health[victim] < 1)
			killed = true;
		
		int health = GetEntProp(victim, Prop_Data, "m_iMaxHealth") - dmg;
		if(health < 1)
			killed = true;
		
		SetEntProp(victim, Prop_Data, "m_iMaxHealth", health);
	}
}
