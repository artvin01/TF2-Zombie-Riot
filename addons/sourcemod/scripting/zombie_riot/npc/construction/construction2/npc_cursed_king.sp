#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};
static const char g_chimeraSuperSlash[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
	"weapons/vaccinator_charge_tier_02.wav",
	"weapons/vaccinator_charge_tier_03.wav",
	"weapons/vaccinator_charge_tier_04.wav",
};

static const char g_HurtSounds[][] =
{
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] =
{
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hit1.wav",
	"weapons/cbar_hit2.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/pickaxe_swing1.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing3.wav"
};
static const char g_MeleeBroke[][] =
{
	"player/taunt_sorcery_staff_break.wav",
};
static const char g_RageOut[][] =
{
	"vo/halloween_boss/knight_laugh01.mp3",
	"vo/halloween_boss/knight_laugh02.mp3",
	"vo/halloween_boss/knight_laugh03.mp3",
	"vo/halloween_boss/knight_laugh04.mp3",
};
static const char g_ExplodeSound[][] =
{
	"weapons/bombinomicon_explode1.wav",
};
void CursedKingOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeBroke);
	PrecacheSoundArray(g_chimeraSuperSlash);
	PrecacheSoundArray(g_RageOut);
	PrecacheSoundArray(g_ExplodeSound);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Cursed King");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_cursed_king");
	strcopy(data.Icon, sizeof(data.Icon), "cursed_king");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CursedKing(vecPos, vecAng, team);
}

methodmap CursedKing < CClotBody
{
	property int m_iAttacksLeft
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property int m_iMiniLivesLost
	{
		public get()
		{
			return this.m_iAttacksTillMegahit;
		}
		public set(int value)
		{
			this.m_iAttacksTillMegahit = value;
		}
	}
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeBroke()
 	{
		EmitSoundToAll(g_MeleeBroke[GetRandomInt(0, sizeof(g_MeleeBroke) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}

	public void PlayRageOut()
 	{
		EmitSoundToAll(g_RageOut[GetRandomInt(0, sizeof(g_RageOut) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
		EmitSoundToAll(g_ExplodeSound[GetRandomInt(0, sizeof(g_ExplodeSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);	
	}
	public void PlayChargeSound()
	{
		EmitSoundToAll(g_chimeraSuperSlash[GetRandomInt(0, sizeof(g_chimeraSuperSlash) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, _);	
	}
	public CursedKing(float vecPos[3], float vecAng[3], int ally)
	{
		CursedKing npc = view_as<CursedKing>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.3", "1000", ally,_,true));
		
		i_NpcWeight[npc.index] = 3;
		npc.SetActivity("ACT_MP_RUN_MELEE");
		KillFeed_SetKillIcon(npc.index, "pickaxe");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ClotTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		npc.m_iMiniLivesLost = 100;
		
		npc.m_flSpeed = 270.0;
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeScaling = 0.0;	//just a safety net
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidAllowsBuildings = true;
		}
		
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 5);
		npc.m_iAttacksLeft = 3;
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_rift_fire_axe/c_rift_fire_axe.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hwn2016_class_crown/hwn2016_class_crown_engineer.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 7511618);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2015_western_beard/hwn2015_western_beard.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable3, 7511618);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/engineer/dec22_underminers_style3/dec22_underminers_style3.mdl");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable4, 7511618);
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/sf14_cursed_cruise/sf14_cursed_cruise_engineer.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable5, 7511618);

		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/engineer/engineer_zombie.mdl");
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", 1);


		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.StartPathing();
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	CursedKing npc = view_as<CursedKing>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	
		
		if(distance < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(target);
		}
		Clot_SelfDefense(npc, distance, vecTarget, gameTime); 
	}

	npc.PlayIdleSound();
}

static void Clot_SelfDefense(CursedKing npc, float distance, float vecTarget[3], float gameTime)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			npc.FaceTowards(vecTarget, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
			{
				int target = TR_GetEntityIndex(swingTrace);
				if(target > 0)
				{
					float damage = 300.0;
					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 10.0;
					}
					npc.PlayMeleeHitSound();
					SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB);
				}
			}

			delete swingTrace;
		}
	}

	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED) && npc.m_flNextMeleeAttack < gameTime)
	{
		int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, target, false, true))
		{
			npc.m_iTarget = target;

			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE",_,_,_, 0.85);
			npc.PlayMeleeSound();
			
			npc.m_flAttackHappens = gameTime + 0.25;
			npc.m_flNextMeleeAttack = gameTime + 0.75;
		}
	}
}
static void ClotDeath(int entity)
{
	CursedKing npc = view_as<CursedKing>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();
	
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
}


static void ClotTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CursedKing npc = view_as<CursedKing>(victim);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	int MaxHealth = ReturnEntityMaxHealth(npc.index);
	int health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth");

	while((float(MaxHealth) * float(npc.m_iMiniLivesLost) * 0.01) > float(health))
	{
		//we lost 1 mini life, try.
		npc.m_iMiniLivesLost--;
		bool ApplyDefaults = false;
		if(!HasSpecificBuff(npc.index, "Ruina's Defense"))
			ApplyDefaults = true;
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Defense", 10.0);
		if(ApplyDefaults)
			NpcStats_RuinaDefenseStengthen(npc.index, 1.0);
		NpcStats_RuinaDefenseStengthen(npc.index, -0.025, true);
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Agility", 10.0);
		if(ApplyDefaults)
			NpcStats_RuinaAgilityStengthen(npc.index, 1.0);	
		NpcStats_RuinaAgilityStengthen(npc.index, 0.05, true);
		ApplyStatusEffect(npc.index, npc.index, "Ruina's Damage", 10.0);
		if(ApplyDefaults)
			NpcStats_RuinaDamageStengthen(npc.index, 1.0);
		NpcStats_RuinaDamageStengthen(npc.index, 0.1, true);
		npc.PlayChargeSound();
		CreateTimer(10.0, Timer_KingRevertTemporaryBuff, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
	}
	if(npc.m_iMiniLivesLost <= 25 && !npc.Anger)
	{
		npc.Anger = true;
		float vecPos[3];
		GetAbsOrigin(npc.index, vecPos);
		vecPos[2] -= 25.0;
		npc.PlayRageOut();
		TE_Particle("mvm_hatch_destroy_smoke", vecPos, NULL_VECTOR, NULL_VECTOR, npc.index, _, _, _, _, _, _, _, _, _, 0.0);
		ApplyStatusEffect(npc.index, npc.index, "Chaos Demon Possession", 999.0);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth / 4);
	}
}

public Action Timer_KingRevertTemporaryBuff(Handle timer, any entid)
{
	int entity = EntRefToEntIndex(entid);
	if(!IsValidEntity(entity))
		return Plugin_Stop;


	NpcStats_RuinaDefenseStengthen(entity, 0.025, true);
	NpcStats_RuinaAgilityStengthen(entity, -0.05, true);
	NpcStats_RuinaDamageStengthen(entity, -0.1, true);

	return Plugin_Stop;
}