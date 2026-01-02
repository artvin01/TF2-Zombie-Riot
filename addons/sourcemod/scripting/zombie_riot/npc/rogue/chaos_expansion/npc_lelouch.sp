// grr twink
#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
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
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static const char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};

static const char g_AngerSounds[][] = {
	"mvm/mvm_tank_deploy.wav",
};
static const char g_LaserLoop[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3"
};

/*
	Notepad:

	Blades:
		Blade initiation Logic  done.
		Blade loop logic done.
		Manipulation ENT created. seems to work thus far
		Blade Slam Done!
		Blade Spin Done!

	Crystals:
		Basic crystal operation Done.
		Make crystal Spin laser.
		Port over ability 8 into one of the laser mods. Done. Just need to add dmg laser code.
		Add a cool animation for when the crystals get summoned, something akin to what karlas does. it looks cool. somewhat done. needs more tweaking.
			- disco_fever
			
			maybe whenever you kill all the crystals he does an anim: taunt_commending_clap_spy


	Cosmetics:
		- Make a custom sword/blade
		- Make someform of wings, take inspiration for the wings from his main knightmare that he uses.
		- a cape, of someform, gotta look for one inside loadout.tf to get a good one.

	Secondary:
		- Proper text lines. "you bitch" probably wouldn't be thaaat good for a live server



	for final anchors ability thing:

		add lantean orbs to his hands.
		make env beams go up from his hands, then merge in the middle, then go up further and do fancy particle of particle ssj at 3 am gone wrong.

	Base Model: Spy

	Theme: https://www.youtube.com/watch?v=AoSUEMYzusc
	
	Make him more militaristic, sure he was a part of the same race/faction as Twirl.
	But he was more focused on results (The ends justify the means)
	his methods are more gritty, but are more "effective" - deadly.

	

	Abilities in no order. just ones that I came up with on the spot.
	also some names are just uhh. pending.
	also also, some probably won't make it in. probably.

	1 - Spiral Fracture: - likely no.
		Stand in spot. do anim.
		300~ HU's in 8 directions walls appear. touching said wall will kill you.
		the walls spin.

		Within 300 HU's players would be safe.

	2 - XX?				- will do
		
		Fire off projectiles in 16 directions.
		These projectiles slowdown slowly.
		Once X seconds pass. a beam of light appears on said projectiles.
		Every projectile that can see any other projectile connect with a small beam.
		then after a few seconds that beam becomes thicker and starts to deal damage.
		
		- Every 2nd proj has a different speed. would allow for special patterns.
		- also stagger firing them too.

		Stand in spot while firing proj.
		while the proj "charge" do anim.
		once lasers become thick and deal dmg, move normally

	//say happens on 90-75% hp?
	3 - Chaos CONTROL (actual name pending.) - will do
		3 special points on the map appears using pre set vectors.
		Magia anchors spawn. chaos affected model smth like that.
		And a countdown begins.

		During this countdown the main boss is invulnerable. and stays in 1 spot.

		Red team have to destroy these anchors before the countdown finishes.
		
		if they fail. depending on the amount of alive anchors left upon the countdown finishing
		ION's spawn on those locations. being very near them makes the player take passive dmg (300-400~) hu?
		Anyone close to the pillars takes increased damage. 600~ hu

		if you royally fuck up and all 3 are still active, all 3 shoot a beam into the center of the arena and create a ORB that shoots 1 big ass death ray.
		following any targets it can see.
		The anchors also gain a lot of resistances, and all their hp is equalized.
		if you kill one of the anchors this breaks.

		If you kill all the anchors: Twirl summons her own anchors in those locations and creates a friendly beam of death.
		Solong as they can keep the anchors alive.

		the anchors also give buffs to red.

		The main boss's priority will switch from killing players to killing any one of the anchors first.
		
		(the idea is that keeping the anchors alive is one viable way to win)

	4 - Blade Related abilities:
		4.1 Does anim. creates a massive - huge as fuck - blade above himself and then a few seconds later slams it down forward dealing HUGE damage to anyone caught in it.
		4.2 Does Anim. big blade. it spawns forward of the npc. then after a few seconds it spins a few times around the npc very fast dealing dmg to anyone caught in the blades AOE


	5 - Frame-Shift-Cannon: - dunno
		Does anim, long charge up.
		Unleashes a fucking DEATH BEAM.
		anything caught in up in it just dies.
		
		In addition, ion strikes happen along the path of the cannon. on the sides.

		Forward facing.

	6 - Stellarararar - dunno
		happens at around 25% hp.

		A massive stellar weaver is summoned at the center of the arena. it cannot take damage, its simply a threat that exists.
		best you can do is distract it.

	7 - Crystal Shield: - will do
		Creates 3 crystals that spin around the boss.
		While active each shield gives 25% dmg resist.
		Each crystal has its own health pool.

		Crystal Specific abilities:	

		7.1 Spiral.
			Does an animation.
			Crystals shoot lasers in their own direction while spining.

		7.2 Focus.
			The crystals start shooting the target the npc is attacking. they also move slightly upward.
			but they also only start blocking 10% dmg.

	8 - Infinity Laser Works (get it?) - maybe.
		Does anim. floats up.
		Several portals or somethingl ike that appears behind the npc in a circle/pattern.

		Seconds later lasers being shooting from said portals.

		Laser logic:
		Get Client Vector.
		Get client Velocity Vector.
		Vector1 :Get BEHIND said velocity, by 2.0
		Vector2: Then get the vector 2.0 Infront of the client.
		Then make the laser Travel from vector1 to vector2.
		Duration 2.0s?

		If the player sees this coming, they can simply walk sideways avoding the laser.

*/




int i_Lelouch_Index;
#define LELOUCH_BLADE_MODEL "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl"
#define LELOUCH_CRYSTAL_MODEL "models/props_moonbase/moon_gravel_crystal_blue.mdl"
#define LELOUCH_LIGHT_MODEL "models/effects/vol_light256x512.mdl"
#define LELOUCH_THEME "#zombiesurvival/forest_rogue/lelouch_theme.mp3"

#define LELOUCH_CRYSTAL_SPIN_SOUND_INIT	 	"npc/strider/charging.wav"
#define LELOUCH_CRYSTAL_WORKS_SOUND_INIT	"weapons/cguard/charging.wav"

//hl1/ambience/alien_powernode.wav
//hl1/ambience/alien_cycletone.wav

#define LELOUCH_CRYSTAL_SHIELD_BEGINSPIN	"misc/doomsday_cap_open_start.wav"
#define LELOUCH_CRYSTAL_SHIELD_ACTIVATE		"mvm/mvm_tele_activate.wav"

#define LELOUCH_CRYSTAL_SHIELD_STRENGTH 0.1	//How much res each crystal gives. eg: 4 crystals alive, each does 0.1, total res is 40%

static float fl_Anchor_Fixed_Spawn_Pos[3][3] ={
	{8731.121094, 2849.591797, -3378.968750},
	{6070.426270, -2539.363281, -3378.968750},
	{11448.688477, -64.187515, -3378.968750}
};
static int i_AnchorID_Ref[MAXENTITIES][3];
static bool b_Anchors_Created[MAXENTITIES];
static float fl_Anchor_Logic[MAXENTITIES];
static float fl_RaidModeScaling_Buffer;
static bool b_Anchors_Red;
static bool b_DeathRay;
static bool b_Standard_Anchor;

static bool b_crystals_active[MAXENTITIES];
static bool b_animation_set[MAXENTITIES];
static bool b_test_mode[MAXENTITIES];


static const char NameColour[] = "{black}";
static const char TextColour[] = "{snow}";


static int i_specialentslot[MAXENTITIES];

