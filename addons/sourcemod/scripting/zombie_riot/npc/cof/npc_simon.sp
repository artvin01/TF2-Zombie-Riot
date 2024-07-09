#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] =
{
	"cof/simon/hurt1.mp3",
	"cof/simon/hurt2.mp3",
	"cof/simon/hurt3.mp3"
};

static bool SimonHasDied;
static int SimonRagdollRef = INVALID_ENT_REFERENCE;

void Simon_MapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Book Simon");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_simon");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_libertylauncher");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_COF;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	PrecacheModel("models/zombie_riot/cof/booksimon.mdl");
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSoundCustom(g_HurtSounds[i]);	   }

	PrecacheSoundCustom("cof/simon/passive.mp3");
	PrecacheSoundCustom("cof/simon/death7.mp3");
	PrecacheSoundCustom("cof/simon/intro.mp3");
	PrecacheSoundCustom("cof/simon/reload.mp3");
	PrecacheSoundCustom("cof/simon/shoot.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Simon(client, vecPos, vecAng, ally, data);
}
methodmap Simon < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		this.m_flNextIdleSound = GetGameTime(this.index) + 18.0;
		EmitCustomToAll("cof/simon/passive.mp3", this.index);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("cof/simon/death7.mp3", _, _, _, _, 2.0);
	}
	public void PlayIntroSound()
	{
		EmitCustomToAll("cof/simon/intro.mp3", _, _, _, _, 2.0);
	}
	public void PlayReloadSound()
	{
		EmitCustomToAll("cof/simon/reload.mp3", this.index, _, _, _, 2.0);
	}
	public void PlayShootSound()
	{
		EmitCustomToAll("cof/simon/shoot.mp3", this.index);
	}
	
	public Simon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		bool newSimon = data[0] == 's';
		
		if(data[0])
			SimonHasDied = false;
		
		if(SimonHasDied)
			return view_as<Simon>(INVALID_ENT_REFERENCE);
		
		Simon npc = view_as<Simon>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/booksimon.mdl", "1.15", data[0] == 'f' ? "300000" : "200000", ally, false, false, true));
		
		i_NpcWeight[npc.index] = 3;
		
		int body = EntRefToEntIndex(SimonRagdollRef);
		if(body > MaxClients)
			RemoveEntity(body);
		
		npc.m_iState = -1;
		npc.SetActivity("ACT_SPAWN");
		npc.PlayIntroSound();
		ExcuteRelay("zr_simonspawn");
		
		func_NPCDeath[npc.index] = Simon_NPCDeath;
		func_NPCThink[npc.index] = Simon_ClotThink;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Simon_ClotDamagedPost);

		npc.m_bThisNpcIsABoss = true;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bInjured = false;
		npc.m_iOverlordComboAttack = 0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 7;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 1.4;
		
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		npc.m_bLostHalfHealth = (!newSimon && view_as<bool>(data[0]));

		Citizen_MiniBossSpawn();
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
	property bool m_bInjured
	{
		public get()		{ return view_as<bool>(this.m_iMedkitAnnoyance); }
		public set(bool value) 	{ this.m_iMedkitAnnoyance = value ? 1 : 0; }
	}
	property bool m_bHasKilled
	{
		public get()		{ return view_as<bool>(this.m_iOverlordComboAttack); }
		public set(bool value) 	{ this.m_iOverlordComboAttack = 1; }
	}
	property bool m_bRetreating
	{
		public get()		{ return this.m_iOverlordComboAttack > 1; }
		public set(bool value) 	{ this.m_iOverlordComboAttack = 2; }
	}
	property bool m_bRanAway
	{
		public get()		{ return this.m_iOverlordComboAttack == 3; }
		public set(bool value) 	{ this.m_iOverlordComboAttack = 3; }
	}
}

