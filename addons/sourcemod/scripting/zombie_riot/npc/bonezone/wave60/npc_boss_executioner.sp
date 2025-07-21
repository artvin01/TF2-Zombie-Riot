#pragma semicolon 1
#pragma newdecls required

#define LORDREAD_SCALE			"1.3"
#define LORDREAD_HP			"50000"
#define LORDREAD_SKIN			"1"

static float LORDREAD_SPEED = 260.0;

//NIGHTMARISH BRUTALITY: Lordread kills his foes so brutally that all enemies within a short radius of the initial victim who have line-of-sight are briefly stunned.
//SCRAPPED: This would be INSANELY annoying to fight against.
//static float Brutality_Radius = 300.0;	//Effect radius.
//static float Brutality_Stun = 3.0;		//Stun duration.

//PUBLIC EXECUTION: Whenever Lordread kills/downs an enemy, all allies (not counting Lordread) with direct line-of-sight to that enemy are immediately buffed and healed
//to full (max 50k healing).
//SCRAPPED: Completely unnecessary, and also annoying to fight against. Faux-Beard has a more balanced version of this ability with his Morale Boost.
//static float Execution_Heal = 1.0;			//Percentage of max HP to heal allies for when they witness the execution.
//static float Execution_MaxHeal = 50000.0;	//Maximum healing given to individual allies by this ability.

//GUILLOTINE: Lordread's basic melee attack. Lordread slams his axe down in front of him, instantly downing anyone who is hit or dealing MASSIVE damage to buildings/barracks
//units. Enemies who are downed by this attack have their down HP halved. This attack's speed and cooldown become faster as Lordread loses health, up to double at 10% HP.
static float Guillotine_Cooldown = 4.0;			//Melee attack interval.
static float Guillotine_DMG = 9999999.0;		//Damage versus players.
static float Guillotine_DMG_Entities = 10000.0;	//Damage versus entities.
static float Guillotine_Range = 90.0;			//Range in which the attack will be used.
static float Guillotine_SpeedMult = 0.33;		//Maximum additional animation speed boost, based on health lost.
static float Guillotine_CDMult = 0.2;			//Maximum additional cooldown multiplier, based on health lost.
static float Guillotine_MinHP = 0.33;			//Health percentage at which Guillotine becomes its fastest.
static float Guillotine_DownMult = 0.5;			//Amount to multiply downed players' HP when they are downed by this attack.

//LORD OF THE WRETCHED: Lordread thrusts his axe into the air, summoning 8 red lightning bolts on random nav areas within a small radius around him. These lightning bolts
//deal AoE damage and summon random non-buffed medieval skeletons. This ability cannot be used if at least 4 enemies who were summoned by him are still alive.
//Lordread's most powerful ability, he only pulls it out when heavily wounded.
static float Lord_Radius = 800.0;				//Radius in which lightning is called down.
static float Lord_Interval_Extra = 0.2;			//Interval in which extra (non-summoner) bolts are called down.
static float Lord_Interval_Summon = 0.75;		//Interval in which bolts which summon allies are called down.
static float Lord_Delay = 1.0;					//Delay after being summoned at which the lightning bolt will strike.
static float Lord_BlastDMG = 100.0;				//Lightning bolt damage.
static float Lord_BlastRadius = 120.0;			//Lightning bolt radius.
static float Lord_BlastEntityMult = 4.0;		//Amount to multiply lightning damage against buildings.
static float Lord_BlastFalloff_Range = 0.66;	//Maximum range-based falloff.
static float Lord_BlastFalloff_MultiHit = 0.8;	//Amount to multiply lightning damage per target hit.
static float Lord_Cooldown = 50.0;				//Ability cooldown.
static float Lord_StartingCooldown = 0.0;		//Starting cooldown.
static float Lord_Duration = 9.0;				//Duration for which to summon allies.
static float Lord_MaxSummons = 6.0;				//Maximum summon value Lordread can have at once. Lightning bolts are still called above this, but they will not summon allies.
static float Lord_SummonsScaling = 2.0;			//Amount to increase sumon cap per valid mercenary.
static float Lord_CapSummons = 5.0;				//If Lordread has a summon value of at least this value, he cannot use this ability again.
static float Lord_Threshold = 0.4;				//Percentage of max health Lordread must reach before he may use this ability.

