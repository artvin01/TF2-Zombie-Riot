#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_lose.mp3",
};

static const char g_HurtSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_1.mp3",
	"freak_fortress_2/corruptedspy/glitch_2.mp3",
	"freak_fortress_2/corruptedspy/glitch_3.mp3",
	"freak_fortress_2/corruptedspy/glitch_4.mp3",
};

static const char g_IdleSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_8.mp3",
	"freak_fortress_2/corruptedspy/glitch_9.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_1.mp3",
	"freak_fortress_2/corruptedspy/glitch_3.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/knife_swing.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"freak_fortress_2/corruptedspy/glitch_7.mp3",
	"freak_fortress_2/corruptedspy/glitch_6.mp3",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_RangedAttackSounds[][] = {
	"player/taunt_tank_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"player/taunt_tank_end.wav",
};

static const char g_decloak[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_overchargebomb.mp3",
};

static const char g_CloakSounds[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_overchargewarning.mp3",
};

static const char g_AngerSounds[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_rage1.mp3",
};
static const char g_TeleportSound[][] = {
	"freak_fortress_2/corruptedspy/sound/tele3.mp3", //sound barely hearable needs to be made louder
};
static const char g_WinSound[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_kill3.mp3",
};
static const char g_Stabbed[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_stabbed1.mp3",
};
static const char g_Music[][] = {
	"freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3",
};
//int g_iPathLaserModelIndex = -1;

public void CorruptedSpyRaid_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_CloakSounds));   i++) { PrecacheSound(g_CloakSounds[i]);   }
	for (int i = 0; i < (sizeof(g_decloak));   i++) { PrecacheSound(g_decloak[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSound));   i++) { PrecacheSound(g_TeleportSound[i]);   }
	for (int i = 0; i < (sizeof(g_WinSound));   i++) { PrecacheSound(g_WinSound[i]);   }
	for (int i = 0; i < (sizeof(g_Stabbed));   i++) { PrecacheSound(g_Stabbed[i]);   }
	for (int i = 0; i < (sizeof(g_Music));   i++) { PrecacheSound(g_Music[i]);   }
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	PrecacheModel("models/freak_fortress_2/corruptedspy/corruptedspy_animated_funny_1.mdl");
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("freak_fortress_2/corruptedspy/sound/rage1r.mp3");
	PrecacheSound("freak_fortress_2/corruptedspy/corrupted_stabbed1.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/1.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/2.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/3.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/4.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/5.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/6.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/7.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/8.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/9.mp3");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/10.mp3");
}

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_PlayMusicSound[MAXENTITIES];

