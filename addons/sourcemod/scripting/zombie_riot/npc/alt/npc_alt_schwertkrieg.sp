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

static bool b_health_stripped[MAXENTITIES];

static float TELEPORT_STRIKE_Usage[MAXENTITIES];
static bool TELEPORT_STRIKE_Activate[MAXENTITIES];
static bool TELEPORT_STRIKE_TeleportUsage[MAXENTITIES];
static bool TempOpener[MAXENTITIES];
static bool TELEPORT_STRIKEActive[MAXENTITIES];
static float animation_timer[MAXENTITIES];


static float TELEPORT_STRIKE_Smite_BaseDMG = 1500.0; //Base damage of the effect
static float TELEPORT_STRIKE_Smite_Radius = 500.0;//Radius of the effect
static float TELEPORT_STRIKE_Smite_ChargeTime = 1.33;
static float TELEPORT_STRIKE_Smite_ChargeSpan = 0.66;
static float TELEPORT_STRIKE_Timer = 1.0; //How long it takes to teleport
static float TELEPORT_STRIKE_Reuseable = 30.0; //How long it should be reuseable again


static float Schwertkrieg_Speed = 330.0;

#define TELEPORT_STRIKE_ACTIVATE		"misc/halloween/gotohell.wav"
#define TELEPORT_STRIKE_TELEPORT		"weapons/bison_main_shot.wav"
#define TELEPORT_STRIKE_EXPLOSION		"weapons/vaccinator_charge_tier_03.wav"
#define TELEPORT_STRIKE_HIT				"vo/taunts/medic/medic_taunt_kill_22.mp3"
#define TELEPORT_STRIKE_MISS			"vo/medic_negativevocalization04.mp3"

void Schwertkrieg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	
	
	PrecacheSound(TELEPORT_STRIKE_ACTIVATE, true);
	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_EXPLOSION, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);
	
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("passtime/tv2.wav");
	PrecacheSound("misc/halloween/spell_mirv_explode_primary.wav");
}