//CRIMSON TEMPEST: Lordread holds his axe out and enchants it with red lightning, then begins to spin wildly, rapidly damaging anyone who gets too close. Enemies within
//a small radius (2x the damage radius) are pulled in (weak pull). Lordread is slowed massively during this attack. Buildings take triple damage from this.
static float Tempest_DMG = 66.0;						//Damage dealt per interval.
static float Tempest_EntityMult = 8.0;					//Amount to multiply damage dealt to entities.
static float Tempest_Interval = 0.2;					//Interval in which Crimson Tempest deals damage.
static float Tempest_Radius = 120.0;					//Damage radius.
static float Tempest_SuckRadius = 300.0;				//Radius in which enemies are pulled in.
static float Tempest_Duration = 12.0;					//Spin duration.
static float Tempest_Cooldown = 24.0;					//Cooldown.
static float Tempest_StartingCD = 2.0;//16.0;			//Starting cooldown.
static float Tempest_Speed = 200.0;						//Movement speed while spinning.
static float Tempest_MinPullStrengthMultiplier = 0.33;	//The minimum percentage of the pull strength to use based on distance, should be above 0.0 or else the knockback will outweigh the pull.
static float Tempest_PullStrength = 66.0;				//Pull strength applied to victims per frame. Note that this is at point-blank, and becomes weaker the further away the target is.

static bool Lordread_Attacking[2049] = { false, ... };
static float Lordread_NextLightning[2049] = { 0.0, ... };
static float Lordread_NextSummon[2049] = { 0.0, ... };
static float Lordread_NextExtraLightning[2049] = { 0.0, ... };
static float Lordread_NextTempest[2049] = { 0.0, ... };
static char s_LordreadSequence[MAXENTITIES][255];
static bool b_LordreadForceSequence[MAXENTITIES] = { false, ... };
static float Lordread_LightningEndTime[2049] = { 0.0, ... };
static bool Lordread_StopMoving[2049] = { false, ... };
static float Lordread_SpeenEndTime[2049] = { 0.0, ... };
static float Lordread_NextSpeen[2049] = { 0.0, ... };

ArrayList Lordread_TempestParticles[2049] = { null, ... };

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

static const char g_KillSounds[][] = {
	"ambient_mp3/halloween/male_scream_19.mp3",
	"ambient_mp3/halloween/male_scream_21.mp3",
	"ambient_mp3/halloween/male_scream_23.mp3",
};

#define SOUND_LORDREAD_HEAVY_WHOOSH			")misc/halloween/strongman_fast_whoosh_01.wav"
#define SOUND_LORDREAD_RUSTLE				")player/cyoa_pda_draw.wav"
#define SOUND_LORDREAD_GUILLOTINE_HIT		")weapons/halloween_boss/knight_axe_hit.wav"
#define SOUND_LORDREAD_LIGHTNING_STRIKE		")misc/halloween/spell_mirv_explode_secondary.wav"
#define SOUND_LORDREAD_LIGHTNING_STRIKE_2	")player/taunt_tank_shoot.wav"
#define SOUND_LORDREAD_CALL_LIGHTNING		")misc/halloween/spell_teleport.wav"
#define SOUND_LORDREAD_SUMMON_LOOP			")ambient/halloween/underground_wind_lp_03.wav"
#define SOUND_LORDREAD_TEMPEST_HIT			")weapons/halloween_boss/knight_axe_hit.wav"
//#define SOUND_LORDREAD_SUMMON_INTRO			""

#define PARTICLE_LORDREAD_LIGHTNING_STRIKE_SUMMON	"skull_island_explosion"
#define PARTICLE_LORDREAD_LIGHTNING_STRIKE			"drg_cow_explosioncore_charged"
#define PARTICLE_TEMPEST_TRAIL						"nailtrails_medic_red_crit"

