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
	"weapons/halloween_boss/knight_axe_hit.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav"
};

void SeaBrandguider_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nethersea Brandguider");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_netherseabrandguider");
	strcopy(data.Icon, sizeof(data.Icon), "ds_brandguide");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return SeaBrandguider(vecPos, vecAng, team, data);
}

methodmap SeaBrandguider < CSeaBody
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
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);	
	}
	
	public SeaBrandguider(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool carrier = data[0] == 'R';
		bool elite = !carrier && data[0];

		SeaBrandguider npc = view_as<SeaBrandguider>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", elite ? "7200" : "5700", ally, false));
		// 19000 x 0.3
		// 24000 x 0.3

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.SetElite(elite, carrier);
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_SEABORN_WALK_TOOL_1");
		KillFeed_SetKillIcon(npc.index, "freedom_staff");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = SeaBrandguider_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeaBrandguider_OnTakeDamage;
		func_NPCThink[npc.index] = SeaBrandguider_ClotThink;
		
		npc.m_flSpeed = 200.0;	// 0.8 x 250
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.Anger = false;
		
		SetEntityRenderColor(npc.index, 155, 155, 255, 255);

		if(carrier)
		{
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			vecMe[2] += 100.0;

			npc.m_iWearable1 = ParticleEffectAt(vecMe, "powerup_icon_king", -1.0);
			SetParent(npc.index, npc.m_iWearable1);
		}

		npc.m_iWearable2 = npc.EquipItem("partyhat", elite ? "models/workshop/player/items/all_class/hwn2021_goalkeeper/hwn2021_goalkeeper_medic.mdl" : "models/workshop/player/items/all_class/hwn2021_goalkeeper_style2/hwn2021_goalkeeper_style2_medic.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_tw_eagle/c_tw_eagle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		return npc;
	}
}

public void SeaBrandguider_ClotThink(int iNPC)
{
	SeaBrandguider npc = view_as<SeaBrandguider>(iNPC);

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

		if(!npc.Anger)
		{
			int maxhealth = ReturnEntityMaxHealth(npc.index);
			int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

			if(health < (maxhealth / 2))
			{
				npc.Anger = true;
				npc.m_flMeleeArmor = 0.25;
			}
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, npc.Anger);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
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
						float attack = npc.m_bElite ? 135.0 : 120.0;
						// 800 x 0.15
						// 900 x 0.15

						if(ShouldNpcDealBonusDamage(target))
							attack *= 2.5;
						
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, attack, DMG_CLUB);
					}
				}

				delete swingTrace;
			}
		}

		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(distance < 10000.0)
			{
				int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					npc.PlayMeleeSound();

					npc.AddGesture("ACT_SEABORN_ATTACK_TOOL_1");	// TODO: Set anim
					npc.m_flAttackHappens = gameTime + 0.45;
					//npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flHeadshotCooldown = gameTime + 1.0;
				}
			}

			if(npc.Anger)
			{
				if(!NpcStats_IsEnemySilenced(npc.index))
				{
					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vecTarget);
					SeaFounder_SpawnNethersea(vecTarget);
				}

				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public Action SeaBrandguider_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;
	
	SeaBrandguider npc = view_as<SeaBrandguider>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void SeaBrandguider_NPCDeath(int entity)
{
	SeaBrandguider npc = view_as<SeaBrandguider>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	float pos[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

	if(npc.m_bCarrier)
		Remains_SpawnDrop(pos, Buff_Brandguider);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}
