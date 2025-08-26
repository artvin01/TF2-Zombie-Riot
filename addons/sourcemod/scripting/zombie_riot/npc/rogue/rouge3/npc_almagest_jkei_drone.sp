#pragma semicolon 1
#pragma newdecls required


static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/doom_scout_shotgun.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};


static const char g_PassiveSound[][] = {
	"ambient/nucleus_electricity.wav",
};
static const char g_PassiveSoundNuke[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_loop.wav",
};
static const char g_SentryBusterNukeSoundIntro[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_intro.wav",
};
static const char g_SentryBusterNukeSoundSpin[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav",
};
static const char g_SentryBusterNukeSoundKaboom[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_explode.wav",
};
void JkeiDrone_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_PassiveSound));   i++) { PrecacheSound(g_PassiveSound[i]);   }
	for (int i = 0; i < (sizeof(g_PassiveSoundNuke));   i++) { PrecacheSound(g_PassiveSoundNuke[i]);   }
	for (int i = 0; i < (sizeof(g_SentryBusterNukeSoundIntro));   i++) { PrecacheSound(g_SentryBusterNukeSoundIntro[i]);   }
	for (int i = 0; i < (sizeof(g_SentryBusterNukeSoundSpin));   i++) { PrecacheSound(g_SentryBusterNukeSoundSpin[i]);   }
	for (int i = 0; i < (sizeof(g_SentryBusterNukeSoundKaboom));   i++) { PrecacheSound(g_SentryBusterNukeSoundKaboom[i]);   }
	PrecacheModel("models/bots/demo/bot_sentry_buster.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Jkei Drone");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_jkei_drone");
	strcopy(data.Icon, sizeof(data.Icon), "scout_fan");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return JkeiDrone(vecPos, vecAng, team, data);
}

methodmap JkeiDrone < CClotBody
{

	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 1.0, 70);
	}
	public void PlayPassiveSoundNuke()
	{
		EmitSoundToAll(g_SentryBusterNukeSoundIntro[GetRandomInt(0, sizeof(g_SentryBusterNukeSoundIntro) - 1)], this.index, SNDCHAN_STATIC, 90, _, 0.5, 100);
		EmitSoundToAll(g_PassiveSoundNuke[GetRandomInt(0, sizeof(g_PassiveSoundNuke) - 1)], this.index, SNDCHAN_STATIC, 90, _, 0.6, 100);
	}
	public void PlayIntroNukeSound()
	{
		EmitSoundToAll(g_SentryBusterNukeSoundSpin[GetRandomInt(0, sizeof(g_SentryBusterNukeSoundSpin) - 1)], this.index, SNDCHAN_STATIC, 90, _, 0.6, 100);
		this.StopPassiveSoundNuke();
	}
	public void PlayIntroNukeBoom()
	{
		EmitSoundToAll(g_SentryBusterNukeSoundKaboom[GetRandomInt(0, sizeof(g_SentryBusterNukeSoundKaboom) - 1)], this.index, SNDCHAN_STATIC, 90, _, 0.6, 100);
	}
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	public void StopPassiveSoundNuke()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSoundNuke[GetRandomInt(0, sizeof(g_PassiveSoundNuke) - 1)]);
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSoundNuke[GetRandomInt(0, sizeof(g_PassiveSoundNuke) - 1)]);
	}
	
	
	property float m_flStandStillSometimes
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	
	property float m_flPlaySoundPassive
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flKamikazeDo
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flKamikazeDoing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property int m_iDroneLevelAt
	{
		public get()							{ return i_MedkitAnnoyance[this.index]; }
		public set(int TempValueForProperty) 	{ i_MedkitAnnoyance[this.index] = TempValueForProperty; }
	}
	
	public void PlayMeleeSound(bool AttackFast)
	{
		if(AttackFast)
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 1.0, 140);
		}
		else
		{
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.2);
	}
	
	public JkeiDrone(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		JkeiDrone npc = view_as<JkeiDrone>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_sentry_buster.mdl", "0.65", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		b_TryToAvoidTraverse[npc.index] = true;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;

		Is_a_Medic[npc.index] = true;
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		func_NPCDeath[npc.index] = view_as<Function>(JkeiDrone_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(JkeiDrone_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(JkeiDrone_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 450.0;
		
		
		AddNpcToAliveList(npc.index, 1);
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 0, 0, 0, 255);

		npc.m_flPlaySoundPassive = 1.0;
		float flPos[3], flAng[3];
		npc.m_iWearable2 = npc.EquipItemSeperate("models/props_teaser/saucer.mdl",_,1,0.85, 65.0);
		JkeiDrone npcWearable = view_as<JkeiDrone>(npc.m_iWearable2);
		SetEntityRenderColor(npc.m_iWearable2, 0, 0, 0, 255);
		npcWearable.GetAttachment("", flPos, flAng);
		npc.m_iWearable3 = ParticleEffectAt_Parent(flPos, "unusual_smoking",				npcWearable.index, "", {0.0,0.0,5.0});
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npcWearable.index, "", {0.0,0.0,-5.0});

		npc.m_iWearable5 = Trail_Attach(npc.m_iWearable2, ARROW_TRAIL, 255, 1.0, 30.0, 3.0, 5);
		SetEntityRenderColor(npc.m_iWearable5, 0, 0, 0, 255);
		
		KillFeed_SetKillIcon(npc.index, "purgatory");
		
		return npc;
	}
}

