#pragma semicolon 1
#pragma newdecls required



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
static const char g_PrimaryFireSounds[][] = {
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};

static const char g_MeleeMissSounds[][] = {
	"weapons/bat_draw_swoosh1.wav",
	"weapons/bat_draw_swoosh2.wav",
};
static char g_TeleportSounds[][] = {
	"weapons/bison_main_shot.wav"
};
static char g_AngerSounds[][] = {	
	"vo/medic_mvm_get_upgrade01.mp3",
	"vo/medic_mvm_get_upgrade02.mp3",
	"vo/medic_mvm_get_upgrade03.mp3"
};
static char g_AngerSounds2[][] = {	
	"hl1/fvox/blood_loss.wav",
	"hl1/fvox/evacuate_area.wav",
	"hl1/fvox/health_critical.wav",
	"hl1/fvox/health_dropping.wav",
	"hl1/fvox/health_dropping2.wav",
	"hl1/fvox/innsuficient_medical.wav",
};
static bool b_angered_once[MAXENTITIES];

void Ruliana_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Ruliana");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_ruliana");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "ruliana"); 						//leaderboard_class_(insert the name)
	data.IconCustom = true;												//download needed?
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;			//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DefaultMedic_DeathSounds);
	PrecacheSoundArray(g_DefaultMedic_HurtSounds);
	PrecacheSoundArray(g_IdleSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_PrimaryFireSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_TeleportSounds);

	PrecacheSoundArray(g_AngerSounds);
	PrecacheSoundArray(g_AngerSounds2);

	PrecacheSound("hl1/fvox/morphine_shot.wav", true);

	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Ruliana(vecPos, vecAng, team, data);
}

static float fl_npc_basespeed;

