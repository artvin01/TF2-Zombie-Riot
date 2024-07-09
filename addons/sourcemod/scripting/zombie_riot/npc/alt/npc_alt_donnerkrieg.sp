#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_painsharp01.mp3",
	"vo/medic_painsharp02.mp3",
	"vo/medic_painsharp03.mp3",
	"vo/medic_painsharp04.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/ubersaw_hit1.wav",
	"weapons/ubersaw_hit2.wav",
	"weapons/ubersaw_hit3.wav",
	"weapons/ubersaw_hit4.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/knife_swing.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};

static char g_RangedAttackSounds[][] = {
	"weapons/capper_shoot.wav",
};
//static j1

static bool b_nightmare_logic[MAXENTITIES];
static float fl_nightmare_grace_period[MAXENTITIES];
static bool b_fuck_you_line_used[MAXENTITIES];
static bool b_train_line_used[MAXENTITIES];
static float fl_cannon_Recharged[MAXENTITIES];

static bool b_fucking_volvo[MAXENTITIES];

static float fl_nightmare_end_timer[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];

static bool b_health_stripped[MAXENTITIES];

static bool NightmareCannon_BEAM_CanUse[MAXENTITIES];
static bool NightmareCannon_BEAM_IsUsing[MAXENTITIES];
static int NightmareCannon_BEAM_TicksActive[MAXENTITIES];
static int NightmareCannon_BEAM_Laser;
static int NightmareCannon_BEAM_Glow;
static float NightmareCannon_BEAM_CloseDPT[MAXENTITIES];
static float NightmareCannon_BEAM_FarDPT[MAXENTITIES];
static int NightmareCannon_BEAM_MaxDistance[MAXENTITIES];
static int NightmareCannon_BEAM_BeamRadius[MAXENTITIES];
static int NightmareCannon_BEAM_ColorHex[MAXENTITIES];
static int NightmareCannon_BEAM_ChargeUpTime[MAXENTITIES];
static float NightmareCannon_BEAM_CloseBuildingDPT[MAXENTITIES];
static float NightmareCannon_BEAM_FarBuildingDPT[MAXENTITIES];
static float NightmareCannon_BEAM_Duration[MAXENTITIES];
static float NightmareCannon_BEAM_BeamOffset[MAXENTITIES][3];
static float NightmareCannon_BEAM_ZOffset[MAXENTITIES];
static bool NightmareCannon_BEAM_HitDetected[MAXENTITIES];
static int NightmareCannon_BEAM_BuildingHit[MAXENTITIES];
static bool NightmareCannon_BEAM_UseWeapon[MAXENTITIES];

static float fl_AlreadyStrippedMusic[MAXTF2PLAYERS];



static int i_SaidLineAlready[MAXENTITIES];


static bool b_InKame[MAXENTITIES];
static bool b_enraged=false;

void Donnerkrieg_OnMapStart_NPC()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_RangedAttackSounds);
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	NightmareCannon_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	NightmareCannon_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Donnerkrieg");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_alt_donnerkrieg");
	data.Category = Type_Alt;
	data.Func = ClotSummon;
	strcopy(data.Icon, sizeof(data.Icon), "donner"); 		//leaderboard_class_(insert the name)
	data.IconCustom = true;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);

}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Donnerkrieg(client, vecPos, vecAng, ally, data);
}

