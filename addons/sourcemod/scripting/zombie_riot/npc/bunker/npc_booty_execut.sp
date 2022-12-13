#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/pootis_engage/be_ded2.mp3"
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

//gets shared with the partner
public const char g_PootisMainTheme[][] = {
	"#freak_fortress_2/pootis_engage/bgm1.mp3"
};

static const char g_PootisDeathTheme[][] = {
	"#freak_fortress_2/pootis_engage/death_bgm1.mp3"
};

bool OnePootisDied = false;
bool DisableMainPootisTheme = false;
bool MainLeaderDied = false;
bool SandSlayerDied = false;
bool OneTimeStopForExe = false;
float ExecuteCustomPootisTheme = 0.0;
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
//bool DefaultPootisTheme = false;

#define POOTISTHEME "#freak_fortress_2/pootis_engage/bgm1.mp3"
#define POOTISOUTROMUSIC "freak_fortress_2/pootis_engage/outromusic_lose.mp3"
#define POOTISBOOTYNUKE "freak_fortress_2/pootis_engage/be_rage_nuke.mp3"
#define POOTISBOOTYSANDVICH "freak_fortress_2/pootis_engage/be_sandvich.mp3"

void BootyExecutioner_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_PootisMainTheme));   i++) { PrecacheSound(g_PootisMainTheme[i]);   }
	for (int i = 0; i < (sizeof(g_PootisDeathTheme));   i++) { PrecacheSound(g_PootisDeathTheme[i]);   }
	PrecacheSound(POOTISOUTROMUSIC, true);
}

methodmap BootyExecutioner < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
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
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], _, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
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
	public void PlayPootisMainTheme() {
	
		EmitSoundToAll(g_PootisMainTheme[GetRandomInt(0, sizeof(g_PootisMainTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisMainTheme()");
		#endif
	}
	public void PlayPootisDeathTheme() {
	
		EmitSoundToAll(g_PootisDeathTheme[GetRandomInt(0, sizeof(g_PootisDeathTheme) - 1)], this.index, SNDCHAN_AUTO, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPootisMainTheme()");
		#endif
	}
	
	public BootyExecutioner(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BootyExecutioner npc = view_as<BootyExecutioner>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.5", "15000", ally, false, true));
		
		i_NpcInternalId[npc.index] = BOOTY_EXECUTIONIER;
		
		if(!b_IsAlliedNpc[npc.index])
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			Music_Stop_Beat_Ten(client);
			//this is only if they somehow magically respawned
			OnePootisDied = false;
			DisableMainPootisTheme = false;
			MainLeaderDied = false;
			//SandSlayerDied = false;
			for(int client_clear=1; client_clear<=MaxClients; client_clear++)
			{
				fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
			}
		}
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, BootyExecutioner_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, BootyExecutioner_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void BootyExecutioner_ClotThink(int iNPC)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	if(!b_IsAlliedNpc[npc.index])
	{
		if(ExecuteCustomPootisTheme <= GetGameTime(npc.index) && !OnePootisDied && !DisableMainPootisTheme && !MainLeaderDied && !SandSlayerDied)
		{
			ExecuteCustomPootisTheme = GetGameTime(npc.index) + 140.0;
			npc.PlayPootisMainTheme();
		}
		if(ExecuteCustomPootisTheme <= GetGameTime(npc.index) && OnePootisDied && DisableMainPootisTheme && SandSlayerDied)
		{
			ExecuteCustomPootisTheme = GetGameTime(npc.index) + 262.0;
			npc.PlayPootisDeathTheme();
		}
		if(SandSlayerDied && !OneTimeStopForExe)
		{
			Music_Stop_Main_Theme(iNPC);
			OneTimeStopForExe = true;
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
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
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
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
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.55;
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
								SDKHooks_TakeDamage(target, npc.index, npc.index, 125.0, DMG_CLUB, -1, _, vecHit);
							else
								SDKHooks_TakeDamage(target, npc.index, npc.index, 500.0, DMG_CLUB, -1, _, vecHit);	
								
							//Hit sound
							npc.PlayMeleeHitSound();	
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.8;
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
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action BootyExecutioner_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BootyExecutioner_NPCDeath(int entity)
{
	BootyExecutioner npc = view_as<BootyExecutioner>(entity);
	npc.PlayDeathSound();	
	if(!b_IsAlliedNpc[npc.index])
	{
		Music_Stop_Main_Theme(entity);
		Music_Stop_Death_Theme(entity);
		ExecuteCustomPootisTheme = GetGameTime() + 0.01;
		OnePootisDied = true;
		DisableMainPootisTheme = true;
		MainLeaderDied = true;
	}
	if(OnePootisDied && MainLeaderDied && SandSlayerDied)
	{
		EmitSoundToAll(POOTISOUTROMUSIC);
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, BootyExecutioner_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, BootyExecutioner_ClotThink);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
//Using my old method Stopping all sounds. cspy had it but never came anyway so i reuse it
void Music_Stop_Main_Theme(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#freak_fortress_2/pootis_engage/bgm1.mp3");
}

void Music_Stop_Death_Theme(int entity)
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

void Music_Stop_Beat_Ten(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "#zombiesurvival/beats/defaultzombiev2/10.mp3");
}