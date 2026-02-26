#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSounds[][] =
{
	"vo/taunts/soldier/soldier_taunt_admire_22.mp3",
	"vo/taunts/soldier/soldier_taunt_admire_24.mp3",
	"vo/taunts/soldier/soldier_taunt_admire_26.mp3",
	"vo/taunts/soldier/soldier_taunt_admire_26.mp3",
	"vo/taunts/soldier/soldier_taunt_admire_09.mp3",
};
static const char g_DeathSounds[][] =
{
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3"
};
static const char g_HurtSounds[][] =
{
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};
static const char g_Panic_WeaponBroke[][] =
{
	"vo/soldier_sf12_badmagic07.mp3",
	"vo/soldier_sf12_badmagic05.mp3",
	"vo/soldier_sf12_badmagic14.mp3",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav"
};
static const char g_ReloadSound[][] =
{
	"weapons/rocket_reload.wav",
};
static const char g_MeleeBroke[][] =
{
	"weapons/teleporter_explode.wav",
};

void ContractedMotivatorOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_ReloadSound);
	PrecacheSoundArray(g_MeleeBroke);
	PrecacheSoundArray(g_Panic_WeaponBroke);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Contracted Motivator");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_contracted_motivator");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_backup");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ContractedMotivator(vecPos, vecAng, team);
}

methodmap ContractedMotivator < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 110);
	}
	public void PlayReloadSound()
 	{
		EmitSoundToAll(g_ReloadSound[GetRandomInt(0, sizeof(g_ReloadSound) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeBroke()
 	{
		EmitSoundToAll(g_MeleeBroke[GetRandomInt(0, sizeof(g_MeleeBroke) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
		EmitSoundToAll(g_Panic_WeaponBroke[GetRandomInt(0, sizeof(g_Panic_WeaponBroke) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, _);
	}

	property int m_iAttacksLeft
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property float m_flDelayRapidAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTimeUntillRunAway
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flRunAway
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_fRadiusCD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public ContractedMotivator(float vecPos[3], float vecAng[3], int ally)
	{
		ContractedMotivator npc = view_as<ContractedMotivator>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		KillFeed_SetKillIcon(npc.index, "crossbow");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ContractedMotivator_TakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 220.0;
		npc.m_iAttacksLeft = 3;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec25_scrooge_style3/dec25_scrooge_style3.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_stealth_bomber_style1/sum23_stealth_bomber_style1.mdl");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.StartPathing();
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	ContractedMotivator npc = view_as<ContractedMotivator>(iNPC);

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

	if(npc.m_flRunAway)
	{
		if(npc.m_flRunAway < gameTime)
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			npc.m_flNextThinkTime = gameTime + 9999.9;
			npc.m_flRunAway = 0.0;
		}
		return;
	}
	if(npc.m_flTimeUntillRunAway)
	{
		if(npc.m_flTimeUntillRunAway < gameTime)
		{
			SetEntityRenderFx(npc.index, RENDERFX_FADE_SLOW);
			if(IsValidEntity(npc.m_iWearable2))
				SetEntityRenderFx(npc.m_iWearable2, RENDERFX_FADE_SLOW);
			if(IsValidEntity(npc.m_iWearable3))
				SetEntityRenderFx(npc.m_iWearable3, RENDERFX_FADE_SLOW);
			if(IsValidEntity(npc.m_iWearable4))
				SetEntityRenderFx(npc.m_iWearable4, RENDERFX_FADE_SLOW);
			if(IsValidEntity(npc.m_iWearable5))
				SetEntityRenderFx(npc.m_iWearable5, RENDERFX_FADE_SLOW);

			npc.m_flRunAway = gameTime + 1.0;
			npc.SetActivity("ACT_MP_RUN_LOSERSTATE");
			npc.m_bAllowBackWalking = false;
			float VectorSave[3];
			VectorSave[1] = 1.0;
			TeleportDiversioToRandLocation(npc.index, true, 2000.0, 1000.0, false, false, VectorSave);
			npc.m_bisWalking = true;
			npc.StartPathing();
			npc.SetGoalVector(VectorSave);
		}
		return;
	}
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gameTime)
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	ExpidonsaGroupHeal(npc.index,
	 500.0,
	  99,
	   0.0,
	   1.0,
	    false,
		 ConstractedMotivatorBuffs ,
  		  _,
   		  true);

	if(npc.m_fRadiusCD < gameTime)
	{
		npc.m_fRadiusCD = gameTime + 1.0;
		ContractedMotivatorEffect(npc.index);
	}
	

	if(target > 0)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float distance = GetVectorDistance(vecTarget, VecSelfNpc, true);	

		if(npc.Anger)
		{
			npc.FaceTowards(vecTarget, 7000.0);	
		}
		else
		{
			int MovementDo = ContractedMotivator_SelfDefense(npc, distance, vecTarget, gameTime); 
			switch(MovementDo)
			{
				case 1:
				{
					npc.m_bAllowBackWalking = false;
					if(distance < npc.GetLeadRadius())
					{
						float vPredictedPos[3]; PredictSubjectPosition(npc, target,_,_, vPredictedPos);
						npc.SetGoalVector(vPredictedPos);
					}
					else 
					{
						npc.SetGoalEntity(target);
					}
				}
				case 2:
				{
					//juke them
					npc.m_bAllowBackWalking = true;
					npc.FaceTowards(vecTarget, 350.0);	
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 1);
					npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				}
				case 3:
				{
					npc.m_bAllowBackWalking = true;
					npc.FaceTowards(vecTarget, 350.0);	
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
					npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
					//too close!!!
				}
			}
		}
	}

	npc.PlayIdleSound();
}

int ContractedMotivator_SelfDefense(ContractedMotivator npc, float distance, float vecTarget[3], float gameTime)
{
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0) && npc.m_flNextMeleeAttack < gameTime)
	{
		int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, target, false, true))
		{
			npc.m_iTarget = target;

			npc.m_flNextMeleeAttack = gameTime + 3.0;
			npc.m_flDelayRapidAttack = 1.0;
			npc.m_iAttacksLeft = 3;
		}
	}

	if(npc.m_flDelayRapidAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 15.0))
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_, 0.85);
			npc.PlayMeleeSound();
			npc.m_flDelayRapidAttack = gameTime + 0.25;

			
			float projectile_speed = 1000.0;
			PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed,_,vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);	
			float damage = 40.0;

			npc.FireRocket(vecTarget, damage, projectile_speed);
			npc.m_iAttacksLeft--;
			if(npc.m_iAttacksLeft <= 0)
			{
				npc.PlayReloadSound();
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY",_,_,_, 0.5);
				npc.m_flDelayRapidAttack = 0.0;
			}
		}
	}
	//too far away
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.0))
	{
		return 1;
	}
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			return 3;
		}
		else
		{
			return 1;
		}
	}
	else
	{
		if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
		{
			return 2;
		}
		else
		{
			return 1;
		}
	}
}
static void ClotDeath(int entity)
{
	ContractedMotivator npc = view_as<ContractedMotivator>(entity);
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
}


