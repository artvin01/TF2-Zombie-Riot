#pragma semicolon 1
#pragma newdecls required

static bool IsThisObject[MAXENTITIES];

methodmap UnitObject < CBaseAnimating
{
	property int m_hTextEntity1
	{
		public get()
		{
			return EntRefToEntIndex(i_TextEntity[this.index][0]);
		}
		public set(int entity)
		{
			i_TextEntity[this.index][0] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hTextEntity2
	{
		public get()
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][1]);
		}
		public set(int entity)
		{
			i_TextEntity[this.index][1] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hTextEntity3
	{
		public get()
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][2]);
		}
		public set(int entity)
		{
			i_TextEntity[this.index][2] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hTextEntity4
	{
		public get()
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][3]);
		}
		public set(int entity)
		{
			i_TextEntity[this.index][3] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hTextEntity5
	{
		public get()
		{ 
			return EntRefToEntIndex(i_TextEntity[this.index][4]);
		}
		public set(int entity)
		{
			i_TextEntity[this.index][4] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hWearable1
	{
		public get()
		{
			return EntRefToEntIndex(i_Wearable[this.index][0]);
		}
		public set(int entity)
		{
			i_Wearable[this.index][0] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hWearable2
	{
		public get()
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][1]);
		}
		public set(int entity)
		{
			i_Wearable[this.index][1] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hWearable3
	{
		public get()
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][2]);
		}
		public set(int entity)
		{
			i_Wearable[this.index][2] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hWearable4
	{
		public get()
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][3]);
		}
		public set(int entity)
		{
			i_Wearable[this.index][3] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_hWearable5
	{
		public get()
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][4]);
		}
		public set(int entity)
		{
			i_Wearable[this.index][4] = entity == -1 ? -1 : EntIndexToEntRef(entity);
		}
	}
	property int m_iResourceType
	{
		public get()
		{ 
			return this.GetProp(Prop_Data, "m_iResourceType");
		}
		public set(int value)
		{
			this.SetProp(Prop_Data, "m_iResourceType", value);
		}
	}
	property Function m_hDeathFunc
	{
		public set(Function value)
		{
			func_NPCDeath[this.index] = value;
		}
	}
	property Function m_hOnTakeDamageFunc
	{
		public set(Function value)
		{
			func_NPCOnTakeDamage[this.index] = value;
		}
	}

	public void SetName(const char[] name)
	{
		strcopy(c_NpcName[this.index], sizeof(c_NpcName[]), name);
	}

	public int EquipItemSeperate(
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
			DispatchKeyValueFloat(item, "modelscale", GetEntPropFloat(this.index, Prop_Send, "m_flModelScale"));
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

		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);
		SetEntityCollisionGroup(item, 1);
		SetEntProp(item, Prop_Send, "m_usSolidFlags", 12); 
		SetEntProp(item, Prop_Data, "m_nSolidType", 6); 
		return item;
	}
	
	public UnitObject(int id, const float vecPos[3], const float vecAng[3],
						const char[] model,
						float modelscale = 1.0,
						int health = 125)
	{
		int entity = CreateEntityByName("prop_resource");
		
		DispatchKeyValueVector(entity, "origin", vecPos);
		DispatchKeyValueVector(entity, "angles", vecAng);
		DispatchKeyValue(entity, "model", model);
		DispatchKeyValueFloat(entity, "modelscale", modelscale);
		DispatchKeyValueInt(entity, "health", health);
		DispatchKeyValue(entity, "solid", "2");

		i_NpcInternalId[entity] = id;
		IsThisObject[entity] = true;
		func_NPCDeath[entity] = INVALID_FUNCTION;
		func_NPCOnTakeDamage[entity] = INVALID_FUNCTION;

		DispatchSpawn(entity);

		SDKHook(entity, SDKHook_OnTakeDamage, Object_TakeDamage);

		return view_as<UnitObject>(entity);
	}
}

void Object_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("prop_resource", _, OnDestroy);
	factory.DeriveFromClass("prop_dynamic");
	factory.BeginDataMapDesc()
	.DefineIntField("m_iResourceType")
	.EndDataMapDesc();
	factory.Install();

	RegAdminCmd("sm_spawn_object", CreateCommand, ADMFLAG_RCON);
}

void Object_PluginEnd()
{
/*
	while((entity = FindEntityByClassname(entity, "prop_resource")) != -1)
	{
		RemoveEntity(entity);
	}
*/
}

static void OnDestroy(UnitObject unit)
{
	ObjectDeath(unit.index, true);
}

static bool ObjectDeath(int entity, bool delet)
{
	Function func = func_NPCDeath[entity];
	if(func != INVALID_FUNCTION)
	{
		bool noDeath;

		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish(noDeath);

		if(!delet && noDeath)	// Block death
			return false;

		func_NPCDeath[entity] = INVALID_FUNCTION;
	}

	IsThisObject[entity] = false;

	SDKUnhook(entity, SDKHook_OnTakeDamage, Object_TakeDamage);

	for(int i; i < sizeof(i_TextEntity[]); i++)
	{
		if(IsValidEntity(i_TextEntity[entity][i]))
			RemoveEntity(i_TextEntity[entity][i]);
		
		i_TextEntity[entity][i] = -1;
	}

	for(int i; i < sizeof(i_Wearable[]); i++)
	{
		if(IsValidEntity(i_Wearable[entity][i]))
			RemoveEntity(i_Wearable[entity][i]);
		
		i_Wearable[entity][i] = -1;
	}

	if(!delet)	// Kill it
		RemoveEntity(entity);
	
	return true;
}

bool IsObject(int entity)
{
	return IsThisObject[entity];
}

static Action CreateCommand(int client, int args)
{
	if(client == 0)
		return Plugin_Handled;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spawn_object <index> [data]");
		return Plugin_Handled;
	}
	
	float flPos[3], flAng[3];
	GetClientAbsAngles(client, flAng);
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	
	char buffer[64];
	GetCmdArg(2, buffer, sizeof(buffer));

	Object_Create(GetCmdArgInt(1), flPos, flAng, buffer);
	return Plugin_Handled;
}

static Action Object_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action = Plugin_Continue;

	Function func = func_NPCOnTakeDamage[victim];
	if(func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(victim);
		Call_PushCellRef(attacker);
		Call_PushCellRef(inflictor);
		Call_PushFloatRef(damage);
		Call_PushCellRef(damagetype);
		Call_PushCellRef(weapon);
		Call_PushArrayEx(damageForce, sizeof(damageForce), SM_PARAM_COPYBACK);
		Call_PushArrayEx(damagePosition, sizeof(damagePosition), SM_PARAM_COPYBACK);
		Call_PushCell(damagecustom);
		Call_Finish(action);
	}

	if(action <= Plugin_Changed)
	{
		int dmg = RoundFloat(damage);
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - dmg;

		if(health < 1)
		{
			if(ObjectDeath(victim, false))
				return Plugin_Changed;
			
			health = 0;
		}

		SetEntProp(victim, Prop_Data, "m_iHealth", health);
	}
	
	return Plugin_Handled;
}

void Object_MapStart()
{
	TreeObject_MapStart();
}

enum
{
	TREE_DEAD = 1,

	// Add entries above this line
	MAX_OBJ_TYPES
}

any Object_Create(int index, const float vecPos[3], const float vecAng[3], const char[] data = "")
{
	any entity = -1;
	switch(index)
	{
		case TREE_DEAD:
			entity = DeadTree(vecPos, vecAng, data);

		default:
			PrintToChatAll("Invalid object ID %d!", index);
	}

	return entity;
}

#include "fortress_wars/object/object_tree.sp"