public void Lordread_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_GibSounds));   i++) { PrecacheSound(g_GibSounds[i]);   }
	for (int i = 0; i < (sizeof(g_KillSounds));   i++) { PrecacheSound(g_KillSounds[i]);   }

	PrecacheSound(SOUND_LORDREAD_HEAVY_WHOOSH);
	PrecacheSound(SOUND_LORDREAD_RUSTLE);
	PrecacheSound(SOUND_LORDREAD_GUILLOTINE_HIT);
	PrecacheSound(SOUND_LORDREAD_LIGHTNING_STRIKE);
	PrecacheSound(SOUND_LORDREAD_LIGHTNING_STRIKE_2);
	PrecacheSound(SOUND_LORDREAD_CALL_LIGHTNING);
	PrecacheSound(SOUND_LORDREAD_SUMMON_LOOP);
	PrecacheSound(SOUND_LORDREAD_TEMPEST_HIT);
	//PrecacheSound(SOUND_LORDREAD_SUMMON_INTRO);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lordread, Royal Executioner of Necropolis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_boss_executioner");
	strcopy(data.Icon, sizeof(data.Icon), "pyro");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Necropolain;
	data.Func = Summon_Lordread;
	NPC_Add(data);
}

public void Lordread_StopLoop(Lordread npc)
{
	StopSound(npc.index, SNDCHAN_AUTO, SOUND_LORDREAD_SUMMON_LOOP);
}

static any Summon_Lordread(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Lordread(client, vecPos, vecAng, ally);
}

