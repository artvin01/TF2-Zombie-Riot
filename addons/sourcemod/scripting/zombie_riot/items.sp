
#define GIFT_MODEL "models/items/tf_gift.mdl"

#define GIFT_CHANCE 0.35 //Extra rare cus alot of zobies

#define SOUND_BEEP			"buttons/button17.wav"

enum
{
	Rarity_None = -1,
	Rarity_Common = 0,
	Rarity_Uncommon = 1,
	Rarity_Rare = 2,
	Rarity_Legend = 3,
	Rarity_Mythic = 4
}

static const char Categories[][] =
{
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
	"Expidonsa"
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
static int LastMenuPage[MAXTF2PLAYERS];

static int g_BeamIndex = -1;
static int i_RarityType[MAXENTITIES];
static float f_IncreaceChanceManually = 1.0;
static bool b_ForceSpawnNextTime;

void Items_PluginStart()
{
	OwnedItems = new ArrayList(sizeof(OwnedItem));
	//RegConsoleCmd("zr_itemdebug", Items_DebugCmd);
}

void Items_SetupConfig()
{
	delete GiftItems;
	GiftItems = new ArrayList(sizeof(GiftItem));
	
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof(buffer), CONFIG_CFG, "giftitems");

	KeyValues kv = new KeyValues("GiftItems");
	kv.ImportFromFile(buffer);
	
	GiftItem item;
	for(int i; ; i++)	// Done this method due to saving by ID instead
	{
		IntToString(i, item.Name, sizeof(item.Name));
		if(kv.JumpToKey(item.Name))
		{
			kv.GetString("name", item.Name, sizeof(item.Name));
			item.Rarity = kv.GetNum("rarity", Rarity_None);
			GiftItems.PushArray(item);

			kv.GoBack();
		}
		else
		{
			break;
		}
	}
}

void Items_ClearArray(int client)
{
	int id;
	while((id = OwnedItems.FindValue(client, OwnedItem::Client)) != -1)
	{
		OwnedItems.Erase(id);
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
	}
}

bool Items_GetNextItem(int client, int &i, int &level, int &flags)
{
	int length = OwnedItems.Length;
	for(; i < length; i++)
	{
		static OwnedItem owned;
		OwnedItems.GetArray(i, owned);
		if(owned.Client == client && level >= 0)
		{
			level = owned.Level;
			flags = owned.Flags;
			return true;
		}
	}

	return false;
}

public Action Items_DebugCmd(int client, int args)
{
	int length = OwnedItems.Length;
	for(int i; i < length; i++)
	{
		static OwnedItem owned;
		OwnedItems.GetArray(i, owned);
		PrintToChatAll("%d %N %d %d", i, client, owned.Level, owned.Flags);
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

static bool AddFlagOfLevel(int client, int level, int flag, bool addition)
{
	static OwnedItem owned;
	int length = OwnedItems.Length;
	for(int i; i < length; i++)
	{
		OwnedItems.GetArray(i, owned);
		if(owned.Client == client && owned.Level == level)
		{
			if(addition || !(owned.Flags & flag))
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
				return view_as<bool>(GetFlagsOfLevel(client, IdToLevel(i)) & IdToFlag(i));
		}
	}
	
	return false;
}

stock void Items_GiveNPCKill(int client, int id)
{
	//AddFlagOfLevel(client, -id, 1, true);
}

bool Items_GiveIdItem(int client, int id, bool addition = false)
{
	return AddFlagOfLevel(client, IdToLevel(id), IdToFlag(id), addition);
}

void Items_GiveNamedItem(int client, const char[] name)
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
				AddFlagOfLevel(client, IdToLevel(i), IdToFlag(i), false);
				break;
			}
		}
	}
}

char[] Items_GetNameOfId(int id)
{
	static GiftItem item;
	GiftItems.GetArray(id, item);
	return item.Name;
}

