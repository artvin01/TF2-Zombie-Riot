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
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
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

methodmap SaintCarmen < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public SaintCarmen(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SaintCarmen npc = view_as<SaintCarmen>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "50000", ally, false));
		// 50000 x 1.0

		SetVariantInt(9);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		i_NpcInternalId[npc.index] = SAINTCARMEN;
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_DARIO_WALK");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		SDKHook(npc.index, SDKHook_Think, SaintCarmen_ClotThink);
		
		npc.m_flSpeed = 125.0;	// 0.5 x 250
		npc.m_flMeleeArmor = 0.5;
		npc.m_flRangedArmor = 1.25;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/w_pistol.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("anim_attachment_LH", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("3.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/short2014_deadhead/short2014_deadhead.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		return npc;
	}
}

public void SaintCarmen_ClotThink(int iNPC)
{
	SaintCarmen npc = view_as<SaintCarmen>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidAlly(npc.index, npc.m_iTarget) && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;

	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, 500.0, true);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(npc.m_iTarget < 1)
		{
			// No nearby targets, kill the ocean
			npc.m_iTarget = GetClosestAlly(npc.index, 10000.0);
		}

		if(npc.m_iTarget < 1)
			npc.m_iTarget = GetClosestTarget(npc.index);
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
						float damage = 300.0;
						if(ShouldNpcDealBonusDamage(target))
							damage *= 20.0;
						
						KillFeed_SetKillIcon(npc.index, "taunt_spy");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						// 1200 x 0.5 x 0.5

						npc.PlayMeleeHitSound();

						if(target <= MaxClients)
						{
							vecHit[0] = 0.0;
							vecHit[1] = 0.0;
							vecHit[2] = 1200.0;
							TeleportEntity(target, _, _, vecHit);
							EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);

							StartHealingTimer(target, 0.4, -300.0);

							npc.m_flNextMeleeAttack += 1.0;
							npc.m_flDoingAnimation = gameTime + 0.35;
						}
						else if(!b_NpcHasDied[target])
						{
							if(!b_CannotBeKnockedUp[target])
							{
								FreezeNpcInTime(target, 2.0);
								
								vecHit = WorldSpaceCenter(target);
								vecHit[2] += 250.0; //Jump up.
								PluginBot_Jump(target, vecHit);
								EmitSoundToAll("mvm/giant_soldier/giant_soldier_rocket_shoot.wav", target, _, 75, _, 0.60);

								npc.m_flNextMeleeAttack += 1.0;

								StartHealingTimer(target, 0.4, team == GetEntProp(target, Prop_Send, "m_iTeamNum") ? -3000.0 : -300.0);
							}
						}
					}
				}

				delete swingTrace;
			}
		}

		if(distance < 10000.0)
		{
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				//int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//if(IsValidEnemy(npc.index, target, true))
				{
					//npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_DARIO_ATTACK_1");
					npc.m_flAttackHappens = gameTime + 0.25;
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

void SaintCarmen_NPCDeath(int entity)
{
	SaintCarmen npc = view_as<SaintCarmen>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, SaintCarmen_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
