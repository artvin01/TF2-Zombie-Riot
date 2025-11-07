// Rogue1 Expansion Update Content

#pragma semicolon 1
#pragma newdecls required

enum struct SoulBuff
{
	int Client;
	int Weapon;
	int Type;
}

static ArrayList AnnouncedBuff;
static int RottenBone;
static int EmptyPlate;

void Rogue_Whiteflower_Reset()
{
	delete AnnouncedBuff;
}

bool Rogue_Whiteflower_RemainDrop(int type)
{
	if(!EmptyPlate)
		return false;
	
	EmptyPlate--;
	switch(type)
	{
		case Buff_Founder:
			Rogue_GiveNamedArtifact("Founder Fondue");
		
		case Buff_Predator:
			Rogue_GiveNamedArtifact("Predator Pancakes");
		
		case Buff_Brandguider:
			Rogue_GiveNamedArtifact("Brandguider Brunch");
		
		case Buff_Spewer:
			Rogue_GiveNamedArtifact("Spewer Spewers");
		
		case Buff_Swarmcaller:
			Rogue_GiveNamedArtifact("Swarmcaller Sandwich");
		
		case Buff_Reefbreaker:
			Rogue_GiveNamedArtifact("Reefbreaker Ravioli");
	}
	return true;
}

static void AnnounceSoulBuff(int client, int entity, int type)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	SoulBuff buff;

	if(AnnouncedBuff)
	{
		int length = AnnouncedBuff.Length;
		for(int i; i < length; i++)
		{
			AnnouncedBuff.GetArray(i, buff);
			if(buff.Client == client && buff.Weapon == StoreWeapon[entity] && buff.Type == type)
				return;
		}
	}

	buff.Client = client;
	buff.Weapon = StoreWeapon[entity];
	buff.Type = type;

	if(!AnnouncedBuff)
		AnnouncedBuff = new ArrayList(sizeof(SoulBuff));
	
	AnnouncedBuff.PushArray(buff);

	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer));
	CPrintToChat(client, "{olive}Your {green}%s {olive} received the power of the soul artifact!", buffer);
}

public void Rogue_SoulFreaks_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "Blitz", false) != -1 ||
		StrContains(buffer, "P15t0l", false) != -1 ||
		StrContains(buffer, "Terroriser Bomb Implanter", false) != -1 ||
		StrContains(buffer, "PhlogStorms Detonator", false) != -1 ||
		StrContains(buffer, "Knife", false) != -1 ||
		StrContains(buffer, "CBS's Blade", false) != -1 ||
		StrContains(buffer, "x10 Spy Main", false) != -1 ||
		StrContains(buffer, "HHH's Juniors Mini Axe", false) != -1 ||
		StrContains(buffer, "Fists Of Kahmlstein", false) != -1 ||
		StrContains(buffer, "Skull Servants", false) != -1 ||
		StrContains(buffer, "Wightmare", false) != -1 ||
		StrContains(buffer, "Aresenal's Tripmine Layer", false) != -1||
		Wkit_Soldin_BvB(client))
	{
		AnnounceSoulBuff(client, entity, 0);

		Attributes_SetMulti(entity, 524, 2.0);
	}
}

