#pragma semicolon 1
#pragma newdecls required

#define BOB_FIRST_LIGHTNING_RANGE 100.0

#define BOB_CHARGE_TIME 1.5
#define BOB_CHARGE_SPAN 0.5

#define BOB_MELEE_SIZE 35
#define BOB_MELEE_SIZE_F 35.0

#define BOB_NO_PULL_RANGE 500.0

//no support for multiple
bool b_EnemyCloseToMainBob[MAXENTITIES];
bool b_BobPistolPhase[MAXENTITIES];
bool b_BobPistolPhaseSaid[MAXENTITIES];
//used for gun prediction too

static const char g_IntroStartSounds[][] =
{
	"npc/combine_soldier/vo/overwatchtargetcontained.wav",
	"npc/combine_soldier/vo/overwatchtarget1sterilized.wav"
};

static const char g_IntroEndSounds[][] =
{
	"npc/combine_soldier/vo/overwatchreportspossiblehostiles.wav"
};

static const char g_SummonSounds[][] =
{
	"npc/combine_soldier/vo/overwatchrequestreinforcement.wav"
};

static const char g_SkyShieldSounds[][] =
{
	"npc/combine_soldier/vo/overwatchrequestskyshield.wav"
};

static const char g_SpeedUpSounds[][] =
{
	"npc/combine_soldier/vo/ovewatchorders3ccstimboost.wav"
};

static const char g_SummonDiedSounds[][] =
{
	"npc/combine_soldier/vo/overwatchteamisdown.wav"
};

static const char PullRandomEnemyAttack[][] =
{
	"weapons/physcannon/energy_sing_explosion2.wav"
};

static const char g_MeleeHitSounds[][] =
{
	"weapons/pickaxe_swing3.wav",
	"weapons/pickaxe_swing2.wav",
	"weapons/pickaxe_swing1.wav",
};

static const char g_MeleeAttackSounds[][] =
{
	"weapons/saxxy_turntogold_05.wav"
};

static const char g_RangedAttackSounds[][] =
{
	"weapons/physcannon/physcannon_claws_close.wav"
};
static const char g_RangedGunSounds[][] =
{
	"weapons/pistol/pistol_fire2.wav",
};
static const char g_RangedSpecialAttackSounds[][] =
{
	"mvm/sentrybuster/mvm_sentrybuster_spin.wav"
};

static const char g_BoomSounds[][] =
{
	"mvm/mvm_tank_explode.wav"
};

static const char g_BuffSounds[][] =
{
	"player/invuln_off_vaccinator.wav"
};

static const char g_FireRocketHoming[][] =
{
	"weapons/cow_mangler_explosion_charge_04.wav",
	"weapons/cow_mangler_explosion_charge_05.wav",
	"weapons/cow_mangler_explosion_charge_06.wav",
};


static const char g_BobSuperMeleeCharge[][] =
{
	"weapons/vaccinator_charge_tier_01.wav",
	"weapons/vaccinator_charge_tier_02.wav",
	"weapons/vaccinator_charge_tier_03.wav",
	"weapons/vaccinator_charge_tier_04.wav",
};

static const char g_BobSuperMeleeCharge_Hit[][] =
{
	"player/taunt_yeti_standee_break.wav",
};


void RaidbossBobTheFirst_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "?????????????");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_first_last_savior");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);

	
	//download fixes
	strcopy(data.Name, sizeof(data.Name), "?????????????");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_first_last_savior_sealogic");
	data.IconCustom = false;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecacheSea;
	NPC_Add(data);

	
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_IntroStartSounds);
	PrecacheSoundArray(g_IntroEndSounds);
	PrecacheSoundArray(g_SummonSounds);
	PrecacheSoundArray(g_SkyShieldSounds);
	PrecacheSoundArray(g_SpeedUpSounds);
	PrecacheSoundArray(g_SummonDiedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedGunSounds);
	PrecacheSoundArray(g_RangedSpecialAttackSounds);
	PrecacheSoundArray(g_BoomSounds);
	PrecacheSoundArray(g_BuffSounds);
	PrecacheSoundArray(PullRandomEnemyAttack);
	PrecacheSoundArray(g_FireRocketHoming);
	PrecacheSoundArray(g_BobSuperMeleeCharge);
	PrecacheSoundArray(g_BobSuperMeleeCharge_Hit);
	
	PrecacheSoundCustom("#zombiesurvival/bob_raid/bob_intro.mp3");
	PrecacheSoundCustom("#zombiesurvival/bob_raid/bob_loop.mp3");
}

