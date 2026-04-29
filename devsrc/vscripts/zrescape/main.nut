g_iFrameCount <- 0
g_iBarricadeTotalSpent <- 0
g_iBarricadeBaseSpent <- 0
g_aPlayerList <- []
g_flSoundCooldown <- 0.0
g_bSeeding <- false
g_iBoxStreak <- 0

g_aPlayerList.clear()
for(local i = 1, hPlayer; i <= MaxPlayers; i++)
{
	if(hPlayer = PlayerInstanceFromIndex(i))
		EntFireByHandle(hPlayer, "CallScriptFunction", "ZREscapePlayerStart", 0.0, null, null)
}

::ZREscapePlayerStart <- function()
{
	if(PlayerInstanceFromIndex(self.entindex()) == null)
		return

	self.ValidateScriptScope()
	local m = self.GetScriptScope()
	m.iLastButtons <- 0
	m.flAmmoCooldown <- 0.0

	g_aPlayerList.append(self)
}

function ResetStats()
{
	g_iBarricadeTotalSpent = 0
	g_iBarricadeBaseSpent = 0
	g_iFrameCount = 0
	g_bSeeding = true

	ShuffleLootbox(null)
}

function ShuffleLootbox(ignore)
{
	g_iBoxStreak = 0

	local aRandomPool = []

	for(local hEntity = null; hEntity = FindByName(hEntity, "lootbo*"); )
	{
		hEntity.AcceptInput("DisableCollision", "", null, null)
		hEntity.AcceptInput("Disable", "", null, null)

		if(hEntity != ignore)
			aRandomPool.append(hEntity)
	}

	if(aRandomPool.len() == 0)
		return ignore

	local hChoosen = aRandomPool[rand() % aRandomPool.len()]
	hChoosen.AcceptInput("Enable", "", null, null)
	hChoosen.AcceptInput("EnableCollision", "", null, null)
	hChoosen.AcceptInput("FireUser3", "", null, null)
	return hChoosen
}

::ZREscapeStarterItems <- function()
{
	for(local a = 0; a < ZRStoreData.len(); a++)
	{
		local tTable = ZRStoreData[a]

		if("fools26starter" in tTable)
		{
			if(ZR_GetClientWeapon(self, a) < 1)
			{
				ZR_GiveClientWeapon(self, a, {})
			}
		}
	}
}

function MainThink()
{
	local iFrameIndex = (g_iFrameCount % 10)
	local bShowText = iFrameIndex == 6

	if(g_bSeeding)
		rand()

	foreach(hPlayer in g_aPlayerList)
	{
		local m = hPlayer.GetScriptScope()

		local bAlive = GetPropInt(hPlayer, "m_lifeState") == 0
		local iButtons = GetPropInt(hPlayer, "m_nButtons")
		local iNewButtons = (m.iLastButtons ^ iButtons) & iButtons
		m.iLastButtons = iButtons

		if(!bAlive || GetPropInt(hPlayer, "m_iMaxHealth") < 10)
		{

		}
		else if(iNewButtons & (IN_RELOAD|IN_USE))
		{
			// Attempt to interact
			local tTrace = TraceToBlock(hPlayer, 150.0)
			if(tTrace.hit)
			{
				local hEntity = tTrace.enthit
				if(hEntity != null)
				{
					local strName = hEntity.GetName()
					if(startswith(strName, "barricade"))
					{
						local iCost = IntFromName(strName, 10)
						if(iCost < 1)
							iCost = 750

						UnlockBarricade(hPlayer, hEntity, iCost, false)
					}
					else if(startswith(strName, "exitdoor"))
					{
						local iCost = IntFromName(strName, 9)
						if(iCost < 1)
							iCost = 50000

						UnlockBarricade(hPlayer, hEntity, iCost, true)
					}
					else if(startswith(strName, "lootbox"))
					{
						SpinLootbox(hPlayer, hEntity)
					}
					else if(startswith(strName, "wallweapon"))
					{
						local iAmount = IntFromName(strName, 11)
						if(iAmount < 1)
							iAmount = 1

						hEntity.Kill()
						ZR_RandomizeNPCStore(ZR_STORE_DEFAULT_SALE, iAmount, -1.0)
					}
					else if(strName == "_lootweapon")
					{
						GrabLootWeapon(hPlayer, hEntity)
					}
					else if(startswith(strName, "perksoda_"))
					{
						local iType = IntFromName(strName, 9)
						UsePerkMachine(hPlayer, hEntity, iType)
					}
					else if(startswith(strName, "packapunch"))
					{
						ZR_ShowPackMenu(hPlayer)
					}
					else if(startswith(strName, "ammobox"))
					{
						UseAmmoBox(hPlayer)
					}
				}
			}
		}

		if(iFrameIndex == (hPlayer.entindex() % 10))
		{
			local tTrace = TraceToBlock(hPlayer, 150.0)
			if(tTrace.hit)
			{
				local hEntity = tTrace.enthit
				if(hEntity != null)
				{
					local strName = hEntity.GetName()
					if(startswith(strName, "barricade"))
					{
						local iCost = IntFromName(strName, 10)
						if(iCost < 1)
							iCost = 750

						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to remove the barricade for " + GetBarricadeCost(iCost, false) + " cash")
					}
					else if(startswith(strName, "lootbox"))
					{
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to spin the lootbox for " + g_iLootboxCost + " cash")
					}
					else if(startswith(strName, "wallweapon"))
					{
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to unlock a random weapon")
					}
					else if(strName == "_lootweapon")
					{
						local n = hEntity.GetScriptScope()
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to grab " + n.strName)
					}
					else if(startswith(strName, "exitdoor"))
					{
						local iCost = IntFromName(strName, 9)
						if(iCost < 1)
							iCost = 50000

						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to remove the barricade: " + GetTotalCash() + " / " + GetBarricadeCost(iCost, true) + " group cash")
					}
					else if(startswith(strName, "perksoda_"))
					{
						local iType = IntFromName(strName, 9)
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to drink " + PerkData[iType][0] + " for " + PerkData[iType][1] + " cash")
					}
					else if(strName == "packapunch")
					{
						ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to use the pack-a-punch")
					}
					else if(startswith(strName, "nopower"))
					{
						ClientPrint(hPlayer, HUD_PRINTCENTER, "No Power!")
					}
					else if(startswith(strName, "ammobox"))
					{
						if(m.flAmmoCooldown > Time())
						{
							ClientPrint(hPlayer, HUD_PRINTCENTER, "Ammo Cooldown: " + ceil(m.flAmmoCooldown - Time()) + "s")
						}
						else
						{
							ClientPrint(hPlayer, HUD_PRINTCENTER, "Press [R/Use] to use collect some ammo")
						}
					}
				}
			}
		}
	}

	g_iFrameCount++
	return -1
}

