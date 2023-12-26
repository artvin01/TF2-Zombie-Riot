#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/sniper_painsharp01.mp3",
	"vo/sniper_painsharp02.mp3",
	"vo/sniper_painsharp03.mp3",
	"vo/sniper_painsharp04.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/sniper_battlecry01.mp3",
	"vo/sniper_battlecry02.mp3",
	"vo/sniper_battlecry03.mp3",
	"vo/sniper_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/sniper_railgun_charged_shot_crit_01.wav",
	"weapons/sniper_railgun_charged_shot_crit_02.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/sniper_railgun_charged_shot_crit_01.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/sniper_railgun_charged_shot_01.wav",
	"weapons/sniper_railgun_charged_shot_02.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/sniper_railgun_world_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

void Sniper_railgunner_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	PrecacheModel("models/player/sniper.mdl");
}

static int i_overcharge[MAXENTITIES];

methodmap Sniper_railgunner < CClotBody
{
	
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-25, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
		
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-25, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-25, 80);
		
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
	
	
	
	public Sniper_railgunner(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Sniper_railgunner npc = view_as<Sniper_railgunner>(CClotBody(vecPos, vecAng, "models/player/sniper.mdl", "1.0", "12500", ally));
		
		i_NpcInternalId[npc.index] = ALT_SNIPER_RAILGUNNER;
		i_NpcWeight[npc.index] = 1;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		SDKHook(npc.index, SDKHook_Think, Sniper_railgunner_ClotThink);
		
		//IDLE
		npc.m_flSpeed = 250.0;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.Anger = false;
		
		i_overcharge[npc.index] = 0;
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/sniper/sniper_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_dex_sniperrifle/c_dex_sniperrifle.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/Jul13_Se_Headset/Jul13_Se_Headset_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/all_class/sbox2014_toowoomba_tunic/sbox2014_toowoomba_tunic_sniper.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Sniper_railgunner_ClotThink(int iNPC)
{
	Sniper_railgunner npc = view_as<Sniper_railgunner>(iNPC);
	
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			if(npc.m_flJumpStartTime < GetGameTime(npc.index))
			{
				npc.m_flSpeed = 170.0;
			}
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			
			if(flDistanceToTarget < 1562500)	//1250 range
			{
				
				if(flDistanceToTarget < 100000) //too close, back off!! Now! /uhhh something range
				{
					npc.StartPathing();
					
					int Enemy_I_See;
				
					Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see. oh shit, I don't have eyes (how do I see? *googles how to see*)
					{
						float vBackoffPos[3];
						
						vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
						
						NPC_SetGoalVector(npc.index, vBackoffPos, true);
					}
				}
				else
				{
					int Enemy_I_See;
				
					Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
					//Target close enough to hit
					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						
						//Can we attack right now?
						if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
						{
							npc.FaceTowards(vecTarget, 30000.0);
							//Play attack anim
							npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
							npc.m_flSpeed = 0.0;
							float damage;
							float speed;
							speed = 1250.0;
							damage = 50.0;
							
							if(i_overcharge[npc.index] > 5 && !NpcStats_IsEnemySilenced(npc.index))	//tl;dr, 6th shot is super pew pew. quad pew for 400 dmg 
							{
								speed = 2000.0;
								damage = 50.0;
								i_overcharge[npc.index] = 0;
								npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 7.0;	//long reload, the gun overheated from the charge shot.
								npc.PlayMeleeSound();
								if(flDistanceToTarget < 1000000)	//doesn't predict over 1000 hu
								{
									vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed);
								}
								if(ZR_GetWaveCount()<40)
								{
									damage=20.0;
								}
								
								npc.FireParticleRocket(vecTarget, damage*4 , speed , 100.0 , "raygun_projectile_red_crit");
								//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)
							}
							else
							{
								if(flDistanceToTarget < 562500)	//Doesn't predict over 750 hu
								{
									vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, speed);
								}
								if(ZR_GetWaveCount()<40)
								{
									damage=25.0;
								}
								npc.FireArrow(vecTarget, damage, speed);
								npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.75;
								i_overcharge[npc.index]++;
								npc.PlayRangedSound();
							}	
							npc.m_flJumpStartTime = GetGameTime(npc.index) + 0.9;
							npc.PlayRangedReloadSound();
						}
						NPC_StopPathing(npc.index);
						npc.m_bPathing = false;
					}
					else
					{
						npc.StartPathing();
					}
				}
			}
			else
			{
				npc.StartPathing();
			}
			
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
				
				
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
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

public Action Sniper_railgunner_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Sniper_railgunner npc = view_as<Sniper_railgunner>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Sniper_railgunner_ClotDamaged_Post(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	Sniper_railgunner npc = view_as<Sniper_railgunner>(victim);

	if(10000 >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger)
	{
		npc.Anger = true; //	>:(
		npc.m_flSpeed = 330.0;
	}
}

public void Sniper_railgunner_NPCDeath(int entity)
{
	Sniper_railgunner npc = view_as<Sniper_railgunner>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	
	SDKUnhook(npc.index, SDKHook_Think, Sniper_railgunner_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, Sniper_railgunner_ClotDamaged_Post);	
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}