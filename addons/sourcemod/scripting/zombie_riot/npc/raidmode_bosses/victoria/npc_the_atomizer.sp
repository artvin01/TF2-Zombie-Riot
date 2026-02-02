#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/scout_painsharp01.mp3",
	"vo/scout_painsharp02.mp3",
	"vo/scout_painsharp03.mp3",
	"vo/scout_painsharp04.mp3",
	"vo/scout_painsharp05.mp3",
	"vo/scout_painsharp06.mp3",
	"vo/scout_painsharp07.mp3",
	"vo/scout_painsharp08.mp3"
};
static const char g_MissAbilitySound[][] = {
	"vo/scout_invinciblechgunderfire01.mp3",
	"vo/scout_invinciblechgunderfire02.mp3",
	"vo/scout_invinciblechgunderfire03.mp3",
	"vo/scout_invinciblechgunderfire04.mp3",
	"vo/scout_beingshotinvincible01.mp3",
	"vo/scout_beingshotinvincible02.mp3",
	"vo/scout_beingshotinvincible03.mp3",
	"vo/scout_beingshotinvincible04.mp3",
	"vo/scout_beingshotinvincible05.mp3",
	"vo/scout_beingshotinvincible06.mp3",
	"vo/scout_beingshotinvincible07.mp3",
	"vo/scout_beingshotinvincible08.mp3",
	"vo/scout_beingshotinvincible09.mp3",
	"vo/scout_beingshotinvincible10.mp3",
	"vo/scout_beingshotinvincible11.mp3",
	"vo/scout_beingshotinvincible12.mp3",
	"vo/scout_beingshotinvincible13.mp3",
	"vo/scout_beingshotinvincible14.mp3",
	"vo/scout_beingshotinvincible15.mp3",
	"vo/scout_beingshotinvincible16.mp3",
	"vo/scout_beingshotinvincible17.mp3",
	"vo/scout_beingshotinvincible18.mp3",
	"vo/scout_beingshotinvincible19.mp3",
	"vo/scout_beingshotinvincible20.mp3",
	"vo/scout_beingshotinvincible21.mp3",
	"vo/scout_beingshotinvincible22.mp3",
	"vo/scout_beingshotinvincible23.mp3",
	"vo/scout_beingshotinvincible24.mp3",
	"vo/scout_beingshotinvincible25.mp3",
	"vo/scout_beingshotinvincible26.mp3",
	"vo/scout_beingshotinvincible27.mp3",
	"vo/scout_beingshotinvincible28.mp3",
	"vo/scout_beingshotinvincible29.mp3",
	"vo/scout_beingshotinvincible30.mp3",
	"vo/scout_beingshotinvincible31.mp3",
	"vo/scout_beingshotinvincible32.mp3",
	"vo/scout_beingshotinvincible33.mp3",
	"vo/scout_beingshotinvincible34.mp3",
	"vo/scout_beingshotinvincible35.mp3",
	"vo/scout_beingshotinvincible36.mp3"
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/scout_taunts03.mp3",
	"vo/taunts/scout_taunts04.mp3",
	"vo/taunts/scout_taunts06.mp3",
	"vo/taunts/scout_taunts15.mp3",
	"vo/compmode/cm_scout_pregamefirst_01.mp3"
};
static const char g_RangedAttackSounds[][] = {
	"weapons/3rd_degree_hit_01.wav",
	"weapons/3rd_degree_hit_02.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/bat_draw.wav",
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav"
};
static const char g_HomerunSounds[][]= {
	"vo/scout_stunballhit01.mp3",
	"vo/scout_stunballhit02.mp3",
	"vo/scout_stunballhit03.mp3",
	"vo/scout_stunballhit04.mp3",
	"vo/scout_stunballhit05.mp3",
	"vo/scout_stunballhit06.mp3",
	"vo/scout_stunballhit07.mp3",
	"vo/scout_stunballhit08.mp3"
};
static const char g_HomerunfailSounds[][]= {
	"vo/taunts/scout/scout_taunt_rps_lose_01.mp3",
	"vo/taunts/scout/scout_taunt_rps_lose_03.mp3"
};
static const char g_StunballPickupeSound[][] = {
	"vo/scout_stunballpickup01.mp3",
	"vo/scout_stunballpickup02.mp3",
	"vo/scout_stunballpickup03.mp3",
	"vo/scout_stunballpickup04.mp3",
	"vo/scout_stunballpickup05.mp3"
};
static const char g_MeleeHitSounds[] = "weapons/bat_hit.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/scout_revenge06.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_SupportSounds[] = "vo/scout_revenge05.mp3";
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

/* Victoria Nuke */
static float Vs_DelayTime[MAXENTITIES];
float Vs_RechargeTime[MAXENTITIES];
float Vs_RechargeTimeMax[MAXENTITIES];
static int Vs_Target[MAXENTITIES];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];
bool Vs_LockOn[MAXENTITIES];

//for Huscarls
int Vs_Atomizer_To_Huscarls;

static bool DrinkPOWERUP[MAXENTITIES];
static bool OnMiss[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];

static bool SUPERHIT[MAXENTITIES];

static int g_RedPoint;
static int g_Laser;

