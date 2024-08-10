#pragma semicolon 1
#pragma newdecls required

methodmap UnitObject < CBaseAnimating
{
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

	// Range at which units can provide vision
	property float m_flVisionRange
	{
		public get()
		{
			return (Stats[this.index].Sight + Stats[this.index].SightBonus) * OBJECT_UNITS;
		}
	}

	// Range at which units will target automatically
	property float m_flEngageRange
	{
		public get()
		{
			int range = Stats[this.index].Range + Stats[this.index].RangeBonus;
			if(range < 4)
				range = 4;
			
			return range * OBJECT_UNITS;
		}
	}

	public void AddFlag(int type)
	{
		UnitFlags[this.index] |= (1 << type);
	}
	public void RemoveFlag(int type)
	{
		UnitFlags[this.index] &= ~(1 << type);
	}
	public void RemoveAllFlags()
	{
		UnitFlags[this.index] = 0;
	}
	public bool HasFlag(int type)
	{
		return RTS_HasFlag(this.index, type);
	}

	public void SetSoundFunc(int type, Function func)
	{
		FuncSound[this.index][type] = func;
	}
	property Function m_hSkillsFunc
	{
		public set(Function value)
		{
			FuncSkills[this.index] = value;
		}
	}

	public void ClearStats(const StatEnum stats = {})
	{
		Stats[this.index] = stats;
	}

	public void DealDamage(int victim, float multi = 1.0, int damageType = DMG_GENERIC, const float damageForce[3] = NULL_VECTOR, const float damagePosition[3] = NULL_VECTOR)
	{
		int damage = RoundFloat(Stats[this.index].Damage * multi) + Stats[this.index].DamageBonus;

		// Check for extra damage vs flags
		for(int i; i < Flag_MAX; i++)
		{
			if((Stats[this.index].ExtraDamage[i] || Stats[this.index].ExtraDamageBonus[i]) && view_as<UnitBody>(victim).HasFlag(i))
				damage += RoundFloat(Stats[this.index].ExtraDamage[i] * multi) + Stats[this.index].ExtraDamageBonus[i];
		}

		SDKHooks_TakeDamage(victim, this.index, this.index, float(damage), damageType, _, damageForce, damagePosition);
	}
	public bool InAttackRange(int target)
	{
		return view_as<UnitBody>(this).InAttackRange(target);
	}

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

	public int EquipItemSeperate(
	const char[] model,
	const char[] anim = "",
	int skin = 0,
	float model_size = 0.0,
	float offset = 0.0,
	bool DontParent = false)
	{
		int item = CreateEntityByName("prop_dynamic");
		DispatchKeyValue(item, "model", model);

		if(model_size == 0.0)
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
		
		if(anim[0])
		{
			SetVariantString(anim);
			AcceptEntityInput(item, "SetAnimation");
		}

		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);
		MakeObjectIntangeable(item);
		return item;
	}
	
	public UnitObject(int team, const float vecPos[3],
					int scale = 1,
					int health = 125,
					bool solid = true,
					const char[] model = "",
					const float vecAng[3] = OBJECT_OFFSET,
					float modelscale = 0.0)
	{
		UnitObject obj = view_as<UnitObject>(CreateEntityByName("obj_building"));

		float pos[3];
		pos = vecPos;
		Object_SnapPosition(pos, scale, scale);
		
		DispatchKeyValueVector(obj.index, "origin", pos);
		DispatchKeyValueVector(obj.index, "angles", vecAng);
		DispatchKeyValue(obj.index, "model", model[0] ? model : OBJECT_HITBOX);
		DispatchKeyValueFloat(obj.index, "modelscale", modelscale ? modelscale : (scale * OBJECT_UNITS / OBJECT_MODELSIZE));
		DispatchKeyValueInt(obj.index, "health", health);
		DispatchKeyValueInt(obj.index, "solid", 2);

		SetEntityRenderFx(obj.index, RENDERFX_FADE_SLOW);

		b_BuildingHasDied[obj.index] = false;
		i_IsABuilding[obj.index] = true;
		b_NoKnockbackFromSources[obj.index] = true;
		b_CantCollidie[obj.index] = !solid;

		obj.m_hDeathFunc = INVALID_FUNCTION;
		obj.m_hOnTakeDamageFunc = INVALID_FUNCTION;

		SetTeam(obj.index, team);

		obj.RemoveAllFlags();
		obj.ClearStats();
		obj.m_hSkillsFunc = INVALID_FUNCTION;

		for(int i; i < Sound_MAX; i++)
		{
			obj.SetSoundFunc(i, INVALID_FUNCTION);
		}

		DispatchSpawn(obj.index);

		SetEntProp(obj.index, Prop_Data, "m_iHealth", health);
		SetEntProp(obj.index, Prop_Data, "m_iMaxHealth", health);

		SDKHook(obj.index, SDKHook_OnTakeDamage, Object_TakeDamage);

		return view_as<UnitObject>(obj.index);
	}
}

