#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/sniper_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath03.mp3",
	"vo/mvm/norm/sniper_mvm_paincrticialdeath04.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/sniper_mvm_painsevere01.mp3",
	"vo/mvm/norm/sniper_mvm_painsevere02.mp3",
	"vo/mvm/norm/sniper_mvm_painsevere03.mp3",
	"vo/mvm/norm/sniper_mvm_painsevere04.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp01.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp02.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp03.mp3",
	"vo/mvm/norm/sniper_mvm_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/sniper_mvm_battlecry01.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry02.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry03.mp3",
	"vo/mvm/norm/sniper_mvm_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/smg_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/smg_worldreload.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void BunkerBotSniper_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/bots/sniper/bot_sniper.mdl");
}

methodmap BunkerBotSniper < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime())
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime() + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime())
			return;
			
		this.m_flNextHurtSound = GetGameTime() + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
		
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	public BunkerBotSniper(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		BunkerBotSniper npc = view_as<BunkerBotSniper>(CClotBody(vecPos, vecAng, "models/bots/sniper/bot_sniper.mdl", "1.0", "12500", ally));
		
		i_NpcInternalId[npc.index] = BUNKER_BOT_SNIPER;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOTSOUNDS;
		
		
		SDKHook(npc.index, SDKHook_Think, BunkerBotSniper_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, BunkerBotSniper_ClotDamaged_Post);
		
		//IDLE
		npc.m_flSpeed = 300.0;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iAttacksTillReload = 1;
		npc.Anger = false;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_sniperrifle/c_sniperrifle.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		return npc;
	}
}

//TODO 
//Rewrite
public void BunkerBotSniper_ClotThink(int iNPC)
{
	BunkerBotSniper npc = view_as<BunkerBotSniper>(iNPC);
	
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
		if(npc.Anger)
		{
			if(npc.m_iChanged_WalkCycle != 2)
			{
				if(IsValidEntity(npc.m_iWearable1))
					RemoveEntity(npc.m_iWearable1);
			
				npc.m_iChanged_WalkCycle = 2;
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				
				npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/weapons/c_models/c_scimitar/c_scimitar.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius())
			{
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			}
			else
			{
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < 15000 || npc.m_flAttackHappenswillhappen)
			{			
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime() || npc.m_flAttackHappenswillhappen)
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
									SDKHooks_TakeDamage(target, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, vecHit);
								else
									SDKHooks_TakeDamage(target, npc.index, npc.index, 800.0, DMG_CLUB, -1, _, vecHit);

								//npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", vecHit, NULL_VECTOR, NULL_VECTOR);
								
								// Hit sound
								npc.PlayMeleeHitSound();
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.6;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime() && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime() + 0.6;
					}
				}
			}
			else
			{
				npc.StartPathing();
				
			}
		}
		else if(!npc.Anger)
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
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextRangedAttack < GetGameTime() && flDistanceToTarget < 942500 && npc.m_flReloadDelay < GetGameTime())
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
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.FaceTowards(vecTarget, 10000.0);
					npc.m_flNextRangedAttack = GetGameTime() + 2.1;
					npc.m_iAttacksTillReload -= 1;
					
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
						npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY2");
						npc.m_flReloadDelay = GetGameTime() + 1.0;
						npc.m_iAttacksTillReload = 1;
						npc.PlayRangedReloadSound();
						//npc.AddGesture("ACT_MP_DEPLOYED_IDLE_ITEM");
					}
					
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					npc.FireArrow(vecTarget, 30.0, 1400.0, "models/weapons/w_models/w_rocket_airstrike/w_rocket_airstrike.mdl", 0.7);
					
					//FireBullet(npc.index, npc.m_iWearable1, WorldSpaceCenter(npc.index), vecDir, 50.0, 9500.0, DMG_BULLET, "bullet_tracer01_red");
					npc.PlayRangedSound();
				}
			}
			if(flDistanceToTarget > 942500)
			{
				npc.StartPathing();
			}
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

public Action BunkerBotSniper_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	BunkerBotSniper npc = view_as<BunkerBotSniper>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime())
	{
		npc.m_flHeadshotCooldown = GetGameTime() + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void BunkerBotSniper_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	BunkerBotSniper npc = view_as<BunkerBotSniper>(victim);

	if(3000 >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		npc.Anger = true; //	>:(
		npc.m_flSpeed = 330.0;
	}
}

public void BunkerBotSniper_NPCDeath(int entity)
{
	BunkerBotSniper npc = view_as<BunkerBotSniper>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, BunkerBotSniper_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, BunkerBotSniper_ClotDamaged_Post);	
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}



