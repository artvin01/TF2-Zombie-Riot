#pragma semicolon 1
#pragma newdecls required

// Amount of aspect (kills) needed for one part of a potion
#define ASPECT_REQUIRED	8.5

static const char AspectName[][] =
{
	"Muscle",
	"Health",
	"Form",
	"Mind",
	"Enhance",

	"Water",
	"Void"
};

enum
{
	// Global
	A_Strength,
	A_Resistance,
	A_Agility,
	A_Mind,
	A_Enhance,

	// Specific
	A_Water,
	A_Void,

	Aspect_MAX
}

enum struct BrewEnum
{
	int AccountId;
	int StoreIndex;
	int TypeIndex;
	float Multi;
	float EndAt;
	int EntRef;
	float EntMulti[TINKER_LIMIT];
}

static const float Cooldowns[] = { 210.0, 190.0, 170.0, 150.0, 130.0, 110.0, 90.0 };

static float Aspects[MAXPLAYERS][Aspect_MAX];
static int AspectMenu[MAXPLAYERS][3];
static int SellingType[MAXPLAYERS];
static int SellingAmount[MAXPLAYERS];
static float SellingPower[MAXPLAYERS];
static float SellingTime[MAXPLAYERS];
static bool InMenu[MAXPLAYERS];
static int RandomSeed;
static ArrayList Brews;
static ArrayList Crafts;
static Handle BrewTimer;

enum struct CraftEnum
{
	Function Func;
	int Aspect1;	// More of this gives more powerful effects
	int Aspect2;	// More of this gives longer lasting effects
	int Aspect3;
	
	void Add(Function func, int a1, int a2, int a3)
	{
		this.Func = func;
		this.Aspect1 = a1;
		this.Aspect2 = a2;
		this.Aspect3 = a3;

		Crafts.PushArray(this);
	}
}

static float GetGameTimeBrew()
{
	return GetGameTime();
}

void BlacksmithBrew_RoundStart()
{
	Zero2(Aspects);
	Zero2(AspectMenu);
	Zero(SellingType);
	Zero(SellingAmount);
	Zero(SellingPower);
	Zero(SellingTime);
	delete Brews;
	delete Crafts;
	delete BrewTimer;
	RandomSeed = GetURandomInt() / 2;
}

static void CacheBrewer()
{
	if(!BrewTimer)
		BrewTimer = CreateTimer(1.0, BlacksmithBrew_GlobalTimer, _, TIMER_REPEAT);
	
	if(!Brews)
		Brews = new ArrayList(sizeof(BrewEnum));
	
	if(Crafts)
		return;
	
	Crafts = new ArrayList(sizeof(CraftEnum));

	CraftEnum c;
	c.Add(Brew_Default, -1, -1, -1);

	c.Add(Brew_012, A_Agility, A_Strength, A_Resistance);
	c.Add(Brew_013, A_Strength, A_Mind, A_Resistance);
	c.Add(Brew_014, A_Strength, A_Enhance, A_Resistance);
	c.Add(Brew_023, A_Agility, A_Mind, A_Strength);
	c.Add(Brew_024, A_Agility, A_Enhance, A_Strength);
	c.Add(Brew_034, A_Strength, A_Enhance, A_Mind);
	c.Add(Brew_123, A_Resistance, A_Mind, A_Agility);
	c.Add(Brew_124, A_Resistance, A_Enhance, A_Agility);
	c.Add(Brew_134, A_Resistance, A_Enhance, A_Mind);
	c.Add(Brew_234, A_Agility, A_Mind, A_Enhance);

	c.Add(Brew_512, A_Agility, A_Resistance, A_Water);
	c.Add(Brew_501, A_Resistance, A_Strength, A_Water);
	c.Add(Brew_514, A_Resistance, A_Enhance, A_Water);
	c.Add(Brew_523, A_Agility, A_Mind, A_Water);
	c.Add(Brew_524, A_Agility, A_Enhance, A_Water);
	c.Add(Brew_502, A_Agility, A_Strength, A_Water);
}