void Lelouch_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lelouch");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_lelouch");
	data.Category = Type_BlueParadox;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "lelouch"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSound("items/cart_explode.wav");
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_AngerSounds);

	PrecacheSound(LELOUCH_CRYSTAL_SPIN_SOUND_INIT);
	PrecacheSound(LELOUCH_CRYSTAL_WORKS_SOUND_INIT);
	PrecacheSound(LELOUCH_CRYSTAL_SHIELD_BEGINSPIN);
	PrecacheSound(LELOUCH_CRYSTAL_SHIELD_ACTIVATE);

	Zero(b_animation_set);

	PrecacheModel(LELOUCH_LIGHT_MODEL);
	PrecacheModel(LELOUCH_BLADE_MODEL);
	PrecacheModel(LELOUCH_CRYSTAL_MODEL);

	PrecacheSound("mvm/mvm_tele_deliver.wav");

	PrecacheSoundCustom(LELOUCH_THEME);
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, char[] data)
{
	return Lelouch(vecPos, vecAng, team, data);
}
Action Timer_Lelouch_Repeat_Sound(Handle Timer, DataPack data)
{
	ResetPack(data);
	int client = EntRefToEntIndex(data.ReadCell());
	char Sound[255];
	data.ReadString(Sound, sizeof(Sound));
	int type = data.ReadCell();
	float Volume = data.ReadFloat();
	int pitch = data.ReadCell();

	if(!IsValidEntity(client))
		return Plugin_Stop;

	switch(type)
	{
		case 1:
		{
			EmitSoundToAll(Sound, client, _, SNDLEVEL_NORMAL, _, Volume, pitch);
		}
		case 2:
		{
			float Loc[3];
			data.ReadFloatArray(Loc, 3);
			EmitSoundToAll(Sound, client, _, SNDLEVEL_NORMAL, _, Volume, pitch, -1, Loc);
		}
		case 3:
		{
			EmitSoundToAll(Sound, client, _, SNDLEVEL_RAIDSIREN, _, Volume, pitch);
		}
		default:
		{
			EmitSoundToAll(Sound, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, Volume, pitch);
		}
	}

	return Plugin_Stop;
}
static bool b_lastman[MAXENTITIES];
static bool b_wonviatimer[MAXENTITIES];
static bool b_wonviakill[MAXENTITIES];
static float fl_npc_basespeed;
methodmap Lelouch < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);	
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);	
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH - 10);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE_ALLCLASS");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	public void PlayLaserLoopSound() {
		if(fl_nightmare_cannon_core_sound_timer[this.index] > GetGameTime())
			return;
		
		EmitCustomToAll(g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)], _, _, SNDLEVEL_RAIDSIREN, _, 0.7);
		fl_nightmare_cannon_core_sound_timer[this.index] = GetGameTime() + 2.25;
	}
	public void PlayCrystalSounds()
	{
		EmitSoundToAll(LELOUCH_CRYSTAL_SHIELD_BEGINSPIN, this.index, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 50);
		char SoundString[255];
		SoundString = LELOUCH_CRYSTAL_SHIELD_ACTIVATE;
		DataPack data;
		CreateDataTimer(7.0, Timer_Lelouch_Repeat_Sound, data, TIMER_FLAG_NO_MAPCHANGE);
		data.WriteCell(EntIndexToEntRef(this.index));
		data.WriteString(SoundString);
		data.WriteCell(3);		//type.
		data.WriteFloat(1.0);	//volume
		data.WriteCell(50);		//pitch
		//data.WriteFloatArray(Random_Loc, 3);	//if type is 2, sets where it shall spawn.

	}

	property float m_flBladeCoolDownTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flCrystalCoolDownTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flCrystalSpiralLaserCoolDownTimer
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flRevertAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flFreezeAnim
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flCrystalLaserWorks
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	property float m_flCrystalRevert
	{
		public get()							{ return fl_AbilityOrAttack[this.index][6]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][6] = TempValueForProperty; }
	}
	property float m_flGiveHyperResistances
	{
		public get()							{ return fl_AbilityOrAttack[this.index][7]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][7] = TempValueForProperty; }
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
	property int m_iSpecialEntSlot
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_specialentslot[this.index]);
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
				i_specialentslot[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_specialentslot[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}

	public char[] GetName()
	{
		char Name[255];
		Format(Name, sizeof(Name), "%s%s%s:", NameColour, c_NpcName[this.index], TextColour);
		return Name;
	}
	public void RangedArmour(float value)
	{
		int crystals = i_Alive_Crystals(this);
		if(crystals>0)
			value -= (crystals*LELOUCH_CRYSTAL_SHIELD_STRENGTH);

		float GameTime = GetGameTime(this.index);
		if(this.m_flDoingAnimation > GameTime)
			value *=0.35;

		if(this.m_flGiveHyperResistances > GameTime)
			value *=0.1;

		if(value <= 0.05)
			value = 0.05;

		this.m_flRangedArmor = value;
	}
	public void MeleeArmour(float value)
	{
		int crystals = i_Alive_Crystals(this);
		if(crystals>0)
			value -= (crystals*LELOUCH_CRYSTAL_SHIELD_STRENGTH);

		float GameTime = GetGameTime(this.index);
		if(this.m_flDoingAnimation > GameTime)
			value *=0.35;

		if(this.m_flGiveHyperResistances > GameTime)
			value *=0.1;

		if(value <= 0.05)
			value = 0.05;

		this.m_flMeleeArmor = value;
	}
	public void SetWeaponState(int activate)
	{
		if(IsValidEntity(this.m_iWearable1))
			RemoveEntity(this.m_iWearable1);

		if(!activate)
			return;

		this.m_iWearable1 = this.EquipItem("effect_hand_r", RUINA_CUSTOM_MODELS_4);
		SetVariantInt(RUINA_FANTASY_BLADE);
		AcceptEntityInput(this.m_iWearable1, "SetBodyGroup");
	}
	public int Set_Particle(char[] Particle, char[] Attachment)
	{
		float flPos[3], flAng[3];

		this.GetAttachment(Attachment, flPos, flAng);
		return ParticleEffectAt_Parent(flPos, Particle, this.index, Attachment, {0.0,0.0,0.0});
	}

	public Lelouch(float vecPos[3], float vecAng[3], int ally, char[] data)
	{
		Lelouch npc = view_as<Lelouch>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 3;

		b_test_mode[npc.index] = StrContains(data, "test") != -1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;

		c_NpcName[npc.index] = "Lelouch";	//Lelouch Vi Britania.

		npc.m_flBladeCoolDownTimer = GetGameTime(npc.index) + GetRandomFloat(15.0, 30.0);

		b_crystals_active[npc.index] = false;
		npc.m_flCrystalCoolDownTimer = GetGameTime(npc.index) + GetRandomFloat(5.0, 10.0);
		npc.m_flCrystalSpiralLaserCoolDownTimer = GetGameTime(npc.index) + GetRandomFloat(25.0, 45.0);
		npc.m_flCrystalLaserWorks = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);

		npc.m_flRevertAnim = FAR_FUTURE;
		npc.m_flFreezeAnim = FAR_FUTURE;
		npc.m_flCrystalRevert = FAR_FUTURE;
		npc.m_flGiveHyperResistances = 0.0;

		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;

		Ruina_Set_No_Retreat(npc.index);
		RemoveAllDamageAddition();

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;

		SetVariantColor(view_as<int>({255, 255, 255, 255}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		fl_nightmare_cannon_core_sound_timer[npc.index] = 0.0;
		b_Anchors_Created[npc.index] = false;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), LELOUCH_THEME);
		music.Time = 236;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "[東方自作アレンジ] Idola Deus 〜 Idoratrize World");
		strcopy(music.Artist, sizeof(music.Artist), "maritumix/まりつみ");
		Music_SetRaidMusic(music);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Lelouch Spawn");
			}
		}

		if(!b_test_mode[npc.index])	//my EARS
		{
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
			EmitSoundToAll("mvm/mvm_tele_deliver.wav", _, _, _, _, _, RUINA_NPC_PITCH);
		}	
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCFuncWin[npc.index] = view_as<Function>(Lelouch_WinLine);
		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 330.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		FreezeTimer(false);

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		//npc.m_iWearable1 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_4);
		npc.SetWeaponState(true);

		npc.m_iWingSlot =  npc.EquipItem("head", WINGS_MODELS_1);
		SetVariantInt(WINGS_LANCELOT);
		AcceptEntityInput(npc.m_iWingSlot, "SetBodyGroup");

		SetVariantInt(RUINA_FANTASY_BLADE);	//so does this actually look good with spy, no clue, if it doesn't use stage 4 rul blades
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_spy.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/spy/sept2014_lady_killer/sept2014_lady_killer.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/spy/dec2014_the_puffy_provocateur/dec2014_the_puffy_provocateur.mdl", _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/hwn2020_seared_sorcerer_style2/hwn2020_seared_sorcerer_style2.mdl", _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", "models/player/items/spy/hwn_spy_misc2.mdl", _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/spy/spy_spats.mdl", _, skin);
		npc.m_iWearable8 = npc.EquipItem("head", "models/workshop_partner/player/items/all_class/tw2_roman_wreath/tw2_roman_wreath_spy.mdl", _, skin);

		npc.m_iWearable9 = npc.EquipItemSeperate(LELOUCH_CRYSTAL_MODEL, _,_, 2.75, 50.0);

		if(IsValidEntity(npc.m_iWearable9))
		{
			SetEntityRenderMode(npc.m_iWearable9, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable9, 150, 150, 150, 100);
		}
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		npc.Anger = false;
		b_animation_set[npc.index] = false;

		Ruina_Set_Heirarchy(npc.index, RUINA_GLOBAL_NPC);	//is a global npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);
		Ruina_Set_Overlord(npc.index, true);

		i_Lelouch_Index = EntIndexToEntRef(npc.index);

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidModeTime = GetGameTime() + 400.0;

		WaveStart_SubWaveStart(GetGameTime() + 600.0);
		//this shouldnt ever start, no anti delay here.

		RaidAllowsBuildings = false;

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
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;

		RaidModeScaling *= 1.1;
		RaidModeScaling *= 0.25;

		if(b_test_mode[npc.index])
			RaidModeTime = FAR_FUTURE;

		if(Rogue_Mode())
			Rogue_Dome_WaveEnd();

		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);

		b_wonviatimer[npc.index] = false;
		Ruina_Set_Battery_Buffer(npc.index, true);
		fl_ruina_battery_max[npc.index] = 1000000.0; //so high itll never be reached.
		fl_ruina_battery[npc.index] = 0.0;

		return npc;
	}
}
static void Lelouch_WinLine(int entity)
{
	b_wonviakill[entity] = true;
	Lelouch npc = view_as<Lelouch>(entity);
	if(b_wonviatimer[npc.index])
		return;
	
	switch(GetRandomInt(0, 1))
	{
		case 0: Lelouch_Lines(npc, "트윌. 이제 넌 혼자야.");
		case 1: Lelouch_Lines(npc, "이제 너 혼자 남았어, 트윌. 저들은 실패했고.");
	}

	CPrintToChatAll("{purple}트윌{snow}: 하하, 그럼 이제 잃을 것이 없어진거네? 를르슈. 이온 공격에 우리가 가진 페타와트를 전부 다 주입해버리면 어떻게 되는지 본 적 있어?");
	Lelouch_Lines(npc, "...");

	if(Rogue_Mode())
	{
		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		CreateEarthquake(flPos, 8.0, 9999.9, 16.0, 255.0);
		CreateTimer(5.0, Timer_FadoutOffset_Global, 68, TIMER_FLAG_NO_MAPCHANGE);

		//kaboom effect
		for(float fl=0.0 ; fl < 10.0 ; fl += 0.15)
		{
			CreateTimer(fl, KaboomRogueOnlyEffect_LeLouch, 50, TIMER_FLAG_NO_MAPCHANGE);
		}
		GiveProgressDelay(12.0);
	}

	Ruina_Ion_Storm(entity);
	EmitSoundToAll(BLITZLIGHT_ATTACK);

}
static void CheckLeLouchShieldCharge(Lelouch npc)
{
	float GameTime = GetGameTime(npc.index);
	float PercentageCharge = 0.0;
	float TimeUntillTeleLeft = npc.m_flCrystalCoolDownTimer - GameTime;
	PercentageCharge = (TimeUntillTeleLeft  / (100.0));

	if(PercentageCharge <= 0.0)
		PercentageCharge = 0.0;

	if(PercentageCharge >= 1.0)
		PercentageCharge = 1.0;

	PercentageCharge -= 1.0;
	PercentageCharge *= -1.0;

	TwirlSetBatteryPercentage(npc.index, PercentageCharge);
}
static void Ruina_Ion_Storm(int iNPC)
{
	DataPack pack;
	CreateDataTimer(1.0, IonStorm_OffsetTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(iNPC));
	pack.WriteCell(EntIndexToEntRef(iNPC));

	float rng = 1.0;
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && i_NpcInternalId[entity] != TwirlFollower_ID())
		{
			rng+=0.1;

			if(GetRandomFloat(0.0,1.0) > rng)
				continue;

			DataPack loop_pack;
			CreateDataTimer(GetRandomFloat(0.0, 1.0)*rng+0.25, IonStorm_OffsetTimer, loop_pack, TIMER_FLAG_NO_MAPCHANGE);
			loop_pack.WriteCell(EntIndexToEntRef(entity));
			loop_pack.WriteCell(EntIndexToEntRef(iNPC));
			rng = 0.0;
		}
	}
	
}
static void ClotThink(int iNPC)
{
	Lelouch npc = view_as<Lelouch>(iNPC);
	
	KeepTimerFrozen();
	CheckLeLouchShieldCharge(npc);
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		b_wonviatimer[npc.index] = true;

		if(!b_wonviakill[npc.index])
		{
			switch(GetRandomInt(0, 1))
			{
				case 0: Lelouch_Lines(npc, "너무 늦었어. 종말이 다가오고 있다고...");
				case 1: Lelouch_Lines(npc, "트윌. 말해봐. 지는 편에 속해있는 기분은 어떻지?");
			}
		}

		CPrintToChatAll("{purple}트윌{snow}: 어떻냐고? 지옥에나 가라! 이 곳은 폭심지가 되어 아무도 살지 않는 땅이 될 테니!");
		Ruina_Ion_Storm(npc.index);
		EmitSoundToAll(BLITZLIGHT_ATTACK);

		if(Rogue_Mode())
		{
			float flPos[3]; // original
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			CreateEarthquake(flPos, 8.0, 9999.9, 16.0, 255.0);
			CreateTimer(5.0, Timer_FadoutOffset_Global, 68, TIMER_FLAG_NO_MAPCHANGE);

			//kaboom effect
			for(float fl=0.0 ; fl < 10.0 ; fl += 0.15)
			{
				CreateTimer(fl, KaboomRogueOnlyEffect_LeLouch, 50, TIMER_FLAG_NO_MAPCHANGE);
			}
			GiveProgressDelay(12.0);
		}

		Lelouch_Lines(npc, "그게 무슨-");

		return;
	}
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}

	if(LastMann && !b_lastman[npc.index])
	{
		b_lastman[npc.index] = true;
		switch(GetRandomInt(0, 1))
		{
			case 0: Lelouch_Lines(npc, "이제 너와 트윌 뿐이다.");
			case 1: Lelouch_Lines(npc, "관문은 거의 열렸고, 너흰 거의 다 죽었다. 정말 신나는데?");
		}
	}

	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
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

	Anchor_Phase_Logic(npc);

	npc.RangedArmour(1.0);
	npc.MeleeArmour(1.5);

	Crystal_Passive_Logic(npc);
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	Handle_Animations(npc);
	//core animations
	if(npc.m_flDoingAnimation > GameTime)
		return;

	if(Blade_Logic(npc))
		return;

	//beloved ruinian crystals.
	if(Create_Crystal_Shields(npc))
		return;

	if(Initiate_Crystal_LaserSpin(npc))
		return;

	if(Initiate_Crystal_LaserWorks(npc))
		return;

	npc.AdjustWalkCycle();

	//Ruina_Add_Battery(npc.index, 5.0);

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	/*
	if(fl_ruina_battery[npc.index]>2500.0)
	{
		if(fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			
		}
	}
	else
	{
		
	}*/
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_bAllowBackWalking = false;
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);	

	Body_Pitch(npc, Npc_Vec, vecTarget);
	
	if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*5.0)
	{
		npc.m_bAllowBackWalking = true;
		npc.FaceTowards(vecTarget, 1500.0);
	}
	else
	{
		npc.m_bAllowBackWalking = false;
	}

	Self_Defense(npc, flDistanceToTarget);

	npc.PlayIdleAlertSound();
}
static void Self_Defense(Lelouch npc, float flDistanceToTarget)
{
	float GameTime = GetGameTime(npc.index);

	//EZ
	Ruina_Self_Defense Melee;

	Melee.iNPC = npc.index;
	Melee.target = npc.m_iTarget;
	Melee.fl_distance_to_target = flDistanceToTarget;
	Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED;
	//something of note. this dmg will stack ontop of the dmg dealt by the OnMeleeSwing Trace extra thing.
	Melee.damage = Modify_Damage(-1, 25.0);
	Melee.bonus_dmg = Modify_Damage(-1, 50.0);
	Melee.attack_anim = "ACT_MP_ATTACK_STAND_MELEE";
	Melee.swing_speed = 1.2;
	Melee.swing_delay = 0.37;
	Melee.turn_speed = 20000.0;
	Melee.gameTime = GameTime;
	Melee.status = 0;
	Melee.Swing_Melee(INVALID_FUNCTION,OnMeleeSwing);

	switch(Melee.status)
	{
		case 1:	//we swung
			npc.PlayMeleeSound();
		case 2:	//we hit something
			npc.PlayMeleeHitSound();
		case 3:	//we missed
			npc.PlayMeleeMissSound();
		//0 means nothing.
	}
}

