#pragma semicolon 1
#pragma newdecls required

static float BONES_SUPREME_SPEED = 350.0;

#define BONES_SUPREME_SCALE				"1.45"
#define BONES_SUPREME_SKIN				"1"
#define BONES_SUPREME_HP				"35000"
#define MODEL_SSB   					"models/zombie_riot/the_bone_zone/supreme_spookmaster_bones.mdl"

#define SND_SPAWN_ALERT		"misc/halloween/merasmus_appear.wav"

#define PARTICLE_SSB_SPAWN	"doomsday_tentpole_vanish01"

static char g_DeathSounds[][] = {
	")misc/halloween/skeleton_break.wav",
};

static char g_HurtSounds[][] = {
	")zombie_riot/the_bone_zone/skeleton_hurt.mp3",
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

public void SupremeSpookmasterBones_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
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
	PrecacheSound(SND_SPAWN_ALERT);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Supreme Spookmaster Bones");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ssb");
	strcopy(data.Icon, sizeof(data.Icon), "sniper");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = Summon_SSB;
	NPC_Add(data);

	SSB_PrepareAbilities();
}

static any Summon_SSB(int client, float vecPos[3], float vecAng[3], int ally)
{
	return SupremeSpookmasterBones(client, vecPos, vecAng, ally);
}

//The following are variables used for SSB's various stats and attacks.
//I use the same trick here as I use for my weapons, but for the wave of the encounter instead.
//When you see a variable that looks like "int MyVariable[4] = { 1, 2, 3, 4 };", 1 is the value used on/before wave 15, 2 is the value used on wave 30, 3 is 45, and 4 is 60+.

int SSB_WavePhase = 0;		//This gets set based on the wave number whenever SSB spawns. <= W15 = 0, 16-30 = 1, 31-45 = 2, 46+ = 3.
							//Used purely to know which array slot to use for ability stats.

//SPELL CARDS: SSB's basic attacks. These come out instantly, but are far weaker than his specials.
//NOTE: Spell Cards must have their own function, which takes a "SupremeSpookmasterBones" as a parameter, plus one entity index for the target entity.
ArrayList SSB_SpellCards[4];								//DO NOT TOUCH THIS DIRECTLY!!!! This is used for setting the collection of Spell Cards SSB can use on each wave.
															//To change this, see "SSB_PrepareAbilities".
int SSB_LastSpell[MAXENTITIES] = { -1, ... };				//The most recently-used spell card. Used so that the same Spell Card cannot be used twice in a row.
int SSB_DefaultSpell[4] = { 0, 0, 0, 0 };					//The Spell Card slot to default to if none of the other Spell Cards are successfully cast.
float SSB_NextSpell[MAXENTITIES] = { 0.0, ... }; 			//The GameTime at which SSB will use his next Spell Card.
float SSB_SpellCDMin[4] = { 7.5, 6.25, 5.0, 3.75 };			//The minimum cooldown between spell cards.
float SSB_SpellCDMax[4] = { 12.5, 11.25, 10.0, 8.75 };		//The maximum cooldown between spell cards.

//SPOOKY SPECIALS: SSB's big attacks. These typically have wind-up periods and are very powerful, but have long cooldowns and are more easily avoided.
ArrayList SSB_Specials[4];								//DO NOT TOUCH THIS DIRECTLY!!!! This is used for setting the collection of Spooky Specials SSB can use on each wave.
														//To change this, see "SSB_PrepareAbilities".
int SSB_LastSpecial[MAXENTITIES] = { -1, ... };			//The most recently-used special. Used so that the same special cannot be used twice in a row.
int SSB_DefaultSpecial[4] = { 0, 0, 0, 0 };				//The Spooky Special slot to default to if none of the other Spooky Specials are successfully cast.
float SSB_NextSpecial[MAXENTITIES] = { 0.0, ... };		//The GameTime at which SSB will use his next Spooky Special.
float SSB_SpecialCDMin[4] = { 20.0, 17.5, 15.0, 12.5 };	//The minimum cooldown between specials.
float SSB_SpecialCDMax[4] = { 30.0, 27.5, 25.0, 22.5 }; //The maximum cooldown between specials.

//Below are the stats governing both of SSB's ability systems (Spell Cards AND Spooky Specials). Do not touch these! Instead, use the methodmap's getters and setters if you need to change them.
#define SSB_MAX_ABILITIES 9999999