void Atomizer_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Atomizer");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_atomizer");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_atomizer_raid");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_HomerunSounds);
	PrecacheSoundArray(g_StunballPickupeSound);
	PrecacheSoundArray(g_MissAbilitySound);
	PrecacheSoundArray(g_HomerunfailSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	PrecacheSound(g_SupportSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheSound("weapons/bumper_car_spawn.wav");
	PrecacheSoundCustom("#zombiesurvival/victoria_1/raid_atomizer.mp3");
	
	g_Laser = PrecacheModel(LASERBEAM);
	g_RedPoint = PrecacheModel("sprites/redglow1.vmt");
	
	PrecacheModel("models/player/scout.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Atomizer(client, vecPos, vecAng, ally, data);
}

methodmap Atomizer < CClotBody
{
	public void PlayIdleAlertSound(){
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayHurtSound(){
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMissSound(){
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		this.m_flNextHurtSound = GetGameTime(this.index) + 1.0;
		int sound = GetRandomInt(0, sizeof(g_MissAbilitySound) - 1);
		EmitSoundToAll(g_MissAbilitySound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_MissAbilitySound[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void NiceCatchKnucklehead() {
		EmitSoundToAll(g_StunballPickupeSound[GetRandomInt(0, sizeof(g_StunballPickupeSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerSound() {
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerReaction() {
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunHitSound() {
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunHitSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySupportSpawnSound() {
		EmitSoundToAll(g_SupportSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_SupportSounds, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunSound() {
		int sound = GetRandomInt(0, sizeof(g_HomerunSounds) - 1);
		EmitSoundToAll(g_HomerunSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomerunMissSound() {
		int sound = GetRandomInt(0, sizeof(g_HomerunfailSounds) - 1);
		EmitSoundToAll(g_HomerunfailSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_HomerunfailSounds[sound], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound(){
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound(){
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound(){
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRangedSound(){
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, GetRandomInt(80,110));
	}
	public void PlayMeleeSound(){
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound(){
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	property float m_flFTL
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flDelay_Attribute
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	property float m_flNiceMiss
	{
		public get()							{ return fl_AbilityOrAttack[this.index][2]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][2] = TempValueForProperty; }
	}
	property float m_flBaseSpeed
	{
		public get()							{ return fl_AbilityOrAttack[this.index][3]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][3] = TempValueForProperty; }
	}
	
	public Atomizer(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Atomizer npc = view_as<Atomizer>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.35", "45000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(3);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;

		if(StrContains(data, "support_ability") != -1)
		{
			func_NPCDeath[npc.index] = Clone_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Clone_OnTakeDamage;
			func_NPCThink[npc.index] = Clone_ClotThink;
			
			MakeObjectIntangeable(npc.index);
			//b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			npc.m_iState = 0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flNextRangedAttack = 0.0;
			npc.m_flRangedSpecialDelay = 0.0;
			npc.m_flNextRangedSpecialAttackHappens = 0.0;
			npc.m_flAngerDelay = 0.0;
			npc.m_flDelay_Attribute = 0.0;
			npc.m_iAmmo = 0;
			
			static char countext[2][216];
			int count = ExplodeString(data, ";", countext, sizeof(countext), sizeof(countext[]));
			for(int i = 0; i < count; i++)
			{
				if(i>=count)break;
				else if(StrContains(countext[i], "support_ability") != -1)
				{
					ReplaceString(countext[i], sizeof(countext[]), "support_ability", "");
					npc.m_iOverlordComboAttack = StringToInt(countext[i]);
				}
				else if(StrContains(countext[i], "override") != -1)
				{
					ReplaceString(countext[i], sizeof(countext[]), "override", "");
					npc.m_iTargetAlly = StringToInt(countext[i]);
				}
			}
			switch(npc.m_iOverlordComboAttack)
			{
				case 1: NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Support-1", false, true);
				case 2:
				{
					npc.m_flSpeed = 400.0;
					npc.m_iMaxAmmo = 30+RoundToNearest(float(CountPlayersOnRed(2)) * 2.5);
					if(npc.m_iMaxAmmo>45)npc.m_iMaxAmmo=45;
					npc.m_iAmmo = npc.m_iMaxAmmo;
					NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Support-2", false, true);
				}
				default: NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Support-1", false, true);
			}
			npc.PlaySupportSpawnSound();
		}
		else
		{
			RemoveAllDamageAddition();
			func_NPCDeath[npc.index] = Atomizer_NPCDeath;
			func_NPCOnTakeDamage[npc.index] = Atomizer_OnTakeDamage;
			func_NPCThink[npc.index] = Atomizer_ClotThink;
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			//IDLE
			npc.StartPathing();
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_flBaseSpeed = 300.0;
			npc.m_flSpeed = 300.0;
			npc.m_flDelay_Attribute = 0.0;
			DrinkPOWERUP[npc.index] = false;
			YaWeFxxked[npc.index] = false;
			ParticleSpawned[npc.index] = false;
			SUPERHIT[npc.index] = false;
			npc.m_flNiceMiss = 0.0;
			Vs_Atomizer_To_Huscarls = 0;
			npc.i_GunMode = 0;
			npc.m_iOverlordComboAttack = 0;
			npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 15.0;
			npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 5.0;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 30.0;
			npc.m_flAngerDelay = GetGameTime(npc.index) + 15.0;
			npc.m_iMaxAmmo = 20+RoundToNearest(float(CountPlayersOnRed(2)) * 2.5);
			if(npc.m_iMaxAmmo>45)npc.m_iMaxAmmo=45;
			npc.m_iAmmo = 0;
			OnMiss[npc.index] = false;
			npc.m_fbRangedSpecialOn = false;
			npc.m_bFUCKYOU = false;
			npc.m_bFUCKYOU_move_anim = false;
			AlreadySaidWin = false;
			
			ApplyStatusEffect(npc.index, npc.index, "Ammo_TM Visualization", 999.0);
			
			Zero(b_said_player_weaponline);
			fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
			
			Vs_RechargeTimeMax[npc.index] = 20.0;
			Victoria_Support_RechargeTimeMax(npc.index, 20.0);
			
			EmitSoundToAll("weapons/bumper_car_spawn.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("weapons/bumper_car_spawn.wav", _, _, _, _, 1.0);	
			b_thisNpcIsARaid[npc.index] = true;
			b_angered_twice[npc.index] = false;
			for(int client_check=1; client_check<=MaxClients; client_check++)
			{
				if(IsClientInGame(client_check) && !IsFakeClient(client_check))
				{
					LookAtTarget(client_check, npc.index);
					SetGlobalTransTarget(client_check);
					ShowGameText(client_check, "item_armor", 1, "%t", "Atomizer Arrived");
				}
			}
			npc.m_flFTL = 200.0;
			RaidModeTime = GetGameTime(npc.index) + npc.m_flFTL;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;

			if(StrContains(data, "nomusic") == -1)
			{
				MusicEnum music;
				strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria_1/raid_atomizer.mp3");
				music.Time = 128;
				music.Volume = 2.0;
				music.Custom = true;
				strcopy(music.Name, sizeof(music.Name), "Hard to Ignore");
				strcopy(music.Artist, sizeof(music.Artist), "UNFINISH");
				Music_SetRaidMusic(music);
			}
			
			NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Intro", false, true);
			Vs_Atomizer_To_Huscarls=Victoria_Melee_or_Ranged(npc);
			
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
			if(RaidModeScaling < 35)
			{
				RaidModeScaling *= 0.25; //abit low, inreacing
			}
			else
			{
				RaidModeScaling *= 0.5;
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
			
		}
		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
		SetVariantString("1.2");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/scout/pn2_longfall.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/scout/fall17_jungle_jersey/fall17_jungle_jersey.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/scout/sum19_bottle_cap/sum19_bottle_cap.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable5, 100, 100, 100, 255);

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/scout/hwn2019_fuel_injector/hwn2019_fuel_injector.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({100, 150, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		return npc;
	}
}

static void Clone_ClotThink(int iNPC)
{
	Atomizer npc = view_as<Atomizer>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;
	
	switch(npc.m_iOverlordComboAttack)
	{
		case 1:
		{
			static float ProjLocBase[3];
			if(npc.m_iState <= 0)
			{
				npc.AddActivityViaSequence("taunt05");
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.4);
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				int POWERHomeRUN = ParticleEffectAt(pos, "utaunt_aestheticlogo_teamcolor_blue", 3.0);
				if(IsValidEntity(POWERHomeRUN))
				{
					SetVariantString("!activator");
					AcceptEntityInput(POWERHomeRUN, "SetParent", npc.index);
				}
				npc.m_flDelay_Attribute = gameTime + 0.5;
				npc.StopPathing();
				npc.m_bisWalking = false;
				npc.m_iState++;
			}
			else if(npc.m_iState < 23)
			{
				float ProjLoc[3];
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
				ProjLocBase = ProjLoc;
				ProjLocBase[2] += 5.0;
				float cpos[3];
				float velocity[3];
				for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
				{
					if(IsValidEnemy(npc.index, EnemyLoop, true, true))
					{
						float vecTarget[3]; WorldSpaceCenter(EnemyLoop, vecTarget);
						float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
						float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
						if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && flDistanceToTarget < (1000.0 * 1000.0))
						{
							if(!HasSpecificBuff(EnemyLoop, "Solid Stance"))
							{
								GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", cpos);
								
								MakeVectorFromPoints(ProjLoc, cpos, velocity);
								NormalizeVector(velocity, velocity);
								ScaleVector(velocity, -450.0);
								if(b_ThisWasAnNpc[EnemyLoop])
								{
									CClotBody npc1 = view_as<CClotBody>(EnemyLoop);
									npc1.SetVelocity(velocity);
								}
								else
									TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
							}
							if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							{
								int red = 125;
								int green = 175;
								int blue = 255;
								if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
									RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
								int laser;
								if(HasSpecificBuff(EnemyLoop, "Solid Stance"))
								{
									red = 50;
									green = 50;
									blue = 50;
								}
								
								laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
					
								i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
								//Im seeing a new target, relocate laser particle.
							}
						}
						else
						{
							if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
								RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
				IncreaseEntityDamageTakenBy(npc.index, 0.7, 0.1);
				spawnRing_Vectors(ProjLocBase, 300.0  * 2.0, 0.0, 0.0, 5.0, LASERBEAM, 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
				spawnRing_Vectors(ProjLocBase, 300.0 * 2.0, 0.0, 0.0, 25.0, LASERBEAM, 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
				
				spawnRing_Vectors(ProjLocBase, 1000.0 * 2.0, 0.0, 0.0, 0.0, LASERBEAM, 255, 255, 255, 150, 1, 0.1, 3.25, 0.1, 3);
				npc.m_flDoingAnimation = gameTime + 1.1;
				npc.m_flDelay_Attribute = gameTime + 0.5;
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.m_iChanged_WalkCycle = 0;
				npc.m_iState++;
			}
			else if(npc.m_flDelay_Attribute < gameTime)
			{
				float damageDealt = 125.0 * RaidModeScaling;
				KillFeed_SetKillIcon(npc.index, "bonk");
				Explode_Logic_Custom(damageDealt, 0, npc.index, -1, ProjLocBase, 300.0 , 1.0, _, true, 20,_,_,_,SuperAttack);
				for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}
				if(SUPERHIT[npc.index])
				{
					npc.PlayHomerunSound();
					npc.PlayHomerunHitSound();
					npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
					SUPERHIT[npc.index]=false;
				}
				else npc.PlayHomerunMissSound();
				npc.m_flDelay_Attribute = gameTime + 0.5;
				npc.m_iState=0;
				npc.m_iOverlordComboAttack=0;
			}
		}
		case 2:
		{
			if(npc.m_flGetClosestTargetTime < gameTime)
			{
				npc.m_iTarget = GetClosestTarget(npc.index);
				npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
			}
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
				float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
				float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				switch(Support_Work(npc, gameTime, flDistanceToTarget))
				{
					case 0:
					{
						npc.m_bisWalking = true;
						npc.m_bAllowBackWalking = false;
						if(flDistanceToTarget < npc.GetLeadRadius()) 
						{
							float vPredictedPos[3];
							PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
							npc.SetGoalVector(vPredictedPos);
						}
						else 
						{
							npc.SetGoalEntity(npc.m_iTarget);
						}
					}
					case 1:
					{
						npc.m_bisWalking = true;
						npc.m_bAllowBackWalking = true;
						float vBackoffPos[3];
						BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
						npc.SetGoalVector(vBackoffPos, true);
					}
				}
			}
			else
			{
				npc.m_flGetClosestTargetTime = 0.0;
				npc.m_iTarget = GetClosestTarget(npc.index);
			}
			if(npc.m_flDoingAnimation < gameTime)
				AtomizerAnimationChange(npc);
				
			if(npc.m_iAmmo<1)
			{
				npc.StopPathing();
				npc.m_bisWalking = false;
			
				npc.AddActivityViaSequence("taunt_the_trackmans_touchdown");
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(1.4);
				npc.m_flDelay_Attribute = gameTime + 0.75;
				npc.m_iOverlordComboAttack=0;
			}
		}
		default:
		{
			if(npc.m_flDelay_Attribute < gameTime)
			{
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
				npc.PlayDeathSound();
				
				b_NpcForcepowerupspawn[npc.index] = 0;
				i_RaidGrantExtra[npc.index] = 0;
				b_DissapearOnDeath[npc.index] = true;
				b_DoGibThisNpc[npc.index] = true;
				SmiteNpcToDeath(npc.index);
			}
		}
	}
}

static int Support_Work(Atomizer npc, float gameTime, float distance)
{
	switch(npc.m_iOverlordComboAttack)
	{
		case 2:
		{
			if(IsValidEnemy(npc.index, Can_I_See_Enemy(npc.index, npc.m_iTarget)) && (distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0) || npc.m_flAttackHappenswillhappen))
			{
				if(npc.m_flNextMeleeAttack < gameTime)
				{
					if(!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY",_,_,_,2.0);
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = gameTime+0.0625;
						npc.m_flAttackHappens_bullshit = gameTime+0.125;
						npc.m_flAttackHappenswillhappen = true;
					}
					if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.PlayRangedSound();
						float RocketDamage = 37.5;
						float RocketSpeed = 1650.0;
						float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
						float VecStart[3]; WorldSpaceCenter(npc.index, VecStart);
						float vecDest[3];
						npc.FaceTowards(vecTarget, 20000.0);
						vecDest = vecTarget;
						float SpeedReturn[3];
						for(int i=1; i<=(npc.m_iAmmo > 3 ? 3 : 1); i++)
						{
							if(npc.m_iAmmo)
							{
								int RocketGet = npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling, RocketSpeed, 400.0, "critical_rocket_blue", false);
								if(RocketGet != -1)
								{
									//max duration of 3 seconds
									CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
								}
								ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.0, 1.0);
								SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
								//Better_Gravity_Rocket(RocketGet, 55.0);
								TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
								WandProjectile_ApplyFunctionToEntity(RocketGet, Atomizer_Rocket_Particle_StartTouch);
								npc.m_iAmmo--;
							}
							else break;
						}
						npc.m_flNextMeleeAttack = gameTime + 0.0625;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = gameTime + 0.0625;
					}
				}
			}
			if(distance > (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
				return 0;
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 8.0))
			{
				if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					return 1;
			}
		}
	}
	return 0;
}

static Action Clone_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	return Plugin_Handled;
}

static void Clone_NPCDeath(int entity)
{
	Atomizer npc = view_as<Atomizer>(entity);
	
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
	}
}

static void Atomizer_ClotThink(int iNPC)
{
	Atomizer npc = view_as<Atomizer>(iNPC);
	float gameTime = GetGameTime(npc.index);
	bool GETVictoria_Support = Victoria_Support(npc);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable8 = ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}
	if(npc.m_flNiceMiss < gameTime)
	{
		if(IsValidEntity(npc.m_iWearable1))
			RemoveEntity(npc.m_iWearable1);
		if(IsValidEntity(npc.m_iWearable7))
			RemoveEntity(npc.m_iWearable7);
	}
	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Lastman-1", false, false);
				}
				case 1:
				{
					NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Lastman-2", false, false);
				}
				case 2:
				{
					NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Lastman-3", false, false);
				}
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		DeleteAndRemoveAllNpcs = 2.0;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_peace_out");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		AlreadySaidWin = true;
		BlockLoseSay = true;
		
		NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_GameEnd", false, false);
		return;
	}
	npc.m_flSpeed = npc.m_flBaseSpeed+(((npc.m_flFTL-(RaidModeTime - GetGameTime()))/npc.m_flFTL)*150.0);
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		BlockLoseSay = true;
		npc.m_flMeleeArmor = 0.3696;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_TimeUp-1", false, false);
			case 2:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_TimeUp-2", false, false);
			case 3:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_TimeUp-3", false, false);
			case 4:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_TimeUp-4", false, false);
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_batter",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_charger",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_teslar",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_victorian_vanguard",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_supplier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_ballista",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_grenadier",_,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		for(int i=1; i<=15; i++)
		{
			switch(GetRandomInt(1, 8))
			{
				case 1:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_humbee",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 2:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_shotgunner",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 3:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_bulldozer",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}	
				case 4:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_hardener",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 5:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_raider",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 6:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_zapper",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 7:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_payback",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
				case 8:
				{
					VictoriaRadiomastSpawnEnemy(npc.index,"npc_blocker",_,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
				}
			}
		}
		YaWeFxxked[npc.index] = true;
	}
	if(YaWeFxxked[npc.index])
	{
		for(int i; i < i_MaxcountNpcTotal; i++)
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
			if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == GetTeam(npc.index))
				ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.3);
		}
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > gameTime)
		return;

	npc.m_flNextThinkTime = gameTime + 0.1;

	if(!IsValidEntity(RaidBossActive))
		RaidBossActive = EntIndexToEntRef(npc.index);

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(npc.m_bFUCKYOU)
	{
		switch(npc.m_iState)
		{
			case 0:
			{
				NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Pre_2_Phase", false, false);
				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/taunt_cheers/taunt_cheers_pyro.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				npc.StopPathing();
				
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_cheers_scout");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(2.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.5;	
				npc.m_flDelay_Attribute = gameTime + 1.4;
				npc.m_iState=1;
				if(!LastMann)Vs_Atomizer_To_Huscarls=Victoria_Melee_or_Ranged(npc);
			}
			case 1:
			{
				if(npc.m_flDelay_Attribute < gameTime)
				{
					EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.9);
					EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.9);
					npc.StopPathing();
					
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 1.5;	
					npc.m_flDelay_Attribute = gameTime + 0.6;
					npc.m_iState=2;
				}
			}
			case 2:
			{
				if(npc.m_flDelay_Attribute < gameTime)
				{
					npc.PlayAngerSound();
					npc.PlayAngerReaction();
					DrinkPOWERUP[npc.index]=true;
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
					SetVariantString("1.2");
					AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
					ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
					NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_2_Phase", false, false);
					npc.m_iState=0;
					npc.m_bFUCKYOU_move_anim=true;
					npc.m_flNextRangedAttack = gameTime+1.0;//Punishment
					npc.m_flRangedSpecialDelay += 2.0;
					npc.m_flNextRangedSpecialAttackHappens += 2.0;
					npc.m_bFUCKYOU=false;
				}
			}
		}
		if(npc.m_flDoingAnimation < gameTime)
			AtomizerAnimationChange(npc);
		return;
	}
	
	if(GETVictoria_Support && npc.m_flDoingAnimation < gameTime)
	{
	
	
	}
	
	if(npc.m_flNextRangedAttack < gameTime)
	{
		static float ProjLocBase[3];
		if(npc.m_iState <= 0)
		{
			NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_Ability", false, false);
			npc.AddActivityViaSequence("taunt05");
			npc.SetCycle(0.01);
			npc.SetPlaybackRate(1.4);
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			int POWERHomeRUN = ParticleEffectAt(pos, "utaunt_aestheticlogo_teamcolor_blue", 3.0);
			if(IsValidEntity(POWERHomeRUN))
			{
				SetVariantString("!activator");
				AcceptEntityInput(POWERHomeRUN, "SetParent", npc.index);
			}
			npc.m_flDelay_Attribute = gameTime + 0.5;
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.m_iState++;
			IncreaseEntityDamageTakenBy(npc.index, 0.7, 3.0);
		}
		else if(npc.m_iState < 23)
		{
			float ProjLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", ProjLoc);
			ProjLocBase = ProjLoc;
			ProjLocBase[2] += 5.0;
			float cpos[3];
			float velocity[3];
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEnemy(npc.index, EnemyLoop, true, true))
				{
					float vecTarget[3]; WorldSpaceCenter(EnemyLoop, vecTarget );
					float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
					if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && flDistanceToTarget < (750.0 * 750.0))
					{
						if(!HasSpecificBuff(EnemyLoop, "Solid Stance"))
						{
							GetEntPropVector(EnemyLoop, Prop_Data, "m_vecAbsOrigin", cpos);
							
							MakeVectorFromPoints(ProjLoc, cpos, velocity);
							NormalizeVector(velocity, velocity);
							ScaleVector(velocity, -450.0);
							if(b_ThisWasAnNpc[EnemyLoop])
							{
								CClotBody npc1 = view_as<CClotBody>(EnemyLoop);
								npc1.SetVelocity(velocity);
							}
							else
								TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
						}
						if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							int red = 125;
							int green = 175;
							int blue = 255;
							if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
								RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
							int laser;
							if(HasSpecificBuff(EnemyLoop, "Solid Stance"))
							{
								red = 50;
								green = 50;
								blue = 50;
							}
							
							laser = ConnectWithBeam(npc.index, EnemyLoop, red, green, blue, 3.0, 3.0, 2.35, LASERBEAM);
				
							i_LaserEntityIndex[EnemyLoop] = EntIndexToEntRef(laser);
							//Im seeing a new target, relocate laser particle.
						}
					}
					else
					{
						if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
							RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
					}
				}
				else
				{
					if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}
			}
			spawnRing_Vectors(ProjLocBase, 250.0  * 2.0, 0.0, 0.0, 5.0, LASERBEAM, 125, 175, 255, 150, 1, 0.3, 5.0, 0.1, 3);
			spawnRing_Vectors(ProjLocBase, 250.0 * 2.0, 0.0, 0.0, 25.0, LASERBEAM, 125, 175, 255, 150, 1, 0.3, 5.0, 0.1, 3);
			spawnRing_Vectors(ProjLocBase, 750.0 * 2.0, 0.0, 0.0, 0.0, LASERBEAM, 255, 255, 255, 150, 1, 0.1, 3.25, 0.1, 3);
			npc.m_flDoingAnimation = gameTime + 1.1;
			npc.m_flDelay_Attribute = gameTime + 0.5;
			npc.StopPathing();
			
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			npc.m_iState++;
		}
		else if(npc.m_flDelay_Attribute < gameTime)
		{
			float damageDealt = 75.0 * (DrinkPOWERUP[npc.index]? 1.34 : 1.0);
			if(npc.m_bFUCKYOU_move_anim)
			{
				damageDealt*2.0;
				npc.m_bFUCKYOU_move_anim=false;
			}
			KillFeed_SetKillIcon(npc.index, "bonk");
			Explode_Logic_Custom(damageDealt * RaidModeScaling, 0, npc.index, -1, ProjLocBase, 250.0 , 1.0, _, true, 20,_,_,_,SuperAttack);
			for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
			}
			if(SUPERHIT[npc.index])
			{
				npc.PlayHomerunSound();
				npc.PlayHomerunHitSound();
				npc.DispatchParticleEffect(npc.index, "mvm_soldier_shockwave", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("anim_attachment_LH"), PATTACH_POINT_FOLLOW, true);
				SUPERHIT[npc.index]=false;
			}
			else npc.PlayHomerunMissSound();
			npc.m_iState=0;
			npc.StartPathing();
			npc.m_flNextRangedAttack = gameTime + (DrinkPOWERUP[npc.index] ? 22.5 : 40.0);
		}
		return;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		int SetGoalVectorIndex = 0;
		SetGoalVectorIndex = AtomizerSelfDefense(npc,gameTime, npc.m_iTarget, flDistanceToTarget); 

		switch(SetGoalVectorIndex)
		{
			case 0:
			{
				npc.m_bAllowBackWalking = false;
				//Get the normal prediction code.
				if(flDistanceToTarget < npc.GetLeadRadius()) 
				{
					float vPredictedPos[3];
					PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
					npc.SetGoalVector(vPredictedPos);
				}
				else 
				{
					npc.SetGoalEntity(npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true); //update more often, we need it
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(npc.m_flDoingAnimation < gameTime)
	{
		AtomizerAnimationChange(npc);
	}
	npc.PlayIdleAlertSound();
}

static Action Atomizer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Atomizer npc = view_as<Atomizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);
	if(npc.m_flNiceMiss > gameTime && GetRandomInt(1,100)<=40)
	{
		damage = 0.0;
		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		if(b_BoundingBoxVariant[victim] == BBV_Giant)
		{
			chargerPos[2] += 120.0;
		}
		else
		{
			chargerPos[2] += 82.0;
		}
		/*int particle_power = ParticleEffectAt(chargerPos, "miss_text", 1.5);
		SetParent(victim, particle_power);*/
		if(IsValidClient(attacker))
		{
			TE_ParticleInt(g_particleMissText, chargerPos);
			TE_SendToClient(attacker);
		}
		OnMiss[npc.index]=true;
		ExtinguishTarget(npc.m_iWearable2);
		IgniteTargetEffect(npc.m_iWearable2);
		npc.PlayMissSound();
		return Plugin_Handled;
	}

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	Atomizer_Weapon_Lines(npc, attacker);
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.33 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.m_fbRangedSpecialOn)
		{
			npc.m_iState=0;
			npc.m_bFUCKYOU=true;
			IncreaseEntityDamageTakenBy(npc.index, 0.05, 2.9);
			npc.m_fbRangedSpecialOn = true;
			npc.m_flFTL += 5.0;
			RaidModeTime += 5.0;
			npc.m_flNextRangedAttack += 5.0;
		}
	}
	
	return Plugin_Changed;
}

static void Atomizer_NPCDeath(int entity)
{
	Atomizer npc = view_as<Atomizer>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	Vs_RechargeTime[npc.index]=0.0;
	Vs_RechargeTimeMax[npc.index]=0.0;
	
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
	if(IsValidEntity(npc.m_iWearable7))
		RemoveEntity(npc.m_iWearable7);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	
	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
	}
	
	for(int client=1; client<=MaxClients; client++)
	{
		if(IsValidClient(client) && !IsFakeClient(client))
			Vs_LockOn[client]=false;
	}

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,2))
	{
		case 0:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_EscapePlan-1", false, false);
		case 1:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_EscapePlan-2", false, false);
		case 2:NPCPritToChat(npc.index, "{blue}", "Atomizer_Talk_EscapePlan-3", false, false);
	}

}

static void AtomizerAnimationChange(Atomizer npc)
{
	if(npc.m_iChanged_WalkCycle == 0)
		npc.m_iChanged_WalkCycle = -1;
	switch(npc.i_GunMode)
	{
		case 1: //primary
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 1)
				{
				// ResetAtomizerWeapon(npc, 1);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 1;
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
				//	ResetAtomizerWeapon(npc, 1);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					npc.StartPathing();
				}	
			}
		}
		case 0: //Melee
		{
			if (npc.IsOnGround())
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
				//	ResetAtomizerWeapon(npc, 0);
					npc.m_bisWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.SetActivity("ACT_MP_RUN_MELEE");
					npc.StartPathing();
				}	
			}
			else
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
				//	ResetAtomizerWeapon(npc, 0);
					npc.m_bisWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					npc.StartPathing();
				}	
			}
		}
	}

}

