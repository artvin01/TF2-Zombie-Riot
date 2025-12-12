#pragma semicolon 1
#pragma newdecls required

void ObjectArmorTable_MapStart()
{
	PrecacheModel("models/props_manor/table_01.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Armor Table");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_armortable");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_armortable");
	build.Cost = 400;
	build.Health = 50;
	build.Cooldown = 20.0;
	build.Func = ObjectGeneric_CanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectArmorTable(client, vecPos, vecAng);
}

methodmap ObjectArmorTable < ObjectGeneric
{
	public ObjectArmorTable(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectArmorTable npc = view_as<ObjectArmorTable>(ObjectGeneric(client, vecPos, vecAng, "models/props_manor/table_01.mdl", _, "50",{20.0, 20.0, 33.0}));

		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCInteract[npc.index] = ClotInteract;

		return npc;
	}
}

static bool ClotCanUse(ObjectArmorTable npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
		return false;

	//During raids, only allow a certain number of uses from armor tables.
	if(RaidbossIgnoreBuildingsLogic(0))
	{
		if(i_MaxArmorTableUsed[client] >= RAID_MAX_ARMOR_TABLE_USE)
			return false;
	}

	return true;
}

static void ClotShowInteractHud(ObjectArmorTable npc, int client)
{
	SetGlobalTransTarget(client);
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%t", ButtonDisplay2, ButtonDisplay, "Armortable Tooltip");
}

static bool ClotInteract(int client, int weapon, ObjectArmorTable npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if((GetURandomInt() % 4) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
	{
		Building_Collect_Cooldown[npc.index][client] = GetGameTime() + 5.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	int Armor_Max = 300;

	Armor_Max = MaxArmorCalculation(Armor_Level[client], client, 1.0);

	bool GiveArmor = true;
	if(Armor_Charge[client] < Armor_Max)
	{
		if(RaidbossIgnoreBuildingsLogic(0))
		{
			if(i_MaxArmorTableUsed[client] < RAID_MAX_ARMOR_TABLE_USE)
			{
				i_MaxArmorTableUsed[client]++;
			}
			else
				GiveArmor = false;
		}
	}
	else
		GiveArmor = false;

	if(!GiveArmor)
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}
	int owner = GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity");
	Building_GiveRewardsUse(client, owner, 30, true, 0.75, true);
	GiveArmorViaPercentage(client, 0.2, 1.0);
	ApplyBuildingCollectCooldown(npc.index, client, 45.0);
	ClientCommand(client, "playgamesound ambient/machines/machine1_hit2.wav");
	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 45.0;

	TE_Particle("halloween_boss_axe_hit_sparks", pos, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	
	return true;
}