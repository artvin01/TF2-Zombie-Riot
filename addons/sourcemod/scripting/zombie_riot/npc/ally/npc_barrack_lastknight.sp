#pragma semicolon 1
#pragma newdecls required

public void BarrackLastKnightOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tide-Hunt Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_lastknight");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackLastKnight(client, vecPos, vecAng);
}

methodmap BarrackLastKnight < BarrackBody
{
	public BarrackLastKnight(int client, float vecPos[3], float vecAng[3])
	{
		BarrackLastKnight npc = view_as<BarrackLastKnight>(BarrackBody(client, vecPos, vecAng, "3000", _, _, "0.75",_,"models/pickups/pickup_powerup_regen.mdl"));
		
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "spy_cicle");
		
		npc.m_bSelectableByAll = true;
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackLastKnight_NPCDeath;
		func_NPCThink[npc.index] = BarrackLastKnight_ClotThink;

		npc.m_flSpeed = 150.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/sbox2014_knight_helmet/sbox2014_knight_helmet_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sf14_deadking_pauldrons/sf14_deadking_pauldrons.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/sbox2014_demo_samurai_armour/sbox2014_demo_samurai_armour.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
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
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				if(npc.m_flNextMeleeAttack < GameTime || npc.m_flAttackHappenswillhappen)
				{
					static int AttackCount;

					if(!npc.m_flAttackHappenswillhappen)
					{
						AttackCount++;

						npc.m_flNextRangedSpecialAttack = GameTime + 2.0;
						npc.AddGesture(AttackCount > 4 ? "ACT_LAST_KNIGHT_ATTACK_2" : "ACT_LAST_KNIGHT_ATTACK_1");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + (AttackCount > 4 ? 0.35 : 0.25);
						npc.m_flAttackHappens_bullshit = GameTime + 0.44;
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

								if(AttackCount > 4)
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

		BarrackBody_ThinkMove(npc.index, 150.0, "ACT_LAST_KNIGHT_WALK", "ACT_LAST_KNIGHT_WALK");
	}
}

void BarrackLastKnight_NPCDeath(int entity)
{
	BarrackLastKnight npc = view_as<BarrackLastKnight>(entity);
	BarrackBody_NPCDeath(npc.index);
}