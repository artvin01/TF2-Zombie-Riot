#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/npc/barney/ba_ohshit03.wav",
	"vo/npc/barney/ba_no02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/barney/ba_pain01.wav",
	"vo/npc/barney/ba_pain02.wav",
	"vo/npc/barney/ba_pain03.wav",
	"vo/npc/barney/ba_pain04.wav",
	"vo/npc/barney/ba_pain05.wav",
	"vo/npc/barney/ba_pain06.wav",
	"vo/npc/barney/ba_pain07.wav",
	"vo/npc/barney/ba_pain08.wav",
	"vo/npc/barney/ba_pain09.wav",
	"vo/npc/barney/ba_pain10.wav",
};

static const char g_IdleSounds[][] = {
	"vo/npc/barney/ba_laugh01.wav",
	"vo/npc/barney/ba_laugh02.wav",
	"vo/npc/barney/ba_laugh03.wav",
	"vo/npc/barney/ba_laugh04.wav",
};

static const char g_IntroSound[][] = {
	"cof/corruptedbarney/intro1.mp3",
	"cof/corruptedbarney/intro3.mp3",
};

static char g_SpawnSounds[][] = {
	"cof/corruptedbarney/intro1.mp3",
	"cof/corruptedbarney/intro2.mp3",
	"cof/corruptedbarney/intro3.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"npc/manhack/grind_flesh1.wav",
	"npc/manhack/grind_flesh2.wav",
	"npc/manhack/grind_flesh3.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"cof/corruptedbarney/alert2.mp3",
	"cof/corruptedbarney/alert1.mp3",
};

static char g_MeleeAttackSounds[][] = {
	"cof/corruptedbarney/attacking1.mp3",
	"cof/corruptedbarney/alert1.mp3",
	"cof/corruptedbarney/attacking3.mp3",
};

void CorruptedBarney_OnMapStart_NPC()
{
	PrecacheModel("models/zombie_riot/cof/barney.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Corrupted Barney");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_corruptedbarney");
	strcopy(data.Icon, sizeof(data.Icon), "corruptedbarney");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSoundCustom(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSoundCustom(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IntroSound));	i++) { PrecacheSoundCustom(g_IntroSound[i]);	}
	for (int i = 0; i < (sizeof(g_SpawnSounds));	i++) { PrecacheSoundCustom(g_SpawnSounds[i]);	}
	PrecacheSoundCustom("#zombiesurvival/cof/barney.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return CorruptedBarney(client, vecPos, vecAng, ally, data);
}
methodmap CorruptedBarney < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitCustomToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(8.0, 16.0);
		
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return; 
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 8.0);
	}
	public void PlayIntro() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitCustomToAll(g_IntroSound[GetRandomInt(0, sizeof(g_IntroSound) - 1)], _, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + 8.0;
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}

	public void PlaySpawnSound() {
	
		EmitCustomToAll(g_SpawnSounds[GetRandomInt(0, sizeof(g_SpawnSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}

	public void PlayDeathSound() {
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}
	public void PlayMeleeSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitCustomToAll(g_MeleeAttackSounds[GetRandomInt(1, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME-0.2, 100);
		this.m_flNextHurtSound = GetGameTime(this.index) + 5.0;
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 100);
	}	
	
	public CorruptedBarney(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		CorruptedBarney npc = view_as<CorruptedBarney>(CClotBody(vecPos, vecAng, "models/zombie_riot/cof/barney.mdl", "1.0", "400", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_RUN_RIFLE_STIMULATED");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		if(npc.m_bDoSpawnGesture)
	{
		npc.PlaySpawnSound();
		npc.AddGesture("ACT_BUSY_SIT_GROUND_EXIT");
		npc.m_bDoSpawnGesture = false;
	}
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(CorruptedBarney_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(CorruptedBarney_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(CorruptedBarney_ClotThink);
		
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		npc.m_flSpeed = 360.0;
		npc.m_bDissapearOnDeath = true;
		b_thisNpcIsARaid[npc.index] = true;

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
			}
		}

		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19;
		}
		else
		{
			RaidModeScaling *= 0.38;
		}
		
		float amount_of_people = float(CountPlayersOnRed());
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;

		RaidModeScaling *= amount_of_people;
		
		if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
		{
			RaidModeScaling *= 0.85;
		}
		else if(ZR_GetWaveCount()+1 > 55)
		{
			RaidModeScaling *= 0.7;
		}

		RaidModeScaling *= 0.5;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/cof/barney.mp3");
		music.Time = 219;
		music.Volume = 1.25;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Last Legs");
		strcopy(music.Artist, sizeof(music.Artist), "Kelly Bailey");
		Music_SetRaidMusic(music);

		return npc;
	}
}

public void CorruptedBarney_ClotThink(int iNPC)
{
	CorruptedBarney npc = view_as<CorruptedBarney>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())

	if(RaidModeTime < GetGameTime())
	{
		ZR_NpcTauntWinClear();
		i_RaidGrantExtra[npc.index] = 0;
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{midnightblue}Barney{maroon}: About that beer I owed ya...");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_BIG_FLINCH", false);
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
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else 
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		CorruptedBarneySelfDefense(npc,GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget); 
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action CorruptedBarney_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	CorruptedBarney npc = view_as<CorruptedBarney>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void CorruptedBarney_NPCDeath(int entity)
{
	CorruptedBarney npc = view_as<CorruptedBarney>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}
void CorruptedBarneySelfDefense(CorruptedBarney npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;

			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			static float MaxVec[3] = {64.0 ,64.0, 128.0};
			static float MinVec[3] = {-64.0, -64.0, -128.0};

			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, MaxVec, MinVec)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
			{
				target = TR_GetEntityIndex(swingTrace);

				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);

				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 50.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 50;

					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);

					// Hit sound
					npc.PlayMeleeHitSound();
				} 
			}
			delete swingTrace;
		}
	}

	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See;

			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_SMG2_FIRE2");
				
				npc.m_flAttackHappens = gameTime + 0.15;
				npc.m_flDoingAnimation = gameTime + 0.25;
				npc.m_flNextMeleeAttack = gameTime + 0.20;
			}
		}
	}
}