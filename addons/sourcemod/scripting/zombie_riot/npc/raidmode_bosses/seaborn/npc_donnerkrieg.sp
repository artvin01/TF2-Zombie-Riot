#pragma semicolon 1
#pragma newdecls required

/*
//Donner, schwert raid abilities

shared:

Group Tele: the 2 run at one another, once in range, they both teleport to a random player.

Behvior:
Backup - Schwertkrieg runs and protects donnerkrieg when he is using nightmare cannon
Cover - If Donnerkriegs "sniper threat" value reaches 25% schwert will switch to attacking "sniper" players which are defined by donnerkrieg. if this value reaches 100% schwert WILL murder the snipers, and teleport to them
Shared Goal - Both have the same PrimaryThreatIndex

schwert:
Multi-Teleport-Strike.
Heaven's blade - Fantasmal swings but heavily moddified.
Heaven's barrage - Quincy Hyper barrage

donner:
Improved Nightmare Cannon:
	Mirror system:
		Either schwertkrieg is the mirror. easier to code, not as cool looking, but could be fine anyway
	Or
		Several mini npc's spawn that act as anchor mirror points, far harder to code, but way cooler looking
Heaven Sent Light: Ruina Ion cannon's but modified - They somewhat start out like moonlight
Heaven's radiance: Jump high into the sky, and spew lasers all around.

Very descriptive descriptions, I know lmao

*/
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


static float fl_nightmare_end_timer[MAXENTITIES];

static int i_AmountProjectiles[MAXENTITIES];

static bool b_health_stripped[MAXENTITIES];

static bool DonnerKriegCannon_BEAM_CanUse[MAXENTITIES];
static bool DonnerKriegCannon_BEAM_IsUsing[MAXENTITIES];
static int DonnerKriegCannon_BEAM_TicksActive[MAXENTITIES];
static int DonnerKriegCannon_BEAM_Laser;
static int DonnerKriegCannon_BEAM_Glow;
static float DonnerKriegCannon_BEAM_CloseDPT[MAXENTITIES];
static float DonnerKriegCannon_BEAM_FarDPT[MAXENTITIES];
static int DonnerKriegCannon_BEAM_MaxDistance[MAXENTITIES];
static int DonnerKriegCannon_BEAM_BeamRadius[MAXENTITIES];
static int DonnerKriegCannon_BEAM_ColorHex[MAXENTITIES];
static int DonnerKriegCannon_BEAM_ChargeUpTime[MAXENTITIES];
static float DonnerKriegCannon_BEAM_CloseBuildingDPT[MAXENTITIES];
static float DonnerKriegCannon_BEAM_FarBuildingDPT[MAXENTITIES];
static float DonnerKriegCannon_BEAM_Duration[MAXENTITIES];
static float DonnerKriegCannon_BEAM_BeamOffset[MAXENTITIES][3];
static float DonnerKriegCannon_BEAM_ZOffset[MAXENTITIES];
static bool DonnerKriegCannon_BEAM_HitDetected[MAXENTITIES];
static int DonnerKriegCannon_BEAM_BuildingHit[MAXENTITIES];
static bool DonnerKriegCannon_BEAM_UseWeapon[MAXENTITIES];


static int Heavens_Beam;

//Logic for duo raidboss

bool shared_goal;
int schwert_target;
static float fl_donner_sniper_threat_timer_clean[MAXTF2PLAYERS+1];
#define RAIDBOSS_DONNERKRIEG_SNIPER_CLEAN_TIMER	30.0	//For how long does a "sniper" player have to not attack in "sniper" deffinition for the threat index to be reset
static float fl_donner_sniper_threat_value[MAXTF2PLAYERS+1];
bool b_donner_valid_sniper_threats[MAXTF2PLAYERS+1];
bool b_schwert_focus_snipers;
float fl_schwertkrieg_sniper_rampage_timer;
#define RAIDBOSS_DONNERKRIEG_SCHWERTKRIEG_SNIPER_RAMPAGE_REFRESH_TIME 10.0	//tl;dr, if a sniper doesn't attack in 10 seconds, schwertkrieg goes to normal operations

static int i_ally_index;

bool b_raidboss_schwertkrieg_alive;
bool b_raidboss_donnerkrieg_alive;

static bool b_InKame[MAXENTITIES];

void Raidboss_Donnerkrieg_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_RangedAttackSounds));   i++) { PrecacheSound(g_RangedAttackSounds[i]);	}
	
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	DonnerKriegCannon_BEAM_Laser = PrecacheModel("materials/sprites/laser.vmt", false);
	DonnerKriegCannon_BEAM_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	PrecacheSound("player/flow.wav");
	PrecacheSound("mvm/mvm_cpoint_klaxon.wav");
	
	PrecacheSound("mvm/mvm_tank_end.wav");
	PrecacheSound("mvm/mvm_tank_ping.wav");
	PrecacheSound("mvm/mvm_tele_deliver.wav");
	PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
	
	//PrecacheSoundCustom("#zombiesurvival/seaborn/donner_schwert.mp3");
	
	Heavens_Beam = PrecacheModel(BLITZLIGHT_SPRITE);
	
	Zero(b_donner_valid_sniper_threats);
	Zero(fl_donner_sniper_threat_value);
	Zero(fl_donner_sniper_threat_timer_clean);
	
}

