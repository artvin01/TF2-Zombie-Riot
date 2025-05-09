#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Soldier

public void BarrackArbelastOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medieval Arbalest");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_arbelast");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackArbelast(client, vecPos, vecAng);
}

methodmap BarrackArbelast < BarrackBody
{
	public BarrackArbelast(int client, float vecPos[3], float vecAng[3])
	{
		BarrackArbelast npc = view_as<BarrackArbelast>(BarrackBody(client, vecPos, vecAng, "250",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackArbelast_NPCDeath;
		func_NPCThink[npc.index] = BarrackArbelast_ClotThink;
		func_NPCAnimEvent[npc.index] = BarrackArbelast_HandleAnimEvent;
		npc.m_flSpeed = 250.0;
		
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
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 180000.0)
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
						npc.m_flReloadDelay = GameTime + (0.6 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_CUSTOM_IDLE_CROSSBOW", "ACT_CUSTOM_WALK_CROSSBOW", 165000.0);
	}
}

void BarrackArbelast_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackArbelast npc = view_as<BarrackArbelast>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0, _,vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),1750.0, 1), 1200.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackArbelast_NPCDeath(int entity)
{
	BarrackArbelast npc = view_as<BarrackArbelast>(entity);
	BarrackBody_NPCDeath(npc.index);
}
