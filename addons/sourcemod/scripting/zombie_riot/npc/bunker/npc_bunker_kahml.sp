#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/kahml/dead.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/boxing_gloves_hit1.wav",
	"weapons/boxing_gloves_hit2.wav",
	"weapons/boxing_gloves_hit3.wav",
	"weapons/boxing_gloves_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/boxing_gloves_swing1.wav",
	"weapons/boxing_gloves_swing2.wav",
	"weapons/boxing_gloves_swing4.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};

static const char g_MeleeCritAttacks[][] = {
	"freak_fortress_2/kahml/crit1.mp3",
	"freak_fortress_2/kahml/crit2.mp3",
	"freak_fortress_2/kahml/crit3.mp3",
};

static const char g_MeleeComboHits[][] = {
	"freak_fortress_2/kahml/slam.mp3",
	"freak_fortress_2/kahml/strong.mp3",
	"freak_fortress_2/kahml/upper.mp3",
};

static const char g_MeleeNeckSnapPrepare[][] = {
	"freak_fortress_2/kahml/snap_prepare.mp3",
};

static const char g_MeleeNeckSnapped[][] = {
	"freak_fortress_2/kahml/snapped.mp3",
};

static const char g_MeleeNanoMachines[][] = {
	"freak_fortress_2/kahml/nanomachines_son.mp3",
};

static const char g_DoubleBarrel[][] = {
	"freak_fortress_2/kahml_new/db.mp3",
};

static const char g_PrimaryBrassBeastSound[][] = {
	"mvm/giant_soldier/giant_soldier_rocket_shoot.wav",
};

static const char g_PrimaryFamilyBusinessSound[][] = {
	"weapons/family_business_shoot.wav",
};

static const char g_PrimaryFamilyBusinessReload[][] = {
	"weapons/shotgun_reload.wav",
};

static const char g_BunkerKahmlTheme[][] = {
	"#freak_fortress_2/kahml/theme1_1.mp3",
};

static const char g_HeavyTerror[][] = {
	"#freak_fortress_2/kahml/heavy_terror_rage.mp3",
};

void BunkerKahml_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeCritAttacks));   i++) { PrecacheSound(g_MeleeCritAttacks[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeComboHits));   i++) { PrecacheSound(g_MeleeComboHits[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeNeckSnapPrepare));   i++) { PrecacheSound(g_MeleeNeckSnapPrepare[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeNeckSnapped));   i++) { PrecacheSound(g_MeleeNeckSnapped[i]);   }
	for (int i = 0; i < (sizeof(g_MeleeNanoMachines));   i++) { PrecacheSound(g_MeleeNanoMachines[i]);   }
	for (int i = 0; i < (sizeof(g_DoubleBarrel));   i++) { PrecacheSound(g_DoubleBarrel[i]);   }
	for (int i = 0; i < (sizeof(g_PrimaryBrassBeastSound));   i++) { PrecacheSound(g_PrimaryBrassBeastSound[i]);   }
	for (int i = 0; i < (sizeof(g_PrimaryFamilyBusinessSound));   i++) { PrecacheSound(g_PrimaryFamilyBusinessSound[i]);   }
	for (int i = 0; i < (sizeof(g_PrimaryFamilyBusinessReload));   i++) { PrecacheSound(g_PrimaryFamilyBusinessReload[i]);   }
	for (int i = 0; i < (sizeof(g_BunkerKahmlTheme));   i++) { PrecacheSound(g_BunkerKahmlTheme[i]);   }
	for (int i = 0; i < (sizeof(g_HeavyTerror));   i++) { PrecacheSound(g_HeavyTerror[i]);   }
}

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_CustomKahmlTheme[MAXENTITIES];

static float fl_AbilityManagement_Timer[MAXENTITIES];
static float fl_AbilityFirstUsageTimer = 15.0;
static float fl_AbilitySecondUsageTimer = 18.0;
static bool b_AbilityManagement[MAXENTITIES];

static float fl_AbilityDoubleBarrel_Timer[MAXENTITIES];
static float fl_AbilityDoubleBarrel_EndTimer = 6.0;
static bool b_AbilityDoubleBarrel[MAXENTITIES];
static int i_AbilityDoubleBarrel_HitAmount[MAXENTITIES];