methodmap Raidboss_Donnerkrieg < CClotBody
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
	
	
	
	public Raidboss_Donnerkrieg(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.1", "25000", ally));
		
		i_NpcInternalId[npc.index] = SEA_RAIDBOSS_DONNERKRIEG;
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		b_raidboss_donnerkrieg_alive = true;
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		/*
			Will use similair logic to silvester & goggles duo
			
			Donnerkrieg is the master raidboss.
		*/
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		
		b_thisNpcIsARaid[npc.index] = true;
		
		npc.m_bThisNpcIsABoss = true;
		
		RaidModeTime = GetGameTime(npc.index) + 2000.0;
		
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

		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		//EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
			
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			b_donner_valid_sniper_threats[client_check] = false;
			fl_donner_sniper_threat_value[client_check] = 0.0;
			fl_donner_sniper_threat_timer_clean[client_check] = 0.0;
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Donnerkrieg And Schwertkrieg Spawn");
			}
		}
		
		Citizen_MiniBossSpawn();
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		Raidboss_Clean_Everyone();
		
		
		
		//Music_SetRaidMusic("#zombiesurvival/seaborn/donner_schwert.mp3", 190, true);
		
		SDKHook(npc.index, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
			
		
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
		
		
		fl_nightmare_end_timer[npc.index]= GetGameTime(npc.index) + 10.0;
		fl_cannon_Recharged[npc.index]= GetGameTime(npc.index) + 10.0;
		
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		
		fl_schwertkrieg_sniper_rampage_timer = 0.0;
		
		
		Invoke_Heavens_Light(npc.index);
		
		shared_goal = false;

		b_schwert_focus_snipers = false;
		
		EmitSoundToAll("mvm/mvm_tele_deliver.wav");
		
		CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: We have arrived to render judgement");
		
		
		//Reused silvester duo code here
		
		RequestFrame(Donnerkrieg_SpawnAllyDuoRaid, EntIndexToEntRef(npc.index)); 
		
		return npc;
	}
	
	
}

void Donnerkrieg_SpawnAllyDuoRaid(int ref)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(entity, Prop_Data, "m_angRotation", ang);
		int maxhealth;

		maxhealth = GetEntProp(entity, Prop_Data, "m_iHealth");
		
		maxhealth = RoundToFloor(maxhealth*2.5);

		int spawn_index = Npc_Create(SEA_RAIDBOSS_SCHWERTKRIEG, -1, pos, ang, GetEntProp(entity, Prop_Send, "m_iTeamNum") == 2);
		if(spawn_index > MaxClients)
		{
			i_ally_index = EntIndexToEntRef(spawn_index);
			Goggles_SetRaidPartner(entity);
			Zombies_Currently_Still_Ongoing += 1;
			SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
			SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);
		}
	}
}

