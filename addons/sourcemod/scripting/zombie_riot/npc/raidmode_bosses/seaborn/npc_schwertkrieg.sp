#pragma semicolon 1
#pragma newdecls required

/*
	Schwert Abilities:

	Wave 15: Teleport strike. Basic teleport

	Wave 30: Spiral Swords. Advanced Teleport. Group Tele.

	Wave 45: Frontal Swords.

*/

static const char g_DeathSounds[][] = {
	"vo/medic_paincrticialdeath01.mp3",
	"vo/medic_paincrticialdeath02.mp3",
	"vo/medic_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/medic_laughshort01.mp3",
	"vo/medic_laughshort02.mp3",
	"vo/medic_laughshort03.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/batsaber_hit_flesh1.wav",
	"weapons/batsaber_hit_flesh2.wav",
	"weapons/batsaber_hit_world1.wav",
	"weapons/batsaber_hit_world2.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/batsaber_swing1.wav",
	"weapons/batsaber_swing2.wav",
	"weapons/batsaber_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav",
};


static float fl_teleport_strike_recharge[MAXENTITIES];
static bool b_teleport_strike_active[MAXENTITIES];


#define TELEPORT_STRIKE_INTIALIZE		"misc/halloween/gotohell.wav"
#define TELEPORT_STRIKE_LOOPS 			"weapons/vaccinator_charge_tier_03.wav"

//Logic for duo raidboss

static int i_ally_index;
static int LaserIndex;
static int BeamLaser;
static float fl_focus_timer[MAXENTITIES];

static bool b_angered_twice[MAXENTITIES];

void Raidboss_Schwertkrieg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}
	
	
	PrecacheSound(TELEPORT_STRIKE_INTIALIZE, true);

	LaserIndex = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	BeamLaser = PrecacheModel("materials/sprites/laser.vmt", true);

	PrecacheSound(TELEPORT_STRIKE_TELEPORT, true);
	PrecacheSound(TELEPORT_STRIKE_HIT, true);
	PrecacheSound(TELEPORT_STRIKE_LOOPS, true);
	PrecacheSound(TELEPORT_STRIKE_MISS, true);
	
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("passtime/tv2.wav");
	PrecacheSound("misc/halloween/spell_mirv_explode_primary.wav");

	Zero(fl_focus_timer);
	Zero(fl_teleport_strike_recharge);
	Zero(b_teleport_strike_active);

}

static int i_schwert_hand_particle[MAXENTITIES];

methodmap Raidboss_Schwertkrieg < CClotBody
{
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	
	
	public Raidboss_Schwertkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcInternalId[npc.index] = SEA_RAIDBOSS_SCHWERTKRIEG;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		fl_focus_timer[npc.index]=0.0;

		b_angered_twice[npc.index]=false;
		fl_teleport_strike_recharge[npc.index] = GetGameTime()+25.0;
		b_teleport_strike_active[npc.index]=false;

		
		
		SDKHook(npc.index, SDKHook_Think, Raidboss_Schwertkrieg_ClotThink);

		RaidModeTime = GetGameTime(npc.index) + 500.0;
			
		
		//IDLE
		npc.m_flSpeed =330.0;
		
		
		/*

			breakneck baggies	"models/workshop/player/items/all_class/jogon/jogon_medic.mdl"
			lo-grav loafers		"models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl"
			puffed practitioner	"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl"

			das blutliebhaber	"models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl"
			Herzensbrecher		"models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl"
			dark helm			"models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl"
			quadwrangler		"models/player/items/medic/qc_glove.mdl"

		*/

		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_das_blutliebhaber/hw2013_das_blutliebhaber.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/all_class/hw2013_the_dark_helm/hw2013_the_dark_helm_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/all_class/jogon/jogon_medic.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");

		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/medic/Hw2013_Moon_Boots/Hw2013_Moon_Boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");

		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");

		npc.m_iWearable7 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable7, "SetModelScale");

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable7, Prop_Send, "m_nSkin", skin);
		
		npc.StartPathing();

		float flPos[3], flAng[3];
				
		npc.GetAttachment("eyeglow_L", flPos, flAng);
		i_schwert_hand_particle[npc.index] = EntIndexToEntRef(ParticleEffectAt_Parent(flPos, "raygun_projectile_blue_crit", npc.index, "eyeglow_L", {0.0,0.0,0.0}));
		npc.GetAttachment("root", flPos, flAng);

		
		npc.m_flMeleeArmor = 1.5;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");


		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		Schwertkrieg_Create_Wings(npc);
		Schwert_Impact_Lance_Create(npc.index);
		
		
		return npc;
	}
}

