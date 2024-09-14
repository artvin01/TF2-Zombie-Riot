#pragma semicolon 1
#pragma newdecls required

#define BONES_JESTER_HP			"300"
#define BONES_JESTER_HP_BUFFED	"600"

#define BONES_JESTER_SKIN		"2"
#define BONES_JESTER_SKIN_BUFFED	"2"

#define BONES_JESTER_SCALE		 "1.0"
#define BONES_JESTER_SCALE_BUFFED "1.2"

#define BONES_JESTER_BUFFPARTICLE	"utaunt_wispy_parent_g"

#define PARTICLE_JESTER_FUSE		"fuse_sparks"
#define PARTICLE_JESTER_FUSE_BUFFED	"spell_fireball_small_red"

static float BONES_JESTER_SPEED = 280.0;
static float BONES_JESTER_SPEED_BUFFED = 180.0;
static float JESTER_NATURAL_BUFF_CHANCE = 0.1;	//Percentage chance for non-buffed skeletons of this type to be naturally buffed instead.
static float JESTER_NATURAL_BUFF_LEVEL_MODIFIER = 0.05;	//Max percentage increase for natural buff chance based on the average level of all players in the lobby, relative to natural_buff_level.
static float JESTER_NATURAL_BUFF_LEVEL = 100.0;	//The average level at which level_modifier reaches its max.

//FEARSOME FOOL (Non-Buffed Variant):
//A jester who juggles two large cannonballs. When an enemy gets close enough, it will throw both bombs at them.
//It must stop juggling before it can throw the bombs, which takes approximately one full second.
static float BONES_JESTER_ATTACKINTERVAL = 1.2;		//Delay between attacks.
static float BONES_JESTER_RANGE = 800.0;			//Attack range.
static float BONES_JESTER_MAX_RANGE = 800.0;		//Distance from its target at which the jester will continue moving.
static float BONES_JESTER_OPTIMAL_RANGE = 400.0;	//Distance from its target at which the jester will stop moving.
static float BONES_JESTER_RANGE_PREDICT = 300.0;	//Range at which the jester will predict its target's location when throwing bombs.
static float BONES_JESTER_VELOCITY = 1600.0;		//Projectile velocity.
static float BONES_JESTER_DAMAGE = 140.0;			//Explosive damage.
static float BONES_JESTER_ENTITYMULT = 8.0;			//Amount to multiply damage dealt to entities.
static float BONES_JESTER_RADIUS = 150.0;			//Explosive radius.
static float BONES_JESTER_FALLOFF_RADIUS = 0.8;		//Maximum damage lost based on distance from the center of the blast.
static float BONES_JESTER_FALLOFF_MULTIHIT = 0.66;	//Amount to multiply damage dealt per enemy hit by explosions.
static float BONES_JESTER_GRAVITY = 0.66;			//Projectile gravity.

//SERVANT OF MONDO (Buffed Variant):
//A deranged cultist who worships a figure known only as "Mondo". Moves very slowly while carrying an enormous bomb on its back.
//When it is ready to attack, it tosses this bomb up into the air, waits for it to fall back down, and then punches it, sending it flying straight forwards.
//The bomb explodes on contact and inflicts devastating damage within an enormous radius.
static float BONES_MONDO_ATTACKINTERVAL = 6.0;		//Delay between attacks.
static float BONES_MONDO_RANGE = 1800.0;			//Range in which the attack will begin.
static float BONES_MONDO_VELOCITY = 2800.0;			//Projectile velocity.
static float BONES_MONDO_DAMAGE = 1800.0;			//Blast damage.
static float BONES_MONDO_ENTITYMULT = 5.0;			//Amount to multiply damage dealt to entities.
static float BONES_MONDO_RADIUS = 650.0;			//Blast radius.
static float BONES_MONDO_FALLOFF_RADIUS = 0.5;		//Maximum damage falloff based on distance from the center of the blast.
static float BONES_MONDO_FALLOFF_MULTIHIT = 0.9;	//Amount to multiply damage dealt per target hit.
static float BONES_MONDO_GRAVITY = 0.66;			//Projectile gravity.

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

