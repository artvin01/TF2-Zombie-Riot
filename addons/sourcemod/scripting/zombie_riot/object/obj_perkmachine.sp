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
	
	char Display3[255];
	if(npc.m_iExtraLogic)
	{
		FormatEx(Display3, sizeof(Display3), "%T", PerkNames[npc.m_iExtraLogic], client);
	}
	PrintCenterText(client, "%s\n%s%t\n%s", ButtonDisplay2, ButtonDisplay, "Perkmachine Tooltip", Display3);
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
	if(npc.m_iExtraLogic)
	{
		GivePerkViaMapForce(client, npc);
		return true;
	}
	char data[4], buffer[32];
	Menu menu2 = new Menu(Building_ConfirmMountedAction);
	menu2.SetTitle("%t", "Which perk do you desire?");

	for(int i = 1; i < 9; i++)
	{
		FormatEx(buffer, sizeof(buffer), "%t", PerkNames[i]);
		IntToString(i, data, sizeof(data));
		menu2.AddItem(data, buffer);
	}
						
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
			char buffer[4];
			menu.GetItem(choice, buffer, sizeof(buffer));
			int id = StringToInt(buffer);

			if((GetURandomInt() % 4) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
			{
				id = GetRandomInt(1, sizeof(PerkNames) - 1);
			}

			int entity = EntRefToEntIndexFast(i_MachineJustClickedOn[client]);
			if(IsValidEntity(entity))
			{
				int owner = -1;
				owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
				Do_Perk_Machine_Logic(owner, client, entity, (1 << (id - 1)), id);
			}
		}
	}
	return 0;
}

void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk, int PrintChatid, bool IsVscriptCall = false)
{
	ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
	if(owner == -1 && !objstats.m_bNoOwnerRequired)
		return;
		
	if(!IsVscriptCall && (GetEntityFlags(client) & FL_DUCKING))
	{
		CPrintToChat(client, "{green} %T", PerkNames_Received[PrintChatid], client);
		ObjectPerkMachine npc = view_as<ObjectPerkMachine>(entity);
		ClotInteract(client, -1, npc);
		return;
	}

	int PerksOn = 0;
	int perklimit = Rogue_ColdWaterActive() ? 2 : 1;
	bool cooldown = true;

	if(perklimit > 1)
	{
		for(int loopCheck = 0; loopCheck < sizeof(PerkNames); loopCheck++)
		{
			if(i_CurrentEquippedPerk[client] & (1 << loopCheck))
			{
				PerksOn++;
			}
		}
	}
	if(PerkModeDo == PERK_MODE_ALL_ALLOW)
	{
		if(i_CurrentEquippedPerk[client] & what_perk)
		{
			ClientCommand(client, "playgamesound items/medshotno1.wav");
			return;
		}
		i_CurrentEquippedPerk[client] |= what_perk;
		i_CurrentEquippedPerkPreviously[client] |= what_perk;
	}
	else
	{	
		if(perklimit > 1 && i_CurrentEquippedPerk[client] & what_perk)
		{
			i_CurrentEquippedPerk[client] &= ~what_perk;
			i_CurrentEquippedPerkPreviously[client] &= ~what_perk;
			CPrintToChat(client, "{crimson} %T", "You removed the current perk", client);
			cooldown = false;
		}
		else
		{
			if(PerksOn >= 2)
			{
				ClientCommand(client, "playgamesound items/medshotno1.wav");
				CPrintToChat(client, "{crimson} %T", "Too many Perks", client);
				return;
			}
			if(perklimit < 2)
			{
				i_CurrentEquippedPerk[client] = 0;
				i_CurrentEquippedPerkPreviously[client] = 0;
			}
			i_CurrentEquippedPerk[client] |= what_perk;
			i_CurrentEquippedPerkPreviously[client] |= what_perk;
		}
	}
	UpdatePerkName(client);
	
	TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
	if(cooldown)
	{
		ApplyBuildingCollectCooldown(entity, client, 40.0);
		Building_GiveRewardsUse(client, owner, 25, true, 0.75, true);
	}

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

void GivePerkViaMapForce(int client, ObjectPerkMachine npc)
{
	if(npc.m_iExtraLogic)
	{
		Do_Perk_Machine_Logic(client, client, npc.index, (1 << (npc.m_iExtraLogic - 1)), npc.m_iExtraLogic);
	}
}