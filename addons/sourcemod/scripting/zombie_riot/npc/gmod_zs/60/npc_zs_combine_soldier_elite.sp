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
	"npc/vort/foot_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"npc/combine_soldier/gear1.wav",
	"npc/combine_soldier/gear2.wav",
	"npc/combine_soldier/gear3.wav",
	"npc/combine_soldier/gear4.wav",
	"npc/combine_soldier/gear5.wav",
	"npc/combine_soldier/gear6.wav",
};


static const char g_RangedAttackSounds[][] = {
	"weapons/ar2/fire1.wav",
};

static const char g_RangedAttackSoundsSecondary[][] = {
	"weapons/irifle/irifle_fire2.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/ar2/npc_ar2_reload.wav",
};

void ZSCombineElite_OnMapStart_NPC()
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
	PrecacheModel("models/combine_super_soldier.mdl");
	PrecacheModel("models/effects/combineball.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Infected Elite");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_combine_soldier_elite");
	strcopy(data.Icon, sizeof(data.Icon), "combine_elite");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSCombineElite(vecPos, vecAng, team);
}
methodmap ZSCombineElite < CClotBody
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
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
		
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
	
	
	public ZSCombineElite(float vecPos[3], float vecAng[3], int ally)
	{
		ZSCombineElite npc = view_as<ZSCombineElite>(CClotBody(vecPos, vecAng, "models/combine_super_soldier.mdl", "1.15", "1500", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_IDLE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		
		func_NPCDeath[npc.index] = ZSCombineElite_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZSCombineElite_OnTakeDamage;
		func_NPCThink[npc.index] = ZSCombineElite_ClotThink;
	
		npc.m_fbGunout = false;
		
		npc.m_iState = 0;
		npc.m_flSpeed = 260.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_flAttackHappenswillhappen = false;
		npc.m_bmovedelay = false;
		
		npc.m_iAttacksTillReload = 30;

		npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_irifle.mdl");
		SetVariantString("1.15");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.StartPathing();
		
		return npc;
	}
	
}


public void ZSCombineElite_ClotThink(int iNPC)
{
    ZSCombineElite npc = view_as<ZSCombineElite>(iNPC);
    
    // 1. 기본 지연 및 업데이트
    if(npc.m_flNextDelayTime > GetGameTime(npc.index)) return;
    npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
    npc.Update();
    
    // 2. 부상 애니메이션
    if(npc.m_blPlayHurtAnimation)
    {
        npc.AddGesture("ACT_GESTURE_FLINCH_STOMACH", false);
        npc.m_blPlayHurtAnimation = false;
        npc.PlayHurtSound();
    }
    
    // 3. AI 판단 지연 (0.1초)
    if(npc.m_flNextThinkTime > GetGameTime(npc.index)) return;
    npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

    // 4. 타겟팅
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
        
        // --- 거리 기준 정의 ---
        bool bInMeleeRange = (flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED);
        bool bInRetreatRange = (flDistanceToTarget < 62500.0); // 약 250 unit
        bool bInShootRange = (flDistanceToTarget < 122500.0);  // 약 350 unit
        bool bIsReloading = (npc.m_flReloadDelay > GetGameTime(npc.index));

        // --- A. 이동 및 애니메이션 상태 제어 ---
        if (bIsReloading)
        {
            npc.m_flSpeed = 0.0;
            npc.StopPathing();
            // 재장전 애니메이션은 공격 로직에서 Gesture로 처리되므로 별도 Activity 불필요
        }
        else if (bInMeleeRange)
        {
            // 근접 추격 모드
            npc.m_flSpeed = 260.0;
            npc.StartPathing();
            npc.SetGoalEntity(PrimaryThreatIndex);
            npc.m_fbGunout = false;

            if (npc.m_bmovedelay) // 상태가 바뀔 때만 애니메이션 재생
            {
                int act = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
                if(act > 0) npc.StartActivity(act);
                npc.m_bmovedelay = false; 
            }
        }
        else if (bInRetreatRange)
        {
            // 후퇴(Kiting) 모드
            npc.m_flSpeed = 160.0; // 후퇴는 자연스럽게 속도 하향
            float vRetreatPos[3], vDir[3];
            MakeVectorFromPoints(vecTarget, VecSelfNpc, vDir);
            NormalizeVector(vDir, vDir);
            ScaleVector(vDir, 250.0);
            AddVectors(VecSelfNpc, vDir, vRetreatPos);
            
            npc.SetGoalVector(vRetreatPos);
            npc.StartPathing();
            npc.m_fbGunout = true;

            if (npc.m_bmovedelay) 
            {
                int act = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
                if(act > 0) npc.StartActivity(act);
                npc.m_bmovedelay = false;
            }
        }
        else if (bInShootRange)
        {
            // 제자리 사격 모드
            npc.m_flSpeed = 0.0;
            npc.StopPathing();
            npc.m_fbGunout = true;

            if (!npc.m_bmovedelay) 
            {
                int act = npc.LookupActivity("ACT_IDLE_ANGRY");
                if(act > 0) npc.StartActivity(act);
                npc.m_bmovedelay = true;
            }
        }
        else 
        {
            // 원거리 추격 모드
            npc.m_flSpeed = 260.0;
            npc.StartPathing();
            npc.SetGoalEntity(PrimaryThreatIndex);
            npc.m_fbGunout = false;

            if (npc.m_bmovedelay) 
            {
                int act = npc.LookupActivity("ACT_RUN_AIM_RIFLE");
                if(act > 0) npc.StartActivity(act);
                npc.m_bmovedelay = false;
            }
        }

        // --- B. 공격 실행 로직 ---
        if (!bIsReloading)
        {
            // 1. 근접 공격
            if(bInMeleeRange || npc.m_flAttackHappenswillhappen)
            {
                if (!npc.m_flAttackHappenswillhappen)
                {
                    npc.AddGesture("ACT_MELEE_ATTACK1");
                    npc.PlayMeleeSound();
                    npc.m_flAttackHappens = GetGameTime(npc.index) + 0.4;
                    npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 0.54;
                    npc.m_flAttackHappenswillhappen = true;
                }
                
                if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index))
                {
                    Handle swingTrace;
                    npc.FaceTowards(vecTarget, 20000.0);
                    if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
                    {
                        int target = TR_GetEntityIndex(swingTrace);    
                        if(target > 0) 
                        {
                            SDKHooks_TakeDamage(target, npc.index, npc.index, 60.0, DMG_CLUB, -1, _, vecTarget);
                            Custom_Knockback(npc.index, target, 250.0);
                            npc.PlayMeleeHitSound();
                        } 
                    }
                    delete swingTrace;
                    npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
                    npc.m_flAttackHappenswillhappen = false;
                }
                else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index))
                {
                    npc.m_flAttackHappenswillhappen = false;
                }
            }
            // 2. 원거리 사격 (총을 꺼낸 상태일 때만)
            else if (npc.m_fbGunout)
            {
                npc.FaceTowards(vecTarget, 10000.0);

                // 특수 공격 (로켓)
                if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
                {
                    float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
                    npc.FireRocket(vPredictedPos, 15.0, 400.0, "models/effects/combineball.mdl");
                    npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 9.0;
                    npc.PlayRangedAttackSecondarySound();
                }

                // 일반 사격
                if(npc.m_flNextRangedAttack < GetGameTime(npc.index) && Can_I_See_Enemy(npc.index, PrimaryThreatIndex) > 0)
                {
                    npc.m_flNextRangedAttack = GetGameTime(npc.index) + 0.15;
                    npc.m_iAttacksTillReload -= 1;
                    
                    if (npc.m_iAttacksTillReload <= 0)
                    {
                        npc.AddGesture("ACT_RELOAD");
                        npc.m_flReloadDelay = GetGameTime(npc.index) + 2.2;
                        npc.m_iAttacksTillReload = 30;
                        npc.PlayRangedReloadSound();
                    }
                    else
                    {
                        npc.AddGesture("ACT_GESTURE_RANGE_ATTACK_AR2");
                        // 사격 탄퍼짐 및 발사 로직
                        float x = GetRandomFloat(-0.15, 0.15) + GetRandomFloat(-0.15, 0.15);
                        float y = GetRandomFloat(-0.15, 0.15) + GetRandomFloat(-0.15, 0.15);
                        float vecDirShooting[3], vecRight[3], vecUp[3], vecDir[3], eyePitch[3], SelfVecPos[3];
                        
                        GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
                        WorldSpaceCenter(npc.index, SelfVecPos);
                        vecTarget[2] += 15.0;
                        MakeVectorFromPoints(SelfVecPos, vecTarget, vecDirShooting);
                        GetVectorAngles(vecDirShooting, vecDirShooting);
                        vecDirShooting[1] = eyePitch[1];
                        GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
                        
                        vecDir[0] = vecDirShooting[0] + x * 0.1 * vecRight[0] + y * 0.1 * vecUp[0]; 
                        vecDir[1] = vecDirShooting[1] + x * 0.1 * vecRight[1] + y * 0.1 * vecUp[1]; 
                        vecDir[2] = vecDirShooting[2] + x * 0.1 * vecRight[2] + y * 0.1 * vecUp[2]; 
                        NormalizeVector(vecDir, vecDir);
                        
                        FireBullet(npc.index, npc.m_iWearable1, SelfVecPos, vecDir, 10.0, 9000.0, DMG_BULLET, "bullet_tracer01_red");
                        npc.PlayRangedSound();
                    }
                }
            }
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


public Action ZSCombineElite_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ZSCombineElite npc = view_as<ZSCombineElite>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ZSCombineElite_NPCDeath(int entity)
{
	ZSCombineElite npc = view_as<ZSCombineElite>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}