static void ClotPrecacheSea()
{
	ClotPrecache();
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/special_mutation/incomming_boss_wait_scary.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossBobTheFirst(vecPos, vecAng, team, data);
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
	public void PlaySummonSound()
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)]);
	}
	public void PlaySkyShieldSound()
	{
		EmitSoundToAll(g_SkyShieldSounds[GetRandomInt(0, sizeof(g_SkyShieldSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySpeedUpSound()
	{
		EmitSoundToAll(g_SpeedUpSounds[GetRandomInt(0, sizeof(g_SpeedUpSounds) - 1)]);
	}
	public void PlaySummonDeadSound()
	{
		EmitSoundToAll(g_SummonDiedSounds[GetRandomInt(0, sizeof(g_SummonDiedSounds) - 1)]);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(90,110));
	}
	public void PlayRangedSound()
	{
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_RangedGunSounds[GetRandomInt(0, sizeof(g_RangedGunSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	public void PlayRandomEnemyPullSound()
	{
		EmitSoundToAll(PullRandomEnemyAttack[GetRandomInt(0, sizeof(PullRandomEnemyAttack) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME - 0.1);
	}
	public void PlayRocketHoming()
	{
		EmitSoundToAll(g_FireRocketHoming[GetRandomInt(0, sizeof(g_FireRocketHoming) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBobMeleePreHit()
	{
		EmitSoundToAll(g_BobSuperMeleeCharge[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, GetRandomInt(80,90));
	}
	public void PlayBobMeleePostHit()
	{
		int pitch = GetRandomInt(70,80);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
		EmitSoundToAll(g_BobSuperMeleeCharge_Hit[GetRandomInt(0, sizeof(g_BobSuperMeleeCharge_Hit) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}
	property int m_iAttackType
	{
		public get()		{	return this.m_iOverlordComboAttack;	}
		public set(int value) 	{	this.m_iOverlordComboAttack = value;	}
	}
	property int m_iPullCount
	{
		public get()		{	return this.m_iMedkitAnnoyance;	}
		public set(int value) 	{	this.m_iMedkitAnnoyance = value;	}
	}
	property bool m_bSecondPhase
	{
		public get()		{	return this.m_bNextRangedBarrage_OnGoing;	}
		public set(bool value)	{	this.m_bNextRangedBarrage_OnGoing = value;	}
	}	
	property bool b_SwordIgnition
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}
	property bool m_bFakeClone
	{
		public get()		{	return i_RaidGrantExtra[this.index] < 0;	}
	}
	property float m_flOverrideMusicNow
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}

	public RaidbossBobTheFirst(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		float pos[3];
		pos = vecPos;
		bool SmittenNpc = false;
		
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(IsValidEntity(entity))
			{
				char npc_classname[60];
				NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));

				if(entity != INVALID_ENT_REFERENCE && (StrEqual(npc_classname, "npc_stella") || StrEqual(npc_classname, "npc_karlas")) && IsEntityAlive(entity))
				{
					GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
					SmiteNpcToDeath(entity);
					SmittenNpc = true;
				}
			}
		}

		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(CClotBody(pos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "20000000", ally, _, _, true, false));
		
		i_NpcWeight[npc.index] = 4;
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MUDROCK_RAGE");
		b_NpcIsInvulnerable[npc.index] = true;

		npc.PlayIntroStartSound();

		func_NPCDeath[npc.index] = RaidbossBobTheFirst_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossBobTheFirst_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossBobTheFirst_ClotThink;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
		
		if(StrContains(data, "final_item") != -1)
		{
			RemoveAllDamageAddition();
			b_NpcUnableToDie[npc.index] = true;
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_BobFirst_Win);
			i_RaidGrantExtra[npc.index] = 1;
			npc.m_flNextDelayTime = GetGameTime(npc.index) + 10.0;
			npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 10.0;
			npc.g_TimesSummoned = 0;
			WaveStart_SubWaveStart(GetGameTime() + 500.0);
			//this shouldnt ever start, no anti delay here.

			if(StrContains(data, "nobackup") != -1)
			{
				npc.m_flNextDelayTime = 0.0;
				npc.m_bSecondPhase = true;
				npc.g_TimesSummoned = -2;
			}
			else
			{
				npc.m_bSecondPhase = false;
			}
		}
		else if(StrContains(data, "nobackup") != -1)
		{
			RemoveAllDamageAddition();
			npc.m_bSecondPhase = true;
			npc.g_TimesSummoned = -2;
		}
		else if(StrContains(data, "fake") != -1)
		{
			npc.m_bSecondPhase = false;
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = -1;
			b_DoNotUnStuck[npc.index] = true;
			b_ThisNpcIsImmuneToNuke[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
			b_ThisEntityIgnoredBeingCarried[npc.index] = true; //cant be targeted AND wont do npc collsiions
		}
		else
		{
			RemoveAllDamageAddition();
			npc.m_bSecondPhase = false;
			npc.m_flNextDelayTime = GetGameTime(npc.index) + 5.0;
			npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + 5.0;
			npc.SetPlaybackRate(2.0);
			npc.g_TimesSummoned = 0;
			WaveStart_SubWaveStart(GetGameTime() + 500.0);
		}

		/*
			Cosmetics
		*/
		
		SetVariantInt(1);	// Combine Model
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		/*
			Variables
		*/

		npc.m_bDissapearOnDeath = true;
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_COMBINE;

		if(!npc.m_bFakeClone)
		{
			npc.m_bThisNpcIsABoss = true;
			b_thisNpcIsARaid[npc.index] = true;
			npc.m_flMeleeArmor = 1.25;
			RemoveAllDamageAddition();
		}

		npc.Anger = false;
		npc.m_flSpeed = 340.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_iAttackType = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iPullCount = 0;
		b_BobPistolPhase[npc.index] = false;
		Zero(b_BobPistolPhaseSaid);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Enable");
		IgniteTargetEffect(npc.m_iWearable1);
		npc.b_SwordIgnition = true;

		if(!npc.m_bFakeClone)
		{
			strcopy(WhatDifficultySetting, sizeof(WhatDifficultySetting), "You.");
			WavesUpdateDifficultyName();
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/bob_raid/bob_intro.mp3");
			music.Time = 44;
			music.Volume = 1.99;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Irln Last Stand against the Sea Intro");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music, true);

		
			npc.m_flOverrideMusicNow = GetGameTime() + 5.0;
			npc.StopPathing();

			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;
			RaidModeTime = GetGameTime() + 292.0;
			RaidModeScaling = 0.0;
			Zero(b_EnemyCloseToMainBob);
		}

		strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "?????????????");
		if(SmittenNpc)
		{
			if(CurrentModifOn() == 1)
			{
				CPrintToChatAll("{white}%s{default}: 혼돈이 사방에 퍼져있어. 우린 너무 늦었어. 나와 함께 하자. 공격하지 말고.\n네 결백을 증명해봐.", NpcStats_ReturnNpcName(npc.index, true));
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{white}%s{default}: 내가 처리하지.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{white}%s{default}: 스텔라, 카를라스, 충분히 잘 해줬다. 이제 뒤로 물러나라.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{white}%s{default}: 나는 감염과 그 약점에 대해 충분히 알고 있어. 그러니 내가 널 막겠다.", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
			}
		}
		
		return npc;
	}
}

public void RaidbossBobTheFirst_ClotThink(int iNPC)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(iNPC);
	
	if(npc.m_flOverrideMusicNow)
	{
		if(npc.m_flOverrideMusicNow < GetGameTime())
		{
			npc.m_flOverrideMusicNow = 0.0;
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/bob_raid/bob_loop.mp3");
			music.Time = 181;
			music.Volume = 1.85;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Irln Last Stand against the Sea");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music, false);
		}
	}	
	float gameTime = GetGameTime(npc.index);

	if(npc.Anger || npc.m_bFakeClone || i_RaidGrantExtra[npc.index] > 1)
	{
		b_NpcIsInvulnerable[npc.index] = true;
	}
	else
	{
		b_NpcIsInvulnerable[npc.index] = false;
	}

	if(npc.m_flAttackHappens_bullshit > GetGameTime(npc.index))
	{
		b_NpcIsInvulnerable[npc.index] = true;
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
		return;
		
	int healthPoints = 20;

	if(npc.m_bFakeClone)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != INVALID_ENT_REFERENCE && other != npc.index)
			{
				if(i_NpcInternalId[npc.index] == i_NpcInternalId[other])
				{
					if(!view_as<RaidbossBobTheFirst>(other).m_bFakeClone && IsEntityAlive(other) && GetTeam(other) == GetTeam(npc.index))
					{
						if(view_as<RaidbossBobTheFirst>(other).Anger)
						{
							healthPoints = 19;	// During combine summons
							npc.m_flNextMeleeAttack = gameTime + 10.0;
						}
						else
						{
							healthPoints = GetEntProp(other, Prop_Data, "m_iHealth") * 20 / ReturnEntityMaxHealth(other);
						}
						
						break;
					}
				}
			}
		}
	}
	else
	{
		healthPoints = GetEntProp(npc.index, Prop_Data, "m_iHealth") * 20 / ReturnEntityMaxHealth(npc.index);
		if(healthPoints < 3)
		{
			if(!b_BobPistolPhaseSaid[npc.index])
			{
				CPrintToChatAll("{crimson}%s 의 엄청난 의지력으로 인해 그의 힘이 되돌아오고 있다...", NpcStats_ReturnNpcName(npc.index, true));
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{white}%s{default}: 내 높은 명중률이 네 뇌를 빗겨나가길 기도해야겠군. 이제 감염 치료는 선택 사항이다.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 1:
					{
						CPrintToChatAll("{white}%s{default}: 생명을 구하려면 생명을 앗아가야한다니. 적어도 이 권총으로 널 감염으로부터 치유할 수 있다면 좋겠는데.", NpcStats_ReturnNpcName(npc.index, true));
					}
					case 2:
					{
						CPrintToChatAll("{white}%s{default}: 점점 내 한계에 다다르고 있어.", NpcStats_ReturnNpcName(npc.index, true));
					}
				}
				int MaxHealth = ReturnEntityMaxHealth(npc.index);
				HealEntityGlobal(npc.index, npc.index, float((MaxHealth / 10)), 1.0, 0.0, HEAL_ABSOLUTE);
			}
			b_BobPistolPhase[npc.index] = true;
			b_BobPistolPhaseSaid[npc.index] = true;
		}
	}
	if(npc.m_bFakeClone)
	{
		int FellowBobFound = 0;
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != INVALID_ENT_REFERENCE && other != npc.index)
			{
				if(i_NpcInternalId[npc.index] == i_NpcInternalId[other])
				{
					if(!view_as<RaidbossBobTheFirst>(other).m_bFakeClone && IsEntityAlive(other) && GetTeam(other) == GetTeam(npc.index))
					{
						SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(other, Prop_Data, "m_iHealth"));
						SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", ReturnEntityMaxHealth(other));
						FellowBobFound = other;
						break;
					}
				}
			}
		}
		if(!FellowBobFound)
		{
			SmiteNpcToDeath(npc.index);
		}
		else
		{
			//set muh phase!
			b_BobPistolPhase[npc.index] = b_BobPistolPhase[FellowBobFound];
		}
	}
	if(!npc.m_bFakeClone && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{white}%s{default}: 마지막 감염체만 남았다.", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 1:
				{
					CPrintToChatAll("{white}%s{default}: 이 악몽이 곧 끝나겠군.", NpcStats_ReturnNpcName(npc.index, true));
				}
				case 2:
				{
					CPrintToChatAll("{white}%s{default}: 마지막 감염체 확인.", NpcStats_ReturnNpcName(npc.index, true));
				}
			}
		}
	}
	//Raidmode timer runs out, they lost.
	if(!npc.m_bFakeClone && npc.m_flNextThinkTime != FAR_FUTURE && RaidModeTime < GetGameTime())
	{
		if(healthPoints < 20)
		{
			if(IsValidEntity(RaidBossActive))
			{
				ForcePlayerLoss();
			}

			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsClientInGame(client) && IsPlayerAlive(client))
					ForcePlayerSuicide(client);
			}

			switch(GetURandomInt() % 3)
			{
				case 0:
					CPrintToChatAll("{white}%s{default}: 넌 그렇게 허무하게 감염 당해서는 안 됐어.", NpcStats_ReturnNpcName(npc.index, true));
				
				case 1:
					CPrintToChatAll("{white}%s{default}: 널 죽이는 것 외엔 선택지가 없어. 그 감염은 지금도 널 삼키고 있으니까.", NpcStats_ReturnNpcName(npc.index, true));
				
				case 2:
					CPrintToChatAll("{white}%s{default}: 우리 서로 잃은 것만 있는 싸움이었어.", NpcStats_ReturnNpcName(npc.index, true));
			}
			
			// Play funny animation intro
			npc.StopPathing();
			npc.m_flNextThinkTime = FAR_FUTURE;
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_IDLE_ZOMBIE");
		}
		else
		{

			CPrintToChatAll("{white}%s{default}: 날 속일 수 있을거라 생각했나!? 널 끝장내주마!", NpcStats_ReturnNpcName(npc.index, true));
			
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) -1);
			fl_Extra_Damage[npc.index] = 999.9;
			fl_Extra_Speed[npc.index] = 5.0;
			RaidModeTime = FAR_FUTURE;
		}
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
		npc.StopPathing();
		npc.m_flNextThinkTime = FAR_FUTURE;
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_IDLE_SHIELDZOBIE");
		RaidModeTime += 1000.0;

		if(XenoExtraLogic())
		{
			switch(i_RaidGrantExtra[npc.index])
			{
				case 2:
				{
					ReviveAll(true);
					CPrintToChatAll("{white}밥 1세{default}: 그래서...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}밥 1세{default}: 이제 어떻게 해야...?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}밥 1세{default}: 아니... 잠깐... 넌 감염체가 아니라 감염과 싸우고 있었던 거였어! 이건.. 말도 안 돼!");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}밥 1세{default}: 맙소사, 정말 예측불허의 일이 일어났어. 이건, 이건....");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}밥 1세{default}: ...");
					npc.m_flNextThinkTime = gameTime + 2.0;
				}
				case 7:
				{
					GiveProgressDelay(30.0);
					SmiteNpcToDeath(npc.index);
					CPrintToChatAll("{white}밥 1세가 급하게 자리를 떴습니다... 뭔가가 잘못 됐습니다. 그를 따라가야했을까요...? 그러기엔 너무 늦은것 같습니다...");
					MusicEnum music;
					strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/special_mutation/incomming_boss_wait_scary.mp3");
					music.Time = 100;
					music.Volume = 1.0;
					music.Custom = true;
					strcopy(music.Name, sizeof(music.Name), "Howilng Emptiness");
					strcopy(music.Artist, sizeof(music.Artist), "....");
					Music_SetRaidMusic(music);
					GivePlayerItems();
					return;
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
					CPrintToChatAll("{white}밥 1세{default}: 이럴수가...");
					npc.m_flNextThinkTime = gameTime + 5.0;
				}
				case 3:
				{
					CPrintToChatAll("{white}밥 1세{default}: 이 감염...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 4:
				{
					CPrintToChatAll("{white}밥 1세{default}: 이게 도대체 어떻게 널 그리 강하게 만든거지..?");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 5:
				{
					CPrintToChatAll("{white}밥 1세{default}: 넌 모든 시본을 제거하고 그들의 감염을 전부 흡수했어...");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 6:
				{
					CPrintToChatAll("{white}밥 1세{default}: 그 후 넌 다른 세력의 도시들과 감염원들과 싸워나갔지. 그리고 그건 네 의지가 아니었을터.");
					npc.m_flNextThinkTime = gameTime + 4.0;
				}
				case 7:
				{
					CPrintToChatAll("{white}밥 1세{default}: 그러니까...");
					npc.m_flNextThinkTime = gameTime + 3.0;
				}
				case 8:
				{
					CPrintToChatAll("{white}밥 1세{default}: 너의 것이 아닌 그 감염은 내가 제거해주면 될 것 같군.");
					npc.m_flNextThinkTime = gameTime + 3.0;
					CreateTimer(12.0, SafetyFixBobDo, EntIndexToEntRef(npc.index));
				}
				case 50:
				{
					SmiteNpcToDeath(npc.index);
					GivePlayerItems();
				}
				default:
				{
					bool found;

					for(int client = 1; client <= MaxClients; client++)
					{
						if(IsClientInGame(client) && IsPlayerAlive(client) && TeutonType[client] == TEUTON_NONE)
						{
							float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
							float ang[3];
							ang[1] = GetRandomFloat(-179.0, 179.0);

							TeleportEntity(npc.index, pos);

							npc.m_iAnimationState = -1;
							npc.m_bisWalking = false;
							npc.SetActivity("ACT_PUSH_PLAYER");
							npc.SetPlaybackRate(3.0);

							npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
							npc.PlayRandomEnemyPullSound();

							ForcePlayerSuicide(client);
							ApplyLastmanOrDyingOverlay(client);
							found = true;
							break;
						}
					}

					// Don't lose when everyone dies
					GiveProgressDelay(15.0);
					Waves_ForceSetup(15.0);

					//dont respawn during setup.
					PreventRespawnsAll = GetGameTime() + 10.0;

					if(found)
					{
						npc.m_flNextThinkTime = gameTime + 0.25;
						i_RaidGrantExtra[npc.index]--;
					}
					else
					{
						npc.AddGesture("ACT_IDLE_ZOMBIE");
						npc.m_flNextThinkTime = gameTime + 1.25;
						
						for(int client = 1; client <= MaxClients; client++)
						{
							if(IsClientInGame(client) && !IsFakeClient(client))
							{
								ApplyLastmanOrDyingOverlay(client);
								SendConVarValue(client, sv_cheats, "1");
								Convars_FixClientsideIssues(client);
							}
						}
						ResetReplications();

						cvarTimeScale.SetFloat(0.1);
						CreateTimer(0.5, SetTimeBack);
						i_RaidGrantExtra[npc.index] = 49;
						PreventRespawnsAll = GetGameTime() + 2.0;
					}
				}
			}
		}

		i_RaidGrantExtra[npc.index]++;
		return;
	}

	if(npc.Anger)	// Waiting for enemies to die off
	{
		if(!Waves_IsEmpty())
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) * 17 / 20);
			return;
		}

		GiveOneRevive();
		RaidModeTime += 60.0;

		npc.m_flRangedArmor = 0.9;
		npc.m_flMeleeArmor = 1.125;
		npc.g_TimesSummoned = 0;

		npc.PlaySummonDeadSound();
		
		npc.Anger = false;
		npc.m_bSecondPhase = true;
		strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Bob the First");
		SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) * 17 / 20);

		if(XenoExtraLogic())
		{
			switch(GetURandomInt() % 3)
			{
				case 0:
					CPrintToChatAll("{white}밥 1세{default}: 네 운은 여기까지인 것 같군!");
				
				case 1:
					CPrintToChatAll("{white}밥 1세{default}: 이 이야기는 이렇게 흘러가면 안 됐어!");
				
				case 2:
					CPrintToChatAll("{white}밥 1세{default}: 운명을 바꿀 생각 하지 마라!");
			}
		}
		else
		{
			switch(GetURandomInt() % 4)
			{
				case 0:
					CPrintToChatAll("{white}밥 1세{default}: 이제 그만!");
				
				case 1:
					CPrintToChatAll("{white}밥 1세{default}: 네가 한 짓이 느껴지나? 네 학살 말이다.");
				
				case 2:
					CPrintToChatAll("{white}밥 1세{default}: 넌 신이 아니다.");
				
				case 3:
					CPrintToChatAll("{white}밥 1세{default}: 제노 감염, 시본 감염, 그리고 그 후엔... 너.");
			}
		}

		npc.m_flNextMeleeAttack = gameTime + 2.0;
	}

	if(npc.m_flGetClosestTargetTime < gameTime || !IsValidEnemy(npc.index, npc.m_iTarget))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;

		if(!npc.m_bFakeClone && b_NpcIsInvulnerable[npc.index])
		{
			b_NpcIsInvulnerable[npc.index] = false;
			npc.PlayIntroEndSound();
		}
	}

	if(!npc.m_bFakeClone)
	{
		static float EnemyPos[3];
		static float pos2[3]; 
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos2);
		Zero(b_EnemyCloseToMainBob);
		for(int EnemyLoop; EnemyLoop <= MAXENTITIES; EnemyLoop ++)
		{	
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
				//only apply the laser if they are near us.
				float distance = GetVectorDistance(EnemyPos, pos2, true);
				if(distance < (BOB_NO_PULL_RANGE * BOB_NO_PULL_RANGE))
				{
					b_EnemyCloseToMainBob[EnemyLoop] = true;
				}
			}
		}
		if(healthPoints < 20)
		{
			if(b_ThisEntityIgnoredByOtherNpcsAggro[npc.index])
			{
				b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
				if(CurrentModifOn() == 1 && i_RaidGrantExtra[npc.index] == 1)
					CPrintToChatAll("{white}%s{default}: 상관 없겠지, 너도 그 감염의 영향을 받았을테니.", NpcStats_ReturnNpcName(npc.index, true));
			}
		}
		int summon;

		switch(npc.g_TimesSummoned)
		{
			case -2, -1, 0:
			{
				if(healthPoints < 16)
					summon = 1;
			}
			case 1:
			{
				if(healthPoints < 11)
					summon = 1;
			}
			case 2:
			{
				if(healthPoints < 6)
					summon = 1;
			}
		}

		if(summon)
		{
			// Summon
			npc.g_TimesSummoned++;

			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			summon = NPC_CreateById(i_NpcInternalId[npc.index], -1, pos, ang, GetTeam(npc.index), "fake");
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index] * 0.5;
				fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index] * 0.75;

				SetEntityRenderMode(summon, RENDER_TRANSALPHA);
				SetEntityRenderColor(summon, 200, 200, 200, 200);
			}
		}
	}

	if(!npc.m_bFakeClone && !npc.m_bSecondPhase)
	{
		if(healthPoints < 9)
		{
			if(npc.b_SwordIgnition)
			{
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				ExtinguishTarget(npc.m_iWearable1);
				npc.b_SwordIgnition = false;
			}
			
			GiveOneRevive();
			RaidModeTime += 200.0;

			npc.Anger = true;
			npc.m_bisWalking = false;
			npc.SetActivity("ACT_IDLE_ZOMBIE");
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "??? the First");

			npc.PlaySummonSound();
			
			SetupMidWave(npc.index);
			return;
		}
		else if(healthPoints < 15)
		{
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "??????? First");
		}
	}

	if(npc.m_iTarget > 0 && healthPoints < 20)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

		switch(npc.m_iAttackType)
		{
			case 2:	// COMBO1 - Frame 44
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.999, 4000.0, true);
					
					npc.m_iAttackType = 3;
					npc.m_flAttackHappens = gameTime + 0.899;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.9);
				}
			}
			case 3:	// COMBO1 - Frame 54
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5, 2000.0, false);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.555;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 1.6);
				}
			}
			case 4:	// COMBO2 - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833, 2000.0, false);
					
					npc.m_iAttackType = 5;
					npc.m_flAttackHappens = gameTime + 0.833;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.9);
				}
			}
			case 5:	// COMBO2 - Frame 52
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833, 2000.0, false);
					
					npc.m_iAttackType = 6;
					npc.m_flAttackHappens = gameTime + 0.833;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.9);
				}
			}
			case 6:	// COMBO2 - Frame 73
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.875, 2000.0, true);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.083;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 1.1);
				}
			}
			case 8:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;
					ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.4);

					int projectile = npc.FireParticleRocket(vecTarget, 3000.0, GetRandomFloat(175.0, 225.0), 150.0, "utaunt_glitter_teamcolor_blue", true);
					npc.DispatchParticleEffect(npc.index, "rd_robot_explosion_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
					
					WandProjectile_ApplyFunctionToEntity(projectile, Bob_Rocket_Particle_StartTouch);	
					npc.PlayRocketHoming();
					float ang_Look[3];
					GetEntPropVector(projectile, Prop_Send, "m_angRotation", ang_Look);
					Initiate_HomingProjectile(projectile,
						npc.index,
						70.0,			// float lockonAngleMax,
						10.0,				//float homingaSec,
						false,				// bool LockOnlyOnce,
						true,				// bool changeAngles,
						ang_Look);// float AnglesInitiate[3]);
					static float EnemyPos[3];
					static float pos[3]; 
					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);

					if(!npc.m_bFakeClone)
					{
						for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
						{	
							if(IsValidEnemy(npc.index, EnemyLoop))
							{
								GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
								//only apply the laser if they are near us.
								float distance = GetVectorDistance(EnemyPos, pos, true);
								if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && distance > (BOB_NO_PULL_RANGE * BOB_NO_PULL_RANGE))
								{
									//Pull them.
									static float angles[3];
									GetVectorAnglesTwoPoints(pos, EnemyPos, angles);

									if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
										angles[0] = 0.0; // toss out pitch if on ground

									static float velocity[3];
									GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
									ScaleVector(velocity, 150.0);
													
													
									// min Z if on ground
									if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
										velocity[2] = fmax(325.0, velocity[2]);
												
									// apply velocity
									TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);   
								}
							}
						}
					}
				}
			}
			case 9:
			{
				PredictSubjectPosition(npc, npc.m_iTarget,_,_, vecTarget);
				npc.SetGoalVector(vecTarget);

				npc.FaceTowards(vecTarget, 20000.0);
				
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;

					KillFeed_SetKillIcon(npc.index, "sword");

					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
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

								SDKHooks_TakeDamage(target, npc.index, npc.index, 350.0, DMG_CLUB, -1, _, vecHit);	
								
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
										float VulnerabilityToGive = 0.20;
										if(npc.m_bFakeClone)
											VulnerabilityToGive = 0.10;
										IncreaseEntityDamageTakenBy(target, VulnerabilityToGive, 10.0, true);
									}	
	
								}
								else
								{
									float VulnerabilityToGive = 0.20;
									if(npc.m_bFakeClone)
										VulnerabilityToGive = 0.10;

									IncreaseEntityDamageTakenBy(target, VulnerabilityToGive, 10.0, true);
								}	
								if(!Knocked)
									Custom_Knockback(npc.index, target, 150.0, true);
							}
						} 
					}

					if(PlaySound)
						npc.PlayMeleeSound();

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
					WritePackCell(data, 95.0); // Distance
					WritePackFloat(data, 0.0); // nphi
					WritePackFloat(data, 250.0); // Range
					WritePackFloat(data, 1500.0); // Damge
					WritePackCell(data, ref);
					ResetPack(data);
					TrueFusionwarrior_IonAttack(data);
					
					int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
					UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
					GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), false, false);
					for(int i; i < sizeof(enemy_2); i++)
					{
						if(enemy_2[i])
						{
							GetEntPropVector(enemy_2[i], Prop_Data, "m_vecAbsOrigin", vecTarget);
							
							data = CreateDataPack();
							WritePackFloat(data, vecTarget[0]);
							WritePackFloat(data, vecTarget[1]);
							WritePackFloat(data, vecTarget[2]);
							WritePackCell(data, 160.0); // Distance
							WritePackFloat(data, 0.0); // nphi
							WritePackFloat(data, 250.0); // Range
							WritePackFloat(data, 2500.0); // Damge
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
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vecTarget);
					npc.SetGoalVector(vecTarget);
				}
				else
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}

				npc.StartPathing();
				npc.m_bisWalking = true;
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
						if(distance > (BOB_NO_PULL_RANGE * BOB_NO_PULL_RANGE))
						{
							if(!b_EnemyCloseToMainBob[npc.index])
								PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1600.0,_,vecTarget);
						}
						//only predict IF client is either too close, or too close to the original bob.
						npc.FireRocket(vecTarget, 600.0, 1600.0, "models/weapons/w_bullet.mdl", 2.0);
						npc.PlayGunSound();

						if(npc.m_bFakeClone)
							npc.m_flAttackHappens += GetRandomFloat(0.0, 0.2);
					}
				}

				npc.FaceTowards(vecTarget, 2500.0);
			}
			case 13, 14:
			{
				npc.StopPathing();
				
				if(npc.m_flAttackHappens < gameTime)
				{
					if(npc.m_iAttackType == 13)
					{
						npc.m_iAttackType = 14;
						npc.m_iAnimationState = -1;	// Replay the animation regardless
						npc.m_bisWalking = false;
						npc.SetActivity("ACT_PUSH_PLAYER");
						npc.SetPlaybackRate(2.0);
						npc.m_flAttackHappens = gameTime + 0.2;
					}
					else
					{
						static bool ClientTargeted[MAXENTITIES];
						static int TotalEnemeisInSight;


						//initiate only once per ability
						UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
						if(npc.m_iPullCount == 0)
						{
							Zero(ClientTargeted);
							TotalEnemeisInSight = 0;
							int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
							GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
							for(int i; i < sizeof(enemy_2); i++)
							{
								if(enemy_2[i])
								{
									TotalEnemeisInSight++;
								}
							}
							TotalEnemeisInSight /= 2;
							if(TotalEnemeisInSight <= 1)
							{
								TotalEnemeisInSight = 1;
							}
						}


						int enemy_2[RAIDBOSS_GLOBAL_ATTACKLIMIT];
						int EnemyToPull = 0;
						GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
						for(int i; i < sizeof(enemy_2); i++)
						{
							if(enemy_2[i] && !ClientTargeted[enemy_2[i]])
							{
								EnemyToPull = enemy_2[i];
								ClientTargeted[enemy_2[i]] = true;
								break;
							}
						}

						npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						npc.PlayRandomEnemyPullSound();

						if(npc.m_iPullCount > TotalEnemeisInSight)
						{
							// After X pulls, revert to normal
							npc.m_iAttackType = 0;
							npc.m_flAttackHappens = gameTime + 0.2;
						}
						else
						{
							// Play animation delay
							npc.m_iAttackType = 13;
							npc.m_flAttackHappens = gameTime + 0.2;
							npc.m_iPullCount++;
						}

						if(EnemyToPull)
						{
							PredictSubjectPosition(npc, EnemyToPull,_,_,vecTarget);
							npc.FaceTowards(vecTarget, 50000.0);
							
							if(!npc.m_bFakeClone)
							{
								BobPullTarget(npc.index, EnemyToPull);
							}
							
							//We succsssfully pulled someone.
							//Take their old position and nuke it.
							float vEnd[3];
					
							GetAbsOrigin(EnemyToPull, vEnd);
							Handle pack;
							CreateDataTimer(BOB_CHARGE_SPAN, Smite_Timer_Bob, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							WritePackCell(pack, EntIndexToEntRef(npc.index));
							WritePackFloat(pack, 0.0);
							WritePackFloat(pack, vEnd[0]);
							WritePackFloat(pack, vEnd[1]);
							WritePackFloat(pack, vEnd[2]);
							if(!npc.m_bFakeClone)
							{
								WritePackFloat(pack, 1000.0);
							}
							else
								WritePackFloat(pack, 650.0);
								
							spawnRing_Vectors(vEnd, BOB_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 125, 125, 200, 1, BOB_CHARGE_TIME, 6.0, 0.1, 1, 1.0);
						}
					}
				}
			}
			default:
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					if(healthPoints < 19 && npc.m_flNextMeleeAttack < gameTime)
					{
						if(npc.b_SwordIgnition)
						{
							AcceptEntityInput(npc.m_iWearable1, "Disable");
							ExtinguishTarget(npc.m_iWearable1);
							npc.b_SwordIgnition = false;
						}
						
						npc.m_flNextMeleeAttack = gameTime + 10.0;
						npc.StopPathing();
						WorldSpaceCenter(npc.index, vecMe);

						switch(GetURandomInt() % 3)
						{
							case 0:
							{
								npc.m_bisWalking = false;
								npc.SetActivity("ACT_COMBO1_BOBPRIME");
								npc.m_iAttackType = 2;
								npc.m_flAttackHappens = gameTime + 0.916;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.916, 2000.0, true);
								ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 1.0);
							}
							case 1:
							{
								npc.m_bisWalking = false;
								npc.SetActivity("ACT_COMBO2_BOBPRIME");
								npc.m_iAttackType = 4;
								npc.m_flAttackHappens = gameTime + 0.5;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5, 2000.0, false);
								ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.6);
							}
							case 2:
							{
								if(npc.m_bFakeClone)
								{
									//main bob shouldnt do this long windup kick, takes too long...
									npc.m_bisWalking = false;
									npc.SetActivity("ACT_COMBO3_BOBPRIME");
									npc.m_flAttackHappens = gameTime + 3.25;
									
									BobInitiatePunch(npc.index, vecTarget, vecMe, 2.125, 8000.0, true);
									ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 3.3);
								}
								else
								{
									switch(GetURandomInt() % 2)
									{
										case 0:
										{
											npc.m_bisWalking = false;
											npc.SetActivity("ACT_COMBO1_BOBPRIME");
											npc.m_iAttackType = 2;
											npc.m_flAttackHappens = gameTime + 0.916;
											
											BobInitiatePunch(npc.index, vecTarget, vecMe, 0.916, 2000.0, true);
											ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 1.0);
										}
										case 1:
										{
											npc.m_bisWalking = false;
											npc.SetActivity("ACT_COMBO2_BOBPRIME");
											npc.m_iAttackType = 4;
											npc.m_flAttackHappens = gameTime + 0.5;
											
											BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5, 2000.0, false);
											ApplyStatusEffect(npc.index, npc.index, "Defensive Backup", 0.6);
										}
									}
								}
							}
						}

						if(npc.m_bFakeClone)
							npc.m_flNextMeleeAttack += GetRandomFloat(5.0, 10.0);
					}
					else if(healthPoints < 17 && npc.m_flNextRangedAttack < gameTime)
					{
						npc.m_flNextRangedAttack = gameTime + (healthPoints < 9 ? 6.0 : 12.0);
						npc.PlayRangedSound();
						npc.StopPathing();
						npc.m_bisWalking = false;
						npc.m_iAnimationState = -1; //reset anim state so they can replay the anim if it was played before
						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 8;
						npc.m_flAttackHappens = gameTime + 1.0;

						if(npc.m_bFakeClone)
							npc.m_flNextRangedAttack += GetRandomFloat(20.0, 30.0);
					}
					else if(!npc.m_bFakeClone && healthPoints < 11 && npc.m_flNextRangedSpecialAttack < gameTime)
					{
						npc.m_flNextRangedSpecialAttack = gameTime + (healthPoints < 7 ? 15.0 : 27.0);
						npc.StopPathing();
						npc.PlaySkyShieldSound();
						npc.m_bisWalking = false;
						npc.m_iAnimationState = -1; //reset anim state so they can replay the anim if it was played before
						npc.SetActivity("ACT_METROPOLICE_DEPLOY_MANHACK");
						npc.m_iAttackType = 10;
						npc.m_flAttackHappens = gameTime + 1.0;

						if(npc.m_bFakeClone)
							npc.m_flNextRangedSpecialAttack += GetRandomFloat(15.0, 25.0);
					}
					else if(healthPoints < 15 && npc.m_flNextChargeSpecialAttack < gameTime)
					{
						// Start pull attack chain
						npc.m_flNextChargeSpecialAttack = gameTime + (healthPoints < 7 ? 15.0 : 27.0);
						npc.StopPathing();

						npc.m_iAttackType = 13;
						npc.m_iPullCount = 0;
						npc.m_bisWalking = false;
						//npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if((healthPoints < 3 || b_BobPistolPhase[npc.index]) && npc.m_bFakeClone)
					{
						npc.m_flSpeed = 1.0;
						npc.m_iAttackType = 11;
						npc.m_flAttackHappens = gameTime + 1.333;

						npc.AddGesture("ACT_METROCOP_DEPLOY_PISTOL");
						
						if(IsValidEntity(npc.m_iWearable1))
							RemoveEntity(npc.m_iWearable1);
						
						npc.m_iWearable1 = npc.EquipItem("anim_attachment_RH", "models/weapons/w_pistol.mdl");
						SetVariantString("2.0");
						AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
					}
					else
					{
						if(!npc.b_SwordIgnition)
						{
							AcceptEntityInput(npc.m_iWearable1, "Enable");
							IgniteTargetEffect(npc.m_iWearable1);
							npc.b_SwordIgnition = true;
						}

						float speed = healthPoints < 13 ? 330.0 : 290.0;
						if(npc.m_flSpeed != speed)
						{
							npc.m_flSpeed = speed;
							if(healthPoints == 12)
								npc.PlaySpeedUpSound();
						}
						
						float distance = GetVectorDistance(vecTarget, vecMe, true);
						if(distance < npc.GetLeadRadius()) 
						{
							PredictSubjectPosition(npc, npc.m_iTarget,_,_, vecTarget);
							npc.SetGoalVector(vecTarget);
						}
						else
						{
							npc.SetGoalEntity(npc.m_iTarget);
						}

						npc.StartPathing();
						npc.m_bisWalking = true;
						
						if(distance < 10000.0)	// 100 HU
						{
							npc.StopPathing();
							
							npc.SetActivity("ACT_RUN_BOB");
							npc.AddGesture("ACT_MELEE_BOB");
							npc.m_bisWalking = false;
							npc.m_iAttackType = 9;
							npc.m_flAttackHappens = gameTime + 0.35;
							npc.PlayMeleeHitSound();
							//SPAWN COOL EFFECT
							float flPos[3];
							float flAng[3];
							GetAttachment(npc.index, "special_weapon_effect", flPos, flAng);
							int particle = ParticleEffectAt(flPos, "raygun_projectile_red_crit", 0.45);	
							SetParent(npc.index, particle, "special_weapon_effect");
						}
						else
						{
							npc.SetActivity("ACT_RUN_BOB");
						}
					}
				}
			}
		}
	}
	else
	{
		if(npc.b_SwordIgnition)
		{
			AcceptEntityInput(npc.m_iWearable1, "Disable");
			ExtinguishTarget(npc.m_iWearable1);
			npc.b_SwordIgnition = false;
		}
		
		npc.StopPathing();
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_IDLE_BOBPRIME");
	}
}

