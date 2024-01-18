#pragma semicolon 1
#pragma newdecls required

static char g_IntroStartSounds[][] =
{
	"npc/combine_soldier/vo/overwatchtargetcontained.wav",
	"npc/combine_soldier/vo/overwatchtarget1sterilized.wav"
};

static char g_IntroEndSounds[][] =
{
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/cbar_hitbod1.wav",
	"weapons/cbar_hitbod2.wav",
	"weapons/cbar_hitbod3.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"weapons/machete_swing.wav"
};

static char g_RangedAttackSounds[][] =
{
	"weapons/bow_shoot.wav"
};

static char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

void RaidbossBobTheFirst_OnMapStart()
{
	PrecacheSoundArray(g_IntroStartSounds);
	PrecacheSoundArray(g_IntroEndSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_BuffSounds);
	
	PrecacheSoundCustom("#zombiesurvival/bob_raid/bob.mp3");
}

methodmap RaidbossBobTheFirst < CClotBody
{
	public void PlayIntroStartSound()
	{
		EmitSoundToAll(g_IntroStartSounds[GetRandomInt(0, sizeof(g_IntroStartSounds) - 1)]);
	}
	public void PlayIntroEndSound()
	{
		EmitSoundToAll(g_IntroStartSounds[GetRandomInt(0, sizeof(g_IntroStartSounds) - 1)]);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSpecialSound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property bool m_bSecondPhase
	{
		public get()		{	return i_NpcInternalId[this.index] == BOB_THE_FIRST_S;	}
		public set(bool value)	{	i_NpcInternalId[this.index] = value ? BOB_THE_FIRST_S : BOB_THE_FIRST;	}
	}

	public RaidbossBobTheFirst(float vecPos[3], float vecAng[3], bool ally, const char[] data)
	{
		float pos[3];
		pos = vecPos;
		
		for(int i; i < i_MaxcountNpc; i++)
		{
			int entity = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(entity != INVALID_ENT_REFERENCE && (i_NpcInternalId[entity] == SEA_RAIDBOSS_DONNERKRIEG || i_NpcInternalId[entity] == SEA_RAIDBOSS_SCHWERTKRIEG) && IsEntityAlive(entity))
			{
				GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
				SmiteNpcToDeath(entity);
			}
		}

		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(CClotBody(pos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "20000000", ally, _, _, true, true));
		
		i_NpcInternalId[npc.index] = BOB_THE_FIRST;
		i_NpcWeight[npc.index] = 4;
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MUDROCK_RAGE");
		npc.m_flNextDelayTime = GetGameTime(npc.index) + 10.0;
		b_NpcIsInvulnerable[npc.index] = true;

		npc.PlayIntroStartSound();

		SDKHook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
		
		if(StrContains(data, "final_item") != -1)
			i_RaidGrantExtra[npc.index] = 1;

		/*
			Cosmetics
		*/
		
		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		/*
			Variables
		*/

		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		npc.m_bThisNpcIsABoss = true;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_flMeleeArmor = 1.25;

		npc.Anger = false;
		npc.m_flSpeed = 340.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_iAttackType = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		
		strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), "??????????????????????????????????");
		Music_SetRaidMusic("#zombiesurvival/bob_raid/bob.mp3", 697, true, 1.99);
		npc.StopPathing();

		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime() + 292.0;
		RaidModeScaling = 9999999.99;

		Zombies_Currently_Still_Ongoing--;

		return npc;
	}
}

