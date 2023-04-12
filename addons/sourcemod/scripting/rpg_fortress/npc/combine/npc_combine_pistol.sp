#pragma semicolon 1
#pragma newdecls required

methodmap CombinePistol < CombinePolice
{
	public CombinePistol(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CombinePistol npc = view_as<CombinePistol>(CombinePolice(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "300", ally, false));
		
		i_NpcInternalId[npc.index] = COMBINE_PISTOL;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		npc.m_fbGunout = false;
		npc.m_bmovedelay = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 12;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, CombinePistol_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, CombinePistol_ClotThink);

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_stunbaton.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		return npc;
	}
}

public void CombinePistol_ClotThink(int iNPC)
{
	ZombiefiedCombineSwordsman npc = view_as<ZombiefiedCombineSwordsman>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime;// + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
}