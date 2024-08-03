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
	InClassicMode = true;

	PrecacheMvMIconCustom("classic_defend", false);
	PrecacheMvMIconCustom("classic_reinforce", false);
}

void Classic_NewRoundStart(int cash)
{
	//todo: Put it in wave CFG instead, too lazy rn
	cash = RoundToCeil(float(cash) * 1.1);
	CashTotal = cash;
	CashLeft = cash;
}

void Classic_EnemySpawned(int entity)
{
	if(CashLeft && MultiGlobalEnemy && view_as<CClotBody>(entity).m_fCreditsOnKill == 0.0)
	{
		// At 4-players, need 150 kills to get all wave money
		
		//scaling for players on how many zombies spawn in much harder in lower counts
		//so we have to extrapolate MultiGlobalEnemy, i.e. max players, 42 zombies, at 4 plasers only 12 spawn.
		float ScalingMoneyCount = MultiGlobalEnemy * 2.5;

		int given = RoundToCeil(float(CashTotal) / 150.0 / ScalingMoneyCount);
		if(given > CashLeft)
			given = CashLeft;
		
		CashLeft -= given;
		view_as<CClotBody>(entity).m_fCreditsOnKill = float(given);
	}
}

bool Classic_CanTeutonUpdate(int client, bool respawn)
{
	if(Classic_Mode() && Waves_Started() && !respawn)
	{
		TeutonType[client] = TEUTON_DEAD;
		return false;
	}

	return true;
}

void Classic_UpdateMvMStats(float &cashLeft)
{
	cashLeft += float(CashLeft);
}
