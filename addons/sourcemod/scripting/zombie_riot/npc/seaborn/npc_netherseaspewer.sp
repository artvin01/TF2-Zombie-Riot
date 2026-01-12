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

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

void SeaSpewer_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nethersea Spewer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_netherseaspewer");
	strcopy(data.Icon, sizeof(data.Icon), "ds_spewer");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeaSpewer(vecPos, vecAng, team, data);
}

methodmap SeaSpewer < CSeaBody
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
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeaSpewer(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaSpewer npc = view_as<SeaSpewer>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", elite ? "1500" : "1200", ally, false));
		// 4000 x 0.3
		// 5000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.SetElite(elite, carrier);
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_3");
		KillFeed_SetKillIcon(npc.index, "huntsman_flyingburn");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeaSpewer_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeaSpewer_OnTakeDamage;
		func_NPCThink[npc.index] = SeaSpewer_ClotThink;
		
		npc.m_flSpeed = 75.0;	// 0.3 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_precision", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		static const char Styles[][] = { "", "_s1", "_s2", "_s3" };
		int style = elite ? ((GetURandomInt() % 3) + 1) : 0;

		char buffer[PLATFORM_MAX_PATH];
		FormatEx(buffer, sizeof(buffer), "models/weapons/c_models/c_skullbat/c_skullbat%s.mdl", Styles[style]);

		npc.m_iWearable2 = npc.EquipItem("weapon_bone", buffer);
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("partyhat", "models/workshop/player/items/soldier/hwn2020_calamitous_cauldron/hwn2020_calamitous_cauldron.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable3, 155, elite ? 0 : 200, elite ? 0 : 100, 255);

		return npc;
	}
}

public void SeaSpewer_ClotThink(int iNPC)
{
	SeaSpewer npc = view_as<SeaSpewer>(iNPC);

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
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3];
		float distance = GetVectorDistance(vecTarget, vecMe, true);		
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		npc.StartPathing();

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			int enemy[3];
			int count = GetAnyTargets(npc, vecMe, enemy, sizeof(enemy));

			if(count)
			{
				npc.m_flNextMeleeAttack = gameTime + 2.0;
				npc.m_flSpeed = 32.5;

				for(int i; i < count; i++)
				{
					WorldSpaceCenter(enemy[i], vecTarget);

					PredictSubjectPositionForProjectiles(npc, enemy[i], 1200.0, _,vecTarget);

					int entity = npc.FireArrow(vecTarget, npc.m_bElite ? 240.0 : 195.0, 1200.0, "models/weapons/w_bugbait.mdl");
					// 650 * 0.3
					// 800 * 0.3

					i_NervousImpairmentArrowAmount[entity] = npc.m_bCarrier ? 6 : (npc.m_bElite ? 5 : 4);
					// 650 * 0.02 * 0.3
					// 800 * 0.02 * 0.3
					// 650 * 0.03 * 0.3
					
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
			}
			else
			{
				npc.m_flSpeed = 75.0;
			}
		}
		else
		{
			npc.m_flSpeed = 32.5;
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static int GetAnyTargets(SeaSpewer npc, const float vecMe[3], int[] enemy, int count)
{
	int team = GetTeam(npc.index);
//	float gameTime = GetGameTime();
	float vecTarget[3];
	int found;
	bool silenced = NpcStats_IsEnemySilenced(npc.index);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(!view_as<CClotBody>(client).m_bThisEntityIgnored && IsClientInGame(client) && GetClientTeam(client) != team && IsEntityAlive(client) && Can_I_See_Enemy_Only(npc.index, client))
		{
			if(silenced || !SeaFounder_TouchingNethersea(client))
			{
				WorldSpaceCenter(client, vecTarget );
				if(GetVectorDistance(vecTarget, vecMe, true) > 48400.0)	// 1.1 * 200
					continue;
			}

			AddToList(client, found, enemy, count);
		}
	}

	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(IsValidEntity(entity) && entity != npc.index)
		{
			if(!view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity) && GetTeam(entity) != team && Can_I_See_Enemy_Only(npc.index, entity))
			{
				if(silenced || !SeaFounder_TouchingNethersea(entity))
				{
					WorldSpaceCenter(entity, vecTarget);
					if(GetVectorDistance(vecTarget, vecMe, true) > 48400.0)	// 1.1 * 200
						continue;
				}

				AddToList(entity, found, enemy, count);
			}
		}
	}

	if(team != 2 && !RaidbossIgnoreBuildingsLogic(1))
	{
		for(int a; a < i_MaxcountBuilding; a++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsBuilding[a]);
			if(entity != INVALID_ENT_REFERENCE && entity != npc.index)
			{
				if(IsValidEnemy(npc.index, entity) && Can_I_See_Enemy_Only(npc.index, entity))
				{
					if(silenced || !SeaFounder_TouchingNethersea(entity))
					{
						WorldSpaceCenter(entity, vecTarget);
						if(GetVectorDistance(vecTarget, vecMe, true) > 48400.0)	// 1.1 * 200
							continue;
					}

					AddToList(entity, found, enemy, count);
				}
			}
		}
	}

	return found;
}

static void AddToList(int data, int &pos, int[] list, int count)
{
	if(pos >= count)
	{
		pos = count;
		list[GetURandomInt() % count] = data;
	}
	else
	{
		list[pos++] = data;
	}
}

public Action SeaSpewer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaSpewer npc = view_as<SeaSpewer>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaSpewer_NPCDeath(int entity)
{
	SeaSpewer npc = view_as<SeaSpewer>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	if(npc.m_bCarrier)
	{
		float pos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		Remains_SpawnDrop(pos, Buff_Spewer);
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
