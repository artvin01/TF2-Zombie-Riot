#pragma semicolon 1
#pragma newdecls required

#define TOWER_SIZE_BARRACKS "0.65"

methodmap BarrackBuilding < BarrackBody
{
	public BarrackBuilding(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BarrackBuilding npc = view_as<BarrackBuilding>(BarrackBody(client, vecPos, vecAng, "5000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 60.0));
		
		npc.m_iWearable1 = npc.EquipItemSeperate("partyhat", "models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		i_NpcInternalId[npc.index] = BARRACKS_BUILDING;
		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_Think, BarrackBuilding_ClotThink);

		npc.m_flSpeed = 0.0;
		
		return npc;
	}
}

public void BarrackBuilding_ClotThink(int iNPC)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(iNPC);
	float GameTime = GetGameTime(iNPC);
	int client = GetClientOfUserId(npc.OwnerUserId);
	if(BarrackBody_ThinkStart(npc.index, GameTime, 60.0))
	{
		if(i_AttacksTillMegahit[iNPC] >= 255)
		{
			if(i_AttacksTillMegahit[iNPC] <= 299)
			{
				i_AttacksTillMegahit[iNPC] = 300;
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			}
			float MinimumDistance = 100.0;

			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_MURDERHOLES)
				MinimumDistance = 0.0;

			float MaximumDistance = 600.0;
			MaximumDistance = Barracks_UnitExtraRangeCalc(npc.index, client, MaximumDistance, true);
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);

			int ValidEnemyToTarget = GetClosestTarget(npc.index, true, MaximumDistance, true, _, _ ,pos, true,_,_,true, MinimumDistance);
			if(IsValidEnemy(npc.index, ValidEnemyToTarget))
			{
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					float ArrowDamage = 3000.0;
					int ArrowCount = 5;
					float AttackDelay = 5.0;
					if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_STRONGHOLDS)
					{
						AttackDelay *= 0.77; //attack 33% faster
					}
					Barracks_UnitExtraDamageCalc(npc.index, client ,ArrowDamage, 1);
					npc.m_flNextMeleeAttack = GameTime + AttackDelay;
					npc.m_flDoingSpecial = ArrowDamage;
					npc.m_iOverlordComboAttack = ArrowCount;
				}
				if(npc.m_iOverlordComboAttack > 0)
				{
					float vecTarget[3];
					float projectile_speed = 1200.0;
					
					if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_BALLISTICS)
					{
						vecTarget = PredictSubjectPositionForProjectiles(npc, ValidEnemyToTarget, projectile_speed, 40.0);
						if(!Can_I_See_Enemy_Only(npc.index, ValidEnemyToTarget)) //cant see enemy in the predicted position, we will instead just attack normally
						{
							vecTarget = WorldSpaceCenter(ValidEnemyToTarget);
						}
					}
					else
					{
						vecTarget = WorldSpaceCenter(ValidEnemyToTarget);
					}


					EmitSoundToAll("weapons/bow_shoot.wav", npc.index, _, 70, _, 0.9, 100);

					//npc.m_flDoingSpecial is damage, see above.
					int arrow = npc.FireArrow(vecTarget, npc.m_flDoingSpecial, projectile_speed,_,_, 40.0, GetClientOfUserId(npc.OwnerUserId));
					npc.m_iOverlordComboAttack -= 1;

					if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_CRENELLATIONS)
					{
						DataPack pack;
						CreateDataTimer(0.1, PerfectHomingShot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(EntIndexToEntRef(arrow)); //projectile
						pack.WriteCell(EntIndexToEntRef(ValidEnemyToTarget));		//victim to annihilate :)
					}
				}
			}
		}
		else
		{
			int alpha = i_AttacksTillMegahit[iNPC];
			if(alpha > 255)
			{
				alpha = 255;
			}
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
		}
	}
}

void BarrackBuilding_NPCDeath(int entity)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(entity);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_Think, BarrackBuilding_ClotThink);
}