methodmap Schwertkrieg < CClotBody
{
	
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
	
	
	
	public Schwertkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Schwertkrieg npc = view_as<Schwertkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcInternalId[npc.index] = ALT_SCHWERTKRIEG;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		b_Schwertkrieg_Alive = true;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		b_health_stripped[npc.index] = false;
		
		SDKHook(npc.index, SDKHook_Think, Schwertkrieg_ClotThink);
			
		
		//IDLE
		npc.m_flSpeed = Schwertkrieg_Speed;
		
		int skin = 5;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/player/items/medic/medic_zombie.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", 1);
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		float flPos[3]; // original
		float flAng[3]; // original
		
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		npc.m_iWearable2 = ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0});
		npc.GetAttachment("root", flPos, flAng);
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		npc.StartPathing();
		
		animation_timer[npc.index] = GetGameTime(npc.index) + 2.0;
		TELEPORT_STRIKE_Usage[npc.index] = GetGameTime(npc.index) + 10.0;
		TELEPORT_STRIKEActive[npc.index] = false;
		TempOpener[npc.index] = false;
		
		npc.m_flMeleeArmor = 1.5;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		TELEPORT_STRIKE_Smite_ChargeTime = 1.33;
		TELEPORT_STRIKE_Smite_ChargeSpan = 0.66;
		TELEPORT_STRIKE_Timer = 1.0; //How long it takes to teleport
		TELEPORT_STRIKE_Reuseable = 30.0; //How long it should be reuseable again
		
		Schwert_Takeover_Active = false;
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Schwertkrieg_ClotThink(int iNPC)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(iNPC);
	
	if(!b_Blitz_Alive && !b_Begin_Dialogue && Schwert_Takeover && b_Valid_Wave)
	{
		if(!Donner_Takeover_Active)
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			npc.m_bThisNpcIsABoss = true;
		}
		if(!Schwert_Takeover_Active && b_angered)
		{
			if(TELEPORT_STRIKE_Usage[npc.index]>GetGameTime()+5.0)
				TELEPORT_STRIKE_Usage[npc.index] = 0.0;
			
			TELEPORT_STRIKE_Reuseable = 15.0;
			TELEPORT_STRIKE_Smite_ChargeTime = 1.0;
			TELEPORT_STRIKE_Smite_ChargeSpan = 0.22;
			TELEPORT_STRIKE_Timer = 0.5;
		}
		Schwert_Takeover_Active = true;
		if(RaidModeTime < GetGameTime())
		{
			int entity = CreateEntityByName("game_round_win"); //You loose.
			DispatchKeyValue(entity, "force_map_reset", "1");
			SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "RoundWin");
			Music_RoundEnd(entity);
			RaidBossActive = INVALID_ENT_REFERENCE;
			SDKUnhook(npc.index, SDKHook_Think, Schwertkrieg_ClotThink);
		}
	}
	
	if(b_angered)
	{
		npc.m_flSpeed = Schwertkrieg_Speed*1.25;
	}
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
			
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flMeleeArmor = 1.5;
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(!b_Schwertkrieg_Alive)	//Schwertkrieg is mute,
	{
		
		npc.m_flNextThinkTime = 0.0;
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.SetActivity("ACT_MP_CROUCH_MELEE");
		npc.m_bisWalking = false;
		if(b_Begin_Dialogue)
		{
			if(GetGameTime() > g_f_blitz_dialogue_timesincehasbeenhurt)
			{
				npc.m_bDissapearOnDeath = true;	
				RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
			}
		}			
		return; //He is trying to help.
	}
	
	if(TELEPORT_STRIKE_Usage[npc.index] <= GetGameTime(npc.index) && !TELEPORT_STRIKEActive[npc.index] && !TempOpener[npc.index])
	{
		npc.m_flSpeed = 0.0;
		float vEnd[3];
		GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vEnd);
		TELEPORT_STRIKE_Usage[npc.index] = GetGameTime(npc.index) + TELEPORT_STRIKE_Timer;
		TempOpener[npc.index] = true;
		//if(IsValidAlly)
		//{
		//	EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		//	EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		//}
		//if(!IsValidAlly)
		//{
		//	EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		//	EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		//}
		EmitSoundToAll(TELEPORT_STRIKE_ACTIVATE, _, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
		TELEPORT_STRIKE_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
		TELEPORT_STRIKE_spawnRing_Vectors(vEnd, 320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
	}
	if(TELEPORT_STRIKE_Usage[npc.index] <= GetGameTime(npc.index) && !TELEPORT_STRIKEActive[npc.index] && TempOpener[npc.index])
	{
		//TELEPORT_STRIKE_Usage[npc.index] = GetGameTime(npc.index) + TELEPORT_STRIKE_Reuseable;
		TELEPORT_STRIKE_TeleportUsage[npc.index] = true;
		TELEPORT_STRIKEActive[npc.index] = true;
		TempOpener[npc.index] = false;
	}
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			if(flDistanceToTarget < npc.GetLeadRadius()) {
				
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
				
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
			float vOrigin[3];
			float vEnd[3];
			vOrigin = GetAbsOrigin(npc.m_iTarget);
			vEnd = GetAbsOrigin(npc.m_iTarget);
			if(TELEPORT_STRIKEActive[npc.index])
			{
				float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex, 0.3);
				static float flVel[3];
				TELEPORT_STRIKE_Usage[npc.index] = GetGameTime(npc.index) + TELEPORT_STRIKE_Reuseable;
				
				if(TELEPORT_STRIKE_TeleportUsage[npc.index])
				{
					int color[4];
					color[0] = 145;
					color[1] = 47;
					color[2] = 47;
					color[3] = 255;
			
					int SPRITE_INT = PrecacheModel("materials/sprites/laserbeam.vmt", false);
					int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
					
					float pos[3], angles[3];
					GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_angRotation", angles);
					GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", pos);
			
					TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT, 0, 0, 0, 0.8, 14.0, 10.2, 1, 1.0, color, 0);
					TE_SendToAll();
					TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
					TE_SendToAll();
					TE_SetupBeamPoints(vecTarget, pos, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
					GetEntPropVector(PrimaryThreatIndex, Prop_Data, "m_vecVelocity", flVel);
					npc.FaceTowards(vecTarget);
					npc.FaceTowards(vecTarget);
					float Tele_Check = GetVectorDistance(vPredictedPos, vecTarget);
					if(Tele_Check < 100000000 || Tele_Check < 10000000 || Tele_Check < 1000000 || Tele_Check < 100000 || Tele_Check < 10000 || Tele_Check > 100000000 || Tele_Check > 10000000 || Tele_Check > 1000000 || Tele_Check > 100000 || Tele_Check > 10000)
					{
						EmitSoundToAll(TELEPORT_STRIKE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
						EmitSoundToAll(TELEPORT_STRIKE_TELEPORT, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, vEnd);
						TeleportEntity(npc.index, vPredictedPos, NULL_VECTOR, NULL_VECTOR);
						TELEPORT_STRIKE_Activate[npc.index] = true;
						TELEPORT_STRIKE_TeleportUsage[npc.index] = false;
						npc.m_flSpeed = Schwertkrieg_Speed;
					}
				}
				
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
				
				if(IsValidEnemy(npc.index, npc.m_iTarget) && npc.m_iTarget == Enemy_I_See && TELEPORT_STRIKE_Activate[npc.index] && !TELEPORT_STRIKE_TeleportUsage[npc.index])
				{
					//float vAngles[3];
					//float vOrigin[3];
					//float vEnd[3];
					//vAngles = GetAbsOrigin(npc.m_iTarget);
					//vOrigin = GetAbsOrigin(npc.m_iTarget);
					//vEnd = GetAbsOrigin(npc.m_iTarget);
				
					Handle pack;
					CreateDataTimer(TELEPORT_STRIKE_Smite_ChargeSpan, TELEPORT_STRIKE_Smite_Timer, pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					WritePackCell(pack, EntRefToEntIndex(npc.index));
					WritePackFloat(pack, 0.0);
					WritePackFloat(pack, vEnd[0]);
					WritePackFloat(pack, vEnd[1]);
					WritePackFloat(pack, vEnd[2]);
					WritePackFloat(pack, TELEPORT_STRIKE_Smite_BaseDMG);
				
					TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 8.0, 8.2, _, 5.0, vOrigin, vEnd);
					//TELEPORT_STRIKE_spawnBeam(320.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 0, 255, 120, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 4.0, 0.1, 1, 1.0);
					TELEPORT_STRIKE_spawnRing_Vectors(vEnd, TELEPORT_STRIKE_Smite_Radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, TELEPORT_STRIKE_Smite_ChargeTime, 6.0, 0.1, 1, 1.0);
					
					//npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 9.0;
					TELEPORT_STRIKEActive[npc.index] = false;
				}
			}
			if(flDistanceToTarget > 100000 && (!TELEPORT_STRIKE_Activate || !TempOpener))
			{
				Schwertkrieg_Speed=350.0;
			}
			else
				Schwertkrieg_Speed=315.0;
			//Target close enough to hit
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.PlayMeleeSound();
						npc.m_flAttackHappens = GetGameTime(npc.index)+0.2;
						npc.m_flAttackHappens_bullshit = GetGameTime(npc.index)+0.35;
						npc.m_flAttackHappenswillhappen = true;
					}
						
					if (npc.m_flAttackHappens < GetGameTime(npc.index) && npc.m_flAttackHappens_bullshit >= GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						Handle swingTrace;
						npc.FaceTowards(vecTarget, 20000.0);
						if(npc.DoSwingTrace(swingTrace, PrimaryThreatIndex))
						{
							int target = TR_GetEntityIndex(swingTrace);	
							
							float vecHit[3];
							TR_GetEndPosition(vecHit, swingTrace);
							
							if(target > 0) 
							{
								float meleedmg= 175.0;
								if(b_angered)
								{
									meleedmg = 325.0;
								}
								
								if(target <= MaxClients)
								{
									float Bonus_damage = 1.0;
									int weapon = GetEntPropEnt(target, Prop_Send, "m_hActiveWeapon");
	
									char classname[32];
									GetEntityClassname(weapon, classname, 32);
								
									int weapon_slot = TF2_GetClassnameSlot(classname);
								
									if(weapon_slot != 2 || i_IsWandWeapon[weapon])
									{
										Bonus_damage = 1.5;
									}
									meleedmg *= Bonus_damage;
									SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg, DMG_CLUB, -1, _, vecHit);
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg * 7.5, DMG_CLUB, -1, _, vecHit);
								}
								
								npc.PlayMeleeHitSound();	
							
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 0.3;
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
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

public Action Schwertkrieg_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	int Health = GetEntProp(npc.index, Prop_Data, "m_iHealth");	//npc becomes imortal when at 1 hp and when its a valid wave	//warp_item
	if(RoundToCeil(damage)>=Health && b_Valid_Wave)
	{
		b_DoNotUnStuck[npc.index] = true;
		b_CantCollidieAlly[npc.index] = true;
		b_CantCollidie[npc.index] = true;
		SetEntityCollisionGroup(npc.index, 24);
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him
		b_NpcIsInvulnerable[npc.index] = true;
        
		b_Schwertkrieg_Alive = false;
		RemoveNpcFromEnemyList(npc.index);
		SetEntProp(npc.index, Prop_Data, "m_iHealth", 1);
		damage = 0.0;
		if(!b_Schwertkrieg_Alive && !b_Donnerkrieg_Alive && !b_timer_locked)
		{
			b_timer_locked = true;
			g_f_blitz_dialogue_timesincehasbeenhurt = GetGameTime() + 20.0;
			
		}
		
		if(Schwert_Takeover_Active && !b_schwert_loocked)
		{
			b_schwert_loocked = true;
			RaidModeTime += 22.5;
			Schwert_Takeover = false;
			Schwert_Takeover_Active = false;
			npc.m_bThisNpcIsABoss = false;
				
			//prepare takeover for donner
			RaidBossActive = INVALID_ENT_REFERENCE;
			if(b_Donnerkrieg_Alive)
			{
				Donner_Takeover = true;
				Donner_Takeover_Active = false;
			}
				
		}
		b_angered = true;
		return Plugin_Handled;
	}
	
	return Plugin_Changed;
}

public void Schwertkrieg_NPCDeath(int entity)
{
	Schwertkrieg npc = view_as<Schwertkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	

	
	b_Schwertkrieg_Alive = false;
	
	b_angered = false;
	
	b_Valid_Wave = false;
	
	b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = false;
	b_NpcIsInvulnerable[npc.index] = false;
			
	npc.m_bThisNpcIsABoss = false;
	
	SDKUnhook(npc.index, SDKHook_Think, Schwertkrieg_ClotThink);
		
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
}

public Action TELEPORT_STRIKE_Smite_Timer(Handle Smite_Logic, DataPack pack)
{
	//int iNPC;
	//DoktorMedick npc = view_as<DoktorMedick>(iNPC);
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	
	float NumLoops = ReadPackFloat(pack);
	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = ReadPackFloat(pack);
	
	if(NumLoops >= TELEPORT_STRIKE_Smite_ChargeTime)
	{
		float secondLoc[3];
		for (int replace = 0; replace < 3; replace++)
		{
			secondLoc[replace] = spawnLoc[replace];
		}
		
		for (int sequential = 1; sequential <= 5; sequential++)
		{
			TELEPORT_STRIKE_spawnRing_Vectors(secondLoc, 1.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.33, 6.0, 0.4, 1, (TELEPORT_STRIKE_Smite_Radius * 5.0)/float(sequential));
			secondLoc[2] += 150.0 + (float(sequential) * 20.0);
		}
		
		//secondLoc[2] = 9999.0;
		secondLoc[2] = 1500.0;
		
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/laserbeam.vmt", 16.0, 16.2, _, 5.0, secondLoc, spawnLoc);	
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);	
		TELEPORT_STRIKE_spawnBeam(0.8, 145, 47, 47, 255, "materials/sprites/lgtning.vmt", 10.0, 10.2, _, 5.0, secondLoc, spawnLoc);
		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 240);
		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 240);
		
		EmitAmbientSound("misc/halloween/spell_mirv_explode_primary.wav", spawnLoc, _, 120);
		
		
		//int target = TR_GetEntityIndex(npc.m_iTarget);	
		//if(target > 0) 
		//{
		//	if(target <= MaxClients)
		//	{
		//		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 120);
		//		EmitAmbientSound(TELEPORT_STRIKE_HIT, spawnLoc, _, 120);
		//	}
		//} 
		//else
		//{
		//	EmitAmbientSound(TELEPORT_STRIKE_MISS, spawnLoc, _, 120);
		//	EmitAmbientSound(TELEPORT_STRIKE_MISS, spawnLoc, _, 120);
		//}
		
		DataPack pack_boom = new DataPack();
		pack_boom.WriteFloat(spawnLoc[0]);
		pack_boom.WriteFloat(spawnLoc[1]);
		pack_boom.WriteFloat(spawnLoc[2]);
		pack_boom.WriteCell(0);
		RequestFrame(MakeExplosionFrameLater, pack_boom);
		
		float radius = TELEPORT_STRIKE_Smite_Radius;
		if(b_angered)
		{
			damage *= 1.25;
			radius *= 1.15;
		}
		Explode_Logic_Custom(damage, entity, entity, -1, spawnLoc, radius * 1.4,_,0.8, true);
		
		return Plugin_Stop;
	}
	else
	{
		
		float radius = TELEPORT_STRIKE_Smite_Radius;
		if(b_angered)
		{
			radius *= 1.15;
		}
		
		TELEPORT_STRIKE_spawnRing_Vectors(spawnLoc, radius * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 145, 47, 47, 255, 1, 0.33, 6.0, 0.1, 1, 1.0);
		EmitAmbientSound(TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
		EmitAmbientSound(TELEPORT_STRIKE_EXPLOSION, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
		
		ResetPack(pack);
		WritePackCell(pack, EntIndexToEntRef(entity));
		WritePackFloat(pack, NumLoops + TELEPORT_STRIKE_Smite_ChargeSpan);
		WritePackFloat(pack, spawnLoc[0]);
		WritePackFloat(pack, spawnLoc[1]);
		WritePackFloat(pack, spawnLoc[2]);
		WritePackFloat(pack, damage);
	}
	
	return Plugin_Continue;
}

static void TELEPORT_STRIKE_spawnBeam(float beamTiming, int r, int g, int b, int a, char sprite[PLATFORM_MAX_PATH], float width=2.0, float endwidth=2.0, int fadelength=1, float amp=15.0, float startLoc[3] = {0.0, 0.0, 0.0}, float endLoc[3] = {0.0, 0.0, 0.0})
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

static void TELEPORT_STRIKE_spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
{
	center[0] += modif_X;
	center[1] += modif_Y;
	center[2] += modif_Z;
	
	int ICE_INT = PrecacheModel(sprite);
	
	int color[4];
	color[0] = r;
	color[1] = g;
	color[2] = b;
	color[3] = alpha;
	
	if (endRange == -69.0)
	{
		endRange = range + 0.5;
	}
	
	TE_SetupBeamRingPoint(center, range, endRange, ICE_INT, ICE_INT, 0, fps, life, width, amp, color, speed, 0);
	TE_SendToAll();
}