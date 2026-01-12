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
//static Function FuncShowInteractHud[MAXENTITIES];

static int Building_Max_Health[MAXENTITIES]={0, ...};
static bool CanUseBuilding[MAXENTITIES][MAXPLAYERS];
int i_MachineJustClickedOn[MAXPLAYERS];
static float RotateByDefault[MAXENTITIES]={0.0, ...};
int Building_BuildingBeingCarried[MAXENTITIES];
float f_DamageTakenFloatObj[MAXENTITIES];
int OwnerOfText[MAXENTITIES];
float f_CooldownShowRange[MAXPLAYERS];

//Performance improvement, no need to check this littearlly every fucking frame
//other things DO need it, but not this.
float f_TransmitDelayCheck[MAXENTITIES][MAXPLAYERS];
Action b_TransmitBiasDo[MAXENTITIES][MAXPLAYERS];

#define DMGMULTI_CONST2_RED 5.0
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
	PrecacheModel("models/props_debris/concrete_debris128pile001a.mdl");
	Zero2(f_TransmitDelayCheck);
	Zero(f_CooldownShowRange);
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
	.DefineBoolField("m_bConstructBuilding")
	.DefineBoolField("m_bTransparrency")
	.DefineFloatField("m_fLastTimeClaimed")
	.DefineBoolField("m_bCannotBePickedUp")
	.DefineBoolField("m_bNoOwnerRequired")

	//needed so npc stuff doesnt break
	.DefineIntField("m_iHealthBar")
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
		if(IsValidClient(client))
			SetTeam(obj, GetTeam(client));
		else
			SetTeam(obj, TFTeam_Blue);
			
 		b_CantCollidie[obj] = false;
	 	b_CantCollidieAlly[obj] = false;
		b_AllowCollideWithSelfTeam[obj] = true;
		i_NpcWeight[obj] = 999;
		i_NpcIsABuilding[obj] = true;
		i_IsABuilding[obj] = true;
		b_NoKnockbackFromSources[obj] = true;
		f_DamageTakenFloatObj[obj] = 0.0;
	
		for(int clients=1; clients<=MaxClients; clients++)
		{
			Building_Collect_Cooldown[obj][clients] = 0.0;
			//reset usage cooldown!
		}
		SDKHook(obj, SDKHook_Think, ObjBaseThink);
		SDKHook(obj, SDKHook_ThinkPost, ObjBaseThinkPost);
		objstats.SetNextThink(GetGameTime());
		SetEntityCollisionGroup(obj, 24);
		RotateByDefault[obj] = 0.0;
		
		for (int i = 0; i < ZR_MAX_BUILDINGS; i++)
		{
			if (EntRefToEntIndexFast(i_ObjectsBuilding[i]) <= 0)
			{
				i_ObjectsBuilding[i] = EntIndexToEntRef(obj);
				i = ZR_MAX_BUILDINGS;
			}
		}

		f3_CustomMinMaxBoundingBox[obj][0] = CustomThreeDimensions[0];
		f3_CustomMinMaxBoundingBox[obj][1] = CustomThreeDimensions[1];
		f3_CustomMinMaxBoundingBox[obj][2] = CustomThreeDimensions[2];
		
		if(FakemodelOffset)
		{
			f3_CustomMinMaxBoundingBox[obj][2] -=FakemodelOffset;
		}
		

		if(FakemodelOffset)
		{
			f3_CustomMinMaxBoundingBoxMinExtra[obj][0] = -CustomThreeDimensions[0];
			f3_CustomMinMaxBoundingBoxMinExtra[obj][1] = -CustomThreeDimensions[1];
			f3_CustomMinMaxBoundingBoxMinExtra[obj][2] = -FakemodelOffset;
		}
		else
		{
			f3_CustomMinMaxBoundingBoxMinExtra[obj][0] = -CustomThreeDimensions[0];
			f3_CustomMinMaxBoundingBoxMinExtra[obj][1] = -CustomThreeDimensions[1];
			f3_CustomMinMaxBoundingBoxMinExtra[obj][2] = 0.0;
		}

		SetEntProp(obj, Prop_Data, "m_nSolidType", 2); 

		SetEntPropVector(obj, Prop_Data, "m_vecMaxs", f3_CustomMinMaxBoundingBox[obj]);
		SetEntPropVector(obj, Prop_Data, "m_vecMins", f3_CustomMinMaxBoundingBoxMinExtra[obj]);
		//Running UpdateCollisionBox On this entity just makes it calculate its own one, bad.
	//	objstats.UpdateCollisionBox();

		static Function defaultFunc;
		if(!defaultFunc)
			defaultFunc = GetFunctionByName(null, "ObjectGeneric_CanBuild");
		
		objstats.FuncCanUse = INVALID_FUNCTION;
		objstats.FuncCanBuild = defaultFunc;
		objstats.FuncShowInteractHud = INVALID_FUNCTION;

		if(IsValidClient(client))
			SetEntPropEnt(obj, Prop_Send, "m_hOwnerEntity", client);
		
		SDKHook(obj, SDKHook_OnTakeDamage, ObjectGeneric_ClotTakeDamage);
	//	SDKHook(obj, SDKHook_OnTakeDamagePost, ObjectGeneric_ClotTakeDamage_Post);
		/*
			how it works:
			if a building is on cooldown/can have one, we spawn a 2nd prop, see below under fake model.
			We made it entirely solid visibly, i.e. not half invisible and make the main prop invisible
			to save on resources unlike before we just re-use the base model
			We dont do set transmit on it, beacuse if its always half invisible, then that means we can just hide the fake model, i.e. fully visible to indicate the building
			can be used
			Zfighting cant happen beacuse its in the exact same position

			im such a genuis...
			-Artvin

		*/
		int entity;
		if(DoFakeModel)
		{
			SetEntityRenderMode(obj, RENDER_TRANSCOLOR);
			//Main prop is always half visible.

			entity = objstats.EquipItemSeperate(model);
			SetEntityRenderMode(entity, RENDER_NORMAL);
			SDKHook(entity, SDKHook_SetTransmit, SetTransmit_BuildingReady);
			SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", objstats.index);
			objstats.m_iWearable1 = entity;
		}

		//think once
		ObjBaseThink(objstats.index);
		UpdateDoublebuilding(objstats.index);

		return objstats;
	}

	property int index 
	{ 
		public get() { return view_as<int>(this); } 
	}
	public int EquipItemSeperate(
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
		SetEntProp(item, Prop_Send, "m_nSkin", skin);
		if(DontParent)
		{
			return item;
		}
		b_ThisEntityIgnored[item] = true;

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
		CClotBody npcself = view_as<CClotBody>(this.index);
		npcself.SetActivity(animation, Is_sequence);
		if(IsValidEntity(this.m_iWearable1))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable1);
			npcstats.SetActivity(animation, Is_sequence);
		}
	}
	public void SetPlaybackRate(float flSpeedAnim)
	{
		CClotBody npcself = view_as<CClotBody>(this.index);
		npcself.SetPlaybackRate(flSpeedAnim);
		if(IsValidEntity(this.m_iWearable1))
		{
			CClotBody npcstats = view_as<CClotBody>(this.m_iWearable1);
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
	property int m_iConstructDeathModel
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][8]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][8] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][8] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iMasterBuilding
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][6]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][6] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][6] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iExtrabuilding1
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][7]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][7] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][7] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iExtrabuilding2
	{
		public get()		 
		{ 
			return EntRefToEntIndex(i_Wearable[this.index][8]); 
		}
		public set(int iInt) 
		{
			if(iInt == -1)
			{
				i_Wearable[this.index][8] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_Wearable[this.index][8] = EntIndexToEntRef(iInt);
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
	property float LastTimeClaimed
	{
		public set(float value)
		{
			SetEntPropFloat(this.index, Prop_Data, "m_fLastTimeClaimed", value);
		}
		public get()
		{
			return GetEntPropFloat(this.index, Prop_Data, "m_fLastTimeClaimed");
		}
	}
	property bool m_bNoOwnerRequired
	{
		public set(bool value)
		{
			SetEntProp(this.index, Prop_Data, "m_bNoOwnerRequired", value);
		}
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bNoOwnerRequired"));
		}
	}
	property bool m_bConstructBuilding
	{
		public set(bool value)
		{
			//no owner
			this.m_bNoOwnerRequired = value;
			SetEntProp(this.index, Prop_Data, "m_bConstructBuilding", value);
		}
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bConstructBuilding"));
		}
	}
	property bool m_bTransparrency
	{
		public set(bool value)
		{
			//no owner
			SetEntProp(this.index, Prop_Data, "m_bTransparrency", value);
		}
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bTransparrency"));
		}
	}
	property bool m_bCannotBePickedUp
	{
		public set(bool value)
		{
			SetEntProp(this.index, Prop_Data, "m_bCannotBePickedUp", value);
		}
		public get()
		{
			return view_as<bool>(GetEntProp(this.index, Prop_Data, "m_bCannotBePickedUp"));
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
	
	property float m_flGlowingLogic
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
}
public Action SetTransmit_BuildingReady(int entity, int client)
{
	if(f_TransmitDelayCheck[entity][client] > GetGameTime())
	{
		return b_TransmitBiasDo[entity][client];
	}
	f_TransmitDelayCheck[entity][client] = GetGameTime() + 0.25;

	b_TransmitBiasDo[entity][client] = SetTransmit_BuildingShared(entity, client, false);
	return b_TransmitBiasDo[entity][client];
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
	if(!Ignorethird && EntRefToEntIndex(Building_Mounted[building]) == owner && !view_as<ObjectGeneric>(building).m_bNoOwnerRequired)
	{
		return Plugin_Continue;
	}
	else
	{
		hide = !CanUseBuilding[building][client];	
	}

	//abomination
	return (hide ^ reverse /*^ InvertTransmitLogic(client)*/) ? Plugin_Stop : Plugin_Continue;
}

public bool ObjectGeneric_CanBuild(int client, int &count, int &maxcount)
{
	if(client)
	{
		int total;
		count = Object_SupportBuildings(client, total);
		maxcount = Object_MaxSupportBuildings(client);
		if(count >= maxcount || total > 79)
			return false;
	}
	
	return true;
}

public bool ObjectGeneric_CanBuildSentryBarracks(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
		
	return ObjectGeneric_CanBuildSentryInternal(client, count, maxcount);
}
public bool ObjectGeneric_CanBuildSentry(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
	if(i_NormalBarracks_HexBarracksUpgrades_2[client] & ZR_BARRACKS_TROOP_CLASSES)
		return false;
	if(f_VintulumBombRecentlyUsed[client] > GetGameTime())
		return false;

	return ObjectGeneric_CanBuildSentryInternal(client, count, maxcount);
}

bool ObjectGeneric_CanBuildSentryInternal(int client, int &count, int &maxcount)
{
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

static bool ObjectGeneric_ClotThink(ObjectGeneric objstats)
{
	float gameTime = GetGameTime(objstats.index);
	if(objstats.m_flNextDelayTime > gameTime)
		return false;

	objstats.m_flNextDelayTime = gameTime + 0.2;

	Function func = func_NPCThink[objstats.index];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(objstats.index);
		Call_Finish();
	}

	BuildingUpdateTextHud(objstats.index);

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

	if(GetTeam(objstats.index) != TFTeam_Red)
		return false;

	int owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
	if(owner == -1 && !objstats.m_bConstructBuilding && !objstats.m_bNoOwnerRequired)
	{                                               
		//give 30 sec untill it destroys itself
		if(objstats.LastTimeClaimed + 30.0 < GetGameTime())
		{
			DestroyBuildingDo(objstats.index);
			return false;
		}
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
		SetEntityRenderColor(objstats.index, 55, 55, 55, 100);
		
		int wearable = objstats.m_iWearable1;
		if(wearable != -1)
		{
			SetEntityRenderMode(wearable, RENDER_TRANSCOLOR);
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
		}
		
		wearable = objstats.m_iWearable2;
		if(wearable != -1)
			SetEntityRenderColor(wearable, 55, 55, 55, 100);
			
	}
	else
	{
		objstats.LastTimeClaimed = GetGameTime();
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

		bool HideBuildingForce = false;
		if(i_NpcInternalId[objstats.index] == ObjectBarricade_ID())
		{
			if(GetEntProp(objstats.index, Prop_Send, "m_CollisionGroup") != 24)
			{
				SetEntityCollisionGroup(objstats.index, 24);
				b_ThisEntityIgnored[objstats.index] = false;
			}
			if(RaidbossIgnoreBuildingsLogic(1))
			{
				HideBuildingForce = true;
			}
		}
		if(HideBuildingForce)
		{
			SetEntityRenderColor(objstats.index, 0, 0, 0, 255);
		}
		else
		{
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
				
				if(!objstats.m_bTransparrency)
				{
					SetEntityRenderColor(objstats.index, r, g, 0, 100);
					SetEntityRenderColor(wearable, r, g, 0, 255);
					SetEntityRenderMode(wearable, RENDER_NORMAL);
				}
				else
				{
					SetEntityRenderColor(objstats.index, r, g, 0, 100);
					SetEntityRenderColor(wearable, r, g, 0, 125);
					SetEntityRenderMode(wearable, RENDER_TRANSCOLOR);
				}
			}
			else
			{
				if(!objstats.m_bTransparrency)
					SetEntityRenderColor(objstats.index, r, g, 0, 255);
				else
				{
					SetEntityRenderColor(objstats.index, r, g, 0, 125);
					SetEntityRenderMode(objstats.index, RENDER_TRANSCOLOR);
				}
			}
		}
	}
	return true;
}

