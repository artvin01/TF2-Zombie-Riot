#pragma semicolon 1
#pragma newdecls required

#define CAPTAIN_SCALE			"1.3"
#define CAPTAIN_HP			"500000"
#define CAPTAIN_SKIN			"1"

static float CAPTAIN_SPEED = 260.0;

//ANCHOR BREAKER: Faux-Beard slams the anchor down, hitting all enemies within a small range for ENORMOUS damage. This attack can be activated from a distance. If this happens, Faux-Beard will sprint straight to his target before attacking.
//The sprint has its own independent cooldown, separate from the melee attack itself.
static float Anchor_DMG = 1600.0;				//Damage dealt.
static float Anchor_EntityMult = 4.0;			//Entity multiplier.
static float Anchor_Falloff_Range = 0.5;		//Falloff based on range.
static float Anchor_Falloff_MultiHit = 0.75;	//Falloff based on number of hits.
static float Anchor_Radius = 85.0;				//Damage radius.
static float Anchor_HitRange = 90.0;			//Range in which the melee attack will begin.
static float Anchor_SprintRange = 1200.0;		//Range in which Faux-Beard will begin sprinting to his target if they are out of range when the ability is activated.
static float Anchor_SprintSpeed = 520.0;		//Speed while sprinting to the target.
static float Anchor_Cooldown_Sprint = 20.0;		//Sprint cooldown.
static float Anchor_Cooldown = 5.0;				//Attack cooldown.
static float Anchor_StartingCooldown = 4.0;		//Starting cooldown.
static float Anchor_SpeedMult = 0.66;			//Maximum additional animation speed multiplier based on health lost.
static float Anchor_CDMult = 0.66;				//Maximum cooldown reduction multiplier based on health lost.
static float Anchor_MinHP = 0.25;				//Percentage of max HP at which animation speed reaches max.
static int Anchor_MaxTargets = 4;				//Maximum targets hit at once by Anchor Breaker.

//KEELHAUL: Faux-Beard throws his anchor forwards, dealing splash damage and knockback at the point of impact. The anchor will bounce several times, dealing splash damage with
//every bounce.
static float Keelhaul_DMG = 250.0;				//Base damage.
static float Keelhaul_KB = 600.0;				//Vertical knockback inflicted to enemies who are hit by the anchor.
static float Keelhaul_Velocity = 2400.0;		//Velocity with which the anchor is thrown out.
static float Keelhaul_Gravity = 3.5;			//Anchor gravity.
static float Keelhaul_Cooldown = 16.0;			//Ability cooldown.
static float Keelhaul_StartingCooldown = 2.0;	//Starting cooldown.
static float Keelhaul_Range = 1200.0;			//Maximum range in which this ability can be used.
static float Keelhaul_ThrowRange = 2400.0;		//Attempted throw distance (gravity will reduce this in-game).
static int Keelhaul_Bounces = 5;				//Number of times the anchor will bounce.
static float Keelhaul_Radius = 120.0;			//Damage radius.
static float Keelhaul_Falloff_MultiHit = 0.66;	//Amount to multiply damage per target hit.
static float Keelhaul_Falloff_Radius = 0.5;		//Max falloff.
static float Keelhaul_EntityMult = 6.0;			//Entity multiplier.
static int Keelhaul_KBMode = 0;					//If set to 1: Knockback velocity completely overrides the victim's existing velocity. Otherwise, it is added onto their current velocity.

//MORALE BOOST: Faux-Beard rallies his allies with a battle cry, permanently buffing all allies within a large radius and healing them for a percentage of their max HP.
static float Morale_Radius = 600.0;				//Ability radius.
static float Morale_Heal = 0.66;				//Percentage of allied HP to heal for.
static float Morale_MinHeal = 1000.0;			//Minimum HP to heal allies for.
static float Morale_MaxHeal = 20000.0;			//Maximum HP to heal allies for.
static float Morale_Cooldown = 20.0;			//Ability cooldown.
static float Morale_StartingCooldown = 10.0;	//Starting cooldown.
static int Morale_MinAllies = 3;				//Minimum allies required to be in range before this ability can be used.

