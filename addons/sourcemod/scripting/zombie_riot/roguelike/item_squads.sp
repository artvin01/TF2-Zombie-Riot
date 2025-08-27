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
	if(map)	// Player
	{
		float value;

		// +50 max health
		map.GetValue("26", value);
		map.SetValue("26", value + 50.0);

		//15% more building damage
		value = 1.0;
		map.GetValue("287", value);
		map.SetValue("287", value * 1.15);
	}
	else if(!b_NpcHasDied[entity])	// NPCs
	{
		if(Citizen_IsIt(entity))	// Rebel
		{
			Citizen npc = view_as<Citizen>(entity);

			// +15% damage bonus
			npc.m_fGunBonusDamage *= 1.15;

			// +50 max health
			int health = ReturnEntityMaxHealth(npc.index) + 50;
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
				int health = ReturnEntityMaxHealth(npc.index) + 50;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
				SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", health);
			}
		}
	}
	else if(i_IsABuilding[entity])	// Building
	{

	}
}

public void Rogue_Spearhead_Weapon(int entity)
{
	Attributes_SetMulti(entity, 2, 1.15);
	Attributes_SetMulti(entity, 410, 1.15);
	char buffer[36];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	if(StrEqual(buffer, "tf_weapon_medigun"))
	{
		Attributes_SetMulti(entity, 1, 1.15);
	}
	
}

public void Rogue_Research_Collect()
{
	b_ResearchSquad = true;
}