public void Schwertkrieg_Set_Ally_Index(int ref)
{	
	i_ally_index = EntIndexToEntRef(ref);
}
static int Schwertkrieg_Get_Target(Raidboss_Schwertkrieg npc, float GameTime)
{
	
	if(shared_goal)	//yes my master...
	{
		if(IsValidEnemy(npc.index, schwert_target))
			return schwert_target;	//if "shared goal" is active both npc's target the same target, the target is set by donnerkrieg
		else
			return npc.m_iTarget;
	}
	
	if(b_schwert_focus_snipers)
	{
		if(fl_focus_timer[npc.index] < GameTime)
		{
			fl_focus_timer[npc.index] = GameTime + GetRandomFloat(2.5 , 7.5);
			float loc[3]; loc = GetAbsOrigin(npc.index);
			float Dist = -1.0;
			int target=-1;
			for(int client=0 ; client <=MAXTF2PLAYERS ; client++)	//get the furthest away valid sniper target
			{
				if(IsValidClient(client) && b_donner_valid_sniper_threats[client] && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
				{
					float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
					float distance = GetVectorDistance(client_loc, loc, true);
					{
						if(distance>Dist)
						{
							target = client;
						}
					}
				}
			}
			if(IsValidEnemy(npc.index, target))
			{
				npc.m_iTarget = target;
				return target;
			}
			else
			{
				return npc.m_iTarget;
			}
		}
		else
		{
			return npc.m_iTarget;
		}
	}

	return npc.m_iTarget;
}
//TODO 
//Rewrite
public void Raidboss_Schwertkrieg_ClotThink(int iNPC)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(iNPC);
	
	if(!b_raidboss_donnerkrieg_alive)	//While This I do need
		Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(false);	//donner first, schwert second


	float GameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
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

	if(npc.m_flGetClosestTargetTime < GameTime && !schwert_retreat)
	{
		if(IsValidAlly(npc.index, EntRefToEntIndex(i_ally_index)))	//schwert will always prefer attacking enemies who are near donnerkrieg.
		{
			npc.m_iTarget = GetClosestTarget(EntRefToEntIndex(i_ally_index),_,_,_,_,_,_,true);
			if(npc.m_iTarget == -1)
			{
				npc.m_iTarget = GetClosestTarget(EntRefToEntIndex(i_ally_index));
			}
		}
		else
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
		}
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
		
	}	

	if(RaidBossActive == INVALID_ENT_REFERENCE)
	{
		RaidBossActive=EntIndexToEntRef(npc.index);
	}

	//Set raid to this one incase the previous one has died or somehow vanished
	if(IsEntityAlive(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop ++)
		{
			if(IsValidClient(EnemyLoop)) //Add to hud as a duo raid.
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	
	int PrimaryThreatIndex = Schwertkrieg_Get_Target(npc, GameTime);

	int Ally =-1;

	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
	float npc_Vec[3]; npc_Vec = WorldSpaceCenter(npc.index);

	float flDistanceToTarget = GetVectorDistance(vecTarget, npc_Vec, true);

	if(schwert_retreat)
	{
		Ally = EntRefToEntIndex(i_ally_index);
		if(IsValidAlly(npc.index, Ally))
		{
			float vecAlly[3]; vecAlly = WorldSpaceCenter(Ally);

			float flDistanceToAlly = GetVectorDistance(vecAlly, npc_Vec, true);
			Schwert_Movement_Ally_Movement(npc, flDistanceToAlly, Ally, GameTime);

			//Schwert_Teleport_Core(npc, PrimaryThreatIndex);
		}
	}
	else
	{
		Schwert_Movement(npc, flDistanceToTarget, PrimaryThreatIndex);

		//Schwert_Teleport_Core(npc, PrimaryThreatIndex);
	}
	
	
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Schwert_Aggresive_Behavior(npc, PrimaryThreatIndex, GameTime, flDistanceToTarget, vecTarget);
	}
	else
	{
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			if(npc.m_bAllowBackWalking)
				npc.m_bAllowBackWalking=false;
		}
		NPC_StopPathing(npc.index);
		npc.m_bPathing = false;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}
