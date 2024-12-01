#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_specialcompleted01.mp3",
	"vo/sniper_specialcompleted02.mp3",
	"vo/sniper_specialcompleted03.mp3",
	"vo/sniper_specialcompleted04.mp3",
	"vo/sniper_specialcompleted05.mp3",
	"vo/sniper_specialcompleted06.mp3",
	"vo/sniper_specialcompleted07.mp3",
	"vo/sniper_specialcompleted08.mp3",
	"vo/sniper_specialcompleted09.mp3",
	"vo/sniper_specialcompleted10.mp3",
	"vo/sniper_specialcompleted11.mp3",
	"vo/sniper_specialcompleted12.mp3",
	"vo/sniper_specialcompleted13.mp3",
	"vo/sniper_specialcompleted14.mp3",
	"vo/sniper_specialcompleted15.mp3",
	"vo/sniper_specialcompleted17.mp3",
	"vo/sniper_specialcompleted18.mp3",
	"vo/sniper_specialcompleted19.mp3",
	"vo/sniper_specialcompleted21.mp3",
	"vo/sniper_specialcompleted22.mp3",
	"vo/sniper_specialcompleted23.mp3",
	"vo/sniper_specialcompleted24.mp3",
	"vo/sniper_specialcompleted25.mp3",
	"vo/sniper_specialcompleted26.mp3",
	"vo/sniper_specialcompleted27.mp3",
	"vo/sniper_specialcompleted28.mp3",
	"vo/sniper_specialcompleted29.mp3",
	"vo/sniper_specialcompleted30.mp3",
	"vo/sniper_specialcompleted31.mp3",
	"vo/sniper_specialcompleted32.mp3",
	"vo/sniper_specialcompleted33.mp3",
	"vo/sniper_specialcompleted34.mp3",
	"vo/sniper_specialcompleted35.mp3",
	"vo/sniper_specialcompleted36.mp3",
	"vo/sniper_specialcompleted37.mp3",
	"vo/sniper_specialcompleted38.mp3",
	"vo/sniper_specialcompleted39.mp3",
	"vo/sniper_specialcompleted40.mp3",
	"vo/sniper_specialcompleted41.mp3",
	"vo/sniper_specialcompleted42.mp3",
	"vo/sniper_specialcompleted43.mp3",
	"vo/sniper_specialcompleted44.mp3",
	"vo/sniper_specialcompleted45.mp3",
	"vo/sniper_specialcompleted46.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};
static const char g_MG42AttackSounds[][] = {
	"weapons/csgo_awp_shoot.wav",
};
static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/scout_revenge06.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_HomerunSounds[][]= {
	"vo/sniper_jaratetoss02/mp3",
	"vo/sniper_jaratetoss03/mp3",
};
static const char g_LasershotReady[][]= {
	"vo/sniper_dominationengineer03.mp3",
	"vo/sniper_dominationengineer05.mp3",
	"vo/sniper_goodjob01.mp3"
};
static const char g_PlayRocketshotready[][] = {
	"vo/sniper_specialcompleted20.mp3",
	"vo/sniper_specialcompleted16.mp3",
	"vo/sniper_dominationsoldier02.mp3"

};
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float FTL[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static int i_AmountProjectiles[MAXENTITIES];
static float fl_said_player_weaponline_time[MAXENTITIES];

void Harrison_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Harrison");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_harrison");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_atomizer_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MG42AttackSounds)); i++) { PrecacheSound(g_MG42AttackSounds[i]); }
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	for (int i = 0; i < (sizeof(g_HomerunSounds));   i++) { PrecacheSound(g_HomerunSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PlayRocketshotready));   i++) { PrecacheSound(g_PlayRocketshotready[i]);   }
	for (int i = 0; i < (sizeof(g_LasershotReady));   i++) { PrecacheSound(g_LasershotReady[i]);   }
	PrecacheModel("models/player/sniper.mdl");
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_atomizer.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Harrison(client, vecPos, vecAng, ally, data);
}

