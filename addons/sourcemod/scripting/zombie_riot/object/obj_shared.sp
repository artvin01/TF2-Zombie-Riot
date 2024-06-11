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

static bool SentryBuilding[MAXENTITIES];
static int Building_Max_Health[MAXENTITIES]={0, ...};
static int Building_Repair_Health[MAXENTITIES]={0, ...};
int i_MachineJustClickedOn[MAXTF2PLAYERS];

void Object_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("obj_building", _, OnDestroy);
	factory.DeriveFromClass("prop_dynamic");
	factory.BeginDataMapDesc()
	.DefineIntField("m_iRepair")
	.DefineIntField("m_iRepairMax")
	.DefineIntField("m_iMaxHealth")
	.EndDataMapDesc();
	factory.Install();
}

//remove whatever things it had
static void OnDestroy(int entity)
{
	ObjectGeneric npc = view_as<ObjectGeneric>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	Building_RotateAllDepencencies(entity);
}

methodmap ObjectGeneric < CClotBody
{
	public ObjectGeneric(int client, const float vecPos[3], const float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] basehealth = "750",
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		int obj = CreateEntityByName("obj_building");
		DispatchKeyValueVector(obj, "origin",	 vecPos);
		DispatchKeyValueVector(obj, "angles",	 vecAng);
		DispatchKeyValue(obj,		 "model",	 model);
		DispatchKeyValue(obj,	   "modelscale", modelscale);
		DispatchKeyValue(obj,	   "solid", "2");
		DispatchKeyValue(obj,	   "physdamagescale", "0.0");
		DispatchKeyValue(obj,	   "minhealthdmg", "0.0");
		DispatchSpawn(obj);
		SetEntProp(obj, Prop_Data, "m_iMaxHealth", StringToInt(basehealth));
		SetEntProp(obj, Prop_Data, "m_iHealth", StringToInt(basehealth));
		SetEntProp(obj, Prop_Data, "m_iRepairMax", StringToInt(basehealth));
		SetEntProp(obj, Prop_Data, "m_iRepair", StringToInt(basehealth));
			
 		b_CantCollidie[obj] = false;
	 	b_CantCollidieAlly[obj] = false;
		b_AllowCollideWithSelfTeam[obj] = true;
		i_NpcWeight[obj] = 999;
		i_NpcIsABuilding[obj] = true;
		i_IsABuilding[obj] = true;
		b_NoKnockbackFromSources[obj] = true;
		SentryBuilding[obj] = false;
		ObjectGeneric objstats = view_as<ObjectGeneric>(obj);
		SDKHook(obj, SDKHook_Think, ObjBaseThink);
		SDKHook(obj, SDKHook_ThinkPost, ObjBaseThinkPost);
		CBaseCombatCharacter(obj).SetNextThink(GetGameTime());
		SetEntityCollisionGroup(obj, 24);
		
		for (int i = 0; i < ZR_MAX_BUILDINGS; i++)
		{
			if (EntRefToEntIndex(i_ObjectsBuilding[i]) <= 0)
			{
				i_ObjectsBuilding[i] = EntIndexToEntRef(obj);
				i = ZR_MAX_BUILDINGS;
			}
		}

		f3_CustomMinMaxBoundingBox[obj][0] = CustomThreeDimensions[0];
		f3_CustomMinMaxBoundingBox[obj][1] = CustomThreeDimensions[1];
		f3_CustomMinMaxBoundingBox[obj][2] = CustomThreeDimensions[2];

		float VecMin[3];
		float VecMax[3];
		VecMin = CustomThreeDimensions;
		VecMin[0] *= -1.0;
		VecMin[1] *= -1.0;
		VecMin[2] = 0.0;
		VecMax = CustomThreeDimensions;
		SetEntProp(obj, Prop_Data, "m_nSolidType", 2); 
		SetEntPropVector(obj, Prop_Data, "m_vecMaxs", VecMax);
		SetEntPropVector(obj, Prop_Data, "m_vecMins", VecMin);
		objstats.UpdateCollisionBox();

		static Function defaultFunc;
		if(!defaultFunc)
			defaultFunc = GetFunctionByName(null, "ObjectGeneric_CanBuild");
		
		objstats.FuncCanUse = INVALID_FUNCTION;
		objstats.FuncCanBuild = defaultFunc;
		objstats.FuncShowInteractHud = INVALID_FUNCTION;

		SetEntPropEnt(obj, Prop_Send, "m_hOwnerEntity", client);
		
		SDKHook(obj, SDKHook_OnTakeDamage, ObjectGeneric_ClotTakeDamage);
	//	SetEntityRenderFx(obj, RENDERFX_FADE_FAST);

		int entity = objstats.EquipItemSeperate("partyhat", model);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", objstats.index);
		objstats.m_iWearable1 = entity;

		entity = objstats.EquipItemSeperate("partyhat", model);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingReady);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", objstats.index);
		objstats.m_iWearable2 = entity;
		return objstats;
	}

	property int index 
	{ 
		public get() { return view_as<int>(this); } 
	}
	public int EquipItemSeperate(
	const char[] attachment,
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 1.0,
	float offset = 0.0,
	bool DontParent = false)
	{
		int item = CreateEntityByName("prop_dynamic");
		DispatchKeyValue(item, "model", model);

		if(model_size == 1.0)
		{
			DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Data, "m_flModelScale"));
		}
		else
		{
			DispatchKeyValueFloat(item, "modelscale", model_size);
		}

		DispatchSpawn(item);
		
		SetEntityMoveType(item, MOVETYPE_NONE);
		SetEntProp(item, Prop_Data, "m_nNextThinkTick", -1.0);
		float eyePitch[3];
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", eyePitch);

		float VecOrigin[3];
		GetAbsOrigin(this.index, VecOrigin);
		VecOrigin[2] += offset;

		TeleportEntity(item, VecOrigin, eyePitch, NULL_VECTOR);
		if(DontParent)
		{
			return item;
		}
		

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
		MakeObjectIntangeable(item);
		return item;
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
	property int BaseHealth
	{
		public set(int value)
		{
			Building_Max_Health[this.index] = value;
			Building_Repair_Health[this.index] = value;
			SetEntProp(this.index, Prop_Data, "m_iMaxHealth", value);
		}
		public get()
		{
			return Building_Max_Health[this.index];
		}
	}
	property bool SentryBuilding
	{
		public set(bool value)
		{
			SentryBuilding[this.index] = value;
		}
		public get()
		{
			return SentryBuilding[this.index];
		}
	}
	property float m_flNextDelayTime
	{
		public get()							{ return fl_NextDelayTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextDelayTime[this.index] = TempValueForProperty; }
	}
	property float m_flAttackHappens
	{
		public get()							{ return fl_AttackHappensMinimum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMinimum[this.index] = TempValueForProperty; }
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

public bool ObjectGeneric_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		count = Object_SupportBuildings(client);
		maxcount = Object_MaxSupportBuildings(client);
		if(count >= maxcount)
			return false;
	}
	
	return true;
}

