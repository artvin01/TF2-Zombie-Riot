#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static const char g_HurtSounds[][] = {
	"music/mvm_class_menu_01.wav",
	"music/mvm_class_menu_02.wav",
	"music/mvm_class_menu_03.wav",
	"music/mvm_class_menu_04.wav",
	"music/mvm_class_menu_05.wav",
	"music/mvm_class_menu_06.wav",
	"music/mvm_class_menu_07.wav",
	"music/mvm_class_menu_08.wav",
	"music/mvm_class_menu_09.wav",
};
static const char g_IdleAlertedSounds[][] = {
	"misc/flame_engulf.wav",
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

void Antiviral_Program_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Anti Viral Programm");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_antiviral_programm");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Matrix;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Antiviral_Program(vecPos, vecAng, team);
}

methodmap Antiviral_Program < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_WEAPON, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 70);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	property float m_flSuicideTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	
	public Antiviral_Program(float vecPos[3], float vecAng[3], int ally)
	{
		Antiviral_Program npc = view_as<Antiviral_Program>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", MinibossHealthScaling(220.0, true), ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_ITEM1");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		npc.m_flSuicideTimer = GetGameTime() + 50.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.m_iOverlordComboAttack = 2;
		npc.m_iChanged_WalkCycle = 1;
		Is_a_Medic[npc.index] = true;
		ApplyStatusEffect(npc.index, npc.index, "Intangible", 999999.0);
		f_CheckIfStuckPlayerDelay[npc.index] = FAR_FUTURE, //She CANT stuck you, so dont make players not unstuck in cant bve stuck ? what ?
		b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions

		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;

		b_DoNotUnStuck[npc.index] = true;

		npc.m_bDissapearOnDeath = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		TE_SetupParticleEffect("utaunt_cremation_black_parent", PATTACH_ABSORIGIN_FOLLOW, npc.index);
		TE_WriteNum("m_bControlPoint1", npc.index);	
		TE_SendToAll();
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		ApplyStatusEffect(npc.index, npc.index, "Challenger", 99999999.0);

		func_NPCDeath[npc.index] = view_as<Function>(Antiviral_Program_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Antiviral_Program_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Antiviral_Program_ClotThink);
		
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/sum23_brothers_blues/sum23_brothers_blues_spy.mdl");
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 7511618);
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		
		SetEntityRenderColor(npc.index, 0, 125, 0, 185);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderFx(npc.index,		 RENDERFX_DISTORT);
		
		KillFeed_SetKillIcon(npc.index, "purgatory");
		
		return npc;
	}
}

public void Antiviral_Program_ClotThink(int iNPC)
{
	Antiviral_Program npc = view_as<Antiviral_Program>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flSuicideTimer < GetGameTime(npc.index))
	{
		RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		return;
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = Antiviral_ProgramSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
		}
	}
	else
	{
		npc.m_flSuicideTimer = 0.0;
	}
	npc.PlayIdleAlertSound();
}

public void Antiviral_Program_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Antiviral_Program npc = view_as<Antiviral_Program>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}

public void Antiviral_Program_NPCDeath(int entity)
{
	Antiviral_Program npc = view_as<Antiviral_Program>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	
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

int Antiviral_ProgramSelfDefense(Antiviral_Program npc, float gameTime, int target, float distance)
{

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _,_,_,_, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 130.0;
					damageDealt *= npc.m_flWaveScale;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
			{
				npc.PlayMeleeSound(false);
				npc.AddGesture("ACT_MP_ATTACK_STAND_ITEM1");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}		
	return 0;
}
