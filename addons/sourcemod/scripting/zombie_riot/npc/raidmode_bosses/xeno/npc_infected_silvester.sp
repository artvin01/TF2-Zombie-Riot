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

#define LASERBEAM "sprites/laserbeam.vmt"
#define LINKBEAM "sprites/glow01.vmt"


static bool Silvester_BEAM_CanUse[MAXENTITIES];
static bool Silvester_BEAM_IsUsing[MAXENTITIES];
static int Silvester_BEAM_TicksActive[MAXENTITIES];
static int Silvester_BEAM_Laser;
static int Silvester_BEAM_Glow;
static float Silvester_BEAM_CloseDPT[MAXENTITIES];
static float Silvester_BEAM_FarDPT[MAXENTITIES];
static int Silvester_BEAM_MaxDistance[MAXENTITIES];
static int Silvester_BEAM_BeamRadius[MAXENTITIES];
static int Silvester_BEAM_ColorHex[MAXENTITIES];
static int Silvester_BEAM_ChargeUpTime[MAXENTITIES];
static float Silvester_BEAM_CloseBuildingDPT[MAXENTITIES];
static float Silvester_BEAM_FarBuildingDPT[MAXENTITIES];
static float Silvester_BEAM_Duration[MAXENTITIES];
static float Silvester_BEAM_BeamOffset[MAXENTITIES][3];
static float Silvester_BEAM_ZOffset[MAXENTITIES];
static bool Silvester_BEAM_HitDetected[MAXENTITIES];
static bool Silvester_BEAM_UseWeapon[MAXENTITIES];
static float fl_Timebeforekamehameha[MAXENTITIES];
static int i_InKame[MAXENTITIES];

public void RaidbossSilvester_OnMapStart()
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
	Silvester_TBB_Precahce();
	
	PrecacheSound("player/flow.wav");
	PrecacheModel(LINKBEAM);
}

void Silvester_TBB_Precahce()
{
	Silvester_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	Silvester_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
}

#define EMPOWER_SOUND "items/powerup_pickup_king.wav"
#define EMPOWER_MATERIAL "materials/sprites/laserbeam.vmt"
#define EMPOWER_WIDTH 5.0
#define EMPOWER_HIGHT_OFFSET 20.0

static int i_TargetToWalkTo[MAXENTITIES];
static float f_TargetToWalkToDelay[MAXENTITIES];
static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static int i_RaidDuoAllyIndex;

