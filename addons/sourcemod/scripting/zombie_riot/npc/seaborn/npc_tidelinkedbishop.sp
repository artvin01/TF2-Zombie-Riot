#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] =
{
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bow_shoot.wav"
};

methodmap TidelinkedBishop < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public TidelinkedBishop(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		TidelinkedBishop npc = view_as<TidelinkedBishop>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.6", "40000", ally, false, true));
		// 40000 x 1.0

		SetVariantInt(6);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcInternalId[npc.index] = TIDELINKED_BISHOP;
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_1");
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SDKHook(npc.index, SDKHook_Think, TidelinkedBishop_ClotThink);
		
		npc.m_flSpeed = 200.0;//100.0;	// 0.4 x 250
		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 0.5;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_iTargetAlly = -1;

		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/medic/medic_blighted_beak.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);

		npc.m_iTargetAlly = -1;

		return npc;
	}
}

public void TidelinkedBishop_ClotThink(int iNPC)
{
	TidelinkedBishop npc = view_as<TidelinkedBishop>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTargetAlly == -1)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 5;
		
		int entity = Npc_Create(TIDELINKED_ARCHON, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
		if(entity > MaxClients)
		{
			npc.m_iTargetAlly = EntIndexToEntRef(entity);
			view_as<CClotBody>(entity).m_iTargetAlly = EntIndexToEntRef(npc.index);
			view_as<CClotBody>(entity).m_bThisNpcIsABoss = npc.m_bThisNpcIsABoss;

			Zombies_Currently_Still_Ongoing++;
			SetEntProp(entity, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(entity, Prop_Data, "m_iMaxHealth", maxhealth);
			
			fl_Extra_MeleeArmor[entity] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entity] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[entity] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[entity] = fl_Extra_Damage[npc.index];
			
			if(npc.m_iWearable3 == -1)
			{
				npc.m_iWearable3 = ConnectWithBeam(npc.m_iWearable1, entity, 0, 55, 255, 5.0, 5.0, 0.0, "sprites/laserbeam.vmt");
			}
		}
	}

	if(b_NpcIsInvulnerable[npc.index])
	{
		int entity = EntRefToEntIndex(npc.m_iTargetAlly);
		if(entity == INVALID_ENT_REFERENCE || b_NpcIsInvulnerable[entity])
		{
			SDKHooks_TakeDamage(npc.index, 0, 0, 9999999.9, DMG_SLASH);
			return;
		}

		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

		health += maxhealth / 200;	// 20 seconds
		if(health > maxhealth)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", maxhealth);

			b_NpcIsInvulnerable[npc.index] = false;
			npc.m_bisWalking = true;
			npc.SetActivity("ACT_SEABORN_WALK_TOOL_1");
		}
		else
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		}
		return;
	}

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget, true))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, true);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 900.0);
				npc.FaceTowards(vecTarget, 15000.0);

				npc.PlayMeleeSound();
				int entity = npc.FireArrow(vecTarget, 600.0, 900.0, "models/weapons/w_bugbait.mdl");
				// 600 x 1.0

				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);
					
					SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(entity, 100, 100, 255, 255);
					
					vecTarget = WorldSpaceCenter(entity);
					f_ArrowTrailParticle[entity] = ParticleEffectAt(vecTarget, "rockettrail_bubbles", 3.0);
					SetParent(entity, f_ArrowTrailParticle[entity]);
					f_ArrowTrailParticle[entity] = EntIndexToEntRef(f_ArrowTrailParticle[entity]);
				}
			}

			npc.m_flSpeed = 25.0;
		}
		else
		{
			npc.m_flSpeed = 100.0;	// 0.4 x 250
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 1102500.0)	// 1.5 * 700
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target, true))
				{
					npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 4.5;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_SEABORN_ATTACK_TOOL_2");
					npc.m_flAttackHappens = gameTime + 0.25;
					//npc.m_flDoingAnimation = gameTime + 0.65;
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

public void TidelinkedBishop_DownedThink(int entity)
{
	TidelinkedBishop npc = view_as<TidelinkedBishop>(entity);
	npc.SetActivity("ACT_MUDROCK_RAGE");
	npc.SetPlaybackRate(0.5);
	SDKUnhook(entity, SDKHook_Think, TidelinkedBishop_DownedThink);
}

void TidelinkedBishop_OnTakeDamage(int victim, int attacker, float damage)
{
	if(attacker > 0)
	{
		TidelinkedBishop npc = view_as<TidelinkedBishop>(victim);

		if(!b_NpcIsInvulnerable[npc.index] && (damage * 2.0) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			npc.m_iTarget = 0;
			npc.m_bisWalking = false;
			b_NpcIsInvulnerable[npc.index] = true;
			npc.StopPathing();

			SDKHook(victim, SDKHook_Think, TidelinkedBishop_DownedThink);
		}
		
		if(b_NpcIsInvulnerable[npc.index])
			damage = 0.0;
	}
}

void TidelinkedBishop_NPCDeath(int entity)
{
	TidelinkedBishop npc = view_as<TidelinkedBishop>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_Think, TidelinkedBishop_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
