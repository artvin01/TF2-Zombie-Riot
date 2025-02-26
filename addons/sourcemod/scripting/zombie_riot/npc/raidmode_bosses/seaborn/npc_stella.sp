#pragma semicolon 1
#pragma newdecls required

/*

Stella:

Move the NC lines into the new format.

Silence:
Very slightly reduces range of normal attack, its turn speed. its "Alpha" (brightness) is lowered to show its weakened state.
Very slightly reduces the turn speed of Nightmare cannon, and its radius. its "Alpha" (brightness) is lowered to show its weakened state.

NC Core:
Make it so, Stella can shoot her NC into karlas and he reflects it. (Done)

For the NC relfection logic: (Done)
First, is karlas in line of sight of stella?
no?: abort.
yes:
Keep on checking which of the 2 npc's can see more targets from their positions, if karlas can see more, move NC onto karlas and have him reflect it, if stella can see more, buisness as usual

If Karlas is close to stella, and there are multiple people near stella, Karlas allows stella to "retreat" teleport like Twirl. (?)

Lunar Flare: (Done-?)
Stella goes into an animation
(What if she also went into the sky? like silvester)
Seconds later a circle appears infront of stella.
Within this circle death happens (projectile like effects?)
This circle then starts to move towards a random target. that stella can see, while active stella always looks at this circle.
All thats left is the sounds / effects where the circle is.

BIG ISSUE: for some god knows why reason, stella's NC cannot turn, on the update frame it *attempts* to turn, but then it rubber bands back to the same direction it was facing.
I am at a loss as to WHY THE FUCK its doing that???????????????????????
I think I fixed it? maybe? its not bugged out ever since I did a few changes?

Karlas:
Silence:
Reduces the proj speed of the slicers by 5%
Reduces the firerate speed of the slicers by 5%

While cannon is being shot at him, his move speed is reduced by 0.0 and his turn speed is reduced by 20%. in addition uses the same targeting logic stella will have. (Done)
Look into replacing his Lance with the model version. (Done)
When Stella dies, Karlas gains his current blades. abit modified tho. mainly visual / trace (Done)

Barrage: Karlas fires off 3 or less, depending on how many people there are within his line of sight forwards, slicers.
Fires several of them, cannot move, gets resistances during it. (Done)

Misc:
Karlas Final Touches: 
Sounds for the barrage. (Done)
Give him actual wings. (Done!)


Wave 60 Notes:

Give Stella a really flashy ability.
Spiral laser crystals?


Give Karlas smth?

*/

static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];

static const char g_nightmare_cannon_core_sound[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3",
};

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};
static const char g_LaserAttackSounds[][] = {
	"weapons/physcannon/energy_sing_flyby1.wav",
	"weapons/physcannon/energy_sing_flyby2.wav",
};
static const char g_LaserChargesounds [][] = {
	"npc/sniper/reload1.wav"
};
static const char g_OnLunarGraceHitSounds[][] = {
	"weapons/airboat/airboat_gun_energy1.wav",
	"weapons/airboat/airboat_gun_energy2.wav",
};

static int i_particle_effects[MAXENTITIES][3];
static int i_wingslot[MAXENTITIES];

#define STELLA_TE_DURATION 0.07

static char gExplosive1;
static int i_ally_index[MAXENTITIES];
static bool b_InKame[MAXENTITIES];
static bool b_tripple_raid[MAXENTITIES];

#define STELLA_NC_DURATION 23.0
#define STELLA_NC_TURNRATE 300.0	//max turnrate.
#define STELLA_NC_TURNRATE_ANGER 400.0
#define STELLA_KARLAS_THEME "#zombiesurvival/seaborn/donner_schwert_5.mp3"

#define STELLA_NORMAL_LASER_DURATION 0.7

static float fl_npc_basespeed;
static bool b_test_mode[MAXENTITIES];
static int i_current_wave[MAXENTITIES];
static bool b_bobwave[MAXENTITIES];
static bool b_IonStormInitiated[MAXENTITIES];
static bool b_LastMannLines[MAXENTITIES];
static bool b_NormLaserOnly[MAXENTITIES];
static float fl_TurnBackUp[MAXENTITIES];

static const char NameColour[] = "{aqua}";
static const char TextColour[] = "{snow}";

static char gGlow1;	//blue

static bool b_said_player_weaponline[MAXTF2PLAYERS];
static float fl_said_player_weaponline_time[MAXENTITIES];

void Stella_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_nightmare_cannon_core_sound));   i++) { PrecacheSoundCustom(g_nightmare_cannon_core_sound[i]);	}	//need it to be precached since its used elsewhere
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Stella");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_stella");
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "donner"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;	
	data.Precache = ClotPrecache;									//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}

static void ClotPrecache()
{
	Zero(fl_nightmare_cannon_core_sound_timer);

	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);

	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_LaserAttackSounds);
	PrecacheSoundArray(g_LaserChargesounds);
	PrecacheSoundArray(g_OnLunarGraceHitSounds);

	PrecacheSound(BLITZLIGHT_ATTACK, true);
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav", true);
	PrecacheSound("mvm/mvm_tank_ping.wav", true);
	PrecacheSound("mvm/mvm_tele_deliver.wav", true);
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav", true);
	PrecacheSound("misc/halloween/gotohell.wav", true);
	PrecacheSound("vo/medic_sf13_influx_big02.mp3", true);
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	PrecacheSound("misc/halloween/spell_mirv_explode_primary.wav", true);
	PrecacheSound("ambient/energy/whiteflash.wav", true);
	PrecacheSoundCustom(STELLA_KARLAS_THEME);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Stella(vecPos, vecAng, team, data);
}

