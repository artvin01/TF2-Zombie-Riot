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

void Militia_Setup()
{
	PrecacheSoundArray(MeleeHitSounds);
	PrecacheSoundArray(MeleeAttackSounds);
	PrecacheSoundArray(MeleeMissSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Militia");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_militia");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int team, const float vecPos[3], const float vecAng[3])
{
	return Militia(team, vecPos, vecAng);
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
	
	public Militia(int team, const float vecPos[3], const float vecAng[3])
	{
		Militia npc = view_as<Militia>(EmpireBody(team, vecPos, vecAng, _, _, "40"));

		i_NpcWeight[npc.index] = 1;

		func_NPCThink[npc.index] = ClotThink;
		
		npc.SetActivity("ACT_IDLE");
		npc.m_flSpeed = 180.0;
		npc.m_flVisionRange = 400.0;
		npc.m_flEngageRange = 300.0;

		npc.AddFlag(Flag_Biological);

		StatEnum stats;
		stats.Damage = 4;
		stats.RangeArmor = 1;
		npc.SetStats(stats);

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
	
	if(npc.m_flAttackHappens)
	{
		target = npc.m_iTarget;

		if(!IsValidEnemy(npc.index, target))
		{
			// Cancel the attack
			npc.m_flAttackHappens = 0.0;
			npc.m_flReloadDelay = 0.0;
			npc.m_flNextMeleeAttack = 0.0;
			npc.RemoveGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
		}
		else if(npc.m_flAttackHappens < gameTime)
		{
			float vecTarget[3];
			WorldSpaceCenter(target, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			
			npc.DealDamage(target, _, DMG_CLUB, _, vecTarget);
			npc.PlayMeleeHitSound();
			
			npc.m_flAttackHappens = 0.0;
		}
	}
	else if(target > 0)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(npc.InAttackRange(target, MELEE_RANGE_SQR))
			{
				npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
				npc.PlayMeleeSound();
				npc.m_iTarget = target;

				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flReloadDelay = gameTime + 0.45;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}

		npc.PlayIdleAlertSound();
	}
	else
	{
		npc.PlayIdleSound();
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
