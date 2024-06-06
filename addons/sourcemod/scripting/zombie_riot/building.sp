#pragma semicolon 1
#pragma newdecls required
	
void Building_ShowInteractionHud(int client, int entity)
{
	if(TeutonType[client] != TEUTON_NONE)
		return;
	
	bool Hide_Hud = true;
	if(dieingstate[client] < 1 && IsValidEntity(entity))
	{
		if(entity <= MaxClients)
		{
			if(dieingstate[entity] > 0 && IsPlayerAlive(client))
			{
				SetGlobalTransTarget(client);
				PrintCenterText(client, "%t", "Revive Teammate tooltip");
				return;
			}
			entity = EntRefToEntIndex(Building_Mounted[entity]);
			if(!IsValidEntity(entity))
			{
				return;
			}
		}
		else if(!b_NpcHasDied[entity])
		{
			if(GetTeam(entity) == TFTeam_Red)
			{
				if(f_CooldownForHurtHud[client] < GetGameTime() && f_CooldownForHurtHud_Ally[client] < GetGameTime())
				{
					Calculate_And_Display_hp(client, entity, 0.0, true);
				}
			}

			static char plugin[64];
			NPC_GetPluginById(i_NpcInternalId[entity], plugin, sizeof(plugin));
			if(StrContains(plugin, "obj_", false) != -1)
			{
				if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == -1)
				{
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					PrintCenterText(client, "%t", "Claim this building");
				}
				else if(Building_Collect_Cooldown[entity][client] > GetGameTime())
				{
					float Building_Picking_up_cd = Building_Collect_Cooldown[entity][client] - GetGameTime();
					
					if(Building_Picking_up_cd <= 0.0)
						Building_Picking_up_cd = 0.0;
					
					Hide_Hud = false;
					SetGlobalTransTarget(client);
					PrintCenterText(client, "%t","Object Cooldown",Building_Picking_up_cd);
				}
				else if(Object_ShowInteractHud(client, entity))
				{
					Hide_Hud = false;
				}
			}
		}
	}

	if(Hide_Hud)
		PrintCenterText(client, "");
}

stock void ApplyBuildingCollectCooldown(int building, int client, float Duration, bool IgnoreVotingExtraCD = false)
{
	if(CvarInfiniteCash.BoolValue)
	{
		Building_Collect_Cooldown[building][client] = 0.0;
	}
	//else if(GameRules_GetRoundState() == RoundState_BetweenRounds && !IgnoreVotingExtraCD)
	//{
	//	Building_Collect_Cooldown[building][client] = FAR_FUTURE;
	//}
	else
	{
		Building_Collect_Cooldown[building][client] = GetGameTime() + Duration;
	}
}