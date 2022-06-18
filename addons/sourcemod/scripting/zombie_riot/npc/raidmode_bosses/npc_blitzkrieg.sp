static char g_DeathSounds[][] = {
	"mvm/mvm_robo_stun.wav",
	"mvm/mvm_bomb_explode.wav",
};

static char g_HurtSounds[][] = {
	"vo/medic_item_secop_domination01.mp3",
	"vo/medic_item_secop_idle03.mp3",
	"vo/medic_item_secop_idle01.mp3",
	"vo/medic_item_secop_idle02.mp3",
};

static char g_IdleSounds[][] = {
	"vo/medic_specialcompleted11.mp3",
	"vo/medic_specialcompleted12.mp3",
	"vo/medic_specialcompleted08.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/medic_hat_taunts01.mp3",
	"vo/medic_hat_taunts04.mp3",
	"vo/medic_item_secop_round_start05.mp3",
	"vo/medic_item_secop_round_start07.mp3",
	"vo/medic_item_secop_kill_assist01.mp3",
};

static char g_MeleeHitSounds[][] = {
	"vo/medic_laughshort01.mp3",
	"vo/medic_laughshort02.mp3",
	"vo/medic_laughshort03.mp3",
};

static char g_MeleeAttackSounds[][] = {
	"weapons/airstrike_fire_01.wav",
	"weapons/airstrike_fire_02.wav",
	"weapons/airstrike_fire_03.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/airstrike_fire_crit.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};

static char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	"vo/medic_sf13_influx_big02.mp3",
	"vo/medic_sf13_influx_big03.mp3",
	"vo/medic_weapon_taunts03.mp3",
};
static const char g_IdleMusic[][] = {
	"#ui/gamestartup12.mp3",
};

static char gGlow1;
static char gExplosive1;
static char gLaser1;

static int i_AmountProjectiles[MAXENTITIES];
static int i_NpcCurrentLives[MAXENTITIES];
static float i_HealthScale[MAXENTITIES];
static float i_RangeScale[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];

public void Blitzkrieg_OnMapStart()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);      		}
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);       		}
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);       		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);   		}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]); 			}
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}		
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   				}
	for (int i = 0; i < (sizeof(g_IdleMusic));   i++) { PrecacheSound(g_IdleMusic[i]);   }
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/freak_fortress_2/shadow93/dmedic/d_medic2.mdl");
	
	PrecacheSound("ui/gamestartup12.mp3");
	
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("zombiesurvival/beats/defaultzombiev2/10.mp3");
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	
}

static float fl_PlayMusicSound[MAXENTITIES];

methodmap Blitzkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flPlayMusicSound
	{
		public get()							{ return fl_PlayMusicSound[this.index]; }
		public set(float TempValueForProperty) 	{ fl_PlayMusicSound[this.index] = TempValueForProperty; }
	}
		public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	public void PlayMusicSound() {
		if(this.m_flPlayMusicSound > GetEngineTime())
			return;
		
		EmitSoundToAll(g_IdleMusic[GetRandomInt(0, sizeof(g_IdleMusic) - 1)], this.index, SNDCHAN_AUTO, 180, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_IdleMusic[GetRandomInt(0, sizeof(g_IdleMusic) - 1)], this.index, SNDCHAN_AUTO, 180, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_IdleMusic[GetRandomInt(0, sizeof(g_IdleMusic) - 1)], this.index, SNDCHAN_AUTO, 180, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_IdleMusic[GetRandomInt(0, sizeof(g_IdleMusic) - 1)], this.index, SNDCHAN_AUTO, 180, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flPlayMusicSound = GetEngineTime() + 233.0;
		
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(BOSS_ZOMBIE_SOUNDLEVEL, 100));
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.5);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public Blitzkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Blitzkrieg npc = view_as<Blitzkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.4", "25000", ally, false, true, true, true)); //giant!
		
		i_NpcInternalId[npc.index] = RAIDMODE_BLITZKRIEG;
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flPlayMusicSound = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime() + 200.0;
		
		i_NpcCurrentLives[npc.index] = 0;
		
		i_HealthScale[npc.index] = 0.5;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
		i_RangeScale[npc.index] = 1.0;
		
		if(ZR_GetWaveCount()>30)
		{
			i_RangeScale[npc.index] = 0.75;
		}
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.17; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.34;
		}
		Raidboss_Clean_Everyone();
		
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime() + 15.0
		
		SDKHook(npc.index, SDKHook_Think, Blitzkrieg_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamage, Blitzkrieg_ClotDamaged);
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/w_models/w_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Spacemans_Suit/Hw2013_Spacemans_Suit.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/Cardiologists_Camo/Cardiologists_Camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 55, 30, 30, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 255, 0, 0, 255);
		
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 125, 100, 100, 255);
		
		
		//IDLE
		npc.m_flSpeed = 270.0;
		
		npc.PlayMusicSound();
		Music_Stop_All_Beat(client);
		return npc;
	}
}

