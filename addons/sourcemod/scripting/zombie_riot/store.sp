static int HighestTier;

#define SELL_AMOUNT 0.7

static const int SlotLimits[] =
{
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1
};

enum struct ItemInfo
{
	int Cost;
	char Desc[256];
	
	bool HasNoClip;
	bool SemiAuto;
	
	bool SemiAuto_SingularReload;
	
	bool NoHeadshot;
	
	float SemiAutoStats_FireRate;
	int SemiAutoStats_MaxAmmo;
	float SemiAutoStats_ReloadTime;
	
	bool NoLagComp;
	bool OnlyLagCompCollision;
	bool OnlyLagCompAwayEnemy;
	bool ExtendBoundingBox;
	bool DontMoveBuildingComp;
	bool DontMoveAlliedNpcs;
	bool BlockLagCompInternal;
	
	char Classname[36];
	int Index;
	int Attrib[16];
	float Value[16];
	int Attribs;
	int Ammo;
	
	bool CannotBeSavedByCookies;
	
	int Reload_ModeForce;
	
	Function FuncAttack;
	Function FuncAttack2;
	Function FuncAttack3;
	Function FuncReload4;
	Function FuncOnBuy;
	
	int Attack3AbilitySlot;
	
	int SpecialAdditionViaNonAttribute; //better then spamming attribs.
	
	int CustomWeaponOnEquip;
	
	bool SniperBugged;
	
	char Model[128];
	
	int Tier;
	int Rarity;
	int PackBranches;
	int PackSkip;
	
	void Self(ItemInfo info)
	{
		info = this;
	}
	
	bool SetupKV(KeyValues kv, const char[] name, const char[] prefix="")
	{
		char buffer[512];
		
		FormatEx(buffer, sizeof(buffer), "%scost", prefix);
		this.Cost = kv.GetNum(buffer, -1);
		if(this.Cost < 0)
			return false;
		
		FormatEx(buffer, sizeof(buffer), "%sdesc", prefix);
		kv.GetString(buffer, this.Desc, 256);
		
		FormatEx(buffer, sizeof(buffer), "%sclassname", prefix);
		kv.GetString(buffer, this.Classname, 36);
		
		FormatEx(buffer, sizeof(buffer), "%scannotbesaved", prefix);
		this.CannotBeSavedByCookies = view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%sindex", prefix);
		this.Index = kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sammo", prefix);
		this.Ammo = kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sreload_mode", prefix);
		this.Reload_ModeForce = kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%ssniperfix", prefix);
		this.SniperBugged = view_as<bool>(kv.GetNum(buffer));
		
		/*
		
			//LagCompArgs, instead of harcoding indexes i will use bools and shit.
				
			"lag_comp" 						"0"
			"lag_comp_comp_collision" 		"0"
			"lag_comp_ignore_player" 		"0"
			"lag_comp_dont_move_building" 	"1"
				
			//These are the defaults for anything that shouldnt trigger lag comp at all.
				
		*/
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp", prefix);
		this.NoLagComp				= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_collision", prefix);
		this.OnlyLagCompCollision	= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_away_everything_enemy", prefix);
		this.OnlyLagCompAwayEnemy	= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_extend_boundingbox", prefix);
		this.ExtendBoundingBox		= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_dont_move_building", prefix);
		this.DontMoveBuildingComp	= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_dont_allied_npc", prefix);
		this.DontMoveAlliedNpcs	= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%slag_comp_block_internal", prefix);
		this.BlockLagCompInternal	= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%sno_clip", prefix);
		this.HasNoClip				= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%ssemi_auto", prefix);
		this.SemiAuto				= view_as<bool>(kv.GetNum(buffer));
		
		FormatEx(buffer, sizeof(buffer), "%sno_headshot", prefix);
		this.NoHeadshot				= view_as<bool>(kv.GetNum(buffer));
		

		
		FormatEx(buffer, sizeof(buffer), "%ssemi_auto_stats_fire_rate", prefix);
		this.SemiAutoStats_FireRate				= kv.GetFloat(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%ssemi_auto_stats_maxAmmo", prefix);
		this.SemiAutoStats_MaxAmmo				= kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%ssemi_auto_stats_reloadtime", prefix);
		this.SemiAutoStats_ReloadTime			= kv.GetFloat(buffer);
	
	
		
		FormatEx(buffer, sizeof(buffer), "%sfunc_attack", prefix);
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack = GetFunctionByName(null, buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sfunc_attack2", prefix)
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack2 = GetFunctionByName(null, buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sfunc_attack3", prefix)
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncAttack3 = GetFunctionByName(null, buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sfunc_reload", prefix)
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncReload4 = GetFunctionByName(null, buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sfunc_onbuy", prefix)
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.FuncOnBuy = GetFunctionByName(null, buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sint_ability_onequip", prefix)
		this.CustomWeaponOnEquip 		= kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sattack_3_ability_slot", prefix)
		this.Attack3AbilitySlot			= kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%sspecial_attribute", prefix)
		this.SpecialAdditionViaNonAttribute			= kv.GetNum(buffer);
		
		char buffers[32][16];
		FormatEx(buffer, sizeof(buffer), "%sattributes", prefix)
		kv.GetString(buffer, buffer, sizeof(buffer));
		this.Attribs = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
		for(int i; i<this.Attribs; i++)
		{
			this.Attrib[i] = StringToInt(buffers[i*2]);
			if(!this.Attrib[i])
			{
				LogError("Found invalid attribute on '%s'", name);
				this.Attribs = i;
				break;
			}
			
			this.Value[i] = StringToFloat(buffers[i*2+1]);
		}
		
		FormatEx(buffer, sizeof(buffer), "%stier", prefix);
		this.Tier = kv.GetNum(buffer, -1);
		
		FormatEx(buffer, sizeof(buffer), "%srarity", prefix);
		this.Rarity = kv.GetNum(buffer);
		if(this.Rarity > HighestTier)
			HighestTier = this.Rarity;

		FormatEx(buffer, sizeof(buffer), "%spappaths", prefix);
		this.PackBranches = kv.GetNum(buffer, 1);
		
		FormatEx(buffer, sizeof(buffer), "%spapskip", prefix);
		this.PackSkip = kv.GetNum(buffer);
		
		FormatEx(buffer, sizeof(buffer), "%smodel", prefix);
		kv.GetString(buffer, this.Model, 128);
		if(this.Model[0])
			PrecacheModel(this.Model);

		
		return true;
	}
}

enum struct Item
{
	char Name[64];
	int Section;
	int Scale;
	int CostPerWave;
	int MaxCost;
	int MaxScaled;
	int Level;
	int Slot;
	int Special;
	bool Default;
	bool NoEscape;
	bool MaxBarricadesBuild;
	bool Hidden;
	bool NoPrivatePlugin;
	bool WhiteOut;
	char BuildingExistName[64];
	bool ShouldThisCountSupportBuildings;
	
	ArrayList ItemInfos;
	
	int Owned[MAXTF2PLAYERS];
	int Scaled[MAXTF2PLAYERS];
	bool NPCSeller;
	bool NPCSeller_First;
	int NPCWeapon;
	bool NPCWeaponAlways;
	char TextStore[64];
	
	bool GetItemInfo(int index, ItemInfo info)
	{
		if(!this.ItemInfos || index >= this.ItemInfos.Length)
			return false;
		
		this.ItemInfos.GetArray(index, info);
		return true;
	}
}

static const char AmmoNames[][] =
{
	"N/A",
	"Primary",
	"Secondary",
	"Scrap Metal",
	"Ball",
	"Food",
	"Jar",
	"Pistol Magazines",
	"Rockets",
	"Flamethrower Tank",
	"Flares",
	"Grenades",
	"Stickybombs",
	"Minigun Barrel",
	"Custom Bolt",
	"Medical Syringes",
	"Sniper Rifle Rounds",
	"Arrows",
	"SMG Magazines",
	"Revolver Rounds",
	"Shotgun Shells",
	"Healing Medicine",
	"Medigun Fluid",
	"Laser Battery",
	"Hand Grenade",
	"Potion Supply"
};
//Rarity
static const int RenderColors[][] =
{
	{255, 255, 255, 255}, 	// 0
	{0, 255, 0, 255, 255},
	{ 65, 105, 225 , 255},
	{ 255, 255, 0 , 255},
	{ 178, 34, 34 , 255},
	{ 138, 43, 226 , 255},
	{0, 0, 0, 255}
};

static Cookie CookieCache;
static Cookie CookieData;
static Cookie CookieLoadoutLv;
static Cookie CookieLoadoutInv;
static ArrayList StoreItems;
static int Equipped[MAXTF2PLAYERS][6];
static int NPCOnly[MAXTF2PLAYERS];
static int NPCCash[MAXTF2PLAYERS];
static int NPCTarget[MAXTF2PLAYERS];

int Store_GetEquipped(int client, int slot)
{
	return Equipped[client][slot];
}

int Store_GetSpecialOfSlot(int client, int slot)
{
	if(StoreItems)
	{
		Item item;
		int length = StoreItems.Length;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Slot == slot && item.Owned[client])
				return item.Special;
		}
	}
	return -1;
}

void Store_PluginStart()
{
	CookieCache = new Cookie("zr_lastgame", "The last game saved data is from", CookieAccess_Protected);
	CookieData = new Cookie("zr_gamedata", "The last game saved data is from", CookieAccess_Protected);
	CookieLoadoutLv = new Cookie("zr_lastloadout_1", "The last loadout saved data is from", CookieAccess_Protected);
	CookieLoadoutInv = new Cookie("zr_lastloadout_2", "The last loadout saved data is from", CookieAccess_Protected);
}

void Store_ConfigSetup()
{
	if(StoreItems)
	{
		Item item;
		int length = StoreItems.Length;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.ItemInfos)
				delete item.ItemInfos;
		}
		delete StoreItems;
	}
	
	StoreItems = new ArrayList(sizeof(Item));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "weapons");
	KeyValues kv = new KeyValues("Weapons");
	kv.SetEscapeSequences(true);
	kv.ImportFromFile(buffer);
	RequestFrame(DeleteHandle, kv);
	
	char blacklist[32][6];
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	int blackcount;
	if(buffer[0])
		blackcount = ExplodeString(buffer, ";", blacklist, sizeof(blacklist), sizeof(blacklist[]));
	
	char whitelist[32][6];
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	int whitecount;
	if(buffer[0])
		whitecount = ExplodeString(buffer, ";", whitelist, sizeof(whitelist), sizeof(whitelist[]));
	
	kv.GotoFirstSubKey();
	do
	{
		ConfigSetup(-1, kv, false, whitelist, whitecount, blacklist, blackcount);
	} while(kv.GotoNextKey());
}

static void ConfigSetup(int section, KeyValues kv, bool hidden, const char[][] whitelist, int whitecount, const char[][] blacklist, int blackcount)
{
	bool isItem = kv.GetNum("cost", -1) >= 0;

	Item item;
	item.Section = section;
	item.Level = kv.GetNum("level");
	item.Hidden = view_as<bool>(kv.GetNum("hidden", hidden ? 1 : 0));
	if(whitecount || blackcount)
	{
		char buffer[128], buffers[32][6];
		kv.GetString("tags", buffer, sizeof(buffer));
		if(buffer[0] || isItem)
		{
			int tags = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[]));
			
			if(whitecount)
			{
				item.Hidden = true;
				
				for(int a; a < tags; a++)
				{
					for(int b; b < whitecount; b++)
					{
						if(StrEqual(buffers[a], whitelist[b], false))
						{
							item.Hidden = false;
							break;
						}
					}
					
					if(!item.Hidden)
						break;
				}
			}
			
			if(blackcount)
			{
				for(int a; a < tags; a++)
				{
					for(int b; b < whitecount; b++)
					{
						if(StrEqual(buffers[a], whitelist[b], false))
						{
							item.Hidden = true;
							break;
						}
					}
					
					if(item.Hidden)
						break;
				}
			}
		}
	}
	
	item.WhiteOut = view_as<bool>(kv.GetNum("whiteout"));
	item.ShouldThisCountSupportBuildings = view_as<bool>(kv.GetNum("count_support_buildings"));
	kv.GetString("textstore", item.TextStore, sizeof(item.TextStore));
	kv.GetSectionName(item.Name, sizeof(item.Name));
	CharToUpper(item.Name[0]);
	kv.GetString("buildingexistname", item.BuildingExistName, sizeof(item.BuildingExistName));
	
	if(isItem)
	{
		item.Default = view_as<bool>(kv.GetNum("default"));
		item.Scale = kv.GetNum("scale");
		item.CostPerWave = kv.GetNum("extracost_per_wave");
		item.MaxBarricadesBuild = view_as<bool>(kv.GetNum("max_barricade_buy_logic"));
		item.MaxCost = kv.GetNum("maxcost");
		item.MaxScaled = kv.GetNum("max_times_scale");
		item.Special = kv.GetNum("special", -1);
		item.Slot = kv.GetNum("slot", -1);
		item.NPCWeapon = kv.GetNum("npc_type", -1);
		item.NPCWeaponAlways = item.NPCWeapon > 9;
		item.ItemInfos = new ArrayList(sizeof(ItemInfo));
		
		ItemInfo info;
		info.SetupKV(kv, item.Name);
		item.ItemInfos.PushArray(info);
		
		for(int i=1; ; i++)
		{
			Format(info.Model, sizeof(info.Model), "pap_%d_", i);
			if(!info.SetupKV(kv, item.Name, info.Model))
				break;
			
			item.ItemInfos.PushArray(info);
		}
		
		StoreItems.PushArray(item);
	}
	else if(kv.GotoFirstSubKey())
	{
		item.Slot = -1;
		int sec = StoreItems.PushArray(item);
		do
		{
			ConfigSetup(sec, kv, item.Hidden, whitelist, whitecount, blacklist, blackcount);
		} while(kv.GotoNextKey());
		kv.GoBack();
	}
}

