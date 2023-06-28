#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSounds[][] =
{
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

methodmap LastKnight < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public LastKnight(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		LastKnight npc = view_as<LastKnight>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.35", "125000", ally, false));
		// 125000 x 1.0

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = LASTKNIGHT;
		i_NpcWeight[npc.index] = 5;
		npc.SetActivity("ACT_PRINCE_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SDKHook(npc.index, SDKHook_Think, LastKnight_ClotThink);
		
		npc.m_flSpeed = 150.0;	// 0.6 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iPhase = 0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/bak_teufort_knight/bak_teufort_knight_demo.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		return npc;
	}
	property int m_iPhase
	{
		public get()
		{
			return this.m_iMedkitAnnoyance;
		}
		public set(int value)
		{
			this.m_iMedkitAnnoyance = value;
		}
	}
}

public void LastKnight_ClotThink(int iNPC)
{
	LastKnight npc = view_as<LastKnight>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, 500.0);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(npc.m_iTarget < 1)
		{
			// No nearby targets, kill the ocean
			npc.m_iTarget = GetClosestAlly(npc.index, 100.0);
		}

		// Won't attack runners
		if(npc.m_iTarget < 1 || i_NpcInternalId[npc.m_iTarget] == CITIZEN_RUNNER)
			npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(CitizenRunner_WasKilled())
	{
		npc.m_flMeleeArmor = 0.4;
		npc.m_flRangedArmor = 0.4;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
		if(npc.m_flAttackHappens)
		{
			npc.FaceTowards(vecTarget, 15000.0);
			
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;

				int team = GetEntProp(npc.index, Prop_Send, "m_iTeamNum");
				SetEntProp(npc.index, Prop_Send, "m_iTeamNum", 0);

				Handle swingTrace;
				bool result = npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _);

				SetEntProp(npc.index, Prop_Send, "m_iTeamNum", team);

				if(result)
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, ShouldNpcDealBonusDamage(target) ? 2000.0 : 1000.0, DMG_CLUB);
						npc.PlayMeleeHitSound();
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 10000.0)
			{
				//int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//if(IsValidEnemy(npc.index, target, true))
				{
					npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 1.75;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_CUSTOM_ATTACK_LUCIAN");
					npc.m_flAttackHappens = gameTime + 0.45;
					npc.m_flDoingAnimation = gameTime + 0.55;
				}
			}
		}
		
		if(npc.m_flDoingAnimation > gameTime)
		{
			npc.StopPathing();
		}
		else
		{
			if(distance < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else 
			{
				NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			}

			npc.StartPathing();
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action LastKnight_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	LastKnight npc = view_as<LastKnight>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void LastKnight_NPCDeath(int entity)
{
	LastKnight npc = view_as<LastKnight>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(i_NpcInternalId[npc.index] == LastKnight_CARRIER)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		Remains_SpawnDrop(pos, Buff_Reefbreaker);
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, LastKnight_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);

	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}
