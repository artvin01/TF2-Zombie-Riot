#pragma semicolon 1
#pragma newdecls required


static const char g_WalkStepSound[][] = {
	"zombie_riot/nothing_there/nt_step.mp3",
};
static const char g_Spawn[][] = {
	"zombie_riot/nothing_there/nt_spawn.mp3",
};
static const char g_Ambience[][] = {
	"zombie_riot/nothing_there/nt_ambience.mp3",
};
static const char g_AttackSound_1[][] = {
	"zombie_riot/nothing_there/nt_attack1.mp3",
};
static const char g_AttackSound_3[][] = {
	"zombie_riot/nothing_there/nt_attack3.mp3",
};
static const char g_HitSound_1[][] = {
	"zombie_riot/nothing_there/nt_skill1_hit.mp3",
};
static const char g_HitSound_2[][] = {
	"zombie_riot/nothing_there/nt_skill2_hit.mp3",
};
static const char g_HitSound_3[][] = {
	"zombie_riot/nothing_there/nt_skill3_hit.mp3",
};

static int NPCID;
static bool HasNT;
void Nothing_There_OnMapStart_NPC()
{
	HasNT = false;
	//model doesnt exist, fail it.
	if(!PrecacheModel("models/slender/stone_m/nothing/nt_normal_v3.mdl"))
		return;

	HasNT = true;
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nothing There");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_nothing_there");
	strcopy(data.Icon, sizeof(data.Icon), "nothing_there");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCID = NPC_Add(data);
}

bool HasNTOnServer()
{
	return HasNT;
}
bool GetNTBuff(int client)
{
	if(IsValidEntity(RaidBossActive))
	{
		if(i_NpcInternalId[EntRefToEntIndex(RaidBossActive)] == NPCID)
			return true;
	}
	if(Store_HasNamedItem(client, "E.G.O. Mimicry Shell"))
		return true;

	return false;
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_WalkStepSound)); i++) { PrecacheSoundCustom(g_WalkStepSound[i]); }
	for (int i = 0; i < (sizeof(g_Spawn)); i++) { PrecacheSoundCustom(g_Spawn[i]); }
	for (int i = 0; i < (sizeof(g_Ambience)); i++) { PrecacheSoundCustom(g_Ambience[i]); }
	for (int i = 0; i < (sizeof(g_AttackSound_1)); i++) { PrecacheSoundCustom(g_AttackSound_1[i]); }
	for (int i = 0; i < (sizeof(g_AttackSound_3)); i++) { PrecacheSoundCustom(g_AttackSound_3[i]); }
	for (int i = 0; i < (sizeof(g_HitSound_1)); i++) { PrecacheSoundCustom(g_HitSound_1[i]); }
	for (int i = 0; i < (sizeof(g_HitSound_2)); i++) { PrecacheSoundCustom(g_HitSound_2[i]); }
	for (int i = 0; i < (sizeof(g_HitSound_3)); i++) { PrecacheSoundCustom(g_HitSound_3[i]); }
	PrecacheSoundCustom("zombie_riot/nothing_there/rabbit_team_aleart.mp3");
	PrecacheSoundCustom("#zombie_riot/nothing_there/second_warning_fix.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Nothing_There(vecPos, vecAng, team);
}

