#pragma semicolon 1
#pragma newdecls required

#define BONES_SAINT_HP			"500"
#define BONES_SAINT_HP_BUFFED	"5000"

#define BONES_SAINT_SKIN		"2"
#define BONES_SAINT_SKIN_BUFFED	"3"

#define BONES_SAINT_SCALE		"1.0"
#define BONES_SAINT_SCALE_BUFFED	"1.2"

#define BONES_SAINTBONES_BUFFPARTICLE	"utaunt_arcane_yellow_parent"//"utaunt_auroraglow_orange_parent"

#define PRIEST_HEALINGPARTICLE			"superrare_greenenergy"
#define PRIEST_HEALINGPARTICLE_BUFFED	"superrare_greenenergy"

#define PARTICLE_PRIEST_CHARGEUP		"superrare_burning2"
#define PARTICLE_PRIEST_CHARGEUP_BUFFED	"unusual_robot_radioactive"
#define PARTICLE_GREENBLAST				"merasmus_dazed_explosion"
#define PARTICLE_NECROBLAST_1			"merasmus_spawn_flash2"
#define PARTICLE_NECROBLAST_2			"merasmus_spawn_flash"

static float BONES_SAINT_SPEED = 350.0;
static float BONES_SAINT_SPEED_BUFFED = 420.0;
static float SAINT_NATURAL_BUFF_CHANCE = 0.0;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float SAINT_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float SAINT_NATURAL_BUFF_LEVEL = 0.0;	//The average level at which level_modifier reaches its max.

static float SAINTBONES_HEAL_RANGE = 300.0;
static float SAINTBONES_HEAL_RANGE_BUFFED = 450.0;

static float SAINTBONES_PRIEST_HEALPERCENTAGE = 0.01;
static int SAINTBONES_PRIEST_MINHEALING = 2;

static float SAINTBONES_PRIEST_HEALPERCENTAGE_BUFFED = 0.05;
static int SAINTBONES_PRIEST_MINHEALING_BUFFED = 1;

static float Priest_EnemyHover_MinDist = 200.0;
static float Priest_EnemyHover_MaxDist = 300.0;

//NECROTIC BOLT: Profaned Priests use this attack when they cannot find a valid ally to heal.
//They clap their hands together, casting forth a bolt of necrotic energy which pierces players.
//They cannot rotate while casting the spell, which gives players a brief window to get out of the way.
//This attack is blocked if the Profaned Priest is silenced.
static float LIGHTNING_DAMAGE = 30.0;
static float LIGHTNING_DAMAGE_ENTITYMULT = 3.0;
static float LIGHTNING_RANGE = 350.0;
static float LIGHTNING_INTERVAL = 1.0;
static float LIGHTNING_WIDTH = 20.0;

//THUNDER CLAP: Skeletal Saints use this attack when they cannot find a valid ally to heal.
//They clap their hands together, triggering an enormous, very deadly blast of thunder at their location.
//They cannot move while charging the spell, which gives players plenty of time to escape its radius and also makes the Skeletal Saint vulnerable.
//This attack is blocked if the Skeletal Saint is silenced.
static float THUNDER_DAMAGE = 800.0;
static float THUNDER_DAMAGE_ENTITYMULT = 1.0;
static float THUNDER_RADIUS = 400.0;
static float THUNDER_INTERVAL = 2.0;
static float THUNDER_CHARGETIME = 2.0;
static float THUNDER_FALLOFF_MULTIHIT = 0.85;
static float THUNDER_FALLOFF_RADIUS = 0.33;

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

static char g_IdleSounds_Buffed[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav", 
	")misc/halloween/skeletons/skelly_giant_02.wav", 
	")misc/halloween/skeletons/skelly_giant_03.wav"
};

static char g_IdleAlertedSounds_Buffed[][] = {
	")misc/halloween/skeletons/skelly_giant_01.wav", 
	")misc/halloween/skeletons/skelly_giant_02.wav", 
	")misc/halloween/skeletons/skelly_giant_03.wav"
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

static int Priest_OldHealTarget[MAXENTITIES];
static int Priest_HealingParticle[MAXENTITIES];
static bool Priest_IsHealing[MAXENTITIES];
static float Priest_LoopHealingGesture[MAXENTITIES];
static float Priest_CanGoBerserkAt[MAXENTITIES];

#define SOUND_CAST_ACTIVATED		")weapons/physcannon/superphys_launch2.wav"
#define SOUND_CAST_ACTIVATED_BUFFED	")misc/halloween_eyeball/book_exit.wav"
#define SOUND_CAST_ACTIVATED_BUFFED_2	")misc/halloween/merasmus_hiding_explode.wav"
#define SOUND_CAST_ACTIVATED_BUFFED_3	")misc/halloween/spell_lightning_ball_cast.wav"
#define SOUND_CAST					")weapons/physcannon/energy_sing_flyby1.wav"
#define SOUND_CAST_BUFFED			")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_THUNDER_CHARGEUP		")misc/halloween/gotohell.wav"
#define SOUND_PRIEST_FIZZLE			")player/taunt_sorcery_fail.wav"
#define PARTICLE_PRIEST_FIZZLE		"spell_skeleton_goop_green"

static float Priest_BoltAngles[MAXENTITIES][3];
static float castTime[MAXENTITIES];
static float castEndTime[MAXENTITIES];
static int CastParticle_L[MAXENTITIES];
static int CastParticle_R[MAXENTITIES];

enum Priest_CastState
{
	CASTSTATE_INACTIVE, 
	CASTSTATE_INTRO, 
	CASTSTATE_CHARGING, 
	CASTSTATE_CASTING
};

Priest_CastState castState[MAXENTITIES] = { CASTSTATE_INACTIVE, ... };

public void SaintBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds)); i++) { PrecacheSound(g_DeathSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtSounds)); i++) { PrecacheSound(g_HurtSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds)); i++) { PrecacheSound(g_IdleSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds_Buffed)); i++) { PrecacheSound(g_IdleSounds_Buffed[i]); }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds_Buffed)); i++) { PrecacheSound(g_IdleAlertedSounds_Buffed[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds)); i++) { PrecacheSound(g_MeleeMissSounds[i]); }
	for (int i = 0; i < (sizeof(g_GibSounds)); i++) { PrecacheSound(g_GibSounds[i]); }
	
	PrecacheSound(SOUND_CAST_ACTIVATED);
	PrecacheSound(SOUND_CAST_ACTIVATED_BUFFED);
	PrecacheSound(SOUND_CAST_ACTIVATED_BUFFED_2);
	PrecacheSound(SOUND_CAST_ACTIVATED_BUFFED_3);
	PrecacheSound(SOUND_CAST);
	PrecacheSound(SOUND_CAST_BUFFED);
	PrecacheSound(SOUND_THUNDER_CHARGEUP);
	PrecacheSound(SOUND_PRIEST_FIZZLE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Blighted Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_skeletalsaint");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Profaned Priest");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_skeletalsaint_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "medic");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SaintBones(vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SaintBones(vecPos, vecAng, ally, true);
}

