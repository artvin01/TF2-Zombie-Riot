#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3"
};
static const char g_MissAbilitySound[][] = {
	"vo/scout_invinciblechgunderfire01.mp3",
	"vo/scout_invinciblechgunderfire02.mp3",
	"vo/scout_invinciblechgunderfire03.mp3",
	"vo/scout_invinciblechgunderfire04.mp3",
	"vo/scout_beingshotinvincible01.mp3",
	"vo/scout_beingshotinvincible02.mp3",
	"vo/scout_beingshotinvincible03.mp3",
	"vo/scout_beingshotinvincible04.mp3",
	"vo/scout_beingshotinvincible05.mp3",
	"vo/scout_beingshotinvincible06.mp3",
	"vo/scout_beingshotinvincible07.mp3",
	"vo/scout_beingshotinvincible08.mp3",
	"vo/scout_beingshotinvincible09.mp3",
	"vo/scout_beingshotinvincible10.mp3",
	"vo/scout_beingshotinvincible11.mp3",
	"vo/scout_beingshotinvincible12.mp3",
	"vo/scout_beingshotinvincible13.mp3",
	"vo/scout_beingshotinvincible14.mp3",
	"vo/scout_beingshotinvincible15.mp3",
	"vo/scout_beingshotinvincible16.mp3",
	"vo/scout_beingshotinvincible17.mp3",
	"vo/scout_beingshotinvincible18.mp3",
	"vo/scout_beingshotinvincible19.mp3",
	"vo/scout_beingshotinvincible20.mp3",
	"vo/scout_beingshotinvincible21.mp3",
	"vo/scout_beingshotinvincible22.mp3",
	"vo/scout_beingshotinvincible23.mp3",
	"vo/scout_beingshotinvincible24.mp3",
	"vo/scout_beingshotinvincible25.mp3",
	"vo/scout_beingshotinvincible26.mp3",
	"vo/scout_beingshotinvincible27.mp3",
	"vo/scout_beingshotinvincible28.mp3",
	"vo/scout_beingshotinvincible29.mp3",
	"vo/scout_beingshotinvincible30.mp3",
	"vo/scout_beingshotinvincible31.mp3",
	"vo/scout_beingshotinvincible32.mp3",
	"vo/scout_beingshotinvincible33.mp3",
	"vo/scout_beingshotinvincible34.mp3",
	"vo/scout_beingshotinvincible35.mp3",
	"vo/scout_beingshotinvincible36.mp3"
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/scout_taunts03.mp3",
	"vo/taunts/scout_taunts04.mp3",
	"vo/taunts/scout_taunts06.mp3",
	"vo/taunts/scout_taunts15.mp3",
	"vo/compmode/cm_scout_pregamefirst_01.mp3"
};
static const char g_RangedAttackSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/3rd_degree_hit_02.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/bat_draw.wav",
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav"
};
static const char g_MeleeHitSounds[] = "weapons/bat_hit.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/scout_revenge06.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_HomerunSounds[][]= {
	"vo/scout_stunballhit01.mp3",
	"vo/scout_stunballhit02.mp3",
	"vo/scout_stunballhit03.mp3",
	"vo/scout_stunballhit04.mp3",
	"vo/scout_stunballhit05.mp3",
	"vo/scout_stunballhit06.mp3",
	"vo/scout_stunballhit07.mp3",
	"vo/scout_stunballhit08.mp3"
};
static const char g_HomerunfailSounds[][]= {
	"vo/taunts/scout/scout_taunt_rps_lose_01.mp3",
	"vo/taunts/scout/scout_taunt_rps_lose_03.mp3"
};
static const char StunballPickupeSound[][] = {
	"vo/scout_stunballpickup01.mp3",
	"vo/scout_stunballpickup02.mp3",
	"vo/scout_stunballpickup03.mp3",
	"vo/scout_stunballpickup04.mp3",
	"vo/scout_stunballpickup05.mp3"
};