static void OnMeleeSwing(int iNPC)
{
	Lelouch npc = view_as<Lelouch>(iNPC);
	
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(100.0);
	Laser.Radius = 100.0;
	Laser.Damage = Modify_Damage(-1, 30.0);
	Laser.Bonus_Damage = 5 *Modify_Damage(-1, 30.0);
	Laser.Deal_Damage(OnMeleeLaserTraceHit);
}
static void OnMeleeLaserTraceHit(int client, int target, int damagetype, float damage)
{
	Lelouch npc = view_as<Lelouch>(client);
	Ruina_Add_Mana_Sickness(npc.index, target, 0.1, (npc.Anger ? 55 : 45), true);
	npc.PlayMeleeHitSound();

	if(AtEdictLimit(EDICT_RAID))
		return;

	float Thick_Start = GetRandomFloat(8.0, 16.0);
	float Thick_End =  GetRandomFloat(Thick_Start*0.5, Thick_Start);
	int color[4]; color = Lelouch_Colors();
	int laser = ConnectWithBeam(npc.index, target, color[0], color[1], color[2], Thick_Start, Thick_End, 2.35, BEAM_COMBINE_BLUE);
	if(IsValidEntity(laser))
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
}
//Crystal Logic
#define LELOUCH_MAX_CRYSTALS 5
enum struct Crystal_Data
{
	int index;
	int state;

	float StartLoc[3];
	float EndLoc[3];

	int Create(Lelouch npc, float Loc[3], int Health)
	{
		int Crystal = i_CreateManipulation(npc, Loc, {0.0,0.0,0.0}, LELOUCH_CRYSTAL_MODEL, Health, 3.0);
		if(!IsValidEntity(Crystal))
			return -1;

		this.state = 0;

		c_NpcName[Crystal] = "Lelouch Crystal";

		Manipulation crystal = view_as<Manipulation>(Crystal);
		crystal.m_flDoingAnimation = FAR_FUTURE;

		this.index = EntIndexToEntRef(Crystal);

		return Crystal;
	}
	bool Valid()
	{
		int Crystal = EntRefToEntIndex(this.index);
		if(!IsValidEntity(Crystal))
			return false;

		if(b_NpcHasDied[Crystal])
			return false;

		return true;
	}
	void Move(float Loc[3], float Angles[3])
	{
		if(!this.Valid())
			return;

		int Crystal = EntRefToEntIndex(this.index);

		float vecView[3], vecFwd[3], Entity_Loc[3], vecVel[3];
	
		GetEntPropVector(Crystal, Prop_Send, "m_vecOrigin", Entity_Loc);
		
		MakeVectorFromPoints(Entity_Loc, Loc, vecView);
		GetVectorAngles(vecView, vecView);
		
		float dist = GetVectorDistance(Entity_Loc, Loc);

		if(dist > 500.0)
		{
			//target location unusually far, assume it got stuck, and thus teleport to the target location.
			f_StuckOutOfBoundsCheck[Crystal] = GetGameTime() + 5.0;	//alongside that give it a bit of "noclip"
			TeleportEntity(Crystal, Loc, Angles);
			return;
		}

		GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);

		Entity_Loc[0]+=vecFwd[0] * dist;
		Entity_Loc[1]+=vecFwd[1] * dist;
		Entity_Loc[2]+=vecFwd[2] * dist;
		
		GetEntPropVector(Crystal, Prop_Send, "m_vecOrigin", vecFwd);
		
		SubtractVectors(Entity_Loc, vecFwd, vecVel);
		ScaleVector(vecVel, 10.0);

		TeleportEntity(Crystal, NULL_VECTOR, Angles, NULL_VECTOR);
		Manipulation npc = view_as<Manipulation>(Crystal);
		npc.SetVelocity(vecVel);

		ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ 5.0);

		if(npc.IsOnGround())
		{
			GetEntPropVector(Crystal, Prop_Send, "m_vecOrigin", Entity_Loc);
			Entity_Loc[2] += 50.0;
			PluginBot_Jump(npc.index, Entity_Loc);
		}
	}
	void Kill()
	{
		Kill_Manipulation(this.index);
	}
}
static Crystal_Data struct_Crystals[MAXENTITIES][LELOUCH_MAX_CRYSTALS];