void Items_EncyclopediaMenu(int client, int page = -1, bool inPage = false)
{
	Menu menu = new Menu(Items_EncyclopediaMenuH);
	SetGlobalTransTarget(client);

	if(inPage)
	{
		char buffer[400];
		FormatEx(buffer, sizeof(buffer), "%s Desc", NPC_Names[page]);
		if(TranslationPhraseExists(buffer))
		{
			Format(buffer, sizeof(buffer), "%t", buffer);

			/*if(Database_IsCached(client))
			{
				menu.SetTitle("%t\n \n%s\n%t\n ", NPC_Names[page], buffer, LastMenuPage[client] ? "Zombie Kills" : "Allied Summons", GetFlagsOfLevel(client, -page));
			}
			else*/
			{
				menu.SetTitle("%t\n \n%s\n ", NPC_Names[page], buffer);
			}
		}
		/*else if(Database_IsCached(client))
		{
			menu.SetTitle("%t\n \n%t\n ", NPC_Names[page], LastMenuPage[client] ? "Zombie Kills" : "Allied Summons", GetFlagsOfLevel(client, -page));
		}*/
		else
		{
			menu.SetTitle("%t\n ", NPC_Names[page]);
		}
		
		char data[16];
		IntToString(page, data, sizeof(data));
		FormatEx(buffer, sizeof(buffer), "%t", "Back");
		menu.AddItem(data, buffer);

		menu.Display(client, MENU_TIME_FOREVER);
	}
	else if(page != -1)
	{
		//int kills;
		int pos;

		char data[16], buffer[64];
		for(int i; i < sizeof(NPC_Names); i++)
		{
			if(NPCCategory[i] == LastMenuPage[client])
			{
				IntToString(i, data, sizeof(data));
				FormatEx(buffer, sizeof(buffer), "%t", NPC_Names[i]);
				
				if(i == page)
				{
					pos = menu.AddItem(data, buffer);
				}
				else
				{
					menu.AddItem(data, buffer);
				}

				//kills += GetFlagsOfLevel(client, -i);
			}
		}

		//menu.SetTitle("%t\n%t\n \n%t\n%t\n ", "TF2: Zombie Riot", "Encyclopedia", Categories[LastMenuPage[client]], LastMenuPage[client] ? "Zombie Kills" : "Allied Summons", kills);
		menu.SetTitle("%t\n%t\n \n%t\n ", "TF2: Zombie Riot", "Encyclopedia", Categories[LastMenuPage[client]]);

		menu.ExitBackButton = true;
		menu.DisplayAt(client, (pos / 7 * 7), MENU_TIME_FOREVER);
	}
	else
	{
		if(LastMenuPage[client] < 0)
			LastMenuPage[client] = 0;
		
		/*int kills;
		int length = OwnedItems.Length;
		for(int i; i < length; i++)
		{
			static OwnedItem owned;
			OwnedItems.GetArray(i, owned);
			if(owned.Client == client && owned.Level < 0)
				kills += owned.Flags;
		}*/

		//menu.SetTitle("%t\n%t\n \n%t\n ", "TF2: Zombie Riot", "Encyclopedia", "Zombie Kills", kills);
		menu.SetTitle("%t\n%t\n ", "TF2: Zombie Riot", "Encyclopedia");

		char data[16], buffer[64];
		for(int i; i < sizeof(Categories); i++)
		{
			IntToString(i, data, sizeof(data));
			FormatEx(buffer, sizeof(buffer), "%t", Categories[i]);
			menu.AddItem(data, buffer);
		}

		menu.ExitBackButton = true;
		menu.DisplayAt(client, (LastMenuPage[client] / 7 * 7), MENU_TIME_FOREVER);
		LastMenuPage[client] = -1;
	}
}

public int Items_EncyclopediaMenuH(Menu menu, MenuAction action, int client, int choice)
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
				if(LastMenuPage[client] == -1)
				{
					MenuPage(client, -1);
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
				LastMenuPage[client] = -1;
			}
		}
		case MenuAction_Select:
		{
			char buffer[16], data[16];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if(LastMenuPage[client] == -1)	// Main -> Category
			{
				LastMenuPage[client] = id;
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
			if(b_ForceSpawnNextTime || (GetRandomFloat(0.0, 200.0) < ((GIFT_CHANCE / (MultiGlobal + 0.0001)) * f_ExtraDropChanceRarity * f_IncreaceChanceManually))) //Never let it divide by 0
			{
				f_IncreaceChanceManually = 1.0;
				float VecOrigin[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", VecOrigin);
				VecOrigin[2] += 20.0;
				for (int client = 1; client <= MaxClients; client++)
				{
					if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
					{
						int rarity = RollRandom(); //Random for each clie
						if(!IsPointHazard(VecOrigin)) //Is it valid?
						{
							b_ForceSpawnNextTime = false;
							Stock_SpawnGift(VecOrigin, GIFT_MODEL, 45.0, client, rarity);
						}
						else //Not a valid position, we must force it! next time we try!
						{
							b_ForceSpawnNextTime = true;
						}
					}
				}
			}	
			else
			{
				f_IncreaceChanceManually += 0.0015;
			}
		}
	}
}

static int RollRandom()
{
	if(!(GetURandomInt() % 150))
		return Rarity_Mythic;
	
	if(!(GetURandomInt() % 35))
		return Rarity_Legend;
	
	if(!(GetURandomInt() % 15))
		return Rarity_Rare;
	
	if(!(GetURandomInt() % 3))
		return Rarity_Uncommon;
	
	return Rarity_Common;
}


