#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/mvm/norm/soldier_mvm_paincrticialdeath01.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath02.mp3",
	"vo/mvm/norm/soldier_mvm_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/mvm/norm/soldier_mvm_painsharp01.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp02.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp03.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp04.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp05.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp06.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp07.mp3",
	"vo/mvm/norm/soldier_mvm_painsharp08.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/mvm/norm/soldier_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint03.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint04.mp3",
	"vo/mvm/norm/soldier_mvm_standonthepoint05.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/machete_swing.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/axe_hit_flesh1.wav",
	"weapons/axe_hit_flesh2.wav",
	"weapons/axe_hit_flesh3.wav",
};

static const char g_RangedAttackSounds[][] = {
	"weapons/shotgun_shoot.wav",
};

static const char g_BoomSounds[][] = {
	"weapons/sentry_damage1.wav",
	"weapons/sentry_damage2.wav",
	"weapons/sentry_damage3.wav",
	"weapons/sentry_damage4.wav",
};

void ARIS_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	PrecacheSound("#zombiesurvival/matrix/furiousangels.mp3");
	PrecacheModel("models/bots/soldier/bot_soldier.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "A.R.I.S");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_aris");
	strcopy(data.Icon, sizeof(data.Icon), "soldier_robot_nys");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Aperture;
	data.Func = ClotSummon;
	NPC_Add(data);
}


static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return ARIS(vecPos, vecAng, ally, data);
}
methodmap ARIS < CClotBody
{
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, 100, _, BOSS_ZOMBIE_VOLUME, 110);
	}
	public void PlayBoomSound() 
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);

	}
	
	public ARIS(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ARIS npc = view_as<ARIS>(CClotBody(vecPos, vecAng, "models/bots/soldier/bot_soldier.mdl", "1.50", "700", ally, false, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;

		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		func_NPCDeath[npc.index] = ARIS_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ARIS_OnTakeDamage;
		func_NPCThink[npc.index] = ARIS_ClotThink;

		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		EmitSoundToAll("mvm/mvm_tank_end.wav", _, _, _, _, 1.0, 100);	
		
		RaidModeTime = GetGameTime(npc.index) + 160.0;
		b_thisNpcIsARaid[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%s", "A.R.I.S arrives");
			}
		}
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		if(RaidModeScaling < 55)
		{
			RaidModeScaling *= 0.19; //abit low, inreacing
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
		
		amount_of_people *= 0.15;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people;
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/matrix/furiousangels.mp3");
		music.Time = 161;
		music.Volume = 1.7;
		music.Custom = false;
		strcopy(music.Name, sizeof(music.Name), "Furious Angels (Instrumental)");
		strcopy(music.Artist, sizeof(music.Artist), "Rob Dougan");
		Music_SetRaidMusic(music);
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 25.0;
		npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 999.0; //Melee
		npc.m_flAbilityOrAttack2 = GetGameTime(npc.index) + 10.0; //Switch to Ranged
		npc.m_flAbilityOrAttack4 = GetGameTime(npc.index) + 10.0;
		npc.m_fbGunout = false;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_PANZER;

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		
		npc.m_flSpeed = 300.0;
		npc.m_flMeleeArmor = 1.0;
				
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_shovel/c_shovel.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_shotgun/c_shotgun.mdl");
		SetVariantString("1.10");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable2, "Disable");

		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);

		Citizen_MiniBossSpawn();
		npc.StartPathing();

		return npc;
	}
}