void Object_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("obj_building", _, OnDestroy);
	factory.DeriveFromClass("prop_dynamic_override");
	factory.BeginDataMapDesc()
	.DefineIntField("m_iResourceType")
	.EndDataMapDesc();
	factory.Install();

	RegAdminCmd("sm_spawn_object", CreateCommand, ADMFLAG_RCON);
}

void Object_PluginEnd()
{

}

static void OnDestroy(UnitObject obj)
{
	ObjectDeath(obj.index, true);
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

	b_BuildingHasDied[entity] = true;
	i_IsABuilding[entity] = false;

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

void Object_SnapPosition(float pos[3], int x, int y)
{
	// Snap x
	int units = RoundFloat(x * OBJECT_UNITS);
	bool odd = (x % 2) == 1;

	if(odd)
		pos[0] -= OBJECT_UNITS / 2.0;
	
	pos[0] = float(RoundFloat(pos[0]) / units * units);

	if(odd)
		pos[0] += OBJECT_UNITS / 2.0;

	// Snap y
	units = RoundFloat(y * OBJECT_UNITS);
	odd = (y % 2) == 1;

	if(odd)
		pos[1] -= OBJECT_UNITS / 2.0;
	
	pos[1] = float(RoundFloat(pos[1]) / units * units);

	if(odd)
		pos[1] += OBJECT_UNITS / 2.0;
	
	// Snap to ground
	pos[2] += 5.0;
	Handle trace = TR_TraceRayFilterEx(pos, {90.0, 0.0, 0.0}, MASK_SOLID, RayType_Infinite, Trace_WorldOnly);
	TR_GetEndPosition(pos, trace);
	delete trace;
}

int Object_GetResource(int entity)
{
	return view_as<UnitObject>(entity).m_iResourceType;
}

bool IsObject(int entity)
{
	return i_IsABuilding[entity];
}

static Action CreateCommand(int client, int args)
{
	if(client == 0)
		return Plugin_Handled;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_spawn_object <plugin> [team] [data]");
		return Plugin_Handled;
	}
	
	float flPos[3];
	if(!SetTeleportEndPoint(client, flPos))
	{
		PrintToChat(client, "Could not find place.");
		return Plugin_Handled;
	}
	
	char plugin[64], buffer[64];
	GetCmdArg(1, plugin, sizeof(plugin));
	int team = args > 1 ? GetCmdArgInt(2) : TeamNumber[client];
	GetCmdArg(3, buffer, sizeof(buffer));

	Object_CreateByName(plugin, team, flPos, buffer);
	return Plugin_Handled;
}

static Action Object_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Action action = Plugin_Continue;

	RTS_TakeDamage(victim, damage, damagetype);

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

static ArrayList ObjectList;

enum struct ObjectData
{
	char Plugin[64];
	char Name[64];
	Function Func;
	int Price[Resource_MAX];
}

int Object_Add(ObjectData data)
{
	if(!data.Func || data.Func == INVALID_FUNCTION)
		ThrowError("Invalid function name");

	if(!TranslationPhraseExists(data.Name))
	{
		LogError("Translation '%s' does not exist", data.Name);
		strcopy(data.Name, sizeof(data.Name), "nothing");
	}
	
	return ObjectList.PushArray(data);
}

int Object_GetByPlugin(const char[] name, ObjectData data = {})
{
	int length = ObjectList.Length;
	for(int i; i < length; i++)
	{
		ObjectList.GetArray(i, data);
		if(StrEqual(name, data.Plugin))
			return i;
	}
	return -1;
}

int Object_CreateByName(const char[] name, int team, const float vecPos[3], const char[] data = "")
{
	static ObjectData objdata;
	int id = Object_GetByPlugin(name, objdata);
	if(id == -1)
	{
		PrintToChatAll("\"%s\" is not a valid Object!", name);
		return -1;
	}

	return CreateObject(objdata, id, team, vecPos, data);
}

static int CreateObject(const ObjectData objdata, int id, int team, const float vecPos[3], const char[] data)
{
	int entity = -1;
	Call_StartFunction(null, objdata.Func);
	Call_PushCell(team);
	Call_PushArray(vecPos, sizeof(vecPos));
	Call_PushString(data);
	Call_Finish(entity);
	
	if(entity > 0)
	{
		if(!c_NpcName[entity][0])
			strcopy(c_NpcName[entity], sizeof(c_NpcName[]), objdata.Name);
		
		if(!i_NpcInternalId[entity])
			i_NpcInternalId[entity] = id;
	}

	return entity;
}

void Object_ConfigSetup()
{
	delete ObjectList;
	ObjectList = new ArrayList(sizeof(ObjectData));

	ObjectData data;
	strcopy(data.Name, sizeof(data.Name), "nothing");
	strcopy(data.Plugin, sizeof(data.Plugin), "object_nothing");
	data.Func = INVALID_FUNCTION;
	ObjectList.PushArray(data);

	TreeObject_Setup();
	ObjectEmpire_Setup();
	TownCenter_Setup();
}

#include "fortress_wars/object/object_tree.sp"
#include "fortress_wars/object/object_base_training.sp"

#include "fortress_wars/object/empire/object_base_empire.sp"
#include "fortress_wars/object/empire/object_towncenter.sp"
