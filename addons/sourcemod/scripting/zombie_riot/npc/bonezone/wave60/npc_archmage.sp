#pragma semicolon 1
#pragma newdecls required

static float BONES_ARCHMAGE_SPEED = 250.0;
static float BONES_ARCHMAGE_SPEED_BUFFED = 320.0;

#define BONES_ARCHMAGE_HP				"900"
#define BONES_ARCHMAGE_HP_BUFFED		"4500"

static float BONES_ARCHMAGE_PLAYERDAMAGE = 100.0;
static float BONES_ARCHMAGE_PLAYERDAMAGE_BUFFED = 800.0;
static float ARCHMAGE_NATURAL_BUFF_CHANCE = 0.0;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float ARCHMAGE_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float ARCHMAGE_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

//static float BONES_ARCHMAGE_BUILDINGDAMAGE = 120.0;
//static float BONES_ARCHMAGE_BUILDINGDAMAGE_BUFFED = 800.0;

static float BONES_ARCHMAGE_PROJECTILE_VELOCITY = 800.0;
static float BONES_ARCHMAGE_PROJECTILE_VELOCITY_BUFFED = 1400.0;
static float BONES_ARCHMAGE_PROJECTILE_LIFESPAN = 1.2;
//No lifespan variable for buffed archmages because their projectiles don't disappear.

static float ARCHMAGE_FIREBALL_BLAST_RADIUS = 200.0;
static float ARCHMAGE_FIREBALL_FALLOFF_MULTIHIT = 0.8;
static float ARCHMAGE_FIREBALL_FALLOFF_RADIUS = 0.66;
static float ARCHMAGE_FIREBALL_ENTITY_MULTIPLIER = 3.0;

static float BONES_ARCHMAGE_ATTACKINTERVAL = 0.5;
static float BONES_ARCHMAGE_ATTACKINTERVAL_BUFFED = 1.0;

static float ARCHMAGE_HOVER_MINDIST = 400.0;
static float ARCHMAGE_HOVER_MAXDIST = 700.0;
//static float ARCHMAGE_HOVER_OPTIMALDIST = 550.0;

static float ARCHMAGE_CHARGE_DURATION = 3.0;

static float f_ArchmageFireballDMG[2049] = { 0.0, ... };

#define BONES_ARCHMAGE_SCALE				"1.0"
#define BONES_ARCHMAGE_BUFFED_SCALE			"1.2"

#define BONES_ARCHMAGE_SKIN						"0"
#define BONES_ARCHMAGE_BUFFED_SKIN				"1"

#define PARTICLE_ARCHMAGE_FIREBALL			"flaregun_trail_red"
#define PARTICLE_ARCHMAGE_FIREBALL_BUFFED	"spell_fireball_small_blue"

#define BONES_ARCHMAGE_BUFFPARTICLE			"utaunt_runeprison_teamcolor_blue"//"utaunt_auroraglow_purple_parent"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
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

static char g_IdleSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
};

