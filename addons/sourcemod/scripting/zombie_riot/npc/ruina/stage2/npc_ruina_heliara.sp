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

void Heliara_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Heliara");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_heliara");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Heliara(client, vecPos, vecAng, ally);
}


methodmap Heliara < CClotBody
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
	
	
	public Heliara(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Heliara npc = view_as<Heliara>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		npc.m_flSpeed = 230.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {
			"models/player/items/medic/berliners_bucket_helm.mdl",
			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl",
			"models/workshop/player/items/medic/dec15_bunnyhoppers_ballistics_vest/dec15_bunnyhoppers_ballistics_vest.mdl",
			"models/workshop/player/items/medic/jul13_emergency_supplies/jul13_emergency_supplies.mdl",
			"models/workshop/player/items/spy/short2014_deadhead/short2014_deadhead.mdl",
			RUINA_CUSTOM_MODELS_1,
			RUINA_CUSTOM_MODELS_1
		};
		
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItemSeperate("head", Items[5],_,_,2.0,85.0);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_HALO_1);
		AcceptEntityInput(npc.m_iWearable6, "SetBodyGroup");
		SetVariantInt(RUINA_HEALING_STAFF_1);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");
				
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc

		Ruina_Set_Healer(npc.index);
		
		Heliara_Create_Crest(npc.index);
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Heliara npc = view_as<Heliara>(iNPC);
	
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

	Ruina_Add_Battery(npc.index, 1.0);

	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(fl_ruina_battery[npc.index]>850.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 2.5;
		fl_ruina_helia_healing_timer[npc.index]=0.0;

		fl_multi_attack_delay[npc.index] = 0.0;
		
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{	
		if(fl_multi_attack_delay[npc.index] < GameTime)
		{
			fl_multi_attack_delay[npc.index] = GameTime + 0.25;
					
			Helia_Healing_Logic(npc.index, 500, 500.0, GameTime, 1.0, {255, 255, 255, 255});
		}
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		//Predict their pos.
		Ruina_Basic_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime);	//handles movement
			
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
			
		if(flDistanceToTarget < (750.0*750.0))
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (500.0*500.0))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					if(fl_multi_attack_delay[npc.index] < GameTime)
					{
						fl_multi_attack_delay[npc.index] = GameTime + 0.5;
					
						Helia_Healing_Logic(npc.index, 150, 175.0, GameTime, 3.5, {255, 155, 155, 255});

					}
				}
				else	
				{
					if(fl_multi_attack_delay[npc.index] < GameTime)
					{
						fl_multi_attack_delay[npc.index] = GameTime + 0.5;
					
						Helia_Healing_Logic(npc.index, 300, 250.0, GameTime, 3.5, {255, 155, 155, 255});
					}
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
				}
			}
			else				
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
				if(fl_multi_attack_delay[npc.index] < GameTime)
				{
					fl_multi_attack_delay[npc.index] = GameTime + 0.5;
					
					Helia_Healing_Logic(npc.index, 150, 175.0, GameTime, 3.5, {255, 155, 155, 255});

				}
			
			}	
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
		}

		Ruina_Self_Defense Melee;

		Melee.iNPC = npc.index;
		Melee.target = PrimaryThreatIndex;
		Melee.fl_distance_to_target = flDistanceToTarget;
		Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25;
		Melee.damage = 25.0;
		Melee.bonus_dmg = 125.0;
		Melee.attack_anim = "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS";
		Melee.swing_speed = 0.54;
		Melee.swing_delay = 0.4;
		Melee.turn_speed = 20000.0;
		Melee.gameTime = GameTime;
		Melee.status = 0;
		Melee.Swing_Melee(OnRuina_MeleeAttack);

		switch(Melee.status)
		{
			case 1:	//we swung
				npc.PlayMeleeSound();
			case 2:	//we hit something
				npc.PlayMeleeHitSound();
			case 3:	//we missed
				npc.PlayMeleeMissSound();
			//0 means nothing.
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
static void OnRuina_MeleeAttack(int iNPC, int Target)
{
	Ruina_Add_Mana_Sickness(iNPC, Target, 0.1, 0);
}

static int i_particle[MAXENTITIES][11];
static int i_laser[MAXENTITIES][9];

static void Heliara_Create_Crest(int client)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(client, "root", flPos, flAng);
	
	
	int r, g, b;
	float f_start, f_end, amp;
	r = 1;
	g = 175;
	b = 255;
	f_start = 1.0;
	f_end = 1.0;
	amp = 0.1;
	
	int particle_0 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = InfoTargetParentAt({0.0,0.0,100.0}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Foward, Back
	//Z axis - Up Down

	int particle_2 = InfoTargetParentAt({112.5, 0.0, 50.0}, "", 0.0);
	int particle_2_1 = InfoTargetParentAt({-112.5, 0.0, 50.0}, "", 0.0);
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_2, particle_2_1, "",_, true);
	
	int particle_4 = InfoTargetParentAt({75.0, -75.0, 50.0}, "", 0.0);
	int particle_4_1 = InfoTargetParentAt({-75.0, 75.0, 50.0}, "", 0.0);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_4, particle_4_1, "",_, true);
	
	int particle_5 = InfoTargetParentAt({0.0, 112.5, 50.0}, "", 0.0);
	int particle_5_1 = InfoTargetParentAt({0.0, -112.5, 50.0}, "", 0.0);
	SetParent(particle_1, particle_5, "",_, true);
	SetParent(particle_5, particle_5_1, "",_, true);
	
	int particle_6 = InfoTargetParentAt({-75.0, -75.0, 50.0}, "", 0.0);
	int particle_6_1 = InfoTargetParentAt({75.0, 75.0, 50.0}, "", 0.0);
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_6, particle_6_1, "",_, true);


	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_0, "root",_);

	/* 
		particle_2 particle_4 particle_5 particle_6 particle_2_1 particle_4_1 particle_5_1 particle_6_1

	*/
	
	//i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_2_1, particle_2, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	//i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_4_1, particle_4, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	//i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_5_1, particle_5, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	//i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_6_1, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_laser[client][0] = EntIndexToEntRef(ConnectWithBeamClient(particle_2, particle_4, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_4_1, particle_5, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_5, particle_6_1, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_2_1, particle_4_1, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][4] = EntIndexToEntRef(ConnectWithBeamClient(particle_5_1, particle_6, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][5] = EntIndexToEntRef(ConnectWithBeamClient(particle_4, particle_5_1, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][6] = EntIndexToEntRef(ConnectWithBeamClient(particle_6_1, particle_2, r, g, b, f_start, f_end, amp, LASERBEAM));

	i_laser[client][7] = EntIndexToEntRef(ConnectWithBeamClient(particle_6, particle_2_1, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	
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
	for(int laser=0 ; laser<8 ; laser++)
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

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Heliara npc = view_as<Heliara>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Heliara npc = view_as<Heliara>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	Delete_Hand_Crest(entity);

	Ruina_NPCDeath_Override(entity);
	
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
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
	
}