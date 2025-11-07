#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav",
};

static int NPCId;

void FinalHunter_Setup()
{
	PrecacheSoundArray(g_MeleeAttackSounds);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Wildingen Hitman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_finalhunter");
	strcopy(data.Icon, sizeof(data.Icon), "sniper_headshot");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

int FinalHunter_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return FinalHunter(vecPos, vecAng, team, data);
}

methodmap FinalHunter < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}

	public FinalHunter(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool final = StrContains(data, "final_wave") != -1;
		if(final)
		{
			
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == FinalHunter_ID() && IsEntityAlive(other))
				{
					Is_a_Medic[other] = false;
					return view_as<FinalHunter>(-1);
				}
			}
		}
		FinalHunter npc = view_as<FinalHunter>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.175", "50000", ally));
		
		i_NpcWeight[npc.index] = 2;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");

		KillFeed_SetKillIcon(npc.index, "freedom_staff");

		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 345.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		npc.m_bStaticNPC = true;
		AddNpcToAliveList(npc.index, 1);
		Is_a_Medic[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/angsty_hood/angsty_hood_sniper.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/sniper/spr17_down_under_duster/spr17_down_under_duster.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_final_frontiersman/invasion_final_frontiersman.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/sniper/sf14_kanga_kickers/sf14_kanga_kickers.mdl");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	FinalHunter npc = view_as<FinalHunter>(iNPC);
	
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

	if(npc.m_bStaticNPC)
	{
		if(!Is_a_Medic[npc.index])
		{
			npc.m_bStaticNPC = false;
			b_NpcIsInvulnerable[npc.index] = false;

			//remove from static.
			RemoveFromNpcAliveList(npc.index);
			AddNpcToAliveList(npc.index, 0);

			float pos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			SeaFounder_SpawnNethersea(pos);
			npc.m_iBleedType = BLEEDTYPE_SEABORN;

			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime() + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
			Waves_Progress();

			CPrintToChatAll("{darkred}Wildingen Hitman{default}: {black}It's inside me");

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == GogglesFollower_ID() && IsEntityAlive(other))
				{
					view_as<GogglesFollower>(other).Speech("What the fuck!");
					CPrintToChatAll("{darkblue}Waldch{default}: What the fuck!");
					break;
				}
			}

			npc.m_flNextThinkTime = 0.0;
			return;
		}

		if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target, true, true))
			i_Target[npc.index] = -1;
		
		if(i_Target[npc.index] == -1 || (npc.m_flGetClosestTargetTime < gameTime && i_NpcInternalId[target] != GogglesFollower_ID()))
		{
			target = -1;

			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != -1 && i_NpcInternalId[other] == GogglesFollower_ID() && IsEntityAlive(other))
				{
					target = other;
					break;
				}
			}

			if(target == -1)
				target = GetClosestTarget(npc.index);
			
			npc.m_iTarget = target;
			npc.m_flGetClosestTargetTime = gameTime + 4.0;
		}
	}
	else
	{
		if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
			i_Target[npc.index] = -1;
		
		if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
		{
			target = GetClosestTarget(npc.index);
			npc.m_iTarget = target;
			npc.m_flGetClosestTargetTime = gameTime + 1.0;
		}
	}

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				if(i_NpcInternalId[target] == GogglesFollower_ID())
				{
					npc.PlayMeleeHitSound();

					int maxhealth = ReturnEntityMaxHealth(target);

					int health = GetEntProp(target, Prop_Data, "m_iHealth");
					if(health > maxhealth)
						health = maxhealth;
					float ScalingDo = MultiGlobalHealthBoss;
					if(ScalingDo <= 0.75)
						ScalingDo = 0.75;

					health -= (maxhealth / RoundToNearest(60.0 / ScalingDo) / 4);

					if(health < 1)
					{
						SmiteNpcToDeath(target);

						RaidBossActive = EntIndexToEntRef(npc.index);
						RaidModeTime = GetGameTime() + 9000.0;
						RaidModeScaling = 0.0;
						RaidAllowsBuildings = true;

						EmitSoundToAll("mvm/mvm_warning.wav");
						fl_Extra_Speed[npc.index] = 1.5;
						fl_Extra_Damage[npc.index] = 5.0;
					}
					else
					{
						if(health < (maxhealth / 10))
						{
							EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", target, SNDCHAN_STATIC, 120, _, 1.0);
							EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav", target, SNDCHAN_STATIC, 120, _, 1.0);
						}

						SetEntProp(target, Prop_Data, "m_iHealth", health);
						Custom_Knockback(npc.index, target, 1000.0, true); 
					}
				}
				else
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
					if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
					{
						target = TR_GetEntityIndex(swingTrace);
						if(target > 0)
						{
							float damage = 1000.0;
							if(ShouldNpcDealBonusDamage(target))
								damage *= 50.0;
							
							if(NpcStats_IberiaIsEnemyMarked(target))
								damage *= 100.0;

							npc.PlayMeleeHitSound();
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
							if(target > MaxClients || (!dieingstate[target] && IsPlayerAlive(target)))
								ApplyStatusEffect(npc.index, target, "Marked", 30.0);
							
							Custom_Knockback(npc.index, target, 1000.0, true); 
						}
					}

					delete swingTrace;
				}
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			if((IsEntityAlive(target) && i_NpcInternalId[target] == GogglesFollower_ID()))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 2.45;
			}
			else
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 2.95;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
	}
}

static void ClotDeath(int entity)
{
	FinalHunter npc = view_as<FinalHunter>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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

}
