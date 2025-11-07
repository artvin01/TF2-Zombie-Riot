#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	")npc/combine_soldier/die1.wav",
	")npc/combine_soldier/die2.wav",
	")npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	")npc/combine_soldier/pain1.wav",
	")npc/combine_soldier/pain2.wav",
	")npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	")npc/combine_soldier/vo/alert1.wav",
	")npc/combine_soldier/vo/bouncerbouncer.wav",
	")npc/combine_soldier/vo/boomer.wav",
	")npc/combine_soldier/vo/contactconfim.wav",
};
static const char g_MeleeHitSounds[][] = {
	")weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_ChargeSounds[][] = {
	")weapons/physcannon/physcannon_charge.wav",
};

static const char g_MeleeAttackSounds[][] = {
	")weapons/demo_sword_swing1.wav",
	")weapons/demo_sword_swing2.wav",
	")weapons/demo_sword_swing3.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

static const char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

public void XenoCombineOverlord_OnMapStart_NPC()
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
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	for (int i = 0; i < (sizeof(g_ChargeSounds));   i++) { PrecacheSound(g_ChargeSounds[i]);   }
	
	PrecacheModel("models/props_wasteland/rockgranite03b.mdl");
	PrecacheModel("models/weapons/w_bullet.mdl");
	PrecacheModel("models/weapons/w_grenade.mdl");
	
	PrecacheSound("ambient/explosions/citadel_end_explosion2.wav",true);
	PrecacheSound("ambient/explosions/citadel_end_explosion1.wav",true);
	PrecacheSound("ambient/energy/weld1.wav",true);
	PrecacheSound("ambient/halloween/mysterious_perc_01.wav",true);
	
	PrecacheSound("player/flow.wav");
	PrecacheModel("models/effects/combineball.mdl", true);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Overlord");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_combine_soldier_overlord");
	strcopy(data.Icon, sizeof(data.Icon), "combine_overlord");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Xeno;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return XenoCombineOverlord(vecPos, vecAng, team);
}
methodmap XenoCombineOverlord < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlaySpecialChargeSound() {
		EmitSoundToAll(g_ChargeSounds[GetRandomInt(0, sizeof(g_ChargeSounds) - 1)], this.index, _, 110, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public XenoCombineOverlord(float vecPos[3], float vecAng[3], int ally)
	{
		XenoCombineOverlord npc = view_as<XenoCombineOverlord>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "1.25", "35000", ally));
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_WF_OVERLORD_RUN_XENO");
		
		
		npc.m_iBleedType = BLEEDTYPE_XENO;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;		
		
	
		func_NPCDeath[npc.index] = XenoCombineOverlord_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = XenoCombineOverlord_OnTakeDamage;
		func_NPCThink[npc.index] = XenoCombineOverlord_ClotThink;	
	//	npc.m_bDissapearOnDeath = true;
		npc.m_flNextMeleeAttack = 0.0;
		
		
		npc.m_bThisNpcIsABoss = true;
		npc.m_flSpeed = 250.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 5.0;
	//	npc.m_iOverlordComboAttack = 0;
		
		GiveNpcOutLineLastOrBoss(npc.index, true);
		
		npc.m_iWearable2 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 2);
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/demo/crown.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		
		SetEntityRenderColor(npc.index, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable1, 150, 255, 150, 255);
		SetEntityRenderColor(npc.m_iWearable2, 150, 255, 150, 255);
		
		return npc;
	}
	
	
}