public Action Timer_Detect_Player_Near_Gift(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	int glow = EntRefToEntIndex(pack.ReadCell());
	int client = GetClientOfUserId(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		if(IsValidClient(client))
		{
			float powerup_pos[3];
			float client_pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", powerup_pos);
			if(f_RingDelayGift[entity] < GetGameTime())
			{
				f_RingDelayGift[entity] = GetGameTime() + 2.0;
				EmitSoundToClient(client, SOUND_BEEP, entity, _, 90, _, 1.0);
				int color[4];
				
				color[0] = RenderColors_RPG[i_RarityType[entity]][0];
				color[1] = RenderColors_RPG[i_RarityType[entity]][1];
				color[2] = RenderColors_RPG[i_RarityType[entity]][2];
				color[3] = RenderColors_RPG[i_RarityType[entity]][3];
		
				TE_SetupBeamRingPoint(powerup_pos, 10.0, 300.0, g_BeamIndex, -1, 0, 30, 1.0, 10.0, 1.0, color, 0, 0);
	   			TE_SendToClient(client);

				GiftJumpTowardsYou(entity, client); //Terror.
   			}
			if (IsPlayerAlive(client) && GetClientTeam(client) == view_as<int>(TFTeam_Red))
			{
				GetClientAbsOrigin(client, client_pos);
				if(GetVectorDistance(powerup_pos, client_pos, true) < 4096.0)
				{
					if(IsValidEntity(glow))
						RemoveEntity(glow);
					
					RemoveEntity(entity);
					
					static GiftItem item;
					int rand = GetURandomInt();
					int length = GiftItems.Length;
					int[] items = new int[length];
					for(int r = i_RarityType[entity]; r >= 0; r--)
					{
						int maxitems;
						for(int i; i < length; i++)
						{
							GiftItems.GetArray(i, item);
							if(item.Rarity == r)
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

							if(Items_GiveIdItem(client, items[i]))	// Gives item, returns true if newly obtained, false if they already have
							{
								static const char Colors[][] = { "default", "green", "blue", "yellow", "darkred" };
								
								GiftItems.GetArray(items[i], item);
								CPrintToChat(client, "{default}You have found {%s}%s{default}!", Colors[r], item.Name);
								r = -1;
								length = 0;
								break;
							}
						}
						while(i != start);
					}
					
					if(length)
					{
						PrintToChat(client, "You already have everything in this rarity, but where given %d Scrap as a compensation.", i_RarityType[entity] + 1);
						Scrap[client] += i_RarityType[entity] + 1;
					}

					return Plugin_Stop;
				}
			}
		}
		else
		{
			if (IsValidEntity(glow))
			{
				RemoveEntity(glow);
			}
			RemoveEntity(entity);
			return Plugin_Stop;			
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock void Stock_SpawnGift(float position[3], const char[] model, float lifetime, int client, int rarity)
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
		
		color[0] = RenderColors_RPG[i_RarityType[m_iGift]][0];
		color[1] = RenderColors_RPG[i_RarityType[m_iGift]][1];
		color[2] = RenderColors_RPG[i_RarityType[m_iGift]][2];
		color[3] = RenderColors_RPG[i_RarityType[m_iGift]][3];
		
		SetVariantColor(view_as<int>(color));
		AcceptEntityInput(glow, "SetGlowColor");
		
		SetEntPropEnt(glow, Prop_Send, "m_hOwnerEntity", client);
		SetEntPropEnt(m_iGift, Prop_Send, "m_hOwnerEntity", client);
			
		
		f_RingDelayGift[m_iGift] = GetGameTime() + 2.0;

		DataPack pack;
		CreateDataTimer(0.1, Timer_Detect_Player_Near_Gift, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(m_iGift));
		pack.WriteCell(EntIndexToEntRef(glow));	
		pack.WriteCell(GetClientUserId(client));
		
		
		DataPack pack_2;
		CreateDataTimer(lifetime, Timer_Despawn_Gift, pack_2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack_2.WriteCell(EntIndexToEntRef(m_iGift));
		pack_2.WriteCell(EntIndexToEntRef(glow));	
		
	//	SDKHook(entity, SDKHook_SetTransmit, GiftTransmit);
		SDKHook(m_iGift, SDKHook_SetTransmit, GiftTransmit);
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
public void GiftJumpTowardsYou(int Gift, int client)
{
	float Jump_1_frame[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", Jump_1_frame);
	float Jump_1_frame_Client[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", Jump_1_frame_Client);
	
	float vecNPC[3], vecJumpVel[3];
	GetEntPropVector(Gift, Prop_Data, "m_vecOrigin", vecNPC);
		
	float gravity = GetEntPropFloat(Gift, Prop_Data, "m_flGravity");
	if(gravity <= 0.0)
		gravity = FindConVar("sv_gravity").FloatValue;
		
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
	float flJumpSpeed = GetVectorLength(vecJumpVel);
	float flMaxSpeed = 350.0;
	if ( flJumpSpeed > flMaxSpeed )
	{
		vecJumpVel[0] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[1] *= flMaxSpeed / flJumpSpeed;
		vecJumpVel[2] *= flMaxSpeed / flJumpSpeed;
	}
	TeleportEntity(Gift, NULL_VECTOR, NULL_VECTOR, vecJumpVel);
}