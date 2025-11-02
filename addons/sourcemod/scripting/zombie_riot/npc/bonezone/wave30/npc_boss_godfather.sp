#pragma semicolon 1
#pragma newdecls required

#define GODFATHER_SCALE			"1.225"
#define GODFATHER_HP			"50000"
#define GODFATHER_SKIN			"1"

static float GODFATHER_SPEED = 200.0;

//IRREFUTABLE OFFER: Godfather Grimme calls a hit on the player he is currently targeting, forcing all allies within a large radius to drop what they're doing and target that player.
//This ability CAN work with entities, I just don't recommend it because then he'll waste it on buildings. It's fun when you spawn him as an ally though!
static float Offer_Duration = 20.0;					//Duration for which the marked player is targeted.
static float Offer_Radius = 1600.0;					//Radius in which allies are forced to target the chosen enemy when this ability is activated.
static float Offer_Cooldown = 30.0;					//Cooldown between offers.
static float Offer_StartingCooldown = 15.0;			//Cooldown upon spawning.
static bool Offer_AllowEntities_Friendly = true;	//Whether or not this ability can target entities and not just clients when Grimme is on the mercs' team.
static bool Offer_AllowEntities_Hostile = false;	//Whether or not this ability can target entities and not just clients when Grimme is on the zombies' team. 
static bool Offer_AllowEntities_NoTeam = true;		//Whether or not this ability can target entities and not just clients when Grimme is on nobody's team and is trying to kill everyone.

//LITTLE FRIENDS: Godfather Grimme slows down and aims his guns at the nearest 2 targets, rapidly firing them the entire time.
//He will path towards the absolute closest target. If only one valid target is within range and visible, he will aim both guns at that target.
//A target must be visible and within a 90-degree cone of one of the guns to be considered a "valid" target for that gun.
//EX: A target is in front of Godfather Grimme, to his left. That target is considered valid for his left-hand gun, but not the right-hand gun.
static float Friends_DMG = 20.0;				//Projectile damage.
static float Friends_EntityDMG = 120.0;			//Projectile damage VS entities.
static float Friends_Velocity = 1200.0;			//Projectile velocity.
static float Friends_Spread = 9.0;				//Projectile spread.
static float Friends_Lifespan = 2.5;			//Projectile lifespan.
static float Friends_AttackRate = 0.08;			//Attack interval.
static float Friends_Duration = 9.0;			//Attack duration.
static float Friends_Cooldown = 15.0;			//Attack cooldown.
static float Friends_StartingCooldown = 10.0;	//Cooldown upon spawning.
static float Friends_Range = 900.0;				//Range in which the ability will be used, if it can.
static float Friends_Speed = 100.0;				//Movement speed while active.
static float Friends_TurnRate = 2.0;

//DIRTY KICK: One of Godfather Grimme's melee attacks, in which he delivers a swift kick in the dick to his target. This deals low damage, but hard-stuns the victim.
static float Dirty_DMG = 60.0;			//Dirty Kick damage.
static float Dirty_EntityDMG = 1000.0;	//Dirty Kick damage to entities.
static float Dirty_Stun = 4.0;			//Dirty Kick stun duration.
static float Dirty_Range = 80.0;		//Range in which the kick will be used, if it can be used.
static float Dirty_Cooldown = 10.0;		//Dirty Kick cooldown.
static float Dirty_StartingCooldown = 4.0;	//Starting cooldown.

//NORMAL KICK: Godfather Grimme's other melee attack, where he kicks his target in the gut, dealing heavy damage in addition to knockback.
static float Kick_DMG = 200.0;			//Normal Kick damage.
static float Kick_EntityDMG = 2000.0;				//Normal Kick damage versus entities.
static float Kick_Knockback = 900.0;	//Normal Kick knockback force.
static float Kick_Range = 90.0;			//Range in which the kick will be used, if it can be used.
static float Kick_Cooldown = 5.0;		//Normal Kick cooldown.
static float Kick_StartingCooldown = 2.0;	//Starting cooldown.

//DEATH RATTLE: When Godfather Grimme dies, he drops a molotov which deals massive building damage.
static float GodfatherMolotov_Velocity = 1200.0;
static float GodfatherMolotov_Gravity = 2.33;
static float GodfatherMolotov_DMG = 150.0;
static float GodfatherMolotov_EntityMult = 25.0;
static float GodfatherMolotov_Radius = 200.0;
static float GodfatherMolotov_Falloff_MultiHit = 0.66;
static float GodfatherMolotov_Falloff_Range = 0.66;