methodmap Ruliana < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_DefaultMedic_HurtSounds[GetRandomInt(0, sizeof(g_DefaultMedic_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DefaultMedic_DeathSounds[GetRandomInt(0, sizeof(g_DefaultMedic_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	
	public void PlayPrimaryFireSound() {
		EmitSoundToAll(g_PrimaryFireSounds[GetRandomInt(0, sizeof(g_PrimaryFireSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}

	public void PlayAngerSound() {
	
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, RUINA_NPC_PITCH);

		EmitSoundToAll(g_AngerSounds2[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitSoundToAll(g_AngerSounds2[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);

		EmitSoundToAll("hl1/fvox/morphine_shot.wav", _, _, SNDLEVEL_ROCKET);	//EXTREME MORPHINE ADMINISTERED
		EmitSoundToAll("hl1/fvox/morphine_shot.wav", _, _, SNDLEVEL_ROCKET);	//EXTREME MORPHINE ADMINISTERED
		EmitSoundToAll("hl1/fvox/morphine_shot.wav", _, _, SNDLEVEL_ROCKET);	//EXTREME MORPHINE ADMINISTERED
		EmitSoundToAll("hl1/fvox/morphine_shot.wav", _, _, SNDLEVEL_ROCKET);	//EXTREME MORPHINE ADMINISTERED
		
	}

	public void Ion_On_Loc(float Predicted_Pos[3], float Radius, float dmg, float Time)
	{
		int color[4]; 
		Ruina_Color(color);

		float Thickness = 6.0;
		TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.1, color, 1, 0);
		TE_SendToAll();

		Ruina_IonSoundInvoke(Predicted_Pos);

		DataPack pack;
		CreateDataTimer(Time, Ruina_Generic_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
		pack.WriteCell(EntIndexToEntRef(this.index));
		pack.WriteFloatArray(Predicted_Pos, sizeof(Predicted_Pos));
		pack.WriteCellArray(color, sizeof(color));
		pack.WriteFloat(Radius);
		pack.WriteFloat(dmg);
		pack.WriteFloat(0.25);			//Sickness %
		pack.WriteCell(100);			//Sickness flat
		pack.WriteCell(this.Anger);		//Override sickness timeout

		float Sky_Loc[3]; Sky_Loc = Predicted_Pos; Sky_Loc[2]+=500.0; Predicted_Pos[2]-=100.0;

		int laser;
		laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, Predicted_Pos, Sky_Loc);

		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
		int loop_for = 5;
		float Add_Height = 500.0/loop_for;
		for(int i=0 ; i < loop_for ; i++)
		{
			Predicted_Pos[2]+=Add_Height;
			TE_SetupBeamRingPoint(Predicted_Pos, (Radius*2.0)/(i+1), 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
			TE_SendToAll();
		}
		
	}
	
	//npc.AdjustWalkCycle();
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE");
				this.m_iChanged_WalkCycle = 1;
			}
		}
		else
		{
			if(this.m_iChanged_WalkCycle == 1)
			{
				this.SetActivity("ACT_MP_JUMP_FLOAT_MELEE");
				this.m_iChanged_WalkCycle = 0;
			}
		}
	}
	
	public Ruliana(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Ruliana npc = view_as<Ruliana>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iChanged_WalkCycle = 1;
		
		/*
			crone's dome 				"models/workshop/player/items/all_class/witchhat/witchhat_%s.mdl"
			lo-grav loafers				//Hw2013_Moon_Boots
			berliners
			hazardous					"models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl"
		
		*/
		static const char Items[][] = {
			"models/workshop/player/items/all_class/witchhat/witchhat_medic.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			WINGS_MODELS_1,
			"models/workshop/player/items/medic/sum24_hazardous_vest/sum24_hazardous_vest.mdl",
			RUINA_CUSTOM_MODELS_2,
			"models/player/items/medic/berliners_bucket_helm.mdl"
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2]);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4]);
		npc.m_iWearable6 = npc.EquipItem("head", Items[5], _, skin);

		SetVariantInt(RUINA_REI_LAUNCHER);
		AcceptEntityInput(npc.m_iWearable5, "SetBodyGroup");
		SetVariantInt(WINGS_RULIANA);
		AcceptEntityInput(npc.m_iWearable3, "SetBodyGroup");

		b_angered_once[npc.index] = false;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);
		
		//speed is low since otherwise allied npc's can't keep up with her.
		fl_npc_basespeed = 250.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
			
		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");			
				
		fl_ruina_battery_max[npc.index] = 3500.0;
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		fl_ruina_battery_timeout[npc.index] = 0.0;

		npc.m_flMeleeArmor = 1.25;

		bool lord = StrContains(data, "overlord") != -1;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc		

		if(lord)
		{
			Ruina_Set_Master_Heirarchy(npc.index, RUINA_GLOBAL_NPC, true, 999, 999);	
			Ruina_Set_Overlord(npc.index, true);

			if(!IsValidEntity(RaidBossActive))
			{
				RemoveSpecificBuff(npc.index, "Ruina Battery Charge");
				RaidBossActive = EntIndexToEntRef(npc.index);
				RaidModeTime = GetGameTime(npc.index) + 9000.0;
				RaidModeScaling = 8008.5;
				RaidAllowsBuildings = true;
			}
		}
		else
		{
			Ruina_Set_Master_Heirarchy(npc.index, RUINA_RANGED_NPC, true, 10, 15);	
		}
		

		fl_multi_attack_delay[npc.index] = 0.0;

		npc.m_flDoingAnimation = 0.0;
		npc.m_flNextTeleport = GetGameTime() + 1.0;

		npc.Anger = false;
		npc.m_flNextRangedBarrage_Singular = GetGameTime(npc.index) + 15.0;
		npc.m_flNextRangedBarrage_Spam = GetGameTime(npc.index) + 2.5;	// GetGameTime(npc.index) + GetRandomFloat(7.5, 15.0);
		
		return npc;
	}
	
	
}


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

	npc.AdjustWalkCycle();
	
	npc.m_flNextThinkTime = GameTime + 0.1;

	float Gain = (npc.Anger ? 15.0 : 10.0);
	float Battery_Cost = fl_ruina_battery_max[npc.index];
	float battery_Ratio = (fl_ruina_battery[npc.index]/Battery_Cost);

	if(fl_ruina_battery_timeout[npc.index] < GameTime)
	{
		if(fl_ruina_battery[npc.index] < Battery_Cost)	//allow overbattery gain, but only if its from outside sources!
		{
			Ruina_Add_Battery(npc.index, Gain);
			if(fl_ruina_battery[npc.index] >= Battery_Cost)	//I like round numbers.
				fl_ruina_battery[npc.index] = Battery_Cost;
		}
			
	}
		

	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + 1.0;
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting

	
		
	if(npc.index==EntRefToEntIndex(RaidBossActive))
	{
		
		RaidModeScaling = battery_Ratio;

		int Health 		= GetEntProp(npc.index, Prop_Data, "m_iHealth"),
		MaxHealth 	= ReturnEntityMaxHealth(npc.index);
	
		float Ratio = (float(Health)/float(MaxHealth));

		if(Ratio < 0.4)
		{
			Ruina_Master_Rally(npc.index, true);

			if(npc.m_flDoingAnimation < GameTime)
			{
				npc.m_flDoingAnimation = GameTime + 1.0;

				Master_Apply_Defense_Buff(npc.index, 325.0, 5.0, 0.9);	//10% dmg resist
			}
		}
		else
			Ruina_Master_Rally(npc.index, false);
			
		if(Ratio < 0.35)
			SacrificeAllies(npc.index);	//if low enough hp, she will absorb the hp of nearby allies to heal herself

	}

	if(npc.IsOnGround())
		Retreat(npc);
	
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);


		if(flDistanceToTarget < 120000)
		{
			int Enemy_I_See;
				
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (85000))
				{
					Ruina_Runaway_Logic(npc.index, PrimaryThreatIndex);
					npc.m_bAllowBackWalking=true;
				}
				else
				{
					npc.StopPathing();
					
					npc.m_bAllowBackWalking=false;
				}
			}
			else
			{
				npc.StartPathing();
				
				npc.m_bAllowBackWalking=false;
			}		
		}
		else
		{
			npc.StartPathing();
			
			npc.m_bAllowBackWalking=false;
		}

		if(npc.m_bAllowBackWalking)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;	
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
		}
		else
			npc.m_flSpeed = fl_npc_basespeed;
		
		if(fl_ruina_battery[npc.index]>=Battery_Cost && fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			fl_ruina_battery_timeout[npc.index] = GameTime + 5.0;
			Ruliana_Barrage_Invoke(npc, Battery_Cost);
		}
		else if(fl_ruina_battery[npc.index]<=Battery_Cost)
		{
			npc.m_flNextRangedBarrage_Singular = GameTime + 15.0; 
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
							npc.m_flNextMeleeAttack = GameTime + (npc.Anger ? 2.5 : 5.0);
						}
						else
						{
							npc.m_iState++;
						}
						
						fl_multi_attack_delay[npc.index] = GameTime + (npc.Anger ? 0.1 : 0.25);

						fl_ruina_in_combat_timer[npc.index]=GameTime+5.0;

						npc.FaceTowards(vecTarget, 100000.0);
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayPrimaryFireSound();

						float 	flPos[3], // original
								flAng[3]; // original
							
						GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

						float 	projectile_speed = 800.0,
								target_vec[3];

						PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, _,target_vec);

			
						int Proj = npc.FireParticleRocket(target_vec, (npc.Anger ? 125.0 : 50.0) , projectile_speed , (npc.Anger ? 150.0 : 75.0) , "raygun_projectile_blue", _, _, true, flPos);

						if(battery_Ratio > 0.5 && IsValidEntity(Proj) && !LastMann)
						{
							float Homing_Power = (npc.Anger ? 7.0 : 5.0);
							float Homing_Lockon = (npc.Anger ? 50.0 : 30.0);

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
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}
static int i_targets_inrange;
static bool Retreat(Ruliana npc, bool custom = false)
{
	float GameTime = GetGameTime(npc.index);
	float Radius = 320.0;	//if too many people are next to her, she just teleports in a direction to escape.
	
	if(npc.m_flNextTeleport > GameTime && !custom)	//internal teleportation device is still recharging...
		return false;

	if(!custom)
		npc.m_flNextTeleport = GameTime + 1.0;

	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	i_targets_inrange = 0;
	Explode_Logic_Custom(0.0, npc.index, npc.index, -1, VecSelfNpc, Radius, _, _, true, 15, false, _, CountTargets);

	if(i_targets_inrange < 4 && !custom)	//not worth "retreating"
		return false;

	//OH SHIT OH FUCK, WERE BEING OVERRUN, TIME TO GET THE FUCK OUTTA HERE

	float Angles[3];
	int loop_for = 8;
	float Ang_Adjust = 360.0/loop_for;
	
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", Angles);
	Angles[0] =0.0;
	Angles[1]+=180.0;	//she prefers teleporting backwards first
	Angles[2] =0.0;

	bool success = false;

	
	switch(GetRandomInt(0, 1))
	{
		case 1:
			Ang_Adjust*=-1.0;
	}
	//float Final_Vec[3];
	for(int i=0 ; i < loop_for ; i++)
	{
		float Test_Vec[3];
		if(Directional_Trace(npc, VecSelfNpc, Angles, Test_Vec))
		{
			if(NPC_Teleport(npc.index, Test_Vec))
			{
				//TE_SetupBeamPoints(VecSelfNpc, Test_Vec, g_Ruina_BEAM_Laser, 0, 0, 0, 5.0, 15.0, 15.0, 0, 0.1, {255, 255, 255,255}, 3);
				//TE_SendToAll();
				//Final_Vec = Test_Vec;
				success = true;
				break;
			}
		}
		Angles[1]+=Ang_Adjust;
	}
	if(!success)
		return false;
	
	if(!custom)
		npc.m_flNextTeleport = GameTime + (npc.Anger ? 15.0 : 30.0);
	
	//YAY IT WORKED!!!!!!!

	npc.PlayTeleportSound();

	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
			
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		npc.FaceTowards(vecTarget, 30000.0);
	}
	else
	{
		npc.FaceTowards(VecSelfNpc, 30000.0);
	}

	float start_offset[3], end_offset[3];
	start_offset = VecSelfNpc;

	float effect_duration = 0.25;
	
	WorldSpaceCenter(npc.index, end_offset);
					
	for(int help=1 ; help<=8 ; help++)
	{	
		Lanius_Teleport_Effect(RUINA_BALL_PARTICLE_BLUE, effect_duration, start_offset, end_offset);
						
		start_offset[2] += 12.5;
		end_offset[2] += 12.5;
	}

	if(custom)
		return true;

	float radius = (npc.Anger ? 325.0 : 250.0);
	float dmg = (npc.Anger ? 1200.0 : 600.0);
	float Time = (npc.Anger ? 1.25 : 1.5);
	npc.Ion_On_Loc(VecSelfNpc, radius, dmg, Time);


	return true;
}
static bool Directional_Trace(Ruliana npc, float Origin[3], float Angle[3], float Result[3])
{
	Ruina_Laser_Logic Laser;

	float Distance = 750.0;
	Laser.client = npc.index;
	Laser.DoForwardTrace_Custom(Angle, Origin, Distance);
	float Dist = GetVectorDistance(Origin, Laser.End_Point);

	//TE_SetupBeamPoints(Origin, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {255, 255, 255,255}, 3);
	//TE_SendToAll();

	//the distance it too short, try a new angle
	if(Dist < 500.0)
		return false;

	Result = Laser.End_Point;
	ConformLineDistance(Result, Origin, Result, Dist - 100.0);	//need to add a bit of extra room to make sure its a valid teleport location. otherwise she might materialize into a wall
	Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Result);	//now get the vector but on the floor.
	float Ang[3];
	MakeVectorFromPoints(Origin, Result, Ang);
	GetVectorAngles(Ang, Ang);

	//TE_SetupBeamPoints(Origin, Result, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {255, 0, 0, 255}, 3);
	//TE_SendToAll();

	float Sub_Dist = GetVectorDistance(Origin, Result);

	Laser.DoForwardTrace_Custom(Ang, Origin, Sub_Dist);	//check if we can see that vector
	//TE_SetupBeamPoints(Origin, Laser.End_Point, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {0, 0, 255, 255}, 3);
	//TE_SendToAll();
	if(Similar_Vec(Result, Laser.End_Point))			//then check if its similar to the one that was traced via a ground clip
	{
		float sky[3]; sky = Result; sky[2]+=500.0;
		//TE_SetupBeamPoints(sky, Result, g_Ruina_BEAM_Laser, 0, 0, 0, 1.0, 15.0, 15.0, 0, 0.1, {0, 255, 0, 255}, 3);
		//TE_SendToAll();
		Result = Laser.End_Point;
		return true;
	}
	return false;
}
static void CountTargets(int entity, int victim, float damage, int weapon)
{
	i_targets_inrange++;
}
#define RULIANA_MAX_BARRAGE_SIZE 15
static void Ruliana_Barrage_Invoke(Ruliana npc, float Cost)
{
	int valid_targets[RULIANA_MAX_BARRAGE_SIZE];
	int targets_aquired = 0;

	int minimum_targets = 4;

	float GameTime = GetGameTime(npc.index);

	bool FIREEVERYTHING = false;
	if(npc.m_flNextRangedBarrage_Singular < GameTime && !LastMann)
	{
		minimum_targets = 1;
		FIREEVERYTHING = true;	//OBLITERATE THEM
	}
		

	for(int client = 1; client <= MaxClients; client++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;
		
		if(!IsValidEnemy(npc.index, client))
			continue;

		int target = IsLineOfSight(npc, client);

		if(IsValidEnemy(npc.index, target))
		{
			//CPrintToChatAll("1 valid target: %i", target);
			valid_targets[targets_aquired] = target;
			targets_aquired++;
			
		}
	}
	for(int a; a < i_MaxcountNpcTotal; a++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;

		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[a]);

		if(!IsValidEnemy(npc.index, entity))
			continue;

		int target = IsLineOfSight(npc, entity);

		if(IsValidEnemy(npc.index, target))
		{
			//CPrintToChatAll("2 valid target: %i", target);
			valid_targets[targets_aquired] = target;
			targets_aquired++;
		}
	}

	for(int a; a < i_MaxcountBuilding; a++)
	{
		if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)
			break;

		int entity = EntRefToEntIndexFast(i_ObjectsBuilding[a]);
		if(!IsValidEnemy(npc.index, entity))
			continue;

		int target = IsLineOfSight(npc, entity);

		if(IsValidEnemy(npc.index, target))
		{
			//CPrintToChatAll("3 valid target: %i", target);
			valid_targets[targets_aquired] = target;
			targets_aquired++;
		}
	}

	if(targets_aquired < minimum_targets)	//we didn't get enough targets, abort abort abort
		return;

	if(FIREEVERYTHING)
	{
		int previous_target = valid_targets[0];
		for(int i=1 ; i < RULIANA_MAX_BARRAGE_SIZE ; i++)
		{
			int Target = valid_targets[i];
			if(!IsValidEnemy(npc.index, Target))
				valid_targets[i] = previous_target;
			else
				previous_target = Target;

		}
		targets_aquired = (RULIANA_MAX_BARRAGE_SIZE-1);
	}

	if(npc.m_flNextRangedBarrage_Singular < GameTime)
		npc.m_flNextRangedBarrage_Singular = GameTime + 10.0;

	if(targets_aquired >= RULIANA_MAX_BARRAGE_SIZE)	///somehow we have more then 15 targets?
		targets_aquired = (RULIANA_MAX_BARRAGE_SIZE-1);

	float Base_Recharge = Cost;
	float Modify_Charge = Base_Recharge*(float(targets_aquired)/float(RULIANA_MAX_BARRAGE_SIZE));

	fl_ruina_battery[npc.index]-=Modify_Charge;

	//CPrintToChatAll("Cost: %f", Modify_Charge);
	//CPrintToChatAll("Amt: %i", targets_aquired);

	float Npc_Vec[3];
	WorldSpaceCenter(npc.index, Npc_Vec);

	for(int i=0 ; i < targets_aquired ; i++)
	{
		int Target = valid_targets[i];

		int color[4];
		Ruina_Color(color);
		int laser;
		laser = ConnectWithBeam(npc.index, Target, color[0], color[1], color[2], 2.5, 2.5, 0.25, BEAM_COMBINE_BLUE);
		CreateTimer(0.1, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);

		float vecTarget[3];
		WorldSpaceCenter(Target, vecTarget);

		Ruina_Projectiles Projectile;

		Projectile.iNPC = npc.index;
		Projectile.Start_Loc = Npc_Vec;
		float Ang[3];
		MakeVectorFromPoints(Npc_Vec, vecTarget, Ang);
		GetVectorAngles(Ang, Ang);
		Projectile.Angles = Ang;
		Projectile.speed = (npc.Anger ? 750.0 : 600.0);
		Projectile.radius = 100.0;
		Projectile.damage = (npc.Anger ? 600.0 : 450.0);
		Projectile.bonus_dmg = 2.5;
		Projectile.Time = 10.0;

		int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);	

		if(IsValidEntity(Proj))
		{
			Projectile.Apply_Particle("raygun_projectile_blue");
			Projectile.Size = 1.0;
			int ModelApply = Projectile.Apply_Model(RUINA_CUSTOM_MODELS_1);
			if(IsValidEntity(ModelApply))
			{
				SetVariantInt(RUINA_ICBM);
				AcceptEntityInput(ModelApply, "SetBodyGroup");
			}
			
			if(FIREEVERYTHING)
				continue;

			float 	Homing_Power = 5.0,
					Homing_Lockon = 45.0;

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

static int IsLineOfSight(Ruliana npc, int Target)
{
	// need position of either the inflictor or the attacker
	float Vic_Pos[3];
	WorldSpaceCenter(Target, Vic_Pos);
	float npc_pos[3];
	float angle[3];
	float eyeAngles[3];
	WorldSpaceCenter(npc.index, npc_pos);
	
	GetVectorAnglesTwoPoints(npc_pos, Vic_Pos, angle);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", eyeAngles);

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
		return Can_I_See_Enemy(npc.index, Target);
	}
	return 0;
}
static void Func_On_Proj_Touch(int projectile, int other)
{
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");

	Ruina_Add_Mana_Sickness(owner, other, 0.0, 100);	//very heavy FLAT amount of mana sickness
		
	float ProjectileLoc[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	Explode_Logic_Custom(fl_ruina_Projectile_dmg[projectile] , owner , owner , -1 , ProjectileLoc , fl_ruina_Projectile_radius[projectile] , _ , _ , true, _,_, fl_ruina_Projectile_bonus_dmg[projectile]);
	TE_Particle("spell_batball_impact_blue", ProjectileLoc, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
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
		MaxHealth 	= ReturnEntityMaxHealth(npc.index);
	
	float Ratio = (float(Health)/float(MaxHealth));

	if(Ratio < 0.5)
	{
		npc.Anger = true; //	>:(
		fl_npc_basespeed = 350.0;
		if(!b_angered_once[npc.index])
		{
			b_angered_once[npc.index] = true;
			npc.PlayAngerSound();
			
			if(npc.m_bThisNpcIsABoss)
			{
				npc.DispatchParticleEffect(npc.index, "hightower_explosion", NULL_VECTOR, NULL_VECTOR, NULL_VECTOR, npc.FindAttachment("eyes"), PATTACH_POINT_FOLLOW, true);
			}
		}
	}
	else
	{
		fl_npc_basespeed = 250.0;
		npc.Anger = false;
	}
	
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
		npc.m_flNextTeleport -=0.2;
	}
	
	return Plugin_Changed;
}
void SacrificeAllies(int npc)
{
	b_NpcIsTeamkiller[npc] = true;
	Explode_Logic_Custom(0.0, npc, npc, -1, _, 500.0, _, _, true, 99, false, _, FindAllies_Logic);
	b_NpcIsTeamkiller[npc] = false;
}

static void FindAllies_Logic(int entity, int victim, float damage, int weapon)
{
	if(entity==victim)
		return;

	if(GetTeam(entity) != GetTeam(victim))
		return;

	int Health 		= GetEntProp(victim, Prop_Data, "m_iHealth"),
		MaxHealth 	= ReturnEntityMaxHealth(victim);

	int ru_MaxHealth 	= ReturnEntityMaxHealth(entity);
	int ru_Health		= GetEntProp(entity, Prop_Data, "m_iHealth");

	float Ratio = (float(ru_Health)/float(ru_MaxHealth));
	if(Ratio > 0.5)
		return;


	float Healing_Amt = float(ru_MaxHealth)*0.1;
	float Healing_Amt2 = float(MaxHealth)*0.1;

	float TrueHealing = Healing_Amt2;

	if(TrueHealing > Healing_Amt)
		TrueHealing = Healing_Amt;

	if(Health > TrueHealing)
	{
		SetEntProp(entity, Prop_Data, "m_iHealth", ru_Health + RoundToFloor(TrueHealing));
		SDKHooks_TakeDamage(victim, 0, 0, TrueHealing, 0, 0, _, _, false, (ZR_DAMAGE_NOAPPLYBUFFS_OR_DEBUFFS|ZR_DAMAGE_NPC_REFLECT));

		int color[4];
		Ruina_Color(color);
		int laser;
		laser = ConnectWithBeam(entity, victim, color[0], color[1], color[2], 2.5, 2.5, 1.5, BEAM_COMBINE_BLUE);
		CreateTimer(0.25, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
	}

}
static void NPC_Death(int entity)
{
	Ruliana npc = view_as<Ruliana>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	if(EntRefToEntIndex(i_Ruina_Overlord_Ref)==npc.index)
	{
		i_Ruina_Overlord_Ref = INVALID_ENT_REFERENCE;
		//CPrintToChatAll("set invalid");
	}
		

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