public void RaidbossBobTheFirst_ClotThink(int iNPC)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(iNPC);
	
	float gameTime = GetGameTime(npc.index);

	//Raidmode timer runs out, they lost.
	if(npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(RaidBossActive != INVALID_ENT_REFERENCE)
		{
			int entity = CreateEntityByName("game_round_win"); 
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
		}

		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
				ForcePlayerSuicide(client);
		}

		char buffer[64];
		if(c_NpcCustomNameOverride[npc.index][0])
		{
			strcopy(buffer, sizeof(buffer), c_NpcCustomNameOverride[npc.index]);
		}
		else
		{
			strcopy(buffer, sizeof(buffer), NPC_Names[i_NpcInternalId[npc.index]]);
		}

		switch(GetURandomInt() % 3)
		{
			case 0:
				CPrintToChatAll("{white}%s{default}: You weren't supposed to have this infection.", buffer);
			
			case 1:
				CPrintToChatAll("{white}%s{default}: No choice but to kill you, it consumes you.", buffer);
			
			case 2:
				CPrintToChatAll("{white}%s{default}: Nobody wins.", buffer);
		}
		
		// Play funny animation intro
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.SetActivity("ACT_IDLE_ZOMBIE");
	}

	if(npc.m_flNextDelayTime > gameTime)
		return;

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	//npc.m_flNextThinkTime = gameTime + 0.05;

	if(i_RaidGrantExtra[npc.index] > 1)
	{
		NPC_StopPathing(npc.index);
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.SetActivity("ACT_IDLE_SHIELDZOBIE");

		if(XenoExtraLogic())
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					ReviveAll(true);
					CPrintToChatAll("{white}Bob the First{default}: So...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}Bob the First{default}: What do you think will happpen..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}Bob the First{default}: What if you killed Seaborn before Xeno..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}Bob the First{default}: Well nothing is holding this one back now...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}Bob the First{default}: ...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 7:
				{
					GiveProgressDelay(1.0);
					SmiteNpcToDeath(npc.index);

					Enemy enemy;

					enemy.Index = XENO_RAIDBOSS_NEMESIS;
					enemy.Health = 30000000;
					enemy.Is_Boss = 2;
					enemy.ExtraSpeed = 1.5;
					enemy.ExtraDamage = 3.0;
					enemy.ExtraSize = 1.0;

					Waves_AddNextEnemy(enemy);

					Zombies_Currently_Still_Ongoing++;

					CreateTimer(0.9, Bob_DeathCutsceneCheck, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}
			}
		}
		else
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					ReviveAll(true);
					CPrintToChatAll("{white}Bob the First{default}: No...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}Bob the First{default}: This infection...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}Bob the First{default}: How did this thing make you thing powerful..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}Bob the First{default}: Took out every single Seaborn and took the infection in yourselves...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}Bob the First{default}: You people fighting these cities and infections...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 7:
				{
					CPrintToChatAll("{white}Bob the First{default}: However...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 8:
				{
					CPrintToChatAll("{white}Bob the First{default}: I will remove what does not belong to you...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 9:
				{
					npc.m_flNextThinkTime = gameTime + 1.25;

					GiveProgressDelay(1.5);
					Waves_ForceSetup(1.5);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && !IsFakeClient(client))
						{
							if(IsPlayerAlive(client))
								ForcePlayerSuicide(client);
							
							ApplyLastmanOrDyingOverlay(client);
							SendConVarValue(client, sv_cheats, "1");
						}
					}

					cvarTimeScale.SetFloat(0.1);
					CreateTimer(0.5, SetTimeBack);
				}
				case 10:
				{
					SmiteNpcToDeath(npc.index);
					GivePlayerItems();
				}
			}
		}

		i_RaidGrantExtra[npc.index]++;
		return;
	}

	if(npc.Anger)	// Waiting for enemies to die off
	{
		float enemies = float(Zombies_Currently_Still_Ongoing);

		for(int i; i < i_MaxcountNpc; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				int maxhealth = GetEntProp(victim, Prop_Data, "m_iMaxHealth");
				if(maxhealth)
					enemies += float(GetEntProp(victim, Prop_Data, "m_iHealth")) / float(maxhealth);
			}
		}

		if(enemies > 3.0)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", RoundToCeil(float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")) * (enemies + 3.0) / 485.0));
			return;
		}

		GiveOneRevive();
		RaidModeTime += 140.0;

		npc.m_flRangedArmor = 0.9;
		npc.m_flMeleeArmor = 1.125;

		npc.Anger = false;
		npc.m_bSecondPhase = true;
		c_NpcCustomNameOverride[npc.index][0] = 0;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") * 17 / 20);

		if(XenoExtraLogic())
		{
			switch(GetURandomInt() % 3)
			{
				case 0:
					CPrintToChatAll("{white}Bob the First{default}: Your in the wrong place in the wrong time!");
				
				case 1:
					CPrintToChatAll("{white}Bob the First{default}: This is not how it goes!");
				
				case 2:
					CPrintToChatAll("{white}Bob the First{default}: Stop trying to change fate!");
			}
		}
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
					CPrintToChatAll("{white}Bob the First{default}: Enough of this!");
				
				case 1:
					CPrintToChatAll("{white}Bob the First{default}: Do you see yourself? Your slaughter?");
				
				case 2:
					CPrintToChatAll("{white}Bob the First{default}: You are no god.");
				
				case 3:
					CPrintToChatAll("{white}Bob the First{default}: Xeno. Seaborn. Then there's you.");
			}
		}

		npc.m_flNextMeleeAttack = gameTime + 2.0;
	}

	if(b_NpcIsInvulnerable[npc.index] || npc.m_flGetClosestTargetTime < gameTime || !IsEntityAlive(npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(b_NpcIsInvulnerable[npc.index])
		{
			b_NpcIsInvulnerable[npc.index] = false;
			npc.PlayIntroEndSound();
		}
	}

	int healthPoints = GetEntProp(npc.index, Prop_Data, "m_iHealth") * 20 / GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	if(!npc.m_bSecondPhase)
	{
		if(healthPoints < 15 && !c_NpcCustomNameOverride[npc.index][0])
		{
			strcopy(c_NpcCustomNameOverride[npc.index], sizeof(c_NpcCustomNameOverride[]), "??????? First");
		}
		else if(healthPoints < 9)
		{
			GiveOneRevive();
			RaidModeTime += 260.0;

			npc.Anger = true;
			npc.SetActivity("ACT_IDLE_ZOMBIE");
			strcopy(c_NpcCustomNameOverride[npc.index], sizeof(c_NpcCustomNameOverride[]), "??? the First");
			
			SetupMidWave();
			return;
		}
	}

	if(healthPoints > 2)
		npc.m_flSpeed = healthPoints < 13 ? 330.0 : 290.0;

	if(npc.m_iTarget > 0 && healthPoints < 20)
	{
		float vecMe[3]; vecMe = WorldSpaceCenter(npc.index);
		float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

		switch(npc.m_iAttackType)
		{
			case 1:	// COMBO1 - Frame 22
			{
				if(RowAttack(npc, vecMe, 650.0, 200.0, true))
				{
					npc.m_iAttackType = 2;
					npc.m_flAttackHappens = gameTime + 1.333;
				}
			}
			case 2:	// COMBO1 - Frame 54
			{
				if(RowAttack(npc, vecMe, 2350.0, 0.0, false))
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.0;
				}
			}
			case 3:	// COMBO2 - Frame 12
			{
				if(RowAttack(npc, vecMe, 325.0, 0.0, false))
				{
					npc.m_iAttackType = 4;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 4:	// COMBO2 - Frame 32
			{
				if(RowAttack(npc, vecMe, 350.0, 200.0, true))
				{
					npc.m_iAttackType = 5;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 5:	// COMBO2 - Frame 52
			{
				if(RowAttack(npc, vecMe, 325.0, 200.0, false))
				{
					npc.m_iAttackType = 6;
					npc.m_flAttackHappens = gameTime + 0.875;
				}
			}
			case 6:	// COMBO2 - Frame 73
			{
				if(RowAttack(npc, vecMe, 2000.0, 0.0, true))
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.208;
				}
			}
			case 7:	// COMBO3 - Frame 51
			{
				if(RowAttack(npc, vecMe, 3000.0, 300.0, true))
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.125;
				}
			}
			case 8:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;

					int projectile = npc.FireRocket(vecTarget, 3000.0, 200.0, "models/effects/combineball.mdl", 1.0, _, 60.0);
					
					float ang_Look[3];
					GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
					Initiate_HomingProjectile(projectile,
						npc.index,
						70.0,			// float lockonAngleMax,
						10.0,				//float homingaSec,
						false,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						ang_Look);// float AnglesInitiate[3]);
				}
			}
			case 9:
			{
				vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
				NPC_SetGoalVector(npc.index, vecTarget);

				npc.FaceTowards(vecTarget, 20000.0);
				
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;

					KillFeed_SetKillIcon(npc.index, "fists");

					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					//bool PlaySound = false;
					for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
					{
						if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
						{
							if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
							{
								//PlaySound = true;
								int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								vecHit = WorldSpaceCenter(target);

								SDKHooks_TakeDamage(target, npc.index, npc.index, 250.0, DMG_CLUB, -1, _, vecHit);	
								
								bool Knocked = false;
								
								if(IsValidClient(target))
								{
									if (IsInvuln(target))
									{
										Knocked = true;
										Custom_Knockback(npc.index, target, 1000.0, true);
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
									else
									{
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
								}
								
								if(!Knocked)
									Custom_Knockback(npc.index, target, 750.0);
							}
						} 
					}

					KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
				}
			}
			case 10:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;

					int ref = EntIndexToEntRef(npc.index);

					Handle data = CreateDataPack();
					WritePackFloat(data, vecMe[0]);
					WritePackFloat(data, vecMe[1]);
					WritePackFloat(data, vecMe[2]);
					WritePackCell(data, 47.0); // Distance
					WritePackFloat(data, 0.0); // nphi
					WritePackCell(data, 250.0); // Range
					WritePackCell(data, 1000.0); // Damge
					WritePackCell(data, ref);
					ResetPack(data);
					TrueFusionwarrior_IonAttack(data);

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && IsPlayerAlive(client))
						{
							GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecTarget);
							
							data = CreateDataPack();
							WritePackFloat(data, vecTarget[0]);
							WritePackFloat(data, vecTarget[1]);
							WritePackFloat(data, vecTarget[2]);
							WritePackCell(data, 87.0); // Distance
							WritePackFloat(data, 0.0); // nphi
							WritePackCell(data, 250.0); // Range
							WritePackCell(data, 1000.0); // Damge
							WritePackCell(data, ref);
							ResetPack(data);
							TrueFusionwarrior_IonAttack(data);
						}
					}
				}
			}
			case 11, 12:
			{
				float distance = GetVectorDistance(vecTarget, vecMe, true);
				if(distance < npc.GetLeadRadius()) 
				{
					vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
					NPC_SetGoalVector(npc.index, vecTarget);
				}
				else
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}

				npc.StartPathing();
				npc.SetActivity("ACT_DARIO_WALK");

				if(npc.m_iAttackType == 12)
					npc.m_flSpeed = 192.0;
				
				if(npc.m_flAttackHappens < gameTime)
				{
					if(npc.m_iAttackType == 11)
					{
						npc.m_iAttackType = 12;
						npc.AddGesture("ACT_DARIO_ATTACK_GUN_1");
						npc.m_flAttackHappens = gameTime + 0.4;
					}
					else
					{
						npc.m_iAttackType = 11;
						npc.m_flAttackHappens = gameTime + 0.5;
						
						vecTarget = PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1200.0);
						npc.FireRocket(vecTarget, 400.0, 1200.0, "models/weapons/w_bullet.mdl", 2.0);
					}
				}

				npc.FaceTowards(vecTarget, 2500.0);
			}
			default:
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					if(healthPoints < 19 && npc.m_flNextMeleeAttack < gameTime)
					{
						npc.m_flNextMeleeAttack = gameTime + 10.0;
						npc.StopPathing();

						switch(GetURandomInt() % 3)
						{
							case 0:
							{
								npc.SetActivity("ACT_COMBO1_BOBPRIME");
								npc.m_iAttackType = 1;
								npc.m_flAttackHappens = gameTime + 0.916;
							}
							case 1:
							{
								npc.SetActivity("ACT_COMBO2_BOBPRIME");
								npc.m_iAttackType = 3;
								npc.m_flAttackHappens = gameTime + 0.5;
							}
							case 2:
							{
								npc.SetActivity("ACT_COMBO3_BOBPRIME");
								npc.m_iAttackType = 7;
								npc.m_flAttackHappens = gameTime + 2.125;
							}
						}
					}
					else if(healthPoints < 17 && npc.m_flNextRangedAttack < gameTime)
					{
						npc.m_flNextRangedAttack = gameTime + (healthPoints < 9 ? 5.0 : 11.0);
						npc.StopPathing();

						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 8;
						npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 11 && npc.m_flNextRangedSpecialAttack < gameTime)
					{
						npc.m_flNextRangedSpecialAttack = gameTime + (healthPoints < 7 ? 15.0 : 27.0);
						npc.StopPathing();

						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 10;
						npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 3)
					{
						npc.m_flSpeed = 1.0;
						npc.m_iAttackType = 11;
						npc.m_flAttackHappens = gameTime + 1.333;

						npc.AddGesture("ACT_METROCOP_DEPLOY_PISTOL");
						
						npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
						SetVariantString("1.15");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}
					else
					{
						float distance = GetVectorDistance(vecTarget, vecMe, true);
						if(distance < npc.GetLeadRadius()) 
						{
							vecTarget = PredictSubjectPosition(npc, npc.m_iTarget);
							NPC_SetGoalVector(npc.index, vecTarget);
						}
						else
						{
							NPC_SetGoalEntity(npc.index, npc.m_iTarget);
						}

						npc.StartPathing();
						npc.SetActivity("ACT_RUN_PANICKED");
						
						if(distance < 10000.0)	// 100 HU
						{
							npc.StopPathing();
							
							npc.AddGesture("ACT_SEABORN_ATTACK_TOOL_1");
							npc.m_iAttackType = 9;
							npc.m_flAttackHappens = gameTime + 0.667;
						}
					}
				}
			}
		}
	}
	else
	{
		npc.StopPathing();
		npc.SetActivity("ACT_IDLE_BOBPRIME");
	}
}

