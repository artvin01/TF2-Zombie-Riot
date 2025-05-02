#pragma semicolon 1
#pragma newdecls required

#define BOB_FIRST_LIGHTNING_RANGE 100.0

#define BOB_CHARGE_TIME 1.5
#define BOB_CHARGE_SPAN 0.5

#define BOB_MELEE_SIZE 35
#define BOB_MELEE_SIZE_F 35.0

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
#define SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE	"misc/halloween/spell_mirv_explode_primary.wav"

static char gGlow1;
static char gExplosive1;
static char gLaser1;
static int SecondPhase[MAXENTITIES];

void RaidbossBobTheFirst_OnMapStart()
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
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	PrecacheSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE);
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob The First");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_first_last_savior");
	data.Func = ClotSummon;
	NPC_Add(data);
}

#define BOB_THE_FIRST_S 2
#define BOB_THE_FIRST 1

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
		EmitSoundToAll(PullRandomEnemyAttack[GetRandomInt(0, sizeof(PullRandomEnemyAttack) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
		public get()		
		{	
			return view_as<bool>(SecondPhase[this.index]);	
		}
		public set(bool value)	{	SecondPhase[this.index] = value;	}
	}	
	property bool b_SwordIgnition
	{
		public get()							{ return b_follow[this.index]; }
		public set(bool TempValueForProperty) 	{ b_follow[this.index] = TempValueForProperty; }
	}
	property bool m_bFakeClone
	{
		public get()		
		{
			if(i_RaidGrantExtra[this.index] != -1)
			{
				return false;
			}
			return true;
		}
	}

	public RaidbossBobTheFirst(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		float pos[3];
		pos = vecPos;

		RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(CClotBody(pos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "20000000", ally, _, _, true, false));
		
		i_NpcWeight[npc.index] = 4;
		SecondPhase[npc.index] = false;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_TrueStrength_RAGE");
		b_NpcIsInvulnerable[npc.index] = true;

		npc.PlayIntroStartSound();

		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		
		if(StrContains(data, "final_item") != -1)
		{
			i_RaidGrantExtra[npc.index] = 1;
			npc.m_flNextDelayTime = GetGameTime(npc.index) + 10.0;

			npc.m_bSecondPhase = true;
			npc.g_TimesSummoned = -2;
		}
		else if(StrContains(data, "nobackup") != -1)
		{
			npc.m_bSecondPhase = true;
			npc.g_TimesSummoned = -2;
		}
		else if(StrContains(data, "fake") != -1)
		{
			MakeObjectIntangeable(npc.index);
			i_RaidGrantExtra[npc.index] = -1;
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_thisNpcIsARaid[npc.index] = true;
		}
		else
		{
			npc.m_flNextDelayTime = GetGameTime(npc.index) + 5.0;
			npc.SetPlaybackRate(2.0);
			npc.g_TimesSummoned = 0;
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
		npc.m_flSpeed = 450.0;
		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;

		npc.m_iAttackType = 0;
		npc.m_flAttackHappens = 0.0;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = 0.0;
		npc.m_iPullCount = 0;
		
		if(!npc.m_bFakeClone)
		{
			npc.StopPathing();
		}
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/weapons/c_models/c_claymore/c_claymore.mdl");
		SetVariantString("1.0");
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 2);
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		AcceptEntityInput(npc.m_iWearable1, "Disable");
		npc.b_SwordIgnition = false;
		
		return npc;
	}
}

static void Internal_ClotThink(int iNPC)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(iNPC);
	
	if(!npc.m_bFakeClone)
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
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
		npc.SetActivity("ACT_IDLE_SHIELDZOBIE");

		switch(i_RaidGrantExtra[npc.index])
		{
			case 2:
			{
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
				CPrintToChatAll("{white}Bob the First{default}: How did this thing make you this powerful..?");
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
			case 50:
			{
				SmiteNpcToDeath(npc.index);
			}
			default:
			{
				bool found;

				for(int client = 1; client <= MaxClients; client++)
				{
					if(IsClientInGame(client) && IsPlayerAlive(client))
					{
						float pos[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", pos);
						float ang[3];
						ang[1] = GetRandomFloat(-179.0, 179.0);

						TeleportEntity(npc.index, pos);

						npc.m_iState = -1;
						npc.SetActivity("ACT_PUSH_PLAYER");
						npc.SetPlaybackRate(3.0);

						npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
						npc.PlayRandomEnemyPullSound();

						ForcePlayerSuicide(client);
						found = true;
						break;
					}
				}

				if(found)
				{
					npc.m_flNextThinkTime = gameTime + 0.25;
					i_RaidGrantExtra[npc.index]--;
				}
				else
				{
					npc.AddGesture("ACT_IDLE_ZOMBIE");
					npc.m_flNextThinkTime = gameTime + 1.25;
					
					ResetReplications();
					i_RaidGrantExtra[npc.index] = 49;
				}
			}
		}

		i_RaidGrantExtra[npc.index]++;
		return;
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

	int healthPoints = 20;

	if(npc.m_bFakeClone)
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(other != INVALID_ENT_REFERENCE && other != npc.index)
			{
				if(i_NpcInternalId[other] == i_NpcInternalId[npc.index])
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
	}

	if(!npc.m_bFakeClone)
	{
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
			summon = NPC_CreateByName("npc_bob_the_first_last_savior", -1, pos, ang, GetTeam(npc.index), "fake");
			if(summon > MaxClients)
			{
				i_RaidGrantExtra[summon] = -1;
				fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index] * 0.5;
				fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index] * 0.75;

				SetEntityRenderMode(summon, RENDER_TRANSALPHA);
				SetEntityRenderColor(summon, 200, 200, 200, 200);
			}
			summon = NPC_CreateByName("npc_bob_the_first_last_savior", -1, pos, ang, GetTeam(npc.index), "fake");
			if(summon > MaxClients)
			{
				i_RaidGrantExtra[summon] = -1;
				fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index] * 0.5;
				fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index] * 0.75;

				SetEntityRenderMode(summon, RENDER_TRANSALPHA);
				SetEntityRenderColor(summon, 200, 200, 200, 200);
			}
			summon = NPC_CreateByName("npc_bob_the_first_last_savior", -1, pos, ang, GetTeam(npc.index), "fake");
			if(summon > MaxClients)
			{
				i_RaidGrantExtra[summon] = -1;
				fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index] * 0.5;
				fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index] * 0.75;

				SetEntityRenderMode(summon, RENDER_TRANSALPHA);
				SetEntityRenderColor(summon, 200, 200, 200, 200);
			}
		}
	}

	if(!npc.m_bFakeClone && !npc.m_bSecondPhase)
	{
		if(healthPoints < 15)
		{
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "??????? First");
		}
		else if(healthPoints < 9)
		{
			if(npc.b_SwordIgnition)
			{
				AcceptEntityInput(npc.m_iWearable1, "Disable");
				ExtinguishTarget(npc.m_iWearable1);
				npc.b_SwordIgnition = false;
			}

			npc.Anger = true;
			npc.SetActivity("ACT_IDLE_ZOMBIE");
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "??? the First");

			npc.PlaySummonSound();
			return;
		}
	}
	
	if(npc.m_iTarget > 0)
	{
		float vecMe[3]; WorldSpaceCenter(npc.index, vecMe);
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		if(npc.m_flCharge_delay < GetGameTime(npc.index))
		{
			if(npc.IsOnGround())
			{
				float vPredictedPos[3];
				PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
				vPredictedPos = GetBehindTarget(npc.m_iTarget, 30.0 ,vPredictedPos);
				static float hullcheckmaxs[3];
				static float hullcheckmins[3];
				hullcheckmaxs = view_as<float>( { 30.0, 30.0, 120.0 } );
				hullcheckmins = view_as<float>( { -30.0, -30.0, 0.0 } );	

				float SelfPos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
				float AllyAng[3];
				GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
				
				bool Succeed = Npc_Teleport_Safe(npc.index, vPredictedPos, hullcheckmins, hullcheckmaxs, false);
				if(Succeed)
				{
					ParticleEffectAt(SelfPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					ParticleEffectAt(vPredictedPos, "teleported_blue", 0.5); //This is a permanent particle, gotta delete it manually...
					float SpaceCenter[3]; WorldSpaceCenter(npc.m_iTarget, SpaceCenter);
					npc.FaceTowards(SpaceCenter, 15000.0);
					npc.m_flCharge_delay = GetGameTime(npc.index) + (GetRandomFloat(7.5, 15.0));
				}
			}
		}

		switch(npc.m_iAttackType)
		{
			case 2:	// COMBO1 - Frame 44
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.999, 4000.0, true);
					
					npc.m_iAttackType = 3;
					npc.m_flAttackHappens = gameTime + 0.899;
				}
			}
			case 3:	// COMBO1 - Frame 54
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5, 2000.0, false);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.555;
				}
			}
			case 4:	// COMBO2 - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833, 2000.0, false);
					
					npc.m_iAttackType = 5;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 5:	// COMBO2 - Frame 52
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.833, 2000.0, false);
					
					npc.m_iAttackType = 6;
					npc.m_flAttackHappens = gameTime + 0.833;
				}
			}
			case 6:	// COMBO2 - Frame 73
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					BobInitiatePunch(npc.index, vecTarget, vecMe, 0.875, 2000.0, true);
					
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 1.083;
				}
			}
			case 8:	// DEPLOY_MANHACK - Frame 32
			{
				if(npc.m_flAttackHappens < gameTime)
				{
					npc.m_iAttackType = 0;
					npc.m_flAttackHappens = gameTime + 0.333;

					int projectile = npc.FireParticleRocket(vecTarget, 7000.0, GetRandomFloat(175.0, 225.0), 150.0, "utaunt_glitter_teamcolor_blue", true);
					npc.DispatchParticleEffect(npc.index, "rd_robot_explosion_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
					
					SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
					
					SDKHook(projectile, SDKHook_StartTouch, Bob_Rocket_Particle_StartTouch);
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
								if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
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

					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					bool PlaySound = false;
					Zero(i_EntitiesHitAoeSwing_NpcSwing);
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

								SDKHooks_TakeDamage(target, npc.index, npc.index, 750.0, DMG_CLUB, -1, _, vecHit);	
								
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
	
								}
								if(!Knocked)
									Custom_Knockback(npc.index, target, 150.0, true);
							}
						} 
					}

					if(PlaySound)
						npc.PlayMeleeSound();
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
							WritePackCell(data, 160.0); // Distance
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
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vecTarget);
					npc.SetGoalVector(vecTarget);
				}
				else
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}

				npc.StartPathing();
				npc.SetActivity("ACT_DARIO_WALK");

				if(npc.m_iAttackType == 12)
					npc.m_flSpeed = 350.0;
				
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
						
						PredictSubjectPositionForProjectiles(npc, npc.m_iTarget, 1600.0, _,vecTarget);
						npc.FireRocket(vecTarget, 1200.0, 1600.0, "models/weapons/w_bullet.mdl", 2.0);
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
						npc.m_iState = -1;	// Replay the animation regardless
						npc.SetActivity("ACT_PUSH_PLAYER");
						npc.SetPlaybackRate(2.0);
						npc.m_flAttackHappens = gameTime + 0.2;
					}
					else
					{
						static bool ClientTargeted[MAXENTITIES];
						static int TotalEnemeisInSight;


						//initiate only once per ability
						CClotBody npcGetInfo = view_as<CClotBody>(npc.index);
						if(npc.m_iPullCount == 0)
						{
							Zero(ClientTargeted);
							TotalEnemeisInSight = 0;
							int enemy_2[MAXENTITIES];
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


						int enemy_2[MAXENTITIES];
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
							PredictSubjectPosition(npc, EnemyToPull,_,_, vecTarget);
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
								WritePackFloat(pack, 2000.0);
							}
							else
								WritePackFloat(pack, 1000.0);
								
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
								npc.SetActivity("ACT_COMBO1_BOBPRIME");
								npc.m_iAttackType = 2;
								npc.m_flAttackHappens = gameTime + 0.916;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.916, 2000.0, true);
							}
							case 1:
							{
								npc.SetActivity("ACT_COMBO2_BOBPRIME");
								npc.m_iAttackType = 4;
								npc.m_flAttackHappens = gameTime + 0.5;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 0.5, 2000.0, false);
							}
							case 2:
							{
								npc.SetActivity("ACT_COMBO3_BOBPRIME");
								npc.m_flAttackHappens = gameTime + 3.25;
								
								BobInitiatePunch(npc.index, vecTarget, vecMe, 2.125, 8000.0, true);
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
						//npc.m_flAttackHappens = gameTime + 1.0;
					}
					else if(healthPoints < 3 && npc.m_bFakeClone)
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
						
						if(distance < 10000.0)	// 100 HU
						{
							npc.StopPathing();
							
							npc.SetActivity("ACT_RUN_BOB");
							npc.AddGesture("ACT_MELEE_BOB");
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
		npc.SetActivity("ACT_IDLE_BOBPRIME");
	}
}


