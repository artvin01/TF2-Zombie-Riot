#pragma semicolon 1
#pragma newdecls required

static const char g_MeleeHitSounds[][] =
{
	"weapons/saxxy_turntogold_05.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing3.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing1.wav",
};
static const char g_CoughRandom[][] = {
	"ambient/voices/cough1.wav",
	"ambient/voices/cough2.wav",
	"ambient/voices/cough3.wav",
	"ambient/voices/cough4.wav",
};


static const char g_BobSuperMeleeCharge_Hit[][] =
{
	"player/taunt_yeti_standee_break.wav",
};
static int NPCId;

void BobFollower_Setup()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob the First");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_follower");
	strcopy(data.Icon, sizeof(data.Icon), "combine_gold");
	for (int i = 0; i < (sizeof(g_CoughRandom)); i++) { PrecacheSound(g_CoughRandom[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_BobSuperMeleeCharge_Hit)); i++) { PrecacheSound(g_BobSuperMeleeCharge_Hit[i]); }

	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	NPCId = NPC_Add(data);
}

stock int BobFollower_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return BobFollower(vecPos, vecAng, ally);
}

methodmap BobFollower < CClotBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayCoughSound() 
	{
		EmitSoundToAll(g_CoughRandom[GetRandomInt(0, sizeof(g_CoughRandom) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound(int who) 
	{
		EmitSoundToAll("npc/strider/striderx_die1.wav", who, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayBobMeleePostHit()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	
	public BobFollower(float vecPos[3], float vecAng[3],int ally)
	{
		BobFollower npc = view_as<BobFollower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, true, true));
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_RUN_BOB");
		KillFeed_SetKillIcon(npc.index, "eyelander");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 0);

		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
		npc.m_bScalesWithWaves = true;
		
		npc.m_flSpeed = 310.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;

		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		IgniteTargetEffect(npc.m_iWearable1);

		if(npc.m_bScalesWithWaves)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 125);
		}

		npc.m_flNextIdleSound = GetGameTime(npc.index) + 60.0;

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	BobFollower npc = view_as<BobFollower>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;


	//Do stuff if the being is here
	if(npc.m_bScalesWithWaves)
	{
		bool stop_thinking;
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != -1 && i_NpcInternalId[other] == OmegaRaidNpcID() && IsEntityAlive(other))
			{
					npc.m_iTarget = other;
					i_RaidGrantExtra[npc.index] = 2;
					npc.StopPathing();
					
					stop_thinking = true;
					break;
			}
		}
		if(stop_thinking)
			return;
	}

	int target = npc.m_iTarget;
	int ally = npc.m_iTargetWalkTo;

	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
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

				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target,_,_,_,2))
				{
					target = TR_GetEntityIndex(swingTrace);
					if(target > 0)
					{
						float damage = 5000.0;
						if(npc.m_bScalesWithWaves)
						{
							damage = 80.0;
						}
						if(ShouldNpcDealBonusDamage(target))
							damage *= 5.0;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB|DMG_PREVENT_PHYSICS_FORCE);
					}
				}

				delete swingTrace;
			}
		}
		else if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, target);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flGetClosestTargetTime = gameTime + 1.0;

				npc.AddGesture("ACT_MELEE_BOB");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flNextMeleeAttack = gameTime + 0.65;
			}
		}

		npc.SetActivity("ACT_RUN_BOB");
	}
	else
	{
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget > 25000.0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
				npc.SetActivity("ACT_RUN_BOB");
				return;
			}
		}

		npc.StopPathing();
		npc.SetActivity("ACT_IDLE_BOBPRIME");
	}
}

static void ClotDeath(int entity)
{
	BobFollower npc = view_as<BobFollower>(entity);

	if(IsValidEntity(npc.index))
		RemoveEntity(npc.index);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}