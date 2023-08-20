#pragma semicolon 1
#pragma newdecls required


static char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
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
	"weapons/breadmonster/throwable/bm_throwable_throw.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_teleport.wav",
};

static char g_MeleeMissSounds[][] = {
	")weapons/cbar_miss1.wav",
};

static char g_AngerSounds[][] = {
	")vo/medic_hat_taunts04.mp3",
};

static char g_PullSounds[][] = {
	"weapons/physcannon/energy_sing_explosion2.wav"
};

static char gGlow1;
static char gExplosive1;
static char gLaser1;

static bool FusionWarrior_BEAM_CanUse[MAXENTITIES];
static bool FusionWarrior_BEAM_IsUsing[MAXENTITIES];
static int FusionWarrior_BEAM_TicksActive[MAXENTITIES];
int FusionWarrior_BEAM_Laser;
int FusionWarrior_BEAM_Glow;
static float FusionWarrior_BEAM_CloseDPT[MAXENTITIES];
static float FusionWarrior_BEAM_FarDPT[MAXENTITIES];
static int FusionWarrior_BEAM_MaxDistance[MAXENTITIES];
static int FusionWarrior_BEAM_BeamRadius[MAXENTITIES];
static int FusionWarrior_BEAM_ColorHex[MAXENTITIES];
static int FusionWarrior_BEAM_ChargeUpTime[MAXENTITIES];
static float FusionWarrior_BEAM_CloseBuildingDPT[MAXENTITIES];
static float FusionWarrior_BEAM_FarBuildingDPT[MAXENTITIES];
static float FusionWarrior_BEAM_Duration[MAXENTITIES];
static float FusionWarrior_BEAM_BeamOffset[MAXENTITIES][3];
static float FusionWarrior_BEAM_ZOffset[MAXENTITIES];
static bool FusionWarrior_BEAM_HitDetected[MAXENTITIES];
static bool FusionWarrior_BEAM_UseWeapon[MAXENTITIES];
static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];


static float fl_Timebeforekamehameha[MAXENTITIES];
static bool b_InKame[MAXENTITIES];
static float fl_NextPull[MAXENTITIES];
static int i_AmountProjectiles[MAXENTITIES];

static bool b_angered_twice[MAXENTITIES];
static int i_SaidLineAlready[MAXENTITIES];
static float f_TimeSinceHasBeenHurt[MAXENTITIES];

public void TrueFusionWarrior_OnMapStart()
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
	for (int i = 0; i < (sizeof(g_PullSounds));   i++) { PrecacheSound(g_PullSounds[i]);   }
	
	
	PrecacheSound("weapons/physcannon/superphys_launch1.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch2.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch3.wav", true);
	PrecacheSound("weapons/physcannon/superphys_launch4.wav", true);
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_drop.wav", true);
	TrueFusionWarrior_TBB_Precahce();
	
	gLaser1 = PrecacheModel("materials/sprites/laser.vmt");
	gGlow1 = PrecacheModel("sprites/blueglow2.vmt", true);
	gExplosive1 = PrecacheModel("materials/sprites/sprite_fire01.vmt");
	
	PrecacheSound("player/flow.wav");

	PrecacheSoundCustom("#zombiesurvival/fusion_raid/fusion_bgm.mp3");
}

