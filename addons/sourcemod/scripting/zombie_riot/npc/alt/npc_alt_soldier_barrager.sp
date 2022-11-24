#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/Soldier_paincrticialdeath01.mp3",
	"vo/Soldier_paincrticialdeath02.mp3",
	"vo/Soldier_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/Soldier_painsharp01.mp3",
	"vo/Soldier_painsharp02.mp3",
	"vo/Soldier_painsharp03.mp3",
	"vo/Soldier_painsharp04.mp3",
	"vo/Soldier_painsharp05.mp3",
	"vo/Soldier_painsharp06.mp3",
	"vo/Soldier_painsharp07.mp3",
	"vo/Soldier_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/taunts/Soldier_taunts01.mp3",
	"vo/taunts/Soldier_taunts09.mp3",
	"vo/taunts/Soldier_taunts14.mp3",
	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/Soldier_taunts19.mp3",
	"vo/taunts/Soldier_taunts20.mp3",
	"vo/taunts/Soldier_taunts21.mp3",
	"vo/taunts/Soldier_taunts18.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/rocket_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static const char g_RangedReloadSound[][] = {
	"weapons/dumpster_rocket_reload.wav",
};

void Soldier_Barrager_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/Soldier.mdl");
}

static int i_ammo_count[MAXENTITIES];
static bool b_target_close[MAXENTITIES];
static bool b_we_are_reloading[MAXENTITIES];
static float fl_idle_timer[MAXENTITIES];

methodmap Soldier_Barrager < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, 80, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public Soldier_Barrager(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Soldier_Barrager npc = view_as<Soldier_Barrager>(CClotBody(vecPos, vecAng, "models/player/Soldier.mdl", "1.0", "2000", ally));
		
		i_NpcInternalId[npc.index] = ALT_SOLDIER_BARRAGER;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Soldier_Barrager_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Soldier_Barrager_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 270.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		i_ammo_count[npc.index]=0;
		b_target_close[npc.index]=false;
		b_we_are_reloading[npc.index]=false;
		fl_idle_timer[npc.index] = 2.0 + GetGameTime(npc.index);
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/Soldier/Soldier_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/soldier_officer.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.index, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 125, 100, 100, 255);
		
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 125, 100, 100, 255);
		
		npc.StartPathing();
		
		
		return npc;
	}
}

//TODO 
//Rewrite
public void Soldier_Barrager_ClotThink(int iNPC)
{
	Soldier_Barrager npc = view_as<Soldier_Barrager>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
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
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
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
			
			if(i_ammo_count[npc.index]==0 && !b_we_are_reloading[npc.index] && !b_target_close[npc.index])	//the npc will prefer to fully reload the clip before attacking, unless the target is too close.
			{
				b_we_are_reloading[npc.index]=true;
			}
			if((b_we_are_reloading[npc.index] || (b_target_close[npc.index] && i_ammo_count[npc.index]<=0)) && npc.m_flReloadIn<GetGameTime(npc.index))	//Reload IF. Target too close. Empty clip.
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
				npc.m_flReloadIn = 0.75 + GetGameTime(npc.index);
				i_ammo_count[npc.index]++;
				npc.PlayRangedReloadSound();
			}
			if(fl_idle_timer[npc.index] <= GetGameTime(npc.index) && npc.m_flReloadIn<GetGameTime(npc.index) && !b_we_are_reloading[npc.index] && !b_target_close[npc.index] && i_ammo_count[npc.index]<10)	//reload if not attacking/idle for long
			{
				npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
				npc.m_flReloadIn = 0.75 + GetGameTime(npc.index);
				i_ammo_count[npc.index]++;
				npc.PlayRangedReloadSound();
			}
			if(i_ammo_count[npc.index]>=10)	//npc will stop reloading once clip size is full.
			{
				b_we_are_reloading[npc.index]=false;
			}
			if(flDistanceToTarget < 60000)
			{
				b_target_close[npc.index]=true;
			}
			else
			{
				b_target_close[npc.index]=false;
			}
			if((i_ammo_count[npc.index]==0 || b_we_are_reloading[npc.index]) && !b_target_close[npc.index])	//Run away if ammo is 0 or we are reloading. Don't run if target is too close
			{
				npc.StartPathing();
				
				npc.m_flSpeed = 250.0;	//reloading is a hard job.
				
				int Enemy_I_See;
			
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					float vBackoffPos[3];
					
					vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
					
					PF_SetGoalVector(npc.index, vBackoffPos);
				}
			}
			else if(flDistanceToTarget < 120000 && i_ammo_count[npc.index]>0)
			{
				npc.m_flSpeed = 270.0;
				int Enemy_I_See;
				
				fl_idle_timer[npc.index] = 2.5 + GetGameTime(npc.index);
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{	
					//Can we attack right now?
					if(npc.m_flNextMeleeAttack < GetGameTime(npc.index) && i_ammo_count[npc.index] >=0)
					{
						//Play attack anim
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 750.0);
						npc.FaceTowards(vecTarget, 20000.0);
						npc.PlayMeleeSound();
						float dmg = 12.5;
						if(ZR_GetWaveCount()>=45)
						{
							dmg=17.5;
						}
						npc.FireRocket(vecTarget, dmg, 750.0);
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.5;
						npc.m_flReloadIn = GetGameTime(npc.index) + 1.75;
						i_ammo_count[npc.index]--;
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
	npc.PlayIdleAlertSound();
}


public Action Soldier_Barrager_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Soldier_Barrager npc = view_as<Soldier_Barrager>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Soldier_Barrager_NPCDeath(int entity)
{
	Soldier_Barrager npc = view_as<Soldier_Barrager>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Soldier_Barrager_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Soldier_Barrager_ClotThink);
		
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}