methodmap Donnerkrieg < CClotBody
{
	property int m_iAmountProjectiles
	{
		public get()							{ return i_AmountProjectiles[this.index]; }
		public set(int TempValueForProperty) 	{ i_AmountProjectiles[this.index] = TempValueForProperty; }
	}
	property bool m_bInKame
	{
		public get()							{ return b_InKame[this.index]; }
		public set(bool TempValueForProperty) 	{ b_InKame[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	
	public Donnerkrieg(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Donnerkrieg npc = view_as<Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		for(int client_clear=1; client_clear<=MaxClients; client_clear++)
		{
			fl_AlreadyStrippedMusic[client_clear] = 0.0; //reset to 0
		}
		bool final = StrContains(data, "raid_ally") != -1;
		
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		else
		{
			RaidModeScaling = 10.0;	//just a safety net
			if(!IsValidEntity(RaidBossActive))
			{
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime(npc.index) + 9000.0;
				RaidAllowsBuildings = true;
			}
		}

		func_NPCDeath[npc.index] = view_as<Function>(Internal_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(Internal_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(Internal_ClotThink);
			
		g_b_donner_died=false;

		b_enraged=false;

		b_health_stripped[npc.index] = false;
		//IDLE
		npc.m_flSpeed = 300.0;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/Sbox2014_Medic_Colonel_Coat/Sbox2014_Medic_Colonel_Coat.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
					
		npc.GetAttachment("effect_hand_l", flPos, flAng);
		npc.m_iWearable1 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "effect_hand_l", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		//SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", 1);
		npc.StartPathing();
		
		b_fuck_you_line_used[npc.index] = false;
		b_train_line_used[npc.index] = false;
		b_nightmare_logic[npc.index] = false;
		fl_nightmare_grace_period[npc.index] = 0.0;
		b_fucking_volvo[npc.index] = false;
		
		
		fl_nightmare_end_timer[npc.index]= GetGameTime(npc.index) + 10.0;
		fl_cannon_Recharged[npc.index]= GetGameTime(npc.index) + 10.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{crimson}Donnerkrieg{default}: I have arrived to render judgement");
		
		g_b_angered=false;

		npc.m_bThisNpcIsABoss = true;

		//b_Begin_Dialogue = true;
		
	//	b_Schwertkrieg_Alive = false;
		
		//RaidModeTime = GetGameTime() + 100.0;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void Internal_ClotThink(int iNPC)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(ZR_GetWaveCount()+1 >=60 && EntRefToEntIndex(RaidBossActive)==npc.index && i_RaidGrantExtra[npc.index] == 1)	//donnerkrieg handles the timer if its the same index
	{
		if(RaidModeTime < GameTime)
		{
			ForcePlayerLoss();
			RaidBossActive = INVALID_ENT_REFERENCE;
			func_NPCThink[npc.index] = INVALID_FUNCTION;
		}
	}
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	if(!IsValidEntity(RaidBossActive) && !g_b_donner_died && ZR_GetWaveCount()+1 >=60 && i_RaidGrantExtra[npc.index] == 1)
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}
	else
	{
		if(ZR_GetWaveCount()+1 >=60 && EntRefToEntIndex(RaidBossActive)==npc.index && g_b_donner_died && i_RaidGrantExtra[npc.index] == 1)
		{
			RaidBossActive = INVALID_ENT_REFERENCE;
		}
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	if(g_b_angered && !b_enraged)
	{
		if(!b_nightmare_logic[npc.index])
		{
			fl_cannon_Recharged[npc.index]=0.0;
			b_enraged=true;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	if(g_b_donner_died && g_b_item_allowed && i_RaidGrantExtra[npc.index] == 1)
	{
		npc.m_flNextThinkTime = 0.0;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(g_b_schwert_died && !IsValidEntity(RaidBossActive))
		{
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
			if(GameTime > g_f_blitz_dialogue_timesincehasbeenhurt)
			{
				CPrintToChatAll("{crimson}Donnerkrieg{default}: Blitzkrieg's army is happy to serve you as thanks for setting us free...");
				npc.m_bDissapearOnDeath = true;

				CPrintToChatAll("{aqua}Stella{snow}: Oh also our true names are, {aqua}Stella{snow}, thats me");
				CPrintToChatAll("{aqua}Stella{snow}: And hes {crimson}Karlas{snow}!");
				
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
				for (int client = 0; client < MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
					{
						Items_GiveNamedItem(client, "Blitzkrieg's Army");
						CPrintToChat(client,"{default}You now have access to: {crimson}''Blitzkrieg's Army''{default}!");
					}
				}
			}
			else if(GameTime + 3.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 8)
			{
				i_SaidLineAlready[npc.index] = 8;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: With Blitzkrieg gone, the army has been set free, and so...");
			}
			else if(GameTime + 5.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 7)
			{
				i_SaidLineAlready[npc.index] = 7;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: However, that doesn't matter anymore");
			}
			else if(GameTime + 8.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 6)
			{
				i_SaidLineAlready[npc.index] = 6;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: The corruption had fully gotten to him");
			}
			else if(GameTime + 10.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 5)
			{
				i_SaidLineAlready[npc.index] = 5;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: If we hadn't complied he would have destroyed us");
			}
			else if(GameTime + 12.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 4)
			{
				i_SaidLineAlready[npc.index] = 4;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: We had no choice.");
			}
			else if(GameTime + 14.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 3)
			{
				i_SaidLineAlready[npc.index] = 3;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: We don't have to fight anymore, for you see...");
			}
			else if(GameTime + 16.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 2)
			{
				i_SaidLineAlready[npc.index] = 2;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: You Stopped The rouge Machine.");
			}
			else if(GameTime + 18.0 > g_f_blitz_dialogue_timesincehasbeenhurt && i_SaidLineAlready[npc.index] < 1)
			{
				i_SaidLineAlready[npc.index] = 1;
				CPrintToChatAll("{crimson}Donnerkrieg{default}: Wait no please stop");
				ReviveAll(true);
			}
		}
		if(npc.m_bInKame)
		{
			npc.m_bInKame = false;
			
			npc.m_flRangedArmor = 1.0;
	
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				
			NightmareCannon_BEAM_IsUsing[npc.index] = false;
		
			NightmareCannon_BEAM_TicksActive[npc.index] = 0;
			
			fl_nightmare_end_timer[npc.index] = 0.0;
			
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", npc.index, SNDCHAN_STATIC, 80, _, 1.0);
		}
		return; //He is trying to help.
	}
	if(fl_nightmare_end_timer[npc.index] < GameTime && b_nightmare_logic[npc.index])
	{	
		npc.m_flRangedArmor = 1.0;
		b_nightmare_logic[npc.index] = false;
		
		if(g_b_angered)
		{
			fl_cannon_Recharged[npc.index] = GameTime + 30.0;
		}
		else		
		{		
			fl_cannon_Recharged[npc.index] = GameTime + 90.0;
		}
		npc.m_flSpeed = 300.0;
		
		f_NpcTurnPenalty[npc.index] = 1.0;	//:)
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);

		if(IsValidEntity(npc.m_iWearable5))
			RemoveEntity(npc.m_iWearable5);
		if(IsValidEntity(npc.m_iWearable6))
			RemoveEntity(npc.m_iWearable6);
		
	}
	int PrimaryThreatIndex = npc.m_iTarget;
		
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_cannon_Recharged[npc.index]<GameTime && !b_nightmare_logic[npc.index])
		{
			fl_nightmare_end_timer[npc.index] = GameTime + 20.0;
			Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		if(!b_nightmare_logic[npc.index])
		{	
	
			float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
				
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; PredictSubjectPosition(npc, PrimaryThreatIndex,_,_, vPredictedPos);
				
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
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
				
			if(g_b_angered)	//thanks to the loss of his companion donner has gained A NECK
			{
				int iPitch = npc.LookupPoseParameter("body_pitch");
				if(iPitch < 0)
					return;		
					
				//Body pitch
				float v[3], ang[3];
				float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
				float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec2);
				SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
				NormalizeVector(v, v);
				GetVectorAngles(v, ang); 
						
				float flPitch = npc.GetPoseParameter(iPitch);
						
				npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
			}
			if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0))
			{	

				npc.FaceTowards(vecTarget);
				float projectile_speed = 400.0;
				PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed,_,vecTarget);
				if(g_b_angered)
				{
					npc.FireParticleRocket(vecTarget, 125.0*RaidModeScaling , 400.0 , 100.0 , "raygun_projectile_blue");
				}
				else
				{
					npc.FireParticleRocket(vecTarget, 25.0*RaidModeScaling , 400.0 , 100.0 , "raygun_projectile_blue");
				}
					
				//(Target[3],dmg,speed,radius,"particle",bool do_aoe_dmg(default=false), bool frombluenpc (default=true), bool Override_Spawn_Loc (default=false), if previus statement is true, enter the vector for where to spawn the rocket = vec[3], flags)

				npc.m_iAmountProjectiles += 1;
				npc.PlayRangedSound();
				npc.AddGesture("ACT_MP_THROW");
				npc.m_flNextRangedBarrage_Singular = GameTime + 0.15;
				if (npc.m_iAmountProjectiles >= 15.0)
				{
					npc.m_iAmountProjectiles = 0;
					npc.m_flNextRangedBarrage_Spam = GameTime + 45.0;
				}
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GameTime+0.4;
						npc.m_flAttackHappens_bullshit = GameTime+0.54;
						npc.m_flAttackHappenswillhappen = true;
						npc.FaceTowards(vecTarget);
						Normal_Attack_BEAM_TBB_Ability(npc.index);
						
						if(flDistanceToTarget < 100.0*100.0)	//to prevent players from sitting ontop of donnerkrieg and just stabing his head
						{
							Handle swingTrace;
							if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex, _, _, _, 1))
							{
								int target = TR_GetEntityIndex(swingTrace);	
							
								float vecHit[3];
								TR_GetEndPosition(vecHit, swingTrace);
								
								if(target > 0) 
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 22.0*RaidModeScaling, DMG_CLUB, -1, _, vecHit);						
								} 
							}
							delete swingTrace;
						}
					}
					if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.6;
					}
				}
			}
			else
			{
				npc.StartPathing();
			}
		}
		else
		{
			Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		
	}
	else
	{
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}

	if(!npc.m_bInKame && !b_nightmare_logic[npc.index])
	{
		npc.StartPathing();
	}
	npc.PlayIdleAlertSound();
}

