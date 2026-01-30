#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/heavy_paincrticialdeath01.mp3",
	"vo/heavy_paincrticialdeath02.mp3",
	"vo/heavy_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/heavy_painsharp01.mp3",
	"vo/heavy_painsharp02.mp3",
	"vo/heavy_painsharp03.mp3",
	"vo/heavy_painsharp04.mp3",
	"vo/heavy_painsharp05.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/heavy_taunts16.mp3",
	"vo/taunts/heavy_taunts18.mp3",
	"vo/taunts/heavy_taunts19.mp3",
};


void Allyheavy_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheModel("models/player/heavy.mdl");
	PrecacheSound("weapons/minigun_spin.wav");
	PrecacheSound("weapons/minigun_shoot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "The Chicken Kiev");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_ally_heavy");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);

}
#define ALLYHEAVY_RANGE 350.0
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Allyheavy(vecPos, vecAng, team);
}

methodmap Allyheavy < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
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

	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				//StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
				//EmitSoundToAll("weapons/minigun_shoot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				//StopSound(this.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
				//EmitSoundToAll("weapons/minigun_spin.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.70);
			}
			this.i_GunMode = 1;
		}
	}

	public Allyheavy(float vecPos[3], float vecAng[3], int ally)
	{
		Allyheavy npc = view_as<Allyheavy>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "300", ally, true, false));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_DEPLOYED_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		func_NPCDeath[npc.index] = Allyheavy_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Allyheavy_OnTakeDamage;
		func_NPCThink[npc.index] = Allyheavy_ClotThink;
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);

		npc.StartPathing();
		npc.m_flSpeed = 230.0;
		npc.m_bThisEntityIgnored = true;
		b_NpcIsInvulnerable[npc.index] = true;
		npc.m_bScalesWithWaves = false;
		
		int skin = 0;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_minigun/c_minigun_natascha.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/hw2013_heavy_robin/hw2013_heavy_robin.mdl");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/heavy/xms_heavy_sandvichsafe.mdl");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 0);
		if(npc.m_bScalesWithWaves)
		{
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 255, 255, 255, 125);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 125);
		}

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		return npc;
	}
}

public void Allyheavy_ClotThink(int iNPC)
{
	Allyheavy npc = view_as<Allyheavy>(iNPC);
	float gametime = GetGameTime(npc.index);

	// 1. 성능 최적화: 업데이트 간격 제한
	if(npc.m_flNextDelayTime > gametime)
	{
		return;
	}
	npc.m_flNextDelayTime = gametime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	// 2. 시선 처리: 뒷걸음질 중이거나 적이 있을 때 응시 (미니건 조준 유지)
	if(npc.m_bAllowBackWalking || IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float WorldSpaceVec[3]; 
			WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
	}

	// 3. 부상 애니메이션 처리
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	// 4. 메인 씽크(Think) 간격 제한 (0.1초)
	if(npc.m_flNextThinkTime > gametime)
	{
		return;
	}
	npc.m_flNextThinkTime = gametime + 0.1;
	
	int ally = npc.m_iTargetWalkTo;
	
	// 5. 타겟 갱신 로직
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < gametime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index, _, _, _, _, _, _, _, 99999.9);
		npc.m_flGetClosestTargetTime = gametime + 1.0;

		ally = GetClosestAllyPlayer(npc.index);
		npc.m_iTargetWalkTo = ally;
	}
	
	// 6. 전투 및 추격 로직 (솔저 스타일의 지능형 추격 적용)
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; 
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
	
		float VecSelfNpc[3]; 
		WorldSpaceCenter(npc.index, VecSelfNpc);
		
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		// --- 시야 밖 적 추적 강화 로직 ---
		
		// 상황 1: 적이 너무 가까울 때 -> 후퇴 (시야 확보 및 거리 유지)
		if(flDistanceToTarget < (npc.GetLeadRadius() * 0.5))
		{
			npc.m_bAllowBackWalking = true;
			float vBackoffPos[3];
			BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget, _, vBackoffPos);
			npc.SetGoalVector(vBackoffPos, true);
		}
		// 상황 2: 적이 사정거리 내에 있을 때 -> 예측 지점으로 이동
		else if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			npc.m_bAllowBackWalking = false;
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		// 상황 3: 적이 멀거나 벽 뒤에 있을 때 -> 적극적 추격 (핵심 수정)
		else 
		{
			npc.m_bAllowBackWalking = false;
			// SetGoalEntity는 시야와 관계없이 적 엔티티의 위치로 경로를 생성합니다.
			npc.SetGoalEntity(npc.m_iTarget);
			npc.StartPathing(); // 경로 탐색 강제 활성화
		}

		// 공격 함수 호출 (내부에서 Can_I_See_Enemy를 체크하여 실제 사격 결정)
		AllyheavySelfDefense(npc); 
	}
	else
	{
		// 적이 없을 때 아군 플레이어를 따라가는 로직
		if(ally > 0)
		{
			float vecTarget[3]; WorldSpaceCenter(ally, vecTarget);
			float vecSelf[3]; WorldSpaceCenter(npc.index, vecSelf);
			float flDistanceToTarget = GetVectorDistance(vecTarget, vecSelf, true);

			if(flDistanceToTarget > 25000.0) // 일정한 거리 이상 떨어지면 이동
			{
				npc.SetGoalEntity(ally);
				npc.StartPathing();
				return;
			}
		}

		npc.StopPathing();
		npc.m_bAllowBackWalking = false;
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
	}

	// 대기 상태 사운드
	npc.PlayIdleAlertSound();
}

public Action Allyheavy_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Allyheavy npc = view_as<Allyheavy>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Allyheavy_NPCDeath(int entity)
{
	Allyheavy npc = view_as<Allyheavy>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_spin.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/minigun_shoot.wav");
	
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}



void AllyheavySelfDefense(Allyheavy npc)
{
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0))
	{
			npc.PlayMinigunSound(true);
			SpinSound = false;
			npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY", false);
			npc.FaceTowards(vecTarget, 20000.0);
			Handle swingTrace;
			if(npc.DoSwingTrace(swingTrace, target, { 9999.0, 9999.0, 9999.0 }))
			{
				target = TR_GetEntityIndex(swingTrace);	
					
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				float origin[3], angles[3];
				view_as<CClotBody>(npc.m_iWearable1).GetAttachment("muzzle", origin, angles);
				ShootLaser(npc.m_iWearable1, "bullet_tracer01_red", origin, vecHit, false );
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 54.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 3.0;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_BULLET, -1, _, vecHit);
					if (!IsInvuln(target) && !i_IsABuilding[target])
					{
						if(!HasSpecificBuff(target, "Fluid Movement"))
							ApplyStatusEffect(npc.index, target, "Slowdown", 1.0);
					}
				}
			}
			delete swingTrace;
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}