#pragma semicolon 1
#pragma newdecls required

static bool BlockLoseSay;

static const char g_DeathSounds[][] = {
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/no02.wav",
};

static const char g_HurtSounds[][] = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/npc/male01/ohno.wav",
	"vo/npc/male01/overthere01.wav",
	"vo/npc/male01/overthere02.wav",
};
static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};


static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};
static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_SlamSounds[][] = {
	"ambient/rottenburg/barrier_smash.wav"
};
static char g_SummonSounds[][] = {
	"weapons/buff_banner_horn_blue.wav",
	"weapons/buff_banner_horn_red.wav",
};
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};

#define SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE	"misc/halloween/spell_mirv_explode_primary.wav"

#define ALAXIOS_BUFF_MAXRANGE 500.0

static int NPCId;
public void GodAlaxios_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "God Alaxios");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_god_alaxios");
	strcopy(data.Icon, sizeof(data.Icon), "alaxios");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Special;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds));        i++) { PrecacheSound(g_IdleAlertedSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));        i++) { PrecacheSound(g_MeleeHitSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));        i++) { PrecacheSound(g_MeleeAttackSounds[i]);        }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));        i++) { PrecacheSound(g_MeleeMissSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SlamSounds));        i++) { PrecacheSound(g_SlamSounds[i]);        }
	for (int i = 0; i < (sizeof(g_SummonSounds));        i++) { PrecacheSound(g_SummonSounds[i]);        }
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return GodAlaxios(client, vecPos, vecAng, ally, data);
}
static float f_AlaxiosCantDieLimit[MAXENTITIES];
static bool b_angered_twice[MAXENTITIES];
static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

