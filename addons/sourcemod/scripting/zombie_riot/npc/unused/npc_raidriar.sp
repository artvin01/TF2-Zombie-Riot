#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"freak_fortress_2/god_king_infinity_blade/death1.mp3",
	"freak_fortress_2/god_king_infinity_blade/death2.mp3",
};

static const char g_HurtSounds[][] = {
	"freak_fortress_2/god_king_infinity_blade/hurt1.mp3",
	"freak_fortress_2/god_king_infinity_blade/hurt2.mp3",
	"freak_fortress_2/god_king_infinity_blade/hurt3.mp3",
	"freak_fortress_2/god_king_infinity_blade/hurt3.mp3",
};

static const char g_IdleSounds[][] = {
	"freak_fortress_2/god_king_infinity_blade/intro.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"freak_fortress_2/god_king_infinity_blade/backstab1.mp3",
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

static float fl_UseBladeSwingNow[MAXENTITIES];
static float fl_CanIParryNow[MAXENTITIES];
static float fl_CanIParryNow_timer[MAXENTITIES];
static float fl_UseBladeSwingNow_timer[MAXENTITIES];
static float fl_MySwordGoesBrr[MAXENTITIES];
static bool b_UseBladeSwingNow[MAXENTITIES];
static bool b_CanIParryNow[MAXENTITIES];

void GodKingRaidriar_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/freak_fortress_2/god_king_infinity_blade/ib3_godking_16.mdl");
	PrecacheSound("freak_fortress_2/god_king_infinity_blade/lifeloss1.mp3");
}

methodmap GodKingRaidriar < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
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
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		
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
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public GodKingRaidriar(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		GodKingRaidriar npc = view_as<GodKingRaidriar>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "5000", ally, false, true, true, true));
		
		i_NpcInternalId[npc.index] = GODKINGRAIDRIAR;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		//npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		
		SDKHook(npc.index, SDKHook_Think, GodKingRaidriar_ClotThink);			

		npc.m_flSpeed = 300.0;
		//IDLE
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;

		//npc.m_flRangedArmor = 0.9;
		//npc.m_flMeleeArmor = 1.1;
		
		//EmitSoundToAll("freak_fortress_2/god_king_infinity_blade/bgm3.mp3")
		EmitSoundToAll("freak_fortress_2/god_king_infinity_blade/intro.mp3")
		
		fl_MySwordGoesBrr[npc.index] = 1.0;
		fl_UseBladeSwingNow[npc.index] = 20.0 + GetGameTime();
		//i_UseBladeSwingNow_timer[npc.index] = 0;
		b_UseBladeSwingNow[npc.index] = false;
		fl_CanIParryNow[npc.index] = 15.0 + GetGameTime();
		b_CanIParryNow[npc.index] = false;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.StartPathing();
		return npc;
	}
}

public void GodKingRaidriar_ClotThink(int iNPC)
{
	GodKingRaidriar npc = view_as<GodKingRaidriar>(iNPC);
	
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
	if(npc.m_flNextThinkTime > GetGameTime())
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime() + 0.1;
	
	if(npc.m_flGetClosestTargetTime < GetGameTime())
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime() + 1.0;
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_UseBladeSwingNow[npc.index] <= GetGameTime() && !b_UseBladeSwingNow[npc.index] && !b_CanIParryNow[npc.index])
		{
			EmitSoundToAll("freak_fortress_2/god_king_infinity_blade/lifeloss1.mp3");
		
			b_UseBladeSwingNow[npc.index] = true;
			
			fl_MySwordGoesBrr[npc.index] = 0.0;
			
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_claymore/c_claymore.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale")
		
			fl_UseBladeSwingNow_timer[npc.index] = 4.0 + GetGameTime();
		
			//fl_UseBladeSwingNow[npc.index] = 4.0 + GetGameTime();
		
			npc.m_flSpeed = 370.0;
		
			PrintToServer("Blade Swing");
		}
		if(b_UseBladeSwingNow[npc.index] && fl_UseBladeSwingNow_timer[npc.index] <= GetGameTime())
		{
			fl_MySwordGoesBrr[npc.index] = 1.0;
			b_UseBladeSwingNow[npc.index] = false
			fl_UseBladeSwingNow[npc.index] = 15.0 + GetGameTime();
			fl_UseBladeSwingNow_timer[npc.index] = 0.0 + GetGameTime();
			npc.m_flSpeed = 300.0;
		}
		if(fl_CanIParryNow[npc.index] <= GetGameTime() && !b_UseBladeSwingNow[npc.index] && !b_CanIParryNow[npc.index])
		{
			npc.m_flRangedArmor = 0.01;
			npc.m_flMeleeArmor = 0.01;
			b_CanIParryNow[npc.index] = true
			fl_CanIParryNow_timer[npc.index] = 1.5 + GetGameTime();
			PrintToServer("Parry");
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;
		}
		if(fl_CanIParryNow_timer[npc.index] <= GetGameTime() && b_CanIParryNow[npc.index])
		{
			b_CanIParryNow[npc.index] = false
			fl_CanIParryNow[npc.index] = 15.0 + GetGameTime();
			npc.m_flRangedArmor = 0.9;
			npc.m_flMeleeArmor = 1.1;
			npc.StartPathing(); //idk i added this as a safty
		}
		
		float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		
		if(flDistanceToTarget < npc.GetLeadRadius())//Predict their pos.
		{
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		}
		if(!b_CanIParryNow[npc.index])
		{
			//Target close enough to hit
			if(flDistanceToTarget < 40000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.	//npc.FaceTowards(vecTarget, 1000.0);	//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime())
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.StartPathing();
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = 0.0;
						npc.m_flAttackHappens_bullshit = GetGameTime()+fl_MySwordGoesBrr[npc.index];
						npc.m_flAttackHappenswillhappen = true;
					}
					if (npc.m_flAttackHappens < GetGameTime() && npc.m_flAttackHappens_bullshit >= GetGameTime() && npc.m_flAttackHappenswillhappen)
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
								//npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
								npc.PlayMeleeHitSound();// Hit sound
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + fl_MySwordGoesBrr[npc.index];
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime() + fl_MySwordGoesBrr[npc.index];
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
	//npc.PlayIdleAlertSound();
}

public Action GodKingRaidriar_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	GodKingRaidriar npc = view_as<GodKingRaidriar>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void GodKingRaidriar_NPCDeath(int entity)
{
	GodKingRaidriar npc = view_as<GodKingRaidriar>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, GodKingRaidriar_ClotThink);	
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

