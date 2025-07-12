#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSound[][] = {
	"npc/headcrab_poison/ph_pain1.wav",
	"npc/headcrab_poison/ph_pain2.wav"
};

static const char g_IdleSound[][] = {
	"npc/headcrab_poison/ph_talk1.wav",
	"npc/headcrab_poison/ph_talk2.wav",
	"npc/headcrab_poison/ph_talk3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/headcrab_poison/ph_rattle1.wav",
	"npc/headcrab_poison/ph_rattle2.wav",
	"npc/headcrab_poison/ph_rattle3.wav"
};

static const char g_MeleeAttackSounds[][] = {
	"npc/headcrab_poison/ph_scream1.wav",
	"npc/headcrab_poison/ph_scream2.wav",
	"npc/headcrab_poison/ph_scream3.wav"
};

static const char g_MeleeHitSounds[][] = {
	"npc/headcrab/headbite.wav"
};

void ArkSlugInfused_MapStart()
{
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}

	PrecacheModel("models/headcrab.mdl");
}

methodmap ArkSlugInfused < CClotBody
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
	
	public ArkSlugInfused(float vecPos[3], float vecAng[3], int ally)
	{
		ArkSlugInfused npc = view_as<ArkSlugInfused>(CClotBody(vecPos, vecAng, "models/headcrab.mdl", "1.15", "2460", ally, false));
		// Infused Originium Slug (HP)

		i_NpcInternalId[npc.index] = ARK_SLUG_INFUSED;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "bread_bite");
		
		npc.SetActivity("ACT_IDLE");

		npc.m_bisWalking = false;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flNextThinkTime = GetGameTime() + GetRandomFloat(0.0, 1.0);

		f3_SpawnPosition[npc.index][0] = vecPos[0];
		f3_SpawnPosition[npc.index][1] = vecPos[1];
		f3_SpawnPosition[npc.index][2] = vecPos[2];
		
		SetEntityRenderColor(npc.index, 150, 25, 0, 255);

		SDKHook(npc.index, SDKHook_OnTakeDamage, ArkSlugInfused_OnTakeDamage);
		SDKHook(npc.index, SDKHook_Think, ArkSlugInfused_ClotThink);
		
		npc.StopPathing();
		
		
		return npc;
	}
	
}

public void ArkSlugInfused_ClotThink(int iNPC)
{
	ArkSlugInfused npc = view_as<ArkSlugInfused>(iNPC);

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

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(iNPC, f_SingerBuffedFor[npc.index] > gameTime ? 775.0 : 500.0, "ACT_RUN", "ACT_IDLE", 216.0, gameTime);
	
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
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, 130.0, DMG_CLUB);
						Stats_AddOriginium(target, 1);
						// Infused Originium Slug (50% dmg)
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
					
					npc.m_flAttackHappens = gameTime + 0.3;

					//npc.m_flDoingAnimation = gameTime + 1.2;
					npc.m_flNextMeleeAttack = gameTime + (f_SingerBuffedFor[npc.index] > gameTime ? 1.0 : 1.5);
					npc.m_bisWalking = true;
				}
			}
		}
	}

	npc.PlayIdleSound(i_NoEntityFoundCount[npc.index] < 9);
}

public Action ArkSlugInfused_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	ArkSlugInfused npc = view_as<ArkSlugInfused>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void ArkSlugInfused_NPCDeath(int entity)
{
	ArkSlugInfused npc = view_as<ArkSlugInfused>(entity);
	
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		KillFeed_SetKillIcon(npc.index, "pumpkindeath");

		float pos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos); 
		pos[2] += 30;
		
		DataPack pack;
		CreateDataTimer(0.5, ArkSlugInfused_Timer, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(entity);
		pack.WriteFloat(pos[0]);
		pack.WriteFloat(pos[1]);
		pack.WriteFloat(pos[2]);
	}

	SDKUnhook(entity, SDKHook_OnTakeDamage, ArkSlugInfused_OnTakeDamage);
	SDKUnhook(entity, SDKHook_Think, ArkSlugInfused_ClotThink);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}

public Action ArkSlugInfused_Timer(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = pack.ReadCell();
	float pos[3];
	pos[0] = pack.ReadFloat();
	pos[1] = pack.ReadFloat();
	pos[2] = pack.ReadFloat();

	makeexplosion(IsValidEntity(entity) ? entity : 0, pos, 520, 100, _, true);
	// Infused Originium Slug boom.atk_scale (50% dmg)

	return Plugin_Continue;
}