void BlacksmithBrew_ExtraDesc(int client, int weapon, bool first = false)
{
	if(Brews)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static BrewEnum brew;
			int length = Brews.Length;
			for(int a; a < length; a++)
			{
				Brews.GetArray(a, brew);
				if(brew.AccountId == account && brew.StoreIndex == StoreWeapon[weapon])
				{
					char name[64];
					int attrib[TINKER_LIMIT];
					float value[TINKER_LIMIT];
					int add[TINKER_LIMIT];
					LookupById(brew.TypeIndex, name, attrib, value, add);

					CPrintToChat(client, "{yellow}%s {default}(%.0fs %s)", name, brew.EndAt - GetGameTimeBrew(), first ? "Duration" : "Left");
					
					for(int b; b < sizeof(attrib); b++)
					{
						if(!attrib[b])
							break;
						
						if(add[b] || attrib[b] > 3999 || Attributes_Has(weapon, attrib[b]))
						{
							if(add[b] == 1)
							{
								value[b] *= brew.Multi * MultiScale(attrib[b]);
							}
							else
							{
								value[b] = 1.0 + ((value[b] - 1.0) * brew.Multi * MultiScale(attrib[b]));
							}

							Blacksmith_PrintAttribValue(client, attrib[b], value[b], brew.Multi * MultiScale(attrib[b]), add[b] == 1);
						}
					}

					return;
				}
			}
		}
	}

	PrintToChat(client, "No active effect");
}

void BlacksmithBrew_Enable(int client, int weapon)
{
	if(Brews)
	{
		int account = GetSteamAccountID(client, false);
		if(account)
		{
			static BrewEnum brew;
			int length = Brews.Length;
			for(int a; a < length; a++)
			{
				Brews.GetArray(a, brew);
				if(brew.AccountId == account && brew.StoreIndex == StoreWeapon[weapon])
				{
					brew.EntRef = EntIndexToEntRef(weapon);
					ApplyStatusEffect(weapon, weapon, "Crafted Potion", brew.EndAt - GetGameTime());

					int attrib[TINKER_LIMIT];
					float value[TINKER_LIMIT];
					int add[TINKER_LIMIT];
					LookupById(brew.TypeIndex, _, attrib, value, add);
					
					for(int b; b < sizeof(attrib); b++)
					{
						if(!attrib[b])
							break;
						
						brew.EntMulti[b] = MultiScale(attrib[b]);

						if(add[b] == 1)
						{
							value[b] *= brew.Multi * brew.EntMulti[b];
							Attributes_SetAdd(weapon, attrib[b], value[b]);
						}
						else if(attrib[b] > 3999 || add[b] || Attributes_Has(weapon, attrib[b]))
						{
							value[b] = 1.0 + ((value[b] - 1.0) * brew.Multi * brew.EntMulti[b]);
							Attributes_SetMulti(weapon, attrib[b], value[b]);
						}
					}

					Brews.SetArray(a, brew);
					break;
				}
			}
		}
	}
}

static float MultiScale(int attrib)
{
	// ALWAYS Return >1 for Buff, <1 for Nerf
	// If it's reverse, do 1.0 / value
	/*
		Didnt include repair speed here.
	*/
	switch(attrib)
	{
		//All defensive and resistive attributes!
		case 205, 206:
		{
			return PlayerCountResBuffScaling;
		}
		//HP values here!
		case 26:
		{
			return PlayerCountResBuffScaling;
		}
		//All damage attribs!
		case 410 , 2 , 1:
		{
			return PlayerCountBuffScaling;
		}
		//all attackspeed and reload speed attribs!
		case 6, 97:
		{
			return PlayerCountBuffAttackspeedScaling;
		}

		default:
		{
			//Do nothing.
		}
	}
	return 1.0;
}