static float fl_crystal_angles[MAXENTITIES];
static float fl_crystal_spin_speed[MAXENTITIES];
static bool Create_Crystal_Shields(Lelouch npc)
{
	if(b_crystals_active[npc.index])
		return false;

	if(npc.m_flCrystalCoolDownTimer > GetGameTime(npc.index))
		return false;

	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		struct_Crystals[npc.index][i].Kill();
	}
	
	int Health = ReturnEntityMaxHealth(npc.index);
	Health = RoundToFloor(float(Health)*0.06);

	npc.PlayCrystalSounds();

	fl_crystal_spin_speed[npc.index] = 0.0;

	b_crystals_active[npc.index] = true;
	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		float Angles[3];
		Angles[0] = 0.0;
		Angles[1] = 360.0/LELOUCH_MAX_CRYSTALS*i;
		Angles[2] = 0.0;
		float Origin[3]; GetAbsOrigin(npc.index, Origin); Origin[2]+=50.0;
		Get_Fake_Forward_Vec(245.0, Angles, Origin, Origin);
		
		struct_Crystals[npc.index][i].Create(npc, Origin, Health);
		struct_Crystals[npc.index][i].state = 0;
	}

	npc.m_flCrystalCoolDownTimer = GetGameTime(npc.index) + 20.0;

	float Duration = 7.0;
	Initiate_Anim(npc, Duration, "disco_fever", _,_, true, true);
	npc.m_flGiveHyperResistances = GetGameTime(npc.index) + Duration;

	npc.m_flRevertAnim = GetGameTime(npc.index) + Duration;

	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	npc.m_iSpecialEntSlot = npc.EquipItemSeperate(LELOUCH_LIGHT_MODEL ,_,_,_,300.0);

	return true;
}
#define LELOUCH_CRYSTAL_SPRIAL_WINDUP 2.5
#define LELOUCH_CRYSTAL_ATTACK_CYCLE 2.5
static void Crystal_Passive_Logic(Lelouch npc)
{
	if(!b_crystals_active[npc.index])
		return;

	float GameTime = GetGameTime(npc.index);

	npc.m_flBladeCoolDownTimer = GameTime + 60.0;
	if(fl_crystal_angles[npc.index] > 360.0)
		fl_crystal_angles[npc.index] -=360.0;
	
	fl_crystal_angles[npc.index] += fl_crystal_spin_speed[npc.index];

	int loop_for = i_Alive_Crystals(npc);
	//crystal count is 0, which means that either all the crystals have been killed, or the crystals have been deleted, either way, abort.
	if(loop_for<= 0)
	{
		Lelouch_Lines(npc, "내 절대 방벽이... 어떻게 부순거냐!");
		b_crystals_active[npc.index] = false;

		if(npc.m_flDoingAnimation > GameTime && npc.m_flCrystalRevert < GameTime)
			return;

		if(b_NpcIsInvulnerable[npc.index])
			return;
		
		float Duration = 4.0;
		Initiate_Anim(npc, Duration, "taunt_commending_clap_spy", _,_, true);

		npc.m_flGiveHyperResistances = GameTime + Duration;

		if(IsValidEntity(npc.m_iSpecialEntSlot))
			RemoveEntity(npc.m_iSpecialEntSlot);

		npc.m_flRevertAnim = GameTime + Duration;
		
		return;
	}

	if(npc.m_flCrystalRevert < GameTime)
	{
		StopCustomSound(npc.index, SNDCHAN_STATIC, g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)]);
		for(int y= 0 ; y < LELOUCH_MAX_CRYSTALS ; y++)
		{
			struct_Crystals[npc.index][y].state = 0;
		}
		Ruina_Master_Rally(npc.index, false);
		npc.m_flCrystalRevert = FAR_FUTURE;
	}

	//re order our struct into a different struct to move the ents.
	Crystal_Data total_crystals[LELOUCH_MAX_CRYSTALS];
	int crystal_loop = 0;
	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		if(struct_Crystals[npc.index][i].Valid())
		{
			total_crystals[crystal_loop] = struct_Crystals[npc.index][i];
			crystal_loop++;
		}
	}
	if(npc.m_flDoingAnimation < GameTime)
		fl_crystal_spin_speed[npc.index] = 5.0;

	int Ignore[LELOUCH_MAX_CRYSTALS];
	Zero(Ignore);
	int targeted = 0;
	for(int i=0 ; i < loop_for; i++)
	{
		Manipulation crystal = view_as<Manipulation>(EntRefToEntIndex(total_crystals[i].index));

		float Angles[3];
		Angles[0] = 0.0;
		Angles[1] = fl_crystal_angles[npc.index] + 360.0/loop_for*i;
		Angles[2] = 0.0;
		float Origin[3]; GetAbsOrigin(npc.index, Origin); Origin[2]+=50.0;
		float Offset_Loc[3];
		Get_Fake_Forward_Vec(245.0, Angles, Offset_Loc, Origin);
		float Crystal_Angles[3];
		MakeVectorFromPoints(Origin, Offset_Loc, Crystal_Angles);
		GetVectorAngles(Crystal_Angles, Crystal_Angles);
		
		int state = total_crystals[i].state;
		switch(state)
		{
			case 1:	//spin around, shoot lasers.
			{
				fl_crystal_spin_speed[npc.index] = (npc.Anger ? 5.0 : 3.0);
				
				float Radius = 25.0;

				float New_Angles[3]; New_Angles = Crystal_Angles;
				if(npc.m_flFreezeAnim > GameTime && npc.m_flFreezeAnim != FAR_FUTURE)
				{
					float Ratio = (npc.m_flFreezeAnim - GameTime) / LELOUCH_CRYSTAL_SPRIAL_WINDUP;
					float Offset_Pitch = 90.0 - 90.0 * Ratio;

					New_Angles[0] = Offset_Pitch;

					Crystal_Angles = New_Angles;

					//make a special laser pointer so players can tell its about to shoot and MURDER you!
					Ruina_Laser_Logic Laser;
					Laser.client = npc.index;
					Crystal_Angles[0]-=90.0;	//need to make it look properly up, otherwise it will go into the ground
					Laser.DoForwardTrace_Custom(Crystal_Angles, Offset_Loc, -1.0);
					Crystal_Angles[0]+=90.0;
					float Diameter = Radius*2.0;
					TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.2, Diameter*0.6, Diameter*0.6, 0, 2.5, Lelouch_Colors(), 0);
					TE_SendToAll(0.0);
				}
				else
				{
					Ruina_Laser_Logic Laser;
					Laser.client = npc.index;
					Laser.DoForwardTrace_Custom(Crystal_Angles, Offset_Loc, -1.0);
					Laser.Damage = Modify_Damage(-1, 50.0);				//how much dmg should it do?		//100.0*RaidModeScaling
					Laser.Bonus_Damage = 5.0 * Modify_Damage(-1, 50.0);			//dmg vs things that should take bonus dmg.
					Laser.damagetype = DMG_PLASMA;		//dmg type.
					Laser.Radius = Radius;				//how big the radius is / hull.
					Laser.Deal_Damage(On_LaserHit_OverflowMana);

					float Diameter = Radius*2.0;
					float Start1 = ClampBeamWidth(GetRandomFloat(Diameter*0.5, Diameter*1.5));
					float End = ClampBeamWidth(GetRandomFloat(Diameter*0.25, Diameter*1.1));
					TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.2, Diameter*0.6, Diameter*0.6, 0, 2.5, Lelouch_Colors(), 0);
					TE_SendToAll(0.0);
					TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.2, Start1, End, 0, 2.5, Lelouch_Colors(), 0);
					TE_SendToAll(0.0);

					npc.PlayLaserLoopSound();

					New_Angles[0] = -90.0;
				}
				Crystal_Angles = New_Angles;
			}
			case 2:
			{
				fl_crystal_spin_speed[npc.index] = (npc.Anger ? 3.0 : 2.0);

				int Target = crystal.m_iTarget;
				float CrystalTime = GetGameTime(crystal.index);

				if(crystal.m_flGetClosestTargetTime < CrystalTime || !IsValidEnemy(crystal.index, crystal.m_iTarget))
				{
					//CPrintToChatAll("Crystal: %i",i);
					fl_AbilityOrAttack[crystal.index][0] = 0.0;
					Target = i_CrystalFindTarget(npc, Ignore);
				}
				if(Target == -3)
				{
					total_crystals[i].Move(Offset_Loc, Crystal_Angles);
					continue;
				}
				crystal.m_iTarget = Target;

				Ignore[targeted] = Target; 
				targeted++;

				if(fl_AbilityOrAttack[crystal.index][0] < CrystalTime)
				{
					crystal.m_flGetClosestTargetTime = CrystalTime + LELOUCH_CRYSTAL_ATTACK_CYCLE;
					fl_AbilityOrAttack[crystal.index][0] = CrystalTime + LELOUCH_CRYSTAL_ATTACK_CYCLE;

					float Origin_Target[3]; GetAbsOrigin(Target, Origin_Target);
					Origin_Target[2]+=35.0;
					
					float SubjectAbsVelocity[3]; GetEntPropVector(Target, Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);

					float Speed = GetVectorLength(SubjectAbsVelocity);

					float Dist_Offset = 1.5;

					if(Speed > 150.0)
					{
						float Predicted_Pos[3];

						ScaleVector(SubjectAbsVelocity, Dist_Offset);
						AddVectors(Origin_Target, SubjectAbsVelocity, Predicted_Pos);

						SetManipulationTargetVec(crystal, 1, Predicted_Pos);

						Dist_Offset *=-1.0;
						ScaleVector(SubjectAbsVelocity, Dist_Offset);
						AddVectors(Origin_Target, SubjectAbsVelocity, Predicted_Pos);

						SetManipulationTargetVec(crystal, 0, Predicted_Pos);

						//so, we have created a special "line" between where the client is standing and where they are going. 1.5 seconds in the future, and 1.5 seconds in the past.

					}
					else
					{
						float Dist_Do[3]; Dist_Do[1] =  150.0*Dist_Offset;

						float Angs[3];
						MakeVectorFromPoints(Offset_Loc, Origin_Target, Angs);
						GetVectorAngles(Angs, Angs);

						float Result[3]; Result = Origin_Target;
						Offset_Vector(Dist_Do, Angs, Result);
						SetManipulationTargetVec(crystal, 1, Result);
						Dist_Do[1] *=-1.0;
						Result = Origin_Target;
						Offset_Vector(Dist_Do, Angs, Result);
						SetManipulationTargetVec(crystal, 0, Result);

					}

					
					total_crystals[i].Move(Offset_Loc, Crystal_Angles);
					continue;
				}

				float Ratio = 1.0 - (fl_AbilityOrAttack[crystal.index][0] - CrystalTime) / LELOUCH_CRYSTAL_ATTACK_CYCLE;

				float Laser_Path[2][3];
				Laser_Path[0] = GetManipulationTargetVec(crystal, 0);
				Laser_Path[1] = GetManipulationTargetVec(crystal, 1);

				//make angles from the start of the path, to the end of the path.
				float New_Angles[3];
				MakeVectorFromPoints(Laser_Path[0], Laser_Path[1], New_Angles);
				GetVectorAngles(New_Angles, New_Angles);

				float Dist = GetVectorDistance(Laser_Path[0], Laser_Path[1]);

				float Middle_Vec[3];
				Get_Fake_Forward_Vec(Dist * Ratio, New_Angles, Middle_Vec, Laser_Path[0]);		

				if(b_test_mode[npc.index])
				{
					int color[4] = {255,0,255,255};
					TE_SetupBeamPoints(Laser_Path[0], Laser_Path[1], g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.1, 15.0, 15.0, 0, 2.5, color, 0);
					TE_SendToAll(0.0);
				}

				//now get the angle from the crystal to the middle vector, that way we can turn the crystal towards where its aiming.
				MakeVectorFromPoints(Offset_Loc, Middle_Vec, Crystal_Angles);
				GetVectorAngles(Crystal_Angles, Crystal_Angles);

				float Laser_Dist = GetVectorDistance(Offset_Loc, Middle_Vec)*1.25;
				npc.PlayLaserLoopSound();

				float Radius = 25.0;

				Ruina_Laser_Logic Laser;			//now reuse my beloved laser logic.
				Laser.client = npc.index;			//whose using the laser?
				Laser.DoForwardTrace_Custom(Crystal_Angles, Offset_Loc, Laser_Dist);
				Laser.Damage = Modify_Damage(-1, 30.0);				//how much dmg should it do?		//100.0*RaidModeScaling
				Laser.Bonus_Damage = 5.0 * Modify_Damage(-1, 30.0);			//dmg vs things that should take bonus dmg.
				Laser.damagetype = DMG_PLASMA;		//dmg type.
				Laser.Radius = 25.0;				//how big the radius is / hull.
				Laser.Deal_Damage(On_LaserHit_OverflowMana);				//and now we kill

				float Diameter = Radius*2.0;
				float Start1 = ClampBeamWidth(GetRandomFloat(Diameter*0.5, Diameter*1.5));
				float End = ClampBeamWidth(GetRandomFloat(Diameter*0.25, Diameter*1.1));
				TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.2, Diameter*0.6, Diameter*0.6, 0, 2.5, Lelouch_Colors(), 0);
				TE_SendToAll(0.0);
				TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.2, Start1, End, 0, 2.5, Lelouch_Colors(), 0);
				TE_SendToAll(0.0);

				if(IsValidClient(Target))
				{
					TE_SetupBeamPoints(Laser_Path[0], Laser_Path[1], g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.1, Diameter*0.6, Diameter*0.6, 0, 2.5, {255,0,0,255}, 0);
					TE_SendToClient(Target);
				}

				Crystal_Angles[0] -= 90.0;
			}
		}
		
		total_crystals[i].Move(Offset_Loc, Crystal_Angles);
	}

	npc.m_flCrystalCoolDownTimer = GetGameTime(npc.index) + 100.0;
}
static int i_targets_traced[50];
static void GetEntitiesForSlicers(int entity, int victim, float damage, int weapon)
{
	Lelouch npc = view_as<Lelouch>(entity);
	if(!IsValidEnemy(npc.index, victim))
		return;

	for(int i=0 ; i < sizeof(i_targets_traced) ; i++)
	{
		if(!i_targets_traced[i])
		{
			i_targets_traced[i] = victim;
			break;
		}
	}
}
static int i_CrystalFindTarget(Lelouch npc, int Ignore[LELOUCH_MAX_CRYSTALS])
{
	float Radius = 9000.0;
	Zero(i_targets_traced);
	Explode_Logic_Custom(0.0, npc.index, npc.index, 0, _, Radius, _, _, true, sizeof(i_targets_traced), false, _, GetEntitiesForSlicers);
	
	int Tmp_Target = -1;
	float Distance_Value = 999999.0;
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	for(int i=0 ; i < sizeof(i_targets_traced) ; i++)
	{
		if(!i_targets_traced[i])
			break;

		//CPrintToChatAll("New Line");

		bool valid = true;
		for(int y=0 ; y < LELOUCH_MAX_CRYSTALS ; y++)
		{
			//if(valid)
			//	CPrintToChatAll("Traced Target: %i, Ignore Target: %i", i_targets_traced[i], Ignore[y]);
			if(i_targets_traced[i] == Ignore[y])
				valid = false;
		}

		if(!valid)
			continue;

		float VecTarget[3]; WorldSpaceCenter(i_targets_traced[i], VecTarget);
		float Dist = GetVectorDistance(VecTarget, Npc_Vec);

		if(Dist > Distance_Value)
			continue;
		
		Tmp_Target = i_targets_traced[i];
		Distance_Value = Dist;
	}

	if(IsValidEnemy(npc.index, Tmp_Target))
		return Tmp_Target;
	else
		return -3;
}

static bool Initiate_Crystal_LaserSpin(Lelouch npc)
{
	//our crystals do not exist, abort.
	if(!b_crystals_active[npc.index])
		return false;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flCrystalSpiralLaserCoolDownTimer > GameTime)
		return false;

	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		struct_Crystals[npc.index][i].state = 1;
	}

	Ruina_Master_Rally(npc.index, true);

	EmitSoundToAll(LELOUCH_CRYSTAL_SPIN_SOUND_INIT, npc.index, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 75);
	
	float Duration = 10.0;
	float WindUp = LELOUCH_CRYSTAL_SPRIAL_WINDUP;
	Initiate_Anim(npc, WindUp+Duration, "taunt_the_fist_bump", _,_, true);

	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	npc.m_flRevertAnim = GameTime + Duration + WindUp;
	npc.m_flFreezeAnim = GameTime + WindUp;
	npc.m_flCrystalRevert = GameTime + Duration + WindUp;

	npc.m_flCrystalSpiralLaserCoolDownTimer = GameTime + 100.0;

	return true;

}
static bool Initiate_Crystal_LaserWorks(Lelouch npc)
{
	//our crystals do not exist, abort.
	if(!b_crystals_active[npc.index])
		return false;

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flCrystalLaserWorks > GameTime)
		return false;

	Ruina_Master_Rally(npc.index, true);

	EmitSoundToAll(LELOUCH_CRYSTAL_WORKS_SOUND_INIT, npc.index, _, SNDLEVEL_RAIDSIREN, _, RAIDBOSSBOSS_ZOMBIE_VOLUME, 75);

	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		struct_Crystals[npc.index][i].state = 2;
	}
	float Duration = 10.0;
	float WindUp = LELOUCH_CRYSTAL_SPRIAL_WINDUP;
	Initiate_Anim(npc, WindUp+Duration, "taunt_the_fist_bump", _,_, true);

	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	npc.m_flRevertAnim = GameTime + Duration + WindUp;
	npc.m_flFreezeAnim = GameTime + WindUp;
	npc.m_flCrystalRevert = GameTime + Duration + WindUp;

	npc.m_flCrystalLaserWorks = GameTime + 80.0;

	return true;
}
static int i_Alive_Crystals(Lelouch npc)
{
	int count = 0;
	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		if(struct_Crystals[npc.index][i].Valid())
			count++;
	}
	return count;
}

