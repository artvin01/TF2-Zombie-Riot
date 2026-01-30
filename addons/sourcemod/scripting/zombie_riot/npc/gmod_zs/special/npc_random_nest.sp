#pragma semicolon 1
#pragma newdecls required


void NestSummonRandom_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Random Boss");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_random_nest");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Hidden; 
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);

}

static void ClotPrecache()
{
	//precaches said npcs.
	NPC_GetByPlugin("npc_zs_fast_zombie");
	NPC_GetByPlugin("npc_zs_shadow_walker");
	NPC_GetByPlugin("npc_zs_skeleton");
	NPC_GetByPlugin("npc_zs_zombie");
	NPC_GetByPlugin("npc_zs_headcrabzombie");
	NPC_GetByPlugin("npc_zs_fastheadcrab_zombie");
	NPC_GetByPlugin("npc_zs_gore_blaster");
	NPC_GetByPlugin("npc_fastzombie_fortified");
	NPC_GetByPlugin("npc_headcrabzombie_fortified");
	NPC_GetByPlugin("npc_medic_healer");
	NPC_GetByPlugin("npc_torsoless_headcrabzombie");
	NPC_GetByPlugin("npc_headcrab");
}

bool SameNestDisallow[6];
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return NestSummonRandom(vecPos, vecAng, team, data);
}
methodmap NestSummonRandom < CClotBody
{
	public NestSummonRandom(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		NestSummonRandom npc = view_as<NestSummonRandom>(CClotBody(vecPos, vecAng, "models/empty.mdl", "0.8", "700", ally));
		
		i_NpcWeight[npc.index] = 1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(NestSummonRandom_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(NestSummonRandom_ClotThink);

		i_RaidGrantExtra[npc.index] = StringToInt(data);
		if(i_RaidGrantExtra[npc.index] <= 40)
		{
			Zero(SameNestDisallow);
			//Reset
		}

		if(TeleportDiversioToRandLocation(npc.index,true,1500.0, 700.0) == 2)
		{
			TeleportDiversioToRandLocation(npc.index, true);
		}
		
		return npc;
	}
}

public void NestSummonRandom_ClotThink(int iNPC)
{
	SmiteNpcToDeath(iNPC);
}

public void NestSummonRandom_NPCDeath(int entity)
{
	NestSummonRandom npc = view_as<NestSummonRandom>(entity);
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	//Spawns a random raid.
	NestSummonRaidboss(entity);
}


void NestSummonRaidboss(int NestSummonbase)
{
	Enemy enemy;
	enemy.Health = ReturnEntityMaxHealth(NestSummonbase);
	enemy.Is_Boss = view_as<int>(b_thisNpcIsABoss[NestSummonbase]);
	enemy.Is_Immune_To_Nuke = true;
	enemy.ExtraMeleeRes = fl_Extra_MeleeArmor[NestSummonbase];
	enemy.ExtraRangedRes = fl_Extra_RangedArmor[NestSummonbase];
	enemy.ExtraSpeed = fl_Extra_Speed[NestSummonbase];
	enemy.ExtraDamage = fl_Extra_Damage[NestSummonbase];
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(NestSummonbase);
	enemy.Does_Not_Scale = 1; //scaling was already done.
	//18 is max bosses?
	char PluginName[255];
	char CharData[255];
	
	Format(CharData, sizeof(CharData), "sc%i;",i_RaidGrantExtra[NestSummonbase]);
	int NumberRand;
	SameNestDisallow[0] = true;
	while(SameNestDisallow[NumberRand])
	{
		NumberRand = GetRandomInt(1,11);
	}
	SameNestDisallow[NumberRand] = true;
	switch(NumberRand)
	{
		case 1:
		{
			PluginName = "npc_zs_fast_zombie";	
		}
		case 2:
		{
			PluginName = "npc_zs_shadow_walker";	
		}
		case 3:
		{
			PluginName = "npc_zs_skeleton";	
		}
		case 4:
		{
			PluginName = "npc_zs_zombie";	
		}
		case 5:
		{
			PluginName = "npc_zs_headcrabzombie";	
		}
		case 6:
		{
			PluginName = "npc_zs_fastheadcrab_zombie";
		}
		case 7:
		{
			PluginName = "npc_zs_gore_blaster";
		}
		case 8:
		{
			PluginName = "npc_fastzombie_fortified";
		}
		case 9:
		{
			PluginName = "npc_headcrabzombie_fortified";
		}
		case 10:
		{
			PluginName = "npc_medic_healer";
		}
		case 11:
		{
			PluginName = "npc_torsoless_headcrabzombie";
		}
		case 12:
		{
			PluginName = "npc_zombine";
		}
	}
	Format(enemy.Data, sizeof(enemy.Data), "%s",CharData);
	enemy.Index = NPC_GetByPlugin(PluginName);


	Waves_AddNextEnemy(enemy);
	Zombies_Currently_Still_Ongoing += 1;
}