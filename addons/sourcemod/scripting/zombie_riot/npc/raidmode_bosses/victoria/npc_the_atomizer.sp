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
static const char g_MeleeHitSounds[] = "weapons/bat_hit.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/scout_revenge06.mp3";
static const char g_HomerunHitSounds[] = "mvm/melee_impacts/bat_baseball_hit_robo01.wav";
static const char g_SupportSounds[] = "vo/scout_revenge05.mp3";
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
static const char StunballPickupeSound[][] = {
	"vo/scout_stunballpickup01.mp3",
	"vo/scout_stunballpickup02.mp3",
	"vo/scout_stunballpickup03.mp3",
	"vo/scout_stunballpickup04.mp3",
	"vo/scout_stunballpickup05.mp3"
};
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";

static float Vs_DelayTime[MAXENTITIES];
float Vs_RechargeTime[MAXENTITIES];
float Vs_RechargeTimeMax[MAXENTITIES];
static int Vs_Target[MAXENTITIES];
static int Vs_ParticleSpawned[MAXENTITIES];
static float Vs_Temp_Pos[MAXENTITIES][3];
bool Vs_LockOn[MAXTF2PLAYERS];
int Vs_Atomizer_To_Huscarls;

static float FTL[MAXENTITIES];
static float Delay_Attribute[MAXENTITIES];
static bool DrinkPOWERUP[MAXENTITIES];
static float NiceMiss[MAXENTITIES];
static bool OnMiss[MAXENTITIES];
static int I_cant_do_this_all_day[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static bool YaWeFxxked[MAXENTITIES];
static bool ParticleSpawned[MAXENTITIES];
static bool b_said_player_weaponline[MAXTF2PLAYERS];
static float fl_said_player_weaponline_time[MAXENTITIES];
static bool SUPERHIT[MAXENTITIES];

static int gLaser1;
static int gRedPoint;
static int g_BeamIndex_heal;
static int g_HALO_Laser;

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
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds)); i++) { PrecacheSound(g_RangedAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_HomerunHitSounds);
	PrecacheSound(g_SupportSounds);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	gRedPoint = PrecacheModel("sprites/redglow1.vmt");
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	g_BeamIndex_heal = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_HALO_Laser = PrecacheModel("materials/sprites/halo01.vmt", true);
	for (int i = 0; i < (sizeof(g_HomerunSounds));   i++) { PrecacheSound(g_HomerunSounds[i]);   }
	for (int i = 0; i < (sizeof(StunballPickupeSound));   i++) { PrecacheSound(StunballPickupeSound[i]);   }
	for (int i = 0; i < (sizeof(g_MissAbilitySound));   i++) { PrecacheSound(g_MissAbilitySound[i]);   }
	for (int i = 0; i < (sizeof(g_HomerunfailSounds));   i++) { PrecacheSound(g_HomerunfailSounds[i]);   }
	PrecacheModel("models/player/scout.mdl");
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_atomizer.mp3");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Atomizer(client, vecPos, vecAng, ally, data);
}

static int i_atomizer_eye_particle[MAXENTITIES];