methodmap Nothing_There < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitCustomToAll(g_Ambience[GetRandomInt(0, sizeof(g_Ambience) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(48.0, 72.0);
	}
	public void PlayStepSound() 
	{
		EmitCustomToAll(g_WalkStepSound[GetRandomInt(0, sizeof(g_WalkStepSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll(g_WalkStepSound[GetRandomInt(0, sizeof(g_WalkStepSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll(g_WalkStepSound[GetRandomInt(0, sizeof(g_WalkStepSound) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlaySpawnSound() 
	{
		EmitCustomToAll(g_Spawn[GetRandomInt(0, sizeof(g_Spawn) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAttackSound2() 
	{
		EmitCustomToAll(g_AttackSound_1[GetRandomInt(0, sizeof(g_AttackSound_1) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAttackSound3() 
	{
		EmitCustomToAll(g_AttackSound_3[GetRandomInt(0, sizeof(g_AttackSound_3) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHitSound1() 
	{
		EmitCustomToAll(g_HitSound_1[GetRandomInt(0, sizeof(g_HitSound_1) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHitSound2() 
	{
		EmitCustomToAll(g_HitSound_2[GetRandomInt(0, sizeof(g_HitSound_2) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHitSound3() 
	{
		EmitCustomToAll(g_HitSound_3[GetRandomInt(0, sizeof(g_HitSound_3) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	

	property float m_flRangeSpikeAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flRangeSpikeDoing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flGoodbyeAttack
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flGoodbyeDoing
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	property float m_flStepDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][4]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][4] = TempValueForProperty; }
	}
	property float m_flSpawnRabitProtocol
	{
		public get()							{ return fl_AbilityOrAttack[this.index][5]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][5] = TempValueForProperty; }
	}
	
	public Nothing_There(float vecPos[3], float vecAng[3], int ally)
	{
		ally = TFTeam_Stalkers;
		Nothing_There npc = view_as<Nothing_There>(CClotBody(vecPos, vecAng, "models/slender/stone_m/nothing/nt_normal_v3.mdl", "1.5", MinibossHealthScaling(250.0), ally, false, true, true));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_WHITEFLOWER_IDLE");
		
		
		
		npc.m_flNextMeleeAttack = 0.0;
		for(int client1 = 1; client1 <= MaxClients; client1++)
		{
			if(!b_IsPlayerABot[client1] && IsClientInGame(client1) && !IsFakeClient(client1))
			{
				SetMusicTimer(client1, GetTime() + 1); //This is here beacuse of raid music.
				Music_Stop_All(client1);
			}
		}
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombie_riot/nothing_there/second_warning_fix.mp3");
		music.Time = 172;
		music.Volume = 1.1;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Second Warning");
		strcopy(music.Artist, sizeof(music.Artist), "Lobotomy Corporation");
		Music_SetRaidMusic(music);
		KillFeed_SetKillIcon(npc.index, "the_maul");

		npc.m_flRangeSpikeAttack = GetGameTime() + 3.5;
		npc.m_flGoodbyeAttack = GetGameTime() + 5.5;
		npc.PlaySpawnSound();


		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;
		npc.m_bDissapearOnDeath = true;

		func_NPCDeath[npc.index] = view_as<Function>(Nothing_There_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Nothing_There_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Nothing_There_ClotThink);
		
		float wave = float(Waves_GetRoundScale()+1);
		wave *= 0.133333;
		npc.m_flWaveScale = wave;
		npc.m_flWaveScale *= MinibossScalingReturn();
		npc.m_flDoingAnimation = 1.0;
		b_thisNpcIsAMiniboss[npc.index] = true;
		b_thisNpcIsABoss[npc.index] = true;
		fl_TotalArmor[npc.index] = 0.2;
	//	b_thisNpcIsARaid[npc.index] = true;
		npc.m_flSpawnRabitProtocol = GetGameTime() + GetRandomFloat( 10.0 , 15.0);
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 9000.0;
			RaidModeScaling = 0.0;
			RaidAllowsBuildings = false;
			RaidAllowLastman = false;
		}
		
		
		npc.StartPathing();
		npc.m_flSpeed = 370.0;
		RaidModeTime = FAR_FUTURE;
		
		return npc;
	}
}

public void Nothing_There_ClotThink(int iNPC)
{
	Nothing_There npc = view_as<Nothing_There>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	if(npc.Anger)
		return;

	if(LastMann)
	{
		SPrintToChatAll("%t", "NT Retry Day");
		npc.Anger = true;
		RequestFrame(KillNpc, EntIndexToEntRef(iNPC));
		
		int entity = -1;
		int a;
		while((entity = FindEntityByNPC(a)) != -1)
		{
			if(IsValidEntity(entity) && Citizen_IsIt(entity) && b_Anger[entity])
			{
				RequestFrame(KillNpc, EntIndexToEntRef(entity));
			}
		}
		return;
	}
	
	if(npc.m_flSpawnRabitProtocol && npc.m_flSpawnRabitProtocol < GetGameTime())
	{
		npc.m_flSpawnRabitProtocol = 0.0;
		EmitCustomToAll("zombie_riot/nothing_there/rabbit_team_aleart.mp3");
		StartZombieRiotFrame(true);
		for (int client_Hud = 1; client_Hud <= MaxClients; client_Hud++)
		{
			if (IsValidClient(client_Hud) && IsPlayerAlive(client_Hud) && GetClientTeam(client_Hud) == view_as<int>(TFTeam_Red))
			{
				SetHudTextParams(-1.0, 0.30, 3.01, 255, 125, 0, 255);
				SetGlobalTransTarget(client_Hud);
				ShowHudText(client_Hud,  -1, "%t", "Rabbit Protocol");
			}
		}
	}
	if(npc.m_flDoingAnimation)
	{
		if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			npc.StartPathing();
			npc.m_flSpeed = 370.0;
			npc.m_bisWalking = false;
			npc.m_flDoingAnimation = 0.0;
			npc.AddActivityViaSequence("nt_walk4");
			npc.SetPlaybackRate(2.0);
			npc.m_flStepDelay = 0.0;
		}
	}
	else
	{
		if(npc.m_flStepDelay < GetGameTime(npc.index))
		{
			npc.m_flStepDelay = GetGameTime(npc.index) + 0.35;
			npc.PlayStepSound();
		}
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	int target = npc.m_iTarget;
	if(i_Target[npc.index] != -1 && !IsValidEnemy(npc.index, target))
		i_Target[npc.index] = -1;
	
	if(i_Target[npc.index] == -1 || npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		target = GetClosestTarget(npc.index);
		npc.m_iTarget = target;
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
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		Nothing_ThereSelfDefense(npc,GetGameTime(npc.index), flDistanceToTarget); 
	}
	npc.PlayIdleAlertSound();
}

public Action Nothing_There_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker <= 0)
		return Plugin_Continue;
	
	return Plugin_Changed;
}

public void Nothing_There_NPCDeath(int entity)
{
	Nothing_There npc = view_as<Nothing_There>(entity);

	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);

	if(EntIndexToEntRef(entity) == RaidBossActive)
		RaidBossActive = INVALID_ENT_REFERENCE;

	if(!npc.Anger)
	{
		SpawnMoney(npc.index);
		SpawnMoney(npc.index);
		SpawnMoney(npc.index);
		Store_DiscountNamedItem("E.G.O. Mimicry Shell", 999, 0.6);
		CPrintToChatAll("{crimson}%t" , "NT Death Msg");
		SPrintToChatAll("%t: {crimson}%t","Unlocked", "E.G.O. Mimicry Shell");
	}
	RaidTimerAlert = true;
}

void Nothing_ThereSelfDefense(Nothing_There npc, float gameTime, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);

							float damage = 150.0;
							damage *= npc.m_flWaveScale;
							if(GetTeam(target) != TFTeam_Red)
							{
								damage *= 50.0;
							}
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);							

							Custom_Knockback(npc.index, target, 400.0, true);
						}
					}
				}
				if(PlaySound)
				{
					npc.PlayHitSound1();
				}
				else
				{
					npc.m_flRangeSpikeAttack -= 2.0;
				}
				delete swingTrace;
			}
		}
	}

	if(!npc.m_flDoingAnimation && gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
						
				npc.m_flAttackHappens = gameTime + 0.35;
				npc.m_flDoingAnimation = gameTime + 0.4;
				npc.m_flNextMeleeAttack = gameTime + 0.75;
				NothingThere_AnimateActivity(npc, "nt_attack2");
			}
		}
	}

	if(npc.m_flRangeSpikeDoing)
	{
		float projectile_speed = 3000.0;
		float vPredictedPos[3];
		PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, projectile_speed, _,vPredictedPos);
		npc.FaceTowards(vPredictedPos, 30000.0);
		if(npc.m_flRangeSpikeDoing < gameTime)
		{
			npc.m_flRangeSpikeDoing = 0.0;
			NothingThere_AnimateActivity(npc, "nt_hello_shoot");
			npc.m_flDoingAnimation = gameTime + 0.6;
			//do ranged attack
			int entity = npc.FireParticleRocket(vPredictedPos, 700.0 * npc.m_flWaveScale, projectile_speed, 100.0, "raygun_projectile_red");	
			int trail = Trail_Attach(entity, ARROW_TRAIL_RED, 175, 0.25, 20.0, 20.0, 5);
			i_WandParticle[entity] = EntIndexToEntRef(trail);
		}
	}
			
	
	if(!npc.m_flDoingAnimation && gameTime > npc.m_flRangeSpikeAttack)
	{
	//	if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
						
				npc.m_flRangeSpikeDoing = gameTime + 0.5;
				npc.m_flDoingAnimation = gameTime + 0.6;
				npc.m_flRangeSpikeAttack = gameTime + 12.0;
				NothingThere_AnimateActivity(npc, "nt_hello_begin");
				npc.PlayAttackSound2();
			}
		}
	}

	
	if(npc.m_flGoodbyeDoing)
	{
		if(npc.m_flGoodbyeDoing < gameTime)
		{
			npc.m_flGoodbyeDoing = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);

							float damage = 2000.0;
							damage *= npc.m_flWaveScale;
							if(GetTeam(target) != TFTeam_Red)
							{
								damage *= 50.0;
							}
							
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);							

							Custom_Knockback(npc.index, target, 900.0, true);
							if(i_BleedType[target] == 0)
								i_BleedType[target] = 1;
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
							Npc_DoGibLogic(target, 0.0, true);
						}
					}
				}
				if(PlaySound)
				{
					npc.PlayHitSound3();
				}
				else
				{
					npc.m_flRangeSpikeAttack -= 2.0;
				}
				delete swingTrace;
			}
		}
	}

	if(!npc.m_flDoingAnimation && gameTime > npc.m_flGoodbyeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
					
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
						
				npc.m_flGoodbyeDoing = gameTime + 0.5;
				npc.m_flDoingAnimation = gameTime + 1.25;
				npc.m_flGoodbyeAttack = gameTime + 10.0;
				NothingThere_AnimateActivity(npc, "nt_attack3");
				npc.m_flSpeed = 75.0;
				npc.SetPlaybackRate(1.35);
				npc.PlayAttackSound3();
			}
		}
	}
}



void NothingThere_AnimateActivity(Nothing_There npc, const char[] WalkAnimDo)
{
	npc.AddActivityViaSequence(WalkAnimDo);
//	npc.StopPathing();
	npc.m_flSpeed = 150.0;
	npc.m_bisWalking = false;
	npc.SetPlaybackRate(2.5);
}