static void Donnerkrieg_Nightmare_Logic(int ref, int PrimaryThreatIndex)
{

				
	Donnerkrieg npc = view_as<Donnerkrieg>(ref);
	

	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);

	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bInKame)
	{
		if(!b_nightmare_logic[npc.index])
		{
			if(g_b_angered)
			{
				fl_nightmare_grace_period[npc.index] = GameTime + 1.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			}
			else
			{
				fl_nightmare_grace_period[npc.index] = GameTime + 10.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
			}
			
			b_nightmare_logic[npc.index] = true;
			
			switch(GetRandomInt(1,6))
			{
				case 1:
				{
					CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}Thats it {default}i'm going to kill you");	
				}
				case 2:
				{
					CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}hm, {default}Wonder how this will end...");	
				}
				case 3:
				{
					CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}PREPARE {default}Thyself, {yellow}Judgement {default}Is near");	
				}
				case 4:
				{
					switch(GetRandomInt(0,10))
					{
						case 5:
						{
							CPrintToChatAll("{crimson}Donnerkrieg{default}: Oh not again now train's gone and {crimson}Left{default}.");	
							b_train_line_used[npc.index] = true;
						}				
						default:
						{
							CPrintToChatAll("{crimson}Donnerkrieg{default}: Oh not again now cannon's gone and {crimson}recharged{default}.");	
						}
							
					}
				}
				case 5:
				{
					CPrintToChatAll("{crimson}Donnerkrieg{default}: Aiming this thing is actually quite {crimson}complex {default}ya know.");	
					b_fuck_you_line_used[npc.index] = true;
				}
				case 6:
				{
					CPrintToChatAll("{crimson}Donnerkrieg{default}: Ya know, im getting quite bored of {crimson}this");	
				}
			}
			
			EmitSoundToAll("mvm/mvm_cpoint_klaxon.wav");
		}
		else
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				npc.StartPathing();
				float vBackoffPos[3];
				BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex,_,vBackoffPos);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);
				
				if(fl_nightmare_grace_period[npc.index]<GameTime)
				{
					fl_nightmare_grace_period[npc.index] = GameTime + 99.0;
					if(!b_fuck_you_line_used[npc.index] && !b_train_line_used[npc.index])
					{	
						switch(GetRandomInt(1,3))
						{
							case 1:
							{
								CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}NIGHTMARE, CANNON!");
							}
							case 2:
							{
								CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}JUDGEMENT BE UPON THEE!");
							}
							case 3:
							{
								CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}Annihilation!");	
							}
						}
					}
					else
					{
						if(b_train_line_used[npc.index])
						{
							CPrintToChatAll("{crimson}Donnerkrieg{default}: {crimson}And the city's to far to walk to the end while I...");	
							b_train_line_used[npc.index] = false;
						}
						else if(b_fuck_you_line_used[npc.index])
						{
							b_fuck_you_line_used[npc.index] = false;
							CPrintToChatAll("{crimson}Donnerkrieg{default}: However its still{crimson} worth the effort");	
						}
						
					}
					
					f_NpcTurnPenalty[npc.index] = 0.01;	//:)
					
					npc.m_bInKame = true;
					
					npc.m_flRangedArmor = 0.5;
						
					float flPos[3]; // original
					float flAng[3]; // original
						
					npc.GetAttachment("root", flPos, flAng);
					npc.m_iWearable5 = ParticleEffectAt_Parent(flPos, "utaunt_portalswirl_purple_parent", npc.index, "root", {0.0,0.0,0.0});
					npc.GetAttachment("root", flPos, flAng);
					npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_runeprison_yellow_parent", npc.index, "root", {0.0,0.0,0.0});
						
					npc.FaceTowards(vecTarget, 20000.0);	//TURN DAMMIT
						
						
					if(g_b_angered)
					{
						//npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					else
					{
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					
					EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
					CreateTimer(1.0, Donner_Nightmare_Offset, EntRefToEntIndex(npc.index), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				npc.StartPathing();
				
				NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
			}
		}
		
	}
	else
	{
		
		if(g_b_angered)	//thanks to the loss of his companion donner has gained A NECK
		{
			int iPitch = npc.LookupPoseParameter("body_pitch");
			if(iPitch < 0)
				return;		
						
			//Body pitch
			float v[3], ang[3];
			float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
			float WorldSpaceVec2[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec2);
			SubtractVectors(WorldSpaceVec, WorldSpaceVec2, v); 
			NormalizeVector(v, v);
			GetVectorAngles(v, ang); 
							
			float flPitch = npc.GetPoseParameter(iPitch);
							
			npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}
				
		npc.StartPathing();
		
		NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		
		float WorldSpaceVec[3]; WorldSpaceCenter(PrimaryThreatIndex, WorldSpaceVec);
		if(g_b_angered)
		{
			npc.FaceTowards(WorldSpaceVec, 150.0);
		}
		else
		{
			npc.FaceTowards(WorldSpaceVec, 5.0);
		}
		
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flSpeed = 0.0;
		npc.m_flGetClosestTargetTime = 0.0;
	}
}