function IntFromName(strName, iPos)
{
	local cost = strName.slice(iPos)
	if(cost == null)
		cost = "0"

	cost = cost.tointeger()
	return cost
}

function GetTotalCash()
{
	local iCash = 0
	foreach(hPlayer in g_aPlayerList)
	{
		if(hPlayer.GetTeam() == TF_TEAM_RED)
		{
			iCash += ZR_GetClientCash(hPlayer)
		}
	}

	return iCash
}

function GetPlayingPlayers()
{
	local iPlayers = 0
	foreach(hPlayer in g_aPlayerList)
	{
		if(hPlayer.GetTeam() == TF_TEAM_RED)
			iPlayers++
	}

	return iPlayers
}

function GetBarricadeCost(iBaseCost, bShared)
{
	local iPlayers = GetPlayingPlayers()
	if(!bShared && iPlayers < 4)
		iPlayers = 4

	if(!bShared && iPlayers > 8)
		iPlayers = 8

	local iMinCost = bShared ? (iBaseCost / 4) : iBaseCost
	local iCost = iPlayers * (iBaseCost / 4)
	local iTax = (iPlayers * (g_iBarricadeBaseSpent / 4)) - g_iBarricadeTotalSpent

	iCost += iTax
	if(iCost < iMinCost)
		iCost = iMinCost

	return iCost
}

function UnlockBarricade(hPlayer, hBarricade, iBaseCost, bShared)
{
	local iCost = GetBarricadeCost(iBaseCost, bShared)

	if(bShared)
	{
		if(GetTotalCash() >= iCost)
		{
			hBarricade.AcceptInput("FireUser1", "", null, null)
			hBarricade.AcceptInput("Break", "", null, null)
			EntFireByHandle(hBarricade, "Kill", "", 0.0, null, null)
			EntFire("tf_point_nav_interface", "RecomputeBlockers", "", 0.1)
			EmitSoundEx({
				sound_name = "mvm/mvm_money_pickup.wav"
			})
			ZR_AddGlobalCash((-(iBaseCost / 4.0)), false)
		}
	}
	else if(ZR_GetClientCash(hPlayer) >= iCost)
	{
		hBarricade.AcceptInput("FireUser1", "", null, null)
		hBarricade.AcceptInput("Break", "", null, null)
		EntFireByHandle(hBarricade, "Kill", "", 0.0, null, null)
		EntFire("tf_point_nav_interface", "RecomputeBlockers", "", 0.1)
		EmitSoundToClient("mvm/mvm_money_pickup.wav", hPlayer)
		g_iBarricadeBaseSpent += iBaseCost
		g_iBarricadeTotalSpent += iCost
		ZR_SpentClientCash(hPlayer, iCost)
	}
}