static char g_OfferDialogue[][] = {
	"{corrupted}Godfather Grimme{default}: Go make {orangered}%s{default} an offer they can't refuse...",
	"{corrupted}Godfather Grimme{default}: It's not personal, {orangered}%s{default}. It's strictly business."
};

static char g_OfferDialogue_Wounded[][] = {
	"{corrupted}Godfather Grimme{default}: I want {orangered}%s{default} dead! I want their family dead! I want their house burned to the ground!"
};

static char g_FriendsDialogue[][] = {
	"{corrupted}Godfather Grimme{default}: SAY HELLO TO MY LITTLE FRIENDS!",
	"{corrupted}Godfather Grimme{default}: These guns ain't just for show, pal...",
	"{corrupted}Godfather Grimme{default}: RATTLE 'EM, BOYS!"
};

/*static char g_MobsterTargeting[][] = {
	")misc/halloween/skeleton_break.wav",
};*/

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
};

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_05.wav",
};

static char g_MeleeHitSounds[][] = {
	")weapons/grappling_hook_impact_flesh.wav",
};

static char g_MeleeAttackSounds[][] = {
	"player/cyoa_pda_fly_swoosh.wav",
};

static char g_MeleeMissSounds[][] = {
	"misc/blank.wav",
};

static char g_HeIsAwake[][] = {
	"physics/concrete/concrete_break2.wav",
	"physics/concrete/concrete_break3.wav",
};

static char g_GibSounds[][] = {
	"items/pumpkin_explode1.wav",
	"items/pumpkin_explode2.wav",
	"items/pumpkin_explode3.wav",
};

#define SOUND_OFFER_MARKED			")mvm/mvm_cpoint_klaxon.wav"
#define SOUND_GODFATHER_KICK_SWING	")weapons/machete_swing.wav"
#define SOUND_GODFATHER_KICK_SWING_BIG	")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_DIRTYKICK_HIT			")weapons/fist_hit_world1.wav"
#define SOUND_DIRTYKICK_HIT_PLAYER	")ambient/rottenburg/rottenburg_belltower.wav"
#define SOUND_DIRTYKICK_STUNNED_SCOUT		")vo/scout_painsevere01.mp3"
#define SOUND_DIRTYKICK_STUNNED_SOLDIER		")vo/soldier_painsevere03.mp3"
#define SOUND_DIRTYKICK_STUNNED_PYRO		")vo/pyro_paincrticialdeath01.mp3"
#define SOUND_DIRTYKICK_STUNNED_DEMOMAN		")vo/demoman_painsevere02.mp3"
#define SOUND_DIRTYKICK_STUNNED_HEAVY		")vo/heavy_paincrticialdeath01.mp3"
#define SOUND_DIRTYKICK_STUNNED_ENGINEER	")vo/engineer_painsevere06.mp3"
#define SOUND_DIRTYKICK_STUNNED_MEDIC		")vo/medic_painsevere04.mp3"
#define SOUND_DIRTYKICK_STUNNED_SNIPER		")vo/sniper_sf13_scared03.mp3"
#define SOUND_DIRTYKICK_STUNNED_SPY			")vo/spy_paincrticialdeath01.mp3"
#define SOUND_DIRTYKICK_STUNNED_KLEINER		")vo/k_lab/kl_ohdear.wav"
#define SOUND_DIRTYKICK_STUNNED_BARNEY		")vo/npc/barney/ba_pain06.wav"
#define SOUND_DIRTYKICK_STUNNED_NIKO		")vo/npc/vortigaunt/tothevoid.wav"	//nik o
#define SOUND_DIRTYKICK_STUNNED_SKELETON	")vo/halloween_boss/knight_pain03.mp3"
#define SOUND_NORMALKICK_HIT				")misc/halloween/strongman_fast_impact_01.wav"
#define SOUND_GODFATHER_GUN_CLICK			")weapons/sniper_bolt_back.wav"
#define SOUND_GODFATHER_GUNS_SWING			")weapons/machete_swing.wav"
#define SOUND_GODFATHER_SHOOT				")weapons/doom_sniper_smg.wav"
#define SOUND_GODFATHER_GUNS_HIT			")player/pain.wav"
#define SOUND_GODFATHER_MOLOTOV_EXPLODE_1	")weapons/bottle_break.wav"
#define SOUND_GODFATHER_MOLOTOV_EXPLODE_2	")misc/halloween/spell_fireball_impact.wav"