// Blade Logic
static int i_BladeLogic[MAXENTITIES];
static float fl_BladeLogic_Duration[2];
static float fl_BladeLogic_Timer[MAXENTITIES];
static float fl_BladeLogic_WindUp[MAXENTITIES];
static int i_BladeNPC_Ref[MAXENTITIES];
static bool b_Invert;
static bool Blade_Logic(Lelouch npc)
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flBladeCoolDownTimer > GameTime)
		return false;
	
	int Forward = i_FindTargetsInfront(npc, 700.0, 50.0);
	int Around = Nearby_Players(npc, 350.0);

	i_BladeLogic[npc.index] = -1;

	if((Forward <= 2 && Around <= 2) && !b_test_mode[npc.index])
	{
		npc.m_flBladeCoolDownTimer = GameTime + 5.0;
		return false;
	}

	//base settings incase somehow they don't get set properly.
	float WindUp = 1.0;
	float Time = 2.0;
	float Recharge = 120.0;
	//to configure them, scroll down.

	int Blade_NPC = -1;

	//Around = 99;

	if(Forward > Around)
	{
		//do giant sword swing forward.
		float Angles[3]; Angles = GetNPCAngles(npc.index);
		int Health = ReturnEntityMaxHealth(npc.index);
		Health = RoundToFloor(Health*0.025);
		float Loc[3]; GetAbsOrigin(npc.index, Loc); 
		Loc[2]+=150.0;	//make it spawn a bit up 
		Angles[0] = 90.0;	//make it pitched.
		Angles[2] = 90.0;	//turn it sideways.
		Blade_NPC = i_CreateManipulation(npc, Loc, Angles, LELOUCH_BLADE_MODEL, Health, 4.5);

		WindUp = 2.5;
		Time = 2.0;
		i_BladeLogic[npc.index] = 0;

		Recharge = 80.0;
	}
	else
	{
		// do giant sword spin.
		i_BladeLogic[npc.index] = 1;
		Recharge = 100.0;

		if(GetRandomInt(1,2) == 1)
			b_Invert = true;
		else
			b_Invert = false;

		float Angles[3]; Angles = GetNPCAngles(npc.index);	Angles[0] = 0.0;	//nullify pitch.
		int Health = ReturnEntityMaxHealth(npc.index);
		Health = RoundToFloor(Health*0.025);
		float Loc[3]; GetAbsOrigin(npc.index, Loc); Loc[2]+=25.0;
		Get_Fake_Forward_Vec(150.0, Angles, Loc, Loc);
		Angles[1]+=180.0;
		Blade_NPC = i_CreateManipulation(npc, Loc, Angles, LELOUCH_BLADE_MODEL, Health, 4.5);

		WindUp = 2.5;
		Time = 5.0;
	}
	//invalid blade npc. retry.
	if(!IsValidAlly(npc.index, Blade_NPC))
	{
		npc.m_flBladeCoolDownTimer = GameTime + 5.0;
		return false;
	}

	//MakeObjectIntangeable(Blade_NPC);

	Manipulation blade = view_as<Manipulation>(Blade_NPC);

	blade.m_iTeamGlow = TF2_CreateGlow(blade.index);
	blade.m_bTeamGlowDefault = false;

	SetVariantColor(view_as<int>({255, 255, 255, 255}));
	AcceptEntityInput(blade.m_iTeamGlow, "SetGlowColor");

	b_animation_set[npc.index] = false;

	fl_BladeLogic_Duration[i_BladeLogic[npc.index]] = Time;

	Initiate_Anim(npc, WindUp+Time+0.1, "taunt_highFiveStart", _,_, true);

	c_NpcName[blade.index] = "Lelouch Blade";

	fl_BladeLogic_Timer[npc.index] = GameTime + WindUp + Time;
	fl_BladeLogic_WindUp[npc.index] = GameTime + WindUp;

	blade.m_flDoingAnimation = FAR_FUTURE;

	i_BladeNPC_Ref[npc.index] = EntIndexToEntRef(blade.index);

	SDKUnhook(npc.index, SDKHook_Think, BladeLogic_Tick);
	SDKHook(npc.index, SDKHook_Think, BladeLogic_Tick);

	npc.m_flBladeCoolDownTimer = GameTime + Recharge;
	return true;
}
static void BladeLogic_Tick(int iNPC)
{
	Lelouch npc = view_as<Lelouch>(iNPC);

	float GameTime = GetGameTime(npc.index);
	if(fl_BladeLogic_Timer[npc.index] < GameTime || b_NpcHasDied[npc.index])
	{
		Kill_Manipulation(i_BladeNPC_Ref[npc.index]);
		SDKUnhook(npc.index, SDKHook_Think, BladeLogic_Tick);
		End_Animation(npc);
		return;
	}
	if(fl_BladeLogic_WindUp[npc.index] > GameTime)
		return;
	if(!b_animation_set[npc.index])
	{
		npc.SetPlaybackRate(0.0);
		b_animation_set[npc.index] = true;
	}
	int Blade_NPC = EntRefToEntIndex(i_BladeNPC_Ref[npc.index]);
	//somehow the blade npc is no longer on our team. it has died. or we canceled/is invalid blade logic
	bool death = b_NpcHasDied[Blade_NPC];
	if(death)
	{
		//temp line for testing.
		Lelouch_Lines(npc, "감히 내 검을 부수다니!");
	}
	if(!IsValidAlly(npc.index, Blade_NPC) || death || i_BladeLogic[npc.index] == -1)
	{
		SDKUnhook(npc.index, SDKHook_Think, BladeLogic_Tick);
		Kill_Manipulation(i_BladeNPC_Ref[npc.index]);
		//prematurly end the animation.
		End_Animation(npc);
		return;
	}
	//get the ratio between the start of the ability to the end of ability, and then scale upcoming stuff in relation to the ratio.
	float Ratio = (fl_BladeLogic_Timer[npc.index]-GameTime) / fl_BladeLogic_Duration[i_BladeLogic[npc.index]];
	switch(i_BladeLogic[npc.index])
	{
		case 0:
		{
			float Blade_Origin[3]; GetAbsOrigin(npc.index, Blade_Origin);
			Blade_Origin[2] +=25.0;	//don't make it do everything inside the ground.
			//-90 is straight up.
			//90 is straight down.
			float Angle_Ratio = -90.0*Ratio;
			//so we want to get the angles of the HOST npc, not the blade, just incase the blade npc decides it wants to turn for some god awful reason!
			float Blade_Angles[3]; Blade_Angles = GetNPCAngles(npc.index); Blade_Angles[0] = Angle_Ratio;
			float Final_Vec[3];
			//now offset the blade's location from origin to where the blade wants to be. respecting angles and such.
			Get_Fake_Forward_Vec(150.0, Blade_Angles, Final_Vec, Blade_Origin);
			Blade_Angles[0] += 180.0;	//make it pitched.
			Blade_Angles[2] += 90.0;	//turn it sideways.
			TeleportEntity(Blade_NPC, Final_Vec, Blade_Angles);

			//now that all the movement logic is done. now the damage logic.
			//First, undo the offset angle logic.
			Blade_Angles[0] -= 180.0;
			Blade_Angles[2] -= 90.0;
			//second, get an offset vector from the offset, this time trying to get to the end of the blade.
			float Blade_EndVec[3];
			Get_Fake_Forward_Vec(300.0, Blade_Angles, Blade_EndVec, Final_Vec);	
			//oh yeah, it is safe to use the input/output as the same variable. however, we want to store the input vector so we can reuse it.

			//now we make a TE to tell us if our vector is in the correct position!
			if(b_test_mode[npc.index])
			{
				int color[4]; color = {255,255,255,255};
				TE_SetupBeamPoints(Blade_EndVec, Final_Vec, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.1, 15.0, 15.0, 0, 2.5, color, 0);
				TE_SendToAll(0.0);
			}
			//300.0 was my first guess and it turns out to be perfect.
			Ruina_Laser_Logic Laser;			//now reuse my beloved laser logic.
			Laser.client = npc.index;			//whose using the laser?
			Laser.Start_Point = Blade_EndVec;	//where does the laser start?
			Laser.End_Point = Final_Vec;		//where does the laser end?
			Laser.Damage = Modify_Damage(-1, 5.0);				//how much dmg should it do?		//100.0*RaidModeScaling
			Laser.Bonus_Damage = 5.0 * Modify_Damage(-1, 5.0);			//dmg vs things that should take bonus dmg.
			Laser.damagetype = DMG_PLASMA;		//dmg type.
			Laser.Radius = 25.0;				//how big the radius is / hull.
			Laser.Deal_Damage(On_LaserHit_OverflowMana);				//and now we kill
		}
		case 1:
		{
			float Blade_Origin[3]; GetAbsOrigin(npc.index, Blade_Origin);
			Blade_Origin[2] +=25.0;	//don't make it do everything inside the ground.
			
			//we want it to spin 3 times around the npc
			float Spin_Angle = (360.0*3.0)*(b_Invert ? 1.0-Ratio : Ratio);

			float Blade_Angles[3]; Blade_Angles = GetNPCAngles(npc.index); Blade_Angles[0] = 0.0;	//nullify pitch.
			Blade_Angles[1] += Spin_Angle;
			Get_Fake_Forward_Vec(150.0, Blade_Angles, Blade_Origin, Blade_Origin);
			Blade_Angles[1]+=180.0;
			TeleportEntity(Blade_NPC, Blade_Origin, Blade_Angles);

			//now that all the movement logic is done. now the damage logic.
			//First, undo the offset angle logic.
			Blade_Angles[1] -= 180.0;
			//second, get an offset vector from the offset, this time trying to get to the end of the blade.
			float Blade_EndVec[3];
			Get_Fake_Forward_Vec(300.0, Blade_Angles, Blade_EndVec, Blade_Origin);	
			//oh yeah, it is safe to use the input/output as the same variable. however, we want to store the input vector so we can reuse it.

			//now we make a TE to tell us if our vector is in the correct position!
			if(b_test_mode[npc.index])
			{
				int color[4]; color = {255,255,255,255};
				TE_SetupBeamPoints(Blade_EndVec, Blade_Origin, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.1, 15.0, 15.0, 0, 2.5, color, 0);
				TE_SendToAll(0.0);
			}
			//300.0 was my first guess and it turns out to be perfect.
			Ruina_Laser_Logic Laser;			//now reuse my beloved laser logic.
			Laser.client = npc.index;			//whose using the laser?
			Laser.Start_Point = Blade_EndVec;	//where does the laser start?
			Laser.End_Point = Blade_Origin;		//where does the laser end?
			Laser.Damage = Modify_Damage(-1, 2.5);				//how much dmg should it do?		//100.0*RaidModeScaling
			Laser.Bonus_Damage = 5.0 * Modify_Damage(-1, 2.5);			//dmg vs things that should take bonus dmg.
			Laser.damagetype = DMG_PLASMA;		//dmg type.
			Laser.Radius = 25.0;				//how big the radius is / hull.
			Laser.Deal_Damage(On_LaserHit_OverflowMana);				//and now we kill

		}
		default:
		{
			CPrintToChatAll("INVALID BLADE LOGIC, CANCELING | [%i]", i_BladeLogic[npc.index]);
			i_BladeLogic[npc.index] = -1;
		}
	}
}

//Anchor Logic
#define LELOUCH_ANCHOR_STAGE_TIMER 120.0 //120.0
enum struct Anchor_Lifeloss_Data
{
	int particles[4];
	int lasers[4];

	//flaregun_energyfield_red
	//flaregun_energyfield_blue

