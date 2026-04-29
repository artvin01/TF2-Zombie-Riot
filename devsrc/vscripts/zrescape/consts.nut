foreach(k, v in NetProps.getclass())
{
	if(k != "IsValid")
	{
		ROOT[k] <- NetProps[k].bindenv(NetProps)
	}
}

FindByClassname <- Entities.FindByClassname.bindenv(Entities)
FindByClassnameNearest <- Entities.FindByClassnameNearest.bindenv(Entities)
FindByClassnameWithin <- Entities.FindByClassnameWithin.bindenv(Entities)
FindByName <- Entities.FindByName.bindenv(Entities)
FindInSphere <- Entities.FindInSphere.bindenv(Entities)

::MaxPlayers <- MaxClients().tointeger()

const g_iLootboxCost = 1000

const ZR_STORE_RESET = 2
const ZR_STORE_DEFAULT_SALE = 4
const ZR_STORE_WAVEPASSED = 8

PerkData <- [
	["No Perk", 0],	// 0
	["Regene Berry", 100],
	["Obsidian Oaf", 500],	// 2
	["Morning Coffee", 400],
	["Hasty Hops", 600],	// 4
	["Marksman Beer", 300],
	["Teslar Mule", 800],	// 6
	["Stockpile Stout", 800],
	["Energy Drink", 400],	// 8

	["Lover's Wine", 400],
	["Marathon Shake", 400],	// 10
	["Sealed Boba", 5000],
	["Bloody Ale", 600],	// 12
	["Who Float", 400],

	["Morning Coffee", 400],	// 14
	["Hasty Hops", 600],
	["Marksman Beer", 300],	// 16
	["Energy Drink", 400]
]