public bool ObjectGeneric_CanBuildSentry(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
	
	count = Object_GetSentryBuilding(client) == -1 ? 0 : 1;
	maxcount = 1;
	if(count)
		return false;

	return true;
}

bool Object_CanBuild(Function func, int client, int &count = 0, int &maxcount = 0)
{
	bool result;
	Call_StartFunction(null, func);
	Call_PushCell(client);
	Call_PushCellRef(count);
	Call_PushCellRef(maxcount);
	Call_Finish(result);
	return result;
}

bool ObjectGeneric_ClotThink(ObjectGeneric objstats)
{
	float gameTime = GetGameTime(objstats.index);
	if(objstats.m_flNextDelayTime > gameTime)
		return false;
	
	objstats.m_flNextDelayTime = gameTime + 0.1;
	BuildingDisplayRepairLeft(objstats.index);
	int owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
	if(owner == -1)
	{
		if(FuncCanBuild[objstats.index] && FuncCanBuild[objstats.index] != INVALID_FUNCTION)
		{
			// If 0 can't build, destory the unclaimed building
			if(!Object_CanBuild(FuncCanBuild[objstats.index], 0))
			{
				SmiteNpcToDeath(objstats.index);
				return false;
			}
		}

		int wearable = objstats.m_iWearable1;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
		
		wearable = objstats.m_iWearable2;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
	}
	else
	{
		// Update max health if attributes changed on the player
		int health = GetEntProp(objstats.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(objstats.index, Prop_Data, "m_iMaxHealth");
		int expected = RoundFloat(Building_Max_Health[objstats.index] * Object_GetMaxHealthMulti(owner));
		if(maxhealth && expected && maxhealth != expected)
		{
			float change = float(expected) / float(maxhealth);

			maxhealth = expected;
			health = RoundFloat(float(health) * change);
			Building_Repair_Health[objstats.index] = RoundFloat(float(Building_Repair_Health[objstats.index]) * change);
			
			SetEntProp(objstats.index, Prop_Data, "m_iMaxHealth", maxhealth);
			SetEntProp(objstats.index, Prop_Data, "m_iHealth", health);
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
		
		int wearable = objstats.m_iWearable1;
		if(wearable != -1)
			SetEntityRenderColor(wearable, r, g, 0, 100);
		
		wearable = objstats.m_iWearable2;
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
					if(Object_CanBuild(FuncCanBuild[entity], client))
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

int Object_NamedBuildings(int owner = 0, const char[] name)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_")) != -1)
	{
		if(!b_NpcHasDied[entity] && (owner == 0 || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner))
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

int Object_GetSentryBuilding(int owner)
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(!b_NpcHasDied[entity] && SentryBuilding[entity] && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_", false) != -1)
				break;
		}
	}

	return entity;
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

float Object_GetMaxHealthMulti(int client)
{
	return Attributes_GetOnPlayer(client, 286);
}

Action ObjectGeneric_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(RaidBossActive && RaidbossIgnoreBuildingsLogic(2)) //They are ignored anyways
		return Plugin_Handled;

	if((damagetype & DMG_CRUSH))
		return Plugin_Handled;

	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	health -= RoundToNearest(damage);
	PrintToChatAll("attacked %i ",health);
	if(health < 0)
	{
		RemoveEntity(victim);
	}
	SetEntProp(victim, Prop_Data, "m_iHealth", health);
	return Plugin_Handled;
}



public void ObjBaseThinkPost(int building)
{
	CBaseCombatCharacter(building).SetNextThink(GetGameTime());
	SetEntPropFloat(building, Prop_Data, "m_flSimulationTime",GetGameTime());
}

public void ObjBaseThink(int building)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(building);
	ObjectGeneric_ClotThink(objstats);
}

void BuildingDisplayRepairLeft(int entity)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	char HealthText[32];
	int HealthColour[4];
	int MaxHealth = GetEntProp(objstats.index, Prop_Data, "m_iRepairMax");
	int Health = GetEntProp(objstats.index, Prop_Data, "m_iRepair");
	for(int i=0; i<(20); i++)
	{
		if(Health >= MaxHealth*(i*(0.05)))
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, "|");
		}
		else
		{
			Format(HealthText, sizeof(HealthText), "%s%s", HealthText, " ");
		}
	}
	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[3] = 255;

	if(IsValidEntity(objstats.m_iWearable3))
	{
		DispatchKeyValue(objstats.m_iWearable3, "message", HealthText);
	}
	else
	{
		float Offset[3];
		Offset[2] = f3_CustomMinMaxBoundingBox[entity][2];
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 7, HealthColour, objstats.index);
		DispatchKeyValue(TextEntity, "font", "1");
		objstats.m_iWearable3 = TextEntity;	
	}
}