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
	"vo/medic_painsharp05.mp3",
	"vo/medic_painsharp06.mp3",
	"vo/medic_painsharp07.mp3",
	"vo/medic_painsharp08.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/medic_standonthepoint01.mp3",
	"vo/medic_standonthepoint02.mp3",
	"vo/medic_standonthepoint03.mp3",
	"vo/medic_standonthepoint04.mp3",
	"vo/medic_standonthepoint05.mp3",
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
	"vo/medic_battlecry05.mp3",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/demo_sword_swing1.wav",
	"weapons/demo_sword_swing2.wav",
	"weapons/demo_sword_swing3.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};

void Magia_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	for (int i = 0; i < (sizeof(g_TeleportSounds));   i++) { PrecacheSound(g_TeleportSounds[i]);  			}
	PrecacheModel("models/player/medic.mdl");
}

methodmap Magia < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayTeleportSound()");
		#endif
	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
		#endif
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayDeathSound()");
		#endif
	}
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
		#endif
	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayMeleeMissSound()");
		#endif
	}
	
	
	public Magia(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Magia npc = view_as<Magia>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcInternalId[npc.index] = RUINA_MAGIA;
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			nunhood						//Xms2013_Medic_Hood
			ramses regalia				//Hw2013_Ramses_Regalia
			lo-grav loafers				//Hw2013_Moon_Boots
			angel of death				//Xms2013_Medic_Robe
		
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		
		
		SDKHook(npc.index, SDKHook_Think, Magia_ClotThink);
		
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_ramses_regalia/hw2013_ramses_regalia.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");
		
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/xms2013_medic_robe/xms2013_medic_robe.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
				
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, 2);	//is a ranged npc
		
		Magia_Create_Hand_Crest(npc.index);
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Magia_ClotThink(int iNPC)
{
	Magia npc = view_as<Magia>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	fl_ruina_battery[npc.index] += 5.0;
	
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
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(fl_ruina_battery[npc.index]>500.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 2.5;
		
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{
		bool buff_array[3];
		buff_array[0] = false;	//defense
		buff_array[1] = true;	//speed
		buff_array[2] = false;	//attack
		
		float buff_array_amt[3];
		//buff_array_amt[0] = 0.2;	//20% dmg bonus
		buff_array_amt[1] = 1.3;	//going bellow 1.0 will reduce speed. 30% speed boost
		//buff_array_amt[2] = 0.05;	//5% dmg resist
				
				
		Apply_Master_Buff(npc.index, buff_array, 125.0, 1.0, buff_array_amt);
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
		
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			//Predict their pos.
			Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex);	//handles movement
			
			if(flDistanceToTarget < 100000)
			{
				if(flDistanceToTarget < 50000)
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
				
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
			}
			
			//Target close enough to hit
			if(flDistanceToTarget < 1000000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
				//npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.FaceTowards(vecTarget, 100000.0);
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
						npc.m_flNextMeleeAttack = GetGameTime(npc.index)+1.0;
						npc.m_flAttackHappenswillhappen = true;
						float flPos[3]; // original
						float flAng[3]; // original
						
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);
						
						float projectile_speed = 1000.0;
						float target_vec[3];
						target_vec = PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed);
		
						npc.FireParticleRocket(target_vec, 50.0 , projectile_speed , 100.0 , "raygun_projectile_blue", _, _, true, flPos);
						
					}
					else
					{
						npc.m_flAttackHappenswillhappen = false;
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

static int i_particle[MAXENTITIES][11];
static int i_laser[MAXENTITIES][8];

static void Magia_Create_Hand_Crest(int client)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(client, "effect_hand_r", flPos, flAng);
	
	
	int r, g, b;
	float f_start, f_end, amp;
	r = 1;
	g = 175;
	b = 255;
	f_start = 1.0;
	f_end = 1.0;
	amp = 0.1;
	
	int particle_0 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Foward, Back
	//Z axis - Up Down
	
	
	int particle_2 = ParticleEffectAt({0.0, 0.0, 15.0}, "", 0.0);
	int particle_2_1 = ParticleEffectAt({0.0, 0.0, -15.0}, "", 0.0);
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_2, particle_2_1, "",_, true);
	
	int particle_4 = ParticleEffectAt({15.0, 0.0, 0.0}, "", 0.0);
	int particle_4_1 = ParticleEffectAt({-15.0, 0.0, 0.0}, "", 0.0);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_4, particle_4_1, "",_, true);
	
	int particle_5 = ParticleEffectAt({7.5, 0.0, 7.5}, "", 0.0);
	int particle_5_1 = ParticleEffectAt({-7.5, 0.0, -7.5}, "", 0.0);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_5, particle_5_1, "",_, true);
	
	int particle_6 = ParticleEffectAt({-7.5, 0.0, 7.5}, "", 0.0);
	int particle_6_1 = ParticleEffectAt({7.5, 0.0, -7.5}, "", 0.0);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_6, particle_6_1, "",_, true);


	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_0, "effect_hand_r",_);

	
	i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_2_1, particle_2, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_4_1, particle_4, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_5_1, particle_5, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_6_1, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	/*i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_2, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_2_1, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_4, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_4_1, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][4] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_5, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][5] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_5_1, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][6] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_6, 255, 0, 0, f_start, f_end, amp, LASERBEAM));
	i_laser[client][7] = EntIndexToEntRef(ConnectWithBeamClient(particle_3_1, particle_6_1, 255, 0, 0, f_start, f_end, amp, LASERBEAM));*/
	
	
	i_particle[client][0] = EntIndexToEntRef(particle_0);
	i_particle[client][1] = EntIndexToEntRef(particle_1);
	i_particle[client][2] = EntIndexToEntRef(particle_2);
	i_particle[client][3] = EntIndexToEntRef(particle_4);
	i_particle[client][4] = EntIndexToEntRef(particle_4_1);
	i_particle[client][5] = EntIndexToEntRef(particle_5);
	i_particle[client][6] = EntIndexToEntRef(particle_5_1);
	i_particle[client][7] = EntIndexToEntRef(particle_6);
	i_particle[client][8] = EntIndexToEntRef(particle_6_1);
	
}
static void Delete_Hand_Crest(int client)
{
	for(int laser=0 ; laser<4 ; laser++)
	{
		int entity = EntRefToEntIndex(i_laser[client][laser]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
	for(int particle=0 ; particle < 9 ; particle++)
	{
		int entity = EntRefToEntIndex(i_particle[client][particle]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
}

public Action Magia_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Magia npc = view_as<Magia>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	fl_ruina_battery[npc.index] += damage;	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Magia_NPCDeath(int entity)
{
	Magia npc = view_as<Magia>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Delete_Hand_Crest(entity);
	
	SDKUnhook(npc.index, SDKHook_Think, Magia_ClotThink);
		
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	
}