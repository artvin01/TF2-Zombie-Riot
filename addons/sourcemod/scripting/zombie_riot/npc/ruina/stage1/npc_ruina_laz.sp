#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/demoman_paincrticialdeath01.mp3",
	"vo/demoman_paincrticialdeath02.mp3",
	"vo/demoman_paincrticialdeath03.mp3",
	"vo/demoman_paincrticialdeath04.mp3",
	"vo/demoman_paincrticialdeath05.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/demoman_painsharp01.mp3",
	"vo/demoman_painsharp02.mp3",
	"vo/demoman_painsharp03.mp3",
	"vo/demoman_painsharp04.mp3",
	"vo/demoman_painsharp05.mp3",
	"vo/demoman_painsharp06.mp3",
	"vo/demoman_painsharp07.mp3",
};
static const char g_IdleAlertedSounds[][] = {
	"vo/demoman_battlecry01.mp3",
	"vo/demoman_battlecry02.mp3",
	"vo/demoman_battlecry03.mp3",
	"vo/demoman_battlecry04.mp3",
};
static const char g_MeleeAttackSounds[][] = {
	"weapons/physcannon/superphys_launch1.wav",
	"weapons/physcannon/superphys_launch2.wav",
	"weapons/physcannon/superphys_launch3.wav",
	"weapons/physcannon/superphys_launch4.wav",
};
static const char g_RangedReloadSound[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};

void Laz_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Laz");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_laz");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "demo"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheModel("models/player/demo.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Laz(client, vecPos, vecAng, ally);
}