function UsePerkMachine(hPlayer, hEntity, iType)
{
	if(ZR_HasClientPerk(hPlayer, iType))
	{
		ClientPrint(hPlayer, HUD_PRINTTALK, "You already own this perk")
		return
	}

	if(ZR_GetClientCash(hPlayer) >= PerkData[iType][1])
	{
		ZR_GiveClientPerk(hPlayer, iType, hEntity)
		if(ZR_HasClientPerk(hPlayer, iType))
			ZR_SpentClientCash(hPlayer, PerkData[iType][1])
	}
}

function SpinLootbox(hPlayer, hLootbox)
{
	g_bSeeding = false

	local m = hLootbox.GetScriptScope()
	if(m == null)
	{
		hLootbox.ValidateScriptScope()
		m = hLootbox.GetScriptScope()

		m.hActiveItem <- null
		m.flSpinTime <- 0.0
		m.iSpinCount <- 0
		m.hItemOwner <- null
		m.LootboxThinking <- LootboxThinking.bindenv(m)
		AddThinkToEnt(hLootbox, "LootboxThinking")
	}

	if(m.hActiveItem != null && m.hActiveItem.IsValid())
		return

	if(ZR_GetClientCash(hPlayer) >= g_iLootboxCost)
	{
		ZR_SpentClientCash(hPlayer, g_iLootboxCost)
		EmitSoundToClient("mvm/mvm_money_pickup.wav", hPlayer)

		hLootbox.AcceptInput("FireUser1", "", null, null)

		local hEntity = SpawnEntityFromTable("prop_dynamic_override",
		{
			origin = hLootbox.GetOrigin() + Vector(0, 0, 25)
			angles = hLootbox.GetAbsAngles() + QAngle(0, 90, 0)
			model = GetModelOfWeaponIndex(199)
			solid = 3
		})

		hEntity.SetCollisionGroup(2)
		hEntity.AcceptInput("EnableCollision", "", null, null)

		m.flSpinTime = 0.0
		m.iSpinCount = 0
		m.hItemOwner = hPlayer
		g_iBoxStreak++

		hEntity.ValidateScriptScope()
		m.hActiveItem = hEntity
		EntFireByHandle(hEntity, "Kill", "", 30.0, null, null)
	}
}

function LootboxThinking()
{
	local m = self.GetScriptScope()

	if(m.hActiveItem == null || !m.hActiveItem.IsValid())
		return -1.0

	local vecOrigin = m.hActiveItem.GetOrigin()

	if(m.iSpinCount < 20)
	{
		if(m.flSpinTime < Time())
		{
			m.iSpinCount++
			m.flSpinTime = Time() + (1.5 / (21 - m.iSpinCount).tofloat())

			local n = m.hActiveItem.GetScriptScope()
			local data = GetRandomZRWeapon()
			n.iIndex <- data[0]
			if(n.iIndex == -1)
			{
				m.hActiveItem.SetModelSimple("models/player/items/engineer/teddy_roosebelt.mdl")
			}
			else
			{
				n.iLevel <- data[1]
				local tTable = data[2]

				local strPrefix = n.iLevel > 0 ? ("pap_" + n.iLevel + "_") : ""
				n.strName <- ((strPrefix + "custom_name") in tTable) ? tTable[strPrefix + "custom_name"] : (tTable.custom_name + " V" + (n.iLevel + 1))

				local iWeaponIndex = tTable[strPrefix + "index"].tointeger()

				if((strPrefix + "model_weapon_override") in tTable)
				{
					m.hActiveItem.SetModelSimple(tTable[strPrefix + "model_weapon_override"])
				}
				else
				{
					m.hActiveItem.SetModelSimple(GetModelOfWeaponIndex(iWeaponIndex))
				}

				if((strPrefix + "weapon_bodygroup") in tTable)
				{
					SetPropInt(m.hActiveItem, "m_nBody", tTable[strPrefix + "weapon_bodygroup"].tointeger())
				}
			}

			if(m.iSpinCount == 20)
			{
				if(n.iIndex != -1)
				{
					m.flSpinTime = Time() + 9.0
					n.hItemOwner <- m.hItemOwner
					m.hActiveItem.KeyValueFromString("targetname", "_lootweapon")

					self.AcceptInput("FireUser2", "", null, null)
				}
				else
				{
					m.flSpinTime = Time() + 2.5
					EmitSoundEx({
						sound_name = "ambient/halloween/thunder_03.wav"
					})

					self.AcceptInput("FireUser4", "", null, null)
				}
			}

			vecOrigin += Vector(0.0, 0.0, 0.8)
		}

		vecOrigin += Vector(0.0, 0.0, 0.8)
		m.hActiveItem.SetAbsOrigin(vecOrigin)
	}
	else if(m.iSpinCount == 20)
	{
		if(m.flSpinTime < Time())
		{
			local n = m.hActiveItem.GetScriptScope()
			if("hItemOwner" in n)
			{
				m.iSpinCount++
				m.flSpinTime = Time() + 6.0
				SetPropInt(m.hActiveItem, "m_fEffects", 0x100)
				n.hItemOwner = null
			}
			else
			{
				m.hActiveItem.AcceptInput("Kill", "", null, null)
				ShuffleLootbox(self)
			}
		}
	}
	else if(m.iSpinCount > 20)
	{
		if(m.flSpinTime < Time())
		{
			m.hActiveItem.AcceptInput("Kill", "", null, null)
		}
	}

	local iPlayers = GetPlayingPlayers()
	if(iPlayers > 8)
		return 0.8 / iPlayers.tofloat()

	return 0.1
}

