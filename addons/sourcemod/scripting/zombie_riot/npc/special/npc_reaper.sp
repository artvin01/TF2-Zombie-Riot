#pragma semicolon 1
#pragma newdecls required

static int GRIMREAPER_BASE_HEALTH = 80;			//Base max health given per player on RED.
static float GRIMREAPER_HEALTH_EXPONENT_PREWAVE20 = 1.125;
static float GRIMREAPER_HEALTH_EXPONENT_PREWAVE30 = 1.225;
static float GRIMREAPER_HEALTH_EXPONENT_LATEGAME = 1.3;
static float GRIMREAPER_HEALTH_MULTIPLIER = 2.5;	//Amount to multiply max health after all other calculations.
static float GRIMREAPER_HEALTH_DIVIDER = 2.0;	//Amount to divide max health after all other calculations.

//The Grim Reaper is very slow, but the further its target is, the faster it becomes.
static float GRIMREAPER_BASE_SPEED = 600.0;			//The Grim Reaper's highest possible movement speed.
static float GRIMREAPER_SPEED_MAX_DISTANCE = 600.0;	//Distance at which the Grim Reaper's speed begins to decrease.
static float GRIMREAPER_SPEED_MIN_DISTANCE = 60.0;	//Distance at which the Grim Reaper's speed is decreased the most.
static float GRIMREAPER_SPEED_LOSS = 450.0;			//The maximum amount of speed the Grim Reaper can lose based on proximity to its target.
static float GRIMREAPER_SPEED_ATTACKING = 60.0;		//The Reaper's move speed while it swings its axe.

//The Grim Reaper charges up a devastating melee attack as it approaches its target. 
//This attack has extended range and a wide hitbox, and can hit multiple enemies at once.
//It deals heavy damage to everything it hits, as well as bonus damage against the Reaper's intended target (meant to instakill the intended target).
static float GRIMREAPER_ATTACK_RANGE = 140.0;				//The range of the attack.
static float GRIMREAPER_ATTACK_WIDTH = 100.0;				//The width of the attack.
static float GRIMREAPER_ATTACK_DISTANCE = 100.0;			//Distance at which the Grim Reaper will unleash its attack if it is ready.
static float GRIMREAPER_ATTACK_DAMAGE_TARGET = 99999999.0;	//Damage dealt to the attack's intended target.
static float GRIMREAPER_ATTACK_DAMAGE = 500.0;				//Damage dealt to everyone else who is hit by the attack.
static float GRIMREAPER_ATTACK_CHARGE_BEGIN = 600.0;		//Distance at which the Grim Reaper begins to raise its axe (this is purely cosmetic).
static float GRIMREAPER_ATTACK_INTERVAL = 2.0;				//Time between attacks. Note that 1.0 is always added to this, because that is the duration of the attack animation.
static float GRIMREAPER_ATTACK_TIME	= 0.375;				//Time after the attack animation begins at which the attack will deal damage.
static float GRIMREAPER_ATTACK_SPEED = 0.875;				//Attack animation speed multiplier. This affects interval and hit time.
static float GRIMREAPER_ATTACK_MIN_AXE_RAISE = 0.95;		//Minimum percentage the axe must be raised in order to attack.
static int GRIMREAPER_ATTACK_MAXTARGETS = 12;				//Maximum targets hit at once by the attack.
static float GRIMREAPER_ATTACK_AFTER_TELEPORT = 1.5;		//Duration to prevent the Reaper from attacking after it teleports.
static float GRIMREAPER_WHIFF_STUN_DURATION = 8.0;			//Duration to stun The Reaper if it somehow misses its intended target when it swings.

static float GRIMREAPER_AXE_RAISE_SPEED = 0.02;		//The speed at which the Reaper raises/lowers its axe per frame. Example: 0.01 means it raises its axe 1% every frame.