static char g_IdleAlertedSounds[][] = {
	")misc/halloween/skeletons/skelly_medium_01.wav",
	")misc/halloween/skeletons/skelly_medium_02.wav",
	")misc/halloween/skeletons/skelly_medium_03.wav",
	")misc/halloween/skeletons/skelly_medium_04.wav",
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

enum Archmage_ThrowState
{
	THROWSTATE_INACTIVE,
	THROWSTATE_INTRO,
	THROWSTATE_CHARGING,
	THROWSTATE_THROWING
};

Archmage_ThrowState throwState[MAXENTITIES] = { THROWSTATE_INACTIVE, ... };
float throwEndTime[MAXENTITIES + 1] = { 0.0, ... };
float throwThrowTime[MAXENTITIES + 1] = { 0.0, ... };
float chargeLoopTime[MAXENTITIES + 1] = { 0.0, ... };
int throwParticle[MAXENTITIES + 1] = { -1, ... };

#define SOUND_SPELL_CHARGEUP		")items/powerup_pickup_base.wav"
#define SOUND_SPELL_THROW			")weapons/cleaver_throw.wav"
#define SOUND_SPELL_THROW_BUFFED	")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_SPELL_CAST			")misc/halloween/spell_meteor_cast.wav"
#define SOUND_SPELL_CAST_BUFFED		")misc/halloween/spell_meteor_impact.wav"
#define SOUND_FIREBALL_HIT			")weapons/dragons_fury_impact_bonus_damage.wav"
#define SOUND_FIREBALL_EXPLODE		")misc/halloween/spell_fireball_impact.wav"

public void ArchmageBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds_Buffed));		i++) { PrecacheSound(g_IdleSounds_Buffed[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds_Buffed)); i++) { PrecacheSound(g_IdleAlertedSounds_Buffed[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheModel(BONEZONE_MODEL);
	
	PrecacheSound(SOUND_SPELL_CHARGEUP);
	PrecacheSound(SOUND_SPELL_THROW);
	PrecacheSound(SOUND_SPELL_THROW_BUFFED);
	PrecacheSound(SOUND_SPELL_CAST);
	PrecacheSound(SOUND_SPELL_CAST_BUFFED);
	PrecacheSound(SOUND_FIREBALL_HIT);
	PrecacheSound(SOUND_FIREBALL_EXPLODE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Spelleton");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_archmage");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Alakablaster");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_archmage_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ArchmageBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return ArchmageBones(client, vecPos, vecAng, ally, true);
}

methodmap ArchmageBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CArchmageBones::PlayMeleeHitSound()");
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
	
	
	
	public ArchmageBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = ARCHMAGE_NATURAL_BUFF_CHANCE;
			if (ARCHMAGE_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / ARCHMAGE_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * ARCHMAGE_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
			
		ArchmageBones npc = view_as<ArchmageBones>(CClotBody(vecPos, vecAng, BONEZONE_MODEL, buffed ? BONES_ARCHMAGE_BUFFED_SCALE : BONES_ARCHMAGE_SCALE, buffed && !randomlyBuffed ? BONES_ARCHMAGE_HP_BUFFED : BONES_ARCHMAGE_HP, ally, false));
		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_ARCHMAGE_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_ARCHMAGE_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_ARCHMAGE_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_ARCHMAGE_BUFFED_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_ARCHMAGE_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_ARCHMAGE_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Alakablaster");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Spelleton");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(ArchmageBones_SetBuffed);
		npc.m_bisWalking = false;

		func_NPCDeath[npc.index] = view_as<Function>(ArchmageBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ArchmageBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ArchmageBones_ClotThink);
		
		Archmage_GiveCosmetics(npc, buffed);
		
		if (buffed)
		{
			TE_SetupParticleEffect(BONES_ARCHMAGE_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, npc.index);
			TE_WriteNum("m_bControlPoint1", npc.index);	
			TE_SendToAll();	
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_WIZARD_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_ARCHMAGE_BUFFED_SKIN : BONES_ARCHMAGE_SKIN);

		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (buffed ? BONES_ARCHMAGE_ATTACKINTERVAL_BUFFED : BONES_ARCHMAGE_ATTACKINTERVAL);
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_ARCHMAGE_SPEED_BUFFED : BONES_ARCHMAGE_SPEED);
		
		throwState[npc.index] = THROWSTATE_INACTIVE;
		
		npc.StartPathing();
		
		return npc;
	}
}

public void ArchmageBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		Archmage_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_ARCHMAGE_BUFFED_SKIN);
		
		//Apply buffed particle:
		TE_SetupParticleEffect(BONES_ARCHMAGE_BUFFPARTICLE, PATTACH_ABSORIGIN_FOLLOW, index);
		TE_WriteNum("m_bControlPoint1", index);	
		TE_SendToAll();
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		Archmage_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_ARCHMAGE_SKIN);
		
		//Remove buffed particle:
		TE_Start("EffectDispatch");
		TE_WriteNum("entindex", index);
		TE_WriteNum("m_nHitBox", GetParticleEffectIndex(BONES_ARCHMAGE_BUFFPARTICLE));
		TE_WriteNum("m_iEffectName", GetEffectIndex("ParticleEffectStop"));
		TE_SendToAll();
	}
}

stock void Archmage_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/workshop/player/items/sniper/hwn2023_sightseer_style1/hwn2023_sightseer_style1.mdl");
		npc.m_iWearable2 = npc.EquipItem("spine3", "models/workshop/player/items/sniper/hwn2023_sharpshooters_shroud/hwn2023_sharpshooters_shroud.mdl");
		
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		DispatchKeyValue(npc.m_iWearable2, "skin", "1");
	}
	else
	{
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/sniper/headhunters_wrap/headhunters_wrap.mdl");
	}
}