//BLACK PEARLS: Faux-Beard rapidly fires a ton of bombs from his Loose Cannon, which explode on impact and deal heavy damage within a small radius. He is slowed down during this.
static float Pearls_Duration = 6.0;				//Attack duration.
static float Pearls_Interval = 0.33;			//Interval between shots while active.
static float Pearls_Velocity = 1200.0;			//Bomb velocity.
static float Pearls_Gravity = 0.5;				//Bomb gravity.
static float Pearls_DMG = 120.0;				//Bomb damage.
static float Pearls_EntityMult = 24.0;			//Entity damage multiplier.
static float Pearls_Radius = 80.0;				//Bomb radius.
static float Pearls_Falloff_Radius = 0.5;		//Falloff based on distance.
static float Pearls_Falloff_MultiHit = 0.8;		//Multi-hit falloff.
static float Pearls_Speed = 130.0;				//Movement speed while firing bombs.
static float Pearls_Cooldown = 25.0;			//Cooldown.
static float Pearls_StartingCooldown = 25.0;	//Starting cooldown.

//DEATH RATTLE: When killed, Faux-Beard stumbles forward, slamming his anchor into the ground for one final Anchor-Breaker before collapsing.

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

static char g_MoraleBoostDialogue[][] = {
	"{vintage}Captain Faux-Beard, Terror of the Dead Sea{default}: LET'S KEELHAUL THE POOR BASTARDS, LADDIES!",
	"{vintage}Captain Faux-Beard, Terror of the Dead Sea{default}: YARR, THEIR BODIES’LL BE NOT OF ONE PIECE WHENCE WE BE DONE WITH ‘EM!",
	"{vintage}Captain Faux-Beard, Terror of the Dead Sea{default}: LET’S SHOW THESE LANDLUBBERS THE MIGHT OF THE DEAD SEA!",
	"{vintage}Captain Faux-Beard, Terror of the Dead Sea{default}: LET’S MAKE ‘EM WISH THEY COULD STILL WALK THE PLANK!",
	"{vintage}Captain Faux-Beard, Terror of the Dead Sea{default}: THERE BE NO SCURVY FOR BONES, LADS! NOT A THING CAN STOP US NOW!"
};

#define SOUND_CAPTAIN_HEAVY_WHOOSH		")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_MORALE_BOOST				")misc/halloween/spell_lightning_ball_cast.wav"
#define SOUND_PEARLS_FIRE				")weapons/loose_cannon_shoot.wav"
#define SOUND_PEARLS_EXPLODE			")weapons/loose_cannon_explode.wav"
#define SOUND_ANCHOR_BREAKER_IMPACT_1	")mvm/giant_soldier/giant_soldier_rocket_explode.wav"
#define SOUND_ANCHOR_BREAKER_IMPACT_2	")weapons/demo_charge_hit_world3.wav"
#define SOUND_CAPTAIN_RUSTLE			")player/cyoa_pda_draw.wav"
#define SOUND_ANCHOR_BOUNCE				")weapons/bumper_car_hit_ball.wav"

#define PARTICLE_MORALE_BOOST_RED		"spell_cast_wheel_red"
#define PARTICLE_MORALE_BOOST_BLUE		"spell_cast_wheel_blue"
#define PARTICLE_MORALE_BOOST_BLAST		"doomsday_tentpole_vanish01"
#define PARTICLE_PEARLS_MUZZLE			"muzzle_bignasty"
#define PARTICLE_PEARLS_EXPLODE			"ExplosionCore_MidAir_underwater"
#define PARTICLE_PEARLS_TRAIL			"fuse_sparks"
#define PARTICLE_ANCHOR_BREAKER_IMPACT	"hammer_impact_button_dust2"
#define PARTICLE_CAPTAIN_ANCHOR_CHAIN	"utaunt_chain_chain_green"
#define PARTICLE_CAPTAIN_ANCHOR_CHAIN_SPAWN	"merasmus_zap"

#define MODEL_PEARLS					"models/weapons/w_models/w_cannonball.mdl"

static float f_NextAnchor[MAXENTITIES] = { 0.0, ... };
static float f_NextAnchorSprint[MAXENTITIES] = { 0.0, ... };
static float f_NextMorale[MAXENTITIES] = { 0.0, ... };
static float f_NextPearls[MAXENTITIES] = { 0.0, ... };
static float f_NextKeelhaul[MAXENTITIES] = { 0.0, ... };
static float Captain_PearlsEndTime[MAXENTITIES] = { 0.0, ... };

static bool Captain_Attacking[MAXENTITIES] = { false, ... };
static bool Captain_RevertSequence[MAXENTITIES] = { false, ... };
static bool Captain_StopMoving[MAXENTITIES] = { false, ... };
static bool Captain_UsingPearls[MAXENTITIES] = { false, ... };
static bool Captain_SetPearlsLoop[MAXENTITIES] = { false, ... };
static bool b_AnchorSprinting[MAXENTITIES] = { false, ... };

