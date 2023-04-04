#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3"
};

static char g_HurtSounds[][] =
{
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static char g_RangedAttackSounds[][] =
{
	"weapons/sniper_railgun_single_01.wav",
	"weapons/sniper_railgun_single_02.wav"
};

static char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static char g_SMGAttackSounds[][] =
{
	"weapons/doom_sniper_smg.wav"
};

static char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static char g_AngerSounds[][] =
{
	"vo/taunts/sniper_taunts05.mp3",
	"vo/taunts/sniper_taunts06.mp3",
	"vo/taunts/sniper_taunts08.mp3",
	"vo/taunts/sniper_taunts11.mp3",
	"vo/taunts/sniper_taunts12.mp3",
	"vo/taunts/sniper_taunts14.mp3"
};

static char g_HappySounds[][] =
{
	"vo/taunts/sniper/sniper_taunt_admire_02.mp3",
	"vo/compmode/cm_sniper_pregamefirst_6s_05.mp3",
	"vo/compmode/cm_sniper_matchwon_02.mp3",
	"vo/compmode/cm_sniper_matchwon_07.mp3",
	"vo/compmode/cm_sniper_matchwon_10.mp3",
	"vo/compmode/cm_sniper_matchwon_11.mp3",
	"vo/compmode/cm_sniper_matchwon_14.mp3"
};

void RaidbossNemesis_OnMapStart()
{
	PrecacheModel("models/zombie_riot/bosses/nemesis_ft1_v2.mdl");
}

methodmap RaidbossNemesis < CClotBody
{
	public void PlayHurtSound()
	{
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll(g_SMGAttackSounds[GetRandomInt(0, sizeof(g_SMGAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSpecialSound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevengeSound()
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "vo/sniper_revenge%02d.mp3", (GetURandomInt() % 25) + 1);
		EmitSoundToAll(buffer, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHappySound()
	{
		EmitSoundToAll(g_HappySounds[GetRandomInt(0, sizeof(g_HappySounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public RaidbossNemesis(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossNemesis npc = view_as<RaidbossNemesis>(CClotBody(vecPos, vecAng, "models/zombie_riot/bosses/nemesis_ft1_v2.mdl", "1.75", "25000", ally, false, true, true,true)); //giant!
		
		//model originally from Roach, https://steamcommunity.com/sharedfiles/filedetails/?id=2053348633&searchtext=nemesis

		//wave 75 xeno raidboss,should be extreamly hard, but still fair, that will be hard to do.

		i_NpcInternalId[npc.index] = XENO_RAIDBOSS_NEMESIS;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_FT2_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SDKHook(npc.index, SDKHook_Think, RaidbossNemesis_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamage, RaidbossNemesis_ClotDamaged);
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidModeTime = GetGameTime(npc.index) + 200.0;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 300.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		Citizen_MiniBossSpawn(npc.index);
		npc.StartPathing();
		return npc;
	}
}

public void RaidbossNemesis_ClotThink(int iNPC)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, RaidbossNemesis_ClotThink);
	}

	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			if(npc.m_flDoingAnimation > GetGameTime(npc.index))
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
					float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
					if(flDistanceToTarget < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 1.50, 2.0))
					{
						//the enemy is still close, do another attack.
						float flPos[3]; // original
						float flAng[3]; // original
						npc.GetAttachment("tag_ragdoll", flPos, flAng);
						if(IsValidEntity(npc.m_iWearable5))
							RemoveEntity(npc.m_iWearable5);
					
						npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_blue", 2.5);
						TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
						SetParent(npc.index, npc.m_iWearable5, "tag_ragdoll");
						npc.m_flAttackHappens = gameTime + 2.5;
						npc.m_flDoingAnimation = gameTime + 2.5;

						if(npc.m_iChanged_WalkCycle != 3) 	
						{
							int iActivity = npc.LookupActivity("ACT_FT2_ATTACK_2");
							if(iActivity > 0) npc.StartActivity(iActivity);
							npc.m_iChanged_WalkCycle = 3;
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
							PF_StopPathing(npc.index);
						}
					}
					else
					{
						npc.m_flAttackHappens = gameTime + 1.0;
					}
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					int iActivity = npc.LookupActivity("ACT_FT2_WALK");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 300.0;
					npc.StartPathing();
				}
				npc.m_flAttackHappens = 0.0;
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			PF_SetGoalVector(npc.index, vPredictedPos);
		} 
		else 
		{
			PF_SetGoalEntity(npc.index, npc.m_iTarget);
		}


		int ActionToTake = -1;

		if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(flDistanceToTarget < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 1.50, 2.0) && npc.m_flNextMeleeAttack < GetGameTime(npc.index))
		{
			ActionToTake = 1;
		}

		/*
		TODO:
		If didnt attack for abit, sprints and grabs someone
		Can dodge projetiles and then equip rocket launcher to retaliate
		Same with minigun, its random what he chooses
		During any melee animation he does, he will ggain 50% ranged resistance
		Make him instantly crush any NPC enemy basically, mainly aoe attacks only
		all his attacks will be aoe and dodgeable easily

		Main threat is trying to do massive damage to him and taking him down before the timer runs out, being too greedy kill you, being too safe makes you lose with a timer.
		Most effective way is backstabbing during melee attacks.
		*/


		switch(ActionToTake)
		{
			case 1:
			{
				npc.m_flNextMeleeAttack = gameTime + 5.0;
				npc.m_flDoingAnimation = gameTime + 2.2;
				npc.m_flAttackHappens = gameTime + 1.25;
				float flPos[3]; // original
				float flAng[3]; // original
				npc.GetAttachment("tag_ragdoll", flPos, flAng);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 1.0);
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				SetParent(npc.index, npc.m_iWearable5, "tag_ragdoll");

				if(npc.m_iChanged_WalkCycle != 1) 	
				{
					int iActivity = npc.LookupActivity("ACT_FT2_ATTACK_1");
					if(iActivity > 0) npc.StartActivity(iActivity);
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					PF_StopPathing(npc.index);
				}
			}
		}
	}
	else
	{
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

	
public Action RaidbossNemesis_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	RaidbossNemesis npc = view_as<RaidbossNemesis>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void RaidbossNemesis_NPCDeath(int entity)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(npc.index, SDKHook_Think, RaidbossNemesis_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, RaidbossNemesis_ClotDamaged);
	
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
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	Citizen_MiniBossDeath(entity);
}