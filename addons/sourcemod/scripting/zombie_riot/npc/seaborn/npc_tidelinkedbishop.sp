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

void TidelinkedBishop_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Tidelinked Bishop");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_tidelinkedbishop");
	strcopy(data.Icon, sizeof(data.Icon), "ds_bishop");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TidelinkedBishop(vecPos, vecAng, team);
}

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
	
	public TidelinkedBishop(float vecPos[3], float vecAng[3], int ally)
	{
		TidelinkedBishop npc = view_as<TidelinkedBishop>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.6", "40000", ally, false, true));
		// 40000 x 1.0

		SetVariantInt(6);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_1");
		KillFeed_SetKillIcon(npc.index, "huntsman");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;

		func_NPCDeath[npc.index] = TidelinkedBishop_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = TidelinkedBishop_OnTakeDamage;
		func_NPCThink[npc.index] = TidelinkedBishop_ClotThink;
		
		npc.m_flSpeed = 200.0;//100.0;	// 0.4 x 250
		npc.m_flMeleeArmor = 1.25;
		npc.m_flRangedArmor = 0.5;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/medic/medic_blighted_beak.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);

		i_TargetAlly[npc.index] = -1;

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

	if(i_TargetAlly[npc.index] == -1)
	{
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int maxhealth = ReturnEntityMaxHealth(npc.index) / 5;
		
		int entity = NPC_CreateByName("npc_tidelinkedarchon", -1, pos, ang, GetTeam(npc.index));
		if(entity > MaxClients)
		{
			i_TargetAlly[npc.index] = EntIndexToEntRef(entity);
			i_TargetAlly[entity] = EntIndexToEntRef(npc.index);
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
		int entity = EntRefToEntIndex(i_TargetAlly[npc.index]);
		if(entity == INVALID_ENT_REFERENCE || !IsValidEntity(entity) ||  b_NpcIsInvulnerable[entity])
		{
			SmiteNpcToDeath(npc.index);
			return;
		}

		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = ReturnEntityMaxHealth(npc.index);

		health += maxhealth / 200;	// 20 seconds
		if(health >= (maxhealth / 2))
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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec );
		float distance = GetVectorDistance(vecTarget, npc_vec, true);
		
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 900.0, _, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);

				npc.PlayMeleeSound();
				int entity = npc.FireArrow(vecTarget, 600.0, 900.0, "models/weapons/w_bugbait.mdl");
				// 600 x 1.0

				if(entity != -1)
				{
					if(IsValidEntity(f_ArrowTrailParticle[entity]))
						RemoveEntity(f_ArrowTrailParticle[entity]);
					
					SetEntityRenderColor(entity, 100, 100, 255, 255);
					
					WorldSpaceCenter(entity, vecTarget);
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
					//npc.m_flDoingAnimation = gameTime + 0.95;
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
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget, _,_,vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
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
	npc.SetActivity("ACT_TrueStrength_RAGE");
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
	}
}

void TidelinkedBishop_NPCDeath(int entity)
{
	TidelinkedBishop npc = view_as<TidelinkedBishop>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
