#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Combine
// Construction Apprentice

methodmap BarrackCrossbow < BarrackBody
{
	public BarrackCrossbow(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackCrossbow npc = view_as<BarrackCrossbow>(BarrackBody(client, vecPos, vecAng, "160"));
		
		i_NpcInternalId[npc.index] = BARRACK_CROSSBOW;
		
		SDKHook(npc.index, SDKHook_Think, BarrackCrossbow_ClotThink);

		npc.m_flSpeed = 175.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("0.4");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackCrossbow_ClotThink(int iNPC)
{
	BarrackCrossbow npc = view_as<BarrackCrossbow>(iNPC);
	if(BarrackBody_ThinkStart(npc.index))
	{
		BarrackBody_ThinkTarget(npc.index, false);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < 170000.0)
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
						npc.AddGesture("ACT_CUSTOM_ATTACK_CROSSBOW");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (2.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GetGameTime(npc.index) + (0.7 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 175.0, "ACT_CUSTOM_IDLE_CROSSBOW", "ACT_CUSTOM_WALK_CROSSBOW", 170000.0);
	}
}

void BarrackCrossbow_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackCrossbow npc = view_as<BarrackCrossbow>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			int arrow = npc.FireArrow(vecTarget, 235.0 * npc.BonusDamageBonus, 1200.0);
			if(arrow > MaxClients)
				SetEntPropEnt(arrow, Prop_Send, "m_hOwnerEntity", GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackCrossbow_NPCDeath(int entity)
{
	BarrackCrossbow npc = view_as<BarrackCrossbow>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackCrossbow_ClotThink);
}