static float REAPER_RANGED_MULTIPLIER = 1.0;		//Amount to multiply damage taken by the Reaper from ranged attacks.
static float REAPER_MELEE_MULTIPLIER = 1.0;		//Amount to multiply damage taken by the Reaper from ranged attacks.

static float GRIMREAPER_TELEPORT_INTERVAL = 0.3;		//Every X% of its max HP the Reaper loses, it will teleport to a random enemy.

static float f_AxeRaiseValue[2049] = { 0.0, ... };
static float f_DamageSinceLastTeleport[2049] = { 0.0, ... };
static float f_ReaperCanAttackAt[2049] = { 0.0, ... };
static float f_ReaperStunned[2049] = { 0.0, ... };
static bool b_AboutToAttack[2049] = { false, ... };
static bool b_Attacking[2049] = { false, ...};
static bool b_ReaperNeedsSpecialEyes[2049] = { false, ...};

#define GRIMREAPER_AURA					"utaunt_cremation_black_parent"
#define GRIMREAPER_EYES					"raygun_projectile_blue"
#define GRIMREAPER_EYES_ATTACK_IMMINENT	"raygun_projectile_red"
#define GRIMREAPER_DEATH				"skull_island_explosion"
#define GRIMREAPER_TELEPORT_START		"eyeboss_tp_player"
#define GRIMREAPER_TELEPORT_END			"ghost_appearation"
#define GRIMREAPER_STUNNED				"merasmus_dazed"

#define SND_REAPER_LOOP				")ambient/halloween/underground_wind_lp_03.wav"
#define SND_REAPER_SWING			")misc/halloween/strongman_fast_whoosh_01.wav"
#define SND_REAPER_ATTACK_IMMINENT	")misc/halloween/hwn_bomb_flash.wav"
#define SND_REAPER_ATTACK_HIT		")weapons/halloween_boss/knight_axe_hit.wav"
#define SND_REAPER_ATTACK_KILL		")misc/halloween/strongman_bell_01.wav"
#define SND_REAPER_SAFE_FOR_NOW		")misc/halloween_eyeball/vortex_eyeball_moved.wav"
#define SND_REAPER_TRICKED			")player/pl_impact_stun_range.wav"

static const char g_DeathSounds[][] = {
	"ambient_mp3/halloween/male_scream_07.mp3",
	"ambient_mp3/halloween/male_scream_06.mp3",
	"ambient_mp3/halloween/male_scream_10.mp3",
};

static const char g_AttackSounds[][] = {
	"ambient_mp3/halloween/male_scream_19.mp3",
	"ambient_mp3/halloween/male_scream_21.mp3",
	"ambient_mp3/halloween/male_scream_23.mp3",
};

static const char g_TeleportSounds[][] = {
	"ambient_mp3/halloween/male_scream_12.mp3",
	"ambient_mp3/halloween/male_scream_13.mp3",
	"ambient_mp3/halloween/male_scream_14.mp3"
};

void GrimReaper_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_AttackSounds));	   i++) { PrecacheSound(g_AttackSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));	   i++) { PrecacheSound(g_TeleportSounds[i]);	   }
	PrecacheSound(SND_REAPER_LOOP);
	PrecacheSound(SND_REAPER_SWING);
	PrecacheSound(SND_REAPER_ATTACK_HIT);
	PrecacheSound(SND_REAPER_ATTACK_KILL);
	PrecacheSound(SND_REAPER_ATTACK_IMMINENT);
	PrecacheSound(SND_REAPER_SAFE_FOR_NOW);
	PrecacheSound(SND_REAPER_TRICKED);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Reaper");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_reaper");
	strcopy(data.Icon, sizeof(data.Icon), "mb_reaper"); 	//leaderboard_class_(insert the name)
	data.IconCustom = true;								//download needed?
	data.Flags = 0;											//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	data.Category = Type_Special;
	data.Func = SummonGrimReaper;
	NPC_Add(data);
}

static any SummonGrimReaper(int client, float vecPos[3], float vecAng[3], int ally)
{
	return GrimReaper(vecPos, vecAng, ally);
}

