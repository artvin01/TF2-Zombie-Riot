methodmap Doctor < CClotBody
{
	public Doctor(int client, float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		Doctor npc = view_as<Doctor>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/sawrunner_1.mdl", "1.5", data[0] == 'f' ? "200000" : "30000", ally, false, true));
		i_NpcInternalId[npc.index] = THEDOCTOR;
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_SPAWN");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_Think, Doctor_ClotThink);
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_flSpeed = 250.0;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 5;
		npc.m_flReloadDelay = GetGameTime() + 2.0;
		
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		npc.m_bLostHalfHealth = view_as<bool>(data[0]);
		return npc;
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

public void Doctor_ClotThink(int iNPC)
{
	Doctor npc = view_as<Doctor>(iNPC);
	
	float gameTime = GetGameTime();
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		if(npc.m_bLostHalfHealth)
		{
			npc.m_flNextRangedSpecialAttack = gameTime + 0.25;
		}
		else
		{
			npc.m_flNextRangedSpecialAttack = gameTime + 2.0;
		}
		
		int target = GetClosestAlly(npc.index, 40000.0);
		if(target)
		{
			CClotBody ally = view_as<CClotBody>(target);
			if(!ally.m_bLostHalfHealth)
			{
				ally.m_bLostHalfHealth = true;
				ally.m_flSpeed *= 1.15;
			}
		}
	}
	
	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	int behavior = npc.m_flReloadDelay > gameTime ? 0 : -1;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.m_iAttacksTillReload++;
			
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
						SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB);
						Custom_Knockback(npc.index, target, 500.0);
						npc.m_iAttacksTillReload++;
					}
				}
				delete swingTrace;
			}
		}
		
		behavior = 0;
	}
	
	if(behavior == -1)
	{
		if(npc.m_iTarget > 0)	// We have a target
		{
			float vecPos[3]; vecPos = WorldSpaceCenter(npc.index);
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			
			float distance = GetVectorDistance(vecTarget, vecPos, true);
			if(distance < 40000.0 && npc.m_flNextMeleeAttack < gameTime)	// Close at any time: Melee
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.SetActivity("ACT_IDLE");
				
				npc.AddGesture("ACT_MELEE_1");
				
				npc.m_flAttackHappens = gameTime + 0.1;
				npc.m_flReloadDelay = gameTime + 0.4;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				
				behavior = 0;
			}
			else if(distance < 200000.0)	// In shooting range
			{
				if(npc.m_flNextRangedAttack < gameTime)	// Not in attack cooldown
				{
					if(npc.m_iAttacksTillReload > 0)	// Has ammo
					{
						vecPos[2] += 30.0;
						
						Handle trace = TR_TraceRayFilterEx(vecPos, vecTarget, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, BulletAndMeleeTrace, npc.index);
						
						if(TR_GetEntityIndex(trace) == npc.m_iTarget)
						{
							behavior = 0;
							npc.SetActivity("ACT_IDLE");
							
							npc.FaceTowards(vecTarget, 15000.0);
							
							npc.AddGesture("ACT_SPAWN");
							
							npc.m_flNextRangedAttack = gameTime + 0.8;
							npc.m_iAttacksTillReload--;
							
							vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1300.0);
							npc.FireRocket(vecTarget, 50.0, 1300.0, "models/weapons/w_bullet.mdl", 1.5);	
						}
						else	// Something in the way, move closer
						{
							behavior = 1;
						}
						
						delete trace;
					}
					else	// No ammo, retreat
					{
						behavior = 3;
					}
				}
				else	// In attack cooldown
				{
					behavior = 0;
					npc.SetActivity("ACT_IDLE");
				}
			}
			else if(npc.m_iAttacksTillReload < 5)	// Take the time to reload
			{
				behavior = 4;
			}
			else	// Sprint Time
			{
				behavior = 2;
			}
		}
		else if(npc.m_iAttacksTillReload < 5)	// Nobody here..?
		{
			behavior = 4;
		}
		else	// What do I do...
		{
			behavior = 0;
		}
	}
	
	// Reload anyways if we can't run
	if(npc.m_flRangedSpecialDelay && behavior == 3 && npc.m_flRangedSpecialDelay > gameTime)
		behavior = 4;
	
	switch(behavior)
	{
		case 0:	// Stand
		{
			// Activity handled above
			npc.m_flSpeed = 0.0;
			
			if(npc.m_bPathing)
			{
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
		}
		case 1:	// Move After the Player
		{
			npc.SetActivity("ACT_RUN");
			npc.m_flSpeed = 340.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Sprint After the Player
		{
			npc.SetActivity("ACT_RUN");
			npc.m_flSpeed = 460.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Retreat
		{
			npc.SetActivity("ACT_RUN");
			npc.m_flSpeed = 460.0;
			
			if(!npc.m_flRangedSpecialDelay)	// Reload anyways timer
				npc.m_flRangedSpecialDelay = gameTime + 4.0;
			
			float vBackoffPos[3]; vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
			PF_SetGoalVector(npc.index, vBackoffPos);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Reload
		{
			npc.SetActivity("ACT_SPAWN");
			npc.m_flSpeed = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flReloadDelay = gameTime + 5.0;
			npc.m_iAttacksTillReload = 5;
			
			if(npc.m_bPathing)
			{
				PF_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
		}
	}
}

public void Doctor_NPCDeath(int entity)
{
	Doctor npc = view_as<Doctor>(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, Doctor_ClotThink);
	
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
		
		HookSingleEntityOutput(entity_death, "OnAnimationDone", Doctor_PostDeath, true);
	}
}

public void Doctor_PostDeath(const char[] output, int caller, int activator, float delay)
{
	RemoveEntity(caller);
}
