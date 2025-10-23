
#define GIFT_MODEL "models/items/tf_gift.mdl"

#define GIFT_CHANCE 0.35 //Extra rare cus alot of zobies

#define SOUND_BEEP			"buttons/button17.wav"


static const char Categories[][] =
{
	"Current Enemies Alive",
	"Allies",
	"Special Enemies",
	"Raid Bosses",
	"Common Infection",
	"Blitz Controlled",
	"Xeno Infection",
	"Bloons",
	"Medieval Empire",
	"Cry of Fear",
	"Seaborn Infection",
	"Expidonsa",
	"Interitus Alliances",
	"Chaos Allience",
	"Voided Subjects",
	"Ruina",
	"Iberia Expidonsa Alliance",
	"Whiteflower Specials",
	"Victoria",
	"Matrix",
	"Aperture",
	"Mutations",
	"Curtain Occupants",
};

enum struct GiftItem
{
	char Name[64];
	int Rarity;
}

enum struct OwnedItem
{
	int Client;
	int Level;
	int Flags;
}

static ArrayList GiftItems;
static ArrayList OwnedItems;
static ArrayList PreviousItems;
static int CategoryPage[MAXPLAYERS];

static int g_BeamIndex = -1;
static ZRGiftRarity i_RarityType[MAXENTITIES];
static float f_IncreaseChanceManually = 1.0;
static bool b_ForceSpawnNextTime;

void Items_PluginStart()
{
	for(int i=0; i<=MaxClients; i++)
	{
		CategoryPage[i] = -2;
	}
	OwnedItems = new ArrayList(sizeof(OwnedItem));
	PreviousItems = new ArrayList(sizeof(OwnedItem));
	RegAdminCmd("zr_give_item", Items_GiveCmd, ADMFLAG_RCON);
	RegAdminCmd("zr_give_allitems", Items_GiveAllCmd, ADMFLAG_RCON);
	RegAdminCmd("zr_remove_allitems", Items_RemoveAllCmd, ADMFLAG_RCON);
}

void Items_SetupConfig()
{
	delete GiftItems;
	GiftItems = new ArrayList(sizeof(GiftItem));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "giftitems");

	KeyValues kv = new KeyValues("GiftItems");
	kv.ImportFromFile(buffer);
	kv.GotoFirstSubKey();
	
	GiftItem item;
	do	// TODO: Replace ArrayList with IntMap
	{
		kv.GetSectionName(item.Name, sizeof(item.Name));
		int index = StringToInt(item.Name);

		item.Name[0] = 0;
		item.Rarity = -1;
		while(GiftItems.Length < index)
		{
			GiftItems.PushArray(item);
		}

		kv.GetString("name", item.Name, sizeof(item.Name));
		item.Rarity = kv.GetNum("rarity", -1);
		if(GiftItems.Length == index)
		{
			GiftItems.PushArray(item);
		}
		else
		{
			GiftItems.SetArray(index, item);
		}
	}
	while(kv.GotoNextKey());

	delete kv;
}

void Items_ClearArray(int client)
{
	int id;
	while((id = OwnedItems.FindValue(client, OwnedItem::Client)) != -1)
	{
		OwnedItems.Erase(id);
	}

	while((id = PreviousItems.FindValue(client, OwnedItem::Client)) != -1)
	{
		PreviousItems.Erase(id);
	}
}

void Items_AddArray(int client, int level, int flags)
{
	if(flags && level >= 0)
	{
		static OwnedItem owned;
		owned.Client = client;
		owned.Level = level;
		owned.Flags = flags;
		OwnedItems.PushArray(owned);
		PreviousItems.PushArray(owned);
	}
}

bool Items_GetNextItem(int client, int &i, int &level, int &flags, bool &newEntry)
{
	int length1 = OwnedItems.Length;
	int length2 = PreviousItems.Length;
	for(; i < length1; i++)
	{
		static OwnedItem owned;
		OwnedItems.GetArray(i, owned);
		if(owned.Client == client)
		{
			newEntry = true;
			bool same;

			for(int b; b < length2; b++)
			{
				static OwnedItem previous;
				PreviousItems.GetArray(b, previous);
				if(previous.Client == client && previous.Level == owned.Level)
				{
					if(previous.Flags == owned.Flags)
					{
						same = true;
					}
					else
					{
						newEntry = false;
					}

					break;
				}
			}

			if(same)
				continue;

			level = owned.Level;
			flags = owned.Flags;
			return true;
		}
	}

	return false;
}