//TODO 
//Rewrite
public void Blitzkrieg_ClotThink(int iNPC)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(iNPC);
	
	//SetVariantInt(1);
    //AcceptEntityInput(npc.index, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime() + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime()) {
		return;
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		Music_Stop_All_Blitzkrieg(entity);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, Blitzkrieg_ClotThink);
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		for(int client=1; client<=MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
				{
					Music_Stop_All(client); //This is actually more expensive then i thought.
				}
				Music_Timer[client] = GetEngineTime() + 5.0;
				fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
			}
		}
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	
	int closest = npc.m_iTarget;
	int PrimaryThreatIndex = npc.m_iTarget;
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				/*
				int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);
				*/
				
				
				
				PF_SetGoalVector(npc.index, vPredictedPos);
			} else {
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime() && npc.m_flNextRangedBarrage_Singular < GetGameTime() && flDistanceToTarget > Pow(110.0, 2.0) && flDistanceToTarget < Pow(500.0, 2.0))
			{	
					EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
			  	    npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.FireRocket(vPredictedPos, 7.5 * RaidModeScaling / i_HealthScale[npc.index], 300.0/(0.25+i_HealthScale[npc.index]), "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl", 1.0);
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					npc.m_flNextRangedBarrage_Singular = GetGameTime() + 0.15 * i_HealthScale[npc.index];
					if (npc.m_iAmountProjectiles >= 10.0 / (i_HealthScale[npc.index]+0.5))
					{
					npc.m_iAmountProjectiles = 0;
					npc.m_flNextRangedBarrage_Spam = GetGameTime() + 45.0 * i_HealthScale[npc.index];
						if(i_NpcCurrentLives[npc.index]==3)
						{
						Blitzkrieg_IOC_Invoke(npc.index, closest);
						}
					}
			}
			if(npc.m_flNextTeleport < GetGameTime() && flDistanceToTarget > Pow(125.0, 2.0) && flDistanceToTarget < Pow(500.0, 2.0))
			{
				static float flVel[3];
				GetEntPropVector(closest, Prop_Data, "m_vecVelocity", flVel);

				if (flVel[0] >= 190.0)
				{
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.m_flNextTeleport = GetGameTime() + 30.0;
					float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
					
					if(Tele_Check > 120.0)
					{
						TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
						npc.PlayTeleportSound();
					}
				}
			}
			if(npc.m_flReloadIn && npc.m_flReloadIn<GetGameTime())
			{
				//Play attack anim
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
				npc.m_flReloadIn = 0.0;
			}
			if(flDistanceToTarget < 100000/i_RangeScale[npc.index])
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					//Look at target so we hit.
					npc.FaceTowards(vecTarget, 1500.0);
					
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime())
					{
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						
						npc.PlayMeleeSound();
						npc.FireRocket(vecTarget, 26.0, 500.0/(0.25+i_HealthScale[npc.index]), "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl", 1.0, EP_NO_KNOCKBACK);
						npc.m_flNextMeleeAttack = GetGameTime() + 0.25 * i_HealthScale[npc.index];
						npc.m_flReloadIn = GetGameTime() + 0.25 * i_HealthScale[npc.index];
					}
					if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								
								if(target <= MaxClients)
									SDKHooks_TakeDamage(target, npc.index, npc.index, 7.5 * RaidModeScaling / i_HealthScale[npc.index], DMG_SLASH|DMG_CLUB);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 10.0 * RaidModeScaling / i_HealthScale[npc.index], DMG_SLASH|DMG_CLUB);
								
								npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.25 * i_HealthScale[npc.index];
						npc.m_flAttackHappenswillhappen = false;
					}
					if(ZR_GetWaveCount()<=15)
					{
					PF_StopPathing(npc.index);
					npc.m_bPathing = false;
					}
				}
				else
				{
					npc.StartPathing();
					
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
	npc.PlayIdleAlertSound()
}

