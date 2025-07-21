#pragma semicolon 1
#pragma newdecls required

static char g_HurtSounds[][] =
{
	"cof/purnell/hurt1.mp3",
	"cof/purnell/hurt2.mp3",
	"cof/purnell/hurt3.mp3",
	"cof/purnell/hurt4.mp3"
};

static char g_KillSounds[][] =
{
	"cof/purnell/kill1.mp3",
	"cof/purnell/kill2.mp3",
	"cof/purnell/kill3.mp3",
	"cof/purnell/kill4.mp3"
};



void SpecialDoctor_OnMapStart()
{
	
	for (int i = 0; i < (sizeof(g_HurtSounds));	   i++) { PrecacheSoundCustom(g_HurtSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_KillSounds));	   i++) { PrecacheSoundCustom(g_KillSounds[i]);	   }
	PrecacheSoundCustom("cof/purnell/death.mp3");
	PrecacheSoundCustom("cof/purnell/intro.mp3");
	PrecacheSoundCustom("cof/purnell/converted.mp3");
	PrecacheSoundCustom("cof/purnell/reload.mp3");
	PrecacheSoundCustom("cof/purnell/shoot.mp3");
	PrecacheSoundCustom("cof/purnell/shove.mp3");
	PrecacheSoundCustom("cof/purnell/meleehit.mp3");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rouge Expidonsan Doctor");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_doctor_special");
	strcopy(data.Icon, sizeof(data.Icon), "expidonsan_doctor");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SpecialDoctor(vecPos, vecAng, team);
}

