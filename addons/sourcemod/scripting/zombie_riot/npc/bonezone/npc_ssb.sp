#pragma semicolon 1
#pragma newdecls required

static float BONES_SUPREME_SPEED = 350.0;

#define BONES_SUPREME_SCALE				"2.0"
#define BONES_SUPREME_SKIN				"1"
#define BONES_SUPREME_HP				"35000"
#define MODEL_SSB   					"models/zombie_riot/the_bone_zone/supreme_spookmaster_bones.mdl"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	"npc/fast_zombie/wake1.wav",
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

static char g_SSBBigHit_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_bighit3.mp3"
};

static char g_SSBBigHit_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}:OH FUCK YOU, YOU PIECE OF SHIT!",
	"{haunted}Supreme Spookmaster Bones{default}:OOOHHH, I HATE THAT ATTACK!",
	"{haunted}Supreme Spookmaster Bones{default}:OH, YOU SON OF A FUCKING BITCH!"
};

static char g_SSBPull_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_deathmagnetic_warning_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_deathmagnetic_warning_2.mp3"
};

static char g_SSBPull_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}GET OVER HERE, BROTHERRRRR!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}GET OVER HEERRREEEE!{default}"
};

static char g_SSBMinorWin_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_3.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_4.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_defeated_minor_5.mp3"
};

static char g_SSBMinorWin_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}NOOOOOO! {default}This is an outrage!",
	"{haunted}Supreme Spookmaster Bones{default}: I hate you all. How dare you.",
	"{haunted}Supreme Spookmaster Bones{default}: Ooohhhh noooo, it's one of {olive}these{default} games...",
	"{haunted}Supreme Spookmaster Bones{default}: {yellow}Sigh... {default}What a good game.",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}OH YOU FUCKING PIECE OF SHIT, GOD DAMMIT- {default}Agh...!"
};

static char g_SSBGenericSpell_Sounds[][] = {
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_1.mp3",
	")zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_genericspell_2.mp3"
};

static char g_SSBHellIsHere_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_hellishere_intro_3.mp3"
};

static char g_SSBHellIsHere_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}I AM A GOD!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}TAKE THIS!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {cyan}I AM THE MASTER NOW!{default}"
};

static char g_SSBIntro_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_intro3.mp3"
};

static char g_SSBIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: Get ready, boys. {unusual}Here it comes!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {unusual}I AM A GOD OF VIOLENCE AND WAR, AND YOU ARE BENEATH ME!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: Who dares enter... {unusual}THE HELL ZONE?{default}"
};

static char g_SSBKill_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill3.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill4.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_kill5.mp3"
};

static char g_SSBKill_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: He will never walk again.",
	"{haunted}Supreme Spookmaster Bones{default}: Oh! Oh, I broke his fucking leg!",
	"{haunted}Supreme Spookmaster Bones{default}: Oh my God, he-he's a dead man.",
    "{haunted}Supreme Spookmaster Bones{default}: HA HA HA HAAAA! Suck it.",
    "{haunted}Supreme Spookmaster Bones{default}: He's so useless!"
};

static char g_SSBNecroBlast_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_3.mp3"
};

static char g_SSBNecroBlast_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}FUCK YOU!!!!!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}BOOM, BABY!{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {crimson}DAMN!!!!!{default}"
};

static char g_SSBNecroBlastWarning_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_2.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_necroblast_prepare_3.mp3"
};

static char g_SSBNecroBlastWarning_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}LAUNCH...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}NOT QUITE HADOUKEN...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {darkorange}YOU'RE DEAD MEAT...{default}"
};

static char g_SSBSpin2Win_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_spin2win_intro1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_spin2win_intro2.mp3"
};

static char g_SSBSpin2Win_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}I'm spinning to winning...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {red}Spin 2 Win, baby!{default}"
};

static char g_SSBSummonIntro_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_2.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_3.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_summoner_intro_4.mp3"
};

static char g_SSBSummonIntro_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {vintage}I'm just gonna place out some Mr. Bones on this map, and they'll never notice...{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {vintage}GO HERE, YOU DUMB FUCK.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {vintage}OBJECTIVE: {crimson}KILL.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {vintage}Come on, family! You'll have fuuuuuunnn~!{default}"
};

static char g_SSBLoss_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win1.mp3",
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win2.mp3",
    "zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win3.mp3"
};

static char g_SSBLoss_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}Life sucks, and then you fucking die.{default}",
	"{haunted}Supreme Spookmaster Bones{default}: {red}Good job, guys. Good job.{default}",
    "{haunted}Supreme Spookmaster Bones{default}: {red}Mmhmhahahahahahahahahahahaaaa... AAAAAAHAHAHAHAHAHAHAHA!{default}"
};