public void Simon_ClotThink(int iNPC)
{
	Simon npc = view_as<Simon>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	npc.PlayIdleSound();
	
	if(!npc.m_bRetreating && npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.25;
		
		int target = GetClosestAlly(npc.index, 40000.0);
		if(target)
		{
			CClotBody ally = view_as<CClotBody>(target);
			
			ally.m_flRangedArmor = 0.7;
			
			if(npc.m_bLostHalfHealth)
			{
				if(!ally.m_bLostHalfHealth)
				{
					ally.m_bLostHalfHealth = true;
					ally.m_flSpeed *= 1.15;
				}
			}
		}
	}
	
	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iTarget <= MaxClients)
			npc.m_bHasKilled = true;
		
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
		int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		if(!npc.m_bRetreating && npc.m_bHasKilled && health < (maxhealth / 2))
		{
			if(Waves_GetRound() != (npc.m_bLostHalfHealth ? 59 : 54))
				npc.m_bRetreating = true;
		}
		
		if(!npc.m_bInjured && health < (maxhealth / 5))
			npc.m_bInjured = true;
		
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	
	int behavior = npc.m_bRetreating ? 5 : -1;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						if(target <= MaxClients)
							SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, 1500.0, DMG_CLUB, -1, _, vecHit);	
						Custom_Knockback(npc.index, target, 500.0);
						npc.m_iAttacksTillReload++;
					}
				}
				delete swingTrace;
			}
		}
		
		behavior = 0;
	}
	
	if(behavior == -1 || behavior == 5)
	{
		if(npc.m_iTarget > 0)	// We have a target
		{
			float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			
			float distance = GetVectorDistance(vecTarget, vecPos, true);
			if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)	// Close at any time: Melee
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.AddGesture("ACT_MELEE");
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flReloadDelay = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + (behavior == 5 ? 2.0 : 1.0);
				
				behavior = 0;
			}
			else if(npc.m_flReloadDelay > gameTime)	// Reloading
			{
				behavior = 0;
			}
			else if(behavior == 5)	// Escaping
			{
			}
			else if(distance < 200000.0)	// In shooting range
			{
				if(npc.m_flNextRangedAttack < gameTime)	// Not in attack cooldown
				{
					if(npc.m_iAttacksTillReload > 0)	// Has ammo
					{
						int Enemy_I_See;
				
						Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						//Target close enough to hit
						if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See)
						{
							behavior = 0;
							npc.SetActivity("ACT_IDLE");
							
							npc.FaceTowards(vecTarget, 15000.0);
							
							npc.AddGesture("ACT_SHOOT");
							
							npc.m_flNextRangedAttack = gameTime + 0.8;
							
							npc.m_iAttacksTillReload--;
							
							PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1000.0,_, vecTarget);
							npc.FireRocket(vecTarget, 140.0, 1000.0, "models/weapons/w_bullet.mdl", 2.0);
							
							npc.PlayShootSound();
						}
						else	// Something in the way, move closer
						{
							behavior = 1;
						}
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
			else if(npc.m_iAttacksTillReload < 0)	// Take the time to reload
			{
				//Only if empty.
				behavior = 4;
			}
			else	// Sprint Time
			{
				behavior = 2;
			}
		}
		else if(npc.m_flReloadDelay > gameTime)	// Reloading...
		{
			behavior = 0;
		}
		else if(behavior == 5)	// Escaping
		{
		}
		else if(npc.m_iAttacksTillReload < 7)	// Nobody here..?
		{
			behavior = 4;
		}
		else	// I'm bored, let's get out of here
		{
			behavior = 5;
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
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
		}
		case 1:	// Move After the Player
		{
			npc.SetActivity(npc.m_bInjured ? "ACT_RUNHURT" : "ACT_RUN");
			npc.m_flSpeed = npc.m_bInjured ? 200.0 : 220.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Sprint After the Player
		{
			npc.SetActivity(npc.m_bInjured ? "ACT_RUNHURT" : "ACT_RUNFASTER");
			npc.m_flSpeed = npc.m_bInjured ? 220.0 : 240.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Retreat
		{
			npc.SetActivity(npc.m_bInjured ? "ACT_RUNHIDE" : "ACT_RUNFASTER");
			npc.m_flSpeed = npc.m_bInjured ? 400.0 : 450.0;
			
			if(!npc.m_flRangedSpecialDelay)	// Reload anyways timer
				npc.m_flRangedSpecialDelay = gameTime + 3.0;
			
			float vBackoffPos[3]; BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
			NPC_SetGoalVector(npc.index, vBackoffPos);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Reload
		{
			npc.AddGesture("ACT_RELOAD");
			npc.m_flSpeed = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flReloadDelay = gameTime + 3.6;
			npc.m_iAttacksTillReload = 7;
			
			if(npc.m_bPathing)
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
			}
			
			npc.PlayReloadSound();
		}
		case 5:	// Escape
		{
			npc.SetActivity(npc.m_bInjured ? "ACT_RUNHIDE" : "ACT_RUNFASTER");
			npc.m_flSpeed = npc.m_bInjured ? 275.0 : 375.0;
			
			int ClosestTarget;
			float TargetLocation[3];
			float TargetDistance;
			float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
			for(int entitycount; entitycount<i_MaxcountSpawners; entitycount++) //Faster check for spawners
			{
				int entity = i_ObjectsSpawners[entitycount];
				if(IsValidEntity(entity) && entity != 0)
				{
					if(!GetEntProp(entity, Prop_Data, "m_bDisabled") && GetTeam(entity) != 2)
					{
						GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
						float distance = GetVectorDistance( vecPos, TargetLocation, true); 
						if (TargetDistance) 
						{
							if( distance < TargetDistance ) 
							{
								ClosestTarget = entity; 
								TargetDistance = distance;		  
							}
						} 
						else 
						{
							ClosestTarget = entity; 
							TargetDistance = distance;
						}
					}
				}
			}
			
			if(ClosestTarget)
			{
				if(TargetDistance < 5000.0)
				{
					npc.m_bRanAway = true;
					npc.m_fCreditsOnKill = 0.0;
					SDKHooks_TakeDamage(npc.index, 0, 0, 99999999.9);
					return;
				}
				
				GetEntPropVector( ClosestTarget, Prop_Data, "m_vecAbsOrigin", TargetLocation ); 
				NPC_SetGoalVector(npc.index, TargetLocation);
				
				if(!npc.m_bPathing)
					npc.StartPathing();
			}
			else
			{
				if(!npc.m_flRangedSpecialDelay)
				{
					npc.m_flRangedSpecialDelay = gameTime + 10.0;
				}
				else if(npc.m_flRangedSpecialDelay < gameTime)
				{
					npc.m_bRanAway = true;
					npc.m_fCreditsOnKill = 0.0;
					SDKHooks_TakeDamage(npc.index, 0, 0, 99999999.9);
					ExcuteRelay("zr_simonescaped");
					return;
				}
				
				if(npc.m_iTarget)
				{
					float vBackoffPos[3]; BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
					NPC_SetGoalVector(npc.index, vBackoffPos);
					
					if(!npc.m_bPathing)
						npc.StartPathing();
				}
			}
		}
	}
}

