#pragma semicolon 1
#pragma newdecls required


static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav",
};

static char g_HurtSounds[][] = {
	")vo/medic_painsharp01.mp3",
	")vo/medic_painsharp02.mp3",
	")vo/medic_painsharp03.mp3",
	")vo/medic_painsharp04.mp3",
	")vo/medic_painsharp05.mp3",
	")vo/medic_painsharp06.mp3",
	")vo/medic_painsharp07.mp3",
	")vo/medic_painsharp08.mp3",
};

static char g_IdleSounds[][] = {
	")vo/null.mp3",
};

static char g_IdleAlertedSounds[][] = {
	")vo/medic_battlecry01.mp3",
	")vo/medic_battlecry02.mp3",
	")vo/medic_battlecry03.mp3",
	")vo/medic_battlecry04.mp3",
};

static char g_MeleeHitSounds[][] = {
	"weapons/breadmonster/throwable/bm_throwable_smash.wav",
};

static char g_MeleeAttackSounds[][] = {
	")weapons/knife_swing.wav",
};

static char g_RangedAttackSounds[][] = {
	"npc/combine_gunship/gunship_ping_search.wav",
};
static char g_TeleportSounds[][] = {
	"mvm/mvm_tank_end.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_item_secop_domination01.mp3",
};

static char g_AngerSoundsPassed[][] = {
	")vo/medic_laughlong01.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

#define LINKBEAM "sprites/glow01.vmt"
#define PILLAR_MODEL "models/props_wasteland/rockcliff06d.mdl"
#define PILLAR_SPACING 170.0

int Silvester_BEAM_Laser_1;
static int i_InKame[MAXENTITIES];
static bool b_RageAnimated[MAXENTITIES];

static float f_TalkDelayCheck;
static int i_TalkDelayCheck;
static int i_SadText;
static int i_ColoursTEPillars[4];
bool AlreadySaidWin;
bool AlreadySaidLastmann;

static int Silvester_TE_Used;

void ResetTEStatusSilvester()
{
	Silvester_TE_Used = 0;
}
void SetSilvesterPillarColour(int colours[4])
{
	i_ColoursTEPillars = colours;
}

public void RaidbossSilvester_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Silvester");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_raidboss_silvester");
	strcopy(data.Icon, sizeof(data.Icon), "silvester_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = Silvester_TBB_Precahce;
	NPC_Add(data);
	PrecacheSound("weapons/mortar/mortar_explode3.wav", true);
	PrecacheSound("mvm/mvm_tele_deliver.wav", true);
	PrecacheSound("player/flow.wav");
	PrecacheModel(LINKBEAM);
	PrecacheModel(PILLAR_MODEL);

	Silvester_BEAM_Laser_1 = PrecacheModel("materials/cable/blue.vmt", false);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
}



void Silvester_TBB_Precahce()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));       i++) { PrecacheSound(g_DeathSounds[i]);       }
	for (int i = 0; i < (sizeof(g_HurtSounds));        i++) { PrecacheSound(g_HurtSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleSounds));        i++) { PrecacheSound(g_IdleSounds[i]);        }
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));    i++) { PrecacheSound(g_MeleeHitSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));    i++) { PrecacheSound(g_MeleeAttackSounds[i]);    }
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSounds));   i++) { PrecacheSound(g_AngerSounds[i]);   }
	for (int i = 0; i < (sizeof(g_AngerSoundsPassed));   i++) { PrecacheSound(g_AngerSoundsPassed[i]);   }
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	PrecacheSoundArray(g_DefaultLaserLaunchSound);
	
	PrecacheSoundCustom("#zombiesurvival/silvester_raid/silvester_waldch_duo.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return RaidbossSilvester(vecPos, vecAng, team, data);
}
#define EMPOWER_SOUND "items/powerup_pickup_king.wav"
#define EMPOWER_MATERIAL "materials/sprites/laserbeam.vmt"
#define EMPOWER_WIDTH 5.0
#define EMPOWER_HIGHT_OFFSET 20.0
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static int i_RaidDuoAllyIndex;

methodmap RaidbossSilvester < CClotBody
{
	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_BEAM_RechargeTime[this.index]; }
		public set(float TempValueForProperty) 	{ fl_BEAM_RechargeTime[this.index] = TempValueForProperty; }
	}
	property int m_iInKame
	{
		public get()							{ return i_InKame[this.index]; }
		public set(int TempValueForProperty) 	{ i_InKame[this.index] = TempValueForProperty; }
	}

	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
	
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	public void PlayAngerSoundPassed() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSoundsPassed) - 1);
		EmitSoundToAll(g_AngerSoundsPassed[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("mvm/mvm_tele_deliver.wav", this.index, SNDCHAN_STATIC, 80, _, 0.8);
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		
	}
	public void PlayLaserLaunchSound() {
		int chose = GetRandomInt(0, sizeof(g_DefaultLaserLaunchSound)-1);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_DefaultLaserLaunchSound[chose], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public RaidbossSilvester(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		RaidbossSilvester npc = view_as<RaidbossSilvester>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		AlreadySaidWin = false;
		AlreadySaidLastmann = false;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Shared_Xeno_Duo);
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
		i_TimesSummoned[npc.index] = 0;

		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Silvester And Waldch Arrived.");
			}
		}
		RemoveAllDamageAddition();
		bool final = StrContains(data, "final_item") != -1;
		
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
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

		if(final)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 6;
		}
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;
		SetEntPropFloat(npc.index, Prop_Data, "m_flElementRes", 1.0, Element_Chaos);
		i_SadText = false;
		npc.m_bDissapearOnDeath = true;
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
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

		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		
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

		f_ExplodeDamageVulnerabilityNpc[npc.index] = 0.7;
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
	
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, RaidbossSilvester_OnTakeDamagePost);
		b_angered_twice[npc.index] = false;
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		/*
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		*/
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", 1);

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);


		npc.m_iWearable7 = npc.EquipItem("head","models/workshop/player/items/medic/cardiologists_camo/cardiologists_camo.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", 1);

		
		float flPos[3]; // original
		float flAng[3]; // original
		npc.GetAttachment("head", flPos, flAng);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});
		
		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable3, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable4, 192, 192, 192, 255);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);


		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		bool ingoremusic = StrContains(data, "triple_enemies") != -1;
		
		if(!ingoremusic)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/silvester_raid/silvester_waldch_duo.mp3");
			music.Time = 260;
			music.Volume = 1.6;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "The Duo that Warns in inconspicuous Ways");
			strcopy(music.Artist, sizeof(music.Artist), "Grandpa Bard");
			Music_SetRaidMusic(music);
		}
		else
		{
			RaidModeTime = GetGameTime(npc.index) + 450.0;
		}
		
		npc.Anger = false;
		//IDLE
		npc.m_flSpeed = 330.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;

		npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
		npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;		
		Citizen_MiniBossSpawn();
		npc.StartPathing();

		
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 20.0;
		npc.m_iInKame = 0;


		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		
		RequestFrame(Silvester_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		npc.m_flNextDelayTime = GetGameTime() + 0.2;
		if(XenoExtraLogic())
		{
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					CPrintToChatAll("{gold}실베스터{default}: 정말로 이렇게까지 해야 우리 경고를 들어먹겠어?");
				}
				case 2:
				{
					CPrintToChatAll("{gold}실베스터{default}: 제발 그냥 돌아가!");
				}
				case 3:
				{
					CPrintToChatAll("{gold}실베스터{default}: 이건 너무 위험한 일이라고!");
				}
			}
		}
		SilvesterApplyEffects(npc.index, false);
		return npc;
	}
}


