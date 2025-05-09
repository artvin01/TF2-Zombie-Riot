#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
};

static const char g_HurtSound[][] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
};

static const char g_IdleSound[][] = {
	"npc/combine_soldier/vo/prison_soldier_bunker1.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker2.wav",
	"npc/combine_soldier/vo/prison_soldier_bunker3.wav"
};

static const char g_IdleAlertedSounds[][] = {
	"npc/combine_soldier/vo/prison_soldier_leader9dead.wav"
};

static const char g_RangedAttackSounds[][] = {
	"weapons/irifle/irifle_fire2.wav"
};

static const char g_RangedSpecialAttackSoundsSecondary[][] = {
	"npc/combine_soldier/vo/prison_soldier_fallback_b4.wav"
};

void RaidbossBladedance_MapStart()
{
	PrecacheModel("models/effects/combineball.mdl");
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_IdleSound));	i++) { PrecacheSound(g_IdleSound[i]);	}
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));	i++) { PrecacheSound(g_IdleAlertedSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));	i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_RangedSpecialAttackSoundsSecondary));	i++) { PrecacheSound(g_RangedSpecialAttackSoundsSecondary[i]);	}

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bladedance The Betrayed");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bladedance");
	strcopy(data.Icon, sizeof(data.Icon), "");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossBladedance(vecPos, vecAng, team, data);
}

methodmap RaidbossBladedance < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		int rand = GetRandomInt(0, sizeof(g_IdleSound) - 1);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleSound[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayKilledEnemySound() 
	{
		int rand = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IdleAlertedSounds[rand], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(5.0, 10.0);
	}
	public void PlayRangedSpecialAttackSecondarySound(const float pos[3])
	{
		int numClients;
		int[] clients = new int[MaxClients];

		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				static float pos2[3];
				GetClientEyePosition(i, pos2);
				if(GetVectorDistance(pos, pos2, true) < 2000000.0)
				{
					clients[numClients++] = i;
				}
			}
		}

		int rand = GetRandomInt(0, sizeof(g_RangedSpecialAttackSoundsSecondary) - 1);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedSpecialAttackSoundsSecondary[rand], this.index, SNDCHAN_AUTO, 130, _, BOSS_ZOMBIE_VOLUME);
	}

	public RaidbossBladedance(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossBladedance npc = view_as<RaidbossBladedance>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "1500000", ally, false));
		
		i_NpcWeight[npc.index] = 5;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

		npc.SetActivity("ACT_CUSTOM_WALK_BOW");

		func_NPCDeath[npc.index] = RaidbossBladedance_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossBladedance_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossBladedance_ClotThink;
		
		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;
		npc.m_bDissapearOnDeath = true;

		
		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		RemoveAllDamageAddition();

		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 170.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		b_thisNpcIsARaid[npc.index] = true;

		npc.Anger = false;
		npc.m_iOverlordComboAttack = 0;
		npc.m_flMeleeArmor = 0.75;
		
		Citizen_MiniBossSpawn();
		
		npc.m_iWearable1 = npc.EquipItem("partyhat", "models/player/items/spy/spy_party_phantom.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("forward", "models/workshop/player/items/all_class/fall17_jungle_wreath/fall17_jungle_wreath_spy.mdl");//"models/player/items/spy/spy_cardhat.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 55, 55, 255);

		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 55, 55, 255);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				LookAtTarget(client_check, npc.index);
		}

		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		RaidModeScaling = 0.0;
		RaidModeTime = GetGameTime() + ((300.0) * (1.0 + (MultiGlobalEnemy * 0.4)));
		Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "??????????????????????????????????");

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = true;

		return npc;
	}
}

