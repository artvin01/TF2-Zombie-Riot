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
};

static const char g_IdleAlertedSounds[][] = {
	"vo/medic_battlecry01.mp3",
	"vo/medic_battlecry02.mp3",
	"vo/medic_battlecry03.mp3",
	"vo/medic_battlecry04.mp3",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/samurai/tf_katana_01.wav",
	"weapons/samurai/tf_katana_02.wav",
	"weapons/samurai/tf_katana_03.wav",
	"weapons/samurai/tf_katana_04.wav",
	"weapons/samurai/tf_katana_05.wav",
	"weapons/samurai/tf_katana_06.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/samurai/tf_katana_slice_01.wav",
	"weapons/samurai/tf_katana_slice_02.wav",
	"weapons/samurai/tf_katana_slice_03.wav",
};

static const char g_MeleeMissSounds[][] = {
	"weapons/cbar_miss1.wav",
};
static const char g_FantasiaSound[][] = {
	"ambient/machines/thumper_hit.wav",
};

static int i_damage_taken[MAXENTITIES];

void Rulius_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Rulius");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_rulius");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "demoknight_samurai"); 						//leaderboard_class_(insert the name)
	data.IconCustom = false;												//download needed?
	data.Flags = 0;						//example: MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;, forces these flags.	
	NPC_Add(data);
}
static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_IdleAlertedSounds);
	PrecacheSoundArray(g_MeleeHitSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_MeleeMissSounds);
	PrecacheSoundArray(g_FantasiaSound);
	Zero(i_damage_taken);
	PrecacheModel("models/player/medic.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return Rulius(vecPos, vecAng, team);
}
methodmap Rulius < CClotBody
{
	
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
	
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		

	}

	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		
	}

	public void PlayFantasiaSound() {
		EmitSoundToAll(g_FantasiaSound[GetRandomInt(0, sizeof(g_FantasiaSound) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
		#if defined DEBUG_SOUND
		PrintToServer("CGoreFast::PlayFantasiaSound()");
		#endif
	}
	
	
	
	public Rulius(float vecPos[3], float vecAng[3], int ally)
	{
		Rulius npc = view_as<Rulius>(CClotBody(vecPos, vecAng, "models/player/medic.mdl", "1.0", "25000", ally));
		
		i_NpcWeight[npc.index] = 3;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);

		npc.m_iChanged_WalkCycle = 1;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		/*
			heat of winter
			herzensbrecher
			lavish labwear
			Low Grav Loafers -	"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl"
			Byte'd beak			"models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl"
			El Jefe				"models/player/items/scout/rebel_cap.mdl"

		*/
		
		//IDLE
		npc.m_flSpeed = 300.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();
		
		static const char Items[][] = {
			"models/workshop/player/items/medic/sbxo2014_medic_wintergarb_coat/sbxo2014_medic_wintergarb_coat.mdl",
			"models/workshop/player/items/medic/sf14_medic_herzensbrecher/sf14_medic_herzensbrecher.mdl",
			"models/workshop/player/items/medic/hwn2022_lavish_labwear/hwn2022_lavish_labwear.mdl",
			"models/workshop/player/items/medic/hw2013_moon_boots/hw2013_moon_boots.mdl",
			"models/workshop/player/items/medic/robo_medic_blighted_beak/robo_medic_blighted_beak.mdl",
			"models/player/items/scout/rebel_cap.mdl",
			RUINA_CUSTOM_MODELS_2
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

		SetVariantInt(RUINA_BLADE_2);
		AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");	

		SetVariantInt(1);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;

		npc.Anger = false;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_MELEE_NPC);	//is a melee npc
		Ruina_Set_Master_Heirarchy(npc.index, RUINA_MELEE_NPC, true, 10, 4);		//priority 4, just lower then the actual bosses

		b_ruina_nerf_healing[npc.index] = true;

		return npc;
	}
	//npc.AdjustWalkCycle();
	public void AdjustWalkCycle()
	{
		if(this.IsOnGround())
		{
			if(this.m_iChanged_WalkCycle == 0)
			{
				this.SetActivity("ACT_MP_RUN_MELEE_ALLCLASS");
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
	
}


static void ClotThink(int iNPC)
{
	Rulius npc = view_as<Rulius>(iNPC);

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

	npc.AdjustWalkCycle();

	Ruina_Add_Battery(npc.index, 15.0);
	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;

	
	if(fl_ruina_battery[npc.index]>3000.0)
	{
		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = true;
	}
	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
		Ruina_Ai_Override_Core(npc.index, PrimaryThreatIndex, GameTime);	//handles movement

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
		float flDistanceToTarget = GetVectorDistance(vecTarget, Npc_Vec, true);

		if(b_ruina_battery_ability_active[npc.index] && !npc.Anger && flDistanceToTarget < 250000 && fl_ruina_battery_timeout[npc.index] < GameTime)
		{
			float Difference = FloatAbs(Npc_Vec[2]-vecTarget[2]);
			if(Difference < 65.0)	//make sure its more or less the same height as the npc
			{
				fl_ruina_battery_timeout[npc.index] = GameTime + 15.0;
				if(IsValidEntity(npc.m_iWearable7))
					RemoveEntity(npc.m_iWearable7);
				
				npc.m_flDoingAnimation = GameTime + 0.9;
				npc.PlayFantasiaSound();
				npc.AddGesture("ACT_MP_THROW");
				b_ruina_battery_ability_active[npc.index] = false;
				npc.Anger = true;
				Rulius_Special(npc, PrimaryThreatIndex);
			}	
		}

		if(npc.m_flDoingAnimation < GameTime)
		{
			if(!IsValidEntity(npc.m_iWearable7))
			{
				npc.m_iWearable7 = npc.EquipItem("head", RUINA_CUSTOM_MODELS_2);
				SetVariantInt(RUINA_BLADE_2);
				AcceptEntityInput(npc.m_iWearable7, "SetBodyGroup");
			}

			Ruina_Self_Defense Melee;

			Melee.iNPC = npc.index;
			Melee.target = PrimaryThreatIndex;
			Melee.fl_distance_to_target = flDistanceToTarget;
			Melee.range = NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED*1.25;
			Melee.damage = 75.0;
			Melee.bonus_dmg = 325.0;
			Melee.attack_anim = "ACT_MP_ATTACK_STAND_MELEE_ALLCLASS";
			Melee.swing_speed = 0.75;
			Melee.swing_delay = 0.35;
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

#define RUINA_RUIANUS_LOOP_AMT 5
static int i_projectile_ref[MAXENTITIES][RUINA_RUIANUS_LOOP_AMT];
static float fl_ability_timer[MAXENTITIES];
static void Rulius_Special(CClotBody npc, int PrimaryThreatIndex)
{
	float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
	float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
	npc.FaceTowards(vecTarget, 20000.0);

	float ang_Look[3];
	MakeVectorFromPoints(Npc_Vec, vecTarget, ang_Look);
	GetVectorAngles(ang_Look, ang_Look);
	
	float wide_set = 45.0;	//How big the angle difference from left to right, in this case its 90 \/ if you set it to 90 rather then 45 it would be a 180 degree swing
	
	ang_Look[1] -= wide_set;
	float type = (wide_set*2) / RUINA_RUIANUS_LOOP_AMT;
	ang_Look[1] -= type;
	
	float Timer = 1.5;
	fl_ability_timer[npc.index] = Timer + GetGameTime(npc.index);
	int Last_Proj = -1;
	for(int i=0 ; i<RUINA_RUIANUS_LOOP_AMT; i++)
	{
		float tempAngles[3], endLoc[3], Direction[3];
		
		tempAngles[0] = 0.0;
		tempAngles[1] = ang_Look[1] + type * (i+1);
		tempAngles[2] = 0.0;
		
		if(ang_Look[1]>360.0)
		{
			ang_Look[1] -= 360.0;
		}

		GetAngleVectors(tempAngles, Direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(Direction, 100.0);
		AddVectors(Npc_Vec, Direction, endLoc);

		float Proj_Ang[3];
		MakeVectorFromPoints(Npc_Vec, endLoc, Proj_Ang);
		GetVectorAngles(Proj_Ang, Proj_Ang);

		Ruina_Projectiles Projectile;

		Projectile.iNPC = npc.index;
		Projectile.Start_Loc = Npc_Vec;
		Projectile.Angles = Proj_Ang;
		Projectile.speed = 300.0;
		Projectile.Time = Timer+0.1;

		int Proj = Projectile.Launch_Projectile();
		SDKUnhook(Proj, SDKHook_StartTouch, Ruina_Projectile_Touch);
		SDKHook(Proj, SDKHook_ShouldCollide, Never_ShouldCollide);

		int color[3] = {255, 150, 150};

		if(Last_Proj!=-1)
		{
			int Laser = ConnectWithBeam(Proj, Last_Proj, color[0], color[1], color[2], 4.0, 4.0, 5.0, BEAM_COMBINE_BLACK);

			CreateTimer(Timer-0.1, Timer_RemoveEntity, EntIndexToEntRef(Laser), TIMER_FLAG_NO_MAPCHANGE);
		}
		i_projectile_ref[npc.index][i] = EntIndexToEntRef(Proj);
		Last_Proj = Proj;
	}
	npc.m_flNextTeleport = 0.0;
	SDKHook(npc.index, SDKHook_Think, Rulius_Ability_Think);
}
static Action Rulius_Ability_Think(int iNPC)
{
	CClotBody npc = view_as<CClotBody>(iNPC);
	float GameTime = GetGameTime(npc.index);

	if(fl_ability_timer[npc.index] < GameTime)
	{
		npc.Anger = false;
		Kill_Ability(npc.index);
		return Plugin_Stop;
	}

	if(npc.m_flNextTeleport > GameTime)
		return Plugin_Continue;

	npc.m_flNextTeleport = GameTime + 0.1;

	int Previous_Proj = i_projectile_ref[npc.index][0];

	for(int i=1 ; i<RUINA_RUIANUS_LOOP_AMT; i++)
	{
		int Proj = EntRefToEntIndex(i_projectile_ref[npc.index][i]);
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

	return Plugin_Continue;
}
static void On_LaserHit(int client, int Target, int damagetype, float damage)
{
	i_damage_taken[client] += RoundToFloor(damage*0.5);
	Ruina_Add_Mana_Sickness(client, Target, 0.0, 50);
}
static void Kill_Ability(int iNPC)
{
	SDKUnhook(iNPC, SDKHook_Think, Rulius_Ability_Think);

	for(int i=0 ; i< RUINA_RUIANUS_LOOP_AMT; i++)
	{
		int Proj = EntRefToEntIndex(i_projectile_ref[iNPC][i]);
		if(IsValidEntity(Proj))
			RemoveEntity(Proj);

		i_projectile_ref[iNPC][i] = INVALID_ENT_REFERENCE;
	}
}
static void OnRuina_MeleeAttack(int iNPC, int Target)
{
	Ruina_Add_Mana_Sickness(iNPC, Target, 0.1, 100);
}
static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Rulius npc = view_as<Rulius>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;

	float GameTime = GetGameTime(npc.index);

	Ruina_NPC_OnTakeDamage_Override(npc.index, attacker, inflictor, damage, damagetype, weapon, damageForce, damagePosition, damagecustom);
	
	if(fl_ruina_battery_timer[npc.index]<GameTime)
	{
		int Max_Health = ReturnEntityMaxHealth(npc.index);
		fl_ruina_battery_timer[npc.index]=GameTime+5.0;
		int healing = RoundToFloor(i_damage_taken[npc.index]*0.2);

		if(healing > RoundToFloor(Max_Health*0.4))
			healing = RoundToFloor(Max_Health*0.4);

		//CPrintToChatAll("Healing: %i",healing);
			
		Helia_Healing_Logic(npc.index, healing, 500.0, GameTime, 0.5);

		i_damage_taken[npc.index]=0;
	}
	else
	{
		i_damage_taken[npc.index]+=damage;
	}

	if (npc.m_flHeadshotCooldown < GameTime)
	{
		npc.m_flHeadshotCooldown = GameTime + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void NPC_Death(int entity)
{
	Rulius npc = view_as<Rulius>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

	Kill_Ability(npc.index);

	Ruina_NPCDeath_Override(entity);
		
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
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