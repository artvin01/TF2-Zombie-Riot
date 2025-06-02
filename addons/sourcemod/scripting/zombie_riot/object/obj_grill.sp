#pragma semicolon 1
#pragma newdecls required

void ObjectTinkerGrill_MapStart()
{
	PrecacheModel("models/props_c17/furniturestove001a.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Merchant Grill");
	strcopy(data.Plugin, sizeof(data.Plugin), "obj_grill");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);

	BuildingInfo build;
	build.Section = 1;
	strcopy(build.Plugin, sizeof(build.Plugin), "obj_grill");
	build.Cost = 338;
	build.Health = 420;
	build.HealthScaleCost = true;
	build.Cooldown = 15.0;
	build.Func = ObjectTinkerGrill_CanBuild;
	Building_Add(build);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return ObjectTinkerGrill(client, vecPos, vecAng);
}

methodmap ObjectTinkerGrill < ObjectGeneric
{
	public ObjectTinkerGrill(int client, const float vecPos[3], const float vecAng[3])
	{
		ObjectTinkerGrill npc = view_as<ObjectTinkerGrill>(ObjectGeneric(client, vecPos, vecAng, "models/props_c17/furniturestove001a.mdl", _, "600", {27.0, 27.0, 41.0}, 20.0));

		npc.SentryBuilding = true;
		npc.FuncCanBuild = ObjectTinkerGrill_CanBuild;
		npc.FuncCanUse = ClotCanUse;
		npc.FuncShowInteractHud = ClotShowInteractHud;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCInteract[npc.index] = ClotInteract;
		i_PlayerToCustomBuilding[client] = EntIndexToEntRef(npc.index);

		for(int i; i < 4; i++)
		{
			int entity = npc.EquipItemSeperate("models/player/gibs/gibs_burger.mdl", "idle", .DontParent = true);
			
			float VecOrigin[3];
			GetAbsOrigin(npc.index, VecOrigin);

			VecOrigin[0] += (i % 2) ? 10.0 : -10.0;
			VecOrigin[1] += (i > 1) ? 10.0 : -10.0;
			VecOrigin[2] -= 54.0;

			TeleportEntity(entity, VecOrigin, NULL_VECTOR, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", npc.index);
			MakeObjectIntangeable(entity);

			AcceptEntityInput(entity, "Disable");

			switch(i)
			{
				case 0:
					npc.m_iWearable3 = entity;
				case 1:
					npc.m_iWearable4 = entity;
				case 2:
					npc.m_iWearable5 = entity;
				case 3:
					npc.m_iWearable6 = entity;
			}
		}

		npc.g_TimesSummoned = 0;

		return npc;
	}
	public int GetWearable(int pos)
	{
		switch(pos)
		{
			case 0:
				return this.m_iWearable3;
			case 1:
				return this.m_iWearable4;
			case 2:
				return this.m_iWearable5;
			case 3:
				return this.m_iWearable6;
		}
		return -1;
	}
}

public bool ObjectTinkerGrill_CanBuild(int client, int &count, int &maxcount)
{
	if(!client)
		return false;
	
	count = Object_GetSentryBuilding(client) == -1 ? 0 : 1;
	maxcount = Merchant_IsAMerchant(client) ? 1 : 0;

	return (!count && maxcount);
}

void ObjectTinkerGrill_UpdateWearables(int entity, int count)
{
	ObjectTinkerGrill npc = view_as<ObjectTinkerGrill>(entity);

	int current = ((npc.g_TimesSummoned & (1 << 0)) ? 1 : 0) +
			((npc.g_TimesSummoned & (1 << 1)) ? 1 : 0) +
			((npc.g_TimesSummoned & (1 << 2)) ? 1 : 0) +
			((npc.g_TimesSummoned & (1 << 3)) ? 1 : 0);

	current = min(current, 4);
	current = max(current, 0);

	int amount = min(count, 4);
	amount = max(amount, 0);
	
	// Add more
	while(current < amount)
	{
		int rand = GetURandomInt() % 4;
		for(int i = rand + 1; ; i++)
		{
			if(i > 3)
			{
				i = -1;
				continue;
			}

			if(!(npc.g_TimesSummoned & (1 << i)))
			{
				npc.g_TimesSummoned |= (1 << i);

				int wearable = npc.GetWearable(i);
				if(wearable != -1)
					AcceptEntityInput(wearable, "Enable");
				
				break;
			}

			if(i == rand)
				break;
		}

		current++;
	}
	
	// Remove more
	while(current > amount)
	{
		int rand = GetURandomInt() % 4;
		for(int i = rand + 1; ; i++)
		{
			if(i > 3)
			{
				i = -1;
				continue;
			}
			
			if((npc.g_TimesSummoned & (1 << i)))
			{
				npc.g_TimesSummoned &= ~(1 << i);

				int wearable = npc.GetWearable(i);
				if(wearable != -1)
					AcceptEntityInput(wearable, "Disable");
				
				break;
			}

			if(i == rand)
				break;
		}

		current--;
	}
}

static void ClotThink(ObjectTinkerGrill npc)
{
	/*int maxrepair = GetEntProp(npc.index, Prop_Data, "m_iRepairMax");
	int repair = GetEntProp(npc.index, Prop_Data, "m_iRepair");
	if(repair < maxrepair)
	{
		// Regen 1% repair a second
		repair += maxrepair / 1000;
		if(repair > maxrepair)
			repair = maxrepair;

		SetEntProp(npc.index, Prop_Data, "m_iRepair", repair);
	}*/
}

static bool ClotCanUse(ObjectTinkerGrill npc, int client)
{
	if(Building_Collect_Cooldown[npc.index][client] > GetGameTime())
	{
		if(GetEntPropEnt(npc.index, Prop_Send, "m_hOwnerEntity") == client)
		{
			if(f_MedicCallIngore[client] > GetGameTime())
				return true;
		}
		
		return false;
	}

	return true;
}

static void ClotShowInteractHud(ObjectTinkerGrill npc, int client)
{
	char ButtonDisplay[255];
	char ButtonDisplay2[255];
	PlayerHasInteract(client, ButtonDisplay, sizeof(ButtonDisplay));
	BuildingVialityDisplay(client, npc.index, ButtonDisplay2, sizeof(ButtonDisplay2));
	PrintCenterText(client, "%s\n%s%T",ButtonDisplay2,ButtonDisplay, "Healing Station Tooltip",client);
}

static bool ClotInteract(int client, int weapon, ObjectTinkerGrill npc)
{
	if(!ClotCanUse(npc, client))
	{
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	if((GetURandomInt() % 4) == 0 && Rogue_HasNamedArtifact("System Malfunction"))
	{
		Building_Collect_Cooldown[npc.index][0] = GetGameTime() + 5.0;
		ClientCommand(client, "playgamesound items/medshotno1.wav");
		return true;
	}

	BlacksmithGrill_BuildingUsed(npc.index, client);
	return true;
}