int Ability_MaxUses[SSB_MAX_ABILITIES] = { 0, ... };	//The maximum number of times the ability can be used per fight. <= 0: no limit.
int Ability_Uses[SSB_MAX_ABILITIES] = { 0, ... };		//The number of times the ability has been used during this fight.
float Ability_Chance[SSB_MAX_ABILITIES] = { 0.0, ... };	//The chance for this ability to be used when SSB attempts to activate a Spooky Special or use a Spell Card (0.0 = 0%, 1.0 = 100%).
Function Ability_Function[SSB_MAX_ABILITIES] = { INVALID_FUNCTION, ... };	//The function to call when this ability is successfully activated.
Function Ability_Filter[SSB_MAX_ABILITIES] = { INVALID_FUNCTION, ... };		//The function to call when this ability is about to be activated, to check manually if it can be used or not. Must take one SupremeSpookmasterBones and an entity index for the victim as parameters, and return a bool (true: activate, false: don't).

bool SSB_AbilitySlotUsed[SSB_MAX_ABILITIES] = {false, ...};

methodmap SSB_Ability __nullable__
{
	public SSB_Ability()
	{
		int index = 0;
		while (SSB_AbilitySlotUsed[index] && index < SSB_MAX_ABILITIES)
			index++;

		if (index >= SSB_MAX_ABILITIES)
			LogError("ERROR: SSB SOMEHOW has more than %i spell cards/specials...\nThis should never happen.", SSB_MAX_ABILITIES);
		
		SSB_AbilitySlotUsed[index] = true;

		return view_as<SSB_Ability>(index);
	}

	//Rolls to see if this ability can successfully be used, auto-using it and returning true on success.
	//Set "forced" to true to ignore random chance, max uses, and the filter function and force the ability to go through.
	public bool Activate(SupremeSpookmasterBones user, int target, bool forced = false)
	{
		bool success = true;
		if (!forced)
			success = GetRandomFloat(0.0, 1.0) <= this.Chance;

		if (success && !forced)
			success = this.Uses < this.MaxUses || this.MaxUses <= 0;

		if (success && !forced && this.FilterFunction != INVALID_FUNCTION)
		{
			Call_StartFunction(null, this.FilterFunction);
			Call_PushCell(user);
			Call_PushCell(target);
			Call_Finish(success);
		}
		
		if (success || forced)
		{
			Call_StartFunction(null, this.ActivationFunction);
			Call_PushCell(user);
			Call_PushCell(target);
			Call_Finish();

			this.Uses++;
		}

		return success;
	}

	public void Delete()
	{
		this.Chance = 0.0;
		this.ActivationFunction = INVALID_FUNCTION;
		this.Uses = 0;
		this.MaxUses = 0;
		SSB_AbilitySlotUsed[this.Index] = false;
	}

	property int Index
	{ 
		public get() { return view_as<int>(this); }
	}

	property int MaxUses
	{
		public get() { return Ability_MaxUses[this.Index]; }
		public set(int value) { Ability_MaxUses[this.Index] = value; }
	}

	property int Uses
	{
		public get() { return Ability_Uses[this.Index]; }
		public set(int value) { Ability_Uses[this.Index] = value; }
	}

	property float Chance
	{
		public get() { return Ability_Chance[this.Index]; }
		public set(float value) { Ability_Chance[this.Index] = value; }
	}

	property Function ActivationFunction
	{
		public get() { return Ability_Function[this.Index]; }
		public set(Function value) { Ability_Function[this.Index] = value; }
	}

	property Function FilterFunction
	{
		public get() { return Ability_Filter[this.Index]; }
		public set(Function value) { Ability_Filter[this.Index] = value; }
	}
}

static void SSB_PrepareAbilities()
{
	SSB_DeleteAbilities();
	for (int i = 0; i < 4; i++)
	{
		SSB_SpellCards[i] = new ArrayList(255);
		SSB_Specials[i] = new ArrayList(255);
	}

	//The following example adds a Spell Card to the wave 15 pool of spells (SSB_SpellCards[0]), which has a 15% cast chance, can be used twice, checks SpellCard_Filter before activation, and calls SpellCard_Example when successfully cast.
	//Simply copy what this does to add new Spell Cards to each wave's pool of Spell Cards.
	//PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility(0.15, 2, SpellCard_Example, SpellCard_Filter));

	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility(0.33, 0, TestSpellCard_1));
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility(0.33, 0, TestSpellCard_2));
	PushArrayCell(SSB_SpellCards[0], SSB_CreateAbility(0.33, 0, TestSpellCard_3));

	PushArrayCell(SSB_Specials[0], SSB_CreateAbility(0.33, 0, TestSpecial_1));
	PushArrayCell(SSB_Specials[0], SSB_CreateAbility(0.33, 0, TestSpecial_2));
	PushArrayCell(SSB_Specials[0], SSB_CreateAbility(0.33, 0, TestSpecial_3));
}