methodmap Lordread < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(SOUND_HHH_DEATH, this.index, _, _, _, _, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CLordread::PlayMeleeHitSound()");
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

	public bool CanUseGuillotine(float dist)
	{
		if (dist > Guillotine_Range)
			return false;

		if (GetGameTime(this.index) < this.m_flNextMeleeAttack || Lordread_Attacking[this.index])
			return false;

		return true;
	}

	public bool CanUseLightning()
	{
		if (GetGameTime(this.index) < Lordread_NextLightning[this.index] || Lordread_Attacking[this.index] || this.m_flBoneZoneNumSummons >= Lord_CapSummons)
			return false;

		float hp = float(GetEntProp(this.index, Prop_Data, "m_iHealth"));
		float maxHP = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));

		float ratio = hp / maxHP;

		if (ratio > Lord_Threshold)
			return false;

		return true;
	}

	public bool CanUseTempest()
	{
		if (GetGameTime(this.index) < Lordread_NextTempest[this.index] || Lordread_Attacking[this.index])
			return false;

		return true;
	}
	
	public void Guillotine(int target, float targPos[3])
	{
		this.FaceTowards(targPos, 15000.0);

		float hp = float(GetEntProp(this.index, Prop_Data, "m_iHealth"));
		float maxHP = float(GetEntProp(this.index, Prop_Data, "m_iMaxHealth"));

		float ratio = hp / maxHP;

		float rate = 1.0;
		if (ratio < 1.0)
		{
			if (ratio < Guillotine_MinHP)
				rate += Guillotine_SpeedMult;
			else
			{
				float diff = (1.0 - ratio) / (1.0 - Guillotine_MinHP);
				rate += Guillotine_SpeedMult * diff;
			}
		}

		this.AddGesture("ACT_EXECUTIONER_GUILLOTINE", _, _, _, rate);
		Lordread_Attacking[this.index] = true;

		EmitSoundToAll(g_HHHGrunts[GetRandomInt(0, sizeof(g_HHHGrunts) - 1)], this.index, _, _, _, _, 80);
		EmitSoundToAll(SOUND_CAPTAIN_RUSTLE, this.index, _, 120);
	}

	public float CalculateMaxSummons()
	{
		if (GetEntProp(this.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Red))
			return Lord_MaxSummons;

		float maxSummons = Lord_MaxSummons;

		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i))
				continue;

			if (TeutonType[i] == TEUTON_NONE)
				maxSummons += Lord_SummonsScaling;
		}

		return maxSummons;
	}

	public void Lightning()
	{
		int iActivity = this.LookupActivity("ACT_EXECUTIONER_LORD_INTRO");
		if (iActivity > 0)
		{	
			this.StartActivity(iActivity);
			Lordread_Attacking[this.index] = true;
			Lordread_NextSummon[this.index] = 0.0;
			Lordread_NextExtraLightning[this.index] = 0.0;
			Lordread_LightningEndTime[this.index] = 0.0;
			Lordread_StopMoving[this.index] = true;
			EmitSoundToAll(SOUND_LORDREAD_SUMMON_LOOP, this.index, _, _, _, _, 80);
			
			int choice = GetRandomInt(0, sizeof(g_HHHLaughs) - 1);
			EmitSoundToAll(g_HHHLaughs[choice], this.index, _, 120, _, _, 80);
			EmitSoundToAll(g_HHHLaughs[choice], this.index, _, 120, _, 0.75, 60);
			EmitSoundToAll(g_HHHLaughs[choice], this.index, _, 120, _, 0.5, 40);
			//EmitSoundToAll(SOUND_LORDREAD_SUMMON_INTRO);
		}
	}

	public void Tempest()
	{
		int iActivity = this.LookupActivity("ACT_EXECUTIONER_TEMPEST_INTRO");
		if (iActivity > 0)
		{	
			this.StartActivity(iActivity);
			Lordread_Attacking[this.index] = true;
			Lordread_StopMoving[this.index] = true;
			Lordread_SpeenEndTime[this.index] = 0.0;
			Lordread_NextSpeen[this.index] = 0.0;
			
			for (int i = 1; i < 16; i++)
			{
				char attachment[255];
				Format(attachment, sizeof(attachment), "executioner_axe_%i", i);

				float partPos[3], trash[3];
				GetAttachment(this.index, attachment, partPos, trash);

				int particle = ParticleEffectAt_Parent(partPos, PARTICLE_TEMPEST_TRAIL, this.index, attachment);
				if (IsValidEntity(particle))
				{
					if (Lordread_TempestParticles[this.index] == null)
						Lordread_TempestParticles[this.index] = CreateArray(255);

					PushArrayCell(Lordread_TempestParticles[this.index], EntIndexToEntRef(particle));
				}
			}
			
			int choice = GetRandomInt(0, sizeof(g_HHHGrunts) - 1);
			EmitSoundToAll(g_HHHGrunts[choice], this.index, _, 120, _, _, 80);
			EmitSoundToAll(g_HHHGrunts[choice], this.index, _, 120, _, 0.75, 60);
			EmitSoundToAll(g_HHHGrunts[choice], this.index, _, 120, _, 0.5, 40);
		}
	}

	public Lordread(int client, float vecPos[3], float vecAng[3], int ally)
	{	
		Lordread npc = view_as<Lordread>(CClotBody(vecPos, vecAng, BONEZONE_MODEL_BOSS, LORDREAD_SCALE, LORDREAD_HP, ally));

		b_BonesBuffed[npc.index] = false;
		npc.m_bBoneZoneNaturallyBuffed = true;
		b_IsSkeleton[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		npc.m_bisWalking = false;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(Lordread_NPCDeath);
		//func_NPCOnTakeDamage[npc.index] = view_as<Function>(Lordread_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Lordread_ClotThink);
		func_NPCAnimEvent[npc.index] = Lordread_AnimEvent;
		Lordread_NextLightning[npc.index] = GetGameTime(npc.index) + Lord_StartingCooldown;
		Lordread_NextTempest[npc.index] = GetGameTime(npc.index) + Tempest_StartingCD;
		Lordread_Attacking[npc.index] = false;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_EXECUTIONER_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", LORDREAD_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		//IDLE
		npc.m_flSpeed = LORDREAD_SPEED;

		npc.StartPathing();
		
		return npc;
	}
}

public void Lordread_ClearParticles(int ent)
{
	if (Lordread_TempestParticles[ent] != null)
	{
		for (int i = 0; i < GetArraySize(Lordread_TempestParticles[ent]); i++)
		{
			int part = EntRefToEntIndex(GetArrayCell(Lordread_TempestParticles[ent], i));
			if (IsValidEntity(part))
				RemoveEntity(part);
		}
	}

	delete Lordread_TempestParticles[ent];
}

