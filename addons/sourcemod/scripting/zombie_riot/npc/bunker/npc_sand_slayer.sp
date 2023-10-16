#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/heavy_jeers03.mp3",	
	"vo/heavy_jeers04.mp3",	
	"vo/heavy_jeers06.mp3",
	"vo/heavy_jeers09.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
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

static const char g_SandSpeed[][] = {
	"vo/heavy_sandwichtaunt13.mp3",
};

static const char g_SandvichUse[][] = {
	"freak_fortress_2/pootis_engage/be_sandvich.mp3",
};

static const char g_SlamUse[][] = {
	"freak_fortress_2/pootis_engage/ss_ostrike.mp3",
};

static const char g_Snap[][] = {
	"vo/heavy_specialweapon05.mp3",
};

/*
static const char g_DuoPootisDeathTheme[][] = {
	"#freak_fortress_2/pootis_engage/death_bgm1.mp3"
};*/

#define POOTISSLAYERSTEAK "freak_fortress_2/pootis_engage/ss_steak.mp3"
#define POOTISSLAYERCANNON "freak_fortress_2/pootis_engage/ss_cannon.mp3"
static float fl_AbilityManagement_Timer[MAXENTITIES];
static float fl_AbilityManagement_FirstTimer = 10.0;
static float fl_AbilityManagement_SecondTimer = 15.0;
static bool b_AbilityManagement[MAXENTITIES] = {false, ...};

static bool b_Snap[MAXENTITIES];
static float fl_Snap[MAXENTITIES];

static bool b_SandvichSlam[MAXENTITIES];
static float fl_SandvichSlam_Timer[MAXENTITIES] = {0.0, ...};
static float fl_SandvichSlam_UsageTimer = 4.9;

static bool b_Sandvich[MAXENTITIES];
static float fl_Sandvich_Timer[MAXENTITIES] = {0.0, ...};
static int i_MaxSandvichUse[MAXENTITIES];

static float fl_AbilitySandSpeeddo_Timer[MAXENTITIES];
static float fl_SandSpeeddo_EndTimer = 6.0;
static bool b_SandSpeeddo[MAXENTITIES] = {false, ...};

static float fl_MainSpeed = 300.0;
static float fl_SandSpeeddo_Speed = 375.0;

static bool b_Serious_Punch[MAXENTITIES] = {false, ...};
static float fl_Serious_Punch_Timer[MAXENTITIES] = {0.0, ...};
static float fl_Serious_Punch_Wearoff = 5.0;
static int i_Serious_Punch_Hit[MAXENTITIES] = {0, ...};

static int i_Crit_Hit[MAXENTITIES] = {0, ...};
static int i_Crit_HitAmount = 6;

static float fl_MainDamage = 275.0;
static float fl_MainBuildNpcDamage = 3750.0;
static float fl_SandSpeeddoDamageMult = 1.95;
static float fl_CritDamageMult = 3.0;

void SandvichSlayer_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_SandSpeed));   i++) { PrecacheSound(g_SandSpeed[i]);   }
	for (int i = 0; i < (sizeof(g_SandvichUse));   i++) { PrecacheSound(g_SandvichUse[i]);   }
	for (int i = 0; i < (sizeof(g_SlamUse));   i++) { PrecacheSound(g_SlamUse[i]);   }
	for (int i = 0; i < (sizeof(g_Snap));   i++) { PrecacheSound(g_Snap[i]);   }
	//for (int i = 0; i < (sizeof(g_DuoPootisDeathTheme));   i++) { PrecacheSound(g_DuoPootisDeathTheme[i]);   }
	PrecacheSound(POOTISOUTROMUSIC, true);
}

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];