bool Store_CanPapItem(int client, int index)
{
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(!item.GetItemInfo(item.Owned[client] - 1, info))
				return false;
			
			if(!item.GetItemInfo(item.Owned[client] + info.PackSkip, info))
				return false;
			
			return view_as<bool>(info.Cost);
		}
	}
	return false;
}

void Store_PackMenu(int client, int index, int entity, int owner)
{
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(item.GetItemInfo(item.Owned[client] - 1, info))
			{
				int count = info.PackBranches;
				if(count > 0)
				{
					Menu menu = new Menu(Store_PackMenuH);
					
					SetGlobalTransTarget(client);
					int cash = CurrentCash-CashSpent[client];
					menu.SetTitle("%t\n \n%t\n \n%s%s\n ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name), AddPluses(item.Owned[client]-1));
					
					int skip = info.PackSkip;
					count += skip;
					
					int userid = (client == owner || owner == -1) ? -1 : GetClientUserId(owner);
					
					char data[64], buffer[64];
					for(int i = skip; i < count; i++)
					{
						if(item.GetItemInfo(item.Owned[client] + i, info) && info.Cost)
						{
							FormatEx(data, sizeof(data), "%d;%d;%d;%d", index, item.Owned[client] + i, entity, userid);
							FormatEx(buffer, sizeof(buffer), "%s%s [$%d]", TranslateItemName(client, item.Name), AddPluses(item.Owned[client] + i), info.Cost);
							menu.AddItem(data, buffer, cash < info.Cost ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
							
							if(info.Desc[0])
							{
								StrCat(info.Desc, sizeof(info.Desc), "\n ");
								menu.AddItem("", info.Desc, ITEMDRAW_DISABLED);
							}
						}
					}
					
					if(!data[0])
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Cannot Pap this");
						menu.AddItem("", buffer, ITEMDRAW_DISABLED);
					}
					
					menu.Pagination = 6;
					menu.ExitButton = true;
					menu.Display(client, MENU_TIME_FOREVER);
				}
			}
		}
	}
}

public int Store_PackMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Select:
		{
			char buffer[64];
			menu.GetItem(choice, buffer, sizeof(buffer));
			
			int values[4];
			ExplodeStringInt(buffer, ";", values, sizeof(values));
			
			static Item item;
			StoreItems.GetArray(values[0], item);
			if(item.Owned[client])
			{
				int owner = -1;
				
				ItemInfo info;
				if(item.GetItemInfo(values[1], info) && info.Cost && (CurrentCash-CashSpent[client]) >= info.Cost)
				{
					CashSpent[client] += info.Cost;
					item.Owned[client] = values[1] + 1;
					StoreItems.SetArray(values[0], item);
					
					TF2_StunPlayer(client, 2.0, 0.0, TF_STUNFLAG_BONKSTUCK | TF_STUNFLAG_SOUND, 0);
					
					SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
					SetGlobalTransTarget(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "Your weapon was boosted");
					Store_ApplyAttribs(client);
					Store_GiveAll(client, GetClientHealth(client));
					
					owner = GetClientOfUserId(values[3]);
					if(owner)
					{
						if(Pack_A_Punch_Machine_money_limit[owner][client] <= 5)
						{
							Pack_A_Punch_Machine_money_limit[owner][client] += 1;
							CashSpent[owner] -= 400;
							Resupplies_Supplied[owner] += 40;
							SetHudTextParams(-1.0, 0.90, 3.01, 34, 139, 34, 255);
							SetGlobalTransTarget(owner);
							ShowSyncHudText(owner, SyncHud_Notifaction, "%t", "Pap Machine Used");
						}
					}
					else
					{
						owner = -1;
					}
				}
				
				Store_PackMenu(client, values[0], values[2], owner);
			}
		}
	}
	return 0;
}

/*int Store_PackCurrentItem(int client, int index)
{
	if(index > 0)
	{
		static Item item;
		StoreItems.GetArray(index, item);
		if(item.Owned[client])
		{
			ItemInfo info;
			if(!item.GetItemInfo(item.Owned[client], info))
				return 1;
			
			int money_for_pap = info.Cost;
			if(money_for_pap > 0)
			{		
				if(money_for_pap <= (CurrentCash-CashSpent[client]))
				{
					CashSpent[client] += money_for_pap;
					item.Owned[client]++;
					StoreItems.SetArray(index, item);
					return 3; //You just paped it.
				}
				else
				{
					return 2; //You dont got enough money to pap it.
				}
			}
			else
			{
				return 1; //You own it but this weapon cannot be pack a punched.
			}
		}
	}
	return 0; //you dont own the item.
}*/

void Store_Reset()
{
	for(int c=1; c<=MaxClients; c++)
	{
		if(IsClientInGame(c))
			Store_SaveLevelPerks(c);
		
		CashSpent[c] = 0;
		
		for(int i; i<sizeof(Equipped[]); i++)
		{
			Equipped[c][i] = -1;
		}
	}
	
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int c=1; c<=MaxClients; c++)
		{
			item.Owned[c] = 0;
			item.Scaled[c] = 0;
		}
		StoreItems.SetArray(i, item);
	}
	
	for(int c=1; c<=MaxClients; c++)
	{
		if(IsClientInGame(c))
			Store_LoadLevelPerks(c, true);
	}
}

bool Store_HasAnyItem(int client)
{
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Owned[client])
		{
			item.GetItemInfo(item.Owned[client] - 1, info);
			if(info.Cost)
				return true;
		}
	}
	
	return false;
}

int Store_HasNamedItem(int client, const char[] name)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
			return item.Owned[client];
	}
	
	ThrowError("Unknown item name %s", name);
	return 0;
}

void Store_SetNamedItem(int client, const char[] name, int amount)
{
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			item.Owned[client] = amount;
			StoreItems.SetArray(i, item);
			return;
		}
	}
	
	ThrowError("Unknown item name %s", name);
}

void Store_PutInServer(int client)
{
	if(EscapeMode)
		return;
	
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Default)
		{
			ItemInfo info;
			item.GetItemInfo(0, info);
			
			CashSpent[client] += info.Cost;
			item.Owned[client] = 1;
			item.Scaled[client]++;
			
			if(item.MaxScaled < item.Scaled[client])
			{
				item.Scaled[client] = item.MaxScaled;
			}
			StoreItems.SetArray(i, item);
			
			int slot = TF2_GetClassnameSlot(info.Classname);
			Equipped[client][slot] = i;
			TF2_RemoveWeaponSlot(client, slot);
			
			if(info.Ammo && info.Ammo < Ammo_MAX)
			{
				i = GetAmmo(client, info.Ammo);
				while(CashSpent[client]+AmmoData[info.Ammo][0] <= StartCash)
				{
					CashSpent[client] += AmmoData[info.Ammo][0];
					i += AmmoData[info.Ammo][1];
				}
				CurrentAmmo[client][info.Ammo] = i;
			}
			
			if(!TeutonType[client])
			{
				Store_GiveItem(client, slot);
				Manual_Impulse_101(client, GetClientHealth(client));
			}
			break;
		}
	}
	
	if(IsPlayerAlive(client))
		TF2_RegeneratePlayer(client);
}

void Store_ClientCookiesCached(int client)
{
	Store_LoadLevelPerks(client);
	
	char buffer[16];
	CookieCache.Get(client, buffer, sizeof(buffer));
	if(CurrentGame && StringToInt(buffer) == CurrentGame)
		Store_LoadLoadout(client);
}

void Store_LoadLevelPerks(int client, bool silent=false)
{
//	PrintToChatAll("load level perks");
	char buffer[512];
	
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	if(buffer[0])
		return;
	
	zr_tagwhitelist.GetString(buffer, sizeof(buffer));
	if(buffer[0])
		return;
	
	char buffers[16][64];
	static Item item;
	int items = StoreItems.Length;
	
	bool found;
	CookieLoadoutLv.Get(client, buffer, sizeof(buffer));
	int length = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[]));
	for(int i; i<length; i++)
	{
		for(int a; a<items; a++)
		{
			StoreItems.GetArray(a, item);
			if(StrEqual(buffers[i], item.Name))
			{
				if(item.Scale == 0 && !item.Hidden)
				{
					item.Scaled[client] = 0;
					item.Owned[client] = 1;
					StoreItems.SetArray(a, item);
					found = true;
					
					ItemInfo info;
					item.GetItemInfo(0, info);
					if(info.Classname[0])
					{
						int slot = TF2_GetClassnameSlot(info.Classname);
						if(slot >= 0 && slot < sizeof(Equipped[]))
							Equipped[client][slot] = a;
					}
				}
				break;
			}
		}
	}
	
	CookieLoadoutInv.Get(client, buffer, sizeof(buffer));
	length = ExplodeString(buffer, ";", buffers, sizeof(buffers), sizeof(buffers[]));
	for(int i; i<length; i++)
	{
		for(int a; a<items; a++)
		{
			StoreItems.GetArray(a, item);
			if(StrEqual(buffers[i], item.Name))
			{
				if(item.Scale == 0 && !item.Hidden)
				{
					item.Scaled[client] = 0;
					item.Owned[client] = 1;
					StoreItems.SetArray(a, item);
					found = true;
					
					ItemInfo info;
					item.GetItemInfo(0, info);
					if(info.Classname[0])
					{
						int slot = TF2_GetClassnameSlot(info.Classname);
						if(slot >= 0 && slot < sizeof(Equipped[]))
							Equipped[client][slot] = a;
					}
				}
				break;
			}
		}
	}
	
	if(!silent && found && IsClientInGame(client))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t","Your last equipped level perks were restored");
		if(IsPlayerAlive(client))
			TF2_RegeneratePlayer(client);
	}
}

