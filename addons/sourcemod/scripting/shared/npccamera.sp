#pragma semicolon 1
#pragma newdecls required

void NPCCamera_PluginStart()
{
	AddCommandListener(NPCCamera_SpecNext, "spec_next");
	AddCommandListener(NPCCamera_SpecPrev, "spec_prev");
}

public Action NPCCamera_SpecNext(int client, const char[] command, int args)
{
	int minEntity = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	int bestEntity = MAXENTITIES;
	int worseEntity = MAXENTITIES;

	for(int entity = 1; entity <= MaxClients; entity++)
	{
		if(IsClientInGame(entity) && IsPlayerAlive(entity))
		{
			if(entity > minEntity && entity < bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity < worseEntity)
			{
				worseEntity = entity;
			}
		}
	}

	for(int i; i < i_MaxcountNpc; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(entity != INVALID_ENT_REFERENCE && (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_StaticNPC[entity]) && IsEntityAlive(entity))
		{
			if(entity > minEntity && entity < bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity < worseEntity)
			{
				worseEntity = entity;
			}
		}
	}

	for(int i; i < i_MaxcountNpc_Allied; i++)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(entity > minEntity && entity < bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity < worseEntity)
			{
				worseEntity = entity;
			}
		}
	}
	
	if(bestEntity == MAXENTITIES)
	{
		if(worseEntity == MAXENTITIES)
			return Plugin_Continue;
		
		bestEntity = worseEntity;
	}
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", bestEntity);
	return Plugin_Handled;
}

public Action NPCCamera_SpecPrev(int client, const char[] command, int args)
{
	int maxEntity = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	int bestEntity = 0;
	int worseEntity = 0;

	for(int entity = MaxClients; entity > 0; entity--)
	{
		if(IsClientInGame(entity) && IsPlayerAlive(entity))
		{
			if(entity < maxEntity && entity > bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity > worseEntity)
			{
				worseEntity = entity;
			}
		}
	}

	for(int i = i_MaxcountNpc - 1; i >= 0; i--)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(entity != INVALID_ENT_REFERENCE && (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_StaticNPC[entity]) && IsEntityAlive(entity))
		{
			if(entity < maxEntity && entity > bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity > worseEntity)
			{
				worseEntity = entity;
			}
		}
	}

	for(int i = i_MaxcountNpc_Allied - 1; i >= 0; i--)
	{
		int entity = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity))
		{
			if(entity < maxEntity && entity > bestEntity)
			{
				bestEntity = entity;
			}
			else if(entity > worseEntity)
			{
				worseEntity = entity;
			}
		}
	}

	if(bestEntity == 0)
	{
		if(worseEntity == 0)
			return Plugin_Continue;
		
		bestEntity = worseEntity;
	}
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", bestEntity);
	return Plugin_Handled;
}