void GiveOneRevive(bool ignorelimit = false)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			i_AmountDowned[client]--;
			if(!ignorelimit && i_AmountDowned[client] < 0)
				i_AmountDowned[client] = 0;
		}
	}
	/*

	int a, entity;
	while((entity = FindEntityByNPC(a)) != -1)
	{
		if(Citizen_IsIt(entity))
		{
			Citizen npc = view_as<Citizen>(entity);
			if(npc.m_nDowned && npc.m_iWearable3 > 0)
				npc.SetDowned(false);
		}
	}

	CheckAlivePlayers();
	WaveEndLogicExtra();
	*/
}

static void SetupMidWave(int entity)
{
	AddBobEnemy(entity, "npc_combine_soldier_elite", "First Elite", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman_ddt", "First DDT", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman", "First Swordsman", RoundToCeil(7.5 * MultiGlobalEnemy), 1500);
	AddBobEnemy(entity, "npc_combine_soldier_giant_swordsman", "First Giant Swordsman", RoundToCeil(3.5 * MultiGlobalEnemy), 5000);
	AddBobEnemy(entity, "npc_combine_soldier_collos_swordsman", "First Golden Collos", RoundToCeil(1.0 * MultiGlobalEnemy), RoundToCeil(10000.0 * MultiGlobalHighHealthBoss),1 );

	AddBobEnemy(entity, "npc_combine_soldier_swordsman_ddt", "First DDT", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_elite", "First Elite", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_giant_swordsman", "First Giant Swordsman", RoundToCeil(5.0 * MultiGlobalEnemy), 5000);

	AddBobEnemy(entity, "npc_combine_soldier_swordsman", "First Swordsman", RoundToCeil(7.5 * MultiGlobalEnemy), 1500);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman_ddt", "First DDT", RoundToCeil(3.5 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_giant_swordsman", "First Giant Swordsman", RoundToCeil(5.0 * MultiGlobalEnemy), 5000);

	AddBobEnemy(entity, "npc_combine_soldier_elite", "First Elite", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman_ddt", "First DDT", RoundToCeil(5.0 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_shotgun", "First Shotgunner", RoundToCeil(5.0 * MultiGlobalEnemy), 1000);

	AddBobEnemy(entity, "npc_combine_soldier_elite", "First Elite", RoundToCeil(2.5 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman_ddt", "First DDT", RoundToCeil(2.5 * MultiGlobalEnemy), 1250);
	AddBobEnemy(entity, "npc_combine_soldier_ar2", "First Rifler", RoundToCeil(2.5 * MultiGlobalEnemy), 1100);
	AddBobEnemy(entity, "npc_combine_soldier_swordsman", "First Swordsman", RoundToCeil(2.5 * MultiGlobalEnemy), 1500);
	AddBobEnemy(entity, "npc_combine_soldier_giant_swordsman", "First Giant Swordsman", RoundToCeil(2.5 * MultiGlobalEnemy), 5000);
	AddBobEnemy(entity, "npc_combine_soldier_shotgun", "First Shotgunner", RoundToCeil(2.5 * MultiGlobalEnemy), 1000);
	AddBobEnemy(entity, "npc_combine_soldier_ar2", "First Rifler", RoundToCeil(2.5 * MultiGlobalEnemy), 1100);
	AddBobEnemy(entity, "npc_combine_police_smg", _, RoundToCeil(2.5 * MultiGlobalEnemy), 700);
	AddBobEnemy(entity, "npc_combine_police_pistol", _, RoundToCeil(2.5 * MultiGlobalEnemy), 550);
}

static void AddBobEnemy(int bobindx, const char[] plugin, const char[] name = "", int count, int health = 0, int boss = 0)
{
	Enemy enemy;

	health *= 8;
	enemy.Index = NPC_GetByPlugin(plugin);
	enemy.Is_Boss = view_as<int>(boss);
	enemy.ExtraMeleeRes = 0.175;
	enemy.ExtraRangedRes = 0.175;
	enemy.ExtraSpeed = 1.3;
	enemy.ExtraDamage = 3.8;
	enemy.ExtraSize = 1.0;
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Team = GetTeam(bobindx);
	strcopy(enemy.CustomName, sizeof(enemy.CustomName), name);
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		Freeplay_AddEnemy(postWaves, enemy, count);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}
	Zombies_Currently_Still_Ongoing += count;
}