int Alaxiosspeedint[MAXENTITIES];
methodmap GodAlaxios < CClotBody
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
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound()
	{
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	public void PlayDeathSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
		f_AlaxiosCantDieLimit[this.index] = GetGameTime() + 0.5;
	}
	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySlamSound() 
	{
		EmitSoundToAll(g_SlamSounds[GetRandomInt(0, sizeof(g_SlamSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}

	public GodAlaxios(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		GodAlaxios npc = view_as<GodAlaxios>(CClotBody(vecPos, vecAng, COMBINE_CUSTOM_MODEL, "1.25", "25000", ally, false, false, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Alaxios_Win);

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		if(ZR_GetWaveCount()+1 >= 59)
		{
			RaidModeTime = GetGameTime(npc.index) + 300.0;
		}
		if(ally == TFTeam_Red)
		{
			RaidModeTime = GetGameTime(npc.index) + 9999.0;
			RaidAllowsBuildings = true;
		}

		npc.m_iChanged_WalkCycle = 4;
		npc.SetActivity("ACT_WALK");
		npc.m_flSpeed = 320.0;
		Alaxiosspeedint[npc.index] = 320;
	
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
				ShowGameText(client_check, "item_armor", 1, "%t", "Alaxios Arrived");
			}
		}

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		b_angered_twice[npc.index] = false;

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		npc.Anger = false;

		npc.m_flAlaxiosBuffEffect = GetGameTime() + 25.0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 10.0;
		npc.m_flNextRangedAttack = GetGameTime() + 15.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.g_TimesSummoned = 0;
		npc.m_bWasSadAlready = false;
		f_AlaxiosCantDieLimit[npc.index] = 0.0;
		
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
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		
		func_NPCDeath[npc.index] = GodAlaxios_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = GodAlaxios_OnTakeDamage;
		func_NPCThink[npc.index] = GodAlaxios_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, GodAlaxios_OnTakeDamagePost);

		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/workshop/weapons/c_models/c_xms_cold_shoulder/c_xms_cold_shoulder.mdl");
		SetVariantString("5.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_iWearable2 = npc.EquipItem("partyhat", "models/player/items/soldier/soldier_spartan.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		Citizen_MiniBossSpawn();
		
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
		music.Time = 189;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Arknights - Putrid");
		strcopy(music.Artist, sizeof(music.Artist), "HyperGryph");
		Music_SetRaidMusic(music);

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_wispy_parent_g", npc.index, "root", {0.0,0.0,0.0});
		npc.StartPathing();

		DoGlobalMultiScaling();
		
		return npc;
	}
}

//TODO 
//Rewrite
public void GodAlaxios_ClotThink(int iNPC)
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
					CPrintToChatAll("{lightblue}God Alaxios{default}: You have no chance alone!");
				}
				case 1:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: Your weaponry frails in comaprison to Atlantis!!");
				}
				case 3:
				{
					CPrintToChatAll("{lightblue}God Alaxios{default}: Concider surrendering?!");
				}
			}
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (9 * 2);
		
		ZR_NpcTauntWinClear();
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
			{
				SetTeam(baseboss_index, TFTeam_Red);
				SetEntityCollisionGroup(baseboss_index, 24);
			}
		}
		ForcePlayerLoss();
		CPrintToChatAll("{lightblue}God Alaxios{default}: No.. No No!! They are comming, prepare to fight together NOW!!!");
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
		for (int client = 0; client < MaxClients; client++)
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
	//float point impresicion...
	if(Alaxiosspeedint[npc.index] == 320)
	{
		if(f_GodAlaxiosBuff[npc.index] > GetGameTime())
		{
			npc.m_flSpeed = 220.0;
			Alaxiosspeedint[npc.index] = 220;
		}
	}
	else if(Alaxiosspeedint[npc.index] == 220)
	{
		if(f_GodAlaxiosBuff[npc.index] < GetGameTime())
		{
			Alaxiosspeedint[npc.index] = 320;
			npc.m_flSpeed = 320.0;
		}		
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.Anger)
	{
		npc.m_flRangedArmor = 0.3;
		npc.m_flMeleeArmor = 0.35;
	}
	else
	{
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
	}


	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	/*
	if(npc.m_flReviveAlaxiosTime)
	{
		if(npc.m_flReviveAlaxiosTime < gameTime)
		{
			if(npc.m_iChanged_WalkCycle == 5)
			{
				npc.m_flReviveAlaxiosTime = 0.0;
				npc.AlaxiosFakeDeathState(0);
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_WALK");
					npc.StartPathing();
					npc.m_flSpeed = 320.0;
					npc.m_bisWalking = true;
				}
				SetEntityRenderColor(npc.index, 255, 255, 255, 255);
				SetEntityRenderMode(npc.index, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
				SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
				npc.m_flReviveAlaxiosTime = 0.0;
				b_ThisEntityIgnored[npc.index] = false;
				b_DoNotUnStuck[npc.index] = false;
			}
		}
	}
	if(b_ThisEntityIgnored[npc.index])
	{
		int HealByThis = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4000;
		SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iHealth") + HealByThis);
		if(GetEntProp(npc.index, Prop_Data, "m_iHealth") >= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
		}
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpc; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcs[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != RAIDMODE_GOD_ALAXIOS)
			{
				allyAlive = true;
			}
		}
		if(!allyAlive)
		{
			npc.AlaxiosFakeDeathState(0);
		}
		return;
	}
	*/
	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndex(i_ObjectsNpcsTotal[targ]);
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
				AlaxiosSayWordsAngry();
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
			}
		}
	}
	npc.PlayIdleAlertSound();
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
		if(npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && !npc.m_flNextRangedAttackHappening && ZR_GetWaveCount()+1 > 30)
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
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTargetWalkTo);
		}

		if(npc.m_flNextRangedAttackHappening > GetGameTime(npc.index))
		{
			ActionToTake = -1;
		}	
		else if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo) && !(ZR_GetWaveCount()+1 > 30 && npc.Anger && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index)))
		{
			if(flDistanceToTarget < (500.0 * 500.0) && flDistanceToTarget > (250.0 * 250.0) && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				ActionToTake = 1;
				//first we try to jump to them if close enough.
			}
			else if(flDistanceToTarget < (250.0 * 250.0) && npc.m_flNextRangedAttack < GetGameTime(npc.index) && ZR_GetWaveCount()+1 > 15)
			{
				//We are pretty close, we will do a wirlwind to kick everyone away after a certain amount of delay so they can prepare.
				ActionToTake = 2;
			}
		}
		else if(IsValidAlly(npc.index, npc.m_iTargetWalkTo) || npc.Anger)
		{
			if((npc.Anger || flDistanceToTarget < (125.0* 125.0)) && npc.m_flAlaxiosBuffEffect < GetGameTime(npc.index) && ZR_GetWaveCount()+1 > 30)
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
				
				Alaxiosspeedint[npc.index] = 0;
				npc.m_flSpeed = 0.0;
				if(npc.m_bPathing)
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
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
	
public Action GodAlaxios_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	GodAlaxios npc = view_as<GodAlaxios>(victim);

	if(npc.m_flReviveAlaxiosTime > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!npc.Anger)
	{
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
		if(health < 1)
		{
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && ZR_GetWaveCount()+1 > 55 && !b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 1)
	{
		if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			b_angered_twice[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(32.0);
			damage = 0.0;
			RaidModeTime += 60.0;
			f_TalkDelayCheck = GetGameTime() + 4.0;
			CPrintToChatAll("{lightblue}God Alaxios{default}: That's it, I will make you listen.");
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}

public void GodAlaxios_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	GodAlaxios npc = view_as<GodAlaxios>(victim);
	float maxhealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(ZR_GetWaveCount()+1 <= 15)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(7.0 * MultiGlobal));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_archer",_, RoundToCeil(5.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_scout",_, RoundToCeil(4.0 * MultiGlobal));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_skirmisher",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(5.0 * MultiGlobal));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4);
			AlaxiosSayWords();
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			if(npc.m_bWasSadAlready)
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 25.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(2.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_scout",_, RoundToCeil(2.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(3.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(5000.0 * MultiGlobalAlaxios), 1, true);		
			}
			else
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_spearmen",_, RoundToCeil(5.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_scout",_, RoundToCeil(5.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_man_at_arms",_, RoundToCeil(8.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalAlaxios), 1, true);		
			}
		}
	}
	else if(ZR_GetWaveCount()+1 <= 30)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(4.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow",_, RoundToCeil(4.0 * MultiGlobal));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(12.0 * MultiGlobal));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_brawler",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(5.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman",_, RoundToCeil(5.0 * MultiGlobal));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4);
			AlaxiosSayWords();
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			if(npc.m_bWasSadAlready)
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 25.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_pikeman",_, RoundToCeil(5.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow_giant",_, RoundToCeil(1.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(5000.0 * MultiGlobalAlaxios), 1, true);		
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalAlaxios), RoundToCeil(2.0 * MultiGlobal), true);		
			}
			else
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_pikeman",_, RoundToCeil(15.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_crossbow_giant",_, RoundToCeil(2.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(10000.0 * MultiGlobalAlaxios), 1, true);		
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_construct", RoundToCeil(10000.0 * MultiGlobalAlaxios), RoundToCeil(2.0 * MultiGlobal), true);				
			}
		}
	}
	else if(ZR_GetWaveCount()+1 <= 45)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_eagle_warrior",_, RoundToCeil(12.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_longbowmen",_, RoundToCeil(4.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobal));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_knight",_, RoundToCeil(5.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_twohanded_swordsman",_, RoundToCeil(12.0 * MultiGlobal));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",_, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_light_cav",_, RoundToCeil(12.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",_, RoundToCeil(2.0 * MultiGlobal));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4);
			AlaxiosSayWords();
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			if(npc.m_bWasSadAlready)
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 25.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",_, RoundToCeil(1.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_obuch",_, RoundToCeil(5.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(5000.0 * MultiGlobalAlaxios), 1);
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(75000.0 * MultiGlobalAlaxios), 1);
			}
			else
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",_, RoundToCeil(2.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_obuch",_, RoundToCeil(8.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(2500.0 * MultiGlobalAlaxios), 1, true);		
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(125000.0 * MultiGlobalAlaxios), 1, true);					
			}
		}
	}
	else
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(6.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_arbalest",50000, RoundToCeil(12.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_longbowmen",50000, RoundToCeil(4.0 * MultiGlobal));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_champion",75000, RoundToCeil(12.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_samurai",75000, RoundToCeil(12.0 * MultiGlobal));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_elite_skirmisher",50000, RoundToCeil(10.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_paladin",100000, RoundToCeil(10.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_swordsman_giant",250000, RoundToCeil(2.0 * MultiGlobal));
			GodAlaxiosSpawnEnemy(npc.index,"npc_medival_achilles", RoundToCeil(300000.0 * MultiGlobalAlaxios), 1);
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", GetEntProp(npc.index, Prop_Data, "m_iMaxHealth") / 4);
			AlaxiosSayWords();
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			if(npc.m_bWasSadAlready)
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 25.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",100000, RoundToCeil(1.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_riddenarcher",75000, RoundToCeil(10.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(25000.0 * MultiGlobalAlaxios), 1);
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_son_of_osiris", RoundToCeil(750000.0 * MultiGlobalAlaxios), 1, true);		
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_villager", RoundToCeil(150000.0 * MultiGlobalAlaxios), 1, true);		
			}
			else
			{
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_hussar",100000, RoundToCeil(2.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_riddenarcher",75000, RoundToCeil(20.0 * MultiGlobal));
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_monk",RoundToCeil(50000.0 * MultiGlobalAlaxios), 1);
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_son_of_osiris", RoundToCeil(1500000.0 * MultiGlobalAlaxios), 1, true);		
				GodAlaxiosSpawnEnemy(npc.index,"npc_medival_villager", RoundToCeil(250000.0 * MultiGlobalAlaxios), 1, true);				
			}
		}
	}
}

