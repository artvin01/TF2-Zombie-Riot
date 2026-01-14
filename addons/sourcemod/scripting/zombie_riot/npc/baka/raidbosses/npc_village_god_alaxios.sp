#pragma semicolon 1
#pragma newdecls required

static const char g_HurtSounds[][] = {
	"zombiesurvival/medieval_raid/arkantos_hurt_1.mp3",
	"zombiesurvival/medieval_raid/arkantos_hurt_2.mp3",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};
static const char g_RandomGroupScream[][] = {
	"zombiesurvival/medieval_raid/battlecry1.mp3",
	"zombiesurvival/medieval_raid/battlecry2.mp3",
	"zombiesurvival/medieval_raid/battlecry3.mp3",
	"zombiesurvival/medieval_raid/battlecry4.mp3",
};
static const char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};
static const char g_MeleeHitSounds[] = "weapons/halloween_boss/knight_axe_hit.wav";
static const char g_DeathSounds[] = "zombiesurvival/medieval_raid/arkantos_death.mp3";
static const char g_PullSounds[] = "weapons/physcannon/energy_sing_explosion2.wav";
static const char g_SlamSounds[] = "ambient/rottenburg/barrier_smash.wav";
static const char g_LastStand[] = "zombiesurvival/medieval_raid/arkantos_rage.mp3";

static float f_AlaxiosCantDieLimit[MAXENTITIES];
static int NPCId;

public void VillageAlaxios_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "God Alaxios");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_village_alaxios");
	strcopy(data.Icon, sizeof(data.Icon), "cyber_alaxios");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
	RevertResearchLogic = 0;
}

static void ClotPrecache()
{
	PrecacheSoundCustomArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundCustomArray(g_RandomGroupScream);
	PrecacheSoundArray(g_SummonSounds);
	PrecacheSoundCustom(g_DeathSounds);
	PrecacheSoundCustom(g_LastStand);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_PullSounds);
	PrecacheSound(g_SlamSounds);
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
	PrecacheSoundCustom("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return VillageAlaxios(vecPos, vecAng, team, data);
}

methodmap VillageAlaxios < CClotBody
{
	property float m_flAlaxiosBuffEffect
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property float m_flReviveAlaxiosTime
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(1.6, 2.5);
	}
	public void PlayDeathSound() 
	{
		EmitCustomToAll(g_DeathSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeWarCry() 
	{
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.9, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.6, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 55.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 75.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	}
	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySlamSound() 
	{
		EmitSoundToAll(g_SlamSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRageSound() 
	{
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}

	public VillageAlaxios(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VillageAlaxios npc = view_as<VillageAlaxios>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "25000", ally, false, false, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Alaxios_Win);

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_bDissapearOnDeath = true;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RemoveAllDamageAddition();

		npc.m_iChanged_WalkCycle = 4;
		npc.SetActivity("ACT_WALK");
		npc.m_flSpeed = 320.0;
	
		npc.m_flMeleeArmor = 1.25;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				if(StrContains(data, "seainfection") != -1)
					ShowGameText(client_check, "item_armor", 1, "%t", "Sea Alaxios Arrived");
				else
					ShowGameText(client_check, "item_armor", 1, "%t", "Alaxios Arrived");
			}
		}

		i_RaidGrantExtra[npc.index] = 1;
		if(StrContains(data, "wave_10") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
		}
		else if(StrContains(data, "wave_20") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
		}
		else if(StrContains(data, "wave_40") != -1)
		{
			i_RaidGrantExtra[npc.index] = 5;
		}
		RevertResearchLogic = 0;
		if(StrContains(data, "res1") != -1)
		{
			RevertResearchLogic = 1;
			Medival_Wave_Difficulty_Riser(1);
		}
		else if(StrContains(data, "res2") != -1)
		{
			RevertResearchLogic = 2;
			Medival_Wave_Difficulty_Riser(2);
		}
		else if(StrContains(data, "res3") != -1)
		{
			RevertResearchLogic = 3;
			Medival_Wave_Difficulty_Riser(3);
		}
		else if(StrContains(data, "res4") != -1)
		{
			RevertResearchLogic = 4;
			Medival_Wave_Difficulty_Riser(4);
		}
		else if(StrContains(data, "res5") != -1)
		{
			RevertResearchLogic = 5;
			Medival_Wave_Difficulty_Riser(5);
		}

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 6;
		}

		if(i_RaidGrantExtra[npc.index] >= 5)
		{
			RaidModeTime = GetGameTime(npc.index) + 400.0;
		}
		if(ally == TFTeam_Red)
		{
			RaidModeTime = GetGameTime(npc.index) + 9999.0;
			RaidAllowsBuildings = true;
		}
		if(Waves_InFreeplay())
		{
			RaidModeTime = GetGameTime(npc.index) + 9999999.0;
		}
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		if(StrContains(data, "seainfection") != -1)
			npc.m_iBleedType = BLEEDTYPE_SEABORN;

		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		b_angered_twice[npc.index] = false;

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
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
		
		npc.Anger = false;

		npc.m_flAlaxiosBuffEffect = GetGameTime() + 7.0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 5.0;
		npc.m_flNextRangedAttack = GetGameTime() + 8.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.g_TimesSummoned = 0;
		f_AlaxiosCantDieLimit[npc.index] = 0.0;
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		
		func_NPCDeath[npc.index] = GodAlaxios_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = GodAlaxios_OnTakeDamage;
		func_NPCThink[npc.index] = VillageAlaxios_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, VillageAlaxios_OnTakeDamagePost);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 16777215);

		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
		music.Time = 189;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Arknights - Putrid");
		strcopy(music.Artist, sizeof(music.Artist), "Arknights");
		Music_SetRaidMusic(music);
		Citizen_MiniBossSpawn();
		
		float flPos[3];
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_wispy_parent_g", npc.index, "", {0.0,0.0,0.0});
		npc.StartPathing();

		DoGlobalMultiScaling();
		
		return npc;
	}
}

