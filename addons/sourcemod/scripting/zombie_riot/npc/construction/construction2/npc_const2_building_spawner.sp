#pragma semicolon 1
#pragma newdecls required

static int NPCId;

void Const2BuildingCreateOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Const2 Spawner");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_const2_building_spawner");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int Const2BuildingCreate_Id()
{
	return NPCId;
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	static char buffers[4][64];
	/*
		0 : npc index
		1 : data for it
		2 : Position
		3 : angles
	*/

	ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
	if(buffers[2][0])
		ExplodeStringFloat(buffers[2], " ", vecPos, sizeof(vecPos));
	if(buffers[3][0])
		ExplodeStringFloat(buffers[3], " ", vecAng, sizeof(vecAng));

	int entity = NPC_CreateByName(buffers[0], client, vecPos, vecAng, team, buffers[1], true);
	if(team != TFTeam_Red)
	{
		//its an enemy one, set all neccecary logics needed
		i_IsABuilding[entity] = false;
 		b_CantCollidie[entity] = false;
	 	b_CantCollidieAlly[entity] = false;
		b_AllowCollideWithSelfTeam[entity] = false;
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", -1);
		SetEntityCollisionGroup(entity, 5);
		ApplyStatusEffect(entity, entity, "Solid Stance", 999999.0);	
		ApplyStatusEffect(entity, entity, "Fluid Movement", 999999.0);	
		SetEntityFlags(entity, FL_NPC);
		SetEntProp(entity, Prop_Data, "m_nSolidType", 2);

		//add to NPC list.
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int eloop = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(!IsValidEntity(eloop))
			{
				i_ObjectsNpcsTotal[entitycount] = EntIndexToEntRef(entity);
				break;
			}
		}

		b_ThisWasAnNpc[entity] = true;
		i_NpcIsABuilding[entity] = true;
		b_NpcHasDied[entity] = false;
		i_IsNpcType[entity] = STATIONARY_NPC;
		AddNpcToAliveList(entity, 1);	
		SetEntityRenderColor(entity, 255, 255, 255, 255);
		b_IsBuildingConverted[entity] = true;
	}
	SetTeam(entity, team);
	//figure out eventually
	return entity;
}