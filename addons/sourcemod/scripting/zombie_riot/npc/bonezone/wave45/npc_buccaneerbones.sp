#pragma semicolon 1
#pragma newdecls required

//TODO: It's really easy to get stuck in the buffed variant, this is probably because the cannon is not part of its bounding box.
//Figure out a workaround so players can never actually touch the buffed variant.

static float BONES_BUCCANEER_SPEED =  300.0;
static float BONES_BUCCANEER_SPEED_BUFFED = 200.0;
static float BUCCANEER_NATURAL_BUFF_CHANCE = 0.0;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float BUCCANEER_NATURAL_BUFF_LEVEL_MODIFIER = 0.0;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float BUCCANEER_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

static int BONES_BUCCANEER_WEIGHT = 1;
static int BONES_BUCCANEER_WEIGHT_BUFFED = 999;

#define BONES_BUCCANEER_HP					"1000"
#define BONES_BUCCANEER_HP_BUFFED			"30000"

//BRIGADIER BONES (NON-BUFFED VARIANT):
//Walks around holding a Loose Cannon, which it fires at survivors within a given range.
//As this is a ranged unit, it will try to back off if the nearest enemy is too close.
static float BONES_BUCCANEER_ATTACKINTERVAL = 3.5;	//Time between non-buffed variant's shots.
static float BUCCANEER_RANGE = 400.0;	//Maximum distance in which the non-buffed variant can shoot.
static float BUCCANEER_PREDICT_RANGE = 100.0;	//Range in which the non-buffed variant will predict enemy positions when it shoots.
static float BUCCANEER_DAMAGE = 120.0;	//Non-buffed variant's projectile damage.
static float BUCCANEER_RADIUS = 100.0;	//Non-buffed variant's projectile blast radius.
static float BUCCANEER_PROJECTILE_SPEED = 1200.0;	//The speed of non-buffed projectiles.
static float BUCCANEER_FALLOFF_MULTIHIT = 0.8;	//Multi-hit falloff for non-buffed variant.
static float BUCCANEER_FALLOFF_RADIUS = 0.8;	//Radius-based falloff for non-buffed variant.
static float BUCCANEER_ENTITY_MULT = 12.0;		//Amount to multiply damage dealt to buildings.
static float BUCCANEER_TOO_CLOSE = 200.0;		//Proximity at which Brigadier Bones begin to back off.
static float BUCCANEER_TOO_FAR = 600.0;			//Distance at which Brigadier Bones begin to give chase.
static float BUCCANEER_GRAVITY = 0.66;			//Gravity applied to projectiles.

//BONER BOMBER (BUFFED VARIANT):
//Rides very slowly on a large wheeled cannon.
//Will occasionally stop and initiate an animation where it commands the cannon to fire. If not killed before this animation ends,
//the cannon will fire an ENORMOUS cannonball which deals massive damage within a decently large radius. Takes self-knockback upon firing.
//This unit will NOT try to back off if enemies get too close. Instead, it will simply run people over like a Capped Ram.
static float BONES_BUCCANEER_ATTACKINTERVAL_BUFFED = 5.0;	//Time between shots.
static float BUFFED_RANGE = 1600.0;	//Range in which shots can be fired.
static float BUFFED_DAMAGE = 1200.0;	//Damage dealt by cannonballs.
static float BUFFED_RADIUS = 400.0;		//Cannonball blast radius.
static float BUFFED_PROJECTILE_SPEED = 1800.0;	//Projectile speed.
static float BUFFED_FALLOFF_MULTIHIT = 0.9;	//Multi-hit falloff for cannonballs.
static float BUFFED_FALLOFF_RADIUS = 0.66;	//Radius falloff for cannonballs.
static float BUFFED_ENTITY_MULT = 18.0;	//Amount to multiply damage dealt to buildings.
static float BUFFED_DELAY_MULT = 1.0; //Duration to delay firing the cannon once the firing sequence begins.
static float BUFFED_SELF_KNOCKBACK = 400.0;	//Self-knockback taken when the cannon fires.
static float BUFFED_GRAVITY = 0.2;	//Gravity for cannonballs.
static float BUFFED_RUN_OVER_DAMAGE = 10.0;	//Damage dealt per tick while the cannon is colliding with someone.
static float BUFFED_RUN_OVER_FLYING = 50.0;	//Damage dealt per tick while the cannon is colliding with someone while flying through the air from self-knockback.
static float BUFFED_TURNRATE = 150.0;		//Rate at which the buffed variant turns to face its target while charging up.

