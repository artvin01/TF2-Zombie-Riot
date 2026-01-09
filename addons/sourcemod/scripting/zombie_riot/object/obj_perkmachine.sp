#pragma semicolon 1
#pragma newdecls required

float Perk_Machine_Sickness[MAXPLAYERS];
void ObjectPerkMachine_MapStart()
{
	PrecacheModel("models/props_farm/welding_machine01.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Perk Machine");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_perkmachine");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_perkmachine");
	build.Cost = 1000;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ObjectGeneric_CanBuild;
	Building_Add(build);

	Zero(Perk_Machine_Sickness);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectPerkMachine(client, vecPos, vecAng);
}

methodmap ObjectPerkMachine < ObjectGeneric
{
	public ObjectPerkMachine(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectPerkMachine npc = view_as<ObjectPerkMachine>(ObjectGeneric(client, vecPos, vecAng, "models/props_farm/welding_machine01.mdl",_, "50",{20.0, 20.0, 65.0}));

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, 90.0);

		return npc;
	}
}

static bool ClotCanUse(ObjectPerkMachine npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;

	if(Perk_Machine_Sickness[client] > GetGameTime())
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectPerkMachine npc, int client)
{
	SetGlobalTransTarget(client);
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%t", ButtonDisplay2, ButtonDisplay,"Perkmachine Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectPerkMachine npc)
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
	
	if(ClientTutorialStep(client) == 4)
	{
		//littel cooldown
		KillMostCurrentIDAnnotation(client, i_CurrentIdBeforeAnnoation[client]);
		f_TutorialUpdateStep[client] = GetGameTime() + 5.0;
		SetClientTutorialStep(client, 6);
		DoTutorialStep(client, false);	
	}
	char buffer[32];
	Menu menu2 = new Menu(Building_ConfirmMountedAction);
	menu2.SetTitle("%t", "Which perk do you desire?");
		
	FormatEx(buffer, sizeof(buffer), "%t", "Stockpile Stout");
	menu2.AddItem("-9", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Teslar Mule");
	menu2.AddItem("-8", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Marksman Beer");
	menu2.AddItem("-7", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Hasty Hops");
	menu2.AddItem("-6", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Morning Coffee");
	menu2.AddItem("-5", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Obsidian Oaf");
	menu2.AddItem("-4", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%t", "Regene Berry");
	menu2.AddItem("-3", buffer);

	FormatEx(buffer, sizeof(buffer), "%t", "Energy Drink");
	menu2.AddItem("-10", buffer);
						
	menu2.Pagination = 0;
	menu2.ExitButton = true;
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
			if(IsValidClient(client))
				AnyMenuOpen[client] = 0.0;
		}
		case MenuAction_Select:
		{
			ResetStoreMenuLogic(client);
			char buffer[24];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if((GetURandomInt() % 4) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
			{
				id = GetRandomInt(-10, -4);
			}

			if(id == -3)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_REGENE, 1);
				}
			}
			else if(id == -4)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_OBSIDIAN, 2);
				}
			}
			else if(id == -5)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_MORNING_COFFEE, 3);
				}
			}
			else if(id == -6)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_HASTY_HOPS, 4);
				}
			}
			else if(id == -7)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_MARKSMAN_BEER ,5);
				}
			}
			else if(id == -8)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_TESLAR_MULE ,6);
				}
			}
			else if(id == -9)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_STOCKPILE_STOUT,7);
				}
			}
			else if(id == -10)
			{
				int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					Do_Perk_Machine_Logic(owner, client, entity, PERK_ENERGY_DRINK, 8);
				}
			}
		}
	}
	return 0;
}

static void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk, int PrintChatid)
{
	if(owner == -1)
		return;
		
	if((GetEntityFlags(client) & FL_DUCKING))
	{
		CPrintToChat(client, "{green} %T", PerkNames_Received[PrintChatid], client);
		ObjectPerkMachine npc = view_as<ObjectPerkMachine>(entity);
		ClotInteract(client, -1, npc);
		return;
	}

	int PerksOn = 0;
	if(Rogue_ColdWaterActive())
	{
		for(int loopCheck = 0; loopCheck < 16; loopCheck++)
		{
			if(i_CurrentEquippedPerk[client] & (1 << loopCheck))
			{
				PerksOn++;
			}
		}
	}
	
	if(Rogue_ColdWaterActive() && i_CurrentEquippedPerk[client] & what_perk)
	{
		i_CurrentEquippedPerk[client] &= ~what_perk;
		i_CurrentEquippedPerkPreviously[client] &= ~what_perk;
		CPrintToChat(client, "{crimson} %T", "You removed the current perk", client);
	}
	else
	{
		if(PerksOn >= 2)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			CPrintToChat(client, "{crimson} %T", "Too many Perks", client);
			return;
		}
		if(!Rogue_ColdWaterActive())
		{
			i_CurrentEquippedPerk[client] = 0;
			i_CurrentEquippedPerkPreviously[client] = 0;
		}
		i_CurrentEquippedPerk[client] |= what_perk;
		i_CurrentEquippedPerkPreviously[client] |= what_perk;

	}
	UpdatePerkName(client);
	
	TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
	ApplyBuildingCollectCooldown(entity, client, 40.0);
	Building_GiveRewardsUse(client, owner, 25, true, 0.75, true);

	float pos[3];
	float angles[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);

	pos[2] += 45.0;
	angles[1] -= 90.0;

	int particle = ParticleEffectAt(pos, "flamethrower_underwater", 1.0);
	SetEntPropVector(particle, Prop_Send, "m_angRotation", angles);
	Perk_Machine_Sickness[client] = GetGameTime() + 2.0;
	SetDefaultHudPosition(client, _, _, _, 5.0);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	
	Barracks_UpdateAllEntityUpgrades(client);
	CPrintToChat(client, "{green} %T", PerkNames_Received[PrintChatid], client);
}