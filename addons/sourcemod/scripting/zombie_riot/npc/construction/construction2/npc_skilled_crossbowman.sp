#pragma semicolon 1
#pragma newdecls required


static const char g_IdleAlertedSounds[][] =
{
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};
static const char g_Panic_WeaponBroke[][] =
{
	"vo/medic_sf12_badmagic08.mp3",
	"vo/medic_sf12_badmagic07.mp3",
	"vo/medic_sf12_badmagic10.mp3",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/crossbow/fire1.wav",
};
static const char g_ReloadSound[][] =
{
	"weapons/crossbow/bolt_load1.wav",
	"weapons/crossbow/bolt_load2.wav",
};
static const char g_MeleeBroke[][] =
{
	"weapons/teleporter_explode.wav",
};

void SkilledCrossbowmanOnMapStart()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_ReloadSound);
	PrecacheSoundArray(g_MeleeBroke);
	PrecacheSoundArray(g_Panic_WeaponBroke);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Skilled Crossbowman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_skilled_crossbowman");
	strcopy(data.Icon, sizeof(data.Icon), "crossbow");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return SkilledCrossbowman(vecPos, vecAng, team);
}

methodmap SkilledCrossbowman < CClotBody
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
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
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
	
	public SkilledCrossbowman(float vecPos[3], float vecAng[3], int ally)
	{
		SkilledCrossbowman npc = view_as<SkilledCrossbowman>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_MP_RUN_PRIMARY");
		KillFeed_SetKillIcon(npc.index, "crossbow");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = SkilledCrossbowman_TakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		
		npc.m_flSpeed = 220.0;
		npc.m_iAttacksLeft = 3;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/zombie_riot/weapons/custom_weaponry_1_52.mdl",_,_, 1.5);
		SetVariantInt(4);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/engineer/hwn2024_delldozer_style3/hwn2024_delldozer_style3.mdl");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec25_cardiologists_cardigan/dec25_cardiologists_cardigan.mdl");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.StartPathing();
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	SkilledCrossbowman npc = view_as<SkilledCrossbowman>(iNPC);

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
			int MovementDo = SkilledCrossbowman_SelfDefense(npc, distance, vecTarget, gameTime); 
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

int SkilledCrossbowman_SelfDefense(SkilledCrossbowman npc, float distance, float vecTarget[3], float gameTime)
{
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) && npc.m_flNextMeleeAttack < gameTime)
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
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY",_,_,_, 0.85);
			npc.PlayMeleeSound();
			npc.m_flDelayRapidAttack = gameTime + 0.25;

			
			float projectile_speed = 1500.0;
			PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed,_,vecTarget);
			npc.FaceTowards(vecTarget, 30000.0);	
			float damage = 70.0;

			npc.FireArrow(vecTarget, damage, projectile_speed);
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
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
	{
		return 1;
	}
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
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
	SkilledCrossbowman npc = view_as<SkilledCrossbowman>(entity);
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


void SkilledCrossbowman_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SkilledCrossbowman npc = view_as<SkilledCrossbowman>(victim);
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