public void GodAlaxios_NPCDeath(int entity)
{
	GodAlaxios npc = view_as<GodAlaxios>(entity);
	if(!BlockLoseSay)
	{
		if(!npc.m_bDissapearOnDeath)
		{
			npc.PlayDeathSound();
		}
		
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: I have failed Atlantis...");
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: How was my army defeated..?");
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: You dont know what you are doing!");
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: We should be fighting together, not against each other, the {blue}sea{default} will be your doom...");
			}
		}
	}
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
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

	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}		
	}

	Citizen_MiniBossDeath(entity);
}

void GodAlaxiosSpawnEnemy(int alaxios, char[] plugin_name, int health = 0, int count, bool outline = false)
{
	if(GetTeam(alaxios) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(alaxios, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(alaxios, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(alaxios));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 4);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 4);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Outlined = outline;
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(alaxios);
	for(int i; i<count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += count;	// FIXME
}

void GodAlaxiosSelfDefense(GodAlaxios npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
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
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
										
							float damage = 20.0;
							if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
							{
								damage = 18.0; //nerf
							}
							else if(ZR_GetWaveCount()+1 > 55)
							{
								damage = 16.5; //nerf
							}

							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
							
							bool Knocked = false;
							
							if(IsValidClient(target))
							{
								if (IsInvuln(target))
								{
									Knocked = true;
									Custom_Knockback(npc.index, target, 900.0, true);
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
								Custom_Knockback(npc.index, target, 150.0, true); 
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

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_ARKANTOS_ATTACK_FAST");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.65;
					if(npc.Anger)
					{
						npc.m_flAttackHappens = gameTime + 0.125;
						npc.m_flDoingAnimation = gameTime + 0.125;
						npc.m_flNextMeleeAttack = gameTime + 0.35;
						int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
						for(int i; i < layerCount; i++)
						{
							view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 2.0);
						}
					}
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
				npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

void GodAlaxiosJumpSpecial(GodAlaxios npc, float gameTime)
{
	if(npc.m_flNextRangedSpecialAttackHappens)
	{
		static float ThrowPos[3]; 
		if(!IsValidEnemy(npc.index,npc.m_iTarget))
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true); //only visible targets!
		}
		float Range = 150.0;
		
		if(IsValidEnemy(npc.index,npc.m_iTarget))
		{
			static float enemypos[3]; 
			GetEntPropVector(npc.m_iTarget, Prop_Data, "m_vecAbsOrigin", enemypos);
			enemypos[2] += 45.0;
			if(npc.m_flNextRangedSpecialAttackHappens > gameTime + 0.5 && npc.m_fbRangedSpecialOn)
			{
				ThrowPos = enemypos;
			}
			npc.FaceTowards(ThrowPos, 15000.0);
			static float selfpos[3]; 
			float flAng[3]; // original
		
			int r = 200;
			int g = 200;
			int b = 255;
			float diameter = 25.0;
			
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 200);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 200);

			npc.GetAttachment("weapon_bone", selfpos, flAng);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			spawnRing_Vectors(ThrowPos, Range * 2.0 * zr_smallmapbalancemulti.FloatValue, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.15, 5.0, 0.0, 1);	
		}
		
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime + 0.5 && npc.m_fbRangedSpecialOn)
		{
			npc.AddGesture("ACT_CUSTOM_ATTACK_SPEAR");
			npc.m_fbRangedSpecialOn = false;
		}

		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			npc.FaceTowards(ThrowPos, 15000.0);
			npc.m_flNextRangedSpecialAttackHappens = 0.0;
			static float selfpos[3]; 
			float flAng[3]; // original
			
			
			npc.GetAttachment("weapon_bone", selfpos, flAng);
			//throw extreamly powerfull spear/laser lighting whatever.	
			EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
			EmitSoundToAll(SOUND_WAND_LIGHTNING_ABILITY_PAP_SMITE, 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, ThrowPos);
			int r = 200;
			int g = 200;
			int b = 255;
			float diameter = 25.0;
				
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 200);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Laser, 0, 0, 0, 1.0, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.9, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.8, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.7, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 150);
			TE_SetupBeamPoints(selfpos, ThrowPos, FusionWarrior_BEAM_Glow, 0, 0, 0, 0.6, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
			spawnRing_Vectors(ThrowPos, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.5, 5.0, 0.0, 1,Range * 2.0 * zr_smallmapbalancemulti.FloatValue);	
			float damage = 600.0;
			if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
			{
				damage = 500.0; //nerf
			}
			else if(ZR_GetWaveCount()+1 > 55)
			{
				damage = 465.5; //nerf
			}
				
			Explode_Logic_Custom(damage * zr_smallmapbalancemulti.FloatValue, 0, npc.index, -1, ThrowPos,Range * zr_smallmapbalancemulti.FloatValue, 1.0, _, true, 20);
			TE_Particle("asplode_hoodoo", ThrowPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
			
			npc.SetVelocity({0.0,0.0,-1000.0});

			if(npc.m_iChanged_WalkCycle != 4)
			{
				npc.m_iChanged_WalkCycle = 4;
				npc.SetActivity("ACT_WALK");
				npc.StartPathing();
				Alaxiosspeedint[npc.index] = 320;
				npc.m_flSpeed = 320.0;
				npc.m_bisWalking = true;
			}
		}
	}
}

