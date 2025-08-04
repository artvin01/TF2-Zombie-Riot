#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"vo/sniper_paincrticialdeath01.mp3",
	"vo/sniper_paincrticialdeath02.mp3",
	"vo/sniper_paincrticialdeath03.mp3"
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
	"npc/vort/foot_hit.wav",
};

static char g_MeleeAttackSounds[][] =
{
	"npc/zombie_poison/pz_warn1.wav",
	"npc/zombie_poison/pz_warn2.wav",
};

static char g_RangedAttackSounds[][] =
{
	"npc/zombie_poison/pz_throw2.wav",
	"npc/zombie_poison/pz_throw3.wav",
};
static char g_RangedAttackSounds2[][] =
{
	"weapons/csgo_awp_shoot.wav",
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


#define INFECTION_MODEL "models/weapons/w_bugbait.mdl"
#define INFECTION_RANGE 150.0

float InfectionDelay()
{
	if(XenoExtraLogic())
		return 0.7;
	
	return 0.8;
}
// NAME IS OLD AND UNUSED FROM NEMESIS!!
//too lazy to replace all files, aint doing it.
void RaidbossNemesis_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Calmaticus");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_raidboss_nemesis");
	strcopy(data.Icon, sizeof(data.Icon), "nemesis_boss");
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
	for (int i = 0; i < (sizeof(g_RangedAttackSounds2));   i++) { PrecacheSound(g_RangedAttackSounds2[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_BoomSounds));   i++) { PrecacheSound(g_BoomSounds[i]);   }
	PrecacheModel(INFECTION_MODEL);
	PrecacheSound("weapons/cow_mangler_explode.wav");
	PrecacheSoundCustom("#zombiesurvival/xeno_raid/genesis_of_the_virus.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossNemesis(vecPos, vecAng, team, data);
}
methodmap RaidbossNemesis < CClotBody
{
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
	}
	public void PlaySMGSound()
	{
		EmitSoundToAll(g_SMGAttackSounds[GetRandomInt(0, sizeof(g_SMGAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME,65);
	}
	public void PlayRangedSoundMinigun()
	{
		EmitSoundToAll(g_RangedAttackSounds2[GetRandomInt(0, sizeof(g_RangedAttackSounds2) - 1)], this.index, SNDCHAN_WEAPON, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.5,110);
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
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayBuffSound()
	{
		EmitSoundToAll(g_BuffSounds[GetRandomInt(0, sizeof(g_BuffSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public RaidbossNemesis(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossNemesis npc = view_as<RaidbossNemesis>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_2_MODEL, "2.0", "20000000", ally, false, true, true,true)); //giant!
		
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Nemesis_Win);
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.SetActivity("ACT_CALMATICUS_RUN");
		
		
		func_NPCDeath[npc.index] = RaidbossNemesis_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossNemesis_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossNemesis_ClotThink;
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossNemesis_OnTakeDamagePost);
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 200.0;


		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}

		if(XenoExtraLogic())
			RaidModeTime = GetGameTime(npc.index) + 9999999.0;

		npc.m_flMeleeArmor = 1.25; 		//Melee should be rewarded for trying to face this monster
		fl_TotalArmor[npc.index] = 0.8;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_TANK;

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Calmaticus Arrived.");
			}
		}
		b_thisNpcIsARaid[npc.index] = true;
		RemoveAllDamageAddition();

		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/xeno_raid/genesis_of_the_virus.mp3");
		music.Time = 185;
		music.Volume = 1.3;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Genesis of the void");
		strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
		Music_SetRaidMusic(music);

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
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 15.0;
		f_NemesisSpecialDeathAnimation[npc.index] = 0.0;
		f_NemesisRandomInfectionCycle[npc.index] = GetGameTime(npc.index) + 20.0;
		Zero(f_NemesisImmuneToInfection);

		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + GetRandomFloat(45.0, 60.0);
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		i_GunMode[npc.index] = 0;
		i_GunAmmo[npc.index] = 0;
		fl_StopDodgeCD[npc.index] = GetGameTime(npc.index) + 25.0;
		if(XenoExtraLogic())
		{
			FormatEx(c_NpcName[npc.index], sizeof(c_NpcName[]), "Enraged Calmaticus");
			CPrintToChatAll("{green}Calmaticus: YOU WILL BECOME DNA SUPLIMENTS:");
		}
		else
		{
			CPrintToChatAll("{green}Calmaticus: You all will be one with the virus.");
		}
		
		npc.m_iWearable6 = npc.EquipItem("weapon_bone", "models/workshop/player/items/pyro/hw2013_mucus_membrane/hw2013_mucus_membrane.mdl");
	
		SetEntityRenderColor(npc.index, 65, 255, 65, 255);
		Citizen_MiniBossSpawn();
		npc.StartPathing();
		return npc;
	}
}

public void RaidbossNemesis_ClotThink(int iNPC)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(iNPC);
	
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
	if(npc.m_flNextRangedAttackHappening && npc.flXenoInfectedSpecialHurtTime - 0.45 < gameTime)
	{
		ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ 90.0, true);
	}
	if(npc.m_flNextDelayTime < GetGameTime(npc.index))
	{
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
		npc.m_flNextDelayTime > GetGameTime(npc.index) + 0.1;
	}

	

	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_HURT", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	if(i_GunAmmo[npc.index] > 0)
	{
		i_GunMode[npc.index] = 1;
	}
	
	if(f_NemesisSpecialDeathAnimation[npc.index])
	{
		if(!NpcStats_IsEnemySilenced(npc.index))
		{
			npc.m_flMeleeArmor = 0.25;
			npc.m_flRangedArmor = 0.25;
		}
		else
		{
			npc.m_flMeleeArmor = 0.30;
			npc.m_flRangedArmor = 0.30;
		}
		//silence doesnt completly delete it, but moreso, nerf it.
		if(f_NemesisSpecialDeathAnimation[npc.index] + 14.0 > GetGameTime(npc.index))
		{
			float ProjLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
			ProjLoc[2] += 70.0;

			ProjLoc[0] += GetRandomFloat(-40.0, 40.0);
			ProjLoc[1] += GetRandomFloat(-40.0, 40.0);
			ProjLoc[2] += GetRandomFloat(-15.0, 15.0);
			TE_Particle("healthgained_blu", ProjLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

			int HealByThis = ReturnEntityMaxHealth(npc.index) / 3250;
			HealByThis = RoundToCeil(float(HealByThis) / TickrateModify);
			if(XenoExtraLogic())
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + (HealByThis * 2));
			}
			else
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + (HealByThis));
			}
			
			if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= ReturnEntityMaxHealth(npc.index))
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
			}
		}

		if(f_NemesisSpecialDeathAnimation[npc.index] + 2.3 > GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 20) 	
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
				
				npc.m_flSpeed = 0.0;
				npc.SetActivity("ACT_CALMATICUS_MINIGUN_REGEN_START");
				npc.m_iChanged_WalkCycle = 20;
			}
		}
		else if(f_NemesisSpecialDeathAnimation[npc.index] + 14.0 > GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 12) 	
			{
				npc.SetActivity("ACT_CALMATICUS_MINIGUN_REGEN_LOOP");
				npc.m_iChanged_WalkCycle = 12;
				SetEntProp(npc.index, Prop_Data, "m_bSequenceLoops", true);
			}
		}
		else if(f_NemesisSpecialDeathAnimation[npc.index] + 14.5 > GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 13) 	
			{
				npc.SetActivity("ACT_CALMATICUS_MINIGUN_REGEN_END");
				npc.m_iChanged_WalkCycle = 13;
				npc.SetPlaybackRate(0.75);
			}
		}
		else if(f_NemesisSpecialDeathAnimation[npc.index] + 16.5 > GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 14) 	
			{
				if(IsValidEntity(npc.m_iWearable1))
				{
					RemoveEntity(npc.m_iWearable1);
				}
				npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_minigun/c_minigun.mdl");
				SetVariantString("1.0");
				AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			}
		}
		else if(f_NemesisSpecialDeathAnimation[npc.index] + 16.5 < GetGameTime(npc.index))
		{
			f_NemesisSpecialDeathAnimation[npc.index] = 0.0;
			if(npc.m_iChanged_WalkCycle != 10) 	
			{
				i_GunMode[npc.index] = 1;
				i_GunAmmo[npc.index] = 250;
				npc.SetActivity("ACT_CALMATICUS_MINIGUN_WALK");
				npc.m_iChanged_WalkCycle = 10;
				npc.m_bisWalking = true;
				npc.m_flSpeed = 50.0;
				if(npc.Anger)
					npc.m_flSpeed = 100.0;

				npc.StartPathing();
				f_NpcTurnPenalty[npc.index] = 1.0;
			}	
		}
		return;
	}
	else
	{
		npc.m_flMeleeArmor = 1.25; 		//Melee should be rewarded for trying to face this monster
	}
	
	
	if(npc.m_flDoingAnimation < gameTime && i_GunMode[npc.index] == 0)
	{
		Nemesis_TryDodgeAttack(npc.index);
	}

	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(f_NemesisRandomInfectionCycle[npc.index] < GetGameTime(npc.index))
	{
		f_NemesisRandomInfectionCycle[npc.index] = GetGameTime(npc.index) + 10.0;
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("anim_attachment_LH", flPos, flAng);
		Nemesis_DoInfectionThrow(npc.index, 5);
		ParticleEffectAt(flPos, "duck_collect_blood_green", 1.0);
	}

	if(fl_StopDodge[npc.index])
	{
		if(fl_StopDodge[npc.index] < GetGameTime(npc.index))
		{
			b_IgnoredByPlayerProjectiles[npc.index] = false;
			npc.m_iChanged_WalkCycle = 9;
			npc.m_bisWalking = false;
			npc.m_bAllowBackWalking = true;
			npc.m_flSpeed = 0.0;
			npc.StopPathing();
			fl_StopDodge[npc.index] = 0.0;

			i_GunMode[npc.index] = 1;
			i_GunAmmo[npc.index] = 150;
			npc.m_flAttackHappens = 0.0;

			npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_minigun/c_minigun.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
			f_NpcTurnPenalty[npc.index] = 1.0;

			return; //just to be sure.
		}
	}
	if(f_NemesisCauseInfectionBox[npc.index])
	{
		if(f_NemesisCauseInfectionBox[npc.index] < GetGameTime(npc.index))
		{
			float flPos[3]; // original
			float flAng[3]; // original
			npc.GetAttachment("anim_attachment_LH", flPos, flAng);
			Nemesis_DoInfectionThrow(npc.index, 10);
			ParticleEffectAt(flPos, "duck_collect_blood_green", 1.0);
			f_NemesisCauseInfectionBox[npc.index] = 0.0;
		}
	}

	if(i_GunAmmo[npc.index] < 0 && i_GunMode[npc.index] == 1)
	{
		if(npc.m_iChanged_WalkCycle != 999) 	
		{
			npc.m_bAllowBackWalking = false;
			i_GunMode[npc.index] = 0;
			npc.m_iChanged_WalkCycle = 999;
			fl_RegainWalkAnim[npc.index] = gameTime + 0.2;
			npc.m_flDoingAnimation = gameTime + 0.1;
			f_NpcTurnPenalty[npc.index] = 1.0;
		}
	}

	if(fl_OverrideWalkDest[npc.index] > gameTime)
	{
		return;
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		if(	i_GunMode[npc.index] != 0)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget < 1)
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	if(fl_RegainWalkAnim[npc.index])
	{
		if(fl_RegainWalkAnim[npc.index] < gameTime)
		{
			switch(i_GunMode[npc.index])
			{
				case 0:
				{
					if(npc.m_iChanged_WalkCycle != 2) 	
					{
						if(IsValidEntity(npc.m_iWearable1))
						{
							RemoveEntity(npc.m_iWearable1);
						}
						npc.SetActivity("ACT_CALMATICUS_RUN");
						npc.m_iChanged_WalkCycle = 2;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 300.0;
						if(npc.Anger)
							npc.m_flSpeed = 350.0;
						npc.StartPathing();
						f_NpcTurnPenalty[npc.index] = 1.0;
					}
				}
				case 1:
				{
					if(npc.m_iChanged_WalkCycle != 10) 	
					{
						npc.SetActivity("ACT_CALMATICUS_MINIGUN_WALK");
						npc.m_iChanged_WalkCycle = 10;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 50.0;
						if(npc.Anger)
							npc.m_flSpeed = 100.0;
						npc.StartPathing();
						f_NpcTurnPenalty[npc.index] = 1.0;
						if(IsValidEntity(npc.m_iWearable1))
						{
							RemoveEntity(npc.m_iWearable1);
						}
						npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_minigun/c_minigun.mdl");
						SetVariantString("1.0");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}					
				}
			}
			fl_RegainWalkAnim[npc.index] = 0.0;
			return; //just incase.
		}
	}
	int client_victim = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	if(IsValidEntity(client_victim))
	{
		if(npc.m_flNextRangedAttackHappening)
		{
			if(npc.m_flNextRangedAttackHappening < gameTime)
			{
				if(XenoExtraLogic())
				{
					ResolvePlayerCollisions_Npc(npc.index, /*damage crush*/ 350.0);
				}
				else
				{
					i_GrabbedThis[npc.index] = -1;
					AcceptEntityInput(client_victim, "ClearParent");
							
					float flPos[3]; // original
					float flAng[3]; // original
							
							
					npc.GetAttachment("anim_attachment_LH", flPos, flAng);
					TeleportEntity(client_victim, flPos, NULL_VECTOR, {0.0,0.0,0.0});
							
					if(client_victim <= MaxClients)
					{
						SetEntityMoveType(client_victim, MOVETYPE_WALK); //can move XD
								
						TF2_AddCondition(client_victim, TFCond_LostFooting, 1.0);
						TF2_AddCondition(client_victim, TFCond_AirCurrent, 1.0);
								
						if(dieingstate[client_victim] == 0)
						{
							SetEntityCollisionGroup(client_victim, 5);
							b_ThisEntityIgnored[client_victim] = false;
						}
						Custom_Knockback(npc.index, client_victim, 3000.0, true, true);
					}
					else
					{
						b_NoGravity[client_victim] = false;
						npc.SetVelocity({0.0,0.0,0.0});
					}
					npc.m_flNextRangedAttackHappening = 0.0;	
					SDKHooks_TakeDamage(client_victim, npc.index, npc.index, 10000.0, DMG_CLUB, -1);
					i_TankAntiStuck[client_victim] = EntIndexToEntRef(npc.index);
					CreateTimer(0.1, CheckStuckNemesis, EntIndexToEntRef(client_victim), TIMER_FLAG_NO_MAPCHANGE);
					npc.PlayRangedSpecialSound();
				}
			}
		}
	}
	else
	{
		if(npc.m_flNextRangedAttackHappening)
		{
			if(npc.m_flNextRangedAttackHappening - 5.75 < gameTime)
			{
				if(npc.m_iChanged_WalkCycle != 6 && npc.m_iChanged_WalkCycle != 5 && npc.m_iChanged_WalkCycle != 7) 
				{
					if(XenoExtraLogic())
						npc.SetActivity("ACT_CALMATICUS_CHARGE_LOOP_LAB");
					else
						npc.SetActivity("ACT_CALMATICUS_CHARGE_LOOP");

					npc.m_iChanged_WalkCycle = 6;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 600.0;
					if(npc.Anger)
							npc.m_flSpeed = 900.0;
					npc.StartPathing();
				}
			}

			if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.flXenoInfectedSpecialHurtTime - 0.45 < gameTime)
			{
				if(!XenoExtraLogic())
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
					{
						int Enemy_I_See;
							
						Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

						//Target close enough to hit
						if(IsValidEntity(npc.m_iTarget) && IsValidEnemy(npc.index, Enemy_I_See))
						{
							npc.SetActivity("ACT_CALMATICUS_CHARGE_END");
							npc.m_iChanged_WalkCycle = 5;
							npc.m_bisWalking = false;
							npc.m_flSpeed = 0.0;
							npc.StopPathing();
							npc.m_flDoingAnimation = gameTime + 3.5;
							npc.m_flNextRangedAttackHappening = gameTime + 2.0;
							fl_RegainWalkAnim[npc.index] = gameTime + 3.5;
							npc.PlayRangedSound();

							if(i_IsVehicle[Enemy_I_See] == 2)
							{
								int driver = Vehicle_Driver(Enemy_I_See);
								if(driver != -1)
								{
									Enemy_I_See = driver;
									Vehicle_Exit(driver);
								}
							}

							GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", f3_LastValidPosition[Enemy_I_See]);
							
							float flPos[3]; // original
							float flAng[3]; // original
						
							npc.GetAttachment("anim_attachment_LH", flPos, flAng);
							
							TeleportEntity(Enemy_I_See, flPos, NULL_VECTOR, {0.0,0.0,0.0});
							
							CClotBody npcenemy = view_as<CClotBody>(Enemy_I_See);

							if(Enemy_I_See <= MaxClients)
							{
								SetEntityMoveType(Enemy_I_See, MOVETYPE_NONE); //Cant move XD
								SetEntityCollisionGroup(Enemy_I_See, 1);
								SetParent(npc.index, Enemy_I_See, "anim_attachment_LH");
							}
							else
							{
								b_NoGravity[Enemy_I_See] = true;
								npcenemy.SetVelocity({0.0,0.0,0.0});
							}
							f_TankGrabbedStandStill[npcenemy.index] = GetGameTime() + 3.5;
							TeleportEntity(npcenemy.index, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});
							i_GrabbedThis[npc.index] = EntIndexToEntRef(Enemy_I_See);
							b_DoNotUnStuck[Enemy_I_See] = true;
							f_NpcTurnPenalty[npc.index] = 1.0;
						}
					}
					
				}
			}
			if(npc.m_iChanged_WalkCycle != 5) 
			{
				if(npc.m_flNextRangedAttackHappening - 0.6 < gameTime)
				{
					if(npc.m_iChanged_WalkCycle != 7) 
					{
						npc.SetActivity("ACT_CALMATICUS_CHARGE_FAIL");
						npc.m_iChanged_WalkCycle = 7;
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
					}
				}
				if(npc.m_flNextRangedAttackHappening < gameTime)
				{
					if(npc.m_iChanged_WalkCycle != 2) 	
					{
						npc.SetActivity("ACT_CALMATICUS_RUN");
						npc.m_iChanged_WalkCycle = 2;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 300.0;
						if(npc.Anger)
							npc.m_flSpeed = 350.0;
						npc.StartPathing();
						f_NpcTurnPenalty[npc.index] = 1.0;
					}
					npc.m_flNextRangedAttackHappening = 0.0;			
				}	
			}
		}
	}

	if(npc.m_flAttackHappens)
	{
		if(f_NemesisHitBoxStart[npc.index] < gameTime && f_NemesisHitBoxEnd[npc.index] > gameTime)
		{
			if(npc.m_iChanged_WalkCycle == 13)
				Nemesis_AreaAttack(npc.index, 3000.0, {-40.0,-40.0,-40.0}, {40.0,40.0,40.0}, "anim_attachment_RH");
			else
				Nemesis_AreaAttack(npc.index, 3000.0, {-40.0,-40.0,-40.0}, {40.0,40.0,40.0});
		}

		if(npc.m_flAttackHappens < gameTime)
		{
			if(npc.m_flDoingAnimation > gameTime)
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 2.0))
					{

						if(npc.m_iChanged_WalkCycle != 13) 
						{
							//the enemy is still close, do another attack.
							float flPos[3]; // original
							float flAng[3]; // original
							npc.GetAttachment("anim_attachment_RH", flPos, flAng);
							if(IsValidEntity(npc.m_iWearable5))
								RemoveEntity(npc.m_iWearable5);
						
							npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_blue", 1.25);
							TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
							SetParent(npc.index, npc.m_iWearable5, "anim_attachment_RH");
							npc.m_flAttackHappens = gameTime + 2.0;
							npc.m_flDoingAnimation = gameTime + 2.0;
							f_NemesisHitBoxStart[npc.index] = gameTime + 0.65;
							f_NemesisHitBoxEnd[npc.index] = gameTime + 1.25;
							f_NemesisCauseInfectionBox[npc.index] = gameTime + 1.0;
							npc.FaceTowards(vecTarget, 99999.9);
							npc.SetActivity("ACT_CALMATICUS_ATTACK_RIGHT");
							npc.SetPlaybackRate(0.6);
							npc.m_iChanged_WalkCycle = 13;
							npc.m_bisWalking = false;
							if(XenoExtraLogic())
							{
								npc.m_flSpeed = 150.0;
								if(npc.Anger)
									npc.m_flSpeed = 200.0;
							}
							else
							{
								npc.m_flSpeed = 50.0;
								if(npc.Anger)
									npc.m_flSpeed = 100.0;
							}
							npc.StartPathing();
							f_NpcTurnPenalty[npc.index] = 0.25;
							npc.PlayMeleeSound();
						}
						else
						{
							npc.m_flAttackHappens = 0.0;
						}
					}
				}
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2) 	
				{
					npc.SetActivity("ACT_CALMATICUS_RUN");
					npc.m_iChanged_WalkCycle = 2;
					npc.m_bisWalking = true;
					npc.m_flSpeed = 300.0;
					if(npc.Anger)
							npc.m_flSpeed = 350.0;
					npc.StartPathing();
					f_NpcTurnPenalty[npc.index] = 1.0;
				}
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
		if(fl_OverrideWalkDest[npc.index] < gameTime)
		{
			if(flDistanceToTarget < npc.GetLeadRadius()) 
			{
				float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
				npc.SetGoalVector(vPredictedPos);
			} 
			else 
			{
				npc.SetGoalEntity(npc.m_iTarget);
			}	
		}


		int ActionToTake = -1;

		npc.m_flRangedArmor = 1.0;	//Due to his speed, ranged will deal less
		if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(i_GunMode[npc.index] == 0)
		{
			if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.50) && npc.m_flNextMeleeAttack < GetGameTime(npc.index))
			{
				ActionToTake = 1;
			}
			else if(flDistanceToTarget > (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.50) && npc.m_flNextRangedAttack < GetGameTime(npc.index))
			{
				ActionToTake = 2;
			}
		}
		else if(i_GunMode[npc.index] == 1)
		{
			if(npc.m_flJumpStartTime < GetGameTime(npc.index))
			{
				ActionToTake = 3;
			}			
		}

		/*
		TODO:
		If didnt attack for abit, sprints and grabs someone
		Can dodge projetiles and then equip rocket launcher to retaliate
		Same with minigun, its random what he chooses
		During any melee animation he does, he will ggain 50% ranged resistance
		Make him instantly crush any NPC enemy basically, mainly aoe attacks only
		all his attacks will be aoe and dodgeable easily

		Main threat is trying to do massive damage to him and taking him down before the timer runs out, being too greedy kill you, being too safe makes you lose with a timer.
		Most effective way is backstabbing during melee attacks.
		*/

		switch(ActionToTake)
		{
			case 1:
			{
				npc.m_flNextMeleeAttack = gameTime + 2.5;
				npc.m_flDoingAnimation = gameTime + 2.5;
				npc.m_flAttackHappens = gameTime + 1.25;
				float flPos[3]; // original
				float flAng[3]; // original
				npc.GetAttachment("anim_attachment_LH", flPos, flAng);
				if(IsValidEntity(npc.m_iWearable5))
					RemoveEntity(npc.m_iWearable5);
		
				npc.m_iWearable5 = ParticleEffectAt(flPos, "spell_fireball_small_red", 1.0);
				TeleportEntity(npc.m_iWearable5, flPos, flAng, NULL_VECTOR);
				SetParent(npc.index, npc.m_iWearable5, "anim_attachment_LH");
				f_NemesisHitBoxStart[npc.index] = gameTime + 0.45;
				f_NemesisHitBoxEnd[npc.index] = gameTime + 1.0;
				f_NemesisCauseInfectionBox[npc.index] = gameTime + 1.0;

				if(npc.m_iChanged_WalkCycle != 15) 
				{
					npc.FaceTowards(vecTarget, 99999.9);
					npc.SetActivity("ACT_CALMATICUS_ATTACK_LEFT");
					npc.SetPlaybackRate(0.6);
					npc.m_iChanged_WalkCycle = 15;
					npc.m_bisWalking = false;
					if(XenoExtraLogic())
					{
						npc.m_flSpeed = 150.0;
						if(npc.Anger)
							npc.m_flSpeed = 200.0;
					}
					else
					{
						npc.m_flSpeed = 50.0;
						if(npc.Anger)
							npc.m_flSpeed = 100.0;
					}
					npc.StartPathing();
					f_NpcTurnPenalty[npc.index] = 0.25;
					npc.PlayMeleeSound();
				}
			}
			case 2:
			{
				npc.m_flNextRangedAttack = gameTime + 35.0;
				npc.m_flNextRangedAttackHappening = gameTime + 7.5;
				npc.flXenoInfectedSpecialHurtTime = gameTime + 1.25;
				npc.SetCycle(0.15);
				npc.m_flDoingAnimation = gameTime + 7.55;

				if(npc.m_iChanged_WalkCycle != 4) 
				{
					npc.PlayAngerSound();
					if(XenoExtraLogic())
						npc.SetActivity("ACT_CALMATICUS_CHARGE_START_LAB");
					else
						npc.SetActivity("ACT_CALMATICUS_CHARGE_START");
					npc.m_iChanged_WalkCycle = 4;
					npc.m_bisWalking = false;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
					f_NpcTurnPenalty[npc.index] = 1.0;
				}
			}
			case 3:
			{
				npc.m_flJumpStartTime = gameTime + 0.1;
				npc.FaceTowards(vecTarget, 99999.9);

				PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1300.0, _,vecTarget);
				float VecSave[3];
				VecSave = vecTarget;
				npc.PlayRangedSoundMinigun();

				for(int repeat = 1; repeat <= 2; repeat++)
				{
					vecTarget = VecSave;
					//	if(flDistanceToTarget < 1000000.0)	// 1000 HU

					vecTarget[0] += GetRandomFloat(-50.0,50.0);
					vecTarget[1] += GetRandomFloat(-50.0,50.0);
					vecTarget[2] += GetRandomFloat(-50.0,50.0);

					i_GunAmmo[npc.index] -= 1;
					//nemesis failsafe.
					if(npc.m_iChanged_WalkCycle != 10) 	
					{
						i_GunMode[npc.index] = 1;
						i_GunAmmo[npc.index] = 250;
						npc.SetActivity("ACT_CALMATICUS_MINIGUN_WALK");
						npc.m_iChanged_WalkCycle = 10;
						npc.m_bisWalking = true;
						npc.m_flSpeed = 50.0;
						if(npc.Anger)
							npc.m_flSpeed = 100.0;

						npc.StartPathing();
						f_NpcTurnPenalty[npc.index] = 1.0;
					}	
						
					float damage = 105.0;

					if(npc.Anger)
					{
						damage = 150.0;
					}
					npc.FireRocket(vecTarget, damage, 1300.0, "models/weapons/w_bullet.mdl", 2.0,_, 45.0);	
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

	
public Action RaidbossNemesis_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;
		
	RaidbossNemesis npc = view_as<RaidbossNemesis>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	return Plugin_Changed;
}

public void RaidbossNemesis_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(victim);
	if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}
		RaidModeTime += 10.0;
		i_GunMode[npc.index] = 1;
		i_GunAmmo[npc.index] = 250;
		fl_StopDodgeCD[npc.index] = GetGameTime(npc.index) + 50.0;
		npc.m_flAttackHappens = 0.0;
		f_NemesisSpecialDeathAnimation[npc.index] = GetGameTime(npc.index);
		npc.PlayBoomSound();
		npc.Anger = true; //	>:(

		int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
		if(IsValidEntity(client))
		{
			AcceptEntityInput(client, "ClearParent");
			b_NoGravity[client] = false;
			npc.SetVelocity({0.0,0.0,0.0});
			if(IsValidClient(client))
			{
				SetEntityMoveType(client, MOVETYPE_WALK); //can move XD
				SetEntityCollisionGroup(client, 5);
			}
			
			float pos[3];
			float Angles[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);

			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			TeleportEntity(client, pos, Angles, NULL_VECTOR);
		}	
	}
}

