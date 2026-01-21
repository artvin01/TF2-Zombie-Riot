#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav",
};

static const char g_HurtSounds[][] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/quake_rpg_fire_remastered.wav",
};

void ChaosGunmenOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chaos Gunman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_gunmen");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosGunmen(vecPos, vecAng, team);
}

methodmap ChaosGunmen < CClotBody
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
	
	public ChaosGunmen(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosGunmen npc = view_as<ChaosGunmen>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_OSMAN_WALK");
		KillFeed_SetKillIcon(npc.index, "crossbow");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		Elemental_AddChaosDamage(npc.index, npc.index, 1, false);		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ChaosGunmen_TakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		fl_TotalArmor[npc.index] = 0.25;
		
		npc.m_flSpeed = 220.0;
		npc.m_iAttacksLeft = 3;

		float flPos[3], flAng[3];
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/player/items/spy/mbsf_spy.mdl",_,_,1.25);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 16777215);
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_bet_rocketlauncher/c_bet_rocketlauncher.mdl");
				
		npc.GetAttachment("eyes", flPos, flAng);
		npc.m_iWearable4 = ParticleEffectAt_Parent(flPos, "unusual_smoking", npc.index, "eyes", {0.0,0.0,0.0});
		npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "unusual_psychic_eye_white_glow", npc.index, "eyes", {0.0,0.0,-15.0});
		npc.StartPathing();
		SetEntityRenderColor(npc.index, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable1, 150, 150, 150, 255);
		SetEntityRenderColor(npc.m_iWearable2, 150, 150, 150, 255);
		return npc;
	}
}

static void ClotThink(int iNPC)
{
	ChaosGunmen npc = view_as<ChaosGunmen>(iNPC);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
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
		int MovementDo = ChaosGunmen_SelfDefense(npc, distance, vecTarget, gameTime); 
		
		if(npc.m_flDelayRapidAttack)
		{
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
			if(npc.m_flDelayRapidAttack > gameTime)
				npc.FaceTowards(vecTarget, 350.0);	
		}
		else
		{
			npc.StartPathing();
			npc.m_flSpeed = 220.0;
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
					npc.m_flSpeed = 110.0;
					//juke them
					npc.m_bAllowBackWalking = true;
					npc.FaceTowards(vecTarget, 350.0);	
					float vBackoffPos[3];
					BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 1);
					npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
				}
				case 3:
				{
					npc.m_flSpeed = 110.0;
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

int ChaosGunmen_SelfDefense(ChaosGunmen npc, float distance, float vecTarget[3], float gameTime)
{
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0) && npc.m_flNextMeleeAttack < gameTime)
	{
		int target = Can_I_See_Enemy(npc.index, npc.m_iTarget);
		if(IsValidEnemy(npc.index, target, false, true))
		{
			npc.m_iTarget = target;

			npc.m_flNextMeleeAttack = gameTime + 5.0;
			npc.AddGesture("ACT_OSMAN_ATTACK_BARRAGE", _ ,_,_, 1.25);
			npc.m_flDelayRapidAttack = gameTime + 0.75;
			npc.m_iAttacksLeft = 5;
		}
	}

	if(npc.m_flDelayRapidAttack && npc.m_flDelayRapidAttack < gameTime)
	{
		npc.PlayMeleeSound();
		npc.m_flDelayRapidAttack = gameTime + 0.15;

		
		float projectile_speed = 1500.0;
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
		{
			PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed,_,vecTarget);
		}
		npc.FaceTowards(vecTarget, 30000.0);	
		float damage = 140.0;

		int arrow = npc.FireArrow(vecTarget, damage, projectile_speed, "models/weapons/w_bullet.mdl", 2.0);	

		int	trail = Trail_Attach(arrow, ARROW_TRAIL, 255, 0.3, 3.0, 3.0, 5);
				
		f_ArrowTrailParticle[arrow] = EntIndexToEntRef(trail);
		CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);

		npc.m_iAttacksLeft--;
		if(npc.m_iAttacksLeft <= 0)
		{
			npc.m_flDelayRapidAttack = 0.0;
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
	ChaosGunmen npc = view_as<ChaosGunmen>(entity);
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


void ChaosGunmen_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosGunmen npc = view_as<ChaosGunmen>(victim);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}