void GodAlaxiosHurricane(GodAlaxios npc, float gameTime)
{
	if(npc.m_flNextRangedAttackHappening)
	{
		static float EnemyPos[3];
		static float pos[3]; 
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float Range = 500.0;
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		spawnRing_Vectors(pos, Range * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", 220, 220, 255, 200, 1, /*duration*/ 0.11, 5.0, 0.0, 1);	
		//Apply an Connection beam.
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
				float Distance = GetVectorDistance(pos, EnemyPos, true);
				if(Distance < (Range * Range))
				{
					//only apply the laser if they are near us.
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
					{
						int red = 65;
						int green = 65;
						int blue = 255;
						if(EnemyLoop == npc.m_iTargetWalkTo)
						{
							red = 220;
							green = 220;
							blue = 255;
						}
						if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							{
								RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
							}

							int laser;
							
							laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
				
							i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
							//Im seeing a new target, relocate laser particle.
						}
						else
						{
							int laser = EntRefToEntIndex(i_LaserEntityIndex[EnemyLoop]);
							SetEntityRenderColor(laser, red, green, blue, 255);
							SetEntityRenderMode(laser, RENDER_TRANSCOLOR);
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
			}
			else
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}						
			}
		}
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
		{
			int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(entity_close))
			{
				if(IsValidEnemy(npc.index, entity_close))
				{
					GetEntPropVector(entity_close, Prop_Send, "m_vecOrigin", EnemyPos);
					float Distance = GetVectorDistance(pos, EnemyPos, true);
					if(Distance < (Range * Range))
					{
						//only apply the laser if they are near us.
						if(Can_I_See_Enemy_Only(npc.index, entity_close) && IsEntityAlive(entity_close))
						{
							int red = 65;
							int green = 65;
							int blue = 255;
							if(entity_close == npc.m_iTargetWalkTo)
							{
								red = 220;
								green = 220;
								blue = 255;
							}
							if(!IsValidEntity(i_LaserEntityIndex[entity_close]))
							{
								if(IsValidEntity(i_LaserEntityIndex[entity_close]))
								{
									RemoveEntity(i_LaserEntityIndex[entity_close]);
								}

								int laser;
								
								laser = ConnectWithBeam(npc.index, entity_close, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
					
								i_LaserEntityIndex[entity_close] = EntIndexToEntRef(laser);
								//Im seeing a new target, relocate laser particle.
							}
							else
							{
								int laser = EntRefToEntIndex(i_LaserEntityIndex[entity_close]);
								SetEntityRenderColor(laser, red, green, blue, 255);
								SetEntityRenderMode(laser, RENDER_TRANSCOLOR);
							}
						}
						else
						{
							if(IsValidEntity(i_LaserEntityIndex[entity_close]))
							{
								RemoveEntity(i_LaserEntityIndex[entity_close]);
							}
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[entity_close]))
						{
							RemoveEntity(i_LaserEntityIndex[entity_close]);
						}
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[entity_close]))
					{
						RemoveEntity(i_LaserEntityIndex[entity_close]);
					}						
				}
			}
		}
		
		
		
		if(npc.m_flNextRangedAttackHappening < GetGameTime(npc.index))
		{
			npc.AddGesture("ACT_SEABORN_ATTACK_BESERK_1");
			npc.m_flDoingAnimation = gameTime + 0.5;
			npc.m_flNextRangedAttackHappening = 0.0;
			static float flPos[3]; 
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
			flPos[2] += 5.0;
			ParticleEffectAt(flPos, "taunt_yeti_fistslam", 0.25);
			npc.PlaySlamSound();
			//Kick everyone away in range, except the one target we hate, make sure to check line of sight too.
			for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
			{
				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					GetEntPropVector(EnemyLoop, Prop_Send, "m_vecOrigin", EnemyPos);
					float Distance = GetVectorDistance(pos, EnemyPos);
					if(Distance < Range)
					{
						//only apply the laser if they are near us.
						if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && EnemyLoop == npc.m_iTargetWalkTo)
						{
							//Pull them.
							static float angles[3];
							GetVectorAnglesTwoPoints(EnemyPos, pos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1.50;
							ScaleVector(velocity, Distance * attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);   
						}
						else if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
						{
							float damage = 50.0;
							if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
							{
								damage = 45.0; //nerf
							}
							else if(ZR_GetWaveCount()+1 > 55)
							{
								damage = 40.5; //nerf
							}

							SDKHooks_TakeDamage(EnemyLoop, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, _);		
							//push them away.
							static float angles[3];
							GetVectorAnglesTwoPoints(EnemyPos, pos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 1500.0;
							ScaleVector(velocity, attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
							{
								velocity[2] = 350.0;
							}
							else
							{
								velocity[2] = 200.0;
							}
										
							// apply velocity
							velocity[0] *= -1.0;
							velocity[1] *= -1.0;
						//	velocity[2] *= -1.0;
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);    	
						}
					}
				}
			}
			for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++) //RED npcs.
			{
				int entity_close = EntRefToEntIndex(i_ObjectsNpcsTotal[entitycount]);
				if(IsValidEntity(entity_close))
				{
					if(IsValidEnemy(npc.index, entity_close))
					{
						GetEntPropVector(entity_close, Prop_Send, "m_vecOrigin", EnemyPos);
						float Distance = GetVectorDistance(pos, EnemyPos, true);
						if(Distance < (Range * Range))
						{
							//only apply the laser if they are near us.
							if(Can_I_See_Enemy_Only(npc.index, entity_close) && IsEntityAlive(entity_close))
							{
								if(entity_close != npc.m_iTargetWalkTo)
								{
									CClotBody npcenemy = view_as<CClotBody>(entity_close);
									static float flPos_1[3]; 
									GetEntPropVector(npcenemy.index, Prop_Data, "m_vecAbsOrigin", flPos_1);
									flPos_1[2] += 500.0;
									npcenemy.SetVelocity({0.0,0.0,0.0});
									PluginBot_Jump(npcenemy.index, flPos_1);
									float damage = 50.0;
									if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
									{
										damage = 45.0; //nerf
									}
									else if(ZR_GetWaveCount()+1 > 55)
									{
										damage = 40.5; //nerf
									}

									SDKHooks_TakeDamage(entity_close, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, _);	
								}
							}
						}
					}
				}
			}
			//Erase all lasers.
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}		
			}
		}
	}
}