void BlacksmithBrew_NPCTakeDamagePost(int victim, int attacker, float damage)
{
	if(attacker <= MaxClients && Merchant_IsAMerchant(attacker) && IsValidEntity(i_PlayerToCustomBuilding[attacker]))
	{
		int random = RandomSeed  + i_NpcInternalId[victim];
		int aspect = random % A_Water;

		// Special Aspects
		if(i_BleedType[victim] == BLEEDTYPE_SEABORN && !b_thisNpcIsABoss[victim] && (random % 9) == 0)
		{
			aspect = A_Water;
		}
		//else if(i_BleedType[victim] == BLEEDTYPE_VOID && (random % 9) == 0)
		//{
		//	aspect = A_Void;
		//}

		// Raid x100, Boss x10, Giant x2.5
		/*
			Here we compare Hp to max hp, so you cant ov erkill
		*/
		int MaxHealth = ReturnEntityMaxHealth(victim);
		if(damage >= float(MaxHealth))
			damage = float(MaxHealth);
			
		float gain = b_thisNpcIsARaid[victim] ? (50.0 * MultiGlobalHighHealthBoss) : (b_thisNpcIsABoss[victim] ? (10.0 * MultiGlobalHealth) : (b_IsGiant[victim] ? 2.5 : 1.0));
		gain = damage * gain / float(MaxHealth);
		Aspects[attacker][aspect] += gain;

		if(b_thisNpcIsABoss[victim])
		{
			// +1 or -1
			int aspect2 = (random + ((i_NpcInternalId[victim] % 2) ? 1 : -1)) % A_Water;
			if(i_BleedType[victim] == BLEEDTYPE_SEABORN)
				aspect2 = A_Water;
			
			Aspects[attacker][aspect2] += gain;

			if(InMenu[attacker])
			{
				char buffer[64];
				FormatEx(buffer, sizeof(buffer), "Gained %.2f％ %s and %s from %s", gain * 100.0 / ASPECT_REQUIRED, AspectName[aspect], AspectName[aspect2], c_NpcName[victim]);
				PotionMakingMenu(attacker, buffer);
			}
		}
		else if(InMenu[attacker])
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "Gained %.2f％ %s from %s", gain * 100.0 / ASPECT_REQUIRED, AspectName[aspect], c_NpcName[victim]);
			PotionMakingMenu(attacker, buffer);
		}
	}
}

static Action BlacksmithBrew_GlobalTimer(Handle timer)
{
	if(!Brews)
	{
		BrewTimer = null;
		return Plugin_Stop;
	}



	float gameTime = GetGameTimeBrew();
	
	static BrewEnum brew;
	int length = Brews.Length;
	for(int a; a < length; a++)
	{
		Brews.GetArray(a, brew);
		if(Waves_InSetup())
		{
			brew.EndAt += 1.0;
			if(brew.EntRef != -1)
			{
				int weapon = EntRefToEntIndex(brew.EntRef);
				if(weapon != -1)
				{
					ApplyStatusEffect(weapon, weapon, "Crafted Potion", brew.EndAt - GetGameTime());
				}
			}
			Brews.SetArray(a, brew);
			continue;
		}
		if(brew.EndAt < gameTime)
		{
			if(brew.EntRef != -1)
			{
				int weapon = EntRefToEntIndex(brew.EntRef);
				if(weapon != -1)
				{
					char buffer[64];
					int attrib[TINKER_LIMIT];
					float value[TINKER_LIMIT];
					int add[TINKER_LIMIT];
					LookupById(brew.TypeIndex, buffer, attrib, value, add);
					
					for(int b; b < sizeof(attrib); b++)
					{
						if(!attrib[b])
							break;
						
						if(add[b] == 1)
						{
							value[b] *= brew.Multi;
							Attributes_SetAdd(weapon, attrib[b], -value[b]);
						}
						else if(attrib[b] > 3999 || add[b] || Attributes_Has(weapon, attrib[b]))
						{
							value[b] = 1.0 + ((value[b] - 1.0) * brew.Multi);
							Attributes_SetMulti(weapon, attrib[b], 1.0 / value[b]);
						}
					}

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && GetSteamAccountID(client, false) == brew.AccountId)
						{
							if(brew.StoreIndex != -1)
							{
								char buffer2[64];
								Store_GetItemName(brew.StoreIndex, client, buffer2, sizeof(buffer2));
								CPrintToChat(client, "{yellow}%s {default}effect has ran out on {yellow}%s", buffer, buffer2);
							}
							break;
						}
					}
				}
			}

			Brews.Erase(a);
			break;
		}
	}

	return Plugin_Continue;
}

