#pragma semicolon 1
#pragma newdecls required

#define NPC_CAMERA

void NPCCamera_PluginStart()
{
	AddCommandListener(NPCCamera_SpecNext, "spec_next");
	AddCommandListener(NPCCamera_SpecPrev, "spec_prev");
}

public Action NPCCamera_SpecNext(int client, const char[] command, int args)
{
#if defined ZR
	if (GetEntProp(client, Prop_Send, "m_iObserverMode") == OBS_MODE_ROAMING)
	{
		// While in freeroam mode, clicking on a targetable entity lets you spectate it
		float pos[3];
		
		StartLagCompensation_Base_Boss(client);
		int target = GetClientPointVisiblePlayersNPCs(client, 500.0, pos, true);
		FinishLagCompensation_Base_boss();
		
		if (target > 0 && IsEntityAlive(target))
		{
			SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target);
			SetEntProp(client, Prop_Send, "m_iObserverMode", OBS_MODE_CHASE);
		}
		
		return Plugin_Handled;
	}
#endif
	int minEntity = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	int bestEntity = MAXENTITIES;
	int worseEntity = MAXENTITIES;
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(NPCCamera_CanSpectateEntity(entity))
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

	if(bestEntity == MAXENTITIES && worseEntity == MAXENTITIES)	// No NPCs, don't override camera
		return Plugin_Continue;

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

	for(int i = i_MaxcountNpcTotal - 1; i >= 0; i--)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(NPCCamera_CanSpectateEntity(entity))
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

	if(bestEntity == 0 && worseEntity == 0)	// No NPCs, don't override camera
		return Plugin_Continue;

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

	if(bestEntity == 0)
	{
		if(worseEntity == 0)
			return Plugin_Continue;
		
		bestEntity = worseEntity;
	}
	
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", bestEntity);
	return Plugin_Handled;
}

static bool NPCCamera_CanSpectateEntity(int entity)
{
#if defined ZR
	return entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && (b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || (GetTeam(entity) == TFTeam_Red && (Citizen_IsIt(entity) || b_NpcIsInvulnerable[entity])));
#else
	return entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && (GetTeam(entity) == TFTeam_Red || b_thisNpcIsARaid[entity] || b_thisNpcIsABoss[entity] || b_StaticNPC[entity]);
#endif
}