#pragma semicolon 1
#pragma newdecls required

/*

Stella:

Move the NC lines into the new format.

Silence:
Very slightly reduces range of normal attack, its turn speed. its "Alpha" (brigtness) is lowered to show its weakened state.
Very slightly reduces the turn speed of Nightmare cannon, and its radius. its "Alpha" (brigtness) is lowered to show its weakened state.

NC Core:
Make it so, Stella can shoot her NC into karlas and he reflects it.


Give stella a cool phase 2 animation, use crystals? in a spining circle that shoot lasers in all the cardinal directions. (Phase 2)



Karlas:
While cannon is being shot at him, his move speed is reduced by 90% and his turn speed is reduced by 50%. in addition uses the same targeting logic stella will have.

Look into replacing his Lance with the model version.

If Karlas is close to stella, and there are multiple people near stella, Karlas allows stella to "retreat" teleport like Twirl.

Give Karlas a Phase 2 animation, doing idk what yet.

When Stella dies, Karlas gains his current blades. abit modified tho. mainly visual / trace (Phase 3)


Misc:
Look into making actual model wings.
And making stella special weapon models for her hand crest.

For Karlas make somekind of slicer model that would be used for ranged attacks, I.E barrage of light?



*/

static float fl_nightmare_cannon_core_sound_timer[MAXENTITIES];

static const char g_nightmare_cannon_core_sound[][] = {
	"zombiesurvival/seaborn/loop_laser.mp3",
};


static const char g_heavens_fall_strike_sound[][] = {
	"ambient_mp3/halloween/thunder_01.mp3",
	"ambient_mp3/halloween/thunder_02.mp3",
	"ambient_mp3/halloween/thunder_03.mp3",
	"ambient_mp3/halloween/thunder_04.mp3",
	"ambient_mp3/halloween/thunder_05.mp3",
	"ambient_mp3/halloween/thunder_06.mp3",
	"ambient_mp3/halloween/thunder_07.mp3",
	"ambient_mp3/halloween/thunder_08.mp3",
	"ambient_mp3/halloween/thunder_09.mp3",
	"ambient_mp3/halloween/thunder_10.mp3",
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
static const char g_MeleeAttackSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};
static int i_particle_effects[MAXENTITIES][3];


#define DONNERKRIEG_TE_DURATION 0.1

//Heavens Light


static char gExplosive1;

//Heavens Fall

static float fl_heavens_fall_use_timer[MAXENTITIES];

//Logic for duo raidboss


static int i_ally_index[MAXENTITIES];
static bool b_InKame[MAXENTITIES];
static bool b_tripple_raid[MAXENTITIES];

#define STELLA_NC_DURATION 15.0
#define STELLA_KARLAS_THEME "#zombiesurvival/seaborn/donner_schwert_5.mp3"

bool b_donner_said_win_line;

static float fl_npc_basespeed;
static bool b_test_mode[MAXENTITIES];
static int i_current_wave[MAXENTITIES];

static const char NameColour[] = "{aqua}";
static const char TextColour[] = "{snow}";

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
	PrecacheSoundCustom(STELLA_KARLAS_THEME);
	NPC_Add(data);

}

static void ClotPrecache()
{
	Zero(fl_nightmare_cannon_core_sound_timer);

	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_heavens_fall_strike_sound);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);


	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");

	PrecacheSound("misc/halloween/gotohell.wav");

	PrecacheSound("vo/medic_sf13_influx_big02.mp3", true);
	

	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);

	PrecacheSound("ambient/energy/whiteflash.wav", true);
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
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayNightmareSound()");
		#endif
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
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		
		
	}
	property float m_flNorm_Attack_Duration
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
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
	property int m_iNC_Dialogue
	{
		public get()							{ return this.m_iState; }
		public set(int TempValueForProperty) 	{ this.m_iState = TempValueForProperty; }
	}

	public void SetKarlasRetreat(bool state)
	{
		if(IsValidAlly(this.index, this.Ally))
		{
			Karlas npc = view_as<Karlas>(this.Ally);
			npc.m_fbGunout = state;
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
			Set_Karlas_Ally(spawn_index, this.index);
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

	public Stella(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Stella npc = view_as<Stella>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));

		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		c_NpcName[npc.index] = "Stella";

		//data: test , force15, force30, force45, force60, hell, solo, triple_enemies, nomusic, anger

		b_test_mode[npc.index] = StrContains(data, "test") != -1;

		int wave = ZR_GetWaveCount()+1;

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

		//todo: this :3
		if(wave == -1)
		{
			wave = 60 + ZR_GetWaveCount();
		}
		i_current_wave[npc.index] = wave;

		
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iChanged_WalkCycle = 1;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		if(!IsValidEntity(RaidBossActive))
			RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_bDissapearOnDeath = true;
		
		RaidModeTime = GetGameTime() + 250.0;
		
		RaidModeScaling = float(wave);

		b_angered_twice[npc.index]=false;
	
		
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Donnerkrieg And Schwertkrieg Spawn");
			}
		}
		
		Citizen_MiniBossSpawn();
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
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
		//func_NPCFuncWin[npc.index] = Win_Line;
			
		
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

		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_r", flPos, flAng);
		i_particle_effects[npc.index][0] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		
		npc.StartPathing();
		float GameTime = GetGameTime(npc.index);
				
		npc.m_flNC_Recharge = GameTime + 10.0;
		npc.m_iNC_Dialogue = 0;


		fl_heavens_fall_use_timer[npc.index] = GameTime + 30.0;
		
		if(!b_test_mode[npc.index])
			EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		if(wave <=45)
			CPrintToChatAll("{aqua}Stella{snow}: We have arrived to render judgement");
		else
			CPrintToChatAll("{aqua}Stella{snow}: This ends now!");
		
		Donnerkrieg_Wings_Create(npc);

		npc.Anger = false;
		
		if(!(StrContains(data, "solo") != -1))
			RequestFrame(Do_OnSpawn, EntIndexToEntRef(npc.index));

		if((StrContains(data, "anger") != -1))
			npc.Anger = true;

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 999, 999);	

		npc.m_flDoingAnimation = 0.0;

		if(b_test_mode[npc.index])
			RaidModeTime = FAR_FUTURE;
		
		return npc;
	}
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
/*
static void Win_Line(int entity)
{	
	char name_color[] = "aqua";
	char text_color[] = "snow";

	char text_lines[255];
	int ally = EntRefToEntIndex(i_ally_index);
	if(IsValidEntity(ally) && !b_schwert_ded)
	{
		switch(GetRandomInt(0, 2))
		{
			case 0:
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Huh, they're all dead, guess they were easier to stop then I expected...", name_color, text_color);
			}
			case 1:
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: HAH, the {darkblue}sea{snow} isn't THAT hard to beat", name_color, text_color);
			}
			case 2:
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Oh boy, their ragdoll's were {gold}amazing{snow}!", name_color, text_color);
			}
		}
	}
	else
	{
		switch(GetRandomInt(0, 1))
		{
			case 0:
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: You killed my beloved, and I {crimson}erased{snow} your existance", name_color, text_color);
			}
			case 1:
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Well, atleast I still have {purple}Twirl{snow}...", name_color, text_color);
			}
		}	
	}
	b_donner_said_win_line = true;
	CPrintToChatAll(text_lines);
}
*/

