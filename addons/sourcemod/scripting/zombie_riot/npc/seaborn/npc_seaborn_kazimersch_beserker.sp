#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeDeflectAttack[][] = {
	"weapons/samurai/tf_katana_impact_object_02.wav",
};


void KazimierzBeserker_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeDeflectAttack));	i++) { PrecacheSound(g_MeleeDeflectAttack[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bloodboil Knightclub Trainee");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_seaborn_kazimersch_beserker");
	strcopy(data.Icon, sizeof(data.Icon), "ds_berserker");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_NORMAL|MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Seaborn;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return KazimierzBeserker(vecPos, vecAng, team);
}

methodmap KazimierzBeserker < CClotBody
{
	property int m_iAlliesDied
	{
		public get()							{ return i_OverlordComboAttack[this.index]; }
		public set(int TempValueForProperty) 	{ i_OverlordComboAttack[this.index] = TempValueForProperty; }
	}
	property int m_iAlliesMaxDeath
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flPercentageAngry
	{
		public get()							{ return fl_Charge_delay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Charge_delay[this.index] = TempValueForProperty; }
	}

	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeflectSound() 
	{
		EmitSoundToAll(g_MeleeDeflectAttack[GetRandomInt(0, sizeof(g_MeleeDeflectAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_MeleeDeflectAttack[GetRandomInt(0, sizeof(g_MeleeDeflectAttack) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
	}	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	
	public KazimierzBeserker(float vecPos[3], float vecAng[3], int ally)
	{
		KazimierzBeserker npc = view_as<KazimierzBeserker>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.75", "70000", ally,_, true));
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_SEABORN_WALK_BESERK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		npc.m_iBleedType = BLEEDTYPE_SEABORN;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_SEABORN;
		
		func_NPCDeath[npc.index] = KazimierzBeserker_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = KazimierzBeserker_OnTakeDamage;
		func_NPCThink[npc.index] = KazimierzBeserker_ClotThink;
		func_NPCDeathForward[npc.index] = KazimierzBeserker_AllyDeath;

		npc.m_iState = 0;
		npc.m_flSpeed = 220.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;

		//how many deaths untill we reach full power?
		float MaxAlliesDeath = 10.0;
		MaxAlliesDeath *= MultiGlobalEnemy;
		npc.m_iAlliesMaxDeath = RoundToCeil(MaxAlliesDeath);

		npc.m_flPercentageAngry = 0.0;
		npc.m_iAlliesDied = 0;

		SetEntityRenderColor(npc.index, 155, 155, 255, 255);		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.1");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderColor(npc.m_iWearable2, 155, 155, 255, 255);
		SetEntityRenderColor(npc.m_iWearable1, 155, 155, 255, 255);

		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void KazimierzBeserker_ClotThink(int iNPC)
{
	KazimierzBeserker npc = view_as<KazimierzBeserker>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	float TrueArmor = 1.0;
	if(npc.m_flPercentageAngry == 1.0)
	{
		TrueArmor *= 0.35;
	}
	else if(npc.m_flPercentageAngry > 0.5)
	{
		TrueArmor *= 0.5;
	}
	fl_TotalArmor[npc.index] = TrueArmor;
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	npc.m_flSpeed = 220.0;
	if(npc.m_flPercentageAngry == 1.0)
	{
		npc.m_flSpeed = 360.0;
	}
	else if(npc.m_flPercentageAngry > 0.5)
	{
		npc.m_flSpeed = 300.0;
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				float TargetVecPos[3]; WorldSpaceCenter(npc.m_iTarget, TargetVecPos);
				npc.FaceTowards(TargetVecPos, 15000.0); 
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					float damage = 100.0;
					
					if(npc.m_flPercentageAngry == 1.0)
					{
						damage *= 3.0;
					}
					else if(npc.m_flPercentageAngry > 0.5)
					{
						damage *= 2.0;
					}

					if(ShouldNpcDealBonusDamage(target))
					{
						damage *= 4.0;
					}

					
					if(target > 0) 
					{
						npc.PlayMeleeHitSound();
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
					}
					Custom_Knockback(npc.index, target, 250.0);
				}
				delete swingTrace;
			}
		}
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.35) && npc.m_flNextMeleeAttack < gameTime)
		{
			npc.m_iState = 1; //Engage in Close Range Destruction.
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_SEABORN_WALK_BESERK");
				}
			}
			case 1:
			{		
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4) 	
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_SEABORN_WALK_BESERK");
				}	

				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				//Can i see This enemy, is something in the way of us?
				//Dont even check if its the same enemy, just engage in killing, and also set our new target to this just in case.
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.AddGesture("ACT_SEABORN_ATTACK_BESERK_1");
					

					npc.PlayMeleeSound();

					npc.m_flAttackHappens = gameTime + 0.35;
					npc.m_flDoingAnimation = gameTime + 0.35;
					npc.m_flNextMeleeAttack = gameTime + 1.5;
					if(npc.m_flPercentageAngry == 1.0)
					{
						npc.m_flNextMeleeAttack = gameTime + 0.65;
					}
					else if(npc.m_flPercentageAngry > 0.5)
					{
						npc.m_flNextMeleeAttack = gameTime + 1.0;
					}
					npc.m_bisWalking = true;
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.PlayIdleAlertSound();
}

public Action KazimierzBeserker_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	KazimierzBeserker npc = view_as<KazimierzBeserker>(victim);
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void KazimierzBeserker_NPCDeath(int entity)
{
	KazimierzBeserker npc = view_as<KazimierzBeserker>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}

public void KazimierzBeserker_AllyDeath(int self, int ally)
{
	KazimierzBeserker npc = view_as<KazimierzBeserker>(self);

	if(GetTeam(ally) != GetTeam(self))
	{
		return;
	}

	float AllyPos[3];
	GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", AllyPos);
	float SelfPos[3];
	GetEntPropVector(self, Prop_Data, "m_vecAbsOrigin", SelfPos);
	float flDistanceToTarget = GetVectorDistance(SelfPos, AllyPos, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 24.0))
	{
		npc.m_iAlliesDied += 1;

		if(npc.m_iAlliesDied >= npc.m_iAlliesMaxDeath)
		{
			npc.m_flPercentageAngry = 1.0;
		}
		else
		{
			npc.m_flPercentageAngry = float(npc.m_iAlliesDied)	/ float(npc.m_iAlliesMaxDeath);
		}

		float flPos[3]; // original
		float flAng[3]; // original
		if(npc.m_flPercentageAngry == 1.0)
		{
			if(IsValidEntity(npc.m_iWearable5))
			{
				RemoveEntity(npc.m_iWearable5);
			}
			if(!IsValidEntity(npc.m_iWearable6))
			{
				npc.GetAttachment("eyes_r", flPos, flAng);
		
				npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "raygun_projectile_red_crit", npc.index, "eyes_r", {0.0,0.0,0.0});
			}
		}
		else if(npc.m_flPercentageAngry > 0.5)
		{
			if(!IsValidEntity(npc.m_iWearable5))
			{
				npc.GetAttachment("eyes_r", flPos, flAng);
		
				npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyes_r", {0.0,0.0,0.0});
			}
		}
	}
}