public void Simon_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(damage > 100.0)
	{
		Simon npc = view_as<Simon>(victim);
		npc.PlayHurtSound();
	}
}

public void Simon_NPCDeath(int entity)
{
	Simon npc = view_as<Simon>(entity);
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Simon_ClotDamagedPost);
	
	NPC_StopPathing(npc.index);
	npc.m_bPathing = false;
	
	if(!npc.m_bRanAway)
	{
		npc.PlayDeathSound();
		SimonHasDied = true;
		
		int entity_death = CreateEntityByName("prop_dynamic_override");
		if(IsValidEntity(entity_death))
		{
			float pos[3], angles[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angles);
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			
			TeleportEntity(entity_death, pos, angles, NULL_VECTOR);
			
	//		GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));
			DispatchKeyValue(entity_death, "model", "models/zombie_riot/cof/booksimon.mdl");
			DispatchKeyValue(entity_death, "skin", "0");
			
			DispatchSpawn(entity_death);
			
			SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 1.15); 
			SetEntityCollisionGroup(entity_death, 2);
			SetVariantString("death");
			AcceptEntityInput(entity_death, "SetAnimation");
			
			SimonRagdollRef = EntIndexToEntRef(entity_death);
		}
	}

	Citizen_MiniBossDeath(entity);
}
