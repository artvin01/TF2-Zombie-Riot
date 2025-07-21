#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/engineer_paincrticialdeath01.mp3",
	"vo/engineer_paincrticialdeath02.mp3",
	"vo/engineer_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/engineer_painsharp01.mp3",
	"vo/engineer_painsharp02.mp3",
	"vo/engineer_painsharp03.mp3",
	"vo/engineer_painsharp04.mp3",
	"vo/engineer_painsharp05.mp3",
	"vo/engineer_painsharp06.mp3",
	"vo/engineer_painsharp07.mp3",
	"vo/engineer_painsharp08.mp3",
};


static const char g_IdleAlertedSounds[][] = {
	"vo/engineer_battlecry01.mp3",
	"vo/engineer_battlecry03.mp3",
	"vo/engineer_battlecry04.mp3",
	"vo/engineer_battlecry05.mp3",
};
static char g_TeleportSounds[][] = {
	"misc/halloween/spell_stealth.wav",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};
static const char g_IdleSounds[][] = {
	"vo/engineer_standonthepoint01.mp3",
	"vo/engineer_standonthepoint02.mp3",
	"vo/engineer_standonthepoint03.mp3",
	"vo/engineer_standonthepoint04.mp3",
	"vo/engineer_standonthepoint05.mp3",
};

