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
static bool CoinExchanger;

void Rogue_Whiteflower_Reset()
{
	delete AnnouncedBuff;
}

void Rogue_Whiteflower_IngotGiven(int &ingots)
{
	if(CoinExchanger)
	{
		CurrentCash += 200 * ingots;
		GlobalExtraCash += 200 * ingots;
		ingots = 0;
	}
}

static void AnnounceSoulBuff(int client, int entity, int type)
{
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
		StrContains(buffer, "Aresenal's Tripmine Layer", false) != -1)
	{
		AnnounceSoulBuff(client, entity, 0);

		Attributes_SetMulti(entity, 524, 2.0);
	}
}

public void Rogue_SoulArknights_Weapon(int entity, int client)
{
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(i_WeaponArchetype[entity] == 22 ||
		i_WeaponArchetype[entity] == 23 ||
		StrContains(buffer, "The Enforcer", false) != -1 ||
		StrContains(buffer, "Victorian Launcher", false) != -1 ||
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
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(entity != -1)
	{
		int client = GetClientOfUserId(pack.ReadCell());
		if(client && IsPlayerAlive(client))
		{
			if(GetClientHealth(client) > 199)
				TF2_AddCondition(client, TFCond_PreventDeath, 5.0);
			
			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

public void Rogue_SoulTerraria_Weapon(int entity, int client)
{
	char buffer[64];
	Store_GetItemName(StoreWeapon[entity], client, buffer, sizeof(buffer), false);
	if(StrContains(buffer, "Fractured Ark", false) != -1 ||
		StrContains(buffer, "Ark of the ", false) != -1 ||
		StrContains(buffer, "Repaired Ark", false) != -1 ||
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
		Attributes_SetMulti(entity, 6, 3.0);
	}
}

public void Rogue_Exchanger_Collect()
{
	int ingots = Rogue_GetIngots();
	Rogue_AddIngots(-ingots, true);
	
	CurrentCash += 200 * ingots;
	GlobalExtraCash += 200 * ingots;

	CoinExchanger = true;
}

public void Rogue_Exchanger_Remove()
{
	CoinExchanger = false;
}

public void Rogue_RareWeapon_Collect()
{
	char name[64];

	switch(GetURandomInt() % 8)
	{
		case 0, 1:
			strcopy(name, sizeof(name), "Vows of the Sea");
		
		case 2:
			strcopy(name, sizeof(name), "Dimension Ripper");
		
		case 3, 4:
			strcopy(name, sizeof(name), "Whistle Stop");
		
		case 5, 6:
			strcopy(name, sizeof(name), "Ancestor Launcher");
		
		case 7:
			strcopy(name, sizeof(name), "Infinity Blade");
	}

	Store_DiscountNamedItem(name, 30);
	CPrintToChatAll("{green}Recovered Items: {palegreen}%s", name);
}

static int RottenBone;
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