void ContractedMotivator_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ContractedMotivator npc = view_as<ContractedMotivator>(victim);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!(damagetype & DMG_CLUB))
		return;
	if(npc.Anger)
		return;
	//if dmg too low, dont do it.
	if(float(ReturnEntityMaxHealth(npc.index)) * 0.2 > damage)
		return;
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	//little delay
	npc.m_flHeadshotCooldown = gameTime + 0.8;
	npc.m_blPlayHurtAnimation = false;
		
	npc.m_bisWalking = false;
	npc.Anger = true;
	npc.StopPathing();
	npc.PlayMeleeBroke();
	float flPos[3];
	float flAng[3];
	GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
	flPos[2] -= 40.0;
	TE_ParticleInt(g_particleImpactMetal, damagePosition);
	TE_SendToAllInRange(damagePosition, RangeType_Visibility);
	npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
	npc.m_flTimeUntillRunAway = gameTime + 3.0;
	//break weapon


	//keep them alive to keep spawn limits high?
}

void ContractedMotivatorEffect(int entity)
{
	float ProjectileLoc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
	spawnRing_Vectors(ProjectileLoc, 0.1, 0.0, 0.0, 80.0, "materials/sprites/laserbeam.vmt", 200, 200, 65, 50, 1, 0.25, 5.0, 0.1, 3, 50.0 * 2.0);	
}