static int AtomizerSelfDefense(Atomizer npc, float gameTime, int target, float distance)
{
	npc.i_GunMode = 0;

	if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
	{
		int Enemy_I_See;
		
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
		
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			npc.AddGesture("ACT_MP_GESTURE_VC_FINGERPOINT_MELEE");
			npc.NiceCatchKnucklehead();
			npc.m_flDoingAnimation = gameTime + 0.45;
			npc.m_flNextRangedSpecialAttackHappens = gameTime + (DrinkPOWERUP[npc.index] ? 15.0 : 22.5);
			npc.m_flNextRangedAttack += 1.0;
			npc.m_iMaxAmmo = (DrinkPOWERUP[npc.index] ? 30 : 20)+RoundToNearest(float(CountPlayersOnRed(2)) * 2.5);
			if(npc.m_iMaxAmmo>45)npc.m_iMaxAmmo=45;
			npc.m_iAmmo = npc.m_iMaxAmmo;
		}
	}
	else if(npc.m_flRangedSpecialDelay < gameTime)
	{
		int Enemy_I_See;
		
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
		
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			switch(npc.m_iState)
			{
				case 0:
				{
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
					IncreaseEntityDamageTakenBy(npc.index, 0.25, 1.5);
					npc.StopPathing();
					
					npc.m_flDoingAnimation = gameTime + 1.0;
					npc.m_bisWalking = false;
					npc.AddActivityViaSequence("layer_taunt04");
					npc.m_flAttackHappens = 0.0;
					npc.m_flAttackHappens_2 = gameTime + 1.4;
					npc.Anger = true;
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					EmitSoundToAll("mvm/mvm_used_powerup.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.5);
					npc.SetCycle(0.01);
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flDelay_Attribute = gameTime + 1.0;
					npc.m_iState=1;
				}
				case 1:
				{
					if(npc.m_flDelay_Attribute < gameTime)
					{
						if(IsValidEntity(npc.m_iWearable2))
							RemoveEntity(npc.m_iWearable2);
						npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
						SetVariantString("1.2");
						AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
						SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
						npc.m_flNiceMiss = gameTime + 10.0;
						if(!LastMann)Vs_Atomizer_To_Huscarls=Victoria_Melee_or_Ranged(npc);
						npc.m_iState=2;
					}
				}
				case 2:
				{
					if(IsValidEntity(npc.m_iWearable7))
						RemoveEntity(npc.m_iWearable7);
					if(!IsValidEntity(npc.m_iWearable1))
					{
						float flPos[3];
						float flAng[3];
						npc.GetAttachment("head", flPos, flAng);
						npc.m_iWearable1 = ParticleEffectAt(flPos, "scout_dodge_blue", 7.5);
						SetParent(npc.index, npc.m_iWearable1, "head");
					}
					if(!IsValidEntity(npc.m_iWearable7))
					{
						static float flPos[3]; 
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 5.0;
						npc.m_iWearable7 = ParticleEffectAt(flPos, "utaunt_tarotcard_blue_glow");
						SetParent(npc.index, npc.m_iWearable7);
					}
					npc.m_iState=0;
					npc.m_flNextRangedAttack += 3.0;
					npc.m_flRangedSpecialDelay = gameTime + (DrinkPOWERUP[npc.index] ? 20.0 : 30.0);
				}
			}
		}
	}	
	else if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			if(npc.m_iAmmo > 0)
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 40.0))
					{
						npc.m_flAttackHappens = 0.0;
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						if(IsValidEnemy(npc.index, Enemy_I_See))
						{
							npc.m_iTarget = Enemy_I_See;
							npc.PlayRangedSound();
							float RocketDamage = 20.0;
							if(OnMiss[npc.index])
							{
								RocketDamage*=1.5;
								OnMiss[npc.index]=false;
								ExtinguishTarget(npc.m_iWearable2);
							}
							if(DrinkPOWERUP[npc.index])
								RocketDamage*=1.25;
							float RocketSpeed = 1650.0;
							float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
							float VecStart[3]; WorldSpaceCenter(npc.index, VecStart );
							float vecDest[3];
							vecDest = vecTarget;
							float SpeedReturn[3];
							for(int i=1; i<=(npc.m_iAmmo > 3 ? 3 : 1); i++)
							{
								if(npc.m_iAmmo > 0)
								{
									int RocketGet = npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling, RocketSpeed, 400.0, "critical_rocket_blue", false);
									if(RocketGet != -1)
									{
										//max duration of 3 seconds
										CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
									}
									SetEntityGravity(RocketGet, 1.0);
									vecDest[0] += GetRandomFloat(-30.0, 30.0);
									vecDest[1] += GetRandomFloat(-30.0, 30.0);
									ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.0, 1.0);
									SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
									TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
									/*SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
									SDKHook(RocketGet, SDKHook_StartTouch, Atomizer_Rocket_Particle_StartTouch);*/
									WandProjectile_ApplyFunctionToEntity(RocketGet, Atomizer_Rocket_Particle_StartTouch);
									npc.m_iAmmo--;
								}
								else break;
							}
						}
					}
				}
				//No can shooty.
				//Enemy is close enough.
				if(distance < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 9.0))
				{
					if(Can_I_See_Enemy_Only(npc.index, npc.m_iTarget))
					{
						float VecAim[3]; WorldSpaceCenter(npc.m_iTarget, VecAim );
						npc.FaceTowards(VecAim, 20000.0);
						//stand
						return 1;
					}
					//cant see enemy somewhy.
					return 0;
				}
				else //enemy is too far away.
				{
					return 0;
				}
			}
			else
			{
				npc.m_flAttackHappens = 0.0;
			
				if(IsValidEnemy(npc.index, target))
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
								int targetTrace = i_EntitiesHitAoeSwing_NpcSwing[counter];
								float vecHit[3];
								
								WorldSpaceCenter(targetTrace, vecHit);

								float damage = 25.0;
								if(OnMiss[npc.index])
								{
									damage*=1.5;
									OnMiss[npc.index]=false;
									ExtinguishTarget(npc.m_iWearable2);
								}
								if(DrinkPOWERUP[npc.index])
									damage*=1.25;
								if(ShouldNpcDealBonusDamage(target))
									damage *= 7.0;
								KillFeed_SetKillIcon(npc.index, "atomizer");
								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
								
								bool Knocked = false;
								
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace) && !HasSpecificBuff(targetTrace, "Solid Stance"))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 600.0, true);
									}
									if(!HasSpecificBuff(targetTrace, "Fluid Movement"))
									{
										TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.4);
										TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.4);
									}
								}
								
								if(!Knocked && !HasSpecificBuff(targetTrace, "Solid Stance"))
									Custom_Knockback(npc.index, targetTrace, 300.0, true); 
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
				}
			}
		}
	}
	//Melee attack, last prio
	else if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, target)) 
		{
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 40.0) && npc.m_iAmmo > 0)
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_SECONDARY");
					
					float time = 0.125;
					if(NpcStats_VictorianCallToArms(npc.index))
					{
						time *= 0.5;
					}
					npc.m_flAttackHappens = gameTime + time;
					npc.m_flNextMeleeAttack = gameTime + time;
					npc.m_flDoingAnimation = gameTime + time;
				}
			}
			else if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					target = Enemy_I_See;

					npc.PlayMeleeSound();
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;
					npc.m_flNextMeleeAttack = gameTime + 0.5;
					npc.m_flDoingAnimation = gameTime + 0.25;
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
	return 0;
}