stock int Archmage_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

//All archmage variants will float a short distance above the ground and attempt to keep a distance from survivors.
//Both variants throw fireballs. 
//Skeletal Mages (the non-buffed variant of the archmage) toss smaller red fireballs which deal 75 damage each and do not explode.
//Skeletal Archmages toss large blue fireballs which deal a base damage of 300 and DO explode within a small radius, with up to 66% falloff. Archmages need to charge these fireballs, during which they suffer a 50% movement speed penalty.

public void Archmage_CheckThrow(ArchmageBones npc, int closest)
{
	if (npc.m_flNextMeleeAttack < GetGameTime(npc.index) && IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index))
	{
		if (!Can_I_See_Enemy_Only(npc.index, closest))
			return;
			
		float userLoc[3], targLoc[3];
		WorldSpaceCenter(npc.index, userLoc);
		WorldSpaceCenter(closest, targLoc);
		//Don't try to throw a fireball if the target is too far away.
		if (GetVectorDistance(userLoc, targLoc) > ARCHMAGE_HOVER_MAXDIST)
			return;
			
		throwState[npc.index] = THROWSTATE_INTRO;
		npc.m_flAttackHappens = GetGameTime(npc.index) + 0.1;
		npc.m_flAttackHappenswillhappen = true;
		
		npc.AddGesture("ACT_MP_PASSTIME_THROW_BEGIN");
		throwParticle[npc.index] = EntIndexToEntRef(Archmage_AttachParticle(npc.index, b_BonesBuffed[npc.index] ? PARTICLE_ARCHMAGE_FIREBALL_BUFFED : PARTICLE_ARCHMAGE_FIREBALL, _, "handR"));
	}
}

public void Archmage_EndIntro(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen)
	{
		if (b_BonesBuffed[npc.index])
		{
			npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
			chargeLoopTime[npc.index] = GetGameTime(npc.index) + 1.8;
			throwState[npc.index] = THROWSTATE_CHARGING;
			npc.m_flAttackHappens = GetGameTime(npc.index) + ARCHMAGE_CHARGE_DURATION;
			EmitSoundToAll(SOUND_SPELL_CHARGEUP, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 10, _, NORMAL_ZOMBIE_VOLUME - 0.1, 90);
		}
		else
		{
			Archmage_Throw(npc, closest);
		}
	}
}

public void Archmage_ChargeUp(ArchmageBones npc, int closest)
{
	//If we are ready to throw, or we can't throw the big blue fireball for some reason, stop charging and attempt to throw.
	if ((GetGameTime(npc.index) >= npc.m_flAttackHappens && npc.m_flAttackHappenswillhappen) || !IsValidEnemy(npc.index, closest) || !b_BonesBuffed[npc.index] || NpcStats_IsEnemySilenced(npc.index))
	{
		Archmage_Throw(npc, closest);
	}
	else if (GetGameTime(npc.index) >= chargeLoopTime[npc.index])
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
		chargeLoopTime[npc.index] = GetGameTime(npc.index) + 1.8;
	}
}

public void Archmage_Throw(ArchmageBones npc, int closest)
{
	npc.RemoveGesture("ACT_MP_PASSTIME_THROW_MIDDLE");
	
	float duration;
	if (IsValidEnemy(npc.index, closest) && !NpcStats_IsEnemySilenced(npc.index))
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_END");
		duration = 0.46;
		throwThrowTime[npc.index] = GetGameTime(npc.index) + 0.1;
		EmitSoundToAll(b_BonesBuffed[npc.index] ? SOUND_SPELL_THROW_BUFFED : SOUND_SPELL_THROW, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - 10, _, NORMAL_ZOMBIE_VOLUME - 0.25);
	}
	else
	{
		npc.AddGesture("ACT_MP_PASSTIME_THROW_CANCEL");
		npc.m_flAttackHappenswillhappen = false;
		duration = 0.1;
		Archmage_RemoveParticle(npc.index);
	}
	
	throwState[npc.index] = THROWSTATE_THROWING;
	throwEndTime[npc.index] = GetGameTime(npc.index) + duration;
}

