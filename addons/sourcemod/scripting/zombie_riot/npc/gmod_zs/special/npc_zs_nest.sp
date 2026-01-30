#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"zombie_riot/gmod_zs/nest/nest_break.wav",
};

static const char g_HurtSounds[][] = {
	"physics/body/flesh_squishy_impact_hard1.wav",
	"physics/body/flesh_squishy_impact_hard2.wav",
	"physics/body/flesh_squishy_impact_hard3.wav",
	"physics/body/flesh_squishy_impact_hard4.wav",
};


static const char g_IdleSounds[][] = {
	"ambient/levels/citadel/citadel_drone_loop5.wav",
};

static const char g_IdleAlertedSounds[][] = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
	"npc/barnacle/barnacle_die1.wav",
	"npc/barnacle/barnacle_die2.wav",
	"npc/barnacle/barnacle_digesting1.wav",
	"npc/barnacle/barnacle_digesting2.wav",
	"npc/barnacle/barnacle_gulp1.wav",
	"npc/barnacle/barnacle_gulp2.wav",
};

static const char g_MeleeHitSounds[][] = {
	"weapons/cleaver_hit_02.wav",
	"weapons/cleaver_hit_03.wav",
	"weapons/cleaver_hit_05.wav",
	"weapons/cleaver_hit_06.wav",
	"weapons/cleaver_hit_07.wav",
};

static const char g_MeleeAttackSounds[][] = {
	"weapons/bow_shoot.wav",
};

static const char g_MeleeMissSounds[][] = {
	"zombie_riot/gmod_zs/nest/nest_spawn_enemy.wav",
};

#define NEST_CORE_MODEL "models/zombie_riot/gmod_zs/nest/nest.mdl"
#define NEST_CORE_MODEL_SIZE "0.4"


static float f_PlayerScalingBuilding;
static int i_currentwave[MAXENTITIES];
static bool AllyIsBoundToVillage[MAXENTITIES];
//static int NPCId;

/*
void ResetBoundNestAlly(int entity)
{
	AllyIsBoundToVillage[entity] = false;
}
*/

void Nest_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleAlertedSounds)); i++) { PrecacheSound(g_IdleAlertedSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }
	PrecacheModel(NEST_CORE_MODEL);

	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Nest");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_nest");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_nest"); 	
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);
}

/*
int Nest_Id()
{
	return NPCId;
}
*/

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return Nest(vecPos, vecAng, team, data);
}