#define PARTICLE_OFFER_MARKED		"teleportedin_red"
#define PARTICLE_OFFER_MARKED_TRAIL	"player_recent_teleport_red"
#define PARTICLE_OFFER_RECEIVED		"spell_batball_impact_blue_3"
#define PARTICLE_GODFATHER_MUZZLE	"muzzle_pistol"
#define PARTICLE_GODFATHER_GUNS_HIT	"flaregun_destroyed"
#define PARTICLE_GODFATHER_PROJECTILE	"raygun_projectile_red"
#define PARTICLE_GODFATHER_MOLOTOV_EXPLODE	"heavy_ring_of_fire"
#define PARTICLE_GODFATHER_MOLOTOV			"fuse_sparks"

#define MODEL_MOLOTOV				"models/weapons/c_models/c_bottle/c_bottle.mdl"

public void Godfather_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SOUND_OFFER_MARKED);
	PrecacheSound(SOUND_GODFATHER_KICK_SWING);
	PrecacheSound(SOUND_GODFATHER_KICK_SWING_BIG);
	PrecacheSound(SOUND_DIRTYKICK_HIT);
	PrecacheSound(SOUND_DIRTYKICK_HIT_PLAYER);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_SCOUT);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_SOLDIER);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_PYRO);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_DEMOMAN);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_HEAVY);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_ENGINEER);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_MEDIC);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_SNIPER);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_SPY);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_KLEINER);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_BARNEY);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_NIKO);
	PrecacheSound(SOUND_DIRTYKICK_STUNNED_SKELETON);
	PrecacheSound(SOUND_NORMALKICK_HIT);
	PrecacheSound(SOUND_GODFATHER_GUN_CLICK);
	PrecacheSound(SOUND_GODFATHER_GUNS_SWING);
	PrecacheSound(SOUND_GODFATHER_SHOOT);
	PrecacheSound(SOUND_GODFATHER_GUNS_HIT);

	PrecacheModel(MODEL_MOLOTOV);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Godfather Grimme");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_godfather");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Necropolain;
	data.Func = Summon_Godfather;
	NPC_Add(data);
}

static any Summon_Godfather(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Godfather(client, vecPos, vecAng, ally);
}

static float f_NextOffer[MAXENTITIES] = { 0.0, ... };
static float f_NextDirtyKick[MAXENTITIES] = { 0.0, ... };
static float f_NextKick[MAXENTITIES] = { 0.0, ... };
static float f_NextGuns[MAXENTITIES] = { 0.0, ... };
static float f_GunsEndTime[MAXENTITIES] = { 0.0, ... };

static int i_GunsRightTarget[MAXENTITIES] = { -1, ... };
static int i_GunsLeftTarget[MAXENTITIES] = { -1, ... };

static bool Godfather_Attacking[MAXENTITIES] = { false, ... };
static bool Godfather_ResetAnimation[MAXENTITIES] = { false, ... };
static bool Friends_SetGestures[MAXENTITIES] = { false, ... };
static bool b_FriendsActive[MAXENTITIES] = { false, ... };

static bool CheckingLeft = false;