bool Store_LoadLoadout(int client)
{
	char buffer[512];
	static int buffers[128];
	CookieData.Get(client, buffer, sizeof(buffer));
	if(!buffer[0])
		return false;
	
	int length = ExplodeStringInt(buffer, ";", buffers, sizeof(buffers));
	CashSpent[client] = buffers[0];
	
	int i = 1;
	for(; i<=sizeof(Equipped[]); i++)
	{
		Equipped[client][i-1] = buffers[i];
	}
	
	static Item item;
	int items = StoreItems.Length;
	for(i++; i<length; i+=2)
	{
		if(buffers[i-1] > 0 && buffers[i-1] < items)
		{
			StoreItems.GetArray(buffers[i-1], item);
			if(item.Scale != 0)
			{
				item.Scaled[client] = buffers[i];
				item.Owned[client] = 0;
			}
			else if(buffers[i] > 0)
			{
				item.Scaled[client] = 0;
				item.Owned[client] = buffers[i];
			}
			StoreItems.SetArray(buffers[i-1], item);
		}
	}
	
	if(IsClientInGame(client))
	{
		SetGlobalTransTarget(client);
		PrintToChat(client, "%t","Your loadout was updated from your previous state.");
		if(IsPlayerAlive(client))
			TF2_RegeneratePlayer(client);
	}
	return true;
}

void Store_ClientDisconnect(int client)
{
	if(AreClientCookiesCached(client))
	{
		char buffer[16];
		IntToString(CurrentGame, buffer, sizeof(buffer));
		CookieCache.Set(client, buffer);
	}
	
	Store_SaveLevelPerks(client);
	Store_SaveLoadout(client);
	
	CashSpent[client] = 0;
	Equipped[client][0] = -1;
	
	for(int i=1; i<sizeof(Equipped[]); i++)
	{
		Equipped[client][i] = -1;
	}
	
	static Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Owned[client] || item.Scale != 0)
		{
			item.Owned[client] = 0;
			item.Scaled[client] = 0;
			StoreItems.SetArray(i, item);
		}
	}
}

void Store_SaveLevelPerks(int client)
{
//	PrintToChatAll("Saving LeveL Perks");
	char level[512];
	zr_tagblacklist.GetString(level, sizeof(level));
	if(level[0])
		return;
	
	zr_tagwhitelist.GetString(level, sizeof(level));
	if(level[0])
		return;
	
	char inv[512];
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length - 1;
	for(int i = length; i >= 0; i--)
	{	
		StoreItems.GetArray(i, item);
		if(item.Scaled[client] > 0 || item.Owned[client])
		{
			int owned = item.Owned[client] - 1;
			if(owned < 0)
				owned = 0;
			
			item.GetItemInfo(owned, info);
			if(!info.Cost && !info.CannotBeSavedByCookies)
			{
				if(item.TextStore[0])
				{
					if(inv[0])
					{
						Format(inv, sizeof(inv), "%s;%s", inv, item.Name);
					}
					else
					{
						strcopy(inv, sizeof(inv), item.Name);
					}
				}
				else if(level[0])
				{
					Format(level, sizeof(level), "%s;%s", level, item.Name);
				}
				else
				{
					strcopy(level, sizeof(level), item.Name);
				}
			}
		}
	}
	
	if(level[0])
	{
//		PrintToChatAll("%s",level);
		CookieLoadoutLv.Set(client, level);
	}
//	else
//	{
//		PrintToChatAll("NO SAVE");	
//	}
	
	if(inv[0])
	{
		CookieLoadoutInv.Set(client, inv);
	}
}

void Store_SaveLoadout(int client)
{
//	PrintToChatAll("Save Loadout");
	char buffer[512];
	Format(buffer, sizeof(buffer), "%d;%d", CashSpent[client], Equipped[client][0]);
	
	for(int i=1; i<sizeof(Equipped[]); i++)
	{
		Format(buffer, sizeof(buffer), "%s;%d", buffer, Equipped[client][i]);
	}
	
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		
		int owned = item.Owned[client] - 1;
		if(owned < 0)
			owned = 0;
		
		item.GetItemInfo(owned, info);
		if(info.Cost)
		{
			if(item.Scaled[client])
			{
				Format(buffer, sizeof(buffer), "%s;%d;%d", buffer, i, item.Scaled[client]);
			}
			else if(item.Owned[client])
			{
				Format(buffer, sizeof(buffer), "%s;%d;%d", buffer, i, item.Owned[client]);
			}
		}
	}
	
	CookieData.Set(client, buffer);
}

public void Store_RandomizeNPCStore(bool ResetStore)
{
	int amount;
	int length = StoreItems.Length;
	int[] indexes = new int[length];
	
	static Item item;
	static ItemInfo info;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.ItemInfos && !item.TextStore[0] && !item.NPCWeaponAlways)
		{
			item.NPCSeller_First = false;
			item.NPCSeller = false;
			item.GetItemInfo(0, info);
			if(info.Cost > 0 && info.Cost > (CurrentCash / 3 - 1000) && info.Cost < CurrentCash)
				indexes[amount++] = i;
			
			StoreItems.SetArray(i, item);
		}
	}
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(!ResetStore)
		{
			bool OneSuperSale = true;
			SortIntegers(indexes, amount, Sort_Random);
			for(int i; i<3 && i<amount; i++) //amount of items to sell
			{
				StoreItems.GetArray(indexes[i], item);
				if(OneSuperSale)
				{
					item.NPCSeller_First = true;
					OneSuperSale = false;
				}
				item.NPCSeller = true;
				StoreItems.SetArray(indexes[i], item);
			}
		}
	}
}

void Store_RoundStart()
{
	static Item item;
	static ItemInfo info;
	ArrayList[] lists = new ArrayList[HighestTier+1];
	char buffer[PLATFORM_MAX_PATH], buffers[4][12];
	int entity = MaxClients+1;
	while((entity=FindEntityByClassname(entity, "prop_dynamic")) != -1)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer))
		if(!StrContains(buffer, "zr_weapon_", false))
		{
			int tier = ExplodeString(buffer, "_", buffers, sizeof(buffers), sizeof(buffers[])) - 1;
			tier = StringToInt(buffers[tier]);
			if(tier >= 0 && tier <= HighestTier)
			{
				int length;
				if(!lists[tier])
				{
					lists[tier] = GetAllWeaponsWithTier(tier);
					if(!(length = lists[tier].Length))
					{
						delete lists[tier];
						lists[tier] = null;
						RemoveEntity(entity);
						continue;
					}
				}
				else if(!(length = lists[tier].Length))
				{
					delete lists[tier];
					lists[tier] = GetAllWeaponsWithTier(tier);
				}
				
				length = GetRandomInt(0, length-1);
				int ids[2];
				lists[tier].GetArray(length, ids);
				StoreItems.GetArray(ids[0], item);
				item.GetItemInfo(ids[1], info);
				lists[tier].Erase(length);
				
				if(info.Model[0])
					SetEntityModel(entity, info.Model);
				
				SetEntProp(entity, Prop_Send, "m_nSkin", ids[0]);
				SetEntProp(entity, Prop_Send, "m_nBody", ids[1]);
				
				if(tier >= sizeof(RenderColors))
					tier = sizeof(RenderColors)-1;
				
				SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(entity, RenderColors[tier][0], RenderColors[tier][1], RenderColors[tier][2], RenderColors[tier][3]);
			}
			else
			{
				RemoveEntity(entity);
				continue;
			}
			
			SetEntityCollisionGroup(entity, 1);
		//	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 2);
			AcceptEntityInput(entity, "DisableShadow");
			AcceptEntityInput(entity, "EnableCollision");
			//Relocate weapon to higher height, looks much better
			float pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			pos[2] += 0.8;
			TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
		}
	}
	
	for(int i; i<=HighestTier; i++)
	{
		if(lists[i])
		{
			delete lists[i];
			lists[i] = null;
		}
	}
}

public bool Do_Not_Collide(int client, int collisiongroup, int contentsmask, bool originalResult)
{
	if(collisiongroup == 9) //Only npc's
		return false;
	else
		return originalResult;
} 

static ArrayList GetAllWeaponsWithTier(int tier)
{
	ArrayList list = new ArrayList(2);
	
	static Item item;
	static ItemInfo info;
	int length = StoreItems.Length;
	int array[2];
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		for(int a; item.GetItemInfo(a, info); a++)
		{
			if(info.Tier == tier)
			{
				array[0] = i;
				array[1] = a;
				for(int b; b<info.Rarity; b++)
				{
					list.PushArray(array);
				}
			}
		}
	}
	
	return list;
}

public Action Access_StoreViaCommand(int client, int args)
{
	if (!IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if(!IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 0;
		MenuPage(client, -1);
	}
	return Plugin_Continue;
}

public void Store_Menu(int client)
{
	if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 0;
		MenuPage(client, -1);
	}
}

void Store_OpenNPCStore(int client)
{
	if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 1;
		MenuPage(client, -1);
	}
}

void Store_OpenGiftStore(int client, int entity, int price)
{
	if(StoreItems && !IsVoteInProgress() && !Waves_CallVote(client))
	{
		NPCOnly[client] = 2;
		NPCTarget[client] = EntIndexToEntRef(entity);
		NPCCash[client] = price;
		MenuPage(client, -1);
	}
}