public Action Items_GiveCmd(int client, int args)
{
	if(args > 1)
	{
		char targetName[MAX_TARGET_LENGTH];
		GetCmdArg(2, targetName, sizeof(targetName));
		
		int id = Items_NameToId(targetName);
		if(id == -1)
		{
			ReplyToCommand(client, "Invalid item name");
			return Plugin_Handled;
		}

		char pattern[PLATFORM_MAX_PATH];
		GetCmdArg(1, pattern, sizeof(pattern));

		int length;
		int targets[MAXPLAYERS];
		bool targetNounIsMultiLanguage;
		if((length=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage)) > 0)
		{
			for(int i; i < length; i++)
			{
				if(Items_HasIdItem(targets[i], id))
				{
					ReplyToCommand(client, "%N already has this item", targets[i]);
				}
				else
				{
					Items_GiveIdItem(targets[i], id);
					ReplyToCommand(client, "Gave %N this item", targets[i]);
				}
			}
		}
		else
		{
			ReplyToTargetError(client, length);
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: zr_give_item <client> <item name>");
	}
	return Plugin_Handled;
}

public Action Items_GiveAllCmd(int client, int args)
{
	if(args == 1)
	{
		char targetName[MAX_TARGET_LENGTH];

		char pattern[PLATFORM_MAX_PATH];
		GetCmdArg(1, pattern, sizeof(pattern));

		int length;
		int targets[MAXPLAYERS];
		bool targetNounIsMultiLanguage;
		if((length=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage)) > 0)
		{
			for(int i; i < length; i++)
			{
				int count;
				int length2 = GiftItems.Length;
				for(int id; id < length2; id++)
				{
					static GiftItem item;
					GiftItems.GetArray(id, item);
					if(StrContains(item.Name, "???") == -1)
					{
						if(!Items_HasIdItem(targets[i], id))
						{
							Items_GiveIdItem(targets[i], id);
							count++;
						}
					}
				}

				for(int id = length2; id < 255; id++)
				{
					if(!Items_HasIdItem(targets[i], id))
						Items_GiveIdItem(targets[i], id);
				}
				
				ReplyToCommand(client, "Gave %d items to %N", count, targets[i]);
			}
		}
		else
		{
			ReplyToTargetError(client, length);
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: zr_give_allitems <client>");
	}
	return Plugin_Handled;
}

