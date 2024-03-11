static bool HeavyWind;
static Handle FrostTimer;
static ArrayList WinterTheme;

bool Rogue_Paradox_HeavyWind()
{
	return HeavyWind;
}

void Rogue_Paradox_MapStart()
{
	delete WinterTheme;
}

void Rogue_Paradox_AddWinterNPC(int id)
{
	if(!WinterTheme)
		WinterTheme = new ArrayList();
	
	WinterTheme.Push(id);
}



bool Rogue_Paradox_JesusBlessing(int client, int &healing_Amount)
{
	if(FrostTimer && dieingstate[client] == 0)
	{
		int health = GetClientHealth(client);
		if(health > 1)
		{
			int maxhealth = SDKCall_GetMaxHealth(client);

			// Degen if no blessing or above 50% health
			if(Jesus_Blessing[client] != 1 || (health > maxhealth / 2))
			{
				int damage = maxhealth / -100;
				health += damage;
				if(health < 1)
				{
					damage = 1 - health;
					health = 1;
				}

				healing_Amount += damage;
				SetEntityHealth(client, health);
			}
		}

		return true;	// Override Jesus Blessing
	}

	return false;
}

public void Rogue_Curse_HeavyRain(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Heavy Rain", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Heavy Rain");
	}
}

public void Rogue_Curse_ExtremeHeat(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Extreme Heat", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Extreme Heat");
	}
}

public void Rogue_Curse_HeavyWind(bool enable)
{
	HeavyWind = enable;
}

public void Rogue_Curse_DenseFrost(bool enable)
{
	delete FrostTimer;

	if(enable)
	{
		FrostTimer = CreateTimer(1.0, Timer_ParadoxFrost, _, TIMER_REPEAT);
	}
	else
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
				Store_GiveAll(client, GetClientHealth(client));
		}
	}
}

public void Rogue_Curse_RedMoon(bool enable)
{
	if(enable)
	{
		Rogue_GiveNamedArtifact("Red Moon", true);
	}
	else
	{
		Rogue_RemoveNamedArtifact("Red Moon");
	}
}

static Action Timer_ParadoxFrost(Handle timer)
{
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(WinterTheme && WinterTheme.FindValue(i_NpcInternalId[entity]) != -1)
				continue;
			
			int health = GetEntProp(client, Prop_Data, "m_iHealth");
			if(health > 1)
			{
				int damage = GetEntProp(client, Prop_Data, "m_iMaxHealth") / 100;
				if(damage > 500)
					damage = 500;
				
				health -= damage;
				if(health < 1)
					health = 1;
				
				SetEntProp(client, Prop_Data, "m_iHealth", health);
			}
		}
	}

	return Plugin_Continue;
}