static int AnvilClickedOn[MAXPLAYERS];
static int ClickedWithWeapon[MAXPLAYERS];
void BlacksmithBrew_BuildingUsed(int entity, int client)
{
	AnvilClickedOn[client] = EntIndexToEntRef(entity);
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
		return;
	ClickedWithWeapon[client] = EntIndexToEntRef(weapon);

	if(f_MedicCallIngore[client] > GetGameTime() && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
	{
		PotionMakingMenu(client, " ");
	}
	else
	{
		Brew_Menu(client, entity);
	}
}

static void Brew_Menu(int client, int entity)
{
	if(dieingstate[client] == 0)
	{	
		CacheBrewer();

		CancelClientMenu(client);
		SetStoreMenuLogic(client, false);
		
		char buffer[64];
		Menu menu = new Menu(Brew_MenuH);
		AnyMenuOpen[client] = 1.0;

		SetGlobalTransTarget(client);
		
		menu.SetTitle("양조기로 뭘 하시겠습니까?\n ");

		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(owner == -1)
			owner = 0;
		
		char NameOfPotion[64];
		char NameOfPotion2[64];
		if(SellingAmount[owner] > 0)
		{
			LookupById(SellingType[owner], NameOfPotion);
		}
		else
		{
			strcopy(NameOfPotion, sizeof(NameOfPotion), "N/A");
		}

		Format(NameOfPotion2, sizeof(NameOfPotion2), "%s Desc", NameOfPotion);
		char buffer2[128];
		Format(buffer2, sizeof(buffer2), "Drink: %T (x%d)\n%T %T\n ", NameOfPotion,client, SellingAmount[owner], "Effect:",client,NameOfPotion2, client);
		menu.AddItem("-1", buffer2, SellingAmount[owner] > 0 ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
		{
			FormatEx(buffer, sizeof(buffer), "Brew a new potion");
			menu.AddItem("-2", buffer);
		}

		FormatEx(buffer, sizeof(buffer), "%t", "Display Current Stats");
		menu.AddItem("-3", buffer);
									
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}
}

static int Brew_MenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);
			int weapon;
			int anvil;
			int owner;
			
			if(IsValidClient(client))
			{
				weapon = EntRefToEntIndex(ClickedWithWeapon[client]);
				anvil = EntRefToEntIndex(AnvilClickedOn[client]);
			}
			else
				return 0;

			if(!IsValidEntity(weapon) || !IsValidEntity(anvil))
				return 0;
			else
			{
				owner = GetEntPropEnt(anvil, Prop_Send, "m_hOwnerEntity");
			}

			switch(id)
			{
				case -1:
				{
					BuildingUsed_Internal(weapon, anvil, client, owner);
				}
				case -2:
				{
					PotionMakingMenu(client);
				}
				case -3:
				{
					BlacksmithBrew_ExtraDesc(client, weapon);
				}
			}
		}
		case MenuAction_Cancel:
		{
			AnyMenuOpen[client] = 0.0;
			ResetStoreMenuLogic(client);
		}
	}
	return 0;
}

static void PotionMakingMenu(int client, const char[] msg = "")
{
	CacheBrewer();
	if(AspectMenu[client][0] == AspectMenu[client][1])
	{
		AspectMenu[client][1]++;
		if(AspectMenu[client][1] >= Aspect_MAX)
			AspectMenu[client][1] = 0;
	}

	while(AspectMenu[client][0] == AspectMenu[client][2] || AspectMenu[client][1] == AspectMenu[client][2])
	{
		AspectMenu[client][2]++;
		if(AspectMenu[client][2] >= Aspect_MAX)
			AspectMenu[client][2] = 0;
	}

	CancelClientMenu(client);
	SetStoreMenuLogic(client, false);

	char buffer[64];

	Menu menu = new Menu(PotionMakingMenuH);
	AnyMenuOpen[client] = 1.0;

	if(msg[0])
	{
		menu.SetTitle("Brewing Stand:\n%s\n ", msg);
	}
	else
	{
		menu.SetTitle("Brewing Stand:\nClick on an Aspect to change, gain Aspect by dealing damage\n ");
	}

	bool failed;
	for(int i; i < 3; i++)
	{
		float precent = (Aspects[client][AspectMenu[client][i]] - 1.0) * 100.0 / ASPECT_REQUIRED;
		if(precent < 0.0)
			precent = 0.0;
		
		FormatEx(buffer, sizeof(buffer), "%s (%d％)", AspectName[AspectMenu[client][i]], RoundToFloor(precent));
		menu.AddItem(NULL_STRING, buffer);

		if(precent < 100.0)
			failed = true;
	}

	strcopy(buffer, sizeof(buffer), "N/A");
	if(LookupByAspect(AspectMenu[client][0], AspectMenu[client][1], AspectMenu[client][2], _, buffer) == -1)
		failed = true;

	char NameOfPotion[128];
	char NameOfPotion2[128];
	strcopy(NameOfPotion, sizeof(NameOfPotion), buffer);
	
	menu.AddItem(NULL_STRING, buffer, ITEMDRAW_SPACER);

	Format(NameOfPotion2, sizeof(NameOfPotion2), "%s Desc", NameOfPotion);
	char buffer2[128];
	Format(buffer2, sizeof(buffer2), "New Brew: %T\n%T %T\n ", NameOfPotion, client, "Effect:",client, NameOfPotion2, client);
	menu.AddItem(NULL_STRING, buffer2, failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if(SellingAmount[client] > 0)
	{
		LookupById(SellingType[client], buffer);
	}
	else
	{
		strcopy(buffer, sizeof(buffer), "N/A");
	}

	Format(buffer, sizeof(buffer), "Selling: %T (x%d)", buffer, client, SellingAmount[client]);
	menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);

	InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
}