static void Internal_ClotThink(int iNPC)
{
	Stella npc = view_as<Stella>(iNPC);


	if(RaidModeTime < GetGameTime())
	{
		func_NPCThink[npc.index]=INVALID_FUNCTION;
		Stella_Lines(npc, "You lose!");
		return;
	}

	/*
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;

			char name_color[] = "aqua";
			char text_color[] = "snow";

			char text_lines[255];
			int ally = EntRefToEntIndex(i_ally_index);
			if(IsValidEntity(ally) && !b_schwert_ded)
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Ahaha, its almost over now, just{crimson} one more left{snow}!", name_color, text_color);
					}
					case 1:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: We'd better not choke now...", name_color, text_color);
					}
				}
			}
			else
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: I'm about to turn you into an unrecognisable mass of sea for {crimson}what you've DONE TO MY BELOVED", name_color, text_color);
			}
			CPrintToChatAll(text_lines);
		}
	}*/
		
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
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
	
	npc.m_flNextThinkTime = GameTime + 0.1;
	
	if(!IsValidEntity(RaidBossActive))
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

	if(npc.m_flGetClosestTargetTime < GameTime)
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

	if(npc.m_bInKame)
		Handle_NC_TurnSpeed(npc);

	if(npc.m_flDoingAnimation > GameTime)
	{
		npc.m_flSpeed = 0.0;
		return;
	}

	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting

	int Current_Wave = i_current_wave[npc.index];
	
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

	Stella_Nightmare_Logic(npc, PrimaryThreatIndex, vecTarget);

	Body_Pitch(npc, VecSelfNpc, vecTarget);

	npc.StartPathing();

	bool backing_up = KeepDistance(npc, flDistanceToTarget, PrimaryThreatIndex,((npc.m_iNC_Dialogue > 0) ? GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0 : GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 7.5));

	if(flDistanceToTarget < GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0)
	{
		npc.m_bAllowBackWalking = true;
		if(!BlockTurn(npc))
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}

	Self_Defense(npc, flDistanceToTarget);

	if(npc.m_bAllowBackWalking && backing_up)
	{
		npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;
		if(!BlockTurn(npc))
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED*2.0);
	}
	else
	{
		npc.m_flSpeed = fl_npc_basespeed;
	}
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
static void Handle_NC_TurnSpeed(Stella npc)
{
	float GameTime = GetGameTime(npc.index);

	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);

	float Duration = npc.m_flNC_Duration - GameTime;
	float Ratio = (1.0 - (Duration / STELLA_NC_DURATION))+0.2;

	float Turn_Speed = ((npc.Anger ? 300.0 : 250.0)*Ratio);

	if(NpcStats_IsEnemySilenced(npc.index))
		Turn_Speed *=0.95;

	npc.FaceTowards(vecTarget, Turn_Speed);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);

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

public void Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(bool donner_alive)
{
	/*if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		b_donner_said_win_line = true;
		if(donner_alive)
		{
			char name_color[] = "aqua";
			char text_color[] = "snow";

			char text_lines[255];
			int ally = EntRefToEntIndex(i_ally_index);
			if(IsValidEntity(ally))	//if karlas is alive
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: You think thats how you fight us two?", name_color, text_color);
			}
			else
			{
				Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Oh my, how annoying this has become...", name_color, text_color);
			}
			CPrintToChatAll(text_lines);
		}
		else
		{
			CPrintToChatAll("{crimson}Karlas{snow}: Ayaya?");
		}
		
	}*/
}

static int i_targets_inrange;

static int Nearby_Players(Stella npc, float Radius)
{
	i_targets_inrange = 0;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);
	return i_targets_inrange;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}
static bool b_Valid_NC_Initialistaion(Stella npc)
{
	int players = CountPlayersOnRed();
	if(players <= 2)
		return true;
	//we only want to use NC if we have atleast 2 people in sight (asuming more then 2 people actually exist)
	int Nearby = Nearby_Players(npc, (npc.Anger ? 3000.0 : 1250.0));

	if(Nearby > 2)
		return true;
	else
		return false;
	
}
static void Stella_Nightmare_Logic(Stella npc, int PrimaryThreatIndex, float vecTarget[3])
{
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNC_Recharge > GameTime)
		return;

	if(npc.m_bInKame)
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
		return;
	}

	if(!b_Valid_NC_Initialistaion(npc) && npc.m_iNC_Dialogue != 0)
		return;

	if(npc.m_iNC_Dialogue == 0)
	{
		
		EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");

		npc.SetKarlasRetreat(true);
		int chose = GetRandomInt(1, 2);
		switch(GetRandomInt(1, 2))
		{
			case 1: Stella_Lines(npc, "Aya 1");
			case 2: Stella_Lines(npc, "Oya 2");
		}
		npc.m_iNC_Dialogue = chose;

		npc.m_flNC_Grace = GameTime + GetRandomFloat(4.0, 6.0);
	}
	else if(npc.m_flNC_Grace < GameTime && b_Valid_NC_Initialistaion(npc))
	{
		npc.m_flNC_Duration = GameTime + STELLA_NC_DURATION + 0.75;
		int Enemy_I_See;

		npc.m_bInKame = true;
		npc.m_flDoingAnimation = GameTime + STELLA_NC_DURATION + 1.5;
			
		Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		//Target close enough to hit
		if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
		{
			npc.FaceTowards(vecTarget, 20000.0);
		}

		npc.m_flRangedArmor = 0.3;
		npc.m_flMeleeArmor = 0.3;
			
		float flPos[3]; // original
		float flAng[3]; // original
			
		npc.GetAttachment("", flPos, flAng);
		i_particle_effects[npc.index][1] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_portalswirl_purple_parent", npc.index, "", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		i_particle_effects[npc.index][2] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "utaunt_runeprison_yellow_parent", npc.index, "", {0.0,0.0,0.0}));

		CreateTimer(0.75, Donner_Nightmare_Offset, npc.index, TIMER_FLAG_NO_MAPCHANGE);

		switch(npc.m_iNC_Dialogue)
		{
			case 1: Stella_Lines(npc, "I CHOSE 1");
			case 2: Stella_Lines(npc, "I CHOSE 2");
		}

		npc.AddActivityViaSequence("taunt_mourning_mercs_medic");

		npc.SetPlaybackRate(2.0);	
		npc.SetCycle(0.0);

		npc.m_bisWalking = false;
		npc.m_flSpeed = 0.0;

		npc.NC_StartupSound();
	}
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
	EmitSoundToAll("mvm/mvm_tank_ping.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL);
	
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
}
public Action Stella_Nightmare_Tick(int iNPC)
{
	Stella npc = view_as<Stella>(iNPC);

	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNC_Duration<GameTime)
	{
		npc.m_bInKame=false;
		npc.m_flNC_Recharge = GameTime + (npc.Anger ? 45.0 : 60.0);
		npc.SetKarlasRetreat(false);

		if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][1])))	//temp particles
			RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][1]));
		if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][2])))	//temp particles
			RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][2]));
		
		npc.m_bisWalking = true;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_iNC_Dialogue = 0;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		npc.m_bisWalking = true;
		npc.m_iChanged_WalkCycle = 1;
		if(iActivity > 0) npc.StartActivity(iActivity);

		SDKUnhook(npc.index, SDKHook_Think, Stella_Nightmare_Tick);
		return Plugin_Stop;
	}

	int wave = i_current_wave[npc.index];
	bool update = false;

	if(fl_NC_thorttle[npc.index]<GameTime)
	{
		fl_NC_thorttle[npc.index] = GameTime + 0.1;
		update = true;
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
	
	Stella_Create_Spinning_Beams(npc, Start_Loc, angles, 7, Dist, true, radius/2.0, -1.0);		//12

	npc.PlayNightmareSound();

	if(update)	//damage is dealt 10 times a second
	{
		Laser.Radius = radius*0.75;
		Laser.Damage = Modify_Damage(-1, 35.0);
		Laser.Bonus_Damage = Modify_Damage(-1, 35.0)*6.0;
		Laser.damagetype = DMG_PLASMA;
		Laser.Deal_Damage();
	}
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
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, r, g, b, a);
	TE_SetupBeamPoints(Start_Loc, endPoint, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter*1.5), ClampBeamWidth(diameter*0.75), 0, 2.5, glowColor, 0);
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
	return Plugin_Continue;
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
										
			TE_SetupBeamPoints(endLoc, End_Loc, g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 0.25, colorLayer1, 3);
										
			TE_SendToAll();
		}
		
	}
	
	int color[4]; color[0] = 1; color[1] = 255; color[2] = 255; color[3] = 255;
	
	TE_SetupBeamPoints(buffer_vec[1], buffer_vec[loop_for], g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
	TE_SendToAll(0.0);
	for(int i=1 ; i<loop_for ; i++)
	{
		TE_SetupBeamPoints(buffer_vec[i], buffer_vec[i+1], g_Ruina_BEAM_Laser, 0, 0, 0, DONNERKRIEG_TE_DURATION, 5.0, 5.0, 0, 0.01, color, 3);	
		TE_SendToAll(0.0);
	}
	
}
#define DONNERKRIEG_HEAVENS_FALL_MAX_DIST 500.0