static void Internal_ClotThink(int iNPC)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(iNPC);
	
	//Raidmode timer runs out, they lost.
	if(LastMann && !AlreadySaidLastmann)
	{
		if(!npc.m_fbGunout)
		{
			AlreadySaidLastmann = true;
			npc.m_fbGunout = true;
			if(!XenoExtraLogic())
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{gold}실베스터{default}: 포기하고 자수해.");
					}
					case 1:
					{
						CPrintToChatAll("{gold}실베스터{default}: 이제 우리 말을 들어줄 준비는 됐어?");
					}
					case 2:
					{
						CPrintToChatAll("{gold}실베스터{default}: 뭐야, 아니면 우릴 그냥 싫어하는거야?");
					}
				}
			}
			else
			{
				switch(GetRandomInt(0,2))
				{
					case 0:
					{
						CPrintToChatAll("{gold}실베스터{default}: 널 죽여서라도 여기에서 끌고 나가겠어!");
					}
					case 1:
					{
						CPrintToChatAll("{gold}실베스터{default}: 말을 안 듣는걸 보니 이미 감염된 상태인게 분명해! 그럼 안타깝지만 죽어야지!");
					}
					case 2:
					{
						CPrintToChatAll("{gold}실베스터{default}: 남의 말 좀 듣는게 그렇게나 힘든 일인거야?");
					}
				}				
			}
		}
	}
	if(RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (10 * 2);
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		SharedTimeLossSilvesterDuo(npc.index);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	if(b_angered_twice[npc.index])
	{
		int closestTarget = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(closestTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
		npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
		int ally = EntRefToEntIndex(i_RaidDuoAllyIndex);
		npc.StopPathing();
		SilvesterApplyEffects(npc.index, true);
		if(SharedGiveupSilvester(npc.index,ally))
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}

	//Think throttling
	
	
	if(!npc.m_flNextChargeSpecialAttack)
	{
		if(npc.m_blPlayHurtAnimation)
		{
			npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
			npc.PlayHurtSound();
			npc.m_blPlayHurtAnimation = false;
		}
	}
	
	if(npc.Anger)
	{
		if(!b_RageAnimated[npc.index])
		{
			npc.StopPathing();
			
			npc.m_flSpeed = 0.0;
			npc.m_bisWalking = false;
			npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
			npc.SetCycle(0.01);
			b_RageAnimated[npc.index] = true;
			b_CannotBeHeadshot[npc.index] = true;
			b_CannotBeBackstabbed[npc.index] = true;
			ApplyStatusEffect(npc.index, npc.index, "Clear Head", 999999.0);	
			ApplyStatusEffect(npc.index, npc.index, "Solid Stance", 999999.0);		
			ApplyStatusEffect(npc.index, npc.index, "Fluid Movement", 999999.0);	
		}
	}


	if(npc.m_flNextChargeSpecialAttack)
	{
		if(npc.m_flNextChargeSpecialAttack < GetGameTime(npc.index))
		{
			b_CannotBeHeadshot[npc.index] = false;
			b_CannotBeBackstabbed[npc.index] = false;
			RemoveSpecificBuff(npc.index, "Clear Head");
			RemoveSpecificBuff(npc.index, "Solid Stance");
			RemoveSpecificBuff(npc.index, "Fluid Movement");
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
			npc.StartPathing();
			
			npc.m_flSpeed = 330.0;
			npc.m_iInKame = 0;
			npc.m_flNextChargeSpecialAttack = 0.0;
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.5;
			npc.m_bisWalking = true;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			b_NpcIsInvulnerable[npc.index] = false; //Special huds for invul targets
			
			strcopy(c_NpcName[npc.index], sizeof(c_NpcName[]), "Angeled Silvester");
			i_NpcWeight[npc.index] = 4;

			SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) / 2));
			SilvesterApplyEffects(npc.index, false);

			int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
			if(IsEntityAlive(AllyEntity) && !IsPartnerGivingUpGoggles(AllyEntity))
			{
				switch(GetRandomInt(1,3))
				{
					case 1:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 이리 와!");
						else
							CPrintToChatAll("{gold}실베스터{default}: 이 곳에서 당장 나가!");
					}
					case 2:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 덤벼봐!");
						else
							CPrintToChatAll("{gold}Silvester{default}: 우린 또 감염당할 수는 없어!");
					}
					case 3:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 이제 진짜배기 싸움이다!");
						else
							CPrintToChatAll("{gold}실베스터{default}: 여긴 최고로 위험한 장소라고! 들어가서는 안 돼!");
					}
				}
			}
			else
			{
				switch(GetRandomInt(1,3))
				{
					case 1:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 이제 끝이다!");
						else
							CPrintToChatAll("{gold}실베스터{default}: 이 곳의 그 놈들은 그 어떤 상식도 통하지 않아..");
					}
					case 2:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 내 말을 안 듣겠다면, 그것들처럼 변이되기 전에 내가 처리해주지!");
						else
							CPrintToChatAll("{gold}실베스터{default}: 너무 많은 자들이 그것들 때문에 죽어나갔어!");
					}
					case 3:
					{
						if(!XenoExtraLogic())
							CPrintToChatAll("{gold}실베스터{default}: 전부 지옥에나 가라!");
						else
							CPrintToChatAll("{gold}실베스터{default}: ...");
					}
				}
			}

				
			SetVariantColor(view_as<int>({255, 255, 0, 200}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			npc.PlayAngerSoundPassed();


			npc.m_flTimebeforekamehameha = 0.0;
			npc.m_flNextRangedSpecialAttack = 0.0;			
			npc.m_flNextRangedAttack = 0.0;		
			npc.m_flRangedSpecialDelay = 0.0;		
			//Reset all cooldowns.
		}
		return;
	}
	if(f_TargetToWalkToDelay[npc.index] < GetGameTime(npc.index))
	{
		if(npc.m_iInKame == 2)
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(IsValidEntity(npc.m_iTargetWalkTo))
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
		}
		else
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		}
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	if(npc.m_iInKame == 2)
	{
		if(IsValidEntity(npc.m_iTargetWalkTo))
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
			npc.FaceTowards(vecTarget, 80.0);
		}
		npc.StopPathing();
		
		npc.m_flSpeed = 0.0;
		npc.m_flDoingAnimation = GetGameTime() + 0.1;
	}
	else if(npc.m_iInKame == 1)
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		npc.StartPathing();
		
		npc.m_flSpeed = 330.0;
		npc.m_iInKame = 0;
		SilvesterApplyEffects(npc.index, false);
	}
	if(npc.m_iInKame > 0 && !NpcStats_IsEnemySilenced(npc.index))
	{
		if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.3;
			npc.m_flMeleeArmor = 0.375;
		}	
		else
		{
			npc.m_flRangedArmor = 0.7;
			npc.m_flMeleeArmor = 0.875;			
		}
	}
	else
	{
		if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.45;
			npc.m_flMeleeArmor = 0.5625;
		}	
		else
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;			
		}	
	}
	if(npc.m_flReloadDelay && npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		npc.StartPathing();
		
		npc.m_flSpeed = 330.0;
		npc.m_iInKame = 0;
		npc.m_flReloadDelay = 0.0;
		npc.m_bisWalking = true;
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		SilvesterApplyEffects(npc.index, false);
	}
	if(npc.m_flDoingSpecial && npc.m_flDoingSpecial < GetGameTime(npc.index))
	{
		npc.SetPlaybackRate(0.0);	//freeze in place.
		npc.m_flDoingSpecial = 0.0;
		SilvesterApplyEffects(npc.index, true);
	}


	//link up to ally and take dmg from them.
	int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
	if(IsEntityAlive(AllyEntity) && !IsPartnerGivingUpGoggles(AllyEntity))
	{
		static float victimPos[3];
		static float partnerPos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
		GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
		float Distance = GetVectorDistance(victimPos, partnerPos, true);
		if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 20.0) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
		{	
			if(!IsValidEntity(i_LaserEntityIndex[npc.index]))
			{
				int red = 0;
				int green = 255;
				int blue = 0;

				if(Goggles_TookDamageRecently(AllyEntity))
				{
					red = 255;
					green = 0;
					blue = 0;
				}
				if(IsValidEntity(i_LaserEntityIndex[npc.index]))
				{
					RemoveEntity(i_LaserEntityIndex[npc.index]);
				}

				int laser;
				RaidbossBlueGoggles allynpc = view_as<RaidbossBlueGoggles>(AllyEntity);

				laser = ConnectWithBeam(npc.m_iWearable6, allynpc.m_iWearable6, red, green, blue, 5.0, 5.0, 0.0, LINKBEAM);
				
				i_LaserEntityIndex[npc.index] = EntIndexToEntRef(laser);
			}
			else
			{
				int laserentity = EntRefToEntIndex(i_LaserEntityIndex[npc.index]);
				if(Goggles_TookDamageRecently(AllyEntity))
				{
					SetEntityRenderColor(laserentity, 255, 0, 0, 255);
				}
				else
				{
					SetEntityRenderColor(laserentity, 0, 255, 0, 255);
				}
			}
		}
		else
		{
			if(IsValidEntity(i_LaserEntityIndex[npc.index]))
			{
				RemoveEntity(i_LaserEntityIndex[npc.index]);
			}
		}
	}
	else
	{
		if(!i_SadText)
		{
			i_SadText = true;
			switch(GetRandomInt(1,3))
			{
				case 1:
				{
					if(!XenoExtraLogic())
						CPrintToChatAll("{gold}실베스터{default}: 아, 안 돼!!");
					else
						CPrintToChatAll("{gold}실베스터{default}: {darkblue}월드치{default}..?");
				}
				case 2:
				{
					if(!XenoExtraLogic())
						CPrintToChatAll("{gold}실베스터{default}: 쟤 말고 나를 공격하라고!");
					else
						CPrintToChatAll("{gold}실베스터{default}: 괜찮아, 나 여깄어, 여깄다고!");
				}
				case 3:
				{
					if(!XenoExtraLogic())
						CPrintToChatAll("{gold}실베스터{default}: 좀만 쉬어. 내가 처리할게.");
					else
						CPrintToChatAll("{gold}실베스터{default}: 내가 이걸 그냥 넘어갈거라고 생각하지마..");
				}
			}
		}
		if(IsValidEntity(i_LaserEntityIndex[npc.index]))
		{
			RemoveEntity(i_LaserEntityIndex[npc.index]);
		}
		AllyEntity = -1;
	}

	if(npc.m_iInKame == 3)
	{
		if(AllyEntity != -1 && !IsPartnerGivingUpGoggles(AllyEntity))
		{
			npc.m_iTargetWalkTo = AllyEntity;
			npc.m_flSpeed = 330.0;
		}
	}
	if(npc.m_flNextRangedSpecialAttackHappens && npc.m_flNextRangedSpecialAttackHappens != 1.0)
	{
		if(AllyEntity != -1 && !b_NoGravity[AllyEntity] && !IsPartnerGivingUpGoggles(AllyEntity))
		{
			npc.m_iTargetWalkTo = AllyEntity;
			npc.m_flSpeed = 500.0;
		}
		else
		{
			npc.m_flSpeed = 250.0;
		}

		spawnRing(npc.index, NORMAL_ENEMY_MELEE_RANGE_FLOAT * 3.0 * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 10, 0.11, EMPOWER_WIDTH, 6.0, 10);
		
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
				{
					if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						int red = 212;
						int green = 155;
						int blue = 0;
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}

						int laser;
						
						laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
			
						i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
						//Im seeing a new target, relocate laser particle.
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
		

		if(npc.m_flNextRangedSpecialAttackHappens < GetGameTime(npc.index))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
			npc.PlayPullSound();
			npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
			npc.m_flNextRangedSpecialAttackHappens = 1.0;
			static float victimPos[3];
			static float partnerPos[3];
			GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
			for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}	

				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
					{
						GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", victimPos); 
						float Distance = GetVectorDistance(victimPos, partnerPos);
						if(Distance > NORMAL_ENEMY_MELEE_RANGE_FLOAT * 3.0) //they are further away, pull them.
						{				
							static float angles[3];
							GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								angles[0] = 0.0; // toss out pitch if on ground

							static float velocity[3];
							GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
							float attraction_intencity = 2.5;
							ScaleVector(velocity, Distance * attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);       
						}
						else //they are too close, push them.
						{
							static float angles[3];
							GetVectorAnglesTwoPoints(victimPos, partnerPos, angles);

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
		}
	}
	else if(npc.m_flNextRangedSpecialAttackHappens == 1.0)
	{
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		npc.m_flSpeed = 330.0;
	}
	if(IsEntityAlive(npc.m_iTargetWalkTo))
	{
		int ActionToTake = -1;

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

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch >= 0)
		{

			//Body pitch
			float v[3], ang[3];
			SubtractVectors(VecSelfNpc, vecTarget, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
					
			float flPitch = npc.GetPoseParameter(iPitch);
					
			//	ang[0] = clamp(ang[0], -44.0, 89.0);
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}
			

		if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(npc.m_iInKame == 3)
		{
			ActionToTake = 3;
		}
		else if(npc.m_iInKame > 0)
		{
			ActionToTake = -1;
		}
		else if(flDistanceToTarget < (1000.0 * 1000.0) && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
			float flPos[3]; // original
			float flAng[3]; // original
			GetAttachment(npc.index, "effect_hand_l", flPos, flAng);
			int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 0.25);
			SetParent(npc.index, particler, "effect_hand_l");
			npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 5.0;
			npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 35.0;
			//pull or push the target away!
			ActionToTake = 1;
		}
		else if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo))
		{
			if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index))
			{
				ActionToTake = 2;
			}
			else if(flDistanceToTarget < (1000.0 * 1000.0) && npc.m_flNextRangedAttack < GetGameTime(npc.index))
			{
				ActionToTake = 4;
			}
			else if(flDistanceToTarget < (750.0 * 750.0) && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				ActionToTake = 5;
			}
		}
		else
		{
			ActionToTake = 0;
		}




		switch(ActionToTake)
		{
			case 2:
			{
				npc.m_iInKame = 3;
			}
			case 3:
			{
				if(AllyEntity != -1 && !IsPartnerGivingUpGoggles(AllyEntity))
				{
					static float victimPos[3];
					static float partnerPos[3];
					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
					GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
					float Distance = GetVectorDistance(victimPos, partnerPos, true);
					if(Distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 5.0) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
					{	
						npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + (npc.Anger ? 40.0 : 50.0);
						npc.m_flDoingSpecial = GetGameTime(npc.index) + 2.5;
						Silvester_TBB_Ability(npc.index);
						npc.m_iInKame = 2;
						npc.m_bisWalking = false;
						npc.AddActivityViaSequence("taunt_doctors_defibrillators");
					//	npc.AddGesture("ACT_MP_RUN_MELEE");
						npc.SetPlaybackRate(0.5);	
						npc.SetCycle(0.15);
						SilvesterApplyEffects(npc.index, true);
					}
				}
				else
				{
					npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + (npc.Anger ? 40.0 : 50.0);
					npc.m_flDoingSpecial = GetGameTime(npc.index) + 2.5;
					Silvester_TBB_Ability(npc.index);
					npc.m_iInKame = 2;
					npc.m_bisWalking = false;
					npc.AddActivityViaSequence("taunt_doctors_defibrillators");
					//npc.AddGesture("ACT_MP_RUN_MELEE");
					npc.SetPlaybackRate(0.5);	
					npc.SetCycle(0.15);
					SilvesterApplyEffects(npc.index, true);
				}
			}
			case 4: //Cause a pillar attack, more fany and better looking elemental wand attack
			{
		//		npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 0.5;
		//		npc.StopPathing();
		//		
		//		npc.m_flSpeed = 0.0;
				npc.FaceTowards(vecTarget, 99999.9);
				float pos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				pos[2] += 5.0;
				float ang_Look[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang_Look);

				float DelayPillars = 1.5;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.25;
				float DelaybewteenPillars = 0.2;
				if(i_RaidGrantExtra[npc.index] >= 4)
				{
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 0.25;
					DelayPillars = 1.0;
					DelaybewteenPillars = 0.1;
				}
				npc.AddGesture("ACT_MP_THROW");
				npc.PlayRangedSound();
				int MaxCount = RoundToNearest(1.0 * RaidModeScaling);
				if(MaxCount < 1)
				{
					MaxCount = 1;
				}
				Silvester_TE_Used = 0;
				SetSilvesterPillarColour({212, 150, 0, 200});
				if(i_RaidGrantExtra[npc.index] >= 5 && i_TimesSummoned[npc.index] >= 3)
				{
					i_TimesSummoned[npc.index] = 0;
					ang_Look[1] -= 30.0;
					for(int Repeat; Repeat <= 1; Repeat++)
					{
						Silvester_Damaging_Pillars_Ability(npc.index,
						10.0 * RaidModeScaling,				 	//damage
						MaxCount, 	//how many
						DelayPillars,									//Delay untill hit
						DelaybewteenPillars,									//Extra delay between each
						ang_Look 								/*2 dimensional plane*/,
						pos,
						0.25,
						0.5);
						if(Repeat == 0)
							ang_Look[1] += 60.0;
					}	
					ang_Look[1] -= 30.0;
				}

				i_TimesSummoned[npc.index] += 1;
				Silvester_Damaging_Pillars_Ability(npc.index,
				25.0 * RaidModeScaling,				 	//damage
				MaxCount, 	//how many
				DelayPillars,									//Delay untill hit
				DelaybewteenPillars,									//Extra delay between each
				ang_Look 								/*2 dimensional plane*/,
				pos);					

				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
				if(npc.Anger)
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 2.5;
				}
			}
			case 5: //Cause a pillar attack, more fany and better looking elemental wand attack
			{
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 3.0;
				npc.m_flReloadDelay = GetGameTime(npc.index) + 3.0;
				npc.StopPathing();
				
				npc.m_flSpeed = 0.0;
				float pos[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				pos[2] += 5.0;

				float DelayPillars = 3.0;
				float DelaybewteenPillars = 0.2;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("taunt_the_fist_bump");
				npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
				npc.SetPlaybackRate(0.5);
				if(i_RaidGrantExtra[npc.index] >= 3)
				{
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5;
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.5;
					DelayPillars = 2.5;
					DelaybewteenPillars = 0.1;
					int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
					for(int i; i < layerCount; i++)
					{
						view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 1.15);
					}
					npc.SetPlaybackRate(0.6);
				}
				if(i_RaidGrantExtra[npc.index] >= 5)
				{
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0;
					npc.m_flReloadDelay = GetGameTime(npc.index) + 2.0;
					DelayPillars = 2.0;
					DelaybewteenPillars = 0.1;
					int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
					for(int i; i < layerCount; i++)
					{
						view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 1.35);
					}
					npc.SetPlaybackRate(1.35);
				}
				npc.SetCycle(0.05);
				npc.m_bisWalking = false;
				npc.PlayTeleportSound();
				float ang_Look[3];
				ang_Look[1] = -180.0;
				float flPos[3]; // original
				float flAng[3]; // original
				GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
				int particler = ParticleEffectAt(flPos, "raygun_projectile_blue_crit", 2.0);
				SetParent(npc.index, particler, "effect_hand_r");

				int MaxCount = RoundToNearest(0.5 * RaidModeScaling);

				if(MaxCount > 15)
				{
					MaxCount = 15;
				}
				else if(MaxCount < 1)
				{
					MaxCount = 1;
				}
				
				Silvester_TE_Used = 0;
				SetSilvesterPillarColour({212, 150, 0, 200});
				for(int Repeat; Repeat <= 7; Repeat++)
				{
					Silvester_Damaging_Pillars_Ability(npc.index,
					25.0 * RaidModeScaling,				 	//damage
					MaxCount, 	//how many
					DelayPillars,									//Delay untill hit
					DelaybewteenPillars,									//Extra delay between each
					ang_Look 								/*2 dimensional plane*/,
					pos,
					0.25);									//volume
					ang_Look[1] += 45.0;
				}
				
				npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 25.0;
				if(npc.Anger)
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 20.0;
				}
				SilvesterApplyEffects(npc.index, true);
			}
			default:
			{
	//			return;
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	//This is for self defense, incase an enemy is too close, This exists beacuse
	//Silvester's main walking target might not be the closest target he has.
	if((npc.m_iInKame == 0 || npc.m_iInKame == 3) && npc.m_flDoingAnimation < GetGameTime(npc.index))
	{
		RaidbossSilvesterSelfDefense(npc,GetGameTime(npc.index)); 
	}
}

	
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	RaidbossSilvester npc = view_as<RaidbossSilvester>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	Internal_Weapon_Lines(npc, attacker);

	if(!b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(damage >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SilvesterApplyEffects(npc.index, true);
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
			GiveProgressDelay(28.0);
			damage = 0.0;
			CPrintToChatAll("{gold}실베스터{default}: 우리 경고는 죽어도 안 듣는구만!?");
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}


public void RaidbossSilvester_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(victim);
	if(i_RaidGrantExtra[npc.index] >= 4)
	{
		if((ReturnEntityMaxHealth(npc.index)/4) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
		{
			SilvesterApplyEffects(npc.index, true);
			if(IsValidEntity(i_LaserEntityIndex[npc.index]))
			{
				RemoveEntity(i_LaserEntityIndex[npc.index]);
			}
			npc.m_flNextChargeSpecialAttack = GetGameTime(npc.index) + 6.0;
			b_NpcIsInvulnerable[npc.index] = true; //Special huds for invul targets
			npc.PlayAngerSound();
			npc.Anger = true; //	>:(
			b_RageAnimated[npc.index] = false;
			RaidModeTime += 60.0;
			int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
			if(IsEntityAlive(AllyEntity) && !IsPartnerGivingUpGoggles(AllyEntity))
			{
				switch(GetRandomInt(1,3))
				{
					case 1:
					{
						CPrintToChatAll("{gold}실베스터{default}: 이게 끝인줄 알아?");
					}
					case 2:
					{
						CPrintToChatAll("{gold}실베스터{default}: 넌 지금 어떤 일이 벌어질지도 모르잖아...");
					}
					case 3:
					{
						CPrintToChatAll("{gold}실베스터{default}: 이걸로 끝이 아니야..");
					}
				}
			}
			else
			{
				switch(GetRandomInt(1,3))
				{
					case 1:
					{
						CPrintToChatAll("{gold}실베스터{default}: 넌 지금 오만함에 눈이 멀었어!");
					}
					case 2:
					{
						CPrintToChatAll("{gold}실베스터{default}: 나 혼자 있다고 얕보고 있는거야?!");
					}
					case 3:
					{
						CPrintToChatAll("{gold}실베스터{default}: 넌 우리 경고를 무시했으니, 그 대가를 치뤄야지!");
					}
				}
			}
			
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			pos[2] += 5.0;
			ParticleEffectAt(pos, "utaunt_electricity_cloud1_WY", 5.5);
		}
	}
}

static void Internal_NPCDeath(int entity)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamagePost, RaidbossSilvester_OnTakeDamagePost);
	StopSound(entity, SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	ExpidonsaRemoveEffects(entity);
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.

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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}		
		if(IsValidClient(EnemyLoop))
		{
			ResetDamageHud(EnemyLoop);//show nothing so the damage hud goes away so the other raid can take priority faster.
		}				
	}
	Citizen_MiniBossDeath(entity);
}

