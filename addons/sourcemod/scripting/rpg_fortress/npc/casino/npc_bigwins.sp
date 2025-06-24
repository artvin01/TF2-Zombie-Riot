#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] =
{
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3"
};

static const char g_HurtSound[][] =
{
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3"
};

static const char g_IdleSound[][] =
{
	"vo/demoman_mvm_resurrect05.mp3",
	"vo/compmode/cm_demo_pregamefirst_rare_01.mp3",
	"vo/compmode/cm_demo_pregamefirst_comp_03.mp3",
	"vo/demoman_gibberish12.mp3",
	"vo/compmode/cm_demo_rankup_highest_01.mp3",
	"vo/compmode/cm_demo_pregamefirst_04.mp3"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/pan/melee_frying_pan_01.wav",
	"weapons/pan/melee_frying_pan_02.wav",
	"weapons/pan/melee_frying_pan_03.wav",
	"weapons/pan/melee_frying_pan_04.wav"
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav"
};

void BigWins_Setup()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSound);
	PrecacheSoundArray(g_IdleSound);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Big Wins");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bigwins");
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return BigWins(client, vecPos, vecAng, team);
}

methodmap BigWins < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;

		EmitSoundToAll(g_IdleSound[GetURandomInt() % sizeof(g_IdleSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetURandomInt() % sizeof(g_HurtSound)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetURandomInt() % sizeof(g_DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
 	{
		EmitSoundToAll(g_MeleeHitSounds[GetURandomInt() % sizeof(g_MeleeHitSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetURandomInt() % sizeof(g_MeleeAttackSounds)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public BigWins(int client, float vecPos[3], float vecAng[3], int team)
	{
		BigWins npc = view_as<BigWins>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.3", "300", team, false, true));

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		npc.SetActivity("ACT_MP_STAND_MELEE_ALLCLASS");
		KillFeed_SetKillIcon(npc.index, "frying_pan");
		i_NpcWeight[npc.index] = 3;

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

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_frying_pan/c_frying_pan.mdl", _, skin + 2);
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/all_class/treasure_hat_02_demo.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/demo/demo_chest_front.mdl", _, skin);
		
		return npc;
	}
	
}

static void ClotThink(int iNPC)
{
	BigWins npc = view_as<BigWins>(iNPC);

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
	Npc_Base_Thinking(npc.index, 350.0, "ACT_MP_RUN_MELEE_ALLCLASS", "ACT_MP_STAND_MELEE_ALLCLASS", 290.0, gameTime);

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
				if(npc.DoSwingTrace(swingTrace, target, .Npc_type = 1))
				{
					target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);

					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, CasinoShared_GetDamage(npc, 3.0), DMG_CLUB, _, _, vecHit);
						CasinoShared_RobMoney(npc, target, 50);
						CasinoShared_StealNearbyItems(npc, vecHit);
						Custom_Knockback(npc.index, target, 2000.0);

						if(target <= MaxClients)
							Client_Shake(target, 0, 35.0, 20.0, 0.8);
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
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		npc.m_bisWalking = true;

		if(distance < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;

				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", _, _, _, 0.5);
				npc.PlayMeleeSound();
				
				npc.m_flAttackHappens = gameTime + 0.75;
				npc.m_flDoingAnimation = gameTime + 1.0;
				npc.m_flNextMeleeAttack = gameTime + 2.05;
			}
		}
	}

	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	BigWins npc = view_as<BigWins>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
}