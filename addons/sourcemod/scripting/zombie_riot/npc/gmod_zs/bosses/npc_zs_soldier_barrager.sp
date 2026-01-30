#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/Soldier_paincrticialdeath01.mp3",
	"vo/Soldier_paincrticialdeath02.mp3",
	"vo/Soldier_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/Soldier_painsharp01.mp3",
	"vo/Soldier_painsharp02.mp3",
	"vo/Soldier_painsharp03.mp3",
	"vo/Soldier_painsharp04.mp3",
	"vo/Soldier_painsharp05.mp3",
	"vo/Soldier_painsharp06.mp3",
	"vo/Soldier_painsharp07.mp3",
	"vo/Soldier_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/taunts/Soldier_taunts01.mp3",
	"vo/taunts/Soldier_taunts09.mp3",
	"vo/taunts/Soldier_taunts14.mp3",
	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/Soldier_taunts19.mp3",
	"vo/taunts/Soldier_taunts20.mp3",
	"vo/taunts/Soldier_taunts21.mp3",
	"vo/taunts/Soldier_taunts18.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/bat_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/rocket_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static const char g_RangedReloadSound[][] = {
	"weapons/dumpster_rocket_reload.wav",
};

void ZsSoldier_Barrager_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheModel("models/player/Soldier.mdl");

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Colonel Barrage");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_soldier_barrager");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_colonel");
	data.Category = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Func = ClotSummon;
	data.IconCustom = true;													//download needed?
	data.Flags = 0;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZsSoldier_Barrager(vecPos, vecAng, team);
}

methodmap ZsSoldier_Barrager < CClotBody
{
	property int m_iAmmo
	{
		public get()							{ return i_ammo_count[this.index]; }
		public set(int TempValueForProperty) 	{ i_ammo_count[this.index] = TempValueForProperty; }
	}
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
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 80, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, GetRandomInt(NORMAL_ZOMBIE_SOUNDLEVEL, 100));
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	public ZsSoldier_Barrager(float vecPos[3], float vecAng[3], int ally)
	{
		ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(CClotBody(vecPos, vecAng, "models/player/Soldier.mdl", "1.15", "45000", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_flMeleeArmor = 2.0;
		npc.m_flRangedArmor = 0.5;
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = true;
		}
		
		//IDLE
		npc.m_flSpeed = 270.0;
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iAmmo=0;
		b_we_are_reloading[npc.index]=false;
		fl_ruina_in_combat_timer[npc.index] = 2.0 + GetGameTime(npc.index);
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_dumpster_device/c_dumpster_device.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/Soldier/Soldier_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2023_shortness_breath/hwn2023_shortness_breath.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/sum23_stealth_bomber_style1/sum23_stealth_bomber_style1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.StartPathing();
		
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(iNPC);

	float GameTime= GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(!IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.PlayIdleAlertSound();
		return;
	}
		
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

	//Predict their pos.
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
		npc.SetGoalVector(vPredictedPos);
	}
	else
	{
		npc.SetGoalEntity(PrimaryThreatIndex);
	}

	int max_ammo = 30;
    // bool close = (flDistanceToTarget < 60000); // 1. 거리 체크 변수 제거 (필요 시 주석 처리)
    
    // 장전 상태 결정: 탄약이 0이면 무조건 장전 모드로 진입
    if(npc.m_iAmmo <= 0 && !b_we_are_reloading[npc.index])
    {
        b_we_are_reloading[npc.index] = true;
    }

    // 2. 긴급 장전 조건(close && npc.m_iAmmo<=0)이 제거된 장전 실행 로직
    if(b_we_are_reloading[npc.index] && npc.m_flReloadIn < GameTime)
    {
        npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
        npc.m_flReloadIn = 0.2 + GameTime;
        npc.m_iAmmo++;
        npc.m_flNextMeleeAttack = GameTime + 0.2;
        npc.PlayRangedReloadSound();
    }

    // 비전투 중 자동 장전 로직 (유지)
    if(fl_ruina_in_combat_timer[npc.index] <= GameTime && npc.m_flReloadIn < GameTime && !b_we_are_reloading[npc.index] && npc.m_iAmmo < max_ammo)
    {
        npc.AddGesture("ACT_MP_RELOAD_STAND_PRIMARY");
        npc.m_flReloadIn = 0.2 + GameTime;
        npc.m_iAmmo++;
        npc.m_flNextMeleeAttack = GameTime + 0.2;
        npc.PlayRangedReloadSound();
    }

    if(npc.m_iAmmo >= max_ammo)
    {
        b_we_are_reloading[npc.index] = false;
    }

    // 3. 후퇴 로직 수정: 이제 적과의 거리에 상관없이(close 조건 제거) 탄약이 없으면 후퇴함
    if(npc.m_iAmmo <= 0 || b_we_are_reloading[npc.index])
    {
        npc.StartPathing();
        npc.m_flSpeed = 400.0;
        
        int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
        if(IsValidEnemy(npc.index, Enemy_I_See))
        {
            float vBackoffPos[3];
            BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
            npc.SetGoalVector(vBackoffPos, true);
        }
    }
    else if(flDistanceToTarget < 1080000 && npc.m_iAmmo > 0) 
    {
        npc.m_flSpeed = 270.0;
        fl_ruina_in_combat_timer[npc.index] = 2.5 + GameTime;
        
        int Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
        
        if(IsValidEnemy(npc.index, Enemy_I_See))
        {	
            // [추가/수정] 만약 적과의 거리가 원래 사정거리(120,000)보다 가까우면 뒤로 물러나며 공격
            if(flDistanceToTarget < 120000)
            {
                float vBackoffPos[3];
                BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex, _, vBackoffPos);
                npc.SetGoalVector(vBackoffPos, true);
            }
            
            npc.StartPathing();

            if(npc.m_flNextMeleeAttack < GameTime)
            {
                npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
                PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, 750.0, _, vecTarget);
                npc.FaceTowards(vecTarget, 20000.0);
                npc.PlayMeleeSound();
                
                float dmg = 200.0;
                npc.FireRocket(vecTarget, dmg, 750.0); // 로켓 발사 
                
                npc.m_flNextMeleeAttack = GameTime + 0.2;
                npc.m_flReloadIn = GameTime + 1.75;
                npc.m_iAmmo--;
            }
        }
    }
	else
	{
		npc.StartPathing();
	}
}


static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	ZsSoldier_Barrager npc = view_as<ZsSoldier_Barrager>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
}