#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3"
};

static const char g_HurtSound[][] =
{
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3"
};

static const char g_IdleSound[][] =
{
	"vo/engineer_mvm_collect_credits01.mp3",
	"vo/engineer_mvm_collect_credits02.mp3",
	"vo/engineer_mvm_collect_credits03.mp3"
};

static const char g_RangeMisfireSounds[][] =
{
	"weapons/shotgun_empty.wav"
};

static const char g_RangeAttackSounds[][] =
{
	"weapons/shotgun_shoot.wav"
};

void BuckshotGambler_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_RangeMisfireSounds);
	PrecacheSoundArray(g_RangeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Buckshot Gambler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_buckshotgambler");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return BuckshotGambler(client, vecPos, vecAng, team);
}

methodmap BuckshotGambler < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetURandomInt() % sizeof(g_IdleSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetURandomInt() % sizeof(g_HurtSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMisfireSound()
 	{
		EmitSoundToAll(g_RangeMisfireSounds[GetURandomInt() % sizeof(g_RangeMisfireSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangeSound()
 	{
		EmitSoundToAll(g_RangeAttackSounds[GetURandomInt() % sizeof(g_RangeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public BuckshotGambler(int client, float vecPos[3], float vecAng[3], int team)
	{
		BuckshotGambler npc = view_as<BuckshotGambler>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_STAND_PRIMARY");
		KillFeed_SetKillIcon(npc.index, "headshot");
		i_NpcWeight[npc.index] = 1;

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		f3_SpawnPosition[npc.index] = vecPos;

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		int skin = GetURandomInt() % 2;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		static const char RandomHat[][] =
		{
			"models/workshop/player/items/engineer/dec23_clue_hairdo/dec23_clue_hairdo.mdl",
			"models/workshop/player/items/engineer/dec23_clue_hairdo_style2/dec23_clue_hairdo_style2.mdl",
			"models/workshop/player/items/engineer/dec23_clue_hairdo_style3/dec23_clue_hairdo_style3.mdl"
		};
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_shotgun/c_shotgun.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/invasion_life_support_system/invasion_life_support_system.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", RandomHat[GetURandomInt() % sizeof(RandomHat)], _, skin);
		
		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	BuckshotGambler npc = view_as<BuckshotGambler>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		if(npc.m_flDoingAnimation < gameTime)
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
		
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// npc.m_iTarget comes from here, This only handles out of battle instancnes, for inbattle, code it yourself. It also makes NPCS jump if youre too high up.
	Npc_Base_Thinking(npc.index, 350.0, "ACT_MP_RUN_PRIMARY", "ACT_MP_STAND_PRIMARY", 260.0, gameTime);

	int target = npc.m_iTarget;
	
	if(target > 0)
	{
		float vecMe[3], vecTarget[3];
		WorldSpaceCenter(npc.index, vecMe);
		WorldSpaceCenter(target, vecTarget);

		float distance = GetVectorDistance(vecTarget, vecMe, true);
		
		if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, target, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(target);
		}

		npc.StartPathing();
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		npc.m_bisWalking = true;

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 1.05;

				npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
				npc.FaceTowards(vecTarget, 15000.0);

				if(GetURandomInt() % 3)
				{
					npc.PlayMisfireSound();
				}
				else
				{
					npc.PlayRangeSound();
					SDKHooks_TakeDamage(target, npc.index, npc.index, CasinoShared_GetDamage(npc, 3.0), DMG_BULLET, _, _, vecTarget);
				}
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	BuckshotGambler npc = view_as<BuckshotGambler>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}