	void Nuke()
	{
		for(int i=0 ; i <sizeof(this.particles); i++)
		{
			int part = EntRefToEntIndex(this.particles[i]);
			if(IsValidEntity(part))
				RemoveEntity(part);

			this.particles[i] = INVALID_ENT_REFERENCE;
		}
		for(int i=0 ; i <sizeof(this.lasers); i++)
		{
			int part = EntRefToEntIndex(this.lasers[i]);
			if(IsValidEntity(part))
				RemoveEntity(part);

			this.lasers[i] = INVALID_ENT_REFERENCE;
		}
	}
}
static Anchor_Lifeloss_Data struct_Anchors_Effects[MAXENTITIES];
static void Create_Anchor_Phase_Effects(Lelouch npc)
{
	struct_Anchors_Effects[npc.index].Nuke();

	int ent1 = npc.Set_Particle("flaregun_energyfield_red", "effect_hand_r");
	int ent2 = npc.Set_Particle("flaregun_energyfield_blue", "effect_hand_l");
	struct_Anchors_Effects[npc.index].particles[0] = EntIndexToEntRef(ent1);
	struct_Anchors_Effects[npc.index].particles[1] = EntIndexToEntRef(ent2);
	
	float Loc1[3], Loc2[3];
	float Angles[3], Origin[3]; WorldSpaceCenter(npc.index, Origin); Angles = GetNPCAngles(npc.index);
	Loc1 = Origin;
	Loc2 = Origin;
	Offset_Vector({0.0, -50.0, 255.0}, Angles, Loc1);
	Offset_Vector({0.0, 50.0, 255.0}, Angles, Loc2);

	int color[4]; color = Lelouch_Colors();

	int laser1 = ConnectWithBeam(ent1, -1, color[0], color[1], color[2], 5.0, 5.0, 1.0, LASERBEAM, _, Loc1);
	int laser2 = ConnectWithBeam(ent2, -1, color[0], color[1], color[2], 5.0, 5.0, 1.0, LASERBEAM, _, Loc2);

	float Middle_Vec[3]; Middle_Vec = Loc1;
	Middle_Vec[0] += Loc2[0];
	Middle_Vec[1] += Loc2[1];
	Middle_Vec[2] += Loc2[2];

	Middle_Vec[0] /=2.0;
	Middle_Vec[1] /=2.0;
	Middle_Vec[2] /=2.0;

	Middle_Vec[2]+=125.0;

	int laser3 = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 1.0, LASERBEAM, Loc1, Middle_Vec);
	int laser4 = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 5.0, 5.0, 1.0, LASERBEAM, Loc2, Middle_Vec);

	struct_Anchors_Effects[npc.index].lasers[0] = EntIndexToEntRef(laser1);
	struct_Anchors_Effects[npc.index].lasers[1] = EntIndexToEntRef(laser2);
	struct_Anchors_Effects[npc.index].lasers[2] = EntIndexToEntRef(laser3);
	struct_Anchors_Effects[npc.index].lasers[3] = EntIndexToEntRef(laser4);

	int ent3 = ParticleEffectAt(Middle_Vec, "flaregun_energyfield_red", 0.0);
	int ent4 = ParticleEffectAt(Middle_Vec, "flaregun_energyfield_blue", 0.0);
	struct_Anchors_Effects[npc.index].particles[2] = EntIndexToEntRef(ent3);
	struct_Anchors_Effects[npc.index].particles[3] = EntIndexToEntRef(ent4);


}
static void Create_Anchors(Lelouch npc)
{
	if(b_Anchors_Created[npc.index])
		return;

	int MaxHealth = ReturnEntityMaxHealth(npc.index);
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float Ratio = float(Health) / float(MaxHealth);

	if(Ratio > 0.8)
		return;
	
	b_Anchors_Created[npc.index] = true;

	b_NpcIsInvulnerable[npc.index] = true;

	fl_Anchor_Logic[npc.index] = GetGameTime() + LELOUCH_ANCHOR_STAGE_TIMER;

	fl_RaidModeScaling_Buffer = RaidModeScaling;

	RaidModeScaling = 0.0;

	b_Anchors_Red = false;
	b_DeathRay = false;
	b_Standard_Anchor = false;

	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	End_Animation(npc);

	npc.m_flCrystalRevert = FAR_FUTURE;
	StopCustomSound(npc.index, SNDCHAN_STATIC, g_LaserLoop[GetRandomInt(0, sizeof(g_LaserLoop) - 1)]);
	for(int y= 0 ; y < LELOUCH_MAX_CRYSTALS ; y++)
	{
		struct_Crystals[npc.index][y].state = 0;
	}
	fl_crystal_spin_speed[npc.index] = 5.0;
	i_BladeLogic[npc.index] = -1;

	float GameTime = GetGameTime(npc.index);
	Initiate_Anim(npc, FAR_FUTURE, "taunt_curtain_call", _,_, true);
	npc.m_flFreezeAnim = GameTime + 4.0;

	EmitSoundToAll(VENIUM_SPAWN_SOUND, _, _, _, _, 1.0);
	EmitSoundToAll(VENIUM_SPAWN_SOUND, _, _, _, _, 1.0);

	for(int i=0 ; i < 3 ; i++)
	{
		int anchor = i_CreateAnchor(npc, i);
		if(IsValidEntity(anchor))
			i_AnchorID_Ref[npc.index][i] = EntIndexToEntRef(anchor); 
	}

	float HP_Scale = 1.0;

	// we aren't in rogue, nerf summon health
	// freeplay lelouch is lolmao
	if(!Rogue_Mode())
	{
		float amount_of_people = ZRStocks_PlayerScalingDynamic();

		HP_Scale = amount_of_people/14.0;

		//for when the server has more then 14 players.
		if(HP_Scale >1.0)
			HP_Scale = 1.0;

		//lower limit.
		if(HP_Scale <=0.1)
			HP_Scale=0.1;

		HP_Scale *=0.5;	//then nerf it in half completely.

	}


	LelouchSpawnEnemy(npc.index,"npc_ruina_theocracy",	RoundToCeil(HP_Scale * 400000.0 * MultiGlobalHealthBoss), RoundToCeil(1.0 * MultiGlobalEnemy), true);
	LelouchSpawnEnemy(npc.index,"npc_ruina_lex"	,		RoundToCeil(HP_Scale * 205000.0 * MultiGlobalHealthBoss), RoundToCeil(1.0 * MultiGlobalEnemy), true);
	LelouchSpawnEnemy(npc.index,"npc_ruina_ruliana",	RoundToCeil(HP_Scale * 652569.0 * MultiGlobalHighHealthBoss),1, true);
	LelouchSpawnEnemy(npc.index,"npc_ruina_lancelot",	RoundToCeil(HP_Scale * 600000.0 * MultiGlobalHealthBoss), RoundToCeil(1.0 * MultiGlobalEnemy), true);

	LelouchSpawnEnemy(npc.index,"npc_ruina_loonarionus",RoundToCeil(HP_Scale * 200000), RoundToCeil(4.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_magianius",	RoundToCeil(HP_Scale * 100000), RoundToCeil(6.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_heliarionus",RoundToCeil(HP_Scale * 500000), RoundToCeil(2.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_euranionis",	RoundToCeil(HP_Scale * 100000), RoundToCeil(5.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_draconia",	RoundToCeil(HP_Scale * 200000), RoundToCeil(8.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_malianius",	RoundToCeil(HP_Scale * 100000), RoundToCeil(4.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_lazurus",	RoundToCeil(HP_Scale * 150000), RoundToCeil(2.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_aetherianus",RoundToCeil(HP_Scale * 75000),  RoundToCeil(20.0 * MultiGlobalEnemy));
	LelouchSpawnEnemy(npc.index,"npc_ruina_rulianius",	RoundToCeil(HP_Scale * 300000), RoundToCeil(2.0 * MultiGlobalEnemy), _,"Elite Rulianius");
	LelouchSpawnEnemy(npc.index,"npc_ruina_astrianious",RoundToCeil(HP_Scale * 100000), RoundToCeil(4.0 * MultiGlobalEnemy));

	Ruina_Master_Rally(npc.index, false);

	//400-500k for melee enemies

	/*
	npc_ruina_magianius    6000
	npc_ruina_loonarionus  7500
	npc_ruina_heliarionus  6000
	npc_ruina_euranionis   8000
	npc_ruina_draconia     9000
	npc_ruina_malianius    12500
	npc_ruina_lazurus      8000
	npc_ruina_aetherianus  9000
	npc_ruina_rulianius    30000
	npc_ruina_astrianious  20000
	*/

	Create_Anchor_Phase_Effects(npc);

	FreezeTimer(true);
}
static int i_CreateAnchor(Lelouch npc, int loop, bool red = false)
{
	int MaxHealth = ReturnEntityMaxHealth(npc.index);
	float Tower_Health = MaxHealth*0.25;

	
	float AproxRandomSpaceToWalkTo[3];
	WorldSpaceCenter(npc.index, AproxRandomSpaceToWalkTo);
	// do not spawn ontop of lelouches head, although it shouldn't matter for spawning stuff, just incase the teleport SOMEHOW fails
	AproxRandomSpaceToWalkTo[0]+=GetRandomFloat(GetRandomFloat(-250.0, -50.0), GetRandomFloat(50.0, 250.0));
	AproxRandomSpaceToWalkTo[1]+=GetRandomFloat(GetRandomFloat(-250.0, -50.0), GetRandomFloat(50.0, 250.0));
	char Data[64]; Data = red ? "lelouch;nospawns;noweaver;full" : "nospawns;noweaver;full";
	if(Waves_GetRoundScale()+1 < 40)
		Format(Data, sizeof(Data), "%sforce40", Data);	//this way if somehow they are spawned before wave 60, they will have the proper wave logic.
	int spawn_index = NPC_CreateByName("npc_ruina_magia_anchor", npc.index, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, red ? TFTeam_Red : GetTeam(npc.index), Data);
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		if(GetTeam(spawn_index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		else
		{
			b_ThisEntityIgnored[spawn_index] = true;
		}
		if(Rogue_Mode())
			TeleportEntity(spawn_index, fl_Anchor_Fixed_Spawn_Pos[loop]);
		else
			TeleportDiversioToRandLocation(spawn_index, true, 5000.0, 125.0);

		SetEntProp(spawn_index, Prop_Data, "m_iHealth", RoundToCeil(Tower_Health));
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", RoundToCeil(Tower_Health));
	}
	return spawn_index;
}
static void Equalize_Anchor_Hp(Lelouch npc)
{
	int Total_Hp = 0;

	int active = 0;
	for(int i=0 ; i < 3 ; i++)
	{
		int Anchor = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
		if(IsValidEntity(Anchor))
		{
			Total_Hp +=GetEntProp(Anchor, Prop_Data, "m_iHealth");
			active++;
		}	
	}
	if(Total_Hp <=0 || active == 0)
		return;
	Total_Hp = RoundToCeil(float(Total_Hp)/float(active));
	for(int i=0 ; i < 3 ; i++)
	{
		int Anchor = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
		if(IsValidEntity(Anchor))
		{
			SetEntProp(Anchor, Prop_Data, "m_iHealth", Total_Hp);
		}	
	}
}
//okay so, the code you will see here relating to the anchors is arguably THE MOST AIDS CODES I HAVE EVER CREATED.
//only god knows how it actually works
//I pray for whoever has to optimise or clean this code up in the future. good luck soldier.
static float fl_DeathRayLoc[3];
static void Anchor_Phase_Logic(Lelouch npc)
{
	//no anchors? begone.
	if(!b_Anchors_Created[npc.index])
		return;

	int Anchors_Active = 0;
	for(int i=0 ; i < 3 ; i++)
	{
		int Anchor = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
		if(IsValidEntity(Anchor))
		{
			Anchors_Active++;

			if(fl_Anchor_Logic[npc.index] != FAR_FUTURE)
			{
				float loc[3]; GetAbsOrigin(Anchor, loc);
				fl_DeathRayLoc = loc;
			}	
		}	
	}
	if(Anchors_Active == 0 && b_Anchors_Red)
		return;

	if(b_DeathRay)
	{
		if(Anchors_Active == 3)
		{
			DeathRay_Logic(npc);
		}
		else
		{
			b_DeathRay = false;
			b_Standard_Anchor = true;
		}
	}
	if(b_Standard_Anchor)
	{

	}

	if(fl_Anchor_Logic[npc.index] == FAR_FUTURE)
		return;
	
	if(fl_Anchor_Logic[npc.index] > GetGameTime())
	{
		RaidModeScaling =1.0-(fl_Anchor_Logic[npc.index] - GetGameTime())/LELOUCH_ANCHOR_STAGE_TIMER;
		if(Anchors_Active <= 0 && !b_Anchors_Red)
		{
			End_Animation(npc);
			npc.m_flDoingAnimation = 0.0;

			switch(GetRandomInt(0,1))
			{
				case 0: Lelouch_Lines(npc, "저렇게 빠른 시간 내에 앵커를 전부 처리하다니...");
				case 1: Lelouch_Lines(npc, "내 앵커! 이 자식들이!");
			}
			
			switch(GetRandomInt(0,1))
			{
				case 0: CPrintToChatAll("{purple}트윌{snow}: 네 모든 앵커는 이제 내 거야..!");
				case 1: CPrintToChatAll("{purple}트윌{snow}: 네 앵커는 내가 파괴해버렸단다~");
			}
			

			b_Anchors_Red = true;

			RaidModeScaling = fl_RaidModeScaling_Buffer;

			struct_Anchors_Effects[npc.index].Nuke();
			b_NpcIsInvulnerable[npc.index] = false;
			b_DeathRay = true;

			for(int i=0 ; i < 3 ; i++)
			{
				int Anchor = i_CreateAnchor(npc,i, true);
				if(IsValidEntity(Anchor))
					i_AnchorID_Ref[npc.index][i] = Anchor;
			}
			FreezeTimer(false);
			fl_Anchor_Logic[npc.index] = FAR_FUTURE;
		}
		
		return;
	}
	else
	{
		//players ran out of time, now do special stuff.
		if(Anchors_Active == 3)
		{
			End_Animation(npc);
			npc.m_flDoingAnimation = 0.0;

			Lelouch_Lines(npc, "받아라, 트라이 앵커 레이저의 힘을!");

			b_Anchors_Red = false;

			b_DeathRay = true;
		}
		else
		{

			b_Standard_Anchor = true;

			End_Animation(npc);
			npc.m_flDoingAnimation = 0.0;

			switch(GetRandomInt(0,1))
			{
				case 0: Lelouch_Lines(npc, "넌 정해진 네 파멸의 운명을 피하는데 성공했어. 잘 했네.");
				case 1: Lelouch_Lines(npc, "그래. 거의 해냈군. 칭찬해주마. *박수");
			}

			CPrintToChatAll("{purple}트윌{snow}: 뭐, 적어도 쟤가 쏘는 죽음의 광선을 더 이상 두려워할 필요는 없게 됐네.");
		}
		RaidModeScaling = fl_RaidModeScaling_Buffer;
		FreezeTimer(false);
		Equalize_Anchor_Hp(npc);
		struct_Anchors_Effects[npc.index].Nuke();
		b_NpcIsInvulnerable[npc.index] = false;
	}

	fl_Anchor_Logic[npc.index] = FAR_FUTURE;
}
static int i_GetTarget_Lazy_Method(float end_point[3], int Team)
{
	float Radius = 999999.0*9999999.0;
	int valid_target = -1;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(view_as<CClotBody>(client).m_bThisEntityIgnored)
			continue;
		
		if(!IsClientInGame(client))
		 	continue;	

		if(!IsEntityAlive(client))
			continue;
		
		if(GetTeam(client) == Team)
			continue;
		
		float Vic_Pos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

		float Dist = GetVectorDistance(Vic_Pos, end_point, true);
		if(Dist > Radius)
			continue;

		valid_target = client;
		Radius = Dist;
	}
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == Team)
				continue;

			float Vic_Pos[3];
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

			float Dist = GetVectorDistance(Vic_Pos, end_point, true);
			if(Dist > Radius)
				continue;

			valid_target = entity;
			Radius = Dist;
		}
	}

	//as far as I am aware, non-red buildings do not exist.
	if(Team == TFTeam_Red)
		return valid_target;

	for(int a; a < i_MaxcountBuilding; a++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[a]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				float Vic_Pos[3];
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Vic_Pos);

				if(GetVectorDistance(Vic_Pos, end_point, true) > Radius)
					continue;

				float Dist = GetVectorDistance(Vic_Pos, end_point, true);
				if(Dist > Radius)
					continue;

				valid_target = entity;
				Radius = Dist;
			}
		}
	}
	return valid_target;
}
static void DeathRay_Logic(Lelouch npc)
{
	int Anchor = -1;

	float Origin[3];

	if(Rogue_Mode())
	{
		Origin = {8727.020508, -121.295174, -3100.386963};
		for(int i= 0 ; i < 3 ; i++)
		{
			int Slave = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
			if(!IsValidEntity(Slave))
			{
				return;
			}
			Anchor = Slave;
		}
	}
	else
	{
		for(int i= 0 ; i < 3 ; i++)
		{
			int Slave = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
			if(!IsValidEntity(Slave))
			{
				//something went horribly wrong.
				return;
			}
			float SlaveVec[3]; GetAbsOrigin(Slave, SlaveVec);
			Origin[0]+=SlaveVec[0];
			Origin[1]+=SlaveVec[1];
			Origin[2]+=SlaveVec[2];

			Anchor = Slave;
		}

		Origin[0] /=3.0;
		Origin[1] /=3.0;
		Origin[2] /=3.0;

		Origin[2]+=200.0;
	}

	float TE_Duration =0.1;

	TE_SetupGlowSprite(Origin, (b_Anchors_Red ? g_Ruina_Glow_Red : g_Ruina_Glow_Blue), TE_Duration, 3.0, 255);
	TE_SendToAll();

	//something MAJOR has gone wrong.
	if(!IsValidEntity(Anchor))
		return;
	
	int Tmp_Target = i_GetTarget_Lazy_Method(Origin, (b_Anchors_Red ? TFTeam_Red : GetTeam(npc.index)));

	if(!IsValidEntity(Tmp_Target))
		return;

	float Target_Angles[3], Beam_Angles[3], Target_Loc[3];
	GetAbsOrigin(Tmp_Target, Target_Loc); Target_Loc[2]+=50.0;
	MakeVectorFromPoints(fl_DeathRayLoc, Target_Loc, Target_Angles);
	GetVectorAngles(Target_Angles, Target_Angles);

	//speed of the death ray
	Get_Fake_Forward_Vec(20.0, Target_Angles, fl_DeathRayLoc, fl_DeathRayLoc);

	MakeVectorFromPoints(Origin, fl_DeathRayLoc, Beam_Angles);
	GetVectorAngles(Beam_Angles, Beam_Angles);

	Ruina_Laser_Logic Laser;			//now reuse my beloved laser logic.
	Laser.client = Anchor;			//whose using the laser?
	Get_Fake_Forward_Vec(2500.0, Beam_Angles, Target_Loc, fl_DeathRayLoc);
	Laser.Start_Point = Origin;
	Laser.End_Point = Target_Loc;
	Laser.Damage = Modify_Damage(-1, 30.0);				//how much dmg should it do?		//100.0*RaidModeScaling
	Laser.Bonus_Damage = Modify_Damage(-1, 30.0);			//dmg vs things that should take bonus dmg.
	Laser.damagetype = DMG_PLASMA;		//dmg type.
	Laser.Radius = 25.0;				//how big the radius is / hull.
	Laser.Deal_Damage((b_Anchors_Red ? INVALID_FUNCTION : On_LaserHit_OverflowMana));

	int color[4]; color = Lelouch_Colors();
	if(b_Anchors_Red)
		color = {255, 25,25,255};

	float Diameter = Laser.Radius*2.0;
	float Start1 = ClampBeamWidth(GetRandomFloat(Diameter*0.5, Diameter*1.5));
	float End = ClampBeamWidth(GetRandomFloat(Diameter*0.25, Diameter*1.1));
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Laser, g_Ruina_BEAM_Laser, 0, 0, 0.2, Diameter*0.6, Diameter*0.6, 0, 2.5, color, 0);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Laser.Start_Point, Laser.End_Point, g_Ruina_BEAM_Combine_Blue, 0, 0, 0, 0.2, Start1, End, 0, 2.5, color, 0);
	TE_SendToAll(0.0);

	
}


