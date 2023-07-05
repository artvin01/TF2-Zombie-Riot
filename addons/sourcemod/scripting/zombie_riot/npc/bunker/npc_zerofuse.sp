#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"zombie_riot/zerofuse/death1.mp3",
	"zombie_riot/zerofuse/death2.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"misc/null.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/blade_hit1.wav",
	"weapons/blade_hit2.wav",
	"weapons/blade_hit3.wav",
	"weapons/blade_hit4.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav",
};

static const char g_RangeAttackTwo[][] = {
	"weapons/diamond_back_01.wav",
	"weapons/diamond_back_02.wav",
	"weapons/diamond_back_03.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static const char g_BalanceSound[][] = {
	"zombie_riot/zerofuse/balanced_rage1.mp3",
};

static const char g_HealingSound[][] = {
	"zombie_riot/zerofuse/healing.mp3",
};

static const char g_HealingSound2[][] = {
	"zombie_riot/zerofuse/healing2.mp3",
};

static const char g_SummonMinions[][] = {
	"zombie_riot/zerofuse/lastman1.mp3",
};

static const char g_IntroSound[][] = {
	//"zombie_riot/zerofuse/intro1.mp3",
	"freak_fortress_2/zerofuse/intro4.mp3",
};

static const char g_JumpSound[][] = {
	"freak_fortress_2/zerofuse/jump1.mp3",
};

static const char g_ZeroMusic[][] = {
	"#zombie_riot/zerofuse/bgm1.mp3",
};

static const char g_AoeHit1[][] = {
	//"weapons/airstrike_small_explosion_02.wav",
	//"weapons/airstrike_small_explosion_03.wav",
	"zombie_riot/zerofuse/aoe_stab1.mp3",
};

static const char g_AoeHit2[][] = {
	"zombie_riot/zerofuse/aoe_stab2.mp3",
};

static const char g_AoeHit3[][] = {
	"zombie_riot/zerofuse/aoe_stab3.mp3",
};

static const char g_Switch1[][] = {
	"zombie_riot/zerofuse/switching1.mp3",
};

static const char g_Switch2[][] = {
	"zombie_riot/zerofuse/switching2.mp3",
};

static const char g_Switch3[][] = {
	"zombie_riot/zerofuse/switching3.mp3",
};

static const char g_Mood1[][] = {
	"zombie_riot/zerofuse/mood1.mp3",
};

static const char g_Mood2[][] = {
	"zombie_riot/zerofuse/mood2.mp3",
};

static const char g_Mood3[][] = {
	"zombie_riot/zerofuse/mood3.mp3",
};

static const char g_Kill1[][] = {
	"zombie_riot/zerofuse/kill1.mp3",
};

static const char g_Kill2[][] = {
	"zombie_riot/zerofuse/kill2.mp3",
};

static const char g_Lifeloss[][] = {
	"zombie_riot/zerofuse/lifeloss.mp3",
};

static float fl_AbilityManager_Timer[MAXENTITIES];
static float fl_AbilityManager_TimerFirstUsage = 10.0;
static float fl_AbilityManager_TimerSecondUsage = 15.0;
static bool b_AbilityManager[MAXENTITIES];
static bool b_AbilityWrathRage[MAXENTITIES];

static float fl_MainSpeed = 412.0;
static float fl_MainDamage = 350.0;
static float fl_LifelossDamage = 520.0;

static float fl_MinionSummon[MAXENTITIES];
static float fl_WrathRage[MAXENTITIES];
static float fl_DefenseHealing_Timer[MAXENTITIES];
static float fl_DefenseHealing_EndTimer[MAXENTITIES];
static float fl_ForceWrath[MAXENTITIES];
static float fl_RocketGunTimer[MAXENTITIES];
static float fl_DisableFakeUber[MAXENTITIES];
static float fl_Stun_Timer[MAXENTITIES];
static bool b_RocketGunReady[MAXENTITIES];
static bool b_RocketGunUsage[MAXENTITIES];
static bool b_WrathRage[MAXENTITIES];
static bool b_DefenseHealing[MAXENTITIES];
static bool b_ForceWrath[MAXENTITIES];
static bool b_Lifeloss[MAXENTITIES];
static bool b_FakeUber[MAXENTITIES];
static bool b_Stun[MAXENTITIES];
static bool b_FirstMessage[MAXENTITIES];
static bool b_SecondMessage[MAXENTITIES];

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_ZeroMusic_Timer[MAXENTITIES];

static int i_AoeHits[MAXENTITIES];
static int i_UntilAoe = 3;
static int i_DamageUntilRage[MAXENTITIES];
static bool b_HealingIsTooStrong = false; //if his healing is way too strong use the other method
static bool b_HealingIsTooStrongOnMelee = false; //if his healing is way too strong use the other method