static void SuperAttack(int entity, int victim, float damage, int weapon)
{
	Atomizer npc = view_as<Atomizer>(entity);
	if(IsValidEntity(victim))
	{
		if(!HasSpecificBuff(victim, "Solid Stance"))
		{
			float vecHit[3]; WorldSpaceCenter(victim, vecHit);
			Custom_Knockback(npc.index, victim, DrinkPOWERUP[npc.index] ? 2200.0 : 1980.0, true, true, true);
		}
		SUPERHIT[npc.index]=true;
	}
}
/*
static Action Atomizer_Rocket_Particle_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];
		KillFeed_SetKillIcon(owner, "ball");
		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		if(target <= MaxClients && !IsInvuln(target))
			if(!HasSpecificBuff(target, "Fluid Movement"))
				TF2_StunPlayer(target, 2.0, 0.4, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);
		ApplyStatusEffect(owner, target, "Teslar Shock", NpcStats_VictorianCallToArms(owner) ? 7.5 : 5.0);
	}
	int particle = EntRefToEntIndex(i_WandParticle[entity]);
	if(IsValidEntity(particle))
		RemoveEntity(particle);
	RemoveEntity(entity);
	return Plugin_Handled;
}
*/
static Action Atomizer_Rocket_Particle_StartTouch(int entity, int target)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
		owner = 0;
	if(target > 0 && target < MAXENTITIES)    //did we hit something???
	{
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

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);    //acts like a kinetic rocket    
		if(target <= MaxClients && !IsInvuln(target))
			if(!HasSpecificBuff(target, "Fluid Movement"))
				TF2_StunPlayer(target, 2.0, 0.4, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);

		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else
	{
		if(IsValidEntity(entity))
		{
			int GETBOUNS = GetEntProp(entity, Prop_Data, "m_iHammerID");
			if(GETBOUNS < 20)
			{
				static float vOrigin[3], vVelocity[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
				GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vVelocity);
				
				float TempANG[3], tOrigin[3];
				TempANG[0]=90.0;
				EntityLookPoint(entity, TempANG, vOrigin, tOrigin);
				float distance = GetVectorDistance(vOrigin, tOrigin);
				if(distance<65.0)
					vVelocity[2] = 600.0;
				else
				{
					TempANG[0]=-90.0;
					EntityLookPoint(entity, TempANG, vOrigin, tOrigin);
					distance = GetVectorDistance(vOrigin, tOrigin);
					if(distance<65.0)
						vVelocity[2] = -600.0;
				}
				int E_Target = GetClosestTarget(entity);
				float VecStart[3]; WorldSpaceCenter(entity, VecStart);
				if(IsValidEnemy(owner, E_Target))
				{
					float vecDest[3]; WorldSpaceCenter(E_Target, vecDest);
					float SpeedReturn[3];
					PredictSubjectPositionForProjectiles(view_as<Atomizer>(entity), E_Target, 400.0,_,vecDest);
					vecDest[0] += GetRandomFloat(-30.0, 30.0);
					vecDest[1] += GetRandomFloat(-30.0, 30.0);
					ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.25, 1.0);
			//   TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
						
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(entity));
					pack.WriteFloat(SpeedReturn[0]);
					pack.WriteFloat(SpeedReturn[1]);
					pack.WriteFloat(SpeedReturn[2]);
					RequestFrames(SetVelocityAtomizerProjectile, 1, pack);
					SetEntProp(entity, Prop_Data, "m_iHammerID", GETBOUNS+1);
				}
				else
				{
					TeleportEntity(entity, NULL_VECTOR, TempANG, NULL_VECTOR);
					
					DataPack pack = new DataPack();
					pack.WriteCell(EntIndexToEntRef(entity));
					pack.WriteFloat(vVelocity[0]);
					pack.WriteFloat(vVelocity[1]);
					pack.WriteFloat(vVelocity[2]);
					RequestFrames(SetVelocityAtomizerProjectile, 1, pack);
				}
				return Plugin_Handled;
			}
		}
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}

