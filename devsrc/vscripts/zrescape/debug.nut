if(!("ZRStoreData" in ROOT))
{
	::ZRStoreData <- []

	function AddDebugItem(strName, iIndex, strModel = null, iPapIndex = null)
	{
		local table = {}
		table.custom_name <- strName
		table.hidden <- "0"
		table.cost <- "200"
		table.classname <- "tf_weapon_pistol"
		table.index <- iIndex.tostring()
		if(strModel != null)
			table.model_weapon_override <- strModel

		if(iPapIndex != null)
		{
			table.pap_1_cost <- "2000"
			table.pap_1_classname <- "tf_weapon_pistol"
			table.pap_1_index <- iPapIndex.tostring()
			if(strModel != null)
				table.pap_1_model_weapon_override <- strModel
		}

		ZRStoreData.append(table)
	}

	AddDebugItem("Grenade", 1083)
	AddDebugItem("Syringe Gun", 204)
	AddDebugItem("Flaregun", 39, null, 351)
}

if(!("ZR_GetGlobalCash" in ROOT))
	function ZR_GetGlobalCash() { return 3000 }

if(!("ZR_RandomizeNPCStore" in ROOT))
	function ZR_RandomizeNPCStore(flags, amount, override) { ClientPrint(null, HUD_PRINTTALK, "ZR_RandomizeNPCStore(" + amount + ")") }

if(!("ZR_GiveClientWeapon" in ROOT))
	function ZR_GiveClientWeapon(client, index, params) { ClientPrint(client, HUD_PRINTTALK, "ZR_GiveClientWeapon(" + index + ")") }

if(!("ZR_LockWeapons" in ROOT))
	function ZR_LockWeapons() { }

if(!("ZR_GetClientCash" in ROOT))
	function ZR_GetClientCash(client) { return 30000 }

if(!("ZR_GetClientWeapon" in ROOT))
	function ZR_GetClientWeapon(client, index) { return 0 }

if(!("ZR_SpentClientCash" in ROOT))
	function ZR_SpentClientCash(client, amount) { ClientPrint(client, HUD_PRINTTALK, "ZR_SpentClientCash(" + amount + ")") }

if(!("ZR_GiveClientAmmo" in ROOT))
	function ZR_GiveClientAmmo(client, type, amount) { ClientPrint(client, HUD_PRINTTALK, "ZR_GiveClientAmmo(" + amount + ")") }

if(!("ZR_HasClientPerk" in ROOT))
	function ZR_HasClientPerk(client, perk) { return false }

if(!("ZR_GiveClientPerk" in ROOT))
	function ZR_GiveClientPerk(client, perk, entity) { ClientPrint(client, HUD_PRINTTALK, "ZR_GiveClientPerk(" + perk + ")") }

if(!("ZR_ShowPackMenu" in ROOT))
	function ZR_ShowPackMenu(client) { ClientPrint(client, HUD_PRINTTALK, "ZR_ShowPackMenu()") }

if(!("ZR_PapModeOnly" in ROOT))
	function ZR_PapModeOnly(mode) { }

if(!("ZR_PerkModeOnly" in ROOT))
	function ZR_PerkModeOnly(mode) { }

if(!("ZR_AddGlobalCash" in ROOT))
	function ZR_AddGlobalCash(amount, extra) { ClientPrint(null, HUD_PRINTTALK, "ZR_AddGlobalCash(" + amount + ")") }

if(!("ZR_CreateNPC" in ROOT))
	function ZR_CreateNPC(name, pos, ang, params) { ClientPrint(null, HUD_PRINTTALK, "ZR_CreateNPC(" + name + ")") }