methodmap SpecialDoctor < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayDeathSound()
	{
		EmitCustomToAll("cof/purnell/death.mp3", _, _, _, _, 2.0);
	}
	public void PlayIntroSound()
	{
		EmitCustomToAll("cof/purnell/intro.mp3", _, _, _, _, 3.0);
	}
	public void PlayFriendlySound()
	{
		EmitCustomToAll("cof/purnell/converted.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.0);
	}
	public void PlayReloadSound()
	{
		EmitCustomToAll("cof/purnell/reload.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 1.75);
	}
	public void PlayShootSound()
	{
		EmitCustomToAll("cof/purnell/shoot.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 2.7);
	}
	public void PlayMeleeSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		EmitCustomToAll("cof/purnell/shove.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayHitSound()
	{
		EmitCustomToAll("cof/purnell/meleehit.mp3", this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}
	public void PlayKillSound()
	{
		this.m_flNextHurtSound = GetGameTime(this.index) + 2.0;
		EmitCustomToAll(g_KillSounds[GetRandomInt(0, sizeof(g_KillSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, 3.0);
	}

	public SpecialDoctor(float vecPos[3], float vecAng[3], int ally)
	{
		SpecialDoctor npc = view_as<SpecialDoctor>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", MinibossHealthScaling(70.0), ally));
		i_NpcWeight[npc.index] = 3;
		
		SetEntityRenderMode(npc.index, RENDER_NONE);

		npc.m_iState = -1;
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		if(ally == TFTeam_Red)
		{
			npc.PlayFriendlySound();
		}
		else
		{
			npc.PlayIntroSound();
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/medic.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_german_gonzila.mdl");

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/medic_gasmask/medic_gasmask.mdl");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/spr18_scourge_of_the_sky/spr18_scourge_of_the_sky.mdl");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl");

		npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, SpecialDoctor_ClotDamagedPost);
		
		npc.m_iInjuredLevel = 0;
		npc.m_bThisNpcIsABoss = true;
		npc.m_iTarget = -1;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = false;
		i_ClosestAllyCDTarget[npc.index] = 0.0;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_flNextRangedAttack = 0.0;
		npc.m_iAttacksTillReload = 5;
		npc.m_flReloadDelay = GetGameTime(npc.index) + 0.8;

		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		
		npc.m_flNextRangedSpecialAttack = 0.0;


		func_NPCDeath[npc.index] = view_as<Function>(SpecialDoctor_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(SpecialDoctor_ClotThink);

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
	property int m_iInjuredLevel
	{
		public get()		{ return this.m_iMedkitAnnoyance; }
		public set(int value) 	{ this.m_iMedkitAnnoyance = value; }
	}
}

public void SpecialDoctor_ClotThink(int iNPC)
{
	SpecialDoctor npc = view_as<SpecialDoctor>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.04;
	npc.Update();
	
	if(npc.m_flNextRangedSpecialAttack < gameTime)
	{
		npc.m_flNextRangedSpecialAttack = gameTime + 0.25;
		
		int target = GetClosestAlly(npc.index, (250.0 * 250.0), _,DoctorBuffAlly);
		if(target)
		{
			if(!HasSpecificBuff(target, "False Therapy"))
			{
				ApplyStatusEffect(npc.index, target, "False Therapy", 30.0);
				npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_SECONDARY",_,_,_,3.0);
			}
		}
	}
	
	if(npc.m_iTarget > 0 && !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iTarget <= MaxClients)
			npc.PlayKillSound();
		
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
	}

	if(!IsValidAlly(npc.index, npc.m_iTargetAlly))
	{
		if(i_ClosestAllyCDTarget[npc.index] < GetGameTime(npc.index))
		{
			npc.m_iTargetAlly = GetClosestAlly(npc.index, _, _,DoctorBuffAlly);
			i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 1.0;
		}
	}
	else
	{
		i_ClosestAllyCDTarget[npc.index] = GetGameTime(npc.index) + 0.0;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_flGetClosestTargetTime = gameTime + 0.5;
		npc.m_iTarget = GetClosestTarget(npc.index, true);
	}
	if(IsValidAlly(npc.index, npc.m_iTargetAlly) && IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTargetally[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTargetally);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
		
		float distanceToAlly = GetVectorDistance(vecTargetally, vecPos, true);
		float distanceToEnemy = GetVectorDistance(vecTarget, vecTargetally, true);
		if(distanceToAlly > (140.0 * 140.0) && npc.m_iTargetWalkTo < (50.0 * 50.0)) //get close to ally but not too close
		{
			npc.m_iTargetWalkTo = npc.m_iTargetAlly;
		}
		else
		{
			if(distanceToEnemy < (200.0 * 200.0)) //enemy is too close to friend, follow enemy
			{
				npc.m_iTargetWalkTo = npc.m_iTargetAlly;
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = npc.m_iTarget;
	}
	
	int behavior = -1;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			npc.m_iAttacksTillReload++;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						float damage = 50.0;
											
											
						if(!ShouldNpcDealBonusDamage(target))
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);
						else
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * 3.0 * npc.m_flWaveScale, DMG_CLUB, -1, _, vecHit);

						Custom_Knockback(npc.index, target, 500.0);
						npc.m_iAttacksTillReload++;
						npc.PlayHitSound();
					}
				}
				delete swingTrace;
			}
		}
		
		behavior = 0;
	}
	
	if(behavior == -1)
	{
		if(npc.m_iTarget > 0 && npc.m_iTargetWalkTo > 0)	// We have a target
		{
			float vecPos[3]; WorldSpaceCenter(npc.index, vecPos );
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			
			float distance = GetVectorDistance(vecTarget, vecPos, true);
			if(distance < 10000.0 && npc.m_flNextMeleeAttack < gameTime)	// Close at any time: Melee
			{
				npc.FaceTowards(vecTarget, 15000.0);
				
				npc.AddGesture("ACT_MP_THROW");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.3;
				npc.m_flReloadDelay = gameTime + 0.6;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
				
				behavior = 0;
			}
			else if(npc.m_flReloadDelay > gameTime)	// Reloading
			{
				behavior = 0;
			}
			else if(distance < 80000.0)	// In shooting range
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
							npc.SetActivity("ACT_MP_STAND_SECONDARY");
							
							npc.FaceTowards(vecTarget, 15000.0);
							
							npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
							
							npc.m_flNextRangedAttack = gameTime + 1.0;
							npc.m_iAttacksTillReload--;
							
							PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 700.0, _,vecTarget);
							float damage = 50.0;

							npc.FireRocket(vecTarget, damage * 0.9 * npc.m_flWaveScale, 700.0, "models/weapons/w_bullet.mdl", 2.0);
							
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
					npc.SetActivity("ACT_MP_STAND_SECONDARY");
				}
			}
			else if(npc.m_iAttacksTillReload < 0)	// Take the time to reload
			{
				//Only if low ammo, otherwise it can be abused.
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
				npc.StopPathing();
				
			}
		}
		case 1:	// Move After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 200.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 2:	// Sprint After the Player
		{
			npc.SetActivity("ACT_MP_RUN_SECONDARY");
			npc.m_flSpeed = 250.0;
			npc.m_flRangedSpecialDelay = 0.0;
			
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 3:	// Retreat
		{
			npc.m_flSpeed = 500.0;
			
			if(!npc.m_flRangedSpecialDelay)	// Reload anyways timer
				npc.m_flRangedSpecialDelay = gameTime + 4.0;
			
			float vBackoffPos[3]; BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTargetWalkTo,_,vBackoffPos);
			npc.SetGoalVector(vBackoffPos);
			
			if(!npc.m_bPathing)
				npc.StartPathing();
		}
		case 4:	// Reload
		{
			npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY",_,_,_,0.25);
			npc.m_flSpeed = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flReloadDelay = gameTime + 4.25;
			npc.m_iAttacksTillReload = 5;
			
			if(npc.m_bPathing)
			{
				npc.StopPathing();
				
			}
			
			npc.PlayReloadSound();
		}
	}
}

public void SpecialDoctor_ClotDamagedPost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon, const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if(damage > 0.0)
	{
		SpecialDoctor npc = view_as<SpecialDoctor>(victim);

		npc.PlayHurtSound();
	}
}

public void SpecialDoctor_NPCDeath(int entity)
{
	SpecialDoctor npc = view_as<SpecialDoctor>(entity);

	npc.SetModel("models/player/medic.mdl");
	SetEntityRenderColor(npc.index, 255, 255, 255, 255);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, SpecialDoctor_ClotDamagedPost);
	
	npc.PlayDeathSound();

	Citizen_MiniBossDeath(entity);
}


public bool DoctorBuffAlly(int provider, int entity)
{
	if(HasSpecificBuff(entity, "False Therapy"))
		return false;

	return true;
}