static Action Donner_Nightmare_Offset(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(IsValidEntity(client))
	{
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		fl_nightmare_end_timer[npc.index] = GetGameTime(npc.index) + 15.0;
		NightmareCannon_TBB_Ability(npc.index);
	}
	return Plugin_Handled;
}
static Action Internal_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(victim);
	
	
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");	//npc becomes imortal when at 1 hp and when its a valid wave	//warp_item
	if(RoundToCeil(damage)>=Health && ZR_GetWaveCount()+1>=60.0 && i_RaidGrantExtra[npc.index] == 1)
	{
		if(g_b_item_allowed)
		{
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(20.0);


			SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
		}
		if(!g_b_donner_died)
		{
			g_b_donner_died=true;
			g_b_angered=true;
			RaidModeTime += 22.5;
			npc.m_bThisNpcIsABoss = false;
			if(EntRefToEntIndex(RaidBossActive)==npc.index)
				RaidBossActive = INVALID_ENT_REFERENCE;
			g_f_blitz_dialogue_timesincehasbeenhurt = GetGameTime(npc.index)+20.0;
		}
		if(npc.m_bInKame)
		{
			npc.m_bInKame = false;
			
			npc.m_flRangedArmor = 1.0;
	
			if(IsValidEntity(npc.m_iWearable5))
				RemoveEntity(npc.m_iWearable5);
			if(IsValidEntity(npc.m_iWearable6))
				RemoveEntity(npc.m_iWearable6);
				
			NightmareCannon_BEAM_IsUsing[npc.index] = false;
		
			NightmareCannon_BEAM_TicksActive[npc.index] = 0;
			
			fl_nightmare_end_timer[npc.index] = 0.0;
			
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
			EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", npc.index, SNDCHAN_STATIC, 80, _, 1.0);
		}
		return Plugin_Handled;
	}
	return Plugin_Changed;
}