Action RaidbossBobTheFirst_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(victim);
	
	if(npc.Anger || npc.m_bFakeClone || i_RaidGrantExtra[npc.index] > 1)
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if(b_ThisEntityIgnoredByOtherNpcsAggro[npc.index])
	{
		if(attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
		{	
			damage = 0.0;
			return Plugin_Handled;
		}
	}

	if(i_RaidGrantExtra[npc.index] == 1)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			Music_SetRaidMusicSimple("vo/null.mp3", 30, false, 0.5);
			npc.StopPathing();

			RaidBossActive = -1;

			i_RaidGrantExtra[npc.index] = 2;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			int GetTeamOld = GetTeam(npc.index);
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(30.0);
			damage = 0.0;
			
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != INVALID_ENT_REFERENCE && other != npc.index)
				{
					if(i_NpcInternalId[npc.index] == i_NpcInternalId[other])
					{
						if(GetTeamOld == GetTeam(other))
						{
							SmiteNpcToDeath(other);
						}
					}
				}
			}
			return Plugin_Handled;
		}
	}

	return Plugin_Changed;
}

void RaidbossBobTheFirst_NPCDeath(int entity)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);

	Format(WhatDifficultySetting, sizeof(WhatDifficultySetting), "%s",WhatDifficultySetting_Internal);
	WavesUpdateDifficultyName();
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != INVALID_ENT_REFERENCE && other != npc.index)
		{
			if(i_NpcInternalId[npc.index] == i_NpcInternalId[other])
			{
				if(GetTeam(npc.index) == GetTeam(other))
				{
					SmiteNpcToDeath(other);
				}
			}
		}
	}
}