public void Rogue_SoulArknights_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(Store_IsWeaponFaction(client, entity, Faction_Seaborn) ||
		Store_IsWeaponFaction(client, entity, Faction_Kazimierz) ||
		Store_IsWeaponFaction(client, entity, Faction_Victoria) ||
		StrContains(buffer, "The Enforcer", false) != -1 ||
		StrContains(buffer, "Riot Gun", false) != -1 ||
		StrContains(buffer, "Angelica Shotgonnus", false) != -1 ||
		StrContains(buffer, "Полумесяц", false) != -1 ||
		StrContains(buffer, "Law's Order", false) != -1 ||
		StrContains(buffer, "Telum Pro Lege", false) != -1 ||
		StrContains(buffer, "Exactio Legis", false) != -1 ||
		StrContains(buffer, "Полнолуние", false) != -1 ||
		StrContains(buffer, "Затмение", false) != -1 ||
		StrContains(buffer, "Lapplands Sword", false) != -1 ||
		StrContains(buffer, "Quibai's Elegance", false) != -1 ||
		StrContains(buffer, "Preaching Sword", false) != -1 ||
		StrContains(buffer, "Guln's Blade", false) != -1 ||
		StrContains(buffer, "Judgement Of Iberia", false) != -1 ||
		StrContains(buffer, "Passanger's Device", false) != -1 ||
		StrContains(buffer, "The Standchen", false) != -1 ||
		StrContains(buffer, "Merchant's Wrench", false) != -1 ||
		StrContains(buffer, "Seaborn Claws", false) != -1 ||
		StrContains(buffer, "Explosive Dawn", false) != -1 ||
		StrContains(buffer, "Ancestor Launcher", false) != -1 ||
		StrContains(buffer, "Whistle Stop", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 1);
		i_AmountDowned[client] = -19;
	}
}

public void Rogue_SoulBTD_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], 0, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "Elite Sniper", false) != -1 ||
		StrContains(buffer, "Alchemist Potion", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 2);

		SoulBuff buff;
		float multi = 1.0;
		int length = AnnouncedBuff.Length;
		for(int i; i < length; i++)
		{
			AnnouncedBuff.GetArray(i, buff);
			if(buff.Type == 2)
				multi += 0.2;
		}
		
		if(Attributes_Has(entity, 2))
			Attributes_SetMulti(entity, 2, multi);
		
		if(Attributes_Has(entity, 410))
			Attributes_SetMulti(entity, 410, multi);
	}
}

public void Rogue_SoulYakuza_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], 0, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "Normal Fists", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 3);
		Attributes_Set(entity, 6123, 1.0);
	}
}

public void Rogue_SoulDungeon_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "King's Broken Blade", false) != -1 ||
		StrContains(buffer, "Repaired Blade", false) != -1 ||
		StrContains(buffer, "King's Revenge", false) != -1 ||
		StrContains(buffer, "Punish", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 4);

		DataPack pack;
		CreateDataTimer(2.0, Timer_DeathDoor, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(GetClientUserId(client));
	}
}