void TrueFusionWarrior_TBB_Precahce()
{
	FusionWarrior_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	FusionWarrior_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

methodmap TrueFusionWarrior < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_Timebeforekamehameha[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Timebeforekamehameha[this.index] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	property float m_flNextPull
	{
		public get()							{ return fl_NextPull[this.index]; }
		public set(float TempValueForProperty) 	{ fl_NextPull[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound(bool repeat = false) {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_IdleSounds) - 1);
		
		EmitSoundToAll(g_IdleSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_IdleSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
			
		int sound = GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1);
		
		EmitSoundToAll(g_IdleAlertedSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_IdleAlertedSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayHurtSound() {
		
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);

		EmitSoundToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_HurtSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_DeathSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	
	public void PlayAngerSound() {
	
		int sound = GetRandomInt(0, sizeof(g_AngerSounds) - 1);
		EmitSoundToAll(g_AngerSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		DataPack pack;
		CreateDataTimer(0.1, Fusion_RepeatSound_Doublevoice, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteString(g_AngerSounds[sound]);
		pack.WriteCell(EntIndexToEntRef(this.index));
	}
	
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds[GetRandomInt(0, sizeof(g_PullSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayPullSound()");
		#endif
	}
	
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public TrueFusionWarrior(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		TrueFusionWarrior npc = view_as<TrueFusionWarrior>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcInternalId[npc.index] = RAIDMODE_TRUE_FUSION_WARRIOR;
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "True Fusion Warrior Spawn");
			}
		}
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		
		RaidModeScaling = float(ZR_GetWaveCount()+1);
		
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
		
		Raidboss_Clean_Everyone();
		
		SDKHook(npc.index, SDKHook_Think, TrueFusionWarrior_ClotThink);
		
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/hwn_medic_hat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_ubersaw/c_ubersaw.mdl");
		SetVariantString("2.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable5 = npc.EquipItem("head","models/workshop/player/items/medic/sf14_medic_kriegsmaschine_9000/sf14_medic_kriegsmaschine_9000.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", 1);
		
		float flPos[3]; // original
		float flAng[3]; // original
	
	
		npc.GetAttachment("head", flPos, flAng);
		
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "unusual_symbols_parent_lightning", npc.index, "head", {0.0,0.0,0.0});
		
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 192, 192, 0, 125);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable5, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable5, 150, 150, 150, 255);
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

		Music_SetRaidMusic("#zombiesurvival/fusion_raid/fusion_bgm.mp3", 178, true);
		
		npc.Anger = false;
		b_angered_twice[npc.index] = false;
		f_TimeSinceHasBeenHurt[npc.index] = 0.0;
		//IDLE
		npc.m_flSpeed = 330.0;
		
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 10.0;
		npc.m_flNextPull = GetGameTime(npc.index) + 5.0;
		npc.m_bInKame = false;
		
		Citizen_MiniBossSpawn(npc.index);
		Building_RaidSpawned(npc.index);
		return npc;
	}
}

//TODO 
//Rewrite
public void TrueFusionWarrior_ClotThink(int iNPC)
{
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(iNPC);
	
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, TrueFusionWarrior_ClotThink);
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) {
		return;
	}
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(npc.m_bInKame)
		{
			npc.m_iTarget = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(npc.m_iTarget == -1)
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
	
	int closest = npc.m_iTarget;
	
	if(npc.m_bInKame)
	{
		if(b_angered_twice[npc.index])
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;
		}
		else if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.6;
			npc.m_flMeleeArmor = 0.75;
		}	
		else
		{
			npc.m_flRangedArmor = 0.7;
			npc.m_flMeleeArmor = 0.875;			
		}
	}
	else
	{
		if(b_angered_twice[npc.index])
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;
		}
		else if(npc.Anger)
		{
			npc.m_flRangedArmor = 0.85;
			npc.m_flMeleeArmor = 1.0625;
		}	
		else
		{
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.25;			
		}	
	}
	
	if(IsValidEnemy(npc.index, closest, true))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(closest);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, closest);
		
			//Body pitch
	//		if(flDistanceToTarget < Pow(110.0,2.0))
			{
				int iPitch = npc.LookupPoseParameter("body_pitch");
				if(iPitch < 0)
					return;		
			
				//Body pitch
				float v[3], ang[3];
				SubtractVectors(WorldSpaceCenter(npc.index), WorldSpaceCenter(closest), v); 
				NormalizeVector(v, v);
				GetVectorAngles(v, ang); 
				
				float flPitch = npc.GetPoseParameter(iPitch);
				
			//	ang[0] = clamp(ang[0], -44.0, 89.0);
				npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
			}
			if(b_angered_twice[npc.index])
			{
				npc.m_flNextThinkTime = 0.0;
				npc.FaceTowards(vecTarget, 100.0);
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.SetActivity("ACT_MP_STAND_LOSERSTATE");
				npc.m_bInKame = false;
				npc.m_bisWalking = false;
				for(int client=1; client<=MaxClients; client++)
				{
					if(IsClientInGame(client))
					{
						if(fl_AlreadyStrippedMusic[client] < GetEngineTime())
						{
							Music_Stop_All(client); //This is actually more expensive then i thought.
						}
						SetMusicTimer(client, GetTime() + 6);
						fl_AlreadyStrippedMusic[client] = GetEngineTime() + 5.0;
					}
				}
				if(GetGameTime() > f_TimeSinceHasBeenHurt[npc.index])
				{
					CPrintToChatAll("{gold}Silvester{default}: You will get soon in touch with a friend of mine, i thank you, and beware of the rogue machine... {red}Blitzkrieg.");
					npc.m_bDissapearOnDeath = true;

					RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
					for (int client = 0; client < MaxClients; client++)
					{
						if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
						{
							Items_GiveNamedItem(client, "Cured Silvester");
							CPrintToChat(client,"{default}You gained his favor, you obtained: {yellow}''Cured Silvester''{default}!");
						}
					}
				}
				else if(GetGameTime() + 5.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 4)
				{
					i_SaidLineAlready[npc.index] = 4;
					CPrintToChatAll("{gold}Silvester{default}: Help the world, retain the chaos!");
				}
				else if(GetGameTime() + 10.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 3)
				{
					i_SaidLineAlready[npc.index] = 3;
					CPrintToChatAll("{gold}Silvester{default}: I thank you, but i will need help from you later, and i will warn you of dangers.");
				}
				else if(GetGameTime() + 13.0 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 2)
				{
					i_SaidLineAlready[npc.index] = 2;
					CPrintToChatAll("{gold}Silvester{default}: A huge chaos is breaking out, you were able to knock some sense into me..!");
				}
				else if(GetGameTime() + 16.5 > f_TimeSinceHasBeenHurt[npc.index] && i_SaidLineAlready[npc.index] < 1)
				{
					i_SaidLineAlready[npc.index] = 1;
					CPrintToChatAll("{gold}Silvester{default}: Listen to me, please!");
				}
				return; //He is trying to help.
			}
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
			/*	int color[4];
				color[0] = 255;
				color[1] = 255;
				color[2] = 0;
				color[3] = 255;
			
				int xd = PrecacheModel("materials/sprites/laserbeam.vmt");
			
				TE_SetupBeamPoints(vPredictedPos, vecTarget, xd, xd, 0, 0, 0.25, 0.5, 0.5, 5, 5.0, color, 30);
				TE_SendToAllInRange(vecTarget, RangeType_Visibility);*/
				
				NPC_SetGoalVector(npc.index, vPredictedPos);
			} else {
				NPC_SetGoalEntity(npc.index, closest);
			}
			
			
			if(ZR_GetWaveCount()+1 > 25)
			{
				if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index) && !npc.Anger)
				{
					npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 35.0;
					npc.m_bInKame = true;
					TrueFusionWarrior_TBB_Ability(npc.index);
				}
				else if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index) && npc.Anger)
				{
					npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 35.0;
					npc.m_bInKame = true;
					TrueFusionWarrior_TBB_Ability_Anger(npc.index);
				}
			}
			if(npc.m_bInKame)
			{
				npc.FaceTowards(vecTarget, 650.0);
				NPC_StopPathing(npc.index);
				npc.m_bPathing = false;
				npc.m_flSpeed = 0.0;
			}
			else
			{
				if (!npc.Anger)
				{
					npc.m_flSpeed = 330.0;
				}
				else
				{
					npc.m_flSpeed = 350.0;
				}
			}
			
			if (npc.m_flNextRangedAttack < GetGameTime(npc.index) && flDistanceToTarget < (500.0 * 500.0) || (npc.m_bInKame && npc.m_flNextRangedAttack < GetGameTime(npc.index)))
			{
				if (!npc.Anger)
				{
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.FireRocket(vPredictedPos, 8.0 * RaidModeScaling, 800.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 4.0;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
				}
				else if (npc.Anger)
				{
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.FireRocket(vPredictedPos, 8.0 * RaidModeScaling, 800.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 3.0;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
				}
			}
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				if(npc.m_flNextPull < GetGameTime(npc.index) && !npc.m_bInKame)
				{
					if (!npc.Anger)
					{
						npc.FaceTowards(vecTarget);
						
						for(int client = 1; client <= MaxClients; client++)
						{
							if (IsClientInGame(client) && dieingstate[client] == 0 && TeutonType[client] == 0)
							{
								float vAngles[3], vDirection[3];
								
								float entity_angles[3];
										
								GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vAngles); 
								
								GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", entity_angles); 
								
								float Distance = GetVectorDistance(vAngles, entity_angles);
								if(Distance < 1250)
								{				
									if(vAngles[0] > -45.0)
									{
												vAngles[0] = -45.0;
									}
														
									TF2_AddCondition(client, TFCond_LostFooting, 0.5);
									TF2_AddCondition(client, TFCond_AirCurrent, 0.5);
									f_ImmuneToFalldamage[client] = GetGameTime() + 5.0;
															
									GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
														
									ScaleVector(vDirection, -1250.0);
									
									if(vDirection[2] > 0.0)
									{
										vDirection[2] *= -1.0;
									}
																			
									TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection);
								}
							}
						}
						
						
						npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
						
						
						npc.m_flNextPull = GetGameTime(npc.index) + 15.0;
						npc.PlayPullSound();
						npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					}
					else if (npc.Anger)
					{
						npc.FaceTowards(vecTarget);
						for(int client = 1; client <= MaxClients; client++)
						{
							if (IsClientInGame(client) && dieingstate[client] == 0 && TeutonType[client] == 0)
							{
								float vAngles[3], vDirection[3];
								
								float entity_angles[3];
										
								GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vAngles); 
								
								GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", entity_angles); 
								
								float Distance = GetVectorDistance(vAngles, entity_angles);
								if(Distance < 1250)
								{				
									if(vAngles[0] > -45.0)
									{
											vAngles[0] = -45.0;
									}
														
									TF2_AddCondition(client, TFCond_LostFooting, 0.5);
									TF2_AddCondition(client, TFCond_AirCurrent, 0.5);
									
									f_ImmuneToFalldamage[client] = GetGameTime() + 5.0;
															
									GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
											
									if(vDirection[2] > 0.0)
									{
										vDirection[2] *= -1.0;
									}
									
									ScaleVector(vDirection, -1250.0);
																			
									TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vDirection);
								}
							}
						}
						
						
						npc.DispatchParticleEffect(npc.index, "hammer_bell_ring_shockwave2", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("effect_hand_r"), PATTACH_POINT_FOLLOW, true);
		
						npc.m_flNextPull = GetGameTime(npc.index) + 13.0;
						npc.PlayPullSound();
						npc.AddGesture("ACT_MP_GESTURE_VC_FISTPUMP_MELEE");
					}
				} 
			}
									
									
			if(npc.m_flNextRangedBarrage_Spam < GetGameTime(npc.index) && npc.m_flNextRangedBarrage_Singular < GetGameTime(npc.index) && flDistanceToTarget < (500.0 * 500.0) || (npc.m_bInKame && npc.m_flNextRangedAttack < GetGameTime(npc.index)))
			{
				if (!npc.Anger)
				{
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.FireRocket(vPredictedPos, 3.0 * RaidModeScaling, 700.0, "models/effects/combineball.mdl", 1.0);	
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15;
					
					if(ZR_GetWaveCount()+1 > 55)
						TrueFusionwarrior_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
						
					if (npc.m_iAmountProjectiles >= 8)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 13.0;
					}
				}
				else if (npc.Anger)
				{
					
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					npc.FireRocket(vPredictedPos, 3.0 * RaidModeScaling, 700.0, "models/effects/combineball.mdl", 1.0);
					npc.m_iAmountProjectiles += 1;
					npc.PlayRangedSound();
					npc.AddGesture("ACT_MP_THROW");
					
					if(ZR_GetWaveCount()+1 > 55)
						TrueFusionwarrior_IOC_Invoke(EntIndexToEntRef(npc.index), closest);
						
					npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 0.15;
					if (npc.m_iAmountProjectiles >= 12)
					{
						npc.m_iAmountProjectiles = 0;
						npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 11.0;
					}
				}
			}
			if(npc.m_flNextTeleport < GetGameTime(npc.index) && flDistanceToTarget > (125.0* 125.0) && flDistanceToTarget < (500.0 * 500.0) && !npc.m_bInKame && ZR_GetWaveCount()+1 > 40)
			{
				static float flVel[3];
				GetEntPropVector(closest, Prop_Data, "m_vecVelocity", flVel);
				if (!npc.Anger)
				{
					if (flVel[0] >= 190.0)
					{
						npc.FaceTowards(vecTarget);
						npc.FaceTowards(vecTarget);
						npc.m_flNextTeleport = GetGameTime(npc.index) + 6.0;
						float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
						
						if(Tele_Check > 120.0)
						{
							bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
							if(Succeed)
							{
								npc.PlayTeleportSound();
							}
							else
							{
								npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
							}
						}
					}
				}
				else if (npc.Anger)
				{
					if (flVel[0] >= 170.0)
					{
						npc.FaceTowards(vecTarget);
						npc.FaceTowards(vecTarget);
						npc.m_flNextTeleport = GetGameTime(npc.index) + 5.0;
						float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
						if(Tele_Check > 120.0)
						{
							bool Succeed = NPC_Teleport(npc.index, vPredictedPos);
							if(Succeed)
							{
								npc.PlayTeleportSound();
							}
							else
							{
								npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
							}
						}
					}
				}
			}
			//Target close enough to hit
			if(flDistanceToTarget < (125.0* 125.0) && !npc.m_bInKame || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.3;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.44;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 5000.0);
						if(npc.DoSwingTrace(swingTrace, closest,_,_,_,1))
							{
								
								int target = TR_GetEntityIndex(swingTrace);	
								
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									float damage = 24.0;
									float damage_rage = 28.0;
									if(ZR_GetWaveCount()+1 > 40 && ZR_GetWaveCount()+1 < 55)
									{
										damage = 20.0; //nerf
										damage_rage = 21.0; //nerf
									}
									else if(ZR_GetWaveCount()+1 > 55)
									{
										damage = 19.0; //nerf
										damage_rage = 20.0; //nerf
									}

									if(!npc.Anger)
										SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);
											
									if(npc.Anger)
										SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling * 0.85, DMG_CLUB, -1, _, vecHit);									
										
									
									// Hit particle
									
									
									// Hit sound
									npc.PlayMeleeHitSound();
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
										Custom_Knockback(npc.index, target, 650.0); 
								} 
							}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 1.0;
					}
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	if  (!npc.m_bInKame)
	{
		npc.StartPathing();
		
	}
	npc.PlayIdleAlertSound();
}
	