static char s_CaptainSequence[MAXENTITIES][255];
static bool b_CaptainForceSequence[MAXENTITIES] = { false, ... };

static int Anchor_Prop[MAXENTITIES] = { -1, ... };
static int Anchor_Bounces[MAXENTITIES] = { -1, ... };

public void Captain_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SOUND_CAPTAIN_HEAVY_WHOOSH);
	PrecacheSound(SOUND_MORALE_BOOST);
	PrecacheSound(SOUND_PEARLS_FIRE);
	PrecacheSound(SOUND_PEARLS_EXPLODE);
	PrecacheSound(SOUND_ANCHOR_BREAKER_IMPACT_1);
	PrecacheSound(SOUND_ANCHOR_BREAKER_IMPACT_2);
	PrecacheSound(SOUND_CAPTAIN_RUSTLE);
	PrecacheSound(SOUND_ANCHOR_BOUNCE);

	PrecacheModel(MODEL_PEARLS);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Captain Faux-Beard, Terror of the Dead Sea");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_captain");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Necropolain;
	data.Func = Summon_Captain;
	NPC_Add(data);
}

static any Summon_Captain(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Captain(vecPos, vecAng, ally);
}

methodmap Captain < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, _, _, _, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CCaptain::PlayMeleeHitSound()");
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

	public bool CanUseMoraleBoost()
	{
		if (GetGameTime(this.index) < f_NextMorale[this.index] || Captain_Attacking[this.index])
			return false;

		int numAllies;

		float myPos[3], allyPos[3];
		WorldSpaceCenter(this.index, myPos);

		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidEntity(i) || i_IsABuilding[i] || i == this.index)
				continue;
			
			if (!IsValidAlly(this.index, i))
				continue;

			WorldSpaceCenter(i, allyPos);
			if (GetVectorDistance(myPos, allyPos) <= Morale_Radius)
			{
				numAllies++;
			}
		}

		return numAllies >= Morale_MinAllies;
	}

	public bool CanUsePearls()
	{
		if (GetGameTime(this.index) < f_NextPearls[this.index] || Captain_Attacking[this.index])
			return false;

		return true;
	}

	public bool CanUseAnchor()
	{
		if (GetGameTime(this.index) < f_NextAnchor[this.index] || (!b_AnchorSprinting[this.index] && Captain_Attacking[this.index]))
			return false;

		return true;
	}

	public bool CanUseKeelhaul(float dist)
	{
		if (GetGameTime(this.index) < f_NextKeelhaul[this.index] || Captain_Attacking[this.index] || dist > Keelhaul_Range)
			return false;

		return true;
	}

	public void AnchorBreaker(int target)
	{
		Captain_Attacking[this.index] = true;
		Captain_StopMoving[this.index] = true;
		b_AnchorSprinting[this.index] = false;

		float pos[3];
		WorldSpaceCenter(target, pos);
		this.FaceTowards(pos, 15000.0);

		int activity = this.LookupActivity("ACT_CAPTAIN_ANCHOR_BREAKER");
		if (activity > 0)
		{
			float hp = float(GetEntProp(this.index, Prop_Data, "m_iHealth"));
			float maxHP = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));

			float ratio = hp / maxHP;

			float rate = 1.0;
			if (ratio < 1.0)
			{
				if (ratio < Anchor_MinHP)
					rate += Anchor_SpeedMult;
				else
				{
					float diff = (1.0 - ratio) / (1.0 - Anchor_MinHP);
					rate += Anchor_SpeedMult * diff;
				}
			}

			this.StartActivity(activity);
			this.SetPlaybackRate(rate);
		}
	}

	public void GetPearlsTarget(float buffer[3])
	{
		int target = this.m_iTarget;
		if (IsValidEnemy(this.index, target) && Can_I_See_Enemy_Only(this.index, target))
		{
			WorldSpaceCenter(target, buffer);
		}
		else
		{
			float ang[3], Direction[3], startPos[3];
			this.GetAttachment("muzzle_cannon", startPos, ang);
			GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, 200.0);
			AddVectors(startPos, Direction, buffer);
		}
	}

	public Captain(float vecPos[3], float vecAng[3], int ally)
	{	
		Captain npc = view_as<Captain>(CClotBody(vecPos, vecAng, BONEZONE_MODEL_BOSS, CAPTAIN_SCALE, CAPTAIN_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(Captain_NPCDeath);
		//func_NPCOnTakeDamage[npc.index] = view_as<Function>(Captain_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Captain_ClotThink);
		func_NPCAnimEvent[npc.index] = Captain_AnimEvent;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_CAPTAIN_WALK");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", CAPTAIN_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = CAPTAIN_SPEED;

		npc.StartPathing();

		f_NextAnchor[npc.index] = GetGameTime(npc.index) + Anchor_StartingCooldown;
		f_NextAnchorSprint[npc.index] = GetGameTime(npc.index) + Anchor_StartingCooldown;
		f_NextMorale[npc.index] = GetGameTime(npc.index) + Morale_StartingCooldown;
		f_NextPearls[npc.index] = GetGameTime(npc.index) + Pearls_StartingCooldown;
		f_NextKeelhaul[npc.index] = GetGameTime(npc.index) + Keelhaul_StartingCooldown;

		Captain_Attacking[npc.index] = false;
		Captain_RevertSequence[npc.index] = false;
		Captain_StopMoving[npc.index] = false;
		Captain_UsingPearls[npc.index] = false;
		Captain_SetPearlsLoop[npc.index] = false;
		b_AnchorSprinting[npc.index] = false;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Captain_ClotThink(int iNPC)
{
	Captain npc = view_as<Captain>(iNPC);
	
	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if (Captain_RevertSequence[npc.index])
	{
		int activity = npc.LookupActivity("ACT_CAPTAIN_WALK");
		if (activity > 0)
			npc.StartActivity(activity);

		Captain_RevertSequence[npc.index] = false;
	}

	if (b_CaptainForceSequence[npc.index])
	{
		int activity = npc.LookupActivity(s_CaptainSequence[npc.index]);
		if (activity > 0)
			npc.StartActivity(activity);

		b_CaptainForceSequence[npc.index] = false;
	}

	npc.m_flNextDelayTime = GetGameTime(npc.index) + (Captain_Attacking[npc.index] ? 0.0 : DEFAULT_UPDATE_DELAY_FLOAT);
	
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
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + (Captain_Attacking[npc.index] ? 0.0 : 0.1);
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	if (Captain_SetPearlsLoop[npc.index])
	{
		npc.AddGesture("ACT_CAPTAIN_HOLD_GUN", false, _, false);
		Captain_SetPearlsLoop[npc.index] = false;
	}

	if (npc.CanUseMoraleBoost())
	{
		int activity = npc.LookupActivity("ACT_CAPTAIN_RALLY");
		if (activity > 0)
			npc.StartActivity(activity);

		npc.StopPathing();

		Captain_StopMoving[npc.index] = true;
		Captain_Attacking[npc.index] = true;

		CPrintToChatAll(g_MoraleBoostDialogue[GetRandomInt(0, sizeof(g_MoraleBoostDialogue) - 1)]);
	}

	if (npc.CanUsePearls())
	{
		npc.AddGesture("ACT_CAPTAIN_DEPLOY_GUN");

		npc.m_flSpeed = Pearls_Speed;

		Captain_Attacking[npc.index] = true;

		EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], npc.index, _, _, _, _, 80);
	}

	if (Captain_UsingPearls[npc.index])
	{
		if (GetGameTime(npc.index) > Captain_PearlsEndTime[npc.index])
		{
			npc.RemoveAllGestures();
			Captain_UsingPearls[npc.index] = false;
			Captain_Attacking[npc.index] = false;
			f_NextPearls[npc.index] = GetGameTime(npc.index) + Pearls_Cooldown;
			npc.m_flSpeed = CAPTAIN_SPEED;
		}
		else if (GetGameTime(npc.index) >= npc.m_flNextRangedAttack)
		{
			npc.AddGesture("ACT_CAPTAIN_SHOOT_GUN", _, _, _, (Pearls_Interval < 0.41 ? 0.41 / Pearls_Interval : 1.0));

			float pos[3], ang[3], vicPos[3];
			npc.GetAttachment("cannon_muzzle", pos, ang);
			ParticleEffectAt(pos, PARTICLE_PEARLS_MUZZLE);

			npc.GetPearlsTarget(vicPos);
			npc.FaceTowards(vicPos, 15000.0);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

			Captain_ShootProjectile(npc, vicPos, pos, ang);

			EmitSoundToAll(SOUND_PEARLS_FIRE, npc.index, _, _, _, _, GetRandomInt(80, 110));
			EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, _, _, _, GetRandomInt(70, 90));

			npc.m_flNextRangedAttack = GetGameTime(npc.index) + Pearls_Interval;
		}
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

		if (npc.CanUseAnchor())
		{
			if (flDistanceToTarget <= Anchor_HitRange)
			{
				npc.AnchorBreaker(closest);
			}
			else if (flDistanceToTarget <= Anchor_SprintRange && GetGameTime(npc.index) >= f_NextAnchorSprint[npc.index] && !b_AnchorSprinting[npc.index])
			{
				f_NextAnchorSprint[npc.index] = GetGameTime(npc.index) + Anchor_Cooldown_Sprint;
				npc.m_flSpeed = Anchor_SprintSpeed;
				Captain_Attacking[npc.index] = true;
				EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, 120, _, _, 80);
				b_AnchorSprinting[npc.index] = true;
				int activity = npc.LookupActivity("ACT_CAPTAIN_RUN");
				if (activity > 0)
					npc.StartActivity(activity);
			}
		}

		//Ability scrapped entirely due to a shit load of technical limitations.
		if (npc.CanUseKeelhaul(flDistanceToTarget))
		{
			npc.FaceTowards(vecTarget, 15000.0);
			int activity = npc.LookupActivity("ACT_CAPTAIN_THROW_ANCHOR");
			if (activity > 0)
				npc.StartActivity(activity);

			Captain_StopMoving[npc.index] = true;
			npc.m_flSpeed = 0.0;
			Captain_Attacking[npc.index] = true;
			EmitSoundToAll(SOUND_CAPTAIN_RUSTLE, npc.index, _, 120);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if (Captain_StopMoving[npc.index])
		npc.StopPathing();

	npc.PlayIdleSound();
}

public void Captain_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	Captain npc = view_as<Captain>(entity);

	switch(event)
	{
		case 1001:	//Morale Boost: Faux-Beard thrusts his anchor up into the air, play a sound.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, _, _, _, GetRandomInt(90, 120));
			EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, 120, _, _, GetRandomInt(80, 90));
		}
		case 1002:	//Morale Boost: Activate buff, play a sound, do VFX, apply buff effects.
		{
			int chosen = GetRandomInt(0, sizeof(g_HHHLaughs) - 1);
			EmitSoundToAll(g_HHHLaughs[chosen], npc.index, _, 120, _, _, GetRandomInt(100, 120));
			EmitSoundToAll(g_HHHLaughs[chosen], npc.index, _, 120, _, _, GetRandomInt(80, 100));
			EmitSoundToAll(g_HHHLaughs[chosen], npc.index, _, 120, _, _, GetRandomInt(60, 80));

			float myPos[3], allyPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", myPos);

			ParticleEffectAt(myPos, PARTICLE_MORALE_BOOST_BLAST);
			EmitSoundToAll(SOUND_MORALE_BOOST, npc.index, _, _, _, _, 80);
			EmitSoundToAll(SOUND_MORALE_BOOST, npc.index, _, 120);

			for (int i = 1; i < MAXENTITIES; i++)
			{
				if (!IsValidEntity(i) || i_IsABuilding[i] || i == npc.index)
					continue;
				
				if (!IsValidAlly(npc.index, i))
					continue;

				GetEntPropVector(i, Prop_Data, "m_vecAbsOrigin", allyPos);
				if (GetVectorDistance(myPos, allyPos) <= Morale_Radius)
				{
					CClotBody ally = view_as<CClotBody>(i);
					if (ally.BoneZone_IsASkeleton() && !ally.BoneZone_GetBuffedState())
						ally.BoneZone_SetBuffedState(true);

					float health = float(GetEntProp(i, Prop_Data, "m_iHealth"));
					float maxhealth;

					if (IsValidClient(i) && dieingstate[i] == 0)
					{
						maxhealth = float(SDKCall_GetMaxHealth(i));
					}
					else if (!IsValidClient(i))
					{
						maxhealth = float(ReturnEntityMaxHealth(i));
					}

					if (maxhealth > 0.0 && health < maxhealth)
					{
						float heals = maxhealth * Morale_Heal;
						if (heals < Morale_MinHeal)
							heals = Morale_MinHeal;
						if (heals > Morale_MaxHeal)
							heals = Morale_MaxHeal;

						health += heals;
						if (health > maxhealth)
							health = maxhealth;

						SetEntProp(i, Prop_Data, "m_iHealth", RoundToFloor(health));
					}

					ParticleEffectAt(allyPos, (GetTeam(i) != 2 ? PARTICLE_MORALE_BOOST_BLUE : PARTICLE_MORALE_BOOST_RED));
					EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], i, _, _, _, _, GetRandomInt(80, 120));
				}
			}
		}
		case 1003:	//Morale Boost sequence has ended, revert sequence.
		{
			f_NextMorale[npc.index] = GetGameTime(npc.index) + Morale_Cooldown;

			Captain_RevertSequence[npc.index] = true;
			Captain_Attacking[npc.index] = false;
			Captain_StopMoving[npc.index] = false;
		}
		case 1004:	//Black Pearls intro sequence finished, transition to loop sequence and start firing.
		{
			Captain_SetPearlsLoop[npc.index] = true;
			Captain_UsingPearls[npc.index] = true;
			Captain_PearlsEndTime[npc.index] = GetGameTime(npc.index) + Pearls_Duration;
			npc.m_flNextRangedAttack = 0.0;
		}
		case 1005:	//Anchor Breaker "whoosh" effect.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index);
		}
		case 1006:	//Anchor Breaker final "whoosh".
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index);
			EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, 120, _, _, 80);
		}
		case 1007:	//Anchor Breaker hits the floor, deal damage and VFX.
		{
			float pos[3], ang[3];
			npc.GetAttachment("anchor_impact_point", pos, ang);

			bool isBlue = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
			Explode_Logic_Custom(Anchor_DMG, npc.index, npc.index, npc.index, pos, Anchor_Radius, Anchor_Falloff_MultiHit, Anchor_Falloff_Range, isBlue, Anchor_MaxTargets, _, Anchor_EntityMult);

			EmitSoundToAll(g_HHHLaughs[GetRandomInt(0, sizeof(g_HHHLaughs) - 1)], npc.index, _, 120, _, _, 80);

			int particle = ParticleEffectAt(pos, PARTICLE_ANCHOR_BREAKER_IMPACT);
			if (IsValidEntity(particle))
			{
				EmitSoundToAll(SOUND_ANCHOR_BREAKER_IMPACT_1, particle, _, 120);
				EmitSoundToAll(SOUND_ANCHOR_BREAKER_IMPACT_2, particle, _, 120);
			}
			
		}
		case 1008:	//Anchor Breaker is over, revert to normal behavior.
		{
			b_AnchorSprinting[npc.index] = false;
			Captain_Attacking[npc.index] = false;
			Captain_StopMoving[npc.index] = false;
			Captain_RevertSequence[npc.index] = true;
			npc.m_flSpeed = CAPTAIN_SPEED;

			float cd = Anchor_Cooldown;

			float hp = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float maxHP = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

			float ratio = hp / maxHP;

			float mult = 1.0;
			if (ratio < 1.0)
			{
				if (ratio < Anchor_MinHP)
					mult = Anchor_CDMult;
				else
				{
					float diff = (1.0 - ratio) / (1.0 - Anchor_MinHP);
					mult -= Anchor_CDMult * diff;
				}
			}

			f_NextAnchor[npc.index] = GetGameTime(npc.index) + (cd * mult);
		}
		case 1009:	//Anchor toss begins, play sound.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, _, _, _, GetRandomInt(90, 120));
			EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, 120, _, _, GetRandomInt(80, 90));
		}
		case 1010:	//Anchor has been tossed, play sound and fire projectile.
		{
			float pos[3], ang[3], targPos[3], Direction[3], vel[3];
			WorldSpaceCenter(npc.index, pos);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

			GetAngleVectors(ang, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, Keelhaul_ThrowRange);
			AddVectors(pos, Direction, targPos);

			npc.GetAttachment("handR", pos, ang);
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

			int anchor = npc.FireRocket(targPos, 0.0, Keelhaul_Velocity, "models/weapons/w_models/w_drg_ball.mdl");
			DispatchKeyValueFloat(anchor, "modelscale", 0.01);
			if (IsValidEntity(anchor))
			{
				if (h_NpcSolidHookType[anchor] != 0)
					DHookRemoveHookID(h_NpcSolidHookType[anchor]);
				h_NpcSolidHookType[anchor] = 0;

				SetEntityGravity(anchor, Keelhaul_Gravity); 	
				ArcToLocationViaSpeedProjectile(pos, targPos, vel, 2.0, 1.0);
				SetEntityMoveType(anchor, MOVETYPE_FLYGRAVITY);
				TeleportEntity(anchor, pos, ang, vel);

				int prop = CreateEntityByName("prop_dynamic_override");
				if (IsValidEntity(prop))
				{
					SetEntityModel(prop, BONEZONE_MODEL_BOSS);

					DispatchSpawn(prop);
					ActivateEntity(prop);

					SetVariantString("captain_anchor_flying");
					AcceptEntityInput(prop, "SetAnimation");

					TeleportEntity(prop, pos, ang);
					SetParent(anchor, prop);

					DispatchKeyValueFloat(prop, "modelscale", 0.01);
					CreateTimer(0.1, Captain_UnhideAnchor, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);

					Anchor_Prop[anchor] = EntIndexToEntRef(prop);
				}

				h_NpcSolidHookType[anchor] = g_DHookRocketExplode.HookEntity(Hook_Pre, anchor, Captain_AnchorCollide);
				RequestFrame(Captain_ScanForAnchorCollision, EntIndexToEntRef(anchor));
				Anchor_Bounces[anchor] = Keelhaul_Bounces;
				//Trail_Attach
			}
		}
		case 1011:	//Anchor toss animation is finished, switch to waiting phase.
		{
			s_CaptainSequence[npc.index] = "ACT_CAPTAIN_WALK";
			Captain_Attacking[npc.index] = false;
			f_NextKeelhaul[npc.index] = GetGameTime(npc.index) + Keelhaul_Cooldown;
			Captain_StopMoving[npc.index] = false;
			b_CaptainForceSequence[npc.index] = true;
		}
	}
}

