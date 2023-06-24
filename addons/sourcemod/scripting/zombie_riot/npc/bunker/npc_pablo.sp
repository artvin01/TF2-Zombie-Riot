#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/pablonew/pablo_death1.mp3",
	"freak_fortress_2/pablonew/pablo_death2.mp3",
	"freak_fortress_2/pablonew/pablo_death3.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/spy_niceshot01.mp3",
	"vo/spy_niceshot02.mp3",
	"vo/spy_niceshot03.mp3",
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
static const char g_MeleeAttackSounds[][] = {
	"vo/spy_laughhappy01.mp3",
	"vo/spy_laughhappy02.mp3",
	"vo/spy_laughhappy03.mp3",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/ambassador_shoot.wav",
};

static const char g_RangeAttackTwo[][] = {
	"weapons/letranger_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/revolver_worldreload.wav",
};

static const char g_PabloMusic[][] = {
	"#freak_fortress_2/pablo/newbgm2.mp3",
};

static const char g_PabloLifelossMusic[][] = {
	"#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3",
};
static float fl_AbilityManager_Timer[MAXENTITIES];
static float fl_AbilityManager_TimerFirstUsage = 10.0;
static float fl_AbilityManager_TimerSecondUsage = 15.0;
static bool b_AbilityManager[MAXENTITIES];
static bool b_AbilityFastKnife[MAXENTITIES];

static float fl_LifelossSpeed = 360.0;

static float fl_MoreGunTimer[MAXENTITIES];
static float fl_FinalGunTimer[MAXENTITIES];
static float fl_FastAsHellKnife[MAXENTITIES];
static float fl_TheExplosiveFart[MAXENTITIES];
static float fl_DisableFakeUber[MAXENTITIES];
static bool b_FinalGunReady[MAXENTITIES];
static bool b_FinalGunUsage[MAXENTITIES];
static bool b_MoreGunUsage[MAXENTITIES];
static bool b_MoreGunReady[MAXENTITIES];
static bool b_FastAsHellKnifeReady[MAXENTITIES];
static bool b_TheExplosiveFart[MAXENTITIES];
static bool b_Lifeloss[MAXENTITIES];
static bool b_FakeUber[MAXENTITIES];

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_PabloMusic[MAXENTITIES];

#define EXPLOSION1			"weapons/airstrike_small_explosion_03.wav"
#define EXPLOSION2			"weapons/airstrike_small_explosion_02.wav"
#define EXPLOSION3			"weapons/airstrike_small_explosion_03.wav"

void Pablo_Gonzales_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangeAttackTwo));   i++) { PrecacheSound(g_RangeAttackTwo[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_PabloMusic));   i++) { PrecacheSound(g_PabloMusic[i]);   }
	for (int i = 0; i < (sizeof(g_PabloLifelossMusic));   i++) { PrecacheSound(g_PabloLifelossMusic[i]);   }
	PrecacheSound("mvm/mvm_warning.wav", true);
	PrecacheSound("mvm/mvm_tank_end.wav", true);
	PrecacheSound("mvm/mvm_tank_deploy.wav", true);
	PrecacheSound("freak_fortress_2/pablonew/stabbed1.mp3", true);
	PrecacheSound("freak_fortress_2/pablonew/stabbed3.mp3", true);
	PrecacheSound("freak_fortress_2/pablonew/lostlife.mp3", true);
	PrecacheSound("freak_fortress_2/pablonew/hyperrage.mp3", true);
	PrecacheSound("freak_fortress_2/pablonew/moregun.mp3", true);
	PrecacheSound("vo/announcer_time_added.mp3", true);
	PrecacheSound(EXPLOSION1, true);
	PrecacheSound(EXPLOSION2, true);
	PrecacheSound(EXPLOSION3, true);
}

