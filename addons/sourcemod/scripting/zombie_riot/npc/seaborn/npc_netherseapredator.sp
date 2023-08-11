#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav"
};

methodmap SeaPredator < CClotBody
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeaPredator(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaPredator npc = view_as<SeaPredator>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", carrier ? "1350" : (elite ? "1500" : "1200"), ally, false));
		// 4000 x 0.3
		// 5000 x 0.3
		// 4500 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = carrier ? SEAPREDATOR_CARRIER : (elite ? SEAPREDATOR_ALT : SEAPREDATOR);
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_2");
		KillFeed_SetKillIcon(npc.index, "fists");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		
		SDKHook(npc.index, SDKHook_Think, SeaPredator_ClotThink);
		
		npc.m_flSpeed = 250.0;	// 1.0 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_reflect", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/pyro/hw2013_visage_of_the_crow/hw2013_visage_of_the_crow.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 200, elite ? 0 : 255, elite ? 0 : 155, 255);

		return npc;
	}
}

public void SeaPredator_ClotThink(int iNPC)
{
	SeaPredator npc = view_as<SeaPredator>(iNPC);

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
		if(npc.Anger)
		{
			if(!SeaFounder_TouchingNethersea(npc.index))
			{
				npc.Anger = false;
				Change_Npc_Collision(npc.index, VIPBuilding_Active() ? num_ShouldCollideEnemyTD : num_ShouldCollideEnemy);
			}
		}
		else if(SeaFounder_TouchingNethersea(npc.index))
		{
			npc.Anger = true;
			Change_Npc_Collision(npc.index, VIPBuilding_Active() ? num_ShouldCollideEnemyTDIgnoreBuilding : num_ShouldCollideEnemyIngoreBuilding);
		}

		npc.m_iTarget = GetClosestTarget(npc.index, npc.Anger);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);		
		
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
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						float attack = i_NpcInternalId[npc.index] == SEAPREDATOR_ALT ? 82.5 : 67.5;
						// 450 x 0.15
						// 550 x 0.15

						if(ShouldNpcDealBonusDamage(target))
							attack *= 2.5;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, attack, DMG_CLUB);

						SeaSlider_AddNeuralDamage(target, npc.index, RoundToCeil(attack * 0.1));
						// 450 x 0.1 x 0.15
						// 550 x 0.1 x 0.15
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)
		{
			int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				npc.m_flNextMeleeAttack = gameTime + 1.5;

				npc.AddGesture("ACT_SEABORN_FIRST_ATTACK_1");	// TODO: Set anim
				npc.m_flAttackHappens = gameTime + 0.45;
				//npc.m_flDoingAnimation = gameTime + 1.2;
				npc.m_flHeadshotCooldown = gameTime + 1.0;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action SeaPredator_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaPredator npc = view_as<SeaPredator>(victim);
	float gameTime = GetGameTime(npc.index);

	static int Pity;
	if(Pity < 30 && npc.m_flNextDelayTime <= (gameTime + DEFAULT_UPDATE_DELAY_FLOAT) && !NpcStats_IsEnemySilenced(npc.index) && (GetURandomInt() % (i_NpcInternalId[npc.index] == SEAPREDATOR_ALT ? 5 : 3)))
	{
		if(attacker <= MaxClients && attacker > 0)
		{
			float chargerPos[3];
			GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
			if(b_BoundingBoxVariant[victim] == 1)
			{
				chargerPos[2] += 120.0;
			}
			else
			{
				chargerPos[2] += 82.0;
			}
			TE_ParticleInt(g_particleMissText, chargerPos);
			TE_SendToClient(attacker);
		}
	
		damage = 0.0;
		Pity += i_NpcInternalId[npc.index] == SEAPREDATOR_ALT ? 1 : 2;
	}
	else if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		Pity = 0;
	}
	return Plugin_Changed;
}

void SeaPredator_NPCDeath(int entity)
{
	SeaPredator npc = view_as<SeaPredator>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(i_NpcInternalId[npc.index] == SEAPREDATOR_CARRIER)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		Remains_SpawnDrop(pos, Buff_Predator);
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, SeaPredator_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}
