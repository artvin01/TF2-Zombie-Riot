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
static const char g_IdleAlertedSounds[][] = {
	"vo/taunts/pyro_taunts01.mp3",
	"vo/taunts/pyro_taunts02.mp3",
	"vo/taunts/pyro_taunts03.mp3",
};


void ChemicalSpreader_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	PrecacheSound("weapons/flame_thrower_loop.wav");
	PrecacheSound("weapons/flame_thrower_pilot.wav");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Chemical Spreader");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_chemical_spreader");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_pulverizer");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_Vesta;
	data.Func = ClotSummon;
	int id = NPC_Add(data);
	Rogue_Paradox_AddWinterNPC(id);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ChemicalSpreader(vecPos, vecAng, team);
}

methodmap ChemicalSpreader < CClotBody
{

	property int i_GunMode
	{
		public get()							{ return i_TimesSummoned[this.index]; }
		public set(int TempValueForProperty) 	{ i_TimesSummoned[this.index] = TempValueForProperty; }
	}
	public void PlayIdleAlertSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
		
	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	
	property float m_flPulveriserAttackDelay
	{
		public get()							{ return fl_AbilityOrAttack[this.index][1]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][1] = TempValueForProperty; }
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMinigunSound(bool Shooting) 
	{
		if(Shooting)
		{
			if(this.i_GunMode != 0)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
				EmitSoundToAll("weapons/flame_thrower_loop.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.20);
			}
			this.i_GunMode = 0;
		}
		else
		{
			if(this.i_GunMode != 1)
			{
				StopSound(this.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
				EmitSoundToAll("weapons/flame_thrower_pilot.wav", this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, 1.20);
			}
			this.i_GunMode = 1;
		}
	}
	
	public ChemicalSpreader(float vecPos[3], float vecAng[3], int ally)
	{
		ChemicalSpreader npc = view_as<ChemicalSpreader>(CClotBody(vecPos, vecAng, "models/player/pyro.mdl", "1.0", "5000", ally));
		
		i_NpcWeight[npc.index] = 1;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_PRIMARY");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		SetVariantInt(5);
		AcceptEntityInput(npc.index, "SetBodyGroup");

		npc.m_bDissapearOnDeath = true;
		
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;

		func_NPCDeath[npc.index] = view_as<Function>(ChemicalSpreader_NPCDeath);
		func_NPCOnTakeDamage[npc.index] = view_as<Function>(ChemicalSpreader_OnTakeDamage);
		func_NPCThink[npc.index] = view_as<Function>(ChemicalSpreader_ClotThink);
		
		
		
		npc.StartPathing();
		npc.m_flSpeed = 280.0;
		
		
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);

		npc.m_iWearable1 = npc.EquipItem("head", "models/weapons/c_models/c_drg_phlogistinator/c_drg_phlogistinator.mdl");
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_creature_from_the_heap/hw2013_the_creature_from_the_heap.mdl");
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/pyro/hwn2025_air_exchanger/hwn2025_air_exchanger.mdl");
		npc.m_iWearable4 = npc.EquipItem("head", "models/workshop/player/items/pyro/dec24_hot_spaniel/dec24_hot_spaniel.mdl");
		npc.m_iWearable5 = npc.EquipItem("head", "models/workshop/player/items/pyro/sum25_frogmanns/sum25_frogmanns.mdl");
		
		SetEntProp(npc.m_iWearable1, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable2, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable3, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable4, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.m_iWearable5, Prop_Send, "m_nSkin", skin);

		NpcColourCosmetic_ViaPaint(npc.m_iWearable2, 2636109);

		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		SetVariantString("1.5");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		return npc;
	}
}

static void ChemicalSpreader_ClotThink(int iNPC)
{
	ChemicalSpreader npc = view_as<ChemicalSpreader>(iNPC);
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;

	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );
	
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget,_,_, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else 
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		ChemicalSpreaderSelfDefense(npc); 
	}
	else
	{
		npc.PlayMinigunSound(false);
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	npc.PlayIdleAlertSound();
}

static Action ChemicalSpreader_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	ChemicalSpreader npc = view_as<ChemicalSpreader>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
		
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