public Action Items_RemoveAllCmd(int client, int args)
{
	if(args == 1)
	{
		char targetName[MAX_TARGET_LENGTH];

		char pattern[PLATFORM_MAX_PATH];
		GetCmdArg(1, pattern, sizeof(pattern));

		int length;
		int targets[MAXPLAYERS];
		bool targetNounIsMultiLanguage;
		if((length=ProcessTargetString(pattern, client, targets, sizeof(targets), COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_BOTS, targetName, sizeof(targetName), targetNounIsMultiLanguage)) > 0)
		{
			for(int i; i < length; i++)
			{
				Items_ClearArray(targets[i]);
				ReplyToCommand(client, "Remove %N items", targets[i]);
			}
		}
		else
		{
			ReplyToTargetError(client, length);
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Usage: zr_give_allitems <client>");
	}
	return Plugin_Handled;
}

static int GetFlagsOfLevel(int client, int level)
{
	int length = OwnedItems.Length;
	for(int i; i < length; i++)
	{
		static OwnedItem owned;
		OwnedItems.GetArray(i, owned);
		if(owned.Client == client && owned.Level == level)
		{
			return owned.Flags;
		}
	}
	
	return 0;
}

static bool AddFlagOfLevel(int client, int level, int flag)
{
	static OwnedItem owned;
	int length = OwnedItems.Length;
	for(int i; i < length; i++)
	{
		OwnedItems.GetArray(i, owned);
		if(owned.Client == client && owned.Level == level)
		{
			if(!(owned.Flags & flag))
			{
				owned.Flags += flag;
				OwnedItems.SetArray(i, owned);
				return true;
			}

			return false;
		}
	}
		
	owned.Client = client;
	owned.Level = level;
	owned.Flags = flag;

	OwnedItems.PushArray(owned);
	return true;
}

static int IdToFlag(int id)
{
	return (1 << (id % 31));
}

static int IdToLevel(int id)
{
	return (id / 31);
}

int Items_NameToId(const char[] name)
{
	int length = GiftItems.Length;
	for(int i; i < length; i++)
	{
		static GiftItem item;
		GiftItems.GetArray(i, item);
		if(StrEqual(item.Name, name, false))
			return i;
	}

	return -1;
}

bool Items_HasIdItem(int client, int id)
{
	return view_as<bool>(GetFlagsOfLevel(client, IdToLevel(id)) & IdToFlag(id));
}

bool Items_HasNamedItem(int client, const char[] name)
{
	if(name[0] && GiftItems)
	{
		int length = GiftItems.Length;
		for(int i; i < length; i++)
		{
			static GiftItem item;
			GiftItems.GetArray(i, item);
			if(StrEqual(item.Name, name, false))
			{
				if(client)
					return view_as<bool>(GetFlagsOfLevel(client, IdToLevel(i)) & IdToFlag(i));
				
				for(int target = 1; target <= MaxClients; target++)
				{
					if(IsClientInGame(target) && GetClientTeam(target) == 2 && (GetFlagsOfLevel(target, IdToLevel(i)) & IdToFlag(i)))
						return true;
				}
			}
		}
	}
	
	return false;
}

bool Items_GiveIdItem(int client, int id, bool noForward = false)
{
	if(!noForward && GiftItems && id < GiftItems.Length)
	{
		static GiftItem item;
		GiftItems.GetArray(id, item);
		if(Native_OnGivenItem(client, item.Name, id))
		{
			Items_GiveNamedItem(client, item.Name, true);
			return false;
		}
	}

	return AddFlagOfLevel(client, IdToLevel(id), IdToFlag(id));
}

bool Items_GiveNamedItem(int client, const char[] name, bool noForward = false)
{
	if(name[0] && GiftItems)
	{
		int length = GiftItems.Length;
		for(int i; i < length; i++)
		{
			static GiftItem item;
			GiftItems.GetArray(i, item);
			if(StrEqual(item.Name, name, false))
			{
				Items_GiveIdItem(client, i, noForward);
				return true;
			}
		}
	}
	return false;
}

char[] Items_GetNameOfId(int id)
{
	static GiftItem item;
	GiftItems.GetArray(id, item);
	return item.Name;
}
public bool Encyclopedia_SayCommand(int client)
{
	if(CategoryPage[client] == -2)
		return false;
	char buffer[16];
	GetCmdArgString(buffer, sizeof(buffer));
	ReplaceString(buffer, sizeof(buffer), "\"", "");
	Format(c_WeaponUseAbilitiesHud[client], sizeof(c_WeaponUseAbilitiesHud[]), "%s", buffer);
	Items_EncyclopediaMenu(client);
	return true;
}

char[] Encyclopedia_CurrentFilter(int client)
{
	char buffer[64];
	//reusing c_WeaponUseAbilitiesHud cus it only affects weapons
	if(!c_WeaponUseAbilitiesHud[client][0])
	{
		Format(buffer, sizeof(buffer), "%T", "Encyclopedia Type", client);
	}
	else
	{
		Format(buffer, sizeof(buffer), "%T %s", "Encyclopedia Filtered", client, c_WeaponUseAbilitiesHud[client]);
	}
	return buffer;
}

void Items_EncyclopediaMenu(int client, int page = -1, bool inPage = false)
{
	Menu menu = new Menu(Items_EncyclopediaMenuH);
	SetGlobalTransTarget(client);
	AnyMenuOpen[client] = 1.0;

	if(inPage)
	{
		NPCData data;
		NPC_GetById(page, data);

		char buffer[400];
		FormatEx(buffer, sizeof(buffer), "%s Desc", data.Name);
		if(TranslationPhraseExists(buffer))
		{
			Format(buffer, sizeof(buffer), "%t", buffer);

			menu.SetTitle("%t\n \n%s\n ", data.Name, buffer);
		}
		else
		{
			menu.SetTitle("%t\n ", data.Name);
		}
		
		IntToString(page, data.Plugin, sizeof(data.Plugin));
		FormatEx(buffer, sizeof(buffer), "%t", "Back");
		menu.AddItem(data.Plugin, buffer);

		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(page != -1)
	{
		//int kills;
		int pos;

		NPCData data;
		int length = NPC_GetCount();
		menu.AddItem("None", "", ITEMDRAW_DISABLED);
		if(CategoryPage[client] == Type_DONOTUSE)
		{
			ArrayList NpcsSavedList = new ArrayList();
			int entity = -1;
			int a;
			while((entity = FindEntityByNPC(a)) != -1)
			{
				if(IsValidEntity(entity))
				{
					if(NpcsSavedList.FindValue(i_NpcInternalId[entity]) != -1)
						continue;
					NPC_GetById(i_NpcInternalId[entity], data);
					if(data.Plugin[0])
					{
						if(i_NpcInternalId[entity] == page)
							pos = menu.ItemCount;

						IntToString(i_NpcInternalId[entity], data.Plugin, sizeof(data.Plugin));
						Format(data.Name, sizeof(data.Name), "%t", data.Name);
						menu.AddItem(data.Plugin, data.Name);
						NpcsSavedList.Push(i_NpcInternalId[entity]);
					}
				}
			}
			delete NpcsSavedList;
		}
		for(int i; i < length; i++)
		{
			NPC_GetById(i, data);
			if(data.Plugin[0] && data.Category == CategoryPage[client])
			{
				IntToString(i, data.Plugin, sizeof(data.Plugin));

				bool AllowShowing = false;
				if(i == page)
					pos = menu.ItemCount;

				if(c_WeaponUseAbilitiesHud[client][0])
				{
					if(StrContains(data.Name, c_WeaponUseAbilitiesHud[client], false) != -1)
					{
						AllowShowing = true;
					}
				}
				else
				{
					AllowShowing = true;
				}

				if(AllowShowing)
				{
					Format(data.Name, sizeof(data.Name), "%t", data.Name);
					menu.AddItem(data.Plugin, data.Name);
				}

				//kills += GetFlagsOfLevel(client, -i);
			}
		}

		menu.SetTitle("%t\n%t\n \n%s\n%t\n ", "TF2: Zombie Riot", "Encyclopedia", Encyclopedia_CurrentFilter(client), Categories[CategoryPage[client]]);

		menu.ExitBackButton = true;
		menu.DisplayAt(client, (pos / 7 * 7), MENU_TIME_FOREVER);
	}
	else
	{
		if(CategoryPage[client] < 0)
			CategoryPage[client] = 0;
		

		menu.SetTitle("%t\n%t\n%s\n ", "TF2: Zombie Riot", "Encyclopedia", Encyclopedia_CurrentFilter(client));

		char chdata[16], buffer[64];
		bool FoundOneMinimum = false;
		
		//always display
		IntToString(Type_DONOTUSE, chdata, sizeof(chdata));
		FormatEx(buffer, sizeof(buffer), "%t", Categories[Type_DONOTUSE]);
		menu.AddItem(chdata, buffer);

		for(int i = Type_Ally; i < sizeof(Categories); i++)
		{
			if(c_WeaponUseAbilitiesHud[client][0])
			{
				NPCData data;
				int length = NPC_GetCount();
				bool FoundOne = false;
				for(int i2; i2 < length; i2++)
				{
					NPC_GetById(i2, data);
					if(data.Plugin[0] && data.Category == i)
					{
						if(StrContains(data.Name, c_WeaponUseAbilitiesHud[client], false) != -1)
						{
							FoundOne = true;
						}
						else
						{
							continue;
						}
					}
				}
				if(!FoundOne)
				{
					continue;
				}
				FoundOneMinimum = true;
			}
			IntToString(i, chdata, sizeof(chdata));
			FormatEx(buffer, sizeof(buffer), "%t", Categories[i]);
			menu.AddItem(chdata, buffer);
		}

		if(!FoundOneMinimum)
		{
			menu.AddItem("None", "", ITEMDRAW_DISABLED);
		}
		menu.ExitBackButton = true;
		menu.DisplayAt(client, (CategoryPage[client] / 7 * 7), MENU_TIME_FOREVER);
		CategoryPage[client] = -1;
	}
}

public int Items_EncyclopediaMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
			{
				AnyMenuOpen[client] = 0.0;
				CategoryPage[client] = -2;
			}
		}
		case MenuAction_Cancel:
		{
			AnyMenuOpen[client] = 0.0;
			if(choice == MenuCancel_ExitBack)
			{
				if(CategoryPage[client] == -1)
				{
					CategoryPage[client] = -2;
					if(GetClientTeam(client) == 2)
						Store_Menu(client);
				}
				else
				{
					//char data[16];
					//if(menu.GetItem(1, data, sizeof(data)))	// Category -> Main
					{
						Items_EncyclopediaMenu(client, -1, false);
					}
					//else if(menu.GetItem(0, data, sizeof(data)))	// Item -> Category
					//{
					//	Items_EncyclopediaMenu(client, StringToInt(data), false);
					//}
				}
			}
			else
			{
				CategoryPage[client] = -2;
			}
		}
		case MenuAction_Select:
		{
			char buffer[16], data[16];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if(CategoryPage[client] == -1)	// Main -> Category
			{
				CategoryPage[client] = id;
				Items_EncyclopediaMenu(client, 0, false);
			}
			else if(choice || menu.GetItem(1, data, sizeof(data)))	// Category -> Item
			{
				Items_EncyclopediaMenu(client, StringToInt(buffer), true);
			}
			else	// Item -> Category
			{
				Items_EncyclopediaMenu(client, StringToInt(buffer), false);
			}
		}
	}
	return 0;
}

