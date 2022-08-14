methodmap Addicition < CClotBody
{
	public Addicition(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Addicition npc = view_as<Addicition>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/sawrunner_1.mdl", "1.5", "10000", ally, false, true));
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
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flRangedSpecialDelay = 1.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flReloadDelay = GetGameTime() + 2.0;
		npc.m_bLostHalfHealth = false;
		npc.m_bDissapearOnDeath = true;
		
		if(data[0])
			npc.SetHalfLifeStats();
		
		return npc;
	}
	
	public void SetHalfLifeStats()
	{
		this.m_bLostHalfHealth = true;
		this.m_flSpeed = 350.0;
	}
	public void SetActivity(const char[] animation)
	{
		int activity = this.LookupActivity(animation);
		if(activity > 0 && activity != this.m_iState)
		{
			this.m_iState = activity;
			this.m_bisWalking = false;
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
				
				npc.SetActivity("ACT_MELEE_ANGRY_MELEE");
				
				npc.AddGesture("ACT_MELEE_1");
				
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
				npc.SetActivity("ACT_SPAWN");
				
				npc.m_flRangedSpecialDelay = gameTime + 3.5;
				npc.m_flReloadDelay = gameTime + 4.25;
				npc.m_flNextRangedSpecialAttack = gameTime + 30.0;
				
				if(npc.m_bPathing)
				{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else
			{
				npc.SetActivity("ACT_RUN");
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
	
	return Plugin_Continue;
}

public void Addicition_NPCDeath(int entity)
{
	Addicition npc = view_as<Addicition>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Addicition_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Addicition_ClotThink);
	
	PF_StopPathing(npc.index);
	npc.m_bPathing = false;
	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3], angles[3];
		GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
		
		TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
		
//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
		DispatchKeyValue(entity_death, "model", "models/zombie_riot/cof/sawrunner_1.mdl");
		DispatchKeyValue(entity_death, "skin", "0");
		
		DispatchSpawn(entity_death);
		
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.5); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("death");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", Addicition_PostDeath, true);
	}
}

public void Addicition_PostDeath(const char[] output, int caller, int activator, float delay)
{
	RemoveEntity(caller);
}