methodmap Stella < CClotBody
{
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	public void PlayNightmareSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime())
			return;

		EmitCustomToAll(g_nightmare_cannon_core_sound[GetRandomInt(0, sizeof(g_nightmare_cannon_core_sound) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime() + 2.25;
	}

	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound= GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void PlayLaserAttackSound() {
		EmitSoundToAll(g_LaserAttackSounds[GetRandomInt(0, sizeof(g_LaserAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayLaserChargeSound() {
		EmitSoundToAll(g_LaserChargesounds[GetRandomInt(0, sizeof(g_LaserChargesounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_Throttle
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
	}
	property float m_flNorm_Attack_In
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flNC_Recharge
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flNC_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flNC_Grace
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flLunar_Grace_CD
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flLunar_Grace_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flNCspecialTargetTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][9]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][9] = TempValueForProperty; }
	}
	property int m_iNC_Dialogue
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}
	property bool m_bMovingTowardsKarlas
	{
		public get()							{ return this.m_flHalf_Life_Regen; }
		public set(bool TempValueForProperty) 	{ this.m_flHalf_Life_Regen = TempValueForProperty; }
	}
	property float m_flNC_LockedOn
	{
		public get()		 
		{ 
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				return fl_AbilityOrAttack[npc.index][9];
			}
			return 0.0;
		}
		public set(float value) 
		{
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				fl_AbilityOrAttack[npc.index][9] = value;
			}
		}
	}
	property bool m_bSaidWinLine
	{
		public get()							{ return this.m_fbGunout; }
		public set(bool TempValueForProperty) 	{ this.m_fbGunout = TempValueForProperty; }
	}
	property bool m_bKarlasRetreat
	{
		public get()		 
		{ 
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				return npc.m_fbGunout;
			}
			return false;
		}
		public set(bool value) 
		{
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				npc.m_fbGunout = value;
			}
		}
	}
	/*
		0 - No cannon.
		1 - Cannon is directly on karlas.
		2 - 
	*/
	property int m_iKarlasNCState
	{
		public get()		 
		{ 
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				return i_MedkitAnnoyance[npc.index];
			}
			return 0;
		}
		public set(int iInt) 
		{
			if(IsValidAlly(this.index, this.Ally))
			{
				Karlas npc = view_as<Karlas>(this.Ally);
				i_MedkitAnnoyance[npc.index] = iInt;
			}
		}
	}
	property int Ally
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_ally_index[this.index]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_ally_index[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_ally_index[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iParticles1
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_particle_effects[this.index][0]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_particle_effects[this.index][0] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_particle_effects[this.index][0] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iParticles2
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_particle_effects[this.index][1]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_particle_effects[this.index][1] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_particle_effects[this.index][1] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iParticles3
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_particle_effects[this.index][2]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_particle_effects[this.index][2] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_particle_effects[this.index][2] = EntIndexToEntRef(iInt);
			}
		}
	}
	property int m_iWingSlot
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_wingslot[this.index]);
			if(returnint == -1)
			{
				return 0;
			}

			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_wingslot[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_wingslot[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	public void SetCrestState(bool activate)
	{
		if(IsValidEntity(this.m_iWearable8))
			RemoveEntity(this.m_iWearable8);
		else if(!activate)
			return;
		//deactivate the crest
		if(!activate)
		{
			return;
		}

		this.m_iWearable8 = this.EquipItem("head", RUINA_CUSTOM_MODELS_4);
		SetVariantInt(RUINA_STELLA_CREST);
		AcceptEntityInput(this.m_iWearable8, "SetBodyGroup");
	}
	public void Spawn_Karlas()
	{
		if(!IsValidEntity(this.index))
			return;

		float pos[3]; GetEntPropVector(this.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(this.index, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(this.index, Prop_Data, "m_iHealth");
		
		maxhealth = RoundToFloor(maxhealth*1.5);

		int spawn_index = NPC_CreateByName("npc_karlas", this.index, pos, ang, GetTeam(this.index));
		if(spawn_index > MaxClients)
		{
			this.Ally = spawn_index;
			Set_Karlas_Ally(spawn_index, this.index, i_current_wave[this.index], b_bobwave[this.index], b_tripple_raid[this.index]);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			fl_Extra_Damage[spawn_index] = fl_Extra_Damage[this.index];
			fl_Extra_Speed[spawn_index] = fl_Extra_Speed[this.index];
		}
	}

	public char[] GetName()
	{
		char Name[255];
		Format(Name, sizeof(Name), "%s%s%s:", NameColour, c_NpcName[this.index], TextColour);
		return Name;
	}

	public void NC_StartupSound()
	{
		EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");

		EmitSoundToAll("ambient/energy/whiteflash.wav", _, _, _, _, 1.0);
		EmitSoundToAll("ambient/energy/whiteflash.wav", _, _, _, _, 1.0);

		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);
				EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);			
			}
			case 2:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
				EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
			}
			case 3:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);	
				EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);			
			}
			case 4:
			{
				EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
				EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
			}		
		}
	}
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.m_bisWalking = true;
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	public void Set_Crest_Charging_Phase(bool activate)
	{
		if(IsValidEntity(this.m_iWearable9))
			RemoveEntity(this.m_iWearable9);
		else if(!activate)
			return;
		//deactivate the crest
		if(!activate)
		{
			this.Set_Particle("raygun_projectile_blue_crit", "effect_hand_r");
			return;
		}

		this.Set_Particle("raygun_projectile_red_crit", "effect_hand_r");	//temp,

		this.m_iWearable9 = this.EquipItem("head", RUINA_CUSTOM_MODELS_4);
		SetVariantInt(RUINA_STELLA_CREST_CHARGING);
		AcceptEntityInput(this.m_iWearable9, "SetBodyGroup");
	}
	public void Set_Particle(char[] Particle, char[] Attachment, int index = 0)
	{
		

		float flPos[3], flAng[3];

		this.GetAttachment(Attachment, flPos, flAng);

		int particle = ParticleEffectAt_Parent(flPos, Particle, this.index, Attachment, {0.0,0.0,0.0});

		switch(index)
		{
			case 0: 
			{
				if(IsValidEntity(this.m_iParticles1))
					RemoveEntity(this.m_iParticles1);
				this.m_iParticles1 = particle;
			}
			case 1: 
			{
				if(IsValidEntity(this.m_iParticles2))
					RemoveEntity(this.m_iParticles2);
				this.m_iParticles2 = particle;
			}
			case 2: 
			{
				if(IsValidEntity(this.m_iParticles3))
					RemoveEntity(this.m_iParticles3);
				this.m_iParticles3 = particle;
			}
			default: 
			{
				//failsafe.
				CPrintToChatAll("INVALID PARTICLE INDEX FOR STELLA: %i", index);
				if(IsValidEntity(index))
					RemoveEntity(index);
			}
		}
		
	}
	property float m_flStellaMeleeArmour
	{
		public get()		 
		{ 
			return this.m_flMeleeArmor;
		}
		public set(float fAmt) 
		{
			float GameTime = GetGameTime(this.index);
			//we are casting Lunar Grace and also can't move, take a heavily defensive position.	
			if(this.m_flLunar_Grace_Duration > GameTime)
				fAmt -=0.7;

			if(this.m_flNC_Duration > GameTime)
				fAmt -=0.95;

			if(this.Anger)
				fAmt -=0.25;
		

			//hard limit, although unlikely to be hit.
			if(fAmt < 0.05)
				fAmt = 0.05;	

			this.m_flMeleeArmor = fAmt;
		}
	}
	property float m_flStellaRangedArmour
	{
		public get()		 
		{ 
			return this.m_flRangedArmor;
		}
		public set(float fAmt) 
		{
			float GameTime = GetGameTime(this.index);
			//we are casting Lunar Grace and also can't move, take a heavily defensive position.	
			if(this.m_flLunar_Grace_Duration > GameTime)
				fAmt -=0.7;
			
			if(this.m_flNC_Duration > GameTime)
				fAmt -=0.7;

			if(this.Anger)
				fAmt -=0.25;


			//hard limit, although unlikely to be hit.
			if(fAmt < 0.05)
				fAmt = 0.05;	
			

			this.m_flRangedArmor = fAmt;
		}
	}
	public Stella(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Stella npc = view_as<Stella>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));

		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		c_NpcName[npc.index] = "Stella";

		//data: test , force15, force30, force45, force60, hell, solo, triple_enemies, nomusic, anger, twirl, bob, normonly

		b_test_mode[npc.index] = StrContains(data, "test") != -1;

		int wave = Waves_GetRound()+1;

		if(StrContains(data, "force15") != -1)
			wave = 15;
		else if(StrContains(data, "force30") != -1)
			wave = 30;
		else if(StrContains(data, "force45") != -1)
			wave = 45;
		else if(StrContains(data, "force60") != -1)
			wave = 60;
		else if(StrContains(data, "hell") != -1)
			wave = -1;

		b_NormLaserOnly[npc.index] = (StrContains(data, "normonly") != -1);

		npc.m_bSaidWinLine = false;
		b_bobwave[npc.index] = false;
		if(StrContains(data, "bob") != -1)
			b_bobwave[npc.index] = true;

		//idk
		if(wave == -1)
		{
			wave = 60 + Waves_GetRound();
		}
		i_current_wave[npc.index] = wave;
		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iChanged_WalkCycle = 1;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		TwirlEarsApply(npc.index,_,0.75);

		if(!IsValidEntity(RaidBossActive))
			RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;
		
		RaidModeTime = GetGameTime() + 250.0;
		
	
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(wave);
		}

		if(RaidModeScaling < 55)
			RaidModeScaling *= 0.19;
		else
			RaidModeScaling *= 0.38;

		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		if(amount_of_people > 12.0)
			amount_of_people = 12.0;

		amount_of_people *= 0.12;

		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people;
			
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Donnerkrieg And Schwertkrieg Spawn");
			}
		}
		RemoveAllDamageAddition();
		Citizen_MiniBossSpawn();
		
		b_tripple_raid[npc.index] = (StrContains(data, "triple_enemies") != -1);

		bool default_theme = true;

		if(b_tripple_raid[npc.index])
			default_theme = false;

		if((StrContains(data, "nomusic") != -1))
			default_theme = false;

		if(!b_tripple_raid[npc.index] && (StrContains(data, "twirl") != -1))
		{
			default_theme = false;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), RAIDBOSS_TWIRL_THEME);
			music.Time = 285;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Solar Sect of Mystic Wisdom ~ Nuclear Fusion");
			strcopy(music.Artist, sizeof(music.Artist), "maritumix/まりつみ");
			Music_SetRaidMusic(music);	
		}

		if(default_theme)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), STELLA_KARLAS_THEME);
			music.Time = 290;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Arknights - Martyr/Guiding Ahead Boss");
			strcopy(music.Artist, sizeof(music.Artist), "HyperGryph");
			Music_SetRaidMusic(music);
		}
		
		b_thisNpcIsARaid[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		func_NPCFuncWin[npc.index] = Win_Line;
			
		
		/*
			breakneck baggies	"models/workshop/player/items/all_class/jogon/jogon_medic.mdl"
			colone's coat		"models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl"
			crone's dome		"models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl"
			flatliner			"models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl"
			lo-grav loafers		"models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl"
			nunhood				"models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl"
			puffed practitioner	"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl"

		*/
		//IDLE
		fl_npc_basespeed = 300.0;
		npc.m_flSpeed = fl_npc_basespeed;

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/medic/sum20_flatliner/sum20_flatliner.mdl", _, skin);
		npc.m_iWearable8 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_4);
		//9 is used by a special item.
		npc.m_iWingSlot =  npc.EquipItem("head", WINGS_MODELS_1);

		SetVariantInt(RUINA_STELLA_CREST);
		AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");
		SetVariantInt(WINGS_STELLA);
		AcceptEntityInput(npc.m_iWingSlot, "SetBodyGroup");

		npc.Set_Particle("raygun_projectile_blue_crit", "effect_hand_r");

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		npc.StartPathing();
		float GameTime = GetGameTime(npc.index);
				
		npc.m_flNC_Recharge = GameTime + GetRandomFloat(10.0, 30.0);
		npc.m_iNC_Dialogue = 0;
		npc.m_bMovingTowardsKarlas = false;
		npc.m_flNCspecialTargetTimer = 0.0;
		npc.m_flNC_Grace = 0.0;
		npc.m_bInKame = false;
		fl_TurnBackUp[npc.index] = FAR_FUTURE;

		npc.m_flLunar_Grace_CD = GetGameTime() + GetRandomFloat(45.0, 75.0);

		npc.m_flNextRangedAttack = GetGameTime() + 1.0;
		npc.m_flNorm_Attack_In = 0.0;

		if(!b_test_mode[npc.index])
			EmitSoundToAll("mvm/mvm_tele_deliver.wav");

		npc.Anger = false;
		
		if(!(StrContains(data, "solo") != -1))
			RequestFrame(Do_OnSpawn, EntIndexToEntRef(npc.index));

		if((StrContains(data, "anger") != -1))
			npc.Anger = true;

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 999, 999);	

		npc.m_flDoingAnimation = 0.0;

		npc.m_flStellaMeleeArmour = 1.25;
		npc.m_flStellaRangedArmour = 1.0;

		if(b_test_mode[npc.index])
			RaidModeTime = FAR_FUTURE;
		
		if(!b_bobwave[npc.index] && !b_tripple_raid[npc.index])
		{
			switch(GetRandomInt(0, 6))
			{
				case 0: Stella_Lines(npc, "Luckily {purple}Twirl{snow} wasn't the one who found you first. For us that is, not you");
				case 1: Stella_Lines(npc, "Man this place is horrid, can't wait to get this job done as soon as possible");
				case 2: Stella_Lines(npc, "Hey {crimson}Karlas{snow}, enough \"chit chat\" it's time to work");
				case 3: Stella_Lines(npc, "We have arrived to render Judgement");
				case 4: Stella_Lines(npc, "I'm in a good mood, so I'll just let you know, if you take too long, this area will soon become ground zero, good luck.");
				case 5: Stella_Lines(npc, "All we have to do is keep them occupied long enough for the ones above to start glassing the area...");
				case 6: Stella_Lines(npc, "We have arrived to eradicate you");
			}
			
		}
		Zero(b_said_player_weaponline);
		b_IonStormInitiated[npc.index] = false;
		b_LastMannLines[npc.index] = false;
		return npc;
	}
}
static void PlayLunarGraceHitSound(int target) {
	EmitSoundToAll(g_OnLunarGraceHitSounds[GetRandomInt(0, sizeof(g_OnLunarGraceHitSounds) - 1)], target, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME*0.5);
}
static void Do_OnSpawn(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		Stella npc = view_as<Stella>(entity);
		npc.Spawn_Karlas();
	}
}