public Action TrueFusionWarrior_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(victim);
	
	if(b_angered_twice[npc.index]) //Ignore teutons during this. they might ruin it.
	{
		damage = 0.0;
		return Plugin_Handled;
	}

	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}

	f_TimeSinceHasBeenHurt[npc.index] = GetGameTime() + 20.0;

	if((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.Anger) //npc.Anger after half hp/400 hp
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();
		npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("head"), PATTACH_POINT_FOLLOW, true);
		/*
		SetEntityModel(npc.index, "models/freak_fortress_2/super_medic/medic_26_super.mdl");
		npc.m_flSpeed = 400.0;
		float minbounds[3] = {-20.0, -20.0, 0.0};
		float maxbounds[3] = {20.0, 20.0, 80.0};
		SetEntPropVector(npc.index, Prop_Send, "m_vecMins", minbounds);
		SetEntPropVector(npc.index, Prop_Send, "m_vecMaxs", maxbounds);
		*/
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 255, 255, 0, 255);
			
		SetVariantColor(view_as<int>({255, 255, 0, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
	}
	if(ZR_GetWaveCount()+1 > 55 && !b_angered_twice[npc.index] && !Waves_InFreeplay())
	{
		if(((GetEntProp(npc.index, Prop_Data, "m_iMaxHealth")/20) >= GetEntProp(npc.index, Prop_Data, "m_iHealth")) || (RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))) //npc.Anger after half hp/400 hp
		{
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.

			ReviveAll(true);

			b_angered_twice[npc.index] = true; //	>:(
			RaidModeTime += 60.0;

			f_NpcImmuneToBleed[npc.index] = GetGameTime() + 1.0;
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);

			StopSound(npc.index,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");

			SDKUnhook(npc.index, SDKHook_Think, TrueFusionWarrior_TBB_Tick);

			CPrintToChatAll("{gold}Silvester{default}: Stop, Stop please i beg you, i was infected!!");
			int i = MaxClients + 1;
			while((i = FindEntityByClassname(i, "obj_sentrygun")) != -1)
			{
				RemoveEntity(i);
			}
			int skin = 1;
			SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

			if(IsValidEntity(npc.m_iWearable3))
			{
				RemoveEntity(npc.m_iWearable3);
			}
			if(IsValidEntity(npc.m_iWearable1))
			{
				RemoveEntity(npc.m_iWearable1);
			}


			SetVariantColor(view_as<int>({150, 150, 0, 150}));
			AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");

/*
			float flPos[3]; // original
			float flAng[3]; // original

			npc.GetAttachment("head", flPos, flAng);
		
			npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_astralbodies_greenorange_parent", npc.index, "head", {0.0,0.0,0.0});
*/
			damage = 0.0; //So he doesnt get oneshot somehow, atleast once.
			return Plugin_Handled;
		}
	}
	if(f_NpcImmuneToBleed[npc.index] > GetGameTime())
	{
		damage = 0.0;
	}
	else if(f_NpcImmuneToBleed[npc.index] + 1.0 > GetGameTime()) //for 2 seconds he will take next to no damage.
	{
		damage *= 0.1;
	}
	return Plugin_Changed;
}

