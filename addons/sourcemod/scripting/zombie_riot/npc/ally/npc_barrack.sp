#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthatcan1.wav",
	"npc/metropolice/vo/pickupthatcan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char g_IdleAlertedSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeHitSounds[][] =
{
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/shovel_swing.wav",
};

static const char g_MeleeMissSounds[][] =
{
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/bow_shoot.wav",
};

static const char g_SwordHitSounds[][] =
{
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_SwordAttackSounds[][] =
{
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static int BarrackOwner[MAXENTITIES];

methodmap BarrackBody < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordSound()
	{
		EmitSoundToAll(g_SwordAttackSounds[GetRandomInt(0, sizeof(g_SwordAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlaySwordHitSound()
	{
		EmitSoundToAll(g_SwordHitSounds[GetRandomInt(0, sizeof(g_SwordHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	property int OwnerUserId
	{
		public get()
		{
			return BarrackOwner[view_as<int>(this)];
		}
	}
	
	public BarrackBody(int client, float vecPos[3], float vecAng[3], const char[] health)
	{
		BarrackBody npc = view_as<BarrackBody>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "0.575", health, true));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		BarrackOwner[npc.index] = client ? GetClientUserId(client) : 0;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;

		npc.m_iState = 0;
		npc.m_flSpeed = 200.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;

		SDKHook(npc.index, SDKHook_OnTakeDamage, BarrackBody_ClotDamaged);
		
		npc.StartPathing();
		return npc;
	}
}

bool BarrackBody_ThinkStart(int iNPC)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
		return false;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
		return false;
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	return true;
}

void BarrackBody_ThinkTarget(int iNPC, bool camo)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index) || !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		npc.m_iTargetAlly = client ? Building_GetFollowerEntity(client) : 0;
		
		if(npc.m_iTargetAlly > 0)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			npc.m_iTarget = GetClosestTarget(npc.index, _, 800000.0, camo, _, _, vecTarget, true);
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index, _, _, camo);
		}

		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
}

void BarrackBody_ThinkMove(int iNPC, const char[] idleAnim = "", const char[] moveAnim = "", float retreat = 0.0, bool move = true)
{
	BarrackBody npc = view_as<BarrackBody>(iNPC);

	bool pathed;
	if(move && npc.m_flReloadDelay < GetGameTime(npc.index))
	{
		int client = GetClientOfUserId(npc.OwnerUserId);
		int command = client ? Building_GetFollowerCommand(client) : Command_Aggressive;

		if(npc.m_iTarget > 0 && command != Command_Retreat)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			if(flDistanceToTarget < retreat)
			{
				if(command == Command_Aggressive || npc.m_iTargetAlly < 1 || flDistanceToTarget < npc.GetLeadRadius())
				{
					vecTarget = BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget);
					PF_SetGoalVector(npc.index, vecTarget);
					
					npc.StartPathing();
					pathed = true;
				}
			}
			else if(flDistanceToTarget < npc.GetLeadRadius())
			{
				//Predict their pos.
				vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
				PF_SetGoalVector(npc.index, vecTarget);

				npc.StartPathing();
				pathed = true;
			}
			else
			{
				PF_SetGoalEntity(npc.index, npc.m_iTarget);

				npc.StartPathing();
				pathed = true;
			}
		}
		
		if(!pathed && npc.m_iTargetAlly > 0 && command != Command_Aggressive)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTargetAlly);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				PF_SetGoalEntity(npc.index, npc.m_iTargetAlly);

				npc.StartPathing();
				pathed = true;
			}
		}
	}
	
	if(pathed)
	{
		if(moveAnim[0])
			npc.SetActivity(moveAnim);
	}
	else
	{
		if(idleAnim[0])
			npc.SetActivity(idleAnim);
		
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
	}

	if(npc.m_iTarget > 0)
	{
		npc.PlayIdleAlertSound();
	}
	else
	{
		npc.PlayIdleSound();
	}
}

public Action BarrackBody_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	BarrackBody npc = view_as<BarrackBody>(victim);
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

void BarrackBody_NPCDeath(int entity)
{
	BarrackBody npc = view_as<BarrackBody>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BarrackBody_ClotDamaged);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}