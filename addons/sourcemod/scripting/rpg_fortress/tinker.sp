#pragma semicolon 1
#pragma newdecls required

static const char TierName[][] =
{
	// 1 = Sell
	// 2 = XP
	// 3 = Forge Stat
	// 4 = Forge Stat
	// 5 = Forge Stat
	// 6 = Forge Stat
	"Strange",			// 3 / 9
	"Unremarkable",		// 4 / 10
	"Scarcely Lethal",	// 5 / 11
	"Uncharitable",		// 6 / 12
	"Truely Feared",	// 7 / 13
	"Wicked Nasty",		// 8 / 14
	"Epic",				// 9 / 15
	"Legendary"			// 10 / 16
};

#define FORGE_COST	2000
#define ROLLING_COST	2000
#define REROLL_COST	3000

#define TINKER_CAP	10

#define FLAG_MELEE	(1 << 0)	// 1
#define FLAG_RANGE	(1 << 1)	// 2
#define FLAG_WAND	(1 << 2)	// 4
#define FLAG_MINE	(1 << 3)	// 8
#define FLAG_FISH	(1 << 4)	// 16
#define FLAG_WRENCH	(1 << 5)	// 32
#define FLAG_ALL	63


enum struct TinkerNPCEnum
{
	char Model[PLATFORM_MAX_PATH];
	char Idle[64];
	float Pos[3];
	float Ang[3];
	float Scale;
	
	char Wear1[PLATFORM_MAX_PATH];
	char Wear2[PLATFORM_MAX_PATH];
	char Wear3[PLATFORM_MAX_PATH];
	
	int EntRef;
	
	void SetupEnum(KeyValues kv)
	{
		kv.GetString("model", this.Model, PLATFORM_MAX_PATH);
		if(!this.Model[0])
			SetFailState("Missing model in tinker.cfg");
		
		this.Scale = kv.GetFloat("scale", 1.0);
		
		kv.GetString("anim_idle", this.Idle, 64);
		
		kv.GetVector("pos", this.Pos);
		kv.GetVector("ang", this.Ang);
		
		kv.GetString("wear1", this.Wear1, PLATFORM_MAX_PATH);
		if(this.Wear1[0])
			PrecacheModel(this.Wear1);
		
		kv.GetString("wear2", this.Wear2, PLATFORM_MAX_PATH);
		if(this.Wear2[0])
			PrecacheModel(this.Wear2);
		
		kv.GetString("wear3", this.Wear3, PLATFORM_MAX_PATH);
		if(this.Wear3[0])
			PrecacheModel(this.Wear3);
	}
	
	void Despawn()
	{
		if(this.EntRef != INVALID_ENT_REFERENCE)
		{
			int entity = EntRefToEntIndex(this.EntRef);
			if(entity != -1)
			{
				int brush = EntRefToEntIndex(b_OwnerToBrush[entity]);
				if(IsValidEntity(brush))
				{
					RemoveEntity(brush);
				}
			}

			if(entity != -1)
				RemoveEntity(entity);
			
			this.EntRef = INVALID_ENT_REFERENCE;
		}
	}
	
	void Spawn()
	{
		if(EntRefToEntIndex(this.EntRef) == INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("prop_dynamic_override");
			if(IsValidEntity(entity))
			{
				DispatchKeyValue(entity, "targetname", "rpg_fortress");
				DispatchKeyValue(entity, "model", this.Model);
				
				
				TeleportEntity(entity, this.Pos, this.Ang, NULL_VECTOR);
				
				DispatchSpawn(entity);
				SetEntityCollisionGroup(entity, 2);

				int brush = SpawnSeperateCollisionBox(entity);
				//Just reuse it.
				b_BrushToOwner[brush] = EntIndexToEntRef(entity);
				b_OwnerToBrush[entity] = EntIndexToEntRef(brush);
				
				if(this.Wear1[0])
					GivePropAttachment(entity, this.Wear1);
				
				if(this.Wear2[0])
					GivePropAttachment(entity, this.Wear2);
				
				if(this.Wear3[0])
					GivePropAttachment(entity, this.Wear3);
				
				SetEntPropFloat(entity, Prop_Send, "m_flModelScale", this.Scale);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetDefaultAnimation", entity, entity);
				
				SetVariantString(this.Idle);
				AcceptEntityInput(entity, "SetAnimation", entity, entity);
				
				this.EntRef = EntIndexToEntRef(entity);
			}
		}
	}
}

enum struct TinkerEnum
{
	char Name[32];
	int PlayerLevel;

	int ToolFlags;

	int Levels;
	int Credits;
	char Previous[32];

	char Cost1[48];
	int Amount1;

	char Cost2[48];
	int Amount2;

	char Cost3[48];
	int Amount3;

	char Desc[256];
	
	int Attrib[4];
	float Value[4];
	int Attribs;

	Function FuncAttack;
	Function FuncAttack2;
	Function FuncAttack3;
	Function FuncReload;
	Function FuncGainXP;
	Function FuncMining;