static void GiveOneRevive()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			int glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][0]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);
			
			glowentity = EntRefToEntIndex(i_DyingParticleIndication[client][1]);
			if(glowentity > MaxClients)
				RemoveEntity(glowentity);
			
			if(IsPlayerAlive(client))
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);
				int entity, i;
				while(TF2U_GetWearable(client, entity, i))
				{
					SetEntityRenderMode(entity, RENDER_NORMAL);
					SetEntityRenderColor(entity, 255, 255, 255, 255);
				}
			}
			
			ForcePlayerCrouch(client, false);
			//just make visible.
			SetEntityRenderMode(client, RENDER_NORMAL);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			
			i_AmountDowned[client]--;
			if(i_AmountDowned[client] < 0)
				i_AmountDowned[client] = 0;
			
			DoOverlay(client, "", 2);
			if(GetClientTeam(client) == 2)
			{
				if((!IsPlayerAlive(client) || TeutonType[client] == TEUTON_DEAD))
				{
					DHook_RespawnPlayer(client);
					GiveCompleteInvul(client, 2.0);
				}
				else if(dieingstate[client] > 0)
				{
					GiveCompleteInvul(client, 2.0);

					if(b_LeftForDead[client])
					{
						dieingstate[client] = -8; //-8 for incode reasons, check dieing timer.
					}
					else
					{
						dieingstate[client] = 0;
					}

					Store_ApplyAttribs(client);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.00001);

					int entity, i;
					while(TF2U_GetWearable(client, entity, i))
					{
						SetEntityRenderMode(entity, RENDER_NORMAL);
						SetEntityRenderColor(entity, 255, 255, 255, 255);
					}

					SetEntityRenderMode(client, RENDER_NORMAL);
					SetEntityRenderColor(client, 255, 255, 255, 255);
					SetEntityCollisionGroup(client, 5);

					SetEntityHealth(client, 50);
					RequestFrame(SetHealthAfterRevive, EntIndexToEntRef(client));
				}
			}
		}
	}

	int entity = MaxClients + 1;
	while((entity = FindEntityByClassname(entity, "zr_base_npc")) != -1)
	{
		if(i_NpcInternalId[entity] == CITIZEN)
		{
			Citizen npc = view_as<Citizen>(entity);
			if(npc.m_nDowned && npc.m_iWearable3 > 0)
				npc.SetDowned(false);
		}
	}

	CheckAlivePlayers();
}

