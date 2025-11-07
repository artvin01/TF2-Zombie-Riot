#pragma semicolon 1
#pragma newdecls required


static char g_HurtSound[][] = {
	"weapons/drg_pomson_drain_01.wav",
};

static char g_DeathSound[][] = {
	"weapons/bombinomicon_explode1.wav",
};
static char g_SpawnSound[][] = {
	"ui/killsound_electro.wav",
};

static char gGlow1;
static char gGlow2;
void TornUmbralGate_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Torn Umbral Gate");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_torn_umbral_gate");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Curtain; 
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
	PrecacheModel("models/zombie_riot/btd/bloons_hitbox.mdl");
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	PrecacheModel("sprites/combineball_trail_black_1.vmt");
	PrecacheModel("sprites/halo01.vmt");
	PrecacheModel("sprites/lgtning.vmt");
	gGlow1 = PrecacheModel("sprites/redglow1.vmt", true);
	gGlow2 = PrecacheModel("sprites/yellowglow1.vmt", true);
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_DeathSound));	i++) { PrecacheSound(g_DeathSound[i]);	}
	for (int i = 0; i < (sizeof(g_SpawnSound));	i++) { PrecacheSound(g_SpawnSound[i]);	}
}


static void ClotPrecache()
{
	NPC_GetByPlugin("npc_umbral_whiteflowers");

}