	void SetupEnum(KeyValues kv)
	{
		kv.GetSectionName(this.Name, 32);

		this.PlayerLevel = kv.GetNum("player_minlevel");
		this.ToolFlags = kv.GetNum("tools", FLAG_ALL);
		this.Levels = kv.GetNum("levels");
		this.Credits = kv.GetNum("credits");

		kv.GetString("previous", this.Previous, 32);

		kv.GetString("name_1", this.Cost1, 48);
		this.Amount1 = kv.GetNum("amount_1");

		kv.GetString("name_2", this.Cost2, 48);
		this.Amount2 = kv.GetNum("amount_2");

		kv.GetString("name_3", this.Cost3, 48);
		this.Amount3 = kv.GetNum("amount_3");

		kv.GetString("func_attack", this.Desc, 256);
		this.FuncAttack = GetFunctionByName(null, this.Desc);

		kv.GetString("func_attack2", this.Desc, 256);
		this.FuncAttack2 = GetFunctionByName(null, this.Desc);

		kv.GetString("func_attack3", this.Desc, 256);
		this.FuncAttack3 = GetFunctionByName(null, this.Desc);

		kv.GetString("func_reload", this.Desc, 256);
		this.FuncReload = GetFunctionByName(null, this.Desc);

		kv.GetString("func_gainxp", this.Desc, 256);
		this.FuncGainXP = GetFunctionByName(null, this.Desc);

		kv.GetString("func_mining", this.Desc, 256);
		this.FuncMining = GetFunctionByName(null, this.Desc);

		static char buffers[64][16];
		kv.GetString("attribs", this.Desc, 256);
		this.Attribs = ExplodeString(this.Desc, ";", buffers, sizeof(buffers), sizeof(buffers[])) / 2;
		for(int i; i < this.Attribs; i++)
		{
			this.Attrib[i] = StringToInt(buffers[i*2]);
			if(!this.Attrib[i])
			{
				LogError("Found invalid attribute on '%s'", this.Name);
				this.Attribs = i;
				break;
			}
			
			this.Value[i] = StringToFloat(buffers[i*2+1]);
		}

		kv.GetString("desc", this.Desc, 256);
	}
}

enum struct ForgeEnum
{
	int Attrib;
	int Type;
	int MinLevel;
	int MaxLevel;
	float Low;
	float High;
	int ToolFlags;

	void SetupEnum(KeyValues kv)
	{
		this.MinLevel = kv.GetNum("minlevel");
		this.MaxLevel = kv.GetNum("maxlevel", 99999);
		this.Type = kv.GetNum("type");
		this.Low = kv.GetFloat("low");
		this.High = kv.GetFloat("high");
		this.ToolFlags = kv.GetNum("tools", FLAG_ALL);
	}
}

enum struct WeaponEnum
{
	int Store;
	int Owner;
	int XP;

	int Perks[TINKER_CAP];
	int PerkCount;

	int Forge[4];
	float Value[4];
	int ForgeCount;

	int Tier()
	{
		int tier = RoundToFloor(Pow(this.XP / 20.0, 0.5));
		if(tier >= sizeof(TierName))
			tier = sizeof(TierName) - 1;
		
		return tier;
	}
	int XpToNextTier()
	{
		int tier = RoundToFloor(Pow(this.XP / 20.0, 0.5)) + 1;
		if(tier >= sizeof(TierName))
			return 0;
		
		return tier * tier * 20;
	}
}

static StringMap NPCList;
static ArrayList TinkerList;
static ArrayList WeaponList;
static ArrayList ForgeList;
static int CurrentWeapon[MAXPLAYERS];
static bool ChatListen[MAXPLAYERS];