methodmap RaidbossSilvester < CClotBody
{


	property float m_flTimebeforekamehameha
	{
		public get()							{ return fl_Timebeforekamehameha[this.index]; }
		public set(float TempValueForProperty) 	{ fl_Timebeforekamehameha[this.index] = TempValueForProperty; }
	}
	property int m_iInKame
	{
		public get()							{ return i_InKame[this.index]; }
		public set(int TempValueForProperty) 	{ i_InKame[this.index] = TempValueForProperty; }
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
	public RaidbossSilvester(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		RaidbossSilvester npc = view_as<RaidbossSilvester>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.35", "25000", ally, false, true, true,true)); //giant!
		
		i_NpcInternalId[npc.index] = XENO_RAIDBOSS_SILVESTER;
		
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
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		
		SDKHook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
		SDKHook(npc.index, SDKHook_OnTakeDamage, RaidbossSilvester_ClotDamaged);
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/all_class/bak_buttler/bak_buttler_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
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
		
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, 192, 192, 192, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, 192, 192, 192, 255);
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
		//IDLE
		npc.m_flSpeed = 330.0;


		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 5.0;
		npc.m_flNextRangedSpecialAttackHappens = 0.0;
		
		Citizen_MiniBossSpawn(npc.index);
		npc.StartPathing();

		
		npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 20.0;
		npc.m_iInKame = 0;


		//Spawn in the duo raid inside him, i didnt code for duo raids, so if one dies, it will give the timer to the other and vise versa.
		
		RequestFrame(Silvester_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		return npc;
	}
}

//TODO 
//Rewrite
public void RaidbossSilvester_ClotThink(int iNPC)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(iNPC);
	
	//Raidmode timer runs out, they lost.
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); 
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		SDKUnhook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
	}

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

	npc.Update();

	//Think throttling
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;
	if(f_TargetToWalkToDelay[npc.index] < GetGameTime(npc.index))
	{
		if(npc.m_iInKame == 2)
		{
			i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(i_TargetToWalkTo[npc.index] == -1)
			{
				i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
			}
		}
		else
		{
			i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
		}
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	
	if(npc.m_iInKame == 2)
	{
		if(i_TargetToWalkTo[npc.index] != -1)
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(i_TargetToWalkTo[npc.index]);
			npc.FaceTowards(vecTarget, 600.0);
		}
		PF_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
	}
	else if(npc.m_iInKame == 1)
	{
		PF_StartPathing(npc.index);
		npc.m_bPathing = true;
		npc.m_flSpeed = 330.0;
		npc.m_iInKame = 0;
	}


	//link up to ally and take dmg from them.
	int AllyEntity = EntRefToEntIndex(i_RaidDuoAllyIndex);
	if(IsEntityAlive(AllyEntity))
	{
		static float victimPos[3];
		static float partnerPos[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
		GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
		float Distance = GetVectorDistance(victimPos, partnerPos, true);
		if(Distance < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 5.0, 2.0) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
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
					SetEntityRenderMode(laserentity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(laserentity, 255, 0, 0, 255);
				}
				else
				{
					SetEntityRenderMode(laserentity, RENDER_TRANSCOLOR);
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
		AllyEntity = -1;
	}

	if(npc.m_iInKame == 3)
	{
		if(AllyEntity != -1)
		{
			i_TargetToWalkTo[npc.index] = AllyEntity;
			npc.m_flSpeed = 330.0;
		}
	}
	if(npc.m_flNextRangedSpecialAttackHappens && npc.m_flNextRangedSpecialAttackHappens != 1.0)
	{
		if(AllyEntity != -1)
		{
			i_TargetToWalkTo[npc.index] = AllyEntity;
			npc.m_flSpeed = 500.0;
		}
		else
		{
			npc.m_flSpeed = 150.0;
		}

		spawnRing(npc.index, NORMAL_ENEMY_MELEE_RANGE_FLOAT * 3.0 * 2.0, 0.0, 0.0, EMPOWER_HIGHT_OFFSET, EMPOWER_MATERIAL, 231, 181, 59, 125, 10, 0.11, EMPOWER_WIDTH, 6.0, 10);
		
		for(int EnemyLoop; EnemyLoop < MaxClients; EnemyLoop ++)
		{
			if(IsValidEnemy(npc.index, EnemyLoop))
			{
				if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
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
			for(int EnemyLoop; EnemyLoop < MaxClients; EnemyLoop ++)
			{
				if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
				{
					RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
				}	

				if(IsValidEnemy(npc.index, EnemyLoop))
				{
					if(IsValidClient(EnemyLoop) && Can_I_See_Enemy_Only(npc.index, EnemyLoop))
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
							float attraction_intencity = 1.5;
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
							float attraction_intencity = 1000.0;
							ScaleVector(velocity, attraction_intencity);
											
											
							// min Z if on ground
							if (GetEntityFlags(EnemyLoop) & FL_ONGROUND)
								velocity[2] = fmax(325.0, velocity[2]);
										
							// apply velocity
							velocity[0] *= -1.0;
							velocity[1] *= -1.0;
						//	velocity[2] *= -1.0;
							TeleportEntity(EnemyLoop, NULL_VECTOR, NULL_VECTOR, velocity);    
							RequestFrame(ApplySdkHookSilvesterThrow, EntIndexToEntRef(EnemyLoop));   					
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

	if(IsEntityAlive(i_TargetToWalkTo[npc.index]))
	{
		int ActionToTake = -1;

		//Predict their pos.
		float vecTarget[3]; vecTarget = WorldSpaceCenter(i_TargetToWalkTo[npc.index]);
		float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, i_TargetToWalkTo[npc.index]);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			PF_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			PF_SetGoalEntity(npc.index, i_TargetToWalkTo[npc.index]);
		}

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		
			
		//Body pitch
		float v[3], ang[3];
		SubtractVectors(WorldSpaceCenter(npc.index), WorldSpaceCenter(i_TargetToWalkTo[npc.index]), v); 
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
				
		float flPitch = npc.GetPoseParameter(iPitch);
				
		//	ang[0] = clamp(ang[0], -44.0, 89.0);
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

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
		else if(flDistanceToTarget < Pow(1000.0, 2.0) && npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
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
		else if(IsValidEnemy(npc.index, i_TargetToWalkTo[npc.index]))
		{
			if(npc.m_flTimebeforekamehameha < GetGameTime(npc.index))
			{
				ActionToTake = 2;
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
				if(AllyEntity != -1)
				{
					static float victimPos[3];
					static float partnerPos[3];
					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", partnerPos);
					GetEntPropVector(AllyEntity, Prop_Data, "m_vecAbsOrigin", victimPos); 
					float Distance = GetVectorDistance(victimPos, partnerPos, true);
					if(Distance < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 5.0, 2.0) && Can_I_See_Enemy_Only(npc.index, AllyEntity))
					{	
						npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 50.0;
						Silvester_TBB_Ability(npc.index);
						npc.m_iInKame = 2;
					}
				}
				else
				{
					npc.m_flTimebeforekamehameha = GetGameTime(npc.index) + 50.0;
					Silvester_TBB_Ability(npc.index);
					npc.m_iInKame = 2;
				}
			}
			default:
			{
	//			return;
			}
		}
	}
	else
	{
		i_TargetToWalkTo[npc.index] = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = GetGameTime(npc.index) + 1.0;
	}
	//This is for self defense, incase an enemy is too close, This exists beacuse
	//Silvester's main walking target might not be the closest target he has.
	if(npc.m_iInKame == 0)
	{
		RaidbossSilvesterSelfDefense(npc,GetGameTime(npc.index)); 
	}
}

	
public Action RaidbossSilvester_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
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

	return Plugin_Changed;
}

public void RaidbossSilvester_NPCDeath(int entity)
{
	RaidbossSilvester npc = view_as<RaidbossSilvester>(entity);
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	SDKUnhook(npc.index, SDKHook_Think, RaidbossSilvester_ClotThink);
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, RaidbossSilvester_ClotDamaged);
	
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
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + 1.0;
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				Handle swingTrace;
				npc.FaceTowards(WorldSpaceCenter(npc.m_iTarget), 15000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1)) //Big range, but dont ignore buildings if somehow this doesnt count as a raid to be sure.
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
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);
								
						if(npc.Anger)
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage_rage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);									
							
						
						// Hit particle
						
						
						// Hit sound
						npc.PlayMeleeHitSound();
						
						if(IsValidClient(target))
						{
							if (IsInvuln(target))
							{
								Custom_Knockback(npc.index, target, 900.0, true);
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
							else
							{
								Custom_Knockback(npc.index, target, 650.0); 
								TF2_AddCondition(target, TFCond_LostFooting, 0.5);
								TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
							}
						}
					} 
				}
				delete swingTrace;
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(npc.m_iTarget);

			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);

			if(flDistanceToTarget < Pow(NORMAL_ENEMY_MELEE_RANGE_FLOAT * 1.25, 2.0))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.6;
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


