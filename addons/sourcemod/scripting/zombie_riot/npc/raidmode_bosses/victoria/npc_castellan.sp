#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"weapons/rescue_ranger_teleport_receive_01.wav",
	"weapons/rescue_ranger_teleport_receive_02.wav"
};
static const char g_HurtSounds[][] = {
	"vo/soldier_painsharp01.mp3",
	"vo/soldier_painsharp02.mp3",
	"vo/soldier_painsharp03.mp3",
	"vo/soldier_painsharp04.mp3",
	"vo/soldier_painsharp05.mp3",
	"vo/soldier_painsharp06.mp3",
	"vo/soldier_painsharp07.mp3",
	"vo/soldier_painsharp08.mp3"
};
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/soldier_taunts01.mp3",
	"vo/taunts/soldier_taunts02.mp3",
	"vo/taunts/soldier_taunts03.mp3",
	"vo/taunts/soldier_taunts04.mp3",
	"vo/taunts/soldier_taunts05.mp3",
	"vo/taunts/soldier_taunts06.mp3",
	"vo/taunts/soldier_taunts07.mp3",
	"vo/taunts/soldier_taunts08.mp3",
	"vo/taunts/soldier_taunts09.mp3",
	"vo/taunts/soldier_taunts10.mp3",
	"vo/taunts/soldier_taunts11.mp3",
	"vo/taunts/soldier_taunts12.mp3",
	"vo/taunts/soldier_taunts13.mp3",
	"vo/taunts/soldier_taunts14.mp3",
	"vo/taunts/soldier_taunts15.mp3",
	"vo/taunts/soldier_taunts16.mp3",
	"vo/taunts/soldier_taunts17.mp3",
	"vo/taunts/soldier_taunts18.mp3",
	"vo/taunts/soldier_taunts19.mp3",
	"vo/taunts/soldier_taunts20.mp3",
	"vo/taunts/soldier_taunts21.mp3",
};

static const char g_MeleeAttackSounds[] = "weapons/machete_swing.wav";
static const char g_RocketAttackSounds[] = "weapons/rpg/rocketfire1.wav";

static const char g_MeleeHitSounds[] = "weapons/cbar_hitbod1.wav";
static const char g_AngerSounds[] = "mvm/mvm_tele_activate.wav";
static const char g_AngerReaction[] = "vo/compmode/cm_soldier_pregamefirst_rare_06.mp3";

static const char g_SummonDroneSound[] = "mvm/mvm_bought_in.wav";
static const char g_SummonAlotOfRockets[] = "weapons/rocket_ll_shoot.wav";
static const char g_BoomSounds[] = "mvm/mvm_tank_explode.wav";
static const char g_IncomingBoomSounds[] = "weapons/drg_wrench_teleport.wav";


static int g_Laser;
static int g_BluePoint;
static int g_RedPoint;
static int g_Laser;

static int Temp_Target[MAXENTITIES];

static int SaveSolidFlags[MAXENTITIES];
static int SaveSolidType[MAXENTITIES];

static bool Gone_Stats[MAXENTITIES];

void Castellan_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Castellan");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_castellan");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_castellan_raid");
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
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_AngerSounds);
	PrecacheSound(g_AngerReaction);
	PrecacheSound(g_BoomSounds);
	PrecacheSound(g_IncomingBoomSounds);
	PrecacheSound(g_SummonDroneSound);
	PrecacheSound(g_SummonAlotOfRockets);
	PrecacheSound(g_MeleeAttackSounds);
	PrecacheSound(g_RocketAttackSounds);
	PrecacheSound("mvm/ambient_mp3/mvm_siren.mp3");
	
	PrecacheSoundCustom("#zombiesurvival/victoria/raid_castellan.mp3");
	
	PrecacheModel("models/player/soldier.mdl");
	PrecacheModel(LASERBEAM);
	g_BluePoint = PrecacheModel("sprites/blueglow1.vmt");
	g_RedPoint = PrecacheModel("sprites/redglow1.vmt");
	g_Laser = PrecacheModel("materials/sprites/laser.vmt");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Castellan(client, vecPos, vecAng, ally, data);
}