void RaidbossSilvesterSelfDefense(RaidbossSilvester npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
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
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.m_iTarget, WorldSpaceVec);
				npc.FaceTowards(WorldSpaceVec, 20000.0);
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
							float damage = 24.0;
							float damage_rage = 28.0;

							if(!npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);
									
							if(npc.Anger)
								SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);									
								
							
							// Hit particle
							
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
								Custom_Knockback(npc.index, target, 450.0, true); 
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

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 1.2;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

void Silvester_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
			
		maxhealth -= (maxhealth / 4);

		int spawn_index = NPC_CreateByName("npc_infected_goggles", -1, pos, ang, GetTeam(entity));
		if(spawn_index > MaxClients)
		{
			NpcStats_CopyStats(entity, spawn_index);
			i_RaidGrantExtra[spawn_index] = i_RaidGrantExtra[entity];
			if(i_RaidGrantExtra[spawn_index] == 6)
			{
				b_NpcUnableToDie[spawn_index] = true;
			}
			i_RaidDuoAllyIndex = EntIndexToEntRef(spawn_index);
			Goggles_SetRaidPartner(entity);
			NpcAddedToZombiesLeftCurrently(spawn_index, true);
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

void Silvester_Damaging_Pillars_Ability(int entity,
float damage,
int count,
float delay,
float delay_PerPillar,
float direction[3] /*2 dimensional plane*/,
float origin[3],
float volume = 0.7,
float extra_pillar_size = 1.0)
{
	float timerdelay = GetGameTime() + delay;
	DataPack pack;
	CreateDataTimer(delay_PerPillar, Silvester_DamagingPillar, pack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	pack.WriteCell(EntIndexToEntRef(entity)); 	//who this attack belongs to
	pack.WriteCell(damage);
	pack.WriteCell(0);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(count);						//how many pillars, this counts down with each pillar made
	pack.WriteCell(timerdelay);					//Delay for each initial pillar
	pack.WriteCell(direction[0]);
	pack.WriteCell(direction[1]);
	pack.WriteCell(direction[2]);
	pack.WriteCell(origin[0]);
	pack.WriteCell(origin[1]);
	pack.WriteCell(origin[2]);
	pack.WriteCell(volume);
	pack.WriteCell(extra_pillar_size);

	float origin_altered[3];
	origin_altered = origin;
	bool DontClipOrMove = false;
	if(count == 0)
	{
		DontClipOrMove = true;
		count = 1;
	}
	for(int Repeats; Repeats < count; Repeats++)
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin_altered[0] + VecForward[0] * (PILLAR_SPACING * extra_pillar_size);
		vecSwingEnd[1] = origin_altered[1] + VecForward[1] * (PILLAR_SPACING * extra_pillar_size);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/

		origin_altered = vecSwingEnd;
		if(DontClipOrMove)
			origin_altered = origin;

		//Clip to ground, its like stepping on stairs, but for these rocks.

		Silvester_ClipPillarToGround({24.0,24.0,24.0}, 300.0, origin_altered);
		float Range = 100.0;
		Range *= extra_pillar_size;

		Range += (float(Repeats) * 10.0);
		Range += 10.0;
		Silvester_TE_Used += 1;
		if(Silvester_TE_Used > 31)
		{
			int DelayFrames = (Silvester_TE_Used / 32);
			DelayFrames *= 2;
			DataPack pack_TE = new DataPack();
			pack_TE.WriteCell(origin_altered[0]);
			pack_TE.WriteCell(origin_altered[1]);
			pack_TE.WriteCell(origin_altered[2]);
			pack_TE.WriteCell(Range);
			pack_TE.WriteCell(delay + (delay_PerPillar * float(Repeats)));
			RequestFrames(Silvester_DelayTE, DelayFrames, pack_TE);
			//Game cannot send more then 31 te's in the same frame, a fix is too just delay it.
		}
		else
		{
			spawnRing_Vectors(origin_altered, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", i_ColoursTEPillars[0], i_ColoursTEPillars[1], i_ColoursTEPillars[2], i_ColoursTEPillars[3], 1, delay + (delay_PerPillar * float(Repeats)), 5.0, 0.0, 1);	
		}
	}
}

void Silvester_ClipPillarToGround(float vecHull[3], float StepHeight, float vecorigin[3])
{
	float originalPostionTrace[3];
	float startPostionTrace[3];
	float endPostionTrace[3];
	endPostionTrace = vecorigin;
	startPostionTrace = vecorigin;
	originalPostionTrace = vecorigin;
	startPostionTrace[2] += StepHeight;
	endPostionTrace[2] -= 5000.0;

	float vecHullMins[3];
	vecHullMins = vecHull;

	vecHullMins[0] *= -1.0;
	vecHullMins[1] *= -1.0;
	vecHullMins[2] *= -1.0;

	Handle trace;
	trace = TR_TraceHullFilterEx( startPostionTrace, endPostionTrace, vecHullMins, vecHull, MASK_NPCSOLID,HitOnlyWorld, 0);
	if ( TR_GetFraction(trace) < 1.0)
	{
		// This is the point on the actual surface (the hull could have hit space)
		TR_GetEndPosition(vecorigin, trace);	
	}
	vecorigin[0] = originalPostionTrace[0];
	vecorigin[1] = originalPostionTrace[1];

	float VecCalc = (vecorigin[2] - startPostionTrace[2]);
	if(VecCalc > (StepHeight - (vecHull[2] + 2.0)) || VecCalc > (StepHeight - (vecHull[2] + 2.0)) ) //This means it was inside something, in this case, we take the normal non traced position.
	{
		vecorigin[2] = originalPostionTrace[2];
	}

	delete trace;
	//if it doesnt hit anything, then it just does buisness as usual
}
			
public void Silvester_DelayTE(DataPack pack)
{
	pack.Reset();
	float Origin[3];
	Origin[0] = pack.ReadCell();
	Origin[1] = pack.ReadCell();
	Origin[2] = pack.ReadCell();
	float Range = pack.ReadCell();
	float Delay = pack.ReadCell();
	spawnRing_Vectors(Origin, Range * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", i_ColoursTEPillars[0], i_ColoursTEPillars[1], i_ColoursTEPillars[2], i_ColoursTEPillars[3], 1, Delay, 5.0, 0.0, 1);	
		
	delete pack;
}

public Action Silvester_DamagingPillar(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	float damage = pack.ReadCell();
	DataPackPos countPos = pack.Position;
	int count = pack.ReadCell();
	int countMax = pack.ReadCell();
	float delayUntillImpact = pack.ReadCell();
	float direction[3];
	direction[0] = pack.ReadCell();
	direction[1] = pack.ReadCell();
	direction[2] = pack.ReadCell();
	float origin[3];
	DataPackPos originPos = pack.Position;
	origin[0] = pack.ReadCell();
	origin[1] = pack.ReadCell();
	origin[2] = pack.ReadCell();
	float volume = pack.ReadCell();
	float PillarSizeEdit = pack.ReadCell();

	//Timers have a 0.1 impresicison logic, accont for it.
	if(delayUntillImpact - 0.1 > GetGameTime())
	{
		return Plugin_Continue;
	}
	bool DontClipOrMove = false;
	if(countMax == 0)
	{
		DontClipOrMove = true;
	}

	count += 1;
	pack.Position = countPos;
	pack.WriteCell(count, false);
	if(IsValidEntity(entity))
	{
		float VecForward[3];
		float vecRight[3];
		float vecUp[3];
				
		GetAngleVectors(direction, VecForward, vecRight, vecUp);
		
		float vecSwingEnd[3];
		vecSwingEnd[0] = origin[0] + VecForward[0] * (PILLAR_SPACING * PillarSizeEdit);
		vecSwingEnd[1] = origin[1] + VecForward[1] * (PILLAR_SPACING * PillarSizeEdit);
		vecSwingEnd[2] = origin[2];/*+ VecForward[2] * (100);*/
		if(DontClipOrMove)
			vecSwingEnd = origin;

		Silvester_ClipPillarToGround({24.0,24.0,24.0}, 300.0, vecSwingEnd);


		
		int prop = CreateEntityByName("prop_physics_multiplayer");
		if(IsValidEntity(prop))
		{

			float vel[3];
			vel[2] = 750.0;
			float SpawnPropPos[3];
			float SpawnParticlePos[3];

			SpawnPropPos = vecSwingEnd;
			SpawnParticlePos = vecSwingEnd;

			SpawnPropPos[2] -= 250.0;
			SpawnParticlePos[2] += 5.0;

			DispatchKeyValue(prop, "model", PILLAR_MODEL);
			DispatchKeyValue(prop, "physicsmode", "2");
			DispatchKeyValue(prop, "solid", "0");
			DispatchKeyValue(prop, "massScale", "1.0");
			DispatchKeyValue(prop, "spawnflags", "6");


			float SizeScale = 0.9;
			SizeScale *= PillarSizeEdit; 

			SizeScale += (float(count -1) * 0.1);

			char FloatString[8];
			FloatToString(SizeScale, FloatString, sizeof(FloatString));

			DispatchKeyValue(prop, "modelscale", FloatString);
			DispatchKeyValueVector(prop, "origin",	 SpawnPropPos);
			direction[2] -= 180.0;
			direction[1] = GetRandomFloat(-180.0, 180.0);
			DispatchKeyValueVector(prop, "angles",	 direction);
			DispatchSpawn(prop);
			TeleportEntity(prop, NULL_VECTOR, NULL_VECTOR, vel);
			if(i_ColoursTEPillars[3] != 255)
				SetEntityRenderMode(prop, RENDER_TRANSCOLOR);
				
			SetEntityRenderColor(prop, i_ColoursTEPillars[0], i_ColoursTEPillars[1], i_ColoursTEPillars[2], i_ColoursTEPillars[3]);
			SetEntityCollisionGroup(prop, 1); //COLLISION_GROUP_DEBRIS_TRIGGER
			SetEntProp(prop, Prop_Send, "m_usSolidFlags", 12); 
			SetEntProp(prop, Prop_Data, "m_nSolidType", 6); 

			float Range = 100.0;
			Range *= PillarSizeEdit;

			Range += (float(count -1) * 10.0);
			Range += 10.0;
			
			makeexplosion(entity, SpawnParticlePos, RoundToCeil(damage), RoundToCeil(Range),_,_,false);
		
	//		InfoTargetParentAt(SpawnParticlePos, "medic_resist_fire", 1.0);
			if(volume == 0.25)
			{
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);		
			}
			else
			{
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
				EmitSoundToAll("weapons/mortar/mortar_explode3.wav", 0, SNDCHAN_AUTO, 100, SND_NOFLAGS, volume, SNDPITCH_NORMAL, -1, SpawnParticlePos);
			}
		
		//	spawnRing_Vectors(vecSwingEnd, Range * 2.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 255, 0, 0, 200, 1, 1.0, 12.0, 6.1, 1);
			spawnRing_Vectors(SpawnParticlePos, 0.0, 0.0, 0.0, 3.0, "materials/sprites/laserbeam.vmt", i_ColoursTEPillars[0], i_ColoursTEPillars[1], i_ColoursTEPillars[2], i_ColoursTEPillars[3], 1, 0.5, 12.0, 6.1, 1,Range * 2.0);

			CreateTimer(4.0, Timer_RemoveEntity, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		pack.Position = originPos;
		pack.WriteCell(vecSwingEnd[0], false);
		pack.WriteCell(vecSwingEnd[1], false);
		pack.WriteCell(origin[2], false);
		//override origin, we have a new origin.
	}
	else
	{
		return Plugin_Stop; //cancel.
	}

	if(count >= countMax)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


void Silvester_TBB_Ability(int client)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(client);
	float flPos[3]; // original
	float flAng[3]; // original
	GetAttachment(client, "effect_hand_r", flPos, flAng);
	int particlel = ParticleEffectAt(flPos, "eyeboss_death_vortex", 4.0);
	SetParent(client, particlel, "effect_hand_r");

	GetAttachment(client, "effect_hand_l", flPos, flAng);
	int particler = ParticleEffectAt(flPos, "eyeboss_death_vortex", 4.0);
	SetParent(client, particler, "effect_hand_l");

	float GameTime = GetGameTime(npc.index);
	fl_BEAM_DurationTime[npc.index] = GameTime + 5.0;
	fl_BEAM_ChargeUpTime[npc.index] = GameTime + 3.0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	npc.PlayLaserLaunchSound();
	
	SDKUnhook(client, SDKHook_Think, Silvester_TBB_Tick);
	SDKHook(client, SDKHook_Think, Silvester_TBB_Tick);
}

public Action Silvester_TBB_Tick(int client)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(client);
	float GameTime = GetGameTime(npc.index);
	if(!IsValidEntity(client) || fl_BEAM_DurationTime[npc.index] < GameTime)
	{
		SDKUnhook(client, SDKHook_Think, Silvester_TBB_Tick);
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
		
		npc.m_iInKame = 1;

		return Plugin_Stop;
	}

	if(fl_BEAM_ChargeUpTime[npc.index] > GameTime)
		return Plugin_Continue;

	Basic_NPC_Laser Data;
	Data.npc = npc;
	Data.Radius = 45.0;
	Data.Range = 2000.0;
	//divided by 6 since its every tick, and by TickrateModify
	Data.Close_Dps = RaidModeScaling * 16.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Long_Dps = RaidModeScaling * 12.0 / 6.0 / TickrateModify/ ReturnEntityAttackspeed(npc.index);
	Data.Color = {238, 221, 68, 60};
	Data.DoEffects = true;
	Basic_NPC_Laser_Logic(Data);

	return Plugin_Continue;
}

bool IsPartnerGivingUpSilvester(int entity)
{
	if(!IsValidEntity(entity))
		return true;

	return b_angered_twice[entity];
}

bool SharedGiveupSilvester(int entity, int entity2)
{
	if(IsPartnerGivingUpSilvester(entity) && IsPartnerGivingUpGoggles(entity2))
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
					if(!XenoExtraLogic())
						CPrintToChatAll("{gold}실베스터{default}: 우린 널 도와주려고 했어. 이건 분명히 엄청 힘든 일일거야.");
					else
						CPrintToChatAll("{gold}실베스터{default}: 전혀 내 말을 듣지 않아. 이젠 널 도와주고 싶지 않네.");
					i_TalkDelayCheck += 1;
				}
				case 1:
				{
					if(!XenoExtraLogic())
						CPrintToChatAll("{darkblue}월드치{default}: 우리보다 훨씬 크고 강한 적이 있지만, 우린 그들을 이길 수 없어.");
					else
						CPrintToChatAll("{darkblue}월드치{default}: 너흰 꼭 마치 무엇에 뛰어들 것인지 알고 있는 듯하네.");

					i_TalkDelayCheck += 1;
				}
				case 2:
				{
					
					CPrintToChatAll("{darkblue}월드치{default}: 솔직히 네가 그 놈을 이길 수 있을지 의심스럽지만, 만약 이긴다면, 큰 혼란을 물리치는 데 큰 도움이 될 거다.");
					i_TalkDelayCheck += 1;
				}
				case 3:
				{
					if(!XenoExtraLogic())
						CPrintToChatAll("{gold}실베스터{default}: 행운을 빌게.");
					else
						CPrintToChatAll("{gold}실베스터{default}: 이제 우리 사이에 다시는 이런 일이 일어나지 않을거야. 맹세할게. 그리고 난 분명히 너희한테 경고한거고!");

					i_TalkDelayCheck = 5;
					for (int client = 1; client <= MaxClients; client++)
					{
						if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
						{
							Items_GiveNamedItem(client, "Head Equipped Blue Goggles");
							CPrintToChat(client, "{default}그들에게서 약간의 도움을 받았습니다. 당신이 얻은것: {blue}''머리에 장착하는 파란 고글''{default}!");
						}
					}
				}
			}
		}
	}
	return false;
}


