#pragma semicolon 1
#pragma newdecls required


void ObjectTradingStation_MapStart()
{
	PrecacheModel("models/props_spytech/computer_low.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Trading Station");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_tradingstation");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectTradingStation(client, vecPos, vecAng);
}

methodmap ObjectTradingStation < ObjectGeneric
{
	public ObjectTradingStation(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectTradingStation npc = view_as<ObjectTradingStation>(ObjectGeneric(client, vecPos, vecAng, "models/props_medieval/ticket_booth/ticket_booth.mdl", "0.25", "50",{20.0, 20.0, 60.0}));

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, 90.0);

		return npc;
	}
}

static bool ClotCanUse(ObjectTradingStation npc, int client)
{
	return true;
}

static void ClotShowInteractHud(ObjectTradingStation npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "Trading Station Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectTradingStation npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	
	i_MachineJustClickedOn[client] = EntIndexToEntRef(npc.index);
	
	CancelClientMenu(client);
	SetStoreMenuLogic(client, false);
	SetGlobalTransTarget(client);
	
	char buffer[32];
	Menu menu2 = new Menu(Building_ConfirmMountedAction);
	menu2.SetTitle("%t", "Trading Station Menu Main");
	
	//You offer your current holding weapon, for another, after a few waves you get it
	/*
		Select weapon you wanna give: (Uses sell value + 30% so its basically equal, includes paps)
		This also allow selling if you want to at a higher value, but itll take longer, choosing to sell will only add an extra 10% of value

		Select weapon you want to recieve, if its not within price range, youll have to pay extra
		after 3-5 waves, you can choose to get the new weapon and give up your old one
		If grigori sells it on sale, then you get some money back
	*/
	FormatEx(buffer, sizeof(buffer), "%t", "Open Exchange Menu");
	menu2.AddItem("-1", buffer);
						
	menu2.Display(client, MENU_TIME_FOREVER);
	return true;
}

static int Building_ConfirmMountedAction(Menu menu, MenuAction action, int client, int choice)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete menu;
		}
		case MenuAction_Cancel:
		{
			ResetStoreMenuLogic(client);
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if(id == -3)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_REGENE);
				}
			}
			else if(id == -4)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_OBSIDIAN);
				}
			}
			else if(id == -5)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_MORNING_COFFEE);
				}
			}
			else if(id == -6)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_HASTY_HOPS);
				}
			}
			else if(id == -7)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_MARKSMAN_BEER);
				}
			}
			else if(id == -8)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_TESLAR_MULE);
				}
			}
			else if(id == -9)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_STOCKPILE_STOUT);
				}
			}
		}
	}
	return 0;
}