methodmap SaintBones < CClotBody
{
	public void PlayIdleSound() {
		if (this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
		
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
		
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSaintBones::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public void PlayHeIsAwake() {
		EmitSoundToAll(g_HeIsAwake[GetRandomInt(0, sizeof(g_HeIsAwake) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBunkerSkeleton::PlayHeIsAwakeSound()");
		#endif
	}
	
	public void PlayPriestSwingSound()
	{
		EmitSoundToAll(SOUND_CAST, this.index, _, _, _, _, GetRandomInt(80, 120));
	}
	
	public SaintBones(float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;

		if (!buffed)
		{
			float chance = SAINT_NATURAL_BUFF_CHANCE;
			if (SAINT_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
			{
				float total;
				float players;
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i))
					{
						total += float(Level[i]);
						players += 1.0;
					}
				}
				
				float average = total / players;
				float mult = average / SAINT_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * SAINT_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		SaintBones npc = view_as<SaintBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_SAINT_SCALE_BUFFED : BONES_SAINT_SCALE, buffed && !randomlyBuffed ? BONES_SAINT_HP_BUFFED : BONES_SAINT_HP, ally, false));
		
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_SAINT_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_SAINT_HP_BUFFED);
		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_SAINT_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_SAINT_SCALE_BUFFED);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_SAINT_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_SAINT_SPEED_BUFFED;
		Priest_CanGoBerserkAt[npc.index] = GetGameTime() + 1.0;

		b_DoNotChangeTargetTouchNpc[npc.index] = true;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Skeletal Saint");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Blighted Bones");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		Is_a_Medic[npc.index] = true;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(SaintBones_SetBuffed);
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(SaintBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SaintBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SaintBones_ClotThink);
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_SAINTBONES_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);
			TE_SendToAll();
			npc.BoneZone_SetExtremeDangerState(true);
			int iActivity = npc.LookupActivity("ACT_ARCHMAGE_IDLE");
			if (iActivity > 0)npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = INVALID_FUNCTION;
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_BLIGHTED_RUN");
			if (iActivity > 0)npc.StartActivity(iActivity);
			func_NPCAnimEvent[npc.index] = Blighted_Anims;
		}
		
		Saint_GiveCosmetics(npc, buffed);
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_SAINT_SKIN_BUFFED : BONES_SAINT_SKIN);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_SAINT_SPEED_BUFFED : BONES_SAINT_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void SaintBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	npc.RemoveAllWearables();
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;

		//Apply buffed stats:
		Saint_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_SAINT_SKIN_BUFFED);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_SAINTBONES_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);
		TE_SendToAll();

		int iActivity = npc.LookupActivity("ACT_ARCHMAGE_IDLE");
		if (iActivity > 0)npc.StartActivity(iActivity);

		npc.BoneZone_SetExtremeDangerState(true);
		func_NPCAnimEvent[npc.index] = INVALID_FUNCTION;
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;

		//Remove buffed stats:
		Saint_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_SAINT_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_SAINTBONES_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();

		int iActivity = npc.LookupActivity("ACT_BLIGHTED_RUN");
		if (iActivity > 0)npc.StartActivity(iActivity);

		npc.BoneZone_SetExtremeDangerState(false);
		func_NPCAnimEvent[npc.index] = Blighted_Anims;
	}
}

stock void Saint_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/spy/mbsf_spy.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/spr17_guilden_guardian/spr17_guilden_guardian.mdl");

		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		DispatchKeyValue(npc.m_iWearable2, "skin", "1");
	}
}