static void MenuPage(int client, int section)
{
	SetGlobalTransTarget(client);
	
	Menu menu;
	
	if(CvarInfiniteCash.BoolValue)
	{
		CurrentCash = 999999;
		CashSpent[client] = 0;
	}
	static Item item;
	static ItemInfo info;
	if(section > -1)
	{
		StoreItems.GetArray(section, item);
		if(item.ItemInfos)
		{
			menu = new Menu(Store_MenuItem);
			int cash = CurrentCash-CashSpent[client];
			char buffer[512];
			
			int level = item.Owned[client] - 1;
			if(level < 0 || NPCOnly[client] == 2)
				level = 0;
			
			item.GetItemInfo(level, info);
			
			level = item.Owned[client];
			if(level < 1 || NPCOnly[client] == 2)
				level = 1;
			
			SetGlobalTransTarget(client);
			ItemInfo info2;
			if(item.GetItemInfo(level, info2))
			{
				if(NPCOnly[client] == 1)
				{
					FormatEx(buffer, sizeof(buffer), "%t\n%t\n%t\n \n%t\n \n%s%s \n<%t> [%i] ", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", cash, TranslateItemName(client, item.Name), AddPluses(level-1),"Can Be Pack-A-Punched", info2.Cost);
				}
				else if(Waves_Started())
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n \n%t\n \n%s%s \n<%t> [%i] ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name), AddPluses(level-1),"Can Be Pack-A-Punched", info2.Cost);
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n%t\n%s%s  \n<%t> [%i] ", "TF2: Zombie Riot", "Credits", cash, "Store Discount", TranslateItemName(client, item.Name), AddPluses(level-1),"Can Be Pack-A-Punched", info2.Cost);
				}
			}
			else
			{
				if(NPCOnly[client] == 1)
				{
					FormatEx(buffer, sizeof(buffer), "%t\n%t\n%t\n \n%t\n \n%s ", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", cash, TranslateItemName(client, item.Name), AddPluses(level-1));
				}
				else if(Waves_Started())
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n \n%s ", "TF2: Zombie Riot", "Credits", cash, TranslateItemName(client, item.Name), AddPluses(level-1));
				}
				else
				{
					FormatEx(buffer, sizeof(buffer), "%t\n \n%t\n%t\n%s%s ", "TF2: Zombie Riot", "Credits", cash, "Store Discount", TranslateItemName(client, item.Name), AddPluses(level-1));
				}				
			}
			

			//		, TranslateItemName(client, item.Name) , item.PackCost > 0 ? "<Packable>" : ""
			Config_CreateDescription(info.Classname, info.Attrib, info.Value, info.Attribs, buffer, sizeof(buffer));
			menu.SetTitle("%s\n%s\n ", buffer, info.Desc);
			
			if(NPCOnly[client] == 2)
			{
				char buffer2[16];
				IntToString(section, buffer2, sizeof(buffer2));
				
				ItemCost(client, item, info.Cost);
				if(!item.NPCWeaponAlways)
					info.Cost -= NPCCash[client];
				
				FormatEx(buffer, sizeof(buffer), "%t ($%d)", "Buy", info.Cost);
				menu.AddItem(buffer2, buffer, info.Cost > cash ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
			}
			else
			{
				bool canSell;
				bool canSellInsideMenu;
				int style = ITEMDRAW_DEFAULT;
				int slot = TF2_GetClassnameSlot(info.Classname);
				if(slot < sizeof(Equipped[]) && Equipped[client][slot] == section)
				{
					if(!EscapeMode && info.Ammo && info.Ammo < Ammo_MAX)
					{
						int cost = AmmoData[info.Ammo][0];
						FormatEx(buffer, sizeof(buffer), "%t ($%d)", AmmoNames[info.Ammo], cost);
						if(cost > cash)
							style = ITEMDRAW_DISABLED;
						
						
					}
					
					
					else
					{
						canSellInsideMenu = true;
						FormatEx(buffer, sizeof(buffer), "%t", "Equip");
						style = ITEMDRAW_DISABLED;
					}
				}
				else if(item.Owned[client] || !info.Cost)
				{
					FormatEx(buffer, sizeof(buffer), "%t", "Equip");
					if(!info.Classname[0])
					{
						if(item.Owned[client])
							style = ITEMDRAW_DISABLED;
					}
					/*
					else if(info.Cost)
					{
						canSell = true;
					}
					*/
				}
				else
				{
					ItemCost(client, item, info.Cost);
					bool Maxed_Building = false;
					
					if(item.MaxBarricadesBuild)
					{
						if(i_BarricadesBuild[client] >= MaxBarricadesAllowed(client))
						{
							Maxed_Building = true;
							style = ITEMDRAW_DISABLED;
						}
					}
					if(Maxed_Building)
					{
						FormatEx(buffer, sizeof(buffer), "%t ($%d) [%t] [%i/%i]", "Buy", info.Cost,"MAX BARRICADES OUT CURRENTLY", i_BarricadesBuild[client], MaxBarricadesAllowed(client));
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%t ($%d)", "Buy", info.Cost);
					}
					if(info.Cost > cash)
						style = ITEMDRAW_DISABLED;
				}
			//	if(info.Cost)// Just allow selling for items that cost 0, like it doesnt matter in the end, does it ?
				{
					if(item.Owned[client])
					{
						if(info.Attack3AbilitySlot != 0 || info.Classname[0] || (!info.Cost && !Waves_Started())) //make sure they cant sell or unqeuip perks though.
						{
							canSellInsideMenu = true;
							canSell = true;
						}
					}
				}
				
				char buffer2[16];
				IntToString(section, buffer2, sizeof(buffer2));
				menu.AddItem(buffer2, buffer, style);
				
				if(!EscapeMode && slot < sizeof(Equipped[]) && Equipped[client][slot] == section)
				{
					if(info.Ammo && info.Ammo < Ammo_MAX)
					{
						canSellInsideMenu = false;
						int cost = AmmoData[info.Ammo][0];
						cost *= 10;
						FormatEx(buffer, sizeof(buffer), "%t x10 ($%d)", AmmoNames[info.Ammo], cost);
						if(cost > cash)
							style = ITEMDRAW_DISABLED;
							
						menu.AddItem(buffer2, buffer, style);
					}
				}

				//ima just make it so it sells for now since you fucked it up WITHOUT TESTING BATFOXKID
				if(/*item.FuncOnBuy != INVALID_FUNCTION && */(canSell && (!EscapeMode || !Waves_Started())) || item.TextStore[0] || item.Level && !Waves_Started())
				{
					if(item.TextStore[0] || item.Level && !Waves_Started() || (!info.Cost && !info.Classname[0]))
					{
						int style_unequip = ITEMDRAW_DEFAULT;
						
						FormatEx(buffer, sizeof(buffer), "------");//my shitcoding, nooooo!!
						menu.AddItem(buffer2, buffer, ITEMDRAW_DISABLED);
						
						FormatEx(buffer, sizeof(buffer), "%t", "Unequip");
						if(!item.Owned[client])
						{
							style_unequip = ITEMDRAW_DISABLED;
						}
						menu.AddItem(buffer2, buffer, style_unequip);
						menu.ExitBackButton = true;
						menu.Display(client, MENU_TIME_FOREVER);
						return;
					}
					if(canSellInsideMenu)
					{
						FormatEx(buffer, sizeof(buffer), "------");//my shitcoding, nooooo!!
						menu.AddItem(buffer2, buffer, ITEMDRAW_DISABLED);
					}
					if(Equipped[client][slot] == section)
					{
						FormatEx(buffer, sizeof(buffer), "%t", "Unequip");
						menu.AddItem(buffer2, buffer);
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "------");//my shitcoding, nooooo!!
						menu.AddItem(buffer2, buffer, ITEMDRAW_DISABLED);
					}
					
					if(info.Cost)
					{
						int sell = ItemSell(item, level, client);
						FormatEx(buffer, sizeof(buffer), "%t ($%d) | (%t: $%d)", "Sell", sell, "Credits After Selling",sell + (CurrentCash-CashSpent[client]));
						menu.AddItem(buffer2, buffer);
					}
				}
			}
			
			menu.ExitBackButton = true;
			menu.Display(client, MENU_TIME_FOREVER);
			return;
		}
		
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			menu.SetTitle("%t\n%t\n%t\n \n%t\n \n%s", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!", "Credits", CurrentCash-CashSpent[client], TranslateItemName(client, item.Name));
		}
		else if(Waves_Started())
		{
			menu.SetTitle("%t\n \n%t\n \n%s", "TF2: Zombie Riot", "Credits", CurrentCash-CashSpent[client], TranslateItemName(client, item.Name));
		}
		else
		{
			menu.SetTitle("%t\n \n%t\n%t\n%s", "TF2: Zombie Riot", "Credits", CurrentCash-CashSpent[client], "Store Discount", TranslateItemName(client, item.Name));
		}
	}
	else
	{
		int xpLevel = LevelToXp(Level[client]);
		int xpNext = LevelToXp(Level[client]+1);
		
		int extra = XP[client]-xpLevel;
		int nextAt = xpNext-xpLevel;
		
		if(extra < 0)
			extra *= -1;
		
		menu = new Menu(Store_MenuPage);
		if(NPCOnly[client] == 1)
		{
			menu.SetTitle("%t\n%t\n%t\n \n%t\n%t\n \n ", "TF2: Zombie Riot", "Father Grigori's Store","All Items are 20%% off here!" , "XP and Level", Level[client], extra, nextAt, "Credits", CurrentCash-CashSpent[client]);
		}
		else if(Waves_Started())
		{
			menu.SetTitle("%t\n \n%t\n%t\n \n ", "TF2: Zombie Riot", "XP and Level", Level[client], extra, nextAt, "Credits", CurrentCash-CashSpent[client]);
		}
		else
		{
			menu.SetTitle("%t\n \n%t\n%t\n%t\n ", "TF2: Zombie Riot", "XP and Level", Level[client], extra, nextAt, "Credits", CurrentCash-CashSpent[client], "Store Discount");
		}
		
		if(section == -1)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Owned Items");
			menu.AddItem("-2", buffer);
		}
	}
	
	bool found;
	char buffer[96];
	int length = StoreItems.Length;
	static Item item2;
	
	int ClientLevel = Level[client];
	
	if(CvarInfiniteCash.BoolValue)
	{
		ClientLevel = 9999; //Set client lvl to 9999 for shop if infinite cash is enabled.
	}
	
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(NPCOnly[client] == 1)
		{
			if(!item.NPCSeller || item.Level > ClientLevel)
				continue;
		}
		else if(NPCOnly[client] == 2)
		{
			if(item.Level > ClientLevel)
				continue;
		}
		else if(item.Hidden || (section == -2 ? (item.Owned[client] || item.Scaled[client]) : item.Section != section) || item.Level > ClientLevel || (EscapeMode && item.NoEscape))
		{
			continue;
		}
		
		if(NPCOnly[client] == 2)
		{
			if(item.NPCWeapon < 0)
				continue;
		}
		else if(item.NPCWeapon > 9)
		{
			continue;
		}
		
		if(item.TextStore[0] && !HasNamedItem(client, item.TextStore))
			continue;
		
		if(NPCOnly[client] != 2 && !item.Owned[client] && item.Slot >= 0)
		{
			int count;
			for(int a; a<length; a++)
			{
				if(a == i)
					continue;
				
				StoreItems.GetArray(a, item2);
				if((item2.Owned[client] || item2.Scaled[client]) && item2.Slot == item.Slot)
					count++;
			}
			
			if(count)
			{
				if(item.Slot >= sizeof(SlotLimits))
					continue;
				
				if(count >= SlotLimits[item.Slot])
					continue;
			}
		}
		
		if(NPCOnly[client] == 2)
		{
			if(item.ItemInfos)
			{
				int npcwallet = item.NPCWeaponAlways ? 0 : NPCCash[client];
				
				item.GetItemInfo(0, info);
				if(info.Cost <= CurrentCash && RoundToCeil(float(info.Cost) * SELL_AMOUNT) > npcwallet)
				{
					ItemCost(client, item, info.Cost);
					FormatEx(buffer, sizeof(buffer), "%s [$%d]", TranslateItemName(client, item.Name), info.Cost - npcwallet);
					
					if(item.NPCSeller_First)
					{
						FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$$}");
					}	
					else if(item.NPCSeller)
					{
						FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$}");
					}
					
					IntToString(i, info.Classname, sizeof(info.Classname));
					menu.AddItem(info.Classname, buffer);
					found = true;
				}
			}
		}
		else if(!item.ItemInfos)
		{
			IntToString(i, info.Classname, sizeof(info.Classname));
			menu.AddItem(info.Classname, TranslateItemName(client, item.Name));
			found = true;
		}
		else
		{
			item.GetItemInfo(0, info);
			if(info.Cost <= CurrentCash)
			{
				int style = ITEMDRAW_DEFAULT;
				int slot = TF2_GetClassnameSlot(info.Classname);
				IntToString(i, info.Classname, sizeof(info.Classname));
				
				char BuildingExtraCounter[8];
				if(item.BuildingExistName[0])
				{
					char BuildingGetName[24];
					char BuildingGetName_2[24];
					
					int How_Many_Buildings_Exist = 0;
					
					strcopy(BuildingGetName, sizeof(BuildingGetName), item.BuildingExistName);
					
					for(int entitycount; entitycount<i_MaxcountBuilding; entitycount++)
					{
						int entity = EntRefToEntIndex(i_ObjectsBuilding[entitycount]);
						if(IsValidEntity(entity))
						{
							GetEntPropString(entity, Prop_Data, "m_iName", BuildingGetName_2, sizeof(BuildingGetName_2));
							if(StrEqual(BuildingGetName_2, BuildingGetName, true))
							{
								How_Many_Buildings_Exist += 1;
							}
						}
					}
					Format(BuildingExtraCounter, sizeof(BuildingExtraCounter), "{%i}", How_Many_Buildings_Exist);
				}
				
				if(slot < sizeof(Equipped[]) && Equipped[client][slot] == i)
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t] %s", TranslateItemName(client, item.Name), "Equipped", BuildingExtraCounter);
				}
				else if(item.Owned[client] == 2)
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t] %s", TranslateItemName(client, item.Name), "Packed", BuildingExtraCounter);
				}
				else if(item.Owned[client])
				{
					FormatEx(buffer, sizeof(buffer), "%s [%t] %s", TranslateItemName(client, item.Name), "Purchased", BuildingExtraCounter);
				}
				else if(!info.Cost && item.Level)
				{
					FormatEx(buffer, sizeof(buffer), "%s [Lv %d] %s", TranslateItemName(client, item.Name), item.Level, BuildingExtraCounter);
				}
				else
				{
					ItemCost(client, item, info.Cost);
					if(!info.Cost && item.WhiteOut)
					{
						if(item.ShouldThisCountSupportBuildings)
						{
							FormatEx(buffer, sizeof(buffer), "%s[%d/%d]", TranslateItemName(client, item.Name), i_SupportBuildingsBuild[client], MaxSupportBuildingsAllowed(client, false));
						}
						else
						{
							FormatEx(buffer, sizeof(buffer), "%s", TranslateItemName(client, item.Name));
						}
						style = ITEMDRAW_DISABLED;
					}
					else
					{
						FormatEx(buffer, sizeof(buffer), "%s [$%d] %s", TranslateItemName(client, item.Name), info.Cost, BuildingExtraCounter);
					}
				}
				
				if(item.NPCSeller_First)
				{
					FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$$}");
				}	
				else if(item.NPCSeller)
				{
					FormatEx(buffer, sizeof(buffer), "%s%s", buffer, "{$}");
				}
				
				menu.AddItem(info.Classname, buffer, style);
				found = true;
			}
		}
	}
	
	if(section == -1 && !NPCOnly[client])
	{
		FormatEx(buffer, sizeof(buffer), "%t", "Help?");
		menu.AddItem("-3", buffer);
		
		zr_tagblacklist.GetString(buffer, sizeof(buffer));
		if(StrContains(buffer, "private", false) == -1)
		{
			FormatEx(buffer, sizeof(buffer), "%t", "Encyclopedia");
			menu.AddItem("-13", buffer);
			
			FormatEx(buffer, sizeof(buffer), "%t", "Bored or Dead");
			menu.AddItem("-14", buffer);
		}
		
		FormatEx(buffer, sizeof(buffer), "%t", "Gamemode Credits"); //credits is whatever, put in back.
		menu.AddItem("-21", buffer);
	}
	else if(!found)
	{
		FormatEx(buffer, sizeof(buffer), "%t", "None");
		menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}
	menu.ExitBackButton = section != -1;
	menu.Display(client, MENU_TIME_FOREVER);
}

