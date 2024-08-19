#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/diamond_back_01.wav",
	"weapons/diamond_back_02.wav",
	"weapons/diamond_back_03.wav"
};

static const char g_RangedReloadSounds[][] =
{
	"weapons/revolver_worldreload.wav"
};

void Huirgrajo_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Huirgrajo");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_huirgrajo");
	strcopy(data.Icon, sizeof(data.Icon), "teleporter");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_IberiaExpiAlliance;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Huirgrajo(client, vecPos, vecAng, ally);
}

methodmap Huirgrajo < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public Huirgrajo(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Huirgrajo npc = view_as<Huirgrajo>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "0.9", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		float gameTime = GetGameTime(npc.index);
		npc.m_flNextMeleeAttack = gameTime + 9.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flCharge_delay = gameTime + 3.0;
		npc.Anger = false;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		static const int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_snub_nose/c_snub_nose.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/hwn2019_avian_amante/hwn2019_avian_amante.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn_spy_priest/hwn_spy_priest_spy.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/sept2014_lady_killer/sept2014_lady_killer.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/spy/short2014_invisible_ishikawa/short2014_invisible_ishikawa.mdl", _, skin);
		
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	Huirgrajo npc = view_as<Huirgrajo>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flReloadDelay > gameTime)
	{
		npc.m_flSpeed = 0.0;
	}
	else
	{
		npc.m_flSpeed = npc.Anger ? 160.0 : 260.0;
	}

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index, .EntityLocation = );
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	int ally = npc.m_iTargetAlly;

	int walk = npc.m_iTarget;
	if(i_TargetToWalkTo[npc.index] != -1 && !IsValidEnemy(npc.index, walk))
		i_TargetToWalkTo[npc.index] = -1;
	
	if(IsValidAlly(npc.index, ally))
	{
		if(i_TargetToWalkTo[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
		{
			walk = GetClosestTarget(npc.index, .EntityLocation = ally);
			npc.m_iTarget = walk;
			npc.m_flGetClosestTargetTime = gameTime + 1.0;
		}
	}
	else
	{
		walk = target
		i_TargetToWalkTo[npc.index] = i_Target[npc.index];
	}

	npc.m_bAllowBackWalking = target != walk;

	if(walk > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(walk, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(npc.m_flReloadDelay > gameTime)
		{
			npc.StopPathing();
			npc.SetActivity("ACT_MP_CROUCH_SECONDARY");
		}
		else if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, walk, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);

			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}
		else
		{
			NPC_SetGoalEntity(npc.index, walk);
			
			npc.StartPathing();
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
		}

		npc.StartPathing();
	}

	if(target > 0)
	{
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 100.0;
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						if(target <= MaxClients && (Armor_Charge[target] < 0 || TF2_IsPlayerInCondition(target, TFCond_Milked) || TF2_IsPlayerInCondition(target, TFCond_Jarated)))
						{
							damage *= Rogue_Paradox_RedMoon() ? 60.0 : 6.0;
						}

						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
					}
				}

				delete swingTrace;
			}
		}

		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flNextMeleeAttack = gameTime + 0.55;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	Huirgrajo npc = view_as<Huirgrajo>(entity);
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