static void Win_Line(int entity)
{	
	Stella npc = view_as<Stella>(entity);

	if(npc.m_bSaidWinLine)
		return;

	npc.m_bSaidWinLine = true;

	if(npc.Ally)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0: Stella_Lines(npc, "Huh, they're all dead, guess they were easier to stop then I expected...");
			case 1: Stella_Lines(npc, "HAH, the {darkblue}sea{snow} isn't THAT hard to beat");
			case 2: Stella_Lines(npc, "Oh boy, their ragdoll's were {gold}amazing{snow}!");
		}
	}
	else
	{
		switch(GetRandomInt(0, 1))
		{
			case 0: Stella_Lines(npc, "You killed {crimson}Karlas{snow}, and I {crimson}erased{snow} your existance");
			case 1: Stella_Lines(npc, "Well, atleast I still have {purple}Twirl{snow}...");
		}
	}
}
static Action OffsetLoseTimer(Handle Timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[entity]=INVALID_FUNCTION;
		b_NpcIsInvulnerable[entity] = false;
		Stella npc = view_as<Stella>(entity);
		if(npc.Ally)
		{
			func_NPCThink[npc.Ally]=INVALID_FUNCTION;
			b_NpcIsInvulnerable[npc.Ally] = false;
		}
		
	}
	EmitSoundToAll("misc/halloween/spell_mirv_explode_primary.wav", _, _, 120, _, _, GetRandomInt(80, 110));
	EmitSoundToAll("misc/halloween/spell_mirv_explode_primary.wav", _, _, 120, _, _, GetRandomInt(80, 110));
	EmitSoundToAll("misc/halloween/spell_mirv_explode_primary.wav", _, _, 120, _, _, GetRandomInt(80, 110));
	ForcePlayerLoss();
	return Plugin_Stop;
}
static void Internal_ClotThink(int iNPC)
{
	Stella npc = view_as<Stella>(iNPC);

	if(RaidModeTime < GetGameTime() && !b_IonStormInitiated[npc.index])
	{
		if(!npc.m_bSaidWinLine)
		{
			npc.m_bSaidWinLine = true;
			switch(GetRandomInt(0,3))
			{
				case 0: Stella_Lines(npc, "You lose!");
				case 1: Stella_Lines(npc, "Too late!");
				case 2: Stella_Lines(npc, "Times UP!");
				case 3: Stella_Lines(npc, "Atleast you survived this long, now its time for it all to end...");
			}
			Stella_Lines(npc, "You have around 5 seconds until everything gets completely nuked by Ruina's ION barrage, good luck");
			Ruina_Ion_Storm(npc.index);	//This is very stupid, I love it.
		}
		CreateTimer(5.0, OffsetLoseTimer, EntIndexToEntRef(npc.index),TIMER_FLAG_NO_MAPCHANGE);

		EmitSoundToAll(BLITZLIGHT_ATTACK);
		b_IonStormInitiated[npc.index] = true;
		b_NpcIsInvulnerable[npc.index] = true;
		if(npc.Ally)
			b_NpcIsInvulnerable[npc.Ally] = true;
	}

	
	if(LastMann)
	{
		if(!b_LastMannLines[npc.index] )
		{
			b_LastMannLines[npc.index] = true;
			if(npc.Ally)
			{
				switch(GetRandomInt(0,1))
				{
					case 0:Stella_Lines(npc, "We'd better not choke now...");
					case 1:Stella_Lines(npc, "Ahaha, its almost over now, just{crimson} one more left{snow}!");
				}
			}
			else
			{
				Stella_Lines(npc, "I'm about to turn you into an unrecognisable mass of sea for {crimson}what you've DONE TO KARLAS");
			}
		}
	}
		
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	npc.m_flStellaMeleeArmour = 1.25;
	npc.m_flStellaRangedArmour = 1.0;
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

	if(npc.m_flGetClosestTargetTime < GameTime && npc.m_flLunar_Grace_Duration < GameTime)
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = i_Get_Laser_Target(npc);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 0.2;
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
	}
	int wave = i_current_wave[npc.index];
	if(npc.m_bInKame)
	{
		Handle_NC_TurnSpeed(npc);
		npc.m_flSpeed = 0.0;
		//CPrintToChatAll("return 2");
		return;
	}
	else if(npc.m_flLunar_Grace_Duration > GameTime)
	{
		Lunar_Body_Pitch(npc);
	}
		

	if(npc.m_flDoingAnimation > GameTime)
	{
		//CPrintToChatAll("return 1");
		npc.m_flSpeed = 0.0;
		return;
	}

	if(wave > 30)	//beyond wave 30.
		if(Lunar_Grace(npc))
			return;

	int PrimaryThreatIndex = npc.m_iTarget;
	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	npc.AdjustWalkCycle();
	npc.StartPathing();
	npc.m_bPathing = true;
	npc.PlayIdleAlertSound();
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		return;
	}
	
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	Body_Pitch(npc, VecSelfNpc, vecTarget);

	bool backing_up = KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex,((npc.m_iNC_Dialogue != 0) ? GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 50.0 : GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5));
	
	//if((npc.m_iNC_Dialogue != 0) && !BlockTurn(npc))
	//	npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);

	if(flDistanceToTarget < ( (npc.m_iNC_Dialogue != 0) ? GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 55.0 : GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
		npc.m_bAllowBackWalking = true;
		if(!BlockTurn(npc))
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}

	Self_Defense(npc, flDistanceToTarget);

	if(npc.m_bAllowBackWalking && backing_up)
	{
		npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
		if(!BlockTurn(npc))
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}

	if(Stella_Nightmare_Logic(npc, PrimaryThreatIndex, vecTarget))
		return;
}
static void Ruina_Ion_Storm(int entity)
{
	for(int y=0 ; y < GetRandomInt(2, 4) ; y++)
	{
		for(int i=1 ; i <= MaxClients ; i++)
		{
			if(!IsValidClient(i) || TeutonType[i] != TEUTON_NONE)
				continue;
			DataPack pack;
			CreateDataTimer(GetRandomFloat(0.0, 1.0)*y+0.25, IonStorm_OffsetTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(i));
			pack.WriteCell(EntIndexToEntRef(entity));
		}
	}
	
}
Action IonStorm_OffsetTimer(Handle Timer, DataPack data)
{
	data.Reset();
	int target = EntRefToEntIndex(data.ReadCell());
	int iNPC = EntRefToEntIndex(data.ReadCell());

	if(!IsValidEntity(target) || !IsValidEntity(iNPC))
		return Plugin_Stop;

	float Predicted_Pos[3]; WorldSpaceCenter(target, Predicted_Pos);

	Predicted_Pos[0] +=GetRandomFloat(-100.0, 100.0);
	Predicted_Pos[1] +=GetRandomFloat(-100.0, 100.0);

	float Radius = 300.0;
	float Time = 4.5;

	int color[4]; 
	color = {255,255,255,255};

	float Thickness = 15.0;
	TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
	TE_SendToAll();
	TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.1, color, 1, 0);
	TE_SendToAll();

	EmitSoundToAll(RUINA_ION_CANNON_SOUND_SPAWN, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, Predicted_Pos);
	DataPack pack;
	CreateDataTimer(Time, Ruina_Generic_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iNPC));
	pack.WriteFloatArray(Predicted_Pos, sizeof(Predicted_Pos));
	pack.WriteCellArray(color, sizeof(color));
	pack.WriteFloat(Radius);
	pack.WriteFloat(9000.0);
	pack.WriteFloat(1.0);			//Sickness %
	pack.WriteCell(1000);			//Sickness flat
	pack.WriteCell(true);		//Override sickness timeout

	float Sky_Loc[3]; Sky_Loc = Predicted_Pos; Sky_Loc[2]+=500.0; Predicted_Pos[2]-=100.0;

	if(!AtEdictLimit(EDICT_NPC))
	{
		int laser;
		laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], Thickness*2.0, Thickness*2.0, 0.5, BEAM_COMBINE_BLACK, Predicted_Pos, Sky_Loc);

		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}
	int loop_for = 5;
	float Add_Height = 500.0/loop_for;
	for(int i=0 ; i < loop_for ; i++)
	{
		Predicted_Pos[2]+=Add_Height;
		TE_SetupBeamRingPoint(Predicted_Pos, (Radius*2.0)/(i+1), 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
		TE_SendToAll();
	}

	return Plugin_Stop;
}
enum struct Lunar_Grace_Data
{
	float Throttle;
	float Loc[3];
	bool AnimSet;
}
static float fl_lunar_radius = 150.0;
static Lunar_Grace_Data struct_Lunar_Grace_Data[MAXENTITIES];
static void Lunar_Body_Pitch(Stella npc)
{
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float vecTarget[3]; vecTarget = struct_Lunar_Grace_Data[npc.index].Loc;
	Body_Pitch(npc, VecSelfNpc, vecTarget);
}
static bool Lunar_Grace(Stella npc)
{
	if(b_NormLaserOnly[npc.index])
		return false;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flLunar_Grace_CD > GameTime)
		return false;

	if(Nearby_Players(npc, 9000.0) <= 0)
		return false;
	
	npc.m_bKarlasRetreat = true;
	npc.m_iTarget = -1;
	float Duration = 12.5;

	npc.SetCrestState(false);
	npc.Set_Crest_Charging_Phase(false);

	npc.m_bAllowBackWalking = true;

	npc.m_flLunar_Grace_CD = GameTime + (npc.Anger ? 50.0 : 75.0) + Duration;

	npc.m_flDoingAnimation = GameTime + Duration + 0.5;

	npc.m_flLunar_Grace_Duration = GameTime + Duration;
	
	SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);
	SDKUnhook(npc.index, SDKHook_Think, Lunar_Grace_Tick);
	SDKHook(npc.index, SDKHook_Think, Lunar_Grace_Tick);

	npc.AddActivityViaSequence("secondrate_sorcery_medic");
	npc.SetPlaybackRate(1.0);	
	npc.SetCycle(0.0);

	//66.6 is ideal 
	//154
	//0.432 cycle

	npc.m_bisWalking = false;

	npc.m_flSpeed = 0.0;

	float Windup = 1.0;

	struct_Lunar_Grace_Data[npc.index].Throttle = GameTime + Windup;
	struct_Lunar_Grace_Data[npc.index].AnimSet = false;

	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float Angles[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	//we don't actually want pitch cause it might screw up some stuff.
	Laser.DoForwardTrace_Custom(Angles, VecSelfNpc, 200.0);
	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Laser.End_Point);
	struct_Lunar_Grace_Data[npc.index].Loc = Laser.End_Point;
	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
	TE_SetupBeamRingPoint(Laser.End_Point, fl_lunar_radius*2.0, fl_lunar_radius*2.0 + 0.5, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, Windup, 15.0, 0.1, color, 1, 0);
	TE_SendToAll();

	return true;
	
}
static Action Lunar_Grace_Tick(int iNPC)
{
	Stella npc = view_as<Stella>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flLunar_Grace_Duration < GameTime)
	{
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_bisWalking = true;

		npc.SetCrestState(true);

		npc.m_bAllowBackWalking = false;
		npc.m_bKarlasRetreat = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		SDKUnhook(npc.index, SDKHook_Think, Lunar_Grace_Tick);
		return Plugin_Stop;
	}

	bool Update = false;
	if(struct_Lunar_Grace_Data[npc.index].Throttle < GameTime)
	{
		if(!struct_Lunar_Grace_Data[npc.index].AnimSet)
		{
			struct_Lunar_Grace_Data[npc.index].AnimSet = true;
			npc.SetCycle(0.432);
			npc.SetPlaybackRate(0.0);
		}
		
		struct_Lunar_Grace_Data[npc.index].Throttle = GameTime + 0.1;
		Update = true;

		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.25);
	}

	int color[4]; Ruina_Color(color, i_current_wave[npc.index]);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);

	TE_SetupBeamRingPoint(struct_Lunar_Grace_Data[npc.index].Loc, fl_lunar_radius*2.0, fl_lunar_radius*2.0+0.5, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, STELLA_TE_DURATION, 7.0, 0.1, color, 1, 0);
	TE_SendToAll();

	float flPos[3];
	npc.GetAttachment("effect_hand_r", flPos, NULL_VECTOR);
	float Angles_special[3];
	MakeVectorFromPoints(VecSelfNpc, struct_Lunar_Grace_Data[npc.index].Loc, Angles_special);
	GetVectorAngles(Angles_special, Angles_special);
	float Dist = GetVectorDistance(struct_Lunar_Grace_Data[npc.index].Loc, VecSelfNpc) - fl_lunar_radius;
	float BeamEndLoc[3];
	Get_Fake_Forward_Vec(Dist, Angles_special, BeamEndLoc, VecSelfNpc);
	BeamEndLoc[2]-=2.5;
	//PrintCenterTextAll("vec : %.1f %.1f %.1f", BeamEndLoc[0], BeamEndLoc[1], BeamEndLoc[2]);
	TE_SetupBeamPoints(flPos, BeamEndLoc, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 0, STELLA_TE_DURATION, 10.0, 10.0, 0, 5.0, color, 3);
	TE_SendToAll();

	npc.GetAttachment("effect_hand_l", flPos, NULL_VECTOR);
	flPos[2]+=4.0;
	TE_SetupGlowSprite(flPos, gGlow1, STELLA_TE_DURATION, 0.65, 255);
	TE_SendToAll();

	if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget < MaxClients)
	{
		//the one who is getting targeted will see the ring a bit differently.
		TE_SetupBeamRingPoint(struct_Lunar_Grace_Data[npc.index].Loc, fl_lunar_radius*2.0, fl_lunar_radius*2.0 + 0.5, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, STELLA_TE_DURATION, 6.0, 0.1, {255,255,255,255}, 1, 0);
		TE_SendToClient(npc.m_iTarget);
	}
	

	if(!Update)
		return Plugin_Continue;

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
		//Ignore buildings, detect camo, override the area, must be able to see the target.
		npc.m_iTarget = GetClosestTarget(npc.index, true, _, true, _,_,struct_Lunar_Grace_Data[npc.index].Loc, true);
	}
	int Target = npc.m_iTarget;

	if(!IsValidEnemy(npc.index, Target))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		return Plugin_Continue;
	}

	float vecTarget[3]; WorldSpaceCenter(Target, vecTarget);

	npc.FaceTowards(struct_Lunar_Grace_Data[npc.index].Loc, 500.0);

	float flDistanceToTarget = GetVectorDistance(vecTarget, struct_Lunar_Grace_Data[npc.index].Loc, true);
	
	float Speed = 12.0;
	float Speed_Radius = 62500.0;
	if(flDistanceToTarget > Speed_Radius)	//if beyond 250 HU's FROM THE RING to the player, start increasing speed bit by bit
		Speed *= 1.0 + (flDistanceToTarget-Speed_Radius)/Speed_Radius;
	float Velocity[3]; Velocity[0] = Speed;

	float Ang[3];
	MakeVectorFromPoints(struct_Lunar_Grace_Data[npc.index].Loc, vecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Offset_Vector(Velocity, Ang, struct_Lunar_Grace_Data[npc.index].Loc);

	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, struct_Lunar_Grace_Data[npc.index].Loc);

	Explode_Logic_Custom(Modify_Damage(-1, 20.0), npc.index, npc.index, -1, struct_Lunar_Grace_Data[npc.index].Loc, fl_lunar_radius , _ , _ , true, _, _, 10.0, OnAOEHit);

	return Plugin_Continue;
}
static void OnAOEHit(int entity, int victim, float damage, int weapon)
{
	PlayLunarGraceHitSound(victim);

	float EnemyVec[3], Sky[3];
	WorldSpaceCenter(victim, EnemyVec);
	Sky = EnemyVec; Sky[2]+=1500.0;
	int color[4]; Ruina_Color(color, i_current_wave[entity]);
	TE_SetupBeamPoints(EnemyVec, Sky, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 0, 0.1, 2.5, 2.5, 0, 5.0, color, 3);
	TE_SendToAll();
}
static void Offset_Vector(float BEAM_BeamOffset[3], float Angles[3], float Result_Vec[3])
{
	float tmp[3];
	float actualBeamOffset[3];

	tmp[0] = BEAM_BeamOffset[0];
	tmp[1] = BEAM_BeamOffset[1];
	tmp[2] = 0.0;
	VectorRotate(BEAM_BeamOffset, Angles, actualBeamOffset);
	actualBeamOffset[2] = BEAM_BeamOffset[2];
	Result_Vec[0] += actualBeamOffset[0];
	Result_Vec[1] += actualBeamOffset[1];
	Result_Vec[2] += actualBeamOffset[2];
}
static void Body_Pitch(Stella npc, float VecSelfNpc[3], float vecTarget[3])
{
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
		return;		

	//Body pitch
	float v[3], ang[3];
	SubtractVectors(VecSelfNpc, vecTarget, v); 
	NormalizeVector(v, v);
	GetVectorAngles(v, ang); 
							
	float flPitch = npc.GetPoseParameter(iPitch);
							
	npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
}
static bool KeepDistance(Stella npc, float flDistanceToTarget, int PrimaryThreatIndex, float Distance)
{
	bool backing_up = false;
	if(flDistanceToTarget < Distance)
	{
		int Enemy_I_See;
			
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			if(flDistanceToTarget < (Distance*0.9))
			{
				Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				npc.m_bAllowBackWalking=true;
				backing_up = true;
			}
			else
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bAllowBackWalking=false;
			}
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}		
	}
	else
	{
		npc.StartPathing();
		npc.m_bPathing = true;
		npc.m_bAllowBackWalking=false;
	}

	return backing_up;
}
static bool b_MoveTowardsKarlas(Stella npc)
{
	//karlas is invalid, don't bother!
	if(!IsValidAlly(npc.index, npc.Ally))
		return false;

	//if its less then wave 30, no reflect.
	if(i_current_wave[npc.index] < 30)
		return false;

	int Near_Stella = Nearby_Players(npc, 9000.0);

	Karlas npc2 = view_as<Karlas>(npc.Ally);
	Stella npc3 = view_as<Stella>(npc.Ally);

	float Karlas_Wanna_Loc[3];
	CanIseeNCEndLoc(npc2,Karlas_Wanna_Loc);
	int Near_Karlas = Nearby_Players(npc3, 9000.0, Karlas_Wanna_Loc);
	if(Near_Karlas<=0)
		Near_Karlas = Nearby_Players(npc3, 9000.0);
	else
	{
		float GameTime = GetGameTime(npc.index);
		fl_TurnBackUp[npc.index] += 0.5;
		if(fl_TurnBackUp[npc.index] > GameTime + 2.0)
			fl_TurnBackUp[npc.index] = GameTime + 2.0;

		if(fl_TurnBackUp[npc.index] < GameTime)
			fl_TurnBackUp[npc.index] = GameTime;
	}
		
		

	//stella has no targets in sight.
	if(Near_Stella <= 0)
	{
		
		//karlas has ATLEAST 1 target in sight.
		if(Near_Karlas>0)
			return true;
		
		//neither have any valid targets in sight, stella shall target on her own.
		return false;
	}
	//stella has ATLEAST 1 target in sight.
	else	
	{
		//Karlas has more then stella has in line of sight.
		//targets in line of sight of stella are more valuable then the ones near karlas. 
		if(RoundToFloor(Near_Karlas*0.75) > Near_Stella)
		{
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			if(Check_Line_Of_Sight(VecSelfNpc, npc.index, npc.Ally) == -1)
				return false;

			//he has more then 2 in line of sight, its worth using him as a reflector!
			if(Near_Karlas>2)
			{
				//Karlas has more then 2 targets + has more then stella even after the devaluing
				return true;
			}
			else
			{
				//Karlas does have more targets then stella, but its less then 2, so its not worth it.
				return false;
			}
		}
		else
		{
			//stella has more targets then karlas, stella targets on her own!
			return false;
		}
	}
}
static void Handle_NC_TurnSpeed(Stella npc)
{
	float GameTime = GetGameTime(npc.index);

	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	int Face_Target = npc.m_iTarget;

	if(npc.m_flNCspecialTargetTimer < GameTime)
	{
		npc.m_flNCspecialTargetTimer = GameTime + 0.5;
		npc.m_bMovingTowardsKarlas = b_MoveTowardsKarlas(npc);
		//CPrintToChatAll("we are now folloing karlas : %b",npc.m_bMovingTowardsKarlas );
	}

	if(npc.m_bMovingTowardsKarlas)
		Face_Target = npc.Ally;
		
	float vecTarget[3]; WorldSpaceCenter(Face_Target, vecTarget);

	float Duration = npc.m_flNC_Duration - GameTime;
	float Ratio = (1.0 - (Duration / STELLA_NC_DURATION))+0.2;

	float Turn_Speed = ((npc.Anger ? STELLA_NC_TURNRATE_ANGER : STELLA_NC_TURNRATE)*Ratio);

	if(NpcStats_IsEnemySilenced(npc.index))
		Turn_Speed *=0.95;

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	if(!Check_Line_Of_Sight_Vector(VecSelfNpc, vecTarget, npc.index) && fl_TurnBackUp[npc.index] > GameTime)
		return;

	npc.FaceTowards(vecTarget, Turn_Speed);
	Body_Pitch(npc, VecSelfNpc, vecTarget);
}
static int i_targets_inrange;