static char[] AddPluses(int amount)
{
	char buffer[16];
	if(amount)
	{
		FormatEx(buffer, sizeof(buffer), " V%d", amount + 1);
	}
	else
	{
		buffer[amount] = '\0';
	}
	return buffer;
}

public int Store_MenuPage(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				Item item;
				menu.GetItem(0, item.Name, sizeof(item.Name));
				StoreItems.GetArray(StringToInt(item.Name), item);
				if(item.Section != -1)
					StoreItems.GetArray(item.Section, item);
				
				MenuPage(client, item.Section);
			}
			/*
			else if(choice != MenuCancel_Disconnected)
			{
				StopSound(client, SNDCHAN_STATIC, "#items/tf_music_upgrade_machine.wav");
			}
			*/
		}
		case MenuAction_Select:
		{
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			if(id == -21)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Credits Page");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -3)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Help Title?");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Gamemode Help?");
				menu2.AddItem("-4", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Command Help?");
				menu2.AddItem("-5", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Difficulty Help?");
				menu2.AddItem("-6", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Level Help?");
				menu2.AddItem("-7", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Special Zombies Help?");
				menu2.AddItem("-8", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Revival Help?");
				menu2.AddItem("-9", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Building Help?");
				menu2.AddItem("-10", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Escape Help?");
				menu2.AddItem("-11", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -4)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Gamemode Help Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -5)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Command Help Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -6)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Difficulty Help Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -7)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Level Help Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -8)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Special Zombies Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -9)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Revival Zombies Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -10)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Building Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -11)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Escape Explained");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -13)
			{
				FakeClientCommand(client, "sm_encyclopedia");
			}
			else if(id == -14)
			{
				Menu menu2 = new Menu(Store_MenuPage);
				menu2.SetTitle("%t", "Bored or Dead Minigame");
				
				FormatEx(buffer, sizeof(buffer), "%t", "Idlemine");
				menu2.AddItem("-15", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Tetris");
				menu2.AddItem("-16", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Snake");
				menu2.AddItem("-17", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Solitaire");
				menu2.AddItem("-18", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Pong");
				menu2.AddItem("-19", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Connect 4");
				menu2.AddItem("-20", buffer);
				
				FormatEx(buffer, sizeof(buffer), "%t", "Back");
				menu2.AddItem("-1", buffer);
				
				menu2.Display(client, MENU_TIME_FOREVER);
			}
			else if(id == -15)
			{
				FakeClientCommand(client, "sm_idlemine");
			}
			else if(id == -16)
			{
				FakeClientCommand(client, "sm_tetris");
			}
			else if(id == -17)
			{
				FakeClientCommand(client, "sm_snake");
			}
			else if(id == -18)
			{
				FakeClientCommand(client, "sm_solitaire");
			}
			else if(id == -19)
			{
				FakeClientCommand(client, "sm_pong");
			}
			else if(id == -20)
			{
				FakeClientCommand(client, "sm_connect4");
			}
			else
			{
				MenuPage(client, id);
			}
		}
	}
	return 0;
}

public int Store_MenuItem(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			if(choice == MenuCancel_ExitBack)
			{
				Item item;
				menu.GetItem(0, item.Name, sizeof(item.Name));
				StoreItems.GetArray(StringToInt(item.Name), item);
				MenuPage(client, item.Section);
			}
			/*
			else if(choice != MenuCancel_Disconnected)
			{
				StopSound(client, SNDCHAN_STATIC, "#items/tf_music_upgrade_machine.wav");
			}
			*/
		}
		case MenuAction_Select:
		{
			Item item;
			menu.GetItem(0, item.Name, sizeof(item.Name));
			int index = StringToInt(item.Name);
			StoreItems.GetArray(index, item);
			
			if(choice == 3)	// Sell
			{
				if(item.Owned[client])
				{
					ItemInfo info;
					item.GetItemInfo(item.Owned[client]-1, info);
					if(info.Cost) //make sure it even can be sold.
					{
						CashSpent[client] -= ItemSell(item, item.Owned[client], client);
						ClientCommand(client, "playgamesound \"mvm/mvm_money_pickup.wav\"");
					}
					
					item.Owned[client] = 0;
					if(item.Scaled[client] > 0)
						item.Scaled[client]--;
					
					StoreItems.SetArray(index, item);
					
					int slot = TF2_GetClassnameSlot(info.Classname);
					if(Equipped[client][slot] == index) //No bugging out >:(((((((((((((((((
					{
						Equipped[client][slot] = -1;
						Store_ApplyAttribs(client);
						Store_GiveAll(client, GetClientHealth(client));	
					}
				}
			}
			if(choice == 2) //
			{
				if(item.Owned[client]) //item.TextStore[0]
				{
					int active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")
					{
						if(GetEntPropFloat(active_weapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime())
						{
							ItemInfo info;
							item.GetItemInfo(item.Owned[client]-1, info);
							int slot = TF2_GetClassnameSlot(info.Classname);
							if(Equipped[client][slot] == index)
							{
								Equipped[client][slot] = -1;
								StoreItems.SetArray(index, item);
							}
							else if(!info.Classname[0] && !info.Cost) //make sure it even can be sold.
							{
								item.Owned[client] = 0;
								if(--item.Scaled[client] < 0)
									item.Scaled[client] = 0;
								
								StoreItems.SetArray(index, item);
							}
							Store_ApplyAttribs(client);
							Store_GiveAll(client, GetClientHealth(client));	
						}
						else
						{
							ClientCommand(client, "playgamesound items/medshotno1.wav");	
						}
					}
				}
			}
			else if (choice == 1)
			{
				int cash = CurrentCash-CashSpent[client];
				int level = item.Owned[client]-1;
				if(level < 0)
					level = 0;
				
				ItemInfo info;
				item.GetItemInfo(level, info);
				int slot = TF2_GetClassnameSlot(info.Classname);
				if(slot < sizeof(Equipped[]) && Equipped[client][slot] == index)
				{
					int cost = AmmoData[info.Ammo][0];
					cost *= 10;
					if(!EscapeMode && info.Ammo && info.Ammo < Ammo_MAX && cost <= cash)
					{
						CashSpent[client] += cost;
						ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
						int ammo = GetAmmo(client, info.Ammo)+AmmoData[info.Ammo][1]*10;
						SetAmmo(client, info.Ammo, ammo);
						CurrentAmmo[client][info.Ammo] = ammo;
					}
				}
				
			}
			else if (choice == 0)
			{
				int cash = CurrentCash-CashSpent[client];
				
				if(NPCOnly[client] == 2)
				{
					ItemInfo info;
					item.GetItemInfo(0, info);
					
					int sell = RoundToCeil(float(info.Cost) * SELL_AMOUNT);
					ItemCost(client, item, info.Cost);
					if(!item.NPCWeaponAlways)
						info.Cost -= NPCCash[client];
					
					if(info.Cost <= cash)
					{
						int entity = EntRefToEntIndex(NPCTarget[client]);
						if(entity != INVALID_ENT_REFERENCE)
						{
							if(Citizen_UpdateWeaponStats(entity, item.NPCWeapon, sell, info))
							{
								CashSpent[client] += info.Cost;
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
								
								if(!item.NPCWeaponAlways)
								{
									for(int i = 1; i <= MaxClients; i++)
									{
										if(GetClientMenu(i) && NPCOnly[i] == 2 && NPCTarget[client] == NPCTarget[i])
										{
											CancelClientMenu(i);
											NPCTarget[i] = -1;
										}
									}
									return 0;
								}
								else
								{
									int client_previously = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
									if(IsValidClient(client_previously) && client_previously != client)
									{
										//Give them some their money back! Some other person just override theirs, i dont think they should be punished for that.......
										//BUT ONLY IF ITS ACTUALLY A DIFFERENT CLIENT. :(
										int money_back = RoundToCeil(float(i_ThisEntityHasAMachineThatBelongsToClientMoney[entity]) * 0.7);
										SetGlobalTransTarget(client_previously);
										PrintToChat(client_previously, "%t","You got your money back npc", money_back);
										CashSpent[client_previously] -= money_back;
										i_ThisEntityHasAMachineThatBelongsToClientMoney[entity] = 0;
										
									}
									i_ThisEntityHasAMachineThatBelongsToClient[entity] = GetClientUserId(client);
									i_ThisEntityHasAMachineThatBelongsToClientMoney[entity] = info.Cost;
								}
							}
						}
					}
				}
				else
				{
					int level = item.Owned[client]-1;
					if(level < 0)
						level = 0;
					
					ItemInfo info;
					item.GetItemInfo(level, info);
					int slot = TF2_GetClassnameSlot(info.Classname);
					if(slot < sizeof(Equipped[]) && Equipped[client][slot] == index)
					{
						int cost = AmmoData[info.Ammo][0];
						if(!EscapeMode && info.Ammo && info.Ammo < Ammo_MAX && cost <= cash)
						{
							CashSpent[client] += cost;
							ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							int ammo = GetAmmo(client, info.Ammo)+AmmoData[info.Ammo][1];
							SetAmmo(client, info.Ammo, ammo);
							CurrentAmmo[client][info.Ammo] = ammo;
						}
					}
					
					else if(info.Classname[0])
					{
						if(!item.Owned[client])
						{
							ItemCost(client, item, info.Cost);
							if(info.Cost <= cash)
							{
								CashSpent[client] += info.Cost;
								item.Owned[client] = 1;
								item.Scaled[client]++;
								if(item.MaxScaled < item.Scaled[client])
								{
									item.Scaled[client] = item.MaxScaled;
								}
								StoreItems.SetArray(index, item);
								
								if(info.FuncOnBuy != INVALID_FUNCTION)
								{
									Call_StartFunction(null, info.FuncOnBuy);
									Call_PushCell(client);
									Call_Finish();
								}
								
								if(info.Cost)
									ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							}
						}
						
						if(item.Owned[client])
						{
							Equipped[client][slot] = index;
							if(!TeutonType[client])
							{
								TF2_RemoveWeaponSlot(client, slot);
								Store_GiveItem(client, slot);
								Manual_Impulse_101(client, GetClientHealth(client));
							}
						}
					}
					else if(!item.Owned[client])
					{
						ItemCost(client, item, info.Cost);
						if(info.Cost <= cash)
						{
							CashSpent[client] += info.Cost;
							item.Owned[client] = 1;
							item.Scaled[client]++;
							if(item.MaxScaled < item.Scaled[client])
							{
								item.Scaled[client] = item.MaxScaled;
							}
							StoreItems.SetArray(index, item);
							if(info.Cost)
								ClientCommand(client, "playgamesound \"mvm/mvm_bought_upgrade.wav\"");
							
							if(info.FuncOnBuy != INVALID_FUNCTION)
							{
								Call_StartFunction(null, info.FuncOnBuy);
								Call_PushCell(client);
								Call_Finish();
							}
							
							if((info.Index < 0 || info.Index > 2) && info.Index < 6)
							{
								Store_ApplyAttribs(client);
						//		if(info.Index == 5)
						//			Building_IncreaseSentryLevel(client);
								
								if(info.Index == 4 || info.Index == 5)
								{
									for(info.Cost=0; info.Cost<info.Attribs; info.Cost++)
									{
										if(info.Attrib[info.Cost] == 286)
										{
											cash = MaxClients+1;
											while((cash=FindEntityByClassname(cash, "obj_*")) != -1)
											{
												if(GetEntPropEnt(cash, Prop_Send, "m_hBuilder") == client)
												{
													SetEntProp(cash, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(cash, Prop_Data, "m_iMaxHealth")*info.Value[info.Cost]));
													SetEntProp(cash, Prop_Send, "m_iHealth", RoundFloat(GetEntProp(cash, Prop_Send, "m_iHealth")*info.Value[info.Cost]));
												}
											}
										}
									}
								}
							}
							else
							{
								Store_GiveAll(client, GetClientHealth(client));
							}
						}
					}
				}
			}
			
			MenuPage(client, index);
		}
	}
	return 0;
}