static void GivePlayerItems(int coolwin = 0)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			Items_GiveNamedItem(client, "Bob's Curing Hand");
			if(coolwin == 0)
				CPrintToChat(client, "{default}밥이 당신에게 깃든 심해의 감염원을 전부 제거해주었습니다. 당신이 얻은 것은... : {yellow}''밥의 치유의 손길''{default}!");
			else
				CPrintToChat(client, "{default}당신은 밥을 공격하지 않았고, 그런 밥이 당신에게 준 것은... : {yellow}''밥의 치유의 손길''{default}!");
		}
	}

}

public Action Smite_Timer_Bob(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
		
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for (int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if (NumLoops >= BOB_CHARGE_TIME)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.4, 1, (BOB_FIRST_LIGHTNING_RANGE * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		secondLoc[2] = 1500.0;
		
		spawnBeam(0.8, 255, 50, 50, 255, "materials/sprites/laserbeam.vmt", 4.0, 6.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 4.0, 5.2, _, 2.0, secondLoc, spawnLoc);	
		spawnBeam(0.8, 255, 50, 50, 200, "materials/sprites/lgtning.vmt", 3.0, 4.2, _, 2.0, secondLoc, spawnLoc);	
		
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 80);
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		 
		CreateEarthquake(spawnLoc, 1.0, BOB_FIRST_LIGHTNING_RANGE * 2.5, 16.0, 255.0);
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, BOB_FIRST_LIGHTNING_RANGE * 1.4,_,0.8, true);  //Explosion range increase
	
		return Plugin_Stop;
	}
	else
	{
		spawnRing_Vectors(spawnLoc, BOB_FIRST_LIGHTNING_RANGE * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 255, 50, 50, 120, 1, 0.33, 6.0, 0.1, 1, 1.0);
	//	EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_CHARGE, spawnLoc, _, 60, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + BOB_CHARGE_TIME);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}


static void spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
{
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = a;
		
	int SPRITE_INT = PrecacheModel(sprite, false);

	TE_SetupBeamPoints(startLoc, endLoc, SPRITE_INT, 0, 0, 0, beamTiming, width, endwidth, fadelength, amp, color, 0);
	
	TE_SendToAll();
}
stock void BobPullTarget(int bobnpc, int enemy)
{
	CClotBody npc = view_as<CClotBody>(bobnpc);
	//pull player
	float vecMe[3];
	float vecTarget[3];
	WorldSpaceCenter(npc.index, vecMe);
	if(enemy <= MaxClients)
	{
		static float angles[3];
		
		WorldSpaceCenter(enemy, vecTarget );
		GetVectorAnglesTwoPoints(vecTarget, vecMe, angles);
		
		if(GetEntityFlags(enemy) & FL_ONGROUND)
			angles[0] = 0.0; // toss out pitch if on ground

		float distance = GetVectorDistance(vecTarget, vecMe);
		if(distance > 500.0)
			distance = 500.0;

		static float velocity[3];
		GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(velocity, distance * 2.0);
		
		// min Z if on ground
		if(GetEntityFlags(enemy) & FL_ONGROUND)
			velocity[2] = fmax(400.0, velocity[2]);
		
		// apply velocity
		TeleportEntity(enemy, NULL_VECTOR, NULL_VECTOR, velocity);
		TF2_AddCondition(enemy, TFCond_LostFooting, 0.5);
		TF2_AddCondition(enemy, TFCond_AirCurrent, 0.5);	
		//give 50% res for 0.5 seconds
	}
	else
	{
		CClotBody npcenemy = view_as<CClotBody>(enemy);

		PluginBot_Jump(npcenemy.index, vecMe);
	}
}


void BobInitiatePunch(int entity, float VectorTarget[3], float VectorStart[3], float TimeUntillHit, float damage, bool kick)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	npc.PlayBobMeleePreHit();
	npc.FaceTowards(VectorTarget, 20000.0);

	TimeUntillHit = (TimeUntillHit * ReturnEntityAttackspeed(entity));

	float vecForward[3], Angles[3];

	GetVectorAnglesTwoPoints(VectorStart, VectorTarget, Angles);

	GetAngleVectors(Angles, vecForward, NULL_VECTOR, NULL_VECTOR);

	float VectorTarget_2[3];
	float VectorForward = 5000.0; //a really high number.
	
	VectorTarget_2[0] = VectorStart[0] + vecForward[0] * VectorForward;
	VectorTarget_2[1] = VectorStart[1] + vecForward[1] * VectorForward;
	VectorTarget_2[2] = VectorStart[2] + vecForward[2] * VectorForward;


	int red = 255;
	int green = 255;
	int blue = 255;
	int Alpha = 255;
	if(GetTeam(entity) == TFTeam_Red)
		Alpha = 125;

	int colorLayer4[4];
	float diameter = float(BOB_MELEE_SIZE * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	int glowColor[4];

	for(int BeamCube = 0; BeamCube < 4 ; BeamCube++)
	{
		float OffsetFromMiddle[3];
		switch(BeamCube)
		{
			case 0:
			{
				OffsetFromMiddle = {0.0, BOB_MELEE_SIZE_F,BOB_MELEE_SIZE_F};
			}
			case 1:
			{
				OffsetFromMiddle = {0.0, -BOB_MELEE_SIZE_F,-BOB_MELEE_SIZE_F};
			}
			case 2:
			{
				OffsetFromMiddle = {0.0, BOB_MELEE_SIZE_F,-BOB_MELEE_SIZE_F};
			}
			case 3:
			{
				OffsetFromMiddle = {0.0, -BOB_MELEE_SIZE_F,BOB_MELEE_SIZE_F};
			}
		}
		float AnglesEdit[3];
		AnglesEdit[0] = Angles[0];
		AnglesEdit[1] = Angles[1];
		AnglesEdit[2] = Angles[2];

		float VectorStartEdit[3];
		VectorStartEdit[0] = VectorStart[0];
		VectorStartEdit[1] = VectorStart[1];
		VectorStartEdit[2] = VectorStart[2];

		GetBeamDrawStartPoint_Stock(entity, VectorStartEdit,OffsetFromMiddle, AnglesEdit);

		SetColorRGBA(glowColor, red, green, blue, Alpha);
		TE_SetupBeamPoints(VectorStartEdit, VectorTarget_2, Shared_BEAM_Laser, 0, 0, 0, TimeUntillHit, ClampBeamWidth(diameter * 0.1), ClampBeamWidth(diameter * 0.1), 0, 0.0, glowColor, 0);
		TE_SendToAll(0.0);
	}
	
	
	DataPack pack = new DataPack();
	pack.WriteCell(EntIndexToEntRef(entity));
	pack.WriteFloat(VectorTarget_2[0]);
	pack.WriteFloat(VectorTarget_2[1]);
	pack.WriteFloat(VectorTarget_2[2]);
	pack.WriteFloat(VectorStart[0]);
	pack.WriteFloat(VectorStart[1]);
	pack.WriteFloat(VectorStart[2]);
	pack.WriteFloat(damage);
	pack.WriteCell(kick);
	// 66.6 assumes normal tickrate.
	int i_FrameCount = RoundToNearest(TimeUntillHit * 66.6);
	RequestFrames(BobInitiatePunch_DamagePart, i_FrameCount, pack);
}

void BobInitiatePunch_DamagePart(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	for (int i = 1; i < MAXENTITIES; i++)
	{
		LaserVarious_HitDetection[i] = false;
	}
	float VectorTarget[3];
	float VectorStart[3];
	VectorTarget[0] = pack.ReadFloat();
	VectorTarget[1] = pack.ReadFloat();
	VectorTarget[2] = pack.ReadFloat();
	VectorStart[0] = pack.ReadFloat();
	VectorStart[1] = pack.ReadFloat();
	VectorStart[2] = pack.ReadFloat();
	float damagedata = pack.ReadFloat();
	bool kick = pack.ReadCell();

	int red = 50;
	int green = 50;
	int blue = 255;
	int Alpha = 222;
	if(GetTeam(entity) == TFTeam_Red)
		Alpha = 100;
	int colorLayer4[4];

	float diameter = float(BOB_MELEE_SIZE * 4);
	SetColorRGBA(colorLayer4, red, green, blue, Alpha);
	//we set colours of the differnet laser effects to give it more of an effect
	int colorLayer1[4];
	SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, Alpha);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.4), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);
	TE_SetupBeamPoints(VectorStart, VectorTarget, Shared_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
	TE_SendToAll(0.0);

	float hullMin[3];
	float hullMax[3];
	hullMin[0] = -float(BOB_MELEE_SIZE);
	hullMin[1] = hullMin[0];
	hullMin[2] = hullMin[0];
	hullMax[0] = -hullMin[0];
	hullMax[1] = -hullMin[1];
	hullMax[2] = -hullMin[2];
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	npc.PlayBobMeleePostHit();

	Handle trace;
	trace = TR_TraceHullFilterEx(VectorStart, VectorTarget, hullMin, hullMax, 1073741824, Sensal_BEAM_TraceUsers_2, entity);	// 1073741824 is CONTENTS_LADDER?
	delete trace;
			
	KillFeed_SetKillIcon(entity, kick ? "mantreads" : "fists");

	if(NpcStats_IsEnemySilenced(entity))
		kick = false;
	
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (LaserVarious_HitDetection[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float damage = damagedata;

			if(victim > MaxClients) //make sure barracks units arent bad
				damage *= 0.35;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_CLUB, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
			
			if(kick && victim <= MaxClients)
			{
				if(victim <= MaxClients)
				{
					float newVel[3];
					newVel[0] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[0]");
					newVel[1] = GetEntPropFloat(victim, Prop_Send, "m_vecVelocity[1]");
					newVel[2] = 400.0;
					TeleportEntity(victim, _, _, newVel, true);
				}
				else if(!b_NpcHasDied[victim])
				{
					FreezeNpcInTime(victim, 1.5);
					
					WorldSpaceCenter(victim, hullMin);
					hullMin[2] += 100.0; //Jump up.
					PluginBot_Jump(victim, hullMin);
				}
			}
		}
	}
	delete pack;

	KillFeed_SetKillIcon(entity, "tf_projectile_rocket");
}


