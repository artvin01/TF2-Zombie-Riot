static char g_HurtSounds[][] =
{
	"cof/addiction/hurt1.mp3",
	"cof/addiction/hurt2.mp3"
};

static char g_PassiveSounds[][] =
{
	"cof/addiction/passive1.mp3",
	"cof/addiction/passive2.mp3"
};

static char g_ThunderSounds[][] =
{
	"cof/addiction/thunder_attack1.wav",
	"cof/addiction/thunder_attack2.wav",
	"cof/addiction/thunder_attack3.wav"
};

methodmap Addicition < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		this.m_flNextIdleSound = GetGameTime() + 3.5;
		EmitSoundToAll(g_PassiveSounds[GetRandomInt(0, sizeof(g_PassiveSounds) - 1)], this.index);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime())
			return;
		
		this.m_flNextHurtSound = GetGameTime() + 2.0;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll("cof/addiction/death.mp3");
		EmitSoundToAll("cof/addiction/death.mp3");
	}
	public void PlayIntroSound()
	{
		EmitSoundToAll("cof/simon/Intro.mp3");
		EmitSoundToAll("cof/simon/Intro.mp3");
	}
	public void PlayAttackSound()
	{
		this.m_flNextHurtSound = GetGameTime() + 2.0;
		EmitSoundToAll("cof/simon/attack.mp3", this.index, SNDCHAN_VOICE);
	}
	public void PlayLightningSound()
	{
		EmitSoundToAll(g_ThunderSounds[GetRandomInt(0, sizeof(g_ThunderSounds) - 1)], this.index);
		EmitSoundToAll(g_ThunderSounds[GetRandomInt(0, sizeof(g_ThunderSounds) - 1)]);
	}
	
	public Addicition(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Addicition npc = view_as<Addicition>(CClotBody(vecPos, vecAng, "models/zombie_riot/aom/david_monster.mdl", "1.0", data[0] == 'f' ? "250000" : "10000", ally));
		i_NpcInternalId[npc.index] = THEADDICTION;
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_SPAWN");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Addicition_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Addicition_ClotThink);
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_flSpeed = 150.0;
		npc.m_iTarget = -1;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flRangedSpecialDelay = 1.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = GetGameTime() + 2.0;
		npc.m_flNextRangedSpecialAttack = npc.m_flReloadDelay + 18.0;
		npc.m_bLostHalfHealth = false;
		npc.m_bDissapearOnDeath = true;
		
		if(data[0])
			npc.SetHalfLifeStats();
		
		return npc;
	}
	
	public void SetHalfLifeStats()
	{
		this.m_bLostHalfHealth = true;
		this.m_flSpeed = 275.0;
	}
	public void SetActivity(const char[] animation)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			//this.m_bisWalking = false;
			this.StartActivity(activity);
		}
	}
}

public void Addicition_ClotThink(int iNPC)
{
	Addicition npc = view_as<Addicition>(iNPC);
	
	float gameTime = GetGameTime();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	npc.PlayIdleSound();
	
	if(npc.m_bLostHalfHealth)
	{
		npc.m_flMeleeArmor = 1.0 - Pow(0.98, float(Zombies_Currently_Still_Ongoing));
		npc.m_flRangedArmor = npc.m_flMeleeArmor;
	}
	else if(GetEntProp(npc.index, Prop_Data, "m_iHealth") < GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2)
	{
		npc.SetHalfLifeStats();
	}
	
	if(npc.m_flRangedSpecialDelay > 1.0)
	{
		if(npc.m_flRangedSpecialDelay < gameTime)
		{
			npc.m_flRangedSpecialDelay = 1.0;
			
			float vecMe[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", vecMe); 
			vecMe[2] += 45;
			
			makeexplosion(npc.index, npc.index, vecMe, "", 2000, 1000, 1000.0);
			
			npc.m_flRangedSpecialDelay = 0.0;
			npc.PlayLightningSound();
		}
		
		return;
	}
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 2))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, 600.0, DMG_CLUB);
					}
				}
				delete swingTrace;
			}
		}
		
		return;
	}
	
	if(npc.m_flReloadDelay > gameTime)
	{
		if(npc.m_bPathing)
		{
			PF_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		return;
	}
	
	if(npc.m_flRangedSpecialDelay == 1.0)
		npc.m_flRangedSpecialDelay = 0.0;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	if(npc.m_iTarget > 0)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			//Stop chasing dead target.
			npc.m_iTarget = 0;
			npc.m_flGetClosestTargetTime = 0.0;
		}
		else
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			
			float distance = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			if(distance < 40000.0 && npc.m_flNextMeleeAttack < gameTime)
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.SetActivity("ACT_IDLE");
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayAttackSound();
				
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flReloadDelay = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else if(distance < 200000.0 && npc.m_flNextRangedSpecialAttack < gameTime)
			{
				npc.SetActivity("ACT_LIGHTNING");
				
				npc.m_flRangedSpecialDelay = gameTime + 3.0;
				npc.m_flReloadDelay = gameTime + 5.0;
				npc.m_flNextRangedSpecialAttack = gameTime + 30.0;
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else
			{
				npc.SetActivity(npc.m_bLostHalfHealth ? "ACT_RUN_HALFLIFE" : "ACT_RUN");
			}
		}
	}
	
	if(npc.m_bPathing)
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
	}
	
	npc.m_flGetClosestTargetTime = 0.0;
	npc.SetActivity("ACT_IDLE");
}

public Action Addicition_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(damage < 9999999.0 && view_as<Addicition>(victim).m_flRangedSpecialDelay == 1.0)
		return Plugin_Handled;
	
	view_as<Addicition>(victim).PlayHurtSound();
	return Plugin_Continue;
}

public void Addicition_NPCDeath(int entity)
{
	Addicition npc = view_as<Addicition>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Addicition_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Addicition_ClotThink);
	
	PF_StopPathing(npc.index);
	npc.m_bPathing = false;
	
	npc.PlayDeathSound();
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/aom/david_monster.mdl");
		DispatchKeyValue(entity_death, "skin", "0");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(1.0, Timer_RemoveEntityOverlord, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
	}
}
