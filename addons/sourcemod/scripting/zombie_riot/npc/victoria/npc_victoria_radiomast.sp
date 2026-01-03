#pragma semicolon 1
#pragma newdecls required

#define VictoriaRadiomast_MODEL_1 "models/props_spytech/radio_tower001.mdl"
#define VictoriaRadiomast_MODEL_2 "models/props_powerhouse/powerhouse_turbine.mdl"
#define VictoriaRadiomast_MODEL_3 "models/props_urban/urban_skytower006.mdl"

static const char g_DeathSounds[][] = {
	"ambient/explosions/explode_3.wav",
	"ambient/explosions/explode_4.wav",
	"ambient/explosions/explode_9.wav"
};

static const char g_HurtSounds[][] = {
	")physics/metal/metal_box_impact_bullet1.wav",
	")physics/metal/metal_box_impact_bullet2.wav",
	")physics/metal/metal_box_impact_bullet3.wav"
};

void VictoriaRadiomast_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Victoria Radiomast");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_victoria_radiomast");
	strcopy(data.Icon, sizeof(data.Icon), "victoria_radiomast");
	data.IconCustom = true;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Victoria;
	data.Precache = ClotPrecache;
	data.Func = ClotSummon;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheModel(VictoriaRadiomast_MODEL_1);
	PrecacheModel(VictoriaRadiomast_MODEL_2);
	PrecacheModel(VictoriaRadiomast_MODEL_3);
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int ally, const char[] data)
{
	return VictoriaRadiomast(vecPos, vecAng, ally, data);
}

methodmap VictoriaRadiomast < CClotBody
{
	public void PlayHurtSound() 
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	public void PlayDeathSound() 
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, BOSS_ZOMBIE_SOUNDLEVEL, _, 0.3);
	}
	
	public VictoriaRadiomast(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		VictoriaRadiomast npc = view_as<VictoriaRadiomast>(CClotBody(vecPos, vecAng, TOWER_MODEL, TOWER_SIZE,"1000000", ally, false,true,_,_,{30.0,30.0,200.0}, .NpcTypeLogic = 1));
		
		i_NpcWeight[npc.index] = 999;
		SetEntityRenderMode(npc.index, RENDER_NONE);
		SetEntityRenderColor(npc.index, 0, 0, 0, 0);
		npc.m_iWearable1 = npc.EquipItemSeperate(VictoriaRadiomast_MODEL_1,_,1);
		SetVariantString("0.5");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");
		npc.m_iWearable2 = npc.EquipItemSeperate(VictoriaRadiomast_MODEL_2,_,_,_,70.0);
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");
		npc.m_iWearable3 = npc.EquipItemSeperate(VictoriaRadiomast_MODEL_3,_,1);
		SetVariantString("0.95");
		AcceptEntityInput(npc.m_iWearable2, "SetModelScale");

		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = 0;	
		npc.m_iNpcStepVariation = 0;
		
		f_ExtraOffsetNpcHudAbove[npc.index] = 200.0;
		i_NpcIsABuilding[npc.index] = true;
		fl_GetClosestTargetTimeTouch[npc.index] = FAR_FUTURE;
		b_thisNpcIsABoss[npc.index] = true;
		if(!IsValidEntity(RaidBossActive))
		{
			RaidModeTime = FAR_FUTURE;
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidAllowsBuildings = true;
			RaidModeScaling = 0.0;
		}

		func_NPCDeath[npc.index] = VictoriaRadiomast_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = VictoriaRadiomast_OnTakeDamage;
		func_NPCThink[npc.index] = VictoriaRadiomast_ClotThink;
		
		//IDLE
		npc.m_iState = 0;
		npc.m_flSpeed = 0.0;
		npc.m_bDissapearOnDeath = true;
		npc.m_bLostHalfHealth = false;
		npc.Anger = false;
		npc.m_bFUCKYOU = (StrContains(data, "death_func") != -1);
		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_flMeleeArmor = 2.5;
		npc.m_flRangedArmor = 1.25;
		
		int Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 1000.0);
		switch(Decicion)
		{
			case 2:
			{
				Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 500.0);
				if(Decicion == 2)
				{
					Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 250.0);
					if(Decicion == 2)
					{
						Decicion = TeleportDiversioToRandLocation(npc.index, true, 1500.0, 0.0);
					}
				}
			}
			case 3:
			{
				//todo code on what to do if random teleport is disabled
			}
		}
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "obj_status_dispenser", 1, "%t", "Victorian Radiomast Is Here!");
			}
		}
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		EmitSoundToAll("weapons/rescue_ranger_teleport_receive_01.wav", npc.index, SNDCHAN_STATIC, 120, _, RAIDBOSSBOSS_ZOMBIE_VOLUME);
		float VecSelfNpcabs[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", VecSelfNpcabs);
		VecSelfNpcabs[2] += 200.0;
		Event event = CreateEvent("show_annotation");
		if(event)
		{
			event.SetFloat("worldPosX", VecSelfNpcabs[0]);
			event.SetFloat("worldPosY", VecSelfNpcabs[1]);
			event.SetFloat("worldPosZ", VecSelfNpcabs[2]);
		//	event.SetInt("follow_entindex", 0);
			event.SetFloat("lifetime", 7.0);
		//	event.SetInt("visibilityBitfield", (1<<client));
			//event.SetBool("show_effect", effect);
			event.SetString("text", "Radio Tower!");
			event.SetString("play_sound", "vo/null.mp3");
			IdRef++;
			event.SetInt("id", IdRef); //What to enter inside? Need a way to identify annotations by entindex!
			event.Fire();
		}
		return npc;
	}
}