//Usefull stuff.
static float fl_timer_offset;
static void FreezeTimer(bool state)
{
	if(state)
		fl_timer_offset = RaidModeTime-GetGameTime();
	else
		fl_timer_offset = -1.69;
}
static void KeepTimerFrozen()
{
	if(fl_timer_offset == -1.69)
		return;
	
	RaidModeTime = GetGameTime() + fl_timer_offset;
}

static void On_LaserHit_OverflowMana(int client, int target, int damagetype, float damage)
{
	Lelouch npc = view_as<Lelouch>(client);
	Ruina_Add_Mana_Sickness(npc.index, target, 0.1, (npc.Anger ? 55 : 45), true);
}
static int[] Lelouch_Colors()
{
	int color[4] = {255,255,255,255};
	return color;
}

static void Handle_Animations(Lelouch npc)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flFreezeAnim < GameTime)
	{
		npc.m_flFreezeAnim = FAR_FUTURE;
		npc.SetPlaybackRate(0.0);
	}
	if(npc.m_flRevertAnim > GameTime)
		return;

	npc.m_flRevertAnim = FAR_FUTURE;

	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	End_Animation(npc);
}
static void Kill_Manipulation(int Manip_Ref)
{
	int Manip_NPC = EntRefToEntIndex(Manip_Ref);
	if(!IsValidEntity(Manip_NPC))
		return;
	
	Manipulation npc = view_as<Manipulation>(Manip_NPC);
	npc.m_iState = -1;	//this tells the npc to nuke itself.
}

static int i_targets_found;
static int i_FindTargetsInfront(Lelouch npc, float Dist, float Radius)
{
	Ruina_Laser_Logic Laser;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(Dist);
	Laser.Radius = Radius;
	i_targets_found = 0;
	Laser.Detect_Entities(FindTargets_OnLaserHit);
	return i_targets_found;
}
static int Nearby_Players(Lelouch npc, float Radius)
{
	i_targets_found = 0;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);
	return i_targets_found;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_found++;
}
static void FindTargets_OnLaserHit(int client, int target, int damagetype, float damage)
{
	i_targets_found++;
}
static float[] GetNPCAngles(int entity)
{
	CClotBody npc = view_as<CClotBody>(entity);
	float Angles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	int iPitch = npc.LookupPoseParameter("body_pitch");
			
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	Angles[0] = flPitch;

	return Angles;
}
static bool b_Buffs;
static void Initiate_Anim(Lelouch npc, float time, char[] Anim = "", float Rate = 1.0, float Cycle = 0.0, bool immune = false, bool donthide = false)
{
	npc.m_flDoingAnimation = GetGameTime(npc.index) + time;

	npc.StopPathing();
	
	npc.m_flGetClosestTargetTime = 0.0;
	npc.m_flSpeed = 0.0;
	npc.m_iChanged_WalkCycle  = -1;

	if(Anim[0])
	{
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence(Anim);
		npc.SetPlaybackRate(Rate);
		npc.SetCycle(Cycle);
	}

	if(!donthide)
		npc.SetWeaponState(false);

	//make sure the npc is 100% not moving anymore!
	npc.SetVelocity({0.0,0.0,0.0});
	b_Buffs = false;
	if(!immune)
		return;

	b_Buffs = true;
	ApplyStatusEffect(npc.index, npc.index, "Clear Head", time);	
	ApplyStatusEffect(npc.index, npc.index, "Solid Stance", time);	
	ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", time);	
}
static void End_Animation(Lelouch npc)
{
	npc.m_flDoingAnimation = 0.0;
	npc.m_flSpeed = fl_npc_basespeed;

	npc.m_flFreezeAnim = FAR_FUTURE;
	npc.m_flRevertAnim = FAR_FUTURE;

	int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
	if(iActivity > 0) npc.StartActivity(iActivity);

	npc.m_iChanged_WalkCycle = 1;

	npc.m_bisWalking = true;

	npc.SetWeaponState(true);

	if(!b_Buffs)
		return;

	b_Buffs = false;

	RemoveSpecificBuff(npc.index, "Clear Head");
	RemoveSpecificBuff(npc.index, "Solid Stance");
	RemoveSpecificBuff(npc.index, "Fluid Movement");
}
static int i_CreateManipulation(Lelouch npc, float Spawn_Loc[3], float Spawn_Ang[3], char[] Model, int Spawn_HP, float size = 1.0)
{
	int spawn_index = NPC_CreateByName("npc_ruina_manipulation", npc.index, Spawn_Loc, Spawn_Ang, GetTeam(npc.index), Model);
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", Spawn_HP);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", Spawn_HP);

		AddNpcToAliveList(spawn_index, 1);

		if(size != 1.0)
		{
			float scale = GetEntPropFloat(spawn_index, Prop_Send, "m_flModelScale");
			SetEntPropFloat(spawn_index, Prop_Send, "m_flModelScale", scale * size);
		}
	}
	return spawn_index;
}
static void Body_Pitch(Lelouch npc, float VecSelfNpc[3], float vecTarget[3])
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
static void Get_Fake_Forward_Vec(float Range, float vecAngles[3], float Vec_Target[3], float Pos[3])
{
	float Direction[3];
	
	GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(Direction, Range);
	AddVectors(Pos, Direction, Vec_Target);
}


static float Modify_Damage(int Target, float damage)
{
	damage *=RaidModeScaling;

	if(!IsValidEntity(Target))
		return damage;

	if(ShouldNpcDealBonusDamage(Target))
		damage*=10.0;

	if(Target > MaxClients)
		return damage;

	int weapon = GetEntPropEnt(Target, Prop_Send, "m_hActiveWeapon");
						
	if(!IsValidEntity(weapon))
		return damage;

	char classname[32];
	GetEntityClassname(weapon, classname, 32);

	int weapon_slot = TF2_GetClassnameSlot(classname, weapon);
										
	if(i_OverrideWeaponSlot[weapon] != -1)
	{
		weapon_slot = i_OverrideWeaponSlot[weapon];
	}
	if(weapon_slot != 2 || i_IsWandWeapon[weapon])
		damage *= 1.7;

	return damage;
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Lelouch npc = view_as<Lelouch>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);

	Create_Anchors(npc);
		
	Lelouch_Weapon_Lines(npc, attacker);

	int Max_Health = ReturnEntityMaxHealth(npc.index);
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	if(IsValidEntity(npc.m_iWearable9))
	{
		float Ratio = ( float(Health)/float(Max_Health) ) - 0.25;
		SetEntityRenderMode(npc.m_iWearable9, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable9, 150, 150, 150, RoundToFloor(100*Ratio));
	}

	if(!npc.Anger && (Max_Health/2) >= Health) //Anger after half hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(IsValidEntity(npc.m_iWearable9))
			RemoveEntity(npc.m_iWearable9);

		float Duration = 6.0;
		Initiate_Anim(npc, Duration, "taunt_unleashed_rage_spy", 0.5,_, true, true);

		npc.m_flGiveHyperResistances = GetGameTime(npc.index) + Duration;

		npc.m_flRevertAnim = GetGameTime(npc.index) + Duration;

		switch(GetRandomInt(0, 2))
		{
			case 0:	Lelouch_Lines(npc, "내 수정 보호막이! 대가를 치르게 해주마!");
			case 1: Lelouch_Lines(npc, "이런 싸가지 없는!!!");
			case 2: Lelouch_Lines(npc, "아직 끝났다고 생각하지 마라! 아직 싸울 힘은 더 많이 남아있다!");
		}
		
		RaidModeScaling *= 1.5;

		RaidModeTime += 200.0;

		WaveStart_SubWaveStart(GetGameTime() + 600.0);
		//this shouldnt ever start, no anti delay here.

		CreateTimer(Duration, LelouchLifeloss, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
		
	}

	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
