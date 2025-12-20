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


void RaidbossBobTheFirst_Duo_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Bob the First, True Teamwork");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_bob_the_first_duo");
	data.IconCustom = true;
	data.Flags = -1;
	data.Category = Type_Hidden;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
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
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossBobTheFirst_Duo(vecPos, vecAng, team, data);
}

methodmap RaidbossBobTheFirst_Duo < CClotBody
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

	public RaidbossBobTheFirst_Duo(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(CClotBody(pos, vecAng, COMBINE_CUSTOM_MODEL, "1.15", "20000000", ally, _, _, true, false));
		
		i_NpcWeight[npc.index] = 4;
		
		KillFeed_SetKillIcon(npc.index, "tf_projectile_rocket");
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.m_bisWalking = false;
		npc.SetActivity("ACT_MUDROCK_RAGE");
		b_NpcIsInvulnerable[npc.index] = true;

		npc.PlayIntroStartSound();

		func_NPCDeath[npc.index] = RaidbossBobTheFirst_Duo_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = RaidbossBobTheFirst_Duo_OnTakeDamage;
		func_NPCThink[npc.index] = RaidbossBobTheFirst_Duo_ClotThink;
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

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
		
		return npc;
	}
}
/*

TODO:

List of abiltiies:

*/
public void RaidbossBobTheFirst_Duo_ClotThink(int iNPC)
{
	RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(iNPC);
	
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

}

Action RaidbossBobTheFirst_Duo_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker < 1)
		return Plugin_Continue;

	RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(victim);

	if(b_ThisEntityIgnoredByOtherNpcsAggro[npc.index])
	{
		if(attacker <= MaxClients && TeutonType[attacker] != TEUTON_NONE)
		{	
			damage = 0.0;
			return Plugin_Handled;
		}
	}

	return Plugin_Changed;
}

void RaidbossBobTheFirst_Duo_NPCDeath(int entity)
{
	RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(entity);
	
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

static Action Bob_DeathCutsceneCheck(Handle timer)
{
	if(!LastMann)
		return Plugin_Continue;
	
	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int victim = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(victim != INVALID_ENT_REFERENCE && GetTeam(victim) != TFTeam_Red)
			SmiteNpcToDeath(victim);
	}
	
	GiveProgressDelay(6.0);
	Waves_ForceSetup(6.0);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			if(IsPlayerAlive(client))
				ForcePlayerSuicide(client);
			
			ApplyLastmanOrDyingOverlay(client);
			SendConVarValue(client, sv_cheats, "1");
			Convars_FixClientsideIssues(client);
		}
	}
	ResetReplications();

	cvarTimeScale.SetFloat(0.1);
	CreateTimer(0.5, SetTimeBack);

	GivePlayerItems();
	return Plugin_Stop;
}

static void GivePlayerItems(int coolwin = 0)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
		{
			Items_GiveNamedItem(client, "Bob's Curing Hand");
			if(coolwin == 0)
				CPrintToChat(client, "{default}밥이 당신에게 깃든 심해의 감염원을 전부 제거해주었습니다. 당신이 얻은 것은...: {yellow}''밥의 치유의 손길''{default}!");
			else
				CPrintToChat(client, "{default}당신은 밥을 공격하지 않았고, 그런 밥이 당신에게 준 것은...: {yellow}''밥의 치유의 손길''{default}!");
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

	RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(entity);
	npc.PlayBobMeleePreHit();
	npc.FaceTowards(VectorTarget, 20000.0);
	int FramesUntillHit = RoundToNearest(TimeUntillHit * float(TickrateModifyInt) * ReturnEntityAttackspeed(entity));

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
	RaidbossBobTheFirst_Duo npc = view_as<RaidbossBobTheFirst_Duo>(entity);
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
				
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
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