static void Schwert_Aggresive_Behavior(Raidboss_Schwertkrieg npc, int PrimaryThreatIndex, float GameTime, float flDistanceToTarget, float vecTarget[3])
{

	if(npc.m_bAllowBackWalking)
		npc.FaceTowards(vecTarget, 20000.0);

	if(npc.m_flNextMeleeAttack > GameTime && !npc.m_flAttackHappenswillhappen)
	{
		npc.m_bAllowBackWalking=true;
		npc.StartPathing();
		float vBackoffPos[3];
		vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
		NPC_SetGoalVector(npc.index, vBackoffPos, true);

		npc.StartPathing();
		npc.m_bPathing = true;

		npc.FaceTowards(vecTarget, 20000.0);
	}
	else
	{
		npc.m_bAllowBackWalking=false;
	}

	
	Schwertkrieg_Teleport_Strike(npc, flDistanceToTarget, GameTime, PrimaryThreatIndex);
	
	if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
	{
		//Look at target so we hit.
	//	npc.FaceTowards(vecTarget, 1000.0);
		
		//Can we attack right now?

		float Swing_Speed = 2.0;
		float Swing_Delay = 0.2;
		if(npc.m_flNextMeleeAttack < GameTime)
		{
			//Play attack ani
			if (!npc.m_flAttackHappenswillhappen)
			{
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
				npc.m_flAttackHappens = GameTime+Swing_Delay;
				npc.m_flAttackHappens_bullshit = GameTime+Swing_Speed;
				npc.m_flAttackHappenswillhappen = true;
			}
				
			if (npc.m_flAttackHappens < GameTime && npc.m_flAttackHappens_bullshit >= GameTime && npc.m_flAttackHappenswillhappen)
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
						float meleedmg= 30.0*RaidModeScaling;	//schwert hurts like a fucking truck
						
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
							SDKHooks_TakeDamage(target, npc.index, npc.index, meleedmg * 5, DMG_CLUB, -1, _, vecHit);
						}

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
						
						npc.PlayMeleeHitSound();	
					
					} 
				}
				delete swingTrace;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
				npc.m_flAttackHappenswillhappen = false;
			}
			else if (npc.m_flAttackHappens_bullshit < GameTime && npc.m_flAttackHappenswillhappen)
			{
				npc.m_flAttackHappenswillhappen = false;
				npc.m_flNextMeleeAttack = GameTime + Swing_Speed;
			}
		}
	}
	else
	{
		npc.StartPathing();
	}
}
static void Schwertkrieg_Teleport_Strike(Raidboss_Schwertkrieg npc, float flDistanceToTarget, float GameTime, int PrimaryThreatIndex)
{
	bool can_see=false;
	bool touching_creep = SeaFounder_TouchingNethersea(PrimaryThreatIndex);
	if(flDistanceToTarget < (2500.0*2500.0) || touching_creep)
	{
		can_see=true;
	}
	if(can_see && fl_teleport_strike_recharge[npc.index] < GameTime && !b_teleport_strike_active[npc.index])
	{
		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy))
		{
			npc.m_flDoingAnimation = GameTime+2.0;
			b_teleport_strike_active[npc.index]=true;

			npc.SetPlaybackRate(0.75);	
			npc.SetCycle(0.0);

			npc.AddActivityViaSequence("taunt_neck_snap_medic");

			Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);

			float npc_Loc[3]; npc_Loc = GetAbsOrigin(npc.index);

			EmitSoundToAll(TELEPORT_STRIKE_INTIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);
			EmitSoundToAll(TELEPORT_STRIKE_INTIALIZE, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npc_Loc);

			npc.m_flMeleeArmor = 0.5;
			npc.m_flRangedArmor = 0.5;

			npc_Loc[2]+=10.0;
			int r, g, b, a;
			r=145;
			g=47;
			b=47;
			a=255;
			spawnRing_Vectors(npc_Loc, 250.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 2.0, 12.0, 2.0, 1, 1.0);

		}
	}
	if(b_teleport_strike_active[npc.index] && npc.m_flDoingAnimation < GameTime)	//warp
	{
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);
		Schwert_Impact_Lance_Create(npc.index);

		b_teleport_strike_active[npc.index]=false;
		fl_teleport_strike_recharge[npc.index]=GameTime+5.0;

		int enemy = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
		if(IsValidEnemy(npc.index, enemy) || touching_creep)	//now do another check to see if we can still even see a target, if not, abort the whole process. ignore if the target is in creep
		{
			float VecForward[3];
			float vecRight[3];
			float vecUp[3];
			float vecPos[3];
					
			GetVectors(PrimaryThreatIndex, VecForward, vecRight, vecUp);
			vecPos = GetAbsOrigin(PrimaryThreatIndex);
			vecPos[2] += 5.0;
					
			float vecSwingEnd[3];
			vecSwingEnd[0] = vecPos[0] - VecForward[0] * (100);
			vecSwingEnd[1] = vecPos[1] - VecForward[1] * (100);
			vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/
			if(Schwert_Teleport(npc, vecSwingEnd, 0.0))
			{
				Schwertkrieg_Teleport_Boom(npc, vecSwingEnd);
				fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
			}
			else
			{
				vecSwingEnd[0] = vecPos[0] - VecForward[0] * (-100);
				vecSwingEnd[1] = vecPos[1] - VecForward[1] * (-100);
				vecSwingEnd[2] = vecPos[2];/*+ VecForward[2] * (100);*/
				if(Schwert_Teleport(npc, vecSwingEnd, 0.0))
				{
					Schwertkrieg_Teleport_Boom(npc, vecSwingEnd);
					fl_teleport_strike_recharge[npc.index]=GameTime+60.0;
				}
			}
		}
	}
}
#define SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS 750.0