void Store_ApplyAttribs(int client)
{
	if(TeutonType[client] || !StoreItems)
		return;
	
	TF2Attrib_RemoveAll(client);
	
	#if defined NoSendProxyClass
	TFClassType ClassForStats = WeaponClass[client];
	#else
	TFClassType ClassForStats = CurrentClass[client];
	#endif
	
	StringMap map = new StringMap();
	int Extra_Juggernog_Hp = 0;
	if(i_CurrentEquippedPerk[client] == 2)
	{
		Extra_Juggernog_Hp = 100;
	}
	if(!EscapeMode)
		map.SetValue("26", -RemoveExtraHealth(ClassForStats) + Extra_Juggernog_Hp);		// Health
	else
		map.SetValue("26", -RemoveExtraHealth(ClassForStats) + 100 + Extra_Juggernog_Hp);		// Health
		
	map.SetValue("107", (RemoveExtraSpeed(ClassForStats) * 1.1));		// Move Speed and abit of extra
	map.SetValue("353", 1.0);											// No manual building pickup.
	map.SetValue("465", 10.0);											// x10 faster diepsner build
	map.SetValue("464", 10.0);											// x10 faster sentry build
	map.SetValue("740", 0.0);											// No Healing from mediguns, allow healing from pickups
	map.SetValue("397", 50.0);											// Ignore ally with shooting
	map.SetValue("169", 0.0);											// Complete sentrygun Immunity
//	map.SetValue("49", 0.0);											// Completly disable double jump as we dont even use this, client prediction babyyyy!!!
																		//... doesnt work on player, must be on weapon...
//	map.SetValue("124", 1.0);											// Make sentries minisentries (only works on melee's that are wrenches...)
//	map.SetValue("345", 0.0);											// No dispenser range
//	map.SetValue("732", 0.0);											// No dispenser metal gain


	int wave_count = Waves_GetRound() + 1;
	
	if(wave_count > 15 && wave_count < 30)
	{
		map.SetValue("252", 0.75);
	}
	else if(wave_count >= 30 && wave_count < 45)
	{
		map.SetValue("252", 0.65);
	}
	else if(wave_count >= 45 && wave_count < 60)
	{
		map.SetValue("252", 0.50);
	}
	else if(wave_count >= 60)
	{
		map.SetValue("252", 0.40);
	}
	
	if(EscapeMode)	//infinite ammo stuff
	{
		map.SetValue("252", 0.50);
		map.SetValue("76", 10.0); //inf ammo
		map.SetValue("78", 10.0); //inf ammo
		map.SetValue("112", 100.0); //inf ammo
		map.SetValue("113", 50.0); //inf ammo
		map.SetValue("701", 100.0); //Armor level
		map.SetValue("258", 1.0); //Cash equals Health!!!!
	}
	if(i_CurrentEquippedPerk[client] == 4)
	{
//		map.SetValue("96", 0.1); //Cash equals Health!!!!
		map.SetValue("178", 0.65); //Faster Weapon Switch
	}
	if(TF2_GetPlayerClass(client) == TFClass_Scout) //make scout have the same capture rate!
	{
		map.SetValue("68", 1.0);
	}
	else
	{
		map.SetValue("68", 2.0);
	}
	
	//DOUBLE TAP!
	if(i_CurrentEquippedPerk[client] == 3) //Increace sentry damage! Not attack rate, could end ugly.
	{		
		map.SetValue("287", 1.15);
	}
		
	Item item;
	ItemInfo info;
	float value;
	char buffer1[12], buffer2[32];
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Owned[client])
		{
			item.GetItemInfo(item.Owned[client]-1, info);
			if(!info.Classname[0] && (info.Index<0 || info.Index>2) && info.Index<6)
			{
				for(int a; a<info.Attribs; a++)
				{
					IntToString(info.Attrib[a], buffer1, sizeof(buffer1));
					if(!map.GetValue(buffer1, value))
					{
						map.SetValue(buffer1, info.Value[a]);
					}
					else if(info.Attrib[a]==26 || (TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", buffer2, sizeof(buffer2)) && StrContains(buffer2, "additive")!=-1))
					{
						map.SetValue(buffer1, value + info.Value[a]);
					}
					else
					{
						map.SetValue(buffer1, value * info.Value[a]);
					}
				}
			}
		}
	}
	
	
	
	
	
	Armor_Level[client] = 0;
	Jesus_Blessing[client] = 0;
	i_HeadshotAffinity[client] = 0;
	i_BarbariansMind[client] = 0;
	i_SoftShoes[client] = 0;
	i_BadHealthRegen[client] = 0;
	
	StringMapSnapshot snapshot = map.Snapshot();
	int entity = client;
	length = snapshot.Length;
	for(int i; i<length; i++)
	{
		if(i && !(i % 16))
		{
			if(!TF2_GetWearable(client, entity))
				break;
			
		//	RemoveAllDefaultAttribsExceptStrings(entity);
			TF2Attrib_RemoveAll(entity);
		}
		
		snapshot.GetKey(i, buffer1, sizeof(buffer1));
		if(map.GetValue(buffer1, value))
		{
			int index = StringToInt(buffer1);
			TF2Attrib_SetByDefIndex(entity, index, value);
			
			
			if(index == 701)
				Armor_Level[client] = RoundToCeil(value);
				
			if(index == 777)
				Jesus_Blessing[client] = RoundToCeil(value);
				
			if(index == 785)
				i_HeadshotAffinity[client] = RoundToCeil(value);
				
			if(index == 830)
				i_BarbariansMind[client] = RoundToCeil(value);
				
			if(index == 527)
				i_SoftShoes[client] = RoundToCeil(value);
				
			if(index == 805)
				i_BadHealthRegen[client] = RoundToCeil(value);
		}
	}
	if(dieingstate[client] > 0)
	{
		TF2Attrib_SetByDefIndex(client, 489, 0.15);
	}
	delete map;
	delete snapshot;
	TF2_AddCondition(client, TFCond_Dazed, 0.001);
}

void Store_GiveAll(int client, int health)
{
	if(TeutonType[client])
	{
		TF2_RegeneratePlayer(client);
		return;
	}
	
	int weapon = GetPlayerWeaponSlot(client, 1); //Secondary
	if(IsValidEntity(weapon))
	{
		if(HasEntProp(weapon, Prop_Send, "m_flChargeLevel"))
		{
			f_MedigunChargeSave[client] = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
		}
	}
	
	TF2_RemoveAllWeapons(client);
	
	//RESET ALL CUSTOM VALUES! I DONT WANT TO KEEP USING ATTRIBS.
	SetAbilitySlotCount(client, 0);
	
	bool Was_phasing = false;
	
	if(b_PhaseThroughBuildingsPerma[client] == 2)
	{
		Was_phasing = true;
	}
	
	b_PhaseThroughBuildingsPerma[client] = 1;
	b_FaceStabber[client] = false;
	b_IsCannibal[client] = false;
	b_HasGlassBuilder[client] = false;
	
	if(!IsFakeClient(client) && Was_phasing)
	{
		SDKUnhook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
		SDKHook(client, SDKHook_PostThink, PhaseThroughOwnBuildings);
	}
						
	bool use = true;
	for(int i; i<sizeof(Equipped[]); i++)
	{
		Store_GiveItem(client, i, use);
	}
	
//	Spawn_Buildable(client);
//	TF2_SetPlayerClass(client, TFClass_Engineer, true, false);
	/*
	if(entity > MaxClients)
	{
		TF2_SetPlayerClass(client, TFClass_Engineer);
	}
	*/
	Manual_Impulse_101(client, health);
}

void Delete_Clip(int entity)
{
	if(IsValidEntity(entity))
	{
		RequestFrame(Delete_Clip_again, entity);
		int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		
		if(ammo > 0)
		{
			SetEntData(entity, iAmmoTable, 0);
		}
		SetEntProp(entity, Prop_Send, "m_iClip1", 0); // weapon clip amount bullets
	}
}