methodmap Pablo_Gonzales < CClotBody
{
	property float fl_FastAsHellKnife
	{
		public get()							{ return fl_FastAsHellKnife[this.index]; }
		public set(float TempValueForProperty) 	{ fl_FastAsHellKnife[this.index] = TempValueForProperty; }
	}
	property bool b_FastAsHellKnifeReady
	{
		public get()							{ return b_FastAsHellKnifeReady[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FastAsHellKnifeReady[this.index] = TempValueForProperty; }
	}
	property bool b_AbilityManager
	{
		public get()							{ return b_AbilityManager[this.index]; }
		public set(bool TempValueForProperty) 	{ b_AbilityManager[this.index] = TempValueForProperty; }
	}
	property bool b_TheExplosiveFart
	{
		public get()							{ return b_TheExplosiveFart[this.index]; }
		public set(bool TempValueForProperty) 	{ b_TheExplosiveFart[this.index] = TempValueForProperty; }
	}
	property bool b_Lifeloss
	{
		public get()							{ return b_Lifeloss[this.index]; }
		public set(bool TempValueForProperty) 	{ b_Lifeloss[this.index] = TempValueForProperty; }
	}
	property bool b_FakeUber
	{
		public get()							{ return b_FakeUber[this.index]; }
		public set(bool TempValueForProperty) 	{ b_FakeUber[this.index] = TempValueForProperty; }
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
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayLeShitengler() {
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
	public void PlayPabloMusic() {
		EmitSoundToAll(g_PabloMusic[GetRandomInt(0, sizeof(g_PabloMusic) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayPabloMusic()");
		#endif
	}
	public void PlayLifelossMusic() {
		EmitSoundToAll(g_PabloLifelossMusic[GetRandomInt(0, sizeof(g_PabloLifelossMusic) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayLifelossMusic()");
		#endif
	}
	
	public Pablo_Gonzales(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Pablo_Gonzales npc = view_as<Pablo_Gonzales>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "225000", ally));
		
		i_NpcInternalId[npc.index] = PABLO_GONZALES;
		
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
					ShowGameText(client_check, "item_armor", 1, "%t", "Pablo Spawn Message");
				}
			}
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			fl_PabloMusic[npc.index] = GetGameTime(npc.index) + 1.0;
		}
		npc.m_bThisNpcIsABoss = true;
		
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerFirstUsage;
		b_FinalGunReady[npc.index] = false;
		b_FinalGunUsage[npc.index] = false;
		b_MoreGunReady[npc.index] = false;
		b_FastAsHellKnifeReady[npc.index] = false;
		b_TheExplosiveFart[npc.index] = false;
		b_AbilityManager[npc.index] = false;
		b_Lifeloss[npc.index] = false;
		b_FakeUber[npc.index] = false;
		npc.m_fbGunout = false;
		npc.Anger = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_flNextMeleeAttack = 0.0;
	
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Pablo_Gonzales_ClotDamaged_Post);
		SDKHook(npc.index, SDKHook_Think, Pablo_Gonzales_ClotThink);
		
		npc.m_iState = 0;
		npc.m_flSpeed = 300.0;
		npc.m_flAttackHappenswillhappen = false;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/all_class/ghostly_gibus_spy.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_voodoo_pin/c_voodoo_pin.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		
		npc.m_iWearable3 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_ambassador/c_ambassador.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
		
		npc.m_iWearable4 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_letranger/c_letranger.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable4, 255, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Pablo_Gonzales_ClotThink(int iNPC)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	
	if(!b_IsAlliedNpc[npc.index])//Don't allow the ally version to fuck over the round
	{
		if(RaidModeTime < GetGameTime())
		{
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			if(b_Lifeloss[npc.index])
			{
				Music_Stop_PabloLifelossTheme(iNPC);
			}
			else
			{
				Music_Stop_MainPablo_Theme(iNPC);
			}
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, Pablo_Gonzales_ClotThink);
		}
		if(fl_PabloMusic[npc.index] <= gameTime && !b_Lifeloss[npc.index])
		{
			fl_PabloMusic[npc.index] = gameTime + 143.0;
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Masafumi Takada {default}- {orange}Mr. Monokuma After Class V3");//idk though it's fancy showing it
			npc.PlayPabloMusic();
		}
		if(fl_PabloMusic[npc.index] <= gameTime && b_Lifeloss[npc.index])
		{
			fl_PabloMusic[npc.index] = gameTime + 375.0;//technically he doesn't need it but i did it anyway if the round is somehow 6mins long
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Carpenter Brut {default}- {orange}You're Mine");//idk though it's fancy showing it
			npc.PlayLifelossMusic();
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
	
	if(fl_AbilityManager_Timer[npc.index] <= gameTime && !b_AbilityManager[npc.index])
	{
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				switch(GetRandomInt(1,2))//switch case in a switch case in a switch case in a switch case
				{
					case 1:
					{
						CPrintToChatAll("{crimson}[WARNING] {default}Pablo gained {red}FINAL GUN!");
						EmitSoundToAll("mvm/mvm_warning.wav", _, _, _, _, 1.0);
						EmitSoundToAll("freak_fortress_2/pablonew/finalgun.mp3", _, _, _, _, 1.0);
						fl_FinalGunTimer[npc.index] = gameTime + 3.1;
						b_FinalGunReady[npc.index] = true;
						npc.m_iAttacksTillReload = 1;
						for(int client = 1; client <= MaxClients; client++)
						{
							if(IsValidClient(client))
							{
								SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
								SetGlobalTransTarget(client);
								ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained FINAL GUN!");
							}
						}
					}
					case 2:
					{
						CPrintToChatAll("{crimson}[WARNING] {default}Pablo gained {red}MORE GUN!");
						EmitSoundToAll("mvm/mvm_warning.wav", _, _, _, _, 1.0);
						EmitSoundToAll("freak_fortress_2/pablonew/moregun.mp3", _, _, _, _, 1.0);
						fl_MoreGunTimer[npc.index] = gameTime + 3.1;
						b_MoreGunReady[npc.index] = true;
						npc.m_iAttacksTillReload = 12;
						for(int client = 1; client <= MaxClients; client++)
						{
							if(IsValidClient(client))
							{
								SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
								SetGlobalTransTarget(client);
								ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained MORE GUN!");
							}
						}
					}
				}
			}
			case 2:
			{
				CPrintToChatAll("{crimson}[WARNING] {default}Pablo gained {yellow}Fast {red}BUTTERKNIFE!");
				EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0);
				EmitSoundToAll("freak_fortress_2/pablonew/power.mp3", _, _, _, _, 1.0);
				fl_FastAsHellKnife[npc.index] = gameTime + 2.1;
				b_FastAsHellKnifeReady[npc.index] = true;
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo Gained Fast BUTTERKNIFE!");
					}
				}
			}
			case 3:
			{
				CPrintToChatAll("{crimson}[WARNING] {default}Pablo is about to {red}EXPLODE the Area.");
				EmitSoundToAll("mvm/mvm_warning.wav", _, _, _, _, 1.0);
				float vEnd[3];
				GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
				spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 0.6, 4.0, 0.1, 1, 1.0);
				spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.8, 4.0, 0.1, 1, 1.0);
				fl_TheExplosiveFart[npc.index] = gameTime + 4.1;
				b_TheExplosiveFart[npc.index] = true;
				
				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client))
					{
						SetHudTextParams(-1.0, 0.25, 3.01, 34, 139, 34, 255);
						SetGlobalTransTarget(client);
						ShowSyncHudText(client, SyncHud_Notifaction, "WARNING!\nPablo is about to EXPLODE the Area.");
						if(!b_IsAlliedNpc[npc.index])
						{
							SetVariantString("HalloweenLongFall");
							AcceptEntityInput(client, "SpeakResponseConcept");
						}
					}
				}
			}
		}
		b_AbilityManager[npc.index] = true;
	}
	if(fl_MoreGunTimer[npc.index] <= gameTime && b_MoreGunReady[npc.index] && !b_MoreGunUsage[npc.index])
	{
		fl_MoreGunTimer[npc.index] = gameTime + 3.2;
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Enable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		b_MoreGunUsage[npc.index] = true;
	}
	if(fl_MoreGunTimer[npc.index] <= gameTime && b_MoreGunReady[npc.index] && b_MoreGunUsage[npc.index])
	{
		b_MoreGunReady[npc.index] = false;
		b_MoreGunUsage[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerSecondUsage;
		b_AbilityManager[npc.index] = false;
		npc.m_iChanged_WalkCycle = 2;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
	}
	if(fl_FinalGunTimer[npc.index] <= gameTime && b_FinalGunReady[npc.index] && !b_FinalGunUsage[npc.index])
	{
		fl_FinalGunTimer[npc.index] = gameTime + 3.2;
		npc.m_iChanged_WalkCycle = 1;
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		AcceptEntityInput(npc.m_iWearable3, "Enable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
		int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
		b_FinalGunUsage[npc.index] = true;
	}
	if(fl_FinalGunTimer[npc.index] <= gameTime && b_FinalGunReady[npc.index] && b_FinalGunUsage[npc.index])
	{
		b_FinalGunReady[npc.index] = false;
		b_FinalGunUsage[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerSecondUsage;
		b_AbilityManager[npc.index] = false;
		npc.m_iChanged_WalkCycle = 2;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		AcceptEntityInput(npc.m_iWearable2, "Enable");
		AcceptEntityInput(npc.m_iWearable3, "Disable");
		AcceptEntityInput(npc.m_iWearable4, "Disable");
	}
	if(fl_TheExplosiveFart[npc.index] <= gameTime && b_TheExplosiveFart[npc.index])
	{
		b_TheExplosiveFart[npc.index] = false;
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				EmitSoundToAll(EXPLOSION1, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 2:
			{
				EmitSoundToAll(EXPLOSION2, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 3:
			{
				EmitSoundToAll(EXPLOSION3, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		}
		float damage = 1000.0;
		float radius = 750.0;
		spawnRing_Vectors(pos, radius, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 0.2, 4.0, 0.1, 1, 1.0);
		spawnRing_Vectors(pos, radius, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 0.4, 4.0, 0.1, 1, 1.0);
		Explode_Logic_Custom(damage, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, radius, _, 0.8, true);
		b_AbilityManager[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerSecondUsage;
	}
	if(fl_FastAsHellKnife[npc.index] <= gameTime && b_FastAsHellKnifeReady[npc.index] && !b_AbilityFastKnife[npc.index] && !b_Lifeloss[npc.index])
	{
		fl_FastAsHellKnife[npc.index] = gameTime + 5.0;
		b_AbilityFastKnife[npc.index] = true;
	}
	if(fl_FastAsHellKnife[npc.index] <= gameTime && b_FastAsHellKnifeReady[npc.index] && b_AbilityFastKnife[npc.index] && !b_Lifeloss[npc.index])
	{
		b_FastAsHellKnifeReady[npc.index] = false;
		b_AbilityFastKnife[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerSecondUsage;
		b_AbilityManager[npc.index] = false;
	}
	if(fl_FastAsHellKnife[npc.index] <= gameTime && b_FastAsHellKnifeReady[npc.index] && !b_AbilityFastKnife[npc.index] && b_Lifeloss[npc.index])
	{
		fl_FastAsHellKnife[npc.index] = gameTime + 5.0;
		b_AbilityFastKnife[npc.index] = true;
		npc.m_flSpeed = fl_LifelossSpeed*2;
		if(!b_IsAlliedNpc[npc.index])//again if he somehow is an ally remove this ability for the ally
		{
			for(int i=1; i<=MaxClients; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i))
				{
					SendConVarValue(i, sv_cheats, "1");
				}
			}
			cvarTimeScale.SetFloat(0.3);
			CreateTimer(2.5, SetTimeBack);
		}
	}
	if(fl_FastAsHellKnife[npc.index] <= gameTime && b_FastAsHellKnifeReady[npc.index] && b_AbilityFastKnife[npc.index] && b_Lifeloss[npc.index])
	{
		b_FastAsHellKnifeReady[npc.index] = false;
		b_AbilityFastKnife[npc.index] = false;
		fl_AbilityManager_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManager_TimerSecondUsage;
		b_AbilityManager[npc.index] = false;
		npc.m_flSpeed = fl_LifelossSpeed;
	}
	if(fl_DisableFakeUber[npc.index] <= gameTime && b_FakeUber[npc.index] && b_Lifeloss[npc.index])
	{
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 1);
		b_FakeUber[npc.index] = false;
		npc.m_flRangedArmor = 0.65;//Nerf if too strong
		npc.m_flMeleeArmor = 0.65;
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex, true))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);	
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
		if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 352000 && npc.m_flReloadDelay < GetGameTime(npc.index) && b_FinalGunUsage[npc.index]
		|| npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < 352000 && npc.m_flReloadDelay < GetGameTime(npc.index) && b_MoreGunUsage[npc.index])
		{
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
				if(b_MoreGunUsage[npc.index])
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.08;
				}
				if(b_FinalGunUsage[npc.index])
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 1.2;
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
					if(b_MoreGunUsage[npc.index])
					{
						npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
					}
					if(b_FinalGunUsage[npc.index])
					{
						npc.m_flReloadDelay = GetGameTime(npc.index) + 0.4;
					}
					npc.m_iAttacksTillReload = 500;
					npc.AddGesture("ACT_MP_RELOAD_STAND_SECONDARY");
					npc.PlayRangedReloadSound();
				}
				
				float vecDir[3];
				vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
				vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
				vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
				NormalizeVector(vecDir, vecDir);
				
				if(b_MoreGunUsage[npc.index])
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
					if(b_Lifeloss[npc.index])
					{
						npc.FireArrow(vecTarget, 120.0, 1400.0, _, 1.0);
					}
					else
					{
						npc.FireArrow(vecTarget, 80.0, 1000.0, _, 1.0);
					}
					npc.PlayLeShitengler();
				}
				
				if(b_FinalGunUsage[npc.index])
				{
					if(b_Lifeloss[npc.index])
					{
						FireBullet(npc.index, npc.m_iWearable3, WorldSpaceCenter(npc.index), vecDir, 600.0, 9000.0, DMG_BULLET|DMG_CRIT, "bullet_tracer01_red");
					}
					else
					{
						FireBullet(npc.index, npc.m_iWearable3, WorldSpaceCenter(npc.index), vecDir, 600.0, 2000.0, DMG_BULLET, "bullet_tracer01_red");
					}
					npc.PlayRangedSound();
				}
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
			}
		}
		if(flDistanceToTarget < 62500 && !b_FinalGunUsage[npc.index] && !b_MoreGunUsage[npc.index] || npc.m_flAttackHappenswillhappen && !b_FinalGunUsage[npc.index] && !b_MoreGunUsage[npc.index])
		{
			npc.StartPathing();
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 2000.0);
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && flDistanceToTarget < 30000)
			{
				if(!npc.m_flAttackHappenswillhappen)
				{
					//npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					if(b_AbilityFastKnife[npc.index])
					{
						npc.m_flAttackHappens = 0.00;
						npc.m_flAttackHappens_bullshit = gameTime + 0.01;
					}
					else if(!b_AbilityFastKnife[npc.index])
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
								if(b_AbilityFastKnife[npc.index])
								{
									if(b_Lifeloss[npc.index])
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0 / 1.5, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 230.0 / 1.5, DMG_CLUB, -1, _, vecHit);
									}
								}
								else
								{
									if(b_Lifeloss[npc.index])
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 300.0, DMG_CLUB, -1, _, vecHit);
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, 230.0, DMG_CLUB, -1, _, vecHit);
									}
								}
							}
							else
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 9000.0, DMG_CLUB, -1, _, vecHit);
							}
							//Hit sound
							npc.PlayMeleeHitSound();
						}
					}
					delete swingTrace;
					if(b_AbilityFastKnife[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.01;
					}
					else if(!b_AbilityFastKnife[npc.index])
					{
						if(b_Lifeloss[npc.index])
						{
							npc.m_flNextMeleeAttack = gameTime + 0.23;
						}
						else
						{
							npc.m_flNextMeleeAttack = gameTime + 0.5;
						}
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(b_AbilityFastKnife[npc.index])
					{
						npc.m_flNextMeleeAttack = gameTime + 0.01;
					}
					else if(!b_AbilityFastKnife[npc.index])
					{
						if(b_Lifeloss[npc.index])
						{
							npc.m_flNextMeleeAttack = gameTime + 0.23;
						}
						else
						{
							npc.m_flNextMeleeAttack = gameTime + 0.5;
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

public Action Set_Pablo_Gonzales_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void Pablo_Gonzales_ClotDamaged_Post(int iNPC, int attacker, int inflictor, float damage, int damagetype)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(iNPC);
	//pablo is about to become even stronger and with one more additional ability
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:( your mother
		EmitSoundToAll("freak_fortress_2/pablonew/lostlife.mp3", _, _, _, _, 1.0);
		b_FakeUber[npc.index] = true;
		b_Lifeloss[npc.index] = true;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", 3);
		fl_DisableFakeUber[npc.index] = GetGameTime(npc.index) + 11.0;
		npc.m_flSpeed = fl_LifelossSpeed;
		npc.m_flRangedArmor = 0.0;
		npc.m_flMeleeArmor = 0.0;
		if(!b_IsAlliedNpc[npc.index])//again if he is an ally somehow give him this
		{
			Music_Stop_MainPablo_Theme(iNPC);
			fl_PabloMusic[npc.index] = GetGameTime(npc.index) + 0.01;
			RaidModeTime += 170.0;//Time increase
			EmitSoundToAll("vo/announcer_time_added.mp3", _, _, _, _, 1.0);
			EmitSoundToAll("vo/announcer_time_added.mp3", _, _, _, _, 1.0);
		}
	}
	/*//Gonna bother later fixing it would be too bad having this gone tho
	int weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	char classname[32];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if(IsValidClient(attacker))
	{
		if(!StrContains(classname, "tf_weapon_knife", false))
		{
			if(damagetype & DMG_CLUB) //Use dmg slash for any npc that shouldnt be scaled.
			{
				if(IsBehindAndFacingTarget(attacker, iNPC))
				{
					int melee = GetIndexOfWeaponSlot(attacker, TFWeaponSlot_Melee);
					if(melee != 4 && melee != 1003)
					{
						int	entity = iNPC;
						int closest = attacker;
						if(IsValidEntity(entity) && entity>MaxClients)
						{
							if(closest > 0) 
							{
								if(closest <= MaxClients)
									//SDKHooks_TakeDamage(closest, npc.index, npc.index, 5.0 * RaidModeScaling, DMG_CLUB, -1, _);
									SDKHooks_TakeDamage(closest, npc.index, npc.index, 90.0, DMG_CLUB, -1, _);
								else
									//SDKHooks_TakeDamage(closest, npc.index, npc.index, 7.0 * RaidModeScaling, DMG_CLUB, -1, _);
									SDKHooks_TakeDamage(closest, npc.index, npc.index, 110.0, DMG_CLUB, -1, _);
								float pos[3];
								GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
								makeexplosion(-1, -1, pos, "", 0, 150);
								npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
							} 
						}
						switch(GetRandomInt(1, 2))
						{
							case 1:
							{
								EmitSoundToAll("freak_fortress_2/pablonew/stabbed1.mp3", attacker, _, _, _, 1.0);
							}
							case 2:
							{
								EmitSoundToAll("freak_fortress_2/pablonew/stabbed3.mp3", attacker, _, _, _, 1.0);
							}
						}
					}
				}
			}
		}
	}*/
}

public Action Pablo_Gonzales_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Pablo_Gonzales_NPCDeath(int entity)
{
	Pablo_Gonzales npc = view_as<Pablo_Gonzales>(entity);
	
	npc.PlayDeathSound();
	if(!b_IsAlliedNpc[npc.index])//ally shouldn't kill the music if the original pablo is there still nor killing the raid index either
	{
		if(!b_Lifeloss[npc.index])
		{
			Music_Stop_MainPablo_Theme(entity);
		}
		else if(b_Lifeloss[npc.index])
		{
			Music_Stop_PabloLifelossTheme(entity);
		}
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Pablo_Gonzales_ClotDamaged_Post);
	SDKUnhook(npc.index, SDKHook_Think, Pablo_Gonzales_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}

void Music_Stop_MainPablo_Theme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pablo/newbgm2.mp3");
}

void Music_Stop_PabloLifelossTheme(int entity)
{
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
	StopSound(entity,SNDCHAN_AUTO, "#freak_fortress_2/pablonew/pablo_lifeloss_1.mp3");
}