public void TestSpellCard_1(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{haunted}Example spell card #1 was cast!");
}

public void TestSpellCard_2(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{haunted}Example spell card #2 was cast!");
}

public void TestSpellCard_3(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{haunted}Example spell card #2 was cast!");
}

public void TestSpecial_1(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{vintage}Example special #1 was cast!");
}

public void TestSpecial_2(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{vintage}Example special #2 was cast!");
}

public void TestSpecial_3(SupremeSpookmasterBones ssb, int target)
{
	CPrintToChatAll("{vintage}Example special #3 was cast!");
}

/*void SpellCard_Example(SupremeSpookmasterBones ssb, int target)
{
	//Hypothetical Spell Card code goes here.
}

void SpellCard_Filter(SupremeSpookmasterBones ssb, int target)
{
	//Hypothetical filter code goes here. Return true to allow activation, false otherwise.
}*/

static SSB_Ability SSB_CreateAbility(float Chance, int MaxUses, Function ActivationFunction, Function FilterFunction = INVALID_FUNCTION)
{
	SSB_Ability Spell = new SSB_Ability();

	Spell.Chance = Chance;
	Spell.MaxUses = MaxUses;
	Spell.ActivationFunction = ActivationFunction;
	Spell.FilterFunction = FilterFunction;

	return Spell;
}

public void SSB_DeleteAbilities()
{
	for (int i = 0; i < 4; i++)
	{
		if (SSB_SpellCards[i] != null)
		{
			for (int spell = 0; spell < GetArraySize(SSB_SpellCards[i]); spell++)
			{
				SSB_Ability ability = GetArrayCell(SSB_SpellCards[i], spell);
				ability.Delete();
			}
		}

		if (SSB_Specials[i] != null)
		{
			for (int special = 0; special < GetArraySize(SSB_Specials[i]); special++)
			{
				SSB_Ability ability = GetArrayCell(SSB_Specials[i], special);
				ability.Delete();
			}
		}

		delete SSB_SpellCards[i];
		delete SSB_Specials[i];
	}
}

