#pragma semicolon 1
#pragma newdecls required

#define CRYSTAL_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl"

static int NPCId;


void SensalTargetLaser_OnMapStart_NPC()
{
	PrecacheModel(CRYSTAL_MODEL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Sensal Targeter");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_sensal_crystal_targeter");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int SensalTargetLaser_Id()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return SensalTargetLaser(vecPos, vecAng);
}

methodmap SensalTargetLaser < CClotBody
{
	
	public SensalTargetLaser(float vecPos[3], float vecAng[3])
	{
		SensalTargetLaser npc = view_as<SensalTargetLaser>(CClotBody(vecPos, vecAng, CRYSTAL_MODEL, "0.01", "999999999", true, true,false,_,_,_, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");


		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iWearable1 = npc.EquipItemSeperate(CRYSTAL_MODEL,_,_,_,30.0);
		SetVariantString("2.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		func_NPCDeath[npc.index] = SensalTargetLaser_NPCDeath;
	//	func_NPCOnTakeDamage[npc.index] = SensalTargetLaser_OnTakeDamage;
	//	func_NPCThink[npc.index] = SensalTargetLaser_ClotThink;

		npc.m_iBleedType = 0;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE, //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		npc.m_bDissapearOnDeath 				= true;
		npc.b_BlockDropChances					= true;

		i_NpcIsABuilding[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		npc.m_bNoKillFeed = true;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		b_ThisEntityIgnored[npc.index] = true;
		AddNpcToAliveList(npc.index, 1);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;

		return npc;
	}
}

public void SensalTargetLaser_NPCDeath(int entity)
{
	SensalTargetLaser npc = view_as<SensalTargetLaser>(entity);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}