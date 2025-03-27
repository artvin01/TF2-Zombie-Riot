#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Combine
// Construction Worker

public void BarrackSwordsmanOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Long Swordsman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_swordsman");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BarrackSwordsman(client, vecPos, vecAng, ally);
}

methodmap BarrackSwordsman < BarrackBody
{
	public BarrackSwordsman(int client, float vecPos[3], float vecAng[3], int ally)
	{
		BarrackSwordsman npc = view_as<BarrackSwordsman>(BarrackBody(client, vecPos, vecAng, "400",_,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "sword");
		

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackSwordsman_NPCDeath;
		func_NPCThink[npc.index] = BarrackSwordsman_ClotThink;

		npc.m_flSpeed = 200.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/demo/jul13_stormn_normn/jul13_stormn_normn.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("weapon_targe", "models/workshop/weapons/c_models/c_persian_shield/c_persian_shield.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		return npc;
	}
}

public void BarrackSwordsman_ClotThink(int iNPC)
{
	BarrackSwordsman npc = view_as<BarrackSwordsman>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						npc.AddGesture("ACT_CUSTOM_ATTACK_SWORD");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (1.0 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),850.0, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
		}

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_IDLE", "ACT_CUSTOM_WALK_SWORD");
	}
}

void BarrackSwordsman_NPCDeath(int entity)
{
	BarrackSwordsman npc = view_as<BarrackSwordsman>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackSwordsman_ClotThink);
}