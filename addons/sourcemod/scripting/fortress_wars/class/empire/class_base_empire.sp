#pragma semicolon 1
#pragma newdecls required

enum
{
	EmpireTech_Loom = 0,

	EmpireTech_MAX
}

static bool Techs[MAX_TEAMS][EmpireTech_MAX];

public void ClassEmpire_Setup(int team, const float pos[3])
{
	for(int i; i < sizeof(Techs[]); i++)
	{
		Techs[team][i] = false;
	}

	float pos2[3];
	pos2 = pos;
	Object_CreateByName("object_towncenter", team, pos2);

	pos2[2] += 100.0;

	pos2[0] += 300.0;
	pos2[1] += 300.0;
	NPC_CreateByName("npc_villager", team, pos2, SPAWN_ANGLES);

	pos2[1] -= 600.0;
	NPC_CreateByName("npc_villager", team, pos2, SPAWN_ANGLES);

	pos2[0] -= 600.0;
	NPC_CreateByName("npc_villager", team, pos2, SPAWN_ANGLES);

	pos2[1] += 600.0;
	NPC_CreateByName("npc_villager", team, pos2, SPAWN_ANGLES);
}

public void ClassEmpire_NPCSpawn(int team, int entity, const NPCData data)
{
	if(StrEqual(data.Plugin, "npc_villager"))
	{
		if(Techs[team][EmpireTech_Loom])
		{
			Stats[entity].RangeArmorBonus += 2;
			Stats[entity].MeleeArmorBonus += 1;
			RTS_AddMaxHealth(entity, 15);
		}
	}
}

bool ClassEmpire_HasTech(int team, int tech)
{
	return Techs[team][tech];
}

void ClassEmpire_AddTech(int team, int tech)
{
	if(Techs[team][tech])
		return;
	
	Techs[team][tech] = true;

	switch(tech)
	{
		case EmpireTech_Loom:
		{
			int id = NPC_GetByPlugin("npc_villager");

			int entity = -1;
			while(RTS_FindTeamUnitById(entity, team, id))
			{
				Stats[entity].RangeArmorBonus += 2;
				Stats[entity].MeleeArmorBonus += 1;
				RTS_AddMaxHealth(entity, 15);
			}
		}
	}
}