void Tinker_ConfigSetup()
{
	char buffer[PLATFORM_MAX_PATH];
	RPG_BuildPath(buffer, sizeof(buffer), "tinker");
	KeyValues kv = new KeyValues("Tinker");
	kv.SetEscapeSequences(true);
	kv.ImportFromFile(buffer);

	Tinker_ResetAll();

	delete NPCList;
	NPCList = new StringMap();

	TinkerNPCEnum npc;
	npc.EntRef = INVALID_ENT_REFERENCE;

	if(kv.JumpToKey("Stores"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				npc.SetupEnum(kv);
				kv.GetSectionName(buffer, sizeof(buffer));
				NPCList.SetArray(buffer, npc, sizeof(npc));
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	delete TinkerList;
	TinkerList = new ArrayList(sizeof(TinkerEnum));

	TinkerEnum tinker;

	if(kv.JumpToKey("Tinkers"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				tinker.SetupEnum(kv);
				TinkerList.PushArray(tinker);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	delete ForgeList;
	ForgeList = new ArrayList(sizeof(ForgeEnum));

	ForgeEnum forge;

	if(kv.JumpToKey("Forge"))
	{
		if(kv.GotoFirstSubKey())
		{
			do
			{
				kv.GetSectionName(buffer, sizeof(buffer));
				forge.Attrib = StringToInt(buffer);
				forge.SetupEnum(kv);
				ForgeList.PushArray(forge);
			}
			while(kv.GotoNextKey());

			kv.GoBack();
		}

		kv.GoBack();
	}

	delete kv;
}

void Tinker_ResetAll()
{
	delete WeaponList;
	WeaponList = new ArrayList(sizeof(WeaponEnum));
}

void Tinker_EnableZone(const char[] name)
{
	static TinkerNPCEnum npc;
	if(NPCList.GetArray(name, npc, sizeof(npc)))
	{
		npc.Spawn();
		NPCList.SetArray(name, npc, sizeof(npc));
	}
}

void Tinker_DisableZone(const char[] name)
{
	static TinkerNPCEnum npc;
	if(NPCList.GetArray(name, npc, sizeof(npc)))
	{
		npc.Despawn();
		NPCList.SetArray(name, npc, sizeof(npc));
	}
}

static void ToMetaData(const WeaponEnum weapon, char data[512])
{
	int sell = FORGE_COST;

	Format(data, sizeof(data), "txp%d", weapon.XP);

	for(int i; i < weapon.PerkCount; i++)
	{
		static TinkerEnum tinker;
		TinkerList.GetArray(weapon.Perks[i], tinker);
		Format(data, sizeof(data), "%s:%s", data, tinker.Name);
		sell += tinker.Credits;
	}

	if(weapon.ForgeCount)
	{
		for(int i; i < weapon.ForgeCount; i++)
		{
			Format(data, sizeof(data), "%s:forge,%d,%.2f", data, weapon.Forge[i], weapon.Value[i]);
		}

		sell += ROLLING_COST;
	}
	
	Format(data, sizeof(data), "sell%d:%s", sell, data);
}

static int ConvertToTinker(int client, int index)
{
	int newIndex = index;

	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		int cash = TextStore_Cash(client);
		if(FORGE_COST <= cash)
		{
			int amount;
			TextStore_GetInv(client, index, amount);
			if(amount)
			{
				TextStore_SetInv(client, index, _, false);

				char data[20];
				FormatEx(data, sizeof(data), "sell%d", FORGE_COST);
				newIndex = TextStore_CreateUniqueItem(client, index, data);
				TextStore_UseItem(client, newIndex, false);

				TextStore_Cash(client, -FORGE_COST);
			}
		}
	}

	return newIndex;
}

void Tinker_EquipItem(int client, int index)
{
	if(index < 0)
	{
		static char data[512];
		TextStore_GetItemData(index, data, sizeof(data));
		
		WeaponEnum weapon;
		weapon.Store = index;
		weapon.Owner = client;

		static char buffers[16][32];
		int count = ExplodeString(data, ":", buffers, sizeof(buffers), sizeof(buffers[]));
		int length = TinkerList.Length;
		for(int i; i < count; i++)
		{
			if(!StrContains(buffers[i], "sell"))
				continue;
			
			if(!StrContains(buffers[i], "txp"))
			{
				weapon.XP = StringToInt(buffers[i][3]);
			}
			else if(!StrContains(buffers[i], "forge"))
			{
				if(i > 1)
				{
					ExplodeString(buffers[i], ",", buffers, 3, sizeof(buffers[]));
					weapon.Forge[weapon.ForgeCount] = StringToInt(buffers[1]);
					weapon.Value[weapon.ForgeCount++] = StringToFloat(buffers[2]);
				}
			}
			else
			{
				for(int a; a < length; a++)
				{
					static TinkerEnum tinker;
					TinkerList.GetArray(a, tinker);
					if(StrEqual(tinker.Name, buffers[i], false))
					{
						weapon.Perks[weapon.PerkCount++] = a;
						break;
					}
				}
			}
		}

		WeaponList.PushArray(weapon);
	}
}

void Tinker_SpawnItem(int client, int index, int entity)
{
	if(index < 0)
	{
		int length = WeaponList.Length;
		for(int i; i < length; i++)
		{
			static WeaponEnum weapon;
			WeaponList.GetArray(i, weapon);
			if(weapon.Store == index && weapon.Owner == client)
			{
				TextStore_GetItemName(index, StoreWeapon[entity], sizeof(StoreWeapon[]));

				static TinkerEnum tinker;
				for(i = 0; i < weapon.PerkCount; i++)
				{
					TinkerList.GetArray(weapon.Perks[i], tinker);
					
					for(int a; a < tinker.Attribs; a++)
					{
						if(tinker.Attrib[a] < 0)
						{
							Stats_SetCustomStats(entity, tinker.Attrib[a], tinker.Value[a]);
						}
						else
						{
							if(!Attributes_Has(entity, tinker.Attrib[a]))
							{
								Attributes_Set(entity, tinker.Attrib[a], tinker.Value[a]);
							}
							else if(TF2Econ_GetAttributeDefinitionString(tinker.Attrib[a], "description_format", tinker.Name, sizeof(tinker.Name)) && StrContains(tinker.Name, "additive") != -1)
							{
								Attributes_SetAdd(entity, tinker.Attrib[a], tinker.Value[a]);
							}
							else
							{
								Attributes_SetMulti(entity, tinker.Attrib[a], tinker.Value[a]);
							}
						}
					}

					if(tinker.FuncAttack != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M1;
						EntityFuncAttack[entity] = tinker.FuncAttack;
					}
					
					if(tinker.FuncAttack2 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_M2;
						EntityFuncAttack2[entity] = tinker.FuncAttack2;
					}
					
					if(tinker.FuncAttack3 != INVALID_FUNCTION)
					{
						i_Hex_WeaponUsesTheseAbilities[entity] |= ABILITY_R;
						EntityFuncAttack3[entity] = tinker.FuncAttack3;
					}
					
					if(tinker.FuncReload != INVALID_FUNCTION)
						EntityFuncReload4[entity] = tinker.FuncReload;
				}

				for(i = 0; i < weapon.ForgeCount; i++)
				{
					if(weapon.Forge[i] < 0)
					{
						Stats_SetCustomStats(entity, weapon.Forge[i], weapon.Value[i]);
					}
					else if(weapon.Forge[i])
					{
						if(!Attributes_Has(entity, weapon.Forge[i]))
						{
							Attributes_Set(entity, weapon.Forge[i], weapon.Value[i]);
						}
						else if(Attribute_IntAttribute(weapon.Forge[i]) || (TF2Econ_GetAttributeDefinitionString(weapon.Forge[i], "description_format", tinker.Name, sizeof(tinker.Name)) && StrContains(tinker.Name, "additive") != -1))
						{
							Attributes_SetAdd(entity, weapon.Forge[i], weapon.Value[i]);
						}
						else
						{
							Attributes_SetMulti(entity, weapon.Forge[i], weapon.Value[i]);
						}

					//	Attributes_Set(entity, 128, 1.0);
					// 	Breaks animations heavily
					}
				}

				break;
			}
		}
	}
}

void Tinker_GainXP(int client, int entity)
{
	int index = Store_GetStoreOfEntity(entity);
	if(index < 0)
	{
		static WeaponEnum weapon;
		int length = WeaponList.Length;
		for(int i; i < length; i++)
		{
			WeaponList.GetArray(i, weapon);
			if(weapon.Store == index && weapon.Owner == client)
			{
				int xp = weapon.XP + 1;

				if(xp % 5)
				{
					weapon.XP = xp;
				}
				else
				{
					int oldTier = weapon.Tier();
					weapon.XP = xp;
					int newTier = weapon.Tier();

					if(oldTier != newTier)
					{
						SPrintToChat(client, "Your %s has reached a new rank: %s!", StoreWeapon[entity], TierName[newTier]);

						if(newTier == (sizeof(TierName) - 1))
						{
							ClientCommand(client, "playgamesound ui/mm_medal_gold.wav");
							ClientCommand(client, "playgamesound ui/mm_medal_gold.wav");
							SPrintToChat(client, "%s has reached it's maximum potential!", StoreWeapon[entity]);
						}
						else
						{
							ClientCommand(client, "playgamesound ui/mm_rank_up_achieved.wav");
							ClientCommand(client, "playgamesound ui/mm_rank_up_achieved.wav");
						}
					}
					
					KeyValues kv = TextStore_GetItemKv(weapon.Store);
					if(kv)
					{
						static char data[512];
						ToMetaData(weapon, data);
						TextStore_SetItemData(weapon.Store, data);
					}
				}

				WeaponList.SetArray(i, weapon);

				for(i = 0; i < weapon.PerkCount; i++)
				{
					static TinkerEnum tinker;
					TinkerList.GetArray(weapon.Perks[i], tinker);
					if(tinker.FuncGainXP != INVALID_FUNCTION)
					{
						Call_StartFunction(null, tinker.FuncGainXP);
						Call_PushCell(client);
						Call_PushCell(entity);
						Call_Finish();
					}
				}

				break;
			}
		}
	}
}

void Tinker_DescItem(int index, char[] desc)
{
	static char data[512];
	TextStore_GetItemData(index, data, sizeof(data));
	strcopy(desc, 512, NULL_STRING);

	static char buffers[16][32];
	int perks, xp;
	int count = ExplodeString(data, ":", buffers, sizeof(buffers), sizeof(buffers[]));
	for(int i; i < count; i++)
	{
		if(!StrContains(buffers[i], "sell"))
			continue;
		
		if(!StrContains(buffers[i], "txp"))
		{
			xp = StringToInt(buffers[i][3]);
		}
		else if(!StrContains(buffers[i], "forge"))
		{
			if(i > 1)
			{
				ExplodeString(buffers[i], ",", buffers, 3, sizeof(buffers[]));

				int attribs[2];
				float values[2];

				attribs[0] = StringToInt(buffers[1]);
				values[0] = StringToFloat(buffers[2]);

				GetAttributeFormat(desc, attribs[0], values[0]);
				Stats_DescItem(desc, attribs, values, 1);
			}
		}
		else
		{
			Format(desc, 512, "%s\n%s", desc, buffers[i]);
			perks++;
		}
	}

	Format(desc, 512, "XP: %d%s", xp, desc);

	int limit = RoundToFloor(Pow(xp / 20.0, 0.5));
	if(limit >= sizeof(TierName))
		limit = sizeof(TierName) - 1;
	
	limit += 3;
	if(perks > limit)
		Format(desc, 512, "%s\n \nModifier Slots: %d", desc, perks - limit);
}

static void GetAttributeFormat(char[] desc, int attrib, float value)
{
	switch(attrib)
	{
		case 2:
			Format(desc, 512, "%s\n%s Physical Damage", desc, CharPercent(value));
		
		case 6:
			Format(desc, 512, "%s\n%s Fire Rate", desc, CharPercent(1.0 / value));
		
		case 96:
			Format(desc, 512, "%s\n%s Reload Speed", desc, CharPercent(1.0 / value));

		case 4009:
			Format(desc, 512, "%s\n%s Damage Resistance", desc, CharPercent(1.0 / value));
		
		case 410:
			Format(desc, 512, "%s\n%s Magic Damage", desc, CharPercent(value));
		
		case 2016:
			Format(desc, 512, "%s\n%s Tool Efficiency", desc, CharPercent(value));
	}
}

bool Tinker_Interact(int client, int entity, int weapon)
{
	StringMapSnapshot snap = NPCList.Snapshot();

	bool result;
	int length = snap.Length;
	for(int i; i < length; i++)
	{
		int size = snap.KeyBufferSize(i) + 1;
		char[] name = new char[size];
		snap.GetKey(i, name, size);

		static TinkerNPCEnum npc;
		NPCList.GetArray(name, npc, sizeof(npc));
		if(EntRefToEntIndex(npc.EntRef) == entity)
		{
			CurrentWeapon[client] = Store_GetStoreOfEntity(weapon);
			if(CurrentWeapon[client])
				ShowMenu(client, -1);
			
			result = true;
			break;
		}
	}

	delete snap;
	return result;
}

static void ShowMenu(int client, int page)
{
	Menu menu = new Menu(Tinker_MainMenu);

	static char buffer[512];

	switch(page)
	{
		case -1, -2, -5:
		{
			TextStore_GetItemName(CurrentWeapon[client], buffer, sizeof(buffer));
			menu.SetTitle("RPG Fortress\n \nForge: %s\n ", buffer);

			KeyValues kv = TextStore_GetItemKv(CurrentWeapon[client]);
			if(kv)
			{
				if(CurrentWeapon[client] < 0)
				{
					static WeaponEnum weapon;
					int length = WeaponList.Length;
					for(int i; i < length; i++)
					{
						WeaponList.GetArray(i, weapon);
						if(weapon.Owner == client && weapon.Store == CurrentWeapon[client])
						{
							menu.AddItem("-3", "Rename");
							menu.AddItem("-4", "Tinker\n ");

							if((weapon.Tier() + 3) > weapon.PerkCount)
							{
								bool hasFunc[4];
								
								hasFunc[0] = view_as<bool>(buffer[0]);
								kv.GetString("func_attack", buffer, sizeof(buffer));

								int tool = FLAG_ALL;
								if(kv.GetNum("is_a_wand"))
								{
									tool = FLAG_WAND;
								}
								else if(Mining_IsPickaxeFunc(buffer))
								{
									tool = FLAG_MINE;
								}
								else if(Fishing_IsFishingFunc(buffer))
								{
									tool = FLAG_FISH;
								}
								else if(kv.GetNum("is_a_wrench"))
								{
									tool = FLAG_WRENCH;
								}
								else
								{
									kv.GetString("classname", buffer, sizeof(buffer));
									if(TF2_GetClassnameSlot(buffer) == TFWeaponSlot_Melee)
									{
										tool = FLAG_MELEE;
									}
									else
									{
										tool = FLAG_RANGE;
									}
								}

								kv.GetString("func_attack2", buffer, sizeof(buffer));
								hasFunc[1] = view_as<bool>(buffer[0]);
								
								kv.GetString("func_attack3", buffer, sizeof(buffer));
								hasFunc[2] = view_as<bool>(buffer[0]);
								
								kv.GetString("func_reload", buffer, sizeof(buffer));
								hasFunc[3] = view_as<bool>(buffer[0]);

								static TinkerEnum tinker;
								for(i = 0; i < weapon.PerkCount; i++)
								{
									TinkerList.GetArray(weapon.Perks[i], tinker);

									if(!hasFunc[0])
										hasFunc[0] = tinker.FuncAttack != INVALID_FUNCTION;

									if(!hasFunc[1])
										hasFunc[1] = tinker.FuncAttack2 != INVALID_FUNCTION;

									if(!hasFunc[2])
										hasFunc[2] = tinker.FuncAttack3 != INVALID_FUNCTION;

									if(!hasFunc[3])
										hasFunc[3] = tinker.FuncReload != INVALID_FUNCTION;
								}

								length = TinkerList.Length;
								for(i = 0; i < length; i++)
								{
									TinkerList.GetArray(i, tinker);
									if((tinker.ToolFlags & tool) &&
									 (!hasFunc[0] || tinker.FuncAttack == INVALID_FUNCTION) &&
									 (!hasFunc[1] || tinker.FuncAttack2 == INVALID_FUNCTION) &&
									 (!hasFunc[2] || tinker.FuncAttack3 == INVALID_FUNCTION) &&
									 (!hasFunc[3] || tinker.FuncReload == INVALID_FUNCTION))
									{
										bool found;
										for(int a; a < weapon.PerkCount; a++)
										{
											if(weapon.Perks[a] == i)
											{
												found = true;
												break;
											}
										}
										
										if(found)
											continue;

										IntToString(i, buffer, sizeof(buffer));
										menu.AddItem(buffer, tinker.Name);
									}
								}
							}

							break;
						}
					}
				}
				else
				{
					if(kv.GetNum("forgable", 1))
					{
						int cash = TextStore_Cash(client);
						Format(buffer, sizeof(buffer), "Forge Item (%d / %d Credits)", cash, FORGE_COST);
						menu.AddItem("-2", buffer, cash < FORGE_COST ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
					}
					else
					{
						menu.AddItem("-1", "Can't Forge This Item", ITEMDRAW_DISABLED);
					}
				}
			}
		}
		case -3:
		{
			TextStore_GetItemName(CurrentWeapon[client], buffer, sizeof(buffer));
			menu.SetTitle("RPG Fortress\n \nForge: %s\n \nType in chat to enter a name for your item\n ", buffer);

			menu.AddItem("-5", "Set Default");

			menu.ExitBackButton = true;
		}
		case -4, -6:
		{
			TextStore_GetItemName(CurrentWeapon[client], buffer, sizeof(buffer));
			Format(buffer, sizeof(buffer), "RPG Fortress\n \nForge: %s\n \nCurrent Tinker Stats:", buffer);
			
			bool first;
			int cost;

			KeyValues kv = TextStore_GetItemKv(CurrentWeapon[client]);
			if(kv)
			{
				static WeaponEnum weapon;
				int length = WeaponList.Length;
				for(int i; i < length; i++)
				{
					WeaponList.GetArray(i, weapon);
					if(weapon.Owner == client && weapon.Store == CurrentWeapon[client])
					{
						if(weapon.ForgeCount)
						{
							cost = REROLL_COST;

							for(int a; a < weapon.ForgeCount; a++)
							{
								GetAttributeFormat(buffer, weapon.Forge[a], weapon.Value[a]);
							}
							
							Stats_DescItem(buffer, weapon.Forge, weapon.Value, weapon.ForgeCount);
						}
						else
						{
							cost = ROLLING_COST;
							first = true;
						}
					}
				}
			}

			menu.SetTitle("%s\n ", buffer);

			int cash = TextStore_Cash(client);

			if(first)
			{
				Format(buffer, sizeof(buffer), "Roll For Random Attributes (%d / %d Credits)", cash, cost);
			}
			else
			{
				Format(buffer, sizeof(buffer), "Reroll (%d / %d Credits)", cash, cost);
			}

			menu.AddItem("-6", buffer, cash < cost ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

			menu.ExitBackButton = true;
		}
		default:
		{
			if(page >= 0)
			{
				KeyValues kv = TextStore_GetItemKv(CurrentWeapon[client]);
				if(kv)
				{
					static WeaponEnum weapon;
					int length = WeaponList.Length;
					for(int i; i < length; i++)
					{
						WeaponList.GetArray(i, weapon);
						if(weapon.Owner == client && weapon.Store == CurrentWeapon[client])
						{
							int level = kv.GetNum("level");
							
							static TinkerEnum tinker;
							for(i = 0; i < weapon.PerkCount; i++)
							{
								TinkerList.GetArray(weapon.Perks[i], tinker);
								level += tinker.Levels;
							}

							TinkerList.GetArray(page, tinker);
							Format(buffer, sizeof(buffer), "%s\n ", tinker.Desc);

							bool failed;
							if(tinker.Cost1[0])
							{
								int count = TextStore_GetItemCount(client, tinker.Cost1);
								Format(buffer, sizeof(buffer), "%s\n%s (%d / %d)", buffer, tinker.Cost1, count, tinker.Amount1);

								if(!failed)
									failed = count < tinker.Amount1;
							}

							if(tinker.Cost2[0])
							{
								int count = TextStore_GetItemCount(client, tinker.Cost2);
								Format(buffer, sizeof(buffer), "%s\n%s (%d / %d)", buffer, tinker.Cost2, count, tinker.Amount2);

								if(!failed)
									failed = count < tinker.Amount2;
							}

							if(tinker.Cost3[0])
							{
								int count = TextStore_GetItemCount(client, tinker.Cost3);
								Format(buffer, sizeof(buffer), "%s\n%s (%d / %d)", buffer, tinker.Cost2, count, tinker.Amount3);

								if(!failed)
									failed = count < tinker.Amount3;
							}

							if(tinker.Credits)
							{
								int count = TextStore_Cash(client);
								Format(buffer, sizeof(buffer), "%s\nCredits (%d / %d)", buffer, count, tinker.Credits);

								if(!failed)
									failed = count < tinker.Credits;
							}

							if(tinker.Levels)
							{
								Format(buffer, sizeof(buffer), "%s\nLevel %d -> Level %d", buffer, level, level + tinker.Levels);

								if(!failed)
									failed = Level[client] < (level + tinker.Levels);
							}

							menu.SetTitle("%s\n \nModifier Limit: (%d / %d)", buffer, weapon.PerkCount, weapon.Tier() + 3);

							TextStore_GetItemName(CurrentWeapon[client], buffer, sizeof(buffer));
							Format(buffer, sizeof(buffer), "Apply %s on %s", tinker.Name, buffer);

							IntToString(page, tinker.Cost1, sizeof(tinker.Cost1));
							menu.AddItem(tinker.Cost1, buffer, failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
							break;
						}
					}

					menu.ExitBackButton = true;
				}
			}
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);

	if(page == -3)
		ChatListen[client] = true;
}

bool Tinker_SayCommand(int client)
{
	if(!ChatListen[client])
		return false;
	
	static char buffer[48];
	int size = GetCmdArgString(buffer, sizeof(buffer));
	if(size > 45)
	{
		SPrintToChat(client, "Your name must be below 46 characters.");
	}
	else if(StrContains(buffer, ";") != -1 || StrContains(buffer, "'") != -1 || StrContains(buffer, "\\") != -1)
	{
		SPrintToChat(client, "Your name contains invalid characters.");
	}
	else
	{
		ReplaceString(buffer, sizeof(buffer), "\"", "");
		Format(buffer, sizeof(buffer), "\"%s\"", buffer);
		TextStore_SetItemName(CurrentWeapon[client], buffer);

		ShowMenu(client, -1);
	}
	return true;
}

public int Tinker_MainMenu(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ChatListen[client] = false;

			if(choice == MenuCancel_ExitBack)
				ShowMenu(client, -1);
		}
		case MenuAction_Select:
		{
			ChatListen[client] = false;

			static char data[512];
			menu.GetItem(choice, data, sizeof(data));

			int page = StringToInt(data);
			switch(page)
			{
				case -2:
				{
					CurrentWeapon[client] = ConvertToTinker(client, CurrentWeapon[client]);
					TF2_RegeneratePlayer(client);
				}
				case -5:
				{
					TextStore_SetItemName(CurrentWeapon[client], NULL_STRING);
				}
				case -6:
				{
					KeyValues kv = TextStore_GetItemKv(CurrentWeapon[client]);
					if(kv)
					{
						static WeaponEnum weapon;
						int length = WeaponList.Length;
						for(int i; i < length; i++)
						{
							WeaponList.GetArray(i, weapon);
							if(weapon.Owner == client && weapon.Store == CurrentWeapon[client])
							{
								int cost = ROLLING_COST;
								if(weapon.ForgeCount)
									cost = REROLL_COST;
								
								TextStore_Cash(client, -cost);

								kv.GetString("func_attack", data, sizeof(data));

								int tool = FLAG_ALL;
								if(kv.GetNum("is_a_wand"))
								{
									tool = FLAG_WAND;
								}
								else if(Mining_IsPickaxeFunc(data))
								{
									tool = FLAG_MINE;
								}
								else if(Fishing_IsFishingFunc(data))
								{
									tool = FLAG_FISH;
								}
								else if(kv.GetNum("is_a_wrench"))
								{
									tool = FLAG_WRENCH;
								}
								else
								{
									kv.GetString("classname", data, sizeof(data));
									if(TF2_GetClassnameSlot(data) == TFWeaponSlot_Melee)
									{
										tool = FLAG_MELEE;
									}
									else
									{
										tool = FLAG_RANGE;
									}
								}

								RollRandomAttribs(Level[client], weapon, tool);
								WeaponList.SetArray(i, weapon);

								ToMetaData(weapon, data);
								TextStore_SetItemData(weapon.Store, data);
								TF2_RegeneratePlayer(client);
								break;
							}
						}
					}
				}
				default:
				{
					if(!choice && page >= 0)
					{
						KeyValues kv = TextStore_GetItemKv(CurrentWeapon[client]);
						if(kv)
						{
							static WeaponEnum weapon;
							int length = WeaponList.Length;
							for(int i; i < length; i++)
							{
								WeaponList.GetArray(i, weapon);
								if(weapon.Owner == client && weapon.Store == CurrentWeapon[client])
								{
									static TinkerEnum tinker;
									TinkerList.GetArray(page, tinker);

									if(tinker.Cost1[0] && TextStore_GetItemCount(client, tinker.Cost1) < tinker.Amount1)
										break;
									
									if(tinker.Cost2[0] && TextStore_GetItemCount(client, tinker.Cost2) < tinker.Amount2)
										break;
									
									if(tinker.Cost3[0] && TextStore_GetItemCount(client, tinker.Cost3) < tinker.Amount3)
										break;
									
									if(tinker.Credits)
									{
										int cash = TextStore_Cash(client);
										if(cash < tinker.Credits)
											break;
										
										TextStore_Cash(client, -tinker.Credits);
									}

									if(tinker.Cost1[0])
										TextStore_AddItemCount(client, tinker.Cost1, -tinker.Amount1);

									if(tinker.Cost2[0])
										TextStore_AddItemCount(client, tinker.Cost2, -tinker.Amount2);

									if(tinker.Cost3[0])
										TextStore_AddItemCount(client, tinker.Cost3, -tinker.Amount3);
									
									weapon.Perks[weapon.PerkCount++] = page;
									WeaponList.SetArray(i, weapon);

									ToMetaData(weapon, data);
									TextStore_SetItemData(weapon.Store, data);
									TF2_RegeneratePlayer(client);
									break;
								}
							}
						}

						page = -1;
					}
				}
			}

			ShowMenu(client, page);
		}
	}
	return 0;
}

static void RollRandomAttribs(int level, WeaponEnum weapon, int tool)
{
	weapon.ForgeCount = 0;

	int fails;
	int length = ForgeList.Length;
	while(weapon.ForgeCount < 4)
	{
		static ForgeEnum forge;
		ForgeList.GetArray(GetURandomInt() % length, forge);
		if(fails < 9 && (forge.MinLevel > level || forge.MaxLevel < level))
		{
			fails++;
			continue;
		}

		if(fails < 19 && !(forge.ToolFlags & tool))
		{
			fails++;
			continue;
		}

		weapon.Forge[weapon.ForgeCount] = forge.Attrib;
		
		float value = 1.0;
		switch(weapon.ForgeCount)
		{
			case 0:
			{
				switch(forge.Type)
				{
					case 0:
						value = GetRandomFloat(1.0, forge.High);
					
					case 1:
						value = GetRandomFloat(forge.Low, 1.0);
					
					case 2:
						value = GetRandomFloat(0.0, forge.High);
				}
			}
			case 1:
			{
				switch(forge.Type)
				{
					case 0:
						value = GetRandomFloat(forge.Low, 1.0);
					
					case 1:
						value = GetRandomFloat(1.0, forge.High);
					
					case 2:
						value = GetRandomFloat(forge.Low, 0.0);
				}
			}
			default:
			{
				value = GetRandomFloat(forge.Low, forge.High);
			}
		}
		
		int compress = RoundFloat(value * 100.0);

		if(fails < 29)
		{
			if((compress == 0 && forge.Type == 2) ||
				(compress == 100 && forge.Type != 2))
			{
				fails++;
				continue;
			}
		}
		
		weapon.Value[weapon.ForgeCount++] = compress / 100.0;

		if(weapon.ForgeCount > 1 && GetURandomInt() % 2)
			break;
	}
}

void Tinker_StatsLevelUp(int client, int oldLevel)
{
	int count;
	int length = TinkerList.Length;
	for(int i; i < length; i++)
	{
		static TinkerEnum tinker;
		TinkerList.GetArray(i, tinker);
		if(tinker.PlayerLevel > oldLevel && tinker.PlayerLevel <= Level[client])
			count++;
	}

	if(count)
	{
		SPrintToChat(client, "%d New Modifiers In Forge", count);
	}

	count = 0;
	length = ForgeList.Length;
	for(int i; i < length; i++)
	{
		static ForgeEnum forge;
		ForgeList.GetArray(i, forge);
		if(forge.MinLevel > oldLevel && forge.MinLevel <= Level[client])
			count++;
		
		if(forge.MaxLevel > oldLevel && forge.MaxLevel <= Level[client])
			count++;
	}

	if(count > 0)
	{
		SPrintToChat(client, "%d New Attributes In Tinker", count);
	}
}

void Tinker_Mining(int client, int entity, int toolTier, int mineTier, int &damage)
{
	int index = Store_GetStoreOfEntity(entity);
	if(index < 0)
	{
		static WeaponEnum weapon;
		int length = WeaponList.Length;
		for(int i; i < length; i++)
		{
			WeaponList.GetArray(i, weapon);
			if(weapon.Store == index && weapon.Owner == client)
			{
				for(i = 0; i < weapon.PerkCount; i++)
				{
					static TinkerEnum tinker;
					TinkerList.GetArray(weapon.Perks[i], tinker);
					if(tinker.FuncMining != INVALID_FUNCTION)
					{
						Call_StartFunction(null, tinker.FuncMining);
						Call_PushCell(client);
						Call_PushCell(entity);
						Call_PushCell(toolTier);
						Call_PushCell(mineTier);
						Call_PushCellRef(damage);
						Call_Finish();
					}
				}

				break;
			}
		}
	}
}

public void Tinker_XP_Ecological(int client, int weapon)
{
	if(!(GetURandomInt() % 6))
	{
		float pos[3];
		GetClientEyePosition(client, pos);
		TextStore_DropNamedItem(client, "Wood", pos, 1);
	}
}

public void Tinker_XP_Glassy(int client, int weapon)
{
	Attributes_SetMulti(weapon, 2, 0.99);

	if(Attributes_Has(weapon, 410))
		Attributes_SetMulti(weapon, 410, 0.99);
	
	if(Attributes_Has(weapon, 2016))
		Attributes_SetMulti(weapon, 2016, 0.98);
}

public void Tinker_XP_Dense(int client, int weapon)
{
	Attributes_SetMulti(weapon, 2, 1.005);

	if(Attributes_Has(weapon, 410))
		Attributes_SetMulti(weapon, 410, 1.005);
	
	if(Attributes_Has(weapon, 2016))
		Attributes_SetMulti(weapon, 2016, 1.01);
}

public void Tinker_Attack_Addiction(int client, int weapon, bool crit, int slot)
{
	if(Ability_Check_Cooldown(client, slot) < 0.0)
	{
		int damage = SDKCall_GetMaxHealth(client) * 2 / 5;
		int health = GetClientHealth(client);
		if(damage >= health)
			damage = health - 1;
		
		SetEntityHealth(client, health - damage);
		TF2_AddCondition(client, TFCond_MarkedForDeath, 5.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 5.0);
		Ability_Apply_Cooldown(client, slot, 30.0);
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
}

public void Tinker_XP_Stonebound(int client, int weapon)
{
	static float f_MomentumAntiOpSpam[MAXENTITIES];
	if(fabs(f_MomentumAntiOpSpam[weapon] - GetGameTime()) < 1.5)
	{
		//dont do anything.
		return;
	}
	f_MomentumAntiOpSpam[weapon] = GetGameTime();
	ApplyTempAttrib(weapon, 6, 0.985, 45.0);
	ApplyTempAttrib(weapon, 2, 0.985, 45.0);

	if(Attributes_Has(weapon, 410))
		ApplyTempAttrib(weapon, 410, 0.985, 45.0);
}

public void Tinker_XP_Momentum(int client, int weapon)
{
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 6.0, client);
}

public void Tinker_XP_Momentum2(int client, int weapon)
{
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 12.0, client);
}

public void Tinker_Mining_Unnatural(int client, int weapon, int toolTier, int mineTier, int &damage)
{
	damage += 1 * (toolTier - mineTier);
}