methodmap Godfather < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, _, _, _, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGodfather::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}

	public void SetArmAim(bool left, float override)
	{
		char param[255];
		if (left)
			param = "godfather_aim_left";
		else
			param = "godfather_aim_right";

		if (override > 90.0)
			override = 90.0;
		if (override < 0.0)
			override = 0.0;

		this.SetPoseParameter(this.LookupPoseParameter(param), override);
	}

	public int GetGunTarget(bool left = true)
	{
		if (left)
		{
			int target = EntRefToEntIndex(i_GunsLeftTarget[this.index]);
			if (IsValidEntity(target))
				return target;
			else
				return this.m_iTarget;
		}
		else
		{
			int target = EntRefToEntIndex(i_GunsRightTarget[this.index]);
			if (IsValidEntity(target))
				return target;
			else
				return this.m_iTarget;
		}
	}

	public void GetGunTargetPos(bool left, float buffer[3])
	{
		int target = this.GetGunTarget(left);
		if (IsValidEnemy(this.index, target) && Can_I_See_Enemy_Only(this.index, target))
		{
			WorldSpaceCenter(target, buffer);
		}
		else
		{
			float ang[3], Direction[3], startPos[3];
			this.GetAttachment((left ? "smg_muzzle_left" : "smg_muzzle_right"), startPos, ang);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, 200.0);
			AddVectors(startPos, Direction, buffer);
		}
	}

	public void PlayFriendsIntro()
	{
		CPrintToChatAll(g_FriendsDialogue[GetRandomInt(0, sizeof(g_FriendsDialogue) - 1)]);
	}

	public void MakeAnOfferTheyCantRefuse(int victim)
	{
		if (!i_IsABuilding[victim])
		{
			float hp = float(GetEntProp(this.index, Prop_Data, "m_iHealth"));
			float maxHP = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));

			char vicName[255];
			if (IsValidClient(victim))
			{
				GetClientName(victim, vicName, sizeof(vicName));
			}
			else
			{
				strcopy(vicName, sizeof(vicName), c_NpcName[victim]);
			}

			if (hp / maxHP <= 0.33)
				CPrintToChatAll(g_OfferDialogue_Wounded[GetRandomInt(0, sizeof(g_OfferDialogue_Wounded) - 1)], vicName);
			else
				CPrintToChatAll(g_OfferDialogue[GetRandomInt(0, sizeof(g_OfferDialogue) - 1)], vicName);
		}

		EmitSoundToAll(SOUND_OFFER_MARKED, victim);

		float pos[3], allyPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", pos);
		ParticleEffectAt(pos, PARTICLE_OFFER_MARKED);

		int effect = ParticleEffectAt_Parent(pos, PARTICLE_OFFER_MARKED_TRAIL, victim);
		if (IsValidEntity(effect))
			CreateTimer(Offer_Duration, Timer_RemoveEntity, EntIndexToEntRef(effect), TIMER_FLAG_NO_MAPCHANGE);

		this.WorldSpaceCenter(pos);

		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidEntity(i) || i_IsABuilding[i] || i == this.index || IsValidClient(i))
				continue;
			
			if (!IsValidAlly(this.index, i))
				continue;
			
			CClotBody mobster = view_as<CClotBody>(i);
			GetEntPropVector(mobster.index, Prop_Data, "m_vecAbsOrigin", allyPos);
			if (GetVectorDistance(pos, allyPos) <= Offer_Radius)
			{
				mobster.m_iTarget = victim;
				mobster.m_flGetClosestTargetTime = GetGameTime(mobster.index) + Offer_Duration;
				fl_GetClosestTargetTimeTouch[mobster.index] = GetGameTime(mobster.index) + Offer_Duration;
				EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], mobster.index, _, _, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 120));
				ParticleEffectAt(allyPos, PARTICLE_OFFER_RECEIVED);
			}
		}

		f_NextOffer[this.index] = GetGameTime(this.index) + Offer_Cooldown;
	}

	public bool IsVictimValidForGun(int victim, bool left)
	{
		if (!IsValidEnemy(this.index, victim) || !Can_I_See_Enemy_Only(this.index, victim))
			return false;

		if (left && victim == i_GunsRightTarget[this.index] || !left && victim == i_GunsLeftTarget[this.index])
			return false;

		float vicPos[3], myPos[3], diff[3], ang[3];
		WorldSpaceCenter(victim, vicPos);
		WorldSpaceCenter(this.index, myPos);
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);

		if (left)
			ang[1] += 45.0;
		else
			ang[1] += 315.0;

		GetAngleVectors(ang, ang, NULL_VECTOR, NULL_VECTOR);

		SubtractVectors(vicPos, myPos, diff);

		float cosDiff = GetVectorDotProduct(ang, diff);
	
		if (cosDiff < 0.0)
			return false;

		float flLen2 = GetVectorLength(diff, true);

		float width = Cosine(45.0);

		// a/sqrt(b) > c  == a^2 > b * c ^2
		return ( cosDiff * cosDiff >= flLen2 * width * width );
	}

	public void SetVictimForGun(bool left)
	{
		int target = (left ? i_GunsLeftTarget[this.index] : i_GunsRightTarget[this.index]);
		if (this.IsVictimValidForGun(target, left))	//Don't set a new target if our current target is valid *and* visible
			return;

		float pos[3], ang[3];
		this.GetAttachment((left ? "smg_muzzle_left" : "smg_muzzle_right"), pos, ang);
		
		CheckingLeft = left;
		target = GetClosestTarget(this.index, _, _, _, _, _, pos, true, _, _, _, _, Godfather_CheckClosestIsValid);
		if (!IsValidEnemy(this.index, target))
			target = this.m_iTarget;

		if (left)
			i_GunsLeftTarget[this.index] = target;
		else
			i_GunsRightTarget[this.index] = target;
	}

	public void AimGunAtTarget(bool left)
	{
		int target = (left ? i_GunsLeftTarget[this.index] : i_GunsRightTarget[this.index]);
		if (!IsValidEnemy(this.index, target) || !Can_I_See_Enemy_Only(this.index, target))
			return;

		float pos[3], vicPos[3], ang[3], targAng[3], buffer[3];
		this.WorldSpaceCenter(pos);
		WorldSpaceCenter(target, vicPos);
		GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);

		for (int i = 0; i < 3; i++)
			ang[i] = fixAngle(ang[i]);

		GetVectorAnglesTwoPoints(pos, vicPos, targAng);

		for (int i = 0; i < 3; i++)
			targAng[i] = fixAngle(targAng[i]);

		if (left)
			SubtractVectors(targAng, ang, buffer);
		else
			SubtractVectors(ang, targAng, buffer);

		float param = ApproachAngle(buffer[1], this.GetPoseParameter(this.LookupPoseParameter((left ? "godfather_aim_left" : "godfather_aim_right"))), Friends_TurnRate);

		this.SetArmAim(left, param);
	}

	public Godfather(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		Godfather npc = view_as<Godfather>(CClotBody(vecPos, vecAng, BONEZONE_MODEL_BOSS, GODFATHER_SCALE, GODFATHER_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		func_NPCAnimEvent[npc.index] = Godfather_AnimEvent;
		f_NextOffer[npc.index] = GetGameTime(npc.index) + Offer_StartingCooldown;
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(Godfather_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(Godfather_ClotThink);

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_GODFATHER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", GODFATHER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = GODFATHER_SPEED;

		npc.StartPathing();
		
		Godfather_Attacking[npc.index] = false;
		f_NextDirtyKick[npc.index] = GetGameTime(npc.index) + Dirty_StartingCooldown;
		f_NextKick[npc.index] = GetGameTime(npc.index) + Kick_StartingCooldown;
		f_NextGuns[npc.index] = GetGameTime(npc.index) + Friends_StartingCooldown;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		return npc;
	}
}

public bool Godfather_CheckClosestIsValid(int user, int target)
{
	Godfather npc = view_as<Godfather>(user);
	return npc.IsVictimValidForGun(target, CheckingLeft);
}

//TODO 
//Rewrite
public void Godfather_ClotThink(int iNPC)
{
	Godfather npc = view_as<Godfather>(iNPC);
	
	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + (Godfather_Attacking[npc.index] ? 0.0 : DEFAULT_UPDATE_DELAY_FLOAT);
	
	if (Godfather_ResetAnimation[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_GODFATHER_RUN");
		if (iActivity > 0)
			npc.StartActivity(iActivity);
			
		Godfather_ResetAnimation[npc.index] = false;
	}

	if (Friends_SetGestures[npc.index])
	{
		npc.AddGesture("ACT_GODFATHER_AIM_POSE", false, _, false);
		npc.AddGesture("ACT_GODFATHER_AIM_RIGHT", false, _, false);
		npc.AddGesture("ACT_GODFATHER_AIM_LEFT", false, _, false);
		npc.SetArmAim(true, 0.0);
		npc.SetArmAim(false, 0.0);

		npc.m_flNextRangedAttack = GetGameTime(npc.index) + Friends_AttackRate;

		Friends_SetGestures[npc.index] = false;
		b_FriendsActive[npc.index] = true;
	}

	if (Godfather_Attacking[npc.index] && b_FriendsActive[npc.index])
	{
		npc.SetVictimForGun(true);
		npc.SetVictimForGun(false);
		npc.AimGunAtTarget(true);
		npc.AimGunAtTarget(false);

		if (GetGameTime(npc.index) > f_GunsEndTime[npc.index])
		{
			b_FriendsActive[npc.index] = false;
			Godfather_Attacking[npc.index] = false;
			npc.m_flSpeed = GODFATHER_SPEED;
			npc.RemoveAllGestures();
			f_NextGuns[npc.index] = GetGameTime(npc.index) + Friends_Cooldown;
		}
		else if (GetGameTime(npc.index) >= npc.m_flNextRangedAttack)
		{
			float pos[3], ang[3], vicPos[3];
			npc.GetAttachment("smg_muzzle_left", pos, ang);
			ang[1] -= 90.0;
			npc.GetGunTargetPos(true, vicPos);

			Godfather_ShootProjectile(npc, vicPos, pos, ang);

			int flash = ParticleEffectAt(pos, PARTICLE_GODFATHER_MUZZLE);
			if (IsValidEntity(flash))
				EmitSoundToAll(SOUND_GODFATHER_SHOOT, flash, _, _, _, _, GetRandomInt(80, 120));

			npc.GetAttachment("smg_muzzle_right", pos, ang);
			npc.GetGunTargetPos(false, vicPos);
			ang[1] -= 90.0;
			Godfather_ShootProjectile(npc, vicPos, pos, ang);

			flash = ParticleEffectAt(pos, PARTICLE_GODFATHER_MUZZLE);
			if (IsValidEntity(flash))
				EmitSoundToAll(SOUND_GODFATHER_SHOOT, flash, _, _, _, _, GetRandomInt(80, 120));

			npc.m_flNextRangedAttack = GetGameTime(npc.index) + Friends_AttackRate;
		}
	}

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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + (Godfather_Attacking[npc.index] ? 0.0 : 0.1);
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;

	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother);
				
		if(flDistanceToTarget * flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}

		if (f_NextOffer[npc.index] <= GetGameTime(npc.index))
		{
			if (!IsValidClient(closest))
			{
				int team = GetTeam(npc.index);

				if (team == 2 && Offer_AllowEntities_Friendly)
					npc.MakeAnOfferTheyCantRefuse(closest);
				else if (team == 3 && Offer_AllowEntities_Hostile)
					npc.MakeAnOfferTheyCantRefuse(closest);
				else if (team != 2 && team != 3 && Offer_AllowEntities_NoTeam)
					npc.MakeAnOfferTheyCantRefuse(closest);
			}
			else
				npc.MakeAnOfferTheyCantRefuse(closest);
		}

		if (flDistanceToTarget <= Dirty_Range && GetGameTime(npc.index) >= f_NextDirtyKick[npc.index] && !Godfather_Attacking[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_GODFATHER_KICK_DIRTY");
			if (iActivity > 0)
				npc.StartActivity(iActivity);

			npc.FaceTowards(vecTarget, 15000.0);
			npc.StopPathing();

			EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index, _, _, _, _, 80);
			Godfather_Attacking[npc.index] = true;
		}

		if (flDistanceToTarget <= Kick_Range && GetGameTime(npc.index) >= f_NextKick[npc.index] && !Godfather_Attacking[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_GODFATHER_KICK_NORMAL");
			if (iActivity > 0)
				npc.StartActivity(iActivity);

			npc.FaceTowards(vecTarget, 15000.0);
			npc.StopPathing();

			EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index, _, _, _, _, 80);
			Godfather_Attacking[npc.index] = true;
		}

		if (flDistanceToTarget <= Friends_Range && GetGameTime(npc.index) >= f_NextGuns[npc.index] && !Godfather_Attacking[npc.index])
		{
			npc.AddGesture("ACT_GODFATHER_TAKE_AIM");
			f_GunsEndTime[npc.index] = GetGameTime() + Friends_Duration + 0.5;
			Godfather_Attacking[npc.index] = true;
			npc.m_flSpeed = Friends_Speed;
			npc.PlayFriendsIntro();
			EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index, _, _, _, _, 80);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.PlayIdleSound();
}

public void Godfather_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	Godfather npc = view_as<Godfather>(entity);

	switch(event)	//Events 1001-1003 are for Dirty Kick, events 1004-1006 are for normal kick.
	{
		case 1001:	//Leg swing, play sound.
		{
			EmitSoundToAll(SOUND_GODFATHER_KICK_SWING, npc.index, _, 120, _, _, 80);
		}
		case 1002:	//Impact, run melee logic and play sound.
		{
			int closest = npc.m_iTarget;
			if (!IsValidEntity(closest))
				return;

			Handle swingTrace;

			if(npc.DoSwingTrace(swingTrace, closest))
			{
				int target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(target > 0) 
				{
					SDKHooks_TakeDamage(target, npc.index, npc.index, target < MaxClients ? Dirty_DMG : Dirty_EntityDMG, DMG_CLUB, -1, _, vecHit);
					EmitSoundToAll(SOUND_DIRTYKICK_HIT, target);
						
					if (!i_IsABuilding[target])
					{
						EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index, _, _, _, _, 80);

						if (target < MaxClients)
						{
							TF2_StunPlayer(target, Dirty_Stun, _, TF_STUNFLAG_BONKSTUCK);

							char sound[255];
							if (i_CustomModelOverrideIndex[target] < BARNEY)
							{
								switch (view_as<int>(CurrentClass[target]))
								{
									case 1:
									{
										sound = SOUND_DIRTYKICK_STUNNED_SCOUT;
									}
									case 2:
									{
										sound = SOUND_DIRTYKICK_STUNNED_SNIPER;
									}
									case 3:
									{
										sound = SOUND_DIRTYKICK_STUNNED_SOLDIER;
									}
									case 4:
									{
										sound = SOUND_DIRTYKICK_STUNNED_DEMOMAN;
									}
									case 5:
									{
										sound = SOUND_DIRTYKICK_STUNNED_MEDIC;
									}
									case 6:
									{
										sound = SOUND_DIRTYKICK_STUNNED_HEAVY;
									}
									case 7:
									{
										sound = SOUND_DIRTYKICK_STUNNED_PYRO;
									}
									case 8:
									{
										sound = SOUND_DIRTYKICK_STUNNED_SPY;
									}
									case 9:
									{
										sound = SOUND_DIRTYKICK_STUNNED_ENGINEER;
									}
								}
							}
							else
							{
								switch(i_CustomModelOverrideIndex[target])
								{
									case 1:
									{
										sound = SOUND_DIRTYKICK_STUNNED_BARNEY;
									}
									case 2:
									{
										sound = SOUND_DIRTYKICK_STUNNED_NIKO;
									}
									case 3:
									{
										sound = SOUND_DIRTYKICK_STUNNED_SKELETON;
									}
									case 4:
									{
										sound = SOUND_DIRTYKICK_STUNNED_KLEINER;
									}
								}
							}

							Client_Shake(target, _, _, _, 1.5);
							EmitSoundToAll(sound, target, _, 120, _, _, 110);
						}
						else
						{
							FreezeNpcInTime(target, Dirty_Stun);
						}

						EmitSoundToAll(SOUND_DIRTYKICK_HIT_PLAYER, target, _, 120, _, _, 80);
					}
				}
			}

			delete swingTrace;
		}
		case 1003:	//Kick is over, resume pathing and revert to walk cycle.
		{
			Godfather_ResetAnimation[npc.index] = true;
			Godfather_Attacking[npc.index] = false;
			f_NextDirtyKick[npc.index] = GetGameTime(npc.index) + Dirty_Cooldown;
			npc.StartPathing();
		}
		case 1004:
		{
			EmitSoundToAll(SOUND_GODFATHER_KICK_SWING_BIG, npc.index, _, 120);
		}
		case 1005:
		{
			int closest = npc.m_iTarget;
			if (!IsValidEntity(closest))
				return;

			Handle swingTrace;

			if(npc.DoSwingTrace(swingTrace, closest))
			{
				int target = TR_GetEntityIndex(swingTrace);	
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				if(target > 0) 
				{
					EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index, _, _, _, _, 80);
					SDKHooks_TakeDamage(target, npc.index, npc.index, target < MaxClients ? Kick_DMG : Kick_EntityDMG, DMG_CLUB, -1, _, vecHit);

					EmitSoundToAll(SOUND_DIRTYKICK_HIT, target);
					EmitSoundToAll(SOUND_NORMALKICK_HIT, target);

					if (!i_IsABuilding[target])
					{
						float ang[3], vel[3], buffer[3];
						GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
						GetAngleVectors(ang, buffer, NULL_VECTOR, NULL_VECTOR);

						for (int i = 0; i < 3; i++)
							vel[i] = buffer[i] * Kick_Knockback;

						vel[2] += 600.0;

						if (IsValidClient(target))
						{
							Client_Shake(target, _, _, _, 0.5);
							TeleportEntity(target, _, _, vel);
						}
						else
						{
							if(VIPBuilding_Active())
								return;
									
							if(f_NoUnstuckVariousReasons[target] > GetGameTime() + 1.0)
							{
								//make the target not stuckable.
								f_NoUnstuckVariousReasons[target] = GetGameTime() + 1.0;
							}

							SDKUnhook(target, SDKHook_Think, NpcJumpThink);
							f3_KnockbackToTake[target] = vel;
							SDKHook(target, SDKHook_Think, NpcJumpThink);
						}
					}
				}
			}

			delete swingTrace;
		}
		case 1006:
		{
			Godfather_ResetAnimation[npc.index] = true;
			Godfather_Attacking[npc.index] = false;
			f_NextKick[npc.index] = GetGameTime(npc.index) + Kick_Cooldown;
			npc.StartPathing();
		}
		case 1007:	//Swings guns up, play sound
		{
			EmitSoundToAll(SOUND_GODFATHER_GUNS_SWING, npc.index);
		}
		case 1008:	//Play gun click sound
		{
			EmitSoundToAll(SOUND_GODFATHER_GUN_CLICK, npc.index, _, _, _, _, GetRandomInt(80, 120));
		}
		case 1009:	//Guns are in place, start aiming/firing
		{
			Friends_SetGestures[npc.index] = true;
		}
	}
}