void SilvesterApplyEffects(int entity, bool withoutweapon = false)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	if(!npc.Anger)
	{
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);

		ExpidonsaRemoveEffects(entity);
		
		SilvesterEarsApply(npc.index);
		if(!withoutweapon)
			SilvesterApplyEffectsForm1(entity);
	}
	else
	{
		if(IsValidEntity(npc.m_iWearable8))
			RemoveEntity(npc.m_iWearable8);
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		ExpidonsaRemoveEffects(entity);
		SilvesterEarsApply(npc.index);
		SilvesterApplyEffectsForm2(entity, withoutweapon);			
	}
}

void SilvesterApplyEffectsForm1(int entity)
{
	if(AtEdictLimit(EDICT_RAID))
		return;
	
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
	SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 2);
	SetVariantInt(2048);
	AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");	
	/*
	int red = 255;
	int green = 255;
	int blue = 255;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	
	int particle_2 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
	int particle_3 = InfoTargetParentAt({-20.5,0.0,0.0}, "", 0.0); //First offset we go by
	int particle_4 = InfoTargetParentAt({-6.75,13.5,0.0}, "", 0.0); //First offset we go by
	int particle_5 = InfoTargetParentAt({-2.7,67.5,0.0}, "", 0.0); //First offset we go by

	
	int particle_2_1 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
	int particle_3_1 = InfoTargetParentAt({20.5,0.0,0.0}, "", 0.0); //First offset we go by
	int particle_4_1 = InfoTargetParentAt({6.75,13.5,0.0}, "", 0.0); //First offset we go by
	int particle_5_1 = InfoTargetParentAt({2.7,67.5,0.0}, "", 0.0); //First offset we go by

	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5_1, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(entity, particle_1, "effect_hand_R",_);


	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);

	int Laser_1_1 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_1 = ConnectWithBeamClient(particle_3_1, particle_4_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_1 = ConnectWithBeamClient(particle_4_1, particle_5_1, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);
	

	i_ExpidonsaEnergyEffect[entity][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[entity][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[entity][2] = EntIndexToEntRef(particle_3);
	i_ExpidonsaEnergyEffect[entity][3] = EntIndexToEntRef(particle_4);
	i_ExpidonsaEnergyEffect[entity][4] = EntIndexToEntRef(particle_5);
	i_ExpidonsaEnergyEffect[entity][5] = EntIndexToEntRef(Laser_1);
	i_ExpidonsaEnergyEffect[entity][6] = EntIndexToEntRef(Laser_2);
	i_ExpidonsaEnergyEffect[entity][7] = EntIndexToEntRef(Laser_3);
	
	i_ExpidonsaEnergyEffect[entity][8] = EntIndexToEntRef(particle_2_1);
	i_ExpidonsaEnergyEffect[entity][9] = EntIndexToEntRef(particle_3_1);
	i_ExpidonsaEnergyEffect[entity][10] = EntIndexToEntRef(particle_4_1);
	i_ExpidonsaEnergyEffect[entity][11] = EntIndexToEntRef(particle_5_1);
	i_ExpidonsaEnergyEffect[entity][12] = EntIndexToEntRef(Laser_1_1);
	i_ExpidonsaEnergyEffect[entity][13] = EntIndexToEntRef(Laser_2_1);
	i_ExpidonsaEnergyEffect[entity][14] = EntIndexToEntRef(Laser_3_1);
	*/
}