static float FTL[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];
static bool DrinkPOWERUP[MAXENTITIES];
static float NiceMiss[MAXENTITIES];
static bool OnMiss[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static float fl_said_player_weaponline_time[MAXENTITIES];
static bool SUPERHIT[MAXENTITIES];

void Atomizer_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Atomizer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_atomizer");
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
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	for (int i = 0; i < (sizeof(g_HomerunSounds));   i++) { PrecacheSound(g_HomerunSounds[i]);   }
	for (int i = 0; i < (sizeof(StunballPickupeSound));   i++) { PrecacheSound(StunballPickupeSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }
	for (int i = 0; i < (sizeof(g_HomerunfailSounds));   i++) { PrecacheSound(g_HomerunfailSounds[i]);   }
	PrecacheModel("models/player/scout.mdl");
	PrecacheSoundCustom("#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Atomizer(client, vecPos, vecAng, ally, data);
}

static int i_atomizer_eye_particle[MAXENTITIES];

methodmap Atomizer < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
    property float m_flHarrisonRocketShotHappening
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void NiceCatchKnucklehead() {
	
		int sound = GetRandomInt(0, sizeof(StunballPickupeSound) - 1);
		EmitSoundToAll(StunballPickupeSound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	
		EmitSoundToAll(g_HomerunfailSounds[GetRandomInt(0, sizeof(g_HomerunfailSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunfailSounds[GetRandomInt(0, sizeof(g_HomerunfailSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMissSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		int sound = GetRandomInt(0, sizeof(g_MissAbilitySound) - 1);
		EmitSoundToAll(g_MissAbilitySound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,110));
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		//EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public Atomizer(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Atomizer npc = view_as<Atomizer>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
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
		DrinkPOWERUP[npc.index] = false;
		YaWeFxxked[npc.index] = false;
		ParticleSpawned[npc.index] = false;
		SUPERHIT[npc.index] = false;
		NiceMiss[npc.index] = 0.0;
        npc.m_flHarrisonRocketShotHappening = 0.0;
		I_cant_do_this_all_day[npc.index] = 0;
		npc.i_GunMode = 0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 15.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 5.0;
		npc.m_flNextRangedAttack = GetGameTime() + 30.0;
		npc.m_flAngerDelay = GetGameTime() + 15.0;
		npc.m_iOverlordComboAttack = 0;
		OnMiss[npc.index] = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_bFUCKYOU = false;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
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
				ShowGameText(client_check, "item_armor", 1, "%t", "Sensal Arrived");
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
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/expidonsa_waves/raid_sensal_2.mp3");
		music.Time = 218;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Goukisan - Betrayal of Fear (TeslaX VIP remix)");
		strcopy(music.Artist, sizeof(music.Artist), "Talurre/TeslaX11");
		Music_SetRaidMusic(music);
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

	//	Weapon
	//	npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
	//	SetVariantString("1.0");
	//	AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

	//	Weapon
		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		CPrintToChatAll("{blue}%s{default}: Intruders in sight, I won't let the get out alive!", c_NpcName[npc.index]);

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/scout/pn2_longfall.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_jungle_jersey/fall17_jungle_jersey.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/sum19_bottle_cap/sum19_bottle_cap.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector/hwn2019_fuel_injector.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({100, 150, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	Atomizer npc = view_as<Atomizer>(iNPC);
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_atomizer_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}	

	if(NiceMiss[npc.index] < gameTime)
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
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
					CPrintToChatAll("{blue}Atomizer{default}: Ready to die?");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Atomizer{default}: You can't run forever.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Atomizer{default}: All of your comrades are fallen.");
				}
			}
		}
	}
	npc.m_flSpeed = 300.0+(((FTL[npc.index]-(RaidModeTime - GetGameTime()))/FTL[npc.index])*150.0);
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		npc.m_flMeleeArmor = 0.33;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:
			{
				CPrintToChatAll("{blue}%s{default}: Victoria will be in peace. Once and for all.", c_NpcName[npc.index]);
			}
			case 2:
			{
				CPrintToChatAll("{blue}%s{default}: The troops have arrived and will begin destroying the intruders!", c_NpcName[npc.index]);
			}
			case 3:
			{
				CPrintToChatAll("{blue}%s{default}: Backup team has arrived. Catch those damn bastards!", c_NpcName[npc.index]);
			}
			case 4:
			{
				CPrintToChatAll("{blue}%s{default}: After this, Im heading to Rusted Bolt Pub. {crimson}I need beer.{default}", c_NpcName[npc.index]);
			}
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

	/*if(OnMiss[npc.index])
	{
		if(IsValidEntity(npc.m_iWearable8))
				RemoveEntity(npc.m_iWearable8);
		if(!IsValidEntity(npc.m_iWearable8))
		{
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			npc.m_iWearable8 = ParticleEffectAt(flPos, "utaunt_tarotcard_blue_glow", 80.0);
			SetParent(npc.index, npc.m_iWearable8, "head");
		}
	}
	else if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);*/

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = AtomizerSelfDefense(npc,gameTime, npc.m_iTarget, flDistanceToTarget); 

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
		AtomizerAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Atomizer npc = view_as<Atomizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);
	if(NiceMiss[npc.index] > gameTime && GetRandomInt(1,100)<=40)
	{
		damage = 0.0;
		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		if(b_BoundingBoxVariant[victim] == 1)
		{
			chargerPos[2] += 120.0;
		}
		else
		{
			chargerPos[2] += 82.0;
		}
		/*int particle_power = ParticleEffectAt(chargerPos, "miss_text", 1.5);
		SetParent(victim, particle_power);*/
		TE_ParticleInt(g_particleMissText, chargerPos);
		TE_SendToClient(attacker);
		OnMiss[npc.index]=true;
		ExtinguishTarget(npc.m_iWearable2);
		IgniteTargetEffect(npc.m_iWearable2);
		npc.PlayMissSound();
		return Plugin_Handled;
	}

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
			npc.m_bFUCKYOU=true;
			IncreaceEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			FTL[npc.index] += 5.0;
			RaidModeTime += 5.0;
			npc.m_flNextRangedAttack += 5.0;
		}
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Atomizer npc = view_as<Atomizer>(entity);
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

	int particle = EntRefToEntIndex(i_atomizer_eye_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_atomizer_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
	
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
	}

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,2))
	{
		case 0:
		{
			CPrintToChatAll("{blue}Atomizer{default}: Ugh, I need backup");
		}
		case 1:
		{
			CPrintToChatAll("{blue}Atomizer{default}: I will never let you trample over the glory of {gold}Victoria{default} Again!");
		}
		case 2:
		{
			CPrintToChatAll("{blue}Atomizer{default}: You intruders will soon face the {crimson}Real Deal.{default}");
		}
	}

}

void AtomizerAnimationChange(Atomizer npc)
{
	
	if(npc.m_iChanged_WalkCycle == 0)
	{
		npc.m_iChanged_WalkCycle = -1;
	}
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetAtomizerWeapon(npc, 1);
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
				//	ResetAtomizerWeapon(npc, 1);
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
				//	ResetAtomizerWeapon(npc, 0);
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
				//	ResetAtomizerWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

int AtomizerSelfDefense(Atomizer npc, float gameTime, int target, float distance)
{
	npc.i_GunMode = 0;

	if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
	{
		if(IsValidEnemy(npc.index, target))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
		}
		if(npc.m_flRangedSpecialDelay < gameTime)
		{
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				npc.PlayRocketSound();
				float vecSelf[3];
				WorldSpaceCenter(npc.index, vecSelf);
				vecSelf[2] += 50.0;
				vecSelf[0] += GetRandomFloat(-10.0, 10.0);
				vecSelf[1] += GetRandomFloat(-10.0, 10.0);
				float RocketDamage = 300.0;
				int RocketGet = npc.FireRocket(vecSelf, RocketDamage, 300.0);
				DataPack pack;
				CreateDataTimer(0.5, WhiteflowerTank_Rocket_Stand, pack, TIMER_FLAG_NO_MAPCHANGE);
				pack.WriteCell(EntIndexToEntRef(RocketGet));
				pack.WriteCell(EntIndexToEntRef(npc.m_iTarget));
			}
			npc.m_flDoingAnimation = 0.0;
		}
		if(npc.m_flDoingAnimation < gameTime)
		{
			npc.m_flDoingAnimation = gameTime + 0.2;
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE",_,_,_,2.0);
			npc.m_flRangedSpecialDelay = gameTime + 0.20;
		}
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flDoingAnimation = gameTime + 0.25;
			npc.m_flNextRangedSpecialAttack = 0.0;
		}
		return;
	}
	else if(npc.m_flRangedSpecialDelay < gameTime)
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
				
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}
			npc.m_flDoingAnimation = gameTime + 99.9;
			npc.m_flHarrisonRocketShotHappening = gameTime + 1.0;
			npc.m_flRangedSpecialDelay = gameTime + 30.0;
			npc.m_flAttackHappens = 0.0;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_fist_bump_fistbump");
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 110);
			npc.SetCycle(0.05);
			float flPos[3];
			float flAng[3];
			npc.GetAttachment("effect_hand_r", flPos, flAng);
			npc.m_iChanged_WalkCycle = 0;
			npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "unusual_breaker_green_parent", npc.index, "effect_hand_r", {0.0,0.0,0.0});
		}
	}
	if(npc.m_flNextRangedAttack < gameTime)
	{
		int GetClosestEnemyToAttack;
		//Get the closest visible target via distance checks, not via pathing check.
		GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);
		float vecTarget[3]; WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);

		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
		{	
			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0))
				{	

					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
					npc.PlayMeleeSound();
					//after we fire, we will have a short delay beteween the actual laser, and when it happens
					//This will predict as its relatively easy to dodge
					float projectile_speed = 1200.0;
					//lets pretend we have a projectile.
					PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0, vecTarget);
					if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
					{
						WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget );
					}

					float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
					HarrisonInitiateLaserAttack(npc.index, vecTarget, WorldSpaceVec);
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 2.5;
				}
			}
		}
		else
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_bisWalking = true;
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_MP_RUN_PRIMARY");
				npc.m_flSpeed = 330.0;
				npc.StartPathing();
			}
		}
	}
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			if(npc.m_iOverlordComboAttack > 0)
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
					{
						npc.m_flAttackHappens = 0.0;
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						if(IsValidEnemy(npc.index, Enemy_I_See))
						{
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							float RocketDamage = 20.0;
							if(OnMiss[npc.index])
							{
								RocketDamage*=1.5;
								OnMiss[npc.index]=false;
								ExtinguishTarget(npc.m_iWearable2);
							}
							if(DrinkPOWERUP[npc.index])
								RocketDamage*=1.25;
							float RocketSpeed = 1650.0;
							float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
							float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
							float vecDest[3];
							vecDest = vecTarget;
							vecDest[0] += GetRandomFloat(-30.0, 30.0);
							vecDest[1] += GetRandomFloat(-30.0, 30.0);
							float SpeedReturn[3];
							for(int i=1; i<=(npc.m_iOverlordComboAttack > 3 ? 3 : 1); i++)
							{
								if(npc.m_iOverlordComboAttack > 0)
								{
									int RocketGet = npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling, RocketSpeed, 400.0, "critical_rocket_blue", false);
									if(RocketGet != -1)
									{
										//max duration of 2 seconds
										CreateTimer(2.0, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
									}
									SetEntityGravity(RocketGet, 1.0); 	
									ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.0, 1.0);
									SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
									TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
									SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
									SDKHook(RocketGet, SDKHook_StartTouch, Atomizer_Rocket_Particle_StartTouch);
									npc.m_iOverlordComboAttack-=1;
								}
								else break;
							}
						}
					}
				}
				//No can shooty.
				//Enemy is close enough.
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					{
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						//stand
						return 1;
					}
					//cant see enemy somewhy.
					return 0;
				}
				else //enemy is too far away.
				{
					return 0;
				}
			}
			else
			{
				npc.m_flAttackHappens = 0.0;
			
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

								float damage = 20.0;
								damage *= 1.15;
								if(OnMiss[npc.index])
								{
									damage*=1.5;
									OnMiss[npc.index]=false;
									ExtinguishTarget(npc.m_iWearable2);
								}
								if(DrinkPOWERUP[npc.index])
									damage*=1.25;

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 300.0, true);
										if(!NpcStats_IsEnemySilenced(npc.index))
										{
											TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
											TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
										}
									}
									else
									{
										if(!NpcStats_IsEnemySilenced(npc.index))
										{
											TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
											TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
										}
									}
								}
											
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 150.0, true); 
							} 
						}
					}
					if(PlaySound)
					{
						npc.PlayMeleeHitSound();
					}
				}
			}
		}
	}
	//Melee attack, last prio
	else if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0) && npc.m_iOverlordComboAttack > 0)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					
					float time = 0.125;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						time *= 0.5;
					}
					npc.m_flAttackHappens = gameTime + time;
					npc.m_flNextMeleeAttack = gameTime + time;
					npc.m_flDoingAnimation = gameTime + time;
				}
			}
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.5;
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
	return 0;
}