methodmap Castellan < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayAngerReaction()
	{
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerReaction, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDroneSummonSound()
	{
		EmitSoundToAll(g_SummonDroneSound, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayHomingBadRocketSound()
	{
		EmitSoundToAll(g_SummonAlotOfRockets, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayGunSound()
	{
		EmitSoundToAll(g_RocketAttackSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL - 5, _, BOSS_ZOMBIE_VOLUME, 85);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayBoomSound()
	{
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_BoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayIncomingBoomSound()
	{
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_IncomingBoomSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property float m_flTimeUntillSupportSpawn
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}

	public Castellan(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Castellan npc = view_as<Castellan>(CClotBody(vecPos, vecAng, "models/player/soldier.mdl", "1.35", "40000", ally, false, true, true,true)); //giant!
		i_NpcWeight[npc.index] = 4;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(2);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		SaveSolidFlags[npc.index]=GetEntProp(npc.index, Prop_Send, "m_usSolidFlags");
		SaveSolidType[npc.index]=GetEntProp(npc.index, Prop_Send, "m_nSolidType");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		npc.m_bDissapearOnDeath = true;
		npc.m_flMeleeArmor = 1.25;
		
		func_NPCDeath[npc.index] = Castellan_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Castellan_OnTakeDamage;
		func_NPCThink[npc.index] = Castellan_ClotThink;
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_Expidonsa_Sensal_Win);

		//IDLE
		npc.m_iState = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flSpeed = 330.0;
		npc.m_flDoingAnimation = 0.0;
		ParticleSpawned[npc.index] = false;
		Gone_Stats[npc.index] = false;
		npc.m_bFUCKYOU = false;
		
		npc.m_flTimeUntillSupportSpawn = 0.0;
		
		f_TimeSinceHasBeenHurt = 0.0;
		Zero(b_said_player_weaponline);
		fl_said_player_weaponline_time[npc.index] = GetGameTime() + GetRandomFloat(0.0, 5.0);
		
		npc.StartPathing();

		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "obj_status_sentrygun_3", 1, "%t", "Castellan Arrived");
			}
		}
		RemoveAllDamageAddition();
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		float value;
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
			value = float(Waves_GetRoundScale()+1);
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
		
		if(value > 25 && value < 35)
		{
			RaidModeScaling *= 0.85;
		}
		else if(value > 35)
		{
			RaidModeTime = GetGameTime(npc.index) + 220.0;
			RaidModeScaling *= 0.75;
		}
		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
			b_NpcUnableToDie[npc.index] = true;
		}

		if(StrContains(data, "nomusic") == -1)
		{
			MusicEnum music;
			strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/victoria/raid_castellan.mp3");
			music.Time = 154;
			music.Volume = 2.0;
			music.Custom = true;
			strcopy(music.Name, sizeof(music.Name), "Deep Dive - Arena Fight");
			strcopy(music.Artist, sizeof(music.Artist), "Serious Sam 4: Reborn mod");
			Music_SetRaidMusic(music);
		}

		npc.m_iChanged_WalkCycle = -1;

		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_fbGunout = false;

		SetGlobalTransTarget(client);
		npc.m_iWearable2 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
		SetVariantString("1.25");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable2, 150, 150, 255, 255);

		npc.m_iWearable3 = npc.EquipItem("head", "models/player/items/soldier/fdu.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/soldier/xms2013_soldier_marshal_hat/xms2013_soldier_marshal_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 255);

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/soldier/sept2014_lone_survivor/sept2014_lone_survivor.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/soldier/coldfront_curbstompers/coldfront_curbstompers.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_batarm/bak_batarm_soldier.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);

		npc.m_iWearable8 = npc.EquipItem("head", "models/workshop/player/items/soldier/hwn2022_safety_stripes/hwn2022_safety_stripes.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable8, "SetModelScale");
		SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 255);

		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable8, Prop_Send, "m_nSkin", skin);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({150, 150, 150, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Intro", false, true);
		
		return npc;
	}
}

static void Castellan_ClotThink(int iNPC)
{
	Castellan npc = view_as<Castellan>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > gameTime)
		return;
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(f_TimeSinceHasBeenHurt)
	{
		npc.StopPathing();
		
		npc.m_bisWalking = false;
		BlockLoseSay = true;

		if(f_TimeSinceHasBeenHurt < gameTime)
		{
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(StealthDevice(npc, ), NpcStats_VictorianCallToArms(npc.index) && !ParticleSpawned[npc.index])
	{
		float flPos[3], flAng[3];
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable9 = ParticleEffectAt_Parent(flPos, "eye_powerup_blue_lvl_3", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("", flPos, flAng);
		ParticleSpawned[npc.index] = true;
	}

	if(LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Lastman-1", false, false);
				case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Lastman-2", false, false);
				case 2:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Lastman-3", false, false);
			}
		}
	}
	if(RaidModeTime < GetGameTime() && !npc.m_bFUCKYOU && GetTeam(npc.index) != TFTeam_Red)
	{
		DeleteAndRemoveAllNpcs = 10.0;
		mp_bonusroundtime.IntValue = (12 * 2);
		ZR_NpcTauntWinClear();
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		switch(GetRandomInt(1, 4))
		{
			case 1:CPrintToChatAll("{blue}Castellan{default}: All Tanks refueled, RUSH THEM!");
			case 2:CPrintToChatAll("{blue}Castellan{default}: Ziberia will pay with their blood for this");
			case 3:CPrintToChatAll("{blue}Castellan{default}: Times up! RUN OVER THEM!");
			case 4:CPrintToChatAll("{blue}Castellan{default}: Seems like your precious knight friends didn't help you so much this time.");
		}
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		for(int i; i<10; i++)
		{
			int spawn_index = NPC_CreateByName("npc_victorian_tank", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index), "only");
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				int health = RoundToCeil(float(ReturnEntityMaxHealth(npc.index)) * 3.0);
				fl_Extra_MeleeArmor[spawn_index] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[spawn_index] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[spawn_index] = fl_Extra_Speed[npc.index] * 10.0;
				fl_Extra_Damage[spawn_index] = fl_Extra_Damage[npc.index]* 20.0;
				if(GetTeam(iNPC) != TFTeam_Red)
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", health);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", health);
				int Decicion = TeleportDiversioToRandLocation(spawn_index,_,1250.0, 500.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 250.0);

				if(Decicion == 2)
					Decicion = TeleportDiversioToRandLocation(spawn_index, _, 1250.0, 0.0);
			}
		}
		npc.PlayDeathSound();
		BlockLoseSay = true;
		npc.m_bFUCKYOU = true;
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

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		if(npc.m_iState == -1)
			npc.m_iState = 0;
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		static bool ReAnim;
		switch(Man_Work(npc, gameTime, VecSelfNpc, vecTarget, flDistanceToTarget))
		{
			case 0:
			{
				if(npc.m_iChanged_WalkCycle != 0)
				{
					ReAnim=true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 0;
					npc.m_flSpeed = 330.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
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
				ReAnim=false;
			}
			case 1:
			{
				if(npc.m_iChanged_WalkCycle != 1)
					npc.m_iChanged_WalkCycle = 1;
				ReAnim=true;
			}
			case 2:
			{
				if(npc.m_iChanged_WalkCycle != 2)
				{
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 2;
					npc.m_flSpeed = 0.0;
					npc.StopPathing();
				}
				ReAnim=true;
			}
			case 3:
			{
				if(npc.m_iChanged_WalkCycle != 3)
				{
					ReAnim=true;
					npc.m_bisWalking = false;
					npc.m_bAllowBackWalking = true;
					npc.m_iChanged_WalkCycle = 3;
					npc.m_flSpeed = 330.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, npc.m_iTarget,_,vBackoffPos);
				npc.SetGoalVector(vBackoffPos, true);
				ReAnim=false;
			}
			case 4:
			{
				if(npc.m_iChanged_WalkCycle != 4)
				{
					ReAnim=true;
					npc.m_bisWalking = true;
					npc.m_bAllowBackWalking = false;
					npc.m_iChanged_WalkCycle = 4;
					npc.m_flSpeed = 290.0;
					npc.StartPathing();
				}
				CastellanIntoAir(npc, ReAnim);
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
				ReAnim=false;
			}
		}
	}
	else
		npc.m_flGetClosestTargetTime = 0.0;
	if(!Gone_Stats[npc.index])
		npc.PlayIdleAlertSound();
}

