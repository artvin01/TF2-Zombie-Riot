#pragma semicolon 1
#pragma newdecls required

static char g_ExplosionSound[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_explode.wav",
};

static char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav",
};

static char g_BustingSound[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav",
};

static char g_IdleSounds[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_loop.wav",
};
static char g_WarningSound[][] = {
	"ambient/rottenburg/tunneldoor_open.wav",
};

static char g_AdminAlert[][] = {
	"vo/mvm_sentry_buster_alerts01.mp3",
	"vo/mvm_sentry_buster_alerts02.mp3",
	"vo/mvm_sentry_buster_alerts03.mp3",
	"vo/mvm_sentry_buster_alerts04.mp3",
	"vo/mvm_sentry_buster_alerts05.mp3",
	"vo/mvm_sentry_buster_alerts06.mp3",
	"vo/mvm_sentry_buster_alerts07.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_loop.wav",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/bottle_hit_flesh1.wav",
	"weapons/bottle_hit_flesh2.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_HeIsAwake[][] = {
	"mvm/sentrybuster/mvm_sentrybuster_intro.wav",
};

public void Temperals_Buster_OnMapStart_NPC()
{
	PrecacheModel("models/bots/demo/bot_sentry_buster.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Anti-Camp Temperal Buster");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_buster_man");
	strcopy(data.Icon, sizeof(data.Icon), "sentry buster");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_ExplosionSound);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_AdminAlert);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_BustingSound);
	PrecacheSoundArray(g_WarningSound);
	PrecacheSoundArray(g_HeIsAwake);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Temperals_Buster(vecPos, vecAng, ally);
}

