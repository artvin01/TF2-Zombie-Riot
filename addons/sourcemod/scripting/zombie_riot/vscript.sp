#include <vscript>

#pragma semicolon 1
#pragma newdecls required

#define VSCRIPT_LIBRARY	"vscript"

static bool MapLockedWeapons;
static bool Loaded;
static ScriptCall ScriptFireScriptHook;
static ScriptCall ScriptAddStoreTable;

// Wrapper for ScriptHandle/FireScriptHook for when the ext is loaded/not
methodmap VScriptEvent < ScriptHandle
{
	public VScriptEvent(const char[] name)
	{
		if(!Loaded)
			return null;
		
		ScriptHandle handle = VScript_CreateTable();
		if(handle)
			handle.SetString("__event", name);
		
		return view_as<VScriptEvent>(handle);
	}
	public bool SetEntity(const char[] key, int value)
	{
		return view_as<ScriptHandle>(this).SetHScript(key, VScript_EntityToHScript(value, true));
	}
	public bool Fire()
	{
		if(this == null || !ScriptFireScriptHook)
			return false;
		
		char buffer[64];
		view_as<ScriptHandle>(this).GetString("__event", buffer, sizeof(buffer));
		ScriptStatus status = ScriptFireScriptHook.Execute(buffer, view_as<ScriptHandle>(this));
		CloseHandle(this);
		return status == ScriptStatus_Done;
	}
}

void VScript_PluginStart()
{
	Loaded = LibraryExists(VSCRIPT_LIBRARY);
	if(Loaded)
	{
		SetupVScript();
		if(VScript_IsVMInitialized())
			VScript_OnVMInitialized();
	}
}

void VScript_MapEnd()
{
	MapLockedWeapons = false;
	PapModeDo = PAP_MODE_DEFAULT;
	PerkModeDo = PERK_MODE_DEFAULT;
}

void VScript_LibraryAdded(const char[] name)
{
	if(!Loaded && StrEqual(name, VSCRIPT_LIBRARY))
	{
		Loaded = true;
		SetupVScript();
		if(VScript_IsVMInitialized())
			VScript_OnVMInitialized();
	}
}

void VScript_LibraryRemoved(const char[] name)
{
	if(Loaded && StrEqual(name, VSCRIPT_LIBRARY))
		Loaded = false;
}

static ScriptHandle ExportKeyValues(KeyValues kv)
{
	if(kv == null)
		return null;
	
	ScriptHandle table = VScript_CreateTable();
	if(kv.GotoFirstSubKey(false))
		KvToTable(table, kv);
	
	return table;
}

static void KvToTable(ScriptHandle table, KeyValues kv)
{
	char key[PLATFORM_MAX_PATH], value[PLATFORM_MAX_PATH];
	do
	{
		if(kv.GetSectionName(key, sizeof(key)))
		{
			if(kv.GotoFirstSubKey(false))
			{
				ScriptHandle subtable = VScript_CreateTable();
				KvToTable(subtable, kv);
				table.SetHScript(key, subtable);
				delete subtable;
			}
			else
			{
				int size = strlen(key);
				for(int i; i < size; i++)
				{
					key[i] = CharToLower(key[i]);
				}

				kv.GetString(NULL_STRING, value, sizeof(value));
				table.SetString(key, value);
			}
		}
	}
	while(kv.GotoNextKey(false));

	kv.GoBack();
}

public void VScript_OnVMInitialized()
{
	VScript_Run("function _ZRAddToStoreTable(table) {\n" ...
		"ZRStoreData.append(table)\n" ...
	"}");
}