#define SOUND_JESTER_FUSE	"misc/halloween/hwn_bomb_fuse.wav"

public void JesterBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }

	PrecacheSound(SOUND_JESTER_FUSE);

//	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie/classic.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Fearsome Fool");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_jester");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_Normal;
	NPC_Add(data);

	NPCData data_buffed;
	strcopy(data_buffed.Name, sizeof(data_buffed.Name), "Servant of Mondo");
	strcopy(data_buffed.Plugin, sizeof(data_buffed.Plugin), "npc_jester_buffed");
	strcopy(data_buffed.Icon, sizeof(data_buffed.Icon), "pyro");
	data_buffed.IconCustom = false;
	data_buffed.Flags = 0;
	data_buffed.Category = Type_Common;
	data_buffed.Func = Summon_Buffed;
	NPC_Add(data_buffed);
}

static any Summon_Normal(int client, float vecPos[3], float vecAng[3], int ally)
{
	return JesterBones(client, vecPos, vecAng, ally, false);
}

static any Summon_Buffed(int client, float vecPos[3], float vecAng[3], int ally)
{
	return JesterBones(client, vecPos, vecAng, ally, true);
}

methodmap JesterBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CJesterBones::PlayMeleeHitSound()");
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
	
	
	
	public JesterBones(int client, float vecPos[3], float vecAng[3], int ally, bool buffed)
	{
		if (!buffed)
		{
			float chance = JESTER_NATURAL_BUFF_CHANCE;
			if (JESTER_NATURAL_BUFF_LEVEL_MODIFIER > 0.0)
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
				float mult = average / JESTER_NATURAL_BUFF_LEVEL;
				if (mult > 1.0)
					mult = 1.0;
					
				chance += (mult * JESTER_NATURAL_BUFF_LEVEL_MODIFIER);
			}
			
			buffed = (GetRandomFloat() <= chance);
		}
			
		JesterBones npc = view_as<JesterBones>(CClotBody(vecPos, vecAng, "models/zombie_riot/the_bone_zone/basic_bones.mdl", buffed ? BONES_JESTER_SCALE_BUFFED : BONES_JESTER_SCALE, buffed ? BONES_JESTER_HP_BUFFED : BONES_JESTER_HP, ally, false));
		
		b_BonesBuffed[npc.index] = buffed;
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = buffed;
		g_BoneZoneBuffFunction[npc.index] = view_as<Function>(JesterBones_SetBuffed);

		func_NPCDeath[npc.index] = view_as<Function>(JesterBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(JesterBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(JesterBones_ClotThink);
		npc.m_bisWalking = false;

		if (buffed)
		{
			int iActivity = npc.LookupActivity("ACT_JESTER_RUN_BUFFED");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}
		else
		{
			int iActivity = npc.LookupActivity("ACT_JESTER_RUN");
			if(iActivity > 0) npc.StartActivity(iActivity);
		}

		Jester_AttachFuseParticles(npc);

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		DispatchKeyValue(npc.index, "skin", buffed ? BONES_JESTER_SKIN_BUFFED : BONES_JESTER_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = (buffed ? BONES_JESTER_SPEED_BUFFED : BONES_JESTER_SPEED);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void JesterBones_SetBuffed(int index, bool buffed)
{
	CClotBody npc = view_as<CClotBody>(index);
	npc.RemoveAllWearables();
	Jester_RemoveFuseParticles(npc);
	if (!b_BonesBuffed[index] && buffed)
	{
		//Tell the game the skeleton is buffed:
		b_BonesBuffed[index] = true;
		
		//Apply buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_JESTER_SCALE_BUFFED);
		int HP = StringToInt(BONES_JESTER_HP_BUFFED);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_JESTER_SPEED_BUFFED;
		DispatchKeyValue(index, "skin", BONES_JESTER_SKIN_BUFFED);
		int iActivity = npc.LookupActivity("ACT_JESTER_RUN_BUFFED");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else if (b_BonesBuffed[index] && !buffed)
	{
		//Tell the game the skeleton is no longer buffed:
		b_BonesBuffed[index] = false;
		
		//Remove buffed stats:
		DispatchKeyValue(index,	"modelscale", BONES_JESTER_SCALE);
		int HP = StringToInt(BONES_JESTER_HP);
		SetEntProp(index, Prop_Data, "m_iMaxHealth", HP);
		npc.m_flSpeed = BONES_JESTER_SPEED;
		DispatchKeyValue(index, "skin", BONES_JESTER_SKIN);
		
		int iActivity = npc.LookupActivity("ACT_JESTER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}

	Jester_AttachFuseParticles(npc);
}

static int Jester_LeftFuse[2049] = { -1, ... };
static int Jester_RightFuse[2049] = { -1, ... };

void Jester_AttachFuseParticles(CClotBody npc)
{
	float pos[3], ang[3];

	if (!npc.BoneZone_GetBuffedState())
	{
		npc.GetAttachment("bomb_fuse_left", pos, ang);
		int particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE, npc.index, "bomb_fuse_left");
		if (IsValidEntity(particle))
		{
			Jester_LeftFuse[npc.index] = EntIndexToEntRef(particle);
			EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, 0.66);
		}

		npc.GetAttachment("bomb_fuse_right", pos, ang);
		particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE, npc.index, "bomb_fuse_right");
		if (IsValidEntity(particle))
		{
			Jester_RightFuse[npc.index] = EntIndexToEntRef(particle);
			EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, 0.66);
		}
	}
	else
	{
		npc.GetAttachment("bomb_fuse_mondo", pos, ang);
		int particle = ParticleEffectAt_Parent(pos, PARTICLE_JESTER_FUSE_BUFFED, npc.index, "bomb_fuse_mondo");
		if (IsValidEntity(particle))
		{
			Jester_LeftFuse[npc.index] = EntIndexToEntRef(particle);
			EmitSoundToAll(SOUND_JESTER_FUSE, particle, _, _, _, _, 75);
		}
	}
}

void Jester_RemoveFuseParticles(CClotBody npc)
{
	int particle = EntRefToEntIndex(Jester_LeftFuse[npc.index]);
	if (IsValidEntity(particle))
	{
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		RemoveEntity(particle);
	}

	particle = EntRefToEntIndex(Jester_RightFuse[npc.index]);
	if (IsValidEntity(particle))
	{
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		StopSound(particle, SNDCHAN_AUTO, SOUND_JESTER_FUSE);
		RemoveEntity(particle);
	}
}

//TODO 
//Rewrite
public void JesterBones_ClotThink(int iNPC)
{
	JesterBones npc = view_as<JesterBones>(iNPC);
	
//	PrintToChatAll("%.f",GetEntPropFloat(view_as<int>(iNPC), Prop_Data, "m_speed"));
	
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
		//PluginBot_NormalJump(npc.index);
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3], vecother[3]; 
		WorldSpaceCenter(closest, vecTarget);
		WorldSpaceCenter(npc.index, vecother);
			
		float flDistanceToTarget = GetVectorDistance(vecTarget, vecother);
				
		if (npc.BoneZone_GetBuffedState())
		{
			//TODO
		}
		else
		{
			if (flDistanceToTarget <= BONES_JESTER_OPTIMAL_RANGE)
			{
				npc.StopPathing();
			}
			else
			{
				if (flDistanceToTarget > BONES_JESTER_MAX_RANGE)
					npc.StartPathing();

				if (flDistanceToTarget < (npc.GetLeadRadius() * npc.GetLeadRadius()))
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
		}

		npc.StartPathing();
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


public Action JesterBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	JesterBones npc = view_as<JesterBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void JesterBones_NPCDeath(int entity)
{
	JesterBones npc = view_as<JesterBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Jester_RemoveFuseParticles(npc);
	npc.RemoveAllWearables();

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
//	AcceptEntityInput(npc.index, "KillHierarchy");
}