static int i_Harrison_eye_particle[MAXENTITIES];

methodmap Harrison < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayRocketshotready() {
	
		int sound = GetRandomInt(0, sizeof(g_PlayRocketshotready) - 1);
		EmitSoundToAll(g_PlayRocketshotready[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerReaction() {
	
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunHitSound() {
	
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunSound() {
	
		EmitSoundToAll(g_HomerunSounds[GetRandomInt(0, sizeof(g_HomerunSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunSounds[GetRandomInt(0, sizeof(g_HomerunSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunMissSound() {
	
		EmitSoundToAll(g_LasershotReady[GetRandomInt(0, sizeof(g_LasershotReady) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_LasershotReady[GetRandomInt(0, sizeof(g_LasershotReady) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound()
	{
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,125));
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_MG42AttackSounds[GetRandomInt(0, sizeof(g_MG42AttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	property float m_flTimeUntillSummonRocket
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flTimeUntillDroneSniperShot
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flTimeUntillNextRailgunShots
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flTimeUntillGunReload
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}

	public Harrison(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Harrison npc = view_as<Harrison>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 300.0;
		Delay_Attribute[npc.index] = 0.0;
		YaWeFxxked[npc.index] = false;
		ParticleSpawned[npc.index] = false;
		I_cant_do_this_all_day[npc.index] = 0;
		npc.i_GunMode = 0;
		npc.m_flTimeUntillNextRailgunShots = GetGameTime() + 22.5;
		npc.m_flTimeUntillSummonRocket = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 10.0;
		npc.m_flTimeUntillDroneSniperShot = GetGameTime() + 5.0;
		npc.m_flTimeUntillGunReload = GetGameTime() + 12.5;
		npc.m_iOverlordComboAttack = 0;
		npc.m_iAmountProjectiles = 0;
		npc.m_iAttacksTillReload = 0;
		
		npc.m_fbRangedSpecialOn = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		Victoria_Support_RechargeTimeMax(npc.index, 20.0);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		b_angered_twice[npc.index] = false;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Harrison Arrived");
			}
		}
		FTL[npc.index] = 200.0;
		RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(ZR_GetWaveCount()+1 > 55)
		{
			FTL[npc.index] = 220.0;
			RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
			RaidModeScaling *= 0.65;
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_atomizer.mp3");
		music.Time = 128;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Hard to Ignore");
		strcopy(music.Artist, sizeof(music.Artist), "UNFINISH");
		Music_SetRaidMusic(music);
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		CPrintToChatAll("{blue}%s{default}: Intruders in sight, I won't let the get out alive!", c_NpcName[npc.index]);

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/all_class/pet_robro.mdl");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/sniper/invasion_starduster/invasion_starduster.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/pyro_hazmat_4/pyro_hazmat_4_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 50, 50, 50, 255);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/sniper/xms2013_sniper_jacket/xms2013_sniper_jacket.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable6, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable6, 50, 50, 50, 255);

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/engineer/sum24_daring_dell_style3/sum24_daring_dell_style3.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable7, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({150, 150, 150, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		CPrintToChatAll("{blue}Harrison{default}: Intruders in sight, I won't let the get out alive!");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Harrison npc = view_as<Harrison>(iNPC);
	float gameTime = GetGameTime(npc.index);
	//bool GETVictoria_Support = Victoria_Support(npc);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_Harrison_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}	

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{blue}Harrison{default}: Ready to die?");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Harrison{default}: You can't run forever.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Harrison{default}: All of your comrades are fallen.");
				}
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		npc.m_flMeleeArmor = 0.33;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{blue}Harrison{default}: Victoria will be in peace. Once and for all.");
			case 2:CPrintToChatAll("{blue}Harrison{default}: The troops have arrived and will begin destroying the intruders!");
			case 3:CPrintToChatAll("{blue}Harrison{default}: Backup team has arrived. Catch those damn bastards!");
			case 4:CPrintToChatAll("{blue}Harrison{default}: After this, Im heading to Rusted Bolt Pub. {unique}I need beer.{default}");
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_batter",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_charger",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_teslar",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_victorian_vanguard",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_supplier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_ballista",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_grenadier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 8))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_humbee",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_shotgunner",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_bulldozer",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_hardener",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_raider",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_zapper",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_payback",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 8:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_blocker",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		BlockLoseSay = true;
		YaWeFxxked[npc.index] = true;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(npc.m_flTimeUntillGunReload < gameTime)
	{
		npc.m_iAttacksTillReload =  RoundToNearest(float(CountPlayersOnRed(2)) * 5); 
		npc.m_flTimeUntillGunReload = 30.0 + gameTime;
	}
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = HarrisonSelfDefense(npc,gameTime, npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
	{
		HarrisonAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Harrison npc = view_as<Harrison>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.33 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.m_fbRangedSpecialOn)
		{
			I_cant_do_this_all_day[npc.index]=0;
			f_VictorianCallToArms[npc.index] = GetGameTime() + 999.0;
			IncreaceEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			FTL[npc.index] += 25.0;
			RaidModeTime += 25.0;
			npc.PlayAngerReaction();
		}
	}

	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Harrison npc = view_as<Harrison>(entity);
	/*
		Explode on death code here please

	*/
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	switch(GetRandomInt(0,2))
	{
		case 0:CPrintToChatAll("{blue}Harrison{default}: Ugh, I need backup");
		case 1:CPrintToChatAll("{blue}Harrison{default}: I will never let you trample over the glory of {gold}Victoria{default} Again!");
		case 2:CPrintToChatAll("{blue}Harrison{default}: You intruders will soon face the {crimson}Real Deal.{default}");
	}

}

static void HarrisonAnimationChange(Harrison npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
		npc.m_iChanged_WalkCycle = -1;
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					ResetHarrisonWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					ResetHarrisonWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ResetHarrisonWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ResetHarrisonWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

static int HarrisonSelfDefense(Harrison npc, float gameTime, int target, float distance)
{
	if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
	{
		npc.i_GunMode = 0;
		bool playsounds=false;
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_i_see_you_primary");
				npc.PlayRocketshotready()
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.5);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flTimeUntillSummonRocket = 1.5;
				I_cant_do_this_all_day[npc.index]=1;
			}
			case 1:
			{
				UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
				int enemy[8];
				GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
				for(int i; i < sizeof(enemy); i++)
				{
					for(int k; k < (NpcStats_VictorianCallToArms(npc.index) ? 2 : 1); k++)
					{
						if(enemy[i])
						{
							DataPack pack;
							CreateDataTimer(npc.m_flTimeUntillSummonRocket, Timer_Quad_Rocket_Shot, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
							pack.WriteCell(EntIndexToEntRef(npc.index));
							pack.WriteCell(EntIndexToEntRef(enemy[i]));
							npc.m_flTimeUntillSummonRocket += 1.5;
							playsounds=true;
						}
					}
				}
				I_cant_do_this_all_day[npc.index]=2;
			}
			case 2:
			{
				if(playsounds)npc.PlayHomerunSound();
				I_cant_do_this_all_day[npc.index]=0;
				npc.m_flTimeUntillSummonRocket = 0.0;
				npc.m_flNextRangedSpecialAttackHappens = gameTime + 30.0;
				npc.m_flTimeUntillNextRailgunShots = gameTime + 2.0;
			}
		}
		return 1;
	}
	else if(npc.m_flTimeUntillNextRailgunShots < gameTime)
	{
		float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
		float projectile_speed = 800.0;

		npc.m_flNextRangedSpecialAttackHappens = gameTime + 4.0;

		PredictSubjectPositionForProjectiles(npc, target, projectile_speed, 40.0, vecTarget);
		if(!Can_I_See_Enemy_Only(npc.index, target)) //cant see enemy in the predicted position, we will instead just attack normally
		{
			WorldSpaceCenter(target, vecTarget );
		}

		float flPos[3];
		float flAng[3];
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		//float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		if(npc.m_iOverlordComboAttack < 6)
		{
			npc.m_iOverlordComboAttack += 1;
			HarrisonInitiateLaserAttack(npc.index, vecTarget, flPos); //laser finger!
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flTimeUntillNextRailgunShots = gameTime + 0.5;
		}
		else
		{
			npc.m_flTimeUntillNextRailgunShots = gameTime + 22.5;
			npc.m_iOverlordComboAttack = 0;
		}
		
	}
	else if(npc.m_flTimeUntillDroneSniperShot < gameTime)
	{
		if(npc.m_flNextRangedAttack < gameTime)
		{	
			npc.m_iAmountProjectiles += 1;
			npc.m_flNextRangedAttack = gameTime + 0.1;
			npc.PlayRangedSound();

			float flPos[3], flAng[3];
					
			npc.GetAttachment("head", flPos, flAng);

			//float flPos[3]; GetEntPropVector(npc.index, Prop_Data, "head", flPos);
			float flPosEdit[3]; 
			flPosEdit = flPos;
			flPosEdit[0] += 15.0;
			flPosEdit[1] += 25.0;
			flPosEdit[2] += 5.0;

			float RocketDamage = 100.0;
			float RocketSpeed = 900.0;
			float Radius = 250.0;
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
			float vecDest[3];
			vecDest = vecTarget;
			vecDest[0] += GetRandomFloat(-50.0, 50.0);
			vecDest[1] += GetRandomFloat(-50.0, 50.0);
			vecDest[2] += GetRandomFloat(-50.0, 50.0);
						
			npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling , RocketSpeed , Radius , "raygun_projectile_blue_crit", true,_, true, flPosEdit);
			if (npc.m_iAmountProjectiles >= 10)
			{
				npc.m_iAmountProjectiles = 0;
				npc.m_flTimeUntillDroneSniperShot = gameTime + 15.0;
			}
		}
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			if(npc.m_iAttacksTillReload > 0)
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(IsValidEnemy(npc.index, target))
					{
						npc.PlayGunSound();
						npc.FaceTowards(vecTarget, 20000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
						{
							target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							float origin[3], angles[3];
							view_as<CClotBody>(npc.index).GetAttachment("effect_hand_r", origin, angles);
							ShootLaser(npc.index, "bullet_tracer02_blue_crit", origin, vecHit, false );

							if(IsValidEnemy(npc.index, target))
							{
								float damageDealt = 5.0;

								SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt * RaidModeScaling, DMG_BULLET, -1, _, vecHit);
							}
							npc.m_iAttacksTillReload -= 1;
						}
						delete swingTrace;
					}
				}
			}
			else
			{
				if(IsValidEnemy(npc.index, target))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
					npc.FaceTowards(VecEnemy, 15000.0);
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					bool PlaySound = false;
					for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
					{
						if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
						{
							if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
							{
								PlaySound = true;
								int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								
								WorldSpaceCenter(targetTrace, vecHit);

								float damage = 70.0;
								damage *= 1.15;

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										if(target > MaxClients)
										{
											StartBleedingTimer_Against_Client(target, npc.index, 15.0, 10);
										}
										else
										{
											if (!IsInvuln(target))
											{
												StartBleedingTimer_Against_Client(target, npc.index, 15.0, 10);
											}
										}
									}
								}
											
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 150.0, true); 
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
				}
			}
		}
	}
	//Melee attack, last prio
	else if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 12.5) && npc.m_iAttacksTillReload > 0)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					
					float time = 0.1;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						time *= 0.75;
					}
					npc.m_flAttackHappens = gameTime + time;
					npc.m_flNextMeleeAttack = gameTime + time;
					npc.m_flDoingAnimation = gameTime + time;
				}
			}
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.0;
					npc.m_flDoingAnimation = gameTime + 0.25;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	if(npc.m_iAttacksTillReload >0)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}


static int HarrisonHitDetected[MAXENTITIES];

static void HarrisonInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
{
	float vecForward[3], vecRight[3], Angles[3];

	MakeVectorFromPoints(VectorStart, VectorTarget, vecForward);
	GetVectorAngles(vecForward, Angles);
	GetAngleVectors(vecForward, vecForward, vecRight, VectorTarget);

	Handle trace = TR_TraceRayFilterEx(VectorStart, Angles, 11, RayType_Infinite, Harrison_TraceWallsOnly);
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(VectorTarget, trace);
		
		float lineReduce = 10.0 * 2.0 / 3.0;
		float curDist = GetVectorDistance(VectorStart, VectorTarget, false);
		if (curDist > lineReduce)
		{
			ConformLineDistance(VectorTarget, VectorStart, VectorTarget, curDist - lineReduce);
		}
	}
	delete trace;

	int red = 200;
	int green = 200;
	int blue = 200;
	int colorLayer4[4];
	float diameter = float(12 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 150);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.4, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.2, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	int glowColor[4];
	SetColorRGBA(glowColor, red, green, blue, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Glow, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.5, glowColor, 0);
	TE_SendToAll(0.0);

	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget[0]);
	pack.WriteFloat(VectorTarget[1]);
	pack.WriteFloat(VectorTarget[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	RequestFrames(HarrisonInitiateLaserAttack_DamagePart, 50, pack);
}

static void HarrisonInitiateLaserAttack_DamagePart(DataPack pack)
{
	for (int i = 1; i < MAXENTITIES; i++)
	{
		HarrisonHitDetected[i] = false;
	}
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();

	int red = 155;
	int green = 155;
	int blue = 255;
	int colorLayer4[4];
	float diameter = float(13 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 255);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 100);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(10);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Harrison_BEAM_TraceUsers, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	float CloseDamage = 50.0;
	float FarDamage = 20.0;
	float MaxDistance = 750.0;
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (HarrisonHitDetected[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float distance = GetVectorDistance(VectorStart, playerPos, false);
			float damage = CloseDamage + (FarDamage-CloseDamage) * (distance/MaxDistance);
			if (damage < 0)
				damage *= -1.0;


			SDKHooks_TakeDamage(victim, entity, entity, damage * RaidModeScaling, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


static bool Harrison_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if(IsEntityAlive(entity))
		HarrisonHitDetected[entity] = true;
	return false;
}

static bool Harrison_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

static Action Timer_Quad_Rocket_Shot(Handle timer, DataPack pack)
{
	pack.Reset();
	Harrison npc = view_as<Harrison>(EntRefToEntIndex(pack.ReadCell()));
	int enemy = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(enemy))
	{
		float vecTarget[3]; WorldSpaceCenter(enemy, vecTarget);
		ParticleEffectAt(vecTarget, "npc_boss_bomb_shadow", 3.0);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);
		vecSelf[2] += 80.0;
		vecSelf[0] += GetRandomFloat(-20.0, 20.0);
		vecSelf[1] += GetRandomFloat(-20.0, 20.0);
		float RocketDamage = 40.0;
		int RocketGet = npc.FireRocket(vecSelf, RocketDamage * RaidModeScaling, 300.0 ,"models/buildables/sentry3_rockets.mdl");
		if(IsValidEntity(RocketGet))
		{
			DataPack pack2;
			CreateDataTimer(0.5, WhiteflowerTank_Rocket_Stand, pack2, TIMER_FLAG_NO_MAPCHANGE);
			pack2.WriteCell(EntIndexToEntRef(RocketGet));
			pack2.WriteCell(EntIndexToEntRef(enemy));
		}
		npc.FaceTowards(vecTarget, 99999.0);
	}
	return Plugin_Stop;
}

void ResetSoldineWeapon(Soldine npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/zombie_riot/weapons/custom_weaponry_1_36.mdl");
			SetVariantString("0.75");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			SetVariantInt(32);
			AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");
		}
		case 0:
		{	
			npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}