//delay velocity setting for upwards movement or else it wont work in that call.
//└ wow.. artvin so genius.. gg My code is a mess - baka
stock void SetVelocityAtomizerProjectile(DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(!IsValidEntity(entity))
	{
		delete pack;
		return;
	}
	float vel[3];
	vel[0] = pack.ReadFloat();
	vel[1] = pack.ReadFloat();
	vel[2] = pack.ReadFloat();
	delete pack;
	Custom_SetAbsVelocity(entity, vel);	

}
static bool ONLYBSP(int entity, int contentsMask, any data)
{
	return !entity;
}

static int Victoria_Melee_or_Ranged(Atomizer npc)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy[MAXENTITIES];
	GetHighDefTargets(npcGetInfo, enemy, sizeof(enemy));
	float SelfLocation[3]; WorldSpaceCenter(npc.index, SelfLocation);
	int MeleeS,RangedS;
	for(int i; i < sizeof(enemy); i++)
	{
		static float EntityLocation[3]; WorldSpaceCenter(enemy[i], EntityLocation);
		float distance = GetVectorDistance(SelfLocation, EntityLocation, true); 
		if(distance <= (500.0 * 500.0))
			MeleeS++;
		else
			RangedS++;
	}
	if(MeleeS==RangedS)
		return 0;
	if(MeleeS>RangedS)
		return 1;
	else
		return 2;
}

