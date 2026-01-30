#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/soldier_paincrticialdeath01.mp3",
	"vo/soldier_paincrticialdeath02.mp3",
	"vo/soldier_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts14.mp3",
	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
	"vo/taunts/soldier_taunts18.mp3",
};

static const char g_RangeAttackSounds[] = "weapons/rocket_shoot.wav";

void Allysoldier_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Freedom Feathers");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_ally_soldier");
	strcopy(data.Icon, sizeof(data.Icon), "soldier");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSound(g_RangeAttackSounds);
	PrecacheModel("models/player/soldier.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Allysoldier(vecPos, vecAng, team);
}
methodmap Allysoldier < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	
	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	
	public void PlayRangeSound() {
		EmitSoundToAll(g_RangeAttackSounds, this.index, SNDCHAN_STATIC, 80, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	
	public Allysoldier(float vecPos[3], float vecAng[3], int ally)
	{
		Allysoldier npc = view_as<Allysoldier>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.0", "200", ally, true, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = Allysoldier_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Allysoldier_OnTakeDamage;
		func_NPCThink[npc.index] = Allysoldier_ClotThink;		
		
		//IDLE
		npc.m_bThisEntityIgnored = true;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.m_flSpeed = 240.0;
		npc.m_iMaxAmmo = 1;
		npc.m_iAmmo = 1;
		npc.m_bScalesWithWaves = false;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/soldier/hw2013_feathered_freedom/hw2013_feathered_freedom.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_buffpack/c_buffpack.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/weapons/c_models/c_buffbanner/c_buffbanner.mdl");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 0);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 0);
		
		if(npc.m_bScalesWithWaves)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 125);
		}
		
		return npc;
	}
}

#define ALLYSOLDIER_RANGE 350.0

static void Allysoldier_ClotThink(int iNPC)
{
	Allysoldier npc = view_as<Allysoldier>(iNPC);
	float gametime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > gametime)
		return;
	npc.m_flNextDelayTime = gametime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	//float Range = ALLYSOLDIER_RANGE;
	//spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 200, 80, 150, 1, 0.1, 3.0, 0.1, 3);	
	//spawnRing_Vectors(VecSelfNpcabs, Range * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 200, 1, /*duration*/ 0.11, 3.0, 5.0, 1);
	
	npc.Update();
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > gametime)
		return;
	npc.m_flNextThinkTime = gametime + 0.1;
	
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	Allysoldier_ApplyBuffInLocation_Optimized(VecSelfNpcabs, GetTeam(npc.index), npc.index);
	
	int ally = npc.m_iTargetWalkTo;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gametime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		npc.m_flGetClosestTargetTime = gametime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		switch(Allysoldier_Work(npc,gametime,npc.m_iTarget,flDistanceToTarget,vecTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
				}
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_STAND_PRIMARY");
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.m_flSpeed = 240.0;
					npc.StartPathing();
				}
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
			}
		}
	}
	else
	{
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget > 25000.0)
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
				return;
			}
		}

		npc.StopPathing();
		npc.m_flGetClosestTargetTime = 0.0;
	}
	npc.PlayIdleAlertSound();
}

static int Allysoldier_Work(Allysoldier npc, float gameTime, int target, float distance, float vecTarget[3])
{
	if(npc.m_flAttackHappens || !npc.m_iAmmo)
	{
		if(!npc.m_flAttackHappens)
		{
			npc.m_flAttackHappens=gameTime+1.0;
			npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY", true,_,_,1.1);
			npc.m_flAttackHappenswillhappen=false;
			//npc.PlayReloadSound();
		}
		if(gameTime > npc.m_flAttackHappens)
		{
			npc.m_iAmmo = npc.m_iMaxAmmo;
			npc.m_flAttackHappens=0.0;
		}
	}
	if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0) || npc.m_flAttackHappenswillhappen)
	{
		int Enemy_I_See = Can_I_See_Enemy(npc.index, target);
		if((gameTime > npc.m_flNextRangedAttack && IsValidEnemy(npc.index, Enemy_I_See)) || npc.m_flAttackHappenswillhappen)
		{
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", true);
			float ProjectileSpeed = 700.0;
			WorldSpaceCenter(Enemy_I_See, vecTarget);
			PredictSubjectPositionForProjectiles(npc, target, ProjectileSpeed, _,vecTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			npc.FireRocket(vecTarget, 270.0, ProjectileSpeed);
			npc.PlayRangeSound();

			npc.m_flNextRangedAttack=gameTime + 2.0;
			npc.m_flAttackHappenswillhappen = true;
			npc.m_iAmmo--;
		}
	}
	if(distance > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0)||ShouldNpcDealBonusDamage(target))
	{
		return 0;
	}
	else if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
	{
		if(Can_I_See_Enemy_Only(npc.index, target))
		{
			return 2;
		}
	}
	return 1;
}

void Allysoldier_ApplyBuffInLocation_Optimized(float BannerPos[3], int Team, int iMe = 0)
{
    // 거리 제곱값을 미리 상수로 계산 (루프 밖에서 1번만)
    float rangeSq = ALLYSOLDIER_RANGE * ALLYSOLDIER_RANGE; 
    float targPos[3];

    // 1. 플레이어 루프
    for(int ally=1; ally<=MaxClients; ally++)
    {
        if(IsClientInGame(ally) && IsPlayerAlive(ally) && GetTeam(ally) == Team)
        {
            GetClientAbsOrigin(ally, targPos);
            // 단순 X, Y 거리 필터링 (선택 사항)
            if (FloatAbs(BannerPos[0] - targPos[0]) > ALLYSOLDIER_RANGE) continue; 
            
            if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
            {
                ApplyStatusEffect(ally, ally, "Ally Empowerment", 1.0);
            }
        }
    }

    // 2. NPC 루프 (초기화 및 활성 카운트 적용)
    for(int i = 0; i < i_MaxcountNpcTotal; i++) // 0으로 명확히 초기화
    {
        int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
        
        // 유효성 검사를 먼저 수행하여 무거운 연산을 피함
        if (ally != -1 && IsValidEntity(ally) && !b_NpcHasDied[ally] && GetTeam(ally) == Team && iMe != ally)
        {
            GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
            if (GetVectorDistance(BannerPos, targPos, true) <= rangeSq)
            {
                ApplyStatusEffect(ally, ally, "Ally Empowerment", 1.0);
            }
        }
    }
}

static Action Allysoldier_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Allysoldier npc = view_as<Allysoldier>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Allysoldier_NPCDeath(int entity)
{
	Allysoldier npc = view_as<Allysoldier>(entity);
	if(!npc.m_bGib)
		npc.PlayDeathSound();	
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}