static float fl_AbilityNeckSnap_Timer[MAXENTITIES];
static float fl_AbilityNeckSnap_EndTimer = 5.0;
static bool b_AbilityNeckSnap[MAXENTITIES];
static int i_AbilityNeckSnap_HitAmount[MAXENTITIES];

static bool b_EnableGun[MAXENTITIES];

static bool b_AnhilationReady[MAXENTITIES];
static float fl_Anhilation_Timer[MAXENTITIES];

static float fl_AbilityNanoMachines_Timer[MAXENTITIES];
static float fl_AbilityNanoMachinesHealing_Timer[MAXENTITIES];
static bool b_AbilityNanoMachines[MAXENTITIES];
static float fl_AbilityNanoMachines_EndTimer = 25.0;

static float fl_MainMeleeDamage = 450.0;
static float fl_MainMeleeDamageNpcBuilding = 25000.0;
//static float fl_ComboHitsRandomDmgMultiplier = GetRandomFloat(1.05, 2.25);
//static float fl_ComboHitsDamage = fl_MainMeleeDamage * fl_ComboHitsRandomDmgMultiplier;
static float fl_DoubleBarrel_Damage = 1250.0;
//static float fl_AbilityNeckSnap_DmgMultiplier = 35.0;
static float fl_AbilityNeckSnap_DmgMultiplier = 135.0;
static float fl_DefaultSpeed = 420.0;
static float fl_NanoSpeed = 550.0;
static float fl_NanoDamageRes = 0.25;

static int i_HitAmounts[MAXENTITIES];
static int i_MaxHitAmount = 8;//please do not mess with it i do not want to bother redoing both of maxuntilcrits and maxhit amount
static int i_CritAttacks[MAXENTITIES];
static int i_MaxHitsUntilCrit = 7;
static float fl_CritMultiplier = 3.0;
static bool b_KahmlDamageDebug = false;//ONLY ACTIVATE IT IF YOU WANT TO SEE HIS DAMAGE FROM HIS COMBO AND NANO AND SNAP

static bool b_TeleporterReady[MAXENTITIES];
static bool b_Teleportering[MAXENTITIES];

static bool b_EmergencyRes = false;//If we can kill him too fast give him emergency res needs to be manually enabled and recompiled
static float fl_EmergencyRes = 0.8;//How much res he gains on Emergency

