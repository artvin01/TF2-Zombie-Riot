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
	PerkModeDo = PERK_MODE_ALL_ALLOW;
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

public void VScript_OnVMInitialized()
{
	VScript_Run("function _ZRAddToStoreTable(table) {\n" ...
		"::ZRStoreData.append(table)\n" ...
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
	VScript_RegisterFunction("ZR_PapModeOnly", VPapModeMapOnly, "(mode)", ScriptField_Int);
	VScript_RegisterFunction("ZR_PerkModeOnly", VPerkModeOnly, "(mode)", ScriptField_Int);
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

static ScriptHandle ExportKeyValues(KeyValues kv)
{
	if(kv == null)
		return null;
	
	ScriptHandle table = VScript_CreateTable();
	kv.Rewind();
	kv.GotoFirstSubKey(false);
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
				kv.GetString(key, value, sizeof(value));
				table.SetString(key, value);
			}
		}
	}
	while(kv.GotoNextKey(false));

	kv.GoBack();
}


//must be set everytime the map reloads
static void VPapModeMapOnly(ScriptContext context)
{
	//1 is buildings only
	//0 is default via menu
	int ModeApply = context.GetArgInt(1);
	PapModeDo = ModeApply;
}
//must be set everytime the map reloads
static void VPerkModeOnly(ScriptContext context)
{
	//1 is no perk limit
	//0 is normal perk logic
	int ModeApply = context.GetArgInt(1);
	PerkModeDo = ModeApply;
}