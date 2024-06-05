#define CHRONO_SHIFT_COOLDOWN 20.0

static bool ChronoShiftEnable[MAXPLAYERS+1] = {false, ...};
static float f_ChronoShiftCooldown[MAXENTITIES];

public void ChronoShiftUnequipOrDisconnect(int client)
{
	ChronoShiftEnable[client] = false;
	f_ChronoShiftCooldown[client] = 0.0;
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
