#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3"
};

static const char g_HurtSounds[][] =
{
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3"
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav"
};

void SeabornHeavy_Precache()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Seaborn Heavy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_heavy");
	strcopy(data.Icon, sizeof(data.Icon), "ds_heavy");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SeabornHeavy(vecPos, vecAng, team);
}

methodmap SeabornHeavy < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public SeabornHeavy(float vecPos[3], float vecAng[3], int ally)
	{
		SeabornHeavy npc = view_as<SeabornHeavy>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "15000", ally));
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "fists");
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = SeabornHeavy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = SeabornHeavy_OnTakeDamage;
		func_NPCThink[npc.index] = SeabornHeavy_ClotThink;
		
		npc.m_flSpeed = 230.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flMeleeArmor = 0.9;
		npc.m_flRangedArmor = 0.9;
		
		SetEntityRenderColor(npc.index, 100, 100, 255, 255);

		return npc;
	}
}

public void SeabornHeavy_ClotThink(int iNPC)
{
	SeabornHeavy npc = view_as<SeabornHeavy>(iNPC);

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

	if(npc.m_iTarget && !IsValidEnemy(npc.index, npc.m_iTarget))
		npc.m_iTarget = 0;
	
	if(!npc.m_iTarget || npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
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
					if(target > 0)
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, 50.0, DMG_CLUB);
						Elemental_AddNervousDamage(target, npc.index, 10);
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

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");

				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.45;
			}
		}
	}
	else
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

void SeabornHeavy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		SeabornHeavy npc = view_as<SeabornHeavy>(victim);
		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			if (attacker <= MaxClients && attacker > 0 && TeutonType[attacker] != TEUTON_NONE)
			{	
				return;
			}
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;

			if(damagetype & DMG_CLUB)
			{
				if(!NpcStats_IsEnemySilenced(npc.index))
				{
					npc.m_flMeleeArmor -= 0.05;
					if(npc.m_flMeleeArmor < 0.05)
						npc.m_flMeleeArmor = 0.05;
				}
				
				npc.m_flRangedArmor += 0.05;
				if(npc.m_flRangedArmor > 1.5)
					npc.m_flRangedArmor = 1.5;
			}
			else if(!(damagetype & DMG_TRUEDAMAGE))
			{
				npc.m_flRangedArmor -= 0.05;
				if(npc.m_flRangedArmor < 0.05)
				{
					npc.m_flRangedArmor = 0.05;
				}
				npc.m_flMeleeArmor += 0.05;
				if(npc.m_flMeleeArmor > 1.5)
				{
					npc.m_flMeleeArmor = 1.5;
				}
			}
		}
	}
}

void SeabornHeavy_NPCDeath(int entity)
{
	SeabornHeavy npc = view_as<SeabornHeavy>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}