static int Nearby_Players(Stella npc, float Radius, float VecSelfNpc[3] = {0.0,0.0,0.0})
{
	i_targets_inrange = 0;
	if(VecSelfNpc[2]==0.0)
		WorldSpaceCenter(npc.index, VecSelfNpc);
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);
	return i_targets_inrange;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}
static bool b_Valid_NC_Initialistaion(Stella npc, int type = 0)
{
	int players = CountPlayersOnRed(1);
	if(players <= 2 && type == 0)
		return true;
	//we only want to use NC if we have atleast 2 people in sight (asuming more then 2 people actually exist)
	int Nearby = Nearby_Players(npc, (npc.Anger ? 5000.0 : 2000.0));

	//tpye == 1 is the trigger for the cannon
	if(type==1)
	{
		//more then 2 players near/in line of sight, fire!
		if(Nearby >= 2)
			return true;
		else if(players <=2)	//low player counts.
		{
			//we have ATLEAST 1 target
			if(Nearby>=1)
				return true;
			else
				return false;	//not worth attacking said position, retry!
		}
		else
			return false; //not worth attacking said position, retry!
	}
	if(Nearby >= 2)
		return true;
	else
		return false;
	
}
static bool Stella_Nightmare_Logic(Stella npc, int PrimaryThreatIndex, float vecTarget[3])
{
	if(b_NormLaserOnly[npc.index])
		return false;

	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNC_Recharge > GameTime)
		return false;

	if(npc.m_bInKame)
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
		return false;
	}

	if(!b_Valid_NC_Initialistaion(npc) && npc.m_iNC_Dialogue != 0)
		return false;

	if(npc.m_iNC_Dialogue == 0)
	{
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");

		npc.m_bKarlasRetreat = true;
		int chose = GetRandomInt(1, 12);
		switch(chose)
		{
			case 1: Stella_Lines(npc, "{snow}Thats it {crimson}i'm going to kill you{snow}.");	
			case 2: Stella_Lines(npc, "{crimson}hm, {snow}Wonder how this will end...");
			case 3: Stella_Lines(npc, "{crimson}PREPARE {snow}Thyself, {aqua}Judgement {crimson}Is near{snow}.");
			case 4: Stella_Lines(npc, "Oh not again now train's gone and {crimson}Left{snow}.");
			case 5: Stella_Lines(npc, "Oh not again now cannon's gone and {crimson}recharged{snow}.");
			case 6: Stella_Lines(npc, "Aiming this thing is actually quite {crimson}complex {snow}ya know.");
			case 7: Stella_Lines(npc, "Ya know, im getting quite bored of {crimson}this{snow} whole charade");
			case 8: Stella_Lines(npc, "Oh how {crimson}Tiny{snow} you all look from up here.");
			case 9: Stella_Lines(npc, "Heh {crimson}This is{snow} gonna be funny.");
			case 10:Stella_Lines(npc, "This has become quite troublesome.");
			case 11:Stella_Lines(npc, "Master....");
			case 12:Stella_Lines(npc, "I've got a question for you, how do you think Holy Water is made?");
		}
		//CPrintToChatAll("Chose %i", chose);
		npc.m_iNC_Dialogue = chose;

		npc.m_flNC_Grace = GameTime + GetRandomFloat(6.0, 12.0);
	}
	else if(npc.m_flNC_Grace < GameTime && b_Valid_NC_Initialistaion(npc, 1))
	{
		npc.m_flNC_Duration = GameTime + STELLA_NC_DURATION + 0.75;
		int Enemy_I_See;

		npc.m_bInKame = true;
		npc.m_flDoingAnimation = GameTime + STELLA_NC_DURATION + 1.5;
			
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, Enemy_I_See) && !BlockTurn(npc)) //Check if i can even see.
		{
			npc.FaceTowards(vecTarget, 200000.0);
			npc.FaceTowards(vecTarget, 200000.0);
		}
		npc.SetCrestState(false);

		npc.Set_Particle("utaunt_portalswirl_purple_parent", "", 1);
		npc.Set_Particle("utaunt_runeprison_yellow_parent", "", 2);

		SDKUnhook(npc.index, SDKHook_Think, Lunar_Grace_Tick);
		SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);
		CreateTimer(0.75, Donner_Nightmare_Offset, npc.index, TIMER_FLAG_NO_MAPCHANGE);

		switch(npc.m_iNC_Dialogue)
		{
			case 1: Stella_Lines(npc, "And I'll Do IT WITH THIS CANNON.");
			case 2: Stella_Lines(npc, "This is gonna end {crimson}Poorly for you all{snow}.");
			case 3: Stella_Lines(npc, "{crimson}JUDGEMENT BE UPON THEE{snow}!");
			case 4: Stella_Lines(npc, "And the city's to far to walk to the end while I...");
			case 5: Stella_Lines(npc, "And the Cannons's Capacitor's to small..");
			case 6: Stella_Lines(npc, "However its still{crimson} worth the effort{snow}.");
			case 7: Stella_Lines(npc, "So to amuse myself,{crimson} I'll commit murder on you all{snow}.");
			case 8: Stella_Lines(npc, "But your tiny stature won't save you from my Nightmare Cannon");
			case 9: Stella_Lines(npc, "{crimson}HERE COMES THE FUNNY{snow}.");
			case 10:Stella_Lines(npc, "So I'll just {crimson}remove{snow} the troublesome component!");
			case 11:Stella_Lines(npc, "{aqua}SPARK!");
			case 12:Stella_Lines(npc, "By boiling the hell out of it, {aqua}hehehe....");

			default: CPrintToChatAll("%s It seems my master forgot to set a proper dialogue line for this specific number, how peculiar. Anyway, here's the ID: [%i]", npc.GetName(), npc.m_iNC_Dialogue);
		}
		
		npc.AddActivityViaSequence("taunt_mourning_mercs_medic");
		npc.SetPlaybackRate(2.0);	
		npc.SetCycle(0.0);
		npc.m_bisWalking = false;
		npc.m_flSpeed = 0.0;
		npc.NC_StartupSound();

		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;

		return true;
	}
	return false;
}
static float fl_initial_windup[MAXENTITIES];
static float fl_spinning_angle[MAXENTITIES];
static float fl_NC_thorttle[MAXENTITIES];