stock int Priest_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
{
	if (IsValidEntity(entity))
	{
		int part1 = CreateEntityByName("info_particle_system");
		if (IsValidEdict(part1))
		{
			float pos[3];
			if (HasEntProp(entity, Prop_Data, "m_vecAbsOrigin"))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
			}
			else if (HasEntProp(entity, Prop_Send, "m_vecOrigin"))
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			}
			
			if (zTrans != 0.0)
			{
				pos[2] += zTrans;
			}
			
			TeleportEntity(part1, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(part1, "effect_name", type);
			SetVariantString("!activator");
			AcceptEntityInput(part1, "SetParent", entity, part1);
			SetVariantString(point);
			AcceptEntityInput(part1, "SetParentAttachmentMaintainOffset", part1, part1);
			DispatchKeyValue(part1, "targetname", "present");
			DispatchSpawn(part1);
			ActivateEntity(part1);
			AcceptEntityInput(part1, "Start");
			
			if (duration > 0.0)
			{
				CreateTimer(duration, Timer_RemoveEntity, EntIndexToEntRef(part1), TIMER_FLAG_NO_MAPCHANGE);
			}
			
			return part1;
		}
	}
	
	return -1;
}

public void Priest_RemoveHealingParticle(int index)
{
	int particle = EntRefToEntIndex(Priest_HealingParticle[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

public void Priest_RemoveThunderParticles(int index)
{
	int particle = EntRefToEntIndex(CastParticle_L[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
	
	particle = EntRefToEntIndex(CastParticle_R[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

//Skeletal Saints are buff providers and healers.
//Profaned Priests (the non-buffed variant) heal a single target. They will prioritize non-buffed skeletons who do not already have a healer. Skeletons being healed by a Profaned Priest are transformed into their buffed variant, and will revert to their normal variant when the healing stops, unless they naturally spawned buffed.
//Skeletal Saints (the buffed variant) provide healing in a radius. All skeletons being healed by this effect are transformed into their buffed counterpart.
//Profaned Priests cannot be transformed into Skeletal Saints by either of these effects, though they *can* be buffed by other sources.
//If all valid heal targets are dead (meaning everything that is not a Saint or Priest), they will take on the movement patterns of Skeletal Archmages and fight by casting low-damage lightning bolts.

//PRIEST HEAL TARGET PRIORITY LIST:
//	1. Non-buffed skeletons, not including healers.
//	2. Any skeleton, not including healers.
//	3. Literally any friendly NPC that is not a healer.
//	4. No valid heal targets exist, become the senate and start zapping people.

public void SaintBones_ClotThink(int iNPC)
{
	SaintBones npc = view_as<SaintBones>(iNPC);
	
	//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
	npc.Update();
	
	if (npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	if (npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		if (!npc.m_flAttackHappenswillhappen)
			npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
	}
	
	if (npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	int closest = npc.m_iTarget;
	
	if (b_BonesBuffed[npc.index])
		SaintBones_SaintLogic(npc, closest);
	else
		SaintBones_PriestLogic(npc, closest);
	
	closest = npc.m_iTarget;
	switch (castState[npc.index])
	{
		case CASTSTATE_INACTIVE:
		Priest_AttemptCast(npc, closest);
		case CASTSTATE_INTRO:
		Priest_EndIntro(npc, closest);
		case CASTSTATE_CHARGING:
		Priest_ChargeUp(npc, closest);
		case CASTSTATE_CASTING:
		{
			Priest_CheckCast(npc, closest);
			Priest_EndCast(npc, closest);
		}
	}
	
	if (npc.m_flAttackHappenswillhappen && b_BonesBuffed[npc.index])
	{
		float position[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", position);
		
		spawnRing_Vectors(position, THUNDER_RADIUS * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 20, 255, 120, 180, 1, 0.1, 16.0, 2.0, 1);
		spawnRing_Vectors(position, 0.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 20, 255, 120, 120, 1, 0.33, 8.0, 0.0, 1, THUNDER_RADIUS * 2.0);
	}
	
	npc.PlayIdleSound();
}

public void Priest_AttemptCast(SaintBones npc, int closest)
{
	//Do not attack if your next attack is not ready, your target is not a valid enemy, you are silenced, or you are healing.
	if (npc.m_flNextMeleeAttack >= GetGameTime(npc.index) || !IsValidEnemy(npc.index, closest) || NpcStats_IsEnemySilenced(npc.index) || Priest_IsHealing[npc.index])
		return;

	if (!Can_I_See_Enemy_Only(npc.index, closest))
		return;
	
	float userLoc[3], otherLoc[3];
	WorldSpaceCenter(npc.index, userLoc);
	WorldSpaceCenter(closest, otherLoc);
	
	if (b_BonesBuffed[npc.index])
	{
		//Do not begin Thunder Clap if the enemy is too far away for it to reasonably hit.
		if (GetVectorDistance(userLoc, otherLoc) > THUNDER_RADIUS * 0.4)
			return;

		npc.FaceTowards(otherLoc, 15000.0);
		npc.m_flAttackHappens = GetGameTime(npc.index) + 0.4;
		castState[npc.index] = CASTSTATE_INTRO;
		npc.m_flAttackHappenswillhappen = true;
		npc.AddGesture("ACT_PRIEST_THUNDERBOLT_INTRO");
		CastParticle_L[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_PRIEST_CHARGEUP_BUFFED : PARTICLE_PRIEST_CHARGEUP, _, "handL"));
		CastParticle_R[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_PRIEST_CHARGEUP_BUFFED : PARTICLE_PRIEST_CHARGEUP, _, "handR"));
	}
	else
	{
		//Do not begin Lightning Strike if the enemy is out of range.
		if (GetVectorDistance(userLoc, otherLoc) > LIGHTNING_RANGE)
			return;
		
		float dummy[3], start[3], target[3];
		WorldSpaceCenter(npc.index, start);
		WorldSpaceCenter(closest, target);
		start[2] += 20.0;
		target[2] += 20.0;
		Priest_GetAngleToPoint(npc.index, start, target, dummy, Priest_BoltAngles[npc.index]);

		npc.FaceTowards(otherLoc, 15000.0);
		castState[npc.index] = CASTSTATE_INTRO;
		npc.m_flAttackHappenswillhappen = true;

		int iActivity = npc.LookupActivity("ACT_BLIGHTED_ATTACK");
		if (iActivity > 0)npc.StartActivity(iActivity);

		CastParticle_L[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_PRIEST_CHARGEUP_BUFFED : PARTICLE_PRIEST_CHARGEUP, _, "healing_staff_1"));
	}
}

void Priest_GetAngleToPoint(int ent, float pos[3], float TargetLoc[3], float DummyAngles[3], const float Output[3])
{
	float ang[3], fVecFinal[3], fFinalPos[3];
	
	GetEntPropVector(ent, Prop_Send, "m_angRotation", ang);
	
	AddInFrontOf(TargetLoc, DummyAngles, 7.0, fVecFinal);
	MakeVectorFromPoints(pos, fVecFinal, fFinalPos);
	
	GetVectorAngles(fFinalPos, ang);
	
	Output = ang;
}

public void Priest_EndIntro(SaintBones npc, int closest)
{
	if (!b_BonesBuffed[npc.index])
		return;

	if (GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen)
	{
		if (b_BonesBuffed[npc.index])
		{
			npc.AddGesture("ACT_PRIEST_THUNDERBOLT_CHARGEUP");
			chargeLoopTime[npc.index] = GetGameTime(npc.index) + 0.9;
			castState[npc.index] = CASTSTATE_CHARGING;
			npc.m_flAttackHappens = GetGameTime(npc.index) + THUNDER_CHARGETIME;
			EmitSoundToAll(SOUND_THUNDER_CHARGEUP, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + 20, _, NORMAL_ZOMBIE_VOLUME, 90);
		}
		else
		{
			Priest_Cast(npc, closest);
		}
	}
}

public void Priest_ChargeUp(SaintBones npc, int closest)
{
	if (!b_BonesBuffed[npc.index])
		return;

	//If we are ready to throw, or we can't cast our giant lightning bolt for some reason, stop charging.
	if ((GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen) || !IsValidEnemy(npc.index, closest) || !b_BonesBuffed[npc.index] || NpcStats_IsEnemySilenced(npc.index) || Priest_IsHealing[npc.index])
	{
		Priest_Cast(npc, closest);
	}
	else if (GetGameTime(npc.index) >= chargeLoopTime[npc.index])
	{
		npc.AddGesture("ACT_PRIEST_THUNDERBOLT_CHARGEUP");
		chargeLoopTime[npc.index] = GetGameTime(npc.index) + 0.9;
	}
}

public void Priest_Cast(SaintBones npc, int closest)
{
	if (!b_BonesBuffed[npc.index])
		return;

	npc.RemoveGesture("ACT_PRIEST_THUNDERBOLT_CHARGEUP");
	
	float duration;
	if (IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index) && !Priest_IsHealing[npc.index])
	{
		npc.AddGesture("ACT_PRIEST_THUNDERBOLT_CAST");
		duration = 0.5;
		castTime[npc.index] = GetGameTime(npc.index) + 0.1;
		EmitSoundToAll(b_BonesBuffed[npc.index] ? SOUND_CAST_BUFFED : SOUND_CAST, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 10, _, NORMAL_ZOMBIE_VOLUME - 0.25);
	}
	else
	{
		npc.m_flAttackHappenswillhappen = false;
		duration = 0.1;
		Priest_RemoveThunderParticles(npc.index);
	}
	
	castState[npc.index] = CASTSTATE_CASTING;
	castEndTime[npc.index] = GetGameTime(npc.index) + duration;
}

public bool Priest_IgnoreAll(int entity, int mask) { return false; }

public bool Priest_OnlyHitWorld(int entity, int mask) { return entity == 0 || b_is_a_brush[entity]; }

static bool Priest_LightningHit[MAXENTITIES];

public bool Priest_LightningTrace(int entity, int contentsMask, int user)
{
	if (IsEntityAlive(entity) && entity != user)
		Priest_LightningHit[entity] = true;
	
	return false;
}

public void Priest_CheckCast(SaintBones npc, int closest)
{
	if (!b_BonesBuffed[npc.index])
		return;

	if (GetGameTime(npc.index) >= castTime[npc.index] && npc.m_flAttackHappenswillhappen)
	{
		if (b_BonesBuffed[npc.index])
		{
			EmitSoundToAll(SOUND_CAST_ACTIVATED_BUFFED_2, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + 20, _, NORMAL_ZOMBIE_VOLUME);
			//EmitSoundToAll(SOUND_CAST_ACTIVATED_BUFFED_2, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + 20, _, NORMAL_ZOMBIE_VOLUME);
			EmitSoundToAll(SOUND_CAST_ACTIVATED_BUFFED, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + 20, _, NORMAL_ZOMBIE_VOLUME);
			EmitSoundToAll(SOUND_CAST_ACTIVATED_BUFFED, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + 20, _, NORMAL_ZOMBIE_VOLUME);
			
			bool isBlue = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
			float position[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", position);
			
			Explode_Logic_Custom(THUNDER_DAMAGE, npc.index, npc.index, npc.index, position, THUNDER_RADIUS, THUNDER_FALLOFF_MULTIHIT, THUNDER_FALLOFF_RADIUS, isBlue, _, false, THUNDER_DAMAGE_ENTITYMULT);
			Priest_AttachParticle(npc.index, PARTICLE_NECROBLAST_1, 2.0, "handL");
			Priest_AttachParticle(npc.index, PARTICLE_NECROBLAST_2, 2.0, "handL");
			
			for (float ang = 0.0; ang < 360.0; ang += 45.0)
			{
				float groundPos[3], skyPos[3], testAng[3];
				testAng[0] = 0.0;
				testAng[1] = ang;
				testAng[2] = 0.0;
				
				GetPointFromAngles(position, testAng, THUNDER_RADIUS, groundPos, Priest_IgnoreAll, MASK_SHOT);
				skyPos = groundPos;
				skyPos[2] += 9999.0;
				
				ParticleEffectAt(groundPos, PARTICLE_GREENBLAST, 2.0);
				SpawnBeam_Vectors(skyPos, groundPos, 0.33, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 0.0);
				SpawnBeam_Vectors(skyPos, groundPos, 0.33, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 36.0, 36.0, _, 0.0);
				SpawnBeam_Vectors(skyPos, groundPos, 0.33, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 36.0, 36.0, _, 20.0);
			}
		}
		else
		{
			float startLoc[3], endLoc[3], center[3], vicLoc[3];
			WorldSpaceCenter(npc.index, center);
			center[2] += 20.0;
			
			TR_TraceRayFilter(center, Priest_BoltAngles[npc.index], MASK_SHOT, RayType_Infinite, Priest_OnlyHitWorld);
			TR_GetEndPosition(endLoc);
			startLoc = endLoc;
			constrainDistance(center, startLoc, GetVectorDistance(center, startLoc), 20.0);
			constrainDistance(center, endLoc, GetVectorDistance(center, endLoc), LIGHTNING_RANGE);
			
			float hullMin[3], hullMax[3];
			
			hullMin[0] = -LIGHTNING_WIDTH;
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			
			//We use center instead of startLoc because otherwise players can avoid the beam by being at point-blank:
			TR_TraceHullFilter(center, endLoc, hullMin, hullMax, 1073741824, Priest_LightningTrace, npc.index);
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Priest_LightningHit[victim])
				{
					Priest_LightningHit[victim] = false;
					
					if (IsValidEnemy(npc.index, victim))
					{
						float damage = LIGHTNING_DAMAGE;
						
						if (ShouldNpcDealBonusDamage(victim))
						{
							damage *= LIGHTNING_DAMAGE_ENTITYMULT;
						}
						
						WorldSpaceCenter(victim, vicLoc);
						SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_PLASMA, _, NULL_VECTOR, vicLoc);
					}
				}
			}
			
			ParticleEffectAt(startLoc, PARTICLE_GREENBLAST, 2.0);
			SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
			SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
			SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 6.0, 6.0, _, 10.0);
			SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 20.0);
		}
		
		EmitSoundToAll(b_BonesBuffed[npc.index] ? SOUND_CAST_ACTIVATED_BUFFED_3 : SOUND_CAST_ACTIVATED, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + (b_BonesBuffed[npc.index] ? 0 : 20), _, NORMAL_ZOMBIE_VOLUME);
		npc.m_flAttackHappenswillhappen = false;
		Priest_RemoveThunderParticles(npc.index);
	}
}

public void Priest_EndCast(SaintBones npc, int closest)
{
	if (!b_BonesBuffed[npc.index])
		return;

	if (GetGameTime(npc.index) >= castEndTime[npc.index])
	{
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? THUNDER_INTERVAL : LIGHTNING_INTERVAL);
		castState[npc.index] = CASTSTATE_INACTIVE;
		npc.RemoveGesture("ACT_PRIEST_THUNDERBOLT_CAST");
	}
}

public int Priest_GetTarget(CClotBody npc)
{
	//Check 1: Find the closest non-buffed skeleton.
	int closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsNonBuffedSkeleton));
	
	//Check 2: There are no non-buffed skeletons, find the closest skeleton.
	if (closest <= 0)
		closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsASkeleton));
	
	//Check 3: There are no skeletons, find the closest ally who is not a healer.
	if (closest <= 0)
		closest = GetClosestAlly(npc.index, _, _, view_as<Function>(Priest_IsNotAHealer));
	
	//Check 4: We were not able to find ANY valid allies to heal, start zapping survivors.	
	if (closest <= 0)
	{
		if (GetGameTime() >= Priest_CanGoBerserkAt[npc.index])
		{
			b_DoNotChangeTargetTouchNpc[npc.index] = false;
			closest = GetClosestTarget(npc.index);
		}
	}
	//Check 5: If we are already healing something, compare its priority level to the new target's to determine whether or not we should switch our heal target.
	else if (closest > 0 && Priest_IsHealing[npc.index] && IsValidEntity(npc.m_iTarget))
	{
		int current = npc.m_iTarget;
		CClotBody currentNPC = view_as<CClotBody>(current);
		CClotBody newNPC = view_as<CClotBody>(closest);
		
		if (currentNPC.BoneZone_IsASkeleton())
		{
			if (!newNPC.BoneZone_IsASkeleton()) //The new target is not a skeleton, don't change our target.
				closest = current;
			else if (newNPC.BoneZone_GetBuffedState() || newNPC.m_bBoneZoneNaturallyBuffed) //The new target is already buffed, don't change our target.
				closest = current;
			else if (!currentNPC.m_bBoneZoneNaturallyBuffed && currentNPC.BoneZone_GetNumBuffers() <= 1) //The current heal target will lose their buffed form if we change our target, do not change.
				closest = current;
		}
	}
	
	return closest;
}