void Map_Precache_Zombie_Drops_Gift()
{
	PrecacheModel(GIFT_MODEL, true);
	PrecacheSound(SOUND_BEEP);
	g_BeamIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
}

void Gift_DropChance(int entity)
{
	char buffer[32];
	zr_tagblacklist.GetString(buffer, sizeof(buffer));
	if(StrContains(buffer, "private", false) == -1)
	{
		if(IsValidEntity(entity))
		{
			if(b_ForceSpawnNextTime || (GetRandomFloat(0.0, 200.0) < ((GIFT_CHANCE / (MultiGlobalEnemy + 0.0001)) * f_ExtraDropChanceRarity * f_IncreaseChanceManually))) //Never let it divide by 0
			{
				f_IncreaseChanceManually = 1.0;
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 20.0;
				ZRGiftRarity rarity = RollRandom(); //Random for each clie
				if(!IsPointHazard(VecOrigin)) //Is it valid?
				{
					b_ForceSpawnNextTime = false;
					Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, rarity);
				}
				else //Not a valid position, we must force it! next time we try!
				{
					b_ForceSpawnNextTime = true;
				}
			}	
			else
			{
				f_IncreaseChanceManually += 0.0015;
			}
		}
	}
}

static ZRGiftRarity RollRandom()
{
	if(!(GetURandomInt() % 150))
		return Mythic;
	
	if(!(GetURandomInt() % 35))
		return Legend;
	
	if(!(GetURandomInt() % 15))
		return Rare;
	
	if(!(GetURandomInt() % 3))
		return Uncommon;
	
	return Common;
}