static Action Donner_Nightmare_Offset(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidEntity(client))
		return Plugin_Handled;

	Stella npc = view_as<Stella>(client);

	npc.SetPlaybackRate(0.0);
	npc.SetCycle(0.23);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 1.0);
	EmitSoundToAll("mvm/mvm_tank_ping.wav", 0, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	
	npc.m_flNC_Duration = GetGameTime(npc.index) + STELLA_NC_DURATION;
	EmitSoundToAll("vo/medic_sf13_influx_big02.mp3", _, _, _, _, _, RUINA_NPC_PITCH);	//she laughing
	Main_Nightmare_Cannon(npc);

	return Plugin_Handled;
}

static void Main_Nightmare_Cannon(Stella npc)
{
	npc.m_bInKame=true;
	fl_initial_windup[npc.index] = GetGameTime(npc.index)+1.5;
	fl_NC_thorttle[npc.index]=0.0;
	fl_spinning_angle[npc.index]=0.0;
	SDKUnhook(npc.index, SDKHook_Think, Stella_Nightmare_Tick);
	SDKHook(npc.index, SDKHook_Think, Stella_Nightmare_Tick);

	npc.m_iKarlasNCState = 0;
}
public Action Stella_Nightmare_Tick(int iNPC)
{
	Stella npc = view_as<Stella>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNC_Duration<GameTime)
	{
		npc.m_bInKame=false;
		npc.m_flNC_Recharge = GameTime + (npc.Anger ? 30.0 : 45.0);
		npc.m_bKarlasRetreat = false;
		npc.m_iKarlasNCState = 0;
		npc.SetCrestState(true);

		if(IsValidEntity(npc.m_iParticles2))	
			RemoveEntity(npc.m_iParticles2);
		if(IsValidEntity(npc.m_iParticles3))	
			RemoveEntity(npc.m_iParticles3);

		npc.m_bisWalking = true;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_iNC_Dialogue = 0;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		SDKUnhook(npc.index, SDKHook_Think, Stella_Nightmare_Tick);
		return Plugin_Stop;
	}
	bool update = false;

	if(fl_NC_thorttle[npc.index]<GameTime)
	{
		fl_NC_thorttle[npc.index] = GameTime + 0.1;
		update = true;
		ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 0.25);		//replace stun
	}

	bool Silence = NpcStats_IsEnemySilenced(npc.index);

	fl_spinning_angle[npc.index]+=2.0/TickrateModify;
		
	if(fl_spinning_angle[npc.index]>=360.0)
		fl_spinning_angle[npc.index] = 0.0;
	float Start_Loc[3];	

	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(-1.0);
	float endPoint[3]; endPoint = Laser.End_Point;
	float angles[3]; angles = Laser.Angles;
	float radius = 75.0;

	if(Silence)
		radius *=0.95;

	Get_Fake_Forward_Vec(30.0, angles, Start_Loc, Laser.Start_Point);

	float Dist = GetVectorDistance(Start_Loc, endPoint);

	Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 5, Dist, false, radius, 1.0);			//5
	Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 3, Dist, false, radius/3.0, 2.0);		//15
	Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 3, Dist, false, radius/3.0, -2.0);		//18

	if(fl_initial_windup[npc.index] > GameTime)
	{
		Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, false, radius/2.0, -1.0);		//12
		return Plugin_Continue;
	}
	//MINUS FIFTY
	npc.m_iKarlasNCState = 0;
	bool block_main_explosion = false;
	if(IsValidAlly(npc.index, npc.Ally) && npc.m_bMovingTowardsKarlas)
	{
		Laser.Radius = radius*0.75;
		npc.m_iKarlasNCState = 2;
		Laser.Any_entities = true;	//ANY valid entity found is added to the trace.
		Laser.Detect_Entities(FindKarlas);	
		if(npc.m_iKarlasNCState == 1)
		{
			block_main_explosion = true;
			WorldSpaceCenter(npc.Ally, endPoint);
			Dist = GetVectorDistance(Start_Loc, endPoint);
			
			Karlas karl = view_as<Karlas>(npc.Ally);
			npc.m_flNC_LockedOn = GetGameTime(karl.index) + 1.0;

			Ruina_Laser_Logic Karl_Laser;
			Karl_Laser.client = npc.Ally;
			Karl_Laser.DoForwardTrace_Basic(-1.0);
			Laser.End_Point = Karl_Laser.Start_Point;
			NC_CoreBeamEffects(npc, 
			Karl_Laser.Start_Point, 
			Karl_Laser.End_Point, 
			GetVectorDistance(Karl_Laser.Start_Point, Karl_Laser.End_Point), 
			radius, 
			Karl_Laser.Angles, 
			update, 
			Silence);
			//for karlas's laser, nerf its damage.
			//oh also, karlas's turn rate for the laser is also nerfed by 20%
			if(update)	//like the main laser, the damage is dealt 10 times a second
			{
				Karl_Laser.Damage = Modify_Damage(-1, 25.0);
				Karl_Laser.Bonus_Damage = Modify_Damage(-1, 25.0)*6.0;
				Karl_Laser.damagetype = DMG_PLASMA;
				Karl_Laser.Deal_Damage();
			}
		}
		
	}

	npc.PlayNightmareSound();

	if(update)	//damage is dealt 10 times a second
	{
		Laser.Damage = Modify_Damage(-1, 35.0);
		Laser.Bonus_Damage = Modify_Damage(-1, 35.0)*6.0;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage();

		if(block_main_explosion)
			update = false;
	}

	
	NC_CoreBeamEffects(npc, Start_Loc, endPoint, Dist, radius, angles, update, Silence);
	
	return Plugin_Continue;
}
static void FindKarlas(int client, int entity, int damagetype, float damage)
{
	Stella npc = view_as<Stella>(client);
	if(entity == npc.Ally)
	{
		Stella faker = view_as<Stella>(npc.Ally);
		if(Nearby_Players(faker, 9000.0)<=0)
			return;

		Karlas karl = view_as<Karlas>(npc.Ally);
		npc.m_iKarlasNCState = 1;	
		if(npc.m_flNC_LockedOn > GetGameTime(karl.index))
			return;
		NPC_StopPathing(karl.index);
		karl.m_bPathing = false;
		karl.m_flGetClosestTargetTime = 0.0;
		karl.m_flSpeed = 0.0;
	}
}
static void NC_CoreBeamEffects(Stella npc, float Start_Loc[3], float endPoint[3],  float Dist, float radius, float angles[3], bool update, bool Silence)
{
	Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, true, radius/2.0, -1.0);		//12

	float diameter = radius *0.75;

	int r=100, g=100, b=100, a=60;

	if(Silence)
		a = 30;
	int colorLayer4[4];
	SetColorRGBA(colorLayer4, r, g, b, a);
	int colorLayer3[4];
	SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, colorLayer4[3]* 7 + 765 / 8);
	int colorLayer2[4];
	SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, colorLayer4[3]* 6 + 765 / 8);
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, colorLayer4[3]* 5 + 765 / 8);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, a);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter*1.5), ClampBeamWidth(diameter*0.75), 0, 2.5, glowColor, 0);
	TE_SendToAll(0.0);

	if(update)	//use a particle instead of this for fancyness of fancy
	{
		DataPack pack = new DataPack();
		pack.WriteFloat(endPoint[0]);
		pack.WriteFloat(endPoint[1]);
		pack.WriteFloat(endPoint[2]);
		pack.WriteCell(1);
		RequestFrame(MakeExplosionFrameLater, pack);
	}
}
static void Stella_Create_Spinning_Beams(Stella npc, float Origin[3], float Angles[3], int loop_for, float Main_Beam_Dist, bool Type=true, float distance_stuff, float ang_multi)
{
	
	float buffer_vec[10][3];
		
	for(int i=1 ; i<=loop_for ; i++)
	{	
		float tempAngles[3], Direction[3], endLoc[3], End_Loc[3];
		tempAngles[0] = Angles[0];
		tempAngles[1] = Angles[1];	//has to the same as the beam
		tempAngles[2] = (fl_spinning_angle[npc.index]+((360.0/loop_for)*float(i)))*ang_multi;	//we use the roll angle vector to make it speeen
		/*
			Using this method we can actuall keep proper pitch/yaw angles on the turning, unlike say fantasy blade or mlynar newspaper's special swing thingy.
		*/
		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, distance_stuff);
		AddVectors(Origin, Direction, endLoc);
		
		buffer_vec[i] = endLoc;
		
		Get_Fake_Forward_Vec(Main_Beam_Dist, Angles, End_Loc, endLoc);
		
		if(Type)
		{
			int r=1, g=1, b=255, a=225;
			float diameter = 15.0;
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, a);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, a);
										
			TE_SetupBeamPoints(endLoc, End_Loc, g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	int color[4]; color[0] = 1; color[1] = 255; color[2] = 255; color[3] = 255;
	
	TE_SetupBeamPoints(buffer_vec[1], buffer_vec[loop_for], g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=1 ; i<loop_for ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Laser, 0, 0, 0, STELLA_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Stella npc = view_as<Stella>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;


	Stella_Weapon_Lines(npc, attacker);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
static void Stella_Weapon_Lines(Stella npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		case WEAPON_KIT_BLITZKRIEG_CORE: switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "Blitzkrieg, that thing dared to disobey me, but will you {gold}%N{snow} do the same?", client); 								case 1: Format(Text_Lines, sizeof(Text_Lines), "I'll make you {gold}%N{snow} feel the same pain Blitzkrieg inflicted on us.", client);}
		case WEAPON_FANTASY_BLADE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "{crimson}Karlas{snow}'s Old blade, interesting choice {gold}%N", client); 														case 1: Format(Text_Lines, sizeof(Text_Lines), "So what if I told you {gold}%N{snow} that you're using the failed version..", client);}	
		case WEAPON_ION_BEAM_NIGHT: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "You're trying to copy me {gold}%N{snow}?", client); 																			case 1: Format(Text_Lines, sizeof(Text_Lines), "I don't approve of this {gold}%N", client);}
		case WEAPON_IMPACT_LANCE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "Pointy stick go into enemy, right {gold}%N{snow}?", client); 																	case 1: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow}, You will never become as proficient with the lance as {crimson}Karlas", client);}	
		case WEAPON_ION_BEAM: switch(GetRandomInt(0,1)) 			{case 0: Format(Text_Lines, sizeof(Text_Lines), "Laser based spell's are one of Ruina's specialties, {gold}%N{snow} You don't even know the first thing about them..",client); 	case 1: Format(Text_Lines, sizeof(Text_Lines), "Oi, {gold}%N{snow} I helped create that spell, you can't just steal it and use it aggainst me", client);}	
		case WEAPON_ION_BEAM_PULSE: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "And you're using {purple}Twirl's{snow} prefered laser, I hope you know what you're getting yourself into {gold}%N", client); 	case 1: Format(Text_Lines, sizeof(Text_Lines), "If {purple}Twirl{snow} catches wing of what you're using {gold}%N{snow}, good luck", client);}	
		case WEAPON_GRAVATON_WAND: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "Gravity is a harness, you {gold} %N{snow} have not harnessed it", client); 													case 1: Format(Text_Lines, sizeof(Text_Lines), "Wonder how you'd react {gold}%N{snow}, if you saw the real one.", client);}
		case WEAPON_ION_BEAM_FEED: 	Format(Text_Lines, sizeof(Text_Lines), "Here's some interesting information for you {gold}%N{snow} the feedback loop Prisim has been obsolete for AGES", client);
		case WEAPON_BOBS_GUN:  		Format(Text_Lines, sizeof(Text_Lines), "Oh, bob's gun well might as well go and sleep... I give up {gold}%N", client); 
		case WEAPON_KIT_FRACTAL:	Format(Text_Lines, sizeof(Text_Lines), "I thought the {aqua}Fractal{snow} was still being developed, how did you {gold}%N{snow} get your hands on it?", client); 
		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		Stella_Lines(npc, Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}