public void Archmage_CheckLaunch(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= throwThrowTime[npc.index] && npc.m_flAttackHappenswillhappen)
	{
		float vicLoc[3];
		WorldSpaceCenter(closest, vicLoc);
		
		float vel = b_BonesBuffed[npc.index] ? BONES_ARCHMAGE_PROJECTILE_VELOCITY_BUFFED : BONES_ARCHMAGE_PROJECTILE_VELOCITY;
		float damage = b_BonesBuffed[npc.index] ? BONES_ARCHMAGE_PLAYERDAMAGE_BUFFED : BONES_ARCHMAGE_PLAYERDAMAGE;
		
		//The buffed variant predicts the victim's location, non-buffed does not.
		if (b_BonesBuffed[npc.index])
		{
			PredictSubjectPositionForProjectiles(npc, closest, vel, _, vicLoc);
		}
		
		Archmage_ShootProjectile(npc, vicLoc, vel, damage);
		
		EmitSoundToAll(b_BonesBuffed[npc.index] ? SOUND_SPELL_CAST_BUFFED : SOUND_SPELL_CAST, npc.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL - (b_BonesBuffed[npc.index] ? 15 : 30), _, NORMAL_ZOMBIE_VOLUME - (b_BonesBuffed[npc.index] ? 0.25 : 0.5));
		npc.m_flAttackHappenswillhappen = false;
		Archmage_RemoveParticle(npc.index);
	}
}

