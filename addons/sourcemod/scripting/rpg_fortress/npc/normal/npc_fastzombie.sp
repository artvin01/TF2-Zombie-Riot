#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
};

static char g_leap_prepare[][] = {
	"npc/fast_zombie/leap1.wav",
};

static char g_leap_scream[][] = {
	"npc/fast_zombie/fz_scream1.wav",
};

static char g_IdleSounds[][] = {
	"npc/fast_zombie/idle1.wav",
	"npc/fast_zombie/idle2.wav",
	"npc/fast_zombie/idle3.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/fast_zombie/fz_alert_close1.wav",
	"npc/fast_zombie/fz_alert_far1.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/fast_zombie/fz_frenzy1.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpPrepare[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};
static char g_PlayMeleeJumpSound[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

public void FastZombie_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PlayMeleeJumpPrepare));   i++) { PrecacheSound(g_PlayMeleeJumpPrepare[i]);   }
	for (int i = 0; i < (sizeof(g_PlayMeleeJumpSound));   i++) { PrecacheSound(g_PlayMeleeJumpSound[i]);   }
	for (int i = 0; i < (sizeof(g_leap_scream));   i++) { PrecacheSound(g_leap_scream[i]);   }
	for (int i = 0; i < (sizeof(g_leap_prepare));   i++) { PrecacheSound(g_leap_prepare[i]);   }
	PrecacheModel("models/zombie/fast.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fast Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_fastzombie");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return FastZombie(vecPos, vecAng, team);
}

methodmap FastZombie < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);	
	}
	
	public void PlayLeapPrepare() {
		
		EmitSoundToAll(g_leap_prepare[GetRandomInt(0, sizeof(g_leap_prepare) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayLeapDone() {
		
		EmitSoundToAll(g_leap_scream[GetRandomInt(0, sizeof(g_leap_scream) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeJumpPrepare()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_PlayMeleeJumpPrepare[GetRandomInt(0, sizeof(g_PlayMeleeJumpPrepare) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public FastZombie(float vecPos[3], float vecAng[3], int ally)
	{
		FastZombie npc = view_as<FastZombie>(CClotBody(vecPos, vecAng, "models/zombie/fast.mdl", "1.15", "300", ally, false,_,_,_,_));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "warrior_spirit");

		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		func_NPCDeath[npc.index] = FastZombie_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = FastZombie_OnTakeDamage;
		func_NPCThink[npc.index] = FastZombie_ClotThink;


		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		
		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void FastZombie_ClotThink(int iNPC)
{
	FastZombie npc = view_as<FastZombie>(iNPC);

	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation && npc.m_flDoingAnimation < gameTime) //Dont play dodge anim if we are in an animation.
	{
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, 500.0, "ACT_RUN", "ACT_IDLE_ANGRY", 360.0, gameTime);

	if(npc.m_bmovedelay_gun)
	{
		if (npc.IsOnGround())
		{
			npc.m_flDoingAnimation = 0.0;
			npc.m_bmovedelay_gun = false;
			npc.m_bisWalking = true;
			if(npc.m_iChanged_WalkCycle != 4) 	
			{
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_RUN");
			}
		}
	}

	if(npc.m_flInJump)
	{
		if(npc.m_flInJump < gameTime)
		{
			npc.m_flInJump = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vPredictedPos[3]; 
				PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
				npc.m_flDoingAnimation = gameTime + 3.5;
				npc.m_bisWalking = true;
				npc.RemoveGesture("ACT_JUMP");
				if(npc.m_iChanged_WalkCycle != 3) 	
				{
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_FASTZOMBIE_LEAP_STRIKE");
				}
				npc.FaceTowards(vPredictedPos, 15000.0);
				PluginBot_Jump(npc.index, vPredictedPos);
				npc.PlayLeapDone();
				npc.m_bisWalking = false;
				npc.m_bmovedelay_gun = true; //we'll treat this as that he jumped.
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3];
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);

		float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, npc.m_iTarget,_,_,vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.65) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump < GetGameTime(npc.index) && flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0) && flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
		{
			npc.m_iState = 2; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_RUN");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;			
					npc.m_flDoingAnimation = gameTime + 0.3;
					npc.m_flNextMeleeAttack = gameTime + 0.3;
					if(npc.m_flNextRangedSpecialAttack < gameTime)
					{
						npc.m_iMedkitAnnoyance = 0; //Nope, didnt attack in a row alot, reset.
					}
					if(npc.m_iMedkitAnnoyance > 3)
					{
						npc.PlayMeleeSound();
						npc.m_iMedkitAnnoyance = 0; //Too many attacks, now be angery and scream!
						npc.m_flDoingAnimation = gameTime + 1.5;
						npc.AddGesture("ACT_FASTZOMBIE_FRENZY");
					}
					else
					{
						npc.AddGesture("ACT_MELEE_ATTACK1");

						Handle swingTrace;
						float WorldSpaceCenterVec[3]; 
						WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
						npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
						if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float damage = 20000.0;

							npc.PlayMeleeHitSound();
							if(target > 0) 
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);

								int Health = GetEntProp(target, Prop_Data, "m_iHealth");
								
								if(Health <= 0)
								{
									npc.PlayKilledEnemySound();
								}
							}
						}
						delete swingTrace;		
					}
					npc.m_flNextRangedSpecialAttack = gameTime + 1.0;
					npc.m_iMedkitAnnoyance += 1;
					npc.m_bisWalking = false;
				}
			}
			case 2:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.m_flInJump = GetGameTime(npc.index) + 0.5;
				
					npc.m_flJumpCooldown = GetGameTime(npc.index) + 5.0;
					npc.PlayLeapPrepare();
				
					npc.AddGesture("ACT_JUMP");

					npc.m_flDoingAnimation = gameTime + 0.5;
					npc.m_bisWalking = false;
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action FastZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	FastZombie npc = view_as<FastZombie>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void FastZombie_NPCDeath(int entity)
{
	FastZombie npc = view_as<FastZombie>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


