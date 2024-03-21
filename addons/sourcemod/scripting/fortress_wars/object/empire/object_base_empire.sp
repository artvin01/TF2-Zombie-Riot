#pragma semicolon 1
#pragma newdecls required

static const char SelectSounds[][] =
{
	"ambient/machines/machine1_hit1.wav",
	"ambient/machines/machine1_hit2.wav",
};

static const char CombatAlertSounds[][] =
{
	"npc/overwatch/radiovoice/socialfractureinprogress.wav",
	"npc/overwatch/radiovoice/threattoproperty51b.wav"
};

static const char CreatedSounds[][] =
{
	"friends/friend_online.wav"
};

static const char BigDeathSounds[][] =
{
	"weapons/sentry_explode.wav"
};

static const char DeathSounds[][] =
{
	"weapons/dispenser_explode.wav"
};

static const char SmallDeathSounds[][] =
{
	"weapons/teleporter_explode.wav"
};

static const char HurtSounds[][] =
{
	"physics/metal/metal_solid_impact_bullet1.wav",
	"physics/metal/metal_solid_impact_bullet2.wav",
	"physics/metal/metal_solid_impact_bullet3.wav",
	"physics/metal/metal_solid_impact_bullet4.wav"
};

void ObjectEmpire_Setup()
{
	PrecacheSoundArray(SelectSounds);
	PrecacheSoundArray(CombatAlertSounds);
	PrecacheSoundArray(CreatedSounds);
	PrecacheSoundArray(BigDeathSounds);
	PrecacheSoundArray(DeathSounds);
	PrecacheSoundArray(SmallDeathSounds);
	PrecacheSoundArray(HurtSounds);
}

methodmap EmpireObject < UnitObject
{
	public void PlayHurtSound()
	{
		EmitSoundToAll(HurtSounds[GetURandomInt() % sizeof(HurtSounds)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound()
	{
		if(this.HasFlag(Flag_Heroic))
		{
			EmitSoundToAll(BigDeathSounds[GetURandomInt() % sizeof(BigDeathSounds)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
		else
		{
			EmitSoundToAll(DeathSounds[GetURandomInt() % sizeof(DeathSounds)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		}
	}

	
	public EmpireObject(int team, const float vecPos[3],
					int scale = 1,
					int health = 125,
					bool solid = true,
					const char[] model = "",
					const float vecAng[3] = OBJECT_OFFSET,
					float modelscale = 0.0)
	{
		EmpireObject obj = view_as<EmpireObject>(UnitObject(team, vecPos, scale, health, solid, model, vecAng, modelscale));
		
		obj.SetSoundFunc(Sound_Select, PlaySelectSound);
		obj.SetSoundFunc(Sound_CombatAlert, PlayCombatAlertSound);
		
		obj.m_hOnTakeDamageFunc = EmpireObject_TakeDamage;
		obj.m_hDeathFunc = EmpireObject_Death;

		return obj;
	}
}

void EmpireObject_TakeDamage(int victim, int &attacker)
{
	if(attacker > 0)
	{
		EmpireBody obj = view_as<EmpireBody>(victim);

		if(obj.m_flHeadshotCooldown < GetGameTime(obj.index))
		{
			obj.m_flHeadshotCooldown = GetGameTime(obj.index) + DEFAULT_HURTDELAY;
			obj.PlayHurtSound();
		}
	}
}

void EmpireObject_Death(int entity)
{
	EmpireObject obj = view_as<EmpireObject>(entity);
	obj.PlayDeathSound();
}

static void PlaySelectSound(int client)
{
	EmitSoundToClient(client, SelectSounds[GetURandomInt() % sizeof(SelectSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}

static void PlayCombatAlertSound(int client)
{
	EmitSoundToClient(client, CombatAlertSounds[GetURandomInt() % sizeof(CombatAlertSounds)], _, SNDCHAN_STATIC, SNDLEVEL_NONE);
}