methodmap Nest < CClotBody
{
	public void PlayIdleSound() 
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(24.0, 48.0);

	}
	
	public void PlayIdleAlertSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleAlertedSounds[GetRandomInt(0, sizeof(g_IdleAlertedSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);

	}
	
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);

	}
	
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		

	}

	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, _, BOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME, 100);
		
	}
	
	public Nest(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		Nest npc = view_as<Nest>(CClotBody(vecPos, vecAng, NEST_CORE_MODEL, NEST_CORE_MODEL_SIZE, MinibossHealthScaling(50.0), ally, false,true,_,_,{30.0,30.0,200.0}, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
//		int iActivity = npc.LookupActivity("ACT_VILLAGER_RUN");
//		if(iActivity > 0) npc.StartActivity(iActivity);
		
		
		npc.m_iWearable1 = npc.EquipItemSeperate("models/zombie_riot/gmod_zs/nest/nest.mdl");
		SetEntPropFloat(npc.m_iWearable1, Prop_Send, "m_flModelScale", 0.4);
		
		if(data[0])
		{
			i_AttacksTillMegahit[npc.index] = StringToInt(data);
			SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
			SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		}

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_bDissapearOnDeath = true;
		
		func_NPCDeath[npc.index] = Nest_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = Nest_OnTakeDamage;
		func_NPCThink[npc.index] = Nest_ClotThink;

		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		if(ally != TFTeam_Red)
		{
			b_thisNpcIsABoss[npc.index] = true;
		}
		i_NpcIsABuilding[npc.index] = true;

		float wave = float(Waves_GetRoundScale()+1);
		
		wave *= 0.133333;
	
		npc.m_flWaveScale = wave;
		// npc.m_flWaveScale *= MinibossScalingReturn();

		b_ThisNpcIsImmuneToNuke[npc.index] = true;

		f_PlayerScalingBuilding = ZRStocks_PlayerScalingDynamic();
		if(f_PlayerScalingBuilding > 10.0)
			f_PlayerScalingBuilding = 10.0;

		i_currentwave[npc.index] = RoundToNearest(npc.m_flWaveScale * 10.0);

		GiveNpcOutLineLastOrBoss(npc.index, true);

		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		
		AddNpcToAliveList(npc.index, 1);
		b_HideHealth[npc.index] = false;
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.0;
		f_ExtraOffsetNpcHudAbove[npc.index] = 180.0;

		return npc;
	}
}

static char g_10wave[][] = {
    "npc_zs_zombie",
    "npc_zs_fast_zombie",
	"npc_zs_shadow_walker",
	"npc_zs_skeleton",
	"npc_zs_gore_blaster",
	"npc_fastzombie_fortified",
	"npc_headcrabzombie_fortified",
	"npc_torsoless_headcrabzombie",
};

static char g_20wave[][] = {
	"npc_zs_shadow_walker",
	"npc_zs_skeleton",
	"npc_zs_headcrabzombie",
	"npc_zs_fastheadcrab_zombie",
	"npc_zs_gore_blaster",
	"npc_zs_runner",
	"npc_zs_spitter",
};

static char g_30wave[][] = {
	"npc_zs_kamikaze_demo",
	"npc_zs_medic_healer",
	"npc_zs_huntsman",
	"npc_zs_zombie_demoknight",
	"npc_zs_zombie_engineer",
	"npc_zs_zombie_heavy",
	"npc_zs_zombie_scout",
	"npc_zs_zombie_sniper_jarate",
	"npc_zs_zombie_soldier",
	"npc_zs_zombie_soldier_pickaxe",
	"npc_zs_zombie_spy",
	"npc_zombie_pyro_giant_main",
	"npc_zombie_scout_grave",
	"npc_zombie_soldier_grave",
	"npc_zombie_spy_grave",
	"npc_zombie_demo_main",
	"npc_zombie_heavy_grave",
};
static char g_40wave[][] = {
	"npc_zs_kamikaze_demo",
	"npc_zs_medic_healer",
	"npc_zs_huntsman",
	"npc_zs_zombie_demoknight",
	"npc_zs_zombie_engineer",
	"npc_zs_zombie_heavy",
	"npc_zs_zombie_scout",
	"npc_zs_zombie_sniper_jarate",
	"npc_zs_zombie_soldier",
	"npc_zs_zombie_soldier_pickaxe",
	"npc_zs_zombie_spy",
	"npc_zs_cleaner",
	"npc_zs_eradicator",
	"npc_zs_firefighter",
	"npc_zombine",
	"npc_zs_medic_main",
	"npc_zs_mlsm",
	"npc_zs_sam",
	"npc_zs_sniper",
	"npc_zs_zombie_breadmonster",
	"npc_zs_zombie_fatscout",
	"npc_zs_zombie_fatspy",
};

public void Nest_ClotThink(int iNPC)
{
	Nest npc = view_as<Nest>(iNPC);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();	

	if(npc.m_blPlayHurtAnimation)
	{
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}

	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}

	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.05;
	

	if(i_AttacksTillMegahit[iNPC] >= 255)
	{
		if(i_AttacksTillMegahit[iNPC] <= 600)
		{
			i_AttacksTillMegahit[iNPC] = 601;
			SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, 255);
			SetEntityRenderMode(npc.m_iWearable1, RENDER_NORMAL);
		}

		if(npc.m_flAttackHappens < GetGameTime(npc.index)) //spawn enemy!
		{
			int npc_current_count;
			for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
			{
				int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
				if(IsValidEntity(entity) && GetTeam(iNPC) == GetTeam(entity))
				{
					npc_current_count += 1;
				}
			}
			//emercency stop. 
			float IncreaseSpawnRates = 6.5;

			IncreaseSpawnRates /= (Pow(1.14, f_PlayerScalingBuilding));

			if((GetTeam(iNPC) != TFTeam_Red && npc_current_count < MaxEnemiesAllowedSpawnNext(0)) || (GetTeam(iNPC) == TFTeam_Red && npc_current_count < 6))
			{
				float AproxRandomSpaceToWalkTo[3];
				GetEntPropVector(iNPC, Prop_Data, "m_vecAbsOrigin", AproxRandomSpaceToWalkTo);
				
				AproxRandomSpaceToWalkTo[2] += 10.0;

				char EnemyToSpawn[255];
				bool Construct = false;

				if(GetTeam(iNPC) == TFTeam_Red)
				{
					IncreaseSpawnRates *= 0.5; //way slower.
				}
				
				if(i_currentwave[iNPC] < 15) {
					int idx = GetRandomInt(0, sizeof(g_10wave) - 1);
					strcopy(EnemyToSpawn, sizeof(EnemyToSpawn), g_10wave[idx]);
					//IncreaseSpawnRates *= 0.8;
				} 
				else if(i_currentwave[iNPC] < 28) {
					int idx = GetRandomInt(0, sizeof(g_20wave) - 1);
					strcopy(EnemyToSpawn, sizeof(EnemyToSpawn), g_20wave[idx]);
					//IncreaseSpawnRates *= 0.8;
				}
				else if(i_currentwave[iNPC] < 41)
				{
					int idx = GetRandomInt(0, sizeof(g_30wave) - 1);
					strcopy(EnemyToSpawn, sizeof(EnemyToSpawn), g_30wave[idx]);
				}
				else 
				{
					int idx = GetRandomInt(0, sizeof(g_40wave) - 1);
					strcopy(EnemyToSpawn, sizeof(EnemyToSpawn), g_40wave[idx]);
				}
				
				if(Rogue_Mode())
					IncreaseSpawnRates *= 3.0;

				int spawn_index = NPC_CreateByName(EnemyToSpawn, -1, AproxRandomSpaceToWalkTo, {0.0,0.0,0.0}, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					b_StaticNPC[spawn_index] = b_StaticNPC[iNPC];
					if(b_StaticNPC[spawn_index])
						AddNpcToAliveList(spawn_index, 1);
						b_HideHealth[npc.index] = false;
					
					npc.PlayMeleeMissSound();
					npc.PlayMeleeMissSound();
					if(GetTeam(iNPC) != TFTeam_Red)
					{
						if(!b_StaticNPC[spawn_index])
							NpcAddedToZombiesLeftCurrently(spawn_index, true);
					}
					else
					{
						AllyIsBoundToVillage[spawn_index] = true;
					}
					if(Construct)
					{
						SetEntProp(spawn_index, Prop_Data, "m_iHealth", 55000);
						SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 55000);
						fl_Extra_Damage[spawn_index] = 1.35;
					}
				}	
			}
			else
			{
				IncreaseSpawnRates = 0.0; //Try again next frame.
			}

			npc.m_flAttackHappens = GetGameTime(npc.index) + IncreaseSpawnRates;
		}
		/*
		if(npc.m_flNextMeleeAttack < GetGameTime(npc.index))
		{
			//Shoot arrow!
			int Target;
			Target = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(IsValidEnemy(npc.index, Target))
			{
				int Enemy_I_See;
				Enemy_I_See = Can_I_See_Enemy(npc.index, Target);
				//Target close enough to hit
				if(IsValidEnemy(npc.index, Enemy_I_See))
				{
					
					//float IncreaseAttackspeed = 1.0;


					//IncreaseAttackspeed *= (1.0 - ((12.0 - 1.0) * 7.0 / 110.0));
					
					npc.m_flNextMeleeAttack = GetGameTime(npc.index) + 5.0;
					npc.m_flAttackHappens_bullshit = GetGameTime(npc.index) + (f_PlayerScalingBuilding * 0.055);
				}
			}
		}
		if(npc.m_flAttackHappens_bullshit > GetGameTime(npc.index))
		{
			int Target;
			Target = GetClosestTarget(npc.index,_,_,_,_,_,_,true);
			if(IsValidEnemy(npc.index, Target))
			{
				float vecTarget[3];
				float projectile_speed = 0.0;
				WorldSpaceCenter(Target, vecTarget );

				npc.PlayMeleeSound();

				float damage = 0.0;	

				damage *= npc.m_flWaveScale;

				npc.FireArrow(vecTarget, damage, projectile_speed,_,_, 75.0);
			}
			else
			{
				//none...
				Target = GetClosestTarget(npc.index,_,_,_,_,_,_,false);
				if(IsValidEnemy(npc.index, Target))
				{
					float vecTarget[3];
					float projectile_speed = 0.0;
					WorldSpaceCenter(Target, vecTarget );

					npc.PlayMeleeSound();

					float damage = 0.0;	

					damage *= npc.m_flWaveScale;

					npc.FireArrow(vecTarget, damage, projectile_speed,_,_, 75.0);
				}
			}
		}
		*/
	}
	else
	{
		bool villagerexists = false;
		for(int entitycount_again_2; entitycount_again_2<i_MaxcountNpcTotal; entitycount_again_2++) //Check for npcs
		{
			int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount_again_2]);
			if(IsValidEntity(entity) && i_NpcInternalId[entity] == FleshCreeper_ID() && !b_NpcHasDied[entity] && GetTeam(entity) == GetTeam(iNPC))
			{
				villagerexists = true;
			}
		}
		if(!villagerexists)
		{
			//SmiteNpcToDeath(iNPC);
			return;
		}

		int alpha = i_AttacksTillMegahit[iNPC];
		if(alpha > 255)
		{
			alpha = 255;
		}
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, 255, 255, 255, alpha);
	}
}

public Action Nest_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	Nest npc = view_as<Nest>(victim);
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void Nest_NPCDeath(int entity)
{
	Nest npc = view_as<Nest>(entity);
	npc.PlayDeathSound();	

	/*
	float pos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
	makeexplosion(-1, pos, 0, 0);
	*/

	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}