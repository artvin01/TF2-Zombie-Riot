#pragma semicolon 1
#pragma newdecls required

#define TOWER_SIZE_BARRACKS "0.65"

methodmap BarrackBuilding < BarrackBody
{
	public BarrackBuilding(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackBuilding npc = view_as<BarrackBuilding>(BarrackBody(client, vecPos, vecAng, "5000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		i_NpcInternalId[npc.index] = BARRACKS_BUILDING;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_Think, BarrackBuilding_ClotThink);

		npc.m_flSpeed = 0.0;
		
		return npc;
	}
}

public void BarrackBuilding_ClotThink(int iNPC)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(iNPC);
	float GameTime = GetGameTime(iNPC);

	if(i_AttacksTillMegahit[iNPC] >= 255)
	{
		if(i_AttacksTillMegahit[iNPC] <= 299)
		{
			i_AttacksTillMegahit[iNPC] = 300;
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		}
	}
	else
	{
		int alpha = i_AttacksTillMegahit[iNPC];
		if(alpha > 255)
		{
			alpha = 255;
		}
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
	}
}

void BarrackBuilding_NPCDeath(int entity)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackBuilding_ClotThink);
}