static bool RowAttack(RaidbossBobTheFirst npc, const float vecMe[3], float damage, float range, bool kick)
{
	float vecAngles[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", vecAngles);

	// Lock to 90 angles
	vecAngles[1] = (((vecAngles[1] > 0.0 ? 45 : -45) + RoundFloat(vecAngles[1])) / 90) * 90.0;
	
	float vecForward[3], vecTarget[3];
	GetAngleVectors(vecAngles, vecForward, NULL_VECTOR, NULL_VECTOR);

	for(int i; i < 3; i++)
	{
		vecTarget[i] = vecMe[i] + vecForward[i];
	}

	npc.FaceTowards(vecTarget, 1000.0);

	if(npc.m_flAttackHappens < GetGameTime(npc.index))
	{
		KillFeed_SetKillIcon(npc.index, kick ? "mantreads" : "fists");

		if(NpcStats_IsEnemySilenced(npc.index))
			kick = false;

		for(int victim = 1; victim <= MaxClients; victim++)
		{
			if(IsClientInGame(victim) && IsPlayerAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET);
					if(kick)
					{
						vecTarget[0] = 0.0;
						vecTarget[1] = 0.0;
						vecTarget[2] = 400.0;
						TeleportEntity(victim, _, _, vecTarget, true);

						TF2_StunPlayer(victim, 1.5, 0.5, TF_STUNFLAGS_NORMALBONK, victim);
					}
				}
			}
		}
		
		for(int i; i < i_MaxcountNpc; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_BULLET);
					if(kick)
					{
						FreezeNpcInTime(victim, 1.5);
						
						vecTarget = WorldSpaceCenter(victim);
						vecTarget[2] += 100.0; //Jump up.
						PluginBot_Jump(victim, vecTarget);
					}
				}
			}
		}
		
		for(int i; i < i_MaxcountNpc_Allied; i++)
		{
			int victim = EntRefToEntIndex(i_ObjectsNpcs_Allied[i]);
			if(victim != INVALID_ENT_REFERENCE && victim != npc.index && IsEntityAlive(victim))
			{
				if(HitByForward(victim, vecMe, vecForward, range))
				{
					SDKHooks_TakeDamage(victim, npc.index, npc.index, damage, DMG_CLUB);
					if(kick)
					{
						FreezeNpcInTime(victim, 1.5);
						
						vecTarget = WorldSpaceCenter(victim);
						vecTarget[2] += 100.0; //Jump up.
						PluginBot_Jump(victim, vecTarget);
					}
				}
			}
		}

		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");

		return true;
	}

	return false;
}