static char g_SSBLossEasterEgg_Sounds[][] = {
	"zombie_riot/the_bone_zone/supreme_spookmaster_bones/ssb_win_waytoolong.mp3"
};

static char g_SSBLossEasterEgg_Captions[][] = {
	"{haunted}Supreme Spookmaster Bones{default}: {red}YO, SHIT FOR BRAINS! What GOD DAMN color is this? HUH?! YOU FUCKING BLIND MOTHERFUCKER!{default}",
    "{red}Who the FUCK do you think you are? Coming here and shitting in MY mailbox, playing MY God damn video games? You're gonna learn about colors, you dumb FORESKIN.{default}"
};

static bool b_BonesBuffed[MAXENTITIES];

public void SupremeSpookmasterBones_OnMapStart_NPC()
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

	for (int i = 0; i < (sizeof(g_SSBBigHit_Sounds));   i++) { PrecacheSound(g_SSBBigHit_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBPull_Sounds));   i++) { PrecacheSound(g_SSBPull_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBMinorWin_Sounds));   i++) { PrecacheSound(g_SSBMinorWin_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBGenericSpell_Sounds));   i++) { PrecacheSound(g_SSBGenericSpell_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBHellIsHere_Sounds));   i++) { PrecacheSound(g_SSBHellIsHere_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBIntro_Sounds));   i++) { PrecacheSound(g_SSBIntro_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBKill_Sounds));   i++) { PrecacheSound(g_SSBKill_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBNecroBlast_Sounds));   i++) { PrecacheSound(g_SSBBigHit_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBNecroBlastWarning_Sounds));   i++) { PrecacheSound(g_SSBNecroBlastWarning_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSpin2Win_Sounds));   i++) { PrecacheSound(g_SSBSpin2Win_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBSummonIntro_Sounds));   i++) { PrecacheSound(g_SSBSummonIntro_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLoss_Sounds));   i++) { PrecacheSound(g_SSBLoss_Sounds[i]);   }
	for (int i = 0; i < (sizeof(g_SSBLossEasterEgg_Sounds));   i++) { PrecacheSound(g_SSBLossEasterEgg_Sounds[i]);   }

	PrecacheModel(MODEL_SSB);
}

methodmap SupremeSpookmasterBones < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(b_BonesBuffed[this.index] ? g_IdleSounds_Buffed[GetRandomInt(0, sizeof(g_IdleSounds_Buffed) - 1)] : g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayIdleSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayDeathSound()");
		#endif
	}
	
	public void PlayGibSound() {
	
		EmitSoundToAll(g_GibSounds[GetRandomInt(0, sizeof(g_GibSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayGibSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayMeleeHitSound()");
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

	public void PlayIntroSound()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBIntro_Sounds) - 1);
		EmitSoundToAll(g_SSBIntro_Sounds[rand], _, _, 120);
		CPrintToChatAll(g_SSBIntro_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayIntroSound()");
		#endif
	}
	
	public SupremeSpookmasterBones(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(CClotBody(vecPos, vecAng, MODEL_SSB, BONES_SUPREME_SCALE, BONES_SUPREME_HP, ally, false, true, true, true));
		
		i_NpcInternalId[npc.index] = BONEZONE_SUPREME;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_STAND_NO_HAMMER");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", BONES_SUPREME_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flSpeed = BONES_SUPREME_SPEED;
		
		throwState[npc.index] = THROWSTATE_INACTIVE;
		SDKHook(npc.index, SDKHook_Think, SupremeSpookmasterBones_ClotThink);

		npc.StartPathing();
		npc.PlayIntroSound();
		
		return npc;
	}
}

public void SupremeSpookmasterBones_ClotThink(int iNPC)
{
	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(iNPC);
	
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
	
	if(IsValidEnemy(npc.index, closest))
	{
		float pos[3], targPos[3], optimalPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
		/*npc.StartPathing();
		NPC_SetGoalEntity(npc.index, closest);
		npc.FaceTowards(targPos, 15000.0);*/
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

public Action SupremeSpookmasterBones_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
//	
	return Plugin_Changed;
}

public void SupremeSpookmasterBones_NPCDeath(int entity)
{
	SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	SDKUnhook(entity, SDKHook_Think, SupremeSpookmasterBones_ClotThink);
		
	npc.RemoveAllWearables();
//	AcceptEntityInput(npc.index, "KillHierarchy");
}