public void VictoriaRadiomast_ClotThink(int iNPC)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(iNPC);
	float gameTime = GetGameTime(npc.index);

	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;

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
	//global range.
	npc.m_flNextRangedSpecialAttack = 0.0;

	gameTime = GetGameTime() + 0.5;
	float InfiniteWave = 5.0;
	int team = GetTeam(npc.index);
	if(team == 2)
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client) && GetClientTeam(client) != 3 && IsEntityAlive(client))
				ApplyStatusEffect(npc.index, client, "Call To Victoria", 0.5);
		}
	}
	//beep say
	//make it affected by attack speed, idk
	if(Waves_IsEmpty() && npc.m_flNextMeleeAttack < gameTime)
	{
		int ISVOLI = 4;
		int VICTORIA = RoundToNearest(MultiGlobalEnemyBoss * 1.2); 
		for(int i=1; i<=VICTORIA; i++)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:
				{
					for(int ii=1; ii<=ISVOLI; ii++)
					{
						switch(GetRandomInt(1, 9))
						{
							case 1:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_batter",30000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 2:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_charger",35000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 3:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_teslar",35000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}	
							case 4:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_victorian_vanguard",35000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 5:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_supplier",30000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 6:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_ballista",30000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 7:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_grenadier",30000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 8:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_igniter",120000,3.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 9:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_squadleader",65000,2.0, RoundToCeil(1.0 * MultiGlobalEnemy));
							}
						}
					}
				}
				case 2:
				{
					for(int ii=1; ii<=ISVOLI; ii++)
					{
						switch(GetRandomInt(1, 10))
						{
							case 1:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_humbee",120000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 2:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_shotgunner",30000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 3:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_bulldozer",120000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}	
							case 4:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_hardener",30000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 5:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_raider",30000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 6:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_zapper",35000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 7:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_payback",120000,2.25, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 8:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_blocker",35000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 9:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_destructor",35000,2.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 10:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_ironshield",100000,2.0, RoundToCeil(1.0 * MultiGlobalEnemy));
							}
						}
					}
				}
				case 3:
				{
					for(int ii=1; ii<=ISVOLI; ii++)
					{
						switch(GetRandomInt(1, 9))
						{
							case 1:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_basebreaker",40000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 2:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_booster",40000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 3:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_scorcher",40000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}	
							case 4:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_mowdown",150000,1.3, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 5:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_mechafist",45000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 6:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_assaulter",40000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 7:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_antiarmor_infantry",40000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 8:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_mortar",40000,1.3, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 9:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_breachcart",160000,1.2, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
						}
					}
				}
				case 4:
				{
					for(int ii=1; ii<=ISVOLI; ii++)
					{
						switch(GetRandomInt(1, 8))
						{
							case 1:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_caffeinator",40000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 2:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_welder",45000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 3:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_mechanist",50000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}	
							case 4:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_tanker",45000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 5:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_pulverizer",40000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 6:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_ambusher",40000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
							case 7:
							{
								VictoriaRadiomastSpawnEnemy(npc.index,"npc_taser",40000,1.0, RoundToCeil(4.0 * MultiGlobalEnemy));
							}
						}
					}
				}
			}
		}
		npc.m_flNextMeleeAttack = gameTime+InfiniteWave;
	}

	for(int i; i < i_MaxcountNpcTotal; i++)
	{
		int entity = EntRefToEntIndexFast(i_ObjectsNpcsTotal[i]);
		if(entity != npc.index && entity != INVALID_ENT_REFERENCE && IsEntityAlive(entity) && GetTeam(entity) == team)
		{
			ApplyStatusEffect(npc.index, entity, "Call To Victoria", 0.5);
		}
	}

	if(!npc.Anger && npc.m_bLostHalfHealth)
	{
		int health = ReturnEntityMaxHealth(npc.index) / 10;
		float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
		float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);

		char Adddeta[512];
		FormatEx(Adddeta, sizeof(Adddeta), "target%i;", npc.index);
		for(int i=1; i<=4; i++)
		{
			int other = NPC_CreateByName("npc_radioguard", -1, pos, ang, team, Adddeta);
			if(other > MaxClients)
			{
				if(team != TFTeam_Red)
					Zombies_Currently_Still_Ongoing++;
				
				SetEntProp(other, Prop_Data, "m_iHealth", health);
				SetEntProp(other, Prop_Data, "m_iMaxHealth", health);
				NpcAddedToZombiesLeftCurrently(other, true);
				fl_Extra_MeleeArmor[other] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[other] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[other] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[other] = fl_Extra_Damage[npc.index];
				b_thisNpcIsABoss[other] = b_thisNpcIsABoss[npc.index];
				b_StaticNPC[other] = b_StaticNPC[npc.index];
				if(b_StaticNPC[other])
					AddNpcToAliveList(other, 1);
			}
			int other1 = NPC_CreateByName("npc_radio_repair", -1, pos, ang, team, Adddeta);
			if(other1 > MaxClients)
			{
				if(team != TFTeam_Red)
					Zombies_Currently_Still_Ongoing++;
				
				SetEntProp(other1, Prop_Data, "m_iHealth", health);
				SetEntProp(other1, Prop_Data, "m_iMaxHealth", health);
				NpcAddedToZombiesLeftCurrently(other1, true);
				fl_Extra_MeleeArmor[other1] = fl_Extra_MeleeArmor[npc.index];
				fl_Extra_RangedArmor[other1] = fl_Extra_RangedArmor[npc.index];
				fl_Extra_Speed[other1] = fl_Extra_Speed[npc.index];
				fl_Extra_Damage[other1] = fl_Extra_Damage[npc.index];
				b_thisNpcIsABoss[other1] = b_thisNpcIsABoss[npc.index];
				b_StaticNPC[other1] = b_StaticNPC[npc.index];
				if(b_StaticNPC[other])
					AddNpcToAliveList(other, 1);
			}
		 }
		npc.Anger = true;
	}
}