void TrueZerofuse_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangeAttackTwo));   i++) { PrecacheSound(g_RangeAttackTwo[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_BalanceSound));   i++) { PrecacheSound(g_BalanceSound[i]);   }
	for (int i = 0; i < (sizeof(g_HealingSound));   i++) { PrecacheSound(g_HealingSound[i]);   }
	for (int i = 0; i < (sizeof(g_HealingSound2));   i++) { PrecacheSound(g_HealingSound2[i]);   }
	for (int i = 0; i < (sizeof(g_SummonMinions));   i++) { PrecacheSound(g_SummonMinions[i]);   }
	for (int i = 0; i < (sizeof(g_IntroSound));   i++) { PrecacheSound(g_IntroSound[i]);   }
	for (int i = 0; i < (sizeof(g_JumpSound));   i++) { PrecacheSound(g_JumpSound[i]);   }
	for (int i = 0; i < (sizeof(g_ZeroMusic));   i++) { PrecacheSound(g_ZeroMusic[i]);   }
	for (int i = 0; i < (sizeof(g_AoeHit1));   i++) { PrecacheSound(g_AoeHit1[i]);   }
	for (int i = 0; i < (sizeof(g_AoeHit2));   i++) { PrecacheSound(g_AoeHit2[i]);   }
	for (int i = 0; i < (sizeof(g_AoeHit3));   i++) { PrecacheSound(g_AoeHit3[i]);   }
	for (int i = 0; i < (sizeof(g_Switch1));   i++) { PrecacheSound(g_Switch1[i]);   }
	for (int i = 0; i < (sizeof(g_Switch2));   i++) { PrecacheSound(g_Switch2[i]);   }
	for (int i = 0; i < (sizeof(g_Switch3));   i++) { PrecacheSound(g_Switch3[i]);   }
	for (int i = 0; i < (sizeof(g_Mood1));   i++) { PrecacheSound(g_Mood1[i]);   }
	for (int i = 0; i < (sizeof(g_Mood2));   i++) { PrecacheSound(g_Mood2[i]);   }
	for (int i = 0; i < (sizeof(g_Mood3));   i++) { PrecacheSound(g_Mood3[i]);   }
	for (int i = 0; i < (sizeof(g_Kill1));   i++) { PrecacheSound(g_Kill1[i]);   }
	for (int i = 0; i < (sizeof(g_Kill2));   i++) { PrecacheSound(g_Kill2[i]);   }
	for (int i = 0; i < (sizeof(g_Lifeloss));   i++) { PrecacheSound(g_Lifeloss[i]);   }
	PrecacheSound("zombie_riot/zerofuse/offensive_rage2.mp3", true);
	PrecacheSound("zombie_riot/shoptheme.mp3", true);
	PrecacheSound(EXPLOSION1, true);
	PrecacheSound(EXPLOSION2, true);
	PrecacheSound(EXPLOSION3, true);
}