void Delete_Clip_again(int entity)
{
	if(IsValidEntity(entity))
	{
		int iAmmoTable = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
		int ammo = GetEntData(entity, iAmmoTable, 4);
		
		if(ammo > 0)
		{
			SetEntData(entity, iAmmoTable, 0);
		}
		SetEntProp(entity, Prop_Send, "m_iClip1", 0); // weapon clip amount bullets
	}
}

int Store_GiveItem(int client, int slot, bool &use=true)
{
	if(!StoreItems)
		return -1;
		
		
	
	Item item;
	int entity = -1;
	int length = StoreItems.Length;
	if(Equipped[client][slot] > 0 && Equipped[client][slot] < length)
	{
		StoreItems.GetArray(Equipped[client][slot], item);
		if(item.Owned[client] > 0)
		{
			ItemInfo info;
			item.GetItemInfo(item.Owned[client]-1, info);
			if(info.Classname[0])
			{
				if(info.SniperBugged && CurrentClass[client] == TFClass_Sniper)
				{
					CurrentClass[client] = TFClass_Soldier;
					TF2_RegeneratePlayer(client);
					return -1;
				}
				
				entity = SpawnWeapon(client, info.Classname, info.Index, 5, 6, info.Attrib, info.Value, info.Attribs);
				
				i_CustomWeaponEquipLogic[entity] = 0;
				i_SemiAutoWeapon[entity] = false;
				i_WeaponCannotHeadshot[entity] = false;
				
				if(entity > MaxClients)
				{
					
					if(info.CustomWeaponOnEquip != 0)
					{
						i_CustomWeaponEquipLogic[entity] = info.CustomWeaponOnEquip;
					}
					if(info.Ammo > 0)
					{
						if(!StrEqual(info.Classname[0], "tf_weapon_medigun"))
						{
							if(!StrEqual(info.Classname[0], "tf_weapon_particle_cannon"))
							{
								if(info.Ammo == 30)
								{
									SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", -1);
								}
								else
								{
									if(!info.HasNoClip)
									{
										RequestFrame(Delete_Clip, entity);
										Delete_Clip(entity);
									}
									if(info.NoHeadshot)
									{
										i_WeaponCannotHeadshot[entity] = true;
									}
									if(info.SemiAuto)
									{
										i_SemiAutoWeapon[entity] = true;
										int slot_weapon_ammo = TF2_GetClassnameSlot(info.Classname);
										
										i_SemiAutoWeapon_AmmoCount[client][slot_weapon_ammo] = 0; //Set the ammo to 0 so they cant abuse it.
										
										f_SemiAutoStats_FireRate[entity] = info.SemiAutoStats_FireRate;
										i_SemiAutoStats_MaxAmmo[entity] = info.SemiAutoStats_MaxAmmo;
										f_SemiAutoStats_ReloadTime[entity] = info.SemiAutoStats_ReloadTime;
	
									}
									
									if(!EscapeMode || info.Ammo < 3) //my man broke my shit.
									{
										SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", info.Ammo);
									}
									else if(info.Ammo == 24 || info.Ammo == 6)
									{
										SetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType", info.Ammo);	
									}
								}
							}
						}
						//CANT USE AMMO 1 or 2 or something, just use 30 LMAO
						//Allows you to switch to the weapon even though it has no ammo, there is PROOOOOOOOOOOOOOOOOOOBAABLY no weapon in the game that actually uses this
						//IF IT DOES!!! then make an exception, but as far as i know, no need.	
						
						if(info.Ammo != Ammo_Hand_Grenade && info.Ammo != Ammo_Potion_Supply) //Excluding Grenades and other chargeable stuff so you cant switch to them if they arent even ready. cus it makes no sense to have it in your hand
						{
							//IT MUST BE 30, ANYTHING ELSE CRASHES OR DOESNT WORK!!!!!!!!!!!!!!!!
							SetAmmo(client, 30, 99999);
							SetEntProp(entity, Prop_Send, "m_iSecondaryAmmoType", 30);
						}
					}
					
					i_Hex_WeaponUsesTheseAbilities[entity] = 0;
		
					if(info.FuncAttack != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M1; //m1 status to weapon
					}
					if(info.FuncAttack2 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M2; //m2 status to weapon
					}
					if(info.FuncAttack3 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_R;  //R status to weapon
					}
					
					EntityFuncAttack[entity] = info.FuncAttack;
					EntityFuncAttack2[entity] = info.FuncAttack2;
					EntityFuncAttack3[entity] = info.FuncAttack3;
					EntityFuncReload4[entity]  = info.FuncReload4;
					
					b_Do_Not_Compensate[entity] 				= info.NoLagComp;
					b_Only_Compensate_CollisionBox[entity] 		= info.OnlyLagCompCollision;
					b_Only_Compensate_AwayPlayers[entity]		= info.OnlyLagCompAwayEnemy;
					b_ExtendBoundingBox[entity]		 			= info.ExtendBoundingBox;
					b_Dont_Move_Building[entity] 				= info.DontMoveBuildingComp;
					
					b_Dont_Move_Allied_Npc[entity]				= info.DontMoveAlliedNpcs;
					
					b_BlockLagCompInternal[entity] 				= info.BlockLagCompInternal;
					
				//	EntityFuncReloadSingular5[entity]  = info.FuncReloadSingular5;
					if (info.Reload_ModeForce == 1)
					{
					//	SetWeaponViewPunch(entity, 100.0); unused.
						SetEntProp(entity, Prop_Data, "m_bReloadsSingly", 0);
					}
					else if (info.Reload_ModeForce == 2)
					{
						SetEntProp(entity, Prop_Data, "m_bReloadsSingly", 1);
					}
					if(use)
					{
						FakeClientCommand(client, "use %s", info.Classname);
						use = false;
					}
				}
			}
		}
	}
	else if(slot == TFWeaponSlot_Melee)
	{
		static char Classnames[][32] = {"tf_weapon_shovel", "tf_weapon_bat", "tf_weapon_club", "tf_weapon_shovel",
		"tf_weapon_bottle", "tf_weapon_bonesaw", "tf_weapon_fists", "tf_weapon_fireaxe", "tf_weapon_knife", "tf_weapon_wrench"};
		
		entity = CreateEntityByName(Classnames[CurrentClass[client]]);
		if(entity > MaxClients)
		{
			static const int Indexes[] = { 6, 0, 3, 6, 1, 8, 5, 2, 4, 7 };
			SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", Indexes[CurrentClass[client]]);
			SetEntProp(entity, Prop_Send, "m_bInitialized", 1);
			
			SetEntProp(entity, Prop_Send, "m_iEntityQuality", 0);
			SetEntProp(entity, Prop_Send, "m_iEntityLevel", 1);
			
			GetEntityNetClass(entity, Classnames[0], sizeof(Classnames[]));
			int offset = FindSendPropInfo(Classnames[0], "m_iItemIDHigh");
			
			SetEntData(entity, offset - 8, 0);	// m_iItemID
			SetEntData(entity, offset - 4, 0);	// m_iItemID
			SetEntData(entity, offset, 0);		// m_iItemIDHigh
			SetEntData(entity, offset + 4, 0);	// m_iItemIDLow
			
			DispatchSpawn(entity);
			SetEntProp(entity, Prop_Send, "m_bValidatedAttachedEntity", true);
			SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(client, false));
			
			TF2Attrib_SetByDefIndex(entity, 1, 0.623);
		//	TF2Attrib_SetByDefIndex(entity, 124, 1.0); //Mini sentry
			
			if(CurrentClass[client] != TFClass_Spy)
				TF2Attrib_SetByDefIndex(entity, 15, 0.0);
			
			if(CurrentClass[client] == TFClass_Engineer)
			{
				TF2Attrib_SetByDefIndex(entity, 93, 0.0);
				TF2Attrib_SetByDefIndex(entity, 95, 0.0);
				TF2Attrib_SetByDefIndex(entity, 2043, 0.0);
			}
			TF2Attrib_SetByDefIndex(entity, 263, 0.0);
			TF2Attrib_SetByDefIndex(entity, 264, 0.0);
			EquipPlayerWeapon(client, entity);
			
			if(use)
			{
				FakeClientCommand(client, "use %s", Classnames[CurrentClass[client]]);
				use = false;
			}
		}
	}
	
	bool EntityIsAWeapon = false;
	if(entity > MaxClients)
	{
		EntityIsAWeapon = true;
	}
	if(EntityIsAWeapon)
	{
		Panic_Attack[entity] = 0.0;
		Mana_Regen_Level[entity] = 0.0;
		i_GlitchedGun[entity] = 0;
		i_SurvivalKnifeCount[entity] = 0;
		i_AresenalTrap[entity] = 0;
		i_ArsenalBombImplanter[entity] = 0;
		i_NoBonusRange[entity] = 0;
		i_BuffBannerPassively[entity] = 0;
	}
	if(!TeutonType[client])
	{
		ItemInfo info;
		for(int i; i<length; i++)
		{
			StoreItems.GetArray(i, item);
			if(item.Owned[client])
			{
				item.GetItemInfo(item.Owned[client]-1, info);
				if(!info.Classname[0])
				{
					if(info.Attack3AbilitySlot != 0)
					{
						SetAbilitySlotCount(client, info.Attack3AbilitySlot);
					}
					if(info.SpecialAdditionViaNonAttribute == 1)
					{
						b_PhaseThroughBuildingsPerma[client] = 2; //Set to true if its 1, other attribs will use other things!
					}
					if(info.SpecialAdditionViaNonAttribute == 2) //stabbb
					{
						b_FaceStabber[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 3) //eated it all
					{
						b_IsCannibal[client] = true;
					}
					if(info.SpecialAdditionViaNonAttribute == 4) //Glass Builder
					{
						b_HasGlassBuilder[client] = true;
					}
					if(EntityIsAWeapon)
					{
						switch(info.Index)
						{
							case 0, 1, 2:
							{
								if(info.Index != slot || (IsWandWeapon(entity) && !IsEngineerWeapon(entity)))
									continue;
							}
							case 6:
							{
								if(slot != TFWeaponSlot_Melee && slot != TFWeaponSlot_Secondary || (IsWandWeapon(entity) && !IsEngineerWeapon(entity)))
									continue;
							}
							case 7:
							{
								if(slot != TFWeaponSlot_Secondary && slot != TFWeaponSlot_Primary || (IsWandWeapon(entity) && !IsEngineerWeapon(entity)))
									continue;
							}
							case 8:
							{
								if(slot != TFWeaponSlot_Melee || (!IsWandWeapon(entity) && !IsEngineerWeapon(entity)))
								{
									continue;
								}
							}
							case 9:
							{
								
							}
							default:
							{
								continue;
							}
						}
						
						for(int a; a<info.Attribs; a++)
						{
							Address address = TF2Attrib_GetByDefIndex(entity, info.Attrib[a]);
							if(address == Address_Null)
							{
								TF2Attrib_SetByDefIndex(entity, info.Attrib[a], info.Value[a]);
							}
							else if(TF2Econ_GetAttributeDefinitionString(info.Attrib[a], "description_format", info.Classname, sizeof(info.Classname)) && StrContains(info.Classname, "additive")!=-1)
							{
								TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) + info.Value[a]);
							}
							else
							{
								TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * info.Value[a]);
							}
						}
					}
				}
			}
		}
	}
	if(EntityIsAWeapon)
	{
		//SPEED COLA!
		if(i_CurrentEquippedPerk[client] == 4)
		{
			Address address = TF2Attrib_GetByDefIndex(entity, 97);
			if(address == Address_Null)
			{
				TF2Attrib_SetByDefIndex(entity, 97, 0.65);
			}
			else
			{
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * 0.65);
			}
		}
		//DOUBLE TAP!
		if(i_CurrentEquippedPerk[client] == 3)
		{		
			Address address = TF2Attrib_GetByDefIndex(entity, 6);
			if(address == Address_Null)
			{
				TF2Attrib_SetByDefIndex(entity, 6, 0.85);
			}
			else
			{
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * 0.85);
			}
		}
		//DEADSHOT!
		if(i_CurrentEquippedPerk[client] == 5)
		{		
			Address address = TF2Attrib_GetByDefIndex(entity, 106);
			if(address == Address_Null)
			{
				TF2Attrib_SetByDefIndex(entity, 106, 0.65);
			}
			else
			{
				TF2Attrib_SetValue(address, TF2Attrib_GetValue(address) * 0.65);
			}
		}
		
		int itemdefindex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
		if(itemdefindex == 772 || itemdefindex == 349 || itemdefindex == 30667 || itemdefindex == 200 || itemdefindex == 45 || itemdefindex == 449 || itemdefindex == 773 || itemdefindex == 973 || itemdefindex == 1103 || itemdefindex == 669 || IsWandWeapon(entity))
		{		
			TF2Attrib_SetByDefIndex(entity, 49, 1.0);
		}
		
		/*
			Attributes to Arrays Here
		*/
		Panic_Attack[entity] = Attributes_FindOnWeapon(client, entity, 651);
		Mana_Regen_Level[entity] = Attributes_FindOnWeapon(client, entity, 405);
		i_SurvivalKnifeCount[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 33));
		i_GlitchedGun[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 731));
		i_AresenalTrap[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 719));
		i_ArsenalBombImplanter[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 544));
		i_NoBonusRange[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 410));
		i_BuffBannerPassively[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 786));
		
		i_LowTeslarStaff[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 3002));
		i_HighTeslarStaff[entity] = RoundToCeil(Attributes_FindOnWeapon(client, entity, 3000));
		
		Enable_Management(client, entity);
		Enable_Arsenal(client, entity);
		On_Glitched_Give(client, entity);
		Enable_Management_Banner(client, entity);
		
		Enable_StarShooter(client, entity);
	}
	return entity;
}