void GodAlaxiosAOEBuff(GodAlaxios npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flAlaxiosBuffEffect < gameTime)
	{
		bool buffed_anyone;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (ALAXIOS_BUFF_MAXRANGE * ALAXIOS_BUFF_MAXRANGE))
					{
						f_GodAlaxiosBuff[entitycount] = GetGameTime() + 10.0; //allow buffing of players too if on red.
						//Buff this entity.
						buffed_anyone = true;	
					}
				}
			}
		}
		if(npc.Anger)
			buffed_anyone = true;

		if(buffed_anyone)
		{
			npc.m_flAlaxiosBuffEffect = gameTime + 10.0;
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				f_GodAlaxiosBuff[npc.index] = GetGameTime() + 5.0; //the buff for alaxios himself is half the time.
			}
			else
			{
				f_GodAlaxiosBuff[npc.index] = GetGameTime() + 3.0; //the buff for alaxios himself is half the time.
			}
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				r = 220;
				g = 220;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, ALAXIOS_BUFF_MAXRANGE * 2.0);		
			npc.AddGestureViaSequence("g_wave");
			if(!mute)
			{
				spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				MedivalHussar npc_sound = view_as<MedivalHussar>(npc.index);
				npc_sound.PlayMeleeWarCry();
			}
		}
		else
		{
			npc.m_flAlaxiosBuffEffect = gameTime + 1.0; //Try again in a second.
		}
	}
}


