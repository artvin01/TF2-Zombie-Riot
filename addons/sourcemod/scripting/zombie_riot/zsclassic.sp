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
	CashTotal = cash;
	CashLeft = cash;
}

void Classic_EnemySpawned(int entity)
{
	if(CashLeft && view_as<CClotBody>(entity).m_fCreditsOnKill == 0.0)
	{
		// At 4-players, need 150 kills to get all wave money
		
		//scaling for players on how many zombies spawn in much harder in lower counts
		/*
			this meanswe cannot use MultiGlobalEnemy stuff.
			PlayersAliveScaling is the cloest we have, this is for max enemies at once.
			it starts at 8 and ends around at 42.

			no divide by 0,
			default is 8 * 1.54560840063 if its 4 players
			See NPC_SpawnNext
		*/
		float ScalingMoneyCount = ((float(PlayersAliveScaling) + 0.01) / 12.0);
		//too little people makes the above scaling impossible
		switch(PlayersInGame)
		{
			case 1:
				ScalingMoneyCount *= 0.35;
			case 2:
				ScalingMoneyCount *= 0.5;
			case 3:
				ScalingMoneyCount *= 0.6;
			case 4:
				ScalingMoneyCount *= 0.75;
			case 7,8,9,10:
				ScalingMoneyCount *= 1.25;
			case 11,12,13,14:
				ScalingMoneyCount *= 1.4;
			case 15,16,17,18:
				ScalingMoneyCount *= 1.5;
		}


		int given = RoundToCeil(float(CashTotal) / 110.0 / ScalingMoneyCount);
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