int Store_GiveSpecificItem(int client, const char[] name)
{
	Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(StrEqual(name, item.Name, false))
		{
			ItemInfo info;
			item.GetItemInfo(0, info);
			int entity = -1;
			int slot = TF2_GetClassnameSlot(info.Classname);
			if(slot < sizeof(Equipped[]))
			{
				int lastEquipped = Equipped[client][slot];
				int lastOwned = item.Owned[client];
				
				Equipped[client][slot] = i;
				item.Owned[client] = 1;
				StoreItems.SetArray(i, item);
				
				entity = Store_GiveItem(client, slot);
				
				Equipped[client][slot] = lastEquipped;
				item.Owned[client] = lastOwned;
				StoreItems.SetArray(i, item);
			}
			return entity;
		}
	}
	
	ThrowError("Unknown item name %s", name);
	return 0;
}

bool Store_Interact(int client, int entity, const char[] classname)
{
	if(!TeutonType[client] && GameRules_GetRoundState() <= RoundState_RoundRunning && StrEqual(classname, "prop_dynamic"))
	{
		char buffer[64];
		GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer))
		if(!StrContains(buffer, "zr_weapon_", false))
		{
			int index = GetEntProp(entity, Prop_Send, "m_nSkin");
			if(index > 0 && index < StoreItems.Length)
			{
				Item item;
				StoreItems.GetArray(index, item);
				
				ItemInfo info;
				int level = GetEntProp(entity, Prop_Send, "m_nBody");
				if(item.GetItemInfo(level, info))
				{
					if(info.Classname[0])
					{
						int last = item.Owned[client] - 1;
						if(last != level)
						{
							item.Owned[client] = level+1;
							StoreItems.SetArray(index, item);
							ClientCommand(client, "playgamesound \"ui/item_heavy_gun_pickup.wav\"");
						}
						
						int slot = TF2_GetClassnameSlot(info.Classname);
						if(slot >= 0 && slot < sizeof(Equipped[]))
						{
							if(Equipped[client][slot] == -1)
							{
								if(Waves_Started())
									RemoveEntity(entity);
							}
							else if(!Waves_Started())
							{
								if(Equipped[client][slot] != index)
								{
									StoreItems.GetArray(Equipped[client][slot], item);
									item.Owned[client] = 0;
									StoreItems.SetArray(Equipped[client][slot], item);
								}
							}
							else
							{
								if(Equipped[client][slot] != index)
								{
									StoreItems.GetArray(Equipped[client][slot], item);
									last = item.Owned[client] - 1;
									if(last < 0)
										last = 0;
									
									item.Owned[client] = 0;
									StoreItems.SetArray(Equipped[client][slot], item);
								}
								
								item.GetItemInfo(last, info);
								if(info.Model[0])
									SetEntityModel(entity, info.Model);
								
								SetEntProp(entity, Prop_Send, "m_nSkin", Equipped[client][slot]);
								SetEntProp(entity, Prop_Send, "m_nBody", last);
								
								int tier = info.Tier;
								if(tier >= sizeof(RenderColors))
									tier = sizeof(RenderColors)-1;
								
								if(tier < 0)
								{
									tier = 0;
								}
								
								SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
								SetEntityRenderColor(entity, RenderColors[tier][0], RenderColors[tier][1], RenderColors[tier][2], RenderColors[tier][3]);
							}
							
							Equipped[client][slot] = index;
							if(!TeutonType[client])
							{
								TF2_RemoveWeaponSlot(client, slot);
								Store_GiveItem(client, slot);
								Manual_Impulse_101(client, GetClientHealth(client));
							}
						}
						return true;
					}
					else if(!item.Owned[client])
					{
						item.Owned[client] = level+1;
						StoreItems.SetArray(index, item);
						ClientCommand(client, "playgamesound \"items/powerup_pickup_base.wav\"");
						RemoveEntity(entity);
						
						if((info.Index < 0 || info.Index > 2) && info.Index < 6)
						{
							Store_ApplyAttribs(client);
						//	if(info.Index == 5)
						//		Building_IncreaseSentryLevel(client);
							
							if(info.Index == 4 || info.Index == 5)
							{
								for(int i; i<info.Attribs; i++)
								{
									if(info.Attrib[i] == 286)
									{
										int ent = MaxClients+1;
										while((ent=FindEntityByClassname(ent, "obj_*")) != -1)
										{
											if(GetEntPropEnt(ent, Prop_Send, "m_hBuilder") == client)
											{
												SetEntProp(ent, Prop_Data, "m_iMaxHealth", RoundFloat(GetEntProp(ent, Prop_Data, "m_iMaxHealth")*info.Value[i]));
												SetEntProp(ent, Prop_Send, "m_iHealth", RoundFloat(GetEntProp(ent, Prop_Send, "m_iHealth")*info.Value[i]));
											}
										}
									}
								}
							}
						}
						else
						{
							Store_GiveAll(client, GetClientHealth(client));
						}
						return true;
					}
				}
			}
		}
	}
	return false;
}

void Store_ConsumeItem(int client, int slot)
{
	if(Equipped[client][slot] > 0 && Equipped[client][slot] < StoreItems.Length)
	{
		Item item;
		StoreItems.GetArray(Equipped[client][slot], item);
		item.Owned[client] = 0;
		StoreItems.SetArray(Equipped[client][slot], item);
		Equipped[client][slot] = -1;
		TF2_RemoveWeaponSlot(client, slot);
	}
}

bool Store_PrintLevelItems(int client, int level)
{
	bool found;
	Item item;
	int length = StoreItems.Length;
	for(int i; i<length; i++)
	{
		StoreItems.GetArray(i, item);
		if(item.Level == level)
		{
			PrintToChat(client, item.Name);
			found = true;
		}
	}
	return found;
}

char[] TranslateItemName(int client, const char name[64])
{
	static int ServerLang = -1;
	if(ServerLang == -1)
		ServerLang = GetServerLanguage();
	
	if(GetClientLanguage(client) != ServerLang)
	{
		if(TranslationPhraseExists(name))
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "%T", name, client);
			return buffer;
		}
	}
	return name;
}

static void ItemCost(int client, Item item, int &cost)
{
	bool started = Waves_Started();
	bool GregSale = false;

	//these should account for selling.
	cost += item.Scale*item.Scaled[client]; 
	cost += item.CostPerWave * CurrentRound;
	
	int original_cost_With_Sell = RoundToCeil(float(cost) * SELL_AMOUNT);
	
	//make sure anything thats additive is on the top, so sales actually help!!
	if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
	{
		if(b_SpecialGrigoriStore) //during maps where he alaways sells, always sell!
		{
			if(item.NPCSeller_First)
			{
				cost = RoundToCeil(float(cost) * 0.7);
			}
			else if(item.NPCSeller)
			{
				cost = RoundToCeil(float(cost) * 0.8);
			}
			
			if(item.NPCSeller)
				GregSale = true;
		}
	}
	if(!started && !GregSale)
	{
		if(CurrentRound < 2)
		{
			cost = RoundToCeil(float(cost) * 0.7);	
		}
		else
		{
			if(IsValidEntity(EntRefToEntIndex(SalesmanAlive)))
			{
				if(item.NPCSeller_First)
				{
					cost = RoundToCeil(float(cost) * 0.7);
				}
				else if(item.NPCSeller)
				{
					cost = RoundToCeil(float(cost) * 0.8);
				}
				else
				{
					cost = RoundToCeil(float(cost) * 0.9);	
				}
			}
			else
			{
				cost = RoundToCeil(float(cost) * 0.9);	
			}
		}

	}
	
	float discount = Building_GetDiscount();
	if(discount != 1.0)
		cost = RoundToNearest(float(cost) * discount);
	
	if((CurrentRound != 0 || CurrentWave != -1) && cost)
	{
		if(!CurrentPlayers)
			CheckAlivePlayers();
		
		if(CurrentPlayers == 1)
			cost = RoundToNearest(float(cost) * 0.7);
			
		if(CurrentPlayers == 2)
			cost = RoundToNearest(float(cost) * 0.8);
			
		else if(CurrentPlayers == 3)
			cost = RoundToNearest(float(cost) * 0.9);
			
	}
	
	//Keep this here, both of these make sure that the item doesnt go into infinite cost, and so it doesnt go below the sell value, no inf money bug!
	if(item.MaxCost > 0 && cost > item.MaxCost)
	{
		cost = item.MaxCost;
	}
	if(cost < original_cost_With_Sell)
	{
		cost = original_cost_With_Sell;
	}
}

static int ItemSell(Item item, int level, int client)
{
	int sell;
	
	ItemInfo info;
	for(int i; i<level && item.GetItemInfo(i, info); i++)
	{
		sell += info.Cost;
		sell += item.Scale * item.Scaled[client]; 
		sell += item.CostPerWave * CurrentRound;
	}
	
	return RoundToCeil(float(sell) * SELL_AMOUNT);
}

bool Store_Girogi_Interact(int client, int entity, const char[] classname, bool Is_Reload_Button = false)
{
	if(Is_Reload_Button)
	{
		if(IsValidEntity(entity))
		{
			if(StrEqual(classname, "base_boss"))
			{
				static char buffer[36];
				GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
				if(StrEqual(buffer, "zr_grigori"))
				{
					if(!Waves_Started() || b_SpecialGrigoriStore)
					{
						Store_OpenNPCStore(client);
					}
					else
					{
						PrintHintText(client,"%t", "Father Grigori No Talk");
					}
					return true;
				}
			}
		}
	}
	return false;
	
}