void Malianius_OnMapStart_NPC()
{

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Malianius");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_malianius");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "engineer"); 						//leaderboard_class_(insert the name)
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
	PrecacheSoundArray(g_TeleportSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheModel("models/player/engineer.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Malianius(vecPos, vecAng, team);
}

static float fl_npc_basespeed;

methodmap Malianius < CClotBody
{
	
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);
		

	}
	
	public void PlayTeleportSound() {
		EmitSoundToAll(g_TeleportSounds[GetRandomInt(0, sizeof(g_TeleportSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		

	}
	
	public void PlayIdleAlertSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
		
	}
	
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
		
	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, 0.5, RUINA_NPC_PITCH);
		

	}

	public Malianius(float vecPos[3], float vecAng[3], int ally)
	{
		Malianius npc = view_as<Malianius>(CClotBody(vecPos, vecAng, "models/player/engineer.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		/*
			Diplomat 			"models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl");
			Iron Lung			"models/workshop/player/items/engineer/hwn2015_iron_lung/hwn2015_iron_lung.mdl"
			Constructor's cover	"models/workshop/player/items/engineer/hwn2023_constructors_cover/hwn2023_constructors_cover.mdl"
			The Birdman of Australiacatraz "models/workshop/player/items/sniper/jul13_bushmans_blazer/jul13_bushmans_blazer.mdl"
			"Brain Interface" "models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl"
			"The Brotherhood of Arms"	"models/workshop/player/items/all_class/brotherhood_2/brotherhood_2_%s.mdl"
		*/
		static const char Items[][] = {
			"models/workshop/player/items/soldier/dec15_diplomat/dec15_diplomat.mdl",
			"models/workshop/player/items/engineer/hwn2015_iron_lung/hwn2015_iron_lung.mdl",
			"models/workshop/player/items/engineer/hwn2023_constructors_cover/hwn2023_constructors_cover.mdl",
			"models/workshop/player/items/sniper/jul13_bushmans_blazer/jul13_bushmans_blazer.mdl",
			"models/workshop/player/items/engineer/sum19_brain_interface/sum19_brain_interface.mdl",
			"models/workshop/player/items/all_class/brotherhood_2/brotherhood_2_engineer.mdl",
			RUINA_CUSTOM_MODELS_1
		};

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_iChanged_WalkCycle = 0;

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

		SetVariantInt(RUINA_STAFF_1);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 270.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery_max[npc.index] = 500.0;
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		npc.Anger = false;
		
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc
		Ruina_Set_Battery_Buffer(npc.index, true);

		return npc;
	}
	
	
}


static void ClotThink(int iNPC)
{
	Malianius npc = view_as<Malianius>(iNPC);
	
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

	Ruina_Add_Battery(npc.index, 2.5);

	
	int PrimaryThreatIndex = npc.m_iTarget;	//when the npc first spawns this will obv be invalid, the core handles this.

	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	
	float radius = 300.0;
	if(fl_ruina_battery[npc.index]>fl_ruina_battery_max[npc.index] && fl_ruina_battery_timer[npc.index] < GameTime)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 5.0;

		npc.AddActivityViaSequence("taunt_drg_melee");
		npc.SetCycle(0.01);
		npc.SetPlaybackRate(0.7);
		npc.m_bisWalking = false;

		i_NpcWeight[npc.index] = 999;

		npc.m_flSpeed = 0.0;

		Master_Apply_Defense_Buff(npc.index, 300.0, 5.0, 0.70);	//30% resistances

		npc.m_flRangedArmor = 0.25;
		npc.m_flMeleeArmor 	= 0.25;

		Fire_Random_Ion(npc);

		npc.Anger = false;

		npc.m_iChanged_WalkCycle = 1;
		
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{
		Master_Apply_Battery_Buff(npc.index, radius, 120.0);

		radius = GetRandomFloat(radius*0.9, radius*1.1); 
		TE_SetupBeamRingPoint(Npc_Vec, radius*2.0, radius*2.0+0.1, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, 0.1, 15.0, 0.5, {175, 25, 0, 255}, 1, 0);
		TE_SendToAll();

		if(fl_ruina_battery_timer[npc.index] < GameTime + 3.0 && !npc.Anger && fl_ruina_battery_timer[npc.index] > GameTime + 2.0)
		{
			npc.Anger = true;
			npc.SetPlaybackRate(0.0);
			npc.SetCycle(0.5);
		}
		else if(fl_ruina_battery_timer[npc.index] < GameTime + 1.0 && npc.Anger)
		{
			npc.Anger = false;
			npc.SetPlaybackRate(0.5);
		}	

		return;
	}
	else
	{

		Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting

		if(npc.m_iChanged_WalkCycle == 1)
		{
			npc.m_iChanged_WalkCycle = 0;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.m_bisWalking = true;

			i_NpcWeight[npc.index] = 1;
			npc.m_flSpeed = fl_npc_basespeed;
			npc.m_flRangedArmor = 1.0;
			npc.m_flMeleeArmor = 1.0;
		}
			
	}

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		int Anchor_Id=-1;
		Ruina_Independant_Long_Range_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime, Anchor_Id); //handles movement

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
			
		if(!IsValidEntity(Anchor_Id))
		{
			if(flDistanceToTarget < (750.0*750.0))
			{
				int Enemy_I_See;
				
				Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
				{
					if(flDistanceToTarget < (250.0*250.0))
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
		}
		else
		{
			npc.m_bAllowBackWalking=false;
		}

		if(npc.m_bAllowBackWalking)
		{
			npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENALTY;
			npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
		}	
		else
			npc.m_flSpeed = fl_npc_basespeed;

		Malianius_SelfDefense(npc, GameTime, Anchor_Id);
	}
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static void Fire_Random_Ion(Malianius npc)
{
	UnderTides npcGetInfo = view_as<UnderTides>(npc.index);
	int enemy_2[1];
	GetHighDefTargets(npcGetInfo, enemy_2, sizeof(enemy_2), true, false);
	for(int i; i < sizeof(enemy_2); i++)
	{
		if(enemy_2[i])
		{
			int color[4]; Ruina_Color(color);

			float Predicted_Pos[3],
			SubjectAbsVelocity[3],
			vecTarget[3];
			WorldSpaceCenter(enemy_2[i],vecTarget);

			GetEntPropVector(enemy_2[i], Prop_Data, "m_vecAbsVelocity", SubjectAbsVelocity);

			float Time = 4.0;

			ScaleVector(SubjectAbsVelocity, 1.0);
			AddVectors(vecTarget, SubjectAbsVelocity, Predicted_Pos);

			//Ruina_Proper_To_Groud_Clip({24.0,24.0,24.0}, 300.0, Predicted_Pos);

			float Radius = 175.0;

			float Thickness = 6.0;
			TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, 0.0, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.75, color, 1, 0);
			TE_SendToAll();
			TE_SetupBeamRingPoint(Predicted_Pos, Radius*2.0, Radius*2.0+0.5, g_Ruina_BEAM_Laser, g_Ruina_HALO_Laser, 0, 1, Time, Thickness, 0.1, color, 1, 0);
			TE_SendToAll();

			Ruina_IonSoundInvoke(Predicted_Pos);
			
			DataPack pack;
			CreateDataTimer(Time, Ruina_Generic_Ion, pack, TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(EntIndexToEntRef(npc.index));
			pack.WriteFloatArray(Predicted_Pos, sizeof(Predicted_Pos));
			pack.WriteCellArray(color, sizeof(color));
			pack.WriteFloat(Radius);		//radius
			pack.WriteFloat(250.0);			//dmg
			pack.WriteFloat(0.1);			//Sickness %
			pack.WriteCell(200);			//Sickness flat
			pack.WriteCell(true);			//Override sickness timeout

			if(!AtEdictLimit(EDICT_NPC))
			{
				float Sky_Loc[3]; Sky_Loc = Predicted_Pos; Sky_Loc[2]+=500.0; Predicted_Pos[2]-=100.0;

				int laser;
				laser = ConnectWithBeam(-1, -1, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK, Predicted_Pos, Sky_Loc);

				CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(laser), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}
static void Malianius_Effects_Attack(Malianius npc, float Target_Vec[3], int GetClosestEnemyToAttack, float flDistanceToTarget)
{
	int amt = 2;
	float Npc_Loc[3];
	WorldSpaceCenter(npc.index, Npc_Loc);
	float Ratio_Core = 180.0/(amt);

	Npc_Loc[2]+=50.0;

	float Ang[3];
	MakeVectorFromPoints(Npc_Loc, Target_Vec, Ang);
	GetVectorAngles(Ang, Ang);

	for(int i =1 ; i <= amt ; i++)
	{
		float Angle_Adj =  Ratio_Core*i+45.0-(Ratio_Core/2);

		if(i>amt/2)
		{
			Angle_Adj+=90.0;
		}	

		float tempAngles[3], Direction[3], endLoc[3];
		tempAngles[0] = Ang[0];
		tempAngles[1] = Ang[1];
		tempAngles[2] = Angle_Adj;	

		
		if(tempAngles[2]>360.0)
			tempAngles[2] -= 360.0;
	
					
		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, Direction);
		ScaleVector(Direction, 75.0);
		AddVectors(Npc_Loc, Direction, endLoc);
		
		float vecTarget[3];
		vecTarget = Target_Vec;
		float projectile_speed = 500.0;
		//lets pretend we have a projectile.
		if(flDistanceToTarget < 1250.0*1250.0)
			PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0, vecTarget);
		if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
		{
			WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
		}
		float DamageDone = 75.0;
		npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "raygun_projectile_red_crit", false, true, true, endLoc,_,_, 10.0);
	}
}

static void Malianius_SelfDefense(Malianius npc, float gameTime, int Anchor_Id)	//ty artvin
{
	int GetClosestEnemyToAttack;
	//Ranged units will behave differently.
	//Get the closest visible target via distance checks, not via pathing check.
	GetClosestEnemyToAttack = GetClosestTarget(npc.index,_,_,_,_,_,_,true,_,_,true);	//works with masters, slaves not so much. seems to work with independant npc's too
	if(!IsValidEnemy(npc.index,GetClosestEnemyToAttack))	//no target, what to do while idle
	{
		return;
	}
	float vecTarget[3]; WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
	if(flDistanceToTarget < (1000.0*1000.0))
	{	
		if(gameTime > npc.m_flNextRangedAttack)
		{
			fl_ruina_in_combat_timer[npc.index]=gameTime+5.0;
			npc.PlayRangedSound();
			//after we fire, we will have a short delay beteween the actual laser, and when it happens
			//This will predict as its relatively easy to dodge
			Malianius_Effects_Attack(npc, vecTarget, GetClosestEnemyToAttack, flDistanceToTarget);
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 7.0;
			npc.PlayRangedReloadSound();
		}
	}
	else
	{
		if(IsValidEntity(Anchor_Id))
		{

			CClotBody npc2 = view_as<CClotBody>(Anchor_Id);
			int	target = npc2.m_iTarget;

			if(IsValidEnemy(npc.index,target))
			{
				GetClosestEnemyToAttack = target;
				WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);

				fl_ruina_in_combat_timer[npc.index]=gameTime+5.0;

				flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);
				if(gameTime > npc.m_flNextRangedAttack)
				{
					npc.PlayRangedSound();
					//after we fire, we will have a short delay beteween the actual laser, and when it happens
					//This will predict as its relatively easy to dodge

					Malianius_Effects_Attack(npc, vecTarget, GetClosestEnemyToAttack, flDistanceToTarget);
					
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
					npc.PlayRangedReloadSound();
				}
			}
		}
	}
	npc.m_iTarget = GetClosestEnemyToAttack;
}

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Malianius npc = view_as<Malianius>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
		
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
	Malianius npc = view_as<Malianius>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
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