methodmap Temperals_Buster < CClotBody
{
	property bool b_Busting_Mode
	{
		public get()							{ return b_FUCKYOU[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU[this.index] = TempValueForProperty; }
	}
	property bool b_Busting_Now
	{
		public get()							{ return b_FUCKYOU_move_anim[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FUCKYOU_move_anim[this.index] = TempValueForProperty; }
	}
	property float fl_AnimTime
	{
		public get()							{ return fl_NextChargeSpecialAttack[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextChargeSpecialAttack[this.index] = TempValueForProperty; }
	}
	property float fl_Busting_Time
	{
		public get()							{ return fl_RangedSpecialDelay[this.index]; }
		public set(float TempValueForProperty) 	{ fl_RangedSpecialDelay[this.index] = TempValueForProperty; }
	}
	property int i_PingMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		EmitSoundToAll(g_AdminAlert[GetRandomInt(0, sizeof(g_AdminAlert) - 1)], _, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0);
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(1.0, 1.4);
	}
	public void PlayBustingSound() {
		EmitSoundToAll(g_BustingSound[GetRandomInt(0, sizeof(g_BustingSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayWarningSound() {
		EmitSoundToAll(g_WarningSound[GetRandomInt(0, sizeof(g_WarningSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 90);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayExplosionSound() {
		EmitSoundToAll(g_ExplosionSound[GetRandomInt(0, sizeof(g_ExplosionSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_ExplosionSound[GetRandomInt(0, sizeof(g_ExplosionSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], _, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public Temperals_Buster(float vecPos[3], float vecAng[3], int ally)
	{
		Temperals_Buster npc = view_as<Temperals_Buster>(CClotBody(vecPos, vecAng, "models/bots/demo/bot_sentry_buster.mdl", "1.0", "3000", ally, false));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;

		npc.b_Busting_Mode = false;
		npc.b_Busting_Now = false;
		npc.i_PingMode = 0;
		npc.fl_Busting_Time = GetGameTime(npc.index) + 10.0;

		npc.PlayHeIsAwake();
		
		npc.m_flSpeed = 300.0;
		func_NPCDeath[npc.index] = Temperals_Buster_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		func_NPCThink[npc.index] = Temperals_Buster_ClotThink;
		
		SetEntityRenderColor(npc.index, 106, 168, 79, 255);
		
		npc.StartPathing();
		npc.PlayIdleSound();

		return npc;
	}
}

static void Temperals_Buster_ClotThink(int iNPC)
{
	Temperals_Buster npc = view_as<Temperals_Buster>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	float TotalArmor = 1.0;

	if(npc.fl_AnimTime >= gameTime)
		TotalArmor *= 0.3;

	fl_TotalArmor[npc.index] = TotalArmor;

	if(npc.fl_AnimTime)
	{
		if(npc.fl_AnimTime <= gameTime)
		{
			npc.i_PingMode++;
			if(npc.i_PingMode <= 12)
			{
				npc.fl_AnimTime = gameTime + BustingTime(npc);
				if(npc.i_PingMode <= 10)
				{
					npc.PlayWarningSound();
					npc.AddActivityViaSequence("taunt04");
				}
				else if(npc.i_PingMode == 11)
				{
					npc.PlayBustingSound();
				}
			}
			else
			{
				Buster_ExplosionAttack(npc);
				npc.i_PingMode = 0;
				npc.fl_AnimTime = 0.0;
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}
		return;
	}
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
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
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();

		npc.StartPathing();
	}

	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}

		if(npc.fl_Busting_Time)
		{
			if(npc.fl_Busting_Time <= gameTime)
			{
				npc.b_Busting_Mode = true;
				npc.fl_Busting_Time = 0.0;
			}
		}

		if(!npc.b_Busting_Mode)
		{
			Buster_SelfDefense(npc, gameTime, closest, flDistanceToTarget);
		}
		else
		{
			if(Can_I_See_Enemy(npc.index, closest))
			{
				if(flDistanceToTarget <= NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.9)
				{
					npc.b_Busting_Now = true;
					npc.fl_AnimTime = gameTime + 0.1;
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
}

static float BustingTime(Temperals_Buster npc)
{
	float value = 0.8;
	switch(npc.i_PingMode)
	{
		case 1:
		{
			value = 0.7;
		}
		case 2:
		{
			value = 0.6;
		}
		case 3:
		{
			value = 0.5;
		}
		case 4, 5, 6:
		{
			value = 0.4;
		}
		case 7, 8, 9:
		{
			value = 0.3;
		}
		case 10, 11:
		{
			value = 0.2;
		}
		case 12:
		{
			value = 0.9;
		}
	}
	return value;
}

static void Buster_ExplosionAttack(Temperals_Buster npc)
{
	float Loc[3];
	float damage = 2000.0, radius = 350.0;
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);
	Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
	ParticleEffectAt(Loc, "hightower_explosion", 0.1);
	spawnRing_Vectors(Loc, 350.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 40, 160, 255, 200, 1, /*duration*/ 0.1, 5.0, 0.0, 1);
	spawnRing_Vectors(Loc, 350.0 * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 220, 40, 160, 200, 1, /*duration*/ 0.15, 5.0, 1.0, 1, 150.0);
}

static void Buster_SelfDefense(Temperals_Buster npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAttackHappens)
	{
		if (npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			Handle swingTrace;
			float vecTarget[3]; WorldSpaceCenter(target, vecTarget);

			npc.FaceTowards(vecTarget, 20000.0);
			if(npc.DoSwingTrace(swingTrace, target))
			{
				target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(IsValidEnemy(npc.index, target))
				{
					float damage = 130.0;
					float radius = 160.0;
					if(target > 0) 
					{
						//SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						
						WorldSpaceCenter(target, vecTarget);
						Explode_Logic_Custom(damage, npc.index, npc.index, -1, _, radius, _, _, true);
						ParticleEffectAt(vecTarget, "drg_cow_explosioncore_charged_blue", 0.5);
						// Hit sound
						//npc.PlayMeleeHitSound();
						npc.PlayExplosionSound();
					}
					else
					{
						npc.PlayMeleeMissSound();
					}
				}
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, target);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				npc.PlayMeleeSound();
				bool rng = view_as<bool>(GetRandomInt(0, 1));
				npc.AddGesture(rng ? "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS" : "ACT_MP_ATTACK_STAND_MELEE");
				npc.m_flAttackHappens = gameTime + 0.3;
				float attack = GetRandomFloat(0.6, 1.2);
				npc.m_flNextMeleeAttack = gameTime + attack;
			}
		}
	}
}

static void Temperals_Buster_NPCDeath(int entity)
{
	Temperals_Buster npc = view_as<Temperals_Buster>(entity);
	
	npc.PlayDeathSound();
	for(int i ; i <= 4 ; i++)
	{
		StopSound(entity, SNDCHAN_STATIC, "mvm/sentrybuster/mvm_sentrybuster_loop.wav");
	}
	
}