methodmap GrimReaper < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		StopSound(this.index, SNDCHAN_AUTO, SND_REAPER_LOOP);
	}

	public void PlayAttackSound()
	{
		EmitSoundToAll(g_AttackSounds[GetRandomInt(0, sizeof(g_AttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public void PlayTeleportSound()
	{
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public float GetAxeRaisePose()
	{
		int param = this.LookupPoseParameter("melee_chargeup");
		return this.GetPoseParameter(param);
	}
	
	public float SetAxeRaisePose(float val)
	{
		int param = this.LookupPoseParameter("melee_chargeup");
		this.SetPoseParameter(param, val);
	}

	public float MoveToAxeRaisePose(float increment, float goal)
	{
		float current = this.GetAxeRaisePose();
		if (goal > current)
		{
			current += increment;
			if (current > goal)
				current = goal;
		}
		else if (goal < current)
		{
			current -= increment;
			if (current < goal)
				current = goal;
		}

		this.SetAxeRaisePose(current);
	}

	public GrimReaper(float vecPos[3], float vecAng[3], int ally)
	{
		GrimReaper npc = view_as<GrimReaper>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, "1.2", GetReaperHealth(), ally));
		
		i_NpcWeight[npc.index] = 5;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_REAPER_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_bisWalking = false;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		f_ReaperStunned[npc.index] = 0.0;
		
		npc.m_iBleedType = STEPTYPE_NONE;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(Reaper_OnDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Reaper_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Reaper_Think);
		
		float wave = float(Waves_GetRound()+1);
		wave *= 0.1;
		npc.m_flWaveScale = wave;
		
		//IDLE
		npc.m_iState = 4;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		Reaper_CalculateSpeed(npc);
		//npc.m_bCamo = true;

		npc.m_flMeleeArmor = REAPER_MELEE_MULTIPLIER; 
		npc.m_flRangedArmor = REAPER_RANGED_MULTIPLIER;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 1, 1, 1, 200);

		//Un-comment to make the Reaper teleport near a random player the moment it spawns:
		//TeleportDiversioToRandLocation(npc.index);

		EmitSoundToAll(SND_REAPER_LOOP, npc.index, _, _, _, 0.8, 80);

		TE_SetupParticleEffect(GRIMREAPER_AURA, PATTACH_ABSORIGIN_FOLLOW, npc.index);
		TE_WriteNum("m_bControlPoint1", npc.index);	
		TE_SendToAll();

		Reaper_AttachEyeParticles(npc.index, false);

		b_NoHealthbar[npc.index] = true; //Makes it so they never have an outline
		GiveNpcOutLineLastOrBoss(npc.index, false);
		b_thisNpcHasAnOutline[npc.index] = true; 

		f_AxeRaiseValue[npc.index] = 0.0;
		b_AboutToAttack[npc.index] = false;
		b_Attacking[npc.index] = false;
		b_NpcIgnoresbuildings[npc.index] = true;
		b_ReaperNeedsSpecialEyes[npc.index] = false;
		f_DamageSinceLastTeleport[npc.index] = 0.0;
		f_ReaperCanAttackAt[npc.index] = 0.0;
		ApplyStatusEffect(npc.index, npc.index, "Challenger", 99999999.0);

		RequestFrame(Reaper_AdjustAxePose, EntIndexToEntRef(npc.index));
		npc.SetAxeRaisePose(0.0);
		
		return npc;
	}
}

static void Reaper_CalculateSpeed(GrimReaper npc)
{
	if (b_Attacking[npc.index])
	{
		npc.m_flSpeed = GRIMREAPER_SPEED_ATTACKING;
	}
	else
	{
		int target = npc.m_iTarget;
		if (!IsValidEntity(target))
		{
			npc.m_flSpeed = GRIMREAPER_BASE_SPEED;
		}
		else
		{
			float pos[3], targPos[3];
			WorldSpaceCenter(npc.index, pos);
			WorldSpaceCenter(target, targPos);
			float dist = GetVectorDistance(pos, targPos);

			if (dist > GRIMREAPER_SPEED_MAX_DISTANCE)
			{
				npc.m_flSpeed = GRIMREAPER_BASE_SPEED;
			}
			else if (dist < GRIMREAPER_SPEED_MIN_DISTANCE)
			{
				npc.m_flSpeed = GRIMREAPER_BASE_SPEED - GRIMREAPER_SPEED_LOSS;
			}
			else
			{
				float multiplier = 1.0 - ((dist - GRIMREAPER_SPEED_MIN_DISTANCE) / (GRIMREAPER_SPEED_MAX_DISTANCE - GRIMREAPER_SPEED_MIN_DISTANCE));
				npc.m_flSpeed = GRIMREAPER_BASE_SPEED - (multiplier * GRIMREAPER_SPEED_LOSS);
			}
		}
	}
}

static void Reaper_AttachEyeParticles(int entity, bool aboutToAttack = false)
{
	if (GetGameTime(entity) <= f_ReaperStunned[entity])
		return;

	GrimReaper npc = view_as<GrimReaper>(entity);

	if (IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	if (IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	float rightEye[3], leftEye[3];
	float junk[3];
	npc.GetAttachment("righteye", rightEye, junk);
	npc.GetAttachment("lefteye", leftEye, junk);

	npc.m_iWearable1 = ParticleEffectAt_Parent(rightEye, aboutToAttack ? GRIMREAPER_EYES_ATTACK_IMMINENT : GRIMREAPER_EYES, npc.index, "righteye", {0.0,0.0,0.0});
	npc.m_iWearable2 = ParticleEffectAt_Parent(leftEye, aboutToAttack ? GRIMREAPER_EYES_ATTACK_IMMINENT : GRIMREAPER_EYES, npc.index, "lefteye", {0.0,0.0,0.0});
}

public void Reaper_AdjustAxePose(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsEntityAlive(ent))
		return;

	GrimReaper npc = view_as<GrimReaper>(ent);

	if (!b_Attacking[ent] && GetGameTime(npc.index) >= npc.m_flNextMeleeAttack && GetGameTime(npc.index) >= f_ReaperCanAttackAt[npc.index] && GetGameTime(npc.index) > f_ReaperStunned[npc.index])
	{
		if (!IsValidEnemy(npc.index, npc.m_iTarget))
			npc.MoveToAxeRaisePose(GRIMREAPER_AXE_RAISE_SPEED, 0.0);
		else
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc);

			if (flDistanceToTarget > GRIMREAPER_ATTACK_CHARGE_BEGIN)
			{
				npc.MoveToAxeRaisePose(GRIMREAPER_AXE_RAISE_SPEED, 0.0);
			}
			else if (flDistanceToTarget <= GRIMREAPER_ATTACK_DISTANCE)
			{
				npc.MoveToAxeRaisePose(GRIMREAPER_AXE_RAISE_SPEED, 1.0);
			}
			else
			{
				float target = 1.0 - ((flDistanceToTarget - GRIMREAPER_ATTACK_DISTANCE) / (GRIMREAPER_ATTACK_CHARGE_BEGIN - GRIMREAPER_ATTACK_DISTANCE));
				npc.MoveToAxeRaisePose(GRIMREAPER_AXE_RAISE_SPEED, target);
			}
		}

		float axeRaised = npc.GetAxeRaisePose();
		if (axeRaised >= 0.66 && !b_AboutToAttack[npc.index])
		{
			b_AboutToAttack[npc.index] = true;
			Reaper_AttachEyeParticles(npc.index, true);
			EmitSoundToAll(SND_REAPER_ATTACK_IMMINENT, npc.index, _, _, _, _, GetRandomInt(30, 80));
			EmitSoundToAll(SND_REAPER_ATTACK_IMMINENT, npc.index, _, _, _, _, GetRandomInt(60, 100));
		}
		else if (axeRaised < 0.66 && b_AboutToAttack[npc.index])
		{
			b_AboutToAttack[npc.index] = false;
			Reaper_AttachEyeParticles(npc.index, false);
		}
	}

	RequestFrame(Reaper_AdjustAxePose, ref);
}

static void Reaper_SetTarget(GrimReaper npc, int targetOverride = -1)
{
	int target;
	if (IsEntityAlive(targetOverride))
		target = targetOverride;
	else
		target = GetClosestTarget(npc.index);

	if (!IsEntityAlive(target))
		return;

	int oldTarget = npc.m_iTarget;
	if (target != oldTarget)
	{
		if (IsValidClient(target))
		{
			float HudY = -1.0;
			float HudX = -1.0;
			SetHudTextParams(HudX, HudY, 2.0, 255, 120, 0, 255);
			SetGlobalTransTarget(target);
			ShowSyncHudText(target,  SyncHud_Notifaction, "%t", "Reaper Target Warning");

			EmitSoundToClient(target, SND_REAPER_ATTACK_IMMINENT, _, _, _, _, _, GetRandomInt(80, 120));
			EmitSoundToClient(target, SND_REAPER_ATTACK_IMMINENT, _, _, _, _, _, GetRandomInt(80, 120));
		}

		if (IsValidClient(oldTarget))
		{
			float HudY = -1.0;
			float HudX = -1.0;
			SetHudTextParams(HudX, HudY, 2.0, 0, 255, 160, 255);
			SetGlobalTransTarget(oldTarget);
			ShowSyncHudText(oldTarget,  SyncHud_Notifaction, "%t", "Reaper Bored Alert");

			EmitSoundToClient(oldTarget, SND_REAPER_SAFE_FOR_NOW, _, _, _, _, _, GetRandomInt(80, 120));
		}
	}

	npc.m_iTarget = target;
	npc.StartPathing();
}

static void Reaper_Think(int iNPC)
{
	GrimReaper npc = view_as<GrimReaper>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	if (GetGameTime(npc.index) <= f_ReaperStunned[npc.index])
	{
		npc.StopPathing();
		return;
	}

	if (b_ReaperNeedsSpecialEyes[npc.index])
	{
		Reaper_AttachEyeParticles(npc.index);
		b_ReaperNeedsSpecialEyes[npc.index] = false;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		Reaper_SetTarget(npc);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	Reaper_CalculateSpeed(npc);

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc);

		if((flDistanceToTarget * flDistanceToTarget) < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}

		Reaper_TryAttack(npc, GetGameTime(npc.index), flDistanceToTarget, npc.GetAxeRaisePose());
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		Reaper_SetTarget(npc);
	}
}