public void RaidbossNemesis_NPCDeath(int entity)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	int client = EntRefToEntIndex(i_GrabbedThis[npc.index]);
	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s",WhatDifficultySetting_Internal);
	WavesUpdateDifficultyName();

	if(IsValidEntity(client))
	{
		AcceptEntityInput(client, "ClearParent");
		b_NoGravity[client] = false;
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
		SetVariantString("calmaticus_death");
		AcceptEntityInput(entity_death, "SetAnimation");
		SetVariantInt(4);
		AcceptEntityInput(entity_death, "SetBodyGroup");
		SetEntityRenderColor(entity_death, 65, 255, 65, 255);		
		CClotBody npcstuff = view_as<CClotBody>(entity_death);
		npcstuff.m_iWearable6 = npcstuff.EquipItem("weapon_bone" ,"models/workshop/player/items/pyro/hw2013_mucus_membrane/hw2013_mucus_membrane.mdl");
		
		CreateTimer(15.0, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(15.0, Timer_RemoveEntity, EntIndexToEntRef(npcstuff.m_iWearable6), TIMER_FLAG_NO_MAPCHANGE);

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
	if(i_RaidGrantExtra[npc.index] == 1 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		for (int client_repat = 1; client_repat <= MaxClients; client_repat++)
		{
			if(IsValidClient(client_repat) && GetClientTeam(client_repat) == 2 && TeutonType[client_repat] != TEUTON_WAITING && PlayerPoints[client_repat	] > 500)
			{
				if(!XenoExtraLogic())
				{
					Items_GiveNamedItem(client_repat, "Calmaticus' Heart Piece");
					CPrintToChat(client_repat, "{default}You cut its heart to ensure his death and gained: {green}''Calmaticus' Heart Piece''{default}!");
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

void Nemesis_TryDodgeAttack(int entity)
{
	RaidbossNemesis npc = view_as<RaidbossNemesis>(entity);
	bool RocketInfrontOfMe = false;

	float flMyPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", flMyPos);
	static float hullcheckmaxs_Player[3];
	static float hullcheckmins_Player[3];
	flMyPos[2] += 18.0; //Step height.
	
	float ang[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	ang[0] = 0.0; //I dont want him to go up or down with his prediction.
	float vecForward_2[3];
			
	GetAngleVectors(ang, vecForward_2, NULL_VECTOR, NULL_VECTOR);
					
	float vecSwingStart_2[3]; vecSwingStart_2 = flMyPos;
				
	float ExtraDistance = 250.0;
	float vecSwingEnd_2[3];
	vecSwingEnd_2[0] = vecSwingStart_2[0] + vecForward_2[0] * ExtraDistance;
	vecSwingEnd_2[1] = vecSwingStart_2[1] + vecForward_2[1] * ExtraDistance;
	vecSwingEnd_2[2] = vecSwingStart_2[2] + vecForward_2[2] * ExtraDistance;

	if(b_IsGiant[entity])
	{
		hullcheckmaxs_Player = view_as<float>( { 30.0, 30.0, 80.0 } );
		hullcheckmins_Player = view_as<float>( { -30.0, -30.0, 0.0 } );	
	}
	else
	{
		hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 42.0 } );
		hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );		
	}

	Handle hTrace = TR_TraceHullFilterEx(vecSwingEnd_2, flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, MASK_PLAYERSOLID, TraceRayHitProjectilesOnly, entity);
	int ref = TR_GetEntityIndex(hTrace);
	if(IsValidEntity(ref))
	{
		ref = EntRefToEntIndex(ref);
		RocketInfrontOfMe = true;
	}
	delete hTrace;

	if(RocketInfrontOfMe)
	{
		if(fl_StopDodgeCD[npc.index] < GetGameTime(npc.index))
		{
			if(npc.m_iChanged_WalkCycle != 8) 
			{
				b_IgnoredByPlayerProjectiles[npc.index] = true;

				float PosToDodgeTo[3];

				npc.SetActivity("ACT_CALMATICUS_MINIGUN_DODGE");
				npc.m_iChanged_WalkCycle = 8;
				npc.m_bisWalking = false;
				npc.m_bAllowBackWalking = true;
				npc.m_flSpeed = 600.0;

				fl_OverrideWalkDest[npc.index] = GetGameTime(npc.index) + 1.5;
				if(IsValidEntity(npc.m_iTarget))
				{
					float vecTarget[3]; WorldSpaceCenter(ref, vecTarget);
					npc.FaceTowards(vecTarget);
				}
				npc.SetGoalVector(PosToDodgeTo);
				npc.StartPathing();
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 1.55;
				fl_StopDodge[npc.index] = GetGameTime(npc.index) + 0.5;
				fl_StopDodgeCD[npc.index] = GetGameTime(npc.index) + 50.0;
				fl_RegainWalkAnim[npc.index] = GetGameTime(npc.index) + 1.5;
				f_NpcTurnPenalty[npc.index] = 1.0;
			}
		}
	}
}

public bool TraceRayHitProjectilesOnly(int entity,int mask,any data)
{
	if(entity == 0)
	{
		return false;
	}
	if(b_IsAProjectile[entity] && GetTeam(entity) == TFTeam_Red)
	{
		return true;
	}
	
	return false;
}


void Nemesis_AreaAttack(int entity, float damage, float m_vecMins_1[3], float m_vecMaxs_1[3], char[] Attachment ="anim_attachment_LH", int who = 1)
{
	if(who == 1)
	{
		RaidbossNemesis npc = view_as<RaidbossNemesis>(entity);
		//focus a box around a certain part of the body, the arm for example.					
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment(Attachment, flPos, flAng);

		static float m_vecMaxs[3];
		static float m_vecMins[3];
		m_vecMaxs = m_vecMaxs_1;
		m_vecMins = m_vecMins_1;	

		for (int i = 1; i < MAXENTITIES; i++)
		{
			i_NemesisEntitiesHitAoeSwing[i] = -1;
		}
		Handle hTrace = TR_TraceHullFilterEx(flPos, flPos, m_vecMins, m_vecMaxs, MASK_SOLID, Nemeis_AoeAttack, entity);
		delete hTrace;
		bool HitEnemy = false;
		for (int counter = 1; counter < MAXENTITIES; counter++)
		{
			if (i_NemesisEntitiesHitAoeSwing[counter] != -1)
			{
				if(IsValidEntity(i_NemesisEntitiesHitAoeSwing[counter]) && f_NemesisEnemyHitCooldown[i_NemesisEntitiesHitAoeSwing[counter]] < GetGameTime())
				{
					HitEnemy = true;
					f_NemesisEnemyHitCooldown[i_NemesisEntitiesHitAoeSwing[counter]] = GetGameTime() + 0.25;
					SDKHooks_TakeDamage(i_NemesisEntitiesHitAoeSwing[counter], npc.index, npc.index, damage, DMG_CLUB, -1);
					Custom_Knockback(entity, i_NemesisEntitiesHitAoeSwing[counter], 1000.0, true); 
					npc.PlayMeleeHitSound();
					if(i_NemesisEntitiesHitAoeSwing[counter] <= MaxClients)
						Client_Shake(i_NemesisEntitiesHitAoeSwing[counter], 0, 20.0, 20.0, 1.0, false);
				}
			}
			else
			{
				break;
			}
		}
		if(HitEnemy)
			npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment(Attachment), PATTACH_POINT_FOLLOW, true);
	}
	else
	{
		RaidbossMrX npc = view_as<RaidbossMrX>(entity);
		//focus a box around a certain part of the body, the arm for example.					
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment(Attachment, flPos, flAng);

		static float m_vecMaxs[3];
		static float m_vecMins[3];
		m_vecMaxs = m_vecMaxs_1;
		m_vecMins = m_vecMins_1;	

		for (int i = 1; i < MAXENTITIES; i++)
		{
			i_NemesisEntitiesHitAoeSwing[i] = -1;
		}
		Handle hTrace = TR_TraceHullFilterEx(flPos, flPos, m_vecMins, m_vecMaxs, MASK_SOLID, Nemeis_AoeAttack, entity);
		delete hTrace;
		bool HitEnemy = false;
		for (int counter = 1; counter < MAXENTITIES; counter++)
		{
			if (i_NemesisEntitiesHitAoeSwing[counter] != -1)
			{
				if(IsValidEntity(i_NemesisEntitiesHitAoeSwing[counter]) && f_NemesisEnemyHitCooldown[i_NemesisEntitiesHitAoeSwing[counter]] < GetGameTime())
				{
					HitEnemy = true;
					f_NemesisEnemyHitCooldown[i_NemesisEntitiesHitAoeSwing[counter]] = GetGameTime() + 0.15;
					SDKHooks_TakeDamage(i_NemesisEntitiesHitAoeSwing[counter], npc.index, npc.index, damage, DMG_CLUB, -1);
					Custom_Knockback(entity, i_NemesisEntitiesHitAoeSwing[counter], 1000.0, true); 
					npc.PlayMeleeHitSound();
					if(i_NemesisEntitiesHitAoeSwing[counter] <= MaxClients)
						Client_Shake(i_NemesisEntitiesHitAoeSwing[counter], 0, 20.0, 20.0, 1.0, false);
				}
			}
			else
			{
				break;
			}
		}
		if(HitEnemy)
			npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment(Attachment), PATTACH_POINT_FOLLOW, true);
	}
}

static bool Nemeis_AoeAttack(int entity, int contentsMask, int filterentity)
{
	if(IsValidEnemy(filterentity,entity, true, true))
	{
		for(int i=1; i < (MAXENTITIES); i++)
		{
			if(i_NemesisEntitiesHitAoeSwing[i] == -1)
			{
				i_NemesisEntitiesHitAoeSwing[i] = entity;
				break;
			}
		}
	}
	return false;
}

public Action CheckStuckNemesis(Handle timer, any entid)
{
	int client = EntRefToEntIndex(entid);
	if(IsValidEntity(client))
	{
		b_DoNotUnStuck[client] = false;
		float flMyPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", flMyPos);
		static float hullcheckmaxs_Player[3];
		static float hullcheckmins_Player[3];

		if(IsValidClient(client)) //Player size
		{
			hullcheckmaxs_Player = view_as<float>( { 24.0, 24.0, 82.0 } );
			hullcheckmins_Player = view_as<float>( { -24.0, -24.0, 0.0 } );		
		}
		
		if(IsSpaceOccupiedIgnorePlayers(flMyPos, hullcheckmins_Player, hullcheckmaxs_Player, client))
		{
			if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
			{
				int damage = SDKCall_GetMaxHealth(client) / 8;
				SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
			}
			TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
		}
		else
		{
			int tank = EntRefToEntIndex(i_TankAntiStuck[client]);
			if(IsValidEntity(tank))
			{
				bool Hit_something = Can_I_See_Enemy_Only(tank, client);
				//Target close enough to hit
				if(!Hit_something)
				{	
					if(IsValidClient(client)) //Player Unstuck, but give them a penalty for doing this in the first place.
					{
						int damage = SDKCall_GetMaxHealth(client) / 8;
						SDKHooks_TakeDamage(client, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR);
					}
					TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
				}
			}
			else
			{
				//Just teleport back, dont fucking risk it.
				TeleportEntity(client, f3_LastValidPosition[client], NULL_VECTOR, { 0.0, 0.0, 0.0 });
			}
		}
	}
	return Plugin_Handled;
}



stock float[] Nemesis_DodgeToDirection(CClotBody npc, float extra_backoff = 64.0, float Angle = -90.0)
{
	float botPos[3];
	WorldSpaceCenter(npc.index, botPos);
	
	// compute our desired destination
	float pathTarget[3];
	
		
	//https://forums.alliedmods.net/showthread.php?t=278691 im too stupid for vectors.
	float ang[3];
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	ang[0] = 0.0; //I dont want him to go up or down with his prediction.
	ang[1] += Angle; //try to the left/right.
	float vecForward_2[3];
			
	GetAngleVectors(ang, vecForward_2, NULL_VECTOR, NULL_VECTOR);
					
	float vecSwingStart_2[3]; vecSwingStart_2 = botPos;
				
	float vecSwingEnd_2[3];
	vecSwingEnd_2[0] = vecSwingStart_2[0] + vecForward_2[0] * extra_backoff;
	vecSwingEnd_2[1] = vecSwingStart_2[1] + vecForward_2[1] * extra_backoff;
	vecSwingEnd_2[2] = vecSwingStart_2[2] + vecForward_2[2] * extra_backoff;
			
	Handle trace_2; 
			
	trace_2 = TR_TraceRayFilterEx(botPos, vecSwingEnd_2, MASK_SOLID, RayType_EndPoint, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
	TR_GetEndPosition(pathTarget, trace_2);

	delete trace_2;

	Handle trace_3; //2nd one, make sure to actually hit the ground!
	
	trace_3 = TR_TraceRayFilterEx(pathTarget, {89.0, 1.0, 0.0}, MASK_SOLID, RayType_Infinite, HitOnlyTargetOrWorld, 0); //If i hit a wall, i stop retreatring and accept death, for now!
	
	TR_GetEndPosition(pathTarget, trace_3);
	
	delete trace_3;
	
	/*
	int g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
	TE_SetupBeamPoints(botPos, pathTarget, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 30, 5.0, 1.0, 0.1, 5, 0.0, view_as<int>({255, 0, 255, 255}), 30);
	TE_SendToAll();
	*/
	
	pathTarget[2] += 20.0; //Clip them up, minimum crouch level preferred, or else the bots get really confused and sometimees go otther ways if the player goes up or down somewhere, very thin stairs break these bots.
	
	return pathTarget;
}

#define MAX_TARGETS_HIT_NEMESIS 64

void Nemesis_DoInfectionThrow(int entity, int MaxThrowCount)
{
	float Nemesis_Loc[3];
	//poisition of the enemy we random decide to shoot.
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Nemesis_Loc);

	Nemesis_Loc[2] += 10.0;
	spawnRing_Vectors(Nemesis_Loc, INFECTION_RANGE * 3.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, InfectionDelay(), 5.0, 0.0, 1,1.0);	
	
	float Nemesis_Ang[3];
	Nemesis_Ang = {-90.0,0.0,0.0};
	int particle = ParticleEffectAt(Nemesis_Loc, "green_steam_plume", 1.0);
	TeleportEntity(particle, NULL_VECTOR, Nemesis_Ang, NULL_VECTOR);

	DataPack pack;
	CreateDataTimer(InfectionDelay(), Nemesis_DoInfectionThrowInternal, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
	pack.WriteCell(MaxThrowCount); 	//who this attack belongs to
}
public Action Nemesis_DoInfectionThrowInternal(Handle timer, DataPack DataNem)
{
	DataNem.Reset();
	int entity = EntRefToEntIndex(DataNem.ReadCell());
	int MaxThrowCount = DataNem.ReadCell();
	
	if(!IsValidEntity(entity))
		return Plugin_Stop;

	int count;
	int targets[MAX_TARGETS_HIT_NEMESIS];

		
	for(int client; client<=MaxClients; client++)
	{
		if(IsValidEntity(client) && IsValidEnemy(entity, client, false, false))
		{
			bool Hit_something = Can_I_See_Enemy_Only(entity, client);
			//Target close enough to hit
			if(Hit_something)
			{	
				if(count < MAX_TARGETS_HIT_NEMESIS)
				{
					targets[count++] = client;
				}
				else
				{
					break;
				}
			}
		}
	}
	for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
	{
		int enemy = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
		if(IsValidEntity(enemy) && IsValidEnemy(entity, enemy, false, false))
		{
			bool Hit_something = Can_I_See_Enemy_Only(entity, enemy);
			//Target close enough to hit
			if(Hit_something)
			{	
				if(count < MAX_TARGETS_HIT_NEMESIS)
				{
					targets[count++] = enemy;
				}
				else
				{
					break;
				}
			}
		}
	}

	SortIntegers(targets, count, Sort_Random);

	for(int Repeat; Repeat<MaxThrowCount; Repeat++)
	{
		if(count)
		{
			// Choosen a random one in our list
			count--;	// This decreases the max entries
			int target = targets[count];	// This grabs the entry at the very end
			
			float VicLoc[3];

			//poisition of the enemy we random decide to shoot.
			GetEntPropVector(target, Prop_Data, "m_vecAbsOrigin", VicLoc);

			VicLoc[2] += 10.0;
			spawnRing_Vectors(VicLoc, INFECTION_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, InfectionDelay(), 5.0, 0.0, 1);	
			VicLoc[2] -= 5.0;
			spawnRing_Vectors(VicLoc, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, InfectionDelay(), 5.0, 0.0, 1,INFECTION_RANGE * 2.0);	
			
			float damage = 500.0;

			DataPack pack;
			CreateDataTimer(InfectionDelay(), Nemesis_Infection_Throw, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
			pack.WriteCell(damage);
			pack.WriteCell(VicLoc[0]);
			pack.WriteCell(VicLoc[1]);
			pack.WriteCell(VicLoc[2]);
		}
	}
	return Plugin_Stop;
}

public Action Nemesis_Infection_Throw(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadCell();
	float origin[3];
	origin[0] = pack.ReadCell();
	origin[1] = pack.ReadCell();
	origin[2] = pack.ReadCell();
	if(IsValidEntity(entity))
	{
		Explode_Logic_Custom(damage, entity, entity, -1, origin, INFECTION_RANGE, _, _, true, _, _, 1.0, NemesisHitInfection);
		int particle = ParticleEffectAt(origin, "green_wof_sparks", 1.0);
		float Ang[3];
		Ang[0] = -90.0;
		TeleportEntity(particle, NULL_VECTOR, Ang, NULL_VECTOR);
		EmitSoundToAll("weapons/cow_mangler_explode.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, origin);
	}
	return Plugin_Stop;
}


void NemesisHitInfection(int entity, int victim, float damage, int weapon)
{
	if(f_NemesisImmuneToInfection[victim] < GetGameTime())
	{
		//this wont work on npcs, too unfair.
		if(IsValidClient(victim) && !IsInvuln(victim))
		{
			f_NemesisImmuneToInfection[victim] = GetGameTime() + 15.0;
			float HudY = -1.0;
			float HudX = -1.0;
			SetHudTextParams(HudX, HudY, 3.0, 50, 255, 50, 255);
			ShowHudText(victim, -1, "%T", "You have been Infected by Calmaticus", victim);
			ClientCommand(victim, "playgamesound items/powerup_pickup_plague_infected.wav");		
			int InfectionCount = 15;
			StartBleedingTimer(victim, entity, 150.0, InfectionCount, -1, DMG_TRUEDAMAGE, 0, 1);
		}
	}
}


public void Raidmode_Nemesis_Win(int entity)
{
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(RaidBossActive == EntIndexToEntRef(entity) && i_RaidGrantExtra[entity] == 1)
	{
		if(XenoExtraLogic())
		{
			CPrintToChatAll("{crimson}You afterall... had no chance.");
		}
		else
		{
			CPrintToChatAll("{snow}???{default}: Good job Calmaticus, head back to the lab.");
		}
	}
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}