static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

	if(i_RaidGrantExtra[npc.index] == 1)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			if(IsValidEntity(npc.m_iWearable1))
				RemoveEntity(npc.m_iWearable1);
			
			npc.StopPathing();


			i_RaidGrantExtra[npc.index] = 2;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			damage = 0.0;
			
			for(int i; i < i_MaxcountNpcTotal; i++)
			{
				int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
				if(other != INVALID_ENT_REFERENCE && other != npc.index)
				{
					if(i_NpcInternalId[other] == BOB_THE_FIRST || i_NpcInternalId[other] == BOB_THE_FIRST_S)
					{
						if(GetTeam(npc.index) == GetTeam(other))
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

static void Internal_NPCDeath(int entity)
{
	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);


	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int other = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(other != INVALID_ENT_REFERENCE && other != npc.index)
		{
			if(GetTeam(npc.index) == GetTeam(other))
			{
				SmiteNpcToDeath(other);
			}
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
		
		EmitAmbientSound(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, spawnLoc, _, 120);
		
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
		
		WorldSpaceCenter(enemy, vecTarget);
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
		IncreaseEntityDamageTakenBy(enemy, 0.5, 0.5);
		//give 50% res for 0.5 seconds
	}
	else
	{
		CClotBody npcenemy = view_as<CClotBody>(enemy);

		PluginBot_Jump(npcenemy.index, vecMe);
	}
}

static int SensalHitDetected_2[MAXENTITIES];

void BobInitiatePunch(int entity, float VectorTarget[3], float VectorStart[3], float TimeUntillHit, float damage, bool kick)
{

	RaidbossBobTheFirst npc = view_as<RaidbossBobTheFirst>(entity);
	npc.PlayBobMeleePreHit();
	npc.FaceTowards(VectorTarget, 20000.0);
	int FramesUntillHit = RoundToNearest(TimeUntillHit * float(TickrateModifyInt));

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
	RequestFrames(BobInitiatePunch_DamagePart, FramesUntillHit, pack);
}

void BobInitiatePunch_DamagePart(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
		entity = 0;

	for (int i = 1; i < MAXENTITIES; i++)
	{
		SensalHitDetected_2[i] = false;
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

	if(NpcStats_IsEnemySilenced(entity))
		kick = false;
	
	float playerPos[3];
	for (int victim = 1; victim < MAXENTITIES; victim++)
	{
		if (SensalHitDetected_2[victim] && GetTeam(entity) != GetTeam(victim))
		{
			GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
			float damage = damagedata;

			if(victim > MaxClients) //make sure barracks units arent bad
				damage *= 0.5;

			SDKHooks_TakeDamage(victim, entity, entity, damage, DMG_CLUB, -1, NULL_VECTOR, playerPos);	// 2048 is DMG_NOGIB?
			
			if(kick)
			{
				if(victim <= MaxClients)
				{
					hullMin[0] = 0.0;
					hullMin[1] = 0.0;
					hullMin[2] = 400.0;
					TeleportEntity(victim, _, _, hullMin, true);
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
}


public bool Sensal_BEAM_TraceUsers_2(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		SensalHitDetected_2[entity] = true;
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


		if(b_should_explode[entity])	//should we "explode" or do "kinetic" damage
		{
			i_ExplosiveProjectileHexArray[owner] = i_ExplosiveProjectileHexArray[entity];
			Explode_Logic_Custom(fl_rocket_particle_dmg[entity] , inflictor , owner , -1 , ProjectileLoc , fl_rocket_particle_radius[entity] , _ , _ , b_rocket_particle_from_blue_npc[entity]);	//acts like a rocket
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




	public void TrueFusionwarrior_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		float Ionrange = ReadPackFloat(data);
		float Iondamage = ReadPackFloat(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client) || b_NpcHasDied[client])
		{
			delete data;
			return;
		}
		
		if (Iondistance > 0)
		{
			EmitSoundToAll("ambient/energy/weld1.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
			
			// Stage 1
			float s=Sine(nphi/360*6.28)*Iondistance;
			float c=Cosine(nphi/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] = startPosition[2];
			
			position[0] += s;
			position[1] += c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 2
			s=Sine((nphi+45.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+45.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+135.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+135.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] -= s;
			position[1] -= c;
		//	TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;

		delete data;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackFloat(nData, Ionrange);
		WritePackFloat(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, TrueFusionwarrior_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE);
		else
		{
			startPosition[2] += 25.0;
			if(!b_Anger[client])
				makeexplosion(client, startPosition, RoundToCeil(Iondamage), 100);
				
			else if(b_Anger[client])
				makeexplosion(client, startPosition, RoundToCeil(Iondamage * 1.25), 120);
				
			startPosition[2] -= 25.0;
			TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
			TE_SendToAll();
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[2] += startPosition[2] + 900.0;
			startPosition[2] += -200;
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 30.0, 30.0, 0, 1.0, {212, 175, 55, 255}, 3);
			TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 50.0, 50.0, 0, 1.0, {212, 175, 55, 200}, 3);
			TE_SendToAll();
		//	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {212, 175, 55, 120}, 3);
		//	TE_SendToAll();
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 100.0, 100.0, 0, 1.0, {212, 175, 55, 75}, 3);
			TE_SendToAll();
	
			position[2] = startPosition[2] + 50.0;
			//new Float:fDirection[3] = {-90.0,0.0,0.0};
			//env_shooter(fDirection, 25.0, 0.1, fDirection, 800.0, 120.0, 120.0, position, "models/props_wasteland/rockgranite03b.mdl");
	
			//env_shake(startPosition, 120.0, 10000.0, 15.0, 250.0);
			
			// Sound
			EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	
			// Blend
			//sendfademsg(0, 10, 200, FFADE_OUT, 255, 255, 255, 150);
			
			// Knockback
	/*		float vReturn[3];
			float vClientPosition[3];
			float dist;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i))
				{	
					GetClientEyePosition(i, vClientPosition);
	
					dist = GetVectorDistance(vClientPosition, position, false);
					if (dist < Ionrange)
					{
						MakeVectorFromPoints(position, vClientPosition, vReturn);
						NormalizeVector(vReturn, vReturn);
						ScaleVector(vReturn, 10000.0 - dist*10);
	
						TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vReturn);
					}
				}
			}
*/
		}
}



public void TrueFusionwarrior_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage;
		IOCdamage= 5000.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackFloat(data, IOCDist); // Range
		WritePackFloat(data, IOCdamage); // Damge
		WritePackCell(data, ref);
		ResetPack(data);
		TrueFusionwarrior_IonAttack(data);
	}
}

public Action TrueFusionwarrior_DrawIon(Handle Timer, any data)
{
	TrueFusionwarrior_IonAttack(data);
		
	return (Plugin_Stop);
}
	
public void TrueFusionwarrior_DrawIonBeam(float startPosition[3], const int color[4])
{
	float position[3];
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] = startPosition[2] + 3000.0;	
	
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.15, 25.0, 25.0, 0, 1.0, color, 3 );
	TE_SendToAll();
	position[2] -= 1490.0;
	TE_SetupGlowSprite(startPosition, gGlow1, 1.0, 1.0, 255);
	TE_SendToAll();
}