#pragma semicolon 1
#pragma newdecls required

// Balanced around Mid Spy

public void BarrackTeutonOnMapStart()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Teutonic Knight");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_teutonic_knight");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
	
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackTeuton(client, vecPos, vecAng);
}

methodmap BarrackTeuton < BarrackBody
{
	public BarrackTeuton(int client, float vecPos[3], float vecAng[3])
	{
		BarrackTeuton npc = view_as<BarrackTeuton>(BarrackBody(client, vecPos, vecAng, "1300",COMBINE_CUSTOM_2_MODEL,_,_,_,"models/pickups/pickup_powerup_strength_arm.mdl"));
		
		i_NpcWeight[npc.index] = 1;
		

		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackTeuton_NPCDeath;
		func_NPCThink[npc.index] = BarrackTeuton_ClotThink;
		func_NPCOnTakeDamage[npc.index] = BarrackTeuton_OnTakeDamage;
		npc.m_flSpeed = 250.0;
		
		npc.Anger = false;
		
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
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");	
		
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
						if(!ShouldNpcDealBonusDamage(npc.m_iTarget))
							npc.AddGesture("ACT_TEUTON_ATTACK_NEW", _,_,_, 1.1);
						else
							npc.AddGesture("ACT_TEUTON_ATTACK_CADE_NEW", _,_,_, 1.1);
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
							
							float damage = 9000.0;
							
							if(target > 0) 
							{
								if(npc.Anger) // Wrathful strike, hits significantly harder if the teutonic took more than 33% max hp as damage from 1 source, deactivates after 1 hit
								{
									damage *= 2.5;
									npc.Anger = false;
									ResetTeutonWeapon(npc, 0);
								}
								SDKHooks_TakeDamage(target, npc.index, client, Barracks_UnitExtraDamageCalc(npc.index, GetClientOfUserId(npc.OwnerUserId),damage, 0), DMG_CLUB, -1, _, vecHit);
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

		BarrackBody_ThinkMove(npc.index, 200.0, "ACT_TEUTON_IDLE_NEW", "ACT_TEUTON_WALK_NEW");
	}
}

void BarrackTeuton_NPCDeath(int entity)
{
	BarrackTeuton npc = view_as<BarrackTeuton>(entity);
	BarrackBody_NPCDeath(npc.index);
}

public Action BarrackTeuton_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	BarrackTeuton npc = view_as<BarrackTeuton>(victim);
	
	float Maxhealth = ReturnEntityMaxHealth(npc.index) + 0.0;
	if((ReturnEntityMaxHealth(npc.index)/3) <= damage) // If teutonic takes a single instance of damage higher than 1/3 of his max hp he instead takes only 33% of his max hp as dmg and enrages
	{
		IgniteTargetEffect(npc.m_iWearable1);
		damage = Maxhealth/3;
		npc.Anger = true;
		switch(GetRandomInt(1, 2))
		{
			case 1:
			{
				NpcSpeechBubble(npc.index, "감히 나에게 손상을 입히다니!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 2:
			{
				NpcSpeechBubble(npc.index, "화나는군...", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
			case 3:
			{
				NpcSpeechBubble(npc.index, "대가를 치를 것이다!", 5, {255,255,255,255}, {0.0,0.0,60.0}, "");
			}
		}
	}

	return Plugin_Changed;
}

void ResetTeutonWeapon(BarrackTeuton npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 0:
		{
			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
			SetVariantString("0.8");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}