#define BONES_BUCCANEER_SCALE					"1.0"
#define BONES_BUCCANEER_BUFFED_SCALE			"1.2"

#define BONES_BUCCANEER_SKIN					"0"
#define BONES_BUCCANEER_BUFFED_SKIN				"2"

//#define BONES_BUCCANEER_BUFFPARTICLE			"utaunt_auroraglow_purple_parent"

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

enum BuccaneerState {
	BUCCANEER_IDLE = 0,
	BUCCANEER_INTRO,
	BUCCANEER_LOOP,
	BUCCANEER_FIRING,
	BUCCANEER_FLYING
};

static bool running[MAXENTITIES];

static float f_CannonballRadius[MAXENTITIES];
static float f_CannonballDMG[MAXENTITIES];
static float f_CannonballFalloff_MultiHit[MAXENTITIES];
static float f_CannonballFalloff_Radius[MAXENTITIES];
static float f_Cannonball_EntMult[MAXENTITIES];

static BuccaneerState buccaneer_BuffedState[MAXENTITIES];

#define SOUND_CANNONBALL_SHOOT		")weapons/loose_cannon_shoot.wav"
#define SOUND_CANNONBALL_EXPLODE	")weapons/loose_cannon_explode.wav"
#define PARTICLE_CANNONBALL_EXPLODE	"ExplosionCore_MidAir_underwater"

#define PARTICLE_BIGBALL_EXPLODE	"hammer_impact_button"
#define SOUND_BIGBALL_EXPLODE	")misc/doomsday_missile_explosion.wav"
#define SOUND_BUFFEDBOMB_LAUNCH	")mvm/giant_demoman/giant_demoman_grenade_shoot.wav"
#define SOUND_BIGBALL_PREPARE	")vo/halloween_boss/knight_alert02.mp3"
#define SOUND_BIGBALL_FIRE		")vo/halloween_boss/knight_attack01.mp3"

public void BuccaneerBones_OnMapStart_NPC()
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

	PrecacheSound(SOUND_CANNONBALL_SHOOT);
	PrecacheSound(SOUND_CANNONBALL_EXPLODE);
	PrecacheSound(SOUND_BIGBALL_EXPLODE);
	PrecacheSound(SOUND_BUFFEDBOMB_LAUNCH);
	PrecacheSound(SOUND_BIGBALL_PREPARE);
	PrecacheSound(SOUND_BIGBALL_FIRE);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Brigadier Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_buccaneerbones");
	strcopy(data.Icon, sizeof(data.Icon), "demo");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Necropolain;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Boner Bomber");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_buccaneerbones_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "demo");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Necropolain;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BuccaneerBones(vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return BuccaneerBones(vecPos, vecAng, ally, true);
}