#define TORN_UMBRAL_GATEWAY 600.0
#define TORN_UMBRAL_DURATION 1.04
static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return TornUmbralGate(vecPos, vecAng, team);
}
methodmap TornUmbralGate < CClotBody
{
	property float m_flGateSpawnEnemies
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	public void PlayHurtSound()
	{
		EmitSoundToAll(g_HurtSound[GetRandomInt(0, sizeof(g_HurtSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSound[GetRandomInt(0, sizeof(g_DeathSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
		EmitSoundToAll(g_DeathSound[GetRandomInt(0, sizeof(g_DeathSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 80);
	}
	public void PlaySummonSound()
	{
		EmitSoundToAll(g_SpawnSound[GetRandomInt(0, sizeof(g_SpawnSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 40);
		EmitSoundToAll(g_SpawnSound[GetRandomInt(0, sizeof(g_SpawnSound) - 1)], this.index, SNDCHAN_AUTO, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 40);
	}
	public TornUmbralGate(float vecPos[3], float vecAng[3], int ally)
	{
		TornUmbralGate npc = view_as<TornUmbralGate>(CClotBody(vecPos, vecAng, "models/zombie_riot/btd/bloons_hitbox.mdl", "2.0", "700", ally, .isGiant = true, .CustomThreeDimensions = {100.0, 100.0, 200.0}, .NpcTypeLogic = STATIONARY_NPC));
		
		i_NpcWeight[npc.index] = 999;

		//not visible hitbox, error doesnt matter.
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flMeleeArmor = 2.0;	
		
		npc.m_iBleedType = BLEEDTYPE_PORTAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		npc.m_bDissapearOnDeath = true;
		//Flies through everything, but can still be hit/calls hits?
		b_IgnoreAllCollisionNPC[npc.index] = true;
		f_NoUnstuckVariousReasons[npc.index] = FAR_FUTURE;
		b_NoKnockbackFromSources[npc.index] = true;
		b_ThisNpcIsImmuneToNuke[npc.index] = true;
		b_DoNotUnStuck[npc.index] = true;
		npc.m_flGateSpawnEnemies = GetGameTime() + 2.0;

		//This gate is fyling, we cant really have npcs target this one
		b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true;

		func_NPCDeath[npc.index] = view_as<Function>(TornUmbralGate_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(TornUmbralGate_ClotThink);
		func_NPCOnTakeDamage[npc.index] = TornUmbralGate_OnTakeDamage;
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 50);
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 50);
		TornUmbralGate_Visuals(npc);
	
		return npc;
	}
}

public Action TornUmbralGate_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;

	TornUmbralGate npc = view_as<TornUmbralGate>(victim);

	float gameTime = GetGameTime(npc.index);

	if (npc.m_flHeadshotCooldown < gameTime)
	{
		
		npc.PlayHurtSound();
		npc.m_flHeadshotCooldown = gameTime + (DEFAULT_HURTDELAY * 0.5);
	}
	return Plugin_Changed;
}

public void TornUmbralGate_ClotThink(int iNPC)
{
	TornUmbralGate npc = view_as<TornUmbralGate>(iNPC);
	float gameTime = GetGameTime(npc.index);

	//some npcs deservere full update time!
	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}

	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;

	if(npc.m_flNextThinkTime > gameTime)
	{
		return;
	}
	npc.m_flNextThinkTime = gameTime + 0.5;
	float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
	VecSelfNpcabs[2] += 100.0;
	/*
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 200.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 400.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, -200.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, -400.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
		
	*/
	Torn_UmbralGate_ApplyBuffInLocation(VecSelfNpcabs);
	if(npc.m_flGateSpawnEnemies < gameTime && MaxEnemiesAllowedSpawnNext(0) > (EnemyNpcAlive - EnemyNpcAliveStatic))
	{
		int MaxenemySpawnScaling = 2;
		MaxenemySpawnScaling = RoundToNearest(float(MaxenemySpawnScaling) * MultiGlobalEnemy);

		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		pos[2] += 100.0;
		npc.PlaySummonSound();
		TE_Particle("powerup_supernova_explode_red", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);

		int MaxHealthGet = ReturnEntityMaxHealth(npc.index);
		MaxHealthGet /= 20;
		for(int i; i<MaxenemySpawnScaling; i++)
		{
			int summon = NPC_CreateByName("npc_umbral_whiteflowers", -1, pos, {0.0,0.0,0.0}, GetTeam(npc.index));
			if(IsValidEntity(summon))
			{
				if(GetTeam(npc.index) != TFTeam_Red)
					Zombies_Currently_Still_Ongoing++;
				
				SetEntProp(summon, Prop_Data, "m_iHealth", 		MaxHealthGet);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", MaxHealthGet);
				
				NpcStats_CopyStats(npc.index, summon);
				fl_Extra_MeleeArmor[summon] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[summon] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[summon] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[summon] = fl_Extra_Damage[npc.index];
				
				float flPos[3];
				flPos = pos;
				flPos[2] += 300.0;
				flPos[0] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(100.0, 200.0);
				flPos[1] += GetRandomInt(0,1) ? GetRandomFloat(-200.0, -100.0) : GetRandomFloat(200.0, 200.0);
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(summon, flPos);
			}
		}
		npc.m_flGateSpawnEnemies = gameTime + 15.0;
	}

	//effects
	float pos[3]; 
	if(IsValidEntity(i_ExpidonsaEnergyEffect[npc.index][1]))
	{
		GetEntPropVector(i_ExpidonsaEnergyEffect[npc.index][1], Prop_Data, "m_vecAbsOrigin", pos);
		TE_SetupGlowSprite(pos, gGlow2, TORN_UMBRAL_DURATION, 2.0, 255);
		TE_SendToAll();
	}
	if(IsValidEntity(i_ExpidonsaEnergyEffect[npc.index][4]))
	{
		GetEntPropVector(i_ExpidonsaEnergyEffect[npc.index][4], Prop_Data, "m_vecAbsOrigin", pos);
		TE_SetupGlowSprite(pos, gGlow1, TORN_UMBRAL_DURATION, 1.0, 255);
		TE_SendToAll();
	}
	if(IsValidEntity(i_ExpidonsaEnergyEffect[npc.index][5]))
	{
		GetEntPropVector(i_ExpidonsaEnergyEffect[npc.index][5], Prop_Data, "m_vecAbsOrigin", pos);
		TE_SetupGlowSprite(pos, gGlow1, TORN_UMBRAL_DURATION, 1.0, 255);
		TE_SendToAll();

	}
}

public void TornUmbralGate_NPCDeath(int entity)
{
	TornUmbralGate npc = view_as<TornUmbralGate>(entity);
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	StopSound(entity, SNDCHAN_STATIC, "weapons/physcannon/energy_sing_loop4.wav");
	float pos[3]; GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
	pos[2] += 100.0;
	TE_Particle("Explosion_ShockWave_01", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("grenade_smoke_cycle", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	TE_Particle("hammer_bell_ring_shockwave", pos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	CreateEarthquake(pos, 1.0, 2000.0, 16.0, 255.0);
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 1.0, 80.0, 4.0, 1, 5000.0);	
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 2.0, 80.0, 4.0, 1, 5000.0);	
	spawnRing_Vectors(pos, 0.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 185, 80, 185, 255, 1, /*duration*/ 3.0, 80.0, 4.0, 1, 5000.0);	
	npc.PlayDeathSound();
	//TornUmbralGate npc = view_as<TornUmbralGate>(entity);
	//gone
	ExpidonsaRemoveEffects(npc.index);
}

void TornUmbralGate_Visuals(TornUmbralGate npc)
{
	
	int particle_1 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0); //This is the root bone basically
		
	//Main 2 eye's
	//Middle eye part to connect to
	int particle_2 = InfoTargetParentAt({0.0,0.0,100.0}, "", 0.0);

	//up and down eye to connect
	int particle_3 = InfoTargetParentAt({0.0,0.0,25.0}, "", 0.0);
	int particle_4 = InfoTargetParentAt({0.0,0.0,175.0}, "", 0.0);
	int Laser_1 = ConnectWithBeamClient(particle_2, particle_3, 255, 255, 255, 40.0, 6.0, 2.0, "sprites/combineball_trail_black_1.vmt");
	int Laser_2 = ConnectWithBeamClient(particle_2, particle_4, 255, 255, 255, 40.0, 6.0, 2.0, "sprites/combineball_trail_black_1.vmt");


	//inside eye part
	int particle_5 = InfoTargetParentAt({0.0,0.0,10.0}, "", 0.0);
	int particle_6 = InfoTargetParentAt({0.0,0.0,190.0}, "", 0.0);

	//left and right
	int particle_7 = InfoTargetParentAt({0.0,90.0,100.0}, "", 0.0);
	int particle_8 = InfoTargetParentAt({0.0,-90.0,100.0}, "", 0.0);
	int Laser_3 = ConnectWithBeamClient(particle_5, particle_7, 255, 60, 100, 12.0, 12.0, 1.0, "sprites/halo01.vmt");
	int Laser_4 = ConnectWithBeamClient(particle_5, particle_8, 255, 60, 100, 12.0, 12.0, 1.0, "sprites/halo01.vmt");
	int Laser_5 = ConnectWithBeamClient(particle_6, particle_7, 255, 60, 100, 12.0, 12.0, 1.0, "sprites/halo01.vmt");
	int Laser_6 = ConnectWithBeamClient(particle_6, particle_8, 255, 60, 100, 12.0, 12.0, 1.0, "sprites/halo01.vmt");

	//Outer eye part
	//up and down
	int particle_9 = InfoTargetParentAt({0.0,0.0,200.0}, "", 0.0);
	int particle_10 = InfoTargetParentAt({0.0,0.0,0.0}, "", 0.0);

	//left and right
	int particle_11 = InfoTargetParentAt({0.0,250.0,100.0}, "", 0.0);
	int particle_12 = InfoTargetParentAt({0.0,-250.0,100.0}, "", 0.0);
	int Laser_7 = ConnectWithBeamClient(particle_9, particle_11, 185, 60, 185, 12.0, 12.0, 4.0, "sprites/lgtning.vmt");
	int Laser_8 = ConnectWithBeamClient(particle_9, particle_12, 185, 60, 185, 12.0, 12.0, 4.0, "sprites/lgtning.vmt");
	int Laser_9 = ConnectWithBeamClient(particle_10, particle_11, 185, 60, 185, 12.0, 12.0, 4.0, "sprites/lgtning.vmt");
	int Laser_10 = ConnectWithBeamClient(particle_10, particle_12, 185, 60, 185, 12.0, 12.0, 4.0, "sprites/lgtning.vmt");


	SetParent(particle_1, particle_2, "",_, true);
	SetParent(particle_1, particle_3, "",_, true);
	SetParent(particle_1, particle_4, "",_, true);
	SetParent(particle_1, particle_5, "",_, true);
	
	SetParent(particle_1, particle_6, "",_, true);
	SetParent(particle_1, particle_7, "",_, true);
	SetParent(particle_1, particle_8, "",_, true);
	SetParent(particle_1, particle_9, "",_, true);
	SetParent(particle_1, particle_10, "",_, true);
	SetParent(particle_1, particle_11, "",_, true);
	SetParent(particle_1, particle_12, "",_, true);

	float flPos[3];
	float flAng[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
	GetEntPropVector(npc.index, Prop_Data, "m_angRotation", flAng);
	SetEntPropVector(particle_1, Prop_Data, "m_angRotation", flAng); 
	Custom_SDKCall_SetLocalOrigin(particle_1, flPos);

	

	i_ExpidonsaEnergyEffect[npc.index][0] = EntIndexToEntRef(particle_1);
	i_ExpidonsaEnergyEffect[npc.index][1] = EntIndexToEntRef(particle_2);
	i_ExpidonsaEnergyEffect[npc.index][2] = EntIndexToEntRef(particle_3);
	i_ExpidonsaEnergyEffect[npc.index][3] = EntIndexToEntRef(particle_4);
	i_ExpidonsaEnergyEffect[npc.index][4] = EntIndexToEntRef(particle_5);	
	i_ExpidonsaEnergyEffect[npc.index][5] = EntIndexToEntRef(particle_6);	
	i_ExpidonsaEnergyEffect[npc.index][6] = EntIndexToEntRef(particle_7);	
	i_ExpidonsaEnergyEffect[npc.index][7] = EntIndexToEntRef(particle_8);	
	i_ExpidonsaEnergyEffect[npc.index][8] = EntIndexToEntRef(particle_9);	
	i_ExpidonsaEnergyEffect[npc.index][9] = EntIndexToEntRef(particle_10);	
	i_ExpidonsaEnergyEffect[npc.index][10] = EntIndexToEntRef(particle_11);	
	i_ExpidonsaEnergyEffect[npc.index][11] = EntIndexToEntRef(particle_12);	
	
	i_ExpidonsaEnergyEffect[npc.index][12] = EntIndexToEntRef(Laser_1);	
	i_ExpidonsaEnergyEffect[npc.index][13] = EntIndexToEntRef(Laser_2);	
	i_ExpidonsaEnergyEffect[npc.index][14] = EntIndexToEntRef(Laser_3);	
	i_ExpidonsaEnergyEffect[npc.index][15] = EntIndexToEntRef(Laser_4);	
	i_ExpidonsaEnergyEffect[npc.index][16] = EntIndexToEntRef(Laser_5);	
	i_ExpidonsaEnergyEffect[npc.index][17] = EntIndexToEntRef(Laser_6);	
	i_ExpidonsaEnergyEffect[npc.index][18] = EntIndexToEntRef(Laser_7);	
	i_ExpidonsaEnergyEffect[npc.index][19] = EntIndexToEntRef(Laser_8);	
	i_ExpidonsaEnergyEffect[npc.index][20] = EntIndexToEntRef(Laser_9);	
	i_ExpidonsaEnergyEffect[npc.index][21] = EntIndexToEntRef(Laser_10);	
}




void Torn_UmbralGate_ApplyBuffInLocation(float BannerPos[3])
{
	float targPos[3];
	for(int ally=1; ally<=MaxClients; ally++)
	{
		if(IsClientInGame(ally) && IsPlayerAlive(ally))
		{
			GetClientAbsOrigin(ally, targPos);
			targPos[2] = BannerPos[2];
			if (GetVectorDistance(BannerPos, targPos, true) <= (TORN_UMBRAL_GATEWAY * TORN_UMBRAL_GATEWAY))
			{
				ApplyStatusEffect(ally, ally, "Unstable Umbral Rift", 2.0);
			}
		}
	}
	for(int entitycount_again; entitycount_again<i_MaxcountNpcTotal; entitycount_again++)
	{
		int ally = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again]);
		if (IsValidEntity(ally) && !b_NpcHasDied[ally])
		{
			GetEntPropVector(ally, Prop_Data, "m_vecAbsOrigin", targPos);
			targPos[2] = BannerPos[2];
			if (GetVectorDistance(BannerPos, targPos, true) <= (TORN_UMBRAL_GATEWAY * TORN_UMBRAL_GATEWAY))
			{
				ApplyStatusEffect(ally, ally, "Unstable Umbral Rift", 2.0);
			}
		}
	}
}