public bool Sensal_BEAM_TraceUsers_2(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		LaserVarious_HitDetection[entity] = true;
	}
	return false;
}



public void Bob_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
		{
			owner = 0;
		}
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];


		if(target > MaxClients) //make sure barracks units arent shit
		{
			DamageDeal *= 0.4;
		}

		if(b_should_explode[entity])	//should we "explode" or do "kinetic" damage
		{
			i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
			Explode_Logic_Custom(DamageDeal, inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
		}
		else
		{
			SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket
		}
		EmitSoundToAll("mvm/mvm_tank_explode.wav", entity, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		ParticleEffectAt(ProjectileLoc, "hightower_explosion", 1.0);
				
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	RemoveEntity(entity);
}

public void Raidmode_BobFirst_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	CPrintToChatAll("{white}밥 1세{default}: 심해의 위협은 이제 완전히 사라졌다. 드디어 평화가 찾아오겠군...");
}



public Action SafetyFixBobDo(Handle timer, int refbob)
{
	if(!IsValidEntity(refbob))
	{
		return Plugin_Handled;
	}
	int Entity = EntRefToEntIndex(refbob);
	if(i_RaidGrantExtra[Entity] <= 50)
		i_RaidGrantExtra[Entity] = 50;
	PreventRespawnsAll = GetGameTime() + 0.0;
	return Plugin_Handled;
}