static void ChemicalSpreader_NPCDeath(int entity)
{
	ChemicalSpreader npc = view_as<ChemicalSpreader>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
		
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_loop.wav");
	StopSound(npc.index, SNDCHAN_STATIC, "weapons/flame_thrower_pilot.wav");
	
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);


	int entity_death = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(entity_death))
	{
		ChemicalSpreader prop = view_as<ChemicalSpreader>(entity_death);
		float pos[3];
		float Angles[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", Angles);

		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(entity_death, pos, Angles, NULL_VECTOR);

		DispatchKeyValue(entity_death, "model", "models/player/pyro.mdl");

		DispatchSpawn(entity_death);
		
		prop.m_iWearable1 = prop.EquipItem("head", "models/workshop/player/items/pyro/hw2013_the_creature_from_the_heap/hw2013_the_creature_from_the_heap.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable1, "SetModelScale");

		prop.m_iWearable2 = prop.EquipItem("head", "models/workshop/player/items/pyro/hwn2025_air_exchanger/hwn2025_air_exchanger.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable2, "SetModelScale");

		prop.m_iWearable3 = prop.EquipItem("head", "models/workshop/player/items/pyro/dec24_hot_spaniel/dec24_hot_spaniel.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable3, "SetModelScale");
		
		prop.m_iWearable4 = prop.EquipItem("head", "models/workshop/player/items/pyro/sum25_frogmanns/sum25_frogmanns.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(prop.m_iWearable4, "SetModelScale");


		DispatchKeyValue(entity_death, "skin", "1");
		DispatchKeyValue(prop.m_iWearable1, "skin", "1");
		DispatchKeyValue(prop.m_iWearable2, "skin", "1");
		DispatchKeyValue(prop.m_iWearable3, "skin", "1");
		DispatchKeyValue(prop.m_iWearable4, "skin", "1");

		NpcColourCosmetic_ViaPaint(prop.m_iWearable1, 2636109);

		SetVariantInt(5);
		AcceptEntityInput(entity_death, "SetBodyGroup");
 
		SetEntityCollisionGroup(entity_death, 2);
		SetVariantString("dieviolent");
		AcceptEntityInput(entity_death, "SetAnimation");
		
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(entity_death), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable1), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable2), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable3), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(1.0, Timer_RemoveEntity, EntIndexToEntRef(prop.m_iWearable4), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	float startPosition[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", startPosition); 
	startPosition[2] += 45;

	KillFeed_SetKillIcon(npc.index, "ullapool_caber_explosion");
	b_NpcIsTeamkiller[npc.index] = true;
	Explode_Logic_Custom(25.0, -1, npc.index, -1, startPosition, 100.0, _, _, true, _, true, 1.0, ChecmicalSpreader_ExplodePost);
	b_NpcIsTeamkiller[npc.index] = false;

	int health = ReturnEntityMaxHealth(npc.index) / 10;

	float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
	float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
	
	if(MaxEnemiesAllowedSpawnNext(1) > (EnemyNpcAlive - EnemyNpcAliveStatic))
	{
		int entityspawn = NPC_CreateByName("npc_searunner", -1, pos, ang, GetTeam(npc.index));
		if(entityspawn > MaxClients)
		{
			if(GetTeam(npc.index) != TFTeam_Red)
				Zombies_Currently_Still_Ongoing++;
			
			SetEntProp(entityspawn, Prop_Data, "m_iHealth", health);
			SetEntProp(entityspawn, Prop_Data, "m_iMaxHealth", health);
			
			fl_Extra_MeleeArmor[entityspawn] = fl_Extra_MeleeArmor[npc.index];
			fl_Extra_RangedArmor[entityspawn] = fl_Extra_RangedArmor[npc.index];
			fl_Extra_Speed[entityspawn] = fl_Extra_Speed[npc.index];
			fl_Extra_Damage[entityspawn] = fl_Extra_Damage[npc.index] * 2.0;
		}
	}

	DataPack pack_boom = new DataPack();
	pack_boom.WriteFloat(startPosition[0]);
	pack_boom.WriteFloat(startPosition[1]);
	pack_boom.WriteFloat(startPosition[2]);
	pack_boom.WriteCell(1);
	RequestFrame(MakeExplosionFrameLater, pack_boom);


}

public void ChecmicalSpreader_ExplodePost(int attacker, int victim, float damage, int weapon)
{	
	float EnemyVecPos[3]; WorldSpaceCenter(victim, EnemyVecPos);
	ParticleEffectAt(EnemyVecPos, "water_bulletsplash01", 3.0);
	Elemental_AddNervousDamage(victim, attacker, RoundToCeil(damage * 2.0));
}

static void ChemicalSpreaderSelfDefense(ChemicalSpreader npc)
{
	if(npc.m_flPulveriserAttackDelay > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flPulveriserAttackDelay = GetGameTime(npc.index) + 0.2;
	int target;
	target = npc.m_iTarget;
	//some Ranged units will behave differently.
	//not this one.
	float vecTarget[3]; WorldSpaceCenter(target, vecTarget);
	bool SpinSound = true;
	float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
	float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
	if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 4.0))
	{
		npc.PlayMinigunSound(true);
		SpinSound = false;
		npc.FaceTowards(vecTarget, 20000.0);
		int projectile = npc.FireParticleRocket(vecTarget, 12.0, 1250.0, 150.0, "unusual_electricfire_teamcolor_blue", true);
		SDKUnhook(projectile, SDKHook_StartTouch, Rocket_Particle_StartTouch);
		int particle = EntRefToEntIndex(i_WandParticle[projectile]);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(projectile), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.5, Timer_RemoveEntity, EntIndexToEntRef(particle), TIMER_FLAG_NO_MAPCHANGE);
		
		WandProjectile_ApplyFunctionToEntity(projectile, ChemicalSpreader_Rocket_Particle_StartTouch);
	}
	if(SpinSound)
		npc.PlayMinigunSound(false);
}

static void ChemicalSpreader_Rocket_Particle_StartTouch(int entity, int target)
{
	if(target > 0 && target < MAXENTITIES)	//did we hit something???
	{
		int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(!IsValidEntity(owner))
			owner = 0;
		
		int inflictor = h_ArrowInflictorRef[entity];
		if(inflictor != -1)
			inflictor = EntRefToEntIndex(h_ArrowInflictorRef[entity]);

		if(inflictor == -1)
			inflictor = owner;
			
		float ProjectileLoc[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjectileLoc);
		float DamageDeal = fl_rocket_particle_dmg[entity];
		if(ShouldNpcDealBonusDamage(target))
			DamageDeal *= h_BonusDmgToSpecialArrow[entity];

		SDKHooks_TakeDamage(target, owner, inflictor, DamageDeal, DMG_BULLET|DMG_PREVENT_PHYSICS_FORCE, -1);
		
		Elemental_AddNervousDamage(target, owner, 25, true);
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	else
	{
		int particle = EntRefToEntIndex(i_WandParticle[entity]);
		//we uhh, missed?
		if(IsValidEntity(particle))
			RemoveEntity(particle);
	}
	RemoveEntity(entity);
}