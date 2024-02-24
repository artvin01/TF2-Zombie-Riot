#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
};

static const char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav"
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/takecover.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/subject.wav",
	"npc/metropolice/vo/subjectis505.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/stunstick/stunstick_fleshhit1.wav",
	"weapons/stunstick/stunstick_fleshhit2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/stunstick/stunstick_swing1.wav",
	"weapons/stunstick/stunstick_swing2.wav"
};

static const char g_MeleeMissSounds[][] =
{
	"weapons/stunstick/spark1.wav",
	"weapons/stunstick/spark2.wav",
	"weapons/stunstick/spark3.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/pistol/pistol_fire2.wav"
};

static const char g_RangedReloadSound[][] =
{
	"weapons/pistol/pistol_reload1.wav"
};

void CombinePolicePistol_Precache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/police.mdl");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Metro Cop");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_police_pistol");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, const float vecPos[3], const float vecAng[3], int team)
{
	return CombinePolicePistol(client, vecPos, vecAng, team);
}

methodmap CombinePolicePistol < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	public void PlayRangedReloadSound()
	{
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);	
	}
	
	public CombinePolicePistol(int client, const float vecPos[3], const float vecAng[3], int team)
	{
		CombinePolicePistol npc = view_as<CombinePolicePistol>(CClotBody(vecPos, vecAng, "models/police.mdl", "1.15", "200", team));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_RUN");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 160.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedAttack = 0.0;
		npc.m_flReloadDelay = 0.0;
		npc.m_iAttacksTillReload = 12;
		npc.m_fbGunout = false;

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl", _, _, 1.15);
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		
		npc.m_iWearable2 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_stunbaton.mdl", _, _, 1.15);

		return npc;
	}
}

static void ClotThink(int iNPC)
{
	CombinePolicePistol npc = view_as<CombinePolicePistol>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flAttackHappens == 0.0)
		{
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
			npc.PlayHurtSound();
		}

		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(npc.m_flGetClosestTargetTime < gameTime || !IsValidEnemy(npc.index, target))
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(target > 0)
	{
		float vecTarget[3], vecMe[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);		

		if(distance < npc.GetLeadRadius())
		{
			float predictedPos[3];
			PredictSubjectPosition(npc, target, _, _, predictedPos);
			npc.SetGoalVector(predictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}
		
		if(npc.m_flAttackHappens)
		{
			// Swinging melee
			npc.StartPathing();

			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 15000.0);
				if(npc.DoSwingTrace(swingTrace, target, _, _, _, _))
				{
					target = TR_GetEntityIndex(swingTrace);

					if(target > 0)
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, 40.0, DMG_CLUB);
					}
					else
					{
						npc.PlayMeleeMissSound();
					}
				}

				delete swingTrace;
			}
		}
		else if(npc.m_flReloadDelay > gameTime || (distance > 62500.0 && distance < 122500.0))
		{
			// Using gun
			npc.StopPathing();

			if(!npc.m_fbGunout)
			{
				npc.SetActivity("ACT_IDLE_ANGRY_PISTOL");
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				npc.m_fbGunout = true;
			}

			if(npc.m_flNextRangedAttack < gameTime)
			{
				if(npc.m_iAttacksTillReload == 0)
				{
					// Reload
					npc.AddGesture("ACT_RELOAD_PISTOL");
					npc.m_flReloadDelay = gameTime + 1.4;
					npc.m_flNextRangedAttack = npc.m_flReloadDelay;
					npc.m_iAttacksTillReload = 12;
					npc.PlayRangedReloadSound();
				}
				else
				{
					// Fire
					npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_PISTOL");
					npc.FaceTowards(vecTarget, 10000.0);
					npc.m_flNextRangedAttack = gameTime + 0.5;
					npc.m_iAttacksTillReload--;

					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x = GetRandomFloat(-0.03, 0.03);
					float y = GetRandomFloat(-0.03, 0.03);
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);

					vecDirShooting[0] += x * vecRight[0] + y * vecUp[0]; 
					vecDirShooting[1] += x * vecRight[1] + y * vecUp[1]; 
					vecDirShooting[2] += x * vecRight[2] + y * vecUp[2]; 
					NormalizeVector(vecDirShooting, vecDirShooting);
					
					FireBullet(npc.index, npc.m_iWearable1, vecMe, vecDirShooting, 6.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
					
					npc.PlayRangedSound();
				}
			}
		}
		else
		{
			// Using melee
			npc.StartPathing();

			if(npc.m_fbGunout)
			{
				npc.SetActivity("ACT_RUN");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				npc.m_fbGunout = false;
			}

			if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
			{
				target = Can_I_See_Enemy(npc.index, target);
				if(IsValidEnemy(npc.index, target))
				{
					npc.m_iTarget = target;
					npc.m_flGetClosestTargetTime = gameTime + 1.0;

					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.PlayMeleeSound();
					
					npc.m_flAttackHappens = gameTime + 0.4;
					npc.m_flNextMeleeAttack = gameTime + 1.4;
				}
			}
		}
	}
	else
	{
		npc.SetActivity("ACT_IDLE");
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	CombinePolicePistol npc = view_as<CombinePolicePistol>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}