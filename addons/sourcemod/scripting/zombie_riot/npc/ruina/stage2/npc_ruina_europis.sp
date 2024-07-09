#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"vo/pyro_paincrticialdeath01.mp3",
	"vo/pyro_paincrticialdeath02.mp3",
	"vo/pyro_paincrticialdeath03.mp3",
};

static const char g_HurtSounds[][] = {
	"vo/pyro_painsharp01.mp3",
	"vo/pyro_painsharp02.mp3",
	"vo/pyro_painsharp03.mp3",
	"vo/pyro_painsharp04.mp3",
	"vo/pyro_painsharp05.mp3",
};

static const char g_IdleSounds[][] = {
	"vo/pyro_jeers01.mp3",	
	"vo/pyro_jeers02.mp3",	
};

static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/pyro_taunts01.mp3",
	"vo/taunts/pyro_taunts02.mp3",
	"vo/taunts/pyro_taunts03.mp3",
};
static const char g_RangedAttackSounds[][] = {
	"weapons/dragons_fury_shoot.wav",
};

static const char g_RangedReloadSound[][] = {
	"weapons/dragons_fury_pressure_build.wav",
};

void Europis_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Europis");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_ruina_europis");
	data.Category = Type_Ruina;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	strcopy(data.Icon, sizeof(data.Icon), "pyro"); 						//leaderboard_class_(insert the name)
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
	PrecacheSoundArray(g_RangedAttackSounds);
	PrecacheSoundArray(g_RangedReloadSound);
	PrecacheModel("models/player/pyro.mdl");
}
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally)
{
	return Europis(client, vecPos, vecAng, ally);
}

static float fl_npc_basespeed;

methodmap Europis < CClotBody
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
	public void PlayRangedSound() {
		EmitSoundToAll(g_RangedAttackSounds[GetRandomInt(0, sizeof(g_RangedAttackSounds) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	public void PlayRangedReloadSound() {
		EmitSoundToAll(g_RangedReloadSound[GetRandomInt(0, sizeof(g_RangedReloadSound) - 1)], this.index, _, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, RUINA_NPC_PITCH);
		
		#if defined DEBUG_SOUND
		PrintToServer("CClot::PlayRangedSound()");
		#endif
	}
	
	
	public Europis(int client, float vecPos[3], float vecAng[3], int ally)
	{
		Europis npc = view_as<Europis>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "1250", ally));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE_ALLCLASS");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		/*
			All Father	"models/workshop/player/items/all_class/xms_beard/xms_beard_%s.mdl"
			Big chief - "models/player/items/heavy/heavy_big_chief.mdl"
			mair mask		"models/workshop/player/items/pyro/hazeguard/hazeguard.mdl"
			pyromancer		Dec2014_Pyromancers_Raiments	"models/workshop/player/items/pyro/dec2014_pyromancers_raiments/dec2014_pyromancers_raiments.mdl"
			hypno-eyes
		
		*/
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(NPC_Death);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ClotThink);

		fl_npc_basespeed = 200.0;
		npc.m_flSpeed = fl_npc_basespeed;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.StartPathing();

		static const char Items[][] = {
			"models/player/items/heavy/heavy_big_chief.mdl",
			"models/workshop/player/items/all_class/xms_beard/xms_beard_medic.mdl",
			"models/workshop/player/items/pyro/hazeguard/hazeguard.mdl",
			"models/workshop/player/items/pyro/dec2014_pyromancers_raiments/dec2014_pyromancers_raiments.mdl",
			RUINA_CUSTOM_MODELS_1
		};

		int skin = 1;	//1=blue, 0=red
		SetVariantInt(1);	
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		npc.m_iWearable1 = npc.EquipItem("head", Items[0], _, skin);
		npc.m_iWearable2 = npc.EquipItem("head", Items[1], _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", Items[2], _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", Items[3], _, skin);
		npc.m_iWearable5 = npc.EquipItem("head", Items[4], _);
		//npc.m_iWearable6 = npc.EquipItem("head", Items[5], _, skin);
		//npc.m_iWearable7 = npc.EquipItem("head", Items[6]);

		SetVariantInt(RUINA_EUR_STAFF_1);
		AcceptEntityInput(npc.m_iWearable5, "SetBodyGroup");

		fl_ruina_battery[npc.index] = 0.0;
		b_ruina_battery_ability_active[npc.index] = false;
		fl_ruina_battery_timer[npc.index] = 0.0;
		
		Ruina_Set_Heirarchy(npc.index, RUINA_RANGED_NPC);	//is a ranged npc

		return npc;
	}
	
	
}