methodmap Atomizer < CClotBody
{
	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void NiceCatchKnucklehead() {
		EmitSoundToAll(StunballPickupeSound[GetRandomInt(0, sizeof(StunballPickupeSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	public void PlayIdleAlertSound(){
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
	
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	public void PlayBoomSound(){
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound(){
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
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
	public Atomizer(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Atomizer npc = view_as<Atomizer>(CClotBody(vecPos, vecAng, "models/player/scout.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
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

		bool CloneDo = StrContains(data, "support_ability") != -1;
		if(CloneDo)
		{
			func_NPCDeath[npc.index] = view_as<Function>(Clone_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Clone_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Clone_ClotThink);
			
			MakeObjectIntangeable(npc.index);
			b_DoNotUnStuck[npc.index] = true;
			b_NoKnockbackFromSources[npc.index] = true;
			b_ThisEntityIgnored[npc.index] = true;
			b_NoKillFeed[npc.index] = true;
			npc.m_flNextRangedAttack = GetGameTime() + 0.1;
			npc.m_flRangedSpecialDelay = GetGameTime() + 99.0;
			npc.m_flNextRangedSpecialAttackHappens = GetGameTime() + 99.0;
			npc.m_flAngerDelay = GetGameTime() + 99.0;
			npc.PlaySupportSpawnSound();
			CPrintToChatAll("{blue}Atomizer{default}: Did you really think we would let you sabotage our Radiotower?");
		}
		else
		{
			RemoveAllDamageAddition();
			func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
			func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
			func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);
			//IDLE
			NPC_StartPathing(npc.index);
			npc.m_iState = 0;
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_flSpeed = 300.0;
			Delay_Attribute[npc.index] = 0.0;
			DrinkPOWERUP[npc.index] = false;
			YaWeFxxked[npc.index] = false;
			ParticleSpawned[npc.index] = false;
			SUPERHIT[npc.index] = false;
			NiceMiss[npc.index] = 0.0;
			Vs_Atomizer_To_Huscarls = 0;
			I_cant_do_this_all_day[npc.index] = 0;
			npc.i_GunMode = 0;
			npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 15.0;
			npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 5.0;
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 30.0;
			npc.m_flAngerDelay = GetGameTime(npc.index) + 15.0;
			npc.m_iOverlordComboAttack = 0;
			OnMiss[npc.index] = false;
			npc.m_fbRangedSpecialOn = false;
			npc.m_bFUCKYOU = false;
			Zero(b_said_player_weaponline);
			fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
			Vs_RechargeTimeMax[npc.index] = 20.0;
			Victoria_Support_RechargeTimeMax(npc.index, 20.0);
			
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
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
			FTL[npc.index] = 200.0;
			RaidModeTime = GetGameTime(npc.index) + FTL[npc.index];
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = false;

			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_atomizer.mp3");
			music.Time = 128;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Hard to Ignore");
			strcopy(music.Artist, sizeof(music.Artist), "UNFINISH");
			Music_SetRaidMusic(music);
			
			CPrintToChatAll("{blue}Atomizer{default}: Intruders in sight, I won't let them get out alive!");
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
				RaidModeScaling = float(Waves_GetRound()+1);
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
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
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
	
	float ProjLocBase[3];
	if(I_cant_do_this_all_day[npc.index] <= 0)
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
		Delay_Attribute[npc.index] = gameTime + 0.5;
		npc.StopPathing();
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		I_cant_do_this_all_day[npc.index]++;
	}
	else if(I_cant_do_this_all_day[npc.index] < 23)
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
				if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop))
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
					{	
						TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
					}
					if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
					{
						int red = 125;
						int green = 175;
						int blue = 255;
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
		IncreaceEntityDamageTakenBy(npc.index, 0.7, 0.1);
		spawnRing_Vectors(ProjLocBase, 250.0  * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
		spawnRing_Vectors(ProjLocBase, 250.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
		npc.m_flDoingAnimation = gameTime + 1.1;
		Delay_Attribute[npc.index] = gameTime + 0.5;
		npc.StopPathing();
		npc.m_bPathing = false;
		npc.m_bisWalking = false;
		npc.m_iChanged_WalkCycle = 0;
		I_cant_do_this_all_day[npc.index]++;
	}
	else if(Delay_Attribute[npc.index] < gameTime)
	{
		float damageDealt = 50.0 * RaidModeScaling;
		Explode_Logic_Custom(damageDealt, 0, npc.index, -1, ProjLocBase, 250.0 , 1.0, _, true, 20,_,_,_,SuperAttack);
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
		I_cant_do_this_all_day[npc.index]=0;
		
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

static void Internal_ClotThink(int iNPC)
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
		i_atomizer_eye_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}
	if(NiceMiss[npc.index] < gameTime)
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
					CPrintToChatAll("{blue}Atomizer{default}: Ready to die?");
				}
				case 1:
				{
					CPrintToChatAll("{blue}Atomizer{default}: You can't run forever.");
				}
				case 2:
				{
					CPrintToChatAll("{blue}Atomizer{default}: All of your comrades are fallen.");
				}
			}
		}
	}
	if(i_RaidGrantExtra[npc.index] == RAIDITEM_INDEX_WIN_COND)
	{
		DeleteAndRemoveAllNpcs = 3.0;
		npc.m_bisWalking = false;
		npc.AddActivityViaSequence("taunt_peace_out");
		npc.SetCycle(0.01);
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		BlockLoseSay = true;
		
		CPrintToChatAll("{blue}Atomizer{default}: Mission Accomplished, we will figure out who is behind them");
		return;
	}
	npc.m_flSpeed = 300.0+(((FTL[npc.index]-(RaidModeTime - GetGameTime()))/FTL[npc.index])*150.0);
	if(RaidModeTime < GetGameTime() && !YaWeFxxked[npc.index] && GetTeam(npc.index) != TFTeam_Red)
	{
		npc.m_flMeleeArmor = 0.3696;
		npc.m_flRangedArmor = 0.33;
		int MaxHealth = RoundToCeil(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")*1.25);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", MaxHealth);
		SetEntProp(npc.index, Prop_Data, "m_iMaxHealth", MaxHealth);
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{blue}Atomizer{default}: Victoria will be in peace. Once and for all.");
			case 2:CPrintToChatAll("{blue}Atomizer{default}: The troops have arrived and will begin destroying the intruders!");
			case 3:CPrintToChatAll("{blue}Atomizer{default}: Backup team has arrived. Catch those damn bastards!");
			case 4:CPrintToChatAll("{blue}Atomizer{default}: After this, Im heading to Rusted Bolt Pub. {unique}I need beer.{default}");
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
		switch(I_cant_do_this_all_day[npc.index])
		{
			case 0:
			{
				CPrintToChatAll("{blue}Atomizer{default}: Not Enough Energy! Nitro Fuel going in!");
				if(IsValidEntity(npc.m_iWearable2))
					RemoveEntity(npc.m_iWearable2);
				npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/taunt_cheers/taunt_cheers_pyro.mdl");
				SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_bisWalking = false;
				npc.AddActivityViaSequence("layer_taunt_cheers_scout");
				npc.m_flAttackHappens = 0.0;
				npc.SetCycle(0.01);
				npc.SetPlaybackRate(2.0);
				npc.m_iChanged_WalkCycle = 0;
				npc.m_flDoingAnimation = gameTime + 1.5;	
				Delay_Attribute[npc.index] = gameTime + 1.4;
				I_cant_do_this_all_day[npc.index]=1;
				if(!LastMann)Vs_Atomizer_To_Huscarls=Victoria_Melee_or_Ranged(npc);
			}
			case 1:
			{
				if(Delay_Attribute[npc.index] < gameTime)
				{
					EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.9);
					EmitSoundToAll("player/pl_scout_dodge_can_drink.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.9);
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bisWalking = false;
					npc.m_flDoingAnimation = gameTime + 1.5;	
					Delay_Attribute[npc.index] = gameTime + 0.6;
					I_cant_do_this_all_day[npc.index]=2;
				}
			}
			case 2:
			{
				if(Delay_Attribute[npc.index] < gameTime)
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
					CPrintToChatAll("{blue}Atomizer{default}: Oh yes! I FEEL ALIVE!");
					I_cant_do_this_all_day[npc.index]=0;
					npc.m_flNextRangedAttack += 2.0;
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
		float ProjLocBase[3];
		if(I_cant_do_this_all_day[npc.index] <= 0)
		{
			CPrintToChatAll("{blue}Atomizer{default}: Ready to fly?");
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
			Delay_Attribute[npc.index] = gameTime + 0.5;
			npc.StopPathing();
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
			I_cant_do_this_all_day[npc.index]++;
		}
		else if(I_cant_do_this_all_day[npc.index] < 23)
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
					float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc);
					if(Can_I_See_Enemy_Only(npc.index, EnemyLoop) && IsEntityAlive(EnemyLoop) && flDistanceToTarget < 750.0)
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
						{	
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);
						}
						if(!IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
						{
							int red = 125;
							int green = 175;
							int blue = 255;
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
			IncreaceEntityDamageTakenBy(npc.index, 0.7, 0.1);
			spawnRing_Vectors(ProjLocBase, 250.0  * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
			spawnRing_Vectors(ProjLocBase, 250.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", 125, 175, 255, 150, 1, 0.3, 5.0, 8.0, 3);	
			npc.m_flDoingAnimation = gameTime + 1.1;
			Delay_Attribute[npc.index] = gameTime + 0.5;
			npc.StopPathing();
			npc.m_bPathing = false;
			npc.m_bisWalking = false;
			npc.m_iChanged_WalkCycle = 0;
			I_cant_do_this_all_day[npc.index]++;
		}
		else if(Delay_Attribute[npc.index] < gameTime)
		{
			float damageDealt = 50.0 * RaidModeScaling;
			Explode_Logic_Custom(damageDealt, 0, npc.index, -1, ProjLocBase, 250.0 , 1.0, _, true, 20,_,_,_,SuperAttack);
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
			I_cant_do_this_all_day[npc.index]=0;
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
					NPC_SetGoalVector(npc.index, vPredictedPos);
				}
				else 
				{
					NPC_SetGoalEntity(npc.index, npc.m_iTarget);
				}
			}
			case 1:
			{
				npc.m_bAllowBackWalking = true;
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true); //update more often, we need it
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

static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Atomizer npc = view_as<Atomizer>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);
	if(NiceMiss[npc.index] > gameTime && GetRandomInt(1,100)<=40)
	{
		damage = 0.0;
		float chargerPos[3];
		GetEntPropVector(victim, Prop_Data, "m_vecAbsOrigin", chargerPos);
		if(b_BoundingBoxVariant[victim] == 1)
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
			I_cant_do_this_all_day[npc.index]=0;
			npc.m_bFUCKYOU=true;
			IncreaceEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			FTL[npc.index] += 5.0;
			RaidModeTime += 5.0;
			npc.m_flNextRangedAttack += 5.0;
		}
	}
	
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Atomizer npc = view_as<Atomizer>(entity);
	/*
		Explode on death code here please

	*/
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

	int particle = EntRefToEntIndex(i_atomizer_eye_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_atomizer_eye_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
	
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
		case 0:CPrintToChatAll("{blue}Atomizer{default}: Ugh, I need backup");
		case 1:CPrintToChatAll("{blue}Atomizer{default}: I will never let you trample over the glory of {gold}Victoria{default} Again!");
		case 2:CPrintToChatAll("{blue}Atomizer{default}: You intruders will soon face the {crimson}Real Deal.{default}");
	}

}

void AtomizerAnimationChange(Atomizer npc)
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

int AtomizerSelfDefense(Atomizer npc, float gameTime, int target, float distance)
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
			npc.m_iOverlordComboAttack =  RoundToNearest(float(CountPlayersOnRed(2)) * 2.5); 
		}
	}
	else if(npc.m_flRangedSpecialDelay < gameTime)
	{
		int Enemy_I_See;
									
		Enemy_I_See = Can_I_See_Enemy(npc.index, target);
						
		if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
		{
			switch(I_cant_do_this_all_day[npc.index])
			{
				case 0:
				{
					if(IsValidEntity(npc.m_iWearable2))
						RemoveEntity(npc.m_iWearable2);
					npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_energy_drink/c_energy_drink.mdl");
					SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
				
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
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
					Delay_Attribute[npc.index] = gameTime + 1.0;
					I_cant_do_this_all_day[npc.index]=1;
				}
				case 1:
				{
					if(Delay_Attribute[npc.index] < gameTime)
					{
						if(IsValidEntity(npc.m_iWearable2))
							RemoveEntity(npc.m_iWearable2);
						npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_bonk_bat/c_bonk_bat.mdl");
						SetVariantString("1.2");
						AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
						SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
						NiceMiss[npc.index] = gameTime + 10.0;
						if(!LastMann)Vs_Atomizer_To_Huscarls=Victoria_Melee_or_Ranged(npc);
						I_cant_do_this_all_day[npc.index]=2;
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
						npc.GetAttachment("effect_hand_r", flPos, flAng);
						npc.m_iWearable7 = ParticleEffectAt_Parent(flPos, "eb_projectile_core01", npc.index, "effect_hand_r", {0.0,0.0,0.0});
					}
					if(!IsValidEntity(npc.m_iWearable7))
					{
						static float flPos[3]; 
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
						flPos[2] += 5.0;
						npc.m_iWearable7 = ParticleEffectAt(flPos, "utaunt_tarotcard_blue_glow");
						SetParent(npc.index, npc.m_iWearable7);
					}
					I_cant_do_this_all_day[npc.index]=0;
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
			if(npc.m_iOverlordComboAttack > 0)
			{
				if(gameTime > npc.m_flNextMeleeAttack)
				{
					if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0))
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
							for(int i=1; i<=(npc.m_iOverlordComboAttack > 3 ? 3 : 1); i++)
							{
								if(npc.m_iOverlordComboAttack > 0)
								{
									int RocketGet = npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling, RocketSpeed, 400.0, "critical_rocket_blue", false);
									if(RocketGet != -1)
									{
										//max duration of 2 seconds
										CreateTimer(3.0, Timer_RemoveEntity, EntIndexToEntRef(RocketGet), TIMER_FLAG_NO_MAPCHANGE);
									}
									SetEntityGravity(RocketGet, 1.0);
									vecDest[0] += GetRandomFloat(-30.0, 30.0);
									vecDest[1] += GetRandomFloat(-30.0, 30.0);
									ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.0, 1.0);
									SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
									TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
									SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
									SDKHook(RocketGet, SDKHook_StartTouch, Atomizer_Rocket_Particle_StartTouch);
									npc.m_iOverlordComboAttack-=1;
								}
								else break;
							}
							
							/*if(!IsSpaceOccupiedWorldOnly(VecStart, view_as<float>( { -35.0, -35.0, 17.0 } ), view_as<float>( { 35.0, 35.0, 500.0 } ), npc.index))
							{
								float SpeedReturn[3];
								for(int i=1; i<=3; i++)
								{
									if(npc.m_iOverlordComboAttack > 0)
									{
										int RocketGet = npc.FireParticleRocket(vecDest, RocketDamage * RaidModeScaling, RocketSpeed, 400.0, "critical_rocket_blue", false);
										SetEntityGravity(RocketGet, 1.0); 	
										ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.0, 1.0);
										SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
										TeleportEntity(RocketGet, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
										SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
										SDKHook(RocketGet, SDKHook_StartTouch, Atomizer_Rocket_Particle_StartTouch);
										npc.m_iOverlordComboAttack --;
									}
									else break;
								}
							}
							else
							{
								RocketSpeed *= 0.75;
								for(int i=1; i<=3; i++)
								{
									if(npc.m_iOverlordComboAttack > 0)
									{
										int RocketGet = npc.FireParticleRocket(vecTarget, RocketDamage * RaidModeScaling, RocketSpeed, 100.0, "critical_rocket_blue", false);
										SetEntityGravity(RocketGet, 1.0);
										SetEntityMoveType(RocketGet, MOVETYPE_FLYGRAVITY);
										SDKUnhook(RocketGet, SDKHook_StartTouch, Rocket_Particle_StartTouch);
										SDKHook(RocketGet, SDKHook_StartTouch, Atomizer_Rocket_Particle_StartTouch);
										npc.m_iOverlordComboAttack --;
									}
									else break;
								}
							}*/
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

								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);								
									
								
								// Hit particle
								
							
								
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 300.0, true);
										if(!NpcStats_IsEnemySilenced(npc.index))
										{
											TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
											TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
										}
									}
									else
									{
										if(!NpcStats_IsEnemySilenced(npc.index))
										{
											TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.25);
											TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.25);
										}
									}
								}
											
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 150.0, true); 
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
			if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 25.0) && npc.m_iOverlordComboAttack > 0)
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
		float vecHit[3]; WorldSpaceCenter(victim, vecHit);
		Custom_Knockback(npc.index, victim, DrinkPOWERUP[npc.index] ? 2200.0 : 1980.0, true, true, true);
		SUPERHIT[npc.index]=true;
	}
}

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
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);	//acts like a kinetic rocket	
		if(!IsInvuln(target))
			if(!HasSpecificBuff(target, "Fluid Movement"))
				TF2_StunPlayer(target, 2.0, 0.4, TF_STUNFLAG_NOSOUNDOREFFECT|TF_STUNFLAG_SLOWDOWN);

		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
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
				TeleportEntity(entity, NULL_VECTOR, TempANG, vVelocity);
				float VecStart[3]; WorldSpaceCenter(entity, VecStart);
				if(IsValidEnemy(owner, E_Target))
				{
					float vecDest[3]; WorldSpaceCenter(E_Target, vecDest);
					float SpeedReturn[3];
					PredictSubjectPositionForProjectiles(view_as<Atomizer>(entity), E_Target, 400.0,_,vecDest);
					vecDest[0] += GetRandomFloat(-30.0, 30.0);
					vecDest[1] += GetRandomFloat(-30.0, 30.0);
					ArcToLocationViaSpeedProjectile(VecStart, vecDest, SpeedReturn, 1.25, 1.0);
					TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, SpeedReturn);
					SetEntProp(entity, Prop_Data, "m_iHammerID", GETBOUNS+1);
				}
				return Plugin_Handled;
			}
		}
		int particle = EntRefToEntIndex(i_rocket_particle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	RemoveEntity(entity);
	return Plugin_Handled;
}