//TODO 
//Rewrite
public void Raidboss_Donnerkrieg_ClotThink(int iNPC)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(iNPC);
	
	if(b_raidboss_donnerkrieg_alive)	//I don't need this here, but I still added it...
		Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(npc.index, EntRefToEntIndex(i_ally_index), true);	//donner first, schwert second
		
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
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	if(fl_nightmare_end_timer[npc.index] < GameTime && b_nightmare_logic[npc.index])
	{	
		npc.m_flRangedArmor = 1.0;
		b_nightmare_logic[npc.index] = false;
		
		if(b_angered)
		{
			fl_cannon_Recharged[npc.index] = GameTime + 60.0;
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
	
	bool target_neutralized = false;	//if all the valid target timers are no more, just forcefully set schwertkrieg to defaul behavior
	for(int client=0 ; client <MAXTF2PLAYERS ; client++)
	{
		if(fl_donner_sniper_threat_timer_clean[client]<GameTime)	//this "sniper" player hasn't attacked donnerkrieg from a far range in 30 seconds, remove them as a valid target for schwertkrieg and remove the threat
		{
			target_neutralized = true;	//a target has been neutralized, check
			fl_donner_sniper_threat_value[client] = 0.0;
			b_donner_valid_sniper_threats[client] = false; //NOTE: its likely that players might attack from a far just cause they happened to be there, so I should probably make the valid threat either be set to false sooner, or I should add a "Value" system, range vs threat %.
		}
		else
		{
			target_neutralized = false;
		}
	}
	if(target_neutralized || fl_schwertkrieg_sniper_rampage_timer < GameTime)
		b_schwert_focus_snipers = false;	//Target neutralized, returning to HQ
		
	int PrimaryThreatIndex = npc.m_iTarget;
		
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		if(fl_cannon_Recharged[npc.index]<GameTime && !b_nightmare_logic[npc.index])
		{
			fl_nightmare_end_timer[npc.index] = GameTime + 20.0;
			Raidboss_Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
		}
		if(!b_nightmare_logic[npc.index])
		{	
	
				float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
				float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
				
				Donner_Movement(npc.index, PrimaryThreatIndex);
				//Predict their pos.
				
					
				if(b_angered)	//thanks to the loss of his companion donner has gained A NECK
				{
					int iPitch = npc.LookupPoseParameter("body_pitch");
					if(iPitch < 0)
						return;		
						
					//Body pitch
					float v[3], ang[3];
					SubtractVectors(WorldSpaceCenter(npc.index), WorldSpaceCenter(PrimaryThreatIndex), v); 
					NormalizeVector(v, v);
					GetVectorAngles(v, ang); 
							
					float flPitch = npc.GetPoseParameter(iPitch);
							
					npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
				}
				if(npc.m_flNextRangedBarrage_Spam < GameTime && npc.m_flNextRangedBarrage_Singular < GameTime && flDistanceToTarget > (110.0 * 110.0) && flDistanceToTarget < (500.0 * 500.0))
				{	

					npc.FaceTowards(vecTarget);
					float projectile_speed = 400.0;
					vecTarget = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed);
					if(b_angered)
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
				if(flDistanceToTarget < 100000 || npc.m_flAttackHappenswillhappen)
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
							RAid_Normal_Attack_BEAM_TBB_Ability(npc.index);
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
			Raidboss_Donnerkrieg_Nightmare_Logic(npc.index, PrimaryThreatIndex);
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


static void Donner_Movement(int client, int PrimaryThreatIndex)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
	
	if(shared_goal)
	{
		schwert_target = PrimaryThreatIndex;	//if "shared goal" is active both npc's target the same target, the target is set by donnerkrieg
	}
	if(flDistanceToTarget < npc.GetLeadRadius())
	{
					
		float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
					

					
		NPC_SetGoalVector(npc.index, vPredictedPos);
	} 
	else 
	{
		NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
	}
}

public void Raid_Donnerkrieg_Schwertkrieg_Raidmode_Logic(int donner, int schwert, bool donner_alive)
{
	if(RaidModeTime < GetGameTime())
	{
		int entity = CreateEntityByName("game_round_win"); //You loose.
		DispatchKeyValue(entity, "force_map_reset", "1");
		SetEntProp(entity, Prop_Data, "m_iTeamNum", TFTeam_Blue);
		DispatchSpawn(entity);
		AcceptEntityInput(entity, "RoundWin");
		Music_RoundEnd(entity);
		RaidBossActive = INVALID_ENT_REFERENCE;
		if(donner_alive)
		{
			SDKUnhook(donner, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
			CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: You think thats how you fight us two?");
		}
		else
		{
			SDKUnhook(schwert, SDKHook_Think, Raidboss_Schwertkrieg_ClotThink);
		}
		
	}
}
#define HEAVENS_LIGHT_MAXIMUM_IONS 18

static float fl_heavens_damage;
static float fl_heavens_charge_time;
static float fl_heavens_charge_gametime;
static float fl_heavens_radius;
static float fl_heavens_speed;

static float fl_Heavens_Loc[HEAVENS_LIGHT_MAXIMUM_IONS+1][3];
static float fl_Heavens_Angle;

static void Invoke_Heavens_Light(int ref)
{
	float Heavens_Duration, GameTime = GetGameTime();
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	fl_heavens_damage = 100.0;
	fl_heavens_charge_time = 7.5;
	Heavens_Duration = 25.0;
	fl_heavens_radius = 200.0;	//This is per individual beam
	fl_heavens_speed = 2.5;
	
	
	fl_Heavens_Angle = 0.0;
	float time = Heavens_Duration + fl_heavens_charge_time;
	
	fl_heavens_charge_gametime = fl_heavens_charge_time + GameTime;
	
	CreateTimer(time, Heavens_End_Timer, npc.index, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(npc.index, SDKHook_Think, Heavens_TBB_Tick);
}
public Action Heavens_End_Timer(Handle timer, int client)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
	if(!IsValidEntity(client))
		return Plugin_Continue;

	SDKUnhook(npc.index, SDKHook_Think, Heavens_TBB_Tick);

	
	return Plugin_Continue;
}
public Action Heavens_TBB_Tick(int client)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
	
	if(!IsValidEntity(client))
	{
		SDKUnhook(npc.index, SDKHook_Think, Heavens_TBB_Tick);
	}
	float GameTime = GetGameTime();
	
	if(fl_heavens_charge_gametime>GameTime)
	{
		float Ratio =(fl_heavens_charge_gametime - GameTime) / fl_heavens_charge_time;	//L + Ratio
		Heavens_Light_Charging(npc.index, Ratio);
	}
	else
	{
		Heavens_Full_Charge(npc.index);
	}
	
	return Plugin_Continue;
}
static void Heavens_Full_Charge(int ref)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	for(int i=0 ; i< HEAVENS_LIGHT_MAXIMUM_IONS ; i++)
	{
		float loc[3]; loc = fl_Heavens_Loc[i];
		float Dist = -1.0;
		float Target_Loc[3]; Target_Loc = loc;
		for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
		{
			if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance<Dist || Dist==-1)
					{
						Target_Loc = client_loc;
					}
				}
	
			}
		}
		
		float Direction[3], vecAngles[3];
		MakeVectorFromPoints(loc, Target_Loc, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
						
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, fl_heavens_speed);
		AddVectors(loc, Direction, loc);
		
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, loc);
		
		for(int client=0 ; client <=MAXTF2PLAYERS ; client++)
		{
			if(IsValidClient(client) && IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client) && TeutonType[client] == TEUTON_NONE && dieingstate[client] == 0)
			{
				float client_loc[3]; GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", client_loc);
				float distance = GetVectorDistance(client_loc, loc, true);
				{
					if(distance< (fl_heavens_radius * fl_heavens_radius))
					{
						float fake_damage = fl_heavens_damage*(1.01 - (distance / (fl_heavens_radius * fl_heavens_radius)));	//reduce damage if the target just grazed it.
						SDKHooks_TakeDamage(client, npc.index, npc.index, fake_damage * 0.85, DMG_CLUB, _, _, loc);
						Client_Shake(client, 0, 5.0, 15.0, 0.1);
					}
				}
	
			}
		}
		
		fl_Heavens_Loc[i] = loc;
		
		int color[4];
		color[0] = 255;
		color[1] = 50;
		color[2] = 50;
		color[3] = 75;
		Heavens_SpawnBeam(loc, color, 7.5);
	}
}
static void Heavens_Light_Charging(int ref, float ratio)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	
	float Base_Dist = 500.0 * ratio;
	if(Base_Dist<150.0)
		Base_Dist = 150.0;
		
	float UserLoc[3], UserAng[3];
	UserLoc = GetAbsOrigin(npc.index);
	
	UserAng[0] = 0.0;
	UserAng[1] = fl_Heavens_Angle;
	UserAng[2] = 0.0;
	
	fl_Heavens_Angle += 1.5*ratio;
	
	if(fl_Heavens_Angle>=360.0)
	{
		fl_Heavens_Angle = 0.0;
	}
	
	for (int i = 0; i < 3; i++)
	{
		float distance = 0.0;
		float angMult = 1.0;
		
		switch(i)
		{
			case 0:
			{
				distance = Base_Dist;
			}
			case 1:
			{
				distance = Base_Dist*1.5;
				angMult = -1.0;
			}
			case 2:
			{
				distance = Base_Dist*2.0;
				angMult = 1.0;
			}
		}
		
		for (int j = 0; j < 6; j++)
		{
			float tempAngles[3], endLoc[3], Direction[3];
			tempAngles[0] = 0.0;
			tempAngles[1] = angMult * (UserAng[1] + (float(j) * 60.0));
			tempAngles[2] = 0.0;
			
			GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(Direction, distance);
			AddVectors(UserLoc, Direction, endLoc);
			
			Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, endLoc);
			
			

			
			if(ratio <=0.2)
			{
				int color[4];
				color[0] = 255;
				color[1] = 50;
				color[2] = 50;
				color[3] = 75;
				Heavens_SpawnBeam(endLoc, color, 7.5);
			}
			else
			{
				Heavens_Spawn8(endLoc, 150.0*ratio, ratio);
			}
			int beam_index = (i*6)+j;
			
			fl_Heavens_Loc[beam_index] = endLoc;
		}
	}
}
static void Heavens_Spawn8(float startLoc[3], float space, float ratio)
{
	for (int i = 0; i < 2 ; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		tempAngles[0] = 0.0;
		tempAngles[1] = float(i) * 180.0 + fl_Heavens_Angle;
		tempAngles[2] = 0.0;
		
		if(tempAngles[1]>=360.0)
		{
			tempAngles[1] = -360.0;
			
		}
			
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, space);
		AddVectors(startLoc, Direction, endLoc);
		int color[4];
		color[0] = 255;
		color[1] = RoundFloat(255.0 * ratio);
		color[2] = RoundFloat(255.0 * ratio);
		color[3] = 150;
		Heavens_SpawnBeam(endLoc, color, 2.0);
	}
	int color[4];
	color[0] = 255;
	color[1] = RoundFloat(255.0 * ratio);
	color[2] = RoundFloat(255.0 * ratio);
	color[3] = 150;
	
	TE_SetupBeamRingPoint(startLoc, space * 2.0, space * 2.0, Heavens_Beam, Heavens_Beam, 0, 1, 0.1, 2.0, 0.1, color, 1, 0);
	TE_SendToAll();
}
void Heavens_SpawnBeam(float beamLoc[3], int color[4], float size)
{

	float skyLoc[3];
	skyLoc[0] = beamLoc[0];
	skyLoc[1] = beamLoc[1];
	skyLoc[2] = 9999.0;
		
	TE_SetupBeamPoints(skyLoc, beamLoc, Heavens_Beam, Heavens_Beam, 0, 1, 0.1, size, size, 1, 0.5, color, 1);
	TE_SendToAll();
}
static void Raidboss_Donnerkrieg_Nightmare_Logic(int ref, int PrimaryThreatIndex)
{

				
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	
	//float vPredictedPos[3]; vPredictedPos = PredictSubjectPosition(npc, PrimaryThreatIndex);
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
	//float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(PrimaryThreatIndex), true);
	
	float GameTime = GetGameTime(npc.index);
	if(!npc.m_bInKame)
	{
		if(!b_nightmare_logic[npc.index])
		{
			if(b_angered)
			{
				fl_nightmare_grace_period[npc.index] = GameTime + 5.0;	//how long until the npc fires the cannon, basically for how long will the npc run away for
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
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}Thats it {snow}i'm going to kill you");	
				}
				case 2:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}hm, {snow}Wonder how this will end...");	
				}
				case 3:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}PREPARE {snow}Thyself, {yellow}Judgement {snow}Is near");	
				}
				case 4:
				{
					switch(GetRandomInt(0,100))
					{
						case 50:
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Oh not again now train's gone and {aliceblue}Left{snow}.");	
							b_train_line_used[npc.index] = true;
						}				
						default:
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Oh not again now cannon's gone and {aliceblue}recharged{snow}.");	
						}
							
					}
				}
				case 5:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Aiming this thing is actually quite {aliceblue}complex {snow}ya know.");	
					b_fuck_you_line_used[npc.index] = true;
				}
				case 6:
				{
					CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: Ya know, im getting quite bored of {aliceblue}this");	
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
				vBackoffPos = BackoffFromOwnPositionAndAwayFromEnemy(npc, PrimaryThreatIndex);
				NPC_SetGoalVector(npc.index, vBackoffPos, true);
				
				if(fl_nightmare_grace_period[npc.index]<GameTime)
				{
					fl_nightmare_grace_period[npc.index] = GameTime + 99.0;
					if(!b_fuck_you_line_used[npc.index] && !b_train_line_used[npc.index])
					{	
						switch(GetRandomInt(1,4))
						{
							case 1:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}NIGHTMARE, CANNON!");
							}
							case 2:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}JUDGEMENT BE UPON THEE!");
							}
							case 3:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}Ruina CANNON!");	
							}
							case 4:
							{
								CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}You cannot run, You Cannot Hide");	
							}
						}
					}
					else
					{
						if(b_train_line_used[npc.index])
						{
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: {aliceblue}And the city's to far to walk to the end while I...");	
							b_train_line_used[npc.index] = false;
						}
						else if(b_fuck_you_line_used[npc.index])
						{
							b_fuck_you_line_used[npc.index] = false;
							CPrintToChatAll("{aliceblue}Donnerkrieg{snow}: However its still{aliceblue} worth the effort");	
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
						
						
					if(b_angered)
					{
						//npc.AddActivityViaSequence("taunt_the_scaredycat_medic");
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					else
					{
						npc.AddActivityViaSequence("taunt_the_fist_bump");
					}
					
					EmitSoundToAll("mvm/sentrybuster/mvm_sentrybuster_spin.wav");
					CreateTimer(1.0, Donner_Nightmare_Offset, npc.index, TIMER_FLAG_NO_MAPCHANGE);
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
		
		if(b_angered)	//thanks to the loss of his companion donner has gained A NECK
		{
					int iPitch = npc.LookupPoseParameter("body_pitch");
					if(iPitch < 0)
						return;		
						
					//Body pitch
					float v[3], ang[3];
					SubtractVectors(WorldSpaceCenter(npc.index), WorldSpaceCenter(PrimaryThreatIndex), v); 
					NormalizeVector(v, v);
					GetVectorAngles(v, ang); 
							
					float flPitch = npc.GetPoseParameter(iPitch);
							
					npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));
		}
				
		NPC_SetGoalEntity(npc.index, PrimaryThreatIndex);
		
		if(b_angered)
		{
			f_NpcTurnPenalty[npc.index] = 0.075;	//:)
		}
		else
		{
			f_NpcTurnPenalty[npc.index] = 0.0085;	//:)
		}
		
		npc.m_flSpeed = 0.0;
		npc.m_bPathing = true;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

static Action Donner_Nightmare_Offset(Handle timer, int client)
{
	if(IsValidEntity(client))
	{
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
		fl_nightmare_end_timer[npc.index] = GetGameTime(npc.index) + 15.0;
		DonnerKriegCannon_TBB_Ability(npc.index);
	}
	return Plugin_Handled;
}
public Action Raidboss_Donnerkrieg_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(victim);
	
	
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Donnerkrieg_Set_Sniper_Threat_Value(victim, attacker, damage, weapon);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}
static void Donnerkrieg_Set_Sniper_Threat_Value(int ref, int PrimaryThreatIndex, float damage, int weapon)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(ref);
	
	float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
	
	float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
	
	float GameTime = GetGameTime(npc.index);
	
	if(flDistanceToTarget >(2000.0 * 2000.0))
	{
		char classname[32];
		GetEntityClassname(weapon, classname, 32);
	
		int weapon_slot = TF2_GetClassnameSlot(classname);
	
		if(weapon_slot == 0)	//check if its a primary, primarly checking if the player is using a long range weapon | Ideally if I could I would check if there holding a sniper weapon type, but idk how to do that
		{
			float MaxHealth = float(GetEntProp(npc.index, Prop_Data, "m_iMaxHealth"));
			
			float amt = damage / (MaxHealth/10.0);
			
			fl_schwertkrieg_sniper_rampage_timer = GameTime + RAIDBOSS_DONNERKRIEG_SCHWERTKRIEG_SNIPER_RAMPAGE_REFRESH_TIME;
			fl_donner_sniper_threat_value[PrimaryThreatIndex]+= amt;
			b_donner_valid_sniper_threats[PrimaryThreatIndex] = true;	//this player is now a valid target for schwert to focus if schwert goes into anti sniper mode
			fl_donner_sniper_threat_timer_clean[PrimaryThreatIndex] = GameTime + RAIDBOSS_DONNERKRIEG_SNIPER_CLEAN_TIMER;
		}
	}
	
	float threat_ammount = 0.0;
	for(int client=0 ; client <MAXTF2PLAYERS ; client++)
	{
		threat_ammount += fl_donner_sniper_threat_value[client];
	}
		
	if(threat_ammount>0.25 && !b_schwert_focus_snipers)
	{
		b_schwert_focus_snipers = true;
	}
	if(threat_ammount<0.25)
		b_schwert_focus_snipers = false;
}

