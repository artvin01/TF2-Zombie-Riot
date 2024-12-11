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
static bool CanUseBuilding[MAXENTITIES][MAXTF2PLAYERS];
int i_MachineJustClickedOn[MAXTF2PLAYERS];
static float RotateByDefault[MAXENTITIES]={0.0, ...};
int Building_BuildingBeingCarried[MAXENTITIES];
float f_DamageTakenFloatObj[MAXENTITIES];
int OwnerOfText[MAXENTITIES];

int i_NormalBarracks_HexBarracksUpgrades_2[MAXENTITIES];

#define ZR_BARRACKS_TROOP_CLASSES			(1 << 3) //Allows training of units, although will limit support buildings to 1.

#define EFL_FORCE_CHECK_TRANSMIT (1 << 7)
#define EFL_IN_SKYBOX (1 << 17)

#define MAX_REBELS_ALLOWED 4

float RotateByDefaultReturn(int entity)
{
	return RotateByDefault[entity];
}
void SetRotateByDefaultReturn(int entity, float Setfloat)
{
	RotateByDefault[entity] = Setfloat;
}
//Default ones, most buildings are metal.
static char g_HurtSounds[][] = {
	"physics/metal/metal_box_impact_hard1.wav",
	"physics/metal/metal_box_impact_hard2.wav",
	"physics/metal/metal_box_impact_hard3.wav",
};

//Default ones, most buildings are metal.
static char g_DeathSounds[][] = {
	"physics/metal/metal_box_break1.wav",
	"physics/metal/metal_box_break2.wav",
};

void Object_MapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
}
void Object_PluginStart()
{
	CEntityFactory factory = new CEntityFactory("obj_building", _, OnDestroy);
	factory.DeriveFromClass("prop_dynamic_override");
	factory.BeginDataMapDesc()
	.DefineIntField("m_iRepair")
	.DefineIntField("m_iRepairMax")
	.DefineIntField("m_iMaxHealth")
	.DefineBoolField("m_bSentryBuilding")
	.EndDataMapDesc();
	factory.Install();
}

int Object_GetRepairHealth(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iRepair");
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
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);

	Building_RotateAllDepencencies(entity);
}