static void Internal_NPCDeath(int entity)
{
	Donnerkrieg npc = view_as<Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
	b_NpcIsInvulnerable[npc.index] = false;
			
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
	
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))	//particles
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))	//temp particles
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))	//temp particles
		RemoveEntity(npc.m_iWearable6);
}
void Normal_Attack_BEAM_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NightmareCannon_BEAM_BuildingHit[building] = false;
	}
			
	NightmareCannon_BEAM_IsUsing[client] = false;
	NightmareCannon_BEAM_TicksActive[client] = 0;

	NightmareCannon_BEAM_CanUse[client] = true;

	float dmg = 20.0*RaidModeScaling;
	if(g_b_angered)
	{
		dmg *= 1.5;
	}
	NightmareCannon_BEAM_CloseDPT[client] = dmg;
	NightmareCannon_BEAM_FarDPT[client] = dmg;
	NightmareCannon_BEAM_MaxDistance[client] = 1000;
	NightmareCannon_BEAM_BeamRadius[client] = 10;
	NightmareCannon_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	NightmareCannon_BEAM_ChargeUpTime[client] = RoundToFloor(12 * TickrateModify);
	NightmareCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_FarBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_Duration[client] = 0.25;
	
	NightmareCannon_BEAM_BeamOffset[client][0] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][1] = 0.0;
	NightmareCannon_BEAM_BeamOffset[client][2] = 0.0;

	NightmareCannon_BEAM_ZOffset[client] = 0.0;
	NightmareCannon_BEAM_UseWeapon[client] = false;

	NightmareCannon_BEAM_IsUsing[client] = true;
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
	switch(GetRandomInt(1, 4))
	{
		case 1:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
			EmitSoundToAll("weapons/physcannon/superphys_launch1.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}
		case 2:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch2.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}
		case 3:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch3.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);				
		}
		case 4:
		{
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
			EmitSoundToAll("weapons/physcannon/superphys_launch4.wav", client, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);	
		}		
	}
			

	CreateTimer(NightmareCannon_BEAM_Duration[client], NightmareCannon_TBB_Timer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
	
}
void NightmareCannon_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		NightmareCannon_BEAM_BuildingHit[building] = false;
	}
	
	float WorldSpaceVec[3]; WorldSpaceCenter(client, WorldSpaceVec);
	ParticleEffectAt(WorldSpaceVec, "eyeboss_death_vortex", 2.0);
	EmitSoundToAll("mvm/mvm_tank_ping.wav");
			
	NightmareCannon_BEAM_IsUsing[client] = false;
	NightmareCannon_BEAM_TicksActive[client] = 0;

	NightmareCannon_BEAM_CanUse[client] = true;
	float dmg = 500.0*RaidModeScaling;
	if(g_b_angered)
	{
		dmg *= 1.5;
	}
	NightmareCannon_BEAM_CloseDPT[client] = dmg;
	NightmareCannon_BEAM_FarDPT[client] = dmg;
	NightmareCannon_BEAM_MaxDistance[client] = 10000;
	NightmareCannon_BEAM_BeamRadius[client] = 150;
	NightmareCannon_BEAM_ColorHex[client] = ParseColor("ff0303");
	NightmareCannon_BEAM_ChargeUpTime[client] = RoundToFloor(150 * TickrateModify);
	NightmareCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_FarBuildingDPT[client] = 0.0;
	NightmareCannon_BEAM_Duration[client] = 15.0;
	
	NightmareCannon_BEAM_BeamOffset[client][0] = 0.0;	//forward/back
	NightmareCannon_BEAM_BeamOffset[client][1] = -1.0;	//left right
	NightmareCannon_BEAM_BeamOffset[client][2] = 25.0;	//up down

	NightmareCannon_BEAM_ZOffset[client] = 0.0;
	NightmareCannon_BEAM_UseWeapon[client] = false;

	NightmareCannon_BEAM_IsUsing[client] = true;
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
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
			

	CreateTimer(NightmareCannon_BEAM_Duration[client], NightmareCannon_TBB_Timer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
	
}
public Action NightmareCannon_TBB_Timer(Handle timer, int ref)
{
	int client = EntRefToEntIndex(ref);
	if(!IsValidEntity(client))
		return Plugin_Continue;

	NightmareCannon_BEAM_IsUsing[client] = false;
	
	NightmareCannon_BEAM_TicksActive[client] = 0;
	
	b_fucking_volvo[client] = false;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

public bool NightmareCannon_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}


