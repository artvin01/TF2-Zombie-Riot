#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3"
};

static const char g_HurtSound[][] =
{
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3"
};

static const char g_IdleSound[][] =
{
	"vo/spy_stabtaunt01.mp3",
	"vo/spy_stabtaunt02.mp3",
	"vo/spy_stabtaunt03.mp3",
	"vo/spy_stabtaunt04.mp3",
	"vo/spy_stabtaunt05.mp3",
	"vo/spy_stabtaunt06.mp3",
	"vo/spy_stabtaunt07.mp3",
	"vo/spy_stabtaunt08.mp3",
	"vo/spy_stabtaunt09.mp3",
	"vo/spy_stabtaunt10.mp3",
	"vo/spy_stabtaunt11.mp3",
	"vo/spy_stabtaunt12.mp3",
	"vo/spy_stabtaunt13.mp3",
	"vo/spy_stabtaunt14.mp3",
	"vo/spy_stabtaunt15.mp3",
	"vo/spy_stabtaunt16.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/knife_swing.wav"
};

void RookieGambler_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rookie Gambler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_rookiegambler");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return RookieGambler(client, vecPos, vecAng, team);
}

methodmap RookieGambler < CClotBody
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
	public void PlayMeleeHitSound()
 	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public RookieGambler(int client, float vecPos[3], float vecAng[3], int team)
	{
		RookieGambler npc = view_as<RookieGambler>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "300", team));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_STAND_MELEE");
		KillFeed_SetKillIcon(npc.index, "eternal_reward");
		i_NpcWeight[npc.index] = 1;

		npc.m_flAttackHappens = 0.0;
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
			"models/workshop/player/items/all_class/hwn2022_beaten_bruised/hwn2022_beaten_bruised_spy.mdl",
			"models/workshop/player/items/all_class/hwn2022_beaten_bruised_style2/hwn2022_beaten_bruised_style2_spy.mdl",
			"models/workshop/player/items/all_class/hwn2022_beaten_bruised_style3/hwn2022_beaten_bruised_style3_spy.mdl",
			"models/workshop/player/items/all_class/hwn2022_beaten_bruised_style4/hwn2022_beaten_bruised_style4_spy.mdl",
			"models/workshop/player/items/all_class/hwn2022_beaten_bruised_style5/hwn2022_beaten_bruised_style5_spy.mdl"
		};
	
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_eternal_reward/c_eternal_reward.mdl", _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/spy/jul13_classy_royale/jul13_classy_royale.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", RandomHat[GetURandomInt() % sizeof(RandomHat)], _, skin);
		
		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	RookieGambler npc = view_as<RookieGambler>(iNPC);

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
	Npc_Base_Thinking(npc.index, 350.0, "ACT_MP_RUN_MELEE", "ACT_MP_STAND_MELEE", 250.0, gameTime);

	int target = npc.m_iTarget;
	
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, target))
			{
				float vecTarget[3]; 
				WorldSpaceCenter(target, vecTarget);
				npc.FaceTowards(vecTarget, 15000.0);

				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, target))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, CasinoShared_GetDamage(npc, 1.0), DMG_CLUB, _, _, vecHit);
						CasinoShared_RobMoney(npc, target, 5);
						CasinoShared_StealNearbyItems(npc, vecHit);
					}
				}
				delete swingTrace;
			}
		}
	}

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
		npc.SetActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;

		if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.45;
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 1.05;
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	RookieGambler npc = view_as<RookieGambler>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}