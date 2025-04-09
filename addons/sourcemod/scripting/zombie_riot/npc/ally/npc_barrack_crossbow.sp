#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Combine
// Construction Apprentice

public void BarrackCrossbowOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Crossbow Man");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_crossbow");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackCrossbow(client, vecPos, vecAng);
}

methodmap BarrackCrossbow < BarrackBody
{
	public BarrackCrossbow(int client, float vecPos[3], float vecAng[3])
	{
		BarrackCrossbow npc = view_as<BarrackCrossbow>(BarrackBody(client, vecPos, vecAng, "160",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackCrossbow_NPCDeath;
		func_NPCThink[npc.index] = BarrackCrossbow_ClotThink;
		func_NPCAnimEvent[npc.index] = BarrackCrossbow_HandleAnimEvent;
	
		npc.m_flSpeed = 225.0;
		
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
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 170000.0)
			{
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GameTime)
					{
						npc.m_flSpeed = 0.0;
						npc.FaceTowards(vecTarget, 30000.0);
						//Play attack anim
						npc.AddGesture("ACT_CUSTOM_ATTACK_CROSSBOW");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GameTime + (3.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GameTime + (0.7 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 225.0, "ACT_CUSTOM_IDLE_CROSSBOW", "ACT_CUSTOM_WALK_CROSSBOW", 155000.0);
	}
}

void BarrackCrossbow_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackCrossbow npc = view_as<BarrackCrossbow>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0,_, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),800.0, 1), 1200.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackCrossbow_NPCDeath(int entity)
{
	BarrackCrossbow npc = view_as<BarrackCrossbow>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackCrossbow_ClotThink);
}
