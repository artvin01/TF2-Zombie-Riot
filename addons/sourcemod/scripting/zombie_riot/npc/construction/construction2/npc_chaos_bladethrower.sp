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
	"weapons/cleaver_throw.wav",
};

void ChaosBladeThrowerOnMapStart()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheModel("models/props_junk/sawblade001a.mdl");
	NPCData data; 
	strcopy(data.Name, sizeof(data.Name), "Chaos Blade Thrower");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chaos_blade_thrower");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = 0;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChaosBladeThrower(vecPos, vecAng, team);
}

methodmap ChaosBladeThrower < CClotBody
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
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
	
	public ChaosBladeThrower(float vecPos[3], float vecAng[3], int ally)
	{
		ChaosBladeThrower npc = view_as<ChaosBladeThrower>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1000", ally));
		
		i_NpcWeight[npc.index] = 1;
		npc.SetActivity("ACT_CHAKRAM_WALK");
		KillFeed_SetKillIcon(npc.index, "crossbow");
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		Elemental_AddChaosDamage(npc.index, npc.index, 1, false);		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;
		

		func_NPCDeath[npc.index] = ClotDeath;
		func_NPCOnTakeDamage[npc.index] = ChaosBladeThrower_TakeDamage;
		func_NPCThink[npc.index] = ClotThink;
		fl_TotalArmor[npc.index] = 0.25;
		
		npc.m_flSpeed = 220.0;
		npc.m_iAttacksLeft = 3;

		float flPos[3], flAng[3];
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/player/items/engineer/mbsf_engineer.mdl",_,_,1.25);
		NpcColourCosmetic_ViaPaint(npc.m_iWearable1, 16777215);
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_prinny_knife/c_prinny_knife.mdl",_,_,1.25);
				
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
	ChaosBladeThrower npc = view_as<ChaosBladeThrower>(iNPC);

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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
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
		ChaosBladeThrowerSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	npc.PlayIdleSound();
}

static void ClotDeath(int entity)
{
	ChaosBladeThrower npc = view_as<ChaosBladeThrower>(entity);
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


void ChaosBladeThrower_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChaosBladeThrower npc = view_as<ChaosBladeThrower>(victim);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
}


void ChaosBladeThrowerSelfDefense(ChaosBladeThrower npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget );
		
		npc.FaceTowards(vecTarget, 15000.0);
		if(npc.m_flAttackHappens < gameTime)
		{

			float projectile_speed = 1000.0;
			npc.FaceTowards(vecTarget, 30000.0);	
			float damage = 100.0;

			int arrow = npc.FireArrow(vecTarget, damage, projectile_speed, "models/props_junk/sawblade001a.mdl", 1.25);	

			int	trail = Trail_Attach(arrow, ARROW_TRAIL, 180, 0.3, 22.0, 3.0, 5);
					
			f_ArrowTrailParticle[arrow] = EntIndexToEntRef(trail);
			CreateTimer(5.0, Timer_RemoveEntity, EntIndexToEntRef(trail), TIMER_FLAG_NO_MAPCHANGE);
			WandProjectile_ApplyFunctionToEntity(arrow, ArrowStartTouchPierce);
			npc.m_flAttackHappens = 0.0;

		}
	}

	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 6.0))
	{
		if(npc.m_iChanged_WalkCycle != 1)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 1;
			npc.StopPathing();
			npc.m_flSpeed = 0.0;
		}
	}
	else
	{
		if(npc.m_iChanged_WalkCycle != 3)
		{
			npc.m_bisWalking = true;
			npc.m_iChanged_WalkCycle = 3;
			npc.StartPathing();
			npc.m_flSpeed = 270.0;
		}
	}
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.0))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_CHAKRAM_ATTACK_RIGHT");
						
				npc.m_flAttackHappens = gameTime + 0.2;
				npc.m_flDoingAnimation = gameTime + 0.2;
				npc.m_flNextMeleeAttack = gameTime + 1.0;
			}
		}
	}
}


public void ArrowStartTouchPierce(int arrow, int entity)
{
	if(entity > 0 && entity < MAXENTITIES)
	{
		if(IsIn_HitDetectionCooldown(arrow,entity))
			return;
		Set_HitDetectionCooldown(arrow,entity, FAR_FUTURE);
		
		if(ShouldNpcDealBonusDamage(entity))
		{
			f_ArrowDamage[arrow] *= 3.0;
		}

		int owner = GetEntPropEnt(arrow, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}

		int inflictor = h_ArrowInflictorRef[arrow];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[arrow]);

		if(inflictor == -1)
			inflictor = owner;

		SDKHooks_TakeDamage(entity, owner, inflictor, f_ArrowDamage[arrow], DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		Projectile_DealElementalDamage(entity, arrow);

		EmitSoundToAll(g_ArrowHitSoundSuccess[GetRandomInt(0, sizeof(g_ArrowHitSoundSuccess) - 1)], arrow, _, 80, _, 0.8, 100);

	}
	else
	{
		EmitSoundToAll(g_ArrowHitSoundMiss[GetRandomInt(0, sizeof(g_ArrowHitSoundMiss) - 1)], arrow, _, 80, _, 0.8, 100);
	}
	if(entity == 0)
	{
		int arrow_particle = EntRefToEntIndex(f_ArrowTrailParticle[arrow]);
		if(IsValidEntity(arrow_particle))
		{
			CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow_particle), TIMER_FLAG_NO_MAPCHANGE);
		}
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(arrow), TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderMode(arrow, RENDER_NONE);
		SetEntityMoveType(arrow, MOVETYPE_NONE);
		WandProjectile_ApplyFunctionToEntity(arrow, INVALID_FUNCTION);
	}
}