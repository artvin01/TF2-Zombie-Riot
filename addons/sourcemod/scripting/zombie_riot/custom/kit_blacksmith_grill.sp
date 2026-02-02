#pragma semicolon 1
#pragma newdecls required

// Amount of Sauce (kills) needed for one part of a potion
#define SAUCE_REQUIRED	6.0
#define MAX_BURGERS_ALLOWED	20

/*
	- Armor Heal
	- Element Restore
	- Regen
	- Buff
	- +1 Down
*/

static const char SauceName[][] =
{
	"마요네즈",
	"케첩",
	"머스타드",
	"바베큐",
	"특별한 재료"
};

static const char EffectsSauce[][] =
{
	"및 원소 피해를 전부 제거함",
	"및 아머 +33％ 회복",
	"및 20초간 초당 체력 재생",
	"및 15초간 치유의 결의 버프 획득",
	"및 다운 횟수 1 증가"
};

enum
{
	// Global
	S_Mayo,
	S_Ketchup,
	S_Mustard,
	S_Barbecue,
	S_Special,

	Sauce_MAX
}

static const float Cooldowns[] = { 70.0, 65.0, 60.0, 55.0, 50.0, 45.0, 40.0 };

static float Meats[MAXPLAYERS];
static float Sauces[MAXPLAYERS][Sauce_MAX];
static int SauceSelected[MAXPLAYERS];
static ArrayList Selling[MAXPLAYERS];
static bool InMenu[MAXPLAYERS];
static int RandomSeed;

void BlacksmithGrill_RoundStart()
{
	Zero(Meats);
	Zero2(Sauces);
	RandomSeed = GetURandomInt() / 2;

	for(int i; i < sizeof(Selling); i++)
	{
		delete Selling[i];
	}

	for(int i; i < sizeof(SauceSelected); i++)
	{
		SauceSelected[i] = -1;
	}
}

void BlacksmithGrill_NPCTakeDamagePost(int victim, int attacker, float damage)
{
	if(attacker <= MaxClients && Merchant_IsAMerchant(attacker) && IsValidEntity(i_PlayerToCustomBuilding[attacker]))
	{
		bool bSandvich = view_as<bool>(Store_HasNamedItem(attacker, "Special Sandvich Recipe"));
		if(bSandvich)
		{
			if(InMenu[attacker])
			{
				char buffer[64];
				FormatEx(buffer, sizeof(buffer), "%t", "Inv Special Sandvich Recipe desc for grill");
				GrillingMenu(attacker, buffer);
			}
			return;
		}
		int random = RandomSeed + i_NpcInternalId[victim];
		int sauce = random % S_Special;

		if(!b_thisNpcIsARaid[victim] && b_thisNpcIsABoss[victim] && (random % 4) == 0)
			sauce = S_Special;

		// Raid x50, Boss x10, Giant x2.5
		/*
			Here we compare Hp to max hp, so you cant ov erkill
		*/
		int MaxHealth = ReturnEntityMaxHealth(victim);
		if(damage >= float(MaxHealth))
			damage = float(MaxHealth);
		
		float gain = b_thisNpcIsARaid[victim] ? (50.0 * MultiGlobalHighHealthBoss) : (b_thisNpcIsABoss[victim] ? (10.0 * MultiGlobalHealth) : (b_IsGiant[victim] ? 2.5 : 1.0));
		gain = damage * gain / float(MaxHealth);
		Sauces[attacker][sauce] += gain;
		Meats[attacker] += gain * 2.0;

		if(Meats[attacker] >= (SAUCE_REQUIRED * 20.0))
		{
			Meats[attacker] = SAUCE_REQUIRED * 20.0;
		}
		if(Sauces[attacker][sauce] >= (SAUCE_REQUIRED * 10.0))
		{
			Sauces[attacker][sauce] = SAUCE_REQUIRED * 10.0;
		}

		if(InMenu[attacker])
		{
			char buffer[64];
			FormatEx(buffer, sizeof(buffer), "Gained %.2f％ Meat and %.2f％ %s from %s", gain * 200.0 / SAUCE_REQUIRED, gain * 100.0 / SAUCE_REQUIRED, SauceName[sauce], NpcStats_ReturnNpcName(victim));
			GrillingMenu(attacker, buffer);
		}
	}
}