static bool HitByForward(int entity, const float vecCenter[3], const float vecForward[3], float range)
{
	float vecMe[3];
	vecMe = WorldSpaceCenter(entity);

	for(int i; i < 2; i++)
	{
		// Check if in pathway
		if(vecForward[i] > 0.8)
		{
			if((vecCenter[i] - range) > vecMe[i])
				return false;
		}
		else if(vecForward[i] < -0.8)
		{
			if((vecCenter[i] + range) < vecMe[i])
				return false;
		}
		else
		{
			continue;
		}

		// Left/right check
		i = i == 0 ? 1 : 0;
		if(fabs(vecCenter[i] - vecMe[i]) > 80.0)
			return false;
		
		// Up/down check
		if(fabs(vecCenter[2] - vecMe[2]) > 175.0)
			return false;
		
		return true;
	}
	
	return false;
}

static void SetupMidWave()
{
	AddBobEnemy(COMBINE_SOLDIER_ELITE, 20);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 20);
	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 40);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 15);
	AddBobEnemy(COMBINE_SOLDIER_COLLOSS, 2, 1);

	AddBobEnemy(COMBINE_SOLDIER_DDT, 30);
	AddBobEnemy(COMBINE_SOLDIER_ELITE, 20);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 20);

	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 40);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 10);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 20);

	AddBobEnemy(COMBINE_SOLDIER_ELITE, 50);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 50);
	AddBobEnemy(COMBINE_SOLDIER_SHOTGUN, 50);

	AddBobEnemy(COMBINE_SOLDIER_ELITE, 10);
	AddBobEnemy(COMBINE_SOLDIER_DDT, 10);
	AddBobEnemy(COMBINE_SOLDIER_AR2, 10);
	AddBobEnemy(COMBINE_SOLDIER_SWORDSMAN, 10);
	AddBobEnemy(COMBINE_SOLDIER_GIANT_SWORDSMAN, 10);
	AddBobEnemy(COMBINE_SOLDIER_SHOTGUN, 10);
	AddBobEnemy(COMBINE_SOLDIER_AR2, 10);
	AddBobEnemy(COMBINE_POLICE_SMG, 10);
	AddBobEnemy(COMBINE_POLICE_PISTOL, 10);
}

