#pragma semicolon 1
#pragma newdecls required

public void BarrackHussarOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Hussar");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_hussar");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackHussar(client, vecPos, vecAng);
}

methodmap BarrackHussar < BarrackBody
{
	public void PlayMeleeWarCry()
	{
		return;
//		EmitSoundToAll("mvm/mvm_tank_horn.wav", this.index, _, 60, _, 0.4, 60);
	}
	public BarrackHussar(int client, float vecPos[3], float vecAng[3])
	{
		BarrackHussar npc = view_as<BarrackHussar>(BarrackBody(client, vecPos, vecAng, "2500",_,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 2;
		KillFeed_SetKillIcon(npc.index, "scout_sword");
		
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackHussar_NPCDeath;
		func_NPCThink[npc.index] = BarrackHussar_ClotThink;

		npc.m_flSpeed = 250.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_scout_sword/c_scout_sword.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetVariantString("2.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/engineer/hwn2022_pony_express/hwn2022_pony_express.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		return npc;
	}
}

public void BarrackHussar_ClotThink(int iNPC)
{
	BarrackHussar npc = view_as<BarrackHussar>(iNPC);
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
					float damage = 9000.0;
					
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_RIDER_ATTACK");
						npc.PlaySwordSound();
						npc.m_flAttackHappens = GameTime + 0.4;
						npc.m_flNextRangedSpecialAttack = GameTime + 0.54;
						npc.m_flDoingAnimation = GameTime + 0.6;
						npc.m_flNextMeleeAttack = GameTime + (2.0 * npc.BonusFireRate);
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if(npc.m_flAttackHappens < GameTime && npc.m_flNextRangedSpecialAttack >= GameTime && npc.m_flAttackHappenswillhappen)
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
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);
								npc.PlaySwordHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flNextRangedSpecialAttack < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}

			HussarAOEBuff(view_as<MedivalHussar>(npc), GameTime, true);
		}

		BarrackBody_ThinkMove(npc.index, 250.0, "ACT_RIDER_IDLE", "ACT_RIDER_RUN");
	}
}

void BarrackHussar_NPCDeath(int entity)
{
	BarrackHussar npc = view_as<BarrackHussar>(entity);
	BarrackBody_NPCDeath(npc.index);
}