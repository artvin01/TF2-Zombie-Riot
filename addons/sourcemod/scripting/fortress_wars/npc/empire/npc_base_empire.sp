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
	"npc/metropolice/vo/unitisonduty10-8.wav",
	"npc/metropolice/vo/wehavea10-108.wav",
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

static const char CreatedSounds[][] =
{
	"friends/friend_online.wav"
};

static const char SiegeDeathSounds[][] =
{
	"physics/wood/wood_crate_break1.wav",
	"physics/wood/wood_crate_break2.wav",
	"physics/wood/wood_crate_break3.wav",
	"physics/wood/wood_crate_break4.wav",
	"physics/wood/wood_crate_break5.wav"
};

static const char SiegeHurtSounds[][] =
{
	"physics/wood/wood_crate_impact_hard1.wav",
	"physics/wood/wood_crate_impact_hard2.wav",
	"physics/wood/wood_crate_impact_hard3.wav",
	"physics/wood/wood_crate_impact_hard4.wav",
	"physics/wood/wood_crate_impact_hard5.wav"
};

static const char SiegeSelectSounds[][] =
{
	"ambient/lightsoff.wav"	
};

static const char SiegeMoveSounds[][] =
{
	"ambient/lightson.wav"	
};

static const char BuildingSelectSounds[][] =
{
	"ambient/machines/machine1_hit1.wav",
	"ambient/machines/machine1_hit2.wav",
};

static const char BuildingCombatAlertSounds[][] =
{
	"npc/overwatch/radiovoice/socialfractureinprogress.wav",
	"npc/overwatch/radiovoice/threattoproperty51b.wav"
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
	PrecacheSoundArray(CreatedSounds);
	PrecacheSoundArray(SiegeDeathSounds);
	PrecacheSoundArray(SiegeHurtSounds);
	PrecacheSoundArray(SiegeSelectSounds);
	PrecacheSoundArray(SiegeMoveSounds);
	PrecacheSoundArray(BuildingSelectSounds);
	PrecacheSoundArray(BuildingCombatAlertSounds);
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
		
		if(this.HasFlag(Flag_Mechanical))
		{
			EmitSoundToAll(SiegeHurtSounds[GetURandomInt() % sizeof(SiegeHurtSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		else
		{
			EmitSoundToAll(HurtSounds[GetURandomInt() % sizeof(HurtSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound()
	{
		if(this.HasFlag(Flag_Mechanical))
		{
			EmitSoundToAll(SiegeDeathSounds[GetURandomInt() % sizeof(SiegeDeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
		else
		{
			EmitSoundToAll(DeathSounds[GetURandomInt() % sizeof(DeathSounds)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		}
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
	
	public EmpireBody(int team, const float vecPos[3], const float vecAng[3],
						const char[] model = COMBINE_CUSTOM_MODEL,
						const char[] modelscale = "1.0",
						const char[] health = "125",
						bool isBuilding = false,
						bool isGiant = false,
						const float CustomThreeDimensions[3] = {0.0,0.0,0.0},
						int type = 0)
	{
		EmpireBody npc = view_as<EmpireBody>(UnitBody(team, vecPos, vecAng, model, modelscale, health, isBuilding, isGiant, CustomThreeDimensions));
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetEntityRenderColor(npc.index, TeamColor[team][0], TeamColor[team][1], TeamColor[team][2], 255);
		
		if(isBuilding)
		{
			npc.m_iBleedType = BLEEDTYPE_METAL;
			npc.m_iNpcStepVariation = STEPTYPE_NONE;

			npc.SetSoundFunc(Sound_Select, PlayBuildingSelectSound);
			npc.SetSoundFunc(Sound_CombatAlert, PlayBuildingCombatAlertSound);
		}
		else
		{
			switch(type)
			{
				case 0:	// Ground Unit
				{
					npc.m_iBleedType = BLEEDTYPE_NORMAL;
					npc.m_iStepNoiseType = isGiant ? STEPSOUND_GIANT : STEPSOUND_NORMAL;
					npc.m_iNpcStepVariation = STEPTYPE_COMBINE_METRO;

					npc.SetSoundFunc(Sound_Select, PlaySelectSound);
					npc.SetSoundFunc(Sound_Move, PlayMoveSound);
					npc.SetSoundFunc(Sound_Attack, PlayAttackSound);
					npc.SetSoundFunc(Sound_CombatAlert, PlayCombatAlertSound);
				}
				case 1:	// Mounted Unit
				{
					npc.m_iBleedType = BLEEDTYPE_NORMAL;
					npc.m_iStepNoiseType = isGiant ? STEPSOUND_GIANT : STEPSOUND_NORMAL;
					npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

					npc.SetSoundFunc(Sound_Select, PlaySelectSound);
					npc.SetSoundFunc(Sound_Move, PlayMoveSound);
					npc.SetSoundFunc(Sound_Attack, PlayAttackSound);
					npc.SetSoundFunc(Sound_CombatAlert, PlayCombatAlertSound);
				}
				case 2:	// Siege Unit
				{
					npc.m_iBleedType = BLEEDTYPE_METAL;
					npc.m_iNpcStepVariation = STEPTYPE_NONE;

					npc.SetSoundFunc(Sound_Select, PlaySiegeSelectSound);
					npc.SetSoundFunc(Sound_Move, PlaySiegeMoveSound);
					npc.SetSoundFunc(Sound_Attack, PlaySiegeMoveSound);
					npc.SetSoundFunc(Sound_CombatAlert, PlayCombatAlertSound);
				}
			}
		}
		
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

			if(!npc.HasFlag(Flag_Mechanical))
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

static void PlaySiegeSelectSound(int client)
{
	EmitSoundToClient(client, SiegeSelectSounds[GetURandomInt() % sizeof(SiegeSelectSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayBuildingSelectSound(int client)
{
	EmitSoundToClient(client, BuildingSelectSounds[GetURandomInt() % sizeof(BuildingSelectSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayMoveSound(int client)
{
	EmitSoundToClient(client, MoveSounds[GetURandomInt() % sizeof(MoveSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlaySiegeMoveSound(int client)
{
	EmitSoundToClient(client, SiegeMoveSounds[GetURandomInt() % sizeof(SiegeMoveSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayAttackSound(int client)
{
	EmitSoundToClient(client, AttackSounds[GetURandomInt() % sizeof(AttackSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayCombatAlertSound(int client)
{
	EmitSoundToClient(client, CombatAlertSounds[GetURandomInt() % sizeof(CombatAlertSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayBuildingCombatAlertSound(int client)
{
	EmitSoundToClient(client, BuildingCombatAlertSounds[GetURandomInt() % sizeof(BuildingCombatAlertSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}