methodmap ObjectGeneric < CClotBody
{
	public ObjectGeneric(int client, const float vecPos[3], const float vecAng[3],
						const char[] model,
						const char[] modelscale = "1.0",
						const char[] basehealth = "750",
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0},
						const float FakemodelOffset = 0.0,
						bool DoFakeModel = true)
	{
		int obj = CreateEntityByName("obj_building");
		b_IsEntityAlwaysTranmitted[obj] = true;
		Hook_DHook_UpdateTransmitState(obj);
		DispatchKeyValueVector(obj, "origin",	 vecPos);
		DispatchKeyValueVector(obj, "angles",	 vecAng);
		DispatchKeyValue(obj,		 "model",	 model);
		DispatchKeyValue(obj,	   "modelscale", modelscale);
		DispatchKeyValue(obj,	   "solid", "2");
		DispatchKeyValue(obj,	   "physdamagescale", "0.0");
		DispatchKeyValue(obj,	   "minhealthdmg", "0.0");
		DispatchSpawn(obj);

		ObjectGeneric objstats = view_as<ObjectGeneric>(obj);
		objstats.BaseHealth = StringToInt(basehealth);
		SetTeam(obj, GetTeam(client));
			
 		b_CantCollidie[obj] = false;
	 	b_CantCollidieAlly[obj] = false;
		b_AllowCollideWithSelfTeam[obj] = true;
		i_NpcWeight[obj] = 999;
		i_NpcIsABuilding[obj] = true;
		i_IsABuilding[obj] = true;
		b_NoKnockbackFromSources[obj] = true;
		f_DamageTakenFloatObj[obj] = 0.0;
		SDKHook(obj, SDKHook_Think, ObjBaseThink);
		SDKHook(obj, SDKHook_ThinkPost, ObjBaseThinkPost);
		objstats.SetNextThink(GetGameTime());
		SetEntityCollisionGroup(obj, 24);
		RotateByDefault[obj] = 0.0;
		
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
		//Running UpdateCollisionBox On this entity just makes it calculate its own one, bad.
	//	objstats.UpdateCollisionBox();

		static Function defaultFunc;
		if(!defaultFunc)
			defaultFunc = GetFunctionByName(null, "ObjectGeneric_CanBuild");
		
		objstats.FuncCanUse = INVALID_FUNCTION;
		objstats.FuncCanBuild = defaultFunc;
		objstats.FuncShowInteractHud = INVALID_FUNCTION;

		SetEntPropEnt(obj, Prop_Send, "m_hOwnerEntity", client);
		
		SDKHook(obj, SDKHook_OnTakeDamage, ObjectGeneric_ClotTakeDamage);
		SetEntityRenderMode(obj, RENDER_TRANSCOLOR);
		SetEntityRenderColor(obj, 0, 0, 0, 0);
		int entity;
		if(DoFakeModel)
		{
			entity = objstats.EquipItemSeperate("partyhat", model,_,_,_,FakemodelOffset);
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingNotReady);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", objstats.index);
			objstats.m_iWearable1 = entity;
		}
		
		entity = objstats.EquipItemSeperate("partyhat", model,_,_,_,FakemodelOffset);
		SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingReady);
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", objstats.index);
		objstats.m_iWearable2 = entity;

		//think once
		ObjBaseThink(objstats.index);

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
		int item = CreateEntityByName("prop_dynamic_override");
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
		SetEntPropEnt(item, Prop_Send, "m_hOwnerEntity", this.index);
		
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

	//	SetEntPropFloat(item, Prop_Send, "m_fadeMinDist", 0.0);
	//	SetEntPropFloat(item, Prop_Send, "m_fadeMaxDist", 100.0);	

		SetVariantString("!activator");
		AcceptEntityInput(item, "SetParent", this.index);
		MakeObjectIntangeable(item);
		return item;
	} 
	public void SetActivity(const char[] animation, bool Is_sequence = false)
	{
		if(IsValidEntity(this.m_iWearable1))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable1);
			npcstats.SetActivity(animation, Is_sequence);
		}
		if(IsValidEntity(this.m_iWearable2))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable2);
			npcstats.SetActivity(animation, Is_sequence);
		}
	}
	public void SetPlaybackRate(float flSpeedAnim)
	{
		if(IsValidEntity(this.m_iWearable1))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable1);
			npcstats.SetPlaybackRate(flSpeedAnim);
		}
		if(IsValidEntity(this.m_iWearable2))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable2);
			npcstats.SetPlaybackRate(flSpeedAnim);
		}
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
			SetEntProp(this.index, Prop_Data, "m_iHealth", value);
			SetEntProp(this.index, Prop_Data, "m_iMaxHealth", value);
			SetEntProp(this.index, Prop_Data, "m_iRepair", RoundToCeil(float(value) * 1.5));
			SetEntProp(this.index, Prop_Data, "m_iRepairMax", RoundToCeil(float(value) * 1.5));
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
			SetEntProp(this.index, Prop_Data, "m_bSentryBuilding", value);
		}
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bSentryBuilding"));
		}
	}
	property bool m_bBurning
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}

	
	public bool PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return false;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.2;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
		return true;
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
}

public Action SetTransmit_BuildingNotReady(int entity, int client)
{
	return SetTransmit_BuildingShared(entity, client, true);
}

public Action SetTransmit_BuildingReady(int entity, int client)
{
	return SetTransmit_BuildingShared(entity, client, false);
}
public Action SetTransmit_BuildingReadyTestThirdPersonIgnore(int entity, int client)
{
	return SetTransmit_BuildingShared(entity, client, false, true);
}