public Action Captain_UnhideAnchor(Handle timer, int ref)
{
	int ent = EntRefToEntIndex(ref);
	if (IsValidEntity(ent))
		DispatchKeyValueFloat(ent, "modelscale", StringToFloat(CAPTAIN_SCALE));

	return Plugin_Continue;
}

int Anchor_FilterUser = -1;

public void Anchor_PredictEndPoint(float pos[3], float ang[3], float DistanceTraveled, float EndPoint[3])
{		
	for (int vec = 0; vec < 3; vec++)
	{
		EndPoint[vec] = pos[vec] + (ang[vec] * DistanceTraveled);
	}
}

public bool Anchor_Filter(int entity, int contentsMask, int data)
{
	//int owner = GetEntPropEnt(Anchor_FilterUser, Prop_Send, "m_hOwnerEntity");

	if (entity == Anchor_FilterUser)
		return false;

	if (IsValidAlly(Anchor_FilterUser, entity) || IsValidAllyPlayer(Anchor_FilterUser, entity))
		return false;
	
	return true;
}

public void Captain_ScanForAnchorCollision(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if (!IsValidEntity(entity))
		return;

	float pos[3], vel[3], RealVel[3], EndPoint[3], HitPoint[3], angles[3], DistanceTraveled;
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", RealVel);
	GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
	for (int j = 0; j < 3; j++)
	{
		vel[j] = RealVel[j] / 63.0;
	}			
			
	DistanceTraveled = GetVectorLength(vel); //The distance the anchor will travel this frame.

	Anchor_PredictEndPoint(pos, vel, DistanceTraveled, EndPoint);

	Anchor_FilterUser = entity;
	Handle trace = TR_TraceRayFilterEx(pos, EndPoint, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, Anchor_Filter, entity);

	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		TR_GetEndPosition(HitPoint, trace);

		if (GetVectorDistance(pos, HitPoint) <= DistanceTraveled)
		{
			bool HitPlayer = IsValidClient(target);

			int particle = ParticleEffectAt(pos, PARTICLE_ANCHOR_BREAKER_IMPACT);
			if (IsValidEntity(particle))
			{
				EmitSoundToAll(SOUND_ANCHOR_BREAKER_IMPACT_1, particle, _, 120);
				EmitSoundToAll(SOUND_ANCHOR_BREAKER_IMPACT_2, particle, _, 120);
				EmitSoundToAll(SOUND_ANCHOR_BOUNCE, particle, _, 120, _, _, GetRandomInt(80, 110));
			}

			int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
			bool isBlue = (IsValidEntity(owner) ? GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue) : true);

			Explode_Logic_Custom(Keelhaul_DMG, IsValidEntity(owner) ? owner : entity, entity, entity, pos, Keelhaul_Radius, Keelhaul_Falloff_MultiHit, Keelhaul_Falloff_Radius, isBlue, _, _, Keelhaul_EntityMult, view_as<Function>(Keelhaul_OnHit_KB));
		
			if (Anchor_Bounces[entity] < 0)
			{
				RemoveEntity(entity);
			}
			else
			{
				Anchor_Bounces[entity]--;
				
				GetAngleToPoint(entity, HitPoint, angles, angles);
				for (int i = 0; i < 3; i++)
					angles[i] *= -1.0;

				for (int check = 0; check < 3; check++)
				{
					if (HitPlayer) //Always bounce if it hits a player, don't even try to commence proper bounce logic because for some reason it doesn't work half the time if it bounces off players
					{
						RealVel[check] *= -1.0;
					}
					else
					{
						float tempVel[3];
						tempVel[0] = 0.0;
						tempVel[1] = 0.0;
						tempVel[2] = 0.0;
						tempVel[check] = vel[check];
						//DistanceTraveled = GetVectorLength(tempVel);
								
						Anchor_PredictEndPoint(pos, tempVel, DistanceTraveled, EndPoint);
								
						trace = TR_TraceRayFilterEx(pos, EndPoint, ( MASK_SOLID | CONTENTS_SOLID ), RayType_EndPoint, Anchor_Filter, entity);

						if (TR_DidHit(trace))
						{
							TR_GetEndPosition(HitPoint, trace);
									
							if (GetVectorDistance(pos, HitPoint) <= DistanceTraveled)
							{
								RealVel[check] *= -1.0;
							}
						}
					}
				}

				TeleportEntity(entity, _, angles, RealVel);
			}		
		}
	}

	delete trace;

	RequestFrame(Captain_ScanForAnchorCollision, ref);
}

