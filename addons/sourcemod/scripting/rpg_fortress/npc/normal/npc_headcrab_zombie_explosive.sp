#pragma semicolon 1
#pragma newdecls required

// this should vary from npc to npc as some are in a really small area.

static char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static char g_HurtSound[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static char g_IdleSound[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/zombie/zombie_alert1.wav",
	"npc/zombie/zombie_alert2.wav",
	"npc/zombie/zombie_alert3.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};

static char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};



public void ExplosiveHeadcrabZombie_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}

	PrecacheModel("models/zombie/classic.mdl");
	PrecacheSound("ambient/explosions/explode_3.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Explosive Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_headcrab_zombie_explosive");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ExplosiveHeadcrabZombie(vecPos, vecAng, team);
}

methodmap ExplosiveHeadcrabZombie < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayHurtSound()
	{
		
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
	}
	public void PlayKilledEnemySound() 
	{
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_AUTO, 90, _, 1.0,_);
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
	
	
	public ExplosiveHeadcrabZombie(float vecPos[3], float vecAng[3], int ally)
	{
		ExplosiveHeadcrabZombie npc = view_as<ExplosiveHeadcrabZombie>(CClotBody(vecPos, vecAng, "models/zombie/classic.mdl", "1.15", "300", ally, false,_,_,_,_));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "pumpkindeath");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		func_NPCDeath[npc.index] = ExplosiveHeadcrabZombie_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ExplosiveHeadcrabZombie_OnTakeDamage;
		func_NPCThink[npc.index] = ExplosiveHeadcrabZombie_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flNextThinkTime = GetGameTime() + GetRandomFloat(0.0, 1.0);

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];

		npc.g_TimesSummoned = 0;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, ExplosiveHeadcrabZombie_OnTakeDamagePost);

		npc.StopPathing();
			
		
		return npc;
	}
	
}


public void ExplosiveHeadcrabZombie_ClotThink(int iNPC)
{
	ExplosiveHeadcrabZombie npc = view_as<ExplosiveHeadcrabZombie>(iNPC);

	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");

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
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	if(npc.m_flNextRangedAttackHappening)
		Npc_Base_Thinking(iNPC, 250.0, "ACT_WALK", "ACT_ZOMBIE_TANTRUM", 120.0, gameTime);
	else
		Npc_Base_Thinking(iNPC, 250.0, "ACT_WALK", "ACT_ZOMBIE_TANTRUM", 300.0, gameTime);
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float WorldSpaceCenterVec[3]; 
				WorldSpaceCenter(npc.m_iTarget, WorldSpaceCenterVec);
				npc.FaceTowards(WorldSpaceCenterVec, 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 22000.0;

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						KillFeed_SetKillIcon(npc.index, "warrior_spirit");
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
						KillFeed_SetKillIcon(npc.index, "pumpkindeath");

						int Health = GetEntProp(target, Prop_Data, "m_iHealth");
						
						if(Health <= 0)
						{
							npc.PlayKilledEnemySound();
						}
					}
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		if(npc.m_iChanged_WalkCycle != 6) 	
		{
			npc.m_iChanged_WalkCycle = 6;
			npc.SetActivity("ACT_ZOMBIE_TANTRUM");
			SetEntityRenderColor(npc.index, 255, 100, 100, 255);
		}
		float vecabsorigin[3];
		GetAbsOrigin(npc.index, vecabsorigin);
		spawnRing_Vectors(vecabsorigin, /*RANGE*/ 250 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, /*DURATION*/ 0.2, 6.0, 0.1, 1, 1.0);

		float vecTarget[3];
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);
		}
		if(npc.m_flNextRangedAttackHappening < gameTime)
		{
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);

			npc.m_flNextRangedAttackHappening = 0.0;
			float vecTarget2[3];
			WorldSpaceCenter(npc.index, vecTarget2);
			makeexplosion(npc.index, vecTarget2, 35000, 200);
			int maxhealth = ReturnEntityMaxHealth(npc.index);
			maxhealth /= 5;
			HealEntityGlobal(npc.index, npc.index, -float(maxhealth), 1.0, 0.0, _);
			RPGNpc_UpdateHpHud(npc.index);
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
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
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
					npc.SetActivity("ACT_WALK");
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

					npc.AddGesture("ACT_MELEE_ATTACK1");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.8;

					npc.m_flDoingAnimation = gameTime + 0.8;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					npc.m_bisWalking = true;
				}
			}
		}
	}
	npc.PlayIdleSound();
}


public Action ExplosiveHeadcrabZombie_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	ExplosiveHeadcrabZombie npc = view_as<ExplosiveHeadcrabZombie>(victim);

	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextRangedAttackHappening > gameTime)
	{
		damage *= 0.35;
	}
	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void ExplosiveHeadcrabZombie_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	ExplosiveHeadcrabZombie npc = view_as<ExplosiveHeadcrabZombie>(victim);
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.65) > ratio)
	{
		npc.g_TimesSummoned++;
		//Exploding already or in cd? Dont do another.
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index))
		{
			float vecabsorigin[3];
			GetAbsOrigin(npc.index, vecabsorigin);

			npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5; //This is the explosive cooldown
			npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 1.5; //This is the explosive cooldown
			npc.PlayKilledEnemySound();
			spawnRing_Vectors(vecabsorigin, /*RANGE*/ 250 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, /*DURATION*/ 0.2, 6.0, 0.1, 1, 1.0);
		}
	}
}

public void ExplosiveHeadcrabZombie_NPCDeath(int entity)
{
	ExplosiveHeadcrabZombie npc = view_as<ExplosiveHeadcrabZombie>(entity);
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