public void Archmage_ShootProjectile(ArchmageBones npc, float vicLoc[3], float vel, float damage)
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		npc.GetVectors(vecForward, vecSwingStart, vecAngles);

		GetAbsOrigin(npc.index, vecSwingStart);
		vecSwingStart[2] += 54.0;

		MakeVectorFromPoints(vecSwingStart, vicLoc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
		
		vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*vel;
		vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*vel;
		vecForward[2] = Sine(DegToRad(vecAngles[0]))*-vel;
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		f_ArchmageFireballDMG[entity] = damage;

		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		int g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_drg_ball.mdl");
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);

		if (h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;
		
		if (b_BonesBuffed[npc.index])
		{
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Archmage_Explode);
			Archmage_AttachParticle(entity, PARTICLE_ARCHMAGE_FIREBALL_BUFFED, _, "");
		}
		else
		{
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Rocket_Particle_DHook_RocketExplodePre); //*yawn*

			SDKHook(entity, SDKHook_Touch, Archmage_FireballTouch);
			Archmage_AttachParticle(entity, PARTICLE_ARCHMAGE_FIREBALL, _, "");
			CreateTimer(BONES_ARCHMAGE_PROJECTILE_LIFESPAN, Timer_RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action Archmage_FireballTouch(int entity, int other)
{
	if (!IsValidEntity(other))
		return Plugin_Continue;
		
	int team1 = GetEntProp(entity, Prop_Send, "m_iTeamNum");
	int team2 = GetEntProp(other, Prop_Send, "m_iTeamNum");
	
	if (team1 != team2)
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		SDKHooks_TakeDamage(other, entity, IsValidEntity(owner) ? owner : entity, f_ArchmageFireballDMG[entity]);
		if (IsValidClient(other))
			EmitSoundToClient(other, SOUND_FIREBALL_HIT);
			
		float position[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
		ParticleEffectAt(position, PARTICLE_FIREBALL_HIT, 2.0);
	}
		
	return Plugin_Continue;
}

public MRESReturn Archmage_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public MRESReturn Archmage_Explode(int entity)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_FIREBALL_EXPLODE, 2.0);
	EmitSoundToAll(SOUND_FIREBALL_EXPLODE, entity, SNDCHAN_STATIC, 80, _, 1.0);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_ArchmageFireballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, ARCHMAGE_FIREBALL_BLAST_RADIUS, ARCHMAGE_FIREBALL_FALLOFF_MULTIHIT, ARCHMAGE_FIREBALL_FALLOFF_RADIUS, isBlue, _, true, ARCHMAGE_FIREBALL_ENTITY_MULTIPLIER);
	
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public void Archmage_RemoveParticle(int index)
{
	int particle = EntRefToEntIndex(throwParticle[index]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
}

public void Archmage_EndThrow(ArchmageBones npc, int closest)
{
	if (GetGameTime(npc.index) >= throwEndTime[npc.index])
	{
		npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (b_BonesBuffed[npc.index] ? BONES_ARCHMAGE_ATTACKINTERVAL_BUFFED : BONES_ARCHMAGE_ATTACKINTERVAL);
		throwState[npc.index] = THROWSTATE_INACTIVE;
	}
}

/*
public int Archmage_GetOptimalTarget(int ent)
{
	float pos[3], otherPos[3];
	pos = WorldSpaceCenter(ent);
	
	float closestDist = 999999999.0;
	int closest = -1;
	
	//TODO: Ask how to make this include NPCs, Archmages do not intentionally attack buildings so we don't care about them.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
			
		CClotBody npc = view_as<CClotBody>(i);
		if (TF2_GetClientTeam(i) != view_as<TFTeam>(GetEntProp(ent, Prop_Send, "m_iTeamNum")) && !npc.m_bThisEntityIgnored && IsEntityAlive(i, true))
		{
			otherPos = WorldSpaceCenter(ent);
			
			float dist = GetVectorDistance(pos, otherPos);
			float diff = ARCHMAGE_HOVER_OPTIMALDIST - dist;
			if (diff < 0.0)
				diff *= -1.0;
				
			if (diff < closestDist)
			{
				closest = i;
				closestDist = diff;
			}
		}
	}
	
	return closest;
}*/

public void Archmage_LookAtPoint(ArchmageBones npc, int closest)
{
	if (IsValidEnemy(npc.index, closest))
	{
		float targLoc[3];
		WorldSpaceCenter(closest, targLoc);
		npc.FaceTowards(targLoc, 15000.0);
	}
}

public void ArchmageBones_ClotThink(int iNPC)
{
	ArchmageBones npc = view_as<ArchmageBones>(iNPC);
	
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
	}
	
	int closest = npc.m_iTarget;
	
	//Archmages will always attempt to stay a certain distance away from their target, not too far but not too close.
	//If they are too far/too close, they will move closer/further as needed.
	//They will still, however, always choose the nearest enemy as their target.
	if(IsValidEnemy(npc.index, closest))
	{
		float pos[3], targPos[3], optimalPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
					
		if (!Can_I_See_Enemy_Only(npc.index, closest))
		{
			npc.StartPathing();
			npc.SetGoalEntity(closest);
		}
		else
		{
			if (flDistanceToTarget < ARCHMAGE_HOVER_MINDIST)
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
			else if (flDistanceToTarget > ARCHMAGE_HOVER_MAXDIST)
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
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	switch(throwState[npc.index])
	{
		case THROWSTATE_INACTIVE:
		{
			Archmage_CheckThrow(npc, closest);
		}
		case THROWSTATE_INTRO:
		{
			Archmage_EndIntro(npc, closest);
			Archmage_LookAtPoint(npc, closest);
		}
		case THROWSTATE_CHARGING:
		{
			Archmage_ChargeUp(npc, closest);
			Archmage_LookAtPoint(npc, closest);
		}
		case THROWSTATE_THROWING:
		{
			Archmage_CheckLaunch(npc, closest);
			Archmage_EndThrow(npc, closest);
			Archmage_LookAtPoint(npc, closest);
		}
	}
	
	npc.PlayIdleSound();
}

stock float[] Archmage_ConstrainDistance(float startPos[3], float endPos[3], float distance)
{	
	if (GetVectorDistance(startPos, endPos, true) >= Pow(distance, 2.0))
	{
		float constraint = distance/GetVectorDistance(startPos, endPos);
		
		for (int i = 0; i < 3; i++)
		{
			endPos[i] = ((endPos[i] - startPos[i]) * constraint) + startPos[i];
		}
	}
	
	return endPos;
}

public bool Archmage_WorldOnly(any entity, any contentsMask)
{
	if (IsValidClient(entity))
	{
		return false;
	}
	
	bool hit = true;
	
	if (IsValidEntity(entity))
	{
		char entname[255];
		GetEntityClassname(entity, entname, 255);
		hit = StrContains(entname, "zr_base_npc") == -1;
	}
	
	return hit;
}

public Action ArchmageBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	ArchmageBones npc = view_as<ArchmageBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void ArchmageBones_NPCDeath(int entity)
{
	ArchmageBones npc = view_as<ArchmageBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	int particle = EntRefToEntIndex(throwParticle[entity]);
	if (IsValidEntity(particle))
		RemoveEntity(particle);
		
	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


