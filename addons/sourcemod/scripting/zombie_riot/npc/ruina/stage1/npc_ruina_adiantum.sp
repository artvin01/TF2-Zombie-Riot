#pragma semicolon 1
#pragma newdecls required


static char g_HurtSounds[][] = {
	"vo/spy_painsharp01.mp3",
	"vo/spy_painsharp02.mp3",
	"vo/spy_painsharp03.mp3",
	"vo/spy_painsharp04.mp3",
};

static char g_DeathSounds[][] = {
	"vo/spy_paincrticialdeath01.mp3",
	"vo/spy_paincrticialdeath02.mp3",
	"vo/spy_paincrticialdeath03.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/spy_laughshort01.mp3",
	"vo/spy_laughshort02.mp3",
	"vo/spy_laughshort03.mp3",
	"vo/spy_laughshort04.mp3",
	"vo/spy_laughshort05.mp3",
	"vo/spy_laughshort06.mp3",
};

static char g_IdleAlertedSounds[][] = {
	"vo/spy_battlecry01.mp3",
	"vo/spy_battlecry02.mp3",
	"vo/spy_battlecry03.mp3",
	"vo/spy_battlecry04.mp3",
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


static char gLaser1;
static char gExplosive1;

public void Adiantum_OnMapStart_NPC()
{
	
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Adiantum");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_adiantum");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "spy"); 		//leaderboard_class_(insert the name)
	data.IconCustom = false;													//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;																//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_IdleSounds);
	
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	PrecacheSound("misc/halloween/gotohell.wav");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Adiantum(client, vecPos, vecAng, ally);
}


methodmap Adiantum < CClotBody
{
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleSound()");
		#endif
	}
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(4.0, 7.0);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayIdleAlertSound()");
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
	public void PlayDeathSound() {
		
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);
		
		EmitSoundToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayHurtSound()");
		#endif
	}
	public Adiantum(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Adiantum npc = view_as<Adiantum>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "13500", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		i_NpcWeight[npc.index] = 2;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		
		/*
			blighted beak			Medic_Blighted_Beak
			braniac hairpiece		Drg_Brainiac_Hair
			claidemor
			coldfront carapace		Dec17_Coldfront_Carapace
			herzensbrecher
			quadwrangler			Qc_Glove
		*/
		
		

		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		
		npc.m_iWearable2 = npc.EquipItem("head", "models/player/items/medic/qc_glove.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		
		npc.m_iWearable3 = npc.EquipItem("head", "models/weapons/c_models/c_claidheamohmor/c_claidheamohmor.mdl");	//claidemor
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable3, "SetModelScale");

		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable4, "SetModelScale");
		
		npc.m_iWearable5 = npc.EquipItem("head", "models/player/items/engineer/drg_brainiac_hair.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable5, "SetModelScale");
		
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/dec17_coldfront_carapace/dec17_coldfront_carapace.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable6, "SetModelScale");
		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
		
		Adiantum_Create_Wings(npc.index);
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 10, 3);	//attracts ranged npc's, can have a maxiumum of 10 of them, priority 3
		
		Ruina_Master_Rally(npc.index, true);	//this npc is always rallying ranged npc's
		
		npc.m_flSpeed = 225.0;
		
		npc.m_flCharge_Duration = 0.0;
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		npc.StartPathing();
		

		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Adiantum npc = view_as<Adiantum>(iNPC);
	
	float GameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > GameTime)
	{
		return;
	}
	
	npc.m_flNextDelayTime = GameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	
		
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST");
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
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		npc.PlayIdleSound();
		
			
			
		Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement
			
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
			
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
			
		if(npc.m_flNextRangedBarrage_Spam < GameTime)
		{

			Master_Apply_Defense_Buff(npc.index, 250.0, 5.0, 0.1);
			Master_Apply_Attack_Buff(npc.index, 250.0, 5.0, 0.05);
				
			Adiantum_Summon_Ion_Barrage(npc.index, vecTarget);
			npc.m_flNextRangedBarrage_Spam = GameTime + 20.0;
		}

		Ruina_Self_Defense Melee;

		Melee.iNPC = npc.index;
		Melee.target = PrimaryThreatIndex;
		Melee.fl_distance_to_target = flDistanceToTarget;
		Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED;
		Melee.damage = 75.0;
		Melee.bonus_dmg = 350.0;
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
	Ruina_Add_Mana_Sickness(iNPC, Target, 0.25, 50);
}
static int i_particle_wings_index[MAXENTITIES][10];
static int i_laser_wings_index[MAXENTITIES][10];

