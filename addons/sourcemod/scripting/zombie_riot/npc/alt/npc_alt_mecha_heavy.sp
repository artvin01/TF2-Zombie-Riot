static const char g_DeathSounds[][] = {
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/heavy_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/mvm/norm/heavy_mvm_jeers03.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers04.mp3",	
	"vo/mvm/norm/heavy_mvm_jeers06.mp3",
	"vo/mvm/norm/heavy_mvm_jeers09.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/taunts/heavy_mvm_taunts16.mp3",
	"vo/mvm/norm/taunts/heavy_mvm_taunts18.mp3",
	"vo/mvm/norm/taunts/heavy_mvm_taunts19.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav",
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

void Mecha_Heavy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
}

methodmap Mecha_Heavy < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(80, 85));
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	
	
	public Mecha_Heavy(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Mecha_Heavy npc = view_as<Mecha_Heavy>(CClotBody(vecPos, vecAng, "models/bots/heavy/bot_heavy.mdl", "1.0", "5000", ally));
		
		i_NpcInternalId[npc.index] = ALT_MECHA_HEAVY;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPTYPE_ROBOT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Mecha_Heavy_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Mecha_Heavy_ClotThink);		
		

		npc.m_flSpeed = 230.0;
		//IDLE
		npc.m_iState = 0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Mecha_Heavy_ClotThink(int iNPC)
{
	Mecha_Heavy npc = view_as<Mecha_Heavy>(iNPC);
	
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
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				PF_SetGoalVector(npc.index, vPredictedPos);
			} else {
				PF_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime())
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime()+0.4;
						npc.m_flAttackHappens_bullshit = GetGameTime()+0.54;
						npc.m_flAttackHappenswillhappen = true;
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 200.0, DMG_CLUB, -1, _, vecHit);
								
								
								
								
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.8;
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

public Action Mecha_Heavy_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Mecha_Heavy npc = view_as<Mecha_Heavy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Mecha_Heavy_NPCDeath(int entity)
{
	Mecha_Heavy npc = view_as<Mecha_Heavy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Mecha_Heavy_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Mecha_Heavy_ClotThink);	
}