static void CastellanIntoAir(Huscarls npc, bool ReAime)
{
	static bool ImAirBone;
	switch(npc.m_iChanged_WalkCycle)
	{
		case 0, 3:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_MELEE");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
					ImAirBone=false;
				}
			}
		}
		case 4:
		{
			if(npc.IsOnGround())
			{
				if(!ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_RUN_PRIMARY");
					ImAirBone=true;
				}
			}
			else
			{
				if(ImAirBone||ReAime)
				{
					npc.SetActivity("ACT_MP_JUMP_FLOAT_PRIMARY");
					ImAirBone=false;
				}
			}
		}
	}
}

static Action Castellan_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Castellan npc = view_as<Castellan>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	if(!IsValidEntity(attacker))
		return Plugin_Continue;
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flHeadshotCooldown < gameTime)
	{
		npc.m_flHeadshotCooldown = gameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(i_RaidGrantExtra[npc.index] == 1)
	{
		if((RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			f_TimeSinceHasBeenHurt = GetGameTime() + 36.0;
			RaidModeTime += 900.0;
			NPCStats_RemoveAllDebuffs(npc.index, 1.0);
			SetEntityCollisionGroup(npc.index, 24);
			SetTeam(npc.index, TFTeam_Red);
			GiveProgressDelay(45.0);
			
			float SelfPos[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", SelfPos);
			float AllyAng[3];
			GetEntPropVector(npc.index, Prop_Data, "m_angRotation", AllyAng);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", SelfPos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", AllyAng);
			}
			int SensalSpawn = NPC_CreateByName("npc_sensal", -1, SelfPos, AllyAng, GetTeam(npc.index), "victoria_cutscene"); //can only be enemy
			if(IsValidEntity(SensalSpawn))
			{
				if(GetTeam(SensalSpawn) != TFTeam_Red)
				{
					NpcAddedToZombiesLeftCurrently(SensalSpawn, true);
				}
				SetEntProp(SensalSpawn, Prop_Data, "m_iHealth", 100000000);
				SetEntProp(SensalSpawn, Prop_Data, "m_iMaxHealth", 100000000);
			}
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}	
	int maxhealth = ReturnEntityMaxHealth(npc.index);
	int health = GetEntProp(npc.index, Prop_Data, "m_iHealth");
	float ratio = float(health) / float(maxhealth);
	if(ratio<0.25 || (float(health)-damage)<(maxhealth*0.3))
	{
		if(!npc.m_fbRangedSpecialOn)
		{
			I_cant_do_this_all_day[npc.index]=0;
			ApplyStatusEffect(npc.index, npc.index, "Call To Victoria", 999.9);
			IncreaseEntityDamageTakenBy(npc.index, 0.05, 1.0);
			npc.m_fbRangedSpecialOn = true;
			npc.m_bFUCKYOU=true;
			RaidModeTime += 35.0;
		}
	}

	return Plugin_Changed;
}

static void Castellan_NPCDeath(int entity)
{
	Castellan npc = view_as<Castellan>(entity);
	float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
	
	ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
	npc.PlayDeathSound();	

	RaidBossActive = INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable9))
		RemoveEntity(npc.m_iWearable9);
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

	if(BlockLoseSay)
		return;

	switch(GetRandomInt(0,2))
	{
		case 0:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_EscapePlan-1", false, false);
		case 1:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_EscapePlan-2", false, false);
		case 2:NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_EscapePlan-3", false, false);
	}

}
static int Man_Work(Castellan npc, float gameTime, float VecSelfNpc[3], float vecTarget[3], float distance)
{
	if(npc.m_flTimeUntillSupportSpawn < gameTime)
	{
		NPCPritToChat(npc.index, "{steelblue}", "Castellan_Talk_Ability1", false, false);
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpc);
		CreateSupport_Castellan(npc.index, target, VecSelfNpc);
		npc.m_flTimeUntillSupportSpawn = gameTime + 20.0;
	}

	if(distance < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
	{
		if(npc.m_flNextMeleeAttack < gameTime)
		{
			if(!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = gameTime+0.25;
				npc.m_flAttackHappens_bullshit = gameTime+0.39;
				npc.m_flAttackHappenswillhappen = true;
			}
			if(npc.m_flAttackHappens < gameTime && npc.m_flAttackHappens_bullshit >= gameTime && npc.m_flAttackHappenswillhappen)
			{
				if(IsValidEnemy(npc.index, npc.m_iTarget))
				{
					int HowManyEnemeisAoeMelee = 64;
					Handle swingTrace;
					npc.FaceTowards(vecTarget, 15000.0);
					npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
					delete swingTrace;
					bool PlaySound = false, PlayPOWERSound = false;
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
								float damage = 40.0 * RaidModeScaling;
								if(fl_ruina_battery[npc.index] && !npc.m_flHuscarlsAdaptiveArmorDuration)
								{
									damage+=fl_ruina_battery[npc.index]*0.1;
									fl_ruina_battery[npc.index]=0.0;
									ExtinguishTarget(npc.m_iWearable2);
									CreateEarthquake(vecTarget, 0.5, 350.0, 16.0, 255.0);
									if(HasSpecificBuff(npc.index, "Battery_TM Charge"))
										RemoveSpecificBuff(npc.index, "Battery_TM Charge");
									PlayPOWERSound = true;
								}
								if(ShouldNpcDealBonusDamage(targetTrace))
									damage *= 7.0;
								KillFeed_SetKillIcon(npc.index, "apocofists");
								SDKHooks_TakeDamage(targetTrace, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
								bool Knocked = false;
											
								if(IsValidClient(targetTrace))
								{
									if(IsInvuln(targetTrace))
									{
										Knocked = true;
										Custom_Knockback(npc.index, targetTrace, 750.0, true);
									}
									TF2_AddCondition(targetTrace, TFCond_LostFooting, 0.5);
									TF2_AddCondition(targetTrace, TFCond_AirCurrent, 0.5);
								}
								
								if(!Knocked)
									Custom_Knockback(npc.index, targetTrace, 375.0, true); 
							} 
						}
					}
					if(PlaySound)
						npc.PlayMeleeHitSound();
					if(PlayPOWERSound)
					{
						ParticleEffectAt(vecTarget, "rd_robot_explosion", 1.0);
						npc.PlayPowerHitSound();
					}
				}
				npc.m_flAttackHappens = 0.0;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if(npc.m_flAttackHappens_bullshit < gameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	npc.m_iState = 0;
	return 0;
}

static void ResetCastellanWeapon(Castellan npc, int weapon_Type)
{
	if(IsValidEntity(npc.m_iWearable1))
	{
		RemoveEntity(npc.m_iWearable1);
	}
	switch(weapon_Type)
	{
		case 1:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_rocketlauncher/c_rocketlauncher.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 2:
		{
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_reserve_shooter/c_reserve_shooter.mdl");
			SetVariantString("1.0");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
		case 0:
		{	
			npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_fireaxe_pyro/c_fireaxe_pyro.mdl");
			SetVariantString("0.75");
			AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		}
	}
}


static void CreateSupport_Castellan(int entity, int enemySelect, float SelfPos[3])
{
	int SupportTeam;
	char Adddeta[512];
	FormatEx(Adddeta, sizeof(Adddeta), "support_ability");
	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			SupportTeam = NPC_CreateByName("npc_atomizer", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta); //can only be enemy
		}
		case 2:
		{
			FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, entity);
			SupportTeam = NPC_CreateByName("npc_the_wall", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		case 3:
		{
			FormatEx(Adddeta, sizeof(Adddeta), "%s;%i", Adddeta, entity);
			SupportTeam = NPC_CreateByName("npc_harrison", -1, SelfPos, {0.0,0.0,0.0}, GetTeam(entity), Adddeta);
		}
		default: //This should not happen
		{
			PrintToChatAll("An error occured. Scream at devs");//none
		}
	}
	if(IsValidEntity(SupportTeam))
	{
		MakeObjectIntangeable(SupportTeam);
		b_DoNotUnStuck[SupportTeam] = true;
		b_NoKnockbackFromSources[SupportTeam] = true;
		b_ThisEntityIgnored[SupportTeam] = true;
		Whiteflower_FloweringDarkness npc = view_as<Whiteflower_FloweringDarkness>(SupportTeam);
		npc.m_iTarget = enemySelect;
		npc.m_bDissapearOnDeath = true;
	}
}

static Action Timer_Rocket_Shot(Handle timer, DataPack pack)
{
	pack.Reset();
	Castellan npc = view_as<Castellan>(EntRefToEntIndex(pack.ReadCell()));
	int enemy = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(enemy))
	{
		float vecTarget[3]; WorldSpaceCenter(enemy, vecTarget);
		float vecSelf[3];
		WorldSpaceCenter(npc.index, vecSelf);
		vecSelf[2] += 80.0;
		vecSelf[0] += GetRandomFloat(-20.0, 20.0);
		vecSelf[1] += GetRandomFloat(-20.0, 20.0);
		float RocketDamage = 40.0;
		int RocketGet = npc.FireRocket(vecSelf, RocketDamage * RaidModeScaling, 50.0 ,"models/buildables/sentry3_rockets.mdl");
		npc.PlayHomingBadRocketSound();
		if(IsValidEntity(RocketGet))
		{
			for(int r=1; r<=5; r++)
            { 
                DataPack pack2;
                CreateDataTimer(1.35 * float(r), WhiteflowerTank_Rocket_Stand, pack2, TIMER_FLAG_NO_MAPCHANGE);
                pack2.WriteCell(EntIndexToEntRef(RocketGet));
                pack2.WriteCell(EntIndexToEntRef(enemy));
            }
		}
	}
	return Plugin_Stop;
}

static bool StealthDevice(Castellan npc, bool Activate)
{
	if(Activate)
	{
		if(!Gone_Stats[npc.index])
		{
			ParticleSpawned[npc.index] = false;
			npc.m_iChanged_WalkCycle = 0;
			b_NoHealthbar[npc.index]=true;
			Npc_BossHealthBar(npc);
			
			if(IsValidEntity(i_InvincibleParticle[npc.index]))
			{
				particle = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
				SetEntityRenderMode(particle, RENDER_NONE);
				SetEntityRenderColor(particle, 255, 255, 255, 1);
				SetEntPropFloat(particle, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(particle, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			SetEntityRenderMode(npc.index, RENDER_NONE);
			SetEntityRenderColor(npc.index, 255, 255, 255, 1);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 1.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 1.0);
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntityRenderMode(npc.m_iWearable2, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable3))
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable4))
			{
				SetEntityRenderMode(npc.m_iWearable4, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable5))
			{
				SetEntityRenderMode(npc.m_iWearable5, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable6))
			{
				SetEntityRenderMode(npc.m_iWearable6, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 1);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable7))
			{
				SetEntityRenderMode(npc.m_iWearable7, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				SetEntityRenderMode(npc.m_iWearable8, RENDER_NONE);
				SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 1);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 1.0);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 1.0);
			}
			if(IsValidEntity(npc.m_iTeamGlow))
				RemoveEntity(npc.m_iTeamGlow);
			Gone_Stats[npc.index]=true;
		}
		return false;
	}
	else
	{
		if(ToggleDevice)
		{
			b_NoHealthbar[npc.index]=false;
			Npc_BossHealthBar(npc);
			if(IsValidEntity(i_InvincibleParticle[npc.index]))
			{
				int Shield = EntRefToEntIndex(i_InvincibleParticle[npc.index]);
				if(b_NpcIsInvulnerable[npc.index])
				{
					if(i_InvincibleParticlePrev[Shield] != 0)
					{
						SetEntityRenderColor(Shield, 0, 255, 0, 255);
						i_InvincibleParticlePrev[Shield] = 0;
					}
				}
				else if(i_npcspawnprotection[npc.index] == NPC_SPAWNPROT_ON)
				{
					if(i_InvincibleParticlePrev[Shield] != 1)
					{
						SetEntityRenderColor(Shield, 0, 50, 50, 35);
						i_InvincibleParticlePrev[Shield] = 1;
					}
				}
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(Shield, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			SetEntityRenderMode(npc.index, RENDER_NORMAL);
			SetEntityRenderColor(npc.index, 255, 255, 255, 255);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMinDist", 30000.0);
			SetEntPropFloat(npc.index, Prop_Send, "m_fadeMaxDist", 30000.0);
			if(IsValidEntity(npc.m_iWearable1))
			{
				SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable2))
			{
				SetEntityRenderMode(npc.m_iWearable2, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable2, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable2, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable3))
			{
				SetEntityRenderMode(npc.m_iWearable3, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable3, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable3, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable4))
			{
				SetEntityRenderMode(npc.m_iWearable4, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable4, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable4, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable5))
			{
				SetEntityRenderMode(npc.m_iWearable5, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable5, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable5, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable6))
			{
				SetEntityRenderMode(npc.m_iWearable6, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable6, 255, 255, 255, 255);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable6, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable7))
			{
				SetEntityRenderMode(npc.m_iWearable7, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable7, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable7, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(IsValidEntity(npc.m_iWearable8))
			{
				SetEntityRenderMode(npc.m_iWearable8, RENDER_NORMAL);
				SetEntityRenderColor(npc.m_iWearable8, 50, 50, 50, 255);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMinDist", 30000.0);
				SetEntPropFloat(npc.m_iWearable8, Prop_Send, "m_fadeMaxDist", 30000.0);
			}
			if(!IsValidEntity(npc.m_iTeamGlow))
			{
				npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
				npc.m_bTeamGlowDefault = false;
				SetVariantColor(view_as<int>({150, 150, 150, 200}));
				AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
			}
			Gone_Stats[npc.index]=false;
		}
	}
	return true;
}
