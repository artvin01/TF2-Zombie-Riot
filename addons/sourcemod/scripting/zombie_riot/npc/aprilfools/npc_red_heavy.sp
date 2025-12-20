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
	"vo/taunts/heavy_taunts18.mp3",
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
static int NPCId;
static bool NoSoundLoop = false;

void RedHeavy_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Red Heavy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_red_heavy");
	strcopy(data.Icon, sizeof(data.Icon), "redheavysoul");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
	NoSoundLoop = false;
}

static void ClotPrecache()
{
	PrecacheSoundCustom("#zombiesurvival/aprilfools/finale.mp3");
}
stock int RedHeavy_ID()
{
	return NPCId;
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RedHeavy(vecPos, vecAng, team);
}

methodmap RedHeavy < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		NpcSpeechBubble(this.index, "I think you need more men!", 5, {255,0,0,255}, {0.0,0.0,80.0}, "");
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public RedHeavy(float vecPos[3], float vecAng[3], int ally)
	{
		RedHeavy npc = view_as<RedHeavy>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "1000000000000", ally));
		
		i_NpcWeight[npc.index] = 2;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "fists");
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);

		func_NPCDeath[npc.index] = RedHeavy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RedHeavy_OnTakeDamage;
		func_NPCThink[npc.index] = RedHeavy_ClotThink;
		
		npc.m_flSpeed = 330.0;
		npc.m_bThisEntityIgnored = true;
		npc.m_bScalesWithWaves = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		AddNpcToAliveList(npc.index, 1);
		NoSoundLoop = false;
		
		npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 1.0;

		SetEntityRenderColor(npc.index, 254, 0, 0, 255);

		return npc;
	}
}

public void RedHeavy_ClotThink(int iNPC)
{
	RedHeavy npc = view_as<RedHeavy>(iNPC);

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
	if(npc.m_flAbilityOrAttack0)
	{
		npc.m_flAbilityOrAttack0 = gameTime + 10.0;
		for(int Ally; Ally < MAXENTITIES; Ally ++)
		{
			if(IsValidAlly(npc.index, Ally))
			{
				float DurationGive = 999999.0;
				ApplyStatusEffect(npc.index, Ally, "Ally Empowerment", DurationGive);
			}
		}
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_bScalesWithWaves)
	{
		bool stop_thinking;
		if(!NoSoundLoop)
		{
			int count = 0;
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(!IsValidEntity(other))
				{
					continue;
				}

				if((YellowHeavyNpcID(other) || PurpleHeavyNpcID(other) || OrangeHeavyNpcID(other) || GreenHeavyNpcID(other) || CyanHeavyNpcID(other) || BlueHeavyNpcID(other)))
				{
					count++;
					npc.m_iTarget = other;
					if(count > 5)
					{
						MusicEnum music;
						strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/aprilfools/finale.mp3");
						music.Time = 555;
						music.Volume = 2.0;
						music.Custom = true;
						strcopy(music.Name, sizeof(music.Name), "Finale");
						strcopy(music.Artist, sizeof(music.Artist), "Toby Fox");
						Music_SetRaidMusic(music,_,true);
						RaidModeTime = GetGameTime(npc.index) + 999.0;
						RaidModeTime += 10.0;
						NoSoundLoop = true;
						stop_thinking = true;
						CPrintToChatAll("{snow}우린 7개의 헤비의 영혼이야. 이 전투에서 널 도울게.");
						CPrintToChatAll("{crimson}아무래도 네 동료가 더 많이 필요하겠어!!");
						break;//we found all!
					}
				}
			}
		}
		if(stop_thinking)
			return;
	}

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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 5.0, DMG_CLUB);
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

void RedHeavy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		RedHeavy npc = view_as<RedHeavy>(victim);
		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			if (attacker <= MaxClients && attacker > 0 && TeutonType[attacker] != TEUTON_NONE)
			{	
				return;
			}
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
}

void RedHeavy_NPCDeath(int entity)
{
	RedHeavy npc = view_as<RedHeavy>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
		
}