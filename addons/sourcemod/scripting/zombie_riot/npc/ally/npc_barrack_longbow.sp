#pragma semicolon 1
#pragma newdecls required

// Balanced around Early Spy

public void BarrackLongbowOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Medival Longbowmen");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_longbow");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BarrackLongbow(client, vecPos, vecAng, ally);
}
methodmap BarrackLongbow < BarrackBody
{
	public BarrackLongbow(int client, float vecPos[3], float vecAng[3], int ally)
	{
		BarrackLongbow npc = view_as<BarrackLongbow>(BarrackBody(client, vecPos, vecAng, "350",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackLongbow_NPCDeath;
		func_NPCThink[npc.index] = BarrackLongbow_ClotThink;
		func_NPCAnimEvent[npc.index] = BarrackLongbow_HandleAnimEvent;
		
		npc.m_flSpeed = 275.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bow/c_bow.mdl");
		SetVariantString("0.6");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/scout/spr17_the_lightning_lid/spr17_the_lightning_lid.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackLongbow_ClotThink(int iNPC)
{
	BarrackLongbow npc = view_as<BarrackLongbow>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 320000.0)
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
						npc.AddGesture("ACT_LONGBOW_ATTACK");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GameTime + (1.0 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 275.0, "ACT_LONGBOW_IDLE", "ACT_LONGBOW_WALK", 275000.0);
	}
}

void BarrackLongbow_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackLongbow npc = view_as<BarrackLongbow>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 2000.0,_, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),8000.0, 1), 2000.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
}

void BarrackLongbow_NPCDeath(int entity)
{
	BarrackLongbow npc = view_as<BarrackLongbow>(entity);
	BarrackBody_NPCDeath(npc.index);
}