methodmap CorruptedSpyRaid < CClotBody
{
	property float m_flPlayMusicSound
	{
		public get()							{ return fl_PlayMusicSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_PlayMusicSound[this.index] = TempValueForProperty; }
	}
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayCloakSound() {
	
		EmitSoundToAll(g_CloakSounds[GetRandomInt(0, sizeof(g_CloakSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_CloakSounds[GetRandomInt(0, sizeof(g_CloakSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayCloakSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayAngerSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public void PlayDecloakSound() {
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_decloak[GetRandomInt(0, sizeof(g_decloak) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_TeleportSound[GetRandomInt(0, sizeof(g_TeleportSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayTeleportSound()");
		#endif
	}
	
	public void PlayWinSound() {
		EmitSoundToAll(g_WinSound[GetRandomInt(0, sizeof(g_WinSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_WinSound[GetRandomInt(0, sizeof(g_WinSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_WinSound[GetRandomInt(0, sizeof(g_WinSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_WinSound[GetRandomInt(0, sizeof(g_WinSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayWinSound()");
		#endif
	}
	public void PlayStabSound() {
		EmitSoundToAll(g_Stabbed[GetRandomInt(0, sizeof(g_Stabbed) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_Stabbed[GetRandomInt(0, sizeof(g_Stabbed) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_Stabbed[GetRandomInt(0, sizeof(g_Stabbed) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_Stabbed[GetRandomInt(0, sizeof(g_Stabbed) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayStabSound()");
		#endif
	}
	
	public void PlayMusicSound() {
		if(this.m_flPlayMusicSound > GetEngineTime())
			return;
		EmitSoundToAll(g_Music[GetRandomInt(0, sizeof(g_Music) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 83);
		EmitSoundToAll(g_Music[GetRandomInt(0, sizeof(g_Music) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 83);
		EmitSoundToAll(g_Music[GetRandomInt(0, sizeof(g_Music) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 83);
		this.m_flPlayMusicSound = GetEngineTime() + 210.0;
	}

	public CorruptedSpyRaid(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(CClotBody(vecPos, vecAng, "models/freak_fortress_2/corruptedspy/corruptedspy_animated_funny_1.mdl", "1.35", "500000", ally, false, true, true, true));
		
		i_NpcInternalId[npc.index] = CORRUPTEDSPYRAID;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, CorruptedSpyRaid_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, CorruptedSpyRaid_ClotDamaged_Post);
		
		npc.m_iAttacksTillReload = 6;
		npc.m_bThisNpcIsABoss = true;
		npc.m_flPlayMusicSound = 0.0;
		
		RaidModeTime = GetGameTime() + 200.0;
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.34;
		}
		Raidboss_Clean_Everyone();
		
		npc.m_fbGunout = false;
		npc.m_bmovedelay_gun = false;
		npc.m_bmovedelay = false;
		npc.g_TimesSummoned = 0;
		
		GiveNpcOutLineLastOrBoss(npc.index, false);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		npc.Anger = false;
		npc.m_iState = 0;
		npc.m_flSpeed = 330.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_flHalf_Life_Regen = false;

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_knife/c_knife.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_knife/c_knife.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
		
		AcceptEntityInput(npc.m_iWearable2, "Disable");
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		npc.PlayMusicSound();
		return npc;
	}
}

//TODO 
//Rewrite
public void CorruptedSpyRaid_ClotThink(int iNPC)
{
	CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		Music_Stop_All_Cspy(entity);
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, CorruptedSpyRaid_ClotThink);
		npc.PlayWinSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		//float targPos[3];
		float chargerPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", chargerPos);
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Cspy_Stop_All_Beat(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int closest = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, closest, true))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest, 0.3);
		
		if(npc.m_flDead_Ringer_Invis < GetGameTime() && npc.m_flDead_Ringer_Invis_bool)
		{
			npc.m_flDead_Ringer_Invis_bool = false;
			
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			
			SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
			SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
			
			GiveNpcOutLineLastOrBoss(npc.index, true);
		
			int entity = EntRefToEntIndex(iNPC);
			if(IsValidEntity(entity) && entity>MaxClients)
			{
				if(closest > 0) 
				{
					if(closest <= MaxClients)
						SDKHooks_TakeDamage(closest, npc.index, npc.index, 5.0 * RaidModeScaling, DMG_CLUB, -1, _);
					else
						SDKHooks_TakeDamage(closest, npc.index, npc.index, 7.0 * RaidModeScaling, DMG_CLUB, -1, _);
					float pos[3];
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
					makeexplosion(-1, -1, pos, "", 0, 450);
					//makeexplosion(-1, -1, pos, "", RoundToCeil(3.25 * RaidModeScaling), 450); // had to be 3.25 unless you want him to selfdmg him to hell
					npc.DispatchParticleEffect(npc.index, "skull_island_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
				} 
			}
			npc.m_flNextRangedAttack = 0.7;
			npc.m_flNextMeleeAttack = 0.11;
			
			npc.PlayDecloakSound();
			npc.PlayDecloakSound();
		}
		if (npc.m_flReloadDelay < GetGameTime() && flDistanceToTarget < 40000 || flDistanceToTarget > 90000 && npc.m_fbGunout == true && npc.m_flReloadDelay < GetGameTime())
		{
			if (!npc.m_bmovedelay)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay = true;
			}
			npc.StartPathing();
		}
		else if (npc.m_flReloadDelay < GetGameTime() && flDistanceToTarget > 40000 && flDistanceToTarget < 90000)
		{
			if (!npc.m_bmovedelay_gun)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				npc.m_bmovedelay_gun = true;
				
				//if(!npc.Anger)
				//	npc.m_flSpeed = 330.0;	
				npc.m_bmovedelay = false;
			}
			npc.StartPathing();
		}
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{	
			NPC_SetGoalVector(npc.index, vPredictedPos);
		} else {
			NPC_SetGoalEntity(npc.index, closest);
		}
		if(npc.m_flNextRangedAttack < GetGameTime() && flDistanceToTarget > 40000 && flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime() && !npc.Anger)
		{
			float vecSpread = 0.1;
			
			npc.FaceTowards(vecTarget, 20000.0);
			
			float eyePitch[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
			
			float x, y;
			x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
			y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
			
			float vecDirShooting[3], vecRight[3], vecUp[3];
			
			vecTarget[2] += 15.0;
			MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
			GetVectorAngles(vecDirShooting, vecDirShooting);
			vecDirShooting[1] = eyePitch[1];
			GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
			
			float m_vecSrc[3];
			
			m_vecSrc = WorldSpaceCenter(npc.index);
			
			float vecEnd[3];
			vecEnd[0] = m_vecSrc[0] + vecDirShooting[0] * 9000; 
			vecEnd[1] = m_vecSrc[1] + vecDirShooting[1] * 9000;
			vecEnd[2] = m_vecSrc[2] + vecDirShooting[2] * 9000;
			
			float vecbro[3];
			vecbro[0] = vecDirShooting[0] + 0.0 * vecSpread * vecRight[0] + 0.0 * vecSpread * vecUp[0]; 
			vecbro[1] = vecDirShooting[1] + 0.0 * vecSpread * vecRight[1] + 0.0 * vecSpread * vecUp[1]; 
			vecbro[2] = vecDirShooting[2] + 0.0 * vecSpread * vecRight[2] + 0.0 * vecSpread * vecUp[2];  //add the spray
			NormalizeVector(vecbro, vecbro);
			
			npc.m_bmovedelay = false;
			
			npc.m_flNextRangedAttack = GetGameTime() + 0.7;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
				npc.m_flReloadDelay = GetGameTime() + 1.4;
				npc.m_iAttacksTillReload = 6;
				npc.PlayRangedReloadSound();
			}
			
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
			float vecDir[3];
			vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
			vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
			vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
			NormalizeVector(vecDir, vecDir);
			
			npc.FireRocket(vecTarget, 05.0 * RaidModeScaling, 900.0, _, 1.0);
			
			npc.PlayRangedSound();
		}
		else if(npc.m_flNextRangedAttack < GetGameTime() && flDistanceToTarget > 40000 && flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime() && npc.Anger)
		{		
			npc.FaceTowards(vecTarget, 20000.0);
			
			npc.m_flNextRangedAttack = GetGameTime() + 0.3;
			npc.m_iAttacksTillReload -= 1;
			
			if (npc.m_iAttacksTillReload == 0)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
				npc.m_flReloadDelay = GetGameTime() + 1.4;
				npc.m_iAttacksTillReload = 6;
				npc.PlayRangedReloadSound();
			}
			
			npc.FireRocket(vecTarget, 05.0 * RaidModeScaling, 900.0, _, 1.0);
			npc.PlayRangedSound();
		}
		if(flDistanceToTarget < 90000 && npc.m_flReloadDelay < GetGameTime() || flDistanceToTarget > 90000 && npc.m_flReloadDelay < GetGameTime() )
		{
			npc.StartPathing();
			
			npc.m_fbGunout = false;
			
			if(npc.m_flNextMeleeAttack < GetGameTime() && flDistanceToTarget < 40000)
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime()+0.1;
					npc.m_flAttackHappens_bullshit = GetGameTime()+0.21;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
				{
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 20000.0);
					if(npc.DoSwingTrace(swingTrace, closest, { 100.0, 100.0, 100.0 }, { -100.0, -100.0, -100.0 })) 
					{
						int target = TR_GetEntityIndex(swingTrace);	
						
						float vecHit[3];
						TR_GetEndPosition(vecHit, swingTrace);
						
						if(target > 0) 
						{
							if(!npc.Anger)
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 8.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 20.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);	
							}
							else if(npc.Anger)
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 10.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 30.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);	
							}
							if(npc.m_iAttacksTillMegahit >= 3)
							{
								Custom_Knockback(npc.index, target, 200.0);
								
								SDKHooks_TakeDamage(target, npc.index, npc.index, 10.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								
								npc.m_iAttacksTillMegahit = 0;
								
							}
							npc.m_iAttacksTillMegahit += 1;
							//npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR); // Hit particle
							npc.PlayMeleeHitSound(); //Hit sound
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime() + 0.11;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime() + 0.21;
				}
			}
		}
	}
	if(npc.m_flNextTeleport < GetGameTime())
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest, 0.3);
		static float flVel[3];
		GetEntPropVector(closest, Prop_Data, "m_vecVelocity", flVel);
		if (!npc.Anger)
		{
			if (flVel[0] >= 190.0)
			{
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				npc.m_flNextTeleport = GetGameTime() + 6.0;
				float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
				
				if(Tele_Check > 120)
				{
					TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
					npc.PlayTeleportSound();
				}
			}
		}
		else if (npc.Anger)
		{
			if (flVel[0] >= 170.0)
			{
				npc.FaceTowards(vecTarget);
				npc.FaceTowards(vecTarget);
				npc.m_flNextTeleport = GetGameTime() + 5.0;
				float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
				if(Tele_Check > 120)
				{
					TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
					npc.PlayTeleportSound();
				}
			}
		}
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}


public Action CorruptedSpyRaid_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(victim);
	
	if(npc.m_flDead_Ringer < GetGameTime())
	{
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
		
		npc.m_flDead_Ringer_Invis = GetGameTime() + 4.0;
		npc.m_flDead_Ringer = GetGameTime() + 35.0;
		npc.m_flDead_Ringer_Invis_bool = true;
		
		npc.m_flNextRangedAttack = 4.05;
		npc.m_flNextMeleeAttack = GetGameTime() + 4.05;
		
		GiveNpcOutLineLastOrBoss(npc.index, false);
		
		npc.PlayCloakSound();
		npc.PlayCloakSound();
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client))
			{
			SetHudTextParams(-1.0, 0.20, 3.01, 34, 139, 34, 255);
			SetGlobalTransTarget(client);
			ShowSyncHudText(client, SyncHud_Notifaction, "Overcloak Explosion Incoming!");
			}
		}
	}
	
	if(!npc.m_flDead_Ringer_Invis_bool)
	{
		if (npc.m_flHeadshotCooldown < GetGameTime())
		{
			npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
			npc.m_blPlayHurtAnimation = true;
		}
	}
	else
	{
		damage *= 0.1;
	}
	if(npc.Anger)
	{
		damage *= 0.6;
	}
	
	return Plugin_Changed;
}

public void CorruptedSpyRaid_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(victim);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		int skin = 3;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		CreateTimer(15.0, RageMode_Timer, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.5, Overlay_End_Timer, TIMER_FLAG_NO_MAPCHANGE);
		npc.PlayAngerSound();
		
		npc.m_flHalf_Life_Regen = false;
		npc.m_flSpeed = 410.0;
		npc.m_flAttackHappens = GetGameTime()+0.00;
		npc.m_flAttackHappens_bullshit = GetGameTime()+0.00;
		npc.m_flNextMeleeAttack = GetGameTime() + 0.00;
		npc.m_flHalf_Life_Regen = false;
		npc.m_flDead_Ringer = GetGameTime() + 99999.0;
		npc.m_flDead_Ringer_Invis_bool = false;
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client))
			{
				ClientCommand(client, "r_screenoverlay freak_fortress_2/corruptedspy/corruptedspy_rageoverlay1");
				SetVariantString("HalloweenLongFall");
				AcceptEntityInput(client, "SpeakResponseConcept");
			}
		}
	}
	
	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.3) > ratio)
	{
		npc.g_TimesSummoned++;
		maxhealth /= 13;
		for(int i; i<1; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index = Npc_Create(CORRUPTEDSPYMINION, -1, pos, ang, GetEntProp(npc.index, Prop_Send, "m_iTeamNum") == 2);
			if(spawn_index > MaxClients)
			{
				Zombies_Currently_Still_Ongoing += 1;
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
			}
		}
	}
}

public Action RageMode_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
	CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(entity);
	npc.m_flAttackHappens = GetGameTime()+0.11;
	npc.m_flSpeed = 330.0;
	npc.m_flAttackHappens_bullshit = GetGameTime()+0.01;
	npc.m_flNextMeleeAttack = GetGameTime() + 0.11;
	npc.m_flDead_Ringer = GetGameTime() + 34.0;
	npc.m_flDead_Ringer_Invis_bool = true;
	npc.m_flNextTeleport = GetGameTime() + 6.0;
	}
	return Plugin_Handled;
}

public Action Overlay_End_Timer(Handle timer, int ref)
{
	for(int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client))
			{
				ClientCommand(client, "r_screenoverlay off");
			}
		}
	return Plugin_Handled;
}

public Action Set_CorruptedSpyRaid_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void CorruptedSpyRaid_NPCDeath(int entity)
{
	CorruptedSpyRaid npc = view_as<CorruptedSpyRaid>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Music_Stop_All_Cspy(entity);
	
	
	SDKUnhook(npc.index, SDKHook_Think, CorruptedSpyRaid_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, CorruptedSpyRaid_ClotDamaged_Post);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}

void Music_Stop_All_Cspy(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "freak_fortress_2/corruptedspy/corruptedspy_bgm1.mp3");
}
void Cspy_Stop_All_Beat(int entity) //Originally from me to disable this so the music from cspy plays
{
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/1.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/2.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/3.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/4.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/5.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/6.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/7.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/8.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/9.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/helblinde.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/ephemerality.mp3");
}