//TODO 
//Rewrite
public void Lordread_ClotThink(int iNPC)
{
	Lordread npc = view_as<Lordread>(iNPC);
	
	npc.Update();
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + (Lordread_Attacking[npc.index] ? 0.0 : DEFAULT_UPDATE_DELAY_FLOAT);
	
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

	if (b_LordreadForceSequence[npc.index])
	{
		int activity = npc.LookupActivity(s_LordreadSequence[npc.index]);
		if (activity > 0)
			npc.StartActivity(activity);

		b_LordreadForceSequence[npc.index] = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + (Lordread_Attacking[npc.index] ? 0.0 : 0.1);
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
		npc.StartPathing();
	}

	if (Lordread_Attacking[npc.index])
	{
		if (Lordread_LightningEndTime[npc.index] > 0.0)
		{
			if (Lordread_LightningEndTime[npc.index] < GetGameTime(npc.index))
			{
				Lordread_LightningEndTime[npc.index] = 0.0;
				Lordread_Attacking[npc.index] = false;
				Lordread_StopMoving[npc.index] = false;
				b_LordreadForceSequence[npc.index] = true;
				s_LordreadSequence[npc.index] = "ACT_EXECUTIONER_RUN";
				Lordread_NextLightning[npc.index] = GetGameTime(npc.index) + Lord_Cooldown;
				Lordread_StopLoop(npc);
				npc.StartPathing();
			}
			else
			{
				float startPos[3];
				npc.WorldSpaceCenter(startPos);
				if (GetGameTime(npc.index) >= Lordread_NextExtraLightning[npc.index])
				{
					Lordread_SummonLightning(npc, startPos, false);
					Lordread_NextExtraLightning[npc.index] = GetGameTime(npc.index) + Lord_Interval_Extra;
				}
				if (GetGameTime(npc.index) >= Lordread_NextSummon[npc.index])
				{
					Lordread_SummonLightning(npc, startPos, true);
					Lordread_NextSummon[npc.index] = GetGameTime(npc.index) + Lord_Interval_Summon;
				}
			}
		}
		else if (Lordread_SpeenEndTime[npc.index] > 0.0)
		{
			if (Lordread_SpeenEndTime[npc.index] < GetGameTime(npc.index))
			{
				Lordread_SpeenEndTime[npc.index] = 0.0;
				Lordread_Attacking[npc.index] = false;
				b_LordreadForceSequence[npc.index] = true;
				s_LordreadSequence[npc.index] = "ACT_EXECUTIONER_RUN";
				Lordread_NextTempest[npc.index] = GetGameTime(npc.index) + Tempest_Cooldown;
				Lordread_StopLoop(npc);
				npc.m_flSpeed = LORDREAD_SPEED;
				Lordread_ClearParticles(npc.index);
			}
			else
			{
				float pos[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

				bool isBlue = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);	
				Explode_Logic_Custom(0.0, npc.index, npc.index, -1, pos, Tempest_SuckRadius, 0.0, 0.0, isBlue, 9999, _, 0.0, Lordread_Pull);
				spawnRing_Vectors(pos, Tempest_SuckRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 0, 0, 255, 1, 0.1, 8.0, 12.0, 1);

				if (GetGameTime(npc.index) >= Lordread_NextSpeen[npc.index])
				{
					Explode_Logic_Custom(Tempest_DMG, npc.index, npc.index, -1, pos, Tempest_Radius, 0.0, 0.0, isBlue, 9999, _, Tempest_EntityMult, Lordread_PlayHitSound);
					Lordread_NextSpeen[npc.index] = GetGameTime(npc.index) + Tempest_Interval;

					spawnRing_Vectors(pos, Tempest_SuckRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 120, 120, 255, 1, 0.33, 4.0, 1.0, 1, 0.1);
				}
			}
		}
	}
	else if (npc.CanUseLightning())
	{
		npc.Lightning();
	}
	else if (npc.CanUseTempest())
	{
		npc.Tempest();
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

		if (npc.CanUseGuillotine(flDistanceToTarget))
		{
			npc.FaceTowards(vecTarget, 15000.0);
			npc.Guillotine(closest, vecTarget);
		}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if (Lordread_StopMoving[npc.index])
	{
		npc.StopPathing();
	}

	npc.PlayIdleSound();
}

public void Lordread_PlayHitSound(int attacker, int victim, float damage)
{
	EmitSoundToAll(SOUND_LORDREAD_TEMPEST_HIT, victim, _, _, _, _, GetRandomInt(80, 120));
}

public void Lordread_Pull(int attacker, int victim, float damage)
{
	if (b_NoKnockbackFromSources[victim] || b_NpcIsInvulnerable[victim] || i_IsABuilding[victim])
		return;

	float userPos[3], vicPos[3];
	WorldSpaceCenter(attacker, userPos);
	WorldSpaceCenter(victim, vicPos);

	float multiplier = 1.0 - (GetVectorDistance(userPos, vicPos) / Tempest_SuckRadius);
	if (multiplier < Tempest_MinPullStrengthMultiplier)
		multiplier = Tempest_MinPullStrengthMultiplier;

	float pullStrength = Tempest_PullStrength * multiplier;

	static float angles[3];
	GetVectorAnglesTwoPoints(userPos, vicPos, angles);

	if (GetEntityFlags(victim) & FL_ONGROUND)
		angles[0] = 0.0;

	float velocity[3], currentVelocity[3];
	GetEntPropVector(victim, Prop_Data, "m_vecVelocity", currentVelocity);
	GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(velocity, -pullStrength);
																
	if (GetEntityFlags(victim) & FL_ONGROUND)
		velocity[2] = fmax(25.0, velocity[2]);

	for (int i = 0; i < 3; i++)
		velocity[i] += currentVelocity[i];
												
	if (IsValidClient(victim))
		TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);  
	else
	{
		//In tower defense, do not allow moving the target.
		if(VIPBuilding_Active())
			return;
			
		if(f_NoUnstuckVariousReasons[victim] > GetGameTime() + 1.0)
		{
			//make the target not stuckable.
			f_NoUnstuckVariousReasons[victim] = GetGameTime() + 1.0;
		}
		SDKUnhook(victim, SDKHook_Think, NpcJumpThink);
		f3_KnockbackToTake[victim] = velocity;
		SDKHook(victim, SDKHook_Think, NpcJumpThink);
	}
}