methodmap BuccaneerBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
		if (!b_BonesBuffed[this.index])
			EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		else
			EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, 120, _, _, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CBuccaneerBones::PlayMeleeHitSound()");
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
	
	
	
	public BuccaneerBones(float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		bool randomlyBuffed = false;
		if (!buffed)
		{
			float chance = BUCCANEER_NATURAL_BUFF_CHANCE;
			if (BUCCANEER_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / BUCCANEER_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * BUCCANEER_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
			randomlyBuffed = buffed;
		}
		
		BuccaneerBones npc = view_as<BuccaneerBones>(CClotBody(vecPos, vecAng, buffed ? BONEZONE_MODEL : "models/player/demo.mdl", buffed ? BONES_BUCCANEER_BUFFED_SCALE : BONES_BUCCANEER_SCALE, buffed && !randomlyBuffed ? BONES_BUCCANEER_HP_BUFFED : BONES_BUCCANEER_HP, ally, false));

		if (randomlyBuffed)
			RequestFrame(BoneZone_SetRandomBuffedHP, npc);

		b_BonesBuffed[npc.index] = buffed;

		npc.m_iBoneZoneNonBuffedMaxHealth = StringToInt(BONES_BUCCANEER_HP);
		npc.m_iBoneZoneBuffedMaxHealth = StringToInt(BONES_BUCCANEER_HP_BUFFED);

		npc.m_flBoneZoneNonBuffedScale = StringToFloat(BONES_BUCCANEER_SCALE);
		npc.m_flBoneZoneBuffedScale = StringToFloat(BONES_BUCCANEER_BUFFED_SCALE);
		npc.m_flBoneZoneNonBuffedSpeed = BONES_BUCCANEER_SPEED;
		npc.m_flBoneZoneBuffedSpeed = BONES_BUCCANEER_SPEED_BUFFED;

		strcopy(c_BoneZoneBuffedName[npc.index], sizeof(c_BoneZoneBuffedName[]), "Boner Bomber");
		strcopy(c_BoneZoneNonBuffedName[npc.index], sizeof(c_BoneZoneNonBuffedName[]), "Brigadier Bones");
		npc.BoneZone_UpdateName();

		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(BuccaneerBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(BuccaneerBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(BuccaneerBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(BuccaneerBones_ClotThink);
		
		Buccaneer_GiveCosmetics(npc, buffed);
		
		running[npc.index] = false;

		if (buffed)
		{
			npc.m_bisWalking = false;
			npc.BoneZone_SetExtremeDangerState(true);
		}
		else
		{
			npc.m_bisWalking = true;
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if (b_BonesBuffed[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_CANNON_IDLE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			
			SDKHook(npc.index, SDKHook_Touch, Cannon_RunOver);
		}

		b_IsGiant[npc.index] = buffed;

		DispatchKeyValue(npc.index, "skin", buffed ? BONES_BUCCANEER_BUFFED_SKIN : BONES_BUCCANEER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = (buffed ? BONES_BUCCANEER_ATTACKINTERVAL_BUFFED : BONES_BUCCANEER_ATTACKINTERVAL);
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_BUCCANEER_SPEED_BUFFED : BONES_BUCCANEER_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void BuccaneerBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;

		//Apply buffed stats:
		Buccaneer_GiveCosmetics(npc, true);
		DispatchKeyValue(index, "skin", BONES_BUCCANEER_BUFFED_SKIN);
		npc.m_flNextRangedAttack = GetGameTime() + BONES_BUCCANEER_ATTACKINTERVAL_BUFFED;
		SDKHook(npc.index, SDKHook_Touch, Cannon_RunOver);
		npc.m_bisWalking = false;
		i_NpcWeight[index] = BONES_BUCCANEER_WEIGHT_BUFFED;

		npc.BoneZone_SetExtremeDangerState(true);
		b_IsGiant[npc.index] = true;
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;

		//Remove buffed stats:
		Buccaneer_GiveCosmetics(npc, false);
		DispatchKeyValue(index, "skin", BONES_BUCCANEER_SKIN);
		buccaneer_BuffedState[npc.index] = BUCCANEER_IDLE;
		npc.m_flNextRangedAttack = GetGameTime() + BONES_BUCCANEER_ATTACKINTERVAL_BUFFED;
		SDKUnhook(npc.index, SDKHook_Touch, Cannon_RunOver);
		npc.m_bisWalking = true;
		i_NpcWeight[index] = BONES_BUCCANEER_WEIGHT;
		b_IsGiant[npc.index] = false;
		npc.BoneZone_SetExtremeDangerState(false);
	}
	
	running[npc.index] = false;
}

public void Cannon_RunOver(int entity, int other)
{
	if(IsValidEnemy(entity, other, true, true) && (buccaneer_BuffedState[entity] == BUCCANEER_IDLE || buccaneer_BuffedState[entity] == BUCCANEER_FLYING))
	{
		SDKHooks_TakeDamage(other, entity, entity, (buccaneer_BuffedState[entity] == BUCCANEER_FLYING ? BUFFED_RUN_OVER_FLYING : BUFFED_RUN_OVER_DAMAGE), DMG_CRUSH|DMG_ALWAYSGIB, -1, _);
	}
}

stock void Buccaneer_GiveCosmetics(CClotBody npc, bool buffed)
{
	npc.RemoveAllWearables();
	
	if (buffed)
	{
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("hat", "models/player/items/sniper/summer_shades.mdl");
		
		float pos[3];
		GetEntPropVector(npc.m_iWearable2, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 10.0;
		TeleportEntity(npc.m_iWearable2, pos);
		
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 9999.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 9999.0);
		
		DispatchKeyValue(npc.index, "model", BONEZONE_MODEL);
		view_as<CBaseCombatCharacter>(npc).SetModel(BONEZONE_MODEL);
		
		int iActivity = npc.LookupActivity("ACT_CANNON_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else
	{
		DispatchKeyValue(npc.index, "model", "models/player/demo.mdl");
		view_as<CBaseCombatCharacter>(npc).SetModel("models/player/demo.mdl");
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 0.0);
		SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
		
		int iActivity = npc.LookupActivity("ACT_MP_STAND_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("hat", "models/player/items/demo/drinking_hat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		DispatchKeyValue(npc.m_iWearable1, "skin", "1");
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_demo_cannon/c_demo_cannon.mdl");
		npc.m_iWearable3 = npc.EquipItem("pelvis", BONEZONE_MODEL);
		DispatchKeyValue(npc.m_iWearable3, "skin", BONES_BUCCANEER_SKIN);
	}
}

stock int Buccaneer_AttachParticle(int entity, char type[255], float duration = 0.0, char point[255], float zTrans = 0.0)
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

public void BuccaneerBones_ClotThink(int iNPC)
{
	BuccaneerBones npc = view_as<BuccaneerBones>(iNPC);
	
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
		if (b_BonesBuffed[npc.index])
		{
			Buccaneer_BuffedLogic(npc, closest);
		}
		else
		{
			Buccaneer_NonBuffedLogic(npc, closest);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		
		if (!b_BonesBuffed[npc.index] && running[npc.index])
		{
			int iActivity = npc.LookupActivity("ACT_MP_STAND_SECONDARY");
			if(iActivity > 0) npc.StartActivity(iActivity);
			running[npc.index] = false;
		}
	}
	
	npc.PlayIdleSound();
}

static float f_BuccaneerIntroEnd[MAXENTITIES];
static float f_BuccaneerLoopEnd[MAXENTITIES];
static float f_BuccaneerFireEnd[MAXENTITIES];

public void Buccaneer_BuffedLogic(BuccaneerBones npc, int closest)
{
	float pos[3], targPos[3]; 
	WorldSpaceCenter(npc.index, pos);
	WorldSpaceCenter(closest, targPos);
			
	float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
	if (buccaneer_BuffedState[npc.index] == BUCCANEER_IDLE)
	{
		npc.SetGoalEntity(closest);
		npc.StartPathing();
		
		//npc.FaceTowards(targPos, 15000.0);
	}
	else
		npc.StopPathing();
	
	float gt = GetGameTime(npc.index);
	
	//if (buccaneer_BuffedState[npc.index] != BUCCANEER_IDLE && buccaneer_BuffedState[npc.index] != BUCCANEER_FLYING)
	//	npc.FaceTowards(targPos, 15000.0);

	switch (buccaneer_BuffedState[npc.index])
	{
		case BUCCANEER_IDLE:
		{
			if (gt >= npc.m_flNextRangedAttack && flDistanceToTarget <= BUFFED_RANGE && Can_I_See_Enemy_Only(npc.index, closest) && GetEntityFlags(npc.index) & FL_ONGROUND != 0)
			{
				int iActivity = npc.LookupActivity("ACT_CANNON_FIRE_INTRO");
				if(iActivity > 0) npc.StartActivity(iActivity);
				
				buccaneer_BuffedState[npc.index] = BUCCANEER_INTRO;
				EmitSoundToAll(SOUND_BIGBALL_PREPARE, npc.index, _, 120); 
				
				f_BuccaneerIntroEnd[npc.index] = gt + 0.5;
				
				npc.StopPathing();
				npc.FaceTowards(targPos, 15000.0);
			}
		}
		case BUCCANEER_INTRO:
		{
			if (gt >= f_BuccaneerIntroEnd[npc.index])
			{
				if (BUFFED_DELAY_MULT > 0.0)
				{
					f_BuccaneerLoopEnd[npc.index] = gt + BUFFED_DELAY_MULT;
					int iActivity = npc.LookupActivity("ACT_CANNON_FIRE_LOOP");
					if(iActivity > 0) npc.StartActivity(iActivity);
					buccaneer_BuffedState[npc.index] = BUCCANEER_LOOP;
				}
				else
				{
					f_BuccaneerFireEnd[npc.index] = gt + 0.5;
					int iActivity = npc.LookupActivity("ACT_CANNON_FIRE_ACTIVATION");
					if(iActivity > 0) npc.StartActivity(iActivity);
					buccaneer_BuffedState[npc.index] = BUCCANEER_FIRING;
				}
			}

			npc.FaceTowards(targPos, BUFFED_TURNRATE);
		}
		case BUCCANEER_LOOP:
		{
			if (gt >= f_BuccaneerLoopEnd[npc.index])
			{
				npc.RemoveGesture("ACT_CANNON_FIRE_LOOP");
				f_BuccaneerFireEnd[npc.index] = gt + 0.5;
				int iActivity = npc.LookupActivity("ACT_CANNON_FIRE_ACTIVATION");
				if(iActivity > 0) npc.StartActivity(iActivity);
				buccaneer_BuffedState[npc.index] = BUCCANEER_FIRING;
				EmitSoundToAll(SOUND_BIGBALL_FIRE, npc.index, _, 140); 
			}

			npc.FaceTowards(targPos, BUFFED_TURNRATE);
		}
		case BUCCANEER_FIRING:
		{
			if (gt >= f_BuccaneerFireEnd[npc.index])
			{	
				float ang[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				GetEntPropVector(npc.index, Prop_Data, "m_vecOrigin", pos);
				
				Buccaneer_ShootProjectile(npc, pos, BUFFED_PROJECTILE_SPEED, true, ang);
				
				ang[1] += 180.0;
				
				GetPointFromAngles(pos, ang, BUFFED_SELF_KNOCKBACK, pos, Priest_IgnoreAll, MASK_SHOT);
				
				PluginBot_Jump(npc.index, pos);
				
				int iActivity = npc.LookupActivity("ACT_CANNON_KB_POSE");
				if(iActivity > 0) npc.StartActivity(iActivity);
				buccaneer_BuffedState[npc.index] = BUCCANEER_FLYING;
				npc.m_flNextRangedAttack = gt + BONES_BUCCANEER_ATTACKINTERVAL_BUFFED;
				
				EmitSoundToAll(SOUND_BUFFEDBOMB_LAUNCH, npc.index, _, 120);
			}

			npc.FaceTowards(targPos, BUFFED_TURNRATE);
		}
		case BUCCANEER_FLYING:
		{
			if (GetEntityFlags(npc.index) & FL_ONGROUND != 0)
			{
				buccaneer_BuffedState[npc.index] = BUCCANEER_IDLE;
				int iActivity = npc.LookupActivity("ACT_CANNON_IDLE");
				if(iActivity > 0) npc.StartActivity(iActivity);
				npc.StartPathing();
			}
		}
	}
}

public void Buccaneer_NonBuffedLogic(BuccaneerBones npc, int closest)
{
	float pos[3], targPos[3], optimalPos[3]; 
	WorldSpaceCenter(npc.index, pos);
	WorldSpaceCenter(closest, targPos);
			
	float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
	if (Can_I_See_Enemy_Only(npc.index, closest))
	{
		if (flDistanceToTarget <= BUCCANEER_TOO_CLOSE)
		{
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
		else if (flDistanceToTarget >= BUCCANEER_TOO_FAR)
		{
			if (flDistanceToTarget < npc.GetLeadRadius())
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			}
			else
			{
				npc.SetGoalEntity(npc.m_iTarget);
				npc.StartPathing();
			}
		}
		else
		{
			npc.StopPathing();
			npc.FaceTowards(targPos, 15000.0);
		}
	}
	else
	{
		npc.SetGoalEntity(npc.m_iTarget);
		npc.StartPathing();
	}
	
	//npc.FaceTowards(targPos, 15000.0);
	
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch > 0)
	{				
		//Body pitch
		float v[3], ang[3], worldold[3];
		WorldSpaceCenter(npc.index, worldold);
		SubtractVectors(worldold, targPos, v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
									
		float flPitch = npc.GetPoseParameter(iPitch);
									
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
	}
		
	if (!running[npc.index])
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		running[npc.index] = true;
	}
	
	float gt = GetGameTime(npc.index);
	if (gt >= npc.m_flNextRangedAttack && flDistanceToTarget <= BUCCANEER_RANGE && Can_I_See_Enemy_Only(npc.index, closest))
	{
		if (flDistanceToTarget <= BUCCANEER_PREDICT_RANGE)
		{
			PredictSubjectPositionForProjectiles(npc, closest, BUCCANEER_PROJECTILE_SPEED, _, targPos);
		}
		
		npc.FaceTowards(targPos, 15000.0);
		
		Buccaneer_ShootProjectile(npc, targPos, BUCCANEER_PROJECTILE_SPEED);
		npc.m_flNextRangedAttack = gt + BONES_BUCCANEER_ATTACKINTERVAL;
	}
}

void Buccaneer_ShootProjectile(BuccaneerBones npc, float vicLoc[3], float vel, bool useoverride = false, float angoverride[3] = NULL_VECTOR)
{
	int entity = CreateEntityByName("zr_projectile_base");
			
	if (IsValidEntity(entity))
	{
		float vecForward[3], vecSwingStart[3], vecAngles[3];
		npc.GetVectors(vecForward, vecSwingStart, vecAngles);

		GetAbsOrigin(npc.index, vecSwingStart);
		vecSwingStart[2] += 54.0;
		
		if (useoverride)
			vecAngles = angoverride;

		if (!b_BonesBuffed[npc.index])
		{
			MakeVectorFromPoints(vecSwingStart, vicLoc, vecAngles);
			GetVectorAngles(vecAngles, vecAngles);
		
			vecForward[0] = Cosine(DegToRad(vecAngles[0]))*Cosine(DegToRad(vecAngles[1]))*vel;
			vecForward[1] = Cosine(DegToRad(vecAngles[0]))*Sine(DegToRad(vecAngles[1]))*vel;
			vecForward[2] = Sine(DegToRad(vecAngles[0]))*-vel;
		}
		else
		{
			float buffer[3];
			GetAngleVectors(vecAngles, buffer, NULL_VECTOR, NULL_VECTOR);
			
			vecForward[0] = buffer[0] * vel;
			vecForward[1] = buffer[1] * vel;
			vecForward[2] = buffer[2] * vel;
		}
		
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", npc.index);
		SetEntDataFloat(entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 0.0, true);	// Damage
		SetEntProp(entity, Prop_Send, "m_iTeamNum", view_as<int>(GetEntProp(npc.index, Prop_Send, "m_iTeamNum")));
		SetEntPropVector(entity, Prop_Send, "m_vInitialVelocity", vecForward);
		
		TeleportEntity(entity, vecSwingStart, vecAngles, NULL_VECTOR, true);
		DispatchSpawn(entity);
		
		int g_ProjectileModelRocket = PrecacheModel("models/weapons/w_models/w_cannonball.mdl");
		for(int i; i<4; i++)
		{
			SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", g_ProjectileModelRocket, _, i);
		}
		
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vecForward, true);
		SetEntityCollisionGroup(entity, 24);
		Set_Projectile_Collision(entity);
		See_Projectile_Team_Player(entity);
		
		SetEntProp(entity, Prop_Send, "m_nSkin", GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue) ? 1 : 0);
		
		if (h_NpcSolidHookType[entity] != 0)
			DHookRemoveHookID(h_NpcSolidHookType[entity]);
		h_NpcSolidHookType[entity] = 0;

		if (b_BonesBuffed[npc.index])
		{
			SDKHook(entity, SDKHook_Touch, Buccaneer_BigBallTouch);
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Buccaneer_DontExplode);
			DispatchKeyValueFloat(entity, "modelscale", 1.75);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, BUFFED_GRAVITY);
			
			f_CannonballRadius[entity] = BUFFED_RADIUS;
			f_CannonballDMG[entity] = BUFFED_DAMAGE;
			f_CannonballFalloff_MultiHit[entity] = BUFFED_FALLOFF_MULTIHIT;
			f_CannonballFalloff_Radius[entity] = BUFFED_FALLOFF_RADIUS;
			f_Cannonball_EntMult[entity] = BUFFED_ENTITY_MULT;
		}
		else
		{
			SDKHook(entity, SDKHook_Touch, Buccaneer_CannonballTouch);
			h_NpcSolidHookType[entity] = g_DHookRocketExplode.HookEntity(Hook_Pre, entity, Buccaneer_DontExplode);
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			SetEntityGravity(entity, BUCCANEER_GRAVITY);
			EmitSoundToAll(SOUND_CANNONBALL_SHOOT, entity);
			npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY", false);
			
			f_CannonballRadius[entity] = BUCCANEER_RADIUS;
			f_CannonballDMG[entity] = BUCCANEER_DAMAGE;
			f_CannonballFalloff_MultiHit[entity] = BUCCANEER_FALLOFF_MULTIHIT;
			f_CannonballFalloff_Radius[entity] = BUCCANEER_FALLOFF_RADIUS;
			f_Cannonball_EntMult[entity] = BUCCANEER_ENTITY_MULT;
		}
	}
}

public Action Buccaneer_CannonballTouch(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_CANNONBALL_EXPLODE, 2.0);
	EmitSoundToAll(SOUND_CANNONBALL_EXPLODE, entity, _);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_CannonballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, f_CannonballRadius[entity], f_CannonballFalloff_MultiHit[entity], f_CannonballFalloff_Radius[entity], isBlue, _, _, f_Cannonball_EntMult[entity]);
	
	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public Action Buccaneer_BigBallTouch(int entity, int other)
{
	float position[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", position);
	ParticleEffectAt(position, PARTICLE_CANNONBALL_EXPLODE);
	ParticleEffectAt(position, PARTICLE_BIGBALL_EXPLODE, 2.0);
	SpawnParticlesInRing(position, f_CannonballRadius[entity], PARTICLE_CANNONBALL_EXPLODE, 16);
	SpawnParticlesInRing(position, f_CannonballRadius[entity] * 0.5, PARTICLE_CANNONBALL_EXPLODE, 8);
	EmitSoundToAll(SOUND_BIGBALL_EXPLODE, entity, _, 120);
	
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	bool isBlue = GetEntProp(entity, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);
	Explode_Logic_Custom(f_CannonballDMG[entity], IsValidEntity(owner) ? owner : entity, entity, entity, position, f_CannonballRadius[entity], f_CannonballFalloff_MultiHit[entity], f_CannonballFalloff_Radius[entity], isBlue, _, _, f_Cannonball_EntMult[entity]);
	
	RemoveEntity(entity);
	return Plugin_Handled; //DONT.
}

public MRESReturn Buccaneer_DontExplode(int entity)
{
	RemoveEntity(entity);
	return MRES_Supercede; //DONT.
}

public Action BuccaneerBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	BuccaneerBones npc = view_as<BuccaneerBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void BuccaneerBones_NPCDeath(int entity)
{
	BuccaneerBones npc = view_as<BuccaneerBones>(entity);
	npc.PlayDeathSound();	

	npc.RemoveAllWearables();
	
	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
	
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


