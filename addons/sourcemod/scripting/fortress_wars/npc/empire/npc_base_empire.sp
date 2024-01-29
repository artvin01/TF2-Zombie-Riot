#pragma semicolon 1
#pragma newdecls required

static const char DeathSounds[][] =
{
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char HurtSounds[][] =
{
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav",
};

static const char IdleSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",

	"npc/metropolice/vo/pickupthecan2.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
};

static const char IdleAlertedSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/canalblock.wav",
	"npc/metropolice/vo/chuckle.wav",
	"npc/metropolice/vo/citizen.wav",
	"npc/metropolice/vo/code7.wav",
	"npc/metropolice/vo/code100.wav",
	"npc/metropolice/vo/copy.wav",
	"npc/metropolice/vo/breakhiscover.wav",
	"npc/metropolice/vo/help.wav",
	"npc/metropolice/vo/hesgone148.wav",
	"npc/metropolice/vo/hesrunning.wav",
	"npc/metropolice/vo/infection.wav",
	"npc/metropolice/vo/king.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",

	"npc/metropolice/vo/pickupthecan3.wav",
	"npc/metropolice/vo/sociocide.wav",
	"npc/metropolice/vo/watchit.wav",
	"npc/metropolice/vo/xray.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/takedown.wav",
};

static const char SelectSounds[][] =
{
	"npc/metropolice/vo/localcptreportstatus.wav",
	"npc/metropolice/vo/needanyhelpwiththisone.wav",
	"npc/metropolice/vo/pickupthecan1.wav",
	"npc/metropolice/vo/stillgetting647e.wav",
	"npc/metropolice/vo/therehegoeshesat.wav",
	"npc/metropolice/vo/unitis10-65.wav",
	"npc/metropolice/vo/unitis10-8standingby.wav",
	"npc/metropolice/vo/unitisonduty10-8.wav"
};

static const char MoveSounds[][] =
{
	"npc/metropolice/vo/affirmative.wav",
	"npc/metropolice/vo/affirmative2.wav",
	"npc/metropolice/vo/lookingfortrouble.wav",
	"npc/metropolice/vo/moveit.wav",
	"npc/metropolice/vo/moveit2.wav",
	"npc/metropolice/vo/movingtohardpoint.wav",
	"npc/metropolice/vo/movingtohardpoint2.wav",
	"npc/metropolice/vo/rodgerthat.wav",
	"npc/metropolice/vo/wehavea10-108.wav",
	"npc/metropolice/vo/youknockeditover.wav",
	"npc/metropolice/vo/youwantamalcomplianceverdict.wav"
};

static const char AttackSounds[][] =
{
	"npc/metropolice/vo/pacifying.wav",
	"npc/metropolice/vo/readytojudge.wav",
	"npc/metropolice/vo/readytoamputate.wav"
};

static const char CombatAlertSounds[][] =
{
	"npc/metropolice/vo/11-99officerneedsassistance.wav",
	"npc/metropolice/vo/cpiscompromised.wav",
	"npc/metropolice/vo/is10-108.wav",
	"npc/metropolice/vo/minorhitscontinuing.wav",
	"npc/metropolice/vo/officerneedsassistance.wav",
	"npc/metropolice/vo/officerneedshelp.wav",
	"npc/metropolice/vo/wehavea10-108.wav"
};

void EmpireBody_MapStart()
{
	PrecacheSoundArray(DeathSounds);
	PrecacheSoundArray(HurtSounds);
	PrecacheSoundArray(IdleSounds);
	PrecacheSoundArray(IdleAlertedSounds);
	PrecacheSoundArray(SelectSounds);
	PrecacheSoundArray(MoveSounds);
	PrecacheSoundArray(AttackSounds);
	PrecacheSoundArray(CombatAlertSounds);
	PrecacheModel(COMBINE_CUSTOM_MODEL);
}

methodmap EmpireBody < UnitBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(IdleSounds[GetURandomInt() % sizeof(IdleSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(IdleAlertedSounds[GetURandomInt() % sizeof(IdleAlertedSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(HurtSounds[GetURandomInt() % sizeof(HurtSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(DeathSounds[GetURandomInt() % sizeof(DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}

	public bool ThinkStart(float gameTime)
	{
		return UnitBody_ThinkStart(this, gameTime);
	}
	public int ThinkTarget(float gameTime)
	{
		return UnitBody_ThinkTarget(this, gameTime);
	}
	public bool ThinkMove(float gameTime)
	{
		return UnitBody_ThinkMove(this, gameTime);
	}
	
	public EmpireBody(int client, const float vecPos[3], const float vecAng[3],
						const char[] model = COMBINE_CUSTOM_MODEL,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isBuilding = false,
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0})
	{
		EmpireBody npc = view_as<EmpireBody>(UnitBody(client, vecPos, vecAng, model, modelscale, health, isBuilding, isGiant, CustomThreeDimensions));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;

		npc.SetSoundFunc(Sound_Select, PlaySelectSound);
		npc.SetSoundFunc(Sound_Move, PlayMoveSound);
		npc.SetSoundFunc(Sound_Attack, PlayAttackSound);
		npc.SetSoundFunc(Sound_CombatAlert, PlayCombatAlertSound);
		
		func_NPCDeath[npc.index] = EmpireBody_Death;
		func_NPCOnTakeDamage[npc.index] = EmpireBody_TakeDamage;

		return npc;
	}
}

void EmpireBody_TakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker > 0)
	{
		EmpireBody npc = view_as<EmpireBody>(victim);

		if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
		{
			npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;

			npc.PlayHurtSound();
			npc.AddNextGesture("ACT_GESTURE_FLINCH_HEAD");
		}
	}
}

void EmpireBody_Death(int entity)
{
	EmpireBody npc = view_as<EmpireBody>(entity);
	
	if(!npc.m_bGib)
		npc.PlayDeathSound();
}

static void PlaySelectSound(int client)
{
	EmitSoundToClient(client, SelectSounds[GetURandomInt() % sizeof(SelectSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayMoveSound(int client)
{
	EmitSoundToClient(client, MoveSounds[GetURandomInt() % sizeof(MoveSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayAttackSound(int client)
{
	EmitSoundToClient(client, AttackSounds[GetURandomInt() % sizeof(AttackSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayCombatAlertSound(int client)
{
	EmitSoundToClient(client, CombatAlertSounds[GetURandomInt() % sizeof(CombatAlertSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}
