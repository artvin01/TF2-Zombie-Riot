#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Zombie
// Construction Novice

public void BarrackArcherOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Archer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_archer");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackArcher(client, vecPos, vecAng);
}

methodmap BarrackArcher < BarrackBody
{
	public BarrackArcher(int client, float vecPos[3], float vecAng[3])
	{
		BarrackArcher npc = view_as<BarrackArcher>(BarrackBody(client, vecPos, vecAng, "110",_,_,_,_,"models/pickups/pickup_powerup_precision.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "huntsman");
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackArcher_NPCDeath;
		func_NPCThink[npc.index] = BarrackArcher_ClotThink;
		func_NPCAnimEvent[npc.index] = BarrackArcher_HandleAnimEvent;
	

		npc.m_flSpeed = 200.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_bow/c_bow.mdl");
		SetVariantString("0.4");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		SetVariantInt(1);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		
		return npc;
	}
}

public void BarrackArcher_ClotThink(int iNPC)
{
	BarrackArcher npc = view_as<BarrackArcher>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < 160000.0)
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
						npc.AddGesture("ACT_CUSTOM_ATTACK_BOW");
						
			//			npc.PlayMeleeSound();
			//			npc.FireArrow(vecTarget, 25.0, 1200.0);
						npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
						npc.m_flReloadDelay = GameTime + (1.0 * npc.BonusFireRate);
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_CUSTOM_IDLE_BOW", "ACT_CUSTOM_WALK_BOW", 145000.0);
	}
}

void BarrackArcher_HandleAnimEvent(int entity, int event)
{
	if(event == 1001)
	{
		BarrackArcher npc = view_as<BarrackArcher>(entity);
		
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSound();
			npc.FireArrow(vecTarget, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),500.0, 1), 1200.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
		}
	}
	
}

void BarrackArcher_NPCDeath(int entity)
{
	BarrackArcher npc = view_as<BarrackArcher>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackArcher_ClotThink);
}
