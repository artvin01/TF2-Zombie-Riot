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

//LITTLE FRIENDS: Godfather Grimme slows down and aims both of his guns at the same target, then rapidly unloads them onto the poor bastard.
//Godfather Grimme has incredible aim and will predict his target's location at any distance, but his guns are not as accurate as he is and have a large spread penalty.
static float Friends_DMG = 40.0;				//Projectile damage.
static float Friends_Velocity = 1200.0;			//Projectile velocity.
static float Friends_Spread = 9.0;				//Projectile spread.
static float Friends_Lifespan = 2.5;			//Projectile lifespan.
static float Friends_AttackRate = 0.08;			//Attack interval.
static float Friends_Duration = 6.0;			//Attack duration.
static float Friends_Cooldown = 20.0;			//Attack cooldown.
static float Friends_StartingCooldown = 20.0;	//Cooldown upon spawning.

//DIRTY KICK: One of Godfather Grimme's melee attacks, in which he delivers a swift kick in the dick to his target. This deals low damage, but hard-stuns the victim.
//This can only be used against players, and has a slow wind-up phase. If it hits, he will always follow up with LITTLE FRIENDS, unless it's on cooldown in which he will
//use NORMAL KICK.
static float Dirty_DMG = 120.0;			//Dirty Kick damage.
static float Dirty_Stun = 6.0;			//Dirty Kick stun duration.
static float Dirty_Length = 120.0;		//Dirty Kick hitbox length.
static float Dirty_Width = 45.0;		//Dirty Kick hitbox width.
static float Dirty_Cooldown = 30.0;		//Dirty Kick cooldown.

//NORMAL KICK: Godfather Grimme's other melee attack, where he kicks his target in the gut, dealing heavy damage in addition to knockback.
static float Kick_DMG = 120.0;			//Normal Kick damage.
static float Kick_Knockback = 900.0;	//Normal Kick knockback force.
static float Kick_Length = 140.0;		//Normal Kick hitbox length.
static float Kick_Width = 60.0;			//Normal Kick hitbox width.
static float Kick_Cooldown = 30.0;		//Normal Kick cooldown.

static char g_OfferDialogue[][] = {
	"{corrupted}Godfather Grimme{default}: Go make {orangered}%s{default} an offer they can't refuse...",
	"{corrupted}Godfather Grimme{default}: It's not personal, {orangered}%s{default}. It's strictly business."
};

static char g_OfferDialogue_Wounded[][] = {
	"{corrupted}Godfather Grimme{default}: I want {orangered}%s{default} dead! I want their family dead! I want their house burned to the ground!"
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

#define SOUND_OFFER_MARKED		")mvm/mvm_cpoint_klaxon.wav"

#define PARTICLE_OFFER_MARKED		"teleportedin_red"
#define PARTICLE_OFFER_MARKED_TRAIL	"player_recent_teleport_red"
#define PARTICLE_OFFER_RECEIVED		"spell_batball_impact_blue_3"

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

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Godfather Grimme");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_godfather");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Godfather;
	NPC_Add(data);
}

static any Summon_Godfather(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Godfather(client, vecPos, vecAng, ally);
}

static float f_NextOffer[MAXENTITIES] = { 0.0, ... };

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

	public Godfather(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		Godfather npc = view_as<Godfather>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, GODFATHER_SCALE, GODFATHER_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		f_NextOffer[npc.index] = GetGameTime(npc.index) + Offer_StartingCooldown;
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(Godfather_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Godfather_OnTakeDamage);
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
		
		return npc;
	}
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
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	int closest = npc.m_iTarget;

	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother, true);
				
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; 
			PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, closest);
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
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	npc.PlayIdleSound();
}


public Action Godfather_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;

	Godfather npc = view_as<Godfather>(victim);
	//TODO: Fill this out if needed, scrap if not

	return Plugin_Changed;
}

public void Godfather_NPCDeath(int entity)
{
	Godfather npc = view_as<Godfather>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}