public Action Blitzkrieg_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.	AJA
	if(attacker <= 0)
		return Plugin_Continue;
		
	Blitzkrieg npc = view_as<Blitzkrieg>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	int closest = npc.m_iTarget;
	
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
    float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	
	
	if(Health/MaxHealth>0.5 && Health/MaxHealth<0.75 && i_NpcCurrentLives[npc.index] == 0)	//Lifelosses
	{	//75%-50%
		i_NpcCurrentLives[npc.index]=1;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		if(ZR_GetWaveCount()>=60)
		{
			i_RangeScale[npc.index] = 0.5;
		}
		if(ZR_GetWaveCount()==30)
		{
			i_RangeScale[npc.index] = 0.75;
		}
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_liberty_launcher/c_liberty_launcher.mdl");	//Liberty
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_HealthScale[npc.index]=0.4;
		
		npc.m_flSpeed = 280.0;
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(npc.index, closest);
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: This is only just the beggining {yellow}%N {default}!", closest);
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: You think this is the end {yellow}%N {default}?", closest);
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: You fool {yellow}%N {default}!", closest);
			}
		}
			
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");	
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else if(Health/MaxHealth>0.25 && Health/MaxHealth<0.5 && i_NpcCurrentLives[npc.index] == 1)
	{	//50%-25%
		i_NpcCurrentLives[npc.index]=2;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		if(ZR_GetWaveCount()>=60)
		{
			i_RangeScale[npc.index] = 0.25;
		}
		if(ZR_GetWaveCount()==30)
		{
			i_RangeScale[npc.index] = 0.5;
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");	//Dumpster deive aka beggars
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		i_HealthScale[npc.index]=0.25;
		
		npc.m_flSpeed = 290.0;
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(npc.index, closest);
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Don't get too cocky {yellow}%N {default}!", closest);
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: The end is near {yellow}%N {default} are you sure you want to proceed?", closest);
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: You Imbecil {yellow}%N {default}!", closest);
			}
		}
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");
					
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	else if(Health/MaxHealth>0 && Health/MaxHealth<0.25&& i_NpcCurrentLives[npc.index] == 2)
	{	//25%-ded
		i_NpcCurrentLives[npc.index]=3;
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		
		if(ZR_GetWaveCount()>=60)
		{
			i_RangeScale[npc.index] = 0.01;
		}
		if(ZR_GetWaveCount()==30)
		{
			i_RangeScale[npc.index] = 0.1;
		}
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_atom_launcher/c_atom_launcher.mdl");	//The thing everyone fears, the airstrike.
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		EmitSoundToAll("mvm/mvm_tank_end.wav");
		
		npc.m_flSpeed = 300.0;
		
		CPrintToChatAll("{crimson}Blitzkrieg{default}: {yellow}Life: %i!",i_NpcCurrentLives[npc.index]);
		
		switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Your own foolishness lead you to this {yellow}%N {default} prepare for complete {red} BLITZKRIEG", closest);
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: The end is {red} here {yellow}%N {default} time for you to learn what {red} BLITZKRIEG {default} means", closest);
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: You've gone and done it {red} ITS TIME TO DIE {yellow}%N {red} PREPARE FOR FULL BLITZKRIEG", closest);
			}
		}
		
		i_HealthScale[npc.index]=0.175;
		
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		Blitzkrieg_IOC_Invoke(npc.index, closest);
					
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
	}
	
	return Plugin_Changed;
}

