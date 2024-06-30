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
static char g_AngerSounds[][] = {	//todo: make it different!
	"vo/medic_cartgoingforwardoffense01.mp3",
	"vo/medic_cartgoingforwardoffense02.mp3",
	"vo/medic_cartgoingforwardoffense03.mp3",
	"vo/medic_cartgoingforwardoffense06.mp3",
	"vo/medic_cartgoingforwardoffense07.mp3",
	"vo/medic_cartgoingforwardoffense08.mp3",
};

void Lex_OnMapStart_NPC()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lex");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_lex");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "medic"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;			//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
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
	PrecacheSoundArray(g_AngerSounds);

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Lex(client, vecPos, vecAng, ally);
}

static float fl_npc_basespeed;


static int Fire_Beacon(CClotBody npc, float vecTarget[3], float Origin[3], float projectile_speed)
{
	Ruina_Projectiles Projectile;

	float GameTime = GetGameTime();

	Projectile.iNPC = npc.index;
	Projectile.Start_Loc = Origin;
	float Ang[3];
	MakeVectorFromPoints(Origin, vecTarget, Ang);
	GetVectorAngles(Ang, Ang);
	Projectile.Angles = Ang;
	Projectile.speed = projectile_speed;
	Projectile.Time = fl_ruina_battery_timer[npc.index] - GameTime;

	return Projectile.Launch_Projectile(Func_On_Proj_Touch);	
}

static void Func_On_Proj_Touch(int projectile, int other)
{
	//Do Jack Shit!
	/*
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}

	Ruina_Add_Mana_Sickness(owner, other, 0.0, 500);	//very heavy FLAT amount of mana sickness
		
	float ProjectileLoc[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	Explode_Logic_Custom(fl_ruina_Projectile_dmg[projectile] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[projectile] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[projectile]);

	Ruina_Remove_Projectile(projectile);*/
}

#define RUINA_LEX_LASER_BEACON_AMT 9
static int i_laser_beacons[MAXENTITIES][RUINA_LEX_LASER_BEACON_AMT];

static void Delete_Beacons(int iNPC)
{
	for(int i=0 ; i < RUINA_LEX_LASER_BEACON_AMT ; i++)
	{
		int entity = EntRefToEntIndex(i_laser_beacons[iNPC][i]);
		if(IsValidEntity(entity))
			RemoveEntity(entity);

		i_laser_beacons[iNPC][i] = INVALID_ENT_REFERENCE;
	}
}