static void VillageAlaxios_ClotThink(int iNPC)
{
	GodAlaxios npc = view_as<GodAlaxios>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(GetTeam(npc.index) != TFTeam_Red && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{lightblue}갓 알락시오스{default}: 너 혼자서는 아무것도 하지 못 한다!");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}갓 알락시오스{default}: 너의 무기술은 아틀란티스에 비하면 허약하다!!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}갓 알락시오스{default}: 지금 항복할텐가?!");
				}
			}
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (9 * 2);
		
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
			{
				SetTeam(baseboss_index, TFTeam_Red);
				SetEntityCollisionGroup(baseboss_index, 24);
			}
		}
		CPrintToChatAll("{lightblue}갓 알락시오스{default}: 안 돼... 놈들이 온다, 전투 준비!!!");
		RaidBossActive = INVALID_ENT_REFERENCE;
		for(int i; i<32; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			}
			int spawn_index = NPC_CreateByName("npc_seaslider", -1, pos, ang, TFTeam_Blue);
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
				fl_Extra_Damage[spawn_index] = 25.0;
				fl_Extra_Speed[spawn_index] = 1.5;
			}
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
		int Spawner_entity = GetRandomActiveSpawner();
		if(IsValidEntity(Spawner_entity))
		{
			GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
			GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
		}
		int spawn_index = NPC_CreateByName("npc_isharmla", -1, pos, ang, TFTeam_Blue);
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(npc.index, spawn_index);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", 100000000);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 100000000);
			fl_Extra_Damage[spawn_index] = 25.0;
			fl_Extra_Speed[spawn_index] = 1.5;
		}
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		return;
	}
	if(b_angered_twice[npc.index])
	{
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		int closestTarget = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(closestTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
		npc.SetActivity("ACT_IDLE");
		npc.m_bisWalking = false;
		npc.StopPathing();
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
			{
				TF2_StunPlayer(client, 0.5, 0.5, TF_STUNFLAGS_LOSERSTATE);
			}
		}
		if(AlaxiosForceTalk())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(f_AlaxiosCantDieLimit[npc.index] && f_AlaxiosCantDieLimit[npc.index] < GetGameTime())
	{
		int RandSound = GetRandomInt(0, sizeof(g_RandomGroupScream) - 1);
		EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_RandomGroupScream[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		f_AlaxiosCantDieLimit[npc.index] = 0.0;
	}
	if(npc.m_flSpeed >= 1.0)
	{
		if(HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 220.0;
		}
		else if(!HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 320.0;
		}	
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoingSpecial < gameTime)
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}
	else
	{
		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.65;
	}		


	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			if(!npc.Anger)
			{
				npc.PlayRageSound();
				AlaxiosSayWordsAngry(npc.index);
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) * 6) / 7);
			}
		}
	}

	if(GetTeam(npc.index) == TFTeam_Red)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			if(f_TargetToWalkToDelay[npc.index] < gameTime)
			{
				npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
				if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
				{
					npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
				}
			}
			else 
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
			f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;	
		}	
	}
	
	if(f_TargetToWalkToDelay[npc.index] < gameTime)
	{
		if(npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && !npc.m_flNextRangedAttackHappening && i_RaidGrantExtra[npc.index] >= 4)
		{
			npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
			if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
		}
		else 
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		}
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;
	}	
	int ActionToTake = -1;
	bool AllowSelfDefense = true;
	//This means nothing, we do nothing.
	if(IsEntityAlive(npc.m_iTargetWalkTo))
	{
		//Predict their pos.
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
		}

		if(npc.m_flNextRangedAttackHappening > GetGameTime(npc.index))
		{
			ActionToTake = -1;
		}	
		else if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo) && !(i_RaidGrantExtra[npc.index] >= 4 && npc.Anger && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index)))
		{
			if(flDistanceToTarget < (500.0 * 500.0) && flDistanceToTarget > (250.0 * 250.0) && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				ActionToTake = 1;
				//first we try to jump to them if close enough.
			}
			else if(flDistanceToTarget < (250.0 * 250.0) && npc.m_flNextRangedAttack < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 3)
			{
				//We are pretty close, we will do a wirlwind to kick everyone away after a certain amount of delay so they can prepare.
				ActionToTake = 2;
			}
		}
		else if(IsValidAlly(npc.index, npc.m_iTargetWalkTo) || npc.Anger)
		{
			if((npc.Anger || flDistanceToTarget < (125.0* 125.0)) && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 4)
			{
				//can only be above wave 15.
				ActionToTake = -1;
				GodAlaxiosAOEBuff(npc,GetGameTime(npc.index));
			}
		}
		else
		{
			ActionToTake = -1; //somethings wrong, do nothing.
		}

		switch(ActionToTake)
		{
			case 1:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				npc.PlayPullSound();
				flPos[2] += 500.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				
				npc.m_flSpeed = 0.0;
				if(npc.m_bPathing)
				{
					npc.StopPathing();
					
				}
				if(npc.m_iChanged_WalkCycle != 8) 	
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_JUMP");
					npc.m_bisWalking = false;
					npc.SetPlaybackRate(1.0);
					npc.m_iTarget = -1;
				}
				
				npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.5;
				if(npc.Anger)
					npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.0;

				if(npc.g_TimesSummoned == 4)
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
				}
				else
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 20.0;
				}
				if(npc.Anger)
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 7.0;

				npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0; //lets not intiate any new ability for a second.
				npc.m_fbRangedSpecialOn = true;
				//just jump at them.
			}
			case 2:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 3.0);
				SetParent(npc.index, particle, "effect_hand_r");
				npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 3.0; //3 seconds to prepare.
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 20.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 4.5; //lets not intiate any new ability for a second.
				if(npc.Anger)
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 10.0;
					npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 1.5; //1.5 seconds to prepare.
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5; //lets not intiate any new ability for a second.
				}
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;		
	}
	if(AllowSelfDefense)
	{
		GodAlaxiosSelfDefense(npc, gameTime);
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;
	GodAlaxiosHurricane(npc, gameTime);
	GodAlaxiosJumpSpecial(npc, gameTime);

}

static void VillageAlaxios_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	GodAlaxios npc = view_as<GodAlaxios>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(i_RaidGrantExtra[npc.index] <= 2)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			//BOOKMARK TODO
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(7.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_scout",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_scout",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 3)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_brawler",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_pikeman",_, RoundToCeil(15.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow_giant",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalHealthBoss), RoundToCeil(2.0 * MultiGlobalEnemyBoss), true);				
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 4)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_longbowmen",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",_, RoundToCeil(2.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_obuch",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(2500.0 * MultiGlobalHighHealthBoss), 1, true);		
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(125000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(6.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_arbalest",50000, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_longbowmen",50000, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_samurai",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_paladin",100000, RoundToCeil(10.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",250000, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			AlaxiosSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",100000, RoundToCeil(2.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_riddenarcher",75000, RoundToCeil(20.0 * MultiGlobalEnemy));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(50000.0 * MultiGlobalHighHealthBoss), 1);
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_son_of_osiris", RoundToCeil(1200000.0 * MultiGlobalHighHealthBoss), 1, true);		
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_villager", RoundToCeil(250000.0 * MultiGlobalHighHealthBoss), 1, true);	
		}
	}
}
