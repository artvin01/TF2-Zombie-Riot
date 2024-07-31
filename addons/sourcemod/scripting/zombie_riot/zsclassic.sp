#pragma semicolon 1
#pragma newdecls required

static bool InClassicMode;
static int CashLeft;
static int CashTotal;

bool Classic_Mode()	// If ZS-Classic is enabled
{
	return InClassicMode;
}

void Classic_MapStart()
{
	InClassicMode = false;
	CashTotal = 0;
	CashLeft = 0;
}

void Classic_Enable()
{
	PrintToChatAll("Classic Mode!");
	InClassicMode = true;
}

void Classic_NewRoundStart(int cash)
{
	CashTotal = cash;
	CashLeft = cash;
}

void Classic_EnemySpawned(int entity)
{
	if(CashLeft && MultiGlobalEnemy && view_as<CClotBody>(entity).m_fCreditsOnKill == 0.0)
	{
		// At 4-players, need 1000 kills to get all wave money
		int given = RoundToCeil(float(CashTotal) / 1000.0 / MultiGlobalEnemy);
		if(given > CashLeft)
			given = CashLeft;
		
		CashLeft -= given;
		view_as<CClotBody>(entity).m_fCreditsOnKill = float(given);
	}
}

bool Classic_CanTeutonUpdate(int client, bool respawn)
{
	if(Classic_Mode() && !respawn)
	{
		TeutonType[client] = TEUTON_DEAD;
		return false;
	}

	return true;
}