methodmap BunkerKahml < CClotBody
{
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayCritSound() {
		EmitSoundToAll(g_MeleeCritAttacks[GetRandomInt(0, sizeof(g_MeleeCritAttacks) - 1)], _, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		//EmitSoundToAll(g_MeleeCritAttacks[GetRandomInt(0, sizeof(g_MeleeCritAttacks) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeCritSound()");
		#endif
	}
	public void PlayMeleeComboSound() {
		EmitSoundToAll(g_MeleeComboHits[GetRandomInt(0, sizeof(g_MeleeComboHits) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeComboSound()");
		#endif
	}
	public void PlaySnapPrepare() {
		EmitSoundToAll(g_MeleeNeckSnapPrepare[GetRandomInt(0, sizeof(g_MeleeNeckSnapPrepare) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySnapPrepareSound()");
		#endif
	}
	public void PlaySnappedSound() {
		EmitSoundToAll(g_MeleeNeckSnapped[GetRandomInt(0, sizeof(g_MeleeNeckSnapped) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySnappedSound()");
		#endif
	}
	public void PlayNanoSound() {
		EmitSoundToAll(g_MeleeNanoMachines[GetRandomInt(0, sizeof(g_MeleeNanoMachines) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlaySnappedSound()");
		#endif
	}
	public void PlayDoubleBarrel() {
		EmitSoundToAll(g_DoubleBarrel[GetRandomInt(0, sizeof(g_DoubleBarrel) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayDBSound()");
		#endif
	}
	public void PlayGattlingSound() {
		EmitSoundToAll(g_PrimaryBrassBeastSound[GetRandomInt(0, sizeof(g_PrimaryBrassBeastSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayDBSound()");
		#endif
	}
	public void PlayFamilyBusinessSound() {
		EmitSoundToAll(g_PrimaryFamilyBusinessSound[GetRandomInt(0, sizeof(g_PrimaryFamilyBusinessSound) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayDBSound()");
		#endif
	}
	public void PlayFamilyBusinessReload() {
		EmitSoundToAll(g_PrimaryFamilyBusinessReload[GetRandomInt(0, sizeof(g_PrimaryFamilyBusinessReload) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayDBSound()");
		#endif
	}
	public void PlayKahmlMainTheme() {
	
		EmitSoundToAll(g_BunkerKahmlTheme[GetRandomInt(0, sizeof(g_BunkerKahmlTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayKahmlMainTheme()");
		#endif
	}
	public void PlayHeavyTerror() {
	
		EmitSoundToAll(g_HeavyTerror[GetRandomInt(0, sizeof(g_HeavyTerror) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayKahmlMainTheme()");
		#endif
	}
	
	public BunkerKahml(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerKahml npc = view_as<BunkerKahml>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "55000000", ally, false, true));
		
		float gameTime = GetGameTime(npc.index);
		
		i_NpcInternalId[npc.index] = BUNKER_KAHML_VTWO;
		
		if(!b_IsAlliedNpc[npc.index])//check if he isn't an ally so he can gain the raid properties
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			Music_Stop_Beat_Ten9(client);
			Music_Stop_KahmlTheme(client);
			fl_CustomKahmlTheme[npc.index] = gameTime + 1.0; //Mainly if you want to bother adding an intro if not just comment it out
			for(int client_clear=1; client_clear<=MaxClients; client_clear++)
			{
				fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
			}
			RaidModeTime = GetGameTime(npc.index) + 325.0;
			GiveNpcOutLineLastOrBoss(npc.index, true);
		}
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerKahml_ClotThink);
		
		fl_AbilityManagement_Timer[npc.index] = gameTime + fl_AbilityFirstUsageTimer;
		fl_Anhilation_Timer[npc.index] = gameTime + 200.0;
		b_AbilityManagement[npc.index] = false;
		b_AbilityDoubleBarrel[npc.index] = false;
		b_AbilityNeckSnap[npc.index] = false;
		b_AbilityNanoMachines[npc.index] = false;
		b_AnhilationReady[npc.index] = false;
		i_AbilityDoubleBarrel_HitAmount[npc.index] = 0;
		i_AbilityNeckSnap_HitAmount[npc.index] = 0;
		i_HitAmounts[npc.index] = 0;
		i_CritAttacks[npc.index] = 0;
		npc.m_flNextTeleport = gameTime + 7.0;
		b_TeleporterReady[npc.index] = false;
		b_Teleportering[npc.index] = false;
		if(b_EmergencyRes)
		{
			npc.m_flMeleeArmor = fl_EmergencyRes;
			npc.m_flRangedArmor = fl_EmergencyRes;
		}
		else
		{
			npc.m_flMeleeArmor = 1.0;
			npc.m_flRangedArmor = 1.0;
		}
		
		//IDLE
		npc.m_flSpeed = fl_DefaultSpeed;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = 0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fists_of_steel/c_fists_of_steel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_russian_riot/c_russian_riot.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_helm.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/heavy/heavy_wolf_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/weapons/c_models/c_gatling_gun/c_gatling_gun.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		
		if(!b_IsAlliedNpc[npc.index])
		{
			skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
			SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		}
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		
		return npc;
	}
}

public void BunkerKahml_ClotThink(int iNPC)
{
	BunkerKahml npc = view_as<BunkerKahml>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	float fl_ComboHitsRandomDmgMultiplier = GetRandomFloat(1.35, 1.75);
	float fl_ComboHitsDamage = fl_MainMeleeDamage * fl_ComboHitsRandomDmgMultiplier;
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(!b_IsAlliedNpc[npc.index])//really hate myself repeating the same thing
	{
		if(RaidModeTime < GetGameTime())
		{
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			//Music_Stop_KahmlTheme(iNPC);//can be enabled reason i didn't bothered is it plays the last sec of the music anyway
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, BunkerKahml_ClotThink);
		}
		if(fl_CustomKahmlTheme[npc.index] <= gameTime)
		{
			fl_CustomKahmlTheme[npc.index] = gameTime + 344.0;//technically he doesn't need it but i did it anyway
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Helblinde {default}- {orange}The Solace of Oblivion");//idk though it's fancy showing it
			npc.PlayKahmlMainTheme();
		}
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
	}
	
	if(fl_AbilityManagement_Timer[npc.index] <= gameTime && !b_AbilityManagement[npc.index] && !b_AbilityDoubleBarrel[npc.index] && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] && !b_AnhilationReady[npc.index] && !b_EnableGun[npc.index])
	{
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				b_AbilityDoubleBarrel[npc.index] = true;
				b_AbilityManagement[npc.index] = true;
				b_EnableGun[npc.index] = true;
				fl_AbilityDoubleBarrel_Timer[npc.index] = gameTime + fl_AbilityDoubleBarrel_EndTimer;
				i_AbilityDoubleBarrel_HitAmount[npc.index] = 0;
				CPrintToChatAll("{blue}Kahmlstein{default}: Do not fear {crimson}DEATH{default}, it's pointless.");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable6, "Disable");
				npc.PlayDoubleBarrel();
			}
			case 2:
			{
				b_AbilityNeckSnap[npc.index] = true;
				b_AbilityManagement[npc.index] = true;
				fl_AbilityNeckSnap_Timer[npc.index] = gameTime + fl_AbilityNeckSnap_EndTimer;
				npc.PlaySnapPrepare();
				i_AbilityNeckSnap_HitAmount[npc.index] = 0;
				CPrintToChatAll("{blue}Kahmlstein{default}: I'm going to {crimson}BREAK YOOOUUU");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				AcceptEntityInput(npc.m_iWearable6, "Disable");
			}
			case 3:
			{
				b_AbilityNanoMachines[npc.index] = true;
				b_AbilityManagement[npc.index] = true;
				fl_AbilityNanoMachines_Timer[npc.index] = gameTime + fl_AbilityNanoMachines_EndTimer;
				npc.m_flSpeed = fl_NanoSpeed;
				CPrintToChatAll("{blue}Kahmlstein{default}: {red}NANOMACHINES SON,{default} they harden in responce too physical trauma, {red}You can't hurt me.");
				npc.m_flMeleeArmor = fl_NanoDamageRes;
				npc.m_flRangedArmor = fl_NanoDamageRes;
				npc.PlayNanoSound();
			}
		}
	}
	if(i_HitAmounts[npc.index] == i_MaxHitAmount + 1)//reset needs to be +1 so i can have it accurate
	{
		i_HitAmounts[npc.index] = 0;
	}
	if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit + 1)//reset same as above
	{
		i_CritAttacks[npc.index] = 0;
	}
	if(fl_AbilityDoubleBarrel_Timer[npc.index] <= gameTime && b_AbilityDoubleBarrel[npc.index] || i_AbilityDoubleBarrel_HitAmount[npc.index] == 2)
	{
		fl_AbilityManagement_Timer[npc.index] = gameTime + fl_AbilitySecondUsageTimer;
		b_AbilityDoubleBarrel[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		b_EnableGun[npc.index] = false;
		i_AbilityDoubleBarrel_HitAmount[npc.index] = 0;
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
	}
	if(fl_AbilityNeckSnap_Timer[npc.index] <= gameTime && b_AbilityNeckSnap[npc.index] || i_AbilityNeckSnap_HitAmount[npc.index] == 1)
	{
		fl_AbilityManagement_Timer[npc.index] = gameTime + fl_AbilitySecondUsageTimer;
		b_AbilityNeckSnap[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		i_AbilityNeckSnap_HitAmount[npc.index] = 0;
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
	}
	if(fl_AbilityNanoMachines_Timer[npc.index] <= gameTime && b_AbilityNanoMachines[npc.index])
	{
		fl_AbilityManagement_Timer[npc.index] = gameTime + fl_AbilitySecondUsageTimer;
		b_AbilityNanoMachines[npc.index] = false;
		b_AbilityManagement[npc.index] = false;
		npc.m_flSpeed = fl_DefaultSpeed;
		if(b_EmergencyRes)
		{
			npc.m_flMeleeArmor = fl_EmergencyRes;
			npc.m_flRangedArmor = fl_EmergencyRes;
		}
		else
		{
			npc.m_flMeleeArmor = 1.0;
			npc.m_flRangedArmor = 1.0;
		}
	}
	if(fl_AbilityNanoMachinesHealing_Timer[npc.index] <= gameTime && b_AbilityNanoMachines[npc.index])
	{
		fl_AbilityNanoMachinesHealing_Timer[npc.index] = gameTime + 0.2;
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 200000);
	}
	if(fl_Anhilation_Timer[npc.index] <= gameTime && !b_AnhilationReady[npc.index] && !b_AbilityNanoMachines[npc.index] && !b_AbilityNeckSnap[npc.index] && !b_AbilityDoubleBarrel[npc.index])
	{
		CPrintToChatAll("{blue}Kahmlstein{default}: {red}HIDE COWARDS {crimson}I WILL FIND YOU!");
		npc.m_flSpeed = 200.0;
		b_AnhilationReady[npc.index] = true;
		b_EnableGun[npc.index] = true;
		fl_Anhilation_Timer[npc.index] = gameTime + 11.0;
		npc.m_flMeleeArmor = 0.3;
		npc.m_flRangedArmor = 0.1;
		npc.PlayHeavyTerror();
	}
	if(fl_Anhilation_Timer[npc.index] <= gameTime && b_AnhilationReady[npc.index])
	{
		fl_AbilityManagement_Timer[npc.index] = gameTime + 7.0;
		b_AnhilationReady[npc.index] = false;
		b_EnableGun[npc.index] = false;
		npc.m_flMeleeArmor = 1.0;
		npc.m_flRangedArmor = 1.0;
		fl_Anhilation_Timer[npc.index] = gameTime + 30.0;
		npc.m_flSpeed = fl_DefaultSpeed;
	}
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
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
	if(npc.m_iChanged_WalkCycle != 3 && b_AnhilationReady[npc.index] && !b_AbilityDoubleBarrel[npc.index])
	{
		npc.m_iChanged_WalkCycle = 3;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Enable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 1 && b_AbilityDoubleBarrel[npc.index] && !b_AnhilationReady[npc.index])
	{
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	if(npc.m_iChanged_WalkCycle != 2 && !b_AbilityDoubleBarrel[npc.index] && !b_AnhilationReady[npc.index] && !b_EnableGun[npc.index])
	{//Back to original melee
		npc.m_iChanged_WalkCycle = 2;
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable6, "Disable");
		//AcceptEntityInput(npc.m_iWearable3, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{	
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
		if(npc.m_flNextTeleport < GetGameTime(npc.index) && !b_TeleporterReady[npc.index] && flDistanceToTarget > 1520000 && !b_AnhilationReady[npc.index])
		{
			npc.m_flSpeed = 0.0;
			npc.AddGesture("ACT_MP_CYOA_PDA_INTRO");
			npc.m_flNextTeleport = GetGameTime(npc.index) + 1.5;
			b_TeleporterReady[npc.index] = true;
		}
		if(npc.m_flNextTeleport <= GetGameTime(npc.index) && b_TeleporterReady[npc.index])
		{
			npc.AddGesture("ACT_MP_CYOA_PDA_OUTRO");
			b_TeleporterReady[npc.index] = false;
			b_Teleportering[npc.index] = true;
			
		}
		if(b_Teleportering[npc.index])
		{
			static float flVel[3];
			npc.FaceTowards(vecTarget);
			npc.FaceTowards(vecTarget);
			GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
			float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
			b_Teleportering[npc.index] = false;
			if(Tele_Check < 100000000 || Tele_Check < 10000000 || Tele_Check < 1000000 || Tele_Check < 100000 || Tele_Check < 10000 || Tele_Check > 100000000 || Tele_Check > 10000000 || Tele_Check > 1000000 || Tele_Check > 100000 || Tele_Check > 10000)
			{
				TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
				npc.m_flNextTeleport = GetGameTime(npc.index) + 12.0;
				npc.m_flSpeed = fl_DefaultSpeed;
				//npc.PlayTeleportSound();
			}
		}
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 352000 && npc.m_flReloadDelay < GetGameTime(npc.index) && b_EnableGun[npc.index])
		{//Exodia
			int target;
			
			target = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(!IsValidEnemy(npc.index, target))
			{
				npc.StartPathing();
			}
			else
			{
				vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 1400.0);
				//NPC_StopPathing(npc.index);
				//npc.m_bPathing = false;
				npc.FaceTowards(vecTarget, 10000.0);
				if(b_AbilityDoubleBarrel[npc.index])
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.4;
				}
				if(b_AnhilationReady[npc.index])
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.2;
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
					if(b_AbilityDoubleBarrel[npc.index])
					{
						npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
						npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
						npc.m_iAttacksTillReload = 500;
						npc.PlayFamilyBusinessReload();
					}
					if(b_AnhilationReady[npc.index])
					{
						//npc.AddGesture("");
						npc.m_iAttacksTillReload = 500;
						npc.m_flReloadDelay = GetGameTime(npc.index) + 0.0;
					}
				}
				
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(b_AbilityDoubleBarrel[npc.index])
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
					npc.FireArrow(vecTarget, fl_DoubleBarrel_Damage, 1400.0, _, 1.0);
					i_AbilityDoubleBarrel_HitAmount[npc.index]++;
					npc.PlayFamilyBusinessSound();
				}
				
				if(b_AnhilationReady[npc.index])
				{
					npc.AddGesture("ACT_MP_DEPLOYED_PRIMARY");
					npc.FireRocket(vecTarget, 140.0, 2500.0, "models/effects/combineball.mdl", 1.0, EP_NO_KNOCKBACK);
					npc.PlayGattlingSound();
				}
			}
		}
		//Target close enough to hit
		if(flDistanceToTarget < 22500 && !b_EnableGun[npc.index] || npc.m_flAttackHappenswillhappen && !b_EnableGun[npc.index])
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < gameTime)
			{
				//Play attack ani
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					//This is such a mess i want to die
					if(i_HitAmounts[npc.index] == i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] 
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flAttackHappens = gameTime + 0.14;
						npc.m_flAttackHappens_bullshit = gameTime + 0.29;
					}
					else if(b_AbilityNanoMachines[npc.index] && !b_AbilityNeckSnap[npc.index])
					{
						npc.m_flAttackHappens = gameTime + 0.10;
						npc.m_flAttackHappens_bullshit = gameTime + 0.15;
					}
					else if(b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flAttackHappens = gameTime + 0.8;
						npc.m_flAttackHappens_bullshit = gameTime + 0.99;
					}
					else if(i_HitAmounts[npc.index] != i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] 
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flAttackHappens = gameTime + 0.27;
						npc.m_flAttackHappens_bullshit = gameTime + 0.39;
					}
					
					npc.m_flAttackHappenswillhappen = true;
				}	
				if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(target <= MaxClients)
							{
								if(i_HitAmounts[npc.index] == i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo Crit1{default}:%.0f", fl_ComboHitsDamage * fl_CritMultiplier - 110.0);
										}
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage, DMG_CLUB, -1, _, vecHit);
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo1{default}:%.0f", fl_ComboHitsDamage - 110.0);
										}
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
								if(i_HitAmounts[npc.index] == i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage * fl_CritMultiplier - 75.0, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo Crit2{default}:%.0f", fl_ComboHitsDamage * fl_CritMultiplier -75.0);
										}
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage - 75.0, DMG_CLUB, -1, _, vecHit);
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo2{default}:%.0f", fl_ComboHitsDamage - 75.0);
										}
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
								if(i_HitAmounts[npc.index] == i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo Crit3{default}:%.0f", fl_ComboHitsDamage * fl_CritMultiplier);
										}
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage, DMG_CLUB, -1, _, vecHit);
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo3{default}:%.0f", fl_ComboHitsDamage);
										}
									}
									if(IsValidClient(target))
									{
										Custom_Knockback(npc.index, target, 600.0, true);
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
								if(i_HitAmounts[npc.index] == i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo Crit4{default}:%.0f", fl_ComboHitsDamage * fl_CritMultiplier);
										}
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_ComboHitsDamage, DMG_CLUB, -1, _, vecHit);
										npc.PlayMeleeComboSound();
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Combo4{default}:%.0f", fl_ComboHitsDamage);
										}
									}
									if(IsValidClient(target))
									{
										Custom_Knockback(npc.index, target, 800.0, true);
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
								else if(b_AbilityNanoMachines[npc.index] && !b_AbilityNeckSnap[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamage * fl_CritMultiplier - 75.0, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Nano Crit{default}:%.0f", fl_MainMeleeDamage * fl_CritMultiplier - 75.0);
										}
										npc.PlayCritSound();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamage - 75.0, DMG_CLUB, -1, _, vecHit);
										if(b_KahmlDamageDebug)
										{
											CPrintToChatAll("{red}Damage Nano{default}:%.0f", fl_MainMeleeDamage - 75.0);
										}
									}
									i_CritAttacks[npc.index]++;
								}
								else if(b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(IsValidClient(target))
									{
										Custom_Knockback(npc.index, target, 1200.0, true);
										TF2_StunPlayer(target, 0.3, _, TF_STUNFLAGS_LOSERSTATE, 0);
									}
									for(int i=1; i<=MaxClients; i++)
									{
										if(IsClientInGame(i) && !IsFakeClient(i))
										{
											SendConVarValue(i, sv_cheats, "1");
										}
									}
									cvarTimeScale.SetFloat(0.3);
									CreateTimer(0.5, SetTimeBack);
									SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamage * fl_AbilityNeckSnap_DmgMultiplier, DMG_CLUB|DMG_CRIT, -1, _, vecHit);
									i_AbilityNeckSnap_HitAmount[npc.index]++;
									npc.PlaySnappedSound();
									if(b_KahmlDamageDebug)
									{
										CPrintToChatAll("{red}Damage Snap{default}:%.0f", fl_MainMeleeDamage*fl_AbilityNeckSnap_DmgMultiplier);
									}
								}
								else
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamage * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamage, DMG_CLUB, -1, _, vecHit);
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
							}
							else//Npc/Building
							{
								if(i_HitAmounts[npc.index] == i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] 
								|| i_HitAmounts[npc.index] == i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
								|| i_HitAmounts[npc.index] == i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
								|| i_HitAmounts[npc.index] == i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding, DMG_CLUB, -1, _, vecHit);
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
								else if(b_AbilityNanoMachines[npc.index] && !b_AbilityNeckSnap[npc.index])
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding, DMG_CLUB, -1, _, vecHit);
									}
									i_CritAttacks[npc.index]++;
								}
								else if(b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding * fl_AbilityNeckSnap_DmgMultiplier * 10.0, DMG_CLUB, -1, _, vecHit);
									i_AbilityNeckSnap_HitAmount[npc.index]++;
								}
								else
								{
									if(i_CritAttacks[npc.index] == i_MaxHitsUntilCrit)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding * fl_CritMultiplier, DMG_CLUB, -1, _, vecHit);
										i_CritAttacks[npc.index] = 0;
										npc.PlayCritSound();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainMeleeDamageNpcBuilding, DMG_CLUB, -1, _, vecHit);
									}
									i_HitAmounts[npc.index]++;
									i_CritAttacks[npc.index]++;
								}
							}
							//Hit sound
							npc.PlayMeleeHitSound();	
						} 
					}
					delete swingTrace;
					if(i_HitAmounts[npc.index] == i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -3 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -1 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.19;
					}
					else if(b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.1;
					}
					else if(b_AbilityNeckSnap[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 1.3;
					}
					else if(i_HitAmounts[npc.index] != i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] 
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.27;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(i_HitAmounts[npc.index] == i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -3 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount -1 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] == i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.19;
					}
					else if(b_AbilityNanoMachines[npc.index] && !b_AbilityNeckSnap[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.1;
					}
					else if(b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 1.3;
					}
					else if(i_HitAmounts[npc.index] != i_MaxHitAmount -6 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index] 
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -4 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount -2 && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| i_HitAmounts[npc.index] != i_MaxHitAmount && !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index]
					|| !b_AbilityNeckSnap[npc.index] && !b_AbilityNanoMachines[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.27;
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
}

public Action BunkerKahml_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BunkerKahml npc = view_as<BunkerKahml>(victim);
	
	float gameTime = GetGameTime(npc.index);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BunkerKahml_NPCDeath(int entity)
{
	BunkerKahml npc = view_as<BunkerKahml>(entity);
	npc.PlayDeathSound();
	if(!b_IsAlliedNpc[npc.index])
	{
		Music_Stop_KahmlTheme(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, BunkerKahml_ClotThink);
	
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
}

void Music_Stop_KahmlTheme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/kahml/theme1_1.mp3");
}

void Music_Stop_Beat_Ten9(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
}