static int PotionMakingMenuH(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Cancel:
		{
			AnyMenuOpen[client] = 0.0;
			InMenu[client] = false;
			ResetStoreMenuLogic(client);
		}
		case MenuAction_Select:
		{
			AnyMenuOpen[client] = 0.0;
			InMenu[client] = false;
			ResetStoreMenuLogic(client);
			
			int entity = EntRefToEntIndex(i_PlayerToCustomBuilding[client]);
			if(entity == -1)
				return 0;

			switch(choice)
			{
				case 0, 1, 2:
				{
					for(int a; a < sizeof(AspectMenu[]); a++)
					{
						if(a == choice)
							AspectMenu[client][a]++;
						
						for(;;)
						{
							if(AspectMenu[client][a] >= Aspect_MAX)
								AspectMenu[client][a] = 0;

							bool found;
							for(int b; b < sizeof(AspectMenu[]); b++)
							{
								if(a != b && AspectMenu[client][a] == AspectMenu[client][b])
								{
									found = true;
									break;
								}
							}

							if(found || (AspectMenu[client][a] >= A_Water && Aspects[client][AspectMenu[client][a]] < 1.0))
							{
								AspectMenu[client][a]++;
								continue;
							}

							break;
						}
					}

					PotionMakingMenu(client);
				}
				case 4:
				{
					CraftEnum craft;
					char buffer[64];
					int id = LookupByAspect(AspectMenu[client][0], AspectMenu[client][1], AspectMenu[client][2], craft, buffer);
					if(id != -1)
					{
						int level = MerchantLevelReturn(client);
						float limit = level > 2 ? 1.0 : (level > 1 ? 0.5 : 0.0);

						float power = -0.5 + ((Aspects[client][craft.Aspect1] - 1.0) / ASPECT_REQUIRED / 2.0);
						float time = -0.5 + ((Aspects[client][craft.Aspect2] - 1.0) / ASPECT_REQUIRED / 2.0);
						
						if((power + time) > limit)
						{
							float ratio1 = power / (power + time);
							float ratio2 = time / (power + time);
							
							power = ratio1 * limit;
							time = ratio2 * limit;
						}

						power += 1.0;
						time += 1.0;

						Aspects[client][craft.Aspect1] = 1.0;
						Aspects[client][craft.Aspect2] = 1.0;
						Aspects[client][craft.Aspect3] -= ASPECT_REQUIRED;

						SellingType[client] = id;
						SellingAmount[client] = RoundToFloor(5.0 / PlayerCountBuffScaling);
						SellingPower[client] = power;
						SellingTime[client] = time;

						ObjectTinkerBrew_TogglePotion(entity, true);

						ClientCommand(client, "playgamesound ui/chem_set_creation.wav");
						ClientCommand(client, "playgamesound ui/chem_set_creation.wav");
						CPrintToChat(client, "Brewed {yellow}%s {default}x%d with {yellow}%.0f％ {default}power and {yellow}%.0f％ {default}duration", buffer, SellingAmount[client], power * 100.0, time * 100.0);
					}

					BlacksmithBrew_BuildingUsed(entity, client);
				}
			}
		}
	}
	return 0;
}

