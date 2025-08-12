#pragma semicolon 1
#pragma newdecls required
 
static char g_DeathSounds[][] = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
};

static char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
};

static char g_IdleSounds[][] = {
	"npc/zombie_poison/pz_idle2.wav",
	"npc/zombie_poison/pz_idle3.wav",
	"npc/zombie_poison/pz_idle4.wav",
};

static char g_IdleAlertedSounds[][] = {
	"npc/zombie_poison/pz_alert1.wav",
	"npc/zombie_poison/pz_alert2.wav",
};

static char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static char g_MeleeAttackSounds[][] = {
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static float fl_KamikazeInitiate;
public void ZMainPoisonZombie_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/poison.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Z-Main Poison Zombie");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zmain_poisonzombie");
	strcopy(data.Icon, sizeof(data.Icon), "norm_poison_zombie");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Mutation;
	data.Func = ClotSummon;
	fl_KamikazeInitiate = 0.0;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZMainPoisonZombie(vecPos, vecAng, team);
}

methodmap ZMainPoisonZombie < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	
	property float m_flJumpCooldownZmain
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flTryIgnorebuildings
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	
	public ZMainPoisonZombie(float vecPos[3], float vecAng[3], int ally)
	{
		ZMainPoisonZombie npc = view_as<ZMainPoisonZombie>(CClotBody(vecPos, vecAng, "models/zombie/poison.mdl", "1.15", "5000", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		KillFeed_SetKillIcon(npc.index, "infection_heavy");
		

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = 330.0;

		float wave = float(Waves_GetRoundScale()+1); //Wave scaling
		
		wave *= 0.133333;

		npc.m_flWaveScale = wave;

		func_NPCDeath[npc.index] = ZMainPoisonZombie_NPCDeath;
		func_NPCThink[npc.index] = ZMainPoisonZombie_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;
		b_AvoidBuildingsAtAllCosts[npc.index] = true;
		
		npc.StartPathing();
		f_MaxAnimationSpeed[npc.index] = 1.5;
		
		return npc;
	}
	
}


public void ZMainPoisonZombie_ClotThink(int iNPC)
{
	ZMainPoisonZombie npc = view_as<ZMainPoisonZombie>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if(!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}

	// fldistancelimit isnt working for using vector distance, and checking for can see and only buildings	
	int IsAbuildingNearMe = GetClosestTarget(npc.index,false,200.0,_,_,_, _,true, _,true,true,0.0, .ExtraValidityFunction = Zmain_TryJumpOverBuildings);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(i_IsABuilding[npc.m_iTarget] && npc.m_flTryIgnorebuildings > GetGameTime(npc.index))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, .IgnoreBuildings = true);
		}
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		ZMainPoisonZombie_AnnoyingZmainwalkLogic(npc,GetGameTime(npc.index), flDistanceToTarget, IsAbuildingNearMe); 
		ZMainPoisonZombie_SelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
		if(i_IsABuilding[npc.m_iTarget])
		{
			npc.m_iTarget = GetClosestTarget(npc.index, .IgnoreBuildings = true);
			npc.m_flTryIgnorebuildings = GetGameTime(npc.index) + 1.0;
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleSound();
}

void ZMainPoisonZombie_AnnoyingZmainwalkLogic(ZMainPoisonZombie npc, float gameTime, float distance, int IsAbuildingNearMe)
{
	if(npc.m_flTryIgnorebuildings > gameTime || IsValidEntity(IsAbuildingNearMe))
	{
		if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
		{
			if (npc.IsOnGround())
			{
				npc.m_flJumpCooldownZmain = gameTime + 2.0;
				npc.GetLocomotionInterface().Jump();
				float vel[3];
				npc.GetVelocity(vel);
				vel[2] = 400.0;
				npc.SetVelocity(vel);
			}	
		}
	}
	npc.m_bAllowBackWalking = false;
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 10.0))
	{
		if(distance < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		//Just walk.
		return;
	}
	
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 0.5))
	{
		//relatively close, what do ?
		//Randomly jump
		if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
		{
			if (npc.IsOnGround())
			{
				npc.m_flJumpCooldownZmain = gameTime + 2.0;
				npc.GetLocomotionInterface().Jump();
				float vel[3];
				npc.GetVelocity(vel);
				vel[2] = 400.0;
				npc.SetVelocity(vel);
			}	
		}
		
		npc.m_bAllowBackWalking = true;
		float vBackoffPos[3];
		BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 1);
		npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
		return;
	}

	//relatively close, what do ?
	//Randomly jump
	if(!npc.m_flAttackHappens && npc.m_flJumpCooldownZmain < gameTime)
	{
		if (npc.IsOnGround())
		{
			npc.m_flJumpCooldownZmain = gameTime + 2.0;
			npc.GetLocomotionInterface().Jump();
			float vel[3];
			npc.GetVelocity(vel);
			vel[2] = 400.0;
			npc.SetVelocity(vel);
		}	
	}
	float vBackoffPos[3];
	BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos, 2);
	npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
	npc.m_bAllowBackWalking = true;
}

void ZMainPoisonZombie_SelfDefense(ZMainPoisonZombie npc, float gameTime, int target, float distance)
{
	float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
	npc.FaceTowards(VecEnemy, 500.0);
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.5;

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
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MELEE_ATTACK1");
						
				npc.m_flAttackHappens = gameTime + 0.71;
				npc.m_flDoingAnimation = gameTime + 0.71;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}

public void ZMainPoisonZombie_NPCDeath(int entity)
{
	ZMainPoisonZombie npc = view_as<ZMainPoisonZombie>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
}