static void Schwertkrieg_Teleport_Boom(Raidboss_Schwertkrieg npc, float Location[3])
{
	float Boom_Time = 5.0;

	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	

	int wave = ZR_GetWaveCount()+1;
	int color[4];
	color[3] = 75;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}

	TE_SetupBeamRingPoint(Location, radius*2.0, 0.0, LaserIndex, LaserIndex, 0, 1, Boom_Time, 3.0, 1.0, color, 1, 0);

	Handle pack;
	CreateDataTimer(Boom_Time, Schwert_Boom, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, EntRefToEntIndex(npc.index));
	WritePackFloat(pack, Location[0]);
	WritePackFloat(pack, Location[1]);
	WritePackFloat(pack, Location[2]);

	Handle pack2;
	CreateDataTimer(0.0, Schwert_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(npc.index));
	WritePackFloat(pack2, Boom_Time);
	WritePackFloat(pack2, Location[0]);
	WritePackFloat(pack2, Location[1]);
	WritePackFloat(pack2, Location[2]);
}
static Action Schwert_Ring_Loops(Handle Loop, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	float loops = ReadPackFloat(pack);
	if(loops<=0.0)
	{
		return Plugin_Stop;
	}
	loops-=1.0;

	
	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}

	EmitAmbientSound(TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));
	EmitAmbientSound(TELEPORT_STRIKE_LOOPS, spawnLoc, _, 120, _, _, GetRandomInt(80, 110));

	int wave = ZR_GetWaveCount()+1;
	int color[4];
	color[3] = 75;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}

	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	if(npc.Anger)
		radius *= 1.25;	
	
	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, 0.0, LaserIndex, LaserIndex, 0, 1, 1.0, 3.0, 0.1, color, 1, 0);

	Handle pack2;
	CreateDataTimer(1.0, Schwert_Ring_Loops, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, EntRefToEntIndex(entity));
	WritePackFloat(pack2, loops);
	WritePackFloat(pack2, spawnLoc[0]);
	WritePackFloat(pack2, spawnLoc[1]);
	WritePackFloat(pack2, spawnLoc[2]);

	return Plugin_Stop;

}
static Action Schwert_Boom(Handle Smite_Logic, DataPack pack)
{
	ResetPack(pack);
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if(!IsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);

	float spawnLoc[3];
	for(int GetVector = 0; GetVector < 3; GetVector++)
	{
		spawnLoc[GetVector] = ReadPackFloat(pack);
	}
	
	float damage = 200.0*RaidModeScaling;
	float radius = SCHWERTKRIEG_TELEPORT_STRIKE_RADIUS;
	int wave = ZR_GetWaveCount()+1;
	int color[4];
	color[3] = 75;
	int loop_for = 15;
	float height = 1500.0;
	float sky_loc[3]; sky_loc = spawnLoc; sky_loc[2]+=height;

	if(wave<=15)
	{
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
	}
	else if(wave <=30)
	{
		color[0] = 147;
		color[1] = 188;
		color[2] = 199;
	}
	else if(wave <=45)
	{
		color[0] = 51;
		color[1] = 9;
		color[2] = 235;
	}

	if(npc.Anger)
	{
		radius *= 1.25;	
		damage *=1.25;
	}

	Explode_Logic_Custom(damage, npc.index, npc.index, -1, spawnLoc, radius,_,0.8, true);

	spawnLoc[2]+=10.0;

	TE_SetupBeamRingPoint(spawnLoc, radius*2.0, 0.0, LaserIndex, LaserIndex, 0, 1, 1.0, 3.0, 1.0, color, 1, 0);

	float start = 5.0;
	float end = 5.0;
	TE_SetupBeamPoints(spawnLoc, sky_loc, BeamLaser, 0, 0, 0, 1.0, start, end, 0, 1.0, color, 3);
	TE_SendToAll();

	float Time = 1.0;

	float thicc = 3.0;
	float Seperation = height / loop_for;
	float Offset_Time = Time / loop_for;
	for(int i = 1 ; i <= loop_for ; i++)
	{
		float timer = Offset_Time*i;
		if(timer<=0.02)
			timer=0.02;
		TE_SetupBeamRingPoint(spawnLoc, radius*((loop_for/i)*0.5), 0.0, LaserIndex, LaserIndex, 0, 1, timer, thicc, 0.1, color, 1, 0);

		TE_SendToAll();
		spawnLoc[2]+=Seperation;
	}

	return Plugin_Stop;
	
}
static bool Schwert_Teleport(Raidboss_Schwertkrieg npc, float vecTarget[3], float Min_Range)
{
	float Tele_Check = GetVectorDistance(WorldSpaceCenter(npc.index), vecTarget);

	float start_offset[3], end_offset[3];
	start_offset = WorldSpaceCenter(npc.index);

	bool Succeed = false;

	if(Tele_Check>Min_Range)
	{
		Succeed = NPC_Teleport(npc.index, vecTarget);
	
		if(Succeed)
		{
			npc.PlayTeleportSound();
			
			float effect_duration = 0.25;
			
			
			end_offset = vecTarget;
			
			start_offset[2]-= 25.0;
			end_offset[2] -= 25.0;
			
			for(int help=1 ; help<=8 ; help++)
			{	
				Schwert_Teleport_Effect(RUINA_BALL_PARTICLE_BLUE, effect_duration, start_offset, end_offset);
				
				start_offset[2] += 12.5;
				end_offset[2] += 12.5;
			}
		}
	}
	return Succeed;
}
static void Schwert_Movement(Raidboss_Schwertkrieg npc, float flDistanceToTarget, int target)
{	
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, target);
								
		NPC_SetGoalVector(npc.index, vPredictedPos);
	} 
	else 
	{
		NPC_SetGoalEntity(npc.index, target);
	}
}
static void Schwert_Movement_Ally_Movement(Raidboss_Schwertkrieg npc, float flDistanceToAlly, int ally, float GameTime)
{	
	if(npc.m_bAllowBackWalking)
		npc.m_bAllowBackWalking=false;
	Raidboss_Donnerkrieg donner = view_as<Raidboss_Donnerkrieg>(ally);
	if(flDistanceToAlly < (450.0*450.0))
	{
		int target_new = GetClosestTarget(donner.index);
		if(IsValidEnemy(npc.index, target_new))
		{
			float Ally_Vec[3]; Ally_Vec = WorldSpaceCenter(donner.index);
			float Vec_Target[3]; Vec_Target = WorldSpaceCenter(target_new);
			float flDistanceToTarget = GetVectorDistance(Ally_Vec, Vec_Target, true);
			if(flDistanceToTarget < (500.0*500.0))	//they are to close to my beloved, *Kill them*
			{
				Schwert_Movement(npc, flDistanceToTarget, target_new);
				Schwert_Aggresive_Behavior(npc, target_new, GameTime, flDistanceToTarget, Vec_Target);
			}
		}
	} 
	else 
	{
		NPC_SetGoalEntity(npc.index, donner.index);
	}
}