static void Reaper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	GrimReaper npc = view_as<GrimReaper>(victim);
		
	if(attacker <= 0)
		return;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	f_DamageSinceLastTeleport[npc.index] += damage;
	if (f_DamageSinceLastTeleport[npc.index] >= (float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * GRIMREAPER_TELEPORT_INTERVAL) && GetGameTime(npc.index) >= f_ReaperStunned[npc.index] && !HasSpecificBuff(npc.index, "Stunned"))
	{
		f_DamageSinceLastTeleport[npc.index] = 0.0;
		f_ReaperCanAttackAt[npc.index] = GetGameTime(npc.index) + GRIMREAPER_ATTACK_AFTER_TELEPORT;

		float pos[3];
		WorldSpaceCenter(npc.index, pos);

		ParticleEffectAt(pos, GRIMREAPER_TELEPORT_START);
		npc.PlayTeleportSound();

		RequestFrame(Reaper_Teleport, EntIndexToEntRef(npc.index));
	}
}

void Reaper_Teleport(int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (!IsEntityAlive(ent))
		return;

	TeleportDiversioToRandLocation(ent);

	float pos[3];
	WorldSpaceCenter(ent, pos);
	ParticleEffectAt(pos, GRIMREAPER_TELEPORT_END);
}

static void Reaper_OnDeath(int entity)
{
	GrimReaper npc = view_as<GrimReaper>(entity);
	npc.PlayDeathSound();
	float pos[3];
	WorldSpaceCenter(entity, pos);
	ParticleEffectAt(pos, GRIMREAPER_DEATH);
	RemoveEntity(entity);
}