public void Raidboss_Donnerkrieg_NPCDeath(int entity)
{
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	shared_goal = false;
	b_raidboss_donnerkrieg_alive = false;
	
	RaidModeTime += 2.0; //cant afford to delete it, since duo.
	//add 2 seconds so if its close, they dont lose to timer.
	
	if(b_raidboss_schwertkrieg_alive)	//handover the hud to schwert
	{
		RaidBossActive = EntRefToEntIndex(i_ally_index);
	}
	
	StopSound(entity,SNDCHAN_STATIC,"weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	
	SDKUnhook(npc.index, SDKHook_Think, Raidboss_Donnerkrieg_ClotThink);
		
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
void RAid_Normal_Attack_BEAM_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		DonnerKriegCannon_BEAM_BuildingHit[building] = false;
	}
			
	DonnerKriegCannon_BEAM_IsUsing[client] = false;
	DonnerKriegCannon_BEAM_TicksActive[client] = 0;

	DonnerKriegCannon_BEAM_CanUse[client] = true;

	float dmg = 23.0*RaidModeScaling;
	if(b_angered)
	{
		dmg *= 1.5;
	}
	DonnerKriegCannon_BEAM_CloseDPT[client] = dmg;
	DonnerKriegCannon_BEAM_FarDPT[client] = dmg;
	DonnerKriegCannon_BEAM_MaxDistance[client] = 1000;
	DonnerKriegCannon_BEAM_BeamRadius[client] = 10;
	DonnerKriegCannon_BEAM_ColorHex[client] = ParseColor("FFFFFF");
	DonnerKriegCannon_BEAM_ChargeUpTime[client] = 12;
	DonnerKriegCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	DonnerKriegCannon_BEAM_FarBuildingDPT[client] = 0.0;
	DonnerKriegCannon_BEAM_Duration[client] = 0.25;
	
	DonnerKriegCannon_BEAM_BeamOffset[client][0] = 0.0;
	DonnerKriegCannon_BEAM_BeamOffset[client][1] = 0.0;
	DonnerKriegCannon_BEAM_BeamOffset[client][2] = 0.0;

	DonnerKriegCannon_BEAM_ZOffset[client] = 0.0;
	DonnerKriegCannon_BEAM_UseWeapon[client] = false;

	DonnerKriegCannon_BEAM_IsUsing[client] = true;
	DonnerKriegCannon_BEAM_TicksActive[client] = 0;
	
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
			

	CreateTimer(DonnerKriegCannon_BEAM_Duration[client], DonnerKriegCannon_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, DonnerKriegCannon_TBB_Tick);
	
}
void DonnerKriegCannon_TBB_Ability(int client)
{
	for (int building = 1; building < MaxClients; building++)
	{
		DonnerKriegCannon_BEAM_BuildingHit[building] = false;
	}
	
	ParticleEffectAt(WorldSpaceCenter(client), "eyeboss_death_vortex", 2.0);
	EmitSoundToAll("mvm/mvm_tank_ping.wav");
			
	DonnerKriegCannon_BEAM_IsUsing[client] = false;
	DonnerKriegCannon_BEAM_TicksActive[client] = 0;

	DonnerKriegCannon_BEAM_CanUse[client] = true;
	float dmg = 500.0*RaidModeScaling;
	if(b_angered)
	{
		dmg *= 1.5;
	}
	DonnerKriegCannon_BEAM_CloseDPT[client] = dmg;
	DonnerKriegCannon_BEAM_FarDPT[client] = dmg;
	DonnerKriegCannon_BEAM_MaxDistance[client] = 10000;
	DonnerKriegCannon_BEAM_BeamRadius[client] = 150;
	DonnerKriegCannon_BEAM_ColorHex[client] = ParseColor("ff0303");
	DonnerKriegCannon_BEAM_ChargeUpTime[client] = 150;
	DonnerKriegCannon_BEAM_CloseBuildingDPT[client] = 0.0;
	DonnerKriegCannon_BEAM_FarBuildingDPT[client] = 0.0;
	DonnerKriegCannon_BEAM_Duration[client] = 15.0;
	
	DonnerKriegCannon_BEAM_BeamOffset[client][0] = 0.0;	//forward/back
	DonnerKriegCannon_BEAM_BeamOffset[client][1] = -1.0;	//left right
	DonnerKriegCannon_BEAM_BeamOffset[client][2] = 25.0;	//up down

	DonnerKriegCannon_BEAM_ZOffset[client] = 0.0;
	DonnerKriegCannon_BEAM_UseWeapon[client] = false;

	DonnerKriegCannon_BEAM_IsUsing[client] = true;
	DonnerKriegCannon_BEAM_TicksActive[client] = 0;
	
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
			

	CreateTimer(DonnerKriegCannon_BEAM_Duration[client], DonnerKriegCannon_TBB_Timer, client, TIMER_FLAG_NO_MAPCHANGE);
	SDKHook(client, SDKHook_Think, DonnerKriegCannon_TBB_Tick);
	
}
public Action DonnerKriegCannon_TBB_Timer(Handle timer, int client)
{
	if(!IsValidEntity(client))
		return Plugin_Continue;

	DonnerKriegCannon_BEAM_IsUsing[client] = false;
	
	DonnerKriegCannon_BEAM_TicksActive[client] = 0;
	
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(client, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	EmitSoundToAll("weapons/physcannon/physcannon_drop.wav", client, SNDCHAN_STATIC, 80, _, 1.0);
	
	return Plugin_Continue;
}

public bool DonnerKriegCannon_BEAM_TraceWallsOnly(int entity, int contentsMask)
{
	return !entity;
}

#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define MAX_PLAYERS_ARRAY 36

public bool DonnerKriegCannon_BEAM_TraceUsers(int entity, int contentsMask, int client)
{
	if (IsEntityAlive(entity))
	{
		DonnerKriegCannon_BEAM_HitDetected[entity] = true;
	}
	return false;
}

#define MAXTF2PLAYERS	36

static void DonnerKriegCannon_GetBeamDrawStartPoint(int client, float startPoint[3])
{
	float angles[3];
	GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
	int iPitch = npc.LookupPoseParameter("body_pitch");
	if(iPitch < 0)
			return;	
	float flPitch = npc.GetPoseParameter(iPitch);
	flPitch *= -1.0;
	angles[0] = flPitch;
	startPoint = GetAbsOrigin(client);
	startPoint[2] += 50.0;
	
	if (0.0 == DonnerKriegCannon_BEAM_BeamOffset[client][0] && 0.0 == DonnerKriegCannon_BEAM_BeamOffset[client][1] && 0.0 == DonnerKriegCannon_BEAM_BeamOffset[client][2])
	{
		return;
	}
	float tmp[3];
	float actualBeamOffset[3];
	tmp[0] = DonnerKriegCannon_BEAM_BeamOffset[client][0];
	tmp[1] = DonnerKriegCannon_BEAM_BeamOffset[client][1];
	tmp[2] = 0.0;
	VectorRotate(tmp, angles, actualBeamOffset);
	actualBeamOffset[2] = DonnerKriegCannon_BEAM_BeamOffset[client][2];
	startPoint[0] += actualBeamOffset[0];
	startPoint[1] += actualBeamOffset[1];
	startPoint[2] += actualBeamOffset[2];
}

public Action DonnerKriegCannon_TBB_Tick(int client)
{
	static int tickCountClient[MAXENTITIES];
	if(!IsValidEntity(client) || !DonnerKriegCannon_BEAM_IsUsing[client])
	{
		tickCountClient[client] = 0;
		SDKUnhook(client, SDKHook_Think, DonnerKriegCannon_TBB_Tick);
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
		npc.m_bInKame = false;
	}

	int tickCount = tickCountClient[client];
	tickCountClient[client]++;
	
	

	DonnerKriegCannon_BEAM_TicksActive[client] = tickCount;
	float diameter = float(DonnerKriegCannon_BEAM_BeamRadius[client] * 4);
	int r = GetR(DonnerKriegCannon_BEAM_ColorHex[client]);
	int g = GetG(DonnerKriegCannon_BEAM_ColorHex[client]);
	int b = GetB(DonnerKriegCannon_BEAM_ColorHex[client]);
	if (DonnerKriegCannon_BEAM_ChargeUpTime[client] <= tickCount)
	{
		static float angles[3];
		static float startPoint[3];
		static float endPoint[3];
		static float hullMin[3];
		static float hullMax[3];
		static float playerPos[3];
		GetEntPropVector(client, Prop_Data, "m_angRotation", angles);
		Raidboss_Donnerkrieg npc = view_as<Raidboss_Donnerkrieg>(client);
		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return Plugin_Continue;
			
		float flPitch = npc.GetPoseParameter(iPitch);
		flPitch *= -1.0;
		angles[0] = flPitch;
		startPoint = GetAbsOrigin(client);
		startPoint[2] += 50.0;
		
		if(!b_nightmare_logic[npc.index])
		{
			float flAng[3]; // original
			GetAttachment(npc.index, "effect_hand_r", startPoint, flAng);
		}

		Handle trace = TR_TraceRayFilterEx(startPoint, angles, 11, RayType_Infinite, DonnerKriegCannon_BEAM_TraceWallsOnly);
		if (TR_DidHit(trace))
		{
			TR_GetEndPosition(endPoint, trace);
			CloseHandle(trace);
			ConformLineDistance(endPoint, startPoint, endPoint, float(DonnerKriegCannon_BEAM_MaxDistance[client]));
			float lineReduce = DonnerKriegCannon_BEAM_BeamRadius[client] * 2.0 / 3.0;
			float curDist = GetVectorDistance(startPoint, endPoint, false);
			if (curDist > lineReduce)
			{
				ConformLineDistance(endPoint, startPoint, endPoint, curDist - lineReduce);
			}
			for (int i = 1; i < MAXENTITIES; i++)
			{
				DonnerKriegCannon_BEAM_HitDetected[i] = false;
			}
			
			if(!b_health_stripped)
			{
				int PrimaryThreatIndex = npc.m_iTarget;
				if(IsValidEnemy(npc.index, PrimaryThreatIndex) &&  !b_nightmare_logic[npc.index])
				{
					float target_vec[3]; target_vec = GetAbsOrigin(PrimaryThreatIndex);
					endPoint[2] = target_vec[2];
				}
			}
			
			hullMin[0] = -float(DonnerKriegCannon_BEAM_BeamRadius[client]);
			hullMin[1] = hullMin[0];
			hullMin[2] = hullMin[0];
			hullMax[0] = -hullMin[0];
			hullMax[1] = -hullMin[1];
			hullMax[2] = -hullMin[2];
			trace = TR_TraceHullFilterEx(startPoint, endPoint, hullMin, hullMax, 1073741824, DonnerKriegCannon_BEAM_TraceUsers, client);	// 1073741824 is CONTENTS_LADDER?
			delete trace;
			
			for (int victim = 1; victim < MAXENTITIES; victim++)
			{
				if (DonnerKriegCannon_BEAM_HitDetected[victim] && GetEntProp(client, Prop_Send, "m_iTeamNum") != GetEntProp(victim, Prop_Send, "m_iTeamNum"))
				{
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", playerPos, 0);
					float distance = GetVectorDistance(startPoint, playerPos, false);
					float damage = DonnerKriegCannon_BEAM_CloseDPT[client] + (DonnerKriegCannon_BEAM_FarDPT[client]-DonnerKriegCannon_BEAM_CloseDPT[client]) * (distance/DonnerKriegCannon_BEAM_MaxDistance[client]);
					if (damage < 0)
						damage *= -1.0;

					if(ShouldNpcDealBonusDamage(victim))
					{
						damage *= 5.0;
					}
					SDKHooks_TakeDamage(victim, client, client, (damage/6), DMG_PLASMA, -1, NULL_VECTOR, startPoint);	// 2048 is DMG_NOGIB?
				}
			}
			static float belowBossEyes[3];
			if(!b_nightmare_logic[npc.index])
			{
				belowBossEyes = startPoint;
				
			}
			else
			{
				
				DonnerKriegCannon_GetBeamDrawStartPoint(client, belowBossEyes);
			}
			
			int colorLayer4[4];
			SetColorRGBA(colorLayer4, r, g, b, 30);
			int colorLayer3[4];
			SetColorRGBA(colorLayer3, colorLayer4[0] * 7 + 255 / 8, colorLayer4[1] * 7 + 255 / 8, colorLayer4[2] * 7 + 255 / 8, 30);
			int colorLayer2[4];
			SetColorRGBA(colorLayer2, colorLayer4[0] * 6 + 510 / 8, colorLayer4[1] * 6 + 510 / 8, colorLayer4[2] * 6 + 510 / 8, 30);
			int colorLayer1[4];
			SetColorRGBA(colorLayer1, colorLayer4[0] * 5 + 765 / 8, colorLayer4[1] * 5 + 765 / 8, colorLayer4[2] * 5 + 765 / 8, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.3), ClampBeamWidth(diameter * 0.3), 0, 5.0, colorLayer1, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.5), ClampBeamWidth(diameter * 0.5), 0, 5.0, colorLayer2, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter * 0.8), ClampBeamWidth(diameter * 0.8), 0, 5.0, colorLayer3, 3);
			TE_SendToAll(0.0);
			TE_SetupBeamPoints(belowBossEyes, endPoint, DonnerKriegCannon_BEAM_Laser, 0, 0, 0, 0.11, ClampBeamWidth(diameter), ClampBeamWidth(diameter), 0, 1.0, colorLayer4, 3);
			TE_SendToAll(0.0);
			int glowColor[4];
			SetColorRGBA(glowColor, r, g, b, 30);
			TE_SetupBeamPoints(belowBossEyes, endPoint, DonnerKriegCannon_BEAM_Glow, 0, 0, 0, 0.11, ClampBeamWidth(diameter*2.5), ClampBeamWidth(diameter), 0, 2.5, glowColor, 0);
			TE_SendToAll(0.0);
			
			
		}
		else
		{
			delete trace;
		}
	}
	return Plugin_Continue;
}