public void ARIS_ClotThink(int iNPC)
{
	ARIS npc = view_as<ARIS>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}

	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		
		CPrintToChatAll("{blue}C.A.T{default}: Intruders taken care of.");
		return;
	}

	//idk it never was in a bracket
	if(IsValidEntity(RaidBossActive) && RaidModeTime < GetGameTime())
	{
		if(RaidModeTime < GetGameTime())
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			CPrintToChatAll("{blue}C.A.T{default}: We hope your stay at Aperture was pleasant!");
			func_NPCThink[npc.index] = INVALID_FUNCTION;
			return;
		}
	}

	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
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

	float gameTime = GetGameTime(npc.index);
	int closest = npc.m_iTarget;

	if(npc.m_flAbilityOrAttack4)
	{
		if(npc.m_flAbilityOrAttack4 < GetGameTime(npc.index))
		{
			float SpeedReturn[3];
			float VecStart[3]; WorldSpaceCenter(npc.index, VecStart);
			float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			int RocketGet = npc.FireRocket(vecTarget, 10.0, 250.0);
			//Reducing gravity, reduces speed, lol.
			SetEntityGravity(RocketGet, 0.5); 	
			//I dont care if its not too accurate, ig they suck with the weapon idk lol, lore.
			ArcToLocationViaSpeedProjectile(VecStart, vecTarget, SpeedReturn, 8.0, 1.0);
			SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
			TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
			npc.m_flAbilityOrAttack4 = gameTime + 10.0;
		}
	}

	if(IsValidEnemy(npc.index, closest))
	{
		float vecTarget[3]; WorldSpaceCenter(closest, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		//Predict their pos.
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3]; PredictSubjectPosition(npc, closest, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(closest);
		}
		
		ARIS_SelfDefense(npc, gameTime, npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void ARIS_SelfDefense(ARIS npc, float gameTime, int target, float flDistanceToTarget)
{
	if(npc.m_flAbilityOrAttack1)
	{
		if(npc.m_flAbilityOrAttack1 > GetGameTime(npc.index))
		{
			npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 999.0; //Ranged
			ARIS_WeaponSwaps(npc, 1);
			AcceptEntityInput(npc.m_iWearable1, "Enable");
			AcceptEntityInput(npc.m_iWearable2, "Disable");
			if(npc.m_flAbilityOrAttack2)
			{
				if(npc.m_flAbilityOrAttack2 < GetGameTime(npc.index))
				{
					npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 0.0; //Melee
					npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 0.0; //Ranged
				}
			}
			if(npc.m_flAttackHappens)
			{
				if(npc.m_flAttackHappens < GetGameTime(npc.index))
				{
					npc.m_flAttackHappens = 0.0;

					if(IsValidEnemy(npc.index, target))
					{
						int HowManyEnemeisAoeMelee = 64;
						Handle swingTrace;
						float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
						npc.FaceTowards(VecEnemy, 15000.0);
						npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1, _, HowManyEnemeisAoeMelee);
						delete swingTrace;
						bool PlaySound = false;
						float damage = 35.0;
						damage *= RaidModeScaling;
						bool silenced = NpcStats_IsEnemySilenced(npc.index);
						for(int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
						{
							if(i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
							{
								if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
								{
									int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
									float vecHit[3];

									WorldSpaceCenter(targetTrace, vecHit);

									if(damage <= 1.0)
									{
										damage = 1.0;
									}
									SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
									//Reduce damage after dealing
									damage *= 0.92;
									// On Hit stuff
									bool Knocked = false;
									if(!PlaySound)
									{
										PlaySound = true;
									}

									if(IsValidClient(targetTrace))
									{
										if (IsInvuln(targetTrace))
										{
											Knocked = true;
											Custom_Knockback(npc.index, targetTrace, 180.0, true);
											if(!silenced)
											{
												TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
												TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
											}
										}
										else
										{
											if(!silenced)
											{
												TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
												TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
											}
										}
									}			
									if(!Knocked)
										Custom_Knockback(npc.index, targetTrace, 450.0, true); 
								} 
							}
						}
						if(PlaySound)
						{
							npc.PlayMeleeHitSound();
						}
					}
				}
			}

			if(gameTime > npc.m_flNextMeleeAttack)
			{
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
				{
					int Enemy_I_See;
					Enemy_I_See = Can_I_See_Enemy(npc.index, target);

					if(IsValidEnemy(npc.index, Enemy_I_See))
					{
						npc.m_iTarget = Enemy_I_See;

						npc.PlayMeleeSound();
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");//He will SMACK you
						npc.m_flAttackHappens = gameTime + 0.1;
						float attack = 1.0;
						npc.m_flNextMeleeAttack = gameTime + attack;
						return;
					}
				}
			}
		}
	}

	if(npc.m_flNextRangedSpecialAttack)
	{
		npc.m_flAbilityOrAttack3 = GetGameTime(npc.index) + 7.0; //Switch to Melee
		if(npc.m_flAbilityOrAttack3)
		{
			if(npc.m_flAbilityOrAttack3 > GetGameTime(npc.index))
			{
				ARIS_WeaponSwaps(npc, 1);
				npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 999.0;
				npc.m_flAbilityOrAttack1 = GetGameTime(npc.index) + 999.0; //Melee
				npc.m_flAbilityOrAttack0 = GetGameTime(npc.index) + 999.0; //Ranged
			}
		}
		if(npc.m_flNextRangedSpecialAttack < gameTime)
		{
			npc.m_flNextRangedSpecialAttack = 0.0;

			if(npc.m_iTarget > 0)
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
				npc.FaceTowards(vecTarget, 150.0);
				
				float eyePitch[3], vecDirShooting[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyePitch);
				
				vecTarget[2] += 15.0;
				MakeVectorFromPoints(vecMe, vecTarget, vecDirShooting);
				GetVectorAngles(vecDirShooting, vecDirShooting);

				vecDirShooting[1] = eyePitch[1];

				npc.m_flNextRangedAttack = gameTime + 0.5;
				
				float x = GetRandomFloat( -0.15, 0.15 );
				float y = GetRandomFloat( -0.15, 0.15 );
				
				float vecRight[3], vecUp[3];
				GetAngleVectors(vecDirShooting, vecDirShooting, vecRight, vecUp);
				
				float vecDir[3];
				for(int i; i < 3; i++)
				{
					vecDir[i] = vecDirShooting[i] + x * vecRight[i] + y * vecUp[i]; 
				}

				NormalizeVector(vecDir, vecDir);
				npc.AddGesture("ACT_MP_ATTACK_STAND_SECONDARY");
				KillFeed_SetKillIcon(npc.index, "shotgun_primary");

				float damage = 15.0;
				damage *= RaidModeScaling;

				FireBullet(npc.index, npc.m_iWearable2, vecMe, vecDir, damage, 9000.0, DMG_BULLET, "dxhr_sniper_rail_blue");
				
				npc.PlayRangedSound();
			}
		}
		return;
	}

	if(npc.m_flAbilityOrAttack0)
	{
		if(npc.m_flAbilityOrAttack0 < GetGameTime(npc.index))
		{
			if(gameTime > npc.m_flNextRangedAttack)
			{
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
				ARIS_WeaponSwaps(npc, 2);
				AcceptEntityInput(npc.m_iWearable1, "Disable");

				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");//ACT_MP_ATTACK_STAND_ITEM1 | ACT_MP_ATTACK_STAND_MELEE_ALLCLASS

					npc.m_flNextRangedSpecialAttack = gameTime + 0.15;
					npc.m_flNextRangedAttack = gameTime + 1.5;
				}
			}
		}
	}
}

public Action ARIS_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ARIS npc = view_as<ARIS>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void ARIS_NPCDeath(int entity)
{
	ARIS npc = view_as<ARIS>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

}

static void ARIS_WeaponSwaps(ARIS npc, int number = 1)
{
	switch(number)
	{
		case 1:
		{
			if(npc.m_iChanged_WalkCycle != 3)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_MELEE");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable2, "Disable");
				AcceptEntityInput(npc.m_iWearable1, "Enable");
				npc.m_iChanged_WalkCycle = 3;
			}
		}
		case 2:
		{
			if(npc.m_iChanged_WalkCycle != 4)
			{
				int iActivity_melee = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
				if(iActivity_melee > 0) npc.StartActivity(iActivity_melee);
				AcceptEntityInput(npc.m_iWearable2, "Enable");
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				npc.m_iChanged_WalkCycle = 4;
			}
		}
	}
}