public bool EntityLookPoint(int entity, float flAng[3], float flPos[3], float pos[3])
{
	Handle trace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, ONLYBSP, entity);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		return true;
	}
	CloseHandle(trace);
	return false;
}

static void Atomizer_Weapon_Lines(Atomizer npc, int client)
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
		/*case WEAPON_SEABORNMELEE: switch(GetRandomInt(0,3)){
			case 0: Format(Text_Lines, sizeof(Text_Lines), "Damn it! {darkblue}Seaborn{default} is here Again!");
			case 1: Format(Text_Lines, sizeof(Text_Lines), "ha. {darkblue}Seaborn{default}!?");
			case 2: Format(Text_Lines, sizeof(Text_Lines), "I found an {darkblue}Infected{default} person, I need a Backup!");
			case 3: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{default}? I knew it, you {darkblue}Seaborn{default} Bastard!", client);}
		case WEAPON_EXPLORER: switch(GetRandomInt(0,2)){
			case 0: Format(Text_Lines, sizeof(Text_Lines), "{purple}Void{default}...");
			case 1: Format(Text_Lines, sizeof(Text_Lines), "HQ? There's a serious problem. He's using the {purple}Void{default}.");
			case 2: Format(Text_Lines, sizeof(Text_Lines), "{gold}%N{default}, You're going to pay a price for bringing {purple}Void{default} into Victoria!", client);}*/
		default:
		{
			valid = false;
		}
	}

	if(valid)
	{
		NPCPritToChat(npc.index, "{blue}", Text_Lines, false, false);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}