public Action Raidboss_Schwertkrieg_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	float Health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));

	if(!b_angered_twice[npc.index] && Health/MaxHealth<=0.5)
	{
		b_angered_twice[npc.index]=true;
		donner_sea_created=true;
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Raidboss_Schwertkrieg_NPCDeath(int entity)
{
	Raidboss_Schwertkrieg npc = view_as<Raidboss_Schwertkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	int ally = EntRefToEntIndex(i_ally_index);
	if(IsValidEntity(ally))
	{
		Raidboss_Donnerkrieg donner = view_as<Raidboss_Donnerkrieg>(ally);
		b_force_heavens_light[ally]=true;	//force heavens Light!
		donner.Anger=true;
	}
		
	
	if(EntRefToEntIndex(RaidBossActive)==npc.index)
	{
		RaidBossActive = INVALID_ENT_REFERENCE;
	}
			
	npc.m_bThisNpcIsABoss = false;
	
	SDKUnhook(npc.index, SDKHook_Think, Raidboss_Schwertkrieg_ClotThink);

	Schwertkrieg_Delete_Wings(npc);
	Schwert_Impact_Lance_CosmeticRemoveEffects(npc.index);
		
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

	int particle = EntRefToEntIndex(i_schwert_hand_particle[npc.index]);
	if(IsValidEntity(particle))
	{
		RemoveEntity(particle);
		i_schwert_hand_particle[npc.index]=INVALID_ENT_REFERENCE;
	}
		
}
static void Schwert_Teleport_Effect(char type[255], float duration = 0.0, float start_point[3], float end_point[3])
{
	int part1 = CreateEntityByName("info_particle_system");
	if(IsValidEdict(part1))
	{
		TeleportEntity(part1, start_point, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(part1, "effect_name", type);
		SetVariantString("!activator");
		DispatchSpawn(part1);
		ActivateEntity(part1);
		AcceptEntityInput(part1, "Start");
		
		DataPack pack;
		CreateDataTimer(0.1, Timer_Move_Particle, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(part1));
		pack.WriteCell(end_point[0]);
		pack.WriteCell(end_point[1]);
		pack.WriteCell(end_point[2]);
		pack.WriteCell(duration);
	}
}
#define SCHWERTKRIEG_PARTICLE_EFFECT_AMT 30
static int i_schwert_particle_index[MAXENTITIES][SCHWERTKRIEG_PARTICLE_EFFECT_AMT];

static void Schwertkrieg_Delete_Wings(Raidboss_Schwertkrieg npc)
{

	for(int i=0 ; i < SCHWERTKRIEG_PARTICLE_EFFECT_AMT ; i++)
	{
		int particle = EntRefToEntIndex(i_schwert_particle_index[npc.index][i]);
		if(IsValidEntity(particle))
		{
			RemoveEntity(particle);
		}
		i_schwert_particle_index[npc.index][i]=INVALID_ENT_REFERENCE;
	}
}

static void Schwertkrieg_Create_Wings(Raidboss_Schwertkrieg npc)
{
	if(AtEdictLimit(EDICT_RAID))
		return;

	Schwertkrieg_Delete_Wings(npc);

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];


	int ParticleOffsetMain = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
	GetAttachment(npc.index, "back_lower", flPos, flAng);
	Custom_SDKCall_SetLocalOrigin(ParticleOffsetMain, flPos);
	SetEntPropVector(ParticleOffsetMain, Prop_Data, "m_angRotation", flAng); 
	SetParent(npc.index, ParticleOffsetMain, "back_lower",_);


	//Left

	float core_loc[3] = {0.0, 20.0, -25.0};

	int particle_left_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/
	int particle_left_wing_1 = InfoTargetParentAt({15.5, 15.0, -15.0}, "", 0.0);	//middle upper
	int particle_left_wing_2 = InfoTargetParentAt({2.5, 20.0, -15.0}, "", 0.0);		//middle mid
	int particle_left_wing_6 = InfoTargetParentAt({18.5, 27.5, 5.0}, "", 0.0);		//middle lower
	
	int particle_left_wing_3 = InfoTargetParentAt({45.0, 35.0, -7.5}, "", 0.0);	//side upper		//raygun_projectile_blue_crit
	int particle_left_wing_4 = InfoTargetParentAt({40.0, 45.0, -7.5}, "", 0.0);	//side lower

	int particle_left_wing_5 = InfoTargetParentAt({25.5, 60.0, 15.0}, "", 0.0);	//lower left

	SetParent(particle_left_core, particle_left_wing_1, "",_, true);
	SetParent(particle_left_core, particle_left_wing_2, "",_, true);
	SetParent(particle_left_core, particle_left_wing_3, "",_, true);
	SetParent(particle_left_core, particle_left_wing_4, "",_, true);
	SetParent(particle_left_core, particle_left_wing_5, "",_, true);
	SetParent(particle_left_core, particle_left_wing_6, "",_, true);
	//SetParent(particle_left_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_left_core, flPos);
	SetEntPropVector(particle_left_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_left_core, "",_);

	float start_1 = 2.0;
	float end_1 = 0.5;
	float amp =0.1;

	int laser_left_wing_1 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);

	int laser_left_wing_2 = ConnectWithBeamClient(particle_left_wing_1, particle_left_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_left_wing_3 = ConnectWithBeamClient(particle_left_wing_3, particle_left_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_left_wing_4 = ConnectWithBeamClient(particle_left_wing_4, particle_left_wing_5, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_left_wing_5 = ConnectWithBeamClient(particle_left_wing_5, particle_left_wing_6, red, green, blue, end_1, start_1, amp, LASERBEAM);
	int laser_left_wing_6 = ConnectWithBeamClient(particle_left_wing_6, particle_left_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);


	i_schwert_particle_index[npc.index][0] = EntIndexToEntRef(ParticleOffsetMain);
	i_schwert_particle_index[npc.index][1] = EntIndexToEntRef(particle_left_core);
	i_schwert_particle_index[npc.index][2] = EntIndexToEntRef(particle_left_wing_1);
	i_schwert_particle_index[npc.index][3] = EntIndexToEntRef(particle_left_wing_2);
	i_schwert_particle_index[npc.index][4] = EntIndexToEntRef(particle_left_wing_3);
	i_schwert_particle_index[npc.index][5] = EntIndexToEntRef(particle_left_wing_4);
	i_schwert_particle_index[npc.index][6] = EntIndexToEntRef(particle_left_wing_5);
	i_schwert_particle_index[npc.index][7] = EntIndexToEntRef(particle_left_wing_6);

	i_schwert_particle_index[npc.index][8] = EntIndexToEntRef(laser_left_wing_1);
	i_schwert_particle_index[npc.index][9] = EntIndexToEntRef(laser_left_wing_2);
	i_schwert_particle_index[npc.index][10] = EntIndexToEntRef(laser_left_wing_2);
	i_schwert_particle_index[npc.index][11] = EntIndexToEntRef(laser_left_wing_3);
	i_schwert_particle_index[npc.index][12] = EntIndexToEntRef(laser_left_wing_4);
	i_schwert_particle_index[npc.index][13] = EntIndexToEntRef(laser_left_wing_5);
	i_schwert_particle_index[npc.index][14] = EntIndexToEntRef(laser_left_wing_6);

	//right

	
	int particle_right_core = InfoTargetParentAt(core_loc, "", 0.0);


	/*
		X = +Left, -Right
		Y = -Up, +Down
		Z = +Backwards, -Forward
	*/

	

	int particle_right_wing_1 = InfoTargetParentAt({-15.5, 15.0, -15.0}, "", 0.0);	//middle upper
	int particle_right_wing_2 = InfoTargetParentAt({-2.5, 20.0, -15.0}, "", 0.0);		//middle mid
	int particle_right_wing_6 = InfoTargetParentAt({-18.5, 27.5, 5.0}, "", 0.0);		//middle lower
	
	int particle_right_wing_3 = InfoTargetParentAt({-45.0, 35.0, -7.5}, "", 0.0);	//side upper		//raygun_projectile_blue_crit
	int particle_right_wing_4 = InfoTargetParentAt({-40.0, 45.0, -7.5}, "", 0.0);	//side lower

	int particle_right_wing_5 = InfoTargetParentAt({-25.5, 60.0, 15.0}, "", 0.0);	//lower right

	SetParent(particle_right_core, particle_right_wing_1, "",_, true);
	SetParent(particle_right_core, particle_right_wing_2, "",_, true);
	SetParent(particle_right_core, particle_right_wing_3, "",_, true);
	SetParent(particle_right_core, particle_right_wing_4, "",_, true);
	SetParent(particle_right_core, particle_right_wing_5, "",_, true);
	SetParent(particle_right_core, particle_right_wing_6, "",_, true);
	//SetParent(particle_right_core, particle_2_Wingset_1, "",_, true);



	Custom_SDKCall_SetLocalOrigin(particle_right_core, flPos);
	SetEntPropVector(particle_right_core, Prop_Data, "m_angRotation", flAng); 
	SetParent(ParticleOffsetMain, particle_right_core, "",_);

	int laser_right_wing_1 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);

	int laser_right_wing_2 = ConnectWithBeamClient(particle_right_wing_1, particle_right_wing_3, red, green, blue, start_1, end_1, amp, LASERBEAM);
	int laser_right_wing_3 = ConnectWithBeamClient(particle_right_wing_3, particle_right_wing_4, red, green, blue, end_1, end_1, amp, LASERBEAM);

	int laser_right_wing_4 = ConnectWithBeamClient(particle_right_wing_4, particle_right_wing_5, red, green, blue, end_1, end_1, amp, LASERBEAM);
	int laser_right_wing_5 = ConnectWithBeamClient(particle_right_wing_5, particle_right_wing_6, red, green, blue, end_1, start_1, amp, LASERBEAM);
	int laser_right_wing_6 = ConnectWithBeamClient(particle_right_wing_6, particle_right_wing_2, red, green, blue, start_1, start_1, amp, LASERBEAM);


	i_schwert_particle_index[npc.index][15] = EntIndexToEntRef(particle_right_core);
	i_schwert_particle_index[npc.index][16] = EntIndexToEntRef(particle_right_wing_1);
	i_schwert_particle_index[npc.index][17] = EntIndexToEntRef(particle_right_wing_2);
	i_schwert_particle_index[npc.index][18] = EntIndexToEntRef(particle_right_wing_3);
	i_schwert_particle_index[npc.index][19] = EntIndexToEntRef(particle_right_wing_4);
	i_schwert_particle_index[npc.index][20] = EntIndexToEntRef(particle_right_wing_5);
	i_schwert_particle_index[npc.index][21] = EntIndexToEntRef(particle_right_wing_6);

	i_schwert_particle_index[npc.index][22] = EntIndexToEntRef(laser_right_wing_1);
	i_schwert_particle_index[npc.index][23] = EntIndexToEntRef(laser_right_wing_2);
	i_schwert_particle_index[npc.index][24] = EntIndexToEntRef(laser_right_wing_2);
	i_schwert_particle_index[npc.index][25] = EntIndexToEntRef(laser_right_wing_3);
	i_schwert_particle_index[npc.index][26] = EntIndexToEntRef(laser_right_wing_4);
	i_schwert_particle_index[npc.index][27] = EntIndexToEntRef(laser_right_wing_5);
	i_schwert_particle_index[npc.index][28] = EntIndexToEntRef(laser_right_wing_6);

}

#define SCHWERTKRIEG_LANCE_EFFECTS 25

static int i_Schwert_Impact_Lance_CosmeticEffect[MAXENTITIES][SCHWERTKRIEG_LANCE_EFFECTS];

static void Schwert_Impact_Lance_CosmeticRemoveEffects(int iNpc)
{
	for(int loop = 0; loop<SCHWERTKRIEG_LANCE_EFFECTS; loop++)
	{
		int entity = EntRefToEntIndex(i_Schwert_Impact_Lance_CosmeticEffect[iNpc][loop]);
		if(IsValidEntity(entity))
		{
			RemoveEntity(entity);
		}
		i_Schwert_Impact_Lance_CosmeticEffect[iNpc][loop] = INVALID_ENT_REFERENCE;
	}
}

static void Schwert_Impact_Lance_Create(int client, char[] attachment = "effect_hand_r")
{

	if(AtEdictLimit(EDICT_RAID))
		return;

	Schwert_Impact_Lance_CosmeticRemoveEffects(client);

	int red = 185;
	int green = 205;
	int blue = 237;
	float flPos[3];
	float flAng[3];
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically

	/*
		{x, y, z};

		x = Right = -x, Left = x
		y = Forward = y, backwrads = -y
		z is inverted values
		 
	*/

	int particle_2 = InfoTargetParentAt({0.0, 10.0, 7.5}, "", 0.0); //First offset we go by
	int particle_2_1 = InfoTargetParentAt({0.0, 10.0, -7.5}, "", 0.0);

	int particle_3 = InfoTargetParentAt({5.0,10.0,0.0}, "", 0.0);
	int particle_3_1 = InfoTargetParentAt({-5.0,10.0,0.0}, "", 0.0);

	int particle_4 = InfoTargetParentAt({0.0,70.0,2.5}, "", 0.0);
	int particle_4_1 = InfoTargetParentAt({0.0,70.0, -2.5}, "", 0.0);

	int particle_5 = InfoTargetParentAt({0.0,-10.0, 5.0}, "", 0.0);
	int particle_5_1 = InfoTargetParentAt({0.0,-10.0, -5.0}, "", 0.0);

	int particle_6 = InfoTargetParentAt({12.0,-5.0, 0.0}, "", 0.0);
	int particle_6_1 = InfoTargetParentAt({-12.0,-5.0, 0.0}, "", 0.0);

	int particle_7 = InfoTargetParentAt({0.0,-10.0, 0.0}, "", 0.0);


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_2_1, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_3_1, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_4_1, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_1, particle_5_1, "",_, true);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_1, particle_6_1, "",_, true);
	SetParent(particle_1, particle_7, "",_, true);

	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_1, attachment,_);


	float amp = 0.1;

	float blade_start = 2.0;
	float blade_end = 0.5;
	//handguard
	float handguard_size = 1.0;
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_2 = ConnectWithBeamClient(particle_3, particle_2_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_3 = ConnectWithBeamClient(particle_2_1, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);
	int Laser_6 = ConnectWithBeamClient(particle_2, particle_3_1, red, green, blue, handguard_size, handguard_size, 0.5, LASERBEAM);

	int Laser_4 = ConnectWithBeamClient(particle_2, particle_4, red, green, blue, blade_start, blade_end, amp, LASERBEAM);			//blade
	int Laser_5 = ConnectWithBeamClient(particle_2_1, particle_4_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM);		//blade

	int Laser_7 = ConnectWithBeamClient(particle_2, particle_5, red, green, blue, blade_start, blade_end, amp, LASERBEAM );			//inner blade
	int Laser_8 = ConnectWithBeamClient(particle_2_1, particle_5_1, red, green, blue, blade_start, blade_end, amp, LASERBEAM );	//	inner blade

	int Laser_9 = ConnectWithBeamClient(particle_6, particle_3, red, green, blue, blade_end, handguard_size, amp, LASERBEAM );			//wing start
	int Laser_10 = ConnectWithBeamClient(particle_6_1, particle_3_1, red, green, blue, blade_end, handguard_size, amp, LASERBEAM );		//wing start
	int Laser_11 = ConnectWithBeamClient(particle_6, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM );			//wing end
	int Laser_12 = ConnectWithBeamClient(particle_6_1, particle_7, red, green, blue, blade_end, blade_start, amp, LASERBEAM );			//wing end
	

	i_Schwert_Impact_Lance_CosmeticEffect[client][0] = EntIndexToEntRef(particle_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][1] = EntIndexToEntRef(particle_2);
	i_Schwert_Impact_Lance_CosmeticEffect[client][2] = EntIndexToEntRef(particle_2_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][3] = EntIndexToEntRef(particle_3);
	i_Schwert_Impact_Lance_CosmeticEffect[client][4] = EntIndexToEntRef(particle_3_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][5] = EntIndexToEntRef(particle_4);
	i_Schwert_Impact_Lance_CosmeticEffect[client][6] = EntIndexToEntRef(Laser_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][7] = EntIndexToEntRef(Laser_2);
	i_Schwert_Impact_Lance_CosmeticEffect[client][8] = EntIndexToEntRef(Laser_3);
	i_Schwert_Impact_Lance_CosmeticEffect[client][9] = EntIndexToEntRef(Laser_4);
	i_Schwert_Impact_Lance_CosmeticEffect[client][10] = EntIndexToEntRef(Laser_5);
	i_Schwert_Impact_Lance_CosmeticEffect[client][11] = EntIndexToEntRef(Laser_6);
	i_Schwert_Impact_Lance_CosmeticEffect[client][12] = EntIndexToEntRef(particle_4_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][13] = EntIndexToEntRef(particle_5);
	i_Schwert_Impact_Lance_CosmeticEffect[client][14] = EntIndexToEntRef(Laser_7);
	i_Schwert_Impact_Lance_CosmeticEffect[client][15] = EntIndexToEntRef(Laser_8);
	i_Schwert_Impact_Lance_CosmeticEffect[client][16] = EntIndexToEntRef(particle_5_1);
	i_Schwert_Impact_Lance_CosmeticEffect[client][17] = EntIndexToEntRef(Laser_9);
	i_Schwert_Impact_Lance_CosmeticEffect[client][18] = EntIndexToEntRef(Laser_10);
	i_Schwert_Impact_Lance_CosmeticEffect[client][19] = EntIndexToEntRef(Laser_11);
	i_Schwert_Impact_Lance_CosmeticEffect[client][20] = EntIndexToEntRef(Laser_12);
	i_Schwert_Impact_Lance_CosmeticEffect[client][21] = EntIndexToEntRef(particle_7);
	i_Schwert_Impact_Lance_CosmeticEffect[client][22] = EntIndexToEntRef(particle_6);
	i_Schwert_Impact_Lance_CosmeticEffect[client][23] = EntIndexToEntRef(particle_6_1);

}
static void spawnRing_Vectors(float center[3], float range, float modif_X, float modif_Y, float modif_Z, char sprite[255], int r, int g, int b, int alpha, int fps, float life, float width, float amp, int speed, float endRange = -69.0) //Spawns a TE beam ring at a client's/entity's location
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