void Godfather_ShootProjectile(Godfather npc, float vicLoc[3], float startPos[3], float startAng[3], bool molotov = false)
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecAngles[3], currentAngles[3], buffer[3];

		if (!molotov)
		{
			currentAngles = startAng;
			Priest_GetAngleToPoint(npc.index, startPos, vicLoc, buffer, vecAngles);
			vecAngles[1] = currentAngles[1];
			vecAngles[2] = currentAngles[2];

			for(int i = 0; i < 3; i++)
				vecAngles[i] += GetRandomFloat(-Friends_Spread, Friends_Spread);
		}
		else
		{
			vecAngles[0] = -90.0;
		}
			
		GetAngleVectors(vecAngles, buffer, NULL_VECTOR, NULL_VECTOR);
		vecForward[0] = buffer[0] * (molotov ? GodfatherMolotov_Velocity : Friends_Velocity);
		vecForward[1] = buffer[1] * (molotov ? GodfatherMolotov_Velocity : Friends_Velocity);
		vecForward[2] = buffer[2] * (molotov ? GodfatherMolotov_Velocity : Friends_Velocity);
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);

		TeleportEntity(entity, startPos, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		int g_ProjectileModelRocket = PrecacheModel((molotov ? MODEL_MOLOTOV : "models/weapons/w_models/w_drg_ball.mdl"));
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);
		
		g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rattler_DontExplode);

		if (!molotov)
		{
			SDKHook(entity, SDKHook_Touch, Godfather_ProjectileHit);
			ParticleEffectAt_Parent(startPos, PARTICLE_GODFATHER_PROJECTILE, entity);
			CreateTimer(Friends_Lifespan, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, GodfatherMolotov_ProjectileHit);
			ParticleEffectAt_Parent(startPos, PARTICLE_GODFATHER_MOLOTOV, entity);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, GodfatherMolotov_Gravity);
			DispatchKeyValueFloat(entity, "modelscale", 1.66);
		}
	}
}