void Reaper_TryAttack(GrimReaper npc, float gameTime, float distance, float axeRaised)
{
	if (axeRaised < GRIMREAPER_ATTACK_MIN_AXE_RAISE || distance > GRIMREAPER_ATTACK_DISTANCE)
		return;
		
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GRIMREAPER_ATTACK_RANGE * GRIMREAPER_ATTACK_RANGE))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.m_flAttackHappens = 1.0;
				npc.m_flNextMeleeAttack = 1.0;
			}
		}
	}

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			int iActivity = npc.LookupActivity("ACT_REAPER_ATTACK");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.SetPlaybackRate(GRIMREAPER_ATTACK_SPEED);
			npc.PlayAttackSound();
			b_Attacking[npc.index] = true;
			b_AboutToAttack[npc.index] = false;
			npc.SetAxeRaisePose(0.0);
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + GRIMREAPER_ATTACK_INTERVAL + (1.0 / GRIMREAPER_ATTACK_SPEED);

			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);

			float swingSound = GetGameTime(npc.index) + (0.2 / GRIMREAPER_ATTACK_SPEED);
			float damageTime = GetGameTime(npc.index) + (GRIMREAPER_ATTACK_TIME / GRIMREAPER_ATTACK_SPEED);
			float endTime = GetGameTime(npc.index) + (1.0 / GRIMREAPER_ATTACK_SPEED);

			DataPack pack = new DataPack();
			RequestFrame(Reaper_AttackLogic, pack);
			WritePackCell(pack, EntIndexToEntRef(npc.index));
			WritePackFloat(pack, swingSound);
			WritePackFloat(pack, damageTime);
			WritePackFloat(pack, endTime);
		}
	}

}