public Action Timer_Detect_Player_Near_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	ZRGiftRarity Rarity = pack.ReadCell();
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		float powerup_pos[3];
		WorldSpaceCenter(entity, powerup_pos);
		bool DoJump = false;
		if(f_RingDelayGift[entity] < GetGameTime())
		{
			float DelayTime = 2.0;
			switch(Rarity)
			{
				case Common:
					DelayTime = 2.0;
				case Uncommon:
					DelayTime = 1.5;
				case Rare:
					DelayTime = 1.0;
				case Legend:
					DelayTime = 0.65;
				case Mythic:
					DelayTime = 0.35;
			}
			f_RingDelayGift[entity] = GetGameTime() + DelayTime;
			EmitSoundToAll(SOUND_BEEP, entity, _, 90, _, 1.0);
			int color[4];
			
			int ColorGiveRarity = view_as<int>(i_RarityType[entity]);
			color[0] = RenderColors_RPG[ColorGiveRarity][0];
			color[1] = RenderColors_RPG[ColorGiveRarity][1];
			color[2] = RenderColors_RPG[ColorGiveRarity][2];
			color[3] = RenderColors_RPG[ColorGiveRarity][3];
	
			TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, color, 0, 0);
			TE_SendToAll();
			DoJump = true;
		}
		float TargetDistance = 0.0; 
		int ClosestTarget = 0; 
		for( int i = 1; i <= MaxClients; i++ ) 
		{
			if (IsValidClient(i))
			{
				if (GetTeam(i)== TFTeam_Red && IsEntityAlive(i))
				{
					float TargetLocation[3]; 
					WorldSpaceCenter(i, TargetLocation);
					
					
					float distance = GetVectorDistance( powerup_pos, TargetLocation, true ); 
					if( TargetDistance ) 
					{
						if( distance < TargetDistance ) 
						{
							ClosestTarget = i; 
							TargetDistance = distance;		  
						}
					} 
					else 
					{
						ClosestTarget = i; 
						TargetDistance = distance;
					}		
				}
			}
		}
		if(ClosestTarget > 0 && TargetDistance <= (50.0 * 50.0))
		{
			//picked up!
			char NameOfTheHero[64];
			Format(NameOfTheHero, sizeof(NameOfTheHero), "%N", ClosestTarget);
			for( int i = 1; i <= MaxClients; i++ ) 
			{
				if (IsValidClient(i))
				{
					if (GetTeam(i)== TFTeam_Red)
					{
						SetGlobalTransTarget(i);
						int MultiExtra = 1;
						switch(Rarity)
						{
							case Common:
								MultiExtra = 1;
							case Uncommon:
								MultiExtra = 2;
							case Rare:
								MultiExtra = 5;
							case Legend:
								MultiExtra = 10;
							case Mythic:
								MultiExtra = 40;
						}
						//xp to give?
						int TempCalc = Level[i];
						if(TempCalc >= 101) //fix shitty rounding to 995 xp to 1000 xp
							TempCalc = 101;

						TempCalc = LevelToXp(TempCalc) - LevelToXp(TempCalc - 1);
						TempCalc /= 40;

						int XpToGive = TempCalc * MultiExtra;
						CPrintToChat(i,"%t", "Pickup Gift", NameOfTheHero, XpToGive);
						XP[i] += XpToGive;
						Native_ZR_OnGetXP(i, XpToGive, 0);
						GiveXP(i, 0);
					}
				}
			}
			Native_ZR_OnGiftCollected(ClosestTarget, Rarity);
			if (IsValidEntity(glow))
			{
				RemoveEntity(glow);
			}
			RemoveEntity(entity);
			return Plugin_Stop;		
		}
		if(ClosestTarget > 0 && TargetDistance <= (500.0 * 500.0) && DoJump)
		{
			GiftJumpAwayYou(entity, ClosestTarget); //Terror.
		}	
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock void Stock_SpawnGift(float position[3], const char[] model, float lifetime, ZRGiftRarity rarity)
{
	int m_iGift = CreateEntityByName("prop_physics_override")
	if(m_iGift != -1)
	{
		char targetname[100];

		Format(targetname, sizeof(targetname), "gift_%i", m_iGift);

		DispatchKeyValue(m_iGift, "model", model);
		DispatchKeyValue(m_iGift, "targetname", targetname);
		DispatchKeyValue(m_iGift, "physicsmode", "2");
		DispatchKeyValue(m_iGift, "massScale", "1.0");
		DispatchSpawn(m_iGift);
		
		SetEntProp(m_iGift, Prop_Send, "m_usSolidFlags", 8);
		SetEntityCollisionGroup(m_iGift, 1);
	
		TeleportEntity(m_iGift, position, NULL_VECTOR, NULL_VECTOR);
		
		i_RarityType[m_iGift] = rarity;
		
		int glow = TF2_CreateGlow(m_iGift);
		
		int color[4];
		int ColorGiveRarity = view_as<int>(rarity);
		color[0] = RenderColors_RPG[ColorGiveRarity][0];
		color[1] = RenderColors_RPG[ColorGiveRarity][1];
		color[2] = RenderColors_RPG[ColorGiveRarity][2];
		color[3] = RenderColors_RPG[ColorGiveRarity][3];
		
		SetVariantColor(view_as<int>(color));
		AcceptEntityInput(glow, "SetGlowColor");
			
		
		f_RingDelayGift[m_iGift] = 0.0;

		DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_Gift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(rarity);	
		
		
		DataPack pack_2;
		CreateDataTimer(lifetime, Timer_Despawn_Gift, pack_2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack_2.WriteCell(EntIndexToEntRef(m_iGift));
		pack_2.WriteCell(EntIndexToEntRef(glow));	
		
	//	SDKHook(entity, SDKHook_SetTransmit, GiftTransmit);
	//	SDKHook(m_iGift, SDKHook_SetTransmit, GiftTransmit);
	}
}


public Action Timer_Despawn_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if (IsValidEntity(glow))
		{
			RemoveEntity(glow);
		}
		RemoveEntity(entity);
	}
	return Plugin_Stop;
}