bool Object_ShowInteractHud(int client, int entity)
{
	if(!FuncShowInteractHud[entity] || FuncShowInteractHud[entity] == INVALID_FUNCTION)
	{
		//No interact hud....
		//display it forcefully.
		char ButtonDisplay[255];
		BuildingVialityDisplay(client, entity, ButtonDisplay, sizeof(ButtonDisplay));
		PrintCenterText(client, "%s", ButtonDisplay);
		return true;
	}
	
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
		ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1 && !objstats.m_bNoOwnerRequired)
		{
			// Claim a unclaimed building
			if(weapon != -1 && (i_IsWrench[weapon] || Attributes_Get(weapon, 4018, 0.0) >= 1.0))
			{
				if(FuncCanBuild[entity] && FuncCanBuild[entity] != INVALID_FUNCTION)
				{
					if(Object_CanBuild(FuncCanBuild[entity], client))
					{
						
						SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", client);
						BuildingUpdateTextHud(entity);
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
					f_TransmitDelayCheck[entity][client] = 0.0;
					if(IsValidEntity(objstats.m_iWearable1))
						f_TransmitDelayCheck[objstats.m_iWearable1][client] = 0.0;
					if(IsValidEntity(objstats.m_iWearable2))
						f_TransmitDelayCheck[objstats.m_iWearable2][client] = 0.0;
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
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
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

int Object_SupportBuildings(int owner, int &all = 0)
{
	int count;
	
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		if(GetTeam(entity) != TFTeam_Red)
			continue;
		
		static char plugin[64];
		NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
		if(StrContains(plugin, "obj_", false) != -1)
		{
			if(StrContains(plugin, "barricade", false) != -1)
				continue;
			
			if(StrContains(plugin, "obj_decorative", false) != -1)
				continue;
			
			ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
			if(objstats.SentryBuilding || objstats.m_bConstructBuilding)
				continue;
			
			all++;
			if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
				count++;
		}
	}

	return count;
}

int Object_GetSentryBuilding(int owner)
{
	int entity = -1;
	if(IsValidEntity(i_PlayerToCustomBuilding[owner]))
	{
		//This is faster and better, all sentry buildings are this only anyways.
		entity = EntRefToEntIndex(i_PlayerToCustomBuilding[owner]);
		if(!view_as<ObjectGeneric>(entity).SentryBuilding)
		{
			//Not a sentry building somehow, nope out.
			entity = -1;
		}
	}
	
	if(entity == -1)
	{
		while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
		{
			if(view_as<ObjectGeneric>(entity).SentryBuilding && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == owner)
				break;
		}
	}

	return entity;
}

int Object_MaxSupportBuildings(int client, bool ingore_glass = false)
{
	int maxAllowed = 1;
	
  	int Building_health_attribute = i_MaxSupportBuildingsLimit[client];
	if(Dungeon_Mode())
		maxAllowed += 1;
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
	
	if(GetTeam(victim) == TFTeam_Red)
	{
		if(CurrentModifOn() == 2 || CurrentModifOn() == 3)
			damage *= 1.25;

		if(Rogue_Mode()) //buildings are refunded alot, so they shouldnt last long.
		{
			int scale = Waves_GetRoundScale();
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
		if(Dungeon_Mode()) //Buildings are good but not too good, its mainly construct buildings that are used.
		{
			damage *= 3.0;
		}
	}
	else
	{
		if(Dungeon_Mode())
		{
			float vecTarget[3]; WorldSpaceCenter(attacker, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(victim, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget > (600.0 * 600.0))
			{
				damage = 0.0;
				if(IsValidClient(attacker) && f_CooldownShowRange[attacker] < GetGameTime())
				{
					f_CooldownShowRange[attacker] = GetGameTime() + 0.25;
					float NewPos[3]; 
					GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", NewPos);
					NewPos[2] += 10.0;
					spawnRing_Vectors(NewPos, 600.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 0.15, 2.0, 2.0, 2, _, attacker);
				}
				return Plugin_Handled;
			}
		}
	}

	if(Damage_Modifiy(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom))
	{
		return Plugin_Handled;
	}
	if(attacker <= MaxClients && dieingstate[attacker] != 0)
	{
		//no dmg at all.
		return Plugin_Handled;
	}
	ObjectGeneric_ClotTakeDamage_Post(victim, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	return Plugin_Changed;
}

void DestroyBuildingDo(int entity, bool DontCheckAgain = false)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(IsValidEntity(objstats.m_iMasterBuilding) && !DontCheckAgain)
	{
		DestroyBuildingDo(objstats.m_iMasterBuilding, true);

		ObjectGeneric objstats2 = view_as<ObjectGeneric>(objstats.m_iMasterBuilding);
		if(IsValidEntity(objstats2.m_iExtrabuilding1))
			DestroyBuildingDo(objstats2.m_iExtrabuilding1, true);

		if(IsValidEntity(objstats2.m_iExtrabuilding2))
			DestroyBuildingDo(objstats2.m_iExtrabuilding2, true);
	}
	else if(!DontCheckAgain)
	{
		if(IsValidEntity(objstats.m_iExtrabuilding1))
			DestroyBuildingDo(objstats.m_iExtrabuilding1, true);

		if(IsValidEntity(objstats.m_iExtrabuilding2))
			DestroyBuildingDo(objstats.m_iExtrabuilding2, true);
	}
	Function func = func_NPCDeath[entity];
	if(func && func != INVALID_FUNCTION)
	{
		Call_StartFunction(null, func);
		Call_PushCell(entity);
		Call_Finish();
	}
	//no more hp.
	SetEntProp(objstats.index, Prop_Data, "m_iHealth", 0);
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
	if(Const2_BuildingDestroySpecial(entity))
	{
		return;
	}

	RemoveEntity(entity);
}

bool Const2_BuildingDestroySpecial(int entity)
{
	if(!Dungeon_Mode())
		return false;
	if(GetTeam(entity) != TFTeam_Red)
		return false;
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(!objstats.m_bConstructBuilding)
		return false;

	if(IsValidEntity(objstats.m_iConstructDeathModel))
		return true;

	//already in ignoring, stop
	if(b_ThisEntityIgnored[objstats.index])
		return false;

	b_ThisEntityIgnored[objstats.index] = true;
	objstats.m_iConstructDeathModel = objstats.EquipItemSeperate("models/props_debris/concrete_debris128pile001a.mdl", .model_size = 0.75, .DontParent = true);
	if(IsValidEntity(objstats.index))
		SetEntityRenderMode(objstats.index, RENDER_NONE);
	if(IsValidEntity(objstats.m_iWearable1))
		SetEntityRenderMode(objstats.m_iWearable1, RENDER_NONE);
	ExtinguishTarget(objstats.index);
	objstats.m_flNextDelayTime = FAR_FUTURE;
	//dont destroy. deactivate.
	return true;
}
void Const2_ReviveAllBuildings()
{
	int entity = -1;
	while((entity=FindEntityByClassname(entity, "obj_building")) != -1)
	{
		Const2_ReConstructBuilding(entity);
	}
}
bool Const2_ReConstructBuilding(int entity)
{
	if(!Dungeon_Mode())
		return false;
	if(GetTeam(entity) != TFTeam_Red)
		return false;
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(!objstats.m_bConstructBuilding)
		return false;

	SetEntProp(objstats.index, Prop_Data, "m_iHealth", GetEntProp(objstats.index, Prop_Data, "m_iMaxHealth"));
	SetEntProp(objstats.index, Prop_Data, "m_iRepair", GetEntProp(objstats.index, Prop_Data, "m_iRepairMax"));
	
	if(!IsValidEntity(objstats.m_iConstructDeathModel))
		return false;
	RemoveEntity(objstats.m_iConstructDeathModel);
	b_ThisEntityIgnored[objstats.index] = false;
	if(IsValidEntity(objstats.index))
		SetEntityRenderMode(objstats.index, RENDER_NORMAL);
	if(IsValidEntity(objstats.m_iWearable1))
		SetEntityRenderMode(objstats.m_iWearable1, RENDER_NORMAL);
	objstats.m_flNextDelayTime = 0.0;
	return true;

}
public void ObjBaseThinkPost(int building)
{
	CBaseCombatCharacter(building).SetNextThink(GetGameTime() + 0.1);
}

public void ObjBaseThink(int building)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(building);
	//Fixes some issues when mounted
	if(IsValidEntity(Building_Mounted[building]))
	{
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
	}

	//do not think if you are being carried, unless bomb.
	if(BombIdVintulum() != i_NpcInternalId[building])
	{
		if(BuildingIsBeingCarried(building))
			return;
	}

	ObjectGeneric_ClotThink(objstats);
}


void BuildingUpdateTextHud(int building)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(building);
	
	int entity = EntRefToEntIndex(Building_Mounted[building]);
	if(entity != -1)
	{
		if(IsValidEntity(objstats.m_iWearable2))
			RemoveEntity(objstats.m_iWearable2);

		return;
	}

	//nope.
	if(IsValidEntity(objstats.m_iMasterBuilding))
	{
		if(IsValidEntity(objstats.m_iWearable2))
			RemoveEntity(objstats.m_iWearable2);
		return;
	}
	if(GetTeam(objstats.index) != TFTeam_Red || objstats.m_bConstructBuilding)
	{
		if(IsValidEntity(objstats.m_iWearable2))
			RemoveEntity(objstats.m_iWearable2);
		return;
	}
	char HealthText[128];
	int HealthColour[4];
	int Repair = GetEntProp(objstats.index, Prop_Data, "m_iRepair");

	int Health = GetEntProp(objstats.index, Prop_Data, "m_iHealth");
	int MaxHealth = GetEntProp(objstats.index, Prop_Data, "m_iMaxHealth");
	HealthColour[0] = 255;
	HealthColour[1] = 255;
	HealthColour[3] = 255;
	char NameTextAllowMax[32];
	int Owner = GetEntPropEnt(objstats.index, Prop_Send, "m_hOwnerEntity");
	if(IsValidClient(Owner))
		Format(NameTextAllowMax, sizeof(NameTextAllowMax), "%N",Owner);
	else if(Owner != -1 && Citizen_IsIt(Owner))
		Format(NameTextAllowMax, sizeof(NameTextAllowMax), "Rebel");

	char sColor[32];
	Format(sColor, sizeof(sColor), " %d %d %d %d ", HealthColour[0], HealthColour[1], HealthColour[2], HealthColour[3]);
	int SpacerAdd = 0;
	SpacerAdd -= (strlen(NameTextAllowMax) / 2);
	Format(HealthText, sizeof(HealthText), "%s", NameTextAllowMax);
	if(Resistance_for_building_High[objstats.index] > GetGameTime())
	{
		Format(sColor, sizeof(sColor), " %d %d %d %d ", 125, 125, 255, 255);
		Format(HealthText, sizeof(HealthText), "[[[%s]]]",HealthText);
		SpacerAdd -= 2;
	}
	char ThousandBuffer2[64];
	char ThousandBuffer3[64];
	IntToString(Health, ThousandBuffer2, sizeof(ThousandBuffer2));
	ThousandString(ThousandBuffer2, sizeof(ThousandBuffer2));
	IntToString(MaxHealth, ThousandBuffer3, sizeof(ThousandBuffer3));
	ThousandString(ThousandBuffer3, sizeof(ThousandBuffer3));
	int SpacerThousand;
	SpacerThousand += (strlen(ThousandBuffer2) / 2);
	SpacerThousand += (strlen(ThousandBuffer3) / 2);
	if(Repair <= 0)
	{
		if(Resistance_for_building_High[objstats.index] < GetGameTime())
			Format(sColor, sizeof(sColor), " %d %d %d %d ", 255, 0, 0, 255);
			
		HealthColour[0] = 255;
		HealthColour[1] = 0;
		HealthColour[3] = 255;
		SpacerAdd += SpacerThousand;
		SpacerAdd = RoundToNearest(float(SpacerAdd) * 1.5);
		SpacerAdd += 3;
		for(int AddSpacer; AddSpacer <= SpacerAdd; AddSpacer++)
		{
			Format(HealthText, sizeof(HealthText), "%s ", HealthText);
		}
		Format(HealthText, sizeof(HealthText), "%s\n%s/%s HP", HealthText, ThousandBuffer2, ThousandBuffer3);
	}
	else
	{
		SpacerAdd += SpacerThousand;
		int MaxRepair = GetEntProp(objstats.index, Prop_Data, "m_iRepairMax");
		float RatioLeft = float(Repair) / float(MaxRepair);
		SpacerAdd += 2;
		SpacerAdd = RoundToNearest(float(SpacerAdd) * 1.5);
		RatioLeft *= 100.0;
		for(int AddSpacer; AddSpacer <= SpacerAdd; AddSpacer++)
		{
			Format(HealthText, sizeof(HealthText), " %s", HealthText);
		}
		Format(HealthText, sizeof(HealthText), "%s\n%s/%s HP\n", HealthText, ThousandBuffer2, ThousandBuffer3, RatioLeft);
		for(int AddSpacer; AddSpacer <= SpacerThousand; AddSpacer++)
		{
			Format(HealthText, sizeof(HealthText), "%s ", HealthText);
		}
		Format(HealthText, sizeof(HealthText), "%s(%0.f%% R)", HealthText, RatioLeft);
	}


	if(IsValidEntity(objstats.m_iWearable2))
	{
		DispatchKeyValue(objstats.m_iWearable2,     "color", sColor);
		DispatchKeyValue(objstats.m_iWearable2, "message", HealthText);
	}
	else
	{
		float Offset[3];
		Offset[2] = f3_CustomMinMaxBoundingBox[building][2];
		Offset[2] += 12.0;
	//	if(f3_CustomMinMaxBoundingBoxMinExtra[building][2])
	//		Offset[2] += f3_CustomMinMaxBoundingBoxMinExtra[building][2];

		int TextEntity = SpawnFormattedWorldText(HealthText,Offset, 6, HealthColour, objstats.index);
		DispatchKeyValue(TextEntity, "font", "4");
		objstats.m_iWearable2 = TextEntity;	
		SDKHook(TextEntity, SDKHook_SetTransmit, SetTransmit_TextBuildingDo);
	}
}

void BuildingVialityDisplay(int client, int building ,char[] Buffer, int Buffersize)
{
	int Repair = GetEntProp(building, Prop_Data, "m_iRepair");
	int MaxRepair = GetEntProp(building, Prop_Data, "m_iRepairMax");

	int Health = GetEntProp(building, Prop_Data, "m_iHealth");
	int MaxHealth = GetEntProp(building, Prop_Data, "m_iMaxHealth");
	
	float RepairPercnt = float(Repair) / float(MaxRepair);
	RepairPercnt *= 100.0;
	
	char ThousandBuffer1[128];
	IntToString(Health, ThousandBuffer1, sizeof(ThousandBuffer1));
	ThousandString(ThousandBuffer1, sizeof(ThousandBuffer1));
	
	char ThousandBuffer2[128];
	IntToString(MaxHealth, ThousandBuffer2, sizeof(ThousandBuffer2));
	ThousandString(ThousandBuffer2, sizeof(ThousandBuffer2));
	Format(Buffer, Buffersize, "%T","Viality Building Display", client, ThousandBuffer1, ThousandBuffer2, RepairPercnt);
}


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


public Action SetTransmit_TextBuildingDo(int entity, int client)
{
	if(b_CanSeeBuildingValues_Force[client])
	{
		//if the client forces it...
		return Plugin_Continue;
	}
	if(b_CanSeeBuildingValues[client])
		return Plugin_Continue;
	else
		return Plugin_Handled;
}

public void ObjectGeneric_ClotTakeDamage_Post(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(RaidBossActive && RaidbossIgnoreBuildingsLogic(2)) //They are ignored anyways
		return;

	if((damagetype & DMG_CRUSH))
		return;

	float Damageafter = damage;
	//only red buildings get 90% dmg res, this is done so its more easy to read the numbers on the buildings.
	if(GetTeam(victim) == TFTeam_Red)
		Damageafter *= 0.1;
	int dmg = FloatToInt_DamageValue_ObjBuilding(victim, Damageafter);
	int health = GetEntProp(victim, Prop_Data, "m_iHealth");
	health -= dmg;
	if((Damageafter >= 0.0 || IsInvuln(victim, true) || (weapon > -1 && i_ArsenalBombImplanter[weapon] > 0))) //make sure to still show it if they are invinceable!
	{
#if !defined RTS
		if(inflictor > 0 && inflictor <= MaxClients)
		{
			GiveRageOnDamage(inflictor, Damageafter);
#if defined ZR
			GiveMorphineOnDamage(inflictor, victim, Damageafter, damagetype);
#endif
			Calculate_And_Display_hp(inflictor, victim, Damageafter, false);
		}
		else if(attacker > 0 && attacker <= MaxClients)
		{
			GiveRageOnDamage(attacker, Damageafter);
#if defined ZR
			GiveMorphineOnDamage(attacker, victim, Damageafter, damagetype);
#endif
			Calculate_And_Display_hp(attacker, victim, Damageafter, false);	
		}
		else
		{
			float damageCalc = Damageafter;
			if(health <= 0)
			{
				damageCalc += health;
			}
			Damage_dealt_in_total[attacker] += damageCalc;
			Calculate_And_Display_hp(attacker, victim, Damageafter, false);
		}
		OnPostAttackUniqueWeapon(attacker, victim, weapon, i_HexCustomDamageTypes[victim]);
#endif
		//Do not show this event if they are attacked with DOT. Earls bleedin.
		if(!(i_HexCustomDamageTypes[victim] & ZR_DAMAGE_DO_NOT_APPLY_BURN_OR_BLEED))
		{
			Event event = CreateEvent("npc_hurt");
			if(event) 
			{
				int display = RoundToNearest(Damageafter);
				event.SetInt("entindex", victim);
				event.SetInt("health", health);
				event.SetInt("damageamount", display);
				event.SetBool("crit", (damagetype & DMG_ACID) == DMG_ACID);

				if(attacker > 0 && attacker <= MaxClients)
				{
					event.SetInt("attacker_player", GetClientUserId(attacker));
					event.SetInt("weaponid", 0);
				}
				else 
				{
					event.SetInt("attacker_player", 0);
					event.SetInt("weaponid", 0);
				}

				event.Fire();
			}
		}
		
	}

	StatusEffect_OnTakeDamagePostVictim(victim, attacker, damage, damagetype);
	StatusEffect_OnTakeDamagePostAttacker(victim, attacker, damage, damagetype);

	int Owner = GetEntPropEnt(victim, Prop_Send, "m_hOwnerEntity");
	if(Owner != -1)
	{
		i_BarricadeHasBeenDamaged[Owner] += dmg;
	}
	if(health < 0)
	{
		b_NpcHasDied[victim] = true;
		DestroyBuildingDo(victim);
		return;
	}
	
	ObjectGeneric objstats = view_as<ObjectGeneric>(victim);
	if(objstats.PlayHurtSound())
	{
		float damagePosition2[3];
		damagePosition2 = damagePosition;
		damagePosition2[2] -= 40.0;
		TE_ParticleInt(g_particleImpactMetal, damagePosition2);
		TE_SendToAll();
	}
	
	SetEntProp(victim, Prop_Data, "m_iHealth", health);
	UpdateDoublebuilding(victim);
	
	return;
}