static bool ONLYBSP(int entity, int contentsMask, any data)
{
	if(entity == data)
		return false;

	if(1 <= entity <= MaxClients)
		return false;

	return true;
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
		CPrintToChatAll("{blue}Atomizer{default}: %s", Text_Lines);
		fl_said_player_weaponline_time[npc.index] = GameTime + GetRandomFloat(17.0, 26.0);
		b_said_player_weaponline[client] = true;
	}
}

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
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0), (1000.0 - ((Vs_RechargeTime[npc.index]/Vs_RechargeTimeMax[npc.index])*1000.0))+0.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {255, 255, 255, 150}, 0, 0);
		TE_SendToAll();
		float position2[3];
		position2[0] = Vs_Temp_Pos[npc.index][0];
		position2[1] = Vs_Temp_Pos[npc.index][1];
		position2[2] = Vs_Temp_Pos[npc.index][2] + 65.0;
		TE_SetupBeamRingPoint(position2, 1000.0, 1000.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(Vs_Temp_Pos[npc.index], 1000.0, 1000.5, g_BeamIndex_heal, g_HALO_Laser, 0, 5, 0.1, 1.0, 1.0, {145, 47, 47, 150}, 0, 0);
		TE_SendToAll();
		TE_SetupBeamPoints(Vs_Temp_Pos[npc.index], position, gLaser1, -1, 0, 0, 0.1, 0.0, 25.0, 0, 1.0, {145, 47, 47, 150}, 3);
		TE_SendToAll();
		TE_SetupGlowSprite(Vs_Temp_Pos[npc.index], gRedPoint, 0.1, 1.0, 255);
		TE_SendToAll();
		if(Vs_RechargeTime[npc.index] > (Vs_RechargeTimeMax[npc.index] - 1.0) && !IsValidEntity(Vs_ParticleSpawned[npc.index]))
		{
			position[0] = 525.0;
			position[1] = 1600.0;
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
		Explode_Logic_Custom(100.0*RaidModeScaling, 0, npc.index, -1, position, 500.0, 1.0, _, true, 20);
		
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
