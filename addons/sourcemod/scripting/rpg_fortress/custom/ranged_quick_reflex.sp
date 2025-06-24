void QuickReflex_MapStart()
{
	PrecacheSound("items/powerup_pickup_haste.wav");
}

public float AbilityQuickReflex(int client, int index, char name[48])
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(!kv)
	{
		return 0.0;
	}

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(!IsValidEntity(weapon))
	{
		return 0.0;
	}

	static char classname[36];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (TF2_GetClassnameSlot(classname, weapon) == TFWeaponSlot_Melee || i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Ranged Weapon.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 65)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [65]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Precision(client, StatsForCalcMultiAdd);
	StatsForCalcMultiAdd /= 4;
	//get base endurance for cost
	if(i_CurrentStamina[client] < StatsForCalcMultiAdd)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Stamina");
		return 0.0;
	}

	int StatsForCalcMultiAdd_Capacity;

	StatsForCalcMultiAdd_Capacity = StatsForCalcMultiAdd * 2;

	if(Current_Mana[client] < StatsForCalcMultiAdd_Capacity)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		SetDefaultHudPosition(client);
		SetGlobalTransTarget(client);
		ShowSyncHudText(client,  SyncHud_Notifaction, "%s", "Not Enough Mana");
		return 0.0;
	}
	RPGCore_StaminaReduction(weapon, client, StatsForCalcMultiAdd / 2);
	RPGCore_ResourceReduction(client, StatsForCalcMultiAdd_Capacity);
	
	Ability_QuickReflex(client, 1, weapon);
	
	return (GetGameTime() + 25.0);
}

public void Ability_QuickReflex(int client, int level, int weapon)
{
	EmitSoundToAll("items/powerup_pickup_haste.wav", client, _, 70);
	ApplyTempAttrib(weapon, 6, 0.65, 5.0);
	ApplyTempAttrib(weapon, 97, 0.65, 5.0);
}

public Action Timer_UpdateMovementSpeed(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidClient(client))
	{
		SDKCall_SetSpeed(client);
	}
	return Plugin_Handled;
}