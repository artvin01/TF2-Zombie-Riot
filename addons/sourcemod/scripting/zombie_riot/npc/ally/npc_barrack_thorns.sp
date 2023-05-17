#pragma semicolon 1
#pragma newdecls required

methodmap BarrackThorns < BarrackBody
{
	public BarrackThorns(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		bool elite = Store_HasNamedItem(client, "Construction Master");

		BarrackThorns npc = view_as<BarrackThorns>(BarrackBody(client, vecPos, vecAng, elite ? "1200" : "900"));
		
		i_NpcInternalId[npc.index] = BARRACK_THORNS;
		
		SDKHook(npc.index, SDKHook_Think, BarrackThorns_ClotThink);

		npc.m_flSpeed = 250.0;

		if(elite)
			npc.BonusDamageBonus *= 1.5;
		
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

public void BarrackThorns_ClotThink(int iNPC)
{
	BarrackThorns npc = view_as<BarrackThorns>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			//Target close enough to hit
			if(flDistanceToTarget < 650000.0 || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_CUSTOM_ATTACK_SWORD");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.3;
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
						npc.m_flNextMeleeAttack = GameTime + (1.0 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
					{
						if(flDistanceToTarget < 10000.0)
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
									SDKHooks_TakeDamage(target, npc.index, client, 2000.0 * npc.BonusDamageBonus, DMG_CLUB, -1, _, vecHit);
									npc.PlaySwordHitSound();
								} 
							}
							delete swingTrace;
						}
						else
						{
							float vecTarget[3]; vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1600.0);
							npc.FaceTowards(vecTarget, 30000.0);
							
							npc.PlayRangedSound();
							npc.FireArrow(vecTarget, 3000.0 * npc.BonusDamageBonus, 1600.0, _, _, _, GetClientOfUserId(npc.OwnerUserId));
						}

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

void BarrackThorns_NPCDeath(int entity)
{
	BarrackThorns npc = view_as<BarrackThorns>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackThorns_ClotThink);
}