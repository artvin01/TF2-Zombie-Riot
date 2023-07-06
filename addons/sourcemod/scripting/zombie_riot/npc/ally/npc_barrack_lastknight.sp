#pragma semicolon 1
#pragma newdecls required

methodmap BarrackLastKnight < BarrackBody
{
	public BarrackLastKnight(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackLastKnight npc = view_as<BarrackLastKnight>(BarrackBody(client, vecPos, vecAng, "3000", _, _, "0.75",_,"models/pickups/pickup_powerup_regen.mdl"));
		
		i_NpcInternalId[npc.index] = BARRACK_LASTKNIGHT;
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "spy_cicle");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, BarrackLastKnight_ClotThink);

		npc.m_flSpeed = 150.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		return npc;
	}
}

public void BarrackLastKnight_ClotThink(int iNPC)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(iNPC);
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
						npc.AddGesture("ACT_CUSTOM_ATTACK_LUCIAN");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.45;
						npc.m_flAttackHappens_bullshit = GameTime + 0.64;
						npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
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
								npc.PlaySwordHitSound();

								static int AttackCount;
								if(++AttackCount > 4)
								{
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),8000.0, 0), DMG_CLUB, -1, _, vecHit);
									Custom_Knockback(npc.index, target, 1000.0);
									AttackCount = 0;
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),4000.0, 0), DMG_CLUB, -1, _, vecHit);
								}
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

		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_PRINCE_IDLE", "ACT_PRINCE_WALK");
	}
}

void BarrackLastKnight_NPCDeath(int entity)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackLastKnight_ClotThink);
}