void SilvesterApplyEffectsForm2(int entity, bool withoutweapon = false)
{
	if(AtEdictLimit(EDICT_RAID))
		return;
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	
	if(!withoutweapon)
	{
		
		if(IsValidEntity(npc.m_iWearable1))
		{
			RemoveEntity(npc.m_iWearable1);
		}
		npc.m_iWearable1 = npc.EquipItem("head", WEAPON_CUSTOM_WEAPONRY_1);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 3);
		SetVariantInt(2048);
		AcceptEntityInput(npc.m_iWearable1, "SetBodyGroup");	
		/*
		int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
		
		int particle_2 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
		int particle_3 = InfoTargetParentAt({-20.5,0.0,0.0}, "", 0.0); //First offset we go by
		int particle_4 = InfoTargetParentAt({-6.75,13.5,0.0}, "", 0.0); //First offset we go by
		int particle_5 = InfoTargetParentAt({-2.7,67.5,0.0}, "", 0.0); //First offset we go by

		
		int particle_2_1 = InfoTargetParentAt({0.0,-20.5,0.0}, "", 0.0); //First offset we go by
		int particle_3_1 = InfoTargetParentAt({20.5,0.0,0.0}, "", 0.0); //First offset we go by
		int particle_4_1 = InfoTargetParentAt({6.75,13.5,0.0}, "", 0.0); //First offset we go by
		int particle_5_1 = InfoTargetParentAt({2.7,67.5,0.0}, "", 0.0); //First offset we go by

		SetParent(particle_1, particle_2, "",_, true);
		SetParent(particle_1, particle_3, "",_, true);
		SetParent(particle_1, particle_4, "",_, true);
		SetParent(particle_1, particle_5, "",_, true);
		
		SetParent(particle_1, particle_2_1, "",_, true);
		SetParent(particle_1, particle_3_1, "",_, true);
		SetParent(particle_1, particle_4_1, "",_, true);
		SetParent(particle_1, particle_5_1, "",_, true);

		Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
		SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
		SetParent(entity, particle_1, "effect_hand_R",_);


		int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_2 = ConnectWithBeamClient(particle_3, particle_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_3 = ConnectWithBeamClient(particle_4, particle_5, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);

		int Laser_1_1 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_2_1 = ConnectWithBeamClient(particle_3_1, particle_4_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
		int Laser_3_1 = ConnectWithBeamClient(particle_4_1, particle_5_1, red, green, blue, 3.0, 1.0, 1.0, LASERBEAM);
		

		i_ExpidonsaEnergyEffect[entity][0] = EntIndexToEntRef(particle_1);
		i_ExpidonsaEnergyEffect[entity][1] = EntIndexToEntRef(particle_2);
		i_ExpidonsaEnergyEffect[entity][2] = EntIndexToEntRef(particle_3);
		i_ExpidonsaEnergyEffect[entity][3] = EntIndexToEntRef(particle_4);
		i_ExpidonsaEnergyEffect[entity][4] = EntIndexToEntRef(particle_5);
		i_ExpidonsaEnergyEffect[entity][5] = EntIndexToEntRef(Laser_1);
		i_ExpidonsaEnergyEffect[entity][6] = EntIndexToEntRef(Laser_2);
		i_ExpidonsaEnergyEffect[entity][7] = EntIndexToEntRef(Laser_3);
		
		i_ExpidonsaEnergyEffect[entity][8] = EntIndexToEntRef(particle_2_1);
		i_ExpidonsaEnergyEffect[entity][9] = EntIndexToEntRef(particle_3_1);
		i_ExpidonsaEnergyEffect[entity][10] = EntIndexToEntRef(particle_4_1);
		i_ExpidonsaEnergyEffect[entity][11] = EntIndexToEntRef(particle_5_1);
		i_ExpidonsaEnergyEffect[entity][12] = EntIndexToEntRef(Laser_1_1);
		i_ExpidonsaEnergyEffect[entity][13] = EntIndexToEntRef(Laser_2_1);
		i_ExpidonsaEnergyEffect[entity][14] = EntIndexToEntRef(Laser_3_1);
		*/
			
	}

	if(IsValidEntity(npc.m_iWearable8))
	{
		RemoveEntity(npc.m_iWearable8);
	}
	npc.m_iWearable8 = npc.EquipItem("head", WINGS_MODELS_1);
	SetVariantInt(1);
	AcceptEntityInput(npc.m_iWearable8, "SetBodyGroup");	
	SetVariantString("1.35");
	AcceptEntityInput(npc.m_iWearable8, "SetModelScale");
	SetEntityRenderColor(npc.m_iWearable8, 255, 255, 255, 3);
	//possible loop function?

	/*
		Fist axies from the POV of the person LOOKINGF at the equipper
		flag

		1st: left and right, negative is left, positive is right 
		2nd: Up and down, negative up, positive down.
		3rd: front and back, negative goes back.
	*/
	/*
	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(entity, "flag", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(entity, ParticleOffsetMain, "flag",_);

	int particle_1_Wingset_1 = InfoTargetParentAt({35.0,40.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_1 = InfoTargetParentAt({-16.0,-16.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_1 = InfoTargetParentAt({16.0,16.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_1 = InfoTargetParentAt({-8.0,12.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_1 = InfoTargetParentAt({12.0,-8.0,-12.0}, "", 0.0);


	SetParent(particle_1_Wingset_1, particle_2_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_3_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_4_Wingset_1, "",_, true);
	SetParent(particle_1_Wingset_1, particle_5_Wingset_1, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_1, flPos);
	SetEntPropVector(particle_1_Wingset_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_1, "",_);
	
	int Laser_1_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_5_Wingset_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_1 = ConnectWithBeamClient(particle_2_Wingset_1, particle_4_Wingset_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_1 = ConnectWithBeamClient(particle_4_Wingset_1, particle_3_Wingset_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_1 = ConnectWithBeamClient(particle_5_Wingset_1, particle_3_Wingset_1, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][15] = EntIndexToEntRef(particle_1_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][16] = EntIndexToEntRef(particle_2_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][17] = EntIndexToEntRef(particle_3_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][18] = EntIndexToEntRef(particle_4_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][19] = EntIndexToEntRef(particle_5_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][20] = EntIndexToEntRef(Laser_1_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][21] = EntIndexToEntRef(Laser_2_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][22] = EntIndexToEntRef(Laser_3_Wingset_1);
	i_ExpidonsaEnergyEffect[entity][23] = EntIndexToEntRef(Laser_4_Wingset_1);
	
	int particle_1_Wingset_2 = InfoTargetParentAt({35.0,-40.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_2 = InfoTargetParentAt({16.0,-16.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_2 = InfoTargetParentAt({-16.0,16.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_2 = InfoTargetParentAt({-8.0,-12.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_2 = InfoTargetParentAt({12.0,8.0,-12.0}, "", 0.0);

	SetParent(particle_1_Wingset_2, particle_2_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_3_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_4_Wingset_2, "",_, true);
	SetParent(particle_1_Wingset_2, particle_5_Wingset_2, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_2, flPos);
	SetEntPropVector(particle_1_Wingset_2, Prop_Data, "m_angRotation", flAng);
	SetParent(ParticleOffsetMain, particle_1_Wingset_2, "",_);
	
	int Laser_1_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_5_Wingset_2, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_2 = ConnectWithBeamClient(particle_2_Wingset_2, particle_4_Wingset_2, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_2 = ConnectWithBeamClient(particle_4_Wingset_2, particle_3_Wingset_2, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_2 = ConnectWithBeamClient(particle_5_Wingset_2, particle_3_Wingset_2, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][24] = EntIndexToEntRef(particle_1_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][25] = EntIndexToEntRef(particle_2_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][26] = EntIndexToEntRef(particle_3_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][27] = EntIndexToEntRef(particle_4_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][28] = EntIndexToEntRef(particle_5_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][29] = EntIndexToEntRef(Laser_1_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][30] = EntIndexToEntRef(Laser_2_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][31] = EntIndexToEntRef(Laser_3_Wingset_2);
	i_ExpidonsaEnergyEffect[entity][32] = EntIndexToEntRef(Laser_4_Wingset_2);



	
	int particle_1_Wingset_3 = InfoTargetParentAt({-35.0,-40.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_3 = InfoTargetParentAt({-16.0,-16.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_3 = InfoTargetParentAt({16.0,16.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_3 = InfoTargetParentAt({-12.0,8.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_3 = InfoTargetParentAt({8.0,-12.0,-12.0}, "", 0.0);

	SetParent(particle_1_Wingset_3, particle_2_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_3_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_4_Wingset_3, "",_, true);
	SetParent(particle_1_Wingset_3, particle_5_Wingset_3, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_3, flPos);
	SetEntPropVector(particle_1_Wingset_3, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_3, "",_);
	
	int Laser_1_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_5_Wingset_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_3 = ConnectWithBeamClient(particle_2_Wingset_3, particle_4_Wingset_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_3 = ConnectWithBeamClient(particle_4_Wingset_3, particle_3_Wingset_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_3 = ConnectWithBeamClient(particle_5_Wingset_3, particle_3_Wingset_3, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][33] = EntIndexToEntRef(particle_1_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][34] = EntIndexToEntRef(particle_2_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][35] = EntIndexToEntRef(particle_3_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][36] = EntIndexToEntRef(particle_4_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][37] = EntIndexToEntRef(particle_5_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][38] = EntIndexToEntRef(Laser_1_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][39] = EntIndexToEntRef(Laser_2_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][40] = EntIndexToEntRef(Laser_3_Wingset_3);
	i_ExpidonsaEnergyEffect[entity][41] = EntIndexToEntRef(Laser_4_Wingset_3);


	
	int particle_1_Wingset_4 = InfoTargetParentAt({-35.0,40.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_4 = InfoTargetParentAt({-16.0,16.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_4 = InfoTargetParentAt({16.0,-16.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_4 = InfoTargetParentAt({8.0,12.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_4 = InfoTargetParentAt({-12.0,-8.0,-12.0}, "", 0.0);

	SetParent(particle_1_Wingset_4, particle_2_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_3_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_4_Wingset_4, "",_, true);
	SetParent(particle_1_Wingset_4, particle_5_Wingset_4, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_4, flPos);
	SetEntPropVector(particle_1_Wingset_4, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_4, "",_);
	
	int Laser_1_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_5_Wingset_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_4 = ConnectWithBeamClient(particle_2_Wingset_4, particle_4_Wingset_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_4 = ConnectWithBeamClient(particle_4_Wingset_4, particle_3_Wingset_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_4 = ConnectWithBeamClient(particle_5_Wingset_4, particle_3_Wingset_4, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][42] = EntIndexToEntRef(particle_1_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][43] = EntIndexToEntRef(particle_2_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][44] = EntIndexToEntRef(particle_3_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][45] = EntIndexToEntRef(particle_4_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][46] = EntIndexToEntRef(particle_5_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][47] = EntIndexToEntRef(Laser_1_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][48] = EntIndexToEntRef(Laser_2_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][49] = EntIndexToEntRef(Laser_3_Wingset_4);
	i_ExpidonsaEnergyEffect[entity][50] = EntIndexToEntRef(Laser_4_Wingset_4);


	
	
	int particle_1_Wingset_5 = InfoTargetParentAt({-50.0,0.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_5 = InfoTargetParentAt({-20.0,0.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_5 = InfoTargetParentAt({20.0,0.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_5 = InfoTargetParentAt({-3.0,14.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_5 = InfoTargetParentAt({-3.0,-14.0,-12.0}, "", 0.0);

	SetParent(particle_1_Wingset_5, particle_2_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_3_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_4_Wingset_5, "",_, true);
	SetParent(particle_1_Wingset_5, particle_5_Wingset_5, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_5, flPos);
	SetEntPropVector(particle_1_Wingset_5, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_5, "",_);
	
	int Laser_1_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_5_Wingset_5, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_5 = ConnectWithBeamClient(particle_2_Wingset_5, particle_4_Wingset_5, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_5 = ConnectWithBeamClient(particle_4_Wingset_5, particle_3_Wingset_5, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_5 = ConnectWithBeamClient(particle_5_Wingset_5, particle_3_Wingset_5, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][51] = EntIndexToEntRef(particle_1_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][52] = EntIndexToEntRef(particle_2_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][53] = EntIndexToEntRef(particle_3_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][54] = EntIndexToEntRef(particle_4_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][55] = EntIndexToEntRef(particle_5_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][56] = EntIndexToEntRef(Laser_1_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][57] = EntIndexToEntRef(Laser_2_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][58] = EntIndexToEntRef(Laser_3_Wingset_5);
	i_ExpidonsaEnergyEffect[entity][59] = EntIndexToEntRef(Laser_4_Wingset_5);


	int particle_1_Wingset_6 = InfoTargetParentAt({50.0,0.0,-15.0}, "", 0.0); //This is the root bone basically

	int particle_2_Wingset_6 = InfoTargetParentAt({-20.0,0.0,-12.0}, "", 0.0); 
	int particle_3_Wingset_6 = InfoTargetParentAt({20.0,0.0,-12.0}, "", 0.0); 
	int particle_4_Wingset_6 = InfoTargetParentAt({3.0,14.0,-12.0}, "", 0.0); 
	int particle_5_Wingset_6 = InfoTargetParentAt({3.0,-14.0,-12.0}, "", 0.0);

	SetParent(particle_1_Wingset_6, particle_2_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_3_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_4_Wingset_6, "",_, true);
	SetParent(particle_1_Wingset_6, particle_5_Wingset_6, "",_, true);

	
	Custom_SDKCall_SetLocalOrigin(particle_1_Wingset_6, flPos);
	SetEntPropVector(particle_1_Wingset_6, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_1_Wingset_6, "",_);
	
	int Laser_1_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_5_Wingset_6, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_2_Wingset_6 = ConnectWithBeamClient(particle_2_Wingset_6, particle_4_Wingset_6, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_3_Wingset_6 = ConnectWithBeamClient(particle_4_Wingset_6, particle_3_Wingset_6, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);
	int Laser_4_Wingset_6 = ConnectWithBeamClient(particle_5_Wingset_6, particle_3_Wingset_6, red, green, blue, 3.0, 3.0, 1.0, LASERBEAM);

	
	i_ExpidonsaEnergyEffect[entity][60] = EntIndexToEntRef(particle_1_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][61] = EntIndexToEntRef(particle_2_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][62] = EntIndexToEntRef(particle_3_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][63] = EntIndexToEntRef(particle_4_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][64] = EntIndexToEntRef(particle_5_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][65] = EntIndexToEntRef(Laser_1_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][66] = EntIndexToEntRef(Laser_2_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][67] = EntIndexToEntRef(Laser_3_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][68] = EntIndexToEntRef(Laser_4_Wingset_6);
	i_ExpidonsaEnergyEffect[entity][69] = EntIndexToEntRef(ParticleOffsetMain);
*/
}