public bool Priest_IsNonBuffedSkeleton(int checker, int target)
{
	CClotBody npc = view_as<CClotBody>(target);
	
	if (npc.BoneZone_GetBuffedState())
		return false;
	
	if (!npc.BoneZone_IsASkeleton())
		return false;
	
	if (npc.BoneZone_IsASaint())
		return false;
	
	return true;
}

public bool Priest_IsASkeleton(int checker, int target)
{
	CClotBody npc = view_as<CClotBody>(target);
	
	if (!npc.BoneZone_IsASkeleton())
		return false;
	
	if (npc.BoneZone_IsASaint())
		return false;
	
	return true;
}

public bool Priest_IsNotAHealer(int checker, int target)
{
	CClotBody npc = view_as<CClotBody>(target);
	
	if (npc.BoneZone_IsASaint())
		return false;
	
	return true;
}

public void SaintBones_PriestLogic(SaintBones npc, int closest)
{
	if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = Priest_GetTarget(npc);
		closest = npc.m_iTarget;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	if (!IsValidEntity(closest) || closest == npc.index)
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_BLIGHTED_HEALING_LOOP");
			Priest_IsHealing[npc.index] = false;
		}
		
		return;
	}
	
	float vecTarget[3], userLoc[3];
	WorldSpaceCenter(closest, vecTarget);
	WorldSpaceCenter(npc.index, userLoc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, userLoc);
	
	CClotBody targetNPC = view_as<CClotBody>(closest);
	
	if (IsValidAlly(npc.index, closest))
	{
		int currentHealTarget = EntRefToEntIndex(Priest_OldHealTarget[npc.index]);
		if (closest != currentHealTarget)
		{
			if (IsValidEntity(currentHealTarget))
			{
				CClotBody oldNPC = view_as<CClotBody>(currentHealTarget);
				oldNPC.BoneZone_SetBuffedState(false, npc.index);
			}
			
			Priest_OldHealTarget[npc.index] = EntIndexToEntRef(closest);
		}
		
		npc.SetGoalEntity(closest);
		
		//Only walk up to 66% the healing distance away from the target, we don't want to be *too* close to them.
		if (flDistanceToTarget <= SAINTBONES_HEAL_RANGE * 0.66 && Can_I_See_Ally(npc.index, closest))
		{
			npc.StopPathing();
		}
		else
		{
			npc.StartPathing();
		}
		
		if (flDistanceToTarget <= SAINTBONES_HEAL_RANGE)
		{
			if (!Priest_IsHealing[npc.index])
			{
				Priest_HealingParticle[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, PRIEST_HEALINGPARTICLE, _, "healing_staff_1"));
				npc.AddGesture("ACT_BLIGHTED_HEALING_LOOP");
				Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				Priest_IsHealing[npc.index] = true;
			}
			else
			{
				if (GetGameTime(npc.index) >= Priest_LoopHealingGesture[npc.index])
				{
					npc.AddGesture("ACT_BLIGHTED_HEALING_LOOP");
					Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				}
			}
			
			int particle = EntRefToEntIndex(Priest_HealingParticle[npc.index]);
			if (IsValidEntity(particle))
			{
				float startLoc[3];
				GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", startLoc);
				vecTarget[2] += 20.0;
				SpawnBeam_Vectors(startLoc, vecTarget, 0.1, 20, 255, 20, 255, PrecacheModel("materials/sprites/lgtning.vmt"), _, _, _, 10.0);
			}
			
			float maxHP = float(GetEntProp(targetNPC.index, Prop_Data, "m_iHealth"));
			int HealingAmount = RoundFloat(maxHP * SAINTBONES_PRIEST_HEALPERCENTAGE);
			if (HealingAmount < SAINTBONES_PRIEST_MINHEALING)
				HealingAmount = SAINTBONES_PRIEST_MINHEALING;
			
			if (GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") < GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"))
			{
				SetEntProp(targetNPC.index, Prop_Data, "m_iHealth", GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") + HealingAmount);
				if (GetEntProp(targetNPC.index, Prop_Data, "m_iHealth") >= GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(targetNPC.index, Prop_Data, "m_iHealth", GetEntProp(targetNPC.index, Prop_Data, "m_iMaxHealth"));
				}
			}
			
			targetNPC.BoneZone_SetBuffedState(true, npc.index);
			
			//Move a little faster than the target NPC so we don't lose them.
			float newSpeed = targetNPC.m_flSpeed * 1.2;
			if (npc.m_flSpeed <= newSpeed)
				npc.m_flSpeed = newSpeed;
		}
		else
		{
			if (Priest_IsHealing[npc.index])
			{
				Priest_RemoveHealingParticle(npc.index);
				npc.RemoveGesture("ACT_BLIGHTED_HEALING_LOOP");
				Priest_IsHealing[npc.index] = false;
			}
			
			targetNPC.BoneZone_SetBuffedState(false, npc.index);
			npc.m_flSpeed = BONES_SAINT_SPEED;
		}
	}
	else if (IsValidEnemy(npc.index, closest))
	{
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_BLIGHTED_HEALING_LOOP");
			Priest_IsHealing[npc.index] = false;
		}
		
		float optimalPos[3];
		
		if (!Can_I_See_Enemy_Only(npc.index, closest))
		{
			npc.StartPathing();
			npc.SetGoalEntity(closest);
		}
		else
		{
			if (flDistanceToTarget < Priest_EnemyHover_MinDist)
			{
				npc.StartPathing();
				BackoffFromOwnPositionAndAwayFromEnemy(npc, closest, _, optimalPos);
				
				if (GetDistanceToGround(optimalPos) <= 200.0)
				{
					npc.SetGoalVector(optimalPos, true);
					npc.StartPathing();
				}
				else
				{
					npc.StopPathing();
				}
			}
			else if (flDistanceToTarget > Priest_EnemyHover_MaxDist)
			{
				npc.StartPathing();
				npc.SetGoalEntity(closest);
			}
			else
			{
				npc.StopPathing();
			}
		}
	}
	
	//Only rotate and allow movement if we are not casting our lightning spell.
	if (castState[npc.index] != CASTSTATE_INACTIVE)
	{
		npc.StopPathing();
		//npc.FaceTowards(vecTarget, 15000.0);
	}
}

