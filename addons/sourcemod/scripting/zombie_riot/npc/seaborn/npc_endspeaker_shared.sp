#pragma semicolon 1
#pragma newdecls required
 
static const char LargeDeath[][] =
{
	"npc/antlion_guard/antlion_guard_die1.wav",
	"npc/antlion_guard/antlion_guard_die2.wav"
};

static const char LargeAnger[][] =
{
	"npc/antlion_guard/angry1.wav",
	"npc/antlion_guard/angry2.wav",
	"npc/antlion_guard/angry3.wav"
};

static const char LargeMeleeHit[][] =
{
	"npc/antlion_guard/shove1.wav"
};

static const char NormalAttack[][] =
{
	"npc/antlion/attack_single1.wav",
	"npc/antlion/attack_single2.wav",
	"npc/antlion/attack_single3.wav"
};

static const char NormalHurt[][] =
{
	"npc/antlion/pain1.wav",
	"npc/antlion/pain2.wav"
};

static const char SmallHurt[][] =
{
	"npc/headcrab_poison/ph_talk1.wav",
	"npc/headcrab_poison/ph_talk2.wav",
	"npc/headcrab_poison/ph_talk3.wav"
};

static const char SmallAttack[][] =
{
	"npc/headcrab_poison/ph_jump1.wav",
	"npc/headcrab_poison/ph_jump2.wav",
	"npc/headcrab_poison/ph_jump3.wav"
};

static const char DigDown[] = "npc/antlion/digdown1.wav";
static const char DigUp[] = "npc/antlion/digup1.wav";
static const char GrabBuff[] = "npc/antlion/land1.wav";

void EndSpeaker_MapStart()
{
	PrecacheSoundArray(LargeDeath);
	PrecacheSoundArray(LargeAnger);
	PrecacheSoundArray(LargeMeleeHit);
	PrecacheSoundArray(NormalAttack);
	PrecacheSoundArray(NormalHurt);
	PrecacheSoundArray(SmallHurt);
	PrecacheSoundArray(SmallAttack);
	PrecacheSound(DigDown);
	PrecacheSound(DigUp);
	PrecacheSound(GrabBuff);
	
	PrecacheModel("models/headcrabclassic.mdl");
	PrecacheModel("models/antlion.mdl");
	PrecacheModel("models/antlion_guard.mdl");
}

#define BUFF_FOUNDER		(1 << 0)
#define BUFF_PREDATOR		(1 << 1)
#define BUFF_BRANDGUIDER	(1 << 2)
#define BUFF_SPEWER		(1 << 3)
#define BUFF_SWARMCALLER	(1 << 4)
#define BUFF_REEFBREAKER	(1 << 5)

static bool HardMode;
static int BaseHealth;

methodmap EndSpeaker < CClotBody
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(DigDown[GetRandomInt(0, sizeof(DigDown) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlaySpawnSound() 
	{
		EmitSoundToAll(DigUp[GetRandomInt(0, sizeof(DigUp) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayGrabSound(int entity) 
	{
		EmitSoundToAll(GrabBuff[GetRandomInt(0, sizeof(GrabBuff) - 1)], entity, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	
	property int m_hBuffs
	{
		public get()
		{
			return this.g_TimesSummoned;
		}
		public set(int value)
		{
			this.g_TimesSummoned = value;
		}
	}
	property int m_iBaseHealth
	{
		public get()
		{
			return BaseHealth;
		}
		public set(int value)
		{
			BaseHealth = value;
		}
	}
	property bool m_bHardMode
	{
		public get()
		{
			return HardMode;
		}
		public set(bool value)
		{
			HardMode = value;
		}
	}
}

methodmap EndSpeakerLarge < EndSpeaker
{
	public void PlayDeathSound() 
	{
		EmitSoundToAll(LargeDeath[GetRandomInt(0, sizeof(LargeDeath) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(LargeAnger[GetRandomInt(0, sizeof(LargeAnger) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(LargeMeleeHit[GetRandomInt(0, sizeof(LargeMeleeHit) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);	
	}
}

methodmap EndSpeakerNormal < EndSpeaker
{
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(NormalAttack[GetRandomInt(0, sizeof(NormalAttack) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(NormalHurt[GetRandomInt(0, sizeof(NormalHurt) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);	
	}
}

methodmap EndSpeakerSmall < EndSpeaker
{
	public void PlayMeleeSound()
 	{
		EmitSoundToAll(SmallAttack[GetRandomInt(0, sizeof(SmallAttack) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(SmallHurt[GetRandomInt(0, sizeof(SmallHurt) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_SOUNDLEVEL);	
	}
}