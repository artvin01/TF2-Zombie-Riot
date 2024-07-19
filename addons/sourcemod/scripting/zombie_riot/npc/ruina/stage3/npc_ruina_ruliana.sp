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
static char g_AngerSounds[][] = {	
	"vo/medic_mvm_get_upgrade01.mp3",
	"vo/medic_mvm_get_upgrade02.mp3",
	"vo/medic_mvm_get_upgrade03.mp3"
};

void Ruliana_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ruliana");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_ruliana");
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

	PrecacheSoundArray(g_AngerSounds);

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return Ruliana(client, vecPos, vecAng, ally, data);
}

static float fl_npc_basespeed;

methodmap Ruliana < CClotBody
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

	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::Playnpc.AngerSound()");
		#endif
	}
	
	
	public Ruliana(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Ruliana npc = view_as<Ruliana>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.5", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			crone's dome 				"models/workshop/player/items/all_class/witchhat/witchhat_%s.mdl"
			lo-grav loafers				//Hw2013_Moon_Boots
			Der Wintermantel			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl"
			medical monarch				"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl"
		
		*/
		static const char Items[][] = {
			"models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			"models/workshop/player/items/medic/medic_wintercoat_s02/medic_wintercoat_s02.mdl",
			"models/workshop/player/items/medic/dec15_medic_winter_jacket2_emblem2/dec15_medic_winter_jacket2_emblem2.mdl",
			RUINA_CUSTOM_MODELS_2
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _, _, 0.75);
		//npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_REI_LAUNCHER);
		AcceptEntityInput(npc.m_iWearable5, "SetBodyGroup");
		
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

		bool lord = StrContains(data, "overlord") != -1;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc		

		if(lord)
		{
			Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);	
			Ruina_Set_Overlord(npc.index, true);

			if(!IsValidEntity(RaidBossActive))
			{
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime(npc.index) + 9000.0;
				RaidModeScaling = GetRandomFloat(25.0, 100.0);
				RaidAllowsBuildings = true;
			}
		}
		else
		{
			Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 10, 15);	
		}
		

		fl_multi_attack_delay[npc.index] = 0.0;

		npc.Anger = false;

		npc.m_flNextRangedBarrage_Spam = 0.0;	// GetGameTime(npc.index) + GetRandomFloat(7.5, 15.0);
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Ruliana npc = view_as<Ruliana>(iNPC);
	
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

	Ruina_Add_Battery(npc.index, 2.0);

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	if(fl_ruina_battery[npc.index]>1250.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 2.5;

		npc.m_iState = 0;
		npc.m_flNextMeleeAttack	= 0.0;

	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{	
		Master_Apply_Speed_Buff(npc.index, 150.0, 1.0, 1.12);
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
		
		if(npc.m_flNextRangedBarrage_Spam < GameTime)
		{
			npc.m_flNextRangedBarrage_Spam = GameTime + 10.0;	//retry in 10 seconds if we failed
			Ruliana_Barrage_Invoke(npc);
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
					if(fl_multi_attack_delay[npc.index] < GameTime)
					{
						int Amt = (npc.Anger ? 15 : 10);
						if(npc.m_iState >= Amt)
						{
							npc.m_iState = 0;
							npc.m_flNextMeleeAttack = GameTime + (npc.Anger ? 5.0 : 7.5);
						}
						else
						{
							npc.m_iState++;
						}
						
						fl_multi_attack_delay[npc.index] = GameTime + (npc.Anger ? 0.1 : 0.25);

						fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;

						npc.FaceTowards(vecTarget, 100000.0);
						npc.AddGesture("ACT_MP_ATTACK_STAND_PRIMARY");
						npc.PlayMeleeSound();

						float 	flPos[3], // original
								flAng[3]; // original
							
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

						float 	projectile_speed = 800.0,
								target_vec[3];

						PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, _,target_vec);

			
						int Proj = npc.FireParticleRocket(target_vec, (npc.Anger ? 125.0 : 50.0) , projectile_speed , (npc.Anger ? 150.0 : 75.0) , "raygun_projectile_blue", _, _, true, flPos);

						if(fl_ruina_battery_timer[npc.index] > GameTime && IsValidEntity(Proj))
						{
							float 	Homing_Power = 7.0,
									Homing_Lockon = 50.0;

							float Ang[3];
							MakeVectorFromPoints(Npc_Vec, target_vec, Ang);
							GetVectorAngles(Ang, Ang);

							Initiate_HomingProjectile(Proj,
							npc.index,
							Homing_Lockon,			// float lockonAngleMax,
							Homing_Power,			// float homingaSec,
							true,					// bool LockOnlyOnce,
							true,					// bool changeAngles,
							Ang);
						}
					}
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
#define RULIANA_MAX_BARRAGE_SIZE 15
static void Ruliana_Barrage_Invoke(Ruliana npc)
{
	float GameTime = GetGameTime(npc.index);

	int valid_targets[RULIANA_MAX_BARRAGE_SIZE];
	int targets_aquired = 0;

	int minimum_targets = 4;

	int Team = GetTeam(npc.index);

	for(int client = 1; client <= MaxClients; client++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;
		
		if(view_as<CClotBody>(client).m_bThisEntityIgnored)
			continue;
		
		if(!IsClientInGame(client))
		 	continue;	

		if(!IsEntityAlive(client))
			continue;
		
		if(GetTeam(client) == Team)
			continue;

		if(IsLineOfSight(npc, client))
		{
			valid_targets[targets_aquired] = client;
			targets_aquired++;
			int color[4];
			Ruina_Color(color);
			int laser;
			laser = ConnectWithBeam(npc.index, client, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK);
			CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;

		int entity = EntRefToEntIndex(i_ObjectsNpcsTotal[a]);
		if(entity != INVALID_ENT_REFERENCE && !view_as<CClotBody>(entity).m_bThisEntityIgnored && !b_NpcIsInvulnerable[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity] && IsEntityAlive(entity))
		{
			if(GetTeam(entity) == Team)
				continue;

			if(IsLineOfSight(npc, entity))
			{
				valid_targets[targets_aquired] = entity;
				targets_aquired++;
				int color[4];
				Ruina_Color(color);
				int laser;
				laser = ConnectWithBeam(npc.index, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK);
				CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	for(int a; a < i_MaxcountBuilding; a++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;

		int entity = EntRefToEntIndex(i_ObjectsBuilding[a]);
		if(entity != INVALID_ENT_REFERENCE)
		{
			if(!b_ThisEntityIgnored[entity] && !b_ThisEntityIgnoredByOtherNpcsAggro[entity])
			{
				if(IsLineOfSight(npc, entity))
				{
					valid_targets[targets_aquired] = entity;
					targets_aquired++;
					int color[4];
					Ruina_Color(color);
					int laser;
					laser = ConnectWithBeam(npc.index, entity, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLACK);
					CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}

	if(targets_aquired < minimum_targets)	//we didn't get enough targets, abort abort abort
		return;

	npc.m_flNextRangedBarrage_Spam = GameTime + 30.0*(targets_aquired/RULIANA_MAX_BARRAGE_SIZE);	//we got proper targets, set the cooldown.

	float Npc_Vec[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", Npc_Vec);

	for(int i=0 ; i < targets_aquired ; i++)
	{
		int Target = valid_targets[i];

		float vecTarget[3];
		GetEntPropVector(Target, Prop_Data, "m_vecAbsOrigin", vecTarget);

		Ruina_Projectiles Projectile;

		Projectile.iNPC = npc.index;
		Projectile.Start_Loc = Npc_Vec;
		float Ang[3];
		MakeVectorFromPoints(Npc_Vec, vecTarget, Ang);
		GetVectorAngles(Ang, Ang);
		Projectile.Angles = Ang;
		Projectile.speed = 600.0;
		Projectile.radius = 300.0;
		Projectile.damage = 450.0;
		Projectile.bonus_dmg = 2.5;
		Projectile.Time = 10.0;

		int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);	

		if(IsValidEntity(Proj))
		{
			Projectile.Apply_Particle("raygun_projectile_blue");
			Projectile.Size = 2.0;
			int ModelApply = Projectile.Apply_Model(RUINA_CUSTOM_MODELS_1);
			if(IsValidEntity(ModelApply))
			{
				float angles[3];
				GetEntPropVector(ModelApply, Prop_Data, "m_angRotation", angles);
				angles[1]+=90.0;
				TeleportEntity(ModelApply, NULL_VECTOR, angles, NULL_VECTOR);
				SetVariantInt(RUINA_ICBM);
				AcceptEntityInput(ModelApply, "SetBodyGroup");
			}

			float 	Homing_Power = 15.0,
					Homing_Lockon = 90.0;

			Initiate_HomingProjectile(Proj,
			npc.index,
			Homing_Lockon,			// float lockonAngleMax,
			Homing_Power,			// float homingaSec,
			true,					// bool LockOnlyOnce,
			true,					// bool changeAngles,
			Ang,
			Target);
		}
	}
}

static bool IsLineOfSight(Ruliana npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	GetEntPropVector(Target, Prop_Data, "m_vecOrigin", Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", angle);


	// need the yaw offset from the player's POV, and set it up to be between (-180.0..180.0]
	float yawOffset = fixAngle(angle[1]) - fixAngle(eyeAngles[1]);
	if (yawOffset <= -180.0)
		yawOffset += 360.0;
	else if (yawOffset > 180.0)
		yawOffset -= 360.0;

	float MaxYaw = 60.0;
	float MinYaw = -60.0;
		
	// now it's a simple check
	if ((yawOffset >= MinYaw && yawOffset <= MaxYaw))	//first check position before doing a trace checking line of sight.
	{
		return Can_I_See_Enemy_Only(npc.index, Target);
	}
	return false;
}
static void Func_On_Proj_Touch(int projectile, int other)
{
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");

	Ruina_Add_Mana_Sickness(owner, other, 0.0, 100);	//very heavy FLAT amount of mana sickness
		
	float ProjectileLoc[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	Explode_Logic_Custom(fl_ruina_Projectile_dmg[projectile] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[projectile] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[projectile]);

	Ruina_Remove_Projectile(projectile);
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Ruliana npc = view_as<Ruliana>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
	//Ruina_Add_Battery(npc.index, damage);	//turn damage taken into energy

	int Health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	
	float Ratio = (float(Health)/float(MaxHealth));

	if(!npc.Anger && Ratio < 0.5) 
	{
		npc.Anger = true; //	>:(
		npc.PlayAngerSound();

		if(npc.m_bThisNpcIsABoss)
		{
			npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
		}
	}
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Ruliana npc = view_as<Ruliana>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(EntRefToEntIndex(i_Ruina_Ovelord_Ref)==npc.index)
		i_Ruina_Ovelord_Ref = INVALID_ENT_REFERENCE;

	if(npc.index==EntRefToEntIndex(RaidBossActive))
		RaidBossActive=INVALID_ENT_REFERENCE;

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
}