methodmap SandvichSlayer < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayPootisDeathTheme() {
		EmitSoundToAll(g_DuoPootisDeathTheme[GetRandomInt(0, sizeof(g_DuoPootisDeathTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_DuoPootisDeathTheme[GetRandomInt(0, sizeof(g_DuoPootisDeathTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, NORMAL_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisDeathTheme()");
		#endif
	}
	public void PlayCritSoundEffect() {
		EmitSoundToAll(g_DuoCritHitPootis[GetRandomInt(0, sizeof(g_DuoCritHitPootis) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	public void PlaySandSpeeddoSound() {
		EmitSoundToAll(g_SandSpeed[GetRandomInt(0, sizeof(g_SandSpeed) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	public void PlaySandvichSound() {
		EmitSoundToAll(g_SandvichUse[GetRandomInt(0, sizeof(g_SandvichUse) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	public void PlaySlamSound() {
		EmitSoundToAll(g_SlamUse[GetRandomInt(0, sizeof(g_SlamUse) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	public void PlaySandSnap() {
		EmitSoundToAll(g_Snap[GetRandomInt(0, sizeof(g_Snap) - 1)], _, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 80);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCritSoundEffect()");
		#endif
	}
	
	public SandvichSlayer(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		SandvichSlayer npc = view_as<SandvichSlayer>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.25", "15000", ally, false, true));
		
		i_NpcInternalId[npc.index] = SANDVICH_SLAYER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			Music_Stop_Beat_Ten(client);
			//b_DuoOnePootisDied = false;
			//b_DuoDisableMainPootisTheme = false;
			//b_DuoMainLeaderDied = false;
			b_DuoOneTimeStopForExe = false;
			b_DuoSandSlayerDied = false;
			RaidModeTime = GetGameTime(npc.index) + 250.0;
			GiveNpcOutLineLastOrBoss(npc.index, true);
			for(int client_clear=1; client_clear<=MaxClients; client_clear++)
			{
				fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
			}
		}
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, SandvichSlayer_ClotThink);
		
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_FirstTimer;
		b_Sandvich[npc.index] = false;
		fl_Sandvich_Timer[npc.index] = GetGameTime(npc.index) + 157.0;
		fl_SandvichSlam_Timer[npc.index] = GetGameTime(npc.index) + fl_SandvichSlam_UsageTimer*6;
		i_MaxSandvichUse[npc.index] = 0;
		i_Serious_Punch_Hit[npc.index] = 0;
		b_AbilityManagement[npc.index] = false;
		b_SandSpeeddo[npc.index] = false;
		b_Serious_Punch[npc.index] = false;
		
		//IDLE
		npc.m_flSpeed = fl_MainSpeed;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		//Citizen_MiniBossSpawn();
		
		return npc;
	}
}

public void SandvichSlayer_ClotThink(int iNPC)
{
	SandvichSlayer npc = view_as<SandvichSlayer>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(!b_IsAlliedNpc[npc.index])
	{
		if(fl_DuoExecuteCustomPootisTheme <= GetGameTime(npc.index) && b_DuoOnePootisDied && b_DuoDisableMainPootisTheme && b_DuoMainLeaderDied)
		{
			fl_DuoExecuteCustomPootisTheme = GetGameTime(npc.index) + 262.0;
			CPrintToChatAll("{lime}[Zombie Riot]{default} Now Playing: {lightblue}Ruoska {default}- {orange}Kesä Tulla Saa");
			npc.PlayPootisDeathTheme();
		}
		if(b_DuoMainLeaderDied)//If ally died, allow the partner to compress the music from zr
		{
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
			if(RaidModeTime < GetGameTime())
			{
				int entity = CreateEntityByName("game_round_win"); //You loose.
				DispatchKeyValue(entity, "force_map_reset", "1");
				SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
				DispatchSpawn(entity);
				AcceptEntityInput(entity, "RoundWin");
				Music_RoundEnd(entity);
				RaidBossActive = INVALID_ENT_REFERENCE;
				SDKUnhook(npc.index, SDKHook_Think, SandvichSlayer_ClotThink);
			}
		}
	}
	if(fl_AbilityManagement_Timer[npc.index] <= GetGameTime(npc.index) && !b_AbilityManagement[npc.index] && !b_SandvichSlam[npc.index])
	{
		switch(GetRandomInt(1,3))
		{
			case 1:
			{
				b_SandSpeeddo[npc.index] = true;
				npc.PlaySandSpeeddoSound();
				fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				fl_AbilitySandSpeeddo_Timer[npc.index] = GetGameTime(npc.index) + fl_SandSpeeddo_EndTimer;
				npc.m_flSpeed = fl_SandSpeeddo_Speed;
			}
			case 2:
			{
				b_Serious_Punch[npc.index] = true;
				//npc.PlayBootyPunchSound();
				fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
				fl_Serious_Punch_Timer[npc.index] = GetGameTime(npc.index) + fl_Serious_Punch_Wearoff;
			}
			case 3:
			{//Yeah i think this is fucking retarded lmao
				fl_Snap[npc.index] = GetGameTime(npc.index) + 2.3;
				b_Snap[npc.index] = true;
				npc.PlaySandSnap();
			}
		}
		b_AbilityManagement[npc.index] = true;
	}
	if(fl_Snap[npc.index] <= GetGameTime(npc.index) && b_Snap[npc.index])
	{
		b_Snap[npc.index] = false;
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
		b_AbilityManagement[npc.index] = false;
		SDKHooks_TakeDamage(npc.m_iTarget, npc.index, npc.index, fl_MainDamage * 4.8, DMG_CLUB, -1, _, _);
	}
	if(fl_SandvichSlam_Timer[npc.index] <= GetGameTime(npc.index) && !b_SandvichSlam[npc.index] && !b_AbilityManagement[npc.index])
	{
		fl_SandvichSlam_Timer[npc.index] = GetGameTime(npc.index) + fl_SandvichSlam_UsageTimer;
		b_SandvichSlam[npc.index] = true;
		npc.PlaySlamSound();
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 120, 0, 255, 1, 4.3, 4.0, 0.1, 1, 1.0);
		spawnRing_Vectors(vEnd, 750.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 255, 0, 120, 1, 4.3, 4.0, 0.1, 1, 1.0);
		npc.m_flSpeed = fl_MainSpeed/4;
	}
	if(fl_SandvichSlam_Timer[npc.index] <= GetGameTime(npc.index) && b_SandvichSlam[npc.index])
	{
		b_SandvichSlam[npc.index] = false;
		fl_SandvichSlam_Timer[npc.index] = GetGameTime(npc.index) + fl_SandvichSlam_UsageTimer*5;
		float pos[3];
		GetEntPropVector(EntRefToEntIndex(iNPC), Prop_Send, "m_vecOrigin", pos);
		Explode_Logic_Custom(2000.0, EntRefToEntIndex(iNPC), EntRefToEntIndex(iNPC), -1, pos, 750.0, _, 0.8, true);
		npc.m_flSpeed = fl_MainSpeed;
	}
	if(fl_AbilitySandSpeeddo_Timer[npc.index] <= GetGameTime(npc.index) && b_SandSpeeddo[npc.index])
	{
		fl_AbilityManagement_Timer[npc.index] = GetGameTime(npc.index) + fl_AbilityManagement_SecondTimer;
		b_AbilityManagement[npc.index] = false;
		b_SandSpeeddo[npc.index] = false;
		npc.m_flSpeed = fl_MainSpeed;
	}
	if(fl_Serious_Punch_Timer[npc.index] <= GetGameTime(npc.index) && b_Serious_Punch[npc.index] || i_Serious_Punch_Hit[npc.index] == 1)
	{
		b_Serious_Punch[npc.index] = false;
		i_Serious_Punch_Hit[npc.index] = 0;
		b_AbilityManagement[npc.index] = false;
	}
	if(i_Crit_Hit[npc.index] == i_Crit_HitAmount + 1)
	{
		i_Crit_Hit[npc.index] = 0;
	}
	if(!b_Sandvich[npc.index] && fl_Sandvich_Timer[npc.index] <= GetGameTime(npc.index) && i_MaxSandvichUse[npc.index] == 0)
	{
		int MaxHealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + MaxHealth / 2);
		b_Sandvich[npc.index] = true;
		i_MaxSandvichUse[npc.index]++;
		npc.PlaySandvichSound();
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
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
		//Target close enough to hit
		if(flDistanceToTarget < 22500 || npc.m_flAttackHappenswillhappen)
		{
			//Look at target so we hit.
			//npc.FaceTowards(vecTarget, 1000.0);
			//Can we attack right now?
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				//Play attack ani
				if(!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					if(b_SandSpeeddo[npc.index] && !b_Serious_Punch[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.0;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.25;
					}
					else if(b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.45;
					}
					else if(!b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
					{
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
					}
					npc.m_flAttackHappenswillhappen = true;
				}	
				if(npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
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
								if(b_SandSpeeddo[npc.index] && !b_Serious_Punch[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_SandSpeeddoDamageMult * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_SandSpeeddoDamageMult, DMG_CLUB, -1, _, vecHit);
									}
								}
								else if(b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * 1.8 * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * 1.8, DMG_CLUB, -1, _, vecHit);
									}
									i_Serious_Punch_Hit[npc.index]++;
								}
								else
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainDamage, DMG_CLUB, -1, _, vecHit);
									}
								}
								i_Crit_Hit[npc.index]++;
							}
							else
							{
								if(b_SandSpeeddo[npc.index] && !b_Serious_Punch[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_SandSpeeddoDamageMult * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_SandSpeeddoDamageMult, DMG_CLUB, -1, _, vecHit);
									}
								}
								else if(b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * 1.8 * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * 1.8, DMG_CLUB, -1, _, vecHit);
									}
									i_Serious_Punch_Hit[npc.index]++;
								}
								else
								{
									if(i_Crit_Hit[npc.index] == i_Crit_HitAmount)
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage * fl_CritDamageMult, DMG_CLUB, -1, _, vecHit);
										npc.PlayCritSoundEffect();
									}
									else
									{
										SDKHooks_TakeDamage(target, npc.index, npc.index, fl_MainBuildNpcDamage, DMG_CLUB, -1, _, vecHit);
									}
								}
								i_Crit_Hit[npc.index]++;
							}
							//Hit sound
							npc.PlayMeleeHitSound();	
						}
					}
					delete swingTrace;
					if(b_SandSpeeddo[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					if(b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else if(!b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					if(b_SandSpeeddo[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
					}
					if(b_Serious_Punch[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
					}
					else if(!b_Serious_Punch[npc.index] && !b_SandSpeeddo[npc.index])
					{
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
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

public Action SandvichSlayer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	SandvichSlayer npc = view_as<SandvichSlayer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void SandvichSlayer_NPCDeath(int entity)
{
	SandvichSlayer npc = view_as<SandvichSlayer>(entity);
	npc.PlayDeathSound();	
	
	if(!b_IsAlliedNpc[npc.index])
	{
		//Music_Stop_Main_Theme2(entity);
		Music_Stop_Death_Theme2(entity);
		fl_DuoExecuteCustomPootisTheme = GetGameTime() + 0.01;
		b_DuoOnePootisDied = true;
		b_DuoDisableMainPootisTheme = true;
		b_DuoSandSlayerDied = true;
		//RaidBossActive = INVALID_ENT_REFERENCE;
	}
	if(b_DuoOnePootisDied && b_DuoMainLeaderDied && b_DuoSandSlayerDied)
	{
		EmitSoundToAll(POOTISOUTROMUSIC);
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, SandvichSlayer_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
/*
void Music_Stop_Main_Theme2(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
}*/

void Music_Stop_Death_Theme2(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/death_bgm1.mp3");
}