methodmap SupremeSpookmasterBones < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.0, GetRandomInt(80, 110));
		
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

	public void PlayIntroSound()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBIntro_Sounds) - 1);
		EmitSoundToAll(g_SSBIntro_Sounds[rand], _, _, 120);
		EmitSoundToAll(SND_SPAWN_ALERT, _, _, _, _, 0.8);
		CPrintToChatAll(g_SSBIntro_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayIntroSound()");
		#endif
	}

	public void PlayMinorLoss()
	{
		int rand = GetRandomInt(0, sizeof(g_SSBMinorWin_Sounds) - 1);
		EmitSoundToAll(g_SSBMinorWin_Sounds[rand], _, _, 120);
		EmitSoundToAll(SND_SPAWN_ALERT, _, _, _, _, 0.8);
		CPrintToChatAll(g_SSBMinorWin_Captions[rand]);

		#if defined DEBUG_SOUND
		PrintToServer("CSupremeSpookmasterBones::PlayIntroSound()");
		#endif
	}

	public void CalculateNextSpecial()
	{
		SSB_NextSpecial[this.index] = GetGameTime() + GetRandomFloat(SSB_SpecialCDMin[SSB_WavePhase], SSB_SpecialCDMax[SSB_WavePhase]);
	}

	public void CalculateNextSpellCard()
	{
		SSB_NextSpell[this.index] = GetGameTime() + GetRandomFloat(SSB_SpellCDMin[SSB_WavePhase], SSB_SpellCDMax[SSB_WavePhase]);
	}

	public bool IsSpecialReady()
	{
		return SSB_NextSpecial[this.index] <= GetGameTime();
	}

	public bool IsSpellReady()
	{
		return SSB_NextSpell[this.index] <= GetGameTime();
	}

	public void ActivateSpecial(int target)
	{
		ArrayList clone = SSB_Specials[SSB_WavePhase].Clone();

		bool success = false;
		int activated = -1;

		//First: Attempt to use a random ability.
		while (!success && GetArraySize(clone) > 0)
		{
			activated = GetRandomInt(0, GetArraySize(clone) - 1);

			if (activated != SSB_LastSpecial[this.index])
			{
				SSB_Ability chosen = GetArrayCell(clone, activated);
				success = chosen.Activate(this, target, false);
			}

			RemoveFromArray(clone, activated);
		}

		delete clone;

		//Second: We failed to successfully activate any of our random options, force the default ability to activate. 
		if (!success)
		{
			activated = SSB_DefaultSpecial[SSB_WavePhase];
			SSB_Ability chosen = GetArrayCell(SSB_Specials[SSB_WavePhase], activated);
			chosen.Activate(this, target, true);
		}

		SSB_LastSpecial[this.index] = activated;
		this.CalculateNextSpecial();
	}

	public void CastSpell(int target)
	{
		ArrayList clone = SSB_SpellCards[SSB_WavePhase].Clone();

		bool success = false;
		int activated = -1;

		//First: Attempt to use a random ability.
		while (!success && GetArraySize(clone) > 0)
		{
			activated = GetRandomInt(0, GetArraySize(clone) - 1);

			if (activated != SSB_LastSpell[this.index])
			{
				SSB_Ability chosen = GetArrayCell(clone, activated);
				success = chosen.Activate(this, target, false);
			}

			RemoveFromArray(clone, activated);
		}

		delete clone;

		//Second: We failed to successfully activate any of our random options, force the default ability to activate. 
		if (!success)
		{
			activated = SSB_DefaultSpell[SSB_WavePhase];
			SSB_Ability chosen = GetArrayCell(SSB_SpellCards[SSB_WavePhase], activated);
			chosen.Activate(this, target, true);
		}

		SSB_LastSpell[this.index] = activated;
		this.CalculateNextSpellCard();
	}
	
	public SupremeSpookmasterBones(int client, float vecPos[3], float vecAng[3], int ally)
	{
		SupremeSpookmasterBones npc = view_as<SupremeSpookmasterBones>(CClotBody(vecPos, vecAng, MODEL_SSB, BONES_SUPREME_SCALE, BONES_SUPREME_HP, ally, false, true, true, true));
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_IsSkeleton[npc.index] = true;
		npc.m_bBoneZoneNaturallyBuffed = true;

		func_NPCDeath[npc.index] = view_as<Function>(SupremeSpookmasterBones_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(SupremeSpookmasterBones_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(SupremeSpookmasterBones_ClotThink);

		int iActivity = npc.LookupActivity("ACT_STAND_NO_HAMMER");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		DispatchKeyValue(npc.index, "skin", BONES_SUPREME_SKIN);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_iBleedType = BLEEDTYPE_SKELETON;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flSpeed = BONES_SUPREME_SPEED;
		
		SDKHook(npc.index, SDKHook_Think, SupremeSpookmasterBones_ClotThink);

		npc.StartPathing();
		npc.PlayIntroSound();

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "SSB Spawn");
			}
		}

		b_thisNpcIsARaid[npc.index] = true;
		SSB_LastSpell[npc.index] = -1;
		ParticleEffectAt(vecPos, PARTICLE_SSB_SPAWN, 3.0);

		float wave = float(Waves_GetWave());
		if (wave <= 0.0)
			SSB_WavePhase = 0;
		else
			SSB_WavePhase = RoundToCeil(wave / 15.0) - 1;

		if (SSB_WavePhase > 3)
			SSB_WavePhase = 3;

		CPrintToChatAll("WavePhase is %i", SSB_WavePhase);
		
		npc.CalculateNextSpecial();
		npc.CalculateNextSpellCard();

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
		float pos[3], targPos[3]; 
		WorldSpaceCenter(npc.index, pos);
		WorldSpaceCenter(closest, targPos);
			
		//float flDistanceToTarget = GetVectorDistance(targPos, pos);
		
		npc.StartPathing();
		NPC_SetGoalEntity(npc.index, closest);
		npc.FaceTowards(targPos, 225.0);

		if (npc.IsSpecialReady())
		{
			npc.ActivateSpecial(closest);
		}
		else if (npc.IsSpellReady())
		{
			npc.CastSpell(closest);
		}
		else /*if (flDistanceToTarget <= SSB_MeleeRange && GetGameTime(npc.index) >= npc.m_flNextMeleeAttack)*/
		{
			//TODO: Generic melee attack if the target is close enough
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
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

	npc.PlayMinorLoss();	//TODO: He needs to have a more cinematic death sequence when defeated on wave 60.
	SDKUnhook(entity, SDKHook_Think, SupremeSpookmasterBones_ClotThink);
		
	npc.RemoveAllWearables();
//	AcceptEntityInput(npc.index, "KillHierarchy");
}