public void SaintBones_SaintLogic(SaintBones npc, int closest)
{
	if (npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = Priest_GetTarget(npc);
		closest = npc.m_iTarget;
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}
	
	if (!IsValidEntity(closest))
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_PRIEST_HEALING");
			Priest_IsHealing[npc.index] = false;
		}
		
		return;
	}
	
	float vecTarget[3], userLoc[3];
	WorldSpaceCenter(closest, vecTarget);
	WorldSpaceCenter(npc.index, userLoc);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, userLoc);
	
	if (IsValidAlly(npc.index, closest))
	{
		npc.SetGoalEntity(closest);
		
		//Only walk up to 80% the healing distance away from the target, we don't want to be *too* close to them.
		if (flDistanceToTarget <= SAINTBONES_HEAL_RANGE_BUFFED * 0.5 && Can_I_See_Ally(npc.index, closest))
		{
			npc.StopPathing();
		}
		else
		{
			npc.StartPathing();
		}
		
		bool AtLeastOne = false;
		float highestSpeed = npc.m_flSpeed;
		
		int particle = EntRefToEntIndex(Priest_HealingParticle[npc.index]);
		float startLoc[3];
		if (IsValidEntity(particle))
		{
			GetEntPropVector(particle, Prop_Data, "m_vecAbsOrigin", startLoc);
		}
		else
		{
			WorldSpaceCenter(npc.index, startLoc);
			startLoc[2] += 90.0;
		}
		
		for (int i = 1; i < MAXENTITIES; i++)
		{
			if (!IsValidEntity(i) || i_IsABuilding[i] || i == npc.index)
				continue;
			
			if (!HasEntProp(i, Prop_Send, "m_iTeamNum"))
				continue;
			
			CClotBody healTarget = view_as<CClotBody>(i);		
			if (healTarget.BoneZone_IsASaint())
				continue;
			
			float healPos[3], userPos[3];
			WorldSpaceCenter(i, healPos);
			WorldSpaceCenter(npc.index, userPos);
			if (IsValidAlly(npc.index, i) && GetVectorDistance(userPos, healPos) <= SAINTBONES_HEAL_RANGE_BUFFED)
			{
				AtLeastOne = true;
				
				float maxHP = float(GetEntProp(healTarget.index, Prop_Data, "m_iHealth"));
				int HealingAmount = RoundFloat(maxHP * SAINTBONES_PRIEST_HEALPERCENTAGE_BUFFED);
				if (HealingAmount < SAINTBONES_PRIEST_MINHEALING_BUFFED)
					HealingAmount = SAINTBONES_PRIEST_MINHEALING_BUFFED;
				
				if (GetEntProp(healTarget.index, Prop_Data, "m_iHealth") < GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"))
				{
					SetEntProp(healTarget.index, Prop_Data, "m_iHealth", GetEntProp(healTarget.index, Prop_Data, "m_iHealth") + HealingAmount);
					if (GetEntProp(healTarget.index, Prop_Data, "m_iHealth") >= GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"))
					{
						SetEntProp(healTarget.index, Prop_Data, "m_iHealth", GetEntProp(healTarget.index, Prop_Data, "m_iMaxHealth"));
					}
				}
				
				healTarget.BoneZone_SetBuffedState(true, npc.index);
				if (healTarget.m_flSpeed > highestSpeed)
					highestSpeed = healTarget.m_flSpeed;
				
				healPos[2] += 20.0;
				SpawnBeam_Vectors(startLoc, healPos, 0.1, 20, 255, 20, 255, PrecacheModel("materials/sprites/lgtning.vmt"), _, _, _, 10.0);
			}
			else
			{
				healTarget.BoneZone_SetBuffedState(false, npc.index);
			}
		}
		
		if (AtLeastOne)
		{
			if (!Priest_IsHealing[npc.index])
			{
				Priest_HealingParticle[npc.index] = EntIndexToEntRef(Priest_AttachParticle(npc.index, PRIEST_HEALINGPARTICLE_BUFFED, _, "handR"));
				npc.AddGesture("ACT_PRIEST_HEALING"); //TODO: Saints need custom anims
				Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				Priest_IsHealing[npc.index] = true;
			}
			else
			{
				if (GetGameTime(npc.index) >= Priest_LoopHealingGesture[npc.index])
				{
					npc.AddGesture("ACT_PRIEST_HEALING"); //TODO: Saints need custom anims
					Priest_LoopHealingGesture[npc.index] = GetGameTime(npc.index) + 0.7;
				}
			}
			
			//Move a little faster than the fastest NPC being healed, that way we don't lose the group.
			if (npc.m_flSpeed < highestSpeed)
				npc.m_flSpeed = highestSpeed * 1.2;
		}
		else
		{
			if (Priest_IsHealing[npc.index])
			{
				Priest_RemoveHealingParticle(npc.index);
				npc.RemoveGesture("ACT_PRIEST_HEALING"); //TODO: Saints need custom anims
				Priest_IsHealing[npc.index] = false;
			}
			
			npc.m_flSpeed = BONES_SAINT_SPEED_BUFFED;
		}
	}
	else if (IsValidEnemy(npc.index, closest))
	{
		if (Priest_IsHealing[npc.index])
		{
			Priest_RemoveHealingParticle(npc.index);
			npc.RemoveGesture("ACT_PRIEST_HEALING"); //TODO: Saints need custom anims
			Priest_IsHealing[npc.index] = false;
		}
		
		npc.StartPathing();
		npc.SetGoalEntity(closest);
	}
	
	//Only rotate and allow movement if we are not casting our lightning spell.
	if (castState[npc.index] != CASTSTATE_INACTIVE)
		npc.StopPathing();
}

public Action SaintBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if (attacker <= 0)
		return Plugin_Continue;
	
	SaintBones npc = view_as<SaintBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	//	
	return Plugin_Changed;
}

