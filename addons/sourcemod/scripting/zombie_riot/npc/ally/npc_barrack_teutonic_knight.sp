#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Spy

methodmap BarrackTeuton < BarrackBody
{
	public BarrackTeuton(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackTeuton npc = view_as<BarrackTeuton>(BarrackBody(client, vecPos, vecAng, "1300",_,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcInternalId[npc.index] = BARRACKS_TEUTONIC_KNIGHT;
		i_NpcWeight[npc.index] = 1;
		
		SDKHook(npc.index, SDKHook_Think, BarrackTeuton_ClotThink);

		npc.m_flSpeed = 250.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.8");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/dec17_brass_bucket/dec17_brass_bucket.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		/*
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/bak_caped_crusader/bak_caped_crusader.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		*/
		
		return npc;
	}
}

public void BarrackTeuton_ClotThink(int iNPC)
{
	BarrackTeuton npc = view_as<BarrackTeuton>(iNPC);
	float GameTime = GetGameTime(iNPC);
	if(BarrackBody_ThinkStart(npc.index, GameTime))
	{
		int client = BarrackBody_ThinkTarget(npc.index, true, GameTime);

		if(npc.m_iTarget > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			//Target close enough to hit
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
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
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),9000.0, 0), DMG_CLUB, -1, _, vecHit);
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

		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_TEUTON_NEW_IDLE", "ACT_TEUTON_NEW_WALK");
	}
}

void BarrackTeuton_NPCDeath(int entity)
{
	BarrackTeuton npc = view_as<BarrackTeuton>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackTeuton_ClotThink);
}