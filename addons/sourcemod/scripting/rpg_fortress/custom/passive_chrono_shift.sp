#define CHRONO_SHIFT_COOLDOWN 20.0

static bool ChronoShiftEnable[MAXPLAYERS+1] = {false, ...};
static float f_ChronoShiftCooldown[MAXENTITIES];
static float f_MagicFocus[MAXPLAYERS+1] = {0.0, ...};

public void ChronoShiftUnequipOrDisconnect(int client)
{
	ChronoShiftEnable[client] = false;
	f_ChronoShiftCooldown[client] = 0.0;
}

bool MagicFocusReady(int client)
{
	if(f_MagicFocus[client] > GetGameTime())
	{
		return true;
	}
	return false;
}

void MagicFocusUse(int client)
{
	f_MagicFocus[client] = 0.0;
}

public void ChronoShiftEquip(int client, int weapon, int index)
{
	KeyValues kv = TextStore_GetItemKv(index);
	if(kv)
	{
		ChronoShiftEnable[client] = true;		
	}
}

int ChronoShiftReady(int client)
{
	if(!ChronoShiftEnable[client])
		return 0;

	if(f_ChronoShiftCooldown[client] < GetGameTime())
		return 2;
	
	return 1;
}

float ChornoShiftCooldown(int client)
{
	return (f_ChronoShiftCooldown[client] - GetGameTime());
}

void ChronoShiftDoCooldown(int client)
{
	f_ChronoShiftCooldown[client] = GetGameTime() + CHRONO_SHIFT_COOLDOWN;
}



public float AbilityMagicFocus(int client, int index, char name[48])
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
	if (!i_IsWandWeapon[weapon])
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "Not usable Without a Magic Wand.");
		return 0.0;
	}
	if(Stats_Intelligence(client) < 1250)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		ShowGameText(client,"leaderboard_streak", 0, "You do not have enough Intelligence [1250]");
		return 0.0;
	}

	int StatsForCalcMultiAdd;
	Stats_Artifice(client, StatsForCalcMultiAdd);
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

	f_MagicFocus[client] = GetGameTime() + 5.0;

	float Time = 25.0;
	EmitSoundToAll("npc/strider/charging.wav", client, SNDCHAN_AUTO, 70, .pitch = 120);

	return (GetGameTime() + Time);
}