#define DONNERKRIEG_HEAVENS_FALL_MAX_AMT 1	//this should always be the highest value of the 3 ones bellow

#define DONNERKRIEG_HEAVENS_FALL_AMT_1 1	//ratios
#define DONNERKRIEG_HEAVENS_FALL_AMT_2 1
#define DONNERKRIEG_HEAVENS_FALL_AMT_3 1

#define DONNERKRIEG_HEAVENS_FALL_MAX_STAGE 5.0	//same thing for this

#define DONNERKRIEG_HEAVENS_STAGE_1 5.0	//ratios
#define DONNERKRIEG_HEAVENS_STAGE_2 1.0
#define DONNERKRIEG_HEAVENS_STAGE_3 5.0


static float DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[2] = {2.5, 5.0};	//Minimum, Maximum Time

static int TE_used;

static void Heavens_Fall(Stella npc, float GameTime, int Infection=0 , bool creep=false)
{

	float Base_Dist=0.0;
	float Distance_Ratios = DONNERKRIEG_HEAVENS_FALL_MAX_DIST/DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;
	if(!Heavens_Fall_Clearance_Check(npc, Base_Dist, DONNERKRIEG_HEAVENS_FALL_MAX_DIST))
	{
		return;
	}

	float Timer = 80.0 *(Base_Dist/DONNERKRIEG_HEAVENS_FALL_MAX_DIST);	//the timer is dynamic to the "power" of this attack, the power is determined by the avalable avg distance which is gotten by clearance check

	if(!npc.Anger)
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer;
	else
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer*0.5;

	if(b_tripple_raid[npc.index])
		fl_heavens_fall_use_timer[npc.index] = GameTime+Timer*1.5;


	int Base_Amt = RoundToFloor((Base_Dist/Distance_Ratios)/DONNERKRIEG_HEAVENS_FALL_MAX_AMT);

	Base_Dist /= DONNERKRIEG_HEAVENS_FALL_MAX_STAGE;	//a lot of ratio stuff, this here makes it actually all dynamic, if you wish to modify it, go to the place where these are defined

	
	int color[4];
	color[3] = 175;

	switch(Infection)
	{
		case 0:
		{
			if(creep)
			{
				color[0] = 54;
				color[1] = 169;
				color[2] = 186;
			}	
			else
			{
				color[0] = 240;
				color[1] = 240;
				color[2] = 240;
			}
		}
		case 1:
		{
			if(creep)
			{
				color[0] = 54;
				color[1] = 85;
				color[2] = 186;
			}
			else
			{
				color[0] = 147;
				color[1] = 199;
				color[2] = 199;
			}
		}
		case 2:
		{
			if(creep)
			{
				color[0] = 39;
				color[1] = 15;
				color[2] = 148;
			}
			else
			{
				color[0] = 147;
				color[1] = 156;
				color[2] = 199;
			}
		}
		case 3:
		{
			if(creep)
			{
				color[0] = 0;
				color[1] = 0;
				color[2] = 255;
			}
			else
			{
				color[0] = 255;
				color[1] = 255;
				color[2] = 255;
			}
		}
	}
	
	

	int Amt1, Amt2, Amt3;
	float Dist1, Dist2, Dist3;

	Dist1 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_1;
	Dist2 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_2;
	Dist3 = Base_Dist*DONNERKRIEG_HEAVENS_STAGE_3;

	Amt1= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_1;
	Amt2= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_2;
	Amt3= Base_Amt*DONNERKRIEG_HEAVENS_FALL_AMT_3;

	TE_used=0;	//set the TE used amt to 0 when we start heavens fall!



	float Loc[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Loc);

	EmitSoundToAll("misc/halloween/gotohell.wav");	//GO TO HELL, AND TELL THE DEVIL, IM COMIN FOR HIM NEXT
	EmitSoundToAll("misc/halloween/gotohell.wav");	//GO TO HELL, AND TELL THE DEVIL, IM COMIN FOR HIM NEXT


	int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);

	float Range = 150.0;

	float UserLoc[3];
	GetAbsOrigin(npc.index, UserLoc);
	UserLoc[2]+=75.0;

	for(int Ion=0 ; Ion < Amt1 ; Ion++)
	{

		float tempAngles[3], EndLoc[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = (360.0/Amt1)*Ion;
		tempAngles[2] = 0.0;

		Do_Trace_Heavens_Fall(Loc, tempAngles, EndLoc, Dist1);

		float dist_check1 = GetVectorDistance(Loc, EndLoc);

		if(dist_check1<Dist1*0.75)	//if the distance is less than we expect or want, abort, same for all the other stages!
			continue;

		for(int Ion2=0 ; Ion2 < Amt2 ; Ion2++)
		{
			float tempAngles2[3], EndLoc2[3];
			tempAngles2[0] = 0.0;
			tempAngles2[1] = (360.0/Amt2)*Ion2;
			tempAngles2[2] = 0.0;

			Do_Trace_Heavens_Fall(EndLoc, tempAngles2, EndLoc2, Dist2);

			float dist_check2 = GetVectorDistance(EndLoc, EndLoc2);

			if(dist_check2<Dist2*0.75)
				continue;
			
			for(int Ion3=0 ; Ion3 < Amt3 ; Ion3++)
			{
				float tempAngles3[3], EndLoc3[3];
				tempAngles3[0] = 0.0;
				tempAngles3[1] = (360.0/Amt3)*Ion3;
				tempAngles3[2] = 0.0;

				Do_Trace_Heavens_Fall(EndLoc2, tempAngles3, EndLoc3, Dist3);

				float dist_check3 = GetVectorDistance(EndLoc2, EndLoc3);

				if(dist_check3<Dist3*0.75)
					continue;

				Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, EndLoc3);	//Make it so the ions appear properly on the ground so its nice

				float Time = GetRandomFloat(DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[0], DONNERKRIEG_HEAVENS_FALL_DETONATION_TIMER[1]);	//make it a bit random so it doesn't all explode at the same time

				
				TE_used += 1;
				if(TE_used > 31)
				{
					int DelayFrames = (TE_used / 32);
					DelayFrames *= 2;
					DataPack pack_TE = new DataPack();
					pack_TE.WriteCell(EndLoc3[0]);
					pack_TE.WriteCell(EndLoc3[1]);
					pack_TE.WriteCell(EndLoc3[2]);
					pack_TE.WriteCell(UserLoc[0]);
					pack_TE.WriteCell(UserLoc[1]);
					pack_TE.WriteCell(UserLoc[2]);
					pack_TE.WriteCell(color[0]);
					pack_TE.WriteCell(color[1]);
					pack_TE.WriteCell(color[2]);
					pack_TE.WriteCell(color[3]);
					pack_TE.WriteCell(SPRITE_INT_2);

					RequestFrames(Doonerkrieg_Delay_TE_Beam2, DelayFrames, pack_TE);
					//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
				}
				else
				{	
					TE_SetupBeamPoints(UserLoc, EndLoc3, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
					TE_SendToAll();
				}
				
				Handle data;
				CreateDataTimer(Time, Smite_Timer_Donner, data, TIMER_FLAG_NO_MAPCHANGE);	//a basic ion timer
				WritePackFloat(data, EndLoc3[0]);
				WritePackFloat(data, EndLoc3[1]);
				WritePackFloat(data, EndLoc3[2]);
				WritePackCell(data, Range); // Range
				WritePackCell(data, EntIndexToEntRef(npc.index));
				WritePackCell(data, Infection);
				WritePackCell(data, color[0]);
				WritePackCell(data, color[1]);
				WritePackCell(data, color[2]);
				WritePackCell(data, color[3]);
				WritePackCell(data, creep);
				

				TE_used += 1;
				if(TE_used > 31)
				{
					int DelayFrames = (TE_used / 32);
					DelayFrames *= 2;
					DataPack pack_TE = new DataPack();
					pack_TE.WriteCell(EndLoc3[0]);
					pack_TE.WriteCell(EndLoc3[1]);
					pack_TE.WriteCell(EndLoc3[2]);
					pack_TE.WriteCell(color[0]);
					pack_TE.WriteCell(color[1]);
					pack_TE.WriteCell(color[2]);
					pack_TE.WriteCell(color[3]);
					pack_TE.WriteCell(Range);
					pack_TE.WriteCell(Time);
					RequestFrames(Doonerkrieg_Delay_TE_Ring, DelayFrames, pack_TE);
					//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
				}
				else
				{
					spawnRing_Vectors(EndLoc3, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", color[0], color[1], color[2], color[3], 1, Time, 6.0, 0.1, 1, 1.0);
				}
			}
		}
	}
	TE_used=0;	//now that the initial heavens fall has been completed, reset this to 0 for the ions TE.
}

static bool Heavens_Fall_Clearance_Check(Stella npc, float &Return_Dist, float Max_Distance)
{
	float UserLoc[3], Angles[3];
	GetAbsOrigin(npc.index, UserLoc);
	Max_Distance+=Max_Distance*0.1;
	float distance = Max_Distance;
	float Distances[361];
	
	int Total_Hit = 0;
	
	for(int alpha = 1 ; alpha<=360 ; alpha++)	//check in a 360 degree angle around the npc, heavy on preformance, but its a raid so I guess its fine..?
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(alpha);
		tempAngles[2] = 0.0;
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, distance);
		AddVectors(UserLoc, Direction, endLoc);
		
		MakeVectorFromPoints(UserLoc, endLoc, Angles);
		GetVectorAngles(Angles, Angles);
		
		float endPoint[3];
	
		//Handle trace = TR_TraceRayFilterEx(UserLoc, Angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
		//if(TR_DidHit(trace))
		{
			//TR_GetEndPosition(endPoint, trace);
			
			float flDistanceToTarget = GetVectorDistance(endPoint, UserLoc);

			Distances[alpha] = flDistanceToTarget;
			
			if(flDistanceToTarget>250.0)	//minimum distance we wish to check, if the traces end is beyond, we count this angle as a valid area.
			{
				Total_Hit++;
				if(flDistanceToTarget>=Max_Distance)
					Distances[alpha]=Max_Distance;
			}
			/*else
			{
				int colour[4];
				colour[0]=150;
				colour[1]=0;
				colour[2]=255;
				colour[3]=125;
				TE_SetupBeamPoints(endPoint, UserLoc, gLaser1, 0, 0, 0, 0.1, 15.0, 15.0, 0, 0.1, colour, 1);
				TE_SendToAll();
			}*/
		}
		//delete trace;
	}
	float Avg=0.0;
	for(int alpha = 1 ; alpha<=360 ; alpha++)
	{
		Avg+=Distances[alpha];
	}
	Avg /=360.0;
	Return_Dist = Avg;
	if(Total_Hit/360>=0.5)	//has to hit atleast 50% before actually proceeding and saying that we have enough clearance
	{
		return true;
	}
	else
	{
		return false;
	}
}

