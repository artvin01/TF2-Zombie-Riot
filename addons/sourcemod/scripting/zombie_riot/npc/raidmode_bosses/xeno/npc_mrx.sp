#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"player/invuln_off_vaccinator.wav",
};

static char g_HurtSounds[][] =
{
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static char g_MeleeHitSounds[][] =
{
	"vehicles/v8/vehicle_impact_heavy1.wav",
	"vehicles/v8/vehicle_impact_heavy2.wav",
	"vehicles/v8/vehicle_impact_heavy3.wav",
	"vehicles/v8/vehicle_impact_heavy4.wav",
};

static char g_MeleeAttackSounds[][] =
{
	"player/taunt_heavy_upper_cut.wav",
};

static char g_RangedAttackSounds[][] =
{
	"npc/zombie_poison/pz_throw2.wav",
	"npc/zombie_poison/pz_throw3.wav",
};

static char g_RangedSpecialAttackSounds[][] =
{
	"npc/fast_zombie/leap1.wav",
};

static char g_BoomSounds[][] =
{
	"npc/strider/striderx_die1.wav"
};

static char g_SMGAttackSounds[][] =
{
	"weapons/doom_sniper_smg.wav"
};

static char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static char g_AngerSounds[][] =
{
	"mvm/mvm_tank_end.wav",
};

static char g_HappySounds[][] =
{
	"vo/taunts/sniper/sniper_taunt_admire_02.mp3",
	"vo/compmode/cm_sniper_pregamefirst_6s_05.mp3",
	"vo/compmode/cm_sniper_matchwon_02.mp3",
	"vo/compmode/cm_sniper_matchwon_07.mp3",
	"vo/compmode/cm_sniper_matchwon_10.mp3",
	"vo/compmode/cm_sniper_matchwon_11.mp3",
	"vo/compmode/cm_sniper_matchwon_14.mp3"
};
static char g_NeckSnap[][] =
{
	"player/taunt_knuckle_crack.wav",
};




static int i_SideHurtWhich[MAXENTITIES];




static float f_MassRushHitAttack[MAXENTITIES];
static float f_MassRushHitAttackCD[MAXENTITIES];
static int i_lastTargetCharged[MAXENTITIES];

void RaidbossMrX_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Vivithorn");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_mrx");
	strcopy(data.Icon, sizeof(data.Icon), "mrx");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	for (int i = 0; i < (sizeof(g_NeckSnap));   i++) { PrecacheSound(g_NeckSnap[i]);   }
	PrecacheModel(INFECTION_MODEL);
	PrecacheSound("weapons/cow_mangler_explode.wav");
	PrecacheSoundCustom("#zombiesurvival/xeno_raid/mr_duo_battle.mp3");
	PrecacheSoundCustom("#zombiesurvival/xeno_raid/mr_x_solo.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossMrX(vecPos, vecAng, team, data);
}
methodmap RaidbossMrX < CClotBody
{

	property int m_iLastChargedTarget
	{
		public get()		 
		{ 
			int returnint = EntRefToEntIndex(i_lastTargetCharged[this.index]);
#if defined ZR
			if(returnint == -1)
			{
				return 0;
			}
#endif
			return returnint;
		}
		public set(int iInt) 
		{
			if(iInt == 0 || iInt == -1 || iInt == INVALID_ENT_REFERENCE)
			{
				i_lastTargetCharged[this.index] = INVALID_ENT_REFERENCE;
			}
			else
			{
				i_lastTargetCharged[this.index] = EntIndexToEntRef(iInt);
			}
		}
	}
	property float m_flRushAttack
	{
		public get()							{ return f_MassRushHitAttack[this.index]; }
		public set(float TempValueForProperty) 	{ f_MassRushHitAttack[this.index] = TempValueForProperty; }
	}
	property float m_flRushAttackCD
	{
		public get()							{ return f_MassRushHitAttackCD[this.index]; }
		public set(float TempValueForProperty) 	{ f_MassRushHitAttackCD[this.index] = TempValueForProperty; }
	}
	public void PlaySnapSound()
	{
		int sound = GetRandomInt(0, sizeof(g_NeckSnap) - 1);
		EmitSoundToAll(g_NeckSnap[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_NeckSnap[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_NeckSnap[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitSoundToAll(g_NeckSnap[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayHurtSound()
	{
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 65);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	public void PlayDeathSound()
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll(g_SMGAttackSounds[GetRandomInt(0, sizeof(g_SMGAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,65);
	}
	public void PlayRangedSpecialSound()
	{
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_RangedSpecialAttackSounds[GetRandomInt(0, sizeof(g_RangedSpecialAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds[GetRandomInt(0, sizeof(g_BoomSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 60);
	}
	public void PlayAngerSound()
	{
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRevengeSound()
	{
		char buffer[64];
		FormatEx(buffer, sizeof(buffer), "vo/sniper_revenge%02d.mp3", (GetURandomInt() % 25) + 1);
		EmitSoundToAll(buffer, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHappySound()
	{
		EmitSoundToAll(g_HappySounds[GetRandomInt(0, sizeof(g_HappySounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound()
	{
		int sound = GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_MeleeHitSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public RaidbossMrX(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossMrX npc = view_as<RaidbossMrX>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "2.0", "20000000", ally, false, true, true,true)); //giant!
		
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Nemesis_Win);
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(8);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_VIVITHORN_RUN");
		
		
		func_NPCDeath[npc.index] = RaidbossMrX_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossMrX_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossMrX_ClotThink;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 9999999.0;
		npc.m_flRushAttackCD = GetGameTime(npc.index) + 45.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 15.0;
		npc.m_flRushAttack = 0.0;
		npc.m_iLastChargedTarget = 0;

		if(XenoExtraLogic())
			RaidModeTime = GetGameTime(npc.index) + 250.0;

		npc.m_flMeleeArmor = 1.25; 		//Melee should be rewarded for trying to face this monster
		npc.m_flRangedArmor = 0.75;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;
		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			RaidModeTime = GetGameTime(npc.index) + 600.0;
			WaveStart_SubWaveStart(GetGameTime() + 800.0);
			Music_SetRaidMusicSimple("#zombiesurvival/xeno_raid/mr_duo_battle.mp3", 171, true, 1.3);
			i_RaidGrantExtra[npc.index] = 1;
		}
		else
		{
			Music_SetRaidMusicSimple("#zombiesurvival/xeno_raid/mr_x_solo.mp3", 127, true, 1.6);
		}
		RemoveAllDamageAddition();

		GiveOneRevive(true);
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Vivithorn Arrived.");
			}
		}
		
		b_thisNpcIsARaid[npc.index] = true;

		RaidModeScaling = 0.0;
		Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s", "??????????????????????????????????");
		WavesUpdateDifficultyName();
		npc.m_bThisNpcIsABoss = true;
		npc.Anger = false;
		npc.m_flSpeed = 300.0;
		if(npc.Anger)
			npc.m_flSpeed = 350.0;

		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_bDissapearOnDeath = true;
		Zero(f_NemesisEnemyHitCooldown);
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		i_GrabbedThis[npc.index] = -1;
		fl_RegainWalkAnim[npc.index] = 0.0;
		f_NemesisSpecialDeathAnimation[npc.index] = 0.0;
		f_NemesisRandomInfectionCycle[npc.index] = GetGameTime(npc.index) + 10.0;
		Zero(f_NemesisImmuneToInfection);
		npc.m_bUseDefaultAnim = true;

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		i_SideHurtWhich[npc.index] = 0;

		CPrintToChatAll("{green}Vivithorn: ...");

		Citizen_MiniBossSpawn();
		npc.StartPathing();
		npc.m_iWearable6 = npc.EquipItem("weapon_bone" ,"models/player/items/spy/spy_hat.mdl", .model_size = 1.2);
		SetEntityRenderColor(npc.index, 125, 125, 125, 255);
		SetEntityRenderColor(npc.m_iWearable6, 25, 25, 25, 255);
		npc.m_iWearable7 = npc.EquipItem("weapon_bone" ,"models/workshop/player/items/sniper/dec2014_hunter_vest/dec2014_hunter_vest.mdl", .model_size = 1.0);
		SetEntityRenderColor(npc.m_iWearable7, 25, 25, 25, 255);

		return npc;
	}
}

public void RaidbossMrX_ClotThink(int iNPC)
{
	RaidbossMrX npc = view_as<RaidbossMrX>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			CPrintToChatAll("{green} The infection got all your friends... Run while you can.");
		}
	}
	if(RaidModeTime < GetGameTime())
	{
		ZR_NpcTauntWinClear();
		i_RaidGrantExtra[npc.index] = 0;
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{green} The infection proves too strong for you to resist as you join his side...");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	if(npc.m_bUseDefaultAnim)
	{
		npc.AddGesture("ACT_HURT",false);
		npc.m_bUseDefaultAnim = false;
		Mr_xWalkingAnimInit(npc.index);
	}

	npc.Update();
	
	if(npc.m_flRushAttack)
	{
		ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ 30.0, true);
		if(npc.m_flGetClosestTargetTime < gameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,true, 1000.0, .ingore_client = npc.m_iLastChargedTarget);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index, true, 1000.0, .ingore_client = npc.m_iLastChargedTarget);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
			
			if(!IsValidEnemy(npc.index, npc.m_iTarget))
			{
				npc.m_flRushAttack = 0.0;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_flDoingAnimation = 0.0;
				Mr_xWalkingAnimInit(npc.index);
				npc.m_flDoingAnimation = gameTime + 1.0;
			}
			return;
		}
		if(npc.m_flDoingAnimation < gameTime)
		{
			//enemy is too close, intiate another attack
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.5))
			{
				npc.m_iLastChargedTarget = npc.m_iTarget;
				npc.m_flGetClosestTargetTime = 0.0;
				switch(GetRandomInt(1,2))
				{
					case 1:
					{
						npc.AddGesture("ACT_VIVITHORN_CHARGE_ATTACK_RIGHT");
					}
					case 2:
					{
						npc.AddGesture("ACT_VIVITHORN_CHARGE_ATTACK_LEFT");
					}
				}
				npc.m_flDoingAnimation = gameTime + 0.7;
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
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
							int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							
							WorldSpaceCenter(targetTrace, vecHit);

							float damage = 5000.0;

							SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);								
						
							
							bool Knocked = false;
										
							if(IsValidClient(targetTrace))
							{
								if (IsInvuln(targetTrace))
								{
									Knocked = true;
									Custom_Knockback(npc.index, targetTrace, 900.0, true);
									if(!NpcStats_IsEnemySilenced(npc.index))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
									}
								}
								else
								{
									if(!NpcStats_IsEnemySilenced(npc.index))
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
		if(npc.m_flRushAttack < gameTime)
		{
			if(npc.m_iChanged_WalkCycle != 14) 
			{
				fl_TotalArmor[npc.index] = 1.5;
				npc.SetActivity("ACT_VIVITHORN_CHARGE_STUN");
				npc.m_iChanged_WalkCycle = 14;
				npc.m_bisWalking = false;
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				f_NpcTurnPenalty[npc.index] = 0.0;
			}
			npc.m_flRushAttack = 0.0;
			npc.m_flDoingAnimation = gameTime + 2.5;
		}
		Mr_xWalkingAnimInit(npc.index);
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(!npc.m_flRushAttack && npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(!IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_flGetClosestTargetTime = 0.0;
		return;
	}
	if(npc.flXenoInfectedSpecialHurtTime)
	{
		int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
		if(IsValidEntity(client))
		{
			float flPos[3]; // original
			float flAng[3]; // original
		
			npc.GetAttachment("anim_attachment_RH", flPos, flAng);
		//	TeleportEntity(Enemy_I_See, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
			flPos[2] -= 70.0;
			SDKCall_SetLocalOrigin(client, flPos);
		}
		
	
		if(npc.flXenoInfectedSpecialHurtTime < gameTime + 1.0)
		{
			if(npc.m_iChanged_WalkCycle != 9) 
			{
				npc.m_iChanged_WalkCycle = 9;
				if(IsValidEntity(client))
				{
					SDKHooks_TakeDamage(client, npc.index, npc.index, 50000.0, DMG_CLUB, -1);
					f_AntiStuckPhaseThrough[client] = GetGameTime() + 3.0;
					ApplyStatusEffect(client, client, "Intangible", 3.0);
					if(client <= MaxClients)
						Client_Shake(client, 0, 20.0, 20.0, 1.0, false);

					npc.PlaySnapSound();
					b_NoGravity[client] = false;
					RemoveSpecificBuff(client, "Solid Stance");
					npc.SetVelocity({0.0,0.0,0.0});
					if(IsValidClient(client))
					{
						SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
						SetEntityCollisionGroup(client, 5);
					}
					b_DoNotUnStuck[client] = false;
					
					float pos[3];
					float Angles[3];
					GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);

					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
					TeleportEntity(client, pos, Angles, NULL_VECTOR);
				}
				i_GrabbedThis[npc.index] = 0;
			}
		}
		else
		{
			if(npc.flXenoInfectedSpecialHurtTime < gameTime + 2.0)
			{
				if(npc.m_iChanged_WalkCycle != 55) 
				{
					npc.SetActivity("ACT_VIVITHORN_GRAB_END");
					npc.m_iChanged_WalkCycle = 55;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;

					npc.StopPathing();
					f_NpcTurnPenalty[npc.index] = 0.0;
				}
			}
		}
		if(npc.flXenoInfectedSpecialHurtTime < gameTime)
		{
			npc.m_flDoingAnimation = 0.0;
			npc.flXenoInfectedSpecialHurtTime = 0.0;
			Mr_xWalkingAnimInit(npc.index);
			i_GrabbedThis[npc.index] = 0;
		}
		return;
	}
	if(npc.m_flNextRangedAttackHappening)
	{
		Mr_xWalkingAnimInit(npc.index);
		if(npc.m_flNextRangedAttackHappening < gameTime + 6.0)
		{
			//enemy is too close, intiate another attack
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
			{
				int Enemy_I_See;
					
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

				//Target close enough to hit
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					if(npc.m_iChanged_WalkCycle != 8) 
					{
						npc.SetActivity("ACT_VIVITHORN_GRAB_START");
						npc.m_iChanged_WalkCycle = 8;
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;

						npc.StopPathing();
						f_NpcTurnPenalty[npc.index] = 0.0;
					}

					if(i_IsVehicle[Enemy_I_See] == 2)
					{
						int driver = Vehicle_Driver(Enemy_I_See);
						if(driver != -1)
						{
							Enemy_I_See = driver;
							Vehicle_Exit(driver);
						}
					}
					
					npc.m_flNextRangedAttackHappening = 0.0;
					npc.m_flDoingAnimation = gameTime + 3.0;
					npc.flXenoInfectedSpecialHurtTime = gameTime + 3.0;
					GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_LastValidPosition[Enemy_I_See]);
					
					float flPos[3]; // original
					float flAng[3]; // original
				
					npc.GetAttachment("anim_attachment_RH", flPos, flAng);
					
					TeleportEntity(Enemy_I_See, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
					flPos[2] -= 70.0;
					SDKCall_SetLocalOrigin(Enemy_I_See, flPos);
					
					CClotBody npcenemy = view_as<CClotBody>(Enemy_I_See);

					if(Enemy_I_See <= MaxClients)
					{
						SetEntityMoveType(Enemy_I_See, MOVETYPE_NONE); //Cant move XD
						SetEntityCollisionGroup(Enemy_I_See, 1);
						FreezeNpcInTime(Enemy_I_See, 5.0);
					}
					else
					{
						b_NoGravity[Enemy_I_See] = true;
						ApplyStatusEffect(Enemy_I_See, Enemy_I_See, "Solid Stance", 999999.0);	
						npcenemy.SetVelocity({0.0,0.0,0.0});
					}
					f_TankGrabbedStandStill[npcenemy.index] = GetGameTime() + 5.5;
					TeleportEntity(npcenemy.index, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
					i_GrabbedThis[npc.index] = EntIndexToEntRef(Enemy_I_See);
					b_DoNotUnStuck[Enemy_I_See] = true;
					f_NpcTurnPenalty[npc.index] = 1.0;
				}
			}
		}
		if(npc.m_flNextRangedAttackHappening < gameTime)
		{
			npc.m_flNextRangedAttackHappening = 0.0;
			Mr_xWalkingAnimInit(npc.index);
		}
	}
	if(npc.m_flAttackHappens && !npc.m_flNextRangedAttackHappening)
	{
		ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ 30.0, false);
		if(f_NemesisHitBoxStart[npc.index] < gameTime && f_NemesisHitBoxEnd[npc.index] > gameTime)
		{
			if(i_SideHurtWhich[npc.index] == 3)
				Nemesis_AreaAttack(npc.index, 6000.0, {-40.0,-40.0,5.0}, {40.0,40.0,80.0}, "anim_attachment_L_Foot", 2);
			else if(i_SideHurtWhich[npc.index] == 2)
				Nemesis_AreaAttack(npc.index, 6000.0, {-40.0,-40.0,-40.0}, {40.0,40.0,40.0}, "anim_attachment_RH", 2);
			else
				Nemesis_AreaAttack(npc.index, 6000.0, {-40.0,-40.0,-40.0}, {40.0,40.0,40.0}, "anim_attachment_LH", 2);
		}
		
		if(npc.m_flAttackHappens < gameTime + 1.0)
		{
			npc.m_iChanged_WalkCycle = 7;
			npc.m_flSpeed = 50.0;
			if(npc.Anger)
				npc.m_flSpeed = 70.0;
		}
		if(npc.m_flAttackHappens < gameTime)
		{
			if(npc.m_flDoingAnimation > gameTime)
			{
				//enemy is too close, intiate another attack
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
				{
					if(npc.m_iChanged_WalkCycle != 3) 
					{

					}
				}
			}
			else
			{
				Mr_xWalkingAnimInit(npc.index);
				npc.m_flAttackHappens = 0.0;
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
			npc.SetGoalVector(vPredictedPos);
		} 
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}	

		int ActionToTake = 0;

		if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.50) && npc.m_flNextMeleeAttack < GetGameTime(npc.index) && !npc.m_flNextRangedAttackHappening && !npc.m_flRushAttack)
		{
			ActionToTake = GetRandomInt(1,3);
		}
		else if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.50) && npc.m_flNextRangedAttack < GetGameTime(npc.index) && !npc.m_flRushAttack)
		{
			ActionToTake = 4;
		}
		else if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 3.50) && npc.m_flRushAttackCD < GetGameTime(npc.index) && !npc.m_flRushAttack)
		{
			ActionToTake = 5;
		}

		switch(ActionToTake)
		{
			case 0:
			{
				Mr_xWalkingAnimInit(npc.index);
			}
			case 1:
			{
				npc.FaceTowards(vecTarget, 99999.9);
				i_SideHurtWhich[npc.index] = 1;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flAttackHappens = gameTime + 1.5;
				float flPos[3]; // original
				float flAng[3]; // original
				
				npc.GetAttachment("anim_attachment_LH", flPos, flAng);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 1.0);
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				SetParent(npc.index, npc.m_iWearable5, "anim_attachment_LH");
				f_NemesisHitBoxStart[npc.index] = gameTime + 0.5;
				f_NemesisHitBoxEnd[npc.index] = gameTime + 1.3;
				f_NemesisCauseInfectionBox[npc.index] = gameTime + 1.0;

				if(npc.m_iChanged_WalkCycle != 1) 
				{
					npc.SetActivity("ACT_VIVITHORN_ATTACK_LEFT");
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 450.0;
					if(npc.Anger)
						npc.m_flSpeed = 500.0;

					npc.StartPathing();
					f_NpcTurnPenalty[npc.index] = 1.5;
					npc.PlayMeleeSound();
				}
			}
			case 2:
			{
				npc.FaceTowards(vecTarget, 99999.9);
				i_SideHurtWhich[npc.index] = 2;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flAttackHappens = gameTime + 1.5;
				float flPos[3]; // original
				float flAng[3]; // original
				
				npc.GetAttachment("anim_attachment_RH", flPos, flAng);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 1.0);
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				SetParent(npc.index, npc.m_iWearable5, "anim_attachment_RH");
				f_NemesisHitBoxStart[npc.index] = gameTime + 0.5;
				f_NemesisHitBoxEnd[npc.index] = gameTime + 1.3;
				f_NemesisCauseInfectionBox[npc.index] = gameTime + 1.0;

				if(npc.m_iChanged_WalkCycle != 1) 
				{
					npc.SetActivity("ACT_VIVITHORN_ATTACK_RIGHT");
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 450.0;
					if(npc.Anger)
						npc.m_flSpeed = 500.0;

					npc.StartPathing();
					f_NpcTurnPenalty[npc.index] = 0.25;
					npc.PlayMeleeSound();
				}
			}
			case 3:
			{
				npc.FaceTowards(vecTarget, 99999.9);
				i_SideHurtWhich[npc.index] = 3;
				npc.m_flNextMeleeAttack = gameTime + 2.5;
				npc.m_flDoingAnimation = gameTime + 1.5;
				npc.m_flAttackHappens = gameTime + 1.5;
				float flPos[3]; // original
				float flAng[3]; // original
				
				npc.GetAttachment("anim_attachment_L_Foot", flPos, flAng);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 1.0);
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				SetParent(npc.index, npc.m_iWearable5, "anim_attachment_L_Foot");
				f_NemesisHitBoxStart[npc.index] = gameTime + 0.5;
				f_NemesisHitBoxEnd[npc.index] = gameTime + 1.3;
				f_NemesisCauseInfectionBox[npc.index] = gameTime + 1.0;

				if(npc.m_iChanged_WalkCycle != 1) 
				{
					npc.SetActivity("ACT_VIVITHORN_ATTACK_STOMP");
					npc.m_iChanged_WalkCycle = 1;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 450.0;
					if(npc.Anger)
						npc.m_flSpeed = 500.0;

					npc.StartPathing();
					f_NpcTurnPenalty[npc.index] = 0.25;
					npc.PlayMeleeSound();
				}
			}
			case 4:
			{
				npc.m_flNextRangedAttack = gameTime + 30.0;
				npc.m_flNextRangedAttackHappening = gameTime + 5.0;
				Mr_xWalkingAnimInit(npc.index);
			}
			case 5:
			{
				npc.m_flNextRangedAttackHappening = 0.0;
				npc.m_iLastChargedTarget = 0;
				npc.m_flRushAttackCD = gameTime + 30.0;
				npc.m_flRushAttack = gameTime + 7.0;
				Mr_xWalkingAnimInit(npc.index);
				npc.m_flDoingAnimation = gameTime + 0.7;
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_flNextRangedAttack += 7.0;
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		if(!npc.m_flRushAttack)
			npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

void Mr_xWalkingAnimInit(int entity)
{
	RaidbossMrX npc = view_as<RaidbossMrX>(entity);
	
	if(npc.m_flDoingAnimation > GetGameTime(npc.index))
		return;

	fl_TotalArmor[npc.index] = 1.0;
	float TimeLeft1 = npc.m_flRushAttack - GetGameTime(npc.index);
	if(TimeLeft1 > 0.0)
	{
		float Percentage = TimeLeft1 / 7.0;
		if(Percentage > 0.8)
		{		
			if(npc.m_iChanged_WalkCycle != 10) 	
			{
				npc.SetActivity("ACT_VIVITHORN_CHARGE_START");
				npc.m_iChanged_WalkCycle = 10;
				npc.m_bisWalking = false;
				npc.m_flSpeed = 0.0;
				npc.StopPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
		else
		{		
			if(npc.m_iChanged_WalkCycle != 11) 	
			{
				npc.SetActivity("ACT_VIVITHORN_CHARGE_RUN");
				npc.m_iChanged_WalkCycle = 11;
				npc.m_bisWalking = true;
				npc.m_flSpeed = 500.0;
				npc.StartPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
		return;
	}
	float TimeLeft = npc.m_flNextRangedAttackHappening - GetGameTime(npc.index);
	if(TimeLeft > 0.0)
	{
		float Percentage = TimeLeft / 5.0;
		if(Percentage > 0.7)
		{		
			if(npc.m_iChanged_WalkCycle != 4) 	
			{
				npc.SetActivity("ACT_VIVITHORN_GRAB_RUN");
				npc.m_iChanged_WalkCycle = 4;
				npc.m_bisWalking = true;
				npc.m_flSpeed = 200.0;
				npc.StartPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
		else if(Percentage > 0.4)
		{		
			if(npc.m_iChanged_WalkCycle != 5) 	
			{
			//	npc.SetActivity("ACT_TYRANT_WALK_FAST");
				npc.m_iChanged_WalkCycle = 5;
				npc.m_bisWalking = true;
				npc.m_flSpeed = 300.0;
				npc.StartPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
		else 
		{
			if(npc.m_iChanged_WalkCycle != 6) 	
			{
			//	npc.SetActivity("ACT_RAID_TYRANT_RUN");
				npc.m_iChanged_WalkCycle = 6;
				npc.m_bisWalking = true;
				npc.m_flSpeed = 500.0;
				if(npc.Anger)
					npc.m_flSpeed = 550.0;
				npc.StartPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
		return;
	}
	//If nothing special happens, do normal walking.
	if(npc.m_iChanged_WalkCycle != 2) 	
	{
		npc.SetActivity("ACT_VIVITHORN_RUN");
		npc.m_iChanged_WalkCycle = 2;
		npc.m_bisWalking = true;
		npc.m_flSpeed = 300.0;
		if(npc.Anger)
			npc.m_flSpeed = 350.0;
		npc.StartPathing();
		f_NpcTurnPenalty[npc.index] = 1.0;
	}
}
	
public Action RaidbossMrX_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	RaidbossMrX npc = view_as<RaidbossMrX>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void RaidbossMrX_NPCDeath(int entity)
{
	RaidbossMrX npc = view_as<RaidbossMrX>(entity);
	npc.PlayDeathSound();
	int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s",WhatDifficultySetting_Internal);
	WavesUpdateDifficultyName();
	
	if(IsValidEntity(client))
	{
		b_NoGravity[client] = false;
		RemoveSpecificBuff(client, "Solid Stance");
		npc.SetVelocity({0.0,0.0,0.0});
		if(IsValidClient(client))
		{
			SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
			SetEntityCollisionGroup(client, 5);
		}
		
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(client, pos, Angles, NULL_VECTOR);
		b_DoNotUnStuck[client] = false;
	}	
	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);
		DispatchKeyValue(entity_death, "model", COMBINE_CUSTOM_2_MODEL);
		DispatchSpawn(entity_death);
		SetEntPropFloat(entity_death, Prop_Send, "m_flModelScale", 2.0); 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("vivithorn_death");
		AcceptEntityInput(entity_death, "SetAnimation");
		SetVariantInt(8);
		AcceptEntityInput(entity_death, "SetBodyGroup");
		CClotBody npcstuff = view_as<CClotBody>(entity_death);
		npcstuff.m_iWearable6 = npcstuff.EquipItem("weapon_bone" ,"models/player/items/spy/spy_hat.mdl", .model_size = 1.2);
		SetEntityRenderColor(npcstuff.m_iWearable6, 25, 25, 25, 255);
		SetEntityRenderColor(npcstuff.index, 125, 125, 125, 255);
		npcstuff.m_iWearable7 = npcstuff.EquipItem("weapon_bone" ,"models/workshop/player/items/sniper/dec2014_hunter_vest/dec2014_hunter_vest.mdl", .model_size = 1.0);
		SetEntityRenderColor(npcstuff.m_iWearable7, 25, 25, 25, 255);
		
		CreateTimer(1.3, Prop_Gib_FadeSet, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.3, Prop_Gib_FadeSet, EntIndexToEntRef(npcstuff.m_iWearable6), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.3, Prop_Gib_FadeSet, EntIndexToEntRef(npcstuff.m_iWearable7), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.65, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.65, Timer_RemoveEntity, EntIndexToEntRef(npcstuff.m_iWearable6), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.65, Timer_RemoveEntity, EntIndexToEntRef(npcstuff.m_iWearable7), TIMER_FLAG_NO_MAPCHANGE);
	}

	i_GrabbedThis[npc.index] = -1;
	
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);

	GiveProgressDelay(3.0);
	RaidModeTime += 3.5; //cant afford to delete it, since duo.
	if(i_RaidGrantExtra[npc.index] == 0 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		for (int client_repat = 1; client_repat <= MaxClients; client_repat++)
		{
			if(IsValidClient(client_repat) && GetClientTeam(client_repat) == 2 && TeutonType[client_repat] != TEUTON_WAITING)
			{
				if(XenoExtraLogic())
				{
					CPrintToChat(client_repat, "{green}Vivithorn: I have to activate Project Calmaticus...");
				}
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == 1 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		for (int client_repat = 1; client_repat <= MaxClients; client_repat++)
		{
			if(IsValidClient(client_repat) && GetClientTeam(client_repat) == 2 && TeutonType[client_repat] != TEUTON_WAITING)
			{
				if(XenoExtraLogic())
				{
					CPrintToChat(client_repat, "{green}Vivithorn Escapes... but heavily wounded...");
				}
			}
		}
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != INVALID_ENT_REFERENCE && other != npc.index)
			{
				if(IsEntityAlive(other) && GetTeam(other) == GetTeam(npc.index))
				{
					ApplyStatusEffect(npc.index, other, "Hussar's Warscream", 999999.0);	
				}
			}
		}
	}
	
	Citizen_MiniBossDeath(entity);
}