static bool b_AlreadyHitTankThrow[MAXENTITIES][MAXENTITIES];
static float fl_ThrowDelay[MAXENTITIES];
public Action contact_throw_Silvester_entity(int client)
{
	CClotBody npc = view_as<CClotBody>(client);
	float targPos[3];
	float chargerPos[3];
	float flVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVel);
	if (npc.IsOnGround() && fl_ThrowDelay[client] < GetGameTime(npc.index))
	{
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			b_AlreadyHitTankThrow[client][entity] = false;
		}

		SDKUnhook(client, SDKHook_Think, contact_throw_Silvester_entity);	
		return Plugin_Continue;
	}
	else
	{
		char classname[60];
		chargerPos = WorldSpaceCenter(client);
		for(int entity=1; entity <= MAXENTITIES; entity++)
		{
			if (IsValidEntity(entity) && !b_ThisEntityIgnored[entity])
			{
				GetEntityClassname(entity, classname, sizeof(classname));
				if (!StrContains(classname, "base_boss", true) || !StrContains(classname, "player", true) || !StrContains(classname, "obj_dispenser", true) || !StrContains(classname, "obj_sentrygun", true))
				{
					targPos = WorldSpaceCenter(entity);
					if (GetVectorDistance(chargerPos, targPos, true) <= Pow(125.0, 2.0) && GetEntProp(entity, Prop_Send, "m_iTeamNum")!=GetEntProp(client, Prop_Send, "m_iTeamNum"))
					{
						if (!b_AlreadyHitTankThrow[client][entity] && entity != client)
						{		
							int damage = GetEntProp(client, Prop_Data, "m_iMaxHealth") / 3;
							
							if(damage > 2000)
							{
								damage = 2000;
							}
							
							if(!ShouldNpcDealBonusDamage(entity))
							{
								damage *= 4;
							}
							
							SDKHooks_TakeDamage(entity, 0, 0, float(damage), DMG_GENERIC, -1, NULL_VECTOR, targPos);
							EmitSoundToAll("weapons/physcannon/energy_disintegrate5.wav", entity, SNDCHAN_STATIC, 80, _, 0.8);
							b_AlreadyHitTankThrow[client][entity] = true;
							if(entity <= MaxClients)
							{
								float newVel[3];
								
								newVel[0] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[0]") * 2.0;
								newVel[1] = GetEntPropFloat(entity, Prop_Send, "m_vecVelocity[1]") * 2.0;
								newVel[2] = 500.0;
												
								for (int i = 0; i < 3; i++)
								{
									flVel[i] += newVel[i];
								}				
								TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVel); 
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}


void ApplySdkHookSilvesterThrow(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		fl_ThrowDelay[entity] = GetGameTime(entity) + 0.1;
		SDKHook(entity, SDKHook_Think, contact_throw_Silvester_entity);		
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

		int spawn_index = Npc_Create(XENO_RAIDBOSS_BLUE_GOGGLES, -1, pos, ang, GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
		{
			i_RaidDuoAllyIndex = EntIndexToEntRef(spawn_index);
			Goggles_SetRaidPartner(entity);
			Zombies_Currently_Still_Ongoing += 1;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}




void Silvester_TBB_Ability(int client)
{
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
			
	Silvester_BEAM_IsUsing[client] = false;
	Silvester_BEAM_TicksActive[client] = 0;

	Silvester_BEAM_CanUse[client] = true;
	Silvester_BEAM_CloseDPT[client] = 16.0 * RaidModeScaling;
	Silvester_BEAM_FarDPT[client] = 12.0 * RaidModeScaling;
	Silvester_BEAM_MaxDistance[client] = 2000;
	Silvester_BEAM_BeamRadius[client] = 45;
	Silvester_BEAM_ColorHex[client] = ParseColor("EEDD44");
	Silvester_BEAM_ChargeUpTime[client] = 200;
	Silvester_BEAM_CloseBuildingDPT[client] = 0.0;
	Silvester_BEAM_FarBuildingDPT[client] = 0.0;
	Silvester_BEAM_Duration[client] = 6.0;
	
	Silvester_BEAM_BeamOffset[client][0] = 0.0;
	Silvester_BEAM_BeamOffset[client][1] = 0.0;
	Silvester_BEAM_BeamOffset[client][2] = 0.0;

	Silvester_BEAM_ZOffset[client] = 0.0;
	Silvester_BEAM_UseWeapon[client] = false;

	Silvester_BEAM_IsUsing[client] = true;
	Silvester_BEAM_TicksActive[client] = 0;
	
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
			

	CreateTimer(5.0, Silvester_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, Silvester_TBB_Tick);
}


public Action Silvester_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	Silvester_BEAM_IsUsing[client] = false;
	
	Silvester_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}


public bool Silvester_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_PLAYERS_ARRAY 36


public bool Silvester_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		Silvester_BEAM_HitDetected[entity] = true;
	}
	return false;
}

static void Silvester_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	RaidbossSilvester npc = view_as<RaidbossSilvester>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == Silvester_BEAM_BeamOffset[client][0] && 0.0 == Silvester_BEAM_BeamOffset[client][1] && 0.0 == Silvester_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = Silvester_BEAM_BeamOffset[client][0];
	tmp[1] = Silvester_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = Silvester_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

#define MAXTF2PLAYERS	36

public Action Silvester_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !Silvester_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, Silvester_TBB_Tick);
		RaidbossSilvester npc = view_as<RaidbossSilvester>(client);
		npc.m_iInKame = 1;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;

	Silvester_BEAM_TicksActive[client] = tickCount;
	float diameter = float(Silvester_BEAM_BeamRadius[client] * 2);
	int r = GetR(Silvester_BEAM_ColorHex[client]);
	int g = GetG(Silvester_BEAM_ColorHex[client]);
	int b = GetB(Silvester_BEAM_ColorHex[client]);
	if (Silvester_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		RaidbossSilvester npc = view_as<RaidbossSilvester>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, Silvester_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(Silvester_BEAM_MaxDistance[client]));
			float lineReduce = Silvester_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				Silvester_BEAM_HitDetected[i] = false;
			}
			
			
			hullMin[0] = -float(Silvester_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, Silvester_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (Silvester_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = Silvester_BEAM_CloseDPT[client] + (Silvester_BEAM_FarDPT[client]-Silvester_BEAM_CloseDPT[client]) * (distance/Silvester_BEAM_MaxDistance[client]);
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
			Silvester_GetBeamDrawStartPoint(client, belowBossEyes);
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3 * 1.28), ClampBeamWidth(diameter * 0.3 * 1.28), 0, 1.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5 * 1.28), ClampBeamWidth(diameter * 0.5 * 1.28), 0, 1.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8 * 1.28), ClampBeamWidth(diameter * 0.8 * 1.28), 0, 1.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, Silvester_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 1.28), ClampBeamWidth(diameter * 1.28), 0, 5.0, glowColor, 0);
			TE_SendToAll(0.0);
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}