public void Keelhaul_OnHit_KB(int attacker, int victim, float damage)
{
	if (b_NoKnockbackFromSources[victim] || b_NpcIsInvulnerable[victim] || i_IsABuilding[victim])
		return;

	float vel[3];
	
	if (Keelhaul_KBMode == 1)
	{
		vel[2] = Keelhaul_KB;
	}
	else
	{
		GetEntPropVector(victim, Prop_Data, "m_vecVelocity", vel);
		if (vel[2] < 0.0)
			vel[2] = Keelhaul_KB;
		else
			vel[2] += Keelhaul_KB;
	}

	if (IsValidClient(victim))
		TeleportEntity(victim, _, _, vel);
	else
		Anchor_NPCKB(victim, vel);
}

public void Anchor_NPCKB(int target, float targVel[3])
{
	//In tower defense, do not allow moving the target.
	if(VIPBuilding_Active())
		return;
		
	if(f_NoUnstuckVariousReasons[target] > GetGameTime() + 1.0)
	{
		//make the target not stuckable.
		f_NoUnstuckVariousReasons[target] = GetGameTime() + 1.0;
	}
	SDKUnhook(target, SDKHook_Think, NpcJumpThink);
	f3_KnockbackToTake[target] = targVel;
	SDKHook(target, SDKHook_Think, NpcJumpThink);
}

