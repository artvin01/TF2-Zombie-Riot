#pragma semicolon 1
#pragma newdecls required

static const char MeleeHitSounds[][] =
{
	"mvm/melee_impacts/bottle_hit_robo01.wav",
	"mvm/melee_impacts/bottle_hit_robo02.wav",
	"mvm/melee_impacts/bottle_hit_robo03.wav",
};

static const char MeleeAttackSounds[][] =
{
	"weapons/shovel_swing.wav",
};

static const char MeleeMissSounds[][] =
{
	"weapons/cbar_miss1.wav",
};

void Militia_MapStart()
{
	PrecacheSoundArray(MeleeHitSounds);
	PrecacheSoundArray(MeleeAttackSounds);
	PrecacheSoundArray(MeleeMissSounds);
}

methodmap Militia < EmpireBody
{
	public void PlayMeleeSound()
	{
		EmitSoundToAll(MeleeAttackSounds[GetRandomInt(0, sizeof(MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(MeleeHitSounds[GetRandomInt(0, sizeof(MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeMissSound()
	{
		EmitSoundToAll(MeleeMissSounds[GetRandomInt(0, sizeof(MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	
	public Militia(int client, float vecPos[3], float vecAng[3])
	{
		Militia npc = view_as<Militia>(EmpireBody(client, vecPos, vecAng, _, _, "50"));

		i_NpcInternalId[npc.index] = MILITIA;
		i_NpcWeight[npc.index] = 1;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCThink[npc.index] = ClotThink;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		
		npc.SetActivity("ACT_IDLE");
		npc.m_flSpeed = 90.0;

		npc.m_flHeadshotCooldown = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_flReloadDelay = 0.0;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_boston_basher/c_boston_basher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop/player/items/sniper/spr17_archers_sterling/spr17_archers_sterling.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		return npc;
	}
}

static void ClotThink(int entity)
{
	Militia npc = view_as<Militia>(entity);
	float gameTime = GetGameTime(npc.index);
	
	if(!npc.ThinkStart(gameTime))
		return;
	
	int target = npc.ThinkTarget(gameTime);
	
	if(target > 0)
	{
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.FaceTowards(vecTarget, 20000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(target > 0) 
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, 4.0, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					} 
				}

				delete swingTrace;

				npc.m_flAttackHappens = 0.0;
			}
		}
		else
		{
			float vecMe[3], vecTarget[3];
			WorldSpaceCenter(target, vecMe);
			WorldSpaceCenter(target, vecTarget);
			
			float distance = GetVectorDistance(vecMe, vecTarget, true);
			if(distance < 10000.0)
			{
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				npc.PlayMeleeSound();

				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flReloadDelay = gameTime + 0.9;
				npc.m_flNextMeleeAttack = gameTime + 2.0;
			}
		}
	}
	
	bool moving;

	if(npc.m_flReloadDelay > gameTime)
	{
		npc.StopPathing();
	}
	else
	{
		moving = npc.ThinkMove(gameTime);
	}
	
	if(moving)
	{
		npc.SetActivity("ACT_WALK");
	}
	else
	{
		npc.SetActivity("ACT_IDLE");
	}
}

static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	// TODO: Move this into npc_base_empire
	if(attacker > 0)
	{
		Militia npc = view_as<Militia>(victim);

		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;

			npc.PlayHurtSound();
			npc.AddNextGesture("ACT_GESTURE_FLINCH_HEAD");
		}
	}
}

static void ClotDeath(int entity)
{
	// TODO: Move this into npc_base_empire
	Militia npc = view_as<Militia>(entity);
	
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}