public void TrueFusionWarrior_NPCDeath(int entity)
{
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	SDKUnhook(npc.index, SDKHook_Think, TrueFusionWarrior_ClotThink);
	
	
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
		
//	AcceptEntityInput(npc.index, "KillHierarchy");
//	npc.Anger = false;

	Citizen_MiniBossDeath(entity);
}

// Ent_Create style position from Doomsday Nuke

void TrueFusionWarrior_TBB_Ability_Anger(int client)
{
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
	
	FusionWarrior_BEAM_IsUsing[client] = false;
	FusionWarrior_BEAM_TicksActive[client] = 0;

	FusionWarrior_BEAM_CanUse[client] = true;
	FusionWarrior_BEAM_CloseDPT[client] = 20.0 * RaidModeScaling;
	FusionWarrior_BEAM_FarDPT[client] = 18.0 * RaidModeScaling;
	FusionWarrior_BEAM_MaxDistance[client] = 2000;
	FusionWarrior_BEAM_BeamRadius[client] = 45;
	FusionWarrior_BEAM_ColorHex[client] = ParseColor("EEDD44");
	FusionWarrior_BEAM_ChargeUpTime[client] = 200;
	FusionWarrior_BEAM_CloseBuildingDPT[client] = 0.0;
	FusionWarrior_BEAM_FarBuildingDPT[client] = 0.0;
	FusionWarrior_BEAM_Duration[client] = 6.0;
	
	FusionWarrior_BEAM_BeamOffset[client][0] = 0.0;
	FusionWarrior_BEAM_BeamOffset[client][1] = 0.0;
	FusionWarrior_BEAM_BeamOffset[client][2] = 0.0;

	FusionWarrior_BEAM_ZOffset[client] = 0.0;
	FusionWarrior_BEAM_UseWeapon[client] = false;

	FusionWarrior_BEAM_IsUsing[client] = true;
	FusionWarrior_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);			
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
		}		
	}
			

	CreateTimer(5.0, TrueFusionWarrior_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
}