/* Victoria Nuke */
static bool Victoria_Support(Atomizer npc)
{
	float GameTime = GetGameTime();
	if(Vs_DelayTime[npc.index] > GameTime)
		return false;
	Vs_DelayTime[npc.index] = GameTime + 0.1;
	
	Vs_Target[npc.index] = Victoria_GetTargetDistance(npc.index, true, false);
	if(!IsValidEnemy(npc.index, Vs_Target[npc.index]))
		return false;
	if(Vs_RechargeTime[npc.index] >= 1.0 && Vs_RechargeTime[npc.index] <= 3.0 && IsValidEntity(Vs_ParticleSpawned[npc.index]))
		RemoveEntity(Vs_ParticleSpawned[npc.index]);
	Vs_RechargeTime[npc.index] += 0.1;
	if(Vs_RechargeTime[npc.index]>(Vs_RechargeTimeMax[npc.index]+1.0))
		Vs_RechargeTime[npc.index]=0.0;
	
	float vecTarget[3];
	GetEntPropVector(Vs_Target[npc.index], Prop_Data, "m_vecAbsOrigin", vecTarget);
	vecTarget[2] += 5.0;
	
	if(Vs_RechargeTime[npc.index] < Vs_RechargeTimeMax[npc.index])
	{
		float position[3];
		position[0] = vecTarget[0];
		position[1] = vecTarget[1];
		position[2] = vecTarget[2] + 3000.0;
		if(Vs_RechargeTime[npc.index] < (Vs_RechargeTimeMax[npc.index] - 3.0))
		{
			Vs_Temp_Pos[npc.index][0] = position[0];
			Vs_Temp_Pos[npc.index][1] = position[1];
			Vs_Temp_Pos[npc.index][2] = position[2] - 3000.0;
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client) && !IsFakeClient(client))
					Vs_LockOn[client]=false;
			}
			Vs_LockOn[Vs_Target[npc.index]]=true;
		}
		else
		{
			for(int client=1; client<=MaxClients; client++)
			{
				if(IsValidClient(client) && !IsFakeClient(client))
					Vs_LockOn[client]=false;
			}
		}
		spawnRing_Vectors(Vs_Temp_Pos[npc.index], (1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0)), 0.0, 0.0, 0.0, LASERBEAM, 255, 255, 255, 150, 1, 0.1, 3.0, 0.1, 3);
		float position2[3];
		position2[0] = Vs_Temp_Pos[npc.index][0];
		position2[1] = Vs_Temp_Pos[npc.index][1];
		position2[2] = Vs_Temp_Pos[npc.index][2] + 40.0;
		spawnRing_Vectors(position2, 1000.0, 0.0, 0.0, 0.0, LASERBEAM, 255, 200, 80, 150, 1, 0.1, 3.0, 0.1, 3);
		spawnRing_Vectors(Vs_Temp_Pos[npc.index], 1000.0, 0.0, 0.0, 0.0, LASERBEAM, 255, 200, 80, 150, 1, 0.1, 3.0, 0.1, 3);
		TE_SetupBeamPoints(Vs_Temp_Pos[npc.index], position, g_Laser, -1, 0, 0, 0.1, 0.0, 25.0, 0, 0.0, {145, 47, 47, 150}, 3);
		TE_SendToAll();
		TE_SetupGlowSprite(Vs_Temp_Pos[npc.index], g_RedPoint, 0.1, 1.0, 255);
		TE_SendToAll();
		if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0) && !IsValidEntity(Vs_ParticleSpawned[npc.index]))
		{
			Vs_ParticleSpawned[npc.index] = EntIndexToEntRef(ParticleEffectAt(position, "kartimpacttrail", 2.0));
			SetEdictFlags(Vs_ParticleSpawned[npc.index], (GetEdictFlags(Vs_ParticleSpawned[npc.index]) | FL_EDICT_ALWAYS));
			SetEntProp(Vs_ParticleSpawned[npc.index], Prop_Data, "m_iHammerID", npc.index);
			npc.PlayIncomingBoomSound();
		}
	}
	else if(IsValidEntity(Vs_ParticleSpawned[npc.index]))
	{
		float position[3];
		position[0] = Vs_Temp_Pos[npc.index][0];
		position[1] = Vs_Temp_Pos[npc.index][1];
		position[2] = Vs_Temp_Pos[npc.index][2] - 700.0;
		TeleportEntity(EntRefToEntIndex(Vs_ParticleSpawned[npc.index]), position, NULL_VECTOR, NULL_VECTOR);
		position[2] += 700.0;
		
		i_ExplosiveProjectileHexArray[npc.index] = EP_DEALS_TRUE_DAMAGE;
		KillFeed_SetKillIcon(npc.index, "megaton");
		Explode_Logic_Custom(125.0*RaidModeScaling, 0, npc.index, -1, position, 500.0, 1.0, _, true, 20);
		
		ParticleEffectAt(position, "hightower_explosion", 1.0);
		i_ExplosiveProjectileHexArray[npc.index] = 0; 
		npc.PlayBoomSound();
		Vs_RechargeTime[npc.index]=0.0;
		Vs_RechargeTime[npc.index]=0.0;
		return true;
	}
	return false;
}

