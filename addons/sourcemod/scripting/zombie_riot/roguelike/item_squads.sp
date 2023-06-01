public void Rogue_LeaderSquad_Collect()
{
	b_LeaderSquad = true;
	Rogue_AddBonusLife(1);
}

public void Rogue_Gathering_Collect()
{
	b_GatheringSquad = true;
	Rogue_AddBonusLife(1);
}

public void Rogue_Support_Collect()
{
	Rogue_AddBonusLife(1);
	Rogue_AddIngots(20);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			CashRecievedNonWave[client] += 500;
			CashSpent[client] -= 500;
		}
	}
}

public void Rogue_Spearhead_Ally(int entity, StringMap map)
{
	if(map)	// Player
	{
		int value;

		// +50 max health
		map.GetValue("26", value);
		map.SetValue("26", value + 50);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(i_NpcInternalId[entity] == CITIZEN)	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunRangeBonus *= 1.15;

			// +50 max health
			int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
			SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
		}
		else
		{
			BarrackBody npc = view_as<BarrackBody>(entity);
			if(npc.OwnerUserId)	// Barracks Unit
			{
				// +15% damage bonus
				npc.BonusDamageBonus *= 1.15;

				// +50 max health
				int health = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
	/*
	else if(i_IsABuilding[entity])	// Building
	{

	}
	*/
}

public void Rogue_Spearhead_Weapon(int entity)
{
	// +15% damage bonus
	Address address = TF2Attrib_GetByDefIndex(entity, 2);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 2, TF2Attrib_GetValue(address) * 1.15);
	
	address = TF2Attrib_GetByDefIndex(entity, 410);
	if(address != Address_Null)
		TF2Attrib_SetByDefIndex(entity, 410, TF2Attrib_GetValue(address) * 1.15);
}

public void Rogue_Research_Collect()
{
	b_ResearchSquad = true;
}

public void Rogue_FirstClass_Collect()
{
	int entity = Citizen_SpawnAtPoint("a");
	if(entity != -1)
		Citizen_GivePerk(entity, 2);
}