static void AddBobEnemy(int id, int count, int boss = 0)
{
	Enemy enemy;

	enemy.Index = id;
	enemy.Is_Boss = boss;
	enemy.Is_Health_Scaled = 1;
	enemy.ExtraMeleeRes = 0.05;
	enemy.ExtraRangedRes = 0.05;
	enemy.ExtraSpeed = 1.5;
	enemy.ExtraDamage = 4.0;
	enemy.ExtraSize = 1.0;

	for(int i; i < count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}

	Zombies_Currently_Still_Ongoing += count;
}

Action RaidbossBobTheFirst_OnTakeDamage(int victim, int &attacker, float &damage)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(victim);
	
	if(npc.Anger || i_RaidGrantExtra[npc.index] > 1)
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if(i_RaidGrantExtra[npc.index] == 1 && Waves_GetRound() > 55)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			Music_SetRaidMusic("vo/null.mp3", 30, false, 0.5);
			npc.StopPathing();

			RaidBossActive = -1;

			i_RaidGrantExtra[npc.index] = 2;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(30.0);
			damage = 0.0;
			
			return Plugin_Handled;
		}
	}

	return Plugin_Changed;
}

void RaidbossBobTheFirst_NPCDeath(int entity)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	SDKUnhook(npc.index, SDKHook_Think, RaidbossBobTheFirst_ClotThink);
	
	Zombies_Currently_Still_Ongoing++;	// Because it was decreased before

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}

static Action Bob_DeathCutsceneCheck(Handle timer)
{
	if(!LastMann)
		return Plugin_Continue;
	
	for(int i; i < i_MaxcountNpc; i++)
	{
		int victim = EntRefToEntIndex(i_ObjectsNpcs[i]);
		if(victim != INVALID_ENT_REFERENCE && IsEntityAlive(victim))
			SmiteNpcToDeath(victim);
	}
	
	GiveProgressDelay(1.5);
	Waves_ForceSetup(1.5);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			if(IsPlayerAlive(client))
				ForcePlayerSuicide(client);
			
			ApplyLastmanOrDyingOverlay(client);
			SendConVarValue(client, sv_cheats, "1");
		}
	}

	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);

	GivePlayerItems();
	return Plugin_Stop;
}

static void GivePlayerItems()
{
	/*
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
		{
			Items_GiveNamedItem(client, "Cured Silvester");
			CPrintToChat(client, "{default}You gained his favor, you obtained: {yellow}''Cured Silvester''{default}!");
		}
	}
	*/
}