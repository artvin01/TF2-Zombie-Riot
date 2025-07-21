#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/headcrab/die1.wav",
	"npc/headcrab/die2.wav"
};

static const char g_HurtSound[][] = {
	"npc/headcrab/pain1.wav",
	"npc/headcrab/pain2.wav",
	"npc/headcrab/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/headcrab/idle1.wav",
	"npc/headcrab/idle2.wav",
	"npc/headcrab/idle3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/headcrab/alert1.wav"
};

static const char g_MeleeHitSounds[][] = {
	"npc/headcrab/headbite.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"npc/headcrab/attack1.wav",
	"npc/headcrab/attack2.wav",
	"npc/headcrab/attack3.wav"
};

void ArkSlug_MapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}

	PrecacheModel("models/headcrabclassic.mdl");
}

methodmap ArkSlug < CClotBody
{
	public void PlayIdleSound(bool alert)
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		if(alert)
		{
			EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		}
		else
		{
			EmitSoundToAll(g_IdleSound[GetRandomInt(0, sizeof(g_IdleSound) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME,_);
		}

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
	
	public ArkSlug(float vecPos[3], float vecAng[3], int ally)
	{
		ArkSlug npc = view_as<ArkSlug>(CClotBody(vecPos, vecAng, "models/headcrabclassic.mdl", "1.15", "1050", ally, false));
		// Originium Slug α (HP)

		i_NpcInternalId[npc.index] = ARK_SLUG;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = false;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flNextThinkTime = GetGameTime() + GetRandomFloat(0.0, 0.5);

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		
		SetEntityRenderColor(npc.index, 50, 25, 0, 255);

		SDKHook(npc.index, SDKHook_OnTakeDamage, ArkSlug_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, ArkSlug_ClotThink);
		
		npc.StopPathing();
		

		i_NoEntityFoundCount[npc.index] = 6;
		
		return npc;
	}
	
}

public void ArkSlug_ClotThink(int iNPC)
{
	ArkSlug npc = view_as<ArkSlug>(iNPC);

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
		//npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	bool wasBurrowed;
	if(i_NoEntityFoundCount[npc.index] > 8)
	{
		wasBurrowed = true;
		i_NoEntityFoundCount[npc.index] = 9;
	}

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, f_SingerBuffedFor[npc.index] > gameTime ? 775.0 : 350.0, "ACT_RUN", "ACT_IDLE", 100.0, gameTime);
	
	if(i_NoEntityFoundCount[npc.index] == 9)
	{
		// Start hiding
		npc.m_bisWalking = false; 
		npc.SetActivity("ACT_HEADCRAB_BURROW_IDLE");
		npc.AddGesture("ACT_HEADCRAB_BURROW_IN");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));

		if(IsValidEntity(npc.m_iTextEntity1))
			RemoveEntity(npc.m_iTextEntity1);
		
		if(IsValidEntity(npc.m_iTextEntity2))
			RemoveEntity(npc.m_iTextEntity2);
		
		if(IsValidEntity(npc.m_iTextEntity3))
			RemoveEntity(npc.m_iTextEntity3);
	}
	else if(i_NoEntityFoundCount[npc.index] > 9)
	{
		// Keep hiding
		npc.m_bisWalking = false;
		if(npc.m_iChanged_WalkCycle != 5)
		{
			npc.m_iChanged_WalkCycle = 5;
			npc.SetActivity("ACT_HEADCRAB_BURROW_IDLE");
		}
	}
	else if(wasBurrowed)
	{
		// Stop hiding
		npc.m_bisWalking = false; 
		npc.SetActivity("ACT_IDLE");
		npc.AddGesture("ACT_HEADCRAB_BURROW_OUT");

		int health = ReturnEntityMaxHealth(npc.index);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", health);
		
		npc.m_flNextThinkTime = gameTime + 1.4;
		npc.m_iChanged_WalkCycle = 5;

		SetEntPropFloat(npc.index, Prop_Send, "m_flModelScale", 0.5);
		Apply_Text_Above_Npc(npc.index, 0, health);
		SetEntPropFloat(npc.index, Prop_Send, "m_flModelScale", 1.15);
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenterOld(npc.m_iTarget), 15000.0); //Snap to the enemy. make backstabbing hard to do.
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, _)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, 92.5, DMG_CLUB);
						Stats_AddOriginium(target, 1);
						// Originium Slug α (50% dmg)

						if(GetEntProp(target, Prop_Data, "m_iHealth") < 1)
						{
							npc.PlayKilledEnemySound();
						}
					}
				}
				delete swingTrace;
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenterOld(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenterOld(npc.index), true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPositionOld(npc, npc.m_iTarget);
			
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
					npc.SetActivity("ACT_RUN");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_RANGE_ATTACK1");

					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.5;

					//npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextMeleeAttack = gameTime + (f_SingerBuffedFor[npc.index] > gameTime ? 1.0 : 1.5);
					npc.m_bisWalking = true;
				}
			}
		}
	}

	npc.PlayIdleSound(i_NoEntityFoundCount[npc.index] < 9);
}

public Action ArkSlug_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	ArkSlug npc = view_as<ArkSlug>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void ArkSlug_NPCDeath(int entity)
{
	ArkSlug npc = view_as<ArkSlug>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	SDKUnhook(entity, SDKHook_OnTakeDamage, ArkSlug_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, ArkSlug_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}


