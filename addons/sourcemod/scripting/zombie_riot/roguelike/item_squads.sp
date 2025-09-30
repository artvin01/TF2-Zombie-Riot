#pragma semicolon 1
#pragma newdecls required

public void Rogue_BonusLife_Collect()
{
	Rogue_AddBonusLife(1);
}

public void Rogue_Leader_Collect()
{
	b_LeaderSquad = true;
	Rogue_AddBonusLife(1);
}
public void Rogue_Leader_Collect_Lite()
{
	b_LeaderSquad = true;
	b_GatheringSquad = true;
}

public void Rogue_Gathering_Collect()
{
	b_GatheringSquad = true;
	Rogue_AddBonusLife(1);
}

public void Rogue_Support_Collect()
{
	Rogue_AddBonusLife(1);
	Rogue_AddIngots(20, true);

	GlobalExtraCash += 250;
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			CashSpent[client] -= 250;
	}
}

public void Rogue_Spearhead_Ally(int entity, StringMap map)
{
	RogueHelp_BodyDamage(entity, map, 1.15);

	if(map)	// Player
	{
		float value;

		map.GetValue("26", value);
		map.SetValue("26", value + 50);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		int health = ReturnEntityMaxHealth(entity) + 50;

		SetEntProp(entity, Prop_Data, "m_iHealth", health);
		SetEntProp(entity, Prop_Data, "m_iMaxHealth", health);
	}
}

public void Rogue_Spearhead_Weapon(int entity)
{
	RogueHelp_WeaponDamage(entity, 1.15);
}

public void Rogue_Research_Collect()
{
	b_ResearchSquad = true;
}