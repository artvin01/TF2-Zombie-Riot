#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav",
};

static const char g_IdleSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/alert1.wav",
	"npc/combine_soldier/vo/bouncerbouncer.wav",
	"npc/combine_soldier/vo/boomer.wav",
	"npc/combine_soldier/vo/contactconfim.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
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


void CombineSwordsman_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DefaultMeleeMissSounds));   i++) { PrecacheSound(g_DefaultMeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedReloadSound));   i++) { PrecacheSound(g_RangedReloadSound[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSoundsSecondary));   i++) { PrecacheSound(g_RangedAttackSoundsSecondary[i]);   }
	PrecacheModel(COMBINE_CUSTOM_MODEL);
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "W.F. Swordsman");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_combine_soldier_swordsman");
	strcopy(data.Icon, sizeof(data.Icon), "demoknight");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return CombineSwordsman(vecPos, vecAng, team);
}

methodmap CombineSwordsman < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	public void PlayRangedAttackSecondarySound() {
		EmitSoundToAll(g_RangedAttackSoundsSecondary[GetRandomInt(0, sizeof(g_RangedAttackSoundsSecondary) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
	}
	
	
	public CombineSwordsman(float vecPos[3], float vecAng[3], int ally)
	{
		CombineSwordsman npc = view_as<CombineSwordsman>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "1500", ally));
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		

		func_NPCDeath[npc.index] = CombineSwordsman_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = CombineSwordsman_OnTakeDamage;
		func_NPCThink[npc.index] = CombineSwordsman_ClotThink;
			

		npc.m_iState = 0;
		npc.m_flSpeed = 200.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_fbRangedSpecialOn = false;
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("0.7");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/workshop/player/items/demo/jul13_trojan_helmet/jul13_trojan_helmet.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.StartPathing();
		
		
		return npc;
	}
	
	
}


public void CombineSwordsman_ClotThink(int iNPC)
{
	CombineSwordsman npc = view_as<CombineSwordsman>(iNPC);
	
	SetVariantInt(1);
	AcceptEntityInput(iNPC, "SetBodyGroup");
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	float TrueArmor = 1.0;
	if(!NpcStats_IsEnemySilenced(npc.index))
	{
		if(npc.m_fbRangedSpecialOn)
			TrueArmor *= 0.15;
	}
	fl_TotalArmor[npc.index] = TrueArmor;

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
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
	
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

		if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index) && flDistanceToTarget < 22500 || npc.m_fbRangedSpecialOn)
		{
	//		npc.FaceTowards(vecTarget, 20000.0);
			if(!npc.m_fbRangedSpecialOn)
			{
				npc.AddGesture("ACT_PUSH_PLAYER");
				npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 0.4;
				npc.m_fbRangedSpecialOn = true;
				npc.m_flReloadDelay = GetGameTime(npc.index) + 1.0;
				npc.StopPathing();
				
			}
			if(npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				npc.m_fbRangedSpecialOn = false;
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
				npc.PlayRangedAttackSecondarySound();
	
				float vecSpread = 0.1;
				
				npc.FaceTowards(vecTarget, 20000.0);
				
				float eyePitch[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
						
				//
				//
				
				
				float x, y;
				x = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
				y = GetRandomFloat( -0.0, 0.0 ) + GetRandomFloat( -0.0, 0.0 );
				
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
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				
				{
					FireBullet(npc.index, npc.index, WorldSpaceVec, vecDir, 60.0, 100.0, DMG_CLUB, "bullet_tracer02_blue", _,_,"anim_attachment_LH");
				}
			}
		}
		
		//Target close enough to hit
		if((flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flReloadDelay < GetGameTime(npc.index)) || npc.m_flAttackHappenswillhappen)
		{
		//	npc.FaceTowards(vecTarget, 1000.0);
			
			if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				if (!npc.m_flAttackHappenswillhappen)
				{
					npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 2.0;
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.PlayMeleeSound();
					npc.m_flAttackHappens = GetGameTime(npc.index)+0.4;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.54;
					npc.m_flAttackHappenswillhappen = true;
				}
					
				if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
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
							{
								SDKHooks_TakeDamage(target, npc.index, npc.index, 60.0, DMG_CLUB, -1, _, vecHit);
							}
							
							Custom_Knockback(npc.index, target, 350.0);
							
							// Hit particle
							
							
							// Hit sound
							npc.PlayMeleeHitSound();
						} 
					}
					delete swingTrace;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
					npc.m_flAttackHappenswillhappen = false;
				}
				else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
				{
					npc.m_flAttackHappenswillhappen = false;
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.6;
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

public Action CombineSwordsman_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	CombineSwordsman npc = view_as<CombineSwordsman>(victim);
	
	/*
	if(attacker > MaxClients && !IsValidEnemy(npc.index, attacker))
		return Plugin_Continue;
	*/
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	
	return Plugin_Changed;
}

public void CombineSwordsman_NPCDeath(int entity)
{
	CombineSwordsman npc = view_as<CombineSwordsman>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
}