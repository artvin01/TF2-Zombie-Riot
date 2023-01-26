#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Spy

methodmap BarrackLongbow < BarrackBody
{
	public BarrackLongbow(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackLongbow npc = view_as<BarrackLongbow>(BarrackBody(client, vecPos, vecAng, "350"));
		
		i_NpcInternalId[npc.index] = BARRACK_LONGBOW;
		
		SDKHook(npc.index, SDKHook_Think, BarrackLongbow_ClotThink);

		npc.m_flSpeed = 225.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("0.4");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackLongbow_ClotThink(int iNPC)
{
	BarrackLongbow npc = view_as<BarrackLongbow>(iNPC);
	if(BarrackBody_ThinkStart(npc.index))
	{
		BarrackBody_ThinkTarget(npc.index, false);

		bool path = true;
		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < 320000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
					{
						npc.m_flSpeed = 0.0;
						npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_LONGBOW_ATTACK");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (3.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GetGameTime(npc.index) + (1.0 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_CUSTOM_IDLE_BOW", "ACT_LONGBOW_WALK", 250000.0);
	}
}

void BarrackLongbow_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackLongbow npc = view_as<BarrackLongbow>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 2000.0);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, 3750.0 * npc.BonusDamageBonus, 2000.0);
		}
	}
}

void BarrackLongbow_NPCDeath(int entity)
{
	BarrackLongbow npc = view_as<BarrackLongbow>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackLongbow_ClotThink);
}