static void LelouchSpawnEnemy(int alaxios, char[] plugin_name, int health = 0, int count, bool is_a_boss = false, char data[64] = "")
{
	if(GetTeam(alaxios) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(alaxios, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(alaxios, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(alaxios));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 3.5;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(alaxios);
	if(data[0])
		enemy.Data = data;
	if(Rogue_Mode())
		Format(enemy.Spawn,sizeof(enemy.Spawn), "spawn_9_5");
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		Freeplay_AddEnemy(postWaves, enemy, count);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}
static Action LelouchLifeloss(Handle Timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidEntity(client))
		return Plugin_Stop;

	Lelouch npc = view_as<Lelouch>(client);

	CPrintToChatAll("{purple}트윌{snow}: 도대체 어떻게 그 고대 유물을 다시 발동시킬 수 있었던 거니?");
	Lelouch_Lines(npc,"한 여자의 쓰레기 취급이, 다른 자에겐 보물이었으니까.");
	i_summon_weaver(npc);

	return Plugin_Stop;
}
static void Lelouch_Weapon_Lines(Lelouch npc, int client)
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
		/*
		case WEAPON_COSMIC_TERROR: switch(GetRandomInt(0,1)) 		
		case WEAPON_LANTEAN: switch(GetRandomInt(0,1)) 							
		case WEAPON_BEAM_PAP: switch(GetRandomInt(0,1)) 				
		case WEAPON_QUINCY_BOW: switch(GetRandomInt(0,1)) 			
		 				
		case WEAPON_IMPACT_LANCE: switch(GetRandomInt(0,1)) 		
		case WEAPON_GRAVATON_WAND: switch(GetRandomInt(0,1)) 		
		*/
		case WEAPON_FANTASY_BLADE: switch(GetRandomInt(1,2)) 		{case 1: Format(Text_Lines, sizeof(Text_Lines), "그 무기는 꼭 마치 내 것처럼 보이는군, {gold}%N{snow}. 다행히도 네 건 짝퉁이지만.", client);  														case 2: Format(Text_Lines, sizeof(Text_Lines), "정말 싼티나는 무기로구나, {gold}%N{snow}.", client);}
		case WEAPON_YAMATO: switch(GetRandomInt(1,2)) 				{case 1: Format(Text_Lines, sizeof(Text_Lines), "도대체 왜 {purple}트윌{snow}이 그렇게 \"{blue}다가오는 폭풍{snow}\"에 집착하는지 모르겠군. 넌 알고 있나? {gold}%N{snow}?", client);  	case 2: Format(Text_Lines, sizeof(Text_Lines), "네가 계속 말하는 {blue}버질{snow}이 도대체 누구냐, {gold}%N{snow}?", client);}
		case WEAPON_KIT_BLITZKRIEG_CORE: switch(GetRandomInt(1,2)) 	{case 1: Format(Text_Lines, sizeof(Text_Lines), "블리츠크리그는 그 연합에서 만들어진 것들 중에서 그나마 상태가 좋았던 무기다, {gold}%N{snow}. 그리고 넌 그것보다 더 좋은 무기를 썼어야해.", client);  								case 2: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow}. 네가 블리츠크리그를 형체도 없이 파괴한 탓에, 난 그를 \"개선\" 시킬 기회조차 사라져버렸다...", client);}
		case WEAPON_KIT_FRACTAL:  switch(GetRandomInt(1,2))			{case 1: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{snow}, 네가 사용하는 그 마기아 무기... 내가 잘못 본거냐?", client);  																				case 2: Format(Text_Lines, sizeof(Text_Lines), "지금... {gold}%N{snow} 네가 {purple}트윌{snow}의 힘을 사용할 수 있다는 뜻이냐?", client);}
		case WEAPON_BOOMSTICK: switch(GetRandomInt(1,2))			{case 1: Format(Text_Lines, sizeof(Text_Lines), "뜀뛰기를 참으로 잘 하는군?", client); 																										case 2: Format(Text_Lines, sizeof(Text_Lines), "그런 거대한 금속 조각을 쏘는게 대체 얼마나 효과적인거지? {gold}%N{snow}, 설명해봐라!", client);}
		case WEAPON_ION_BEAM, WEAPON_ION_BEAM_PULSE, WEAPON_ION_BEAM_NIGHT, WEAPON_ION_BEAM_FEED: switch(GetRandomInt(1,2))	{case 1: Format(Text_Lines, sizeof(Text_Lines), "네 무기 꼴을 보면 네가 무기 성능보다 외형을 더 중시한다는걸 보여주고 있다, {gold}%N", client); 						case 2: Format(Text_Lines, sizeof(Text_Lines), "네 무기는 화려하기만 하고 쓸모가 없다, {gold}%N !", client);}
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "이런 개같은 자식, {gold}%N", client); 

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		Lelouch_Lines(npc, Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}
static int i_summon_weaver(Lelouch npc)
{
	HealEntityGlobal(npc.index, npc.index, ReturnEntityMaxHealth(npc.index) * 0.1, 1.0, 0.0, HEAL_ABSOLUTE);
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	int maxhealth;

	maxhealth = GetEntProp(npc.index, Prop_Data, "m_iHealth");

	float Npc_Loc[3]; GetAbsOrigin(npc.index, Npc_Loc);
	int spawn_index = NPC_CreateByName("npc_interstellar_weaver", npc.index, Npc_Loc, ang, GetTeam(npc.index));
	if(spawn_index > MaxClients)
	{
		NpcStats_CopyStats(npc.index, spawn_index);
		if(GetTeam(npc.index) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
		}
		Interstellar_Weaver worm = view_as<Interstellar_Weaver>(spawn_index);
		worm.m_iState = EntIndexToEntRef(npc.index);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
	}
	return spawn_index;
}

static void NPC_Death(int entity)
{
	Lelouch npc = view_as<Lelouch>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	i_Lelouch_Index = INVALID_ENT_REFERENCE;
	
	Ruina_NPCDeath_Override(entity);

	struct_Anchors_Effects[npc.index].Nuke();

	if(npc.index==EntRefToEntIndex(RaidBossActive))
		RaidBossActive=INVALID_ENT_REFERENCE;

	for(int i= 0 ; i < LELOUCH_MAX_CRYSTALS ; i++)
	{
		struct_Crystals[npc.index][i].Kill();
	}
	for(int i = 0 ; i < 3 ; i++)
	{
		int anchor = EntRefToEntIndex(i_AnchorID_Ref[npc.index][i]);
		if(IsValidEntity(anchor))
		{
			RequestFrame(KillNpc, EntIndexToEntRef(anchor));
		}
	}
		
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
	if(IsValidEntity(npc.m_iSpecialEntSlot))
		RemoveEntity(npc.m_iSpecialEntSlot);

	if(!b_wonviakill[npc.index] && !b_wonviatimer[npc.index])
	{
		Lelouch_Lines(npc, "너... 넌 내가 죽으면 너 혼자 관문을 막을 수 있을거라 생각해...? 어리석은 것들....");
		//it isn't rouge mode? don't do anything else
		if(!Rogue_Mode())
			return;
		
		if(Rogue_HasNamedArtifact("Ascension Stack"))
			return;

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		CreateEarthquake(flPos, 8.0, 9999.9, 16.0, 255.0);
		CreateTimer(5.0, Timer_FadoutOffset_Global, 69, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, Timer_FadoutOffset_Global, 50, TIMER_FLAG_NO_MAPCHANGE);

		//kaboom effect
		for(float fl=0.0 ; fl < 10.0 ; fl += 0.15)
		{
			CreateTimer(fl, KaboomRogueOnlyEffect_LeLouch, 50, TIMER_FLAG_NO_MAPCHANGE);
		}
		Waves_ClearWaveCurrentSpawningEnemies();
		
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entitynpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entitynpc))
			{
				if(entitynpc != INVALID_ENT_REFERENCE && IsEntityAlive(entitynpc) && GetTeam(npc.index) == GetTeam(entitynpc))
				{
					SmiteNpcToDeath(entitynpc);
				}
			}
		}
		GiveProgressDelay(12.0);
	}
	
}
static Action KaboomRogueOnlyEffect_LeLouch(Handle Timer, int nothing)
{
	float SavePos[3];
	for(int LoopExplode; LoopExplode <= 2; LoopExplode++)
	{
		//Middle of island
		SavePos = {8705.115234, -137.372833, -3051.154297};
		SavePos[0] += GetRandomFloat(-100.0,100.0);
		SavePos[1] += GetRandomFloat(-100.0,100.0);
		SavePos[2] += GetRandomFloat(-300.0,100.0);
		DataPack pack_boom1 = new DataPack();
		pack_boom1.WriteFloat(SavePos[0]);
		pack_boom1.WriteFloat(SavePos[1]);
		pack_boom1.WriteFloat(SavePos[2]);
		pack_boom1.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom1);
		EmitAmbientSound("ambient/explosions/explode_3.wav", SavePos, _, 90, _,1.0, GetRandomInt(75, 110));
		ParticleEffectAt(SavePos, "powerup_supernova_explode_blue", 0.25);
	}
	return Plugin_Stop;
}
static Action Timer_FadoutOffset_Global(Handle Timer, int nothing)
{
	if(nothing == 50)
	{
		CPrintToChatAll("{crimson}당신이 트윌의 보호를 받으며 섬을 빠져나가자, 섬이 완전히 파괴됩니다. 하지만 를르슈는 그의 목숨을 바쳐서라도 자신의 목적을 달성하고 말았습니다...");
		CPrintToChatAll("{crimson}장막과의 연결망이 약화되었습니다. 무언가... 끔찍한게 다가오고 있습니다...");
		for(int i=1 ; i <= MaxClients ; i++)
		{
			if(IsValidClient(i) && Rogue_Mode())
			{
				//safe spot?
				TeleportEntity(i, {83.142601, -1510.043335, -6910.704590}, NULL_VECTOR, NULL_VECTOR);
			}
		}
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entity))
			{
				if(entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == TFTeam_Red)
				{
					TeleportEntity(entity, {83.142601, -1510.043335, -6910.704590}, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		return Plugin_Stop;
	}
	if(nothing == 69)
	{
		ParticleEffectAt({8705.115234, -137.372833, -3051.154297}, "hightower_explosion", 1.0);
		CPrintToChatAll("{purple}트윌{snow}: 이런, 그가 정말로 자기 목숨을 바쳐서까지 관문을 열어버렸어. 꽉 잡으렴, 금방 빠져나갈테니!");
		EmitSoundToAll("items/cart_explode.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, {8705.115234, -137.372833, -3051.154297});
		EmitSoundToAll("items/cart_explode.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, {8705.115234, -137.372833, -3051.154297});
	}
	if(nothing == 68)
	{
		ParticleEffectAt({8705.115234, -137.372833, -3051.154297}, "hightower_explosion", 1.0);
		EmitSoundToAll("items/cart_explode.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, {8705.115234, -137.372833, -3051.154297});
		EmitSoundToAll("items/cart_explode.wav", 0, SNDCHAN_AUTO, 90, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, {8705.115234, -137.372833, -3051.154297});
	}
		
	for(int i=1 ; i <= MaxClients ; i++)
	{
		if(IsValidClient(i) && Rogue_Mode())
		{
			TF2_StunPlayer(i, 10.0, 0.1, TF_STUNFLAGS_LOSERSTATE);
		}
	}
	if(Rogue_Mode())
		CauseFadeInAndFadeOut(0,4.0,4.0,10.0, "255");
	return Plugin_Stop;
}
void Lelouch_Lines(Lelouch npc, const char[] text)
{
	if(b_test_mode[npc.index])
		return;

	CPrintToChatAll("%s %s", npc.GetName(), text);
}