function GetRandomZRWeapon()
{
	local iCurrentCash = 3000 + (ZR_GetGlobalCash() / 3)

	local aRandomPool = []

	for(local a = 0; a < ZRStoreData.len(); a++)
	{
		local tTable = ZRStoreData[a]

		if(("classname" in tTable)
			&& ("index" in tTable)
			&& ("cost" in tTable)
			&& ("custom_name" in tTable)
			&& (!("hidden" in tTable) || tTable.hidden.tointeger() == 0)
			&& tTable.cost.tointeger() > 0
			&& tTable.cost.tointeger() < iCurrentCash
		)
		{
			if(!("ammo" in tTable))
			{
				if((rand() % 3) != 0)
					continue
			}

			if(("is_a_wand" in tTable) && tTable.is_a_wand.tointeger() != 0)
			{
				if((rand() % 3) != 0)
					continue
			}

			local iTotalCost = tTable.cost.tointeger()

			for(local b = 1; ; b++)
			{
				local strPrefix = "pap_" + b + "_"
				if(!(((strPrefix + "classname") in tTable)
					&& (strPrefix + "index") in tTable
					&& (strPrefix + "cost") in tTable
					&& tTable[strPrefix + "cost"].tointeger() > 0
				))
				{
					break
				}

				aRandomPool.append([a, b - 1, tTable])

				iTotalCost += tTable[strPrefix + "cost"].tointeger()
				if(iTotalCost > iCurrentCash)
					break
			}
		}
	}

	for(local a = 0; a < g_iBoxStreak; a++)
	{
		aRandomPool.append([-1, 0, null])
	}

	if(aRandomPool.len() == 0)
		return [-1, 0, null]

	return aRandomPool[rand() % aRandomPool.len()]
}

function GrabLootWeapon(hPlayer, hWeapon)
{
	local m = hWeapon.GetScriptScope()
	if(m.hItemOwner != null && m.hItemOwner != hPlayer)
		return

	local bAmmo = false
	local tTable = ZRStoreData[m.iIndex]
	local strPrefix = m.iLevel > 0 ? ("pap_" + m.iLevel + "_") : ""
	if((strPrefix + "ammo") in tTable)
	{
		bAmmo = true
		local iAmount = DoubleAmmo(hPlayer) ? 24 : 18
		ZR_GiveClientAmmo(hPlayer, tTable[strPrefix + "ammo"].tointeger(), iAmount)
	}

	local iExisting = ZR_GetClientWeapon(hPlayer, m.iIndex)
	if(iExisting > 1 || (iExisting > 0 && m.iLevel == 0))
	{
		if(bAmmo)
		{
			hWeapon.Kill()
			ClientPrint(hPlayer, HUD_PRINTTALK, "You got ammo instead for this weapon")
		}
		else
		{
			ClientPrint(hPlayer, HUD_PRINTTALK, "You already own this weapon")
		}
		return
	}

	ZR_GiveClientWeapon(hPlayer, m.iIndex, {
		owned = m.iLevel + 1
		sell = 50
	})

	hWeapon.Kill()
}

function UseAmmoBox(hPlayer)
{
	local m = hPlayer.GetScriptScope()
	if(m.flAmmoCooldown < Time())
	{
		m.flAmmoCooldown = Time() + 100.0
		local iAmount = DoubleAmmo(hPlayer) ? 12 : 9

		for(local i = 7; i < 24; i++)
		{
			ZR_GiveClientAmmo(hPlayer, i, iAmount)
		}
	}
}

function DoubleAmmo(hPlayer)
{
	return ZR_HasClientPerk(hPlayer, 7)
}