static void Adiantum_Create_Wings(int client)
{
	float flPos[3];
	float flAng[3];
	GetAttachment(client, "flag", flPos, flAng);
	
	
	int r, g, b;
	float f_start, f_end, amp;
	r = 1;
	g = 175;
	b = 255;
	f_start = 1.0;
	f_end = 1.0;
	amp = 1.0;
	
	int particle_0 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Up down, for once
	//Z axis - Forward backwards.????????
	
	//ALL OF THESE ARE RELATIVE TO THE BACKPACK POINT THINGY, or well the viewmodel, but its easier to visualise if using the back
	//Left?
	
	int particle_2 = InfoTargetParentAt({20.0, 10.5, 2.5}, "", 0.0);	//x,y,z	//Z axis IS NOT UP/DOWN, its forward and backwards. somehow
	int particle_2_1 = InfoTargetParentAt({45.0, 35.0, -5.0}, "", 0.0);
	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_2, particle_2_1, "",_, true);


	Custom_SDKCall_SetLocalOrigin(particle_0, flPos);
	SetEntPropVector(particle_0, Prop_Data, "m_angRotation", flAng); 
	SetParent(client, particle_0, "flag",_);

	i_laser_wings_index[client][1] = EntIndexToEntRef(ConnectWithBeamClient(particle_2, particle_1, r, g, b, f_start, f_end, amp, LASERBEAM));
	i_laser_wings_index[client][2] = EntIndexToEntRef(ConnectWithBeamClient(particle_2_1, particle_2, r, g, b, f_start, f_end, amp, LASERBEAM));
	i_laser_wings_index[client][3] = EntIndexToEntRef(ConnectWithBeamClient(particle_1, particle_2_1, r, g, b, f_start, f_end, amp, LASERBEAM));
	
	i_particle_wings_index[client][0] = EntIndexToEntRef(particle_0);
	i_particle_wings_index[client][1] = EntIndexToEntRef(particle_1);
	i_particle_wings_index[client][2] = EntIndexToEntRef(particle_2);
	i_particle_wings_index[client][3] = EntIndexToEntRef(particle_2_1);

}
static void Adiantum_Destroy_Wings(int client)
{
	for(int wing=1 ; wing<=3 ; wing++)
	{
		int entity = EntRefToEntIndex(i_laser_wings_index[client][wing]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
	for(int particle=0 ; particle<=3 ; particle++)
	{
		int entity = EntRefToEntIndex(i_particle_wings_index[client][particle]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);
	}
}
static void Adiantum_Summon_Ion_Barrage(int client, float vecTarget[3])
{
	float current_loc[3]; GetAbsOrigin(client, current_loc);
	float vecAngles[3], Direction[3], endLoc[3];
	
	
			
	for(int ion=1 ; ion <= 10 ; ion++)
	{
		MakeVectorFromPoints(current_loc, vecTarget, vecAngles);
		GetVectorAngles(vecAngles, vecAngles);
	
		GetAngleVectors(vecAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, 100.0*ion);
		AddVectors(current_loc, Direction, endLoc);
		
		Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, endLoc);
		
		Adiantum_Ion_Invoke(client, endLoc, float(ion)/5.0);
	}
}

public void Adiantum_Ion_Invoke(int ref, float vecTarget[3], float Time)
{
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity))
	{
		
		float Range=100.0;
		float Dmg = 100.0;
		
		int color[4] = {1, 175, 255, 255};
		float UserLoc[3];
		GetAbsOrigin(entity, UserLoc);
		
		UserLoc[2]+=75.0;
		
		int SPRITE_INT_2 = PrecacheModel("materials/sprites/lgtning.vmt", false);
					
		TE_SetupBeamPoints(vecTarget, UserLoc, SPRITE_INT_2, 0, 0, 0, 0.8, 22.0, 10.2, 1, 8.0, color, 0);
		TE_SendToAll();

		EmitSoundToAll("misc/halloween/gotohell.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL*0.5, SNDPITCH_NORMAL, -1, vecTarget);
		
		Handle data;
		CreateDataTimer(Time, Smite_Timer_Adiantum, data, TIMER_FLAG_NO_MAPCHANGE);
		WritePackFloat(data, vecTarget[0]);
		WritePackFloat(data, vecTarget[1]);
		WritePackFloat(data, vecTarget[2]);
		WritePackFloat(data, Range); // Range
		WritePackFloat(data, Dmg); // Damge
		WritePackCell(data, ref);
		
		spawnRing_Vectors(vecTarget, Range * 2.0, 0.0, 0.0, 0.0, "materials/sprites/laserbeam.vmt", 1, 175, 255, 255, 1, Time, 6.0, 0.1, 1, 1.0);
	}
}

public Action Smite_Timer_Adiantum(Handle Smite_Logic, DataPack data)
{
	ResetPack(data);
		
	float startPosition[3];
	float position[3];
	startPosition[0] = ReadPackFloat(data);
	startPosition[1] = ReadPackFloat(data);
	startPosition[2] = ReadPackFloat(data);
	float Ionrange = ReadPackFloat(data);
	float Iondamage = ReadPackFloat(data);
	int client = EntRefToEntIndex(ReadPackCell(data));
	
	if (!IsValidEntity(client))
	{
		return Plugin_Stop;
	}
				
	Explode_Logic_Custom(Iondamage, client, client, -1, startPosition, Ionrange , _ , _ , true);
	
	TE_SetupExplosion(startPosition, gExplosive1, 10.0, 1, 0, 0, 0);
	TE_SendToAll();
			
	position[0] = startPosition[0];
	position[1] = startPosition[1];
	position[2] += startPosition[2] + 900.0;
	startPosition[2] += -200;
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.75, 15.0, 1.0, 0, 0.75, {1, 175, 255, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.45, 25.0, 1.0, 0, 0.45, {1, 175, 255, 255}, 3);
	TE_SendToAll();
	TE_SetupBeamPoints(startPosition, position, gLaser1, 0, 0, 0, 0.3, 40.0, 1.0, 0, 0.3, {1, 175, 255, 255}, 3);
	TE_SendToAll();
	
	position[2] = startPosition[2] + 50.0;
	EmitSoundToAll("ambient/explosions/explode_9.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, startPosition);
	return Plugin_Continue;
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	Adiantum npc = view_as<Adiantum>(victim);

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
	Adiantum npc = view_as<Adiantum>(entity);

	Ruina_NPCDeath_Override(entity);
	
	Adiantum_Destroy_Wings(entity);
	npc.PlayDeathSound();
		
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
}




	
	