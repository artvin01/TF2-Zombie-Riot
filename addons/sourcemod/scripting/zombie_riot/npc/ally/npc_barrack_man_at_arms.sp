#pragma semicolon 1
#pragma newdecls required

methodmap BarrackManAtArms < BarrackBody
{
	public BarrackManAtArms(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackManAtArms npc = view_as<BarrackManAtArms>(BarrackBody(client, vecPos, vecAng, "160"));
		
		i_NpcInternalId[npc.index] = BARRACK_MAN_AT_ARMS;
		
		SDKHook(npc.index, SDKHook_Think, BarrackManAtArms_ClotThink);

		npc.m_flSpeed = 175.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.375");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/player/items/mvm_loot/soldier/robot_helmet.mdl");
		SetVariantString("0.875");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("weapon_targe", "models/weapons/c_models/c_targe/c_targe.mdl");
		SetVariantString("0.625");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		return npc;
	}
}

public void BarrackManAtArms_ClotThink(int iNPC)
{
	BarrackManAtArms npc = view_as<BarrackManAtArms>(iNPC);
	if(BarrackBody_ThinkStart(npc.index))
	{
		BarrackBody_ThinkTarget(npc.index, false);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			//Target close enough to hit
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
						npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index) + 0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 0.54;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 250.0, DMG_CLUB, -1, _, vecHit);
								npc.PlayMeleeHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, "ACT_IDLE", "ACT_WALK");
	}
}

void BarrackManAtArms_NPCDeath(int entity)
{
	BarrackManAtArms npc = view_as<BarrackManAtArms>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackManAtArms_ClotThink);
}