#pragma semicolon 1
#pragma newdecls required

stock float CasinoShared_GetDamage(CClotBody npc, float multi)
{
	return Level[npc.index] * 50.0 * multi;
}

stock void CasinoShared_StealNearbyItems(CClotBody npc, const float pos1[3])
{
	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
	{
		static float pos2[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
		if(GetVectorDistance(pos1, pos1, true) < 40000.0) // 200.0
		{
			static char buffer[64];
			GetEntPropString(entity, Prop_Data, "m_iName", buffer, sizeof(buffer));
			if(StrContains(buffer, "rpg_item", false) != -1)
			{
				GetEntPropString(entity, Prop_Data, "m_ModelName", buffer, sizeof(buffer));
				if(StrContains(buffer, "currencypack_small") != -1)
				{
					SetEntityRenderMode(entity, RENDER_NONE);
					TeleportEntity(entity, OFF_THE_MAP);
				}
			}
		}
	}
}

stock void CasinoShared_RobMoney(CClotBody npc, int victim, int steal)
{
	if(i_CreditsOnKill[npc.index] > 999)
		return;
	
	if(victim <= MaxClients)
	{
		static float StealCooldown[MAXPLAYERS];
		float gameTime = GetGameTime();

		if(fabs(StealCooldown[victim] - gameTime) > 2.0)
		{
			StealCooldown[victim] = gameTime;// + 2.0;

			int cash = TextStore_Cash(victim);
			if(cash >= steal)
			{
				SPrintToChat(victim, "%d credits were stolen", steal);
				
				TextStore_Cash(victim, -steal);
				i_CreditsOnKill[npc.index] += steal;
			}
		}
	}
	else if(i_CreditsOnKill[victim] >= steal)
	{
		i_CreditsOnKill[victim] -= steal;
		i_CreditsOnKill[npc.index] += steal;
	}
}