static void BuildingUsed_Internal(int weapon, int entity, int client, int owner)
{
	if(owner != -1)
	{
		int level = MerchantLevelReturn(owner);

		if(level >= 0)
		{
			int account = GetSteamAccountID(client, false);
			if(!account)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				ApplyBuildingCollectCooldown(entity, client, 3.0);
				return;
			}

			static BrewEnum brew;
			int length = Brews.Length;
			for(int a; a < length; a++)
			{
				Brews.GetArray(a, brew);
				if(brew.AccountId == account/* && brew.StoreIndex == StoreWeapon[weapon]*/)
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "An effect is already active!");// for this weapon!");
					ApplyBuildingCollectCooldown(entity, client, 2.0);
					return;
				}
			}

			if(SellingAmount[owner] > 0)
			{
				char buffer[64];
				int attrib[TINKER_LIMIT];
				float value[TINKER_LIMIT];
				int add[TINKER_LIMIT];
				float time = LookupById(SellingType[owner], buffer, attrib, value, add);

				bool found;
				for(int b; b < sizeof(attrib); b++)
				{
					if(!attrib[b])
						break;
					
					if(add[b] || attrib[b] > 3999 || Attributes_Has(weapon, attrib[b]))
					{
						found = true;
						break;
					}
				}

				if(!found)
				{
					ClientCommand(client, "playgamesound items/medshotno1.wav");
					SetDefaultHudPosition(client);
					ShowSyncHudText(client, SyncHud_Notifaction, "Weapon No Effect Tinker");
					ApplyBuildingCollectCooldown(entity, client, 2.0);
					return;
				}

				time = time * SellingTime[owner];

				brew.AccountId = account;
				brew.EntRef = -1;
				brew.StoreIndex = StoreWeapon[weapon];
				brew.TypeIndex = SellingType[owner];
				brew.Multi = SellingPower[owner];
				brew.EndAt = GetGameTimeBrew() + time;
				Brews.PushArray(brew);

				SellingAmount[owner]--;

				BlacksmithBrew_ExtraDesc(client, weapon, true);

				Building_GiveRewardsUse(client, owner, 40, true, 1.0, true);
				Store_ApplyAttribs(client);
				Store_GiveAll(client, GetClientHealth(client));

				if(SellingAmount[owner] == 0)
					ObjectTinkerBrew_TogglePotion(entity, false);
				else if(SellingAmount[owner] > 0)
				{
					ObjectTinkerBrew_TogglePotion(entity, true);
				}

				if(client == owner && SellingAmount[owner] == 0)
				{
					ClientCommand(client, "playgamesound ui/quest_status_tick_novice_complete.wav");
				}
				else
				{
					ClientCommand(client, "playgamesound ui/quest_status_tick_novice.wav");
				}

				if(client != owner)
				{
					float cooldown = Cooldowns[level];
					if(Store_HasWeaponKit(client))
						cooldown *= 0.5;
					
					ApplyBuildingCollectCooldown(entity, client, cooldown);

					if(SellingAmount[owner] == 0)
					{
						ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_complete_pda.wav");
					}
					else if(!Rogue_Mode())
					{
						ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
					}
				}

				return;
			}
		}
	}

	DestroyBuildingDo(entity);
	SPrintToChat(client, "%t", "The Blacksmith Failed!");
	ApplyBuildingCollectCooldown(entity, client, 3.0);
}

static int LookupByAspect(int a1, int a2, int a3, CraftEnum craft = {}, char name[64] = {}, int attrib[TINKER_LIMIT] = {}, float value[TINKER_LIMIT] = {}, int add[TINKER_LIMIT] = {}, float &time = 0.0)
{
	int length = Crafts.Length;
	for(int i; i < length; i++)
	{
		Crafts.GetArray(i, craft);
		if(craft.Aspect1 != a1 && craft.Aspect1 != a2 && craft.Aspect1 != a3)
			continue;
		
		if(craft.Aspect2 != a1 && craft.Aspect2 != a2 && craft.Aspect2 != a3)
			continue;
		
		if(craft.Aspect3 != a1 && craft.Aspect3 != a2 && craft.Aspect3 != a3)
			continue;

		time = CallFunc(craft, name, attrib, value, add);
		return i;
	}

	return -1;
}

static float LookupById(int id, char name[64] = {}, int attrib[TINKER_LIMIT] = {}, float value[TINKER_LIMIT] = {}, int add[TINKER_LIMIT] = {})
{
	static CraftEnum craft;
	Crafts.GetArray(id, craft);
	return CallFunc(craft, name, attrib, value, add);
}

static float CallFunc(CraftEnum craft, char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	float time;
	Call_StartFunction(null, craft.Func);
	Call_PushStringEx(name, sizeof(name), SM_PARAM_STRING_COPY, SM_PARAM_COPYBACK);
	Call_PushArrayEx(attrib, sizeof(attrib), SM_PARAM_COPYBACK);
	Call_PushArrayEx(value, sizeof(value), SM_PARAM_COPYBACK);
	Call_PushArrayEx(add, sizeof(add), SM_PARAM_COPYBACK);
	Call_Finish(time);
	return time;
}