static void SetupVScript()
{
	ScriptFireScriptHook = new ScriptCall("FireScriptHook", ScriptField_Bool, ScriptField_String, ScriptField_HScript);
	ScriptAddStoreTable = new ScriptCall("_ZRAddToStoreTable", ScriptField_Void, ScriptField_HScript);
	
	VScript_RegisterFunction("ZR_GetClientCash", VGetCurrentCash, "(client)", ScriptField_Int, ScriptField_HScript);
	VScript_RegisterFunction("ZR_SpentClientCash", VSpentClientCash, "(client, amount)", ScriptField_Void, ScriptField_HScript, ScriptField_Int);
	VScript_RegisterFunction("ZR_GetClientWeapon", VGetClientWeapon, "(client, index)", ScriptField_Int, ScriptField_HScript, ScriptField_Int);
	VScript_RegisterFunction("ZR_GiveClientWeapon", VGiveClientWeapon, "(client, index, params)", ScriptField_Void, ScriptField_HScript, ScriptField_Int, ScriptField_HScript);
	VScript_RegisterFunction("ZR_LockWeapons", VLockWeapons, "()", ScriptField_Void);
	VScript_RegisterFunction("ZR_RandomizeNPCStore", VRandomizeNPCStore, "(flags, amount, override)", ScriptField_Void, ScriptField_Int, ScriptField_Int, ScriptField_Float);
	VScript_RegisterFunction("ZR_GetGlobalCash", VGetGlobalCash, "()", ScriptField_Int);
	VScript_RegisterFunction("ZR_GiveClientAmmo", VGiveClientAmmo, "(client, index, amount)", ScriptField_Void, ScriptField_HScript, ScriptField_Int, ScriptField_Int);
	VScript_RegisterFunction("ZR_PapModeOnly", VPapModeMapOnly, "(mode)", ScriptField_Void, ScriptField_Int);
	VScript_RegisterFunction("ZR_PerkModeOnly", VPerkModeOnly, "(mode)", ScriptField_Void, ScriptField_Int);
	VScript_RegisterFunction("ZR_HasClientPerk", VHasClientPerk, "(client, perk)", ScriptField_Bool, ScriptField_HScript, ScriptField_Int);
	VScript_RegisterFunction("ZR_GiveClientPerk", VGiveClientPerk, "(client, perk, entity)", ScriptField_Void, ScriptField_HScript, ScriptField_Int, ScriptField_HScript);
	VScript_RegisterFunction("ZR_ShowPackMenu", VShowPackMenu, "(client)", ScriptField_Void, ScriptField_HScript);
	VScript_RegisterFunction("ZR_AddGlobalCash", VAddGlobalCash, "(amount, extra)", ScriptField_Void, ScriptField_Int, ScriptField_Bool);
	VScript_RegisterFunction("ZR_CreateNPC", VCreateNPC, "(name, pos, ang, params)", ScriptField_HScript, ScriptField_String, ScriptField_Vector, ScriptField_Vector, ScriptField_HScript);
}

void VScript_SetupStoreTable()
{
	if(!Loaded)
		return;
	
	VScript_Run("::ZRStoreData <- []");
}

void VScript_AddStoreTable(KeyValues kv, const char[] name)
{
	if(!Loaded)
		return;
	
	ScriptHandle table = ExportKeyValues(kv);
	if(table)
	{
		if(!table.HasKey("custom_name"))
			table.SetString("custom_name", name);
		
		ScriptAddStoreTable.Execute(table);
		delete table;
	}
}