public void RaidbossBladedance_ClotThink(int iNPC)
{
	RaidbossBladedance npc = view_as<RaidbossBladedance>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(IsValidEntity(RaidBossActive))
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > gameTime)
		return;

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_GESTURE_FLINCH_HEAD", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = gameTime + 0.05;

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)) || IsPartnerGivingUpSilvester(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime || !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}

	if(npc.Anger)
	{
		if(--npc.m_iOverlordComboAttack < 1)
			npc.Anger = false;
	}
	else if(npc.m_iOverlordComboAttack > 99)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.Anger = true;
			
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			npc.FaceTowards(vecTarget, 30000.0);
			
			npc.PlayRangedSpecialAttackSecondarySound(vecTarget);
			npc.AddGesture("ACT_METROPOLICE_POINT");
			
			npc.m_flDoingAnimation = gameTime + 0.9;
			npc.m_flNextRangedAttackHappening = 0.0;
			npc.m_bisWalking = false;
			NPC_StopPathing(npc.index);
			npc.m_bPathing = false;

			float pos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			ParticleEffectAt(pos, "utaunt_bubbles_glow_orange_parent", 0.5);

			int team = GetTeam(npc.index);
			int a, entity;
			while((entity = FindEntityByNPC(a)) != -1)
			{
				if(!b_NpcHasDied[entity] && GetTeam(entity) == team)
				{
					ApplyStatusEffect(npc.index, entity, "Godly Motivation", 16.0);
					ParticleEffectAt(pos, "utaunt_bubbles_glow_orange_parent", 0.5);
				}
			}
			
			return;
		}
	}

	if(npc.m_flNextRangedAttackHappening)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			npc.FaceTowards(vecTarget, 30000.0);
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				
				float vPredictedPos[3]; PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 400.0, _,vPredictedPos);
				npc.FireRocket(vPredictedPos, 1000.0, 400.0, "models/effects/combineball.mdl");
				npc.PlayRangedSound();

				Elemental_AddNervousDamage(npc.m_iTarget, npc.index, 200);
			}
		}
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		//Get position for just travel here.

		if(npc.m_flDoingAnimation > gameTime) //I am doing an animation or doing something else, default to doing nothing!
		{
			npc.m_iState = -1;
		}
		else if(flDistanceToTarget < 160000 && npc.m_flNextRangedAttack < gameTime)
		{
			npc.m_iState = 1;
		}
		else 
		{
			npc.m_iState = 0; //stand and look if close enough.
		}
		
		switch(npc.m_iState)
		{
			case -1:
			{
				return; //Do nothing.
			}
			case 0:
			{
				//Walk to target
				if(!npc.m_bPathing)
					npc.StartPathing();
					
				npc.m_bisWalking = true;
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_CUSTOM_WALK_BOW");
				}
			}
			case 1:
			{			
				int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.SetActivity("ACT_IDLE_PISTOL");
					npc.AddGesture("ACT_MELEE_ATTACK_SWING_GESTURE");
					npc.m_iChanged_WalkCycle = 5;

					npc.m_flNextRangedAttackHappening = gameTime + 0.4;

					npc.m_flDoingAnimation = gameTime + 0.7;
					npc.m_flNextRangedAttack = gameTime + 1.0;

					npc.m_bisWalking = false;
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
		}
	}

	npc.PlayIdleSound();
}

public Action RaidbossBladedance_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBladedance npc = view_as<RaidbossBladedance>(victim);

	float gameTime = GetGameTime(npc.index);
	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		if(!npc.Anger)
			npc.m_iOverlordComboAttack++;
	}

	return Plugin_Changed;
}

public void RaidbossBladedance_NPCDeath(int entity)
{
	Waves_ClearWave();

	RaidbossBladedance npc = view_as<RaidbossBladedance>(entity);
	
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
	TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
	EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s",WhatDifficultySetting_Internal);
	WavesUpdateDifficultyName();
	
	if(i_RaidGrantExtra[npc.index] == 1 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		CPrintToChatAll("{crimson}Bladedance{default}: You and Bob the first.. you both missunderstand who the enemy is.. its {white}Whiteflower{default} you fools! He betrayed {crimson}Guln{default} aswell!");
		CPrintToChatAll("{crimson}Bladedance{default} escapes from you... and gains the ability to copy {crimson}you.");
		for (int client = 0; client < MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
			{
				Items_GiveNamedItem(client, "Bob's true fear");
				CPrintToChat(client,"{default}This battle wasnt something that should have happend. You had little to no chance... This is... {red}''Bob's True fear.''{default}!");
			}
		}
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entitynpc = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entitynpc))
			{
				if(entitynpc != INVALID_ENT_REFERENCE && IsEntityAlive(entitynpc) && GetTeam(npc.index) == GetTeam(entitynpc))
				{
					SmiteNpcToDeath(entitynpc);
				}
			}
		}
		ForcePlayerWin();
	}
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);

	RaidBossActive = INVALID_ENT_REFERENCE;
}
