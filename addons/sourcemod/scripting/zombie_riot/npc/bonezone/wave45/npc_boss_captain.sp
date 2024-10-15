#pragma semicolon 1
#pragma newdecls required

#define CAPTAIN_SCALE			"1.3"
#define CAPTAIN_HP			"500000"
#define CAPTAIN_SKIN			"1"

static float CAPTAIN_SPEED = 260.0;

//ANCHOR BREAKER: Faux-Beard slams the anchor down, hitting all enemies within a small range for 80% of their max HP + 200. This attack can be activated from a distance. If this happens, Faux-Beard will sprint straight to his target before attacking.
//The sprint has its own independent cooldown, separate from the melee attack itself.
static float Anchor_DMG_Flat = 200.0;		//Flat damage dealt by the attack.
static float Anchor_DMG_Percent = 0.8;		//Percentage of the target's HP added to the attack's damage (DOES NOT AFFECT BUILDINGS).
static float Anchor_DMG_Buildings = 4000.0;	//Damage dealt to buildings.
static float Anchor_Length = 120.0;			//Hitbox length.
static float Anchor_Width = 60.0;			//Hitbox width.
static float Anchor_HitRange = 90.0;		//Range in which the melee attack will begin.
static float Anchor_SprintRange = 1200.0;	//Range in which Faux-Beard will begin sprinting to his target if they are out of range when the ability is activated.
static float Anchor_SprintSpeed = 520.0;	//Speed while sprinting to the target.
static float Anchor_Cooldown_Sprint = 20.0;	//Sprint cooldown.
static float Anchor_Cooldown = 5.0;			//Attack cooldown.
static float Anchor_StartingCooldown = 4.0;	//Starting cooldown.

//KEELHAUL: Faux-Beard throws his anchor forwards, dealing damage and knockback to whoever it hits. Once the anchor hits the floor, Faux-Beard waits X seconds before pulling it back with a chain, dealing rapid damage to anyone the anchor hits
//on the way back, pulling them with it. He will always follow up with Anchor Breaker if at least one enemy who was pulled is within melee range after the attack ends.
static float Keelhaul_DMG_Out = 200.0;		//Damage dealt if the anchor hits someone while it is not being pulled back.
static float Keelhaul_DMG_In = 20.0;		//Damage dealt if the anchor hits someone while being pulled back.
static float Keelhaul_KB_Out = 600.0;		//Knockback inflicted to enemies who are hit by the anchor when it is thrown out.
static float Keelhaul_KB_In = 900.0;		//Strength with which enemies are pulled towards Faux-Beard when they are hit by the anchor while it is being reeled in.
static float Keelhaul_PullIn_TickRate = 0.33;	//Interval in which the anchor hits enemies and drags them with it while it is being pulled in.
static float Keelhaul_Velocity_Out = 1600.0;	//Velocity with which the anchor is thrown out.
static float Keelhaul_Velocity_In = 900.0;		//Velocity with which the anchor is pulled in.
static float Keelhaul_Pull_Delay = 1.0;			//Delay after the anchor hits the floor before Faux-Beard will pull it back in.
static float Keelhaul_Cooldown = 15.0;		//Ability cooldown.
static float Keelhaul_StartingCooldown = 10.0;	//Starting cooldown.

//MORALE BOOST: Faux-Beard rallies his allies with a battle cry, permanently buffing all allies within a large radius and healing them for a percentage of their max HP.
static float Morale_Radius = 600.0;			//Ability radius.
static float Morale_Heal = 0.66;			//Percentage of allied HP to heal for.
static float Morale_MinHeal = 1000.0;		//Minimum HP to heal allies for.
static float Morale_MaxHeal = 20000.0;		//Maximum HP to heal allies for.
static float Morale_Cooldown = 20.0;		//Ability cooldown.
static float Morale_StartingCooldown = 10.0;	//Starting cooldown.
static int Morale_MinAllies = 3;			//Minimum allies required to be in range before this ability can be used.

//BLACK PEARLS: Faux-Beard rapidly fires a ton of bombs from his Loose Cannon, which explode on impact and deal heavy damage within a small radius. He is slowed down during this.
static float Pearls_Duration = 6.0;			//Attack duration.
static float Pearls_Interval = 0.33;		//Interval between shots while active.
static float Pearls_Velocity = 1200.0;		//Bomb velocity.
static float Pearls_Gravity = 0.5;			//Bomb gravity.
static float Pearls_DMG = 120.0;			//Bomb damage.
static float Pearls_EntityMult = 3.0;		//Entity damage multiplier.
static float Pearls_Radius = 140.0;			//Bomb radius.
static float Pearls_Falloff_Radius = 0.66;	//Falloff based on distance.
static float Pearls_Falloff_MultiHit = 0.8;	//Multi-hit falloff.
static float Pearls_Speed = 130.0;			//Movement speed while firing bombs.
static float Pearls_Cooldown = 30.0;		//Cooldown.
static float Pearls_StartingCooldown = 30.0;	//Starting cooldown.

//CANNONKART: Faux-Beard jumps up and summons a cannon beneath his feet, which then rolls forward very quickly, flattening any enemy it collides with. If he collides with a wall or a building, Faux-Beard is briefly stunned.
static float Kart_Velocity = 2000.0;		//Speed with which the kart zooms forward.
static float Kart_Duration = 2.0;			//Active duration.
static float Kart_DMG = 500.0;				//Damage dealt to anyone the kart hits.
static float Kart_EntityDMG = 6000.0;		//Damage dealt to entities.
static float Kart_Stun = 4.0;				//Stun duration upon colliding with a wall.
static float Kart_Cooldown = 25.0;			//Cooldown.
static float Kart_StartingCooldown = 20.0;	//Starting cooldown.

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

static float f_NextAnchor[MAXENTITIES] = { 0.0, ... };
static float f_NextAnchorSprint[MAXENTITIES] = { 0.0, ... };
static float f_NextMorale[MAXENTITIES] = { 0.0, ... };
static float f_NextPearls[MAXENTITIES] = { 0.0, ... };
static float f_NextKeelhaul[MAXENTITIES] = { 0.0, ... };
static float f_NextKart[MAXENTITIES] = { 0.0, ... };

static bool Captain_Attacking[MAXENTITIES] = { false, ... };

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

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Captain Faux-Beard, Terror of the Dead Sea");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_captain");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Captain;
	NPC_Add(data);
}

static any Summon_Captain(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Captain(client, vecPos, vecAng, ally);
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

	public Captain(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		Captain npc = view_as<Captain>(CClotBody(vecPos, vecAng, BONEZONE_MODEL_BOSS, CAPTAIN_SCALE, CAPTAIN_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(Captain_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Captain_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Captain_ClotThink);

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
		f_NextKart[npc.index] = GetGameTime(npc.index) + Kart_StartingCooldown;

		Captain_Attacking[npc.index] = false;
		
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


public Action Captain_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;

	Captain npc = view_as<Captain>(victim);
	//TODO: Fill this out if needed, scrap if not

	return Plugin_Changed;
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