/*
	Aspect_Strength,
	Aspect_Resistance,
	Aspect_Agility,
	Aspect_Mind,
	Aspect_Enhance,

	Aspect_Water,
	Aspect_Void,
*/

static float Brew_Default(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Default Stew");
	attrib[0] = 6;
	value[0] = 0.98;
	attrib[1] = 8;
	value[1] = 1.15;
	return 180.0;
}

// Str* Res Agi^
static float Brew_012(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Flexibility");
	attrib[0] = 6;
	value[0] = 0.95;
	attrib[1] = 97;
	value[1] = 0.85;
	return 180.0;
}

// Str^ Res Min*
static float Brew_013(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Barrier");
	attrib[0] = 410;
	value[0] = 1.1;
	attrib[1] = 205;
	value[1] = 0.95;
	add[1] = 2;
	attrib[2] = 206;
	value[2] = 0.95;
	return 180.0;
}

// Str^ Res Enc*
static float Brew_014(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Strength");
	attrib[0] = 2;
	value[0] = 1.1;
	attrib[1] = 205;
	value[1] = 0.95;
	attrib[2] = 206;
	value[2] = 0.95;
	add[2] = 2;
	return 180.0;
}

// Str Agi^ Min*
static float Brew_023(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Casting");
	attrib[0] = 6;
	value[0] = 0.97;
	attrib[1] = 733;
	value[1] = 0.9;
	return 180.0;
}

// Str Agi* Enc^
static float Brew_024(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Beef");
	attrib[0] = 26;
	value[0] = 200.0;
	add[0] = 1;
	return 180.0;
}

// Str* Min Enc^
static float Brew_034(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Engineering");
	attrib[0] = 8;
	value[0] = 1.2;
	attrib[1] = 10;
	value[1] = 1.1;
	attrib[2] = 95;
	value[2] = 1.25;
	return 180.0;
}

// Res^ Agi Min*
static float Brew_123(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Stock");
	attrib[0] = 4019;
	value[0] = 1.1;
	add[0] = 2;
	return 180.0;
}

// Res^ Agi Enc*
static float Brew_124(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Boulder");
	attrib[0] = 252;
	value[0] = 0.5;
	add[0] = 2;
	attrib[1] = 205;
	value[1] = 0.95;
	add[1] = 2;
	attrib[2] = 206;
	value[2] = 0.95;
	add[2] = 2;
	return 180.0;
}

// Res^ Min Enc*
static float Brew_134(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Ripening");
	attrib[0] = 57;
	value[0] = 5.0;
	add[0] = 1;
	return 180.0;
}

// Agi^ Min* Enc
static float Brew_234(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Potion of Velocity");
	attrib[0] = 101;
	value[0] = 1.3;
	attrib[1] = 103;
	value[1] = 1.3;
	attrib[2] = 252;
	value[2] = 1.5;
	add[2] = 2;
	return 180.0;
}

// Wat Res* Agi^
static float Brew_512(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Assimilation");
	attrib[0] = Attrib_TerrianRes;
	value[0] = 0.6;
	add[0] = 2;
	return 150.0;
}

// Wat Str* Res^
static float Brew_501(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Freedom");
	attrib[0] = Attrib_SlowImmune;
	value[0] = 2.0;
	add[0] = 1;
	return 150.0;
}

// Wat Res^ Enc*
static float Brew_514(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Armor");
	attrib[0] = Attrib_ElementalDef;
	value[0] = 5.0;
	add[0] = 1;
	return 150.0;
}

// Wat Agi^ Min*
static float Brew_523(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Sanitizing");
	attrib[0] = Attrib_ObjTerrianAbsorb;
	value[0] = 3.0;
	add[0] = 1;
	return 150.0;
}

// Wat Agi^ Enc*
static float Brew_524(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Abyssal Hunter");
	attrib[0] = Attrib_SetArchetype;
	value[0] = 22.0;
	add[0] = 1;
	return 150.0;
}

// Wat Str* Agi^
static float Brew_502(char name[64], int attrib[TINKER_LIMIT], float value[TINKER_LIMIT], int add[TINKER_LIMIT])
{
	strcopy(name, sizeof(name), "Flask of Kazimierz");
	attrib[0] = Attrib_SetArchetype;
	value[0] = 23.0;
	add[0] = 1;
	return 150.0;
}
