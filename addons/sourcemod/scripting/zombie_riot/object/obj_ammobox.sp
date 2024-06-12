#pragma semicolon 1
#pragma newdecls required

void ObjectAmmobox_MapStart()
{
	PrecacheModel("models/items/ammocrate_smg1.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ammo Box");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_ammobox");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectAmmobox(client, vecPos, vecAng);
}

methodmap ObjectAmmobox < ObjectGeneric
{
	public ObjectAmmobox(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectAmmobox npc = view_as<ObjectAmmobox>(ObjectGeneric(client, vecPos, vecAng, "models/items/ammocrate_smg1.mdl", _,"50", {20.0, 20.0, 33.0}, 15.0));
		
		npc.SetActivity("Idle", true);

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;

		return npc;
	}
}

static void ClotThink(ObjectAmmobox npc)
{
	if(npc.m_flAttackHappens)
	{
		float gameTime = GetGameTime(npc.index);

		if(npc.m_flAttackHappens > 999999.9)
		{
			npc.SetActivity("Open", true);
			npc.SetPlaybackRate(0.5);	
			npc.m_flAttackHappens = gameTime + 0.6;
		}
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.SetActivity("Close", true);
			npc.SetPlaybackRate(0.5);
			npc.m_flAttackHappens = 0.0;
		}
	}
}

static bool ClotCanUse(ObjectAmmobox npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;
	
	if((Ammo_Count_Ready - Ammo_Count_Used[client]) < 1)
		return false;

	return true;
}

static void ClotShowInteractHud(ObjectAmmobox npc, int client)
{
	SetGlobalTransTarget(client);
	PrintCenterText(client, "%t", "Ammobox Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectAmmobox npc)
{
	if(ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		ClientCommand(client, "playgamesound items/ammo_pickup.wav");
		ApplyBuildingCollectCooldown(npc.index, client, 5.0, true);
		
		//Trying to apply animations outside of clot think can fail to work.


	//	npc.SetActivity("Open", true);
	//	npc.SetPlaybackRate(0.5);
	//	npc.m_flAttackHappens = GetGameTime(npc.index) + 1.4;
		npc.m_flAttackHappens = GetGameTime(npc.index) + 999999.4;
	}
	else
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
	}
	
	return true;
}