public void XenoCombineOverlord_ClotThink(int iNPC)
{
	XenoCombineOverlord npc = view_as<XenoCombineOverlord>(iNPC);
	
	SetVariantInt(3);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	float TrueArmor = 1.0;
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		if(npc.m_flAngerDelay > GetGameTime(npc.index))
			TrueArmor *= 0.25;
		
		if(npc.m_fbRangedSpecialOn)
			TrueArmor *= 0.15;
	}
	fl_TotalArmor[npc.index] = TrueArmor;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			if (npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				if (npc.m_flmovedelay < GetGameTime(npc.index) && npc.m_flAngerDelay < GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 7)
					{
						npc.m_iChanged_WalkCycle = 7;
						npc.SetActivity("ACT_WF_OVERLORD_RUN_XENO");
					}
					npc.m_flmovedelay = GetGameTime(npc.index) + 1.0;
					npc.m_flSpeed = 330.0;
				}
				if (npc.m_flmovedelay < GetGameTime(npc.index) && npc.m_flAngerDelay > GetGameTime(npc.index))
				{
					if(npc.m_iChanged_WalkCycle != 8)
					{
						npc.m_iChanged_WalkCycle = 8;
						npc.SetActivity("ACT_WF_OVERLORD_RUN_RAGE_XENO");
					}
					npc.m_flmovedelay = GetGameTime(npc.index) + 1.0;
					npc.m_flSpeed = 380.0;
				}
			//	npc.FaceTowards(vecTarget);
			}
			
			if(npc.m_flJumpStartTime > GetGameTime(npc.index))
			{
				npc.m_flSpeed = 0.0;
			}
			
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				npc.SetGoalVector(vPredictedPos);
			} else {
				npc.SetGoalEntity(PrimaryThreatIndex);
			}
			
			if(npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index) && npc.m_flReloadDelay < GetGameTime(npc.index) && !npc.m_fbRangedSpecialOn && flDistanceToTarget < 160000)
			{
				npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 20.0;
				npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
				npc.m_flRangedSpecialDelay += GetGameTime(npc.index) + 1.0;
				npc.m_flAngerDelay = GetGameTime(npc.index) + 5.0;
				if(npc.m_bThisNpcIsABoss)
				{
					npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				}
				npc.PlaySpecialChargeSound();
				npc.AddGesture("ACT_WF_OVERLORD_RAGE_START_XENO", .SetGestureSpeed = 2.0);
				npc.m_flmovedelay = GetGameTime(npc.index) + 0.5;
				npc.m_flJumpStartTime = GetGameTime(npc.index) + 1.0;
				npc.StopPathing();
				
			}
	
			if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && flDistanceToTarget < 22500 && npc.m_flAngerDelay < GetGameTime(npc.index) || npc.m_fbRangedSpecialOn)
			{
			//	npc.FaceTowards(vecTarget, 2000.0);
				if(!npc.m_fbRangedSpecialOn)
				{
					npc.AddGesture("ACT_WF_OVERLORD_ATTACK_PULSE_XENO");
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.3;
					npc.m_fbRangedSpecialOn = true;
					npc.m_flReloadDelay = GetGameTime(npc.index) + 0.3;
				}
				if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
				{
					npc.m_fbRangedSpecialOn = false;
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 8.0;
					npc.PlayRangedAttackSecondarySound();

					float vecSpread = 0.1;
					
					npc.FaceTowards(vecTarget, 20000.0);
					
					float eyePitch[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
							
					//
					//
					
					
					float x, y;
					x = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
					y = GetRandomFloat( -0.01, 0.01 ) + GetRandomFloat( -0.01, 0.01 );
					
					float vecDirShooting[3], vecRight[3], vecUp[3];
					//GetAngleVectors(eyePitch, vecDirShooting, vecRight, vecUp);
					
					vecTarget[2] += 15.0;
					float SelfVecPos[3]; WorldSpaceCenter(npc.index, SelfVecPos);
					MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
					GetVectorAngles(vecDirShooting, vecDirShooting);
					vecDirShooting[1] = eyePitch[1];
					GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
					
					//add the spray
					float vecDir[3];
					vecDir[0] = vecDirShooting[0] + x * vecSpread * vecRight[0] + y * vecSpread * vecUp[0]; 
					vecDir[1] = vecDirShooting[1] + x * vecSpread * vecRight[1] + y * vecSpread * vecUp[1]; 
					vecDir[2] = vecDirShooting[2] + x * vecSpread * vecRight[2] + y * vecSpread * vecUp[2]; 
					NormalizeVector(vecDir, vecDir);
					
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
					
					float npc_vec[3]; WorldSpaceCenter(npc.index, npc_vec);
					int player_hurt = FireBullet(npc.index, npc.index, npc_vec, vecDir, 150.0, 150.0, DMG_CLUB, "bullet_tracer02_blue", _,_,"anim_attachment_LH");
					
					if(IsValidClient(player_hurt))
					{
						DataPack pack;
						CreateDataTimer(0.2, XenoCombineOverlord_Timer_Combo_Attack, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						pack.WriteCell(GetClientUserId(player_hurt));
						pack.WriteCell(EntIndexToEntRef(npc.index));	
					}
				}
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index) || npc.m_flAttackHappenswillhappen)
			{
				npc.StartPathing();

				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
						npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_XENO");
						npc.RemoveGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE_XENO");
						if(npc.m_flAngerDelay > GetGameTime(npc.index))
						{
							npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_RAGE_XENO",_, 0.25);
						}
						else
							npc.AddGesture("ACT_WF_OVERLORD_ATTACK_NORMAL_XENO",_, 0.25);
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.44;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.FaceTowards(vecTarget, 20000.0);
						Handle swingTrace;
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									if(!ShouldNpcDealBonusDamage(target))
										SDKHooks_TakeDamage(target, npc.index, npc.index, 110.0, DMG_CLUB, -1, _, vecHit);
									else
										SDKHooks_TakeDamage(target, npc.index, npc.index, 450.0, DMG_CLUB, -1, _, vecHit);
											
									Custom_Knockback(npc.index, target, 450.0);
									
									// Hit particle
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
								} 
							}
						delete swingTrace;
						if(npc.m_flAngerDelay > GetGameTime(npc.index))
						{
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
						}
						else
						{
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.4;
						}
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						if(npc.m_flAngerDelay > GetGameTime(npc.index))
						{
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.2;
						}
						else
						{
							npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.4;
						}
					}
				}
			}
			if (npc.m_flReloadDelay < GetGameTime(npc.index))
			{
				npc.StartPathing();
				
			}
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action XenoCombineOverlord_Timer_Combo_Attack(Handle Debuff_lightning_hud, DataPack pack)
{
	pack.Reset();
	int target = GetClientOfUserId(pack.ReadCell());
	int npczombie = EntRefToEntIndex(pack.ReadCell());
	
	if (IsValidClient(target) && IsValidEntity(npczombie))
	{
		XenoCombineOverlord npc = view_as<XenoCombineOverlord>(npczombie);
		if(npc.m_iOverlordComboAttack <= 5)
		{
			SDKHooks_TakeDamage(target, npc.index, npc.index, 30.0, DMG_CLUB);
			Custom_Knockback(npc.index, target, 250.0);
			float startPosition[3];
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", startPosition);
			npc.DispatchParticleEffect(npc.index, "blood_impact_backscatter", startPosition, NULL_VECTOR, NULL_VECTOR);
			// Hit sound
			npc.PlayMeleeHitSound();
			npc.m_iOverlordComboAttack += 1;
			return Plugin_Continue;
		}
		else
		{
			npc.m_iOverlordComboAttack = 0;
			return Plugin_Stop;
		}
	}
	return Plugin_Stop;
}

public Action XenoCombineOverlord_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	XenoCombineOverlord npc = view_as<XenoCombineOverlord>(victim);
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}


	return Plugin_Changed;
}

public void XenoCombineOverlord_NPCDeath(int entity)
{
	XenoCombineOverlord npc = view_as<XenoCombineOverlord>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}