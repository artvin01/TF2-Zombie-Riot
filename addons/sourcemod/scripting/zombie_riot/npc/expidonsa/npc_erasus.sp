#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/neon_sign_hit_01.wav",
	"weapons/neon_sign_hit_02.wav",
	"weapons/neon_sign_hit_03.wav",
	"weapons/neon_sign_hit_04.wav"
};

void Erasus_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	PrecacheModel("models/player/medic.mdl");
}


methodmap Erasus < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

	}
	
	
	public Erasus(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Erasus npc = view_as<Erasus>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "10000", ally));
		
		i_NpcInternalId[npc.index] = EXPIDONSA_ERASUS;
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		SDKHook(npc.index, SDKHook_Think, Erasus_ClotThink);
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 330.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		ErasusEffects(npc.index);

		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");


		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_misc1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem/dec15_medic_winter_jacket2_emblem.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		
		return npc;
	}
}

public void Erasus_ClotThink(int iNPC)
{
	Erasus npc = view_as<Erasus>(iNPC);
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
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);
	
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			vPredictedPos = PredictSubjectPosition(npc, npc.m_iTarget);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		ErasusSelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Erasus_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Erasus npc = view_as<Erasus>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Erasus_NPCDeath(int entity)
{
	Erasus npc = view_as<Erasus>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	ExpidonsaRemoveEffects(entity);
	SDKUnhook(npc.index, SDKHook_Think, Erasus_ClotThink);
		
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

void ErasusSelfDefense(Erasus npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
							
				target = TR_GetEntityIndex(swingTrace);	
				
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 100.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;


					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
				delete swingTrace;
			}
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
								
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						
				npc.m_flAttackHappens = gameTime + 0.25;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
}


void ErasusEffects(int iNpc)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(iNpc, "effect_hand_r", flPos, flAng);

	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	
	int particle_2 = ParticleEffectAt({0.0,-15.0,0.0}, "", 0.0); //First offset we go by
	int particle_3 = ParticleEffectAt({-15.0,0.0,0.0}, "", 0.0); //First offset we go by
	int particle_4 = ParticleEffectAt({5.0,10.0,0.0}, "", 0.0); //First offset we go by
	int particle_5 = ParticleEffectAt({2.0,50.0,0.0}, "", 0.0); //First offset we go by

	
	int particle_2_i = ParticleEffectAt({0.0,-15.0,0.0}, "", 0.0); //First offset we go by
	int particle_3_i = ParticleEffectAt({15.0,0.0,0.0}, "", 0.0); //First offset we go by
	int particle_4_i = ParticleEffectAt({-5.0,10.0,0.0}, "", 0.0); //First offset we go by
	int particle_5_i = ParticleEffectAt({-2.0,50.0,0.0}, "", 0.0); //First offset we go by
	
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	
	SetParent(particle_1, particle_2_i, "",_, true);
	SetParent(particle_1, particle_3_i, "",_, true);
	SetParent(particle_1, particle_4_i, "",_, true);
	SetParent(particle_1, particle_5_i, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(iNpc, particle_1, "effect_hand_r",_); 


	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, 255, 255, 255, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, 255, 255, 255, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, 255, 255, 255, 2.0, 1.0, 1.0, LASERBEAM);
	
	int Laser_1_i = ConnectWithBeamClient(particle_2_i, particle_3_i, 255, 255, 255, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_2_i = ConnectWithBeamClient(particle_3_i, particle_4_i, 255, 255, 255, 2.0, 2.0, 1.0, LASERBEAM);
	int Laser_3_i = ConnectWithBeamClient(particle_4_i, particle_5_i, 255, 255, 255, 2.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[iNpc][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[iNpc][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[iNpc][2] = EntIndexToEntRef(particle_3);
	i_ExpidonsaEnergyEffect[iNpc][3] = EntIndexToEntRef(particle_4);
	i_ExpidonsaEnergyEffect[iNpc][4] = EntIndexToEntRef(particle_5);
	i_ExpidonsaEnergyEffect[iNpc][5] = EntIndexToEntRef(particle_2_i);
	i_ExpidonsaEnergyEffect[iNpc][6] = EntIndexToEntRef(particle_3_i);
	i_ExpidonsaEnergyEffect[iNpc][7] = EntIndexToEntRef(particle_4_i);
	i_ExpidonsaEnergyEffect[iNpc][8] = EntIndexToEntRef(particle_5_i);
	i_ExpidonsaEnergyEffect[iNpc][9] = EntIndexToEntRef(Laser_1);
	i_ExpidonsaEnergyEffect[iNpc][10] = EntIndexToEntRef(Laser_2);
	i_ExpidonsaEnergyEffect[iNpc][11] = EntIndexToEntRef(Laser_3);
	i_ExpidonsaEnergyEffect[iNpc][12] = EntIndexToEntRef(Laser_1_i);
	i_ExpidonsaEnergyEffect[iNpc][13] = EntIndexToEntRef(Laser_2_i);
	i_ExpidonsaEnergyEffect[iNpc][14] = EntIndexToEntRef(Laser_3_i);
}