static void SuperAttack(int entity, int victim, float damage, int weapon)
{
	Atomizer npc = view_as<Atomizer>(entity);
	if(IsValidEntity(victim))
	{
		float vecHit[3]; WorldSpaceCenter(victim, vecHit);
		Custom_Knockback(npc.index, victim, DrinkPOWERUP[npc.index] ? 2200.0 : 1980.0, true, true, true);
		SUPERHIT[npc.index]=true;
	}
}

static Action Atomizer_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		if (!IsInvuln(target))
		{
			TF2_StunPlayer(target, 1.0, 0.4, TF_STUNFLAG_SLOWDOWN);
		}

		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}

bool NemalSnipingShots(Nemal npc)
{
	if(npc.m_flHarrisonRocketShotHappening)
	{
		
		//at max 15 targets, anything above that is unneccecary.
		//we dont support more then 1 nemal at a time.
		//This is due to just the array being way too big.
		static float SnipeTargets[MAXENTITIES][3];  
		if(npc.m_flAttackHappens)
		{
			//Enemies currently in vision
			float pos_npc[3];
			float angles_useless[3];
			float PosEnemy[3];
			WorldSpaceCenter(npc.index, pos_npc);
			npc.GetAttachment("effect_hand_r", pos_npc, angles_useless);
			if(npc.m_flAttackHappens - 0.35 > GetGameTime(npc.index))
			{
				UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
				int enemy_2[MAXENTITIES];
				GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false, npc.m_iWearable8);
				for(int i; i < sizeof(enemy_2); i++)
				{
					if(enemy_2[i] && NemalAntiLaserDo[enemy_2[i]] < GetGameTime())
					{
						int ememyTarget = enemy_2[i];
						WorldSpaceCenter(ememyTarget, PosEnemy);
						float flDistanceToTarget = GetVectorDistance(pos_npc, PosEnemy);
						float SpeedToPredict = flDistanceToTarget * 2.1;
						PredictSubjectPositionForProjectiles(npc, ememyTarget, SpeedToPredict, _,SnipeTargets[ememyTarget]);
					}
				}
			}
			bool DoLaserShow = false;
			if(npc.m_flNemalSniperShotsLaserThrottle < GetGameTime())
			{
				DoLaserShow = true;
				npc.m_flNemalSniperShotsLaserThrottle = GetGameTime() + 0.1;
			}
			for(int Loop = 1; Loop < MAXENTITIES; Loop ++)
			{
				if(SnipeTargets[Loop][1] != 0.0)
				{
					float AngleAim[3];
					GetVectorAnglesTwoPoints(pos_npc, SnipeTargets[Loop], AngleAim);
					Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
					if(TR_DidHit(hTrace))
					{
						TR_GetEndPosition(SnipeTargets[Loop], hTrace);
					}
					delete hTrace;
					if(DoLaserShow)
					{
						TE_SetupBeamPoints(pos_npc, SnipeTargets[Loop], Shared_BEAM_Laser, 0, 0, 0, 0.1, 5.0, 5.0, 0, 0.0, {125,125,255,255}, 3);
						TE_SendToAll(0.0);
					}
				}
			}
			if(npc.m_flAttackHappens < GetGameTime(npc.index))
			{	
				bool PlaySound;
				for(int Loop = 1; Loop < MAXENTITIES; Loop ++)
				{
					if(SnipeTargets[Loop][1] != 0.0)
					{
						TE_SetupBeamPoints(pos_npc, SnipeTargets[Loop], Shared_BEAM_Laser, 0, 0, 0, 0.25, 5.0, 5.0, 5, 0.0, {255,255,255,255}, 3);
						TE_SendToAll(0.0);
						float AngleAim[3];
						GetVectorAnglesTwoPoints(pos_npc, SnipeTargets[Loop], AngleAim);
						Handle hTrace = TR_TraceRayFilterEx(pos_npc, AngleAim, MASK_SOLID, RayType_Infinite, BulletAndMeleeTrace, npc.index);
						int Traced_Target = TR_GetEntityIndex(hTrace);
						if(Traced_Target > 0)
						{
							WorldSpaceCenter(Traced_Target, SnipeTargets[Loop]);
						}
						else if(TR_DidHit(hTrace))
						{
							TR_GetEndPosition(SnipeTargets[Loop], hTrace);
						}
						delete hTrace;
						int target = Can_I_See_Enemy(npc.index, Loop,_ ,SnipeTargets[Loop]);
						if(IsValidEnemy(npc.index, target))
						{
							float damageDealt = 40.0 * RaidModeScaling;
							if(Loop > MaxClients)
								damageDealt *= 0.5;

							SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, SnipeTargets[Loop]);
						} 
						PlaySound = true;
						DataPack pack_boom = new DataPack();
						pack_boom.WriteFloat(SnipeTargets[Loop][0]);
						pack_boom.WriteFloat(SnipeTargets[Loop][1]);
						pack_boom.WriteFloat(SnipeTargets[Loop][2]);
						pack_boom.WriteCell(0);
						RequestFrame(MakeExplosionFrameLater, pack_boom);
						EmitAmbientSound("ambient/explosions/explode_3.wav", SnipeTargets[Loop], _, 90, _,0.7, GetRandomInt(75, 110));
					}
				}
				if(PlaySound)
				{
					npc.PlayShootSoundNemalSnipe();
				}
				npc.m_flAttackHappens = GetGameTime(npc.index) + 1.0;
				Zero2(SnipeTargets);//rest all!
			}
		}
		if(npc.m_flHarrisonRocketShotHappening < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 100)
			{
				//we change animations
				npc.m_flHarrisonRocketShotHappening = GetGameTime(npc.index) + 3.1;
				if(i_RaidGrantExtra[npc.index] >= 4)
					npc.m_flHarrisonRocketShotHappening = GetGameTime(npc.index) + 4.1;

				npc.m_flAttackHappens = GetGameTime(npc.index) + 1.0;
				npc.m_iChanged_WalkCycle = 100;
				npc.AddActivityViaSequence("taunt_headbutt_start");
				npc.SetCycle(0.5);
				npc.SetPlaybackRate(0.05);	
				Zero2(SnipeTargets);//rest all!
				return true;
			}
			npc.i_GunMode = 0;
			npc.m_flAttackHappens = 0.0;
			npc.m_flHarrisonRocketShotHappening = 0.0;	
			npc.m_iChanged_WalkCycle = 0;
			npc.m_flDoingAnimation = 0.0;
			if(IsValidEntity(npc.m_iWearable8))
			{
				RemoveEntity(npc.m_iWearable8);
			}
		}
		return true;
	}
	return false;
}


int HarrisonHitDetected[MAXENTITIES];

void HarrisonInitiateLaserAttack(int entity, float VectorTarget[3], float VectorStart[3])
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
	int blue = 255;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
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

void HarrisonInitiateLaserAttack_DamagePart(DataPack pack)
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

	int red = 100;
	int green = 25;
	int blue = 255;
	int colorLayer4[4];
	float diameter = float(10 * 4);
	SetColorRGBA(colorLayer4, red, green, blue, 100);
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
			
	float CloseDamage = 75.0;
	float FarDamage = 50.0;
	float MaxDistance = 125.0;
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

			
			if(ShouldNpcDealBonusDamage(victim))
				damage *= 3.0;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_PLASMA, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
				
		}
	}
	delete pack;
}


public bool Harrison_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		HarrisonHitDetected[entity] = true;
	}
	return false;
}

public bool Harrison_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}