//TODO 
//Rewrite
static void ClotThink(int iNPC)
{
	Europis npc = view_as<Europis>(iNPC);
	
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

	Ruina_Add_Battery(npc.index, 1.5);

	
	if(npc.m_flGetClosestTargetTime < GameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GameTime + GetRandomRetargetTime();
	}
	
	int PrimaryThreatIndex = npc.m_iTarget;
	
	if(fl_ruina_battery[npc.index]>4000.0)
	{
		if(Zombies_Currently_Still_Ongoing < NPC_HARD_LIMIT)
		{
			fl_ruina_battery[npc.index] = 0.0;
			Europis_Spawn_Self(npc);
			Master_Apply_Speed_Buff(npc.index, 100.0, 10.0, 1.75);	//a strong buff.
		}
		
	}

	if(fl_ruina_battery_timer[npc.index]<GameTime)
	{
		fl_ruina_battery_timer[npc.index]=GameTime+7.5;
		if(Zombies_Currently_Still_Ongoing < RoundToFloor(NPC_HARD_LIMIT*0.5))
		{
			Europis_Spawn_Minnions(npc);
		}
		
	}

	if(IsValidEnemy(npc.index, PrimaryThreatIndex))
	{
			
		int Anchor_Id=-1;
		Ruina_Independant_Long_Range_Npc_Logic(npc.index, PrimaryThreatIndex, GameTime, Anchor_Id); //handles movement

		float vecTarget[3]; WorldSpaceCenter(PrimaryThreatIndex, vecTarget);
		float Npc_Vec[3]; WorldSpaceCenter(npc.index, Npc_Vec);
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
		}
		else
		{
			npc.m_bAllowBackWalking=false;
		}
		Europis_SelfDefense(npc, GameTime, Anchor_Id);
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

static Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	Europis npc = view_as<Europis>(victim);
		
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
	Europis npc = view_as<Europis>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}

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
}
static void Europis_Spawn_Minnions(Europis npc)
{
	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");
	
	float ratio = float(GetEntProp(npc.index, Prop_Data, "m_iHealth")) / float(maxhealth);
	if(0.9-(npc.g_TimesSummoned*0.2) > ratio)
	{
		npc.g_TimesSummoned++;
		for(int i; i<1; i++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int spawn_index;

			char NpcName[50];

			switch(GetRandomInt(0, 5))
			{
				case 0:
					NpcName = "npc_ruina_magia";
				case 3:
					NpcName = "npc_ruina_lanius";
				default: 
					NpcName = "npc_ruina_dronian";
			}
			
			spawn_index = NPC_CreateByName(NpcName, npc.index, pos, ang, GetTeam(npc.index));
			maxhealth = RoundToNearest(maxhealth * 0.45);

			if(spawn_index > MaxClients)
			{
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);

				float WorldSpaceVec[3]; WorldSpaceCenter(spawn_index, WorldSpaceVec);
				ParticleEffectAt(WorldSpaceVec, "teleported_blue", 0.5);
			}
		}
	}
}
static void Europis_Spawn_Self(Europis npc)
{
	int maxhealth = GetEntProp(npc.index, Prop_Data, "m_iMaxHealth");

	if(maxhealth<100)
		return;
	
	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
	int spawn_index;
			
	spawn_index = NPC_CreateByName("npc_ruina_europis", npc.index, pos, ang, GetTeam(npc.index));
	maxhealth = RoundToNearest(maxhealth * 0.8);

	if(spawn_index > MaxClients)
	{
		NpcAddedToZombiesLeftCurrently(spawn_index, true);
		SetEntProp(spawn_index, Prop_Data, "m_iHealth", maxhealth);
		SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", maxhealth);

		float WorldSpaceVec[3]; WorldSpaceCenter(spawn_index, WorldSpaceVec);
		ParticleEffectAt(WorldSpaceVec, "teleported_red", 0.5);
	}
}
static void Europis_SelfDefense(Europis npc, float gameTime, int Anchor_Id)	//ty artvin
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
			npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", true);
			npc.PlayRangedSound();
			//after we fire, we will have a short delay beteween the actual laser, and when it happens
			//This will predict as its relatively easy to dodge
			float projectile_speed = 500.0;
			//lets pretend we have a projectile.
			if(flDistanceToTarget < 1250.0*1250.0)
				PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0, vecTarget);
			if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
			{
				WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
			}
			float DamageDone = 75.0;
			npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
			npc.FaceTowards(vecTarget, 20000.0);
			npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
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
					npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE_ALLCLASS", true);
					npc.PlayRangedSound();
					//after we fire, we will have a short delay beteween the actual laser, and when it happens
					//This will predict as its relatively easy to dodge
					float projectile_speed = 500.0;
					//lets pretend we have a projectile.
					if(flDistanceToTarget < 1250.0*1250.0)
						PredictSubjectPositionForProjectiles(npc, GetClosestEnemyToAttack, projectile_speed, 40.0, vecTarget);
					if(!Can_I_See_Enemy_Only(npc.index, GetClosestEnemyToAttack)) //cant see enemy in the predicted position, we will instead just attack normally
					{
						WorldSpaceCenter(GetClosestEnemyToAttack, vecTarget);
					}
					float DamageDone = 50.0;
					npc.FireParticleRocket(vecTarget, DamageDone, projectile_speed, 0.0, "spell_fireball_small_blue", false, true, false,_,_,_,10.0);
					npc.FaceTowards(vecTarget, 20000.0);
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 5.0;
					npc.PlayRangedReloadSound();
				}
			}
		}
	}
	if(npc.m_bAllowBackWalking)
	{
		npc.m_flSpeed = fl_npc_basespeed*RUINA_BACKWARDS_MOVEMENT_SPEED_PENATLY;
		npc.FaceTowards(vecTarget, RUINA_FACETOWARDS_BASE_TURNSPEED);
	}	
	else
		npc.m_flSpeed = fl_npc_basespeed;
	npc.m_iTarget = GetClosestEnemyToAttack;
}