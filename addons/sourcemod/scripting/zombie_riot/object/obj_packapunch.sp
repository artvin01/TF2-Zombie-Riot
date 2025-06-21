#pragma semicolon 1
#pragma newdecls required

float f_CheckWeaponDelay[MAXPLAYERS];
bool b_LastWeaponCheckBias[MAXPLAYERS];

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

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_packapunch");
	build.Cost = 1000;
	build.Health = 50;
	build.Cooldown = 60.0;
	build.Func = ObjectGeneric_CanBuild;
	Building_Add(build);

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
	
	//Just allow.
	bool started = true;// Waves_Started();
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
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%t", ButtonDisplay2, ButtonDisplay,"PackAPunch Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectPackAPunch npc)
{
	if(ClientTutorialStep(client) == 5)
	{
		KillMostCurrentIDAnnotation(client, i_CurrentIdBeforeAnnoation[client]);
		SetClientTutorialStep(client, 6);
		DoTutorialStep(client, false);	
	}
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

	if(owner > MaxClients)
		owner = client;

	Store_PackMenu(client, StoreWeapon[weapon], -1, owner);
	return true;
}