#pragma semicolon 1
#pragma newdecls required

#define TOWER_SIZE_BARRACKS "0.65"

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

public void BarrackBuildingOnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Barracks Building");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_barrack_building");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Ally;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return BarrackBuilding(client, vecPos, vecAng);
}

methodmap BarrackBuilding < BarrackBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
	}
	public BarrackBuilding(int client, float vecPos[3], float vecAng[3])
	{
		BarrackBuilding npc = view_as<BarrackBuilding>(BarrackBody(client, vecPos, vecAng, "4000", TOWER_MODEL, _, TOWER_SIZE_BARRACKS, 80.0,"models/pickups/pickup_powerup_resistance.mdl", .NpcTypeLogicdo = 1));
		npc.m_iWearable1 = npc.EquipItemSeperate("models/props_manor/clocktower_01.mdl");
		SetVariantString("0.1");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}

		i_NpcWeight[npc.index] = 999;
		i_NpcIsABuilding[npc.index] = true;
		b_NoKnockbackFromSources[npc.index] = true;
		npc.m_bDissapearOnDeath = true;
		func_NPCOnTakeDamage[npc.index] = BarrackBody_OnTakeDamage;
		func_NPCDeath[npc.index] = BarrackBuilding_NPCDeath;
		func_NPCThink[npc.index] = BarrackBuilding_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BarrackBuilding_OnTakeDamagePost);

		npc.m_flSpeed = 0.0;
		
		return npc;
	}
}

public void BarrackBuilding_ClotThink(int iNPC)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(iNPC);
	float GameTime = GetGameTime(iNPC);
	int client = GetClientOfUserId(npc.OwnerUserId);
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
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
			float MinimumDistance = 60.0;

			if(i_NormalBarracks_HexBarracksUpgrades[client] & ZR_BARRACKS_UPGRADES_MURDERHOLES)
				MinimumDistance = 0.0;

			float MaximumDistance = 400.0;
			MaximumDistance = Barracks_UnitExtraRangeCalc(npc.index, client, MaximumDistance, true);
			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);

			int ValidEnemyToTarget = GetClosestTarget(npc.index, true, MaximumDistance, true, _, _ ,pos, true,_,_,true, MinimumDistance);
			if(IsValidEnemy(npc.index, ValidEnemyToTarget))
			{
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					float ArrowDamage = 4000.0;
					int ArrowCount = 3;
					float AttackDelay = 7.0;
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
						PredictSubjectPositionForProjectiles(npc, ValidEnemyToTarget, projectile_speed, 40.0, vecTarget);
						if(!Can_I_See_Enemy_Only(npc.index, ValidEnemyToTarget)) //cant see enemy in the predicted position, we will instead just attack normally
						{
							WorldSpaceCenter(ValidEnemyToTarget, vecTarget );
						}
					}
					else
					{
						WorldSpaceCenter(ValidEnemyToTarget, vecTarget );
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
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			if(alpha > 255)
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
				alpha = 255;
			}
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
		}
	}
}

void BarrackBuilding_NPCDeath(int entity)
{
	BarrackBuilding npc = view_as<BarrackBuilding>(entity);
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	BarrackBody_NPCDeath(npc.index);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, BarrackBuilding_OnTakeDamagePost);
	SDKUnhook(npc.index, SDKHook_Think, BarrackBuilding_ClotThink);
}



public void BarrackBuilding_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	//Valid attackers only.
	if(attacker <= 0)
		return;
		
	BarrackBuilding npc = view_as<BarrackBuilding>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}