public Action VictoriaRadiomast_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(victim);
	
	if((ReturnEntityMaxHealth(npc.index)/2) >= GetEntProp(npc.index, Prop_Data, "m_iHealth") && !npc.m_bLostHalfHealth) 
	{
		npc.m_bLostHalfHealth = true;
	}

	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	return Plugin_Changed;
}

public void VictoriaRadiomast_NPCDeath(int entity)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(entity);
	npc.PlayDeathSound();	
	
	if(npc.m_bFUCKYOU)
	{
		for(int entitycount; entitycount<i_MaxcountNpcTotal; entitycount++)
		{
			int IsBaguettus = EntRefToEntIndexFast(i_ObjectsNpcsTotal[entitycount]);
			if(IsValidEntity(IsBaguettus) && i_NpcInternalId[IsBaguettus] == CaptinoBaguettus_ID() && !b_NpcHasDied[IsBaguettus])
			{
				CaptinoBaguettus Baguettus = view_as<CaptinoBaguettus>(IsBaguettus);
				Baguettus.m_bFUCKYOU=true;
				break;
			}
		}
	}

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
	if(IsValidEntity(npc.m_iWearable8))
		RemoveEntity(npc.m_iWearable8);
}

void VictoriaRadiomastSpawnEnemy(int iNPC, char[] plugin_name, int health = 0, float damage, int count, bool is_a_boss = false)
{
	VictoriaRadiomast npc = view_as<VictoriaRadiomast>(iNPC);
	if(GetTeam(npc.index) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(npc.index));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = damage;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 5);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 5);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(npc.index);
	for(int i; i<count; i++)
	{
		Waves_AddNextEnemy(enemy);
	}
	Zombies_Currently_Still_Ongoing += count;	// FIXME
}