public MRESReturn Captain_AnchorCollide(int entity)
{
	return MRES_Supercede; //DONT.
}

void Captain_ShootProjectile(Captain npc, float vicLoc[3], float startPos[3], float startAng[3])
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecAngles[3], currentAngles[3], buffer[3];

		currentAngles = startAng;
		Priest_GetAngleToPoint(npc.index, startPos, vicLoc, buffer, vecAngles);
		vecAngles[1] = currentAngles[1];
		vecAngles[2] = currentAngles[2];
			
		GetAngleVectors(vecAngles, buffer, NULL_VECTOR, NULL_VECTOR);
		vecForward[0] = buffer[0] * Pearls_Velocity;
		vecForward[1] = buffer[1] * Pearls_Velocity;
		vecForward[2] = buffer[2] * Pearls_Velocity;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);

		TeleportEntity(entity, startPos, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		SetEntityModel(entity, MODEL_PEARLS);
		
		for(int i = 0; i < 3; i++)
			vecAngles[i] = GetRandomFloat(0.0, 360.0);

		TeleportEntity(entity, NULL_VECTOR, vecAngles, vecForward, true);
		RequestFrame(SpinEffect, EntIndexToEntRef(entity));
		SetEntProp(entity, Prop_Send, "m_nSkin",  (GetTeam(entity)-2));

		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);
		
		if (h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;

		h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rattler_DontExplode);
		SDKHook(entity, SDKHook_Touch, Captain_BombHit);
		ParticleEffectAt_Parent(startPos, PARTICLE_PEARLS_TRAIL, entity, "attach_fuse");
		SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
		SetEntityGravity(entity, Pearls_Gravity);
		DispatchKeyValueFloat(entity, "modelscale", 1.25);
	}
}


public Action Captain_BombHit(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_PEARLS_EXPLODE);
	EmitSoundToAll(SOUND_PEARLS_EXPLODE, entity, _, 120, _, _, GetRandomInt(80, 110));

	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(Pearls_DMG, IsValidEntity(owner) ? owner : entity, entity, entity, position, Pearls_Radius, Pearls_Falloff_MultiHit, Pearls_Falloff_Radius, isBlue, _, _, Pearls_EntityMult);

	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public void Captain_NPCDeath(int entity)
{
	Captain npc = view_as<Captain>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}