public void Lordread_SummonLightning(Lordread npc, float startPos[3], bool summon)
{
	float pos[3];
	CNavArea navi = GetRandomNearbyArea(startPos, Lord_Radius);
	navi.GetCenter(pos);

	if (summon)
	{
		spawnRing_Vectors(pos, Lord_BlastRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 160, 0, 255, 255, 1, Lord_Delay, 16.0, 12.0, 1);
		spawnRing_Vectors(pos, Lord_BlastRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 200, 120, 255, 255, 1, Lord_Delay, 8.0, 1.0, 1, 0.1);
	}
	else
	{
		spawnRing_Vectors(pos, Lord_BlastRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 0, 0, 255, 1, Lord_Delay, 16.0, 12.0, 1);
		spawnRing_Vectors(pos, Lord_BlastRadius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/lgtning.vmt", 255, 120, 120, 255, 1, Lord_Delay, 8.0, 1.0, 1, 0.1);
	}

	DataPack pack = new DataPack();
	CreateDataTimer(Lord_Delay, Lordread_LightningStrike, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntIndexToEntRef(npc.index));
	WritePackFloat(pack, pos[0]);
	WritePackFloat(pack, pos[1]);
	WritePackFloat(pack, pos[2]);
	WritePackCell(pack, summon);

	//EmitSoundToAll(SOUND_LORDREAD_CALL_LIGHTNING, _, _, _, _, _, GetRandomInt(80, 120), _, pos);
}

public Action Lordread_LightningStrike(Handle timely, DataPack pack)
{
	ResetPack(pack);

	int ent = EntRefToEntIndex(ReadPackCell(pack));
	float pos[3], startPos[3];
	for (int i = 0; i < 3; i++)
		pos[i] = ReadPackFloat(pack);
	bool summon = ReadPackCell(pack);

	if (!IsValidEntity(ent))
		return Plugin_Continue;

	startPos = pos;
	startPos[2] += 9999.0;

	if (summon)
	{
		SpawnBeam_Vectors(startPos, pos, 0.33, 120, 20, 255, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(startPos, pos, 0.33, 200, 20, 255, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(startPos, pos, 0.33, 120, 20, 255, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 20.0);
	}
	else
	{
		SpawnBeam_Vectors(startPos, pos, 0.33, 255, 20, 0, 255, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(startPos, pos, 0.33, 255, 20, 0, 255, PrecacheModel("materials/sprites/glow02.vmt"), 12.0, 12.0, _, 0.0);
		SpawnBeam_Vectors(startPos, pos, 0.33, 255, 20, 0, 180, PrecacheModel("materials/sprites/lgtning.vmt"), 12.0, 12.0, _, 20.0);
	}

	int particle = ParticleEffectAt(pos, (summon ? PARTICLE_LORDREAD_LIGHTNING_STRIKE_SUMMON : PARTICLE_LORDREAD_LIGHTNING_STRIKE), 2.0);
	if (IsValidEntity(particle))
	{
		EmitSoundToAll(SOUND_LORDREAD_LIGHTNING_STRIKE, particle, _, 120, _, _, GetRandomInt(80, 120));
		EmitSoundToAll(SOUND_LORDREAD_LIGHTNING_STRIKE_2, particle, _, 120, _, _, GetRandomInt(80, 120));
	}

	Lordread npc = view_as<Lordread>(ent);
	bool isBlue = GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == view_as<int>(TFTeam_Blue);	
	Explode_Logic_Custom(Lord_BlastDMG, npc.index, npc.index, npc.index, pos, Lord_BlastRadius, Lord_BlastFalloff_MultiHit, Lord_BlastFalloff_Range, isBlue, _, false, Lord_BlastEntityMult);

	if (npc.m_flBoneZoneNumSummons < npc.CalculateMaxSummons() && summon/* && (MaxEnemiesAllowedSpawnNext(1) <= EnemyNpcAlive)*/)
	{
		float randAng[3];
		randAng[1] = GetRandomFloat(0.0, 360.0);

		int entity;
		switch(GetRandomInt(1, 6))
		{
			case 1:
			{
				entity = PeasantBones(npc.index, pos, randAng, GetTeam(npc.index), false).index;
			}
			case 2:
			{
				entity = ArchmageBones(npc.index, pos, randAng, GetTeam(npc.index), false).index;
			}
			case 3:
			{
				entity = AlchemistBones(npc.index, pos, randAng, GetTeam(npc.index)).index;
			}
			case 4:
			{
				entity = JesterBones(npc.index, pos, randAng, GetTeam(npc.index), false).index;
			}
			case 5:
			{
				entity = SaintBones(npc.index, pos, randAng, GetTeam(npc.index), false).index;
			}
			case 6:
			{
				entity = SquireBones(npc.index, pos, randAng, GetTeam(npc.index), false).index;
			}
		}

		if (IsValidEntity(entity))
		{
			CClotBody summoned = view_as<CClotBody>(entity);
			summoned.m_iBoneZoneSummoner = npc.index;
			summoned.m_flBoneZoneSummonValue = 1.0;
			npc.m_flBoneZoneNumSummons += 1.0;
			NpcAddedToZombiesLeftCurrently(entity, true);
			EmitSoundToAll(g_WitchLaughs[GetRandomInt(0, sizeof(g_WitchLaughs) - 1)], entity, _, _, _, _, GetRandomInt(90, 110));
		}
	}

	return Plugin_Continue;
}

public void Lordread_AnimEvent(int entity, int event)
{
	if (!IsValidEntity(entity))
		return;

	Lordread npc = view_as<Lordread>(entity);

	switch(event)
	{
		case 1013:	//Axe has been swung, play whoosh sound.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, 120);
			EmitSoundToAll(g_HHHYells[GetRandomInt(0, sizeof(g_HHHYells) - 1)], npc.index, _, _, _, _, GetRandomInt(70, 90));
		}
		case 1014:	//Axe has reached the peak of its arc, deal damage.
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
					if(target <= MaxClients)
					{
						SDKHooks_TakeDamage(target, npc.index, npc.index, Guillotine_DMG, DMG_CLUB, -1, _, vecHit);
						RequestFrame(Guillotine_HalveHP, GetClientUserId(target));
					}
					else
						SDKHooks_TakeDamage(target, npc.index, npc.index, Guillotine_DMG_Entities, DMG_CLUB, -1, _, vecHit);					

					EmitSoundToAll(SOUND_LORDREAD_GUILLOTINE_HIT, target, _, 120, _, _, 80);
				}
			}
			delete swingTrace;
		}
		case 1015:	//Axe has reached the end of its swing arc, play sound effect while re-holstering it.
		{
			EmitSoundToAll(SOUND_CAPTAIN_RUSTLE, npc.index, _, 120);
		}
		case 1016:	//Guillotine gesture ends, apply cooldown and end attack state.
		{
			float cd = Guillotine_Cooldown;

			float hp = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
			float maxHP = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

			float ratio = hp / maxHP;

			float mult = 1.0;
			if (ratio < 1.0)
			{
				if (ratio < Guillotine_MinHP)
					mult = Guillotine_CDMult;
				else
				{
					float diff = (1.0 - ratio) / (1.0 - Guillotine_MinHP);
					mult -= Guillotine_CDMult * diff;
				}
			}

			npc.m_flNextMeleeAttack = GetGameTime(npc.index) + (cd * mult);

			Lordread_Attacking[npc.index] = false;
		}
		case 1017:	//Lord of the Wretched intro "whoosh" sound.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, 120);
		}
		case 1018:
		{
			b_LordreadForceSequence[npc.index] = true;
			s_LordreadSequence[npc.index] = "ACT_EXECUTIONER_LORD_ACTIVE";
			Lordread_NextExtraLightning[npc.index] = GetGameTime(npc.index) + Lord_Interval_Extra;
			Lordread_NextSummon[npc.index] = GetGameTime(npc.index) + Lord_Interval_Summon;
			Lordread_LightningEndTime[npc.index] = GetGameTime(npc.index) + Lord_Duration;
		}
		case 1019:	//Crimson Tempest's intro "whoosh" sound.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, 120);
			int choice = GetRandomInt(0, sizeof(g_HHHYells) - 1);
			EmitSoundToAll(g_HHHYells[choice], npc.index, _, 120, _, _, 80);
			EmitSoundToAll(g_HHHYells[choice], npc.index, _, 120, _, 0.75, 60);
			EmitSoundToAll(g_HHHYells[choice], npc.index, _, 120, _, 0.5, 40);
		}
		case 1020:	//Crimson Tempest begins spinning.
		{
			b_LordreadForceSequence[npc.index] = true;
			s_LordreadSequence[npc.index] = "ACT_EXECUTIONER_TEMPEST_ACTIVE";
			Lordread_SpeenEndTime[npc.index] = GetGameTime(npc.index) + Tempest_Duration;
			Lordread_StopMoving[npc.index] = false;
			npc.m_flSpeed = Tempest_Speed;
			EmitSoundToAll(SOUND_LORDREAD_SUMMON_LOOP, npc.index, _, _, _, _, 80);
		}
		case 1021:	//Spinning.
		{
			EmitSoundToAll(SOUND_CAPTAIN_HEAVY_WHOOSH, npc.index, _, 120, _, _, GetRandomInt(90, 110));
		}
	}
}

public void Guillotine_HalveHP(int id)
{
	int client = GetClientOfUserId(id);
	if (!IsValidClient(client))
		return;
	
	if (TeutonType[client] == TEUTON_NONE && dieingstate[client] > 0)
	{
		float health = float(GetEntProp(client, Prop_Data, "m_iHealth"));
		health *= Guillotine_DownMult;
		SetEntProp(client, Prop_Data, "m_iHealth", RoundFloat(health));
	}
}

public void Lordread_NPCDeath(int entity)
{
	Lordread npc = view_as<Lordread>(entity);

	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Lordread_StopLoop(npc);

	DispatchKeyValue(npc.index, "model", "models/bots/skeleton_sniper/skeleton_sniper.mdl");
	view_as<CBaseCombatCharacter>(npc).SetModel("models/bots/skeleton_sniper/skeleton_sniper.mdl");
}