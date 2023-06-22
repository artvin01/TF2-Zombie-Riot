#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"fish/lose_vader.mp3",
};

static const char g_HurtSounds[][] = {
	"fish/darthvader_fullbreath_new.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"fish/no_vader.mp3",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/superphys_launch1.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static const char g_Music[][] = {
	"fish/starwarsbgm.mp3",
};

static const char g_AngerSound[][] = {
	"fish/no_vader_2.mp3",
};

static const char g_Jump[][] = {
	"freak_fortress_2/dark_vader/saber1_01.mp3",
};

static const char g_WinSound[][] = {
	"fish/darthvader_yourfather.mp3",
};

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];
static float fl_PlayMusicSound[MAXENTITIES];

public void Vader_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	for (int i = 0; i < (sizeof(g_Music));   i++) { PrecacheSound(g_Music[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSound));   i++) { PrecacheSound(g_AngerSound[i]);   }
	for (int i = 0; i < (sizeof(g_Jump));   i++) { PrecacheSound(g_Jump[i]);   }
	for (int i = 0; i < (sizeof(g_WinSound));   i++) { PrecacheSound(g_WinSound[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	PrecacheSound("fish/starwarsbgm.mp3");
	PrecacheSound("fish/destroy_vader.mp3");
	
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/effects/combineball.mdl", true);
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

methodmap Vader < CClotBody
{
	property float m_flPlayMusicSound
	{
		public get()							{ return fl_PlayMusicSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_PlayMusicSound[this.index] = TempValueForProperty; }
	}
	
	public void PlayMusicSound() {
		if(this.m_flPlayMusicSound > GetEngineTime())
			return;
		EmitSoundToAll(g_Music[GetRandomInt(0, sizeof(g_Music) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_Music[GetRandomInt(0, sizeof(g_Music) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flPlayMusicSound = GetEngineTime() + 146.0;
		
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public void PlayAngerSound() {
		EmitSoundToAll(g_AngerSound[GetRandomInt(0, sizeof(g_AngerSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAngerSound()");
		#endif
	}
	
	public void PlayJump() {
		EmitSoundToAll(g_Jump[GetRandomInt(0, sizeof(g_Jump) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayAngerSound()");
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
	
	public Vader(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Vader npc = view_as<Vader>(CClotBody(vecPos, vecAng, "models/freak_fortress_2/dark_vader/vader_but_cool_final_4.mdl", "1.0", "50000", ally, false, true, true ,true));
		
		i_NpcInternalId[npc.index] = VADER;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		EmitSoundToAll("fish/destroy_vader.mp3", _, _, _, _, 1.0);	
		EmitSoundToAll("fish/destroy_vader.mp3", _, _, _, _, 1.0);	
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidModeTime = GetGameTime() + 200.0;
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		npc.m_bThisNpcIsABoss = true;
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.20; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.40;
		}
		Raidboss_Clean_Everyone();
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;		
		
		npc.m_flPlayMusicSound = 0.0;
		
		
		SDKHook(npc.index, SDKHook_Think, Vader_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, Vader_ClotDamaged_Post);

		npc.m_iState = 0;
		npc.m_flSpeed = 340.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.Anger = false;

		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 255, 255, 255, 255);
		
		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/freak_fortress_2/dark_vader/saber_3.mdl");
		SetVariantString("1.75");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("anim_attachment_head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_invasion_codex", npc.index, "anim_attachment_head", {0.0,0.0,15.0})
		
		npc.PlayMusicSound();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Vader_ClotThink(int iNPC)
{
	Vader npc = view_as<Vader>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
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
		SDKUnhook(npc.index, SDKHook_Think, Vader_ClotThink);
		npc.PlayWinSound();
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime()) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.10;

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
					Vader_Stop_All_Beat(client); //This is actually more expensive then i thought.
				}
				SetMusicTimer(client, GetTime() + 5);
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
		/* if(npc.m_flJumpCooldown < GetGameTime() && npc.m_flInJump < GetGameTime() && flDistanceToTarget > 10000 && flDistanceToTarget < 1000000)
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See) && Enemy_I_See == PrimaryThreatIndex)
			{
				npc.m_flInJump = GetGameTime() + 0.65;
				npc.m_flJumpCooldown = GetGameTime() + 0.5;
			}
		}
		if(npc.m_flJumpCooldown < GetGameTime() && npc.m_flInJump > GetGameTime())
		{
			PluginBot_Jump(npc.index, vecTarget);
			npc.PlayJump();
			npc.m_flJumpCooldown = GetGameTime() + 5.0;
			
		}
		if(npc.m_flInJump > GetGameTime())
		{
			npc.FaceTowards(vecTarget, 1000.0);
			return;
		}*/
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
	
			if(npc.m_flNextRangedSpecialAttack < GetGameTime() && flDistanceToTarget < 62500 || npc.m_fbRangedSpecialOn)
			{
				
				if(!npc.m_fbRangedSpecialOn)
				{
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.m_flRangedSpecialDelay = GetGameTime() + 0.4;
					npc.m_fbRangedSpecialOn = true;
					npc.m_flReloadDelay = GetGameTime() + 1.0;
				}
				if(npc.m_flRangedSpecialDelay < GetGameTime())
				{
					npc.m_fbRangedSpecialOn = false;
					npc.m_flNextRangedSpecialAttack = GetGameTime() + 7.0;
					npc.PlayRangedAttackSecondarySound();
		
					float vecSpread = 0.1;
					
					npc.FaceTowards(vecTarget, 20000.0);
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
					
					float x, y;
					x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
					y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
					
					vecTarget[2] += 15.0;
					MakeVectorFromPoints(WorldSpaceCenter(npc.index), vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					//add the spray
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_RH"), PATTACH_POINT_FOLLOW, true);
					
					if(EscapeModeForNpc)
					{
						FireBullet(npc.index, npc.index, WorldSpaceCenter(npc.index), vecDir, 50.0, 550.0, DMG_BULLET, "bullet_tracer02_blue");
					}
					else
					{
						FireBullet(npc.index, npc.index, WorldSpaceCenter(npc.index), vecDir, 35.0 * RaidModeScaling, 550.0, DMG_BULLET, "bullet_tracer02_blue");
					}
				}
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < 40000 && npc.m_flReloadDelay < GetGameTime() || npc.m_flAttackHappenswillhappen)
			{
				NPC_StartPathing(npc.index);
				npc.m_bPathing = true;
				if(npc.m_flNextMeleeAttack < GetGameTime())
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime() + 2.0;
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime()+0.30;
						npc.m_flAttackHappens_bullshit = GetGameTime()+0.54;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex,{ 228.0, 228.0, 228.0 }, { -228.0, -228.0, -228.0 }))
						{
							int target = TR_GetEntityIndex(swingTrace);	
								
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
								
							if(target > 0) 
							{
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 10.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 60.0 * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
									
								Custom_Knockback(npc.index, target, 250.0);
									
								// Hit particle
								//npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
									
								// Hit sound
								npc.PlayMeleeHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
					}
				}
			}
			if (npc.m_flReloadDelay < GetGameTime())
			{
				NPC_StartPathing(npc.index);
				npc.m_bPathing = true;
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

public Action Vader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Vader npc = view_as<Vader>(victim);
		
	if(npc.m_fbRangedSpecialOn)
		damage *= 0.75;
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public Action Set_Vader_HP(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", (GetEntProp(entity, Prop_Data, "m_iMaxHealth") / 2));
	}
	return Plugin_Stop;
}

public void Vader_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Vader npc = view_as<Vader>(victim);
	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 2 )>= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(;
		CreateTimer(10.0, RageModeEnd_Timer, EntIndexToEntRef(npc.index), TIMER_FLAG_NO_MAPCHANGE);
		npc.PlayAngerSound();
		npc.m_flHalf_Life_Regen = false;
		npc.m_flSpeed = 410.0;
		for(int client = 1; client <= MaxClients; client++)
		{
			if (IsValidClient(client))
			{
				TF2_StunPlayer(client, 3.5, _, TF_STUNFLAGS_GHOSTSCARE, 0);
			}
		}
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
	}
}

public Action RageModeEnd_Timer(Handle timer, int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(entity>MaxClients && IsValidEntity(entity))
	{
	Vader npc = view_as<Vader>(entity);
	npc.m_flSpeed = 340.0;
	}
	return Plugin_Handled;
}

public void Vader_NPCDeath(int entity)
{
	Vader npc = view_as<Vader>(entity);
	
	npc.PlayDeathSound();
	
	
	SDKUnhook(npc.index, SDKHook_Think, Vader_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Vader_ClotDamaged_Post);
	RaidBossActive = INVALID_ENT_REFERENCE;
	Music_Stop_All_Vader(entity);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	
}

void Music_Stop_All_Vader(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
	StopSound(entity, SNDCHAN_AUTO, "fish/starwarsbgm.mp3");
}

void Vader_Stop_All_Beat(int entity)
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