static void Do_Trace_Heavens_Fall(float startPoint[3], float Angles[3], float Loc[3], float Dist)
{

	//Handle trace = TR_TraceRayFilterEx(startPoint, Angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
	//if (TR_DidHit(trace))
	{
		//TR_GetEndPosition(Loc, trace);
		//delete trace;

		float distance = GetVectorDistance(startPoint, Loc);

		if(distance>Dist)
		{
			Get_Fake_Forward_Vec(Dist, Angles, Loc, startPoint);
		}
		
	}
	//else
	{
		//delete trace;
	}
}

public Action Smite_Timer_Donner(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackCell(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	int Infection = ReadPackCell(data);
	int Color[4];
	Color[0] = ReadPackCell(data);
	Color[1] = ReadPackCell(data);
	Color[2] = ReadPackCell(data);
	Color[3] = ReadPackCell(data);
	bool creep  = ReadPackCell(data);

	EmitSoundToAll(g_heavens_fall_strike_sound[GetRandomInt(0, sizeof(g_heavens_fall_strike_sound) - 1)], 0, _, _, _, _, _, -1, startPosition);
	//EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Stella npc = view_as<Stella>(client);

	Doonerkrieg_Do_AOE_Damage(npc, startPosition, 100.0, Ionrange, Infection);

	/*TE_used += 1;
	if(TE_used > 31)
	{
		int DelayFrames = (TE_used / 32);
		DelayFrames *= 2;
		DataPack pack_TE = new DataPack();
		pack_TE.WriteCell(startPosition[0]);
		pack_TE.WriteCell(startPosition[1]);
		pack_TE.WriteCell(startPosition[2]);
		RequestFrames(Doonerkrieg_Delay_TE_Explosion, DelayFrames, pack_TE);
		//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
	}
	else
	{
		TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
		TE_SendToAll();
	}*/

	
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 999.0;
	startPosition[2] += -200;

	float time[4], start[4], end[4];
	time[0]=2.2; start[0] = 30.0; end[0] = 30.0;
	time[1]=2.1; start[1] = 50.0; end[1] = 50.0;
	time[2]=2.0; start[2] = 70.0; end[2] = 70.0;
	time[3]=1.9; start[3] = 90.0; end[3] = 90.0;


	for(int i=0 ; i < 4 ; i ++)
	{
		TE_used += 1;
		if(TE_used > 31)
		{
			int DelayFrames = (TE_used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(startPosition[0]);
			pack_TE.WriteCell(startPosition[1]);
			pack_TE.WriteCell(startPosition[2]);
			pack_TE.WriteCell(position[0]);
			pack_TE.WriteCell(position[1]);
			pack_TE.WriteCell(position[2]);
			pack_TE.WriteCell(Color[0]);
			pack_TE.WriteCell(Color[1]);
			pack_TE.WriteCell(Color[2]);
			pack_TE.WriteCell(Color[3]);
			pack_TE.WriteCell(time[i]);
			pack_TE.WriteCell(start[i]);
			pack_TE.WriteCell(end[i]);
			RequestFrames(Doonerkrieg_Delay_TE_Beam, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			TE_SetupBeamPoints(startPosition, position, g_Ruina_BEAM_Laser, 0, 0, 0, time[i], start[i], end[i], 0, 1.0, Color, 3);
			TE_SendToAll();
		}
	}
	
	return Plugin_Continue;
}



static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Stella npc = view_as<Stella>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(ReturnEntityMaxHealth(npc.index));

	if(!b_angered_twice[npc.index] && Health/MaxHealth<=0.5)
	{
		b_angered_twice[npc.index]=true;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Stella npc = view_as<Stella>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}


	int wave = i_current_wave[npc.index];

	int ally = npc.Ally;
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	if(!b_donner_said_win_line)
	{
		if(wave!=60)
		{
			if(IsValidEntity(ally) && npc.Ally)
			{
				switch(GetRandomInt(1,2))	//warp
				{
					case 1:
					{
						CPrintToChatAll("{aqua}Stella{snow}: Hmph, I'll let {crimson}Karlas{snow} handle this");
					}
					case 2:
					{
						CPrintToChatAll("{aqua}Stella{snow}: You still have {crimson}Karlas{snow} to deal with... heh");
					}
				}
			}
			else
			{
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						CPrintToChatAll("{aqua}Stella{snow}: Hmph, I'll let this slide,{crimson} for now.");
					}
					case 2:
					{
						CPrintToChatAll("{aqua}Stella{snow}: Fine, we're leaving.{crimson} Until next time that is{snow} heh");
					}
				}
			}
		}
		else
		{
			switch(GetRandomInt(1,3))	//warp
			{
				case 1:
				{
					CPrintToChatAll("{aqua}Stella{snow}: Huh, I guess our turn's over");
				}
				case 2:
				{
					CPrintToChatAll("{aqua}Stella{snow}: Oh boy, this is gonna be fun to watch");
				}
				case 3:
				{
					CPrintToChatAll("{aqua}Stella{snow}: I wanted to play with them more, allas");
				}
			}
			
		}
	}

	RaidModeTime +=50.0;


	Donnerkrieg_Delete_Wings(npc);


	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		
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

		//when 7 wearables isn't enough, get 3 more...

	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][0])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][0]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][1])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][1]));
	if(IsValidEntity(EntRefToEntIndex(i_particle_effects[npc.index][2])))	//temp particles
		RemoveEntity(EntRefToEntIndex(i_particle_effects[npc.index][2]));


	
}
static bool b_hit_something;
static bool Is_Target_Infront(Stella npc, float Radius)
{
	b_hit_something=false;
	
	Ruina_Laser_Logic Laser;	//it doesn't deal damage, only detects enemies.
	Laser.client = npc.index;
	float Range = (npc.Anger ? 3000.0 : 1000.0);
	Laser.DoForwardTrace_Basic(Range);
	Laser.Damage = 0.0;
	Laser.Radius = Radius;
	Laser.Bonus_Damage = 0.0;
	Laser.Deal_Damage(On_LaserHit);

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
static void Self_Defense(Stella npc, float flDistanceToTarget)
{
	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNC_Grace > GameTime)
	{
		float Grace_Time = npc.m_flNC_Grace - GameTime;
		if(Grace_Time < 1.5)
		{
			npc.m_flNorm_Attack_In = 0.0;
			npc.m_flNorm_Attack_Duration = GameTime + 1.0;
			return;
		}
	}
	

	float Range = (npc.Anger ? 3000.0 : 1000.0);

	float Attack_Speed = 3.0;	//how often she attacks.
	float Attack_Delay = 1.0;	//how long until she actually attacks
	float Attack_Time = 0.7;	//how long the normal attack laser lasts

	if(npc.m_flNorm_Attack_In > GameTime)
		npc.m_bAllowBackWalking = true;

	//target is too far, and we are a not about to fire a laser, return.
	if(npc.m_flNorm_Attack_In == 0.0 && flDistanceToTarget > Range*Range)
	{
		return;
	}

	//target within range, and out laser is recharged.
	if(npc.m_flNextRangedAttack < GameTime)
	{
		if(!Is_Target_Infront(npc, 50.0))
			return;

		npc.m_flNorm_Attack_In = GameTime + Attack_Delay;
		npc.m_flNextRangedAttack = GameTime + Attack_Speed;
		int color[4]; Ruina_Color(color);
		float self_Vec[3]; WorldSpaceCenter(npc.index, self_Vec);
		TE_SetupBeamRingPoint(self_Vec, 300.0, 0.0, g_Ruina_Laser_BEAM, g_Ruina_Laser_BEAM, 0, 1, Attack_Delay, 15.0, 0.1, color, 1, 0);
		TE_SendToAll();

		npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
		npc.PlayMeleeSound();
	}

	if(npc.m_flNorm_Attack_In != 0.0 && npc.m_flNorm_Attack_In < GameTime)
	{
		npc.m_flNorm_Attack_In = 0.0;
		npc.m_flNorm_Attack_Duration = GameTime + Attack_Time;
		Fire_Laser(npc);
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
		SDKUnhook(npc.index, SDKHook_Think, Normal_Laser_Think);
		return Plugin_Stop;
	}

	npc.m_bAllowBackWalking = true;

	bool Silence = NpcStats_IsEnemySilenced(npc.index);

	float Range = (npc.Anger ? 3000.0 : 1000.0);
	int target = i_Get_Laser_Target(npc, Range);
	if(IsValidEnemy(npc.index, target))
	{
		float Bonus_Speed_Range = 300.0*300.0;
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float Self_Vec[3]; WorldSpaceCenter(npc.index, Self_Vec);
		float Dist = GetVectorDistance(vecTarget, Self_Vec, true);

		float Turn_Rate = (npc.Anger ? 0.4 : 0.25);
		float Turn_Speed = (RUINA_FACETOWARDS_BASE_TURNSPEED*Turn_Rate);
		
		if(Dist <= 0.0)
			Dist = 1.0;

		if(Dist < Bonus_Speed_Range)
		{
			Turn_Speed*= ((1.0-(Dist/Bonus_Speed_Range))*4.2);
		}

		if(Silence)
			Turn_Speed *= 0.95;

		Turn_Rate /= TickrateModify;
		npc.FaceTowards(vecTarget, Turn_Speed);
	}
		

	float radius = 10.0;

	Ruina_Laser_Logic Laser;
	if(Silence)
		Range *=0.95;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Basic(Range);
	Laser.Damage = Modify_Damage(-1, 15.0)/TickrateModify;
	Laser.Radius = radius;
	Laser.Bonus_Damage = (Modify_Damage(-1, 15.0)*6.0)/TickrateModify;
	Laser.damagetype = DMG_PLASMA;
	Laser.Deal_Damage();

	int wave = i_current_wave[npc.index];

	float startPoint[3], endPoint[3];
	float flPos[3], flAng[3];
	npc.GetAttachment("effect_hand_r", flPos, flAng);
	startPoint  = flPos;
	endPoint	= Laser.End_Point;

	float diameter = radius *1.0;
	int color[4];
	Ruina_Color(color);

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
#define DONNERKRIEG_PARTICLE_EFFECT_AMT 30
static int i_donner_particle_index[MAXENTITIES][DONNERKRIEG_PARTICLE_EFFECT_AMT];

static void Donnerkrieg_Delete_Wings(Stella npc)
{

	for(int i=0 ; i < DONNERKRIEG_PARTICLE_EFFECT_AMT ; i++)
	{
		int particle = EntRefToEntIndex(i_donner_particle_index[npc.index][i]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		i_donner_particle_index[npc.index][i]=INVALID_ENT_REFERENCE;
	}
}

static void Donnerkrieg_Wings_Create(Stella npc)	//I wish these wings were real, but allas, Donnerkrieg can't into space
{

	if(AtEdictLimit(EDICT_RAID))
		return;

	Donnerkrieg_Delete_Wings(npc);

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];


	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(npc.index, "back_lower", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(npc.index, ParticleOffsetMain, "back_lower",_);


	//Left

	float core_loc[3] = {0.0, 15.0, -20.0};


	//upper left

	int particle_upper_left_core = InfoTargetParentAt(core_loc, "", 0.0);


	
	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_upper_left_wing_1 = InfoTargetParentAt({7.5, 0.0, -9.5}, "", 0.0);	//middle mid
	int particle_upper_left_wing_2 = InfoTargetParentAt({20.5, 10.0, -15.0}, "", 0.0);		//middle lower
	int particle_upper_left_wing_3 = InfoTargetParentAt({5.0, -25.0, 0.0}, "", 0.0);		//middle up	

	int particle_upper_left_wing_4 = InfoTargetParentAt({50.0, -15.0, 5.0}, "", 0.0);	//side up
	int particle_upper_left_wing_5 = InfoTargetParentAt({60.0, -10.0, 10.0}, "", 0.0);	//side mid
	int particle_upper_left_wing_6 = InfoTargetParentAt({55.0, 0.0, 2.5}, "", 0.0);	//side low


	SetParent(particle_upper_left_core, particle_upper_left_wing_1, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_2, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_3, "",_, true);

	SetParent(particle_upper_left_core, particle_upper_left_wing_4, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_5, "",_, true);
	SetParent(particle_upper_left_core, particle_upper_left_wing_6, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_upper_left_core, flPos);
	SetEntPropVector(particle_upper_left_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_upper_left_core, "",_);

	//start_1 = 2.0;
	//end_1 = 0.5;
	//amp =0.1;

	int laser_upper_left_wing_1 = ConnectWithBeamClient(particle_upper_left_wing_1, particle_upper_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);
	int laser_upper_left_wing_2 = ConnectWithBeamClient(particle_upper_left_wing_1, particle_upper_left_wing_3, red, green, blue, start_1, start_1, amp, LASERBEAM);
	
	int laser_upper_left_wing_3 = ConnectWithBeamClient(particle_upper_left_wing_5, particle_upper_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_upper_left_wing_4 = ConnectWithBeamClient(particle_upper_left_wing_5, particle_upper_left_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_upper_left_wing_5 = ConnectWithBeamClient(particle_upper_left_wing_3, particle_upper_left_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_upper_left_wing_6 = ConnectWithBeamClient(particle_upper_left_wing_2, particle_upper_left_wing_6, red, green, blue, start_1, end_1, amp, LASERBEAM);

	int laser_upper_left_wing_7 = ConnectWithBeamClient(particle_upper_left_wing_4, particle_upper_left_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);


	
	i_donner_particle_index[npc.index][0] = EntIndexToEntRef(ParticleOffsetMain);
	i_donner_particle_index[npc.index][1] = EntIndexToEntRef(particle_upper_left_core);
	i_donner_particle_index[npc.index][2] = EntIndexToEntRef(laser_upper_left_wing_1);
	i_donner_particle_index[npc.index][3] = EntIndexToEntRef(laser_upper_left_wing_2);
	i_donner_particle_index[npc.index][4] = EntIndexToEntRef(laser_upper_left_wing_3);
	i_donner_particle_index[npc.index][5] = EntIndexToEntRef(laser_upper_left_wing_4);
	i_donner_particle_index[npc.index][6] = EntIndexToEntRef(laser_upper_left_wing_5);
	i_donner_particle_index[npc.index][7] = EntIndexToEntRef(laser_upper_left_wing_6);
	i_donner_particle_index[npc.index][8] = EntIndexToEntRef(laser_upper_left_wing_7);

	i_donner_particle_index[npc.index][9] = EntIndexToEntRef(particle_upper_left_wing_1);
	i_donner_particle_index[npc.index][10] = EntIndexToEntRef(particle_upper_left_wing_2);
	i_donner_particle_index[npc.index][11] = EntIndexToEntRef(particle_upper_left_wing_3);
	i_donner_particle_index[npc.index][12] = EntIndexToEntRef(particle_upper_left_wing_4);
	i_donner_particle_index[npc.index][13] = EntIndexToEntRef(particle_upper_left_wing_5);
	i_donner_particle_index[npc.index][14] = EntIndexToEntRef(particle_upper_left_wing_6);


	//upper right

	int particle_upper_right_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	int particle_upper_right_wing_1 = InfoTargetParentAt({-7.5, 0.0, -9.5}, "", 0.0);	//middle mid
	int particle_upper_right_wing_2 = InfoTargetParentAt({-20.5, 10.0, -15.0}, "", 0.0);		//middle lower
	int particle_upper_right_wing_3 = InfoTargetParentAt({-5.0, -25.0, 0.0}, "", 0.0);		//middle up	

	int particle_upper_right_wing_4 = InfoTargetParentAt({-50.0, -15.0, 5.0}, "", 0.0);	//side up
	int particle_upper_right_wing_5 = InfoTargetParentAt({-60.0, -10.0, 10.0}, "", 0.0);	//side mid
	int particle_upper_right_wing_6 = InfoTargetParentAt({-55.0, 0.0, 2.5}, "", 0.0);	//side low


	SetParent(particle_upper_right_core, particle_upper_right_wing_1, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_2, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_3, "",_, true);

	SetParent(particle_upper_right_core, particle_upper_right_wing_4, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_5, "",_, true);
	SetParent(particle_upper_right_core, particle_upper_right_wing_6, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_upper_right_core, flPos);
	SetEntPropVector(particle_upper_right_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_upper_right_core, "",_);

	//start_1 = 2.0;
	//end_1 = 0.5;
	//amp =0.1;

	int laser_upper_right_wing_1 = ConnectWithBeamClient(particle_upper_right_wing_1, particle_upper_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);
	int laser_upper_right_wing_2 = ConnectWithBeamClient(particle_upper_right_wing_1, particle_upper_right_wing_3, red, green, blue, start_1, start_1, amp, LASERBEAM);
	
	int laser_upper_right_wing_3 = ConnectWithBeamClient(particle_upper_right_wing_5, particle_upper_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_upper_right_wing_4 = ConnectWithBeamClient(particle_upper_right_wing_5, particle_upper_right_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_upper_right_wing_5 = ConnectWithBeamClient(particle_upper_right_wing_3, particle_upper_right_wing_4, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_upper_right_wing_6 = ConnectWithBeamClient(particle_upper_right_wing_2, particle_upper_right_wing_6, red, green, blue, start_1, end_1, amp, LASERBEAM);

	int laser_upper_right_wing_7 = ConnectWithBeamClient(particle_upper_right_wing_4, particle_upper_right_wing_6, red, green, blue, end_1, end_1, amp, LASERBEAM);

	i_donner_particle_index[npc.index][15] = EntIndexToEntRef(particle_upper_right_core);
	i_donner_particle_index[npc.index][16] = EntIndexToEntRef(laser_upper_right_wing_1);
	i_donner_particle_index[npc.index][17] = EntIndexToEntRef(laser_upper_right_wing_2);
	i_donner_particle_index[npc.index][18] = EntIndexToEntRef(laser_upper_right_wing_3);
	i_donner_particle_index[npc.index][19] = EntIndexToEntRef(laser_upper_right_wing_4);
	i_donner_particle_index[npc.index][20] = EntIndexToEntRef(laser_upper_right_wing_5);
	i_donner_particle_index[npc.index][21] = EntIndexToEntRef(laser_upper_right_wing_6);
	i_donner_particle_index[npc.index][22] = EntIndexToEntRef(laser_upper_right_wing_7);

	i_donner_particle_index[npc.index][23] = EntIndexToEntRef(particle_upper_right_wing_1);
	i_donner_particle_index[npc.index][24] = EntIndexToEntRef(particle_upper_right_wing_2);
	i_donner_particle_index[npc.index][25] = EntIndexToEntRef(particle_upper_right_wing_3);
	i_donner_particle_index[npc.index][26] = EntIndexToEntRef(particle_upper_right_wing_4);
	i_donner_particle_index[npc.index][27] = EntIndexToEntRef(particle_upper_right_wing_5);
	i_donner_particle_index[npc.index][28] = EntIndexToEntRef(particle_upper_right_wing_6);
}

static float ion_damage[MAXENTITIES];
static void Doonerkrieg_Do_AOE_Damage(Stella npc, float loc[3], float damage, float Range, int infection = 0, bool shake=true)
{
	ion_damage[npc.index] = 1.0;
	switch(infection)
	{
		case 0:
		{
			if(shake)
				Explode_Logic_Custom(damage, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5, Donner_Normal_Tweak);
			else
				Explode_Logic_Custom(damage, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5);
		}
		case 1:
		{
			
			int neural_damage = RoundToFloor(damage*0.1);
			if(neural_damage < 4)
				neural_damage = 4;

			ion_damage[npc.index] = float(neural_damage);

			if(shake)
				Explode_Logic_Custom(damage*0.5, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5, Donner_Neural_Tweak_shake);
			else
				Explode_Logic_Custom(damage*0.5, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 2.5, Donner_Neural_Tweak);
		}
		case 2:
		{
			int neural_damage = RoundToFloor(damage*0.1);
			if(neural_damage < 8)
				neural_damage = 8;

			ion_damage[npc.index] = float(neural_damage);

			if(shake)
				Explode_Logic_Custom(5.0, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 1.0, Donner_Neural_Tweak_shake);
			else
				Explode_Logic_Custom(5.0, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 1.0, Donner_Neural_Tweak);
		}
		case 3:
		{

			if(shake)
				Explode_Logic_Custom(damage * 0.5, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 1.0, ManaSicknessTweak_Shake);
			else
				Explode_Logic_Custom(damage * 0.5, npc.index, npc.index, -1, loc, Range , _ , _ , true, _, _, 1.0, ManaSicknessTweak);
		}
	}
}
static void ManaSicknessTweak(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
	Ruina_Add_Mana_Sickness(entity, victim, 0.0, RoundToCeil(damage*0.05), true);
}
static void ManaSicknessTweak_Shake(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim))
	{
		Client_Shake(victim);
		Ruina_Add_Mana_Sickness(entity, victim, 0.0, RoundToCeil(damage*0.05), true);
	}	
	
}
public void Donner_Normal_Tweak(int entity, int victim, float damage, int weapon)
{	
	if(IsValidClient(victim))
	{
		Client_Shake(victim);
	}
}
public void Donner_Neural_Tweak(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(victim))
	{
		int neural_damage = RoundToFloor(ion_damage[entity]);
		Elemental_AddNervousDamage(victim, entity, neural_damage, false, true);
	}
}
public void Donner_Neural_Tweak_shake(int entity, int victim, float damage, int weapon)
{
	if(IsValidEntity(victim))
	{
		int neural_damage = RoundToFloor(ion_damage[entity]);
		Elemental_AddNervousDamage(victim, entity, neural_damage, false, true);
		if(IsValidClient(victim))
			Client_Shake(victim);
	}
}

/*
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
	//see if the vectors match up, if they do we can safely say the enemy gamer is in sight of the crystal.
	if(Similar_Vec(Trace_Loc, Enemy_Loc))
		return enemy;
	else
		return -1;
}
*/

static void Donnerkrieg_Say_Lines(Stella npc, int line_type)
{
	char name_color[] = "aqua";
	char text_color[] = "snow";
	char danger_color[] = "crimson";

	char text_lines[255];

	char extra_lines[255]; extra_lines = "";
	

			extra_lines = "...";
			switch(GetRandomInt(1,9))
			{
				case 1:
				{
					//CPrintToChatAll("{%s}Stella{%s}: {%s}Thats it {%s}i'm going to kill you", name_color, text_color, name_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}Thats it {%s}i'm going to kill you{%s}.", name_color, text_color, name_color, danger_color, text_color);	
				}
				case 2:
				{
					//CPrintToChatAll("{%s}Stella{%s}: {%s}hm, {%s}Wonder how this will end...", name_color, text_color, danger_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}hm, {%s}Wonder how this will end...", name_color, text_color, danger_color, text_color);	
				}
				case 3:
				{
					//CPrintToChatAll("{%s}Stella{%s}: {%s}PREPARE {%s}Thyself, {%s}Judgement {%s}Is near", name_color, text_color, danger_color, name_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}PREPARE {%s}Thyself, {%s}Judgement {%s}Is near{%s}.", name_color, text_color, danger_color, name_color, text_color, danger_color, text_color);		
				}
				case 4:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							//CPrintToChatAll("{%s}Stella{%s}: Oh not again now train's gone and {%s}Left{%s}.", name_color, text_color, danger_color, text_color);	
							Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Oh not again now train's gone and {%s}Left{%s}.", name_color, text_color, danger_color, text_color);	
						}				
						default:
						{
							//CPrintToChatAll("{%s}Stella{%s}: Oh not again now cannon's gone and {%s}recharged{%s}.", name_color, text_color, danger_color, text_color);	
							Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Oh not again now cannon's gone and {%s}recharged{%s}.", name_color, text_color, danger_color, text_color);	
						}
					}
				}
				case 5: 
				{
					//CPrintToChatAll("{%s}Stella{%s}: Aiming this thing is actually quite {%s}complex {%s}ya know.", name_color, text_color, danger_color, text_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Aiming this thing is actually quite {%s}complex {%s}ya know.", name_color, text_color, danger_color, text_color);
					//b_fuck_you_line_used[npc.index] = true;
				}
				case 6:
				{
					//CPrintToChatAll("{%s}Stella{%s}: Ya know, im getting quite bored of {%s}this", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Ya know, im getting quite bored of {%s}this{%s}.", name_color, text_color, danger_color, text_color);	
				}
				case 7:
				{
					//CPrintToChatAll("{%s}Stella{%s}: Ya know, im getting quite bored of {%s}this", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Oh how {%s}Tiny{%s} you all look from up here.", name_color, text_color, danger_color, text_color);	
				}
				case 8:
				{
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: heh {%s}This is{%s} gonna be funny.", name_color, text_color, danger_color, text_color);	
				}
				case 9:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}Oya{%s}?", name_color, text_color, danger_color, text_color);	
						}				
						default:
						{
							Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: Aya, how troublesome {%s}this is{%s}.", name_color, text_color, danger_color, text_color);	
						}
					}
				}
			}

			//if(!b_fuck_you_line_used[npc.index] && !b_train_line_used[npc.index])
			{	
				switch(GetRandomInt(1,6))
				{
					case 1:
					{
						//CPrintToChatAll("{%s}Stella{%s}: {%s}NIGHTMARE, CANNON!", name_color, text_color, danger_color);
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}NIGHTMARE, CANNON{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 2:
					{
						//CPrintToChatAll("{%s}Stella{%s}: {%s}JUDGEMENT BE UPON THEE!", name_color, text_color, danger_color);
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}JUDGEMENT BE UPON THEE{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 3:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}COSMIC ANNIHILATION{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 4:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}DIVINE RETRIBUTION{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 5:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}CALL OF THE BEYOND{%s}!", name_color, text_color, danger_color, text_color);
					}
					case 6:
					{
						Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}PUNISHMENT OF HER {%s}GRACE{%s}!", name_color, text_color, danger_color, name_color, text_color);
					}
				}
			}
			//else
			{
				/*if(b_train_line_used[npc.index])
				{
					//CPrintToChatAll("{%s}Stella{%s}: {%s}And the city's to far to walk to the end while I...", name_color, text_color, danger_color);	
					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: {%s}And the city's to far to walk to the end while I...", name_color, text_color, danger_color);	
					b_train_line_used[npc.index] = false;
					extra_lines = "...";
				}
				else if(b_fuck_you_line_used[npc.index])
				{
					b_fuck_you_line_used[npc.index] = false;
					//CPrintToChatAll("{%s}Stella{%s}: However its still{%s} worth the effort", name_color, text_color, danger_color);	

					Format(text_lines, sizeof(text_lines), "{%s}Stella{%s}: However its still{%s} worth the effort{%s}.", name_color, text_color, danger_color, text_color);	
					extra_lines = "";
				}*/
				
			}

	CPrintToChatAll(text_lines);
	NpcSpeechBubble(npc.index, "", 15, {255,0,0,255}, {0.0,0.0,125.0}, extra_lines);
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
static void Stella_Lines(Stella npc, const char[] text)
{
	if(b_test_mode[npc.index])
		return;

	CPrintToChatAll("%s %s", npc.GetName(), text);
}