void TrueFusionWarrior_TBB_Ability(int client)
{
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
			
	FusionWarrior_BEAM_IsUsing[client] = false;
	FusionWarrior_BEAM_TicksActive[client] = 0;

	FusionWarrior_BEAM_CanUse[client] = true;
	FusionWarrior_BEAM_CloseDPT[client] = 14.0 * RaidModeScaling;
	FusionWarrior_BEAM_FarDPT[client] = 12.0 * RaidModeScaling;
	FusionWarrior_BEAM_MaxDistance[client] = 2000;
	FusionWarrior_BEAM_BeamRadius[client] = 25;
	FusionWarrior_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	FusionWarrior_BEAM_ChargeUpTime[client] = 200;
	FusionWarrior_BEAM_CloseBuildingDPT[client] = 0.0;
	FusionWarrior_BEAM_FarBuildingDPT[client] = 0.0;
	FusionWarrior_BEAM_Duration[client] = 4.0;
	
	FusionWarrior_BEAM_BeamOffset[client][0] = 0.0;
	FusionWarrior_BEAM_BeamOffset[client][1] = 0.0;
	FusionWarrior_BEAM_BeamOffset[client][2] = 0.0;

	FusionWarrior_BEAM_ZOffset[client] = 0.0;
	FusionWarrior_BEAM_UseWeapon[client] = false;

	FusionWarrior_BEAM_IsUsing[client] = true;
	FusionWarrior_BEAM_TicksActive[client] = 0;
	
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", client, SNDCHAN_STATIC, 120, _, 1.0, 75);
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", _, _, _, _, 1.0);			
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", _, _, _, _, 1.0);
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);	
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", _, _, _, _, 1.0);			
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", _, _, _, _, 1.0);
		}		
	}
			

	CreateTimer(5.0, TrueFusionWarrior_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
	
}