static void VGetCurrentCash(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			context.SetReturnInt(CurrentCash - CashSpent[client]);
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VSpentClientCash(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			CashSpent[client] += context.GetArgInt(1);
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VGetClientWeapon(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			context.SetReturnInt(Store_HasIndexItem(client, context.GetArgInt(1)));
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VGiveClientWeapon(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			int index = context.GetArgInt(1);
			int owned = 1;
			bool equipped = true;
			int sell = 0;

			ScriptHandle table = context.GetArgHScript(2);
			if(table)
			{
				if(table.HasKey("owned"))
					owned = table.GetInt("owned");
				
				if(table.HasKey("equip"))
					equipped = table.GetBool("equip");
				
				if(table.HasKey("sell"))
					sell = table.GetInt("sell");
			}

			Store_GiveItemIndex(client, index, owned, equipped, sell);
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VLockWeapons(ScriptContext context)
{
	MapLockedWeapons = true;
}

bool VScript_LockedWeapons()
{
	return MapLockedWeapons;
}

static void VRandomizeNPCStore(ScriptContext context)
{
	Store_RandomizeNPCStore(context.GetArgInt(0), context.GetArgInt(1), context.GetArgFloat(2));
}

static void VGetGlobalCash(ScriptContext context)
{
	context.SetReturnInt(CurrentCash);
}

static void VGiveClientAmmo(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			int index = context.GetArgInt(1);
			int amount = context.GetArgInt(2);
			
			int ammo = GetAmmo(client, index) + (AmmoData[index][1] * amount);
			SetAmmo(client, index, ammo);
			CurrentAmmo[client][index] = ammo;
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

//must be set everytime the map reloads
static void VPapModeMapOnly(ScriptContext context)
{
	//1 is buildings only
	//0 is default via menu
	int ModeApply = context.GetArgInt(0);
	PapModeDo = ModeApply;
}

//must be set everytime the map reloads
static void VPerkModeOnly(ScriptContext context)
{
	//1 is no perk limit
	//0 is normal perk logic
	int ModeApply = context.GetArgInt(0);
	PerkModeDo = ModeApply;
}

static void VGiveClientPerk(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			int index = context.GetArgInt(1);
			int entity = -1;
			
			ScriptHandle hentity = context.GetArgHScript(2);
			if(hentity)
				entity = VScript_HScriptToEntity(hentity);
			
			Do_Perk_Machine_Logic(client, client, entity, (1 << (index - 1)), index);
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VHasClientPerk(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			int index = context.GetArgInt(1);
			context.SetReturnBool(view_as<bool>(i_CurrentEquippedPerk[client] & (1 << (index - 1))));
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VShowPackMenu(ScriptContext context)
{
	ScriptHandle hclient = context.GetArgHScript(0);
	if(hclient)
	{
		int client = VScript_HScriptToEntity(hclient);
		if(client > 0 && client <= MaxClients)
		{
			int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if(weapon != -1)
				Store_PackMenu(client, StoreWeapon[weapon], -1, client);
			
			return;
		}
	}

	context.RaiseException("Invalid player entity");
}

static void VAddGlobalCash(ScriptContext context)
{
	int amount = context.GetArgInt(0);
	CurrentCash += amount;

	if(context.GetArgBool(1))
		GlobalExtraCash += amount;
}

static void VCreateNPC(ScriptContext context)
{
	char name[64], buffer[512];
	float pos[3], ang[3];
	int client;
	int team = 3;
	bool nosetup;

	context.GetArgString(0, name, sizeof(name));
	context.GetArgVector(1, pos);
	context.GetArgVector(2, ang);
	ScriptHandle table = context.GetArgHScript(3);

	if(table.HasKey("client"))
	{
		ScriptHandle hclient = table.GetHScript("client");
		if(hclient)
		{
			client = VScript_HScriptToEntity(hclient);
			delete hclient;
		}
	}

	if(table.HasKey("team_npc"))
		team = table.GetInt("team_npc");

	if(table.HasKey("ignoresetup"))
		nosetup = table.GetBool("ignoresetup");

	if(table.HasKey("data"))
		table.GetString("data", buffer, sizeof(buffer));

	int entity = NPC_CreateByName(name, client, pos, ang, team, buffer, true);
	if(entity != -1)
	{
		int boss = table.HasKey("is_boss") ? table.GetInt("is_boss") : 0;
		int healthscaling = table.HasKey("is_health_scaling") ? table.GetInt("is_health_scaling") : 0;
		int outline;
		
		if(table.HasKey("is_outlined"))
		{
			outline = table.GetInt("is_outlined");
			switch(outline)
			{
				case 1:
					b_thisNpcHasAnOutline[entity] = true;
				
				case 2:
					b_NoHealthbar[entity] = 1;
			}
		}
		
		if(table.HasKey("is_immune_to_nuke") && table.GetBool("is_immune_to_nuke"))
			b_ThisNpcIsImmuneToNuke[entity] = true;

		if(table.HasKey("health"))
		{
			int health = table.GetInt("health");

			if(boss >= 1 || healthscaling >= 1)
				health = RoundToNearest(health * MultiGlobalHighHealthBoss);

			SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
			SetEntProp(entity, Prop_Data, "m_iHealth", health);
		}

		if(table.HasKey("custom_name"))
		{
			table.GetString("custom_name", c_NpcName[entity], sizeof(c_NpcName[]));
			b_NameNoTranslation[entity] = !TranslationPhraseExists(c_NpcName[entity]);
		}

		CClotBody npc = view_as<CClotBody>(entity);
		
		if(table.HasKey("is_static"))
		{
			npc.m_bStaticNPC = table.GetBool("is_static");
			if(npc.m_bStaticNPC && team != TFTeam_Red)
				AddNpcToAliveList(entity, 1);
		}

		npc.m_bThisNpcIsABoss = boss > 0;

		if(table.HasKey("cash"))
			npc.m_fCreditsOnKill = table.GetFloat("cash");

		if(table.HasKey("extra_melee_res"))
			fl_Extra_MeleeArmor[entity] *= table.GetFloat("extra_melee_res");

		if(table.HasKey("extra_ranged_res"))
			fl_Extra_RangedArmor[entity] *= table.GetFloat("extra_ranged_res");

		if(table.HasKey("extra_speed"))
			fl_Extra_Speed[entity] *= table.GetFloat("extra_speed");

		if(table.HasKey("extra_damage"))
			fl_Extra_Damage[entity] *= table.GetFloat("extra_damage");

		if(table.HasKey("extra_thinkspeed"))
			f_AttackSpeedNpcIncrease[entity] *= table.GetFloat("extra_thinkspeed");

		if(table.HasKey("extra_size"))
		{
			float scale = GetEntPropFloat(entity, Prop_Send, "m_flModelScale");
			SetEntPropFloat(entity, Prop_Send, "m_flModelScale", scale * table.GetFloat("extra_size"));
		}

		if(boss || outline)
		{
			GiveNpcOutLineLastOrBoss(entity, true);
		}
		else
		{
			GiveNpcOutLineLastOrBoss(entity, false);
		}
		
		if(!nosetup)
			NPC_PostSetup(entity);

		context.SetReturnHScript(VScript_EntityToHScript(entity, true));
	}
	else
	{
		context.SetReturnNull();
	}
}