void Reaper_AttackLogic(DataPack pack)
{
	ResetPack(pack);
	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float swingSound = ReadPackFloat(pack);
	float damageAt = ReadPackFloat(pack);
	float endTime = ReadPackFloat(pack);
	delete pack;

	if (!IsEntityAlive(ent))
		return;

	GrimReaper npc = view_as<GrimReaper>(ent);

	if (IsValidEntity(npc.m_iTarget))
	{
		float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
		npc.FaceTowards(VecEnemy, 15000.0);
	}

	if (GetGameTime(npc.index) >= swingSound)
	{
		EmitSoundToAll(SND_REAPER_SWING, npc.index, _, _, _, _, 80);
		EmitSoundToAll(SND_REAPER_SWING, npc.index, _, _, _, _, 80);
		swingSound = 99999999.0;
	}

	if (GetGameTime(npc.index) >= damageAt)
	{
		float swingMins[3], swingMaxs[3];
		swingMaxs[0] = GRIMREAPER_ATTACK_WIDTH;
		swingMaxs[1] = GRIMREAPER_ATTACK_WIDTH;
		swingMaxs[2] = GRIMREAPER_ATTACK_RANGE;
		swingMins[0] = -swingMaxs[0];
		swingMins[1] = -swingMaxs[1];
		swingMins[2] = -swingMaxs[2];

		Handle swingTrace;
		npc.DoSwingTrace(swingTrace, npc.m_iTarget, swingMaxs, swingMins, _, 1, 1, GRIMREAPER_ATTACK_MAXTARGETS);
		delete swingTrace;

		bool hitTarget = !IsValidClient(npc.m_iTarget);		//Count as true by default if the target is not a player, that way The Reaper can't stun himself if he misses an NPC.
		for (int i = 1; i <= GRIMREAPER_ATTACK_MAXTARGETS; i++)
		{
			if (i_EntitiesHitAoeSwing_NpcSwing[i] > 0)
			{
				if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[i]))
				{
					int target = i_EntitiesHitAoeSwing_NpcSwing[i];
					float vecHit[3];
					WorldSpaceCenter(target, vecHit);

					if (target == npc.m_iTarget)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, GRIMREAPER_ATTACK_DAMAGE_TARGET, DMG_CLUB|DMG_TRUEDAMAGE, -1, _, vecHit);
						EmitSoundToAll(SND_REAPER_ATTACK_KILL, target, _, 120, _, _, GetRandomInt(40, 60));
						hitTarget = true;
					}
					else
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, GRIMREAPER_ATTACK_DAMAGE, DMG_CLUB, -1, _, vecHit);
					}

					EmitSoundToAll(SND_REAPER_ATTACK_HIT, target, _, 120, _, _, GetRandomInt(80, 100));
				}
			} 
		}

		if (!hitTarget)
		{
			if (IsValidClient(npc.m_iTarget))
			{
				float HudY = -1.0;
				float HudX = -1.0;
				SetHudTextParams(HudX, HudY, 2.0, 120, 255, 200, 255);
				SetGlobalTransTarget(npc.m_iTarget);
				ShowSyncHudText(npc.m_iTarget,  SyncHud_Notifaction, "%t", "Reaper Tricked Alert");

				EmitSoundToClient(npc.m_iTarget, SND_REAPER_TRICKED);
			}

			if (IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);

			if (IsValidEntity(npc.m_iWearable2))
				RemoveEntity(npc.m_iWearable2);

			f_ReaperStunned[npc.index] = GetGameTime(npc.index) + GRIMREAPER_WHIFF_STUN_DURATION;
			b_ReaperNeedsSpecialEyes[npc.index] = true;
			EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index, _, _, _, _, 80);
			EmitSoundToAll(SND_REAPER_TRICKED, npc.index);

			float pos[3];
			npc.GetAbsOrigin(pos);
			pos[2] += 90.0;
			int particle = ParticleEffectAt_Parent(pos, GRIMREAPER_STUNNED, npc.index, "root");
			if (IsValidEntity(particle))
				CreateTimer(GRIMREAPER_WHIFF_STUN_DURATION, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		}

		damageAt = 9999999.0;
		Reaper_AttachEyeParticles(npc.index, false);
	}

	if (GetGameTime(npc.index) >= endTime)
	{
		int iActivity = npc.LookupActivity("ACT_REAPER_FLOAT");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.SetPlaybackRate(1.0);
		b_Attacking[npc.index] = false;
		return;
	}

	pack = new DataPack();
	RequestFrame(Reaper_AttackLogic, pack);
	WritePackCell(pack, EntIndexToEntRef(ent));
	WritePackFloat(pack, swingSound);
	WritePackFloat(pack, damageAt);
	WritePackFloat(pack, endTime);
}

static char[] GetReaperHealth()
{
	int health = GRIMREAPER_BASE_HEALTH;
	
	health *= CountPlayersOnRed(); //yep its high! will need tos cale with waves expoentially.
	
	float temp_float_hp = float(health);
	
	if(Waves_GetRound()+1 < 20)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)), GRIMREAPER_HEALTH_EXPONENT_PREWAVE20));
	}
	else if(Waves_GetRound()+1 < 30)
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)), GRIMREAPER_HEALTH_EXPONENT_PREWAVE30));
	}
	else
	{
		health = RoundToCeil(Pow(((temp_float_hp + float(Waves_GetRound()+1)) * float(Waves_GetRound()+1)), GRIMREAPER_HEALTH_EXPONENT_LATEGAME));
	}
	
	health = RoundFloat((health * GRIMREAPER_HEALTH_MULTIPLIER) / GRIMREAPER_HEALTH_DIVIDER);
	
	char buffer[16];
	IntToString(health, buffer, sizeof(buffer));
	return buffer;
}