public Action TrueFusionWarrior_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	FusionWarrior_BEAM_IsUsing[client] = false;
	
	FusionWarrior_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}



public bool FusionWarrior_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

public bool FusionWarrior_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		FusionWarrior_BEAM_HitDetected[entity] = true;
	}
	return false;
}

static void FusionWarrior_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	TrueFusionWarrior npc = view_as<TrueFusionWarrior>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == FusionWarrior_BEAM_BeamOffset[client][0] && 0.0 == FusionWarrior_BEAM_BeamOffset[client][1] && 0.0 == FusionWarrior_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = FusionWarrior_BEAM_BeamOffset[client][0];
	tmp[1] = FusionWarrior_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = FusionWarrior_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

public Action TrueFusionWarrior_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !FusionWarrior_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, TrueFusionWarrior_TBB_Tick);
		TrueFusionWarrior npc = view_as<TrueFusionWarrior>(client);
		npc.m_bInKame = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	FusionWarrior_BEAM_TicksActive[client] = tickCount;
	float diameter = float(FusionWarrior_BEAM_BeamRadius[client] * 2);
	int r = GetR(FusionWarrior_BEAM_ColorHex[client]);
	int g = GetG(FusionWarrior_BEAM_ColorHex[client]);
	int b = GetB(FusionWarrior_BEAM_ColorHex[client]);
	if (FusionWarrior_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		TrueFusionWarrior npc = view_as<TrueFusionWarrior>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, FusionWarrior_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(FusionWarrior_BEAM_MaxDistance[client]));
			float lineReduce = FusionWarrior_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				FusionWarrior_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(FusionWarrior_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, FusionWarrior_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (FusionWarrior_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = FusionWarrior_BEAM_CloseDPT[client] + (FusionWarrior_BEAM_FarDPT[client]-FusionWarrior_BEAM_CloseDPT[client]) * (distance/FusionWarrior_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					if(victim > MAXTF2PLAYERS)
					{
						damage *= 3.0; //give 3x dmg to anything
					}

					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			
			static float belowBossEyes[3];
			FusionWarrior_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, FusionWarrior_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, FusionWarrior_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}

public Action Fusion_RepeatSound_Doublevoice(Handle timer, DataPack pack)
{
	pack.Reset();
	char sound[128];
	pack.ReadString(sound, 128);
	int entity = EntRefToEntIndex(pack.ReadCell());
	if(IsValidEntity(entity) && entity>MaxClients)
	{
		EmitSoundToAll(sound, entity, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	return Plugin_Handled; 
}

public void TrueFusionwarrior_IOC_Invoke(int ref, int enemy)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		static float distance=87.0; // /29 for duartion till boom
		static float IOCDist=250.0;
		static float IOCdamage=10.0;
		
		float vecTarget[3];
		GetEntPropVector(enemy, Prop_Data, "m_vecAbsOrigin", vecTarget);
		
		Handle data = CreateDataPack();
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackCell(data, distance); // Distance
		WritePackFloat(data, 0.0); // nphi
		WritePackCell(data, IOCDist); // Range
		WritePackCell(data, IOCdamage); // Damge
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

	public void TrueFusionwarrior_IonAttack(Handle &data)
	{
		float startPosition[3];
		float position[3];
		startPosition[0] = ReadPackFloat(data);
		startPosition[1] = ReadPackFloat(data);
		startPosition[2] = ReadPackFloat(data);
		float Iondistance = ReadPackCell(data);
		float nphi = ReadPackFloat(data);
		int Ionrange = ReadPackCell(data);
		int Iondamage = ReadPackCell(data);
		int client = EntRefToEntIndex(ReadPackCell(data));
		
		if(!IsValidEntity(client))
		{
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
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
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
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
			// Stage 3
			s=Sine((nphi+90.0)/360*6.28)*Iondistance;
			c=Cosine((nphi+90.0)/360*6.28)*Iondistance;
			
			position[0] = startPosition[0];
			position[1] = startPosition[1];
			position[0] += s;
			position[1] += c;
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
			
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
			TrueFusionwarrior_DrawIonBeam(position, {212, 175, 55, 255});
	
			if (nphi >= 360)
				nphi = 0.0;
			else
				nphi += 5.0;
		}
		Iondistance -= 10;
		
		Handle nData = CreateDataPack();
		WritePackFloat(nData, startPosition[0]);
		WritePackFloat(nData, startPosition[1]);
		WritePackFloat(nData, startPosition[2]);
		WritePackCell(nData, Iondistance);
		WritePackFloat(nData, nphi);
		WritePackCell(nData, Ionrange);
		WritePackCell(nData, Iondamage);
		WritePackCell(nData, EntIndexToEntRef(client));
		ResetPack(nData);
		
		if (Iondistance > -30)
		CreateTimer(0.1, TrueFusionwarrior_DrawIon, nData, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		else
		{
			startPosition[2] += 25.0;
			if(!b_Anger[client])
				makeexplosion(client, client, startPosition, "", RoundToCeil(35.0 * RaidModeScaling), 100);
				
			else if(b_Anger[client])
				makeexplosion(client, client, startPosition, "", RoundToCeil(50.0 * RaidModeScaling), 120);
				
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
			TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 2.0, 80.0, 80.0, 0, 1.0, {212, 175, 55, 120}, 3);
			TE_SendToAll();
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