#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bow_shoot.wav"
};

void GogglesFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Blue Goggles");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_goggles_follower");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3])
{
	return GogglesFollower(client, vecPos, vecAng);
}

methodmap GogglesFollower < CClotBody
{
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	
	public GogglesFollower(int client, float vecPos[3], float vecAng[3])
	{
		GogglesFollower npc = view_as<GogglesFollower>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "10000", TFTeam_Red, true, false));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_MP_STAND_ITEM2");
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 320.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		/*
			Cosmetics
		*/

		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_ice", npc.index, "head", {0.0,0.0,0.0});
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/spr18_antarctic_eyewear/spr18_antarctic_eyewear_scout.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_bow_thief/c_bow_thief.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/sum19_wagga_wagga_wear/sum19_wagga_wagga_wear.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/short2014_sniper_cargo_pants/short2014_sniper_cargo_pants.mdl");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 65, 65, 255, 255);

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	GogglesFollower npc = view_as<GogglesFollower>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;
	int chaos = Rogue_GetChaosLevel();
	b_NpcIsTeamkiller[npc.index] = chaos == 4;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
	{
		i_Target[npc.index] = -1;
		npc.m_flAttackHappens = 0.0;
	}
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index, _, 2000.0, true, _, _, _, true, 150.0, true, true);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		switch(chaos)
		{
			case 3:
			{
				ally = GetClosestAllyPlayer(npc.index);
				npc.m_iTargetWalkTo = ally;
			}
			case 4:
			{
				ally = -1;
				npc.m_iTargetWalkTo = -1;
			}
			default:
			{
				ally = GetClosestAllyPlayerGreg(npc.index);
				if(!ally)
				{
					ally = GetClosestAllyPlayer(npc.index);
					npc.m_iTargetWalkTo = ally;
				}
			}
		}
	}

	float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
	bool crouching;

	if(ally > 0)
	{
		if(b_BobsCuringHand[ally] && b_BobsCuringHand_Revived[ally] >= 20 && TeutonType[ally] == TEUTON_NONE && dieingstate[ally] > 0 
			&& GetEntPropEnt(ally, Prop_Data, "m_hVehicle") == -1 && !b_LeftForDead[ally])
		{
			//walk to client.
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget < 5000.0)
			{
				//slowly revive
				ReviveClientFromOrToEntity(npc.m_iTargetWalkTo, npc.index, 1);
				
				npc.StopPathing();
				crouching = true;
			}
			else
			{
				// Run to ally target, ignore enemies
				npc.SetActivity("ACT_MP_RUN_ITEM2");
				NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
				npc.StartPathing();
				target = -1;
			}
		}
		else
		{
			// Walk to ally target
			NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
			npc.StartPathing();
		}
	}
	else
	{
		// No ally target
		npc.StopPathing();
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float distance = GetVectorDistance(vecTarget, vecSelf, true);

		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM2");

				if(chaos < 4 && !NpcStats_IsEnemySilenced(npc.index))
					PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1500.0, _, vecTarget);
				
				npc.FaceTowards(vecTarget, 30000.0);

				float damage = 10000.0;
				switch(chaos)
				{
					case 2:
					{
						damage = GetRandomFloat(5000.0, 15000.0);
					}
					case 3:
					{
						damage += GetRandomInt(-1, 1) * 5000.0;
					}
					case 4:
					{
						damage += GetRandomInt(-2, 2) * 4999.0;
					}
				}
				
				npc.PlayMeleeSound();
				npc.FireArrow(vecTarget, damage, 1500.0);

				vecTarget[2] += 40.0;
				npc.FireArrow(vecTarget, damage, 1500.0);

				vecTarget[2] -= 80.0;
				npc.FireArrow(vecTarget, damage, 1500.0);
			}
			else
			{
				npc.FaceTowards(vecTarget, 3000.0);
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			npc.FaceTowards(vecTarget, 30000.0);
			npc.m_flGetClosestTargetTime = gameTime + 1.45;
			npc.m_flAttackHappens = gameTime + 1.35;
			npc.m_flNextMeleeAttack = gameTime + 3.85;
		}
	}
	else
	{
		npc.m_flAttackHappens = 0.0;
	}

	if(npc.m_bPathing)
	{
		npc.m_bAllowBackWalking = true;

		if(npc.m_flAttackHappens)
		{
			npc.m_flSpeed = 85.0;
			npc.SetActivity("ACT_MP_DEPLOYED_ITEM2");
		}
		else
		{
			npc.m_flSpeed = 320.0;
			npc.SetActivity("ACT_MP_RUN_ITEM2");
		}
	}
	else
	{
		npc.m_flSpeed = 1.0;
		npc.m_bAllowBackWalking = false;

		if(crouching)
		{
			if(npc.m_flAttackHappens)
			{
				npc.SetActivity("ACT_MP_CROUCH_DEPLOYED_IDLE_ITEM2");
			}
			else
			{
				npc.SetActivity("ACT_MP_CROUCH_ITEM2");
			}
		}
		else if(npc.m_flAttackHappens)
		{
			npc.SetActivity("ACT_MP_DEPLOYED_IDLE_ITEM2");
		}
		else
		{
			npc.SetActivity("ACT_MP_STAND_ITEM2");
		}
	}
}

static void ClotDeath(int entity)
{
	GogglesFollower npc = view_as<GogglesFollower>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}