public void JkeiDrone_ClotThink(int iNPC)
{
	JkeiDrone npc = view_as<JkeiDrone>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	if(npc.m_flKamikazeDoing)
	{
		if(npc.m_flKamikazeDoing < GetGameTime(npc.index))
		{
			npc.PlayIntroNukeBoom();
			Explode_Logic_Custom(2000.0, npc.index, npc.index, -1, _, 200.0, _, _, true, 99);
			float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
			TE_Particle("rd_robot_explosion", vecMe, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(npc.m_flPlaySoundPassive)
	{
		npc.PlayPassiveSound();
		npc.m_flPlaySoundPassive = 0.0;
	}
	if(!IsValidEntity(npc.m_iTargetAlly))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	JkeiDrone npcally = view_as<JkeiDrone>(npc.m_iTargetAlly);
	if(npc.m_flKamikazeDo == 1.0)
	{
		//delay sound so you arent ear destroyed
		npc.PlayPassiveSoundNuke();
		npc.m_flKamikazeDo = 2.0;
	}
	if(!npc.m_flKamikazeDo && npcally.m_iDroneLevelAt != npc.m_iDroneLevelAt)
	{
		//kamikazte!!!
		npc.StopPassiveSound();
		npc.m_flKamikazeDo = 1.0;
		npc.m_iTargetWalkTo = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextDelayTime = GetGameTime(npc.index) + GetRandomFloat(0.5, 1.0);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		if(IsValidEntity(npc.m_iWearable2))
			RemoveEntity(npc.m_iWearable2);
		if(IsValidEntity(npc.m_iWearable3))
			RemoveEntity(npc.m_iWearable3);
		if(IsValidEntity(npc.m_iWearable4))
			RemoveEntity(npc.m_iWearable4);
		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	JkeiDrone_DoLaser(iNPC);
	if(IsValidEntity(npc.m_iTargetWalkTo))
	{
		if(npc.m_flStandStillSometimes > GetGameTime(npc.index))
		{
			return;
		}
		npc.m_flStandStillSometimes = GetGameTime(npc.index) + GetRandomFloat(0.5 , 1.0);
		//We have a valid ally, circle them!
	//	CNavArea RandomArea;
		float VecAlly[3];
		PredictSubjectPositionForProjectiles(npc, npc.m_iTargetWalkTo, 300.0, _, VecAlly);
		VecAlly[2] += GetRandomFloat(0.0, 1.0);
		//circumvent potimisation
		VecAlly[1] += GetRandomFloat(-200.0, 200.0);
		VecAlly[0] += GetRandomFloat(-200.0, 200.0);
		static const float maxs[] = { 10.0, 10.0, 10.0 };
		static const float mins[] = { -10.0, -10.0, -10.0 };
		Handle trace;
		float VecSelfNpc[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, VecSelfNpc);
		trace = TR_TraceHullFilterEx(VecSelfNpc, VecAlly,mins,maxs , MASK_NPCSOLID, TraceRayHitWorldOnly);

		if(TR_DidHit(trace))
		{
			TR_GetEndPosition(VecAlly, trace);
			delete trace;
		}
		else
		{
			delete trace;
			VecSelfNpc = VecAlly;
			VecSelfNpc[2] -= 5000.0;
			trace = TR_TraceHullFilterEx(VecAlly, VecSelfNpc,mins,maxs , MASK_NPCSOLID, TraceRayHitWorldOnly);
			if(TR_DidHit(trace))
			{
				TR_GetEndPosition(VecAlly, trace);
				delete trace;
			}
			else
			{
				delete trace;
				return;
			}
		}

		npc.SetGoalVector(VecAlly);
		npc.m_flSpeed = 600.0;
		//spatically walk
		return;
	}

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		//get a random target, not closest.
		int victims;
		int[] victim = new int[MAXENTITIES];

		for (int victimloop = 1; victimloop < MAXENTITIES; victimloop++)
		{
			if(IsValidEnemy(npc.index, victimloop))
				victim[victims++] = victimloop;
		}
		if(victims)
		{
			int winner = victim[GetURandomInt() % victims];
			npc.m_iTarget = winner;
		}
		npc.m_flGetClosestTargetTime = FAR_FUTURE;
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_flSpeed = 380.0;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//Get the normal prediction code.
		if(npc.m_flKamikazeDo && flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			npc.AddActivityViaSequence("taunt04");
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			npc.PlayIntroNukeSound();
			npc.m_flKamikazeDoing = GetGameTime(npc.index) + 2.1;
			return;
		}
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			b_TryToAvoidTraverse[npc.index] = false;
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			vPredictedPos = GetBehindTarget(npc.m_iTarget, 40.0 ,vPredictedPos);
			b_TryToAvoidTraverse[npc.index] = true;
			npc.SetGoalVector(vPredictedPos, true);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
	}
}

public void JkeiDrone_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	JkeiDrone npc = view_as<JkeiDrone>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

public void JkeiDrone_NPCDeath(int entity)
{
	JkeiDrone npc = view_as<JkeiDrone>(entity);
	npc.StopPassiveSound();
	npc.StopPassiveSoundNuke();
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}
void JkeiDrone_DoLaser(int iNpc)
{
	JkeiDrone npc = view_as<JkeiDrone>(iNpc);
	if(npc.m_flKamikazeDo)
		return;
	if(IsValidEntity(npc.m_iTargetAlly))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetAlly, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTargetAlly))
		{
			if(!IsValidEntity(npc.m_iWearable6))
			{
				npc.m_iWearable6 = ConnectWithBeam(npc.m_iTargetAlly, npc.index, 50, 50, 50, 5.0, 5.0, 1.2, LASERBEAM);
			}
			Zero(LaserVarious_HitDetection);
			Handle trace;
			trace = TR_TraceRayFilterEx(VecSelfNpc, vecTarget, 1073741824,RayType_EndPoint,  Sensal_BEAM_TraceUsers, npc.index);
			delete trace;
			float playerPos[3];
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (LaserVarious_HitDetection[victim] && GetTeam(iNpc) != GetTeam(victim))
				{
					float DealDamage = 50.0;
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					if(victim > MaxClients) //make sure barracks units arent bad, they now get targetted too.
						DealDamage *= 0.25;

					SDKHooks_TakeDamage(victim, iNpc, iNpc, DealDamage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
					Elemental_AddChaosDamage(victim, iNpc, RoundToNearest(DealDamage), true, true);
				}
			}
		}
		else
		{
			if(IsValidEntity(npc.m_iWearable6))
			{
				RemoveEntity(npc.m_iWearable6);
			}
		}
	}
}