#pragma semicolon 1
#pragma newdecls required

static char g_ShootingSound[][] = {
	"weapons/sentry_shoot_mini.wav",
};

void ObjectGoliath_Factory_MapStart()
{
	PrecacheSoundArray(g_ShootingSound);
	PrecacheModel("models/props_combine/combine_teleportplatform.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Goliath Factory");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_goliath_factory");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_goliath_factory");
	build.Cost = 600;
	build.Health = 30;
	build.Cooldown = 30.0;
	build.Func = ObjectGeneric_CanBuildSentry;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectGoliathFactory(client, vecPos, vecAng);
}

methodmap ObjectGoliathFactory < ObjectGeneric
{
	public void PlayShootSound() 
	{
		EmitSoundToAll(g_ShootingSound[GetRandomInt(0, sizeof(g_ShootingSound) - 1)], this.index, SNDCHAN_AUTO, 80, _, 0.8, 100);
	}
	public ObjectGoliathFactory(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectGoliathFactory npc = view_as<ObjectGoliathFactory>(ObjectGeneric(client, vecPos, vecAng, "models/props_combine/combine_teleportplatform.mdl", "0.75","50", {15.0, 15.0, 34.0},_,false));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectGeneric_CanBuildSentry;
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ObjectGoliathFactory_ClotThink;
		SetRotateByDefaultReturn(npc.index, 180.0);
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		return npc;
	}
}


void ObjectGoliathFactory_ClotThink(ObjectGoliathFactory npc)
{
	int Owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(Owner))
	{
		return;
	}

}



static bool ClotCanUse(ObjectPerkMachine npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
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