public void Blighted_Anims(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	SaintBones npc = view_as<SaintBones>(entity);

	if (b_BonesBuffed[entity])
		return;

	if (castState[entity] == CASTSTATE_INACTIVE)
		return;

	switch(event)
	{
		case 1001:	//Blighted Bones swings its staff, play a sound.
		{
			npc.PlayPriestSwingSound();
		}
		case 1002:	//Blighted Bones casts its spell, do damage and VFX.
		{
			if (NpcStats_IsEnemySilenced(npc.index))
			{
				float fizzle[3], ang[3];
				npc.GetAttachment("healing_staff_1", fizzle, ang);
				ParticleEffectAt(fizzle, PARTICLE_PRIEST_FIZZLE);
				EmitSoundToAll(SOUND_PRIEST_FIZZLE, npc.index, _, _, _, _, GetRandomInt(80, 110));
			}
			else
			{
				float startLoc[3], endLoc[3], center[3], vicLoc[3];
				WorldSpaceCenter(npc.index, center);
				center[2] += 20.0;
				
				TR_TraceRayFilter(center, Priest_BoltAngles[npc.index], MASK_SHOT, RayType_Infinite, Priest_OnlyHitWorld);
				TR_GetEndPosition(endLoc);
				startLoc = endLoc;
				constrainDistance(center, startLoc, GetVectorDistance(center, startLoc), 20.0);
				constrainDistance(center, endLoc, GetVectorDistance(center, endLoc), LIGHTNING_RANGE);
				
				float hullMin[3], hullMax[3];
				
				hullMin[0] = -LIGHTNING_WIDTH;
				hullMin[1] = hullMin[0];
				hullMin[2] = hullMin[0];
				hullMax[0] = -hullMin[0];
				hullMax[1] = -hullMin[1];
				hullMax[2] = -hullMin[2];
				
				//We use center instead of startLoc because otherwise players can avoid the beam by being at point-blank:
				TR_TraceHullFilter(center, endLoc, hullMin, hullMax, 1073741824, Priest_LightningTrace, npc.index);
				
				for (int victim = 1; victim < MAXENTITIES; victim++)
				{
					if (Priest_LightningHit[victim])
					{
						Priest_LightningHit[victim] = false;
						
						if (IsValidEnemy(npc.index, victim))
						{
							float damage = LIGHTNING_DAMAGE;
							
							if (ShouldNpcDealBonusDamage(victim))
							{
								damage *= LIGHTNING_DAMAGE_ENTITYMULT;
							}
							
							WorldSpaceCenter(victim, vicLoc);
							SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_PLASMA, _, NULL_VECTOR, vicLoc);
						}
					}
				}
				
				npc.GetAttachment("healing_staff_1", startLoc, center);
				ParticleEffectAt(startLoc, PARTICLE_GREENBLAST, 2.0);
				SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
				SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 20, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
				SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 6.0, 6.0, _, 10.0);
				SpawnBeam_Vectors(startLoc, endLoc, 0.25, 20, 255, 120, 80, PrecacheModel("materials/sprites/lgtning.vmt"), 2.0, 2.0, _, 20.0);

				EmitSoundToAll(SOUND_CAST_ACTIVATED, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL + (b_BonesBuffed[npc.index] ? 0 : 20), _, NORMAL_ZOMBIE_VOLUME);
			}

			npc.m_flAttackHappenswillhappen = false;
			Priest_RemoveThunderParticles(npc.index);
		}
		case 1003:	//End of attack sequence, apply attack interval and revert to run cycle.
		{
			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? THUNDER_INTERVAL : LIGHTNING_INTERVAL);
			castState[npc.index] = CASTSTATE_INACTIVE;
			int iActivity = npc.LookupActivity("ACT_BLIGHTED_RUN");
			if (iActivity > 0)npc.StartActivity(iActivity);
		}
	}
}

public void SaintBones_NPCDeath(int entity)
{
	SaintBones npc = view_as<SaintBones>(entity);
	if (!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}

	for (int i = 1; i < 2049; i++)
	{
		if (!IsValidEntity(i) || i == entity)
			continue;
		
		CClotBody other = view_as<CClotBody>(i);
		other.BoneZone_SetBuffedState(false, entity);
	}
	
	if (Priest_IsHealing[entity])
	{
		Priest_RemoveHealingParticle(entity);
		npc.RemoveGesture("ACT_PRIEST_HEALING");
		Priest_IsHealing[entity] = false;
	}
	
	npc.RemoveAllWearables();
	Priest_RemoveThunderParticles(entity);
	Priest_IsHealing[entity] = false;
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	
	//	AcceptEntityInput(npc.index, "KillHierarchy");
}