void Victoria_Support_RechargeTimeMax(int entity, float MAXTime=20.0)
{
	Vs_RechargeTimeMax[entity]=MAXTime;
}

int Victoria_Support_RechargeTime(int entity)
{
	if(Vs_RechargeTime[entity] <= 0.0 || Vs_RechargeTimeMax[entity]<=0.0)
		return 0;
	return RoundToFloor((Vs_RechargeTime[entity]/Vs_RechargeTimeMax[entity])*100.0);
}

stock int Victoria_GetTargetDistance(int entity, bool inversion, bool ICantSEE)
{
	float TargetDistance = 0.0, EntityLocation[3];
	int ClosestTarget = 0;
	WorldSpaceCenter(entity, EntityLocation);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i) && TeutonType[i] == TEUTON_NONE &&((ICantSEE && Can_I_See_Enemy(entity, i)) || !ICantSEE))
		{
			float TargetLocation[3];
			WorldSpaceCenter(i, TargetLocation);
			float distance = GetVectorDistance(EntityLocation, TargetLocation);
			if(GetTeam(entity) != GetTeam(i) && i != entity && IsValidEnemy(entity, i))
			{
				if(TargetDistance)
				{
					if(!inversion && distance < TargetDistance)
					{
						ClosestTarget = i;
						TargetDistance = distance;			
					}
					else if(inversion && distance > TargetDistance)
					{
						ClosestTarget = i;
						TargetDistance = distance;			
					}
				}
				else
				{
					ClosestTarget = i;
					TargetDistance = distance;
				}
			}
		}
	}
	return ClosestTarget;
}