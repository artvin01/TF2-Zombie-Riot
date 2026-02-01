#pragma semicolon 1
#pragma newdecls required


void NpcConst2Building_CommandPluginStart()
{
	RegConsoleCmd("sm_getbase_layout", Building_GiveLayout, "Base Building logic",ADMFLAG_SLAY);
}

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
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	char buffers[4][64];
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
	int entity = NPC_CreateByName(buffers[0], client, vecPos, vecAng, team, buffers[1]);
	if(IsValidEntity(entity) && team != TFTeam_Red)
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
		CClotBody npc = view_as<CClotBody>(entity);
		if(StrContains(buffers, "obj_dungeon_wall1") != -1)
		{
			//global res values
			npc.m_flMeleeArmor *= 0.75;
			npc.m_flRangedArmor *= 0.5;
		}
		if(StrContains(buffers, "obj_const2_house") != -1 || StrContains(buffers, "obj_dungeon_wall1") != -1)
		{
			SDKUnhook(entity, SDKHook_Think, ObjBaseThink);
			SDKUnhook(entity, SDKHook_ThinkPost, ObjBaseThinkPost);
		}
		b_ThisWasAnNpc[entity] = true;
		i_NpcIsABuilding[entity] = true;
		b_NpcHasDied[entity] = false;
		i_IsNpcType[entity] = STATIONARY_NPC;
		AddNpcToAliveList(entity, 1);	
		SetEntityRenderColor(entity, 255, 255, 255, 255);
		ApplyStatusEffect(entity, entity, "Const2 Scaling For Enemy Base Nerf", 999999.0);
		npc.m_flMeleeArmor *= 1.5;
		
		ObjectGeneric objstats = view_as<ObjectGeneric>(entity);
		if(IsValidEntity(objstats.m_iWearable2))
			RemoveEntity(objstats.m_iWearable2);
		//remove text
	}
	SetTeam(entity, team);
	//figure out eventually
	return entity;
}


#define FILE_CHECKBASE  "addons/sourcemod/data/zombie_riot/baselayout.cfg"
public Action Building_GiveLayout(int client, int args)
{
	char buffer[1024];
	
	DeleteFile(FILE_CHECKBASE);
	File file = OpenFile(FILE_CHECKBASE, "w");
	if(!file)
	{
		ReplyToCommand(client, "Failed?.");
		delete file;
		return Plugin_Handled;
	}
	//We give the basics now to the file to imitate a waveset
	/*
		end result as a test
		"Waves"
		{
			"1"
			{
				"0.01"
				{
					"count"				"0"
					"is_health_scaling"	"1"
					"health"			"25000"
					"plugin"			"npc_const2_building_spawner"
					
					"data"				"obj_const2_cannon;_;6495.1 923.0 -1199.9;0.0 0.0 0.0"
				}
	*/
	Format(buffer, sizeof(buffer), "\"Waves\""
	... "\n{"
	... "\n	//Created by using ''sm_getbase_layout'' In construction 2"
	... "\n	\"1\""
	... "\n	{");
	
	file.WriteLine(buffer);

	
	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		bool WasASpawner = false;
		if(!i_NpcIsABuilding[entity])
			continue;
		if (GetTeam(entity) == TFTeam_Red)
			continue;

		if(i_NpcInternalId[entity] == Const2Spawner_Id())
		{
			Const2Spawner Snpc = view_as<Const2Spawner>(entity);
			if(!Snpc.m_bEnemyBase)
				continue;
			WasASpawner = true;
		}
		
		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		char buffer2[128];
		int health = ReturnEntityMaxHealth(entity);
		NPC_GetPluginById(i_NpcInternalId[entity], buffer2, sizeof(buffer2));
		if(WasASpawner)
		{
			
			Const2SpawnerEnum Initdata;
			int length = hConst2_SpawnerSaveWave.Length;
			char DataSave[512];
			for(int i; i < length; i++)
			{
				// Loop through the arraylist to find the right attacker and victim
				hConst2_SpawnerSaveWave.GetArray(i, Initdata);
				if(Initdata.SpawnerAmRef == EntIndexToEntRef(entity))
				{
					Format(DataSave, sizeof(DataSave), "%s", Initdata.DataWave);
				}
			}

			Format(buffer, sizeof(buffer), "		\"0.01\""
			... "\n		{"
			... "\n			\"count\"				\"1\""
			... "\n			\"does_not_scale\"	\"1\""
			... "\n			\"plugin\"			\"npc_const2_spawner\""
			... "\n			\"spawn\"				\"enemy_base_point\""
			... "\n			\"data\"				\"%s;%.0f %.0f %.0f;enemy_base\""
			... "\n		}", DataSave, pos[0], pos[1], pos[2]);
		}
		else
		{
			Format(buffer, sizeof(buffer), "		\"0.01\""
			... "\n		{"
			... "\n			\"count\"				\"0\""
			... "\n			\"health\"			\"%i\""
			... "\n			\"extra_damage\"		\"1.0\""
	//		... "\n			\"is_health_scaling\"	\"1.0\""
			... "\n			\"plugin\"			\"npc_const2_building_spawner\""
	//		... "\n			\"spawn\"				\"enemy_base_point\""
			... "\n			\"data\"				\"%s;enemy_base;%.0f %.0f %.0f;%.0f %.0f %.0f\""
			... "\n		}", health, buffer2, pos[0], pos[1], pos[2], ang[0], ang[1], ang[2]);
		}
		file.WriteLine(buffer);
	}
	Format(buffer, sizeof(buffer), "\n	}"
	...	"\n	\"Freeplay\""
	... "\n	{"
	... "\n	"
	... "\n	}"
	... "\n}");
	file.WriteLine(buffer);
	delete file;
	ReplyToCommand(client, "Gave layout in file ''%s''.",FILE_CHECKBASE);
	return Plugin_Handled;
}