void BlacksmithGrill_BuildingUsed(int entity, int client)
{
	if(f_MedicCallIngore[client] > GetGameTime() && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
	{
		GrillingMenu(client);
	}
	else
	{
		GrillingUse(client, entity);
	}
}

static void GrillingUse(int client, int entity)
{
	if(dieingstate[client] != 0)
	{
		return;
	}
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner == -1)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	int level = MerchantLevelReturn(owner);

	if(level < 0)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		DestroyBuildingDo(entity);
		SPrintToChat(client, "%t", "The Blacksmith Failed!");
		return;
	}
	if(Selling[owner] && Selling[owner].Length > 0)
	{
		int sauce = Selling[owner].Get(0);
		Selling[owner].Erase(0);

		float healing = 120.0 * Attributes_GetOnPlayer(owner, 8, true);
		healing *= 0.5; //too op

		char buffer[128];
		FormatEx(buffer, sizeof(buffer), "체력 %d 회복", RoundFloat(healing));

		switch(sauce)
		{
			case S_Mayo:
			{
				if(Armor_Charge[client] < 0)
				{
					Armor_Charge[client] = 0;
				}
			}
			case S_Ketchup:
			{
				Armor_Charge[client] += MaxArmorCalculation(Armor_Level[client], client, 0.333);
			}
			case S_Mustard:
			{
				HealEntityGlobal(owner, client, healing / 10.0, _, 20.0);
			}
			case S_Barbecue:
			{
				ApplyStatusEffect(owner, client, "Healing Resolve", 15.0);
			}
			case S_Special:
			{
				if(i_AmountDowned[client] > 0)
				{
					i_AmountDowned[client]--;
				}
			}
		}

		if(sauce >= 0 && sauce < Sauce_MAX)
		{
			CPrintToChat(client, "{yellow}%s 버거{default}를 먹었습니다\n{green}%s", SauceName[sauce], EffectsSauce[sauce]);
		}
		else
		{
			CPrintToChat(client, "{yellow}평범한 버거{default}를 먹었습니다\n{green}%s", buffer);
		}

		HealEntityGlobal(owner, client, healing, _, 3.0);
		Building_GiveRewardsUse(client, owner, 15, true, 0.4, true);
		ObjectTinkerGrill_UpdateWearables(entity, Selling[owner].Length);

		ClientCommand(client, "playgamesound items/smallmedkit1.wav");
		ClientCommand(client, "playgamesound vo/sandwicheat09.mp3");
		
		float cooldown = Cooldowns[level];
		if(client == owner)
			cooldown *= 0.5;
		
		ApplyBuildingCollectCooldown(entity, client, cooldown);

		if(client != owner)
		{
			if(Selling[owner].Length == 0)
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_complete_pda.wav");
			}
			else if(!Rogue_Mode())
			{
				ClientCommand(owner, "playgamesound ui/quest_status_tick_novice_friend.wav");
			}
		}
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		ShowSyncHudText(client, SyncHud_Notifaction, "No Burger Left");
		ApplyBuildingCollectCooldown(entity, client, 2.0);
		return;
	}
}

static void GrillingMenu(int client, const char[] msg = "")
{
	CancelClientMenu(client);
	SetStoreMenuLogic(client, false);

	char buffer[64];

	Menu menu = new Menu(GrillingMenuH);
	AnyMenuOpen[client] = 1.0;

	if(msg[0])
	{
		menu.SetTitle("Grilling:\n%s\n ", msg);
	}
	else
	{
		menu.SetTitle("Grilling:\nGet meat and sauce by dealing damage\nChange the sauce by clicking on it\n ");
	}

	bool failed;

	if(SauceSelected[client] >= 0 && SauceSelected[client] < Sauce_MAX)
	{
		float precent = (Sauces[client][SauceSelected[client]] - 1.0) * 100.0 / SAUCE_REQUIRED;
		if(precent < 0.0)
			precent = 0.0;
		
		FormatEx(buffer, sizeof(buffer), "%s (%d％)\n%T Heals %s", SauceName[SauceSelected[client]], RoundToFloor(precent), "Effect:", client, EffectsSauce[SauceSelected[client]]);

		if(precent < 100.0)
			failed = true;
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "No Sauce\n%T Heals","Effect:", client);
	}
	
	menu.AddItem(NULL_STRING, buffer);
	menu.AddItem(NULL_STRING, buffer, ITEMDRAW_SPACER);

	if(Meats[client] < SAUCE_REQUIRED)
	{
		FormatEx(buffer, sizeof(buffer), "Grill Burger (%.0f％)\n ", Meats[client] * 100.0 / SAUCE_REQUIRED);
		failed = true;
	}
	else
	{
		FormatEx(buffer, sizeof(buffer), "Grill Burger (%d patties)\n ", RoundToFloor(Meats[client] / SAUCE_REQUIRED));
	}

	menu.AddItem(NULL_STRING, buffer, failed ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	
	if(Selling[client] && Selling[client].Length > 0)
	{
		int sauce = Selling[client].Get(0);
		if(sauce >= 0 && sauce < Sauce_MAX)
		{
			FormatEx(buffer, sizeof(buffer), "Next: %s Burger (x%d)", SauceName[sauce], Selling[client].Length);
		}
		else
		{
			FormatEx(buffer, sizeof(buffer), "Next: Plain Burger (x%d)", Selling[client].Length);
		}
		
		menu.AddItem(NULL_STRING, buffer, ITEMDRAW_DISABLED);
	}

	InMenu[client] = menu.Display(client, MENU_TIME_FOREVER);
}

static int GrillingMenuH(Menu menu, MenuAction action, int client, int choice)
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
				case 0:
				{
					SauceSelected[client]++;
					if(SauceSelected[client] >= Sauce_MAX)
						SauceSelected[client] = -1;

					GrillingMenu(client);
				}
				case 2:
				{
					if(!Selling[client])
						Selling[client] = new ArrayList();
					
					if(Selling[client].Length >= MAX_BURGERS_ALLOWED)
					{

						SetDefaultHudPosition(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "Too Many Burgers currently out");
						ClientCommand(client, "playgamesound items/medshotno1.wav");
						GrillingMenu(client);
						return 0;
					}
					Selling[client].Push(SauceSelected[client]);
					
					Meats[client] -= SAUCE_REQUIRED;
					if(SauceSelected[client] >= 0 && SauceSelected[client] < Sauce_MAX)
						Sauces[client][SauceSelected[client]] -= SAUCE_REQUIRED;
					
					ObjectTinkerGrill_UpdateWearables(entity, Selling[client].Length);

					ClientCommand(client, "playgamesound player/flame_out.wav");
					GrillingMenu(client);
				}
			}
		}
	}
	return 0;
}
