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
static char g_MeleeHitSounds[][] = {
	"weapons/halloween_boss/knight_axe_hit.wav",
};


static char gLaser1;
static char gExplosive1;

public void Adiantum_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_DeathSounds));	i++) { PrecacheSound(g_DeathSounds[i]);	}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	
	gLaser1 = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	PrecacheSound("misc/halloween/gotohell.wav");
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
	
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayMeleeHitSound()");
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
	public Adiantum(int client, float vecPos[3], float vecAng[3], bool ally)
	{
		Adiantum npc = view_as<Adiantum>(CClotBody(vecPos, vecAng, "models/player/spy.mdl", "1.0", "13500", ally));
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		i_NpcInternalId[npc.index] = RUINA_ADIANTUM;
		
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;		
		
		npc.m_flNextMeleeAttack = 0.0;
		
		
		SDKHook(npc.index, SDKHook_OnTakeDamage, Adiantum_ClotDamaged);
		SDKHook(npc.index, SDKHook_Think, Adiantum_ClotThink);				
		
		
		
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
		
		Ruina_Set_Heirarchy(npc.index, 2);	//is a ranged npc
		Ruina_Set_Master_Heirarchy(npc.index, false, true, true, 10, 3);	//attracts ranged npc's, can have a maxiumum of 10 of them, priority 3
		
		Ruina_Master_Rally(npc.index, true);	//this npc is always rallying ranged npc's
		
		npc.m_flSpeed = 250.0;
		
		npc.m_flCharge_Duration = 0.0;
		npc.m_flCharge_delay = GetGameTime(npc.index) + 2.0;
		npc.StartPathing();
		

		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 15.0;
		return npc;
	}
	
	
}

//TODO 
//Rewrite
public void Adiantum_ClotThink(int iNPC)
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
		
			float vecTarget[3]; vecTarget = WorldSpaceCenter(PrimaryThreatIndex);
			
			float flDistanceToTarget = GetVectorDistance(vecTarget, WorldSpaceCenter(npc.index), true);
			
			Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex);	//handles movement
			
			
			
			if(npc.m_flNextRangedBarrage_Spam < GameTime)
			{
				bool buff_array[3];
				buff_array[0] = true;	//defense
				buff_array[1] = false;	//speed
				buff_array[2] = true;	//attack
				float buff_array_amt[3];
				buff_array_amt[0] = 0.2;	//20% dmg bonus
				buff_array_amt[1] = 1.25;	//going bellow 1.0 will reduce speed
				buff_array_amt[2] = 0.05;	//5% dmg resist
			
				Apply_Master_Buff(npc.index, buff_array, 250.0, 5.0, buff_array_amt);
				Adiantum_Summon_Ion_Barrage(npc.index, vecTarget);
				npc.m_flNextRangedBarrage_Spam = GameTime + 15.0;
			}
				
			
			if(flDistanceToTarget < 10000 || npc.m_flAttackHappenswillhappen)
			{
				//Look at target so we hit.
			//	npc.FaceTowards(vecTarget, 1000.0);
				
				//Can we attack right now?
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					//Play attack ani
					if (!npc.m_flAttackHappenswillhappen)
					{
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS");
						npc.m_flAttackHappens = GameTime+0.4;
						npc.m_flAttackHappens_bullshit = GameTime+0.54;
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
								if(!ShouldNpcDealBonusDamage(target))
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 75.0, DMG_CLUB, -1, _, vecHit);	//kill!
								}
								else
								{
									SDKHooks_TakeDamage(target, npc.index, npc.index, 350.0, DMG_CLUB, -1, _, vecHit);	//kill!
								}
							
								// Hit sound
								npc.PlayMeleeHitSound();
								
							} 
						}
						delete swingTrace;
						npc.m_flNextMeleeAttack = GameTime + 0.8;
						npc.m_flAttackHappenswillhappen = false;
					}
					else if (npc.m_flAttackHappens_bullshit < GetGameTime(npc.index) && npc.m_flAttackHappenswillhappen)
					{
						npc.m_flAttackHappenswillhappen = false;
						npc.m_flNextMeleeAttack = GameTime + 0.8;
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
	
	int particle_0 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);	//Root, from where all the stuff goes from
	
	
	int particle_1 = ParticleEffectAt({0.0,0.0,0.0}, "", 0.0);
	
	SetParent(particle_0, particle_1);
	
	
	//X axis- Left, Right	//this one im almost fully sure of
	//Y axis - Up down, for once
	//Z axis - Forward backwards.????????
	
	//ALL OF THESE ARE RELATIVE TO THE BACKPACK POINT THINGY, or well the viewmodel, but its easier to visualise if using the back
	//Left?
	
	int particle_2 = ParticleEffectAt({20.0, 10.5, 2.5}, "", 0.0);	//x,y,z	//Z axis IS NOT UP/DOWN, its forward and backwards. somehow
	int particle_2_1 = ParticleEffectAt({45.0, 35.0, -5.0}, "", 0.0);
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
	float current_loc[3]; current_loc=GetAbsOrigin(client);
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
		UserLoc = GetAbsOrigin(entity);
		
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
		WritePackCell(data, Range); // Range
		WritePackCell(data, Dmg); // Damge
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
	float Ionrange = ReadPackCell(data);
	float Iondamage = ReadPackCell(data);
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

public Action Adiantum_ClotDamaged(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
	Adiantum npc = view_as<Adiantum>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void Adiantum_NPCDeath(int entity)
{
	Adiantum npc = view_as<Adiantum>(entity);
	
	Adiantum_Destroy_Wings(entity);
	npc.PlayDeathSound();
	
	SDKUnhook(npc.index, SDKHook_OnTakeDamage, Adiantum_ClotDamaged);
	SDKUnhook(npc.index, SDKHook_Think, Adiantum_ClotThink);	
		
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




	
	