methodmap Lex < CClotBody
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
	
	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
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
	
	
	public Lex(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Lex npc = view_as<Lex>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			nunhood						//Xms2013_Medic_Hood
			ramses regalia				//Hw2013_Ramses_Regalia
			lo-grav loafers				//Hw2013_Moon_Boots
			Der Wintermantel			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl"
			medical monarch				"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl"
		
		*/
		static const char Items[][] = {
			"models/workshop/player/items/medic/xms2013_medic_hood/xms2013_medic_hood.mdl",
			"models/workshop/player/items/medic/hw2013_ramses_regalia/hw2013_ramses_regalia.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl",
			"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl",
			"models/workshop/player/items/medic/dec23_puffed_practitioner/dec23_puffed_practitioner.mdl",						//Quantum Armour Aquired
			RUINA_CUSTOM_MODELS
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, skin);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5], _, skin);
		npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_W30_HAND_CREST);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		fl_npc_basespeed = 300.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
			

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		fl_ruina_battery_timeout[npc.index] = 0.0;

		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc		
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 15, 6);

		Delete_Beacons(npc.index);

		fl_multi_attack_delay[npc.index] = 0.0;

		npc.m_iState = 0;

		npc.Anger = false;
		
		return npc;
	}
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Lex npc = view_as<Lex>(iNPC);
	
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

	Ruina_Add_Battery(npc.index, 10.0);

	
	int PrimaryThreatIndex = npc.m_iTarget;	//when the npc first spawns this will obv be invalid, the core handles this.

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>3000.0)	//every 30 seconds.
	{
		Master_Apply_Shield_Buff(npc.index, 150.0, 0.1);	//90% shield
		fl_ruina_battery[npc.index] = 0.0;
		npc.m_flNextMeleeAttack = 0.0;		
	}
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
	
		if(flDistanceToTarget < 100000)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (75000))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					npc.m_bAllowBackWalking=true;
				}
				else
				{
					NPC_StopPathing(npc.index);
					npc.m_bPathing = false;
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				npc.m_bPathing = true;
				npc.m_bAllowBackWalking=false;
			}		
		}
		else
		{
			npc.StartPathing();
			npc.m_bPathing = true;
			npc.m_bAllowBackWalking=false;
		}

		if(npc.m_bAllowBackWalking)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
		}
		else
			npc.m_flSpeed = fl_npc_basespeed;

		if(fl_ruina_battery_timer[npc.index] > GameTime)
		{
			if(npc.m_iState > 0)
			{
				int Previous_Proj = EntRefToEntIndex(i_laser_beacons[iNPC][0]);
				for(int i=1 ; i < npc.m_iState ; i++)
				{
					int Proj = EntRefToEntIndex(i_laser_beacons[iNPC][i]);

					if(!IsValidEntity(Proj))
						continue;

					if(!IsValidEntity(Previous_Proj))
					{
						Previous_Proj = Proj;
						continue;
					}
					float Vec1[3], Vec2[3];
					GetEntPropVector(Proj, Prop_Data, "m_vecAbsOrigin", Vec1);
					GetEntPropVector(Previous_Proj, Prop_Data, "m_vecAbsOrigin", Vec2);

					if(GetVectorDistance(Vec1, Vec2, true) > 90000.0)
						TeleportEntity(Proj, NULL_VECTOR, NULL_VECTOR, {0.0,0.0,0.0});

					Ruina_Laser_Logic Laser;

					Laser.client = npc.index;
					Laser.Start_Point = Vec1;
					Laser.End_Point = Vec2;

					Laser.Radius = 5.0;
					Laser.Damage = 10.0;
					Laser.Bonus_Damage = 60.0;
					Laser.damagetype = DMG_PLASMA;

					Laser.Deal_Damage(On_LaserHit);

						
					Previous_Proj = Proj;
				}
			}
		}		

		//Target close enough to hit
		if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*17)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(npc.m_flNextMeleeAttack < GameTime)
				{
					if(fl_ruina_battery_timer[npc.index] > GameTime + 1.0)
					{
						if(npc.m_iState < RUINA_LEX_LASER_BEACON_AMT && fl_multi_attack_delay[npc.index] < GameTime)
						{
							fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;

							fl_multi_attack_delay[npc.index] = GameTime + 0.2;

							npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
							npc.PlayMeleeSound();

							float Min,Max;

							Min = (npc.Anger ? 800.0 : 400.0);
							Max = (npc.Anger ? 1200.0 : 800.0);

							float projectile_speed = GetRandomFloat(Min, Max);

							int RNG = GetRandomInt(0, 3);
							float fRNG = GetRandomFloat(0.1, 1.0);
							switch(RNG)
							{
								case 0:
								{
									for(int i=0 ; i < 3 ; i ++)
									{
										vecTarget[i]+=((RNG*250.0)*fRNG);
									}
								}
								case 1:
								{
									for(int i=0 ; i < 3 ; i ++)
									{
										vecTarget[i]-=((RNG*250.0)*fRNG);
									}
								}
								default:
								{
									PredictSubjectPositionForProjectiles(npc, Enemy_I_See, projectile_speed, _,vecTarget);
									RNG-=2;
									switch(RNG)
									{
										case 1:
										{
											for(int i=0 ; i < 3 ; i ++)
											{
												vecTarget[i]-=((RNG*250.0)*fRNG);
											}
										}
										case 2:
										{
											for(int i=0 ; i < 3 ; i ++)
											{
												vecTarget[i]+=((RNG*250.0)*fRNG);
											}
										}
										
									}
								}
							}

							float flPos[3], flAng[3]; // original
							GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

							int Proj = Fire_Beacon(npc, vecTarget, flPos, projectile_speed);

							i_laser_beacons[npc.index][npc.m_iState] = EntIndexToEntRef(Proj);

							CreateTimer(0.1, Lex_Slow_Projectiles, EntIndexToEntRef(Proj), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

							if(npc.m_iState > 0)
							{
								int Last_Proj = EntRefToEntIndex(i_laser_beacons[npc.index][npc.m_iState-1]);
								int color[3] = {255, 255, 255};
								int Laser = ConnectWithBeam(Proj, Last_Proj, color[0], color[1], color[2], 4.0, 4.0, 0.1, BEAM_COMBINE_BLACK);

								CreateTimer((fl_ruina_battery_timer[npc.index] - GameTime)-0.1, Timer_RemoveEntity, EntIndexToEntRef(Laser), TIMER_FLAG_NO_MAPCHANGE);
							}

							npc.m_iState++;
						}
					}
					else
					{
						npc.m_iState = 0;
						Delete_Beacons(npc.index);
						npc.m_flNextMeleeAttack = GameTime + 9.0;
					}
				}
				else
				{
					npc.m_iState = 0;
					fl_ruina_battery_timer[npc.index] = GameTime + 12.0;
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
static void On_LaserHit(int client, int target, int damagetype, float damage)
{
	Ruina_Add_Mana_Sickness(client, target, 0.01, 10);
}
static Action Lex_Slow_Projectiles(Handle Timer, int ref)
{
	int Proj = EntRefToEntIndex(ref);

	if(!IsValidEntity(Proj))
		return Plugin_Stop;

	float CurrentVel[3];
	GetEntPropVector(Proj, Prop_Data, "m_vecVelocity", CurrentVel);
	float Speed = FloatAbs(CurrentVel[0]) + FloatAbs(CurrentVel[1]) + FloatAbs(CurrentVel[2]);

	if(Speed > 10.0)	//slow the projectile until it reaches our desired speed, then nuke the timer!
	{
		for(int i=0 ; i < 3 ; i ++)
		{
			if(CurrentVel[i] > 10.0)
			{
				if(CurrentVel[i] > 100.0)
				{
					CurrentVel[i]*=0.95;
				}
				else
				{
					CurrentVel[i]-=10.0;
				}
			}
			else if(CurrentVel[i] < -10.0)
			{
				if(CurrentVel[i] < -100.0)
				{
					CurrentVel[i]*=0.95;
				}
				else
				{
					CurrentVel[i]+=10.0;
				}
			}
		}
		TeleportEntity(Proj, NULL_VECTOR, NULL_VECTOR, CurrentVel);
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Lex npc = view_as<Lex>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	int Health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	
	float Ratio = (float(Health)/float(MaxHealth));
	if(!npc.Anger && Ratio < 0.75) 
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Lex npc = view_as<Lex>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Delete_Beacons(npc.index);

	Ruina_NPCDeath_Override(npc.index);
		
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