static void Internal_NPCDeath(int entity)
{
	Stella npc = view_as<Stella>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);

	SDKUnhook(npc.index, SDKHook_Think, Lunar_Grace_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Stella_Nightmare_Tick);
	SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);

	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);

	npc.m_bKarlasRetreat = false;

	RaidModeScaling *= 1.2;

	if(b_tripple_raid[npc.index])
	{
		Twirl_OnStellaKarlasDeath(npc.Ally);
	}

	if(!npc.m_bSaidWinLine)
	{
		if(b_bobwave[npc.index])
		{
			switch(GetRandomInt(1,3))
			{
				case 1: Stella_Lines(npc, "Huh, I guess our turn's over");
				case 2: Stella_Lines(npc, "Oh boy, this is gonna be fun to watch");
				case 3: Stella_Lines(npc, "I wanted to play with them more, allas");
			}
		}
		else
		{
			if(npc.Ally)
			{
				Karlas karl = view_as<Karlas>(npc.Ally);
				karl.Anger = true;
				NpcSpeechBubble(npc.Ally, ">>:(", 7, {255,9,9,255}, {0.0,0.0,120.0}, "");
				switch(GetRandomInt(1,3))
				{
					case 1: Stella_Lines(npc, "Hmph, I'll let {crimson}Karlas{snow} handle this");
					case 2: Stella_Lines(npc, "You still have {crimson}Karlas{snow} to deal with... heh");
					case 3: Stella_Lines(npc, "I hope you like spining blades");
				}
			}
			else
			{
				switch(GetRandomInt(1,2))
				{
					case 1: Stella_Lines(npc, "Hmph, I'll let this slide,{crimson} for now.");
					case 2: Stella_Lines(npc, "Fine, we're leaving.{crimson} Until next time that is{snow} heh");
				}
			}
		}
	}
	RaidModeTime +=50.0;

	if(EntRefToEntIndex(RaidBossActive)==npc.index)
		RaidBossActive = INVALID_ENT_REFERENCE;
		
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
	if(IsValidEntity(npc.m_iWearable7))	
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable8))	
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable9))	
		RemoveEntity(npc.m_iWearable9);

	if(IsValidEntity(npc.m_iWingSlot))	
		RemoveEntity(npc.m_iWingSlot);

	for(int i=0 ; i < 3 ; i++)
	{
		if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][i])))
			RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][i]));
	}
	
}
static bool b_hit_something;
static bool Is_Target_Infront(Stella npc, float Radius)
{
	b_hit_something=false;
	
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	float Range = fl_Normal_Laser_Range(npc);
	Laser.DoForwardTrace_Basic(Range);
	Laser.Radius = Radius;
	Laser.Detect_Entities(On_LaserHit);	//by default it only filters out enemies

	return b_hit_something;
}
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	b_hit_something = true;
}
static bool BlockTurn(Stella npc)
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNorm_Attack_In < GameTime + 1.0 && npc.m_flNorm_Attack_In > GameTime)
		return true;

	if(npc.m_flNorm_Attack_Duration > GameTime)
		return true;

	return false;
	
}
static float fl_Normal_Laser_Range(Stella npc)
{
	return (npc.Anger ? 3000.0 : 1000.0);
}
static void Self_Defense(Stella npc, float flDistanceToTarget)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_iNC_Dialogue != 0)
	{
		float Grace_Time = npc.m_flNC_Grace - GameTime;
		if(Grace_Time < 3.0)
		{
			npc.m_flNorm_Attack_In = 0.0;
			npc.Set_Crest_Charging_Phase(false);
			return;
		}
	}
	
	float Range = fl_Normal_Laser_Range(npc);

	if(npc.m_flNorm_Attack_In > GameTime)
	{
		Ruina_Laser_Logic Laser;
		if(NpcStats_IsEnemySilenced(npc.index))
			Range *=0.95;
		Laser.client = npc.index;
		Laser.DoForwardTrace_Basic(Range);
		int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
		float flPos[3];
		npc.GetAttachment("effect_hand_r", flPos, NULL_VECTOR);
		TE_SetupBeamPoints(flPos, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 0.1, 2.0, 2.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}

	float Attack_Speed = 3.3;	//how often she attacks.
	float Attack_Delay = 1.0;	//how long until she actually attacks
	float Attack_Time = STELLA_NORMAL_LASER_DURATION;	//how long the normal attack laser lasts

	if(npc.m_flNorm_Attack_In > GameTime)
		npc.m_bAllowBackWalking = true;

	//target is too far, and we are a not about to fire a laser, return.
	if(npc.m_flNorm_Attack_In == 0.0 && flDistanceToTarget > Range*Range)
	{
		return;
	}

	//target within range, and our laser is recharged.
	if(npc.m_flNextRangedAttack < GameTime)
	{
		if(!Is_Target_Infront(npc, 50.0))
			return;

		npc.m_flNorm_Attack_In = GameTime + Attack_Delay;
		npc.m_flNextRangedAttack = GameTime + Attack_Speed;
		/*int color[4]; Ruina_Color(color, i_current_wave[npc.index]);
		float self_Vec[3]; WorldSpaceCenter(npc.index, self_Vec);
		TE_SetupBeamRingPoint(self_Vec, 300.0, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, Attack_Delay, 15.0, 0.1, color, 1, 0);
		TE_SendToAll();*/

		npc.Set_Crest_Charging_Phase(true);

		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE", _ , 2.0, _, 0.28);
		npc.PlayLaserChargeSound();
	}

	if(npc.m_flNorm_Attack_In != 0.0 && npc.m_flNorm_Attack_In < GameTime)
	{
		npc.m_flNorm_Attack_In = 0.0;
		npc.m_flNorm_Attack_Duration = GameTime + Attack_Time;
		npc.m_flNorm_Attack_Throttle = 0.0;
		Fire_Laser(npc);
		npc.PlayLaserAttackSound();
	}
}
static void Fire_Laser(Stella npc)
{
	SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);
	SDKHook(npc.index, SDKHook_Think, Normal_Laser_Think);
}
static float Modify_Damage(int Target, float damage)
{
	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	damage*=RaidModeScaling;

	return damage;
}
public Action Normal_Laser_Think(int iNPC)	//A short burst of a laser.
{
	Stella npc = view_as<Stella>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNorm_Attack_Duration < GameTime)
	{
		npc.Set_Crest_Charging_Phase(false);
		SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);
		return Plugin_Stop;
	}

	/*
	//uncomment this and the other thing to reenable
	bool update = false;
	if(npc.m_flNorm_Attack_Throttle < GameTime)
	{
		npc.m_flNorm_Attack_Throttle = GameTime + 0.1;
		update = true;
	}*/

	npc.m_bAllowBackWalking = true;

	bool Silence = NpcStats_IsEnemySilenced(npc.index);

	float Range = fl_Normal_Laser_Range(npc);
	
	float radius = 10.0;

	Ruina_Laser_Logic Laser;
	if(Silence)
		Range *=0.95;
	//unlike most ruina lasers, this one deals damage every tick.
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(Range);
	
	int target = i_Get_Laser_Target(npc, Range);

	float Ratio = 1.0 - (npc.m_flNorm_Attack_Duration - GameTime) / STELLA_NORMAL_LASER_DURATION;

	if(Ratio < 0.001)
		Ratio = 0.001;

	if(IsValidEnemy(npc.index, target))
	{
		//times these value has been altered: 32.
		//warp_turn_speed
		float Bonus_Speed_Range = 500.0*500.0;
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float Self_Vec[3]; WorldSpaceCenter(npc.index, Self_Vec);
		float Dist = GetVectorDistance(vecTarget, Self_Vec, true);

		float Turn_Rate = (npc.Anger ? 0.09 : 0.07);
		float Turn_Speed = (RUINA_FACETOWARDS_BASE_TURNSPEED*Turn_Rate);
		
		if(Dist <= 0.0)
			Dist = 1.0;

		//if(!BlockTurn(npc))

		if(Dist < Bonus_Speed_Range)
		{
			Turn_Speed*= 1.0 + ((Bonus_Speed_Range - Dist)/Bonus_Speed_Range)*2.0;
		}

		if(Silence)
			Turn_Speed *= 0.95;

		Turn_Speed /=TickrateModify;
		Turn_Speed /=f_AttackSpeedNpcIncreace[npc.index];

		float Turn_Extra = 0.94 + ((Ratio+0.5)*(Ratio+0.5)*(Ratio+0.5)*(Ratio+0.5));	
		//this ^ what I did here is ass. NORMALLY what you would do is (Ratio+0.5)^4.0. BUT FOR WHATEVER REASON, doing that results in numbers that physically shouldn't be possible.
		//CPrintToChatAll("Turn Extra: %f", Turn_Extra);
		Turn_Speed *= Turn_Extra;

		npc.FaceTowards(vecTarget, Turn_Speed);
	}

	//if(update)
	{
		//extreme amounts of trolley
		float Dmg = Modify_Damage(-1, 4.5);
		Dmg *= (0.75-Logarithm(Ratio));
		Dmg /= TickrateModify;	//since the damage is dealt every tick, make it so the dmg is modified by tickrate modif.
		Dmg /=f_AttackSpeedNpcIncreace[npc.index];
		//the 0.75 is min dmg it will reach at ability end.
		Laser.Damage = Dmg;
		Laser.Radius = radius;
		Laser.Bonus_Damage = Dmg*6.0;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage();

		//CPrintToChatAll("Damage: %f", Dmg);
	}

	float startPoint[3], endPoint[3];
	float flPos[3];
	npc.GetAttachment("effect_hand_r", flPos, NULL_VECTOR);
	startPoint  = flPos;
	endPoint	= Laser.End_Point;
	float diameter = radius *1.0;
	int color[4];
	Ruina_Color(color, i_current_wave[npc.index]);

	if(i_current_wave[npc.index] >=45)
	{
		color[0] = 0;
		color[1] = 250;
		color[2] = 237;	
	}

	if(Silence)
		color[3] = 175;
	else
		color[3] = 255;
	//TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, color, 3);
	//TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, g_Ruina_BEAM_lightning, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, color, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Combine_Blue, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, color, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Diamond, 0, 0, 0.11, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, color, 3);
	TE_SendToAll(0.0);

	TE_SetupBeamPoints(startPoint, endPoint, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.11, ClampBeamWidth(diameter*1.5), ClampBeamWidth(diameter*0.75), 0, 2.5, color, 0);
	TE_SendToAll(0.0);

	return Plugin_Continue;
}
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}
static int Check_Line_Of_Sight(float pos_npc[3], int attacker, int enemy)
{
	Ruina_Laser_Logic Laser;
	Laser.client = attacker;
	Laser.Start_Point = pos_npc;

	float Enemy_Loc[3], vecAngles[3];
	//get the enemy gamer's location.
	GetAbsOrigin(enemy, Enemy_Loc);
	//get the angles from the current location of the crystal to the enemy gamer
	MakeVectorFromPoints(pos_npc, Enemy_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	//get the estimated distance to the enemy gamer,
	float Dist = GetVectorDistance(Enemy_Loc, pos_npc);
	//do a trace from the current location of the crystal to the enemy gamer.
	Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.

	float Trace_Loc[3];
	Trace_Loc = Laser.End_Point;	//get the end location of the trace.
	//see if the vectors match up, if they do we can safely say the target is in line of sight of the origin npc/loc
	if(Similar_Vec(Trace_Loc, Enemy_Loc))
		return enemy;
	else
		return -1;

}
static bool Check_Line_Of_Sight_Vector(float pos_npc[3], float Enemy_Loc[3], int attacker)
{
	Ruina_Laser_Logic Laser;
	Laser.client = attacker;
	Laser.Start_Point = pos_npc;

	float vecAngles[3];
	//get the enemy gamer's location.
	//get the angles from the current location of the crystal to the enemy gamer
	MakeVectorFromPoints(pos_npc, Enemy_Loc, vecAngles);
	GetVectorAngles(vecAngles, vecAngles);
	//get the estimated distance to the enemy gamer,
	float Dist = GetVectorDistance(Enemy_Loc, pos_npc);
	//do a trace from the current location of the crystal to the enemy gamer.
	Laser.DoForwardTrace_Custom(vecAngles, pos_npc, Dist);	//alongside that, use the estimated distance so that our end location from the trace is where the player is.

	float Trace_Loc[3];
	Trace_Loc = Laser.End_Point;	//get the end location of the trace.
	//see if the vectors match up, if they do we can safely say the target is in line of sight of the origin npc/loc

	return Similar_Vec(Trace_Loc, Enemy_Loc);

}




public void Doonerkrieg_Delay_TE_Ring(DataPack pack)
{
	pack.Reset();
	float endLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Time = pack.ReadCell();

	spawnRing_Vectors(endLoc, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, Time, 6.0, 0.1, 1, 1.0);
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Beam(DataPack pack)
{
	pack.Reset();
	float endLoc[3], StartLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	StartLoc[0] = pack.ReadCell();
	StartLoc[1] = pack.ReadCell();
	StartLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	float time = pack.ReadCell();
	float start = pack.ReadCell();
	float end = pack.ReadCell();

	TE_SetupBeamPoints(StartLoc, endLoc, g_Ruina_BEAM_Laser, 0, 0, 0, time, start, end, 0, 1.0, color, 3);
	TE_SendToAll();
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Explosion(DataPack pack)
{
	pack.Reset();
	float endLoc[3];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();

	TE_SetupExplosion(endLoc, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
		
	delete pack;
}

public void Doonerkrieg_Delay_TE_Beam2(DataPack pack)
{
	pack.Reset();
	float endLoc[3], StartLoc[3];
	int color[4];
	endLoc[0] = pack.ReadCell();
	endLoc[1] = pack.ReadCell();
	endLoc[2] = pack.ReadCell();
	StartLoc[0] = pack.ReadCell();
	StartLoc[1] = pack.ReadCell();
	StartLoc[2] = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	int SPRITE_INT_2 = pack.ReadCell();
					
	TE_SetupBeamPoints(StartLoc, endLoc, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
	TE_SendToAll();
		
	delete pack;
}
static float Target_Angle_Value(Stella npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(npc.index, npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyeAngles);

	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0)
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	//if its more then 180, its on the other side of the npc / behind
	return fabs(yawOffset);
}
//don't just search for the nearest target when using the laser.
//Instead search for the target NEAREST to our BEAM's length.
static int i_Get_Laser_Target(Stella npc, float Range = -1.0)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[MAXTF2PLAYERS];
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, true);
	//only bother getting targets infront of stella that are players. + wall check obv
	int Tmp_Target = -1;
	float Angle_Val = 420.0;
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			float Target_Angles = Target_Angle_Value(npc, enemy_2[i]);
			float VecTarget[3]; WorldSpaceCenter(enemy_2[i], VecTarget);
			if(Target_Angles < 45.0 && Target_Angles < Angle_Val && (Range == -1 || GetVectorDistance(VecTarget, Npc_Vec) <= Range))
			{
				Angle_Val = Target_Angles;
				Tmp_Target = enemy_2[i];
				
				//CPrintToChatAll("Player %N within 45 degress: %f", Tmp_Target, Target_Angles);
			}
		}
	}
	//if we don't find any targets within 90 degrees infront, give up and use normal targeting!
	//and by 90 degress I mean -45 -> 45. \/
	
	if(!IsValidEnemy(npc.index, Tmp_Target))
	{
		//CPrintToChatAll("Backup Target used");
		npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
		if(npc.m_iTarget < 1)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		return npc.m_iTarget;
	}
	else
	{
		//CPrintToChatAll("Chose Target: %N with angle var: %f", Tmp_Target, Angle_Val);
		return Tmp_Target;
	}
		
}
void Stella_Lines(Stella npc, const char[] text)
{
	if(b_test_mode[npc.index])
		return;

	CPrintToChatAll("%s %s", npc.GetName(), text);
}