static Action Timer_DeathDoor(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int client = GetClientOfUserId(pack.ReadCell());
		if(client && IsPlayerAlive(client))
		{
			if(GetClientHealth(client) > 199)
			{
				ApplyStatusEffect(client, client, "Infinite Will", 5.0);
			}
			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

public void Rogue_SoulTerraria_Weapon(int entity, int client)
{
	if(StoreWeapon[entity] == -1)
		return;
	
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "Fractured Ark", false) != -1 ||
		StrContains(buffer, "Ark of the ", false) != -1 ||
		StrContains(buffer, "Repaired Ark", false) != -1 ||
		StrContains(buffer, "Star Shooter", false) != -1 ||
		StrContains(buffer, "Super Star Shooter", false) != -1 ||
		StrContains(buffer, "Koshi's Plasm-inator", false) != -1 ||
		StrContains(buffer, "Tinker's Wrench", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 5);

		DataPack pack;
		CreateDataTimer(40.0, Timer_SuperHeal, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		pack.WriteCell(EntIndexToEntRef(entity));
		pack.WriteCell(GetClientUserId(client));
	}
}

static Action Timer_SuperHeal(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int client = GetClientOfUserId(pack.ReadCell());
		if(client && IsPlayerAlive(client))
		{
			ClientCommand(client, "playgamesound vo/sandwicheat09.mp3");

			if(dieingstate[client] == 0)
			{
				SetEntityHealth(client, GetClientHealth(client) + 1000);
			}
			else
			{
				SetEntityHealth(client, GetClientHealth(client) + 100);
			}

			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

public void Rogue_AntiXeno_Enemy(int entity)
{
	if(i_BleedType[entity] == BLEEDTYPE_XENO)
	{
		fl_Extra_MeleeArmor[entity] *= 1.75;
		fl_Extra_RangedArmor[entity] *= 1.75;
	}
}

public void Rogue_AntiSeaborn_Enemy(int entity)
{
	if(i_BleedType[entity] == BLEEDTYPE_SEABORN)
	{
		fl_Extra_MeleeArmor[entity] *= 1.75;
		fl_Extra_RangedArmor[entity] *= 1.75;
	}
}

public void Rogue_CursedRelic_Weapon(int entity, int client)
{
	if(GetURandomInt() % 9)
	{
		Attributes_SetMulti(entity, 6, 0.92);
	}
	else
	{
		Attributes_SetMulti(entity, 6, 1.1);
	}
}

public void Rogue_Exchanger_Collect()
{
	int ingots = Rogue_GetIngots();
	if(ingots <= 0)
		return;
		
	Rogue_AddIngots(-ingots, true);
	
	CurrentCash += 200 * ingots;
	GlobalExtraCash += 200 * ingots;
}

public void Rogue_Exchanger_IngotChanged(int &ingots)
{
	if(ingots <= 0)
		return;

	CurrentCash += 200 * ingots;
	GlobalExtraCash += 200 * ingots;
	CPrintToChatAll("{green}%t","Cash Gained!", 200 * ingots);
	ingots = 0;
}

public void Rogue_RareWeapon_Collect()
{
	char name[64];

	switch(GetURandomInt() % 6)
	{
		case 0, 1:
			strcopy(name, sizeof(name), "Vows of the Sea");
		
	//	case 2:
	//		strcopy(name, sizeof(name), "Infinity Blade");
		
		case 2, 3:
			strcopy(name, sizeof(name), "Whistle Stop");
		
		case 4, 5:
			strcopy(name, sizeof(name), "Ancestor Launcher");
	}

	Store_DiscountNamedItem(name, 999, 0.6);
	CPrintToChatAll("{green}Recovered Items: {palegreen}%s", name);
}

public void Rogue_RottenBone_Collect()
{
	RottenBone = 1;
}

public void Rogue_RottenBone_Enemy(int entity)
{
	if(RottenBone)
	{
		fl_Extra_MeleeArmor[entity] *= 1.0 + (RottenBone * 0.00015);
		fl_Extra_RangedArmor[entity] *= 1.0 + (RottenBone * 0.00015);

		if(RottenBone < 3000)
			RottenBone++;
	}
}

public void Rogue_RottenBone_Remove()
{
	RottenBone = 0;
}

public void Rogue_Silence30_Enemy(int entity)
{
	ApplyStatusEffect(entity, entity, "Silenced", 30.0);
}

public void Rogue_CopperOre_Weapon(int entity)
{
	if(!Rogue_HasNamedArtifact("Iron Ore") && Attributes_Has(entity, 45))
		Attributes_SetMulti(entity, 45, 1.35);
}

public void Rogue_IronOre_Weapon(int entity)
{
	if(!Rogue_HasNamedArtifact("Copper Ore"))
	{
		if(Attributes_Has(entity, 101))
			Attributes_SetMulti(entity, 101, 1.35);
		
		if(Attributes_Has(entity, 103))
			Attributes_SetMulti(entity, 103, 1.35);
	}
}

public void Rogue_EmptyPlate_Collect()
{
	EmptyPlate = 5;
}

public void Rogue_EmptyPlate_Remove()
{
	EmptyPlate = 0;
}

public void Rogue_FoodFounder_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value;
		map.GetValue("4023", value);
		map.SetValue("4023", value + 10.0);
	}
}

public void Rogue_FoodBrandguider_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		float value = 1.0;
		map.GetValue("4022", value);
		map.SetValue("4022", value * 0.5);
	}
}

public void Rogue_FoodSpewer_Weapon(int entity)
{
	if(Attributes_Has(entity, 101))
		Attributes_SetMulti(entity, 101, 1.5);
}

public void Rogue_FoodSwarmcaller_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		map.SetValue("4024", 1.0);
	}
}

public void Rogue_Reefbreaker_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.15);
}