public Action GiftTransmit(int entity, int target)
{
	if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == target)
		return Plugin_Continue;

	return Plugin_Handled;
}

//This is probably the silliest thing ever.
public void GiftJumpAwayYou(int Gift, int client)
{
	float Jump_1_frame[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", Jump_1_frame);
	float Jump_1_frame_Client[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", Jump_1_frame_Client);
	
	float vecNPC[3], vecJumpVel[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", vecNPC);
		/*
	float gravity = GetEntPropFloat(Gift, Prop_Data, "m_flGravity");
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
		*/
	float gravity = 800.0;
		
	// How fast does the headcrab need to travel to reach the position given gravity?
	float flActualHeight = Jump_1_frame_Client[2] - vecNPC[2];
	float height = flActualHeight;
	if ( height < 72 )
	{
		height = 72.0;
	}

	float additionalHeight = 0.0;
		
	if ( height < 35 )
	{
		additionalHeight = 50.0;
	}
		
	height += additionalHeight;
	
	float speed = SquareRoot( 2 * gravity * height );
	float time = speed / gravity;
	
	time += SquareRoot( (2 * additionalHeight) / gravity );
		
	// Scale the sideways velocity to get there at the right time
	SubtractVectors( Jump_1_frame_Client, vecNPC, vecJumpVel );
	vecJumpVel[0] /= time;
	vecJumpVel[1] /= time;
	vecJumpVel[2] /= time;
	
	// Speed to offset gravity at the desired height.
	vecJumpVel[2] = speed;
		
	// Don't jump too far/fast.
	float flJumpSpeed = 400.0;
	float flMaxSpeed = 400.0;
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	//jump away!
	vecJumpVel [0] *= -1.0;
	vecJumpVel [1] *= -1.0;
	TeleportEntity(Gift, NULL_VECTOR, NULL_VECTOR, vecJumpVel);
}


bool Item_ClientHasAllRarity(int client, int rarity)
{
	static GiftItem item;
	int rand = GetURandomInt();
	int length = GiftItems.Length;
	int[] items = new int[length];
	int maxitems;
	rarity--;
	for(int i; i < length; i++)
	{
		GiftItems.GetArray(i, item);
		if(item.Rarity == rarity)
		{
			items[maxitems++] = i;
		}
	}

	int start = (rand % maxitems);
	int i = start;
	do
	{
		i++;
		if(i >= maxitems)
		{
			i = -1;
			continue;
		}

		if(!Items_HasIdItem(client, items[i]))
		{
			//GiftItems.GetArray(items[i], item);
			length = 0;
			break;
		}
	}
	while(i != start);
	
	if(length)
	{
		return true;
	}
	return false;
}

public void MapChooser_OnClientItem(int client, const char[] item, int amount, bool &result)
{
	result = Items_HasNamedItem(client, item);
}