int IsSilvesterTransforming(int silvester)
{
	if(!IsValidEntity(silvester))
		return 0;

	RaidbossSilvester npc = view_as<RaidbossSilvester>(silvester);
	if(npc.m_flNextChargeSpecialAttack > GetGameTime(npc.index))
	{
		return 1; //Transforming, make goggles immune to damage.
	}

	if(npc.Anger)
	{
		return 2; //he's angry, get resisstances.
	}

	return 3;
}

public void Raidmode_Shared_Xeno_Duo(int entity)
{
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
	func_NPCThink[entity] = INVALID_FUNCTION;
	if(AlreadySaidWin)
		return;

	AlreadySaidWin = true;
	//b_NpcHasDied[client]
	char npc_classname[60];
	NPC_GetPluginById(i_NpcInternalId[entity], npc_classname, sizeof(npc_classname));
	
	if(StrEqual(npc_classname, "npc_xeno_raidboss_silvester"))
	{
		if(XenoExtraLogic())
		{
			CPrintToChatAll("{gold}실베스터{default}: 넌 너무 고집불통이야.");
		}
		else
		{
			CPrintToChatAll("{gold}실베스터{default}: 어쩌면 우리는 너에게 더 좋은 경고 방식을 생각해냈어야 했을지도 모르겠어.");
		}
		return;
	}
	if(StrEqual(npc_classname, "npc_infected_goggles"))
	{
		if(XenoExtraLogic())
		{
			CPrintToChatAll("{darkblue}월드치{default}: 너무 멀리 오셨군.");
		}
		else
		{
			CPrintToChatAll("{darkblue}월드치{default}: {green}그 놈{default}에게 죽는 것보단 나을거다.");
		}
	}
}