public void Blitzkrieg_NPCDeath(int entity)
{
	Blitzkrieg npc = view_as<Blitzkrieg>(entity);
	npc.PlayDeathSound();
	Music_Stop_All_Blitzkrieg(entity);
	SDKUnhook(npc.index, SDKHook_Think, Blitzkrieg_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Blitzkrieg_ClotDamaged);
	Music_RoundEnd(entity);
	
	int closest = npc.m_iTarget;
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
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
		
	switch(GetRandomInt(1, 3))
		{
			case 1:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Noooo, this cannot be {yellow}%N {default} you won, {red}this time", closest);
			}
			case 2:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: It seems I have failed {yellow}%N {default} you were far supperior than me {red}this time", closest);
			}
			case 3:
			{
				CPrintToChatAll("{crimson}Blitzkrieg{default}: Until next time {yellow}%N {red} until next time...", closest);
			}
		}
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
}
// Ent_Create style position from Doomsday Nuke

public void Blitzkrieg_IOC_Invoke(int client, int enemy)	//Ion cannon from above
{
	static float distance=87.0; // /29 for duartion till boom
	static float IOCDist=250.0;
	static float IOCdamage=100.0;
	
	float vecTarget[3];
	GetClientEyePosition(enemy, vecTarget);
	vecTarget[2] -= 54.0;
	
	Handle data = CreateDataPack();
	WritePackFloat(data, vecTarget[0]);
	WritePackFloat(data, vecTarget[1]);
	WritePackFloat(data, vecTarget[2]);
	WritePackCell(data, distance); // Distance
	WritePackFloat(data, 0.0); // nphi
	WritePackCell(data, IOCDist); // Range
	WritePackCell(data, IOCdamage); // Damge
	WritePackCell(data, client);
	ResetPack(data);
	Blitzkrieg_IonAttack(data);
}

public Action Blitzkrieg_DrawIon(Handle Timer, any data)
{
	Blitzkrieg_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void Blitzkrieg_DrawIonBeam(float startPosition[3], const color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, 1.0, 1.0, 255);
	TE_SendToAll();
}

	public void Blitzkrieg_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		int Ionrange = ReadPackCell(data);
		int Iondamage = ReadPackCell(data);
		int client = ReadPackCell(data);
		
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			// Stage 1
			float s=Sine(nphi/360*6.28)*Iondistance;
			float c=Cosine(nphi/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
			
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			Blitzkrieg_DrawIonBeam(position, {7, 255, 255, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackCell(nData, Ionrange);
		WritePackCell(nData, Iondamage);
		WritePackCell(nData, client);
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, Blitzkrieg_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		else
		{
			
			makeexplosion(client, client, startPosition, "", RoundToCeil(35.0 * RaidModeScaling), 100);
				
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {7, 255, 255, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {7, 255, 255, 200}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {7, 255, 255, 120}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {7, 255, 255, 75}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
			// Blend
			//sendfademsg(0, 10, 200, FFADE_OUT, 255, 255, 255, 150);
			
			// Knockback
	/*		float vReturn[3];
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < Ionrange)
					{
						MakeVectorFromPoints(position, vClientPosition, vReturn);
						NormalizeVector(vReturn, vReturn);
						ScaleVector(vReturn, 10000.0 - dist*10);
	
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
					}
				}
			}
*/
		}
}
void Music_Stop_All_Blitzkrieg(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
	StopSound(entity, SNDCHAN_AUTO, "ui/gamestartup12.mp3");
}
void Music_Stop_All_Beat(int entity)
{
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
	StopSound(entity, SNDCHAN_AUTO, "zombiesurvival/beats/defaultzombiev2/10.mp3");
}