methodmap TrueZerofuse < CClotBody
{
	property float fl_ForceWrath//penner hat sich verweigert in perma wrath raus zugehen
	{
		public get()							{ return fl_ForceWrath[this.index]; }
		public set(float TempValueForProperty) 	{ fl_ForceWrath[this.index] = TempValueForProperty; }
	}
	property float fl_WrathRage
	{
		public get()							{ return fl_WrathRage[this.index]; }
		public set(float TempValueForProperty) 	{ fl_WrathRage[this.index] = TempValueForProperty; }
	}
	property bool b_ForceWrath
	{
		public get()							{ return b_ForceWrath[this.index]; }
		public set(bool TempValueForProperty) 	{ b_ForceWrath[this.index] = TempValueForProperty; }
	}
	property bool b_WrathRage
	{
		public get()							{ return b_WrathRage[this.index]; }
		public set(bool TempValueForProperty) 	{ b_WrathRage[this.index] = TempValueForProperty; }
	}
	property bool b_AbilityWrathRage
	{
		public get()							{ return b_AbilityWrathRage[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AbilityWrathRage[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRocketGunThrow() {
		EmitSoundToAll(g_RangeAttackTwo[GetRandomInt(0, sizeof(g_RangeAttackTwo) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayBalanceSound() {
		EmitSoundToAll(g_BalanceSound[GetRandomInt(0, sizeof(g_BalanceSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_BalanceSound[GetRandomInt(0, sizeof(g_BalanceSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_BalanceSound[GetRandomInt(0, sizeof(g_BalanceSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_BalanceSound[GetRandomInt(0, sizeof(g_BalanceSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayBalanceSound()");
		#endif
	}
	public void PlayHealingSound() {
		switch(GetRandomInt(1,4))
		{
			case 1:
			{
				EmitSoundToAll(g_HealingSound2[GetRandomInt(0, sizeof(g_HealingSound2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound2[GetRandomInt(0, sizeof(g_HealingSound2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound2[GetRandomInt(0, sizeof(g_HealingSound2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			default:
			{
				EmitSoundToAll(g_HealingSound[GetRandomInt(0, sizeof(g_HealingSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound[GetRandomInt(0, sizeof(g_HealingSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound[GetRandomInt(0, sizeof(g_HealingSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound[GetRandomInt(0, sizeof(g_HealingSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_HealingSound[GetRandomInt(0, sizeof(g_HealingSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
		}
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayHealingSound()");
		#endif
	}
	public void PlaySummonMinionSound() {
		EmitSoundToAll(g_SummonMinions[GetRandomInt(0, sizeof(g_SummonMinions) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_SummonMinions[GetRandomInt(0, sizeof(g_SummonMinions) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_SummonMinions[GetRandomInt(0, sizeof(g_SummonMinions) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySummonMinionSound()");
		#endif
	}
	public void PlayMoodOne() {
		EmitSoundToAll(g_Mood1[GetRandomInt(0, sizeof(g_Mood1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood1[GetRandomInt(0, sizeof(g_Mood1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood1[GetRandomInt(0, sizeof(g_Mood1) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySummonMinionSound()");
		#endif
	}
	public void PlayMoodTwo() {
		EmitSoundToAll(g_Mood2[GetRandomInt(0, sizeof(g_Mood2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood2[GetRandomInt(0, sizeof(g_Mood2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood2[GetRandomInt(0, sizeof(g_Mood2) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySummonMinionSound()");
		#endif
	}
	public void PlayMoodThree() {
		EmitSoundToAll(g_Mood3[GetRandomInt(0, sizeof(g_Mood3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood3[GetRandomInt(0, sizeof(g_Mood3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Mood3[GetRandomInt(0, sizeof(g_Mood3) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySummonMinionSound()");
		#endif
	}
	public void PlayKillPlayer() {
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				EmitSoundToAll(g_Kill1[GetRandomInt(0, sizeof(g_Kill1) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Kill1[GetRandomInt(0, sizeof(g_Kill1) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			case 2:
			{
				EmitSoundToAll(g_Kill2[GetRandomInt(0, sizeof(g_Kill2) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Kill2[GetRandomInt(0, sizeof(g_Kill2) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
		}
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySummonMinionSound()");
		#endif
	}
	public void PlayZeroMusic() {
		//for(int client_check=1; client_check<=MaxClients; client_check++)
		//{
		//	if(IsClientInGame(client_check) && !IsFakeClient(client_check))
		//	{
		//		EmitSoundToClient(client_check, g_ZeroMusic[GetRandomInt(0, sizeof(g_ZeroMusic) - 1)], _, SNDCHAN_STATIC, SNDLEVEL_NONE, _, BOSS_ZOMBIE_VOLUME);
		//	}
		//}
		
		EmitSoundToAll(g_ZeroMusic[GetRandomInt(0, sizeof(g_ZeroMusic) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_ZeroMusic[GetRandomInt(0, sizeof(g_ZeroMusic) - 1)], this.index, SNDCHAN_AUTO, 120, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayZeroMusic()");
		#endif
	}
	public void PlayAoeSound() {
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				EmitSoundToAll(g_AoeHit1[GetRandomInt(0, sizeof(g_AoeHit1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_AoeHit1[GetRandomInt(0, sizeof(g_AoeHit1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			case 2:
			{
				EmitSoundToAll(g_AoeHit2[GetRandomInt(0, sizeof(g_AoeHit2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_AoeHit2[GetRandomInt(0, sizeof(g_AoeHit2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			case 3:
			{
				EmitSoundToAll(g_AoeHit3[GetRandomInt(0, sizeof(g_AoeHit3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_AoeHit3[GetRandomInt(0, sizeof(g_AoeHit3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
		}
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAoe()");
		#endif
	}
	public void PlayJumpSound() {
		EmitSoundToAll(g_JumpSound[GetRandomInt(0, sizeof(g_JumpSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_JumpSound[GetRandomInt(0, sizeof(g_JumpSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_JumpSound[GetRandomInt(0, sizeof(g_JumpSound) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAoe()");
		#endif
	}
	public void PlayLifelossSound() {
		EmitSoundToAll(g_Lifeloss[GetRandomInt(0, sizeof(g_Lifeloss) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Lifeloss[GetRandomInt(0, sizeof(g_Lifeloss) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		//EmitSoundToAll(g_Lifeloss[GetRandomInt(0, sizeof(g_Lifeloss) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAoe()");
		#endif
	}
	public void PlaySwitchSound() {
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				EmitSoundToAll(g_Switch1[GetRandomInt(0, sizeof(g_Switch1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch1[GetRandomInt(0, sizeof(g_Switch1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch1[GetRandomInt(0, sizeof(g_Switch1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch1[GetRandomInt(0, sizeof(g_Switch1) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			case 2:
			{
				EmitSoundToAll(g_Switch2[GetRandomInt(0, sizeof(g_Switch2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch2[GetRandomInt(0, sizeof(g_Switch2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch2[GetRandomInt(0, sizeof(g_Switch2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch2[GetRandomInt(0, sizeof(g_Switch2) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
			case 3:
			{
				EmitSoundToAll(g_Switch3[GetRandomInt(0, sizeof(g_Switch3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch3[GetRandomInt(0, sizeof(g_Switch3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch3[GetRandomInt(0, sizeof(g_Switch3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
				EmitSoundToAll(g_Switch3[GetRandomInt(0, sizeof(g_Switch3) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
			}
		}
		EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		//EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAoe()");
		#endif
	}
	public void PlayIntroSound() {
		EmitSoundToAll(g_IntroSound[GetRandomInt(0, sizeof(g_IntroSound) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAoe()");
		#endif
	}
	
	public TrueZerofuse(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		TrueZerofuse npc = view_as<TrueZerofuse>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "2250000", ally));
		
		i_NpcInternalId[npc.index] = TRUE_ZEROFUSE;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		i_ExplosiveProjectileHexArray[npc.index] = EP_NO_KNOCKBACK;
		
		if(!b_IsAlliedNpc[npc.index])//idk why you would even allow him to be an ally...
		{
			RaidBossActive = EntRefToEntIndex(npc.index);
			
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					//LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					//ShowGameText(client_check, "item_armor", 1, "%t", "Zerofuse Spawn Message");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 310.0;
			b_ForceWrath[npc.index] = false;
			b_FirstMessage[npc.index] = true;
			b_SecondMessage[npc.index] = true;
			npc.PlayIntroSound();
			Music_Stop_Zerofuse_Theme(npc.index);
			fl_ZeroMusic_Timer[npc.index] = GetGameTime(npc.index) + 11.0;
			fl_ForceWrath[npc.index] = GetGameTime(npc.index) + 227.0;
			fl_MinionSummon[npc.index] = GetGameTime(npc.index) + 30.0;
			GiveNpcOutLineLastOrBoss(npc.index, true);
			CPrintToChatAll("{crimson}[WARNING] {yellow}Zerofuse is a slight passive {red}healer {yellow}be AWARE!!");
		}
		npc.m_bThisNpcIsABoss = true;
		npc.m_flJumpCooldown = GetGameTime(npc.index) + 15.0;
		
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerFirstUsage;
		b_RocketGunReady[npc.index] = false;
		b_RocketGunUsage[npc.index] = false;
		b_WrathRage[npc.index] = false;
		b_ForceWrath[npc.index] = false;
		b_AbilityManager[npc.index] = false;
		b_Lifeloss[npc.index] = false;//has the same thing as pablo if he lifelosses he gets stronger
		b_FakeUber[npc.index] = false;
		b_Stun[npc.index] = false;
		b_AbilityWrathRage[npc.index] = false;
		i_AoeHits[npc.index] = 0;
		i_DamageUntilRage[npc.index] = 0;
		npc.m_fbGunout = false;
		npc.Anger = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
	
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, TrueZerofuse_ClotDamaged_Post);
		SDKHook(npc.index, SDKHook_Think, TrueZerofuse_ClotThink);
		
		npc.m_iState = 0;
		npc.m_flSpeed = fl_MainSpeed;
		npc.m_flAttackHappenswillhappen = false;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntityRenderColor(npc.index, 1, 1, 1, 255);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/workshop/player/items/all_class/fall2013_hong_kong_cone/fall2013_hong_kong_cone_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable1, 1, 1, 1, 255);
		
		//npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl");
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_switchblade/c_switchblade.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/workshop_partner/weapons/c_models/c_dex_revolver/c_dex_revolver.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable3, 1, 1, 1, 255);
		
		npc.m_iWearable4 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/short2014_invisible_ishikawa/short2014_invisible_ishikawa.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable4, 1, 1, 1, 255);
		
		npc.m_iWearable5 = npc.EquipItem("partyhat", "models/workshop_partner/player/items/spy/shogun_ninjamask/shogun_ninjamask.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable5, 1, 1, 1, 255);
		
		npc.m_iWearable6 = npc.EquipItem("partyhat", "models/workshop/player/items/spy/spycrab/spycrab.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable6, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		
		return npc;
	}
}

//TODO 
//Rewrite
public void TrueZerofuse_ClotThink(int iNPC)
{
	TrueZerofuse npc = view_as<TrueZerofuse>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	if(!b_IsAlliedNpc[npc.index])//Don't allow the ally version to fuck over the round
	{
		if(RaidModeTime < GetGameTime())
		{
			fl_ForceWrath[npc.index] = gameTime + 40000.0;//if the map somehow gets replayed, this is more of a fix so he doesn't go on instant force wrath next time which he did on my test server
			b_RocketGunReady[npc.index] = false;
			b_RocketGunUsage[npc.index] = false;
			b_WrathRage[npc.index] = false;
			b_ForceWrath[npc.index] = false;
			b_AbilityWrathRage[npc.index] = false;
			b_AbilityManager[npc.index] = false;
			b_Lifeloss[npc.index] = false;
			b_FakeUber[npc.index] = false;
			b_Stun[npc.index] = false;
			//fl_ForceWrath[npc.index] = 4000.0;
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			Music_Stop_Zerofuse_Theme(iNPC);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, TrueZerofuse_ClotThink);
		}
		//Only works once do not remove this unless you have a better idea doing this
		if(RaidModeTime - GetGameTime() < 180.0 && b_FirstMessage[npc.index])
		{
			CPrintToChatAll("{red}[Warning] {yellow}Zerofuse mood has slightly lowered.");
			//taunts everyone
			b_FirstMessage[npc.index] = false;
			npc.PlayMoodOne();
		}
		if(RaidModeTime - GetGameTime() < 110.0 && b_SecondMessage[npc.index])
		{
			CPrintToChatAll("{red}[Warning] {yellow}Zerofuse mood has decreased in significant Amount.");
			//taunts everyone
			b_SecondMessage[npc.index] = false;
			npc.PlayMoodTwo();//such weakness
		}
		if(fl_ZeroMusic_Timer[npc.index] <= gameTime)
		{
			fl_ZeroMusic_Timer[npc.index] = gameTime + 343.0;
			//CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Masafumi Takada {default}- {orange}Mr. Monokuma After Class V3");//he uses 3 themes at once won't bother
			npc.PlayZeroMusic();//Embrace your doom
		}
		if(fl_ForceWrath[npc.index] <= gameTime && !b_ForceWrath[npc.index])
		{
			CPrintToChatAll("{crimson}[WARNING] {yellow}You've Awoken the Wrath of Zerofuse,{red} PREPARE TO BE EXTERMINATED.");
			//had enough
			npc.PlayMoodThree();//Your time has run out
			b_WrathRage[npc.index] = false;
			b_AbilityWrathRage[npc.index] = false;
			float vEnd[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
			spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 2.8, 4.0, 0.1, 1, 1.0);
			spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 2.95, 4.0, 0.1, 1, 1.0);
			fl_ForceWrath[npc.index] = gameTime + 3.0;
			b_ForceWrath[npc.index] = true;
			b_WrathRage[npc.index] = true;
			npc.m_flSpeed = 0.0;
			fl_Stun_Timer[npc.index] = gameTime + 0.1;
			b_Stun[npc.index] = true;
		}
		if(fl_MinionSummon[npc.index] <= gameTime)
		{
			int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
			float startPosition[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition);
			maxhealth /= 9;//if they are somehow weak do 6 or 7 if they are strong reduce it more
			for(int i; i<1; i++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
				int spawn_index = Npc_Create(SPY_MAIN_BOSS, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
				if(spawn_index > MaxClients)
				{
					Zombies_Currently_Still_Ongoing += 1;
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
				}
			}
			for(int j; j<1; j++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		
				int spawn_index = Npc_Create(MEDIVAL_SAMURAI, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
				if(spawn_index > MaxClients)
				{
					Zombies_Currently_Still_Ongoing += 1;
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
				}
			}
			CPrintToChatAll("{crimson}[WARNING] {yellow}Zerofuse summoned some of his Minion's!");
			fl_MinionSummon[npc.index] = gameTime + 60.0;
			npc.PlaySummonMinionSound();
		}
		///*
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client);
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		//*/
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		//npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	//Not the best stun anim but i don't want him to be constantly on stun anims then walk with stun anims either
	if(fl_Stun_Timer[npc.index] <= gameTime && b_Stun[npc.index] && b_WrathRage[npc.index] && b_ForceWrath[npc.index])
	{
		fl_Stun_Timer[npc.index] = gameTime + 1.05;
		npc.AddGesture("ACT_MP_STUN_MIDDLE");
	}
	if(fl_Stun_Timer[npc.index] <= gameTime && b_Stun[npc.index] && b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
	{
		fl_Stun_Timer[npc.index] = gameTime + 1.05;
		npc.AddGesture("ACT_MP_STUN_MIDDLE");
	}
	
	//if(fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index] && !b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
	if(fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index])//The above disables the ability on wrath usage use it if he goes too op
	{
		switch(GetRandomInt(1,2))
		{
			case 1:
			{
				fl_RocketGunTimer[npc.index] = gameTime + 0.5;
				b_RocketGunReady[npc.index] = true;
				npc.m_iAttacksTillReload = 5;
				npc.PlayBalanceSound();
			}
			case 2:
			{
				fl_DefenseHealing_Timer[npc.index] = gameTime + 0.4;
				fl_DefenseHealing_EndTimer[npc.index] = gameTime + 6.5;
				b_DefenseHealing[npc.index] = true;
				npc.PlayHealingSound();
			}
		}
		//npc.PlaySwitchSound();
		b_AbilityManager[npc.index] = true;
	}//Unneeded just gonna comment it out
	/*
	else if(fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index] && b_WrathRage[npc.index] && !b_ForceWrath[npc.index]
	|| fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index] && !b_WrathRage[npc.index] && b_ForceWrath[npc.index]
	|| fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index] && b_WrathRage[npc.index] && b_ForceWrath[npc.index])
	{
		fl_AbilityManager_Timer[npc.index] = gameTime + 5.0;
	}*/
	//if healing is active loop self healing X amount
	if(fl_DefenseHealing_Timer[npc.index] <= gameTime && b_DefenseHealing[npc.index])
	{
		fl_DefenseHealing_Timer[npc.index] = gameTime + 0.2;//52 times intotal yeah i am quite retarded... BUT i like the "slow" regen gain :)
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		if(b_HealingIsTooStrong)
		{
			//SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 500);
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 1300);
		}
		else
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 20000);
		}
	}
	if(fl_DefenseHealing_EndTimer[npc.index] <= gameTime && b_DefenseHealing[npc.index])
	{
		b_AbilityManager[npc.index] = false;
		b_DefenseHealing[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = gameTime + fl_AbilityManager_TimerSecondUsage;
	}
	if(fl_RocketGunTimer[npc.index] <= gameTime && b_RocketGunReady[npc.index] && !b_RocketGunUsage[npc.index])
	{
		fl_RocketGunTimer[npc.index] = gameTime + 3.2;
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Enable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		b_RocketGunUsage[npc.index] = true;
	}
	if(fl_RocketGunTimer[npc.index] <= gameTime && b_RocketGunReady[npc.index] && b_RocketGunUsage[npc.index])
	{
		b_RocketGunReady[npc.index] = false;
		b_RocketGunUsage[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = gameTime + fl_AbilityManager_TimerSecondUsage;
		b_AbilityManager[npc.index] = false;
		npc.m_iChanged_WalkCycle = 2;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
	}
	if(fl_ForceWrath[npc.index] <= gameTime && b_WrathRage[npc.index] && !b_AbilityWrathRage[npc.index] && b_ForceWrath[npc.index])
	{
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		Explode_Logic_Custom(750.0, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, 200.0, _, 0.8, true);
		npc.m_iChanged_WalkCycle = 2;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.AddGesture("ACT_MP_STUN_END");
		b_Stun[npc.index] = false;
		fl_ForceWrath[npc.index] = gameTime + 89.0;//it's 88s left anyway
		b_AbilityWrathRage[npc.index] = true;
		npc.m_flSpeed = fl_MainSpeed*1.25;//512 speed
		npc.m_flRangedArmor = 0.15;
		npc.m_flMeleeArmor = 0.25;
	}
	if(fl_ForceWrath[npc.index] <= gameTime && b_WrathRage[npc.index] && b_AbilityWrathRage[npc.index] && b_ForceWrath[npc.index])
	{
		i_DamageUntilRage[npc.index] = 0;
		b_WrathRage[npc.index] = false;
		b_AbilityWrathRage[npc.index] = false;
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.0;
	}
	if(fl_WrathRage[npc.index] <= gameTime && b_WrathRage[npc.index] && !b_AbilityWrathRage[npc.index] && !b_ForceWrath[npc.index])
	{
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		Explode_Logic_Custom(750.0, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, 200.0, _, 0.8, true);
		npc.m_iChanged_WalkCycle = 2;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.AddGesture("ACT_MP_STUN_END");
		b_Stun[npc.index] = false;
		fl_WrathRage[npc.index] = gameTime + 25.0;
		b_AbilityWrathRage[npc.index] = true;
		npc.m_flSpeed = fl_MainSpeed*1.25;//512 speed
		if(b_FakeUber[npc.index])
		{
			npc.m_flRangedArmor = 0.0;
			npc.m_flMeleeArmor = 0.0;
		}
		else
		{
			npc.m_flRangedArmor = 0.35;
			npc.m_flMeleeArmor = 0.35;
		}
	}
	if(fl_WrathRage[npc.index] <= gameTime && b_WrathRage[npc.index] && b_AbilityWrathRage[npc.index] && !b_ForceWrath[npc.index])
	{
		i_DamageUntilRage[npc.index] = 0;
		b_WrathRage[npc.index] = false;
		b_AbilityWrathRage[npc.index] = false;
		npc.m_flSpeed = fl_MainSpeed;
		if(b_FakeUber[npc.index])
		{
			npc.m_flRangedArmor = 0.0;
			npc.m_flMeleeArmor = 0.0;
		}
		else
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.0;
		}
	}
	if(fl_DisableFakeUber[npc.index] <= gameTime && b_FakeUber[npc.index] && b_Lifeloss[npc.index])
	{
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		b_FakeUber[npc.index] = false;
		if(b_WrathRage[npc.index])
		{
			npc.m_flRangedArmor = 0.35;
			npc.m_flMeleeArmor = 0.35;
		}
		else if(b_WrathRage[npc.index] && b_ForceWrath[npc.index])
		{
			npc.m_flRangedArmor = 0.15;
			npc.m_flMeleeArmor = 0.25;
		}
		else
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.0;
		}
	}
	if(i_AoeHits[npc.index] == i_UntilAoe+1)
	{
		i_AoeHits[npc.index] = 0;
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);	
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump < GetGameTime(npc.index) && flDistanceToTarget > 920000 && !b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex)
			{
				npc.m_flInJump = GetGameTime(npc.index) + 0.65;
				npc.m_flJumpCooldown = GetGameTime(npc.index) + 0.5;
			}
		}
		if(npc.m_flJumpCooldown < GetGameTime(npc.index) && npc.m_flInJump > GetGameTime(npc.index) && !b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
		{
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayJumpSound();
			npc.m_flJumpCooldown = GetGameTime(npc.index) + 30.0;
		}
		if(npc.m_flInJump > GetGameTime(npc.index) && !b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
		{
			//NPC_StopPathing(npc.index);
			//npc.m_bPathing = false;
			npc.FaceTowards(vecTarget, 10000.0);
			return;
		}
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			/*int color[4];
			color[0] = 255;
			color[1] = 255;
			color[2] = 0;
			color[3] = 255;
			
			int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
			TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
			TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 352000 && npc.m_flReloadDelay < GetGameTime(npc.index) && b_RocketGunUsage[npc.index] && !b_Stun[npc.index])
		{
			int target;
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				if(b_Lifeloss[npc.index])
				{
					vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1200.0);
				}
				else
				{
					vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 650.0);
				}
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				if(b_AbilityWrathRage[npc.index])//If he is in wrath buff ruins his main gimick then if it was the same speed
				{
					//npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.08;
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.1;
				}
				else
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.18;
				}
				//npc.m_iAttacksTillReload -= 1;
				
				float vecSpread = 0.1;
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				float x, y;
				x = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				y = GetRandomFloat( -0.15, 0.15 ) + GetRandomFloat( -0.15, 0.15 );
				
				float vecDirShooting[3], vecRight[3], vecUp[3];
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);
				vecDirShooting[1] = eyePitch[1];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				if(npc.m_iAttacksTillReload == 0)
				{
					npc.m_flReloadDelay = GetGameTime(npc.index) + 0.4;
					npc.m_iAttacksTillReload = 500;
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.PlayRangedReloadSound();
				}
				
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(b_Lifeloss[npc.index])
				{
					npc.FireRocket(vecTarget, 130.0, 1200.0);
				}
				else
				{
					npc.FireRocket(vecTarget, 90.0, 650.0);
				}
				npc.PlayRocketGunThrow();
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
			}
		}
		if(flDistanceToTarget < 62500 && !b_RocketGunUsage[npc.index] && !b_Stun[npc.index] || npc.m_flAttackHappenswillhappen && !b_RocketGunUsage[npc.index] && !b_Stun[npc.index])
		{
			npc.StartPathing();
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 2000.0);
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < 30000)
			{
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					
					if(b_AbilityWrathRage[npc.index])
					{
						npc.m_flAttackHappens = 0.00;
						npc.m_flAttackHappens_bullshit = gameTime + 0.01;
					}
					else if(!b_AbilityWrathRage[npc.index])
					{
						npc.m_flAttackHappens = gameTime + 0.1;
						npc.m_flAttackHappens_bullshit = gameTime + 0.21;
					}
					npc.m_flAttackHappenswillhappen = true;
				}
				if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, { 128.0, 128.0, 128.0 }, { -128.0, -128.0, -128.0 }))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(target <= MaxClients)
							{
								if(b_AbilityWrathRage[npc.index])
								{
									int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
									if(b_HealingIsTooStrongOnMelee)
									{
										SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 1400);//obviously not that low
									}
									else
									{
										SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 20000);
									}
									if(i_AoeHits[npc.index] == 3)
									{
										float pos[3];
										GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
										npc.PlayAoeSound();
										float damage = 70.0;
										float radius = 150.0;
										Explode_Logic_Custom(damage, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, radius, _, 0.8, true);
									}
									if(b_Lifeloss[npc.index])
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_LifelossDamage / 2, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage / 2, DMG_CLUB, -1, _, vecHit);
									}
									i_AoeHits[npc.index]++;
								}
								else
								{
									if(i_AoeHits[npc.index] == 3)
									{
										float pos[3];
										GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
										npc.PlayAoeSound();
										float damage = 90.0;
										float radius = 150.0;
										Explode_Logic_Custom(damage, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, radius, _, 0.8, true);
									}
									if(b_Lifeloss[npc.index])
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_LifelossDamage, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage, DMG_CLUB, -1, _, vecHit);
									}
									i_AoeHits[npc.index]++;
								}
								int Health = GetEntProp(target, Prop_Data, "m_iHealth");
								if(Health <= 0)
								{
									switch(GetRandomInt(1,3))
									{
										case 1:
										{
											npc.PlayKillPlayer();
										}
									}
								}
							}
							else
							{
								if(b_AbilityWrathRage[npc.index])
								{
									int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
									/*
									if(b_HealingIsTooStrongOnMelee[npc.index])//meh npcs can suffer
									{
										SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + 750);//obviously not that low
									}
									else
									{
										SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 20000);
									}*/
									
									SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 20000);
								}
								if(i_AoeHits[npc.index] == 3)
								{
									float pos[3];
									GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
									npc.PlayAoeSound();
									float damage = 140.0;
									float radius = 150.0;
									Explode_Logic_Custom(damage, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, radius, _, 0.8, true);
								}
								SDKHooks_TakeDamage(target, npc.index, npc.index, 9000.0, DMG_CLUB, -1, _, vecHit);
								i_AoeHits[npc.index]++;
							}
							//Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					if(b_AbilityWrathRage[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.01;
					}
					else if(!b_AbilityWrathRage[npc.index])
					{
						if(b_Lifeloss[npc.index])
						{
							npc.m_flNextMeleeAttack = gameTime + 0.23;
						}
						else
						{
							npc.m_flNextMeleeAttack = gameTime + 0.3;
						}
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(b_AbilityWrathRage[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.01;
					}
					else if(!b_AbilityWrathRage[npc.index])
					{
						if(b_Lifeloss[npc.index])
						{
							npc.m_flNextMeleeAttack = gameTime + 0.23;
						}
						else
						{
							npc.m_flNextMeleeAttack = gameTime + 0.3;
						}
					}
				}
			}
		}
		else
		{
			npc.StartPathing();
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Set_TrueZerofuse_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void TrueZerofuse_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	TrueZerofuse npc = view_as<TrueZerofuse>(iNPC);
	//zero is about to become even stronger
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( your mother
		b_FakeUber[npc.index] = true;
		b_Lifeloss[npc.index] = true;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 2);
		fl_DisableFakeUber[npc.index] = GetGameTime(npc.index) + 11.0;
		//npc.m_flSpeed = fl_MainSpeed;
		npc.m_flRangedArmor = 0.0;
		npc.m_flMeleeArmor = 0.0;
		npc.PlayLifelossSound();
	}
	int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	//SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 200000);
	if(!b_ForceWrath[npc.index])//If he somehow gonna disable this instantly if he uses forcewrath
	{
		i_DamageUntilRage[npc.index] += RoundFloat(damage);
	}
	if(i_DamageUntilRage[npc.index] >= MaxHealth/6 && !b_WrathRage[npc.index] && !b_ForceWrath[npc.index])
	{
		float vEnd[3];
		if(b_IsAlliedNpc[npc.index])
		{
			EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", EntRefToEntIndex(npc.index), _, _, _, 1.0);
		}
		else
		{
			npc.PlaySwitchSound();
		}
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 3.8, 4.0, 0.1, 1, 1.0);
		spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 3.95, 4.0, 0.1, 1, 1.0);
		fl_WrathRage[npc.index] = GetGameTime(npc.index) + 4.0;
		b_WrathRage[npc.index] = true;
		b_Stun[npc.index] = true;
		fl_Stun_Timer[npc.index] = GetGameTime(npc.index) + 0.4;
		npc.m_flRangedArmor = 0.0;
		npc.m_flMeleeArmor = 0.0;
		npc.m_flSpeed = 0.0;
		npc.AddGesture("ACT_MP_STUN_BEGIN");
		npc.AddGesture("ACT_MP_STUN_LOOP");
		//EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", _, _, _, _, 1.0);
		//EmitSoundToAll("zombie_riot/zerofuse/offensive_rage2.mp3", _, _, _, _, 1.0);
	}
	else if(i_DamageUntilRage[npc.index] >= MaxHealth/6)
	{
		i_DamageUntilRage[npc.index] = MaxHealth/6;
	}
}

public Action TrueZerofuse_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	TrueZerofuse npc = view_as<TrueZerofuse>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void TrueZerofuse_NPCDeath(int entity)
{
	TrueZerofuse npc = view_as<TrueZerofuse>(entity);
	
	npc.PlayDeathSound();
	if(!b_IsAlliedNpc[npc.index])//ally shouldn't kill the music if the original pablo is there still nor killing the raid index either
	{
		Music_Stop_Zerofuse_Theme(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, TrueZerofuse_ClotDamaged_Post);
	SDKUnhook(npc.index, SDKHook_Think, TrueZerofuse_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}

void Music_Stop_Zerofuse_Theme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombie_riot/zerofuse/bgm1.mp3");
	//StopSound(entity, SNDCHAN_STATIC, "#zombie_riot/zerofuse/bgm1.mp3");
	//StopSound(entity, SNDCHAN_STATIC, "#zombie_riot/zerofuse/bgm1.mp3");
}