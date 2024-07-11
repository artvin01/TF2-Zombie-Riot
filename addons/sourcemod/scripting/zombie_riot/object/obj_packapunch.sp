#pragma semicolon 1
#pragma newdecls required

float f_CheckWeaponDelay[MAXTF2PLAYERS];
bool b_LastWeaponCheckBias[MAXTF2PLAYERS];

void ObjectPackAPunch_MapStart()
{
	PrecacheModel("models/props_spytech/computer_low.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Pack-a-Punch");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_packapunch");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
	Zero(b_LastWeaponCheckBias);
	Zero(f_CheckWeaponDelay);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectPackAPunch(client, vecPos, vecAng);
}

methodmap ObjectPackAPunch < ObjectGeneric
{
	public ObjectPackAPunch(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectPackAPunch npc = view_as<ObjectPackAPunch>(ObjectGeneric(client, vecPos, vecAng, "models/props_spytech/computer_low.mdl", _, "50",{25.0, 25.0, 65.0}));

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;
		SetRotateByDefaultReturn(npc.index, 90.0);

		return npc;
	}
}

static bool ClotCanUse(ObjectPackAPunch npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;

	if(!Pap_WeaponCheck(client))
		return false;
	
	bool started = Waves_Started();
	if(started || Rogue_Mode() || CvarNoRoundStart.BoolValue)
	{
		return true;
	}
	return false;
}

bool Pap_WeaponCheck(int client, bool force = false)
{
	if(!force && f_CheckWeaponDelay[client] > GetGameTime())
	{
		return b_LastWeaponCheckBias[client];
	}
	f_CheckWeaponDelay[client] = GetGameTime() + 0.25;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(weapon == -1)
		return false;
	
	b_LastWeaponCheckBias[client] = Store_CanPapItem(client, StoreWeapon[weapon]);
	
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_ION_BEAM, WEAPON_ION_BEAM_FEED, WEAPON_ION_BEAM_NIGHT, WEAPON_ION_BEAM_PULSE:
		{
			b_LastWeaponCheckBias[client] = true;
		}
	}
	return b_LastWeaponCheckBias[client];
}

static void ClotShowInteractHud(ObjectPackAPunch npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "PackAPunch Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectPackAPunch npc)
{
	f_CheckWeaponDelay[client] = 0.0;
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	int owner;
	owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	
	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_ION_BEAM, WEAPON_ION_BEAM_FEED, WEAPON_ION_BEAM_NIGHT, WEAPON_ION_BEAM_PULSE:
		{
			int buttons = GetClientButtons(client);
			bool attack2 = (buttons & IN_ATTACK2) != 0;
			if(attack2)
			{
				Neuvellete_Menu(client, weapon);
				return true;
			}
		}
	}
	Store_PackMenu(client, StoreWeapon[weapon], weapon, owner);
	return true;
}
/*
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
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 1);
				}
			}
			else if(id == -4)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 2);
				}
			}
			else if(id == -5)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 3);
				}
			}
			else if(id == -6)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}
					Do_Perk_Machine_Logic(owner, client, entity, 4);
				}
			}
			else if(id == -7)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					else
					{
						owner = GetClientOfUserId(i_ThisEntityHasAMachineThatBelongsToClient[entity]);
					}	
					Do_Perk_Machine_Logic(owner, client, entity, 5);
				}
			}
			else if(id == -8)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					Do_Perk_Machine_Logic(owner, client, entity, 6);
				}
			}
			else if(id == -9)
			{
				int entity = EntRefToEntIndex(i_MachineJustClickedOn[client]);
				if(IsValidEntity(entity))
				{
					int owner = -1;
					if(HasEntProp(entity, Prop_Send, "m_hBuilder"))
					{
						owner = GetEntPropEnt(entity, Prop_Send, "m_hBuilder");
					}
					Do_Perk_Machine_Logic(owner, client, entity, 7);
				}
			}
		}
	}
	return 0;
}

static void Do_Perk_Machine_Logic(int owner, int client, int entity, int what_perk)
{
	TF2_StunPlayer(client, 0.0, 0.0, TF_STUNFLAG_SOUND, 0);
	ApplyBuildingCollectCooldown(entity, client, 40.0);
	
	i_CurrentEquippedPerk[client] = what_perk;
	i_CurrentEquippedPerkPreviously[client] = what_perk;
	
	if(!Rogue_Mode() && owner > 0 && owner != client)
	{
		if(!Rogue_Mode() && Perk_Machine_money_limit[owner][client] < 10)
		{
			GiveCredits(owner, 40, true);
			Perk_Machine_money_limit[owner][client] += 1;
			Resupplies_Supplied[owner] += 4;
			SetDefaultHudPosition(owner);
			SetGlobalTransTarget(owner);
			ShowSyncHudText(owner,  SyncHud_Notifaction, "%t", "Perk Machine Used");
		}
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
	SetGlobalTransTarget(client);
	ShowSyncHudText(client,  SyncHud_Notifaction, "%t", PerkNames_Recieved[i_CurrentEquippedPerk[client]]);
	Store_ApplyAttribs(client);
	Store_GiveAll(client, GetClientHealth(client));	
	Barracks_UpdateAllEntityUpgrades(client);
}
*/
