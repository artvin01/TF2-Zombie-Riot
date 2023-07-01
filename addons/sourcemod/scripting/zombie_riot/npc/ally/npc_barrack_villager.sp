#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Spy

methodmap BarrackVillager < BarrackBody
{
	public BarrackVillager(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackVillager npc = view_as<BarrackVillager>(BarrackBody(client, vecPos, vecAng, "1000"));
		
		i_NpcInternalId[npc.index] = BARRACKS_TEUTONIC_KNIGHT;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, BarrackVillager_ClotThink);

		npc.m_flSpeed = 150.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_sledgehammer/c_sledgehammer.mdl");
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

public void BarrackVillager_ClotThink(int iNPC)
{
	BarrackVillager npc = view_as<BarrackVillager>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		//	npc.SetActivity("ACT_VILLAGER_BUILD_LOOP");
		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_VILLAGER_IDLE", "ACT_VILLAGER_RUN");
	}
}

void BarrackVillager_NPCDeath(int entity)
{
	BarrackVillager npc = view_as<BarrackVillager>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackVillager_ClotThink);
}