methodmap Laz < CClotBody
{	
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

	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	public Laz(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Laz npc = view_as<Laz>(CClotBody(vecPos, vecAng, "models/player/demo.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_SECONDARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			Bozo's bouffant		"models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl"
			Last Breath			"models/workshop/player/items/pyro/pyro_halloween_gasmask/pyro_halloween_gasmask.mdl"
			Masked Loyalty		"models/workshop/player/items/pyro/dec23_masked_loyalty/dec23_masked_loyalty.mdl"
			Mighty Mitre		"models/workshop/player/items/medic/dec18_mighty_mitre/dec18_mighty_mitre.mdl"
			Nostrum Napalmer	"models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl"
			Wings of purity		"models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl"
		
		*/
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		npc.m_flSpeed = 250.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_haha_hairdo/hw2013_the_haha_hairdo.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/pyro_halloween_gasmask/pyro_halloween_gasmask.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec23_masked_loyalty/dec23_masked_loyalty.mdl");	
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/medic/dec18_mighty_mitre/dec18_mighty_mitre.mdl");	
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop_partner/weapons/c_models/c_ai_flamethrower/c_ai_flamethrower.mdl");
		npc.m_iWearable6 = npc.EquipItem("head", "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl");

		
		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable6, Prop_Send, "m_nSkin", skin);
				
		npc.m_flNextTeleport = GetGameTime(npc.index) + 1.0;
				
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a RANGED npc
		
		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Laz npc = view_as<Laz>(iNPC);
	
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

	//Ruina_Add_Battery(npc.index, 0.75);
	
	int PrimaryThreatIndex = npc.m_iTarget;	//when the npc first spawns this will obv be invalid, the core handles this.

	Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement, also handles targeting
	
	/*if(fl_ruina_battery[npc.index]>500.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		fl_ruina_battery_timer[npc.index] = GameTime + 2.5;
		
	}
	if(fl_ruina_battery_timer[npc.index]>GameTime)	//apply buffs
	{
		
	}*/
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))	//a final final failsafe
	{
		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

		int iPitch = npc.LookupPoseParameter("body_pitch");
		if(iPitch < 0)
			return;		

		
						
		//Body pitch
		float v[3], ang[3];
		float SelfVec[3]; WorldSpaceCenter(npc.index, SelfVec);
		if(!IsValidEntity(EntRefToEntIndex(i_laz_entity[npc.index])))
			SubtractVectors(SelfVec, vecTarget, v); 
		else
		{
			float Proj_Vec[3];
			GetEntPropVector(EntRefToEntIndex(i_laz_entity[npc.index]), Prop_Data, "m_vecAbsOrigin", Proj_Vec);
			SubtractVectors(SelfVec, Proj_Vec, v); 
			npc.FaceTowards(Proj_Vec, 20000.0);
		}
		NormalizeVector(v, v);
		GetVectorAngles(v, ang); 
								
		float flPitch = npc.GetPoseParameter(iPitch);
								
		npc.SetPoseParameter(iPitch, ApproachAngle(ang[0], flPitch, 10.0));

		if(flDistanceToTarget < (500.0*500.0))
		{
			int Enemy_I_See;
			
			Enemy_I_See = Can_I_See_Enemy(npc.index, PrimaryThreatIndex);
			//Target close enough to hit
			if(IsValidEnemy(npc.index, Enemy_I_See)) //Check if i can even see.
			{
				if(flDistanceToTarget < (325.0*350.0))
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

		if(npc.m_flNextRangedAttack < GameTime)	//Initialize the attack.
		{
			if(flDistanceToTarget<(750.0*750.0))
			{
				int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);
				
				if(!IsValidEntity(Laser_End))
				{
					Ruina_Projectiles Projectile;

					float Laser_Time = 5.0;
					float Reload_Time = 13.5;

					float projectile_speed = 500.0;
					float target_vec[3];
					PredictSubjectPositionForProjectiles(npc, PrimaryThreatIndex, projectile_speed, _,target_vec);

					Projectile.iNPC = npc.index;
					Projectile.Start_Loc = SelfVec;
					float Ang[3];
					MakeVectorFromPoints(SelfVec, target_vec, Ang);
					GetVectorAngles(Ang, Ang);
					Projectile.Angles = Ang;
					Projectile.speed = projectile_speed;
					Projectile.radius = 0.0;
					Projectile.damage = 100.0;
					Projectile.bonus_dmg = 200.0;
					Projectile.Time = Laser_Time;
					Projectile.visible = false;
					int Proj = Projectile.Launch_Projectile(Func_On_Proj_Touch);		

					if(IsValidEntity(Proj))
					{
						npc.PlayMeleeSound();
						npc.m_flNextRangedAttack = GameTime + Reload_Time;

						npc.m_flAttackHappens = GameTime + Laser_Time;

						i_laz_entity[npc.index] = EntIndexToEntRef(Proj);
						//CPrintToChatAll("Laser end created and is valid");

						Initiate_HomingProjectile(Proj,
						npc.index,
						75.0,			// float lockonAngleMax,
						7.5,			// float homingaSec,
						true,			// bool LockOnlyOnce,
						true,			// bool changeAngles,
						Ang);			// float AnglesInitiate[3]);

						float 	f_start = 1.5,
								f_end = 0.75,
								amp = 0.25;
						
						int r = 200,
							g = 200,
							b = 200;

						int beam = ConnectWithBeamClient(npc.m_iWearable5, Proj, r, g, b, f_start, f_end, amp, LASERBEAM);
						i_ruina_Projectile_Particle[Proj] = EntIndexToEntRef(beam);
					}
				}
			}
		}
		if(npc.m_flAttackHappens > GameTime)	//attack is active
		{

			int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

			if(!IsValidEntity(Laser_End))
			{
				//CPrintToChatAll("Delete laser end due to invalid");
				npc.m_flAttackHappens = 0.0;
				i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;

				npc.PlayRangedReloadSound();

				return;
			}

			float Proj_Vec[3];
			GetEntPropVector(Laser_End, Prop_Data, "m_vecAbsOrigin", Proj_Vec);
			

			//int color[4];
			//float time=0.1;
			//float size[2];
			//float amp = 0.1;
			//color = {175, 175, 175, 255};
			//size[0] = 7.5; size[1] = 5.0;

			npc.FaceTowards(Proj_Vec, 20000.0);
				
			Ruina_Laser_Logic Laser;

			Laser.client = npc.index;
			Laser.Start_Point = SelfVec;
			Laser.End_Point = Proj_Vec;

			//float flPos[3], flAng[3]; // original
			//GetAttachment(npc.index, "effect_hand_r", flPos, flAng);

			//TE_SetupBeamPoints(flPos, Proj_Vec, g_Ruina_BEAM_Laser, 0, 0, 0, time, size[0], size[1], 0, amp, color, 0);
			//TE_SendToAll();

			float dmg = 7.5;
			float radius = 15.0;

			Laser.Radius = radius;
			Laser.Damage = dmg;
			Laser.Bonus_Damage = dmg*6.0;
			Laser.damagetype = DMG_PLASMA;

			Laser.Deal_Damage();
		}
		else
		{
			if(npc.m_bAllowBackWalking)
				npc.FaceTowards(vecTarget, 2000.0);
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

static void Func_On_Proj_Touch(int projectile, int other)
{
	int owner = GetEntPropEnt(projectile, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(owner))
	{
		owner = 0;
	}
	else
	{
		Laz npc = view_as<Laz>(owner);
		npc.m_flAttackHappens = 0.0;
		npc.PlayRangedReloadSound();
		i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;
	}
		
	float ProjectileLoc[3];
	GetEntPropVector(projectile, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);

	if(IsValidEnemy(owner, other))
	{
		float Dmg = fl_ruina_Projectile_dmg[projectile];
		if(ShouldNpcDealBonusDamage(other))
			Dmg = fl_ruina_Projectile_bonus_dmg[projectile];
		
		SDKHooks_TakeDamage(other, owner, owner, Dmg, DMG_PLASMA, -1, _, ProjectileLoc);
	}

	Ruina_Remove_Projectile(projectile);
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{

	Laz npc = view_as<Laz>(victim);
		
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
	Laz npc = view_as<Laz>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	int Laser_End = EntRefToEntIndex(i_laz_entity[npc.index]);

	if(IsValidEntity(Laser_End))
	{
		RemoveEntity(Laser_End);
		i_laz_entity[npc.index] = INVALID_ENT_REFERENCE;
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
}