void SharedTimeLossSilvesterDuo(int entity)
{
	float SelfPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", SelfPos);
	float AllyAng[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", AllyAng);
	int Spawner_entity = GetRandomActiveSpawner();
	if(IsValidEntity(Spawner_entity))
	{
		GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
		GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
	}
	int SensalSpawn = NPC_CreateByName("npc_sensal", -1, SelfPos, AllyAng, GetTeam(entity), "duo_cutscene"); //can only be enemy
	if(IsValidEntity(SensalSpawn))
	{
		if(GetTeam(SensalSpawn) != TFTeam_Red)
		{
			NpcAddedToZombiesLeftCurrently(SensalSpawn, true);
		}
		SetEntProp(SensalSpawn, Prop_Data, "m_iHealth", 100000000);
		SetEntProp(SensalSpawn, Prop_Data, "m_iMaxHealth", 100000000);
		CPrintToChatAll("{blue}센살{default}: 당장 멈춰. 지금 이게 무슨 상황이지?");
	}
}

static void Internal_Weapon_Lines(RaidbossSilvester npc, int client)
{
	if(client > MaxClients)
		return;

	if(b_said_player_weaponline[client])	//only 1 line per player.
		return;

	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

	if(!IsValidEntity(weapon))	//invalid weapon, go back and get a valid one you <...>
		return;

	float GameTime = GetGameTime();	//no need to throttle this.

	if(fl_said_player_weaponline_time[npc.index] > GameTime)	//no spamming in chat please!
		return;

	bool valid = true;
	char Text_Lines[255];

	Text_Lines = "";

	switch(i_CustomWeaponEquipLogic[weapon])
	{
		
		case WEAPON_SENSAL_SCYTHE,WEAPON_SENSAL_SCYTHE_PAP_1,WEAPON_SENSAL_SCYTHE_PAP_2,WEAPON_SENSAL_SCYTHE_PAP_3:
		 switch(GetRandomInt(0,1)) 	{case 0: Format(Text_Lines, sizeof(Text_Lines), "그 무기, 분명 센살의 것이지만 걔보단 못 다루네.");
		  							case 1: Format(Text_Lines, sizeof(Text_Lines), "{blue}센살{default}이 너한테 그 무기를 줬다고, {gold}%N{default}? 세상에.", client);}	//IT ACTUALLY WORKS, LMFAO
		case WEAPON_FUSION,WEAPON_FUSION_PAP1,WEAPON_FUSION_PAP2, WEAPON_NEARL: switch(GetRandomInt(0,1)) 		{case 0: Format(Text_Lines, sizeof(Text_Lines), "그건 내 무기인데... 어떻게 얻은거야?");
		 							case 1: Format(Text_Lines, sizeof(Text_Lines), "그건 내 무기잖아!");}
		case WEAPON_KIT_BLITZKRIEG_CORE:  Format(Text_Lines, sizeof(Text_Lines), "어, 그 미친 기계를 잡았어? 대단한데!");
		case WEAPON_BOBS_GUN:  Format(Text_Lines, sizeof(Text_Lines), "그 총은 나한텐 아무것도 아니야!!!");
		case WEAPON_ANGELIC_SHOTGUN:  Format(Text_Lines, sizeof(Text_Lines), "{lightblue}네말{default}의 총...? 어...");

		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		CPrintToChatAll("{gold}Silvester{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}