void AlaxiosSayWords()
{
	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: You don't know the dangers you're getting yourself into fighting me and my army at the same time!");
		}
		case 1:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: My army will always help me back up!");
		}
		case 2:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: Me and my army, as one, will never be defeated!");
		}
		case 3:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: Together for Atlantis! As one and for all!");
		}
	}
}

void AlaxiosSayWordsAngry()
{
	RaidModeTime += 30.0;
	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}FOR THE PEOPLE!!!!!!!!!!");
		}
		case 1:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}FOR ALL THAT IS FORSAKEN!!!!!!!");
		}
		case 2:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}FOR THE FUTURE!!!!!!!");
		}
		case 3:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: {crimson}FOR ATLANTIS!!!!!!!!!");
		}
	}
}


bool AlaxiosForceTalk()
{
	if(i_TalkDelayCheck == 5)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 7.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				CPrintToChatAll("{lightblue}God Alaxios{default}: Since you refuse to listen, I will have to restrain you.");
				i_TalkDelayCheck += 1;
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: I am not your enemy and I can revive all my allies, so do not worry.");
				i_TalkDelayCheck += 1;
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: The true enemy is the {blue}sea{default}, if we don't beat them, then were done for. They can infect any one of us.");
				i_TalkDelayCheck += 1;
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}God Alaxios{default}: I will hand you a bit of help as youre proven to be a strong foe.");
				i_TalkDelayCheck = 5;
				for (int client = 0; client < MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
					{
						Items_GiveNamedItem(client, "Alaxios's Godly assistance");
						CPrintToChat(client, "{default}You feel something around you... and gained: {lightblue}''Alaxios's Godly assistance''{default}!");
					}
				}
			}
		}
	}
	return false;
}
public void Raidmode_Alaxios_Win(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	switch(GetRandomInt(0,3))
	{
		case 0:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: Atlantis will never fall!");
		}
		case 1:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: I still have to take care of the {blue}deep sea{default}...");
		}
		case 2:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: Threaten our livelyhood and you pay!");
		}
		case 3:
		{
			CPrintToChatAll("{lightblue}God Alaxios{default}: I have to inform {blue}Sensal{default} about this.");
		}
	}
}