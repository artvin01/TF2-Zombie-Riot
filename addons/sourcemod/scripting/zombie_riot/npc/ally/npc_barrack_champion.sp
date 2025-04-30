#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Spy
public void BarrackChampionOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Champion");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_champion");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackChampion(client, vecPos, vecAng);
}

methodmap BarrackChampion < BarrackBody
{
	public BarrackChampion(int client, float vecPos[3], float vecAng[3])
	{
		BarrackChampion npc = view_as<BarrackChampion>(BarrackBody(client, vecPos, vecAng, "1000",_,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		KillFeed_SetKillIcon(npc.index, "claidheamohmor");
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackChampion_NPCDeath;
		func_NPCThink[npc.index] = BarrackChampion_ClotThink;


		npc.m_flSpeed = 250.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/soldier/sum20_breach_and_bomb/sum20_breach_and_bomb.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop/player/items/medic/hw2013_spacemans_suit/hw2013_spacemans_suit.mdl");
		SetVariantString("0.9");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		return npc;
	}
}

public void BarrackChampion_ClotThink(int iNPC)
{
	BarrackChampion npc = view_as<BarrackChampion>(iNPC);
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
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),5900.0, 0), DMG_CLUB, -1, _, vecHit);
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

		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_IDLE", "ACT_CUSTOM_WALK_SWORD");
	}
}

void BarrackChampion_NPCDeath(int entity)
{
	BarrackChampion npc = view_as<BarrackChampion>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackChampion_ClotThink);
}