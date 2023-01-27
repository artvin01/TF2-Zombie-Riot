#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Soldier

methodmap BarrackArbelast < BarrackBody
{
	public BarrackArbelast(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackArbelast npc = view_as<BarrackArbelast>(BarrackBody(client, vecPos, vecAng, "250"));
		
		i_NpcInternalId[npc.index] = BARRACK_ARBELAST;
		
		SDKHook(npc.index, SDKHook_Think, BarrackArbelast_ClotThink);

		npc.m_flSpeed = 200.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_crusaders_crossbow/c_crusaders_crossbow.mdl");
		SetVariantString("0.4");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/scout/hwn2018_hephaistos_handcraft/hwn2018_hephaistos_handcraft.mdl");
		SetVariantString("1.3");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackArbelast_ClotThink(int iNPC)
{
	BarrackArbelast npc = view_as<BarrackArbelast>(iNPC);
	if(BarrackBody_ThinkStart(npc.index))
	{
		BarrackBody_ThinkTarget(npc.index, false);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < 180000.0)
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
						npc.m_flReloadDelay = GetGameTime(npc.index) + (0.6 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_CUSTOM_IDLE_CROSSBOW", "ACT_CUSTOM_WALK_CROSSBOW", 180000.0);
	}
}

void BarrackArbelast_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackArbelast npc = view_as<BarrackArbelast>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, 1300.0 * npc.BonusDamageBonus, 1200.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackArbelast_NPCDeath(int entity)
{
	BarrackArbelast npc = view_as<BarrackArbelast>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackArbelast_ClotThink);
}