public bool NightmareCannon_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		NightmareCannon_BEAM_HitDetected[entity] = true;
	}
	return false;
}


static void NightmareCannon_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	GetAbsOrigin(client, startPoint);
	startPoint[2] += 50.0;
	
	Donnerkrieg npc = view_as<Donnerkrieg>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	GetAbsOrigin(client, startPoint);
	startPoint[2] += 50.0;
	
	if (0.0 == NightmareCannon_BEAM_BeamOffset[client][0] && 0.0 == NightmareCannon_BEAM_BeamOffset[client][1] && 0.0 == NightmareCannon_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = NightmareCannon_BEAM_BeamOffset[client][0];
	tmp[1] = NightmareCannon_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = NightmareCannon_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

public Action NightmareCannon_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !NightmareCannon_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, NightmareCannon_TBB_Tick);
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		npc.m_bInKame = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;
	
	

	NightmareCannon_BEAM_TicksActive[client] = tickCount;
	float diameter = float(NightmareCannon_BEAM_BeamRadius[client] * 4);
	int r = GetR(NightmareCannon_BEAM_ColorHex[client]);
	int g = GetG(NightmareCannon_BEAM_ColorHex[client]);
	int b = GetB(NightmareCannon_BEAM_ColorHex[client]);
	if (NightmareCannon_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		Donnerkrieg npc = view_as<Donnerkrieg>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		GetAbsOrigin(client, startPoint);
		startPoint[2] += 50.0;
		
		if(!b_nightmare_logic[npc.index])
		{
			float flAng[3]; // original
			GetAttachment(npc.index, "effect_hand_r", startPoint, flAng);
		}

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, NightmareCannon_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			delete trace;
			ConformLineDistance(endPoint, startPoint, endPoint, float(NightmareCannon_BEAM_MaxDistance[client]));
			float lineReduce = NightmareCannon_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				NightmareCannon_BEAM_HitDetected[i] = false;
			}
			
			if(!b_health_stripped)
			{
				int PrimaryThreatIndex = npc.m_iTarget;
				if(IsValidEnemy(npc.index, PrimaryThreatIndex) &&  !b_nightmare_logic[npc.index])
				{
					float target_vec[3]; GetAbsOrigin(PrimaryThreatIndex, target_vec);
					endPoint[2] = target_vec[2];
				}
			}
			
			hullMin[0] = -float(NightmareCannon_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, NightmareCannon_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (NightmareCannon_BEAM_HitDetected[victim] && GetTeam(client) != GetTeam(victim))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = NightmareCannon_BEAM_CloseDPT[client] + (NightmareCannon_BEAM_FarDPT[client]-NightmareCannon_BEAM_CloseDPT[client]) * (distance/NightmareCannon_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					if(ShouldNpcDealBonusDamage(victim))
					{
						damage *= 5.0;
					}
					float WorldSpaceVec[3]; WorldSpaceCenter(victim, WorldSpaceVec);
					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, WorldSpaceVec);	// 2048 is DMG_NOGIB?
				}
			}
			static float belowBossEyes[3];
			if(!b_nightmare_logic[npc.index])
			{
				belowBossEyes = startPoint;
				
			}
			else
			{
				
				NightmareCannon_GetBeamDrawStartPoint(client, belowBossEyes);
			}
			
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, NightmareCannon_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter*2.5), ClampBeamWidth(diameter), 0, 2.5, glowColor, 0);
			TE_SendToAll(0.0);
			
			
		}
		else
		{
			delete trace;
		}
		delete trace;
	}
	return Plugin_Continue;
}