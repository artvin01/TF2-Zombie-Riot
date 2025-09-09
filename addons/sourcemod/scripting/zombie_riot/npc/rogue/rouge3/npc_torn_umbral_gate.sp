#pragma semicolon 1
#pragma newdecls required


static char gGlow1;
static char gGlow2;

static char g_HurtSound[][] = {
	"weapons/drg_pomson_drain_01.wav",
};

static char g_DeathSound[][] = {
	"weapons/bombinomicon_explode1.wav",
};
static char g_SpawnSound[][] = {
	"ui/killsound_electro.wav",
};

void TornUmbralGate_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Torn Umbral Gate");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_torn_umbral_gate");
	strcopy(data.Icon, sizeof(data.Icon), "void_gate");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = 0; 
	data.Func = ClotSummon;
	NPC_Add(data);
	PrecacheModel("models/zombie_riot/btd/bloons_hitbox.mdl");
	PrecacheSound("weapons/physcannon/energy_sing_loop4.wav", true);
	gGlow1 = PrecacheModel("sprites/redglow1.vmt", true);
	gGlow2 = PrecacheModel("sprites/yellowglow1.vmt", true);
	for (int i = 0; i < (sizeof(g_HurtSound));	i++) { PrecacheSound(g_HurtSound[i]);	}
	for (int i = 0; i < (sizeof(g_DeathSound));	i++) { PrecacheSound(g_DeathSound[i]);	}
	for (int i = 0; i < (sizeof(g_SpawnSound));	i++) { PrecacheSound(g_SpawnSound[i]);	}
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

		//not visible hitbox
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 255, 255, 255, 0);

		npc.m_flNextMeleeAttack = 0.0;
		
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

		func_NPCDeath[npc.index] = view_as<Function>(TornUmbralGate_NPCDeath);
		func_NPCThink[npc.index] = view_as<Function>(TornUmbralGate_ClotThink);
		func_NPCOnTakeDamage[npc.index] = TornUmbralGate_OnTakeDamage;
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 50);
		EmitSoundToAll("weapons/physcannon/energy_sing_loop4.wav", npc.index, SNDCHAN_STATIC, 120, _, 0.8, 50);
	
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
	TornUmbralGate_Visuals(npc);
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 0.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, /*duration*/ TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 200.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, /*duration*/ TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, 400.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, /*duration*/ TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, -200.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, /*duration*/ TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
	spawnRing_Vectors(VecSelfNpcabs, TORN_UMBRAL_GATEWAY * 2.0, 0.0, 0.0, -400.0, "materials/sprites/combineball_trail_black_1.vmt", 255, 255, 255, 125, 1, /*duration*/ TORN_UMBRAL_DURATION, 10.0, 1.0, 1);	
		
	
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
		MaxHealthGet /= 10;
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
}

void TornUmbralGate_Visuals(TornUmbralGate npc)
{

	int RGBA[4] = {255,255,255, 255};
	/*
		its 200 units across big
	*/
	//Gate stuff
	float vecSelf[3];
	GetEntPropVector(npc.index, Prop_Send, "m_vecOrigin", vecSelf);
	float VecPos1[3],VecPos2[3];

	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 25.0;
	VecPos2[2] += 100.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_Combine_Black, 0, 0, 0, TORN_UMBRAL_DURATION, 6.0, 40.0, 0, 2.0, RGBA, 3);
	TE_SendToAll(0.0);


	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 100.0;
	VecPos2[2] += 175.0;
	TE_SetupGlowSprite(VecPos1, gGlow2, TORN_UMBRAL_DURATION, 2.0, 255);
	TE_SendToAll();
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_Combine_Black, 0, 0, 0, TORN_UMBRAL_DURATION, 40.0, 6.0, 0, 2.0, RGBA, 3);
	TE_SendToAll(0.0);

	//outer eye layer
	RGBA = {185,60,185, 255};

	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 200.0;
	VecPos2[2] += 100.0;
	VecPos2[1] += 250.0;
	TE_SetupGlowSprite(VecPos1, gGlow1, TORN_UMBRAL_DURATION, 1.0, 255);
	TE_SendToAll();
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_lightning, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 4.0, RGBA, 3);
	TE_SendToAll(0.0);
	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 200.0;
	VecPos2[2] += 100.0;
	VecPos2[1] -= 250.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_lightning, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 4.0, RGBA, 3);
	TE_SendToAll(0.0);

	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
//	VecPos1[2] += 200.0;
	VecPos2[2] += 100.0;
	VecPos2[1] += 250.0;
	TE_SetupGlowSprite(VecPos1, gGlow1, TORN_UMBRAL_DURATION, 1.0, 255);
	TE_SendToAll();
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_lightning, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 4.0, RGBA, 3);
	TE_SendToAll(0.0);
	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
//	VecPos1[2] += 200.0;
	VecPos2[2] += 100.0;
	VecPos2[1] -= 250.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_BEAM_lightning, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 4.0, RGBA, 3);
	TE_SendToAll(0.0);


	
	//inner eye layer
	RGBA = {255,60,100, 255};

	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 190.0;
	VecPos2[2] += 100.0;
	VecPos2[1] += 90.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_HALO_Laser, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 1.0, RGBA, 3);
	TE_SendToAll(0.0);
	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 190.0;
	VecPos2[2] += 100.0;
	VecPos2[1] -= 90.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_HALO_Laser, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 1.0, RGBA, 3);
	TE_SendToAll(0.0);

	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 10.0;
	VecPos2[2] += 100.0;
	VecPos2[1] += 90.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_HALO_Laser, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 1.0, RGBA, 3);
	TE_SendToAll(0.0);
	
	VecPos1 = vecSelf;
	VecPos2 = vecSelf;
	VecPos1[2] += 10.0;
	VecPos2[2] += 100.0;
	VecPos2[1] -= 90.0;
	TE_SetupBeamPoints(VecPos1, VecPos2, g_Ruina_HALO_Laser, 0, 0, 0, TORN_UMBRAL_DURATION, 12.0, 12.0, 0, 1.0, RGBA, 3);
	TE_SendToAll(0.0);

	

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