static Action SetTransmit_BuildingShared(int entity, int client, bool reverse, bool Ignorethird = false)
{
	if(client < 1 || client > MaxClients)
		return Plugin_Continue;
	
	int building;
	if(Ignorethird)
	{
		building = EntRefToEntIndex(OwnerOfText[entity]);
	}
	else
	{
		building = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	}
	if(building == -1)
	{
		RemoveEntity(entity);
		return Plugin_Continue;
	}
	int owner;

		
	owner = GetEntPropEnt(building, Prop_Send, "m_hOwnerEntity");
	
	bool hide;
	if(owner != -1)
	{
		if(!Ignorethird && EntRefToEntIndex(Building_Mounted[building]) == owner)
		{
			return Plugin_Continue;
		}
		else
		{
			hide = !CanUseBuilding[building][client];	
		}
	}

	//abomination
	return (hide ^ reverse /*^ InvertTransmitLogic(client)*/) ? Plugin_Stop : Plugin_Continue;
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
	maxcount = (Blacksmith_IsASmith(client) || Merchant_IsAMerchant(client)) ? 0 : 1;

	return (!count && maxcount);
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


	Function func = func_NPCThink[objstats.index];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(objstats.index);
		Call_Finish();
	}

	objstats.m_flNextDelayTime = gameTime + 0.2;
	BuildingDisplayRepairLeft(objstats.index);
	

	int health = GetEntProp(objstats.index, Prop_Data, "m_iHealth");
	int maxhealth = GetEntProp(objstats.index, Prop_Data, "m_iMaxHealth");
	float Ratio = float(health) / float(maxhealth);
		
	if(Ratio < 0.15)
	{
		if(!objstats.m_bBurning)
		{
			IgniteTargetEffect(objstats.index, _, _);
			objstats.m_bBurning = true;
		}
	}
	else
	{
		if(objstats.m_bBurning)
		{
			ExtinguishTarget(objstats.index);
			objstats.m_bBurning = false;
		}
	}

	int owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
	if(owner == -1)
	{
		if(FuncCanBuild[objstats.index] && FuncCanBuild[objstats.index] != INVALID_FUNCTION)
		{
			// If 0 can't build, destory the unclaimed building (sentry)
			if(!Object_CanBuild(FuncCanBuild[objstats.index], 0))
			{
				RemoveEntity(objstats.index);
				return false;
			}
		}		
		
		if(i_NpcInternalId[objstats.index] == ObjectBarricade_ID())
		{
			if(GetEntProp(objstats.index, Prop_Send, "m_CollisionGroup") != 1)
			{
				SetEntityCollisionGroup(objstats.index, 1);
				b_ThisEntityIgnored[objstats.index] = true;
			}
		}

		int wearable = objstats.m_iWearable1;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
		
		wearable = objstats.m_iWearable2;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);

		if(IsValidEntity(objstats.m_iWearable4))
			RemoveEntity(objstats.m_iWearable4);
			
	}
	else
	{
		for(int target = 1; target <= MaxClients; target++)
		{
			if(FuncCanUse[objstats.index] && FuncCanUse[objstats.index] != INVALID_FUNCTION && IsClientInGame(target) && IsPlayerAlive(target))
			{
				Call_StartFunction(null, FuncCanUse[objstats.index]);
				Call_PushCell(objstats.index);
				Call_PushCell(target);
				Call_Finish(CanUseBuilding[objstats.index][target]);
			}
			else
			{
				CanUseBuilding[objstats.index][target] = true;
			}
		}

		if(i_NpcInternalId[objstats.index] == ObjectBarricade_ID())
		{
			if(GetEntProp(objstats.index, Prop_Send, "m_CollisionGroup") != 24)
			{
				SetEntityCollisionGroup(objstats.index, 24);
				b_ThisEntityIgnored[objstats.index] = false;
			}
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
		{
			SetEntityRenderColor(wearable, r, g, 0, 100);
			/*
			if(b_Anger[wearable])
			{
				this.SetSequence(0);	
			}
			else
			{
				this.SetSequence(0);
			}
			*/
		}
		
		wearable = objstats.m_iWearable2;
		if(wearable != -1)
		{
			SetEntityRenderColor(wearable, r, g, 0, 255);
		}
		else
		{
			SetEntityRenderColor(objstats.index, r, g, 0, 255);
		}
		
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
	
	bool MountedObjectInteracted = false;
	int entity = obj;
	if(entity <= MaxClients)
	{
		// Player mounted
		entity = EntRefToEntIndex(Building_Mounted[obj]);
		if(entity == -1)
			return false;

		MountedObjectInteracted = true;
	}

	Function func = func_NPCInteract[entity];
	if((!func || func == INVALID_FUNCTION) && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != -1)
		return false;
/*
	if(PlayerIsInNpcBattle(client, 1.0) && MountedObjectInteracted)
	{
		//self mounted ignores this.
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") != client)
			return false;
	}
*/

	bool result;
	
	static char plugin[64];
	NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
	if(StrContains(plugin, "obj_", false) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
		{
			// Claim a unclaimed building
			if(weapon != -1 && (i_IsWrench[weapon] || Attributes_Get(weapon, 4018, 0.0) >= 1.0))
			{
				if(FuncCanBuild[entity] && FuncCanBuild[entity] != INVALID_FUNCTION)
				{
					if(Object_CanBuild(FuncCanBuild[entity], client))
					{
						SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
						ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
						if(IsValidEntity(objstats.m_iWearable4))
						{
							char HealthText[32];
							int Owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
							if(IsValidClient(Owner))
								Format(HealthText, sizeof(HealthText), "%N", Owner);
							else
								Format(HealthText, sizeof(HealthText), "%s", " ");

							DispatchKeyValue(objstats.m_iWearable4, "message", HealthText);
						}
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
			//dont interact with buildings if you are carring something
			if(MountedObjectInteracted || !IsPlayerCarringObject(client) && !BuildingIsBeingCarried(entity))
			{
				func = func_NPCInteract[entity];
				if(func && func != INVALID_FUNCTION)
				{
					Call_StartFunction(null, func);
					Call_PushCell(client);
					Call_PushCell(weapon);
					Call_PushCell(entity);
					Call_Finish(result);
				}
				return true;
			}
		}
	}

	return false;
}

int Object_NamedBuildings(int owner = 0, const char[] name)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(owner == 0 || GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
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
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
		{
			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_", false) != -1)
			{
				if(StrContains(plugin, "barricade", false) != -1)
					continue;
				if(StrContains(plugin, "obj_decorative", false) != -1)
					continue;

				ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
				if(objstats.SentryBuilding)
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
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(view_as<ObjectGeneric>(entity).SentryBuilding && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
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
	maxAllowed += Blacksmith_Additional_SupportBuildings(client); 
	maxAllowed += Merchant_Additional_SupportBuildings(client); 
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

	if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES)
	{
		if(!ingore_glass)
		{
			if(maxAllowed > 2)
			{
				maxAllowed = 2;

			}
		}
	}
	return maxAllowed;
}

float Object_GetMaxHealthMulti(int client)
{
	if(client <= MaxClients)
		return Attributes_GetOnPlayer(client, 286);
	
	return 2.5 + (view_as<Citizen>(client).m_iGunValue * 0.000135);
}

Action ObjectGeneric_ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(RaidBossActive && RaidbossIgnoreBuildingsLogic(2)) //They are ignored anyways
		return Plugin_Handled;

	if((damagetype & DMG_CRUSH))
		return Plugin_Handled;

	if(Resistance_for_building_High[victim] > GetGameTime())
	{
		damage *= 0.75;
	}
	
	if(CurrentModifOn() == 2 || CurrentModifOn() == 3)
		damage *= 1.25;

	if(Rogue_Mode()) //buildings are refunded alot, so they shouldnt last long.
	{
		int scale = Rogue_GetRoundScale();
		if(scale < 2)
		{
			//damage *= 1.0;
		}
		else if(scale < 4)
		{
			damage *= 2.0;
		}
		else
		{
			damage *= 3.0;
		}
	}

	damage *= 0.1;
	if(Damage_Modifiy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
	{
		return Plugin_Handled;
	}
	int dmg = FloatToInt_DamageValue_ObjBuilding(victim, damage);
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	health -= dmg;

	int Owner = GetEntPropEnt(victim, Prop_Send, "m_hOwnerEntity");
	if(Owner != -1)
	{
		i_BarricadeHasBeenDamaged[Owner] += dmg;
	}
	if(health < 0)
	{
		DestroyBuildingDo(victim);
		return Plugin_Handled;
	}
	
	ObjectGeneric objstats = view_as<ObjectGeneric>(victim);
	if(objstats.PlayHurtSound())
	{
		damagePosition[2] -= 40.0;
		TE_ParticleInt(g_particleImpactMetal, damagePosition);
		TE_SendToAll();
	}

	SetEntProp(victim, Prop_Data, "m_iHealth", health);
	return Plugin_Handled;
}

void DestroyBuildingDo(int entity)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	objstats.PlayDeathSound();
	float VecOrigin[3];
	GetAbsOrigin(entity, VecOrigin);
	VecOrigin[2] += 15.0;
	DataPack pack = new DataPack();
	pack.WriteFloat(VecOrigin[0]);
	pack.WriteFloat(VecOrigin[1]);
	pack.WriteFloat(VecOrigin[2]);
	pack.WriteCell(0);
	RequestFrame(MakeExplosionFrameLater, pack);
	RemoveEntity(entity);
}

public void ObjBaseThinkPost(int building)
{
	CBaseCombatCharacter(building).SetNextThink(GetGameTime() + 0.1);
}

public void ObjBaseThink(int building)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(building);
	//Fixes some issues when mounted
	int wearable = objstats.m_iWearable1;
	if(wearable != -1)
	{			
		SetEntProp(wearable, Prop_Send, "m_fEffects", GetEntProp(wearable, Prop_Send, "m_fEffects") ^ EF_PARENT_ANIMATES);
	}
	wearable = objstats.m_iWearable2;
	if(wearable != -1)
	{
		SetEntProp(wearable, Prop_Send, "m_fEffects", GetEntProp(wearable, Prop_Send, "m_fEffects") ^ EF_PARENT_ANIMATES);
	}

	//do not think if you are being carried.
	if(BuildingIsBeingCarried(building))
		return;

	ObjectGeneric_ClotThink(objstats);
}

void BuildingDisplayRepairLeft(int entity)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	char HealthText[64];
	int HealthColour[4];
	int Repair = GetEntProp(objstats.index, Prop_Data, "m_iRepair");
//	int MaxRepair = GetEntProp(objstats.index, Prop_Data, "m_iRepairMax");

	int Health = GetEntProp(objstats.index, Prop_Data, "m_iHealth");
//	int MaxHealth = GetEntProp(objstats.index, Prop_Data, "m_iMaxHealth");
	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[3] = 255;
	if(Repair <= 0)
	{
		HealthColour[0] = 255;
		HealthColour[1] = 0;
		HealthColour[3] = 255;
		char ThousandBuffer[64];
		IntToString(Health, ThousandBuffer, sizeof(ThousandBuffer));
		ThousandString(ThousandBuffer, sizeof(ThousandBuffer));
		Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ThousandBuffer);
	}
	else
	{
		char ThousandBuffer[64];
		IntToString(Repair, ThousandBuffer, sizeof(ThousandBuffer));
		ThousandString(ThousandBuffer, sizeof(ThousandBuffer));
		Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ThousandBuffer);
		Format(HealthText, sizeof(HealthText), "%s%s", HealthText, " -> ");
		IntToString(Health, ThousandBuffer, sizeof(ThousandBuffer));
		ThousandString(ThousandBuffer, sizeof(ThousandBuffer));
		Format(HealthText, sizeof(HealthText), "%s%s", HealthText, ThousandBuffer);
	}


	if(IsValidEntity(objstats.m_iWearable3))
	{
		char sColor[32];
		Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
		DispatchKeyValue(objstats.m_iWearable3,     "color", sColor);
		DispatchKeyValue(objstats.m_iWearable3, "message", HealthText);
	}
	else
	{
		float Offset[3];
		Offset[2] = f3_CustomMinMaxBoundingBox[entity][2];
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 6, HealthColour, objstats.index);
		DispatchKeyValue(TextEntity, "font", "4");
		objstats.m_iWearable3 = TextEntity;	
	}
	if(!IsValidEntity(objstats.m_iWearable4))
	{
		HealthColour[0] = 0;
		HealthColour[1] = 255;
		HealthColour[2] = 0;
		HealthColour[3] = 255;
		int Owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
		if(IsValidClient(Owner))
			Format(HealthText, sizeof(HealthText), "%N", Owner);
		else if(Owner != -1 && Citizen_IsIt(Owner))
			strcopy(HealthText, sizeof(HealthText), "Rebel");
		else
			strcopy(HealthText, sizeof(HealthText), " ");
		float Offset[3];
		Offset[2] = f3_CustomMinMaxBoundingBox[entity][2];
		Offset[2] += 6.0;
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 6, HealthColour, objstats.index);
		OwnerOfText[TextEntity] = Owner;
		DispatchKeyValue(TextEntity, "font", "4");
		objstats.m_iWearable4 = TextEntity;	
	}
	
	if(!IsValidEntity(objstats.m_iWearable5))
	{
		HealthColour[0] = 0;
		HealthColour[1] = 255;
		HealthColour[2] = 0;
		HealthColour[3] = 255;
		float Offset[3];
		Offset[2] = f3_CustomMinMaxBoundingBox[entity][2] * 0.4;
		Offset[2] += 6.0;
		Format(HealthText, sizeof(HealthText), "%s", "Ready!");
		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 0, HealthColour, objstats.index);
		OwnerOfText[TextEntity] = EntIndexToEntRef(objstats.index);
		DispatchKeyValue(TextEntity, "font", "4");
		objstats.m_iWearable5 = TextEntity;	
	}
}
/*
static Action SetTransmit_OwnerOfBuilding(int entity, int client)
{
	if(OwnerOfText[entity] == client)
	{
		return Plugin_Continue;
	}
	return Plugin_Handled;
}
*/

int FloatToInt_DamageValue_ObjBuilding(int victim, float damage)
{
	int Damage_Return;

	if (damage <= 1.0 && damage > 0.0)
	{
		f_DamageTakenFloatObj[victim] += damage;
			
		if(f_DamageTakenFloatObj[victim] >= 1.0)
		{
			f_DamageTakenFloatObj[victim] -= 1.0;
			Damage_Return = 1;
		}
	}
	else
	{
		if(Damage_Return < 0.0) //negative heal
		{
			Damage_Return = RoundToFloor(damage);
		}
		else
		{
			Damage_Return = RoundToFloor(damage);
		
			float Decimal_healing = FloatFraction(damage);
								
								
			f_DamageTakenFloatObj[victim] += Decimal_healing;
								
			while(f_DamageTakenFloatObj[victim] >= 1.0)
			{
				f_DamageTakenFloatObj[victim] -= 1.0;
				Damage_Return += 1;
			}
		}		
	}
	return Damage_Return;
}