public Action GodfatherMolotov_ProjectileHit(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_GODFATHER_MOLOTOV_EXPLODE, 2.0);
	EmitSoundToAll(SOUND_GODFATHER_MOLOTOV_EXPLODE_1, entity, _, _, _, 0.8, GetRandomInt(80, 110));
	EmitSoundToAll(SOUND_GODFATHER_MOLOTOV_EXPLODE_2, entity, _, _, _, 0.8, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(GodfatherMolotov_DMG, IsValidEntity(owner) ? owner : entity, entity, entity, position, GodfatherMolotov_Radius, GodfatherMolotov_Falloff_MultiHit, GodfatherMolotov_Falloff_Range, isBlue, _, true, GodfatherMolotov_EntityMult);

	RemoveEntity(entity);
		
	return Plugin_Continue;
}

public Action Godfather_ProjectileHit(int entity, int other)
{
	if (!IsValidEntity(other))
		return Plugin_Continue;
		
	int team1 = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(other, Prop_Send, "m_iTeamNum");
	
	if (team1 != team2)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		float damage = (ShouldNpcDealBonusDamage(other) ? Friends_EntityDMG : Friends_DMG);
		SDKHooks_TakeDamage(other, entity, IsValidEntity(owner) ? owner : entity, damage);
			
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, PARTICLE_GODFATHER_GUNS_HIT, 2.0);
		EmitSoundToAll(SOUND_GODFATHER_GUNS_HIT, entity, _, _, _, 0.8, GetRandomInt(80, 110));

		RemoveEntity(entity);
	}
		
	return Plugin_Continue;
}

public void Godfather_NPCDeath(int entity)
{
	Godfather npc = view_as<Godfather>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	float pos[3];
	WorldSpaceCenter(entity, pos);
	Godfather_ShootProjectile(npc, pos, pos, NULL_VECTOR, true);
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}